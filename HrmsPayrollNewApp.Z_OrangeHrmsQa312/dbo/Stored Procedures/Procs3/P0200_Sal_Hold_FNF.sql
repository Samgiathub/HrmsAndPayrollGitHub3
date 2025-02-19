
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_Sal_Hold_FNF]
	@Sal_Hold_Tran_ID AS NUMERIC output,
	@cmp_ID AS NUMERIC,
	@Sal_Tran_ID AS VARCHAR(100),
	@Sal_Month as nvarchar(50),
	@Sal_Year as nvarchar(50),
	@Sal_Amount as numeric(18,0),
	@Emp_id as numeric(18,0),
	@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
				select @Sal_Hold_Tran_ID = Isnull(max(Sal_Hold_Tran_ID),0) + 1 	From T0200_Hold_Sal_FNF WITH (NOLOCK)
				 
				INSERT INTO T0200_Hold_Sal_FNF
				                      (Sal_Hold_Tran_ID, Cmp_ID, Sal_Tran_ID,Sal_Month,Sal_Year,Sal_Amount,Emp_id)
				VALUES     (@Sal_Hold_Tran_ID, @Cmp_ID, @Sal_Tran_ID,@Sal_Month,@Sal_Year,@Sal_Amount,@Emp_id)
			
		End
	Else if @Tran_Type = 'U'
		begin
				Update T0200_Hold_Sal_FNF
				set Cmp_ID = @cmp_ID,
				Sal_Tran_ID = @Sal_Tran_ID,
				Sal_Month = @Sal_Month,
				Sal_Year = @Sal_Year,
				Sal_Amount = @Sal_Amount,	
				emp_id = @Emp_id
				where Sal_Hold_Tran_ID = @Sal_Hold_Tran_ID
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0200_Hold_Sal_FNF Where Sal_Tran_ID = @Sal_Tran_ID
		end
		
	RETURN




