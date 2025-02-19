-- =============================================
-- Author:		<Mehul>
-- Create date: <10/08/2021>
-- Description:	<SP for Master Cost Center>
-- =============================================

CREATE PROCEDURE [dbo].[P0040_MASTER_COST_CENTER]
@Cost_Slab_id numeric(18,0) output,
@Cmp_id numeric(18,0),
@Effective_Date datetime,
@Bandid varchar(Max),
@Business_Segment varchar(Max),
@Cost_Center_id varchar(Max),
@cost_center_percentage varchar(max),
@cost_slab_name varchar(max),
@TransId Char = ''	

AS
BEGIN
	
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


declare @OldValue as  varchar(max)
Declare @String_val as varchar(max)
set @String_val=''
set @OldValue =''

			If @TransId = 'I'
			Begin
				if exists (Select Cost_Slab_id  from T0040_Master_Cost_Center WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Cost_Slab_Name = @cost_slab_name) 
						begin
							set @Cost_Slab_id = 0
						end
				else
					begin
						select @Cost_Slab_id = isnull(max(Cost_Slab_id),0) from T0040_Master_Cost_Center WITH (NOLOCK)
							if @Cost_Slab_id is null or @Cost_Slab_id = 0
								set @Cost_Slab_id =1
							else
								set @Cost_Slab_id = @Cost_Slab_id + 1


								Insert into T0040_Master_Cost_Center(Cmp_id,effective_date,bandid,business_segment,cost_center_id,cost_center_percentage,Cost_Slab_Name)
								values(@Cmp_id,@Effective_Date,@Bandid,@Business_Segment,@Cost_Center_id,@cost_center_percentage,@cost_slab_name)

								--exec P9999_Audit_get @table = 'T0040_Master_Cost_Center' ,@key_column='Cost_slab_id',@key_Values=@Cost_Slab_id,@String=@String_val output
								--set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
							

					end

			End

			Else If @TransId = 'U'
			Begin
			
				--if exists (Select Cost_Slab_id  from T0040_Master_Cost_Center WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Cost_Slab_Name = @cost_slab_name) 
				--		BEGIN
				--			SET @Cost_Slab_id = 0
				--		END	
				--else
				--begin
						--exec P9999_Audit_get @table='T0040_Master_Cost_Center' ,@key_column='Cost_Slab_id',@key_Values=@Cost_Slab_id,@String=@String_val output
						
						update T0040_Master_Cost_Center
						Set effective_date = @Effective_Date,
						 bandid = @Bandid,
						 business_segment = @Business_Segment,
						 cost_center_id = @Cost_Center_id,
						 cost_center_percentage = @cost_center_percentage,
						 Cost_Slab_Name = @cost_slab_name
						 where cmp_id = @Cmp_id  and Cost_Slab_id = @Cost_Slab_id

						--exec P9999_Audit_get @table = 'T0040_Master_Cost_Center' ,@key_column='Cost_Slab_id',@key_Values=@Cost_Slab_id,@String=@String_val output
						--set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))

				--end
			End


			Else If @TransId = 'D'
			Begin
				
				Delete from T0040_Master_Cost_Center where Cmp_id = @Cmp_id and Cost_Slab_id = @Cost_Slab_id

				--exec P9999_Audit_get @table='T0040_Master_Cost_Center' ,@key_column='Cost_Slab_id',@key_Values=@Cost_Center_id,@String=@String_val output
				--set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))

			End

End
