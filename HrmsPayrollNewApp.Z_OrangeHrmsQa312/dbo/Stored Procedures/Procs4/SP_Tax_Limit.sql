


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_Tax_Limit] 
	@Cmp_ID numeric,
	@Gender char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @for_Date dateTime
	
	Select @for_Date =Max(For_Date) from T0040_Tax_limit WITH (NOLOCK) where cmp_ID=@Cmp_ID and Gender =@Gender
	
	Select * from T0040_Tax_Limit WITH (NOLOCK) where cmp_ID=@Cmp_ID and Gender = @Gender and for_Date =@For_Date	
		
	

	RETURN




