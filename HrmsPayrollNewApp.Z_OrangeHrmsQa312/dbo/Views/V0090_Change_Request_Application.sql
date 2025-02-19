








CREATE VIEW [dbo].[V0090_Change_Request_Application]
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
					  
					  -----------------------------------------------Added by ronakk 21062022 -------------------------------------------------
					  ,isnull(Dep_OccupationID,0) as Dep_OccupationID
					  ,ISNULL(Dep_HobbyID,'') as Dep_HobbyID
					  ,ISNULL(Dep_HobbyName,'') as Dep_HobbyName
					  ,ISNULL(Dep_DepCompanyName,'') as Dep_DepCompanyName
					  ,ISNULL(Dep_CmpCity,'') as Dep_CmpCity
					  ,ISNULL(Dep_Standard_ID,0) as Dep_Standard_ID
					  ,ISNULL(Dep_Shcool_College,'') as Dep_Shcool_College
					  ,ISNULL(Dep_SchCity,'') as Dep_SchCity
					  ,ISNULL(Dep_ExtraActivity,'') as Dep_ExtraActivity
                      					  
					  --------------------------------------------------End by ronakk 21062022 ------------------------------------------------

					  ---------------------------------------------------------Added by ronakk 22062022 --------------------------------------------
					 
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name
					  ,isnull(T0090_Change_Request_Application.Emp_Hobby_id,'') as Emp_Hobby_id
					  ,isnull(T0090_Change_Request_Application.Emp_Hobby_Name,'') as Emp_Hobby_Name
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Food,'') as Emp_Fav_Food
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Restro,'') as Emp_Fav_Restro
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Festival,'') as Emp_Fav_Festival
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson
					  ,isnull(T0090_Change_Request_Application.Emp_Fav_Singer,'') as Emp_Fav_Singer

					    ---------------------------------------------------------End by ronakk 22062022 --------------------------------------------


						 ---------------------------------------------------------Added by ronakk 24062022 --------------------------------------------
					 
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Sport_id,'') as Curr_Emp_Fav_Sport_id
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Sport_Name,'') as Curr_Emp_Fav_Sport_Name
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Hobby_id,'') as Curr_Emp_Hobby_id
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Hobby_Name,'') as Curr_Emp_Hobby_Name
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Food,'') as Curr_Emp_Fav_Food
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Restro,'') as Curr_Emp_Fav_Restro
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Trv_Destination,'') as Curr_Emp_Fav_Trv_Destination
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Festival,'') as Curr_Emp_Fav_Festival
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_SportPerson,'') as Curr_Emp_Fav_SportPerson
					  ,isnull(T0090_Change_Request_Application.Curr_Emp_Fav_Singer,'') as Curr_Emp_Fav_Singer

					    ---------------------------------------------------------End by ronakk 24062022 --------------------------------------------

				    ---------------------------------------------------Added by ronakk 27062022 --------------------------------------
					 ,isnull(T0090_Change_Request_Application.OtherHobby,'') as OtherHobby
					 ,isnull(T0090_Change_Request_Application.Dep_PancardNo,'') as Dep_PancardNo
					 ,isnull(T0090_Change_Request_Application.Dep_AdharcardNo,'') as Dep_AdharcardNo
					 ,isnull(T0090_Change_Request_Application.Dep_Height,'') as Dep_Height
					 ,isnull(T0090_Change_Request_Application.Dep_Weight,'') as Dep_Weight

					 ,isnull(T0090_Change_Request_Application.OtherSports,'') as OtherSports
				   ----------------------------------------------------End by ronakk 27062022 -----------------------------------------

				    ----------------------------------------Added by ronakk 06072022 --------------------------
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_ID,0) as Curr_Dep_ID 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_Name,'') as Curr_Dep_Name  
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_Gender,'') as Curr_Dep_Gender 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_DOB,'') as Curr_Dep_DOB
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_CAGE,'0') as Curr_Dep_CAGE 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_Relationship,'') as Curr_Dep_Relationship 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_ISResi,0) as Curr_Dep_ISResi 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_ISDep,0) as Curr_Dep_ISDep 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_ImagePath,'') as Curr_Dep_ImagePath 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_PanCard,'') as Curr_Dep_PanCard
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_AdharCard,'') as Curr_Dep_AdharCard 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_Height,'') as Curr_Dep_Height
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_Weight,'') as Curr_Dep_Weight 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_OccupationID,0) as Curr_Dep_OccupationID 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_OccupationName,'') as  Curr_Dep_OccupationName 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_HobbyID ,'') as Curr_Dep_HobbyID
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_HobbyName ,'') as Curr_Dep_HobbyName
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_CompanyName,'') as Curr_Dep_CompanyName 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_CompanyCity ,'') as Curr_Dep_CompanyCity
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_StandardID,0) as Curr_Dep_StandardID
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_StandardName,'') as Curr_Dep_StandardName 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_SchCol,'') as Curr_Dep_SchCol 
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_SchColCity,'') as Curr_Dep_SchColCity
					   ,isnull(T0090_Change_Request_Application.Curr_Dep_ExtraActivity,'') as Curr_Dep_ExtraActivity 
					 ------------------------------------------End  by ronakk 06072022 -------------------------
					  ,isnull(T0090_Change_Request_Application.Dep_Std_Specialization,'') as Dep_Std_Specialization			  --Added by ronakk 21072022
					  ,isnull(T0090_Change_Request_Application.Curr_Dep_Std_Specialization,'') as Curr_Dep_Std_Specialization --Added by ronakk 21072022

FROM         dbo.T0090_Change_Request_Application WITH (NOLOCK) 

					INNER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_Change_Request_Application.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID 
					INNER JOIN dbo.T0040_Change_Request_Master WITH (NOLOCK)  ON dbo.T0090_Change_Request_Application.Request_Type_id = dbo.T0040_Change_Request_Master.Request_id AND 
                                                                                 dbo.T0090_Change_Request_Application.Cmp_id = dbo.T0040_Change_Request_Master.Cmp_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0090_Change_Request_Application"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 246
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Change_Request_Master"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 126
               Right = 409
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
      Begin ColumnWidths = 9
         Width = 284
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Application';

