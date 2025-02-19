




CREATE VIEW [dbo].[V0060_HRMS_CandidateFinalization1]
AS
SELECT     c.Resume_ID, c.Resume_Status, c.Cmp_ID, c.Rec_post_Id, c.Branch_id, c.Grd_id, c.Desig_id, c.Dept_id, c.Joining_date, c.Total_CTC, c.ReportingManager_Id, 
                      c.SalaryCycle_Id, c.ShiftId, c.EmploymentTypeId, c.BusinessSegment_Id, c.Vertical_Id, c.SubVertical_Id, c.app_full_name, c.Emp_First_Name, c.Emp_Second_Name, 
                      c.Emp_Last_Name, c.Initial, c.Gender, c.Job_title, c.Basic_Salay, c.Rec_Post_Code, c.Dept_Name, c.Desig_Name, c.Branch_Name, c.Segment_Name, c.Grd_Name, 
                      c.Name, c.SubVertical_Name, c.Vertical_Name, c.Level2_Approval, c.Emp_Full_Name, c.Work_Email, c.Approval_Date, c.PaymentMode, c.BankId, c.AccountNo_Bank, 
                      c.Remarks, c.FinalStatus, c.ApprovedBy, c.IsEmployee, c.Login_id, c.Salary_Rule, c.Acceptance, r.Resume_Code, r.HasPancard, r.PanCardAck_Path, r.PanCardNo, 
                      r.PanCardAck_No, r.PanCardProof, r.Date_Of_Birth, r.Marital_Status, r.Present_Loc, r.Permanent_Loc_ID, r.Gender AS Expr1, r.Mobile_No, r.Present_Street, 
                      r.Present_City, r.Present_State, r.Present_Post_Box, r.FatherName, h.emp_file_name AS photo, r.Transfer_RecPostId,
                      c.Resume_Code+'-'+c.Emp_First_Name+' '+c.Emp_Last_Name as Candidate_Name,
                          (SELECT     TOP (1) ISNULL(Employer_Name, '''') AS Expr1
                            FROM          dbo.T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK)
                            WHERE      (Resume_ID = c.Resume_ID)) AS Employer,
                          (SELECT     TOP (1) ISNULL(GrossSalary, 0) AS Expr1
                            FROM          dbo.T0090_HRMS_RESUME_EXPERIENCE AS T0090_HRMS_RESUME_EXPERIENCE_5 WITH (NOLOCK)
                            WHERE      (Resume_ID = c.Resume_ID)
                            ORDER BY Row_ID DESC) AS GrossSalary,
                          (SELECT     TOP (1) ISNULL(ProfessionalTax, 0) AS Expr1
                            FROM          dbo.T0090_HRMS_RESUME_EXPERIENCE AS T0090_HRMS_RESUME_EXPERIENCE_4 WITH (NOLOCK)
                            WHERE      (Resume_ID = c.Resume_ID)
                            ORDER BY Row_ID DESC) AS ProfessionalTax,
                          (SELECT     TOP (1) ISNULL(Surcharge, 0) AS Expr1
                            FROM          dbo.T0090_HRMS_RESUME_EXPERIENCE AS T0090_HRMS_RESUME_EXPERIENCE_3 WITH (NOLOCK)
                            WHERE      (Resume_ID = c.Resume_ID)
                            ORDER BY Row_ID DESC) AS Surcharge,
                          (SELECT     TOP (1) ISNULL(EducationCess, 0) AS Expr1
                            FROM          dbo.T0090_HRMS_RESUME_EXPERIENCE AS T0090_HRMS_RESUME_EXPERIENCE_2 WITH (NOLOCK)
                            WHERE      (Resume_ID = c.Resume_ID)
                            ORDER BY Row_ID DESC) AS EducationCess,
                          (SELECT     TOP (1) ISNULL(TDS, 0) AS Expr1
                            FROM          dbo.T0090_HRMS_RESUME_EXPERIENCE AS T0090_HRMS_RESUME_EXPERIENCE_1 WITH (NOLOCK)
                            WHERE      (Resume_ID = c.Resume_ID)
                            ORDER BY Row_ID DESC) AS TDS, Em.Alpha_Emp_Code, h.Blood_group, h.Height, ISNULL(c.Accept_Appointment, 0) AS Accept_appointment
FROM         dbo.V0060_HRMS_Candidates_Finalization AS c WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0055_Resume_Master AS r WITH (NOLOCK) ON r.Resume_Id = c.Resume_ID LEFT OUTER JOIN
                      dbo.T0090_HRMS_RESUME_HEALTH AS h WITH (NOLOCK) ON h.Resume_ID = c.Resume_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK) ON c.confirm_emp_id = Em.Emp_ID
WHERE     (ISNULL(c.Accept_Appointment, 0) <> 2)




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[5] 2[51] 3) )"
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
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "r"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "h"
            Begin Extent = 
               Top = 6
               Left = 272
               Bottom = 125
               Right = 433
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Em"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_CandidateFinalization1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_CandidateFinalization1';

