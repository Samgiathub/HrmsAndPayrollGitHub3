

  
  
  
  
  
  
  
-- Created by Sumit on 01092015  
Create VIEW [dbo].[V0130_Travel_Approval_Other_Detail_Edit_19042024]  
AS  
SELECT   Distinct TAD.Travel_Apr_Other_Detail_Id as Travel_App_Other_Detail_Id,TAD.Cmp_ID,TAD.Travel_Approval_ID as Travel_App_ID,TAD.Travel_Mode_Id,  
CONVERT(VARCHAR(11),TAD.For_date,103) as For_date ,  
right(convert(varchar,TAD.For_date),7) as From_Time,  
TAD.Description,TAD.Amount,case when TAD.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay  
,TAD.modify_Date  
,TM.Travel_Mode_Name,  
right(convert(varchar,TAD.To_date),7) as To_Time,TAD.To_date,isnull(TAD.curr_ID,0) as Curr_ID,isnull(Cm.Curr_Symbol,'') as Currency  
,TM.GST_Applicable,TAD.SGST,TAD.CGST,TAD.IGST,TAD.GST_No,TAD.GST_Company_Name,TAM.TRAVEL_MODE  
FROM dbo.T0130_TRAVEL_Approval_OTHER_DETAIL AS TAD WITH (NOLOCK) INNER JOIN  
 T0110_Travel_Application_Other_Detail TAPD on TAPD.Travel_Mode_Id=TAD.Travel_Mode_ID   
 INNER JOIN  
   dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID and tapd.Mode_ID=tm.Travel_Mode_ID and tm.Cmp_ID=tad.Cmp_ID   
   left join T0040_CURRENCY_MASTER cm WITH (NOLOCK)  on Cm.Curr_ID=TAD.curr_ID  
   left join T0130_Travel_Approval_Other_Mode_Detail TAM WITH (NOLOCK)  ON TAD.TRAVEL_APR_OTHER_DETAIL_ID = TAM.TRAVEL_APPROVAL_OTHER_DETAIL_ID AND TAD.TRAVEL_APPROVAL_ID = TAM.TRAVEL_APPROVAL_ID  
   RIGHT join T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL TAOL WITH (NOLOCK) ON TAOL.Travel_Apr_Other_Detail_ID=TAM.Travel_Approval_Other_Detail_ID
     
     
     
     
  
