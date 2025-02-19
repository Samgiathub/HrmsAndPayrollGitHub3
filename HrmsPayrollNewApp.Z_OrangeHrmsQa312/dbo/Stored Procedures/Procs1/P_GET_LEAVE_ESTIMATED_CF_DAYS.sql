

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_LEAVE_ESTIMATED_CF_DAYS]
	@Cmp_ID		NUMERIC,
	@From_Date	DateTime = NULL,
	@To_Date	DateTime,
	@Leave_ID	NUMERIC
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #Data         
	(         
		Emp_Id   numeric ,         
		For_date datetime,        
		Duration_in_sec numeric,        
		Shift_ID numeric ,        
		Shift_Type numeric ,        
		Emp_OT  numeric ,        
		Emp_OT_min_Limit numeric,        
		Emp_OT_max_Limit numeric,        
		P_days  numeric(12,3) default 0,        
		OT_Sec  numeric default 0  ,
		In_Time datetime,
		Shift_Start_Time datetime,
		OT_Start_Time numeric default 0,
		Shift_Change tinyint default 0,
		Flag int default 0,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time datetime,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    

	
	IF OBJECT_ID('tempdb..#LEAVE_CF_DAYS') IS NULL
		CREATE TABLE #LEAVE_CF_DAYS
		(
			Emp_ID			NUMERIC,
			FROM_DATE		DATETIME,
			TO_DATE			DATETIME,
			Emp_Type_ID		NUMERIC,
			DateOfJoin		DATETIME,
			Grd_ID			NUMERIC,

			/*GENRATEL SETTINGS*/
			Sal_St_Date				DATETIME,
			Is_CF_On_Sal_Days		TINYINT,
			Days_As_Per_Sal_Days	TINYINT,

			/*CF DETAIL*/
			Month_St_Date			DATETIME,
			Month_End_Date			DATETIME,
			Leave_Closing			NUMERIC(9,2),
			Leave_CF_P_Days			NUMERIC(9,2),
			Leave_Again_Present_Day	NUMERIC(9,2),
			Leave_CF_Days			NUMERIC(9,2),
			Exceed_CF_Days			NUMERIC(9,2),
			Min_Present_Days_Per_Wise NUMERIC(9,2),

			/*Salary Detail*/
			Sal_Cal_Days			NUMERIC(9,2),
			P_Days					NUMERIC(9,2),
			WO_Days					NUMERIC(9,2),
			HO_Days					NUMERIC(9,2),
			L_Paid_Days				NUMERIC(9,2),
			Alternate_Weekoff		VARCHAR(50),
			Alternate_Weekoff_Days	NUMERIC(9,2)
		)

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #Emp_WeekOff
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #Emp_WeekOff(Emp_ID, For_Date)		
		END
	
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END

	CREATE TABLE #LEAVE_CF_DAYS_MONTHLY
	(
		Emp_ID			NUMERIC,
		FOR_DATE		DATETIME,
		Sal_Cal_Days	NUMERIC(9,2),
		P_Days			NUMERIC(9,2),
		WO_Days			NUMERIC(9,2),
		HO_Days			NUMERIC(9,2),
		L_Paid_Days		NUMERIC(9,2),
		Leave_CF_Days	NUMERIC(9,2),
		Leave_CF_P_Days			NUMERIC(9,2),
		Leave_Again_Present_Day	NUMERIC(9,2),
	)
	
	 Declare @Add_Alt_WO_Carry_Fwd TINYINT --- Added this setting for AIA client to add Alternate weekoff in Present Days Fix, by Hardik 07/01/2020
	 set @Add_Alt_WO_Carry_Fwd = 0
																			
	 if Object_ID('tempdb..#EmpWeekoffData') is not null
		Begin
			Drop TABLE #EmpWeekoffData
		End 
	 
	 Create Table #EmpWeekoffData
	 (
		Row_ID Numeric,
		W_Date Datetime,
		W_Name VARCHAR(20)
	 ) 

	INSERT	INTO #LEAVE_CF_DAYS(Emp_ID, FROM_DATE, TO_DATE, Sal_St_Date, Is_CF_On_Sal_Days, Days_As_Per_Sal_Days,Grd_ID,DateOfJoin,Emp_Type_ID)
	SELECT	EC.EMP_ID , @From_Date, @To_Date, Sal_St_Date,Is_CF_On_Sal_Days,Days_As_Per_Sal_Days,I.Grd_ID,Date_Of_Join,E.Type_ID
	FROM	#Emp_Cons EC
			INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON G.Branch_ID=EC.Branch_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID = E.Emp_ID
			INNER JOIN (SELECT	BRANCH_ID, MAX(For_Date) AS For_Date
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
						WHERE	For_Date <= @To_Date AND Cmp_ID=@Cmp_ID
						GROUP BY Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID AND G.For_Date=G1.For_Date
						
	
    
	DECLARE @Leave_Max_Bal				NUMERIC(9,2)
	DECLARE @Leave_CF_Type				VARCHAR(20)
	DECLARE @Leave_PDays				NUMERIC(9,2)
	DECLARE @Leave_Get_Against_PDays	NUMERIC(12,1)

	DECLARE @Leave_Precision			NUMERIC(2)
	DECLARE @Leave_CF_Days				NUMERIC(9,2)
	DECLARE @Max_Accumulate_Balance		NUMERIC(9,2)
	DECLARE @Min_Present_Days			NUMERIC(9,2)

	
	DECLARE @Is_Leave_CF_Rounding	TINYINT
	DECLARE @Is_Leave_CF_Prorata	TINYINT
	DECLARE @Effective_Date			DATETIME
	DECLARE @CF_Type_ID				NUMERIC

	DECLARE @Reset_Months			INT
	DECLARE @Duration				VARCHAR(15)
	DECLARE @CF_Months				NVARCHAR(50)
	DECLARE @Release_Month			NUMERIC(9,2)

	DECLARE @Reset_Month_String		VARCHAR(128)
	DECLARE @MinPdays_Type			TINYINT
	DECLARE @Default_Short_Name		VARCHAR(32)
	DECLARE @Trans_Leave_ID			INT
	DECLARE @Apply_Hourly			TINYINT

	DECLARE @tmpPeriod				NUMERIC
	DECLARE @For_Date				DATETIME

	DECLARE @Is_Advance_Leave_Balance		TINYINT
	DECLARE @Including_Leave_Type			VARCHAR(256)

	DECLARE @Type_ID		NUMERIC

	DECLARE @CF_Flag		TINYINT
	DECLARE @Inc_HOWO		TINYINT
	DECLARE @Inc_WeekOff	TINYINT
	DECLARE @Inc_Holiday	TINYINT

	DECLARE @Monthly_Max_CF_Limit Numeric(9,2)
	
	Declare @Can_Apply_Fraction tinyint
	SET @For_Date = @To_Date
	set @Can_Apply_Fraction=0

	DECLARE @TMP_FROM_DATE DATETIME
	DECLARE @TMP_TO_DATE DATETIME
	DECLARE @TMP_CONSTRAINT VARCHAR(MAX)
	
	DECLARE curLeave CURSOR FAST_FORWARD FOR
	SELECT	DISTINCT LM.Leave_Max_Bal,Leave_CF_Type,Leave_PDays,Leave_Get_Against_PDays,IsNull(Leave_Precision,0),
			LM.Max_Accumulate_Balance,Min_Present_Days,Is_Leave_CF_Rounding,Is_Leave_CF_Prorata,
			QRY.Effective_Date,CF.CF_Type_ID,CF.Reset_Months,CF.Duration,CF.CF_Months,CF.Release_Month,CF.Reset_Month_String,
			LM.MinPdays_Type,IsNull(LM.Default_Short_Name ,'') AS  Default_Short_Name,LM.Trans_Leave_ID,IsNull(LM.Apply_Hourly,0),
			Is_Advance_Leave_Balance,Is_Ho_Wo,Including_Leave_Type,Including_WeekOff,Including_Holiday,CF.Type_ID, Isnull(LM.Can_Apply_Fraction,0),Isnull(Add_Alt_WO_Carry_Fwd,0)
	FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
			INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
			INNER JOIN T0050_CF_EMP_TYPE_DETAIL CF WITH (NOLOCK) ON CF.Leave_ID=LM.Leave_ID
			INNER JOIN (SELECT	MAX(Effective_Date) AS Effective_Date,Leave_ID 
						FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
						WHERE	Leave_ID=@Leave_ID AND Effective_Date <= IsNull(@From_Date, @To_Date-1) 
						GROUP BY Leave_ID) QRY ON QRY.Leave_ID=CF.Leave_ID AND QRY.Effective_Date=CF.Effective_Date
	WHERE	LM.Leave_ID = @Leave_ID AND LeavE_Paid_Unpaid ='P' AND LM.Leave_CF_Type <> 'None'
			AND EXISTS(SELECT 1 FROM #LEAVE_CF_DAYS T WHERE T.Emp_Type_ID=CF.Type_ID AND T.Grd_ID=LD.Grd_ID)
	
	
	OPEN curLeave
	FETCH NEXT FROM curLeave INTO	@Leave_Max_Bal,@Leave_CF_Type,@Leave_PDays,@Leave_Get_Against_PDays,@Leave_Precision,@Max_Accumulate_Balance,
									@Min_Present_Days,@Is_Leave_CF_Rounding,@Is_Leave_CF_Prorata,@Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,
									@Release_Month,@Reset_Month_String,@MinPdays_Type,@Default_Short_Name,@Trans_Leave_ID,@Apply_Hourly,@Is_Advance_Leave_Balance,
									@Inc_HOWO,@Including_Leave_Type,@Inc_WeekOff,@Inc_Holiday,@Type_ID,@Can_Apply_Fraction,@Add_Alt_WO_Carry_Fwd
	WHILE @@FETCH_STATUS = 0
		BEGIN

			SELECT	@Including_Leave_Type = @Including_Leave_Type + '#' + CAST(LEAVE_ID AS VARCHAR(10))
			FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
			WHERE	(Leave_Type = 'Company Purpose' OR Default_Short_Name = 'COMP')
					AND Cmp_ID=@Cmp_ID 
					AND NOT EXISTS(Select 1 From dbo.Split(@Including_Leave_Type, '#') T Where T.Data <> '' AND Cast(T.Data As Numeric) = LM.Leave_ID)
			
			
			IF EXISTS(SELECT Min_Leave_CF FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Leave_ID = @Leave_ID)
				BEGIN					
					DECLARE @Min_Leave_CF_Temp AS NUMERIC(18,1)
					DECLARE @Max_Accumulate_Balance_Temp as numeric(18,1)

					SELECT  @Min_Leave_CF_Temp = Min_Leave_CF,
							@Max_Accumulate_Balance_Temp = Max_Accumulate_Balance
					FROM	T0050_LEAVE_DETAIL WITH (NOLOCK)
					WHERE	Leave_ID = @Leave_ID
									
					IF @Min_Leave_CF_Temp > 0
						SET @Leave_Max_Bal = @Min_Leave_CF_Temp
						
					IF @Max_Accumulate_Balance_Temp > 0
						SET @Max_Accumulate_Balance = @Max_Accumulate_Balance_Temp
				END
			---- Max Leave To Carry Forward	
			IF @Leave_Max_Bal IS NULL
				SET @Leave_Max_Bal = 0
						
			---- Get Start n End Date
			IF @Duration = 'Yearly'
				BEGIN
					SET @tmpPeriod = 11	
					SET @Monthly_Max_CF_Limit = @Leave_Max_Bal / 12
				end
			ELSE IF @Duration = 'Half Yearly'
				BEGIN
					SET @tmpPeriod = 5					
					SET @Monthly_Max_CF_Limit = @Leave_Max_Bal / 6
				end
			ELSE IF @Duration = 'Quarterly'
				BEGIN
					SET @tmpPeriod = 2
					SET @Monthly_Max_CF_Limit = @Leave_Max_Bal / 3
				end			

			
										
			IF @Duration = 'Yearly' or @Duration = 'Half Yearly' or @Duration = 'Quarterly'
				BEGIN
					--IF @Days_As_Per_Sal_Days = 0
						BEGIN
							UPDATE	LCF
							--SET		Month_End_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(month(@For_Date),year(@For_Date)))							
							SET		Month_End_Date = @To_Date
							FROM	#LEAVE_CF_DAYS LCF
							WHERE	Days_As_Per_Sal_Days = 0 AND Emp_Type_ID=@Type_ID
							
						end
					--ELSE
						BEGIN
							--IF @Sal_St_Date <> ''  AND day(@Sal_St_Date) > 1   
								BEGIN
									UPDATE	LCF
									--SET		Month_End_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(month(@For_Date),year(@For_Date)))
									SET		Month_End_Date = @To_Date
									FROM	#LEAVE_CF_DAYS LCF
									WHERE	Day(Cast(IsNull(Sal_St_Date,'1900-01-01') As DateTime)) > 1 AND Emp_Type_ID=@Type_ID AND Days_As_Per_Sal_Days <> 0

									UPDATE	LCF
									--SET		Month_End_Date = cast(cast(day(Sal_St_Date)-1 as VARCHAR(5)) + '-' + cast(datename(mm,Month_End_Date) as VARCHAR(10)) + '-' +  cast(year(Month_End_Date)as VARCHAR(10)) as smalldatetime)
									SET		Month_End_Date = @To_Date
									FROM	#LEAVE_CF_DAYS LCF
									WHERE	Day(Cast(IsNull(Sal_St_Date,'1900-01-01') As DateTime)) > 1 AND Emp_Type_ID=@Type_ID AND Days_As_Per_Sal_Days <> 0
								End
							--ELSE IF isnull(@Sal_St_Date,'') = '' or day(@Sal_St_Date) = 1
								BEGIN
									IF  @Is_Advance_Leave_Balance = 1 AND @CF_Type_ID = 2 
										BEGIN
											UPDATE	LCF
											--SET		Month_End_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(month(@For_Date),(year(@For_Date) + 1)))
											SET		Month_End_Date = @To_Date
											FROM	#LEAVE_CF_DAYS LCF
											WHERE	Day(Cast(IsNull(Sal_St_Date,'1900-01-01') As DateTime)) = 1 AND Emp_Type_ID=@Type_ID AND Days_As_Per_Sal_Days <> 0

										End
									--ELSE
										BEGIN
											UPDATE	LCF
											--SET		Month_End_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(month(@For_Date),year(@For_Date)))
											SET		Month_End_Date = @To_Date
											FROM	#LEAVE_CF_DAYS LCF
											WHERE	Day(Cast(IsNull(Sal_St_Date,'1900-01-01') As DateTime)) = 1 AND Emp_Type_ID=@Type_ID AND Days_As_Per_Sal_Days <> 0
										End
								END 
						END

					UPDATE	LCF
					SET		Month_St_Date = ISNULL(@From_Date, LCD.CF_TO_DATE + 1), --dbo.GET_MONTH_ST_DATE(month(DATEADD(m,-@tmpPeriod,Month_End_Date)),year((DATEADD(m,-@tmpPeriod,Month_End_Date))))								
							FROM_DATE = COALESCE(FROM_DATE,@From_Date, LCD.CF_TO_DATE + 1)
					FROM	#LEAVE_CF_DAYS LCF
							CROSS APPLY (SELECT MAX(CF_TO_DATE) CF_TO_DATE 
											FROM	T0100_LEAVE_CF_DETAIL LCD WITH (NOLOCK)
											WHERE	LCD.Emp_ID=LCF.Emp_ID 
													AND LCD.CF_To_Date <= LCF.Month_End_Date AND LCD.Leave_ID=@Leave_ID
													AND DATEPART(MM, ISNULL(@From_Date, LCD.CF_TO_DATE + 1)) = CAST(@CF_Months AS NUMERIC)
													) LCD
					WHERE	Emp_Type_ID=@Type_ID
							AND DATEDIFF(MM, ISNULL(@From_Date, LCD.CF_TO_DATE + 1), LCF.Month_End_Date) BETWEEN 1 AND 12							 
					
					
					SELECT	@For_Date=dbo.GET_MONTH_ST_DATE(Min(cast(items as numeric)),year(@For_Date)) FROM dbo.Split2(@CF_Months,'#') --WHERE items>=MONTH(@For_Date)
					
					UPDATE	LCF
					SET		Month_St_Date = CASE WHEN @For_Date > @To_Date THEN DATEADD(YYYY,-1, @FOR_DATE) ELSE @For_Date END
					FROM	#LEAVE_CF_DAYS LCF							
					WHERE	Emp_Type_ID=@Type_ID AND Month_St_Date IS NULL
					
					
					IF CHARINDEX(cast(month(@For_Date) as varchar),@CF_Months) > 0
						BEGIN	
							SET @CF_Flag = 1
						end
					--ELSE
					--	BEGIN
					--		raiserror('You Cannot Carry Forward In This Month.',16,2)
					--		return -1
					--	end							
				end	

				IF @CF_Type_ID = 1	/*Prorata*/
					UPDATE	LCF
					SET		Leave_CF_P_Days = IsNull(T.Present_Day,0),
							Leave_Again_Present_Day = IsNull(T.Leave_Again_Present_Day,0)
					FROM	#LEAVE_CF_DAYS LCF
							CROSS APPLY(SELECT	Present_Day,Leave_Again_Present_Day
										FROM	T0050_LEAVE_CF_Present_Day LCP WITH (NOLOCK)
												INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
															FROM	T0050_LEAVE_CF_Present_Day  WITH (NOLOCK)
															WHERE	Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID AND Type_ID = LCF.Emp_Type_ID AND Effective_Date <= LCF.Month_End_Date
															GROUP BY Leave_ID,Type_ID) QRY ON LCP.Effective_Date = QRY.Effective_Date AND LCP.Leave_ID = QRY.Leave_ID AND LCP.Type_ID = QRY.Type_ID
										WHERE	LCP.Cmp_ID = @Cmp_ID AND LCP.Leave_ID = @Leave_ID AND LCP.Type_ID = LCF.Emp_Type_ID AND LCP.Effective_Date <= LCF.Month_End_Date
										) T 
					WHERE	Emp_Type_ID=@Type_ID

				INSERT INTO #LEAVE_CF_DAYS_MONTHLY(Emp_ID, FOR_DATE,Sal_Cal_Days,P_Days,WO_Days,HO_Days,L_Paid_Days,Leave_CF_P_Days,Leave_Again_Present_Day,Leave_CF_Days)
				SELECT	LCD.Emp_ID, DATEADD(M, ROW_ID, LCD.Month_St_Date), 0,0,0,0,0,Leave_CF_P_Days,Leave_Again_Present_Day,0
				FROM	(SELECT	TOP 12 ROW_NUMBER() OVER(ORDER BY OBJECT_ID) -1 AS ROW_ID 
						 FROM	SYS.objects
						 ) T CROSS APPLY #LEAVE_CF_DAYS LCD 
				WHERE	DATEADD(M, ROW_ID, LCD.Month_St_Date) < LCD.Month_End_Date

				
				
			--IF @Default_Short_Name <> 'COMP'
				BEGIN
					---- Get Leave Balance ----
					UPDATE	LCF
					SET		LEAVE_CLOSING = IsNull(LT.Leave_Closing,0)
					FROM	#LEAVE_CF_DAYS LCF
							CROSS APPLY(SELECT	Leave_Closing
										FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
												INNER JOIN (SELECT	T1.Emp_ID,MAX(T1.FOR_DATE) AS FOR_DATE
															FROM	T0140_LEAVE_TRANSACTION T1 WITH (NOLOCK)
																	INNER JOIN #Emp_Cons EC ON T1.Emp_ID=EC.Emp_ID
															WHERE	T1.For_Date <= LCF.Month_End_Date AND T1.Leave_ID=@Leave_ID
															GROUP BY T1.Emp_ID) T1 ON T.Emp_ID=T1.Emp_ID AND T.For_Date=T1.FOR_DATE
										WHERE	T.EMP_ID=LCF.EMP_ID AND T.Leave_ID=@Leave_ID
										) LT 
					WHERE	 Emp_Type_ID=@Type_ID

					

					UPDATE	LCF
					SET		LEAVE_CLOSING = 0
					FROM	#LEAVE_CF_DAYS LCF
					WHERE	IsNull(LEAVE_CLOSING,0) = 0 AND Emp_Type_ID=@Type_ID

					--IF @CF_Flag = 1
						BEGIN
							
							IF @CF_Type_ID = 1 or @CF_Type_ID = 3
								BEGIN
									--IF @Is_CF_On_Sal_Days = 1
										BEGIN
											UPDATE	LCM
											SET		P_Days = IsNull(T.Present_Days,Q1.Present_Days) ,
													WO_Days = IsNull(T.Weekoff_Days,Q1.Weekoff_Days),
													HO_Days = IsNull(T.Holiday_Days,Q1.Holiday_Days),
													Sal_Cal_Days = IsNull(T.Sal_Cal_Days,0)
											FROM	#LEAVE_CF_DAYS_MONTHLY LCM													
													LEFT OUTER JOIN (	SELECT	Emp_ID, Month_St_Date, Month_End_Date,
																			SUM(Present_Days) As Present_Days, SUM(Weekoff_Days) As Weekoff_Days, 
																			SUM(Holiday_Days) As Holiday_Days, ISNULL(SUM(Sal_Cal_Days),0) As Sal_Cal_Days
																	FROM	T0200_MONTHLY_SALARY MS	WITH (NOLOCK)																
																	GROUP BY MS.Emp_ID,Month_St_Date, Month_End_Date
																) T ON T.Emp_ID=LCM.Emp_ID AND LCM.FOR_DATE BETWEEN T.Month_St_Date AND T.Month_End_Date													
													INNER JOIN #LEAVE_CF_DAYS LCF ON LCM.Emp_ID=LCF.Emp_ID
													LEFT OUTER JOIN (
																		SELECT  SUM(P_DAYS) Present_Days, SUM(W_DAYS) Weekoff_Days,SUM(H_DAYS) Holiday_Days,																				
																				EMP_ID,dbo.GET_MONTH_ST_DATE(Month(for_date),year(For_date)) as Month_St_Date,
																				dbo.GET_MONTH_END_DATE(Month(for_date),year(For_date))  as  Month_End_Date
																		FROM 	T0185_LOCKED_IN_OUT LA WITH (NOLOCK)
																		--WHERE 	FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE --Commented by Hardik 11/01/2021 As Opening Balance showing wrong due to @from_Date Null
																		GROUP BY EMP_ID,MONTH(FOR_DATE),YEAR(FOR_DATE)
																	)Q1 ON Q1.EMP_ID = LCM.EMP_ID AND LCM.FOR_DATE BETWEEN Q1.Month_St_Date AND Q1.Month_End_Date													
											WHERE	Emp_Type_ID=@Type_ID AND Is_CF_On_Sal_Days = 1	
																						
										
											UPDATE	LCF
											SET		P_Days = IsNull(T.Present_Days,0),
													WO_Days = IsNull(T.Weekoff_Days,0),
													HO_Days = IsNull(T.Holiday_Days,0),
													Sal_Cal_Days = IsNull(T.Sal_Cal_Days,0)
											FROM	#LEAVE_CF_DAYS LCF
													INNER JOIN (SELECT	EMP_ID, SUM(P_Days) As Present_Days,  SUM(WO_Days) As Weekoff_Days, 
																			SUM(HO_Days) As Holiday_Days, ISNULL(SUM(Sal_Cal_Days),0) As Sal_Cal_Days
																FROM	#LEAVE_CF_DAYS_MONTHLY
																GROUP BY EMP_ID) T ON LCF.Emp_ID=T.Emp_ID
											WHERE	 Emp_Type_ID=@Type_ID AND Is_CF_On_Sal_Days = 1	


											If Isnull(@Add_Alt_WO_Carry_Fwd,0) = 1 -- For AIA Client
												BEGIN

												--Upadte Flag of Alternate Week-off 
												UPDATE	CF
													SET Alternate_Weekoff = Isnull(Qry.Alternate_Weekoff,'')
												From #LEAVE_CF_DAYS CF
												Inner Join ( 
																Select Isnull(Alt_W_Name,'') as Alternate_Weekoff ,A.Emp_ID
																	From T0100_WEEKOFF_ADJ A WITH (NOLOCK)
																Inner Join(
																			Select Emp_ID,Max(For_Date) as Fdate 
																				From T0100_WEEKOFF_ADJ  WITH (NOLOCK)
																			Where For_Date <= @To_Date
																			GROUP By Emp_ID 
																		  ) As Qry ON A.Emp_ID = Qry.Emp_ID and A.For_Date = Qry.Fdate
																Where A.Alt_W_Name <> '' 
															) as Qry ON CF.Emp_ID = Qry.Emp_ID

													SET	@TMP_CONSTRAINT = NULL
													SELECT	@TMP_CONSTRAINT = COALESCE(@TMP_CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(5))
														FROM	#LEAVE_CF_DAYS
													WHERE	Month_St_Date=@TMP_FROM_DATE AND Month_End_Date=@TMP_TO_DATE AND Emp_Type_ID=@Type_ID AND Is_CF_On_Sal_Days = 1 
													and Alternate_Weekoff <> ''
											
											
													DECLARE curDays_Alternate CURSOR FAST_FORWARD FOR
													SELECT	DISTINCT Month_St_Date,Month_End_Date 
													FROM	#LEAVE_CF_DAYS
													WHERE	Is_CF_On_Sal_Days = 1 AND Emp_Type_ID=@Type_ID and Alternate_Weekoff <> ''
											
													OPEN curDays_Alternate
													FETCH NEXT FROM curDays_Alternate INTO @TMP_FROM_DATE, @TMP_TO_DATE
													WHILE @@FETCH_STATUS = 0
														BEGIN
															EXEC SP_GET_HW_ALL @CONSTRAINT=@TMP_CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@TMP_FROM_DATE, @TO_DATE=@TMP_TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
													
															UPDATE	LCF
															SET		Alternate_Weekoff_Days = Qry.Alt_Count
															FROM	#LEAVE_CF_DAYS LCF
																	INNER JOIN(
																				Select SUM(EW.W_Day) as Alt_Count,EW.Emp_ID 
																					From #Emp_WeekOff EW 
																				INNER JOIN  #LEAVE_CF_DAYS LCD ON EW.Emp_ID = LCD.Emp_ID AND Upper(EW.Weekoff_day) = Upper(LCD.Alternate_Weekoff)
																				GROUP By EW.Emp_ID
																			   ) as Qry ON LCF.Emp_ID = Qry.Emp_ID
													
															FETCH NEXT FROM curDays_Alternate INTO @TMP_FROM_DATE, @TMP_TO_DATE
														END
													CLOSE curDays_Alternate
													DEALLOCATE curDays_Alternate
												END																						
										END
									--ELSE
										BEGIN

											
											DECLARE curDays CURSOR FAST_FORWARD FOR
											SELECT	DISTINCT Month_St_Date,Month_End_Date 
											FROM	#LEAVE_CF_DAYS
											WHERE	Is_CF_On_Sal_Days = 0 AND Emp_Type_ID=@Type_ID

											OPEN curDays
											FETCH NEXT FROM curDays INTO @TMP_FROM_DATE, @TMP_TO_DATE
											WHILE @@FETCH_STATUS = 0
												BEGIN
													SET	@TMP_CONSTRAINT = NULL
													SELECT	@TMP_CONSTRAINT = COALESCE(@TMP_CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(5))
													FROM	#LEAVE_CF_DAYS
													WHERE	Month_St_Date=@TMP_FROM_DATE AND Month_End_Date=@TMP_TO_DATE AND Emp_Type_ID=@Type_ID AND Is_CF_On_Sal_Days = 0

													TRUNCATE TABLE #DATA

													TRUNCATE TABLE #EMP_WEEKOFF
													TRUNCATE TABLE #EMP_HOLIDAY
													
													PRINT  @TMP_CONSTRAINT
													Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@TMP_FROM_DATE,@TMP_TO_DATE,0,0,0,0,0,0,0,@TMP_CONSTRAINT,4  
													
													UPDATE	LCF
													SET		P_Days = IsNull(T.P_Days,0)
													FROM	#LEAVE_CF_DAYS LCF
															INNER JOIN (	SELECT	Emp_ID, Sum(P_Days) As P_Days
																			FROM	#DATA D																			
																			GROUP BY D.Emp_ID
																		) T ON LCF.Emp_ID=T.Emp_ID

													UPDATE	LCF
													SET		WO_Days = IsNull(T.W_Days,0)
													FROM	#LEAVE_CF_DAYS LCF
															INNER JOIN (	SELECT	Emp_ID, Sum(W_Day) As W_Days
																			FROM	#EMP_WEEKOFF W																		
																			GROUP BY W.Emp_ID
																		) T ON LCF.Emp_ID=T.Emp_ID

													UPDATE	LCF
													SET		HO_Days = IsNull(T.H_Days,0)
													FROM	#LEAVE_CF_DAYS LCF
															INNER JOIN (	SELECT	Emp_ID, Sum(H_Day) As H_Days
																			FROM	#EMP_HOLIDAY H																	
																			GROUP BY H.Emp_ID
																		) T ON LCF.Emp_ID=T.Emp_ID

													FETCH NEXT FROM curDays INTO @TMP_FROM_DATE, @TMP_TO_DATE
												END
											CLOSE curDays
											DEALLOCATE curDays
													
												
										END										
										---- End ----
								END	

							UPDATE #LEAVE_CF_DAYS
							SET		P_Days = ISNULL(P_DAYS,0),
									WO_Days = ISNULL(WO_Days,0),
									HO_Days = ISNULL(HO_Days,0),
									Sal_Cal_Days = ISNULL(Sal_Cal_Days,0)
							WHERE	Emp_Type_ID=@Type_ID
								
													
							--SET @C_Paid_Days = 0
							
							
													 
							IF @Inc_HOWO = 1 
								BEGIN
									
									IF @Including_Leave_Type IS NOT NULL --'' IF Including leave Checkbox is selected but Leave Type details are not Selected 
										BEGIN
											UPDATE	LCM
											SET		L_Paid_Days = IsNull(LT.Leave_Used,0) * (CASE WHEN @Apply_Hourly = 1 THEN 0.125 ELSE 1 END)
											FROM	#LEAVE_CF_DAYS_MONTHLY LCM
													INNER JOIN (SELECT	LT.EMP_ID,DATEADD(D, (DAY(LT.FOR_DATE)-1) * -1, LT.FOR_DATE) AS FOR_DATE,
																		SUM((CASE WHEN LM.Default_short_Name = 'COMP' THEN LT.CompOff_Used ELSE LT.Leave_Used END) + IsNull(Leave_Adj_L_Mark,0)) As Leave_Used
																FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
																		INNER JOIN #LEAVE_CF_DAYS LCF ON LT.Emp_ID=LCF.EMP_ID AND LT.FOR_DATE BETWEEN LCF.Month_St_Date AND LCF.Month_End_Date
																WHERE	LM.Leave_Paid_Unpaid = 'P'
																		AND EXISTS(SELECT 1 FROM dbo.Split(@Including_Leave_Type, '#') T Where Cast(T.Data As Numeric) = LT.Leave_ID)
																		AND Emp_Type_ID=@Type_ID
																		AND CASE WHEN (LM.Default_short_Name = 'COMP' OR LM.Leave_Type = 'Company Purpose') AND For_Date > '2017-02-28' THEN 0 ELSE 1 END  = 1
																GROUP BY LT.EMP_ID,DATEADD(D, (DAY(LT.FOR_DATE)-1) * -1, LT.FOR_DATE)
																) LT ON LCM.Emp_ID=LT.Emp_ID AND LCM.FOR_DATE=LT.FOR_DATE
											

											UPDATE	LCF
											SET		L_Paid_Days = LCM.L_Paid_Days -- IsNull(LT.Leave_Used,0) * (CASE WHEN @Apply_Hourly = 1 THEN 0.125 ELSE 1 END)
											FROM	#LEAVE_CF_DAYS LCF
													INNER JOIN (SELECT	EMP_ID, SUM(L_Paid_Days) AS L_Paid_Days 
																FROM	#LEAVE_CF_DAYS_MONTHLY 
																GROUP	BY Emp_ID) LCM ON LCF.Emp_ID=LCM.Emp_ID
													--CROSS APPLY (SELECT	SUM((CASE WHEN LM.Default_short_Name = 'COMP' THEN LT.CompOff_Used ELSE LT.Leave_Used END) + IsNull(Leave_Adj_L_Mark,0)) As Leave_Used
													--			FROM	T0140_LEAVE_TRANSACTION LT
													--					INNER JOIN T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID
													--			WHERE	LT.For_Date BETWEEN LCF.Month_St_Date AND LCF.Month_End_Date AND LT.Emp_ID=LCF.Emp_ID																
													--					AND LM.Leave_Paid_Unpaid = 'P'
													--					AND EXISTS(SELECT 1 FROM dbo.Split(@Including_Leave_Type, '#') T Where Cast(T.Data As Numeric) = LT.Leave_ID)
													--			) LT
											WHERE	Emp_Type_ID=@Type_ID
											
							
										End 
								End
							
							UPDATE	#LEAVE_CF_DAYS
							SET		L_Paid_Days = 0
							WHERE	L_Paid_Days IS NULL AND Emp_Type_ID=@Type_ID
														
							--Added by nilesh patel on 28032015 --Start

								BEGIN
									UPDATE	LCF
									SET		P_Days =	IsNull(P_Days,0) + IsNull(Alternate_Weekoff_Days,0)
														+ Case WHEN @Inc_WeekOff = 1 THEN IsNull(WO_Days,0) ELSE 0 END 
														+ Case WHEN @Inc_Holiday = 1 THEN IsNull(HO_Days,0) ELSE 0 END 
														+ Case WHEN @Inc_HOWO = 1 THEN IsNull(L_Paid_Days,0) ELSE 0 END
									FROM	#LEAVE_CF_DAYS LCF
									WHERE	Emp_Type_ID=@Type_ID

									

									UPDATE	LCM
									SET		P_Days =	IsNull(LCM.P_Days,0) + IsNull(Alternate_Weekoff_Days,0)
														+ Case WHEN @Inc_WeekOff = 1 THEN IsNull(LCM.WO_Days,0) ELSE 0 END 
														+ Case WHEN @Inc_Holiday = 1 THEN IsNull(LCM.HO_Days,0) ELSE 0 END 
														+ Case WHEN @Inc_HOWO = 1 THEN IsNull(LCM.L_Paid_Days,0) ELSE 0 END
									FROM	#LEAVE_CF_DAYS_MONTHLY LCM
											INNER JOIN #LEAVE_CF_DAYS LCF ON LCM.EMP_ID=LCF.Emp_ID
									WHERE	Emp_Type_ID=@Type_ID
								END
								---- End ----						
											
							---- Carry Forward Type	
							
							IF @CF_Type_ID = 1	---- Prorata
								BEGIN									
			  							BEGIN
											
											--UPDATE	LCM
											--SET		Leave_CF_Days = LCM.P_Days * IsNull(LCM.Leave_Again_Present_Day,0) / LCM.Leave_CF_P_Days
											--FROM	#LEAVE_CF_DAYS_MONTHLY LCM
											--		INNER JOIN #LEAVE_CF_DAYS LCF ON LCM.Emp_ID=LCF.Emp_ID 
											--WHERE	LCM.Leave_CF_P_Days > 0 AND LCM.Leave_Again_Present_Day > 0 AND Emp_Type_ID=@Type_ID

											--IF @Monthly_Max_CF_Limit > 0 AND @Duration IN ('Yearly')
											--	BEGIN 
											--		UPDATE	LCM
											--		SET		Leave_CF_Days = CASE WHEN Leave_CF_Days > @Monthly_Max_CF_Limit THEN @Monthly_Max_CF_Limit ELSE Leave_CF_Days END
											--		FROM	#LEAVE_CF_DAYS_MONTHLY LCM
											--	END
											
											--UPDATE	LCF
											--SET		Leave_CF_Days = T.Leave_CF_Days
											--FROM	#LEAVE_CF_DAYS LCF
											--		INNER JOIN (SELECT	Emp_ID, Sum(Leave_CF_Days) As Leave_CF_Days 
											--					FROM	#LEAVE_CF_DAYS_MONTHLY GROUP BY Emp_ID) T ON LCF.Emp_ID=T.Emp_ID

											UPDATE	LCF
											SET		Leave_CF_Days = P_Days * isnull(Leave_Again_Present_Day,0) / Leave_CF_P_Days
											FROM	#LEAVE_CF_DAYS LCF
											WHERE	Leave_CF_P_Days > 0 AND Leave_Again_Present_Day > 0 AND Emp_Type_ID=@Type_ID
										

											IF @is_leave_CF_Rounding = 1
												UPDATE	LCF
												SET		Leave_CF_Days = Round(Leave_CF_Days,0)
												FROM	#LEAVE_CF_DAYS LCF
												WHERE	Leave_CF_P_Days > 0 AND Leave_Again_Present_Day > 0 AND Emp_Type_ID=@Type_ID
			  							
										END	
								END
							ELSE IF @CF_Type_ID = 2		---- Monthly Fix
								BEGIN
									--IF Exists(SELECT Leave_ID FROM T0050_LEAVE_CF_MONTHLY_SETTING WHERE Leave_ID=@Leave_ID AND Month(For_Date)=Month(Month_End_Date) AND CF_M_Days <> 0)  
										BEGIN  
											UPDATE	LCF
											SET		Leave_CF_Days = IsNull(T.CF_M_Days,0)
											FROM	#LEAVE_CF_DAYS LCF
													CROSS APPLY(SELECT	CF_M_Days
																FROM	T0050_LEAVE_CF_MONTHLY_SETTING CF WITH (NOLOCK)
																		INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																					FROM	T0050_LEAVE_CF_MONTHLY_SETTING  WITH (NOLOCK)
																					WHERE	Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID AND Type_ID = LCF.Emp_Type_ID AND Month(For_Date)= Month(Month_End_Date) AND Effective_Date <= LCF.Month_End_Date
																					GROUP BY Leave_ID,Type_ID
																					) QRY ON CF.Effective_Date = QRY.Effective_Date AND CF.Leave_ID = QRY.Leave_ID AND CF.Type_ID = QRY.Type_ID
																WHERE	CF.Cmp_ID = @Cmp_ID AND CF.Leave_ID = @Leave_ID AND CF.Type_ID = LCF.Emp_Type_ID AND CF.Effective_Date <= LCF.Month_End_Date																		
																) T 
											WHERE	EXISTS(SELECT 1 FROM T0050_LEAVE_CF_MONTHLY_SETTING S WITH (NOLOCK) WHERE S.Leave_ID=@Leave_ID AND Month(S.For_Date)=Month(LCF.Month_End_Date) AND CF_M_Days <> 0)
													 AND Emp_Type_ID=@Type_ID

										END
								END	
							ELSE IF @CF_Type_ID = 3		---- Slab
								BEGIN
									UPDATE	LCF
									SET		Leave_CF_Days = IsNull(T.CF_Days,0)
									FROM	#LEAVE_CF_DAYS LCF
											CROSS APPLY(SELECT	CF_Days
														FROM	T0050_LEAVE_CF_SLAB CF WITH (NOLOCK)
																INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																			FROM	T0050_LEAVE_CF_SLAB  WITH (NOLOCK)
																			WHERE	Cmp_ID = @Cmp_ID AND Leave_ID = @Leave_ID AND Type_ID = LCF.Emp_Type_ID AND Effective_Date <= LCF.Month_End_Date
																			GROUP BY Leave_ID,Type_ID
																			) QRY ON CF.Effective_Date = QRY.Effective_Date AND CF.Leave_ID = QRY.Leave_ID AND CF.Type_ID = QRY.Type_ID
														WHERE	CF.Cmp_ID = @Cmp_ID AND CF.Leave_ID = @Leave_ID AND CF.Type_ID = LCF.Emp_Type_ID AND CF.Effective_Date <= LCF.Month_End_Date
																AND CF.From_Days <= LCF.P_Days AND CF.To_Days >= LCF.P_Days
														) T 
									WHERE	Emp_Type_ID=@Type_ID
								end
							ELSE IF @CF_Type_ID = 4		---- Flat
								BEGIN
									UPDATE	LCF
									SET		Leave_CF_Days = IsNull(DATEDIFF(D, DATEDIFF(DD,-1 ,DateOfJoin), Month_End_Date),0) * (IsNull(LD.Leave_Days,0)/ DATEDIFF(d,Month_St_Date,Month_End_Date))
									FROM	#LEAVE_CF_DAYS LCF
											INNER JOIN T0050_LEAVE_DETAIL LD ON LD.Leave_ID=@Leave_ID AND LCF.Grd_ID=LD.Grd_ID
									WHERE	DateOfJoin > Month_St_Date AND @is_leave_CF_Prorata = 1 AND Emp_Type_ID=@Type_ID

									UPDATE	LCF
									SET		Leave_CF_Days = IsNull(LD.Leave_Days,0)
									FROM	#LEAVE_CF_DAYS LCF
											INNER JOIN T0050_LEAVE_DETAIL LD ON LD.Leave_ID=@Leave_ID AND LCF.Grd_ID=LD.Grd_ID
									WHERE	NOT (DateOfJoin > Month_St_Date AND @is_leave_CF_Prorata = 1) AND Emp_Type_ID=@Type_ID
									
									IF @is_leave_CF_Rounding = 1
										UPDATE	LCF
										SET		Leave_CF_Days = ROUND(Leave_CF_Days,0)
										FROM	#LEAVE_CF_DAYS LCF
										WHERE	Emp_Type_ID=@Type_ID									
								END	
																	
							
							
							IF @Leave_Max_Bal > 0
								BEGIN 
									IF @Duration = 'Yearly'
										BEGIN

											--UPDATE	LCF
											--SET		Leave_CF_Days =Leave_CF_Days-- (@Leave_Max_Bal / 12) *	MONTH_DIFF --Leave_CF_Days -- --DISABLE UPDATE
											--FROM	#LEAVE_CF_DAYS LCF
											--		INNER JOIN (SELECT	EMP_ID, CASE WHEN DATEDIFF(M,Month_St_Date, Month_End_Date)+1 > 12 THEN 12 ELSE DATEDIFF(M,Month_St_Date, Month_End_Date)+1 END AS MONTH_DIFF
											--					FROM	#LEAVE_CF_DAYS LCF1
											--					) LCF1 ON LCF.Emp_ID=LCF1.EMP_ID
											--WHERE	Emp_Type_ID=@Type_ID
											--		AND (IsNull(Leave_CF_Days,0) / MONTH_DIFF)  > (@Leave_Max_Bal / 12)
											--		AND MONTH_DIFF > 0



											UPDATE	LCF
											SET		Leave_CF_Days =Round((@Leave_Max_Bal / 12) *	MONTH_DIFF,0)
											FROM	#LEAVE_CF_DAYS LCF
													INNER JOIN (SELECT	EMP_ID, Count(FOR_DATE) AS MONTH_DIFF
																FROM	#LEAVE_CF_DAYS_MONTHLY LCF1
																Group by Emp_Id
																) LCF1 ON LCF.Emp_ID=LCF1.EMP_ID
											WHERE	Emp_Type_ID=@Type_ID
													AND Round((@Leave_Max_Bal / 12) *	MONTH_DIFF,0)  < Leave_CF_Days
													AND MONTH_DIFF > 0											
										END
									ELSE 
										UPDATE	#LEAVE_CF_DAYS
										SET		Leave_CF_Days = @Leave_Max_Bal
										WHERE	IsNull(Leave_CF_Days,0) > @Leave_Max_Bal AND Emp_Type_ID=@Type_ID
								END

							UPDATE	LCF
							SET		Leave_CF_Days = Case when @Can_Apply_Fraction=1 then Leave_CF_Days else Round(Leave_CF_Days,0) End --Nimesh: As per discussed with U.R.Shah they required 0.5 based rounding so, I have replaced the CEILING() function with Round(Value,0)
							FROM	#LEAVE_CF_DAYS LCF

							IF @Max_Accumulate_Balance > 0
								UPDATE	LCF
								SET		Exceed_CF_Days = IsNull(Leave_Closing,0) + Leave_CF_Days - IsNull(@Max_Accumulate_Balance,0),
										Leave_CF_Days = IsNull(@Max_Accumulate_Balance,0) - IsNull(Leave_Closing,0)											
								FROM	#LEAVE_CF_DAYS LCF
								WHERE	(IsNull(Leave_Closing,0) + Leave_CF_Days) > isnull(@Max_Accumulate_Balance,0) AND Emp_Type_ID=@Type_ID
							ELSE
								UPDATE	LCF
								SET		Exceed_CF_Days = 0
								FROM	#LEAVE_CF_DAYS LCF
								WHERE	(IsNull(Leave_Closing,0) + Leave_CF_Days) > isnull(@Max_Accumulate_Balance,0) AND Emp_Type_ID=@Type_ID
									

							IF @Is_Advance_Leave_Balance <> 1	--Alpesh 17-Aug-2012
								UPDATE	#LEAVE_CF_DAYS SET Leave_CF_Days = 0 WHERE Leave_CF_Days < 0 AND Emp_Type_ID=@Type_ID
												

							UPDATE	#LEAVE_CF_DAYS
							SET		Min_Present_days_per_wise = 0
							WHERE	Emp_Type_ID=@Type_ID

							IF isnull(@Min_Present_Days,0) > 0
								BEGIN
									IF @MinPDays_Type = 1  -- Added by Gadriwala Muslim 10022015(Minimum Present Day Percentage Wise Calculate) 
										BEGIN
											UPDATE	#LEAVE_CF_DAYS
											SET		Min_Present_days_per_wise = (DATEDIFF(D, CASE WHEN DateOfJoin > Month_St_Date THEN DateOfJoin ELSE Month_St_Date END , Month_End_Date) + 1) 
											WHERE	Emp_Type_ID=@Type_ID
											
											UPDATE	#LEAVE_CF_DAYS
											SET		Min_Present_days_per_wise = Min_Present_days_per_wise - (WO_Days + HO_Days)
											WHERE	Emp_Type_ID=@Type_ID
											
											UPDATE	#LEAVE_CF_DAYS
											SET		Min_Present_days_per_wise = Min_Present_days_per_wise * @Min_Present_Days / 100
											WHERE	Emp_Type_ID=@Type_ID

										END									
								END							
						END
			End
			FETCH NEXT FROM curLeave INTO	@Leave_Max_Bal,@Leave_CF_Type,@Leave_PDays,@Leave_Get_Against_PDays,@Leave_Precision,@Max_Accumulate_Balance,
									@Min_Present_Days,@Is_Leave_CF_Rounding,@Is_Leave_CF_Prorata,@Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,
									@Release_Month,@Reset_Month_String,@MinPdays_Type,@Default_Short_Name,@Trans_Leave_ID,@Apply_Hourly,@Is_Advance_Leave_Balance,
									@Inc_HOWO,@Including_Leave_Type,@Inc_WeekOff,@Inc_Holiday,@Type_ID,@Can_Apply_Fraction,@Add_Alt_WO_Carry_Fwd
		END
	CLOSE curLeave
	DEALLOCATE curLeave

	

