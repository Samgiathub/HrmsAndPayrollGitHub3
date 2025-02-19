

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Claim_Approval_Detail]  
 @CMP_ID  NUMERIC ,  
 @Claim_App_ID  NUMERIC(18,2),
 @Rpt_Level Numeric(18,0)
 
   
AS  
 SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   ;
  
--WITH CTE AS(
--   select row_number() OVER ( PARTITION BY cur.Curr_Name,cur.curr_ID ORDER BY cur.curr_ID DESC )rank,clmAppl.Claim_App_ID,clm.Claim_Apr_ID,clmAppl.For_Date,clm.Claim_Apr_Comments,clm.Claim_Apr_Code,clm.Emp_ID,clm.Claim_Apr_By,clm.Claim_Apr_Deduct_From_Sal,clmapp.Claim_App_Code,clm.Claim_Apr_Amount,clm.Claim_apr_Status,clmapp.Claim_App_Date,clmst.Claim_ID,cur.Curr_ID,clm.Claim_Apr_Date, clmst.Claim_Name as Claim_type,clmAppl.Claim_Amount as Amount,clmAppl.Application_Amount as TotalAmount,clmAppl.Claim_Description AS Description ,cur.Curr_Name as Currency,cur.Curr_Rate as Exchange_Rate
--from T0120_CLAIM_APPROVAL clm left outer join T0110_CLAIM_APPLICATION_DETAIL clmAppl  inner join 
--T0100_CLAIM_APPLICATION clmapp on clmAppl.Claim_App_ID= clmapp.Claim_App_ID
--on clmAppl.Claim_App_ID=clm.Claim_App_ID inner join T0040_CLAIM_MASTER clmst on clmst.Claim_ID=clm.Claim_ID
--left outer join T0040_CURRENCY_MASTER cur on cur.Curr_ID=clmAppl.Curr_ID
-- where clm.Claim_App_ID=@Claim_App_ID and clm.Cmp_ID=@CMP_ID
--)
--select * FROM CTE  where RANK = 1
--WITH CTE AS(
-- select 
-- distinct clmst.Claim_Name as Claim_type,clmAppl.Claim_Amount as Amount,for_date,
--clmAppl.Application_Amount as TotalAmount_one,clmAppl.Claim_Description AS Description ,
--cur.Curr_Name as Currency,cur.Curr_Rate as Exchange_Rate, Claim_Apr_Amount as TotalAmount, clmAppl.Claim_App_ID,Claim_Apr_ID,clmAppl.Claim_ID
--,cur.Curr_ID,Claim_App_Date,Claim_App_Code,Claim_Apr_Amount,Claim_Apr_Date,Claim_apr_Status,Claim_Apr_Comments
--,Claim_Apr_Code,CAL.Emp_ID,Claim_Apr_By,Claim_Apr_Deduct_From_Sal,Claim_Apr_Pending_Amount
--from T0100_CLAIM_APPLICATION as CL inner join
--T0110_CLAIM_APPLICATION_DETAIL clmAppl  on CL.Claim_App_ID= clmAppl.Claim_App_ID 
--left outer join T0120_CLAIM_APPROVAL CAL on  CAL.Claim_App_ID=clmAppl.Claim_App_ID and CAL.Claim_ID=clmAppl.Claim_ID
--and CAL.Claim_Apr_Amount=clmAppl.Application_Amount

--left outer JOIN T0040_CURRENCY_MASTER cur on cur.Curr_ID= clmAppl.Curr_ID
--left outer join T0040_CLAIM_MASTER clmst on clmst.Claim_ID=clmAppl.Claim_ID
-- where clmAppl.Claim_App_ID=@Claim_App_ID and clmAppl.Cmp_ID=@CMP_ID
--)
--select * FROM CTE

--select clm.Claim_App_Date as for_date,clm_master.Claim_Name as Claim_Type,clm.Claim_ID,clm.Claim_App_Amount as Amount,cur.Curr_Name as Currency,clm.Curr_ID,clm.Curr_Rate as Exchange_Rate,clm.Claim_Apr_Amount as TotalAmount,clm.Claim_App_Total_Amount as TotalAmount_one,clm.Purpose as Description,clm.Claim_App_ID,clm.Claim_Apr_ID,clm.Claim_Apr_Date,clm.Claim_Apr_Code as Claim_App_Code,clm.Claim_Apr_Deduct_From_Sal,clm.Claim_Apr_Pending_Amount,clm.Claim_Apr_Amount
--,clm.Claim_apr_Status,clm.Claim_Apr_Comments
--,clm.Claim_Apr_Code,clm.Emp_ID,clm.Claim_Apr_By,clm.Petrol_KM,Petrol_KM  AS Approved_Petrol_Km
-- from T0120_CLAIM_APPROVAL clm 
--left outer join T0040_CURRENCY_MASTER cur on cur.Curr_ID=clm.Curr_ID
--left outer join T0040_CLAIM_MASTER clm_master on clm_master.Claim_ID=clm.Claim_ID

--where clm.Claim_App_ID=@Claim_App_ID and clm.Cmp_ID=@CMP_ID
select Distinct 
CAD.Claim_Apr_Date as for_date,clm_master.Claim_Name as Claim_Type,clm_master.Claim_Name,CAD.Claim_ID,
CAD.Claim_Apr_Amount as Amount,
--CAD.Claim_App_Amount as Amount,
cur.Curr_Name as Currency,CAD.Curr_ID,CAD.Curr_Rate as Exchange_Rate,
CAD.Claim_App_Ttl_Amount as TotalAmount,
CAD.Claim_App_Ttl_Amount as TotalAmount_one,CAD.Purpose as Description,CAD.Claim_App_ID,CAD.Claim_Apr_ID,
clm.Claim_Apr_Date,clm.Claim_Apr_Code as Claim_App_Code,clm.Claim_Apr_Deduct_From_Sal,clm.Claim_Apr_Pending_Amount,clm.Claim_Apr_Amount
,CAD.Claim_Status as Claim_apr_Status,clm.Claim_Apr_Comments
,clm.Claim_Apr_Code,clm.Emp_ID,clm.Claim_Apr_By,CAD.Petrol_KM,CAD.Petrol_KM  AS Approved_Petrol_Km,clm.Cmp_ID,CLAIM_ALLOW_BEYOND_LIMIT
,Claim_Max_Limit,isnull(CD.Claim_Model,'') AS Model,isnull(cd.Claim_IMEI,'') AS IMEI
,CD.CLAIM_ATTACHMENT  --Commented by Mr.Mehul for duplication of records at final level manager (completed side) in ess 20122022
,CAD.Claim_Status,ISNULL(CD.Claim_NoofPerson,'') AS NoofPerson,
isnull(CONVERT(varchar,CD.Claim_DateOfPurchase,103),'') as DateOfPurchase,isnull(CD.Claim_BookName,'') As BookName,
isnull(CD.Claim_Subject,'') As Subject,isnull(CD.Claim_ActualPrice,'') As ActualPrice,
isnull(CD.Claim_PriceAfterDiscount,'') As PriceAfterDiscount,isnull(CD.Claim_FamilyMember,'') as FamilyMember,
isnull(CD.Claim_Relation,'') as Relation,isnull(CD.Claim_Age,0) as Age,isnull(CD.Claim_Limit,0) as Limit,
isnull(CD.Claim_FamilyMeberId,0) as RowId,ISNULL(cd.Claim_ConversionRate,0) as ConversionRate,
isnull(cd.ClaimSelf_Value,0) as ClaimSelf_Value,isnull(cd.Claim_UnitFlag,0) as UnitFlag,
isnull(cd.Claim_UnitName,'') as UnitName,ISNULL(Claim_Comments,'') as Claim_Comments,isnull(Rpt_Level,0) as Rpt_Level
from T0120_CLAIM_APPROVAL clm WITH (NOLOCK)
inner join T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK) on Clm.Claim_Apr_ID=CAD.Claim_Apr_ID
left join T0110_CLAIM_APPLICATION_DETAIL CD WITH (NOLOCK) on CD.Claim_App_ID=CAD.Claim_App_ID AND CD.Claim_ID = CAD.Claim_ID
left outer join T0040_CURRENCY_MASTER cur WITH (NOLOCK) on cur.Curr_ID=clm.Curr_ID
left outer join T0040_CLAIM_MASTER clm_master WITH (NOLOCK) on clm_master.Claim_ID=CAD.Claim_ID
LEFT JOIN T0115_CLAIM_LEVEL_APPROVAL CLA WITH (NOLOCK) on CLA.Claim_App_ID = CAD.Claim_App_ID
where CAD.Claim_App_ID=@Claim_App_ID and clm.Cmp_ID=@CMP_ID and Rpt_Level = @Rpt_Level
  
 
 RETURN  

