



CREATE VIEW [dbo].[V0100_Leave_Encash_Application]
AS
SELECT     dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.Cmp_ID, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.Emp_ID, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Code, dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Date, 
                      CASE WHEN la.Lv_Encash_Apr_Status = 'A' THEN LA.Lv_Encash_Apr_Days ELSE dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Days END AS Lv_Encash_App_Days,
                       dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Status, dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Comments, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Login_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.System_Date, dbo.T0040_LEAVE_MASTER.Leave_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Basic_Salary, Qry.Grd_ID, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_CompOff_Dates, dbo.T0040_LEAVE_MASTER.Leave_Count, dbo.T0040_LEAVE_MASTER.Default_Short_Name, 
                      dbo.T0040_LEAVE_MASTER.Max_Accumulate_Balance, dbo.T0040_LEAVE_MASTER.Apply_Hourly, dbo.T0095_INCREMENT.Vertical_ID, 
                      dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_Encash_Amount
FROM         dbo.T0100_LEAVE_ENCASH_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0100_LEAVE_ENCASH_APPLICATION.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_LEAVE_ENCASH_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID Cross APPLY
                      (Select * from dbo.fn_getEmpIncrement(T0100_LEAVE_ENCASH_APPLICATION.Cmp_Id,T0100_LEAVE_ENCASH_APPLICATION.Emp_Id,T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Date)) Qry Inner JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON Qry.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0120_LEAVE_ENCASH_APPROVAL AS LA WITH (NOLOCK)  ON LA.Lv_Encash_App_ID = dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_ID


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
         Begin Table = "T0100_LEAVE_ENCASH_APPLICATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 25
               Left = 375
               Bottom = 140
               Right = 586
            End
            DisplayFlags = 280
            TopColumn = 46
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 65
               Left = 638
               Bottom = 180
               Right = 855
            End
            DisplayFlags = 280
            TopColumn = 74
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 153
               Left = 203
               Bottom = 268
               Right = 411
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
         Or = 1350', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Leave_Encash_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Leave_Encash_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Leave_Encash_Application';

