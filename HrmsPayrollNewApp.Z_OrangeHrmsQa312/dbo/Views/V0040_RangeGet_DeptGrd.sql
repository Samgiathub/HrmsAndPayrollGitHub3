



----------------------
CREATE VIEW [dbo].[V0040_RangeGet_DeptGrd]
AS
SELECT DISTINCT 
                      (dbo.t0040_hrms_rangemaster.Range_PID), dbo.t0040_hrms_rangemaster.Range_Type, dbo.t0040_hrms_rangemaster.cmp_id, 
                      dbo.t0040_hrms_rangemaster.Range_Grade, dbo.t0040_hrms_rangemaster.Range_Dept, CASE WHEN dbo.t0040_hrms_rangemaster.Range_Grade IS NOT NULL 
                      THEN
                          (SELECT     bm1.Grd_Name + ', '
                            FROM          t0040_grade_master BM1 WITH (NOLOCK)
                            WHERE      Grd_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(isnull(dbo.t0040_hrms_rangemaster.Range_Grade, '0'), '#')
                                                         WHERE      data <> '') FOR xml path('')) ELSE 'ALL' END AS Grade_Name, CASE WHEN dbo.t0040_hrms_rangemaster.Range_Dept IS NOT NULL 
                      THEN
                          (SELECT     d .Dept_Name + ', '
                            FROM          T0040_DEPARTMENT_MASTER d WITH (NOLOCK)
                            WHERE      Dept_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(isnull(dbo.t0040_hrms_rangemaster.Range_Dept, '0'), '#')
                                                         WHERE      data <> '') FOR xml path('')) ELSE 'ALL' END AS Dept_Name,
                    ISNULL(dbo.t0040_hrms_rangemaster.Effective_Date,
                          (SELECT     From_Date
                            FROM          dbo.T0010_COMPANY_MASTER WITH (NOLOCK)
                            WHERE      (Cmp_Id = dbo.t0040_hrms_rangemaster.Cmp_Id))) AS Effective_Date
FROM         dbo.t0040_hrms_rangemaster WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.t0040_grade_master WITH (NOLOCK) ON dbo.t0040_hrms_rangemaster.Cmp_Id = dbo.t0040_grade_master.Cmp_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0040_HRMS_RangeMaster.Cmp_ID = dbo.T0040_DEPARTMENT_MASTER.Cmp_Id




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[16] 2[25] 3) )"
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
         Width = 1755
         Width = 2160
         Width = 2985
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_RangeGet_DeptGrd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_RangeGet_DeptGrd';

