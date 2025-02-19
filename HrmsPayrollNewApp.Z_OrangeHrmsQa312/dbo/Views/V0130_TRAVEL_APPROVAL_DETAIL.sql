



CREATE VIEW [dbo].[V0130_TRAVEL_APPROVAL_DETAIL]
AS
SELECT     TA.Travel_Approval_ID, TA.Approval_Date, TA.Emp_ID, EM.Emp_Full_Name, TA.S_Emp_ID, SEMP.Emp_Full_Name AS Supervisor, TAD.Travel_Approval_Detail_ID, 
                      TAD.Place_Of_Visit, TAD.Travel_Purpose, TAD.Instruct_Emp_ID, IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name, TAD.Travel_Mode_ID, 
                      TM.Travel_Mode_Name, TAD.From_Date, TAD.Period, TAD.To_Date, TAD.Remarks
FROM         dbo.T0120_TRAVEL_APPROVAL AS TA WITH (NOLOCK) INNER JOIN
                      dbo.T0130_TRAVEL_APPROVAL_DETAIL AS TAD WITH (NOLOCK)  ON TA.Travel_Approval_ID = TAD.Travel_Approval_ID INNER JOIN
                      dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS IEMP WITH (NOLOCK)  ON TAD.Instruct_Emp_ID = IEMP.Emp_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'dth = 1455
         Width = 930
         Width = 1935
         Width = 2130
         Width = 1215
         Width = 1320
         Width = 1410
         Width = 2970
         Width = 1380
         Width = 1620
         Width = 1995
         Width = 645
         Width = 1995
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_TRAVEL_APPROVAL_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_TRAVEL_APPROVAL_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[11] 2[9] 3) )"
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
         Begin Table = "TA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 252
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TAD"
            Begin Extent = 
               Top = 6
               Left = 270
               Bottom = 236
               Right = 488
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TM"
            Begin Extent = 
               Top = 6
               Left = 526
               Bottom = 125
               Right = 710
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 6
               Left = 748
               Bottom = 125
               Right = 973
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SEMP"
            Begin Extent = 
               Top = 6
               Left = 1011
               Bottom = 125
               Right = 1236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IEMP"
            Begin Extent = 
               Top = 126
               Left = 526
               Bottom = 245
               Right = 751
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
      Begin ColumnWidths = 18
         Width = 284
         Width = 1635
         Width = 1995
         Width = 750
         Wi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_TRAVEL_APPROVAL_DETAIL';

