




CREATE VIEW [dbo].[V0090_HRMS_Appraisal_Emp_GoalDescription]
AS
SELECT     dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_Id, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_GoalId, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_CmpId, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.SuccessCriteria, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.AbovePar, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.AtPar, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.BelowPar, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.Employee_Comment, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.Supervisor_Comment, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_Rating, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_EmployeeId, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_SupervisorId, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_Year, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_CreatedBy, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_CreatedDate, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_ModifyBy, dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.GoalDescription_ModifyDate, 
                      dbo.T0040_HRMS_Appraisal_Rating_Master.Rating, dbo.T0080_EMP_MASTER.Emp_Full_Name, T0080_EMP_MASTER_1.Emp_Full_Name AS Sup_Full_Name, 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_GoalType, dbo.T0040_HRMS_Appraisal_GoalType_Master.GoalType
FROM         dbo.T0090_HRMS_Appraisal_Emp_GoalDescription WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_HRMS_Appraisal_Rating_Master WITH (NOLOCK)  ON 
                      dbo.T0040_HRMS_Appraisal_Rating_Master.Rating_Id = dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_Rating LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_EmployeeId = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_SupervisorId = T0080_EMP_MASTER_1.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_Appraisal_GoalType_Master WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_GoalDescription.FK_GoalType = dbo.T0040_HRMS_Appraisal_GoalType_Master.GoalType_Id




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[8] 2[27] 3) )"
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
         Begin Table = "T0090_HRMS_Appraisal_Emp_GoalDescription"
            Begin Extent = 
               Top = 0
               Left = 251
               Bottom = 191
               Right = 482
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_HRMS_Appraisal_Rating_Master"
            Begin Extent = 
               Top = 1
               Left = 34
               Bottom = 120
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 520
               Bottom = 125
               Right = 745
            End
            DisplayFlags = 280
            TopColumn = 38
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 41
               Left = 621
               Bottom = 160
               Right = 846
            End
            DisplayFlags = 280
            TopColumn = 38
         End
         Begin Table = "T0040_HRMS_Appraisal_GoalType_Master"
            Begin Extent = 
               Top = 120
               Left = 38
               Bottom = 239
               Right = 240
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
      Begin ColumnWidths = 23
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2325
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_GoalDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Width = 1845
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2010
         Width = 2130
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_GoalDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_GoalDescription';

