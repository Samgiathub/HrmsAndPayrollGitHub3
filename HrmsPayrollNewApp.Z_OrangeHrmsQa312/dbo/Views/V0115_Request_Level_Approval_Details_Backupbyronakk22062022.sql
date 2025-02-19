






Create VIEW [dbo].[V0115_Request_Level_Approval_Details_Backupbyronakk22062022]
AS
SELECT     CRA.Request_id, CRA.Cmp_id, CRA.Emp_ID, CRA.Request_Type_id, CRA.Change_Reason, CRA.Request_Date, 0 AS is_Final_Approved, qry.S_Emp_Id AS S_Emp_ID_A, CRM.Request_type, 
                      EM.Alpha_Emp_Code, EM.Emp_Full_Name, qry.Tran_id, qry.Shift_From_Date, qry.Shift_To_Date, qry.Curr_Details, qry.New_Details, qry.Curr_Tehsil, qry.Curr_District, qry.Curr_Thana, 
                      qry.Curr_City_Village, qry.Curr_State, qry.Curr_Pincode, qry.New_Tehsil, qry.New_District, qry.New_Thana, qry.New_City_Village, qry.New_State, qry.New_Pincode, qry.Request_Apr_Date, 
                      qry.Effective_Date, qry.Quaulification_ID, qry.Specialization, qry.Passing_Year, qry.Score, qry.Quaulification_Star_Date, qry.Quaulification_End_Date, qry.Dependant_Name, qry.Dependant_Gender,
                       qry.Dependant_DOB, qry.Dependant_Age, qry.Dependant_Relationship, qry.Dependant_Is_Resident, qry.Dependant_Is_Dependant, qry.Pass_Visa_No, qry.Pass_Visa_Issue_Date, 
                      qry.Pass_Visa_Exp_Date, qry.Pass_Visa_Review_Date, qry.Pass_Visa_Citizenship, qry.Pass_Visa_Status, qry.License_ID, qry.License_Type, qry.License_IssueDate, qry.License_No, 
                      qry.License_ExpDate, qry.License_Is_Expired, qry.Image_path, qry.Curr_IFSC_Code, qry.Curr_Account_No, qry.Curr_Branch_Name, qry.New_Account_No, qry.New_Branch_Name, 
                      qry.New_IFSC_Code, qry.Nominess_Address, qry.Nominess_Share, qry.Nominess_For, qry.Nominees_Row_ID, qry.Hospital_Name, qry.Hospital_Address, qry.Admit_Date, 
                      qry.MediCalim_Approval_Amount, qry.Old_Pan_No, qry.New_Pan_No, qry.Old_Adhar_No, qry.New_Adhar_No, qry.Loan_Month, qry.Loan_Year,
                      EM.Alpha_Emp_Code +'-' + EM.Emp_Full_Name as Emp_Code_Name,
                      Convert(varchar(11),qry.Child_Birth_Date,103) As Child_Birth_Date,qry.Request_Apr_Status
FROM         dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK) INNER JOIN
                      dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID INNER JOIN
                          (SELECT     RLA.Request_id, RLA.S_Emp_Id, RLA.Tran_id, RLA.Shift_From_Date, RLA.Shift_To_Date, RLA.Curr_Details, RLA.New_Details, RLA.Curr_Tehsil, RLA.Curr_District, RLA.Curr_Thana, 
                                                   RLA.Curr_City_Village, RLA.Curr_State, RLA.Curr_Pincode, RLA.New_Tehsil, RLA.New_District, RLA.New_Thana, RLA.New_City_Village, RLA.New_State, RLA.New_Pincode, 
                                                   RLA.Request_Apr_Date, RLA.Effective_Date, RLA.Quaulification_ID, RLA.Specialization, RLA.Passing_Year, RLA.Score, RLA.Quaulification_Star_Date, RLA.Quaulification_End_Date, 
                                                   RLA.Dependant_Name, RLA.Dependant_Gender, RLA.Dependant_DOB, RLA.Dependant_Age, RLA.Dependant_Relationship, RLA.Dependant_Is_Resident, 
                                                   RLA.Dependant_Is_Dependant, RLA.Pass_Visa_Citizenship, RLA.Pass_Visa_No, RLA.Pass_Visa_Issue_Date, RLA.Pass_Visa_Exp_Date, RLA.Pass_Visa_Review_Date, 
                                                   RLA.Pass_Visa_Status, RLA.License_ID, RLA.License_Type, RLA.License_IssueDate, RLA.License_No, RLA.License_ExpDate, RLA.License_Is_Expired, RLA.Image_path, 
                                                   RLA.Curr_IFSC_Code, RLA.Curr_Account_No, RLA.Curr_Branch_Name, RLA.New_Account_No, RLA.New_IFSC_Code, RLA.New_Branch_Name, RLA.Nominess_Address, 
                                                   RLA.Nominess_Share, RLA.Nominess_For, RLA.Nominees_Row_ID, RLA.Hospital_Name, RLA.Hospital_Address, RLA.Admit_Date, RLA.MediCalim_Approval_Amount, RLA.Old_Pan_No, 
                                                   RLA.New_Pan_No, RLA.Old_Adhar_No, RLA.New_Adhar_No, RLA.Loan_Month, RLA.Loan_Year,RLA.Child_Birth_Date,rla.Request_Apr_Status
                            FROM          dbo.T0115_Request_Level_Approval AS RLA WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(Rpt_Level) AS Rpt_Level, Request_id
                                                         FROM          dbo.T0115_Request_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY Request_id) AS Qry_1 ON Qry_1.Rpt_Level = RLA.Rpt_Level AND Qry_1.Request_id = RLA.Request_id INNER JOIN
                                                   dbo.T0090_Change_Request_Application AS RA WITH (NOLOCK)  ON RA.Request_id = RLA.Request_id
                            WHERE      (RLA.Request_Apr_Status = 'A') OR
                                                   (RLA.Request_Apr_Status = 'R')) AS qry ON CRA.Request_id = qry.Request_id




