





CREATE VIEW [dbo].[V0090_Change_Request_Final_N_level_Approval]
AS
SELECT     CRA.Request_id, CRA.Cmp_id, CRA.Emp_ID, CRA.Request_Type_id, CRA.Change_Reason, CRA.Request_Date, CRA.Shift_From_Date, CRA.Shift_To_Date, CRA.Curr_Details, CRA.New_Details, 
                      CRA.Curr_Tehsil, CRA.Curr_District, CRA.Curr_Thana, CRA.Curr_City_Village, CRA.Curr_State, CRA.Curr_Pincode, CRA.New_Tehsil, CRA.New_District, CRA.New_Thana, CRA.New_City_Village, 
                      CRA.New_State, CRA.New_Pincode, (CASE WHEN Qry.Request_Apr_Status = 'P' THEN 'Pending' WHEN Qry.Request_Apr_Status = 'A' THEN 'Approved' WHEN Qry.Request_Apr_Status = 'R' THEN 'Rejected' END)
                       AS Request_status, 0 AS is_Final_Approved, qry.S_Emp_Id AS S_Emp_ID_A, CRM.Request_type, EM.Alpha_Emp_Code, EM.Emp_Full_Name, qry.Tran_id,CRA.Child_Birth_Date
FROM         dbo.T0090_Change_Request_Application AS CRA WITH (NOLOCK) INNER JOIN
                      dbo.T0040_Change_Request_Master AS CRM WITH (NOLOCK)  ON CRA.Request_Type_id = CRM.Request_id AND CRA.Cmp_id = CRM.Cmp_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = CRA.Emp_ID INNER JOIN
                          (SELECT     RLA.Request_id, RLA.S_Emp_Id, RLA.Tran_id,RLA.Request_Apr_Status
                            FROM          dbo.T0115_Request_Level_Approval AS RLA WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     MAX(Rpt_Level) AS Rpt_Level, Request_id
                                                         FROM          dbo.T0115_Request_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY Request_id) AS Qry_1 ON Qry_1.Rpt_Level = RLA.Rpt_Level AND Qry_1.Request_id = RLA.Request_id INNER JOIN
                                                   dbo.T0090_Change_Request_Application AS RA WITH (NOLOCK)  ON RA.Request_id = RLA.Request_id
                            WHERE      (RLA.Request_Apr_Status = 'A' OR RLA.Request_Apr_Status = 'R')) AS qry ON CRA.Request_id = qry.Request_id





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[20] 2[13] 3) )"
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
         Begin Table = "CRA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 126
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CRM"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 126
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 246
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "qry"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 351
               Right = 198
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Final_N_level_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Change_Request_Final_N_level_Approval';

