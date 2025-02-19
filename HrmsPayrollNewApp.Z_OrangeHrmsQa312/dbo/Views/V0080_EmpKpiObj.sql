



CREATE VIEW [dbo].[V0080_EmpKpiObj]
AS
SELECT DISTINCT 
                      k.EmpKPI_Id, k.Cmp_Id, k.Status, k.Emp_Id, k.CreatedBy, k.CreatedDate, k.LastEditDate, E1.Alpha_Emp_Code + '-' + E1.Emp_Full_Name AS Emp_Full_Name, 
                      E2.Alpha_Emp_Code + '-' + E2.Emp_Full_Name AS CreatedByName, E1.Emp_Superior, p.Approve_Status, k.FinancialYr, k.Emp_Comments, k.Mgr_Comments, 
                      k.HR_Comments, E1.Alpha_Emp_Code
FROM         dbo.T0080_EmpKPI AS k WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_KPIObjectives AS p WITH (NOLOCK)  ON p.EmpKPI_Id = k.EmpKPI_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK)  ON E1.Emp_ID = k.Emp_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E2 WITH (NOLOCK)  ON E2.Emp_ID = E1.Emp_Superior



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[33] 4[14] 2[27] 3) )"
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
         Begin Table = "E2"
            Begin Extent = 
               Top = 0
               Left = 573
               Bottom = 119
               Right = 817
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "E1"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 125
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 45
         End
         Begin Table = "k"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 137
               Left = 241
               Bottom = 256
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 7
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
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
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EmpKpiObj';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EmpKpiObj';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EmpKpiObj';

