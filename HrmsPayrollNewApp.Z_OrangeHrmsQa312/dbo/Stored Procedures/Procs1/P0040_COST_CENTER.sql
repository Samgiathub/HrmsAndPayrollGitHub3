



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_COST_CENTER]
@Tally_Center_ID as numeric output,
@Tally_Cat_ID as numeric,
@Cmp_ID numeric(18,0),
@Cost_Center as varchar(100),
@Trans_type as char(1)
AS
BEGIN


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Trans_type = 'I'
   begin
  	If  Exists(Select @Tally_Center_ID From t0040_Cost_Center WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And 
						Tally_Cat_ID = @Tally_Cat_ID and  Cost_Center = @Cost_Center)
					begin
						set @Tally_Center_ID = 0
						Return
					end						
						
				select @Tally_Center_ID = isnull(max(Tally_Center_ID),0) + 1 from t0040_Cost_Center WITH (NOLOCK)

				Insert Into t0040_Cost_Center(Tally_Center_ID,Tally_Cat_ID,Cmp_Id,Cost_Center)
				Values(@Tally_Center_ID,@Tally_Cat_ID,@Cmp_ID,@Cost_Center)
end
else if @Trans_type = 'D'
	begin
				
		delete from t0040_Cost_Center where  Tally_Center_ID=@Tally_Center_ID
		
	end
END




