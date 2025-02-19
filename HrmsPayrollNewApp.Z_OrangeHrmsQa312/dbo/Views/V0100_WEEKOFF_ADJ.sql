


CREATE VIEW [dbo].[V0100_WEEKOFF_ADJ]
AS

SELECT     WA.W_Tran_ID, WA.Emp_ID, WA.Cmp_ID, WA.For_Date, 
                      WA.Weekoff_Day, E.Emp_First_Name, E.Emp_Last_Name, 
                      G.Grd_Name, E.Emp_Full_Name, E.Emp_Left, 
                      I.Branch_ID, --Change by ronakk 23022022
					  E.Emp_code, WA.Weekoff_Day_Value, 
                      B.Branch_Name, B.Branch_Code, E.Emp_Superior, 
                      E.Alpha_Emp_Code, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id, 
                      I.subBranch_ID, I.Segment_ID,WA.Alt_W_Name,WA.Alt_W_Full_Day_Cont,
                      CASE WHEN WA.Alt_W_Name = '' THEN '' ELSE (WA.Alt_W_Name +' [' + WA.Alt_W_Full_Day_Cont +']') END AS alt_W_Name_Day_Count,weekOffOddEven
FROM	dbo.T0100_WEEKOFF_ADJ WA WITH (NOLOCK)
		INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON WA.Emp_ID=E.Emp_ID
		INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID=E.Emp_ID
		CROSS APPLY (SELECT * FROM dbo.fn_getEmpIncrement(E.Cmp_ID,E.Emp_ID,getdate()) T WHERE I.Increment_ID=T.Increment_ID) T
		INNER JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON I.Branch_ID = B.Branch_ID
		LEFT OUTER JOIN T0040_GRADE_MASTER G WITH (NOLOCK) ON I.Grd_ID = G.Grd_ID
		where isnull(WA.IsMakerChecker,0) <> 1 



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
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 197
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "V0080_Employee_Master"
            Begin Extent = 
               Top = 9
               Left = 428
               Bottom = 173
               Right = 645
            End
            DisplayFlags = 280
            TopColumn = 96
         End
         Begin Table = "T0100_WEEKOFF_ADJ"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 227
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_WEEKOFF_ADJ';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_WEEKOFF_ADJ';

