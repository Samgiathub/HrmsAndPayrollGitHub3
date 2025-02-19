


CREATE VIEW [dbo].[V0100_EMP_EARN_DEDUCTION]
AS
SELECT     dbo.T0050_AD_MASTER.AD_NAME, EED.AD_TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EED.INCREMENT_ID, EED.FOR_DATE, 
                      EED.E_AD_FLAG, EED.E_AD_MODE, DBO.F_Lower_Round(EED.E_AD_PERCENTAGE,EED.CMP_ID) As E_AD_PERCENTAGE, DBO.F_Lower_Round(EED.E_AD_AMOUNT,EED.CMP_ID) As E_AD_AMOUNT , EED.E_AD_MAX_LIMIT, dbo.T0050_AD_MASTER.AD_LEVEL, 
                      dbo.T0050_AD_MASTER.AD_NOT_EFFECT_SALARY, dbo.T0050_AD_MASTER.AD_PART_OF_CTC, dbo.T0050_AD_MASTER.AD_ACTIVE, 
                      dbo.T0050_AD_MASTER.AD_NOT_EFFECT_ON_PT, dbo.T0050_AD_MASTER.FOR_FNF, dbo.T0050_AD_MASTER.NOT_EFFECT_ON_MONTHLY_CTC, 
                      dbo.T0050_AD_MASTER.Is_Yearly, dbo.T0050_AD_MASTER.Not_Effect_on_Basic_Calculation, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, 
                      dbo.T0050_AD_MASTER.Effect_Net_Salary, dbo.T0050_AD_MASTER.AD_EFFECT_MONTH, 
                      CASE WHEN E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, dbo.T0050_AD_MASTER.Add_in_sal_amt, 
                      dbo.T0050_AD_MASTER.AD_DEF_ID,
                      dbo.T0050_AD_MASTER.Hide_In_Reports   --Added by Jaina 20-12-2016
FROM         dbo.T0100_EMP_EARN_DEDUCTION AS EED WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EED.INCREMENT_ID = EM.Increment_ID INNER JOIN
                      dbo.T0050_AD_MASTER WITH (NOLOCK)  ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID





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
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "EED"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 6
               Left = 254
               Bottom = 121
               Right = 471
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_AD_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 266
            End
            DisplayFlags = 280
            TopColumn = 12
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_EMP_EARN_DEDUCTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_EMP_EARN_DEDUCTION';

