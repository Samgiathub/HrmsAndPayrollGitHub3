





CREATE VIEW [dbo].[V0090_HRMS_Resume_Skill]
AS
SELECT     dbo.T0055_Resume_Master.Resume_Id, dbo.T0090_HRMS_RESUME_SKILL.Row_Id, dbo.T0090_HRMS_RESUME_SKILL.Cmp_Id, 
                      dbo.T0040_SKILL_MASTER.Skill_ID, dbo.T0040_SKILL_MASTER.Skill_Name, dbo.T0090_HRMS_RESUME_SKILL.Skill_Comments, 
                      dbo.T0090_HRMS_RESUME_SKILL.Skill_Experience, dbo.T0055_Resume_Master.Resume_Code,ISNULL(attach_Documents,'')attach_Documents
FROM         dbo.T0090_HRMS_RESUME_SKILL WITH (NOLOCK) INNER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0090_HRMS_RESUME_SKILL.Resume_Id = dbo.T0055_Resume_Master.Resume_Id INNER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_RESUME_SKILL.Skill_Id = dbo.T0040_SKILL_MASTER.Skill_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[8] 3) )"
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
         Begin Table = "T0090_HRMS_RESUME_SKILL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 6
               Left = 233
               Bottom = 121
               Right = 421
            End
            DisplayFlags = 280
            TopColumn = 35
         End
         Begin Table = "T0040_SKILL_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 190
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
      Begin ColumnWidths = 10
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Resume_Skill';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Resume_Skill';

