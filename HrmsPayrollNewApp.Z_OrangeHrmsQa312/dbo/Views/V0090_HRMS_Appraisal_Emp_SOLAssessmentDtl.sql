




CREATE VIEW [dbo].[V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl]
AS
SELECT     Emp_Rating_Master.Rating AS Emp_Rating, Sup_Rating_Master.Rating AS Sup_Rating, dbo.T0040_HRMS_Appraisal_SOL_Master.SOL, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.SOLAssessmentDtl_Id, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.SOLAssessmentDtl_CmpId, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.Fk_SOLAssessment_Id, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.Fk_SOL, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.FK_EmployeeId, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.IndicativeExample, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.DepartmentActionPlan, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.FK_Rating_Emp, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.FK_Rating_Sup, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.ReviewSOL_Signoff, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.ReviewSOL_SignoffDate, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.Is_Emp_Manager, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.FK_SettingId, dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.SOLAssessmentDtl_CreatedBy, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.SOLAssessmentDtl_CreatedDate, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.SOLAssessmentDtl_ModifyBy, 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.SOLAssessmentDtl_ModifyDate
FROM         dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl WITH (NOLOCK) INNER JOIN
                      dbo.T0040_HRMS_Appraisal_SOL_Master WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.Fk_SOL = dbo.T0040_HRMS_Appraisal_SOL_Master.SOL_Id LEFT OUTER JOIN
                      dbo.T0040_HRMS_Appraisal_Rating_Master AS Emp_Rating_Master WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.FK_Rating_Emp = Emp_Rating_Master.Rating_Id LEFT OUTER JOIN
                      dbo.T0040_HRMS_Appraisal_Rating_Master AS Sup_Rating_Master WITH (NOLOCK)  ON 
                      dbo.T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl.FK_Rating_Sup = Sup_Rating_Master.Rating_Id




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[10] 2[35] 3) )"
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
         Begin Table = "T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl"
            Begin Extent = 
               Top = 9
               Left = 337
               Bottom = 192
               Right = 583
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_HRMS_Appraisal_SOL_Master"
            Begin Extent = 
               Top = 7
               Left = 650
               Bottom = 197
               Right = 879
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Emp_Rating_Master"
            Begin Extent = 
               Top = 4
               Left = 62
               Bottom = 123
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Sup_Rating_Master"
            Begin Extent = 
               Top = 141
               Left = 56
               Bottom = 260
               Right = 244
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
      Begin ColumnWidths = 21
         Width = 284
         Width = 1500
         Width = 1500
         Width = 795
         Width = 1875
         Width = 2205
         Width = 930
         Width = 1605
         Width = 1980
         Width = 1500
         Width = 1365
         Width = 2070
         Width = 2145
         Width = 1500
         Width = 1500
         Width = 75
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_Appraisal_Emp_SOLAssessmentDtl';

