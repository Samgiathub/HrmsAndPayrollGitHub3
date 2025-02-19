CREATE TABLE [dbo].[T0185_LOCKED_LATE_EARLY_ADJUST] (
    [Tran_ID]     INT            IDENTITY (1, 1) NOT NULL,
    [Lock_Id]     INT            NOT NULL,
    [Cmp_ID]      INT            NOT NULL,
    [Emp_ID]      INT            NOT NULL,
    [From_Date]   DATETIME       NOT NULL,
    [To_Date]     DATETIME       NOT NULL,
    [Sort_ID]     INT            NOT NULL,
    [Leave_ID]    INT            NOT NULL,
    [LastBalance] NUMERIC (9, 4) NOT NULL,
    [Flag]        CHAR (1)       NOT NULL,
    [AdjustDays]  NUMERIC (9, 4) NOT NULL,
    CONSTRAINT [fk_LOCKED_LATE_EARLY_ADJUST] FOREIGN KEY ([Lock_Id]) REFERENCES [dbo].[T0180_LOCKED_ATTENDANCE] ([Lock_Id])
);


GO


-- =============================================
-- Author:		<HARDIK BAROT>
-- Create date: <12/11/2019>
-- Description:	<FOR UPDATE TRANSACTION TABLE WHILE ATTENDANCE GETS LOCKED>
-- =============================================
CREATE TRIGGER [DBO].[Tri_T0185_LOCKED_LATE_EARLY_ADJUST]  
ON [dbo].[T0185_LOCKED_LATE_EARLY_ADJUST]  
FOR  INSERT,  DELETE   
AS  
BEGIN
	SET NOCOUNT ON;

	DECLARE @EMP_ID NUMERIC
	DECLARE @LEAVE_ID NUMERIC
	DECLARE @ADJUST_DAY NUMERIC(18,4)
	DECLARE @FROM_DATE DATETIME
	DECLARE @TO_DATE DATETIME
	DECLARE @CMP_ID INT

	Declare @Pre_Closing numeric(18,4)
	Declare @Leave_Tran_Id Numeric
	
	
	IF UPDATE(Lock_Id)
		BEGIN

			DECLARE curEmp CURSOR FAST_FORWARD FOR 
				SELECT I.CMP_ID, EMP_ID, I.Leave_ID, AdjustDays, From_Date, To_Date
				FROM inserted i Inner Join T0040_LEAVE_MASTER LM On I.Leave_ID = LM.Leave_Id And I.Cmp_ID = LM.Cmp_ID
			OPEN curEmp
			FETCH NEXT FROM curEmp INTO @CMP_ID, @EMP_ID, @LEAVE_ID,@ADJUST_DAY,@FROM_DATE,@TO_DATE
			WHILE @@FETCH_STATUS = 0
				BEGIN		

					--SELECT @CMP_ID= I.CMP_ID, @EMP_ID=EMP_ID, @LEAVE_ID=I.Leave_ID, @ADJUST_DAY=AdjustDays, @FROM_DATE=From_Date, @TO_DATE=To_Date
					--FROM inserted i Inner Join T0040_LEAVE_MASTER LM On I.Leave_ID = LM.Leave_Id And I.Cmp_ID = LM.Cmp_ID

					If Isnull(@EMP_ID,0) > 0
						Begin
							if Exists (Select 1 from T0140_LEAVE_TRANSACTION where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date=@TO_DATE)
								Begin
									Update T0140_LEAVE_TRANSACTION Set Leave_Adj_L_Mark =@ADJUST_DAY, Leave_Closing=Leave_Closing-@ADJUST_DAY
									Where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date=@TO_DATE
								End
							Else
								Begin
									Select @Pre_Closing = Leave_Closing 
									From T0140_LEAVE_TRANSACTION Where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date=
										(Select Max(For_Date) From T0140_LEAVE_TRANSACTION Where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date < @TO_DATE)
					
									SELECT @Leave_Tran_Id = isnull(max(Leave_Tran_ID),0) + 1 from T0140_LEAVE_TRANSACTION
 
									INSERT INTO T0140_LEAVE_TRANSACTION
										(EMP_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,leave_tran_id,Leave_Adj_L_Mark)  
									VALUES
										(@EMP_ID,@leave_id,@Cmp_ID,@TO_DATE,@Pre_Closing,0,0, @Pre_Closing - @ADJUST_DAY,@leave_tran_id,@ADJUST_DAY)  
								End

							EXEC [dbo].[Set_leave_transaction_table] @Cmp_id_set=@cmp_id ,@emp_id_Set=@EMP_ID,@leave_id_set=@leave_id,@max_Date_Set=@FROM_DATE
						End

					FETCH NEXT FROM curEmp INTO @CMP_ID, @EMP_ID, @LEAVE_ID,@ADJUST_DAY,@FROM_DATE,@TO_DATE
				END
				CLOSE curEmp
				DEALLOCATE curEmp
		END
	ELSE
		BEGIN
			DECLARE curEmp CURSOR FAST_FORWARD FOR 
				SELECT d.CMP_ID, EMP_ID, d.Leave_ID, AdjustDays, From_Date, To_Date
				FROM deleted D Inner Join T0040_LEAVE_MASTER LM On d.Leave_ID = LM.Leave_Id And d.Cmp_ID = LM.Cmp_ID
			OPEN curEmp
			FETCH NEXT FROM curEmp INTO @CMP_ID, @EMP_ID, @LEAVE_ID,@ADJUST_DAY,@FROM_DATE,@TO_DATE
			WHILE @@FETCH_STATUS = 0
				BEGIN	
					--SELECT @CMP_ID= D.CMP_ID, @EMP_ID=d.EMP_ID, @LEAVE_ID=D.Leave_ID, @ADJUST_DAY=D.AdjustDays, @FROM_DATE=D.From_Date, @TO_DATE=D.To_Date
					--FROM deleted d Inner Join T0040_LEAVE_MASTER LM On D.Leave_ID = LM.Leave_Id And D.Cmp_ID = LM.Cmp_ID
				
					If Isnull(@EMP_ID,0) > 0
						Begin
							if Exists (Select 1 from T0140_LEAVE_TRANSACTION where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date=@TO_DATE)
								Begin

									Update T0140_LEAVE_TRANSACTION Set Leave_Adj_L_Mark =Leave_Adj_L_Mark - @ADJUST_DAY, Leave_Closing=Leave_Closing + @ADJUST_DAY
									Where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date=@TO_DATE
								End
							Else
								Begin
									Select @Pre_Closing = Leave_Closing 
									From T0140_LEAVE_TRANSACTION Where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date=
										(Select Max(For_Date) From T0140_LEAVE_TRANSACTION Where Emp_Id = @EMP_ID and Leave_Id=@Leave_Id and For_Date < @TO_DATE)
					
									SELECT @Leave_Tran_Id = isnull(max(Leave_Tran_ID),0) + 1 from T0140_LEAVE_TRANSACTION
 
									INSERT INTO T0140_LEAVE_TRANSACTION
										(EMP_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing,leave_tran_id,Leave_Adj_L_Mark)  
									VALUES
										(@EMP_ID,@leave_id,@Cmp_ID,@TO_DATE,@Pre_Closing,0,0, @Pre_Closing + @ADJUST_DAY,@leave_tran_id,0)  
								End

							EXEC [dbo].[Set_leave_transaction_table] @Cmp_id_set=@cmp_id ,@emp_id_Set=@EMP_ID,@leave_id_set=@leave_id,@max_Date_Set=@FROM_DATE
						End
					FETCH NEXT FROM curEmp INTO @CMP_ID, @EMP_ID, @LEAVE_ID,@ADJUST_DAY,@FROM_DATE,@TO_DATE
				END
				CLOSE curEmp
				DEALLOCATE curEmp
		END

END

