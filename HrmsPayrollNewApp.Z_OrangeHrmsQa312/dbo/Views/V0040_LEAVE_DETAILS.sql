




CREATE VIEW [dbo].[V0040_LEAVE_DETAILS]
AS
SELECT     dbo.T0040_GRADE_MASTER.Grd_ID, dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0040_LEAVE_MASTER.Leave_Name, 
                      dbo.T0040_LEAVE_MASTER.Leave_ID, dbo.T0050_LEAVE_DETAIL.Leave_Days, dbo.T0050_LEAVE_DETAIL.Row_ID, 
                      dbo.T0050_LEAVE_DETAIL.Cmp_ID, dbo.T0040_LEAVE_MASTER.Is_Late_Adj, dbo.T0040_LEAVE_MASTER.Leave_Paid_Unpaid, 
                      dbo.T0040_LEAVE_MASTER.Display_leave_balance, dbo.T0040_LEAVE_MASTER.Leave_Status, dbo.T0040_LEAVE_MASTER.InActive_Effective_Date, 
                      dbo.T0040_LEAVE_MASTER.leave_club_with, dbo.T0040_LEAVE_MASTER.Default_Short_Name, dbo.T0040_LEAVE_MASTER.Apply_Hourly, 
                      dbo.T0040_LEAVE_MASTER.Multi_Branch_ID,
                      dbo.T0040_LEAVE_MASTER.Leave_Type,
                      dbo.T0040_LEAVE_MASTER.Leave_Sorting_No
FROM         dbo.T0040_LEAVE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0050_LEAVE_DETAIL WITH (NOLOCK) ON dbo.T0040_LEAVE_MASTER.Leave_ID = dbo.T0050_LEAVE_DETAIL.Leave_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0050_LEAVE_DETAIL.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID




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
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 257
            End
            DisplayFlags = 280
            TopColumn = 49
         End
         Begin Table = "T0050_LEAVE_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 295
               Bottom = 121
               Right = 447
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 213
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_LEAVE_DETAILS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_LEAVE_DETAILS';

