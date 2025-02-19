





CREATE VIEW [dbo].[V0100_ADVANCE_PAYMENT]
AS
SELECT     dbo.T0100_ADVANCE_PAYMENT.Adv_ID, dbo.T0100_ADVANCE_PAYMENT.Cmp_ID, dbo.T0100_ADVANCE_PAYMENT.For_Date, 
                      dbo.T0100_ADVANCE_PAYMENT.Adv_Amount, dbo.T0100_ADVANCE_PAYMENT.Adv_P_Days, dbo.T0100_ADVANCE_PAYMENT.Adv_Approx_Salary, 
                      dbo.T0100_ADVANCE_PAYMENT.Adv_Comments, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0100_ADVANCE_PAYMENT.Emp_ID,dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code,
                      B.Vertical_ID,B.SubVertical_ID,B.Dept_ID,B.Branch_ID  --Added By Jaina 29-09-2015
                      ,dbo.T0040_Reason_Master.Reason_Name,dbo.T0040_Reason_Master.Res_Id
                      ,T0100_ADVANCE_PAYMENT.Adv_Approval_ID   --Added By Jaina 17-11-2015
FROM         dbo.T0100_ADVANCE_PAYMENT WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_ADVANCE_PAYMENT.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID 
                      LEFT OUTER JOIN T0040_Reason_Master WITH (NOLOCK)  on dbo.T0040_Reason_Master.Res_Id = dbo.T0100_ADVANCE_PAYMENT.Res_id  --Added By Jaina 20-10-2015
                      --dbo.T0095_INCREMENT ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID
                      --Added By Jaina 29-09-2015 Start
                      INNER JOIN (
						SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID
						FROM	T0095_INCREMENT I WITH (NOLOCK) 
						WHERE	I.INCREMENT_ID = (
													SELECT	TOP 1 INCREMENT_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
													WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
													ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
												)
					  ) AS B ON B.EMP_ID = dbo.T0080_EMP_MASTER.EMP_ID AND B.CMP_ID=dbo.T0080_EMP_MASTER.CMP_ID 
					  --Added By Jaina 29-09-2015 End





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
         Begin Table = "T0100_ADVANCE_PAYMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 253
               Bottom = 121
               Right = 470
            End
            DisplayFlags = 280
            TopColumn = 78
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 153
               Left = 357
               Bottom = 268
               Right = 565
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_ADVANCE_PAYMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_ADVANCE_PAYMENT';

