---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_POLICY_DOC_READ_DETAILS_GET]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		VARCHAR(MAX)
	,@Cat_ID		VARCHAR(MAX)
	,@Grd_ID		VARCHAR(MAX)
	,@Type_ID		VARCHAR(MAX) 
	,@Dept_ID		VARCHAR(MAX)
	,@Desig_ID		VARCHAR(MAX)
	,@Emp_ID		NUMERIC			= 0
	,@Constraint	VARCHAR(MAX)	= ''
	,@New_Join_emp	NUMERIC		= 0 
	,@Left_Emp		NUMERIC		= 0
	,@Salary_Cycle_id NUMERIC	= NULL
	,@Segment_Id	VARCHAR(MAX) = ''	
	,@Vertical_Id	VARCHAR(MAX) = ''	 
	,@SubVertical_Id VARCHAR(MAX)	= ''	
	,@SubBranch_Id	VARCHAR(MAX)	= ''
	,@Policy_ID		NUMERIC		= 0
	,@Report_Type	VARCHAR(50)	= 'ALL'
	,@Is_Mobile_Read tinyint = 0       --Added By Dhruv --0 WEB ,1--MOBILE,2--WEB & MOBILE
	,@Format VARCHAR(50) = @Report_Type
	,@Bank_ID	varchar(Max) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @CurPolicyID NUMERIC(18,0)
	DECLARE @CurPolicyEmpID VARCHAR(MAX)
	DECLARE @CurPolicyDeptID VARCHAR(MAX)
	DECLARE @CurPolicyTitle VARCHAR(500)
	
	SET @CurPolicyID = 0
	SET @CurPolicyEmpID = ''
	SET @CurPolicyDeptID = ''
	SET @CurPolicyTitle = ''
		
	IF @Policy_ID = 0
		SET @Policy_ID = NULL	
	
	 CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID NUMERIC ,     
	   Branch_ID NUMERIC,
	   Increment_ID NUMERIC    
	 )  
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'0',0,0,@Bank_ID    
	
	CREATE TABLE #POLICY
	(
		Policy_ID		NUMERIC,
		Policy_Title	VARCHAR(100),
		EMP_ID			NUMERIC,
		Read_Datetime	VARCHAR(20),
		Row_id			NUMERIC,	  --added  on 19 oct 2015
		Is_mobile_read  tinyint		 --Added By Dhruv 18032017
	)
	
	
	INSERT INTO #POLICY	----For All Policy
	SELECT PD.Policy_Doc_ID,PD.Policy_Title,EM.Emp_ID,NULL,NULL,NULL
	FROM T0040_POLICY_DOC_MASTER PD WITH (NOLOCK) LEFT OUTER JOIN
		T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Cmp_ID = PD.Cmp_ID 
	WHERE  CAST(@Cmp_ID AS varchar) in (select Data from dbo.Split(isnull(cmp_id_multi,pd.cmp_id),'#')) 
	AND EM.Emp_ID IN ( SELECT Emp_ID FROM #Emp_Cons )
		AND (PD.Emp_ID = '0' AND PD.Dept_Id = '0') 
		AND ISNULL(PD.Policy_Doc_ID,0) = ISNULL(@Policy_ID ,ISNULL(PD.Policy_Doc_ID,0))
	ORDER BY PD.Policy_Title
	
	
	
	DECLARE CurPolicyID	CURSOR FOR	--For Employee/Department policy
		SELECT PD.Policy_Doc_ID,PD.Policy_Title,PD.Emp_ID,PD.Dept_Id
		FROM T0040_POLICY_DOC_MASTER PD WITH (NOLOCK)
		WHERE  CAST(@Cmp_ID AS varchar) in (select DATA from dbo.Split(isnull(cmp_id_multi,pd.cmp_id),'#')) AND (PD.Emp_ID <> '0' OR PD.Dept_Id <> '0') 
			AND ISNULL(PD.Policy_Doc_ID,0) = ISNULL(@Policy_ID ,ISNULL(PD.Policy_Doc_ID,0))
		ORDER BY PD.Policy_Title
	OPEN CurPolicyID
	FETCH NEXT FROM CurPolicyID INTO @CurPolicyID,@CurPolicyTitle,@CurPolicyEmpID,@CurPolicyDeptID
	WHILE @@FETCH_STATUS = 0
		BEGIN
				IF @CurPolicyEmpID <> '0'
					BEGIN
						INSERT INTO #POLICY	
						SELECT @CurPolicyID,@CurPolicyTitle,Emp_ID,NULL,NULL,NULL
						FROM T0080_EMP_MASTER WITH (NOLOCK)
						WHERE Cmp_ID = @Cmp_Id AND Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons WHERE Emp_ID IN ( SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(LEFT(@CurPolicyEmpID,LEN(@CurPolicyEmpID)-1),'#')))
					END
				
				
				IF @CurPolicyDeptID <> '0'
					BEGIN
						INSERT INTO #POLICY	
						SELECT @CurPolicyID,@CurPolicyTitle,I.Emp_ID,NULL,NULL,NULL
						FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
								WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID 
										AND Dept_ID IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(LEFT(@CurPolicyDeptID,LEN(@CurPolicyDeptID)-1),'#'))
								GROUP BY emp_ID  
							) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	
						WHERE Cmp_ID = @Cmp_Id 
							AND Dept_ID IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(LEFT(@CurPolicyDeptID,LEN(@CurPolicyDeptID)-1),'#'))
							AND I.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
					END
						
			
			FETCH NEXT FROM CurPolicyID INTO @CurPolicyID,@CurPolicyTitle,@CurPolicyEmpID,@CurPolicyDeptID
		END
	CLOSE CurPolicyID
	DEALLOCATE CurPolicyID	
	
	
	---added on 19Oct 2015--sneha to capture multiple reads
	declare @CurPolicy_id as numeric(18,0)
	declare @readcnt as int
	declare @curempid numeric(18,0)
	
	declare cur_policy cursor for
		select Policy_ID,emp_id from #POLICY where row_id is null
	OPEN cur_policy
	FETCH NEXT FROM cur_policy INTO @CurPolicy_id,@curempid
	WHILE @@FETCH_STATUS = 0
		begin		
			select @readcnt =count(Read_Datetime) FROM T0090_EMP_POLICY_DOC_READ_DETAIL WITH (NOLOCK)
				WHERE  Read_Datetime <= GETDATE() and Cmp_ID = @Cmp_ID and  Policy_Doc_ID=@CurPolicy_id and Emp_ID =  @curempid
			
			if @readcnt = 1
				begin
					UPDATE #POLICY 
					SET	Read_Datetime = CONVERT(VARCHAR, EP.Read_Datetime, 105) + ' ' + CONVERT(VARCHAR, DATEPART(hh,  EP.Read_Datetime)) + ':' +  RIGHT('0' + CONVERT(VARCHAR, DATEPART(MI,  EP.Read_Datetime)),2) + CASE WHEN EP.Is_Mobile_Read = 1 THEN ' (M)' ELSE '' End,
						row_id = EP.Row_ID,Is_Mobile_Read = EP.Is_Mobile_Read
					FROM (select (Read_Datetime) AS Read_Datetime,Row_ID,Is_Mobile_Read  FROM T0090_EMP_POLICY_DOC_READ_DETAIL WITH (NOLOCK)
						WHERE  Read_Datetime <= GETDATE() and Cmp_ID = @Cmp_ID and  Policy_Doc_ID=@CurPolicy_id and EMP_ID=@curempid)EP
					WHERE Policy_ID = @CurPolicy_id and EMP_ID=@curempid
					
				
				end	
			Else if @readcnt > 1
				begin	
					UPDATE #POLICY 
					SET	Read_Datetime = CONVERT(VARCHAR, EP.Read_Datetime, 105) + ' ' + CONVERT(VARCHAR, DATEPART(hh,  EP.Read_Datetime)) + ':' +  RIGHT('0' + CONVERT(VARCHAR, DATEPART(MI,  EP.Read_Datetime)),2) + CASE WHEN EP.Is_Mobile_Read = 1 THEN ' (M)' ELSE '' End,
						row_id = EP.Row_ID,Is_Mobile_Read = EP.Is_Mobile_Read
					FROM (select Read_Datetime,Row_ID,Is_Mobile_Read FROM T0090_EMP_POLICY_DOC_READ_DETAIL WITH (NOLOCK)
						WHERE  Read_Datetime <= GETDATE() and Cmp_ID = @Cmp_ID and  Policy_Doc_ID=@CurPolicy_id and EMP_ID=@curempid
						and Read_Datetime = (select MAX(Read_Datetime) from T0090_EMP_POLICY_DOC_READ_DETAIL WITH (NOLOCK) where Read_Datetime <= GETDATE() 
						and Cmp_ID = @Cmp_ID and  Policy_Doc_ID=@CurPolicy_id and EMP_ID=@curempid))EP
					WHERE Policy_ID = @CurPolicy_id and EMP_ID=@curempid
				
					insert into #POLICY	
					Select ED.Policy_Doc_ID,pd.Policy_Title,ED.Emp_ID,CONVERT(VARCHAR, Read_Datetime, 105) + ' ' + CONVERT(VARCHAR, DATEPART(hh,  Read_Datetime)) + ':' +  RIGHT('0' + CONVERT(VARCHAR, DATEPART(MI,  Read_Datetime)),2) + CASE WHEN Is_Mobile_Read = 1 THEN ' (M)' ELSE '' End
							,Row_ID,ED.Is_Mobile_Read
					from   T0090_EMP_POLICY_DOC_READ_DETAIL ED WITH (NOLOCK) inner join
						   T0040_POLICY_DOC_MASTER PD WITH (NOLOCK) on pd.Policy_Doc_ID = ED.Policy_Doc_ID
					where  ED.Policy_Doc_ID =@CurPolicy_id and ED.Emp_ID = @curempid
							and Row_ID <> (select Row_ID from #POLICY where Policy_ID=@CurPolicy_id and EMP_ID=@curempid)
							--and CONVERT(VARCHAR(20), Read_Datetime, 100)  <> 
							--(select CONVERT(VARCHAR(20), max(Read_Datetime), 100) from #POLICY where Read_Datetime <= GETDATE() 
						-- and  Policy_ID=@CurPolicy_id and EMP_ID=@curempid 
				end				
			FETCH NEXT FROM cur_policy INTO @CurPolicy_id,@curempid
		end
	close 	cur_policy
	deallocate cur_policy
	--end on 19Oct 2015--sneha
	
	--commneted by sneha to capture multiple reads
	--UPDATE #POLICY
	--SET	Read_Datetime = CONVERT(VARCHAR(20), EP.Read_Datetime, 100)
	--FROM #POLICY P LEFT OUTER JOIN
	--	( SELECT ed.Read_Datetime,ED.Emp_ID,Policy_Doc_ID FROM  T0090_EMP_POLICY_DOC_READ_DETAIL ED INNER JOIN 
	--		( SELECT max(Read_Datetime) AS Read_Datetime,Emp_ID FROM T0090_EMP_POLICY_DOC_READ_DETAIL
	--			WHERE  Read_Datetime <= GETDATE() and Cmp_ID = @Cmp_ID GROUP by Emp_ID
	--		) Qry ON ED.Emp_ID = Qry.Emp_ID and ED.Read_Datetime = Qry.Read_Datetime
	--	) EP ON P.EMP_ID = EP.Emp_ID AND P.Policy_ID = EP.Policy_Doc_ID
	
	
	
	SELECT 
		E.Cmp_ID,E.Emp_ID, E.Alpha_Emp_Code,E.Emp_Full_Name,PC.Policy_Title,PC.Policy_ID,ISNULL(PC.Read_Datetime,'Unread') AS Read_Datetime
		,BM.Branch_Name,GM.Grd_Name,ETM.Type_Name,DGM.Desig_Name,DM.Dept_Name
		,CM.Cmp_Name,CM.Cmp_Address
	FROM #POLICY PC INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = PC.Emp_ID LEFT OUTER JOIN
		 ( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID
			FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
			 ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment WITH (NOLOCK)
				WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  
			 ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
		  ) I_Q ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
		dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
		dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
		dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN 
		dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
	WHERE E.Cmp_ID = @Cmp_ID AND E.EMP_LEFT = 'N' 
		AND ISNULL(PC.Read_Datetime,'Unread') = 
			CASE WHEN @Report_Type = 'Unread' THEN 'Unread' 
				 WHEN @Report_Type = 'ALL' THEN ISNULL(PC.Read_Datetime,'Unread')
			ELSE ISNULL(PC.Read_Datetime,'') END
		AND ISNULL(PC.Is_mobile_read,0) = CASE WHEN @Is_Mobile_Read = 2 THEN ISNULL(PC.Is_mobile_read,0) ELSE @Is_Mobile_Read END --Added By Dhruv 18032017			
	ORDER BY CASE WHEN ISNUMERIC(e.Alpha_Emp_Code) = 1 THEN
				RIGHT(REPLICATE('0',21) + e.Alpha_Emp_Code, 20)
			 ELSE LEFT(e.Alpha_Emp_Code + REPLICATE('',21), 20) END	,PC.Policy_Title
		
	
drop table #POLICY

RETURN
