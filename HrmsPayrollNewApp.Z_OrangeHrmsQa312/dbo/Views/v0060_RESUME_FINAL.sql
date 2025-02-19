
CREATE VIEW [dbo].[v0060_RESUME_FINAL]
AS
SELECT     dbo.T0060_RESUME_FINAL.Tran_ID, dbo.T0060_RESUME_FINAL.Resume_ID, dbo.T0060_RESUME_FINAL.Resume_Status, dbo.T0060_RESUME_FINAL.Cmp_ID, 
                      dbo.T0060_RESUME_FINAL.Rec_post_Id, dbo.T0060_RESUME_FINAL.Approval_Date, dbo.T0060_RESUME_FINAL.Comments, dbo.T0060_RESUME_FINAL.Branch_id, 
                      dbo.T0060_RESUME_FINAL.Grd_id, dbo.T0060_RESUME_FINAL.Desig_id, dbo.T0060_RESUME_FINAL.Dept_id, dbo.T0060_RESUME_FINAL.Acceptance, 
                      dbo.T0060_RESUME_FINAL.Acceptance_Date, dbo.T0060_RESUME_FINAL.Medical_inspection, dbo.T0060_RESUME_FINAL.Police_Incpection, 
                      dbo.T0060_RESUME_FINAL.Ref_1, dbo.T0060_RESUME_FINAL.Ref_2, dbo.T0060_RESUME_FINAL.Joining_date, dbo.T0060_RESUME_FINAL.Login_id, 
                      dbo.T0060_RESUME_FINAL.Basic_Salay, ISNULL(dbo.T0060_RESUME_FINAL.Joining_status, 0) AS Joining_status, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0040_GRADE_MASTER.Grd_Name, ISNULL(dbo.T0055_Resume_Master.Initial, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, dbo.T0055_Resume_Master.Emp_First_Name, dbo.T0055_Resume_Master.Emp_Last_Name, 
                      dbo.T0052_HRMS_Posted_Recruitment.Job_title, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0011_LOGIN.Login_Name, dbo.T0060_RESUME_FINAL.Total_CTC, dbo.T0060_RESUME_FINAL.Joining_status AS Expr1, 
                      dbo.T0060_RESUME_FINAL.ReportingManager_Id, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0060_RESUME_FINAL.BusinessHead, 
                      dbo.T0060_RESUME_FINAL.Level2_Approval, dbo.T0060_RESUME_FINAL.SalaryCycle_Id, dbo.T0060_RESUME_FINAL.ShiftId, 
                      dbo.T0060_RESUME_FINAL.EmploymentTypeId, dbo.T0040_Salary_Cycle_Master.Name, dbo.T0040_TYPE_MASTER.Type_Name, 
                      dbo.T0040_SHIFT_MASTER.Shift_Name, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_date, dbo.T0052_HRMS_Posted_Recruitment.Rec_Start_date, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date, dbo.T0060_RESUME_FINAL.BusinessSegment_Id, dbo.T0060_RESUME_FINAL.Vertical_Id, 
                      dbo.T0060_RESUME_FINAL.SubVertical_Id, dbo.T0040_Vertical_Segment.Vertical_Name, dbo.T0040_Business_Segment.Segment_Name, 
                      dbo.T0050_SubVertical.SubVertical_Name, dbo.T0055_Resume_Master.Resume_Code, dbo.T0055_Resume_Master.Present_Street, 
                      dbo.T0055_Resume_Master.Present_City, dbo.T0055_Resume_Master.Present_State, dbo.T0055_Resume_Master.Present_Post_Box, 
                      dbo.T0055_Resume_Master.Primary_email, dbo.T0060_RESUME_FINAL.Assigned_Cmpid, dbo.T0060_RESUME_FINAL.Latter_Format, 
                      dbo.T0060_RESUME_FINAL.latterfile_Name, dbo.T0060_RESUME_FINAL.Salary_File_name, CASE WHEN isnull(T0060_RESUME_FINAL.notice_period, 0) 
                      = 0 THEN T0040_GRADE_MASTER.Short_Fall_Days ELSE T0060_RESUME_FINAL.notice_period END AS notice_period, dbo.T0040_GRADE_MASTER.Signature, 
                      dbo.T0080_EMP_MASTER.Emp_ID, CASE WHEN dbo.T0080_EMP_MASTER.Emp_Full_Name IS NULL 
                      THEN 'Admin' ELSE dbo.T0080_EMP_MASTER.Emp_Full_Name END AS Emp_Full_Name, CASE WHEN dbo.T0080_EMP_MASTER.Alpha_Emp_Code IS NULL 
                      THEN ' ' ELSE dbo.T0080_EMP_MASTER.Alpha_Emp_Code END AS Alpha_Emp_Code, dbo.T0060_RESUME_FINAL.R_Cmp_Id, 
                      dbo.T0060_RESUME_FINAL.Appointment_Letter_Format, dbo.T0060_RESUME_FINAL.Appointment_Letter_File, dbo.T0060_RESUME_FINAL.Accept_Appointment, 
                      dbo.T0060_RESUME_FINAL.Confirm_Emp_id, TMP.Work_Email AS HR_Email_ID, dbo.T0055_Resume_Master.Gender, 
                      dbo.T0060_RESUME_FINAL.Background_Verification, dbo.T0030_BRANCH_MASTER.Branch_City, dbo.T0030_BRANCH_MASTER.Branch_Address, 
                      dbo.T0060_RESUME_FINAL.offer_date, dbo.T0055_Resume_Master.Mobile_No, dbo.T0055_Resume_Master.Date_Of_Birth, ApprovedBy,DBO.T0060_RESUME_FINAL.S_EMP_ID,
                      dbo.T0060_RESUME_FINAL.Gross_Salary,dbo.T0060_RESUME_FINAL.Category_id
FROM         dbo.T0060_RESUME_FINAL WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_Business_Segment WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.BusinessSegment_Id = dbo.T0040_Business_Segment.Segment_ID LEFT OUTER JOIN
                      dbo.T0040_Vertical_Segment WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Vertical_Id = dbo.T0040_Vertical_Segment.Vertical_ID LEFT OUTER JOIN
                      dbo.T0050_SubVertical WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.SubVertical_Id = dbo.T0050_SubVertical.SubVertical_ID AND 
                      dbo.T0040_Vertical_Segment.Vertical_ID = dbo.T0050_SubVertical.Vertical_ID LEFT OUTER JOIN
                      dbo.T0040_Salary_Cycle_Master WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.SalaryCycle_Id = dbo.T0040_Salary_Cycle_Master.Tran_Id LEFT OUTER JOIN
                      dbo.T0040_SHIFT_MASTER  WITH (NOLOCK) ON dbo.T0060_RESUME_FINAL.ShiftId = dbo.T0040_SHIFT_MASTER.Shift_ID LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER  WITH (NOLOCK) ON dbo.T0060_RESUME_FINAL.EmploymentTypeId = dbo.T0040_TYPE_MASTER.Type_ID LEFT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Login_id = dbo.T0011_LOGIN.Login_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0011_LOGIN.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER  WITH (NOLOCK) ON dbo.T0060_RESUME_FINAL.Desig_id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Dept_id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Rec_post_Id = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0055_Resume_Master  WITH (NOLOCK) ON dbo.T0060_RESUME_FINAL.Resume_ID = dbo.T0055_Resume_Master.Resume_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER  WITH (NOLOCK) ON dbo.T0060_RESUME_FINAL.Grd_id = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0060_RESUME_FINAL.Branch_id = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0051_HRMS_Recruitment_Setting AS HRM  WITH (NOLOCK) ON HRM.RecApplicationId = dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS TMP WITH (NOLOCK)  ON TMP.Emp_ID = HRM.PostVacancy_EmpId



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'    Bottom = 340
               Right = 979
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0011_LOGIN"
            Begin Extent = 
               Top = 0
               Left = 633
               Bottom = 115
               Right = 803
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 133
               Left = 66
               Bottom = 252
               Right = 310
            End
            DisplayFlags = 280
            TopColumn = 130
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 30
               Left = 823
               Bottom = 145
               Right = 984
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 5
               Left = 467
               Bottom = 120
               Right = 619
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 57
               Left = 293
               Bottom = 172
               Right = 481
            End
            DisplayFlags = 280
            TopColumn = 21
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 227
               Left = 249
               Bottom = 342
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 225
               Left = 633
               Bottom = 340
               Right = 820
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HRM"
            Begin Extent = 
               Top = 468
               Left = 38
               Bottom = 587
               Right = 230
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMP"
            Begin Extent = 
               Top = 588
               Left = 38
               Bottom = 707
               Right = 282
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
      Begin ColumnWidths = 71
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
         Wid', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'v0060_RESUME_FINAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'th = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1740
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
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'v0060_RESUME_FINAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'v0060_RESUME_FINAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[5] 2[51] 3) )"
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
         Begin Table = "T0060_RESUME_FINAL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 47
         End
         Begin Table = "T0040_Business_Segment"
            Begin Extent = 
               Top = 356
               Left = 635
               Bottom = 471
               Right = 817
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_Vertical_Segment"
            Begin Extent = 
               Top = 356
               Left = 268
               Bottom = 471
               Right = 443
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_SubVertical"
            Begin Extent = 
               Top = 359
               Left = 830
               Bottom = 474
               Right = 1023
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_Salary_Cycle_Master"
            Begin Extent = 
               Top = 223
               Left = 454
               Bottom = 338
               Right = 608
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_SHIFT_MASTER"
            Begin Extent = 
               Top = 349
               Left = 84
               Bottom = 464
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_TYPE_MASTER"
            Begin Extent = 
               Top = 225
               Left = 827
           ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'v0060_RESUME_FINAL';

