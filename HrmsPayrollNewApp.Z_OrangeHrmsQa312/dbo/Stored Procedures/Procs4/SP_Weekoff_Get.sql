


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_Weekoff_Get] 
	@Cmp_ID numeric,
	@Branch_ID numeric

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

if exists(Select  cmp_ID from T0040_Weekoff_Master WITH (NOLOCK) where  Branch_ID  = @Branch_ID)
	begin
		Select  * from T0040_Weekoff_Master WITH (NOLOCK) where  isnull(Branch_ID,0) = @Branch_ID	 and cmp_ID =@Cmp_ID
	end
else
	begin
		Select  * from T0040_Weekoff_Master WITH (NOLOCK) where  isnull(Branch_ID,0) = 0 and cmp_ID =@Cmp_ID
	end

		
	RETURN




