





CREATE VIEW [dbo].[V0150_LEAVE_CANCELLATION_APPROVAL_MAIN]
AS
SELECT  Distinct   LC.Cmp_Id, LC.Emp_Id, LC.Leave_Approval_id, LC.Leave_id,
					  --LC.For_date, 
					  Convert(varchar(12),LC.Request_Date,103) as For_Date,
					  LC.Is_Approve, ISNULL(LC.MComment, '') AS MComment,
                      --LC.Actual_Leave_Day, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, ISNULL(CAST(dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID AS varchar(10)), 
                      '') AS Leave_Application_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      T0080_EMP_MASTER_1.Emp_Full_Name AS S_Emp_Full_Name, dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, 
                      dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period,
					  dbo.T0080_EMP_MASTER.Branch_ID, 
                      LC.A_Emp_Id, 
                      --LC.Tran_id, 
                       LC.Leave_Approval_id as Tran_id,
                      dbo.T0040_LEAVE_MASTER.Apply_Hourly,
                      dbo.T0040_LEAVE_MASTER.Default_Short_Name   --Added By Jaina 25-11-2015
                      ,dbo.T0080_EMP_MASTER.Dept_ID --Ankit
                      ,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID --added by jimit 02122016
                      ,Convert(varchar(11),LC.Request_Date,120) AS L_For_Date 
					  ,S_Emp_ID
FROM         dbo.T0150_LEAVE_CANCELLATION AS LC WITH (NOLOCK) 
			INNER JOIN dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON LC.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL WITH (NOLOCK)  ON LC.Leave_Approval_id = dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID 
			INNER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON LC.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID 
			left outer JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)  ON dbo.T0120_LEAVE_APPROVAL.Leave_Approval_ID = dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Approval_ID 
			LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_Superior = T0080_EMP_MASTER_1.Emp_ID
					
			GROUP BY LC.Cmp_Id, LC.Emp_Id, LC.Leave_Approval_id, LC.Leave_id,
			LC.Request_Date,LC.Is_Approve, ISNULL(LC.MComment, ''), LC.Actual_Leave_Day, 
            dbo.T0040_LEAVE_MASTER.Leave_Name, ISNULL(CAST(dbo.T0120_LEAVE_APPROVAL.Leave_Application_ID AS varchar(10)), ''), 
            dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, T0080_EMP_MASTER_1.Emp_Full_Name, 
            dbo.T0130_LEAVE_APPROVAL_DETAIL.From_Date, dbo.T0130_LEAVE_APPROVAL_DETAIL.To_Date, 
            dbo.T0130_LEAVE_APPROVAL_DETAIL.Leave_Period, dbo.T0080_EMP_MASTER.Branch_ID, LC.A_Emp_Id, LC.Tran_id, 
            dbo.T0040_LEAVE_MASTER.Apply_Hourly,dbo.T0040_LEAVE_MASTER.Default_Short_Name   
            ,dbo.T0080_EMP_MASTER.Dept_ID,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID,S_Emp_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[23] 2[14] 3) )"
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
         Left = -26
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
            TopColumn = 0
         End
         Begin Table = "LT"
            Begin Extent = 
               Top = 25
               Left = 1118
               Bottom = 144
               Right = 1306
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 0
               Left = 262
               Bottom = 119
               Right = 489
            End
            DisplayFlags = 280
            TopColumn = 46
         End
         Begin Table = "T0120_LEAVE_APPROVAL"
            Begin Extent = 
               Top = 0
               Left = 620
               Bottom = 119
               Right = 813
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 0
               Left = 840
               Bottom = 119
               Right = 1065
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_LEAVE_APPROVAL_DETAIL"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 126
               Left = 260
               Bottom = 245
               Right', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_LEAVE_CANCELLATION_APPROVAL_MAIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' = 485
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
         Width = 1785
         Width = 1710
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
      Begin ColumnWidths = 12
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_LEAVE_CANCELLATION_APPROVAL_MAIN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_LEAVE_CANCELLATION_APPROVAL_MAIN';

