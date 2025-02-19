-----------------------------------------------

--ADDED JIMIT 01032017------
--- Form 13 Overtime Register---
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_Form13]      
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
	--,@IS_COLUMN		TINYINT = 0
	,@SALARY_CYCLE_ID  NUMERIC  = 0
	,@SEGMENT_ID NUMERIC = 0 
	,@Vertical_Id NUMERIC = 0 
	,@SubVertical_Id NUMERIC = 0 
	,@SubBranch_Id NUMERIC = 0 	
    
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	declare	@Total_Days_Of_Month as Numeric
	set @Total_Days_Of_Month = DATEDIFF(D,@FROM_DATE,@TO_DATE) + 1
	
	
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)	
	EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	CREATE Table #OverTime
			(	
				 Emp_id				numeric
				,for_date			DATETIME				 
				,Shift_Hour			Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,W_Day				Varchar(10) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,OT_Hour			Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Day_Rate			NUMERIC(18,2)
				,Total_Ot_Amount	Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
				,Total_OT_Hour		Varchar(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS				
			)
			
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
			   Shift_End_Time datetime,			
			   OT_End_Time numeric default 0,	
			   Working_Hrs_St_Time tinyint default 0, 
			   Working_Hrs_End_Time tinyint default 0, 
			   GatePass_Deduct_Days numeric(18,2) default 0 
		   )    
		   
		  
		DECLARE @OT_HOURS	AS NUMERIC(18,2)
		EXEC SP_CALCULATE_PRESENT_DAYS @CMP_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,4
			
		
		
		Declare	@From_Date_WeekOff datetime
		Declare	@To_Date_weekoff datetime
		
		set	@From_Date_WeekOff = convert(datetime,DATEADD(d,-7,@FROM_DATE),103)
		set	@To_Date_weekoff = DATEADD(d,7,@TO_DATE)
		 
		
		IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
			BEGIN
	
			CREATE table #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		
	
			----Holiday - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
		--	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));
		--	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
	
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
			
		
			
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID = @Cmp_ID, @FROM_DATE = @From_Date_WeekOff, @TO_DATE = @To_Date_weekoff, @All_Weekoff = 0, @Exec_Mode=0
	
		END
		
		
		
		--declare @for_Date datetime = '2017-02-11 00:00:00.000'
		
		--select Emp_ID, 8 * (7 -COUNT(1)), dateadd(d, ((DATEPART(WEEKDAY,@for_Date) -1) * -1), @for_Date) ,  dateadd(d, 7 - DATEPART(WEEKDAY,@for_Date), @for_Date)
		--from #Emp_WeekOff where Emp_ID = 18403 
		----and Row_ID=(day(@for_Date) / 7 + case when day(@for_Date) % 7 > 0 then 1 else 0 end ) 
		--and For_Date between dateadd(d, ((DATEPART(WEEKDAY,@for_Date) -1) * -1), @for_Date) AND  dateadd(d, 7 - DATEPART(WEEKDAY,@for_Date), @for_Date)
		--group by Emp_ID
		
		--select DBO.F_RETURN_HOURS(case when ) as shift_Dur,
		--	Shift_Start_Time,Shift_End_Time,* from #Data
		--return
		
		
		DECLARE  @TotalRow BigInt
		SET @TotalRow = DATEDIFF(D, @From_Date_WeekOff, @To_Date_weekoff);
		
		Select	DATEADD(D, ROW_ID, @From_Date_WeekOff) AS For_Date INTO #tmp_Dates
		FROM	(Select (ROW_NUMBER() OVER(Order BY OBJECT_ID) - 1) ROW_ID FROM sys.objects) T
		WHERE	ROW_ID <= @TotalRow
		
		
		Insert Into #OverTime(Emp_id,for_date)
		Select	Emp_Id,TD.for_Date 
		FROM	#EMP_CONS E CROSS JOIN #tmp_Dates TD 
		Order By EMP_ID, For_Date
		
		--Insert Into #OverTime(Emp_id,for_date)
		--Select Emp_Id,TD.for_Date 
		--from  #tmp_Dates TD FULL OUTER JOIN #Data D ON TD.For_Date=D.For_date
		--where (IsNull(OT_Sec,0)+ ISNULL(Weekoff_OT_Sec,0)+ IsNull(Holiday_OT_Sec,0)) > 0
			
	
	
		-------------------------------------------for getting the weekly dates and Hours--------------------------
		
			create table #TmpWeeks
			(
				FromDate	DateTime,
				ToDate		DateTime,
				TotalHrs	Numeric,
			)

			DECLARE @TmpFromDate DateTime  
			DECLARE @TmpToDate DateTime 
			
			
			SET @TmpFromDate = DATEADD(d, (DatePart(WEEKDAY, @FROM_DATE) -1) * -1, @FROM_DATE)
			SET @TmpToDate = DATEADD(d, 7 - DatePart(WEEKDAY, @To_Date), @To_Date)
			
			INSERT INTO #TmpWeeks(FromDate, ToDate, TotalHrs)
			SELECT	DATEADD(d, T.ROW_ID, @TmpFromDate), DATEADD(d, T.ROW_ID + 6, @TmpFromDate), 56
			FROM	(SELECT	TOP 35 (ROW_NUMBER() OVER(ORDER BY OBJECT_ID) -1) AS ROW_ID
					FROM	SYS.objects
					) T
			WHERE	T.ROW_ID % 7 = 0		
			
			-------------CREate weekoff,holiday and Leave table-----------------
			
			create table #EMP_HWL
			(
				EmpID		Numeric,
				For_Date	DateTime,
				W_Day		Numeric(5,2)
			)
			
			Insert into #EMP_HWL
			Select	Emp_ID,For_Date,W_Day 
			from	#Emp_WeekOff EW 			
			union all 
			
			select 	Emp_ID,For_Date,H_DAY 
			from	#EMP_HOLIDAY EH 							
			union All 
			
			Select	L.EMP_ID,L.For_Date,(Isnull(sum(Leave_Used),0) + ISNULL(sum(CompOff_Used),0)) as W_Day 
			from	T0140_LEAVE_TRANSACTION L WITH (NOLOCK)
					Inner join #EMP_CONS E On L.Emp_ID = E.EMP_ID
					Inner JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) On Lm.Leave_ID = L.Leave_ID and Lm.Cmp_ID = L.Cmp_ID
					LEFT Outer JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) On G.Branch_ID = E.BRANCH_ID						
			where   L.for_date between @from_date and @To_date
					and LM.Leave_Type <> 'Company Purpose' and G.Is_OD_Transfer_to_OT = 1					
			group by L.Emp_ID,L.For_Date
				
			----------------------------ended-------------------------
			
			
			
			
			
			
			
		-------------------------------------------end--------------------------------------------------------------
		
		 UPDATE O
		 SET
			O.Shift_Hour = Q.shift_Dur,				
			O.OT_Hour = Q.TOtal_OT,
			O.Total_OT_Hour	= Q.Total_Hours_OT		
		 from #OverTime  O Inner JOIN	
			 (
				SELECT D.EMP_ID,DBO.F_RETURN_HOURS(DATEDIFF(SECOND,Shift_Start_Time,Shift_End_Time)) as shift_Dur
							,(case when p_days <> 0 then
							DBO.F_RETURN_HOURS((D.OT_Sec))
								WHEN p_days = 0 THEN
							DBO.F_RETURN_HOURS((IsNull(D.OT_Sec,0)) + (D.Weekoff_OT_Sec)+(D.Holiday_OT_Sec))
							end)as TOtal_OT,D.For_date
							,Q1.Total_Hours_OT								
					from #Data D Inner join
					(
							SELECT emp_Id,DBO.F_RETURN_HOURS(SUM(IsNull(OT_Sec,0)+ISNULL(Weekoff_OT_Sec,0)+ IsNull(Holiday_OT_Sec,0))) as Total_Hours_OT
							from #Data
							GROUP BY Emp_Id
					)Q1 ON Q1.emp_Id = D.emp_Id		
			 )Q ON Q.emp_Id = O.emp_Id and Q.for_Date = O.for_date
			
			/*This logic will not be work in some cases so, need to rework on it*/
			UPDATE  O
			set		Shift_Hour = (Select Top 1 Shift_Hour FROM #OverTime O1 Where  O1.for_date < O.for_date AND O1.Shift_Hour IS NOT NULL Order BY for_date Desc)
			FROM	#OverTime O 
			Where	O.Shift_Hour Is Null
			
			
			------------------------for Updating the Null shift hours Logic-------------------------
			
			DECLARE @Temp_End_Date AS DATETIME			
			DECLARE @FOR_DATE AS DATETIME
			Declare	@curEmp_ID as Numeric
			
			
			DECLARE @Shift_Dur_N AS VARCHAR(10)			
			DECLARE @Is_Half_Day As numeric;
			DECLARE @Half_WeekDay Varchar(10);			
			DECLARE @Half_Shift_Dur AS VARCHAR(10);			
			DECLARE @PREVIOUS_END_TIME DATETIME
			
			Declare @Shift_ID as numeric
			
			
			DECLARE curShift CURSOR FOR
			SELECT Emp_ID,for_date 
			FROM  #OverTime
			WHERE Shift_Hour Is Null
			
			OPEN curShift                      
			FETCH NEXT FROM curShift INTO @curEmp_ID,@FOR_DATE
			   
				WHILE @@FETCH_STATUS = 0
					BEGIN
						
						SET @Half_Shift_Dur = NULL;  						
						SET @Shift_Dur_N = NULL;
						SET @Half_WeekDay = NULL;
						SET @Is_Half_Day = NULL;
						
						
						Exec SP_CURR_T0100_EMP_SHIFT_GET @curEmp_ID,@Cmp_ID,@FOR_DATE,NULL,NULL,
								@Shift_Dur_N output,null,null,null,null,NULL,@Is_Half_Day Output,@Half_WeekDay OUTPUT,NULL, 
								NULL,@Half_Shift_Dur output	
												
															
						IF DATENAME(WEEKDAY, @FOR_DATE) = @Half_WeekDay AND @Is_Half_Day = 1 AND @Half_Shift_Dur IS NOT NULL
							SET @Shift_Dur_N = @Half_Shift_Dur
							
						UPDATE #OVERTIME 
						SET	 SHIFT_HOUR = @Shift_Dur_N
						WHERE EMP_ID = @CUREMP_ID AND FOR_DATE = @FOR_DATE	
						
						
						FETCH NEXT FROM curShift INTO @curEmp_ID,@FOR_DATE			  
					END
			CLOSE curShift                    
			DEALLOCATE curShift
			
			-----------------------------------ended--------------------------------
			
			
			---update the working hours-----------
			
			UPDATE 	O
			SET		O.W_Day = WEEKLY_HRS			
			from	#Overtime O
					Cross Apply (Select SUM(CASE WHEN EW.W_Day IS NULL THEN ISNULL(dbo.F_Return_Sec(O1.Shift_Hour),0) / 3600 ELSE 0 END) AS WEEKLY_HRS, TW.FromDate, TW.ToDate 
								 FROM	#OverTime O1 
										INNER JOIN #TmpWeeks TW ON O1.for_date BETWEEN  TW.FromDate AND TW.ToDate
										LEFT OUTER JOIN #EMP_HWL EW ON O1.for_date=EW.For_Date AND O1.Emp_id=EW.EmpID
								 WHERE	O.for_date BETWEEN TW.FromDate AND TW.ToDate AND O.Emp_id=O1.Emp_id
								 GROUP BY TW.FromDate, TW.ToDate) O1
								
			
			
			
			
				
			Declare	@For_Date2 as datetime
			Declare @Emp_Id_WeekOff1 as Numeric
			
			
			
			
				print @Total_Days_Of_Month
				
				DECLARE Cur_Overtime  CURSOR FOR        
					SELECT for_date,emp_Id
					FROM #OverTime					
				OPEN Cur_Overtime        
				FETCH NEXT FROM Cur_Overtime INTO @For_Date2,@Emp_Id_WeekOff1     
				WHILE @@FETCH_STATUS = 0        
					BEGIN   					
							Update O
							SET
								O.Day_Rate = (Case when DBO.F_Return_Sec(O.Shift_Hour) <> 0 then
													((Isnull(new_inc.Basic_Salary,0) + Isnull(M_AD_Amount,0)) / (@Total_Days_Of_Month *  DBO.F_Return_Sec(O.Shift_Hour) /3600))
											  else
													0
											   end)
								,O.Total_Ot_Amount = (Case when DBO.F_Return_Sec(O.Shift_Hour) <> 0 then
													cast(round(((Isnull(new_inc.Basic_Salary,0) + Isnull(M_AD_Amount,0)) * new_inc.Emp_WeekDay_OT_Rate * (DBO.F_Return_Sec(O.OT_Hour) / 3600)/ (@Total_Days_Of_Month *  DBO.F_Return_Sec(O.Shift_Hour) /3600)),2)as Numeric(18,2)) 
											  else
													0
											   end)										   							
							FROM #OverTime O Inner join	
										(SELECT top 1 MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID,I3.Basic_Salary,I3.Emp_WeekDay_OT_Rate
										 FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID 
										 WHERE I3.Cmp_ID = @CMP_ID and I3.Emp_ID = @Emp_Id_WeekOff1
												and @For_Date2 >= I3.INCREMENT_EFFECTIVE_DATE
										 GROUP BY I3.EMP_ID,I3.Basic_Salary,I3.Emp_WeekDay_OT_Rate
										 ORDER BY INCREMENT_EFFECTIVE_DATE DESC								
										 )new_inc ON new_inc.Emp_ID = O.Emp_ID LEFT OUTER JOIN										
									
									(SELECT EE.EMP_ID,IsNULL(Sum(E_AD_AMOUNT),0) as M_AD_Amount
									FROM T0100_EMP_EARN_DEDUCTION EE WITH (NOLOCK)
									INNER JOIN
											(
													SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,EED.AD_ID,EED.EMP_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  Inner JOIN
													( 
														SELECT MAX(FOR_DATE)AS FOR_DATE,EED.AD_ID,EED.EMP_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
														WHERE CMP_ID = @CMP_ID AND EED.EMP_ID = @EMP_ID_WEEKOFF1 AND FOR_DATE <= @FOR_DATE2		
														GROUP BY EED.EMP_ID,EED.AD_ID,EED.FOR_DATE
													) INN_QRY ON INN_QRY.FOR_DATE = EED.FOR_DATE AND  INN_QRY.AD_ID = EED.AD_ID AND INN_QRY.EMP_ID = EED.EMP_ID
													WHERE CMP_ID = @CMP_ID AND EED.EMP_ID = @EMP_ID_WEEKOFF1 AND EED.FOR_DATE <= @FOR_DATE2	
													GROUP BY EED.EMP_ID,EED.AD_ID
											)QRY ON QRY.EMP_ID = EE.EMP_ID AND QRY.AD_ID = EE.AD_ID AND QRY.INCREMENT_ID =EE.INCREMENT_ID Inner join																			
									 T0050_AD_MASTER MAD WITH (NOLOCK) ON MAD.AD_ID = Qry.AD_ID
									 WHERE	AD_EFFECT_ON_OT = 1 AND Mad.CMP_ID = @CMP_ID
									 GROUP BY EE.EMP_ID) MAD  ON Mad.Emp_ID = new_inc.Emp_ID --and  @For_Date2 >= new_inc.INCREMENT_EFFECTIVE_DATE
							WHERE O.EMP_ID = @EMP_ID_WEEKOFF1 AND O.FOR_DATE = @FOR_DATE2
												
						
					FETCH NEXT FROM Cur_Overtime INTO @For_Date2,@Emp_Id_WeekOff1        
					END
				CLOSE Cur_Overtime        
				DEALLOCATE Cur_Overtime
					
						
			SELECT O.*,E.Alpha_Emp_Code,D.Desig_Name,C.Cmp_Name,E.Emp_Full_Name,
				   E.Date_Of_Join,Bm.Branch_Name,G.Grd_Name,T.[Type_Name],DM.Dept_Name,
				   Emp_WeekDay_OT_Rate,@To_Date as to_date		  
			from #OverTime O INNER JOIN
				 T0080_EMP_MASTER E WITH (NOLOCK) on O.Emp_id = E.Emp_ID  INNER JOIN
					(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Wages_Type,I.Emp_WeekDay_OT_Rate
					 FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
						 FROM T0095_INCREMENT WITH (NOLOCK) 
						 WHERE INCREMENT_EFFECTIVE_DATE <= @To_date AND CMP_ID = @CMP_ID
						 GROUP BY EMP_ID  ) QRY ON
				I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON E.EMP_ID = INC_QRY.EMP_ID  INNER JOIN
				T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.CMP_ID = E.CMP_ID INNER JOIN
				T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN
				T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON D.DESIG_ID = INC_QRY.DESIG_ID LEFT JOIN
				T0040_GRADE_MASTER G  WITH (NOLOCK) On G.Grd_ID = INC_QRY.Grd_ID  Left JOIN
				T0040_TYPE_MASTER T WITH (NOLOCK) On T.[Type_ID] = INC_QRY.[Type_ID] Left JOIN
				T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On Dm.Dept_Id = INC_QRY.Dept_ID	
			where for_date between @FROM_DATE and @TO_DATE	and O.OT_Hour <> '00:00'
			order BY 			
				Case When IsNumeric(Replace(Replace(E.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Emp_Code,'="',''),'"',''), 20)
					 When IsNumeric(Replace(Replace(E.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
					 Else Replace(Replace(E.Emp_Code,'="',''),'"','') End,for_date
			
			drop table  #OverTime