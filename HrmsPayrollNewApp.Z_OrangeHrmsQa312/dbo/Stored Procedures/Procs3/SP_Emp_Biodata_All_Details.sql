



CREATE PROCEDURE [dbo].[SP_Emp_Biodata_All_Details]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		NUMERIC	
	,@Grade_ID 		NUMERIC
	,@Type_ID 		NUMERIC
	,@Dept_ID 		NUMERIC
	,@Desig_ID 		NUMERIC
	,@Emp_ID 		NUMERIC
	,@Constraint	VARCHAR(MAX)
	,@Cat_ID        NUMERIC = 0
	,@Salary_Cycle_id NUMERIC = 0
	,@Segment_ID	NUMERIC = 0
	,@Vertical_Id	NUMERIC = 0
	,@SubVertical_Id	NUMERIC = 0
	,@SubBranch_Id	NUMERIC = 0
	,@Op			NUMERIC = 0
	,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 16-05-2017            
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  
   
    set @Show_Hidden_Allowance = 0
    
 	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Grade_ID = 0  
		 SET @Grade_ID = NULL  
		 
	IF @Emp_ID = 0  
		SET @Emp_ID = NULL  
		
	IF @Desig_ID = 0  
		SET @Desig_ID = NULL  
		
    IF @Dept_ID = 0  
		SET @Dept_ID = NULL 
		
	IF @Type_ID = 0  
		SET @Type_ID = NULL 	
		
    IF @Cat_ID = 0
        SET @Cat_ID = NULL
        
	If @Salary_Cycle_id = 0
   set @Salary_Cycle_id = null
   
	If @Segment_ID = 0
  set @Segment_ID = null
        
	if @Vertical_Id =0
   set @Vertical_Id =NULL
  
	if @SubVertical_Id =0
   set @SubVertical_Id =null
  
	if @SubBranch_Id =0
   set @SubBranch_Id =null
     
	CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
 )            
         

	if @Constraint <> ''        
	 BEGIN	 
	   Insert Into #Emp_Cons(Emp_ID)        
	   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
	  END      
 ELSE        
	 BEGIN
	 
			 Insert Into #Emp_Cons      
		    select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
		    left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
			inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = V_Emp_Cons.Emp_ID
			where 
		    cmp_id=@Cmp_ID 
		   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grade_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
		   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013
		   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013
		   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )						
						) 
						order by Emp_ID
			Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date)
  END
    
  IF @Op = 0 -- EMERGENCY_CONTACT_DETAIL
	BEGIN  
			SELECT Name,RelationShip,Home_Tel_No as 'Home Phone',Home_Mobile_No as 'Mobile'
			,Work_Tel_No as 'Work Phone',ECD.Emp_ID,Cmp_ID FROM T0090_EMP_EMERGENCY_CONTACT_DETAIL ECD WITH (NOLOCK) INNER JOIN
			#Emp_Cons E ON E.Emp_ID = ECD.Emp_ID WHERE ECD.Cmp_ID =  @Cmp_Id
			Order by Name
	END
  ELSE IF @Op = 1 -- EMP_DEPENDANT_DETAIL
	BEGIN	
			SELECT Name,RelationShip,D_Age as 'Age',BirthDate,Share			
			,CASE WHEN ISNULL(NomineeFor,0) = 0 THEN 'ALL' WHEN ISNULL(NomineeFor,0) = 1 THEN 'PF' WHEN ISNULL(NomineeFor,0) = 2 THEN 'Gratuity' WHEN ISNULL(NomineeFor,0) = 3 THEN 'ESIC' WHEN ISNULL(NomineeFor,0) = 4 THEN 'GPA' WHEN ISNULL(NomineeFor,0) = 5 THEN 'Super Annuation' END as 'NomineeFor'
			,CASE WHEN ISNULL(Is_Resi,0) = 0 THEN  'NO' ELSE 'YES' END as 'Is_Resi'
			,EDD.Emp_ID,Cmp_ID
			FROM T0090_EMP_DEPENDANT_DETAIL EDD WITH (NOLOCK) INNER JOIN
			#Emp_Cons E ON E.Emp_ID = EDD.Emp_ID WHERE EDD.Cmp_ID =  @Cmp_Id
			Order by Name
	END
  ELSE IF @Op = 2 -- EMP_CHILDRAN_DETAIL
	BEGIN
			SELECT Name,Relationship
			,CASE WHEN Gender = 'M' THEN 'Male' ELSE 'Female' END as 'Gender'
			,C_Age,Date_Of_Birth
			,CASE WHEN ISNULL(Is_Resi,0) = 0 THEN  'NO' ELSE 'YES' END as 'Is_Resi'
			,CASE WHEN ISNULL(Is_Dependant,0) = 0 THEN  'NO' ELSE 'YES' END as 'Is_Dependant'
			,EDD.Emp_ID,Cmp_ID
			FROM T0090_EMP_CHILDRAN_DETAIL EDD WITH (NOLOCK) INNER JOIN
			#Emp_Cons E ON E.Emp_ID = EDD.Emp_ID WHERE EDD.Cmp_ID =  @Cmp_Id
			Order by Name
	END
  ELSE IF @Op = 3 -- LOCATION_MASTER
	BEGIN
			Select Imm_Type,Imm_No,EID.Loc_ID,Loc_name,Imm_Issue_Date,Imm_Date_of_Expiry,EID.Emp_ID,Cmp_ID
			from T0090_EMP_IMMIGRATION_DETAIL EID WITH (NOLOCK)
			INNER JOIN T0001_LOCATION_MASTER LM WITH (NOLOCK) ON LM.Loc_ID = EID.Loc_ID
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EID.Emp_ID 
			Where EID.Cmp_ID = @Cmp_Id order by Imm_Type
	END
  ELSE IF  @Op = 4 -- EMP_ASSET_DETAIL
	BEGIN	
			--Select Asset_ID,Asset_Name,Model_No,Issue_Date,Return_Date,EAD.Emp_ID,Cmp_ID 
			--from V0090_EMP_ASSET_DETAIL EAD
			--INNER JOIN #Emp_Cons E ON E.Emp_ID = EAD.Emp_ID 
			--Where EAD.Cmp_ID = @Cmp_Id order by Asset_Name
			--Mukti(start)23122015
			Select AP.Asset_ID,AP.Asset_Name,AP.Model_Name AS Model_No,AP.Allocation_Date as Issue_Date,AP.Return_Date,EAD.Emp_ID,EAD.Cmp_ID 
			from V0100_Asset_Approval EAD
			inner join V0120_Asset_Approval AP on AP.Asset_Approval_ID=EAD.Asset_Approval_ID
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EAD.Emp_ID 
			Where EAD.Cmp_ID = @Cmp_Id order by Asset_Name
			--Mukti(end)23122015
	END
  ELSE IF  @Op = 5 -- Emp_License_Detail
	BEGIN	
			Select Lic_Name,Lic_For,Lic_Number,Lic_St_Date,Lic_End_Date,Lic_Comments
			,CASE WHEN ISNULL(Is_Expired,0) = 0 THEN 'NO' ELSE 'YES' END as 'Is_Expired'
			,ELD.Emp_ID,Cmp_ID
			from V0090_Emp_License_Detail_Get ELD
			INNER JOIN #Emp_Cons E ON E.Emp_ID = ELD.Emp_ID 
			Where ELD.Cmp_ID = @Cmp_Id order by Lic_Name
	END
  ELSE IF @Op = 6 -- EMP_REPORTING_DETAIL
	BEGIN
			Select CAST(Alpha_Emp_Code + '-' + Emp_Full_Name as varchar(50)) as Emp_Name
			,R_Emp_Full_Name as Reporting_Manager 
			,Reporting_To,Reporting_Method,ERD.Emp_ID,Cmp_ID,R_Emp_ID
			from V0090_EMP_REPORTING_DETAIL_Get ERD
			INNER JOIN #Emp_Cons E ON E.Emp_ID = ERD.Emp_ID 
			Where ERD.Cmp_ID = @Cmp_Id order by Emp_Name

	END
  ELSE IF @Op = 7 -- EMP_CONTRACT_DETAIL
	BEGIN
			Select Prj_name,[Start_Date],End_Date
			, CASE WHEN ISNULL(Is_Renew,0) = 0 THEN 'NO' ELSE 'YES' END as 'Is_Renew'
			, CASE WHEN ISNULL(Is_Reminder,0) = 0 THEN 'NO' ELSE 'YES' END as 'Is_Renew'
			,ECD.Emp_ID,ECD.Cmp_ID
			from T0090_EMP_CONTRACT_DETAIL ECD WITH (NOLOCK)
			INNER JOIN T0040_PROJECT_MASTER PM WITH (NOLOCK) ON PM.Prj_ID = ECD.Prj_ID
			INNER JOIN #Emp_Cons E ON E.Emp_ID = ECD.Emp_ID 
			Where ECD.Cmp_ID = @Cmp_Id  order by Prj_name
			
	END
  ELSE IF @Op = 8 -- Emp_Experiance_Detail
	BEGIN
			Select CAST(Alpha_Emp_Code + ' - ' +  Emp_Full_Name as varchar(50)) as Emp_Name
			,Branch_Name,Employer_Name,Desig_Name,Branch,Location,Manager,Manager_Contact_Number
			,St_Date as From_Date,End_Date as To_Date ,CTC_Amount,GROSS_Salary,Exp_Remarks
			,EXD.Emp_ID,EXD.Cmp_ID
			from V0090_Emp_Experiance_Detail EXD 
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EXD.Emp_ID 
			Where EXD.Cmp_ID = @Cmp_Id order by Employer_Name
	END
  ELSE IF @Op = 9 -- EMP_LANGUAGE_DETAIL
	BEGIN
			Select Lang_Name,Lang_Fluency,REPLACE(Lang_Ability,'#',',') as 'Lang_Ability',ELD.Emp_Id,ELD.Cmp_ID
			from T0090_EMP_LANGUAGE_DETAIL ELD WITH (NOLOCK)
			INNER JOIN T0040_LANGUAGE_MASTER LM WITH (NOLOCK) ON LM.Lang_ID = ELD.Lang_ID
			INNER JOIN #Emp_Cons E ON E.Emp_ID = ELD.Emp_ID 
			Where ELD.Cmp_ID = @Cmp_Id order by Lang_Name
			
	END
  ELSE IF @Op = 10 -- Emp_Qualification_Detail
	BEGIN
			Select CAST(Alpha_Emp_Code + ' - ' + Emp_Full_Name as varchar(50)) as Emp_Name
			,Date_Of_Join,End_Date as Passing_Date,Qual_Name as Qualification,qual_type
			, Specialization,Year,Score,EQD.Emp_ID,Cmp_ID 
			from V0090_Emp_Qualification_Detail_Get  EQD
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EQD.Emp_ID 
			Where EQD.Cmp_ID = @Cmp_Id order by Qualification

	END
  ELSE IF @Op = 11 -- Emp_Skill_Detail
	BEGIN
			Select CAST(Alpha_Emp_Code + ' - ' + Emp_Full_Name as varchar(50)) as Emp_Name
			,Skill_Name as Skill, Skill_Experience,ESD.Emp_ID,Cmp_ID 
			from V0090_Emp_Skill_Detail_Get ESD
			INNER JOIN #Emp_Cons E ON E.Emp_ID = ESD.Emp_ID 
			Where ESD.Cmp_ID = @Cmp_Id order by Skill
	END
  ELSE IF @Op = 12 -- EMP_EARN_DEDUCTION
	BEGIN
			Select AD_NAME,FOR_DATE as 'Effective_Date',
			--E_AD_AMOUNT     commented by jimit to set Ad amount 0 when ad_calculate on Formula (for Rk) 
			(case when EED.AD_CALCULATE_ON = 'Formula' then 0 ELSE E_AD_AMOUNT end) as E_AD_AMOUNT
			,E_AD_Flag1,E_AD_FLAG
			,E_AD_PERCENTAGE,AD_CALCULATE_ON,E_AD_MODE,EED.EMP_ID,CMP_ID
			from V0100_EMP_EARN_DEDUCTION EED
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EED.Emp_ID 
			Where EED.Cmp_ID = @Cmp_Id 
				AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0  AND  EED.HIDE_IN_REPORTS = 1 AND EED.AD_NOT_EFFECT_SALARY=1 THEN 0 ELSE 1 END )=1  --CHANGE BY JAINA 16-05-2017
			order by AD_NAME
	END
  ELSE IF @Op = 13 -- EMP_INSURANCE_DETAIL
	BEGIN
			--Select * from T0080_EMP_MASTER EM
			--INNER JOIN #Emp_Cons E ON E.Emp_ID = EM.Emp_ID 
			--INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
			--					, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
			--					, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
			--					, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID		
			--				FROM T0095_INCREMENT 
			--					INNER JOIN (SELECT MAX(Increment_effective_Date) AS For_Date, Emp_ID 
			--									FROM T0095_INCREMENT  
			--									WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_Id 
			--									GROUP BY emp_ID
			--								) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND Increment_Effective_date = Qry.For_date   
			--				WHERE cmp_id = @Cmp_Id
			--			) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
			--Where EM.Cmp_ID = @Cmp_Id
			
			Select Ins_Name,Ins_Cmp_name,Ins_Policy_No,Ins_Due_Date,Ins_Taken_Date,Ins_Amount,Ins_Exp_Date,Ins_Anual_Amt,EID.Emp_Id,Cmp_ID,EID.Emp_Dependent_Name_Detail
			from V0090_EMP_INSURANCE_DETAIL EID
			INNER JOIN #Emp_Cons E ON E.Emp_ID = EID.Emp_ID 
			Where EID.Cmp_ID = @Cmp_Id order by Ins_Name

	END
   
ELSE IF @Op = 14 -- With Increment History ''Code Added By Ramiz on 05/02/2015
	BEGIN
	
			CREATE TABLE #Inc_History
			  (
				cmp_id numeric(18),
				inc_id numeric(18),
				Emp_id numeric(18),
				Revised_date datetime,
				CTC numeric(18,2),
				Gross_Salary numeric(18,2),
				Basic_Salary numeric(18,2)				
			  )
			
			  insert into #Inc_History
			  select inc.cmp_id,inc.increment_id,inc.emp_id,inc.increment_effective_date,inc.ctc,inc.gross_salary,inc.basic_Salary from t0095_increment inc WITH (NOLOCK)
			  inner join t0080_emp_master em WITH (NOLOCK) on inc.emp_id = em.emp_id
			  inner join #Emp_Cons ec on  ec.emp_id = inc.emp_id
			  order by inc.emp_id,inc.increment_effective_date
			  
			  select Revised_date , CTC , Gross_Salary , Basic_Salary from #Inc_History order by Revised_date desc
			  
			  Drop table #Inc_History

	END
END



