

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Emp_Export_Master_CTC]  
	@Company_id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		varchar(max)	
	,@Grade_ID 		varchar(max)
	,@Type_ID 		varchar(max)
	,@Dept_ID 		varchar(max)
	,@Desig_ID 		varchar(max)
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@Cat_ID        varchar(max)
	,@Order_By   varchar(30) = 'Code' --Added by Jimit 28/09/2015 (To sort by Code/Name/Enroll No)
	,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 24-12-2016
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	  
	 DECLARE @Year_End_Date AS DATETIME  
	 DECLARE @User_type VARCHAR(30)  
	 
	 -- Added by rohit ON 27102015 for Cera.
	 Declare @Month_Days_for_Daily Numeric(18,2)  
	 SET @Month_Days_for_Daily = 26
   
	SET @Show_Hidden_Allowance = 0
   
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)		
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0

	CREATE table #CTCMast
	(
		
	    Cmp_ID			numeric(18,0)
	   ,Emp_ID			numeric(18,0) 
	   ,Branch_id       numeric(18,0)
	   ,Alpha_Emp_Code	Varchar(30)
	   ,Emp_Full_Name	varchar(250)
	   ,Father_Name	    varchar(250)
	   ,Employee_Address Varchar(Max)
	   ,Branch			nvarchar(100)
	   ,Deptartment		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,DOB				nvarchar(20)
	   ,DOJ				nvarchar(20)
	   ,Type_Name		nvarchar(100)
	   --,Prev_Experience Numeric(18,2)
	   ,Curr_Experience Numeric(18,2)
	   ,Qualification	nvarchar(Max)
	   ,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 28/09/2015
	   ,Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 28/09/2015
	   ,Business_segment nvarchar(100) DEFAULT ''
	   ,Vertical_Name	 nvarchar(100) DEFAULT ''
	   ,SubVertical_Name	nvarchar(100) DEFAULT ''
	   ,Category			nvarchar(100) DEFAULT ''
	  ,SubBranch_Name	nvarchar(100) DEFAULT ''
	  ,Emp_PF_No		nvarchar(100) DEFAULT ''
	  ,PF_Trust_No		nvarchar(100) DEFAULT ''
	  ,UAN_No			nvarchar(100) DEFAULT ''
	  ,ESIC_No			nvarchar(100) DEFAULT ''
	  ,Aadhar_Card_No	nvarchar(100) DEFAULT ''
	  ,PAN_No	nvarchar(100) DEFAULT ''
	   ,Bank_Name		nvarchar(100) DEFAULT ''
	   ,Bank_Account		nvarchar(100) DEFAULT ''
	   ,AGE				nvarchar(100) DEFAULT ''
	   ,Cost_Center_Name nvarchar(100) DEFAULT ''
	   ,Basic_Salary	numeric(18,2)
	)
	
	----------------------------------------------
		
	Declare @Columns nvarchar(2000)
	SET @Columns = '#'
	
	-- Changed By Ali 22112013 EmpName_Alias
	--insert into #CTCMast 		
	--SELECT e.Cmp_ID,e.Emp_ID, BM.Branch_ID ,e.Alpha_Emp_Code,
	--IsNull(e.EmpName_Alias_Salary,e.Emp_Full_Name),e.Father_Name, Street_1 + ' ' + IsNull(City,'') + ' ' + IsNull(State,'')
	----e.Emp_Full_Name
	--,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,convert(nvarchar,e.Date_Of_Birth,103) as Date_Of_Birth,convert(nvarchar,e.Date_Of_Join,103) as Date_Of_Join,
	--	tm.Type_Name,
	--	--Prev_Exp,
	--	dbo.[F_GET_AGE] (Date_Of_Join,GETDATE(),'Y','N'),		
	--	Qual_Name,0  --IsNull(Inc_Qry.Basic_Salary,0)
	--	,Dnm.Desig_Dis_No,E.Enroll_No     --added jimit 28/09/2015
	--FROM T0080_EMP_MASTER e	inner join
	--	--( SELECT I.Emp_id,I.Basic_Salary,Branch_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID FROM T0095_Increment I INNER JOIN 
	--	--	( SELECT max(Increment_Id) as Increment_Id , Emp_ID FROM T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
	--	--	WHERE Increment_Effective_date <= @To_Date
	--	--	and cmp_id = @Company_id
	--	--	group by emp_ID  ) Qry on
	--	--	I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry ON 
	--	--E.Emp_ID = Inc_Qry.Emp_ID
		
	--	--added jimit 28/9/2015-------------
	--	(SELECT	I.Emp_id
	--	,I.Basic_Salary,Branch_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID,I.Cmp_ID
	--					FROM	T0095_INCREMENT I
	--					WHERE	I.INCREMENT_ID = (
	--												SELECT	TOP 1 INCREMENT_ID
	--												FROM	T0095_INCREMENT I1
	--												WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID And i1.Increment_Effective_Date <= @To_Date
	--												ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
	--											)
	--				  ) AS B ON B.EMP_ID = E.EMP_ID AND B.CMP_ID=E.CMP_ID  
	--	--ended
	--INNER JOIN #Emp_Cons ec ON e.Emp_ID = ec.Emp_ID
	--left outer join T0030_BRANCH_MASTER bm ON B.Branch_ID = bm.Branch_ID
	--left outer join T0040_GRADE_MASTER ga ON B.Grd_ID = ga.Grd_ID
	--left outer join T0040_DEPARTMENT_MASTER dm ON B.Dept_ID = dm.Dept_Id
	--left outer join T0040_DESIGNATION_MASTER dnm ON B.Desig_Id = dnm.Desig_ID
	--left outer join T0040_TYPE_MASTER tm ON B.Type_ID = tm.Type_ID 
	--Left Outer Join (SELECT DISTINCT Emp_ID,
	--						         STUFF(
	--				   (SELECT      ', ' + qm.Qual_Name
	--				   FROM      T0090_EMP_QUALIFICATION_DETAIL AS SubTableUser
	--					INNER JOIN T0040_QUALIFICATION_MASTER QM ON SubTableUser.Qual_ID = Qm.Qual_ID
	--				   WHERE      SubTableUser.Emp_ID = T0090_EMP_QUALIFICATION_DETAIL.emp_Id
	--				   FOR XML PATH('')), 1, 1, '') AS Qual_Name
	--	FROM      T0090_EMP_QUALIFICATION_DETAIL WHERE Cmp_ID = @Company_id) Qualification ON Ec.Emp_ID = Qualification.Emp_ID 	
	--Left Outer Join (SELECT  Emp_ID,dbo.[F_GET_AGE] (St_Date,End_Date,'Y','N') as Prev_Exp FROM T0090_EMP_EXPERIENCE_DETAIL) as Experience  ON Experience.Emp_ID = E.Emp_ID
	
	--New Query with #emp_Cons Added By Ramiz ON 02/02/2018
	/*
	UPDATE #CTCMast 
	SET BASIC_SALARY = CASE WHEN i.Wages_Type ='Daily' THEN (i.Basic_Salary * @Month_Days_for_Daily) ELSE i.Basic_Salary END
	FROM #CTCMast C 
	INNER JOIN T0095_INCREMENT I ON C.EMP_ID = I.EMP_ID 
	INNER JOIN #EMP_CONS EC ON EC.EMP_ID = I.EMP_ID AND EC.INCREMENT_ID = I.INCREMENT_ID	
	*/
	
	----New Query with #emp_Cons Added By Ramiz ON 11/06/2019
	--UPDATE #CTCMast 
	--SET BASIC_SALARY = CASE WHEN I.Wages_Type ='Daily' THEN (I.Basic_Salary * @Month_Days_for_Daily) ELSE I.Basic_Salary END
	--FROM #CTCMast C
	--	INNER JOIN T0095_INCREMENT I ON I.EMP_ID = C.EMP_ID 
	--	INNER JOIN (SELECT	MAX(I1.INCREMENT_ID) AS INCREMENT_ID, I1.Emp_ID
	--				FROM	T0095_INCREMENT I1
	--						INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
	--						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
	--									FROM	T0095_INCREMENT I3
	--									INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
	--									WHERE	I3.INCREMENT_EFFECTIVE_DATE <= @To_Date AND I3.CMP_ID=@Company_id AND I3.Increment_Type <> 'Transfer' AND I3.Increment_Type <> 'Deputation'
	--									GROUP BY I3.EMP_ID
	--									) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
	--				WHERE	I1.Increment_Effective_Date <= @To_Date AND I1.CMP_ID=@Company_id AND I1.Increment_Type <> 'Transfer' AND I1.Increment_Type <> 'Deputation'
	--				GROUP BY I1.Emp_ID
	--				) I2 ON I.INCREMENT_ID=I2.INCREMENT_ID
	----------------------------------------------------------------


	
	insert into #CTCMast 		
	SELECT	e.Cmp_ID,e.Emp_ID, BM.Branch_ID ,e.Alpha_Emp_Code,
			ISNULL(e.EmpName_Alias_Salary,e.Emp_Full_Name),e.Father_Name, Street_1 + ' ' + ISNULL(City,'') + ' ' + ISNULL(State,''),	--e.Emp_Full_Name
			bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,convert(nvarchar,e.Date_Of_Birth,103) as Date_Of_Birth,
			convert(nvarchar,e.Date_Of_Join,103) as Date_Of_Join,tm.Type_Name,--Prev_Exp,
			dbo.[F_GET_AGE] (Date_Of_Join,GETDATE(),'Y','N'),Qual_Name
			,Dnm.Desig_Dis_No
			,E.Enroll_No     --added jimit 28/09/2015
			,BS.Segment_Name as Business_segment
			,VS.Vertical_Name		
			,SV.SubVertical_Name							
			,CM.Cat_Name 
			,SB.SubBranch_Name
			,E.SSN_No AS PF_NO
			,e.PF_Trust_No 
			,'="' +e.UAN_No + '"'
			,e.SIN_No AS ESIC_No
			,'="' +E.Aadhar_Card_No  + '"'
			,'="' +E.PAN_No  + '"'
			,BN.Bank_Name As Primary_Bank_Name
			,( '="' + I_2.Inc_Bank_Ac_No + '"') as Primary_Bank_Account_No
			,(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age
			,ISNULL(ccm.Center_Name,'') AS Cost_Center_Name
			,CASE WHEN I_2.Wages_Type ='Daily' THEN (I_2.Basic_Salary * @Month_Days_for_Daily) ELSE I_2.Basic_Salary END
			
	from	T0080_EMP_MASTER e	WITH (NOLOCK)
			inner join #Emp_Cons ec on e.Emp_ID = ec.Emp_ID
			inner join t0095_Increment I_1 WITH (NOLOCK) On I_1.Increment_Id = Ec.Increment_Id and I_1.Emp_Id = ec.Emp_Id
			Inner Join (SELECT  MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM    dbo.t0095_Increment AS I2 WITH (NOLOCK)
								INNER JOIN  (
												SELECT	MAX(I3.Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, I3.Emp_ID
												FROM    dbo.t0095_Increment AS I3 WITH (NOLOCK) INNER JOIN
														#Emp_Cons AS EM ON EM.Emp_ID = I3.Emp_ID
												WHERE   I3.Increment_Effective_Date <= @To_date AND (I3.Increment_Type NOT IN ('Transfer','Deputation'))
												GROUP BY I3.Emp_ID
											) AS I3_1 ON I2.Increment_Effective_Date = I3_1.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID = I3_1.Emp_ID
						GROUP BY I2.Emp_ID) AS I2_Q ON I2_Q.EMP_Id = Ec.Emp_Id
			Inner Join  t0095_Increment I_2 WITH (NOLOCK) On I_2.Increment_Id = I2_Q.Increment_Id and I_2.Emp_Id = I2_Q.Emp_Id
			left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on I_1.Branch_ID = bm.Branch_ID
			left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on I_1.Grd_ID = ga.Grd_ID
			left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on I_1.Dept_ID = dm.Dept_Id
			left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on I_1.Desig_Id = dnm.Desig_ID
			left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on I_1.Type_ID = tm.Type_ID 
			Left Outer Join (SELECT DISTINCT Emp_ID,
									STUFF((SELECT   ', ' + qm.Qual_Name
											FROM	T0090_EMP_QUALIFICATION_DETAIL AS SubTableUser WITH (NOLOCK)
													Inner Join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on SubTableUser.Qual_ID = Qm.Qual_ID
											WHERE   SubTableUser.Emp_ID = T0090_EMP_QUALIFICATION_DETAIL.emp_Id
											FOR XML PATH('')), 1, 1, '') AS Qual_Name
							  FROM  T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK)
							  where Cmp_ID = @Company_id
							 ) Qualification on Ec.Emp_ID = Qualification.Emp_ID 	
	
			LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) On BS.Segment_ID = I_2.Segment_ID			
			LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On VS.Vertical_ID = I_2.Vertical_ID		
			LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) On SV.SubVertical_ID =  I_2.SubVertical_ID		
			LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) On SB.SubBranch_ID = I_2.SubBranch_ID			
			LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I_2.Cat_id = CM.Cat_Id
			LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON I_2.Bank_id = BN.Bank_Id 
			LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_2.Center_ID
	  
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)

	
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	Declare @Increment_ID numeric(18,0)
	SET @Increment_ID = 0
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE Cmp_id = @Company_id and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 0 and AD_FLAG = 'I' order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next FROM Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				BEGIN
					
					
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					SET @val = 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0'
					
					exec (@val)	
					SET @val = ''
					
					SET @Columns = @Columns +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
				fetch next FROM Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
	----------------------------------------------------------------
				
	Alter table   #CTCMast Add Gross_Salary numeric(18,2) default 0
	SET @Columns = @Columns +  'Gross_Salary#'
	
	----------------------------------------------------------------
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE Cmp_id = @Company_id and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1 and AD_FLAG = 'I' 
		AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 24-12-2016
		order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next FROM Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				BEGIN
					
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					SET @val = 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0'
					
					exec (@val)	
					SET @val = ''
					
					SET @Columns = @Columns +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
				fetch next FROM Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
	----------------------------------------------------------------
	
	Alter table   #CTCMast Add CTC numeric(18,2) default 0
	SET @Columns = @Columns +  'CTC#'
	
	----------------------------------------------------------------
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE Cmp_id = @Company_id and AD_NOT_EFFECT_SALARY = 0 and AD_FLAG = 'D' order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next FROM Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				BEGIN
					
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					SET @val = 'Alter table   #CTCMast Add [' + REPLACE(@AD_NAME_DYN,' ','_') + '] numeric(18,2) default 0'
					
					exec (@val)	
					SET @val = ''
					
					SET @Columns = @Columns +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					
				fetch next FROM Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
	----------------------------------------------------------------
   --added by mansi 28-09-23
	if exists(SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'PT' AND TABLE_NAME LIKE '#CTCMast%')
		begin
		  print 125
		end
		else
		begin 
		  Alter table   #CTCMast Add PT numeric(18,2) default 0
		end
	--ended by mansi 28-09-23
	--Alter table   #CTCMast Add PT numeric(18,2) default 0--commented by mansi 28-09-23
	Alter table   #CTCMast Add Total_Deduction numeric(18,2) default 0
	Alter table   #CTCMast Add Net_Take_Home numeric(18,2) default 0
	
	SET @Columns = @Columns +  'PT#'
	SET @Columns = @Columns +  'Total_Deduction#'
	SET @Columns = @Columns +  'Net_Take_Home#'
	
	----------------------------------------------------------------
	
	Declare @CTC_COLUMNS nvarchar(100)
	Declare @CTC_AD_FLAG varchar(1)
				
	--Declare CTC_UPDATE CURSOR FOR
	--	SELECT Cmp_Id,Emp_Id,Basic_Salary FROM #CTCMast
	--OPEN CTC_UPDATE
	--fetch next FROM CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
	--while @@fetch_status = 0
	--	BEGIN	
			
			
			
	--		
	--		Declare @CTC_GROSS numeric(18,2)
	--		Declare @Total_Ear numeric(18,2)
	--		Declare @Total_Ded numeric(18,2)
	--		
	--		Declare @CTC_PT numeric(18,2)
			
			
	--		SET @CTC_PT = 0
	--		SET @CTC_GROSS = 0
	--		SET @Total_Ear = 0
	--		SET @Total_Ded = 0
			
	--		Declare @Inc_ID  numeric
	--		Declare @Allow_Amount numeric(18,2)
			
	--		Declare @Inc_Wages_Type  varchar(50)  -- Added by rohit ON 27102015
	--		SET @Inc_Wages_Type =''
			
	--		SET @Inc_Id = 0			
			
	--		--SELECT @Inc_Id=MAX(INCREMENT_ID) FROM T0095_INCREMENT WHERE CMP_ID = @CTC_CMP_ID and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date and increment_type <> 'Transfer'
			
	--		--Changed By Jimit 30122017 Issue at Wonder Allowance Amount is not coming according to Latest Increment
	--		SELECT @Inc_Id = I1.INCREMENT_ID FROM T0095_INCREMENT I1 
	--						INNER JOIN (
	--									SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
	--									FROM	T0095_Increment I2 INNER JOIN T0080_EMP_MASTER E ON I2.Emp_ID=E.Emp_ID
	--											INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
	--														FROM T0095_INCREMENT I3 INNER JOIN T0080_EMP_MASTER E3 ON I3.Emp_ID=E3.Emp_ID	
	--														WHERE I3.Increment_effective_Date <= @To_Date AND I3.Cmp_ID = @CTC_CMP_ID
	--																	and I3.Emp_ID = @CTC_EMP_ID  and increment_type <> 'Transfer'
	--														GROUP BY I3.EMP_ID  
	--														) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
	--														      and I2.increment_type <> 'Transfer'																																			
	--									GROUP BY I2.Emp_ID
	--									) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID
	--		WHERE CMP_ID = @CTC_CMP_ID and I1.EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date 
	--		--Ended
			
			
	--		SELECT @Inc_Wages_Type = IsNull(wages_type,'')  FROM T0095_INCREMENT WHERE Increment_ID= @Inc_Id -- Added by rohit ON 27102015
	
	SELECT	T.*, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.Ad_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') AS Ad_Name
	INTO	#EmpAllowance
	FROM	dbo.fn_getEmpIncrementDetail(@Company_id, @Constraint,@To_Date) T
			INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
	
	
	Create Table #Emp_CTC
	(
		Emp_ID			NUMERIC,
		Increment_ID	NUMERIC,
		Inc_Wages_Type	Varchar(64),
		Total_Ear		NUMERIC(18,2),
		CTC_BASIC		NUMERIC(18,2),
		CTC_GROSS		NUMERIC(18,2),
		CTC_PT			NUMERIC(18,2),
		Emp_PT_Amount	NUMERIC(18,2),
		Month_Days_for_Daily NUMERIC(18,2),
		Allow_Amount	NUMERIC(18,2),
		Total_Ded		NUMERIC(18,2)
	)	
			
	DECLARE CRU_COLUMNS CURSOR FAST_FORWARD FOR
	SELECT data FROM Split(@Columns,'#') WHERE data <> ''
	
	INSERT INTO #Emp_CTC
	SELECT	EC.Emp_ID, EC.Increment_ID, I.Wages_Type, 0 As Total_Ear,
			CASE WHEN I.Wages_Type ='Daily' THEN (I.Basic_Salary * @Month_Days_for_Daily) ELSE I.Basic_Salary END, 0 As CTC_GROSS, 0 As CTC_PT, Emp_PT_Amount, 
			@Month_Days_for_Daily, 0 As Allow_Amount, 0 As Total_Ded
	FROM	#Emp_Cons EC 			
			INNER JOIN T0095_Increment I WITH (NOLOCK) ON EC.Emp_ID=I.Emp_ID
			INNER JOIN (SELECT	MAX(I1.Increment_ID) As Increment_ID, I1.Emp_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(I2.Increment_Effective_Date) As Increment_Effective_Date, I2.Emp_ID
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE	I2.Increment_Effective_Date <= @To_Date
													AND Increment_Type NOT IN ('Transfer', 'Deputation')
											GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
						GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
			
	
	OPEN CRU_COLUMNS
	FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			--IF @Inc_ID > 0
				BEGIN
					SET @CTC_COLUMNS = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																				
					IF @CTC_COLUMNS = 'Gross_Salary'
						BEGIN
							--SET @val = 	'UPDATE C 
							--			 SET	Gross_Salary = ' + convert(nvarchar,(IsNull(@Total_Ear,0) + IsNull(@CTC_BASIC,0))) + ' 
							--			 FROM	#CTCMast C INNER JOIN #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID
							--			 WHERE	C.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' 
							--					and C.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
							
							UPDATE	C 
							SET		Gross_Salary = IsNull(Total_Ear,0) + IsNull(CTC_BASIC,0)
							FROM	#CTCMast C INNER JOIN #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID
							--WHERE	C.Cmp_ID = @CTC_CMP_ID
							
							UPDATE	#Emp_CTC
							SET		CTC_GROSS = Total_Ear + CTC_BASIC
												
							--SET @CTC_GROSS =@Total_Ear + @CTC_BASIC
							--EXEC (@val)	
						END
					ELSE IF	@CTC_COLUMNS = 'CTC'
						BEGIN
							--SET @val = 	'UPDATE #CTCMast SET CTC = ' + convert(nvarchar,(IsNull(@Total_Ear,0) + IsNull(@CTC_BASIC,0))) + ' 
							--			 WHERE	#CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' 
							--					AND #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
												
									
							--EXEC (@val)	
						
							UPDATE	C 
							SET		CTC = IsNull(Total_Ear,0) + IsNull(CTC_BASIC,0)
							FROM	#CTCMast C INNER JOIN #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID									
							--WHERE	Cmp_ID = @CTC_CMP_ID
						END
					ELSE IF @CTC_COLUMNS = 'PT'	
						BEGIN						
							--SELECT	@CTC_PT= CASE WHEN @Inc_Wages_Type='Daily' THEN Emp_PT_Amount * @Month_Days_for_Daily ELSE Emp_PT_Amount END  
							--FROM	T0095_INCREMENT 
							--WHERE	Increment_ID=@Inc_ID
							
							UPDATE	EC
							SET		CTC_PT= CASE WHEN Inc_Wages_Type='Daily' THEN Emp_PT_Amount * Month_Days_for_Daily ELSE Emp_PT_Amount END  
							FROM	#Emp_CTC EC
												
							--SET @val = 	'UPDATE  #CTCMast SET PT = ' + convert(nvarchar,(IsNull(@CTC_PT,0))) + ' WHERE #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
							
							UPDATE  C
							SET		PT = IsNull(CTC_PT,0)
							FROM	#CTCMast C INNER JOIN  #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID							
							--WHERE	C.Cmp_ID = @CTC_CMP_ID
							
							UPDATE	#Emp_CTC
							SET		Total_Ded = Total_Ded + CTC_PT
							--SET @Total_Ded = @Total_Ded + @CTC_PT	
							
							--EXEC (@val)								
						END
					ELSE IF @CTC_COLUMNS = 'Total_Deduction'	
						BEGIN							
							--SET @val = 	'UPDATE  #CTCMast SET Total_Deduction = ' + convert(nvarchar,@Total_Ded) + ' WHERE #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)							
							--EXEC (@val)									
							UPDATE  C 
							SET		Total_Deduction = Total_Ded
							FROM	#CTCMast C INNER JOIN  #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID							
							--WHERE	C.Cmp_ID = @CTC_CMP_ID
						end
					ELSE IF @CTC_COLUMNS = 'Net_Take_Home'	
						BEGIN						
							--SET @val = 	'UPDATE  #CTCMast SET Net_Take_Home = ' + convert(nvarchar,(IsNull(@CTC_GROSS,0)  - IsNull(@Total_Ded,0))) + ' WHERE #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)							
							--EXEC (@val)												
							UPDATE  C 
							SET		Net_Take_Home = IsNull(CTC_GROSS,0) - IsNull(Total_Ded,0) 
							FROM	#CTCMast C INNER JOIN  #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID							
							--WHERE	C.Cmp_ID = @CTC_CMP_ID
						END
					ELSE
						BEGIN	
							SELECT	TOP 1 @CTC_AD_FLAG=E_AD_FLAG 
							FROM	#EmpAllowance EA 
							WHERE	EA.AD_NAME = @CTC_COLUMNS 
							
							
							IF @CTC_AD_FLAG <> 'D'
								UPDATE	EC
								SET		Allow_Amount = IsNull(CASE WHEN Inc_Wages_Type = 'Daily' THEN 
															CASE WHEN Ad.AD_CALCULATE_ON in('FIX','FIX + JOINING PRORATE') THEN 
																E_AD_AMOUNT  
															ELSE 
																(E_AD_AMOUNT * @Month_Days_for_Daily) 
															END 
														ELSE 
															E_AD_AMOUNT 
														END,0)
								FROM	#Emp_CTC EC 
										INNER JOIN #EmpAllowance EA ON EC.EMP_ID=EA.EMP_ID
										INNER JOIN T0050_AD_MASTER AD ON EA.AD_ID=AD.AD_ID
								WHERE	IsNull(E_AD_Flag,'') <> 'D'
										AND  EA.AD_NAME = @CTC_COLUMNS 
								
							IF @CTC_AD_FLAG = 'D'	
								UPDATE	EC
								SET		Allow_Amount = IsNull(CASE WHEN Inc_Wages_Type = 'Daily' THEN 
															CASE WHEN Ad.AD_CALCULATE_ON in('FIX','FIX + JOINING PRORATE') THEN 
																E_AD_AMOUNT  
															ELSE 
																(E_AD_AMOUNT * @Month_Days_for_Daily) 
															END 
														ELSE 
															E_AD_AMOUNT 
														END,0)
								FROM	#Emp_CTC EC 
										INNER JOIN #EmpAllowance EA ON EC.EMP_ID=EA.EMP_ID
										INNER JOIN T0050_AD_MASTER AD ON EA.AD_ID=AD.AD_ID
								WHERE	IsNull(E_AD_Flag,'') = 'D'
										AND  EA.AD_NAME = @CTC_COLUMNS 
									
									
							/*
							SELECT	@Allow_Amount = CASE WHEN @Inc_Wages_Type = 'Daily' THEN CASE WHEN Ad.AD_CALCULATE_ON in('FIX','FIX + JOINING PRORATE') THEN E_AD_AMOUNT  ELSE (E_AD_AMOUNT * @Month_Days_for_Daily) END ELSE E_AD_AMOUNT END,
									@CTC_AD_FLAG=E_AD_FLAG 
							FROM	T0100_EMP_EARN_DEDUCTION DED
									INNER JOIN T0050_AD_MASTER AD ON DED.AD_Id = AD.AD_Id
							WHERE	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ad.Ad_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS and DED.CMP_ID = @CTC_CMP_ID and DED.EMP_ID = @CTC_EMP_ID and DED.INCREMENT_ID = @Inc_Id 
												
							IF EXISTS(SELECT 1 FROM T0110_EMP_EARN_DEDUCTION_REVISED DED
													INNER JOIN T0050_AD_MASTER ad ON DED.AD_Id = ad.AD_Id
									  WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(ad.Ad_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
											AND DED.CMP_ID = @CTC_CMP_ID and DED.EMP_ID = @CTC_EMP_ID 
											AND DED.FOR_DATE = 
													(SELECT Max(FOR_DATE) FROM T0110_EMP_EARN_DEDUCTION_REVISED d
																				INNER JOIN T0050_AD_MASTER AD1 ON d.AD_Id = AD1.AD_Id
													 WHERE  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD1.Ad_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
															and d.CMP_ID = @CTC_CMP_ID and d.EMP_ID = @CTC_EMP_ID And For_Date <= @To_Date)
											 ---added by jimit 05122016 After discuss with Nimesh bhai for RK consider only Revise date of allowance greater than Increment effect date   
											 AND NOT EXISTS (SELECT 1 FROM T0100_EMP_EARN_DEDUCTION ed 
																			INNER JOIN t0095_increment I ON ed.INCREMENT_ID = I.Increment_ID 
																			inner join(SELECT MAX(increment_effective_date) as increment_effective_date, emp_id FROM T0095_INCREMENT i2 
																						WHERE increment_effective_date <= @To_Date
																						group by EMP_ID) i2 ON i.Emp_ID=i2.Emp_ID and i.increment_effective_date=i2.increment_effective_date
															 WHERE i.Increment_Type <> 'Transfer' and i.Increment_Type <> 'Deputation' and ed.AD_ID = DED.AD_ID and ed.FOR_DATE < DED.FOR_DATE
																		and ed.Increment_ID = @Inc_Id)
										)
													
								BEGIN
									
									SELECT @Increment_ID = Increment_Id FROM T0095_INCREMENT 
									WHERE Emp_ID =  @CTC_EMP_ID And Cmp_ID = @CTC_CMP_ID 
										And Increment_Id = ( SELECT MAX(Increment_ID) FROM T0095_INCREMENT 
															WHERE Emp_ID =  @CTC_EMP_ID And Cmp_ID = @CTC_CMP_ID And Increment_Effective_Date <=  @To_Date and Increment_Type <> 'transfer' )
								
									SET @Allow_Amount = 0
									
									
									SELECT @Allow_Amount = e_ad_Amount,@CTC_AD_FLAG=E_AD_FLAG FROM
											(SELECT CASE WHEN @Inc_Wages_Type = 'Daily' THEN 
												CASE WHEN AM.AD_CALCULATE_ON in('FIX','FIX + JOINING PRORATE') THEN 
													CASE WHEN  Qry1.Increment_ID >= EED.INCREMENT_ID /* Qry1.FOR_DATE > EED.FOR_DATE */ Then
														CASE WHEN Qry1.E_Ad_Amount IS NULL THEN eed.E_AD_Amount ELSE Qry1.E_Ad_Amount END 
													Else eed.e_ad_Amount END 
												else 
													( CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
														CASE WHEN Qry1.E_Ad_Amount IS NULL THEN eed.E_AD_Amount ELSE Qry1.E_Ad_Amount END 
													  ELSE eed.e_ad_Amount END  * @Month_Days_for_Daily 
													 ) 
												end 
											else 
												CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID /* Qry1.FOR_DATE > EED.FOR_DATE*/ Then
													CASE WHEN Qry1.E_Ad_Amount IS NULL THEN eed.E_AD_Amount ELSE Qry1.E_Ad_Amount END 
												Else eed.e_ad_Amount END 
											end as e_ad_Amount,
										  E_AD_FLAG 
																
									FROM	T0100_EMP_EARN_DEDUCTION EED INNER JOIN 
											T0080_EMP_MASTER E ON EED.Emp_ID=E.Emp_ID  INNER JOIN 
											T0050_ad_master AM ON eed.ad_id = am.ad_id LEFT OUTER JOIN
											( SELECT EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
												FROM T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
												( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised 
													WHERE  Emp_Id = @CTC_EMP_ID And For_date <= @To_Date  And Cmp_ID = @CTC_CMP_ID
												  Group by Ad_Id )Qry ON Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
											) Qry1 ON eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID And Qry1.FOR_DATE >= EED.FOR_DATE and Qry1.Increment_ID >= EED.INCREMENT_ID --added By Jimit 04072017 as it is changed at WCL
									WHERE EEd.EMP_ID = @CTC_EMP_ID 
										And CASE WHEN Qry1.ENTRY_TYPE IS null THEN '' ELSE Qry1.ENTRY_TYPE END <> 'D'
										and REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(am.Ad_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
										and eed.INCREMENT_ID = @Increment_ID
										
									UNION 
									
										SELECT DISTINCT   dbo.F_Show_Decimal(EED.E_AD_AMOUNT,eed.CMP_ID) as E_AD_AMOUNT , EED.E_AD_FLAG
										FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED INNER JOIN
														( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WHERE Emp_Id = @CTC_EMP_ID And For_date <= @To_Date GROUP BY Ad_Id )Qry 
															ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
														dbo.T0080_EMP_MASTER AS EM ON EED.Emp_ID = EM.Emp_ID INNER JOIN
														dbo.T0050_AD_MASTER ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
										WHERE EED.EMP_ID = @CTC_EMP_ID AND EEd.ENTRY_TYPE = 'A' AND EED.Increment_ID = @Increment_ID)Qry
								
								
								END	
							*/																				
							--SET @val = 	'UPDATE  #CTCMast SET ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,IsNull(@Allow_Amount,0)) + ' WHERE #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)

							SET @val = 	'UPDATE	C 
										 SET	[' + @CTC_COLUMNS + '] = IsNull(Allow_Amount,0)
										 FROM	#CTCMast C INNER JOIN #Emp_CTC EC ON C.EMP_ID=EC.EMP_ID'
										 
						
							EXEC (@val)								   
						END
					IF @CTC_AD_FLAG = 'I'
						BEGIN
							--SET @Total_Ear = @Total_Ear + IsNull(@Allow_Amount,0)
							UPDATE	#Emp_CTC
							SET		Total_Ear = Total_Ear + IsNull(Allow_Amount,0)
						END
					ELSE IF @CTC_AD_FLAG = 'D'
						BEGIN
							--SET @Total_Ded = @Total_Ded + IsNull(@Allow_Amount,0)
							UPDATE	#Emp_CTC
							SET		Total_Ded = Total_Ded + IsNull(Allow_Amount,0)
						END
				
					--SET @Inc_Id = 0
					--SET @Allow_Amount = 0
					UPDATE	#Emp_CTC
					SET		Allow_Amount = 0 										
				END																								
			FETCH NEXT FROM CRU_COLUMNS into @CTC_COLUMNS
		End
	CLOSE CRU_COLUMNS	
	DEALLOCATE CRU_COLUMNS


	--fetch next FROM CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
	--			End
	--close CTC_UPDATE	
	--deallocate CTC_UPDATE
	
	----------------------------------------------------------------
	UPDATE #CTCMast SET Alpha_Emp_Code = '="' + Alpha_Emp_Code + '"' -- Added By Gadriwala Muslim 03052014
	--SELECT * FROM #CTCMast WHERE Basic_Salary > 0 order by #CTCMast.Emp_code
	
	--added jimit 28/09/2015
	SELECT * FROM #CTCMast order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Enroll_No AS VARCHAR), 21)  
							WHEN @Order_By='Name' THEN #CTCMast.Emp_Full_Name 
							When @Order_By = 'Designation' THEN (CASE WHEN #CTCMast.Desig_dis_No  = 0 THEN #CTCMast.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(#CTCMast.Desig_dis_No AS VARCHAR), 21)   END) 
							--ELSE RIGHT(REPLICATE(N' ', 500) + #CTCMast.Alpha_Emp_Code, 500) 
						End ,CASE WHEN IsNumeric(REPLACE(REPLACE(#CTCMast.Alpha_Emp_Code,'="',''),'"','')) = 1 THEN Right(Replicate('0',21) + REPLACE(REPLACE(#CTCMast.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(REPLACE(REPLACE(#CTCMast.Alpha_Emp_Code,'="',''),'"','')) = 0 THEN Left(REPLACE(REPLACE(#CTCMast.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 ELSE REPLACE(REPLACE(#CTCMast.Alpha_Emp_Code,'="',''),'"','') END 

