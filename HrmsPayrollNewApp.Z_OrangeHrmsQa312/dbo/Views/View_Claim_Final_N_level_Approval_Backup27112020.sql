






CREATE VIEW [dbo].[View_Claim_Final_N_level_Approval_Backup27112020]
AS


SELECT  LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Claim_App_ID, LAD.Claim_App_Code ,LAD.Branch_Name,LAD.Desig_ID
		,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Claim_App_Date ,LAD.Claim_App_Status As Application_Status_1 ,qry.Claim_Apr_Status As Application_Status
		,LAD.Claim_approval_id,LAD.Claim_approval_id as clmaprid,LAD.Emp_First_Name,LAD.Branch_ID
        ,qry.S_emp_id AS S_Emp_ID_A,qry.S_emp_id AS S_Emp_ID,LAD.Claim_App_Status,LAD.Cmp_ID,
         LAD.Grd_ID,(CASE WHEN ISNULL(LAD.CLAIM_APP_DOC,'') <> '' THEN 'Attached' ELSE 'Not-Attached' END) AS Attachment --Added by Rajput on 08032018 
FROM         V0100_Claim_Application LAD WITH (NOLOCK) INNER JOIN
                          (SELECT     Tla.Claim_App_ID, Tla.s_emp_id,Tla.Claim_Apr_Status
                            FROM          T0115_CLAIM_LEVEL_APPROVAL Tla WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Claim_App_ID
                                                         FROM          T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK) 
                                                         GROUP BY Claim_App_ID) AS Qry ON Qry.Rpt_Level = Tla.Rpt_Level AND Qry.Claim_App_ID = Tla.Claim_App_ID LEFT JOIN
                                                   V0100_Claim_Application LA ON la.Claim_App_ID = Tla.Claim_App_ID
                            WHERE      (Tla.Claim_Apr_Status = 'A' OR
                                                   Tla.Claim_Apr_Status = 'R' OR
                                                   Tla.Claim_Apr_Status = 'M')) AS qry ON LAD.Claim_App_ID = qry.Claim_App_ID -- Tla.Claim_Apr_Status = 'M' ADDED ON 28052018




