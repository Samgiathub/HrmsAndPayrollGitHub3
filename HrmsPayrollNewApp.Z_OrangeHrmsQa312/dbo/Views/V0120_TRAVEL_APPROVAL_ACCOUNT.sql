    
    
          
CREATE VIEW [dbo].[V0120_TRAVEL_APPROVAL_ACCOUNT]          
AS          
SELECT   distinct  EM.Alpha_Emp_Code, TAPR.Travel_Approval_ID, TAPR.Cmp_ID, TAPR.Emp_ID, dbo.T0100_TRAVEL_APPLICATION.Application_Code,           
                      dbo.T0100_TRAVEL_APPLICATION.Application_Date, SEMP.Emp_Full_Name AS Supervisor, EM.Emp_Full_Name, TAPR.Approval_Date, TAPR.Approval_Status,           
                      TAPR.Approval_Comments,          
                                
                      T0100_TRAVEL_APPLICATION.Travel_Application_ID,           
                      LTRIM(RTRIM(isnull(TAPR.Approved_Account_Advance_desk,'P'))) as Application_Status,            
                      BM.Branch_Name, BM.Branch_ID          
                     ,ISNULL(TSA.Travel_Set_Application_id,0) as travel_set_Application_id          
                     ,ISNULL(TAPR.Total,0) as Adv_Amount,em.Vertical_ID,em.SubVertical_ID,em.Dept_ID           
      ,'' as Reason_Name          
                                
FROM         dbo.T0120_TRAVEL_APPROVAL AS TAPR WITH (NOLOCK) INNER JOIN          
       T0130_TRAVEL_APPROVAL_ADVDETAIL Adv WITH (NOLOCK)  on TAPR.Travel_Approval_ID=Adv.Travel_Approval_ID inner join          
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TAPR.Emp_ID = EM.Emp_ID INNER JOIN          
                      dbo.T0100_TRAVEL_APPLICATION WITH (NOLOCK)  ON TAPR.Travel_Application_ID = dbo.T0100_TRAVEL_APPLICATION.Travel_Application_ID LEFT OUTER JOIN          
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TAPR.S_Emp_ID = SEMP.Emp_ID inner join           
                      T0030_BRANCH_MASTER BM WITH (NOLOCK)  on EM.Branch_ID = BM.Branch_ID left join          
                  
                      T0140_Travel_Settlement_Application as TSA WITH (NOLOCK)  ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID          
      left join T0110_TRAVEL_APPLICATION_DETAIL TRD with (NOLOCK) on Trd.Travel_app_id=TAPR.travel_Application_id   
   left join T0130_TRAVEL_APPROVAL_DETAIL TPRD with (NOLOCK) on TPrd.Travel_Approval_ID=TAPR.Travel_Approval_ID   
     
      left join T0040_Reason_Master RM WITH (NOLOCK) on rm.Res_Id=TPrd.Reason_ID          
                 