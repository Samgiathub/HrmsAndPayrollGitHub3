




-- Must be check Before Using
CREATE PROCEDURE [dbo].[P0040_PROFESSIONAL_SETTING]
	@Cmp_ID numeric(18,0)
   ,@Branch_ID numeric(18,0)
   ,@For_Date datetime
   ,@Row_ID numeric(18,0) output
   ,@From_Limit numeric(18,0)
   ,@To_Limit numeric(18,0)
   ,@Amount numeric(16,2)
   ,@tran_type varchar(1)
   ,@Applicable_PT_Male_Female	varchar(10) = 'ALL'
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	
	if @Branch_ID =0 
		set	@Branch_ID =null	
	
	If @tran_type  = 'I'
		Begin
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0040_PROFESSIONAL_SETTING WITH (NOLOCK)
				
				INSERT INTO T0040_PROFESSIONAL_SETTING
				                      (
										     Cmp_ID 
											,Branch_ID 
											,For_Date 
											,Row_ID 
											,From_Limit 
											,To_Limit 
											,Amount 
											,Applicable_PT_Male_Female
				                      )
				                            
				VALUES     (
											 @Cmp_ID 
											,@Branch_ID 
											,@For_Date 
											,@Row_ID 
											,@From_Limit 
											,@To_Limit 
											,@Amount
											,@Applicable_PT_Male_Female
				
				)
		End
	Else if @tran_Type = 'U'
		begin
			if @Row_ID =0 
				begin
				
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0040_PROFESSIONAL_SETTING WITH (NOLOCK)
				
				INSERT INTO T0040_PROFESSIONAL_SETTING
				                      (
										     Cmp_ID 
											,Branch_ID 
											,For_Date 
											,Row_ID 
											,From_Limit 
											,To_Limit 
											,Amount 
											,Applicable_PT_Male_Female
				                      )
				                            
				VALUES     (
											 @Cmp_ID 
											,@Branch_ID 
											,@For_Date 
											,@Row_ID 
											,@From_Limit 
											,@To_Limit 
											,@Amount
											,@Applicable_PT_Male_Female
				
				)
				end				
			else
				begin
				
				Update T0040_PROFESSIONAL_SETTING
				set 											 
											 From_Limit  = @From_Limit
											,To_Limit = @To_Limit
											,Amount = @Amount
											,Applicable_PT_Male_Female = @Applicable_PT_Male_Female
				where 
											Cmp_ID = @Cmp_ID 
											and isnull(Branch_ID,0) =  isnull(@Branch_ID ,0)
											and For_Date = @For_Date
											and Row_ID = @Row_ID 
				end
	
		end
	Else if @tran_Type = 'D'
		begin
				
					
				Delete From T0040_PROFESSIONAL_SETTING Where Cmp_ID = @Cmp_ID 
											and isnull(Branch_ID,0) =  isnull(@Branch_ID ,0)
											and For_Date = @For_Date
											and Applicable_PT_Male_Female = @Applicable_PT_Male_Female
											--and Row_ID = @Row_ID  Changed by mitesh on 22052012
		end

	RETURN




