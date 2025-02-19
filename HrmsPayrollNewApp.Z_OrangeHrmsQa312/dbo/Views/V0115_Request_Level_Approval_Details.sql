










CREATE VIEW [dbo].[V0115_Request_Level_Approval_Details]
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

					  ---------------------------------------------------------Added by ronakk 22062022 --------------------------------------------
					  ,isnull(qry.Dep_OccupationID,0) as Dep_OccupationID
					  ,ISNULL(qry.Dep_HobbyID,'') as Dep_HobbyID
					  ,ISNULL(qry.Dep_HobbyName,'') as Dep_HobbyName
					  ,ISNULL(qry.Dep_DepCompanyName,'') as Dep_DepCompanyName
					  ,ISNULL(qry.Dep_CmpCity,'') as Dep_CmpCity
					  ,ISNULL(qry.Dep_Standard_ID,0) as Dep_Standard_ID
					  ,ISNULL(qry.Dep_Shcool_College,'') as Dep_Shcool_College
					  ,ISNULL(qry.Dep_SchCity,'') as Dep_SchCity
					  ,ISNULL(qry.Dep_ExtraActivity,'') as Dep_ExtraActivity
                      					  
					

					
					 
					  ,isnull(qry.Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id
					  ,isnull(qry.Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name
					  ,isnull(qry.Emp_Hobby_id,'') as Emp_Hobby_id
					  ,isnull(qry.Emp_Hobby_Name,'') as Emp_Hobby_Name
					  ,isnull(qry.Emp_Fav_Food,'') as Emp_Fav_Food
					  ,isnull(qry.Emp_Fav_Restro,'') as Emp_Fav_Restro
					  ,isnull(qry.Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination
					  ,isnull(qry.Emp_Fav_Festival,'') as Emp_Fav_Festival
					  ,isnull(qry.Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson
					  ,isnull(qry.Emp_Fav_Singer,'') as Emp_Fav_Singer

					    ---------------------------------------------------------End by ronakk 22062022 --------------------------------------------

						 -----------------------------Added by ronakk 24062022-------------------------------
		              ,isnull(qry.Curr_Emp_Fav_Sport_id,'') as Curr_Emp_Fav_Sport_id
					  ,isnull(qry.Curr_Emp_Fav_Sport_Name,'') as Curr_Emp_Fav_Sport_Name
					  ,isnull(qry.Curr_Emp_Hobby_id,'') as Curr_Emp_Hobby_id
					  ,isnull(qry.Curr_Emp_Hobby_Name,'') as Curr_Emp_Hobby_Name
					  ,isnull(qry.Curr_Emp_Fav_Food,'') as Curr_Emp_Fav_Food
					  ,isnull(qry.Curr_Emp_Fav_Restro,'') as Curr_Emp_Fav_Restro
					  ,isnull(qry.Curr_Emp_Fav_Trv_Destination,'') as Curr_Emp_Fav_Trv_Destination
					  ,isnull(qry.Curr_Emp_Fav_Festival,'') as Curr_Emp_Fav_Festival
					  ,isnull(qry.Curr_Emp_Fav_SportPerson,'') as Curr_Emp_Fav_SportPerson
					  ,isnull(qry.Curr_Emp_Fav_Singer,'') as Curr_Emp_Fav_Singer


                        -----------------------------End by ronakk 24062022-------------------------------

						    ---------------------------------------------------Added by ronakk 27062022 --------------------------------------
					 ,isnull(qry.OtherHobby,'') as OtherHobby
					 ,isnull(qry.Dep_PancardNo,'') as Dep_PancardNo
					 ,isnull(qry.Dep_AdharcardNo,'') as Dep_AdharcardNo
					 ,isnull(qry.Dep_Height,'') as Dep_Height
					 ,isnull(qry.Dep_Weight,'') as Dep_Weight

					 ,isnull(qry.OtherSports,'') as OtherSports
				   ----------------------------------------------------End by ronakk 27062022 -----------------------------------------
				   ----------------------------------------Added by ronakk 06072022 --------------------------
					   ,isnull(qry.Curr_Dep_ID,0) as Curr_Dep_ID 
					   ,isnull(qry.Curr_Dep_Name,'') as Curr_Dep_Name  
					   ,isnull(qry.Curr_Dep_Gender,'') as Curr_Dep_Gender 
					   ,isnull(qry.Curr_Dep_DOB,'') as Curr_Dep_DOB
					   ,isnull(qry.Curr_Dep_CAGE,'0') as Curr_Dep_CAGE 
					   ,isnull(qry.Curr_Dep_Relationship,'') as Curr_Dep_Relationship 
					   ,isnull(qry.Curr_Dep_ISResi,0) as Curr_Dep_ISResi 
					   ,isnull(qry.Curr_Dep_ISDep,0) as Curr_Dep_ISDep 
					   ,isnull(qry.Curr_Dep_ImagePath,'') as Curr_Dep_ImagePath 
					   ,isnull(qry.Curr_Dep_PanCard,'') as Curr_Dep_PanCard
					   ,isnull(qry.Curr_Dep_AdharCard,'') as Curr_Dep_AdharCard 
					   ,isnull(qry.Curr_Dep_Height,'') as Curr_Dep_Height
					   ,isnull(qry.Curr_Dep_Weight,'') as Curr_Dep_Weight 
					   ,isnull(qry.Curr_Dep_OccupationID,0) as Curr_Dep_OccupationID 
					   ,isnull(qry.Curr_Dep_OccupationName,'') as  Curr_Dep_OccupationName 
					   ,isnull(qry.Curr_Dep_HobbyID ,'') as Curr_Dep_HobbyID
					   ,isnull(qry.Curr_Dep_HobbyName ,'') as Curr_Dep_HobbyName
					   ,isnull(qry.Curr_Dep_CompanyName,'') as Curr_Dep_CompanyName 
					   ,isnull(qry.Curr_Dep_CompanyCity ,'') as Curr_Dep_CompanyCity
					   ,isnull(qry.Curr_Dep_StandardID,0) as Curr_Dep_StandardID
					   ,isnull(qry.Curr_Dep_StandardName,'') as Curr_Dep_StandardName 
					   ,isnull(qry.Curr_Dep_SchCol,'') as Curr_Dep_SchCol 
					   ,isnull(qry.Curr_Dep_SchColCity,'') as Curr_Dep_SchColCity
					   ,isnull(qry.Curr_Dep_ExtraActivity,'') as Curr_Dep_ExtraActivity 
					------------------------------------------End  by ronakk 06072022 -------------------------
					  ,isnull(qry.Dep_Std_Specialization,'') as Dep_Std_Specialization			  --Added by ronakk 21072022
					  ,isnull(qry.Curr_Dep_Std_Specialization,'') as Curr_Dep_Std_Specialization --Added by ronakk 21072022


FROM         dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK) 
INNER JOIN dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id 
INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID 
INNER JOIN (SELECT     RLA.Request_id, RLA.S_Emp_Id, RLA.Tran_id, RLA.Shift_From_Date, RLA.Shift_To_Date, RLA.Curr_Details, RLA.New_Details, RLA.Curr_Tehsil, RLA.Curr_District, RLA.Curr_Thana, 
             RLA.Curr_City_Village, RLA.Curr_State, RLA.Curr_Pincode, RLA.New_Tehsil, RLA.New_District, RLA.New_Thana, RLA.New_City_Village, RLA.New_State, RLA.New_Pincode, 
             RLA.Request_Apr_Date, RLA.Effective_Date, RLA.Quaulification_ID, RLA.Specialization, RLA.Passing_Year, RLA.Score, RLA.Quaulification_Star_Date, RLA.Quaulification_End_Date, 
             RLA.Dependant_Name, RLA.Dependant_Gender, RLA.Dependant_DOB, RLA.Dependant_Age, RLA.Dependant_Relationship, RLA.Dependant_Is_Resident, 
             RLA.Dependant_Is_Dependant, RLA.Pass_Visa_Citizenship, RLA.Pass_Visa_No, RLA.Pass_Visa_Issue_Date, RLA.Pass_Visa_Exp_Date, RLA.Pass_Visa_Review_Date, 
             RLA.Pass_Visa_Status, RLA.License_ID, RLA.License_Type, RLA.License_IssueDate, RLA.License_No, RLA.License_ExpDate, RLA.License_Is_Expired, RLA.Image_path, 
             RLA.Curr_IFSC_Code, RLA.Curr_Account_No, RLA.Curr_Branch_Name, RLA.New_Account_No, RLA.New_IFSC_Code, RLA.New_Branch_Name, RLA.Nominess_Address, 
             RLA.Nominess_Share, RLA.Nominess_For, RLA.Nominees_Row_ID, RLA.Hospital_Name, RLA.Hospital_Address, RLA.Admit_Date, RLA.MediCalim_Approval_Amount, RLA.Old_Pan_No, 
             RLA.New_Pan_No, RLA.Old_Adhar_No, RLA.New_Adhar_No, RLA.Loan_Month, RLA.Loan_Year,RLA.Child_Birth_Date,rla.Request_Apr_Status
			 ----------Added by ronakk 22062022 ---------------------
			 ,RLA.Dep_OccupationID
			 ,RLA.Dep_HobbyID
			 ,RLA.Dep_HobbyName
			 ,RLA.Dep_DepCompanyName
			 ,RLA.Dep_CmpCity
			 ,RLA.Dep_Standard_ID
			 ,RLA.Dep_Shcool_College
			 ,RLA.Dep_SchCity
			 ,RLA.Dep_ExtraActivity

			 ,RLA.Emp_Fav_Sport_id
			 ,RLA.Emp_Fav_Sport_Name
			 ,RLA.Emp_Hobby_id
			 ,RLA.Emp_Hobby_Name
			 ,RLA.Emp_Fav_Food
			 ,RLA.Emp_Fav_Restro
			 ,RLA.Emp_Fav_Trv_Destination
			 ,RLA.Emp_Fav_Festival
			 ,RLA.Emp_Fav_SportPerson
			 ,RLA.Emp_Fav_Singer
			 -----------End by ronakk 22062022 ----------------------
			 -----------------------------Added by ronakk 24062022-------------------------------
			 ,RLA.Curr_Emp_Fav_Sport_id
			 ,RLA.Curr_Emp_Fav_Sport_Name
			 ,RLA.Curr_Emp_Hobby_id
			 ,RLA.Curr_Emp_Hobby_Name
			 ,RLA.Curr_Emp_Fav_Food
			 ,RLA.Curr_Emp_Fav_Restro
			 ,RLA.Curr_Emp_Fav_Trv_Destination
			 ,RLA.Curr_Emp_Fav_Festival
			 ,RLA.Curr_Emp_Fav_SportPerson
			 ,RLA.Curr_Emp_Fav_Singer
              -----------------------------End by ronakk 24062022-------------------------------

			-------------------------------------Added by ronakk 27062022 -------------------------------------
			,RLA.OtherHobby
			,RLA.Dep_PancardNo
			,RLA.Dep_AdharcardNo
			,RLA.Dep_Height
			,RLA.Dep_Weight
			
			,RLA.OtherSports


			-------------------------------------End by ronakk 27062022 -------------------------------------
			---------------------------------------Add  by ronakk 06072022 -----------------------------------
			 ,RLA.Curr_Dep_ID 
			 ,RLA.Curr_Dep_Name 
			 ,RLA.Curr_Dep_Gender 
			 ,RLA.Curr_Dep_DOB
			 ,RLA.Curr_Dep_CAGE 
			 ,RLA.Curr_Dep_Relationship 
			 ,RLA.Curr_Dep_ISResi 
			 ,RLA.Curr_Dep_ISDep 
			 ,RLA.Curr_Dep_ImagePath 
			 ,RLA.Curr_Dep_PanCard
			 ,RLA.Curr_Dep_AdharCard 
			 ,RLA.Curr_Dep_Height 
			 ,RLA.Curr_Dep_Weight 
			 ,RLA.Curr_Dep_OccupationID 
			 ,RLA.Curr_Dep_OccupationName 
			 ,RLA.Curr_Dep_HobbyID 
			 ,RLA.Curr_Dep_HobbyName 
			 ,RLA.Curr_Dep_CompanyName 
			 ,RLA.Curr_Dep_CompanyCity 
			 ,RLA.Curr_Dep_StandardID
			 ,RLA.Curr_Dep_StandardName 
			 ,RLA.Curr_Dep_SchCol 
			 ,RLA.Curr_Dep_SchColCity
			 ,RLA.Curr_Dep_ExtraActivity
			 ---------------------------------------End  by ronakk 06072022 -----------------------------------
			 ,RLA.Dep_Std_Specialization	  --Added by ronakk 21072022
			 ,RLA.Curr_Dep_Std_Specialization --Added by ronakk 21072022


             FROM          dbo.T0115_Request_Level_Approval AS RLA WITH (NOLOCK)  
			 INNER JOIN(SELECT  MAX(Rpt_Level) AS Rpt_Level, Request_id FROM  dbo.T0115_Request_Level_Approval WITH (NOLOCK) 
			             GROUP BY Request_id) AS Qry_1 ON Qry_1.Rpt_Level = RLA.Rpt_Level AND Qry_1.Request_id = RLA.Request_id 
			 INNER JOIN dbo.T0090_Change_Request_Application AS RA WITH (NOLOCK)  ON RA.Request_id = RLA.Request_id
			 WHERE  (RLA.Request_Apr_Status = 'A') OR (RLA.Request_Apr_Status = 'R')) AS qry ON CRA.Request_id = qry.Request_id




