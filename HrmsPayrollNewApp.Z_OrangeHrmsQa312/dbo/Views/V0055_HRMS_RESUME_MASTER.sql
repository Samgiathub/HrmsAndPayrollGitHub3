






CREATE VIEW [dbo].[V0055_HRMS_RESUME_MASTER]
AS
SELECT     dbo.T0052_HRMS_Posted_Recruitment.Job_title, dbo.T0052_HRMS_Posted_Recruitment.S_Emp_id, ISNULL(dbo.T0055_Resume_Master.Initial, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, ISNULL(dbo.T0055_Resume_Master.Total_Exp, 0) AS Total_Experience, 
                      dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0055_Resume_Master.Resume_Id, dbo.T0055_Resume_Master.Cmp_id, dbo.T0055_Resume_Master.Rec_Post_Id, 
                      dbo.T0055_Resume_Master.Resume_Posted_date, dbo.T0055_Resume_Master.Initial, dbo.T0055_Resume_Master.Emp_First_Name, 
                      dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Emp_Last_Name, dbo.T0055_Resume_Master.Date_Of_Birth, 
                      ISNULL(dbo.T0055_Resume_Master.Marital_Status, 0) AS Marital_Status, dbo.T0055_Resume_Master.Gender, dbo.T0055_Resume_Master.Present_Street, 
                      dbo.T0055_Resume_Master.Present_City, dbo.T0055_Resume_Master.Present_State, dbo.T0055_Resume_Master.Present_Post_Box, 
                      dbo.T0055_Resume_Master.Permanent_Street, dbo.T0055_Resume_Master.Permanent_City, dbo.T0055_Resume_Master.Permanent_State, 
                      dbo.T0055_Resume_Master.Permanentt_Post_Box, dbo.T0055_Resume_Master.Home_Tel_no, dbo.T0055_Resume_Master.Mobile_No, 
                      dbo.T0055_Resume_Master.Primary_email, dbo.T0055_Resume_Master.Other_Email, dbo.T0055_Resume_Master.Cur_CTC, dbo.T0055_Resume_Master.Exp_CTC, 
                      ISNULL(dbo.T0055_Resume_Master.Resume_Name, '') AS Resume_Name, dbo.T0055_Resume_Master.File_Name, dbo.T0055_Resume_Master.Resume_Status, 
                      dbo.T0055_Resume_Master.Final_CTC, dbo.T0055_Resume_Master.Date_Of_Join, dbo.T0055_Resume_Master.Marriage_Date, 
                      dbo.T0055_Resume_Master.Basic_Salary, dbo.T0055_Resume_Master.Emp_Full_PF, dbo.T0055_Resume_Master.Emp_Fix_Salary, 
                      dbo.T0055_Resume_Master.Present_Loc, dbo.T0055_Resume_Master.Permanent_Loc_ID, dbo.T0055_Resume_Master.Non_Technical_Skill, 
                      dbo.T0055_Resume_Master.Total_Exp, Loc1.Loc_name AS Present_Loc_Name, Loc2.Loc_name AS Per_loc_Name, dbo.T0055_Resume_Master.Resume_Code, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0055_Resume_Master.PanCardNo, dbo.T0055_Resume_Master.PanCardAck_Path, 
                      dbo.T0055_Resume_Master.Address_Proof, dbo.T0055_Resume_Master.ConfirmJoining, dbo.T0055_Resume_Master.Comments, 
                      dbo.T0055_Resume_Master.FatherName, dbo.T0055_Resume_Master.Lock, dbo.T0055_Resume_Master.HasPancard, dbo.T0055_Resume_Master.Identity_Proof, 
                      dbo.T0055_Resume_Master.Present_District, dbo.T0055_Resume_Master.Present_PO, dbo.T0055_Resume_Master.Permanent_District, 
                      dbo.T0055_Resume_Master.Permanent_PO, dbo.T0055_Resume_Master.DocumentType_Identity, dbo.T0055_Resume_Master.PanCardProof, 
                      dbo.T0055_Resume_Master.PanCardAck_No, dbo.T0055_Resume_Master.DocumentType_Address_Proof, doc1.Doc_Name AS addressproof, 
                      doc2.Doc_Name AS identityproof, dbo.T0055_Resume_Master.DocumentType_Identity2, dbo.T0055_Resume_Master.Identity_Proof2, 
                      dbo.T0055_Resume_Master.DocumentType_AddressProof2, dbo.T0055_Resume_Master.Address_Proof2, doc3.Doc_Name AS address2, 
                      doc4.Doc_Name AS identity2, dbo.T0055_Resume_Master.Marriage_Proof, doc5.Doc_Name AS Documenttype_marriage_proof_Name, 
                      doc5.Doc_ID AS Documenttype_marriage_proof, dbo.T0055_Resume_Master.Source_type_id, dbo.T0055_Resume_Master.Source_Id, STM.Source_Type_Name, 
                      CASE WHEN STM.source_type_name = 'Employee Referral' THEN ETMS.Emp_Full_name ELSE CASE WHEN isnull(T0055_Resume_Master.Source_Name, '') 
                      <> '' THEN T0055_Resume_Master.Source_Name ELSE isnull(sm.Source_Name, 'Career Page') END END AS Source_Name, 
                      dbo.T0055_Resume_Master.Resume_ScreeningStatus, dbo.T0055_Resume_Master.Resume_ScreeningBy, dbo.T0055_Resume_Master.is_physical, 
                      dbo.T0055_Resume_Master.Archive,
                      isnull(dbo.T0055_Resume_Master.Aadhar_CardNo,'') as Aadhar_CardNo,isnull(dbo.T0055_Resume_Master.Aadhar_CardPath,'') as Aadhar_CardPath,
                      ISNULL(SM1.State_Name,'')StateDomicile,ISNULL(PlaceofBirth,'')PlaceofBirth,ISNULL(TrainingSeminars,'')TrainingSeminars,ISNULL(jobProfile,'')jobProfile
                      ,ISNULL(Location_Preference,'')Location_Preference,
                      CASE WHEN T0055_Resume_Master.Location_Preference IS NOT NULL THEN
					  ISNULL((SELECT  (upper(isnull(Branch_Name,'')) + ' » ' + upper(isnull(branch_city,''))) + ' , '
                         FROM          v0030_branch_master d
                         WHERE      d .Branch_ID IN
                               (SELECT     cast(data AS numeric(18, 0))
                                FROM          dbo.Split(ISNULL(T0055_Resume_Master.Location_Preference, '0'), '#')
                                WHERE      data <> '') FOR XML path('')),'#') else '#' end as Location,dbo.T0055_Resume_Master.System_Date,
                     T0055_Resume_Master.Religion,Caste,Caste_Category,No_Of_children,Shirt_Size,Pant_Size,Shoe_Size,
                     CASE WHEN Is_Physical_Disable =1 THEN 'Yse' ELSE 'No' END AS Physical_Disable,Physical_Disable_Perc,Video_Resume,
                     T0055_Resume_Master.Nationality,Mother_Tongue,Is_Physical_Disable,HR.Blood_group,HR.Height,HR.[weight],HR.emp_file_name,
                     BM.Bank_Name,RB.Account_No,BM.Bank_Branch_Name AS Branch_Name,RB.IFSC_Code          
FROM         dbo.T0001_LOCATION_MASTER AS Loc2 WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.S_Emp_id = dbo.T0080_EMP_MASTER.Emp_ID RIGHT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_Resume_Master.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER AS Loc1 WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Present_Loc = Loc1.Loc_ID ON 
                      Loc2.Loc_ID = dbo.T0055_Resume_Master.Permanent_Loc_ID LEFT OUTER JOIN
                      dbo.T0040_DOCUMENT_MASTER AS doc1  WITH (NOLOCK) ON dbo.T0055_Resume_Master.DocumentType_Address_Proof = doc1.Doc_ID LEFT OUTER JOIN
                      dbo.T0040_DOCUMENT_MASTER AS doc2  WITH (NOLOCK) ON dbo.T0055_Resume_Master.DocumentType_Identity = doc2.Doc_ID LEFT OUTER JOIN
                      dbo.T0040_DOCUMENT_MASTER AS doc3  WITH (NOLOCK) ON dbo.T0055_Resume_Master.DocumentType_AddressProof2 = doc3.Doc_ID LEFT OUTER JOIN
                      dbo.T0040_DOCUMENT_MASTER AS doc4  WITH (NOLOCK) ON dbo.T0055_Resume_Master.DocumentType_Identity2 = doc4.Doc_ID LEFT OUTER JOIN
                      dbo.T0040_DOCUMENT_MASTER AS doc5  WITH (NOLOCK) ON dbo.T0055_Resume_Master.DocumentType_Marriage_Proof = doc5.Doc_ID LEFT OUTER JOIN
                      dbo.T0030_Source_Type_Master AS STM WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Source_type_id = STM.Source_Type_Id LEFT OUTER JOIN
                      dbo.T0040_Source_Master AS SM  WITH (NOLOCK) ON dbo.T0055_Resume_Master.Source_Id = SM.Source_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS ETMS WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Source_Id = ETMS.Emp_ID left JOIN
                      T0020_STATE_MASTER SM1  WITH (NOLOCK) ON SM1.State_ID=T0055_Resume_Master.StateDomicile AND SM1.Cmp_ID=T0055_Resume_Master.Cmp_id LEFT JOIN
                      T0090_HRMS_RESUME_HEALTH HR WITH (NOLOCK)  ON HR.Resume_ID=T0055_Resume_Master.Resume_Id left JOIN
                      T0090_HRMS_RESUME_BANK RB WITH (NOLOCK)  ON RB.Resume_Id=T0055_Resume_Master.Resume_Id LEFT JOIN
                      T0040_BANK_MASTER BM WITH (NOLOCK)  ON BM.Bank_ID=RB.Bank_Id





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "doc3"
            Begin Extent = 
               Top = 222
               Left = 652
               Bottom = 337
               Right = 807
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "doc4"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 193
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "doc5"
            Begin Extent = 
               Top = 306
               Left = 231
               Bottom = 425
               Right = 414
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "STM"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 455
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SM"
            Begin Extent = 
               Top = 426
               Left = 261
               Bottom = 545
               Right = 425
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ETMS"
            Begin Extent = 
               Top = 546
               Left = 38
               Bottom = 665
               Right = 282
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
      Begin ColumnWidths = 73
         Width = 284
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
         GroupBy = 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_RESUME_MASTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_RESUME_MASTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_RESUME_MASTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[45] 4[9] 2[19] 3) )"
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
         Top = -384
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Loc2"
            Begin Extent = 
               Top = 216
               Left = 264
               Bottom = 301
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 238
               Bottom = 121
               Right = 455
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 306
            End
            DisplayFlags = 280
            TopColumn = 56
         End
         Begin Table = "Loc1"
            Begin Extent = 
               Top = 121
               Left = 459
               Bottom = 206
               Right = 611
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "doc1"
            Begin Extent = 
               Top = 102
               Left = 649
               Bottom = 217
               Right = 804
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "doc2"
            Begin Extent = 
               Top = 210
               Left = 454
               Bottom = 325
               Right = 609
            ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_RESUME_MASTER';

