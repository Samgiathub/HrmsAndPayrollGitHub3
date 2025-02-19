



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_P0040_General_Setting] 
	
	@Cmp_ID Numeric
	,@Branch_ID Numeric
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   Declare @For_Date DateTime
   Declare @From_Date DateTime 
     if Isnull(@For_Date,'') = '' 
			begin
				select @For_Date = max(For_Date) From T0040_general_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID  and Branch_ID=@Branch_ID
			end
			
	
					
			Select Inout_Days from T0040_General_Setting WITH (NOLOCK)
					where Cmp_ID = @Cmp_ID and Branch_ID=@Branch_ID and  For_Date=@For_Date
					

	
	RETURN




