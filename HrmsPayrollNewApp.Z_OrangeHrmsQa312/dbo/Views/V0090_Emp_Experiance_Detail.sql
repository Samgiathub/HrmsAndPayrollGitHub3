



CREATE VIEW [dbo].[V0090_Emp_Experiance_Detail]
AS
SELECT     dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, Convert(varchar(25),dbo.T0080_EMP_MASTER.Date_Of_Join,103) as Date_of_Join  , 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0090_EMP_EXPERIENCE_DETAIL.Employer_Name, dbo.T0090_EMP_EXPERIENCE_DETAIL.Desig_Name, 
                      CONVERT(VARCHAR(25),T0090_EMP_EXPERIENCE_DETAIL.St_Date,103) AS St_Date, CONVERT(VARCHAR(25),T0090_EMP_EXPERIENCE_DETAIL.End_Date,103) AS End_Date, dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Cmp_ID, dbo.T0080_EMP_MASTER.Branch_ID, 
                      dbo.T0090_EMP_EXPERIENCE_DETAIL.Emp_Branch AS Branch, dbo.T0090_EMP_EXPERIENCE_DETAIL.Emp_Location AS Location, 
                      dbo.T0090_EMP_EXPERIENCE_DETAIL.Manager_Name AS Manager, dbo.T0090_EMP_EXPERIENCE_DETAIL.Contact_number AS Manager_Contact_Number, 
                      dbo.T0090_EMP_EXPERIENCE_DETAIL.Exp_Remarks, dbo.T0090_EMP_EXPERIENCE_DETAIL.Gross_Salary, 
                      dbo.T0090_EMP_EXPERIENCE_DETAIL.CTC_Amount,dbo.T0090_EMP_EXPERIENCE_DETAIL.EmpExp
FROM         dbo.T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0090_EMP_EXPERIENCE_DETAIL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[57] 4[5] 2[21] 3) )"
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
         Begin Table = "T0090_EMP_EXPERIENCE_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 311
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 234
               Bottom = 121
               Right = 451
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 489
               Bottom = 121
               Right = 648
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Emp_Experiance_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Emp_Experiance_Detail';

