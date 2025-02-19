



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_CTC]    
 @CMP_ID NUMERIC,    
 @EMP_ID NUMERIC,    
 @Type   Char(1)    
 As 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  declare @Data_Table table    
   (    
    Ad_ID  Numeric,    
    Cmp_Id Numeric,    
    Emp_ID Numeric,    
    CTC    Numeric,    
    For_Date Datetime    
   )     
  Insert into @Data_Table    
    
   select AM.Ad_ID,EEM.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date     
    from t0050_ad_master am WITH (NOLOCK) Left outer join     
                       t0100_emp_earn_deduction EEM WITH (NOLOCK) on am.Ad_ID = EEM.Ad_ID Inner join     
         t0080_emp_master EM WITH (NOLOCK) on EEM.Emp_ID = EM.Emp_ID inner join    
         t0095_increment I WITH (NOLOCK) on EM.Increment_ID = I.Increment_Id     
   where am.cmp_id=@CMP_ID  And EEM.Emp_ID = @Emp_ID And am.ad_effect_on_ctc=1  and i.Increment_Effective_Date = EEM.For_Date and EEM.E_AD_Flag = 'I'
																		--change by Falak on 31-aug-2010 coz for gross only earning should be counted    
  
   Insert into @Data_Table    
   Select 0,I.Cmp_Id,EM.Emp_ID,I.Basic_Salary,I.Increment_Effective_Date from t0095_Increment I WITH (NOLOCK) Left outer join t0080_emp_master EM WITH (NOLOCK) On I.Increment_ID = EM.Increment_ID where EM.Emp_Id = @Emp_ID And EM.Cmp_Id = @Cmp_ID     
  
  
 IF @Type = 'C'    
   Begin    
    Declare @Amount  numeric(18,2)   
    set @Amount = 0  
    -- select @Amount=isnull(max(lea.limit),0)   from  t0100_emp_earn_deduction eem inner join t0050_ad_master am on eem.ad_id = am.ad_id inner join t0040_late_extra_amount lea on eem.ad_id = lea.allowance_id where ad_calculate_on='Present Senario' and eem.Emp_ID=@Emp_ID   
     Select Sum(CTC)+@Amount As CTC from @Data_Table   
   End    
 Else If @Type= 'A'    
   Begin    
     Select * From @Data_Table    
   End     
RETURN    
  
  


