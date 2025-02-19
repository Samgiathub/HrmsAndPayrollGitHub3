



CREATE  VIEW [dbo].[V0060_HRMS_Candidates_Finalization]
AS
SELECT     dbo.T0060_RESUME_FINAL.Resume_ID, dbo.T0060_RESUME_FINAL.Resume_Status, dbo.T0060_RESUME_FINAL.Cmp_ID, dbo.T0060_RESUME_FINAL.Rec_post_Id, 
                      dbo.T0060_RESUME_FINAL.Branch_id, dbo.T0060_RESUME_FINAL.Grd_id, dbo.T0060_RESUME_FINAL.Desig_id, dbo.T0060_RESUME_FINAL.Dept_id, 
                      dbo.T0060_RESUME_FINAL.Joining_date, dbo.T0060_RESUME_FINAL.Total_CTC, dbo.T0060_RESUME_FINAL.ReportingManager_Id, 
                      dbo.T0060_RESUME_FINAL.SalaryCycle_Id, dbo.T0060_RESUME_FINAL.ShiftId, dbo.T0060_RESUME_FINAL.EmploymentTypeId, 
                      dbo.T0060_RESUME_FINAL.BusinessSegment_Id, dbo.T0060_RESUME_FINAL.Vertical_Id, dbo.T0060_RESUME_FINAL.SubVertical_Id, 
                      dbo.T0055_Resume_Master.Initial + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS app_full_name, dbo.T0055_Resume_Master.Emp_First_Name, 
                      dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Emp_Last_Name, dbo.T0055_Resume_Master.Initial, 
                      dbo.T0055_Resume_Master.Gender, dbo.T0052_HRMS_Posted_Recruitment.Job_title, dbo.T0060_RESUME_FINAL.Basic_Salay, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_Business_Segment.Segment_Name, dbo.T0040_GRADE_MASTER.Grd_Name, 
                      dbo.T0040_Salary_Cycle_Master.Name, dbo.T0050_SubVertical.SubVertical_Name, dbo.T0040_Vertical_Segment.Vertical_Name, 
                      dbo.T0060_RESUME_FINAL.Level2_Approval, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Work_Email, 
                      dbo.T0060_RESUME_FINAL.Approval_Date, dbo.T0060_RESUME_FINAL.PaymentMode, dbo.T0060_RESUME_FINAL.BankId, 
                      dbo.T0060_RESUME_FINAL.AccountNo_Bank, dbo.T0060_RESUME_FINAL.Remarks, dbo.T0060_RESUME_FINAL.FinalStatus, 
                      dbo.T0060_RESUME_FINAL.ApprovedBy, dbo.T0060_RESUME_FINAL.IsEmployee, dbo.T0055_Resume_Master.Date_Of_Birth, 
                      dbo.T0055_Resume_Master.Date_Of_Join, dbo.T0055_Resume_Master.Mobile_No, dbo.T0060_RESUME_FINAL.Login_id, dbo.T0060_RESUME_FINAL.Salary_Rule, 
                      ISNULL(dbo.T0060_RESUME_FINAL.Confirm_Emp_id, 0) AS confirm_emp_id, dbo.T0055_Resume_Master.Resume_Code, 
                      dbo.T0055_Resume_Master.Permanent_Street, dbo.T0055_Resume_Master.Permanent_City, dbo.T0055_Resume_Master.Permanent_State, 
                      dbo.T0055_Resume_Master.Permanentt_Post_Box, dbo.T0055_Resume_Master.Home_Tel_no, dbo.T0010_COMPANY_MASTER.Cmp_Name, 
                      dbo.T0060_RESUME_FINAL.Acceptance, dbo.T0060_RESUME_FINAL.Accept_Appointment, dbo.T0055_Resume_Master.Resume_Posted_date, 
                      dbo.T0060_RESUME_FINAL.Gross_Salary, dbo.T0060_RESUME_FINAL.IFSC_Code,dbo.T0060_RESUME_FINAL.Category_ID,Type_Of_Opening,CZ.Tran_Id AS Customize_column
FROM         dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0060_RESUME_FINAL WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.ReportingManager_Id = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0060_RESUME_FINAL.Rec_post_Id INNER JOIN
					  T0050_HRMS_Recruitment_Request HR ON HR.Rec_Req_ID= dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID  LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Dept_id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER  WITH (NOLOCK) ON dbo.T0060_RESUME_FINAL.Grd_id = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_Business_Segment WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.BusinessSegment_Id = dbo.T0040_Business_Segment.Segment_ID LEFT OUTER JOIN
                      dbo.T0040_Salary_Cycle_Master WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Tran_ID = dbo.T0040_Salary_Cycle_Master.Tran_Id LEFT OUTER JOIN
                      dbo.T0050_SubVertical WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.SubVertical_Id = dbo.T0050_SubVertical.SubVertical_ID LEFT OUTER JOIN
                      dbo.T0040_Vertical_Segment WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Vertical_Id = dbo.T0040_Vertical_Segment.Vertical_ID LEFT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Resume_ID = dbo.T0055_Resume_Master.Resume_Id LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Cmp_id = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
					  T0081_CUSTOMIZED_COLUMN CZ ON dbo.T0052_HRMS_Posted_Recruitment.Cmp_id=CZ.Cmp_Id AND CZ.Column_Name='Additional opening' AND Table_Name='Employee Master'  

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[58] 4[5] 2[5] 3) )"
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
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 127
               Left = 36
               Bottom = 242
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0060_RESUME_FINAL"
            Begin Extent = 
               Top = 0
               Left = 67
               Bottom = 292
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 34
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 169
               Left = 220
               Bottom = 284
               Right = 437
            End
            DisplayFlags = 280
            TopColumn = 31
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 30
               Left = 276
               Bottom = 145
               Right = 463
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 6
               Left = 490
               Bottom = 121
               Right = 642
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 126
               Left = 681
               Bottom = 241
               Right = 856
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 6
               Left = 680
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_Candidates_Finalization';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'      Bottom = 121
               Right = 841
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Business_Segment"
            Begin Extent = 
               Top = 126
               Left = 461
               Bottom = 241
               Right = 643
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Salary_Cycle_Master"
            Begin Extent = 
               Top = 232
               Left = 4
               Bottom = 347
               Right = 158
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_SubVertical"
            Begin Extent = 
               Top = 269
               Left = 621
               Bottom = 413
               Right = 814
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Vertical_Segment"
            Begin Extent = 
               Top = 250
               Left = 453
               Bottom = 365
               Right = 628
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 143
               Left = 718
               Bottom = 258
               Right = 915
            End
            DisplayFlags = 280
            TopColumn = 18
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 288
               Left = 196
               Bottom = 407
               Right = 437
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
      Begin ColumnWidths = 61
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
En', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_Candidates_Finalization';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'd
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_Candidates_Finalization';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_Candidates_Finalization';

