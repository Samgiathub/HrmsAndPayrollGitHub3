

-- =============================================
-- Author:		<Jaina>
-- Create date: <25-04-2017>
-- Description:	<In Out Summary Detail (Ess Homepage)>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_In_Out_Summary_Detail]
	@Cmp_Id numeric,
	@Emp_Id numeric
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @MONTH_ST_DATE AS DATETIME
	DECLARE @MONTH_END_DATE AS DATETIME
	DECLARE @TEMP_DATE AS DATETIME
	DECLARE @COUNTER AS NUMERIC
	DECLARE @STRHOLIDAY_DATE AS VARCHAR(MAX)
	DECLARE @STRWEEKOFF_DATE VARCHAR(MAX)
	DECLARE @SHIFT_ID NUMERIC
	DECLARE @SHIFT_NAME VARCHAR(500)
	DECLARE @LEAVE_ID NUMERIC
	DECLARE @LEAVE_NAME VARCHAR(500)
	DECLARE @LEAVE_USED NUMERIC(18,2)
	Declare @Late_Limit time
			
	
		
		CREATE TABLE #EMP_INOUT_DATA
		(
			EMP_ID NUMERIC,
			FOR_DATE DATETIME,
			SHIFT_ID NUMERIC,
			Shift_Time VARCHAR(250),
			Shift_Name varchar(250),
			Actual_In_Time varchar(50),
			In_Time varchar(50),
			Out_Time varchar(50),
			Late_In varchar(50),
			E_Status varchar(max)
		)
		/******* Get Employee Detail Start*****/
		CREATE TABLE #Emp_Cons 
       (      
			Emp_ID numeric ,     
			Branch_ID numeric,
			Increment_ID numeric    
		);
		CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);   
		
		INSERT	INTO #Emp_Cons(Emp_ID)        
		SELECT  @Emp_Id
		
		
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
												WHERE I3.Increment_effective_Date <= GETDATE() AND I3.Cmp_ID =@Cmp_Id
												GROUP BY I3.EMP_ID  
											) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
								GROUP BY I2.Emp_ID
							) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID
		
		/******* Get Employee Detail End *****/
		
		/**********************************************************************************/
								/******* Get Employee In Out Detail Start*****/
		/**********************************************************************************/
								
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
	   
		
		SET @Month_END_Date = CONVERT(DATETIME, CONVERT(char(10), GETDATE(), 103),103) --dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))
		SET @Month_ST_Date = DATEADD(D, -3, @Month_END_Date) -- dbo.GET_MONTH_ST_DATE(MONTH(GETDATE()),YEAR(GETDATE()))
		
			
		--select @Month_ST_Date,	@Month_END_Date											
	   	EXEC P_GET_EMP_INOUT @Cmp_ID=@Cmp_ID, @FROM_DATE =@Month_ST_Date, @TO_DATE=@Month_END_Date
	   	
	   	--Add Missing Date in #Data (Weekoff/Holiday/leave dates)
	   	DECLARE @startDate DATE, @endDate DATE
		SELECT @startDate = @Month_ST_Date, @endDate = @Month_END_Date --yyyy-mm-dd
		;WITH Calender AS (
		SELECT @startDate AS CalanderDate
		UNION ALL
		SELECT DATEADD(day,1,CalanderDate) FROM Calender
		WHERE DATEADD(day,1,CalanderDate) <= @endDate
		)
		INSERT INTO #Data(Emp_Id,For_date) 
		SELECT Emp_Id = @Emp_Id,For_date =CalanderDate
		FROM Calender c
		LEFT JOIN #Data t 
		ON t.For_date = c.CalanderDate
		WHERE t.For_date IS NULL order BY For_date
		option (maxrecursion 0)
		
		
		
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
		--it will fetch all employee's shift rotation detail if employee id is not specified.
		IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
			Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
		--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @Month_END_Date, @Emp_id	
		
		
		
		--Getting Shift from Shift Change Detail (Default Shift)
		UPDATE	#Data SET SHIFT_ID = SH.Shift_ID, Shift_Type=SH.Shift_Type
		FROM	#Data D,
				(	
					SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D ON SD.Emp_ID=D.Emp_Id
					WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
							AND SD.For_Date =	(Select	Max(For_Date)
												FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
												WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date <= D.For_date and ISNULL(SD1.Shift_Type,0)=0
												)
				) As SH
		WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID
		
		--Getting Shift from Monthly Shift Rotation Detail Detail 
		UPDATE	#Data 
		SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
		FROM	#Data D INNER JOIN #Rotation R ON R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
						AND D.Emp_Id=R.R_EmpID
				INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID	=SM.Shift_ID 
		WHERE	R.R_Effective_Date = (
										SELECT	MAX(R_Effective_Date)
										FROM	#Rotation R1 
										WHERE	R1.R_EmpID=Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
									) 
				AND NOT EXISTS(Select 1 from T0040_SHIFT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Inc_Auto_Shift=1 AND D.Shift_ID=D.Shift_ID)
				AND SM.Cmp_ID=@Cmp_ID	
		
		
		--Getting Shift from Shift Change Detail (Temporary)
		UPDATE	#Data SET SHIFT_ID = SH.Shift_ID, Shift_Type=SH.Shift_Type
		FROM	#Data D,
				(	
					SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D ON SD.Emp_ID=D.Emp_Id
					WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
							AND SD.For_Date =	(Select	Max(For_Date)
												FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
												WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date = D.For_date	
														AND SD1.Shift_Type=1														
												)
							AND NOT EXISTS (
												SELECT 1 FROM #Rotation R
												WHERE	SD.Emp_ID=R.R_EmpID AND R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
														AND R.R_Effective_Date = (
																				SELECT	MAX(R_Effective_Date)
																				FROM	#Rotation R1 
																				WHERE	R1.R_EmpID=D.Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
																			) 
											)													
				) As SH
		WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID
		
		--Getting Shift from Shift Change Detail (Regular)
		UPDATE	#Data SET SHIFT_ID = SH.Shift_ID, Shift_Type=SH.Shift_Type
		FROM	#Data D,
				(	
					SELECT	SD.Emp_ID,SD.Shift_ID, D.For_date,SD.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK) INNER JOIN #Data D ON SD.Emp_ID=D.Emp_Id
					WHERE	SD.Emp_ID=D.EMP_ID AND SD.Cmp_ID=@CMP_ID
							AND SD.For_Date =	(
													Select	Max(For_Date)
													FROM	T0100_EMP_SHIFT_DETAIL SD1 WITH (NOLOCK)
													WHERE	SD1.Emp_ID	=SD.Emp_ID AND SD1.Cmp_ID=SD.Cmp_ID	AND SD1.For_Date = D.For_date	
												)
							AND EXISTS (
											SELECT 1 FROM #Rotation R
											WHERE	SD.Emp_ID=R.R_EmpID AND R.R_DayName = 'Day' + CAST(DATEPART(d, D.For_date) As Varchar)
													AND R.R_Effective_Date = (
																				SELECT	MAX(R_Effective_Date)
																				FROM	#Rotation R1 
																				WHERE	R1.R_EmpID=D.Emp_Id AND R1.R_Effective_Date<=D.FOR_DATE
																			) 
										)													
				) As SH
		WHERE	SH.For_date	= D.For_date AND SH.Emp_ID=D.Emp_ID
		
		UPDATE	#Data
		SET		Shift_Start_Time = q.Shift_St_Time,
				Shift_End_Time = q.Shift_End_Time	   
		FROM	#data d INNER JOIN 
				(
					SELECT	ST.Shift_st_time,ST.Shift_ID,ISNULL(SD.OT_Start_Time,0) AS OT_Start_Time,
							ST.Shift_End_Time ,ISNULL(SD.OT_End_Time,0) AS OT_End_Time,
							Sd.Working_Hrs_St_Time,sd.Working_Hrs_End_Time
					FROM	dbo.t0040_shift_master ST WITH (NOLOCK) LEFT OUTER JOIN dbo.t0050_shift_detail SD WITH (NOLOCK)
							ON ST.Shift_ID=SD.Shift_ID 
					WHERE St.Cmp_ID = @Cmp_ID
				) q ON d.shift_id=q.shift_id

		
		/**********************************************************************************/
								/******* Get Employee In Out Detail End*****/
		/**********************************************************************************/
		
		
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;	
		
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
	BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
	END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
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
		DECLARE @All_Weekoff BIT
		SET @All_Weekoff = 0;

		EXEC SP_GET_HW_ALL @CONSTRAINT=@Emp_Id,@CMP_ID=@Cmp_ID, @FROM_DATE=@Month_ST_Date, @TO_DATE=@Month_END_Date, @All_Weekoff = @All_Weekoff, @Exec_Mode=0		

	END 
	select @StrHoliday_Date = HolidayDate, @StrWeekoff_Date = WeekOffDate from #EMP_HW_CONS
		
		

		set @TEMP_DATE = CONVERT(date,GETDATE())
		set @Counter = 0
		
		while @Counter < 4
		Begin
			
			select @SHIFT_ID = Shift_ID from #Data where For_date = @TEMP_DATE
			select @SHIFT_NAME = Shift_Name from T0040_SHIFT_MASTER WITH (NOLOCK) where Shift_ID = @SHIFT_ID 
			
			
			SELECT @LATE_LIMIT = DBO.F_RETURN_HHMM(EMP_LATE_LIMIT)
			FROM #DATA D INNER JOIN
				(
					SELECT I.EMP_ID,EMP_LATE_LIMIT,EMP_LATE_MARK 
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN   
						(
							SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
							FROM T0095_INCREMENT WITH (NOLOCK)		
							WHERE INCREMENT_EFFECTIVE_DATE <= GETDATE() AND CMP_ID = @CMP_ID  
							GROUP BY EMP_ID  
						 ) QRY ON  
					I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
				)IQ ON IQ.EMP_ID = D.EMP_ID AND IQ.EMP_LATE_MARK = 1 
			
			IF @LATE_LIMIT = ''
			BEGIN
				SELECT @Late_Limit = G.Late_Limit				
				FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK) inner JOIN 
					 #Emp_Cons E ON G.Branch_ID = E.Branch_ID
				WHERE Cmp_ID = @Cmp_ID and G.Is_Late_Mark = 1
				AND	For_Date = (
								 select MAX(For_Date) 
								 from T0040_GENERAL_SETTING G1 WITH (NOLOCK) inner join 
									  #Emp_Cons EC ON G1.Branch_ID = EC.Branch_ID
								 where Cmp_ID = @Cmp_ID and For_Date <= GETDATE()
								)	  	
			END
			 
			INSERT INTO #EMP_INOUT_DATA
			select Emp_Id,for_Date, Shift_ID,RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,Shift_Start_Time,100),8)),7) + ' To ' +
			RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,Shift_End_Time,100),8)),7) As ShiftTime,  
			@SHIFT_NAME,RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,In_Time,100),8)),7) As Actual_In_Time,
			RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,In_Time,100),8)),7) As In_Time,
			RIGHT('0'+LTRIM(RIGHT(CONVERT(varchar,OUT_Time,100),8)),7) As Out_Time,
			datediff(second,dbo.F_Return_HHMM(Shift_Start_Time),dbo.F_Return_HHMM(In_Time)) AS Late_In
			,''As E_Status
			from #Data where For_date = @TEMP_DATE
			
			update #EMP_INOUT_DATA SET Late_In = datediff(MINUTE,dbo.F_RETURN_HHMM(@LATE_LIMIT),dbo.F_Return_Hours(Late_In))
			where Late_In > 0
			
		
			
			IF CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrWeekoff_Date) > 0			
			BEGIN
					UPDATE #EMP_INOUT_DATA SET E_Status = 'Week Off'
					WHERE FOR_DATE = @TEMP_DATE
					--INSERT INTO #EMP_INOUT_DATA (EMP_ID,FOR_DATE,SHIFT_ID,Shift_Name,E_Status)
					--SELECT @EMP_ID,@TEMP_DATE,@SHIFT_ID,@SHIFT_NAME,E_Status = 'Week Off'
					
			END
			
			if CHARINDEX(CAST(@TEMP_DATE AS VARCHAR(11)), @StrHoliday_Date) > 0
			BEGIN
					UPDATE #EMP_INOUT_DATA SET E_Status = 'Holiday'
					WHERE FOR_DATE = @TEMP_DATE
					--INSERT INTO #EMP_INOUT_DATA (EMP_ID,FOR_DATE,SHIFT_ID,Shift_Name,E_Status)
					--SELECT @EMP_ID,@TEMP_DATE,@SHIFT_ID,@SHIFT_NAME,E_Status = 'Holiday'
										
			end	
			
			
			if exists ( SELECT 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_id AND For_Date=@TEMP_DATE AND Leave_Used> 0)
			BEGIN
				
				SELECT @Leave_ID = Leave_ID,@Leave_used = Leave_Used FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_id AND For_Date=@TEMP_DATE AND Cmp_ID = @CMP_ID
				SELECT @LEAVE_NAME = Leave_Name FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Cmp_ID=@cMP_ID AND Leave_ID = @Leave_ID
				
				IF EXISTS (SELECT 1 FROM #EMP_INOUT_DATA WHERE FOR_DATE = @TEMP_DATE)
				BEGIN
					
					UPDATE #EMP_INOUT_DATA SET E_STATUS = CONVERT(varchar(5),@Leave_used) +' Day '+ @LEAVE_NAME + ' is taken.'
					WHERE FOR_DATE = @TEMP_DATE
				END
				ELSE
				BEGIN
					--INSERT INTO #EMP_INOUT_DATA (EMP_ID,FOR_DATE,SHIFT_ID,Shift_Name)
					--SELECT @EMP_ID,@TEMP_DATE,@SHIFT_ID,@SHIFT_NAME
					
					UPDATE #EMP_INOUT_DATA SET E_Status = CONVERT(varchar(5),@Leave_used) +' Day '+ @LEAVE_NAME + ' is taken.'
					WHERE FOR_DATE = @TEMP_DATE
				END
			END
			else
			Begin
					UPDATE #EMP_INOUT_DATA SET E_STATUS = 'Absent'
					WHERE FOR_DATE = @TEMP_DATE and In_Time is NULL and Out_Time is null and E_Status = ''
			END
					
			set @TEMP_DATE = DATEADD(D, -1, @TEMP_DATE)
			
			set @Counter = @Counter + 1
			
			
		END
				
		SELECT Day(FOR_DATE) As Day, CAST(DATENAME(month,FOR_DATE)AS CHAR(3))AS 'Month',
			  CONVERT(VARCHAR(11),FOR_DATE,106)as For_Date,SHIFT_ID,Shift_Time,Shift_Name,
			  Actual_In_Time,In_Time,Out_Time,Late_In,E_Status,
			  case E_Status WHEN 'Week Off' THEN 'weekoff' 
							WHEN 'Holiday' THEN 'holiday' 
							ELSE 'summary' END As Summary_Class
		FROM #EMP_INOUT_DATA
END


