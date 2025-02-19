


CREATE VIEW [dbo].[Active_InActive_Users]
AS
SELECT     l.Login_ID, l.Cmp_ID, l.Login_Name, l.Login_Password, l.Emp_ID, e.Branch_ID, l.Login_Rights_ID, l.Is_Default, l.Is_HR, l.Is_Accou, l.Email_ID, l.Email_ID_Accou, 
                      l.Is_Active, e.Emp_First_Name, e.Emp_Second_Name, e.Emp_Last_Name, e.Date_Of_Join, e.Basic_Salary, e.Shift_Name, e.Dept_Name, e.Gender, e.Type_Name, 
                      e.Marital_Status, e.Grd_Name, e.Emp_Full_Name_new, e.Emp_Full_Name, e.Emp_Left, e.Work_Tel_No, e.Mobile_No, e.Date_Of_Birth, e.Emp_Full_Name_Superior, 
                      e.Emp_Superior, e.Present_City, e.Present_State, e.Present_Post_Box, e.Present_Street, e.Emp_Left_Date, e.Other_Email, e.Work_Email, e.Home_Tel_no, 
                      e.Zip_code, e.State, e.City, e.Street_1, e.Nationality, e.Dr_Lic_Ex_Date, e.Pan_No, e.Dr_Lic_No, e.SIN_No, e.SSN_No, e.Desig_Id, e.Desig_Name, e.Def_ID, 
                      e.Cmp_Name, e.Dept_ID, e.Branch_Name, e.P_Other_Mail, e.P_Work_Mail, e.Grd_ID, e.Image_Name, e.Enroll_No, e.Initial, e.Gross_Salary, e.Emp_OT, 
                      e.Emp_OT_Min_Limit, e.Emp_OT_Max_Limit, e.Emp_Late_mark, e.Emp_PT, e.Emp_Full_PF, e.Emp_Fix_Salary, e.Emp_Part_Time, e.Late_Dedu_Type, 
                      e.Emp_Late_Limit, e.Emp_PT_Amount, e.Yearly_Bonus_Amount, e.Inc_Bank_AC_No, e.Payment_Mode, e.Salary_Basis_On, e.Wages_Type, e.Bank_ID, e.Type_ID, 
                      e.Blood_Group, e.Religion, e.Height, e.Emp_Mark_Of_Identification, e.Despencery, e.Doctor_Name, e.DespenceryAddress, e.Insurance_No, e.Is_Gr_App, 
                      e.Is_Yearly_Bonus, e.Yearly_Leave_Days, e.Yearly_Leave_Amount, e.Emp_Confirm_Date, e.Is_On_Probation, e.Probation, e.Yearly_Bonus_Per, e.Shift_ID, 
                      e.Increment_ID, e.Parent_ID, e.Is_Main, e.System_Date, e.Loc_name, e.Reg_Accept_Date, e.Loc_ID, e.Sup_Mobile_No, e.Alpha_Emp_Code, e.Alpha_Code, 
                      e.Old_Ref_No, e.Emp_code, e.Ifsc_Code, e.Bank_BSR, e.Leave_In_Probation, ISNULL(q.Reason, '') AS Reason
FROM         dbo.T0011_LOGIN AS l WITH (NOLOCK) INNER JOIN
                      dbo.V0080_Employee_Master AS e WITH (NOLOCK)  ON l.Emp_ID = e.Emp_ID LEFT OUTER JOIN
                          (SELECT     i.History_Id, i.Cmp_Id, i.Emp_Id, i.Login_Id, i.Reason, i.System_Date, i.Active_Status
                            FROM          dbo.T0020_INACTIVE_USER_HISTORY AS i WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     Emp_Id, MAX(System_Date) AS System_Date
                                                         FROM          dbo.T0020_INACTIVE_USER_HISTORY AS iu WITH (NOLOCK) 
                                                         WHERE      (Active_Status = 'InActive')
                                                         GROUP BY Emp_Id) AS Qry ON i.Emp_Id = Qry.Emp_Id AND i.System_Date = Qry.System_Date) AS q ON q.Emp_Id = l.Emp_ID


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
         Begin Table = "l"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "q"
            Begin Extent = 
               Top = 6
               Left = 254
               Bottom = 125
               Right = 414
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Active_InActive_Users';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Active_InActive_Users';

