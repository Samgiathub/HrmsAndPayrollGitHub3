


CREATE VIEW [dbo].[View_Vehicle_Final_N_level_Approval]
AS
SELECT Tran_ID,LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Vehicle_App_ID,LAD.Branch_Name
			,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Vehicle_App_Date ,LAD.App_Status 
			,0 As Rpt_Level,'0' as Scheme_ID, '1' as Final_Approver,Vehicle_ID
			,'0' as Is_Fwd_Leave_Rej,0 AS Is_Intimation,Vehicle_Type
			,QRY.Approval_Date,qry.S_emp_id,LAD.Cmp_ID,Vehicle_Type AS Vehicle_Name,CASE WHEN QRY.Vehicle_Appr_Status='A' THEN 'Approved' ELSE 'Rejected' END AS Vehicle_App_Status  ,
			isnull(qry.Vehicle_Option,'')Vehicle_Option
FROM         V0100_VEHICLE_APPLICATION LAD WITH (NOLOCK)  INNER JOIN
                (SELECT    TLA.Tran_ID, Tla.Vehicle_App_ID, Tla.s_emp_id,Tla.Vehicle_Appr_Status,Approval_Date,Tla.Vehicle_Option
                FROM          T0115_VEHICLE_APPROVAL_LEVEL Tla WITH (NOLOCK)  INNER JOIN
                                            (SELECT     max(Rpt_Level) Rpt_Level, Vehicle_App_ID
                                                FROM          T0115_VEHICLE_APPROVAL_LEVEL WITH (NOLOCK) 
                                                GROUP BY Vehicle_App_ID) AS Qry ON Qry.Rpt_Level = Tla.Rpt_Level AND Qry.Vehicle_App_ID = Tla.Vehicle_App_ID INNER JOIN
                                        V0100_VEHICLE_APPLICATION LA WITH (NOLOCK)  ON la.Vehicle_App_ID = Tla.Vehicle_App_ID
                WHERE      (Tla.Vehicle_Appr_Status = 'A' OR
                                        Tla.Vehicle_Appr_Status = 'R' OR
                                        Tla.Vehicle_Appr_Status = 'M')) AS qry ON LAD.Vehicle_App_ID = qry.Vehicle_App_ID 
