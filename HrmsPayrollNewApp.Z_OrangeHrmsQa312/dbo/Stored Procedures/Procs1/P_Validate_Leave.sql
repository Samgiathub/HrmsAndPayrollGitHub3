

-- =============================================
-- Author:		<Jaina>
-- Create date: <18-03-2017>
-- Description:	<Leave Application Validation>
-- =============================================
CREATE PROCEDURE [dbo].[P_Validate_Leave]
    @Emp_Id					numeric
   ,@Cmp_ID					numeric
   ,@Leave_ID				numeric
   ,@From_Date				datetime
   ,@To_Date				datetime
   ,@Leave_Period			numeric(18,2)
   ,@Leave_Application_ID	numeric = 0
   ,@Leave_Approval_ID   numeric = 0
   ,@Leave_Assign_As		varchar(50) = ''
   ,@Half_Leave_Date    datetime = null
   ,@ApprovalFlag INT = null
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

		
	DECLARE @tmpFrom_Date datetime
	DECLARE @tmpTo_Date datetime	
	DECLARE @Total_Leave_Days numeric(18,2)
	DECLARE @Total_Cancel_Day numeric(18,2)
	DECLARE @Leave_Max		numeric(18,2)
	DECLARE @apply_hourly as numeric
	DECLARE @Branch_Id  Numeric
	Declare @indDay as integer
	DECLARE @MONTH_ST_DATE DATETIME   
	DECLARE @MONTH_END_DATE DATETIME    
	DECLARE @MONTHLY_MAX_LEAVE NUMERIC(18,2) = 0  
	DECLARE @TOTAL_LEAVE NUMERIC(18,2) = 0
	DECLARE @EFFECT_SALARY_CYCLE AS BIT = 0
	DECLARE @PRE_TEMP_PERIOD AS NUMERIC(18,2)
	DECLARE @POST_TEMP_PERIOD AS NUMERIC(18,2)
	DECLARE @TEMP_LEAVE_PERIOD AS NUMERIC(18,2)
	Declare @L_Falg int =0	
	DECLARE @T_DATE DATETIME
	Declare @Leave_Pre_Post as bit = 0
	
	--Added by Jaina 13-03-2019 Start
	DECLARE @Pending_Leave_Count numeric(18,0) = 0
	DECLARE @Approval_Leave_Count numeric(18,0) = 0
	DECLARE @Max_Leave_Lifetime numeric(18,2) = 0
	Declare @MPLeave_type varchar(100) = ''
	--Added by Jaina 13-03-2019 End
	

	SET @TEMP_LEAVE_PERIOD = @Leave_Period	
	
	--ADDED BY JAINA 28-03-2017 End

	if @Leave_Application_Id is null
		set @Leave_Application_Id = 0
	IF @Leave_Approval_ID IS NULL
		SET @Leave_Approval_ID = 0
	
	--Set @StrWeekoff_Date = '' 
	--Set @Weekoff_Days  = 0
	--Set @Cancel_Weekoff    = 0
		 
	--Set @StrHoliday_Date  = '' 
	--Set @Holiday_days   = 0
	--Set @Cancel_Holiday   = 0
	Set @Branch_Id   = 0
		
	Declare @Leave_negative_Allow tinyint
	Set @Leave_negative_Allow = 0
	
	DECLARE @CYCLE_STATUS TINYINT
	SET @CYCLE_STATUS = 0
	
	--Getting Settings from Leave Master
	SELECT @LEAVE_NEGATIVE_ALLOW = LEAVE_NEGATIVE_ALLOW, @LEAVE_MAX=ISNULL(LEAVE_MAX,0),
		   @APPLY_HOURLY = ISNULL(APPLY_HOURLY,0),@MONTHLY_MAX_LEAVE=ISNULL(MONTHLY_MAX_LEAVE,0),
		   @EFFECT_SALARY_CYCLE = ISNULL(EFFECT_SALARY_CYCLE,0),
		   @MAX_LEAVE_LIFETIME = ISNULL(MAX_LEAVE_LIFETIME,0),  --Added by Jaina 13-03-2019
		   @MPLeave_type = Leave_Type
	FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND LEAVE_ID = @LEAVE_ID
	
		 -- Overwrite @Leave_Max value 
	DECLARE @YEAR AS NUMERIC
	SET @YEAR = YEAR(GETDATE())
		
	IF MONTH(GETDATE())> 3
	BEGIN
		SET @YEAR = @YEAR + 1
	END
		
	Declare @date as varchar(20)  
	Set @date = '31-Mar-' + convert(varchar(5),@Year) 
	
	SELECT	@BRANCH_ID = BRANCH_ID
	FROM	T0095_INCREMENT EI WITH (NOLOCK)
	WHERE	INCREMENT_ID IN   
			(
				SELECT	MAX(Increment_Id) AS Increment_effective_Date 
				from T0095_Increment WITH (NOLOCK)  
				where Increment_Effective_date <= @From_Date  
				   and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id
			) and Emp_ID = @Emp_Id
		
	
	/*FOLLOWING CODE ADDED BY NIMESH ON 18-SEP-2017 (WE ARE TRYING TO REMOVE THE OLD METHOD SP_EMP_WEEKOFF_DATE_GET AND SP_EMP_HOLIDAY_DATE_GET*/
	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		
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

	DECLARE @CONSTRAINT VARCHAR(20)
	SET @CONSTRAINT = CAST(@Emp_Id AS VARCHAR(10))

	DECLARE @TEMP_FROM_DATE DATETIME
	DECLARE @TEMP_TO_DATE DATETIME

	SET @TEMP_FROM_DATE = DATEADD(D, -12, @FROM_DATE) 
	SET @TEMP_TO_DATE = DATEADD(M, 12, @To_Date)	

	
	
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@TEMP_FROM_DATE, @TO_DATE=@TEMP_TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		

	Declare @SalaryCycle as Date 
	select @SalaryCycle = Sal_St_Date from T0040_GENERAL_SETTING where Branch_id = @Branch_Id and Cmp_ID = @Cmp_ID
	
	--Getting Settings from Leave Detail
	SELECT @LEAVE_MAX = CASE WHEN ISNULL(TEMP.MAX_LEAVE,0)=0 THEN 
										LM.LEAVE_MAX 
							 ELSE TEMP.MAX_LEAVE END ,
		   @EFFECT_SALARY_CYCLE = CASE WHEN ISNULL(temp.EFFECT_SALARY_CYCLE,0) = 0 THEN
									LM.Effect_Salary_Cycle
								ELSE temp.EFFECT_SALARY_CYCLE END,
			@MONTHLY_MAX_LEAVE = CASE WHEN ISNULL(temp.MONTHLY_MAX_LEAVE,0) = 0 THEN
										LM.Monthly_Max_Leave
								ELSE temp.MONTHLY_MAX_LEAVE END
	FROM T0040_LEAVE_MASTER LM WITH (NOLOCK) LEFT JOIN 
			(SELECT MAX_LEAVE,LEAVE_ID,EFFECT_SALARY_CYCLE,MONTHLY_MAX_LEAVE
			 FROM T0050_LEAVE_DETAIL WITH (NOLOCK) 
			 WHERE LEAVE_ID = @LEAVE_ID 
			 AND CMP_ID = @CMP_ID AND GRD_ID IN (SELECT I.GRD_ID FROM   DBO.T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
				(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,EMP_ID FROM DBO.T0095_INCREMENT IM  WITH (NOLOCK)
			    	WHERE INCREMENT_EFFECTIVE_DATE <= @DATE GROUP BY EMP_ID 
				 ) QRY ON I.EMP_ID = QRY.EMP_ID 
				AND I.INCREMENT_ID = QRY.INCREMENT_ID INNER JOIN
				DBO.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = QRY.EMP_ID 
				WHERE EM.CMP_ID = @CMP_ID AND EM.EMP_ID = @EMP_ID)
			) AS TEMP ON LM.LEAVE_ID = TEMP.LEAVE_ID 
	WHERE LM.LEAVE_ID = @LEAVE_ID 
		
		
	
	--START Deepal 17062024 -- Commented the below code of effect on salary cycle ticket Id 29738
	--	if day(@FROM_DATE) >= 26
	--		If Month(@From_Date) = 12
	--			SELECT @MONTH_ST_DATE= Sal_St_Date,@MONTH_END_DATE = Sal_End_Date FROM F_Get_SalaryDate (@Cmp_id,@Branch_id,MONTH('01-Jan-1900'),YEAR(@FROM_DATE)+1)		
	--		Else
	--			SELECT @MONTH_ST_DATE= Sal_St_Date,@MONTH_END_DATE = Sal_End_Date FROM F_Get_SalaryDate (@Cmp_id,@Branch_id,MONTH(@FROM_DATE)+1,YEAR(@FROM_DATE))		
	--end
	if @EFFECT_SALARY_CYCLE = 1  --Added by Jaina 09-08-2019 ( Case is : Current month is : 9 and salary cycle :26-25  and from daate : 26-9 to 29-9 that time consider month 10.)
	begin
		SELECT @MONTH_ST_DATE= Sal_St_Date,@MONTH_END_DATE = Sal_End_Date FROM F_Get_SalaryDate (@Cmp_id,@Branch_id,MONTH(@FROM_DATE),YEAR(@FROM_DATE))
	END
	ELSE 
	BEGIN
		select @MONTH_ST_DATE = dateadd(d,-1,dateadd(mm,datediff(m,0,@FROM_DATE),1 ))
		select @MONTH_END_DATE = dateadd(s,-1,dateadd(mm,datediff(m,0,@To_Date)+1,0))
	END
	--END Deepal 17062024 ticket Id 29738
	
	
	IF OBJECT_ID('TEMPDB..#Leave_Dates') IS NOT NULL	
		DROP TABLE #Leave_Dates
			
	CREATE TABLE #Leave_Dates
	(
		L_Date datetime
	)
	--select @MONTH_ST_DATE,@MONTH_END_DATE
		/******************************************************************
		**********VALIDATION FOR CONTINUOUS LEAVE LIMIT*******************
		******************************************************************/				
				
		set @indDay = 1
		set @Total_Leave_Days = 0
		if @EFFECT_SALARY_CYCLE = 1
			Begin
					
					IF @MONTH_ST_DATE = @From_Date or @MONTH_ST_DATE = @To_Date
						begin
							--select 3
							Set @tmpFrom_Date = @From_Date
						end
					else
						Set @tmpFrom_Date = DATEADD(d,-1,@From_Date)
					
					IF @MONTH_END_DATE = @To_Date or @MONTH_END_DATE = @From_Date
						Set @tmpTo_Date = @To_Date
					else
						Set @tmpTo_Date = DATEADD(d,1,@To_Date)
					
					
					IF (@MONTH_END_DATE BETWEEN @FROM_DATE AND @TO_DATE  -- If salary cycle 26-25
						OR (ABS(DATEDIFF(D, @MONTH_END_DATE, @FROM_DATE)) < 2 AND @LEAVE_PERIOD > 1 ))
					--IF MONTH(@FROM_DATE) <> MONTH(@TO_DATE)  --If take leave on 30-03-2017 to 01-04-2017
						BEGIN
							
							--IF OBJECT_ID('TEMPDB..#Leave_Dates') IS NOT NULL	
							--	DROP TABLE #Leave_Dates
					
							--CREATE TABLE #Leave_Dates
							--(
							--	L_Date datetime
							--)
							Insert INTO #Leave_Dates
							exec Calculate_Leave_End_Date @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Leave_Id=@Leave_ID,@From_Date=@From_Date,@Period=@Leave_Period,@Type='o',@M_Cancel_weekoff_holiday=0,@Leave_Assign_As=@Leave_Assign_As
							
							select @PRE_TEMP_PERIOD = COUNT(*) from #Leave_Dates where L_Date between @MONTH_ST_DATE AND @MONTH_END_DATE
							select @POST_TEMP_PERIOD = COUNT(*) from #Leave_Dates where L_Date > @MONTH_END_DATE
							SET @TEMP_LEAVE_PERIOD = @PRE_TEMP_PERIOD													
							Set @tmpTo_Date =  @MONTH_END_DATE								
							SET @CYCLE_STATUS = 1
							SET @PRE_TEMP_PERIOD = 0
							SET @POST_TEMP_PERIOD = 0
							
							
						END
			END
		ELSE
			BEGIN
					Set @tmpFrom_Date = DATEADD(d,-1,@From_Date)
					Set @tmpTo_Date = DATEADD(d,1,@To_Date)		
			END
			
		
		--select @tmpFrom_Date,@tmpTo_Date
SAL_CYCLE:
		
		DECLARE @COUNTER INT
		DECLARE @INTERVAL INT
		DECLARE @TEMP_DATE DATETIME
		DECLARE @CHECK_FLAG BIT 
		Declare @Leave_Type varchar(50)
		declare @Half_Leave datetime
		DECLARE @HAS_LEAVE BIT
		 
		SET @COUNTER = (@LEAVE_MAX - convert(int,@TEMP_LEAVE_PERIOD))+1  

		SET @INTERVAL = 1
		SET @CHECK_FLAG  = 0
		set @Leave_Type = ''
		
		
		if IsNull(@Half_Leave_Date,'1900-01-01') <> '1900-01-01'
		BEGIN
			SET @TEMP_DATE = @To_Date
		END
		ELSE IF @CYCLE_STATUS = 1  --If ForDate : 30-03-2017 ToDate: 01-04-2017  set interval -1 For this case (it check 29-03-2017 date)
			BEGIN 
				SET @INTERVAL = -1
				SET @TEMP_DATE = @tmpFrom_Date
				SET	@CHECK_FLAG  = 1				
			END
		ELSE
			SET @TEMP_DATE = @tmpTo_Date
		
														
		--SELECT @tmpFrom_Date,@tmpTo_Date,@TEMP_DATE
		
		--DECLARE @HWFROMDATE DATETIME
		--DECLARE @HWTODATE DATETIME
		set @Leave_Pre_Post = 1  -- Post date
		
		--select @TEMP_DATE,@COUNTER
		Begin
LOOP:				
			--Deepal
			--SELECT * FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
			--INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) 
			--ON LA.Leave_Application_ID=LAD.Leave_Application_ID 
			--WHERE LA.Emp_ID=@EMP_ID AND 
			----	@TEMP_DATE BETWEEN FROM_DATE AND TO_DATE AND 
			--LA.Application_Status = 'P'
			--and LA.Leave_Application_ID <> IsNull(@Leave_Application_Id,0)
			--AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)
			--AND LAD.LEAVE_ID = @LEAVE_ID

			---Check for Holiday /Weekoff Case
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
					
				
				WHILE @COUNTER > 0
					BEGIN			
						SET @HAS_LEAVE =0
											
							BEGIN						
								if @indDay <> 0
									begin
										
										BEGIN
											set @L_Falg = 0

											DECLARE @WH_STATUS TINYINT
											IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@TEMP_DATE) 
												SET @WH_STATUS = 1
											ELSE IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE FOR_DATE=@TEMP_DATE)	
												SET @WH_STATUS = 2
											ELSE
												SET @WH_STATUS = 0
												
												----Leave App Exist without Approval (Half Leave Date Case )
											IF EXISTS(SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
															INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID 
														WHERE LA.Emp_ID=@EMP_ID AND 
															@TEMP_DATE BETWEEN FROM_DATE AND TO_DATE
															AND LA.Application_Status = 'P'
															and LA.Leave_Application_ID <> IsNull(@Leave_Application_Id,0)
															AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)
															AND LAD.LEAVE_ID = @LEAVE_ID)
															
												BEGIN
													
													SELECT @Leave_Type=LAD.Leave_Assign_As,@Half_Leave =LAD.Half_Leave_Date FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
															INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID
														WHERE LA.Emp_ID=@EMP_ID AND 
															@TEMP_DATE BETWEEN FROM_DATE AND TO_DATE
															AND LA.Application_Status = 'P'
															and LA.Leave_Application_ID <> @Leave_Application_Id
															AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID)
															AND LAD.LEAVE_ID = @LEAVE_ID
															
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
														ELSE if @Leave_Assign_As <> 'Part Day' AND @TEMP_DATE <> @From_Date
														begin
															SET @Total_Leave_Days +=1
														end
														--ELSE if @Leave_Assign_As = 'Part Day' AND @TEMP_DATE = @From_Date
														--begin
														--	SET @Total_Leave_Days += 1
														--	select 1
														--end
														--ELSE
														--begin
														--	SET @Total_Leave_Days += 1
														--end
														
														--if @Leave_Assign_As = 'Part Day'
														--begin
														
														--if exists (select 1 from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
														--and la.Emp_ID = @Emp_Id and lad.From_Date = @From_Date and lad.To_Date = @To_Date)
														--begin
														--	SElecT @Total_Leave_Days = @Total_Leave_Days + sum(lad.leave_period) from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
														--	and la.Emp_ID = @Emp_Id and lad.From_Date = @From_Date and lad.To_Date = @To_Date
															
														--end
														--end
														SET @HAS_LEAVE =1
														set @T_DATE = @TEMP_DATE
														--select  @TEMP_DATE,@Total_Leave_Days
												END		
														
											--More than 0.5 Leave Approval Is Exist
											IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
														WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE AND (IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0) + Isnull(Back_Dated_Leave,0)) > 0.5 AND Leave_ID = @Leave_ID)
												BEGIN
													
													SET @HAS_LEAVE =1
													set @Total_Leave_Days +=1
													
												END
												--Approval Exits (0.5 First/Second)
											Else IF EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE 
																AND (IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0)  + Isnull(Back_Dated_Leave,0)) = 0.5)
												  
												Begin
													
													
													SELECT @T_DATE = For_Date FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_DATE 
																AND (IsNUll(Leave_Used,0) + ISNULL(CompOff_Used,0)  + Isnull(Back_Dated_Leave,0)) = 0.5
																
													select @Leave_Type = LAD.Leave_Assign_As 
													from T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
														inner JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
													where LA.Emp_ID=@emp_ID and (LAD.From_Date = @TEMP_DATE OR LAD.Half_Leave_Date= @TEMP_DATE )
														and la.Approval_Status='A' and LAD.Leave_ID = @Leave_ID
													
													
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
												
													
												if @Total_Leave_Days = 0 and @HAS_LEAVE = 0 --2 day app (5,6 Date) and take 1.5 day leave (3,4 FH Date)
													begin
														--IF (CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrWeekoff_Date) > 0
														--	OR CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrHoliday_Date) > 0)
														IF @WH_STATUS <> 0
															BEGIN
																print 'Weekoff/Holiday Exists'
															END
														ELSE
															begin
																--select @TEMP_DATE
																break
															end
													end	
													
												if @HAS_LEAVE = 1
													Begin
														IF @Leave_Pre_Post  = 1 and @T_DATE = @tmpFrom_Date
															Begin
																
																if @L_Falg = 1   -- leave exists(3,4(FH) date) and take it (5,6 date)
																	BEGIN
																
																		set @Total_Leave_Days = 0
																		BREAK
																	END
															
															END
														ELSE if @Leave_Pre_Post  = 0 and @T_DATE = @tmpTo_Date
															BEGIN
																
																 if @L_Falg = 2 
																	BEGIN
																		
																		set @Total_Leave_Days = 0
																		BREAK
																	END									
															END	
															
													END
												--ELSE IF (CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrWeekoff_Date) > 0
												--	OR CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrHoliday_Date) > 0)
												ELSE IF @WH_STATUS <> 0
													AND @HAS_LEAVE = 0
													Begin
														print 'Weekoff/Holiday Exists'
													End
												ELSE
													BEGIN
														
														BREAK
													END
												
											
										END 

										if @Leave_Assign_As = 'Part Day'
										begin
											if @ApprovalFlag = 1
											begin
												set @Total_Leave_Days = 0
											end
											else
											begin
											if exists (select 1 from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
											and la.Emp_ID = @Emp_Id and lad.From_Date = @From_Date and lad.To_Date = @To_Date)
											begin
												SElecT @Total_Leave_Days = sum(lad.leave_period) from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
												and la.Emp_ID = @Emp_Id and lad.From_Date = @From_Date and lad.To_Date = @To_Date															
											end
											else
											begin
											set @Total_Leave_Days = 0
											end 
											end
										end						
																
									END	
									 
									--Set Date For Weekoff and Holiday Date									
									--IF (CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrWeekoff_Date) > 0
									--	OR CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrHoliday_Date) > 0)
									IF @WH_STATUS <> 0
										AND @HAS_LEAVE = 0
										begin
											SET @TEMP_DATE = DATEADD(D, @INTERVAL, @TEMP_DATE)
										end
									ELSE
										BEGIN
											SET @COUNTER = @COUNTER - 1
											--select @TEMP_DATE
											SET @TEMP_DATE = DATEADD(D, @INTERVAL, @TEMP_DATE)	
											--select @TEMP_DATE			
										END									
							END
					END
					If @Leave_Pre_Post = 1
						Begin
							IF @Half_Leave_Date= @To_Date and @Leave_Assign_As = 'Second Half' and @Total_Leave_Days = 0   --25,26,27 date 3 day 29 0.5 SH  FH GAP
							Begin
								
								set @TEMP_LEAVE_PERIOD = 0
								--return
								GOTO BREAK_LOOP;
							End
						END
					ELSE
						BEgin
							IF @Half_Leave_Date= @From_Date and @Leave_Assign_As = 'First Half' and @Total_Leave_Days = 0  --25,26,27 date 3 day 24 0.5 FH  SH GAP
							Begin
								
								set @TEMP_LEAVE_PERIOD = 0
								--return
								GOTO BREAK_LOOP;
							End
						END
					
					
					DECLARE @PREDATE AS DATE = DATEADD(D,-1,@FROM_DATE)
					DECLARE @NEXTDATE AS DATE = DATEADD(D,1,@FROM_DATE)
					DECLARE @ToChkPreDate AS DATE 
					DECLARE @ToChkNXtDate AS DATE 
					DECLARE @ShortLeave	AS INT = 1
					Declare @CntPreDate as int = 0
					Declare @CntNxtDate as int = 0

					IF OBJECT_ID('TEMPDB..#temp12') IS NOT NULL	
						DROP TABLE #temp12

					Select * into #temp12 from (
								Select LAD.Leave_ID,LAD.From_Date,LAD.To_Date,LA.Emp_ID
								from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
								on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
								and la.Emp_ID = @Emp_Id 
								and month(LAD.From_Date) = Month(@From_Date) and Year(LAD.To_Date) = Year(@From_Date)
								ANd LAD.Leave_ID = @Leave_ID and Application_Status= 'P'
								union 
								Select LADD.Leave_ID,LADD.From_Date,LADD.To_Date,LAA.Emp_ID 
								from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
								on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
								and la.Emp_ID = @Emp_Id 
								and month(LAD.From_Date) = Month(@From_Date) and Year(LAD.To_Date) = Year(@From_Date)
								ANd LAD.Leave_ID = @Leave_ID and Application_Status= 'A'
								inner join T0120_LEAVE_APPROVAL LAa on LAA.Leave_Application_ID = LA.Leave_Application_ID
								Inner join T0130_LEAVE_APPROVAL_DETAIL LADD on LADD.Leave_Approval_ID = LAA.Leave_Approval_ID
					) as T

					
					--IF EXISTS(Select 1 from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
					--on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
					--and la.Emp_ID = @Emp_Id and LAD.From_Date = @PreDate and LAD.To_Date = @PreDate
					--ANd LAD.Leave_ID = @Leave_ID)
					
					if @EFFECT_SALARY_CYCLE  = 1
					BEGIN
					
						IF OBJECT_ID('TEMPDB..#temp12') IS NOT NULL	
							Truncate table #temp12
							
						IF ((Select Count(1) from #temp12) = 0)
						BEGIN

							insert into #temp12
							select * from (
								Select LAD.Leave_ID,LAD.From_Date,LAD.To_Date,LA.Emp_ID 
								from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
								on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As and la.Emp_ID = @Emp_Id 
								and LAD.From_Date >=  @MONTH_ST_DATE   and LAD.To_Date <= @MONTH_END_DATE
								ANd LAD.Leave_ID = @Leave_ID and Application_Status = 'P'

								union 

								Select LADD.Leave_ID,LADD.From_Date,LADD.To_Date,LAA.Emp_ID 
								from T0100_LEAVE_APPLICATION LA 
								INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As and la.Emp_ID = @Emp_Id 
								and LAD.From_Date >=  @MONTH_ST_DATE  and LAD.To_Date <= @MONTH_END_DATE ANd LAD.Leave_ID = @Leave_ID and Application_Status= 'A'
								inner join T0120_LEAVE_APPROVAL LAa on LAA.Leave_Application_ID = LA.Leave_Application_ID
								Inner join T0130_LEAVE_APPROVAL_DETAIL LADD on LADD.Leave_Approval_ID = LAA.Leave_Approval_ID
							) As T

							
							
							--select * from (
							--	Select LAD.Leave_ID,LAD.From_Date,LAD.To_Date,LA.Emp_ID from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
							--	on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
							--	and la.Emp_ID = @Emp_Id 
							--	and month(LAD.From_Date) =  Month(dateADD(m,-1,@From_Date))  and Year(LAD.To_Date) = Year(dateADD(m,-1,@From_Date))
							--	ANd LAD.Leave_ID = @Leave_ID and Application_Status= 'P'
							--	union 
							--	Select LADD.Leave_ID,LADD.From_Date,LADD.To_Date,LAA.Emp_ID from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
							--	on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
							--	and la.Emp_ID = @Emp_Id 
							--	and month(LAD.From_Date) =  Month(dateADD(m,-1,@From_Date))  and Year(LAD.To_Date) = Year(dateADD(m,-1,@From_Date))
							--	ANd LAD.Leave_ID = @Leave_ID and Application_Status= 'A'
							--	inner join T0120_LEAVE_APPROVAL LAa on LAA.Leave_Application_ID = LA.Leave_Application_ID
							--	Inner join T0130_LEAVE_APPROVAL_DETAIL LADD on LADD.Leave_Approval_ID = LAA.Leave_Approval_ID
							--) As T
							
							
						END
					END

					
					if (DATEDIFF(DAY,cast(@From_Date as date),cast(@To_Date as date)) + 1) > @Leave_Max and @Leave_Max > 0
					BEGIN
						print 1
						RAISERROR('@@Continuous Leave Is Not Allowed Beyond Max Limit@@',16,2)
						RETURN 
					END
					
					IF EXISTS(Select 1 from #temp12 Where Emp_ID = @Emp_Id and From_Date = @PreDate and To_Date = @PreDate ANd Leave_ID = @Leave_ID) and
						EXISTS(Select 1 from #temp12 Where Emp_ID = @Emp_Id and From_Date = @NEXTDATE and To_Date = @NEXTDATE ANd Leave_ID = @Leave_ID)
					Begin 
							print 1
							While @ShortLeave <= @Leave_Max
							Begin
								set @ToChkPreDate = DATEADD(D,-@ShortLeave,@From_Date)
								set @ToChkNXtDate = DATEADD(D,@ShortLeave,@From_Date)
								SELECT @CntPreDate = @CntPreDate + count(1) FROM #temp12 WHERE From_Date = @ToChkPreDate and To_Date = @ToChkPreDate
								SELECT @CntNxtDate = @CntNxtDate + count(1) FROM #temp12 WHERE From_Date = @ToChkNXtDate and To_Date = @ToChkNXtDate
								
								if ((@CntPreDate + @CntNxtDate) >= @Leave_Max)
								BEGIN
										RAISERROR('@@Continuous Leave Is Not Allowed Beyond Max Limit@@',16,2)
										RETURN 
								END

								set @ShortLeave = @ShortLeave + 1
							END
					END
					--ELSE IF EXISTS(Select 1 from #temp12 Where Emp_ID = @Emp_Id and From_Date = @PreDate and To_Date = @PreDate ANd Leave_ID = @Leave_ID) Deepal Change the Query 18062024
					ELSE IF EXISTS(Select 1 from #temp12 Where Emp_ID = @Emp_Id and @PreDate BETWEEN From_Date and To_Date ANd Leave_ID = @Leave_ID)
					BEGIN
							print 2

							While @ShortLeave <= @Leave_Max
							Begin
									
									set @ToChkPreDate = DATEADD(D,-@ShortLeave,@From_Date)
									--Select @CntPreDate = @CntPreDate + count(1) from #temp12 where From_Date = @ToChkPreDate and To_Date = @ToChkPreDate -- Deepal Change The Query 18062024
									Select @CntPreDate = @CntPreDate + count(1) from #temp12 where  @ToChkPreDate  between From_Date and To_Date 
									IF @CNTPREDATE >= @LEAVE_MAX
									BEGIN
										RAISERROR('@@CONTINUOUS LEAVE IS NOT ALLOWED BEYOND MAX LIMIT@@',16,2)
										RETURN 
									END
									set @ShortLeave = @ShortLeave + 1
							END
					END
					--ELSE IF EXISTS(Select 1 from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
					--		on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
					--		and la.Emp_ID = @Emp_Id and LAD.From_Date = @NextDate and LAD.To_Date = @NextDate
					--		ANd LAD.Leave_ID = @Leave_ID)
					--ELSE IF EXISTS(Select 1 from #temp12 Where Emp_ID = @Emp_Id and From_Date = @NEXTDATE and To_Date = @NEXTDATE ANd Leave_ID = @Leave_ID) -- Deepal Change the Query 18062024
					ELSE IF EXISTS(Select 1 from #temp12 Where Emp_ID = @Emp_Id and @NEXTDATE BETWEEN From_Date and To_Date ANd Leave_ID = @Leave_ID)
					BEGin
						print 3
						While @ShortLeave <= @Leave_Max
							Begin
									set @ToChkNXtDate = DATEADD(D,@ShortLeave,@From_Date)
									
									--Select @CntNxtDate = @CntPreDate + count(1) from T0100_LEAVE_APPLICATION LA INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD 
									--on LA.Leave_Application_ID = LAD.Leave_Application_ID AND LAD.Leave_Assign_As = @Leave_Assign_As
									--and la.Emp_ID = @Emp_Id and LAD.From_Date = @ToChkNXtDate and LAD.To_Date = @ToChkNXtDate
									--ANd LAD.Leave_ID = @Leave_ID

									--Select @CntNxtDate = @CntNxtDate + count(1) from #temp12 where From_Date = @ToChkNXtDate and To_Date = @ToChkNXtDate -- Deepal Change the Query 18062024
									Select @CntNxtDate = @CntNxtDate + count(1) from #temp12 where @ToChkNXtDate BETWEEN From_Date and To_Date
									
									if @CntNxtDate >= @Leave_Max
									Begin
										RAISERROR('@@Continuous Leave Is Not Allowed Beyond Max Limit@@',16,2)
										RETURN 
									END
									set @ShortLeave = @ShortLeave + 1
							END
							
								--set @ShortLeave = 1
								--if @ShortLeave > @Leave_Max
								--Begin
								--	RAISERROR('@@Continuous Leave Is Not Allowed Beyond Max Limit@@',16,2)
								--	RETURN 
								--END
					END
					-- Comment by deepal discussed with sandip /Sajid the logic is not working properly so change the logic only for continuous.28122022
					--If (ISNULL(@Total_Leave_Days,0)+ @TEMP_LEAVE_PERIOD  > @Leave_Max and @Leave_Max > 0) --and @Apply_hourly=0  --Added by Sumit on 25102016 -- Commented by Hardik on 21/10/2019 as Max Limit not checking for Hourly leave, Client Name : Cliantha
					--BEGIN
					--			RAISERROR('@@Continuous Leave Is Not Allowed Beyond Max Limit@@',16,2)
					--			RETURN 
					--END					
					-- Comment by deepal discussed with sandip /Sajid the logic is not working properly so change the logic only for continuous.28122022
					ELSE IF @CHECK_FLAG = 0
						Begin
								
								set @Leave_Pre_Post = 2
								SET @COUNTER = (@Leave_Max - (convert(int,@TEMP_LEAVE_PERIOD))) + 1 --(4 - (2 + 1)) + 1 = 2 
								SET @INTERVAL = -1
													
							if IsNull(@Half_Leave_Date, '1900-01-01') <> '1900-01-01'
								Begin
									SET @TEMP_DATE = @From_Date
									SET	@CHECK_FLAG  = 1
								END
							ELSE
								Begin
									SET @TEMP_DATE = @tmpFrom_Date
									SET	@CHECK_FLAG  = 1
								END						
								
							----Salary Cycle allowed, and From date and TO date is two diiferent month
							IF @CHECK_FLAG = 1 AND @EFFECT_SALARY_CYCLE = 1 AND @MONTH_END_DATE between @FROM_DATE and @TO_DATE
							BEGIN
								GOTO BREAK_LOOP;
							END	
							
							GOTO LOOP
						END
					ELSE
						GOTO BREAK_LOOP
			END
BREAK_LOOP:			
		/******************************************************************
		**********VALIDATION FOR MONTHLY MAX LEAVE LIMIT*******************
		******************************************************************/
		--select @MONTHLY_MAX_LEAVE,@MONTH_ST_DATE,@MONTH_END_DATE
		BEGIN
				---Monthly Maximum Leave   --Added by Jaina 28-03-2017
				--select @MONTHLY_MAX_LEAVE AS MONTHLY_MAX_LEAVE
				
				DECLARE @TOTAL_APP_LEAVE NUMERIC(18,2) = 0
				DEclare @Schme_Leave numeric(18,2) = 0
				
				
				--Added by Jaina 08-04-2019
				if @EFFECT_SALARY_CYCLE = 0 and @CYCLE_STATUS = 0
				BEGIN
					
					 set @MONTH_ST_DATE = dbo.GET_MONTH_ST_DATE(MONTH(@From_date),year(@From_date))
					 set @MONTH_END_DATE = dbo.GET_MONTH_END_DATE(MONTH(@From_date),year(@From_date))
				end
				
				
				SET @TOTAL_APP_LEAVE = 0
				SET @Schme_Leave = 0
				
				IF @MONTHLY_MAX_LEAVE > 0
				BEGIN
					
					set @TOTAL_LEAVE = 0			
					SELECT @TOTAL_LEAVE = IsNull(SUM(LEAVE_USED),0 )+ isnull(sum(CompOff_Used),0) FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)  --Change by Jaina 22-02-2018
					WHERE CMP_ID=@CMP_ID AND FOR_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE 
						  AND EMP_ID = @EMP_ID AND (LEAVE_USED > 0 or CompOff_Used > 0  or Isnull(Back_Dated_Leave,0) > 0)and Leave_ID = @LEave_ID --Change by Jaina 22-02-2018
						
						
					--if exists (SELECT 1 FROM T0140_LEAVE_TRANSACTION 
					--WHERE CMP_ID=@CMP_ID AND FOR_DATE BETWEEN @From_Date AND @To_Date 
					--	  AND EMP_ID = @EMP_ID AND LEAVE_USED > 0 and Leave_ID = @LEave_ID)
					--BEGIN
					--	SELECT @Schme_Leave = IsNull(SUM(LEAVE_USED),0) 
					--	FROM T0140_LEAVE_TRANSACTION 
					--	WHERE CMP_ID=@CMP_ID AND FOR_DATE BETWEEN @From_Date AND @To_Date 
					--		  AND EMP_ID = @EMP_ID AND LEAVE_USED > 0 and Leave_ID = @LEave_ID
					--END
						    
								  
					--IF MONTH(@MONTH_ST_DATE) <> MONTH(@MONTH_END_DATE)  --If take leave on 26-03-2017 to 25-04-2017
					BEgin
						Declare @F_Date Datetime
						Declare @TDate datetime
						declare @Count_Period numeric(18,2) = 0
						declare @TEMP_DATE_MONTH datetime
						declare @L_Period numeric(18,2)
						declare @T_Leave_Period numeric(18,2)						
										
						--take leave Continuous Leave 24 to 26 3 day for get leave period between month start and end date
						select @F_Date = LAD.From_Date,@TDate =LAD.To_Date,@L_Period=IsNull(LAD.Leave_Period,0)
						FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN 
							  T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID = LAD.LEAVE_APPLICATION_ID
						WHERE LA.CMP_ID = @CMP_ID AND LA.EMP_ID = @EMP_ID  AND LA.APPLICATION_STATUS <> 'R'
							  and (@MONTH_ST_DATE between LAD.From_Date and LAD.To_Date or
							   @MONTH_END_DATE between LAD.From_Date AND LAD.To_Date)
							  AND MONTH(LAD.From_Date) <> MONTH(LAD.To_Date) --Added by Jaina 13-03-2018
							  AND LA.LEAVE_APPLICATION_ID <> @LEAVE_APPLICATION_ID
							  AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID AND LA.Application_Status='A')					  
							  and LAd.Leave_ID = @LEave_ID
						
												  
						--select @MONTH_ST_DATE,@MONTH_END_DATE
						SET @TEMP_DATE_MONTH = @F_Date 
						
ABC:  
						WHILE @TEMP_DATE_MONTH < @MONTH_ST_DATE
							BEGIN
								
								set @Count_Period +=1
								SET @TEMP_DATE_MONTH = DATEADD(D, 1, @TEMP_DATE_MONTH)
							
								Goto ABC;
								IF @MONTH_ST_DATE = @TEMP_DATE_MONTH
									break
							END
						
						set @T_Leave_Period = IsNull(@L_Period,0) - @Count_Period
						
						--select @T_Leave_Period T_Leave_Period
						--set @TOTAL_APP_LEAVE = @TOTAL_APP_LEAVE - @Count_Period	
						
						--select @LEAVE_APPLICATION_ID
						--select @MONTH_ST_DATE,@MONTH_END_DATE
						SELECT @TOTAL_APP_LEAVE = ISNULL(SUM(LAD.LEAVE_PERIOD),0) 
						FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN 
							  T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID = LAD.LEAVE_APPLICATION_ID
						WHERE LA.CMP_ID = @CMP_ID AND LA.EMP_ID = @EMP_ID  AND LA.APPLICATION_STATUS <> 'R'
							  AND (LAD.FROM_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE and
								   LAD.TO_DATE BETWEEN @MONTH_ST_DATE AND @MONTH_END_DATE)
							  AND LA.LEAVE_APPLICATION_ID <> @LEAVE_APPLICATION_ID
							  AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA1.Leave_Application_ID=LA.Leave_Application_ID AND LA.Application_Status='A')					  
							  and LAd.Leave_ID = @LEave_ID
							
						
						
						set @TOTAL_APP_LEAVE = @TOTAL_APP_LEAVE  +@T_Leave_Period
						
													  												
					END
					
					
					--take Leave Application / Leave Approval Case, seperate leave period (Eg: take leave 30-4-2017 to 1-05-2017 that time consider only 1 leave Count)
					--IF @MONTH_ST_DATE between @From_Date and @To_Date or
					--	@MONTH_END_DATE between @From_Date AND @To_Date
					----select @MONTH_END_DATE,@MONTH_ST_DATE
					--Begin
					--	set @Count_Period = 0
					--	set @TEMP_DATE_MONTH = @From_Date 
					--		PQR:  
					--		while @TEMP_DATE_MONTH <= @MONTH_ST_DATE
					--		begin
								
					--			set @Count_Period +=1
					--			SET @TEMP_DATE_MONTH = DATEADD(D, 1, @TEMP_DATE_MONTH)
							
					--			Goto PQR;
					--			IF @MONTH_ST_DATE = @TEMP_DATE_MONTH
					--				break
							
					--		END
					--	--set @LEAVE_PERIOD = @LEAVE_PERIOD - @Count_Period
					--	set @LEAVE_PERIOD = @Count_Period
						
					--	set @Count_Period = 0
					--	set @TEMP_DATE_MONTH = @From_Date  
					--	XYZ:
					--	while @TEMP_DATE_MONTH <= @MONTH_END_DATE
					--	begin
							
					--		SET @COUNT_PERIOD +=1
							
					--		IF @MONTH_END_DATE = @TEMP_DATE_MONTH
					--			break
								
					--		SET @TEMP_DATE_MONTH = DATEADD(D, 1, @TEMP_DATE_MONTH)
							
					--		Goto XYZ;
							
							
					--	END
					--	--select @COUNT_PERIOD
					--	--set @LEAVE_PERIOD = @LEAVE_PERIOD - @Count_Period
					--	set @LEAVE_PERIOD = @Count_Period
					--END
					
					
					IF (@MONTH_END_DATE BETWEEN @FROM_DATE AND @TO_DATE  -- If salary cycle 26-25
							OR (ABS(DATEDIFF(D, @MONTH_END_DATE, @FROM_DATE)) < 2 AND @LEAVE_PERIOD > 1)) 
					BEGIN
							delete from #Leave_Dates
							Insert INTO #Leave_Dates
							exec Calculate_Leave_End_Date @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Leave_Id=@Leave_ID,@From_Date=@From_Date,@Period=@Leave_Period,@Type='o',@M_Cancel_weekoff_holiday=0,@Leave_Assign_As=@Leave_Assign_As
					
							IF @CYCLE_STATUS = 1
							BEGIN
								select @PRE_TEMP_PERIOD = COUNT(*) from #Leave_Dates where L_Date between @MONTH_ST_DATE AND @MONTH_END_DATE
								select @POST_TEMP_PERIOD = COUNT(*) from #Leave_Dates where L_Date > @MONTH_END_DATE
							END
					END		
						
					IF @CYCLE_STATUS = 1
						SET @Count_Period = @PRE_TEMP_PERIOD
					ELSE
						SET @Count_Period = @POST_TEMP_PERIOD
					
					SET @LEAVE_PERIOD = @LEAVE_PERIOD - isnull(@Count_Period,0)
					SET @TOTAL_LEAVE = isnull(@TOTAL_LEAVE,0) + isnull(@TOTAL_APP_LEAVE,0) + @LEAVE_PERIOD 
					
					IF @MONTHLY_MAX_LEAVE < @TOTAL_LEAVE 
					BEGIN
						RAISERROR('@@Leave Is Not Allowed Beyond Monthly Max Limit@@',16,2)
						RETURN 
					END
				END
		END		
		
	
	/**********************************************************************/
    /*********** Call For 2 Cycle Loop If Effect Salary Cycle =1 **********/
    /* Take Leave 30-03-2017 to 01-04-2017  Leave Period = 3 **************/
    /* 1 Cycle Loop For 31-03-2017 Check Pre Date (29-03-2017,28-03-2017)**/
    /* 2 Cycle Loop For 01-04-2017 Check Post Date (02-04-2017,03-04-2017)*/
	/**********************************************************************/
	IF @EFFECT_SALARY_CYCLE = 1 AND @CYCLE_STATUS <> 2
		BEGIN
			
			IF @MONTH_END_DATE between @FROM_DATE and @TO_DATE
				BEGIN
					
					Set @tmpFrom_Date =  DATEADD(d,1,@MONTH_END_DATE)
					IF @To_Date = IsNull(@Half_Leave_Date, '1900-01-01')
						Set @tmpTo_Date =  @To_Date									
					ELSE
						Set @tmpTo_Date =  DATEADD(d,1,@To_Date)									
					SET @TEMP_LEAVE_PERIOD = @POST_TEMP_PERIOD
					
					SET @CYCLE_STATUS = 2
					
										
					GOTO SAL_CYCLE
				END
		END
		
		
	--Added by Jaina 13-03-2019 
	Declare @Message varchar(max) = ''
	--or @MPLeave_type = 'Paternity Leave'
	IF ((@MPLeave_type = 'Maternity Leave' ) and @Max_Leave_Lifetime <> 0)
	begin
		--SELECT	@Approval_Leave_Count = COUNT(1)
		--FROM	T0120_LEAVE_APPROVAL LA INNER JOIN 
		--		T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
		--WHERE	NOT EXISTS(
		--				SELECT 1 FROM T0150_LEAVE_CANCELLATION LC 
		--				WHERE LC.Leave_Approval_id=LA.Leave_Approval_ID AND lc.Is_Approve=1
		--				)
		--		AND LA.Emp_ID=@Emp_ID AND LAD.Leave_ID = @Leave_Id AND LA.Cmp_ID=@Cmp_ID and LA.Approval_Status = 'A'
		
		select @Approval_Leave_Count = COUNT(1) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
		where Emp_ID = @Emp_Id and Cmp_ID=@Cmp_Id and Leave_ID=@Leave_Id

		SELECT	@PENDING_LEAVE_COUNT = COUNT(1)
		FROM	T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN 
				T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID=LAD.Leave_Application_ID
		WHERE	LA.Emp_ID=@Emp_id and LA.Application_Status='P' AND LA.Cmp_ID=@Cmp_ID
				AND LAD.Leave_ID = @Leave_Id and LA.Leave_Application_ID <> @Leave_Application_ID
				
		

		IF (isnull(@PENDING_LEAVE_COUNT,0) + isnull(@Approval_Leave_Count,0)) < @Max_Leave_Lifetime
		BEGIN
			set @Message = '@@Maximum limit is over for Maternity leave Request@@'
			RAISERROR(@Message,16,2)	
			return
		END 
		
		
	end
	
END


