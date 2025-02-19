


CREATE VIEW [dbo].[V0110_Travel_Approval_Other_Detail]
AS
--SELECT
--TAD.Travel_App_Other_Detail_Id,TAD.Cmp_ID,TAD.Travel_App_ID,TAD.Travel_Mode_Id,
--CONVERT(VARCHAR(11),TAD.For_date,103) as For_date ,
--right(convert(varchar,For_date),7) as From_Time,
--TAD.Description,TAD.Amount,case when TAD.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay
--,TAD.modify_Date
--,TM.Travel_Mode_Name
--FROM dbo.T0110_Travel_Application_Other_Detail AS TAD INNER JOIN
--			dbo.T0030_TRAVEL_MODE_MASTER AS TM ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID 
SELECT    

TAD.Travel_Apr_Other_Detail_Id,TAD.Cmp_ID,TAD.Travel_Approval_ID,TAD.Travel_Mode_Id,
CONVERT(VARCHAR(11),TAD.For_date,103) as For_date ,
right(convert(varchar,For_date),7) as From_Time,
TAD.Description,TAD.Amount,case when TAD.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay
,TAD.modify_Date
,TM.Travel_Mode_Name
FROM dbo.T0130_Travel_Approval_Other_Detail AS TAD WITH (NOLOCK) INNER JOIN
			dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID 




