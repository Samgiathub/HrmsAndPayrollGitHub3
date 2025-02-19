
CREATE VIEW [dbo].[V0190_TAX_PLANNING]
AS
SELECT     TP.Emp_Id, TP.Cmp_ID, EM.Emp_Full_Name, EM.Emp_code AS Emp_Code1, EM.Alpha_Emp_Code, TP.From_Date, TP.To_Date, TP.For_Date, TP.Taxable_Amount, 
                      TP.IT_Y_Final_Amount, TP.IT_M_Final_Amount, TP.Is_Repeat, TP.Tran_ID, EM.Emp_First_Name, I.Branch_ID, EM.Alpha_Emp_Code AS Emp_Code, EM.Dept_ID, 
                      EM.Desig_Id, I.SalDate_id, I.Vertical_ID, I.SubVertical_ID, I.subBranch_ID, I.Segment_ID, TP.IT_Declaration_Calc_On
                      ,case when ITR.Regime is null or ITR.Regime = '' then '' 
							WHEN ITR.Regime = 'Tax Regime 1' then 'Old Regime'
							WHEN ITR.Regime = 'Tax Regime 2' then 'New Regime'
							end as Regime,
                      case when ITR.Regime is null or ITR.Regime = '' THEN
							'clsinactive1'
						when ITR.Regime = 'Tax Regime 1'  then 
							 'clsinactive'
						else
							 'clsactive'
					end  as Activeclass
FROM         dbo.T0190_TAX_PLANNING AS TP WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK)  ON TP.Emp_Id = I.Emp_ID INNER JOIN
                          (SELECT     MAX(Increment_ID) AS Increment_Id, Emp_ID
                            FROM          dbo.T0095_INCREMENT AS IM WITH (NOLOCK) 
                            WHERE      (Increment_Effective_Date <=
                                                       (SELECT     MAX(To_Date) AS Expr1
                                                         FROM          dbo.T0190_TAX_PLANNING WITH (NOLOCK) 
                                                         WHERE      (Cmp_ID = IM.Cmp_ID) AND (Emp_Id = IM.Emp_ID)))
                            GROUP BY Emp_ID) AS Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_Id INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = Qry.Emp_ID
             left outer join T0095_IT_Emp_Tax_Regime as ITR WITH (NOLOCK)  on EM.Emp_ID = ITR.Emp_ID and year(TP.From_Date) = left(ITR.Financial_Year,4) and year(TP.To_Date) = right(itr.Financial_Year,4)



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[5] 2[53] 3) )"
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
         Begin Table = "TP"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 256
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 78
               Left = 645
               Bottom = 197
               Right = 887
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qry"
            Begin Extent = 
               Top = 6
               Left = 294
               Bottom = 95
               Right = 454
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_TAX_PLANNING';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0190_TAX_PLANNING';

