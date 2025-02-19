                
                
                
                
                
                
                
                
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
CREATE VIEW [dbo].[V0140_Travel_Sattlement_No_TravelType]                        
AS                        
--SELECT                             
--       TA.Travel_Approval_ID,TA.Approval_Date,TA.Approval_Comments,TA.Approval_Status,                        
--       TA.Cmp_ID,TA.Emp_ID,TA.S_Emp_ID,TA.Travel_Application_ID,TA.Total                        
--       ,EM.Emp_Full_Name,Em.Alpha_Emp_Code,ISNULL(SEM.Emp_Full_Name ,'')as S_Emp_full_Name                        
--       ,ISNULL(EM.Emp_First_Name,'')AS Emp_First_Name,EM.Branch_ID                        
--        ,0 as Travel_Set_Application_id                      
--        ,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit                      
--        ,TRA.Application_Code as Travel_App_Code,inc.Vertical_ID,inc.SubVertical_ID,inc.Dept_ID                      
--        ,isnull(TRA.Chk_International,0) as Is_Foreign                      
--        ,isnull(Inc.Desig_Id,0) as Desig_Id                      
--        ,C.GST_No                      
--FROM         dbo.T0120_TRAVEL_APPROVAL as TA INNER JOIN                        
----dbo.T0130_TRAVEL_APPROVAL_DETAIL as TAD ON TA.Travel_Approval_ID = TAD .Travel_Approval_ID INNER JOIN                        
----dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL as TAAD ON TA.Travel_Approval_ID = TAAD.Travel_Approval_ID INNER JOIN                        
--                      dbo.T0080_EMP_MASTER as EM ON TA.Emp_ID = EM.Emp_ID inner JOIN                        
--                      dbo.T0095_INCREMENT Inc ON EM.Increment_ID = Inc.Increment_ID left JOIN                        
--                      dbo.T0080_EMP_MASTER as SEM on TA.S_Emp_ID = SEM.Emp_ID                        
--                      left Join T0100_TRAVEL_APPLICATION TRA on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID                      
--                      INNER JOIN T0010_COMPANY_MASTER C ON C.Cmp_Id = Inc.Cmp_ID                      
--where TA.Travel_Approval_ID not in (select Travel_Approval_ID from T0140_Travel_Settlement_Application )                        
                       
  SELECT Distinct TA.TRAVEL_APPROVAL_ID,TA.APPROVAL_DATE,TA.APPROVAL_COMMENTS,TA.APPROVAL_STATUS,                        
  --TA.CMP_ID,TA.EMP_ID,TA.S_EMP_ID,TA.TRAVEL_APPLICATION_ID,case when ta.Approved_Account_Advance_desk<>'A' then isnull(TA.TOTAL,0) else isnull(adv.Amount,0) end as TOTAL,                    
  TA.CMP_ID,TA.EMP_ID,TA.S_EMP_ID,TA.TRAVEL_APPLICATION_ID,case when ta.Approved_Account_Advance_desk='A' then isnull(TA.TOTAL,0)  end as TOTAL,                      
  EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,ISNULL(SEM.EMP_FULL_NAME ,'')AS S_EMP_FULL_NAME ,ISNULL(EM.EMP_FIRST_NAME,'')AS EMP_FIRST_NAME,EM.BRANCH_ID                        
        ,0 as Travel_Set_Application_id,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit                      
        ,TRA.Application_Code as Travel_App_Code,inc.Vertical_ID,inc.SubVertical_ID,inc.Dept_ID                      
        ,isnull(TRA.Chk_International,0) as Is_Foreign                      
        ,isnull(Inc.Desig_Id,0) as Desig_Id                      
        ,C.GST_No,TT.Travel_Type_Name,TT.Travel_Type_Id                      
  ,'' as Reason_Name                    
FROM         dbo.T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK) INNER JOIN                        
                      dbo.T0080_EMP_MASTER as EM  WITH (NOLOCK) ON TA.Emp_ID = EM.Emp_ID inner JOIN                        
                      dbo.T0095_INCREMENT Inc  WITH (NOLOCK) ON EM.Increment_ID = Inc.Increment_ID left JOIN                        
                      dbo.T0080_EMP_MASTER as SEM  WITH (NOLOCK) on TA.S_Emp_ID = SEM.Emp_ID       
                      left Join T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID                      
       inner join T0110_TRAVEL_APPLICATION_DETAIL TAD With (Nolock) on TRA.Travel_Application_ID = TAD.Travel_App_ID                      
      left join T0040_Travel_Type TT With (NOLOCK) on TAD.TravelTypeId = TT.Travel_Type_Id           
          inner join T0130_TRAVEL_APPROVAL_DETAIL TAPD With (Nolock) on TA.Travel_Approval_ID = TApD.Travel_Approval_ID                      
          
                      INNER JOIN T0010_COMPANY_MASTER C  WITH (NOLOCK) ON C.Cmp_Id = Inc.Cmp_ID                      
       left join T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=TAPD.Reason_ID                    
    left join T0130_TRAVEL_APPROVAL_ADVDETAIL ADV WITH(NOLOCK) on adv.Travel_Approval_ID=ta.Travel_Approval_ID                
where TA.Travel_Approval_ID not in (select Travel_Approval_ID from T0140_Travel_Settlement_Application WITH (NOLOCK)  )  and TAD.TravelTypeId=0 or TAD.TravelTypeId=Null                      
                      
                      
UNION ALL                      
                      
                      
SELECT Distinct ISNULL(TA.TRAVEL_APPROVAL_ID,0) AS TRAVEL_APPROVAL_ID,ISNULL(TRSA.APPROVAL_DATE,TSA.FOR_DATE) AS APPROVAL_DATE,TSA.COMMENT AS APPROVAL_COMMENTS,'Draft' AS APPROVAL_STATUS,                        
  --TSA.CMP_ID,ISNULL(TA.EMP_ID,TSA.EMP_ID) AS EMP_ID,ISNULL(TA.S_EMP_ID,0) AS S_EMP_ID,TA.TRAVEL_APPLICATION_ID,case when ta.Approved_Account_Advance_desk<>'A' then isnull(TA.TOTAL,0) else isnull(adv.Amount,0) end as TOTAL,                    
  TSA.CMP_ID,ISNULL(TA.EMP_ID,TSA.EMP_ID) AS EMP_ID,ISNULL(TA.S_EMP_ID,0) AS S_EMP_ID,TA.TRAVEL_APPLICATION_ID,case when ta.Approved_Account_Advance_desk='A' then isnull(TA.TOTAL,0)  end as TOTAL,                      
  EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,ISNULL(SEM.EMP_FULL_NAME ,'')AS S_EMP_FULL_NAME,ISNULL(EM.EMP_FIRST_NAME,'')AS EMP_FIRST_NAME,EM.BRANCH_ID,                      
  TSA.TRAVEL_SET_APPLICATION_ID AS TRAVEL_SET_APPLICATION_ID,DBO.F_GET_EMP_VISIT(TA.CMP_ID,TA.TRAVEL_APPLICATION_ID,0) AS EMP_VISIT,                      
  --(TSA.TRAVEL_SET_APPLICATION_ID) AS TRAVEL_APP_CODE,INC.VERTICAL_ID,INC.SUBVERTICAL_ID,INC.DEPT_ID,ISNULL(TRA.CHK_INTERNATIONAL,0) AS IS_FOREIGN,                      
  -- Change From TSA.TRAVEL_SET_APPLICATION_ID to TRA.Application_Code by Yogesh patel on 28-07-2022 to resolve issue in travel sattlement appcode change to travel sattlement id after drafting the application                      
  -----------------------------------------------------------------------------------------------------------------------------------------                      
  (TRA.Application_Code) AS TRAVEL_APP_CODE,INC.VERTICAL_ID,INC.SUBVERTICAL_ID,INC.DEPT_ID,ISNULL(TRA.CHK_INTERNATIONAL,0) AS IS_FOREIGN,                      
  -----------------------------------------------------------------------------------------------------------------------------------------                      
  ISNULL(INC.DESIG_ID,0) AS DESIG_ID,C.GST_NO,TT.Travel_Type_Name,TT.Travel_Type_Id                      
  --,RM.Reason_Name AS Reason_Name                    
  ,'' AS Reason_Name                    
                        
  --ISNULL(TSA.STATUS,0) AS STATUS,TSA.DOCUMENT,ISNULL(TRA.APPLICATION_CODE,TRSA.APPROVAL_DATE AS SET_APPROVE_DATE,                      
  --ISNULL(TSA.ODDATES,0) AS ODDATES,ISNULL(TSA.VISITED_FLAG,0) AS VISITED_FLAG,                      
                        
FROM    T0140_TRAVEL_SETTLEMENT_APPLICATION AS TSA  WITH (NOLOCK) LEFT JOIN                      
  DBO.T0120_TRAVEL_APPROVAL AS TA  WITH (NOLOCK) ON TA.TRAVEL_APPROVAL_ID = TSA.TRAVEL_APPROVAL_ID AND TA.EMP_ID=TSA.EMP_ID                      
  INNER JOIN  DBO.T0080_EMP_MASTER AS EM  WITH (NOLOCK) ON TSA.EMP_ID = EM.EMP_ID                       
  INNER JOIN  DBO.T0095_INCREMENT INC  WITH (NOLOCK) ON EM.INCREMENT_ID = INC.INCREMENT_ID                       
  LEFT JOIN   DBO.T0080_EMP_MASTER AS SEM  WITH (NOLOCK) ON TA.S_EMP_ID = SEM.EMP_ID                      
  LEFT JOIN T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) ON TRA.EMP_ID=TA.EMP_ID AND TRA.TRAVEL_APPLICATION_ID=TA.TRAVEL_APPLICATION_ID                      
  inner join T0110_TRAVEL_APPLICATION_DETAIL TAD With (Nolock) on TRA.Travel_Application_ID = TAD.Travel_App_ID                      
  left join T0040_Travel_Type TT With (NOLOCK) on TAD.TravelTypeId = TT.Travel_Type_Id                 
   inner join T0130_TRAVEL_APPROVAL_DETAIL TAPD With (Nolock) on TA.Travel_Approval_ID = TAPD.Travel_Approval_ID              
  LEFT JOIN T0150_TRAVEL_SETTLEMENT_APPROVAL TRSA  WITH (NOLOCK) ON TRSA.TRAVEL_SET_APPLICATION_ID=TSA.TRAVEL_SET_APPLICATION_ID AND TRSA.EMP_ID=TSA.EMP_ID                      
        INNER JOIN T0010_COMPANY_MASTER C  WITH (NOLOCK) ON C.CMP_ID = INC.CMP_ID                      
  left join T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=TAPD.Reason_ID                 
  left join T0130_TRAVEL_APPROVAL_ADVDETAIL ADV WITH(NOLOCK) on adv.Travel_Approval_ID=ta.Travel_Approval_ID                
                  
  WHERE   TAD.TravelTypeId=0 or TAD.TravelTypeId=Null   --TSA.STATUS='D'                   
--      SELECT Distinct TA.TRAVEL_APPROVAL_ID,TA.APPROVAL_DATE,TA.APPROVAL_COMMENTS                
-- ,Case When tsl.Travel_Approval_Id is null then TA.APPROVAL_STATUS else 'D'end as APPROVAL_STATUS                
                
-- ,TA.CMP_ID,TA.EMP_ID,TA.S_EMP_ID,TA.TRAVEL_APPLICATION_ID,case when ta.Approved_Account_Advance_desk<>'A' then TA.TOTAL else adv.Amount end as TOTAL,                      
--  EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,ISNULL(SEM.EMP_FULL_NAME ,'')AS S_EMP_FULL_NAME ,ISNULL(EM.EMP_FIRST_NAME,'')AS EMP_FIRST_NAME,EM.BRANCH_ID                        
--        ,0 as Travel_Set_Application_id,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit                      
--        ,TRA.Application_Code as Travel_App_Code,inc.Vertical_ID,inc.SubVertical_ID,inc.Dept_ID                      
--        ,isnull(TRA.Chk_International,0) as Is_Foreign                      
--        ,isnull(Inc.Desig_Id,0) as Desig_Id                      
--        ,C.GST_No,TT.Travel_Type_Name,TT.Travel_Type_Id                      
--  ,Rm.Reason_Name as Reason_Name                    
--FROM         dbo.T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK) INNER JOIN                        
--                      dbo.T0080_EMP_MASTER as EM  WITH (NOLOCK) ON TA.Emp_ID = EM.Emp_ID inner JOIN                        
--                      dbo.T0095_INCREMENT Inc  WITH (NOLOCK) ON EM.Increment_ID = Inc.Increment_ID left JOIN                        
--                      dbo.T0080_EMP_MASTER as SEM  WITH (NOLOCK) on TA.S_Emp_ID = SEM.Emp_ID                        
--                      left Join T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID                      
--       inner join T0110_TRAVEL_APPLICATION_DETAIL TAD With (Nolock) on TRA.Travel_Application_ID = TAD.Travel_App_ID                      
--      left join T0040_Travel_Type TT With (NOLOCK) on TAD.TravelTypeId = TT.Travel_Type_Id                      
--                      INNER JOIN T0010_COMPANY_MASTER C  WITH (NOLOCK) ON C.Cmp_Id = Inc.Cmp_ID                      
--       left join T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=TAD.Reason_ID                    
--    left join T0110_TRAVEL_ADVANCE_DETAIL ADV WITH(NOLOCK) on adv.Travel_App_ID=tra.Travel_Application_ID                
--    left join T0115_Travel_Settlement_Level_Expense TSL WITH(NOLOCK) on tsl.Travel_Approval_Id=ta.Travel_Approval_ID                
--where TA.Travel_Approval_ID not in (select Travel_Approval_ID from T0140_Travel_Settlement_Application WITH (NOLOCK)  )  and TAD.TravelTypeId=0 or TAD.TravelTypeId=Null 