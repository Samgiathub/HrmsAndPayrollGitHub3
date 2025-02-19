


CREATE VIEW [dbo].[V0040_Asset_Return]
AS
SELECT     dbo.T0040_BRAND_MASTER.BRAND_Name, dbo.T0040_ASSET_MASTER.Asset_Name, dbo.T0040_ASSET_MASTER.Asset_ID, 
                      dbo.T0100_Asset_Application.Application_date, dbo.T0100_Asset_Application.Application_status, dbo.T0130_Asset_Approval_Det.Model_Name, 
                      dbo.T0130_Asset_Approval_Det.Serial_No, dbo.T0130_Asset_Approval_Det.Asset_ID AS Expr1, dbo.T0100_Asset_Application.Asset_ID AS Asset_ID1, 
                      dbo.T0130_Asset_Approval_Det.Asset_Code, dbo.T0120_Asset_Approval.Emp_ID, dbo.T0130_Asset_Approval_Det.Cmp_ID, 
                      dbo.T0130_Asset_Approval_Det.Purchase_date, dbo.T0130_Asset_Approval_Det.Brand_Id, dbo.T0100_Asset_Application.Application_Type, 
                      dbo.T0120_Asset_Approval.Branch_ID, dbo.T0100_Asset_Application.Application_code, dbo.T0130_Asset_Approval_Det.Return_Date, 
                      dbo.T0130_Asset_Approval_Det.AssetM_ID, dbo.T0130_Asset_Approval_Det.Allocation_Date, dbo.T0130_Asset_Approval_Det.Return_asset_approval_id, 
                      dbo.T0120_Asset_Approval.Status, dbo.T0120_Asset_Approval.Asset_Approval_ID, dbo.T0120_Asset_Approval.Applied_by, dbo.T0120_Asset_Approval.Dept_Id, 
                      dbo.T0130_Asset_Approval_Det.Approval_status, dbo.T0100_Asset_Application.Asset_Application_ID, dbo.T0120_Asset_Approval.Transfer_Emp_Id, 
                      dbo.T0120_Asset_Approval.Transfer_Branch_Id, dbo.T0120_Asset_Approval.Transfer_Dept_Id
FROM         dbo.T0040_BRAND_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0040_ASSET_MASTER WITH (NOLOCK)  INNER JOIN
                      dbo.T0120_Asset_Approval WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0100_Asset_Application WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Asset_Application_ID = dbo.T0100_Asset_Application.Asset_Application_ID INNER JOIN
                      dbo.T0130_Asset_Approval_Det WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID ON 
                      dbo.T0040_ASSET_MASTER.Asset_ID = dbo.T0130_Asset_Approval_Det.Asset_ID ON 
                      dbo.T0040_BRAND_MASTER.BRAND_ID = dbo.T0130_Asset_Approval_Det.Brand_Id


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[28] 4[5] 2[53] 3) )"
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
         Begin Table = "T0040_BRAND_MASTER"
            Begin Extent = 
               Top = 223
               Left = 848
               Bottom = 400
               Right = 1008
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_ASSET_MASTER"
            Begin Extent = 
               Top = 175
               Left = 174
               Bottom = 375
               Right = 334
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_Asset_Approval"
            Begin Extent = 
               Top = 3
               Left = 478
               Bottom = 208
               Right = 672
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "T0100_Asset_Application"
            Begin Extent = 
               Top = 25
               Left = 80
               Bottom = 144
               Right = 271
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_Asset_Approval_Det"
            Begin Extent = 
               Top = 29
               Left = 1066
               Bottom = 298
               Right = 1292
            End
            DisplayFlags = 280
            TopColumn = 3
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 28
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
         Width = 2670
         Wid', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'th = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Return';

