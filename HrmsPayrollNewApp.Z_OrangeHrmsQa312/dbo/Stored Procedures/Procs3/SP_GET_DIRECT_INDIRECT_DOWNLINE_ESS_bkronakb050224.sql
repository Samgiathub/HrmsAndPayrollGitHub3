


CREATE PROCEDURE [dbo].[SP_GET_DIRECT_INDIRECT_DOWNLINE_ESS_bkronakb050224]
	@Cmp_ID numeric(18,0),  
	@Emp_ID numeric(18,0),
	@Emp_Search int=0,     --added jimit 03082015
	@From_Date  datetime = NULL, --Mukti(06042017)       
	@To_Date  datetime = NULL, --Mukti(06042017)
	@ExecuteFor Varchar(32) = '',
	@Flagatt int = 0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	if @From_Date IS NULL
		set @From_Date=GETDATE()
	if @To_Date IS NULL
		set @To_Date=GETDATE()	
		
	IF @ExecuteFor NOT IN ('DIRECT' , 'INDIRECT', 'BOTH')
		SET @ExecuteFor = ''
	-----Direct Downline----
	/*Commented by Nimesh 2015-05-11
	SELECT	DISTINCT emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code 
	FROM	V0080_Employee_Master 
	WHERE	emp_id in (select emp_id 
						from t0080_emp_master 
						where emp_superior=@Emp_ID and Cmp_ID=@Cmp_ID 
							and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120))))
	union 
	select distinct emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code from V0080_Employee_Master 
	where emp_id in (select ERD.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD INNER JOIN	--Ankit 28012015
								(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1
									where ERD1.Effect_Date <= getdate() AND Emp_ID IN (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WHERE R_Emp_ID = @Emp_ID)
								GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
		where R_Emp_ID = @Emp_ID and Reporting_Method = 'Direct') 
		 and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))		
	*/

	--Added by Nimesh 2015-05-11
	Select E.R_Emp_ID,T.emp_id,I.Increment_ID,I.Branch_ID,E.Reporting_Method,I.Sales_Code,T.Date_Of_Join,I.CTC--Added Date_Of_Join field by Mukti(19122017)
	INTO #Emp_Cons
	FROM T0080_EMP_MASTER  T WITH (NOLOCK)
			INNER JOIN (
						SELECT	Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method,MAX(Effect_Date) As Effect_Date 
						FROM	T0090_EMP_REPORTING_DETAIL E WITH (NOLOCK)
						WHERE	Effect_Date<=GetDate() 
						GROUP	BY Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method
						) E ON E.Emp_ID=T.Emp_ID And E.Cmp_ID=T.Cmp_ID 
			INNER JOIN (
						SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID , I.Sales_Code,I.CTC
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.Increment_ID = (
													SELECT	TOP 1 I1.Increment_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
													ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
													)
						) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
	Where E.Effect_Date=(Select MAX(Effect_Date) FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK)
						WHERE ED.Emp_ID=E.Emp_ID And Effect_Date<=GetDate())
	and (Emp_Left = 'N' or
	--or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))
	(Emp_Left = 'Y' and Emp_Left_Date >= @To_Date)) --Mukti(06042017)	
	AND E.R_Emp_ID=@Emp_ID
	AND (E.Cmp_ID=@Cmp_ID OR E.Reporting_Method='InDirect') --commented by Mukti(19122017)
	--select * from #Emp_Cons

	--Added by ronakk for redmine Bug #9115
	insert into  #Emp_Cons
		Select @Emp_ID,T.emp_id,I.Increment_ID,I.Branch_ID,'Direct',I.Sales_Code,T.Date_Of_Join,I.CTC
		FROM T0080_EMP_MASTER  T WITH (NOLOCK)

			INNER JOIN (
						SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID , I.Sales_Code,I.CTC
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.Increment_ID = (
													SELECT	TOP 1 I1.Increment_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
													ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
													)
						) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
	and (Emp_Left = 'N' or
	(Emp_Left = 'Y' and Emp_Left_Date >= @To_Date))
	AND T.Emp_ID=@Emp_ID
	--End by ronakk for redmine Bug #9115


		
	Select	E.R_Emp_ID,T.emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code,E.Reporting_Method,
			E.branch_id,T.Dept_ID,BM.branch_name,DEPT.dept_name,
	case @Emp_Search                --added jimit 03082015
			when 0
				then cast( T.Alpha_Emp_Code as varchar) + ' - '+ T.Emp_Full_Name
			when 1
				then  cast( T.Alpha_Emp_Code as varchar) + ' - '+ T.Emp_First_Name+SPACE(1)+T.Emp_Second_Name+SPACE(2)+T.Emp_Last_Name
			when 2
				then  cast( T.Alpha_Emp_Code as varchar)
			when 3
				then  T.Initial+SPACE(1)+ T.Emp_First_Name+SPACE(1)+T.Emp_Second_Name+SPACE(2)+T.Emp_Last_Name
			when 4
				then  T.Emp_First_Name+SPACE(1)+T.Emp_Second_Name+SPACE(2)+T.Emp_Last_Name + ' - ' + cast( T.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name1 
			,Dm.Desig_Name , E.Sales_Code,T.Date_Of_Join,T.Cmp_ID,co.Cmp_Name,I.CTC  --added jimit 03022016
			,I.Desig_Id  --Added by Jaina 15-03-2019
	INTO #TMP
	FROM T0080_EMP_MASTER T WITH (NOLOCK) INNER JOIN #EMP_CONS E ON T.Emp_ID=E.EMP_ID --	AND T.Increment_ID=E.Increment_ID
		INNER JOIN (
						SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID, I.Dept_ID,I.Desig_Id,I.CTC
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.Increment_ID = (
													SELECT	TOP 1 I1.Increment_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
													ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
													)
						) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.CMP_ID=BM.CMP_ID AND I.Branch_ID=BM.Branch_ID
		LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DEPT WITH (NOLOCK) ON I.Cmp_ID=DEPT.Cmp_Id AND I.Dept_ID=DEPT.Dept_Id
		LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Dm.Desig_ID = I.Desig_Id AND I.Cmp_ID = DM.Cmp_ID	
		INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=T.Cmp_ID		
		ORDER BY 
				Case @Emp_Search 
				When 3 Then
					t.Emp_First_Name
				When 4 Then
					t.Emp_First_Name
				Else
					Case When IsNumeric(t.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + t.Alpha_Emp_Code, 20)
			When IsNumeric(t.Alpha_Emp_Code) = 0 then Left(t.Alpha_Emp_Code + Replicate('',21), 20)
				Else t.Alpha_Emp_Code
			End
					--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)					
				End
	
	--select * from #TMP
	if @Flagatt <> 1
	begin 
	IF @ExecuteFor  IN ('', 'BOTH', 'DIRECT')
		SELECT 111,R_Emp_ID,Emp_id,Emp_Full_Name,Alpha_Emp_Code,Emp_Name_Code,Branch_ID,Dept_ID,branch_name,dept_name,Emp_Full_Name1
				,Desig_Id ,Desig_Name	, Sales_Code,Date_Of_Join,CMP.cmp_id,
				--case when cmp_id=@cmp_id then '' else cmp_name end as cmp_name,
				Cmp.Cmp_Name,
				CTC		--added jimit 03022016
			FROM #TMP TMP
		INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) on CMP.Cmp_Id=TMP.Cmp_ID
		WHERE Reporting_Method = 'Direct' 
	
	--select distinct emp_id,emp_full_name,Alpha_Emp_Code from V0080_Employee_Master where emp_id in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @Emp_ID and Reporting_Method = 'Direct') and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))	
	
	IF @ExecuteFor  IN ('')
		select E.emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code,T.branch_id,Dept_ID,branch_name,dept_name
		,case @Emp_Search   --added jimit 03082015
				when 0
					then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
				when 1
					then  cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
				when 2
					then  cast( Alpha_Emp_Code as varchar)
				when 3
					then  Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
				when 4
					then  Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast( Alpha_Emp_Code as varchar)	
				end as Emp_Full_Name1,E.Date_Of_Join,E.Cmp_ID,co.Cmp_Name,T.CTC
		 from V0080_Employee_Master E 
		 inner JOIN #Emp_Cons T ON E.Emp_ID=T.Emp_ID 
		 INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=E.Cmp_ID		
		 where e.Cmp_ID = 0 and E.Emp_ID = 0 -- temp only for getting table at form level - mitesh on 21/02/2012
		 ORDER BY 
				  Case @Emp_Search 
					When 3 Then
						Emp_First_Name
					When 4 Then
						Emp_First_Name
					Else
						Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
				When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
					Else Alpha_Emp_Code
				End
						--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
					End
	ELSE IF @ExecuteFor  IN ('BOTH', 'INDIRECT')
	--SELECT * FROM #Emp_Cons RETURN
		select 4444
		select  E.emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code,T.branch_id,Dept_ID,branch_name,dept_name
				,case @Emp_Search   --added jimit 03082015
				when 0
					then cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name
				when 1
					then  cast( Alpha_Emp_Code as varchar) + ' - '+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
				when 2
					then  cast( Alpha_Emp_Code as varchar)
				when 3
					then  Initial+SPACE(1)+ Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name
				when 4
					then  Emp_First_Name+SPACE(1)+Emp_Second_Name+SPACE(2)+Emp_Last_Name + ' - ' + cast( Alpha_Emp_Code as varchar)	
				end as Emp_Full_Name1,E.Desig_Id,E.Desig_Name,E.Sales_Code, E.Date_Of_Join,E.Cmp_ID,co.Cmp_Name,T.CTC, 0 As R_Emp_ID
		 from V0080_Employee_Master E 
		 inner JOIN #Emp_Cons T ON E.Emp_ID=T.Emp_ID 
		 INNER JOIN T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=E.Cmp_ID		
		 where e.Cmp_ID = 0 and E.Emp_ID = 0 -- temp only for getting table at form level - mitesh on 21/02/2012		 
		UNION  ALL
		SELECT  Emp_id,Emp_Full_Name,Alpha_Emp_Code,Emp_Name_Code,branch_id,Dept_ID,branch_name,dept_name,Emp_Full_Name1 
				,Desig_Id ,Desig_Name , Sales_Code,Date_Of_Join,TMP.cmp_id,
				--case when cmp_id=@cmp_id then '' else cmp_name end as cmp_name,
				Cmp.Cmp_Name,
				CTC--,t.cnt--added jimit 03022016	
				,R_Emp_ID
		FROM #TMP TMP
		INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) on CMP.Cmp_Id=TMP.Cmp_ID		
		WHERE Reporting_Method = 'InDirect'
		ORDER BY Emp_Full_Name1
				 
	/*Commented by Nimesh 2015-05-11
	select emp_id,emp_full_name,Alpha_Emp_Code,cast(Alpha_Emp_Code as varchar) + ' - '+ Emp_Full_Name as Emp_Name_Code from V0080_Employee_Master where emp_id in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @Emp_ID and Reporting_Method = 'InDirect') and (Emp_Left = 'N' or (Emp_Left = 'Y' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))
	*/	
	IF @ExecuteFor  IN ('')		
		SELECT R_Emp_ID,Emp_id,Emp_Full_Name,Alpha_Emp_Code,Emp_Name_Code,branch_id,Dept_ID,branch_name,dept_name,Emp_Full_Name1 
				,Desig_Id ,Desig_Name , Sales_Code,Date_Of_Join,CMP.cmp_id,
				--case when cmp_id=@cmp_id then '' else cmp_name end as cmp_name,
				Cmp.Cmp_Name,
				CTC--,t.cnt--added jimit 03022016	
		FROM #TMP TMP
		INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) on CMP.Cmp_Id=TMP.Cmp_ID
		WHERE Reporting_Method = 'InDirect'
	END
	else
	begin 
		SELECT 111,R_Emp_ID,Emp_id,Emp_Full_Name,Alpha_Emp_Code,Emp_Name_Code,Branch_ID,Dept_ID,branch_name,dept_name,Emp_Full_Name1
				,Desig_Id ,Desig_Name	, Sales_Code,Date_Of_Join,CMP.cmp_id,
				--case when cmp_id=@cmp_id then '' else cmp_name end as cmp_name,
				Cmp.Cmp_Name,
				CTC		--added jimit 03022016
			FROM #TMP TMP
		INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) on CMP.Cmp_Id=TMP.Cmp_ID
		WHERE Reporting_Method in ('Direct','InDirect') 
	end
END




