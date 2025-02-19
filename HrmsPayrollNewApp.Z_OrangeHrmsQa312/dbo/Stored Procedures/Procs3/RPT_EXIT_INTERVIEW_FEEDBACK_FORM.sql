




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_EXIT_INTERVIEW_FEEDBACK_FORM]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime  =null
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	
	IF @Branch_ID = 0
		SET @Branch_ID = null
	IF @Cat_ID = 0
		SET @Cat_ID = null		 
	IF @Type_ID = 0
		SET @Type_ID = null
	IF @Dept_ID = 0
		SET @Dept_ID = null
	IF @Grd_ID = 0
		SET @Grd_ID = null
	IF @Emp_ID = 0
		SET @Emp_ID = null		
	IF @Desig_ID = 0
		SET @Desig_ID = null
		
	--DECLARE @Emp_Cons TABLE
	--(
	--	Emp_ID	NUMERIC
	--)
	
	--IF @Constraint <> ''
	--	BEGIN
	--		INSERT INTO @Emp_Cons
	--		SELECT  cast(data  as NUMERIC) FROM dbo.Split (@Constraint,'#') 
	--	END
	--ELSE
	--	BEGIN
	--		IF @To_Date is not null
	--			BEGIN
	--				INSERT INTO @Emp_Cons
	--				SELECT I.Emp_Id FROM T0095_Increment I inner join 
	--						( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment	-- Ankit 10092014 for Same Date Increment
	--						WHERE Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						GROUP BY emp_ID  ) Qry ON
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
	--				WHERE Cmp_ID = @Cmp_ID 
	--				AND Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				AND Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				AND Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				AND isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				AND Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				AND Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				AND I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				AND I.Emp_ID IN 
	--					( SELECT Emp_Id FROM
	--					(SELECT emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN) qry
	--					 WHERE cmp_ID = @Cmp_ID   AND  
	--					(( @From_Date  >= join_Date  AND  @From_Date <= left_date ) 
	--					OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )
	--					OR Left_date IS NULL AND @To_Date >= Join_Date)
	--					OR @To_Date >= left_date  AND  @From_Date <= left_date ) 
	--			END
	--		ELSE
	--			BEGIN
	--				SELECT I.Emp_Id FROM T0095_Increment I inner join 
	--						( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment	-- Ankit 10092014 for Same Date Increment
	--						WHERE Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						GROUP BY emp_ID  ) Qry ON
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
	--				WHERE Cmp_ID = @Cmp_ID 
	--				AND Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				AND Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				AND Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				AND isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				AND Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				AND Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				AND I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				AND I.Emp_ID IN 
	--					( SELECT Emp_Id FROM
	--					T0080_EMP_MASTER WHERE Date_Of_Join <= @From_Date ) 
	--			END
	--	END
		
  CREATE table #Emp_Cons 
  (      
   Emp_ID numeric ,     
   Branch_ID numeric,
   Increment_ID numeric    
  )  
  
  EXEC dbo.SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0,@Cat_ID=0, @Grd_ID=0, @Type_ID=0, @Dept_ID=0, @Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint 
        
        	

		---employee details
		SELECT E.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,CONVERT(VARCHAR(12),EA.resignation_date,103)resignation_date,CONVERT(VARCHAR(12),isnull(El.Left_Date,EA.last_date),103)last_date,EA.reason,RM.Reason_Name,
				CASE WHEN EA.is_rehirable = 0 THEN 'No' ELSE 'Yes' END is_rehirable,
			    C.Cmp_Name,C.Cmp_Address,C.cmp_logo,IG.Dept_Name,IG.Branch_Name,IG.Desig_Name,CONVERT(VARCHAR(12),EM.Date_Of_Join,103)Date_Of_Join,isnull(CONVERT(VARCHAR(12),EA.interview_date,103),'')interview_date,isnull(Left_Date,EA.last_date)Left_Date
			    ,IQ.Joining_CTC, Q.Last_CTC,R.Ret_EmpName,
			    dbo.F_GET_AGE(EM.Date_Of_Join,isnull(EM.Emp_Left_Date,EA.last_date),'Y','N') As Total_Year,
				CASE WHEN em.Street_1 <> '' THEN (EM.Street_1 + ', ' + EM.City + ', ' + EM.State + ', ' + EM.Zip_code) ELSE '' END AS Emp_Address,
				EM.Mobile_No,Em.Other_Email,em.Home_Tel_no,IQ.Desig_Name as Join_Desig_Name
		FROM  #Emp_Cons E 
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.Emp_ID
		LEFT JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id = E.Emp_ID
		INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = EM.Cmp_ID 
		INNER JOIN V0080_EMP_MASTER_INCREMENT_GET IG ON IG.Emp_ID = E.Emp_ID
		INNER JOIN T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_id = EA.Reason  --Added by Jaina 25-06-2020
		LEFT JOIN T0100_LEFT_EMP El WITH (NOLOCK) on el.Emp_ID = E.Emp_ID
		left JOIN    --Added by Jaina 25-04-2018 Start
		(	SELECT Distinct I.CTC As Joining_CTC,E.Emp_ID,D.Desig_Name--e1.Alpha_Emp_Code + ' - ' + e1.Emp_Full_Name As Ret_EmpName
			FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
				T0080_EMP_MASTER E WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID AND I.Increment_Effective_Date = E.Date_Of_Join INNER JOIN
				#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
				T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.Desig_ID = I.Desig_Id
			where I.Cmp_ID=@Cmp_Id 
		) IQ ON IQ.Emp_ID = E.Emp_ID
		left JOIN 
		(
			SELECT I.CTC as Last_CTC,Ec.Emp_ID
			FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
			#Emp_Cons Ec ON I.Emp_ID = Ec.Emp_ID AND I.Increment_ID = Ec.Increment_ID 
			
		) Q ON Q.Emp_ID = E.Emp_ID
		left JOIN
		(
			select top 1 R.Emp_ID ,R.Effect_Date,E1.Alpha_Emp_Code + ' - ' + E1.Emp_Full_Name As Ret_EmpName
			FROM T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) LEFT JOIN 
				 T0080_EMP_MASTER E1 WITH (NOLOCK) on e1.Emp_ID = R.R_Emp_ID INNER JOIN
				 #Emp_Cons EC1 ON EC1.Emp_ID = R.Emp_ID			
			ORDER BY R.Effect_Date desc
		) R ON R.Emp_ID = E.Emp_ID
		--inner JOIN T0080_EMP_MASTER E1 ON e1.Emp_Superior = Em.Emp_Superior
		
		--left JOIN
		--(	
		--	SELECT E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name  As Ret_EmpName,EA.emp_id
		--	FROM T0080_EMP_MASTER E INNER JOIN 
		--		 T0200_Emp_ExitApplication EA on E.Emp_ID = EA.emp_id
		--) R ON R.emp_id = E.Emp_ID   --Added by Jaina 25-04-2018 End
		WHERE EM.Cmp_ID = @CMP_ID AND E.Emp_ID IS NOT NULL
			
		---employee feedback details	
		SELECT E.Emp_ID,EF.question_id,EQ.Question,EF.exit_feedback_id,ER.Description,EF.Answer_rate,EF.Comments,ER.Title,ER.Rating_Id
		FROM   #Emp_Cons E
		INNER JOIN T0200_Exit_Feedback EF WITH (NOLOCK) ON E.Emp_ID = EF.emp_id
		INNER JOIN T0200_Question_Exit_Analysis_Master EQ WITH (NOLOCK) ON EQ.Quest_ID = EF.question_id
		LEFT OUTER JOIN T0040_Exit_Analysis_rating ER WITH (NOLOCK) ON ER.Rating_Id = ef.Answer_rate
		WHERE EF.cmp_id = @CMP_ID AND E.Emp_ID IS NOT NULL
		
		--Asset Details	
		SELECT E.Emp_ID,Asset_Name,Brand_Name,Vendor,Type_Of_Asset,Model_Name,Serial_No,Asset_Code,E.Emp_ID,Cmp_ID,CONVERT(VARCHAR(12),Return_Date,103)Return_Date,Type,CONVERT(VARCHAR(12),Allocation_Date,103)Allocation_Date
		FROM #Emp_Cons E 
		LEFT JOIN V0040_Asset_Allocation A on A.Emp_ID = E.Emp_ID
		WHERE A.cmp_id = @CMP_ID AND E.Emp_ID IS NOT NULL
		
		--Loan Details
		SELECT E.Emp_ID,Loan_Name,CONVERT(VARCHAR(12),Loan_Apr_Date,103)Loan_Apr_Date,Loan_Apr_Amount,Loan_Apr_Pending_Amount,Loan_Apr_Status
		FROM #Emp_Cons E
		LEFT JOIN V0120_LOAN_APPROVAL VL ON VL.Emp_Id = E.Emp_ID
		WHERE VL.Cmp_ID = @CMP_ID AND E.Emp_ID IS NOT NULL	
	
	DECLARE @i  INTEGER
	DECLARE @t_empId  NUMERIC(18,0)
	DECLARE @resigDate  DATETIME
	DECLARE @todayDate DATETIME = getdate()
	DECLARE @Guarantor_Emp_ID NUMERIC(18,0)
	
	
	--leave table
	CREATE table #Leave_Detail
	(
		Leave_Opening numeric(18,2),
		Leave_Used numeric(18,2),
		Leave_Closing numeric(18,2),
		Leave_Code varchar(10),
		Leave_Name varchar(250),
		Leave_ID numeric(18,0),
		Leave_Type varchar(10)
	)
	CREATE table #Leave_Bal
	(
		Emp_Id	numeric(18,0),
		Leave_Opening numeric(18,2),
		Leave_Used numeric(18,2),
		Leave_Closing numeric(18,2),
		Leave_Code varchar(10),
		Leave_Name varchar(250),
		Leave_ID numeric(18,0),
		Leave_Type varchar(10)
	)
	
	---Advance Table
	CREATE TABLE #Advance_Detail
	(
	   Adv_ID				NUMERIC(18,0)
      ,Cmp_ID				NUMERIC(18,0)
      ,For_Date				DATETIME
      ,Adv_Amount			NUMERIC(18,2)
      ,Adv_P_Days			NUMERIC(18,2)
      ,Adv_Approx_Salary	NUMERIC(18,2)
      ,Adv_Comments			VARCHAR(1000)
      ,Emp_Full_Name		VARCHAR(100)
      ,Emp_First_Name		VARCHAR(50)
      ,Emp_ID				NUMERIC(18,0)
      ,Emp_code				VARCHAR(50)
      ,Alpha_Emp_Code		VARCHAR(50)
      ,Vertical_ID			NUMERIC(18,0)
      ,SubVertical_ID		NUMERIC(18,0)
      ,Dept_ID				NUMERIC(18,0)
      ,Branch_ID			NUMERIC(18,0)
      ,Reason_Name			VARCHAR(1000)
      ,Res_Id				NUMERIC(18,0)
      ,Adv_Approval_ID		NUMERIC(18,0)
	)
	
	---Guarantor Table
	CREATE TABLE #GuarantorDetail
	(
		G_Emp_Full_Name		VARCHAR(150)
		,Emp_Id					NUMERIC(18,0)
	)
	
	---Exit rating Table
	CREATE TABLE #ExitRatingScale
	(
		  Quest_ID			NUMERIC(18,0)
		 ,Question			VARCHAR(500)
		 ,Question_Type		INT
		 ,Title				VARCHAR(100)
		 ,Rating_Id			NUMERIC(18,0)
		 ,Emp_Id			NUMERIC(18,0)
	)
	
	SET @i = 1;
	WHILE @i <= (SELECT count(1) FROM #Emp_Cons WHERE Emp_ID IS NOT NULL)
		BEGIN
			SELECT @t_empId= k.Emp_ID
			FROM (SELECT Emp_ID,ROW_NUMBER() OVER(ORDER BY Emp_ID) as r_num
				  FROM #Emp_Cons WHERE Emp_ID IS NOT NULL)k	
			WHERE k.r_num = @i AND k.Emp_ID is NOT NULL
			
			
			----Leave Details			
			EXEC  SP_LEAVE_CLOSING_AS_ON_DATE	@CMP_ID=@CMP_ID,@EMP_ID=@t_empId,@Return_Table=1
			
						
			INSERT INTO #Leave_Bal
			SELECT DISTINCT @t_empId as Emp_ID,* FROM #Leave_Detail
						
			----Advance Details
			SELECT @resigDate = resignation_date FROM T0200_Emp_ExitApplication WITH (NOLOCK) WHERE emp_id = @t_empId	  		
			
			INSERT INTO #Advance_Detail
			EXEC P0200_AdvanceDetail_Exit @CMP_ID,@resigDate,@t_empId
			
			---Guaranteed Employee Pending Amount Details
			DECLARE @Check_Guarantor TABLE
			(
				error_log			NUMERIC,
				Guarantor_Emp_ID	NUMERIC				
			)
			
			INSERT INTO @Check_Guarantor		 
			EXEC SP_RPT_LOAN_STATEMENT_REPORT_GUARANTOR @CMP_ID,@todayDate,@t_empId,0,0,1
			
			SELECT @Guarantor_Emp_ID = Guarantor_Emp_ID FROM @Check_Guarantor
		
				
			INSERT INTO #GuarantorDetail
			SELECT Alpha_Emp_Code + ' - ' + Emp_Full_Name As Emp_Full_Name,@t_empId as Emp_Id 
			FROM V0080_EMPloyee_MASTER
			WHERE Emp_Id = @Guarantor_Emp_ID
			
			INSERT INTO #ExitRatingScale
			SELECT EA.Quest_ID,EA.Question,EA.Question_Type,er.Title,Er.Rating_Id,@t_empId 
			FROM T0200_Exit_Feedback F WITH (NOLOCK)
			INNER JOIN T0200_Question_Exit_Analysis_Master EA WITH (NOLOCK) ON ea.Quest_ID = f.question_id
			INNER JOIN (
							SELECT data,t.Quest_ID
							FROM T0200_Question_Exit_Analysis_Master t WITH (NOLOCK)
							CROSS APPLY dbo.Split(Question_Options,'#')
							WHERE t.Question_Options<>'' and t.Question_Type <>2
			)EA1 on EA.Quest_ID = EA1.Quest_ID
			INNER JOIN T0040_Exit_Analysis_rating Er WITH (NOLOCK) on Er.Rating_Id = EA1.Data
			WHERE EA.Question_Type <> 2 AND F.emp_id = @t_empId

			DELETE FROM #Leave_Detail
			DELETE @Check_Guarantor
			SET @resigDate = null;
			SET @t_empId = null;
			SET @i = @i + 1;
		END	
			
		
		SELECT * FROM #Leave_Bal
		
		SELECT * FROM #Advance_Detail
		SELECT * FROM #GuarantorDetail	
		SELECT * FROM #ExitRatingScale	
		
		DROP TABLE #Leave_Bal
		DROP TABLE #Advance_Detail
		DROP TABLE #GuarantorDetail	
		DROP TABLE #ExitRatingScale
END

