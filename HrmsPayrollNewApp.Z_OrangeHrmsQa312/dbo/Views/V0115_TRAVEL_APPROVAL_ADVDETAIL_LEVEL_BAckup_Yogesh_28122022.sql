



Create VIEW [dbo].[V0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL_BAckup_Yogesh_28122022]
AS
Select Tran_Id,Row_Adv_ID As Travel_Advance_Detail_ID,
	   TAD.Cmp_ID,Expence_Type,
	   CASE when isnull(TAD.curr_ID,0)=0 then TAD.Amount
	   when cm.Curr_Major='Y' then TAD.Amount  
	   Else isnull(TAD.Amount_Dollar,0) End as Amount
	   ,Adv_Detail_Desc,ROW_NUMBER() OVER (ORDER BY Row_Adv_ID) AS Sr_No,
	   TAD.Curr_ID,Cm.Curr_Symbol as Currency 
FROM T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL TAD WITH (NOLOCK)
		left JOIN T0040_CURRENCY_MASTER Cm WITH (NOLOCK) ON TAD.Curr_ID=Cm.Curr_ID 
		and TAD.Cmp_ID=Cm.Cmp_ID




