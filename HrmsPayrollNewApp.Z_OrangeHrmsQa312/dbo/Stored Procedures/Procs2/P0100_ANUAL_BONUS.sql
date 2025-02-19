



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_ANUAL_BONUS]
	 @Bonus_Tran_ID numeric(18,0)
	,@Cmp_Id numeric(18,0)
	,@Emp_ID  numeric(18,0)
	,@Ad_ID numeric(18,0)
	,@Amount numeric(22,0)
	,@Effective_Month numeric(18,0)
	,@Effective_Year numeric(18,0)
	,@Sal_Tran_ID numeric(18,0)
	,@tran_type varchar
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @tran_type  = 'I' 
		Begin
				--change by Falak on 14-OCT-2010 to avoid no
				if exists (select Bonus_Tran_Id from T0100_Anual_Bonus WITH (NOLOCK) where Effective_Month = @Effective_Month and Effective_Year = @Effective_Year and
									Cmp_Id = @Cmp_Id and Emp_Id = @Emp_ID)
					begin
						return
					end
				
				select @Bonus_Tran_ID = Isnull(max(Bonus_Tran_ID),0) + 1 	From t0100_Anual_bonus  WITH (NOLOCK)
				
				INSERT INTO t0100_Anual_bonus
				                      (
										  Bonus_Tran_ID  
										 ,Cmp_Id 
										 ,Emp_ID 
										 ,Ad_ID 
										 ,Amount
										 ,Effective_Month 
									     ,Effective_Year 
									     ,Sal_Tran_ID 
									     ,Sys_Date
				                      )
								VALUES     
								(
									      @Bonus_Tran_ID  
										 ,@Cmp_Id 
										 ,@Emp_ID 
										 ,@Ad_ID 
										 ,@Amount
										 ,@Effective_Month 
									     ,@Effective_Year 
									     ,@Sal_Tran_ID 
									     ,getdate()
								)
		End
	Else if @Tran_Type = 'D' 
		begin
				Delete From t0100_Anual_bonus Where Sal_Tran_ID  = @Sal_Tran_ID
		end


	RETURN




