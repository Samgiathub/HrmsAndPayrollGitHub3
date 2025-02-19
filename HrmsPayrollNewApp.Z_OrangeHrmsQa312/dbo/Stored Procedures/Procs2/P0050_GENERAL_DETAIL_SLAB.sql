


-- Must be check Before Using
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_GENERAL_DETAIL_SLAB]
@Slab_id	int	,
@Cmp_ID	numeric(18, 0),
@GEN_ID	numeric(18, 0),
@From_hours	numeric(18,2),
@To_hours	numeric(18,2),
@Deduction_Days	numeric(18, 2),
@tran_type varchar(1),
@Slab_Type varchar(1) = 'P'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Slab_Type=''
	set @Slab_Type='P'
	
	
	
	If @tran_type  = 'I'
		Begin
		
		if @From_hours>0.00 --Added by Sumit 17022015
		begin
			select @Slab_id = isnull(max(Slab_ID),0) + 1 from dbo.T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK)
								
				INSERT INTO T0050_GENERAL_DETAIL_SLAB
				                      (
										    
											Cmp_ID
											,GEN_ID
											,From_hours
											,To_hours
											,Deduction_Days
                                            ,Slab_Type 
				                      )
				                            
				VALUES     (
											
											@Cmp_ID
											,@GEN_ID
											,@From_hours
											,@To_hours
											,@Deduction_Days
				                            ,@Slab_Type 
				)
		end
			
				
		End
	Else if @tran_Type = 'U'
		begin
				
				Update T0050_GENERAL_DETAIL_SLAB
				set
											Cmp_ID = @Cmp_ID
											,GEN_ID=@GEN_ID
											,From_hours = @From_hours
											,To_hours = @To_hours
											,Deduction_Days = @Deduction_Days
                                            ,Slab_Type = @Slab_Type 
				where Slab_id=@Slab_id
				
	
		end
	Else if @tran_Type = 'D'
		begin
				Delete From T0050_GENERAL_DETAIL_SLAB Where Slab_id=@Slab_id 
											
		end

	RETURN




