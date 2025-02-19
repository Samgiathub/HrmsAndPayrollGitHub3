



CREATE VIEW [dbo].[Get_Emp_Superior]
AS
SELECT     EM.Emp_Left, EM.Cmp_ID, EM.Branch_ID, EM.Emp_ID, CAST(EM.Alpha_Emp_Code AS varchar) + ' - ' + EM.Emp_Full_Name AS Emp_Full_Name, DM.Def_ID, 
                      EM2.Emp_ID AS Superior_Id, CAST(EM2.Alpha_Emp_Code AS varchar) + ' - ' + EM2.Emp_Full_Name AS Emp_Superior, EM2.Emp_Left_Date
FROM         dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM2 WITH (NOLOCK)  ON EM2.Emp_ID = EM.Emp_Superior INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS DM WITH (NOLOCK)  ON EM2.Desig_Id = DM.Desig_ID
WHERE     (EM2.Emp_Left <> 'y')



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Get_Emp_Superior';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[11] 2[15] 3) )"
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
         Begin Table = "EM"
            Begin Extent = 
               Top = 14
               Left = 291
               Bottom = 129
               Right = 508
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM2"
            Begin Extent = 
               Top = 43
               Left = 37
               Bottom = 158
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 40
         End
         Begin Table = "DM"
            Begin Extent = 
               Top = 6
               Left = 534
               Bottom = 121
               Right = 686
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
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2685
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Get_Emp_Superior';

