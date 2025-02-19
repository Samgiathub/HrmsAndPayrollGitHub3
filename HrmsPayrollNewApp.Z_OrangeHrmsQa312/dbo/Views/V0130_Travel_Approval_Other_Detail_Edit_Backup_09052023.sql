




-- Created by Sumit on 01092015
Create VIEW [dbo].[V0130_Travel_Approval_Other_Detail_Edit_Backup_09052023]
AS
SELECT   TAD.Travel_Apr_Other_Detail_Id as Travel_App_Other_Detail_Id,TAD.Cmp_ID,TAD.Travel_Approval_ID as Travel_App_ID,TAD.Travel_Mode_Id,
CONVERT(VARCHAR(11),TAD.For_date,103) as For_date ,
right(convert(varchar,For_date),7) as From_Time,
TAD.Description,TAD.Amount,case when TAD.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay
,TAD.modify_Date
,TM.Travel_Mode_Name,
right(convert(varchar,To_date),7) as To_Time,To_date,isnull(TAD.curr_ID,0) as Curr_ID,isnull(Cm.Curr_Symbol,'') as Currency
,TM.GST_Applicable,TAD.SGST,TAD.CGST,TAD.IGST,TAD.GST_No,TAD.GST_Company_Name,TAM.TRAVEL_MODE
FROM dbo.T0130_TRAVEL_Approval_OTHER_DETAIL AS TAD WITH (NOLOCK) INNER JOIN
			dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID 
			left join T0040_CURRENCY_MASTER cm WITH (NOLOCK)  on Cm.Curr_ID=TAD.curr_ID
			left join T0130_Travel_Approval_Other_Mode_Detail TAM WITH (NOLOCK)  ON TAD.TRAVEL_APR_OTHER_DETAIL_ID = TAM.TRAVEL_APPROVAL_OTHER_DETAIL_ID AND TAD.TRAVEL_APPROVAL_ID = TAM.TRAVEL_APPROVAL_ID
			
			
			

