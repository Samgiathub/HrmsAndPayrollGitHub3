
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_Travel_Expense_Level_Detail]
	 @Cmp_ID 		numeric
	,@Emp_ID 		numeric
 	,@Travel_Approval_Id Numeric
 	,@Travel_Set_App_ID numeric(18,0)=null
 	,@Rpt_Level numeric=1
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Emp_ID = 0  
		set @Emp_ID = null
	
	 --insert into @Temp_Emp_Expense(int_id,Travel_Approval_Id,For_Date,Amount,Expense_Type_name,Comments,Missing,int_Exp_id,Travel_Settlement_Id,Approved_Amount,From_Time,To_Time,Duration,Appr_From_Time,Appr_To_Time,Appr_Duration,TravelAllowance,Limit_Amnt,Grp_Emp,Grp_Emp_ID
	  --,Curr_ID,Currency,Exchange_Rate,Diff_Amount,Exp_KM,is_petrol,RateKM,File_Name,
	  --File_Name_Original,City_ID,City_Name,Travel_Mode_ID,Mode_Name)
	  select DISTINCT TSE.int_id,TSE.Travel_Approval_Id,
	  convert(NVARCHAR, TSE.For_Date , 103) as For_Date,
	  TSE.Amount,Expense_Type_name,TSE.Comments,TSE.Missing, 0 as int_Exp_Id,isnull(TSA.Travel_Set_Application_id,0) as Travel_Settlement_Id,TSE.Approved_Amount as Approved_Amount,
	     isnull(TSE.from_Time,'') as From_Time ,
	    isnull(TSE.To_Time,'') as To_Time,
	    TSE.Duration,
	    isnull(TSE.from_Time,'') as Appr_From_Time ,
	    isnull(TSE.To_Time,'') as Appr_To_Time,
	    TSE.Duration as Appr_Duration,
	    TSD.travelAllowance,
	    TSD.Limit_Amount as Limit_Amnt,
	    isnull(TSD.Grp_Emp,'') as Grp_Emp,
	    ISNULL(TSD.Grp_Emp_ID,'') as Grp_Emp_ID,
	    isnull(TSE.Curr_ID,0) as Curr_ID,
	    ISNULL(cm.Curr_Symbol,'') as Currency,
	    isnull(TSE.Exchange_Rate,0) as Exchange_Rate,
	    ISNULL(TSD.Diff_Amount,0) as Diff_Amount,
	    ISNULL(TSE.ExpKM,0) as Exp_KM,
	    isnull(TSD.Is_petrol,0) as is_petrol,
	    ISNULL(TSD.RateKM,0) as RateKM,
	     isnull(TSD.FileName,'') as File_Name,
	    RIGHT(TSD.FileName,LEN(TSD.FileName)-CHARINDEX('#',TSD.FileName)) as File_Name_Original,
	    --ISNULL(TSD.City_ID,0) as City_ID,
	    --ISNULL(CTM.City_Name,'') as City_Name
	    case when isnull(TSE.Curr_ID,0)=0 then ISNULL(TSD.City_ID,0) Else isnull(lm.Loc_ID,0) End
		as City_ID,
	    --ISNULL(CTM.City_Name,'') as City_Name
	    case when isnull(TSE.Curr_ID,0)=0 then ISNULL(CTM.City_Name,'') Else isnull(lm.Loc_Name,'') End
		as City_Name,
		isnull(TSD.Travel_Mode_ID,0) as Travel_Mode_ID,
		case when isnull(TSD.Travel_Mode_ID,0)=99999 then 'Special'
		Else ISNULL(TM.Travel_Mode_Name,'') End as Mode_Name,
		'' as str_rate,0.0 as Exp_Amount,
		T0040_Expense_Type_Master.GST_Applicable   --Added by Jaina 27-11-2017
		,TSD.SGST,TSD.CGST,TSD.IGST
		,TSD.GST_No,TSD.GST_Company_Name  --Added by Jaina 15-02-2018
		,TSLME.TRAVEL_MODE,TSLME.TRAVEL_SETTLEMENT_ID AS TRAVEL_SET_APPLICATION_ID,TSD.SelfPay --ADEED BY RAJPUT ON 02082019
		,tse.No_of_Days,TSE.GuestName
		from T0115_Travel_Settlement_Level_Expense TSE WITH (NOLOCK)
		inner join T0040_Expense_Type_Master  WITH (NOLOCK) on TSE.expense_type_id =  T0040_Expense_Type_Master.expense_type_id
		inner join T0140_Travel_Settlement_Application TSA on TSE.Travel_Approval_Id = TSA.Travel_Approval_Id  
		and TSE.Emp_ID = TSA.emp_id
		and TSE.Travel_Settlement_Id=TSA.Travel_Set_Application_id
		inner join T0140_Travel_Settlement_Expense TSD WITH (NOLOCK) on TSE.INT_ID=TSD.INT_ID 	
		--TSD.Travel_Approval_Id=TSE.Travel_Approval_Id and TSD.Expense_Type_id=TSE.Expense_Type_IDand TSE.Travel_Settlement_Id=TSD.Travel_Set_Application_id
		--and TSD.Emp_ID=TSE.Emp_ID and TSD.Cmp_ID=TSE.Cmp_ID
		left join T0040_CURRENCY_MASTER cm WITH (NOLOCK) on cm.Curr_ID =TSE.Curr_ID and cm.Cmp_ID=TSE.Cmp_ID
		left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTM.City_ID=TSD.City_ID and CTM.Cmp_ID=TSE.Cmp_ID
		left join t0001_Location_Master lm WITH (NOLOCK) on lm.Loc_ID=TSD.City_ID
		left join T0030_TRAVEL_MODE_MASTER TM WITH (NOLOCK) on TM.Travel_Mode_ID=TSD.Travel_Mode_ID and TM.Cmp_ID=TSD.Cmp_ID
		left join T0115_Travel_Settlement_Level_Mode_Expense TSLME WITH (NOLOCK) ON TSE.INT_ID = TSLME.INT_ID AND TSE.TRAVEL_SETTLEMENT_ID = TSLME.TRAVEL_SETTLEMENT_ID AND TSE.TRAVEL_APPROVAL_ID = TSLME.TRAVEL_APPROVAL_ID
		 where  --TSE.Cmp_ID =@Cmp_ID and
		 TSE.Emp_ID  =@Emp_ID and TSE.Travel_Approval_Id=@Travel_Approval_Id
		and  isnull(TSE.Travel_Settlement_Id,0)=case when TSE.Travel_Settlement_Id is null then 0 Else @Travel_Set_App_ID End
		and TSE.Rpt_Level=@Rpt_Level
		--and TSE.Travel_Settlement_Id=265
		order by Travel_Settlement_Id, TSE.int_Id
	  
	
     
	 --select distinct *,'' as str_rate,0.0 as Exp_Amount from @Temp_Emp_Expense	
		
		select Isnull(SUM(amount),0) as total_Expense 
		from T0140_Travel_Settlement_Expense WITH (NOLOCK)
		where  Cmp_ID =@Cmp_ID and Emp_ID  =@Emp_ID and Travel_Approval_Id=@Travel_Approval_Id
		and  isnull(Travel_Set_Application_id,0)=case when Travel_Set_Application_id is null then 0 Else isnull(@Travel_Set_App_ID,0) End
RETURN





