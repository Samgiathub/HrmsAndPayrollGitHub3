

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_HRMS_Range_Multiplier]
	   @Mul_Range_ID				numeric(18) output
	  ,@Cmp_ID						numeric(18)
      ,@Mul_Range_From				numeric(18,2)  
      ,@Mul_Range_To				numeric(18,2) 
      ,@Mul_Range_Slab				numeric(18,2) 
      ,@Mul_Effective_Date			Datetime 
      ,@tran_type					char(1) 
	  ,@User_Id						numeric(18,0) = 0
	  ,@IP_Address					varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	 
	
	If Upper(@tran_type) ='I'
		begin
			if exists(Select 1 from T0040_HRMS_Range_Multiplier WITH (NOLOCK) where Cmp_Id= @Cmp_ID and Mul_Range_Slab = @Mul_Range_Slab and Mul_Effective_Date= @Mul_Effective_Date)
				Begin				
					RAISERROR ('Slab like this already exist' , 16, 2) 
					Return
				End
				Select @Mul_Range_ID,@Cmp_ID,@Mul_Range_From,@Mul_Range_To,@Mul_Range_Slab,@Mul_Effective_Date,@User_Id,@IP_Address
		
				select @Mul_Range_ID = isnull(max(Mul_Range_ID),0) + 1 from T0040_HRMS_Range_Multiplier WITH (NOLOCK)

				INSERT INTO T0040_HRMS_Range_Multiplier(
					    Mul_Range_ID,Cmp_ID,Mul_Range_From,Mul_Range_To,Mul_Range_Slab,Mul_Effective_Date,Modify_by,Modify_date,Ip_Address)
				VAlUES(@Mul_Range_ID,@Cmp_ID,@Mul_Range_From,@Mul_Range_To,@Mul_Range_Slab,@Mul_Effective_Date,@User_Id,Getdate(),@IP_Address)
		End		
	Else If  Upper(@tran_type) ='U' 	
		Begin
			UPDATE    T0040_HRMS_Range_Multiplier
			SET       Mul_Range_From	 = @Mul_Range_From,
					  Mul_Range_To		 = @Mul_Range_To,
					  Mul_Range_Slab	 = @Mul_Range_Slab,
					  Mul_Effective_Date = @Mul_Effective_Date
			WHERE     Mul_Range_ID		 = @Mul_Range_ID
		End
	Else If  Upper(@tran_type) ='D'
		begin
				DELETE FROM T0040_HRMS_Range_Multiplier WHERE Mul_Range_ID = @Mul_Range_ID		
		End
END

