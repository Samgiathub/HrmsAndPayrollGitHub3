





CREATE VIEW [dbo].[V0120_HRMS_TRAINING_APPROVAL]
AS
SELECT     dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_App_ID, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Login_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id, 
                      Qry.From_Date AS Training_Date/* dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Date*/ , dbo.T0120_HRMS_TRAINING_APPROVAL.Place, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Faculty, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Pro_ID, dbo.T0120_HRMS_TRAINING_APPROVAL.Description, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Cost, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Cost_per_Emp, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Apr_Status, dbo.T0120_HRMS_TRAINING_APPROVAL.Cmp_ID, 
                      Qry.To_Date AS Training_End_Date/*dbo.T0120_HRMS_TRAINING_APPROVAL.Training_End_Date*/ , dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Type, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Leave_Type, dbo.T0120_HRMS_TRAINING_APPROVAL.no_of_day, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Impact_Salary, dbo.T0120_HRMS_TRAINING_APPROVAL.emp_feedback, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Sup_feedback, dbo.T0040_Hrms_Training_master.Training_name, 
                     CASE WHEN isnull(dbo.T0050_HRMS_Training_Provider_master.Provider_TypeId, 0) 
                      = 0 THEN dbo.T0050_HRMS_Training_Provider_master.Provider_Name ELSE
                           CASE WHEN T0050_HRMS_Training_Provider_master.Provider_Emp_Id IS NOT NULL 
                      THEN
                          (SELECT     E.Emp_Full_Name + ','
                            FROM          T0080_EMP_MASTER E WITH (NOLOCK)
                            WHERE      E.Emp_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0050_HRMS_Training_Provider_master.Provider_Emp_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE '' END
                    END Provider_Name, 
                      dbo.T0050_HRMS_Training_Provider_master.Provider_Email, 
                      /*CASE WHEN training_type = 1 THEN 'External' ELSE Case When training_type = 2 then 'Internal' End  END AS Type, */ T0030_Hrms_Training_Type.Training_TypeName
                       AS Type, CASE WHEN training_leave_type = 0 THEN 'Paid' ELSE 'Unpaid' END AS Leave_type, 
                      CASE WHEN impact_salary = 0 THEN 'No' ELSE 'Yes' END AS Salary_impact, 
                      CASE WHEN Apr_status = 0 THEN 'Pending' WHEN Apr_status = 1 THEN 'Approve' ELSE 'Reject' END AS Apr_status_name, 
                      dbo.T0010_COMPANY_MASTER.Cmp_Address, dbo.T0010_COMPANY_MASTER.Cmp_Name, dbo.T0120_HRMS_TRAINING_APPROVAL.Comments, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.branch_id, dbo.T0120_HRMS_TRAINING_APPROVAL.desig_id, dbo.T0120_HRMS_TRAINING_APPROVAL.grd_id, 
                      dbo.T0100_HRMS_TRAINING_APPLICATION.Skill_ID, dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_SKILL_MASTER.Skill_Name, 
                      isnull(dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Code, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Apr_ID) AS Training_Code, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_FromTime, dbo.T0120_HRMS_TRAINING_APPROVAL.Training_ToTime, 
                      T0120_HRMS_TRAINING_APPROVAL.dept_id, CASE WHEN T0120_HRMS_TRAINING_APPROVAL.dept_id IS NOT NULL THEN
                          (SELECT     d .Dept_Name + ','
                            FROM          T0040_DEPARTMENT_MASTER d WITH (NOLOCK)
                            WHERE      Dept_Id IN
                                                (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0120_HRMS_TRAINING_APPROVAL.dept_id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Dept_Name, isnull(lock, 0) lock, 
                      CASE WHEN T0120_HRMS_TRAINING_APPROVAL.desig_id IS NOT NULL THEN
                          (SELECT     dg.Desig_Name + ','
                            FROM          T0040_Designation_MASTER dg WITH (NOLOCK)
                            WHERE      desig_id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0120_HRMS_TRAINING_APPROVAL.desig_id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Desig_Name, CASE WHEN T0120_HRMS_TRAINING_APPROVAL.branch_id IS NOT NULL 
                      THEN
                          (SELECT     b.Branch_Name + ','
                            FROM          T0030_branch_MASTER b WITH (NOLOCK)
                            WHERE      branch_id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0120_HRMS_TRAINING_APPROVAL.branch_id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Branch_Name, CASE WHEN T0120_HRMS_TRAINING_APPROVAL.grd_id IS NOT NULL 
                      THEN
                          (SELECT     g.grd_name + ','
                            FROM          T0040_grade_MASTER g WITH (NOLOCK)
                            WHERE      grd_id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0120_HRMS_TRAINING_APPROVAL.grd_id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS grd_name, T0120_HRMS_TRAINING_APPROVAL.bond_Month, 
                      T0120_HRMS_TRAINING_APPROVAL.Attachment, T0120_HRMS_TRAINING_APPROVAL.PublishTraining, Manager_FeedbackDays, 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.VideoURL, dbo.T0120_HRMS_TRAINING_APPROVAL.latitude, dbo.T0120_HRMS_TRAINING_APPROVAL.longitude, 
                      isnull(Training_Category_Id, 0) Training_Category_Id,T0120_HRMS_TRAINING_APPROVAL.category_id,Training_Cordinator,Training_Director
FROM         dbo.T0040_SKILL_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0100_HRMS_TRAINING_APPLICATION WITH (NOLOCK) ON dbo.T0040_SKILL_MASTER.Skill_ID = dbo.T0100_HRMS_TRAINING_APPLICATION.Skill_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0100_HRMS_TRAINING_APPLICATION.Posted_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID RIGHT OUTER JOIN
                      dbo.T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) ON 
                      dbo.T0100_HRMS_TRAINING_APPLICATION.Training_App_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_App_ID LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.dept_id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.grd_id = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.Login_ID = dbo.T0011_LOGIN.Login_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK) ON dbo.T0120_HRMS_TRAINING_APPROVAL.Training_id = dbo.T0040_Hrms_Training_master.Training_id LEFT OUTER JOIN
                      dbo.T0050_HRMS_Training_Provider_master WITH (NOLOCK) ON 
                      dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Pro_ID = dbo.T0050_HRMS_Training_Provider_master.Training_Pro_ID LEFT OUTER JOIN
                      dbo.T0030_Hrms_Training_Type WITH (NOLOCK) ON dbo.T0030_Hrms_Training_Type.Training_Type_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_Type INNER JOIN
                          (SELECT     MIN(FROM_DATE) AS From_Date, MAX(TO_DATE) AS To_Date, Training_App_ID
                            FROM          T0120_HRMS_TRAINING_SCHEDULE WITH (NOLOCK)
                            GROUP BY Training_App_ID) Qry ON Qry.Training_App_ID = dbo.T0120_HRMS_TRAINING_APPROVAL.Training_App_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[5] 2[66] 3) )"
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_HRMS_TRAINING_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_HRMS_TRAINING_APPROVAL';

