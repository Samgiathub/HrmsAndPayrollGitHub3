
    
    
    
    
CREATE view [dbo].[V0140_Travel_Sattlement_Approval_Detail_Update]      
AS      
 SELECT DISTINCT TSA.int_Id,TSA.Travel_Approval_Id,TSA.For_Date,    
   isnull(TSE.Amount,0) as Amount,TEM.Expense_Type_name,TSA.Comments    
   ,TSA.Missing,TSA.int_Exp_Id,TSA.Travel_Settlement_Id,TSA.Approved_Amount,TSA.From_Time,TSA.To_Time,    
   TSA.Duration,TSA.Appr_From_Time,TSA.Appr_To_Time,TSA.Appr_Duration,isnull(TSE.TravelAllowance,0) as TravelAllowance    
   ,isnull(TSE.Limit_Amount,0) as Limit_Amnt,TSA.Grp_Emp,TSA.Grp_Emp_ID,
    ISNULL(TSA.Curr_ID,0) as Curr_ID,    
   isnull(Cm.Curr_Symbol,'') as Currency,    
   ISNULL(TSA.Exchange_rate,0) as Exchange_Rate,    
   ISNULL(TSE.Diff_Amount,0) as Diff_Amount,    
   ISNULL(TSA.ExpKM,0) as Exp_KM,    
   ISNULL(TSE.is_petrol,0) as is_petrol,    
   ISNULL(TSE.RateKm,0) as RateKM,    
   ISNULL(TSE.FileName,'') as File_Name,    
   RIGHT(TSE.FileName,LEN(TSE.FileName)-CHARINDEX('#',TSE.FileName)) as File_Name_Original,    
   '' as str_rate,    
   ISNULL(TSA.Curr_Amount,0) as Exp_Amount,    
   --ISNULL(TSE.City_ID,0) as City_ID,    
   --ISNULL(CTM.City_Name,'') AS City_Name,    
   case when isnull(TSE.Curr_ID,0)=0 then ISNULL(TSE.City_ID,0) Else isnull(lm.Loc_ID,0) End    
     as City_ID,         
     case when isnull(TSE.Curr_ID,0)=0 then ISNULL(CTM.City_Name,'') Else isnull(lm.Loc_Name,'') End    
     as City_Name,    
   isnull(TSE.Travel_Mode_ID,0) as Travel_Mode_ID,    
   case when isnull(TSE.Travel_Mode_ID,0)=99999 then 'Special'    
     Else ISNULL(TM.Travel_Mode_Name,'') End    
   as Mode_Name,     
   TSA.Cmp_ID--,TSA.Emp_ID,    
   --TSA.Expense_Type_id    
   ,TEM.GST_Applicable,TSE.SGST,TSE.CGST,TSE.IGST,    
   TSE.GST_NO,TSE.GST_COMPANY_NAME,    
   TSME.TRAVEL_MODE,TSA.TRAVEL_SETTLEMENT_ID AS TRAVEL_SET_APPLICATION_ID,TSA.SelfPay
     ,isnull (tse.No_of_days,1) as No_of_days,
   tse.GuestName as GuestName
   from    
   T0150_Travel_Settlement_Approval_Expense TSA WITH (NOLOCK)    
   inner join T0040_Expense_Type_Master TEM WITH (NOLOCK) on     
   TSA.Expense_Type_id=TEM.Expense_Type_ID and TEM.CMP_ID=TSA.Cmp_ID    
   inner join T0140_Travel_Settlement_Expense TSE WITH (NOLOCK) on TSA.Travel_Approval_Id=TSE.Travel_Approval_Id    
   and TSA.Emp_ID=TSE.Emp_ID and TSA.For_Date=TSE.For_Date AND TSA.Expense_Type_id=TSE.Expense_Type_id and TSA.int_Id=TSE.int_Id -- TSA.int_Id=TSE.int_Id Added by Rajput Problem Was Same Row Repeter Multiple Time Face by VCERP Client 28072017    
   left join T0030_City_Master CTM WITH (NOLOCK) on CTM.City_ID=TSE.City_ID and CTM.Cmp_ID=TSE.Cmp_ID    
   LEFT JOIN T0040_CURRENCY_MASTER Cm WITH (NOLOCK) ON Cm.Curr_ID=TSA.Curr_ID AND Cm.Cmp_ID=TSA.Cmp_ID    
   left join t0001_Location_Master lm WITH (NOLOCK) on lm.Loc_ID=TSE.City_ID    
   left join T0030_TRAVEL_MODE_MASTER TM WITH (NOLOCK) on TM.Travel_Mode_ID=TSE.Travel_Mode_ID and TM.Cmp_ID=TSE.Cmp_ID    
   left join T0150_TRAVEL_SETTLEMENT_APPROVAL_MODE_EXPENSE TSME WITH (NOLOCK) ON TSA.INT_ID = TSME.INT_ID AND TSA.TRAVEL_SETTLEMENT_ID = TSME.TRAVEL_SETTLEMENT_ID AND TSA.TRAVEL_APPROVAL_ID = TSME.TRAVEL_APPROVAL_ID   --ADDED BY RAJPUT ON 18072019    
    
    
    
    
    
    
    
    
    
    
