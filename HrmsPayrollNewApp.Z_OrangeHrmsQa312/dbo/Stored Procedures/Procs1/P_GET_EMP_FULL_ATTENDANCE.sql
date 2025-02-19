
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_EMP_FULL_ATTENDANCE]
	@CmpID				Numeric			= 149
	,@Month				NUMERIC			= 7
	,@Year				NUMERIC			= 2017
	,@BranchID			VARCHAR(MAX)    = ''
	,@CatID				VARCHAR(MAX)    = ''
	,@GrdID				VARCHAR(MAX)    = ''
	,@TypeID			Numeric			= 0  
	,@DeptID			VARCHAR(MAX)    = ''
	,@EmpID				Numeric			= 0 
	,@SalCycleID		Numeric			= 0 
	,@VerticalID		VARCHAR(MAX)    = ''
	,@SubVerticalID		VARCHAR(MAX)    = ''
	,@SegmentID			VARCHAR(MAX)	= ''
	,@SubBranchID		VARCHAR(MAX)    = ''
AS
	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @From_Date DateTime
	DECLARE @To_Date DateTime

	SET @From_Date = Cast(Cast(@Year as Varchar(4)) + '-' + Cast(@Month as Varchar(2)) + '-01' as datetime)
	SET	@To_Date  = DATEADD(D, -1, DATEADD(MM, 1, @From_Date))
		
	/*GETTING EMPLOYEE DETAILS*/
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID Numeric ,     
		Branch_ID Numeric,
		Increment_ID Numeric    
	);

	Exec [dbo].[SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN] 
				@Cmp_ID=@CmpID,
				@From_Date = @From_Date,
				@To_Date=@To_Date,
				@Branch_ID=@BranchID,
				@Cat_ID=@CatID,
				@Grd_ID=@GrdID,
				@Type_ID=@TypeID,
				@Dept_ID=@DeptID,
				@Desig_ID ='',
				@Emp_ID = @EmpID,
				@constraint = '',
				@Sal_Type = 0,
				@Salary_Cycle_id = @SalCycleID,
				@Segment_Id=@SegmentID,
				@Vertical_Id=@VerticalID,
				@SubVertical_Id =@SubVerticalID,
				@SubBranch_Id=@SubBranchID,
				@New_Join_emp =0,
				@Left_Emp = 0,
				@SalScyle_Flag = 0,
				@PBranch_ID = 0,
				@With_Ctc = 0,
				@Type = 0
 
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
	
	
	DELETE	EC 
	FROM	#Emp_Cons EC					
			left outer join (SELECT TOP 1500 Emp_ID FROM #Emp_Cons EC) EC1 ON EC.Emp_ID=EC1.EMP_ID
	where	ec1.Emp_ID is null	
	
	
	DECLARE @Constraint VARCHAR(MAX)
	SELECT	@Constraint =  COALESCE(@Constraint + '#', '') + CAST(Emp_ID As VarChar(10))
	FROM	#Emp_Cons 

	/*END OF EMPLOYEE DETAILS*/

	/*FOR LATE MARK TABLE DECLARATION*/

	CREATE TABLE #Emp_Late   
	(  
		Emp_ID   numeric ,  
		Cmp_ID   numeric ,  
		Increment_ID numeric,  
		For_Date  Datetime ,  
		In_Time   Datetime ,  
		Shift_Time  Datetime ,  
		Late_Sec  int default 0 ,  
		Late_Limit_Sec int default 0,  
		Late_Hour  varchar(10), 
		Branch_Id NUMERIC,
		Late_Limit Varchar(100),
		Out_Time   Datetime,		
		Shift_ID	   numeric,	 -- Added by Gadriwala Muslim 30062015	
		Shift_End_Time  Datetime,	
		Shift_Max_St_Time Datetime,
		Shift_max_Ed_Time DATETIME,
		Early_Sec INT DEFAULT 0,
		Early_Limit_Sec int default 0,
		Early_hour VARCHAR(10),
		Early_Limit Varchar(100),
		Late_Deduct_Days numeric(18,2) default 0, 
		Early_Deduct_Days numeric(18,2) default 0,
		Is_Early tinyint default 0,
		Is_Late tinyint default 0 ,
		Is_Maximum_Late tinyint default 0,-- Changed by Gadriwala Muslim 23062015 
		Is_Late_Calc_Ho_WO tinyint default 0, --Changed by Gadriwala Muslim 03072015 
		Is_Early_Calc_Ho_Wo tinyint default 0, --Changed by Gadriwala Muslim 03072015 
		Extra_Exempted_Sec numeric(18,0) default 0,	-- Added by Gadriwala Muslim 28102015
		Extra_Exempted tinyint default 0	,		-- Added by Gadriwala Muslim 28102015
		Late_Mark_Scenario tinyint default 1,
		Is_Late_Mark_Percentage tinyint default 0
	)  
	  
	CREATE NONCLUSTERED INDEX ix_Emp_Late_EmpID_For_Date ON #Emp_Late(Emp_ID,For_Date) ;

	/*END OF LATE MARK TABLE DECLARATION*/

	/*GETTING IN-OUT DETAILS*/
	CREATE TABLE #Data     
	(     
		Emp_ID					Numeric,     
		For_date				DateTime,    
		Duration_in_sec			Numeric,    
		Shift_ID				Numeric,    
		Shift_Type				Numeric ,    
		Emp_OT					Numeric,    
		Emp_OT_min_Limit		Numeric,    
		Emp_OT_max_Limit		Numeric,    
		P_days					Numeric(12,3)	Default 0,
		OT_Sec					Numeric			Default 0,
		In_Time					DateTime		Default NULL,
		Shift_Start_Time		DateTime		Default NULL,
		OT_Start_Time			Numeric			Default 0,
		Shift_Change			TinyInt			Default 0,
		Flag					Int				Default 0,
		Weekoff_OT_Sec			Numeric			Default 0,
		Holiday_OT_Sec			Numeric			Default 0,
		Chk_By_Superior			Numeric			Default 0,
		IO_Tran_Id				Numeric			Default 0,
		Out_time				DateTime		Default null,
		Shift_End_Time			DateTime,
		OT_End_Time				Numeric			Default 0,
		Working_Hrs_St_Time		TinyInt			Default 0,
		Working_Hrs_End_Time	TinyInt			Default 0,
		GatePass_Deduct_Days	Numeric(18,2)	Default 0
	)



	/*************************************************************************
	Added by Nimesh: 27/Dec/2017 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/

	/*GETTING HOLIDAYS AND WEEKOFF DATA*/
	CREATE TABLE #EMP_HOLIDAY
	(
		EMP_ID Numeric, 
		FOR_DATE DateTime, 
		IS_CANCEL BIT, 
		Is_Half TinyInt, 
		Is_P_Comp TinyInt, 
		H_DAY Numeric(4,1)
	);
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

	CREATE TABLE #EMP_WEEKOFF
	(
		Row_ID			Numeric,
		Emp_ID			Numeric,
		For_Date		DateTime,
		Weekoff_day		VARCHAR(10),
		W_Day			Numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		

	--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
	CREATE TABLE #Emp_WeekOff_Holiday
	(
		Emp_ID				Numeric,
		WeekOffDate			VARCHAR(Max),
		WeekOffCount		Numeric(4,1),
		HolidayDate			VARCHAR(Max),
		HolidayCount		Numeric(4,1),
		HalfHolidayDate		VARCHAR(Max),
		HalfHolidayCount	Numeric(4,1),
		OptHolidayDate		VARCHAR(Max),
		OptHolidayCount		Numeric(4,1)
	);

	--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
	CREATE TABLE #EMP_HW_CONS
	(
		Emp_ID				Numeric,
		WeekOffDate			Varchar(Max),
		WeekOffCount		Numeric(4,1),
		CancelWeekOff		Varchar(Max),
		CancelWeekOffCount	Numeric(4,1),
		HolidayDate			Varchar(MAX),
		HolidayCount		Numeric(4,1),
		HalfHolidayDate		Varchar(MAX),
		HalfHolidayCount	Numeric(4,1),
		CancelHoliday		Varchar(Max),
		CancelHolidayCount	Numeric(4,1)
	);
		
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)

	CREATE TABLE #EMP_GEN_SETTING
	(
		Branch_ID	NUMERIC,
		Gen_ID		NUMERIC
	)
	

	INSERT INTO #EMP_GEN_SETTING 
	SELECT	T.Branch_ID, G.Gen_ID
	FROM	(SELECT DISTINCT BRANCH_ID FROM #Emp_Cons) T
			INNER JOIN (SELECT	G.Branch_ID, MAX(G.Gen_ID) AS Gen_ID
						FROM	T0040_GENERAL_SETTING G WITH (NOLOCK)
								INNER JOIN (SELECT	Branch_ID, MAX(G1.For_Date) AS For_Date
											FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
											WHERE	G1.For_Date <= @To_Date
													AND EXISTS(SELECT 1 FROM #Emp_Cons EC WHERE EC.Branch_ID=G1.Branch_ID)
											GROUP BY G1.Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID AND G.For_Date=G1.For_Date
						GROUP BY G.Branch_ID) G ON T.Branch_ID = G.Branch_ID
	
	DECLARE @All_Weekoff BIT
	SET @All_Weekoff = 0;
		
	
	--PRINT ' STAGE 1 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@CmpID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = @All_Weekoff, @Exec_Mode=0, @Delete_Cancel_HW = 0

	--PRINT ' STAGE 2 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)
	--/*END OF HOLIDAYS AND WEEKOFF DATA CODE*/

	DELETE FROM #DATA WHERE FOR_DATE NOT BETWEEN @From_Date AND @To_Date
	

	CREATE TABLE #ATT_DATES (ROW_ID INT, FOR_DATE DATETIME)

	INSERT INTO #ATT_DATES  
	SELECT	ROW_ID, DATEADD(D,ROW_ID-1, @FROM_DATE)
	FROM	(SELECT	TOP 31 ROW_NUMBER() OVER (ORDER BY OBJECT_ID) AS ROW_ID	
			FROM	SYS.objects ) T
	WHERE	DATEADD(D,ROW_ID-1, @FROM_DATE) <= @To_Date

	CREATE TABLE #T0180_EMP_LOCKED_ATTENDANCE(
		[Emp_ID] [numeric](18, 0) NOT NULL,
		[Cmp_ID] [numeric](18, 0) NOT NULL,
		[For_Date] [datetime] NOT NULL,
		[Duration_In_Sec] [numeric](18, 0) NOT NULL,
		[Shift_ID] [int] NOT NULL,
		[P_Days] [numeric](5, 3) NOT NULL,
		[A_Days] [numeric](5, 3) NULL DEFAULT(1),
		[In_Time] [datetime] NULL,
		[Shift_Start_Time] [datetime] NULL,
		[Out_Time] [datetime] NULL,
		[Shift_End_Time] [datetime] NULL,
		[OT_Sec] [int] NOT NULL,
		[Weekoff_OT_Sec] [int] NOT NULL,
		[Holiday_OT_Sec] [int] NOT NULL,
		[GatePass_Deduct_Days] [numeric](5, 3) NULL,
		[Chk_By_Superior] [tinyint] NOT NULL,
		[Leave_Days] [numeric](5, 3) NOT NULL,
		[On_Duty] [numeric](5, 3) NOT NULL,
		[H_Day] [numeric](5, 3) NOT NULL,
		[W_Day] [numeric](5, 3) NOT NULL,
		[HW_FLAG] [CHAR] (1) NULL,
		[Is_Exempted] [bit] NOT NULL,
		[Late_Days] [numeric](5, 3) NOT NULL,
		[Early_Days] [numeric](5, 3) NOT NULL	
	)

	CREATE UNIQUE CLUSTERED INDEX IX_T0180_EMP_LOCKED_ATTENDANCE_TEMP ON #T0180_EMP_LOCKED_ATTENDANCE(EMP_ID,FOR_DATE)


	INSERT INTO #T0180_EMP_LOCKED_ATTENDANCE	
			(Emp_ID,Cmp_ID,For_Date		,Duration_In_Sec,Shift_ID,P_Days,In_Time,Shift_Start_Time,Out_Time,Shift_End_Time,OT_Sec,Weekoff_OT_Sec,Holiday_OT_Sec,GatePass_Deduct_Days,Chk_By_Superior,Leave_Days,On_Duty,H_Day,W_Day,HW_FLAG,Is_Exempted,Late_Days,Early_Days)
	SELECT	EC.Emp_ID,@CmpID,D.FOR_DATE,              0,       0,     0,   Null,            Null,    Null,          Null,     0,             0,             0,                   0,              0,         0,		0,    0,    0,   NULL,          0,        0,         0    
	FROM	#Emp_Cons EC
			CROSS JOIN #ATT_DATES  D
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=EC.EMP_ID AND D.FOR_DATE BETWEEN EM.Date_Of_Join AND IsNull(EM.Emp_Left_Date, D.For_Date)

	/*Getting Leave Detail*/
	CREATE TABLE #T0190_EMP_LOCKED_LEAVE_DETAIL
	(
		[Emp_ID] [numeric](18, 0) NOT NULL,
		[Cmp_ID] [numeric](18, 0) NOT NULL,
		[For_Date] [datetime] NOT NULL,
		[Leave_ID] [numeric](18,0) NOT NULL,
		[Leave_Period] [numeric](9,3) NOT NULL,
		[Leave_Type] [varchar](32) NOT NULL,
		[From_Time] [DateTime] NULL,
		[To_Time] [DateTime] NULL,
		[App_ID] [numeric](18,0) NULL,
		[Apr_ID] [numeric](18,0) NULL,
		[Is_Comp_Purpose] BIT NOT NULL
	)

	CREATE UNIQUE CLUSTERED INDEX IX_T0190_EMP_LOCKED_LEAVE_DETAIL_TEMP ON #T0190_EMP_LOCKED_LEAVE_DETAIL(EMP_ID, FOR_DATE, Leave_ID)

	INSERT	INTO #T0190_EMP_LOCKED_LEAVE_DETAIL(Emp_ID,Cmp_ID,For_Date,Leave_ID,Leave_Period,Leave_Type,Is_Comp_Purpose)
	SELECT	LT.Emp_ID,@CmpID,LT.For_Date,LT.Leave_ID,(Case When LT.CompOff_Used > 0 Then LT.CompOff_Used  - IsNull(LT.Leave_Encash_Days,0) Else LT.Leave_Used END), '', CASE WHEN LM.Leave_Type = 'Company Purpose' THEN 1 ELSE 0 END
	FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON LT.Emp_ID = EC.Emp_ID
			INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
			INNER JOIN #ATT_DATES  D ON LT.For_Date=D.FOR_DATE
	WHERE	(Case When CompOff_Used > 0 Then CompOff_Used - IsNull(Leave_Encash_Days,0) Else Leave_Used END) > 0

	

	/*For Full Day Leave Without Cancellation*/
	UPDATE	LD
	SET		Leave_Type = 'Full Day',
			From_Time = CASE WHEN LAD.Leave_In_Time = '1900-01-01 00:00:00' THEN NULL ELSE LAD.Leave_In_Time END,
			To_Time = CASE WHEN LAD.Leave_out_time = '1900-01-01 00:00:00' THEN NULL ELSE LAD.Leave_out_time END,
			App_ID = LA.Leave_Application_ID,
			Apr_ID = LA.Leave_Approval_ID
	FROM	T0120_LEAVE_APPROVAL LA 
			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
			INNER JOIN #T0190_EMP_LOCKED_LEAVE_DETAIL LD ON LA.Emp_ID=LD.Emp_ID AND LA.Cmp_ID=LD.Cmp_ID AND LD.For_Date BETWEEN LAD.From_Date AND LAD.To_Date AND LD.Leave_ID=LAD.Leave_ID		
	WHERE	NOT EXISTS(SELECT 1 FROM T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) WHERE LC.Leave_Approval_id=LA.Leave_Approval_ID AND LC.For_date=LD.For_Date AND lc.Is_Approve=1)		
			AND LA.Approval_Status = 'A' AND LD.Leave_Period = 1

	
	/*If Half Day Cancelled*/
	UPDATE	LD
	SET		Leave_Type = Case	When LC.Leave_Approval_id IS NULL Then 
									LAD.Leave_Assign_As 
								When LC.Day_type = 'First Half' Then 
									'Second Half' 
								When LC.Day_type = 'Second Half' Then 
									'First Half' 
								Else 
									LAD.Leave_Assign_As 
						END,
			From_Time = LAD.Leave_In_Time,
			To_Time = LAD.Leave_out_time,
			App_ID = LA.Leave_Application_ID,
			Apr_ID = LA.Leave_Approval_ID
	FROM	T0120_LEAVE_APPROVAL LA 
			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
			INNER JOIN #T0190_EMP_LOCKED_LEAVE_DETAIL LD ON LA.Emp_ID=LD.Emp_ID AND LA.Cmp_ID=LD.Cmp_ID AND LD.For_Date BETWEEN LAD.From_Date AND LAD.To_Date AND LD.Leave_ID=LAD.Leave_ID		
			LEFT OUTER JOIN T0150_LEAVE_CANCELLATION LC ON LA.Leave_Approval_ID=LC.Leave_Approval_id AND LD.For_Date=LC.For_date
	WHERE	LA.Approval_Status = 'A' 

	UPDATE	LD
	SET		From_Time = NULL,
			To_Time = NULL
	FROM	#T0190_EMP_LOCKED_LEAVE_DETAIL LD 
	WHERE	From_Time = To_Time

	UPDATE	LD
	SET		Leave_Period = Leave_Period
	FROM	#T0190_EMP_LOCKED_LEAVE_DETAIL LD
	/*End Of Code Leave Detail*/

	--PRINT ' STAGE 3 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)

	DECLARE @Cur_Branch_ID NUMERIC
	DECLARE @LateEarlyCons Varchar(MAX)

	DECLARE curEmp CURSOR FAST_FORWARD FOR
	SELECT	DISTINCT BRANCH_ID FROM #Emp_Cons ORDER BY Branch_ID

	OPEN curEmp
	FETCH NEXT FROM curEmp INTO @Cur_Branch_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @Constraint = NULL;
			--PRINT ' STAGE 3.1 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)

			SELECT	@Constraint = COALESCE(@Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(10)) 
			FROM	#Emp_Cons EC
			WHERE	Branch_ID=@Cur_Branch_ID

			--PRINT @Constraint		

			--TRUNCATE TABLE #DATA
			--TRUNCATE TABLE #EMP_WEEKOFF
			--TRUNCATE TABLE #EMP_HOLIDAY
			--TRUNCATE TABLE #EMP_WEEKOFF
			--TRUNCATE TABLE #Emp_WeekOff_Holiday
			--TRUNCATE TABLE #EMP_HW_CONS
	
			/*Getting Present Days*/
			PRINT 'START : '  + CONVERT(VARCHAR(20), GETDATE(), 114)
			Exec dbo.SP_CALCULATE_PRESENT_DAYS @CmpID,@From_Date,@To_Date,0,0,0,@TypeID,0,0,0,@Constraint,4,'',1   
			PRINT 'END : '  + CONVERT(VARCHAR(20), GETDATE(), 114)
			
			
			--PRINT ' STAGE 3.2 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)

			IF EXISTS(SELECT 1 FROM #EMP_GEN_SETTING EG INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON EG.Gen_ID=G.Gen_ID WHERE G.Is_Late_Mark=1 AND EG.Branch_ID=@Cur_Branch_ID)
				BEGIN 
					SET @LateEarlyCons = NULL
					SELECT	@LateEarlyCons = COALESCE(@LateEarlyCons + '#', '') + CAST(EC.EMP_ID AS VARCHAR(10)) 
					FROM	#Emp_Cons EC
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID							
					WHERE	EC.Branch_ID=@BranchID AND I.Emp_Late_mark = 1 -- AND I.Emp_Early_mark = 1

					TRUNCATE TABLE #Emp_Late
					/*Getting Late Days*/
					IF @LateEarlyCons IS NOT NULL
						exec rpt_Late_Early_Mark_Deduction_Details 
								@Cmp_ID=@CmpID,
								@From_Date=@From_Date,
								@To_Date=@To_Date,
								@Branch_ID=0,
								@Cat_ID=0,
								@Grd_ID=0,
								@Type_ID=0,
								@Dept_ID=0,
								@Desig_ID=0,
								@Emp_ID=0,
								@Constraint=@LateEarlyCons,
								@Format_Type='Late',
								@Report_Type=0	

					PRINT 'END LATE : '  + CONVERT(VARCHAR(20), GETDATE(), 114)
					UPDATE	EL
					SET		Late_Days	= IsNull(LE.Late_Deduct_Days,0),
							Is_Exempted = Case When (IsNull(LE.Late_Sec,0) > 0 AND IsNull(LE.Late_Deduct_Days,0) = 0) Then 1 Else 0 END			
					FROM	#T0180_EMP_LOCKED_ATTENDANCE EL 							
							LEFT OUTER JOIN #Emp_Late LE ON EL.Emp_ID=LE.Emp_ID AND EL.For_Date=LE.For_Date
					----PRINT ' STAGE 3.3 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)
					SET @LateEarlyCons = NULL
					SELECT	@LateEarlyCons = COALESCE(@LateEarlyCons + '#', '') + CAST(EC.EMP_ID AS VARCHAR(10)) 
					FROM	#Emp_Cons EC
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID							
					WHERE	EC.Branch_ID=@BranchID AND I.Emp_Early_mark = 1

					TRUNCATE TABLE #Emp_Late
					/*Getting Early Days*/
					IF @LateEarlyCons IS NOT NULL
						exec rpt_Late_Early_Mark_Deduction_Details 
								@Cmp_ID=@CmpID,
								@From_Date=@From_Date,
								@To_Date=@To_Date,
								@Branch_ID=0,
								@Cat_ID=0,
								@Grd_ID=0,
								@Type_ID=0,
								@Dept_ID=0,
								@Desig_ID=0,
								@Emp_ID=0,
								@Constraint=@LateEarlyCons,
								@Format_Type='Early',
								@Report_Type=0	
					----PRINT ' STAGE 3.4 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)
					PRINT 'END EARLY : '  + CONVERT(VARCHAR(20), GETDATE(), 114)
				END			
			

			UPDATE	EL
			SET		Duration_In_Sec = IsNull(D.Duration_In_Sec,0),
					Shift_ID = COALESCE(D.Shift_ID,dbo.fn_get_Shift_From_Monthly_Rotation(@CmpID,EL.Emp_ID,EL.For_Date),0),
					P_Days = IsNull(D.P_Days,0),
					In_Time = D.In_Time,
					Shift_Start_Time = D.Shift_Start_Time,
					Out_Time = D.Out_Time,
					Shift_End_Time = D.Shift_End_Time,
					OT_Sec = IsNull(D.OT_Sec,0),
					Weekoff_OT_Sec = IsNull(D.Weekoff_OT_Sec,0),
					Holiday_OT_Sec = IsNull(D.Holiday_OT_Sec,0),
					GatePass_Deduct_Days = IsNull(D.GatePass_Deduct_Days,0),
					Chk_By_Superior = IsNull(D.Chk_By_Superior,0),
		
					Leave_Days = IsNull(L.Leave_Period,0),
					On_Duty = IsNull(L.OD,0),
					
		
					H_Day = IsNull(H.H_Day,0),
					W_Day = IsNull(W.W_Day,0),
					HW_FLAG = Case When H.EMP_ID IS NOT NULL Then 'H' When W.Emp_ID IS NOT NULL Then 'W' Else NULL END,
		
					Early_Days	= IsNull(LE.Early_Deduct_Days,0),
					Is_Exempted = Is_Exempted + Case When (IsNull(LE.Early_Sec,0) > 0 AND IsNull(LE.Early_Deduct_Days,0) = 0) Then 1 Else 0 END			
			FROM	#T0180_EMP_LOCKED_ATTENDANCE EL 
					LEFT OUTER JOIN #Data D ON EL.EMP_ID=D.EMP_ID AND EL.FOR_DATE = D.For_date
					LEFT OUTER JOIN #EMP_WEEKOFF W ON EL.EMP_ID=W.EMP_ID AND EL.FOR_DATE = W.For_date
					LEFT OUTER JOIN #EMP_HOLIDAY H ON EL.EMP_ID=H.EMP_ID AND EL.FOR_DATE = H.For_date		
					LEFT OUTER JOIN #Emp_Late LE ON EL.Emp_ID=LE.Emp_ID AND EL.For_Date=LE.For_Date
					LEFT OUTER JOIN  (SELECT	EMP_ID,FOR_DATE, SUM(Case When Is_Comp_Purpose = 0 THEN Leave_Period ELSE 0 END) As Leave_Period, SUM(Case When Is_Comp_Purpose = 1 THEN Leave_Period ELSE 0 END) As OD
									  FROM		#T0190_EMP_LOCKED_LEAVE_DETAIL L
									  GROUP	 BY EMP_ID,For_Date) L ON EL.Emp_ID=L.Emp_ID AND EL.For_Date=L.For_Date
				
			----PRINT ' STAGE 3.5 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)
			FETCH NEXT FROM curEmp INTO @Cur_Branch_ID
		END 
	CLOSE curEmp
	DEALLOCATE curEmp

	--PRINT ' STAGE 4 : ' + CONVERT(VARCHAR(20), GETDATE(), 114)
	UPDATE	EL
	SET		A_Days = A_Days - (P_Days + Leave_Days + W_Day + H_Day + Late_Days + Early_Days)
	FROM	#T0180_EMP_LOCKED_ATTENDANCE EL

	

	--INSERT INTO T0180_EMP_LOCKED_ATTENDANCE
	--SELECT * FROM #T0180_EMP_LOCKED_ATTENDANCE

	--select * from #T0190_EMP_LOCKED_LEAVE_DETAIL

	--INSERT INTO T0190_EMP_LOCKED_LEAVE_DETAIL
	--SELECT * FROM	#T0190_EMP_LOCKED_LEAVE_DETAIL


	/*
	CREATE TABLE #T0180_EMP_LOCKED_ATTENDANCE_ARREAR(
		[Emp_ID] [numeric](18, 0) NOT NULL,
		[Cmp_ID] [numeric](18, 0) NOT NULL,
		[For_Date] [datetime] NOT NULL,
		[Duration_In_Sec] [numeric](18, 0) NOT NULL,
		[Shift_ID] [int] NOT NULL,
		[P_Days] [numeric](5, 3) NOT NULL,
		[In_Time] [datetime] NULL,
		[Shift_Start_Time] [datetime] NULL,
		[Out_Time] [datetime] NULL,
		[Shift_End_Time] [datetime] NULL,
		[OT_Sec] [int] NOT NULL,
		[Weekoff_OT_Sec] [int] NOT NULL,
		[Holiday_OT_Sec] [int] NOT NULL,
		[GatePass_Deduct_Days] [numeric](5, 3) NULL,
		[Chk_By_Superior] [tinyint] NOT NULL,
		[Leave_Days] [numeric](5, 3) NOT NULL,
		[H_Day] [numeric](5, 3) NOT NULL,
		[W_Day] [numeric](5, 3) NOT NULL,
		[Is_Exempted] [bit] NOT NULL,
		[Late_Days] [numeric](5, 3) NOT NULL,
		[Early_Days] [numeric](5, 3) NOT NULL	
	)

	CREATE UNIQUE CLUSTERED INDEX IX_T0180_EMP_LOCKED_ATTENDANCE_ARREAR_TEMP ON #T0180_EMP_LOCKED_ATTENDANCE_ARREAR(EMP_ID,FOR_DATE)
	*/	

	/*The Following Column Names are Case Sensitive. If you change the case of field name then it would be affected in EmployeeAttendanceLock.js file too*/
	IF OBJECT_ID('tempdb..#tmp') is null
	SELECT	ELA.Emp_ID,Alpha_Emp_Code, Emp_Full_Name, BM.Branch_Name As Branch, DM.Dept_Name As [Department],DG.Desig_Name As [Designation],
			RIGHT(Convert(varchar(20), For_Date, 105), 7) As [Month],
			Sum(P_Days) As Present, Sum(H_Day) As Holiday, Sum(W_Day) As WeekOff, 
			Sum(ELA.Leave_Days) As PaidLeave, SUM(On_Duty) As On_Duty, SUM(A_Days) As Absent, Sum(ELA.Late_Days) As Late_Days, Sum(Early_Days) As Early_Days,
			(Sum(ELA.OT_Sec) / 3600) As OT_Hours, 0 As Sal_Cal_Days, 0 As Total_Days,
			'UnLocked' As [Status]
	FROM	#T0180_EMP_LOCKED_ATTENDANCE ELA 		
			INNER JOIN #Emp_Cons EC ON ELA.Emp_ID=EC.Emp_ID	
			INNER JOIN T0080_EMP_MASTER	E WITH (NOLOCK) ON ELA.Emp_ID=E.Emp_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID=EC.Increment_ID
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.Branch_ID=BM.Branch_ID
			INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_ID=DM.Dept_Id
			INNER JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON I.Desig_Id=DG.Desig_Id
	GROUP	BY ELA.Emp_ID,Alpha_Emp_Code, Emp_Full_Name, BM.Branch_Name, DM.Dept_Name,DG.Desig_Name, RIGHT(Convert(varchar(20), For_Date, 105), 7)

