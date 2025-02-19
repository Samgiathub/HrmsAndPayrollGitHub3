


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0040_COST_CATEGORY]
@Tally_Cat_ID as numeric output,
@Cmp_ID numeric(18,0),
@Cost_Category As Varchar(100),
@Trans_type as char(1)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Trans_type = 'I'
   begin
  	If  Exists(Select @Tally_Cat_ID From t0040_Cost_Category WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And 
						Cost_Category = @Cost_Category)
					begin
						set @Tally_Cat_ID = 0
						Return
					end						
						
				select @Tally_Cat_ID = isnull(max(Tally_Cat_ID),0) + 1 from t0040_Cost_Category WITH (NOLOCK)

				Insert Into t0040_Cost_Category (Tally_Cat_ID,Cmp_Id,Cost_Category)
				Values(@Tally_Cat_ID,@Cmp_ID,@Cost_Category)
			
			
end
else if @Trans_type = 'D'
	begin
		delete from t0040_Cost_Category where Tally_Cat_ID=@Tally_Cat_ID
	end
END




