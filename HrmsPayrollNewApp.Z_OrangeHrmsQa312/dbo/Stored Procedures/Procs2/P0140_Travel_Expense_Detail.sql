
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_Travel_Expense_Detail]
	 @Cmp_ID 		numeric
	,@Emp_ID 		numeric
 	,@Travel_Approval_Id Numeric
 	,@Travel_Set_App_ID numeric(18,0)=null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	 IF @EMP_ID = 0  
	 SET @EMP_ID = NULL
		
	 declare @Temp_Emp_Expense table
	 (
		int_id int ,
		Travel_Approval_Id numeric,
		For_Date varchar(25),
		Amount numeric(18,2),
		Expense_Type_name  varchar(100),
	    Comments  varchar(1000),
	    Missing tinyint,
	    int_Exp_id int ,
	    Travel_Settlement_Id numeric,
	    Approved_Amount numeric(18,2),
	    From_Time varchar(25), -- Added by Gadriwala Muslim 01122014
        To_Time  varchar(25),  -- Added by Gadriwala Muslim 01122014
        Duration numeric(18,2), -- Added by Gadriwala Muslim 01122014
        Appr_From_Time varchar(25), -- Added by Gadriwala Muslim 01122014
        Appr_To_Time varchar(25), -- Added by Gadriwala Muslim 01122014
        Appr_Duration numeric, -- Added by Gadriwala Muslim 01122014
        TravelAllowance numeric(18,2),
        Limit_Amnt numeric(18,2),
        Grp_Emp varchar(max),
        Grp_Emp_ID varchar(max),
        Curr_ID numeric(18,0),
        Currency varchar(50),
        Exchange_Rate numeric(18,2),
        Diff_Amount numeric(18,2),
        Exp_KM numeric(18,2),
        is_petrol tinyint,
        RateKM numeric(18,2),
        File_Name varchar(500),
        File_Name_Original varchar(500),
        City_ID	numeric(18,0),
        City_Name varchar(500),
        Travel_Mode_ID numeric(18,0),
        Mode_Name varchar(200),
        GST_Applicable tinyint,
        SGST numeric(18,2),  --Added by Jaina 21-09-2017
        CGST numeric(18,2),  --Added by Jaina 21-09-2017
        IGST numeric(18,2),   --Added by Jaina 21-09-2017
        GST_No nvarchar(15),  --Added by Jaina 5-12-2017
        GST_Company_Name nvarchar(2500),  --Added by Jaina 5-12-2017
        Travel_Mode INT,
        Travel_Set_Application_ID numeric,
        SelfPay int
		,No_of_days numeric(18,2)
		,GuestName varchar(Max)
	 )	
		
	 insert into @Temp_Emp_Expense(int_id,Travel_Approval_Id,For_Date,Amount,Expense_Type_name,Comments,Missing,int_Exp_id,Travel_Settlement_Id,Approved_Amount,From_Time,To_Time,Duration,Appr_From_Time,Appr_To_Time,Appr_Duration,TravelAllowance,Limit_Amnt,Grp_Emp,Grp_Emp_ID
		,Curr_ID,Currency,Exchange_Rate,Diff_Amount,Exp_KM,is_petrol,RateKM,File_Name,
		File_Name_Original,City_ID,City_Name,Travel_Mode_ID,Mode_Name,GST_Applicable,SGST,CGST,IGST,GST_No,GST_Company_Name,Travel_Mode,Travel_Set_Application_ID,SelfPay,No_of_days,GuestName)
	    select TSE.int_id,TSE.Travel_Approval_Id,convert(NVARCHAR, TSE.For_Date , 103),TSE.Amount,Expense_Type_name,Comments,Missing, TSE.expense_type_id as int_Exp_Id,isnull(TSA.Travel_Set_Application_id,0) as Travel_Settlement_Id,TSE.Amount as Approved_Amount,
	     isnull(TSE.from_Time,'') as From_Time ,
	    isnull(TSE.To_Time,'') as To_Time,
	    TSE.Duration,
	    isnull(TSE.from_Time,'') as Appr_From_Time ,
	    isnull(TSE.To_Time,'') as Appr_To_Time,
	    TSE.Duration as Appr_Duration,
	    TSE.TravelAllowance,
	    ISnull(TSE.Limit_Amount,0),
	    ISNULL(TSE.Grp_Emp,'') as Grp_Emp,
	    ISNULL(TSE.Grp_Emp_ID,'') as Grp_Emp_ID,
	    isnull(TSE.Curr_ID,0) as Curr_ID,
	    ISNULL(cm.Curr_Symbol,'') as Currency,
	    isnull(TSE.Exchange_Rate,0) as Exchange_Rate,
	    ISNULL(TSE.Diff_Amount,0) as Diff_Amount,
	    isnull(TSE.Exp_KM,0) as Exp_KM,
	    isnull(TSE.Is_petrol,0) as is_petrol,
	    ISNULL(TSE.RateKM,0) as RateKM,
	    
	    isnull(TSE.FileName,'') as File_Name,
	    RIGHT(TSE.FileName,LEN(TSE.FileName)-CHARINDEX('#',TSE.FileName)) as File_Name_Original,
	    --ISNULL(TSE.City_ID,0) as City_ID,
	    case when isnull(TSE.Curr_ID,0)=0 then ISNULL(TSE.City_ID,0) Else isnull(lm.Loc_ID,0) End
		as City_ID,
	    --ISNULL(CTM.City_Name,'') as City_Name
	    case when isnull(TSE.Curr_ID,0)=0 then ISNULL(CTM.City_Name,'') Else isnull(lm.Loc_Name,'') End
		as City_Name,
		isnull(TSE.Travel_Mode_ID,0),
		case when isnull(TSE.Travel_Mode_ID,0)=99999 then 'Special'
		Else ISNULL(TM.Travel_Mode_Name,'') End,
		T0040_Expense_Type_Master.GST_Applicable,TSE.SGST,TSE.CGST,TSE.IGST   --Added by Jaina 21-09-2017
		,TSE.GST_No, TSE.GST_Company_Name,ISNULL(TSME.TRAVEL_MODE,0),isnull(TSA.Travel_Set_Application_id,0) as Travel_Set_Application_ID,
		SelfPay,tse.No_of_Days,tse.GuestName
		from T0140_Travel_Settlement_Expense TSE WITH (NOLOCK)
		
		
		inner join T0040_Expense_Type_Master WITH (NOLOCK) on TSE.expense_type_id =  T0040_Expense_Type_Master.expense_type_id
		--inner join 		
		--(select ISNULL(max(ex.City_Cat_Amount),0) as City_Cat_Amount,Ex.expense_type_id from T0050_EXPENSE_TYPE_MAX_LIMIT  
		--where ex.expense_type_id=TSE.)
		
		--(select I.Expense_Type_ID,I.City_Cat_Amount from T0050_EXPENSE_TYPE_MAX_LIMIT I inner join
		--(select ISNULL(max(ex.City_Cat_Amount),0) as City_Cat_Amount,Expense_Type_ID from T0050_EXPENSE_TYPE_MAX_LIMIT ex where 
		--CMP_ID=@Cmp_ID and ex.Effective_Date=(select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT where Cmp_ID=@Cmp_ID and Expense_Type_ID=Ex.expense_type_id)
		--group by Expense_Type_ID) qry on QRY.Expense_Type_ID=I.Expense_Type_ID) I_Q
		--on I_Q.Expense_Type_ID=TSE.Expense_Type_id
		--)
		
		--on exmax.Expense_Type_ID=T0040_Expense_Type_Master.expense_type_id
		--and exmax.Cmp_ID=T0040_Expense_Type_Master.CMP_ID
		left join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) on TSE.Travel_Approval_Id = TSA.Travel_Approval_Id  
		and TSE.Emp_ID = TSA.emp_id 
		and TSA.Travel_Set_Application_id=isnull(TSE.Travel_Set_Application_id,TSA.Travel_Set_Application_id)
		left join T0040_CURRENCY_MASTER cm WITH (NOLOCK) on cm.Curr_ID =TSE.Curr_ID and cm.Cmp_ID=TSE.Cmp_ID
		left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTM.City_ID=TSE.City_ID and CTM.Cmp_ID=TSE.Cmp_ID
		left join t0001_Location_Master lm WITH (NOLOCK) on lm.Loc_ID=TSE.City_ID
		left join T0030_TRAVEL_MODE_MASTER TM WITH (NOLOCK) on TM.Travel_Mode_ID=TSE.Travel_Mode_ID and TM.Cmp_ID=TSE.Cmp_ID
		left join T0140_Travel_Settlement_Mode_Expense TSME WITH (NOLOCK) ON  TSE.INT_ID = TSME.INT_ID AND TSE.TRAVEL_SET_APPLICATION_ID = TSME.TRAVEL_SET_APPLICATION_ID --ADDED BY RAJPUT ON 18072019
		where  --TSE.Cmp_ID =@Cmp_ID and 
		TSE.Emp_ID  =@Emp_ID and TSE.Travel_Approval_Id=@Travel_Approval_Id
		and  isnull(TSE.Travel_Set_Application_id,0)=isnull(TSE.Travel_Set_Application_id, @Travel_Set_App_ID)--case when TSE.Travel_Set_Application_id is null then 0 Else isnull(@Travel_Set_App_ID,0) End
		--and exmax.Effective_Date=(select MAX(Effective_Date) from T0050_EXPENSE_TYPE_MAX_LIMIT where Cmp_ID=@Cmp_ID and Expense_Type_ID=TSE.expense_type_id)		
		
		order by TSE.Travel_Approval_Id, int_Id
	  
	--declare @intLoop int
	--declare @intcnt int
	--set @intLoop=1
	--set @intcnt=0
	--declare @dtFor_Date datetime
	
	
   
     
  --    declare @intCnt1 int
 
	 --set @intCnt1=0
     
  	 
  --   select @intCnt1=count(int_Id) from @Temp_Emp_Expense
		--if(@intCnt1<=0)
		--begin
		--    insert into @Temp_Emp_Expense(int_id)
		--		select 1 		 
		--end  
     --select Distinct * from @Temp_Emp_Expense
	 select distinct *,'' as str_rate,Amount as Exp_Amount,@Cmp_ID  as Cmp_ID,Row_number() over (order by Int_ID) as RowIndex,0 as Exchnge_Rate  from @Temp_Emp_Expense	
	 --select distinct *,0 as Exchnge_Rate,'' as str_rate,0.0 as Exp_Amount,@Cmp_ID  as Cmp_ID  from @Temp_Emp_Expense	
		
		--select Isnull(SUM(amount),0) as total_Expense from T0140_Travel_Settlement_Expense where  Cmp_ID =@Cmp_ID and Emp_ID  =@Emp_ID and Travel_Approval_Id=@Travel_Approval_Id
select Isnull(SUM(amount),0) as total_Expense from T0140_Travel_Settlement_Expense WITH (NOLOCK)
		where  Cmp_ID =@Cmp_ID and Emp_ID  =@Emp_ID and Travel_Approval_Id=@Travel_Approval_Id
		and  isnull(Travel_Set_Application_id,0)=case when Travel_Set_Application_id is null then 0 Else isnull(@Travel_Set_App_ID,0) End
RETURN




