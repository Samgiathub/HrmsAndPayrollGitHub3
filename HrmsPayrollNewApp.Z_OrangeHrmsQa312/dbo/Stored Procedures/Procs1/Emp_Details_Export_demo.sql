




CREATE PROCEDURE [dbo].[Emp_Details_Export_demo]  
	 @Company_Id	  varchar(max) 
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		Varchar(Max) = ''
	,@Grade_ID 		Varchar(Max) = ''
	,@Type_ID 		Varchar(Max) = ''
	,@Dept_ID 		Varchar(Max) = ''
	,@Desig_ID 		Varchar(Max) = ''
	,@Emp_ID 		NUMERIC
	,@Constraint	VARCHAR(MAX)
	,@Cat_ID        Varchar(Max) = ''
	,@Order_By	varchar(30) = 'Code'
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  
	
      CREATE TABLE #Cmp_Cons                 
   (                      
     Cmp_ID NUMERIC                     
   )      
    INSERT INTO #Cmp_Cons    
    SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Company_Id,'#')
	 declare @company_Count as int    
     set @company_Count =(SELECT COUNT(@Company_Id) FROM #Cmp_Cons)    
	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )            
    
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN_demo @Company_Id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0               
		--******* New Sequence Added By Ramiz on 19/08/2017 ******---
		-- All Missing Fields of Employee Master Import Sheet are now Added , so that it can directly be Exported and we can Import Employee Master in Case of Re Join Employees--
	
	--select * from #Emp_Cons
	if(@company_Count>=1 and @Company_Id<>cast(0 as varchar))
	begin 

	SELECT '="' + Alpha_Emp_Code + '"' AS Emp_code, Initial, Emp_First_Name, Emp_Second_Name, Emp_Last_Name, Emp_Full_Name, BM.Branch_Name, GM.Grd_Name As Grade_Name
			,DT.Dept_Name As Department,CM.Cat_Name As Category,DM.Desig_Name As Designation_Name, TM.Type_Name,SHM.Shift_Name as Shift_Name,BN.Bank_Name
			,CUM.Curr_Name as Currency,REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join, Pan_No,SIN_No AS ESIC_No,SSN_No AS PF_NO
			,REPLACE(CONVERT(VARCHAR,Date_Of_Birth,106),' ','-') AS Date_Of_Birth, CASE	WHEN Marital_Status = 0 THEN 'Single' 
					WHEN Marital_Status = 1 THEN 'Married' 
					WHEN Marital_Status = 2 THEN 'Divorced' 
					WHEN Marital_Status = 3 THEN 'Separated' 
					WHEN Marital_Status = 4 THEN 'Widowed' 
					END AS Marital_Status, Gender,Nationality, Lm.Loc_name as Location,Street_1 AS [Address], City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No
			, Work_Email, Other_Email, Present_Street [Working_Address], Present_City, Present_State, Present_Post_Box, IsNull(INC_SAL.Basic_salary,0) As Basic_salary, IsNull(INC_SAL.Gross_salary,0) As Gross_salary, INC_SAL.Wages_Type
			, Inc_Qry.Salary_Basis_on ,Inc_Qry.Payment_Mode,Inc_Qry.Inc_Bank_Ac_No ,Inc_Qry.Emp_OT ,Emp_Late_Limit as LATE_LIMIT,emp_early_limit as EARLY_LIMIT
			, Inc_Qry.Emp_Late_Mark, Inc_Qry.Emp_Full_PF, Inc_Qry.Emp_PT, Inc_Qry.Emp_Fix_Salary, Blood_Group, Enroll_No, Father_name,e.Ifsc_Code
			, REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') AS Emp_Confirm_Date,Probation,e.Old_Ref_No,e.Alpha_Code
			,(SELECT SUP.Alpha_Emp_Code FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) Manager_Code
			,(SELECT SUP.Emp_Full_Name FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) AS Manager_Name
			, case when isnull(E.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF
			, Inc_Qry.Emp_WeekDay_OT_Rate as WeekDay_OT_Rate , Inc_Qry.Emp_WeekOff_OT_Rate as Weekoff_OT_Rate , Inc_Qry.Emp_Holiday_OT_Rate as Holiday_OT_Rate
			, BS.Segment_Name, VS.Vertical_Name , SV.SubVertical_Name, REPLACE(CONVERT(VARCHAR,E.GroupJoiningDate,106),' ','-') As Group_Join_Date,SB.SubBranch_Name
			, SCM.Name As Salary_Cycle,Emp_Auto_Vpf as Company_Full_PF , PSCM.Pay_Scale_Name , Customer_Audit
			
			, E.Image_Name,Emp_Left, REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Emp_Left_Date
			, Inc_Qry.Emp_Part_time, Inc_Qry.Late_Dedu_Type, Inc_Qry.Emp_Childran, Religion, Height, Emp_Mark_Of_Identification
			, Despencery, Doctor_Name, DespenceryAddress, Insurance_No,  DATEDIFF(MM,Date_Of_Join,@To_date) AS Work_Exp_Month
			, e.dealer_code, ISNULL(ccm.Center_Name,'-') AS Cost_Center_Name,
			(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age
			, Dr_Lic_No,e.Emp_Dress_Code as Dress_Code,e.Emp_Shirt_Size as Shirt_Code , e.Emp_Pent_Size  as Pent_Code,e.Emp_Shoe_Size  as Shoe_Code
			, e.Emp_Canteen_Code as Canteen_Code,e.Extra_AB_Deduction,E.DBRD_Code,LGN.Login_Name,LGN.Login_Alias,COM.Cmp_Name AS Transfer_From_Company
			, E.Tally_Led_Name ,Case When ISNULL(E.Salary_Depends_on_Production,0) = 1 then 'Yes' Else 'No' END as Salary_Depends_on_Production
			, UAN_No,Aadhar_Card_No , CCenter_Remark as CostCenter_Remark,REPLACE(CONVERT(VARCHAR,Emp_Offer_Date,106),' ','-') AS Emp_Offer_Date
			,Inc_Qry.Branch_ID 
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT Emp_Id,Increment_ID, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary,  ( '="' + Inc_Bank_Ac_No + '"') as Inc_Bank_Ac_No, Emp_OT , Emp_WeekDay_OT_Rate , Emp_WeekOff_OT_Rate , Emp_Holiday_OT_Rate
								, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID , Payment_Mode		-- Added By Hiral 22 August, 2013
						FROM	T0095_INCREMENT WITH (NOLOCK) )	Inc_Qry ON EC.Emp_ID = Inc_Qry.Emp_ID AND EC.Increment_ID=Inc_Qry.Increment_ID
			INNER JOIN T0095_INCREMENT INC_SAL WITH (NOLOCK) ON E.Emp_ID = INC_SAL.Emp_ID 
			INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
						FROM	T0095_Increment I1 WITH (NOLOCK)
								INNER JOIN (SELECT	I2.Emp_ID, Max(I2.Increment_Effective_Date) As Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE	I2.Increment_Effective_Date < @TO_DATE AND I2.Increment_Type NOT IN ('Transfer', 'Deputation')
											Group BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
						Group BY I1.Emp_ID) I1 ON I1.Emp_ID=INC_SAL.Emp_ID AND I1.Increment_ID=INC_SAL.Increment_ID
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id
			INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id
			inner join #Cmp_Cons CC with(NOLOCK) on CC.Cmp_ID=E.Cmp_ID
			LEFT OUTER JOIN T0011_LOGIN LGN WITH (NOLOCK) ON E.Cmp_ID=LGN.Cmp_ID AND E.Emp_ID=LGN.Emp_ID
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
			LEFT OUTER JOIN T0095_EMP_COMPANY_TRANSFER ECT WITH (NOLOCK) ON ECT.New_Emp_Id = E.Emp_ID				
			LEFT OUTER JOIN T0010_COMPANY_MASTER COM WITH (NOLOCK) ON COM.Cmp_ID = ECT.Old_Cmp_Id
			LEFT OUTER JOIN		(
									SELECT     psc.Pay_Scale_ID,PSC.Emp_ID,PSC.Cmp_ID
									FROM       T0050_EMP_PAY_SCALE_DETAIL PSC WITH (NOLOCK) inner JOIN
									           #Cmp_Cons CC on CC.Cmp_ID=PSC.Cmp_ID inner JOIN
												(
													SELECT max(Pay_Scale_ID)as  pay_scale_Id,Emp_ID 
													FROM   T0050_EMP_PAY_SCALE_DETAIL WITH (NOLOCK)
													inner join #Cmp_Cons CC on CC.Cmp_ID=T0050_EMP_PAY_SCALE_DETAIL.Cmp_ID
													WHERE  Effective_Date <= @To_Date and T0050_EMP_PAY_SCALE_DETAIL.Cmp_ID in(cc.Cmp_ID)
													GROUP by Emp_ID
												)Qr On Qr.Emp_ID = PSC.Emp_ID and Qr.pay_scale_Id= PSC.Pay_Scale_ID			
									WHERE PSC.Cmp_ID in(CC.Cmp_ID)) Qr_1 On Qr_1.Emp_ID = e.Emp_ID
			LEFT OUTER JOIN	   T0040_PAY_SCALE_MASTER PSCM WITH (NOLOCK) On PSCM.Pay_Scale_ID = Qr_1.Pay_Scale_ID and pscm.Cmp_ID = Qr_1.cmp_Id
			LEFT OUTER JOIN    T0040_CURRENCY_MASTER  CUM WITH (NOLOCK) On CUM.Curr_ID = E.Curr_ID and CUm.Cmp_ID = E.Cmp_ID
			LEFT OUTER JOIN		T0040_SHIFT_MASTER SHM	WITH (NOLOCK) on SHM.Shift_ID = E.shift_Id 
			LEFT OUTER JOIN     T0001_LOCATION_MASTER LM WITH (NOLOCK) on Lm.Loc_Id = E.Loc_ID	
	WHERE	e.Cmp_ID in(CC.Cmp_ID)	
	Order by CASE WHEN @Order_By='Name' THEN E.Emp_Full_Name  --added by jaina 31072015 start
					WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0', 21) +  CAST(E.Enroll_No AS VARCHAR), 21)
					ELSE 
					(CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code END)
		End
 end
 else
 begin
 print 2
 	SELECT '="' + Alpha_Emp_Code + '"' AS Emp_code, Initial, Emp_First_Name, Emp_Second_Name, Emp_Last_Name, Emp_Full_Name, BM.Branch_Name, GM.Grd_Name As Grade_Name
			,DT.Dept_Name As Department,CM.Cat_Name As Category,DM.Desig_Name As Designation_Name, TM.Type_Name,SHM.Shift_Name as Shift_Name,BN.Bank_Name
			,CUM.Curr_Name as Currency,REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join, Pan_No,SIN_No AS ESIC_No,SSN_No AS PF_NO
			,REPLACE(CONVERT(VARCHAR,Date_Of_Birth,106),' ','-') AS Date_Of_Birth, CASE	WHEN Marital_Status = 0 THEN 'Single' 
					WHEN Marital_Status = 1 THEN 'Married' 
					WHEN Marital_Status = 2 THEN 'Divorced' 
					WHEN Marital_Status = 3 THEN 'Separated' 
					WHEN Marital_Status = 4 THEN 'Widowed' 
					END AS Marital_Status, Gender,Nationality, Lm.Loc_name as Location,Street_1 AS [Address], City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No
			, Work_Email, Other_Email, Present_Street [Working_Address], Present_City, Present_State, Present_Post_Box, IsNull(INC_SAL.Basic_salary,0) As Basic_salary, IsNull(INC_SAL.Gross_salary,0) As Gross_salary, INC_SAL.Wages_Type
			, Inc_Qry.Salary_Basis_on ,Inc_Qry.Payment_Mode,Inc_Qry.Inc_Bank_Ac_No ,Inc_Qry.Emp_OT ,Emp_Late_Limit as LATE_LIMIT,emp_early_limit as EARLY_LIMIT
			, Inc_Qry.Emp_Late_Mark, Inc_Qry.Emp_Full_PF, Inc_Qry.Emp_PT, Inc_Qry.Emp_Fix_Salary, Blood_Group, Enroll_No, Father_name,e.Ifsc_Code
			, REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') AS Emp_Confirm_Date,Probation,e.Old_Ref_No,e.Alpha_Code
			,(SELECT SUP.Alpha_Emp_Code FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) Manager_Code
			,(SELECT SUP.Emp_Full_Name FROM dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) WHERE SUP.Emp_ID = E.Emp_Superior) AS Manager_Name
			, case when isnull(E.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF
			, Inc_Qry.Emp_WeekDay_OT_Rate as WeekDay_OT_Rate , Inc_Qry.Emp_WeekOff_OT_Rate as Weekoff_OT_Rate , Inc_Qry.Emp_Holiday_OT_Rate as Holiday_OT_Rate
			, BS.Segment_Name, VS.Vertical_Name , SV.SubVertical_Name, REPLACE(CONVERT(VARCHAR,E.GroupJoiningDate,106),' ','-') As Group_Join_Date,SB.SubBranch_Name
			, SCM.Name As Salary_Cycle,Emp_Auto_Vpf as Company_Full_PF , PSCM.Pay_Scale_Name , Customer_Audit
			
			, E.Image_Name,Emp_Left, REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Emp_Left_Date
			, Inc_Qry.Emp_Part_time, Inc_Qry.Late_Dedu_Type, Inc_Qry.Emp_Childran, Religion, Height, Emp_Mark_Of_Identification
			, Despencery, Doctor_Name, DespenceryAddress, Insurance_No,  DATEDIFF(MM,Date_Of_Join,@To_date) AS Work_Exp_Month
			, e.dealer_code, ISNULL(ccm.Center_Name,'-') AS Cost_Center_Name,
			(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age
			, Dr_Lic_No,e.Emp_Dress_Code as Dress_Code,e.Emp_Shirt_Size as Shirt_Code , e.Emp_Pent_Size  as Pent_Code,e.Emp_Shoe_Size  as Shoe_Code
			, e.Emp_Canteen_Code as Canteen_Code,e.Extra_AB_Deduction,E.DBRD_Code,LGN.Login_Name,LGN.Login_Alias,COM.Cmp_Name AS Transfer_From_Company
			, E.Tally_Led_Name ,Case When ISNULL(E.Salary_Depends_on_Production,0) = 1 then 'Yes' Else 'No' END as Salary_Depends_on_Production
			, UAN_No,Aadhar_Card_No , CCenter_Remark as CostCenter_Remark,REPLACE(CONVERT(VARCHAR,Emp_Offer_Date,106),' ','-') AS Emp_Offer_Date
			,Inc_Qry.Branch_ID 
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT Emp_Id,Increment_ID, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary,  ( '="' + Inc_Bank_Ac_No + '"') as Inc_Bank_Ac_No, Emp_OT , Emp_WeekDay_OT_Rate , Emp_WeekOff_OT_Rate , Emp_Holiday_OT_Rate
								, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID , Payment_Mode		-- Added By Hiral 22 August, 2013
						FROM	T0095_INCREMENT WITH (NOLOCK) )	Inc_Qry ON EC.Emp_ID = Inc_Qry.Emp_ID AND EC.Increment_ID=Inc_Qry.Increment_ID
			INNER JOIN T0095_INCREMENT INC_SAL WITH (NOLOCK) ON E.Emp_ID = INC_SAL.Emp_ID 
			INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
						FROM	T0095_Increment I1 WITH (NOLOCK)
								INNER JOIN (SELECT	I2.Emp_ID, Max(I2.Increment_Effective_Date) As Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE	I2.Increment_Effective_Date < @TO_DATE AND I2.Increment_Type NOT IN ('Transfer', 'Deputation')
											Group BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
						Group BY I1.Emp_ID) I1 ON I1.Emp_ID=INC_SAL.Emp_ID AND I1.Increment_ID=INC_SAL.Increment_ID
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id
			INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id
			--inner join #Cmp_Cons CC with(NOLOCK) on CC.Cmp_ID=E.Cmp_ID
			LEFT OUTER JOIN T0011_LOGIN LGN WITH (NOLOCK) ON E.Cmp_ID=LGN.Cmp_ID AND E.Emp_ID=LGN.Emp_ID
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
			LEFT OUTER JOIN T0095_EMP_COMPANY_TRANSFER ECT WITH (NOLOCK) ON ECT.New_Emp_Id = E.Emp_ID				
			LEFT OUTER JOIN T0010_COMPANY_MASTER COM WITH (NOLOCK) ON COM.Cmp_ID = ECT.Old_Cmp_Id
			LEFT OUTER JOIN		(
									SELECT     psc.Pay_Scale_ID,PSC.Emp_ID,PSC.Cmp_ID
									FROM       T0050_EMP_PAY_SCALE_DETAIL PSC WITH (NOLOCK) inner JOIN
									          -- #Cmp_Cons CC on CC.Cmp_ID=PSC.Cmp_ID inner JOIN
												(
													SELECT max(Pay_Scale_ID)as  pay_scale_Id,Emp_ID 
													FROM   T0050_EMP_PAY_SCALE_DETAIL WITH (NOLOCK)
													--inner join #Cmp_Cons CC on CC.Cmp_ID=T0050_EMP_PAY_SCALE_DETAIL.Cmp_ID
													WHERE  Effective_Date <= @To_Date --and T0050_EMP_PAY_SCALE_DETAIL.Cmp_ID in(cc.Cmp_ID)
													GROUP by Emp_ID
												)Qr On Qr.Emp_ID = PSC.Emp_ID and Qr.pay_scale_Id= PSC.Pay_Scale_ID			
									) Qr_1 On Qr_1.Emp_ID = e.Emp_ID
			LEFT OUTER JOIN	   T0040_PAY_SCALE_MASTER PSCM WITH (NOLOCK) On PSCM.Pay_Scale_ID = Qr_1.Pay_Scale_ID and pscm.Cmp_ID = Qr_1.cmp_Id
			LEFT OUTER JOIN    T0040_CURRENCY_MASTER  CUM WITH (NOLOCK) On CUM.Curr_ID = E.Curr_ID and CUm.Cmp_ID = E.Cmp_ID
			LEFT OUTER JOIN		T0040_SHIFT_MASTER SHM	WITH (NOLOCK) on SHM.Shift_ID = E.shift_Id 
			LEFT OUTER JOIN     T0001_LOCATION_MASTER LM WITH (NOLOCK) on Lm.Loc_Id = E.Loc_ID	
	--WHERE	e.Cmp_ID in(CC.Cmp_ID)	
	Order by CASE WHEN @Order_By='Name' THEN E.Emp_Full_Name  --added by jaina 31072015 start
					WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0', 21) +  CAST(E.Enroll_No AS VARCHAR), 21)
					ELSE 
					(CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code END)
		End

  end
 RETURN

