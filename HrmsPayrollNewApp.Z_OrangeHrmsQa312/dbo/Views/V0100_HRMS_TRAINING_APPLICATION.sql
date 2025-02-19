



CREATE VIEW [dbo].[V0100_HRMS_TRAINING_APPLICATION]
AS
SELECT     dbo.T0100_HRMS_TRAINING_APPLICATION.Training_App_ID, dbo.T0100_HRMS_TRAINING_APPLICATION.Training_id, 
                      dbo.T0100_HRMS_TRAINING_APPLICATION.Training_Desc, dbo.T0100_HRMS_TRAINING_APPLICATION.For_Date, 
                      dbo.T0100_HRMS_TRAINING_APPLICATION.Posted_Emp_ID, dbo.T0100_HRMS_TRAINING_APPLICATION.Skill_ID, 
                      dbo.T0100_HRMS_TRAINING_APPLICATION.App_Status, dbo.T0100_HRMS_TRAINING_APPLICATION.Cmp_ID, dbo.T0100_HRMS_TRAINING_APPLICATION.Login_ID, 
                      dbo.T0100_HRMS_TRAINING_APPLICATION.System_Date, dbo.T0100_HRMS_TRAINING_APPLICATION.Training_Plan, dbo.T0040_SKILL_MASTER.Skill_Name, 
                      dbo.T0040_Hrms_Training_master.Training_name, dbo.T0040_Hrms_Training_master.Training_description, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0080_EMP_MASTER.Emp_ID, ISNULL(dbo.T0040_Hrms_Training_master.Training_Category_Id, 0) AS Training_Category_Id,T0095_INCREMENT.Cat_ID as Category_id
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID ON 
                      dbo.T0040_DESIGNATION_MASTER.Desig_ID = dbo.T0095_INCREMENT.Desig_Id ON 
                      dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID RIGHT OUTER JOIN
                      dbo.T0040_SKILL_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK)  ON dbo.T0040_SKILL_MASTER.Skill_ID = dbo.T0100_HRMS_TRAINING_APPLICATION.Skill_ID ON 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_HRMS_TRAINING_APPLICATION.Posted_Emp_ID LEFT OUTER JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK)  ON dbo.T0100_HRMS_TRAINING_APPLICATION.Training_id = dbo.T0040_Hrms_Training_master.Training_id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT JOIN
                      dbo.T0030_CATEGORY_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Cat_ID = dbo.T0030_CATEGORY_MASTER.Cat_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'        Bottom = 605
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 486
               Left = 270
               Bottom = 605
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 606
               Left = 38
               Bottom = 725
               Right = 216
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
      Begin ColumnWidths = 12
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_HRMS_TRAINING_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_HRMS_TRAINING_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[22] 4[5] 2[56] 3) )"
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
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 126
               Left = 257
               Bottom = 245
               Right = 468
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_SKILL_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0100_HRMS_TRAINING_APPLICATION"
            Begin Extent = 
               Top = 366
               Left = 236
               Bottom = 485
               Right = 405
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Hrms_Training_master"
            Begin Extent = 
               Top = 486
               Left = 38
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_HRMS_TRAINING_APPLICATION';

