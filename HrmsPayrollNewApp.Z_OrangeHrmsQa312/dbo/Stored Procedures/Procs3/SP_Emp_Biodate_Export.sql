



CREATE PROCEDURE [dbo].[SP_Emp_Biodate_Export]  
	 @Cmp_Id	NUMERIC  
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
	,@PathName as varchar(Max) = ''
	,@WithIncrement as tinyint = 0
AS  
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  
   
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

	DECLARE @Status VARCHAR(10) 
    SET @Status =  ''
    
    SELECT Alpha_Emp_Code AS Emp_code, Initial, Emp_First_Name, Emp_Second_Name, Emp_Last_Name, BM.Branch_Name, GM.Grd_Name, DM.Desig_Name
			, TM.Type_Name, CM.Cat_Name, DT.Dept_Name, REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join, SSN_No AS PF_NO
			, SIN_No AS ESIC_No, Dr_Lic_No, Pan_No, REPLACE(CONVERT(VARCHAR,Date_Of_Birth,106),' ','-') AS Date_Of_Birth			
			, CASE WHEN Marital_Status = 0 THEN 'Single' WHEN Marital_Status = 1 THEN 'Married' WHEN Marital_Status = 2 THEN 'Divorced' WHEN Marital_Status = 3 THEN 'Saperated' END AS Marital_Status 
			, Gender,Nationality, Street_1 AS [Address], City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email
			, CASE WHEN ISNULL(E.Image_Name,'') = '' THEN '' WHEN E.Image_Name = '0.jpg' THEN ''  ELSE @PathName+ '\App_File\Empimages\' + E.Image_Name END as Image_Name
			, Emp_Full_Name, BN.Bank_Name, Inc_Qry.Inc_Bank_Ac_No, Emp_Left, REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Emp_Left_Date
			, Present_Street as [Working_Address], Present_City, Present_State, Present_Post_Box, Enroll_No, Inc_Qry.Emp_OT, Inc_Qry.Emp_Late_Mark
			, Inc_Qry.Emp_Full_PF, Inc_Qry.Emp_PT, Inc_Qry.Emp_Fix_Salary, Inc_Qry.Emp_Part_time, Inc_Qry.Late_Dedu_Type, Inc_Qry.Emp_Childran
			, Blood_Group, Religion, Height, Emp_Mark_Of_Identification, Despencery, Doctor_Name, DespenceryAddress, Insurance_No
			, REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') AS Emp_Confirm_Date, Father_name, DATEDIFF(MM,Date_Of_Join,@To_date) AS Work_Exp_Month
			, Inc_Qry.Wages_Type, Inc_Qry.Basic_salary, Inc_Qry.Gross_salary
			, (SELECT SUP.Emp_Full_Name FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) AS manager
			, e.Old_Ref_No,e.dealer_code, ISNULL(ccm.Center_Name,'-') AS Cost_Center_Name, @Status AS Status, Inc_Qry.Branch_ID AS Branch_ID
			,(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age
			,(SELECT SUP.Alpha_Emp_Code FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) Manager_Code
			, SCM.Name As Salary_Cycle, BS.Segment_Name, VS.Vertical_Name		
			, SV.SubVertical_Name, SB.SubBranch_Name							
			,E.Emp_Dress_Code as Dress_Code 
			,E.Emp_Shirt_Size as Shirt_Code 
			,E.Emp_Pent_Size  as Pent_Code 
			,E.Emp_Shoe_Size  as Shoe_Code 		
			,E.Cmp_ID		
			,Com.Cmp_Name
			,Com.Cmp_Address																									
			,E.Emp_ID
			,E.GroupJoiningDate
			,E.Old_Ref_No
			,TAM.ThanaName
			,E.Tehsil
			,E.District
			,TAMW.ThanaName
			,E.Tehsil_Wok
			,E.District_Wok
			,@WithIncrement as Format_Type
			,E.mother_name,COM.cmp_logo,E.UAN_No   --added jimit 30042016
			,E.Aadhar_Card_No,E.Ration_Card_No,E.Ifsc_Code  --added by chetan 19122017
		FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) 
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID		
							FROM T0095_INCREMENT WITH (NOLOCK)
								INNER JOIN (SELECT MAX(Increment_ID) AS Increment_ID, Emp_ID 
												FROM T0095_INCREMENT WITH (NOLOCK) 
												WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_Id 
												GROUP BY emp_ID
											) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_ID = Qry.Increment_ID   
							WHERE cmp_id = @Cmp_Id
						) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
			INNER JOIN T0010_COMPANY_MASTER COM WITH (NOLOCK) ON COM.Cmp_Id = E.Cmp_ID
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id
			INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id
			LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_id = BN.Bank_Id 
			LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON Inc_Qry.Type_Id = TM.Type_Id
			LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON Inc_Qry.Cat_id = CM.Cat_Id
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id			
			LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = Inc_Qry.Center_ID
			LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON SCM.Tran_ID = Inc_Qry.SalDate_ID		
			LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) On BS.Segment_ID = Inc_Qry.Segment_ID			
			LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On VS.Vertical_ID = Inc_Qry.Vertical_ID		
			LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) On SV.SubVertical_ID =  Inc_Qry.SubVertical_ID		
			LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) On SB.SubBranch_ID = Inc_Qry.SubBranch_ID
			LEFT OUTER JOIN T0030_Thana_Master TAM WITH (NOLOCK) ON TAM.Cmp_Id = E.Cmp_ID AND TAM.Thana_Id = E.Thana_Id
			LEFT OUTER JOIN T0030_Thana_Master TAMW WITH (NOLOCK) ON TAMW.Cmp_Id = E.Cmp_ID AND TAMW.Thana_Id = E.Thana_Id_Wok	
		WHERE e.Cmp_ID = @Cmp_Id   
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)		
 RETURN


