


CREATE VIEW [dbo].[V0120_Asset_Approval]
AS
SELECT     dbo.T0040_ASSET_MASTER.Asset_Name, dbo.T0040_BRAND_MASTER.BRAND_Name, 
                      CASE WHEN T0040_Asset_Details.Warranty_Starts = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), dbo.T0040_Asset_Details.Warranty_Starts, 103) 
                      END AS Warranty_Starts, CASE WHEN T0040_Asset_Details.Warranty_Ends = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), 
                      dbo.T0040_Asset_Details.Warranty_Ends, 103) END AS Warranty_Ends, 
                      CASE WHEN T0040_Asset_Details.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), dbo.T0040_Asset_Details.Purchase_date, 103) 
                      END AS Purchase_date, dbo.T0040_Vendor_Master.Vendor_Name AS Vendor, dbo.T0040_Asset_Details.Type_of_Asset, 
                      dbo.T0130_Asset_Approval_Det.Asset_Approval_ID, dbo.T0040_Asset_Details.Model AS Model_Name, dbo.T0040_Asset_Details.SerialNo AS Serial_No, 
                      dbo.T0040_Asset_Details.Asset_Code, dbo.T0130_Asset_Approval_Det.Cmp_ID, dbo.T0040_Asset_Details.Asset_Status, CASE WHEN CONVERT(varchar(10), 
                      dbo.T0130_Asset_Approval_Det.Return_Date, 103) = '01/01/1900' THEN '' ELSE CONVERT(varchar(10), dbo.T0130_Asset_Approval_Det.Return_Date, 103) 
                      END AS Return_Date, CASE WHEN CONVERT(varchar(10), dbo.T0130_Asset_Approval_Det.Allocation_Date, 103) = '01/01/1900' THEN '' ELSE CONVERT(varchar(10), 
                      dbo.T0130_Asset_Approval_Det.Allocation_Date, 103) END AS Allocation_Date, dbo.T0040_ASSET_MASTER.Asset_ID, 
                      dbo.T0130_Asset_Approval_Det.Approval_status
FROM         dbo.T0040_Asset_Details WITH (NOLOCK) INNER JOIN
                      dbo.T0040_ASSET_MASTER WITH (NOLOCK)  ON dbo.T0040_Asset_Details.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
                      dbo.T0040_BRAND_MASTER WITH (NOLOCK)  ON dbo.T0040_Asset_Details.BRAND_ID = dbo.T0040_BRAND_MASTER.BRAND_ID LEFT OUTER JOIN
                      dbo.T0130_Asset_Approval_Det WITH (NOLOCK)  ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID LEFT OUTER JOIN
                      dbo.T0040_Vendor_Master WITH (NOLOCK)  ON dbo.T0040_Asset_Details.Vendor_Id = dbo.T0040_Vendor_Master.Vendor_Id


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'e = 1170
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Asset_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Asset_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[19] 4[5] 2[39] 3) )"
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
         Begin Table = "T0040_Asset_Details"
            Begin Extent = 
               Top = 0
               Left = 696
               Bottom = 373
               Right = 1065
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_ASSET_MASTER"
            Begin Extent = 
               Top = 6
               Left = 289
               Bottom = 125
               Right = 449
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_BRAND_MASTER"
            Begin Extent = 
               Top = 205
               Left = 434
               Bottom = 463
               Right = 594
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_Asset_Approval_Det"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 301
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 18
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1860
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2325
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
         Tabl', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Asset_Approval';

