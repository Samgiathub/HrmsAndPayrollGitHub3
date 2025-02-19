CREATE VIEW dbo.V0140_ADVANCE_SUMMARY
AS
SELECT     T.Emp_ID, EM.Cmp_ID, EM.Alpha_Emp_Code, EM.Emp_Full_Name, BM.Branch_Name, GM.Grd_Name AS Grade, DM.Dept_Name AS Department, DSM.Desig_Name AS Designation, VS.Vertical_Name, SV.SubVertical_Name, BS.Segment_Name AS Business_Segment, EM.Mobile_No, 
                  T.Adv_Closing AS Advance_Till_Date, T.For_Date AS Advance_Approved_Date, I1.Branch_ID, I1.Vertical_ID
FROM        dbo.T0140_ADVANCE_TRANSACTION AS T WITH (NOLOCK) INNER JOIN
                      (SELECT     MAX(For_Date) AS FOR_DATE, Emp_ID
                       FROM        dbo.T0140_ADVANCE_TRANSACTION WITH (NOLOCK)
                       GROUP BY Emp_ID) AS QRYAD ON QRYAD.Emp_ID = T.Emp_ID AND QRYAD.FOR_DATE = T.For_Date INNER JOIN
                  dbo.T0095_INCREMENT AS I1 WITH (NOLOCK) ON I1.Emp_ID = T.Emp_ID INNER JOIN
                      (SELECT     MAX(Increment_ID) AS INCREMENT_ID, Emp_ID
                       FROM        dbo.T0095_INCREMENT WITH (NOLOCK)
                       WHERE     (Increment_Effective_Date <= GETDATE())
                       GROUP BY Emp_ID) AS QRYINC ON QRYINC.INCREMENT_ID = I1.Increment_ID AND QRYINC.Emp_ID = I1.Emp_ID INNER JOIN
                  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EM.Emp_ID = T.Emp_ID AND EM.Emp_Left <> 'Y' INNER JOIN
                  dbo.T0040_GRADE_MASTER AS GM WITH (NOLOCK) ON GM.Grd_ID = I1.Grd_ID INNER JOIN
                  dbo.T0040_DESIGNATION_MASTER AS DSM WITH (NOLOCK) ON DSM.Desig_ID = I1.Desig_Id INNER JOIN
                  dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON BM.Branch_ID = I1.Branch_ID LEFT OUTER JOIN
                  dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK) ON DM.Dept_Id = I1.Dept_ID LEFT OUTER JOIN
                  dbo.T0040_Vertical_Segment AS VS WITH (NOLOCK) ON VS.Vertical_ID = I1.Vertical_ID LEFT OUTER JOIN
                  dbo.T0050_SubVertical AS SV WITH (NOLOCK) ON SV.SubVertical_ID = I1.SubVertical_ID LEFT OUTER JOIN
                  dbo.T0040_Business_Segment AS BS WITH (NOLOCK) ON BS.Segment_ID = I1.Segment_ID
WHERE     (T.Adv_Closing > 0)

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         End
         Begin Table = "VS"
            Begin Extent = 
               Top = 1421
               Left = 48
               Bottom = 1584
               Right = 275
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "SV"
            Begin Extent = 
               Top = 1589
               Left = 48
               Bottom = 1752
               Right = 300
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BS"
            Begin Extent = 
               Top = 1757
               Left = 48
               Bottom = 1920
               Right = 284
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "QRYAD"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 126
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "QRYINC"
            Begin Extent = 
               Top = 7
               Left = 532
               Bottom = 126
               Right = 729
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_ADVANCE_SUMMARY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_ADVANCE_SUMMARY';


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
         Top = -1320
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I1"
            Begin Extent = 
               Top = 294
               Left = 48
               Bottom = 457
               Right = 348
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 581
               Left = 48
               Bottom = 744
               Right = 375
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "GM"
            Begin Extent = 
               Top = 749
               Left = 48
               Bottom = 912
               Right = 318
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DSM"
            Begin Extent = 
               Top = 917
               Left = 48
               Bottom = 1080
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BM"
            Begin Extent = 
               Top = 1085
               Left = 48
               Bottom = 1248
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DM"
            Begin Extent = 
               Top = 1253
               Left = 48
               Bottom = 1416
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 6
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_ADVANCE_SUMMARY';

