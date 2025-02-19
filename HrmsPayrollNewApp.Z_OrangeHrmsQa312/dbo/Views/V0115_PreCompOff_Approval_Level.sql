




CREATE VIEW [dbo].[V0115_PreCompOff_Approval_Level]
AS
SELECT     dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0115_PreCompOff_Approval_Level.Tran_ID, 
                      dbo.T0115_PreCompOff_Approval_Level.cmp_ID, dbo.T0115_PreCompOff_Approval_Level.PreCompOff_App_ID, 
                      dbo.T0115_PreCompOff_Approval_Level.Emp_ID, dbo.T0115_PreCompOff_Approval_Level.S_Emp_ID, 
                      dbo.T0115_PreCompOff_Approval_Level.From_Date, dbo.T0115_PreCompOff_Approval_Level.To_Date, 
                      dbo.T0115_PreCompOff_Approval_Level.Period, dbo.T0115_PreCompOff_Approval_Level.Remarks, 
                      dbo.T0115_PreCompOff_Approval_Level.Approval_Status, dbo.T0115_PreCompOff_Approval_Level.RPT_Level, 
                      dbo.T0115_PreCompOff_Approval_Level.Final_Approval, dbo.T0115_PreCompOff_Approval_Level.Is_FWD_REJECT, 
                      dbo.T0115_PreCompOff_Approval_Level.PrecompOff_App_Date, dbo.T0115_PreCompOff_Approval_Level.PreCompOff_Apr_Date, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name
FROM         dbo.T0115_PreCompOff_Approval_Level WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0115_PreCompOff_Approval_Level.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID



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
         Begin Table = "T0115_PreCompOff_Approval_Level"
            Begin Extent = 
               Top = 6
               Left = 312
               Bottom = 175
               Right = 585
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 9
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0115_PreCompOff_Approval_Level';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0115_PreCompOff_Approval_Level';

