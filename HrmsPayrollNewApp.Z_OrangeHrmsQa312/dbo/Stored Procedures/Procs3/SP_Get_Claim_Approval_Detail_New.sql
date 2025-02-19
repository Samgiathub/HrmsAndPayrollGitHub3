


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Claim_Approval_Detail_New]  
 @CMP_ID  NUMERIC ,  
 @Claim_App_ID  NUMERIC(18,2) = 0,
 @Claim_Apr_ID Numeric(18,0) = 0 --Added by Jaina 9-10-020
 
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   ;
  
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
		select	CAD.Claim_Apr_Date as for_date,clm_master.Claim_Name as Claim_Type,clm_master.Claim_Name,CAD.Claim_ID,
					--CAD.Claim_Apr_Amount as Amount,
					CAD.Claim_App_Amount as Amount,
					cur.Curr_Name as Currency,CAD.Curr_ID,CAD.Curr_Rate as Exchange_Rate,
					CAD.Claim_Apr_Amount as TotalAmount,
					CAD.Claim_App_Ttl_Amount as TotalAmount_one,CAD.Purpose as Description,CAD.Claim_App_ID,CAD.Claim_Apr_ID,clm.Claim_Apr_Date,clm.Claim_Apr_Code as Claim_App_Code,
					(case when clm_master.Claim_Apr_Deduct_From_Sal = 0 then 'No' else 'Yes' end) as Claim_Apr_Deduct_From_Sal,clm.Claim_Apr_Pending_Amount,clm.Claim_Apr_Amount
					,CAD.Claim_Status as Claim_apr_Status,clm.Claim_Apr_Comments
					,clm.Claim_Apr_Code,clm.Emp_ID,clm.Claim_Apr_By,CAD.Petrol_KM,CAD.Petrol_KM  AS Approved_Petrol_Km
					,CAD.Claim_Apr_Dtl_ID,isnull(ACAD.Claim_Attachment,'') as Claim_Attachment,CLM.CMP_ID,CLAIM_ALLOW_BEYOND_LIMIT, -- ADDED BY RAJPUT ON 16032018
					clm.Claim_Apr_Deduct_From_Sal,
					isnull(ACAD.Claim_Model,'') as Model,isnull(ACAD.Claim_IMEI,'') as IMEI,ISNULL(ACAD.Claim_NoofPerson,'') as NoofPerson,isnull(CONVERT(varchar,ACAD.Claim_DateOfPurchase,103),'') as DateOfPurchase,
					isnull(ACAD.Claim_BookName,'') as BookName,ISNULL(ACAD.Claim_Subject,'') as Subject,isnull(ACAD.Claim_ActualPrice,0) as ActualPrice,ISNULL(ACAD.Claim_PriceAfterDiscount,0) as PriceAfterDiscount,
					isnull(ACAD.Claim_FamilyMember,'') as FamilyMember,isnull(ACAD.Claim_Relation,'') as Relation,isnull(ACAD.Claim_Age,0) as Age,isnull(ACAD.Claim_Limit,0) as Limit,
					isnull(ACAD.Claim_UnitName,'') as UnitName,isnull(ACAD.Claim_UnitFlag,0) as UnitFlag,isnull(ACAD.Claim_ConversionRate,0) as ConversionRate,isnull(ACAD.Claim_FamilyMeberId,0) as RowId,ACAD.Claim_App_Detail_ID,CLM.Purpose
		from T0120_CLAIM_APPROVAL clm WITH (NOLOCK)
		inner join T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK) on Clm.Claim_Apr_ID=CAD.Claim_Apr_ID
		--left outer join T0040_CURRENCY_MASTER cur on cur.Curr_ID=clm.Curr_ID COMMENTED BY RAJPUT ON 17032018
		left outer join T0040_CURRENCY_MASTER cur WITH (NOLOCK) on cur.Curr_ID=CAD.Curr_ID
		left outer join T0040_CLAIM_MASTER clm_master WITH (NOLOCK) on clm_master.Claim_ID=CAD.Claim_ID
		
		left outer join	T0110_CLAIM_APPLICATION_DETAIL ACAD WITH (NOLOCK) on ACAD.Claim_App_ID=CAD.Claim_App_ID AND ACAD.Claim_ID=CAD.Claim_ID 
		AND ACAD.For_Date=CAD.Claim_Apr_Date  AND ACAD.CLAIM_AMOUNT=CAD.CLAIM_APP_AMOUNT AND ACAD.CLAIM_DESCRIPTION =CAD.PURPOSE  -- ADDED BY RAJPUT ON 19032018
		and ACAD.Claim_App_Detail_ID=CAD.Claim_Apr_Dtl_ID
		where CAD.Claim_Apr_ID=@Claim_Apr_ID and clm.Cmp_ID=@CMP_ID 
		order by CAD.Claim_ID
		  
 
 RETURN  

