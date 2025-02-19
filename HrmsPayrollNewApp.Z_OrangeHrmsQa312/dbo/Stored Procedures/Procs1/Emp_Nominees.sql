


-- =============================================
-- Author:		<Author,,jimit>
-- Create date: <Create Date,,30042015>
-- Description:	<Description,,Emp_Nominees>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Emp_Nominees]
	 @Company_Id	NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	--,@Branch_ID		NUMERIC	
	--,@Grade_ID 		NUMERIC
	--,@Type_ID 		NUMERIC
	--,@Dept_ID 		NUMERIC
	--,@Desig_ID 		NUMERIC
	,@Branch_ID		Varchar(Max) = ''	 
	,@Grade_ID 		Varchar(Max) = ''
	,@Type_ID 		Varchar(Max) = ''
	,@Dept_ID 		Varchar(Max) = ''
	,@Desig_ID 		Varchar(Max) = ''
	,@Emp_ID 		NUMERIC
	,@Constraint	VARCHAR(MAX)
	,@Cat_ID        Varchar(Max) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  


CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )
  
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0               
           
           	DECLARE @Status VARCHAR(10) 
    SET @Status =  ''
  --  SELECT Alpha_Emp_Code AS Emp_code, Initial, Emp_First_Name, Emp_Second_Name, Emp_Last_Name, BM.Branch_Name, GM.Grd_Name, DM.Desig_Name
		--	, TM.Type_Name, CM.Cat_Name, DT.Dept_Name, REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join, SSN_No AS PF_NO
		--	, SIN_No AS ESIC_No, Dr_Lic_No, Pan_No, REPLACE(CONVERT(VARCHAR,Date_Of_Birth,106),' ','-') AS Date_Of_Birth
			
		--	, CASE WHEN Marital_Status = 0 THEN 'Single' WHEN Marital_Status = 1 THEN 'Married' WHEN Marital_Status = 2 THEN 'Divorced' WHEN Marital_Status = 3 THEN 'Saperated' END AS Marital_Status 
		--	, Gender,Nationality, Street_1 AS [Address], City, STATE, Zip_code, Home_Tel_no, Mobile_No, Work_Tel_No, Work_Email, Other_Email
		--	, Image_Name, Emp_Full_Name, BN.Bank_Name, Inc_Qry.Inc_Bank_Ac_No, Emp_Left, REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Emp_Left_Date
		--	, Present_Street [Working_Address], Present_City, Present_State, Present_Post_Box, Enroll_No, Inc_Qry.Emp_OT, Inc_Qry.Emp_Late_Mark
		--	, Inc_Qry.Emp_Full_PF, Inc_Qry.Emp_PT, Inc_Qry.Emp_Fix_Salary, Inc_Qry.Emp_Part_time, Inc_Qry.Late_Dedu_Type, Inc_Qry.Emp_Childran
		--	, Blood_Group, Religion, Height, Emp_Mark_Of_Identification, Despencery, Doctor_Name, DespenceryAddress, Insurance_No
		--	, REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') AS Emp_Confirm_Date, Father_name, DATEDIFF(MM,Date_Of_Join,@To_date) AS Work_Exp_Month
		--	, Inc_Qry.Wages_Type, Inc_Qry.Basic_salary, Inc_Qry.Gross_salary--,AR.Emp_Id, Ar.Company_ID
		--	, (SELECT SUP.Emp_Full_Name FROM dbo.T0080_EMP_MASTER SUP WHERE SUP.Emp_ID = E.Emp_Superior) AS manager
		--	, e.Old_Ref_No,e.dealer_code, ISNULL(ccm.Center_Name,'-') AS Cost_Center_Name, @Status AS Status, Inc_Qry.Branch_ID AS Branch_ID
		--	,(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age
		--	,(SELECT SUP.Alpha_Emp_Code FROM dbo.T0080_EMP_MASTER SUP WHERE SUP.Emp_ID = E.Emp_Superior) Manager_Code
		--	, SCM.Name As Salary_Cycle, BS.Segment_Name, VS.Vertical_Name		-- Added By Hiral 22 August, 2013
		--	, SV.SubVertical_Name, SB.SubBranch_Name							-- Added By Hiral 22 August, 2013
		--	,e.Emp_Dress_Code as Dress_Code -- Added By Ali 25032014
		--	,e.Emp_Shirt_Size as Shirt_Code -- Added By Ali 25032014
		--	,e.Emp_Pent_Size  as Pent_Code -- Added By Ali 25032014
		--	,e.Emp_Shoe_Size  as Shoe_Code -- Added By Ali 25032014
		--	,e.Emp_Canteen_Code as Canteen_Code -- Added By Ali 01042014
		--	,e.Extra_AB_Deduction --added by Hardik 02/08/2014
		--FROM dbo.T0080_EMP_MASTER E 
		--	INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
		--	INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
		--						, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
		--						, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
		--						, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID		-- Added By Hiral 22 August, 2013
		--					FROM T0095_INCREMENT 
		--						INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   --Changed by Hardik 10/09/2014 for Same Date Increment
		--										FROM T0095_INCREMENT  
		--										WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Company_ID 
		--										GROUP BY emp_ID
		--									) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_Id = Qry.Increment_Id   
		--					WHERE cmp_id = @Company_ID
		--				) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
		--	INNER JOIN T0040_GRADE_MASTER GM ON Inc_Qry.Grd_Id = GM.Grd_Id 
		--	INNER JOIN T0030_BRANCH_MASTER BM ON Inc_Qry.Branch_ID = BM.Branch_Id
		--	INNER JOIN T0040_DESIGNATION_MASTER DM ON Inc_Qry.Desig_Id = DM.Desig_Id
		--	LEFT OUTER JOIN T0040_BANK_MASTER BN ON Inc_Qry.Bank_id = BN.Bank_Id 
		--	LEFT OUTER JOIN T0040_TYPE_MASTER TM ON Inc_Qry.Type_Id = TM.Type_Id
		--	LEFT OUTER JOIN T0030_CATEGORY_MASTER CM ON Inc_Qry.Cat_id = CM.Cat_Id
		--	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DT ON Inc_Qry.Dept_Id = DT.Dept_Id
		--	--LEFT OUTER JOIN #Allowance_Record AR ON inc_Qry.Emp_id = AR.Emp_id
		--	LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM ON CCM.Center_ID = Inc_Qry.Center_ID
		--	LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM ON SCM.Tran_ID = Inc_Qry.SalDate_ID		-- Added By Hiral 22 August, 2013
		--	LEFT OUTER JOIN T0040_Business_Segment BS On BS.Segment_ID = Inc_Qry.Segment_ID			-- Added By Hiral 22 August, 2013
		--	LEFT OUTER JOIN T0040_Vertical_Segment VS On VS.Vertical_ID = Inc_Qry.Vertical_ID		-- Added By Hiral 22 August, 2013
		--	LEFT OUTER JOIN T0050_SubVertical SV On SV.SubVertical_ID =  Inc_Qry.SubVertical_ID		-- Added By Hiral 22 August, 2013
		--	LEFT OUTER JOIN T0050_SubBranch SB On SB.SubBranch_ID = Inc_Qry.SubBranch_ID			-- Added By Hiral 22 August, 2013
		--WHERE e.Cmp_ID = @Company_ID  
		--Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
		--	When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
		--		Else e.Alpha_Emp_Code
		--	End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)	
		--e.Emp_code   
	 SELECT Alpha_Emp_Code AS Emp_code,EDT.Cmp_ID,EDT.Row_ID,EDT.Emp_ID,EDT.Address,EDT.BirthDate,EDT.D_Age,EDT.Is_Resi,EDT.Name,EDT.NomineeFor,EDT.RelationShip,Inc_Qry.Branch_ID AS Branch_ID
		FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID 
			INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id, Curr_id, Wages_Type
								, Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No, Emp_OT, Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary
								, Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID
								, SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID		-- Added By Hiral 22 August, 2013
							FROM T0095_INCREMENT WITH (NOLOCK)
								INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   --Changed by Hardik 10/09/2014 for Same Date Increment
												FROM T0095_INCREMENT  WITH (NOLOCK)
												WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Company_ID 
												GROUP BY emp_ID
											) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_Id = Qry.Increment_Id   
							WHERE cmp_id = @Company_ID
						) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID 
			INNER JOIN T0090_EMP_DEPENDANT_DETAIL EDT WITH (NOLOCK) on ec.Emp_ID = EDT.Emp_ID
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id
		WHERE e.Cmp_ID = @Company_ID  
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End	
		

            
Return




