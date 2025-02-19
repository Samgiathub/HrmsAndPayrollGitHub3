

Create VIEW [dbo].[V0090_Change_Request_Approval_Admin_Backupbyronakk_23062022]
AS
SELECT     dbo.T0090_Change_Request_Approval.Cmp_id, dbo.T0090_Change_Request_Approval.Emp_ID, dbo.T0090_Change_Request_Approval.Request_Type_id, 
                      dbo.T0090_Change_Request_Approval.Change_Reason, 
                      --(Case when dbo.T0090_Change_Request_Application.Request_Date <> '' THEN dbo.T0090_Change_Request_Application.Request_Date ELSE T0090_Change_Request_Approval.Request_Date END) As Request_Date, 
					  --(Case when dbo.T0090_Change_Request_Application.Request_id > 0 THEN dbo.T0090_Change_Request_Application.Request_Date ELSE T0090_Change_Request_Approval.Request_Date END) As Request_Date,
					  dbo.T0090_Change_Request_Approval.Request_Date As Request_Date, -- Added by Niraj (16062022)
                      dbo.T0090_Change_Request_Approval.Effective_Date,
                      dbo.T0090_Change_Request_Approval.Request_Date As Request_Apr_Date, 
                      dbo.T0090_Change_Request_Approval.Shift_From_Date, dbo.T0090_Change_Request_Approval.Shift_To_Date, dbo.T0090_Change_Request_Approval.Curr_Details, 
                      dbo.T0090_Change_Request_Approval.New_Details, dbo.T0090_Change_Request_Approval.Curr_Tehsil, dbo.T0090_Change_Request_Approval.Curr_District, 
                      dbo.T0090_Change_Request_Approval.Curr_Thana, dbo.T0090_Change_Request_Approval.Curr_City_Village, dbo.T0090_Change_Request_Approval.Curr_State, 
                      dbo.T0090_Change_Request_Approval.Curr_Pincode, dbo.T0090_Change_Request_Approval.New_Tehsil, dbo.T0090_Change_Request_Approval.New_District, 
                      dbo.T0090_Change_Request_Approval.New_Thana, dbo.T0090_Change_Request_Approval.New_City_Village, dbo.T0090_Change_Request_Approval.New_State, 
                      dbo.T0090_Change_Request_Approval.New_Pincode, dbo.T0090_Change_Request_Approval.Request_status, dbo.T0090_Change_Request_Approval.Increment_ID, 
                      dbo.T0090_Change_Request_Approval.Increment_ID_old, dbo.T0090_Change_Request_Approval.Request_Apr_ID, dbo.T0040_Change_Request_Master.Request_type, 
                      dbo.T0090_Change_Request_Approval.Request_id, dbo.T0090_Change_Request_Approval.Quaulification_ID, dbo.T0090_Change_Request_Approval.Specialization, 
                      dbo.T0090_Change_Request_Approval.Passing_Year, dbo.T0090_Change_Request_Approval.Score, dbo.T0090_Change_Request_Approval.Quaulification_Star_Date, 
                      dbo.T0090_Change_Request_Approval.Quaulification_End_Date, dbo.T0090_Change_Request_Approval.Dependant_Name, dbo.T0090_Change_Request_Approval.Dependant_Gender, 
                      dbo.T0090_Change_Request_Approval.Dependant_DOB, dbo.T0090_Change_Request_Approval.Dependant_Age, dbo.T0090_Change_Request_Approval.Dependant_Relationship, 
                      dbo.T0090_Change_Request_Approval.Dependant_Is_Resident, dbo.T0090_Change_Request_Approval.Dependant_Is_Dependant, dbo.T0090_Change_Request_Approval.Pass_Visa_Citizenship, 
                      dbo.T0090_Change_Request_Approval.Pass_Visa_No, dbo.T0090_Change_Request_Approval.Pass_Visa_Issue_Date, dbo.T0090_Change_Request_Approval.Pass_Visa_Exp_Date, 
                      dbo.T0090_Change_Request_Approval.Pass_Visa_Review_Date, dbo.T0090_Change_Request_Approval.Pass_Visa_Status, dbo.T0090_Change_Request_Approval.License_ID, 
                      dbo.T0090_Change_Request_Approval.License_Type, dbo.T0090_Change_Request_Approval.License_IssueDate, dbo.T0090_Change_Request_Approval.License_No, 
                      dbo.T0090_Change_Request_Approval.License_ExpDate, dbo.T0090_Change_Request_Approval.License_Is_Expired, dbo.T0090_Change_Request_Approval.Image_path, 
                      dbo.T0090_Change_Request_Approval.Curr_IFSC_Code, dbo.T0090_Change_Request_Approval.Curr_Account_No, dbo.T0090_Change_Request_Approval.Curr_Branch_Name, 
                      dbo.T0090_Change_Request_Approval.New_IFSC_Code, dbo.T0090_Change_Request_Approval.New_Account_No, dbo.T0090_Change_Request_Approval.New_Branch_Name, 
                      dbo.T0090_Change_Request_Approval.Nominess_Address, dbo.T0090_Change_Request_Approval.Nominess_Share, dbo.T0090_Change_Request_Approval.Nominess_For, 
					  dbo.T0090_Change_Request_Approval.Nominees_Row_ID, dbo.T0090_Change_Request_Approval.Hospital_Name, dbo.T0090_Change_Request_Approval.Hospital_Address, 
                      dbo.T0090_Change_Request_Approval.Admit_Date, dbo.T0090_Change_Request_Approval.MediCalim_Approval_Amount, dbo.T0090_Change_Request_Approval.Old_Pan_No, 
                      dbo.T0090_Change_Request_Approval.Old_Adhar_No, dbo.T0090_Change_Request_Approval.New_Adhar_No, dbo.T0090_Change_Request_Approval.New_Pan_No
                      ,dbo.T0090_Change_Request_Approval.Loan_Month
                      ,dbo.T0090_Change_Request_Approval.Loan_Year
                      ,T0090_Change_Request_Approval.Child_Birth_Date
			FROM dbo.T0090_Change_Request_Approval WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_Change_Request_Approval.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0040_Change_Request_Master WITH (NOLOCK)  ON dbo.T0090_Change_Request_Approval.Request_Type_id = dbo.T0040_Change_Request_Master.Request_id AND 
                      dbo.T0090_Change_Request_Approval.Cmp_id = dbo.T0040_Change_Request_Master.Cmp_ID
                      LEFT Outer JOIN T0090_Change_Request_Application WITH (NOLOCK)  ON T0040_Change_Request_Master.Request_id = T0090_Change_Request_Application.Request_id




