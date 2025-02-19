



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0501_FollowLead_History]
	@Tran_ID NUMERIC(18,0)
	, @LEAD_ID NUMERIC(18,0)
	, @Assigned_TO NUMERIC(18,0)
	, @Assigned_Date DATETIME
	, @Login_ID NUMERIC(18,0)
	, @CmpID NUMERIC(18,0)
	, @TranType CHAR(1) = 'I'
	, @Result VARCHAR(256) OUTPUT
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	IF @TranType = 'I'
		BEGIN
		
			SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0501_FollowLead_History WITH (NOLOCK)
			
			INSERT INTO T0501_FollowLead_History (Tran_ID,LEAD_ID,Assigned_TO,Assigned_Date,CmpID,Modified_By,Modified_Date)
			VALUES (@Tran_ID,@LEAD_ID,@Assigned_TO,@Assigned_Date,@CmpID, @Login_ID,GETDATE())
			
			SET @Result = '1:Assigned Successfully.!'
			
		END
END
