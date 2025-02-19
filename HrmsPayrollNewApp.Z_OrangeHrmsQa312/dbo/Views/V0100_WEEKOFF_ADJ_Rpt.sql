





CREATE VIEW [dbo].[V0100_WEEKOFF_ADJ_Rpt]
AS
SELECT     W.W_Tran_ID, W.Emp_ID, W.Cmp_ID, W.For_Date, W.Weekoff_Day, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_Left, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name, dbo.T0080_EMP_MASTER.Emp_Left_Date, 
                      dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0010_COMPANY_MASTER.Cmp_Name, dbo.T0010_COMPANY_MASTER.Cmp_Address, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_WEEKOFF_MASTER.Branch_ID, dbo.T0040_WEEKOFF_MASTER.Cmp_ID AS Expr1
FROM         dbo.T0100_WEEKOFF_ADJ AS W WITH (NOLOCK) INNER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON W.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0010_COMPANY_MASTER.Cmp_Id = dbo.T0030_BRANCH_MASTER.Cmp_ID INNER JOIN
                      dbo.T0040_WEEKOFF_MASTER WITH (NOLOCK)  ON dbo.T0010_COMPANY_MASTER.Cmp_Id = dbo.T0040_WEEKOFF_MASTER.Cmp_ID AND 
                      dbo.T0030_BRANCH_MASTER.Branch_ID = dbo.T0040_WEEKOFF_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON W.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_WEEKOFF_ADJ_Rpt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[50] 4[11] 2[20] 3) )"
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
         Begin Table = "W"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 265
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 265
               Bottom = 121
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_WEEKOFF_MASTER"
            Begin Extent = 
               Top = 126
               Left = 303
               Bottom = 241
               Right = 458
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 255
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
      Begin ColumnWidths = 11
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
      End
   End
   Begin CriteriaPane = ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_WEEKOFF_ADJ_Rpt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_WEEKOFF_ADJ_Rpt';

