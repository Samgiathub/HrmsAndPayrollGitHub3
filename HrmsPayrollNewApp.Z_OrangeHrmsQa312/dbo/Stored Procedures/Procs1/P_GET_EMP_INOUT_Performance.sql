
CREATE PROCEDURE [dbo].[P_GET_EMP_INOUT_Performance] @Cmp_ID NUMERIC(9, 0)
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@First_In_Last_OUT_Flag TINYINT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ANSI_WARNINGS OFF

	-- Deepal Comment  24062024
	--IF OBJECT_ID('tempdb..#EMP_CONS_INOUT') IS NOT NULL AND OBJECT_ID('tempdb..PresentData_INOUT') IS NOT NULL
	--BEGIN
	--	IF EXISTS (SELECT 1 FROM #EMP_CONS_INOUT EI FULL JOIN #EMP_CONS EC ON EI.EMP_ID = EC.EMP_ID WHERE EI.Emp_ID IS NULL OR EC.Emp_ID IS NULL)
	--	BEGIN
	--		TRUNCATE TABLE PresentData   
	--		INSERT INTO PresentData  	
	--		SELECT * FROM PresentData_INOUT
	--		RETURN
	--	END
	--END
	--END Deepal Comment  24062024

	DECLARE @IsNight BIT = 0
	DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT
	DECLARE @First_In_Last_Out_For_InOut_Calculation_Actual TINYINT

	SELECT @IsNight = ISNULL(SETTING_VALUE, 0) FROM T0040_SETTING WITH (NOLOCK) WHERE SETTING_NAME = 'Enable Night Shift Scenario for In Out' AND CMP_ID = @Cmp_ID

	IF @IsNight = 1
	BEGIN
		SELECT TOP 1 @First_In_Last_Out_For_InOut_Calculation = First_In_Last_Out_For_InOut_Calculation
		FROM #EMP_CONS EC
		INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON EC.BRANCH_ID = GS.BRANCH_ID
		INNER JOIN (
			SELECT GS1.BRANCH_ID
				,MAX(FOR_DATE) AS FOR_DATE
			FROM T0040_GENERAL_SETTING GS1 WITH (NOLOCK)
			WHERE GS1.FOR_DATE < @TO_DATE
			GROUP BY GS1.BRANCH_ID
			) GS1 ON GS.BRANCH_ID = GS1.BRANCH_ID
			AND GS.FOR_DATE = GS1.FOR_DATE

		IF @First_In_Last_Out_For_InOut_Calculation = 1  -- Deepal Has Uncomment the condition -- 22062024
		BEGIN
			EXEC [P_GET_EMP_INOUT_CACHE] @Cmp_ID = @Cmp_ID ,@From_Date = @From_Date ,@To_Date = @To_Date ,@First_In_Last_OUT_Flag = @First_In_Last_OUT_Flag
			GOTO END_OF_CALL;
		END
	END

	IF OBJECT_ID('tempdb..#TMP_EMP_0150_INOUT') IS NULL
	BEGIN
		SELECT TOP 0 * INTO #TMP_EMP_0150_INOUT FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK) WHERE 1 <> 1
		CREATE CLUSTERED INDEX IX_TMP_INOUT ON #TMP_EMP_0150_INOUT (For_Date DESC ,Emp_ID ,In_Time ,Out_Time)

		INSERT INTO #TMP_EMP_0150_INOUT
		SELECT IO_Tran_Id
			,EIR.Emp_ID
			,Cmp_ID
			,For_Date
			,CASE 
				WHEN isnull(In_Time, '') = ''
					THEN In_Date_Time
				ELSE In_Time
				END AS In_Time
			,CASE 
				WHEN Out_Time IS NULL
					THEN Out_Date_Time
				ELSE Out_Time
				END AS Out_Time
			,Duration
			,Reason
			,Ip_Address
			,In_Date_Time
			,Out_Date_Time
			,Skip_Count
			,Late_Calc_Not_App
			,Chk_By_Superior
			,Sup_Comment
			,Half_Full_day
			,Is_Cancel_Late_In
			,Is_Cancel_Early_Out
			,Is_Default_In
			,Is_Default_Out
			,Cmp_prp_in_flag
			,Cmp_prp_out_flag
			,is_Cmp_purpose
			,App_Date
			,Apr_Date
			,System_date
			,Other_Reason
			,ManualEntryFlag
			,StatusFlag
			,In_Admin_Time
			,Out_Admin_Time
		FROM dbo.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) INNER JOIN #EMP_CONS EC ON EIR.EMP_ID = EC.EMP_ID
		WHERE FOR_DATE BETWEEN (@FROM_DATE - 7) AND (@To_Date + 7)
	END

	IF OBJECT_ID('tempdb..#EMP_GEN_SETTINGS') IS NULL
	BEGIN
		CREATE TABLE #EMP_GEN_SETTINGS (
			EMP_ID NUMERIC PRIMARY KEY
			,BRANCH_ID NUMERIC
			,First_In_Last_Out_For_InOut_Calculation TINYINT
			,Chk_otLimit_before_after_Shift_time TINYINT
			)
	END
	-- Deepal commented 22062024
	--IF OBJECT_ID('tempdb..PresentData') IS NULL
	--BEGIN
	--	CREATE TABLE PresentData (
	--		Emp_Id NUMERIC
	--		,For_date DATETIME
	--		,Duration_in_sec NUMERIC
	--		,Shift_ID NUMERIC
	--		,Shift_Type NUMERIC
	--		,Emp_OT NUMERIC
	--		,Emp_OT_min_Limit NUMERIC
	--		,Emp_OT_max_Limit NUMERIC
	--		,P_days NUMERIC(12, 3) DEFAULT 0
	--		,OT_Sec NUMERIC DEFAULT 0
	--		,In_Time DATETIME
	--		,Shift_Start_Time DATETIME
	--		,OT_Start_Time NUMERIC DEFAULT 0
	--		,Shift_Change TINYINT DEFAULT 0
	--		,Flag INT DEFAULT 0
	--		,Weekoff_OT_Sec NUMERIC DEFAULT 0
	--		,Holiday_OT_Sec NUMERIC DEFAULT 0
	--		,Chk_By_Superior NUMERIC DEFAULT 0
	--		,IO_Tran_Id NUMERIC DEFAULT 0
	--		,OUT_Time DATETIME
	--		,Shift_End_Time DATETIME
	--		,OT_End_Time NUMERIC DEFAULT 0
	--		,Working_Hrs_St_Time TINYINT DEFAULT 0
	--		,Working_Hrs_End_Time TINYINT DEFAULT 0
	--		,GatePass_Deduct_Days NUMERIC(18, 2) DEFAULT 0
	--		)
	--END
	-- Deepal commented 22062024

	DECLARE @cBrh AS NUMERIC
	DECLARE @Chk_otLimit_before_after_Shift_time TINYINT
	DECLARE @curEmp_ID NUMERIC(9, 0)
	DECLARE @Is_OT NUMERIC

	IF Isnull(@IsNight, 0) = 1
	BEGIN
		DECLARE @Shift_Id_N AS NUMERIC
		DECLARE @Shift_St_Sec AS NUMERIC
		DECLARE @Shift_En_sec AS NUMERIC
		DECLARE @Shift_St_Time AS VARCHAR(10)
		DECLARE @Shift_End_Time AS VARCHAR(10)
		DECLARE @Shift_Dur_N AS VARCHAR(10)
		DECLARE @Shift_ST_DateTime AS DATETIME
		DECLARE @Temp_Date AS DATETIME
		DECLARE @Shift_End_DateTime AS DATETIME
		DECLARE @Insert_In_Date AS DATETIME
		DECLARE @Insert_Out_Date AS DATETIME
		DECLARE @Shift_St_Sec_Next_day AS NUMERIC
		DECLARE @Shift_En_sec_Next_day AS NUMERIC
		DECLARE @Shift_St_Time_Next_day AS VARCHAR(10)
		DECLARE @Shift_End_Time_Next_day AS VARCHAR(10)
		DECLARE @Shift_End_DateTime_Next_day AS DATETIME
		DECLARE @Shift_ST_DateTime_Next_day AS DATETIME
		DECLARE @Shift_Id_N_Next_day AS NUMERIC
		DECLARE @Shift_Dur_N_Next_Day AS VARCHAR(10)
		DECLARE @Add_Hrs_Shift_End_Time AS NUMERIC(18, 3)
		DECLARE @Minus_Hrs_Shift_St_Time AS NUMERIC
		DECLARE @Temp_Date_Next_Day AS DATETIME
		DECLARE @Is_Half_Day AS NUMERIC;
		DECLARE @Half_WeekDay VARCHAR(10);
		DECLARE @Half_Shift_St_Time AS DATETIME;
		DECLARE @Half_Shift_End_Time AS DATETIME;
		DECLARE @Half_Shift_Day AS BIT;
		DECLARE @Temp_End_Date AS DATETIME
		DECLARE @Temp_Month_Date AS DATETIME
		DECLARE @PREVIOUS_END_TIME DATETIME

		DECLARE curNightShift CURSOR FOR
			SELECT Emp_ID FROM #Emp_Cons
		OPEN curNightShift

		FETCH NEXT
		FROM curNightShift INTO @curEmp_ID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Temp_Month_Date = dateadd(dd, - 1, @From_Date)
			SET @Temp_End_Date = @To_Date
			SET @PREVIOUS_END_TIME = @Temp_Month_Date;

			WHILE @Temp_Month_Date <= @Temp_End_Date
			BEGIN
				SET @Shift_Id_N = 0
				SET @Half_Shift_Day = 0;
				SET @Half_Shift_St_Time = NULL;
				SET @Half_Shift_End_Time = NULL;
				SET @Half_WeekDay = NULL;
				SET @Is_Half_Day = NULL;

				EXEC SP_CURR_T0100_EMP_SHIFT_GET @curEmp_ID ,@Cmp_ID ,@Temp_Month_Date
					,@Shift_St_Time OUTPUT
					,@Shift_End_Time OUTPUT
					,@Shift_Dur_N OUTPUT
					,NULL
					,NULL
					,NULL
					,NULL
					,@Shift_Id_N OUTPUT
					,@Is_Half_Day OUTPUT
					,@Half_WeekDay OUTPUT
					,@Half_Shift_St_Time OUTPUT
					,@Half_Shift_End_Time OUTPUT

				IF DATENAME(WEEKDAY, @Temp_Month_Date) = @Half_WeekDay
					AND @Is_Half_Day = 1
					AND @Half_Shift_St_Time IS NOT NULL
				BEGIN
					SET @Shift_St_Time = dbo.F_Return_HHMM(@Half_Shift_St_Time);
					SET @Shift_End_Time = dbo.F_Return_HHMM(@Half_Shift_End_Time);
					SET @Half_Shift_Day = 1;
				END

				SET @Add_Hrs_Shift_End_Time = 7
				SET @Minus_Hrs_Shift_St_Time = 7
				SET @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)
				SET @Shift_En_Sec = dbo.F_Return_Sec(@Shift_End_Time)
				SET @Shift_St_Datetime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time AS SMALLDATETIME)
				SET @Temp_Date = dateadd(d, 1, @Temp_Month_Date)

				IF @Shift_St_Sec > @Shift_En_Sec
					SET @Shift_End_DateTime = cast(cast(@Temp_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time AS SMALLDATETIME)
				ELSE
					SET @Shift_End_DateTime = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time AS SMALLDATETIME)

				SET @Half_Shift_St_Time = NULL;
				SET @Half_WeekDay = NULL;
				SET @Is_Half_Day = NULL;
				SET @Half_Shift_End_Time = NULL;
				SET @Temp_Month_Date = dateadd(day, 1, @Temp_Month_Date)

				EXEC SP_CURR_T0100_EMP_SHIFT_GET @curEmp_ID
					,@Cmp_ID
					,@Temp_Month_Date
					,@Shift_St_Time_Next_Day OUTPUT
					,@Shift_End_Time_Next_Day OUTPUT
					,@Shift_Dur_N_Next_Day OUTPUT
					,NULL
					,NULL
					,NULL
					,NULL
					,@Shift_Id_N_Next_Day OUTPUT
					,@Is_Half_Day OUTPUT
					,@Half_WeekDay OUTPUT
					,@Half_Shift_St_Time OUTPUT
					,@Half_Shift_End_Time OUTPUT

				IF DATENAME(WEEKDAY, @Temp_Month_Date) = @Half_WeekDay
					AND @Is_Half_Day = 1
					AND @Half_Shift_St_Time IS NOT NULL
				BEGIN
					SET @Shift_St_Time_Next_day = dbo.F_Return_HHMM(@Half_Shift_St_Time);
					SET @Shift_End_Time_Next_day = dbo.F_Return_HHMM(@Half_Shift_End_Time);
				END

				SET @Shift_St_Sec_Next_day = dbo.F_Return_Sec(@Shift_St_Time_Next_day)
				SET @Shift_En_sec_Next_day = dbo.F_Return_Sec(@Shift_End_Time_Next_day)
				SET @Shift_ST_DateTime_Next_day = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time_Next_day AS SMALLDATETIME)
				SET @Temp_Date_Next_Day = dateadd(d, 1, @Temp_Month_Date)
				SET @Add_Hrs_Shift_End_Time = DATEDIFF(hh, @Shift_End_DateTime, @Shift_ST_DateTime_Next_day)

				IF @Shift_St_Sec_Next_day > @Shift_En_sec_Next_day
					SET @Shift_End_DateTime_Next_day = cast(cast(@Temp_Date_Next_Day AS VARCHAR(11)) + ' ' + @Shift_End_Time_Next_day AS SMALLDATETIME)
				ELSE
					SET @Shift_End_DateTime_Next_day = cast(cast(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time_Next_day AS SMALLDATETIME)

				SET @Temp_Month_Date = dateadd(day, - 1, @Temp_Month_Date)

				IF datediff(SECOND, @Shift_End_DateTime, @Shift_ST_DateTime_Next_day) <= 3600
					SET @Add_Hrs_Shift_End_Time = datediff(SECOND, @Shift_End_DateTime, @Shift_ST_DateTime_Next_day) / 3600

				IF @Add_Hrs_Shift_End_Time <= 0
					SET @Add_Hrs_Shift_End_Time = 1

				IF @Add_Hrs_Shift_End_Time > 10
					SET @Add_Hrs_Shift_End_Time = CASE 
							WHEN @Add_Hrs_Shift_End_Time > 16
								THEN 16
							ELSE @Add_Hrs_Shift_End_Time
							END - 5;

				--Scope Hours cannot be greater than difference of next shift start time but, there should not be continue shift.  
				IF DateDiff(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day) > 1 AND @Add_Hrs_Shift_End_Time >= DateDiff(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day)
				
				SET @Add_Hrs_Shift_End_Time = DateDiff(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day) - 1
				SET @cBrh = NULL;
				SET @First_In_Last_Out_For_InOut_Calculation = NULL;
				SET @Chk_otLimit_before_after_Shift_time = NULL;

				SELECT @cBrh = Branch_ID
				FROM T0095_Increment EI
				WHERE Increment_Effective_Date IN (
						SELECT max(Increment_effective_Date) AS Increment_effective_Date
						FROM T0095_Increment
						WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID
							AND Emp_ID = @curEmp_ID
						)
					AND Emp_ID = @curEmp_ID

				SELECT @First_In_Last_Out_For_InOut_Calculation = First_In_Last_Out_For_InOut_Calculation
					,@Chk_otLimit_before_after_Shift_time = Chk_otLimit_before_after_Shift_time
					,@Is_OT = ISNULL(Is_OT, 0)
				FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
				WHERE Branch_ID = @cBrh
					AND For_Date IN (
						SELECT MAX(For_Date) AS for_date
						FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
						WHERE For_Date <= @To_Date
							AND Cmp_ID = Cmp_ID
							AND Branch_ID = @cBrh
						)
					AND Cmp_ID = @Cmp_ID

				IF NOT EXISTS (
						SELECT 1
						FROM #EMP_GEN_SETTINGS
						WHERE EMP_ID = @curEmp_ID
						)
					INSERT INTO #EMP_GEN_SETTINGS
					VALUES (
						@curEmp_ID
						,@cBrh
						,@First_In_Last_Out_For_InOut_Calculation
						,@Chk_otLimit_before_after_Shift_time
						);

				IF Isnull(@First_In_Last_OUT_Flag, 0) = 1
					SET @First_In_Last_Out_For_InOut_Calculation = 1

				IF @First_In_Last_Out_For_InOut_Calculation = 1
				BEGIN
					INSERT INTO PresentDATA (
						Emp_ID
						,For_Date
						,Duration_In_sec
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,In_Time
						,Shift_Start_Time
						,Shift_End_Time
						,OT_Start_Time
						,Shift_Change
						,Chk_By_Superior
						,IO_Tran_Id
						,OUT_Time
						,Shift_ID
						)
					SELECT Emp_Id
						,Shift_St_Datetime
						,datediff(SECOND, min(In_Time), max(OUT_Time)) AS Duration_In_sec
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,min(Qry.In_Time) AS In_Time
						,Shift_Start_Time
						,@Shift_End_DateTime AS Shift_End_Time
						,OT_Start_Time
						,Shift_Change
						,Chk_By_Superior
						,IO_Tran_Id
						,Max(OUT_Time) AS OUT_Time
						,Shift_ID 
					FROM (
						SELECT DISTINCT EC.Emp_ID
							,Cast(@Shift_St_Datetime AS VARCHAR(11)) AS Shift_St_Datetime
							,ISNULL(DATEDIFF(s, In_Date, IsNUll(Out_Date, In_Date)), 0) AS Duration_In_sec
							,CASE 
								WHEN @Is_OT = 0
									THEN @Is_OT
								ELSE isnull(Emp_OT, 0)
								END AS Emp_OT
							,dbo.F_Return_Sec(Emp_OT_min_Limit) AS Emp_OT_min_Limit
							,dbo.F_Return_Sec(Emp_OT_max_Limit) AS Emp_OT_max_Limit
							,In_Date AS In_Time
							,@Shift_ST_DateTime AS Shift_Start_Time
							,0 AS OT_Start_Time
							,0 AS Shift_Change
							,isnull(Q3.Chk_By_Sup, 0) AS Chk_By_Superior
							,0 AS IO_Tran_Id
							,CASE 
								WHEN IsNull(IN_Date, '1900-01-01 00:00') <> IsNull(Out_Date, '1900-01-01 00:00')
									THEN Out_Date
								ELSE NULL
								END AS OUT_Time
							,@Shift_Id_N AS Shift_ID
						FROM #Emp_Cons Ec
						INNER JOIN (
							SELECT I.Increment_ID
								,I.Emp_ID
								,Emp_OT
								,isnull(Emp_OT_min_Limit, '00:00') Emp_OT_min_Limit
								,isnull(Emp_OT_max_Limit, '00:00') Emp_OT_max_Limit
							FROM dbo.T0095_Increment I WITH (NOLOCK)
							WHERE Emp_ID = @curEmp_ID
							) IQ ON EC.Emp_ID = IQ.emp_ID
							AND IQ.Increment_ID = EC.Increment_ID
						LEFT JOIN (
							SELECT Emp_Id
								,Min(In_Time) In_Date
							FROM #TMP_EMP_0150_INOUT
							WHERE In_Time >= (
									CASE 
										WHEN DATEDIFF(hh, @PREVIOUS_END_TIME, @Shift_St_Datetime) > 5
											THEN DateAdd(hh, - 5, @Shift_St_Datetime)
										ELSE @PREVIOUS_END_TIME
										END
									)
								AND In_Time <= CASE 
									WHEN @Shift_ST_DateTime_Next_day < Dateadd(hh, 20, @Shift_St_Datetime)
										THEN DateAdd(hh, - 5, @Shift_ST_DateTime_Next_day)
									ELSE Dateadd(hh, 20, @Shift_St_Datetime)
									END
								AND Emp_ID = @curEmp_ID
							GROUP BY Emp_Id
							) Q1 ON EC.Emp_Id = Q1.Emp_Id
						LEFT JOIN (
							SELECT ISNULL(T1.EMP_ID, T2.EMP_ID) AS EMP_ID
								,(
									CASE 
										WHEN (
												DATEDIFF(HH, @Shift_End_Datetime, Min_Out_Date) > @Add_Hrs_Shift_End_Time
												AND Max_Out_Date IS NOT NULL
												AND @Add_Hrs_Shift_End_Time < 2
												)
											OR Min_Out_Date IS NULL
											THEN Max_Out_Date
										ELSE Min_Out_Date
										END
									) AS OUT_DATE
							FROM (
								SELECT Emp_Id
									,(
										CASE 
											WHEN (DATEDIFF(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day) >= @Add_Hrs_Shift_End_Time)
												THEN MAX(IsNull(Out_Time, In_Time)) --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time (If you comment the ODD punch case will not work (ie. missing out punch case, last in punch should be considered as out punch)  
											ELSE Min(IsNull(Out_Time, In_Time)) --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
											END
										) Min_Out_Date
								FROM #TMP_EMP_0150_INOUT
								WHERE --Out_Time >= @Shift_End_Datetime   --Change > to >= for Continuous shift 11-7 and 7-5.  
									IsNull(Out_Time, In_Time) > @Shift_End_Datetime --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
									AND Emp_ID = @curEmp_ID
									AND (
										CASE 
											WHEN (DATEDIFF(hh, @Shift_End_Datetime, @Shift_ST_DateTime_Next_day) >= @Add_Hrs_Shift_End_Time)
												THEN DateAdd(hh, @Add_Hrs_Shift_End_Time, @Shift_End_Datetime)
											ELSE DATEADD(n, 1, IsNull(IN_TIME, Out_Time))
											END
										) > IsNull(IN_TIME, Out_Time)
									--AND OUT_TIME < DateAdd(hh,1, @Shift_ST_DateTime_Next_day) --Out Time is not considering if out punch is taken after shift start  
									AND IsNull(OUT_TIME, In_Time) < DateAdd(hh, 1, @Shift_ST_DateTime_Next_day) --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
								GROUP BY Emp_Id
								) T1
							FULL JOIN (
								SELECT Emp_Id
									,Max(IsNull(Out_Time, In_Time)) Max_Out_Date --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
								FROM #TMP_EMP_0150_INOUT
								WHERE
									IsNull(Out_Time, In_Time) <= @Shift_End_Datetime --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
									AND Emp_ID = @curEmp_ID
									AND IsNull(Out_Time, In_Time) > @PREVIOUS_END_TIME
									AND (ABS(DATEDIFF(HH, IsNull(Out_Time, In_Time), @Shift_End_Datetime)) < 20) --Commented by Hardik 30/11/2017 for RKM and AIA as In Time and Out time is showing Same time  
									--AND Out_Time >  @PREVIOUS_END_TIME AND (ABS(DATEDIFF(HH,Out_Time, @Shift_End_Datetime)) < 20)  
								GROUP BY Emp_Id
								) T2 ON T1.EMP_ID = T2.EMP_ID
							) Q2 ON EC.Emp_Id = Q2.Emp_Id
						LEFT JOIN (
							SELECT DISTINCT Emp_ID
								,Chk_By_Superior Chk_By_Sup
								,For_Date
							FROM #TMP_EMP_0150_INOUT
							WHERE Chk_By_Superior <> 0
								AND Emp_ID = @curEmp_ID
								AND For_Date BETWEEN @from_Date
									AND @To_date
							) Q3 ON EC.Emp_Id = Q3.Emp_Id
							AND CAST(CAST(@Shift_St_Datetime AS VARCHAR(11)) AS DATETIME) = Q3.For_Date
						WHERE ec.Emp_ID = @curEmp_ID
							AND (
								CASE 
									WHEN (
											CONVERT(VARCHAR(5), @Shift_St_Time, 108) > CONVERT(VARCHAR(5), @Shift_End_Time, 108)
											AND In_Date IS NULL
											AND DATEDIFF(hh, @Shift_ST_DateTime, OUT_DATE) > 20
											)
										OR (
											CONVERT(VARCHAR(5), @Shift_St_Time, 108) > CONVERT(VARCHAR(5), @Shift_End_Time, 108)
											AND OUT_DATE IS NULL
											AND DATEDIFF(hh, @Shift_ST_DateTime, In_Date) > 12
											)
										THEN 0
									ELSE 1
									END = 1
								)
						GROUP BY EC.Emp_ID
							,Emp_OT
							,Emp_OT_min_Limit
							,Emp_OT_max_Limit
							,out_Date
							,Chk_By_Sup
							,In_Date 
						) Qry
					WHERE (
							OUT_Time IS NOT NULL
							OR In_Time IS NOT NULL
							)
					GROUP BY Emp_Id
						,Shift_St_Datetime
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,Shift_Start_Time
						,OT_Start_Time
						,Shift_Change
						,Chk_By_Superior
						,IO_Tran_Id
						,Shift_ID
					ORDER BY Cast(Shift_St_Datetime AS VARCHAR(11))
				END
				ELSE
				BEGIN
					IF CONVERT(VARCHAR(5), @Shift_St_Time, 108) < CONVERT(VARCHAR(5), @Shift_End_Time, 108)
					BEGIN
						INSERT INTO PresentData (
							Emp_ID
							,For_Date
							,Duration_In_sec
							,Emp_OT
							,Emp_OT_min_Limit
							,Emp_OT_max_Limit
							,In_Time
							,Shift_Start_Time
							,OT_Start_Time
							,Shift_Change
							,Chk_By_Superior
							,IO_Tran_Id
							,OUT_Time
							,Shift_Id
							)
						SELECT EIR.Emp_ID
							,EIR.for_Date
							,SUM(ISNULL(DATEDIFF(s, in_time, out_time), 0))
							,CASE 
								WHEN @Is_OT = 0
									THEN @Is_OT
								ELSE isnull(Emp_OT, 0)
								END
							,dbo.F_Return_Sec(Emp_OT_min_Limit)
							,dbo.F_Return_Sec(Emp_OT_max_Limit)
							,In_Time
							,NULL
							,0
							,0
							,Chk_By_Superior
							,isnull(EIR.is_cmp_purpose, 0)
							,Out_Time
							,@Shift_Id_N
						FROM #TMP_EMP_0150_INOUT EIR
						INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID
						INNER JOIN (
							SELECT I.Increment_ID
								,I.Emp_ID
								,Emp_OT
								,ISNULL(Emp_OT_min_Limit, '00:00') Emp_OT_min_Limit
								,isnull(Emp_OT_max_Limit, '00:00') Emp_OT_max_Limit
							FROM dbo.T0095_Increment I WITH (NOLOCK)
							) IQ ON EIR.Emp_ID = IQ.emp_ID
							AND IQ.Increment_ID = EC.Increment_ID
						WHERE cmp_Id = @Cmp_ID
							AND EIR.for_Date = @Temp_Month_Date
							AND ec.Emp_ID = @curEmp_ID
						GROUP BY EIR.Emp_ID
							,EIR.For_Date
							,Emp_OT
							,Emp_OT_min_Limit
							,Emp_OT_max_Limit
							,In_Time
							,Chk_By_Superior
							,EIR.is_cmp_purpose
							,Out_Time
						ORDER BY EIR.For_Date
					END
					ELSE
					BEGIN
						INSERT INTO PresentData (
							Emp_ID
							,For_Date
							,Duration_In_sec
							,Emp_OT
							,Emp_OT_min_Limit
							,Emp_OT_max_Limit
							,In_Time
							,Shift_Start_Time
							,Shift_ID
							,OT_Start_Time
							,Shift_Change
							,Chk_By_Superior
							,IO_Tran_Id
							,OUT_Time
							)
						SELECT EIR.Emp_ID
							,CAST(@Shift_St_Datetime AS VARCHAR(11))
							,SUM(ISNULL(DATEDIFF(s, in_time, out_time), 0))
							,ISNULL(Emp_OT, 0)
							,dbo.F_Return_Sec(Emp_OT_min_Limit)
							,dbo.F_Return_Sec(Emp_OT_max_Limit)
							,In_Time
							,@Shift_St_Time
							,@Shift_Id_N
							,0
							,0
							,Chk_By_Superior
							,ISNULL(EIR.is_cmp_purpose, 0)
							,Out_Time
						FROM #TMP_EMP_0150_INOUT EIR
						INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID
						INNER JOIN (
							SELECT I.Increment_ID
								,I.Emp_ID
								,Emp_OT
								,ISNULL(Emp_OT_min_Limit, '00:00') Emp_OT_min_Limit
								,ISNULL(Emp_OT_max_Limit, '00:00') Emp_OT_max_Limit
							FROM T0095_Increment I WITH (NOLOCK)
							) IQ ON EIR.Emp_ID = IQ.emp_ID
							AND IQ.Increment_ID = EC.Increment_ID
						WHERE cmp_Id = @Cmp_ID
							AND EIR.In_Time >= Dateadd(hh, - 5, @Shift_St_Datetime)
							AND EIR.Out_Time <= Dateadd(hh, 5, @Shift_End_Datetime)
						GROUP BY EIR.Emp_ID
							,Emp_OT
							,Emp_OT_min_Limit
							,Emp_OT_max_Limit
							,In_Time
							,Chk_By_Superior
							,EIR.is_cmp_purpose
							,Out_Time
						ORDER BY Cast(@Shift_St_Datetime AS VARCHAR(11))
					END
				END

				SET @PREVIOUS_END_TIME = CASE 
						WHEN ISNULL(@PREVIOUS_END_TIME, '1900-01-01') > @Temp_Month_Date
							THEN @PREVIOUS_END_TIME
						ELSE @Temp_Month_Date
						END;

				SELECT @PREVIOUS_END_TIME = COALESCE(OUT_TIME, DATEADD(n, 1, In_Time), @PREVIOUS_END_TIME)
				FROM PresentData
				WHERE EMP_ID = @curEmp_ID
					AND FOR_DATE = @Temp_Month_Date

				SET @Temp_Month_Date = Dateadd(d, 1, @Temp_Month_Date)
			END

			FETCH NEXT
			FROM curNightShift
			INTO @curEmp_ID
		END

		CLOSE curNightShift
		DEALLOCATE curNightShift
		
		DELETE FROM PresentData WHERE For_Date = DateAdd(dd, - 1, @From_Date)
	END
	ELSE
	BEGIN
		 
		DECLARE curBranch CURSOR FAST_FORWARD FOR
				SELECT DISTINCT Branch_ID FROM #EMP_CONS
		OPEN curBranch
		FETCH NEXT
		FROM curBranch INTO @cBrh
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @First_In_Last_Out_For_InOut_Calculation = NULL;
			SET @Chk_otLimit_before_after_Shift_time = NULL;
			SET @Is_OT = 1;

			SELECT @First_In_Last_Out_For_InOut_Calculation = First_In_Last_Out_For_InOut_Calculation
				,@Is_OT = CASE WHEN @Is_OT = 0 THEN 0 ELSE ISNULL(Is_OT, 0) END
				,@Chk_otLimit_before_after_Shift_time = Chk_otLimit_before_after_Shift_time
			FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK)
			INNER JOIN (
						SELECT Branch_ID ,Max(For_Date) AS For_Date
						FROM dbo.T0040_GENERAL_SETTING G1 WITH (NOLOCK)
						WHERE G1.For_Date <= @To_Date
						GROUP BY Branch_ID
				) G1 ON G.Branch_ID = G1.Branch_ID AND G.For_Date = G1.For_Date
			WHERE G.Branch_ID = @cBrh
			
			SET @First_In_Last_Out_For_InOut_Calculation_Actual = @First_In_Last_Out_For_InOut_Calculation
			IF NOT EXISTS (SELECT 1 FROM #EMP_GEN_SETTINGS WHERE BRANCH_ID = @cBrh)
			BEGIN
				INSERT INTO #EMP_GEN_SETTINGS
				SELECT DISTINCT
					EMP_ID,
					@cBrh,
					isnull(@First_In_Last_Out_For_InOut_Calculation, 0),
					isnull(@Chk_otLimit_before_after_Shift_time, 0)
				FROM #EMP_CONS
				WHERE BRANCH_ID = @cBrh
			END

			IF Isnull(@First_In_Last_OUT_Flag, 0) = 1
				SET @First_In_Last_Out_For_InOut_Calculation = 1

			
			IF isnull(@First_In_Last_Out_For_InOut_Calculation, 0) = 1
			BEGIN
				INSERT INTO PresentData (
					Emp_ID
					,For_Date
					,Duration_In_sec
					,Emp_OT
					,Emp_OT_min_Limit
					,Emp_OT_max_Limit
					,In_Time
					,Shift_Start_Time
					,OT_Start_Time
					,Shift_Change
					,Chk_By_Superior
					,IO_Tran_Id
					,OUT_Time
					,Shift_ID
					)
				SELECT EMP_ID
					,For_Date
					,ISNULL(DATEDIFF(S, IN_TIME, OUT_TIME), 0) AS Duration
					,Emp_OT
					,Emp_OT_min_Limit
					,Emp_OT_max_Limit
					,In_Time
					,NULL
					,0
					,0
					,Chk_By_Sup
					,is_cmp_purpose
					,OUT_Time
					,dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, Emp_ID, For_Date) AS Shift_ID
				FROM (
					SELECT DISTINCT EIR.Emp_ID
						,EIR.for_Date
						,CASE 
							WHEN @Is_OT = 1
								THEN I.Emp_OT
							ELSE 0
							END AS Emp_OT
						,dbo.F_Return_Sec(isnull(I.Emp_OT_min_Limit, '00:00')) Emp_OT_min_Limit
						,dbo.F_Return_Sec(isnull(I.Emp_OT_max_Limit, '00:00')) Emp_OT_max_Limit
						,cast(CONVERT(VARCHAR(16), Q1.In_Date, 120) AS DATETIME) AS In_Time
						,isnull(Q3.Chk_By_Sup, 0) AS Chk_By_Sup
						,isnull(EIR.is_cmp_purpose, 0) AS is_cmp_purpose
						,CASE 
							WHEN CAST(CONVERT(VARCHAR(16), Max_In_Date, 120) AS DATETIME) > CAST(CONVERT(VARCHAR(16), Out_Date, 120) AS DATETIME)
								THEN cast(CONVERT(VARCHAR(16), Max_In_Date, 120) AS DATETIME)
							ELSE cast(CONVERT(VARCHAR(16), Out_Date, 120) AS DATETIME)
							END AS Out_Time
					FROM #TMP_EMP_0150_INOUT EIR
					INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = EC.Emp_ID
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EIR.Emp_ID = EM.Emp_ID
						AND EIR.Cmp_ID = EM.Cmp_ID
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID
					INNER JOIN (
						SELECT T.Emp_Id
							,Min(In_Time) In_Date
							,For_Date
						FROM #TMP_EMP_0150_INOUT T
						INNER JOIN #EMP_CONS EC ON T.EMP_ID = EC.EMP_ID
							AND EC.BRANCH_ID = @cBrh
						GROUP BY T.Emp_Id
							,For_Date
						) Q1 ON EIR.Emp_Id = Q1.Emp_Id
						AND EIR.For_Date = Q1.For_Date
					INNER JOIN (
						SELECT T.Emp_Id
							,Max(Out_Time) Out_Date
							,For_Date
						FROM #TMP_EMP_0150_INOUT T
						INNER JOIN #EMP_CONS EC ON T.EMP_ID = EC.EMP_ID
							AND EC.BRANCH_ID = @cBrh
						GROUP BY T.Emp_Id
							,For_Date
						) Q2 ON EIR.Emp_Id = Q2.Emp_Id
						AND EIR.For_Date = Q2.For_Date
					INNER JOIN
						--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)  
						(
						SELECT T.Emp_Id
							,Max(In_Time) Max_In_Date
							,For_Date
						FROM #TMP_EMP_0150_INOUT T
						INNER JOIN #EMP_CONS EC ON T.EMP_ID = EC.EMP_ID
							AND EC.BRANCH_ID = @cBrh
						GROUP BY T.Emp_Id
							,For_Date
						) Q4 ON EIR.Emp_Id = Q4.Emp_Id
						AND EIR.For_Date = Q4.For_Date
					LEFT JOIN (
						SELECT T.Emp_ID
							,Max(Chk_By_Superior) Chk_By_Sup
							,For_Date
						FROM #TMP_EMP_0150_INOUT T
						INNER JOIN #EMP_CONS EC ON T.EMP_ID = EC.EMP_ID
							AND EC.BRANCH_ID = @cBrh
						WHERE Chk_By_Superior = 1 --and Emp_ID = @curEmp_ID  
						GROUP BY T.Emp_ID
							,For_Date
						) Q3 ON EIR.Emp_Id = Q3.Emp_Id
						AND EIR.For_Date = Q3.For_Date
					WHERE EIR.cmp_Id = @Cmp_ID
						AND EIR.for_Date >= @From_Date
						AND EIR.For_Date <= @To_Date
						AND ec.Branch_ID = @cBrh
					GROUP BY EIR.Emp_ID
						,EIR.For_Date
						,In_Time
						,In_Date
						,out_Date
						,Chk_By_Sup
						,EIR.is_cmp_purpose
						,OUT_Time
						,Max_In_Date
						,I.Emp_OT_min_Limit
						,I.Emp_OT_max_Limit
						,I.Emp_OT
					) T
				ORDER BY T.For_Date
			END
			ELSE
			BEGIN
				INSERT INTO PresentData (
					Emp_ID
					,For_Date
					,Duration_In_sec
					,Emp_OT
					,Emp_OT_min_Limit
					,Emp_OT_max_Limit
					,In_Time
					,Shift_Start_Time
					,OT_Start_Time
					,Shift_Change
					,Chk_By_Superior
					,IO_Tran_Id
					,OUT_Time
					,Shift_ID
					)
				SELECT EIR.Emp_ID
					,EIR.for_Date
					,SUM(ISNULL(DATEDIFF(s, CAST(CONVERT(VARCHAR(16), In_Time, 120) AS DATETIME), CAST(CONVERT(VARCHAR(16), out_time, 120) AS DATETIME)), 0))
					,CASE 
						WHEN @Is_OT = 0
							THEN @Is_OT
						ELSE isnull(Emp_OT, 0)
						END
					,dbo.F_Return_Sec(Emp_OT_min_Limit)
					,dbo.F_Return_Sec(Emp_OT_max_Limit)
					,CAST(CONVERT(VARCHAR(16), isnull(In_Date_Time, In_Time), 120) AS DATETIME)
					,NULL
					,0
					,0
					,Chk_By_Superior
					,ISNULL(EIR.is_cmp_purpose, 0)
					,CAST(CONVERT(VARCHAR(16), isnull(Out_Date_Time, Out_Time), 120) AS DATETIME)
					,dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, EIR.Emp_ID, EIR.for_Date) AS Shift_ID
				FROM #TMP_EMP_0150_INOUT EIR
				INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID
				INNER JOIN (
					SELECT I.Increment_ID
						,I.Emp_ID
						,Emp_OT
						,ISNULL(Emp_OT_min_Limit, '00:00') Emp_OT_min_Limit
						,ISNULL(Emp_OT_max_Limit, '00:00') Emp_OT_max_Limit
					FROM dbo.T0095_Increment I WITH (NOLOCK)
					) IQ ON EIR.Emp_ID = IQ.emp_ID
					AND IQ.Increment_ID = EC.Increment_ID
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.EMP_ID = EM.EMP_ID
				WHERE EM.Cmp_ID = @Cmp_ID
					AND EIR.for_Date >= @From_Date
					AND EIR.For_Date <= @To_Date
					AND ec.Branch_ID = @cBrh
				GROUP BY EIR.Emp_ID
					,EIR.For_Date
					,Emp_OT
					,Emp_OT_min_Limit
					,Emp_OT_max_Limit
					,In_Time
					,Out_Time
					,Chk_By_Superior
					,EIR.is_cmp_purpose
					,In_Date_Time
					,Out_Date_Time
				ORDER BY EIR.For_Date
			END

			FETCH NEXT FROM curBranch INTO @cBrh
		END
		CLOSE curBranch
		DEALLOCATE curBranch
	END -- IF Night Condition END
	--select * from #Emp_Cons
	
	
	INSERT INTO PresentData (
		 Emp_ID
		,For_Date
		,Duration_In_sec
		,Emp_OT
		,Emp_OT_min_Limit
		,Emp_OT_max_Limit
		,In_Time
		,Shift_Start_Time
		,OT_Start_Time
		,Shift_Change
		,Chk_By_Superior
		,IO_Tran_Id
		,OUT_Time
		,Shift_Id
		)
	SELECT EIR.Emp_ID
		,EIR.FOR_DATE
		,SUM(ISNULL(DATEDIFF(s, EIR.in_time, EIR.out_time), 0))
		,0
		,dbo.F_Return_Sec(IQ.Emp_OT_min_Limit)
		,dbo.F_Return_Sec(IQ.Emp_OT_max_Limit)
		,EIR.In_Time
		,NULL
		,0
		,0
		,1
		,isnull(EIR.is_cmp_purpose, 0)
		,EIR.Out_Time
		,dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, EIR.Emp_ID, EIR.For_Date) AS Shift_ID
	FROM (
		SELECT EIR.EMP_ID
			,EIR.FOR_DATE
			,MIN(EIR.IN_TIME) AS IN_TIME
			,MAX(EIR.OUT_TIME) AS OUT_TIME
			,MAX(EIR.is_cmp_purpose) AS is_cmp_purpose
		FROM #TMP_EMP_0150_INOUT EIR
		INNER JOIN #EMP_CONS E ON EIR.EMP_ID = E.EMP_ID
		WHERE EIR.FOR_DATE BETWEEN @FROM_DATE
				AND @TO_DATE
			AND EIR.Chk_By_Superior = 1
		GROUP BY EIR.EMP_ID
			,EIR.FOR_DATE
		) EIR
	INNER JOIN #Emp_Cons Ec ON EIR.Emp_Id = ec.Emp_ID
	INNER JOIN (
		SELECT I.Increment_ID
			,I.Emp_ID
			,Emp_OT
			,ISNULL(Emp_OT_min_Limit, '00:00') Emp_OT_min_Limit
			,ISNULL(Emp_OT_max_Limit, '00:00') Emp_OT_max_Limit
		FROM dbo.T0095_Increment I WITH (NOLOCK)
		) IQ ON EIR.Emp_ID = IQ.emp_ID
		AND IQ.Increment_ID = EC.Increment_ID
	LEFT JOIN PresentData D ON EIR.EMP_ID = D.EMP_ID
		AND EIR.FOR_DATE = D.FOR_DATE
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.EMP_ID = EM.EMP_ID
	WHERE D.EMP_ID IS NULL
	GROUP BY EIR.Emp_ID
		,EIR.For_Date
		,IQ.Emp_OT
		,IQ.Emp_OT_min_Limit
		,IQ.Emp_OT_max_Limit
		,EIR.In_Time
		,EIR.is_cmp_purpose
		,EIR.Out_Time
	ORDER BY EIR.For_Date
	


	DELETE D
	FROM PresentData D
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON D.Emp_Id = E.Emp_ID
	WHERE (
			D.For_date < E.Date_Of_Join
			OR D.For_date > ISNULL(E.EMP_LEFT_DATE, @TO_DATE)
			)

	DELETE D FROM PresentData D WHERE In_Time IS NULL AND OUT_Time IS NULL

	
	UPDATE D
	SET Duration_in_sec = DateDiff(s, In_Time, Out_Time)
	FROM PresentData D

		

	IF Isnull(@IsNight, 0) = 0
	BEGIN
		SELECT @FROM_DATE = Min(For_date) ,@To_date = Max(For_date)
		FROM PresentData

		SELECT ROW_ID ,DATEADD(D, ROW_ID - 1, @FROM_DATE) AS FOR_DATE
		INTO #SHIFT_DATE
		FROM (
			SELECT ROW_NUMBER() OVER (ORDER BY OBJECT_ID) AS ROW_ID FROM sys.tables
		) t
		WHERE ROW_ID <= CAST(DATEDIFF(D, @FROM_DATE, @TO_DATE) AS BIGINT) + 1

		CREATE TABLE #EMP_SHIFT_DETAIL (
			EMP_ID NUMERIC
			,FOR_DATE DATETIME
			,SHIFT_ID NUMERIC
			,START_TIME DATETIME
			,END_TIME DATETIME
			,DURATION VARCHAR(6)
		)

		CREATE UNIQUE NONCLUSTERED INDEX IX_EMP_SHIFT_DETAIL ON #EMP_SHIFT_DETAIL (EMP_ID,FOR_DATE)

		INSERT INTO #EMP_SHIFT_DETAIL (EMP_ID,FOR_DATE)
		SELECT DISTINCT EMP_ID,FOR_DATE
		FROM #EMP_CONS,#SHIFT_DATE

		/*Default Shift*/
		UPDATE S
		SET SHIFT_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, Emp_ID, For_Date)
		FROM #EMP_SHIFT_DETAIL S

		/*Default Shift*/
		UPDATE S
		SET SHIFT_ID = SD.SHIFT_ID
		FROM #EMP_SHIFT_DETAIL S
		INNER JOIN T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) ON S.EMP_ID = SD.EMP_ID
			AND SD.FOR_DATE = S.FOR_DATE

		UPDATE S
		SET START_TIME = FOR_DATE + SM.Shift_St_Time
			,END_TIME = FOR_DATE + CASE 
				WHEN SM.Shift_St_Time > SM.Shift_End_Time
					THEN 1
				ELSE 0
				END + CASE 
				WHEN SM.Is_Half_Day = 1
					AND SM.Week_Day = DATENAME(WEEKDAY, S.FOR_DATE)
					THEN SM.Half_End_Time
				ELSE SM.Shift_End_Time
				END
			,DURATION = SM.F_Duration
		FROM #EMP_SHIFT_DETAIL S
		INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON S.SHIFT_ID = SM.Shift_ID

		UPDATE D
		SET SHIFT_ID = SD.SHIFT_ID
			,Shift_Start_Time = SD.START_TIME
			,Shift_End_Time = SD.END_TIME
		FROM PresentData D
		INNER JOIN #EMP_SHIFT_DETAIL SD WITH (NOLOCK) ON D.Emp_Id = SD.EMP_ID
			AND D.For_date = SD.FOR_DATE

		DROP TABLE #EMP_SHIFT_DETAIL
	END

	
	--Added by Jaina 16-03-2017 Start  
	DECLARE @DIFF_HOUR AS NUMERIC(18, 4)
	SET @DIFF_HOUR = 0

	SELECT @DIFF_HOUR = CAST(Setting_Value AS NUMERIC(18, 2))
	FROM T0040_SETTING WITH (NOLOCK)
	WHERE Cmp_ID = @Cmp_Id AND Setting_Name = 'Remove the Gap Between Two In-Out Punch from Working Hours' AND ISNUMERIC(Setting_Value) = 1

	IF @DIFF_HOUR > 0
	BEGIN
		DECLARE @Total_second AS NUMERIC(18)
		SET @Total_second = 0

		IF @DIFF_HOUR % 1.00 > 0
			SET @DIFF_HOUR = (@DIFF_HOUR * 100) / 60;

	--IF NOT (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = 'PresentData_EIO_Diff'))
	--BEGIN
	    CREATE TABLE #Data_EIO_Diff (
			Emp_Id NUMERIC
			,For_date DATETIME
			,Out_Time DATETIME
			,In_Time DATETIME
			,Diff_Sec NUMERIC
			)
		CREATE NONCLUSTERED INDEX ix_Data_temp1_Diff_Emp_Id_For_date ON #Data_EIO_Diff (Emp_Id,For_Date,In_Time);
	--END
				
		
		SET @Total_second = (@DIFF_HOUR * 3600)
		SELECT ROW_NUMBER() OVER (
				PARTITION BY EIO1.Emp_ID ORDER BY FOR_DATE
					,ISNULL(IN_TIME, OUT_TIME)
				) AS ROW_ID
			,EIO1.Emp_ID
			,For_Date
			,In_Time
			,Out_Time
		INTO #EIO
		FROM T0150_EMP_INOUT_RECORD EIO1 WITH (NOLOCK)
		INNER JOIN #Emp_Cons Ec ON EIO1.Emp_Id = ec.Emp_ID
		WHERE EIO1.cmp_Id = @Cmp_ID
			AND EIO1.for_Date >= @From_Date
			AND EIO1.For_Date <= @To_Date;

		WITH Q (
			ROW_ID
			,Emp_ID
			,For_Date
			,In_Time
			,Out_Time
			,LVL
			,DIFF
			,DiffSe
			)
		AS (
				SELECT ROW_ID
					,EIO1.Emp_ID
					,For_Date
					,In_Time
					,Out_Time
					,'U' AS LVL
					,CAST(NULL AS DATETIME) AS DIFF
					,CAST(0 AS INT) AS DiffSe
				FROM #EIO EIO1 WHERE ROW_ID = 1
				UNION ALL
				SELECT EIO2.ROW_ID
					,EIO2.Emp_ID
					,EIO2.For_Date
					,EIO2.In_Time
					,EIO2.Out_Time
					,'D' AS LVL
					,Q.Out_Time
					,CAST(DATEDIFF(S, Q.out_Time, EIO2.In_Time) AS INT) AS DiffSe  
				FROM #EIO EIO2
				INNER JOIN Q ON EIO2.ROW_ID = (Q.ROW_ID + 1)AND Q.Emp_ID = EIO2.Emp_ID
			)
		INSERT INTO #Data_EIO_Diff
		SELECT Q.Emp_id
			,Q.For_Date
			,Q.DIFF
			,Q.In_Time
			,Q.DiffSe
		FROM Q
		INNER JOIN (
				SELECT FOR_DATE ,EMP_ID
				FROM Q WHERE Isnull(Out_Time, '') <> ''
				GROUP BY EMP_ID ,FOR_DATE
				HAVING COUNT(1) > 1
			) Q1 ON Q.FOR_DATE = Q1.FOR_DATE AND Q.EMP_ID = Q1.EMP_ID  
		WHERE LVL = 'D' AND Q.DiffSe <= 36000 AND Q.DiffSe >= @Total_second
		OPTION (MAXRECURSION 0)

		/*Records should not be considered before shift start*/
		DELETE EIO
		FROM #Data_EIO_Diff EIO
		INNER JOIN PresentData D ON EIO.Emp_ID = D.Emp_Id AND EIO.For_date = D.For_date
		WHERE EXISTS (
				SELECT 1
				FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
				WHERE D.Shift_ID = SD.Shift_ID AND ISNULL(SD.Working_Hrs_St_Time, 0) = 1
		) AND EIO.In_Time < D.Shift_Start_Time

		/*Records should not be considered after shift end*/
		DELETE EIO
		FROM #Data_EIO_Diff EIO
		INNER JOIN PresentData D ON EIO.Emp_ID = D.Emp_Id
			AND EIO.For_date = D.For_date
		WHERE EXISTS (
				SELECT 1
				FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
				WHERE D.Shift_ID = SD.Shift_ID AND ISNULL(SD.Working_Hrs_End_Time, 0) = 1
		)AND EIO.Out_Time > D.Shift_End_Time

		/*Difference should be calculated after shift start only*/
		UPDATE EIO
		SET Out_Time = D.Shift_Start_Time
			,Diff_Sec = DateDiff(s, D.Shift_Start_Time, EIO.In_Time)
		FROM #Data_EIO_Diff EIO
		INNER JOIN PresentData D ON EIO.Emp_ID = D.Emp_Id
			AND EIO.For_date = D.For_date
		WHERE EXISTS (
				SELECT 1
				FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
				WHERE D.Shift_ID = SD.Shift_ID
					AND ISNULL(SD.Working_Hrs_St_Time, 0) = 1
				)
			AND D.Shift_Start_Time BETWEEN EIO.Out_Time
				AND EIO.IN_TIME

		IF @First_In_Last_Out_For_InOut_Calculation = 1
		BEGIN
			UPDATE D
			SET Duration_in_sec = DateDiff(s, D1.In_Time, D1.OUT_Time)
			FROM PresentData D
			INNER JOIN (
				SELECT D.Emp_ID
					,D.For_Date
					,CASE 
						WHEN From_ST_Start = 1
							AND In_Time < Shift_Start_Time
							THEN Shift_Start_Time
						ELSE D.In_Time
						END AS In_Time
					,CASE 
						WHEN To_ST_End = 1
							AND OUT_Time > Shift_End_Time
							THEN Shift_End_Time
						ELSE D.OUT_Time
						END AS Out_Time
				FROM PresentData D
				INNER JOIN (
					SELECT SD.Shift_ID
						,IsNull(Max(SD.Working_Hrs_St_Time), 0) AS From_ST_Start
						,IsNull(Max(SD.Working_Hrs_End_Time), 0) AS To_ST_End
					FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
					WHERE Cmp_ID = @Cmp_ID
					GROUP BY SD.Shift_ID
					) SD ON D.Shift_ID = SD.Shift_ID
				) D1 ON D.Emp_Id = D1.Emp_Id
				AND D.For_date = D1.For_date
			WHERE EXISTS (
					SELECT 1
					FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
					WHERE D.Shift_ID = SD.Shift_ID
						AND (
							ISNULL(SD.Working_Hrs_St_Time, 0) = 1
							OR ISNULL(SD.Working_Hrs_End_Time, 0) = 1
							)
					)
		END -- @First_In_Last_Out_For_InOut_Calculation Condition END 

		

		/*Difference should be calculated before shift end only*/
		UPDATE EIO
		SET In_Time = D.Shift_End_Time ,Diff_Sec = DateDiff(s, EIO.Out_Time, D.Shift_End_Time)
		FROM #Data_EIO_Diff EIO
		INNER JOIN PresentData D ON EIO.Emp_ID = D.Emp_Id
			AND EIO.For_date = D.For_date
		WHERE EXISTS (
				SELECT 1
				FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
				WHERE D.Shift_ID = SD.Shift_ID
					AND ISNULL(SD.Working_Hrs_End_Time, 0) = 1
				)
			AND D.Shift_End_Time BETWEEN EIO.Out_Time
				AND EIO.IN_TIME

		IF OBJECT_ID('tempdb..#Data_NOT_FILO') IS NULL
		BEGIN
			CREATE TABLE #Data_NOT_FILO (
				Emp_Id NUMERIC
				,For_date DATETIME
				,Diff_Sec NUMERIC
				)
			CREATE NONCLUSTERED INDEX ix_Data_temp1_Diff_Emp_Id_For_date ON #Data_NOT_FILO (Emp_Id ,For_Date);
		END

		INSERT INTO #Data_NOT_FILO
		SELECT DT.EMP_ID
			,DT.FOR_DATE
			,SUM(Diff_Sec) AS Diff_Sec
		FROM #Data_EIO_Diff DT
		INNER JOIN PresentData D ON D.Emp_Id = DT.Emp_Id
			AND D.For_date = DT.For_date
		WHERE (
				DT.Out_Time BETWEEN D.In_Time
					AND D.OUT_Time
				)
			AND (
				DT.In_Time BETWEEN D.In_Time
					AND D.OUT_Time
				)
		GROUP BY DT.EMP_ID
			,DT.FOR_DATE

		UPDATE PresentData
		SET Duration_in_sec = Duration_in_sec - ISNULL(DT.Diff_Sec, 0)
		FROM PresentData D
		LEFT JOIN #Data_NOT_FILO DT ON D.Emp_Id = DT.Emp_Id
			AND D.For_date = DT.For_date
		WHERE D.Duration_in_sec > 0

		DROP TABLE #EIO
	END

	UPDATE D
	SET Working_Hrs_St_Time = SD.Working_Hrs_St_Time
		,Working_Hrs_End_Time = SD.Working_Hrs_End_Time
		,OT_Start_Time = SD.OT_Start_Time
		,OT_End_Time = SD.OT_End_Time
	FROM PresentData D
	INNER JOIN (
		SELECT Shift_ID
			,Max(Working_Hrs_St_Time) AS Working_Hrs_St_Time
			,Max(Working_Hrs_End_Time) AS Working_Hrs_End_Time
			,Max(OT_Start_Time) AS OT_Start_Time
			,Max(OT_End_Time) AS OT_End_Time
		FROM T0050_SHIFT_DETAIL SD WITH (NOLOCK)
		GROUP BY Shift_ID
		) SD ON D.Shift_ID = SD.Shift_ID
	INNER JOIN #EMP_GEN_SETTINGS EGS ON D.Emp_Id = EGS.EMP_ID
	WHERE EGS.First_In_Last_Out_For_InOut_Calculation = 0

	UPDATE D
	SET Duration_In_Sec = D1.Actual_Work
	FROM PresentData D
	INNER JOIN (
		SELECT DISTINCT Emp_ID ,For_Date ,Sum(DateDiff(s, In_Time, Out_Time)) AS Actual_Work
		FROM (
			SELECT DISTINCT D1.Emp_ID
				,D1.For_Date
				,CASE 
					WHEN EIR.In_Time < D1.Shift_Start_Time
						AND D1.Working_Hrs_St_Time = 1
						THEN D1.Shift_Start_Time
					WHEN EIR.In_Time > D1.Shift_End_Time
						AND D1.Working_Hrs_End_Time = 1
						THEN D1.Shift_End_Time
					ELSE EIR.In_Time
					END AS In_Time
				,CASE 
					WHEN EIR.Out_Time > D1.Shift_End_Time
						AND D1.Working_Hrs_End_Time = 1
						THEN D1.Shift_End_Time
					WHEN EIR.Out_Time < D1.Shift_Start_Time
						AND D1.Working_Hrs_St_Time = 1
						THEN D1.Shift_Start_Time
					ELSE EIR.Out_Time
					END AS Out_Time
			FROM PresentData D1
			INNER JOIN #TMP_EMP_0150_INOUT EIR ON D1.Emp_Id = EIR.Emp_ID
				AND EIR.In_Time BETWEEN D1.In_Time
					AND ISNULL(D1.Out_Time, D1.In_Time)
			WHERE EIR.Duration <> '0'
			) T
		GROUP BY Emp_ID
			,For_Date
		) D1 ON D.Emp_Id = D1.Emp_Id
		AND D.For_date = D1.For_date
	INNER JOIN #EMP_GEN_SETTINGS EGS ON D.Emp_Id = EGS.EMP_ID
	WHERE EGS.First_In_Last_Out_For_InOut_Calculation = 0

	

	--IF (EXISTS(SELECT ISNULL(SETTING_VALUE, 0) FROM T0040_SETTING WITH (NOLOCK) WHERE SETTING_NAME = 'Personal Gate Pass Duration Minus in Working Hours' AND CMP_ID = @Cmp_ID) = 1)
	--DECLARE @GatePassPersonal NUMERIC
	--SET @GatePassPersonal = 0
	
	IF (SELECT ISNULL(SETTING_VALUE, 0) FROM T0040_SETTING WITH (NOLOCK) WHERE SETTING_NAME = 'Personal Gate Pass Duration Minus in Working Hours' AND CMP_ID = @Cmp_ID) = 1
	BEGIN
		UPDATE D
		SET Duration_In_Sec = Duration_In_Sec - dbo.F_Return_Sec(GPA.Hours)
		FROM PresentData D
		LEFT JOIN T0150_EMP_Gate_Pass_INOUT_RECORD GPA ON GPA.EMP_ID = D.EMP_ID AND GPA.FOR_DATE = D.FOR_DATE
		LEFT JOIN T0040_Reason_Master RM ON RM.Res_ID = GPA.Reason_ID
		WHERE Gate_Pass_Type = 'Personal' AND Cmp_ID = @Cmp_ID AND GPA.Is_Approved = 1 AND Exempted = 0
	END

	--------------- Add By Jignesh 03-Dec-2019(For Multi Recored )------  
	IF @First_In_Last_Out_For_InOut_Calculation_Actual = 1
		SET @First_In_Last_OUT_Flag = 1

	IF isnull(@First_In_Last_OUT_Flag, 0) = 0
	BEGIN
		IF OBJECT_ID('tempdb..#Data_IO') IS NULL
		BEGIN
			IF object_id('tempdb..#Data_IO') IS NOT NULL
			BEGIN
				DROP TABLE #Data_IO
			END
			SELECT * INTO #Data_IO FROM PresentData WHERE 1 = 2
		END

		IF object_id('tempdb..#Data_IO') IS NOT NULL
		BEGIN
			INSERT INTO #Data_IO
			SELECT DISTINCT A.Emp_Id
				,A.For_date
				,Duration_in_sec
				,A.Shift_ID
				,A.Shift_Type
				,A.Emp_OT
				,Emp_OT_min_Limit
				,A.Emp_OT_max_Limit
				,A.P_days
				,A.OT_Sec
				,B.In_Time
				,A.Shift_Start_Time
				,A.OT_Start_Time
				,A.Shift_Change
				,A.Flag
				,A.Weekoff_OT_Sec
				,A.Holiday_OT_Sec
				,A.Chk_By_Superior
				,A.IO_Tran_Id
				,B.OUT_Time
				,A.Shift_End_Time
				,A.OT_End_Time
				,A.Working_Hrs_St_Time
				,A.Working_Hrs_End_Time
				,A.GatePass_Deduct_Days
			FROM PresentData AS A
			INNER JOIN #TMP_EMP_0150_INOUT AS B ON A.emp_id = B.Emp_id
				AND (
					B.In_Time BETWEEN Isnull(A.In_Time, A.Shift_Start_Time)
						AND isnull(A.out_time, A.Shift_End_Time)
					OR B.out_Time BETWEEN Isnull(A.In_Time, A.Shift_Start_Time)
						AND isnull(A.out_time, A.Shift_End_Time)
					)
			ORDER BY B.in_time

			UPDATE D
			SET Emp_OT = CASE WHEN D.Emp_OT = 1 THEN I.Emp_OT ELSE 0 END
			,Emp_OT_Min_Limit = dbo.F_Return_Sec(I.Emp_OT_Min_Limit)
			,Emp_OT_Max_Limit = dbo.F_Return_Sec(I.Emp_OT_Max_Limit)
			FROM #Data_IO D
			INNER JOIN #EMP_CONS EC ON D.EMP_ID = EC.EMP_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.INCREMENT_ID = I.INCREMENT_ID
			WHERE I.Emp_OT_Min_Limit <> '24:00'

			UPDATE #Data_IO
			SET Duration_In_Sec = CASE WHEN A.In_Time = MaxTime THEN Duration_In_Sec ELSE 0 END
			FROM #Data_IO AS A
			LEFT JOIN (
					SELECT emp_id ,for_date,MIN(In_time) AS MinTime ,MAX(In_time) AS MaxTime FROM #Data_IO GROUP BY emp_id ,for_date
			) AS B ON A.emp_id = B.emp_id AND A.for_Date = B.for_Date
			
			
			Delete D From PresentData D inner join #Data_IO DI on d.Emp_Id = DI.Emp_Id

			INSERT INTO PresentData
			SELECT * FROM #Data_IO
	END
END

END_OF_CALL:

	-- Deepal Need to check the night Case 22062024
	IF OBJECT_ID('tempdb..#EMP_CONS_INOUT') IS NOT NULL AND OBJECT_ID('tempdb..PresentData_INOUT') IS NOT NULL
	BEGIN
		SELECT * INTO #EMP_CONS_INOUT FROM #EMP_CONS
		SELECT * INTO PresentData_INOUT FROM PresentData
	END
END