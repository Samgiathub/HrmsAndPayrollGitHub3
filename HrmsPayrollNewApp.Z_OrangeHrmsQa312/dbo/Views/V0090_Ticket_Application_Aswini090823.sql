CREATE VIEW dbo.V0090_Ticket_Application_Aswini090823
AS
SELECT     TA.Ticket_App_ID, TTM.Ticket_Type, TTM.Ticket_Dept_Name, CASE WHEN TA.Is_Candidate = 1 THEN R.Resume_Code ELSE EM.Alpha_Emp_Code END AS Alpha_Emp_Code, CASE WHEN TA.Is_Candidate = 1 THEN ISNULL(r.Initial, '') 
                  + ' ' + r.Emp_First_Name + ' ' + r.Emp_Last_Name ELSE EM.Emp_Full_Name END AS Emp_Full_Name, TA.Ticket_Gen_Date, (CASE WHEN TA.Ticket_Status = 'O' THEN 'Open' WHEN TA.Ticket_Status = 'H' THEN 'On Hold' ELSE 'Closed' END) AS Ticket_Status, TA.Ticket_Description, 
                  TP.Priority_Name AS Ticket_Priority, TA.Ticket_Type_ID, TA.Ticket_Dept_ID, CASE WHEN TA.Is_Candidate = 1 THEN R.Resume_Id ELSE EM.Emp_ID END AS Emp_ID, TA.Cmp_ID, TA.Ticket_Attachment, TA.Is_Escalation, TA.Ticket_Priority AS Ticket_Priority_ID, 
                  TTA.Ticket_Solution AS On_Hold_Reason, TA.Ticket_Status AS Ticket_Status_Flag, ISNULL(TTA.Ticket_Apr_ID, 0) AS Ticket_Apr_ID, TTA.Ticket_Apr_Attachment, ISNULL(TA.Is_Candidate, 0) AS Is_Candidate, TA.User_ID, Eu.Emp_Full_Name AS AppliedByName, Eu.Emp_ID AS AppliedById, 
                  Eu.Work_Email AS appliedByEmail, TA.Escalation_Hours, TA.SendTo, ST.Alpha_Emp_Code + ' - ' + ST.Emp_Full_Name AS SendTo_Full_Name
FROM        dbo.T0090_Ticket_Application AS TA WITH (NOLOCK) INNER JOIN
                  dbo.T0040_Ticket_Type_Master AS TTM WITH (NOLOCK) ON TA.Ticket_Type_ID = TTM.Ticket_Type_ID LEFT OUTER JOIN
                  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON TA.Emp_ID = EM.Emp_ID LEFT OUTER JOIN
                  dbo.T0100_Ticket_Approval AS TTA WITH (NOLOCK) ON TTA.Ticket_App_ID = TA.Ticket_App_ID LEFT OUTER JOIN
                  dbo.T0055_Resume_Master AS R WITH (NOLOCK) ON R.Resume_Id = TA.Emp_ID LEFT OUTER JOIN
                  dbo.T0011_LOGIN AS L WITH (NOLOCK) ON L.Login_ID = TA.User_ID LEFT OUTER JOIN
                  dbo.T0080_EMP_MASTER AS Eu WITH (NOLOCK) ON Eu.Emp_ID = L.Emp_ID INNER JOIN
                  dbo.T0040_Ticket_Priority AS TP WITH (NOLOCK) ON TP.Tran_ID = TA.Ticket_Priority INNER JOIN
                  dbo.T0080_EMP_MASTER AS ST WITH (NOLOCK) ON ST.Emp_ID = TA.SendTo

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
         Begin Table = "TA"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 265
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TTM"
            Begin Extent = 
               Top = 7
               Left = 313
               Bottom = 170
               Right = 532
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 7
               Left = 580
               Bottom = 170
               Right = 907
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TTA"
            Begin Extent = 
               Top = 7
               Left = 955
               Bottom = 170
               Right = 1202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 352
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 175
               Left = 400
               Bottom = 338
               Right = 623
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Eu"
            Begin Extent = 
               Top = 175
               Left = 671
               Bottom = 338
               Right = 998
            End
            DisplayFlags = 280
            TopColumn = 0
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Ticket_Application_Aswini090823';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
         Begin Table = "TP"
            Begin Extent = 
               Top = 175
               Left = 1046
               Bottom = 338
               Right = 1240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ST"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 375
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Ticket_Application_Aswini090823';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Ticket_Application_Aswini090823';

