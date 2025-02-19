﻿




CREATE VIEW [dbo].[V0090_HRMS_Appraisal_Emp_GoalReview]
AS
SELECT     GoalDescription_Id, FK_GoalId, GoalDescription_CmpId, GoalDescription, SuccessCriteria, FK_GoalType, AbovePar, AtPar, BelowPar, Employee_Comment, 
                      Supervisor_Comment, FK_Rating, FK_EmployeeId, FK_SupervisorId, GoalDescription_Year, GoalDescription_CreatedBy, GoalDescription_CreatedDate, 
                      GoalDescription_ModifyBy, GoalDescription_ModifyDate,
                          (SELECT     ReviewGoal_Id
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1)) AS Emp_Review_ID,
                          (SELECT     Comment
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1)) AS Emp_Comment_Review,
                          (SELECT     FK_EmployeeId
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1)) AS Emp_ID_Review,
                          (SELECT     FK_SettingId
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1)) AS Emp_SettingId_Review,
                          (SELECT     ReviewGoal_Signoff
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1)) AS Emp_Signoff_Review,
                          (SELECT     ReviewGoal_SignoffDate
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrEmp WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager = 1)) AS Emp_SignoffDate_Review,
                          (SELECT     TOP (1) ReviewGoal_Id
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_Review_ID,
                          (SELECT     TOP (1) Comment
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_Comment_Review,
                          (SELECT     TOP (1) FK_Rating
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_Rating_Review,
                          (SELECT     TOP (1) FK_EmployeeId
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_EmployeeId_Review,
                          (SELECT     TOP (1) FK_SettingId
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_SettingId_Review,
                          (SELECT     TOP (1) ReviewGoal_Signoff
                           FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_Signoff_Review,
                          (SELECT     TOP (1) ReviewGoal_SignoffDate
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Mng_SignoffDate_Review,
                          (SELECT     TOP (1) Is_Emp_Manager
                            FROM          dbo.T0090_HRMS_Appraisal_Emp_GoalReview AS egrMan WITH (NOLOCK)
                            WHERE      (FK_GoalDescriptionId = appDes.GoalDescription_Id) AND (Is_Emp_Manager > 1)
                            ORDER BY Is_Emp_Manager DESC) AS Is_Emp_Manager
FROM         dbo.T0090_HRMS_Appraisal_Emp_GoalDescription AS appDes WITH (NOLOCK)




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[21] 4[10] 2[43] 3) )"
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
         Begin Table = "appDes"
            Begin Extent = 
               Top = 6
               Left = 82
               Bottom = 166
               Right = 313
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
      Begin ColumnWidths = 35
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
         Width = 2055
         Width = 1935
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
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_GoalReview';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_GoalReview';

