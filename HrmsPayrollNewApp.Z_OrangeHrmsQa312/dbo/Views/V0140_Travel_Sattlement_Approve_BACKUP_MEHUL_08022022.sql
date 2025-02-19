









CREATE VIEW [dbo].[V0140_Travel_Sattlement_Approve_BACKUP_MEHUL_08022022]  
AS  
--SELECT       
--       TA.Travel_Approval_ID,
--       --TA.Approval_Date,
--       isnull(TRSA.Approval_date,TSA.For_date) as Approval_Date,
--       TSA.Comment as Approval_Comments,TA.Approval_Status,  
--       TA.Cmp_ID,TA.Emp_ID,TA.S_Emp_ID,TA.Travel_Application_ID,TA.Total  
--       ,EM.Emp_Full_Name,Em.Alpha_Emp_Code,ISNULL(SEM.Emp_Full_Name ,'')as S_Emp_full_Name  
--       ,ISNULL(EM.Emp_First_Name,'')AS Emp_First_Name,EM.Branch_ID  
--       ,  TSA.Travel_Set_Application_id as Travel_Set_Application_id
--        ,isnull(TSA.status,0) as status,TSA.Document
--          ,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit,
--          TRA.Application_Code as Travel_App_code
--          ,TRSA.Approval_date as Set_Approve_Date,Inc.Vertical_ID,Inc.SubVertical_ID,Inc.Dept_ID
--          ,isnull(TRA.Chk_International,0) as Is_Foreign
--          ,isnull(Inc.Desig_Id,0) as Desig_Id
--FROM         dbo.T0120_TRAVEL_APPROVAL as TA INNER JOIN  
--                      --dbo.T0130_TRAVEL_APPROVAL_DETAIL as TAD ON TA.Travel_Approval_ID = TAD .Travel_Approval_ID INNER JOIN  
--                      --dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL as TAAD ON TA.Travel_Approval_ID = TAAD.Travel_Approval_ID INNER JOIN  
--                      dbo.T0080_EMP_MASTER as EM ON TA.Emp_ID = EM.Emp_ID inner JOIN  
--                      dbo.T0095_INCREMENT Inc ON EM.Increment_ID = Inc.Increment_ID left JOIN  
--                      dbo.T0080_EMP_MASTER as SEM on TA.S_Emp_ID = SEM.Emp_ID  inner join
--                      T0140_Travel_Settlement_Application as TSA on TA.Travel_Approval_ID = TSA.Travel_Approval_ID
--                      left Join T0100_TRAVEL_APPLICATION TRA on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID
--                      left join T0150_Travel_Settlement_Approval TRSA on TRSA.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TRSA.emp_id=TSA.emp_id
                      --
  -- comment by deepal 31012022
  SELECT   
       isnull(TA.Travel_Approval_ID,0) as Travel_Approval_ID,
       --TA.Approval_Date,
       isnull(TRSA.Approval_date,TSA.For_date) as Approval_Date,
       TSA.Comment as Approval_Comments,isnull(TA.Approval_Status,'A') as Approval_Status,  
       TSA.Cmp_ID,isnull(TA.Emp_ID,TSA.emp_id) as Emp_ID,isnull(TA.S_Emp_ID,0) as S_Emp_ID,TA.Travel_Application_ID,isnull(TA.Total,0) as Total
       ,EM.Emp_Full_Name,Em.Alpha_Emp_Code,ISNULL(SEM.Emp_Full_Name ,'')as S_Emp_full_Name  
       ,ISNULL(EM.Emp_First_Name,'')AS Emp_First_Name,EM.Branch_ID  
       ,  TSA.Travel_Set_Application_id as Travel_Set_Application_id
        ,isnull(TSA.status,0) as status,TSA.Document
          ,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit,
          isnull(TRA.Application_Code,TSA.Travel_Set_Application_id) as Travel_App_code
          ,TRSA.Approval_date as Set_Approve_Date,Inc.Vertical_ID,Inc.SubVertical_ID,Inc.Dept_ID
          ,isnull(TRA.Chk_International,0) as Is_Foreign
          ,isnull(Inc.Desig_Id,0) as Desig_Id
          ,isnull(TSA.ODDates,0) as ODDates
          ,isnull(TSA.Visited_flag,0) as Visited_flag
          ,c.GST_No,TT.Travel_Type_Id,Travel_Type_Name
FROM        T0140_Travel_Settlement_Application as TSA WITH (NOLOCK) Left Join
 dbo.T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK)  on TA.Travel_Approval_ID = TSA.Travel_Approval_ID
  and TA.Emp_ID=TSA.emp_id
  INNER JOIN  
                      --dbo.T0130_TRAVEL_APPROVAL_DETAIL as TAD ON TA.Travel_Approval_ID = TAD .Travel_Approval_ID INNER JOIN  
                      --dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL as TAAD ON TA.Travel_Approval_ID = TAAD.Travel_Approval_ID INNER JOIN  
                      dbo.T0080_EMP_MASTER as EM WITH (NOLOCK)  ON TSA.Emp_ID = EM.Emp_ID inner JOIN  
                      dbo.T0095_INCREMENT Inc WITH (NOLOCK)  ON EM.Increment_ID = Inc.Increment_ID left JOIN  
                      dbo.T0080_EMP_MASTER as SEM WITH (NOLOCK)  on TA.S_Emp_ID = SEM.Emp_ID  ---inner join
              
                      left Join T0100_TRAVEL_APPLICATION TRA WITH (NOLOCK)  on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID
					  inner Join T0110_TRAVEL_APPLICATION_DETAIL TRAD WITH (NOLOCK)  on TRA.Travel_Application_ID = Trad.Travel_App_ID
					  LEft Join T0040_Travel_Type TT WITH (NOLOCK)  on TRAD.TravelTypeId= TT.Travel_Type_Id
                      left join T0150_Travel_Settlement_Approval TRSA WITH (NOLOCK)  on TRSA.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TRSA.emp_id=TSA.emp_id
                      INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = Inc.Cmp_ID
                      -- END by



