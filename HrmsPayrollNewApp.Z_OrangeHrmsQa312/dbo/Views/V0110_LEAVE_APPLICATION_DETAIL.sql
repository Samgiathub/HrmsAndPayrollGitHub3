





CREATE VIEW [dbo].[V0110_LEAVE_APPLICATION_DETAIL]
AS
SELECT     lad.Cmp_ID, lad.Leave_ID, lad.From_Date, lad.To_Date, lad.Leave_Period, lad.Leave_Assign_As, lad.Leave_Reason, lad.Row_ID, lad.Login_ID, 
                      lad.System_Date, lad.Leave_Application_ID, LA.Emp_ID, LA.S_Emp_ID, 
                      LA.Application_Date 
                      --convert(varchar(10),LA.Application_Date ,101) as Application_date
                      , lm.Leave_Name, lm.Leave_Paid_Unpaid, 
                      E1.Emp_Full_Name, R_Emp_ID As Emp_Superior, isnull(Qry_Reporting.Emp_Full_Name,'Admin') AS Senior_Employee, LA.Application_Code,
					  LA.Application_Status, E1.Emp_First_Name, 
                      Qry_Reporting.Emp_First_Name AS S_Emp_First_Name, e1.Emp_Left, Qry_Reporting.Other_Email AS S_Other_Email, E1.Mobile_No, lm.Leave_Min, lm.Leave_Max, 
                      lm.Leave_Notice_Period, lm.Leave_Applicable, lm.Leave_Status, dbo.T0095_INCREMENT.Grd_ID, E1.Date_Of_Join, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, Qry_Reporting.Emp_Full_Name AS S_Emp_Full_Name, E1.Other_Email, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name, Qry_Reporting.Emp_code AS S_Emp_Code, dbo.T0030_BRANCH_MASTER.Branch_Name, E1.Emp_code, 
                      E1.Work_Email, E1.Alpha_Emp_Code, lad.Half_Leave_Date, lm.Default_Short_Name, LA.is_backdated_application, LA.is_Responsibility_pass, 
                      LA.Responsible_Emp_id, ISNULL(lad.Leave_App_Doc, '') AS Leave_App_Doc, LA.Application_Comments, lm.Apply_Hourly, lm.Can_Apply_Fraction, 
                      lad.leave_Out_time, lad.leave_In_time, lm.Leave_Type, lad.NightHalt, lm.AllowNightHalt, ISNULL(lad.Leave_CompOff_Dates, '') 
                      AS Leave_CompOff_Dates, lad.Half_Payment, lm.Half_Paid, lad.Warning_flag, lad.Rules_violate
                      ,dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID ,dbo.T0040_DEPARTMENT_MASTER.Dept_Name --Added By Jaina 01-10-2015 
                      ,LA.M_Cancel_WO_HO --Ankit 05082016
                      ,E1.Gender,Qry_Reporting.Alpha_Emp_Code AS S_Alpha_Emp_Code
FROM         dbo.T0100_LEAVE_APPLICATION AS LA WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1 WITH (NOLOCK)  INNER JOIN
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON E1.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID ON 
                      LA.Emp_ID = E1.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      --dbo.T0080_EMP_MASTER AS e ON LA.S_Emp_ID = e.Emp_ID RIGHT OUTER JOIN
                      -- LEFT OUTER JOIN
                       	--Removed by Nimesh on 30-11-2015 (Duplicate records are displaying for emp code top2010821064)
                          (SELECT   R1.Emp_ID, Effect_Date AS Effect_Date, R_Emp_ID,Em.emp_full_name,Em.Emp_First_Name,Em.Emp_code,Em.Other_Email,Alpha_Emp_Code
                            FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) 
									INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)  
													INNER JOIN (SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID FROM T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)  WHERE R3.Effect_Date < GETDATE() GROUP BY R3.Emp_ID) R3
													ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date
												GROUP BY R2.Emp_ID
												) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID
												inner join t0080_emp_master Em WITH (NOLOCK)  on R1.R_emp_id = Em.emp_id
							) AS Qry_Reporting ON E1.Emp_ID = Qry_Reporting.Emp_ID RIGHT OUTER JOIN --Added by sumit for showing reporting manager 05120015
                      dbo.T0040_LEAVE_MASTER AS lm WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0110_LEAVE_APPLICATION_DETAIL AS lad WITH (NOLOCK)  ON lm.Leave_ID = lad.Leave_ID ON LA.Leave_Application_ID = lad.Leave_Application_ID LEFT OUTER JOIN
					  dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id 
					  --LEFT OUTER JOIN 
					  --dbo.T0115_Leave_Level_Approval WITH (NOLOCK)  ON dbo.T0115_Leave_Level_Approval.Leave_Application_ID = lad.Leave_Application_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'      End
            DisplayFlags = 280
            TopColumn = 28
         End
         Begin Table = "lad"
            Begin Extent = 
               Top = 366
               Left = 287
               Bottom = 481
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 10
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
      PaneHidden = 
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_LEAVE_APPLICATION_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_LEAVE_APPLICATION_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[12] 3) )"
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
         Configuration = "(H (2[75] 3) )"
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
         Configuration = "(V (2) )"
      End
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = -192
         Left = 0
      End
      Begin Tables = 
         Begin Table = "LA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 10
         End
         Begin Table = "E1"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 75
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 265
               Bottom = 121
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 126
               Left = 293
               Bottom = 241
               Right = 452
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 246
               Left = 228
               Bottom = 361
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "lm"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 648
               Right = 249
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_LEAVE_APPLICATION_DETAIL';

