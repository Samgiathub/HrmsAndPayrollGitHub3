



CREATE VIEW [dbo].[V0095_Increment_All_Data]
AS
SELECT     dbo.T0095_INCREMENT.Increment_ID, dbo.T0095_INCREMENT.Emp_ID, dbo.T0095_INCREMENT.Cmp_ID, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0095_INCREMENT.Cat_ID, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      dbo.T0095_INCREMENT.Type_ID, dbo.T0095_INCREMENT.Bank_ID, dbo.T0095_INCREMENT.Curr_ID, dbo.T0095_INCREMENT.Wages_Type, 
                      dbo.T0095_INCREMENT.Salary_Basis_On, dbo.T0095_INCREMENT.Basic_Salary, dbo.T0095_INCREMENT.Gross_Salary, dbo.T0095_INCREMENT.Increment_Type, 
                      dbo.T0095_INCREMENT.Increment_Date, dbo.T0095_INCREMENT.Increment_Effective_Date, dbo.T0095_INCREMENT.Payment_Mode, 
                      dbo.T0095_INCREMENT.Inc_Bank_AC_No, dbo.T0095_INCREMENT.Emp_OT, dbo.T0095_INCREMENT.Emp_OT_Min_Limit, 
                      dbo.T0095_INCREMENT.Emp_OT_Max_Limit, dbo.T0095_INCREMENT.Increment_Per, dbo.T0095_INCREMENT.Increment_Amount, 
                      dbo.T0095_INCREMENT.Pre_Basic_Salary, dbo.T0095_INCREMENT.Pre_Gross_Salary, dbo.T0095_INCREMENT.Increment_Comments, 
                      dbo.T0095_INCREMENT.Emp_Late_mark, dbo.T0095_INCREMENT.Emp_Full_PF, dbo.T0095_INCREMENT.Emp_PT, dbo.T0095_INCREMENT.Emp_Fix_Salary, 
                      dbo.T0095_INCREMENT.Emp_Part_Time, dbo.T0095_INCREMENT.Late_Dedu_Type, dbo.T0095_INCREMENT.Emp_Late_Limit, 
                      dbo.T0095_INCREMENT.Emp_PT_Amount, dbo.T0095_INCREMENT.Emp_Childran, dbo.T0095_INCREMENT.Is_Master_Rec, dbo.T0095_INCREMENT.Login_ID, 
                      dbo.T0095_INCREMENT.System_Date, dbo.T0095_INCREMENT.Yearly_Bonus_Amount, dbo.T0095_INCREMENT.Deputation_End_Date, 
                      dbo.T0095_INCREMENT.Is_Deputation_Reminder, dbo.T0095_INCREMENT.Appr_Int_ID, dbo.T0030_BRANCH_MASTER.Branch_Code, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0040_DESIGNATION_MASTER.Def_ID, dbo.T0040_DESIGNATION_MASTER.Parent_ID, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Second_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name, 
                      dbo.T0080_EMP_MASTER.Initial, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0080_EMP_MASTER.Date_Of_Birth, 
                      CASE WHEN Gender = 'M' THEN 'Male' ELSE 'Female' END AS Gender, dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0095_INCREMENT.Increment_Type AS I, dbo.T0080_EMP_MASTER.Emp_Left, dbo.T0040_DESIGNATION_MASTER.Is_Main, dbo.T0095_INCREMENT.CTC, 
                      dbo.T0095_INCREMENT.Emp_Early_mark, dbo.T0095_INCREMENT.Early_Dedu_Type, dbo.T0095_INCREMENT.Emp_Early_Limit, 
                      dbo.T0095_INCREMENT.Emp_Deficit_mark, dbo.T0095_INCREMENT.Deficit_Dedu_Type, dbo.T0095_INCREMENT.Emp_Deficit_Limit, 
                      dbo.T0095_INCREMENT.Center_ID, dbo.T0095_INCREMENT.Emp_WeekDay_OT_Rate, dbo.T0095_INCREMENT.Emp_WeekOff_OT_Rate, 
                      dbo.T0095_INCREMENT.Emp_Holiday_OT_Rate, dbo.T0095_INCREMENT.Is_Metro_City, dbo.T0095_INCREMENT.Pre_CTC_Salary, 
                      dbo.T0095_INCREMENT.Incerment_Amount_gross, dbo.T0095_INCREMENT.Incerment_Amount_CTC, dbo.T0095_INCREMENT.Increment_Mode, 
                      dbo.T0095_INCREMENT.is_physical, dbo.T0095_INCREMENT.SalDate_id, dbo.T0095_INCREMENT.Emp_Auto_Vpf, dbo.T0095_INCREMENT.Segment_ID, 
                      dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.subBranch_ID, 
                      dbo.T0095_INCREMENT.Monthly_Deficit_Adjust_OT_Hrs, dbo.T0095_INCREMENT.Fix_OT_Hour_Rate_WD, dbo.T0095_INCREMENT.Fix_OT_Hour_Rate_WO_HO, 
                      dbo.T0095_INCREMENT.Bank_ID_Two, dbo.T0095_INCREMENT.Payment_Mode_Two, dbo.T0095_INCREMENT.Inc_Bank_AC_No_Two, 
                      dbo.T0095_INCREMENT.Bank_Branch_Name, dbo.T0095_INCREMENT.Bank_Branch_Name_Two,Alpha_Emp_Code
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID



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
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 71
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 246
               Left = 259
               Bottom = 365
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 366
               Left = 236
               Bottom = 485
               Right = 431
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
      Begin ColumnWidths = 9', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_Increment_All_Data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_Increment_All_Data';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_Increment_All_Data';

