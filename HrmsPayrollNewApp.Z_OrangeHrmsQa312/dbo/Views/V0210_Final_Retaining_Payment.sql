CREATE VIEW dbo.V0210_Final_Retaining_Payment
AS
SELECT     ES.Tran_Id, ES.For_Date, ES.Cmp_Id, ES.Emp_Id, ES.Hours, ES.Comp_Esic AS Amount, ES.Retain_Amount, ES.Esic, ES.Net_Amount, ES.Ad_Id, ES.Modify_Date, ES.Comp_Esic, ES.TDS, ES.PF, ES.Working_Days, ES.Calculate_on, EM.Alpha_Emp_Code, EM.Emp_Full_Name, Am.AD_NAME, 
                  Am.AD_NOT_EFFECT_SALARY, I_1.Branch_ID, I_1.Grd_ID, I_1.Desig_Id, I_1.Dept_ID, I_1.Vertical_ID, I_1.SubVertical_ID, I_1.Segment_ID, BM.Branch_Name, Am.Hide_In_Reports, I_1.Cat_ID, I_1.Type_ID, I_1.subBranch_ID, GM.Grd_Name, DEM.Desig_Name, CM.Cmp_Name, 
                  DM.Dept_Name, BAM.Bank_Name, I_1.Inc_Bank_AC_No, TM.Type_Name, I_1.Basic_Salary AS Rate, ES.Ret_Tran_id, ES.VPF, ES.CPF
FROM        dbo.T0210_Final_Retaining_Payment AS ES WITH (NOLOCK) INNER JOIN
                  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON ES.Emp_Id = EM.Emp_ID INNER JOIN
                  dbo.T0050_AD_MASTER AS Am WITH (NOLOCK) ON ES.Ad_Id = Am.AD_ID INNER JOIN
                      (SELECT     I.Cmp_ID, I.Basic_Salary, I.Bank_ID, I.Inc_Bank_AC_No, I.Branch_ID, I.Increment_ID, I.Emp_ID, I.Grd_ID, I.Desig_Id, I.Dept_ID, I.Vertical_ID, I.SubVertical_ID, I.Segment_ID, I.Cat_ID, I.Type_ID, I.subBranch_ID
                       FROM        dbo.T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN
                                             (SELECT     MAX(TI.Increment_ID) AS Increment_Id, TI.Emp_ID
                                              FROM        dbo.T0095_INCREMENT AS TI WITH (NOLOCK) INNER JOIN
                                                                    (SELECT     MAX(Increment_Effective_Date) AS Increment_Effective_Date, Emp_ID
                                                                     FROM        dbo.T0095_INCREMENT WITH (NOLOCK)
                                                                     WHERE     (Increment_Effective_Date <= GETDATE())
                                                                     GROUP BY Emp_ID) AS new_inc ON TI.Emp_ID = new_inc.Emp_ID AND TI.Increment_Effective_Date = new_inc.Increment_Effective_Date
                                              WHERE     (TI.Increment_Effective_Date <= GETDATE())
                                              GROUP BY TI.Emp_ID) AS Qry ON I.Increment_ID = Qry.Increment_Id) AS I_1 ON EM.Emp_ID = I_1.Emp_ID INNER JOIN
                  dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON I_1.Branch_ID = BM.Branch_ID INNER JOIN
                  dbo.T0040_GRADE_MASTER AS GM WITH (NOLOCK) ON I_1.Grd_ID = GM.Grd_ID INNER JOIN
                  dbo.T0040_DESIGNATION_MASTER AS DEM WITH (NOLOCK) ON I_1.Desig_Id = DEM.Desig_ID INNER JOIN
                  dbo.T0010_COMPANY_MASTER AS CM WITH (NOLOCK) ON I_1.Cmp_ID = CM.Cmp_Id LEFT OUTER JOIN
                  dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK) ON I_1.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
                  dbo.T0040_BANK_MASTER AS BAM WITH (NOLOCK) ON I_1.Bank_ID = BAM.Bank_ID LEFT OUTER JOIN
                  dbo.T0040_TYPE_MASTER AS TM WITH (NOLOCK) ON I_1.Type_ID = TM.Type_ID

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'     End
         Begin Table = "CM"
            Begin Extent = 
               Top = 1183
               Left = 48
               Bottom = 1346
               Right = 375
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DM"
            Begin Extent = 
               Top = 1351
               Left = 48
               Bottom = 1514
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BAM"
            Begin Extent = 
               Top = 1519
               Left = 48
               Bottom = 1682
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TM"
            Begin Extent = 
               Top = 1687
               Left = 48
               Bottom = 1850
               Right = 260
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0210_Final_Retaining_Payment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0210_Final_Retaining_Payment';


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
         Begin Table = "ES"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 375
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Am"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 376
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I_1"
            Begin Extent = 
               Top = 7
               Left = 292
               Bottom = 170
               Right = 495
            End
            DisplayFlags = 280
            TopColumn = 12
         End
         Begin Table = "BM"
            Begin Extent = 
               Top = 679
               Left = 48
               Bottom = 842
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "GM"
            Begin Extent = 
               Top = 847
               Left = 48
               Bottom = 1010
               Right = 318
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DEM"
            Begin Extent = 
               Top = 1015
               Left = 48
               Bottom = 1178
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
    ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0210_Final_Retaining_Payment';

