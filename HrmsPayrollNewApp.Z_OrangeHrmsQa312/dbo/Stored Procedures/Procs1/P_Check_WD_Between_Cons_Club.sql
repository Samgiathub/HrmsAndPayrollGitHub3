CREATE PROCEDURE [dbo].[P_Check_WD_Between_Cons_Club]
	@Emp_Id					numeric
   ,@Cmp_ID					numeric
   ,@Leave_ID				numeric
   ,@From_Date				datetime
   ,@To_Date				datetime
   ,@Leave_Period			numeric(18,2)
   ,@Leave_Application_ID	numeric = null
   ,@Leave_Approval_ID		numeric = null
   ,@Leave_Assign_As		varchar(50) = ''
   ,@Half_Leave_Date		datetime = null
   ,@Is_Club				numeric = 0  --Added by Jaina 05-06-2017   
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	IF @Leave_Application_ID = 0
		SET @Leave_Application_ID = null
	IF @Leave_Approval_ID = 0
		SET @Leave_Approval_ID = null
	
	DECLARE @WORK_DAYS NUMERIC(18,2)
	DECLARE @Consecutive_Leave numeric(18,2)

	if @Is_Club = 1
		Begin
		
			SELECT	@WORK_DAYS = Working_Club_Days,@CONSECUTIVE_LEAVE = Consecutive_Club_Days 
			FROM	T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID=@LEAVE_ID AND CMP_ID = @CMP_ID
			
		END
	ELSE IF @IS_CLUB = 2   ---Use For Only CL, EL Consecutive Leave BackDated Leave
		BEGIN
		
			SET @WORK_DAYS = 1
			SET @CONSECUTIVE_LEAVE = 1
			--SET @IS_CLUB = 1
		END
	ELSE
		BEGIN
			SELECT	@WORK_DAYS = WORKING_DAYS,@CONSECUTIVE_LEAVE = CONSECUTIVE_DAYS 
			FROM	T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID=@LEAVE_ID AND CMP_ID = @CMP_ID
		END
		
		--select @WORK_DAYS,@CONSECUTIVE_LEAVE
		
		if  isnull(@CONSECUTIVE_LEAVE,0) = 0 or isnull(@Work_Days,0) = 0
			return
			
		
		
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

			CREATE UNIQUE CLUSTERED INDEX IX_Employee_Leave ON #Employee_Leave (EMP_ID,FOR_DATE,LEAVE_ID,Leave_Type)
		
		
		/*STEP 1
		Getting all leave detail*/
		
		
		
		DECLARE @hwFromDate DATETIME
		DECLARE @hwToDate DATETIME
		SET @hwFromDate = DateAdd(d, -20, @From_Date)
		SET @hwToDate = DateAdd(d, 20, @To_Date)
		
		--INSERT INTO	#Employee_Leave
		EXEC P_GET_LEAVE_DETAIL @CMP_ID,@EMP_ID,@hwFromDate,@hwToDate
	
		
		
		/*STEP 2
		Inserting Current Leave Detail*/	
			
		--DELETE FROM #Employee_Leave 
		--select ISNULL(@Leave_Application_ID,-1), ISNULL(@Leave_Approval_ID,-1), *
		
		--select @Leave_Application_ID
		
		DELETE #Employee_Leave 
		WHERE (Application_Id=ISNULL(@Leave_Application_ID,-1) OR Approval_Id=ISNULL(@Leave_Approval_ID,-1))
		
		DECLARE @TMP_DATE DATETIME
		DECLARE @TMP_PERIOD NUMERIC(18,2)
		DECLARE @TMP_LEAVE_TYPE VARCHAR(32)
		
		
		SET @TMP_DATE = @From_Date
		
		--select @TMP_DATE,@TO_DATE
		WHILE @TMP_DATE <= @TO_DATE
			BEGIN
				 
				IF @TMP_DATE = @Half_Leave_Date 
					SET @TMP_LEAVE_TYPE = @Leave_Assign_As
				ELSE IF ISNULL(@Half_Leave_Date , '1900-01-01') <> '1900-01-01' 
						AND @TMP_DATE <> @Half_Leave_Date 
					SET @TMP_LEAVE_TYPE = 'Full Day'
				ELSE
					SET @TMP_LEAVE_TYPE = @Leave_Assign_As
				
				SET @TMP_PERIOD = CASE @TMP_LEAVE_TYPE WHEN 'Full Day' THEN 1 WHEN 'Part Day' THEN @Leave_Period Else 0.5 END
				IF @TMP_LEAVE_TYPE = 'Part Day' AND @TMP_PERIOD > 1
					SET @TMP_PERIOD = @TMP_PERIOD * 0.125;
									
				--set @Leave_Application_ID = 0
				--set @Leave_Approval_ID = 0
				IF NOT EXISTS(SELECT 1 FROM #Employee_Leave WHERE Emp_Id=@Emp_Id AND For_Date=@TMP_DATE AND Leave_Id=@Leave_ID AND Leave_Type=@TMP_LEAVE_TYPE)
					INSERT INTO #Employee_Leave
					VALUES(@Emp_Id,@TMP_DATE,@Leave_ID,@TMP_PERIOD,@TMP_LEAVE_TYPE,@Leave_Application_ID,@Leave_Approval_ID,NULL, NULL)
					
				SET @TMP_DATE = DATEADD(D,1,@TMP_DATE )
			END
		
		
		
		---If Leave Not Club Setting is Set
		IF @Is_Club = 0
			begin
				DELETE FROM #EMPLOYEE_LEAVE where Leave_Id <> @Leave_Id
			end
		
		/*STEP 3
		Inserting Weekoff & Holiday to get Working Days*/	
		DECLARE @CONSTRAINT VARCHAR(MAX)	
		SET @CONSTRAINT  =CAST (@Emp_Id AS varchar(10))

		DECLARE @Required_Execution BIT;
		SET @Required_Execution = 0;
		IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
			BEGIN	
				CREATE TABLE #EMP_HOLIDAY
				(
					EMP_ID NUMERIC, 
					FOR_DATE DATETIME, 
					IS_CANCEL BIT, 
					Is_Half tinyint, 
					Is_P_Comp tinyint, 
					H_DAY numeric(4,1)
				)
				CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE)
				SET @Required_Execution = 1;
			END
		
		IF OBJECT_ID('tempdb..#EMP_WEEKOFF') IS NULL
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
				SET @Required_Execution = 1;
			END
		
		IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
			BEGIN	
				CREATE table #Emp_WeekOff_Holiday
				(
					Emp_ID				NUMERIC,
					WeekOffDate			VARCHAR(Max),
					WeekOffCount		NUMERIC(3,1),
					HolidayDate			VARCHAR(Max),
					HolidayCount		NUMERIC(3,1),
					HalfHolidayDate		VARCHAR(Max),
					HalfHolidayCount	NUMERIC(3,1),
					OptHolidayDate		VARCHAR(Max),
					OptHolidayCount		NUMERIC(3,1)
				)
				CREATE UNIQUE CLUSTERED INDEX IX_Emp_WeekOff_Holiday_EMPID ON #Emp_WeekOff_Holiday(Emp_ID);
				SET @Required_Execution = 1;
			END
		
		IF @Required_Execution = 1
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT ,@CMP_ID=@Cmp_ID, @FROM_DATE=@hwFromDate, @TO_DATE=@hwToDate, @All_Weekoff = 0, @Exec_Mode=0	
		
		
		INSERT INTO #Employee_Leave
		SELECT	@Emp_Id,ISNULL(W.For_Date,H.FOR_DATE),0,0,CASE WHEN W.For_Date IS NULL THEN 'H' ELSE 'W' END,0,0,NULL, NULL
		FROM	#Emp_WeekOff W FULL OUTER JOIN #EMP_HOLIDAY H ON W.Emp_ID=H.EMP_ID AND W.For_Date=H.FOR_DATE
		
		
		
		/*STEP 4
		Getting Only Consecutive Leave Club*/	
		DECLARE	@START_DATE DATETIME
		DECLARE @TMP_LEAVE_ID INT
		
		DECLARE	@LAST_LEAVE_TYPE VARCHAR(32)
		DECLARE @LAST_DATE DATETIME
		DECLARE @LAST_DIFF INT
		DECLARE @LAST_LEAVE_ID INT
		
		
		ALTER TABLE  #Employee_Leave ADD DELETE_FLAG BIT, ST_DATE DATETIME, END_DATE DATETIME
		
		
		
		DECLARE curLeave Cursor Fast_Forward FOR 
		SELECT FOR_DATE, LEAVE_TYPE, LEAVE_ID 
		FROM #Employee_Leave 
		ORDER BY For_Date
		
		OPEN curLeave
		FETCH NEXT FROM curLeave INTO @TMP_DATE, @TMP_LEAVE_TYPE, @TMP_LEAVE_ID
		WHILE @@FETCH_STATUS =0
			BEGIN
				
				
				SET @LAST_DIFF = DATEDIFF(D,@LAST_DATE,@TMP_DATE)
				
				IF @LAST_DIFF > 1 AND @START_DATE IS NOT NULL
					BEGIN 	
							
													
						--IF DATEDIFF(D, 	@START_DATE, @LAST_DATE) < @CONSECUTIVE_LEAVE			
						IF (SELECT SUM(Leave_Period) FROM #Employee_Leave 
							WHERE For_Date BETWEEN @START_DATE AND @LAST_DATE AND Leave_Type NOT IN ('H', 'W')) <= @CONSECUTIVE_LEAVE							
							BEGIN		
								--SELECT * from #Employee_Leave WHERE	For_Date >= @START_DATE AND For_Date < @TMP_DATE 						
								UPDATE	#Employee_Leave
								SET		DELETE_FLAG=1
								WHERE	For_Date >= @START_DATE AND For_Date < @TMP_DATE 
							
							END 
						ELSE
							BEGIN
								IF @IS_CLUB = 1
									BEGIN
										--ADVANCE VALIDATION
										UPDATE	T
										SET		DELETE_FLAG=1
										FROM	#Employee_Leave T
										WHERE	For_Date >= @START_DATE AND For_Date < @TMP_DATE AND T.Leave_Id <> 0
												AND (SELECT COUNT(1) 
													 FROM	(
																SELECT	LEAVE_ID 
																FROM	#Employee_Leave T1 
																WHERE	T1.For_Date >= @START_DATE 
																		AND T1.For_Date < @TMP_DATE AND T1.Leave_Id <> 0
																GROUP BY LEAVE_ID
															 ) T2
													 ) < 2
									END
							END
						IF NOT EXISTS(SELECT 1 FROM #Employee_Leave WHERE For_Date > @TMP_DATE)
						BEGIN
							--SELECT * from #Employee_Leave WHERE	For_Date = @TMP_DATE								
							UPDATE	#Employee_Leave
							SET		DELETE_FLAG=1
							WHERE	For_Date = @TMP_DATE								
						END
							
						SET @START_DATE = NULL
					END
				ELSE IF @LAST_DIFF = 1 AND @LAST_LEAVE_TYPE = 'First Half'  
						AND NOT EXISTS(SELECT 1 FROM #Employee_Leave 
										WHERE For_Date=@LAST_DATE AND Leave_Type='Second Half')
					BEGIN												
						IF (SELECT SUM(Leave_Period) FROM #Employee_Leave 
							WHERE For_Date BETWEEN @START_DATE AND @LAST_DATE AND Leave_Type NOT IN ('H', 'W')) <= @CONSECUTIVE_LEAVE							
							BEGIN								
								UPDATE	#Employee_Leave
								SET		DELETE_FLAG=1
								WHERE	For_Date >= @START_DATE AND For_Date < @TMP_DATE 
								
							END 
						--ELSE
						--	BEGIN
						--		--ADVANCE VALIDATION
						--	END
						IF NOT EXISTS(SELECT 1 FROM #Employee_Leave WHERE For_Date > @TMP_DATE)
							UPDATE	#Employee_Leave
							SET		DELETE_FLAG=1
							WHERE	For_Date = @TMP_DATE	
						SET @START_DATE = NULL
					END
				ELSE IF @LAST_DIFF = 1 AND @LAST_LEAVE_TYPE = 'Second Half'
						AND NOT EXISTS(SELECT 1 FROM #Employee_Leave 
										WHERE For_Date=@LAST_DATE AND Leave_Type='First Half')
					BEGIN					
						
						IF (SELECT SUM(Leave_Period) FROM #Employee_Leave 
							WHERE For_Date BETWEEN @START_DATE AND @LAST_DATE AND Leave_Type NOT IN ('H', 'W')) <= @CONSECUTIVE_LEAVE							
							BEGIN								
								UPDATE	#Employee_Leave
								SET		DELETE_FLAG=1
								WHERE	For_Date >= @START_DATE AND For_Date < @LAST_DATE
								
							END 
						--ELSE
						--	BEGIN
						--		--ADVANCE VALIDATION
						--	END
						IF NOT EXISTS(SELECT 1 FROM #Employee_Leave WHERE For_Date > @TMP_DATE)
							UPDATE	#Employee_Leave
							SET		DELETE_FLAG=1
							WHERE	For_Date = @TMP_DATE	
						SET @START_DATE = @LAST_DATE
					END
				
				
					
				UPDATE #Employee_Leave
				SET		ST_DATE = @START_DATE, END_DATE = @TMP_DATE
				WHERE	For_Date BETWEEN @START_DATE AND @TMP_DATE
				
				--IF @TMP_LEAVE_TYPE	NOT IN ('H', 'W')
				--	BEGIN
						SET	@START_DATE = ISNULL(@START_DATE,@TMP_DATE) 
						SET	@LAST_DATE = @TMP_DATE
						SET @LAST_LEAVE_TYPE = @TMP_LEAVE_TYPE	
					--END
					
				FETCH NEXT FROM curLeave INTO @TMP_DATE, @TMP_LEAVE_TYPE, @TMP_LEAVE_ID
			END
		CLOSE curLeave
		DEALLOCATE curLeave		
		
		--select * from #Employee_Leave order BY for_date
		
		DELETE FROM #Employee_Leave WHERE DELETE_FLAG=1 
			AND Leave_Type NOT IN ('H', 'W') 
			--and Leave_Id = 0  --Change by Jaina 07-07-2017 (If Leave take 18 to 20 and take other leave 25 to  27  that record also delted id we set leave<> 0)
		
		--select * from #Employee_Leave order BY for_date
		
		
		/*STEP 5
		Finding Working Days Between Two Consecutive Club*/	
		--DECLARE curClub Cursor Fast_Forward FOR
		DECLARE @SLAB_FROM DATETIME
		DECLARE @SLAB_TO DATETIME
		
		--select @From_Date
		--GETTING SLAB DATES
		Select	@SLAB_FROM = St_Date, @SLAB_TO=End_Date 
		From	#Employee_Leave 
		Where	@From_Date BETWEEN St_date and End_date 
		
		
		--select @SLAB_FROM,@SLAB_TO,@From_Date,@Consecutive_Leave
		--GETTING BEFORE SLAB
		SET  @TMP_DATE = NULL;
		SET	@LAST_DIFF = NULL
		
		SELECT	@TMP_DATE = MAX(FOR_DATE)
		FROM	#Employee_Leave 
		WHERE	For_Date < @SLAB_FROM AND Leave_Type NOT IN ('H', 'W')
				and DATEDIFF(d,ST_DATE,end_date) + 1 >= @Consecutive_Leave
		

		--select @TMP_DATE,@SLAB_FROM,DATEDIFF(D, @TMP_DATE, @SLAB_FROM)
		IF @TMP_DATE IS NOT NULL
			BEGIN
								
				SELECT	@LAST_DIFF = DATEDIFF(D, @TMP_DATE, @SLAB_FROM)- WH_COUNT -1  --(-1 is added for working days allow 1 and temp date = 18-04-2017 slab-from = 20-04-2017 diff get = 2)
				FROM	#Employee_Leave T
						CROSS APPLY (SELECT Count(1) AS WH_COUNT FROM #Employee_Leave T 
		    							WHERE	For_Date >=  @TMP_DATE  AND For_Date < @SLAB_FROM AND Leave_Type IN ('H', 'W')) T1									
		    	WHERE	For_Date >= @TMP_DATE AND For_Date < @SLAB_FROM --AND Leave_Type NOT IN ('H', 'W')											
														
			END
			
		-----SELECT @LAST_DIFF,@WORK_DAYS
		
		IF @WORK_DAYS = 1 and @CONSECUTIVE_LEAVE  = 1
			begin		
				IF @LAST_DIFF = @WORK_DAYS AND @LAST_DIFF IS NOT NULL
				begin
					RAISERROR('@@Leave Is Not Allowed Between Two Consecutive Club@@',16,2)
					RETURN	
				end
			end
		else
		begin
			IF @LAST_DIFF < @WORK_DAYS AND @LAST_DIFF IS NOT NULL
				BEGIN 		
					RAISERROR('@@Leave Is Not Allowed Between Two Consecutive Club@@',16,2)
					RETURN	
				END
		END

		--GETTING AFTER SLAB
		SET  @TMP_DATE = NULL;
		SET	@LAST_DIFF = NULL

		SELECT	@TMP_DATE = MIN(FOR_DATE)
		FROM	#Employee_Leave 
		---WHERE	For_Date > @SLAB_TO AND Leave_Type NOT IN ('H', 'W')
		WHERE	For_Date between @SLAB_FROM And @SLAB_TO AND Leave_Type NOT IN ('H', 'W')  -----Add Jignesh Patel 12-Jul-2021------
				
		----select @TMP_DATE

		IF @TMP_DATE IS NOT NULL
			BEGIN		
				SELECT	@LAST_DIFF = DATEDIFF(D, @SLAB_TO, @TMP_DATE)- WH_COUNT - 1 --(-1 is added for working days allow 1 and temp date = 18-04-2017 slab-from = 20-04-2017 diff get = 2)
				FROM	#Employee_Leave T
						CROSS APPLY (SELECT Count(1) AS WH_COUNT FROM #Employee_Leave T 
										 WHERE	For_Date >= @SLAB_TO AND For_Date < @TMP_DATE AND Leave_Type IN ('H', 'W')
										 ) T1									
				---WHERE	For_Date >= @SLAB_TO AND For_Date < @TMP_DATE --AND Leave_Type NOT IN ('H', 'W')
    			  Where For_date Between  @TMP_DATE And @SLAB_TO   -----Add Jignesh Patel 12-Jul-2021------
			END
		
		---SELECT @LAST_DIFF,@WORK_DAYS
		
		IF @WORK_DAYS = 1 and @CONSECUTIVE_LEAVE  = 1
			begin
				IF @LAST_DIFF = @WORK_DAYS AND @LAST_DIFF IS NOT NULL
				begin
					RAISERROR('@@Leave Is Not Allowed Between Two Consecutive Club@@',16,2)
					RETURN	
				end
			end
		else
			begin
				IF @LAST_DIFF < @WORK_DAYS AND @LAST_DIFF IS NOT NULL
				begin
					RAISERROR('@@Leave Is Not Allowed Between Two Consecutive Club@@',16,2)
					RETURN	
				end
			end
    
    
END


