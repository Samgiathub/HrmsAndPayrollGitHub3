CREATE VIEW dbo.[V0040_Asset_details2]
AS
SELECT DISTINCT 
                  dbo.T0040_ASSET_MASTER.Asset_Name, dbo.T0040_Asset_Details.Type_of_Asset, dbo.T0040_Asset_Details.SerialNo, dbo.T0040_BRAND_MASTER.BRAND_Name, dbo.T0040_Asset_Details.Cmp_ID, dbo.T0040_Asset_Details.Asset_Code, dbo.T0040_Asset_Details.AssetM_ID, 
                  CASE WHEN dbo.T0040_Asset_Details.allocation = 1 THEN 'Yes' ELSE 'No' END AS Allocation, CASE WHEN T0040_Asset_Details.Purchase_date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), dbo.T0040_Asset_Details.Purchase_date, 103) END AS Purchase_date, 
                  CASE WHEN T0130_Asset_Approval_Det.Application_Type = '2' AND 
                  T0130_Asset_Approval_Det.Approval_status = 'A' THEN 'sell' WHEN dbo.T0040_Asset_Details.Asset_Status = 'W' THEN 'Working' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Dispose' THEN 'Dispose' WHEN dbo.T0040_Asset_Details.Asset_Status = 'Spare' THEN 'Spare' WHEN dbo.T0040_Asset_Details.Asset_Status
                   = 'Not Repairable' THEN 'Not Repairable' END AS Asset_Status, dbo.T0040_Asset_Details.Invoice_No, dbo.T0040_Asset_Details.Invoice_Amount, dbo.T0040_Asset_Details.Invoice_Date, dbo.T0040_Asset_Details.Model, dbo.T0040_Asset_Details.Vendor_Id, 
                  dbo.T0040_Asset_Details.Branch_ID
FROM        dbo.T0040_Asset_Details WITH (NOLOCK) LEFT OUTER JOIN
                  dbo.T0040_BRAND_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.BRAND_ID = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
                  dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0040_Asset_Details.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID LEFT OUTER JOIN
                  dbo.T0130_Asset_Approval_Det WITH (NOLOCK) ON dbo.T0040_Asset_Details.AssetM_ID = dbo.T0130_Asset_Approval_Det.AssetM_ID AND dbo.T0130_Asset_Approval_Det.Application_Type = 0 AND dbo.T0040_Asset_Details.allocation = 1 LEFT OUTER JOIN
                  dbo.T0120_Asset_Approval WITH (NOLOCK) ON dbo.T0130_Asset_Approval_Det.Asset_Approval_ID = dbo.T0120_Asset_Approval.Asset_Approval_ID

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
         Begin Table = "T0040_Asset_Details"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_BRAND_MASTER"
            Begin Extent = 
               Top = 7
               Left = 298
               Bottom = 170
               Right = 492
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_ASSET_MASTER"
            Begin Extent = 
               Top = 7
               Left = 540
               Bottom = 170
               Right = 734
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_Asset_Approval_Det"
            Begin Extent = 
               Top = 7
               Left = 782
               Bottom = 170
               Right = 1043
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_Asset_Approval"
            Begin Extent = 
               Top = 7
               Left = 1091
               Bottom = 170
               Right = 1356
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
         Filter = 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_details2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_details2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_details2';

