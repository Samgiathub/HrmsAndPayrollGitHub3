



-- =============================================
-- Author:		Binal Prajapati
-- Create date: 01-01-2019
-- Description:	Check Reporting Level
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Check_Next_Reporting_Level_Pending] 
	-- Add the parameters for the stored procedure here
	@Ref_Emp_Tran_ID BIGINT,
	@Status Char(1)='P',
	@IS_Pending TinyInt =0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    -- Insert statements for procedure here
	SELECT  @IS_Pending= Count(1) FROM T0060_EMP_MASTER_APP WITH (NOLOCK) where Ref_Emp_Tran_ID =@Ref_Emp_Tran_ID and Approve_Status=@Status
	 
	-- SELECT @IS_Pending
END

