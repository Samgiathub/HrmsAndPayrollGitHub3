



CREATE VIEW [dbo].[V0150_LEAVE_CANCELLATION_APPROVAL]
AS
SELECT     LC.Tran_id, LC.Cmp_Id, LC.Emp_Id, LC.Leave_Approval_id, LC.Leave_id, LC.For_date, LC.Leave_period AS leave_period_app, LC.Is_Approve, 
                      LC.Comment, LC.Request_Date, ISNULL(LC.MComment, '') AS MComment, LC.A_Emp_Id, LC.Day_type, LC.Actual_Leave_Day, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, LT.Leave_Opening, LT.Leave_Credit, LT.Leave_Used, LT.Leave_Closing, 
                      ISNULL(CAST(dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID AS varchar(10)), '') AS Leave_Application_ID, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      T0080_EMP_MASTER_1.Emp_Full_Name AS S_Emp_Full_Name, dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period, dbo.T0040_LEAVE_MASTER.Leave_Code, 
                      dbo.T0040_LEAVE_MASTER.Apply_Hourly,
                      CASE WHEN LT.Leave_Used <> '0'  THEN LT.Leave_Used ELSE LT.CompOff_Used END As  Leave_Used_Comp  --Added By Jaina 26-11-2015
FROM         dbo.T0150_LEAVE_CANCELLATION AS LC WITH (NOLOCK) INNER JOIN
                      dbo.T0140_LEAVE_TRANSACTION AS LT  WITH (NOLOCK) ON LC.For_date = LT.For_Date AND LC.Leave_id = LT.Leave_ID AND LC.Emp_Id = LT.Emp_ID INNER JOIN
                      dbo.T0040_LEAVE_MASTER  WITH (NOLOCK) ON LT.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0120_LEAVE_APPROVAL WITH (NOLOCK)  ON LC.Leave_Approval_id = dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID INNER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON LC.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0130_LEAVE_APPROVAL_DETAIL  WITH (NOLOCK) ON 
                      dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_Superior = T0080_EMP_MASTER_1.Emp_ID
WHERE     (LC.Is_Approve = 0)



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
         Begin Table = "LC"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "LT"
            Begin Extent = 
               Top = 6
               Left = 257
               Bottom = 125
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 483
               Bottom = 125
               Right = 710
            End
            DisplayFlags = 280
            TopColumn = 46
         End
         Begin Table = "T0120_LEAVE_APPROVAL"
            Begin Extent = 
               Top = 6
               Left = 748
               Bottom = 125
               Right = 941
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 34
               Left = 1036
               Bottom = 153
               Right = 1261
            End
            DisplayFlags = 280
            TopColumn = 43
         End
         Begin Table = "T0130_LEAVE_APPROVAL_DETAIL"
            Begin Extent = 
               Top = 54
               Left = 658
               Bottom = 173
               Right = 842
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 128
               Left = 827
               Bottom = 247
               Right =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_LEAVE_CANCELLATION_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 1052
            End
            DisplayFlags = 280
            TopColumn = 36
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
         Width = 915
         Width = 2070
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
         Column = 1905
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_LEAVE_CANCELLATION_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_LEAVE_CANCELLATION_APPROVAL';

