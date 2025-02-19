---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_APPLICATION_DETAILS_CommonWebservice]
	@Month int,
	@Year int,
	@CMP_ID	 NUMERIC(18,0)=0,
	@Emp_Code VARCHAR(50)=''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
BEGIN 
	
	SELECT EM.Alpha_Emp_Code,LM.Leave_Code,LM.Leave_Name, CONVERT(varchar(11),ISNULL(LT.For_Date,''),103) AS For_Date,
	--ISNULL(LT.For_Date,'') AS For_Date,
	       convert(decimal(18,2),(LT.Leave_Used + LT.Back_Dated_Leave)) AS 'Leave_Used',LT.Cmp_ID
	FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
	INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LT.Emp_ID = EM.Emp_ID
	WHERE MONTH(LT.For_Date) = @Month AND YEAR(LT.For_Date) = @Year
	      AND LT.Cmp_ID = @CMP_ID AND (EM.Alpha_Emp_Code = @Emp_Code or isnull(@Emp_Code,'')= '')
	
	--SELECT LA.Leave_Application_ID,LA.Emp_ID,LA.Application_Date,LA.Application_Status,LA.Cmp_ID,LAD.Leave_ID,
	--LM.Leave_Name,LM.Leave_Code,LAD.From_Date,LAD.To_Date ,EM.Emp_code,EM.Alpha_Emp_Code
	--FROM T0100_LEAVE_APPLICATION LA
	--INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD ON LA.Leave_Application_ID = LAD.Leave_Application_ID
	--INNER JOIN T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID
	--INNER JOIN T0080_EMP_MASTER EM ON LA.Emp_ID = EM.Emp_ID 
	--WHERE MONTH(LA.Application_Date) = @Month AND YEAR(LA.Application_Date) = @Year

END
