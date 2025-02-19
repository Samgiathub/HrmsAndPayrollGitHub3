



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0251_IT_PAID_DETAIL]
	@Tran_ID			numeric output
   ,@IT_Paid_ID			numeric(18,0)
   ,@Cmp_ID				numeric(18,0)
   ,@Emp_ID             numeric(18,0)
   ,@E_Taxable_Amount   numeric(18,0)
   ,@E_IT_Amount		numeric(12,0)
   ,@E_IT_Surcharge		numeric(7,0)
   ,@E_IT_ED_Cess		numeric(7,0)	
   ,@E_Total_IT_Amount  numeric(12,0)
   ,@E_IT_Paid_Amount	numeric(12,0)
   ,@E_IT_Comments		varchar(250)
   ,@tran_type as varchar(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
									
		select @Tran_ID = Isnull(max(Tran_ID),0) + 1 	From T0251_IT_PAID_DETAIL WITH (NOLOCK)
		
		
				
			INSERT INTO T0251_IT_PAID_DETAIL
			                      ( Tran_ID,IT_Paid_ID,Cmp_ID,Emp_ID,E_Taxable_Amount,E_IT_Amount,E_IT_Surcharge,E_IT_ED_Cess,E_Total_IT_Amount,E_IT_Paid_Amount,E_IT_Comments)
			VALUES     (@Tran_ID,@IT_Paid_ID,@Cmp_ID,@Emp_ID,@E_Taxable_Amount,@E_IT_Amount,@E_IT_Surcharge,@E_IT_ED_Cess,@E_Total_IT_Amount,@E_IT_Paid_Amount,@E_IT_Comments)	
			
			
			  
		End
	
	RETURN




