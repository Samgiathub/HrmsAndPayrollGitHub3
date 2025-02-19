





/*Added By Jaina 08-09-2015 End*/
CREATE VIEW [dbo].[V0090_Change_Request_Admin]
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

					       -----------------------------------------------Added by ronakk 23062022 -------------------------------------------------
					  ,isnull(T.Dep_OccupationID,0) as Dep_OccupationID
					  ,ISNULL(T.Dep_HobbyID,'') as Dep_HobbyID
					  ,ISNULL(T.Dep_HobbyName,'') as Dep_HobbyName
					  ,ISNULL(T.Dep_DepCompanyName,'') as Dep_DepCompanyName
					  ,ISNULL(T.Dep_CmpCity,'') as Dep_CmpCity
					  ,ISNULL(T.Dep_Standard_ID,0) as Dep_Standard_ID
					  ,ISNULL(T.Dep_Shcool_College,'') as Dep_Shcool_College
					  ,ISNULL(T.Dep_SchCity,'') as Dep_SchCity
					  ,ISNULL(T.Dep_ExtraActivity,'') as Dep_ExtraActivity

					  ,isnull(T.Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id
					  ,isnull(T.Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name
					  ,isnull(T.Emp_Hobby_id,'') as Emp_Hobby_id
					  ,isnull(T.Emp_Hobby_Name,'') as Emp_Hobby_Name
					  ,isnull(T.Emp_Fav_Food,'') as Emp_Fav_Food
					  ,isnull(T.Emp_Fav_Restro,'') as Emp_Fav_Restro
					  ,isnull(T.Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination
					  ,isnull(T.Emp_Fav_Festival,'') as Emp_Fav_Festival
					  ,isnull(T.Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson
					  ,isnull(T.Emp_Fav_Singer,'') as Emp_Fav_Singer

					    ---------------------------------------------------------End by ronakk 23062022 --------------------------------------------
						 ---------------------------------------------------------Added by ronakk 24062022 --------------------------------------------
					 
					  ,isnull(T.Curr_Emp_Fav_Sport_id,'') as Curr_Emp_Fav_Sport_id
					  ,isnull(T.Curr_Emp_Fav_Sport_Name,'') as Curr_Emp_Fav_Sport_Name
					  ,isnull(T.Curr_Emp_Hobby_id,'') as Curr_Emp_Hobby_id
					  ,isnull(T.Curr_Emp_Hobby_Name,'') as Curr_Emp_Hobby_Name
					  ,isnull(T.Curr_Emp_Fav_Food,'') as Curr_Emp_Fav_Food
					  ,isnull(T.Curr_Emp_Fav_Restro,'') as Curr_Emp_Fav_Restro
					  ,isnull(T.Curr_Emp_Fav_Trv_Destination,'') as Curr_Emp_Fav_Trv_Destination
					  ,isnull(T.Curr_Emp_Fav_Festival,'') as Curr_Emp_Fav_Festival
					  ,isnull(T.Curr_Emp_Fav_SportPerson,'') as Curr_Emp_Fav_SportPerson
					  ,isnull(T.Curr_Emp_Fav_Singer,'') as Curr_Emp_Fav_Singer

					---------------------------------------------------------End by ronakk 24062022 --------------------------------------------

				     ---------------------------------------------------Added by ronakk 29062022 --------------------------------------
					 ,isnull(T.OtherHobby,'') as OtherHobby
					 ,isnull(T.Dep_PancardNo,'') as Dep_PancardNo
					 ,isnull(T.Dep_AdharcardNo,'') as Dep_AdharcardNo
					 ,isnull(T.Dep_Height,'') as Dep_Height
					 ,isnull(T.Dep_Weight,'') as Dep_Weight

					 ,isnull(T.OtherSports,'') as OtherSports
				   ----------------------------------------------------End by ronakk 29062022 -----------------------------------------


				     ----------------------------------------Added by ronakk 06072022 --------------------------
					   ,isnull(T.Curr_Dep_ID,0) as Curr_Dep_ID 
					   ,isnull(T.Curr_Dep_Name,'') as Curr_Dep_Name  
					   ,isnull(T.Curr_Dep_Gender,'') as Curr_Dep_Gender 
					   ,isnull(T.Curr_Dep_DOB,'') as Curr_Dep_DOB
					   ,isnull(T.Curr_Dep_CAGE,'0') as Curr_Dep_CAGE 
					   ,isnull(T.Curr_Dep_Relationship,'') as Curr_Dep_Relationship 
					   ,isnull(T.Curr_Dep_ISResi,0) as Curr_Dep_ISResi 
					   ,isnull(T.Curr_Dep_ISDep,0) as Curr_Dep_ISDep 
					   ,isnull(T.Curr_Dep_ImagePath,'') as Curr_Dep_ImagePath 
					   ,isnull(T.Curr_Dep_PanCard,'') as Curr_Dep_PanCard
					   ,isnull(T.Curr_Dep_AdharCard,'') as Curr_Dep_AdharCard 
					   ,isnull(T.Curr_Dep_Height,'') as Curr_Dep_Height
					   ,isnull(T.Curr_Dep_Weight,'') as Curr_Dep_Weight 
					   ,isnull(T.Curr_Dep_OccupationID,0) as Curr_Dep_OccupationID 
					   ,isnull(T.Curr_Dep_OccupationName,'') as  Curr_Dep_OccupationName 
					   ,isnull(T.Curr_Dep_HobbyID ,'') as Curr_Dep_HobbyID
					   ,isnull(T.Curr_Dep_HobbyName ,'') as Curr_Dep_HobbyName
					   ,isnull(T.Curr_Dep_CompanyName,'') as Curr_Dep_CompanyName 
					   ,isnull(T.Curr_Dep_CompanyCity ,'') as Curr_Dep_CompanyCity
					   ,isnull(T.Curr_Dep_StandardID,0) as Curr_Dep_StandardID
					   ,isnull(T.Curr_Dep_StandardName,'') as Curr_Dep_StandardName 
					   ,isnull(T.Curr_Dep_SchCol,'') as Curr_Dep_SchCol 
					   ,isnull(T.Curr_Dep_SchColCity,'') as Curr_Dep_SchColCity
					   ,isnull(T.Curr_Dep_ExtraActivity,'') as Curr_Dep_ExtraActivity 
					------------------------------------------End  by ronakk 06072022 -------------------------
					  ,isnull(T.Dep_Std_Specialization,'') as Dep_Std_Specialization		--Added by ronakk 22072022
					  ,isnull(T.Curr_Dep_Std_Specialization,'') as Curr_Dep_Std_Specialization	--Added by ronakk 22072022





FROM  (SELECT     CRA.Request_id AS Request_Apr_id, CRA.Cmp_id, CRA.Emp_ID, CRA.Request_Type_id, CRA.Change_Reason, CRA.Request_Date, 0 AS is_Final_Approved, 
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

											  -----------------------------------------------Added by ronakk 23062022 -------------------------------------------------
											  ,qry.Dep_OccupationID
											  ,qry.Dep_HobbyID
											  ,qry.Dep_HobbyName
											  ,qry.Dep_DepCompanyName
											  ,qry.Dep_CmpCity
											  ,qry.Dep_Standard_ID
											  ,qry.Dep_Shcool_College
											  ,qry.Dep_SchCity
											  ,qry.Dep_ExtraActivity
											  ,qry.Emp_Fav_Sport_id
											  ,qry.Emp_Fav_Sport_Name
											  ,qry.Emp_Hobby_id
											  ,qry.Emp_Hobby_Name
											  ,qry.Emp_Fav_Food
											  ,qry.Emp_Fav_Restro
											  ,qry.Emp_Fav_Trv_Destination
											  ,qry.Emp_Fav_Festival
											  ,qry.Emp_Fav_SportPerson
											  ,qry.Emp_Fav_Singer
											  ---------------------------------------------------------End by ronakk 23062022 --------------------------------------------

											   ---------------------------------------------------------Added by ronakk 24062022 --------------------------------------------
					 
											   ,qry.Curr_Emp_Fav_Sport_id
											   ,qry.Curr_Emp_Fav_Sport_Name
											   ,qry.Curr_Emp_Hobby_id
											   ,qry.Curr_Emp_Hobby_Name
											   ,qry.Curr_Emp_Fav_Food
											   ,qry.Curr_Emp_Fav_Restro
											   ,qry.Curr_Emp_Fav_Trv_Destination
											   ,qry.Curr_Emp_Fav_Festival
											   ,qry.Curr_Emp_Fav_SportPerson
											   ,qry.Curr_Emp_Fav_Singer
										  ---------------------------------------------------------End by ronakk 24062022 --------------------------------------------
										  -------------------------------------Added by ronakk 29062022 -------------------------------------
												,qry.OtherHobby
												,qry.Dep_PancardNo
												,qry.Dep_AdharcardNo
												,qry.Dep_Height
												,qry.Dep_Weight
												
												,qry.OtherSports
										-------------------------------------End by ronakk 29062022 -------------------------------------

											---------------------------------------Add  by ronakk 06072022 -----------------------------------
											 ,qry.Curr_Dep_ID 
											 ,qry.Curr_Dep_Name 
											 ,qry.Curr_Dep_Gender 
											 ,qry.Curr_Dep_DOB
											 ,qry.Curr_Dep_CAGE 
											 ,qry.Curr_Dep_Relationship 
											 ,qry.Curr_Dep_ISResi 
											 ,qry.Curr_Dep_ISDep 
											 ,qry.Curr_Dep_ImagePath 
											 ,qry.Curr_Dep_PanCard
											 ,qry.Curr_Dep_AdharCard 
											 ,qry.Curr_Dep_Height 
											 ,qry.Curr_Dep_Weight 
											 ,qry.Curr_Dep_OccupationID 
											 ,qry.Curr_Dep_OccupationName 
											 ,qry.Curr_Dep_HobbyID 
											 ,qry.Curr_Dep_HobbyName 
											 ,qry.Curr_Dep_CompanyName 
											 ,qry.Curr_Dep_CompanyCity 
											 ,qry.Curr_Dep_StandardID
											 ,qry.Curr_Dep_StandardName 
											 ,qry.Curr_Dep_SchCol 
											 ,qry.Curr_Dep_SchColCity
											 ,qry.Curr_Dep_ExtraActivity
											 ---------------------------------------End  by ronakk 06072022 -----------------------------------
											 ,qry.Dep_Std_Specialization		--Added by ronakk 22072022
											 ,qry.Curr_Dep_Std_Specialization	--Added by ronakk 22072022





											 FROM          dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK) 
											 INNER JOIN dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id AND CRA.Cmp_id = CRM.Cmp_ID 
											 INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID 
											 INNER JOIN (SELECT     RLA.Request_id, RLA.S_Emp_Id, RLA.Tran_id, RLA.Shift_From_Date, RLA.Shift_To_Date, RLA.Curr_Details, RLA.New_Details, RLA.Curr_Tehsil, RLA.Curr_District, 
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
																		    -----------------------------------------------Added by ronakk 23062022 -------------------------------------------------
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
																			---------------------------------------------------------End by ronakk 23062022 --------------------------------------------
																			 ---------------------------------------------------------Added by ronakk 24062022 --------------------------------------------
					 
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
																	        ---------------------------------------------------------End by ronakk 24062022 --------------------------------------------
																			-------------------------------------Added by ronakk 29062022 -------------------------------------
																			,RLA.OtherHobby
																			,RLA.Dep_PancardNo
																			,RLA.Dep_AdharcardNo
																			,RLA.Dep_Height
																			,RLA.Dep_Weight
																			
																			,RLA.OtherSports
																			-------------------------------------End by ronakk 29062022 -------------------------------------

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
																				 ,RLA.Dep_Std_Specialization		--Added by ronakk 22072022
																				 ,RLA.Curr_Dep_Std_Specialization	--Added by ronakk 22072022

                                                             FROM          dbo.T0115_Request_Level_Approval AS RLA  WITH (NOLOCK) 
															 INNER JOIN (SELECT     MAX(Rpt_Level) AS Rpt_Level, Request_id
                                                                         FROM          dbo.T0115_Request_Level_Approval WITH (NOLOCK) 
                                                                                 GROUP BY Request_id) AS Qry_1 ON Qry_1.Rpt_Level = RLA.Rpt_Level AND Qry_1.Request_id = RLA.Request_id 
															INNER JOIN dbo.T0090_Change_Request_Application AS RA WITH (NOLOCK)  ON RA.Request_id = RLA.Request_id
                                                            WHERE      (RLA.Request_Apr_Status = 'A') OR (RLA.Request_Apr_Status = 'R')) AS qry ON CRA.Request_id = qry.Request_id
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
											 -----------------------------------------------Added by ronakk 23062022 -------------------------------------------------
											 ,CRA.Dep_OccupationID
											 ,CRA.Dep_HobbyID
											 ,CRA.Dep_HobbyName
											 ,CRA.Dep_DepCompanyName
											 ,CRA.Dep_CmpCity
											 ,CRA.Dep_Standard_ID
											 ,CRA.Dep_Shcool_College
											 ,CRA.Dep_SchCity
											 ,CRA.Dep_ExtraActivity
											 ,CRA.Emp_Fav_Sport_id
											 ,CRA.Emp_Fav_Sport_Name
											 ,CRA.Emp_Hobby_id
											 ,CRA.Emp_Hobby_Name
											 ,CRA.Emp_Fav_Food
											 ,CRA.Emp_Fav_Restro
											 ,CRA.Emp_Fav_Trv_Destination
											 ,CRA.Emp_Fav_Festival
											 ,CRA.Emp_Fav_SportPerson
											 ,CRA.Emp_Fav_Singer
											 ---------------------------------------------------------End by ronakk 23062022 --------------------------------------------
											  ---------------------------------------------------------Added by ronakk 24062022 --------------------------------------------
					 
											  ,CRA.Curr_Emp_Fav_Sport_id
											  ,CRA.Curr_Emp_Fav_Sport_Name
											  ,CRA.Curr_Emp_Hobby_id
											  ,CRA.Curr_Emp_Hobby_Name
											  ,CRA.Curr_Emp_Fav_Food
											  ,CRA.Curr_Emp_Fav_Restro
											  ,CRA.Curr_Emp_Fav_Trv_Destination
											  ,CRA.Curr_Emp_Fav_Festival
											  ,CRA.Curr_Emp_Fav_SportPerson
											  ,CRA.Curr_Emp_Fav_Singer
					                       ---------------------------------------------------------End by ronakk 24062022 -------------------------------------------
										   
										   	-------------------------------------Added by ronakk 29062022 -------------------------------------
											,CRA.OtherHobby
											,CRA.Dep_PancardNo
											,CRA.Dep_AdharcardNo
											,CRA.Dep_Height
											,CRA.Dep_Weight
											
											,CRA.OtherSports
											-------------------------------------End by ronakk 29062022 -------------------------------------
										   

										   	---------------------------------------Add  by ronakk 06072022 -----------------------------------
											 ,CRA.Curr_Dep_ID 
											 ,CRA.Curr_Dep_Name 
											 ,CRA.Curr_Dep_Gender 
											 ,CRA.Curr_Dep_DOB
											 ,CRA.Curr_Dep_CAGE 
											 ,CRA.Curr_Dep_Relationship 
											 ,CRA.Curr_Dep_ISResi 
											 ,CRA.Curr_Dep_ISDep 
											 ,CRA.Curr_Dep_ImagePath 
											 ,CRA.Curr_Dep_PanCard
											 ,CRA.Curr_Dep_AdharCard 
											 ,CRA.Curr_Dep_Height 
											 ,CRA.Curr_Dep_Weight 
											 ,CRA.Curr_Dep_OccupationID 
											 ,CRA.Curr_Dep_OccupationName 
											 ,CRA.Curr_Dep_HobbyID 
											 ,CRA.Curr_Dep_HobbyName 
											 ,CRA.Curr_Dep_CompanyName 
											 ,CRA.Curr_Dep_CompanyCity 
											 ,CRA.Curr_Dep_StandardID
											 ,CRA.Curr_Dep_StandardName 
											 ,CRA.Curr_Dep_SchCol 
											 ,CRA.Curr_Dep_SchColCity
											 ,CRA.Curr_Dep_ExtraActivity
											 ---------------------------------------End  by ronakk 06072022 -----------------------------------
											 ,CRA.Dep_Std_Specialization		--Added by ronakk 22072022
											 ,CRA.Curr_Dep_Std_Specialization	--Added by ronakk 22072022
		

                       FROM         dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK)
					   INNER JOIN dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id AND CRA.Cmp_id = CRM.Cmp_ID 
					   INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID
                       WHERE     (CRA.Request_status = 'P') AND (CRA.Request_id NOT IN
                                                 (SELECT     CRA.Request_id
                                                   FROM          dbo.T0115_Request_Level_Approval AS RLA WITH (NOLOCK) 
                                                   WHERE      (Request_id = CRA.Request_id) AND (Emp_ID = CRA.Emp_ID)))) AS T
												   LEFT OUTER JOIN (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID, Dept_ID
																	FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK) 
																	WHERE      (Increment_ID = (SELECT     TOP (1) Increment_ID
																	                             FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK) 
																	                             WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
																								ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = T.Emp_ID AND B.Cmp_ID = T.Cmp_id





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'= 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Admin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Admin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[18] 2[19] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -769
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CRA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CRM"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 126
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 246
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "qry"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 366
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 164
         Width = 284
         Width = 2130
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2685
         Width = 1995
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Admin';

