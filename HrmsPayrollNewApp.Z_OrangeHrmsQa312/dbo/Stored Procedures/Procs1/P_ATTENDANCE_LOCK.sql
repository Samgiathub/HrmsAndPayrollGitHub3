

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 18-Feb-2019
-- Description:	To lock the Attendance
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_ATTENDANCE_LOCK] 
	-- Add the parameters for the stored procedure here
	@Cmp_ID			INT, 
	@From_Date		DateTime,
	@To_Date		DateTime,
	@Constraint		Varchar(Max)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


    CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	);
	CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);
	
	
	IF @Constraint <> ''        
		BEGIN
			INSERT	INTO #Emp_Cons(Emp_ID)        
			SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
			--Added By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---
			UPDATE	#Emp_Cons 
			SET		Branch_ID=I1.Branch_ID,
					Increment_ID =I1.Increment_ID
			FROM	#Emp_Cons EC 
					INNER JOIN T0095_INCREMENT I1 ON EC.Emp_ID=I1.Emp_ID
					INNER JOIN (
									SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
									FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E ON I2.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment --
											INNER JOIN (
															SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
															FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.Emp_ID	
															WHERE I3.Increment_effective_Date <= @to_date AND I3.Cmp_ID =@Cmp_ID
															GROUP BY I3.EMP_ID  
														) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
									GROUP BY I2.Emp_ID
								) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID
										
										
			--Ended By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---       
		END
	ELSE
		BEGIN
			INSERT	INTO #Emp_Cons      
			SELECT	DISTINCT emp_id,branch_id,Increment_ID 
			FROM	dbo.V_Emp_Cons 
			WHERE	Cmp_ID=@Cmp_ID 															
					AND Increment_Effective_Date <= @To_Date 
					AND (
							(@From_Date  >= join_Date  AND  @From_Date <= left_date ) 
							OR ( @To_Date  >= join_Date  and @To_Date <= left_date )      
							OR (Left_date is null and @To_Date >= Join_Date)
							OR (@To_Date >= left_date  and  @From_Date <= left_date )
						) 
			ORDER BY Emp_ID
							
					
			DELETE E FROM #Emp_Cons E
			WHERE NOT EXISTS (
								SELECT	TOP 1 1
								FROM	t0095_increment TI WITH (NOLOCK)
										INNER JOIN (
													SELECT	MAX(T0095_Increment.Increment_ID) AS Increment_ID,T0095_Increment.Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK) INNER JOIN #Emp_Cons E ON T0095_INCREMENT.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment
													WHERE	Increment_effective_Date <= @to_date AND Cmp_ID =@Cmp_Id 
													GROUP BY T0095_Increment.emp_ID
													) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID
								WHERE	Increment_effective_Date <= @to_date AND E.Increment_ID	= TI.Increment_ID
							)


	END        
	
   
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
 
	 
	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY_SUMMARY(EMP_ID INT, FOR_DATE DATETIME,HolidayName Varchar(128), CancelReason Varchar(128))
			CREATE CLUSTERED INDEX IX_EMP_HOLIDAY_SUMMARY_EmpID_ForDate ON #EMP_HOLIDAY_SUMMARY(Emp_ID, For_Date)		

			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #EMP_WEEKOFF_SUMMARY(EMP_ID INT, FOR_DATE DATETIME, CancelReason Varchar(128))
			CREATE CLUSTERED INDEX IX_EMP_WEEKOFF_SUMMARY_EmpID_ForDate ON #EMP_WEEKOFF_SUMMARY(Emp_ID, For_Date)		

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
		END
  	IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
	BEGIN
		--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #Emp_WeekOff_Holiday
		(
			Emp_ID				NUMERIC,
			WeekOffDate			VARCHAR(Max),
			WeekOffCount		NUMERIC(4,1),
			HolidayDate			VARCHAR(Max),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		VARCHAR(Max),
			HalfHolidayCount	NUMERIC(4,1),
			OptHolidayDate		VARCHAR(Max),
			OptHolidayCount		NUMERIC(4,1)
		);
		SET @Required_Execution  = 1;
	END 
	
	IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
	BEGIN	
	
		--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #EMP_HW_CONS
		(
			Emp_ID				NUMERIC,
			WeekOffDate			Varchar(Max),
			WeekOffCount		NUMERIC(4,1),
			CancelWeekOff		Varchar(Max),
			CancelWeekOffCount	NUMERIC(4,1),
			HolidayDate			Varchar(MAX),
			HolidayCount		NUMERIC(4,1),
			HalfHolidayDate		Varchar(MAX),
			HalfHolidayCount	NUMERIC(4,1),
			CancelHoliday		Varchar(Max),
			CancelHolidayCount	NUMERIC(4,1)
		);
		
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
		
		SET @Required_Execution  =1;		
	END
	

	IF @Required_Execution = 1
	BEGIN		
		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0,@Delete_Cancel_HW	=0
	END 

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

	
	EXEC	SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0, @Cat_ID=0, @Grd_ID=0,@Type_ID=0,@Dept_ID=0,
				@Desig_ID=0, @Emp_ID=0, @constraint=@Constraint, @Return_Record_set=4
	
	--EXEC rpt_Late_Early_Mark_Deduction_Details @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0, @Cat_ID=0, @Grd_ID=0,@Type_ID=0,@Dept_ID=0,
	--		@Desig_ID=0, @Emp_ID=0, @constraint=@Constraint, @Format_Type=''

	

	--DECLARE @EMP_ID INT
	--DECLARE @Is_Late_Mark INT = 1
	--DECLARE @Is_Late_Mark_Gen INT = 1
	--DECLARE @Late_Mark_Scenario INT	= 2
	--DECLARE @Late_Absent_Day NUMERIC(18,3)
	--DECLARE @Total_LMark NUMERIC(18,3)
	--DECLARE @Total_Late_Sec INT
	--DECLARE @Increment_ID INT

	--DECLARE @StrWeekoff_Date VARCHAR(MAX)
	--DECLARE @StrHoliday_Date VARCHAR(MAX)
	--DECLARE @Absent_date_String VARCHAR(MAX) =''
	--DECLARE @Total_Late_OT_Hours NUMERIC(18,2)

	--DECLARE curEmp CURSOR FAST_FORWARD FOR 
	--SELECT Emp_ID, Increment_ID FROM #Emp_Cons 

	--OPEN curEmp
	--FETCH NEXT FROM curEmp INTO @EMP_ID, @Increment_ID
	--WHILE @@FETCH_STATUS = 0
	--	BEGIN
	--		 If @Is_Late_Mark = 1 And @Is_Late_Mark_Gen = 1 --and @Is_Manual_Present = 0 -- Added By Hardik 10/09/2012
 --               Begin
 --                   if @Late_Mark_Scenario = 2 --and @Is_LateMark_Percent = 0 
 --                       Begin
	--						SET @StrWeekoff_Date = NULL

	--						SELECT	@StrWeekoff_Date = COALESCE(@StrWeekoff_Date + ';', '') + Cast(For_Date As Varchar(11))
	--						FROM	#Emp_WeekOff
	--						WHERE	Is_Cancel=0

	--						SET @StrHoliday_Date = NULL
	--						SELECT	@StrHoliday_Date = COALESCE(@StrHoliday_Date + ';', '') + Cast(For_Date As Varchar(11))
	--						FROM	#Emp_Holiday
	--						WHERE	Is_Cancel=0

	--						SET @Absent_date_String = NULL
	--						SELECT	@Absent_date_String = COALESCE(@Absent_date_String + '#', '') + Cast(For_Date As Varchar(11))
	--						FROM	#DATA
	--						WHERE	P_Days <> 1

 --                           exec SP_CALCULATE_LATE_DEDUCTION_SLABWISE @emp_Id,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Total_LMark output,
	--								@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,0,@Total_Late_OT_Hours output   
 --                       End					
 --                   --Else if @Late_Mark_Scenario = 2 and @Is_LateMark_Percent = 1 and @Is_LateMark_Calc_On <> 0
 --                   --    Begin
 --                   --        exec SP_CALCULATE_LATE_DEDUCTION_PERCENTAGE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,0,@Absent_date_String,@Sal_Tran_ID,@tmp_Month_St_Date,@tmp_Month_End_Date
 --                   --    End
 --                   --Else if @Late_Mark_Scenario = 3
 --                   --    Begin
 --                   --        exec SP_CALCULATE_LATE_DEDUCTION_DESIGNATION_WISE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,0,@Absent_date_String,@Sal_Tran_ID,@tmp_Month_St_Date,@tmp_Month_End_Date
 --                   --    End
 --                   --Else
 --                   --    Begin   
 --                   --        if @Late_Early_Ded_Combine = 1
 --                   --            Begin
 --                   --                Declare @var_Return_Early_Date Varchar(100)
 --                   --                exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,0,0,@Sal_Tran_ID
 --                   --            End
 --                   --        Else
 --                   --            Begin
 --                   --                exec SP_CALCULATE_LATE_DEDUCTION @emp_Id,@Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@StrWeekoff_Date,@StrHoliday_Date,0,'',0,@Absent_date_String,0,@total_count_all_incremnet,@Mid_Inc_Late_Mark_Count
 --                   --            End
 --                   --    End
 --               End
	--			FETCH NEXT FROM curEmp INTO @EMP_ID, @Increment_ID
	--	END
	--CLOSE curEmp
	--DEALLOCATE curEmp



	IF EXISTS(SELECT 1 FROM T0185_LOCKED_IN_OUT T WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON T.Emp_Id=EC.Emp_ID WHERE T.For_date BETWEEN @From_Date AND @To_Date)
		DELETE T FROM T0185_LOCKED_IN_OUT T INNER JOIN #Emp_Cons EC ON T.Emp_Id=EC.Emp_ID WHERE T.For_date BETWEEN @From_Date AND @To_Date


	SELECT TOP 0 * INTO #T0185_LOCKED_IN_OUT FROM T0185_LOCKED_IN_OUT WITH (NOLOCK)

	CREATE UNIQUE CLUSTERED INDEX IX_T0185_LOCKED_IN_OUT ON #T0185_LOCKED_IN_OUT(Emp_ID, For_Date)


	
	INSERT INTO #T0185_LOCKED_IN_OUT([LOCK_ID],[Emp_Id],[For_date],[Duration_in_sec],[Shift_ID],[Emp_OT],[P_Days],[OT_Sec],[In_Time],[Shift_Start_Time],
			[Shift_Change],[Weekoff_OT_Sec],[Holiday_OT_Sec],[Chk_By_Superior],[Out_Time],[Shift_End_Time],[GatePass_Deduct_Days])
	SELECT	LA.LOCK_ID,EC.EMP_ID, DATEADD(D, ROW_ID, @FROM_DATE),0,0,0,0,0,NULL AS IN_TIME, NULL, 
			0,0,0,0,NULL AS OUT_TIME, NULL, 0
	FROM	#Emp_Cons EC 
			INNER JOIN T0180_LOCKED_ATTENDANCE LA WITH (NOLOCK) ON LA.EMP_ID = EC.EMP_ID  AND	[MONTH] = MONTH(@TO_DATE) AND [YEAR] = YEAR(@TO_DATE)
			CROSS JOIN (SELECT top 400	ROW_NUMBER() OVER(ORDER BY OBJECT_ID) - 1 AS ROW_ID FROM sys.objects) t
	WHERE	DATEADD(D, ROW_ID, @FROM_DATE) <= @To_Date

	
	--INSERT INTO #T0185_LOCKED_IN_OUT([Emp_Id],[For_date],[Duration_in_sec],[Shift_ID],[Emp_OT],[P_Days],[OT_Sec],[In_Time],[Shift_Start_Time],
	--		[Shift_Change],[Weekoff_OT_Sec],[Holiday_OT_Sec],[Chk_By_Superior],[Out_Time],[Shift_End_Time],[GatePass_Deduct_Days])
 --   SELECT	D.Emp_Id,D.For_date,D.Duration_in_sec,D.Shift_ID,D.Emp_OT,
	--		D.P_Days,D.OT_Sec,D.In_Time,D.Shift_Start_Time,D.Shift_Change,D.Weekoff_OT_Sec,
	--		D.Holiday_OT_Sec,D.Chk_By_Superior,D.Out_Time,D.Shift_End_Time,
	--		D.GatePass_Deduct_Days
	--FROM	#DATA D

	/*Attendance*/
	
	UPDATE	T
	SET		[Duration_in_sec] = D.Duration_in_sec,
			[Shift_ID] = D.Shift_ID,
			[Emp_OT] = D.Emp_OT,
			[P_Days] = D.P_Days,
			[OT_Sec] = D.OT_Sec,
			[In_Time] = D.In_Time,
			[Shift_Start_Time] = D.Shift_Start_Time,
			[Shift_Change] = D.Shift_Change,
			[Weekoff_OT_Sec] = D.Weekoff_OT_Sec,
			[Holiday_OT_Sec] = D.Holiday_OT_Sec,
			[Chk_By_Superior] = D.Chk_By_Superior,
			[Out_Time] = D.Out_Time,
			[Shift_End_Time] = D.Shift_End_Time,
			[GatePass_Deduct_Days] = D.GatePass_Deduct_Days
	FROM	#T0185_LOCKED_IN_OUT T
			INNER JOIN #DATA D ON T.EMP_ID=D.EMP_ID AND T.For_date=D.For_date
 
	/*End of Attendance*/


	
	/*Holiday & WeekOff*/
	UPDATE	T
	SET		W_Days=W.W_Day,
			Shift_ID=IsNull(T.Shift_ID,SM.Shift_ID),
			Shift_Start_Time = IsNull(T.Shift_Start_Time, SM.Shift_St_Time + T.FOR_DATE),
			Shift_End_Time = IsNull(T.Shift_End_Time, SM.Shift_End_Time + T.FOR_DATE)
	FROM	#T0185_LOCKED_IN_OUT T
			INNER JOIN #Emp_WeekOff W ON T.EMP_ID=W.EMP_ID AND T.FOR_DATE=W.FOR_DATE
			,T0040_Shift_Master SM
	WHERE	SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,W.Emp_ID,W.For_Date)
			AND W.Is_Cancel=0

		
	UPDATE	T
	SET		H_Days=H.H_Day,
			Shift_ID=IsNull(T.Shift_ID,SM.Shift_ID),
			Shift_Start_Time = IsNull(T.Shift_Start_Time,  SM.Shift_St_Time + T.FOR_DATE),
			Shift_End_Time = IsNull(T.Shift_End_Time, SM.Shift_End_Time + T.FOR_DATE)
	FROM	#T0185_LOCKED_IN_OUT T			
			INNER JOIN #Emp_Holiday H ON T.EMP_ID=H.EMP_ID AND T.FOR_DATE=H.FOR_DATE
			,T0040_Shift_Master SM
	WHERE	SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,H.Emp_ID,H.For_Date)
			AND H.Is_Cancel=0

	SELECT TOP 0 * INTO #T0185_LOCKED_HW FROM T0185_LOCKED_HW WITH (NOLOCK)

	INSERT INTO #T0185_LOCKED_HW(Lock_Id,Emp_ID,For_Date,DayName,HW_Day,Is_P_Comp,Is_Half,Is_Cancel,CancelReason,Flag)
	SELECT	La.Lock_Id,T.*
	FROM	(
				SELECT	W.EMP_ID, W.FOR_DATE, WeekOff_Day,W_Day,0 As Is_P_Comp, 0 As Is_Half, Is_Cancel,WS.CancelReason As CancelReason, 'W' As Flag
				FROM	#EMP_WEEKOFF W
						LEFT OUTER JOIN #EMP_WEEKOFF_SUMMARY WS ON W.EMP_ID=WS.EMP_ID AND W.FOR_DATE=WS.FOR_DATE
				UNION ALL
				SELECT	H.EMP_ID, H.FOR_DATE, IsNull(HS.HolidayName, 'Holiday'),H_Day,H.Is_P_Comp,H.Is_Half, Is_Cancel,HS.CancelReason As CancelReason, 'H' As Flag
				FROM	#EMP_HOLIDAY H
						LEFT OUTER JOIN #EMP_HOLIDAY_SUMMARY HS ON H.EMP_ID=HS.EMP_ID AND H.FOR_DATE=HS.FOR_DATE
			) T 
			INNER JOIN #T0185_LOCKED_IN_OUT LA WITH (NOLOCK) ON T.EMP_ID=LA.EMP_ID AND T.FOR_DATE=LA.FOR_DATE
	ORDER BY EMP_ID, FOR_DATE, Flag

	--INSERT	INTO #T0185_LOCKED_IN_OUT([Emp_Id],[For_date],[Shift_ID],[P_Days],[Shift_Start_Time],[Shift_End_Time],[W_Days])
	--SELECT	Emp_ID, For_Date, SM.Shift_ID,0,SM.Shift_St_Time, SM.Shift_End_Time,W_Day
	--FROM	#Emp_WeekOff W, T0040_Shift_Master SM
	--WHERE	SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,W.Emp_ID,W.For_Date)
	--		AND NOT EXISTS(SELECT 1 FROM #DATA D WHERE W.EMP_ID=D.EMP_ID AND W.FOR_DATE=D.FOR_DATE)

	--INSERT	INTO #T0185_LOCKED_IN_OUT([Emp_Id],[For_date],[Shift_ID],[P_Days],[Shift_Start_Time],[Shift_End_Time],[H_Days])
	--SELECT	Emp_ID, For_Date, SM.Shift_ID,0,SM.Shift_St_Time, SM.Shift_End_Time,H_Day
	--FROM	#Emp_Holiday H, T0040_Shift_Master SM
	--WHERE	SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,H.Emp_ID,H.For_Date)
	--		AND NOT EXISTS(SELECT 1 FROM #DATA D WHERE H.EMP_ID=D.EMP_ID AND H.FOR_DATE=D.FOR_DATE)

	/*End of Holiday & WeekOff*/
	
	/*Leave Days*/
	Declare @OD_Compoff_As_Present tinyint
	Set @OD_Compoff_As_Present = 0
				
	Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name='OD and CompOff Leave Consider As Present'

	SELECT TOP 0 * INTO #T0185_LOCKED_LEAVE FROM T0185_LOCKED_LEAVE WITH (NOLOCK)

	
	INSERT INTO #T0185_LOCKED_LEAVE(Lock_Id,Emp_ID,For_Date,Leave_ID,Leave_Type,Leave_Days,IsPaid,IsCompOff,IsOD,Leave_Approval_ID)
	SELECT	La.Lock_Id,LT.Emp_ID,LT.For_Date,LT.Leave_ID,'' As Leave_Type,
			LT.CompOff_Used + Case When LM.Apply_Hourly = 1 AND LT.Leave_Used % 1 = 0  Then LT.Leave_Used * 0.125 Else LT.Leave_Used End As Leave_Days,
			Case When LM.Leave_Paid_UnPaid = 'P' Then 1 Else 0 End As IsPaid,
			Case When LM.Default_Short_Name IN ('COMP', 'COND', 'COPH') Then 1 Else 0 End As IsCompOff,
			Case When LM.Leave_Type = 'Company Purpose' Then 1 Else 0 End IsOD, 0 As Leave_Approval_ID
	FROM	T0140_Leave_Transaction LT	WITH (NOLOCK)
			INNER JOIN T0040_Leave_Master LM WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
			INNER JOIN #T0185_LOCKED_IN_OUT LA WITH (NOLOCK) ON LT.EMP_ID=LA.EMP_ID AND LT.FOR_DATE=LA.FOR_DATE
	WHERE	(LT.Leave_Used + LT.CompOff_Used) > 0

	UPDATE	LL
	SET		Leave_Approval_ID = LA.Leave_Approval_ID,
			Leave_Type = Case 	When LL.For_Date = LAD.Half_Leave_Date OR IsNull(LAD.Half_Leave_Date, '1900-01-01') = '1900-01-01' Then 
									LAD.Leave_Assign_As 								
								Else 
									'Full Day' 
						End,
			From_Time = LAD.Leave_Out_Time,
			To_Time = LAD.Leave_In_Time
	FROM	#T0185_LOCKED_LEAVE LL
			INNER JOIN T0130_Leave_Approval_Detail LAD ON LL.Leave_ID=LAD.Leave_ID AND LL.For_Date Between LAD.From_Date AND LAD.To_Date
			INNER JOIN T0120_Leave_Approval LA ON LL.Emp_ID=LA.Emp_ID AND LAD.Leave_Approval_ID=LA.Leave_Approval_ID
	Where	NOT EXISTS(Select 1 FROM T0150_Leave_Cancellation LC WITH (NOLOCK)
						WHERE LC.For_Date=LL.For_Date AND LC.Leave_Approval_ID=LA.Leave_Approval_ID)
			AND LA.Approval_Status = 'A'



	UPDATE	T
	SET		Leave_Days= LT.Leave_Days,
			Shift_ID=IsNull(T.Shift_ID,SM.Shift_ID),
			Shift_Start_Time = IsNull(T.Shift_Start_Time, SM.Shift_St_Time + T.FOR_DATE),
			Shift_End_Time = IsNull(T.Shift_End_Time, SM.Shift_End_Time + T.FOR_DATE)
	FROM	#T0185_LOCKED_IN_OUT T			
			INNER JOIN (SELECT	Emp_ID, For_Date, IsNull(Sum(Leave_Days),0) As Leave_Days 
						FROM	#T0185_LOCKED_LEAVE WITH (NOLOCK)
						WHERE	(@OD_Compoff_As_Present = 0 OR (@OD_Compoff_As_Present = 1 AND IsOD = 0 AND IsCompOff=0))
						GROUP BY Emp_ID,For_Date) LT ON T.Emp_ID=LT.Emp_ID AND T.For_Date=LT.For_Date
			--INNER JOIN (SELECT	LT.Emp_ID, LT.For_Date, Sum(CompOff_Used) As CompOff_Used, Sum(Case When LM.Apply_Hourly = 1 AND Leave_Used % 1 = 0  Then Leave_Used * 0.125 Else Leave_Used End) As Leave_Used
			--			FROM	T0140_LEAVE_TRANSACTION LT 
			--					INNER JOIN #Emp_Cons EC ON LT.Emp_ID=EC.Emp_ID
			--					INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID=LM.Leave_ID
			--			WHERE	LT.For_Date BETWEEN @From_Date AND @To_Date AND (CompOff_Used > 0 OR Leave_Used > 0)
			--					AND (@OD_Compoff_As_Present = 0 OR (@OD_Compoff_As_Present = 1 AND LM.Leave_Type <> 'Company Purpose' AND LM.Default_Short_Name NOT IN ('COMP', 'COND', 'COPH')))
			--			GROUP BY LT.Emp_ID, LT.For_Date
			--			) LT ON T.EMP_ID=LT.EMP_ID AND T.FOR_DATE=LT.FOR_DATE
			,T0040_Shift_Master SM WITH (NOLOCK)
	WHERE	SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,T.Emp_ID,T.For_Date)

	
	IF @OD_Compoff_As_Present = 1
		UPDATE	T
		SET		P_Days= P_Days + LT.Leave_Days,
				Shift_ID=IsNull(T.Shift_ID,SM.Shift_ID),
				Shift_Start_Time = IsNull(T.Shift_Start_Time, SM.Shift_St_Time + T.FOR_DATE),
				Shift_End_Time = IsNull(T.Shift_End_Time, SM.Shift_End_Time + T.FOR_DATE)
		FROM	#T0185_LOCKED_IN_OUT T			
				INNER JOIN (SELECT	Emp_ID, For_Date, Sum(Leave_Days) As Leave_Days FROM #T0185_LOCKED_LEAVE  
							WHERE	(IsOD = 1 OR IsCompOff=1)
							GROUP BY Emp_ID,For_Date) LT ON T.Emp_ID=LT.Emp_ID AND T.For_Date=LT.For_Date
				--INNER JOIN (SELECT	LT.Emp_ID, LT.For_Date, Sum(CompOff_Used) As CompOff_Used, Sum(Case When LM.Apply_Hourly = 1 AND Leave_Used % 1 = 0  Then Leave_Used * 0.125 Else Leave_Used End) As Leave_Used
				--			FROM	T0140_LEAVE_TRANSACTION LT 
				--					INNER JOIN #Emp_Cons EC ON LT.Emp_ID=EC.Emp_ID
				--					INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID=LM.Leave_ID
				--			WHERE	LT.For_Date BETWEEN @From_Date AND @To_Date AND (CompOff_Used > 0 OR Leave_Used > 0)
				--					AND  (LM.Leave_Type = 'Company Purpose' OR LM.Default_Short_Name IN ('COMP', 'COND', 'COPH'))
				--			GROUP BY LT.Emp_ID, LT.For_Date
				--			) LT ON T.EMP_ID=LT.EMP_ID AND T.FOR_DATE=LT.FOR_DATE
				,T0040_Shift_Master SM WITH (NOLOCK)
		WHERE	SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,T.Emp_ID,T.For_Date)
		
	UPDATE	#T0185_LOCKED_IN_OUT SET P_DAYS = 1 WHERE P_DAYS > 1
	/*End of Leave Days*/
	
	
	/*Late Early Mark*/	
	EXEC P_CALCULATE_LATE_EARLY_DEDUCTION_DAYS @CMP_ID=@CMP_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE
	/*End of Late Early Mark*/

	UPDATE #T0185_LOCKED_IN_OUT
	Set		LateSalDeduDays = LateSalDeduDays  - 9999
	Where	LateSalDeduDays > 9999

	--SELECT EMP_ID, SUM(P_DAYS) P_DAYS,SUM(LEAVE_DAYS) AS LEAVE_DAYS, SUM(W_Days) AS W_Days, SUM(H_Days) H_Days, Sum(LateSalDeduDays) LateSalDeduDays, Sum(EarlySalDeduDays) As EarlySalDeduDays  
	--FROM #T0185_LOCKED_IN_OUT
	--GROUP BY EMP_ID

	DELETE T FROM T0185_LOCKED_IN_OUT T INNER JOIN #T0185_LOCKED_IN_OUT T1 ON T.Emp_Id=T1.Emp_Id
	WHERE T.For_date BETWEEN @From_Date AND @To_Date

	DELETE T FROM T0185_LOCKED_HW T INNER JOIN #T0185_LOCKED_HW T1 ON T.Emp_Id=T1.Emp_Id
	WHERE T.For_date BETWEEN @From_Date AND @To_Date

	DELETE T FROM T0185_LOCKED_LEAVE T INNER JOIN #T0185_LOCKED_LEAVE T1 ON T.Emp_Id=T1.Emp_Id
	WHERE T.For_date BETWEEN @From_Date AND @To_Date

	--TRUNCATE TABLE T0185_LOCKED_IN_OUT

	--SELECT * FROM #EMP_WEEKOFF
	--SELECT  * FROM #T0185_LOCKED_IN_OUT
	
	ALTER TABLE #T0185_LOCKED_IN_OUT
	DROP COLUMN TRAN_ID

	ALTER TABLE #T0185_LOCKED_HW
	DROP COLUMN TRAN_ID

	ALTER TABLE #T0185_LOCKED_LEAVE
	DROP COLUMN TRAN_ID

	
	INSERT INTO T0185_LOCKED_IN_OUT
	SELECT * FROM #T0185_LOCKED_IN_OUT

	INSERT INTO T0185_LOCKED_HW
	SELECT * FROM #T0185_LOCKED_HW

	INSERT INTO T0185_LOCKED_LEAVE
	SELECT * FROM #T0185_LOCKED_LEAVE
	
	

	EXEC P_LATE_EARLY_ADJUST @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Constraint=@Constraint
	--select * from #EMP_LATE_EARLY
END


