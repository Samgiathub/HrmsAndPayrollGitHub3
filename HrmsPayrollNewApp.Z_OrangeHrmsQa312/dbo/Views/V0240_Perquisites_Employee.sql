



CREATE VIEW [dbo].[V0240_Perquisites_Employee]
AS
SELECT     TOP (100) PERCENT Tran_id, Cmp_id, Emp_id, Perquisites_id, Financial_Year, Emp_Name, Perquisites_Name, Alpha_Emp_Code, Change_Date
FROM         (SELECT     TOP (100) PERCENT dbo.T0240_Perquisites_Employee.Tran_id, dbo.T0240_Perquisites_Employee.Cmp_id, dbo.T0240_Perquisites_Employee.Emp_id, 
                                              dbo.T0240_Perquisites_Employee.Perquisites_id, dbo.T0240_Perquisites_Employee.Financial_Year, 
                                              dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Name, dbo.T0240_Perquisites_Master.Name AS Perquisites_Name, 
                                              dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0240_Perquisites_Employee.Change_Date
                       FROM          dbo.T0240_Perquisites_Employee WITH (NOLOCK) INNER JOIN
                                              dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0240_Perquisites_Employee.Emp_id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                                              dbo.T0240_Perquisites_Master WITH (NOLOCK)  ON dbo.T0240_Perquisites_Employee.Perquisites_id = dbo.T0240_Perquisites_Master.Perquisites_Id
                       UNION
                       SELECT     TOP (100) PERCENT dbo.T0240_Perquisites_Employee_Car.Tran_id, dbo.T0240_Perquisites_Employee_Car.cmp_id, 
                                             dbo.T0240_Perquisites_Employee_Car.emp_id, dbo.T0240_Perquisites_Employee_Car.perquisites_id, 
                                             dbo.T0240_Perquisites_Employee_Car.Financial_Year, T0080_EMP_MASTER_1.Emp_Full_Name AS Emp_Name, 
                                             T0240_Perquisites_Master_1.Name AS Perquisites_Name, T0080_EMP_MASTER_1.Alpha_Emp_Code, 
                                             dbo.T0240_Perquisites_Employee_Car.Change_Date
                       FROM         dbo.T0240_Perquisites_Employee_Car WITH (NOLOCK)  INNER JOIN
                                             dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0240_Perquisites_Employee_Car.emp_id = T0080_EMP_MASTER_1.Emp_ID INNER JOIN
                                             dbo.T0240_Perquisites_Master AS T0240_Perquisites_Master_1 WITH (NOLOCK)  ON 
                                             dbo.T0240_Perquisites_Employee_Car.perquisites_id = T0240_Perquisites_Master_1.Perquisites_Id) AS Qry
ORDER BY RIGHT(REPLICATE(N' ', 500) + Alpha_Emp_Code, 500)



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
         Begin Table = "Qry"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 212
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
      Begin ColumnWidths = 27
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1995
         Width = 1995
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0240_Perquisites_Employee';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0240_Perquisites_Employee';

