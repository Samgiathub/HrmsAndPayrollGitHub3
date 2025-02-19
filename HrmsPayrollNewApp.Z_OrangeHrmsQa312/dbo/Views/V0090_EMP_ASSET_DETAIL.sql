


CREATE VIEW [dbo].[V0090_EMP_ASSET_DETAIL]
AS
SELECT     dbo.T0040_ASSET_MASTER.Asset_Name, dbo.T0040_ASSET_MASTER.Asset_ID, dbo.T0090_EMP_ASSET_DETAIL.Emp_Asset_ID, 
                      dbo.T0090_EMP_ASSET_DETAIL.Cmp_ID, dbo.T0090_EMP_ASSET_DETAIL.Model_No, 
                      CAST(dbo.T0090_EMP_ASSET_DETAIL.Issue_Date AS Varchar(11)) AS Issue_Date, CAST(dbo.T0090_EMP_ASSET_DETAIL.Return_Date AS Varchar(11)) 
                      AS Return_Date, dbo.T0090_EMP_ASSET_DETAIL.Asset_Comment, dbo.T0090_EMP_ASSET_DETAIL.Emp_ID, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0080_EMP_MASTER.Initial + ' ' + dbo.T0080_EMP_MASTER.Emp_First_Name + ' ' + dbo.T0080_EMP_MASTER.Emp_Last_Name AS Emp_Name, 
                      dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, CAST(dbo.T0080_EMP_MASTER.Date_Of_Join AS Varchar(11)) 
                      AS Date_Of_Join
FROM         dbo.T0040_ASSET_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0090_EMP_ASSET_DETAIL WITH (NOLOCK)  ON dbo.T0040_ASSET_MASTER.Asset_ID = dbo.T0090_EMP_ASSET_DETAIL.Asset_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_EMP_ASSET_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID




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
         Begin Table = "T0040_ASSET_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0090_EMP_ASSET_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 387
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 425
               Bottom = 121
               Right = 642
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 680
               Bottom = 121
               Right = 839
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
      Begin ColumnWidths = 15
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
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_ASSET_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'= 1170
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_ASSET_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_ASSET_DETAIL';

