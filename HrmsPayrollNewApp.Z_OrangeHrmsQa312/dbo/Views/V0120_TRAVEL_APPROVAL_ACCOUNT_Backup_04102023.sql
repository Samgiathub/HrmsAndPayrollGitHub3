





------------Created by Sumit for Getting Advance Amount Detail 07082015--------------------------------------------
Create VIEW [dbo].[V0120_TRAVEL_APPROVAL_ACCOUNT_Backup_04102023]
AS
SELECT   distinct  EM.Alpha_Emp_Code, TAPR.Travel_Approval_ID, TAPR.Cmp_ID, TAPR.Emp_ID, dbo.T0100_TRAVEL_APPLICATION.Application_Code, 
                      dbo.T0100_TRAVEL_APPLICATION.Application_Date, SEMP.Emp_Full_Name AS Supervisor, EM.Emp_Full_Name, TAPR.Approval_Date, TAPR.Approval_Status, 
                      TAPR.Approval_Comments,
                      
                      T0100_TRAVEL_APPLICATION.Travel_Application_ID, 
                      LTRIM(RTRIM(isnull(TAPR.Approved_Account_Advance_desk,'P'))) as Application_Status,  
                      BM.Branch_Name, BM.Branch_ID
                     ,ISNULL(TSA.Travel_Set_Application_id,0) as travel_set_Application_id
                     ,ISNULL(TAPR.Total,0) as Adv_Amount,em.Vertical_ID,em.SubVertical_ID,em.Dept_ID                     
                      
FROM         dbo.T0120_TRAVEL_APPROVAL AS TAPR WITH (NOLOCK) INNER JOIN
					  T0130_TRAVEL_APPROVAL_ADVDETAIL Adv WITH (NOLOCK)  on TAPR.Travel_Approval_ID=Adv.Travel_Approval_ID inner join
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TAPR.Emp_ID = EM.Emp_ID INNER JOIN
                      dbo.T0100_TRAVEL_APPLICATION WITH (NOLOCK)  ON TAPR.Travel_Application_ID = dbo.T0100_TRAVEL_APPLICATION.Travel_Application_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TAPR.S_Emp_ID = SEMP.Emp_ID inner join 
                       -- Added By Yogesh on 17082023 for to Get latest Branch name Start
					   dbo.T0095_INCREMENT AS IM WITH (NOLOCK)  ON TAPR.Emp_ID = IM.Emp_ID 
					   and IM.Increment_Effective_Date=(select Max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=EM.Emp_ID) 
					   INNER JOIN
					     
                      T0030_BRANCH_MASTER BM WITH (NOLOCK)  on IM.Branch_ID = BM.Branch_ID left join
					  -- Added By Yogesh on 17082023 for to Get latest Branch name End
					  	
                      T0140_Travel_Settlement_Application as TSA WITH (NOLOCK)  ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID




