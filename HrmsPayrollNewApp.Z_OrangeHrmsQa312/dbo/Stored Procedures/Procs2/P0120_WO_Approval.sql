
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_WO_Approval] 
	@WO_Approval_Id as numeric(18,0) Output
	,@WO_Application_Id as numeric(18,0)
	,@Cmp_Id as numeric(18,0)
	,@Emp_Id as numeric(18,0)
	,@S_Emp_Id as numeric(18,0)
	,@WoDate as datetime
	,@WoDay as varchar(30)
	,@No_Of_Days as nvarchar(5)
	,@NewWoDate as datetime
	,@NewWoDay as varchar(30)	
	,@Status as varchar(1)
	,@Login_Id as numeric(18,0)
	,@Month as numeric(18,0)
	,@Year as numeric(18,0)
	,@TRAN_TYPE as VARCHAR(1)    --ADDED BY JAINA 14-09-2016
	,@System_Date as Datetime = null  --Added By Jaina 14-09-2016
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
		
		--select CONVERT(Varchar(30),WO_Date,103),* from T0120_WO_Approval where Emp_Id=@Emp_id
		--select CONVERT(Varchar(30),@WoDate,103)
		--select @WO_Approval_Id,@Emp_Id
		
		if @TRAN_TYPE = 'I'
		Begin
					select @WO_Approval_Id = ISNULL(MAX(WO_Approval_Id),0) + 1 from T0120_WO_Approval WITH (NOLOCK) 
					--where Emp_Id = @Emp_Id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year and CONVERT(Varchar(30),Approval_Date,103) = CONVERT(Varchar(30),GETDATE(),103)
				
					INSERT INTO T0120_WO_Approval (WO_Approval_Id,WO_Application_Id,Cmp_Id,Emp_Id,S_Emp_Id,WO_Date,WO_Day,No_Of_Days,New_WO_Date,New_WO_Day,Status,Login_Id,Month,Year,System_Date)
					VALUES (@WO_Approval_Id,@WO_Application_Id,@Cmp_Id,@Emp_Id,@S_Emp_Id,@WoDate,datename(dw,@WoDate),@No_Of_Days,@NewWoDate,datename(dw,@NewWoDate),@Status,@Login_Id,@Month,@Year,@System_Date)
					
					Update T0110_WO_Application Set Status = @Status, System_Date = @System_Date where WO_Application_Id = @WO_Application_Id
					
				if @Status = 'A'
				Begin
							IF EXISTS(SELECT 1 FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID 
							AND CONVERT(VARCHAR(30),FOR_DATE,103) = CONVERT(VARCHAR(30),@WODATE,103))
								BEGIN													
										UPDATE T0100_WEEKOFF_ROSTER 
										SET IS_CANCEL_WO = 1
										FROM T0100_WEEKOFF_ROSTER
										WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID 
										AND CONVERT(VARCHAR(30),FOR_DATE,103) = CONVERT(VARCHAR(30),@WODATE,103)
								END
							ELSE
								BEGIN
										DECLARE @TRANID_CAN AS NUMERIC
										SELECT @TRANID_CAN = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK)
										INSERT INTO T0100_WEEKOFF_ROSTER (TRAN_ID,CMP_ID,EMP_ID,FOR_DATE,IS_CANCEL_WO)
										VALUES (@TRANID_CAN,@CMP_ID,@EMP_ID,@WODATE,1) 
								end
				
							--Added By Jaina 20-09-2016		
							IF EXISTS(SELECT 1 FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID 
								AND CONVERT(VARCHAR(30),FOR_DATE,103) = CONVERT(VARCHAR(30),@NEWWODATE,103))
								BEGIN
										update T0100_WEEKOFF_ROSTER 
										set is_Cancel_WO = 0
										from T0100_WEEKOFF_ROSTER
										where Cmp_id = @Cmp_Id AND Emp_id = @Emp_Id 
										AND CONVERT(varchar(30),For_date,103) = CONVERT(varchar(30),@NewWoDate,103)
								END
							ELSE
								BEGIN
										Declare @TranId as numeric
										SELECT @TranId = ISNULL(MAX(Tran_Id),0) + 1 from T0100_WEEKOFF_ROSTER WITH (NOLOCK)
										INSERT INTO T0100_WEEKOFF_ROSTER (Tran_Id,Cmp_id,Emp_id,For_date)
										VALUES (@TranId,@Cmp_Id,@Emp_Id,@NewWoDate) 	
								END		
				End	
			
			
		End
		
		if @TRAN_TYPE = 'U'
		Begin
			select @WO_Approval_Id = WO_Approval_Id from T0120_WO_Approval WITH (NOLOCK) where WO_Approval_Id = @WO_Approval_Id and Cmp_Id= @Cmp_Id and Emp_Id = @Emp_Id and CONVERT(Varchar(30),WO_Date,103) = CONVERT(Varchar(30),@WoDate,103)
					PRINT @WO_Approval_Id
					
					Update T0120_WO_Approval
						Set Approval_Date = GETDATE()
						,WO_Date = @WoDate
						,WO_Day = datename(dw,@WoDate)
						,New_WO_Date = @NewWoDate
						,New_WO_Day = datename(dw,@NewWoDate)
						,Status = @Status
						,Login_Id = @Login_Id
						,Month = @Month
						,Year = @Year
						,System_Date = @System_Date  --Added By Jaina 14-09-2016
						where WO_Approval_Id = @WO_Application_Id		
						
					
		End
		
		IF @TRAN_TYPE = 'D'
		BEGIN
			select @WO_Approval_Id = WO_Approval_Id from T0120_WO_Approval WITH (NOLOCK) where WO_Application_Id = @WO_Application_Id and Cmp_Id= @Cmp_Id and Emp_Id = @Emp_Id and CONVERT(Varchar(30),WO_Date,103) = CONVERT(Varchar(30),@WoDate,103)
			--print @WoDate
			--select * from T0120_WO_Approval where WO_Application_Id = @WO_Application_Id and Cmp_Id= @Cmp_Id and Emp_Id = @Emp_Id and CONVERT(Varchar(30),WO_Date,103) = CONVERT(Varchar(30),@WoDate,103)
			DELETE FROM T0120_WO_APPROVAL WHERE WO_APPROVAL_ID = @WO_Approval_Id and Cmp_Id = @Cmp_Id
			
			Update T0110_WO_Application Set Status = 'P', System_Date = @System_Date where WO_Application_Id = @WO_Application_Id
			
			if exists(select 1 from T0100_WEEKOFF_ROSTER WITH (NOLOCK) where Cmp_id = @Cmp_Id AND Emp_id = @Emp_Id 
					AND CONVERT(varchar(30),For_date,103) = CONVERT(varchar(30),@WoDate,103))
			begin
					--SELECT * from T0100_WEEKOFF_ROSTER where Emp_id = @emp_id and Cmp_id = 149
				
					update T0100_WEEKOFF_ROSTER 
					set is_Cancel_WO = 0
					from T0100_WEEKOFF_ROSTER
					where Cmp_id = @Cmp_Id AND Emp_id = @Emp_Id 
					AND CONVERT(varchar(30),For_date,103) = CONVERT(varchar(30),@WoDate,103)
			
					update T0100_WEEKOFF_ROSTER 
					set is_Cancel_WO = 1
					from T0100_WEEKOFF_ROSTER
					where Cmp_id = @Cmp_Id AND Emp_id = @Emp_Id 
					AND CONVERT(varchar(30),For_date,103) = CONVERT(varchar(30),@NewWoDate,103)
					
					--SELECT * from T0100_WEEKOFF_ROSTER where Emp_id = @emp_id and Cmp_id = 149
				
			end
			
		END
		-- Update Application Status And Remove Weekoff date/Replace		
		--Update T0100_WO_Application_Main Set Application_Status = @Status where WO_Application_Id = @WO_Application_Id  --Comment By Jaina 14-09-2016
		
		
		--Delete from T0100_WEEKOFF_ROSTER where Cmp_id = @Cmp_Id AND Emp_id = @Emp_Id AND CONVERT(varchar(30),For_date,103) = CONVERT(varchar(30),@WoDate,103)
			

		
RETURN		
END



