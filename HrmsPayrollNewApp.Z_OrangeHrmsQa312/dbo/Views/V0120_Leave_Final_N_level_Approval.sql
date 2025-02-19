





CREATE VIEW [dbo].[V0120_Leave_Final_N_level_Approval]
AS
SELECT     Row_ID, Leave_Name, Application_Code, VLA.Emp_ID, VLA.Emp_code, VLA.Emp_Full_Name, S_Emp_Full_Name, VLA.Cmp_ID, Approval_Status, Leave_Application_Id, 
                      Leave_Approval_ID, From_Date, To_Date, Leave_Period, VLA.Alpha_Emp_Code, leave_id, Leave_Reason, Approval_Comments, Approval_date, leave_assign_as, 
                      1 AS 'is_Final_Approved', S_Emp_ID AS 'S_Emp_ID_A',Apply_Hourly
           ,VLA.Emp_First_Name,VLA.Branch_ID,VLA.Dept_ID,Default_Short_Name,Leave_App_Doc,Is_Backdated_Application,
		   Half_Payment ,'' NightHalt,Leave_Assign_As as Leave_Type,
		   Leave_In_Time,Leave_Out_Time,Responsible_Emp_id,Half_Leave_Date,Rules_violate,
		   M_Cancel_WO_HO,application_date,TEMP.Emp_Full_Name  as Responsible_Employee
FROM         V0120_LEAVE_APPROVAL VLA WITH (NOLOCK)
Left Join T0080_EMP_MASTER TEMP WITH (NOLOCK) on VLA.Responsible_Emp_id=TEMP.Emp_ID
UNION ALL
SELECT     Row_ID, Leave_Name, Application_Code, Emp_ID, Emp_code, Emp_Full_Name, S_Emp_Full_Name, Cmp_ID,Approval_Status,-- Application_Status AS Approval_Status, 
                      lad.Leave_Application_Id, LAD.Leave_Application_ID AS Leave_Approval_ID, qry.From_Date, qry.To_Date, Leave_Period_Approved, Alpha_Emp_Code, leave_id, Leave_Reason, 
                      qry.Approval_Comments AS Approval_Comments, application_date AS Approval_date, leave_assign_as, 0 AS 'is_Final_Approved', qry.S_Emp_ID AS 'S_Emp_ID_A',Apply_Hourly
					,Emp_First_Name,LAD.Branch_ID,LAD.Dept_ID,Default_Short_Name,Leave_App_Doc,
					CASE lad.is_backdated_application WHEN 1 THEN '*' ELSE ''END as Is_Backdated_Application ,
					Half_Payment ,'' NightHalt,Leave_Assign_As as Leave_Type,
					Leave_In_Time,Leave_Out_Time,qry.Responsible_Emp_id,Half_Leave_Date,Rules_violate,
					M_Cancel_WO_HO, application_date, '' as Responsible_Employee                
FROM         V0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK)  INNER JOIN
                          (SELECT     lla.Leave_Application_ID, lla.s_emp_id, lla.Leave_Period as Leave_Period_Approved,Approval_Status,lla.From_Date,lla.To_Date,lla.Responsible_Emp_id,lla.Approval_Comments
						                            FROM          T0115_Leave_Level_Approval lla WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Leave_Application_ID
                                                         FROM          T0115_Leave_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY Leave_Application_ID) AS Qry ON Qry.Rpt_Level = lla.Rpt_Level AND Qry.Leave_Application_ID = lla.Leave_Application_ID INNER JOIN
                                                   T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  ON la.Leave_Application_ID = lla.Leave_Application_ID
							WHERE      (la.Application_Status = 'P' OR
                                                   la.Application_Status = 'F')) AS qry ON LAD.Leave_Application_ID = qry.Leave_Application_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[46] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
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
         Configuration = "(H (2[46] 3) )"
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
         Top = 0
         Left = 0
      End
      Begin Tables = 
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Leave_Final_N_level_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_Leave_Final_N_level_Approval';

