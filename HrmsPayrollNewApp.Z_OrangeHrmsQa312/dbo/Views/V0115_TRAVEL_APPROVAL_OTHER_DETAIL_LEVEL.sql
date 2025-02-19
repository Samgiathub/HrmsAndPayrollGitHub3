  
  
CREATE VIEW [dbo].[V0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL]  
AS  
Select  
distinct  
--ROW_NUMBER() OVER (ORDER BY Travel_Apr_Other_Detail_Id) AS Sr_No,  
  Travel_Apr_Other_Detail_Id As Travel_App_Other_Detail_Id,TLA.Tran_Id,   
  TAO.Travel_Mode_Id,TAO.For_date,TAO.Description,TAO.Amount,Case when TAO.Self_Pay = 1 then 'Yes' else 'No' end as Self_Pay,  
  TAO.modify_Date,Travel_Mode_Name,right(convert(varchar,TAO.For_date),7) as From_Time,  
  right(convert(varchar,TAO.To_date),7) as To_Time,TAO.To_date,isnull(TAO.Curr_ID,0) as Curr_ID
  ,isnull(Cm.Curr_Symbol,'') as Currency
	 ,TLA.Travel_Application_ID,TLA.Rpt_Level  
     ,tm.GST_APPLICABLE  
  ,TAO.SGST,TAO.CGST,TAO.IGST,TAO.GST_No,TAO.GST_Company_Name,TAOD.TRAVEL_MODE,TLA.Travel_Application_ID AS Travel_App_ID  
From T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL TAO WITH (NOLOCK)  
  Inner Join T0115_TRAVEL_LEVEL_APPROVAL TLA WITH (NOLOCK) ON Tao.Tran_Id = TLA.Tran_Id   
  inner join T0110_Travel_Application_Other_Detail TAD on TAD.Travel_Mode_Id=tao.Travel_Mode_ID   
  Inner Join T0030_TRAVEL_MODE_MASTER TM WITH (NOLOCK) ON TAO.Travel_Mode_ID= TM.Travel_Mode_ID and TAD.Travel_Mode_Id=tm.Travel_Mode_ID and tm.Cmp_ID=tao.Cmp_ID  
    
  LEFT JOIN T0040_CURRENCY_MASTER Cm WITH (NOLOCK) ON Cm.Curr_ID=TAO.Curr_ID and Cm.Cmp_ID=TAO.Cmp_ID  
  LEFT JOIN T0115_TRAVEL_APPROVAL_OTHER_Mode_DETAIL_LEVEL TAOD WITH (NOLOCK) ON TAO.TRAVEL_APR_OTHER_DETAIL_ID = TAOD.TRAVEL_APPROVAL_OTHER_DETAIL_ID AND TAO.TRAN_ID = TAOD.OTHER_TRAN_ID  
    
--  Where TLA.Travel_Application_ID =449   
--And TLA.Rpt_Level = (Select MAX(Rpt_Level) As Rpt_level From T0115_TRAVEL_LEVEL_APPROVAL Where Travel_Application_ID = 449)  
  
  
  