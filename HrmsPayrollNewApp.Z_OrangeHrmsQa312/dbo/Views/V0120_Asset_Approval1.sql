





CREATE VIEW [dbo].[V0120_Asset_Approval1]
AS
SELECT     *, LEFT(Asset_Name1, len(Asset_Name1) - 1) AS Asset_Name
FROM         (SELECT     AA.Asset_Approval_Date, ab.Application_status, aa.Asset_Application_ID AS Application_Code, aa.Asset_Application_ID, aa.Cmp_ID, aa.Asset_Approval_ID, 
                                              e.Emp_ID, aa.Branch_ID, mm.Branch_ID AS emp_branch, E.Emp_Full_Name, CASE WHEN aa.Status = 'A' THEN 'Approved' ELSE 'Rejected' END AS [status],
                                               e.Emp_First_Name, CASE WHEN ab.Asset_Application_ID <> 0 AND AB.Application_Type = 0 THEN 'Application' WHEN ab.Asset_Application_ID <> 0 AND 
                                              ab.Application_Type = 1 THEN 'Return' ELSE 'Application' END AS [Application_Type], E.Alpha_Emp_Code AS Emp_code, 
                                              CASE WHEN AA.Receiver_ID = 0 THEN 'Admin' ELSE EE.Emp_Full_Name END AS Approved_By, B.Branch_Name, D .Dept_Name, 
                                              CASE WHEN E1.Alpha_Emp_Code IS NULL THEN 'Admin' ELSE (E1.Alpha_Emp_Code + '-' + E1.Emp_Full_Name) END AS Applied_By_Name,
                                                  (SELECT     Asset_Name + ','
                                                    FROM          T0040_ASSET_MASTER WITH (NOLOCK)
                                                    WHERE      Asset_ID IN
                                                                               (SELECT     Asset_ID
                                                                                 FROM          T0130_Asset_Approval_Det WITH (NOLOCK)
                                                                                 WHERE      Asset_Approval_ID = aa.Asset_Approval_ID) FOR xml path('')) AS Asset_Name1
                       FROM          T0120_Asset_Approval AA WITH (NOLOCK) LEFT OUTER JOIN
                                              dbo.T0100_Asset_Application AB WITH (NOLOCK) ON AA.Asset_Application_ID = AB.Asset_Application_ID AND AA.Cmp_ID = AB.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0080_EMP_MASTER EE WITH (NOLOCK) ON AA.Receiver_ID = EE.Emp_ID AND EE.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON AA.Emp_ID = E.Emp_ID AND E.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0080_EMP_MASTER E1 WITH (NOLOCK) ON AA.Applied_By = E1.Emp_ID AND E1.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.t0040_department_master D WITH (NOLOCK) ON AA.Dept_ID = D .Dept_ID AND D .Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON AA.Branch_ID = B.Branch_ID AND B.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                                  (SELECT     I.emp_id, I.branch_id, i.Cmp_ID
                                                    FROM          dbo.T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
                                                                           dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = I.Emp_ID
                                                    WHERE      I.INCREMENT_id IN
                                                                               (SELECT     MAX(INCREMENT_ID)
                                                                                 FROM          dbo.T0095_INCREMENT WITH (NOLOCK)
                                                                                 GROUP BY EMP_ID)) mm ON e.Emp_ID = mm.Emp_ID AND e.Cmp_ID = mm.Cmp_ID) src





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[6] 2[34] 3) )"
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
      Begin ColumnWidths = 21
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1875
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Asset_Approval1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Asset_Approval1';

