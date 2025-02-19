

Create VIEW [dbo].[V0090_Change_Request_Admin_Backupbyronakk23062022]
AS
SELECT     T.Request_Apr_id, T.Cmp_id, T.Emp_ID, T.Request_Type_id, T.Change_Reason, T.Request_Date, T.is_Final_Approved, T.S_Emp_ID_A, T.Request_type, T.Alpha_Emp_Code, T.Emp_Full_Name, 
                      T.Tran_id, T.Shift_From_Date, T.Shift_To_Date, T.Curr_Details, T.New_Details, T.Curr_Tehsil, T.Curr_District, T.Curr_Thana, T.Curr_City_Village, T.Curr_State, T.Curr_Pincode, T.New_Tehsil, 
                      T.New_District, T.New_Thana, T.New_City_Village, T.New_State, T.New_Pincode, T.Request_Apr_Date, T.Effective_Date, T.Quaulification_ID, T.Specialization, T.Passing_Year, T.Score, 
                      T.Quaulification_Star_Date, T.Quaulification_End_Date, T.Dependant_Name, T.Dependant_Gender, T.Dependant_DOB, T.Dependant_Age, T.Dependant_Relationship, T.Dependant_Is_Resident, 
                      T.Dependant_Is_Dependant, T.Pass_Visa_No, T.Pass_Visa_Issue_Date, T.Pass_Visa_Exp_Date, T.Pass_Visa_Review_Date, T.Pass_Visa_Citizenship, T.Pass_Visa_Status, T.License_ID, 
                      T.License_Type, T.License_IssueDate, T.License_No, T.License_ExpDate, T.License_Is_Expired, T.Request_status, T.Emp_First_Name, T.Image_path, B.Branch_ID, B.Vertical_ID, B.SubVertical_ID,
                       B.Dept_ID, T.Nominess_Address, T.Nominess_Share, T.Nominess_For, T.Nominees_Row_ID, T.Hospital_Name, T.Hospital_Address, T.Admit_Date, T.MediCalim_Approval_Amount
                       ,T.Old_Pan_No,T.Old_Adhar_No,T.New_Pan_No,T.New_Adhar_No,T.Loan_Month,T.Loan_Year
                       ,T.Curr_IFSC_Code,T.Curr_Account_No,T.Curr_Branch_Name,T.New_IFSC_Code,T.New_Account_No,T.New_Branch_Name
                       ,isnull(T.Child_Birth_Date,'') as Child_Birth_Date
FROM         (SELECT     CRA.Request_id AS Request_Apr_id, CRA.Cmp_id, CRA.Emp_ID, CRA.Request_Type_id, CRA.Change_Reason, CRA.Request_Date, 0 AS is_Final_Approved, 
                                              qry.S_Emp_Id AS S_Emp_ID_A, CRM.Request_type, EM.Alpha_Emp_Code, EM.Emp_Full_Name, qry.Tran_id, qry.Shift_From_Date, qry.Shift_To_Date, qry.Curr_Details, qry.New_Details, 
                                              qry.Curr_Tehsil, qry.Curr_District, qry.Curr_Thana, qry.Curr_City_Village, qry.Curr_State, qry.Curr_Pincode, qry.New_Tehsil, qry.New_District, qry.New_Thana, qry.New_City_Village, 
                                              qry.New_State, qry.New_Pincode, qry.Request_Apr_Date, qry.Effective_Date, qry.Quaulification_ID, qry.Specialization, qry.Passing_Year, qry.Score, qry.Quaulification_Star_Date, 
                                              qry.Quaulification_End_Date, qry.Dependant_Name, qry.Dependant_Gender, qry.Dependant_DOB, qry.Dependant_Age, qry.Dependant_Relationship, qry.Dependant_Is_Resident, 
                                              qry.Dependant_Is_Dependant, qry.Pass_Visa_No, qry.Pass_Visa_Issue_Date, qry.Pass_Visa_Exp_Date, qry.Pass_Visa_Review_Date, qry.Pass_Visa_Citizenship, 
                                              qry.Pass_Visa_Status, qry.License_ID, qry.License_Type, qry.License_IssueDate, qry.License_No, qry.License_ExpDate, qry.License_Is_Expired, 
                                              (CASE WHEN CRA.Request_status = 'A' THEN 'Approved' WHEN CRA.Request_status = 'R' THEN 'Rejected' WHEN CRA.Request_status = 'P' THEN 'Pending' END) AS Request_status, 
                                              -- WHEN CRA.Request_status = 'P' THEN 'Approved' due to AIA Client Default select Approved instead of none on 14102016
                                              EM.Emp_First_Name, '' AS Image_path, qry.Nominess_Address, qry.Nominess_Share, qry.Nominess_For, qry.Nominees_Row_ID, qry.Hospital_Name, qry.Hospital_Address, 
                                              qry.Admit_Date, qry.MediCalim_Approval_Amount
                                              ,qry.Old_Pan_No,qry.Old_Adhar_No,qry.New_Pan_No,qry.New_Adhar_No
                                              ,qry.Loan_Month,qry.Loan_Year
                                              ,qry.Curr_IFSC_Code,qry.Curr_Account_No,qry.Curr_Branch_Name,qry.New_IFSC_Code,qry.New_Account_No,qry.New_Branch_Name
                                              ,qry.Child_Birth_Date
                       FROM          dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK) INNER JOIN
                                              dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id AND CRA.Cmp_id = CRM.Cmp_ID INNER JOIN
                                              dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID INNER JOIN
                                                  (SELECT     RLA.Request_id, RLA.S_Emp_Id, RLA.Tran_id, RLA.Shift_From_Date, RLA.Shift_To_Date, RLA.Curr_Details, RLA.New_Details, RLA.Curr_Tehsil, RLA.Curr_District, 
                                                                           RLA.Curr_Thana, RLA.Curr_City_Village, RLA.Curr_State, RLA.Curr_Pincode, RLA.New_Tehsil, RLA.New_District, RLA.New_Thana, RLA.New_City_Village, RLA.New_State, 
                                                                           RLA.New_Pincode, RLA.Request_Apr_Date, RLA.Effective_Date, RLA.Quaulification_ID, RLA.Specialization, RLA.Passing_Year, RLA.Score, RLA.Quaulification_Star_Date, 
                                                                           RLA.Quaulification_End_Date, RLA.Dependant_Name, RLA.Dependant_Gender, RLA.Dependant_DOB, RLA.Dependant_Age, RLA.Dependant_Relationship, 
                                                                           RLA.Dependant_Is_Resident, RLA.Dependant_Is_Dependant, RLA.Pass_Visa_Citizenship, RLA.Pass_Visa_No, RLA.Pass_Visa_Issue_Date, RLA.Pass_Visa_Exp_Date, 
                                                                           RLA.Pass_Visa_Review_Date, RLA.Pass_Visa_Status, RLA.License_ID, RLA.License_Type, RLA.License_IssueDate, RLA.License_No, RLA.License_ExpDate, 
                                                                           RLA.License_Is_Expired, RLA.Nominess_Address, RLA.Nominess_Share, RLA.Nominess_For, RLA.Nominees_Row_ID, RLA.Hospital_Name, RLA.Hospital_Address, 
                                                                           RLA.Admit_Date, RLA.MediCalim_Approval_Amount
                                                                           ,RLA.Old_Pan_No,RLA.Old_Adhar_No,RLA.New_Pan_No,RLA.New_Adhar_No
                                                                           ,RLA.Loan_Month,RLA.Loan_Year
                                                                           ,rla.Curr_IFSC_Code,RlA.Curr_Account_No,RLA.Curr_Branch_Name,RLA.New_IFSC_Code,RLA.New_Account_No,RLA.New_Branch_Name,
                                                                           RLA.Child_Birth_Date
                                                    FROM          dbo.T0115_Request_Level_Approval AS RLA  WITH (NOLOCK) INNER JOIN
                                                                               (SELECT     MAX(Rpt_Level) AS Rpt_Level, Request_id
                                                                                 FROM          dbo.T0115_Request_Level_Approval WITH (NOLOCK) 
                                                                                 GROUP BY Request_id) AS Qry_1 ON Qry_1.Rpt_Level = RLA.Rpt_Level AND Qry_1.Request_id = RLA.Request_id INNER JOIN
                                                                           dbo.T0090_Change_Request_Application AS RA WITH (NOLOCK)  ON RA.Request_id = RLA.Request_id
                                                    WHERE      (RLA.Request_Apr_Status = 'A') OR
                                                                           (RLA.Request_Apr_Status = 'R')) AS qry ON CRA.Request_id = qry.Request_id
                       WHERE      (CRA.Request_status = 'P')
            UNION
                       SELECT     CRA.Request_id AS Request_Apr_id, CRA.Cmp_id, CRA.Emp_ID, CRA.Request_Type_id, CRA.Change_Reason, CRA.Request_Date, 0 AS is_Final_Approved, CRA.Emp_ID AS S_Emp_ID_A, 
                                             CRM.Request_type, EM.Alpha_Emp_Code, EM.Emp_Full_Name, 0 AS Tran_id, CRA.Shift_From_Date, CRA.Shift_To_Date, CRA.Curr_Details, CRA.New_Details, CRA.Curr_Tehsil, 
                                             CRA.Curr_District, CRA.Curr_Thana, CRA.Curr_City_Village, CRA.Curr_State, CRA.Curr_Pincode, CRA.New_Tehsil, CRA.New_District, CRA.New_Thana, CRA.New_City_Village, 
                                             CRA.New_State, CRA.New_Pincode, CRA.Request_Date AS Request_Apr_Date, CRA.Request_Date AS Effective_Date, CRA.Quaulification_ID, CRA.Specialization, CRA.Passing_Year, CRA.Score, 
                                             CRA.Quaulification_Star_Date, CRA.Quaulification_End_Date, CRA.Dependant_Name, CRA.Dependant_Gender, CRA.Dependant_DOB, CRA.Dependant_Age, CRA.Dependant_Relationship, 
                                             CRA.Dependant_Is_Resident, CRA.Dependant_Is_Dependant, CRA.Pass_Visa_No, CRA.Pass_Visa_Issue_Date, CRA.Pass_Visa_Exp_Date, CRA.Pass_Visa_Review_Date, 
                                             CRA.Pass_Visa_Citizenship, CRA.Pass_Visa_Status, CRA.License_ID, CRA.License_Type, CRA.License_IssueDate, CRA.License_No, CRA.License_ExpDate, CRA.License_Is_Expired, 
                                             (CASE WHEN CRA.Request_status = 'A' THEN 'Approved' WHEN CRA.Request_status = 'R' THEN 'Rejected' WHEN CRA.Request_status = 'P' THEN 'Pending' END) AS Request_status, 
                                             -- WHEN CRA.Request_status = 'P' THEN 'Approved' due to AIA Client Default select Approved instead of none on 14102016
                                             EM.Emp_First_Name, CRA.Image_path, CRA.Nominess_Address, CRA.Nominess_Share, CRA.Nominess_For, CRA.Nominees_Row_ID, CRA.Hospital_Name, CRA.Hospital_Address, 
                                             CRA.Admit_Date, CRA.MediCalim_Approval_Amount
                                             ,CRA.Old_Pan_No,CRA.Old_Adhar_No,CRA.New_Pan_No,CRA.New_Adhar_No,CRA.Loan_Month,CRA.Loan_Year
                                             ,cra.Curr_IFSC_Code,CRA.Curr_Account_No,CRA.Curr_Branch_Name,CRA.New_IFSC_Code,CRA.New_Account_No,CRA.New_Branch_Name,
                                             CRA.Child_Birth_Date
                       FROM         dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK)  INNER JOIN
                                             dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id AND CRA.Cmp_id = CRM.Cmp_ID INNER JOIN
                                             dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID
                       WHERE     (CRA.Request_status = 'P') AND (CRA.Request_id NOT IN
                                                 (SELECT     CRA.Request_id
                                                   FROM          dbo.T0115_Request_Level_Approval AS RLA WITH (NOLOCK) 
                                                   WHERE      (Request_id = CRA.Request_id) AND (Emp_ID = CRA.Emp_ID)))) AS T LEFT OUTER JOIN
                          (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID
                            FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK) 
                            WHERE      (Increment_ID =
                                                       (SELECT     TOP (1) Increment_ID
                                                         FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK) 
                                                         WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
                                                         ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = T.Emp_ID AND B.Cmp_ID = T.Cmp_id




