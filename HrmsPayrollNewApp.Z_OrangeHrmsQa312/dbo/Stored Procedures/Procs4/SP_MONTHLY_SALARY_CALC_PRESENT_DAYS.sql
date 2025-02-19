CREATE PROCEDURE [dbo].[SP_MONTHLY_SALARY_CALC_PRESENT_DAYS]
	@Cmp_ID NUMERIC,
	@FROM_DATE DATETIME,
	@TO_DATE DATETIME,
	@CONSTRAINT VARCHAR(MAX) 
AS		
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	

	
		--declare @from_date datetime = '2016-02-01'
		DECLARE @nFromDate NUMERIC,@settingval as numeric = 0 --Condition added by Sumit  as per nimesh bhai suggestions for aashiana client query manual salary period..04052016
		SET @nFromDate = CAST(@from_date AS NUMERIC) - 1;
--select CAST(@nFromDate  + Day('1976-01-20') AS DATETIME) 
	Select @settingval = Setting_Value from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name = 'Present On Holiday And Weekoff Calculate On Shift Master Slab Wise.'
	
	CREATE TABLE #EMP_CONS_SAL(EMP_ID numeric PRIMARY KEY, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
	
	INSERT INTO #EMP_CONS_SAL (EMP_ID)
	SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@CONSTRAINT, '#');

	--Change by ronakk 09122022 cast sal start in emp sal cycle
	SELECT	-1 AS Branch_ID, C.EMP_ID,  CAST(@nFromDate  + Day(CM.Salary_St_Date ) AS DATETIME)  as Salary_St_Date
	INTO	#EMP_SAL_CYCLE
	from	T0095_Emp_Salary_Cycle C WITH (NOLOCK)
			INNER JOIN t0040_salary_cycle_master CM WITH (NOLOCK) ON C.SalDate_ID=CM.Tran_ID
			INNER JOIN #EMP_CONS_SAL E ON C.Emp_id=E.EMP_ID
	where	effective_date =(
						SELECT	MAX(effective_date) 
						from	T0095_Emp_Salary_Cycle C1 WITH (NOLOCK)
						where	C1.EMP_ID = C.Emp_id AND effective_date <=  @TO_DATE
								)

							


	SELECT	DISTINCT I.EMP_ID,(CASE WHEN IsNull(G.Manual_Salary_Period,0) =1 THEN ISNULL(SP.from_date,g.Sal_St_Date) ELSE  CAST(@nFromDate  + Day(g.Sal_St_Date) AS DATETIME) END) AS Sal_St_Date, 
			(CASE WHEN IsNull(G.Manual_Salary_Period,0) =1 THEN 
				ISNULL(SP.end_date,(Case when Year(g.Cutoffdate_salary) > 1900 then g.Cutoffdate_salary else dateadd(d,-1, dateadd(m,1,g.Sal_St_Date)) end)) 
			ELSE 
				(Case when Year(g.Cutoffdate_salary) > 1900 then g.Cutoffdate_salary else dateadd(d,-1, dateadd(m,1,g.Sal_St_Date)) end)
			END) AS Sal_End_Date, IsNull(G.Manual_Salary_Period,0) As Manual_Salary_Period, (Case When Year(g.Cutoffdate_salary) > 1900 Then 1 Else 0 END) As Is_CutOff
	INTO	#SAL_CYCLE
	FROM	t0030_branch_master b WITH (NOLOCK) inner join 
			t0040_general_setting g WITH (NOLOCK) on b.branch_id=g.branch_id
			INNER JOIN (SELECT MAX(FOR_DATE) AS FOR_DATE, BRANCH_ID FROM t0040_general_setting G1 WITH (NOLOCK) WHERE G1.For_Date <= @TO_DATE GROUP BY G1.BRANCH_ID) G1 ON G.Branch_ID=G1.BRANCH_ID AND G.FOR_DATE=G1.FOR_DATE
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON B.BRANCH_ID=I.BRANCH_ID
			INNER JOIN #EMP_CONS_SAL E ON I.Emp_id=E.EMP_ID
			LEFT OUTER JOIN #EMP_SAL_CYCLE SC ON E.EMP_ID=SC.EMP_ID
			INNER JOIN (
						SELECT	I2.EMP_ID, MAX(I2.INCREMENT_ID) AS INCREMENT_ID 
						FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
								INNER JOIN #EMP_CONS_SAL E ON I2.Emp_id=E.EMP_ID
								INNER JOIN (SELECT I3.EMP_ID, MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
											 FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #EMP_CONS_SAL E ON I3.Emp_id=E.EMP_ID
											 WHERE I3.Increment_Effective_Date <= @TO_DATE
											 GROUP BY I3.Emp_ID
											 ) I3 ON I2.Emp_ID=I3.EMP_ID AND I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE
						WHERE	I3.Increment_Effective_Date <= @TO_DATE
						GROUP BY I2.Emp_ID) I2 ON I.EMP_ID=I2.EMP_ID AND I.INCREMENT_ID=I2.INCREMENT_ID
			LEFT OUTER JOIN Salary_Period SP WITH (NOLOCK) ON SP.month = MONTH(@FROM_DATE) AND SP.year = YEAR(@FROM_DATE)
	--WHERE	SC.EMP_ID IS NULL	
	WHERE	(SC.EMP_ID IS NULL ) ---OR IsNull(G.Manual_Salary_Period,0) = 0) -- Commented by Hardik 20/11/2020 for Kataria as Salary cycle showing wrong due to Mix Salary Cycles


	

	DELETE ESC FROM #EMP_SAL_CYCLE ESC INNER JOIN #SAL_CYCLE SC ON ESC.Emp_id=SC.EMP_ID


	CREATE TABLE #SALARY_CYCLE(ROW_ID BIGINT IDENTITY(1,1) PRIMARY KEY, EMP_CONS VARCHAR(MAX), SAL_ST_DATE DATETIME, SAL_END_DATE DATETIME, Manual_Salary_Period tinyint, Is_CutOff Bit);

	INSERT INTO #SALARY_CYCLE
	SELECT (SELECT (SELECT	Cast(EMP_ID As Varchar(10)) + '#'
					 FROM	#SAL_CYCLE SC
					 WHERE	SC.SAL_ST_DATE=SC1.SAL_ST_DATE AND SC.SAL_END_DATE=SC1.SAL_END_DATE
							FOR XML PATH('')						 
					)), SAL_ST_DATE, SAL_END_DATE, Manual_Salary_Period, Is_CutOff
	FROM	(SELECT SAL_ST_DATE, SAL_END_DATE, Manual_Salary_Period,Is_CutOff FROM  #SAL_CYCLE SC1  GROUP BY SAL_ST_DATE, SAL_END_DATE,Manual_Salary_Period,Is_CutOff) SC1
	UNION ALL
	SELECT	(SELECT (SELECT CAST(EMP_ID AS VARCHAR(20)) + '#'
				FROM #EMP_SAL_CYCLE C1
				WHERE C1.Salary_St_Date = C2.Salary_St_Date 
				FOR XML PATH(''))) AS EMP_ID, C2.Salary_St_Date, DATEADD(d, -1, dateadd(m, 1, C2.Salary_St_Date)) As Salary_End_Date, Cast(0 AS tinyint) As Manual_Salary_Period, 0 AS Is_CutOff
	FROM	(SELECT Salary_St_Date FROM #EMP_SAL_CYCLE GROUP BY Salary_St_Date) C2 






	DECLARE @EMP_CONS VARCHAR(MAX);
	DECLARE @SAL_ST_DATE DATETIME;
	DECLARE @SAL_END_DATE DATETIME;
	DECLARE @Manual_Salary_Period tinyint	
	DECLARE @IS_CUTOFF BIT
	
	--For Calculate Present Days    
	CREATE TABLE #Data     
	(     
		Emp_Id     NUMERIC ,     
		For_date   DATETIME,    
		Duration_in_sec  NUMERIC,    
		Shift_ID   NUMERIC ,    
		Shift_Type   NUMERIC ,    
		Emp_OT    NUMERIC ,    
		Emp_OT_min_Limit NUMERIC,    
		Emp_OT_max_Limit NUMERIC,    
		P_days    NUMERIC(18, 4) default 0,    
		OT_Sec    NUMERIC default 0,
		In_Time DATETIME default null,
		Shift_Start_Time DATETIME default null,
		OT_Start_Time NUMERIC default 0,
		Shift_Change TINYINT default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  NUMERIC default 0,
		Holiday_OT_Sec  NUMERIC default 0	,
		Chk_By_Superior NUMERIC default 0,
		IO_Tran_Id	   NUMERIC default 0,
		OUT_Time DATETIME, 
		Shift_End_Time DATETIME,		--Ankit 16112013
		OT_End_Time NUMERIC default 0,	--Ankit 16112013
		Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time TINYINT default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18, 4) default 0 -- Added by Gadriwala Muslim 05012014	
		 --,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
	)
	
	/*************************************************************************
	Added by Nimesh: 02/Oct/2017
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/

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
				--Cmp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(10),
				W_Day			numeric(4,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
		END
	
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = N'Emp_PresentOnHoliday')
	BEGIN	
		Truncate table Emp_PresentOnHoliday
	END
	ELSE
	BEGIN
			CREATE TABLE Emp_PresentOnHoliday
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				PresOnHol_Day	numeric(18,0)
			)
			CREATE CLUSTERED INDEX IX_Emp_PresentOnHoliday ON Emp_PresentOnHoliday(Emp_ID, For_Date)		
	END


	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME = N'Emp_PresentOnWeekoff')
	BEGIN	
		Truncate table Emp_PresentOnWeekoff
	END
	ELSE
	BEGIN
			CREATE TABLE Emp_PresentOnWeekoff
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				PresOnWeek_Day	numeric(18,0)
			)
			CREATE CLUSTERED INDEX IX_Emp_PresentOnWeekoff ON Emp_PresentOnWeekoff(Emp_ID, For_Date)		
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
		
		END
	
	IF OBJECT_ID('tempdb..#HW_DETAIL') IS NULL
		BEGIN	
			CREATE TABLE #HW_DETAIL(EMP_ID NUMERIC, FOR_DATE DATETIME, Is_UnPaid TinyInt);
			CREATE UNIQUE CLUSTERED INDEX IX_HW_DETAIL_EMPID_FORDATE ON #HW_DETAIL(EMP_ID, FOR_DATE);
		END


		
	


	DECLARE CUR_EMP CURSOR FAST_FORWARD FOR
	SELECT EMP_CONS, SAL_ST_DATE, SAL_END_DATE,Manual_Salary_Period, IS_CutOff
	FROM #SALARY_CYCLE
	OPEN CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_CONS, @SAL_ST_DATE, @SAL_END_DATE,@Manual_Salary_Period,@IS_CUTOFF
	WHILE @@FETCH_STATUS = 0
		BEGIN
		IF (@Manual_Salary_Period <> 1 )
			BEGIN

				IF ABS(DATEDIFF(m, @FROM_DATE, @SAL_ST_DATE)) < 2
					BEGIN
						IF day(@Sal_St_Date) = 1
							BEGIN
								
								
								SET @SAL_END_DATE = DATEADD(yyyy,  YEAR(@TO_DATE) - YEAR(@SAL_END_DATE) , @SAL_END_DATE);
								SET @SAL_END_DATE = DATEADD(m,  MONTH(@TO_DATE) - MONTH(@SAL_END_DATE) , @SAL_END_DATE);
								
								SET @SAL_ST_DATE = DATEADD(m,  MONTH(@FROM_DATE) - MONTH(@SAL_ST_DATE) , @SAL_ST_DATE);
								SET @SAL_ST_DATE = DATEADD(yyyy,  YEAR(@FROM_DATE) - YEAR(@SAL_ST_DATE) , @SAL_ST_DATE);
								
								if @IS_CUTOFF <> 1 
									SET @SAL_END_DATE = DATEADD(d,-1,DATEADD(m, 1,@SAL_ST_DATE));
								
								if @IS_CUTOFF = 1   --Added by Jaina 15-12-2017
									set @SAL_ST_DATE = DATEADD(d,1,DATEADD(m, -1,@SAL_END_DATE))

							END
						ELSE
							BEGIN
								SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    							
								SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
							END
					END
				Else --Condition added by Sumit  as per nimesh bhai suggestions for aashiana client query manual salary period..04052016
					Begin						
						SET @SAL_END_DATE=DATEADD(D,-1,DATEADD(m,1,@Sal_St_date))
					End	
			END
			--SET @SAL_END_DATE = CONVERT(DATETIME, CONVERT(VARCHAR(6), @TO_DATE, 112) + CAST(DAY(@SAL_END_DATE) AS VARCHAR), 112);
			--SET @SAL_ST_DATE = 
				
			
			--print @SAL_END_DATE
			--truncate table #Data
			--SELECT * FROM #Data
		
			SET @EMP_CONS = LEFT(@EMP_CONS, LEN(@EMP_CONS)-1)			
			IF (@EMP_CONS  <> '')




			Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@FROM_DATE=@SAL_ST_DATE,@TO_DATE=@SAL_END_DATE,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@CONSTRAINT=@EMP_CONS,@Return_Record_set=4

			INSERT INTO #Data_SAL SELECT * FROM #Data
	
			
			
			if @settingval = 1 
			begin 
				
				Select * into #Data_SAL_value from #Data_SAL
				
				delete from #Data_SAL_value where in_time not in (Select In_time from #Data_SAL_value where Weekoff_OT_sec > 0 or Holiday_OT_sec > 0)

			end


			--select * from #Data_SAL

			/*FOR HOLIDAY WEEKOFF*/
			TRUNCATE TABLE #EMP_WEEKOFF
			TRUNCATE TABLE #EMP_HOLIDAY
			TRUNCATE TABLE #Emp_WeekOff_Holiday
			TRUNCATE TABLE #EMP_HW_CONS
			IF @IS_CUTOFF = 1
				BEGIN										
					SET @SAL_ST_DATE = DATEADD(D, -1 * DAY(@SAL_ST_DATE), @SAL_ST_DATE)  + 1					
				END
				
			EXEC SP_GET_HW_ALL @CONSTRAINT=@EMP_CONS,@CMP_ID=@Cmp_ID, @FROM_DATE=@SAL_ST_DATE, @TO_DATE=@SAL_END_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW =0

			

			-- Deepal ST :- 30/11/2022 Getting the count Week off base on salary generate date.19604
			IF ((SELECT SETTING_VALUE FROM T0040_SETTING WHERE CMP_ID = @CMP_ID AND  SETTING_NAME = 'COUNT OF ACTUAL DAY SALARY IN CURRENT MONTH') = 1)
			BEGIN
					--DECLARE @SALSTDATE AS DATE
					--SELECT @SALSTDATE = DATEADD(M,-1,SAL_ST_DATE) FROM #SAL_CYCLE WHERE EMP_ID = @EMP_CONS
					--DELETE FROM #EMP_WEEKOFF WHERE (FOR_DATE < @SALSTDATE OR FOR_DATE > CAST(GETDATE() AS DATE))
					--DELETE FROM #EMP_HOLIDAY WHERE (FOR_DATE < @SALSTDATE OR FOR_DATE > CAST(GETDATE() AS DATE))
					DELETE FROM #EMP_WEEKOFF WHERE FOR_DATE > CAST(GETDATE() AS DATE)
					DELETE FROM #EMP_HOLIDAY WHERE FOR_DATE > CAST(GETDATE() AS DATE)
			END
			-- Deepal ST :- 30/11/2022 Getting the count Week off base on salary generate date.19604
			
			

			INSERT INTO #EMP_WEEKOFF_SAL
			SELECT * FROM #EMP_WEEKOFF
			
			INSERT INTO #EMP_HOLIDAY_SAL
			SELECT * FROM #EMP_HOLIDAY

			INSERT INTO #Emp_WeekOff_Holiday_SAL
			SELECT * FROM #Emp_WeekOff_Holiday

			INSERT INTO #EMP_HW_CONS_SAL
			SELECT * FROM #EMP_HW_CONS

			INSERT INTO #HW_DETAIL_SAL
			SELECT * FROM #HW_DETAIL

			/*END OF HOLIDAY/WEEKOFF*/
	
			
			FETCH NEXT FROM CUR_EMP INTO @EMP_CONS, @SAL_ST_DATE, @SAL_END_DATE,@Manual_Salary_Period,@IS_CUTOFF
		END
						
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP;
					
					delete  from T0040_CALCULATION_HOLIDAY_SLABWISE	
					delete  from T0040_CALCULATION_WEEKOFF_SLABWISE	

					if @settingval = 0
					begin 
														--select * from #DATA
							-- Deepal Date :- 18072022
								IF ((SELECT COUNT(1) FROM #DATA WHERE HOLIDAY_OT_SEC > 0) > 0)
								BEGIN 
									INSERT INTO Emp_PresentOnHoliday	
									SELECT ROW_NUMBER() OVER (ORDER BY Emp_Id,For_Date) row_num, Emp_Id,For_date,Holiday_OT_Sec 
									FROM #Data where Holiday_OT_Sec > 0
								END
				
								IF ((SELECT COUNT(1) FROM #DATA WHERE Weekoff_OT_Sec > 0) > 0)  --Added by Mehul 08-05-2022
								BEGIN 
									INSERT INTO Emp_PresentOnWeekoff	
									SELECT ROW_NUMBER() OVER (ORDER BY Emp_Id,For_Date) row_num, Emp_Id,For_date,Weekoff_OT_Sec
									FROM #Data where Weekoff_OT_Sec > 0
								END
				
							-- Deepal Date :- 18072022
					end
					else
					begin
								IF ((SELECT COUNT(1) FROM #Data_SAL_value WHERE HOLIDAY_OT_SEC > 0) > 0)
								BEGIN 
									INSERT INTO T0040_CALCULATION_HOLIDAY_SLABWISE	
									SELECT ROW_NUMBER() OVER (ORDER BY Emp_Id,For_Date) row_num, Emp_Id,For_date,Holiday_OT_Sec,Shift_ID 
									FROM #Data_SAL_value where Holiday_OT_Sec > 0
								END
				
								IF ((SELECT COUNT(1) FROM #Data_SAL_value WHERE Weekoff_OT_Sec > 0) > 0)  --Added by Mehul 08-05-2022
								BEGIN 
									INSERT INTO T0040_CALCULATION_WEEKOFF_SLABWISE	
									SELECT ROW_NUMBER() OVER (ORDER BY Emp_Id,For_Date) row_num, Emp_Id,For_date,Weekoff_OT_Sec,Shift_ID
									FROM #Data_SAL_value where Weekoff_OT_Sec > 0
								END
					end

	
				
					if @settingval = 1 
					begin 
							Drop table #Data_SAL_value
					end
	
	RETURN;
