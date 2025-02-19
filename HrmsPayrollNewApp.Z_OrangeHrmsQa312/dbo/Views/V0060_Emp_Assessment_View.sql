



--------------------------

CREATE VIEW [dbo].[V0060_Emp_Assessment_View]
AS
SELECT     dbo.T0060_Emp_Assessment_View.Emp_AssessmentView_Id, ISNULL(dbo.T0060_Emp_Assessment_View.SA_View, 1) AS SA_View, I.Branch_ID, 
                      ISNULL(dbo.T0060_Emp_Assessment_View.KPA_View, 1) AS KPA_View, dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '-' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS emp_name, 
                      dbo.T0080_EMP_MASTER.Cmp_ID, DG.Desig_Name, D.Dept_Name, ISNULL(dbo.T0060_Emp_Assessment_View.Effective_Date,
                          (SELECT     From_Date
                            FROM          dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      (Cmp_Id = dbo.T0060_Emp_Assessment_View.Cmp_Id))) AS Effective_Date
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0060_Emp_Assessment_View WITH (NOLOCK) ON dbo.T0060_Emp_Assessment_View.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON I.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND I.Increment_ID =
                          (SELECT     MAX(Increment_ID) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK)
                            WHERE      (Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID)) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
WHERE     (dbo.T0080_EMP_MASTER.Emp_Left <> 'Y')




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'egin ColumnWidths = 11
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_Emp_Assessment_View';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_Emp_Assessment_View';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0060_Emp_Assessment_View"
            Begin Extent = 
               Top = 6
               Left = 320
               Bottom = 125
               Right = 530
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 6
               Left = 568
               Bottom = 125
               Right = 810
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DG"
            Begin Extent = 
               Top = 6
               Left = 848
               Bottom = 125
               Right = 1029
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 1067
               Bottom = 125
               Right = 1245
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
      Begin ColumnWidths = 12
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
      End
   End
   Begin CriteriaPane = 
      B', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_Emp_Assessment_View';

