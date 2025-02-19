

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 04-March-2016
-- Description:	For Importing Advance
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_EMP_ADVANCE_IMPORT]			-- CREATED BY SHAIKH RAMIZ ON 04-MARCH-2016
 @Adv_ID			NUMERIC OUTPUT
,@Cmp_ID			NUMERIC
,@Alpha_Emp_Code	VARCHAR(50)
,@Emp_Full_Name		VARCHAR(150)
,@For_date			DATETIME
,@Advance_Amount	VARCHAR(150)
,@Reason_Name		VARCHAR(150)
,@Remarks			VARCHAR(150)
,@User_Id			numeric(18,0) = 0
,@IP_Address		varchar(30)= ''
,@Log_Status		Int = 0 Output
,@Row_No			Int
,@GUID				Varchar(2000) = '' --Added by nilesh patel on 15062016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Emp_ID			NUMERIC
	DECLARE @Res_ID			NUMERIC
	DECLARE @PREV_AMOUNT	NUMERIC
	DECLARE @Adv_Tran_ID	NUMERIC
	DECLARE @Last_Closing	NUMERIC
	DECLARE @Pre_Closing	NUMERIC
	DECLARE @CHG_TRAN_ID NUMERIC    
	DECLARE @FOR_DATE_CUR DATETIME 
  	DECLARE @EMP_LEFT AS CHAR
  	
	SET @Emp_ID  = 0
	SET @Res_ID  = 0
	SET @Pre_Closing = 0
	SET @Last_Closing = 0
	SET @EMP_LEFT = ''
	
	
	
	IF @Advance_Amount > 0	/* POSITIVE ADVANCE CAN ONLY BE PROVIDED TO ACTIVE EMPLOYEES */
		BEGIN
			
			SELECT TOP 1 @EMP_ID = EMP_ID , @EMP_LEFT = EMP_LEFT FROM T0080_EMP_MASTER WITH (NOLOCK)
			WHERE UPPER(ALPHA_EMP_CODE) = UPPER(@ALPHA_EMP_CODE) AND CMP_ID = @CMP_ID 
			ORDER BY EMP_ID DESC
			
			IF @EMP_LEFT = 'Y'
			BEGIN
				INSERT INTO dbo.T0080_Import_Log 
				VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee is Left',@Alpha_Emp_Code,'This Employee is Already Left.So You Cannot Provide Advance',GETDATE(),'Employee Advance Import',@GUID)  
				SET @Log_Status = 1
				RETURN -1
			END
			
		END
	ELSE
		BEGIN	/* NEGATIVE ADVANCE CAN BE PROVIDED TO ALL EMPLOYEES */
			SELECT @EMP_ID = EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK)
			WHERE UPPER(ALPHA_EMP_CODE) = UPPER(@ALPHA_EMP_CODE) AND CMP_ID = @CMP_ID
		END
	
	IF @REASON_NAME <> ''
	BEGIN
		SELECT @RES_ID = RES_ID FROM T0040_REASON_MASTER WITH (NOLOCK) WHERE REASON_NAME = @REASON_NAME AND TYPE = 'ADVANCE'
	END
	
	IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND @For_Date >= Month_St_Date AND @For_Date <= Month_End_Date)
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Salary Exists',@Alpha_Emp_Code,'This Months Salary Exists.So You Can not Import Advance',GETDATE(),'Employee Advance Import',@GUID)  
			SET @Log_Status=1
			RETURN -1
		END
	ELSE
		BEGIN
			IF @EMP_ID = 0
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Code not Exists in Hrms',@Alpha_Emp_Code,'Verify Employee Code as per Hrms employee Master',GETDATE(),'Employee Advance Import',@GUID)
					SET @Log_Status=1
					RETURN
				END
			IF @For_date is NULL
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'For Date not Exists in Hrms',@Alpha_Emp_Code,'Enter Valid For Date',GETDATE(),'Employee Advance Import',@GUID)
					SET @Log_Status=1
					RETURN
				END
			IF @RES_ID = 0 AND @REASON_NAME <> ''
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Reason not Exists in Hrms',@Reason_Name,'Verify Reason Name as per Hrms Reason Master',GETDATE(),'Employee Advance Import',@GUID)  
					SET @Log_Status=1
					RETURN
				END	
			IF EXISTS(SELECT Adv_ID FROM T0100_ADVANCE_PAYMENT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND For_Date= @For_Date AND Res_id = @Res_ID and @Advance_Amount > 0)	
				BEGIN
					INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'This Entry is Already Imported',@For_Date,'This Entry is Already Imported',GETDATE(),'Employee Advance Import',@GUID)  
					SET @Log_Status=1
					RETURN -1
				END

		/* HERE I HAVE ADDED 2 LOGICS
			1) IF IMPORT AMOUNT IS GREATER THAN 0 (i.e. POSITIVE), THEN IT WILL BE INSERTED IN ADVANCE PAYMENT AND TRANSACTION WILL BE SET FROM TRIGGER.
			2) IF AMOUNT IS LESS THAN 0 (i.e. NEGATIVE) , WE WILL DIRECTLY INSERT IT IN TRANSACTION TABLE IN ADVANCE RETURN COLUMN
		*/
			IF @Advance_Amount > 0	/* SCENERIO - 1 */
				BEGIN
					SELECT @ADV_ID = ISNULL(MAX(ADV_ID),0) + 1  FROM T0100_ADVANCE_PAYMENT	WITH (NOLOCK)
					
					INSERT INTO T0100_ADVANCE_PAYMENT
							(Adv_ID,Cmp_ID,Emp_ID,For_Date,Adv_Amount,Adv_P_Days,Adv_Approx_Salary,Adv_Comments,Res_id ,Adv_Approval_ID)
					VALUES   
							(@Adv_ID,@Cmp_ID,@Emp_ID,@For_Date,@Advance_Amount,0,0,@Remarks,@Res_ID,0)
										
				END
			ELSE			/* SCENERIO - 2 */
				BEGIN
					SELECT @Adv_Tran_ID = Isnull(Max(Adv_Tran_ID),0)  +1 From T0140_ADVANCE_TRANSACTION WITH (NOLOCK)
					
					SELECT @Last_Closing = ISNULL(Adv_Closing,0) 
					FROM T0140_ADVANCE_TRANSACTION WITH (NOLOCK)
					WHERE For_date = (
										SELECT MAX(for_date) FROM T0140_ADVANCE_TRANSACTION WITH (NOLOCK)
										WHERE for_date < @For_date and cmp_ID = @cmp_ID and emp_id = @emp_Id 
									 )	AND cmp_ID = @cmp_ID and emp_id = @emp_Id
			
					IF @Last_Closing IS NULL 
						SET  @Last_Closing = 0
								
					IF EXISTS(SELECT * FROM T0140_ADVANCE_TRANSACTION WITH (NOLOCK) WHERE for_date = @For_date and Cmp_ID = @Cmp_ID and emp_id = @Emp_id)
						BEGIN
							SELECT @PREV_AMOUNT = ISNULL(Adv_Return,0)
							FROM T0140_ADVANCE_TRANSACTION WITH (NOLOCK)
							WHERE FOR_DATE = @For_date and CMP_ID = @Cmp_ID and EMP_ID = @Emp_id
				
							IF ABS(@PREV_AMOUNT) = ABS(@Advance_Amount)
								BEGIN
									INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Same Date Entry is Not Allowed',@For_Date,'Same Date Entry is Not Allowed',GETDATE(),'Employee Advance Import',@GUID)  
									SET @Log_Status=1
									RETURN -1
								END
								
							IF ABS(@Advance_Amount) > ABS(@Last_Closing) 
								BEGIN
									INSERT INTO dbo.T0080_Import_Log 
									VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Imported Amount is More then Closing Amount',@For_Date,'Imported Amount is More then Closing Amount',GETDATE(),'Employee Advance Import',@GUID)  
									SET @Log_Status=1
									RETURN -1	
								END
								
								UPDATE T0140_ADVANCE_TRANSACTION 
								SET		Adv_Opening = @Last_Closing,
										Adv_Return = ABS(@Advance_Amount),
										Adv_Closing = @last_closing + @Advance_Amount	
								WHERE for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id
							
								SELECT @Pre_Closing = @last_closing + @Advance_Amount
							
								DECLARE cur1 CURSOR FOR   
									SELECT Adv_Tran_ID,For_Date FROM dbo.T0140_ADVANCE_TRANSACTION WITH (NOLOCK)
									WHERE For_date > @For_date and cmp_ID = @cmp_ID and emp_id = @emp_Id
									ORDER BY for_date  
								OPEN cur1  
								FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur  
									WHILE @@fetch_status = 0  
										BEGIN  

											UPDATE T0140_ADVANCE_TRANSACTION 
											SET		Adv_Opening = @Pre_Closing,
													Adv_Closing = @Pre_Closing + isnull(Adv_Issue,0) - isnull(Adv_Return,0)
											WHERE	FOR_DATE = @For_Date_Cur and CMP_ID = @Cmp_ID and EMP_ID = @Emp_id
											
											SET @Pre_Closing = ISNULL((SELECT isnull(Adv_Closing,0) FROM dbo.T0140_ADVANCE_TRANSACTION WITH (NOLOCK) WHERE Adv_Tran_ID = @Chg_Tran_Id),0)
											
											FETCH NEXT FROM cur1 INTO @Chg_Tran_Id,@For_Date_Cur  
										END  
								CLOSE cur1  
								DEALLOCATE cur1
						END
					ELSE
						BEGIN
							
							IF ABS(@Advance_Amount) > ABS(@Last_Closing) 
								BEGIN
									INSERT INTO dbo.T0080_Import_Log 
									VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Imported Amount is More then Closing Amount',@For_Date,'Imported Amount is More then Closing Amount',GETDATE(),'Employee Advance Import',@GUID)  
									SET @Log_Status=1
									RETURN -1	
								END
							
							IF ABS(@Advance_Amount) = 0
								BEGIN
									INSERT INTO dbo.T0080_Import_Log 
									VALUES (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Amount is Zero',@Alpha_Emp_Code,'0 Advance Cannot be Imported',GETDATE(),'Employee Advance Import',@GUID)  
									SET @Log_Status = 1
									RETURN -1
								END
			
							INSERT INTO T0140_ADVANCE_TRANSACTION
								(Adv_Tran_ID,emp_id,cmp_ID,For_Date,Adv_Opening,Adv_Issue,Adv_Return,Adv_Closing)
							VALUES
								(@Adv_Tran_ID,@emp_id,@cmp_ID,@for_Date,@last_closing,0,ABS(@Advance_Amount) , @last_closing + @Advance_Amount)												    		
						
							UPDATE T0140_ADVANCE_TRANSACTION 
							SET		Adv_Opening = Adv_Opening + @Advance_Amount,
									Adv_Closing = Adv_Closing + @Advance_Amount	
							WHERE	for_date > @For_Date and cmp_ID = @cmp_ID and emp_Id = @emp_Id

						END	
				END	
		END
RETURN



