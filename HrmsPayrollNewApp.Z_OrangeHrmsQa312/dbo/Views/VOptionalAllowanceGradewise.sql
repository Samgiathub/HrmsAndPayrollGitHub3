



CREATE VIEW [dbo].[VOptionalAllowanceGradewise]
AS
SELECT     GA.Tran_ID, GA.cmp_id, GA.Ad_ID, GA.Grd_ID, GA.Sys_Date, GA.AD_Level, GA.AD_MODE, GA.AD_PERCENTAGE, GA.AD_AMOUNT, GA.AD_MAX_LIMIT, 
                      GA.AD_NON_TAX_LIMIT, ISNULL(GA.AD_MAX_LIMIT, 0.0) AS AD_MAX_LIMIT_NotNull, AD.AD_NAME, AD.AD_FLAG, AD.AD_SORT_NAME, ISNULL(AD.Is_Optional, 0) 
                      AS Is_Optional, ISNULL(dbo.T0040_GRADE_MASTER.Eligibility_Amount, 0) AS Eligibility_Amount, dbo.V0080_Employee_Master.Emp_Full_Name_new, 
                      dbo.V0080_Employee_Master.Emp_ID, AD.AD_CALCULATE_ON, ISNULL(AD.AD_Code, '') AS AD_Code, ISNULL(AD.Allowance_Type, '') AS Allowance_Type
FROM         dbo.T0120_GRADEWISE_ALLOWANCE AS GA WITH (NOLOCK) INNER JOIN
                      dbo.T0050_AD_MASTER AS AD WITH (NOLOCK)  ON AD.AD_ID = GA.Ad_ID INNER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON GA.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID INNER JOIN
                      dbo.V0080_Employee_Master WITH (NOLOCK)  ON dbo.T0040_GRADE_MASTER.Grd_ID = dbo.V0080_Employee_Master.Grd_ID
                      
                      
--SELECT * FROM V0080_Employee_Master 





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[51] 4[5] 3[18] 2) )"
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
         Begin Table = "GA"
            Begin Extent = 
               Top = 0
               Left = 355
               Bottom = 262
               Right = 544
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AD"
            Begin Extent = 
               Top = 6
               Left = 43
               Bottom = 263
               Right = 296
            End
            DisplayFlags = 280
            TopColumn = 32
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 582
               Bottom = 125
               Right = 765
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "V0080_Employee_Master"
            Begin Extent = 
               Top = 0
               Left = 649
               Bottom = 236
               Right = 874
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
      Begin ColumnWidths = 23
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2025
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1020
         Width = 1035
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
      Begin C', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VOptionalAllowanceGradewise';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'olumnWidths = 11
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
         Or = 1395
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VOptionalAllowanceGradewise';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VOptionalAllowanceGradewise';

