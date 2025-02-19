



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Cost_Center_Detail]
@Tally_Tran_ID as numeric output,
@Cmp_ID numeric(18,0),
@Cost_Category As Varchar(100),
@Cost_Center as varchar(100),
@Trans_type as char(1)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Trans_type = 'I'
   begin
  	If  Exists(Select @Tally_Tran_ID From t0040_Cost_Center_Detail WITH (NOLOCK) Where Cmp_Id = @Cmp_ID And 
						Cost_Category = @Cost_Category and  Cost_Center = @Cost_Center)
					begin
						set @Tally_Tran_ID = 0
						Return
					end						
						
				select @Tally_Tran_ID = isnull(max(Tally_Tran_ID),0) + 1 from t0040_Cost_Center_Detail WITH (NOLOCK)

				Insert Into t0040_Cost_Center_Detail (Tally_Tran_ID,Cost_Category,Cost_Center,Cmp_Id)
				Values(@Tally_Tran_ID, @Cost_Category,@Cost_Center,@Cmp_ID)
			
			
end

else if @Trans_type = 'D'
	begin
		delete from t0040_Cost_Center_Detail where  Tally_Tran_ID=@Tally_Tran_ID
	end
END




