


CREATE VIEW [dbo].[V0130_HRMS_TRAINING_ALERT]
AS
SELECT     dbo.T0130_HRMS_TRAINING_ALERT.Emp_id, dbo.T0130_HRMS_TRAINING_ALERT.Training_Apr_ID, dbo.T0130_HRMS_TRAINING_ALERT.Tran_alert_ID, 
                      dbo.T0130_HRMS_TRAINING_ALERT.Comments, dbo.T0130_HRMS_TRAINING_ALERT.alerts_Days, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Date, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Description, dbo.T0040_Hrms_Training_master.Training_name, dbo.T0130_HRMS_TRAINING_ALERT.alerts_Start_Days, 
                      dbo.T0130_HRMS_TRAINING_ALERT.cmp_id, dbo.T0130_HRMS_TRAINING_ALERT.Dept_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.grd_id, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Apr_Status, dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Grd_ID AS Expr1, 
                      dbo.T0095_INCREMENT.Dept_ID AS Expr2, dbo.T0095_INCREMENT.Desig_Id, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_End_Date
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0130_HRMS_TRAINING_ALERT  WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id ON 
                      dbo.T0130_HRMS_TRAINING_ALERT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)  ON dbo.T0040_Hrms_Training_master.Training_id = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id ON 
                      dbo.T0130_HRMS_TRAINING_ALERT.Training_Apr_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID ON 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0130_HRMS_TRAINING_ALERT.Emp_id AND 
                      dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   Bottom = 482
               Right = 186
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_HRMS_TRAINING_APPROVAL"
            Begin Extent = 
               Top = 434
               Left = 427
               Bottom = 553
               Right = 630
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 606
               Left = 38
               Bottom = 725
               Right = 207
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
      Begin ColumnWidths = 23
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAINING_ALERT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAINING_ALERT';


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
         Top = -384
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_HRMS_TRAINING_ALERT"
            Begin Extent = 
               Top = 0
               Left = 414
               Bottom = 119
               Right = 590
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 125
               Left = 46
               Bottom = 244
               Right = 288
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 1
               Left = 675
               Bottom = 120
               Right = 870
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 344
               Left = 588
               Bottom = 463
               Right = 771
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 130
               Left = 698
               Bottom = 249
               Right = 858
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Hrms_Training_master"
            Begin Extent = 
               Top = 363
               Left = 1
            ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAINING_ALERT';

