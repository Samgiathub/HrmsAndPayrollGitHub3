



CREATE VIEW [dbo].[V0100_AR_ApplicationDetail]
AS
SELECT     dbo.T0100_AR_ApplicationDetail.AR_AppDetail_ID, dbo.T0100_AR_ApplicationDetail.AD_ID, dbo.T0100_AR_ApplicationDetail.AD_Flag, 
                      dbo.T0100_AR_ApplicationDetail.AD_Mode, dbo.T0100_AR_ApplicationDetail.AD_Percentage, dbo.T0100_AR_ApplicationDetail.AD_Amount, 
                      dbo.T0100_AR_ApplicationDetail.E_AD_Max_Limit, dbo.T0100_AR_ApplicationDetail.Comments, dbo.T0100_AR_ApplicationDetail.CreatedBy, 
                      dbo.T0100_AR_ApplicationDetail.DateCreated, dbo.T0100_AR_ApplicationDetail.Modifiedby, dbo.T0100_AR_ApplicationDetail.DateModified, 
                      dbo.T0050_AD_MASTER.AD_NAME, dbo.T0050_AD_MASTER.AD_SORT_NAME, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, dbo.T0100_AR_Application.AR_App_ID, 
                      dbo.T0100_AR_Application.Emp_ID, dbo.T0100_AR_Application.Grd_ID, dbo.T0100_AR_Application.For_Date, dbo.T0100_AR_Application.Total_Amount, 
                      dbo.T0100_AR_Application.App_Status, dbo.T0100_AR_Application.Cmp_ID, dbo.V0080_Employee_Master.Emp_Full_Name_new, 
                      ISNULL(dbo.T0040_GRADE_MASTER.Eligibility_Amount, 0.0) AS Eligibility_Amount, ISNULL(dbo.T0050_AD_MASTER.Is_Optional, 0) AS Is_Optional, 
                      ISNULL(dbo.T0050_AD_MASTER.AD_Code, '') AS AD_Code, ISNULL(dbo.T0050_AD_MASTER.Allowance_Type, '') AS Allowance_Type
FROM         dbo.T0100_AR_ApplicationDetail WITH (NOLOCK) INNER JOIN
                      dbo.T0050_AD_MASTER WITH (NOLOCK)  ON dbo.T0100_AR_ApplicationDetail.AD_ID = dbo.T0050_AD_MASTER.AD_ID INNER JOIN
                      dbo.T0100_AR_Application WITH (NOLOCK)  ON dbo.T0100_AR_ApplicationDetail.AR_App_ID = dbo.T0100_AR_Application.AR_App_ID INNER JOIN
                      dbo.V0080_Employee_Master WITH (NOLOCK)  ON dbo.T0100_AR_Application.Emp_ID = dbo.V0080_Employee_Master.Emp_ID INNER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0100_AR_Application.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
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
         Width = 75
         Width = 570
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_AR_ApplicationDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_AR_ApplicationDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[6] 2[30] 3) )"
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
         Begin Table = "T0100_AR_ApplicationDetail"
            Begin Extent = 
               Top = 7
               Left = 483
               Bottom = 197
               Right = 655
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "T0050_AD_MASTER"
            Begin Extent = 
               Top = 1
               Left = 711
               Bottom = 179
               Right = 964
            End
            DisplayFlags = 280
            TopColumn = 40
         End
         Begin Table = "T0100_AR_Application"
            Begin Extent = 
               Top = 7
               Left = 303
               Bottom = 183
               Right = 469
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "V0080_Employee_Master"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 350
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 3
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 28
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
         Width = 1500', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_AR_ApplicationDetail';

