



CREATE VIEW [dbo].[V0110_Leave_FirstApprover_Detail]
AS
SELECT     LAPR.Cmp_ID, LAPRD.Leave_ID, LAPRD.From_Date, LAPRD.To_Date, LAPRD.Leave_Period, LAPRD.Leave_Assign_As, LAPRD.Leave_Reason, lad.Row_ID, 
                      lad.Login_ID, lad.System_Date, lad.Leave_Application_ID, LA.Emp_ID, LA.S_Emp_ID, LA.Application_Date, lm.Leave_Name, lm.Leave_Paid_Unpaid, 
                      E1.Emp_Full_Name, E1.Emp_Superior, e.Emp_Full_Name AS Senior_Employee, LA.Application_Code, LA.Application_Status, E1.Emp_First_Name, 
                      e.Emp_First_Name AS S_Emp_First_Name, e.Emp_Left, e.Other_Email AS S_Other_Email, E1.Mobile_No, lm.Leave_Min, lm.Leave_Max, lm.Leave_Notice_Period, 
                      lm.Leave_Applicable, lm.Leave_Status, dbo.T0095_INCREMENT.Grd_ID, E1.Date_Of_Join, dbo.T0095_INCREMENT.Dept_ID, dbo.T0095_INCREMENT.Desig_Id, 
                      e.Emp_Full_Name AS S_Emp_Full_Name, E1.Other_Email, dbo.T0095_INCREMENT.Branch_ID, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      e.Emp_code AS S_Emp_Code, dbo.T0030_BRANCH_MASTER.Branch_Name, E1.Emp_code, E1.Work_Email, E1.Alpha_Emp_Code, lad.Half_Leave_Date, 
                      lm.Default_Short_Name
FROM         dbo.T0120_LEAVE_APPROVAL AS LAPR WITH (NOLOCK) INNER JOIN
                      dbo.T0130_LEAVE_APPROVAL_DETAIL AS LAPRD WITH (NOLOCK)  ON LAPRD.Leave_Approval_ID = LAPR.Leave_Approval_ID INNER JOIN
                      dbo.T0100_LEAVE_APPLICATION AS LA WITH (NOLOCK)  ON LA.Leave_Application_ID = LAPR.Leave_Application_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK)  INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON E1.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID ON LA.Emp_ID = E1.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON LA.S_Emp_ID = e.Emp_ID RIGHT OUTER JOIN
                      dbo.T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0110_LEAVE_APPLICATION_DETAIL AS lad WITH (NOLOCK)  ON lm.Leave_ID = lad.Leave_ID ON LA.Leave_Application_ID = lad.Leave_Application_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 126
               Left = 732
               Bottom = 245
               Right = 957
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "lm"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 320
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "lad"
            Begin Extent = 
               Top = 246
               Left = 358
               Bottom = 365
               Right = 551
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
      Begin ColumnWidths = 47
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Leave_FirstApprover_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Leave_FirstApprover_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[22] 2[21] 3) )"
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
         Begin Table = "LAPR"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 234
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LAPRD"
            Begin Extent = 
               Top = 6
               Left = 272
               Bottom = 125
               Right = 456
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LA"
            Begin Extent = 
               Top = 6
               Left = 494
               Bottom = 125
               Right = 691
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E1"
            Begin Extent = 
               Top = 6
               Left = 729
               Bottom = 125
               Right = 954
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 126
               Left = 292
               Bottom = 245
               Right = 487
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 126
               Left = 525
               Bottom = 245
               Right = 694
            End
          ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Leave_FirstApprover_Detail';

