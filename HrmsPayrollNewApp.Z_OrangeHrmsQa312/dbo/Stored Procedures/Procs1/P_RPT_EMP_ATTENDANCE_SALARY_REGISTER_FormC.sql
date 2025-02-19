

-----------------------------------------------

--ADDED JIMIT 22022016------
---SALARY REGISTER FORMAT FORM-C FOR PUNJAB---
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_ATTENDANCE_SALARY_REGISTER_FormC]      
     @CMP_ID		NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		NUMERIC	
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@CAT_ID        NUMERIC = 0
	,@IS_COLUMN		TINYINT = 0
	,@SALARY_CYCLE_ID  NUMERIC  = 0
	,@SEGMENT_ID NUMERIC = 0 
	,@Vertical_Id NUMERIC = 0 
	,@SubVertical_Id NUMERIC = 0 
	,@SubBranch_Id NUMERIC = 0 
	,@SUMMARY VARCHAR(MAX)=''
	,@PBRANCH_ID VARCHAR(200) = '0'
	,@ORDER_BY   VARCHAR(30) = 'CODE' 
	,@REPORT_CALL VARCHAR(20) = 'IN-OUT'   
    ,@WEEKOFF_ENTRY VARCHAR(1) = 'Y'
    ,@STATE_ID  NUMERIC(18,0) = 0
    
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	
	
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)	
	EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	
	CREATE Table #Attendance
			(	
				 Emp_id numeric,
				 for_date		DATETIME,
				 Attendance Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Shift_Form_Hours Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Shift_To_Hours	Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Total_Shift_Hour Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Interval_From_HOur Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Interval_TO_HOur	Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Interval_Total		varchar(10)	COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Total_Working_hours	varchar(10)	COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS				
				,Total_OT		Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Leave_Apllication_Date	Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Leave_Approval_Date	Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Wages				NUMERIC(18,2)
				,Leave_Availed		NUMERIC(18,2)	DEFAULT 0
				,Total_Hours_Of_OT			Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS DEFAULT '00:00'
			)
			
		
			
	DECLARE @STATE_NAME VARCHAR(50)
	SELECT @STATE_NAME = ISNULL(STATE_NAME,'') FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE STATE_ID = @STATE_ID AND CMP_ID = @CMP_ID
			
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
		   IO_Tran_Id	   numeric default 0, 
		   OUT_Time datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	   )    
	   
	  
	DECLARE @OT_HOURS	AS NUMERIC(18,2)
	EXEC SP_CALCULATE_PRESENT_DAYS @CMP_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,4
	
	--SELECT * from #Data
	
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
	BEGIN
		--Holiday & WeekOff - In colon(;) seperated string (Without Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
		CREATE TABLE #Emp_WeekOff_Holiday
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
	
		--Holiday - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
		CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
	
		--WeekOff - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
		CREATE TABLE #Emp_WeekOff
		(
			Row_ID			NUMERIC,
			Emp_ID			NUMERIC,
			For_Date		DATETIME,
			Weekoff_day		VARCHAR(10),
			W_Day			numeric(3,1),
			Is_Cancel		BIT
		)
		CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
		
		
		--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
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
		
		
		
		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
	
		END
	
	
	
	DECLARE @HOliday_Dates VARCHAR(100)
	DECLARE @FromDAte	DATETIME
	DECLARE @ToDate	DATETIME
	--SET @FromDAte = @From_Date
	--SET @ToDate = @To_Date
	
	
	--SELECT @HOliday_Dates =  Isnull(RIGHT(RTRIM(HolidayDate), LEN(HolidayDate) - 1),0)  from #EMP_HW_CONS 
	
	-- changed by jimit 31082016 to remove the Invalid length parameter passed to the RIGHT function error
	 SELECT @HOliday_Dates =  Isnull(RIGHT(RTRIM(HolidayDate), case when LEN(HolidayDate) > 0 then LEN(HolidayDate) - 1 else 0 end),0)  from #EMP_HW_CONS
	
		
		
	Declare cur_emp cursor for 
	select Emp_ID From #Emp_Cons 
	open cur_emp
	fetch next from Cur_Emp into @Emp_ID 
	while @@fetch_Status = 0
		begin 
			If (@HOliday_Dates) <> ''
			Begin			
			INSERT INTO #Attendance(Emp_id,Attendance,for_date)
			SELECT @Emp_Id,'HO',DATA from dbo.Split((SELECT RIGHT(RTRIM(HolidayDate), LEN(HolidayDate) - 1) from #EMP_HW_CONS WHERE Emp_ID = @emp_id and HolidayDate<> ''),';')
			end
		fetch next from Cur_Emp into @Emp_ID 
		end 
	close cur_Emp
	Deallocate cur_Emp
	
	INSERT Into #Attendance(Emp_Id,Attendance,for_date)
	SELECT Ec.Emp_Id,'WO',EW.For_Date from #Emp_WeekOff EW
		INNER JOIN #EMP_CONS Ec	on Ec.EMP_ID = EW.emp_Id
	

	
	INSERT Into #Attendance(Emp_Id,Attendance,for_date)
	SELECT d.Emp_Id,
	( select case when P_days = 1 then 'P' 
				  WHEN P_days = 0.5 THEN 'HF'
	end)as Attendance,For_date
	 from #Data d INNER JOIN
	 #EMP_CONS EC On Ec.EMP_ID = D.Emp_Id
	 WHERE d.P_days > 0
	 
	 
	 
	 UPDATE A
		SET		A.Shift_Form_Hours = Q.Shift_St_Time
				,A.Shift_To_Hours = Q.Shift_End_Time
				,A.Total_Shift_Hour = Q.shift_Dur
				,A.Interval_From_HOur = Q.S_St_Time,
				A.Interval_TO_HOur = Q.S_End_Time,
				A.Interval_Total = Q.S_Duration				
				,A.Total_OT = Q.TOtal_OT
				,A.Total_Working_hours = Q.Total_Working_Hour
				,A.Total_Hours_Of_OT = q.Total_Hours_Of_OT
		from #Attendance  A Inner JOIN
				(
					SELECT D.EMP_ID,dbo.F_GET_AMPM(Shift_Start_Time) AS Shift_St_Time
							,dbo.F_GET_AMPM(Shift_End_Time) AS Shift_End_Time
							,DBO.F_RETURN_HOURS(DATEDIFF(SECOND,dbo.F_GET_AMPM(Shift_Start_Time),dbo.F_GET_AMPM(Shift_End_Time))) as shift_Dur
							,ES.Shift_ID,ES.S_St_Time,ES.S_End_Time,ES.S_Duration
							,(case when p_days <> 0 then
							DBO.F_RETURN_HOURS((D.OT_Sec))
								WHEN p_days = 0 THEN
							DBO.F_RETURN_HOURS((D.Weekoff_OT_Sec)+(D.Holiday_OT_Sec))
							end)as TOtal_OT,For_date
							,(case when p_days <> 0 then 
							DBO.F_RETURN_HOURS((DATEDIFF(SECOND,dbo.F_GET_AMPM(Shift_Start_Time),dbo.F_GET_AMPM(Shift_End_Time))- datepart(SECOND,Es.S_Duration))) 
							 end) as Total_Working_Hour
							,Q1.Total_Hours_OT as Total_Hours_Of_OT
							
					from #Data D inner JOIN
						(
							SELECT S_St_Time,S_End_Time,S_Duration,SM.Shift_ID,ESD.Emp_ID from T0040_SHIFT_MASTER SM WITH (NOLOCK)
								INNER join T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) On ESD.Shift_ID = Sm.Shift_ID
						)ES ON ES.Shift_ID = D.Shift_ID and ES.Emp_ID = D.Emp_Id INNER JOIN
						(
							SELECT emp_Id,DBO.F_RETURN_HOURS(SUM(IsNull(OT_Sec,0)+ISNULL(Weekoff_OT_Sec,0)+ IsNull(Holiday_OT_Sec,0))) as Total_Hours_OT
							from #Data GROUP BY Emp_Id
						)Q1 ON Q1.emp_Id = D.emp_Id							
				)Q ON Q.emp_Id = A.Emp_id and A.for_date = Q.for_Date


	Declare @Leave_Used numeric(18,2)
	DECLARE @For_Date DATETIME
	Declare @Leave_Approval_Date DATETIME
	Declare @Leave_Application_Date DATETIME
	DECLARE @Leave_Code as varchar(100)
	
	Declare cur_Leave cursor for 
		Select LT.Emp_Id,LT.For_Date,Isnull(LT.Leave_Used,0) + Isnull(LT.CompOff_Used ,0),LM.Leave_Code
		from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join #EMP_CONS EC on LT.Emp_ID=EC.EMP_ID  
		Inner Join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID
		where( LT.Leave_Used>0 or lt.CompOff_Used>0)	 And LT.For_Date BETWEEN @From_Date And @To_Date			
	open cur_Leave
	fetch next from cur_Leave into @Emp_ID ,@For_Date,@Leave_Used,@Leave_Code
	while @@fetch_Status = 0
		begin 
			Select @Leave_Approval_Date= LA.Approval_Date,@Leave_Application_Date=LA1.Application_Date
			From dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join   
			dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) On LA.Leave_Approval_ID = LAD.Leave_Approval_ID   LEFT Outer JOIN
			dbo.T0100_LEAVE_APPLICATION LA1 WITH (NOLOCK) On LA.Leave_Application_ID= LA1.Leave_Application_ID 
			Where From_Date <= @For_Date And To_Date >= @For_Date And LA.Emp_ID = @Emp_ID And LA.Approval_Status = 'A'
			and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.Emp_ID = @Emp_ID and LC.For_Date = @For_Date and LC.Is_Approve=1)
		
			If not EXISTS (Select 1 From #Attendance Where Emp_id=@Emp_Id and for_date=@For_Date)
				BEGIN
						INSERT Into #Attendance(Emp_Id,Attendance,for_date,Leave_Approval_Date,Leave_Apllication_Date,Leave_Availed)
						Select @Emp_Id,@Leave_Code,@For_Date,COnvert(varchar(20),@Leave_Approval_Date,103),COnvert(varchar(20),@Leave_Application_Date,103),@Leave_Used
				END
			Else
				BEGIN
					Update #Attendance Set Attendance = Attendance + ', ' + @Leave_Code, Leave_Approval_Date = COnvert(varchar(20),@Leave_Approval_Date,103), Leave_Apllication_Date= COnvert(varchar(20),@Leave_Application_Date,103)
										,Leave_Availed = @Leave_Used
					Where Emp_id=@Emp_Id And for_date=@For_Date
				END


			fetch next from cur_Leave into @Emp_ID ,@For_Date,@Leave_Used ,@Leave_Code
		end 
	close cur_Leave
	Deallocate cur_Leave
	
	
			
	Declare cur_Absent cursor for 
		SELECT distinct emp_Id from #Attendance			
	open cur_Absent
	fetch next from cur_Absent into @Emp_ID 
	while @@fetch_Status = 0	
		BEGIN
		SET @FromDAte = @From_Date
		SET	@ToDate = @To_Date
		WHILE @FromDAte < = @ToDate
		BEGIN
		If not EXISTS (Select 1 From #Attendance Where Emp_id=@Emp_Id and for_date=@FromDAte)
				BEGIN
						INSERT Into #Attendance(Emp_Id,Attendance,for_date)
						Select @Emp_Id,'A',@FromDAte
				END
				SET @FromDAte  = DATEADD(DAY,1,@FromDAte)
		END
		
		fetch next from cur_Absent into @Emp_ID 
		end 
	close cur_Absent
	Deallocate cur_Absent
		
		
		UPDATE A
		SET		A.Wages = Q.Net_Amount
		from  #Attendance A INNER JOIN
				(
					SELECT Net_Amount,Emp_ID 
					from T0200_MONTHLY_SALARY WITH (NOLOCK)
					where Month_St_Date > = @From_date and Month_St_Date <= @to_date
			)Q ON Q.Emp_ID = A.Emp_id
		
		SELECT A.*,E.Alpha_Emp_Code,D.Desig_Name,C.Cmp_Name,E.Emp_Full_Name,dbo.Age(E.Date_Of_Birth,getdate(),'Y') AS AGE,
			   E.Father_name,E.Date_Of_Join,Bm.Branch_Name,G.Grd_Name,T.[Type_Name],DM.Dept_Name
			  ,INC_QRY.Wages_Type
		from #Attendance A INNER JOIN
			 T0080_EMP_MASTER E WITH (NOLOCK) on A.Emp_id = E.Emp_ID  INNER JOIN
				(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Wages_Type
				 FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
					(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
					 FROM T0095_INCREMENT WITH (NOLOCK) 
					 WHERE INCREMENT_EFFECTIVE_DATE <= @To_date AND CMP_ID = @CMP_ID
					 GROUP BY EMP_ID  ) QRY ON
			I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON E.EMP_ID = INC_QRY.EMP_ID  INNER JOIN
			T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.CMP_ID = E.CMP_ID INNER JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN
			T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.DESIG_ID = INC_QRY.DESIG_ID LEFT JOIN
			T0040_GRADE_MASTER G WITH (NOLOCK) On G.Grd_ID = INC_QRY.Grd_ID  Left JOIN
			T0040_TYPE_MASTER T WITH (NOLOCK) On T.[Type_ID] = INC_QRY.[Type_ID] Left JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On Dm.Dept_Id = INC_QRY.Dept_ID
			--T0200_MONTHLY_SALARY Ms On Ms.Emp_ID = E.Emp_ID and E.Cmp_ID = Ms.Cmp_ID
		--where Month_St_Date > = @From_date and Month_St_Date <= @to_date and C.Cmp_ID = @Cmp_Id
		order BY 			
			Case When IsNumeric(Replace(Replace(E.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Emp_Code,'="',''),'"',''), 20)
				 When IsNumeric(Replace(Replace(E.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
				 Else Replace(Replace(E.Emp_Code,'="',''),'"','') End,for_date
		
		DROP TABLE #Attendance
