


CREATE VIEW [dbo].[V0130_TRAVEL_ADVANCE_DETAIL_EDIT]
AS
SELECT Travel_Approval_AdvDetail_ID as Travel_Advance_Detail_ID
,TAP.Cmp_ID,Travel_Approval_ID as Travel_App_ID,TAP.Expence_type
,CASE when isnull(TAp.curr_ID,0)=0 then tap.Amount
when cm.Curr_Major='Y' then tap.Amount
 Else isnull(Tap.Amount_Dollar,0) End as Amount,
TAP.Adv_Detail_Desc,isnull(TAp.curr_ID,0) as Curr_ID,isnull(Cm.Curr_Symbol,'') as Currency
 from T0130_TRAVEL_APPROVAL_ADVDETAIL TAP WITH (NOLOCK)
 left join T0040_CURRENCY_MASTER cm WITH (NOLOCK) on Cm.Curr_ID=Tap.curr_ID
 



