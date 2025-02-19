

  
CREATE VIEW [dbo].[V0140_Travel_Sattlement_Detail]              
AS              
--SELECT distinct                    
--       TA.Travel_Approval_ID,TA.Approval_Date,TA.Approval_Comments,TA.Approval_Status,              
--       TA.Cmp_ID,TA.Emp_ID,TA.S_Emp_ID,TA.Travel_Application_ID,TA.Total              
--       ,EM.Emp_Full_Name,Em.Alpha_Emp_Code,SEM.Emp_Full_Name as S_Emp_full_Name              
--       ,EM.Emp_First_Name,EM.Branch_ID              
--       ,TAD.From_Date,TAD.Instruct_Emp_ID,tad.Period,tad.Place_Of_Visit,tad.Remarks,tad.To_Date,tad.Travel_Approval_Detail_ID,tad.Travel_Mode_ID,tad.Travel_Purpose              
--       ,tmm.Travel_Mode_Name  
--     ,isnull(TAD.From_State_ID,0)as From_State_ID  
--    ,isnull(TAD.From_City_ID,0) as From_City_ID          
--    ,FCm.City_Name as From_City  
-- ,Fsm.State_Name as From_State  
--    ,isnull(TAD.State_ID,0)as State_ID  
--    ,isnull(TAD.City_ID,0) as City_ID              
--    ,Cm.City_Name as City  
-- ,sm.State_Name as State  
-- ,TRA.Application_Code as Travel_App_Code              
--       ,Lm.Loc_Name,isnull(TAD.Loc_ID,0) as Loc_ID,TRA.Tour_Agenda,TRA.IMP_Business_Appoint,TRA.KRA_Tour              
--    ,TT.Travel_Type_Name,TT.Travel_Type_Id,RM.Reason_Name as Reason_Name           
--FROM         dbo.T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK) INNER JOIN              
--                      dbo.T0130_TRAVEL_APPROVAL_DETAIL as TAD WITH (NOLOCK)  ON TA.Travel_Approval_ID = TAD .Travel_Approval_ID INNER JOIN              
                     
--                      --dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL as TAAD ON TA.Travel_Approval_ID = TAAD.Travel_Approval_ID INNER JOIN              
--                      dbo.T0080_EMP_MASTER as EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID left JOIN              
--                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON EM.Increment_ID = dbo.T0095_INCREMENT.Increment_ID left JOIN              
--                      dbo.T0080_EMP_MASTER as SEM  WITH (NOLOCK) on TA.S_Emp_ID = SEM.Emp_ID left JOIN              
--       dbo.T0130_TRAVEL_Approval_OTHER_DETAIL as TAOD with (NoLOCK) on TAOD.Travel_Approval_ID=tad.Travel_Approval_ID-- added by Yogesh              
--       left join              
--       dbo.T0030_TRAVEL_MODE_MASTER as TMM  WITH (NOLOCK) on tad.Travel_Mode_ID = TMM.Mode_Type and taod.Mode_Id=tmm.Travel_Mode_ID              
                     
--       left outer join T0020_STATE_MASTER sm  WITH (NOLOCK) on sm.State_ID=TAD.state_ID and sm.Cmp_ID=TAD.Cmp_ID              
--       left outer join T0030_CITY_MASTER cm  WITH (NOLOCK) on cm.City_ID=TAD.City_ID and cm.Cmp_ID=TAD.Cmp_ID    
--     left outer join T0020_STATE_MASTER fsm  WITH (NOLOCK) on fsm.State_ID=TAD.From_state_ID and sm.Cmp_ID=TAD.Cmp_ID          
--       left outer join T0030_CITY_MASTER fcm  WITH (NOLOCK) on fcm.City_ID=TAD.From_City_ID and cm.Cmp_ID=TAD.Cmp_ID          
--       left Join T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID              
--       inner join T0110_TRAVEL_APPLICATION_DETAIL TD With (Nolock) on TRA.Travel_Application_ID = TD.Travel_App_ID              
--       inner join T0040_Travel_Type TT With (NOLOCK) on TD.TravelTypeId = TT.Travel_Type_Id              
--       left join T0001_LOCATION_MASTER Lm  WITH (NOLOCK) on Lm.Loc_ID=TAD.Loc_ID              
--  left join T0040_Reason_Master RM With (NOLOCK) on RM.Res_Id=TAD.Reason_ID          
      
SELECT  Distinct                 
       TA.Travel_Approval_ID,TA.Approval_Date,TA.Approval_Comments,TA.Approval_Status,            
       TA.Cmp_ID,TA.Emp_ID,TA.S_Emp_ID,TA.Travel_Application_ID,TA.Total            
       ,EM.Emp_Full_Name,Em.Alpha_Emp_Code,SEM.Emp_Full_Name as S_Emp_full_Name            
       ,EM.Emp_First_Name,EM.Branch_ID            
       ,TAD.From_Date,TAD.Instruct_Emp_ID,tad.Period,tad.Place_Of_Visit,tad.Remarks,tad.To_Date,tad.Travel_Approval_Detail_ID,tad.Travel_Mode_ID,tad.Travel_Purpose            
       ,tmm.Travel_Mode_Name
	    ,isnull(TAD.From_State_ID,0)as From_State_ID  
	    ,isnull(TAD.From_City_ID,0) as From_City_ID 
		  ,FCm.City_Name as From_City  
		 ,Fsm.State_Name as From_State
	   ,isnull(TAD.State_ID,0)as State_ID,isnull(TAD.City_ID,0) as City_ID            
    ,Cm.City_Name as City,sm.State_Name as State,TRA.Application_Code as Travel_App_Code            
       ,Lm.Loc_Name,isnull(TAD.Loc_ID,0) as Loc_ID,TRA.Tour_Agenda,TRA.IMP_Business_Appoint,TRA.KRA_Tour            
    ,TT.Travel_Type_Name,TT.Travel_Type_Id ,rm.Reason_Name         
FROM         dbo.T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK) INNER JOIN        
                      dbo.T0130_TRAVEL_APPROVAL_DETAIL as TAD WITH (NOLOCK)  ON TA.Travel_Approval_ID = TAD .Travel_Approval_ID INNER JOIN            
                      --dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL as TAAD ON TA.Travel_Approval_ID = TAAD.Travel_Approval_ID INNER JOIN            
                      dbo.T0080_EMP_MASTER as EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID left JOIN            
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON EM.Increment_ID = dbo.T0095_INCREMENT.Increment_ID left JOIN            
                      dbo.T0080_EMP_MASTER as SEM  WITH (NOLOCK) on TA.S_Emp_ID = SEM.Emp_ID left JOIN            
       dbo.T0030_TRAVEL_MODE_MASTER as TMM  WITH (NOLOCK) on tad.Travel_Mode_ID = TMM.Travel_Mode_ID            
       left outer join T0020_STATE_MASTER sm  WITH (NOLOCK) on sm.State_ID=TAD.state_ID and sm.Cmp_ID=TAD.Cmp_ID            
       left outer join T0030_CITY_MASTER cm  WITH (NOLOCK) on cm.City_ID=TAD.City_ID and cm.Cmp_ID=TAD.Cmp_ID            
	    left outer join T0020_STATE_MASTER fsm  WITH (NOLOCK) on fsm.State_ID=TAD.From_state_ID and sm.Cmp_ID=TAD.Cmp_ID          
       left outer join T0030_CITY_MASTER fcm  WITH (NOLOCK) on fcm.City_ID=TAD.From_City_ID and cm.Cmp_ID=TAD.Cmp_ID 
       left Join T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID            
       inner join T0110_TRAVEL_APPLICATION_DETAIL TD With (Nolock) on TRA.Travel_Application_ID = TD.Travel_App_ID            
       left join T0040_Travel_Type TT With (NOLOCK) on TD.TravelTypeId = TT.Travel_Type_Id            
       left join T0001_LOCATION_MASTER Lm  WITH (NOLOCK) on Lm.Loc_ID=TAD.Loc_ID            
    left join T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=tad.Reason_ID            
      where TD.TravelTypeId=0 or TD.TravelTypeId=Null             
