





CREATE VIEW [dbo].[V0090_HRMS_RESUME_EXP]
AS
SELECT     dbo.T0090_HRMS_RESUME_EXPERIENCE.Desig_Name, dbo.T0090_HRMS_RESUME_EXPERIENCE.St_Date,
CASE WHEN CONVERT(varchar(15),End_Date,103)='01/01/1900' THEN '' ELSE CONVERT(varchar(15),End_Date,103) END AS End_Date,
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.Resume_ID, dbo.T0090_HRMS_RESUME_EXPERIENCE.Cmp_ID, 
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.Employer_Name, dbo.T0090_HRMS_RESUME_EXPERIENCE.Row_ID, dbo.T0055_Resume_Master.Resume_Code, 
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.ExpProof, dbo.T0090_HRMS_RESUME_EXPERIENCE.DocumentType, 
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.Fromdate, dbo.T0090_HRMS_RESUME_EXPERIENCE.Todate, dbo.T0090_HRMS_RESUME_EXPERIENCE.GrossSalary, 
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.ProfessionalTax, dbo.T0090_HRMS_RESUME_EXPERIENCE.Surcharge, 
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.EducationCess, dbo.T0090_HRMS_RESUME_EXPERIENCE.TDS, 
                      dbo.T0055_Resume_Master.Initial + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, dbo.T0090_HRMS_RESUME_EXPERIENCE.ITax, 
                      dbo.T0090_HRMS_RESUME_EXPERIENCE.FYear, ISNULL(dbo.T0090_HRMS_RESUME_EXPERIENCE.StillContinue, 0) AS StillContinue, 
                      ISNULL(dbo.T0090_HRMS_RESUME_EXPERIENCE.Fresher, 0) AS Fresher,ISNULL(CTC,0)CTC,
                      ISNULL(Manager_Name,'')Manager_Name,ISNULL(Manager_Contact_No,0)Manager_Contact_No,ISNULL(Reason_For_Leaving,'')Reason_For_Leaving
FROM         dbo.T0055_Resume_Master WITH (NOLOCK) INNER JOIN
                      dbo.T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Resume_Id = dbo.T0090_HRMS_RESUME_EXPERIENCE.Resume_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[18] 2[20] 3) )"
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
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 35
         End
         Begin Table = "T0090_HRMS_RESUME_EXPERIENCE"
            Begin Extent = 
               Top = 6
               Left = 264
               Bottom = 121
               Right = 422
            End
            DisplayFlags = 280
            TopColumn = 14
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2940
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_RESUME_EXP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_RESUME_EXP';

