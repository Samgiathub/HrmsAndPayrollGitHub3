/* created By rohit For import Present Days on 31102014*/
CREATE VIEW dbo.V0190_MONTHLY_PRESENT_IMPORT
AS
SELECT     dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0080_EMP_MASTER.Vertical_ID, dbo.T0190_MONTHLY_PRESENT_IMPORT.Tran_ID, dbo.T0190_MONTHLY_PRESENT_IMPORT.Emp_ID, 
                  dbo.T0190_MONTHLY_PRESENT_IMPORT.Cmp_ID, dbo.T0190_MONTHLY_PRESENT_IMPORT.Month, dbo.T0190_MONTHLY_PRESENT_IMPORT.Year, dbo.T0190_MONTHLY_PRESENT_IMPORT.For_Date, dbo.T0190_MONTHLY_PRESENT_IMPORT.P_Days, 
                  dbo.T0190_MONTHLY_PRESENT_IMPORT.Extra_Days, dbo.T0190_MONTHLY_PRESENT_IMPORT.Extra_Day_Month, dbo.T0190_MONTHLY_PRESENT_IMPORT.Extra_Day_Year, dbo.T0190_MONTHLY_PRESENT_IMPORT.Cancel_Weekoff_Day, 
                  dbo.T0190_MONTHLY_PRESENT_IMPORT.Cancel_Holiday, dbo.T0190_MONTHLY_PRESENT_IMPORT.Over_Time, dbo.T0190_MONTHLY_PRESENT_IMPORT.Payble_Amount, dbo.T0190_MONTHLY_PRESENT_IMPORT.User_ID, dbo.T0190_MONTHLY_PRESENT_IMPORT.Time_Stamp, 
                  dbo.T0190_MONTHLY_PRESENT_IMPORT.Backdated_Leave_Days, dbo.T0190_MONTHLY_PRESENT_IMPORT.WO_OT_Hour, dbo.T0190_MONTHLY_PRESENT_IMPORT.HO_OT_Hour, dbo.T0190_MONTHLY_PRESENT_IMPORT.Present_on_holiday
FROM        dbo.T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) INNER JOIN
                  dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0190_MONTHLY_PRESENT_IMPORT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID

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
         Begin Table = "T0190_MONTHLY_PRESENT_IMPORT"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 295
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 375
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
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_MONTHLY_PRESENT_IMPORT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_MONTHLY_PRESENT_IMPORT';

