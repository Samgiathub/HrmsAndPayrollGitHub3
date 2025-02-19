


CREATE VIEW [dbo].[V0040_Asset_Details_Report]
AS
SELECT     dbo.T0040_Asset_Details.Vendor, dbo.T0040_Asset_Details.Vendor_Address, dbo.T0040_Asset_Details.City, dbo.T0040_Asset_Details.PONO, 
                      dbo.T0040_Asset_Details.Invoice_No, dbo.T0040_Asset_Details.Invoice_Date, dbo.T0040_Asset_Details.pono_Date, 
                      dbo.T0110_Asset_Installation_Details.Installation_Details
FROM         dbo.T0030_Asset_Installation WITH (NOLOCK) INNER JOIN
                      dbo.T0110_Asset_Installation_Details WITH (NOLOCK)  ON 
                      dbo.T0030_Asset_Installation.Asset_Installation_ID = dbo.T0110_Asset_Installation_Details.Asset_Installation_ID INNER JOIN
                      dbo.T0040_Asset_Details WITH (NOLOCK)  ON dbo.T0110_Asset_Installation_Details.AssetM_Id = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
                      dbo.T0120_Asset_Approval WITH (NOLOCK)  ON dbo.T0110_Asset_Installation_Details.Asset_Approval_ID = dbo.T0120_Asset_Approval.Asset_Approval_ID INNER JOIN
                      dbo.T0130_Asset_Approval_Det WITH (NOLOCK)  ON dbo.T0040_Asset_Details.AssetM_ID = dbo.T0130_Asset_Approval_Det.AssetM_ID AND 
                      dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID


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
         Begin Table = "T0030_Asset_Installation"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_Asset_Details"
            Begin Extent = 
               Top = 6
               Left = 268
               Bottom = 125
               Right = 438
            End
            DisplayFlags = 280
            TopColumn = 24
         End
         Begin Table = "T0110_Asset_Installation_Details"
            Begin Extent = 
               Top = 6
               Left = 476
               Bottom = 125
               Right = 684
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_Asset_Approval"
            Begin Extent = 
               Top = 6
               Left = 722
               Bottom = 125
               Right = 916
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "T0130_Asset_Approval_Det"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 254
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
    ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Details_Report';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  Begin ColumnWidths = 11
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Details_Report';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Details_Report';

