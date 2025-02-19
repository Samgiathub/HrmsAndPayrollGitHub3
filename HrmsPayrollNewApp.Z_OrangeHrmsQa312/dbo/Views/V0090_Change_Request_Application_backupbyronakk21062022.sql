

Create VIEW [dbo].[V0090_Change_Request_Application_backupbyronakk21062022]
AS
SELECT     dbo.T0090_Change_Request_Application.Request_id, dbo.T0090_Change_Request_Application.Cmp_id, dbo.T0090_Change_Request_Application.Emp_ID, 
                      dbo.T0090_Change_Request_Application.Request_Type_id, 
                      CASE WHEN Request_status = 'P' THEN 'Pending' WHEN Request_status = 'A' THEN 'Approval' WHEN Request_status = 'R' THEN 'Reject' END AS Request_status, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0090_Change_Request_Application.Change_Reason, 
                      dbo.T0090_Change_Request_Application.Request_Date, dbo.T0080_EMP_MASTER.Emp_First_Name, IsNull(dbo.T0090_Change_Request_Application.Shift_From_Date, '1900-01-01') As Shift_From_Date, 
                      IsNull(dbo.T0090_Change_Request_Application.Shift_To_Date, '1900-01-01') As Shift_To_Date, dbo.T0090_Change_Request_Application.Curr_Details, dbo.T0090_Change_Request_Application.New_Details, 
                      dbo.T0090_Change_Request_Application.Curr_Tehsil, dbo.T0090_Change_Request_Application.Curr_District, dbo.T0090_Change_Request_Application.Curr_Thana, 
                      dbo.T0090_Change_Request_Application.Curr_City_Village, dbo.T0090_Change_Request_Application.Curr_State, dbo.T0090_Change_Request_Application.Curr_Pincode, 
                      dbo.T0090_Change_Request_Application.New_Tehsil, dbo.T0090_Change_Request_Application.New_District, dbo.T0090_Change_Request_Application.New_Thana, 
                      dbo.T0090_Change_Request_Application.New_City_Village, dbo.T0090_Change_Request_Application.New_State, dbo.T0090_Change_Request_Application.New_Pincode, 
                      dbo.T0090_Change_Request_Application.Request_status AS Status, dbo.T0040_Change_Request_Master.Request_type, dbo.T0090_Change_Request_Application.Quaulification_ID, 
                      dbo.T0090_Change_Request_Application.Specialization, dbo.T0090_Change_Request_Application.Passing_Year, IsNull(dbo.T0090_Change_Request_Application.Quaulification_Star_Date, '1900-01-01') As Quaulification_Star_Date, 
                      IsNull(dbo.T0090_Change_Request_Application.Quaulification_End_Date, '1900-01-01') As Quaulification_End_Date, dbo.T0090_Change_Request_Application.Score, dbo.T0090_Change_Request_Application.Dependant_Name, 
                      dbo.T0090_Change_Request_Application.Dependant_Gender, IsNull(dbo.T0090_Change_Request_Application.Dependant_DOB, '1900-01-01') As Dependant_DOB, dbo.T0090_Change_Request_Application.Dependant_Age, 
                      dbo.T0090_Change_Request_Application.Dependant_Relationship, dbo.T0090_Change_Request_Application.Dependant_Is_Resident, 
                      dbo.T0090_Change_Request_Application.Dependant_Is_Dependant, dbo.T0090_Change_Request_Application.Pass_Visa_Citizenship, dbo.T0090_Change_Request_Application.Pass_Visa_No, 
                      IsNull(dbo.T0090_Change_Request_Application.Pass_Visa_Issue_Date, '1900-01-01') As Pass_Visa_Issue_Date, IsNull(dbo.T0090_Change_Request_Application.Pass_Visa_Exp_Date, '1900-01-01') As Pass_Visa_Exp_Date, 
                      IsNull(dbo.T0090_Change_Request_Application.Pass_Visa_Review_Date, '1900-01-01') As Pass_Visa_Review_Date, dbo.T0090_Change_Request_Application.Pass_Visa_Status, dbo.T0090_Change_Request_Application.License_ID, 
                      dbo.T0090_Change_Request_Application.License_Type, IsNull(dbo.T0090_Change_Request_Application.License_IssueDate, '1900-01-01') As License_IssueDate, dbo.T0090_Change_Request_Application.License_No, 
                      IsNull(dbo.T0090_Change_Request_Application.License_ExpDate, '1900-01-01') As License_ExpDate, dbo.T0090_Change_Request_Application.License_Is_Expired, dbo.T0090_Change_Request_Application.Image_path, 
                      dbo.T0090_Change_Request_Application.Curr_IFSC_Code, dbo.T0090_Change_Request_Application.Curr_Account_No, dbo.T0090_Change_Request_Application.Curr_Branch_Name, 
                      dbo.T0090_Change_Request_Application.New_Account_No, dbo.T0090_Change_Request_Application.New_IFSC_Code, dbo.T0090_Change_Request_Application.New_Branch_Name, 
                      dbo.T0090_Change_Request_Application.Nominess_Address, dbo.T0090_Change_Request_Application.Nominess_Share, dbo.T0090_Change_Request_Application.Nominess_For, 
                      dbo.T0090_Change_Request_Application.Nominees_Row_ID, dbo.T0090_Change_Request_Application.Hospital_Name, dbo.T0090_Change_Request_Application.Hospital_Address, 
                      IsNull(dbo.T0090_Change_Request_Application.Admit_Date, '1900-01-01') As Admit_Date, dbo.T0090_Change_Request_Application.MediCalim_Approval_Amount, dbo.T0090_Change_Request_Application.Old_Pan_No, 
                      dbo.T0090_Change_Request_Application.New_Pan_No, dbo.T0090_Change_Request_Application.Old_Adhar_No, dbo.T0090_Change_Request_Application.New_Adhar_No, 
                      dbo.T0090_Change_Request_Application.Loan_Month, dbo.T0090_Change_Request_Application.Loan_Year,dbo.T0090_Change_Request_Application.Loan_Skip_Details,
                      dbo.T0040_Change_Request_Master.Flag,
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '-' + dbo.T0080_EMP_MASTER.Emp_Full_Name as Emp_Code_Name,
					  Convert(varchar(11),IsNull(dbo.T0090_Change_Request_Application.Child_Birth_Date, '1900-01-01'),103) AS Child_Birth_Date 	          
FROM         dbo.T0090_Change_Request_Application WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_Change_Request_Application.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0040_Change_Request_Master WITH (NOLOCK)  ON dbo.T0090_Change_Request_Application.Request_Type_id = dbo.T0040_Change_Request_Master.Request_id AND 
                      dbo.T0090_Change_Request_Application.Cmp_id = dbo.T0040_Change_Request_Master.Cmp_ID




