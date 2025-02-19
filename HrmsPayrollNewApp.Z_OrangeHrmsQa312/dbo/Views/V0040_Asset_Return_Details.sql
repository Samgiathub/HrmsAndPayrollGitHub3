


CREATE VIEW [dbo].[V0040_Asset_Return_Details]
AS
SELECT     BRAND_Name, Asset_Name, Asset_ID, Application_date, Application_status, Model_Name, Serial_No, Allocation_Date, Asset_Code, Emp_ID, Cmp_ID, AssetM_ID, 
                      Branch_ID, 0 AS Brand_ID, '' AS Purchase_date, '' AS Return_Date, asset_approval_id
FROM         dbo.V0040_Asset_Return WITH (NOLOCK)
WHERE     (Application_Type = 0) AND (asset_approval_id NOT IN
                          (SELECT     Return_asset_approval_id
                            FROM          dbo.t0130_asset_approval_det AS V0040_Asset_Return_1 WITH (NOLOCK)
                            WHERE      (Application_Type = 1)))
UNION
SELECT     bd.Brand_Name, am.Asset_Name, apd.asset_id, '' AS Application_date, '' AS Application_status, ad.Model AS Model_Name, ad.SerialNO, apd.Allocation_Date, 
                      ad.Asset_Code, ap.Emp_ID, ap.Cmp_ID, apd.assetM_Id, ap.Branch_ID, ad.Brand_id, ad.Purchase_date, apd.Return_Date, apd.asset_approval_id
FROM         t0120_asset_approval ap WITH (NOLOCK) INNER JOIN
                      t0130_asset_approval_det apd WITH (NOLOCK) ON ap.asset_approval_id = apd.asset_approval_id AND ap.cmp_id = apd.cmp_id INNER JOIN
                      t0040_asset_details ad WITH (NOLOCK) ON apd.assetM_Id = ad.assetM_Id AND apd.cmp_id = ad.cmp_id INNER JOIN
                      t0040_brand_master bd WITH (NOLOCK) ON ad.brand_id = bd.brand_id AND bd.cmp_id = ad.cmp_id INNER JOIN
                      t0040_Asset_master am WITH (NOLOCK) ON am.asset_id = apd.asset_id AND am.cmp_id = apd.cmp_id
WHERE     ap.asset_application_id = 0 AND apd.application_type = 0


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[5] 2[58] 3) )"
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
         Width = 1500
         Width = 1560
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return_Details';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return_Details';

