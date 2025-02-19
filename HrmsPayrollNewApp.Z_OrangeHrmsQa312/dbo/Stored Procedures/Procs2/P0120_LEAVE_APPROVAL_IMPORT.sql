

CREATE PROCEDURE [dbo].[P0120_LEAVE_APPROVAL_IMPORT]
    @CMP_ID numeric(18,0)
   ,@EMP_CODE varchar(30)
   ,@Leave_Name varchar(50)    
   ,@From_Date datetime
   ,@Leave_Period numeric(18,2) 
   ,@LEave_Assign varchar(15)  
   ,@APPROVAL_COMMENTS varchar(250)
   ,@LOGIN_ID numeric(18,0)   
   ,@Is_Import int
   ,@TRAN_TYPE as varchar(1)
   ,@Row_No int = 0
   ,@Log_Status Int = 0 Output
   ,@CancelWOHO tinyint = 0
   ,@GUID Varchar(2000) = '' --Added by nilesh patel on 14062016
   
AS  

 	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF;
	
  DECLARE @LEAVE_APPLICATION_ID AS NUMERIC(18,0)
  DECLARE @LEAVE_APPROVAL_ID AS NUMERIC(18,0)
  DECLARE @S_EMP_ID NUMERIC(18,0)
  DECLARE @EMP_ID NUMERIC(18,0)
  Declare @APPROVAL_STATUS char(1)
  Declare @To_Date datetime
  Declare @Leave_ID numeric(18,0)
  Declare @Leave_negative_Allow tinyint
  Declare @Default_Short_Name as varchar(max)  -- Added by Gadriwala Muslim 15052015
  Declare @System_Date As DateTime
		Set @System_Date=GetDate()
  
   
  DECLARE @Leave_Type as VARCHAR(30)
  DECLARE @Gender as VARCHAR(10)
  
  SET @S_EMP_id =0
  SET @LEAVE_APPROVAL_ID=0  
  SET @APPROVAL_STATUS ='A'
  set @Default_Short_Name = '' -- Added by Gadriwala Muslim 15052015
  SET @LEAVE_APPLICATION_ID = NULL  
 
   
  SELECT @Leave_ID = isnull(Leave_ID,0),@Leave_negative_Allow = Leave_negative_Allow,@Default_Short_Name = ISNULL(Default_Short_Name,'')
		,@Leave_Type = Leave_Type
   from T0040_Leave_Master WITH (NOLOCK) where cmp_id = @Cmp_ID and Leave_Name = @Leave_Name
  SELECT @EMP_ID= isnull(EMP_ID,0),@S_EMP_id = Emp_Superior 
		,@Gender = Gender
  FROM t0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@EMP_CODE and cmp_id = @cmp_id
  
  --Added by Jaina 17-01-2019
  Declare @Grd_Id numeric(18,0)
  
  select @Grd_Id = Grd_ID FROM T0095_INCREMENT I WITH (NOLOCK)INNER JOIN
	( SELECT * FROM dbo.fn_getEmpIncrement(@cmp_id,@EMP_ID,GETDATE()))As GI on GI.Increment_ID = I.Increment_ID
	   
     If @Leave_Id Is Null
		Set @Leave_Id = 0
		
	IF @Emp_id is null
		Set @Emp_id = 0
	
	if @LEave_Assign = ''
		begin
			set @LEave_Assign = 'Full Day'
		end
	
	if @CancelWOHO Is NULL OR @CancelWOHO = ''
		Begin
			Set @CancelWOHO = 0
		End
	
	IF @CancelWOHO NOT IN(0,1)
		Begin
			SET @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Invalid Flag For Weekoff or Leave Cancellation',@Leave_Name,'Invalid Cancel Flag',GetDate(),'Leave Approval',@GUID)		
			return	
		END 
	
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
	
	--Added by Jaina 07-05-2020
	If EXISTS(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @EMP_ID and isnull(cutoff_date,Month_End_Date) >= @From_Date and isnull(cutoff_date,Month_End_Date) <= @From_Date)														
	BEGIN
		SET @Log_Status=1
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,' Salary Exists For This Month. '  + @Leave_Name ,@Leave_Name,'Invalid Leave',GetDate(),'Leave Approval',@GUID)		
		return	
	END
	
	--Added By Jimit 06112019
	
	If EXISTS(SELECT 1 from T0040_SETTING WITH (NOLOCK) where Cmp_ID =@CMP_ID and Group_By = 'Leave Settings' 
						and Setting_Name = 'Hide Previous Month Option in Leave Application and Approval' and Setting_Value = 2)
		BEGIN
				If EXISTS(Select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @EMP_ID and isnull(month(cutoff_date),month(Month_End_Date)) = month(@From_Date) 
														and isnull(year(cutoff_date),year(Month_End_Date)) = year(@From_Date))
					BEGIN							
							SET @Log_Status=1
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,' BackDated Leave Approval is not Allowed. '  + @Leave_Name ,@Leave_Name,'Invalid Leave',GetDate(),'Leave Approval',@GUID)		
							return	
					END
		END
	--Ended


	--Added by Jaina 16-05-2018
	--if @Leave_Type = 'Paternity Leave'
	--	BEGIN
	--		SET @Log_Status=1
	--		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@Gender + ' Employee can not Apply for '  + @Leave_Name,@Leave_Name,'Invalid Leave',GetDate(),'Leave Approval',@GUID)		
	--		return		
	--	end
	
	if @Leave_Id =0
	begin
		Set @Log_Status=1
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Doesn''t exists',@Leave_Name,'Enter proper Leave Name',GetDate(),'Leave Approval',@GUID)
		--Raiserror('Leave Doesn''t exists',16,2) -- Commented by rohit For Polycab Due to if error in 5th record from 10 record then import nine row and show 1 rows in logs. on 24-03-2014 
		return
	end
    
     if @Emp_Id =0
		begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Leave Approval',@GUID)			
			--Raiserror('Employee Doesn''t exists',16,2) -- Commented by rohit For Polycab Due to if error in 5th record from 10 record then import nine row and show 1 rows in logs. on 24-03-2014
			return
		end
		
	 if @From_Date IS NULL
		Begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'For Date Does not Exists',@EMP_CODE,'Please Enter Correct For Date',GetDate(),'Leave Approval',@GUID)			
			return
		End
	
	if @Leave_Period = 0
		Begin
			Set @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Enter Correct Leave Period',@EMP_CODE,'Enter Correct Leave Period',GetDate(),'Leave Approval',@GUID)			
			return
		End
	
	--Added by Jaina 17-01-2019	
	
	IF not exists (SELECT 1 FROM  T0050_LEAVE_DETAIL LD WITH (NOLOCK) inner join 
								  T0040_LEAVE_MASTER   L WITH (NOLOCK) ON LD.Leave_ID = L.Leave_ID 
					where L.Cmp_ID=@Cmp_Id AND Grd_ID=@Grd_Id AND L.Leave_ID=@Leave_ID)
	BEGIN
			
			SET @Log_Status=1
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave is not assigned to employee grade',@Leave_Name,'Assign Grade in Leave Detail',GetDate(),'Leave Approval',@GUID)		
			return	
	END
	
	
	--If 	upper(@Default_Short_Name) = 'COMP' -- Added by Gadriwala Muslim 15052015
	If 	(upper(@Default_Short_Name) = 'COMP' OR UPPER(@DEFAULT_SHORT_NAME) = 'COPH')
		begin		
			exec P0120_COMPOFF_APPROVAL_IMPORT @cmp_Id,@Emp_Code,@Emp_ID,@Leave_Name,@Leave_ID,@From_date,@Leave_Period,@LEave_Assign,@Approval_Comments,@LOGIN_ID,@Is_Import,@TRAN_TYPE,@Row_No,@Log_Status output,@CancelWOHO,@Leave_negative_Allow,@S_EMP_id,@DEFAULT_SHORT_NAME
			return
		end
		
	If @S_EMP_id = 0
		Set @S_EMP_id = Null		
     
	Declare @J As Varchar(10)
	Set @J= Cast(@Leave_Period As Varchar(10))

	set @To_Date = DATEADD(day, @Leave_Period-1, @From_Date)
	
	If substring(@j,CharIndex('.',@j,1)+1, 2) > 0
	Begin
		Set @To_Date = DATEADD(day, @Leave_Period, @From_Date)		--If Decimal Leave 4.5,1.5 etc
	End
	Else
	Begin
		Set @To_Date = DATEADD(day, @Leave_Period-1, @From_Date)	--If Not Decimal Leave	1,2,4,5 etc
	End
	
	-- Comment by Jaina 27-01-2017 (Direct Admin Approve the Leave,so no need to check scheme) 
	/*Added by Sumit on 17012017 for Scheme Check*/
	--if (OBJECT_ID('tempdb..#tmpScheme') IS NULL)
	--	Begin		
	
	--	declare @LeaveCheck as varchar(15)	
	--	create table #tmpScheme(scheme Varchar(128))
		
	--		insert into #tmpScheme
	--			Exec SP_Emp_Scheme_Details @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Loan_ID='Leave',@Leave_Type=@Leave_ID,@From_Date=@From_Date
				
				
	--		select @LeaveCheck=scheme from #tmpScheme	
			
	--		if (isnull(@LeaveCheck,'0') = '0')
	--					Begin
	--							--drop table #tmpScheme
	--							Set @Log_Status=1
	--							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave scheme is not assigned to employee',@EMP_CODE,'Enter proper Leave Scheme to Employee',GetDate(),'Leave Approval',@GUID)											
	--							return
	--					End
	
	--	End
	
	/*Ended by Sumit*/
	
	
	
	--- below block added by mitesh on 03/02/2012
	
	CREATE table #leave_detail(
	From_Date datetime,
	End_Date datetime,
	Period numeric(18,2),
	leave_Date nvarchar(max), 
	StrWeekoff_Date nvarchar(max), 
	StrHoliday_Date nvarchar(max)
	)
	
		

	insert into #leave_detail
	exec dbo.Calculate_Leave_End_Date @cmp_id,@emp_id,@leave_id,@from_date,@Leave_Period,'E',@CancelWOHO
	
	select @To_Date = End_Date from #leave_detail 
	
	CREATE TABLE #Emp_Leave_Clubbing
	(
		Leave_ID Numeric,
		For_Date DateTime,
		App_ID Numeric,
		Apr_ID Numeric,
		AssigAs Varchar(20)
	)

	----Advance Leave Restriction --Ankit 03092016----
	DECLARE @UpToDate	VARCHAR(100)
	DECLARE @UpTo_Days	NUMERIC
	DECLARE @UpTo_Error VARCHAR(500)
	SET @UpToDate = ''
	SET @UpTo_Days = 0
	SET @UpTo_Error = ''
	
	SELECT @UpTo_Days = setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE cmp_Id = @Cmp_ID AND Setting_Name='Add number of days to apply leave in advance'
	
	
	
	IF @UpTo_Days <> 0 AND @To_Date >= DATEADD(d,@UpTo_Days,@From_Date)
		BEGIN
	
	
			SET @UpToDate = CONVERT(VARCHAR(15),DATEADD(d,@UpTo_Days,@From_Date),103)
			SET @UpTo_Error = 'You Can Apply Leave Up To ' + @UpToDate + '(' + CAST(@UpTo_Days AS VARCHAR(5)) +') Days. '
			--RAISERROR (@UpTo_Error , 16, 2)
			
			SET @Log_Status=1
			INSERT INTO dbo.T0080_Import_Log VALUES (@Row_No,@Cmp_Id,@Emp_Code,@UpTo_Error,@EMP_CODE,@UpTo_Error,GETDATE(),'Leave Approval',@GUID)			
			RETURN;
			
		END	
	-------------------------------------
	
	DECLARE @CL_FROM_DATE DateTime
	DECLARE @CL_TO_DATE DateTime
	DECLARE @Half_Leave_Date DateTime
	
	SET @CL_FROM_DATE = DATEADD(d, -1, @From_Date)
	SET @CL_TO_DATE = DATEADD(d, 1, @To_Date)
	SET @Half_Leave_Date = CASE @LEave_Assign WHEN 'First Half' THEN @From_Date WHEN 'Second Half' THEN @To_Date ELSE NULL END
	
	IF @Leave_Period % 1 > 0 AND @Half_Leave_Date IS NULL
		SET @Half_Leave_Date = @From_Date
	
	
	insert into #Emp_Leave_Clubbing
	exec Check_Leave_Clubbing @Emp_Id=@emp_id,@Cmp_Id=@Cmp_Id,@From_DateFE=@CL_FROM_DATE,@To_DateFE=@CL_TO_DATE,@From_DateLE=@CL_FROM_DATE,@To_DateLE=@CL_TO_DATE,@Tag='LP',@Leave_Id=@Leave_ID,@Leave_App_Id=0,@Leave_Period=@Leave_Period,@Leave_Day=@LEave_Assign,@Leave_Half_Date=@Half_Leave_Date
	
	IF EXISTS(select 1 from #Emp_Leave_Clubbing)
		BEGIN	
	
			
			DECLARE @ERR_DESC Varchar(100)
			SELECT	@ERR_DESC = COALESCE(@ERR_DESC + ';', '') +  ' Leave Date: ' + CAST(FOR_DATE AS VARCHAR(11)) + ', Leave Application Code: ' + CAST(App_ID As Varchar(10)) + ', Leave Approval Code: ' + CAST(App_ID As Varchar(10)) + ', Leave Name: ' + Leave_Name
			From	#Emp_Leave_Clubbing ELC INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON ELC.Leave_ID=LM.Leave_ID
			
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@ERR_DESC,@From_Date,'Can not be clubbed with Leave previously taken.',GetDate(),'Leave Approval',@GUID)
			set @Log_Status = 1					
			RETURN 
		END

   
 
		--Comment by Jaina 10-04-2017 Start					
 --  	If exists(select Emp_ID From dbo.T0130_Leave_Approval_detail LAD inner join
	--							T0120_Leave_Approval LA ON LAD.Leave_Approval_ID = LA.Leave_Approval_ID
	--								where LA.Cmp_ID = @Cmp_ID and LA.Emp_ID = @Emp_ID  and LA.Approval_Status <> 'R' and 
	--							((@From_Date >= from_date and @From_Date <= to_date) or 
	--							(@To_Date >= from_date and 	@To_Date <= to_date) or 
	--							(from_date >= @From_Date and from_date <= @To_Date) or
	--							(to_date >= @From_Date and to_date <= @To_Date)) AND @Leave_Period <> 0.5
	--		 )			
	--			BEGIN
	--				--log here	
	--				PRINT 345	
	--				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',@From_Date,'Enter proper Leave Period',GetDate(),'Leave Approval',@GUID)
	--				set @Log_Status = 1
					
	--				--Raiserror('Leave Already Assign for given Date',16,2) -- Commented by rohit For Polycab Due to if error in 5th record from 10 record then import nine row and show 1 rows in logs. on 24-03-2014
	--				RETURN 

	--			END
	--ELSE
	--			BEGIN
				
	--				If exists(select Emp_ID From dbo.T0130_Leave_Approval_detail LAD inner join
	--							T0120_Leave_Approval LA ON LAD.Leave_Approval_ID = LA.Leave_Approval_ID
	--								where LA.Cmp_ID = @Cmp_ID and LA.Emp_ID = @Emp_ID  and LA.Approval_Status <> 'R' and 
	--								LAD.From_Date >= @From_Date and LAD.To_Date <= @To_Date and
	--							((@From_Date >= from_date and @From_Date <= to_date) or 
	--							(@To_Date >= from_date and 	@To_Date <= to_date) or 
	--							(from_date >= @From_Date and from_date <= @To_Date) or
	--							(to_date >= @From_Date and to_date <= @To_Date)) AND Leave_Period = 0.5 AND Leave_Assign_As = @LEave_Assign )			
	--				BEGIN
	--					--log here			
	--						PRINT 34
	--					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Already Assign for given Date',@From_Date,'Enter proper Leave Period',GetDate(),'Leave Approval',@GUID)
	--					set @Log_Status = 1
	--					--Raiserror('Leave Already Assign for given Date',16,2) -- Commented by rohit For Polycab Due to if error in 5th record from 10 record then import nine row and show 1 rows in logs. on 24-03-2014
	--					RETURN 
	--				END
	--			END
	--Comment by Jaina 10-04-2017 End
									
   if @Leave_negative_Allow = 0 
	begin	
	
		Declare @Leave_Balance numeric(18,2)

		select @Leave_Balance = (isnull(Leave_Closing,0)) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
    										where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
    												where for_date <= @From_Date
    											and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id) 
    											and Cmp_ID = @Cmp_ID
    											and leave_id = @leave_Id and emp_Id = @emp_Id
    		
    	set @Leave_Balance = isnull(@Leave_Balance,0)- @Leave_Period  -- Added by rohit For Polycab Due to if error in 5th record from 10 record then import nine row and show 1 rows in logs. on 24-03-2014
		
		if isnull(@Leave_Balance,0) < 0
		begin
			--log here
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,'Leave Balance Negative Not Allowed',@Leave_Period,'Insufficient Balance to approve the leave',GetDate(),'Leave Approval',@GUID)
			set @Log_Status = 1
			--Raiserror('Leave Balance Negative Not Allowed',16,2) -- Commented by rohit For Polycab Due to if error in 5th record from 10 record then import nine row and show 1 rows in logs. on 24-03-2014
			Return 
		end
		
	end
	
    IF @TRAN_TYPE  = 'I'  
	BEGIN      
		begin try
		
		SELECT  @Leave_Approval_ID = ISNULL(MAX(Leave_Approval_ID),0) + 1  FROM T0120_LEAVE_APPROVAL WITH (NOLOCK)

		INSERT INTO T0120_LEAVE_APPROVAL  
              (Leave_Approval_ID, Leave_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status, Approval_Comments, Login_ID,System_Date)                
		VALUES     
	      (@Leave_Approval_ID,@Leave_Application_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@System_Date,@Approval_Status,@Approval_Comments,@Login_ID,@System_Date)
	      
		If @Leave_Period = 0.5 or @Leave_Period = 0.25 or @Leave_Period = 0.75  --Condition Added by Hardik 18/06/2013
			exec P0130_LEAVE_APPROVAL_DETAIL NULL,@Leave_Approval_ID,@CMP_ID,@Leave_Id,@From_Date,@To_Date,@Leave_Period,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@SYSTEM_DATE,@Is_Import,@TRAN_TYPE,@CancelWOHO,@Half_Leave_Date
		Else	
			BEGIN
				IF @LEave_Assign in ('First Half','Second Half')  --Added by Jaina 14-04-2017			
					set @Half_Leave_Date = DATEADD(d,convert(int,@Leave_Period),@Half_Leave_Date)
				ELSE	
					set @Half_Leave_Date = @Half_Leave_Date
				
				exec P0130_LEAVE_APPROVAL_DETAIL NULL,@Leave_Approval_ID,@CMP_ID,@Leave_Id,@From_Date,@To_Date,@Leave_Period,@LEave_Assign,@APPROVAL_COMMENTS,@LOGIN_ID,@SYSTEM_DATE,@Is_Import,@TRAN_TYPE,@CancelWOHO,@Half_Leave_Date	
			END
			
		END try
		BEGIN catch   --Added by Jaina 10-04-2017
			DELETE FROM T0130_LEAVE_APPROVAL_DETAIL where Leave_Approval_ID =@Leave_Approval_ID
			DELETE FROM T0120_LEAVE_APPROVAL where Leave_Approval_ID =@Leave_Approval_ID
			
			declare @Error_Msg varchar(max)
			set @Error_Msg =  ERROR_MESSAGE()
			
			--set @Error_Msg = replace(substring (@Error_Msg, charindex('@@', @Error_Msg), len(@Error_Msg) - charindex('@@', @Error_Msg)), '@@','')
			IF (CHARINDEX('@@',@Error_Msg) > 0)
				BEGIN
					SET @Error_Msg = SUBSTRING (@Error_Msg, charindex('@@', @Error_Msg)+2, LEN(@Error_Msg))
					SET @Error_Msg = SUBSTRING (@Error_Msg, 0, charindex('@@', @Error_Msg))
				END 
			--ltrlmsg2.Text = Replace(ex.Message.Substring(ex.Message.IndexOf("@@") + 2, (ex.Message.LastIndexOf("@@") - ex.Message.IndexOf("@@")) - 2).ToString(), "@@", "", 1)
			print @Error_Msg
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_Code,@Error_Msg,@From_Date,'Enter proper Leave',GetDate(),'Leave Approval',@GUID)
				set @Log_Status = 1
				
			RETURN 
		End catch
	   
	END
	
	
  
 RETURN  
  
  
  

