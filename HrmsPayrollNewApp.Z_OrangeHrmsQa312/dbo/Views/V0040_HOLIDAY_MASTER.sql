




CREATE VIEW [dbo].[V0040_HOLIDAY_MASTER]
AS
SELECT     dbo.T0040_HOLIDAY_MASTER.Hday_ID, dbo.T0040_HOLIDAY_MASTER.cmp_Id, dbo.T0040_HOLIDAY_MASTER.Hday_Name, CONVERT(varchar(12), 
                      dbo.T0040_HOLIDAY_MASTER.H_From_Date, 103) AS H_From_Date, CONVERT(varchar(10), dbo.T0040_HOLIDAY_MASTER.H_To_Date, 103) 
                      AS H_To_Date, dbo.T0040_HOLIDAY_MASTER.Is_Fix, dbo.T0040_HOLIDAY_MASTER.Hday_Ot_setting, dbo.T0040_HOLIDAY_MASTER.Branch_ID, 
                      dbo.T0040_HOLIDAY_MASTER.Is_Half AS Branch_Code, ISNULL(dbo.T0030_BRANCH_MASTER.Branch_Name, 'All') AS Branch_Name, 
                      dbo.T0040_HOLIDAY_MASTER.Is_Optional, 
                      CASE WHEN dbo.T0040_HOLIDAY_MASTER.is_National_Holiday = 0 THEN 'National' ELSE 'Festival' END AS is_National_Holiday, 
                      CASE WHEN isnull(dbo.T0040_HOLIDAY_MASTER.Is_Optional, 0) = 0 THEN 'No' ELSE 'Yes' END AS Is_Optional1, 
                      dbo.T0040_HOLIDAY_MASTER.H_From_Date AS H_From_Date1, dbo.T0040_HOLIDAY_MASTER.H_To_Date AS H_To_Date1
FROM         dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0040_HOLIDAY_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[20] 4[4] 2[47] 3) )"
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
         Begin Table = "T0040_HOLIDAY_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 239
               Bottom = 121
               Right = 398
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 16
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_HOLIDAY_MASTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_HOLIDAY_MASTER';

