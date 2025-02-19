CREATE VIEW dbo.V0190_MONTHLY_AD_DETAIL_IMPORT
AS
SELECT     dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Tran_ID, dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Emp_ID, dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.AD_ID, dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Month, dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Year, 
                  dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.For_Date, dbo.T0050_AD_MASTER.AD_SORT_NAME, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, dbo.T0050_AD_MASTER.CMP_ID, dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Amount, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                  dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0080_EMP_MASTER.Vertical_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Increment_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0050_AD_MASTER.Hide_In_Reports, 
                  dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Comments, dbo.T0080_EMP_MASTER.Emp_Left
FROM        dbo.T0050_AD_MASTER WITH (NOLOCK) INNER JOIN
                  dbo.T0190_MONTHLY_AD_DETAIL_IMPORT WITH (NOLOCK) ON dbo.T0050_AD_MASTER.AD_ID = dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.AD_ID INNER JOIN
                  dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0190_MONTHLY_AD_DETAIL_IMPORT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                  dbo.T0095_INCREMENT WITH (NOLOCK) ON dbo.T0095_INCREMENT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      (SELECT     MAX(I.Increment_ID) AS INCREMENT_ID, I.Emp_ID
                       FROM        dbo.T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN
                                             (SELECT     MAX(Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, Emp_ID
                                              FROM        dbo.T0095_INCREMENT AS I3 WITH (NOLOCK)
                                              WHERE     (Increment_Effective_Date <= GETDATE())
                                              GROUP BY Emp_ID) AS I3_1 ON I.Increment_Effective_Date = I3_1.INCREMENT_EFFECTIVE_DATE AND I.Emp_ID = I3_1.Emp_ID
                       WHERE     (I.Increment_Effective_Date <= GETDATE())
                       GROUP BY I.Emp_ID) AS Qry ON dbo.T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND dbo.T0095_INCREMENT.Increment_ID = Qry.INCREMENT_ID INNER JOIN
                  dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON dbo.T0095_INCREMENT.Branch_ID = BM.Branch_ID AND ISNULL(BM.InActive_EffeDate, GETDATE() + 1) > GETDATE()

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' = 1500
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
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_MONTHLY_AD_DETAIL_IMPORT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_MONTHLY_AD_DETAIL_IMPORT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[56] 4[5] 2[20] 3) )"
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
         Begin Table = "T0050_AD_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 291
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0190_MONTHLY_AD_DETAIL_IMPORT"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 236
               Bottom = 245
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 77
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 245
               Left = 48
               Bottom = 408
               Right = 348
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BM"
            Begin Extent = 
               Top = 532
               Left = 48
               Bottom = 695
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qry"
            Begin Extent = 
               Top = 7
               Left = 339
               Bottom = 126
               Right = 536
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
         Width', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_MONTHLY_AD_DETAIL_IMPORT';

