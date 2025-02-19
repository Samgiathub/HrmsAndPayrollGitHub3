

 ---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Route_Vehicle_Details]
	@Assign_ID numeric(18,0) OUTPUT,
	@Vehicle_ID numeric(18,0),
	@Route_ID numeric(18,0),
	@Effective_Date datetime,
	@Cmp_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@Trans_Type char(1)
	
AS
BEGIN
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	
	IF @Trans_Type  = 'I'
		BEGIN
			SELECT @Assign_ID = ISNULL(MAX(Assign_ID),0) + 1 FROM T0050_Route_Vehicle_Details WITH (NOLOCK)
			INSERT INTO T0050_Route_Vehicle_Details(Assign_ID,Vehicle_ID,Route_ID,Effective_Date,Cmp_ID,Created_By,Created_Date)
			VALUES(@Assign_ID,@Vehicle_ID,@Route_ID,@Effective_Date,@Cmp_ID,@Login_ID,GETDATE())
		END
	ELSE IF @Trans_Type  = 'D'
		BEGIN
			DELETE FROM T0050_Route_Vehicle_Details WHERE Assign_ID = @Assign_ID 
		END

END
