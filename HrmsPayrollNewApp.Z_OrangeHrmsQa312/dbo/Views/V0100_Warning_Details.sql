





CREATE VIEW [dbo].[V0100_Warning_Details]
AS
SELECT     WD.War_Tran_ID, WD.Emp_Id, WD.Warr_Date, WD.Warr_Reason, WD.Issue_By, WD.Authorised_By, WM.War_Name, WM.Deduct_Rate, 
                      e.Emp_code, e.Emp_Full_Name, sm.Shift_Name, WD.Shift_ID, i.Branch_ID, i.Dept_ID, i.Grd_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_GRADE_MASTER.Grd_Name, e.Emp_First_Name, WM.War_ID, e.Cmp_ID, 
                      e.Alpha_Emp_Code, e.Emp_Superior,i.Vertical_ID,i.SubVertical_ID  --Added By Jaina 19-09-2015
                      ,WD.Level_Id,C.Level_Name,C.No_Of_Card,C.Card_Color,WD.Action_Taken_Date,WD.Action_Detail
FROM         dbo.T0100_WARNING_DETAIL AS WD WITH (NOLOCK) INNER JOIN
                      dbo.T0040_WARNING_MASTER AS WM WITH (NOLOCK)  ON WD.War_ID = WM.War_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON WD.Emp_Id = e.Emp_ID LEFT OUTER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON e.Increment_ID = i.Increment_ID LEFT OUTER JOIN
                      dbo.T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON WD.Shift_ID = sm.Shift_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON i.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON i.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON i.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      T0040_Warning_CardMapping C WITH (NOLOCK)  ON C.Level_Id = WD.Level_Id AND C.Cmp_Id = WD.Cmp_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 366
               Left = 228
               Bottom = 481
               Right = 403
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
      Begin ColumnWidths = 24
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Warning_Details';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Warning_Details';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[8] 4[4] 2[52] 3) )"
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
         Begin Table = "WD"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "WM"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 385
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
            TopColumn = 45
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
         Begin Table = "sm"
            Begin Extent = 
               Top = 126
               Left = 293
               Bottom = 241
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 246
               Left = 284
               Bottom = 361
               Right = 443
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 190
            End
            DisplayFlags = 280
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Warning_Details';

