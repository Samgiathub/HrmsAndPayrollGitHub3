
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_INOUT_RECORD_GET_CERA_TEMP] 
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
    
    
	   
	DECLARE @Status AS VARCHAR(9)      
	DECLARE @For_Date AS DATETIME      
	DECLARE @RowID AS NUMERIC       
	DECLARE @GradeID AS NUMERIC       
	DECLARE @SysDate DATETIME  
	  
	  
	DECLARE @LateMark AS VARCHAR(9)      
	DECLARE @InTime AS smalldatetime       
	DECLARE @OutTime AS smalldatetime      
	DECLARE @PreOutTime AS smalldatetime      
	    
	DECLARE @Is_Join AS VARCHAR(1)      
	DECLARE @Count AS NUMERIC      
	DECLARE @dblYear AS NUMERIC      
	DECLARE @numofDay AS NUMERIC      
	DECLARE @varWeekoff_Date AS VARCHAR(500)      
	DECLARE @varHoliday_Date AS VARCHAR(500)      

	DECLARE @Join_Date    DATETIME      
	DECLARE @Left_Date    DATETIME       
	DECLARE @StrHoliday_Date  VARCHAR(1000)      
	DECLARE @StrWeekoff_Date  VARCHAR(1000)      
	DECLARE @Is_Cancel_Holiday  Numeric(1,0)      
	DECLARE @Is_Cancel_Weekoff  Numeric(1,0)      
	DECLARE @Holiday_Days    NUMERIC(12,1)      
	DECLARE @Weekoff_Days    NUMERIC(12,1)      
	DECLARE @Cancel_Holiday   NUMERIC(12,1)      
	DECLARE @Cancel_Weekoff      NUMERIC(12,1)      
	DECLARE @Leave_Days numeric(18,2)

	DECLARE @StrCancelWeekoff_Date  VARCHAR(1000)--Ankit 30122015
	DECLARE @StrCancelHoliday_Date  VARCHAR(1000)--Ankit 30122015
	DECLARE @Weekoff_Date1_CancelStr AS VARCHAR(MAX)	--Ankit 25022016
	SET @StrCancelWeekoff_Date = ''
	SET @StrCancelHoliday_Date = ''
	SET @Weekoff_Date1_CancelStr = ''

	SET @Is_Cancel_Weekoff = 0      
	SET @Is_Cancel_Holiday = 0      
	SET @StrHoliday_Date = ''      
	SET @StrWeekoff_Date = ''      
	SET @Holiday_Days  = 0      
	SET @Weekoff_Days  = 0      
	SET @Cancel_Holiday  = 0      
	SET @Cancel_Weekoff  = 0      

	  
	SET @Count =0      
	SET @RowID =0      

	   
	SET @numofDay = DATEDIFF(d,@From_Date,@To_Date) + 1      
	  
	-- for Holiday and Week Off  and LEave date      
	DECLARE @Total_Holiday_Date AS VARCHAR(500)      
	DECLARE @Total_LeaveDay_Date AS VARCHAR(500)      
	DECLARE @strOnlyHoliday_date AS VARCHAR(500)      
	SET @Total_Holiday_Date = ''      
	SET @Total_LeaveDay_Date = ''      
	  
	-- for Shift      
	DECLARE @Shift_St_Time AS VARCHAR(10)      
	DECLARE @Shift_END_Time AS VARCHAR(10)      
	DECLARE @varShift_St_Date AS VARCHAR(20)      
	DECLARE @dtShift_St_Date AS DATETIME      
	DECLARE @varShift_END_Date AS VARCHAR(20)      
	DECLARE @dtShift_END_Date AS DATETIME      
	DECLARE @TempFor_Date AS smalldatetime      
	DECLARE @dtShift_Actual_St_Time AS DATETIME      
	DECLARE @dtShift_Actual_END_Time AS DATETIME      
	DECLARE @Late_Comm_Limit AS VARCHAR(5)      
	DECLARE @Late_comm_sec AS NUMERIC       
	DECLARE @Leave_ID AS NUMERIC       
	DECLARE @Leave_Name AS VARCHAR(20)      
	DECLARE @Leave_Reason AS VARCHAR(100)  
	--Added by Hardik 06/12/2013 for Pakistan
	DECLARE @Leave_Period AS NUMERIC(18,2)
	DECLARE @Half_Leave_Date AS DATETIME
	DECLARE @Leave_Assign_As AS VARCHAR(100)
	DECLARE @Country_Name AS VARCHAR(100)

	-- Added by rohit on 20082014
	DECLARE @leave_out_time AS DATETIME
	DECLARE @leave_in_time AS DATETIME
	DECLARE @leave_Detail AS VARCHAR(max)
	DECLARE @apply_hourly AS VARCHAR(100)

	--add by chetan 250517
	DECLARE @Leave_FromDate AS DATETIME
	DECLARE @Leave_ToDate AS DATETIME
		---------
	SET @leave_Detail=''
	SET @leave_out_time ='01-jan-1900'
	SET @leave_in_time ='01-jan-1900'
	SET @apply_hourly = ''

	SELECT @Country_Name = Loc_name FROM T0010_COMPANY_MASTER C WITH (NOLOCK) Inner Join T0001_LOCATION_MASTER L WITH (NOLOCK) On
		C.Loc_ID = L.Loc_ID WHERE C.Cmp_Id = @Cmp_ID
	  
	DECLARE @Temp_Month_Date AS DATETIME      
	SET @Temp_Month_Date = @From_Date      
	   

	  
	DECLARE @In_Dur AS VARCHAR(10)      
	DECLARE @In_Out_Flag AS VARCHAR(1)      
	DECLARE @Day_St_Time AS DATETIME      
	DECLARE @Day_END_Time AS DATETIME      
	   
	DECLARE @OT_Limit_Sec AS NUMERIC      
	DECLARE @OT_Limit AS VARCHAR(10)      
	   
	DECLARE @Temp_For_Date AS VARCHAR(11)      
	DECLARE @Shift_Sec AS NUMERIC      
	DECLARE @Return_Sec AS NUMERIC      
	DECLARE @Tot_Working_Sec AS NUMERIC      
	DECLARE @Working_Sec AS NUMERIC      
	DECLARE @OT_Sec AS NUMERIC      
	DECLARE @Holiday_Work_Sec AS NUMERIC      
	DECLARE @WeekOff_Work_Sec AS NUMERIC      
	   
	SET @Return_Sec = 0      
	SET @Holiday_Work_Sec = 0      
	SET @WeekOff_Work_Sec = 0      
	   
	DECLARE @In_Date AS DATETIME      
	DECLARE @Out_Date AS DATETIME      
	DECLARE @Shift_Dur AS VARCHAR(10)      
	DECLARE @Temp_Date AS DATETIME      
	DECLARE @Min_Dur AS VARCHAR(10)      
	   
	DECLARE @Rounding_Shift_Time AS NUMERIC      
	DECLARE @Next_Day_Working_Sec AS NUMERIC      
	DECLARE @Is_OT AS VARCHAR(1)      
	DECLARE @Fix_OT AS NUMERIC      
	DECLARE @Shift_END_DateTime AS DATETIME      
	DECLARE @Shift_ST_DateTime AS DATETIME      
	DECLARE @Last_out_Date AS DATETIME      
	DECLARE @Manual_Last_in_Date AS DATETIME      
	DECLARE @Next_day_Work_Sec AS NUMERIC  -- previous days working sec      
	DECLARE @Temp_Working_sec AS NUMERIC      
	DECLARE @varWagesType AS VARCHAR(20)      
	DECLARE @temp_out_Date AS DATETIME      
	DECLARE @SHIFT_ID AS NUMERIC       
	  
	DECLARE @Insert_In_Date AS DATETIME      
	DECLARE @Insert_Out_Date AS DATETIME      
	DECLARE @INSERT_COUNT AS INTEGER      
	DECLARE @Late_In AS VARCHAR(20)      
	DECLARE @Late_Out AS VARCHAR(20)      
	DECLARE @Early_In AS VARCHAR(20)      
	DECLARE @Early_Out AS VARCHAR(20)      
	DECLARE @WORKING_HOURS AS VARCHAR(20)      
	DECLARE @Late_In_Count AS NUMERIC       
	DECLARE @Early_out_count AS NUMERIC       
	DECLARE @Total_less_work_sec AS NUMERIC       
	DECLARE @Total_More_work_sec AS NUMERIC       
	   
	DECLARE @Late_In_Sec numeric      
	DECLARE @Late_Out_Sec numeric      
	DECLARE @Early_In_Sec numeric      
	DECLARE @Early_Out_Sec numeric      
	   
	DECLARE @Toatl_Working_sec numeric       
	DECLARE @Total_work AS VARCHAR(20)      
	DECLARE @Less_Work AS VARCHAR(20)      
	DECLARE @More_Work AS VARCHAR(20)      
	DECLARE @Diff_Sec  AS NUMERIC       
	DECLARE @Working_Sec_AfterShift AS NUMERIC       
	DECLARE @Working_AfterShift_Count AS NUMERIC       
	DECLARE @Reason AS VARCHAR(300)   
	DECLARE @Other_Reason AS VARCHAR(MAX)    --Added By Jaina 12-09-2015
	DECLARE @Pre_Reason AS VARCHAR(300)      
	DECLARE @Last_Entry_For_check AS DATETIME      
	  
	DECLARE @Shift_St_Sec AS NUMERIC       
	DECLARE @Shift_En_sec AS NUMERIC      
	DECLARE @Pre_Inout_Flag AS VARCHAR(1)      
	DECLARE @Pre_In_Date AS DATETIME      
	DECLARE @Pre_Shift_St_dateTime AS DATETIME      
	DECLARE @Pre_Shift_En_DateTime AS DATETIME       

	DECLARE @Early_Limit_sec AS NUMERIC   
	DECLARE @Early_Limit AS VARCHAR(10)    
	DECLARE @Is_Cancel_Holiday_WO_HO_same_day BIT
	
	SET @Early_Limit_sec = 0
	SET @Early_Limit = ''

	DECLARE @Emp_OT AS NUMERIC
	DECLARE @Emp_OT_Min_Limit_Sec AS NUMERIC
	DECLARE @Emp_OT_Max_Limit_Sec AS NUMERIC

	DECLARE @Monthly_Deficit_Adjust_OT_Hrs AS TINYINT -- Added by Hardik 25/10/2013 for Sharp Image, Pakistan

	--Ankit 12112013
	DECLARE @Second_Break_Duration AS VARCHAR(10)    
	DECLARE @Third_Break_Duration AS VARCHAR(10)     
	 SET @Second_Break_Duration =''	
	 SET @Third_Break_Duration =''	
	DECLARE @Second_Break_Duration_Sec AS NUMERIC      	
	DECLARE @Third_Break_Duration_Sec AS NUMERIC      	
	--Ankit 12112013 

	SET @Emp_OT = 0
	SET @Emp_OT_Min_Limit_Sec = 0
	SET @Emp_OT_Max_Limit_Sec = 0
	SET @Monthly_Deficit_Adjust_OT_Hrs = 0
	   
	-- Added by rohit on 22082014
	DECLARE @Is_Half_Day	tinyint	
	DECLARE @Week_Day	varchar(10)	
	DECLARE @Half_St_Time	varchar(10)	
	DECLARE @Half_END_Time	varchar(10)	
	DECLARE @Half_Dur	varchar(10)	
	
	
	
	DECLARE @Chk_by_Superior AS TINYINT
	DECLARE @Half_Full_Day AS VARCHAR(30)
	DECLARE @Is_Cancel_Late_In AS TINYINT
	DECLARE @Is_Cancel_Early_Out AS TINYINT
	--added by chetan 07102017 for time card report of break time show 
	--DECLARE @Break_St_Time AS DATETIME
	--DECLARE @Break_Ed_Time AS DATETIME
	--DECLARE @For_Date_Count AS INT

	SET @Is_Half_Day = 0  
	SET @Week_Day	= '' 
	SET @Half_St_Time		= '' 
	SET @Half_END_Time		= '' 
	SET @Half_Dur	= '' 
	   

	  
	SET @Fix_OT = 0      
	  
	  
	SET @Reason  = ''      
	SET @Pre_Reason = ''      
	  
	SET @Shift_St_Time = ''      
	SET @Shift_END_Time = ''      
	SET @Shift_Dur = ''      
	SET @Late_Comm_Limit = ''      
	SET @Late_comm_sec = 0      
	SET @Leave_Id = 0      
	SET @Leave_Name = ''      
	   
       
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
	   
	DECLARE @Vertical_Id NUMERIC --added jimit 15062016
	DECLARE @SubVertical_Id NUMERIC --added jimit 15062016    
	SET @Vertical_Id =0
	SET @SubVertical_Id = 0
	   			

	--Create Table #INOUT_DETAIL
 --       (
	--		Emp_ID		Numeric,
	--		Row_ID		Numeric,
	--		For_Date	DateTime,
	--		P_Days		Numeric(9,4),
	--		HO_Day		Numeric(5,2),
	--		WO_Day		Numeric(5,2),
	--		Leave_Days	Numeric(9,4),			
	--		Leave_Type	varchar(100),
	--		Absent      Numeric(5,2)
 --       )
        
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)      
	-- Ankit 08092014 for Same Date Increment
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2,@PBranch_ID 
	
	
	
	DECLARE @Branch_Id_Cur AS NUMERIC

	-- Added by rohit For Leave Name Showing With Leave Code in Footer on 08082013
	DECLARE @leave_Footer VARCHAR(5000)
	SET @leave_Footer = ''

	SELECT  @leave_Footer = STUFF((SELECT ' ' + s.Leave_name FROM 
	( SELECT ('  ' + Leave_Code + ' : ' + Leave_name + ' ' ) AS leave_name,Cmp_ID FROM T0040_LEAVE_MASTER WITH (NOLOCK) where isnull(Display_leave_balance,0) = 1
	)
	s WHERE s.Cmp_id = t.Cmp_id FOR XML PATH('')),1,1,'')  FROM T0040_LEAVE_MASTER AS t WITH (NOLOCK) WHERE t.Cmp_ID=@cmp_id GROUP BY t.Cmp_id

 --SELECT @leave_Footer
 
 -- ENDed by rohit on 08082013

	--Added by Jaina 19-02-2018 Start
	IF @Report_call = 'Inout_Mail'
		BEGIN
			CREATE table #ATT_MUSTER_EXCEL 
			(	
				EMP_ID		NUMERIC , 
				CMP_ID		NUMERIC,
				FOR_DATE	DATETIME,
				STATUS		VARCHAR(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				LEAVE_COUNT	NUMERIC(5,2),
				WO_HO		VARCHAR(3) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				STATUS_2	VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				ROW_ID		NUMERIC ,
				WO_HO_DAY	NUMERIC(3,2) DEFAULT 0,
				P_DAYS		NUMERIC(5,2) DEFAULT 0,
				A_DAYS		NUMERIC(5,2) DEFAULT 0 ,
				JOIN_DATE	DATETIME DEFAULT NULL,
				LEFT_DATE	DATETIME DEFAULT NULL,
				GATE_PASS_DAYS NUMERIC(18,2) DEFAULT 0,  -- ADDED BY GADRIWALA MUSLIM 07042015
				LATE_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0, -- ADDED BY GADRIWALA MUSLIM 07042015
				EARLY_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0, -- ADDED BY GADRIWALA MUSLIM 07042015
				EMP_CODE    VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				EMP_FULL_NAME  VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				BRANCH_ADDRESS VARCHAR(300) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				COMP_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				BRANCH_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				DEPT_NAME  VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				GRD_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				DESIG_NAME VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
				P_FROM_DATE  DATETIME,
				P_TO_DATE DATETIME,
				BRANCH_ID NUMERIC(18,0),
				DESIG_DIS_NO NUMERIC(18,2) DEFAULT 0,          ---ADDED JIMIT 31082015 
				SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
			)
			  
			CREATE NONCLUSTERED INDEX IX_DATA ON DBO.#ATT_MUSTER_EXCEL
			(	EMP_ID,EMP_CODE,ROW_ID ) 
			
			exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@Cmp_ID,@From_Date=@FROM_DATE,@To_Date=@TO_DATE,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@Constraint=@Constraint,@Report_For = '',@Export_Type  = 'EXCEL',@Type=0
		END		
	--Added by Jaina 19-02-2018 Start

 -- Added by rohit for monthly Auto Generate mail For muni seva Ashram on 24092013       
	IF @Report_call <> 'Monthly Generate'
		BEGIN   
			IF  object_id('tempdb..#Emp_Inout') IS NOT NULL --exists (SELECT 1 FROM [tempdb].dbo.sysobjects WHERE name like '#Emp_Inout' )        
				BEGIN      
					drop table #Emp_Inout  
				END  
		END       

	IF  OBJECT_ID('tempdb..#Emp_Inout') IS NULL 
		BEGIN
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
				Break_Duration	VARCHAR(10) null, --added by chetan 07102017
				Rest_Duration_Sec NUMERIC DEFAULT 0, --added by chetan 03112017
				Rest_Duration	VARCHAR(10) DEFAULT '', --added by chetan 03112017
				DEPARTMENT_IN_TIME DATETIME NULL, -- ADDED BY RAJPUT ON 20072018
				DEPARTMENT_OUT_TIME DATETIME NULL -- ADDED BY RAJPUT ON 20072018
				
				
			)      
		END
  
	DECLARE @bHW_Exec_Req BIT;
	SET @bHW_Exec_Req = 0;

	DECLARE @p_Days AS NUMERIC(18,2)  
	SET @p_Days = 0
	
	
	
	IF OBJECT_ID('tempdb..#Emp_WeekOff_Holiday') IS NULL
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
	 
		--Added by Jaina 17-01-2018
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

		END
		
	 IF @bHW_Exec_Req = 1
		 BEGIN
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW=0
		 END
	  
	  
	DECLARE @Is_Late_Calc_On_HO_WO  AS NUMERIC
	DECLARE @Is_Early_Calc_On_HO_WO AS NUMERIC
	
	
	DECLARE @OT_Start_ShiftEND_Sec NUMERIC

	SET @Is_Late_Calc_On_HO_WO=0
	SET @Is_Early_Calc_On_HO_WO=0
	  

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
	IF @Report_Call='Time_Card' OR @Report_Call='Time_Card_Cera' 
		BEGIN    
			EXEC P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE, @Is_Auto_Inout
		END
	ELSE
		BEGIN
			EXEC P_GET_EMP_INOUT @CMP_ID, @FROM_DATE, @TO_DATE
		END
		


	IF @Report_call = 'Time_Card' or @Report_call = 'Time_Card_Cera'
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
		
	--select	D.Emp_Id,D.For_date,D.In_Time,D.OUT_Time,EIO.In_Time,EIO.Out_Time 
	--from	T0150_EMP_INOUT_RECORD EIO
	--		INNER JOIN #Data D ON EIO.In_Time BETWEEN DATEADD(n,1, D.In_Time) AND DATEADD(n,-1, D.OUT_Time) AND EIO.Emp_ID=D.Emp_Id
	--ORDER BY EIO.In_Time
	
	
	
	SELECT	TOP 0 IN_TIME,OUT_TIME,REASON,OTHER_REASON,Half_Full_day
	INTO	#IN_OUT
	FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
	
	  
	Select	@Is_Cancel_Holiday = Is_Cancel_Holiday ,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,@Is_Late_Calc_On_HO_WO=Is_Late_Calc_On_HO_WO, @Is_Early_Calc_On_HO_WO =Is_Early_Calc_On_HO_WO        
	From	dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID and Branch_ID = @Branch_ID      
			and For_Date = ( SELECT max(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)  

 
	      
	DECLARE CUR_EMP CURSOR FOR
	SELECT	E.EMP_ID,Inc_Qry.Grd_ID,Inc_Qry.Type_ID,Inc_Qry.Dept_ID,Inc_Qry.Desig_ID,
			dbo.F_Return_Sec(Inc_Qry.Emp_Late_Limit),dbo.F_Return_Sec(Inc_Qry.Emp_Early_Limit),
			Emp_OT,dbo.F_Return_Sec(Inc_Qry.Emp_OT_Min_Limit),dbo.F_Return_Sec(Inc_Qry.Emp_OT_Max_Limit),ISNULL(Monthly_Deficit_Adjust_OT_Hrs,0),Inc_Qry.Branch_ID
			,Inc_Qry.Vertical_ID,Inc_Qry.SubVertical_ID  --added jimit 15062016
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK) Inner join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner join       
			(
				select	I.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,ISNULL(Emp_Late_Limit,'00:00') AS Emp_Late_Limit,
						ISNULL(Emp_Early_Limit,'00:00') AS Emp_Early_Limit,ISNULL(Emp_OT,0) AS Emp_OT,
						ISNULL(Emp_OT_Min_Limit,'00:00') AS Emp_OT_Min_Limit,ISNULL(Emp_OT_Max_Limit,'00:00') AS Emp_OT_Max_Limit, Monthly_Deficit_Adjust_OT_Hrs,
						Branch_ID,I.Vertical_ID,I.SubVertical_ID
				from	dbo.T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN (
									select	max(i.Increment_ID) AS Increment_ID, i.Emp_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner Join #Emp_Cons EC on i.Emp_ID = ec.Emp_ID	-- Ankit 08092014 for Same Date Increment    
									where	Increment_effective_Date <= @To_Date and Cmp_ID = @Cmp_ID      
									group by i.emp_ID  ) Qry ON I.Emp_ID = Qry.Emp_ID and i.Increment_ID   = Qry.Increment_ID       
				WHERE Cmp_ID = @Cmp_ID ) Inc_Qry on e.Emp_ID = Inc_Qry.Emp_ID       
	           
	WHERE E.Cmp_ID = @Cmp_ID       
	OPEN  CUR_EMP      
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur,@Vertical_Id,@SubVertical_Id
	WHILE @@FETCH_STATUS = 0      
		BEGIN      
		
			SELECT	@Late_Comm_Limit = Late_Limit,@Early_Limit = Early_Limit, @Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day
			FROM	T0040_GENERAL_SETTING G WITH (NOLOCK)
					INNER JOIN (SELECT	MAX(For_Date) AS For_Date, G1.BRANCH_ID 
								FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
										INNER JOIN #EMP_CONS E ON G1.BRANCH_ID=E.BRANCH_ID
								WHERE	Cmp_ID = @Cmp_ID and For_Date <=@To_Date
								GROUP BY G1.BRANCH_ID) G1 ON G.BRANCH_ID=G1.BRANCH_ID
			    
			SET @Late_Comm_sec = dbo.F_Return_Sec(@Late_Comm_Limit) 
			SET @Early_Limit_sec = dbo.F_Return_Sec(@Early_Limit)        
		
			SET @varWeekoff_Date = ''      
			SET @varHoliday_Date = ''       
			SET @Last_out_Date  = null      
			SET @out_Date = null      
			SET @in_Date = null      
			SET @Last_Entry_For_check = null      
			SET @Pre_Inout_Flag = ''      
			SET @Pre_Shift_St_DateTime = null      
			SET @Pre_Shift_en_DateTime = null      
			SET @Working_Sec_AfterShift = 0      
			SET @Working_AfterShift_Count = 0       
			    
			SET @Temp_Month_Date = @From_Date      
			    
			SET @insert_In_date = null      
			SET @insert_Out_Date = null      
			SET @Pre_In_Date = null      
			  
			SET @strOnlyHoliday_date = ''      
			SET @Total_Holiday_Date = ''      
			SET @Total_LeaveDay_Date  = ''      
			SET @varWeekoff_Date = ''
			SET @StrHoliday_Date = ''      
			SET @StrWeekoff_Date = ''      
			SET @Holiday_Days  = 0      
			SET @Weekoff_Days  = 0      
			SET @Cancel_Holiday  = 0      
			SET @Cancel_Weekoff  = 0      
			SET @StrCancelWeekoff_Date = ''
			SET @StrCancelHoliday_Date = ''

			--Added by Hardik 22/11/2011 for Night shift Min In and Max Out Record
			DECLARE @Min_In DATETIME 
			DECLARE @Max_Out AS DATETIME
			DECLARE @hh AS int
			DECLARE @mi AS int
			DECLARE @Shift_St_Time1 AS DATETIME
			DECLARE @Shift_END_Time1 AS DATETIME
			DECLARE @For_Date1 AS DATETIME
			DECLARE @For_Date2 AS DATETIME
			DECLARE @Max_Date AS DATETIME
			DECLARE @Reason1 AS VARCHAR(150)
			--- END for Hardik 

			DECLARE @Temp_END_Date AS DATETIME       
			--SET @Temp_END_Date = Dateadd(d,1,@To_Date)      
			SET @Temp_END_Date = @To_Date      
	  
			EXEC dbo.SP_EMP_JOIN_LEFT_DATE_GET @Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date OUTPUT,@Left_Date OUTPUT
			
			SELECT	@StrWeekoff_Date = T.WeekOffDate,
					@Weekoff_Days = T.WeekOffCount,
					@Cancel_Weekoff = T.CancelWeekOffCount,
					@StrHoliday_Date = T.HolidayDate + T.CancelHoliday,	--CancelHoliday Added by Ankit 30122015
					@Holiday_days = T.HolidayCount,
					@Cancel_Holiday = T.CancelHolidayCount,
					@Weekoff_Date1_CancelStr = T.CancelWeekOff,	--Added by Ankit 30122015
					@StrCancelHoliday_Date = T.CancelHoliday	--Added by Ankit 30122015
			FROM	#EMP_HW_CONS T
			WHERE	Emp_ID= @Emp_ID 
			
			SELECT @StrCancelWeekoff_Date = coalesce(@StrCancelWeekoff_Date +';','') + Data  FROM dbo.Split(ISNULL(@Weekoff_Date1_CancelStr,''),';')
			WHERE Data <> '' AND NOT EXISTS ( SELECT For_Date FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK) WHERE Emp_id = @Emp_ID and is_Cancel_WO = 1 and For_date = CAST(Data AS DATETIME) )

			IF ISNULL(@StrCancelWeekoff_Date,'') <> ''
				SET @StrWeekoff_Date = @StrWeekoff_Date + @StrCancelWeekoff_Date


			while @Temp_Month_Date <= @Temp_END_Date      
				BEGIN      
					SET @shift_ID = 0      
			        
					SET @Is_Half_Day = 0;    
					SET @Shift_END_Time = null;
					EXEC dbo.SP_CURR_T0100_EMP_SHIFT_GET @emp_id,@Cmp_ID,@Temp_Month_Date,@Shift_St_Time OUTPUT,@Shift_END_Time OUTPUT,@Shift_Dur OUTPUT,null,@Second_Break_Duration OUTPUT,@Third_Break_Duration  OUTPUT,null,@shift_ID OUTPUT,@Is_Half_Day	output,@Week_Day OUTPUT,@Half_St_Time OUTPUT,@Half_END_Time	output,@Half_Dur OUTPUT
				
					SET @Shift_Sec = 0     
					SET @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur)      
					SET @Shift_St_Sec = dbo.F_Return_Sec(@Shift_St_Time)      
					SET @Shift_En_Sec = dbo.F_Return_Sec(@Shift_END_Time)      
			 
					--Ankit 12112013
					SET @Second_Break_Duration_Sec = 0
					SET @Third_Break_Duration_Sec = 0
					SET @Second_Break_Duration_Sec = dbo.F_Return_Sec(@Second_Break_Duration)
					SET @Third_Break_Duration_Sec = dbo.F_Return_Sec(@Third_Break_Duration)
					--Ankit 12112013	
					    
					IF @Report_call ='Simsona'
						BEGIN
							 SET @Shift_Sec = @Shift_Sec - @Second_Break_Duration_Sec -- Added by rohit for simsona on 28102015
							 SET @Shift_Dur =  dbo.f_return_hours(@Shift_Sec)      
						END --add by sumit 18112015  
					SET @Leave_Name = ''  
					SET @Leave_Reason = ''  
					SET @Leave_ID = 0  
					SET @Leave_Period = 0
					SET @Half_Leave_Date = ''
					SET @Leave_Assign_As =''
			   
					SET @Fix_OT = 86400 - @Shift_Sec       
					SET @Day_St_Time = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + '00:00'  AS smalldatetime)  
					SET @Shift_St_Datetime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_St_Time AS smalldatetime)      
					SET @Temp_Date = dateadd(d,1,@Temp_Month_Date)      
					SET @Day_END_Time = CAST(CAST(@Temp_Date AS VARCHAR(11)) + ' ' + '00:00'  AS smalldatetime)      
					IF @Shift_St_Sec > @Shift_En_Sec       
						SET @Shift_END_DateTime = CAST(CAST(@Temp_Date AS VARCHAR(11)) + ' ' + @Shift_END_Time  AS smalldatetime)      
					ELSE      
						SET @Shift_END_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @Shift_END_Time  AS smalldatetime)      
			             
					SET @Insert_IN_DATE = NULL      
					SET @Insert_Out_DATE = NULL      

					--SELECT @Insert_In_Date = Min(In_Time) FROM T0150_emp_inout_record WHERE Emp_ID  = @Emp_ID and For_Date = @Temp_Month_Date      
					--SELECT @Insert_Out_Date = Out_Time  FROM T0150_emp_inout_record WHERE Emp_ID = @Emp_ID and In_Time = @Insert_In_Date      

					DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT
					SET @First_In_Last_Out_For_InOut_Calculation = 0 
					--SELECT @First_In_Last_Out_For_InOut_Calculation= ISNULL(First_In_Last_Out_For_InOut_Calculation,0) FROM dbo.T0040_GENERAL_SETTING 
					--WHERE Cmp_ID = @Cmp_ID and Branch_ID = (SELECT Branch_ID FROM dbo.T0080_EMP_MASTER WHERE Emp_ID=@Emp_ID)

					--Commented and Changed by Ramiz on 07102014
					DECLARE @branch_id_new AS NUMERIC
					DECLARE @Tras_Week_ot AS NUMERIC
					SELECT @branch_id_new = Branch_ID FROM dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID=@Emp_ID
					SELECT @First_In_Last_Out_For_InOut_Calculation= ISNULL(First_In_Last_Out_For_InOut_Calculation,0),
					@Tras_Week_ot = ISNULL(Tras_Week_ot,0) --Added by nilesh patel on 12082015 
					FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
					WHERE Cmp_ID = @Cmp_ID and Branch_ID = @branch_id_new 
							and For_Date = ( SELECT max(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date and Branch_ID = @Branch_ID_new and Cmp_ID = @Cmp_ID)
					
					
					
					 --ENDed by Ramiz on 07102014

					-- Added by nilesh on 22122014 For Rotation AttENDance Dashboard --Start
					IF @InOut_Tag = 'D' 
						BEGIN
							SET @First_In_Last_Out_For_InOut_Calculation = 1
						END 
					-- Added by nilesh on 22122014 For Rotation AttENDance Dashboard --END

					IF @Report_call ='Inout_Page' --added by Hardik 13/10/2012 for In Out Record Page
						SET @First_In_Last_Out_For_InOut_Calculation = 0

					IF @Report_call ='Time_Loss' --Added By Ramiz AS Time Loss is only Useful when First In Last Out is Not ticked
						SET @First_In_Last_Out_For_InOut_Calculation = 0
						
					IF @Report_call ='Time_Card'--added by chetan 07102017 for time card report 
						SET @First_In_Last_Out_For_InOut_Calculation = 1
						
					IF @Report_call ='Time_Card_Cera'-- ADDED BY RAJPUT ON 19072018
						SET @First_In_Last_Out_For_InOut_Calculation = 1
											

	
				--	IF @First_In_Last_Out_For_InOut_Calculation = 1
				--		BEGIN      							
				--			DECLARE cur_Inout CURSOR FOR       
				--			SELECT	MIN(In_time),CASE WHEN Max_In > MAX(Out_Time) THEN Max_In ELSE MAX(Out_time) END ,CASE WHEN ISNULL(e.Chk_By_Superior,0)=1 THEN MAX(Reason) ELSE '' END AS Reason,
				--					CASE WHEN ISNULL(e.Chk_By_Superior,0)=1 THEN MAX(Other_Reason) ELSE '' END AS Other_Reason  --Added By Jaina 12-09-2015 Other Reason
				--			from	dbo.T0150_emp_inout_record e Inner Join  
				--					(SELECT Max(In_time) Max_In,Emp_Id,For_Date FROM dbo.T0150_emp_inout_record WHERE Emp_ID =@Emp_ID 
				--						and For_Date = @Temp_Month_Date Group by Emp_ID,For_Date) m
				--					on e.Emp_ID = M.Emp_ID and E.For_Date = M.For_Date
				--					inner join T0080_Emp_Master EM on EM.Emp_ID=e.Emp_ID and EM.Cmp_ID= e.cmp_ID
				--					WHERE E.Emp_ID =@Emp_ID							
				--					--and E.For_Date = ISNULL(EM.Emp_left_date,@Temp_Month_Date) 
				--					and E.For_Date = @Temp_Month_Date 
				--					--Commented below condition by Hardik 04/10/2016 AS IF apply for attENDance regularise but not approved then it should display his actual in Out entries
				--					--and ((ISNULL(e.Chk_By_Superior,0)=1 and not e.App_Date IS NULL) OR (e.app_date IS NULL))   ---added by jimit 10092016 attENDace regularize record is not showing when pENDing OR reject the record 
				--					group by Max_In,e.Chk_By_Superior								
								
				--		END
				--ELSE
				--	BEGIN						
				--		DECLARE cur_Inout CURSOR FOR
				--		SELECT	In_time,Out_Time,CASE WHEN ISNULL(Chk_By_Superior,0)=1 THEN Reason ELSE '' END AS Reason,
				--				CASE WHEN ISNULL(Chk_By_Superior,0)=1 THEN Other_Reason ELSE '' END AS other_reason 
				--		FROM	dbo.T0150_emp_inout_record e 
				--				INNER JOIN T0080_Emp_Master EM on EM.Emp_ID=e.Emp_ID and EM.Cmp_ID= e.cmp_ID
				--		WHERE	e.Emp_ID =@Emp_ID and For_Date = @Temp_Month_Date      --Added By Jaina 12-09-2015 Other Reason
				--		ORDER BY ISNULL(In_time,Out_time),Out_time,Reason    
				--	END
				TRUNCATE TABLE #IN_OUT
				
				
				IF @First_In_Last_Out_For_InOut_Calculation = 1
					INSERT	INTO #IN_OUT
					SELECT	IN_TIME,OUT_TIME,REASON,OTHER_REASON,T.Half_Full_day						
					FROM	#DATA D 
							LEFT OUTER JOIN (SELECT MAX(REASON) AS REASON, MAX(OTHER_REASON) AS OTHER_REASON, EMP_ID ,T.Half_Full_day  --Change by Jaina 08-03-2018
											 FROM T0150_EMP_INOUT_RECORD T WITH (NOLOCK)
											 WHERE	EMP_ID=@EMP_ID AND FOR_DATE=@TEMP_MONTH_DATE 
											 GROUP BY EMP_ID,Half_Full_day) T ON D.EMP_ID=T.EMP_ID
					WHERE	D.EMP_ID=@EMP_ID AND D.FOR_DATE=@TEMP_MONTH_DATE 
					ORDER BY ISNULL(IN_TIME,OUT_TIME),OUT_TIME,REASON
				ELSE
					INSERT	INTO #IN_OUT
					SELECT	EIR.IN_TIME,EIR.OUT_TIME,REASON,OTHER_REASON,EIR.Half_Full_day  --Change by Jaina 08-03-2018				
					FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)
							--INNER JOIN 	#DATA D ON ISNULL(EIR.IN_TIME,EIR.OUT_TIME) >= ISNULL(D.IN_TIME,D.OUT_TIME) AND ISNULL(EIR.OUT_TIME,EIR.IN_TIME) <= ISNULL(D.OUT_TIME,D.IN_TIME) AND D.EMP_ID=EIR.EMP_ID
							INNER JOIN 	#DATA D ON D.EMP_ID=EIR.EMP_ID AND EIR.In_Time Between D.In_Time AND IsNull(D.Out_Time, DateAdd(HH, 8 , D.In_Time))
					WHERE	EIR.EMP_ID=@EMP_ID AND D.FOR_DATE=@TEMP_MONTH_DATE 
					ORDER BY ISNULL(EIR.IN_TIME,EIR.OUT_TIME),EIR.OUT_TIME,REASON,EIR.Half_Full_day
					
			     
				DECLARE cur_Inout CURSOR FOR
				SELECT IN_TIME,OUT_TIME,REASON,OTHER_REASON,Half_Full_day FROM #IN_OUT
				OPEN cur_inout      
				FETCH NEXT FROM cur_inout INTO @Insert_In_Date,@Insert_Out_Date,@Reason,@Other_Reason,@Half_Full_day   --Change by Jaina 08-03-2018
				WHILE @@FETCH_STATUS = 0      
					BEGIN      
						SET @working_sec = 0      
						SET @Ot_sec = 0      
						SET @holiday_work_sec = 0      
						SET @Late_In = ''      
						SET @Late_Out =''      
						SET @Early_In = ''      
						SET @Early_Out = ''      
						SET @WORKING_HOURS = ''      
						SET @INSERT_COUNT = 0      
						    
						SET @Late_In_sec = 0      
						SET @Late_Out_Sec = 0      
						SET @Early_In_sec = 0      
						SET @Early_Out_sec = 0      
						SET @Toatl_Working_sec = 0      
						SET @Less_Work = ''      
						SET @More_Work = ''      
						SET @Total_work = ''      
						SET @late_in_count = 0      
						SET @Early_Out_Count = 0      
						SET @Total_less_work_sec = 0      
						SET @Total_More_work_sec = 0
						SET @p_Days = 0 -- Added by rohit on 08082016
						   
						SET @Working_sec = ISNULL(DATEDIFF(s,@Insert_In_Date,@Insert_Out_Date),0)
						SET @Working_sec = dbo.F_Return_Without_Sec(@Working_sec) --Added by Sumit 16102015

						IF DATEDIFF(s,@Insert_In_Date,@Shift_St_Datetime) > 0       
							SET @Early_In_Sec = DATEDIFF(s,@Insert_In_Date,@Shift_St_Datetime)      
						IF DATEDIFF(s,@Insert_In_Date,@Shift_St_Datetime) < 0       
							SET @late_In_Sec = DATEDIFF(s,@Insert_In_Date,@Shift_St_Datetime)      
						IF DATEDIFF(s,@Insert_Out_Date,@Shift_END_Datetime) > 0       
							SET @Early_Out_Sec = DATEDIFF(s,@Insert_Out_Date,@Shift_END_Datetime)      
						IF DATEDIFF(s,@Insert_Out_Date,@Shift_END_Datetime) < 0       
							SET @Late_Out_Sec = DATEDIFF(s,@Insert_Out_Date,@Shift_END_Datetime)      
	      
						SET @late_In_Sec  = @late_In_Sec * -1      
						SET @Late_Out_Sec  = @Late_Out_Sec * -1      
						
						IF @Report_call='Employee Wise Latemark'
							BEGIN
								IF @Late_Comm_sec > 0
								SET  @late_In_Sec = isnull(@late_In_Sec,0) - ISNULL(@Late_Comm_sec,0)
							END  

						SET @Toatl_Working_sec = ISNULL(@Toatl_Working_sec,0) + @Working_sec      
			          
						--Ankit Start 12112013
						DECLARE @DeduHour_SecondBreak AS TINYINT
						DECLARE @DeduHour_ThirdBreak AS TINYINT
						DECLARE @S_St_Time AS VARCHAR(10)      
						DECLARE @S_END_Time AS VARCHAR(10)     
						DECLARE @T_St_Time AS VARCHAR(10)      
						DECLARE @T_END_Time AS VARCHAR(10)     
						DECLARE @Shift_S_ST_DateTime AS DATETIME
						DECLARE @Shift_S_END_DateTime AS DATETIME      
						DECLARE @Shift_T_ST_DateTime AS DATETIME     
						DECLARE @Shift_T_END_DateTime AS DATETIME      
						DECLARE @Shift_Max_Outtime AS DATETIME
						--	DECLARE @HalfDayDate1 VARCHAR(500)  --added By Mukti 28112014 
						DECLARE @HalfDayDate VARCHAR(500)  
						
						
						
						SELECT @DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_END_Time=S_END_Time,@T_St_Time=T_St_Time,@T_END_Time=T_END_Time
						FROM dbo.T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
							
						SET @Shift_S_ST_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS smalldatetime)
						SET @Shift_S_END_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_END_Time AS smalldatetime)
						SET @Shift_T_ST_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_St_Time AS smalldatetime)
						SET @Shift_T_END_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_END_Time AS smalldatetime)
						
						

						--EXEC dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate OUTPUT --added By Mukti 28112014 
												
						IF not (charindex(CONVERT(nvarchar(11),@Insert_In_Date,109),@HalfDayDate) > 0)  --added By Mukti 28112014 
							BEGIN   
								IF @DeduHour_SecondBreak = 1 And  @DeduHour_ThirdBreak = 1 
	   								BEGIN	   	
	   									IF @DeduHour_SecondBreak = 1 And @Insert_In_Date < @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
											BEGIN
				 								SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
											END

										IF @DeduHour_ThirdBreak = 1 And @Insert_In_Date < @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
											BEGIN
												SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec	
											END
									END	
								ELSE IF @DeduHour_SecondBreak = 1 And @Insert_In_Date < @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
									BEGIN
		 								SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
		 							END
								ELSE IF @DeduHour_ThirdBreak = 1 And @Insert_In_Date < @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
									BEGIN
										SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec
									END
							END						
				
						--Ankit END 12112013  
	                   
						IF @Toatl_Working_sec > 0 
							EXEC dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work OUTPUT         
	                           
						IF @Insert_IN_Date > @Shift_END_datetime      
							BEGIN      
								SET @Working_Sec_AfterShift = @Working_sec + @Working_Sec_AfterShift      
								SET @Working_AfterShift_Count =  1      
							END
	           
						--SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
						--Ankit start 13112013
						DECLARE @OT_Start_ShiftEND_Time AS VARCHAR(10)
						DECLARE @OT_Start_ShiftStart_Time AS VARCHAR(10)
						
						SET @OT_Start_ShiftEND_Time = ''	
						SET @OT_Start_ShiftStart_Time = ''
				  
				 
						Select	@OT_Start_ShiftStart_Time=OT_Start_Time, @OT_Start_ShiftEND_Time = OT_END_Time 
						from	T0050_SHIFT_DETAIL WITH (NOLOCK)
						WHERE	Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID	
				
						--SELECT @OT_Start_ShiftStart_Time,@OT_Start_ShiftEND_Time, FROM T0050_SHIFT_DETAIL WHERE Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
						--return
						IF @OT_Start_ShiftStart_Time = 1
							BEGIN
								DECLARE @OT_Start_ShiftStart_Sec NUMERIC
								SET @OT_Start_ShiftStart_Sec =0
		
								IF DATEDIFF(s,@Insert_In_Date,@Shift_ST_DateTime) > 0       
									BEGIN
										SET @OT_Start_ShiftStart_Sec = DATEDIFF(s,@Insert_In_Date,@Shift_ST_DateTime)
							
										SET @Toatl_Working_sec = @Toatl_Working_sec - @OT_Start_ShiftStart_Sec
									END
							END
			
						IF @DeduHour_SecondBreak = 0 AND @DeduHour_ThirdBreak = 0
							SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec
						IF @DeduHour_SecondBreak = 1 AND @DeduHour_ThirdBreak = 0
							SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec --+ @Second_Break_Duration_Sec
						IF @DeduHour_ThirdBreak = 1  And @DeduHour_SecondBreak = 0
							SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec  --+ @Third_Break_Duration_Sec
						IF @DeduHour_SecondBreak = 1 And @DeduHour_ThirdBreak = 1
							SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec --+ @Second_Break_Duration_Sec  + @Third_Break_Duration_Sec
							
							

						IF @OT_Start_ShiftStart_Time = 1
							BEGIN
								SET @Toatl_Working_sec = @Toatl_Working_sec + ISNULL(@OT_Start_ShiftStart_Sec,0)
							END
				
						IF @OT_Start_ShiftEND_Time = 1
							BEGIN
						
						SET @OT_Start_ShiftEND_Sec = 0

						IF @First_In_Last_Out_For_InOut_Calculation = 1
							BEGIN
								IF DATEDIFF(s,@Insert_Out_Date,@Shift_END_Datetime) < 0  
									SET @OT_Start_ShiftEND_Sec = DATEDIFF(s,@Shift_END_Datetime,@Insert_Out_Date)
							END
						ELSE
							BEGIN
								SELECT	@OT_Start_ShiftEND_Sec = SUM(Diff_Sec) 
								FROM	(SELECT	CASE WHEN Row = 1 
													THEN DATEDIFF(s,@Shift_END_Datetime,Out_Time)
												ELSE 
													DATEDIFF(s,In_Time,Out_Time)
												END AS Diff_Sec 
										From	(
													SELECT	ROW_NUMBER() OVER (ORDER BY IO_Tran_Id) AS Row, * 
													FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
													WHERE	Emp_ID = @Emp_ID AND (In_Time >= @Shift_END_Datetime OR Out_Time >= @Shift_END_Datetime)
															AND For_Date = @Temp_Month_Date And Emp_ID = @Emp_ID
												) AS Qry
										) AS Qry1						
							END
							
							
						
						IF @OT_Start_ShiftEND_Sec > 0
							SET @Diff_Sec = @OT_Start_ShiftEND_Sec	
						ELSE
							SET @Diff_Sec = 0					
					END
				--Ankit END 13112013 
			  
			         
				---Hardik 21/11/2011 for Half day shift  
				DECLARE @WeekDay VARCHAR(10)  
				DECLARE @HalfStartTime VARCHAR(10)  
				DECLARE @HalfENDTime VARCHAR(10)  
				DECLARE @HalfDuration VARCHAR(10)  

				DECLARE @curForDate DATETIME  
				DECLARE @HalfMinDuration VARCHAR(10)  
				DECLARE @HalfStartDateTime DATETIME  
				DECLARE @HalfENDDateTime DATETIME  
	   
	   
				SELECT	@WeekDay=SM.Week_Day,@HalfStartTime=SM.Half_St_Time,@HalfENDTime=SM.Half_END_Time,@HalfDuration=SM.Half_Dur,@HalfMinDuration=SM.Half_min_duration 
				FROM	dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK)
				WHERE	Is_Half_Day = 1 and SM.Shift_ID=@SHIFT_ID
	    
				SET @HalfStartDateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @HalfStartTime AS smalldatetime)      
				SET @HalfENDDateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @HalfENDTime  AS smalldatetime)      
				
				
				
				SELECT	@P_Days = ISNULL(Calculate_Days,0) 
				FROM	T0050_SHIFT_DETAIL WITH (NOLOCK)
				WHERE	Shift_ID =@shift_id and (Replace(dbo.F_Return_Hours(@Toatl_Working_sec),':','.')) > From_Hour and (Replace(dbo.F_Return_Hours(@Toatl_Working_sec),':','.')) <= To_Hour -- Added by Hardik 07/09/2017
				--WHERE	Shift_ID =@shift_id and (@Working_sec/3600) > From_Hour and (@Working_sec/3600) <= To_Hour -- Added by rohit on 08082016   
				
				--Added by Jaina 08-03-2018
				IF isnull(@Half_Full_day,'') <> '' and isnull(@Reason,'') <> ''
				BEGIN
					if @Half_Full_day = 'Full Day'
						set @p_Days = 1
					else
						set @p_Days = 0.5
					
				END
	  
				IF(CHARINDEX(CONVERT(NVARCHAR(11),@Insert_In_Date,109),@HalfDayDate) > 0)  
					BEGIN      
					
						SET @Diff_Sec  = @Toatl_Working_sec -  dbo.F_Return_Sec(@HalfDuration)      
	  
						SET @Late_In_sec = 0      
						SET @Late_Out_Sec = 0      
						SET @Early_In_sec = 0      
						SET @Early_Out_sec = 0    
	            
						IF DATEDIFF(s,@Insert_In_Date,@HalfStartDateTime) > 0       
							SET @Early_In_Sec = DATEDIFF(s,@Insert_In_Date,@HalfStartDateTime)      
						IF DATEDIFF(s,@Insert_In_Date,@HalfStartDateTime) < 0       
							SET @late_In_Sec = DATEDIFF(s,@Insert_In_Date,@HalfStartDateTime)      
						IF DATEDIFF(s,@Insert_Out_Date,@HalfENDDateTime) > 0       
							SET @Early_Out_Sec = DATEDIFF(s,@Insert_Out_Date,@HalfENDDateTime)      
						IF DATEDIFF(s,@Insert_Out_Date,@HalfENDDateTime) < 0       
							SET @Late_Out_Sec = DATEDIFF(s,@Insert_Out_Date,@HalfENDDateTime)      
	  
			
						SET @Shift_St_Time = @HalfStartTime
			
						SET @Shift_END_Time = @HalfENDTime
			
						SET @shift_Dur= @Half_Dur       
				
						SET @Shift_Sec = 0     
						SET @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur) 
	        
						SET @late_In_Sec  = @late_In_Sec * -1      
						SET @Late_Out_Sec  = @Late_Out_Sec * -1     
	      
						IF @Working_sec >= dbo.F_Return_Sec(@HalfMinDuration)-- Added by rohit on 08082016
							SET @p_Days = 1
						ELSE
							SET @p_Days = 0 

					END         
	    
				-- Added By Rohit On 08102014 for Inductotherm late not Calculate on Week off
				IF @Is_Late_Calc_On_HO_WO=0
					BEGIN		  
						IF(CHARINDEX(CONVERT(NVARCHAR(11),@Insert_In_Date,109),@StrWeekoff_Date) > 0)  
							BEGIN
								SET @Late_In_sec = 0      
								SET @Late_Out_Sec = 0      
							END    
					END
	  
				IF @Is_Early_Calc_On_HO_WO=0
					BEGIN
						IF(CHARINDEX(CONVERT(NVARCHAR(11),@Insert_In_Date,109),@StrWeekoff_Date) > 0)  
							BEGIN      
								SET @Early_In_sec = 0      
								SET @Early_Out_sec = 0    
							END    
					END
				--ENDed by rohit on 08102014
	    
				------------ END for Half shift  
				-- Added by rohit on 21082014
				IF @Late_Comm_sec >=  @late_in_sec   
					SET @late_in_sec  = 0      
				IF @Late_Comm_sec >=  @late_out_sec  
					SET @late_out_sec  = 0      
				IF @Early_Limit_sec >=  @Early_In_Sec  
					SET @Early_In_Sec  = 0      
				IF @Early_Limit_sec >=  @Early_Out_Sec 
					SET  @Early_Out_Sec  = 0      
	                  
				IF @late_in_sec  > 0  
					EXEC dbo.Return_DurHourMin  @late_In_Sec ,@late_In OUTPUT       
				IF @late_out_sec > 0  
					EXEC dbo.Return_DurHourMin  @late_Out_Sec ,@late_Out OUTPUT       
	                  
				IF @Early_In_Sec  > 0 
					EXEC dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In OUTPUT
				IF @Early_Out_Sec > 0 
					EXEC dbo.Return_DurHourMin  @Early_Out_Sec ,@Early_Out OUTPUT       
				IF @Working_sec > 0 
					EXEC dbo.Return_DurHourMin  @Working_Sec ,@WORKING_HOURS OUTPUT    
	      
	     
				IF @Diff_Sec < 0
					BEGIN  
						SET @Diff_Sec = @Diff_Sec * -1
						EXEC dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec OUTPUT
						SET @Diff_Sec = @Diff_Sec * -1
					END
				ELSE
					BEGIN
						EXEC dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec OUTPUT
					END
					
					
				
				IF  @Diff_Sec > 0  And @Diff_Sec > @Emp_OT_Min_Limit_Sec And (@Emp_OT = 1 OR @Monthly_Deficit_Adjust_OT_Hrs = 1)
					BEGIN
				
						IF @Diff_Sec < @Emp_OT_Max_Limit_Sec OR @Emp_OT_Max_Limit_Sec = 0
							BEGIN
								EXEC dbo.Return_DurHourMin @Diff_Sec , @More_Work OUTPUT  
								SET @Total_More_work_sec = @Diff_Sec  
								
							END
						ELSE
							BEGIN
								EXEC dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work OUTPUT  
								SET @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
							END
						
					END
				ELSE IF @Diff_Sec <  0 and @Toatl_Working_sec > 0 And (@Emp_OT = 1 OR @Monthly_Deficit_Adjust_OT_Hrs = 1)     
					BEGIN      
						SET @Diff_Sec = @Diff_Sec * -1      
						SET @Total_Less_Work_Sec = @Diff_Sec      
						EXEC dbo.Return_DurHourMin @Diff_Sec , @less_Work OUTPUT       
						
					END       
	      
	      		
				IF @late_in_Sec > 0       
					SET @Late_in_count =1       
				IF @Early_Out_Sec > 0      
					SET @Early_Out_Count = 1       
	       
				---Hardik 13/12/2013 for Pakistan
				IF UPPER(@Country_Name) = 'PAKISTAN'
					BEGIN
						SET @Chk_by_Superior =0
						SET @Half_Full_Day =''
						SET @Is_Cancel_Late_In =0
						SET @Is_Cancel_Early_Out =0
						
						SELECT	@Chk_by_Superior = ISNULL(Chk_by_Superior,0),
								@Half_Full_Day = ISNULL(Half_Full_Day,''),
								@Is_Cancel_Late_In = ISNULL(Is_Cancel_Late_In,0),
								@Is_Cancel_Early_Out= ISNULL(Is_Cancel_Early_Out,0)
						FROM	dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK)
						WHERE	In_Time = @Insert_IN_DATE And Emp_ID = @Emp_ID
					
						IF @Chk_by_Superior = 1
							BEGIN
								IF @Half_Full_Day = 'Full Day'
									BEGIN
										SET @Insert_IN_DATE =''
										SET @Insert_Out_DATE = ''
										SET @working_Hours = @Shift_Dur
										SET @working_sec = @Shift_Sec
										SET @Total_Work = @Shift_Dur
										SET @Toatl_Working_sec = @Shift_Sec
										SET @Less_Work = '-'
										SET @Total_less_work_sec = 0
										SET @More_Work = '-'
										SET @Total_More_work_sec = 0
									END
								ELSE IF @Half_Full_Day = 'First Half' OR @Half_Full_Day = 'Second Half'
									BEGIN
										SET @Insert_IN_DATE =''
										SET @Insert_Out_DATE = ''
										SET @working_Hours = dbo.F_Return_Hours(@Shift_Sec/2)
										SET @working_sec = @Shift_Sec/2
										SET @Total_Work = dbo.F_Return_Hours(@Shift_Sec/2)
										SET @Toatl_Working_sec = @Shift_Sec/2
										SET @Less_Work = '-'
										SET @Total_less_work_sec = 0
										SET @More_Work = '-'
										SET @Total_More_work_sec = 0
									END
								
								IF @Is_Cancel_Late_In = 1 
									BEGIN
										SET @Late_In =''
										SET @Late_In_Sec = 0
										SET @Late_In_Count = 0
									END

								IF @Is_Cancel_Early_Out = 1 
									BEGIN
										SET @Early_Out =''
										SET @Early_Out_Sec = 0
										SET @Early_out_count = 0
									END
							END
					END
				---END for Hardik 13/12/2013 for Pakistan
	      
				---Hardik for Total Work show only in Last row (IF Multiple In-Out Entries)  
				IF EXISTS(SELECT EI.Emp_ID FROM #Emp_Inout AS EI WHERE EI.Emp_ID = @Emp_ID AND EI.For_DAte = @temp_Month_DAte )  
					BEGIN  
						SELECT	@Toatl_Working_sec = ISNULL(SUM(Duration_Sec) ,0)  
						FROM	#Emp_Inout AS EI  
						WHERE	EI.Emp_ID = @Emp_ID AND EI.For_DAte = @temp_Month_DAte  
	     
						SELECT	@Working_Sec_AfterShift = ISNULL(SUM(Working_Sec_AfterShift) ,0)  
						FROM	#Emp_Inout AS EI  
						WHERE	EI.Emp_ID = @Emp_ID and EI.For_DAte = @temp_Month_DAte  
								and EI.In_Time >= @Shift_END_datetime  
	       
						SET @Toatl_Working_sec = ISNULL(@Toatl_Working_sec,0) + @Working_sec      
		  
						--Ankit Start 12112013
  						DECLARE @Min_In_Time AS DATETIME
						SELECT	@Min_In_Time = MIN(In_Time) 
						FROM	#Emp_Inout AS EI 
						WHERE	EI.Emp_ID = @Emp_ID  AND EI.For_DAte = @temp_Month_Date 

						SELECT	@DeduHour_SecondBreak = DeduHour_SecondBreak,@DeduHour_ThirdBreak = DeduHour_ThirdBreak ,@S_St_Time=S_St_Time,@S_END_Time=S_END_Time,@T_St_Time=T_St_Time,@T_END_Time=T_END_Time
						FROM	dbo.T0040_SHIFT_MASTER WITH (NOLOCK)
						WHERE	Cmp_ID=@Cmp_ID And Shift_ID=@SHIFT_ID
					
						SET @Shift_S_ST_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_St_Time AS SMALLDATETIME)
						SET @Shift_S_END_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @S_END_Time AS SMALLDATETIME)
						SET @Shift_T_ST_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_St_Time AS SMALLDATETIME)
						SET @Shift_T_END_DateTime = CAST(CAST(@Temp_Month_Date AS VARCHAR(11)) + ' ' + @T_END_Time AS SMALLDATETIME)
						

						IF @DeduHour_SecondBreak = 1 AND @DeduHour_ThirdBreak = 1 
	   						BEGIN
				   	
	   							IF @DeduHour_SecondBreak = 1 AND @Min_In_Time <= @Shift_S_ST_DateTime AND @Insert_Out_DATE > @Shift_S_ST_DateTime
									BEGIN
				 						SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
									END

								IF @DeduHour_ThirdBreak = 1 AND @Min_In_Time <= @Shift_T_ST_DateTime AND @Insert_Out_DATE > @Shift_T_ST_DateTime
									BEGIN
										SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec	
									END
							END	
						ELSE IF @DeduHour_SecondBreak = 1 And @Min_In_Time <= @Shift_S_ST_DateTime And @Insert_Out_DATE > @Shift_S_ST_DateTime
							BEGIN
		 						SET @Toatl_Working_sec = @Toatl_Working_sec - @Second_Break_Duration_Sec
							END
						ELSE IF @DeduHour_ThirdBreak = 1 And @Min_In_Time <= @Shift_T_ST_DateTime And @Insert_Out_DATE > @Shift_T_ST_DateTime
							BEGIN
								SET @Toatl_Working_sec = @Toatl_Working_sec - @Third_Break_Duration_Sec
							END
						--Ankit END 12112013			
						
					
						IF @Toatl_Working_sec > 0 
							EXEC dbo.Return_DurHourMin  @Toatl_Working_sec ,@Total_work OUTPUT         
	  
						--SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec       
						--Ankit 14112013	
		   
  						IF @OT_Start_ShiftEND_Time = 1
							BEGIN
								SET @OT_Start_ShiftEND_Sec = 0

								IF @First_In_Last_Out_For_InOut_Calculation = 1
									BEGIN
										IF DATEDIFF(s,@Insert_Out_Date,@Shift_END_Datetime) < 0  
											BEGIN     
												SET @OT_Start_ShiftEND_Sec = DATEDIFF(s,@Shift_END_Datetime,@Insert_Out_Date)
											END
									END
								ELSE
									BEGIN
										SELECT	@OT_Start_ShiftEND_Sec = SUM(Diff_Sec) 
										FROM	(SELECT	CASE WHEN Row =1 
															THEN DATEDIFF(s,@Shift_END_Datetime,Out_Time)
														ELSE 
															DATEDIFF(s,In_Time,Out_Time)
														END AS Diff_Sec 
												FROM	(SELECT ROW_NUMBER() OVER (ORDER BY IO_Tran_Id) AS Row, * 
														FROM	T0150_EMP_INOUT_RECORD WITH (NOLOCK)
														WHERE	Emp_ID = @Emp_ID AND (In_Time >= @Shift_END_Datetime OR Out_Time >= @Shift_END_Datetime)
																AND For_Date = @Temp_Month_Date AND Emp_ID = @Emp_ID
														) AS Qry
												) AS Qry1						
									END						
								IF @OT_Start_ShiftEND_Sec > 0
									SET @Diff_Sec = @OT_Start_ShiftEND_Sec	- @OT_Start_ShiftStart_Sec
								ELSE
									SET @Diff_Sec = 0
							END
							
						ELSE
							SET @Diff_Sec  = @Toatl_Working_sec -  @Shift_Sec - ISNULL(@OT_Start_ShiftStart_Sec	,0)
				
		  		
						IF @Diff_Sec < 0
							BEGIN  
								SET @Diff_Sec = @Diff_Sec * -1
								EXEC dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec OUTPUT
								SET @Diff_Sec = @Diff_Sec * -1
							END
						ELSE
							EXEC dbo.Return_Without_Sec @Diff_Sec,@Diff_Sec OUTPUT

						IF  @Diff_Sec > 0 AND @Diff_Sec > @Emp_OT_Min_Limit_Sec AND (@Emp_OT = 1 OR @Monthly_Deficit_Adjust_OT_Hrs = 1)
							BEGIN
								IF @Diff_Sec < @Emp_OT_Max_Limit_Sec OR @Emp_OT_Max_Limit_Sec = 0
									BEGIN
										EXEC dbo.Return_DurHourMin @Diff_Sec , @More_Work OUTPUT  
										SET @Total_More_work_sec = @Diff_Sec      
										SET @less_Work = ''
										SET @Total_Less_Work_Sec =0
									END
								ELSE
									BEGIN
										EXEC dbo.Return_DurHourMin @Emp_OT_Max_Limit_Sec , @More_Work OUTPUT  
										SET @Total_More_work_sec = @Emp_OT_Max_Limit_Sec      
										SET @less_Work = ''
										SET @Total_Less_Work_Sec =0
									END
							END
						ELSE IF @Diff_Sec <  0 and @Toatl_Working_sec > 0  And (@Emp_OT = 1 OR @Monthly_Deficit_Adjust_OT_Hrs = 1)    
							BEGIN      
								SET @Diff_Sec = @Diff_Sec * -1      
								SET @Total_Less_Work_Sec = @Diff_Sec      
								EXEC dbo.Return_DurHourMin @Diff_Sec,@less_Work OUTPUT
								SET @More_Work = ''
								SET @Total_More_work_sec =0
							END       
						--ELSE IF condition added by Hardik 18/11/2013 for Diff_Sec zero
						ELSE IF @Diff_Sec = 0
							BEGIN
								SET @less_Work = ''
								SET @More_Work = ''
								SET @Total_More_work_sec =0
								SET @Total_Less_Work_Sec =0
							END
		
						UPDATE	#Emp_Inout     
						SET		Late_out = '',
								Early_Out = '',
								Total_Work = '',
								less_work = '',
								More_work = '',
								Early_Out_sec = 0,
								Total_Less_work_sec = 0,
								Total_More_work_Sec = 0,
								Early_Out_count = 0,
								Total_Work_Sec =0      
						WHERE	Emp_ID = @emp_Id and For_Date = @temp_month_Date  
				 
						IF @Report_call='Simsona' --Condtions Added by Sumit 18112015
							BEGIN
								UPDATE	#Emp_Inout     
								SET		Shift_Sec=0,
										Shift_Dur=null
								WHERE	Emp_ID = @emp_Id AND For_Date = @temp_month_Date		
							END
					END   
				------------ END for Hardik 
		
		       
				---------------------------------------------------------              
				IF (@Total_work <>'' OR @Total_work<>'00:00')
					BEGIN
						DECLARE @ttl_work_sec AS NUMERIC(18,0)
						
						IF (@Shift_Sec >=@Toatl_Working_sec)
							BEGIN
							
								SET @ttl_work_sec=@Shift_Sec-@Toatl_Working_sec
								EXEC Return_DurHourMin @ttl_work_sec , @less_Work OUTPUT
								IF (@less_Work<>'' OR @less_work <> '00:00')
								BEGIN
									SET @Total_Less_Work_Sec=@ttl_work_sec
								END
								
								
							END
						ELSE
							BEGIN
								IF (@Emp_OT = 1 OR @Monthly_Deficit_Adjust_OT_Hrs = 1)
									BEGIN
										
										SET @ttl_work_sec=@Toatl_Working_sec-@Shift_Sec
										EXEC Return_DurHourMin @ttl_work_sec,@More_Work OUTPUT
										IF (@More_Work<>'' OR @More_Work<>'00:00')
											BEGIN
												SET @total_more_work_sec=@ttl_work_sec
												SET @Total_Less_Work_Sec=0			
											END
									END	
							END	
					END --Added by Sumit 16102015 for Take Deficit hours even IF Emp OT yes OR NO and Sirplus will not calculate IF OT is not applicable
	    
				INSERT INTO #Emp_Inout (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration,
							Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,
							Other_Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime,
							Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,Total_Work_Sec,Late_Out_Sec,Early_In_sec,Total_More_work_Sec,
							Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,vertical_Id,subvertical_Id,p_Days,AB_LEAVE)     --added jimit 15062016             
				VALUES(@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,@Insert_IN_DATE ,@Insert_Out_DATE ,@working_Hours,      
						@working_sec,@late_In ,@late_Out , @Early_In , @Early_Out , '',@Shift_Sec,@Shift_Dur,@Total_Work,@Less_Work,@More_work,
						@Reason,@Other_Reason,@late_in_sec,@Early_Out_Sec,@Total_less_work_sec,@Late_in_Count,@Early_Out_count,@Shift_St_Time,
						@Shift_END_Time,@Working_Sec_AfterShift,@Working_AfterShift_Count,@Reason,ISNULL(@Toatl_Working_sec,0),ISNULL(@Late_Out_Sec,0),
						ISNULL(@Early_In_Sec,0),ISNULL(@Total_More_work_Sec,0),@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_comm_sec,@Branch_Id_Cur,
						@Vertical_Id,@SubVertical_Id,@P_Days,case when @Insert_IN_DATE IS NULL and @Insert_Out_DATE IS NULL then 'AB' ELSE NULL END)   --added jimit 15062016 --Added AB leave by Sumit on 27102016
						
		
				---Hardik for Total Work show only in Late in row (IF Multiple In-Out Entries)  
				IF EXISTS(SELECT EI.Emp_ID FROM #Emp_Inout AS EI WHERE EI.Emp_ID = @Emp_ID AND EI.For_DAte = @temp_Month_DAte )  
					BEGIN
						DECLARE @Late_In_N AS VARCHAR(10)  
	       
						SELECT	TOP(1) @Late_In_N = Late_In 
						FROM	#Emp_Inout AS EI 
						WHERE	EI.Emp_ID = @Emp_ID AND EI.For_DAte = @temp_Month_DAte 
	       
						IF @Late_In_N <> '' OR @Late_In_N <> '00:00'  
							BEGIN
								UPDATE	#Emp_Inout 
								SET		Late_In = '',Late_In_Sec = 0,Late_In_count=0  
								WHERE	Emp_ID = @emp_Id AND For_Date = @temp_month_Date AND Late_In <> @Late_In_N
							END
					END
				------------ END for Hardik   
	    
				--Hardik for Late In Hours show only on First Row (IF Multiple In-Out Entries)
				--DECLARE @Min_In_Time AS DATETIME	--Comment By Ankit 30112013 For Update Shift Break Deduction
				SET		@Min_In_Time = ''
				SELECT	@Min_In_Time = MIN(In_Time)
				FROM	#Emp_Inout AS EI 
				WHERE	EI.Emp_ID = @Emp_ID AND EI.For_DAte = @temp_Month_Date 
			       
				UPDATE	#Emp_Inout 
				SET		Late_In = '',Late_In_Sec = 0,Late_In_count=0  
				WHERE	Emp_ID = @emp_Id AND For_Date = @temp_month_Date AND In_Time <> @Min_In_Time
				------------ END for Hardik   
			                             
				Fetch next FROM cur_inout  into @Insert_In_Date,@Insert_Out_Date,@Reason,@Other_Reason,@Half_Full_day --Added By Jaina 12-09-2015     
			END      
		close cur_Inout      
		Deallocate cur_inout     
		-------------------------------------------------------------------------
		---------Added by Sumit 19092015-------------------------------------------------------------------

	  
	  
		DECLARE @Emp_ID_AutoShift numeric
		DECLARE @In_Time_Autoshift DATETIME
		DECLARE @Out_Time_Autoshift DATETIME
		DECLARE @New_Shift_ID numeric
		DECLARE @Shift_St_Time_Autoshift DATETIME
		DECLARE @Shift_END_Time_Autoshift AS DATETIME
		
		IF EXISTS(SELECT 1 FROM T0040_SHIFT_MASTER s WITH (NOLOCK) WHERE ISNULL(s.Inc_Auto_Shift,0) = 1 AND s.Cmp_ID=@Cmp_id)
			BEGIN
				DECLARE curautoshift CURSOR FAST_FORWARD FOR	                  
				SELECT	DISTINCT d.Emp_ID,Em.In_Time,d.Shift_ID,Em.Out_Time,CAST(CONVERT(VARCHAR(11),Em.in_Time,120) + s.Shift_St_Time AS DATETIME),
						CAST(CONVERT(VARCHAR(11),Em.out_time,120) + s.Shift_END_Time AS DATETIME) 
				FROM	T0100_EMP_SHIFT_DETAIL d WITH (NOLOCK)
						INNER JOIN T0040_SHIFT_MASTER s WITH (NOLOCK) ON d.Shift_ID = s.Shift_ID 
						INNER JOIN T0150_EMP_INOUT_RECORD EM WITH (NOLOCK) ON Em.Emp_ID=d.Emp_ID and d.Cmp_ID=Em.Cmp_ID
						INNER JOIN #Emp_Cons Ec ON EC.Emp_ID=d.Emp_ID
				WHERE	ISNULL(s.Inc_Auto_Shift,0) = 1 AND Em.For_Date >=@from_date and Em.For_Date<=@to_date
						AND (ISNULL(DATEDIFF(s, CAST(EM.In_Time AS DATETIME),CAST(CONVERT(VARCHAR(11),Em.in_Time,120) + s.Shift_St_Time AS DATETIME) ),0)  < -14300		
								or ISNULL(DATEDIFF(s,Em.in_Time,CAST(CONVERT(varchar(11),Em.in_Time,120) + s.Shift_St_Time AS DATETIME)),0) > 14300
							 )
						AND d.Cmp_ID=@Cmp_ID	
				ORDER BY d.Emp_ID 
			
				OPEN	curautoshift                      
				FETCH NEXT FROM curautoshift INTO @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID,@Out_Time_Autoshift,@Shift_St_Time_Autoshift,@Shift_END_Time_Autoshift
			              
				WHILE @@FETCH_STATUS = 0                    
					BEGIN   
						DECLARE @Shift_ID_Autoshift numeric
						DECLARE @Shift_start_time_Autoshift VARCHAR(12)
						
						SELECT	TOP 1 @Shift_ID_Autoshift =  Shift_ID 
						FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
						WHERE	Cmp_ID = @Cmp_ID 
						ORDER BY ABS(DATEDIFF(s,@In_Time_Autoshift,CAST(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) AS DATETIME)))
				
						IF ISNULL(@Shift_ID_Autoshift,0) > 0
							BEGIN
								SELECT	TOP 1 @Shift_ID_Autoshift =  Shift_ID 
								FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
								WHERE	Cmp_ID = @Cmp_ID 
								ORDER BY ABS(DATEDIFF(s,@In_Time_Autoshift,CAST(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) AS DATETIME)))				
					
								DECLARE @Shift_st_time_auto AS DATETIME
								DECLARE @Shift_Out_time_auto AS DATETIME
					
								SELECT	@Shift_st_time_auto =CAST(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) AS DATETIME),
										@Shift_Out_time_auto=CAST(CONVERT(VARCHAR(11), @Out_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_END_Time, 114) AS DATETIME)
								FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
								WHERE Shift_ID=@Shift_ID_Autoshift and Cmp_ID=@Cmp_ID
					
								DECLARE @late_insec AS NUMERIC
								DECLARE @Working_secAt AS NUMERIC(18,0)
								DECLARE @late_out_sec_auto AS NUMERIC
								DECLARE @Erlyoutsec AS NUMERIC(18,0)
								
								SET @Working_secAt = ISNULL(DATEDIFF(s,@In_Time_Autoshift,@Shift_Out_time_auto),0)
						
								IF DATEDIFF(s,@In_Time_Autoshift,@Shift_st_time_auto) > 0  					      
									SET @Early_In_Sec = DATEDIFF(s,@In_Time_Autoshift,@Shift_st_time_auto)   
								ELSE
									SET @Early_In_Sec =  0
						      
								IF DATEDIFF(s,@In_Time_Autoshift,@Shift_st_time_auto) < 0 
									SET @late_insec = DATEDIFF(s,@In_Time_Autoshift,@Shift_st_time_auto)      
								ELSE
									SET @late_insec = 0
						   
								IF DATEDIFF(s,@Out_Time_Autoshift,@Shift_Out_time_auto) > 0       
									SET @Erlyoutsec = DATEDIFF(s,@Out_Time_Autoshift,@Shift_Out_time_auto)  
								ELSE
									SET @Erlyoutsec = 0
						   
						   
								IF DATEDIFF(s,@Out_Time_Autoshift,@Shift_Out_time_auto) < 0       
									SET @late_out_sec_auto = DATEDIFF(s,@Out_Time_Autoshift,@Shift_Out_time_auto)      
								ELSE
									SET @late_out_sec_auto = 0
							
							
							
								 --SELECT @late_out_sec_auto
								SET @late_insec  = @late_insec * -1      
								SET @late_out_sec_auto  = @late_out_sec_auto * -1 
							
								IF DATEDIFF(s,@Out_Time_Autoshift,@Shift_Out_time_auto) = 0
									BEGIN
										SET @Erlyoutsec=0
									END
								
								IF @late_insec IS NULL
									BEGIN
										SET @late_insec=0
									END
								IF @late_out_sec_auto IS NULL
									BEGIN
										SET @late_out_sec_auto=0
									END	
								IF @late_insec  > 0         
									BEGIN
										EXEC dbo.Return_DurHourMin @late_insec ,@late_In OUTPUT
									END
								ELSE IF @late_insec  < 0      
									BEGIN
										SET @late_insec=replace(@late_insec,'-','')
										EXEC dbo.Return_DurHourMin @late_insec ,@late_In OUTPUT
									END
								ELSE
									SET @late_in=''
							  
								IF @late_insec > 0
									BEGIN
										EXEC dbo.Return_DurHourMin  @late_insec ,@late_Out OUTPUT
									END
								ELSE
									SET @Late_Out=''					
							  
								IF @Early_In_Sec  > 0 
									EXEC dbo.Return_DurHourMin  @Early_In_Sec ,@Early_In OUTPUT  
								ELSE
									SET @Early_In = ''
								
							  
								IF @Erlyoutsec > 0 
									EXEC dbo.Return_DurHourMin  @Erlyoutsec ,@Early_Out OUTPUT       
							  
								IF @Working_sec > 0 
									EXEC dbo.Return_DurHourMin  @Working_secAt ,@WORKING_HOURS OUTPUT 
							   
								IF @late_out_sec_auto > 0  
									EXEC dbo.Return_DurHourMin  @late_out_sec_auto ,@late_Out OUTPUT  
								 
								IF @Erlyoutsec=0
									SET @Early_Out=''
							
								IF @late_out_sec_auto=0
									SET @late_out=''
								
								IF @late_insec=0
									SET @late_in=''
								
								IF @Early_In_Sec>0
									SET @late_in=''
							
								SET @Toatl_Working_sec = ISNULL(@Toatl_Working_sec,0) + @Working_secAt
											 
								UPDATE	#Emp_Inout 
								SET		Shift_ID=@Shift_ID_Autoshift,
										Late_In=@Late_In,
										Late_Out=@Late_Out,
										Early_In=@Early_In,
										Early_In_Sec = @Early_In_Sec,
										Early_Out=@Early_Out,
										Early_Out_Sec= @Erlyoutsec,
										Late_In_Sec=@late_insec,
										Shift_St_Datetime=@Shift_st_time_auto,
										Shift_en_Datetime=@Shift_Out_time_auto,
										Late_Out_Sec=0
								WHERE	emp_id=@Emp_ID_AutoShift and In_Time=@In_Time_Autoshift
										And Shift_ID <> @Shift_ID_Autoshift
					
								--Update #Data SET Shift_ID=@Shift_ID_Autoshift,Shift_Start_Time= CAST(CONVERT(VARCHAR(11), In_time, 121)  + CONVERT(VARCHAR(12), @Shift_start_time_Autoshift, 114) AS DATETIME)  FROM #Data
								--WHERE Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift And Shift_ID <> @Shift_ID_Autoshift
							END					
							
							FETCH NEXT FROM curautoshift INTO @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID,@Out_Time_Autoshift,@Shift_St_Time_Autoshift,@Shift_END_Time_Autoshift
						END 
					
					CLOSE curautoshift                    
					DEALLOCATE curautoshift   
					-------------ENDed by Sumit 19092015------------------------------------------------------------------------------  
				END         
	  
	  
				-- Added by rohit on 22082014
				EXEC dbo.GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@To_Date,0,@HalfDayDate OUTPUT  
		     
				IF	(CHARINDEX(CONVERT(NVARCHAR(11),@Temp_Month_Date,109),@HalfDayDate) > 0)  
					BEGIN      
				
						SET @Shift_St_Time = @Half_St_Time
						SET @Shift_END_Time = @Half_END_Time
						SET @shift_Dur= @Half_Dur       
						SET @Shift_Sec = 0     
						SET @Shift_Sec  = dbo.F_Return_Sec(@Shift_Dur) 
					END 
				-- ENDed by rohit
				DECLARE @HO_WO_STATUS INT 
				SET @HO_WO_STATUS = 0	-- 0: FOR NORMAL DAY, 1: HOLIDAY, 2: WEEKOFF
				
				DECLARE @WEEKOFF_WITHOUT_CANCEL VARCHAR(MAX)
				SET @WEEKOFF_WITHOUT_CANCEL = REPLACE(@StrWeekoff_Date, @StrCancelWeekoff_Date, '')
				
				DECLARE @HOLIDAY_WITHOUT_CANCEL VARCHAR(MAX)
				SET @HOLIDAY_WITHOUT_CANCEL = REPLACE(@StrHoliday_Date, @StrCancelHoliday_Date, '')
				
				IF CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@StrHoliday_Date,0) > 0
					AND CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@WEEKOFF_WITHOUT_CANCEL,0) > 0     
					BEGIN
						IF @Is_Cancel_Holiday_WO_HO_same_day = 1 
							SET @HO_WO_STATUS = 2
						ELSE
							SET @HO_WO_STATUS = 1
					END
				ELSE IF CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@HOLIDAY_WITHOUT_CANCEL,0) > 0
					SET @HO_WO_STATUS = 1
				ELSE IF CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@WEEKOFF_WITHOUT_CANCEL,0) > 0
					SET @HO_WO_STATUS = 2
					
				
				--Added by Jaina 08-03-2018 Start
				Declare @OD_Compoff_As_Present tinyint 
				Set @OD_Compoff_As_Present = 0 
		
				SELECT @OD_COMPOFF_AS_PRESENT = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK)
				WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @CMP_ID
				--Added by Jaina 08-03-2018 End
				
	
				---- Added by Hardik on 11/10/2011 for Holiday, Weekoff and Leave checking  
				--IF LEAVE EXIST THEN IT SHOULD BE CONSIDERED FIRST
				IF EXISTS (SELECT 1 FROM dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
											INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
								WHERE	From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
										AND LA.Leave_Approval_ID  NOT IN (SELECT	Leave_Approval_ID FROM dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK)
																		  WHERE		LC.cmp_id=@Cmp_ID AND LC.Emp_ID = @Emp_ID AND LC.For_Date = @Temp_Month_Date AND LC.Is_Approve=1) 
								)  
					BEGIN  
						--ADDED BY GADRIWALA MUSLIM 03122016 - START 
						set @Leave_ID = 0
						set @Leave_Reason = ''
						set @Leave_Period = 0
						set @Half_Leave_Date = null
						set @Leave_Assign_As = ''
						set @leave_out_time = NULL
						set @leave_in_time = NULL
						set	@Leave_Name = ''
						set @apply_hourly = ''
						set @Leave_Days = 0
					--ADDED BY GADRIWALA MUSLIM 03122016 - END 
					
						SELECT @Leave_ID = Leave_ID, @Leave_Reason = Leave_Reason, @Leave_Period = Leave_Period,@Half_Leave_Date = Half_Leave_Date, @Leave_Assign_As = Leave_Assign_As
						,@leave_out_time=ISNULL(LAD.leave_out_time,'01-jan-1900'),@leave_in_time=ISNULL(lad.leave_in_time,'01-jan-1900')
						,@Leave_FromDate = LAD.From_Date ,@Leave_ToDate = LAD.To_Date--add by chetan 250517
						FROM dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
						dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
						WHERE From_Date <= @Temp_Month_Date And To_Date >= @Temp_Month_Date And Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
						and LA.Leave_Approval_ID  not In (SELECT Leave_Approval_ID FROM dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) WHERE  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @Temp_Month_Date and LC.Is_Approve=1)

						
						--Added by Gadriwala Muslim 05122016
						DECLARE @HOLIDAY_AS_LEAVE AS TINYINT
						DECLARE @WEEKOFF_AS_LEAVE AS TINYINT
						declare @Leave_Type varchar(100)  --Added by Jaina 17-01-2018
						
						SET @HOLIDAY_AS_LEAVE = 0
						SET @WEEKOFF_AS_LEAVE = 0
						set @Leave_Type = ''
						
						SELECT @Leave_Name = Leave_Code,@apply_hourly = ISNULL(apply_hourly,0), @HOLIDAY_AS_LEAVE = HOLIDAY_AS_LEAVE,
							   @WEEKOFF_AS_LEAVE = WEEKOFF_AS_LEAVE  FROM dbo.T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID = @Leave_ID  
					  
						SELECT	@Leave_Days = Case When Default_Short_Name='COMP' Then IsNull(CompOff_Used,0) Else  ISNULL(leave_used,0) End,
								@Leave_Type = L.Leave_Type
						FROM	dbo.T0140_LEAVE_TRANSACTION  T WITH (NOLOCK) INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON T.LEAVE_ID=L.LEAVE_ID
						WHERE	t.Leave_ID = @Leave_ID  and Emp_ID=@Emp_ID and For_Date = @Temp_Month_Date
						
							--select @Leave_Days,@Leave_Name,@Temp_Month_Date
							
							
						--ADDED BY GADRIWALA MUSLIM 03122016 - START 
						if @leave_days = 0
							begin
									set @Leave_Name = ''
									--IF EXISTS (SELECT 1 FROM #EMP_HOLIDAY WHERE  IS_CANCEL = 1 AND FOR_DATE = @TEMP_MONTH_DATE) or (@HOLIDAY_AS_LEAVE = 1 and @WEEKOFF_AS_LEAVE = 0) -- Commented By Hardik Bhai 31082017 Due To WO Problem in Employee In-out Summary Report
									--	BEGIN
									--			SET @Leave_Name = 'WO'
									--	END	
									
									if CHARINDEX(Cast(@Temp_Month_Date as varchar(11)),@StrWeekoff_Date)>0
										BEGIN
												SET @Leave_Name = 'WO'
										END	
									if CHARINDEX(Cast(@Temp_Month_Date as varchar(11)),@StrHoliday_Date)>0
										BEGIN
												SET @Leave_Name = 'HO'
										END	
							end
							 
					

					IF NOT EXISTS (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
						BEGIN						

							IF Upper(@Country_Name) <> 'PAKISTAN'
								BEGIN
									IF @Report_call='Simsona' --Added Condition by Sumit 18112015
										BEGIN
											 INSERT INTO #Emp_Inout   
											  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
											  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
											  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,Total_Work_Sec
											  ,Vertical_Id,SubVertical_Id)   --added jimit 15062016
											 VALUES   
											  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
											   0, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,'-','-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_END_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
											  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Shift_Sec
											  ,@Vertical_Id,@SubVertical_Id)   --added jimit 15062016
										END
									 ELSE
										BEGIN
											--Added by Jaina 08-03-2018
											
											if @OD_Compoff_As_Present = 1
												begin
													IF @Leave_Type = 'Company Purpose'											
														set @p_Days = @Leave_Days
													else
														set @p_Days = 0
												END
											else
												set @p_Days = 0
											
											
											 INSERT INTO #Emp_Inout   
											  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
											  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
											  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id
											  ,Vertical_Id,SubVertical_Id,P_days)   --added jimit 15062016
											 VALUES   
											  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
											   0, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,'-','-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_END_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
											  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur
											  ,@Vertical_Id,@SubVertical_Id,@p_Days)   --added jimit 15062016
										END 
								END
							ELSE
								BEGIN													
									IF @Leave_Assign_As = 'Full Day'
										BEGIN
										IF @Report_call='Simsona' --Added Condition by Sumit 18112015
											BEGIN
											 INSERT INTO #Emp_Inout   
											  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
											  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
											  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id
											  ,Vertical_Id,SubVertical_Id)   --added jimit 15062016
											 VALUES   
											  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
											   @Shift_Sec, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,@Shift_Dur,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_END_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
											  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Shift_Sec,@Branch_Id_Cur
											  ,@Vertical_Id,@SubVertical_Id)   --added jimit 15062016
											 END
										ELSE
											BEGIN
												
												 INSERT INTO #Emp_Inout   
											  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
											  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
											  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id
											  ,Vertical_Id,SubVertical_Id)   --added jimit 15062016
											 VALUES   
											  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
											   @Shift_Sec, '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,@Shift_Dur,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_END_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
											  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Shift_Sec,@Branch_Id_Cur
											  ,@Vertical_Id,@SubVertical_Id)   --added jimit 15062016
											END	  
										END
									ELSE
										BEGIN
											IF @Report_call='Simsona' --Added Condition by Sumit 18112015
											BEGIN
											 INSERT INTO #Emp_Inout   
											  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
											  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
											  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id
											  ,Vertical_Id,SubVertical_Id)   --added jimit 15062016
											 VALUES   
											  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
											   Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 ELSE @Shift_Sec END , '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,Case When @Half_Leave_Date = @Temp_Month_Date Then dbo.F_Return_Hours(@Shift_Sec/2) ELSE @Shift_Dur END,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_END_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
											  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 ELSE @Shift_Sec END,@Branch_Id_Cur
											  ,@Vertical_Id,@SubVertical_Id)   --added jimit 15062016
											END
										ELSE
											BEGIN
											
											
												 INSERT INTO #Emp_Inout   
											  (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
											  Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
											  ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Total_Work_Sec,Branch_Id
											  ,Vertical_Id,SubVertical_Id,P_days)   --added jimit 15062016
											 VALUES   
											  (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
											   Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 ELSE @Shift_Sec END , '-' ,'-', '-', '-', @Leave_Name,@Shift_Sec,@Shift_Dur,Case When @Half_Leave_Date = @Temp_Month_Date Then dbo.F_Return_Hours(@Shift_Sec/2) ELSE @Shift_Dur END,'-','-',@Leave_Reason,0,0,0,0,0,@Shift_St_Time,@Shift_END_Time -- Null,Null -- comment and add by rohit for shift time on 06-aug-2012   
											  ,0,0,'-',@Leave_Name,0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,Case When @Half_Leave_Date = @Temp_Month_Date Then @Shift_Sec/2 ELSE @Shift_Sec END,@Branch_Id_Cur 
											  ,@Vertical_Id,@SubVertical_Id,0)   --added jimit 15062016
											END
										  
										END
									
											-- Added by rohit on 20082014
										IF @Report_Call='Shift_END' OR @Report_Call='Time_Loss'			----Time_Loss is Added By Ramiz on 29/09/2015
											BEGIN
												SET @leave_Detail=''
												IF @apply_hourly = 0
													BEGIN
														SET @leave_Detail=@leave_Detail + 'Day Leave ,'
														IF upper(@Leave_Assign_As) = 'PART DAY'
															BEGIN
																SET @leave_Detail=@leave_Detail + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
															END
														ELSE
															BEGIN										
																SET @leave_Detail=@leave_Detail + ' - ' + @Leave_Assign_As + ' - ' + CAST(@Leave_Days AS VARCHAR(10))											
															END
													END
												ELSE IF @apply_hourly = 1
													BEGIN
														SET @leave_Detail=@leave_Detail + 'Hourly Leave,'
														SET @leave_Detail=@leave_Detail + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
													END
									 					
									 															
												UPDATE	#Emp_Inout SET AB_LEAVE = @Leave_Name + ' - ' + @leave_Detail  
												WHERE	emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
									
												IF @Shift_St_Datetime =@leave_out_time
													BEGIN
														Update #Emp_Inout SET  Late_In = 0,late_in_sec=0,late_in_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
													END
												IF @Shift_END_dateTime = @leave_In_Time
													BEGIN
														Update #Emp_Inout SET Early_Out = 0,early_out_sec=0,Early_Out_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
													END
														
												IF upper(@Leave_Assign_As) = 'FIRST HALF'
													BEGIN
														Update #Emp_Inout SET  Late_In = 0,late_in_sec=0,late_in_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
													END
									
												IF upper(@Leave_Assign_As) = 'SECOND HALF'
													BEGIN
														Update #Emp_Inout SET Early_Out = 0,early_out_sec=0,Early_Out_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
													END									
											END
								END
						END
					ELSE
						BEGIN		
						--Leave_Reason = @Leave_Reason add by chetan 250517						
							Update #Emp_Inout SET AB_LEAVE = @Leave_Name,Total_Less_work_Sec = 0,Less_Work = '',Total_More_work_Sec = 0, More_Work='' 
							,Leave_Reason = @Leave_Reason ,Leave_FromDate = @Leave_FromDate,Leave_ToDate = @Leave_ToDate,Reason=@Leave_Reason 							
							WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
							
							--Added by Jaina 08-03-2018 Start													
							if @OD_Compoff_As_Present = 1
							begin
								IF @Leave_Type = 'Company Purpose'											
									set @p_Days = @p_Days + @Leave_Days								
							END				
														
							IF @Leave_Type = 'Company Purpose'
							BEGIN
								Update #Emp_Inout SET P_days = @p_Days								
								WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date 
							END
							--Added by Jaina 08-03-2018 END
							
								-- Added by rohit on 20082014
							IF @Report_Call='Shift_END' OR @Report_call = 'Time_loss'		--Time_Loss is Added By Ramiz on 29/09/2015
							BEGIN
							
							SET @leave_Detail=''
							IF @apply_hourly = 0
							BEGIN
								SET @leave_Detail=@leave_Detail + 'Day Leave ,'
								IF upper(@Leave_Assign_As) = 'PART DAY'
								BEGIN
									SET @leave_Detail=@leave_Detail + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
								END
								ELSE
								BEGIN
									SET @leave_Detail=@leave_Detail + ' - ' + CAST(@Leave_Assign_As AS varchar) + ' - ' + CAST(@Leave_Days AS VARCHAR(10))
								END
							END
							ELSE IF @apply_hourly = 1
							BEGIN
								SET @leave_Detail=@leave_Detail + 'Hourly Leave,'
								SET @leave_Detail=@leave_Detail + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_out_time, 100), 7)),'') + ' - ' + ISNULL(LTRIM(RIGHT(CONVERT(VARCHAR(20), @leave_in_time, 100), 7)),'') 
							END
							 
							 Update #Emp_Inout SET AB_LEAVE = @Leave_Name + ' - ' + @leave_Detail  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  		
							 
			 					-- Added by rohit on 08102014
									IF @Shift_St_Datetime =@leave_out_time
									 BEGIN
										Update #Emp_Inout SET  Late_In = 0,late_in_sec=0,late_in_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
									 END
									 IF @Shift_END_dateTime = @leave_In_Time
									 BEGIN
										Update #Emp_Inout SET Early_Out = 0,early_out_sec=0,Early_Out_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
									 END
														
									IF upper(@Leave_Assign_As) = 'FIRST HALF'
									BEGIN
										Update #Emp_Inout SET  Late_In = 0,late_in_sec=0,late_in_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
									END
									
									IF upper(@Leave_Assign_As) = 'SECOND HALF'
									BEGIN
									Update #Emp_Inout SET Early_Out = 0,early_out_sec=0,Early_Out_count=0  WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date  			
									END
									
									-- ENDed by rohit on 08102014
							
							 	
							END
							-- ENDed by rohit
						END
						
					 
				  
					END  						
				ELSE IF @HO_WO_STATUS = 1	--FOR HOLIDAY
					BEGIN  
						
						SET @Weekoff_Entry = @Weekoff_Entry  
		  
						IF NOT EXISTS (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
							BEGIN  
								
								DECLARE @Is_Half_Holiday TINYINT
								SET @Is_Half_Holiday = 0
				
								SELECT @Is_Half_Holiday= ISNULL(T.Is_Half,0) FROM #Emp_Holiday T WHERE Emp_Id = @Emp_ID and For_Date = @Temp_Month_Date 
				
								IF @Is_Half_Holiday = 0 
									BEGIN
										IF @Report_call='Simsona' --Added Condition by Sumit 18112015
											BEGIN
												INSERT INTO #Emp_Inout(Emp_id,For_Date,Dept_id,Grd_ID,Type_ID,Desig_ID,Shift_ID,In_Time,Out_Time,
															Duration,Duration_sec,Late_In,Late_Out,Early_In,Early_Out,Leave,Shift_Sec,Shift_Dur,
															Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,
															Early_Out_count,Shift_St_Datetime,Shift_en_Datetime,Working_Sec_AfterShift,Working_AfterShift_Count,
															Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,
															Late_Comm_sec,Branch_Id,Total_Work_Sec,Vertical_Id,SubVertical_Id,P_days)   --added jimit 15062016 )   
												VALUES(@emp_id,@Temp_Month_Date,@Dept_id,@Grd_ID,@Type_ID,@Desig_ID,@Shift_ID,Null,Null,'-',0,'-','-','-','-',
														'',@Shift_Sec,@shift_Dur,'-','-','-','-',0,0,0,0,0,@Shift_St_Time,@Shift_END_Time,0,0,'-','HO',0,
														@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Shift_Sec,
														@Vertical_Id,@SubVertical_Id,0)   --added jimit 15062016
											END
										ELSE
											BEGIN
												IF ((@Temp_Month_Date <= @Left_Date OR @Left_Date IS NULL)) --Added by Sumit on 22102016
													BEGIN
														INSERT INTO #Emp_Inout(Emp_id,For_Date,Dept_id,Grd_ID,Type_ID,Desig_ID,Shift_ID,In_Time,Out_Time,
																Duration,Duration_sec,Late_In,Late_Out,Early_In,Early_Out,Leave,Shift_Sec,Shift_Dur,
																Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,
																Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime,Working_Sec_AfterShift,
																Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,
																Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,Vertical_Id,SubVertical_Id,P_Days)   --added jimit 15062016
														VALUES(@emp_id,@Temp_Month_Date,@Dept_id,@Grd_ID,@Type_ID,@Desig_ID,@Shift_ID,Null,Null,'-',
																0, '-' ,'-', '-', '-', '',0,'-','-','-','-','-',0,0,0,0,0,Null,Null,0,0,'-','HO',0,@Emp_OT,
																@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Vertical_Id,@SubVertical_Id,0)   --added jimit 15062016
													END  
											END
								
										---Added Code by Sumit on 10112016--------------------------------------------------------	   
										UPDATE	EI 
										SET		EI.AB_LEAVE='OHO'
										FROM	#Emp_Inout EI 
												INNER JOIN #Emp_WeekOff_Holiday EWH ON EI.Emp_ID=EWH.Emp_ID
										WHERE	CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),EWH.OptHolidayDate,0) > 0
												AND EI.For_Date=@Temp_Month_Date
										------------------------------------------------------------------------------		
									END
								ELSE
									BEGIN
										IF @Report_call='Simsona' --Added Condition by Sumit 18112015
											BEGIN
												INSERT INTO #Emp_Inout(Emp_id,For_Date,Dept_id,Grd_ID,Type_ID,Desig_ID,Shift_ID,In_Time,Out_Time,Duration,
															Duration_sec,Late_In,Late_Out,Early_In,Early_Out,Leave,Shift_Sec,Shift_Dur,Total_Work,
															Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,
															Early_Out_count,Shift_St_Datetime,Shift_en_Datetime,Working_Sec_AfterShift,Working_AfterShift_Count,
															Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,
															Late_Comm_sec,Branch_Id,total_Work_Sec,Vertical_Id,SubVertical_Id,P_Days)   --added jimit 15062016
												VALUES(@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',0, '-' ,'-',
															'-', '-', '',@Shift_Sec,@shift_Dur,'-','-','-','-',0,0,0,0,0,@Shift_St_Time,@Shift_END_Time,0,0,'-',
															'HHO',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Shift_Sec,@Vertical_Id,
															@SubVertical_Id,0)   --added jimit 15062016
											END
										ELSE
											BEGIN
												IF ((@Temp_Month_Date <= @Left_Date OR @Left_Date IS NULL)) --Added by Sumit on 22102016
													BEGIN	
														INSERT INTO #Emp_Inout(Emp_id,For_Date,Dept_id,Grd_ID,Type_ID,Desig_ID,Shift_ID,In_Time,Out_Time,
																	Duration,Duration_sec,Late_In,Late_Out,Early_In,Early_Out,Leave,Shift_Sec,Shift_Dur,
																	Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,
																	Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime,Working_Sec_AfterShift,
																	Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,
																	Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,Vertical_Id,SubVertical_Id,P_Days)   --added jimit 15062016
														VALUES(@emp_id,@Temp_Month_Date,@Dept_id,@Grd_ID,@Type_ID,@Desig_ID,@Shift_ID,Null,Null,'-',0,'-','-',
																'-','-','',0,'-','-','-','-','-',0,0,0,0,0,Null,Null,0,0,'-','HHO',0,@Emp_OT,
																@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Vertical_Id,@SubVertical_Id,0)   --added jimit 15062016
													END	
											END 
									END 
							END  
						ELSE  
							BEGIN  			
								IF @Emp_OT = 1
									BEGIN
										----Comment - Ankit 30122015
										--Update #Emp_Inout SET AB_LEAVE = 'HO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work,Shift_Sec = 0 
										--FROM #Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
										-- WHERE EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half = 0
										  
										-- Update #Emp_Inout SET AB_LEAVE = 'HHO', Total_More_work_Sec = CAST(Total_Work_Sec AS NUMERIC(18,2)) - DATEDIFF(s,Shift_St_Datetime,Shift_en_Datetime)/2, More_Work =  dbo.F_Return_Hours(CAST(ISNULL(Total_Work_Sec,0) AS NUMERIC(18,2))- DATEDIFF(s,Shift_St_Datetime,Shift_en_Datetime)/2),Shift_Sec = 0 
										--FROM #Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
										-- WHERE EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.Is_Half = 1
										
										/* Note : Cancel Holiday IF Sandwich Policy and Employee Present on that day then its calculate Ovet Time 
											--CancelHoliday Added by Ankit 30122015 */
											
											
										IF CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@StrCancelHoliday_Date,0) > 0 
											BEGIN
												Update	#Emp_Inout 
												SET		Total_More_work_Sec = Total_Work_Sec,
														More_Work = Total_work,Shift_Sec = 0 
												FROM	#Emp_Inout EI inner join #Emp_Holiday EH ON EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
												WHERE	EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half = 0
												  
												Update	#Emp_Inout 
												SET		Total_More_work_Sec = CAST(Total_Work_Sec AS NUMERIC(18,2)) - DATEDIFF(s,Shift_St_Datetime,Shift_en_Datetime)/2, More_Work =  dbo.F_Return_Hours(CAST(ISNULL(Total_Work_Sec,0) AS NUMERIC(18,2))- DATEDIFF(s,Shift_St_Datetime,Shift_en_Datetime)/2),Shift_Sec = 0 
												FROM	#Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
												WHERE	EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.Is_Half = 1
											END
										ELSE
											BEGIN
												Update	#Emp_Inout 
												SET		AB_LEAVE = 'HO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work,Shift_Sec = 0 
												FROM	#Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
												WHERE	EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half = 0
												  
												Update	#Emp_Inout 
												SET		AB_LEAVE = 'HHO', Total_More_work_Sec = CAST(Total_Work_Sec AS NUMERIC(18,2)) - DATEDIFF(s,Shift_St_Datetime,Shift_en_Datetime)/2, More_Work =  dbo.F_Return_Hours(CAST(ISNULL(Total_Work_Sec,0) AS NUMERIC(18,2))- DATEDIFF(s,Shift_St_Datetime,Shift_en_Datetime)/2),Shift_Sec = 0 
												FROM	#Emp_Inout EI inner join #Emp_Holiday EH  on EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
												WHERE	EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.Is_Half = 1
												 
												---Added Code by Sumit on 10112016--------------------------------------------------------	   
												UPDATE	EI 
												SET		EI.AB_LEAVE='OHO'
												FROM	#Emp_Inout EI INNER JOIN #Emp_WeekOff_Holiday EWH ON EI.Emp_ID=EWH.Emp_ID
												where	CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),EWH.OptHolidayDate,0) > 0
														AND EI.For_Date=@Temp_Month_Date
												------------------------------------------------------------------------------		
											END	
											
										IF @Tras_Week_ot = 0  --Added by nilesh patel on 12082015(Working on Weekoff & Transfer weekoff is not SELECT that time consider AS working our
											BEGIN
												IF @Diff_Sec > 0 
													BEGIN
														DECLARE @More_Work_2 VARCHAR(100)
														SET @More_Work_2 = '-'
														EXEC dbo.Return_DurHourMin @Diff_Sec , @More_Work_2 OUTPUT
														
														Update #Emp_Inout SET More_Work = @More_Work_2, Total_More_work_Sec = @Diff_Sec WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date and (AB_LEAVE = 'HO' or AB_LEAVE = 'OHO')
													END
												ELSE
													Update #Emp_Inout SET More_Work = '-', Total_More_work_Sec = 0 WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date and (AB_LEAVE = 'HO'  or AB_LEAVE = 'OHO')
											END
									END
								ELSE
									BEGIN
										UPDATE	#Emp_Inout 
										SET		AB_LEAVE = 'HO',Shift_Sec = 0 
										FROM	#Emp_Inout EI 
												INNER JOIN #Emp_Holiday EH ON EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
										WHERE	EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half = 0
					
										Update	#Emp_Inout 
										SET		AB_LEAVE = 'HHO',Shift_Sec = 0 
										FROM	#Emp_Inout EI 
												INNER JOIN #Emp_Holiday EH ON EH.Emp_Id = EI.emp_id and EH.For_Date = EI.for_Date 
										WHERE	EI.emp_id = @Emp_ID And EI.for_Date = @Temp_Month_Date and EH.is_Half = 1
										
										---Added Code by Sumit on 10112016--------------------------------------------------------	   
										UPDATE	EI 
										SET		EI.AB_LEAVE='OHO'
										FROM	#Emp_Inout EI 
												INNER JOIN #Emp_WeekOff_Holiday EWH ON EI.Emp_ID=EWH.Emp_ID
										WHERE	CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),EWH.OptHolidayDate,0) > 0
												AND EI.For_Date=@Temp_Month_Date
										------------------------------------------------------------------------------		
									END
							END  
					END   
				ELSE IF @HO_WO_STATUS = 2	--FOR WEEKOFF
					BEGIN  
						SET @Weekoff_Entry = @Weekoff_Entry  
						IF NOT EXISTS (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)  
							BEGIN  
								IF ((@Temp_Month_Date <= @Left_Date OR @Left_Date IS NULL)) --Added by Sumit on 22102016
									BEGIN
										INSERT INTO #Emp_Inout(Emp_id,For_Date,Dept_id,Grd_ID,Type_ID,Desig_ID,Shift_ID,In_Time,Out_Time,Duration,Duration_sec,
													Late_In,Late_Out,Early_In,Early_Out,Leave,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,
													Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,
													Shift_en_Datetime,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,
													Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id,Vertical_Id,SubVertical_Id,P_days)   --added jimit 15062016
										VALUES(@emp_id,@Temp_Month_Date,@Dept_id,@Grd_ID,@Type_ID,@Desig_ID,@Shift_ID,Null,Null,'-',0,'-','-','-','-','',0,
												'-','-','-','-','-',0,0,0,0,0,@Shift_St_Time,@Shift_END_Time,0,0,'-','WO',0,@Emp_OT,
												@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur,@Vertical_Id,@SubVertical_Id,0)   --added jimit 15062016
									END	   
							END  
						ELSE  
							BEGIN  
								IF @Emp_OT = 1
									BEGIN 
										----Comment by Ankit For Cancel Weeklyoff	--30122015
										--Update #Emp_Inout SET AB_LEAVE = 'WO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 
										--WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date 
							
										/* Note : Cancel weekly off IF Sandwich Policy and Employee Present on that day then its calculate Ovet Time 
										--CancelWeekOff Added by Ankit 30122015 */
										IF CHARINDEX(CAST(@Temp_Month_Date AS VARCHAR(11)),@StrCancelWeekoff_Date,0) > 0 
											BEGIN
												UPDATE	#Emp_Inout 
												SET		Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 
												WHERE	emp_id = @Emp_ID And for_Date = @Temp_Month_Date   
											END
										ELSE
											BEGIN
												Update	#Emp_Inout 
												SET		AB_LEAVE = 'WO', Total_More_work_Sec = Total_Work_Sec, More_Work = Total_work, Total_Less_work_Sec = 0,Less_Work = '',Shift_Sec = 0 
												WHERE	emp_id = @Emp_ID And for_Date = @Temp_Month_Date   
											END		
							
										IF @Tras_Week_ot = 0  --Added by nilesh patel on 12082015(Working on Weekoff & Transfer weekoff is not SELECT that time consider AS working our
											BEGIN
												IF @Diff_Sec > 0 
													BEGIN
														DECLARE @More_Work_1 VARCHAR(100)
														SET @More_Work_1 = '-'
														EXEC dbo.Return_DurHourMin @Diff_Sec , @More_Work_1 OUTPUT
														
														UPDATE	#Emp_Inout 
														SET		More_Work = @More_Work_1,Total_More_work_Sec = @Diff_Sec 
														WHERE	emp_id = @Emp_ID And for_Date = @Temp_Month_Date and AB_LEAVE = 'WO'
													END
												ELSE											
													Update	#Emp_Inout 
													SET		More_Work = '-', Total_More_work_Sec = 0 
													WHERE	emp_id = @Emp_ID And for_Date = @Temp_Month_Date and AB_LEAVE = 'WO' 
											END
									END
								ELSE
									UPDATE	#Emp_Inout 
									SET		AB_LEAVE = 'WO',Shift_Sec = 0 
									WHERE	emp_id = @Emp_ID And for_Date = @Temp_Month_Date  
							END  
					END  
				ELSE  --REST SHOULD BE ABSENT
					BEGIN  
						IF NOT EXISTS (SELECT 1 FROM #Emp_Inout WHERE emp_id = @Emp_ID And for_Date = @Temp_Month_Date)-- and ((ISNULL(Chk_By_Superior,0)=1 and not App_Date IS NULL) OR (app_date IS NULL))  )  
							BEGIN



							IF @Temp_Month_Date >= @Join_Date And (@Temp_Month_Date <= @Left_Date OR @Left_Date IS NULL)
								BEGIN
								
											
								  INSERT INTO #Emp_Inout
								   (Emp_id,For_Date , Dept_id ,Grd_ID,Type_ID,Desig_ID ,Shift_ID,In_Time ,Out_Time ,Duration ,      
								   Duration_sec  , Late_In ,Late_Out , Early_In , Early_Out , Leave ,Shift_Sec,Shift_Dur,Total_Work,Less_Work,More_work,Reason,Late_in_sec,Early_Out_sec,Total_Less_work_sec,Late_in_Count,Early_Out_count,Shift_St_Datetime,Shift_en_Datetime      
								   ,Working_Sec_AfterShift,Working_AfterShift_Count,Inout_Reason,AB_LEAVE,Total_More_work_Sec,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Late_Comm_sec,Branch_Id
								   ,Vertical_Id,SubVertical_Id,P_Days)   --added jimit 15062016
								  VALUES   
								   (@emp_id ,@Temp_Month_Date ,@Dept_id ,@Grd_ID ,@Type_ID,@Desig_ID,@Shift_ID,Null,Null ,'-',      
									0, '-' ,'-', '-', '-', '',@Shift_Sec,@Shift_Dur,'-',@Shift_Dur,'-','-',0,0,@Shift_Sec,0,0,@Shift_St_Time,@Shift_END_Time --Null,Null --comment and add by rohit for shift time on 06-aug-2012  
								   ,0,0,'-','AB',0,@Emp_OT,@Monthly_Deficit_Adjust_OT_Hrs,@Late_Comm_sec,@Branch_Id_Cur 
								   ,@Vertical_Id,@SubVertical_Id,0)   --added jimit 15062016
								END
							END  
					END  			
				------------- END by Hardik   
			    --Added by Jaina 17-01-2018
				
				set @Leave_Days = 0  --Added by Jaina 17-01-2018
				set @Leave_Type = '' --Added by Jaina 17-01-2018
			      
				SET @Temp_Month_Date = Dateadd(d,1,@Temp_Month_Date)       
			END       
		FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Late_Comm_sec,@Early_Limit_Sec,@Emp_OT,@Emp_OT_Min_Limit_Sec,@Emp_OT_Max_Limit_Sec,@Monthly_Deficit_Adjust_OT_Hrs,@Branch_Id_Cur,@Vertical_Id,@SubVertical_Id
	END      
	close cur_Emp      
	deallocate cur_Emp  
	    
	--Added by Jaina 17-01-2018 Start	
	DECLARE @SETTING_VALUE AS BIT =0    	    	
	IF OBJECT_ID('tempdb..#INOUT_DETAIL') is not null
		BEGIN		
			
			INSERT	INTO #INOUT_DETAIL (Emp_Id,Row_ID,For_Date,P_Days,Ho_Day,Wo_Day,Leave_Days,Leave_Type,Absent)
			select DISTINCT EMP_ID,9999,@From_Date,0,0,0,0,'',0 from #Att_Muster_Excel
			
			UPDATE 	ID
			SET		P_DAYS	= CONVERT(decimal(4,2),I.STATUS)
			from	#INOUT_DETAIL ID
					inner JOIN #ATT_MUSTER_EXCEL I on I.Emp_Id=ID.Emp_ID 
			where I.ROW_ID=32
			
			UPDATE	ID
			SET		Absent	= CONVERT(decimal(4,2),I.STATUS)
			from	#INOUT_DETAIL ID
					inner JOIN #ATT_MUSTER_EXCEL I on I.Emp_Id=ID.Emp_ID 
			where I.ROW_ID=33
			
			
			UPDATE	ID
			SET		Leave_Days	= isnull(CONVERT(decimal(4,2),I.STATUS),0)
			from	#INOUT_DETAIL ID
					inner JOIN #ATT_MUSTER_EXCEL I on I.Emp_Id=ID.Emp_ID 			
			where I.ROW_ID=34
			
			UPDATE	ID
			SET		WO_Day	= isnull(CONVERT(decimal(4,2),I.STATUS),0)
			from	#INOUT_DETAIL ID
					inner JOIN #ATT_MUSTER_EXCEL I on I.Emp_Id=ID.Emp_ID 
			where I.ROW_ID=35
			
			UPDATE	ID
			SET		HO_Day	= isnull(CONVERT(decimal(4,2),I.STATUS),0)
			from	#INOUT_DETAIL ID
					inner JOIN #ATT_MUSTER_EXCEL I on I.Emp_Id=ID.Emp_ID 
			where I.ROW_ID=36
			
			
			
			--select * from #INOUT_DETAIL
			--Comment by Jaina 19-02-2018 Start
			--INSERT	INTO #INOUT_DETAIL (Emp_Id,Row_ID,For_Date,P_Days,Ho_Day,Wo_Day,Leave_Days,Leave_Type,Absent)
			--SELECT	EMP_ID, ROW_ID, DATEADD(D, T.ROW_ID-1, @FROM_DATE), 0, 0, 0, 0, '',0
			--FROM	#Emp_Cons EC
			--		CROSS JOIN (SELECT	TOP 365 ROW_NUMBER() OVER(ORDER BY For_date ) AS ROW_ID
			--					FROM	#Emp_Inout ) T 
			--WHERE	DATEADD(D, T.ROW_ID-1, @FROM_DATE) <= @TO_DATE
						
					
			--UPDATE	ID
			--SET		P_DAYS	= dbo.F_Remove_Zero_Decimal(ISNULL(EI.P_days, 0)),
			--		WO_Day = ISNULL(W.W_day, 0),
			--		Ho_Day = ISNULL(H.H_DAY,0)					
			--FROM	#INOUT_DETAIL ID
			--		LEFT OUTER JOIN #Emp_Inout EI ON ID.EMP_ID=EI.emp_id AND ID.FOR_DATE=EI.FOR_DATE
			--		LEFT OUTER JOIN #Emp_WeekOff W ON ID.Emp_ID=W.Emp_ID AND ID.For_Date=W.For_Date
			--		LEFT OUTER JOIN #Emp_Holiday H ON ID.Emp_ID=H.Emp_ID AND ID.For_Date=H.For_Date
				
			--UPDATE ID
			--SET LEAVE_DAYS = case when Leave_Paid_Unpaid = 'U' then '0' else dbo.F_Remove_Zero_Decimal(isnull(LD.LEAVE_USED,0)) END,
			--	LEAVE_TYPE = LD.LEAVE_TYPE
			--FROM	#INOUT_DETAIL ID 
			--		LEFT OUTER JOIN ( SELECT  CASE WHEN DEFAULT_SHORT_NAME='COMP' THEN SUM(ISNULL(LT.COMPOFF_USED,0)) ELSE  SUM(ISNULL(LT.LEAVE_USED,0)) END AS LEAVE_USED,
			--								  L.LEAVE_TYPE,LT.EMP_ID,LT.FOR_DATE,L.Leave_Paid_Unpaid
			--						  FROM T0140_LEAVE_TRANSACTION LT 
			--								INNER JOIN T0040_LEAVE_MASTER L ON L.LEAVE_ID = LT.LEAVE_ID 
			--						  GROUP BY LT.FOR_DATE,DEFAULT_SHORT_NAME,EMP_ID,LEAVE_TYPE,Leave_Paid_Unpaid
			--						 ) AS LD ON LD.EMP_ID = ID.EMP_ID AND LD.FOR_DATE = ID.FOR_DATE
			
			----UPDATE ID
			----SET P_DAYS = P_DAYS - leave_Days				
			----FROM	#INOUT_DETAIL ID 
			----where ID.Leave_Type='Company Purpose'
			
			--UPDATE ID
			--SET P_DAYS = 1
			--FROM	#INOUT_DETAIL ID 
			--where ID.Leave_Type='Company Purpose' AND P_DAYS > 1
			
			--SELECT @Setting_value = Setting_Value FROM T0040_SETTING where Setting_Name like '%OD and CompOff Leave Consider As Present%' and Cmp_ID = @Cmp_id			
			--IF @Setting_value = 1
			--begin
				
			--	UPDATE ID
			--	SET ID.P_DAYS = ID.P_DAYS + LD.LEAVE_USED					
			--	FROM	#INOUT_DETAIL ID 
			--		LEFT OUTER JOIN ( SELECT  CASE WHEN DEFAULT_SHORT_NAME='COMP' THEN SUM(ISNULL(LT.COMPOFF_USED,0)) ELSE  SUM(ISNULL(LT.LEAVE_USED,0)) END AS LEAVE_USED,
			--								  L.LEAVE_TYPE,LT.EMP_ID,LT.FOR_DATE
			--						  FROM T0140_LEAVE_TRANSACTION LT 
			--								INNER JOIN T0040_LEAVE_MASTER L ON L.LEAVE_ID = LT.LEAVE_ID 
			--						  WHERE (L.Leave_Type='Company Purpose' OR L.Default_Short_Name='COMP')
			--						  GROUP BY LT.FOR_DATE,DEFAULT_SHORT_NAME,EMP_ID,LEAVE_TYPE
			--						 ) AS LD ON LD.EMP_ID = ID.EMP_ID AND LD.FOR_DATE = ID.FOR_DATE
			--	where ID.Leave_Type='Company Purpose'
				
			--	UPDATE ID
			--	SET 
			--		ID.leave_Days = ID.P_DAYS - LD.LEAVE_USED
			--	FROM	#INOUT_DETAIL ID 
			--		LEFT OUTER JOIN ( SELECT  CASE WHEN DEFAULT_SHORT_NAME='COMP' THEN SUM(ISNULL(LT.COMPOFF_USED,0)) ELSE  SUM(ISNULL(LT.LEAVE_USED,0)) END AS LEAVE_USED,
			--								  L.LEAVE_TYPE,LT.EMP_ID,LT.FOR_DATE
			--						  FROM T0140_LEAVE_TRANSACTION LT 
			--								INNER JOIN T0040_LEAVE_MASTER L ON L.LEAVE_ID = LT.LEAVE_ID 
			--						  WHERE (L.Leave_Type='Company Purpose' OR L.Default_Short_Name='COMP')
			--						  GROUP BY LT.FOR_DATE,DEFAULT_SHORT_NAME,EMP_ID,LEAVE_TYPE
			--						 ) AS LD ON LD.EMP_ID = ID.EMP_ID AND LD.FOR_DATE = ID.FOR_DATE
			--	where ID.Leave_Type='Company Purpose'
			
			--end
						
				
			--UPDATE ID
			--SET ABSENT = 1 - (P_DAYS + HO_DAY + WO_DAY + LEAVE_DAYS)
			--FROM	#INOUT_DETAIL ID		
				
			--INSERT	INTO #INOUT_DETAIL (EMP_ID,ROW_ID,FOR_DATE,P_DAYS,HO_DAY,WO_DAY,LEAVE_DAYS,LEAVE_TYPE,ABSENT)
			--SELECT EMP_ID,9999,DATEADD(DD,1,@TO_DATE), dbo.F_Remove_Zero_Decimal(SUM(P_DAYS)),dbo.F_Remove_Zero_Decimal(SUM(HO_DAY)),dbo.F_Remove_Zero_Decimal(SUM(WO_DAY)),dbo.F_Remove_Zero_Decimal(SUM(LEAVE_DAYS)),'',SUM(ABSENT) 
			--FROM #INOUT_DETAIL
			--GROUP BY EMP_ID
			
			--SELECT * FROM #INOUT_DETAIL	
			--Comment by Jaina 19-02-2018 End
		END		
			
	--Added by Jaina 17-01-2018 End		
				
				
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
							--Following Update Query placed for BMA Client on 14-May-2018 (they requires Leave Reason in Reason Column, Customized Report -> Attendance -> In-Out Summary)
							UPDATE	EIO
							SET		Reason = CASE WHEN Len(Reason) > 0 Then Reason + ' #Leave: ' Else '' END  + Leave_Reason
							FROM	#Emp_Inout EIO
							WHERE	LEN(Leave_Reason) > 0 

							IF @InOut_Tag = 'CSV'
								BEGIN
									SELECT	Emp_code AS EmpNo, EI.In_Time As InDate, EI.Out_Time As OutDate, REPLACE(CONVERT(VARCHAR(11), EI.for_Date, 113), ' ', '-') As AttendanceDate
									FROM	#Emp_Inout EI
											INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EI.emp_id=E.Emp_ID
									WHERE	In_Time IS NOT NULL AND EI.Out_Time IS NOT NULL
								END
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
								   T0050_SubVertical sv WITH (NOLOCK) on E_IO.subvertical_Id = sv.SubVertical_ID --left JOIN
								   --T0150_EMP_INOUT_RECORD EIR ON EI.EMP_ID = EIR.EMP_ID AND EI.For_date=EIR.For_Date and isnull(EIR.Chk_By_Superior,0) <>1  --Mukti(06102017)
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
				SUM(Total_Less_work_Sec) 
				-- SUM(Total_More_work_Sec) Commented by Rajput on 19042018 after discussed with hardik bhai ( CERA Client Probelm )
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
			FROM #Emp_Inout AS E_IO inner join dbo.T0080_EMP_MASTER E on E.emp_ID = E_IO.Emp_Id  inner join      
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
							FROM	dbo.t0040_shift_master ST WITH (NOLOCK) LEFT OUTER JOIN dbo.t0050_shift_detail SD WITH (NOLOCK)
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
							ELSE e.Alpha_Emp_Code END 
							
							
							
	END
	ELSE IF @Report_call = 'Time_Card_Cera' -- ADDED BY RAJPUT ON 19072018 FOR CERA CLIENT
		BEGIN
		
					CREATE TABLE #GATE_INOUT
					(
						EMP_ID	NUMERIC(18,0),
						ENROLL_NO	NVARCHAR(100),
						FOR_DATE	DATETIME NULL,
						IN_TIME		DATETIME NULL,      
						OUT_TIME    DATETIME NULL   
					)
					CREATE TABLE #DEPARTMENT_INOUT
					(
						EMP_ID	 NUMERIC(18,0),
						ENROLL_NO NVARCHAR(100),
						FOR_DATE DATETIME NULL,
						IN_TIME DATETIME NULL,
						OUT_TIME DATETIME NULL
					)
					CREATE TABLE #CANTEEN_INOUT
					(
						EMP_ID NUMERIC(18,0),
						ENROLL_NO NVARCHAR(100),
						FOR_DATE DATETIME NULL,
						IN_TIME DATETIME NULL,
						OUT_TIME DATETIME NULL
					)
					
					
					INSERT INTO #GATE_INOUT(EMP_ID,ENROLL_NO,IN_TIME,OUT_TIME)
					SELECT EM.EMP_ID,DATA.ENROLL_NO,MIN(IN_TIME) AS IN_TIME, MAX(OUT_TIME) AS OUT_TIME FROM
					(
						SELECT 
						ENROLL_NO,IN_OUT.IP_ADDRESS,MIN(IO_DATETIME) AS IN_TIME,MAX(IO_DATETIME) AS OUT_TIME
						FROM T9999_DEVICE_INOUT_DETAIL AS IN_OUT WITH (NOLOCK) LEFT OUTER JOIN T0040_IP_MASTER AS IP WITH (NOLOCK) ON IN_OUT.IP_ADDRESS = IP.IP_ADDRESS 
						WHERE ENROLL_NO =1002 AND IP.DEVICE_NAME  LIKE '%GATE%'
						AND IO_DATETIME>'2018-07-02'
						GROUP BY ENROLL_NO,IN_OUT.IP_ADDRESS,IO_DATETIME
					) AS DATA INNER JOIN DBO.T0080_EMP_MASTER EM WITH (NOLOCK) ON DATA.Enroll_No = EM.Enroll_No
					GROUP BY DATA.ENROLL_NO,EM.Emp_ID
					ORDER BY IN_TIME
					
					INSERT INTO #DEPARTMENT_INOUT(EMP_ID,ENROLL_NO,IN_TIME,OUT_TIME)
					SELECT EM.EMP_ID,DATA.ENROLL_NO,MIN(IN_TIME) AS IN_TIME, MAX(OUT_TIME) AS OUT_TIME FROM
					(
						SELECT 
						ENROLL_NO,IN_OUT.IP_ADDRESS,MIN(IO_DATETIME) AS IN_TIME,MAX(IO_DATETIME) AS OUT_TIME
						FROM T9999_DEVICE_INOUT_DETAIL AS IN_OUT WITH (NOLOCK) LEFT OUTER JOIN T0040_IP_MASTER AS IP WITH (NOLOCK) ON IN_OUT.IP_ADDRESS = IP.IP_ADDRESS 
						WHERE ENROLL_NO =1002 AND IP.DEVICE_NAME  LIKE '%DEPARTMENT%'
						AND IO_DATETIME>'2018-07-02'
						GROUP BY ENROLL_NO,IN_OUT.IP_ADDRESS
					) AS DATA INNER JOIN DBO.T0080_EMP_MASTER EM WITH (NOLOCK) ON DATA.Enroll_No = EM.Enroll_No
					GROUP BY DATA.ENROLL_NO,EM.Emp_ID
					ORDER BY IN_TIME
					
					
					Update #Emp_Inout SET Shift_St_Datetime = CAST(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) AS DATETIME)  FROM #Emp_Inout
	   				IF  object_id('tempdb..#Break_INOUT_Cera') IS NOT NULL 
					BEGIN      
						drop table #Break_INOUT_Cera  
					END 
					
						--SELECT B.*,SM.S_St_Time,SM.S_End_Time,ABS(DATEDIFF(s,Pre_Out_TIme,B.for_date+S_st_time )) AS DIFF_NEAR 
						--INTO	#Break_INOUT_Cera
						--FROM	#TMP_BREAK B 
						--INNER JOIN #Emp_Inout D ON B.FOR_DATE=D.For_date AND B.EMP_ID=D.EMP_ID  
						--INNER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID=SM.Shift_ID
						
					
						--UPDATE EI 
						--SET EI.Break_Start_Time = Qry.PRE_OUT_TIME  
						--,EI.Break_End_Time = Qry.IN_TIME
						--,EI.Break_Duration = dbo.F_Return_Hours(Qry.Diffse)
						--FROM #Emp_Inout EI INNER JOIN
						--(SELECT BI.Emp_ID,BI.For_Date,BI1.PRE_OUT_TIME,IN_TIME,Diffse
						--FROM	#Break_INOUT_Cera BI
						--		INNER JOIN (SELECT min(BI1.PRE_OUT_TIME) as PRE_OUT_TIME ,BI1.EMP_ID,BI1.FOR_DATE
						--					FROM	#Break_INOUT_Cera BI1
						--							INNER JOIN (SELECT	MIN(DIFF_NEAR) DIFF_NEAR, EMP_ID,FOR_DATE
						--										FROM	#Break_INOUT_Cera BI2
						--										GROUP BY EMP_ID,FOR_DATE) BI2 ON BI1.EMP_ID=BI2.EMP_ID AND BI1.FOR_DATE=BI2.FOR_DATE AND BI1.DIFF_NEAR=BI2.DIFF_NEAR
						--					GROUP BY BI1.EMP_ID,BI1.FOR_DATE) BI1 ON BI1.EMP_ID=BI.EMP_ID AND BI1.FOR_DATE=BI.FOR_DATE AND BI1.PRE_OUT_TIME=BI.PRE_OUT_TIME
						--)Qry  ON EI.Emp_ID=Qry.Emp_ID AND EI.For_Date = Qry.For_Date 
						
						
						
						UPDATE EI 
						SET EI.DEPARTMENT_IN_TIME = Qry.IN_TIME
						,EI.DEPARTMENT_OUT_TIME = Qry.OUT_TIME
						--,EI.Break_Duration = dbo.F_Return_Hours(Qry.Diffse)
						FROM #Emp_Inout EI INNER JOIN
						(SELECT BI.EMP_ID,BI.FOR_DATE,BI.IN_TIME,BI.OUT_TIME
						FROM	#DEPARTMENT_INOUT BI
								INNER JOIN (SELECT BI1.EMP_ID,BI1.FOR_DATE
											FROM	#DEPARTMENT_INOUT BI1
													INNER JOIN (SELECT	EMP_ID,FOR_DATE
																FROM	#DEPARTMENT_INOUT BI2
																GROUP BY EMP_ID,FOR_DATE) BI2 ON BI1.EMP_ID=BI2.EMP_ID --AND BI1.FOR_DATE=BI2.FOR_DATE --AND BI1.DIFF_NEAR=BI2.DIFF_NEAR
											GROUP BY BI1.EMP_ID,BI1.FOR_DATE) BI1 ON BI1.EMP_ID=BI.EMP_ID --AND BI1.FOR_DATE=BI.FOR_DATE --AND BI1.PRE_OUT_TIME=BI.PRE_OUT_TIME
						)Qry  ON EI.Emp_ID=Qry.Emp_ID --AND EI.For_Date = Qry.For_Date 
						
						
						
						UPDATE EI 
						SET EI.In_Time = Qry.IN_TIME
						,EI.OUT_TIME = Qry.OUT_TIME
						--,EI.Break_Duration = dbo.F_Return_Hours(Qry.Diffse)
						FROM #Emp_Inout EI INNER JOIN
						(SELECT BI.EMP_ID,BI.FOR_DATE,BI.IN_TIME,BI.OUT_TIME
						FROM	#GATE_INOUT BI
								INNER JOIN (SELECT BI1.EMP_ID,BI1.FOR_DATE
											FROM	#GATE_INOUT BI1
													INNER JOIN (SELECT	EMP_ID,FOR_DATE
																FROM	#GATE_INOUT BI2
																GROUP BY EMP_ID,FOR_DATE) BI2 ON BI1.EMP_ID=BI2.EMP_ID --AND BI1.FOR_DATE=BI2.FOR_DATE --AND BI1.DIFF_NEAR=BI2.DIFF_NEAR
											GROUP BY BI1.EMP_ID,BI1.FOR_DATE) BI1 ON BI1.EMP_ID=BI.EMP_ID --AND BI1.FOR_DATE=BI.FOR_DATE --AND BI1.PRE_OUT_TIME=BI.PRE_OUT_TIME
						)Qry  ON EI.Emp_ID=Qry.Emp_ID --AND EI.For_Date = Qry.For_Date 
						
									
					
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
				,E_IO.Break_Start_Time,E_IO.Break_End_Time ,E_IO.Break_Duration,E_IO.DEPARTMENT_IN_TIME,E_IO.DEPARTMENT_OUT_TIME
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
							ELSE e.Alpha_Emp_Code END 
							
							
							
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
				FROM T9999_DEVICE_INOUT_DETAIL TD WITH (NOLOCK) 
				LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TD.Enroll_No = EM.Enroll_No 
				LEFT OUTER JOIN T0040_IP_MASTER IM WITH (NOLOCK) ON TD.IP_Address = IM.IP_ADDRESS 
				WHERE  TD.In_Out_flag = 0 --and emp_ID =  17914
			)IN_QRY ON  E_IO.Emp_ID = IN_QRY.Emp_ID AND E_IO.In_Time = IN_QRY.IO_DateTime 
			LEFT OUTER JOIN 
			(
				SELECT EM.Emp_ID,TD.Enroll_No,TD.IO_DateTime,TD.In_Out_flag,TD.IP_Address AS IN_IP_ADDRESS
				,ISNULL(IM.Device_Name,'') AS  Out_Punch_DeviceName
				FROM T9999_DEVICE_INOUT_DETAIL TD WITH (NOLOCK)
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




