
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_LEAVE_OPENING_IMPORT]
 -- @EMP_CODE  as numeric
  @Alpha_Emp_Code as varchar(50)
 ,@CMP_ID as numeric
 ,@LEAVE_NAME as varchar(50)
 ,@LEAVE_OP_DAYS as numeric(22,5)
 ,@FOR_DATE  as datetime
 ,@Log_Status Int = 0 Output
 ,@Row_No int = 0
 ,@GUID Varchar(2000) = '' --Added by nilesh patel on 14062016
 --,@TRAN_TYPE as varchar(1) 
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
		DECLARE @Grd_Id_Old NUMERIC(18,0)
		DECLARE @LEAVE_ID NUMERIC(18,0)
		DECLARE @LEAVE_OP_ID NUMERIC(18,0)
		DECLARE @GRD_ID NUMERIC(18,0)
		DECLARE @EMP_ID NUMERIC(18,0)
		DECLARE @TRAN_TYPE Varchar(1)
		--Declare @For_Date datetime
		declare @EMP_CODE numeric
		
		
		DECLARE @Leave_Type as VARCHAR(30)
		DECLARE @Gender as VARCHAR(10)
		
		SET @LEAVE_OP_ID=0
		SET @Grd_Id_Old = 0
		SET @GRD_ID =0
		SET @EMP_ID =0
		Set @LEAVE_ID = 0
		--Set @For_Date = DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)
		
		--SELECT @EMP_ID=EMP_ID , @GRD_ID=GRD_ID FROM T0080_EMP_MASTER WHERE EMP_CODE=@EMP_CODE And cmp_Id=@Cmp_Id
		SELECT @EMP_ID=EMP_ID , @GRD_ID=GRD_ID , @EMP_CODE = Emp_code 
				,@Gender = Gender
		FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Alpha_Emp_Code And cmp_Id=@Cmp_Id
		
		SELECT @LEAVE_ID=LEAVE_ID 
				,@Leave_Type = Leave_Type
		FROM t0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_Name =@LEAVE_NAME And cmp_Id=@Cmp_Id
		
		If @Leave_Id Is Null 
			Set @Leave_Id = 0
		
		IF @Emp_id is null 
			Set @Emp_id = 0
		
		
		------Added By Jimit 05012018------
		If (@Leave_Type = 'Maternity Leave' and @Gender = 'M') or (@Leave_Type = 'Paternity Leave' and @Gender = 'F')
			BEGIN
					If @Gender = 'M'
						SET @Gender = 'Male'
					ELSE IF @Gender = 'F'
						SET @Gender = 'Female'
		
					 SET @Log_Status=1
					 Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@Gender + '  Employee can not Apply for '  + @Leave_Name ,@Leave_Name,'Invalid Leave',GetDate(),'Leave Approval',@GUID)		
					 return		
			END
	
		------ended------
		--Added by Jaina 16-05-2018
		if @Leave_Type = 'Paternity Leave'
		BEGIN
			SET @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@Gender + '  Employee can not Apply for '  + @Leave_Name,@Leave_Name,'Invalid Leave',GetDate(),'Leave Opening',@GUID)		
			return		
		end
		
		
		if @Leave_Id =0
		begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'Leave Doesn''t exists',@LEAVE_NAME,'Enter proper Leave Name',GetDate(),'Leave Opening',@GUID)
			return
		end
		
    
		if @Emp_Id =0
		begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE ,'Enter proper Employee Code',GetDate(),'Leave Opening',@GUID)			
			return
		end		
		
		if @FOR_DATE is null
			Begin
				Set @Log_Status=1
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'For Date is invalid',@EMP_CODE ,'Enter Valid For Date',GetDate(),'Leave Opening',@GUID)			
				return
			End
		
		--if @Leave_Op_Days = 0
		--	Begin
		--		Set @Log_Status=1
		--		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@EMP_CODE ,'Enter Valid Opening Days',@EMP_CODE ,'Enter Valid Opening Days',GetDate(),'Leave Opening',@GUID)			
		--		return
		--	End 
		
		If Exists(select Emp_ID From Dbo.T0095_LEAVE_OPENING  WITH (NOLOCK) Where Emp_ID= @Emp_ID and LEave_ID =@Leave_ID and For_Date = @for_Date)
		begin
			set @tran_type = 'U'
		end
		else
		begin
			set @tran_type = 'I'
		end
		
		IF @TRAN_TYPE = 'I'
			BEGIN
			IF @GRD_ID  = 0
				SET @GRD_ID = NULL
			
					SELECT @Leave_Op_ID = ISNULL(MAX(LEAVE_OP_ID),0) + 1 FROM Dbo.T0095_LEAVE_OPENING WITH (NOLOCK)
					
					INSERT INTO Dbo.T0095_LEAVE_OPENING
							   (LEAVE_OP_ID, EMP_ID, GRD_ID, CMP_ID, LEAVE_ID, FOR_DATE, Leave_Op_Days)
					VALUES     (@LEAVE_OP_ID,@Emp_Id,@Grd_ID,@Cmp_ID,@Leave_ID,@For_Date,@Leave_Op_Days)	
			END
		Else If @Tran_Type = 'U'
		begin
				Select @Grd_Id_Old =Grd_ID  From Dbo.T0095_LEAVE_OPENING WITH (NOLOCK) Where Emp_ID= @Emp_ID and LEave_ID =@Leave_ID and For_Date = @for_Date And Cmp_Id=@Cmp_Id	
					If @GRD_ID <> @Grd_Id_Old 
					Begin
						Update Dbo.T0095_LEAVE_OPENING Set Grd_ID = @GRD_ID Where Emp_Id =@Emp_Id and LEave_ID =@Leave_ID and For_Date = @for_Date And Cmp_Id=@Cmp_Id				
					End 
				--------------------
					UPDATE    Dbo.T0095_LEAVE_OPENING
					SET       Leave_Op_Days = @Leave_Op_Days
					where     CMP_Id = @CMP_Id and Grd_ID = @Grd_ID and Emp_Id = @Emp_Id and Leave_ID = @Leave_ID and For_Date = @For_Date --change by Falak on 25-Jan-2011 added for_Date condition
		end
		
		
		if Exists(Select Im_Id from T0080_Import_Log WITH (NOLOCK) where convert(varchar(50),for_date,103) = Convert(varchar(50),getdate(),103) and import_type = 'Leave Opening')
			begin 
				set @Log_Status = 1
			end
		
RETURN




