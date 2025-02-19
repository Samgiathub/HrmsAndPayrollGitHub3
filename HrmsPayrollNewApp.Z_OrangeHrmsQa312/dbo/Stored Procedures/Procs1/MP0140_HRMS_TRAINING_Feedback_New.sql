

 
 ---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[MP0140_HRMS_TRAINING_Feedback_New]
	@Training_ID numeric(18,0),
	@Tran_Emp_Detail_Id numeric(18,0),
	@Cmp_Id numeric(18,0),
	@Is_Attend int,
	@Emp_Score numeric(18,2),
	@Question XML,
	@Result varchar(100) OUTPUT
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Tran_Feedback_ID numeric(18,0)
DECLARE @Que_ID numeric(18,0)
DECLARE @Ans varchar(150)
SET @Tran_Feedback_ID = 0

BEGIN TRY
	
	EXEC P0140_HRMS_TRAINING_Feedback_New @Tran_Feedback_ID,@Tran_Emp_Detail_Id,@Cmp_Id,@Is_Attend,'',@Emp_Score,0.00,'','',NULL,1,'I'
	
	SELECT @Tran_Feedback_ID = MAX(Tran_Feedback_ID) FROM T0140_HRMS_TRAINING_Feedback_New WITH (NOLOCK)
		
	SELECT Table1.value('(Que_ID/text())[1]','numeric(18,0)') AS Que_ID,
	Table1.value('(Ans/text())[1]','varchar(150)') AS Ans
    INTO #QueTemp from @Question.nodes('/NewDataSet/Table1') AS Temp(Table1)
    
    DECLARE Que_CURSOR CURSOR  FAST_FORWARD FOR
    SELECT Que_ID,Ans FROM #QueTemp
    OPEN Que_CURSOR
    FETCH NEXT FROM Que_CURSOR INTO @Que_ID,@Ans
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC P0150_HRMS_TRAINING_Answers 0,@Tran_Feedback_Id=@Tran_Feedback_ID,@Tran_Emp_Detail_Id=@Tran_Emp_Detail_Id,@Tran_Question_Id=@Que_ID,@Answer=@Ans,@Cmp_Id=@Cmp_Id,@Trans_Type='I',@emp_Id=0,@Training_id=@Training_ID,@Training_Apr_ID=0,@User_Id=0,@IP_Address=''
			FETCH NEXT FROM Que_CURSOR INTO @Que_ID,@Ans
		END
    CLOSE Que_CURSOR
    DEALLOCATE Que_CURSOR
    
    SET @Result = 'Training Feedback Done'
    
END TRY
BEGIN CATCH
	SET @Result = ERROR_MESSAGE()
	ROLLBACK 
END CATCH


