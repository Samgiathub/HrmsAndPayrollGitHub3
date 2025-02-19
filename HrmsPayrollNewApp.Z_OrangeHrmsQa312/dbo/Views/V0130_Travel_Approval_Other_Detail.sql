


-- Created by rohit on 11-jun-2014
CREATE VIEW [dbo].[V0130_Travel_Approval_Other_Detail]
AS
SELECT    

TAD.Travel_Apr_Other_Detail_Id,TAD.Cmp_ID,TAD.Travel_Approval_ID,TAD.Travel_Mode_Id,
CONVERT(VARCHAR(11),TAD.For_date,103) as For_date ,
right(convert(varchar,For_date),7) as From_Time,
TAD.Description,TAD.Amount,case when TAD.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay
,TAD.modify_Date
,TM.Travel_Mode_Name,TRA.Application_Code as Travel_App_Code
FROM dbo.T0130_Travel_Approval_Other_Detail AS TAD WITH (NOLOCK) INNER JOIN
			dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID
left join T0120_Travel_Approval TA WITH (NOLOCK)  on TA.Travel_Approval_ID=TAD.Travel_Approval_ID			 
left Join T0100_TRAVEL_APPLICATION TRA WITH (NOLOCK)  on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID




