



CREATE VIEW [dbo].[V0040_KPI_Master]
AS
SELECT     dbo.T0040_KPI_Master.KPI_Id, dbo.T0040_KPI_Master.Cmp_Id, dbo.T0040_KPI_Master.Branch_Id, CASE WHEN T0040_KPI_Master.Branch_Id IS NOT NULL 
                      THEN
                          (SELECT     B.Branch_Name + ','
                            FROM          T0030_BRANCH_MASTER B WITH (NOLOCK)
                            WHERE      B.Branch_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0040_KPI_Master.Branch_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Branch_Name, dbo.T0040_KPI_Master.KPI, dbo.T0040_KPI_Master.Weightage, 
                      dbo.T0040_KPI_Master.Effective_Date, dbo.T0040_KPI_Master.Category_Id, dbo.T0030_CATEGORY_MASTER.Cat_Name, dbo.T0040_KPI_Master.Designation_Id, CASE WHEN T0040_KPI_Master.Designation_Id IS NOT NULL 
                      THEN
                          (SELECT     DG.Desig_Name + ','
                            FROM          T0040_DESIGNATION_MASTER DG WITH (NOLOCK)
                            WHERE      DG.Desig_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0040_KPI_Master.Designation_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Desig_Name,isnull(Active,1)Active
FROM         dbo.T0040_KPI_Master WITH (NOLOCK) LEFT OUTER JOIN
             dbo.T0030_CATEGORY_MASTER WITH (NOLOCK) ON dbo.T0030_CATEGORY_MASTER.Cat_ID = dbo.T0040_KPI_Master.Category_Id 



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[15] 2[29] 3) )"
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
         Begin Table = "T0040_KPI_Master"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 237
               Bottom = 125
               Right = 432
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_CATEGORY_MASTER"
            Begin Extent = 
               Top = 6
               Left = 470
               Bottom = 125
               Right = 635
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
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2160
         Width = 2250
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_KPI_Master';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_KPI_Master';

