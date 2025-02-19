      
      
      
      
      
      
CREATE VIEW [dbo].[V0130_TRAVEL_APPROVAL_DETAIL_EDIT]      
AS      
SELECT  distinct   TA.Travel_Application_ID, TA.Application_Date, TA.Application_Code, TA.Emp_ID, EM.Emp_Full_Name, isnull(TA.S_Emp_ID,0) as S_Emp_ID , SEMP.Emp_Full_Name AS Supervisor,       
                      TAD.Travel_Approval_Detail_ID as Travel_App_Detail_ID, TAD.Place_Of_Visit, TAD.Travel_Purpose, TAD.Instruct_Emp_ID,       
                      IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name, TAD.Travel_Mode_ID, TM.Travel_Mode_Name, TAD.From_Date, TAD.Period,       
                      TAD.To_Date, TAD.Remarks, dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_ID,       
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name      
                      ,TAD.Leave_ID as Leave_id,'' as Leave_name,TA.Cmp_ID      
       --Changes made by Yogseh to resolvel Ticket #24059 on 30012023      
       --               ,isnull(TDL.chk_Adv,TA.chk_Adv)as chk_Adv      
       --,isnull(TDL.chk_Agenda,TA.chk_Agenda)as chk_Agenda      
       --,isnull(TDL.Tour_Agenda,TA.Tour_Agenda)as Tour_Agenda      
       --,isnull(TDL.IMP_Business_Appoint,TA.IMP_Business_Appoint) as IMP_Business_Appoint      
       --,isnull(TDL.KRA_Tour,TA.KRA_Tour)as KRA_Tour      
       --,isnull(TDL.Attached_Doc_File,TA.Attached_Doc_File )as Attached_Doc_File      
      
       ,isnull(TDL.chk_Adv,0)as chk_Adv--,TA.chk_Adv)as chk_Adv      
       ,TDL.chk_Agenda--,TA.chk_Agenda)as chk_Agenda      
       ,TDL.Tour_Agenda--,TA.Tour_Agenda)as Tour_Agenda      
       ,TDL.IMP_Business_Appoint--,TA.IMP_Business_Appoint) as IMP_Business_Appoint      
       ,TDL.KRA_Tour--,TA.KRA_Tour)as KRA_Tour      
       ,TDL.Attached_Doc_File--,TA.Attached_Doc_File )as Attached_Doc_File      
       --Changes made by Yogseh to resolvel Ticket #24059 on 30012023      
     ,isnull(TAD.From_State_id,0)as From_State_ID  
       ,isnull(TAD.From_City_id,0) as From_City_ID  
       ,fSm.State_Name as 'From_State'  
       ,fcm.City_Name as 'From_City'   
       ,isnull(TAD.State_ID,0)as State_ID  
       ,isnull(TAD.City_ID,0) as City_ID  
       ,Sm.State_Name as State  
       ,cm.City_Name as City   
         
                      ,lM.Loc_name,isnull(tad.loc_ID,0) as Loc_ID,isnull(tad.loc_ID,0) as chk_International      
                      ,isnull(TAD.Project_ID,0) as Project_ID,ISNULL(pmp.Project_Name,'') as Project_Name,isnull(pmp.Site_ID,'') as Site_ID      
                      ,ISNULL(TAP.Approval_Comments,'') as Comments,      
                      TAD.Half_Leave_Date,TAD.LeaveType,TAD.Night_Day,C.GST_No      
        ,isnull(TT.Travel_Type_Name , '') as Travel_Type_Name,isnull(tt.Travel_Type_Id,0) as Travel_Type_Id      
        ,RM.Res_Id,Rm.Reason_Name      
FROM          
     dbo.T0130_TRAVEL_APPROVAL_DETAIL AS TAD WITH (NOLOCK) INNER JOIN      
       dbo.T0120_TRAVEL_APPROVAL TAP WITH (NOLOCK)  on TAP.Travel_Approval_ID=TAD.Travel_Approval_ID and TAP.Cmp_ID=TAD.Cmp_ID      
       LEFT join      
                      dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK)  ON TAP.Travel_Application_ID = TA.Travel_Application_ID left JOIN      
       dbo.T0110_TRAVEL_APPLICATION_DETAIL AS TADD WITH (NOLOCK)  on TADD.Travel_App_ID = TA.Travel_Application_ID left JOIN      
         T0040_Travel_Type TT With (Nolock) on  Tt.Travel_Type_Id = TADD.TravelTypeId  left JOIN      
                      dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID INNER JOIN      
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID INNER JOIN      
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON EM.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN      
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON EM.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN      
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN      
                      dbo.T0080_EMP_MASTER AS IEMP WITH (NOLOCK)  ON TAD.Instruct_Emp_ID = IEMP.Emp_ID left outer join      
                      dbo.T0020_STATE_MASTER sm WITH (NOLOCK)  on sm.State_ID=TAD.state_ID left outer join      
                      dbo.T0030_CITY_MASTER cm WITH (NOLOCK)  on cm.City_ID=TAD.City_ID left join      
        dbo.T0020_STATE_MASTER fsm WITH (NOLOCK)  on fsm.State_ID=TAD.From_State_id left outer join      
                      dbo.T0030_CITY_MASTER fcm WITH (NOLOCK)  on fcm.City_ID=TAD.From_City_id left join     
             dbo.T0001_LOCATION_MASTER Lm  WITH (NOLOCK) on Lm.Loc_ID=tad.loC_id left join      
                      dbo.T0050_Project_Master_Payroll pmp WITH (NOLOCK)  on pmp.Tran_Id=tad.project_ID INNER JOIN      
                      T0010_COMPANY_MASTER C WITH (NOLOCK)  ON C.Cmp_Id = TAD.Cmp_ID left join      
       V0115_TRAVEL_APPLICATION_DETAIL_LEVEL TDL on TDL.Travel_Application_ID=TA.Travel_Application_ID -- --Changes made by Yogseh to resolvel Ticket #24059 on 30012023      
       left join T0040_Reason_Master RM With (NOLOCK) on rm.Res_Id=TAD.Reason_ID 