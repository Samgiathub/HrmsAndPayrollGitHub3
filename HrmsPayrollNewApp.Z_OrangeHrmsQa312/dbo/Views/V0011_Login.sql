




CREATE VIEW [dbo].[V0011_Login]
AS
SELECT     dbo.T0011_LOGIN.Login_Name, dbo.T0011_LOGIN.Login_Password, dbo.T0011_LOGIN.Login_ID, dbo.T0011_LOGIN.Cmp_ID, dbo.T0011_LOGIN.Branch_ID, dbo.T0080_EMP_MASTER.Emp_ID, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Last_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Other_Email, 
                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0040_GRADE_MASTER.Grd_Name, CAST(dbo.T0080_EMP_MASTER.Emp_code AS varchar(50)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_NEw, 
                      CAST(dbo.T0080_EMP_MASTER.Emp_code AS VARCHAR(50)) AS EMP_CODE, dbo.T0011_LOGIN.Is_Default, dbo.T0011_LOGIN.Email_ID AS HR_Email_ID, 
                      dbo.T0011_LOGIN.Email_ID_Accou AS Acc_Email_ID, dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0011_LOGIN.Is_HR, dbo.T0011_LOGIN.Is_Accou, 
                      dbo.T0080_EMP_MASTER.Emp_Left, dbo.T0011_LOGIN.Login_Alias, dbo.T0011_LOGIN.IS_IT, dbo.T0011_LOGIN.Travel_Help_Desk,dbo.T0080_EMP_MASTER.Mobile_No
                      ,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID,dbo.T0080_EMP_MASTER.Dept_ID,dbo.T0080_EMP_MASTER.Branch_ID As Emp_Branch  --Added By Jaina 13-08-2016
FROM         dbo.T0040_GRADE_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0011_LOGIN.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID ON dbo.T0040_GRADE_MASTER.Grd_ID = dbo.T0080_EMP_MASTER.Grd_ID




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0011_Login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[69] 4[4] 2[9] 3) )"
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
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0011_LOGIN"
            Begin Extent = 
               Top = 6
               Left = 251
               Bottom = 227
               Right = 410
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 9
               Left = 545
               Bottom = 288
               Right = 762
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 126
               Left = 293
               Bottom = 241
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 246
               Left = 228
               Bottom = 361
               Right = 387
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
      Begin ColumnWidths = 26
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0011_Login';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   Width = 284
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0011_Login';

