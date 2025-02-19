





CREATE VIEW [dbo].[V0090_EMP_PRIVILEGE_DETAILS]
AS
SELECT     TOP (100) PERCENT ISNULL(CONVERT(NVARCHAR, PD.From_Date, 103), '-') AS FROM_DATE, ISNULL(CONVERT(NVARCHAR, PD.Privilege_Id), '-') AS PRIVILEGE_ID, 
                      LO.Cmp_ID, LO.Login_ID, EMP.Emp_Full_Name, EMP.Alpha_Emp_Code, ISNULL(PM.Privilege_Name, '-') AS PRIVILEGE_NAME, CASE CONVERT(NVARCHAR, 
                      PM.PRIVILEGE_TYPE) WHEN '0' THEN 'ADMIN USER' WHEN '1' THEN 'ESS USER' ELSE '-' END AS PRIVILEGE_TYPE, INC.Branch_ID, INC.Grd_ID, INC.Desig_Id, 
                      ISNULL(INC.Dept_ID, 0) AS Dept_ID, ISNULL(PD.Trans_Id, 0) AS Trans_Id, EMP.Emp_ID, INC.Vertical_ID, INC.SubVertical_ID,
					  INC.Cat_ID,INC.Segment_ID,INC.subBranch_ID,INC.Band_Id,INC.Type_ID,INC.SalDate_id,
					  PD.From_Date AS Effective_Date, 
                      EMP.Emp_First_Name
FROM         dbo.T0090_EMP_PRIVILEGE_DETAILS AS PD WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN AS LO  WITH (NOLOCK) ON LO.Login_ID = PD.Login_Id INNER JOIN
                      dbo.T0080_EMP_MASTER AS EMP  WITH (NOLOCK) ON EMP.Emp_ID = LO.Emp_ID LEFT OUTER JOIN
                      dbo.T0020_PRIVILEGE_MASTER AS PM  WITH (NOLOCK) ON PM.Privilege_ID = PD.Privilege_Id left JOIN
                      dbo.T0095_INCREMENT AS INC  WITH (NOLOCK) ON INC.Increment_ID = EMP.Increment_ID
WHERE     (EMP.Emp_Left = 'N')
ORDER BY EMP.Alpha_Emp_Code, Effective_Date


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
         Begin Table = "PD"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LO"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 387
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EMP"
            Begin Extent = 
               Top = 6
               Left = 425
               Bottom = 121
               Right = 642
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PM"
            Begin Extent = 
               Top = 6
               Left = 680
               Bottom = 121
               Right = 834
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
      Begin ColumnWidths = 14
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
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 3390
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_PRIVILEGE_DETAILS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_PRIVILEGE_DETAILS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_PRIVILEGE_DETAILS';

