


CREATE VIEW [dbo].[V0120_Leave_Encash_Approval]
AS
SELECT     dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_Apr_ID, dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_App_ID, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Cmp_ID, dbo.T0120_LEAVE_ENCASH_APPROVAL.Emp_ID, dbo.T0120_LEAVE_ENCASH_APPROVAL.Leave_ID, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_Apr_Code, dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_Apr_Date, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_Apr_Days, dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_Apr_Status, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_Apr_Comments, dbo.T0120_LEAVE_ENCASH_APPROVAL.Login_ID, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.System_Date, dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Status, 
                      dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Date, dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_Code, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Other_Email, dbo.T0095_INCREMENT.Grd_ID, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Eff_In_Salary, dbo.T0120_LEAVE_ENCASH_APPROVAL.Is_FNF, dbo.T0120_LEAVE_ENCASH_APPROVAL.Upto_Date, 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Leave_CompOff_Dates, dbo.T0040_LEAVE_MASTER.Default_Short_Name, 
                      ISNULL(dbo.T0120_LEAVE_ENCASH_APPROVAL.Leave_Encash_Amount, 0) AS Leave_Encash_Amount, dbo.T0095_INCREMENT.Branch_ID
FROM         dbo.T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) INNER JOIN
                      dbo.T0100_LEAVE_ENCASH_APPLICATION WITH (NOLOCK)  ON 
                      dbo.T0120_LEAVE_ENCASH_APPROVAL.Lv_Encash_App_ID = dbo.T0100_LEAVE_ENCASH_APPLICATION.Lv_Encash_App_ID INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0120_LEAVE_ENCASH_APPROVAL.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0120_LEAVE_ENCASH_APPROVAL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID CROSS APPLY
                          (SELECT     *
                            FROM          dbo.fn_getEmpIncrement(T0120_LEAVE_ENCASH_APPROVAL.Cmp_Id, T0120_LEAVE_ENCASH_APPROVAL.Emp_Id, 
                                                   T0120_LEAVE_ENCASH_APPROVAL.Upto_Date)) Qry INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON Qry.Increment_ID = dbo.T0095_INCREMENT.Increment_ID


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
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0120_LEAVE_ENCASH_APPROVAL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 257
            End
            DisplayFlags = 280
            TopColumn = 12
         End
         Begin Table = "T0100_LEAVE_ENCASH_APPLICATION"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 320
            End
            DisplayFlags = 280
            TopColumn = 42
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 263
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Leave_Encash_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Leave_Encash_Approval';

