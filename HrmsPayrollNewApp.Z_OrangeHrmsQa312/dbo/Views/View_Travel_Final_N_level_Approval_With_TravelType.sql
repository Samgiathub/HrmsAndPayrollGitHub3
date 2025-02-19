


CREATE VIEW [dbo].[View_Travel_Final_N_level_Approval_With_TravelType]
AS
SELECT  LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Travel_Application_ID, LAD.Application_Code ,LAD.Branch_Name
		,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Application_Date ,LAD.Application_Status As Application_Status_1 ,qry.Approval_Status As Application_Status
		,LAD.Travel_Set_Application_id,LAD.travel_approval_id as Travel_approval_id,LAD.Emp_First_Name,LAD.Branch_ID
        ,qry.S_emp_id AS S_Emp_ID_A,dbo.F_GET_Emp_Visit(LAD.Cmp_ID,LAD.Travel_Application_ID,0) as Emp_Visit
FROM         V0100_TRAVEL_APPLICATION LAD WITH (NOLOCK) INNER JOIN
                          (SELECT     Tla.Travel_Application_ID, Tla.s_emp_id,Tla.Approval_Status
                            FROM          T0115_TRAVEL_LEVEL_APPROVAL Tla WITH (NOLOCK)  INNER JOIN
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Travel_Application_ID
                                                         FROM          T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) 
                                                         GROUP BY Travel_Application_ID) AS Qry ON Qry.Rpt_Level = Tla.Rpt_Level AND Qry.Travel_Application_ID = Tla.Travel_Application_ID INNER JOIN
                                                   V0100_TRAVEL_APPLICATION LA WITH (NOLOCK)  ON la.Travel_Application_ID = Tla.Travel_Application_ID
                            WHERE      (Tla.Approval_Status = 'A' OR
                                                   Tla.Approval_Status = 'R')) AS qry ON LAD.Travel_Application_ID = qry.Travel_Application_ID




