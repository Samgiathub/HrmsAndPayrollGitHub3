﻿


CREATE VIEW [dbo].[V0020_PRIVILEGE_MASTER]
AS
SELECT     dbo.T0020_PRIVILEGE_MASTER.Privilege_ID, dbo.T0020_PRIVILEGE_MASTER.Cmp_Id, dbo.T0020_PRIVILEGE_MASTER.Privilege_Name, 
                      dbo.T0020_PRIVILEGE_MASTER.Is_Active, dbo.T0020_PRIVILEGE_MASTER.Privilege_Type, dbo.T0020_PRIVILEGE_MASTER.Branch_Id, 
                      dbo.T0030_BRANCH_MASTER.Branch_Code, dbo.T0020_PRIVILEGE_MASTER.Branch_Id_Multi,dbo.T0020_PRIVILEGE_MASTER.Vertical_ID_Multi,dbo.T0020_PRIVILEGE_MASTER.SubVertical_ID_Multi,
                      CASE WHEN dbo.T0020_PRIVILEGE_MASTER.Branch_Id_Multi IS NOT NULL 
						THEN (SELECT bm1.Branch_Name + ', ' 
							  FROM T0030_BRANCH_MASTER BM1 WITH (NOLOCK)
							  WHERE Branch_ID in (SELECT cast(data as numeric(18,0)) 
												  FROM dbo.Split(isnull(dbo.T0020_PRIVILEGE_MASTER.Branch_Id_Multi,'0'),'#')) for xml path('')
												  ) 
						ELSE 'ALL' END As Branch_Name,dbo.T0020_PRIVILEGE_MASTER.Department_Id_Multi
FROM         dbo.T0020_PRIVILEGE_MASTER  WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0020_PRIVILEGE_MASTER.Branch_Id = dbo.T0030_BRANCH_MASTER.Branch_ID AND 
                      dbo.T0020_PRIVILEGE_MASTER.Cmp_Id = dbo.T0030_BRANCH_MASTER.Cmp_ID





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
         Begin Table = "T0020_PRIVILEGE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 28
               Left = 356
               Bottom = 143
               Right = 515
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
         Width = 3660
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0020_PRIVILEGE_MASTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0020_PRIVILEGE_MASTER';

