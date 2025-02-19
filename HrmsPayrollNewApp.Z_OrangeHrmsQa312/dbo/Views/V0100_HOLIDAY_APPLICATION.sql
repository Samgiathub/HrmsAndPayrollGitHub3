



CREATE VIEW [dbo].[V0100_HOLIDAY_APPLICATION]
AS
SELECT     dbo.T0040_HOLIDAY_MASTER.Hday_Name, T0080_EMP_MASTER.Emp_ID,T0080_EMP_MASTER.Cmp_ID,
			Convert(varchar(10), T0040_HOLIDAY_MASTER.H_From_Date, 103) as H_From_Date,
		   Convert(varchar(10), T0040_HOLIDAY_MASTER.H_To_Date, 103) as H_To_Date,
		   dbo.T0100_OP_Holiday_Application.HDay_ID, 
		   Convert(varchar(10), dbo.T0100_OP_Holiday_Application.Op_Holiday_Date, 103) as Op_Holiday_Date, 
		   Op_Holiday_App_ID,
                      dbo.T0100_OP_Holiday_Application.Op_Holiday_Status, dbo.T0080_EMP_MASTER.Emp_Full_Name,
                      cast(dbo.T0080_EMP_MASTER.Emp_code as varchar(100)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name  AS Emp_Full_Name_Detail
FROM         dbo.T0040_HOLIDAY_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0100_OP_Holiday_Application WITH (NOLOCK) ON dbo.T0040_HOLIDAY_MASTER.Hday_ID = dbo.T0100_OP_Holiday_Application.HDay_ID AND 
                      dbo.T0040_HOLIDAY_MASTER.Hday_ID = dbo.T0100_OP_Holiday_Application.HDay_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0100_OP_Holiday_Application.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID




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
         Begin Table = "T0040_HOLIDAY_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0100_OP_Holiday_Application"
            Begin Extent = 
               Top = 6
               Left = 258
               Bottom = 125
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 140
               Left = 365
               Bottom = 259
               Right = 590
            End
            DisplayFlags = 280
            TopColumn = 38
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_HOLIDAY_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_HOLIDAY_APPLICATION';

