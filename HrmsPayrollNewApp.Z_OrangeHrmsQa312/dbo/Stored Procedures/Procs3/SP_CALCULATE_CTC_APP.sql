



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_CTC_APP]    
 @CMP_ID int,    
 @Emp_Tran_ID bigint,    
 @Type   Char(1)    
 As   
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

  declare @Data_Table table    
   (    
    Ad_ID  int,    
    Cmp_Id int,    
    Emp_Tran_ID bigint,    
    CTC    Numeric,    
    Approved_Date Datetime    
   )     
  Insert into @Data_Table    
    
   select AM.Ad_ID,EEM.cmp_id,EEM.Emp_Tran_ID,EEM.E_Ad_Amount,EEM.Approved_Date     
    from T0050_AD_MASTER am WITH (NOLOCK) Left outer join     
         T0075_EMP_EARN_DEDUCTION_APP EEM WITH (NOLOCK)  on am.Ad_ID = EEM.Ad_ID Inner join     
         T0060_EMP_MASTER_APP EM WITH (NOLOCK) on EEM.Emp_Tran_ID = EM.Emp_Tran_ID inner join    
         P0070_EMP_INCREMENT_APP I on EM.Increment_ID = I.Increment_Id     
   where am.cmp_id=@CMP_ID  And EEM.Emp_Tran_ID = @Emp_Tran_ID And am.ad_effect_on_ctc=1 
    and i.Increment_Effective_Date = EEM.Approved_Date and EEM.E_AD_Flag = 'I'
																		
  
   Insert into @Data_Table    
   Select 0,I.Cmp_Id,EM.Emp_Tran_ID,I.Basic_Salary,I.Increment_Effective_Date from
    P0070_EMP_INCREMENT_APP I Left outer join T0060_EMP_MASTER_APP EM WITH (NOLOCK) On I.Increment_ID = EM.Increment_ID 
    where EM.Emp_Tran_ID = @Emp_Tran_ID And EM.Cmp_Id = @Cmp_ID     
  
  
 IF @Type = 'C'    
   Begin    
    Declare @Amount  numeric(18,2)   
    set @Amount = 0  
    
     Select Sum(CTC)+@Amount As CTC from @Data_Table   
   End    
 Else If @Type= 'A'    
   Begin    
     Select * From @Data_Table    
   End     
RETURN    
  
  


