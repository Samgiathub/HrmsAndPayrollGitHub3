CREATE PROCEDURE [dbo].[P0100_LEAVE_APPLICATION_WEBSERVICE]
    @Emp_Code				VARCHAR(30)
   ,@Leave_Name				VARCHAR(50)    
   ,@From_Date				DATETIME
   ,@Leave_Period			NUMERIC(18,2) 
   ,@Leave_Assign_As		VARCHAR(15) = 'Full Day'  
   ,@Application_Comments	VARCHAR(250) = 'WebService'
   ,@Return_Message			VARCHAR(150) output
   ,@WebService_Type		VARCHAR(15) = 'Application'
   ,@Half_Leave_Date		DATETIME = NULL
AS    
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	DECLARE @EMP_ID NUMERIC(18,0)
	DECLARE @Cmp_ID NUMERIC(18,0)
	DECLARE @Login_ID as BIT
	
	SELECT @EMP_ID= ISNULL(EMP_ID,0),@Cmp_ID = ISNULL(Cmp_ID,0) 
	FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code = @EMP_CODE
	
	SET @Login_ID = 1	-- Login_ID 1 is for ADMIN

	IF @Leave_Period % 1 <> 0.5
		SET @Half_Leave_Date = NULL;

	IF @WebService_Type NOT IN ('Application', 'Approval')
		SET @WebService_Type = 'Application';
	
IF @WebService_Type = 'Application'
	BEGIN
		DECLARE @CancelWOHO tinyint = 0
		DECLARE @Leave_Application_ID AS NUMERIC(18,0)
		DECLARE @S_EMP_ID NUMERIC(18,0)
		DECLARE @Application_Status char(1)
		DECLARE @To_Date datetime
		DECLARE @Leave_ID numeric(18,0)
		DECLARE @Leave_negative_Allow tinyint
		DECLARE @Default_Short_Name as varchar(max)  
		DECLARE @System_Date As DateTime
		
		
		SET @Application_Status ='P'
		SET @Default_Short_Name = '' 
		SET @LEAVE_APPLICATION_ID = NULL
		SET @System_Date = GETDATE()
		
	
		SELECT	@Leave_ID = isnull(Leave_ID,0),
				@Leave_negative_Allow = Leave_negative_Allow,
				@Default_Short_Name = ISNULL(Default_Short_Name,'') 
		FROM T0040_Leave_Master WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and Leave_Name = @Leave_Name
	
		If @Leave_Id Is Null
			Set @Leave_Id = 0
			
		IF @Emp_id is null
			Set @Emp_id = 0

		if @Leave_Assign_As = ''
			begin
				set @Leave_Assign_As = 'Full Day'
			end
		
		if @CancelWOHO Is NULL
			Begin
				Set @CancelWOHO = 0
			End

		if @Leave_Id =0
			BEGIN
				SET @Return_Message = 'Leave Doesn''t exists.'
				RETURN
			END

		if @Emp_Id =0
			BEGIN
				SET @Return_Message = 'Employee Doesn''t exists.'
				RETURN
			END
		
		if @From_Date IS NULL
			Begin
				Set @Return_Message = 'For Date Does not Exists.'
				RETURN
			End
	
		if @Leave_Period = 0
			Begin
				SET @Return_Message = 'Enter Correct Leave Period.'
				RETURN
			End
			
		If 	(upper(@Default_Short_Name) = 'COMP' OR UPPER(@DEFAULT_SHORT_NAME) = 'COPH')
			BEGIN
				SET @Return_Message = 'Comp-off Leave not apply through Web Service.'		
				RETURN
			END
			
		CREATE table #leave_detail
		(
			From_Date datetime,
			End_Date datetime,
			Period numeric(18,2),
			leave_Date nvarchar(max), 
			StrWeekoff_Date nvarchar(max), 
			StrHoliday_Date nvarchar(max)
		)
	
		
		insert into #leave_detail
		exec dbo.Calculate_Leave_End_Date @Cmp_ID,@EMP_ID,@Leave_ID,@From_Date,@Leave_Period,'E',@CancelWOHO

		SELECT @To_Date = End_Date FROM #leave_detail 
	
	
		--- Leave Clubbing check
		CREATE TABLE #Emp_Leave_Clubbing
		(
			Leave_ID Numeric,
			For_Date DateTime,
			App_ID Numeric,
			Apr_ID Numeric,
			AssigAs Varchar(20)
		)

		DECLARE @CL_FROM_DATE DateTime
		DECLARE @CL_TO_DATE DateTime
		--DECLARE @Half_Leave_Date DateTime

		SET @CL_FROM_DATE = DATEADD(d, -1, @From_Date)
		SET @CL_TO_DATE = DATEADD(d, 1, @To_Date)


		IF @Leave_Period % 1 = 0.5 AND @Half_Leave_Date IS NULL
			SET @Half_Leave_Date = CASE @Leave_Assign_as WHEN 'Second Half' THEN @From_Date WHEN 'First Half' THEN @To_Date ELSE NULL END
	
	
		insert into #Emp_Leave_Clubbing
		exec Check_Leave_Clubbing @Emp_Id=@emp_id,@Cmp_Id=@Cmp_Id,@From_DateFE=@CL_FROM_DATE,@To_DateFE=@CL_TO_DATE,@From_DateLE=@CL_FROM_DATE,@To_DateLE=@CL_TO_DATE,@Tag='LA',@Leave_Id=@Leave_ID,@Leave_App_Id=0,@Leave_Period=@Leave_Period,@Leave_Day=@Leave_Assign_As,@Leave_Half_Date=@Half_Leave_Date

		IF EXISTS(select 1 from #Emp_Leave_Clubbing)
			BEGIN			
				DECLARE @ERR_DESC Varchar(100)
				SELECT	@ERR_DESC = COALESCE(@ERR_DESC + '; ', '') +  'Leave Date: ' + CAST(FOR_DATE AS VARCHAR(11)) + ', Leave App Code: ' + CAST(App_ID As Varchar(10)) + ', Leave Apr Code: ' + CAST(Apr_ID As Varchar(10)) + ', Leave Name: ' + Leave_Code
				From	#Emp_Leave_Clubbing ELC INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON ELC.Leave_ID=LM.Leave_ID
				
				Set @Return_Message ='Can not be clubbed with Leave previously taken.'
				RETURN 
			END


	
			Set @Leave_Application_ID = 0

			EXEC [dbo].[P0100_LEAVE_APPLICATION] @Leave_Application_ID = @Leave_Application_ID output,@Cmp_ID = @Cmp_ID, @Emp_ID=@Emp_ID,@S_Emp_ID = 0,@Application_Date = @System_Date 
												,@Application_Code='',@Application_Status=@Application_Status,@Application_Comments =@Application_Comments,@Login_ID = @Login_ID,@System_Date=@System_Date
												,@tran_type='I',@is_backdated_application = 0,@is_Responsibility_pass = 0,@Responsible_Emp_id = 0,@M_Cancel_WO_HO = 0

			EXEC [dbo].[P0110_Leave_Application_Detail] @Leave_Application_ID=@Leave_Application_ID,@Emp_Id = @EMP_ID, @Cmp_ID = @Cmp_ID, @Leave_ID = @Leave_ID, @From_Date = @From_Date
													,@To_Date = @To_Date,@Leave_Period = @Leave_Period, @Leave_Assign_As = @Leave_Assign_As,@Leave_Reason = @Application_Comments,@Row_ID= 0
													,@Login_ID = @Login_ID,@System_Date =@System_Date,@tran_type='I',@Half_Leave_Date = @Half_Leave_Date,@Leave_App_Docs='',@User_Id = Null,@IP_Address= 'Web Service'
													,@Leave_Out_Time = NULL, @Leave_In_Time = NULL, @NightHalt=0,@strLeaveCompOff_Dates = '',@Half_Payment =0,@Warning_flag =0
												   ,@Rules_Violate = 0 
			if 	@Leave_Application_ID = 0
				begin
					SET @Return_Message = 'Unable to Apply Leave.'
				end
			else
				begin
					SET @Return_Message = 'Leave Applied Successfull'
				end
	END
ELSE IF @WebService_Type = 'Approval'
	BEGIN
		declare @Logs_Status as Tinyint
		
		EXEC [dbo].[P0120_LEAVE_APPROVAL_IMPORT] 
				@Cmp_ID = @Cmp_ID, @EMP_CODE = @EMP_CODE , @Leave_Name = @Leave_Name , @From_Date = @From_Date , 
				@Leave_Period = @Leave_Period , @LEave_Assign = @Leave_Assign_As , @APPROVAL_COMMENTS = @Application_Comments,
				@LOGIN_ID = @LOGIN_ID , @Is_Import = 1 , @TRAN_TYPE = 'I' , @Row_No = 0 , @Log_Status = @Logs_Status output , @CancelWOHO = @CancelWOHO,@GUID = ''
		
		
		
		IF 	@Logs_Status = 1
			SET @Return_Message = 'Unable to Insert Leave Approval.'
		else
			SET @Return_Message = 'Leave Approval Successfull.'
	END
	
RETURN    
