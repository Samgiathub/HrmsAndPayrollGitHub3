

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 23-Jul-2015
-- Description:	For Insert/Update/Delete/View GPF Interest Rate
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_GPF_INTEREST_RATE] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID			numeric(18,0), 
	@Tran_ID		numeric(18,0) output,
	@AD_ID			numeric(18,0), 
	@Effective_Date DateTime,
	@Interest_Rate	numeric(18,4),
	@Trans_Type		tinyint = 1
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	IF @Trans_Type = 2	--FOR DELETE
	BEGIN
		DELETE FROM T0060_GPF_INTEREST_RATE WHERE Tran_ID=@TRAN_ID
		RETURN;
	END
	
	IF NOT EXISTS(SELECT 1 FROM T0050_AD_MASTER	WITH (NOLOCK) WHERE AD_ID=@AD_ID AND CMP_ID=@CMP_ID)
		RAISERROR('Allowance does not exist in database.', 1, 10);
	
	IF IsNull(@Tran_ID,0) = 0 
	BEGIN
		SELECT	@Tran_ID=Tran_ID 
		FROM	T0060_GPF_INTEREST_RATE WITH (NOLOCK)
		WHERE	Cmp_ID=@CMP_ID AND AD_ID=@AD_ID AND Effective_Date=@EFFECTIVE_DATE
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM T0060_GPF_INTEREST_RATE WITH (NOLOCK) WHERE	Cmp_ID=@CMP_ID AND AD_ID=@AD_ID AND Effective_Date=@EFFECTIVE_DATE AND Tran_ID<>@TRAN_ID)
		BEGIN
			RAISERROR('Another record already exist with the same date.', 1, 10);
		END
	END 
	
	IF IsNull(@Tran_ID,0) = 0
	BEGIN
		SELECT @Tran_ID=IsNull(Max(Tran_ID),0) + 1 FROM T0060_GPF_INTEREST_RATE WITH (NOLOCK) 
		
		INSERT INTO T0060_GPF_INTEREST_RATE(Cmp_ID,Tran_ID,AD_ID,Effective_Date,Interest_Rate,System_date)
		VALUES(@CMP_ID,@TRAN_ID,@AD_ID,@EFFECTIVE_DATE,@INTEREST_RATE,GETDATE());
	END
	ELSE
	BEGIN
		UPDATE	T0060_GPF_INTEREST_RATE
		SET		Interest_Rate=@INTEREST_RATE
		WHERE	Cmp_ID=@CMP_ID AND AD_ID=@AD_ID AND Tran_ID=@TRAN_ID
	END
   
END

