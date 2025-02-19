




CREATE VIEW [dbo].[V0090_HRMS_Appraisal_Emp_PerformanceSummary]
AS
SELECT     dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_Id, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_CmpId, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_EmployeeComment, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_SupervisorComment, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.Cp_EmployeeComment, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.Cp_SupervisorComment, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.FK_Rating, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.FK_EmployeeId, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.FK_SupervisorId, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.Employee_SignOff, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.Employee_SignOffDate, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.Supervisor_SignOff, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.Supervisor_SignOffDate, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_StartDate, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_EndDate, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_Year, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_CreatedBy, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_CreatedDate, 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_ModifyBy, dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.PS_ModifyDate, 
                      dbo.T0040_HRMS_Appraisal_Rating_Master.Rating, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      T0080_Sup_MASTER.Emp_Full_Name AS Sup_Full_Name, T0080_Sup_MASTER.Alpha_Emp_Code AS Alpha_Sup_Code
FROM         dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.FK_EmployeeId = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_Sup_MASTER WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.FK_SupervisorId = T0080_Sup_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_Appraisal_Rating_Master WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_PerformanceSummary.FK_Rating = dbo.T0040_HRMS_Appraisal_Rating_Master.Rating_Id




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'th = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2595
         Alias = 2640
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_PerformanceSummary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_PerformanceSummary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[49] 4[5] 2[24] 3) )"
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
         Begin Table = "T0090_HRMS_Appraisal_Emp_PerformanceSummary"
            Begin Extent = 
               Top = 2
               Left = 302
               Bottom = 244
               Right = 507
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_HRMS_Appraisal_Rating_Master"
            Begin Extent = 
               Top = 2
               Left = 36
               Bottom = 121
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 5
               Left = 700
               Bottom = 124
               Right = 925
            End
            DisplayFlags = 280
            TopColumn = 78
         End
         Begin Table = "T0080_Sup_MASTER"
            Begin Extent = 
               Top = 131
               Left = 700
               Bottom = 250
               Right = 925
            End
            DisplayFlags = 280
            TopColumn = 76
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 26
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
         Wid', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_PerformanceSummary';

