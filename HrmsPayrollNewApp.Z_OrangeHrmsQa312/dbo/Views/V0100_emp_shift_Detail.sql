


CREATE VIEW [dbo].[V0100_emp_shift_Detail]
AS
SELECT     esd.Shift_Tran_ID, esd.Emp_ID, esd.Cmp_ID, esd.Shift_ID, esd.For_Date, esd.Shift_Type, e.Emp_Full_Name, sm.Shift_Name, e.Emp_First_Name, 
                      bm.Branch_Name, e.Emp_code, i.Branch_ID, MONTH(esd.For_Date) AS Month, YEAR(esd.For_Date) AS Year, e.Alpha_Emp_Code
                      ,i.Vertical_ID,i.SubVertical_ID,i.Dept_ID  --Added By Jaina 17-09-2015
FROM         dbo.T0100_EMP_SHIFT_DETAIL AS esd WITH (NOLOCK) INNER JOIN
                      dbo.T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON esd.Shift_ID = sm.Shift_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON esd.Emp_ID = e.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON e.Increment_ID = i.Increment_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS bm WITH (NOLOCK)  ON e.Branch_ID = bm.Branch_ID INNER JOIN
                      T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK)  ON D.Dept_Id = i.Dept_ID   --Added By Jaina 17-09-2015





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
         Begin Table = "esd"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sm"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 396
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 78
         End
         Begin Table = "i"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "bm"
            Begin Extent = 
               Top = 126
               Left = 293
               Bottom = 241
               Right = 452
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
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_emp_shift_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_emp_shift_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_emp_shift_Detail';

