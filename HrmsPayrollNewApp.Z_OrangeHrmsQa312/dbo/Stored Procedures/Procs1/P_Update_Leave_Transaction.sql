

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 14-Mar-2018
-- Description:	To Update The Leave Closing Balance By Given Date
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Update_Leave_Transaction] 
	@Emp_ID		Numeric, 
	@Leave_ID	Numeric,
	@For_Date	DateTime
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #EMP_CONS_LT
	(
		EMP_ID	 NUMERIC
	)
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_TRAN ON #EMP_CONS_LT(EMP_ID)

	INSERT INTO #EMP_CONS_LT 
	SELECT DISTINCT EMP_ID
	FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
	WHERE	T.Emp_ID=ISNULL(@Emp_ID, T.EMP_ID)
			AND T.For_Date >= @For_Date

	DECLARE @Leave_Tran_ID Numeric
	DECLARE @Leave_Posting Numeric(18,4)
	DECLARE @Leave_Opening Numeric(18,4)

	DECLARE curEmp Cursor Fast_Forward For
	Select Emp_ID FROM #EMP_CONS_LT

	OPEN curEmp 
	FETCH NEXT FROM curEmp INTO @Emp_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE curLeave Cursor Fast_Forward For
			SELECT	Leave_Tran_ID,Leave_Posting
			FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
			Where	Emp_ID = @Emp_ID AND Leave_ID = @Leave_ID AND For_Date >= @For_Date --I Have used >= because if updated Leave Transaction has Posting Value then Balance Should not be updated for rest of the records after @For_Date
			Order By For_Date 

			OPEN curLeave

			FETCH FROM curLeave INTO @Leave_Tran_ID,@Leave_Posting
			WHILE	@@FETCH_STATUS=0
				BEGIN
					IF @Leave_Posting Is Not NULL
						AND EXISTS(SELECT 1 FROM T0095_LEAVE_OPENING WITH (NOLOCK) Where Emp_Id=@Emp_ID AND For_Date=@For_Date AND Leave_ID=@Leave_ID)
						BEGIN
							SELECT @Leave_Opening = Leave_Op_Days FROM T0095_LEAVE_OPENING WITH (NOLOCK) Where Emp_Id=@Emp_ID AND For_Date=@For_Date AND Leave_ID=@Leave_ID
						END

					Update	T
					Set		Leave_Opening = COALESCE(@Leave_Opening, Leave_Opening, 0),
							Leave_Closing = ( COALESCE(@Leave_Opening, Leave_Opening, 0) + Leave_Credit) - (Leave_Used + IsNull(Leave_Adj_L_Mark,0) + IsNull(Arrear_Used,0) + IsNull(Leave_Encash_Days,0) + IsNull(Back_Dated_Leave,0)+ IsNULL(CF_Laps_Days,0))
					From	T0140_LEAVE_TRANSACTION T
					Where	T.Leave_Tran_ID = @Leave_Tran_ID

					SELECT	@Leave_Opening = Leave_Closing
					FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
					Where	Leave_Tran_ID = @Leave_Tran_ID



					If @Leave_Posting IS NOT NULL
						BEGIN
							Update	T
							Set		Leave_Posting = Leave_Closing,
									Leave_Closing = 0
							From	T0140_LEAVE_TRANSACTION T
							Where	T.Leave_Tran_ID = @Leave_Tran_ID							
							SET @Leave_Opening = 0
						END
			
					FETCH FROM curLeave INTO @Leave_Tran_ID,@Leave_Posting
				END	
			CLOSE curLeave
			DEALLOCATE curLeave
		END
	CLOSE curEmp
	DEALLOCATE curEmp
END

