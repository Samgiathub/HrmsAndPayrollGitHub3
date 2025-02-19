
CREATE PROCEDURE [dbo].[SP_CALCULATE_PRESENT_DAYS_Performance] 
	 @Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_ID NUMERIC
	,@Desig_ID NUMERIC
	,@Emp_ID NUMERIC
	,@constraint NVARCHAR(MAX)
	,@Return_Record_set NUMERIC = 1
	,@StrWeekoff_Date NVARCHAR(Max) = ''
	,@Is_Split_Shift_Req TINYINT = 0
	,@PBranch_ID NVARCHAR(MAX) = ''
	,@PVertical_ID NVARCHAR(MAX) = ''
	,@PSubVertical_ID NVARCHAR(MAX) = ''
	,@PDept_ID NVARCHAR(MAX) = ''
	,@Late_SP TINYINT = 0
	,@Call_For_Leave_Cancel NUMERIC(18, 2) = 0
	,@Reload_InOut BIT = 1
	,@Report_For NVARCHAR(50) = NULL
	,@flag INT = 0
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Count NUMERIC
DECLARE @Tmp_Date DATETIME

SET @Tmp_Date = @From_Date

DECLARE @For_OT_APPROVAL AS BIT = 0

--IF @Return_Record_set = 15
--	begin
--		SET @For_OT_APPROVAL=1
--		set @Return_Record_set = 2
--	end
--return
IF @Return_Record_set = 1
	OR @Return_Record_set = 2
	OR @Return_Record_set = 3
	OR @Return_Record_set = 5
	OR @Return_Record_set = 8
	OR @Return_Record_set = 9
	OR @Return_Record_set = 10
	OR @Return_Record_set = 11
	OR @Return_Record_set = 12
	OR @Return_Record_set = 13
	OR @Return_Record_set = 14
	OR @Return_Record_set = 15
	OR @return_record_set = 16 --or @Return_Record_set = 7    
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME = 'PresentData'
			)
	BEGIN
		CREATE TABLE PresentData (
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
			,OUT_Time DATETIME
			,Shift_End_Time DATETIME
			,OT_End_Time NUMERIC DEFAULT 0
			,Working_Hrs_St_Time TINYINT DEFAULT 0
			,Working_Hrs_End_Time TINYINT DEFAULT 0
			,GatePass_Deduct_Days NUMERIC(18, 2) DEFAULT 0
			)

		CREATE CLUSTERED INDEX ix_PresentData_Emp_Id_For_date ON PresentData (Emp_Id,For_Date);
	END
END

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'PresentData_temp1')
BEGIN
	CREATE TABLE PresentData_temp1 (
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
		,OUT_Time DATETIME
		,Shift_End_Time DATETIME
		,OT_End_Time NUMERIC DEFAULT 0
		,Working_Hrs_St_Time TINYINT DEFAULT 0
		,Working_Hrs_End_Time TINYINT DEFAULT 0
		,GatePass_Deduct_Days NUMERIC(18, 2) DEFAULT 0
		)

	CREATE CLUSTERED INDEX ix_PresentData_temp1_Emp_Id_For_date ON PresentData_temp1 (Emp_Id,For_Date);
END

IF @Is_Split_Shift_Req = 1
BEGIN
	CREATE TABLE #Split_Shift_Table (
		Emp_Id NUMERIC
		,Split_Shift_Count NUMERIC(18, 0)
		,Split_Shift_Dates VARCHAR(5000)
		,Split_Shift_Allow NUMERIC(18, 3)
		)
END

IF @Branch_ID = 0
	SET @Branch_ID = NULL

IF @Cat_ID = 0
	SET @Cat_ID = NULL

IF @Grd_ID = 0
	SET @Grd_ID = NULL

IF @Type_ID = 0
	SET @Type_ID = NULL

IF @Dept_ID = 0
	SET @Dept_ID = NULL

IF @Desig_ID = 0
	SET @Desig_ID = NULL

IF @Emp_ID = 0
	SET @Emp_ID = NULL

IF @PBranch_ID = '0' OR @PBranch_ID = '' 
	SET @PBranch_ID = NULL

IF @PVertical_ID = '0' OR @PVertical_ID = ''
	SET @PVertical_ID = NULL

IF @PsubVertical_ID = '0' OR @PsubVertical_ID = '' 
	SET @PsubVertical_ID = NULL

IF @PDept_ID = '0' OR @PDept_Id = '' 
	SET @PDept_ID = NULL

IF @PBranch_ID IS NULL
BEGIN
	SELECT @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID AS NVARCHAR(5)) FROM T0030_BRANCH_MASTER WHERE Cmp_ID = @Cmp_ID
	SET @PBranch_ID = @PBranch_ID + ',0'
END

IF @PVertical_ID IS NULL
BEGIN
	SELECT @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID AS NVARCHAR(5)) FROM T0040_Vertical_Segment WHERE Cmp_ID = @Cmp_ID
	IF @PVertical_ID IS NULL
		SET @PVertical_ID = '0';
	ELSE
		SET @PVertical_ID = @PVertical_ID + ',0'
END

IF @PsubVertical_ID IS NULL
BEGIN
	SELECT @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID AS NVARCHAR(5)) FROM T0050_SubVertical WHERE Cmp_ID = @Cmp_ID
	IF @PsubVertical_ID IS NULL
		SET @PsubVertical_ID = '0';
	ELSE
		SET @PsubVertical_ID = @PsubVertical_ID + ',0'
END

IF @PDept_ID IS NULL
BEGIN
	SELECT @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID AS NVARCHAR(5)) FROM T0040_DEPARTMENT_MASTER WHERE Cmp_ID = @Cmp_ID
	IF @PDept_ID IS NULL
		SET @PDept_ID = '0';
	ELSE
		SET @PDept_ID = @PDept_ID + ',0'
END

--Added By Jaina 25-09-2015 End
--This Section is Added By Ramiz on 05/03/2016, This will be used in OT Approval for Filtering Purpose 
IF @Return_Record_set = 2
BEGIN
	DECLARE @BRANCH_ID_FOR_OT NUMERIC(18, 0)
	DECLARE @DEPT_ID_FOR_OT NUMERIC(18, 0)
	DECLARE @GRD_ID_FOR_OT NUMERIC(18, 0)

	SET @BRANCH_ID_FOR_OT = @Branch_id
	SET @DEPT_ID_FOR_OT = @Dept_ID
	SET @GRD_ID_FOR_OT = @Grd_ID
END


DECLARE @HasConsTable BIT
SET @HasConsTable = 1;

IF OBJECT_ID('tempdb..#Emp_Cons') IS NOT NULL
BEGIN
	IF EXISTS (SELECT 1 FROM dbo.split(@Constraint, '#') T WHERE T.Data <> '' AND NOT EXISTS (SELECT 1 FROM #Emp_Cons E WHERE Cast(T.Data AS NUMERIC) = Emp_ID))
	BEGIN
		SET @HasConsTable = 0;
	END
END
ELSE
BEGIN
	SET @HasConsTable = 0;
END

--IF OBJECT_ID('tempdb..#Emp_Cons') IS NULL
IF (@HasConsTable = 0)
BEGIN
	CREATE TABLE #Emp_Cons (
		 Emp_ID NUMERIC
		,Branch_ID NUMERIC
		,Increment_ID NUMERIC
	);
	CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);

	IF @Constraint <> ''
		AND @Constraint <> '0'
	BEGIN
		INSERT INTO #Emp_Cons (Emp_ID)
		SELECT CAST(data AS NUMERIC)
		FROM dbo.Split(@Constraint, '#')

		--Added By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---
		UPDATE #Emp_Cons
		SET Branch_ID = I1.Branch_ID
			,Increment_ID = I1.Increment_ID
		FROM #Emp_Cons EC
		INNER JOIN T0095_INCREMENT I1 ON EC.Emp_ID = I1.Emp_ID
		INNER JOIN (
			SELECT MAX(I2.Increment_ID) AS Increment_ID
				,I2.Emp_ID
			FROM T0095_Increment I2
			INNER JOIN #Emp_Cons E ON I2.Emp_ID = E.Emp_ID -- Ankit 12092014 for Same Date Increment --
			INNER JOIN (
				SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
					,I3.EMP_ID
				FROM T0095_INCREMENT I3
				INNER JOIN #Emp_Cons E3 ON I3.Emp_ID = E3.Emp_ID
				WHERE I3.Increment_effective_Date <= @to_date
					AND I3.Cmp_ID = @Cmp_ID
				GROUP BY I3.EMP_ID
				) I3 ON I2.Increment_Effective_Date = I3.Increment_Effective_Date
				AND I2.EMP_ID = I3.Emp_ID
			GROUP BY I2.Emp_ID
			) I ON I1.Emp_ID = I.Emp_ID
			AND I1.Increment_ID = I.Increment_ID
			--Ended By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---   
	END
	ELSE
	BEGIN
		INSERT INTO #Emp_Cons
		SELECT DISTINCT emp_id
			,branch_id
			,Increment_ID
		FROM dbo.V_Emp_Cons
		WHERE Cmp_ID = @Cmp_ID
			AND ISNULL(Cat_ID, 0) = ISNULL(@Cat_ID, ISNULL(Cat_ID, 0))
			AND Grd_ID = ISNULL(@Grd_ID, Grd_ID)
			AND ISNULL(Dept_ID, 0) = ISNULL(@Dept_ID, ISNULL(Dept_ID, 0))
			AND ISNULL(Type_ID, 0) = ISNULL(@Type_ID, ISNULL(Type_ID, 0))
			AND ISNULL(Desig_ID, 0) = ISNULL(@Desig_ID, ISNULL(Desig_ID, 0)) --Added By Jaina 25-09-2015
			AND EXISTS (
				SELECT Data
				FROM dbo.Split(isnull(@PBranch_ID, 0), ',') PB
				WHERE cast(PB.data AS NUMERIC) = Isnull(V_Emp_Cons.Branch_ID, 0)
				)
			AND EXISTS (
				SELECT Data
				FROM dbo.Split(isnull(@PVertical_ID, 0), ',') V
				WHERE cast(v.data AS NUMERIC) = Isnull(V_Emp_Cons.Vertical_ID, 0)
				)
			AND EXISTS (
				SELECT Data
				FROM dbo.Split(isnull(@PsubVertical_ID, 0), ',') S
				WHERE cast(S.data AS NUMERIC) = Isnull(V_Emp_Cons.SubVertical_ID, 0)
				)
			AND EXISTS (
				SELECT Data
				FROM dbo.Split(isnull(@PDept_ID, 0), ',') D
				WHERE cast(D.data AS NUMERIC) = Isnull(V_Emp_Cons.Dept_ID, 0)
				)
			AND Emp_ID = ISNULL(@Emp_ID, Emp_ID)
			AND Increment_Effective_Date <= @To_Date
			AND (
				(
					@From_Date >= join_Date
					AND @From_Date <= left_date
					)
				OR (
					@To_Date >= join_Date
					AND @To_Date <= left_date
					)
				OR (
					Left_date IS NULL
					AND @To_Date >= Join_Date
					)
				OR (
					@To_Date >= left_date
					AND @From_Date <= left_date
					)
				)
		ORDER BY Emp_ID

		DELETE E
		FROM #Emp_Cons E
		WHERE NOT EXISTS (
				SELECT TOP 1 1
				FROM t0095_increment TI
				INNER JOIN (
					SELECT MAX(T0095_Increment.Increment_ID) AS Increment_ID
						,T0095_Increment.Emp_ID
					FROM T0095_Increment
					INNER JOIN #Emp_Cons E ON T0095_INCREMENT.Emp_ID = E.Emp_ID -- Ankit 12092014 for Same Date Increment
					WHERE Increment_effective_Date <= @to_date
						AND Cmp_ID = @Cmp_Id
					GROUP BY T0095_Increment.emp_ID
					) new_inc ON TI.Emp_ID = new_inc.Emp_ID
					AND Ti.Increment_ID = new_inc.Increment_ID
				WHERE Increment_effective_Date <= @to_date
					AND E.Increment_ID = TI.Increment_ID
				)
	END
END


/*************************************************************************
Added by Nimesh: 17/Nov/2015 
(To get holiday/weekoff data for all employees in seperate table)
*************************************************************************/
DECLARE @Required_Execution BIT;
SET @Required_Execution = 0;
IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
BEGIN
	CREATE TABLE #EMP_HOLIDAY (
		EMP_ID NUMERIC
		,FOR_DATE DATETIME
		,IS_CANCEL BIT
		,Is_Half TINYINT
		,Is_P_Comp TINYINT
		,H_DAY NUMERIC(4, 1)
	);
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY (EMP_ID,FOR_DATE);
	SET @Required_Execution = 1
END

IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
BEGIN
	CREATE TABLE #EMP_WEEKOFF (
		Row_ID NUMERIC
		,Emp_ID NUMERIC
		,For_Date DATETIME
		,Weekoff_day VARCHAR(10)
		,W_Day NUMERIC(4, 1)
		,Is_Cancel BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF (Emp_ID,For_Date)
	SET @Required_Execution = 1
END
ELSE IF NOT EXISTS (SELECT 1 FROM #EMP_WEEKOFF)
BEGIN
	SET @Required_Execution = 1
END

IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
BEGIN
	--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
	CREATE TABLE #Emp_WeekOff_Holiday (
		Emp_ID NUMERIC
		,WeekOffDate VARCHAR(Max)
		,WeekOffCount NUMERIC(4, 1)
		,HolidayDate VARCHAR(Max)
		,HolidayCount NUMERIC(4, 1)
		,HalfHolidayDate VARCHAR(Max)
		,HalfHolidayCount NUMERIC(4, 1)
		,OptHolidayDate VARCHAR(Max)
		,OptHolidayCount NUMERIC(4, 1)
		);
	SET @Required_Execution = 1;
END

IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
BEGIN
	--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
	CREATE TABLE #EMP_HW_CONS (
		 Emp_ID NUMERIC
		,WeekOffDate VARCHAR(Max)
		,WeekOffCount NUMERIC(4, 1)
		,CancelWeekOff VARCHAR(Max)
		,CancelWeekOffCount NUMERIC(4, 1)
		,HolidayDate VARCHAR(MAX)
		,HolidayCount NUMERIC(4, 1)
		,HalfHolidayDate VARCHAR(MAX)
		,HalfHolidayCount NUMERIC(4, 1)
		,CancelHoliday VARCHAR(Max)
		,CancelHolidayCount NUMERIC(4, 1)
	);
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS (Emp_ID)
	SET @Required_Execution = 1;
END

IF OBJECT_ID('tempdb..#EMP_HW_CONS_SAL') IS NOT NULL
	SET @Required_Execution = 1;

IF @Required_Execution = 1
BEGIN
	DECLARE @All_Weekoff BIT
	SET @All_Weekoff = 0;
	--Commented By Nimesh on 29-Aug-2017 (WeekOff CompOff should not be given if weekoff is canceled due to sandwich policy)
	TRUNCATE TABLE #EMP_HW_CONS
	EXEC SP_GET_HW_ALL @CONSTRAINT = @CONSTRAINT ,@CMP_ID = @Cmp_ID,@FROM_DATE = @FROM_DATE,@TO_DATE = @TO_DATE ,@All_Weekoff = @All_Weekoff,@Exec_Mode = 0
END

--Create by Nimesh on 05-Jan-2015 (To hold the General Setting for each employee to use it later)
CREATE TABLE #EMP_GEN_SETTINGS (
	 EMP_ID NUMERIC PRIMARY KEY
	,BRANCH_ID NUMERIC
	,First_In_Last_Out_For_InOut_Calculation TINYINT
	,Chk_otLimit_before_after_Shift_time TINYINT
)

DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT
SELECT TOP 1 @First_In_Last_Out_For_InOut_Calculation = First_In_Last_Out_For_InOut_Calculation
FROM #EMP_CONS EC
INNER JOIN T0040_GENERAL_SETTING GS ON EC.BRANCH_ID = GS.BRANCH_ID
INNER JOIN (
	SELECT GS1.BRANCH_ID,MAX(FOR_DATE) AS FOR_DATE FROM T0040_GENERAL_SETTING GS1
	WHERE GS1.FOR_DATE < @TO_DATE GROUP BY GS1.BRANCH_ID 
) GS1 ON GS.BRANCH_ID = GS1.BRANCH_ID AND GS.FOR_DATE = GS1.FOR_DATE

IF @Reload_InOut = 1
BEGIN
	--TRUNCATE TABLE #DATA  -- Deepal Change the #DATA to PresentDATA
	EXEC P_GET_EMP_INOUT_Performance @Cmp_ID,@FROM_DATE,@TO_DATE,@First_In_Last_Out_For_InOut_Calculation
END
--SELECT * FROM PRESENTDATA
RETURN

--add by chetan 050617 for check general setting option weekoff work transfer to ot
ALTER TABLE #EMP_GEN_SETTINGS ADD Tras_Week_OT TINYINT ,Is_Cancel_Holiday_WO_HO_same_day TINYINT
UPDATE TG
SET Tras_Week_OT = G.Tras_Week_OT ,Is_Cancel_Holiday_WO_HO_same_day = G.Is_Cancel_Holiday_WO_HO_same_day
FROM #EMP_GEN_SETTINGS TG
INNER JOIN T0040_GENERAL_SETTING G ON TG.BRANCH_ID = G.BRANCH_ID
INNER JOIN (
	SELECT MAX(GEN_ID) AS GEN_ID ,G1.BRANCH_ID
	FROM T0040_GENERAL_SETTING G1
	INNER JOIN (
		SELECT MAX(FOR_DATE) AS FOR_DATE ,BRANCH_ID
		FROM T0040_GENERAL_SETTING G2
		WHERE G2.For_Date <= @TO_DATE AND G2.Cmp_ID = @Cmp_Id GROUP BY G2.Branch_ID
	) G2 ON G1.Branch_ID = G2.Branch_ID AND G1.For_Date = G2.FOR_DATE GROUP BY G1.Branch_ID
) G1 ON G.Gen_ID = G1.GEN_ID AND G.Branch_ID = G1.Branch_ID


UPDATE D
SET EMP_OT = 0
FROM PresentData D
INNER JOIN #Emp_Cons E ON D.Emp_Id = E.Emp_ID
INNER JOIN T0095_INCREMENT I ON E.Increment_ID = I.Increment_ID
INNER JOIN T0040_GRADE_MASTER G ON G.Grd_ID = I.Grd_ID
WHERE OT_Applicable = 0


DELETE D FROM PresentData D INNER JOIN (  
	SELECT FOR_DATE ,EMP_ID FROM PresentData D1 WHERE Chk_By_Superior = 1
) D1 ON D.EMP_ID = D1.EMP_ID AND D.FOR_DATE = D1.For_date WHERE D.Chk_By_Superior = 0

SELECT D.Emp_Id
	,For_date
	,Duration_in_sec
	,In_Time
	,Shift_Start_Time
	,OUT_Time
	,Shift_End_Time
	,Working_Hrs_St_Time
	,Working_Hrs_End_Time
INTO #temp_In_Out_Time
FROM PresentData D
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
WHERE First_In_Last_Out_For_InOut_Calculation = 0

DECLARE @shift_st_time1 DATETIME
INSERT INTO PresentData_temp1 (
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
	)
SELECT Emp_ID
	,for_Date
	,sum(isnull(Duration_in_sec, 0))
	,isnull(Emp_OT, 0)
	,isnull(Emp_OT_min_Limit, 0)
	,isnull(Emp_OT_max_Limit, 0)
	,NULL
	,NULL
	,0
	,0
	,MAX(Chk_By_Superior)
	,IO_Tran_Id
	,0 
FROM PresentData
GROUP BY For_Date,Emp_ID,Emp_Ot,Emp_OT_min_Limit,Emp_OT_Max_Limit,IO_Tran_Id

UPDATE PresentData_temp1
SET In_Time = InTime ,OUT_Time = OutTime
FROM PresentData_temp1 AS DT
INNER JOIN (
	SELECT Min(In_Time) AS InTime ,Max(OUT_Time) AS OutTime ,For_Date ,Emp_ID
	FROM PresentData
	GROUP BY For_Date,Emp_ID
) Q ON DT.Emp_ID = Q.Emp_ID AND Dt.For_Date = Q.For_Date

--select * From PresentData 
--SELECT * FROM PresentData_temp1
return

TRUNCATE TABLE #Data 
INSERT INTO #data
SELECT * FROM PresentData_temp1


--This sp retrieves the Shift Rotation as per given employee id and effective date.
--it will fetch all employee's shift rotation detail if employee id is not specified.
IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
	CREATE TABLE #Rotation (
		R_EmpID NUMERIC(18, 0)
		,R_DayName VARCHAR(25)
		,R_ShiftID NUMERIC(18, 0)
		,R_Effective_Date DATETIME
	);

--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
IF EXISTS (SELECT 1 FROM T0050_Emp_Monthly_Shift_Rotation ROT INNER JOIN #Emp_Cons EC ON ROT.Emp_ID = EC.Emp_ID)
	EXEC dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID ,NULL ,@To_Date ,@constraint


UPDATE #Data SET SHIFT_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, Emp_Id, For_date);

UPDATE #Data
SET Shift_Start_Time = CASE 
		WHEN Is_Half_Day = 1 AND DATENAME(WEEKDAY, FOR_DATE) = Week_Day THEN ISNULL(Half_ST_Time, q.Shift_St_Time) ELSE q.Shift_St_Time END
	,OT_Start_Time = isnull(q.OT_Start_Time, 0)
	,Shift_End_Time = CASE 
		WHEN Is_Half_Day = 1 AND DATENAME(WEEKDAY, FOR_DATE) = Week_Day THEN ISNULL(Half_End_Time, q.Shift_End_Time)
		ELSE q.Shift_End_Time END
	,OT_End_Time = isnull(q.OT_End_Time, 0)
	,Working_Hrs_St_Time = q.Working_Hrs_St_Time
	,Working_Hrs_End_Time = isnull(q.Working_Hrs_End_Time, 0)
FROM #data d
INNER JOIN (
	SELECT ST.Shift_st_time
		,ST.Shift_ID
		,ISNULL(SD.OT_Start_Time, 0) AS OT_Start_Time
		,ST.Shift_End_Time
		,ISNULL(SD.OT_End_Time, 0) AS OT_End_Time
		,Sd.Working_Hrs_St_Time
		,sd.Working_Hrs_End_Time
		,ST.Half_ST_Time
		,ST.Half_End_Time
		,ST.Week_Day
		,ST.Is_Half_Day
	FROM dbo.t0040_shift_master ST
	LEFT JOIN dbo.t0050_shift_detail SD ON ST.Shift_ID = SD.Shift_ID
	WHERE St.Cmp_ID = @Cmp_ID
	) q ON d.shift_id = q.shift_id

--Update #Data set Shift_End_Time = Case When Shift_Start_Time > Shift_End_Time or Datepart(hour,Shift_Start_Time)=0 Then  -- Or Condition added by Hardik 20/11/2015 for 12:00 Night shift for Nirma
--Commented Above Code and New Code of Shift End Time is Added By Ramiz on 19/12/2016 Bcoz if Outtime is on Same Day then Shift Out Time was Coming Incorrect--
UPDATE #Data
SET Shift_End_Time = CASE 
		WHEN Shift_Start_Time > Shift_End_Time
			OR Datepart(hour, Shift_Start_Time) = 0
			THEN -- Or Condition added by Hardik 20/11/2015 for 12:00 Night shift for Nirma
				CASE 
					WHEN (CONVERT(VARCHAR, IN_TIME, 111) = CONVERT(VARCHAR, OUT_TIME, 111))
						AND (CONVERT(VARCHAR(8), IN_TIME, 108) < CONVERT(VARCHAR(8), OUT_Time, 108))
						THEN CAST(CONVERT(VARCHAR(11), OUT_TIME + 1, 121) + CONVERT(VARCHAR(12), SHIFT_END_TIME, 114) AS DATETIME)
					ELSE CAST(CONVERT(VARCHAR(11), OUT_TIME, 121) + CONVERT(VARCHAR(12), SHIFT_END_TIME, 114) AS DATETIME)
					END
		ELSE
			--cast(CONVERT(VARCHAR(11), In_Time, 121)  + CONVERT(VARCHAR(12), Shift_End_Time, 114) as datetime) End  --Commented by Hardik 27/07/2016 as Normal Shift Time not coming when In and Out Punch is not there
			CAST(CONVERT(VARCHAR(11), For_Date, 121) + CONVERT(VARCHAR(12), Shift_End_Time, 114) AS DATETIME)
		END
FROM #Data

--Code Ended By Ramiz on 19/12/2016
UPDATE #Data
SET Shift_Start_Time = CASE 
		WHEN Datepart(hour, Shift_Start_Time) = 0
			THEN 
				cast(CONVERT(VARCHAR(11), OUT_Time, 121) + CONVERT(VARCHAR(12), Shift_Start_Time, 114) AS DATETIME)
		ELSE
			cast(CONVERT(VARCHAR(11), For_date, 121) + CONVERT(VARCHAR(12), Shift_Start_Time, 114) AS DATETIME)
		END
FROM #Data


UPDATE #Data
SET Shift_Change = 1
WHERE ABS(isnull(datediff(s, in_time, Shift_Start_Time), 0)) > 18000
	AND IsNull(Chk_By_Superior, 0) <> 1
	AND CASE 
		WHEN Shift_Start_Time > Shift_End_Time
			THEN 0
		ELSE datediff(HH, Shift_Start_Time, Shift_End_Time)
		END < 23

UPDATE #Data
SET Shift_Change = 0
WHERE ABS(isnull(datediff(s, OUT_Time, Shift_End_Time), 0)) < 18000 AND Shift_Change = 1 

UPDATE #temp_In_Out_Time
SET Shift_End_Time = d.Shift_End_Time
	,Shift_Start_Time = d.Shift_Start_Time
FROM #data d
LEFT JOIN #temp_In_Out_Time t ON t.For_date = d.For_date
	AND t.Emp_Id = d.Emp_Id
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
WHERE First_In_Last_Out_For_InOut_Calculation = 0

UPDATE TIO
SET Working_Hrs_St_Time = q.Working_Hrs_St_Time
	,Working_Hrs_End_Time = isnull(q.Working_Hrs_End_Time, 0)
FROM #temp_In_Out_Time TIO
INNER JOIN #data d ON TIO.Emp_ID = d.Emp_ID
	AND TIO.For_Date = d.For_Date
INNER JOIN (
	SELECT ST.Shift_st_time
		,ST.Shift_ID
		,ISNULL(SD.OT_Start_Time, 0) AS OT_Start_Time
		,ST.Shift_End_Time
		,ISNULL(SD.OT_End_Time, 0) AS OT_End_Time
		,Sd.Working_Hrs_St_Time
		,sd.Working_Hrs_End_Time
	FROM dbo.t0040_shift_master ST
	LEFT JOIN dbo.t0050_shift_detail SD ON ST.Shift_ID = SD.Shift_ID
	WHERE St.Cmp_ID = @Cmp_ID
	) q ON d.shift_id = q.shift_id
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
WHERE First_In_Last_Out_For_InOut_Calculation = 0

UPDATE #temp_In_Out_Time
SET OUT_Time = CASE 
		WHEN OUT_Time > Shift_End_Time
			THEN Shift_End_Time
		ELSE OUT_Time
		END
FROM #temp_In_Out_Time t
INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID = ES.EMP_ID
WHERE First_In_Last_Out_For_InOut_Calculation = 0
	AND t.Working_Hrs_End_Time = 1

UPDATE #temp_In_Out_Time
SET In_Time = CASE 
		WHEN In_Time < Shift_Start_Time
			THEN Shift_Start_Time
		ELSE In_Time
		END
FROM #temp_In_Out_Time t
INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID = ES.EMP_ID
WHERE First_In_Last_Out_For_InOut_Calculation = 0
	AND t.Working_Hrs_St_Time = 1

UPDATE #temp_In_Out_Time
SET In_Time = CASE 
		WHEN In_Time > Shift_End_Time
			AND OUT_Time = Shift_End_Time
			THEN Shift_End_Time
		ELSE In_Time
		END
FROM #temp_In_Out_Time t
INNER JOIN #EMP_GEN_SETTINGS ES ON t.EMP_ID = ES.EMP_ID
WHERE First_In_Last_Out_For_InOut_Calculation = 0 AND t.Working_Hrs_End_Time = 1

SELECT * ,Duration_in_sec AS TotalWorkDur INTO #Data_DURCAL FROM #DATA

UPDATE #Data_DURCAL SET TotalWorkDur = DATEDIFF(s, In_Time, IsNull(Out_Time, In_Time))

UPDATE D
SET Duration_in_sec = DATEDIFF(s, d.Shift_Start_Time, d.OUT_Time)
FROM #Data_DURCAL d
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
WHERE Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 0 AND In_Time < d.Shift_Start_Time 

UPDATE D
SET Duration_in_sec = DATEDIFF(s, In_Time, d.Shift_End_Time)
FROM #Data_DURCAL d
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
WHERE d.Working_Hrs_St_Time = 0 AND d.Working_Hrs_End_Time = 1 AND OUT_Time > d.Shift_End_Time 

UPDATE D
SET Duration_in_sec = (
		CASE 
			WHEN In_Time < Shift_Start_Time
				AND OUT_Time > Shift_End_Time
				THEN DATEDIFF(s, d.Shift_Start_Time, d.Shift_End_Time)
			ELSE CASE 
					WHEN In_Time < Shift_Start_Time
						THEN DATEDIFF(s, d.Shift_Start_Time, OUT_Time)
					ELSE CASE 
							WHEN OUT_Time > Shift_End_Time
								THEN DATEDIFF(s, In_Time, d.Shift_End_Time)
							ELSE DATEDIFF(s, In_Time, OUT_Time)
							END
					END
			END
		)
FROM #Data_DURCAL d
LEFT JOIN #EMP_HW_CONS EHW ON d.Emp_Id = EHW.Emp_ID
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
WHERE d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND ISNULL(CHARINDEX(cast(d.For_date AS VARCHAR(11)), ehw.WeekOffDate), 0) = 0 AND ISNULL(CHARINDEX(cast(d.For_date AS VARCHAR(11)), ehw.HolidayDate), 0) = 0


UPDATE D
SET Duration_in_sec = D.Duration_in_sec
	,OT_Sec = DD.TotalWorkDur - D.Duration_in_sec
FROM #DATA D
INNER JOIN #Data_DURCAL DD ON D.Emp_Id = DD.Emp_Id AND D.For_date = DD.For_date
WHERE d.Working_Hrs_St_Time = 1 AND d.Working_Hrs_End_Time = 1 AND D.OT_Start_Time = 0 AND D.OT_End_Time = 1 
--Deepal Comment on 18062021	


UPDATE D
SET Duration_in_sec = D.Duration_in_sec
	,OT_Sec = DATEDIFF(s, d.Shift_End_Time, d.OUT_Time)
FROM #DATA D
INNER JOIN #Data_DURCAL DD ON D.Emp_Id = DD.Emp_Id
	AND D.For_date = DD.For_date
WHERE d.Working_Hrs_St_Time = 1
	AND d.Working_Hrs_End_Time = 1
	AND D.OT_Start_Time = 1
	AND D.OT_End_Time = 1


UPDATE D
SET Duration_in_sec = D.Duration_in_sec
	,OT_Sec = DATEDIFF(s, d.In_Time, d.Shift_Start_Time)
FROM #DATA D
INNER JOIN #Data_DURCAL DD ON D.Emp_Id = DD.Emp_Id
	AND D.For_date = DD.For_date
WHERE d.Working_Hrs_St_Time = 1
	AND d.Working_Hrs_End_Time = 1
	AND D.OT_Start_Time = 0
	AND D.OT_End_Time = 0


UPDATE D
SET Duration_in_sec = DATEDIFF(s, DD.In_Time, IsNull(DD.Out_Time, DD.In_Time))
	,OT_Sec = (D.Duration_in_sec - DATEDIFF(s, d.Shift_Start_Time, d.Shift_END_Time)) - DATEDIFF(s, d.In_Time, d.Shift_Start_Time)
FROM #DATA D
INNER JOIN #Data_DURCAL DD ON D.Emp_Id = DD.Emp_Id
	AND D.For_date = DD.For_date
WHERE d.Working_Hrs_St_Time = 0
	AND d.Working_Hrs_End_Time = 0
	AND D.OT_Start_Time = 1
	AND D.OT_End_Time = 0


UPDATE D
SET Duration_in_sec = D.Duration_in_sec
	,OT_Sec = (D.Duration_in_sec - DATEDIFF(s, d.Shift_Start_Time, d.Shift_END_Time))
FROM #DATA D
INNER JOIN #Data_DURCAL DD ON D.Emp_Id = DD.Emp_Id
	AND D.For_date = DD.For_date
WHERE d.Working_Hrs_St_Time = 1
	AND d.Working_Hrs_End_Time = 0
	AND D.OT_Start_Time = 1
	AND D.OT_End_Time = 0


UPDATE #Data
SET P_days = 1
	,
	in_time = CASE 
		WHEN @Return_Record_set IN (
				9
				,10
				,11
				,12
				,13
				,14
				,15
				,16
				)
			THEN CASE 
					WHEN Is_Cancel_Late_In = 1
						THEN CASE 
								WHEN d.in_time > CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time
									THEN CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_st_time
								ELSE d.In_Time
								END
					ELSE d.In_Time
					END
		ELSE CASE 
				WHEN Is_Default_In = 1
					THEN NULL
				ELSE d.In_Time
				END
		END
	,out_time = CASE 
		WHEN @Return_Record_set IN (
				9
				,10
				,11
				,12
				,13
				,14
				,15
				,16
				)
			THEN CASE 
					WHEN Is_Cancel_Early_Out = 1
						THEN CASE 
								WHEN d.Out_Time < CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time
									THEN CONVERT(VARCHAR(11), d.For_date, 120) + sm.shift_end_time
								ELSE d.Out_Time
								END
					ELSE d.Out_Time
					END
		ELSE CASE 
				WHEN Is_Default_Out = 1
					THEN NULL
				ELSE d.Out_Time
				END
		END
	,duration_in_sec = CASE 
		WHEN @Return_Record_set IN (
				9
				,10
				,11
				,12
				,14
				,15
				,16
				)
			THEN --Remove 13 number set for getting regularized compoff date  Mr.Mehul on 12-04-2023
				dbo.F_Return_Sec(sm.shift_dur)
		WHEN @Return_Record_set IN (13)
			THEN 
				dbo.F_Return_Sec(TEIR.Duration)
		ELSE DATEDIFF(s, CASE 
					WHEN Is_Default_In = 1
						THEN NULL
					ELSE d.In_Time
					END, CASE 
					WHEN Is_Default_Out = 1
						THEN NULL
					ELSE d.Out_Time
					END)
		END
FROM #Data d
INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
	AND TEIR.Chk_By_Superior = 1
	AND TEIR.For_Date = d.For_date
	AND TEIR.Half_Full_day = 'Full Day'
INNER JOIN T0040_SHIFT_MASTER SM ON d.shift_id = SM.shift_id
WHERE TEIR.For_Date >= @From_Date
	AND TEIR.For_Date <= @To_Date
	AND d.IO_Tran_Id = 0

UPDATE #Data
SET In_Time = TEIR.In_Time
	,OUT_Time = TEIR.Out_Time
	,duration_in_sec = dbo.F_Return_Sec(TEIR.Duration)
FROM #Data d
INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
	AND TEIR.Chk_By_Superior = 1
	AND TEIR.For_Date = d.For_date
	AND TEIR.Half_Full_day = 'Full Day'
INNER JOIN T0040_SHIFT_MASTER SM ON d.shift_id = SM.shift_id
WHERE P_days = 1
	AND D.In_Time IS NULL
	AND D.OUT_Time IS NULL
	AND Reason <> ''
	AND TEIR.For_Date >= @From_Date
	AND TEIR.For_Date <= @To_Date
	AND d.IO_Tran_Id = 0


UPDATE #Data
SET P_days = 0.5
	,in_time = CASE 
		WHEN ISNULL(d.in_time, '01-01-1900') = '01-01-1900'
			THEN convert(VARCHAR(11), d.For_date, 120) + sm.shift_st_time
		ELSE d.in_time
		END
	,out_time = CASE 
		WHEN ISNULL(d.out_time, '01-01-1900') = '01-01-1900'
			THEN CASE 
					WHEN (dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2) > 86400
						THEN (convert(VARCHAR(11), dateadd(dd, 1, d.For_date), 120) + dbo.F_Return_Hours((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2) - 86400))
					ELSE (convert(VARCHAR(11), d.For_date, 120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2))
					END
		ELSE d.out_time
		END
	,duration_in_sec = DATEDIFF(s,
		CASE 
			WHEN ISNULL(d.in_time, '01-01-1900') = '01-01-1900'
				THEN convert(VARCHAR(11), d.For_date, 120) + sm.shift_st_time
			ELSE d.in_time
			END, cast(CASE 
				WHEN ISNULL(d.out_time, '01-01-1900') = '01-01-1900'
					THEN CASE 
							WHEN (dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2) > 86400
								THEN (convert(VARCHAR(11), dateadd(dd, 1, d.For_date), 120) + dbo.F_Return_Hours((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2) - 86400))
							ELSE (convert(VARCHAR(11), d.For_date, 120) + dbo.F_Return_Hours(dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2))
							END
				ELSE d.out_time
				END AS DATETIME))
FROM #Data d
INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
	AND TEIR.Chk_By_Superior = 1
	AND TEIR.For_Date = d.For_date
	AND (TEIR.Half_Full_day = 'First Half')
INNER JOIN T0040_SHIFT_MASTER SM ON d.Shift_ID = SM.shift_id
WHERE TEIR.For_Date >= @From_Date
	AND TEIR.For_Date <= @To_Date
	AND d.IO_Tran_Id = 0


UPDATE #Data
SET P_days = 0.5
	,in_time = CASE 
		WHEN ISNULL(d.in_time, '01-01-1900') = '01-01-1900'
			THEN DATEADD(s, CAST((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2) AS NUMERIC(9, 2)), d.For_date)
		ELSE d.in_time
		END
	,out_time = CASE 
		WHEN ISNULL(d.out_time, '01-01-1900') = '01-01-1900'
			THEN DATEADD(s, dbo.F_Return_Sec(sm.shift_dur), Convert(DATETIME, Convert(CHAR(10), d.For_date, 103) + ' ' + sm.shift_st_time, 103))
		ELSE d.out_time
		END
	,duration_in_sec = DATEDIFF(s,
		CASE 
			WHEN ISNULL(d.in_time, '01-01-1900') = '01-01-1900'
				THEN DATEADD(s, CAST((dbo.F_Return_Sec(sm.shift_st_time) + (dbo.F_Return_Sec(sm.shift_dur)) / 2) AS NUMERIC(9, 2)), d.For_date)
			ELSE d.in_time
			END, cast(CASE 
				WHEN ISNULL(d.out_time, '01-01-1900') = '01-01-1900'
					THEN DATEADD(s, dbo.F_Return_Sec(sm.shift_dur), Convert(DATETIME, Convert(CHAR(10), d.For_date, 103) + ' ' + sm.shift_st_time, 103))
				ELSE d.out_time
				END AS DATETIME))
FROM #Data d
INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
	AND TEIR.Chk_By_Superior = 1
	AND TEIR.For_Date = d.For_date
	AND (TEIR.Half_Full_day = 'Second Half')
INNER JOIN T0040_SHIFT_MASTER SM ON d.Shift_ID = SM.shift_id
WHERE TEIR.For_Date >= @From_Date
	AND TEIR.For_Date <= @To_Date
	AND d.IO_Tran_Id = 0


DECLARE @Emp_ID_AutoShift NUMERIC
DECLARE @In_Time_Autoshift DATETIME
DECLARE @Out_Time_Autoshift DATETIME 
DECLARE @New_Shift_ID NUMERIC
DECLARE @AUTO_SHIFT_GRPID AS TINYINT

IF EXISTS (
		SELECT 1
		FROM T0040_SHIFT_MASTER s
		WHERE Isnull(s.Inc_Auto_Shift, 0) = 1
			AND s.Cmp_ID = @Cmp_id
		)
BEGIN
	DECLARE curautoshift CURSOR FAST_FORWARD
	FOR
		SELECT d.Emp_ID
			,d.In_Time
			,d.Out_Time
			,d.Shift_ID
		FROM #Data d
		INNER JOIN T0040_SHIFT_MASTER s ON d.Shift_ID = s.Shift_ID
		WHERE Isnull(s.Inc_Auto_Shift, 0) = 1
		ORDER BY In_time ,Emp_ID
	OPEN curautoshift

	FETCH NEXT
	FROM curautoshift
	INTO @Emp_ID_AutoShift
		,@In_Time_Autoshift
		,@Out_Time_Autoshift
		,@New_Shift_ID

	WHILE @@fetch_status = 0
	BEGIN
		DECLARE @Shift_ID_Autoshift NUMERIC
		DECLARE @Shift_start_time_Autoshift VARCHAR(12)
		DECLARE @Shift_End_time_Autoshift VARCHAR(12)
		
		SELECT @AUTO_SHIFT_GRPID = ISNULL(Auto_Shift_Group, 0)
		FROM T0040_SHIFT_MASTER
		WHERE SHIFT_ID = @New_Shift_ID

		SELECT TOP 1 @Shift_ID_Autoshift = Shift_ID
			,@Shift_start_time_Autoshift = Shift_St_Time
			,@Shift_End_time_Autoshift = Shift_End_Time
		FROM T0040_SHIFT_MASTER
		WHERE Cmp_ID = @Cmp_ID
			AND Auto_Shift_Group = @AUTO_SHIFT_GRPID
			AND Isnull(Inc_Auto_Shift, 0) = 1
		ORDER BY ABS(datediff(s, @In_Time_Autoshift, cast(CONVERT(VARCHAR(11), CASE 
								WHEN DATEPART(hh, Shift_St_Time) = 0
									AND DATEPART(hh, @In_Time_Autoshift) <> 0
									THEN DATEADD(dd, 1, @In_Time_Autoshift)
								ELSE @In_Time_Autoshift
								END, 121) + CONVERT(VARCHAR(12), Shift_St_Time, 114) AS DATETIME)))

		IF ISNULL(@SHIFT_ID_AUTOSHIFT, 0) > 0
			AND (CAST(CONVERT(VARCHAR(11), @IN_TIME_AUTOSHIFT, 121) AS DATE) < CAST(CONVERT(VARCHAR(11), @OUT_TIME_AUTOSHIFT, 121) AS DATE))
		BEGIN
			IF (@SHIFT_START_TIME_AUTOSHIFT < @SHIFT_END_TIME_AUTOSHIFT)
			BEGIN
				UPDATE #Data
				SET Shift_ID = @Shift_ID_Autoshift
					,Shift_Start_Time = CAST(CONVERT(VARCHAR(11), In_time, 121) + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) AS DATETIME)
					,Shift_End_Time = CAST(CONVERT(VARCHAR(11), In_time, 121) + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) AS DATETIME)
				FROM #Data
				WHERE Emp_ID = @Emp_ID_AutoShift
					AND In_time = @In_Time_Autoshift
					AND Shift_ID <> @Shift_ID_Autoshift
			END
			ELSE
			BEGIN
				UPDATE #Data
				SET Shift_ID = @Shift_ID_Autoshift
					,Shift_Start_Time = CAST(CONVERT(VARCHAR(11), In_time, 121) + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) AS DATETIME)
					,Shift_End_Time = CAST(CONVERT(VARCHAR(11), For_date + 1, 121) + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) AS DATETIME)
				FROM #Data
				WHERE Emp_ID = @Emp_ID_AutoShift
					AND In_time = @In_Time_Autoshift
					AND Shift_ID <> @Shift_ID_Autoshift
			END
		END
		ELSE IF isnull(@Shift_ID_Autoshift, 0) > 0 
		BEGIN
			UPDATE #Data
			SET Shift_ID = @Shift_ID_Autoshift
				,Shift_Start_Time = CAST(CONVERT(VARCHAR(11), In_time, 121) + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) AS DATETIME)
				,Shift_End_Time = CAST(CONVERT(VARCHAR(11), Coalesce(OUT_Time, In_Time, For_Date), 121) + CONVERT(VARCHAR(12), @Shift_End_time_Autoshift, 114) AS DATETIME)
			FROM #Data
			WHERE Emp_ID = @Emp_ID_AutoShift
				AND In_time = @In_Time_Autoshift
				AND Shift_ID <> @Shift_ID_Autoshift
		END
		
		FETCH NEXT
		FROM curautoshift
		INTO @Emp_ID_AutoShift ,@In_Time_Autoshift ,@Out_Time_Autoshift ,@New_Shift_ID
	END

	CLOSE curautoshift
	DEALLOCATE curautoshift
	
	UPDATE #Data
	SET OT_Start_Time = isnull(q.OT_Start_Time, 0)
		,OT_End_Time = isnull(q.OT_End_Time, 0)
	FROM #data d
	INNER JOIN (
		SELECT ST.Shift_st_time
			,ST.Shift_ID
			,isnull(SD.OT_Start_Time, 0) AS OT_Start_Time
			,isnull(SD.OT_End_Time, 0) AS OT_End_Time
		FROM dbo.t0040_shift_master ST
		LEFT JOIN dbo.t0050_shift_detail SD ON ST.Shift_ID = SD.Shift_ID
		WHERE St.Cmp_ID = @Cmp_ID
		) q ON d.shift_id = q.shift_id
	WHERE isnull(d.shift_Change, 0) = 1
END

CREATE TABLE #Emp_WeekOFf_Detail (
	Emp_ID NUMERIC
	,StrWeekoff_Holiday VARCHAR(max)
	,StrWeekoff VARCHAR(max)
	,StrHoliday VARCHAR(max)
	,strHalfday_Holiday VARCHAR(max) 
	)

INSERT INTO #Emp_WeekOFf_Detail
SELECT Emp_ID
	,IsNull(WeekOffDate, '') + IsNull(HolidayDate, '')
	,WeekOffDate
	,HolidayDate
	,HalfHolidayDate
FROM #EMP_HW_CONS


DELETE D
FROM #Emp_WeekOFf_Detail D
WHERE NOT EXISTS (
		SELECT Emp_ID
		FROM #Data t
		WHERE t.Emp_Id = D.Emp_ID
) 

DECLARE @Weekoff_Days NUMERIC(12, 1)
DECLARE @Cancel_Weekoff NUMERIC(12, 1)
DECLARE @Week_oF_Branch NUMERIC(18, 0)
DECLARE @tras_week_ot TINYINT
DECLARE @Auto_OT TINYINT
DECLARE @OT_Present TINYINT
DECLARE @Is_Cancel_Weekoff NUMERIC(1, 0)
DECLARE @Is_WD NUMERIC
DECLARE @Is_WOHO NUMERIC
DECLARE @Is_HO_CompOff NUMERIC 
DECLARE @Is_W_CompOff NUMERIC

SET @OT_Present = 0

DECLARE @Emp_Week_Detail NUMERIC(18, 0)
DECLARE @strweekoff VARCHAR(max)

IF @Return_Record_set = 5
BEGIN
	INSERT INTO #Data_Weekoff
	SELECT E.Emp_ID
		,E.WeekOffCount
	FROM #EMP_HW_CONS E
END

/*Added following query by Nimesh on 30-Sep-2016 (Removed cursor from below to optimize the performance)*/
UPDATE D
SET Duration_in_sec = 0
	,
	--OT_Sec = dbo.F_Return_Without_Sec(T.OT_Sec + T.Duration_in_sec), -- Commeted By Sajid 20092023
	OT_Sec = dbo.F_Return_Without_Sec(T.Duration_in_sec)
	,-- Added By Sajid 20092023
	P_Days = 0
FROM #DATA D
INNER JOIN (
	SELECT D1.EMP_ID
		,FOR_DATE
		,OT_SEC
		,DURATION_IN_SEC
	FROM #DATA D1
	INNER JOIN #EMP_GEN_SETTINGS G ON D1.Emp_Id = G.EMP_ID --Modified by by Chetan 050617 (WeeOff & Holiday Work was getting transfered to OT even not selecting option in general settings)
	WHERE (
			(
				NOT EXISTS (
					SELECT 1
					FROM #EMP_HOLIDAY H1
					WHERE D1.EMP_ID = H1.EMP_ID
						AND D1.FOR_DATE = H1.FOR_DATE
						AND H1.IS_CANCEL = 0
						AND H1.IS_HALF = 1
					)
				AND EXISTS (
					SELECT 1
					FROM #EMP_HOLIDAY H1
					WHERE D1.EMP_ID = H1.EMP_ID
						AND D1.FOR_DATE = H1.FOR_DATE
						AND H1.IS_CANCEL = 0
					)
				)
			OR EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF W1
				WHERE D1.EMP_ID = W1.EMP_ID
					AND D1.FOR_DATE = W1.FOR_DATE
					AND (
						W1.IS_CANCEL = 0
						OR EXISTS (
							SELECT 1
							FROM T0100_WEEKOFF_ROSTER WR
							WHERE WR.FOR_DATE = W1.For_Date
								AND WR.EMP_ID = W1.EMP_ID
								AND WR.is_Cancel_WO = 1
							)
						)
				)
			)
		AND G.Tras_Week_OT = 1
	) T ON D.EMP_ID = T.EMP_ID
	AND D.FOR_DATE = T.FOR_DATE
WHERE D.Emp_OT = 1 
-- EMP OT Condition Added By Ramiz (05/12/2016) 

DECLARE @Emp_Id_Temp1 NUMERIC
DECLARE @Weekoff_Date1 AS VARCHAR(max)
DECLARE @Half_Holiday_Date AS VARCHAR(max)
DECLARE @Weekoff_Date1_Cancel AS VARCHAR(max)
DECLARE @Holiday_Date1_Cancel AS VARCHAR(max)
DECLARE @Weekoff_Date1_CancelStr AS VARCHAR(MAX)
DECLARE @Shift_ID NUMERIC
DECLARE @From_Hour NUMERIC(12, 3)
DECLARE @To_Hour NUMERIC(12, 3)
DECLARE @Minimum_hour NUMERIC(12, 3)
DECLARE @Calculate_days NUMERIC(12, 3)
DECLARE @OT_applicable NUMERIC(1)
DECLARE @Fix_OT_Hours NUMERIC(12, 3)
DECLARE @Shift_Dur VARCHAR(10)
DECLARE @Shift_Dur_sec NUMERIC
DECLARE @Fix_W_Hours NUMERIC(5, 2)
DECLARE @Ot_Sec_Neg NUMERIC(18, 0) --Nikunj
--Ankit 15112013
DECLARE @DeduHour_SecondBreak AS TINYINT
DECLARE @DeduHour_ThirdBreak AS TINYINT
DECLARE @S_St_Time AS VARCHAR(10)
DECLARE @S_End_Time AS VARCHAR(10)
DECLARE @T_St_Time AS VARCHAR(10)
DECLARE @T_End_Time AS VARCHAR(10)
DECLARE @Second_Break_Duration AS VARCHAR(10)
DECLARE @Third_Break_Duration AS VARCHAR(10)
DECLARE @Second_Break_Duration_Sec AS NUMERIC
DECLARE @Third_Break_Duration_Sec AS NUMERIC
DECLARE @HalfDayDate1 VARCHAR(max)

--Ankit 15112013    
--PRINT 'CALC 10 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
--Added By Mukti 28112014(start) to deduct Break hours
DECLARE Cur_Break CURSOR
FOR
SELECT DISTINCT shift_id
	,DeduHour_SecondBreak
	,DeduHour_ThirdBreak
	,Shift_Dur
	,S_Duration
	,T_Duration
	,S_St_Time
	,T_St_Time
FROM T0040_shift_master
WHERE shift_id IN (
		SELECT DISTINCT Shift_ID
		FROM #Data
		)

OPEN Cur_Break

FETCH NEXT
FROM Cur_Break
INTO @shift_ID
	,@DeduHour_SecondBreak
	,@DeduHour_ThirdBreak
	,@Shift_Dur
	,@Second_Break_Duration
	,@Third_Break_Duration
	,@S_St_Time
	,@T_St_Time

WHILE @@Fetch_Status = 0
BEGIN
	EXEC GET_HalfDay_Date @Cmp_ID
		,@Emp_Id_Temp1
		,@From_Date
		,@To_Date
		,0
		,@HalfDayDate1 OUTPUT

	SELECT @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur)

	SELECT @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)

	SELECT @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)

	IF @DeduHour_SecondBreak = 1
		AND @DeduHour_ThirdBreak = 1
	BEGIN
		IF @DeduHour_SecondBreak = 1
		BEGIN
			UPDATE #Data
			SET Duration_In_Sec = Duration_In_Sec - @Second_Break_Duration_Sec
			WHERE Shift_ID = @Shift_ID
				AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
				AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
				AND Duration_in_sec > 0
				AND For_Date NOT IN (
					SELECT Data
					FROM dbo.Split(@HalfDayDate1, ';')
					WHERE DATA <> ''
					)

			-- For OT	
			UPDATE #Data
			SET OT_Sec = OT_Sec - @Second_Break_Duration_Sec
			WHERE Shift_ID = @Shift_ID
				AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
				AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
				AND Duration_in_sec = 0
				AND OT_Sec > 0
				--and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'') 							 		
		END

		IF @DeduHour_ThirdBreak = 1
		BEGIN
			UPDATE #Data
			SET Duration_In_Sec = Duration_In_Sec - @Third_Break_Duration_Sec
			WHERE Shift_ID = @Shift_ID
				AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
				AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
				AND Duration_in_sec > 0
				AND For_Date NOT IN (
					SELECT Data
					FROM dbo.Split(@HalfDayDate1, ';')
					WHERE DATA <> ''
					)

			-- For OT
			UPDATE #Data
			SET OT_Sec = OT_Sec - @Third_Break_Duration_Sec
			WHERE Shift_ID = @Shift_ID
				AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
				AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
				AND Duration_in_sec = 0
				AND OT_Sec > 0
				--and For_Date not In (Select Data from dbo.Split(@HalfDayDate1,';') where DATA<>'')
		END
	END
	ELSE IF @DeduHour_SecondBreak = 1
	BEGIN
		UPDATE #Data
		SET Duration_In_Sec = Duration_In_Sec - CASE 
				WHEN @Second_Break_Duration_Sec >= Datediff(ss, cast(cast(For_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME), OUT_Time)
					THEN Datediff(ss, cast(cast(For_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME), OUT_Time)
				ELSE @Second_Break_Duration_Sec
				END
		WHERE Shift_ID = @Shift_ID
			AND In_Time < cast(cast(For_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
			AND OUT_Time > cast(cast(For_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
			AND Duration_in_sec > 0
			AND For_Date NOT IN (
				SELECT Data
				FROM dbo.Split(@HalfDayDate1, ';')
				WHERE DATA <> ''
				)
			---- For OT	
			--Update #Data Set OT_Sec = OT_Sec - @Second_Break_Duration_Sec
			--	Where Shift_ID = @Shift_ID 
			--	And In_Time < cast(cast(In_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime) And OUT_Time > cast(cast(OUT_Time as varchar(11)) + ' ' + @S_St_Time as smalldatetime)
			--	And Duration_in_sec = 0	And OT_Sec > 0	
	END
	ELSE IF @DeduHour_ThirdBreak = 1
	BEGIN
		UPDATE #Data
		SET Duration_In_Sec = Duration_In_Sec - @Third_Break_Duration_Sec
		WHERE Shift_ID = @Shift_ID
			AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
			AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
			AND Duration_in_sec > 0
			AND For_Date NOT IN (
				SELECT Data
				FROM dbo.Split(@HalfDayDate1, ';')
				WHERE DATA <> ''
				)

		-- For OT
		UPDATE #Data
		SET OT_Sec = OT_Sec - @Third_Break_Duration_Sec
		WHERE Shift_ID = @Shift_ID
			AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
			AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
			AND Duration_in_sec = 0
			AND OT_Sec > 0
			AND For_Date NOT IN (
				SELECT Data
				FROM dbo.Split(@HalfDayDate1, ';')
				WHERE DATA <> ''
				)
	END

	FETCH NEXT
	FROM Cur_Break
	INTO @shift_ID
		,@DeduHour_SecondBreak
		,@DeduHour_ThirdBreak
		,@Shift_Dur
		,@Second_Break_Duration
		,@Third_Break_Duration
		,@S_St_Time
		,@T_St_Time
END

CLOSE Cur_Break

DEALLOCATE Cur_Break


DECLARE @Is_Negative_Ot INT ---For negative yes or no take its value from general setting
DECLARE @OT_Applicable_Grade AS TINYINT

SET @OT_Applicable_Grade = 0


DECLARE @HalfWeekDay VARCHAR(12)
DECLARE @HalfDayMinDur VARCHAR(8)

SELECT sd.Shift_ID
	,From_Hour
	,To_Hour
	,Minimum_hour
	,Calculate_days
	,OT_applicable
	,Fix_OT_Hours
	,Shift_Dur
	,isnull(Fix_W_Hours, 0) AS Fix_W_Hours
	,DeduHour_SecondBreak
	,DeduHour_ThirdBreak
	,S_St_Time
	,S_End_Time
	,S_Duration
	,T_St_Time
	,T_End_Time
	,T_Duration
	,CASE 
		WHEN Is_Half_Day = 1
			THEN Week_Day
		ELSE ''
		END AS HalfDay
	,Half_min_duration
INTO #Shift_Detail
FROM dbo.T0050_shift_detail sd
INNER JOIN dbo.T0040_shift_master sm ON sd.shift_ID = sm.Shift_ID
INNER JOIN (
	SELECT DISTINCT Shift_ID
	FROM #Data
	) q ON sm.shift_Id = q.shift_ID
ORDER BY sd.shift_Id
	,From_Hour


CREATE TABLE #DATA_JOIN (
	EMP_ID NUMERIC
	,FOR_DATE DATETIME
	)

INSERT INTO #DATA_JOIN
SELECT EMP_ID
	,FOR_DATE
FROM #Data

UPDATE_LATE_DAYS:

IF OBJECT_ID('tempdb..#Extra_Exempted') IS NOT NULL
BEGIN
	TRUNCATE TABLE #DATA_JOIN

	INSERT INTO #DATA_JOIN
	SELECT EMP_ID
		,FOR_DATE
	FROM #Extra_Exempted
END

-- Cliantha --			
IF EXISTS (
		SELECT 1
		FROM T0140_LEAVE_TRANSACTION LT
		INNER JOIN T0040_LEAVE_MASTER L ON LT.Leave_Id = L.Leave_ID
			AND LT.Cmp_ID = L.Cmp_ID
		INNER JOIN #Data D ON LT.Emp_Id = D.Emp_Id
		WHERE Isnull(L.Add_In_Working_Hour, 0) = 1
			AND LT.Leave_Used > 0
		)
BEGIN
	UPDATE D
	SET Duration_in_sec = Duration_in_sec + dbo.f_return_sec(Replace(LT.Leave_Used, '.', ':'))
	FROM T0140_LEAVE_TRANSACTION LT
	INNER JOIN T0040_LEAVE_MASTER L ON LT.Leave_Id = L.Leave_ID
		AND LT.Cmp_ID = L.Cmp_ID
	INNER JOIN #Data D ON LT.Emp_Id = D.Emp_Id
		AND LT.For_Date = D.For_date
	WHERE Isnull(L.Add_In_Working_Hour, 0) = 1
		AND LT.Leave_Used > 0
END

DECLARE Cur_shift CURSOR FAST_FORWARD
FOR
SELECT *
FROM #Shift_Detail
ORDER BY shift_Id
	,FROM_HOUR

OPEN cur_shift

FETCH NEXT
FROM cur_Shift
INTO @shift_ID
	,@From_hour
	,@To_Hour
	,@Minimum_Hour
	,@Calculate_Days
	,@OT_Applicable
	,@Fix_OT_Hours
	,@Shift_Dur
	,@Fix_W_Hours
	,@DeduHour_SecondBreak
	,@DeduHour_ThirdBreak
	,@S_St_Time
	,@S_End_Time
	,@Second_Break_Duration
	,@T_St_Time
	,@T_End_Time
	,@Third_Break_Duration
	,@HalfWeekDay
	,@HalfDayMinDur

WHILE @@Fetch_Status = 0
BEGIN
	SELECT @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur)

	SELECT @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)

	SELECT @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)

	IF @Fix_W_Hours > 0
	BEGIN
		UPDATE D
		SET P_Days = @Calculate_Days
			,Duration_in_sec = dbo.f_return_sec(replace(@Fix_W_Hours, '.', ':'))
		FROM #Data D
		LEFT JOIN #EMP_HW_CONS HW ON D.Emp_Id = HW.Emp_ID
		INNER JOIN #EMP_GEN_SETTINGS G ON D.Emp_Id = G.EMP_ID --Checked Transfer WH Work to OT if setting applied in General Setting Otherwise it should considered as present day									--CHANGED FROM INNER JOIN TO LEFT OUTER BY RAMIZ ON 14/03/2017 (CONTINOUS ABSENT REPORT OF SAMARTH WAS COMING WRONG)
		WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
			AND dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0
			AND chk_by_superior <> 1 
			--Modified following condition by Chetan on 05062017 (WeekOff & Holiday Work Transfer To OT Setting should be checked in following case)
			AND (
				CASE 
					WHEN G.Tras_Week_OT = 1
						AND CHARINDEX(cast(d.For_date AS VARCHAR(11)), REPLACE(ISNULL(HW.WeekOffDate, ''), ISNULL(HW.CancelWeekOff, ''), '')) > 0
						THEN 0
					ELSE 1
					END
				) = 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
			AND (
				CASE 
					WHEN G.Tras_Week_OT = 1
						AND CHARINDEX(cast(d.For_date AS VARCHAR(11)), REPLACE(ISNULL(HW.HolidayDate, ''), ISNULL(HW.CancelHoliday, ''), '')) > 1
						THEN 0
					ELSE 1
					END
				) = 1
			AND (
				NOT In_Time IS NULL
				OR NOT OUT_Time IS NULL
				) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
			AND EXISTS (
				SELECT 1
				FROM #DATA_JOIN J
				WHERE D.EMP_ID = J.EMP_ID
					AND D.FOR_DATE = J.FOR_DATE
				)
	END
	ELSE
	BEGIN
		UPDATE D
		SET P_Days = @Calculate_Days
		FROM #Data D
		LEFT JOIN #EMP_HW_CONS HW ON D.Emp_Id = HW.Emp_ID --CHANGED FROM INNER JOIN TO LEFT OUTER BY RAMIZ ON 14/03/2017 (CONTINOUS ABSENT REPORT OF SAMARTH WAS COMING WRONG)		
		INNER JOIN #EMP_GEN_SETTINGS G ON D.Emp_Id = G.EMP_ID --Checked Transfer WH Work to OT if setting applied in General Setting Otherwise it should considered as present day
		WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
			AND dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0
			AND chk_by_superior <> 1 -- Changed by rohit on 27122013
			--Modified following condition by Chetan on 05062017 (WeekOff & Holiday Work Transfer To OT Setting should be checked in following case)
			AND (
				CASE 
					WHEN G.Tras_Week_OT = 1
						AND CHARINDEX(cast(d.For_date AS VARCHAR(11)), REPLACE(ISNULL(HW.WeekOffDate, ''), ISNULL(HW.CancelWeekOff, ''), '')) > 0
						THEN 0
					ELSE 1
					END
				) = 1 --AND EMP_OT = 1 --Modified by Nimesh on 22-Jul-2016 ('00:00' From hours in Shift Master was creating issue on WeekOff OT Comp-Off)
			AND (
				CASE 
					WHEN G.Tras_Week_OT = 1
						AND CHARINDEX(cast(d.For_date AS VARCHAR(11)), REPLACE(ISNULL(HW.HolidayDate, ''), ISNULL(HW.CancelHoliday, ''), '')) > 1
						THEN 0
					ELSE 1
					END
				) = 1
			AND (
				NOT In_Time IS NULL
				OR NOT OUT_Time IS NULL
				) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
			AND EXISTS (
				SELECT 1
				FROM #DATA_JOIN J
				WHERE D.EMP_ID = J.EMP_ID
					AND D.FOR_DATE = J.FOR_DATE
				)
	END

	/*Added By Nimesh on 27-Feb-2019 (Tradebull : Half Day Shift (Minimum Half Day Duration) with Alternate WeekOff - Employee Present then it should consider Minimum Half Day Duration for Present Day Calculation*/
	IF IsNull(@HalfWeekDay, '') <> ''
		AND IsNull(@HalfDayMinDur, '') <> ''
	BEGIN
		UPDATE D
		SET P_Days = @Calculate_Days
		FROM #Data D
		WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@HalfDayMinDur, '.', ':'))
			--and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':'))   
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0
			AND chk_by_superior <> 1 -- CHanged by rohit on 27122013  
			AND (
				NOT In_Time IS NULL
				OR NOT OUT_Time IS NULL
				) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
			AND DateName(WEEKDAY, For_Date) = @HalfWeekDay
			AND EXISTS (
				SELECT 1
				FROM #DATA_JOIN J
				WHERE D.EMP_ID = J.EMP_ID
					AND D.FOR_DATE = J.FOR_DATE
				)
	END

	IF @OT_Applicable = 1
	BEGIN
		IF @Fix_OT_Hours > 0
		BEGIN
			UPDATE D
			SET P_Days = @Calculate_Days
				,OT_Sec = dbo.f_return_sec(replace(@Fix_OT_Hours, '.', ':'))
			FROM #Data D
			WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
				AND dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
				AND Emp_OT = 1
				AND Shift_ID = @shift_ID
				AND IO_Tran_Id = 0
				AND chk_by_superior <> 1 -- CHanged by rohit on 27122013
				AND (
					NOT In_Time IS NULL
					OR NOT OUT_Time IS NULL
					) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
				AND EXISTS (
					SELECT 1
					FROM #DATA_JOIN J
					WHERE D.EMP_ID = J.EMP_ID
						AND D.FOR_DATE = J.FOR_DATE
					)
		END
		ELSE IF @Minimum_Hour > 0
		BEGIN
			UPDATE D
			SET P_Days = @Calculate_Days
				,OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - dbo.f_return_sec(replace(@Minimum_Hour, '.', ':')))
				,Duration_in_sec = dbo.f_return_sec(replace(@Minimum_Hour, '.', ':'))
			FROM #Data D
			WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
				AND dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
				AND Emp_OT = 1
				AND Shift_ID = @shift_ID
				AND IO_Tran_Id = 0
				AND chk_by_superior <> 1 -- CHanged by rohit on 27122013  
				AND (
					NOT In_Time IS NULL
					OR NOT OUT_Time IS NULL
					) --added by Hardik 27/07/2016 for Single punch Present case where Attendance Regularise Applied, it is taking Full Present at GTPL
				AND EXISTS (
					SELECT 1
					FROM #DATA_JOIN J
					WHERE D.EMP_ID = J.EMP_ID
						AND D.FOR_DATE = J.FOR_DATE
					)
		END
		ELSE IF @Minimum_Hour = 0
		BEGIN
			IF Isnull(@DeduHour_SecondBreak, 0) = 1 -- Added by Hardik 10/12/2018 for Shoft shipyard client
			BEGIN
				UPDATE D
				SET P_Days = @Calculate_Days
					,OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - (@Shift_Dur_sec - IsNull(Second_Break.Second_Break_Duration_Sec, 0)))
				FROM #Data D
				LEFT JOIN (
					SELECT Emp_Id
						,For_date
						,@Second_Break_Duration_Sec AS Second_Break_Duration_Sec
					FROM #Data
					WHERE Shift_ID = @Shift_ID
						AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
						AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
						AND Duration_in_sec > 0
						AND For_Date NOT IN (
							SELECT Data
							FROM dbo.Split(@HalfDayDate1, ';')
							WHERE DATA <> ''
							)
					) Second_Break ON D.Emp_Id = Second_Break.Emp_Id
					AND D.For_date = Second_Break.For_date
				WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
					AND dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
					AND Emp_OT = 1
					AND dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec - IsNull(Second_Break.Second_Break_Duration_Sec, 0)
					AND Shift_ID = @shift_ID
					AND IO_Tran_Id = 0
					AND EXISTS (
						SELECT 1
						FROM #DATA_JOIN J
						WHERE D.EMP_ID = J.EMP_ID
							AND D.FOR_DATE = J.FOR_DATE
						)

				UPDATE D
				SET P_Days = @Calculate_Days
					,OT_Sec = dbo.F_Return_Without_Sec(OT_Sec - (IsNull(Second_Break.Second_Break_Duration_Sec, 0)))
				FROM #Data D
				LEFT JOIN (
					SELECT Emp_Id
						,For_date
						,@Second_Break_Duration_Sec AS Second_Break_Duration_Sec
					FROM #Data
					WHERE Shift_ID = @Shift_ID
						AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
						AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
						AND (
							Duration_in_sec > 0
							OR OT_Sec > 0
							)
						AND For_Date NOT IN (
							SELECT Data
							FROM dbo.Split(@HalfDayDate1, ';')
							WHERE DATA <> ''
							)
					) Second_Break ON D.Emp_Id = Second_Break.Emp_Id
					AND D.For_date = Second_Break.For_date
				WHERE dbo.F_Return_Without_Sec(OT_Sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
					AND dbo.F_Return_Without_Sec(OT_Sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
					AND Emp_OT = 1
					AND dbo.F_Return_Without_Sec(OT_Sec) > @Shift_Dur_sec - IsNull(Second_Break.Second_Break_Duration_Sec, 0)
					AND Shift_ID = @shift_ID
					AND IO_Tran_Id = 0
					AND EXISTS (
						SELECT 1
						FROM #DATA_JOIN J
						WHERE D.EMP_ID = J.EMP_ID
							AND D.FOR_DATE = J.FOR_DATE
						)
			END
			ELSE IF Isnull(@DeduHour_ThirdBreak, 0) = 1 -- Added by Hardik 10/12/2018 for Shoft shipyard client
			BEGIN
				UPDATE D
				SET P_Days = @Calculate_Days
					,OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - (@Shift_Dur_sec - IsNull(Third_Break.Third_Break_Duration_Sec, 0)))
				FROM #Data D
				LEFT JOIN (
					SELECT Emp_Id
						,For_date
						,@Third_Break_Duration_Sec AS Third_Break_Duration_Sec
					FROM #Data
					WHERE Shift_ID = @Shift_ID
						AND In_Time < cast(cast(In_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
						AND OUT_Time > cast(cast(OUT_Time AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
						AND Duration_in_sec > 0
						AND For_Date NOT IN (
							SELECT Data
							FROM dbo.Split(@HalfDayDate1, ';')
							WHERE DATA <> ''
							)
					) Third_Break ON D.Emp_Id = Third_Break.Emp_Id
					AND D.For_date = Third_Break.For_date
				WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
					AND dbo.F_Return_Without_Sec(Duration_in_sec) <= dbo.f_return_sec(replace(@To_Hour, '.', ':'))
					AND Emp_OT = 1
					AND dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec - IsNull(Third_Break.Third_Break_Duration_Sec, 0)
					AND Shift_ID = @shift_ID
					AND IO_Tran_Id = 0
					AND EXISTS (
						SELECT 1
						FROM #DATA_JOIN J
						WHERE D.EMP_ID = J.EMP_ID
							AND D.FOR_DATE = J.FOR_DATE
						)
			END
			ELSE
			BEGIN
				--if @Calculate_days = 1
				--	 select  @From_hour,@To_Hour,
				--	 dbo.F_Return_Without_Sec(Duration_in_sec)
				--	 ,dbo.f_return_sec( replace(@From_hour,'.',':'))
				--	 ,dbo.f_return_sec( replace(@To_Hour,'.',':')) 
				--	 ,@Calculate_Days,    
				--		 dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec),P_Days,OT_Sec,*
				--	from	#Data D
				--	Where	dbo.F_Return_Without_Sec(Duration_in_sec) >=dbo.f_return_sec( replace(@From_hour,'.',':'))
				--	and Emp_OT= 1 and dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec    
				--	and Shift_ID= @shift_ID  and IO_Tran_Id  = 0 
				--	AND EXISTS(SELECT 1 FROM #DATA_JOIN J WHERE D.EMP_ID=J.EMP_ID AND D.FOR_DATE=J.FOR_DATE)
				--	AND OT_Start_Time=0 AND OT_End_Time=0 AND Working_Hrs_St_Time=0 AND Working_Hrs_End_Time=0 -- Added By Sajid 19-09-2023
				UPDATE D
				SET P_Days = @Calculate_Days
					,OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec)
				FROM #Data D
				WHERE dbo.F_Return_Without_Sec(Duration_in_sec) >= dbo.f_return_sec(replace(@From_hour, '.', ':'))
					--and dbo.F_Return_Without_Sec(Duration_in_sec) <=dbo.f_return_sec( replace(@To_Hour,'.',':')) --   Comment by ronakk 24012023  for Redmine Bug #27512   
					AND Emp_OT = 1
					AND dbo.F_Return_Without_Sec(Duration_in_sec) > @Shift_Dur_sec
					AND Shift_ID = @shift_ID
					AND IO_Tran_Id = 0
					AND EXISTS (
						SELECT 1
						FROM #DATA_JOIN J
						WHERE D.EMP_ID = J.EMP_ID
							AND D.FOR_DATE = J.FOR_DATE
						)
					AND OT_Start_Time = 0
					AND OT_End_Time = 0
					AND Working_Hrs_St_Time = 0
					AND Working_Hrs_End_Time = 0 -- Added By Sajid 19-09-2023
			END

			SELECT @Ot_Sec_Neg = Isnull(Ot_Sec, 0)
			FROM #Data D
			WHERE OT_Sec < 1 --Nikunj
				AND EXISTS (
					SELECT 1
					FROM #DATA_JOIN J
					WHERE D.EMP_ID = J.EMP_ID
						AND D.FOR_DATE = J.FOR_DATE
					)

			IF @Ot_Sec_Neg < 1
				AND Isnull(@Is_Negative_Ot, 0) = 1 --And Duration_In_sec < @Shift_Dur_sec --logic Of Negative ot			
			BEGIN
				UPDATE D
				SET OT_Sec = dbo.F_Return_Without_Sec(@Shift_Dur_sec - Duration_in_sec)
					,Flag = 1
				FROM #Data D
				WHERE Ot_Sec < 1
					AND dbo.F_Return_Without_Sec(Duration_In_sec) < @Shift_Dur_sec
					AND Shift_Id = @Shift_Id
					AND Emp_OT = 1
					AND EXISTS (
						SELECT 1
						FROM #DATA_JOIN J
						WHERE D.EMP_ID = J.EMP_ID
							AND D.FOR_DATE = J.FOR_DATE
						)
			END
		END

		IF isnull(@Report_For, '') = 'ABSENT_CON'
		BEGIN
			UPDATE D
			SET P_Days = 1
				,OT_Sec = dbo.F_Return_Without_Sec(Duration_in_sec - @Shift_Dur_sec)
			FROM #Data D
			WHERE Emp_OT = 1
				AND Shift_ID = @shift_ID
				AND IO_Tran_Id = 0
				AND Chk_By_Superior <> 1
				AND EXISTS (
					SELECT 1
					FROM #DATA_JOIN J
					WHERE D.EMP_ID = J.EMP_ID
						AND D.FOR_DATE = J.FOR_DATE
					)
				AND (
					NOT In_Time IS NULL
					OR NOT OUT_Time IS NULL
					)
		END
	END

	FETCH NEXT
	FROM cur_Shift
	INTO @shift_ID
		,@From_hour
		,@To_Hour
		,@Minimum_Hour
		,@Calculate_Days
		,@OT_Applicable
		,@Fix_OT_Hours
		,@Shift_Dur
		,@Fix_W_Hours
		,@DeduHour_SecondBreak
		,@DeduHour_ThirdBreak
		,@S_St_Time
		,@S_End_Time
		,@Second_Break_Duration
		,@T_St_Time
		,@T_End_Time
		,@Third_Break_Duration
		,@HalfWeekDay
		,@HalfDayMinDur
END

CLOSE cur_Shift

DEALLOCATE Cur_Shift

-- Added by Gadriwala Muslim 28102015 - Start
DECLARE @LateEarly_Exemption_MaxLimit VARCHAR(10)
DECLARE @LateEarly_Exemption_Count NUMERIC
DECLARE @LateEarly_Exemption_Constraint VARCHAR(MAX)

SET @LateEarly_Exemption_MaxLimit = '00:00'
SET @LateEarly_Exemption_Count = 0

SELECT @LateEarly_Exemption_MaxLimit = IsNull(LateEarly_Exemption_MaxLimit, @LateEarly_Exemption_MaxLimit)
	,@LateEarly_Exemption_Count = IsNull(LateEarly_Exemption_Count, @LateEarly_Exemption_Count)
	,@LateEarly_Exemption_Constraint = COALESCE(@LateEarly_Exemption_Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(5))
FROM dbo.T0040_GENERAL_SETTING G
INNER JOIN (
	SELECT MAX(FOR_DATE) AS FOR_DATE
		,G1.BRANCH_ID
	FROM dbo.T0040_GENERAL_SETTING G1
	INNER JOIN #EMP_CONS E ON G1.BRANCH_ID = E.BRANCH_ID
	GROUP BY G1.BRANCH_ID
	) G1 ON G.FOR_DATE = G1.FOR_DATE
	AND G.BRANCH_ID = G1.BRANCH_ID
INNER JOIN #EMP_CONS E ON G.Branch_ID = E.Branch_ID
WHERE LateEarly_Exemption_MaxLimit <> '00:00'
	AND LateEarly_Exemption_Count <> 0

IF ISNULL(@LateEarly_Exemption_MaxLimit, '00:00') <> '00:00'
	AND @LateEarly_Exemption_Count <> 0
	AND @Late_SP = 0
	AND @LateEarly_Exemption_Constraint IS NOT NULL
	AND OBJECT_ID('tempdb..#Extra_Exempted') IS NULL
BEGIN
	CREATE TABLE #Extra_Exempted (
		Emp_ID NUMERIC(18, 0)
		,For_Date DATETIME
		,Extra_Exempted_Sec NUMERIC(18, 0) DEFAULT 0
		,Extra_Exempted TINYINT DEFAULT 0
		)

	EXEC rpt_Late_Early_Mark_Deduction_Details @Cmp_ID
		,@From_Date
		,@To_Date
		,@Branch_ID
		,@Cat_ID
		,@Grd_ID
		,@Type_ID
		,@Dept_ID
		,@Desig_ID
		,@Emp_ID
		,@LateEarly_Exemption_Constraint
		,'Extra-Exempted'
		,0
		,1
		,1

	UPDATE #Data
	SET Duration_in_sec = (Duration_in_sec + Extra_Exempted_Sec)
	FROM #Data DA
	INNER JOIN #Extra_Exempted EE ON DA.Emp_Id = EE.Emp_ID
		AND DA.For_date = EE.For_Date
	INNER JOIN dbo.Split(@LateEarly_Exemption_Constraint, '#') T ON DA.Emp_Id = Cast(T.Data AS NUMERIC)

	GOTO UPDATE_LATE_DAYS
END


DECLARE @ShiftId NUMERIC
DECLARE @WeekDay VARCHAR(10)
DECLARE @HalfStartTime VARCHAR(10)
DECLARE @HalfEndTime VARCHAR(10)
DECLARE @HalfDuration VARCHAR(10)
DECLARE @HalfDayDate VARCHAR(max)
DECLARE @curForDate DATETIME
DECLARE @HalfMinDuration VARCHAR(10)

--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
DECLARE curweekoff1 CURSOR FAST_FORWARD
FOR
SELECT DISTINCT Emp_Id
FROM #Emp_Cons

OPEN curweekoff1

FETCH NEXT
FROM curweekoff1
INTO @Emp_Id_Temp1

WHILE @@fetch_status = 0
BEGIN
	EXEC dbo.GET_HalfDay_Date @Cmp_ID
		,@Emp_Id_Temp1
		,@From_Date
		,@To_Date
		,0
		,@HalfDayDate OUTPUT

	IF IsNUll(@HalfDayDate, '') <> ''
	BEGIN
		SELECT @ShiftId = SM.Shift_id
			,@WeekDay = SM.Week_Day
			,@HalfStartTime = SM.Half_St_Time
			,@HalfEndTime = SM.Half_End_Time
			,@HalfDuration = SM.Half_Dur
			,@HalfMinDuration = SM.Half_min_duration
		FROM dbo.T0040_SHIFT_MASTER SM
		INNER JOIN (
			SELECT DISTINCT Shift_ID
			FROM #Data
			WHERE Emp_Id = @Emp_Id_Temp1
			) q ON SM.Shift_ID = q.shift_ID
		WHERE Is_Half_Day = 1

		DECLARE cur_shift_half_day CURSOR FAST_FORWARD
		FOR
		SELECT For_date
		FROM #Data D
		WHERE Emp_Id = @Emp_Id_Temp1
			AND EXISTS (
				SELECT 1
				FROM dbo.Split(@HalfDayDate, ';')
				WHERE DATA <> ''
					AND CAST(DATA AS DATETIME) = D.For_date
				) --Hardik 07/09/2012 Where Condition
			AND NOT EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY H
				WHERE D.For_date = H.FOR_DATE
					AND H.IS_CANCEL = 0
					AND D.Emp_Id = H.EMP_ID
				)
			AND NOT EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF W
				WHERE D.For_date = W.FOR_DATE
					AND W.IS_CANCEL = 0
					AND D.Emp_Id = W.EMP_ID
				)

		OPEN cur_shift_half_day

		FETCH NEXT
		FROM cur_shift_half_day
		INTO @curForDate

		WHILE @@Fetch_Status = 0
		BEGIN
			IF (charindex(CONVERT(NVARCHAR(11), @curForDate, 109), @HalfDayDate) > 0)
			BEGIN
				-- Comment by rohit for week of regularization not calculate in present if Week off Work transfer to ot on 12082013
				UPDATE #Data
				SET P_days = 1
					,in_time = convert(VARCHAR(11), d.For_date, 120) + @HalfStartTime
					,out_time = convert(VARCHAR(11), d.For_date, 120) + @HalfEndTime
					,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration)
				FROM #Data d
				INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
					AND TEIR.Chk_By_Superior = 1
					AND TEIR.For_Date = d.For_date
					AND TEIR.Half_Full_day = 'Full Day'
				WHERE TEIR.For_Date = @curForDate
					AND d.IO_Tran_Id = 0
					AND TEIR.emp_id = @Emp_Id_Temp1
					AND NOT EXISTS (
						SELECT 1
						FROM #Emp_WeekOff W
						WHERE d.For_date = W.For_Date
							AND d.Emp_Id = W.Emp_ID
							AND W.Is_Cancel = 0
						)

				-- Ended by rohit on 12082013	
				UPDATE #Data
				SET Shift_Start_Time = convert(VARCHAR(11), @curForDate, 120) + @HalfStartTime
					,Shift_End_Time = convert(VARCHAR(11), @curForDate, 120) + @HalfEndTime
				WHERE For_date = @curForDate
					AND IO_Tran_Id = 0
					AND Emp_Id = @Emp_Id_Temp1

				UPDATE #Data
				SET P_days = 1
				WHERE For_date = @curForDate
					AND Duration_in_sec >= dbo.F_Return_Sec(@HalfMinDuration)
					AND IO_Tran_Id = 0
					AND Emp_Id = @Emp_Id_Temp1

				UPDATE #Data
				SET P_days = 0
				WHERE For_date = @curForDate
					AND Duration_in_sec < dbo.F_Return_Sec(@HalfMinDuration)
					AND IO_Tran_Id = 0
					AND Emp_Id = @Emp_Id_Temp1

				UPDATE #Data
				SET OT_Sec = dbo.F_Return_Without_Sec(CASE 
							WHEN dbo.F_Return_Sec(@HalfMinDuration) > Duration_in_sec
								THEN dbo.F_Return_Sec(@HalfMinDuration) - Duration_in_sec
							ELSE Duration_in_sec - dbo.F_Return_Sec(@HalfMinDuration)
							END)
				WHERE Duration_in_sec >= dbo.F_Return_Sec(@HalfMinDuration)
					AND Emp_OT = 1
					AND For_date = @curForDate
					AND Emp_Id = @Emp_Id_Temp1

				-- Added by rohit for week of regularization not calculate in present if Week off Work transfer to OT on 12082013
				UPDATE #Data
				SET P_days = 0.5
					,in_time = convert(VARCHAR(11), d.For_date, 120) + @HalfStartTime
					,out_time = (convert(VARCHAR(11), d.For_date, 120) + dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfStartTime) + (dbo.F_Return_Sec(@HalfMinDuration)) / 2))
					,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration) / 2
				FROM #Data d
				INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
					AND TEIR.Chk_By_Superior = 1
					AND TEIR.For_Date = d.For_date
					AND (TEIR.Half_Full_day = 'First Half')
				WHERE TEIR.For_Date = @curForDate
					AND d.IO_Tran_Id = 0
					AND TEIR.emp_id = @Emp_Id_Temp1

				UPDATE #Data
				SET P_days = 0.5
					,in_time = (convert(VARCHAR(11), d.For_date, 120) + dbo.F_Return_Hours(dbo.F_Return_Sec(@HalfStartTime) + (dbo.F_Return_Sec(@HalfMinDuration)) / 2))
					,out_time = convert(VARCHAR(11), d.For_date, 120) + @HalfEndTime
					,duration_in_sec = dbo.F_Return_Sec(@HalfMinDuration) / 2
				FROM #Data d
				INNER JOIN dbo.T0150_EMP_INOUT_RECORD TEIR ON TEIR.Emp_Id = d.Emp_Id
					AND TEIR.Chk_By_Superior = 1
					AND TEIR.For_Date = d.For_date
					AND (TEIR.Half_Full_day = 'Second Half')
				WHERE TEIR.For_Date = @curForDate
					AND d.IO_Tran_Id = 0
					AND TEIR.emp_id = @Emp_Id_Temp1
			END

			FETCH NEXT
			FROM cur_shift_half_day
			INTO @curForDate
		END

		CLOSE cur_shift_half_day

		DEALLOCATE cur_shift_half_day
	END

	FETCH NEXT
	FROM curweekoff1
	INTO @Emp_Id_Temp1
END

CLOSE curweekoff1
DEALLOCATE curweekoff1

IF @Call_For_Leave_Cancel <> 1 
BEGIN
	/*Modified following query by Nimesh on 10-Jan-2019 (If employee takes two half day leaves (CompOff and PL) andalso present for full day then leave should be deducted from present days) - Competant*/
	UPDATE dbo.#Data 
	SET P_days = (P_days - Leave_Used)
	FROM #Data d
	INNER JOIN (
		SELECT For_Date
			,Emp_ID
			,Sum(Leave_Used) AS Leave_Used
		FROM (
			SELECT For_Date
				,Emp_ID
				,Sum(Leave_Used) AS Leave_Used
			FROM dbo.T0140_LEAVE_TRANSACTION LT
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LT.Leave_ID = LM.Leave_ID
				AND isnull(LM.Default_Short_Name, '') <> 'COMP'
			WHERE leave_used = 0.5
				AND LT.Cmp_Id = @Cmp_Id
				AND 
				For_Date >= @From_Date
				AND For_Date <= @To_Date
				AND (
					isnull(eff_in_salary, 0) <> 1
					OR (
						isnull(eff_in_salary, 0) = 1
						AND Leave_Used > 0
						)
					)
				AND Isnull(LM.Add_In_Working_Hour, 0) = 0 
			GROUP BY For_Date
				,Emp_ID
			
			UNION ALL
			
			SELECT For_Date
				,Emp_ID
				,Sum(CompOff_Used) AS Leave_Used
			FROM dbo.T0140_LEAVE_TRANSACTION LT
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LT.Leave_ID = LM.Leave_ID
				AND isnull(LM.Default_Short_Name, '') = 'COMP'
			WHERE (CompOff_Used - Leave_Encash_Days) = 0.5
				AND 
				For_Date >= @From_Date
				AND For_Date <= @To_Date
				AND (
					isnull(eff_in_salary, 0) <> 1
					AND LT.Cmp_Id = @Cmp_Id
					OR (
						isnull(eff_in_salary, 0) = 1
						AND (CompOff_Used - Leave_Encash_Days) > 0
						)
					)
				AND Isnull(LM.Add_In_Working_Hour, 0) = 0 
			GROUP BY For_Date
				,Emp_ID
			) T
		GROUP BY For_Date
			,Emp_ID
		) Qry ON Qry.For_Date = d.For_date
		AND Qry.Emp_ID = d.Emp_Id
	WHERE IO_Tran_Id = 0
		AND P_days = 1
END

-- Changed by Gadriwala Muslim 01012015 - End
-- Comment and Added by rohit on 08092014
--Alpesh 06-Jul-2012 -> If Leave is paid then count as Leave, Not as Present 			 
--update dbo.#Data 
--set P_days = 0 from #Data d inner join  
--	(select For_Date,Emp_ID from dbo.T0140_LEAVE_TRANSACTION lt inner join dbo.T0040_LEAVE_MASTER lm on lm.Leave_ID=lt.Leave_ID
--	 where leave_used = 1 and For_Date >= @From_Date and For_Date <= @To_Date and lm.Leave_Paid_Unpaid='P') Qry 
--	 on Qry.For_Date = d.For_date and Qry.Emp_ID = d.Emp_Id where IO_Tran_Id  = 0
---- End ----
---- end below update statment added by mitesh for regularization as only full day on 09/01/2012.
--Deepal 03042022
--update D set d.P_days = 0 
--from #DATA D inner join  T0150_EMP_INOUT_RECORD T  on T.Emp_ID = d.Emp_Id and (t.In_Date_Time = d.In_Time and t.Out_Date_Time = d.Out_time or  
--t.In_Time = d.In_Time and t.Out_Time = d.Out_time)
--where t.Chk_By_Superior = 2
--update D set d.P_days = 0 ,Duration_in_sec = case when isnull(t.Duration,'') = '' then 0 else dbo.F_Return_Sec(t.Duration) end ,OT_Sec = (case when isnull(T.Out_Date_Time,'') =  '' or isnull(t.Out_Time,'') = '' then 0 else OT_Sec end)
--from #DATA D inner join  T0150_EMP_INOUT_RECORD T  on T.Emp_ID = d.Emp_Id 
--and (t.In_Date_Time = d.In_Time and t.Out_Date_Time = d.Out_time or t.In_Time = d.In_Time and t.Out_Time = d.Out_time)
--where t.Chk_By_Superior = 0 and (Reason <> '' or Other_Reason <> '')
--and P_days > 0
--select P_days,Duration_in_sec, * from #DATA where For_date ='2024-01-02 00:00:00.000'
-- Changed by Gadriwala Muslim 01012015 - Start
IF @CALL_FOR_LEAVE_CANCEL <> 1 
BEGIN
	UPDATE #Data 
	SET P_days = CASE 
			WHEN (1 - lt.leave_used) < 0
				THEN 0
			ELSE (1 - lt.leave_used)
			END
	FROM #Data d
	LEFT JOIN (
		SELECT emp_id
			,for_date
			,sum(CASE 
					WHEN lm.Apply_hourly = 0
						THEN lt.leave_used
					ELSE CASE 
							WHEN (lt.leave_used * 0.125) > 1
								THEN 1
							ELSE (lt.leave_used * 0.125)
							END
					END) AS Leave_Used
		FROM T0140_LEAVE_TRANSACTION lt
		INNER JOIN T0040_LEAVE_MASTER lm ON lt.Leave_ID = lm.Leave_ID
			AND isnull(lm.Default_Short_Name, '') <> 'COMP'
			AND Isnull(LM.Add_In_Working_Hour, 0) = 0 --cliantha
		WHERE For_Date BETWEEN @From_Date
				AND @To_Date
			AND lt.Cmp_ID = @Cmp_id
		GROUP BY Emp_ID
			,For_Date
		) AS lt ON d.emp_id = lt.emp_ID
		AND d.for_date = lt.for_date
	WHERE d.P_days + lt.leave_used > 1

	UPDATE #Data -- For CompOFf Leave 
	SET P_days = CASE 
			WHEN (1 - lt.leave_used) < 0
				THEN 0
			ELSE (1 - lt.leave_used)
			END
	FROM #Data d
	LEFT JOIN (
		SELECT emp_id
			,for_date
			,sum(CASE 
					WHEN lm.Apply_hourly = 0
						THEN (lt.CompOff_Used - lt.Leave_Encash_Days)
					ELSE CASE 
							WHEN ((lt.CompOff_Used - lt.Leave_Encash_Days) * 0.125) > 1
								THEN 1
							ELSE ((lt.CompOff_Used - lt.Leave_Encash_Days) * 0.125)
							END
					END) AS Leave_Used
		FROM T0140_LEAVE_TRANSACTION lt
		INNER JOIN T0040_LEAVE_MASTER lm ON lt.Leave_ID = lm.Leave_ID
			AND isnull(lm.Default_Short_Name, '') = 'COMP'
			AND Isnull(LM.Add_In_Working_Hour, 0) = 0
		WHERE For_Date BETWEEN @From_Date
				AND @To_Date
		GROUP BY Emp_ID
			,For_Date
		) AS lt ON d.emp_id = lt.emp_ID
		AND d.for_date = lt.for_date
	WHERE d.P_days + lt.leave_used > 1
END

-- Changed by Gadriwala Muslim 01012015 - End
-- Ende
--------------------Added by Mitesh on 15/09/2011 for Shift Half Day ----------------------------
UPDATE #Data
SET OT_Sec = isnull(Approved_OT_Sec, 0)
	,Weekoff_OT_Sec = ISNULL(OA.Approved_WO_OT_Sec, 0)
	,Holiday_OT_Sec = ISNULL(OA.Approved_HO_OT_Sec, 0) -- * 3600    
FROM #Data d
INNER JOIN dbo.T0160_OT_Approval OA ON d.emp_ID = Oa.Emp_ID
	AND d.For_Date = oa.For_Date
	AND Is_Month_Wise = 0

-- Deepal 12122022 23482 
UPDATE D
SET D.P_days = 0
FROM #DATA D
INNER JOIN #EMP_GEN_SETTINGS G ON D.EMP_ID = G.EMP_ID
WHERE G.TRAS_WEEK_OT = 1
	AND (
		D.Weekoff_OT_Sec > 0
		OR D.Holiday_OT_Sec > 0
		)

-- Deepal 12122022 23482
---------------- Add by Jignesh Patel 14-Apr-2022---(Bug/Suggestions #20756)---------
-- if Not exists (Select 1 from tempdb.sys.columns  where [object_id] = object_id('tempdb..#Data') 
--            and name ='Original_OT_Sec')
--Begin
--	ALTER TABLE #Data
--	ADD  Original_OT_Sec int 
--End
--  Update #Data SET Original_OT_Sec = OT_Sec
IF OBJECT_ID(N'tempdb..#Emp_Original_OT_Sec') IS NOT NULL
BEGIN
	DROP TABLE #Emp_Original_OT_Sec
END

SELECT Emp_id AS OT_Emp_Id
	,For_date
	,OT_Sec AS Original_OT_Sec
INTO #Emp_Original_OT_Sec
FROM #Data

------------------------End -------------
UPDATE #Data
SET OT_Sec = 0
WHERE Emp_OT_Min_Limit > OT_sec
	AND OT_sec > 0

UPDATE #Data
SET OT_Sec = Emp_OT_Max_Limit
WHERE OT_sec > Emp_OT_Max_Limit
	AND Emp_OT_Max_Limit > 0
	AND OT_sec > 0

-- Added by Hardik 03/12/2019 for Cera
DECLARE @Setting_Value INT

SET @Setting_Value = 0

SELECT @Setting_Value = Isnull(Setting_Value, 0)
FROM T0040_SETTING
WHERE setting_name = 'Make Absent if Employee came in Different Shift'
	AND Cmp_Id = @Cmp_Id

--Code Commented and Added By Ramiz on 04/04/2017 ( Reason:- For 24 Hours Shift , We will Not Consider Shift Deviation )
IF Isnull(@Setting_Value, 0) = 1
BEGIN
	UPDATE D
	SET P_days = 0
	FROM #DATA D
	INNER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID = SM.Shift_ID
	WHERE Shift_Change = 1
		AND NOT EXISTS (
			SELECT 1
			FROM T0050_SHIFT_DETAIL SD
			WHERE D.SHIFT_ID = SD.SHIFT_ID
				AND SD.FROM_HOUR < 1
				AND SD.TO_HOUR > 23
			)
		AND Inc_Auto_Shift <> 1
END

--PRINT 'CALC 17 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
---Add by Hardik for Diferentiate Weekoff OT And Holiday OT 
--Declare @Is_Cancel_Holiday  Numeric(1,0)  
DECLARE @Is_Cancel_Weekoff_OT NUMERIC(1, 0)
DECLARE @Join_Date DATETIME
DECLARE @Left_Date DATETIME
--Declare @StrHoliday_Date  varchar(max)  
DECLARE @StrWeekoff_Date_OT VARCHAR(max)
--Declare @Holiday_Days Numeric(12,1)
DECLARE @Weekoff_Days_OT NUMERIC(12, 1)
--Declare @Cancel_Holiday Numeric(12,1)
DECLARE @Cancel_Weekoff_OT NUMERIC(12, 1)
DECLARE @Emp_Id_Cur NUMERIC
DECLARE @For_Date DATETIME
DECLARE @WeekOff_Work_Sec NUMERIC
DECLARE @Holiday_Work_Sec NUMERIC
DECLARE @Trans_Weekoff_OT TINYINT --Hardik 14/02/2013 
DECLARE @Is_Cancel_Holiday INT
DECLARE @StrHoliday_Date VARCHAR(Max)
DECLARE @Holiday_days NUMERIC(18, 3)
DECLARE @Cancel_Holiday NUMERIC(18, 3)
DECLARE @Half_Holiday_Dates VARCHAR(Max)
--- Added By Hardik 10/08/2013 for Split Shift Count and Dates for Azure Client
DECLARE @Is_Split_Shift AS TINYINT
DECLARE @In_Time DATETIME
DECLARE @Out_Time DATETIME
DECLARE @First_Working_Sec NUMERIC
DECLARE @Split_Shift_Allow NUMERIC(18, 3)
DECLARE @Split_Shift_Ratio NUMERIC(18, 3)
DECLARE @Shift_Second_St_Time DATETIME
DECLARE @Shift_Second_End_Time DATETIME
DECLARE @Shift_Second_Sec NUMERIC
DECLARE @Shift_Third_St_Time DATETIME
DECLARE @Shift_Third_End_Time DATETIME
DECLARE @Shift_Third_Sec NUMERIC

SET @Is_Cancel_Weekoff_OT = 0
SET @Is_Cancel_Holiday = 0
SET @StrHoliday_Date = ''
SET @StrWeekoff_Date_OT = ''
SET @Holiday_Days = 0
SET @Weekoff_Days_OT = 0
SET @Cancel_Holiday = 0
SET @Cancel_Weekoff_OT = 0
SET @Trans_Weekoff_OT = 0
SET @Half_Holiday_Dates = '';

SELECT @Is_Cancel_Holiday = Is_Cancel_Holiday
	,@Is_Cancel_Weekoff_OT = Is_Cancel_Weekoff
FROM dbo.T0040_GENERAL_SETTING
WHERE cmp_ID = @cmp_ID
	AND Branch_ID = @Branch_ID
	AND For_Date = (
		SELECT max(For_Date)
		FROM dbo.T0040_GENERAL_SETTING
		WHERE For_Date <= @To_Date
			AND Branch_ID = @Branch_ID
			AND Cmp_ID = @Cmp_ID
		)

DECLARE @Split_Shift_Count NUMERIC
SET @Split_Shift_Count = 0


DECLARE @Shift_End_Time_Temp AS DATETIME
DECLARE @Diff_Sec AS NUMERIC
DECLARE @OT_Start_Time AS NUMERIC


DECLARE Cur_HO CURSOR FAST_FORWARD
FOR
SELECT Emp_Id
	,For_Date
	,Shift_End_Time
FROM #Data 

OPEN Cur_HO

FETCH NEXT
FROM Cur_HO
INTO @Emp_Id_Cur
	,@For_Date
	,@Shift_End_Time_Temp

WHILE @@Fetch_Status = 0
BEGIN
	SET @Is_Split_Shift = 0
	SET @In_Time = NULL
	SET @Out_Time = NULL
	SET @Shift_Second_St_Time = NULL
	SET @Shift_Second_End_Time = NULL
	SET @Shift_Third_St_Time = NULL
	SET @Shift_Third_End_Time = NULL
	SET @Shift_Second_Sec = 0
	SET @Shift_Third_Sec = 0
	SET @First_Working_Sec = 0
	SET @Split_Shift_Allow = 0
	SET @Split_Shift_Ratio = 0
	SET @Split_Shift_Count = 0
	SET @Diff_Sec = 0

	SELECT @Is_Split_Shift = Is_Split_Shift
		,@Split_Shift_Allow = S.Split_Shift_Rate
		,@Split_Shift_Ratio = Split_Shift_Ratio
		,@Shift_Second_St_Time = Cast(@For_Date + ' ' + S.S_St_Time AS DATETIME)
		,@Shift_Second_End_Time = Cast(@For_Date + ' ' + S.S_End_Time AS DATETIME)
		,@Shift_Second_Sec = DATEDIFF(SS, @Shift_Second_St_Time, @Shift_Second_End_Time)
		,@Shift_Third_St_Time = Cast(@For_Date + ' ' + S.T_St_Time AS DATETIME)
		,@Shift_Third_End_Time = Cast(@For_Date + ' ' + S.T_End_Time AS DATETIME)
		,@Shift_Third_Sec = DATEDIFF(SS, @Shift_Third_St_Time, @Shift_Third_End_Time)
	FROM T0040_SHIFT_MASTER S
	INNER JOIN #Data D ON S.Shift_ID = D.Shift_ID
	WHERE For_date = @For_Date
		AND Emp_Id = @Emp_Id_Cur

	IF @Is_Split_Shift = 1
		AND @Is_Split_Shift_Req = 1
	BEGIN
		DECLARE Cur_Split CURSOR FAST_FORWARD
		FOR
		SELECT In_Time
			,Out_Time
		FROM T0150_EMP_INOUT_RECORD
		WHERE For_Date = @For_Date
			AND Emp_ID = @Emp_Id_Cur

		OPEN Cur_Split

		FETCH NEXT
		FROM Cur_Split
		INTO @In_Time
			,@Out_Time

		WHILE @@Fetch_Status = 0
		BEGIN
			IF DATEADD(MINUTE, - 90, @Shift_Second_St_Time) <= @In_Time
				AND DATEADD(MINUTE, 90, @Shift_Second_End_Time) >= @Out_Time
			BEGIN
				IF @Shift_Second_St_Time > @In_Time
					SET @In_Time = @Shift_Second_St_Time

				IF @Shift_Second_End_Time < @Out_Time
					SET @Out_Time = @Shift_Second_End_Time

				IF @Shift_Second_Sec < Datediff(SS, @In_Time, @Out_Time)
				BEGIN
					SET @First_Working_Sec = @First_Working_Sec + @Shift_Second_Sec
				END
				ELSE
				BEGIN
					SET @First_Working_Sec = @First_Working_Sec + Datediff(SS, @In_Time, @Out_Time)
				END
			END
			ELSE IF DATEADD(MINUTE, - 90, @Shift_Third_St_Time) <= @In_Time
				AND DATEADD(MINUTE, 90, @Shift_Third_End_Time) >= @Out_Time
			BEGIN
				IF @Shift_Third_St_Time > @In_Time
					SET @In_Time = @Shift_Third_St_Time

				IF @Shift_Third_End_Time < @Out_Time
					SET @Out_Time = @Shift_Third_End_Time

				IF @Shift_Third_Sec < Datediff(SS, @In_Time, @Out_Time)
				BEGIN
					SET @First_Working_Sec = @First_Working_Sec + @Shift_Second_Sec
				END
				ELSE
				BEGIN
					SET @First_Working_Sec = @First_Working_Sec + Datediff(SS, @In_Time, @Out_Time)
				END
			END

			FETCH NEXT
			FROM Cur_Split
			INTO @In_Time
				,@Out_Time
		END

		CLOSE Cur_Split

		DEALLOCATE Cur_Split

		IF (@First_Working_Sec / (@Shift_Second_Sec + @Shift_Third_Sec)) * 100 >= @Split_Shift_Ratio
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM #Split_Shift_Table
					WHERE Emp_Id = @Emp_Id_Cur
					)
			BEGIN
				INSERT INTO #Split_Shift_Table (
					Emp_Id
					,Split_Shift_Count
					,Split_Shift_Dates
					,Split_Shift_Allow
					)
				VALUES (
					@Emp_ID
					,1
					,Cast(@For_Date AS VARCHAR(11))
					,@Split_Shift_Allow
					)
			END
			ELSE
			BEGIN
				UPDATE #Split_Shift_Table
				SET Split_Shift_Count = Split_Shift_Count + 1
					,Split_Shift_Dates = Split_Shift_Dates + ';' + Cast(@For_Date AS VARCHAR(11))
					,Split_Shift_Allow = Split_Shift_Allow + @Split_Shift_Allow
				WHERE Emp_Id = @Emp_Id_Cur
			END
		END
	END

	
	SELECT @Branch_ID = I.Branch_ID
	FROM dbo.T0095_Increment I
	INNER JOIN (
		SELECT max(Increment_ID) AS Increment_ID
			,Emp_ID
		FROM dbo.T0095_Increment 
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @Cmp_ID
			AND Emp_ID = @Emp_Id_Cur
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_ID = Qry.Increment_ID
	WHERE I.Emp_ID = @Emp_Id_Cur
	
	SET @StrWeekoff_Date_OT = ''
	SET @StrHoliday_Date = ''

	SELECT @StrWeekoff_Date_OT = StrWeekoff
		,@StrHoliday_Date = StrHoliday
	FROM #Emp_WeekOFf_Detail
	WHERE Emp_ID = @Emp_Id_Cur

	
	/* Note : Cancel weekly off If Sandwich Policy and Employee Present on that day then its calculate Ovet Time 
			--CancelWeekOff Added by Ankit 16122015 */
	SET @Holiday_Date1_Cancel = '';
	SET @Weekoff_Date1_CancelStr = '';
	SET @Half_Holiday_Dates = '';
	SET @WEEKOFF_DATE1_CANCEL = '';

	SELECT @Weekoff_Date1_CancelStr = ISNULL(CancelWeekOff, '')
		,@Holiday_Date1_Cancel = ISNULL(CancelHoliday, '')
		,@Half_Holiday_Dates = IsNull(HalfHolidayDate, '')
	FROM #EMP_HW_CONS
	WHERE Emp_ID = @Emp_Id_Cur

	SELECT @Weekoff_Date1_Cancel = COALESCE(@Weekoff_Date1_Cancel + ';', '') + DATA
	FROM dbo.Split(@Weekoff_Date1_CancelStr, ';')
	WHERE Data <> ''
		AND NOT EXISTS (
			SELECT For_date
			FROM T0100_WEEKOFF_ROSTER
			WHERE Emp_id = @Emp_Id_Temp1
				AND is_Cancel_WO = 1
				AND For_date = CAST(DATA AS DATETIME)
			)

	IF @StrWeekoff_Date_OT <> ''
		SET @StrWeekoff_Date_OT = @StrWeekoff_Date_OT + @Weekoff_Date1_Cancel

	IF @Holiday_Date1_Cancel <> ''
		SET @StrHoliday_Date = @StrHoliday_Date + @Holiday_Date1_Cancel

	DECLARE @Trans_Week_OT AS TINYINT
	SET @Trans_Week_OT = 0
	SELECT @Trans_Week_OT = isnull(Tras_Week_OT, 0)
	FROM dbo.T0040_GENERAL_SETTING
	WHERE cmp_ID = @cmp_ID
		AND Branch_ID = @Branch_ID
		AND For_Date = (
			SELECT max(For_Date)
			FROM dbo.T0040_GENERAL_SETTING
			WHERE For_Date <= @To_Date
				AND Branch_ID = @Branch_ID
				AND Cmp_ID = @Cmp_ID
			)

	IF (charindex(cast(@For_Date AS VARCHAR(11)), @StrHoliday_Date, 0) > 0 OR charindex(cast(@For_Date AS VARCHAR(11)), @Half_Holiday_Dates, 0) > 0) AND @Trans_Week_OT = 1 
	BEGIN
		DECLARE @shift_Work_time_Sec AS NUMERIC(18, 3)
		SET @shift_Work_time_Sec = 0
		IF @Trans_Week_OT = 1
		BEGIN
			--Following condition modified by Nimesh on 17-Oct-2017 (If Holiday AND WeekOff is on same date and Holiday is being canceled.)
			IF charindex(cast(@For_Date AS VARCHAR(11)), @StrHoliday_Date, 0) > 0
				AND charindex(cast(@For_Date AS VARCHAR(11)), @StrWeekoff_Date_OT, 0) > 0
				UPDATE #Data
				SET OT_Sec = 0
					,Holiday_OT_Sec = OT_Sec + Holiday_OT_Sec
				FROM #Data AS data_t
				INNER JOIN #EMP_GEN_SETTINGS G ON data_t.Emp_Id = G.EMP_ID
				WHERE data_t.For_date = @For_Date
					AND Data_t.Emp_Id = @Emp_Id_Cur 
					AND G.Is_Cancel_Holiday_WO_HO_same_day = 0
			ELSE
				UPDATE #Data
				SET OT_Sec = 0
					,Holiday_OT_Sec = OT_Sec + Holiday_OT_Sec
				FROM #Data AS data_t
				WHERE data_t.For_date = @For_Date
					AND Data_t.Emp_Id = @Emp_Id_Cur 

			IF charindex(cast(@For_Date AS VARCHAR(11)), @Half_Holiday_Dates, 0) > 0
			BEGIN
				SELECT @shift_Work_time_Sec = Duration_In_Sec - (DATEDIFF(S, Shift_Start_Time, Shift_End_Time) / 2)
				FROM #Data
				WHERE For_date = @For_Date AND Emp_Id = @Emp_Id_Cur AND isnull(Emp_OT, 0) = 1

				UPDATE #Data
				SET OT_Sec = 0 ,Holiday_OT_Sec = @shift_Work_time_Sec ,P_days = P_days - 0.5
				FROM #Data AS data_t
				WHERE data_t.For_date = @For_Date AND Data_t.Emp_Id = @Emp_Id_Cur AND P_days = 1 
			END
		END
		ELSE
		BEGIN
			UPDATE #Data
			SET Holiday_OT_Sec = Ot_sec ,OT_Sec = 0
			WHERE Emp_Id = @Emp_Id_Cur AND For_Date = @For_Date
		END
	END

	
	IF charindex(cast(@For_Date AS VARCHAR(11)), @StrWeekoff_Date_OT, 0) > 0 AND @Trans_Week_OT = 1
	BEGIN
		IF CHARINDEX(CAST(@For_Date AS VARCHAR(11)), @StrHoliday_Date, 0) > 0
			UPDATE D
			SET OT_Sec = 0
				,Weekoff_OT_Sec = OT_Sec + Weekoff_OT_Sec
			FROM #DATA D
			INNER JOIN #EMP_GEN_SETTINGS G ON D.Emp_Id = G.EMP_ID
			WHERE D.For_date = @For_Date
				AND D.Emp_Id = @Emp_Id_Cur
				AND G.Is_Cancel_Holiday_WO_HO_same_day = 1
		ELSE
			UPDATE D
			SET OT_Sec = 0
				,Weekoff_OT_Sec = OT_Sec + Weekoff_OT_Sec
			FROM #DATA D
			WHERE For_date = @For_Date
				AND Emp_Id = @Emp_Id_Cur
	END

	SELECT @ot_start_time = OT_Start_Time
		,@shift_st_time1 = Shift_start_time
	FROM #DATA D
	INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
	WHERE First_In_Last_Out_For_InOut_Calculation = 0
		AND FOR_DATE = @for_date
		AND D.Emp_Id = @Emp_ID_Cur

	SELECT @Diff_Sec = SUM(Diff_Sec)
	FROM (
		SELECT CASE 
				WHEN Row = 1
					THEN CASE 
							WHEN @Shift_End_Time_Temp < out_time
								THEN DATEDIFF(s, @Shift_End_Time_Temp, Out_Time)
							ELSE 0
							END + CASE 
							WHEN @OT_Start_Time = 0
								THEN CASE 
										WHEN in_time < @shift_St_Time1
											THEN DATEDIFF(SECOND, in_time, @shift_St_Time1)
										ELSE 0
										END
							ELSE 0
							END
				WHEN @Shift_End_Time_Temp > In_Time
					AND Out_Time > @Shift_End_Time_Temp
					THEN DATEDIFF(s, @Shift_End_Time_Temp, Out_Time)
				WHEN @Shift_End_Time_Temp > Out_Time
					THEN 0
				ELSE DATEDIFF(s, In_Time, Out_Time)
				END AS Diff_Sec
		FROM (
			SELECT ROW_NUMBER() OVER (
					ORDER BY IO_Tran_Id
					) AS Row
				,IOUT.*
			FROM T0150_EMP_INOUT_RECORD IOUT
			INNER JOIN #EMP_GEN_SETTINGS ES ON IOUT.EMP_ID = ES.EMP_ID
			WHERE First_In_Last_Out_For_InOut_Calculation = 0
				AND (
					In_Time <= @Shift_St_Time1
					OR Out_Time >= @Shift_End_Time_Temp
					)
				AND For_Date = @For_Date
				AND IOUT.Emp_ID = @Emp_Id_Cur
			) AS Qry
		) AS Qry1

	------Added by Sid Ends.
	UPDATE #Data
	SET OT_Sec = ISNULL(@Diff_Sec, 0)
	FROM #DATA D
	INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
	WHERE First_In_Last_Out_For_InOut_Calculation = 0
		AND For_date = @For_Date
		AND D.Emp_Id = @Emp_Id_Cur
		AND OT_End_Time = 1
		AND Weekoff_OT_Sec = 0
		AND Holiday_OT_Sec = 0
		AND isnull(Emp_OT, 0) = 1
		AND ISNULL(D.Emp_OT_min_limit, 0) < ISNULL(@Diff_Sec, 0) -- Added by nilesh on 12102016 update OT Sec when OT Sec is less than Emp min OT 
	--End	

	FETCH NEXT
	FROM Cur_HO
	INTO @Emp_Id_Cur
		,@For_Date
		,@Shift_End_Time_Temp
END

CLOSE Cur_HO

DEALLOCATE Cur_HO
DECLARE @DIFF_HOUR AS NUMERIC(18, 2)
DECLARE @Total_second AS NUMERIC(18, 2)

SET @DIFF_HOUR = 0
SET @Total_second = 0

SELECT @DIFF_HOUR = CAST(Setting_Value AS NUMERIC(18, 2))
FROM T0040_SETTING
WHERE Cmp_ID = @Cmp_Id
	AND Setting_Name = 'Remove the Gap Between Two In-Out Punch from Working Hours'
	AND ISNUMERIC(Setting_Value) = 1

IF @DIFF_HOUR % 1.00 > 0
	SET @DIFF_HOUR = (@DIFF_HOUR * 100) / 60;

CREATE TABLE #DIFF (
	EMP_ID INT
	,FOR_DATE DATETIME
	,DIFF INT
	)

IF @DIFF_HOUR > 0
BEGIN
	SET @Total_second = (@DIFF_HOUR * 3600)

	INSERT INTO #DIFF
	SELECT EMP_ID
		,FOR_DATE
		,DATEDIFF(S, IN_TIME, OUT_TIME) - Duration_in_Sec
	FROM #Data
	WHERE In_Time IS NOT NULL
		AND OUT_Time IS NOT NULL

	DELETE
	FROM #DIFF
	WHERE DIFF < @Total_second
END

UPDATE #Data
SET 
	OT_Sec = (
		CASE 
			WHEN DATEDIFF(s, D.Shift_End_Time, D.OUT_Time) > ISNULL(D.Emp_OT_Max_limit, 0)
				AND ISNULL(D.Emp_OT_Max_limit, 0) > 0
				THEN ISNULL(D.Emp_OT_Max_limit, 0)
			ELSE DATEDIFF(s, D.Shift_End_Time, D.OUT_Time)
			END
		) 
FROM #Data D
LEFT JOIN #Emp_WeekOFf_Detail EWD ON D.emp_id = EWD.emp_id
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
LEFT JOIN #DIFF DF ON D.Emp_Id = DF.EMP_ID
	AND D.For_date = DF.FOR_DATE
WHERE Chk_otLimit_before_after_Shift_time = 0
	AND OT_End_Time = 1
	AND OUT_Time >= Shift_End_Time
	AND Weekoff_OT_Sec = 0
	AND Holiday_OT_Sec = 0
	AND isnull(Emp_OT, 0) = 1
	AND DATEDIFF(s, Shift_End_Time, OUT_Time) >= Emp_ot_min_limit
	AND Emp_ot_min_limit > 0
	AND D.for_date NOT IN (
		SELECT cast(data AS DATETIME)
		FROM dbo.Split(isnull(Ewd.strweekoff_Holiday, ''), ';')
		)

UPDATE #Data SET OT_Sec = 0 WHERE OT_Sec < 0

UPDATE #Data
SET OT_Sec = OT_Sec + (DATEDIFF(s, In_Time, Shift_Start_Time) - IsNull(DF.DIFF, 0))
FROM #Data D
LEFT JOIN #Emp_WeekOFf_Detail EWD ON D.emp_id = EWD.emp_id
INNER JOIN #EMP_GEN_SETTINGS ES ON D.EMP_ID = ES.EMP_ID
LEFT JOIN #DIFF DF ON D.Emp_Id = DF.EMP_ID AND D.For_date = DF.FOR_DATE AND (DATEDIFF(s, In_Time, Shift_Start_Time) - IsNull(DF.DIFF, 0)) > 0
WHERE Chk_otLimit_before_after_Shift_time = 0
	AND OT_Start_Time = 1
	AND In_Time <= Shift_Start_Time
	AND Weekoff_OT_Sec = 0
	AND Holiday_OT_Sec = 0 
	AND ISNULL(Emp_OT, 0) = 1
	AND DATEDIFF(s, In_Time, Shift_Start_Time) >= Emp_ot_min_limit
	AND Emp_ot_min_limit > 0
	AND D.for_date NOT IN (
		SELECT cast(data AS DATETIME)
		FROM dbo.Split(isnull(Ewd.strweekoff_Holiday, ''), ';')
	)

--END
UPDATE #Data
SET OT_Sec = 0
WHERE Emp_OT_Min_Limit > OT_sec
	AND OT_sec > 0

UPDATE #Data
SET OT_Sec = Emp_OT_Max_Limit
WHERE OT_sec > Emp_OT_Max_Limit
	AND Emp_OT_Max_Limit > 0
	AND OT_sec > 0


CREATE TABLE #EMP_Gate_Pass (
	 emp_ID NUMERIC(18, 0)
	,For_date DATETIME
	,GatePass_Deduct_Days NUMERIC(18, 2) DEFAULT 0
)


--ADD Deepal Get the GatePassDeductDays
DECLARE @GatePass_Deduct_Days AS NUMERIC(18, 2)
EXEC Calc_Gate_Pass_Present_Days_Deduction @Emp_ID ,@Cmp_ID ,@Branch_ID ,@From_Date ,@To_Date ,@GatePass_Deduct_Days OUTPUT ,@constraint ,1
--END Deepal Get the GatePassDeductDays

UPDATE #Data
SET GatePass_Deduct_Days = isnull(qry.GatePass_Deduct_Days, 0)
FROM #Data d
INNER JOIN (
	SELECT GP.emp_ID
		,GP.for_Date
		,isnull(sum(GP.gatePass_Deduct_Days), 0) AS gatePass_Deduct_Days
	FROM #Emp_Gate_Pass GP
	GROUP BY GP.Emp_ID
		,GP.For_date
	) qry ON qry.Emp_ID = d.Emp_Id
	AND qry.For_date = d.For_date

UPDATE #Data_temp1
SET GatePass_Deduct_Days = isnull(Qry.GatePass_Deduct_Days, 0)
FROM #Data_temp1 d
INNER JOIN (
	SELECT GP.emp_ID
		,GP.for_Date
		,isnull(sum(GP.gatePass_Deduct_Days), 0) AS gatePass_Deduct_Days
	FROM #Emp_Gate_Pass GP
	GROUP BY GP.Emp_ID
		,GP.For_date
	) Qry ON Qry.Emp_ID = d.Emp_Id
	AND Qry.For_date = d.For_date

--Added by Nilesh Patel on 20072018 For Cliantha -- Attendance Approval Process
UPDATE dt
SET dt.P_days = Q.P_Days
	,dt.OT_Sec = dt.Duration_in_sec 
FROM #Data dt
INNER JOIN (
	SELECT AA.Emp_id
		,AA.For_Date
		,P_Days
	FROM T0165_Attendance_Approval AA
	WHERE For_Date >= @From_Date
		AND For_Date <= @To_Date
		AND ATT_STATUS = 'A'
		AND P_Days <> 0
	) AS Q ON dt.Emp_ID = Q.Emp_ID
	AND dt.For_Date = Q.For_Date

DECLARE @Att_Emp_ID NUMERIC

SET @Att_Emp_ID = 0

IF EXISTS (SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >= @FROM_DATE AND FOR_DATE <= @TO_DATE AND ATT_STATUS = 'A')
BEGIN
	DECLARE CurAttApproval CURSOR
	FOR
		SELECT DISTINCT emp_id FROM #Data
	OPEN CurAttApproval
	FETCH NEXT
	FROM CurAttApproval
	INTO @Att_Emp_ID

	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO #Data (
			Emp_Id
			,For_date
			,Duration_in_sec
			,Shift_ID
			,Shift_Type
			,Emp_OT
			,Emp_OT_min_Limit
			,Emp_OT_max_Limit
			,P_days
			,OT_Sec
			,In_Time
			,Shift_Start_Time
			,OT_Start_Time
			,Shift_Change
			,Flag
			,Weekoff_OT_Sec
			,Holiday_OT_Sec
			,Chk_By_Superior
			,IO_Tran_Id
			,OUT_Time
			)
		SELECT AA.Emp_id
			,AA.For_Date
			,0
			,dbo.fn_get_Shift_From_Monthly_Rotation(Cmp_ID, Emp_ID, For_Date)
			,0
			,1
			,0
			,0
			,P_Days
			,0
			,For_Date
			,For_Date
			,0
			,0
			,0
			,0
			,0
			,0
			,0
			,For_Date
		FROM T0165_Attendance_Approval AA
		WHERE For_Date >= @From_Date
			AND For_Date <= @To_Date
			AND Emp_id = @Att_Emp_ID
			AND ATT_STATUS = 'A'
			AND P_Days <> 0
			AND NOT EXISTS (
				SELECT 1
				FROM #Data D
				WHERE D.Emp_ID = AA.Emp_ID
					AND D.For_Date = AA.For_Date
				)

		FETCH NEXT
		FROM CurAttApproval
		INTO @Att_Emp_ID
	END

	CLOSE CurAttApproval

	DEALLOCATE CurAttApproval
END

IF EXISTS (
		SELECT 1
		FROM T0165_ATTENDANCE_APPROVAL
		WHERE CMP_ID = @CMP_ID
			AND FOR_DATE >= @FROM_DATE
			AND FOR_DATE <= DateAdd(Day, 1, @TO_DATE)
			AND ATT_STATUS = 'A'
		)
BEGIN
	UPDATE DT
	SET DT.DURATION_IN_SEC = (
			CASE 
				WHEN DT.DURATION_IN_SEC > Q.SHIFT_SEC
					THEN DT.DURATION_IN_SEC - Q.SHIFT_SEC
				ELSE 0
				END
			)
		,DT.OT_SEC = CASE 
			WHEN DT.OT_SEC > Q.SHIFT_SEC
				THEN CASE 
						WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC)
							THEN 0
						ELSE (DT.OT_SEC - Q.SHIFT_SEC)
						END
			ELSE 0
			END
		,DT.Weekoff_OT_Sec = CASE 
			WHEN G.Tras_Week_OT = 1
				AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC
				THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC
			ELSE DT.Weekoff_OT_Sec
			END
		,DT.Holiday_OT_Sec = CASE 
			WHEN G.Tras_Week_OT = 1
				AND DT.Holiday_OT_Sec > Q.SHIFT_SEC
				THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC
			ELSE DT.Holiday_OT_Sec
			END
	FROM #DATA DT
	INNER JOIN (
		SELECT EMP_ID
			,DATEADD(D, - 1, FOR_DATE) AS FORDATE
			,P_DAYS
			,ATT_STATUS
			,SHIFT_SEC
		FROM T0165_ATTENDANCE_APPROVAL
		WHERE CMP_ID = @CMP_ID
			AND FOR_DATE >= @FROM_DATE
			AND FOR_DATE <= DateAdd(Day, 1, @TO_DATE)
			AND ATT_STATUS = 'A'
			AND P_Days <> 0
		) Q ON DT.EMP_ID = Q.EMP_ID
		AND DT.FOR_DATE = Q.FORDATE
	INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id = G.EMP_ID
END

----Add by Sid for OT Rounding off 21/05/2014 -----------------------------
DECLARE @OT_Emp NUMERIC ,@OT_Branch NUMERIC ,@OT_RoundingOff_To AS NUMERIC(18, 3) ,@OT_RoundingOff_Lower AS NUMERIC
DECLARE OTRoundCur CURSOR
FOR
	SELECT DISTINCT emp_id FROM #Data
OPEN OTRoundCur
FETCH NEXT FROM OTRoundCur INTO @OT_Emp
WHILE @@fetch_status = 0
BEGIN
	SELECT @OT_Branch = Branch_ID
	FROM T0095_INCREMENT t1
	INNER JOIN (
		SELECT emp_id
			,max(Increment_ID) AS Increment_ID
		FROM t0095_increment
		WHERE emp_id = @OT_Emp
			AND Increment_Effective_Date <= @To_Date
		GROUP BY emp_id
		) t2 
		ON t1.emp_id = t2.Emp_ID
		AND t1.Increment_ID = t2.Increment_ID
	WHERE t1.emp_id = @ot_Emp

	SELECT @OT_RoundingOff_To = OT_RoundingOff_To
		,@OT_RoundingOff_Lower = OT_RoundingOff_Lower
	FROM T0040_GENERAL_SETTING
	WHERE branch_id = @OT_Branch
		AND For_Date = (
			SELECT max(for_date)
			FROM T0040_General_Setting
			WHERE Branch_ID = @OT_Branch
	) 

	IF @ot_Roundingoff_to > 0
	BEGIN
		SET @OT_Roundingoff_To = CASE 
				WHEN @OT_Roundingoff_To = '0.15'
					THEN '0.25'
				WHEN @OT_Roundingoff_To = '0.30'
					THEN '0.50'
				WHEN @OT_Roundingoff_To = '0.45'
					THEN '0.75'
				WHEN @OT_Roundingoff_To = '1'
					THEN 1
				ELSE @OT_Roundingoff_To
			END
		
		IF @ot_roundingoff_lower = 0
		BEGIN
			UPDATE #Data
			SET OT_Sec = (
					floor((
							cast(CASE 
									WHEN Emp_OT_Max_Limit > 0
										THEN Original_OT_Sec
									ELSE OT_Sec
									END AS FLOAT) / cast(3600 AS FLOAT)
							) * (1 / @OT_RoundingOff_To)) / (1 / @OT_Roundingoff_To)
					) * 3600
				,Weekoff_OT_Sec = (floor((cast(Weekoff_OT_Sec AS FLOAT) / cast(3600 AS FLOAT)) * (1 / @OT_RoundingOff_To)) / (1 / @OT_Roundingoff_To)) * 3600
				,Holiday_OT_Sec = (floor((cast(Holiday_OT_Sec AS FLOAT) / cast(3600 AS FLOAT)) * (1 / @OT_RoundingOff_To)) / (1 / @OT_Roundingoff_To)) * 3600
			FROM #Data AS A INNER JOIN #Emp_Original_OT_Sec AS B ON A.Emp_Id = B.OT_Emp_Id AND A.For_date = B.For_date 
			WHERE emp_id = @OT_Emp
		END
		ELSE IF @OT_Roundingoff_lower = 1
		BEGIN
			UPDATE #Data
			SET OT_Sec = (
					ceiling((
							cast(CASE 
									WHEN Emp_OT_Max_Limit > 0
										THEN Original_OT_Sec
									ELSE OT_Sec
									END AS FLOAT) / cast(3600 AS FLOAT)
							) * (1 / @OT_RoundingOff_To)) / (1 / @OT_Roundingoff_To)
					) * 3600
				,Weekoff_OT_Sec = (ceiling((cast(Weekoff_OT_Sec AS FLOAT) / cast(3600 AS FLOAT)) * (1 / @OT_RoundingOff_To)) / (1 / @OT_Roundingoff_To)) * 3600
				,Holiday_OT_Sec = (ceiling((cast(Holiday_OT_Sec AS FLOAT) / cast(3600 AS FLOAT)) * (1 / @OT_RoundingOff_To)) / (1 / @OT_Roundingoff_To)) * 3600
			FROM #Data AS A INNER JOIN #Emp_Original_OT_Sec AS B ON A.Emp_Id = B.OT_Emp_Id AND A.For_date = B.For_date 
			WHERE emp_id = @OT_Emp
		END
		ELSE
		BEGIN
			BEGIN
				UPDATE #Data
				SET OT_Sec = (
						round((
								cast(CASE 
										WHEN Emp_OT_Max_Limit > 0
											THEN Original_OT_Sec
										ELSE OT_Sec
										END AS FLOAT) / cast(3600 AS FLOAT)
								) * (1 / @OT_RoundingOff_To), 0) / (1 / @OT_Roundingoff_To)
						) * 3600
					,Weekoff_OT_Sec = (round((cast(Weekoff_OT_Sec AS FLOAT) / cast(3600 AS FLOAT)) * (1 / @OT_RoundingOff_To), 0) / (1 / @OT_Roundingoff_To)) * 3600
					,Holiday_OT_Sec = (round((cast(Holiday_OT_Sec AS FLOAT) / cast(3600 AS FLOAT)) * (1 / @OT_RoundingOff_To), 0) / (1 / @OT_Roundingoff_To)) * 3600
				FROM #Data AS A INNER JOIN #Emp_Original_OT_Sec AS B ON A.Emp_Id = B.OT_Emp_Id AND A.For_date = B.For_date 
				WHERE emp_id = @OT_Emp
			END
		END
	END
		FETCH NEXT FROM OTRoundCur INTO @OT_Emp
END
CLOSE OTRoundCur
DEALLOCATE OTRoundCur

UPDATE #Data
SET OT_Sec = 0
WHERE Emp_OT_Min_Limit > OT_sec
	AND OT_sec > 0

UPDATE #Data
SET OT_Sec = Emp_OT_Max_Limit
WHERE OT_sec > Emp_OT_Max_Limit
	AND Emp_OT_Max_Limit > 0
	AND OT_sec > 0


--Deepal not sure but the #DATA logic end here 

IF @Return_Record_set = 2
	OR @Return_Record_set = 5
	OR @Return_Record_set = 8
	OR @Return_Record_set = 9
	OR @Return_Record_set = 10
	OR @Return_Record_set = 11
	OR @Return_Record_set = 12
	OR @Return_Record_set = 13
	OR @Return_Record_set = 14
	OR @Return_Record_set = 15
	OR @return_record_set = 16 
BEGIN
	CREATE TABLE #Data_Temp (
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
		,OUT_Time DATETIME
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
	
	DECLARE @Emp_ID_W NUMERIC
	DECLARE @For_date_W DATETIME

	DECLARE OT_Emp CURSOR FOR
		SELECT Emp_ID FROM #Emp_Cons
	OPEN OT_Emp
	FETCH NEXT FROM OT_Emp INTO @Emp_ID_W
	WHILE @@fetch_status = 0
	BEGIN
		DECLARE @StrWeekoff_Date_W VARCHAR(max)
		DECLARE @Weekoff_Days_W VARCHAR(max)
		DECLARE @Cancel_Weekoff_w VARCHAR(max)
		DECLARE @StrHoliday_Date_W VARCHAR(max)
		DECLARE @Holiday_days_W VARCHAR(max)
		DECLARE @Cancel_Holiday_W VARCHAR(max)
		DECLARE @OD_transfer_to_ot NUMERIC(1, 0)
		DECLARE @Branch_id_OD NUMERIC(4, 0)

		SELECT @BRANCH_ID_OD = Branch_id
		FROM t0095_increment
		WHERE Increment_ID = (
				SELECT max(Increment_ID)
				FROM t0095_increment
				WHERE emp_id = @Emp_ID_W
					AND increment_effective_date <= @To_Date
				)
			AND emp_id = @Emp_ID_W 

		SELECT @OD_transfer_to_ot = Is_OD_Transfer_to_OT
		FROM t0040_general_setting
		WHERE branch_id = @BRANCH_ID_OD
		AND For_Date = (
				SELECT max(for_date)
				FROM T0040_General_Setting
				WHERE Branch_ID = @BRANCH_ID_OD
		) 

		IF @OD_transfer_to_ot = 1
		BEGIN
			--Condition Added By Yogesh on 19082022 to Get Data  Branch Wise in Salary OT Approval Screen START
			IF @Emp_id != NULL
				OR @Emp_id = 0
			BEGIN
				SELECT @StrHoliday_Date_W = IsNull(HolidayDate, '')
					,@Holiday_days_W = IsNull(HolidayCount, 0)
					,@Cancel_Holiday_W = IsNull(CancelHoliday, '')
					,@StrWeekoff_Date_W = IsNull(WeekOffDate, '') + IsNull(CancelWeekOff, '')
					,@Weekoff_Days_W = IsNull(WeekOffCount, 0)
					,@Cancel_Weekoff_w = IsNull(CancelWeekOff, '')
				FROM #EMP_HW_CONS
				WHERE EMP_ID = @Emp_ID
			END
			ELSE
			BEGIN
				SELECT @StrHoliday_Date_W = IsNull(HolidayDate, '')
					,@Holiday_days_W = IsNull(HolidayCount, 0)
					,@Cancel_Holiday_W = IsNull(CancelHoliday, '')
					,@StrWeekoff_Date_W = IsNull(WeekOffDate, '') + IsNull(CancelWeekOff, '')
					,@Weekoff_Days_W = IsNull(WeekOffCount, 0)
					,@Cancel_Weekoff_w = IsNull(CancelWeekOff, '')
				FROM #EMP_HW_CONS
			END

			--Condition Added By Yogesh on 19082022 to Get Data  Branch Wise in Salary OT Approval Screen START
			DECLARE OT_For_Date CURSOR
			FOR
			SELECT CAST(DATA AS DATETIME) AS For_date
			FROM dbo.Split((@StrHoliday_Date_W), ';')
			OPEN OT_For_Date

			FETCH NEXT
			FROM OT_For_Date
			INTO @For_date_W

			WHILE @@FETCH_STATUS = 0
			BEGIN
				--select @For_date_W as fordate,@Emp_ID_W as empid
				--change by ronakk 09022023 condtion (Is_Approved <>0) after dicuss with sandeep bhai
				IF NOT EXISTS (
						SELECT Tran_Id
						FROM dbo.t0160_Ot_Approval
						WHERE Emp_ID = @Emp_ID_W
							AND For_Date = @For_date_W
							AND Is_Approved <> 0
						)
				BEGIN
					--Comment this condition by nilesh patel on 13082015 After Discuss with Hardik Bhai due to wrong details show in OT Approval
					INSERT INTO #Data_Temp (
						Emp_Id
						,For_date
						,Duration_in_sec
						,Shift_ID
						,Shift_Type
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,P_days
						,OT_Sec
						,In_Time
						,Shift_Start_Time
						,OT_Start_Time
						,Shift_Change
						,Flag
						,Weekoff_OT_Sec
						,Holiday_OT_Sec
						,Chk_By_Superior
						,IO_Tran_Id
						,OUT_Time
						)
					SELECT LA.Emp_id
						,@For_date_W
						,0
						,0
						,0
						,1
						,0
						,0
						,0
						,0
						,@For_date_W
						,@For_date_W
						,0
						,0
						,0
						,0
						,CASE 
							WHEN lad.half_leave_date = @For_date_W
								THEN 28800 / 2
							ELSE 28800
							END
						,0
						,0
						,@For_date_W
					FROM T0120_LEAVE_APPROVAL LA
					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
					INNER JOIN T0040_LEAVE_MASTER LM ON LAD.leave_id = LM.leave_id
					WHERE Leave_Type = 'Company Purpose'
						AND @for_date_W >= LAD.From_date
						AND @for_date_W <= LAD.To_Date
						AND Emp_id = @Emp_ID_W
						AND LA.Approval_Status = 'A'
				END

				FETCH NEXT
				FROM OT_For_Date
				INTO @For_date_W
			END

			CLOSE OT_For_Date

			DEALLOCATE OT_For_Date

			--exec [dbo].[SP_CALCULATE_PRESENT_DAYS] 120,'2022-06-01 00:00:00.000','2022-06-30 00:00:00.000',0,0,0,0,0,0,0,'27182#27272#27438#23274#24529#24530#24532#25288#23065#23066#24778#24542#25287#24783#24782#25286#14803#25504#25505#21478#21147#21954#19081#22070#22280#22331#22343#22345#22347#22519#22928#23425#23995#24051#24050#24058#14560#14561#14562#14563#14564#14565#14566#14567#14568#14813#18165#21094#21105#21162#21244#21247#21253#21274#21385#21428#21431#21437#21438#21439#21440#21441#21490#21491#21492#21500#21507#21554#21555#21556#21947#21951#22009#22010#22099#22107#22116#22122#22167#22276#23062#22296#22312#22678#22698#22699#22702#22703#22704#22705#22709#22710#22711#22712#22713#22714#22715#22725#22726#22728#22729#22730#22731#22929#22931#22932#22933#22934#22935#23036#23076#23106#23214#23220#23415#23417#23446#23789#23802#23803#23804#23805#23827#23890#23906#24518#24519#24054#24053#24055#24056#24520#24521#24522#24523#24524#24525#24526#24095#24101#24489#24490#24492#24493#24494#24495#24496#24497#24498#24499#24500#24501#24517#24528#24533#24534#24539#24540#24541#24544#24545#24559#24560#24561#24562#24564#24565#24571#24573#24582#24589#24590#24591#24592#24593#24594#24595#24597#24598#24599#24600#24601#24603#24604#24605#24606#24607#24608#24609#24610#24615#24620#24621#24622#24628#24630#24631#24633#24634#24635#24637#24638#24642#24646#24647#24650#24651#24653#24654#24655#24657#24658#24659#24660#24691#24692#24693#24694#24695#24698#24700#24701#24702#24703#24710#24737#24738#24739#24740#24757#24758#24788#25241#25256#25258#25259#25260#25261#25262#25263#25264#25265#25266#25267#25268#25272#25274#25277#25278#25279#25280#25281#25282#25290#25291#25292#25293#25297#25298#25299#25379#25386#25389#25390#25392#25498#25500#25512#25516#25517#25522#25523#25688#25689#25720#25730#25731#25732#25734#25796#25797#25798#25908#25909#25910#25917#26123#26126#26773#26778#26783#26784#26785#26786#26949#26950#26955#26957#26960#27111#27126#27123#27127#27128#27154#27155#27157#27158#27159#27160#27161#27162#27175#27183#27185#27186#27188#27201#27202#27215#27217#27219#27220#27230#27235#27236#27242#27244#27245#27246#27248#27249#27254#27263#27264#27271#27273#27274#27275#27276#27285#27288#27289#27290#27291#27292#27293#27294#27350#27352#27354#27357#27358#27390#27391#27395#27397#27398#27399#27400#27401#27402#27403#27406#27407#27409#27410#27411#27430#27431#27434#27435#27436#27739#27740#27741#27742#27743#27744#27745#27752#27773#27774#27775#27776#27777#27778#27779#27780#27781#27782#27783#27784#27785#27786#27787#27788#27789#27790#27793#27794#27795#27796#27797#27798#27801#27802#27803#27804#27806#27807#27808#27809#27810#27813#27814#27815#27816#27817#27819#27820#27821#27823#27824#27825#27826#27827#27828#27829#27831#27832#27833#27834#27836#27842#27843#27865#27866#27867#27889#27890#27891#27893#27906#27908#27912#27914#27915#27918#27920#27921#27922#27923#27924#27926#27927#27928#27929#27930#27931#27932#27933#27934#27935#27940#27941#27943#27944#27945#27946#27947#27948#27949#25375#25376#25373#25374#25372#27138',2		
			DECLARE OT_For_Date CURSOR
			FOR
			SELECT CAST(DATA AS DATETIME) AS For_date
			FROM dbo.Split((@StrWeekoff_Date_W), ';')
			WHERE CAST(DATA AS DATETIME) NOT IN (
					SELECT CAST(DATA AS DATETIME) AS For_date
					FROM dbo.Split((@StrHoliday_Date_W), ';')
					)

			OPEN OT_For_Date

			FETCH NEXT
			FROM OT_For_Date
			INTO @For_date_W

			WHILE @@FETCH_STATUS = 0
			BEGIN
				--change by ronakk 09022023 condtion (Is_Approved <>0) after dicuss with sandeep bhai
				IF NOT EXISTS (
						SELECT Tran_Id
						FROM dbo.t0160_Ot_Approval
						WHERE Emp_ID = @Emp_ID_W
							AND For_Date = @For_date_W
							AND Is_Approved <> 0
						)
				BEGIN
					INSERT INTO #Data_Temp (
						Emp_Id
						,For_date
						,Duration_in_sec
						,Shift_ID
						,Shift_Type
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,P_days
						,OT_Sec
						,In_Time
						,Shift_Start_Time
						,OT_Start_Time
						,Shift_Change
						,Flag
						,Weekoff_OT_Sec
						,Holiday_OT_Sec
						,Chk_By_Superior
						,IO_Tran_Id
						,OUT_Time
						)
					SELECT LA.Emp_id
						,@For_date_W
						,0
						,0
						,0
						,1
						,0
						,0
						,0
						,0
						,@For_date_W
						,@For_date_W
						,0
						,0
						,0
						,CASE 
							WHEN lad.half_leave_date = @For_date_W
								THEN 28800 / 2
							ELSE 28800
							END
						,0
						,0
						,0
						,@For_date_W
					FROM T0120_LEAVE_APPROVAL LA
					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
					INNER JOIN T0040_LEAVE_MASTER LM ON LAD.leave_id = LM.leave_id
					WHERE Leave_Type = 'Company Purpose'
						AND @for_date_W >= LAD.From_date
						AND @for_date_W <= LAD.To_Date
						AND Emp_id = @Emp_ID_W
						AND LA.Approval_Status = 'A'
				END

				FETCH NEXT
				FROM OT_For_Date
				INTO @For_date_W
			END

			CLOSE OT_For_Date

			DEALLOCATE OT_For_Date
		END

		FETCH NEXT
		FROM OT_Emp
		INTO @Emp_ID_W
	END

	CLOSE OT_Emp
	DEALLOCATE OT_Emp

	
	DECLARE @T_Emp_ID NUMERIC
	DECLARE @T_For_Date DATETIME
	DECLARE @Flag_cur_temp INT
	DECLARE @P_Days_Count NUMERIC(18, 3)
	SET @P_Days_Count = 0

	DECLARE OT_cursor CURSOR FOR
		SELECT d.Emp_ID ,d.For_Date FROM #Data d
	OPEN OT_cursor
	FETCH NEXT FROM OT_cursor INTO @T_Emp_ID ,@T_For_Date
	WHILE @@fetch_status = 0
	BEGIN
		IF NOT EXISTS (SELECT Tran_Id FROM dbo.t0160_Ot_Approval WHERE Emp_ID = @T_Emp_ID AND For_Date = @T_For_Date AND Is_Approved <> 0)
		BEGIN
			INSERT INTO #Data_Temp
			SELECT * FROM #Data WHERE Emp_ID = @T_Emp_ID AND For_Date = @T_For_Date
		END
		FETCH NEXT
		FROM OT_cursor INTO @T_Emp_ID ,@T_For_Date
	END
	CLOSE OT_cursor
	DEALLOCATE OT_cursor

	SET @P_Days_Count = (
			SELECT SUM(P_days)
			FROM #data
			WHERE Emp_ID = @T_Emp_ID
				AND Month(For_Date) = Month(@T_For_Date)
				AND IO_Tran_Id = 0
			)

	CREATE TABLE #Data_Temp_Test (
		Emp_Id NUMERIC
		,For_date DATETIME
		,Duration_in_sec NUMERIC
		,Shift_ID NUMERIC
		,Shift_Type NUMERIC
		,Emp_OT NUMERIC
		,Emp_OT_min_Limit NUMERIC
		,Emp_OT_max_Limit NUMERIC
		,P_days NUMERIC(12, 2) DEFAULT 0
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
		,OUT_Time DATETIME
		,Shift_End_Time DATETIME
		,OT_End_Time NUMERIC DEFAULT 0 
		)

	
	CREATE TABLE #Data_Gen (
		Emp_Id NUMERIC
		,For_Date DATETIME
		,Branch_Id NUMERIC
		,W_CompOff_Min_hours VARCHAR(500)
		,H_CompOff_Min_hours VARCHAR(500)
		,CompOff_Min_hours VARCHAR(500)
		)

	INSERT INTO #Data_Gen
	SELECT I.Emp_ID
		,G.For_Date
		,I.Branch_ID
		,G.W_CompOff_Min_Hours
		,G.H_CompOff_Min_hours
		,G.CompOff_Min_Hours
	FROM T0095_INCREMENT I
	INNER JOIN (
		SELECT MAX(I2.Increment_ID) AS Increment_ID
		FROM T0095_INCREMENT I2
		INNER JOIN (
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date
				,I3.EMP_ID
			FROM T0095_INCREMENT I3
			INNER JOIN #Data_Temp T ON I3.Emp_ID = T.Emp_Id
			WHERE Increment_Effective_Date <= @To_Date
				AND I3.Cmp_ID = @Cmp_ID
			GROUP BY I3.Emp_ID
			) I3 ON I2.Emp_ID = I3.Emp_ID
			AND I2.Increment_Effective_Date = I3.Increment_Effective_Date
		GROUP BY I2.Emp_ID
		) I2 ON I2.Increment_ID = I.Increment_ID
	INNER JOIN T0040_GENERAL_SETTING G ON I.Branch_ID = G.Branch_ID
		AND G.Cmp_ID = I.Cmp_ID
	INNER JOIN (
		SELECT MAX(GEN_ID) AS GEN_ID
		FROM T0040_GENERAL_SETTING G2
		INNER JOIN (
			SELECT MAX(G3.For_Date) AS FOR_DATE
				,G3.Branch_ID
			FROM T0040_GENERAL_SETTING G3
			WHERE G3.For_Date <= @To_Date
				AND G3.Cmp_ID = @Cmp_ID
			GROUP BY G3.Branch_ID
			) G3 ON G2.Branch_ID = G3.Branch_ID
			AND G2.For_Date = G3.FOR_DATE
		GROUP BY G2.Branch_ID
		) G2 ON G2.GEN_ID = G.Gen_ID
								
	IF @Return_Record_set = 2
	BEGIN
		--Commented Above code and New Code Added by Ramiz on 05/03/2016 as filters was not working in OT Approval Form
		IF @For_OT_APPROVAL = 0
			SELECT OA.*
				,QRY.Branch_ID
				,E.*
				,DBO.F_RETURN_HOURS(DURATION_IN_SEC) AS WORKING_HOUR
				,DBO.F_RETURN_HOURS(OT_SEC) AS OT_HOUR
				,FLAG
				,@P_DAYS_COUNT AS P_DAYS_COUNT
				,DBO.F_RETURN_HOURS(ISNULL(WEEKOFF_OT_SEC, 0)) AS WEEKOFF_OT_HOUR
				,DBO.F_RETURN_HOURS(HOLIDAY_OT_SEC) AS HOLIDAY_OT_HOUR
				,QRY.Branch_ID AS INC_BRANCH_ID
				,QRY.Dept_ID AS INC_DEPT_ID
				,QRY.Grd_ID AS INC_GRD_ID
			FROM #DATA_TEMP OA
			INNER JOIN DBO.T0080_EMP_MASTER E ON OA.EMP_ID = E.EMP_ID
			INNER JOIN (
				SELECT MAX(I2.Increment_ID) AS Increment_ID
					,I2.Emp_ID
					,I2.Branch_ID
					,I2.Dept_ID
					,I2.Grd_ID
				FROM T0095_INCREMENT I2
				INNER JOIN (
					SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date
						,I3.EMP_ID
					FROM T0095_INCREMENT I3
					INNER JOIN #DATA_TEMP T ON I3.Emp_ID = T.Emp_Id
					WHERE Increment_Effective_Date <= @To_Date
						AND I3.Cmp_ID = @Cmp_ID
					GROUP BY I3.Emp_ID
					) I3 ON I2.Emp_ID = I3.Emp_ID
					AND I2.Increment_Effective_Date = I3.Increment_Effective_Date
				GROUP BY I2.Emp_ID
					,I2.Branch_ID
					,I2.Dept_ID
					,I2.Grd_ID
				) QRY ON QRY.Emp_ID = OA.Emp_Id
			INNER JOIN T0095_INCREMENT IE ON IE.EMP_ID = QRY.EMP_ID
				AND IE.Increment_ID = QRY.Increment_ID
			WHERE (
					OT_SEC > 0
					OR WEEKOFF_OT_SEC > 0
					OR HOLIDAY_OT_SEC > 0
					)
				AND QRY.Branch_ID = IsNull(@BRANCH_ID_FOR_OT, QRY.Branch_ID)
				AND isnull(QRY.Dept_ID, 0) = COALESCE(@DEPT_ID_FOR_OT, QRY.Dept_ID, 0) 
				AND QRY.Grd_ID = ISNULL(@GRD_ID_FOR_OT, QRY.Grd_ID)
				AND (
					(
						IE.EMP_HOLIDAY_OT_RATE <> 0
						AND DBO.F_RETURN_HOURS(HOLIDAY_OT_SEC) <> '00:00'
						)
					OR (
						IE.EMP_WEEKOFF_OT_RATE <> 0
						AND DBO.F_RETURN_HOURS(ISNULL(WEEKOFF_OT_SEC, 0)) <> '00:00'
						)
					OR (
						IE.EMP_WEEKDAY_OT_RATE <> 0
						AND DBO.F_RETURN_HOURS(OT_SEC) <> '00:00'
						)
					)
			ORDER BY OA.FOR_DATE
	-- Ended by Ramiz on 05/03/2016 as filters was not working in OT Approval Form  
	END
	ELSE IF @Return_Record_set = 8
	BEGIN
		-- If (@Is_WD = 1 And @Is_WOHO = 1)
		BEGIN
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(OT_SEC, 0) + isnull(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec + ISNULL(OT_Sec, 0) + ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Approve_Status AS Application_Status
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			WHERE Cast(Replace(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
				OR Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
				OR Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
			
			UNION
			
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(OT_SEC, 0) + isnull(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec + ISNULL(OT_Sec, 0) + ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Application_Status
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			WHERE Cast(Replace(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
				OR Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
				OR Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
			
			UNION
			
			SELECT Qry1.*
			FROM (
				SELECT dt.*
					,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
					,dbo.F_Return_Hours(ISNULL(OT_SEC, 0) + isnull(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
					,dbo.F_Return_Hours(Duration_in_Sec + ISNULL(OT_Sec, 0) + ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
					,@P_Days_Count AS P_Days_Count
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
					,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
					,'-' AS application_status
				FROM #Data_Temp DT
				WHERE For_date NOT IN (
						SELECT For_date
						FROM #Data_Temp OA
						INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						WHERE Cast(Replace(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
							OR Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
							OR Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
						
						UNION
						
						SELECT For_date
						FROM #Data_Temp OA
						INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						WHERE Cast(Replace(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
							OR Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
							OR Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
						)
				) Qry1
			INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
			WHERE Cast(Replace(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(Em.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
				OR Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(Em.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
				OR Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= Cast(Replace(Em.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
			ORDER BY OA.For_Date
		END
	END
	ELSE IF @Return_Record_set = 9
	BEGIN
		BEGIN
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
				,CASE 
					WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
						OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
						THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
					ELSE dbo.F_Return_Hours(0)
					END AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Approve_Status AS Application_Status
				,'WD' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			INNER JOIN (
				SELECT t1.emp_id
					,branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID 
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON oa.emp_id = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.For_Date
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
			
			UNION
			
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
				,CASE 
					WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
						OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
						THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
					ELSE dbo.F_Return_Hours(0)
					END AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Application_Status
				,'WD' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			INNER JOIN (
				SELECT t1.emp_id
					,branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) 
						AS Increment_ID
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON oa.emp_id = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.For_Date
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
			
			UNION
			
			SELECT Qry1.*
			FROM (
				SELECT dt.*
					,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
					,CASE 
						WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
							OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
							THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
						ELSE dbo.F_Return_Hours(0)
						END AS OT_Hour
					,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
					,@P_Days_Count AS P_Days_Count
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
					,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
					,'-' AS application_status
					,'WD' AS DayFlag
					,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
					,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
					,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
				FROM #Data_Temp DT
				WHERE For_date NOT IN (
						SELECT OA.For_Date
						FROM [#Data_Temp] AS OA
						INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						INNER JOIN (
							SELECT t1.Emp_ID
								,t1.Branch_ID
							FROM T0095_INCREMENT t1
							INNER JOIN (
								SELECT Emp_ID
									,MAX(Increment_ID) AS Increment_ID 
								FROM T0095_INCREMENT
								WHERE cmp_ID = @cmp_ID
								GROUP BY Emp_ID
								) AS t2 ON t1.emp_id = t2.Emp_ID
								AND t1.Increment_ID = t2.Increment_ID
							) AS inc ON OA.Emp_ID = inc.Emp_ID
						INNER JOIN (
							SELECT GS.gen_ID
								,GS.Branch_ID
								,GS.CompOff_Min_hours
							FROM T0040_General_Setting GS
							INNER JOIN (
								SELECT Branch_ID
									,max(For_Date) AS For_Date
								FROM T0040_General_Setting
								WHERE cmp_ID = @Cmp_ID
									AND For_Date <= @To_Date
								GROUP BY Branch_ID
								) qry ON Qry.For_Date = GS.For_Date
								AND qry.Branch_ID = GS.Branch_ID
							) gs ON gs.branch_id = inc.branch_id
						WHERE (
								CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
									WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
										THEN CAST(REPLACE(Isnull(CASE 
															WHEN E.CompOff_Min_hrs = ''
																THEN '00:00'
															ELSE e.CompOff_Min_hrs
															END, '00:00'), ':', '.') AS NUMERIC(18, 3))
									ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
									END
								)
							AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
						
						UNION
						
						SELECT OA.For_Date
						FROM [#Data_Temp] AS OA
						INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						INNER JOIN (
							SELECT t1.Emp_ID
								,t1.Branch_ID
							FROM T0095_INCREMENT t1
							INNER JOIN (
								SELECT Emp_ID
									,MAX(Increment_ID) -- Ankit 12092014 for Same Date Increment
									AS Increment_ID
								FROM T0095_INCREMENT
								WHERE cmp_ID = @cmp_ID
								GROUP BY Emp_ID
								) AS t2 ON t1.emp_id = t2.Emp_ID
								AND t1.Increment_ID = t2.Increment_ID
							) AS inc ON OA.Emp_ID = inc.Emp_ID
						INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
						WHERE (
								CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
									WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
										THEN CAST(REPLACE(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
									ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
									END
								)
							AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
						)
				) Qry1
			INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON Qry1.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_date = GS.For_date
					AND Qry.Branch_ID = GS.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(isnull(CASE 
										WHEN gs.CompOff_Min_hours = ''
											THEN '00:00'
										ELSE gs.CompOff_Min_hours
										END, '00:00'), ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(isnull(CASE 
											WHEN Em.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE Em.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(isnull(CASE 
										WHEN gs.CompOff_Min_hours = ''
											THEN '00:00'
										ELSE gs.CompOff_Min_hours
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					END
				AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
			ORDER BY OA.For_Date
		END
	END
	ELSE IF @Return_Record_set = 10
	BEGIN
		IF (
				@Is_HO_CompOff = 1
				OR @Is_HO_CompOff IS NULL
				)
		BEGIN
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,
				--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
				--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
				CA.Extra_Work_Hours AS OT_Hour
				,CA.Sanctioned_Hours AS Actual_Workerd_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Approve_Status AS Application_Status
				,'HO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON OA.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.H_CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND EXISTS (
					SELECT 1
					FROM #EMP_HOLIDAY HO
					WHERE HO.IS_CANCEL = 0
						AND HO.EMP_ID = OA.EMP_ID
						AND HO.FOR_DATE = OA.FOR_DATE
					) -- ADDED BY GADRIWALA MUSLIM 0312016
			
			UNION
			
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Application_Status
				,'HO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON OA.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.H_CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND OA.For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
				AND EXISTS (
					SELECT 1
					FROM #EMP_HOLIDAY HO
					WHERE HO.IS_CANCEL = 0
						AND HO.EMP_ID = OA.EMP_ID
						AND HO.FOR_DATE = OA.FOR_DATE
					) -- ADDED BY GADRIWALA MUSLIM 0312016
			
			UNION
			
			SELECT Qry1.*
			FROM (
				SELECT dt.*
					,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
					,@P_Days_Count AS P_Days_Count
					,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
					,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
					,'-' AS application_status
					,'HO' AS DayFlag
					,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
					,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
					,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
				FROM #Data_Temp DT
				WHERE For_date NOT IN (
						SELECT For_date
						FROM #Data_Temp OA
						INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
							AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
						
						UNION
						
						SELECT For_date
						FROM #Data_Temp OA
						INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE E.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
							OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						)
					AND (
						CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
						OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
						)
				) Qry1
			INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON Qry1.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.H_CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND qry.Branch_ID = Gs.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN Em.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE em.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND EXISTS (
					SELECT 1
					FROM #EMP_HOLIDAY HO
					WHERE HO.IS_CANCEL = 0
						AND HO.EMP_ID = Qry1.EMP_ID
						AND HO.FOR_DATE = Qry1.FOR_DATE
					) -- ADDED BY GADRIWALA MUSLIM 0312016				  
			
			UNION -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
			
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'HO-G' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON OA.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.For_Date
					,Gs.Branch_ID
					,H_CompOff_Min_Hours
				FROM T0040_GENERAL_SETTING GS
				INNER JOIN (
					SELECT MAX(For_date) AS For_Date
						,Branch_ID
					FROM T0040_General_Setting gs
					WHERE Cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) Qry ON Qry.Branch_ID = GS.Branch_ID
					AND Qry.For_Date = GS.For_Date
				) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
			INNER JOIN (
				SELECT max(GP.In_Time) AS In_Time
					,GP.emp_id
					,GP.For_Date
					,Is_Approved
					,Reason_id
				FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
				INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
					AND OA.For_date = GP.For_date
					AND GP.Is_Approved = 1
				INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
					AND Type = 'GatePass'
					AND Gate_Pass_Type = 'Official'
				GROUP BY GP.Emp_ID
					,GP.For_Date
					,GP.Is_Approved
					,GP.Reason_id
				) GPQuery ON OA.emp_id = GPQuery.emp_ID
				AND OA.For_date = GPQuery.For_date
			WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND OA.For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
				AND EXISTS (
					SELECT 1
					FROM #EMP_HOLIDAY HO
					WHERE HO.IS_CANCEL = 0
						AND HO.EMP_ID = OA.EMP_ID
						AND HO.FOR_DATE = OA.FOR_DATE
					) -- ADDED BY GADRIWALA MUSLIM 0312016
			ORDER BY OA.For_Date
		END
	END
	ELSE IF @Return_Record_set = 11
	BEGIN
		SELECT @Is_W_CompOff = GS.Is_W_CompOff
		FROM T0040_General_Setting GS
		INNER JOIN (
			SELECT Branch_ID
				,max(For_Date) AS For_Date
			FROM T0040_General_Setting
			WHERE cmp_ID = @Cmp_ID
				AND For_Date <= @To_Date
			GROUP BY Branch_ID
			) qry ON Qry.For_Date = GS.For_Date
			AND Qry.Branch_ID = GS.Branch_ID
		INNER JOIN #Emp_Cons EC ON gs.Branch_ID = EC.Branch_ID

		IF (@Is_W_CompOff = 1)
		BEGIN
			-- Added Nilesh Patel on 20072018 --For Cliantha -- if Employee Working 18 Hours next absent day adjust with previouse day OT and Deduct working hours from OT.
			--IF Exists(SELECT 1 FROM T0165_ATTENDANCE_APPROVAL WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A')
			--	Begin
			--		UPDATE DT
			--			SET DT.DURATION_IN_SEC = (Case When DT.DURATION_IN_SEC > Q.SHIFT_SEC Then DT.DURATION_IN_SEC - Q.SHIFT_SEC Else 0 END),
			--				DT.OT_SEC = CASE WHEN DT.OT_SEC > Q.SHIFT_SEC THEN 
			--								CASE WHEN DT.Emp_OT_Min_Limit > (DT.OT_SEC - Q.SHIFT_SEC) THEN	
			--									0
			--								ELSE  (DT.OT_SEC - Q.SHIFT_SEC) END
			--							ELSE 0 END,
			--				DT.Weekoff_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Weekoff_OT_Sec > Q.SHIFT_SEC THEN DT.Weekoff_OT_Sec - Q.SHIFT_SEC ELSE DT.Weekoff_OT_Sec END,
			--				DT.Holiday_OT_Sec = CASE WHEN G.Tras_Week_OT = 1 AND DT.Holiday_OT_Sec > Q.SHIFT_SEC THEN DT.Holiday_OT_Sec - Q.SHIFT_SEC ELSE DT.Holiday_OT_Sec END
			--		FROM #DATA_TEMP DT INNER JOIN 
			--		(
			--				SELECT EMP_ID,DATEADD(D,-1,FOR_DATE) AS FORDATE,P_DAYS,ATT_STATUS,SHIFT_SEC
			--				FROM T0165_ATTENDANCE_APPROVAL
			--				WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE AND ATT_STATUS = 'A' AND P_DAYS <> 0
			--		)Q ON DT.EMP_ID =Q.EMP_ID  AND DT.FOR_DATE = Q.FORDATE
			--		INNER JOIN #EMP_GEN_SETTINGS G ON DT.Emp_Id=G.EMP_ID
			--	End
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,
				--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS OT_Hour,
				--dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec,0) + ISNULL(Holiday_OT_Sec,0)) AS Actual_Worked_Hrs,
				CA.Extra_Work_Hours AS OT_Hour
				,CA.Sanctioned_Hours AS Actual_Workerd_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Approve_Status AS Application_Status
				,'WO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON OA.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.W_CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND EXISTS (
					SELECT 1
					FROM #EMP_WEEKOFF WK
					WHERE WK.IS_CANCEL = 0
						AND WK.EMP_ID = OA.EMP_ID
						AND WK.FOR_DATE = OA.FOR_DATE
					) -- Added by Gadriwala Muslim 0312016
			
			UNION
			
			SELECT OA.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,CA.Application_Status
				,'WO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
				AND OA.For_date = CA.Extra_Work_Date
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON OA.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.W_CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND OA.For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
				AND EXISTS (
					SELECT 1
					FROM #EMP_WEEKOFF WK
					WHERE WK.IS_CANCEL = 0
						AND WK.EMP_ID = OA.EMP_ID
						AND WK.FOR_DATE = OA.FOR_DATE
					) -- Added by Gadriwala Muslim 0312016
			
			UNION
			
			SELECT Qry1.*
			FROM (
				SELECT dt.*
					,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
					,@P_Days_Count AS P_Days_Count
					,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
					,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
					,'-' AS application_status
					,'WO' AS DayFlag
					,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
					,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
					,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
				FROM #Data_Temp DT
				WHERE For_date NOT IN (
						SELECT For_date
						FROM #Data_Temp OA
						INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
							AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
						
						UNION
						
						SELECT For_date
						FROM #Data_Temp OA
						INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
						INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
							AND OA.For_date = CA.Extra_Work_Date
						WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						)
					AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				) Qry1
			INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON Qry1.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.gen_ID
					,GS.Branch_ID
					,GS.W_CompOff_Min_hours
				FROM T0040_General_Setting GS
				INNER JOIN (
					SELECT Branch_ID
						,max(For_Date) AS For_Date
					FROM T0040_General_Setting
					WHERE cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) qry ON Qry.For_Date = GS.For_Date
					AND Qry.Branch_ID = GS.Branch_ID
				) gs ON gs.branch_id = inc.branch_id
			WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN Em.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE em.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND EXISTS (
					SELECT 1
					FROM #EMP_WEEKOFF WK
					WHERE WK.IS_CANCEL = 0
						AND WK.EMP_ID = QRY1.EMP_ID
						AND WK.FOR_DATE = QRY1.FOR_DATE
					) -- Added by Gadriwala Muslim 0312016
			
			UNION -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
			
			SELECT OA.*
				,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)) AS Working_Hour
				,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WO-G' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, OA.shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), GPQuery.IN_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp OA
			INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
			INNER JOIN (
				SELECT t1.emp_id
					,t1.branch_id
				FROM T0095_Increment t1
				INNER JOIN (
					SELECT emp_id
						,MAX(Increment_ID) AS Increment_ID
					FROM t0095_increment
					WHERE cmp_ID = @cmp_ID
					GROUP BY emp_id
					) AS t2 ON t1.emp_id = t2.emp_id
					AND t1.Increment_ID = t2.Increment_ID
				) AS inc ON OA.Emp_ID = inc.emp_id
			INNER JOIN (
				SELECT GS.For_Date
					,Gs.Branch_ID
					,W_CompOff_Min_hours
				FROM T0040_GENERAL_SETTING GS
				INNER JOIN (
					SELECT MAX(For_date) AS For_Date
						,Branch_ID
					FROM T0040_General_Setting gs
					WHERE Cmp_ID = @Cmp_ID
						AND For_Date <= @To_Date
					GROUP BY Branch_ID
					) Qry ON Qry.Branch_ID = GS.Branch_ID
					AND Qry.For_Date = GS.For_Date
				) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
			INNER JOIN (
				SELECT max(GP.In_Time) AS In_Time
					,GP.emp_id
					,GP.For_Date
					,Is_Approved
					,Reason_id
				FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
				INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
					AND OA.For_date = GP.For_date
					AND GP.Is_Approved = 1
				INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
					AND Type = 'GatePass'
					AND Gate_Pass_Type = 'Official'
				GROUP BY GP.Emp_ID
					,GP.For_Date
					,GP.Is_Approved
					,GP.Reason_id
				) GPQuery ON OA.emp_id = GPQuery.emp_ID
				AND OA.For_date = GPQuery.For_date
			WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
					WHEN CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
						THEN CAST(REPLACE(Isnull(CASE 
											WHEN E.CompOff_Min_hrs = ''
												THEN '00:00'
											ELSE e.CompOff_Min_hrs
											END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					ELSE CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
					END
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				AND OA.For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
				AND EXISTS (
					SELECT 1
					FROM #EMP_WEEKOFF WK
					WHERE WK.IS_CANCEL = 0
						AND WK.EMP_ID = OA.EMP_ID
						AND WK.FOR_DATE = OA.FOR_DATE
					) -- Added by Gadriwala Muslim 0312016
			ORDER BY OA.For_Date
		END
	END
	ELSE IF @return_record_set = 12 -- Changed by Gadriwala Muslim 25112015 for Auto OD
	BEGIN
		EXEC getAllDaysBetweenTwoDate @from_Date
			,@to_Date

		INSERT INTO #data_temp_test
		SELECT t1.Emp_ID
			,t2.test1 AS For_Date
			,0 AS Duration_in_Sec
			,1 AS Shift_ID
			,0 AS shift_type
			,1 AS Emp_OT
			,0 AS Emp_OT_min_Limit
			,0 AS Emp_OT_max_Limit
			,0 AS P_Days
			,(
				SELECT CASE 
						WHEN Leave_Assign_As <> 'Full Day'
							AND Half_Leave_Date = t2.test1
							THEN dbo.F_Return_Sec(Shift_Dur) / 2
						WHEN Leave_Assign_As = 'Part Day'
							AND IsNull(Half_Leave_Date, '1900-01-01') = '1900-01-01'
							THEN -- Added by Rajput on 13122018 As per discussed with Nimesh Bhai ( Inductotherm Client )															
								CASE 
									WHEN Leave_Period % 1 > 0
										THEN (8 / Leave_Period) * 3600
									ELSE Leave_Period * 3600
									END
						ELSE dbo.F_Return_Sec(Shift_Dur)
						END AS Shift_Dur
				FROM T0040_SHIFT_MASTER SM
				WHERE Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID, @Emp_ID, t2.test1)
				) AS OT_Sec
			,test1 AS In_Time
			,test1 AS Shift_Start_Time
			,0 AS OT_Start_Time
			,0 AS Shift_Change
			,0 AS Flag
			,0 AS Weekoff_OT_Sec
			,0 AS Holiday_OT_Sec
			,0 AS Chk_By_Superior
			,0 AS IO_Trans_ID
			,test1 AS OUT_Time
			,test1 AS Shift_End_Time
			,0 AS OT_End_Time
		FROM (
			SELECT la.Emp_ID
				,lad.From_Date
				,lad.To_Date
				,lad.Leave_Assign_As
				,lad.Half_Leave_Date
				,lad.Leave_Period
			FROM (
				SELECT la.*
				FROM T0120_LEAVE_APPROVAL la
				LEFT JOIN T0150_LEAVE_CANCELLATION lc ON la.Leave_Approval_ID = lc.Leave_Approval_id
					AND la.Cmp_ID = lc.Cmp_Id
				WHERE ISNULL(Is_Approve, 0) = 0
				) AS la
			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL AS lad ON la.Leave_Approval_ID = lad.Leave_Approval_ID
				AND la.Cmp_ID = lad.Cmp_ID
			INNER JOIN T0040_LEAVE_MASTER AS lt ON la.Cmp_ID = lt.Cmp_ID
				AND lad.Leave_ID = lt.Leave_ID
			WHERE (la.Emp_ID = @Emp_ID)
				AND (lt.Leave_Type = 'Company Purpose')
				AND (la.Approval_Status = 'A')
			) AS t1
		CROSS JOIN test1 AS t2
		WHERE t2.test1 >= from_Date
			AND t2.test1 <= to_date
		ORDER BY For_Date

		SELECT dtt.*
			,0 AS Working_Hrs_St_Time
			,0 AS Working_Hrs_End_Time
			,0 AS GatePass_Deduct_Days
			,'00:00' AS Working_Hour
			,dbo.F_Return_Hours(dtt.OT_Sec) AS OT_Hour
			,dbo.F_Return_Hours(dtt.OT_Sec) AS Actual_Worked_Hrs
			,0.00 AS P_Days_Count
			,'00:00' AS Weekoff_OT_Hours
			,'00:00' AS Holiday_OT_Hours
			,ISNULL(ca.Application_Status, ISNULL(capr.Approve_Status, '')) AS Application_Status
			,-- Changed  by Gadriwala Muslim 02042015
			'OD' AS DayFlag
			,'00:00' AS Shift_Hours
			,CAST('00:00:00' AS VARCHAR(8)) AS In_Time_Actual
			,CAST('00:00:00' AS VARCHAR(8)) AS Out_Time_Actual
		FROM #Data_Temp_test AS dtt
		LEFT JOIN t0100_Compoff_Application AS ca ON dtt.emp_id = ca.emp_id
			AND dtt.For_Date = ca.Extra_Work_Date
		LEFT JOIN T0120_CompOff_Approval AS CApr ON dtt.Emp_Id = CApr.Emp_ID
			AND dtt.For_date = CApr.Extra_Work_Date -- Changed  by Gadriwala Muslim 02042015
	END
	ELSE IF @return_record_set = 13 -- HO & WO & WD
	BEGIN
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,Cast('WO' AS VARCHAR(20)) AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		INTO #HO_WO_WD
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016

		--UNION										
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'WO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = E.Emp_ID
					AND T.For_date = OA.For_date
				)

		--UNION	
		INSERT INTO #HO_WO_WD
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					)
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			) Qry1
		INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = Qry1.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = QRY1.EMP_ID
					AND WK.FOR_DATE = QRY1.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = Qry1.Emp_ID
					AND T.For_date = Qry1.For_date
				)

		--union	-- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)) AS Working_Hour
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'WO-G' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, OA.shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), GPQuery.IN_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		INNER JOIN (
			SELECT max(GP.In_Time) AS In_Time
				,GP.emp_id
				,GP.For_Date
				,Is_Approved
				,Reason_id
			FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
			INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
				AND OA.For_date = GP.For_date
				AND GP.Is_Approved = 1
			INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
				AND Type = 'GatePass'
				AND Gate_Pass_Type = 'Official'
			GROUP BY GP.Emp_ID
				,GP.For_Date
				,GP.Is_Approved
				,GP.Reason_id
			) GPQuery ON OA.emp_id = GPQuery.emp_ID
			AND OA.For_date = GPQuery.For_date
		WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND OA.For_date NOT IN (
				SELECT For_date
				FROM #Data_Temp OA
				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
					AND OA.For_date = CA.Extra_Work_Date
				WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
									WHEN E.CompOff_Min_hrs = ''
										THEN '00:00'
									ELSE e.CompOff_Min_hrs
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--Added By Jaina 2-12-2015 Start
		--UNION
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,'-' AS Application_Status
			,'WO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND NOT EXISTS (
				SELECT 1
				FROM (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					) T
				WHERE T.FOR_DATE = OA.FOR_DATE
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--Added By Jaina 2-12-2015 End
		--Union 
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,'HO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--UNION
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'HO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--UNION
		INSERT INTO #HO_WO_WD
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'HO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE E.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					)
				AND (
					CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
					OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
					)
			) Qry1
		INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = Qry1.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = QRY1.EMP_ID
					AND HO.FOR_DATE = QRY1.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = Qry1.Emp_ID
					AND T.For_date = Qry1.For_date
				)

		--Union -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'HO-G' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		INNER JOIN (
			SELECT max(GP.In_Time) AS In_Time
				,GP.emp_id
				,GP.For_Date
				,Is_Approved
				,Reason_id
			FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
			INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
				AND OA.For_date = GP.For_date
				AND GP.Is_Approved = 1
			INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
				AND Type = 'GatePass'
				AND Gate_Pass_Type = 'Official'
			GROUP BY GP.Emp_ID
				,GP.For_Date
				,GP.Is_Approved
				,GP.Reason_id
			) GPQuery ON OA.emp_id = GPQuery.emp_ID
			AND OA.For_date = GPQuery.For_date
		WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND OA.For_date NOT IN (
				SELECT For_date
				FROM #Data_Temp OA
				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
					AND OA.For_date = CA.Extra_Work_Date
				WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
									WHEN E.CompOff_Min_hrs = ''
										THEN '00:00'
									ELSE e.CompOff_Min_hrs
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--Added By Jaina 2-12-2015 For (Holiday) Start
		--UNION
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'HO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND NOT EXISTS (
				SELECT 1
				FROM (
					--Change By Jaina 9-12-2015 Filed Holiday_OT_Sec in both query
					SELECT FOR_DATE
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT FOR_DATE
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					) T
				WHERE T.FOR_DATE = OA.FOR_DATE
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--Added By Jaina 2-12-2015 End 													
		--UNION		
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
			,CASE 
				WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
					OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
					THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
				ELSE dbo.F_Return_Hours(0)
				END AS OT_Hour
			,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,'WD' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--UNION
		INSERT INTO #HO_WO_WD
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
			,CASE 
				WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
					OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
					THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
				ELSE dbo.F_Return_Hours(0)
				END AS OT_Hour
			,dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'WD' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = OA.Emp_ID
					AND T.For_date = OA.For_date
				)

		--UNION
		INSERT INTO #HO_WO_WD
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
				,CASE 
					WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
						OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
						THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
					ELSE dbo.F_Return_Hours(0)
					END AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WD' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT OA.For_Date
					FROM [#Data_Temp] AS OA
					INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
					WHERE (
							CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
								WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
									THEN CAST(REPLACE(Isnull(CASE 
														WHEN E.CompOff_Min_hrs = ''
															THEN '00:00'
														ELSE e.CompOff_Min_hrs
														END, '00:00'), ':', '.') AS NUMERIC(18, 3))
								ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
								END
							)
						AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT OA.For_Date
					FROM [#Data_Temp] AS OA
					INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					INNER JOIN #Data_Gen AS gs ON gs.Emp_id = OA.Emp_Id
					WHERE (
							CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
								WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
									THEN CAST(REPLACE(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
								ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
								END
							)
						AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
			) Qry1
		INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN #Data_Gen AS gs ON gs.Emp_id = Qry1.Emp_Id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(isnull(CASE 
									WHEN gs.CompOff_Min_hours = ''
										THEN '00:00'
									ELSE gs.CompOff_Min_hours
									END, '00:00'), ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE Em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(isnull(CASE 
									WHEN gs.CompOff_Min_hours = ''
										THEN '00:00'
									ELSE gs.CompOff_Min_hours
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
			AND NOT EXISTS (
				SELECT 1
				FROM #HO_WO_WD T
				WHERE T.Emp_Id = Qry1.Emp_ID
					AND T.For_date = Qry1.For_date
				)

		SELECT *
		FROM #HO_WO_WD
		ORDER BY For_Date
	END
	ELSE IF @return_record_set = 14 -- HO & WO
	BEGIN
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,CAST('WO' AS VARCHAR(12)) AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016												
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'WO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION
		
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
						AND DT.EMP_ID = OA.EMP_ID
						AND DT.FOR_DATE = OA.FOR_DATE
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND DT.EMP_ID = OA.EMP_ID
						AND DT.FOR_DATE = OA.FOR_DATE
					)
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			) Qry1
		INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON Qry1.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = Qry1.EMP_ID
					AND WK.FOR_DATE = Qry1.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
		
		SELECT OA.*
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)) AS Working_Hour
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'WO-G' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, OA.shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), GPQuery.IN_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID
				FROM t0095_increment
				WHERE cmp_ID = @cmp_ID
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN (
			SELECT GS.For_Date
				,Gs.Branch_ID
				,W_CompOff_Min_hours
			FROM T0040_GENERAL_SETTING GS
			INNER JOIN (
				SELECT MAX(For_date) AS For_Date
					,Branch_ID
				FROM T0040_General_Setting gs
				WHERE Cmp_ID = @Cmp_ID
					AND For_Date <= @To_Date
				GROUP BY Branch_ID
				) Qry ON Qry.Branch_ID = GS.Branch_ID
				AND Qry.For_Date = GS.For_Date
			) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
		INNER JOIN (
			SELECT max(GP.In_Time) AS In_Time
				,GP.emp_id
				,GP.For_Date
				,Is_Approved
				,Reason_id
			FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
			INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
				AND OA.For_date = GP.For_date
				AND GP.Is_Approved = 1
			INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
				AND Type = 'GatePass'
				AND Gate_Pass_Type = 'Official'
			GROUP BY GP.Emp_ID
				,GP.For_Date
				,GP.Is_Approved
				,GP.Reason_id
			) GPQuery ON OA.emp_id = GPQuery.emp_ID
			AND OA.For_date = GPQuery.For_date
		WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND OA.For_date NOT IN (
				SELECT For_date
				FROM #Data_Temp OA
				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
					AND OA.For_date = CA.Extra_Work_Date
				WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
									WHEN E.CompOff_Min_hrs = ''
										THEN '00:00'
									ELSE e.CompOff_Min_hrs
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,CAST('HO' AS VARCHAR(25)) AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'HO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION
		
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'HO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE E.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					)
				AND (
					CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
					OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
					)
			) Qry1
		INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON Qry1.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = QRY1.EMP_ID
					AND HO.FOR_DATE = QRY1.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'HO-G' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID
				FROM t0095_increment
				WHERE cmp_ID = @cmp_ID
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN (
			SELECT GS.For_Date
				,Gs.Branch_ID
				,H_CompOff_Min_Hours
			FROM T0040_GENERAL_SETTING GS
			INNER JOIN (
				SELECT MAX(For_date) AS For_Date
					,Branch_ID
				FROM T0040_General_Setting gs
				WHERE Cmp_ID = @Cmp_ID
					AND For_Date <= @To_Date
				GROUP BY Branch_ID
				) Qry ON Qry.Branch_ID = GS.Branch_ID
				AND Qry.For_Date = GS.For_Date
			) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
		INNER JOIN (
			SELECT max(GP.In_Time) AS In_Time
				,GP.emp_id
				,GP.For_Date
				,Is_Approved
				,Reason_id
			FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
			INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
				AND OA.For_date = GP.For_date
				AND GP.Is_Approved = 1
			INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
				AND Type = 'GatePass'
				AND Gate_Pass_Type = 'Official'
			GROUP BY GP.Emp_ID
				,GP.For_Date
				,GP.Is_Approved
				,GP.Reason_id
			) GPQuery ON OA.emp_id = GPQuery.emp_ID
			AND OA.For_date = GPQuery.For_date
		WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND OA.For_date NOT IN (
				SELECT For_date
				FROM #Data_Temp OA
				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
					AND OA.For_date = CA.Extra_Work_Date
				WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
									WHEN E.CompOff_Min_hrs = ''
										THEN '00:00'
									ELSE e.CompOff_Min_hrs
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		ORDER BY OA.For_Date
	END
	ELSE IF @return_record_set = 15 -- HO & WD
	BEGIN
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,'HO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'HO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION
		
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'HO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
						AND EXISTS (
							SELECT 1
							FROM #EMP_HOLIDAY HO
							WHERE HO.IS_CANCEL = 0
								AND HO.FOR_DATE = OA.FOR_DATE
								AND HO.EMP_ID = OA.EMP_ID
							) -- ADDED BY GADRIWALA MUSLIM 0312016
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE E.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					)
				AND (
					CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
					OR CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0
					)
			) Qry1
		INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON Qry1.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = QRY1.EMP_ID
					AND HO.FOR_DATE = QRY1.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 18/08/2015
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(0) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'HO-G' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID
				FROM t0095_increment
				WHERE cmp_ID = @cmp_ID
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN (
			SELECT GS.For_Date
				,Gs.Branch_ID
				,H_CompOff_Min_Hours
			FROM T0040_GENERAL_SETTING GS
			INNER JOIN (
				SELECT MAX(For_date) AS For_Date
					,Branch_ID
				FROM T0040_General_Setting gs
				WHERE Cmp_ID = @Cmp_ID
					AND For_Date <= @To_Date
				GROUP BY Branch_ID
				) Qry ON Qry.Branch_ID = GS.Branch_ID
				AND Qry.For_Date = GS.For_Date
			) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
		INNER JOIN (
			SELECT max(GP.In_Time) AS In_Time
				,GP.emp_id
				,GP.For_Date
				,Is_Approved
				,Reason_id
			FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
			INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
				AND OA.For_date = GP.For_date
				AND GP.Is_Approved = 1
			INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
				AND Type = 'GatePass'
				AND Gate_Pass_Type = 'Official'
			GROUP BY GP.Emp_ID
				,GP.For_Date
				,GP.Is_Approved
				,GP.Reason_id
			) GPQuery ON OA.emp_id = GPQuery.emp_ID
			AND OA.For_date = GPQuery.For_date
		WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(Gen_Qry.H_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND OA.For_date NOT IN (
				SELECT For_date
				FROM #Data_Temp OA
				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
					AND OA.For_date = CA.Extra_Work_Date
				WHERE CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
									WHEN E.CompOff_Min_hrs = ''
										THEN '00:00'
									ELSE e.CompOff_Min_hrs
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					AND (CAST(REPLACE(dbo.F_Return_Hours(Holiday_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_HOLIDAY HO
				WHERE HO.IS_CANCEL = 0
					AND HO.EMP_ID = OA.EMP_ID
					AND HO.FOR_DATE = OA.FOR_DATE
				) -- ADDED BY GADRIWALA MUSLIM 0312016
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
			,CASE 
				WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
					OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
					THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
				ELSE dbo.F_Return_Hours(0)
				END AS OT_Hour
			,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,'WD' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON oa.emp_id = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
			,CASE 
				WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
					OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
					THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
				ELSE dbo.F_Return_Hours(0)
				END AS OT_Hour
			,dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'WD' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) -- Ankit 12092014 for Same Date Increment
					AS Increment_ID
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON oa.emp_id = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
		
		UNION
		
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
				,CASE 
					WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
						OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
						THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
					ELSE dbo.F_Return_Hours(0)
					END AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WD' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT OA.For_Date
					FROM [#Data_Temp] AS OA
					INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					INNER JOIN (
						SELECT t1.Emp_ID
							,t1.Branch_ID
						FROM T0095_INCREMENT t1
						INNER JOIN (
							SELECT Emp_ID
								,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
							FROM T0095_INCREMENT
							GROUP BY Emp_ID
							) AS t2 ON t1.emp_id = t2.Emp_ID
							AND t1.Increment_ID = t2.Increment_ID
						) AS inc ON OA.Emp_ID = inc.Emp_ID
					INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
					WHERE (
							CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
								WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
									THEN CAST(REPLACE(Isnull(CASE 
														WHEN E.CompOff_Min_hrs = ''
															THEN '00:00'
														ELSE e.CompOff_Min_hrs
														END, '00:00'), ':', '.') AS NUMERIC(18, 3))
								ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
								END
							)
						AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT OA.For_Date
					FROM [#Data_Temp] AS OA
					INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					INNER JOIN (
						SELECT t1.Emp_ID
							,t1.Branch_ID
						FROM T0095_INCREMENT t1
						INNER JOIN (
							SELECT Emp_ID
								,MAX(Increment_ID) -- Ankit 12092014 for Same Date Increment
								AS Increment_ID
							FROM T0095_INCREMENT
							GROUP BY Emp_ID
							) AS t2 ON t1.emp_id = t2.Emp_ID
							AND t1.Increment_ID = t2.Increment_ID
						) AS inc ON OA.Emp_ID = inc.Emp_ID
					INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
					WHERE (
							CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
								WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
									THEN CAST(REPLACE(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
								ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
								END
							)
						AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
			) Qry1
		INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON Qry1.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(isnull(CASE 
									WHEN gs.CompOff_Min_hours = ''
										THEN '00:00'
									ELSE gs.CompOff_Min_hours
									END, '00:00'), ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE Em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(isnull(CASE 
									WHEN gs.CompOff_Min_hours = ''
										THEN '00:00'
									ELSE gs.CompOff_Min_hours
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
		ORDER BY OA.For_Date
	END
	ELSE IF @return_record_set = 16 -- WO & WD
	BEGIN
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,'WO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'WO' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION
		
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WO' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
						AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT For_date
					FROM #Data_Temp OA
					INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					)
				AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			) Qry1
		INNER JOIN dbo.T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON Qry1.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = qry1.EMP_ID
					AND WK.FOR_DATE = qry1.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION -- Added By Gadriwala Muslim For Adjust CompOff Officially  Employee Go Out . 04/09/2015
		
		SELECT OA.*
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)) AS Working_Hour
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS OT_Hour
			,dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time) + ISNULL(Holiday_OT_Sec, 0)) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(DATEDIFF(s, OA.in_Time, GPQuery.in_Time), 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,'-' AS application_status
			,'WO-G' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, OA.shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), OA.In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), GPQuery.IN_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID
				FROM t0095_increment
				WHERE cmp_ID = @cmp_ID
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON OA.Emp_ID = inc.emp_id
		INNER JOIN (
			SELECT GS.For_Date
				,Gs.Branch_ID
				,W_CompOff_Min_hours
			FROM T0040_GENERAL_SETTING GS
			INNER JOIN (
				SELECT MAX(For_date) AS For_Date
					,Branch_ID
				FROM T0040_General_Setting gs
				WHERE Cmp_ID = @Cmp_ID
					AND For_Date <= @To_Date
				GROUP BY Branch_ID
				) Qry ON Qry.Branch_ID = GS.Branch_ID
				AND Qry.For_Date = GS.For_Date
			) Gen_Qry ON Gen_Qry.branch_id = inc.branch_id
		INNER JOIN (
			SELECT max(GP.In_Time) AS In_Time
				,GP.emp_id
				,GP.For_Date
				,Is_Approved
				,Reason_id
			FROM T0150_EMP_Gate_Pass_INOUT_RECORD GP
			INNER JOIN #Data_Temp OA ON OA.Emp_ID = GP.emp_id
				AND OA.For_date = GP.For_date
				AND GP.Is_Approved = 1
			INNER JOIN T0040_Reason_Master RM ON RM.Res_Id = GP.Reason_id
				AND Type = 'GatePass'
				AND Gate_Pass_Type = 'Official'
			GROUP BY GP.Emp_ID
				,GP.For_Date
				,GP.Is_Approved
				,GP.Reason_id
			) GPQuery ON OA.emp_id = GPQuery.emp_ID
			AND OA.For_date = GPQuery.For_date
		WHERE CAST(REPLACE(dbo.F_Return_Hours(DATEDIFF(s, OA.in_Time, GPQuery.in_Time)), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(Gen_Qry.W_CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
			AND OA.For_date NOT IN (
				SELECT For_date
				FROM #Data_Temp OA
				INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
				INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
					AND OA.For_date = CA.Extra_Work_Date
				WHERE CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) >= CAST(REPLACE(Isnull(CASE 
									WHEN E.CompOff_Min_hrs = ''
										THEN '00:00'
									ELSE e.CompOff_Min_hrs
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
					AND (CAST(REPLACE(dbo.F_Return_Hours(Weekoff_OT_Sec), ':', '.') AS NUMERIC(18, 3)) <> 0)
				)
			AND EXISTS (
				SELECT 1
				FROM #EMP_WEEKOFF WK
				WHERE WK.IS_CANCEL = 0
					AND WK.EMP_ID = OA.EMP_ID
					AND WK.FOR_DATE = OA.FOR_DATE
				) -- Added by Gadriwala Muslim 0312016
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
			,CASE 
				WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
					OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
					THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
				ELSE dbo.F_Return_Hours(0)
				END AS OT_Hour
			,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Approve_Status AS Application_Status
			,'WD' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0120_CompOff_Approval CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON oa.emp_id = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
		
		UNION
		
		SELECT OA.*
			,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
			,CASE 
				WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
					OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
					THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
				ELSE dbo.F_Return_Hours(0)
				END AS OT_Hour
			,dbo.F_Return_Hours(Duration_in_Sec /*+ ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
			,@P_Days_Count AS P_Days_Count
			,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
			,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
			,CA.Application_Status
			,'WD' AS DayFlag
			,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
			,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
			,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
		FROM #Data_Temp OA
		INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
		INNER JOIN dbo.T0100_CompOff_Application CA ON OA.Emp_Id = CA.Emp_ID
			AND OA.For_date = CA.Extra_Work_Date
		INNER JOIN (
			SELECT t1.emp_id
				,branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) -- Ankit 12092014 for Same Date Increment
					AS Increment_ID
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON oa.emp_id = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(Isnull(CASE 
										WHEN E.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE e.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
		
		UNION
		
		SELECT Qry1.*
		FROM (
			SELECT dt.*
				,dbo.F_Return_Hours(Duration_in_Sec - OT_SEC) AS Working_Hour
				,CASE 
					WHEN DATEDIFF(SECOND, In_Time, shift_Start_time) >= 3600
						OR DATEDIFF(SECOND, Shift_End_Time, Out_Time) >= 3600
						THEN dbo.F_Return_Hours(ISNULL(OT_SEC, 0))
					ELSE dbo.F_Return_Hours(0)
					END AS OT_Hour
				,dbo.F_Return_Hours(Duration_in_Sec /* + ISNULL(OT_Sec,0)*/) AS Actual_Worked_Hrs
				,@P_Days_Count AS P_Days_Count
				,dbo.F_Return_Hours(ISNULL(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
				,dbo.F_Return_Hours(ISNULL(Holiday_OT_Sec, 0)) AS Holiday_OT_Hour
				,'-' AS application_status
				,'WD' AS DayFlag
				,dbo.F_Return_Hours(DATEDIFF(SECOND, shift_start_time, shift_end_time)) AS Shift_Hours
				,CONVERT(NVARCHAR(8), In_Time, 108) AS In_Time_Actual
				,CONVERT(NVARCHAR(8), Out_Time, 108) AS Out_Time_Actual
			FROM #Data_Temp DT
			WHERE For_date NOT IN (
					SELECT OA.For_Date
					FROM [#Data_Temp] AS OA
					INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN T0120_CompOff_Approval AS CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					INNER JOIN (
						SELECT t1.Emp_ID
							,t1.Branch_ID
						FROM T0095_INCREMENT t1
						INNER JOIN (
							SELECT Emp_ID
								,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
							FROM T0095_INCREMENT
							GROUP BY Emp_ID
							) AS t2 ON t1.emp_id = t2.Emp_ID
							AND t1.Increment_ID = t2.Increment_ID
						) AS inc ON OA.Emp_ID = inc.Emp_ID
					INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
					WHERE (
							CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
								WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
									THEN CAST(REPLACE(Isnull(CASE 
														WHEN E.CompOff_Min_hrs = ''
															THEN '00:00'
														ELSE e.CompOff_Min_hrs
														END, '00:00'), ':', '.') AS NUMERIC(18, 3))
								ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
								END
							)
						AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
					
					UNION
					
					SELECT OA.For_Date
					FROM [#Data_Temp] AS OA
					INNER JOIN T0080_EMP_MASTER AS E ON OA.Emp_ID = E.Emp_ID
					INNER JOIN T0100_CompOff_Application AS CA ON OA.Emp_Id = CA.Emp_ID
						AND OA.For_date = CA.Extra_Work_Date
					INNER JOIN (
						SELECT t1.Emp_ID
							,t1.Branch_ID
						FROM T0095_INCREMENT t1
						INNER JOIN (
							SELECT Emp_ID
								,MAX(Increment_ID) -- Ankit 12092014 for Same Date Increment
								AS Increment_ID
							FROM T0095_INCREMENT
							GROUP BY Emp_ID
							) AS t2 ON t1.emp_id = t2.Emp_ID
							AND t1.Increment_ID = t2.Increment_ID
						) AS inc ON OA.Emp_ID = inc.Emp_ID
					INNER JOIN T0040_GENERAL_SETTING AS gs ON gs.Branch_ID = inc.Branch_ID
					WHERE (
							CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
								WHEN CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3)) = 0
									THEN CAST(REPLACE(E.CompOff_Min_hrs, ':', '.') AS NUMERIC(18, 3))
								ELSE CAST(REPLACE(gs.CompOff_Min_hours, ':', '.') AS NUMERIC(18, 3))
								END
							)
						AND (CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0)
					)
			) Qry1
		INNER JOIN T0080_EMP_MASTER em ON Qry1.Emp_Id = em.Emp_ID
		INNER JOIN (
			SELECT t1.emp_id
				,t1.branch_id
			FROM T0095_Increment t1
			INNER JOIN (
				SELECT emp_id
					,MAX(Increment_ID) AS Increment_ID -- Ankit 12092014 for Same Date Increment
				FROM t0095_increment
				GROUP BY emp_id
				) AS t2 ON t1.emp_id = t2.emp_id
				AND t1.Increment_ID = t2.Increment_ID
			) AS inc ON Qry1.Emp_ID = inc.emp_id
		INNER JOIN T0040_General_Setting gs ON gs.branch_id = inc.branch_id
		WHERE CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) >= CASE 
				WHEN CAST(REPLACE(isnull(CASE 
									WHEN gs.CompOff_Min_hours = ''
										THEN '00:00'
									ELSE gs.CompOff_Min_hours
									END, '00:00'), ':', '.') AS NUMERIC(18, 3)) = 0
					THEN CAST(REPLACE(isnull(CASE 
										WHEN Em.CompOff_Min_hrs = ''
											THEN '00:00'
										ELSE Em.CompOff_Min_hrs
										END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				ELSE CAST(REPLACE(isnull(CASE 
									WHEN gs.CompOff_Min_hours = ''
										THEN '00:00'
									ELSE gs.CompOff_Min_hours
									END, '00:00'), ':', '.') AS NUMERIC(18, 3))
				END
			AND CAST(REPLACE(dbo.F_Return_Hours(OT_SEC), ':', '.') AS NUMERIC(18, 3)) <> 0
		ORDER BY OA.For_Date
	END
			-------------------------
END
ELSE IF @Return_Record_set = 1
BEGIN
	SELECT *
		,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
		,dbo.F_Return_Hours(OT_SEc) AS OT_Hour
		,Flag
		,dbo.F_Return_Hours(Weekoff_OT_Sec) AS Weekoff_OT_Hour
		,dbo.F_Return_Hours(Holiday_OT_Sec) AS Holiday_OT_Hour
		,Shift_Name
		,Shift_St_Time
		,OA.Shift_End_Time
		,Shift_Dur
		,REPLACE(CONVERT(VARCHAR(20), FOR_DATE, 106), ' ', '-') AS ForDate
		,CONVERT(VARCHAR(20), In_Time, 108) AS InTime
		,CONVERT(VARCHAR(20), OUT_Time, 108) AS OutTime
		,SM.Shift_End_Time AS Shift_En_Time 
	FROM #Data OA
	INNER JOIN dbo.T0080_EMP_MASTER E ON OA.Emp_ID = E.Emp_ID
	LEFT JOIN dbo.T0040_SHIFT_MASTER SM ON OA.Shift_ID = SM.Shift_ID
	ORDER BY E.emp_ID
		,For_Date
END
ELSE IF @Return_Record_set = 3
BEGIN
	CREATE TABLE #Data_Temp_3 (
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
		,OUT_Time DATETIME
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

	DECLARE @T_Emp_ID_3 NUMERIC
	DECLARE @T_For_Date_3 DATETIME
	DECLARE @Flag_cur AS INT

	--delete from #Data_Temp_3  
	TRUNCATE TABLE #Data_Temp_3 --Hardik 15/02/2013

	-- Added by rohit on 26082013
	--declare @Emp_ID_W numeric
	--Declare @For_date_W Datetime
	DECLARE OT_Emp CURSOR
	FOR
	SELECT Emp_ID
	FROM #Emp_Cons

	--inner join
	--t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
	OPEN OT_Emp

	FETCH NEXT
	FROM OT_Emp
	INTO @Emp_ID_W

	WHILE @@fetch_status = 0
	BEGIN
		--Declare @StrWeekoff_Date_W varchar(max)
		--declare @Weekoff_Days_W varchar(max)
		--declare @Cancel_Weekoff_w varchar(max)
		--declare @StrHoliday_Date_W varchar(max)
		--declare @Holiday_days_W varchar(max)
		--declare @Cancel_Holiday_W varchar (max)
		--declare @OD_transfer_to_ot numeric(1,0)
		--Declare @Branch_id_OD numeric (4,0)
		SELECT @BRANCH_ID_OD = Branch_id
		FROM t0095_increment
		WHERE Increment_ID = (
				SELECT max(Increment_ID)
				FROM t0095_increment
				WHERE emp_id = @Emp_ID_W
					AND increment_effective_date <= @To_Date
				)
			AND emp_id = @Emp_ID_W -- Ankit 12092014 for Same Date Increment

		SELECT @OD_transfer_to_ot = Is_OD_Transfer_to_OT
		FROM t0040_general_setting
		WHERE branch_id = @BRANCH_ID_OD

		IF @OD_transfer_to_ot = 1
		BEGIN
			--Exec dbo.SP_EMP_HOLIDAY_DATE_GET1 @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date_W output,@Holiday_days_W output,@Cancel_Holiday_W output,0,@Branch_ID,@StrWeekoff_Date_W			
			--Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_ID_W,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date_W output,@Weekoff_Days_W output ,@Cancel_Weekoff_w output,@constraint=''
			IF OBJECT_ID('tempdb..#Emp_Holiday') IS NOT NULL
			BEGIN
				DROP TABLE #Emp_Holiday
			END --Added by Sumit after discussion with Nimesh bhai on 05122016

			EXEC dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID_W
				,@Cmp_ID
				,@From_Date
				,@To_Date
				,NULL
				,NULL
				,9
				,@StrHoliday_Date_W OUTPUT
				,@Holiday_days_W OUTPUT
				,@Cancel_Holiday_W OUTPUT
				,0
				,@Branch_ID
				,@StrWeekoff_Date_W

			IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NOT NULL
			BEGIN
				DROP TABLE #Emp_WeekOff
			END --Added by Sumit after discussion with Nimesh bhai on 05122016

			EXEC dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID_W
				,@Cmp_ID
				,@From_Date
				,@To_Date
				,NULL
				,NULL
				,9
				,''
				,@StrWeekoff_Date_W OUTPUT
				,@Weekoff_Days_W OUTPUT
				,@Cancel_Weekoff_w OUTPUT

			DECLARE OT_For_Date CURSOR
			FOR
			SELECT cast(data AS DATETIME) AS For_date
			FROM dbo.Split((@StrHoliday_Date_W), ';')

			--select inactive_effective_date from t0040_leave_master
			OPEN OT_For_Date

			FETCH NEXT
			FROM OT_For_Date
			INTO @For_date_W

			WHILE @@fetch_status = 0
			BEGIN
				--select @For_date_W as fordate,@Emp_ID_W as empid
				IF NOT EXISTS (
						SELECT Tran_Id
						FROM dbo.t0160_Ot_Approval
						WHERE Emp_ID = @Emp_ID_W
							AND For_Date = @For_date_W
						)
				BEGIN
					INSERT INTO #Data_Temp_3 (
						Emp_Id
						,For_date
						,Duration_in_sec
						,Shift_ID
						,Shift_Type
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,P_days
						,OT_Sec
						,In_Time
						,Shift_Start_Time
						,OT_Start_Time
						,Shift_Change
						,Flag
						,Weekoff_OT_Sec
						,Holiday_OT_Sec
						,Chk_By_Superior
						,IO_Tran_Id
						,OUT_Time
						)
					SELECT LA.Emp_id
						,@For_date_W
						,0
						,0
						,0
						,1
						,0
						,0
						,0
						,0
						,@For_date_W
						,@For_date_W
						,0
						,0
						,0
						,0
						,CASE 
							WHEN lad.half_leave_date = @For_date_W
								THEN 28800 / 2
							ELSE 28800
							END
						,0
						,0
						,@For_date_W
					FROM T0120_LEAVE_APPROVAL LA
					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
					INNER JOIN T0040_LEAVE_MASTER LM ON LAD.leave_id = LM.leave_id
					WHERE Leave_Type = 'Company Purpose'
						AND @for_date_W >= LAD.From_date
						AND @for_date_W <= LAD.To_Date
						AND Emp_id = @Emp_ID_W
				END

				FETCH NEXT
				FROM OT_For_Date
				INTO @For_date_W
			END

			CLOSE OT_For_Date

			DEALLOCATE OT_For_Date

			DECLARE OT_For_Date CURSOR
			FOR
			SELECT cast(data AS DATETIME) AS For_date
			FROM dbo.Split((@StrWeekoff_Date_W), ';')
			WHERE cast(data AS DATETIME) NOT IN (
					SELECT cast(data AS DATETIME)
					FROM dbo.Split((@StrHoliday_Date_W), ';')
					)

			--select inactive_effective_date from t0040_leave_master
			OPEN OT_For_Date

			FETCH NEXT
			FROM OT_For_Date
			INTO @For_date_W

			WHILE @@fetch_status = 0
			BEGIN
				IF NOT EXISTS (
						SELECT Tran_Id
						FROM dbo.t0160_Ot_Approval
						WHERE Emp_ID = @Emp_ID_W
							AND For_Date = @For_date_W
						)
				BEGIN
					INSERT INTO #Data_Temp_3 (
						Emp_Id
						,For_date
						,Duration_in_sec
						,Shift_ID
						,Shift_Type
						,Emp_OT
						,Emp_OT_min_Limit
						,Emp_OT_max_Limit
						,P_days
						,OT_Sec
						,In_Time
						,Shift_Start_Time
						,OT_Start_Time
						,Shift_Change
						,Flag
						,Weekoff_OT_Sec
						,Holiday_OT_Sec
						,Chk_By_Superior
						,IO_Tran_Id
						,OUT_Time
						)
					SELECT LA.Emp_id
						,@For_date_W
						,0
						,0
						,0
						,1
						,0
						,0
						,0
						,0
						,@For_date_W
						,@For_date_W
						,0
						,0
						,0
						,CASE 
							WHEN lad.half_leave_date = @For_date_W
								THEN 28800 / 2
							ELSE 28800
							END
						,0
						,0
						,0
						,@For_date_W
					FROM T0120_LEAVE_APPROVAL LA
					INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
					INNER JOIN T0040_LEAVE_MASTER LM ON LAD.leave_id = LM.leave_id
					WHERE Leave_Type = 'Company Purpose'
						AND @for_date_W >= LAD.From_date
						AND @for_date_W <= LAD.To_Date
						AND Emp_id = @Emp_ID_W
				END

				FETCH NEXT
				FROM OT_For_Date
				INTO @For_date_W
			END

			CLOSE OT_For_Date

			DEALLOCATE OT_For_Date
		END

		FETCH NEXT
		FROM OT_Emp
		INTO @Emp_ID_W
	END

	CLOSE OT_Emp

	DEALLOCATE OT_Emp

	-- Ended by rohit
	DECLARE OT_cursor CURSOR
	FOR
	SELECT d.Emp_ID
		,d.For_Date
		,Flag
	FROM #Data D

	--Commented By rohit under the Guidance by Miteshbhai for Showing Ot hours Without Approved. 07-dec-2012
	--   d inner join
	--t0160_Ot_Approval t  on d.Emp_ID = t.Emp_ID And d.For_Date = t.For_Date -- Added Inner join by Hardik 10/09/2012
	OPEN OT_cursor

	FETCH NEXT
	FROM OT_cursor
	INTO @T_Emp_ID_3
		,@T_For_Date_3
		,@Flag_cur

	WHILE @@fetch_status = 0
	BEGIN
		--Commented by Hardik 10/09/2012    
		IF NOT EXISTS (
				SELECT Tran_Id
				FROM dbo.t0160_Ot_Approval
				WHERE Emp_ID = @T_Emp_ID_3
					AND For_Date = @T_For_Date_3
				) ----Commented By rohit under the Guidance by Miteshbhai for Showing Ot hours Without Approved. 07-dec-2012
		BEGIN
			INSERT INTO #Data_Temp_3
			SELECT *
			FROM #Data
			WHERE Emp_ID = @T_Emp_ID_3
				AND For_Date = @T_For_Date_3

			IF @Flag_cur = 1
			BEGIN
				UPDATE #Data_Temp_3
				SET OT_Sec = (OT_Sec * - 1)
				WHERE Emp_ID = @T_Emp_ID_3
					AND For_Date = @T_For_Date_3
			END
		END

		FETCH NEXT
		FROM OT_cursor
		INTO @T_Emp_ID_3
			,@T_For_Date_3
			,@Flag_cur
	END

	CLOSE OT_cursor

	DEALLOCATE OT_cursor

	-- Added by rohit For match the ot hours  monthly ot and daily ot  on 04-dec-2012
	DELETE
	FROM #Data_Temp_3
	WHERE Emp_Id = @Emp_Id
		AND (
			ISNULL(Weekoff_OT_Sec, 0) = 0
			OR ISNULL(Holiday_OT_Sec, 0) = 0
			)
		AND For_Date IN (
			SELECT Extra_Work_Date
			FROM dbo.T0120_CompOff_Approval
			WHERE Extra_Work_Date >= @From_Date
				AND Extra_Work_Date <= @To_Date
				AND Cmp_ID = @Cmp_ID
				AND Emp_ID = @T_Emp_ID_3
				AND Approve_Status = 'A'
			)

	UPDATE #Data_Temp_3
	SET OT_Sec = 0
	WHERE Emp_Id = @Emp_Id
		AND (
			ISNULL(Weekoff_OT_Sec, 0) = 0
			AND ISNULL(Holiday_OT_Sec, 0) = 0
			)
		AND For_Date IN (
			SELECT Extra_Work_Date
			FROM dbo.T0120_CompOff_Approval
			WHERE Extra_Work_Date >= @From_Date
				AND Extra_Work_Date <= @To_Date
				AND Cmp_ID = @Cmp_ID
				AND Emp_ID = @T_Emp_ID_3
				AND Approve_Status = 'A'
			)

	-- ended by rohit For match the ot hours for monthly ot and daily ot on 04-dec-2012				  
	DECLARE @Emp_Temp TABLE (
		Emp_ID NUMERIC(18, 0)
		,For_Date DATETIME
		,Emp_full_Name VARCHAR(50)
		,Working_Hour VARCHAR(20)
		,
		--Working_Hour numeric(18,5),  
		OT_Hour NUMERIC(18, 5)
		,Weekoff_OT_Hour NUMERIC(18, 5)
		,Holiday_OT_Hour NUMERIC(18, 5)
		,P_Days NUMERIC(18, 3)
		)

	INSERT INTO @Emp_Temp (
		Emp_ID
		,For_Date
		,Emp_full_Name
		,Working_Hour
		,OT_Hour
		,Weekoff_OT_Hour
		,Holiday_OT_Hour
		,P_Days
		)
	--select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, CONVERT(decimal(10,2), sum(Duration_in_Sec)/3600) as Working_Hour ,CONVERT(decimal(10,2),(sum(OT_SEc)))  as OT_Hour ,sum(P_days) as Present_Days    
	SELECT OA.Emp_ID
		,Max(For_Date) For_Date
		,E.Emp_Full_Name
		,dbo.F_Return_Hours(Sum(Duration_in_Sec)) AS Working_Hour
		,CONVERT(DECIMAL(10, 2), (sum(OT_SEc))) AS OT_Hour
		,CONVERT(DECIMAL(10, 2), (sum(Weekoff_OT_Sec))) AS Weekoff_OT_Sec
		,CONVERT(DECIMAL(10, 2), (sum(Holiday_OT_Sec))) AS Holiday_OT_Sec
		,sum(P_days) AS Present_Days
	FROM #Data_Temp_3 OA
	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
	WHERE OT_sec > 0
		OR Weekoff_OT_Sec > 0
		OR Holiday_OT_Sec > 0 --or Night_ot_sec > 0 --(Comment Night_ot_sec -Ankit 08042015 Not exist in templarty talbe #Data_Temp_3) 
	GROUP BY OA.emp_ID
		,E.Emp_Full_Name

	SELECT OA1.Emp_ID
		,Max(For_Date) For_Date
		,E1.Alpha_Emp_code
		,E1.Emp_Full_Name
		,Working_Hour
		,dbo.F_Return_Hours(OT_HOur) AS OT_Hour
		,P_days
		,E1.Emp_Superior
		,dbo.F_Return_Hours(Weekoff_OT_Hour) AS Weekoff_OT_Hour
		,dbo.F_Return_Hours(Holiday_OT_Hour) AS Holiday_OT_Hour
		,E1.branch_id
	FROM @Emp_Temp OA1
	INNER JOIN dbo.T0080_emp_master E1 ON OA1.Emp_ID = E1.Emp_ID
	GROUP BY OA1.emp_ID
		,E1.Alpha_Emp_code
		,E1.Emp_Full_Name
		,For_Date
		,Working_Hour
		,OT_Hour
		,P_days
		,Emp_Superior
		,Weekoff_OT_Hour
		,Holiday_OT_Hour
		,E1.branch_id
END
ELSE IF @Return_Record_set = 4
BEGIN
	IF @OT_Present = 1
		AND @Auto_OT = 1
	BEGIN
		--Update #Data   
		--set OT_Sec = isnull(Approved_OT_Sec,0) -- * 3600    
		--from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date 		
		UPDATE #Data
		SET P_Days = P_Days + 0.5
			,OT_Sec = 0
		WHERE OT_Sec >= 3600
			AND OT_Sec <= 18000
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0

		UPDATE #Data
		SET P_Days = P_Days + 1
			,OT_Sec = 0
		WHERE OT_Sec >= 18001
			AND OT_Sec <= 36000
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0

		UPDATE #Data
		SET P_Days = P_Days + 1.5
			,OT_Sec = 0
		WHERE OT_Sec >= 36001
			AND OT_Sec <= 54000
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0

		UPDATE #Data
		SET P_Days = P_Days + 2.5
			,OT_Sec = 0
		WHERE OT_Sec >= 54001
			AND OT_Sec <= 99999
			AND Shift_ID = @shift_ID
			AND IO_Tran_Id = 0
	END
	ELSE IF @OT_Present = 0
		AND @Auto_OT = 1
	BEGIN
		UPDATE #Data
		SET OT_Sec = isnull(Approved_OT_Sec, 0) --* 3600    
		FROM #Data d
		INNER JOIN dbo.T0160_OT_Approval OA ON d.emp_ID = Oa.Emp_ID
			AND d.For_Date = oa.For_Date
	END
	ELSE IF @OT_Present = 0
		AND @Auto_OT = 0
	BEGIN
		--Update #Data set OT_Sec =0
		UPDATE #Data
		SET OT_Sec = isnull(Approved_OT_Sec, 0) -- * 3600    
		FROM #Data d
		INNER JOIN dbo.T0160_OT_Approval OA ON d.emp_ID = Oa.Emp_ID
			AND d.For_Date = oa.For_Date
	END
END
IF @Return_Record_set = 5
BEGIN
	CREATE TABLE #Data_Temp_5 (
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

	DECLARE @Temp TABLE (
		Emp_ID NUMERIC
		,For_Date DATETIME
		,p_Days NUMERIC(12, 3) DEFAULT 0
		,OT_Sec NUMERIC DEFAULT 0
		,Weekoff_OT_Sec NUMERIC DEFAULT 0
		,Holiday_OT_Sec NUMERIC DEFAULT 0
		,OT_Hours NUMERIC(18, 5)
		,Flag INT DEFAULT 0
		,Weekoff_OT_Hour NUMERIC(18, 5)
		,Holiday_OT_Hour NUMERIC(18, 5)
		)
	DECLARE @T_Emp_ID_5 NUMERIC
	DECLARE @T_For_Date_5 DATETIME
	DECLARE @Flag_cur_5 AS INT
	
	TRUNCATE TABLE #Data_Temp_5 
	DECLARE OT_cursor CURSOR
	FOR
		SELECT Emp_ID ,For_Date ,Flag FROM #Data
	OPEN OT_cursor

	FETCH NEXT
	FROM OT_cursor
	INTO @T_Emp_ID_5
		,@T_For_Date_5
		,@Flag_cur_5

	WHILE @@fetch_status = 0
	BEGIN
		INSERT INTO #Data_Temp_5
		SELECT *
		FROM #Data
		WHERE Emp_ID = @T_Emp_ID_5
			AND For_Date = @T_For_Date_5

		INSERT INTO @Temp
		SELECT Emp_Id
			,For_Date
			,P_Days
			,OT_sec
			,weekoff_ot_sec
			,Holiday_OT_Sec
			,cast(Round(OT_Sec / 3600, 2) AS NUMERIC(18, 3))
			,flag
			,cast(Round(Weekoff_OT_Sec / 3600, 2) AS NUMERIC(18, 3))
			,cast(Round(Holiday_OT_Sec / 3600, 2) AS NUMERIC(18, 3))
		FROM #Data
		WHERE Emp_ID = @T_Emp_ID_5
			AND For_Date = @T_For_Date_5

		IF @Flag_cur_5 = 1
		BEGIN
			UPDATE @temp
			SET Ot_Sec = (Ot_Sec * - 1)
				,Weekoff_OT_Sec = (Weekoff_OT_Sec * - 1)
				,Holiday_OT_Sec = (Holiday_OT_Sec * - 1)
			WHERE Emp_ID = @T_Emp_ID_5
				AND For_Date = @T_For_Date_5
				AND Flag = 1

			UPDATE @temp
			SET OT_Hours = '-' + OT_Hours
				,Weekoff_OT_Hour = '-' + Weekoff_OT_Hour
				,Holiday_OT_Hour = '-' + Holiday_OT_Hour
			WHERE Emp_ID = @T_Emp_ID_5
				AND For_Date = @T_For_Date_5
				AND Flag = 1
		END

		FETCH NEXT
		FROM OT_cursor
		INTO @T_Emp_ID_5
			,@T_For_Date_5
			,@Flag_cur_5
	END

	CLOSE OT_cursor
	DEALLOCATE OT_cursor

	DECLARE @Emp_Temp_5 TABLE (
		Emp_ID NUMERIC(18, 0)
		,For_Date DATETIME
		,Emp_full_Name VARCHAR(50)
		,Working_Hour NUMERIC(18, 5)
		,OT_Hour NUMERIC(18, 5)
		,P_Days NUMERIC(18, 3)
		,Weekoff_OT_Hour NUMERIC(18, 5)
		,Holiday_OT_Hour NUMERIC(18, 5)
		)

	INSERT INTO @Emp_Temp_5 (
		Emp_ID
		,For_Date
		,Emp_full_Name
		,Working_Hour
		,OT_Hour
		,P_Days
		,Weekoff_OT_Hour
		,Holiday_OT_Hour
		)
	SELECT OA.Emp_ID
		,Max(For_Date) For_Date
		,E.Emp_Full_Name
		,CONVERT(DECIMAL(10, 2), sum(Duration_in_Sec) / 3600) AS Working_Hour
		,CONVERT(DECIMAL(10, 2), (sum(OT_SEc))) AS OT_Hour
		,sum(P_days) AS Present_Days
		,CONVERT(DECIMAL(10, 2), (sum(Weekoff_OT_Sec))) AS Weekoff_OT_Hour
		,CONVERT(DECIMAL(10, 2), (sum(Holiday_OT_Sec))) AS Holiday_OT_Hour
	FROM #Data_Temp_5 OA
	INNER JOIN dbo.T0080_emp_master E ON OA.Emp_ID = E.Emp_ID
	GROUP BY OA.emp_ID
		,E.Emp_Full_Name

	INSERT INTO #Data_MOTIF
	SELECT Emp_ID
		,For_Date
		,p_Days
		,dbo.F_Lower_Round(OT_Hours, @Cmp_ID)
		,Weekoff_OT_Hour
		,Holiday_OT_Hour
	FROM @temp OA
	ORDER BY OA.For_Date
	
	INSERT INTO #Att_Detail
	SELECT OA1.Emp_ID
		,P_days
		,dbo.F_Return_Hours(OT_HOur)
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,dbo.F_Return_Hours(Weekoff_OT_Hour)
		,dbo.F_Return_Hours(Holiday_OT_Hour)
	FROM @Emp_Temp_5 OA1
	INNER JOIN dbo.T0080_emp_master E1 ON OA1.Emp_ID = E1.Emp_ID
	GROUP BY OA1.emp_ID
		,E1.Emp_Full_Name
		,For_Date
		,Working_Hour
		,OT_Hour
		,P_days
		,Weekoff_OT_Hour
		,Holiday_OT_Hour
END
RETURN