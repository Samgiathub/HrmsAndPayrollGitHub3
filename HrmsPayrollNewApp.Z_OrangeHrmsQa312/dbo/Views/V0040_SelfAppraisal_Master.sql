





CREATE VIEW [dbo].[V0040_SelfAppraisal_Master]
AS
SELECT     dbo.T0040_SelfAppraisal_Master.SApparisal_ID, dbo.T0040_SelfAppraisal_Master.Cmp_ID, dbo.T0040_SelfAppraisal_Master.SApparisal_Content, SWeight, 
                      dbo.T0040_SelfAppraisal_Master.SAppraisal_Sort, dbo.T0040_SelfAppraisal_Master.SDept_Id, CASE WHEN dbo.T0040_SelfAppraisal_Master.SDept_Id IS NOT NULL 
                      THEN
                          (SELECT     d .Dept_Name + ','
                            FROM          T0040_DEPARTMENT_MASTER d WITH (NOLOCK)
                            WHERE      Dept_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0040_SelfAppraisal_Master.SDept_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE '' END AS Dept_Name,
    CASE WHEN dbo.T0040_SelfAppraisal_Master.SCateg_Id IS NOT NULL 
                      THEN
                          (SELECT     c.Desig_Name + ','
                            FROM          T0040_DESIGNATION_MASTER c WITH (NOLOCK)
                            WHERE      c.Desig_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0040_SelfAppraisal_Master.SCateg_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE '' END AS Category,
   CASE WHEN dbo.T0040_SelfAppraisal_Master.SBranch_Id IS NOT NULL 
                      THEN
                          (SELECT     b.Branch_Name + ','
                            FROM          T0030_BRANCH_MASTER b WITH (NOLOCK)
                            WHERE      b.Branch_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0040_SelfAppraisal_Master.SBranch_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE '' END AS Branch,
   dbo.T0040_SelfAppraisal_Master.SIsMandatory,dbo.T0040_SelfAppraisal_Master.SType, isnull(Effective_Date,
                          (SELECT     From_Date
                            FROM          T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      Cmp_Id = dbo.T0040_SelfAppraisal_Master.Cmp_ID)) Effective_Date, case when SType = 2 then isnull(SKPAWeight,1) else isnull(SKPAWeight,0) end SKPAWeight
FROM         dbo.T0040_SelfAppraisal_Master WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0040_SelfAppraisal_Master.SDept_Id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[11] 3) )"
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
         Begin Table = "T0040_SelfAppraisal_Master"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 6
               Left = 260
               Bottom = 125
               Right = 420
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_SelfAppraisal_Master';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_SelfAppraisal_Master';

