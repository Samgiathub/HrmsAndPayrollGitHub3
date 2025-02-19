
/*WHERE     (TA.Ticket_Status = 'O' OR TA.Ticket_Status = 'H')*/
CREATE VIEW [dbo].[V0090_Ticket_Application_withOut_Sendto]
AS
SELECT     TA.Ticket_App_ID, TTM.Ticket_Type, TTM.Ticket_Dept_Name, 
                      CASE WHEN TA.Is_Candidate = 1 THEN R.Resume_Code ELSE EM.Alpha_Emp_Code END AS Alpha_Emp_Code, 
                      CASE WHEN TA.Is_Candidate = 1 THEN ISNULL(r.Initial, '') + ' ' + r.Emp_First_Name + ' ' + r.Emp_Last_Name ELSE EM.Emp_Full_Name END AS Emp_Full_Name, 
                      TA.Ticket_Gen_Date, (CASE WHEN TA.Ticket_Status = 'O' THEN 'Open' WHEN TA.Ticket_Status = 'H' THEN 'On Hold' ELSE 'Closed' END) AS Ticket_Status, 
                      TA.Ticket_Description,TP.Priority_Name AS Ticket_Priority,TA.Ticket_Type_ID,
					  TA.Ticket_Dept_ID, CASE WHEN TA.Is_Candidate = 1 THEN R.Resume_Id ELSE EM.Emp_ID END AS Emp_ID, TA.Cmp_ID, 
                      TA.Ticket_Attachment, TA.Is_Escalation, TA.Ticket_Priority AS Ticket_Priority_ID, TTA.Ticket_Solution AS On_Hold_Reason, TA.Ticket_Status AS Ticket_Status_Flag, 
                      ISNULL(TTA.Ticket_Apr_ID, 0) AS Ticket_Apr_ID, TTA.Ticket_Apr_Attachment, ISNULL(TA.Is_Candidate, 0) AS Is_Candidate, TA.User_ID, 
                      Eu.Emp_Full_Name AS AppliedByName, Eu.Emp_ID AS AppliedById, Eu.Work_Email AS appliedByEmail,
                      TA.Escalation_Hours,0 as Sendto, '' as SendTo_Full_Name 
FROM         dbo.T0090_Ticket_Application AS TA WITH (NOLOCK) INNER JOIN
                      dbo.T0040_Ticket_Type_Master AS TTM WITH (NOLOCK)  ON TA.Ticket_Type_ID = TTM.Ticket_Type_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID LEFT OUTER JOIN
                      dbo.T0100_Ticket_Approval AS TTA WITH (NOLOCK)  ON TTA.Ticket_App_ID = TA.Ticket_App_ID LEFT OUTER JOIN
                      dbo.T0055_Resume_Master AS R WITH (NOLOCK)  ON R.Resume_Id = TA.Emp_ID LEFT OUTER JOIN
                      dbo.T0011_LOGIN AS L WITH (NOLOCK)  ON L.Login_ID = TA.User_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS Eu WITH (NOLOCK)  ON Eu.Emp_ID = L.Emp_ID INNER JOIN 
                      T0040_Ticket_Priority TP WITH (NOLOCK)  ON TP.Tran_ID = TA.Ticket_Priority 
					  where isnull(Ta.SendTo,0) = 0 


