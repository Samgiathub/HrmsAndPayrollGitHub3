





CREATE VIEW [dbo].[V0110_Training_Induction_Details]
AS
SELECT     dbo.T0110_Training_Induction_Details.Emp_ID, dbo.T0110_Training_Induction_Details.Training_Date, 
 isnull(dbo.F_GET_AMPM(dbo.T0110_Training_Induction_Details.Training_Time),'')Training_Time, 
                      dbo.T0110_Training_Induction_Details.Training_Induction_ID, V0040_Training_Induction_Master.Training_id, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
                      (Alpha_Emp_Code+'-'+dbo.T0080_EMP_MASTER.Emp_Full_Name)Emp_Full_Name,Tran_ID,T0080_EMP_MASTER.Cmp_ID,Emp_Name as Contact_Person,Contact_Person_ID,TM.Training_name
FROM         dbo.V0040_Training_Induction_Master WITH (NOLOCK) INNER JOIN
                      dbo.T0110_Training_Induction_Details WITH (NOLOCK)  ON 
                      dbo.V0040_Training_Induction_Master.Training_Induction_ID = dbo.T0110_Training_Induction_Details.Training_Induction_ID INNER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.V0040_Training_Induction_Master.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0110_Training_Induction_Details.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      T0040_Hrms_Training_master TM WITH (NOLOCK)  on TM.Training_id=V0040_Training_Induction_Master.Training_id inner join
                      dbo.T0040_Hrms_Training_master WITH (NOLOCK)  ON dbo.T0040_Hrms_Training_master.Training_id = dbo.V0040_Training_Induction_Master.Training_id

                     



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[22] 4[23] 2[37] 3) )"
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
         Begin Table = "T0040_Training_Induction_Master"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0110_Training_Induction_Details"
            Begin Extent = 
               Top = 6
               Left = 271
               Bottom = 125
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 6
               Left = 504
               Bottom = 125
               Right = 682
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 720
               Bottom = 125
               Right = 964
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
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Training_Induction_Details';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Training_Induction_Details';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Training_Induction_Details';

