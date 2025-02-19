





CREATE VIEW [dbo].[V0130_HRMS_TRAININIG_DETAILS]
AS
SELECT     dbo.T0100_TRAINING_APPLICATION.Training_App_ID, dbo.T0100_TRAINING_APPLICATION.Training_Title, 
                      dbo.T0100_TRAINING_APPLICATION.Training_Desc, dbo.T0100_TRAINING_APPLICATION.For_Date, 
                      dbo.T0100_TRAINING_APPLICATION.Posted_Emp_ID, dbo.T0100_TRAINING_APPLICATION.Skill_ID, dbo.T0100_TRAINING_APPLICATION.App_Status, 
                      dbo.T0100_TRAINING_APPLICATION.Cmp_ID, dbo.T0100_TRAINING_APPLICATION.Login_ID, dbo.T0100_TRAINING_APPLICATION.System_Date, 
                      dbo.T0120_training_Approval.Training_Apr_ID, dbo.T0120_training_Approval.Training_Date, dbo.T0120_training_Approval.Place, 
                      dbo.T0120_training_Approval.Faculty,  dbo.T0120_training_Approval.Description, 
                      dbo.T0120_training_Approval.Training_Cost, dbo.T0120_training_Approval.Apr_Status,dbo.T0120_training_Approval.company_name, dbo.T0110_TRAINING_APPLICATION_DETAIL.Emp_ID, 
                      dbo.T0040_SKILL_MASTER.Skill_Name, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Training_Apr_Detail_ID, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_S_ID, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_Feedback, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Superior_Feedback, dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_Feedback_Date, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Sup_feedback_date, ISNULL(dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_Eval_Rate, 
                      0) AS Emp_Rate, ISNULL(dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Sup_Eval_Rate, 0) AS Sup_Rate, 
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Is_Attend, dbo.T0120_training_Approval.Training_End_Date
FROM         dbo.T0100_TRAINING_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0120_training_Approval WITH (NOLOCK)  ON 
                      dbo.T0100_TRAINING_APPLICATION.Training_App_ID = dbo.T0120_training_Approval.Training_App_ID INNER JOIN
                      dbo.T0110_TRAINING_APPLICATION_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0100_TRAINING_APPLICATION.Training_App_ID = dbo.T0110_TRAINING_APPLICATION_DETAIL.Training_App_ID INNER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  ON dbo.T0100_TRAINING_APPLICATION.Skill_ID = dbo.T0040_SKILL_MASTER.Skill_ID LEFT OUTER JOIN
                      dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS WITH (NOLOCK)  ON 
                      dbo.T0110_TRAINING_APPLICATION_DETAIL.Emp_ID = dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Emp_ID AND 
                      dbo.T0120_training_Approval.Training_Apr_ID = dbo.T0130_HRMS_TRAINING_FEEDBACK_DETAILS.Training_Apr_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'teriaPane = 
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAININIG_DETAILS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[62] 4[4] 3[28] 2) )"
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
         Begin Table = "T0100_TRAINING_APPLICATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 167
               Right = 199
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_TRAINING_APPROVAL"
            Begin Extent = 
               Top = 6
               Left = 237
               Bottom = 269
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0110_TRAINING_APPLICATION_DETAIL"
            Begin Extent = 
               Top = 169
               Left = 209
               Bottom = 296
               Right = 387
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_SKILL_MASTER"
            Begin Extent = 
               Top = 165
               Left = 48
               Bottom = 248
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_HRMS_TRAINING_FEEDBACK_DETAILS"
            Begin Extent = 
               Top = 48
               Left = 496
               Bottom = 277
               Right = 689
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
   Begin Cri', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAININIG_DETAILS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAININIG_DETAILS';

