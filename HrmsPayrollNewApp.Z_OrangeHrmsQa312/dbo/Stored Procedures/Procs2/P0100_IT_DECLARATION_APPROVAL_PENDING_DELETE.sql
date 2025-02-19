

-- =============================================
-- Author:		<Author,,Jimit>
-- Create date: <Create Date,,13032019>
-- Description:	<Description,,For deleting Approval And Pending IT Declaration Records>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_IT_DECLARATION_APPROVAL_PENDING_DELETE]
	@IT_TRAN_ID		NUMERIC output, 
	@CMP_ID			NUMERIC, 
	@IT_ID			NUMERIC, 
	@EMP_ID			NUMERIC, 
	@FOR_DATE		DATETIME, 	
	@FINANCIAL_YEAR VARCHAR(20),	
	@Type			VARCHAR(200) = 'Pending'		
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Type ='Approved'
		BEGIN			
				
				
				UPDATE    T0100_IT_DECLARATION
				SET       Is_Lock = 0,
						  AMOUNT = AMOUNT_ESS,
						  DOC_NAME = CASE WHEN AMOUNT_ESS = 0 THEN '' ELSE DOC_NAME END				--Changed by Jimit 06092019 As per redmine bug No 1578	  
				WHERE	  IT_TRAN_ID = @IT_TRAN_ID
		END
	ELSE IF @Type ='Pending'
		BEGIN
				DELETE FROM T0100_IT_DECLARATION WHERE IT_TRAN_ID = @IT_TRAN_ID
				DELETE FROM T0110_IT_Emp_Details WHERE IT_ID = @IT_ID AND Financial_Year = @FINANCIAL_YEAR and Emp_Id = @EMP_ID
		END
RETURN

