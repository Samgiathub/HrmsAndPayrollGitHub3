





CREATE VIEW [dbo].[V0080_Employee_Master_Coustomize_report]
AS
SELECT     E.Emp_ID, E.Cmp_ID, E.Emp_code, E.Emp_First_Name AS FIRST_NAME, E.Emp_Second_Name AS SECOND_NAME, 
                      E.Emp_Last_Name AS LAST_NAME, CAST(E.Date_Of_Join AS varchar(11)) AS Date_OF_JOIN, i.Basic_Salary, SM.Shift_Name AS SHIFT, 
                      DM.Dept_Name AS DEPARTMENT, E.Gender, TM.Type_Name AS STATUS, 
                      CASE E.Marital_Status WHEN '0' THEN 'Single' WHEN '1' THEN 'Married' WHEN '2' THEN 'Divorced' WHEN '3' THEN 'Psychology' WHEN '4' THEN 'Saperated'
                       ELSE 'Single' END AS MARITAL_STATUS, GM.Grd_Name AS GRADE, E.Emp_Full_Name AS FULL_NAME, E.Emp_Left, 
                      E.Work_Tel_No AS HOME_TELEPHONE, E.Mobile_No, CAST(E.Date_Of_Birth AS varchar(11)) AS DATE_OF_BIRTH, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name AS MANAGER_NAME, E.Emp_Superior, E.Present_City AS WORKING_TOWN, 
                      E.Present_State AS WORKING_REGION, E.Present_Post_Box AS WORKING_POSTBOX, E.Present_Street AS WORKING_ADDRESS, 
                      CAST(E.Emp_Left_Date AS Varchar(11)) AS LEFT_DATE, E.Other_Email AS PERSONAL_EMAIL, E.Work_Email AS WORKING_EMAIL, 
                      E.Home_Tel_no AS WORK_TELEPHONE, E.Zip_code AS PERMANENT_POSTBOX, E.State AS PERMANENT_REGION, E.City AS PERMANENT_TOWN, 
                      E.Street_1 AS PERMANENT_ADDRESS, E.Nationality, CAST(E.Dr_Lic_Ex_Date AS Varchar(11)) AS DRIVING_LICENSE_EXPIRY, E.Pan_No, 
                      E.Dr_Lic_No AS DRIVING_LICENSE, E.SIN_No AS ESIC_NO, E.SSN_No AS PF_NO, dbo.T0040_DESIGNATION_MASTER.Desig_Name AS DESIGNATION, 
                      dbo.T0010_COMPANY_MASTER.Cmp_Name AS COMPANY_NAME, BM.Branch_Name AS BRANCH, E.Image_Name, ISNULL(E.Enroll_No, 0) 
                      AS ENROLL_NO, E.Initial AS INITIAL_NAME, i.Gross_Salary, i.Emp_OT AS OT_APPLICABLE, i.Emp_OT_Min_Limit, i.Emp_OT_Max_Limit, 
                      i.Emp_Late_mark AS LATE_MARK_APPLICABLE, i.Emp_PT AS PT_APPLICABLE, i.Emp_Full_PF AS FULL_PF_APPLICABLE, 
                      i.Emp_Fix_Salary AS FIX_SALARY_APPLICABLE, i.Emp_Part_Time, i.Late_Dedu_Type, i.Emp_Late_Limit, i.Emp_PT_Amount AS PT_AMOUNT, 
                      i.Yearly_Bonus_Amount, i.Inc_Bank_AC_No AS BANK_ACOUNT_NO, i.Payment_Mode, i.Salary_Basis_On, i.Wages_Type, E.Blood_Group, E.Religion, 
                      E.Height, E.Emp_Mark_Of_Identification AS MARK_OF_IDENTIFICATION, E.Despencery, E.Doctor_Name, 
                      E.DespenceryAddress AS DESPENCERY_ADDRESS, E.Insurance_No, E.Is_Gr_App AS GRATUITY_APPLICABLE, 
                      E.Is_Yearly_Bonus AS YEARLY_BONUS_APPLICABLE, E.Yearly_Leave_Days, E.Yearly_Leave_Amount, CAST(E.Emp_Confirm_Date AS Varchar(11)) 
                      AS DATE_OF_CONFIRMATION, E.Is_On_Probation AS ON_PROBATION, E.Probation AS PROBATION_PERIOD, 
                      E.Yearly_Bonus_Per AS YEARLY_BONUS_PERCENTAGE, E.Shift_ID, E.Increment_ID
FROM         dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON E.Increment_ID = i.Increment_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER AS GM WITH (NOLOCK)  ON i.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON E.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
                      dbo.T0040_SHIFT_MASTER AS SM WITH (NOLOCK)  ON E.Shift_ID = SM.Shift_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON i.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK)  ON i.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON i.Branch_ID = BM.Branch_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON E.Emp_Superior = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER AS TM WITH (NOLOCK)  ON i.Type_ID = TM.Type_ID




