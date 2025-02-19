


CREATE  VIEW [dbo].[View_Claim_Final_N_level_Approval]
AS


SELECT distinct  LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Claim_App_ID, LAD.Claim_App_Code ,LAD.Branch_Name,LAD.Desig_ID
		,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Claim_App_Date ,LAD.Claim_App_Status As Application_Status_1 ,qry.Claim_Apr_Status As Application_Status
		,LAD.Claim_approval_id,LAD.Claim_approval_id as clmaprid,LAD.Emp_First_Name,LAD.Branch_ID
        ,qry.S_emp_id AS S_Emp_ID_A,qry.S_emp_id AS S_Emp_ID,LAD.Claim_App_Status,LAD.Cmp_ID,
         LAD.Grd_ID,(CASE WHEN ISNULL(LAD.CLAIM_APP_DOC,'') <> '' THEN 'Attached' ELSE 'Not-Attached' END) AS Attachment --Added by Rajput on 08032018 
		 ,LAD.CLAIM_APP_DOC as MobileAttachment,Qry.Approval_Date
		 , ISNULL(REVERSE(STUFF(REVERSE((SELECT  DISTINCT   CD.Claim_Name + ','
                            FROM          V0100_Claim_Application_New_Detail CD WITH (NOLOCK)
                            WHERE      CD.Claim_App_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(LAD.Claim_App_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') AS Claim_Name,Cast(Claim_App_Amount as decimal(18,2)) as Claim_App_Amount,Claim_Apr_Amount,Claim_Date_Label
FROM         V0100_Claim_Application LAD WITH (NOLOCK)  INNER JOIN
                          (SELECT     Tla.Claim_App_ID, Tla.s_emp_id,Tla.Claim_Apr_Status,tla.Approval_Date,cla.Claim_Apr_Amount
                            FROM          T0115_CLAIM_LEVEL_APPROVAL Tla WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Claim_App_ID
                                                         FROM          T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK) 
                                                         GROUP BY Claim_App_ID) AS Qry ON Qry.Rpt_Level = Tla.Rpt_Level AND Qry.Claim_App_ID = Tla.Claim_App_ID INNER JOIN
                                                   V0100_Claim_Application LA WITH (NOLOCK)  ON la.Claim_App_ID = Tla.Claim_App_ID INNER JOIN
												    (SELECT     sum(Claim_Apr_Amnt) Claim_Apr_Amount, Claim_App_ID,Rpt_Level as lvl
                                                         FROM          T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK) 
                                                         GROUP BY Claim_App_ID,Claim_ID,Emp_ID,Rpt_Level) CLA ON  Qry.Claim_App_ID = CLA.Claim_App_ID and Qry.Rpt_Level = cla.lvl
                            WHERE      (Tla.Claim_Apr_Status = 'A' OR
                                                   Tla.Claim_Apr_Status = 'R' OR
                                                   Tla.Claim_Apr_Status = 'M' )) AS qry ON LAD.Claim_App_ID = qry.Claim_App_ID -- Tla.Claim_Apr_Status = 'M' ADDED ON 28052018




