





CREATE VIEW [dbo].[V0140_Leave_Transaction]
AS
SELECT     dbo.T0140_LEAVE_TRANSACTION.Leave_Tran_ID, dbo.T0140_LEAVE_TRANSACTION.Cmp_ID, dbo.T0140_LEAVE_TRANSACTION.Leave_ID, 
                      dbo.T0140_LEAVE_TRANSACTION.Emp_ID, dbo.T0140_LEAVE_TRANSACTION.For_Date, dbo.T0140_LEAVE_TRANSACTION.Leave_Opening, 
                      dbo.T0140_LEAVE_TRANSACTION.Leave_Credit, dbo.T0140_LEAVE_TRANSACTION.Leave_Used, dbo.T0140_LEAVE_TRANSACTION.Leave_Posting, 
                      dbo.T0140_LEAVE_TRANSACTION.Leave_Closing, dbo.T0140_LEAVE_TRANSACTION.Leave_Adj_L_Mark, dbo.T0140_LEAVE_TRANSACTION.Leave_Cancel, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0040_LEAVE_MASTER.Can_Apply_Fraction,
                      dbo.F_Lower_Round(CAST((CASE WHEN Leave_Used <> '0'  THEN Leave_Used ELSE CompOff_Used END) AS NUMERIC(22,8)),T0040_LEAVE_MASTER.Cmp_ID) As Leave_Used_Comp  --Added By Jaina 9-12-2015
                      ,dbo.T0040_LEAVE_MASTER.Default_Short_Name  --Added by Jaina 20-01-2017
FROM         dbo.T0040_LEAVE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK)  ON dbo.T0040_LEAVE_MASTER.Leave_ID = dbo.T0140_LEAVE_TRANSACTION.Leave_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_Leave_Transaction';


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
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 265
            End
            DisplayFlags = 280
            TopColumn = 33
         End
         Begin Table = "T0140_LEAVE_TRANSACTION"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 226
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
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_Leave_Transaction';

