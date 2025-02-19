


CREATE VIEW [dbo].[V0201_MONTHLY_SALARY_SETT_GET]
AS
SELECT     MS.S_Sal_Tran_ID, MS.S_Sal_Receipt_No, MS.Emp_ID, MS.Cmp_ID, MS.Increment_ID, MS.S_Month_St_Date, MS.S_Month_End_Date, MS.S_Sal_Generate_Date, MS.S_Sal_Cal_Days, 
                      MS.S_Shift_Day_Sec, MS.S_Shift_Day_Hour, MS.S_Basic_Salary, MS.S_Day_Salary, MS.S_Hour_Salary, MS.S_Salary_Amount, MS.S_Allow_Amount, MS.S_OT_Amount, 
                      MS.S_Other_Allow_Amount, MS.S_Gross_Salary, MS.S_Dedu_Amount, MS.S_Loan_Amount, MS.S_Loan_Intrest_Amount, MS.S_Advance_Amount, MS.S_Other_Dedu_Amount, 
                      MS.S_Total_Dedu_Amount, MS.S_Due_Loan_Amount, MS.S_Net_Amount, MS.S_Actually_Gross_Salary, MS.S_PT_Amount, MS.S_PT_Calculated_Amount, MS.S_Total_Claim_Amount, 
                      MS.S_M_OT_Hours, MS.S_M_Adv_Amount, MS.S_M_Loan_Amount, MS.S_M_IT_Tax, MS.S_LWF_Amount, MS.S_Revenue_Amount, MS.S_PT_F_T_Limit, e.Dept_ID, e.Grd_ID, i.Branch_ID, 
                      e.Emp_Full_Name, BM.Branch_Name, e.Other_Email, e.Emp_code AS Emp_Code1, e.Alpha_Emp_Code AS Emp_Code, MS.S_Eff_Date, i.Vertical_ID, i.SubVertical_ID, ISNULL(MS.Effect_On_Salary, 
                      0) AS Effect_On_Salary
FROM         dbo.T0201_MONTHLY_SALARY_SETT AS MS WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON MS.Emp_ID = e.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON MS.Increment_ID = i.Increment_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON i.Branch_ID = BM.Branch_ID


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0201_MONTHLY_SALARY_SETT_GET';


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
         Begin Table = "MS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 82
               Left = 621
               Bottom = 197
               Right = 838
            End
            DisplayFlags = 280
            TopColumn = 75
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
         Begin Table = "BM"
            Begin Extent = 
               Top = 6
               Left = 280
               Bottom = 121
               Right = 467
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
      Begin ColumnWidths = 48
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
         Width = 1500
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0201_MONTHLY_SALARY_SETT_GET';


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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0201_MONTHLY_SALARY_SETT_GET';

