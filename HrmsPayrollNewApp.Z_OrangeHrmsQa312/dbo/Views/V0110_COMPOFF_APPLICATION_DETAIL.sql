




CREATE VIEW [dbo].[V0110_COMPOFF_APPLICATION_DETAIL]
AS
SELECT     CA.Cmp_ID, CA.Extra_Work_Date, CA.Extra_Work_Hours, CA.Extra_Work_Reason, CA.Login_ID, CA.System_Datetime, CA.Compoff_App_ID, 
                      CA.Emp_ID, CA.S_Emp_ID, CA.Application_Date, E1.Emp_Full_Name, E1.Emp_Superior, E.Emp_Full_Name AS SENIOR_EMPLOYEE, 
                      CA.Application_Status, E1.Emp_First_Name, E.Emp_First_Name AS S_EMP_FIRST_NAME, E.Emp_Left, E.Other_Email AS S_OTHER_EMAIL, 
                      E1.Mobile_No, I.Grd_ID, E1.Date_Of_Join, I.Dept_ID, I.Desig_Id, E.Emp_Full_Name AS S_EMP_FULL_NAME, E1.Other_Email, I.Branch_ID, 
                      D.Desig_Name, E.Emp_code AS S_EMP_CODE, B.Branch_Name, E1.Emp_code, E1.Work_Email, E1.Alpha_Emp_Code, CA.CompOff_Type,
                      I.Vertical_ID,I.SubVertical_ID,  --Added By Jaina 21-09-2015
                      CA.OT_Type,Ap.Sanctioned_Hours,ap.Approve_Comments
FROM         dbo.T0100_CompOff_Application AS CA WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1  WITH (NOLOCK) INNER JOIN
                      dbo.T0095_INCREMENT AS I WITH (NOLOCK)  ON E1.Increment_ID = I.Increment_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK)  ON I.Branch_ID = B.Branch_ID ON CA.Emp_ID = E1.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS D WITH (NOLOCK)  ON I.Desig_Id = D.Desig_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON CA.S_Emp_ID = E.Emp_ID LEFT OUTER JOIN
					  dbo.T0120_CompOff_Approval AS Ap WITH (NOLOCK)  ON CA.CompOff_App_ID = Ap.CompOff_App_ID --Added by Ronakb111223




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
         Begin Table = "CA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "E1"
            Begin Extent = 
               Top = 6
               Left = 256
               Bottom = 121
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 6
               Left = 511
               Bottom = 121
               Right = 719
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 757
               Bottom = 121
               Right = 916
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 954
               Bottom = 121
               Right = 1106
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 255
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
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_COMPOFF_APPLICATION_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' Output = 720
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_COMPOFF_APPLICATION_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_COMPOFF_APPLICATION_DETAIL';

