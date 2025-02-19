




CREATE VIEW [dbo].[V0095_INCREMENT]
AS
SELECT     e.Emp_Full_Name, I.Increment_ID, I.Emp_ID, I.Cmp_ID, I.Branch_ID, I.Cat_ID, I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, I.Bank_ID, I.Curr_ID, I.Wages_Type, I.Salary_Basis_On, 
                      dbo.F_Show_Decimal(ISNULL(I.Basic_Salary,0), I.Cmp_ID) AS Basic_Salary, dbo.F_Show_Decimal(ISNULL(I.Gross_Salary,0), I.Cmp_ID) AS Gross_Salary, I.Increment_Type, I.Increment_Date, I.Increment_Effective_Date, 
                      I.Payment_Mode, I.Inc_Bank_AC_No, I.Emp_OT, I.Emp_OT_Min_Limit, I.Emp_OT_Max_Limit, I.Increment_Per, dbo.F_Show_Decimal(I.Increment_Amount, I.Cmp_ID) AS Increment_Amount, 
                      dbo.F_Show_Decimal(ISNULL(I.Pre_Basic_Salary,0), I.Cmp_ID) AS Pre_Basic_Salary, dbo.F_Show_Decimal(ISNULL(I.Pre_Gross_Salary,0), I.Cmp_ID) AS Pre_Gross_Salary, I.Increment_Comments, ISNULL(I.Emp_Late_mark,0) AS Emp_Late_mark, 
                      I.Emp_Full_PF, I.Emp_PT, I.Emp_Fix_Salary, e.Emp_First_Name, e.Emp_code, e.Emp_Left, b.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, I.Yearly_Bonus_Amount, 
                      I.Deputation_End_Date, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.F_Show_Decimal(ISNULL(I.CTC, 0), I.Cmp_ID) AS CTC, ISNULL(I.Center_ID, 0) AS Center_ID, e.Alpha_Emp_Code, 
                      dbo.F_Show_Decimal(ISNULL(I.Pre_CTC_Salary,0), I.Cmp_ID) AS Pre_CTC_Salary, dbo.F_Show_Decimal(ISNULL(I.Incerment_Amount_gross,0), I.Cmp_ID) AS Incerment_Amount_gross, 
                      dbo.F_Show_Decimal(ISNULL(I.Incerment_Amount_CTC,0), I.Cmp_ID) AS Incerment_Amount_CTC, I.Increment_Mode, I.is_physical, I.Segment_ID, I.Vertical_ID, I.SubVertical_ID, I.subBranch_ID, 
                      I.Emp_Auto_Vpf, e.GroupJoiningDate, I.SalDate_id, I.Reason_ID, I.Reason_Name,I.Customer_Audit,I.Sales_Code,i.Is_Piece_Trans_Salary  --Added By Jaina 22-08-2016	--SalesCode By Ramiz on 08122016
					  ,I.Band_Id,I.Is_Pradhan_Mantri,I.Is_1time_PF_Member  --added by mansi 200821 
					  ,i.System_Date,isnull(i.Remarks,'') as Remarks
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = I.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON I.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON I.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS b WITH (NOLOCK)  ON I.Branch_ID = b.Branch_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON I.Emp_ID = e.Emp_ID
WHERE     (I.Increment_Type <> 'Joining') AND (ISNULL(I.Is_Master_Rec, 0) = 0)





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
               Top = 0
               Left = 495
               Bottom = 115
               Right = 703
            End
            DisplayFlags = 280
            TopColumn = 61
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 126
               Left = 228
               Bottom = 241
               Right = 380
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 197
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 215
               Left = 570
               Bottom = 330
               Right = 787
            End
            DisplayFlags = 280
            TopColumn = 95
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 44
         Width = 284
         Width = 1500
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_INCREMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_INCREMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_INCREMENT';

