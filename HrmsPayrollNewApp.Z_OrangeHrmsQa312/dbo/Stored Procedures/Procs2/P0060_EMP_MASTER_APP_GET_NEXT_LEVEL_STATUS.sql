


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_GET_NEXT_LEVEL_STATUS]
	-- Add the parameters for the stored procedure here
	@EMP_TRAN_ID BIGINT = 0,
	@APPROVE_STATUS CHAR(1) ='' OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    -- Insert statements for procedure here
	SELECT  @APPROVE_STATUS = AP.Approve_Status 
					   
	FROM	T0060_EMP_MASTER_APP AP WITH (NOLOCK)
	WHERE Ap.Ref_Emp_Tran_ID =@EMP_TRAN_ID
	
	select @APPROVE_STATUS as APPROVE_STATUS
END


