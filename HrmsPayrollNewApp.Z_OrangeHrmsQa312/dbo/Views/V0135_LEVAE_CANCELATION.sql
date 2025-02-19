


CREATE VIEW [dbo].[V0135_LEVAE_CANCELATION]
AS
SELECT     dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0135_LEAVE_CANCELATION.LV_Can_Tran_ID, 
                      dbo.T0135_LEAVE_CANCELATION.Emp_ID, dbo.T0135_LEAVE_CANCELATION.Cmp_ID, dbo.T0135_LEAVE_CANCELATION.Leave_ID, 
                      dbo.T0135_LEAVE_CANCELATION.Leave_Period, dbo.T0135_LEAVE_CANCELATION.For_Date, dbo.T0135_LEAVE_CANCELATION.LV_Can_Day, 
                      dbo.T0135_LEAVE_CANCELATION.LV_Can_Status, dbo.T0135_LEAVE_CANCELATION.LV_Can_Comments, dbo.T0135_LEAVE_CANCELATION.Out_Time, 
                      dbo.T0135_LEAVE_CANCELATION.In_Time, dbo.T0135_LEAVE_CANCELATION.Leave_Approval_ID, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0040_LEAVE_MASTER.Default_Short_Name
FROM         dbo.T0135_LEAVE_CANCELATION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON dbo.T0135_LEAVE_CANCELATION.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0135_LEAVE_CANCELATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
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
         Begin Table = "T0135_LEAVE_CANCELATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 52
               Left = 224
               Bottom = 167
               Right = 435
            End
            DisplayFlags = 280
            TopColumn = 38
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 79
               Left = 415
               Bottom = 194
               Right = 632
            End
            DisplayFlags = 280
            TopColumn = 80
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 985
               Bottom = 121
               Right = 1193
            End
            DisplayFlags = 280
            TopColumn = 51
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 91
               Left = 700
               Bottom = 206
               Right = 859
            End
            DisplayFlags = 280
            TopColumn = 5
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 19
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
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0135_LEVAE_CANCELATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0135_LEVAE_CANCELATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0135_LEVAE_CANCELATION';

