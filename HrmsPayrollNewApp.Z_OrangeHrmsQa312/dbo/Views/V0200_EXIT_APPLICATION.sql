﻿


CREATE VIEW [dbo].[V0200_EXIT_APPLICATION]
AS
SELECT     dbo.T0200_Emp_ExitApplication.exit_id, dbo.T0200_Emp_ExitApplication.emp_id, dbo.T0200_Emp_ExitApplication.cmp_id, 
                      dbo.T0200_Emp_ExitApplication.resignation_date, dbo.T0200_Emp_ExitApplication.last_date, dbo.T0200_Emp_ExitApplication.reason, 
                      dbo.T0200_Emp_ExitApplication.comments, dbo.T0200_Emp_ExitApplication.status, dbo.T0200_Emp_ExitApplication.is_rehirable, 
                      dbo.T0200_Emp_ExitApplication.s_emp_id, dbo.T0200_Emp_ExitApplication.feedback, dbo.T0200_Emp_ExitApplication.sup_ack, 
                      dbo.T0200_Emp_ExitApplication.interview_date, dbo.T0200_Emp_ExitApplication.interview_time, dbo.T0200_Emp_ExitApplication.Is_Process, 
                      dbo.T0200_Question_Exit_Analysis_Master.Quest_ID, dbo.T0200_Question_Exit_Analysis_Master.Question, 
                      dbo.T0200_Question_Exit_Analysis_Master.Question_Type, dbo.T0200_Question_Exit_Analysis_Master.Question_Options, 
                      dbo.T0200_Exit_Interview.Interview_id, dbo.T0200_Question_Exit_Analysis_Master.Sorting_No, 
                      dbo.T0200_Question_Exit_Analysis_Master.strDesig_ID, dbo.T0200_Question_Exit_Analysis_Master.AutoAssign
FROM         dbo.T0200_Emp_ExitApplication WITH (NOLOCK) INNER JOIN
                      dbo.T0200_Exit_Interview WITH (NOLOCK)  ON dbo.T0200_Emp_ExitApplication.exit_id = dbo.T0200_Exit_Interview.exit_id INNER JOIN
                      dbo.T0200_Question_Exit_Analysis_Master WITH (NOLOCK)  ON dbo.T0200_Exit_Interview.Question_Id = dbo.T0200_Question_Exit_Analysis_Master.Quest_ID


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[17] 2[24] 3) )"
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
         Begin Table = "T0200_Emp_ExitApplication"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 9
         End
         Begin Table = "T0200_Exit_Interview"
            Begin Extent = 
               Top = 6
               Left = 238
               Bottom = 121
               Right = 390
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0200_Question_Master"
            Begin Extent = 
               Top = 6
               Left = 428
               Bottom = 121
               Right = 580
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 22
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
         Filter ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_EXIT_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'= 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_EXIT_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_EXIT_APPLICATION';

