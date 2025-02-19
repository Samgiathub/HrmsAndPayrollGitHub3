


/*LEFT OUTER JOIN
dbo.T0110_EMP_LEFT_JOIN_TRAN ON dbo.T0100_LEFT_EMP.Emp_ID = dbo.T0110_EMP_LEFT_JOIN_TRAN.Emp_ID AND 
dbo.T0100_LEFT_EMP.Left_Date = dbo.T0110_EMP_LEFT_JOIN_TRAN.Left_Date AND dbo.T0100_LEFT_EMP.Left_Date = dbo.T0110_EMP_LEFT_JOIN_TRAN.Left_Date*/
CREATE VIEW [dbo].[V0080_EMP_CMP_TRANSFER_INSERT]
AS
SELECT     dbo.T0095_EMP_COMPANY_TRANSFER.Tran_Id, dbo.T0095_EMP_COMPANY_TRANSFER.Old_Cmp_Id, dbo.T0095_EMP_COMPANY_TRANSFER.Old_Emp_Id, 
                      dbo.T0095_EMP_COMPANY_TRANSFER.New_Cmp_Id, dbo.T0095_EMP_COMPANY_TRANSFER.New_Emp_Id, 
                      dbo.T0095_EMP_COMPANY_TRANSFER.Old_Branch_Id, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, T0010_COMPANY_MASTER_1.Cmp_Name, 
                      dbo.T0095_EMP_COMPANY_TRANSFER.Effective_Date, dbo.T0010_COMPANY_MASTER.Cmp_Name AS New_Cmp_Name,
                      dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,dbo.T0095_INCREMENT.Dept_ID   --Added By Jaina 16-09-2015
FROM         dbo.T0010_COMPANY_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK) ON dbo.T0010_COMPANY_MASTER.Cmp_Id = dbo.T0095_EMP_COMPANY_TRANSFER.New_Cmp_Id LEFT OUTER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_1 WITH (NOLOCK) ON dbo.T0095_INCREMENT.Cmp_ID = T0010_COMPANY_MASTER_1.Cmp_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID ON 
                      dbo.T0095_EMP_COMPANY_TRANSFER.Old_Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[75] 4[5] 2[15] 3) )"
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
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER_1"
            Begin Extent = 
               Top = 8
               Left = 444
               Bottom = 127
               Right = 685
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 146
               Left = 551
               Bottom = 265
               Right = 795
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0095_EMP_COMPANY_TRANSFER"
            Begin Extent = 
               Top = 168
               Left = 67
               Bottom = 287
               Right = 277
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 271
               Left = 290
               Bottom = 390
               Right = 531
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
      Begin ColumnWidths = 14
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
         Width = 15', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_CMP_TRANSFER_INSERT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'00
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_CMP_TRANSFER_INSERT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_CMP_TRANSFER_INSERT';

