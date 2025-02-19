


-- =============================================
-- Author:		<Author,,Jimit Soni>
-- Create date: <Create Date,,16042019>
-- Description:	<Description,,For WHFl Laps CF Leaves from Last Year>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Laps_CF_Leaves_Last_Year]
	@CMP_ID		 NUMERIC(18,0),
	@LEAVE_ID	 NUMERIC(18,0),
	@EMP_ID		 NUMERIC(18,0),
	@FOR_DATE	 DATETIME,
	@CF_TO_DATE	 DATETIME,
	@Type_Id     Numeric,
	@CF_Laps_Days	 NUMERIC(18,5) output
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
				DECLARE @Release_MONTH			TINYINT	
				--DECLARE @Release_DATE			DATETIME	
				DECLARE @Laps_Date				DATETIME
				DECLARE @CLOSING_BALANCE_DATE	DATETIME
				DECLARE @QUARTER_END_DATE		DATETIME
				DECLARE @LAPS_MONTH				TINYINT
				DECLARE @LEAVE_CLOSING			NUMERIC(18,5)
				DECLARE @LEAVE_USED				NUMERIC(18,5)		
				DECLARE @LAPS_DAYS				NUMERIC(18,5)
				DECLARE @NEGETIVE_MAX_LIMIT		NUMERIC
				DECLARE @LEAVE_TRAN_ID			NUMERIC			
				DECLARE @TEMPDATE DATETIME = '1900-01-01'
				declare @Last_Leave_Closing		numeric(18,5)
				SET @LEAVE_USED = 0
				SET @LEAVE_CLOSING = 0
				SET @LAPS_DAYS = 0
				SET @NEGETIVE_MAX_LIMIT = 0		

				--set @Leave_Laps = 0

				IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Default_Short_Name IN ('COMP', 'COND', 'COPH') AND LEAVE_ID = @LEAVE_ID)
					RETURN

				SELECT  @Release_MONTH = QW.Release_Month,
						@LAPS_MONTH = QW.LAPS_AFTER_RELEASE
				FROM	T0040_TYPE_MASTER T WITH (NOLOCK) INNER JOIN 
						(
							SELECT	C.EFFECTIVE_DATE,C.LEAVE_ID,TYPE_ID,C.LAPS_AFTER_RELEASE,
									Release_Month
							FROM	T0050_CF_EMP_TYPE_DETAIL C WITH (NOLOCK) INNER JOIN
									(
										SELECT	MAX(EFFECTIVE_DATE) EFFECTIVE_DATE
										FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
										WHERE	CMP_ID = @CMP_ID AND LEAVE_ID = @LEAVE_ID AND TYPE_ID = @TYPE_ID								
									) QRY ON    C.EFFECTIVE_DATE=QRY.EFFECTIVE_DATE
						) QW ON QW.TYPE_ID = T.TYPE_ID  AND QW.LEAVE_ID = @LEAVE_ID 
				WHERE	T.CMP_ID=@CMP_ID 

				DECLARE @RELEASE_DATE DATETIME  
				

				SET @RELEASE_DATE = DATEADD(YYYY, YEAR(@CF_TO_DATE) - 1900, '1900-01-01')
				SET @RELEASE_DATE = DATEADD(M, @Release_MONTH - 1, @RELEASE_DATE) 

				SET @LAPS_DATE  = DATEADD(M, @LAPS_MONTH, @RELEASE_DATE) - 1

				
				--SET	@Release_DATE = dbo.GET_MONTH_ST_DATE(@Release_MONTH,YEAR(@CF_TO_DATE))		
				--SET @LAPS_DATE = DATEADD(D,DAY(@CF_TO_DATE) * - 1,@CF_TO_DATE)
				--SET @LAPS_DATE = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(M,(@Release_MONTH - 1 + @LAPS_MONTH), @TEMPDATE)),YEAR(@CF_TO_DATE)))		
				--SET @CLOSING_BALANCE_DATE = DATEADd(D,-1,@Release_DATE)		

				IF MONTH(@CF_TO_DATE) <> MONTH(@LAPS_DATE)      --If Carry forward month is not match with Laps month then Return
					RETURN
				
				SELECT	@LEAVE_CLOSING = Leave_closing
				FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
						INNER JOIN (
									SELECT		MAX(FOR_DATE) FOR_DATE,EMP_ID,LEAVE_Id
									FROM		T0140_LEAVE_TRANSACTION WITH (NOLOCK)
									WHERE		EMP_ID = @EMP_ID AND FOR_DATE < @RELEASE_DATE
												AND LEAVE_Id = @LEAVE_ID
									GROUP BY	EMP_ID,LEAVE_Id )Q ON LT.EMP_ID = Q.EMP_ID AND Q.FOR_DATE = LT.FOR_DATE AND Q.Leave_ID = LT.Leave_ID 
				WHERE	LT.EMP_ID = @EMP_ID 

				SELECT	@LEAVE_USED = ISNULL(SUM(LEAVE_USED),0) + IsNull(SUM(Leave_Adj_L_Mark),0) + IsNull(SUM(Arrear_Used),0) +
									  IsNull(SUM(Leave_Encash_Days),0) + IsNull(SUM(Back_Dated_Leave),0)+ IsNULL(SUM(CF_Laps_Days),0)
				FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				WHERE	FOR_DATE BETWEEN @RELEASE_DATE AND @LAPS_DATE 
						AND LEAVE_ID = @LEAVE_ID AND EMP_ID = @EMP_ID
			
			 

				--IF @LEAVE_CLOSING - @LEAVE_USED < 0  --If Closing Balance of Leave is less then Leave used then Return
				--	RETURN

				SELECT  @NEGETIVE_MAX_LIMIT = ISNULL(LEAVE_NEGATIVE_MAX_LIMIT,0)
				FROM	T0040_LEAVE_MASTER WITH (NOLOCK)
				WHERE	LEAVE_Id = @LEAVE_ID AND LEAVE_NEGATIVE_ALLOW = 1

				--IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WHERE LEAVE_Id = @LEAVE_ID AND LEAVE_NEGATIVE_ALLOW = 1)
				--	BEGIN
				--		SELECT  @NEGETIVE_MAX_LIMIT = ISNULL(LEAVE_NEGATIVE_MAX_LIMIT,0)
				--		FROM	T0040_LEAVE_MASTER
				--		WHERE	LEAVE_Id = @LEAVE_ID AND LEAVE_NEGATIVE_ALLOW = 1
				--	END

				--Default Laps Days (Leave Closing Before Release Month - Total Leave Used During Laps Period)
				SET @LAPS_DAYS = @LEAVE_CLOSING - @LEAVE_USED

				--IF Employee has used all the leaves carryforwarded from the last year then no need to process for Laps Days
				IF @LAPS_DAYS < 0
					RETURN

				--If Closing balance is less than Laps days and also allowed Negative Limit then what Laps Days should be calculated
				/*i.e. 
					if ( 5 (CL)  + 2 (NL)) < 10 (LD)
						SET @LAPS_DAYS = 5 (CL) + 2 (NL)

					Result : 7 Days will be laps and -2 will be as Closing (Cause negative allowed)
				*/
				IF (@LEAVE_CLOSING + @NEGETIVE_MAX_LIMIT) <	@LAPS_DAYS
					SET @LAPS_DAYS = @LEAVE_CLOSING + @NEGETIVE_MAX_LIMIT 
						  

				--IF ((@LEAVE_CLOSING + @NEGETIVE_MAX_LIMIT) < @LAPS_DAYS)
				--	SET @LEAVE_CLOSING = @LEAVE_CLOSING + @NEGETIVE_MAX_LIMIT
				--ELSE
				--	SET @LEAVE_CLOSING = (@LEAVE_CLOSING + @NEGETIVE_MAX_LIMIT) - @LAPS_DAYS									
									
					--SELECT @LAPS_DAYS,@LEAVE_CLOSING,@LEAVE_USED,@LEAVE_TRAN_ID,@LAPS_DAYS
					
				
				SET @Laps_Date = @Laps_Date + 1 --To Take 1st Of Next Month (i.e.  30-Jun + 1 = 01-Jul)
				IF EXISTS(
							Select	1 
							FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
							WHere	Emp_Id = @EMP_ID AND LEAVE_Id = @LEAVE_ID AND CMP_ID = @CMP_ID 
									AND FOR_DATE = @Laps_Date
						 )
					BEGIN
							UPDATE T0140_LEAVE_TRANSACTION 
							SET		CF_LAPS_DAYS = @LAPS_DAYS,
									LEAVE_CLOSING = (ISNULL(LEAVE_OPENING,0) + ISNULL(LEAVE_CREDIT,0)) - (@LAPS_DAYS + ISNULL(LEAVE_USED,0) + IsNull(Leave_Adj_L_Mark,0) + IsNull(Arrear_Used,0) +
																											IsNull(Leave_Encash_Days,0) + IsNull(Back_Dated_Leave,0)+ IsNULL(CF_Laps_Days,0))
							WHERE	EMP_ID = @EMP_ID AND LEAVE_ID = @LEAVE_ID AND CMP_ID = @CMP_ID 
									AND FOR_DATE = @Laps_Date			
									 
							
					END
				ELSE
					BEGIN
							
							SELECT	@LAST_LEAVE_CLOSING = ISNULL(LEAVE_CLOSING,0) 
							FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
							WHERE	FOR_DATE = (
													SELECT	MAX(FOR_DATE) 
													FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													WHERE	FOR_DATE < @Laps_Date AND LEAVE_ID = @LEAVE_ID 
															AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID
												) 
									 AND CMP_ID = @CMP_ID AND LEAVE_ID = @LEAVE_ID AND EMP_ID = @EMP_ID
							
													
							SELECT @LEAVE_TRAN_ID = ISNULL(MAX(LEAVE_TRAN_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)

					

							INSERT T0140_LEAVE_TRANSACTION(EMP_ID,LEAVE_ID,CMP_ID,FOR_DATE,LEAVE_OPENING,LEAVE_CREDIT,
										LEAVE_CLOSING,LEAVE_USED,LEAVE_TRAN_ID,COMOFF_FLAG,CF_LAPS_DAYS)
							VALUES(@EMP_ID,@LEAVE_ID,@CMP_ID,@Laps_Date,@LAST_LEAVE_CLOSING,0
									,@LAST_LEAVE_CLOSING - @LAPS_DAYS,0,@LEAVE_TRAN_ID,0,@LAPS_DAYS)
							
							--UPDATE	T
							--SET		LEAVE_CLOSING = LEAVE_OPENING + LEAVE_CREDIT - (LEAVE_USED + ISNULL(LEAVE_ADJ_L_MARK,0) + ISNULL(COMPOFF_USED,0) + ISNULL(CF_LAPS_DAYS,0))
							--FROM	T0140_LEAVE_TRANSACTION  T		
							--		INNER JOIN T0040_LEAVE_MASTER LM ON T.LEAVE_ID=LM.LEAVE_ID
							--WHERE	T.LEAVE_ID = @LEAVE_ID AND FOR_DATE = DATEADD(M, @LAPS_MONTH, @RELEASE_DATE) 
							--		AND T.CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID
							
							--IF @For_Date = '2018-07-01'
								--select  'Laps Days', * from T0140_LEAVE_TRANSACTION Where Emp_ID=@Emp_ID and Leave_ID=@Leave_ID AND For_Date='2018-07-01'
							
					END
				
					SET @CF_Laps_Days = @LAPS_DAYS

								
					--EXEC dbo.P_Update_Leave_Transaction @Emp_ID=@Emp_Id,@Leave_ID=@Leave_Id,@For_Date=@For_Date
					--select * from T0140_LEAVE_TRANSACTION where EMP_ID = 14842 and LEAVE_ID = 1194 and For_date = '2018-07-01 00:00:00'
								
					--SET @Leave_Laps = 1



		END
	



