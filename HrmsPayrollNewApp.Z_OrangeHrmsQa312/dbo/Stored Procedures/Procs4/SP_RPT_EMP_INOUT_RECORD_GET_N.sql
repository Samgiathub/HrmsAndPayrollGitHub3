CREATE PROCEDURE [dbo].[SP_RPT_EMP_INOUT_RECORD_GET_N] 
	@Cmp_ID   numeric,      
	@From_Date  DATETIME,      
	@To_Date  DATETIME ,      
	@Branch_ID  numeric   ,      
	@Cat_ID   numeric  ,      
	@Grd_ID   numeric ,      
	@Type_ID  numeric ,      
	@Dept_ID  numeric  ,      
	@Desig_ID  numeric ,      
	@Emp_ID   numeric  ,      
	@Constraint  VARCHAR(max) = '',      
	@Report_call VARCHAR(50) = 'IN-OUT',      
	@Weekoff_Entry VARCHAR(1) = 'Y',  
	@PBranch_ID VARCHAR(max) = '0' ,
	@InOut_Tag VARCHAR(200) = '0' ,  -- Added by nilesh on 22122014 For Rotation AttENDance Dashboard 
	@Order_By	varchar(30) = 'Code' --Added by Jaina 31-Jul-2015 (To sort by Code/Name/Enroll No)      

AS      
  	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON    
    SET	ANSI_WARNINGS OFF;
    
	   
       
	IF @Branch_ID = 0      
		SET @Branch_ID = null      
	IF @Cat_ID = 0      
		SET @Cat_ID  = null      
	    
	IF @Type_ID = 0      
		SET @Type_ID = null      
	IF @Dept_ID = 0      
		SET @Dept_ID = null      
	IF @Grd_ID = 0      
		SET @Grd_ID = null      
	IF @Emp_ID = 0      
		SET @Emp_ID = null      
	IF @Desig_ID =0      
		SET @Desig_ID = null      
	   

	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)      
	-- Ankit 08092014 for Same Date Increment
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2,@PBranch_ID 



	-- Added by rohit For Leave Name Showing With Leave Code in Footer on 08082013
	DECLARE @leave_Footer VARCHAR(5000)
	SET @leave_Footer = ''

	SELECT  @leave_Footer = STUFF((SELECT ' ' + s.Leave_name FROM 
	( SELECT ('  ' + Leave_Code + ' : ' + Leave_name + ' ' ) AS leave_name,Cmp_ID FROM T0040_LEAVE_MASTER WITH (NOLOCK)
	)
	s WHERE s.Cmp_id = t.Cmp_id FOR XML PATH('')),1,1,'')  FROM T0040_LEAVE_MASTER AS t WITH (NOLOCK) WHERE t.Cmp_ID=@cmp_id GROUP BY t.Cmp_id

 --SELECT @leave_Footer
 
 -- ENDed by rohit on 08082013

 -- Added by rohit for monthly Auto Generate mail For muni seva Ashram on 24092013       
	IF @Report_call <> 'Monthly Generate'
	BEGIN   
		IF  object_id('tempdb..#Emp_Inout') IS NOT NULL --exists (SELECT 1 FROM [tempdb].dbo.sysobjects WHERE name like '#Emp_Inout' )        
			BEGIN      
				drop table #Emp_Inout  
			END  
	       
		   
			CREATE table #Emp_Inout       
			(      
				emp_id     numeric ,      
				for_Date    DATETIME,      
				Dept_id    numeric null ,      
				Grd_ID    numeric null,      
				Type_ID   numeric null,      
				Desig_ID    numeric null,      
				Shift_ID    numeric null ,      
				In_Time    DATETIME null,      
				Out_Time    DATETIME null,      
				Duration    VARCHAR(20) null,      
				Duration_sec   numeric  null,      
				Late_In    VARCHAR(20) null,      
				Late_Out    VARCHAR(20) null,      
				Early_In    VARCHAR(20) null,      
				Early_Out    VARCHAR(20) null,      
				Leave     VARCHAR(5) null,      
				Shift_Sec    numeric null,      
				Shift_Dur    VARCHAR(20) null,      
				Total_work    VARCHAR(20) null,      
				Less_Work    VARCHAR(20) null,      
				More_Work    VARCHAR(20) null,      
				Reason     VARCHAR(200) null, 
				Other_Reason VARCHAR(300) null, --Added By Jaina 12-09-2015        
				AB_LEAVE    VARCHAR(Max) NULL,      
				Late_In_Sec   numeric null,      
				Late_In_count   numeric null,      
				Early_Out_sec   numeric null,      
				Early_Out_Count  numeric null,      
				Total_Less_work_Sec numeric null,      
				Shift_St_Datetime  DATETIME null,      
				Shift_en_Datetime  DATETIME null,      
				Working_Sec_AfterShift numeric null,      
				Working_AfterShift_Count numeric null ,      
				Leave_Reason   VARCHAR(250) null,      
				Inout_Reason   VARCHAR(250) null,  
				SysDate  DATETIME   ,  
				Total_Work_Sec numeric Null,  
				Late_Out_Sec   numeric null,  
				Early_In_sec   numeric null,
				Total_More_work_Sec numeric null,
				Is_OT_Applicable TINYINT null,
				Monthly_Deficit_Adjust_OT_Hrs TINYINT null,
				Late_Comm_sec  numeric null,
				Branch_Id Numeric default 0,
				P_days	numeric(5,2) default 0,
				vertical_Id numeric default 0,  --added jimit 15062016
				subvertical_Id numeric default 0,  --added jimit 15062016
				Leave_FromDate	Datetime null, --add by chetan 250517
				Leave_ToDate	Datetime null, --add by chetan 250517  
				Break_Start_Time	Datetime null,--added by chetan 07102017
				Break_End_Time	Datetime null, --added by chetan 07102017
				Break_Duration	VARCHAR(10) null --added by chetan 07102017
			)      
		END
  
	DECLARE @bHW_Exec_Req BIT;
	SET @bHW_Exec_Req = 0;

	DECLARE @p_Days AS NUMERIC(18,2)  
	SET @p_Days = 0
	
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
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
			) --Added by Sumit on 10112016
		END	
	
	--Added by Nimesh on 14-Dec-2015 (For new Holiday/Weekoff SP execution)
	IF OBJECT_ID('tempdb..#Emp_Holiday') IS NULL
		BEGIN			
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half TINYINT, Is_P_Comp TINYINT, H_DAY numeric(3,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @bHW_Exec_Req = 1;
		END
	 
	 IF object_ID('tempdb..#EMP_HW_CONS') IS NULL
		 BEGIN
			CREATE TABLE #EMP_HW_CONS
			(
				Emp_ID				NUMERIC,
				WeekOffDate			Varchar(Max),
				WeekOffCount		NUMERIC(3,1),
				CancelWeekOff		Varchar(Max),
				CancelWeekOffCount	NUMERIC(3,1),
				HolidayDate			Varchar(MAX),
				HolidayCount		NUMERIC(3,1),
				HalfHolidayDate		Varchar(MAX),
				HalfHolidayCount	NUMERIC(3,1),
				CancelHoliday		Varchar(Max),
				CancelHolidayCount	NUMERIC(3,1)
			)
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
			SET @bHW_Exec_Req = 1;
		 END
	 
	 IF @bHW_Exec_Req = 1
		 BEGIN
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW=0
		 END
	 
	CREATE TABLE #EMP_GEN_SETTINGS
	(
		EMP_ID		NUMERIC PRIMARY KEY,
		BRANCH_ID	NUMERIC,
		First_In_Last_Out_For_InOut_Calculation TINYINT,
		Chk_otLimit_before_after_Shift_time	TINYINT
	) 
	-- Added by nilesh on 22122014 For Rotation AttENDance Dashboard --Start
	IF @InOut_Tag = 'D' 
		UPDATE #EMP_GEN_SETTINGS SET First_In_Last_Out_For_InOut_Calculation = 1
	-- Added by nilesh on 22122014 For Rotation AttENDance Dashboard --END

	IF @Report_call ='Inout_Page' --added by Hardik 13/10/2012 for In Out Record Page
		UPDATE #EMP_GEN_SETTINGS SET First_In_Last_Out_For_InOut_Calculation = 0

	IF @Report_call ='Time_Loss' --Added By Ramiz AS Time Loss is only Useful when First In Last Out is Not ticked
		UPDATE #EMP_GEN_SETTINGS SET First_In_Last_Out_For_InOut_Calculation = 0
						
	IF @Report_call ='Time_Card'--added by chetan 07102017 for time card report 
		UPDATE #EMP_GEN_SETTINGS SET First_In_Last_Out_For_InOut_Calculation = 1
	

	CREATE TABLE #Data         
	(         
		Emp_Id   numeric ,         
		For_date DATETIME,        
		Duration_in_sec numeric,        
		Shift_ID numeric ,        
		Shift_Type numeric ,        
		Emp_OT  numeric ,        
		Emp_OT_min_Limit numeric,        
		Emp_OT_max_Limit numeric,        
		P_days  numeric(12,3) default 0,        
		OT_Sec  numeric default 0  ,
		In_Time DATETIME,
		Shift_Start_Time DATETIME,
		OT_Start_Time numeric default 0,
		Shift_Change TINYINT default 0,
		Flag int default 0,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time DATETIME,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
		Working_Hrs_END_Time TINYINT default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    
	--added by chetan 07102017
	DECLARE @Is_Auto_Inout AS INT
	SET @Is_Auto_Inout  = 1
	IF @Report_Call='Time_Card'
		BEGIN    
			EXEC P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE, @Is_Auto_Inout
		END
	ELSE
		BEGIN
			EXEC P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE
		END
		
		  

	IF @Report_call = 'Time_Card'
	   	BEGIN
	   		IF  object_id('tempdb..#TMP_BREAK') IS NOT NULL 
				BEGIN      
					drop table #TMP_BREAK  
				END  
			
			SELECT	ROW_NUMBER() OVER(PARTITION BY EIO1.Emp_ID ORDER BY EIO1.FOR_DATE,ISNULL(EIO1.IN_TIME, EIO1.OUT_TIME)) AS ROW_ID, EIO1.Emp_ID,EIO1.For_Date,EIO1.In_Time,EIO1.Out_Time 
			INTO	#EIO
			FROM	T0150_EMP_INOUT_RECORD EIO1 WITH (NOLOCK)
					INNER JOIN #Emp_Cons Ec ON EIO1.Emp_Id = ec.Emp_ID
					INNER JOIN #Data D ON EIO1.In_Time BETWEEN D.In_Time AND D.OUT_Time AND EIO1.Emp_ID=D.Emp_Id
			WHERE	--EIO1.Emp_ID = @curEmp_ID
					EIO1.cmp_Id= @Cmp_ID  and EIO1.for_Date >=@From_Date and EIO1.For_Date <=@To_Date 


			;WITH Q(ROW_ID,Emp_ID,For_Date,In_Time,Out_Time,LVL, DIFF,DiffSe,Pre_Out_Time) AS
			(
				SELECT	ROW_ID, EIO1.Emp_ID,For_Date,In_Time,Out_Time, 'U' AS LVL, CAST(NULL AS DATETIME) AS DIFF ,CAST(0 AS INT) AS DiffSe, CAST(NULL As DateTime) As Pre_Out_Time
				FROM	#EIO EIO1
				WHERE	ROW_ID=1
				UNION ALL
				SELECT	EIO2.ROW_ID,EIO2.Emp_ID,EIO2.For_Date,EIO2.In_Time,EIO2.Out_Time,'D' AS LVL,Q.Out_Time ,CAST(DATEDIFF(S,Q.out_Time,EIO2.In_Time) AS INT) AS DiffSe --CAST(EIO2.In_Time - Q.Out_Time AS DATETIME) AS DIFF
						,Q.Out_Time As Pre_Out_Time
				FROM	#EIO EIO2 INNER JOIN Q ON EIO2.ROW_ID = (Q.ROW_ID + 1) AND Q.Emp_ID=EIO2.Emp_ID
			) 
			SELECT ROW_ID,EMP_ID,FOR_DATE,PRE_OUT_TIME, IN_TIME, DiffSe 
			INTO	#TMP_BREAK
			FROM Q
			WHERE	DiffSe BETWEEN 300 AND 28800
	
		END
		

	
	CREATE TABLE #IN_OUT
	(
		EMP_ID			NUMERIC,
		FOR_DATE		DATETIME,
		IN_TIME			DATETIME,
		OUT_TIME		DATETIME,
		REASON			VARCHAR(250),
		OTHER_REASON	VARCHAR(250),

		Shift_ID		INT,
		Shift_St_Time	DATETIME,
		Shift_End_Time	DATETIME,
		Working_Sec		INT DEFAULT 0,
		Actual_W_Sec	INT DEFAULT 0,
		Early_In_Sec	INT DEFAULT 0,
		Late_In_Sec		INT DEFAULT 0,
		Early_Out_Sec	INT DEFAULT 0,
		Late_Out_Sec	INT DEFAULT 0,
		Shift_Sec		INT DEFAULT 0,
		Diff_Sec		INT DEFAULT 0
	)
	CREATE CLUSTERED INDEX IX_IN_OUT ON #IN_OUT(EMP_ID,FOR_DATE,IN_TIME) 
	
	
	
	INSERT	INTO #IN_OUT (EMP_ID,FOR_DATE,IN_TIME,OUT_TIME,REASON,OTHER_REASON)
	SELECT	D.EMP_ID,FOR_DATE,IN_TIME,OUT_TIME,REASON,OTHER_REASON 						
	FROM	#DATA D 
			INNER JOIN #EMP_GEN_SETTINGS G ON D.EMP_ID=G.EMP_ID
			LEFT OUTER JOIN (SELECT MAX(REASON) AS REASON, MAX(OTHER_REASON) AS OTHER_REASON, T.EMP_ID 
							FROM	T0150_EMP_INOUT_RECORD T WITH (NOLOCK)
									INNER JOIN #Emp_Cons E ON T.Emp_ID=E.EMP_ID
							WHERE	T.For_Date BETWEEN @From_Date AND @To_Date
							GROUP BY T.EMP_ID) T ON D.EMP_ID=T.EMP_ID							
	WHERE	First_In_Last_Out_For_InOut_Calculation = 1
	ORDER BY ISNULL(IN_TIME,OUT_TIME),OUT_TIME,REASON
	
	INSERT	INTO #IN_OUT (EMP_ID,FOR_DATE,IN_TIME,OUT_TIME,REASON,OTHER_REASON)
	SELECT	EIR.EMP_ID,EIR.FOR_DATE,EIR.IN_TIME,EIR.OUT_TIME,REASON,OTHER_REASON 						
	FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
			INNER JOIN 	#DATA D ON ISNULL(EIR.IN_TIME,EIR.OUT_TIME) >= ISNULL(D.IN_TIME,D.OUT_TIME) AND ISNULL(EIR.OUT_TIME,EIR.IN_TIME) <= ISNULL(D.OUT_TIME,D.IN_TIME) AND D.EMP_ID=EIR.EMP_ID		
			INNER JOIN #EMP_GEN_SETTINGS G ON D.EMP_ID=G.EMP_ID
	WHERE	First_In_Last_Out_For_InOut_Calculation = 0
	ORDER BY ISNULL(EIR.IN_TIME,EIR.OUT_TIME),EIR.OUT_TIME,REASON

	
	/*UPDATING SHIFT ID*/
	UPDATE	D
	SET		Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,D.Emp_Id,D.For_date)
	FROM	#Data D
	UPDATE	D
	SET		Shift_Start_Time =  For_date + CASE WHEN SM.Is_Half_Day=1 AND SM.Week_Day=DATENAME(WEEKDAY, d.For_date) THEN SM.Half_St_Time ELSE  SM.Shift_St_Time END,
			Shift_END_Time= (For_date + CASE WHEN SM.Shift_St_Time > SM.Shift_End_Time THEN 1 ELSE 0 END) + CASE WHEN SM.Is_Half_Day=1 AND SM.Week_Day=DATENAME(WEEKDAY, d.For_date) THEN SM.Half_End_Time ELSE SM.Shift_End_Time END
	FROM	#Data D
			INNER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID=SM.Shift_ID

	

	
	UPDATE	I
	SET		Working_Sec		= dbo.F_Return_Without_Sec(ISNULL(DATEDIFF(s,I.IN_TIME,I.OUT_TIME),0)),	--Removed seconds ie. Working_Sec =  130 after Rounding Working_Sec = 120 = 2 min
			Early_In_Sec	= CASE	WHEN DATEDIFF(s,I.IN_TIME,D.Shift_Start_Time) > 0 THEN DATEDIFF(s,I.IN_TIME,D.Shift_Start_Time)  ELSE 0 END,
			Late_In_Sec		= CASE	WHEN DATEDIFF(s,I.IN_TIME,Shift_Start_Time) < 0 THEN DATEDIFF(s,Shift_Start_Time,I.IN_TIME) ELSE 0 END,
			Early_Out_Sec	= CASE	WHEN DATEDIFF(s,I.OUT_TIME,D.Shift_END_Time) > 0 THEN DATEDIFF(s,I.OUT_TIME,D.Shift_END_Time) ELSE 0 END,
			Late_Out_Sec	= CASE	WHEN DATEDIFF(s,I.OUT_TIME,D.Shift_END_Time) < 0 THEN DATEDIFF(s,D.Shift_END_Time,I.OUT_TIME) ELSE 0 END,
			Shift_ID		= D.Shift_ID,
			Shift_St_Time	= D.Shift_Start_Time,
			Shift_End_Time	= D.Shift_END_Time
	FROM	#IN_OUT I
			INNER JOIN #DATA D ON I.FOR_DATE=D.FOR_DATE AND I.FOR_DATE=D.FOR_DATE

	--add by chetan 250517
	IF @Report_call='Employee Wise Latemark'
		BEGIN
			UPDATE	IOUT
			SET		Late_In_Sec	= Late_In_Sec - dbo.F_Return_Sec(Emp_Late_Limit)
			FROM	#IN_OUT IOUT
					INNER JOIN #Emp_Cons E ON IOUT.EMP_ID=E.Emp_ID
					INNER JOIN T0095_INCREMENT I ON I.Increment_ID=E.Increment_ID
			Where	dbo.F_Return_Sec(Emp_Late_Limit) > 0 AND dbo.F_Return_Sec(Emp_Late_Limit) < Late_In_Sec
					AND Late_In_Sec > 0			
		END  
		
	/*Getting Actual Working Seconds*/
	UPDATE	I
	SET		Actual_W_Sec	= Working_Sec,
			Shift_Sec		= DATEDIFF(s, Shift_St_Time, Shift_End_Time)
	FROM	#IN_OUT I
			INNER JOIN T0050_SHIFT_DETAIL SD ON I.Shift_ID=SD.Shift_ID 
	WHERE	SD.OT_Start_Time = 1 AND IN_TIME < Shift_St_Time

	/*If Working hours should not be calculate before shift start*/
	UPDATE	I
	SET		Actual_W_Sec		= Actual_W_Sec - DATEDIFF(S,IN_TIME,Shift_St_Time)
	FROM	#IN_OUT I
			INNER JOIN T0050_SHIFT_DETAIL SD ON I.Shift_ID=SD.Shift_ID 
	WHERE	SD.OT_Start_Time = 1 AND IN_TIME < Shift_St_Time

	/*If Working hours should not be calculate after shift end*/
	UPDATE	I
	SET		Actual_W_Sec		= Actual_W_Sec - DATEDIFF(S,Shift_End_Time,OUT_TIME)
	FROM	#IN_OUT I
			INNER JOIN T0050_SHIFT_DETAIL SD ON I.Shift_ID=SD.Shift_ID 
	WHERE	SD.OT_End_Time = 1 AND Shift_End_Time < OUT_TIME
	

	--SELECT	TOP 0 IN_TIME,OUT_TIME,REASON,OTHER_REASON 
	--INTO	#IN_OUT
	--FROM	T0150_EMP_INOUT_RECORD 
	  
	--DECLARE @FOR_DATE DATETIME
	--SET @FOR_DATE = @From_Date
	--WHILE (@FOR_DATE <= @To_Date)
	--	BEGIN
			
			
	SELECT IOUT.*, D.Shift_Start_Time,D.Shift_END_Time FROM #IN_OUT IOUT INNER JOIN #DATA D ON IOUT.EMP_ID=D.Emp_Id AND IOUT.FOR_DATE=D.For_date
			
			
	--		SET @FOR_DATE  = DATEADD(D, 1, @FOR_DATE)
	--	END

	 
	IF @Report_call = 'IN-OUT' OR @Report_call = 'Inout_Page' OR @Report_call = 'Simsona'
		BEGIN 
			IF (@InOut_Tag = 'D') -- Added by nilesh on 22122014 For Rotation AttENDance Dashboard --Start 
				BEGIN
					SELECT E_IO.Late_In,E_IO.Early_Out,E_IO.emp_id
					FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
					dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
					dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
					dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
					dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
					E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
					E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
					T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID
					WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
					and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
					and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 
					Order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 		    
				END  -- Added by nilesh on 22122014 For Rotation AttENDance Dashboard --END
			ELSE
				BEGIN	
					IF @Report_call = 'Simsona'
						BEGIN
							SELECT  ROW_NUMBER() OVER(ORDER BY 
								CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
								WHEN @Order_By='Name' THEN E.Emp_Full_Name
								When @Order_By = 'Designation' then (CASE WHEN  Dm.Desig_dis_No  = 0 THEN DM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DM.Desig_dis_No AS VARCHAR), 21)   END)     --added jimit 25092015
								ELSE 
									Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
									 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
									 ELSE Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') END
							END) AS Sr_No,
							  E_IO.*,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
						   @From_Date AS P_From_date ,@To_Date AS P_To_Date  
						   ,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,
						   dbo.F_GET_AMPM (Shift_END_Time) AS Shift_END_Time,
						   
						   --- Modify Jignesh 23-Oct-2012 ( add 1 min IF Sec > 30 )
						   --dbo.F_GET_AMPM (In_Time) AS Actual_In_Time,
						   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time,  
						   --dbo.F_GET_AMPM (Out_Time) AS Actual_Out_Time , 
						   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time,  
						   
						   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date AS VARCHAR(11)) AS On_Date,
						   ,@leave_Footer AS Leave_Footer
						   --,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
						   ,Branch_Name
						   ,ISNULL(E_IO.ab_leave,'-') AS New_Ab_leave
						   ,BM.Comp_Name, BM.Branch_Address --Added by Nimesh 31-Jul-2015 (For Employee's Branch Address)
							,DM.Desig_Dis_No ---added jimit 24082015
				   FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
						   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
						   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
						   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
						   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
						   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
						   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
						   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID
				  WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
						  and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
						  and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 
							--Order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							--		WHEN @Order_By='Name' THEN E.Emp_Full_Name
							--		When @Order_By = 'Designation' then (CASE WHEN  Dm.Desig_dis_No  = 0 THEN DM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DM.Desig_dis_No AS VARCHAR), 21)   END)     --added jimit 25092015
							--		--ELSE RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
							--	END,Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
							--			 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
							--			 ELSE Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') END
								--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
							--Added by Jaina 31 July 2015 END					  
							RETURN
						END
					ELSE
						BEGIN	
								
							SELECT  ROW_NUMBER() OVER(ORDER BY 
										CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
										WHEN @Order_By='Name' THEN E.Emp_Full_Name
										When @Order_By = 'Designation' then (CASE WHEN  Dm.Desig_dis_No  = 0 THEN DM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DM.Desig_dis_No AS VARCHAR), 21)   END)     --added jimit 25092015
										ELSE 
											Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
											 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
											 ELSE Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') END
									END) AS Sr_No,
									  E_IO.*,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
								   @From_Date AS P_From_date ,@To_Date AS P_To_Date  
								   ,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,
								   (Case When E_IO.AB_LEAVE IN('HO','WO','OHO') THEN NULL ELSE dbo.F_GET_AMPM (Shift_END_Time) END) AS Shift_END_Time,
								   
								   --- Modify Jignesh 23-Oct-2012 ( add 1 min IF Sec > 30 )
								   --dbo.F_GET_AMPM (In_Time) AS Actual_In_Time,
								   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time,  
								   --dbo.F_GET_AMPM (Out_Time) AS Actual_Out_Time , 
								   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time,  
								   
								   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date AS VARCHAR(11)) AS On_Date,
								   ,@leave_Footer AS Leave_Footer
								   --,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
								   ,Branch_Name
								   ,BM.Comp_Name, BM.Branch_Address --Added by Nimesh 31-Jul-2015 (For Employee's Branch Address)
									,DM.Desig_Dis_No ---added jimit 24082015
									,vs.Vertical_Name,sv.SubVertical_Name --addee jimit 15062016
							FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
								   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
								   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
								   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
								   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
								   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
								   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
								   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID left outer join
								   T0040_Vertical_Segment vs WITH (NOLOCK) on E_Io.vertical_Id = vs.Vertical_ID left outer JOIN
								   T0050_SubVertical sv WITH (NOLOCK) on E_IO.subvertical_Id = sv.SubVertical_ID
							WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
								  and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
								  and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 

							return
						END 
				END
		END      
	ELSE IF @Report_call = 'SUMMARY'      
		BEGIN 
	      
			SELECT * FROM       
			( SELECT E_IO.Emp_ID,E_IO.SysDate,Emp_full_Name,Alpha_Emp_Code,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name,
			SUM(Total_Work_Sec) - SUM(ISNULL(Total_More_work_Sec,0)) AS Total_Work_Sec, SUM(Shift_Sec) AS Shift_Sec,
			sum(Late_in_sec) AS Late_in_sec ,sum(Early_Out_sec) AS Early_Out_sec, sum(Total_Less_Work_sec) AS Total_Less_Work_sec,
			sum(Total_More_Work_sec) AS Total_More_Work_sec,
			sum(Late_In_Count) AS Late_In_Count,sum(Early_Out_Count) AS Early_Out_Count      
			,sum(Working_sec_afterShift) AS Working_sec_afterShift,
			sum(Working_afterShift_count) AS Working_afterShift_count     
			, dbo.F_Return_Hours(sum(Total_Work_Sec)- SUM(ISNULL(Total_More_work_Sec,0))) AS Total_Work_Hours       
			, dbo.F_Return_Hours(sum(Shift_Sec)) AS Shift_Hours       
			, dbo.F_Return_Hours(sum(late_in_sec)) AS Late_in_Hours       
			, dbo.F_Return_Hours(sum(Early_Out_sec)) AS Early_Out_Hours       
			, dbo.F_Return_Hours(sum(Total_More_work_Sec)) AS Total_More_Work_Hours       
			, dbo.F_Return_Hours(sum(Total_Less_Work_sec)) AS Total_Less_Work_Hours       
			, dbo.F_Return_Hours(sum(Working_Sec_AfterShift)) AS Working_AfterShift_Hours
			,COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = '-' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) AS Working_Days
			,Late_Comm_sec, (Late_Comm_sec/3600) AS Late_Grace_Hour
			,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
					0
				ELSE 				
					Case When Is_OT_Applicable = 1 Then
						SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
					ELSE 0 END
				END
			ELSE 
				Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) ELSE 0 END 
			END AS Actual_OT_Sec

			,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
					0
				ELSE 				
					Case When Is_OT_Applicable = 1 Then
						SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
					ELSE 0 END
				END
			ELSE 
				Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) ELSE 0 END 
			END) AS Actual_OT_Hour	

			,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec) Then
					Case When COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0) > Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec) Then
							0
						ELSE (Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec)) - (COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0))
					END
				ELSE 0 END
			ELSE 
				SUM(Total_Less_work_Sec)
			END AS Actual_Deficit_Sec

			,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0) Then
					Case When SUM(Total_More_work_Sec) > Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0) Then
							0
						ELSE (Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0)) - SUM(Total_More_work_Sec)
					END
				ELSE 0 END
			ELSE 
				SUM(Total_More_work_Sec)
			END) AS Actual_Deficit_Hour
				
			,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
			,CMP_NAME,CMP_ADDRESS      
			,@From_Date AS P_From_date ,@To_Date AS P_To_Date   
			,DM.Desig_Dis_No,E.Enroll_No   --added jimit 24082015   
			,bm.branch_Name    --added jimit 21072016
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
			dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID    Inner Join
			T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID  
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)      
			and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
			Group by E_IO.Emp_ID,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name      
			,CMP_NAME,CMP_ADDRESS, E_IO.Sysdate,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs ,Late_Comm_sec,Alpha_Emp_Code,Desig_Dis_No,E.Enroll_No,bm.branch_Name    
			)Qry      
			WHERE Qry.Late_In_Count > 0 OR Qry.Early_Out_Count > 0 OR Total_less_Work_sec > 0 OR Total_More_Work_sec > 0 --or Qry.Working_afterShift_count > 0      
	 END       
	ELSE IF @Report_call = 'SALARY'      
		BEGIN      
	 
			SELECT * Into ##Salary FROM       
			( SELECT E_IO.Emp_ID,E_IO.SysDate,Emp_full_Name,Alpha_Emp_Code,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name,
			SUM(Total_Work_Sec) AS Total_Work_Sec, SUM(Shift_Sec) AS Shift_Sec,
			sum(Late_in_sec) AS Late_in_sec ,sum(Early_Out_sec) AS Early_Out_sec, sum(Total_Less_Work_sec) AS Total_Less_Work_sec,
			sum(Total_More_Work_sec) AS Total_More_Work_sec,
			sum(Late_In_Count) AS Late_In_Count,sum(Early_Out_Count) AS Early_Out_Count      
			,sum(Working_sec_afterShift) AS Working_sec_afterShift,
			sum(Working_afterShift_count) AS Working_afterShift_count     
			, dbo.F_Return_Hours(sum(Total_Work_Sec)) AS Total_Work_Hours       
			, dbo.F_Return_Hours(sum(Shift_Sec)) AS Shift_Hours       
			, dbo.F_Return_Hours(sum(late_in_sec)) AS Late_in_Hours       
			, dbo.F_Return_Hours(sum(Early_Out_sec)) AS Early_Out_Hours       
			, dbo.F_Return_Hours(sum(Total_More_work_Sec)) AS Total_More_Work_Hours       
			, dbo.F_Return_Hours(sum(Total_Less_Work_sec)) AS Total_Less_Work_Hours       
			, dbo.F_Return_Hours(sum(Working_Sec_AfterShift)) AS Working_AfterShift_Hours
			,COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' OR AB_LEAVE = '-' Then Null ELSE 1 END) AS Working_Days
			,Late_Comm_sec, (Late_Comm_sec/3600) AS Late_Grace_Hour
			,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
					0
				ELSE 				
					Case When Is_OT_Applicable = 1 Then
						SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
					ELSE 0 END
				END
			ELSE 
				Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) ELSE 0 END 
			END AS Actual_OT_Sec

			,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
					0
				ELSE 				
					Case When Is_OT_Applicable = 1 Then
						SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
					ELSE 0 END
				END
			ELSE 
				Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) ELSE 0 END 
			END) AS Actual_OT_Hour	

			,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec) Then
					Case When COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0) > Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec) Then
							0
						ELSE (Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec)) - (COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0))
					END
				ELSE 0 END
			ELSE 
				SUM(Total_Less_work_Sec)
			END AS Actual_Deficit_Sec

			,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
				Case When Sum(Total_Less_work_Sec) > COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0) Then
					Case When SUM(Total_More_work_Sec) > Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0) Then
							0
						ELSE (Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' OR AB_LEAVE = 'HO' OR AB_LEAVE = 'OHO' Then Null ELSE 1 END) * ISNULL(Late_Comm_sec,0)) - SUM(Total_More_work_Sec)
					END
				ELSE 0 END
			ELSE 
				SUM(Total_More_work_Sec)
			END) AS Actual_Deficit_Hour
				
			,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
			,CMP_NAME,CMP_ADDRESS      
			,@From_Date AS P_From_date ,@To_Date AS P_To_Date         
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
			dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)      
			and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
			Group by E_IO.Emp_ID,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name      
			,CMP_NAME,CMP_ADDRESS, E_IO.Sysdate,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs ,Late_Comm_sec,Alpha_Emp_Code     
			)Qry      
			WHERE Qry.Late_In_Count > 0 OR Qry.Early_Out_Count > 0 OR Total_less_Work_sec > 0 OR Total_More_Work_sec > 0 --or Qry.Working_afterShift_count > 0      
		END       
	ELSE IF @Report_call = 'OFF SHIFT'      
		BEGIN      
			SELECT E_IO.*,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS      
			,@From_Date AS P_From_date ,@To_Date AS P_To_Date         
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id  inner join      
			dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id Left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)      
			and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
			and Working_afterShift_count > 0       
		END    
	ELSE IF @Report_call = 'Shift_END' 
		BEGIN      	   
			Update #Emp_Inout SET Shift_St_Datetime = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) AS DATETIME)  FROM #Emp_Inout
			Update #Emp_Inout SET Shift_en_Datetime   = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) AS DATETIME)  FROM #Emp_Inout	
		  
			   
			SELECT 
			--E_IO.*,
			E_IO.emp_id,E_IO.for_Date,E_IO.Dept_id,E_IO.Grd_ID,E_IO.Type_ID,E_IO.Desig_ID,E_IO.Shift_ID,
			E_IO.In_Time,case when E_IO.Out_Time >  Shift_en_Datetime  then Shift_en_Datetime ELSE E_IO.Out_Time END AS  Out_Time
			,E_IO.Duration,
			E_IO.Duration_sec
			,E_IO.Late_In,
			case when E_IO.Out_Time >  Shift_en_Datetime  then '' ELSE E_IO.Late_Out END AS Late_Out ,
			E_IO.Early_In,E_IO.Early_Out,
			E_IO.Leave,
			E_IO.Shift_Sec,
			E_IO.Shift_Dur,
			case when E_IO.Out_Time >  Shift_en_Datetime then DBO.F_Return_Hours(DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime)) ELSE E_IO.Total_work END AS Total_work ,
			--E_IO.Less_Work
			--,E_IO.More_Work
			case when E_IO.Out_Time >  Shift_en_Datetime then CAST( DBO.F_Return_Hours(case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 ELSE ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) END)  AS varchar) ELSE E_IO.Less_Work END AS Less_Work
			, case when E_IO.Out_Time >  Shift_en_Datetime then CAST( DBO.F_Return_Hours(case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 ELSE ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) END)  AS varchar) ELSE E_IO.More_Work END AS More_Work
			,Reason,
			E_IO.AB_LEAVE,E_IO.Late_In_Sec,E_IO.Late_In_count,E_IO.Early_Out_sec,E_IO.Early_Out_Count,
			--E_IO.Total_Less_work_Sec,
			case when E_IO.Out_Time >  Shift_en_Datetime then (case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 ELSE ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) END)   ELSE E_IO.Total_Less_work_Sec END AS Total_Less_work_Sec,

			E_IO.Shift_St_Datetime,E_IO.Shift_en_Datetime,
			E_IO.Working_Sec_AfterShift,E_IO.Working_AfterShift_Count,E_IO.Leave_Reason,E_IO.Inout_Reason,
			E_IO.SysDate,
			case when E_IO.Out_Time >  Shift_en_Datetime then DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ELSE  E_IO.Total_Work_Sec END AS Total_Work_Sec,
			0 AS Late_Out_Sec,
			E_IO.Early_In_sec
			-- ,E_IO.Total_More_work_Sec,
			, case when E_IO.Out_Time >  Shift_en_Datetime then (case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 ELSE ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) END)  ELSE E_IO.Total_More_work_Sec END AS Total_More_work_Sec
			,E_IO.Is_OT_Applicable,E_IO.Monthly_Deficit_Adjust_OT_Hrs,E_IO.Late_Comm_sec
			,E_IO.P_days
			,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
			@From_Date AS P_From_date ,@To_Date AS P_To_Date  
			,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,
			dbo.F_GET_AMPM (Shift_END_Time) AS Shift_END_Time,

			--- Modify Jignesh 23-Oct-2012 ( add 1 min IF Sec > 30 )
			--dbo.F_GET_AMPM (In_Time) AS Actual_In_Time,
			dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time,  
			--dbo.F_GET_AMPM (Out_Time) AS Actual_Out_Time , 
			dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time,  

			convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date AS VARCHAR(11)) AS On_Date,
			,@leave_Footer AS Leave_Footer,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
			,DM.Desig_Dis_No       --added jimit 01092015
			,BM.Branch_Name			--added jimit 29072015
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
			dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID  
			Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) On BM.Branch_ID = E_IO.Branch_ID    
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
			and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
			and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 
			-- Order by 
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						ELSE e.Alpha_Emp_Code
					END
	--e.Emp_code
		 --RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		END	
	ELSE IF @Report_call = 'SUMMARY1'      
		BEGIN      
			SELECT * FROM       
			( SELECT E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,sum(Shift_Sec) AS Total_Work_sec, 
			CAST(Replace(dbo.F_Return_Hours(Total_Work_Sec_new - Required_Hrs_Till_date),':','.') AS NUMERIC(18,2)) AS Total_Work_Hours,
			Required_Hrs_Till_date, CAST(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date),':','.') AS NUMERIC(18,2)) AS Total_Required_Hours_Till_Date,
			Dur_Sec  AS Achieved_Sec,CAST(Replace(dbo.F_Return_Hours(Dur_Sec ),':','.') AS NUMERIC(18,2)) AS Achieved_Hours
			,Required_Hrs_Till_date - Dur_Sec AS Short_Sec, 
			 CAST(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date - Dur_Sec),':','.')AS NUMERIC(18,2)) AS Short_Hours,
			Sum(Total_More_Work_sec) AS Total_More_Work_sec
			, CAST(Replace(dbo.F_Return_Hours(sum(Total_More_work_Sec) ),':','.') AS NUMERIC(18,2)) AS Total_More_Work_Hours
			,@From_Date AS P_From_date ,@To_Date AS P_To_Date         

			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
			dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Left Outer Join
			(SELECT Emp_Id,ISNULL(SUM(Shift_Sec),0) AS Required_Hrs_Till_date From
			(SELECT Distinct Emp_id, ISNULL((Shift_Sec),0) AS Shift_Sec, For_Date 
				FROM #Emp_Inout 
				WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date AS VARCHAR(11)) AS smalldatetime)      
				and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(GETDATE()  AS VARCHAR(11)) AS smalldatetime)       
				And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'OHO') OR AB_LEAVE IS NULL)As Qry1 Group by Emp_id) AS Qry4 
			on E_IO.emp_id = Qry4.emp_id Left Outer Join
			(SELECT Emp_id, ISNULL(SUM(Duration_sec),0) AS Dur_Sec 
				FROM #Emp_Inout 
				WHERE (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'OHO') OR AB_LEAVE IS NULL Group by Emp_id) Qry2 on E_IO.emp_id = Qry2.emp_id
			Left Outer Join
			(SELECT Emp_id, ISNULL(SUM(Shift_Sec),0) AS Total_Work_Sec_new
				FROM #Emp_Inout 
				WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date AS VARCHAR(11)) AS smalldatetime)      
				and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
				And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'OHO') OR AB_LEAVE IS NULL Group by Emp_id) Qry3 
			on E_IO.emp_id = Qry3.emp_id 
				
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)      
			and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
			Group by E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Required_Hrs_Till_date,Dur_Sec ,Total_Work_Sec_new            
			)Qry      
		END  
	-------------Below Portion is Added By Ramiz on 29/09/2015 for Time Loss Report , It is Generated FROM In-Out Summary Form  ------------------
	ELSE IF @Report_call = 'Time_Loss'      
		BEGIN

			UPDATE	#Emp_Inout
			SET		Shift_St_Datetime = q.Shift_St_Time,			
					Shift_en_Datetime = q.Shift_END_Time
			FROM	#Emp_Inout d INNER JOIN 
						(
							SELECT	ST.Shift_st_time,ST.Shift_ID,ISNULL(SD.OT_Start_Time,0) AS OT_Start_Time,
									ST.Shift_END_Time ,ISNULL(SD.OT_END_Time,0) AS OT_END_Time,
									Sd.Working_Hrs_St_Time,sd.Working_Hrs_END_Time
							FROM	dbo.t0040_shift_master ST WITH (NOLOCK) LEFT OUTER JOIN dbo.t0050_shift_detail SD 
									ON ST.Shift_ID=SD.Shift_ID 
							WHERE St.Cmp_ID = @Cmp_ID
						) q ON d.shift_id=q.shift_id


			Update #Emp_Inout SET Shift_St_Datetime = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) AS DATETIME)  FROM #Emp_Inout
			Update #Emp_Inout SET Shift_en_Datetime   = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) AS DATETIME)  FROM #Emp_Inout	

			Update #Emp_Inout 
			SET OUT_Time = case when OUT_Time > Shift_en_Datetime then Shift_en_Datetime ELSE OUT_Time END 
			FROM #Emp_Inout t
		
			Update #Emp_Inout 
			SET In_Time = case  when In_Time < Shift_St_Datetime then Shift_St_Datetime ELSE In_Time END  
			FROM #Emp_Inout t

			Update #Emp_Inout 
			SET In_Time = case  when In_Time > Shift_en_Datetime and OUT_Time = Shift_en_Datetime then Shift_en_Datetime ELSE In_Time END  
			FROM #Emp_Inout t 
			
			--Update #Emp_Inout
			--SET Shift_Sec = (Shift_Sec/2), In_Time = case when In_Time < (SELECT Shift_en_Datetime - dbo.F_Return_Hours(Shift_Sec/2) FROM #Emp_Inout WHERE AB_LEAVE like '%Half%') then (SELECT Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2)  FROM #Emp_Inout WHERE AB_LEAVE like '%Half%') ELSE In_Time END 
			--FROM #Emp_Inout t WHERE AB_LEAVE like '%First Half%'
				
			--Update #Emp_Inout
			--SET Shift_Sec = (Shift_Sec/2), Out_Time = case when OUT_Time > (SELECT Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2)  FROM #Emp_Inout WHERE AB_LEAVE like '%Half%') then (SELECT Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2)  FROM #Emp_Inout WHERE AB_LEAVE like '%Half%') ELSE OUT_Time END 
			--FROM #Emp_Inout t WHERE AB_LEAVE like '%Second Half%'
			
			Update #Emp_Inout
			SET Shift_Sec = (Shift_Sec/2),
			In_Time = case when In_Time < Shift_en_Datetime - dbo.F_Return_Hours(Shift_Sec/2)then
			Shift_en_Datetime - dbo.F_Return_Hours(Shift_Sec/2) ELSE In_Time END
			FROM #Emp_Inout t WHERE AB_LEAVE like '%First Half - 0.50%'

			Update #Emp_Inout
			SET Shift_Sec = (Shift_Sec/2),
			Out_Time = case when OUT_Time >Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2) then
			Shift_St_Datetime + dbo.F_Return_Hours(Shift_Sec/2) ELSE OUT_Time END
			FROM #Emp_Inout t WHERE AB_LEAVE like '%Second Half - 0.50%'

			Update #Emp_Inout
			SET Duration_sec = ISNULL(DATEDIFF(s,t.in_time,t.out_time),0)
			FROM #Emp_Inout t
			
			Update #Emp_Inout
			SET Duration = CAST(Replace(dbo.F_Return_Hours(Duration_sec ),':','.') AS NUMERIC(18,2))
			FROM #Emp_Inout t


			SELECT * FROM       
		   ( SELECT E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Total_Work_Sec_new, 
		   CAST(Replace(dbo.F_Return_Hours(Total_Work_Sec_new - Required_Hrs_Till_date),':','.') AS NUMERIC(18,2)) AS Total_Work_Hours,
			Required_Hrs_Till_date, CAST(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date),':','.') AS NUMERIC(18,2)) AS Total_Required_Hours_Till_Date,
			Dur_Sec  AS Achieved_Sec,CAST(Replace(dbo.F_Return_Hours(Dur_Sec ),':','.') AS NUMERIC(18,2)) AS Achieved_Hours
			,Required_Hrs_Till_date - Dur_Sec AS Short_Sec, 
			 CAST(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date - Dur_Sec),':','.')AS NUMERIC(18,2)) AS Short_Hours,
			Sum(Total_More_Work_sec) AS Total_More_Work_sec
			, CAST(Replace(dbo.F_Return_Hours(sum(Total_More_work_Sec) ),':','.') AS NUMERIC(18,2)) AS Total_More_Work_Hours
			,cm.Cmp_Name AS Cmp_Name , cm.Cmp_Address AS Cmp_Address
			,GRM.Grd_Name , et.Type_Name , DPM.Dept_Name , DM.Desig_Name
			,@From_Date AS P_From_date ,@To_Date AS P_To_Date
			,bm.Branch_Name   --added jimit 21072016
			   FROM #Emp_Inout AS E_IO 
			   inner join dbo.T0080_EMP_MASTER E		 WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id 
			   inner join dbo.T0040_SHIFT_MASTER SM		 WITH (NOLOCK) on SM.Shift_ID = E_IO.Shift_ID 
			   inner join dbo.T0040_GRADE_MASTER GRM	 WITH (NOLOCK) on GRM.Grd_ID = E_IO.Grd_ID  
			   left join dbo.T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) on DPM.Dept_id = E_IO.dept_id 
			   left outer join dbo.T0040_TYPE_MASTER Et  WITH (NOLOCK) on E_IO.Type_ID = Et.Type_ID 
			   left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on E_IO.Desig_ID = DM.Desig_ID  
			   inner join dbo.T0010_COMPANY_MASTER CM	 WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID 
			   Left Outer Join
					(SELECT Emp_Id,ISNULL(SUM(Shift_Sec),0) AS Required_Hrs_Till_date From
					(SELECT Distinct Emp_id, ISNULL((Shift_Sec),0) AS Shift_Sec, For_Date 
					FROM #Emp_Inout 
					WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date AS VARCHAR(11)) AS smalldatetime)      
					and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(GETDATE()  AS VARCHAR(11)) AS smalldatetime)       
					And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'OHO' AND AB_LEAVE <> 'AB' and AB_LEAVE not like '%Full day%') OR AB_LEAVE IS NULL)As Qry1 Group by Emp_id) AS Qry4 
					on E_IO.emp_id = Qry4.emp_id 
				Left Outer Join
					(SELECT Emp_id, ISNULL(SUM(Duration_sec),0) AS Dur_Sec 
					FROM #Emp_Inout 
					WHERE (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'OHO' AND AB_LEAVE <> 'AB' and  AB_LEAVE not like '%Full day%') OR AB_LEAVE IS NULL Group by Emp_id) Qry2 on E_IO.emp_id = Qry2.emp_id
				Left Outer Join
					(SELECT Emp_id, ISNULL(SUM(Shift_Sec),0) AS Total_Work_Sec_new
					FROM #Emp_Inout 
					WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date AS VARCHAR(11)) AS smalldatetime)      
					and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
					And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO' AND AB_LEAVE <> 'OHO' AND AB_LEAVE <> 'AB' and  AB_LEAVE not like '%Full day%') OR AB_LEAVE IS NULL Group by Emp_id) Qry3 
					on E_IO.emp_id = Qry3.emp_id 
				Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) On BM.Branch_ID = E_IO.Branch_ID
				   WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)      
					and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)       
				   Group by E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Required_Hrs_Till_date,Dur_Sec ,Total_Work_Sec_new , Cmp_Name , Cmp_Address   ,GRM.Grd_Name , et.Type_Name , DPM.Dept_Name , DM.Desig_Name,branch_Name
				   )Qry
		END
		-- Added by rohit on 04012015
	ELSE IF @Report_call = 'Inout_Mail'      
		BEGIN
			SELECT 
				  --E_IO.*
				  E_IO.emp_id,E_IO.for_Date,E_IO.Dept_id,E_IO.Grd_ID,E_IO.Type_ID,E_IO.Desig_ID,E_IO.Shift_ID,E_IO.In_Time,E_IO.Out_Time,E_IO.Duration,E_IO.Duration_sec,E_IO.Late_In,E_IO.Late_Out,E_IO.Early_In,E_IO.Early_Out,E_IO.Leave,E_IO.Shift_Sec,E_IO.Shift_Dur,E_IO.Total_work,E_IO.Less_Work,E_IO.More_Work,E_IO.Reason,E_IO.Other_Reason,E_IO.AB_LEAVE
				  ,E_IO.Late_In_Sec,E_IO.Late_In_count,E_IO.Early_Out_sec,E_IO.Early_Out_Count,E_IO.Total_Less_work_Sec,E_IO.Shift_St_Datetime,E_IO.Shift_en_Datetime,E_IO.Working_Sec_AfterShift,E_IO.Working_AfterShift_Count,E_IO.Leave_Reason,E_IO.Inout_Reason,E_IO.SysDate,
				  E_IO.Total_Work_Sec,E_IO.Late_Out_Sec,E_IO.Early_In_sec,E_IO.Total_More_work_Sec,E_IO.Is_OT_Applicable,E_IO.Monthly_Deficit_Adjust_OT_Hrs,
				  E_IO.Late_Comm_sec,E_IO.Branch_Id,E_IO.P_Days
				  ,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
			   @From_Date AS P_From_date ,@To_Date AS P_To_Date  
			   ,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,
			   (Case When E_IO.AB_LEAVE IN('HO','WO','OHO') THEN NULL ELSE dbo.F_GET_AMPM (Shift_END_Time) END) AS Shift_END_Time,
			   
			   ----- Modify Jignesh 23-Oct-2012 ( add 1 min IF Sec > 30 )
			   --dbo.F_GET_AMPM (In_Time) AS Actual_In_Time,
			   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time,  
			   --dbo.F_GET_AMPM (Out_Time) AS Actual_Out_Time , 
			   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time,  
			   
			   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date AS VARCHAR(11)) AS On_Date,
			   ,Reporting.R_Emp_ID as manager_id
			   ,BM.Branch_Name
			   --,@leave_Footer AS Leave_Footer
			   ----,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
			   --,Branch_Name
			  
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
			   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
			   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID left JOIN 
			   (select ROW_NUMBER() over(Partition by emp_id order by effect_date desc) as rank_Id,* from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where  Cmp_ID=@cmp_id
				) as Reporting on E_io.Emp_id = Reporting.Emp_ID  and Reporting.rank_Id=1 
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
			  and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
			  and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 
		END
--add by chetan 250517 for HMDA
	ELSE IF @Report_call = 'Employee Wise Latemark'
	BEGIN
										SELECT  ROW_NUMBER() OVER(ORDER BY 
										CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
										WHEN @Order_By='Name' THEN E.Emp_Full_Name
										When @Order_By = 'Designation' then (CASE WHEN  Dm.Desig_dis_No  = 0 THEN DM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DM.Desig_dis_No AS VARCHAR), 21)   END)     --added jimit 25092015
										ELSE 
											Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
											 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
											 ELSE Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') END
									END) AS Sr_No,
									  E_IO.*,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
								   @From_Date AS P_From_date ,@To_Date AS P_To_Date  
								   ,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,
								   (Case When E_IO.AB_LEAVE IN('HO','WO','OHO') THEN NULL ELSE dbo.F_GET_AMPM (Shift_END_Time) END) AS Shift_END_Time,
								   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time,  
								   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time,  
								   
								   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date AS VARCHAR(11)) AS On_Date,
								   ,@leave_Footer AS Leave_Footer
								   ,Branch_Name
								   ,BM.Comp_Name, BM.Branch_Address --Added by Nimesh 31-Jul-2015 (For Employee's Branch Address)
									,DM.Desig_Dis_No ---added jimit 24082015
									,vs.Vertical_Name,sv.SubVertical_Name --addee jimit 15062016
									
							FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
								   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
								   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
								   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
								   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
								   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
								   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
								   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID left outer join
								   T0040_Vertical_Segment vs WITH (NOLOCK) on E_Io.vertical_Id = vs.Vertical_ID left outer JOIN
								   T0050_SubVertical sv WITH (NOLOCK) on E_IO.subvertical_Id = sv.SubVertical_ID
							WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
								  and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
								  and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 

							
	END
	--added by chetan 06102017 for inout with break time card report 
	ELSE IF @Report_call = 'Time_Card'
		BEGIN
				Update #Emp_Inout SET Shift_St_Datetime = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) AS DATETIME)  FROM #Emp_Inout
	   				IF  object_id('tempdb..#Break_INOUT') IS NOT NULL 
					BEGIN      
						drop table #Break_INOUT  
					END 
					
						SELECT B.*,SM.S_St_Time,SM.S_End_Time,ABS(DATEDIFF(s,Pre_Out_TIme,B.for_date+S_st_time )) AS DIFF_NEAR 
						INTO	#Break_INOUT
						FROM	#TMP_BREAK B 
						INNER JOIN #Emp_Inout D ON B.FOR_DATE=D.For_date AND B.EMP_ID=D.EMP_ID  
						INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON D.Shift_ID=SM.Shift_ID
						
						--SELECT Emp_ID,For_Date,BI1.PRE_OUT_TIME,IN_TIME,Diffse
						--FROM	#Break_INOUT BI
						--		INNER JOIN (SELECT min(BI1.PRE_OUT_TIME) as PRE_OUT_TIME ,BI1.EMP_ID,BI1.FOR_DATE
						--					FROM	#Break_INOUT BI1
						--							INNER JOIN (SELECT	MIN(DIFF_NEAR) DIFF_NEAR, EMP_ID,FOR_DATE
						--										FROM	#Break_INOUT BI2
						--										GROUP BY EMP_ID,FOR_DATE) BI2 ON BI1.EMP_ID=BI2.EMP_ID AND BI1.FOR_DATE=BI2.FOR_DATE AND BI1.DIFF_NEAR=BI2.DIFF_NEAR
						--					GROUP BY BI1.EMP_ID,BI1.FOR_DATE) BI1 ON BI1.EMP_ID=BI.EMP_ID AND BI1.FOR_DATE=BI.FOR_DATE AND BI1.PRE_OUT_TIME=BI.PRE_OUT_TIME
						UPDATE EI 
						SET EI.Break_Start_Time = Qry.PRE_OUT_TIME  
						,EI.Break_End_Time = Qry.IN_TIME
						,EI.Break_Duration = dbo.F_Return_Hours(Qry.Diffse)
						FROM #Emp_Inout EI INNER JOIN
						(SELECT BI.Emp_ID,BI.For_Date,BI1.PRE_OUT_TIME,IN_TIME,Diffse
						FROM	#Break_INOUT BI
								INNER JOIN (SELECT min(BI1.PRE_OUT_TIME) as PRE_OUT_TIME ,BI1.EMP_ID,BI1.FOR_DATE
											FROM	#Break_INOUT BI1
													INNER JOIN (SELECT	MIN(DIFF_NEAR) DIFF_NEAR, EMP_ID,FOR_DATE
																FROM	#Break_INOUT BI2
																GROUP BY EMP_ID,FOR_DATE) BI2 ON BI1.EMP_ID=BI2.EMP_ID AND BI1.FOR_DATE=BI2.FOR_DATE AND BI1.DIFF_NEAR=BI2.DIFF_NEAR
											GROUP BY BI1.EMP_ID,BI1.FOR_DATE) BI1 ON BI1.EMP_ID=BI.EMP_ID AND BI1.FOR_DATE=BI.FOR_DATE AND BI1.PRE_OUT_TIME=BI.PRE_OUT_TIME
						)Qry  ON EI.Emp_ID=Qry.Emp_ID AND EI.For_Date = Qry.For_Date 
									
					
				--end--		
				Update #Emp_Inout SET Shift_en_Datetime   = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) AS DATETIME)  FROM #Emp_Inout	
				
				SELECT 
				--E_IO.*,
				E_IO.emp_id,E_IO.for_Date,E_IO.Dept_id,E_IO.Grd_ID,E_IO.Type_ID,E_IO.Desig_ID,E_IO.Shift_ID,
				E_IO.In_Time
				,E_IO.Out_Time
				,E_IO.Duration,
				E_IO.Duration_sec
				,E_IO.Late_In,
				case when E_IO.Out_Time >  Shift_en_Datetime  then '' ELSE E_IO.Late_Out END AS Late_Out ,
				E_IO.Early_In,E_IO.Early_Out,
				E_IO.Leave,
				E_IO.Shift_Sec,
				E_IO.Shift_Dur,
				case when E_IO.Out_Time >  Shift_en_Datetime then DBO.F_Return_Hours(DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime)) ELSE E_IO.Total_work END AS Total_work ,
				case when E_IO.Out_Time >  Shift_en_Datetime then CAST( DBO.F_Return_Hours(case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 ELSE ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) END)  AS varchar) ELSE E_IO.Less_Work END AS Less_Work
				,E_IO.More_Work 
				,Reason,
				E_IO.AB_LEAVE,E_IO.Late_In_Sec,E_IO.Late_In_count,E_IO.Early_Out_sec,E_IO.Early_Out_Count,
				case when E_IO.Out_Time >  Shift_en_Datetime then (case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 ELSE ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) END)   ELSE E_IO.Total_Less_work_Sec END AS Total_Less_work_Sec,

				E_IO.Shift_St_Datetime,E_IO.Shift_en_Datetime,
				E_IO.Working_Sec_AfterShift,E_IO.Working_AfterShift_Count,E_IO.Leave_Reason,E_IO.Inout_Reason,
				E_IO.SysDate,
				case when E_IO.Out_Time >  Shift_en_Datetime then DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ELSE  E_IO.Total_Work_Sec END AS Total_Work_Sec,
				0 AS Late_Out_Sec,
				E_IO.Early_In_sec
				,E_IO.Total_More_work_Sec 
				,E_IO.Is_OT_Applicable,E_IO.Monthly_Deficit_Adjust_OT_Hrs,E_IO.Late_Comm_sec
				,E_IO.P_days
				,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
				@From_Date AS P_From_date ,@To_Date AS P_To_Date  
				,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,
				dbo.F_GET_AMPM (Shift_END_Time) AS Shift_END_Time,
				dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time,  
				dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time,  

				convert(varchar(10),for_date,103)as On_Date 
				,@leave_Footer AS Leave_Footer,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
				,DM.Desig_Dis_No       
				,BM.Branch_Name		
				,E_IO.Break_Start_Time,E_IO.Break_End_Time ,E_IO.Break_Duration
				FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
				dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
				dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
				dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
				dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
				E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
				E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID  
				Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) On BM.Branch_ID = E_IO.Branch_ID    
				WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
				and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
				and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 
				-- Order by 
				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
						When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
							ELSE e.Alpha_Emp_Code
		END 
							
	END
	--added by chetan 03112017 for rest duration report
	ELSE IF @report_call='Rest_Duration'
	BEGIN
			Update #Emp_Inout SET Shift_St_Datetime = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) AS DATETIME)  FROM #Emp_Inout
			Update #Emp_Inout SET Shift_en_Datetime   = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) AS DATETIME)  FROM #Emp_Inout	
		  --for rest duration update--------------------
		  IF  object_id('tempdb..#Temp_Emp_Inout') IS NOT NULL 
					BEGIN      
						drop table #Temp_Emp_Inout  
					END 
					
			;WITH s AS 
			(
				SELECT 1 AS LeadOffset, 1 AS LagOffset, NULL AS LeadDefVal, NULL AS LagDefVal, ROW_NUMBER() OVER (ORDER BY emp_id, for_date) AS Row_No
				,In_Time,Out_Time,for_Date,EMP_ID FROM #Emp_Inout
			)
			
			SELECT	S.EMP_ID,S.FOR_DATE,sLead.In_Time,DATEDIFF(s,s.Out_Time,ISNULL( sLead.In_Time, s.LeadDefVal)) AS RestDurationSec
			INTO #Temp_Emp_Inout
			FROM s
			LEFT OUTER JOIN s AS sLead
			ON s.Row_No = sLead.Row_No - s.LeadOffset
			AND s.for_Date = sLead.for_Date
			LEFT OUTER JOIN s AS sLag
			ON s.Row_No = sLag.Row_No + s.LagOffset
			AND s.for_Date = sLag.for_Date
			ORDER BY s.Emp_ID, s.for_Date
		 
			UPDATE EIO 
			SET EIO.Rest_Duration_Sec = T.RestDurationSec,
				EIO.Rest_Duration = dbo.F_Return_Hours(T.RestDurationSec)
			FROM #Emp_Inout EIO
			INNER JOIN
			#Temp_Emp_Inout T 
			ON EIO.EMP_ID=T.EMP_ID AND EIO.FOR_DATE=T.FOR_DATE 
			AND EIO.In_Time = T.In_Time
			
			
			SELECT 
			E_IO.emp_id,E_IO.for_Date,E_IO.Dept_id,E_IO.Grd_ID,E_IO.Type_ID,E_IO.Desig_ID,E_IO.Shift_ID
			,E_IO.In_Time,case when E_IO.Out_Time >  Shift_en_Datetime  then Shift_en_Datetime ELSE E_IO.Out_Time END AS  Out_Time
			,E_IO.Duration,E_IO.Duration_sec,E_IO.Late_In,case when E_IO.Out_Time >  Shift_en_Datetime  then '' ELSE E_IO.Late_Out END AS Late_Out
			,E_IO.Early_In,E_IO.Early_Out,E_IO.Leave,E_IO.Shift_Sec,E_IO.Shift_Dur,
			case when E_IO.Out_Time >  Shift_en_Datetime then DBO.F_Return_Hours(DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime)) ELSE E_IO.Total_work END AS Total_work ,
			case when E_IO.Out_Time >  Shift_en_Datetime then CAST( DBO.F_Return_Hours(case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 ELSE ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) END)  AS varchar) ELSE E_IO.Less_Work END AS Less_Work
			, case when E_IO.Out_Time >  Shift_en_Datetime then CAST( DBO.F_Return_Hours(case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 ELSE ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) END)  AS varchar) ELSE E_IO.More_Work END AS More_Work
			,Reason,E_IO.AB_LEAVE,E_IO.Late_In_Sec,E_IO.Late_In_count,E_IO.Early_Out_sec,E_IO.Early_Out_Count,
			case when E_IO.Out_Time >  Shift_en_Datetime then (case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 ELSE ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) END)   ELSE E_IO.Total_Less_work_Sec END AS Total_Less_work_Sec,
			E_IO.Shift_St_Datetime,E_IO.Shift_en_Datetime,E_IO.Working_Sec_AfterShift,E_IO.Working_AfterShift_Count,E_IO.Leave_Reason,E_IO.Inout_Reason,
			E_IO.SysDate,
			case when E_IO.Out_Time >  Shift_en_Datetime then DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ELSE  E_IO.Total_Work_Sec END AS Total_Work_Sec,
			0 AS Late_Out_Sec,E_IO.Early_In_sec
			, case when E_IO.Out_Time >  Shift_en_Datetime then (case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 ELSE ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) END)  ELSE E_IO.Total_More_work_Sec END AS Total_More_work_Sec
			,E_IO.Is_OT_Applicable,E_IO.Monthly_Deficit_Adjust_OT_Hrs,E_IO.Late_Comm_sec
			,E_IO.P_days
			,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
			@From_Date AS P_From_date ,@To_Date AS P_To_Date ,dbo.F_GET_AMPM (Shift_St_Datetime) AS Shift_Start_Time,dbo.F_GET_AMPM (Shift_END_Time) AS Shift_END_Time
			,dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) ELSE In_Time END ) AS  Actual_In_Time
			,dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) ELSE Out_Time END ) AS  Actual_Out_Time
			,convert(varchar(10),for_date,103)as On_Date,@leave_Footer AS Leave_Footer,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,DM.Desig_Dis_No,BM.Branch_Name
			,E_IO.Rest_Duration, IN_QRY.In_Punch_DeviceName,OUT_QRY.Out_Punch_DeviceName --added by chetan 08112017
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
			dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
			dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
			dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
			dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
			E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
			E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID  
			Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) On BM.Branch_ID = E_IO.Branch_ID 
			--added by chetan 08112017
			LEFT OUTER JOIN 
			(
				SELECT EM.Emp_ID,TD.Enroll_No,TD.IO_DateTime,TD.In_Out_flag,TD.IP_Address AS IN_IP_ADDRESS
				,ISNULL(IM.Device_Name,'') AS  In_Punch_DeviceName
				FROM T9999_DEVICE_INOUT_DETAIL TD 
				LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TD.Enroll_No = EM.Enroll_No 
				LEFT OUTER JOIN T0040_IP_MASTER IM WITH (NOLOCK) ON TD.IP_Address = IM.IP_ADDRESS 
				WHERE  TD.In_Out_flag = 0 --and emp_ID =  17914
			)IN_QRY ON  E_IO.Emp_ID = IN_QRY.Emp_ID AND E_IO.In_Time = IN_QRY.IO_DateTime 
			LEFT OUTER JOIN 
			(
				SELECT EM.Emp_ID,TD.Enroll_No,TD.IO_DateTime,TD.In_Out_flag,TD.IP_Address AS IN_IP_ADDRESS
				,ISNULL(IM.Device_Name,'') AS  Out_Punch_DeviceName
				FROM T9999_DEVICE_INOUT_DETAIL TD 
				LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TD.Enroll_No = EM.Enroll_No 
				LEFT OUTER JOIN T0040_IP_MASTER IM WITH (NOLOCK) ON TD.IP_Address = IM.IP_ADDRESS 
				WHERE  TD.In_Out_flag = 1 --and emp_ID =  17914
			)OUT_QRY ON  E_IO.Emp_ID = OUT_QRY.Emp_ID  AND E_IO.Out_Time = OUT_QRY.IO_DateTime  
			----------------END---------------
			WHERE CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) >= CAST(CAST(@From_Date  AS VARCHAR(11)) AS smalldatetime)  
			and CAST(CAST(For_Date AS VARCHAR(11)) AS smalldatetime) <= CAST(CAST(@To_Date  AS VARCHAR(11)) AS smalldatetime)   
			and ( In_Time is not null  OR Out_Time is not null  OR ab_leave is not null ) 
			-- Order by 
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						ELSE e.Alpha_Emp_Code
					END
	END
    
    
RETURN      



