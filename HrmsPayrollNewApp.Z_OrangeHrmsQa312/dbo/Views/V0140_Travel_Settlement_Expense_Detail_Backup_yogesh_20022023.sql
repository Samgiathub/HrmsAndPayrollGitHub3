

Create view [dbo].[V0140_Travel_Settlement_Expense_Detail_Backup_yogesh_20022023]
AS
	select distinct  TSE.int_Id,TSE.Travel_Approval_Id,For_Date, Limit_Amount as Amount,
			ETP.Expense_Type_name,Comments,Missing,0 as int_Exp_ID,0 as Travel_Settlement_ID,0 as Approved_Amount,
			From_Time,To_Time,Duration,'' as Appr_From_Time,'' as Appr_To_Time,'' as Appr_Duration,isnull(TravelAllowance,0) as TravelAllowance,
			'' as Limit_Amount,Grp_Emp,Grp_Emp_ID,Amount as Exp_Amount,ETP.is_overlimit,
			isnull(TSE.Diff_Amount,0) as Diff_Amount,
			Cm.Curr_Symbol as Currency,
			TSE.Exchange_Rate as Exchnge_Rate,
			TSE.Curr_ID,
			TSE.Exp_KM,
			isnull(ETP.Is_Petrol_wise,0) as Is_Petrol,
			TSE.FileName as File_Name,
			isnull(TSE.RateKM,0) as RateKm,
			RIGHT(TSE.FileName,LEN(TSE.FileName)-CHARINDEX('#',TSE.FileName)) as File_Name_Original,
			--ISNULL(TSE.City_ID,0) as City_ID,
			case when isnull(TSE.Curr_ID,0)=0 then ISNULL(TSE.City_ID,0) Else isnull(lm.Loc_ID,0) End
			as City_ID,
			--'' as str_rate,
			case when isnull(TSE.Curr_ID,0)=0 then ISNULL(CTM.City_Name,'') Else isnull(lm.Loc_Name,'') End
			as City_Name,
			ISNULL(TSE.Travel_Mode_ID,0) as Travel_Mode_ID,
			'' as str_rate,
			case when ISNULL(TSE.Travel_Mode_ID,0)=99999 then 'Special' else 
			isnull(TMM.Travel_Mode_Name,'')
			End as Mode_Name,
			--ISNULL(CTm.City_Name,'') as City_Name,
			TSE.Cmp_ID,--TSE.Expense_Type_id,
			TSE.Travel_Set_Application_id
			,etp.GST_Applicable ,TSE.SGST,TSE.CGST,TSE.IGST,TSE.GST_No,TSE.GST_Company_Name,TSM.travel_mode,selfpay
			from T0140_Travel_Settlement_Expense TSE WITH (NOLOCK)
			inner join T0040_Expense_Type_Master ETP WITH (NOLOCK) on TSE.Expense_Type_id=ETP.Expense_Type_ID
			and TSE.Cmp_ID=ETP.CMP_ID
			left join T0040_CURRENCY_MASTER Cm WITH (NOLOCK) on Cm.Cmp_ID=TSE.CMP_ID and Cm.Curr_ID=TSE.Curr_ID
			left join T0030_CITY_MASTER CTM WITH (NOLOCK) on CTm.City_ID=TSE.City_ID and CTM.Cmp_ID=TSE.Cmp_ID
			left join t0001_Location_Master lm WITH (NOLOCK) on lm.Loc_ID=TSE.City_ID
			left join T0030_TRAVEL_MODE_MASTER TMM WITH (NOLOCK) on TMM.Travel_Mode_ID=TSE.Travel_Mode_ID
			LEFT JOIN T0140_TRAVEL_SETTLEMENT_MODE_EXPENSE TSM WITH (NOLOCK) ON TSE.INT_ID = TSM.INT_ID AND TSE.TRAVEL_SET_APPLICATION_ID = TSM.TRAVEL_SET_APPLICATION_ID
			






























