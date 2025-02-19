


CREATE VIEW [dbo].[V0090_Emp_License_Detail_Get]
AS
SELECT     dbo.T0040_LICENSE_MASTER.Lic_Name, dbo.T0090_EMP_LICENSE_DETAIL.Row_ID, dbo.T0090_EMP_LICENSE_DETAIL.Emp_ID, 
                      dbo.T0090_EMP_LICENSE_DETAIL.Cmp_ID, dbo.T0090_EMP_LICENSE_DETAIL.LIC_ID, dbo.T0090_EMP_LICENSE_DETAIL.Lic_St_Date, 
                      CASE WHEN T0090_EMP_LICENSE_DETAIL.Lic_End_Date = '01/01/1900' THEN '' ELSE CONVERT(varchar(11), dbo.T0090_EMP_LICENSE_DETAIL.Lic_End_Date, 103) 
                      END AS Lic_End_Date, dbo.T0090_EMP_LICENSE_DETAIL.Lic_Comments, dbo.T0090_EMP_LICENSE_DETAIL.Lic_For, 
                      dbo.T0090_EMP_LICENSE_DETAIL.Lic_Number, dbo.T0090_EMP_LICENSE_DETAIL.Is_Expired
FROM         dbo.T0040_LICENSE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0090_EMP_LICENSE_DETAIL WITH (NOLOCK)  ON dbo.T0040_LICENSE_MASTER.Lic_ID = dbo.T0090_EMP_LICENSE_DETAIL.LIC_ID


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
         Begin Table = "T0040_LICENSE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0090_EMP_LICENSE_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 380
            End
            DisplayFlags = 280
            TopColumn = 6
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Emp_License_Detail_Get';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Emp_License_Detail_Get';

