



CREATE VIEW [dbo].[V0040_Asset_Return_Details1]
AS
SELECT DISTINCT 
                      bd.BRAND_Name, am.Asset_Name, apd.Asset_ID, '' AS Application_date, '' AS Application_status, ad.Model AS Model_Name, ad.SerialNo, apd.Allocation_Date, 
                      ad.Asset_Code, ap.Emp_ID, ap.Cmp_ID, apd.AssetM_ID, ap.Branch_ID, ad.BRAND_ID, ad.Purchase_date, apd.Return_Date, ad.Asset_Status, ap.Asset_Approval_ID, 
                      ap.Asset_Application_ID, apd.Return_asset_approval_id, apd.Application_Type, ad.allocation, ap.Dept_Id, ap.Status, apd.Approval_status, ap.Transfer_Emp_Id, 
                      ap.Transfer_Branch_Id, ap.Transfer_Dept_Id, apd.Asset_ApprDet_ID, apd.Transfer_Id, ad.Description,ap.Branch_For_Dept,ap.Transfer_Branch_For_Dept
FROM         dbo.T0120_Asset_Approval AS ap WITH (NOLOCK) INNER JOIN
                      dbo.T0130_Asset_Approval_Det AS apd WITH (NOLOCK)  ON ap.Asset_Approval_ID = apd.Asset_Approval_ID AND ap.Cmp_ID = apd.Cmp_ID INNER JOIN
                      dbo.T0040_Asset_Details AS ad WITH (NOLOCK)  ON apd.AssetM_ID = ad.AssetM_ID AND apd.Cmp_ID = ad.Cmp_ID INNER JOIN
                      dbo.T0040_BRAND_MASTER AS bd WITH (NOLOCK)  ON ad.BRAND_ID = bd.BRAND_ID AND bd.Cmp_ID = ad.Cmp_ID INNER JOIN
                      dbo.T0040_ASSET_MASTER AS am WITH (NOLOCK)  ON am.Asset_ID = apd.Asset_ID AND am.Cmp_ID = apd.Cmp_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[46] 4[5] 2[15] 3) )"
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
         Begin Table = "ap"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "apd"
            Begin Extent = 
               Top = 6
               Left = 270
               Bottom = 244
               Right = 452
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "ad"
            Begin Extent = 
               Top = 6
               Left = 490
               Bottom = 226
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 10
         End
         Begin Table = "bd"
            Begin Extent = 
               Top = 6
               Left = 698
               Bottom = 125
               Right = 858
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "am"
            Begin Extent = 
               Top = 6
               Left = 896
               Bottom = 154
               Right = 1056
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
      Begin ColumnWidths = 26
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
         Width = 15', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return_Details1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return_Details1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'00
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return_Details1';

