

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[Delete_SP_Minimum_Wages]
	@cmp_ID numeric,
	@State_ID numeric,
	@Effective_Date datetime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	delete from T0050_Minimum_Wages_Master where cmp_Id = @cmp_ID and State_ID = @State_ID and  CONVERT(varchar(25),Effective_Date,103) = Convert(varchar(25),@Effective_Date,103) -- Replace(Convert(varchar(25),Effective_Date,103),' ','/') = @Effective_Date 
END

