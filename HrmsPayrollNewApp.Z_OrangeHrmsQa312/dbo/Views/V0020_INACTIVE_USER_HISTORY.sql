




CREATE VIEW [dbo].[V0020_INACTIVE_USER_HISTORY]
AS
SELECT     i.History_Id, i.Cmp_Id, i.Emp_Id, i.Login_Id, i.Reason, i.System_Date, i.Active_Status, e.Emp_First_Name, e.Emp_Second_Name, e.Emp_Last_Name, e.Date_Of_Join, 
                      e.Basic_Salary, e.Shift_Name, e.Dept_Name, e.Gender, e.Type_Name, e.Marital_Status, e.Grd_Name, e.Emp_Full_Name_new, e.Emp_Full_Name, e.Emp_Left, 
                      e.Work_Tel_No, e.Mobile_No, e.Date_Of_Birth, e.Emp_Full_Name_Superior, e.Emp_Superior, e.Present_City, e.Present_State, e.Present_Post_Box, e.Present_Street, 
                      e.Emp_Left_Date, e.Other_Email, e.Work_Email, e.Home_Tel_no, e.Zip_code, e.State, e.City, e.Street_1, e.Nationality, e.Dr_Lic_Ex_Date, e.Pan_No, e.Dr_Lic_No, 
                      e.SIN_No, e.SSN_No, e.Desig_Id, e.Desig_Name, e.Def_ID, e.Cmp_Name, e.Dept_ID, e.Branch_Name, e.P_Other_Mail, e.P_Work_Mail, e.Grd_ID, e.Image_Name, 
                      e.Branch_ID, e.Enroll_No, e.Initial, e.Gross_Salary, e.Emp_OT, e.Emp_OT_Min_Limit, e.Emp_OT_Max_Limit, e.Emp_Late_mark, e.Emp_PT, e.Emp_Full_PF, 
                      e.Emp_Fix_Salary, e.Emp_Part_Time, e.Late_Dedu_Type, e.Emp_Late_Limit, e.Emp_PT_Amount, e.Yearly_Bonus_Amount, e.Inc_Bank_AC_No, e.Payment_Mode, 
                      e.Salary_Basis_On, e.Wages_Type, e.Bank_ID, e.Type_ID, e.Blood_Group, e.Religion, e.Height, e.Emp_Mark_Of_Identification, e.Despencery, e.Doctor_Name, 
                      e.DespenceryAddress, e.Insurance_No, e.Is_Gr_App, e.Is_Yearly_Bonus, e.Yearly_Leave_Days, e.Yearly_Leave_Amount, e.Emp_Confirm_Date, e.Is_On_Probation, 
                      e.Probation, e.Yearly_Bonus_Per, e.Shift_ID, e.Increment_ID, e.Parent_ID, e.Is_Main, e.Loc_name, e.Reg_Accept_Date, e.Loc_ID, e.Sup_Mobile_No, 
                      e.Alpha_Emp_Code, e.Alpha_Code, e.Old_Ref_No, e.Emp_code, e.Ifsc_Code, e.Bank_BSR, e.Leave_In_Probation
FROM         dbo.T0020_INACTIVE_USER_HISTORY AS i WITH (NOLOCK) INNER JOIN
                      dbo.V0080_Employee_Master AS e WITH (NOLOCK)  ON i.Emp_Id = e.Emp_ID



