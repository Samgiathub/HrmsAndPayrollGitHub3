







CREATE  VIEW [dbo].[V0050_HRMS_Recruitment_Request]
AS
SELECT     dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID, dbo.T0050_HRMS_Recruitment_Request.Job_Title, dbo.T0050_HRMS_Recruitment_Request.Cmp_id, 
                      dbo.T0050_HRMS_Recruitment_Request.S_Emp_ID, ISNULL(Alpha_Emp_Code +' - '+ dbo.T0080_EMP_MASTER.Emp_Full_Name, 'Admin') AS Emp_Full_Name,T0080_EMP_MASTER.Emp_ID ,  --Emp_id Added by Jaina 11-11-2016   
                      ISNULL(dbo.T0080_EMP_MASTER.Alpha_Emp_Code, '') AS alpha_Emp_Code, ISNULL(dbo.T0080_EMP_MASTER.Work_Email, '') AS Work_Email, 
                      dbo.T0050_HRMS_Recruitment_Request.Login_ID, dbo.T0050_HRMS_Recruitment_Request.Posted_date, dbo.T0050_HRMS_Recruitment_Request.Grade_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Desi_Id, dbo.T0050_HRMS_Recruitment_Request.Qualification_detail, 
                      dbo.T0050_HRMS_Recruitment_Request.Experience_Detail, dbo.T0050_HRMS_Recruitment_Request.Branch_id, dbo.T0050_HRMS_Recruitment_Request.Type_ID, 
                      dbo.T0050_HRMS_Recruitment_Request.Dept_Id, dbo.T0050_HRMS_Recruitment_Request.Skill_detail, dbo.T0050_HRMS_Recruitment_Request.Job_Description, 
                      dbo.T0050_HRMS_Recruitment_Request.No_of_vacancies, dbo.T0050_HRMS_Recruitment_Request.App_status, ISNULL(dbo.T0040_TYPE_MASTER.Type_Name, 
                      'All') AS Type_Name, dbo.T0030_BRANCH_MASTER.Branch_Code, ISNULL(dbo.T0030_BRANCH_MASTER.Branch_Name, 'All') AS Branch_Name, 
                      ISNULL(dbo.T0040_DESIGNATION_MASTER.Desig_Name, 'All') AS Desig_Name, ISNULL(dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 'All') AS Dept_Name, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date, dbo.T0050_HRMS_Recruitment_Request.BusinessSegment_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Vertical_Id, dbo.T0050_HRMS_Recruitment_Request.SubVertical_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Type_Of_Opening, dbo.T0050_JobDescription_Master.Job_Code, dbo.T0050_HRMS_Recruitment_Request.JD_CodeId, 
                      dbo.T0050_HRMS_Recruitment_Request.Budgeted, dbo.T0050_HRMS_Recruitment_Request.Exp_Min, dbo.T0050_HRMS_Recruitment_Request.Exp_Max, 
                      dbo.T0050_HRMS_Recruitment_Request.Rep_EmployeeId,Justification,CTC_Budget as CTC_Budget,Is_Left_ReplaceEmpId,Comments,ISNULL(T0050_HRMS_Recruitment_Request.Attach_Doc,'')Attach_Doc,
                      dbo.T0050_HRMS_Recruitment_Request.document_ID,dbo.T0050_HRMS_Recruitment_Request.Experience_Type,ISNULL(MIN_CTC_Budget,0)MIN_CTC_Budget,MRF_Code,Category_id,isnull(Manager_Attach_Docs,'')Manager_Attach_Docs,Gender_Specific
FROM         dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_Business_Segment WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.BusinessSegment_Id = dbo.T0040_Business_Segment.Segment_ID LEFT OUTER JOIN
                      dbo.T0050_SubVertical WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.SubVertical_Id = dbo.T0050_SubVertical.SubVertical_ID LEFT OUTER JOIN
                      dbo.T0040_Vertical_Segment WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.Vertical_Id = dbo.T0040_Vertical_Segment.Vertical_ID AND 
                      dbo.T0050_SubVertical.Vertical_ID = dbo.T0040_Vertical_Segment.Vertical_ID LEFT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  ON 
                      dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.Dept_Id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.Desi_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.Type_ID = dbo.T0040_TYPE_MASTER.Type_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0011_LOGIN  WITH (NOLOCK) ON dbo.T0011_LOGIN.Login_ID = dbo.T0050_HRMS_Recruitment_Request.Login_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0011_LOGIN.Emp_ID LEFT OUTER JOIN
                      dbo.T0050_JobDescription_Master WITH (NOLOCK)  ON dbo.T0050_JobDescription_Master.Job_Id = dbo.T0050_HRMS_Recruitment_Request.JD_CodeId
















GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[47] 4[5] 2[5] 3) )"
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
         Begin Table = "T0050_HRMS_Recruitment_Request"
            Begin Extent = 
               Top = 4
               Left = 300
               Bottom = 119
               Right = 480
            End
            DisplayFlags = 280
            TopColumn = 17
         End
         Begin Table = "T0040_Business_Segment"
            Begin Extent = 
               Top = 180
               Left = 625
               Bottom = 295
               Right = 807
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_SubVertical"
            Begin Extent = 
               Top = 246
               Left = 242
               Bottom = 361
               Right = 435
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_Vertical_Segment"
            Begin Extent = 
               Top = 307
               Left = 543
               Bottom = 422
               Right = 718
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 12
               Left = 606
               Bottom = 127
               Right = 768
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 120
               Left = 491
               Bottom = 235
               Right = 643
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 149
           ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_HRMS_Recruitment_Request';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'    Left = 43
               Bottom = 264
               Right = 204
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "T0040_TYPE_MASTER"
            Begin Extent = 
               Top = 131
               Left = 295
               Bottom = 246
               Right = 447
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0011_LOGIN"
            Begin Extent = 
               Top = 298
               Left = 756
               Bottom = 413
               Right = 926
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 0
               Left = 31
               Bottom = 242
               Right = 248
            End
            DisplayFlags = 280
            TopColumn = 71
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 31
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_HRMS_Recruitment_Request';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_HRMS_Recruitment_Request';

