
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_TRAVEL_ALLOWANCE]  
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Duration numeric(18,2),
	@To_Date datetime
	
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 

select EED.cmp_ID,EED.Emp_ID,AM.AD_NAME,
cast((GA.AD_AMOUNT * ADS.Amount) as numeric(18,2))as
  Travel_Working_AD_Amount from T0100_EMP_EARN_DEDUCTION 
    EED 
   WITH (NOLOCK) inner join 
   ( select I.Emp_id,Grd_ID,Dept_ID,I.Increment_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)
				where Increment_Effective_date <=@To_Date
				and cmp_id =@Cmp_ID
				group by emp_ID
			) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
EED.Emp_ID = Inc_Qry.Emp_ID	
and EED.Increment_ID = Inc_Qry.Increment_ID 
inner join 
T0050_AD_MASTER 
AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
and AM.AD_CALCULATE_ON = 'Slab Wise' 
Inner join T0040_AD_Slab_Setting ADS WITH (NOLOCK)
on EED.AD_ID = ADS.AD_ID 
and ADS.Calc_Type = 'Travel(Working Hours)' 
inner join T0120_GRADEWISE_ALLOWANCE 
GA WITH (NOLOCK) on GA.Ad_ID = EED.AD_ID 
and GA.Grd_ID = Inc_Qry.Grd_ID 
where @DURATION between ADS.From_Slab
AND ADS.To_Slab 
and EED.Cmp_ID =@Cmp_ID and EED.EMP_ID=@Emp_ID

RETURN
