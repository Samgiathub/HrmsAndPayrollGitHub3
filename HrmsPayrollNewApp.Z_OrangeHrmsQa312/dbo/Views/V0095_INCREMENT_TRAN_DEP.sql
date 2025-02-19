





/*i.Increment_ID  not in (select Increment_ID from T0080_emp_master )*/
CREATE VIEW [dbo].[V0095_INCREMENT_TRAN_DEP]
AS
SELECT     e.Emp_Full_Name, I.Increment_ID, I.Emp_ID, I.Cmp_ID, I.Branch_ID, I.Cat_ID, I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, I.Bank_ID, I.Curr_ID, 
                      I.Wages_Type, I.Salary_Basis_On, I.Basic_Salary, I.Gross_Salary, I.Increment_Type, I.Increment_Date, I.Increment_Effective_Date, I.Payment_Mode, 
                      I.Inc_Bank_AC_No, I.Emp_OT, I.Emp_OT_Min_Limit, I.Emp_OT_Max_Limit, I.Increment_Per, I.Increment_Amount, I.Pre_Basic_Salary, 
                      I.Pre_Gross_Salary, I.Increment_Comments, I.Emp_Late_mark, I.Emp_Full_PF, I.Emp_PT, I.Emp_Fix_Salary, e.Emp_First_Name, e.Emp_code, 
                      e.Emp_Left, b.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, I.Yearly_Bonus_Amount, I.Deputation_End_Date, ISNULL(I.CTC, 0) AS CTC, 
                      ISNULL(I.Center_ID, 0) AS Center_ID, e.Alpha_Emp_Code
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = I.Grd_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON I.Emp_ID = e.Emp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS b WITH (NOLOCK)  ON I.Branch_ID = b.Branch_ID
WHERE     (ISNULL(I.Is_Master_Rec, 0) = 0) AND (I.Increment_Type <> 'Joining') AND (I.Increment_Type = 'Transfer' OR
                      I.Increment_Type = 'Deputation')





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_INCREMENT_TRAN_DEP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_INCREMENT_TRAN_DEP';


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
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 9
               Left = 410
               Bottom = 216
               Right = 618
            End
            DisplayFlags = 280
            TopColumn = 42
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 15
               Left = 691
               Bottom = 130
               Right = 908
            End
            DisplayFlags = 280
            TopColumn = 75
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 110
               Left = 188
               Bottom = 225
               Right = 347
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
      Begin ColumnWidths = 43
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
         Width = 1500
         Width = 1500
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_INCREMENT_TRAN_DEP';

