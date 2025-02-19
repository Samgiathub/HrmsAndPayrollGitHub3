



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Allo_ded_detail]    
 @Cmp_ID numeric,    
 @Emp_ID numeric    
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    

select eed.For_Date,AM.AD_SORT_NAME,eed.AD_ID,eed.Emp_ID,    
eed.E_AD_FLAG,eed.E_AD_MODE,eed.E_AD_PERCENTAGE,eed.E_AD_AMOUNT    
from t0050_ad_master AM WITH (NOLOCK) inner     
join t0100_emp_earn_deduction eed WITH (NOLOCK) on AM.Ad_ID=eed.Ad_ID and AM.Ad_Not_Effect_Salary<>1    
and  eed.increment_id=(select max(increment_id) from t0100_emp_earn_deduction WITH (NOLOCK)
 where t0100_emp_earn_deduction.emp_ID=@emp_id) order by AM.ad_flag desc    
    
RETURN    
  



