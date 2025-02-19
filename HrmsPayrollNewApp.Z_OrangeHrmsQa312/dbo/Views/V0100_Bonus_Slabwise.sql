





CREATE VIEW [dbo].[V0100_Bonus_Slabwise]
AS
SELECT DISTINCT 
                      isb.Gross_Salary, isb.Eligible_Day, em.Emp_Full_Name, isb.Cmp_ID, isb.Emp_ID, isb.Working_Days, em.Alpha_Emp_Code, isb.Tran_ID, mm.Branch_ID, 
                      mm.Vertical_ID, mm.SubVertical_ID, mm.Dept_ID, mm.Type_ID, mm.Grd_ID, mm.Cat_ID, mm.Desig_Id, mm.Segment_ID, mm.subBranch_ID, em.Emp_First_Name, 
                      isb.From_date, isb.To_date, isb.Bonus_Comments, isb.Bonus_Effect_Year, isb.Bonus_Effect_Month, isb.Bonus_Effect_on_Sal, isb.For_date, 
                      isb.Total_Bonus_Amount, isb.Additional_Amount, isb.Bonus_Amount, isb.Paid_Day, isb.Leave_Slab,isb.Extra_Paid_Days,
                      BM.Branch_Name,DM.Dept_Name,'="' + Replace(Convert(Varchar(11),em.Date_of_join,104),'.','/') + '"' as Date_Of_Join,
                      mm.Payment_Mode,'="' + mm.Inc_Bank_AC_No + '"' as Inc_Bank_AC_No,BBM.Bank_Name
FROM         dbo.T0100_Bonus_Slabwise AS isb WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS em WITH (NOLOCK)  ON isb.Emp_ID = em.Emp_ID AND isb.Cmp_ID = em.Cmp_ID 
                      LEFT OUTER JOIN
                          (
							SELECT  I.Emp_ID, I.Branch_ID, I.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, 
								    I.Grd_ID, I.Cat_ID, I.Desig_Id, I.Segment_ID, I.subBranch_ID,I.Bank_ID,I.Payment_Mode,I.Inc_Bank_AC_No
                            FROM    dbo.T0095_INCREMENT AS I WITH (NOLOCK)  INNER JOIN
                                    dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON E.Emp_ID = I.Emp_ID
                            WHERE   (I.Increment_ID IN(
														 SELECT     MAX(Increment_ID) AS Expr1
                                                         FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                                                         GROUP BY Emp_ID
                                                       )
                                     )
                          ) AS mm ON em.Emp_ID = mm.Emp_ID AND em.Cmp_ID = mm.Cmp_ID
                     Inner JOIN T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON BM.Branch_ID = mm.Branch_ID
					 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON DM.Dept_Id = mm.Dept_ID
					 Left Outer JOIN T0040_BANK_MASTER BBM WITH (NOLOCK)  ON BBM.Bank_ID = mm.Bank_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[46] 4[5] 2[31] 3) )"
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
         Begin Table = "isb"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "em"
            Begin Extent = 
               Top = 6
               Left = 267
               Bottom = 125
               Right = 511
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mm"
            Begin Extent = 
               Top = 6
               Left = 549
               Bottom = 125
               Right = 709
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
      Begin ColumnWidths = 22
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
         Or ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Bonus_Slabwise';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'= 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Bonus_Slabwise';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Bonus_Slabwise';

