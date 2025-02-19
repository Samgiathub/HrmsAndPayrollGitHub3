





CREATE VIEW [dbo].[V0090_HRMS_RESUME_EDU]
AS
SELECT     dbo.T0055_Resume_Master.Resume_Id,dbo.T0090_HRMS_RESUME_QUALIFICATION.Year, dbo.T0090_HRMS_RESUME_QUALIFICATION.Score, 
                      dbo.T0090_HRMS_RESUME_QUALIFICATION.Qual_ID, dbo.T0040_QUALIFICATION_MASTER.Qual_Name, dbo.T0090_HRMS_RESUME_QUALIFICATION.Cmp_id, 
                      dbo.T0090_HRMS_RESUME_QUALIFICATION.Specialization, dbo.T0090_HRMS_RESUME_QUALIFICATION.End_Date, 
                      dbo.T0090_HRMS_RESUME_QUALIFICATION.St_Date, dbo.T0090_HRMS_RESUME_QUALIFICATION.Row_ID, dbo.T0055_Resume_Master.Resume_Code, 
                      dbo.T0090_HRMS_RESUME_QUALIFICATION.Comments, dbo.T0090_HRMS_RESUME_QUALIFICATION.EduCertificate_path, 
                      dbo.T0090_HRMS_RESUME_QUALIFICATION.University, dbo.T0090_HRMS_RESUME_QUALIFICATION.Division, 
                      dbo.T0055_Resume_Master.Initial + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name
FROM         dbo.T0055_Resume_Master WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0090_HRMS_RESUME_QUALIFICATION WITH (NOLOCK)  ON 
                      dbo.T0055_Resume_Master.Resume_Id = dbo.T0090_HRMS_RESUME_QUALIFICATION.Resume_ID LEFT OUTER JOIN
                      dbo.T0040_QUALIFICATION_MASTER WITH (NOLOCK)  ON dbo.T0090_HRMS_RESUME_QUALIFICATION.Qual_ID = dbo.T0040_QUALIFICATION_MASTER.Qual_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[16] 3) )"
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
               Top = 0
               Left = 0
               Bottom = 115
               Right = 188
            End
            DisplayFlags = 280
            TopColumn = 37
         End
         Begin Table = "T0090_HRMS_RESUME_QUALIFICATION"
            Begin Extent = 
               Top = 6
               Left = 264
               Bottom = 201
               Right = 549
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "T0040_QUALIFICATION_MASTER"
            Begin Extent = 
               Top = 65
               Left = 92
               Bottom = 180
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
      Begin ColumnWidths = 17
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_RESUME_EDU';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_HRMS_RESUME_EDU';

