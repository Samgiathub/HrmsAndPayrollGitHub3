  
  
  
  
  
  
CREATE VIEW [dbo].[View_Travel_Settlement_Final_N_level_Approval_No_TravelType]  
AS  
SELECT distinct  LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Travel_Set_Application_ID,LAD.Travel_Application_ID,LAD.Branch_Name  
  ,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.For_date as Application_Date,LAD.For_Date as For_Date,LAD.Status,qry.Status As Application_Status  
  ,LAD.Travel_Set_Application_id as App_code,LAD.travel_approval_id,LAD.Emp_First_Name,LAD.Branch_ID,LAD.Cmp_Id  
        ,qry.manager_emp_id AS S_Emp_ID_A,LAD.Advance_Amount,qry.manager_emp_id as S_Emp_ID,LAD.Tran_ID as Tran_id,LAD.Travel_App_Code  
        ,qry.Approved_Expance as Approved_Expense  
        --,LAD.Rpt_Level  
        --,LAD.DirectEntry  
        ,LAD.Visited_Flag  
		,(select count(1) from T0080_Emp_Travel_Proof where TravelApp_Code=LAD.Travel_App_Code and Cmp_Id=Lad.Cmp_ID and Emp_ID=Lad.Emp_id ) as ProofCount    
FROM         V0140_Travel_Settlement_Application_New_Level_No_Travel_Type LAD WITH (NOLOCK)  
  
inner join  
                          (SELECT     Tla.Travel_Set_Application_id,Tla.Travel_Approval_ID,Tla.manager_emp_id,Tla.Status,  
         tla.Approved_Expance  
                            FROM          T0115_Travel_Settlement_Level_Approval Tla WITH (NOLOCK) INNER JOIN  
                                                       (SELECT     max(Rpt_Level) Rpt_Level, Travel_Approval_ID,Travel_Set_Application_id  
                                                         FROM          T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)  
                                                         GROUP BY Travel_Approval_ID,Travel_Set_Application_id) AS Qry ON Qry.Rpt_Level = Tla.Rpt_Level   
                                                         AND Qry.Travel_Set_Application_id = Tla.Travel_Set_Application_id INNER JOIN  
                                                   V0140_Travel_Settlement_Application_New_Level_No_Travel_Type LA WITH (NOLOCK) ON la.Travel_Approval_ID = Tla.Travel_Approval_ID  
                            WHERE      (Tla.status = 'A' OR  
                                                   Tla.Status = 'R')) AS qry ON LAD.Travel_Set_Application_id = qry.Travel_Set_Application_id  
 --INNER JOIN  
--(select max(rpt_level) as Rpt_Level,cmp_id from View_Travel_Settlement_Final_N_level_Approval  
--where Cmp_Id=qry.Cmp_ID and S_Emp_ID_A=qry.manager_emp_id  
  
--where cmp_id=LAD.CMp_ID and S_Emp_ID_A=LAD.S_Emp_ID_A --where Cmp_Id=55 and S_Emp_ID_A=2721  
--) as NL  
--on LAD.Rpt_Level =NL.Rpt_Level   
--and lad.cmp_id=nl.cmp_id --and LAD.S_Emp_ID_A=nl.S_Emp_ID_A    
  
  
  
  