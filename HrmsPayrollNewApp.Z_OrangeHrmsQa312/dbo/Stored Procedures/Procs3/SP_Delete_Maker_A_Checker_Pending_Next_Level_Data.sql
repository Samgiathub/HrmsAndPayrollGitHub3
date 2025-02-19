


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

-- =============================================
CREATE PROCEDURE [dbo].[SP_Delete_Maker_A_Checker_Pending_Next_Level_Data]
	-- Add the parameters for the stored procedure here
	@Ref_Emp_Tran_ID BIGINT =1  Output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Emp_Tran_ID AS BIGINT
	SET @Emp_Tran_ID =@Ref_Emp_Tran_ID	
    -- Insert statements for procedure here
	--SELECT @Emp_Tran_ID=Emp_Tran_ID FROM T0060_EMP_MASTER_APP WHERE Ref_Emp_Tran_ID=@Ref_Emp_Tran_ID
	
	
	Delete From  T0060_EMP_MASTER_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_REPORTING_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_SHIFT_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_CHILDRAN_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_CONTRACT_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_DEPENDANT_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0070_EMP_INCREMENT_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0075_EMP_EARN_DEDUCTION_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_DOC_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_EXPERIENCE_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_IMMIGRATION_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID
    Delete From  T0065_EMP_LANGUAGE_DETAIL_APP WHERE Emp_Tran_ID=@Emp_Tran_ID

END


