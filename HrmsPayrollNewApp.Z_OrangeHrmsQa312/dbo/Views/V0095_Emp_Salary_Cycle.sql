



CREATE VIEW [dbo].[V0095_Emp_Salary_Cycle]
AS
SELECT     dbo.T0095_Emp_Salary_Cycle.Tran_id, dbo.T0095_Emp_Salary_Cycle.Cmp_id, dbo.T0095_Emp_Salary_Cycle.Emp_id, 
                      dbo.T0095_Emp_Salary_Cycle.SalDate_id, dbo.T0095_Emp_Salary_Cycle.Effective_date, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0095_INCREMENT.Cat_ID, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      dbo.T0040_Salary_Cycle_Master.Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0095_INCREMENT.Segment_ID, dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.SubVertical_ID, 
                      dbo.T0095_INCREMENT.subBranch_ID
FROM         dbo.T0095_Emp_Salary_Cycle WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_Emp_Salary_Cycle.Emp_id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0095_INCREMENT.Emp_ID INNER JOIN
                      dbo.T0040_Salary_Cycle_Master WITH (NOLOCK)  ON dbo.T0095_Emp_Salary_Cycle.SalDate_id = dbo.T0040_Salary_Cycle_Master.Tran_Id



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
         Begin Table = "T0095_Emp_Salary_Cycle"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 0
               Left = 313
               Bottom = 119
               Right = 538
            End
            DisplayFlags = 280
            TopColumn = 37
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 663
               Bottom = 125
               Right = 879
            End
            DisplayFlags = 280
            TopColumn = 63
         End
         Begin Table = "T0040_Salary_Cycle_Master"
            Begin Extent = 
               Top = 33
               Left = 1048
               Bottom = 152
               Right = 1210
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
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1995
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_Emp_Salary_Cycle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_Emp_Salary_Cycle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_Emp_Salary_Cycle';

