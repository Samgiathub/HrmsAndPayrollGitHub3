


CREATE VIEW [dbo].[V0130_HRMS_TRAINING_EMPLOYEE_DETAIL]
AS
SELECT     dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Tran_emp_Detail_ID, dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_App_ID, 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_Apr_ID, dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_tran_status, 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.cmp_id, 
                      CASE WHEN EMP_TRAN_STATUS = 0 THEN 'Pending' WHEN EMP_TRAN_STATUS = 1 THEN 'Approved' WHEN Emp_tran_status = 4 THEN 'Unplanned' ELSE 'Rejected'
                       END AS STATUS, dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Date, dbo.T0040_Hrms_Training_master.Training_name, dbo.T0120_HRMS_TRAINING_APPROVAL.Description, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Faculty, dbo.T0120_HRMS_TRAINING_APPROVAL.Place, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_End_Date, 
                      dbo.T0030_Hrms_Training_Type.Training_TypeName AS Type, dbo.T0120_HRMS_TRAINING_APPROVAL.emp_feedback, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Sup_feedback, dbo.T0050_HRMS_Training_Provider_master.Provider_Name, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Cost, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Pro_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.grd_id, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Apr_Status, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(50)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_new, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_FromTime, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_ToTime, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Code, dbo.T0040_GRADE_MASTER.Grd_Name
FROM         dbo.T0030_BRANCH_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)  ON 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Emp_ID LEFT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id ON 
                      dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID ON 
                      dbo.T0030_BRANCH_MASTER.Branch_ID = dbo.T0095_INCREMENT.Branch_ID LEFT OUTER JOIN
                      dbo.T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK)  ON dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id = dbo.T0040_Hrms_Training_master.Training_id ON 
                      dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL.Training_Apr_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID LEFT OUTER JOIN
                      dbo.T0050_HRMS_Training_Provider_master WITH (NOLOCK)  ON 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Pro_ID = dbo.T0050_HRMS_Training_Provider_master.Training_Pro_ID LEFT OUTER JOIN
                      dbo.T0030_Hrms_Training_Type WITH (NOLOCK)  ON dbo.T0030_Hrms_Training_Type.Training_Type_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Type


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[29] 3) )"
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
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0130_HRMS_TRAINING_EMPLOYEE_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 125
               Right = 458
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
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 366
               Left = 245
               Bottom = 485
               Right = 405
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 486
               Left = 38
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAINING_EMPLOYEE_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         Bottom = 605
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_HRMS_TRAINING_APPROVAL"
            Begin Extent = 
               Top = 486
               Left = 259
               Bottom = 605
               Right = 462
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Hrms_Training_master"
            Begin Extent = 
               Top = 606
               Left = 38
               Bottom = 725
               Right = 223
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_HRMS_Training_Provider_master"
            Begin Extent = 
               Top = 606
               Left = 261
               Bottom = 725
               Right = 465
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAINING_EMPLOYEE_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0130_HRMS_TRAINING_EMPLOYEE_DETAIL';

