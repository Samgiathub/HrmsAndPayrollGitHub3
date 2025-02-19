


---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_SHIFT_ALLOWANCE_RATE]
@Tran_Id numeric output,
@Cmp_id numeric,
@Shift_Id numeric,
@Rate numeric(18,2),
@Effective_Date datetime,
@is_Emp_Rate numeric,
@Tran_Type varchar(1),
@Minimum_Count numeric(18,2)=0,
@Ad_Id numeric(18,2) = 0  --Added by Jaina 17-04-2018
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	if @Tran_Type = 'I'
		Begin
			if not exists (SELECT Tran_Id from T0100_SHIFT_ALLOWANCE_RATE WITH (NOLOCK) where Effective_Date = @Effective_Date AND  Cmp_id = @Cmp_id AND Shift_id = @Shift_Id AND Ad_Id = @ad_ID )
				begin
					select @Tran_id = isnull(max(@Tran_Id),0) + 1 from T0100_SHIFT_ALLOWANCE_RATE WITH (NOLOCK)
					
					INSERT INTO T0100_SHIFT_ALLOWANCE_RATE
									  (Tran_id, Cmp_id, Shift_id, Rate, Effective_Date, Is_Emp_Rate,Minimum_Count,Ad_Id)
					VALUES     (@Tran_id,@Cmp_Id,@Shift_Id,@Rate,@Effective_Date,@Is_Emp_Rate,@Minimum_Count,@Ad_Id)
				end
			
		End
	Else if @Tran_Type = 'U'
		Begin
		
			UPDATE    T0100_SHIFT_ALLOWANCE_RATE
			SET  Is_Emp_Rate = @Is_Emp_Rate , Rate = @Rate, Minimum_Count = @Minimum_Count where Shift_id = @Shift_Id and Effective_Date = @Effective_Date and Cmp_id = @Cmp_id and Ad_Id = @Ad_Id
			
		End
	Else if @Tran_Type ='D'
		Begin
			delete T0100_SHIFT_ALLOWANCE_RATE where Effective_Date = @Effective_Date and Cmp_id = @Cmp_id 
			and Ad_Id = @Ad_Id		 --Added by Jaina 29-05-2018
		End
	
	    
END


