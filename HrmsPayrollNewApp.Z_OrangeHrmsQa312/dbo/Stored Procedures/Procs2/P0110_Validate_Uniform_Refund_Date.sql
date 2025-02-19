-- =============================================
-- Author:		Binal Prajapati
-- Create date: 01092020
-- Description:	This sp used for validate refund date
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--========================================
-- =============================================
CREATE PROCEDURE [dbo].[P0110_Validate_Uniform_Refund_Date]
	-- Add the parameters for the stored procedure here
	@DispatchDate DateTime,
	@DedcutionInstall INT,
	@RefundDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @DeductionCompleteDate DateTime
    -- Insert statements for procedure here
	SET @DeductionCompleteDate= DATEADD(MONTH,@DedcutionInstall,@DispatchDate) 
	
	IF @RefundDate <= @DeductionCompleteDate
	BEGIN
		RAISERROR ('@@Refund Date Must Be Start After Deduction Installment Completed.@@', 16, 2)
		RETURN
	END
	ELSE
	BEGIN
		SELECT 1  AS Valid
	END
			
END
