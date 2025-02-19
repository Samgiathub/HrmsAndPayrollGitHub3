






CREATE VIEW [dbo].[V_Emp_Cons]  
AS  
SELECT    
		T0100_EMP_SHIFT_DETAIL.Shift_ID, 
		T0080_EMP_MASTER.Date_Of_Join As Join_Date, T0080_EMP_MASTER.Emp_Left_Date As Left_Date, T0095_INCREMENT.Emp_ID, T0095_INCREMENT.Cmp_ID, 
		T0095_INCREMENT.Branch_ID, T0095_INCREMENT.Cat_ID, T0095_INCREMENT.Grd_ID, T0095_INCREMENT.Dept_ID, T0095_INCREMENT.Desig_Id, 
		T0095_INCREMENT.Type_ID, T0095_INCREMENT.Bank_ID, T0095_INCREMENT.Curr_ID, T0095_INCREMENT.Increment_Effective_Date, 
		T0080_EMP_MASTER.Emp_code, T0080_EMP_MASTER.Initial, T0080_EMP_MASTER.Emp_First_Name, T0080_EMP_MASTER.Emp_Second_Name, 
		T0080_EMP_MASTER.Emp_Last_Name, T0080_EMP_MASTER.Date_Of_Birth, T0080_EMP_MASTER.Gender, T0095_INCREMENT.Increment_ID, 
		T0080_EMP_MASTER.Date_Of_Join, T0095_INCREMENT.SalDate_id, T0095_INCREMENT.Segment_ID, T0095_INCREMENT.Vertical_ID, 
		T0095_INCREMENT.SubVertical_ID, T0095_INCREMENT.subBranch_ID, T0080_EMP_MASTER.Emp_Left, T0095_INCREMENT.Center_ID,T0095_INCREMENT.Band_Id
		,T0080_EMP_MASTER.Alpha_Emp_Code --Added by ronakk 28042023
FROM	T0095_INCREMENT  WITH (NOLOCK)
		--LEFT OUTER JOIN T0110_EMP_LEFT_JOIN_TRAN ON T0095_INCREMENT.Emp_ID = T0110_EMP_LEFT_JOIN_TRAN.Emp_ID AND T0095_INCREMENT.Cmp_ID = T0110_EMP_LEFT_JOIN_TRAN.Cmp_ID 
		LEFT OUTER JOIN T0080_EMP_MASTER  WITH (NOLOCK) ON T0095_INCREMENT.Emp_ID = T0080_EMP_MASTER.Emp_ID AND T0095_INCREMENT.Cmp_ID = T0080_EMP_MASTER.Cmp_ID
		LEFT OUTER JOIN T0100_EMP_SHIFT_DETAIL  WITH (NOLOCK) on T0095_INCREMENT.Emp_ID = T0100_EMP_SHIFT_DETAIL.Emp_ID AND T0095_INCREMENT.Cmp_ID=T0100_EMP_SHIFT_DETAIL.Cmp_ID 
						and Shift_Tran_ID = (
												SELECT	TOP 1 Shift_Tran_ID 
												FROM	T0100_EMP_SHIFT_DETAIL  WITH (NOLOCK)  
												WHERE	Emp_ID = T0095_INCREMENT.Emp_ID
												ORDER BY For_Date DESC
											)
  
  



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[59] 4[2] 2[20] 3) )"
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
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 63
         End
         Begin Table = "T0110_EMP_LEFT_JOIN_TRAN"
            Begin Extent = 
               Top = 6
               Left = 288
               Bottom = 121
               Right = 444
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 37
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V_Emp_Cons';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V_Emp_Cons';

