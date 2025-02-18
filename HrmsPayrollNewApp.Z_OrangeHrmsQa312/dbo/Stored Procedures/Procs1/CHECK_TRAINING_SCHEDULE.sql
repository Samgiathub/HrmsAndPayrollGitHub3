﻿


-- =============================================
-- AUTHOR:		<AUTHOR,,GADRIWALA MUSLIM>
-- CREATE DATE: <CREATE DATE,,01122016>
-- DESCRIPTION:	<DESCRIPTION,,CHECK EMPLOYEE TRAINING HAVE BEEND SCHEDULED OR NOT>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[CHECK_TRAINING_SCHEDULE]
	 @CMP_ID AS NUMERIC(18,0)
	,@EMP_ID AS NUMERIC(18,0)
	,@FROM_DATE AS DATETIME
	,@TO_DATE AS DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF EXISTS(SELECT 1 FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL HTED WITH (NOLOCK)
		INNER JOIN (
						SELECT MIN(FROM_DATE) as FROM_DATE,MAX(TO_DATE) as TO_DATE,TRAINING_APP_ID FROM T0120_HRMS_TRAINING_SCHEDULE WITH (NOLOCK)
						GROUP BY TRAINING_APP_ID
					)QRY ON  HTED.TRAINING_APP_ID = QRY.TRAINING_APP_ID
		WHERE EMP_TRAN_STATUS = 1 AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID
		AND  ((QRY.FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE)  OR (QRY.TO_DATE BETWEEN @FROM_DATE AND @TO_DATE)))
		BEGIN
			SELECT 'Training has been scheduled on leave days.'	as Training_msg
		END
	ELSE
		BEGIN
				SELECT '' as Training_msg	
		END		
				
		
    -- Insert statements for procedure here
	
END

