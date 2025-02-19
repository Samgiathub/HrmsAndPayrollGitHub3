


CREATE VIEW [dbo].[V0180_BONUS]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0180_BONUS.From_Date, dbo.T0180_BONUS.To_Date,					  
					  CASE WHEN Bonus_Cal_Type is null then dbo.T0180_BONUS.Bonus_Calculated_On else dbo.T0180_BONUS.Bonus_Calculated_On + ' - ' + Bonus_Cal_Type end as Bonus_Calculated_On,
					  CASE WHEN Bonus_Cal_Type is null then dbo.T0180_BONUS.Bonus_Amount else Isnull(dbo.T0180_BONUS.Bonus_Amount,0) +  Isnull(Ex_Gratia_Bonus_Amount,0) end as Bonus_Amount, 
                      dbo.T0180_BONUS.Bonus_ID, dbo.T0180_BONUS.Emp_ID, dbo.T0180_BONUS.Bonus_Calculated_Amount, dbo.T0180_BONUS.Bonus_Percentage, 
                      dbo.T0180_BONUS.Bonus_Fix_Amount, dbo.T0180_BONUS.Bonus_Comments, dbo.T0180_BONUS.Bonus_Effect_Year, dbo.T0180_BONUS.Bonus_Effect_Month, 
                      dbo.T0180_BONUS.Bonus_Effect_on_Sal, dbo.T0180_BONUS.Cmp_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS Emp_code, 
                      I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Cat_ID, 
                      I.Grd_ID, I.Desig_Id, I.Type_ID, I.Branch_ID,Bonus_Cal_Type,
					  dbo.T0180_BONUS.Bonus_Calculated_On as Bonus_Calculated_On1
FROM    dbo.T0180_BONUS WITH (NOLOCK)
		LEFT OUTER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0180_BONUS.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID 
		INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = I.Emp_ID		
		INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
					FROM	T0095_INCREMENT I2 WITH (NOLOCK)
							INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
										FROM	T0095_INCREMENT I3  WITH (NOLOCK)
										WHERE	I3.Increment_Effective_Date <= GETDATE()
										GROUP BY I3.Emp_ID
										) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
					GROUP BY I2.Emp_ID
					) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID	
		INNER JOIN dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON I.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID
		




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
         Begin Table = "T0180_BONUS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 25
               Left = 468
               Bottom = 144
               Right = 710
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 233
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0180_BONUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0180_BONUS';

