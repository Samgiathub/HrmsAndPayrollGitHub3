




CREATE VIEW [dbo].[V0090_HRMS_Appraisal_Emp_SOLAssessment]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, T0080_Sup_MASTER.Emp_Full_Name AS Sup_Full_Name, 
                      T0080_Sup_MASTER.Alpha_Emp_Code AS Alpha_Sup_Code, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessment.*
FROM         dbo.T0090_HRMS_Appraisal_Emp_SOLAssessment WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_Appraisal_Emp_SOLAssessment.FK_EmployeeId = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_Sup_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_Appraisal_Emp_SOLAssessment.FK_SupervisorId = T0080_Sup_MASTER.Emp_ID




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[58] 4[3] 2[16] 3) )"
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
         Begin Table = "T0090_HRMS_Appraisal_Emp_SOLAssessment"
            Begin Extent = 
               Top = 5
               Left = 233
               Bottom = 277
               Right = 541
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 0
               Left = 655
               Bottom = 156
               Right = 880
            End
            DisplayFlags = 280
            TopColumn = 72
         End
         Begin Table = "T0080_Sup_MASTER"
            Begin Extent = 
               Top = 161
               Left = 657
               Bottom = 280
               Right = 882
            End
            DisplayFlags = 280
            TopColumn = 74
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 28
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1710
         Width = 2025
         Width = 825
         Width = 1575
         Width = 1845
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_SOLAssessment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_SOLAssessment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_SOLAssessment';

