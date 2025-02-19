CREATE  PROCEDURE [dbo].[Mobile_HRMS_P_Check_Leave_Notice_Period]
	@CMP_ID NUMERIC,
	@LEAVE_ID NUMERIC,
	@APP_DATE DATETIME='',
	@LEAVE_PERIOD NUMERIC(7,2),
	@FROM_DATE DATETIME,
	@LEAVE_TYPE VARCHAR(24),
	@Emp_Id numeric(18,0)=0,  --Added by Jaina 23-05-2017
	@TO_DATE datetime = null,
	@Rais_Error bit = 0 -- added by Prakash Patel
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	IF @LEAVE_TYPE = 'Hour(s)' and @LEAVE_PERIOD % 1 = 0
		SET @LEAVE_PERIOD = @LEAVE_PERIOD * 0.125
	

	Set @APP_DATE = getdate()

	
	--select @CMP_ID as cmp_id,@LEAVE_TYPE as leave_type,@LEAVE_ID as lId,@APP_DATE as app_date,@LEAVE_PERIOD as lP,@FROM_DATE as fm,@Emp_Id as eid,@TO_DATE as td
	
	DECLARE @NOTICE_DAYS NUMERIC
	
	if exists(SELECT 1 from sys.procedures where name='P_Validate_Leave')

		AND (@FROM_DATE < convert(datetime,convert(char(10),getdate(),103),103))
			
		--return -- commented by yogesh to resolved LWP Leave Application error on 08082023
		
	IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH(NOLOCK) 
			  WHERE Leave_ID=@LEAVE_ID AND NoticePeriod_type=0)	--Normal Notice Period
		BEGIN
			
				SELECT @NOTICE_DAYS = LEAVE_NOTICE_PERIOD 
				FROM T0040_LEAVE_MASTER WITH(NOLOCK)
				WHERE LEAVE_ID = @LEAVE_ID 

				
			IF @NOTICE_DAYS = -999	--(User can apply leave for today but not for yesterday or day beofore yesterday)
				BEGIN	
			
					IF @FROM_DATE < CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103), 103)
					BEGIN
							SELECT  'This leave cannot be taken back dated.' AS NOTICE_MSG							
					END
					RETURN
				END
			ELSE IF @NOTICE_DAYS = 0
			goto A
					--RETURN
					
		END
	ELSE IF NOT EXISTS(SELECT 1 FROM T0045_LEAVE_APP_NOTICE_SLAB WITH(NOLOCK) WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID)
	
		RETURN
		
		
	--Following Condition is used to check applied leave is backdated or regular.
	--Notice period should not be checked if user applies for backdated leave.
	IF @APP_DATE > @FROM_DATE
		AND EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH(NOLOCK) WHERE @FROM_DATE BETWEEN Month_St_Date and Month_End_Date AND Emp_ID=@Emp_Id)
		BEGIN
		
			return
		END
		
	------Check Existing Leave Detail
	CREATE table #Employee_Leave
	(
		Emp_Id numeric(18,0),
		For_Date datetime,
		Leave_Id numeric(18,0),
		Leave_Period numeric(18,2),
		Leave_Type varchar(50),
		Application_Id numeric(18,0),
		Approval_Id numeric(18,0),
		Leave_Start_Time DateTime,
		Leave_End_Time DateTime
	)
		
	Declare @F_Date datetime
	Declare @T_Date datetime
	
	set @F_Date =dateadd(d,-10,@FROM_DATE)
	set @T_Date =dateadd(d,10,@FROM_DATE)
		
		--select @CMP_ID,@EMP_ID,@F_Date,@T_Date
	
	
	EXEC P_GET_LEAVE_DETAIL @CMP_ID,@EMP_ID,@F_Date,@T_Date
	
	DECLARE @TEMP_DATE DATETIME
	Declare @Cnt_Period numeric(18,2)
	DEclare @Flag Int = 0
	Declare @L_Type varchar(50)
	
	set @Cnt_Period = 0
	set @Temp_Date = dateadd(D,-1,@FROM_DATE)
	
	
	while @FROM_DATE > @Temp_Date
		BEGIN
			if exists (select 1 from #Employee_Leave  where For_Date = @Temp_Date And LEAVE_ID=@Leave_ID)
				BEGIN
					select @L_Type = Leave_Type from #Employee_Leave where For_Date = @Temp_Date And LEAVE_ID=@Leave_ID
					if @L_Type = 'First Half' or @L_Type = 'Second Half'
						set @Cnt_Period = @Cnt_Period + 0.5
					else
						set @Cnt_Period = @Cnt_Period + 1	
					set @Flag = 1
				END
			Else
				begin
					set @Flag = 0
				end
			
			if @Flag = 0
				break;
			SET @Temp_Date = DATEADD(D, -1, @Temp_Date)
		END
		
	set @Temp_Date = dateadd(D,1,@TO_DATE)
	
	
	while @FROM_DATE < @Temp_Date
		BEGIN
			if exists (select 1 from #Employee_Leave where For_Date = @Temp_Date And LEAVE_ID=@Leave_ID)
				BEGIN
					
					select @L_Type = Leave_Type from #Employee_Leave where For_Date = @Temp_Date And LEAVE_ID=@Leave_ID
					
					if @L_Type = 'First Half' or @L_Type = 'Second Half'
						set @Cnt_Period = @Cnt_Period + 0.5
					else
						set @Cnt_Period = @Cnt_Period + 1	
					set @Flag = 1
					
				END
			Else
				begin
					set @Flag = 0
				end
			
			if @Flag = 0
				break;
			SET @Temp_Date = DATEADD(D, -1, @Temp_Date)
		END
	
	SET @LEAVE_PERIOD = @LEAVE_PERIOD + @Cnt_Period
	--select @LEAVE_PERIOD,@Cnt_Period
	-------------------------------------------------------------
	
	DECLARE @Month_Start_date DATETIME
	DECLARE @Month_End_date DATETIME
	Declare @CONSTRAINT varchar(100)
	
	SET @CONSTRAINT = @Emp_Id
	
	
		
	SELECT	TOP 1 @NOTICE_DAYS=NOTICE_DAYS
	FROM	T0045_LEAVE_APP_NOTICE_SLAB SLB WITH(NOLOCK)
	WHERE	SLB.Cmp_ID=@CMP_ID AND SLB.Leave_ID=@LEAVE_ID AND SLB.Leave_Period >= @LEAVE_PERIOD AND SLB.For_Date <= @FROM_DATE
	ORDER BY SLB.For_Date DESC, SLB.Leave_Period ASC

	
	--select @NOTICE_DAY
	DECLARE @LEAVE_NAME VARCHAR(64)
	SELECT	@LEAVE_NAME = LEAVE_NAME FROM T0040_LEAVE_MASTER WITH(NOLOCK) WHERE Leave_ID=@LEAVE_ID

	
	--declare @msg varchar(max) 
	--IF @NOTICE_DAYS < 0 
	--	BEGIN
	--		IF @NOTICE_DAYS = -1
	--		BEGIN
	--			SET @msg = @LEAVE_NAME + ' for ' + CAST(@LEAVE_PERIOD AS VARCHAR(10)) + ' ' + @LEAVE_TYPE + ' can be applied only on next day of working.' 
	--			SET @msg = ''				
	--		END
	--		ELSE
	--			SET @msg = @LEAVE_NAME + ' for ' + CAST(@LEAVE_PERIOD AS VARCHAR(10)) + ' ' + @LEAVE_TYPE + ' can be applied only after ' + Cast((@NOTICE_DAYS * -1) - 1 As Varchar(16)) + ' day(s).' 
	--	END		
	--ELSE
	--Begin 
	--	set @msg = @LEAVE_NAME + ' for ' + CAST(@LEAVE_PERIOD AS VARCHAR(10)) + ' ' + @LEAVE_TYPE + ' should be inform before ' + Cast(@NOTICE_DAYS As Varchar(16)) + ' day(s).' 
	--END
	
	
	
	DECLARE @START_DATE DATETIME
	DECLARE @END_DATE DATETIME

	IF @NOTICE_DAYS < 0 AND @FROM_DATE < @APP_DATE	--For Previous Day Logic 
		BEGIN
			SET @START_DATE = @FROM_DATE
			SET @END_DATE = @APP_DATE
		END
	ELSE
		BEGIN
			SET @START_DATE = @APP_DATE
			SET @END_DATE =  @FROM_DATE
		END

	
	
	DECLARE @display_leave_period VARCHAR(64)
	set @display_leave_period = ''
	
	--select @APP_DATE,@FROM_DATE
	--select @NOTICE_DAYS,DATEDIFF(D, @APP_DATE, @FROM_DATE)
		
	CREATE TABLE #EMP_HOLIDAY
	(
		EMP_ID NUMERIC,
	    FOR_DATE DATETIME,
	    IS_CANCEL BIT, 
	    Is_Half tinyint, 
	    Is_P_Comp tinyint, 
	    H_DAY numeric(4,1)
	 );

	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

	CREATE TABLE #Emp_WeekOff
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
		
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@START_DATE, @TO_DATE=@END_DATE, @All_Weekoff = 1, @Exec_Mode=0		
		
	CREATE TABLE #DATES
	(
		FOR_DATE DATETIME
	)
	insert INTO #DATES
	select for_Date from #EMP_HOLIDAY
	
	insert INTO #DATES
	select for_date from #Emp_WeekOff
	
	
	
	Declare @hCount as numeric =0
	Declare @WorkingDays as numeric = 0
	
	
	
	select  @hCount = COUNT(distinct  FOR_DATE)  from #DATES where FOR_DATE between @START_DATE AND @END_DATE	  --Change by Jaina 27-10-2020
	
	SET @WorkingDays = DATEDIFF(D, @APP_DATE, @FROM_DATE) /*Normal Number of Days from Application Date to Leave From Date*/ --- @hCount - @Cnt_Period  ---@Cnt_Period set if only application exits and take consecutive leave deduct that day
	
	IF @APP_DATE > @FROM_DATE /*For Back Dated Leave*/
	BEGIN
		SET @WorkingDays = @WorkingDays + @hCount /*Removing Holiday/WeekOff Days & Taking only Working Days*/
		SET @WorkingDays = @WorkingDays + @Cnt_Period /*Removing Existing Leave Days*/

		
	END
	ELSE
	BEGIN
		SET @WorkingDays = @WorkingDays - @hCount /*Removing Holiday/WeekOff Days & Taking only Working Days*/
		SET @WorkingDays = @WorkingDays - @Cnt_Period /*Removing Existing Leave Days*/
	END	
	
	--while @NOTICE_DAYS > @Cnt
	--begin
	--	--select @Temp_Date,@cnt
	--	 IF exists (SELECT * FROM #DATES where FOR_DATE = @Temp_Date)
	--		 BEGIN
	--			IF @cnt > 0
	--				set @Cnt = @Cnt - 1	
	--		 END
	--	 set @Cnt = @Cnt + 1	
	--	 SET @Temp_Date = DATEADD(D, 1, @Temp_Date)
		 
	--end
	--set @Total_Cnt = @Cnt
	
	IF @NOTICE_DAYS >= @WorkingDays		-- "=" Added for 0.5 day leave take before 1 day not working so added it.
		BEGIN		
			if not exists(SELECT 1 from sys.procedures where name='P_Validate_Leave_SLS')
				BEGIN	
				
					set @display_leave_period = @LEAVE_NAME + ' for '
					if @LEAVE_PERIOD % 1 >0
						set @display_leave_period =  @display_leave_period + CAST(@LEAVE_PERIOD AS VARCHAR(10)) + ' ' + @LEAVE_TYPE
					else
						set @display_leave_period =  @display_leave_period + CAST(Cast(@LEAVE_PERIOD as int) AS VARCHAR(10)) + ' ' + @LEAVE_TYPE

					--set @display_leave_period =  @display_leave_period + ' should be inform before ' + Cast(@NOTICE_DAYS As Varchar(16)) + ' days.'
					IF @NOTICE_DAYS < 0 
						BEGIN			
						
							IF @NOTICE_DAYS = -1
							BEGIN
								SET @display_leave_period = @display_leave_period + '  can be applied only on next day of working.' 
								SET @display_leave_period = ''
							END
							ELSE
								set @display_leave_period =  @display_leave_period + ' can be applied only after ' + Cast((@NOTICE_DAYS * -1)-1 As Varchar(16)) + ' day(s).'
						END
					ELSE
					
						set @display_leave_period =  @display_leave_period + ' should be inform before ' + Cast(@NOTICE_DAYS As Varchar(16)) + ' day(s).'									
				END
			ELSE
				Begin
				
					if @LEAVE_PERIOD % 1 >0
							set @display_leave_period =   CAST(@LEAVE_PERIOD AS VARCHAR(10)) + ' ' + @LEAVE_TYPE
						else
							set @display_leave_period =   CAST(Cast(@LEAVE_PERIOD as int) AS VARCHAR(10)) + ' ' + @LEAVE_TYPE
							
					IF @NOTICE_DAYS < 0	
						BEGIN	
							IF @NOTICE_DAYS = -1	
								set @display_leave_period =  'Applying Leave for '+ @display_leave_period + ' ,You must Apply after ' + Cast((@NOTICE_DAYS * -1)-1 As Varchar(16)) + ' Working day(s)....!!'
							ELSE
								set @display_leave_period =  'Applying Leave for '+ @display_leave_period + ' ,You must Apply before ' + Cast(@NOTICE_DAYS As Varchar(16)) + ' Working day(s)....!!'
						END			
					ELSE
						set @display_leave_period =  'Applying Leave for '+ @display_leave_period + ' ,You must Apply before ' + Cast(@NOTICE_DAYS As Varchar(16)) + ' Working day(s)....!!'
				END
		END		
		A:
		
		IF Object_ID('tempdb..##NOTICE_MSG') Is Not null
				Begin
				
					Drop Table ##NOTICE_MSG
				End
			
	IF @Rais_Error = 0 --- Added by Praksh Patel
		BEGIN	
		
			SELECT @display_leave_period AS NOTICE_MSG into ##NOTICE_MSG
			
		END
	ELSE
	
		RAISERROR(@display_leave_period,16,2)
	

