





CREATE VIEW [dbo].[V0120_Leave_Final_N_level_Approval_BACKUP_MEHUL_04062022]
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
                      Leave_Reason AS Approval_Comments, application_date AS Approval_date, leave_assign_as, 0 AS 'is_Final_Approved', qry.S_Emp_ID AS 'S_Emp_ID_A',Apply_Hourly
					,Emp_First_Name,LAD.Branch_ID,LAD.Dept_ID,Default_Short_Name,Leave_App_Doc,
					CASE lad.is_backdated_application WHEN 1 THEN '*' ELSE ''END as Is_Backdated_Application ,
					Half_Payment ,'' NightHalt,Leave_Assign_As as Leave_Type,
					Leave_In_Time,Leave_Out_Time,qry.Responsible_Emp_id,Half_Leave_Date,Rules_violate,
					M_Cancel_WO_HO, application_date, '' as Responsible_Employee                
FROM         V0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK)  INNER JOIN
                          (SELECT     lla.Leave_Application_ID, lla.s_emp_id, lla.Leave_Period as Leave_Period_Approved,Approval_Status,lla.From_Date,lla.To_Date,lla.Responsible_Emp_id
						                            FROM          T0115_Leave_Level_Approval lla WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Leave_Application_ID
                                                         FROM          T0115_Leave_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY Leave_Application_ID) AS Qry ON Qry.Rpt_Level = lla.Rpt_Level AND Qry.Leave_Application_ID = lla.Leave_Application_ID INNER JOIN
                                                   T0100_LEAVE_APPLICATION LA WITH (NOLOCK)  ON la.Leave_Application_ID = lla.Leave_Application_ID
                            WHERE      (la.Application_Status = 'P' OR
                                                   la.Application_Status = 'F')) AS qry ON LAD.Leave_Application_ID = qry.Leave_Application_ID




