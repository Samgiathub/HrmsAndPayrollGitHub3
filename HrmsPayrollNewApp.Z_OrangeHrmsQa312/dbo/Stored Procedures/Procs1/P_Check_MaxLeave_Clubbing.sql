

-- =============================================
-- Author:		<Jaina>
-- Create date: <19-04-2017>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Check_MaxLeave_Clubbing]
	@Emp_Id			NUMERIC,
    @Cmp_Id			NUMERIC,
    @From_Date		DATETIME,
    @To_Date		DATETIME,
    @Leave_Id		NUMERIC,
    @Leave_Period	NUMERIC(18,2),
    @Leave_Assign_As VARCHAR(50) = '',		
    @Leave_Half_Date DATETIME =  null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		 
	Declare @Max_Club_Day numeric
	DECLARE @COUNTER INT
	DECLARE @CHECK_FLAG BIT 
	DECLARE @INTERVAL INT
	DECLARE @TEMP_DATE DATETIME
	DECLARE @HAS_LEAVE BIT
	DECLARE @L_FALG INT =0	
	DECLARE @T_DATE DATETIME
	Declare @Leave_Type varchar(50)
	declare @Half_Leave datetime
	declare @Total_Leave_Days numeric(18,2) = 0
	--DECLARE @HWFROMDATE DATETIME
	--DECLARE @HWTODATE DATETIME
	DECLARE @DOJ datetime
	--DECLARE @StrWeekoff_Date varchar(Max)
	--DECLARE @Weekoff_Days   Numeric(12,1)    
	--DECLARE @Cancel_Weekoff   Numeric(12,1)  
	--DECLARE @StrHoliday_Date   varchar(Max) 
	--DECLARE @Holiday_days   Numeric(12,1) 
	--DECLARE @Cancel_Holiday  Numeric(12,1) 
	DECLARE @Branch_Id  Numeric  
	Declare @Leave_Pre_Post as bit = 0
	   
	SELECT	@Max_Club_Day = SETTING_VALUE 
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	CMP_ID=@CMP_ID AND SETTING_NAME = 'Maximum days allowed for leave clubbing'
	   
	--select @Max_Club_Day,convert(int,@Leave_Period)
	SET @COUNTER = (isnull(@Max_Club_Day,0) - convert(int,@Leave_Period))+1  
	IF @Leave_Period % 1 BETWEEN 0.1 AND 0.5
		SET @COUNTER = @COUNTER +1

		
	SET @INTERVAL = 1
	SET @CHECK_FLAG = 0
	   
	set @Leave_Pre_Post = 1  -- Post date
	   
	--SELECT @Max_Club_Day
	SELECT @DOJ = DATE_OF_JOIN FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @EMP_ID
	   
	   
	IF IsNull(@Leave_Half_Date,'1900-01-01') <> '1900-01-01'	
		SET @TEMP_DATE = @Leave_Half_Date
	ELSE
		SET @TEMP_DATE = @To_Date

	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
	/*FOLLOWING CODE ADDED BY NIMESH ON 18-SEP-2017 (WE ARE TRYING TO REMOVE THE OLD METHOD SP_EMP_WEEKOFF_DATE_GET AND SP_EMP_HOLIDAY_DATE_GET*/
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

	DECLARE @CONSTRAINT VARCHAR(20)
	SET @CONSTRAINT = CAST(@Emp_Id AS VARCHAR(10))

	DECLARE @TEMP_FROM_DATE DATETIME
	DECLARE @TEMP_TO_DATE DATETIME

	SET @TEMP_FROM_DATE = DATEADD(D, -12, @FROM_DATE) 
	SET @TEMP_TO_DATE = DATEADD(M, 12, @To_Date)	
	
	IF @Required_Execution = 1
		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@TEMP_FROM_DATE, @TO_DATE=@TEMP_TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		

		
	IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Is_Leave_Clubbed=1 AND LEAVE_ID=@LEAVE_ID)
	   BEGIN
			CREATE TABLE #Leave_Cons ( Leave_ID NUMERIC )
			
			DECLARE @Leave_Club_With VARCHAR(500)
				
			SELECT  @Leave_Club_With = ISNULL(LEAVE_CLUB_WITH, '')
			FROM    T0040_LEAVE_MASTER WITH (NOLOCK)
			WHERE   Cmp_ID = @Cmp_Id
					AND Leave_Id = @Leave_Id
		                
				
			INSERT  INTO #Leave_Cons
			SELECT	LEAVE_ID FROM T0040_LEAVE_MASTER LM  WITH (NOLOCK)
			WHERE	EXISTS(SELECT 1 FROM    dbo.Split(@Leave_Club_With, '#') T 
							WHERE DATA <> '' AND CAST(DATA AS NUMERIC) = LM.LEAVE_ID)
					AND LM.LEAVE_ID<>@LEAVE_ID
					AND LM.CMP_ID=@CMP_ID	
				
				
			SELECT	@BRANCH_ID = BRANCH_ID
			FROM	T0095_INCREMENT EI  WITH (NOLOCK)
			WHERE	INCREMENT_ID IN   
					(
						SELECT	MAX(Increment_Id) AS Increment_effective_Date 
						from T0095_Increment  WITH (NOLOCK)
						where Increment_Effective_date <= @From_Date  
							and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
					) and Emp_ID = @Emp_Id
				
				--select @COUNTER,@TEMP_DATE
		LOOP:
			--IF @INTERVAL > 0
			--	BEGIN
			--		SET @hwFromDate = @TEMP_DATE
			--		SET @hwToDate = DATEADD(D, @COUNTER * @INTERVAL, @TEMP_DATE)				
			--	END
			--ELSE
			--	BEGIN
			--		SET @hwFromDate = DATEADD(D, @COUNTER * @INTERVAL, @TEMP_DATE)
			--		SET @hwToDate = @TEMP_DATE
			--	END
					
				
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@hwFromDate,@hwToDate,@DOJ,null,0,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,0,1     
			--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@hwFromDate,@hwToDate,@DOJ,null,0,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_Id,@StrWeekoff_Date,1
			
				
				
			WHILE @COUNTER >0
				BEGIN
					set @HAS_LEAVE = 0
					SET @L_FALG = 0
					
					IF EXISTS(SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
								INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID 
								INNER JOIN #LEAVE_CONS L ON L.LEAVE_ID = LAD.LEAVE_ID
								WHERE LA.Emp_ID=@EMP_ID AND 
									@TEMP_DATE BETWEEN FROM_DATE AND TO_DATE
									AND LA.Application_Status = 'P'
									AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID))								  													
						BEGIN
								
								SELECT @Leave_Type=LAD.Leave_Assign_As,@Half_Leave =LAD.Half_Leave_Date FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
										INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID
										inner JOIN #LEAVE_CONS L ON L.LEAVE_ID = LAD.LEAVE_ID
								WHERE LA.Emp_ID=@EMP_ID AND 
									  @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE
									  AND LA.Application_Status = 'P'
									  AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)
									  
									--select @Leave_Type		
									--select @TEMP_DATE,@Half_Leave
									IF @Half_Leave = @TEMP_DATE and @Leave_Type = 'First Half'
									BEGIN
														
											set @Total_Leave_Days +=0.5
											set @L_Falg = 1
									END
									ELSE IF @Half_Leave = @TEMP_DATE and @Leave_Type = 'Second Half'
									BEGIN
																
											set @Total_Leave_Days +=0.5
											set @L_Falg = 2
									END
									ELSE
									begin
											SET @Total_Leave_Days +=1
									end
														
									SET @HAS_LEAVE =1
									set @T_DATE = @TEMP_DATE
									
						END		
						
					--More than 0.5 Leave Approval Is Exist
					IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
								INNER JOIN #Leave_Cons L ON L.Leave_ID = T.Leave_ID
								WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE AND (IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0)) > 0.5)
						BEGIN															
							SET @HAS_LEAVE =1
							set @Total_Leave_Days +=1
						END
					--Approval Exits (0.5 First/Second)
					ELSE IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION  T WITH (NOLOCK) INNER JOIN
									#Leave_Cons L ON L.Leave_ID = T.Leave_ID
									WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE 
									AND (IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0)) = 0.5)
												  
						BEGIN			
							SELECT @T_DATE = For_Date FROM T0140_LEAVE_TRANSACTION T WITH (NOLOCK) INNER JOIN
									#Leave_Cons L ON L.Leave_ID = T.Leave_ID
							WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE 
									AND (IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0)) = 0.5
																
							select @Leave_Type = LAD.Leave_Assign_As 
							from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
									inner JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
									inner JOIN #Leave_Cons L ON L.Leave_ID = LAD.Leave_ID
							where LA.Emp_ID=@emp_ID and (LAD.From_Date = @TEMP_DATE OR LAD.Half_Leave_Date= @TEMP_DATE )
								and la.Approval_Status='A' 
													
													
							IF @Leave_Type = 'First Half' 
								Begin
									set @L_Falg = 1
									set @Total_Leave_Days +=0.5
								END
							ELSE IF @Leave_Type = 'Second Half'
								BEGIN
									set @L_Falg = 2
									set @Total_Leave_Days +=0.5
								END
									 --select DATEADD(d,-1,@tmpFrom_Date),@Total_Leave_Days,@TEMP_DATE,@T_DATE,@tmpFrom_Date										
							SET @HAS_LEAVE =1
						End			

					DECLARE @WH_STATUS TINYINT
					IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@TEMP_DATE) 
						SET @WH_STATUS = 1
					ELSE IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE FOR_DATE=@TEMP_DATE)	
						SET @WH_STATUS = 2
					ELSE
						SET @WH_STATUS = 0
						
					IF @TOTAL_LEAVE_DAYS = 0 AND @HAS_LEAVE = 0 --2 day app (5,6 Date) and take 1.5 day leave (3,4 FH Date)
						BEGIN							
							--IF (CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @STRWEEKOFF_DATE) > 0
							--	OR CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @STRHOLIDAY_DATE) > 0)
							IF @WH_STATUS <> 0
								BEGIN
										print 'Weekoff/Holiday Exists'
								END
							ELSE
								BEGIN
									--select @TEMP_DATE
										BREAK
								END
						END			
						
					IF @HAS_LEAVE = 1
						BEGIN
							IF @Leave_Pre_Post  = 1 and @T_DATE = @From_Date
								BEGIN																
									IF @L_Falg = 1   -- leave exists(3,4(FH) date) and take it (5,6 date)
										BEGIN										
											set @Total_Leave_Days = 0
											BREAK
										END															
								END
							ELSE IF @Leave_Pre_Post  = 0 and @T_DATE = @To_Date
								BEGIN
									 IF @L_Falg = 2 
								  		BEGIN					
											set @Total_Leave_Days = 0
											BREAK
						 				END									
								END														
						END

					--ELSE IF (CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrWeekoff_Date) > 0
					--			 OR CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrHoliday_Date) > 0)
					ELSE IF @WH_STATUS <> 0
								AND @HAS_LEAVE = 0
						BEGIN									
							print 'Weekoff/Holiday Exists'
						END
					ELSE
						BEGIN												
							BREAK
						END
													
					--IF (CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrWeekoff_Date) > 0
					--	OR CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrHoliday_Date) > 0)
					IF @WH_STATUS <> 0
						AND @HAS_LEAVE = 0
						BEGIN
							SET @TEMP_DATE = DATEADD(D, @INTERVAL, @TEMP_DATE)
						END
					ELSE
						BEGIN
							SET @COUNTER = @COUNTER - 1
							--select @TEMP_DATE
							SET @TEMP_DATE = DATEADD(D, @INTERVAL, @TEMP_DATE)	
							--select @TEMP_DATE			
						END		
					--select @TEMP_DATE				
				ENd
				
				IF @Leave_Pre_Post = 1
					BEGIN
						IF @Leave_Half_Date= @To_Date and @Leave_Assign_As = 'Second Half' and @Total_Leave_Days = 0   --25,26,27 date 3 day 29 0.5 SH  FH GAP
							SET @Leave_Period = 0
					END
				ELSE
					BEGIN
						IF @Leave_Half_Date= @From_Date and @Leave_Assign_As = 'First Half' and @Total_Leave_Days = 0  --25,26,27 date 3 day 24 0.5 FH  SH GAP
							SET @Leave_Period = 0
					END
				
				--select @Total_Leave_Days,@Leave_Period
				If (ISNULL(@Total_Leave_Days,0)+ @Leave_Period  > @Max_Club_Day and @Max_Club_Day > 0)
					Begin
						RAISERROR('@@Clubbing Is Not Allowed Beyond Max Club Limit@@',16,2)
						RETURN 
					END
				ELSE IF @CHECK_FLAG = 0
					Begin						
						set @Leave_Pre_Post = 2
						SET @COUNTER = (@Max_Club_Day - (convert(int,@Leave_Period))) + 1 --(4 - (2 + 1)) + 1 = 2 
						SET @INTERVAL = -1
									
										
						if IsNull(@Leave_Half_Date, '1900-01-01') <> '1900-01-01'
							Begin
								SET @TEMP_DATE = @From_Date
								SET	@CHECK_FLAG  = 1
								Goto LOOP;
							END
						ELSE
							Begin
									SET @TEMP_DATE = @From_Date
									SET	@CHECK_FLAG  = 1
								
									Goto LOOP;
							END	
					END	
							
	   END
END

