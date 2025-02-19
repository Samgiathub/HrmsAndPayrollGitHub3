  
  
  
        
        
        
        
        
        
        
        
        
        
        
-- Created by Sumit on 11-jun-2015        
CREATE VIEW [dbo].[V0110_Travel_Apr_Other_Detail]        
AS        
SELECT            
distinct        
TAD.Travel_App_Other_Detail_Id,TAD.Cmp_ID,TAD.Travel_App_ID,TAD.Travel_Mode_Id,        
CONVERT(VARCHAR(11),TAD.For_date,103) as For_date ,        
right(convert(varchar,For_date),7) as From_Time,        
TAD.Description,TAD.Amount,case when TAD.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay        
,TAD.modify_Date        
,TM.Travel_Mode_Name,        
CONVERT(VARCHAR(11),TAD.To_Date,103) as To_Date,        
right(convert(varchar,To_Date),7) as To_Time,        
isnull(TAD.Curr_ID,0) as Curr_ID, isnull(Cm.Curr_Symbol,'') as Currency,TM.GST_Applicable        
,TAD.SGST,TAD.CGST,TAD.IGST,TAD.GST_No, TAD.GST_Company_Name,tm.Travel_Mode_ID as TRAVEL_MODE--TAMD.TRAVEL_MODE        
FROM dbo.T0110_Travel_Application_Other_Detail AS TAD WITH (NOLOCK) INNER JOIN        
--   dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_Id and tm.Cmp_ID=tad.Cmp_ID        
dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_Id and tm.Cmp_ID=tad.Cmp_ID        
   Left join T0040_CURRENCY_MASTER Cm WITH (NOLOCK)  on TAD.Curr_ID=Cm.Curr_ID        
   left join T0110_TRAVEL_APPLICATION_MODE_DETAIL TAMD WITH (NOLOCK)  ON TAD.Travel_App_Other_Detail_Id = TAMD.TRAVEL_APP_OTHER_DETAIL_ID AND         
   TAD.TRAVEL_APP_ID = TAMD.TRAVEL_APP_ID  --and TAMD.Travel_Mode=tm.Mode_Type--and  tm.Cmp_ID=TAMD.Cmp_ID        
             -- where tad.Travel_App_ID=307        
        
        