





CREATE VIEW [dbo].[V0040_Asset_Details3]
AS
SELECT DISTINCT 
                      dbo.T0040_ASSET_MASTER.Asset_Name, T0040_Asset_Details_1.SerialNo, T0040_Asset_Details_1.Model, 
                      CASE WHEN T0040_Asset_Details_1.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), T0040_Asset_Details_1.Purchase_date, 103) 
                      END AS Purchase_date, T0040_Asset_Details_1.Asset_Code, T0040_Asset_Details_1.Asset_ID, T0040_Asset_Details_1.Cmp_ID, 
                      dbo.T0040_BRAND_MASTER.BRAND_Name, T0040_Asset_Details_1.BRAND_ID, T0040_Asset_Details_1.allocation, T0040_Asset_Details_1.Asset_Status, 
                      T0040_Asset_Details_1.AssetM_ID, dbo.T0130_Asset_Approval_Det.Allocation_Date, T0040_Asset_Details_1.Type_of_Asset
FROM         dbo.T0040_Asset_Details AS T0040_Asset_Details_1 WITH (NOLOCK)  INNER JOIN
                      dbo.T0040_ASSET_MASTER WITH (NOLOCK)  ON T0040_Asset_Details_1.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID AND 
                      T0040_Asset_Details_1.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
                      dbo.T0040_BRAND_MASTER WITH (NOLOCK)  ON T0040_Asset_Details_1.BRAND_ID = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
                      dbo.T0130_Asset_Approval_Det WITH (NOLOCK)  ON dbo.T0130_Asset_Approval_Det.AssetM_ID = T0040_Asset_Details_1.AssetM_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[5] 2[31] 3) )"
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
         Begin Table = "T0040_Asset_Details_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 151
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_ASSET_MASTER"
            Begin Extent = 
               Top = 121
               Left = 460
               Bottom = 240
               Right = 620
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_BRAND_MASTER"
            Begin Extent = 
               Top = 6
               Left = 652
               Bottom = 125
               Right = 812
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_Asset_Approval_Det"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 125
               Right = 428
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
         Ne', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Details3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'wValue = 1170
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Details3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Details3';

