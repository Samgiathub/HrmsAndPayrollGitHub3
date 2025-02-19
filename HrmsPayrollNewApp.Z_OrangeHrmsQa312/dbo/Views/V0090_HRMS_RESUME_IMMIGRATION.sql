





CREATE VIEW [dbo].[V0090_HRMS_RESUME_IMMIGRATION]
AS
SELECT     dbo.T0001_LOCATION_MASTER.Loc_name, dbo.T0090_HRMS_RESUME_IMMIGRATION.Row_ID, dbo.T0090_HRMS_RESUME_IMMIGRATION.Cmp_ID, 
                      dbo.T0090_HRMS_RESUME_IMMIGRATION.Resume_ID, dbo.T0090_HRMS_RESUME_IMMIGRATION.Loc_ID, 
                      dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_Type, dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_No, 
                      dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_Issue_Date, dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_Issue_Status, 
                      dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_Date_of_Expiry, dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_Review_Date, 
                      dbo.T0090_HRMS_RESUME_IMMIGRATION.Imm_Comments, dbo.T0055_Resume_Master.Resume_Code,ISNULL(attach_Documents,'')attach_Documents
FROM         dbo.T0090_HRMS_RESUME_IMMIGRATION WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON dbo.T0001_LOCATION_MASTER.Loc_ID = dbo.T0090_HRMS_RESUME_IMMIGRATION.Loc_ID LEFT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0090_HRMS_RESUME_IMMIGRATION.Resume_ID = dbo.T0055_Resume_Master.Resume_Id





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[12] 2[21] 3) )"
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
         Begin Table = "T0090_HRMS_RESUME_IMMIGRATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 0
               Left = 518
               Bottom = 115
               Right = 706
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0001_LOCATION_MASTER"
            Begin Extent = 
               Top = 6
               Left = 258
               Bottom = 91
               Right = 410
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
      Begin ColumnWidths = 14
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_RESUME_IMMIGRATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_RESUME_IMMIGRATION';

