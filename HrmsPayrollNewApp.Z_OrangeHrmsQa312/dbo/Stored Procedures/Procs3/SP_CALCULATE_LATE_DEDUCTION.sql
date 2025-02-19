
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_LATE_DEDUCTION] @emp_Id NUMERIC
	,@Cmp_ID NUMERIC
	,@Month_St_Date DATETIME
	,@Month_End_Date DATETIME
	,@Late_Sal_Dedu_Days NUMERIC(18, 1) OUTPUT
	,@Late_Sal_Dedu_Days_cutoff NUMERIC(18, 1) OUTPUT -- added by tejas at 17092024
	,@Total_LMark INT OUTPUT
	,@Total_Late_Sec NUMERIC OUTPUT
	,@Increment_ID NUMERIC
	,@StrWeekoff_Date VARCHAR(max) = '' -- Added by Hardik 10/09/2012
	,@StrHoliday_Date VARCHAR(max) = '' -- Added by Hardik 10/09/2012
	,@Return_Record_Set NUMERIC = 0
	,@var_Return_Late_Date VARCHAR(max) = '' OUTPUT
	,@Return_Late_Date_Table TINYINT = 0
	,@Absent_Date_String VARCHAR(max) = '' -- Added by Gadriwala Muslim 25062015
	,@Temp_Extra_Count NUMERIC(18, 0) = 0 OUTPUT --For Extra Exemption in Late/Earlly Panalaty Days  --Ankit 29102015
	--,@total_count_all_incremnet NUMERIC(18,0) = 1 -- Mid Increment Case Late Count is not Properly For Gallpos 13092018  commented By Jimit 07112019
	,@total_count_all_incremnet NUMERIC(18, 0) = 0 -- Added By Jimit 07112019
	,@Mid_Inc_Late_Mark_Count NUMERIC(18, 0) = 0
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @In_Date DATETIME
DECLARE @Shift_St_Time VARCHAR(10)
DECLARE @Shift_St_DATETIME DATETIME
DECLARE @Curr_Month_LMark NUMERIC(18, 1)
DECLARE @Curr_Month_LMark_WithOut_Exemption NUMERIC(18, 1)
DECLARE @LMark_BF NUMERIC(18, 1)
DECLARE @var_Shift_St_Date VARCHAR(20)
DECLARE @numWorkingHoliday NUMERIC(18, 1)
DECLARE @varWeekOff_Date VARCHAR(500)
DECLARE @dtAdjDate DATETIME
DECLARE @TempFor_Date SMALLDATETIME
DECLARE @WeekOff VARCHAR(20)
DECLARE @dtHoliday_Date DATETIME
DECLARE @varHoliday_Date VARCHAR(100)
DECLARE @Emp_Late_Limit VARCHAR(10)
DECLARE @Late_Limit_Sec NUMERIC
DECLARE @Late_Adj_Day INT
DECLARE @Branch_ID NUMERIC
DECLARE @Emp_Late_Mark INT
DECLARE @Late_Dedu_Days NUMERIC(5, 1)
DECLARE @Late_Dedu_Type VARCHAR(10)
DECLARE @numPresentDays NUMERIC(12, 1)
DECLARE @month NUMERIC
DECLARE @varMonth VARCHAR(10)
DECLARE @Late_With_leave NUMERIC(1, 0)
DECLARE @Year NUMERIC
DECLARE @Is_Late_CF NUMERIC
DECLARE @Late_CF_Reset_On VARCHAR(50)
DECLARE @Shift_St_Time_Half_Day VARCHAR(10)
DECLARE @is_Half_Day TINYINT
DECLARE @Late_Exempted_Days NUMERIC(5, 2) --Alpesh 07-Oct-2011
DECLARE @RoundingValue NUMERIC(18, 2) -- added by mitesh on 08/11/2011
DECLARE @Is_Late_calc_On_HO_WO TINYINT
DECLARE @Temp_Branch_ID NUMERIC
DECLARE @Is_LateMark TINYINT
DECLARE @Late_Exempted_limit VARCHAR(10) -- added by mitesh on 24/01/2012
DECLARE @Late_Exempted_limit_sec NUMERIC -- added by mitesh on 24/01/2012
DECLARE @Shift_Exemption_St_DATETIME DATETIME -- added by mitesh on 24/01/2012
	--Alpesh 18-Jul-2012
DECLARE @Max_Late_Limit VARCHAR(50)
DECLARE @Shift_Max_Late_Time DATETIME
DECLARE @Out_Date DATETIME
DECLARE @Shift_End_Time VARCHAR(10)
DECLARE @var_Shift_End_Date VARCHAR(20)
DECLARE @Shift_End_Time_Half_Day VARCHAR(10)
DECLARE @Cutoff_date AS DATETIME
DECLARE @cutoff_month_st_date AS DATETIME
DECLARE @LMark_After_Cutoff NUMERIC(18, 2)
--- End ---
----Extra Exemption --Ankit 03112015
DECLARE @Shift_Time_Sec NUMERIC(18, 0)
DECLARE @Working_Time_Sec NUMERIC(18, 0)
DECLARE @Extra_exemption_limit VARCHAR(10)
DECLARE @Extra_Count_Exemption NUMERIC(18, 2)
DECLARE @Extra_Exemption NUMERIC(18, 0)
DECLARE @Shift_Exemption_St_MAX_DATETIME DATETIME

SET @Temp_Extra_Count = 0
SET @Extra_Exemption = 0
SET @Shift_Time_Sec = 0
SET @Working_Time_Sec = 0
SET @Extra_Count_Exemption = 0
SET @Extra_exemption_limit = 0
----Extra Exemption
SET @Curr_Month_LMark = 0
SET @Curr_Month_LMark_WithOut_Exemption = 0
SET @numWorkingHoliday = 0
SET @varWeekOff_Date = ''
SET @varHoliday_Date = ''
SET @LMark_BF = 0
SET @Late_Dedu_Days = 0
SET @Total_Late_Sec = 0
SET @Month = Month(@Month_st_Date)
SET @varMonth = @Month
SET @varMonth = '#' + @varMonth + '#'
SET @RoundingValue = 0

set @LMark_After_Cutoff = 0
SELECT @cutoff_month_st_date = DATEADD(month, DATEDIFF(month, 0, @Month_End_Date), 0)

SELECT @Cutoff_date = cutoff_date
FROM T0200_MONTHLY_SALARY
WHERE MONTH(Month_End_Date) = month(dateadd(m, - 1, @Month_End_Date))
	AND year(Month_End_Date) = Year(dateadd(m, - 1, @Month_End_Date))
	AND Emp_ID = @Emp_Id
	AND cutoff_date <> Month_End_Date

SET @Year = Year(@Month_st_Date)
SET @var_Return_Late_Date = ''
SET @Is_Late_calc_On_HO_WO = 0
SET @Is_LateMark = 0

-- Added by nilesh on  03-Feb-2018 Add For GrindMaster -- Wrong Branch consider in case of tansfer branch
SELECT TOP 1 @Increment_ID = Increment_ID
FROM T0095_INCREMENT WITH (NOLOCK)
WHERE Increment_Effective_Date <= @Month_End_Date
	AND Emp_ID = @Emp_ID
	AND Cmp_ID = @Cmp_ID
ORDER BY Increment_Effective_Date DESC

SELECT @Emp_Late_Mark = isnull(Emp_Late_Mark, 0)
	,@Emp_Late_Limit = ISNULL(Emp_Late_Limit, '00:00')
	,@Branch_ID = Branch_ID
	,@Late_Dedu_Type = Late_Dedu_Type
FROM T0095_Increment I WITH (NOLOCK)
WHERE I.Emp_ID = @emp_ID
	AND Increment_Id = @Increment_ID

CREATE TABLE #Absent_Dates -- Added by Gadriwala Muslim 25062015 - Start
	(Absent_date DATETIME)

IF @Absent_Date_String <> ''
BEGIN
	INSERT INTO #Absent_Dates (Absent_date)
	SELECT data
	FROM dbo.Split(@Absent_Date_String, '#')
END

SELECT @Late_Adj_Day = isnull(Late_Adj_Day, 0)
	,@Late_Dedu_Days = isnull(Late_Deduction_Days, 0)
	,@Late_CF_Reset_On = isnull(Late_CF_Reset_On, '')
	,@Is_Late_CF = isnull(Is_Late_CF, 0)
	,@Late_With_leave = Late_with_Leave
	,@Late_Exempted_Days = Isnull(Late_Count_Exemption, 0)
	,@RoundingValue = ISNULL(Late_Hour_Upper_Rounding, 0)
	,@Late_Exempted_limit = ISNULL(late_exemption_limit, '00:00')
	,-- added by mitesh on 24/01/2012
	@Max_Late_Limit = ISNULL(Max_Late_Limit, '00:00')
	,--Alpesh 18-Jul-2012
	@Extra_exemption_limit = CASE 
		WHEN LateEarly_Exemption_MaxLimit = ''
			THEN '00:00'
		ELSE ISNULL(LateEarly_Exemption_MaxLimit, '00:00')
		END
	,@Extra_Count_Exemption = ISNULL(LateEarly_Exemption_Count, 0)
FROM T0040_GENERAL_SETTING G WITH (NOLOCK)
INNER JOIN (
	SELECT MAX(For_Date) AS For_Date
	FROM T0040_GENERAL_SETTING WITH (NOLOCK)
	WHERE cmp_id = @cmp_id
		AND For_Date <= @Month_End_Date
		AND Branch_ID = @Branch_ID
	) G1 ON G.For_Date = G1.For_Date
WHERE Cmp_ID = @Cmp_ID
	AND Branch_ID = @Branch_ID

SELECT @Late_Limit_Sec = dbo.F_Return_Sec(@Emp_Late_Limit)

SELECT @Late_Exempted_limit_sec = dbo.F_Return_Sec(@Late_Exempted_limit) -- added by mitesh on 24/01/2012

CREATE TABLE #Late_Data (
	Emp_ID NUMERIC
	,Cmp_ID NUMERIC
	,[Month] NUMERIC
	,[Year] NUMERIC
	,Late_Balance_BF NUMERIC
	,Curr_M_Late NUMERIC
	,Total_Late NUMERIC
	,To_Be_Adj NUMERIC
	,Leave_ID NUMERIC
	,Leave_Bal NUMERIC(5, 1)
	,Adj_Again_Leave NUMERIC
	,Dedu_Leave_Bal NUMERIC(5, 1)
	,Adj_Fm_Sal NUMERIC
	,Deduct_From_Sal NUMERIC(5, 1)
	,Total_Adj NUMERIC(5, 1)
	,Balance_CF NUMERIC
	)

IF Object_ID('tempdb..#data') IS NULL
BEGIN
	CREATE TABLE #EMP_CONS (
		EMP_ID NUMERIC
		,BRANCH_ID NUMERIC
		,INCREMENT_ID NUMERIC
		)

	INSERT INTO #EMP_CONS
	VALUES (
		@emp_Id
		,@Branch_ID
		,@Increment_ID
		)

	CREATE TABLE #Data (
		Emp_Id NUMERIC
		,For_date DATETIME
		,Duration_in_sec NUMERIC
		,Shift_ID NUMERIC
		,Shift_Type NUMERIC
		,Emp_OT NUMERIC
		,Emp_OT_min_Limit NUMERIC
		,Emp_OT_max_Limit NUMERIC
		,P_days NUMERIC(12, 3) DEFAULT 0
		,OT_Sec NUMERIC DEFAULT 0
		,In_Time DATETIME
		,Shift_Start_Time DATETIME
		,OT_Start_Time NUMERIC DEFAULT 0
		,Shift_Change TINYINT DEFAULT 0
		,Flag INT DEFAULT 0
		,Weekoff_OT_Sec NUMERIC DEFAULT 0
		,Holiday_OT_Sec NUMERIC DEFAULT 0
		,Chk_By_Superior NUMERIC DEFAULT 0
		,IO_Tran_Id NUMERIC DEFAULT 0
		,-- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time DATETIME
		,Shift_End_Time DATETIME
		,--Ankit 16112013
		OT_End_Time NUMERIC DEFAULT 0
		,--Ankit 16112013
		Working_Hrs_St_Time TINYINT DEFAULT 0
		,--Hardik 14/02/2014
		Working_Hrs_End_Time TINYINT DEFAULT 0
		,--Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18, 2) DEFAULT 0 -- Add by Gadriwala Muslim 05012014
		)

	EXEC P_GET_EMP_INOUT @Cmp_ID
		,@Month_St_Date
		,@Month_End_Date
END

IF @Emp_Late_Mark = 1
BEGIN
	IF @Is_Late_CF = 1
		AND charindex(@varMonth, @Late_CF_Reset_On) > 0
	BEGIN
		SELECT @LMark_BF = isnull(lATE_Closing, 0)
		FROM T0140_LATE_TRANSACTION T WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(For_Date) AS For_Date
			FROM T0140_LATE_TRANSACTION WITH (NOLOCK)
			WHERE Emp_ID = @emp_Id
				AND Cmp_ID = @Cmp_ID
				AND For_Date <= @Month_St_Date
			) T2 ON T.For_Date = T2.FOR_DATE
		WHERE Emp_ID = @emp_Id
			AND Cmp_ID = @Cmp_ID
	END

	SELECT Shift_ID
		,Shift_St_Time
		,Shift_End_Time
	INTO #SHIFT_MASTER
	FROM T0040_SHIFT_MASTER WITH (NOLOCK)
	WHERE CMP_ID = @Cmp_ID
		AND Inc_Auto_Shift = 1

	--Added by Nimesh on 22-Dec-2015 (Placed it out side the cursor loop)
	DECLARE @HalfDayDate VARCHAR(500)

	EXEC GET_HalfDay_Date @Cmp_ID
		,@Emp_ID
		,@Month_st_Date
		,@Month_End_Date
		,0
		,@HalfDayDate OUTPUT

	DECLARE @For_DateCurr DATETIME --Ankit 07112015    

	SET @For_DateCurr = NULL

	DECLARE @Is_Cancel_Late_In TINYINT
	DECLARE @Differnce_Rounding_Late_Sec NUMERIC
	DECLARE @Shift_ID NUMERIC(18, 0);

	SELECT @Is_Late_calc_On_HO_WO = Is_Late_Calc_On_HO_WO
		,@Is_LateMark = Is_Late_Mark
		,@RoundingValue = ISNULL(Early_Hour_Upper_Rounding, 0)
	FROM T0040_GENERAL_SETTING G WITH (NOLOCK)
	INNER JOIN (
		SELECT MAX(For_Date) AS For_Date
		FROM T0040_GENERAL_SETTING WITH (NOLOCK)
		WHERE Cmp_ID = @Cmp_ID
			AND For_Date <= @Month_End_Date
			AND Branch_ID = @Branch_ID
		) G1 ON G.For_Date = G1.For_Date
	WHERE Branch_ID = @Branch_ID
		AND Cmp_ID = @Cmp_ID

	DECLARE curLMark CURSOR
	FOR
	SELECT In_Time
		,OUT_Time
		,For_date
	FROM #Data D
	LEFT OUTER JOIN #Absent_Dates AD ON D.For_Date = AD.Absent_date
	WHERE NOT EXISTS (
			SELECT 1
			FROM T0150_EMP_INOUT_RECORD EIO WITH (NOLOCK)
			WHERE EIO.Emp_ID = D.Emp_Id
				AND isnull(Is_Cancel_Late_In, 0) <> 0
				--AND In_Time=D.In_Time  As in mid case when approve cancel late in at that time in present day Sp In_Time is set to shift start time so need to change this with for_date
				AND for_date = d.for_date
				AND (
					(
						Chk_By_Superior = 2
						AND Reason = ''
						)
					OR (
						Chk_By_Superior = 1
						AND Reason <> ''
						)
					)
			)
		AND Absent_date IS NULL
		AND D.For_date BETWEEN @Month_St_Date
			AND @Month_End_Date --ADDED BY RAMIZ ON 03/01/2018
		AND D.EMP_iD = ISNULL(@emp_Id, D.EMP_ID)
		AND d.P_days = 1 -- Add by deepal bhagawati issue Only need to take full day present in the late mark
		--SELECT    MIN(CAST(CAST(in_time as VARCHAR(11)) + ' ' + dbo.F_Return_HHMM(in_time) AS DATETIME)),
		--      MAX(CAST(CAST(Out_time as VARCHAR(11)) + ' ' + dbo.F_Return_HHMM(Out_time) AS DATETIME)),
		--      EI.For_Date 
		--FROM  dbo.T0150_Emp_Inout_Record EI
		--      LEFT OUTER JOIN #Absent_Dates AD on EI.For_Date = AD.Absent_date
		--WHERE Emp_ID =@Emp_ID AND For_Date>=@Month_st_Date AND For_Date<=@Month_end_Date  
		--      AND isnull(Is_Cancel_Late_In,0) =0 AND Absent_date IS NULL 
		--GROUP BY For_Date     

	OPEN curLMark

	FETCH NEXT
	FROM curLMark
	INTO @In_Date
		,@Out_Date
		,@For_DateCurr

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Added by Nimesh 20 April, 2015
		SET @Shift_ID = NULL;
		SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @emp_Id, @In_Date);

		/*The following code added by Nimesh On 23-Aug-2018 (Auto Shift Scenario does not working in Late Early Mark Report)*/
		IF EXISTS (
				SELECT 1
				FROM #SHIFT_MASTER
				WHERE SHIFT_ID = @Shift_ID
				)
		BEGIN
			SELECT TOP 1 @Shift_ID = Shift_ID
			FROM #SHIFT_MASTER
			ORDER BY ABS(DATEDIFF(S, @In_Date, @For_DateCurr + Shift_St_Time)) ASC
		END

		SELECT @Shift_St_Time = SM.Shift_St_Time
			,@Shift_End_Time = SM.Shift_End_Time
		FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)
		WHERE SM.Cmp_ID = @Cmp_ID
			AND SM.Shift_ID = @Shift_ID

		--End Nimesh
		SET @var_Shift_St_Date = cast(@In_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time
		SET @var_Shift_End_Date = cast(@Out_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time --Alpesh 18-Jul-2012
		SET @Shift_St_DATETIME = cast(@var_Shift_St_Date AS DATETIME)
		SET @Shift_Exemption_St_DATETIME = dateadd(s, @Late_Exempted_limit_sec, @Shift_St_DATETIME)
		SET @Shift_Max_Late_Time = dateadd(s, dbo.F_Return_Sec(@Max_Late_Limit), @Shift_St_DATETIME) --Alpesh 18-Jul-2012
		SET @Shift_St_DATETIME = dateadd(s, @Late_Limit_Sec, @Shift_St_DATETIME)
		-----Extra Exemption
		SET @Working_Time_Sec = 0
		SET @Shift_Time_Sec = 0
		SET @Working_Time_Sec = Datediff(s, @In_Date, @Out_Date)
		SET @Shift_Time_Sec = Datediff(S, @Shift_St_Time, @Shift_End_Time)

		IF (@Shift_Time_Sec - @Working_Time_Sec) > 0
		BEGIN
			IF dbo.F_Return_Sec(@Extra_exemption_limit) >= (@Shift_Time_Sec - @Working_Time_Sec)
			BEGIN
				IF @Extra_Count_Exemption > @Temp_Extra_Count
					SET @Extra_Exemption = 1
				ELSE
					SET @Extra_Exemption = 0
			END
			ELSE
				SET @Extra_Exemption = 0
		END
		ELSE
			SET @Extra_Exemption = 0

		-----Extra Exemption
		IF @Is_LateMark = 1
		BEGIN
			IF @Is_Late_calc_On_HO_WO = 0
			BEGIN
				IF CHARINDEX(CAST(@In_Date AS VARCHAR(11)), @StrWeekoff_Date, 0) <> 0
					OR CHARINDEX(CAST(@In_Date AS VARCHAR(11)), @StrHoliday_Date, 0) <> 0
					SET @In_Date = @Shift_St_DATETIME
			END
		END
		
		------Hasmukh for Late effect or not on WO HO 110711 -----------
		IF @Return_Record_SET = 1
			AND EXISTS (
				SELECT 1
				FROM dbo.T0100_EMP_LATE_DETAIL WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID
					AND Month(For_Date) = @month
					AND Year(For_Date) = @Year
				)
		BEGIN
			INSERT INTO #Late_Data (
				Emp_ID
				,Cmp_ID
				,Month
				,Year
				,Late_Balance_BF
				,Curr_M_Late
				,Total_Late
				,To_Be_adj
				,Leave_ID
				,Leave_Bal
				,Adj_Again_Leave
				,Deduct_From_Sal
				,Total_Adj
				,Adj_Fm_Sal
				,Balance_CF
				)
			SELECT @Emp_ID
				,@Cmp_ID
				,@Month
				,@Year
				,Late_Balance_BF
				,Late_Curr_Days
				,Late_total_Days
				,Late_Tobe_Adj_days
				,LeavE_Id
				,0
				,Late_adj_Agn_Leave
				,Late_adj_Agn_Leave
				,Late_total_adj_Days
				,0
				,Late_closing
			FROM T0100_EMP_LATE_DETAIL WITH (NOLOCK)
			WHERE Emp_ID = @Emp_ID
				AND Month(for_DatE) = @month
				AND Year(for_Date) = @Year
		END
		ELSE
		BEGIN
			
			--- Added by Mitesh 08/08/2011 ## Start ## ----
			SET @Is_Cancel_Late_In = 0

			SELECT TOP 1 @Is_Cancel_Late_In = isnull(Is_Cancel_Late_In, 0)
			FROM dbo.T0150_Emp_Inout_Record WITH (NOLOCK)
			WHERE Emp_ID = @emp_Id
				AND For_Date = CONVERT(NVARCHAR, @In_Date, 106)
				AND ISNULL(Late_Calc_Not_App, 0) = 0
				--AND (Chk_By_Superior <> 2 And Reason <> '')-- Changed by Ramiz on 04/03/2016 from Chk_By_Superior = 1 to Chk_By_Superior <> 0 as now Chk_By_Superior = 2 is also coming
				--AND ((Chk_By_Superior = 2 AND Reason = '') Or (Chk_By_Superior <> 2 AND Reason <> ''))	--New Condition added by Ramiz on 05/02/2019
				AND (
					(
						Chk_By_Superior = 2
						AND Reason = ''
						)
					OR (
						Chk_By_Superior = 1
						AND Reason <> ''
						)
					)
			ORDER BY Is_Cancel_Late_In DESC --order by change by hasmukh 25022013

			--Added by Nimesh 21 May, 2015
			--SET @Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @emp_Id, @In_Date);                       
			SELECT @Shift_St_Time = SM.Shift_St_Time
				,@is_Half_Day = isnull(SM.Is_Half_Day, 0)
				,@Shift_St_Time_Half_Day = isnull(SM.Half_St_Time, '00:00')
				,@Shift_End_Time_Half_Day = isnull(SM.Half_End_Time, '00:00')
			FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)
			WHERE SM.Cmp_ID = @Cmp_ID
				AND SM.Shift_ID = @Shift_ID

			--End Nimesh
			IF (CHARINDEX(CONVERT(NVARCHAR(11), @In_Date, 109), @HalfDayDate) > 0) -- Added by Mitesh
			BEGIN
				IF @is_Half_Day = 1
				BEGIN
					SET @var_Shift_St_Date = cast(@In_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time_Half_Day
					SET @var_Shift_End_Date = cast(@Out_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time_Half_Day --Alpesh 19-Jul-2012
				END
				ELSE
				BEGIN
					SET @var_Shift_St_Date = cast(@In_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time
					SET @var_Shift_End_Date = cast(@Out_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time --Alpesh 19-Jul-2012
				END
			END
			ELSE
			BEGIN
				SET @var_Shift_St_Date = cast(@In_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time
				SET @var_Shift_End_Date = cast(@Out_Date AS VARCHAR(11)) + ' ' + @Shift_End_Time --Alpesh 19-Jul-2012
			END

			SET @Shift_St_DATETIME = cast(@var_Shift_St_Date AS DATETIME)
			SET @Shift_Exemption_St_DATETIME = dateadd(s, @Late_Exempted_limit_sec, @Shift_St_DATETIME)
			SET @Shift_Max_Late_Time = dateadd(s, dbo.F_Return_Sec(@Max_Late_Limit), @Shift_St_DATETIME) --Alpesh 19-Jul-2012
			SET @Shift_St_DATETIME = dateadd(s, @Late_Limit_Sec, @Shift_St_DATETIME)

			-- Start half day leave condition added by mitesh on 23/01/2012
			-- if Firt half day leave is there than it will not considered late mark
			DECLARE @is_half_day_Leave TINYINT
			DECLARE @is_Full_day_Leave TINYINT

			SET @is_half_day_Leave = 0
			SET @is_Full_day_Leave = 0

			DECLARE @fr_dt AS DATETIME

			--SET @fr_dt =  cast(@In_Date as DATETIME)
			SET @fr_dt = cast(convert(NVARCHAR(11), @In_Date, 106) + ' 00:00:00' AS DATETIME)

			IF EXISTS (
					SELECT la.Leave_Approval_ID
					FROM T0120_LEAVE_APPROVAL la WITH (NOLOCK)
					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) ON la.Leave_Approval_ID = lad.Leave_Approval_ID
					WHERE Emp_ID = @emp_Id
						AND Leave_Assign_As = 'First Half'
						AND (
							ISNULL(Half_Leave_Date, To_date) = @fr_dt
							OR CASE 
								WHEN Half_Leave_Date = '01-Jan-1900'
									THEN To_date
								ELSE Half_Leave_Date
								END = @fr_dt
							)
						AND Approval_Status = 'A'
					)
			BEGIN
				SET @is_half_day_Leave = 1
			END

			-- Added by rohit on 03052016
			IF EXISTS (
					SELECT la.Leave_Approval_ID
					FROM T0120_LEAVE_APPROVAL la WITH (NOLOCK)
					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) ON la.Leave_Approval_ID = lad.Leave_Approval_ID
					WHERE Emp_ID = @emp_Id
						AND upper(Leave_Assign_As) = 'PART DAY'
						AND (From_Date = @fr_dt)
						AND Leave_out_time = @Shift_Max_Late_Time
						AND Approval_Status = 'A'
					)
			BEGIN
				SET @is_half_day_Leave = 1
			END

			-- End half day leave condition added by mitesh on 23/01/2012
			----Full day leave condition added by hasmukh 05032013
			IF EXISTS (
					SELECT Emp_id
					FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
					WHERE Emp_ID = @emp_id
						AND For_Date = @fr_dt
						AND (
							Leave_Used >= 1
							OR CompOff_Used >= 1
							)
					) --CompOff_Used  --Ankit 04122015
			BEGIN
				SET @is_Full_day_Leave = 1
			END

			-------Full day leave condition  End hasmukh 05032013-----------                                    
			SET @Differnce_Rounding_Late_Sec = 0

			IF @In_Date > @Shift_St_DATETIME
				AND @Is_Cancel_Late_In = 0
				AND @is_half_day_Leave = 0
				AND @is_Full_day_Leave = 0 -- Modified by Mitesh on 08/08/2011
			BEGIN
				/* For Shift Start time 12:00 AM & Employee In punch Early then not count Late Mark (Nirma Client)  --Ankit 07112015 */
				IF @RoundingValue > 0
				BEGIN
					IF DATEPART(hh, @Shift_St_DATETIME) = 0
						AND @In_Date < DATEADD(D, 1, @For_DateCurr)
						SET @Differnce_Rounding_Late_Sec = datediff(s, DATEADD(D, 1, @For_DateCurr), @In_Date)
					ELSE
						SET @Differnce_Rounding_Late_Sec = datediff(s, cast(@var_Shift_St_Date AS DATETIME), @In_Date)

					SELECT @Differnce_Rounding_Late_Sec = dbo.Pro_Rounding_Sec_HH_MM(@Differnce_Rounding_Late_Sec, @RoundingValue)
				END
				ELSE
				BEGIN
					IF DATEPART(hh, @Shift_St_DATETIME) = 0
						AND @In_Date < DATEADD(D, 1, @For_DateCurr)
						SET @Differnce_Rounding_Late_Sec = datediff(s, DATEADD(D, 1, @For_DateCurr), @In_Date)
					ELSE
						SET @Differnce_Rounding_Late_Sec = datediff(s, @Shift_St_DATETIME, @In_Date)
				END

				IF @Differnce_Rounding_Late_Sec > 0
				BEGIN
					/*Added Following Code By Nimesh on 13-Jan-2017 (If Extra Exemption is given and it is remaining then it should be considered after normal late deduction)*/
					IF @Extra_Exemption = 0
						AND (
							@Curr_Month_LMark >= @Late_Exempted_Days
							OR (
								@Late_Exempted_limit_sec <> 0
								AND @In_Date > @Shift_Exemption_St_DateTime
								)
							) --AND (@Late_Exempted_limit_sec = 0 OR  @In_Date <= @Shift_Exemption_St_DateTime )
						AND @Extra_Count_Exemption > @Temp_Extra_Count
					BEGIN
						SET @Extra_Exemption = 1
					END

					--Alpesh 19-Jul-2012 put condition for deficiate with limited period
					IF (
							@In_Date > @Shift_St_DATETIME
							AND @In_Date <= @Shift_Max_Late_Time
							)
					BEGIN
						IF DATEDIFF(s, @In_Date, @Out_Date) < DATEDIFF(s, @var_Shift_St_Date, @var_Shift_End_Date)
						BEGIN
							IF @Extra_Exemption = 0
							BEGIN
								IF @Late_Exempted_limit_sec = 0
									SET @Curr_Month_LMark = @Curr_Month_LMark + 1
								ELSE IF @In_Date <= @Shift_Exemption_St_DATETIME
									SET @Curr_Month_LMark = @Curr_Month_LMark + 1
								ELSE
									SET @Curr_Month_LMark_WithOut_Exemption = @Curr_Month_LMark_WithOut_Exemption + 1
							END
							ELSE
							BEGIN
								SET @Temp_Extra_Count = @Temp_Extra_Count + 1
							END

							SET @Total_Late_Sec = @Total_Late_Sec + @Differnce_Rounding_Late_Sec
							SET @var_Return_Late_Date = @var_Return_Late_Date + ';' + cast(@In_Date AS VARCHAR(11))
						END
					END
					ELSE
					BEGIN
						IF @Extra_Exemption = 0
						BEGIN
							IF @Late_Exempted_limit_sec = 0
							BEGIN
							
								IF @Cutoff_date <> '' -- Added by tejas for wonser home finance late_early deduction gat in another variable
									AND @In_Date > @Cutoff_date
									AND @In_Date < @cutoff_month_st_date and @In_Date > @Shift_St_DATETIME  and exists(select 1 from T0200_MONTHLY_SALARY where MONTH(Month_End_Date) =  month(dateadd(m,-1,@Month_End_Date)) 
												and year(Month_End_Date) =  Year( dateadd(m,-1,@Month_End_Date)) and Emp_ID=@Emp_Id and cutoff_date <> Month_End_Date)  
									BEGIN
										SET @LMark_After_Cutoff = @LMark_After_Cutoff + 1      
									END
								ELSE
									BEGIN
											SET @Curr_Month_LMark = @Curr_Month_LMark + 1      
									END
							END
							ELSE IF @In_Date <= @Shift_Exemption_St_DATETIME
							BEGIN
								SET @Curr_Month_LMark = @Curr_Month_LMark + 1
							END
							ELSE
							BEGIN
								SET @Curr_Month_LMark_WithOut_Exemption = @Curr_Month_LMark_WithOut_Exemption + 1
							END
						END
						ELSE
							SET @Temp_Extra_Count = @Temp_Extra_Count + 1

						SET @Total_Late_Sec = @Total_Late_Sec + @Differnce_Rounding_Late_Sec
						SET @var_Return_Late_Date = @var_Return_Late_Date + ';' + cast(@In_Date AS VARCHAR(11))
					END
							----- End ---
				END
				
				IF @Return_Late_Date_Table = 1
				BEGIN
					INSERT INTO #Emp_Late (
						Emp_ID
						,In_time
						,Shift_Time
						,Late_Sec
						,Late_Day
						)
					SELECT @Emp_ID
						,@In_Date
						,@Shift_St_DATETIME
						,Datediff(s, @Shift_St_DATETIME, @In_Date)
						,1
				END
			END
		END

		FETCH NEXT
		FROM curLMark
		INTO @In_Date
			,@Out_Date
			,@For_DateCurr --Alpesh 18-Jul-2012
	END

	CLOSE curLMark;

	DEALLOCATE curLMark;
END

IF @Late_Dedu_Type = 'Hour'
BEGIN
	SET @Total_LMark = 0
	SET @Late_Sal_Dedu_Days = 0
	set @Late_Sal_Dedu_Days_cutoff = 0
END
ELSE
BEGIN
	DECLARE @Tobe_Adj NUMERIC
	DECLARE @Dedu_From_Sal NUMERIC(5, 1)
	DECLARE @Adj_fm_sal NUMERIC
	DECLARE @Balance_CF NUMERIC
	DECLARE @Total_Adj NUMERIC
	DECLARE @Leave_Bal NUMERIC(5, 1)
	DECLARE @Leave_ID NUMERIC
	DECLARE @Adj_Again_Leave NUMERIC
	DECLARE @Dedu_Leave_Bal NUMERIC(5, 1)
	DECLARE @Leave_Tran_ID NUMERIC
	DECLARE @For_Date DATETIME
	DECLARE @Leave_negative_Allow NUMERIC(5, 1)

	SET @Adj_Again_Leave = 0
	SET @Dedu_Leave_Bal = 0
	
	--Added By Jimit 07112019 for Kich mid increment case 
	DECLARE @ExemptOnce AS INT

	--SET @Total_LMark = @LMark_BF + @Curr_Month_LMark - @Late_Exempted_Days --Alpesh 07-Oct-2011  --Commented By Jimit 07112019 for Kich mid increment case 
	IF @LMark_BF + @Curr_Month_LMark - @Late_Exempted_Days > 0
	BEGIN
		SET @Total_LMark = @LMark_BF + @Curr_Month_LMark - @Late_Exempted_Days --Alpesh 07-Oct-2011
		SET @ExemptOnce = 1
	END
	ELSE
	BEGIN
		SET @Total_LMark = @LMark_BF --+ @Curr_Month_LMark --- Commented by Hardik 11/03/2020 for Kich as this going minus
		SET @ExemptOnce = 0
	END
	
	--Ended
	--select @Mid_Inc_Late_Mark_Count,@Total_LMark,@total_count_all_incremnet,@LMark_BF , @Curr_Month_LMark , @Late_Exempted_Days
	IF @Total_LMark < 0
		SET @Total_LMark = 0 --added by hasmukh due to transaction goes to negetive when no late is there 29122011
	--if @Total_LMark > 0 -- Commented by Hardik 11/03/2020 for Kich
	SET @Total_LMark = @Total_LMark + @Curr_Month_LMark_WithOut_Exemption

	--Added By Jimit 07112019 for Kich mid increment case
	IF @Mid_Inc_Late_Mark_Count > 0
		AND @ExemptOnce <> 1
		SET @Total_LMark = @Total_LMark - @Late_Exempted_Days

	--Ended
	SELECT TOP 1 @Leave_ID = l.Leave_ID
		,@For_Date = l.For_Date
		,@Leave_Tran_ID = l.Leave_Tran_ID
		,@Leave_Bal = ISNULL(Leave_Closing, 0)
		,@Leave_negative_Allow = q.Leave_Negative_Allow
	FROM dbo.T0140_Leave_Transaction l WITH (NOLOCK)
	INNER JOIN (
		SELECT max(For_Date) For_Date
			,lt.Leave_Id
			,lm.Leave_Negative_Allow
		FROM dbo.T0140_Leave_Transaction lt WITH (NOLOCK)
		INNER JOIN dbo.T0040_LeavE_MAster lm WITH (NOLOCK) ON lt.leave_ID = lm.leave_ID
			AND isnull(lm.Leave_paid_Unpaid, '') = 'P'
			AND lm.Leave_Type <> 'Company Purpose'
			AND isnull(Is_Late_Adj, 0) = 1
		WHERE Emp_ID = @Emp_ID
			AND For_Date <= @Month_End_Date
		GROUP BY lt.Leave_ID
			,lm.Leave_Negative_Allow
		) q ON l.Leave_ID = q.Leave_ID
		AND l.for_Date = q.for_Date
	WHERE l.Emp_ID = @Emp_ID
	ORDER BY Leave_Closing DESC

	SET @Tobe_Adj = 0
	SET @Dedu_From_Sal = 0

	-- Added For MID-Increment Count For GALLOPS ON 13092018
	--IF @total_count_all_incremnet > 1 and @Total_LMark > 0  --Commented By Jimit 07112019 for Kich mid increment case 
	IF @total_count_all_incremnet > 1
	BEGIN
		SET @Total_LMark = @Mid_Inc_Late_Mark_Count + @Total_LMark
	END
	ELSE --Added By Jimit 07112019 for Kich mid increment case 
	BEGIN
		SET @Total_LMark = @Total_LMark
	END

	
	IF @Late_Adj_Day > 0 AND @Total_LMark > 0
		SET @Tobe_Adj = @Total_LMark - (@Total_LMark % @Late_Adj_Day)
	
	IF @Late_Dedu_Days > 0
		SET @Adj_fm_sal = @Tobe_Adj
		
	set  @Adj_fm_sal = isnull(@Adj_fm_sal,0)
	
	IF cast(@Late_Adj_Day as int) > 0 --and @Adj_fm_sal > 0 and @Late_Dedu_Days > 0 
	BEGIN
		set @Dedu_From_Sal = isnull(@Adj_fm_sal,0) * @Late_Dedu_Days / @Late_Adj_Day
	END
	
	SET @Total_Adj = @Adj_fm_sal
	SET @Balance_CF = @Total_LMark - @Total_Adj
	SET @Total_Late_Sec = 0
	SET @Late_Sal_Dedu_Days = @Dedu_From_Sal
	if cast(@Late_Adj_Day as int) > 0
		set @Late_Sal_Dedu_Days_cutoff = @LMark_After_Cutoff * @Late_Dedu_Days / @Late_Adj_Day
	

	IF @Return_Record_SET = 1
	BEGIN
		SELECT *
			,@numPresentDays AS Present_Day
		FROM #Late_Data

		INSERT INTO #Late_Data (
			Emp_ID
			,Cmp_ID
			,Month
			,Year
			,Late_Balance_BF
			,Curr_M_Late
			,Total_Late
			,To_Be_adj
			,Leave_ID
			,Leave_Bal
			,Adj_Again_Leave
			,Dedu_Leave_Bal
			,Adj_Fm_Sal
			,Total_Adj
			,Deduct_From_Sal
			,Balance_CF
			)
		SELECT @Emp_ID
			,@Cmp_ID
			,@Month
			,@Year
			,@LMark_BF
			,(@Curr_Month_LMark + @Curr_Month_LMark_WithOut_Exemption)
			,@Total_LMark
			,@Tobe_Adj
			,@Leave_ID
			,@Leave_Bal
			,@Adj_Again_Leave
			,@Dedu_Leave_Bal
			,@Adj_fm_sal
			,@Total_Adj
			,@Dedu_From_Sal
			,@Balance_CF
	END
END

RETURN