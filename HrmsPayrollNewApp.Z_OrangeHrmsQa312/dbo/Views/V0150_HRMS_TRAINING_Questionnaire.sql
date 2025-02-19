


CREATE VIEW [dbo].[V0150_HRMS_TRAINING_Questionnaire]
AS
SELECT     dbo.T0150_HRMS_TRAINING_Questionnaire.Training_Que_ID, dbo.T0150_HRMS_TRAINING_Questionnaire.Question, 
                      dbo.T0150_HRMS_TRAINING_Questionnaire.Training_Id, dbo.T0150_HRMS_TRAINING_Questionnaire.Cmp_Id, 
                      isnull(dbo.T0150_HRMS_TRAINING_Questionnaire.Questionniare_Type, 0) Questionniare_Type, 
                      CASE WHEN Questionniare_Type = 1 THEN 'Questionnaire' WHEN Questionniare_Type = 2 THEN 'Manager Feedback' WHEN Questionniare_Type = 0 THEN 'Employee Feedback' WHEN Questionniare_Type = 3 THEN 'Induction Feedback' END QuestionniareType, 
                      isnull(dbo.T0150_HRMS_TRAINING_Questionnaire.Question_Type, 3) Question_Type, 
                      CASE WHEN Question_Type = 0 THEN '' ELSE CASE WHEN Question_Type = 1 THEN 'Title' ELSE CASE WHEN Question_Type = 2 THEN 'Text' ELSE CASE WHEN Question_Type
                       = 4 THEN 'Multiple Choice' ELSE CASE WHEN Question_Type = 5 THEN 'CheckBoxList' ELSE CASE WHEN Question_Type = 6 THEN 'DropDownList' ELSE CASE WHEN Question_Type = 7 THEN 'Multiple Choice Grid' ELSE CASE WHEN Question_Type = 8 THEN 'Video' ELSE 'Paragraph Text'
                       END END END END END END END END QuestionType, isnull(dbo.T0150_HRMS_TRAINING_Questionnaire.Sorting_No, 0) Sorting_No, 
                      dbo.T0150_HRMS_TRAINING_Questionnaire.Question_Option, dbo.T0150_HRMS_TRAINING_Questionnaire.Answer, 
                      dbo.T0150_HRMS_TRAINING_Questionnaire.Marks, CASE WHEN T0150_HRMS_TRAINING_Questionnaire.Training_Id IS NOT NULL THEN
                          (SELECT     t .Training_name + ','
                            FROM          T0040_Hrms_Training_master t WITH (NOLOCK)
                            WHERE      Training_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0150_HRMS_TRAINING_Questionnaire.Training_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE '' END AS Training_name, Question_Row_Option, Question_Row_Type,Video_Path
FROM         dbo.T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK) LEFT JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK) ON dbo.T0150_HRMS_TRAINING_Questionnaire.Training_Id = dbo.T0040_Hrms_Training_master.Training_id




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[5] 2[28] 3) )"
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
         Begin Table = "T0150_HRMS_TRAINING_Questionnaire"
            Begin Extent = 
               Top = 3
               Left = 280
               Bottom = 118
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Hrms_Training_master"
            Begin Extent = 
               Top = 9
               Left = 35
               Bottom = 124
               Right = 212
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_HRMS_TRAINING_Questionnaire';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0150_HRMS_TRAINING_Questionnaire';

