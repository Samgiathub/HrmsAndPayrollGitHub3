


CREATE VIEW [dbo].[V0120_AR_Approval]
AS
SELECT     dbo.T0120_AR_Approval.AR_Apr_ID, dbo.T0120_AR_Approval.AR_APP_ID, dbo.T0120_AR_Approval.Cmp_ID, dbo.T0120_AR_Approval.Emp_ID, 
                      dbo.T0120_AR_Approval.Increment_Id, dbo.T0120_AR_Approval.For_Date, dbo.T0120_AR_Approval.Eligibility_amount, dbo.T0120_AR_Approval.Total_Amount, 
                      dbo.T0120_AR_Approval.Apr_Status, dbo.T0120_AR_Approval.CreatedBy, dbo.T0120_AR_Approval.DateCreated, dbo.T0120_AR_Approval.ModifiedBy, 
                      dbo.T0120_AR_Approval.DateModified, dbo.V0080_Employee_Master.Emp_Full_Name_new, dbo.V0080_Employee_Master.Branch_ID, 
                      dbo.V0080_Employee_Master.Emp_First_Name, dbo.V0080_Employee_Master.Alpha_Emp_Code
FROM         dbo.T0120_AR_Approval WITH (NOLOCK) INNER JOIN
                      dbo.V0080_Employee_Master WITH (NOLOCK)  ON dbo.T0120_AR_Approval.Emp_ID = dbo.V0080_Employee_Master.Emp_ID
			LEFT OUTER JOIN
                (SELECT     I.emp_id, I.branch_id, i.Cmp_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID  --added by jimit 02122016
                 FROM          dbo.T0095_INCREMENT I WITH (NOLOCK)  INNER JOIN
                              dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON E.Emp_ID = I.Emp_ID
                 WHERE      I.INCREMENT_id IN
                       (SELECT     MAX(INCREMENT_ID)
                        FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                        GROUP BY EMP_ID)) mm ON V0080_Employee_Master.Emp_ID = mm.Emp_ID AND V0080_Employee_Master.Cmp_ID = mm.Cmp_ID
                        


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[13] 3) )"
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
         Begin Table = "T0120_AR_Approval"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 166
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "V0080_Employee_Master"
            Begin Extent = 
               Top = 7
               Left = 397
               Bottom = 181
               Right = 622
            End
            DisplayFlags = 280
            TopColumn = 18
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_AR_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_AR_Approval';

