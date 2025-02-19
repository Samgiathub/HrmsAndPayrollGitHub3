



/****** Object:  View dbo.V0080_Employee_Details    Script Date: 12/10/2010 5:16:31 AM ******/
CREATE VIEW [dbo].[V0080_Employee_Details]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Cmp_ID, dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0080_EMP_MASTER.Cat_ID, 
                      dbo.T0080_EMP_MASTER.Grd_ID, dbo.T0080_EMP_MASTER.Dept_ID, dbo.T0080_EMP_MASTER.Desig_Id, dbo.T0080_EMP_MASTER.Type_ID, 
                      dbo.T0080_EMP_MASTER.Shift_ID, dbo.T0080_EMP_MASTER.Bank_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Initial, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Second_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name, 
                      dbo.T0080_EMP_MASTER.Curr_ID, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0080_EMP_MASTER.SSN_No, dbo.T0080_EMP_MASTER.SIN_No, 
                      dbo.T0080_EMP_MASTER.Dr_Lic_No, dbo.T0080_EMP_MASTER.Pan_No, dbo.T0080_EMP_MASTER.Date_Of_Birth, 
                      dbo.T0080_EMP_MASTER.Marital_Status, dbo.T0080_EMP_MASTER.Gender, dbo.T0080_EMP_MASTER.Dr_Lic_Ex_Date, 
                      dbo.T0080_EMP_MASTER.Nationality, dbo.T0080_EMP_MASTER.Loc_ID, dbo.T0080_EMP_MASTER.Street_1, dbo.T0080_EMP_MASTER.City, 
                      dbo.T0080_EMP_MASTER.State, dbo.T0080_EMP_MASTER.Zip_code, dbo.T0080_EMP_MASTER.Home_Tel_no, dbo.T0080_EMP_MASTER.Mobile_No, 
                      dbo.T0080_EMP_MASTER.Work_Tel_No, dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Other_Email, 
                      T0080_EMP_MASTER.Basic_Salary,
                       dbo.T0080_EMP_MASTER.Image_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Left, dbo.T0080_EMP_MASTER.Emp_Left_Date, dbo.T0080_EMP_MASTER.Increment_ID, 
                      dbo.T0080_EMP_MASTER.Present_Street, dbo.T0080_EMP_MASTER.Present_City, dbo.T0080_EMP_MASTER.Present_State, 
                      dbo.T0080_EMP_MASTER.Present_Post_Box, dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0080_EMP_MASTER.Enroll_No, 
                      dbo.T0080_EMP_MASTER.Blood_Group, dbo.T0080_EMP_MASTER.Tally_Led_Name, dbo.T0080_EMP_MASTER.Religion, 
                      dbo.T0080_EMP_MASTER.Height, dbo.T0080_EMP_MASTER.Emp_Mark_Of_Identification, dbo.T0080_EMP_MASTER.Despencery, 
                      dbo.T0080_EMP_MASTER.Doctor_Name, dbo.T0080_EMP_MASTER.DespenceryAddress, dbo.T0080_EMP_MASTER.Insurance_No, 
                      dbo.T0080_EMP_MASTER.Is_Gr_App, dbo.T0080_EMP_MASTER.Is_Yearly_Bonus, dbo.T0080_EMP_MASTER.Yearly_Leave_Days, 
                      dbo.T0080_EMP_MASTER.Yearly_Leave_Amount, dbo.T0080_EMP_MASTER.Yearly_Bonus_Per, dbo.T0080_EMP_MASTER.Yearly_Bonus_Amount, 
                      dbo.T0080_EMP_MASTER.Emp_Confirm_Date, dbo.T0080_EMP_MASTER.IS_Emp_FNF, dbo.T0080_EMP_MASTER.Is_On_Probation, 
                      dbo.T0080_EMP_MASTER.Tally_Led_ID, dbo.T0080_EMP_MASTER.Login_ID, dbo.T0080_EMP_MASTER.System_Date, 
                      dbo.T0080_EMP_MASTER.Probation, dbo.T0080_EMP_MASTER.Worker_Adult_No, dbo.T0080_EMP_MASTER.Father_name, 
                      dbo.T0080_EMP_MASTER.Bank_BSR, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0001_LOCATION_MASTER.Loc_name, 
                      dbo.T0080_EMP_MASTER.Alpha_Code, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Old_Ref_No
FROM         dbo.T0030_BRANCH_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.Branch_ID = dbo.T0080_EMP_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Loc_ID = dbo.T0001_LOCATION_MASTER.Loc_ID




