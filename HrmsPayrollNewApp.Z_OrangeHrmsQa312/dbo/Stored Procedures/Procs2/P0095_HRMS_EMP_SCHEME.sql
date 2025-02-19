


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_HRMS_EMP_SCHEME]
	 @Tran_ID			NUMERIC(18,0) OUTPUT
	,@Cmp_ID			NUMERIC(18,0)
	,@Resume_ID			NUMERIC(18,0)
	,@Scheme_ID			NUMERIC(18,0)
	,@Type				VARCHAR(100)
	,@Tran_Type			VARCHAR(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	IF @Tran_Type = 'I'
		BEGIN
			--If Exists(Select Tran_ID From T0095_HRMS_EMP_SCHEME  Where Cmp_ID = @Cmp_ID and Resume_ID = @Resume_ID And Type = @Type)
				--Begin
											
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_HRMS_EMP_SCHEME WITH (NOLOCK)
					Insert Into T0095_HRMS_EMP_SCHEME(Tran_ID, Cmp_ID, Resume_ID, Scheme_ID, Type)
					Values(@Tran_ID, @Cmp_ID, @Resume_ID, @Scheme_ID, @Type)
				--End
		END

END


