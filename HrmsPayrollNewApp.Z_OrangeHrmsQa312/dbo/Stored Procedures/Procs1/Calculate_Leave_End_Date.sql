
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Calculate_Leave_End_Date]	
	@CMP_ID AS numeric,
	@Emp_Id AS numeric,
	@Leave_id numeric,
	@From_Date datetime,
	@Period numeric(18,2),		--Ankit 22022014
	@Type nvarchar(1) = 'E',
	@M_Cancel_weekoff_holiday tinyint = 0,
	@Leave_Assign_As Varchar(10)= 'Full Day'	--Ankit 22022014
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	/*************************************************************************
	Added by Nimesh: 16/Sep/2017
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution=1
		END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #EMP_WEEKOFF
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
			SET @Required_Execution=1
		END
	IF @Required_Execution = 1
		BEGIN
			DECLARE @CONSTRAINT VARCHAR(10)
			SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(10));
			
			DECLARE @TO_DATE_TEMP DATETIME
			SET @TO_DATE_TEMP = DATEADD(D, 9 + @PERIOD, @FROM_DATE);
			
			DECLARE @From_DATE_TEMP DATETIME
			SET @From_DATE_TEMP = DATEADD(D, -7 , @FROM_DATE);
			
			
			
			CREATE TABLE #WH_SETTINGS
			(
				CANCEL_WEEKOFF	SMALLINT,
				CANCEL_HOLIDAY	SMALLINT
			)

			TRUNCATE TABLE #WH_SETTINGS
			INSERT INTO #WH_SETTINGS VALUES(1,1);

			--EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE_TEMP, @All_Weekoff = 1, @Exec_Mode=0		
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@From_DATE_TEMP, @TO_DATE=@TO_DATE_TEMP, @All_Weekoff = 1, @Exec_Mode=0		
			
		END 
	
	
	Declare @Leave_Code varchar(150)
	SET @Leave_Code=''
	
	CREATE table #Display_Leave_Detail 
	(
		Applieddates datetime,
		leavedetails nvarchar(30)
		
	)
	
	
	SELECT * into #Weekoff from #EMP_WEEKOFF  --Added by Jaina 22-01-2019
	SELECT * into #Holiday from #EMP_HOLIDAY  --Added by Jaina 22-01-2019
	
		 
	DECLARE @To_Date datetime
	DECLARE @End_Date datetime
	DECLARE @Weekoff_as_leave tinyint
	DECLARE @Holiday_as_leave tinyint
	DECLARE @StrWeekoff_Date varchar(Max)
	--DECLARE @Weekoff_Days   Numeric(12,1)    
	--DECLARE @Cancel_Weekoff   Numeric(12,1)  
	DECLARE @leave_Date varchar(Max)
	DECLARE @StrHoliday_Date   varchar(Max) 
	--DECLARE @Holiday_days   Numeric(12,1)  
	--DECLARE @Cancel_Holiday  Numeric(12,1)  
	DECLARE @Branch_Id  Numeric
	--DECLARE @WeekOff_Holiday_dates varchar(Max)
	DECLARE @DOJ datetime
	--DECLARE @genral_Cancel_Holiday tinyint
	--DECLARE @genral_Cancel_Weekoff tinyint
	
	DECLARE @Apply_Hourly as numeric
	
	--Set @Weekoff_Days =0
	--Set @Cancel_Weekoff = 0
	--set @Weekoff_as_leave = 0
	--set @Holiday_as_leave  = 0
	set @leave_Date  = ''
	--set @StrHoliday_Date = '' 
	--set @Holiday_days   = 0
	--set @Cancel_Holiday  = 0
	--set @WeekOff_Holiday_dates = ''
	--set @genral_Cancel_Weekoff = 0
	--set @genral_Cancel_Holiday = 0
	

	select @To_Date = DATEADD(D,@Period,@From_Date) 
	select @Apply_Hourly = Apply_Hourly, 
		@Weekoff_as_leave = weekoff_as_leave, @Holiday_as_leave = Holiday_as_leave,
		@Leave_Code=isnull(Leave_Name,'')  
	from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_id
	
	--Ankit 22022014
	Declare @Leave_Period	NUMERIC(18,2)
	If @Leave_Assign_As = 'Part Day'
		begin
			Set @Leave_Period = @Period 
			--set  @Period = @Leave_Period  * 0.125
			set @Period = 1
			--select @To_Date = DATEADD(D,@Period,@From_Date) 
			--select @To_Date = @Period
			set @To_Date=dateadd(n, 1439, @From_Date)
		end
	if @Apply_Hourly = 1
	begin
		set @Period = 1
		--set @To_Date=@From_Date
		set @To_Date=dateadd(n, 1439, @From_Date)
	end	
	--Ankit 22022014

	
	IF @M_Cancel_weekoff_holiday = 1
		BEGIN
			TRUNCATE TABLE #EMP_WEEKOFF
			TRUNCATE TABLE #EMP_HOLIDAY
		END	
	IF @Weekoff_as_leave = 1
		TRUNCATE TABLE #EMP_WEEKOFF
	IF @Holiday_as_leave = 1
		TRUNCATE TABLE #EMP_HOLIDAY
	
	DECLARE @temp_to_date as datetime
	DECLARE @Count_WF as numeric
	
	set @Count_WF = 0
	set @temp_to_date = @From_Date
	
	SELECT	@DOJ = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id
	select @Branch_Id = Branch_ID from T0095_Increment EI WITH (NOLOCK) where Increment_Id in 
	(select max(Increment_Id) as Increment_Id from T0095_Increment  WITH (NOLOCK) where Increment_Effective_date <= @From_Date    --Changed by Hardik 10/09/2014 for Same Date Increment
	and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id) and Emp_ID = @Emp_Id
	
	
	DECLARE @Is_Cancel_Holiday_WO_HO_same_day As TinyInt
	SELECT	TOP 1 @Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day
	FROM	T0040_general_Setting WITH (NOLOCK)
	where	Branch_ID=@Branch_Id
	ORDER BY FOR_DATE DESC, GEN_ID DESC
	
	IF @Is_Cancel_Holiday_WO_HO_same_day = 1 
		DELETE H FROM #EMP_HOLIDAY H INNER JOIN #EMP_WEEKOFF W ON H.EMP_ID=W.EMP_ID AND H.FOR_DATE=W.FOR_DATE WHERE H.IS_CANCEL=0 AND W.IS_CANCEL=0
	ELSE
		DELETE W FROM #EMP_HOLIDAY H INNER JOIN #EMP_WEEKOFF W ON H.EMP_ID=W.EMP_ID AND H.FOR_DATE=W.FOR_DATE WHERE H.IS_CANCEL=0 AND W.IS_CANCEL=0
		
	
	
	DECLARE @HW_End_Date DateTime
	SET @HW_End_Date = DATEADD(dd,@Period-1, @From_Date)
	
	while @Count_WF < @Period
		begin			
			IF @Count_WF = 0 OR @HW_End_Date < @temp_to_date
				BEGIN
					IF @HW_End_Date < @temp_to_date
						SET @HW_End_Date = @temp_to_date
					
				END
			
			IF (EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@temp_to_date AND Is_Cancel=0) AND @Weekoff_as_leave = 1)
				OR (EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date=@temp_to_date AND Is_Cancel=0) AND @Holiday_as_leave = 1)
				BEGIN
					DELETE FROM #EMP_WEEKOFF WHERE For_Date = @temp_to_date
					DELETE FROM #EMP_HOLIDAY WHERE For_Date = @temp_to_date
					set @leave_Date = @leave_Date + ' ; ' + CONVERT(NVARCHAR(11),@temp_to_date,109)
					set @End_Date = @temp_to_date
					set @Count_WF = @Count_WF  + 1							
				END			
			ELSE IF NOT EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@temp_to_date AND Is_Cancel=0)
					AND NOT EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date=@temp_to_date AND Is_Cancel=0)			
				BEGIN 
					set @leave_Date = @leave_Date + ' ; ' + CONVERT(NVARCHAR(11),@temp_to_date,109)
					set @End_Date = @temp_to_date
					set @Count_WF = @Count_WF  + 1		
				END
			
			
			
			set @temp_to_date = DATEADD(D,1,@temp_to_date)
			
		end
		

		if @End_Date <> @End_Date
			SET @End_Date = DATEADD(D,-1,@End_Date)
		 
		 
		
		DELETE FROM #EMP_WEEKOFF WHERE For_Date NOT BETWEEN @FROM_DATE AND @End_Date
		DELETE FROM #EMP_HOLIDAY WHERE For_Date NOT BETWEEN @FROM_DATE AND @End_Date
		
		
		
		SET @StrWeekoff_Date = NULL;
		SELECT @StrWeekoff_Date = COALESCE(@StrWeekoff_Date + ';', '') + CAST(FOR_DATE AS VARCHAR(11)) FROM #EMP_WEEKOFF
		SET @StrHoliday_Date = NULL;
		SELECT @StrHoliday_Date = COALESCE(@StrHoliday_Date+ ';', '') + CAST(FOR_DATE AS VARCHAR(11)) FROM #EMP_HOLIDAY
		
		
		
		if @Type = 'E'
			begin
				select @From_Date as From_date ,@End_Date as to_date ,@Period as Period ,@leave_Date as leave_dates , @StrWeekoff_Date as weekoff_Date , @StrHoliday_Date as Holiday_date
			end
		Else if @Type = 'A'
			begin		
				
				SELECT @From_Date as From_date ,@End_Date as to_date ,@Period as Period ,@leave_Date as leave_dates , @StrWeekoff_Date as weekoff_Date , @StrHoliday_Date as Holiday_date
						
				INSERT INTO #Display_Leave_Detail (Applieddates ,leavedetails )		
				select cast(data as datetime) , 'Weekoff' from dbo.Split(@StrWeekoff_Date,';') where data <> ''
				
				INSERT INTO #Display_Leave_Detail (Applieddates ,leavedetails )		
				select cast(data as datetime), 'Holiday' from dbo.Split(@StrHoliday_Date,';') where data <> ''
				
				INSERT INTO #Display_Leave_Detail (Applieddates ,leavedetails )		
				select cast(data as datetime) , @Leave_Code from dbo.Split(@leave_Date,';') where data <> ''

				DELETE	D
				FROM	#Display_Leave_Detail D
				WHERE	Applieddates NOT BETWEEN @FROM_DATE AND @End_Date
				
				
				
				SELECT CONVERT(VARCHAR(10), Applieddates, 103) AS Applieddates, leavedetails,SUBSTRING(DATENAME(weekday, Applieddates),1,3) AS wday,
						dbo.F_GET_AMPM(Q1.In_Date) AS In_Time ,
						CASE WHEN CAST(CONVERT(VARCHAR(16),Max_In_Date,120)AS DATETIME) > CAST(CONVERT(VARCHAR(16),Out_Date,120)AS DATETIME) THEN dbo.F_GET_AMPM(Max_In_Date) ELSE dbo.F_GET_AMPM(Out_Date) END AS Out_Time 
						--cast(CONVERT(varchar(16),Q1.In_Date,120)as datetime) AS In_Time ,
						--Case when cast(CONVERT(varchar(16),Max_In_Date,120)as datetime) > cast(CONVERT(varchar(16),Out_Date,120)as datetime) Then cast(CONVERT(varchar(16),Max_In_Date,120)as datetime) Else cast(CONVERT(varchar(16),Out_Date,120)as datetime) End AS Out_Time 
				FROM #Display_Leave_Detail DL LEFT OUTER JOIN
					( SELECT Emp_Id, MIN(In_Time) In_Date,For_Date FROM dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
						WHERE Emp_ID = @Emp_ID AND For_Date BETWEEN @From_Date AND @To_Date GROUP BY Emp_Id,For_Date
					) Q1 ON Q1.Emp_Id = @Emp_ID AND DL.Applieddates = Q1.For_Date LEFT OUTER JOIN
					( SELECT Emp_Id, MAX(Out_Time) Out_Date,For_Date FROM dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
						WHERE  Emp_ID = @Emp_ID AND For_Date BETWEEN @From_Date AND @To_Date GROUP BY Emp_Id,For_Date
					) Q2 ON Q2.Emp_Id = @Emp_ID AND DL.Applieddates = Q2.For_Date LEFT OUTER JOIN
						--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
					( SELECT Emp_Id, MAX(In_Time) Max_In_Date,For_Date FROM dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
						WHERE Emp_ID = @Emp_ID AND For_Date BETWEEN @From_Date AND @To_Date GROUP BY Emp_Id,For_Date
					) Q4 ON Q4.Emp_Id = @Emp_ID AND DL.Applieddates = Q4.For_Date
				ORDER BY CAST(Applieddates AS DATETIME)
				
				
				-- Added By Ali 20122013
				select ISNULL(Can_Apply_Fraction,0) as Can_Apply_Fraction from T0040_LEAVE_MASTER WITH (NOLOCK) Where Cmp_ID = @CMP_ID And Leave_ID = @Leave_id
			end
		Else if @Type = 'O'
			begin
				if @Apply_hourly = 0
				begin	
					select cast(data as datetime) from dbo.Split(@leave_Date,';') where data <> ''
				end
				else
				begin
					select top 1 cast(data as datetime) from dbo.Split(@leave_Date,';') where data <> ''
				end
			end
	--drop table #Display_Leave_Detail	
		delete FROM #Display_Leave_Detail	
	
	
	---Added by Jaina 22-01-2019 
	--If leave taken on Monday that time check leave is taken on Saterday or not?
	IF @Type <> 'O' and @Type <> 'E'
	begin
		--IF exists(select 1  from T0040_LEAVE_MASTER where Leave_ID = @Leave_id and Cmp_ID=@Cmp_id AND (Weekoff_as_leave = 1 OR Holiday_as_leave = 1))
		IF exists(select 1  from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_id and Cmp_ID=@Cmp_id )
		BEGIN
			
			
			Declare @F_Date datetime
			Declare @T_Date datetime
			Declare @Count int = 1
			Declare @T_From_date datetime
			Declare @T_To_Date datetime
			declare @Message varchar(250) = ''
			Declare @Day varchar(100) = ''
			
			
			SELECT @WEEKOFF_AS_LEAVE = WEEKOFF_AS_LEAVE, @HOLIDAY_AS_LEAVE = HOLIDAY_AS_LEAVE  
			FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID = @LEAVE_ID AND CMP_ID=@CMP_ID

			--select @WEEKOFF_AS_LEAVE,@HOLIDAY_AS_LEAVE
			INSERT INTO #Display_Leave_Detail (Applieddates ,leavedetails )	
			SELECT for_date,'Weekoff' from #Weekoff	
						
			INSERT INTO #Display_Leave_Detail (Applieddates ,leavedetails )		
			SELECT for_date,'Holiday' from #Holiday
									
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
								
			set @F_Date =dateadd(d,-10,@FROM_DATE)
			set @T_Date =dateadd(d,10,@To_Date)

			EXEC P_GET_LEAVE_DETAIL @CMP_ID,@EMP_ID,@F_Date,@T_Date
		
			INSERT INTO #Display_Leave_Detail (Applieddates ,leavedetails )
			SELECT For_Date,'Leave' from #Employee_Leave

			--select @F_Date,@T_Date
			--select * from #Employee_Leave
			--select * from #Display_Leave_Detail order BY Applieddates asc
			--select * from #Weekoff
			
		
			set @To_Date = DATEADD(d,@Period,@from_date)
			--select @To_Date
			set @T_To_Date = @To_Date
			
			Declare @Is_HOL int
			Declare @Is_WOL int
			set @Is_HOL = 0		
			set @Is_WOL = 0
			--Loop:
			Declare @Taken_Leave_Id numeric(18,0)
			Declare @T_Weekoff_As_LEave as tinyint
			DEclare @T_Holiday_As_Leave as tinyint
			set @T_Weekoff_As_LEave = 0
			set @T_Holiday_As_Leave = 0

			WHILE @COUNT > 0
			BEGIN
						SELECT @Taken_Leave_Id = Leave_Id FROM #Employee_Leave WHERE For_Date = @T_To_Date
						
						SELECT @T_Weekoff_As_LEave = isnull(WEEKOFF_AS_LEAVE,0), @T_Holiday_As_Leave =isnull( HOLIDAY_AS_LEAVE,0)  
						FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID = @Taken_Leave_Id AND CMP_ID=@CMP_ID

					IF EXISTS (SELECT 1 FROM #DISPLAY_LEAVE_DETAIL WHERE APPLIEDDATES = @T_To_Date AND LEAVEDETAILS IN ('WEEKOFF') and @Weekoff_as_leave =1)
						BEGIN
							
							SET @COUNT = @COUNT + 1
							SET @T_To_Date = DATEADD(D,1,@T_To_Date)
							set @Is_WOL= 1			
							PRINT @T_To_Date		
							--Goto Loop;
						END
					ELSE IF EXISTS (SELECT 1 FROM #DISPLAY_LEAVE_DETAIL WHERE APPLIEDDATES = @T_To_Date AND LEAVEDETAILS IN ('Holiday') and @Holiday_as_leave = 1 )
						BEGIN
							
							SET @COUNT = @COUNT + 1
							SET @T_To_Date = DATEADD(D,1,@T_To_Date)
							set @Is_HOL = 1			
							PRINT @T_To_Date		
							--Goto Loop;
						END
					ELSE
						BEGIN								
								IF EXISTS (SELECT 1 FROM #DISPLAY_LEAVE_DETAIL WHERE APPLIEDDATES = @T_To_Date AND LEAVEDETAILS = 'LEAVE' and ((@T_Weekoff_As_LEave = 1 and @Is_WOL=1) or (@T_Holiday_As_Leave = 1 and @Is_HOL= 1)))		
									
								BEGIN		
									
									SELECT @Day = dbo.udf_DayOfWeek(@T_To_Date)
									SET @Message = 'You have taken leave on '+ @Day +' Date :'+ CONVERT(varchar(11),@T_To_Date,103) +', So your Weekoff or Holiday will be cancel. Do you want to continue ?'
									select @Message As Message
									
									Goto HW_EndCase;
								END
								set @Count = 0
								break;							
						END
			End
	
			set @T_From_date = DATEADD(d,-1,@from_date)
			set @Count = 1
			set @Is_HOL	= 0  --Added by Jaina 29-08-2020		
			set @Is_WOL = 0
			set @Taken_Leave_Id = 0
			set @T_Weekoff_As_LEave = 0
			set @T_Holiday_As_Leave = 0

			--Loop1:
			While @Count > 0
			BEGIN		
					SELECT @Taken_Leave_Id = Leave_Id FROM #Employee_Leave WHERE For_Date = @T_FROM_DATE

					SELECT @T_Weekoff_As_LEave = isnull(WEEKOFF_AS_LEAVE,0), @T_Holiday_As_Leave =isnull( HOLIDAY_AS_LEAVE,0)  
					FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID = @Taken_Leave_Id AND CMP_ID=@CMP_ID
					
				IF EXISTS (SELECT 1 FROM #DISPLAY_LEAVE_DETAIL WHERE APPLIEDDATES = @T_FROM_DATE AND LEAVEDETAILS IN ('WEEKOFF') and @WEEKOFF_AS_LEAVE = 1 )
					BEGIN								
						SET @COUNT = @COUNT + 1
						SET @T_FROM_DATE = DATEADD(D,-1,@T_FROM_DATE)	
						set @Is_WOL = 1			
						
						--Goto Loop1;
					END
				ELSE IF EXISTS (SELECT 1 FROM #DISPLAY_LEAVE_DETAIL WHERE APPLIEDDATES = @T_FROM_DATE AND LEAVEDETAILS IN ('HOLIDAY') and @Holiday_as_leave = 1 )
					BEGIN								
						SET @COUNT = @COUNT + 1
						SET @T_FROM_DATE = DATEADD(D,-1,@T_FROM_DATE)	
						set @Is_HOL = 1			
						
						--Goto Loop1;
					END
				ELSE
					BEGIN	
						--select @Temp_To_Date,@Count
						--select @T_Weekoff_As_LEave,@T_Holiday_As_Leave
						IF EXISTS (SELECT 1 FROM #DISPLAY_LEAVE_DETAIL WHERE APPLIEDDATES = @T_FROM_DATE AND LEAVEDETAILS = 'LEAVE' and ((@T_Weekoff_As_LEave = 1 and @Is_WOL=1) or(@T_Holiday_As_Leave = 1 and @Is_HOL=1))	)
							
						BEGIN				
							
							SELECT @Day = dbo.udf_DayOfWeek(@T_FROM_DATE)
							SET @Message = 'You have taken leave on '+ @Day +' Date :'+ CONVERT(varchar(11),@T_FROM_DATE,103) +', So your Weekoff or Holiday will be cancel. Do you want to continue ?'
							select @Message As Message
						
							Goto HW_EndCase;
						END
						set @Count = 0
						break;
						
					END
			End
			--print @Message		
																													   
		END
		HW_EndCase:
		
		drop table #Display_Leave_Detail	
	END	
	
	
	
RETURN




