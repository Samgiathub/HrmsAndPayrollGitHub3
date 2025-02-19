

CREATE VIEW [dbo].[V0090_EMP_HR_DOC_Detail]
AS
SELECT     dbo.T0090_EMP_HR_DOC_Detail.accetpeted, dbo.T0090_EMP_HR_DOC_Detail.accepted_date, dbo.T0090_EMP_HR_DOC_Detail.Emp_doc_ID, 
                      dbo.T0090_EMP_HR_DOC_Detail.HR_DOC_ID, dbo.T0090_EMP_HR_DOC_Detail.Emp_id, dbo.T0090_EMP_HR_DOC_Detail.Doc_content, 
                      dbo.T0040_HR_DOC_MASTER.Doc_Title, dbo.T0090_EMP_HR_DOC_Detail.cmp_id, 
                      CASE WHEN accetpeted = 0 THEN 'Pending' WHEN accetpeted = 1 THEN 'Accepted' ELSE 'Rejected' END AS accepeted_status, 
                      dbo.T0090_EMP_HR_DOC_Detail.Login_id, T0010_COMPANY_MASTER_1.Domain_Name, CASE WHEN isnull(login_name, '') 
                      = '' THEN 'Auto Generated' ELSE replace(login_name, T0010_COMPANY_MASTER_1.domain_name, '') END AS login_name, 
                      dbo.T0010_COMPANY_MASTER.Image_name, dbo.T0010_COMPANY_MASTER.Cmp_Name, ISNULL(dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 'All') 
                      AS Dept_Name, ISNULL(dbo.T0040_DESIGNATION_MASTER.Desig_Name, 'All') AS Desig_Name, ISNULL(dbo.T0030_BRANCH_MASTER.Branch_Name, 'All') 
                      AS Branch_Name, ISNULL(dbo.T0040_GRADE_MASTER.Grd_Name, 'All') AS Grd_Name, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Gender, dbo.T0080_EMP_MASTER.Emp_Full_Name, ISNULL(CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(50)) 
                      + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name, 'All') AS emp_full_name_new, ISNULL(dbo.T0090_EMP_HR_DOC_Detail.Type, 0) AS type,Alpha_Emp_Code
FROM         dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_1 WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON T0010_COMPANY_MASTER_1.Cmp_Id = dbo.T0011_LOGIN.Cmp_ID RIGHT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER  WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0090_EMP_HR_DOC_Detail WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0040_GRADE_MASTER  WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID ON 
                      dbo.T0040_GRADE_MASTER.Grd_ID = dbo.T0095_INCREMENT.Grd_ID ON 
                      dbo.T0030_BRANCH_MASTER.Branch_ID = dbo.T0095_INCREMENT.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id ON 
                      dbo.T0090_EMP_HR_DOC_Detail.Emp_id = dbo.T0080_EMP_MASTER.Emp_ID ON 
                      dbo.T0010_COMPANY_MASTER.Cmp_Id = dbo.T0090_EMP_HR_DOC_Detail.cmp_id LEFT OUTER JOIN
                      dbo.T0040_HR_DOC_MASTER WITH (NOLOCK)  ON dbo.T0090_EMP_HR_DOC_Detail.HR_DOC_ID = dbo.T0040_HR_DOC_MASTER.HR_DOC_ID ON 
                      dbo.T0011_LOGIN.Login_ID = dbo.T0090_EMP_HR_DOC_Detail.Login_id
WHERE     (ISNULL(dbo.T0090_EMP_HR_DOC_Detail.Type, 0) = 0)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[18] 4[12] 2[8] 3) )"
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
         Begin Table = "T0010_COMPANY_MASTER_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0011_LOGIN"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0090_EMP_HR_DOC_Detail"
            Begin Extent = 
               Top = 126
               Left = 254
               Bottom = 245
               Right = 415
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 605
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 606
               Left = 38
               Bottom = 725', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_HR_DOC_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 726
               Left = 38
               Bottom = 845
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 366
               Left = 271
               Bottom = 485
               Right = 452
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 6
               Left = 317
               Bottom = 125
               Right = 477
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_HR_DOC_MASTER"
            Begin Extent = 
               Top = 486
               Left = 287
               Bottom = 605
               Right = 457
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
      Begin ColumnWidths = 29
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
         Width = 2235
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_HR_DOC_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_HR_DOC_Detail';

