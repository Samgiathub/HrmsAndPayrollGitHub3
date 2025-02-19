



CREATE VIEW [dbo].[V0080_EMP_MASTER_GET]
AS
SELECT     em.Emp_ID, em.Cmp_ID, em.Branch_ID, em.Cat_ID, em.Grd_ID, em.Dept_ID, em.Desig_Id, em.Type_ID, em.Shift_ID, em.Bank_ID, em.Emp_code, em.Initial, 
                      em.Emp_First_Name, em.Emp_Second_Name, em.Emp_Last_Name, em.Curr_ID, em.Date_Of_Join, em.SSN_No, em.SIN_No, em.Dr_Lic_No, em.Pan_No, 
                      em.Marital_Status, em.Gender, em.Nationality, em.Loc_ID, em.Street_1, em.City, em.State, em.Zip_code, em.Home_Tel_no, em.Mobile_No, em.Work_Tel_No, 
                      em.Work_Email, em.Other_Email, em.Basic_Salary, em.Image_Name, em.Emp_Full_Name, em.Emp_Left, em.Emp_Left_Date, em.Increment_ID, em.Present_Street, 
                      em.Present_City, em.Present_State, em.Present_Post_Box, CAST(em.Date_Of_Birth AS varchar(11)) AS Date_OF_Birth, CAST(em.Dr_Lic_Ex_Date AS varchar(11)) 
                      AS Dr_Lic_Ex_Date, dbo.T0011_LOGIN.Login_Name, dbo.T0011_LOGIN.Login_Password, dbo.T0011_LOGIN.Login_ID, em.Alpha_Emp_Code, em.Alpha_Code, 
                      em.Old_Ref_No, em.UAN_No
FROM         dbo.T0080_EMP_MASTER AS em WITH (NOLOCK) INNER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON em.Emp_ID = dbo.T0011_LOGIN.Emp_ID


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
         Begin Table = "em"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 119
         End
         Begin Table = "T0011_LOGIN"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 216
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_MASTER_GET';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_MASTER_GET';

