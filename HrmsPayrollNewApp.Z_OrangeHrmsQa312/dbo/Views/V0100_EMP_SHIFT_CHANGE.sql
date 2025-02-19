/*SELECT     dbo.T0100_EMP_SHIFT_DETAIL.Shift_Tran_ID, dbo.T0100_EMP_SHIFT_DETAIL.Emp_ID, dbo.T0100_EMP_SHIFT_DETAIL.Cmp_ID, 
                      dbo.T0100_EMP_SHIFT_DETAIL.Shift_ID, dbo.T0100_EMP_SHIFT_DETAIL.For_Date, dbo.T0100_EMP_SHIFT_DETAIL.Shift_Type, 
                      (CASE WHEN dbo.T0100_EMP_SHIFT_DETAIL.Shift_type = 0 THEN 'Regular' WHEN dbo.T0100_EMP_SHIFT_DETAIL.Shift_Type = 1 THEN 'Temporary' END) 
                      AS Shift_Type1, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0040_SHIFT_MASTER.Shift_Name, B.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0080_EMP_MASTER.Emp_Superior, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, B.Vertical_ID, B.SubVertical_ID, B.Dept_ID, B.Cat_ID, B.Desig_Id, B.subBranch_ID, B.Segment_ID, B.Grd_ID, 
                      B.Type_ID
FROM         dbo.T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_EMP_SHIFT_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                          (SELECT     Emp_ID, Branch_ID, Cmp_ID, SubVertical_ID, Vertical_ID, Dept_ID, Cat_ID, Desig_Id, subBranch_ID, Segment_ID, Grd_ID, Type_ID
                            FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK) 
                            WHERE      (Increment_ID =
                                                       (SELECT     TOP (1) Increment_ID
                                                         FROM          dbo.T0095_INCREMENT AS I1 WITH (NOLOCK) 
                                                         WHERE      (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
                                                         ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B 
														 ON B.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      B.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID INNER JOIN
                      dbo.T0040_SHIFT_MASTER WITH (NOLOCK)  ON dbo.T0100_EMP_SHIFT_DETAIL.Shift_ID = dbo.T0040_SHIFT_MASTER.Shift_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON B.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID*/
CREATE VIEW dbo.V0100_EMP_SHIFT_CHANGE
AS
SELECT     dbo.T0100_EMP_SHIFT_DETAIL.Shift_Tran_ID, dbo.T0100_EMP_SHIFT_DETAIL.Emp_ID, dbo.T0100_EMP_SHIFT_DETAIL.Cmp_ID, dbo.T0100_EMP_SHIFT_DETAIL.Shift_ID, dbo.T0100_EMP_SHIFT_DETAIL.For_Date, dbo.T0100_EMP_SHIFT_DETAIL.Shift_Type, 
                  (CASE WHEN dbo.T0100_EMP_SHIFT_DETAIL.Shift_type = 0 THEN 'Regular' WHEN dbo.T0100_EMP_SHIFT_DETAIL.Shift_Type = 1 THEN 'Temporary' END) AS Shift_Type1, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                  dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_SHIFT_MASTER.Shift_Name, B.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, B.Vertical_ID, B.SubVertical_ID, B.Dept_ID, B.Cat_ID, 
                  B.Desig_Id, B.subBranch_ID, B.Segment_ID, B.Grd_ID, B.Type_ID
FROM        dbo.T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) INNER JOIN
                  dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0100_EMP_SHIFT_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      (SELECT     Emp_ID, Branch_ID, Cmp_ID, SubVertical_ID, Vertical_ID, Dept_ID, Cat_ID, Desig_Id, subBranch_ID, Segment_ID, Grd_ID, Type_ID
                       FROM        dbo.T0095_INCREMENT AS I WITH (NOLOCK)
                       WHERE     (Increment_ID =
                                             (SELECT     TOP (1) Increment_ID
                                              FROM        dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)
                                              WHERE     (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
                                              ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND B.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID INNER JOIN
                  dbo.T0040_SHIFT_MASTER WITH (NOLOCK) ON dbo.T0100_EMP_SHIFT_DETAIL.Shift_ID = dbo.T0040_SHIFT_MASTER.Shift_ID AND dbo.T0100_EMP_SHIFT_DETAIL.Cmp_ID = dbo.T0040_SHIFT_MASTER.Cmp_ID AND B.Cmp_ID = dbo.T0100_EMP_SHIFT_DETAIL.Cmp_ID INNER JOIN
                  dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON B.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                  dbo.T0040_Vertical_Segment WITH (NOLOCK) ON B.Vertical_ID = dbo.T0040_Vertical_Segment.Vertical_ID
WHERE     (dbo.T0080_EMP_MASTER.Emp_Left <> 'Y')

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
         Begin Table = "T0100_EMP_SHIFT_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 76
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 113
               Left = 16
               Bottom = 276
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_SHIFT_MASTER"
            Begin Extent = 
               Top = 126
               Left = 284
               Bottom = 241
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Vertical_Segment"
            Begin Extent = 
               Top = 7
               Left = 493
               Bottom = 170
               Right = 720
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
         Width = 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_EMP_SHIFT_CHANGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'84
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
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_EMP_SHIFT_CHANGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_EMP_SHIFT_CHANGE';

