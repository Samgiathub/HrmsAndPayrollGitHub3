CREATE PROCEDURE [dbo].[Mobile_HRMS_SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET_TEST]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_For	varchar(50) = 'EMP RECORD'
	,@Graph_flag	varchar(50) = ''
	,@ReloadData	BIT = 1	
	,@Shift_ID		Numeric = 0  --Added by Jaina 27-02-2018
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON   
	  
	Declare @IsMobileInOut Bit
	SET @IsMobileInOut = 0
	Declare @IsCalendar Bit
	SET @IsCalendar = 0
	Declare @Tras_Week_OT tinyint
	set @Tras_Week_OT = 0


	if @Report_For = 'Mobile In-Out'
	BEGIN
		SET @IsMobileInOut = 1
		SET @Report_For = 'IN-OUT'
	END
	ELSE IF @Report_For = 'CALENDAR'
	BEGIN
		SET @IsCalendar = 1
		SET @Report_For = 'IN-OUT'
	END

		
	IF @Report_For <> 'BulkRegularization'  AND @Report_For <> 'BulkRegularization_Mobile' AND @IsCalendar = 0 --Added by Jaina 26-02-2018
		BEGIN
			--Added By Hiral 15 April,2013 (Start)
			Declare @Sal_St_Date	Datetime
			Declare @Sal_end_Date   Datetime 
			Declare @OutOf_Days		NUMERIC  
			Declare @ForDate		Datetime --Added by Jaina 22-02-2018
			SET @ForDate = @From_Date --Added by Jaina 22-02-2018
			
			Declare @Is_Cancel_Holiday_WO_HO_same_day tinyint --Added By nilesh on 01122015(For Cancel Holiday When WO/HO on Same Day
			SET @Is_Cancel_Holiday_WO_HO_same_day = 0

			declare @manual_salary_period as numeric(18,0)
		   	
			IF IsNull(@Emp_ID ,0) > 0
				SELECT	@Branch_ID =I.Branch_ID 
				FROM	T0095_Increment I 
						INNER JOIN (
										SELECT	MAX(TI.Increment_ID) Increment_Id,TI.Emp_ID 
										FROM	T0095_increment TI 
												INNER JOIN (
															SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date,I.Emp_ID
															FROM	T0095_Increment I
															WHERE	Increment_effective_Date <= @TO_DATE AND I.Emp_ID=@Emp_ID 
															GROUP BY I.emp_ID
															) NEW_INC ON TI.Emp_ID = NEW_INC.Emp_ID AND TI.Increment_Effective_Date=NEW_INC.Increment_Effective_Date
										WHERE	TI.Emp_ID=@Emp_ID 
										GROUP BY TI.Emp_ID
			) Qry on I.Increment_Id = Qry.Increment_Id

			   

			IF @BRANCH_ID IS NULL
				BEGIN 
					-- CHANGED BY GADRIWALA MUSLIM 06102016 - REPLACE INNER MAX QUERY TO INNER JOIN MAX QUERY
					SELECT TOP 1 @SAL_ST_DATE  = SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=IsNull(MANUAL_SALARY_PERIOD ,0),
					  @IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY = IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY,
					  @Tras_Week_OT = IsNull(Tras_Week_OT,0)
					  FROM T0040_GENERAL_SETTING GS INNER JOIN (
						 SELECT  MAX(FOR_DATE) FOR_DATE FROM T0040_GENERAL_SETTING
						 WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID
					   ) QRY ON QRY.FOR_DATE = GS.FOR_DATE
					   WHERE CMP_ID = @CMP_ID    
					  
				END
			ELSE
				BEGIN
					-- CHANGED BY GADRIWALA MUSLIM 06102016 - REPLACE INNER MAX QUERY TO INNER JOIN MAX QUERY
					SELECT @SAL_ST_DATE  =SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=IsNull(MANUAL_SALARY_PERIOD ,0),
					  @IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY = IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY,
					  @Tras_Week_OT = IsNull(Tras_Week_OT,0)
					  FROM T0040_GENERAL_SETTING GS INNER JOIN
					  (
							SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING 
							WHERE FOR_DATE <= @TO_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
							GROUP BY BRANCH_ID
					  )QRY ON QRY.FOR_DATE = GS.FOR_DATE AND QRY.BRANCH_ID= GS.BRANCH_ID
					  WHERE CMP_ID = @CMP_ID AND GS.BRANCH_ID = @BRANCH_ID    
					  
				END 
			
				
			if IsNull(@Sal_St_Date,'') = ''    
				BEGIN    
					SET @From_Date  = @From_Date     
					SET @To_Date = @To_Date    
					SET @OutOf_Days = @OutOf_Days
				END  				     
			ELSE IF day(@Sal_St_Date) =1
				BEGIN    
					SET @From_Date  = @From_Date  
					SET @To_Date = @To_Date    
					SET @OutOf_Days = @OutOf_Days    	         
				END				  		  
			ELSE IF @Sal_St_Date <> ''  AND day(@Sal_St_Date) > 1   
				BEGIN   
					IF @manual_salary_period = 0 
					   BEGIN
							SET @Sal_St_Date = DateAdd(D,DAY(@Sal_St_Date), DateAdd(d, Day(@From_Date) *-1, @From_Date))
							IF DAY(@Sal_St_Date) > Day(@From_Date)
								SET @Sal_St_Date = DateAdd(M, -1, @Sal_St_Date)
								
							--SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,DateAdd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(YEAR(DateAdd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
							SET @Sal_End_Date = DateAdd(d,-1,DateAdd(m,1,@Sal_St_Date)) 
							SET @OutOf_Days = DateDiff(d,@Sal_St_Date,@Sal_End_Date) + 1
			
							SET @From_Date = @Sal_St_Date
							SET @To_Date = @Sal_End_Date 
						END 
					ELSE
						BEGIN
							select @Sal_St_Date=from_date,@Sal_End_Date=end_date FROM salary_period WHERE MONTH= MONTH(@From_Date) AND YEAR=YEAR(@From_Date)
							SET @OutOf_Days = DateDiff(d,@Sal_St_Date,@Sal_End_Date) + 1
							SET @From_Date = @Sal_St_Date
							SET @To_Date = @Sal_End_Date 
						END   
				  END
		END
	
	SELECT	TOP 1 @IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY = IS_CANCEL_HOLIDAY_WO_HO_SAME_DAY, @Tras_Week_OT = IsNull(Tras_Week_OT,0)
	FROM	T0040_GENERAL_SETTING GS 
			INNER JOIN (SELECT  MAX(FOR_DATE) FOR_DATE 
						FROM	T0040_GENERAL_SETTING
						WHERE	FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID AND BRANCH_ID = IsNull(@BRANCH_ID,BRANCH_ID)) QRY ON QRY.FOR_DATE = GS.FOR_DATE
	WHERE	CMP_ID = @CMP_ID AND GS.BRANCH_ID = IsNull(@BRANCH_ID,GS.BRANCH_ID)	
	
	
	
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
		
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  


	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0
	
	
	IF @Report_For = 'EMP RECORD'
		BEGIN

			Select E.Emp_ID ,E.Emp_code,E.Emp_full_Name,Comp_Name,Branch_Address 
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,cmp_Name,Cmp_Address
			From #Emp_Cons EC INNER JOIN  T0080_EMP_MASTER E ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
			 T0095_Increment Q_I ON			
			E.EMP_ID = Q_I.EMP_ID AND E.Increment_ID = Q_I.Increment_ID
			INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN
			T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
			return 
		END


	IF OBJECT_ID('tempdb..#TMP_EMP_0150_INOUT') IS NULL
		BEGIN
			SElECT TOP 0 * INTO #TMP_EMP_0150_INOUT FROM T0150_EMP_INOUT_RECORD WHERE 1<>1
			CREATE CLUSTERED INDEX IX_TMP_INOUT ON #TMP_EMP_0150_INOUT (For_Date Desc,Emp_ID, In_Time,Out_Time)
			
			INSERT INTO #TMP_EMP_0150_INOUT
			SELECT EIR.* FROM dbo.T0150_EMP_INOUT_RECORD EIR INNER JOIN #EMP_CONS EC ON EIR.EMP_ID=EC.EMP_ID
			WHERE	FOR_DATE BETWEEN (@FROM_DATE - 7) AND (@To_Date + 7)
		END

	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	declare @Date_of_join datetime  --Added by Jaina 25-12-2017
	declare @Left_date datetime --Added by Jaina 25-12-2017
	
	SET @Date_Diff = DateDiff(d,@From_Date,@to_DAte) + 1 
	SET @Date_Diff = 35 - ( @Date_Diff)
	SET @New_To_Date = @To_Date --DateAdd(d,@date_diff,@To_Date)
	
	Create TABLE #Att_Period
	(
		For_Date	datetime,
		Row_ID		numeric
	)
	 
	SET @For_Date = @From_Date
	SET @Row_ID = 1
	

	While @For_Date <= @New_To_Date
		BEGIN
				insert into #Att_Period 
				select @For_Date,@Row_ID
				
				SET @Row_ID =@Row_ID + 1
				SET @for_Date = DateAdd(d,1,@for_date)								
		end
		
	
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
		P_days  numeric(12,2) default 0,        
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
		--,Working_sec_Between_Shift numeric(18) default 0 -- Commented by Niraj(20062022)
	)        

	CREATE NONCLUSTERED INDEX ix_Data_Emp_Id_For_date on #Data(Emp_Id,For_Date);
	
	Create TABLE #Att_Muster
	(
		Emp_Id		numeric , 
		Cmp_ID		numeric,
		branch_ID	numeric,
		For_Date	datetime,
		Status		varchar(10),
		Leave_code	varchar(50) default '-',
		Leave_Count	numeric(5,2),
		OD			varchar(10) default '-',
		OD_Count	numeric(5,2),
		WO_HO		varchar(2),
		Status_2	varchar(10),
		Row_ID		numeric ,
		In_Date		datetime,
		Out_Date	Datetime,
		shift_id	numeric,
		shift_name  varchar(50),
		sh_in_time varchar(10),
		sh_out_time varchar(10),
		holiday varchar(50),
		late_limit varchar(10),
		Reason varchar(1000),
		Half_Full_Day Varchar(20),
		Chk_By_Superior varchar(15),
		Sup_Comment varchar(1000),
		Is_Cancel_Late_In tinyint default 0,  -- Alpesh 02-Aug-2011 For Attendance Regularization
		Is_Cancel_Early_Out tinyint default 0, -- Alpesh 02-Aug-2011 For Attendance Regularization
		Early_Limit varchar(10),
		Main_Status varchar(10),
		Detail_Status varchar(50),
		Is_Late_Calc_On_HO_WO	tinyint,
		Is_Early_Calc_On_HO_WO	tinyint,
		late_minute numeric default 0, -- Added by rohit on 18102013
		Early_minute Numeric default 0, -- Added by rohit on 18102013
		Is_Leave_App tinyint default 0,
		Other_Reason	varchar(1000)	null,	--Added by Nimesh 31-Aug-2015
		R_Emp_ID numeric default 0,  --Mukti(04092017)
		Att_Approval_Days Numeric(3,2) default 0,
		Att_App_ID Numeric(5,0) default 0,
		Att_Apr_Status Char(1) default '',
		Shift_Duration Varchar(10) default NULL,
		OT_Apr_ID Numeric(10,0) default 0,
		Comp_off_App Numeric(5,0) default 0,
		Comp_off_Apr Numeric(5,0) default 0,
		OT_Applicable Tinyint default 0,
		Display_Birth char default 'F', --Added By Jimit 13022019
		Display_Marriage_Date char default 'F' --Added By Jimit 13022019
	)

	CREATE UNIQUE NONCLUSTERED INDEX ix_Att_Muster_Emp_Id on #Att_Muster(Emp_Id,For_Date) INCLUDE(Cmp_ID,Branch_ID);	  
		
	declare @get_date as datetime
	SET @get_date=cast(getdate() as varchar(11))
	
	
	
	insert into #Att_Muster (Emp_ID,Cmp_ID,branch_ID,For_Date,row_ID)
	select 	E.Emp_ID ,E.Cmp_ID,EC.branch_ID,For_Date,row_ID FROM #Att_Period cross join #Emp_Cons EC Inner Join T0080_EMP_MASTER E ON EC.Emp_ID = E.Emp_ID
	

	--Added by Jaina 26-12-2017
	alter table #Att_Muster add Date_of_join datetime, Left_date datetime
	
	update #Att_Muster set Date_of_join = E.DATE_OF_JOIN, 
							Left_date = E.EMP_LEFT_DATE,
							Display_Birth=(case when month(Date_Of_Birth) = month(For_Date) and day(Date_Of_Birth) = day(For_Date) then 'Y' else 'F' end),  --Added By Jimit 13022019
							Display_Marriage_Date = case when (Emp_Annivarsary_Date IS NULL or Convert(varchar(11),convert(datetime,Emp_Annivarsary_Date),121) = '1900-01-01' or Emp_Annivarsary_Date = '') then 'F' else (case when month(Emp_Annivarsary_Date) = month(For_Date) and day(Emp_Annivarsary_Date) = day(For_Date) then 'Y' else 'F' end)   end --Added By Jimit 13022019
	FROM T0080_EMP_MASTER E INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID
	inner JOIN #Att_Muster A ON A.Emp_Id = EC.Emp_ID	
	
	/********************************************************************
	Added by Nimesh : Using new employee weekoff/holiday stored procedure
	*********************************************************************/
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
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
		)
	
		--Holiday - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
		CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
	
		--WeekOff - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
		CREATE TABLE #Emp_WeekOff
		(
			Row_ID			NUMERIC,
			Emp_ID			NUMERIC,
			For_Date		DATETIME,
			Weekoff_day		VARCHAR(10),
			W_Day			numeric(4,1),
			Is_Cancel		BIT
		)
		CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
		
		
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
		)
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
		
		
		--EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
		
	--Here Condition is Added By Ramiz on 14/04/2016 after discussion with Hardik Bhai
		If @Report_For <> 'ABSENT_CON'
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
		--ELSE IF @Report_For = 'ABSENT_CON' AND @Cancel_WKOF <> 1 
		--	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
		END
			

		
	--Changed Branch_Id variable by Hardik 09/02/2016 as Branch Id taken in #Emp Cons table
	--select 	Emp_ID ,@Cmp_ID ,@branch_ID,For_Date,row_ID FROM #Att_Period cross join #Emp_Cons

	--Commented by Hardik 09/02/2016 as Branch Id taken in #Emp Cons table
	--update #Att_Muster 
	--set branch_ID = inc.Branch_ID
	--from #Att_Muster AM inner join 
	--(select I.Emp_Id,i.Branch_ID FROM T0095_Increment I inner join
	--	(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI inner join
	--		(Select Max(I.Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID FROM T0095_Increment I INNER JOIN #Emp_Cons EC on I.Emp_ID = EC.Emp_ID
	--		  WHERE I.Increment_effective_Date <= @to_date Group by I.emp_ID
	--		 ) new_inc on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
	--		Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
	--	 ) Qry on I.Increment_Id = Qry.Increment_Id
								 
	--	--(select max(Increment_effective_Date) as For_Date , Emp_ID 
	--	--	From T0095_Increment WHERE Increment_Effective_date <= @From_Date
	--	--	and Cmp_ID = @Cmp_ID group by emp_ID  
	--	--) Qry on I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date WHERE Cmp_ID = @Cmp_ID 
	-- ) Inc 
	--on inc.Emp_ID = am.Emp_Id		-- added by mitesh on 31/01/2012					

	
		
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id AND effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.


	
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation(R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure	
	IF (IsNull(@constraint,'') = '' AND @EMP_ID > 0)					
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, @EMP_ID, @To_Date,NULL
		
	Else
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @Constraint
		
	
	
	--Added for adding weekk off n holiday detail of whole month Alpesh 09-Sep-2011
	declare @Main_To_Date datetime
	SET @Main_To_Date = @To_Date
	
	if @get_date<@To_Date
		SET @To_Date=@get_date    
		--select * FROM #Att_Muster					

	SET @For_Date = @From_Date
	declare @Att_date as datetime
	select @Att_date= max(for_date) FROM #Att_Muster
	While @for_Date <= @Att_date
		BEGIN
			--Modified by Nimesh  20 May 2015
			--Updating default shift info FROM Shift Detail
			UPDATE	#Att_Muster SET SHIFT_ID = Shf.Shift_ID
			FROM	#Att_Muster AM INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID 
			FROM	T0100_EMP_SHIFT_DETAIL esd INNER JOIN  
					(SELECT MAX(For_Date) AS For_Date,ESD.Emp_ID FROM T0100_EMP_SHIFT_DETAIL ESD INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
						WHERE For_Date <= @For_Date AND IsNull(Shift_Type,0) = 0 GROUP BY ESD.Emp_ID) S ON 
						esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
					Shf.Emp_ID = AM.EMP_ID 
			WHERE	AM.For_Date=@For_Date

			--Updating Shift ID FROM Rotation
			UPDATE	#Att_Muster 
			SET		SHIFT_ID=SM.SHIFT_ID
			FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
			WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @for_Date) As Varchar) AND
					Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
						FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
							 R_Effective_Date<=@for_Date) 
					AND For_Date=@For_Date
					

	
			--Updating Shift ID FROM Employee Shift Detail WHERE ForDate=@TempDate AND Shift_Type=1 
			--And Rotation should be assigned to that particular employee
			UPDATE	#Att_Muster 
			SET		shift_id=ESD.SHIFT_ID
			FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
					WHERE For_Date = @For_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	ESD.Emp_ID IN (
									Select	DISTINCT R.R_EmpID 
									FROM	#Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) 
											AND R_Effective_Date<=@For_Date
								) 
					AND D.For_date=@For_Date

			
			--Updating Shift ID FROM Employee Shift Detail WHERE ForDate=@TempDate AND Shift_Type=1 
			--And Rotation should not be assigned to that particular employee
			UPDATE	#Att_Muster 
			SET		SHIFT_ID=ESD.SHIFT_ID
			FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
					WHERE For_Date = @For_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	ESD.Emp_ID NOT IN (
											Select	DISTINCT R.R_EmpID 
											FROM	#Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @For_Date) As Varchar) 
													AND R_Effective_Date<=@For_Date
										) 
					AND IsNull(ESD.Shift_Type,0)=1 AND D.For_date=@For_Date
			--End Nimesh
										 												
			
			UPDATE #ATT_MUSTER SET 
				IS_LATE_CALC_ON_HO_WO =  Q_W.IS_LATE_CALC_ON_HO_WO
			   ,IS_EARLY_CALC_ON_HO_WO = Q_W.IS_EARLY_CALC_ON_HO_WO
			FROM #ATT_MUSTER AM INNER JOIN
				#EMP_CONS EC ON AM.EMP_ID = EC.EMP_ID INNER JOIN
				(
					SELECT Q.BRANCH_ID,Q1.FOR_DATE,Q1.LATE_LIMIT,Q1.EARLY_LIMIT,Q1.IS_LATE_CALC_ON_HO_WO,Q1.IS_EARLY_CALC_ON_HO_WO 
					FROM T0040_GENERAL_SETTING Q1 INNER JOIN
					 (
						SELECT MAX(FOR_DATE)AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING 
						WHERE FOR_DATE <= @FOR_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID 
					 )Q ON Q1.BRANCH_ID =Q.BRANCH_ID AND Q1.FOR_DATE = Q.FOR_DATE
				)Q_W ON EC.BRANCH_ID=Q_W.BRANCH_ID
			WHERE AM.FOR_DATE = @FOR_DATE
			
			UPDATE #ATT_MUSTER SET
				LATE_LIMIT = IE.EMP_LATE_LIMIT
				,EARLY_LIMIT = IE.EMP_EARLY_LIMIT
				,OT_Applicable = IE.Emp_OT
				FROM #ATT_MUSTER AM 
				INNER JOIN #EMP_CONS EC ON AM.EMP_ID = EC.EMP_ID
				INNER JOIN T0095_INCREMENT IE ON IE.INCREMENT_ID = EC.INCREMENT_ID
			    WHERE AM.FOR_DATE = @FOR_DATE
			
			------------------------------
				------------Added by Deepali 26Apr22--- Start
				--print 'Add Retain Days'
				declare @Days_cnt as integer
				set @Days_cnt =0 
			if((select 1 from T0100_EMP_RETAINTION_STATUS OA  INNER JOIN #EMP_CONS EC ON OA.EMP_ID = EC.EMP_ID and OA.Cmp_Id= @Cmp_ID and  CONVERT(VARCHAR(20),CAST(@FOR_DATE AS DATETIME),101)  between CONVERT(VARCHAR(20),CAST(OA.Start_Date AS DATETIME),101) and CONVERT(VARCHAR(20),CAST(OA.End_Date AS DATETIME),101) and OA.Is_Retain_ON = 0)=1)
					Begin
						update #Att_Muster set Main_Status ='RT', Status = 'RT' ,WO_HO = 'RT' where For_Date = @FOR_DATE
					    
						--UPDATE	#Att_Muster
						--	SET		WO_HO = 'W' ,Main_Status='T'
						--	FROM	#Att_Muster Att INNER JOIN 
						--	#Emp_Weekoff ew on Att.emp_ID = ew.emp_ID AND Att.For_date =ew.For_Date
						--	and W_Day > 0 AND ew.Is_Cancel=0 

						--print  @FOR_DATE
					
					End
				-----------Added by Deepali 26Apr22--- End-----------------------------------------
			SET @FOR_DATE = DateAdd(D,1,@FOR_DATE)
		end
	
	
	IF  (@Report_For = 'BulkRegularization' OR @Report_For = 'BulkRegularization_Mobile')  AND IsNull(@Shift_ID,0) > 0
		BEGIN
			DELETE FROM #Att_Muster WHERE shift_id <> @Shift_ID
			SET  @Constraint = NULL;
			SELECT	@Constraint  = COALESCE(@Constraint + '#', '') + CAST(EMP_ID AS VARCHAR(10))
			FROM	(SELECT DISTINCT EMP_ID FROM #Att_Muster) T
			
			DELETE	EC 
			FROM	#Emp_Cons EC
					LEFT OUTER JOIN #Att_Muster AT ON EC.Emp_ID=AT.Emp_Id
			WHERE	AT.Emp_Id IS NULL	
		END
	
	--Added by Nimesh 21 April,2015
	--Finally Updating other shift infor FROM update Shift ID
	UPDATE	#Att_Muster 
	SET		SHIFT_NAME=SM.SHIFT_NAME,
			SH_IN_TIME =SM.SHIFT_ST_TIME,
			SH_OUT_TIME=SM.SHIFT_END_TIME,
			SHIFT_DURATION = SM.SHIFT_DUR
	FROM	T0040_SHIFT_MASTER SM INNER JOIN #Att_Muster AM ON 
			SM.Shift_ID=AM.shift_id 
	--WHERE	SM.Cmp_ID=@Cmp_ID
				
	--End Nimesh
	
	update #Att_Muster set 
		Late_limit=0			
	where Late_limit = ''
	
	update #Att_Muster set 
		Early_Limit=0			
	where Early_Limit = ''
			
	UPDATE #ATT_MUSTER SET SH_IN_TIME = QRY.HALF_ST_TIME,SH_OUT_TIME = QRY.HALF_END_TIME  FROM #ATT_MUSTER  AM INNER JOIN
			(
				SELECT  SM.SHIFT_ID,SM.HALF_ST_TIME,SM.HALF_END_TIME,SM.WEEK_DAY
				FROM T0040_SHIFT_MASTER SM 
				WHERE SM.IS_HALF_DAY = 1-- AND SM.Cmp_ID = @CMP_ID
			)QRY ON QRY.SHIFT_ID = AM.SHIFT_ID AND DATENAME(WEEKDAY,AM.FOR_DATE) = QRY.WEEK_DAY
			
	---Alpesh 3-Oct-2011
	/*  COMMENTED BY GADRIWALA MUSLIM 06102016 - NOT REQUIRE THIS CURSOR WE SET HALF DATE TIME DIRECTLY FROM T0040_SHIFT_MASTER AND #ATT_MUSTER
	
	declare	@Half_Day numeric(18,1)
	declare @HalfDay_Date varchar(500)
	declare @CUR_HALF_DATE datetime
	declare @Shift_St_Time_Half_Day varchar(20)
	declare @Shift_End_Time_Half_Day varchar(20)
	
	exec GET_HalfDay_Date @Cmp_ID,@Emp_ID,@From_Date,@Main_To_Date,@Half_Day, @HalfDay_Date output	
	declare CURHALFDAY cursor for 
		select For_Date FROM #Att_Muster WHERE (charindex(CONVERT(nvarchar(11),For_Date,109),@HalfDay_Date) > 0) --Where added by Hardik 18/01/2016 for performance
	open CURHALFDAY
	fetch next FROM CURHALFDAY into @CUR_HALF_DATE
	
	while @@fetch_status = 0
	BEGIN
		if(charindex(CONVERT(nvarchar(11),@CUR_HALF_DATE,109),@HalfDay_Date) > 0) -- Added by Mitesh
		BEGIN	
			select @Shift_St_Time_Half_Day = SM.Half_St_Time, @Shift_End_Time_Half_Day = SM.Half_End_Time FROM T0040_SHIFT_MASTER SM inner join 
			T0100_EMP_SHIFT_DETAIL EM on SM.Shift_ID = Em.Shift_ID 
			where EM.Emp_ID = @Emp_Id AND sm.Is_Half_Day = 1 
			and em.for_date = (Select max(for_date) FROM T0100_EMP_SHIFT_DETAIL WHERE for_date <= @CUR_HALF_DATE AND Emp_ID = @Emp_Id)
			
			Update #Att_Muster
				set sh_in_time =  @Shift_St_Time_Half_Day
					,sh_out_time = @Shift_End_Time_Half_Day
			Where For_Date = @CUR_HALF_DATE
			 	
		end
		
		fetch next FROM CURHALFDAY into @CUR_HALF_DATE
	end
	
	close CURHALFDAY
	deallocate CURHALFDAY
	*/
	--Ankit 25112014--
	
	Declare @Is_Cancel_Weekoff Numeric(1,0)
	Declare @Weekoff_Days Numeric(12,1)
	Declare @Cancel_Weekoff Numeric(12,1)
	Declare @Emp_Week_Detail numeric(18,0)
	Declare @StrWeekoff_Date varchar(Max)
	
	Declare @Is_Cancel_Holiday Numeric(1,0)
	Declare @Holiday_days Numeric(12,1)
	Declare @Cancel_Holiday Numeric(12,1)
	Declare @StrHoliday_Date varchar(Max)
	
	---- Added by Nilesh Patel on 01122015 -Start 
	--if @Is_Cancel_Holiday_WO_HO_same_day = 1 
	--	BEGIN
	--		Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
	--		Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date
	--		--Added by nilesh Patel on 01122015
	--	End
	--Else
	--	BEGIN
	--		Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,null
	--		Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
	--	End
	---- Added by Nilesh Patel on 01122015 -End 
	
	--UPDATE	#Att_Muster
	--SET		WO_HO = 'W' ,Main_Status='W'
	--FROM	#Att_Muster Att INNER JOIN dbo.Split(@StrWeekoff_Date,';') ON Att.For_date = Data

	--------------Changed by Deepali 26Apr22--- Start Added and Isnull(Att.WO_HO,'') <> 'RT' condition 
	--Added by Sumit on 26/12/2016 for Weekoff Holiday
	

	
	UPDATE	#Att_Muster
	SET		WO_HO = 'W' ,Main_Status='W'
	FROM	#Att_Muster Att INNER JOIN 
	#Emp_Weekoff ew on Att.emp_ID = ew.emp_ID AND Att.For_date =ew.For_Date
	and W_Day > 0 AND ew.Is_Cancel=0  and Isnull(Att.WO_HO,'') <> 'RT'
		-----------Added by Deepali 26Apr22--- End-----------------------------------------

	--,Main_Status='W'

	
	-- Added by nilesh Patel on 01122015
	--UPDATE	#Att_Muster
	--SET		WO_HO = 'HO' ,Main_Status='HO'
	--FROM	#Att_Muster Att INNER JOIN dbo.Split(@StrHoliday_Date,';') ON Att.For_date = Data
	-- Added by nilesh Patel on 01122015
	UPDATE	#Att_Muster
	SET		WO_HO = 'HO' ,Main_Status='HO'
	FROM	#Att_Muster Att 
	--INNER JOIN dbo.Split(@StrHoliday_Date,';') ON Att.For_date = Data
	inner join #Emp_Holiday eh on Att.emp_ID = eh.emp_ID AND Att.For_date =Eh.For_Date
	--Added by Sumit on 26/12/2016 for Holiday
--- Add by Hardik 16/08/2011 for Alternate Weekoff setting

Declare @Row_No as int
Declare @Alt_W_Full_Day_Cont varchar(100)
Declare @Count as int
SET @Count = 0

	update #Att_Muster
	set Status = 'P'
	from #Att_Muster AM inner join #TMP_EMP_0150_INOUT EIR ON AM.EMP_ID = EIR.EMP_ID
	AND AM.FOR_DATE = EIR.FOR_DATE 
	where (NOT EIR.IN_TIME IS NULL or NOT EIR.Out_Time IS NULL)	--Alpesh 30-May-2012
	--where NOT EIR.IN_TIME IS NULL
	and Am.For_Date >=@From_Date AND Am.For_Date <=@To_Date
	
	-- done by mitesh on 24/11/2011 - to display two different 0.5 leave on same day START

	
	update #Att_Muster
	set Leave_Count = LT.Leave_Used
		,status='L'
		,Leave_code= substring(LT.Leave_code,2,LEN(LT.Leave_code))
		,Main_Status='L'
		,Detail_Status= substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.Leave_Used,LT.Cmp_ID) as varchar)
	from #Att_Muster AM inner join				--Changed By Gadriwala Muslim 01102014

		(
			SELECT  LT1.CMP_ID,  LT1.EMP_ID, LT1.FOR_DATE, 
			( 
				SUM( 
						CASE WHEN LT1.BACK_DATED_LEAVE > 0 THEN 
								LT1.BACK_DATED_LEAVE 
							 WHEN APPLY_HOURLY=0 THEN 
								LT1.LEAVE_USED 
							 ELSE LT1.LEAVE_USED *0.125 
						 END
				   ) 
			) AS LEAVE_USED,
			( 
				SELECT '/' + LMIN.LEAVE_CODE FROM T0040_LEAVE_MASTER AS LMIN WHERE LMIN.LEAVE_ID IN 
				( 
					 SELECT LEAVE_ID FROM T0140_LEAVE_TRANSACTION AS LT2 
					 WHERE LT2.FOR_DATE = LT1.FOR_DATE AND LT2.EMP_ID = LT1.EMP_ID AND (LT2.LEAVE_USED > 0)
					 
			 ) AND LEAVE_TYPE <> 'Company Purpose' And Isnull(LMIN.Add_In_Working_Hour,0) = 0
			 --AND IsNull(DEFAULT_SHORT_NAME,'') <>'COMP'
			 AND IsNull(Default_Short_Name,'') not in ('COMP','COPH','COND')
			   FOR XML PATH ('')
				 
			 ) AS LEAVE_CODE FROM  T0140_LEAVE_TRANSACTION AS LT1 INNER JOIN #EMP_CONS EC ON LT1.EMP_ID = EC.EMP_ID
			 LEFT OUTER JOIN T0040_LEAVE_MASTER AS EA ON LT1.LEAVE_ID = EA.LEAVE_ID WHERE EA.CMP_ID  = @CMP_ID AND LT1.LEAVE_USED > 0 
			 AND(EA.LEAVE_TYPE <> 'Company Purpose') AND LEAVE_PAID_UNPAID='P'  And Isnull(Add_In_Working_Hour,0) = 0
			 --AND IsNull(DEFAULT_SHORT_NAME,'')<> 'COMP' 
			 AND IsNull(Default_Short_Name,'') not in ('COMP','COPH','COND')
			 GROUP BY LT1.CMP_ID,  LT1.EMP_ID, LT1.FOR_DATE
		 )LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
	WHERE LT.LEAVE_USED > 0 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@MAIN_TO_DATE 
	

	--ADDED BY GADRIWALA MULSLIM 07102016 - START USED QUERY FOR UNPAIN LEAVE INSTEAD OF CURSOR 
	UPDATE #ATT_MUSTER
	SET LEAVE_COUNT = LT.LEAVE_USED
		,STATUS='LWP'
		,LEAVE_CODE= SUBSTRING(LT.LEAVE_CODE,2,LEN(LT.LEAVE_CODE))
		,MAIN_STATUS='LWP'
		,DETAIL_STATUS= SUBSTRING(LT.LEAVE_CODE,2,LEN(LT.LEAVE_CODE)) +'-'+ CAST(DBO.F_LOWER_ROUND(LT.LEAVE_USED,LT.CMP_ID) AS VARCHAR)
	FROM #ATT_MUSTER AM INNER JOIN				--CHANGED BY GADRIWALA MUSLIM 01102014
	(
		SELECT  LT1.CMP_ID,  LT1.EMP_ID, LT1.FOR_DATE, 
		( 
			SUM( 
					CASE WHEN LT1.BACK_DATED_LEAVE > 0 THEN 
							LT1.BACK_DATED_LEAVE 
						 WHEN APPLY_HOURLY=0 THEN 
							LT1.LEAVE_USED 
						 ELSE LT1.LEAVE_USED *0.125 
					 END
			   ) 
		) AS LEAVE_USED,
		( 
			SELECT '/' + LMIN.LEAVE_CODE FROM T0040_LEAVE_MASTER AS LMIN WHERE LMIN.LEAVE_ID IN 
			( 
				 SELECT LEAVE_ID FROM T0140_LEAVE_TRANSACTION AS LT2 
				 WHERE LT2.FOR_DATE = LT1.FOR_DATE AND LT2.EMP_ID = LT1.EMP_ID AND (LT2.LEAVE_USED > 0)
				 
		 ) AND LEAVE_TYPE <> 'Company Purpose' 
		 --AND IsNull(DEFAULT_SHORT_NAME,'') <>'COMP'
		 AND IsNull(DEFAULT_SHORT_NAME,'') NOT IN ('COMP','COPH','COND') --Added by Sumit on 01122016
		   FOR XML PATH ('')
			 
		 ) AS LEAVE_CODE FROM  T0140_LEAVE_TRANSACTION AS LT1 INNER JOIN #EMP_CONS EC ON LT1.EMP_ID = EC.EMP_ID
		 LEFT OUTER JOIN T0040_LEAVE_MASTER AS EA ON LT1.LEAVE_ID = EA.LEAVE_ID WHERE EA.CMP_ID  = @CMP_ID AND LT1.LEAVE_USED > 0 
		 AND(EA.LEAVE_TYPE <> 'Company Purpose') AND LEAVE_PAID_UNPAID='U' And Isnull(Add_In_Working_Hour,0) = 0 
		 --AND IsNull(DEFAULT_SHORT_NAME,'')<> 'COMP' 
		 AND IsNull(DEFAULT_SHORT_NAME,'') NOT IN ('COMP','COPH','COND') --Added by Sumit on 01122016
		 GROUP BY LT1.CMP_ID,  LT1.EMP_ID, LT1.FOR_DATE
	 )LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
	WHERE LT.LEAVE_USED > 0 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@MAIN_TO_DATE 
	
	--ADDED BY GADRIWALA MULSLIM 07102016 - END
	

	UPDATE #ATT_MUSTER
	SET LEAVE_COUNT =  IsNull(LT.LEAVE_USED,0)
		,STATUS='L'
		,LEAVE_CODE= SUBSTRING(LT.LEAVE_CODE,2,LEN(LT.LEAVE_CODE))
		,MAIN_STATUS='L'
		,DETAIL_STATUS=  
			CASE WHEN AM.LEAVE_CODE IS NULL THEN 
				SUBSTRING(LT.LEAVE_CODE,2,LEN(LT.LEAVE_CODE)) +'-'+ CAST(DBO.F_LOWER_ROUND(LT.LEAVE_USED,LT.CMP_ID) AS VARCHAR) 
			ELSE
				AM.LEAVE_CODE + '/' +SUBSTRING(LT.LEAVE_CODE,2,LEN(LT.LEAVE_CODE)) +'-'+ CAST(DBO.F_LOWER_ROUND((IsNull(AM.LEAVE_COUNT,0)+ LT.LEAVE_USED),LT.CMP_ID) AS VARCHAR) 
			END --Added by Sumit for two leaves on same date on 18072016
		--substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.Leave_Used,Lt.Cmp_ID) as varchar)
	FROM #ATT_MUSTER AM INNER JOIN				--CHANGED BY GADRIWALA MUSLIM 01102014
( 
		SELECT     LT1.CMP_ID,LT1.EMP_ID, LT1.FOR_DATE, ( 
		SUM(	
				CASE WHEN APPLY_HOURLY=0 THEN 
					(LT1.COMPOFF_USED - LT1.LEAVE_ENCASH_DAYS) 
				ELSE 
					(LT1.COMPOFF_USED - LT1.LEAVE_ENCASH_DAYS) *0.125 
				END
			) 
	) AS LEAVE_USED,
	 (
		SELECT '/' + LMIN.LEAVE_CODE FROM T0040_LEAVE_MASTER AS LMIN WHERE LMIN.LEAVE_ID IN 
		(
		SELECT LEAVE_ID FROM T0140_LEAVE_TRANSACTION AS LT2 WHERE LT2.FOR_DATE = LT1.FOR_DATE AND LT2.EMP_ID = LT1.EMP_ID AND 
	 ((LT2.COMPOFF_USED - LT2.LEAVE_ENCASH_DAYS) > 0 )
	 ) AND LEAVE_TYPE <> 'Company Purpose' 
	 --AND IsNull(DEFAULT_SHORT_NAME,'') ='COMP'
	 AND IsNull(DEFAULT_SHORT_NAME,'') IN ('COMP','COPH','COND') --Added by Sumit on 01122016
	   FOR XML PATH ('')
	 ) AS LEAVE_CODE FROM  T0140_LEAVE_TRANSACTION AS LT1 INNER JOIN #EMP_CONS EC ON LT1.EMP_ID = EC.EMP_ID
	 LEFT OUTER JOIN T0040_LEAVE_MASTER AS EA ON LT1.LEAVE_ID = EA.LEAVE_ID WHERE EA.CMP_ID  = @CMP_ID AND LT1.COMPOFF_USED > 0 AND      
	 (EA.LEAVE_TYPE <> 'Company Purpose') AND LEAVE_PAID_UNPAID='P' And Isnull(Add_In_Working_Hour,0) = 0
	 --AND IsNull(DEFAULT_SHORT_NAME,'')='COMP' 
	 AND IsNull(DEFAULT_SHORT_NAME,'') IN ('COMP','COPH','COND') --Added by Sumit on 01122016
	 GROUP BY LT1.CMP_ID,  LT1.EMP_ID, LT1.FOR_DATE)LT   --EA.LEAVE_CODE<>'OD' AND
	ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
	WHERE LT.LEAVE_USED  > 0 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@MAIN_TO_DATE 


	update #Att_Muster
	set OD_count = (LT.Leave_Used) --Changed By Gadriwala Muslim 01102014
		,status='OD'
		,OD= LT.Leave_code
		,Main_Status='OD'
		,Detail_Status= substring(LT.Leave_code,2,LEN(LT.Leave_code)) +'-'+ cast(dbo.F_Lower_Round(LT.Leave_Used,Lt.Cmp_ID)as varchar)
	FROM #ATT_MUSTER AM INNER JOIN
	 (
		SELECT LT1.CMP_ID, LT1.LEAVE_USED,LT1.EMP_ID,
		LT1.FOR_DATE,EA.LEAVE_CODE,EA.LEAVE_TYPE FROM T0140_LEAVE_TRANSACTION LT1 
		INNER JOIN #EMP_CONS EC ON LT1.EMP_ID = EC.EMP_ID 
		LEFT OUTER JOIN  T0040_LEAVE_MASTER EA ON LT1.LEAVE_ID=EA.LEAVE_ID WHERE EA.LEAVE_TYPE='Company Purpose' 
		--AND IsNull(EA.DEFAULT_SHORT_NAME,'') <> 'COMP' 
		AND IsNull(DEFAULT_SHORT_NAME,'') NOT IN ('COMP','COPH','COND') --Added by Sumit on 01122016
		AND LT1.LEAVE_USED>0
	  )LT    --EA.Leave_code='OD' AND 
	ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
	WHERE (LT.LEAVE_USED > 0 )
	AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@MAIN_TO_DATE

	UPDATE #ATT_MUSTER
	SET OD_COUNT = (LT.COMPOFF_USED -IsNull(LT.LEAVE_ENCASH_DAYS,0)) --CHANGED BY GADRIWALA MUSLIM 01102014
		,STATUS='OD'
		,OD= LT.LEAVE_CODE
		,MAIN_STATUS='OD'
		,DETAIL_STATUS= SUBSTRING(LT.LEAVE_CODE,2,LEN(LT.LEAVE_CODE)) +'-'+ CAST(DBO.F_LOWER_ROUND(LT.COMPOFF_USED,LT.CMP_ID)AS VARCHAR)
	FROM #ATT_MUSTER AM INNER JOIN 
	(
		SELECT LT1.CMP_ID, LT1.COMPOFF_USED,LT1.LEAVE_ENCASH_DAYS,LT1.EMP_ID,
		LT1.FOR_DATE,EA.LEAVE_CODE,EA.LEAVE_TYPE FROM T0140_LEAVE_TRANSACTION LT1 
		INNER JOIN #EMP_CONS EC ON LT1.EMP_ID = EC.EMP_ID 
		LEFT OUTER JOIN T0040_LEAVE_MASTER EA ON LT1.LEAVE_ID=EA.LEAVE_ID 
		WHERE EA.LEAVE_TYPE='Company Purpose' 
		--AND IsNull(EA.DEFAULT_SHORT_NAME,'') = 'COMP' 
		AND IsNull(DEFAULT_SHORT_NAME,'') IN ('COMP','COPH','COND') --Added by Sumit on 01122016
		AND LT1.COMPOFF_USED>0
	 )LT    --EA.Leave_code='OD' AND 
	ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE WHERE ((LT.COMPOFF_USED - IsNull(LT.LEAVE_ENCASH_DAYS,0))  > 0 )
	AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@MAIN_TO_DATE
	
	--COMMENTED BY GADRIWALA MULSLIM 07102016 - START USED QUERY FOR UNPAIN LEAVE INSTEAD OF CURSOR 
	    
		
	/*
	---- Alpesh 06-Dec-2011 for Unpaid Leaves for which we dont maintain balance in T0140_LEAVE_TRANSACTION
	declare @lwp_EmpId numeric
	declare @lwp_LeaveId numeric
	declare @lwp_Leave_Code varchar(20)
	declare @lwp_FromDate datetime
	declare @lwp_ToDate datetime
	declare @lwp_Period numeric(18,1)
	declare @lwp_Leave_Assign varchar(20)
	declare @flag int
	declare @lwp_Leave_Remain numeric(18,1)
	declare @lwp_For_date datetime
	
	
	SET @flag = 0
	SET @lwp_Leave_Remain = 0

	declare cur1 cursor for 
		select lt.Emp_ID,lt.Leave_ID,lm.Leave_Code,For_Date,lt.Leave_Used as leave_period FROM T0140_LEAVE_TRANSACTION LT
				inner join T0040_LEAVE_MASTER LM on LT.Leave_ID = lm.Leave_ID
			where LT.For_Date <= @Main_To_Date AND lt.For_Date>=@From_Date AND lt.Leave_Used>0 AND LT.Cmp_ID=@cmp_id AND Emp_ID=@emp_id AND  LM.Leave_Paid_Unpaid='U'
			
	open cur1
	fetch next FROM cur1 into @lwp_EmpId,@lwp_LeaveId,@lwp_Leave_Code,@lwp_For_date,@lwp_Period
	while @@fetch_status = 0
	BEGIN			
					if @lwp_Period > 0.5
					  BEGIN
						update #Att_Muster set
							 Leave_Count = 1
							,status = 'LWP'
							,Leave_code = @lwp_Leave_Code 
							,Main_Status='LWP'
							,Detail_Status= @lwp_Leave_Code +'-1.0'
						Where EMP_ID = @lwp_EmpId AND CONVERT(varchar(10),For_Date,120) = CONVERT(varchar(10),@lwp_For_date,120)												
						
					  end
					else  										
					  BEGIN
						update #Att_Muster set
							 Leave_Count = 0.5
							,status = 'LWP'
							,Leave_code = case when Leave_code Is NULL or Leave_code='' or Leave_code = '-' then @lwp_Leave_Code else Leave_code end
							,Main_Status='LWP'
							,Detail_Status= @lwp_Leave_Code +'-0.5'
						Where EMP_ID = @lwp_EmpId AND CONVERT(varchar(10),For_Date,120) = CONVERT(varchar(10),@lwp_For_date,120)												
					
					  end	
					
		fetch next FROM cur1 into @lwp_EmpId,@lwp_LeaveId,@lwp_Leave_Code,@lwp_For_date,@lwp_Period
	end
	close cur1
	deallocate cur1*/


	Update #Att_Muster
	set Status = WO_HO
	Where IsNull(Status,'') <> '' AND ( WO_HO = 'HO' or WO_HO = 'W')
	and For_Date >=@From_Date AND For_Date <=@Main_To_Date  --Alpesh 09-Sep-2011
	--and For_Date >=@From_Date AND For_Date <=@To_Date
	
	Update #Att_Muster set 
		 Status ='A'
		,Main_Status='A'
	Where Status is NULL
	and For_Date >=@From_Date AND For_Date <=@To_Date

	
	
	Update #Att_Muster set 
		 Main_Status='A'
	Where Main_Status is NULL
	and For_Date >=@From_Date AND For_Date <=@To_Date

	--Added by Jaina 26-12-2017 Start  (i.e Date of join 8-12-2017 that case 1 to 7 date absent display)
	update #Att_Muster
	SET Main_Status = NULL
	where Date_of_join > For_Date OR IsNull(left_date,For_Date) < For_Date


	Update #Att_Muster
	Set In_Date =In_time
	From #Att_Muster AM inner join 
	( select min(In_Time) In_Time ,EIR.Emp_Id,For_Date FROM #TMP_EMP_0150_INOUT EIR
		INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID 
		Where For_Date>=@From_Date AND For_Date <=@To_Date
		group by EIR.Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  AND am.for_Date = Q.for_Date

	

	Update #Att_Muster
	Set Out_Date = Case When Max_In_Time > OUT_Time Then Max_In_Time Else OUT_Time End
	From #Att_Muster AM inner join 
	( select Max(Out_Time) OUT_Time ,EIR.Emp_Id,For_Date FROM #TMP_EMP_0150_INOUT EIR
			INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
		Where For_Date>=@From_Date AND For_Date <=@To_Date
		group by EIR.Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  AND am.for_Date = Q.for_Date Left Outer Join
	( select Max(In_Time) Max_In_Time ,EIR.Emp_Id,For_Date FROM #TMP_EMP_0150_INOUT EIR
			INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
		Where For_Date>=@From_Date AND For_Date <=@To_Date
		group by EIR.Emp_ID ,for_date 
	)q1 on Am.Emp_ID =q1.emp_ID  AND am.for_Date = Q1.for_Date
	
	Update #Att_Muster
	Set Reason = IsNull(Q.Reason,''), Other_Reason=q.Other_Reason
	From #Att_Muster AM inner join 
	(select reason,Other_Reason,for_date,EIR.emp_ID FROM #TMP_EMP_0150_INOUT EIR
			INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
			inner join T0040_Reason_Master rm on reason=rm.Reason_Name
		Where For_Date>=@From_Date AND For_Date <=@To_Date AND Reason is not NULL AND Reason <> ''
	 )q on Am.Emp_ID =q.emp_ID  AND am.for_date = Q.for_date

	Update AM
		Set Att_Approval_Days = q.P_Days,
			Att_App_ID = q.Att_App_ID
	From #Att_Muster AM inner join 
	(
		 select Emp_ID,For_Date,P_Days,Att_App_ID
			From T0160_Attendance_Application
		 WHERE For_Date >=@From_Date AND For_Date <=@To_Date
	)q on Am.Emp_ID =q.Emp_ID  AND am.for_date = Q.For_Date

	Update AM
		Set Att_Approval_Days = q.P_Days,
			Att_Apr_Status = q.Att_Status,
			AM.Main_Status = (Case When q.Att_Status = 'A' Then 'P' Else AM.Main_Status END)
	From #Att_Muster AM inner join 
	(
		 select Emp_ID,For_Date,P_Days,Att_Status
			From T0165_Attendance_Approval
		 WHERE Cmp_ID = @cmp_ID AND For_Date >=@From_Date AND For_Date <=@To_Date
	)q on Am.Emp_ID =q.Emp_ID  AND am.for_date = Q.For_Date

	Update AM
		Set OT_Apr_ID = q.Tran_ID
	From #Att_Muster AM inner join 
	(
		Select Tran_ID,Emp_ID,For_Date
			 FROM T0160_OT_Approval 
		Where Cmp_ID = @Cmp_ID AND For_Date >= @From_Date AND For_Date <= @To_Date AND Is_Approved = 1
	)q on Am.Emp_ID =q.Emp_ID  AND am.for_date = Q.For_Date

	Update AM
		Set Comp_off_App = q.Compoff_App_ID
	From #Att_Muster AM inner join 
	(
		Select Compoff_App_ID,Emp_ID,Extra_Work_Date 
			From T0100_CompOff_Application CA
		Where Cmp_ID = @Cmp_ID AND Extra_Work_Date >= @From_Date AND Extra_Work_Date <= @To_Date AND Application_Status = 'P' 
		and Not Exists(Select 1 FROM T0120_CompOff_Approval CCA WHERE CCA.CompOff_App_ID = CA.Compoff_App_ID)
	)q on Am.Emp_ID =q.Emp_ID  AND am.for_date = Q.Extra_Work_Date

	Update AM
		Set Comp_off_Apr = q.CompOff_Appr_ID
	From #Att_Muster AM inner join 
	(
		Select CompOff_Appr_ID,Emp_ID,Extra_Work_Date 
			From T0120_CompOff_Approval 
		Where Cmp_ID = @Cmp_ID AND Extra_Work_Date >= @From_Date AND Extra_Work_Date <= @To_Date AND Approve_Status = 'A' 
	)q on Am.Emp_ID =q.Emp_ID  AND am.for_date = Q.Extra_Work_Date

	----Nikunj 08-June-2011---------
	Update #Att_Muster
	Set Half_Full_Day = IsNull(Q.Half_Full_Day,'')
	From #Att_Muster AM inner join 
	(Select Half_Full_Day,for_date,EIR.emp_ID FROM #TMP_EMP_0150_INOUT EIR
			INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
		Where Cmp_ID = @cmp_ID AND For_Date>=@From_Date AND For_Date <=@To_Date AND Half_Full_Day is not NULL AND Half_Full_Day <> ''
	 )q on Am.Emp_ID =q.emp_ID  AND am.for_date = Q.for_date
	
	----Nikunj 08-June-2011---------

	Update #Att_Muster
	set Status =  dbo.F_Return_HHMM(cast(datepart(hh,In_Date) as varchar(2))+ ':'+ cast(datepart(mi,In_Date) as varchar(2)))
	where In_Date is not NULL --Status = 'P' and	--Alpesh 30-May-2012
	
	Update #Att_Muster
	set Status_2 =  dbo.F_Return_HHMM(cast(datepart(hh,OUT_Date) as varchar(2))+ ':'+ cast(datepart(mi,OUT_Date) as varchar(2)))
	where not OUT_Date is NULL

	
	Update #Att_Muster set 
		 Status = WO_HO
	    ,Main_Status = WO_HO 
	where In_Date is NULL AND ( WO_HO = 'W' or WO_HO = 'HO' )


	Update #Att_Muster
	set Status = '-'
	where IsNull(Status,'')=''
	
	
	--Alpesh 5-Jun-2012
		
	Update #Att_Muster
	set Status = '-'
	where In_Date is NULL AND OUT_Date is not NULL
	
	Update #Att_Muster set 		 
	    Main_Status = WO_HO 
	where ( WO_HO = 'W' or WO_HO = 'HO' )
	-- End--
	
	Update #Att_Muster set 		 
	    Main_Status = WO_HO 
	where ( WO_HO = 'W' or WO_HO = 'HO' )
	-- End--
	
	----------Alpesh 28-Jun-2011----------
	
	UPDATE #ATT_MUSTER
	SET CHK_BY_SUPERIOR = IsNull(Q.CHK_BY_SUPERIOR,'')
	FROM #ATT_MUSTER AM INNER JOIN 
	(	SELECT CHK_BY_SUPERIOR = CASE CHK_BY_SUPERIOR WHEN 2 THEN 'Rejected' WHEN 1 THEN 'Approved' WHEN 0  THEN 'Pending' ELSE '' END ,FOR_DATE,EMP_ID FROM #TMP_EMP_0150_INOUT
		INNER JOIN T0040_REASON_MASTER RM ON REASON=RM.REASON_NAME
		WHERE CMP_ID = @CMP_ID AND FOR_DATE>=@FROM_DATE AND FOR_DATE <=@TO_DATE AND CHK_BY_SUPERIOR IS NOT NULL
		AND (REASON IS NOT NULL AND REASON<>'')
		and (App_Date is not null or apr_date is not null) --Added By Jimit 31122018 
	 )Q ON AM.EMP_ID =Q.EMP_ID  AND AM.FOR_DATE = Q.FOR_DATE
	
	UPDATE #ATT_MUSTER
	SET SUP_COMMENT = IsNull(Q.SUP_COMMENT,'')
	FROM #ATT_MUSTER AM INNER JOIN 
	(
		SELECT SUP_COMMENT,FOR_DATE,EIR.EMP_ID FROM #TMP_EMP_0150_INOUT EIR
			INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
		WHERE CMP_ID = @CMP_ID AND FOR_DATE>=@FROM_DATE AND FOR_DATE <=@TO_DATE AND SUP_COMMENT IS NOT NULL
	)Q ON AM.EMP_ID =Q.EMP_ID  AND AM.FOR_DATE = Q.FOR_DATE
	 
	---------------end-----------------
	----------Alpesh 02-Aug-2011----------
	UPDATE #ATT_MUSTER
	SET IS_CANCEL_LATE_IN = IsNull(Q.IS_CANCEL_LATE_IN,0)
	FROM #ATT_MUSTER AM INNER JOIN 
	(
		SELECT IS_CANCEL_LATE_IN,FOR_DATE,EIR.EMP_ID FROM #TMP_EMP_0150_INOUT EIR
			INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
		WHERE CMP_ID = @CMP_ID AND FOR_DATE>=@FROM_DATE AND FOR_DATE <=@TO_DATE AND IsNull(IS_CANCEL_LATE_IN,0) = 1
	 )Q ON AM.EMP_ID =Q.EMP_ID  AND AM.FOR_DATE = Q.FOR_DATE
	 
	UPDATE #ATT_MUSTER
	SET IS_CANCEL_EARLY_OUT = IsNull(Q.IS_CANCEL_EARLY_OUT,0)
	FROM #ATT_MUSTER AM LEFT OUTER JOIN 
	(
		SELECT IS_CANCEL_EARLY_OUT,FOR_DATE,EIR.EMP_ID FROM #TMP_EMP_0150_INOUT EIR
				INNER JOIN #Emp_Cons EC on EIR.Emp_ID = EC.Emp_ID
		WHERE CMP_ID = @CMP_ID AND FOR_DATE>=@FROM_DATE AND FOR_DATE <=@TO_DATE AND IS_CANCEL_EARLY_OUT = 1
	 )Q ON AM.EMP_ID =Q.EMP_ID  AND AM.FOR_DATE = Q.FOR_DATE
	---------------end-----------------
	--Alpesh 8-Jun-2012
	UPDATE #ATT_MUSTER SET STATUS=NULL
	WHERE LEN(STATUS)<=3
	
	UPDATE #ATT_MUSTER SET STATUS='-'
	WHERE STATUS IS NULL AND FOR_DATE>GETDATE() 

	-- Commented by Hardik 30/11/2019 As not needed, this SP already called under SP_CALCULATE_PRESENT_DAYS at below side
	--After discuss with Nimeshbhai change it. 26-12-2017
	--SELECT TOP 0 * INTO #DATA_TMP FROM #DATA
	--EXEC P_GET_EMP_INOUT @Cmp_ID, @FROM_DATE, @TO_DATE   			
	--INSERT INTO #DATA_TMP SELECT * FROM #DATA
	
	if @Emp_ID is not NULL  
		BEGIN
			--EXEC P_GET_EMP_INOUT @Cmp_ID, @FROM_DATE, @TO_DATE   --Added by Jaina 01-02-2017
			
			--SELECT * INTO #DATA_TMP FROM #DATA
			
			TRUNCATE TABLE #DATA
			EXEC dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,@Emp_ID,'',4
			
		END
	ELSE IF IsNull(@Constraint, '') <>  '' --Added by Jaina 26-02-2018
		BEGIN
			TRUNCATE TABLE #DATA
			EXEC dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@constraint,4	
		END
		
	----- End ----	

	--Nimesh 20 April,2015
	--This query will update the shift information according to updated shift in #Data table in 
	--SP_CALCULATE_PRESENT_DAYS stored procedure. The shifts are retrieveing FROM Employee Monthly 
	--Shift Rotation Details.

	--Commented By Nilesh Patel on 16032019 -- Common Logic is implemented In Present Day Sp so not required here
	--Update D
	--	Set D.Duration_in_sec = (CASE WHEN (AM.WO_HO = 'W' OR AM.WO_HO = 'HO') AND @Tras_Week_OT = 1 THEN D.Duration_in_sec ELSE Duration_in_sec - q.Shift_Sec END),
	--		D.Weekoff_OT_Sec = (CASE WHEN AM.WO_HO = 'W' AND @Tras_Week_OT = 1 THEN Weekoff_OT_Sec - q.Shift_Sec ELSE D.Weekoff_OT_Sec END),
	--		D.Holiday_OT_Sec = (CASE WHEN AM.WO_HO = 'HO' AND @Tras_Week_OT = 1 THEN Holiday_OT_Sec - q.Shift_Sec ELSE D.Holiday_OT_Sec END)
	--From #Data D inner join 
	--(
	--	 select Emp_ID,DateAdd(d,-1,For_Date) as ForDate,P_Days,Att_Status,Shift_Sec
	--		From T0165_Attendance_Approval
	--	 WHERE Cmp_ID = @cmp_ID AND For_Date >=@From_Date AND For_Date <=@To_Date
	--)q on D.Emp_ID =q.Emp_ID  AND D.for_date = Q.ForDate
	--Left OUTER join #Att_Muster AM ON AM.Emp_Id = D.Emp_ID AND AM.For_Date = D.For_Date
	
	UPDATE	A
	SET		shift_name=IsNull(SM.shift_name,A.shift_name), 
			sh_in_time =IsNull(CONVERT(varchar(5),D.Shift_Start_Time, 108),sh_in_time),
			sh_out_time=IsNull(CONVERT(varchar(5),D.Shift_End_Time, 108),sh_out_time),
			[Status] = CONVERT(varchar(5), D.In_Time, 114),
			[Status_2] = CONVERT(varchar(5), D.Out_Time, 114),
			--In_Date = IsNull( In_Time, In_Date), --Commented & remove IsNull condition by Hardik 21/11/2016 as if In Time not in Present then it should display blank
			In_Date = D.In_Time,
			Out_Date = D.Out_Time,
			shift_id=IsNull(D.Shift_ID,A.shift_id)
	FROM	#Att_Muster A 
			LEFT OUTER JOIN #Data D ON D.Emp_ID=A.Emp_ID AND D.For_Date=A.For_Date
			--LEFT OUTER JOIN #DATA_TMP D1 ON D.Emp_ID=D1.Emp_ID AND D.For_Date=D1.For_Date  -- Commented by Hardik 30/11/2019
			LEFT OUTER JOIN T0040_SHIFT_MASTER SM ON D.Shift_ID=SM.Shift_ID AND SM.Cmp_ID=@Cmp_ID

	
	----Ankit 01042016
	UPDATE #Att_Muster
	SET Main_Status =  CASE WHEN Is_Split_Shift = 1 THEN 'S' WHEN Is_Training_Shift = 1 THEN 'T'  ELSE 'P' END
	FROM  #Att_Muster AM INNER JOIN 
		  dbo.#TMP_EMP_0150_INOUT EIR ON AM.EMP_ID = EIR.EMP_ID AND AM.FOR_DATE = EIR.FOR_DATE INNER JOIN 
		  #DATA D ON Am.For_Date = D.For_date AND Am.Emp_Id = d.Emp_Id LEFT OUTER JOIN 
		  T0040_SHIFT_MASTER S ON D.Shift_ID = S.Shift_ID
	WHERE AM.For_Date >= @From_Date AND AM.For_Date <=@To_Date AND D.P_days = 1
	----Ankit 01042016
	
-- Added by rohit on 28012013
	Update #Att_Muster
	set Main_Status='A'
	from #Att_Muster AM inner join #Data D on
	AM.Emp_Id = D.Emp_Id AND AM.For_Date=d.For_Date
	where P_Days='0.0' AND main_status not in ('W','HO','L','OD','P') AND od <> 'OD' AND IsNull(leave_count,0) <= 0
	-- ended by rohit on 28012013	

	
	Update #Att_Muster
	set Main_Status=Case D.P_days When 0.75 THEN '3QD' When 0.25 Then 'QD' END
	from #Att_Muster AM inner join #Data D on
	AM.Emp_Id = D.Emp_Id AND AM.For_Date=d.For_Date
	where P_Days in (0.75 ,0.25)
	
	
	--Update #Att_Muster
	--set Main_Status='QD'
	--from #Att_Muster AM inner join #Data D on
	--AM.Emp_Id = D.Emp_Id AND AM.For_Date=d.For_Date
	--where P_Days=0.25 
	
	-- Added by rohit on 28012013
	Update #Att_Muster
	set Main_Status='L'
	from #Att_Muster AM 
	where  IsNull(leave_count,0) > 0 AND IsNull(leave_code,'-') <> '-'
	
	Update #Att_Muster
	set Main_Status='OD'
	from #Att_Muster AM 
	where  IsNull(od_count,0) > 0 AND IsNull(OD,'-') <> '-'
		
	-- ended by rohit on 28012013	
	
	
			

	---- Added by rohit on 18102013		
	-- Late Minute condition added by Hardik 21/12/2015 for 12 AM Shift
    update #Att_Muster
    set late_minute = Case when sh_in_time <> '00:00' then 
						case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) < 0 then 0
						    when  DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) > LTRIM(DATEDIFF(MINUTE, 0, Emp_Late_Limit)) then  --Added By Jimit 21052019 
							      DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)
						else 0 end
						--else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)  end
					Else
						--commented by Hardik 13/01/2016 AND put below mentioned condition for Nirma
						--Case when In_Date > cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime) then
						--	case when DateDiff(mi,In_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime))<0 then 0 
						--	else DateDiff(mi,In_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime)) end
						--Else
						--	case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 
						--	else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end
						--End
						Case when DateDiff(mi,cast(cast(DateAdd(d,1,AM.for_date) as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) < 0 then 0
						     when DateDiff(mi,cast(cast(DateAdd(d,1,AM.for_date) as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) >  LTRIM(DATEDIFF(MINUTE, 0, Emp_Late_Limit)) then  --Added By Jimit 21052019 
							      DateDiff(mi,cast(cast(DateAdd(d,1,AM.for_date) as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)
						else 0 end
						--else DateDiff(mi,cast(cast(DateAdd(d,1,AM.for_date) as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end
					
					End,
		Early_minute = case when DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 
								0 
						   when DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime)) >  LTRIM(DATEDIFF(MINUTE, 0, Emp_Early_Limit)) then --Added By Jimit 21052019 
							DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime))
						   else 0
						   --else 
							--	DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime)) 
						   end
	FROM	#Att_Muster AM INNER JOIN #Emp_Cons E ON AM.Emp_ID=E.Emp_ID
			INNER JOIN T0095_INCREMENT I ON E.INCREMENT_ID=I.INCREMENT_ID
			Inner Join T0040_GENERAL_SETTING GS ON I.Branch_ID = GS.Branch_ID
			INNER JOIN(
						Select MAX(For_Date) as ForDate,Branch_ID FROM T0040_GENERAL_SETTING 
						Where Cmp_ID = @Cmp_ID 
						GROUP By Branch_ID
					  ) as QRY ON GS.For_Date = QRY.ForDate AND GS.Branch_ID = QRY.Branch_ID
	WHERE	(CASE WHEN GS.IS_LATE_MARK = 0 THEN 0 ELSE I.Emp_Late_Mark END) = 1 --COALESCE(@IS_LATE_MARK, I.Emp_Late_Mark) = 1 

	-- Commented by Hardik 21/12/2015 AND put above condtion for 12 AM Shift for Nirma    
    --update #Att_Muster
    --set late_minute = case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end
    --,Early_minute = case when DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end
    --from #Att_Muster AM
    
   UPDATE #ATT_MUSTER  
	SET LATE_MINUTE = Case When LEAVE_ASSIGN_AS = 'First Half' Then 0 Else LATE_MINUTE End,
		EARLY_MINUTE = Case When LEAVE_ASSIGN_AS = 'Second Half' Then 0 Else EARLY_MINUTE End
	FROM #ATT_MUSTER EL
		INNER JOIN
		 (
			SELECT LA.LEAVE_APPROVAL_ID,LA.EMP_ID,LAD.HALF_LEAVE_DATE,LEAVE_ASSIGN_AS FROM T0120_LEAVE_APPROVAL LA 
			INNER JOIN #Emp_Cons E ON LA.Emp_ID=E.Emp_ID
			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
			WHERE LEAVE_ASSIGN_AS In ('First Half','Second Half') AND APPROVAL_STATUS = 'A'
		  ) QRY 
		ON QRY.EMP_ID = EL.EMP_ID AND QRY.HALF_LEAVE_DATE = EL.FOR_DATE
		
 Update #Att_Muster  
	set late_minute = 0 ,Early_minute = 0
	from #Att_Muster EL
		inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.From_Date FROM T0120_LEAVE_APPROVAL la 
				INNER JOIN #Emp_Cons E ON LA.Emp_ID=E.Emp_ID
				inner join T0130_LEAVE_APPROVAL_DETAIL lad on la.Leave_Approval_ID = lad.Leave_Approval_ID
				inner join T0040_LEAVE_MASTER LM on lad.Leave_ID=lm.Leave_ID AND lad.Cmp_ID=lm.Cmp_ID
				where  Approval_Status = 'A' AND lm.Apply_Hourly=1) Qry 
		on Qry.Emp_ID = el.Emp_ID AND Qry.From_Date = el.For_Date --Added by Sumit on 05012017		
  
  update #Att_Muster 
	set late_minute = 0 ,Early_minute =0
	From #Att_Muster  A inner join #Data D on A.For_Date = D.For_date and A.Emp_Id = d.Emp_Id 
	where D.P_days = 0.5 and A.Emp_Id = @Emp_ID and Cmp_ID = @Cmp_ID

	
       
 --  UPDATE #ATT_MUSTER  
	--SET EARLY_MINUTE = 0
 --  FROM #ATT_MUSTER EL
	--	inner join 
	--	(
	--		SELECT LA.LEAVE_APPROVAL_ID,LA.EMP_ID,LAD.HALF_LEAVE_DATE FROM T0120_LEAVE_APPROVAL LA 
	--			INNER JOIN #Emp_Cons E ON LA.Emp_ID=E.Emp_ID
	--			INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID
	--		WHERE LEAVE_ASSIGN_AS = 'Second Half' AND APPROVAL_STATUS = 'A'
	--	 ) QRY 
	--	ON QRY.EMP_ID = EL.EMP_ID AND QRY.HALF_LEAVE_DATE = EL.FOR_DATE
		
	-- Commented by Hardik 07/12/2018 this query added in above query with Late_minute = 0
	--Update #Att_Muster  
	--set Early_minute = 0
 --  FROM #Att_Muster EL
	--	inner join (select la.Leave_Approval_ID,la.Emp_ID,lad.From_Date FROM T0120_LEAVE_APPROVAL la 
	--			INNER JOIN #Emp_Cons E ON LA.Emp_ID=E.Emp_ID
	--			inner join T0130_LEAVE_APPROVAL_DETAIL lad on la.Leave_Approval_ID = lad.Leave_Approval_ID
	--			inner join T0040_LEAVE_MASTER LM on lad.Leave_ID=lm.Leave_ID AND lad.Cmp_ID=lm.Cmp_ID
	--			where Approval_Status = 'A' AND lm.Apply_Hourly=1) Qry 
	--	on Qry.Emp_ID = el.Emp_ID AND Qry.From_Date = el.For_Date --Added by Sumit on 05012017		
  
	CREATE TABLE #T
	(
	  ID INT IDENTITY PRIMARY KEY,
	  Emp_Id	NUMERIC,
	  FROMDATE DATETIME,
	  TODATE DATETIME,
	  H_LEAVE_DATE DATETIME
	)
	INSERT INTO #T (Emp_Id,FROMDATE,TODATE,H_LEAVE_DATE)  
		(	SELECT V.Emp_Id, FROM_DATE,TO_DATE,HALF_LEAVE_DATE FROM  
			--V0110_LEAVE_APPLICATION_DETAIL LAD WHERE CMP_ID = @CMP_ID  AND EMP_ID = @EMP_ID 
			V0110_LEAVE_APPLICATION_DETAIL V INNER JOIN #Emp_Cons E ON E.Emp_ID = V.Emp_ID WHERE V.Cmp_ID = @Cmp_id   --Change by Jaina 26-02-2018
			AND (MONTH(FROM_DATE) = MONTH(@FROM_DATE) AND YEAR(TO_DATE) = YEAR(@TO_DATE)) AND LEAVE_ASSIGN_AS <> 'PART DAY'
		 )	
	

	/*UPDATE #ATT_MUSTER  SET IS_LEAVE_APP = 1 WHERE FOR_DATE IN  
		(
		SELECT D.DATES FROM #T AS T INNER JOIN MASTER..SPT_VALUES AS N
		ON N.NUMBER BETWEEN 0 AND DateDiff(DAY, T.FROMDATE, T.TODATE)
	    CROSS APPLY (SELECT DateAdd(DAY, N.NUMBER, T.FROMDATE)) AS D(DATES)
		WHERE N.TYPE ='P' AND  (D.DATES <> T.H_LEAVE_DATE )
		)		
	--  -- ended by rohit on 18102013
	----Added by Sid to remove those codes WHERE leave AND present days becomes full day 25062014

--Added by Mukti(25082017)start if first half AND second half both leave applied than change status IS_LEAVE_APP=1 
	UPDATE #ATT_MUSTER  SET IS_LEAVE_APP = 1 WHERE FOR_DATE IN  
		(
		SELECT D.DATES FROM #T AS T INNER JOIN MASTER..SPT_VALUES AS N
		ON N.NUMBER BETWEEN 0 AND DateDiff(DAY, T.FROMDATE, T.TODATE)
	    CROSS APPLY (SELECT DateAdd(DAY, N.NUMBER, T.FROMDATE)) AS D(DATES)
		WHERE N.TYPE ='P' AND  (D.DATES = T.H_LEAVE_DATE )
		Group by D.DATES
		Having Count(T.H_LEAVE_DATE)>1
		)		
--Added by Mukti(25082017)end
	*/
	
	--Update by Krushna due to Multiple employees 13-02-2019
	UPDATE #ATT_MUSTER  SET IS_LEAVE_APP = 1 
		From #ATT_MUSTER A Inner join 
		(
		SELECT D.DATES,T.EMP_ID FROM #T AS T INNER JOIN MASTER..SPT_VALUES AS N
		ON N.NUMBER BETWEEN 0 AND DATEDIFF(DAY, T.FROMDATE, T.TODATE)
	    CROSS APPLY (SELECT DATEADD(DAY, N.NUMBER, T.FROMDATE)) AS D(DATES)
		WHERE N.TYPE ='P' AND  (D.DATES <> T.H_LEAVE_DATE )
		) Q On A.Emp_Id = Q.EMP_ID And A.For_Date = Q.DATES
	
	UPDATE #ATT_MUSTER  SET IS_LEAVE_APP = 1 			
		From #ATT_MUSTER A Inner join 
		(
		SELECT D.DATES,T.EMP_ID FROM #T AS T INNER JOIN MASTER..SPT_VALUES AS N
		ON N.NUMBER BETWEEN 0 AND DateDiff(DAY, T.FROMDATE, T.TODATE)
	    CROSS APPLY (SELECT DateAdd(DAY, N.NUMBER, T.FROMDATE)) AS D(DATES)
		WHERE N.TYPE ='P' AND  (D.DATES = T.H_LEAVE_DATE )
		Group by D.DATES,T.EMP_ID
		Having Count(T.H_LEAVE_DATE)>1
		) Q On A.Emp_Id = Q.EMP_ID And A.For_Date = Q.DATES
	--end Krushna 13-02-2019

			
	-- Deepal 06052022

	
	
		exec rptLateEarlyCombination @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID
	,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@Constraint    
	
	select * from #data
	select * from #Att_Muster
	return
				


	
IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'ExmptTable'))
BEGIN
				Alter table #Att_Muster add ExFlag Char(2)
				
			
				update A
				set A.ExFlag = T.ExemptFlag
				from #Att_Muster A inner join ExmptTable T on A.Emp_ID = T.Emp_Id 
				and A.For_Date = T.For_Date and A.Cmp_ID = T.Cmp_ID
				where T.ExemptFlag in ('Ex','D')

				update #Att_Muster set ExFlag = 'NA'  where isnull(ExFlag,'') not in ('Ex','D')

					update #Att_Muster set ExFlag = 'NA'  where For_Date = '2022-03-07 00:00:00.000'
						
END

-- Deepal 06052022
--Added by nilesh patel on 04042018 -- if Today Attendance only In-Time Consider As Present

if @Report_for = 'IN-OUT'
	BEGIN
		
		if exists(select 1 FROM #Data WHERE Emp_ID = @Emp_ID AND For_Date = Convert(datetime,Convert(Varchar(8),Getdate(),112),106) AND P_days = 0 AND IN_TIME IS NOT NULL)
			BEGIN
				update #Data 
					Set P_days = 1
				Where Emp_ID = @Emp_ID AND For_Date = Convert(datetime,Convert(Varchar(8),Getdate(),112),106) AND P_days = 0

				Update #Att_Muster
					Set Main_Status = 'P'
				Where Emp_ID = @Emp_ID AND For_Date = Convert(datetime,Convert(Varchar(8),Getdate(),112),106) AND Main_Status = 'A'
			End
	End
--Added by nilesh patel on 04042018 

update at 
set Is_Leave_App = 1 
from #Att_Muster at
inner join #Data d on
at.Emp_Id = d.Emp_Id AND at.For_Date = d.For_date
where Leave_Count + p_days >=1 
----Added by Sid 25062014 Ends

		--Added by Mukti Reporting Manager of employee(start)04092017
			UPDATE	#Att_Muster SET R_Emp_ID = isnull(rm.R_Emp_ID,0) --isnull for - if employee have no manager then it will be zero,bcoz  it will effect on ESS login Attendance Req. page
			FROM	#Att_Muster AM INNER JOIN (SELECT esd.R_Emp_ID, esd.Effect_Date,esd.Emp_ID 
			FROM	T0090_EMP_REPORTING_DETAIL esd INNER JOIN  
					(SELECT MAX(Effect_Date) AS For_Date,ESD.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ESD
							 INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
						WHERE Cmp_ID = IsNull(@Cmp_ID,Cmp_ID) AND Effect_Date <= @For_Date GROUP BY ESD.Emp_ID) S ON 
						esd.Emp_ID = S.Emp_ID AND esd.Effect_Date=s.For_Date) rm ON 
					rm.Emp_ID = AM.EMP_ID 
			--WHERE	AM.For_Date=@For_Date				
		--Added by Mukti Reporting Manager of employee(end)04092017
		
	--NEW CODE ADDED BY RAMIZ FOR WEBSERVICE OF TRADEBULLS
		IF @Report_for = 'WEB-SERVICE'
			BEGIN
				SELECT	FROM_DATE, TO_DATE , EMPLOYEE , DATES , ATTENDANCE
				FROM (
						SELECT	ROW_NUMBER( )OVER (ORDER BY AM.FOR_DATE) AS ROW_ID, 
								CASE WHEN ROW_ID = 1 THEN REPLACE(CONVERT(VARCHAR(12) , @FROM_DATE , 106) , ' ' , '-') ELSE '' END AS FROM_DATE , 
								CASE WHEN ROW_ID = 1 THEN REPLACE(CONVERT(VARCHAR(12) , @TO_DATE , 106) , ' ' , '-') ELSE '' END AS TO_DATE,
								CASE WHEN ROW_ID = 1 THEN (EM.ALPHA_EMP_CODE  + ' - ' + EM.EMP_FULL_NAME)ELSE '' END AS EMPLOYEE,
								REPLACE(CONVERT(VARCHAR(12) , AM.FOR_DATE , 106) , ' ' , '-') AS DATES, 
								CASE WHEN AM.MAIN_STATUS = 'L' THEN AM.DETAIL_STATUS ELSE AM.MAIN_STATUS END AS ATTENDANCE
						FROM #ATT_MUSTER AM 
							INNER JOIN T0080_EMP_MASTER Em ON AM.EMP_ID = EM.EMP_ID
					 ) T
				ORDER BY T.DATES
				RETURN
			END
	--CODE ENDS
	
	IF @CONSTRAINT = '' 
	 BEGIN
	 
		Declare @w_sql As varchar(max)
		SET @w_sql = ''
		
	Declare @w_sql_test As varchar(max)
		SET @w_sql_test = ''

		Declare @filter As varchar(500)
		SET @filter = ''
		
		IF @Graph_flag <> ''
			BEGIN
				if @Graph_flag = 'WO'
					BEGIN
						SET @filter = 'Where Main_Status = ''W'''
					End
				Else
					BEGIN
						SET @filter = 'Where Main_Status = ''' + @Graph_flag + ''''
					End
			END
	
		 IF @IsMobileInOut = 1
			BEGIN
			
				SET @w_sql = @w_sql + 'Select IsNull(AM.Emp_Id,0) As Emp_Id,IsNull(AM.Cmp_ID,0) As Cmp_ID,IsNull(AM.branch_ID,0) As branch_ID,IsNull(AM.For_Date,0) As For_Date,
					IsNull(AM.Status,'''') As Status,IsNull(AM.Leave_code,'''') As Leave_code,IsNull(AM.Leave_Count,0) As Leave_Count,IsNull(AM.OD,'''') As OD,IsNull(AM.OD_Count,0) As OD_Count,
					IsNull(AM.WO_HO,'''') As WO_HO,IsNull(AM.Status_2,'''') As Status_2,IsNull(AM.Row_ID,0) As Row_ID,IsNull(AM.In_Date,0) As In_Date,IsNull(AM.Out_Date,0) As Out_Date,
					IsNull(AM.shift_id,0) As shift_id,IsNull(AM.shift_name,'''') As shift_name,IsNull(AM.sh_in_time,'''') As sh_in_time,IsNull(AM.sh_out_time,'''') As sh_out_time,
					IsNull(AM.holiday,'''') As holiday,IsNull(AM.late_limit,'''') As late_limit,IsNull(AM.Reason,'''') As Reason,IsNull(AM.Half_Full_Day,'''') As Half_Full_Day,
					IsNull(AM.Chk_By_Superior,'''') As Chk_By_Superior,IsNull(AM.Sup_Comment,'''') As Sup_Comment,IsNull(AM.Is_Cancel_Late_In,0) As Is_Cancel_Late_In,
					IsNull(AM.Is_Cancel_Early_Out,0) As Is_Cancel_Early_Out,IsNull(AM.Early_Limit,'''') As Early_Limit,IsNull(AM.Main_Status,'''') As Main_Status,
					IsNull(AM.Detail_Status,'''') As Detail_Status,IsNull(AM.Is_Late_Calc_On_HO_WO,0) As Is_Late_Calc_On_HO_WO,IsNull(AM.Is_Early_Calc_On_HO_WO,0) As Is_Early_Calc_On_HO_WO,
					IsNull(AM.late_minute,0) As late_minute,IsNull(AM.Early_minute,0) As Early_minute,IsNull(AM.Is_Leave_App,0) As Is_Leave_App,IsNull(AM.Other_Reason,'''') As Other_Reason,
					IsNull(AM.R_Emp_ID,0) As R_Emp_ID,IsNull(AM.Date_of_join,0) As Date_of_join,IsNull(AM.Left_date,0) As Left_date,
					 IsNull(DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + '' '' + AM.late_limit as datetime)), 0) late_time 
					,IsNull(DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + '' '' + AM.Early_Limit as datetime)), 0) early_time 
					,IsNull(AM.late_minute,0) as late_minutes
					,IsNull(AM.Early_minute,0) as early_out
					,E.Alpha_Emp_Code,E.Emp_full_Name
					,Branch_Name , Dept_Name 
					,Grd_Name , Desig_Name,Branch_Address
					,IsNull(Comp_Name,'''') As Comp_Name,DBRD_Code,IsNull(d.P_days,0.0) P_days
					,IsNull(Emp_Late_mark,0) As Emp_Late_mark,IsNull(Emp_Early_mark,0) As Emp_Early_mark
					,(CASE WHEN IsNull(AM.Reason,'''') <> '''' THEN '''' ELSE ''disabled'' END) AS Disable_Comment,Q_I.Grd_ID,AM.R_Emp_ID			
				From #Att_Muster  AM Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
				INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark 
								FROM T0095_Increment I inner join 
									(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI inner join
										(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID FROM T0095_Increment
										Where Cmp_Id = ' + Cast(@Cmp_Id As Varchar(4)) + ' And Increment_effective_Date <= ''' + Cast(@to_date AS varchar(50)) + ''' Group by emp_ID) new_inc
										on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
										Where TI.Increment_effective_Date <= '''+ Cast(@to_date  AS varchar(50)) + ''' group by ti.emp_id
									) Qry on I.Increment_Id = Qry.Increment_Id
							)Q_I ON E.EMP_ID = Q_I.EMP_ID	
					INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
					T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
					T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID 
					LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date ' + @filter + ' 
				Order by Emp_Code,Am.For_Date desc'

				--SET @w_sql_test = @w_sql_test +  'select 28201 as Emp_Id'
	
			END
		ELSE
			BEGIN
			
				--if condition added by Krushna 05-12-2018 for attendance reg report CORONA
				IF @Report_For = 'Att Reg Report'
					begin
				
						delete from #Att_Muster
						where (Is_Leave_App = 1) 
							or (chk_by_superior in('Approved','Rejected','Pending')) 
							or (Main_Status = 'P' and late_minute <= DateDiff(mi,for_date,cast(cast(for_date as varchar(11)) + ' ' + late_limit as datetime)) and Early_minute <= DateDiff(mi,for_date,cast(cast(for_date as varchar(11)) + ' ' + Early_Limit as datetime)))
							or Main_Status in ('HO','W')				
								
						Select	--AM.* COMMENTED BY RAJPUT DON'T NEED TO TAKE UNUSED COLUMN IN ATTENDANCE REGULARIZATION REPORT (AS DISCUSSED WITH MR. KRISHNA)
								 AM.FOR_DATE
								,AM.IN_DATE
								,AM.OUT_DATE
								,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time 
								,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time 
								,AM.late_minute as late_minutes
								,AM.Early_minute as early_out
								,E.Alpha_Emp_Code
								,E.Emp_full_Name
								,Branch_Name 
								,Dept_Name 
								,Grd_Name	
								,Desig_Name
								,Branch_Address
								,Comp_Name
								,E.DBRD_Code
								,IsNull(d.P_days,0.0) P_days
								,Emp_Late_mark,Emp_Early_mark
								,(CASE WHEN IsNull(AM.Reason,'') <> '' THEN '' ELSE 'disabled' END) AS Disable_Comment
								,Q_I.Grd_ID
								,AM.R_Emp_ID			
								,DBO.F_RETURN_HOURS (DURATION_IN_SEC) AS WORKING_HOUR
								,IsNull(d.Duration_in_sec,0) As Working_Sec
								,IsNull(DBO.F_RETURN_SEC(SHIFT_DURATION),0) as Req_For_App
								,CM.Cmp_Name
								,CM.Cmp_Address
								,TM.Type_Name
								,VS.Vertical_Name
								,SV.SubVertical_Name
								,@From_Date as From_Date
								,@To_Date as To_Date
								,E.Alpha_Code
								,E1.Emp_Full_Name as Reporting_Manager
						From	#Att_Muster AM 
								Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
								INNER JOIN (
												SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark ,I.Type_ID,I.Vertical_ID,I.SubVertical_ID
												FROM	T0095_Increment I 
														inner join (
																		select	Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
																		FROM	t0095_increment TI 
																				inner join (
																								Select	Max(Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID 
																								FROM	T0095_Increment I 
																										Inner Join #Emp_Cons EC On I.Emp_ID= EC.Emp_ID
																								Where	Increment_effective_Date <= @to_date Group by I.emp_ID
																							) new_inc on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
																		Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
																	) Qry on I.Increment_Id = Qry.Increment_Id
											)Q_I ON E.EMP_ID = Q_I.EMP_ID	
								INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID 
								INNER JOIN T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID
								INNER JOIN T0010_COMPANY_MASTER CM ON AM.Cmp_ID = CM.Cmp_ID
								--LEFT JOIN T0090_EMP_REPORTING_DETAIL ESD ON Am.R_Emp_ID = ESD.Emp_ID
								LEFT JOIN T0080_EMP_MASTER E1 on AM.R_Emp_ID = E1.Emp_Id --- Changed by Hardik and above line commented by Hardik as Duplicate Records coming Redmine Bug id : 1263
								LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID 
								LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID
								LEFT outer JOIN t0040_type_master TM on Q_I.type_id = Tm.type_id 
								LEFT Outer JOIN T0040_Vertical_Segment vs On Q_I.Vertical_ID = vs.Vertical_ID  
								LEFT Outer JOIN T0050_SubVertical sv On Q_I.SubVertical_ID = sv.SubVertical_ID						  
								LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date  
						Order by E.Emp_Code,Am.For_Date
					
					
					return
					end
				else
					begin
					
						SET @w_sql = @w_sql + 'Select --AM.*,
							 Am.Emp_Id, Am.Cmp_ID, Am.branch_ID, Am.For_Date, Am.Status
							 --, case when Isnull(AM.LEAVE_CODE,''-'') = ''-'' THEN ''''+ AM.ExFlag 
								--	  when Isnull(AM.ExFlag,'''') = '''' THEN Am.Leave_code	
								--	  ELSE Am.Leave_code + ''-'' + AM.ExFlag END as Leave_code
							,Am.Leave_code 
							,Am.Leave_Count  , Am.OD, Am.OD_Count, Am.WO_HO , Am.Status_2
							,Am.Row_ID, Am.In_Date, Am.Out_Date
							,Am.shift_id, Am.shift_name, Am.sh_in_time, Am.sh_out_time, Am.holiday, Am.late_limit, Am.Reason, Am.Half_Full_Day
							, Am.Chk_By_Superior, Am.Sup_Comment, Am.Is_Cancel_Late_In
							,Am.Is_Cancel_Early_Out, Am.Early_Limit, Am.Main_Status
							, Am.Detail_Status
							--, case when Isnull(AM.Detail_Status,''-'') = ''-'' THEN ''''+ AM.ExFlag 
							--		  when Isnull(AM.ExFlag,'''') = '''' THEN Am.Detail_Status	
							--		  ELSE Am.Detail_Status + ''-'' + AM.ExFlag END as Detail_Status	
							, Am.Is_Late_Calc_On_HO_WO, Am.Is_Early_Calc_On_HO_WO
							, Am.late_minute, Am.Early_minute, Am.Is_Leave_App
							,Am.Other_Reason, Am.R_Emp_ID, Am.Att_Approval_Days, Am.Att_App_ID, Am.Att_Apr_Status, Am.Shift_Duration, Am.OT_Apr_ID, Am.Comp_off_App, Am.Comp_off_Apr
							,Am.OT_Applicable, Am.Display_Birth, Am.Display_Marriage_Date, Am.Date_of_join, Am.Left_date, Am.ExFlag
							,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + '' '' + AM.late_limit as datetime))late_time 
							,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + '' '' + AM.Early_Limit as datetime))early_time 
							,AM.late_minute as late_minutes
							,AM.Early_minute as early_out
							,E.Alpha_Emp_Code,E.Emp_full_Name
							,Branch_Name , Dept_Name 
							,Grd_Name , Desig_Name,Branch_Address
							,Comp_Name,DBRD_Code,IsNull(d.P_days,0.0) P_days
							,Emp_Late_mark,Emp_Early_mark
							,(CASE WHEN IsNull(AM.Reason,'''') <> '''' THEN '''' ELSE ''disabled'' END) AS Disable_Comment,Q_I.Grd_ID,AM.R_Emp_ID			
							,DBO.F_RETURN_HOURS (Case When  ' + Cast(@Tras_Week_OT as Varchar(5)) + ' = 1 AND WO_HO = ''W'' THEN Weekoff_OT_Sec When  ' + Cast(@Tras_Week_OT as Varchar(5)) + ' = 1 AND  WO_HO = ''HO'' THEN Holiday_OT_Sec ELSE DURATION_IN_SEC END) AS WORKING_HOUR
							--,IsNull(d.Duration_in_sec,0) As Working_Sec
							,(Case When  ' + Cast(@Tras_Week_OT as Varchar(5)) + ' = 1 AND WO_HO = ''W'' THEN Isnull(Weekoff_OT_Sec,0) When  ' + Cast(@Tras_Week_OT as Varchar(5)) + ' = 1 AND  WO_HO = ''HO'' THEN Isnull(Holiday_OT_Sec,0) ELSE Isnull(d.Duration_in_sec,0) END) as Working_Sec
							, IsNull(DBO.F_RETURN_SEC(Case When Len(TSD.From_Hour) >= 5 then Cast(TSD.From_Hour as VARCHAR(5)) Else ''0'' + Cast(TSD.From_Hour as VARCHAR(5)) END),0) * 2 as Req_For_App
							,Case When Len(TSD.From_Hour) >= 5 then Cast(TSD.From_Hour as VARCHAR(5)) Else ''0'' + Cast(TSD.From_Hour as VARCHAR(5)) END as Slab_Shift_Hours
							,Case When  ' + Cast(@Tras_Week_OT as Varchar(5)) + ' = 1 AND  (WO_HO = ''W'' OR WO_HO = ''HO'') and (Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0) THEN 1 Else 0 End As Week_Off_OT
							,ExFlag
						From #Att_Muster AM Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
						INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark 
										FROM T0095_Increment I inner join 
											(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI inner join
												(Select Max(Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID 
													FROM T0095_Increment I
													Inner Join #Emp_Cons EC On I.Emp_ID= EC.Emp_ID
												Where Increment_effective_Date <= ''' + Cast(@to_date AS varchar(50)) + ''' Group by I.emp_ID) new_inc
												on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
												Where TI.Increment_effective_Date <= '''+ Cast(@to_date  AS varchar(50)) + ''' group by ti.emp_id
											) Qry on I.Increment_Id = Qry.Increment_Id
									)Q_I ON E.EMP_ID = Q_I.EMP_ID	
							INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
							T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
							T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID 
							LEFT OUTER JOIN T0050_SHIFT_DETAIL TSD ON TSD.Shift_ID = AM.Shift_ID and TSD.Calculate_Days = 1
							LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date ' + @filter + ' 
						Order by Emp_Code,Am.For_Date'
						
						Select Emp_Id From #Att_Muster Group by Emp_Id 
						
					END
			END	    
	    

	   -- Exec(@w_sql);
		    --Exec(@w_sql_test);

	    /*
		Select AM.*,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time 
			,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time 
			-- Changed by rohit on 1810213
			--,case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes
			--,case when DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end early_out  --Alpesh 04-Apr-2012 for night shift
				,AM.late_minute as late_minutes
			,AM.Early_minute as early_out 
			-- Ended by rohit on 18102013
			
			, E.Emp_code,E.Emp_full_Name, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name,DBRD_Code,IsNull(d.P_days,0.0) P_days,Emp_Late_mark,Emp_Early_mark
			, (CASE WHEN IsNull(AM.Reason,'') <> '' THEN '' ELSE 'disabled' END) AS Disable_Comment	--Added by Nimesh 31-Aug-2015
		From #Att_Muster  AM Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark 
						FROM T0095_Increment I inner join 
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID FROM T0095_Increment
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
							) Qry on I.Increment_Id = Qry.Increment_Id
					)Q_I ON E.EMP_ID = Q_I.EMP_ID 				
						--( select max(Increment_effective_Date) as For_Date , Emp_ID FROM T0095_Increment
						--where Increment_Effective_date <= @To_Date
						--and Cmp_ID = @Cmp_ID
						--group by emp_ID  ) Qry on
						--I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
			INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
			#Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date
		Order by Emp_Code,Am.For_Date
		--Select AM.*,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time ,
		--case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes
		--,case when DateDiff(mi,Out_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else DateDiff(mi,Out_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end early_out
		--, E.Emp_code,E.Emp_full_Name, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name
		--From #Att_Muster  AM Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
		--INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM T0095_Increment I inner join 
		--				( select max(Increment_effective_Date) as For_Date , Emp_ID FROM T0095_Increment
		--				where Increment_Effective_date <= @To_Date
		--				and Cmp_ID = @Cmp_ID
		--				group by emp_ID  ) Qry on
		--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
		--	E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		--	T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		--	T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		--	T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID 
		--Order by Emp_Code,Am.For_Date
		*/
		
	 end
	 ELSE IF @Report_For = 'BulkRegularization'  --Added by Jaina 26-02-2018
		BEGIN
			Update #Att_Muster set late_minute = ISNULL(Late_minute,0), Early_minute = ISNULL(Early_Minute,0), Is_Cancel_Late_In = ISNULL(Is_Cancel_Late_In,0), Is_Cancel_Early_Out = ISNULL(Is_Cancel_Early_Out,0)

			Select	AM.*,
					 DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time 
					,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time 
					,AM.late_minute as late_minutes
					,AM.Early_minute as early_out
					,E.Alpha_Emp_Code,E.Emp_full_Name
					,Branch_Name , Dept_Name 
					,Grd_Name , Desig_Name,Branch_Address
					,Comp_Name,DBRD_Code,IsNull(d.P_days,0.0) P_days
					,Emp_Late_mark,Emp_Early_mark
					,(CASE WHEN IsNull(AM.Reason,'') <> '' THEN '' ELSE 'disabled' END) AS Disable_Comment,Q_I.Grd_ID,AM.R_Emp_ID			
			From	#Att_Muster  AM 
					INNER JOIN T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
					INNER JOIN (SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark 
								FROM	T0095_Increment I 
										INNER JOIN #Emp_Cons EC on I.Increment_Id = EC.Increment_Id
								) Q_I ON E.EMP_ID = Q_I.EMP_ID	
					INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID 
					INNER JOIN T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID 
					LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date 
			ORDER BY Emp_Code,Am.For_Date
			
		END
	ELSE IF @Report_For = 'BulkRegularization_Mobile'
		BEGIN

			SELECT ROW_NUMBER() OVER(PARTITION BY Emp_id,cast(IO_Datetime as Date) ORDER BY IO_Datetime desc) as Row_no,
			Max(Convert(varchar(5),IO_Datetime,108)) as [Time],IO_DateTime ,Emp_ID ,isnull(Location,'') as Location
			into #tmpMobileInOut
			FROM	T9999_MOBILE_INOUT_DETAIL I  WITH (NOLOCK) 
			where cast(IO_Datetime as Date) Between @From_Date and @To_Date
			Group by Emp_ID,Location,IO_DateTime
			order by IO_DateTime 

			Delete from #tmpMobileInOut where Row_no > 1 
			
			Select	IsNull(AM.Emp_Id,0) As 'Emp_Id',IsNull(E.Cmp_ID,0) As 'Cmp_ID',IsNull(AM.branch_ID,0) AS 'branch_ID',IsNull(AM.For_Date,0) AS 'For_Date',
					IsNull(AM.Status,'') As Status,IsNull(AM.Leave_code,'') As Leave_code,IsNull(AM.Leave_Count,0) As Leave_Count,IsNull(AM.OD,'') As OD,IsNull(AM.OD_Count,0) As OD_Count,
					IsNull(AM.WO_HO,'') As WO_HO,IsNull(AM.Status_2,'') As Status_2,IsNull(AM.Row_ID,0) As Row_ID,IsNull(AM.In_Date,0) As In_Date,IsNull(AM.Out_Date,0) As Out_Date,
					IsNull(AM.shift_id,0) As shift_id,IsNull(AM.shift_name,'') As shift_name,IsNull(AM.sh_in_time,'') As sh_in_time,IsNull(AM.sh_out_time,'') As sh_out_time,
					IsNull(AM.holiday,'') As holiday,IsNull(AM.late_limit,'') As late_limit,IsNull(AM.Reason,'') As Reason,IsNull(AM.Half_Full_Day,'') As Half_Full_Day,
					IsNull(AM.Chk_By_Superior,'') As Chk_By_Superior,IsNull(AM.Sup_Comment,'') As Sup_Comment,IsNull(AM.Is_Cancel_Late_In,0) As Is_Cancel_Late_In,
					IsNull(AM.Is_Cancel_Early_Out,0) As Is_Cancel_Early_Out,IsNull(AM.Early_Limit,'') As Early_Limit,IsNull(AM.Main_Status,'') As Main_Status,
					IsNull(AM.Detail_Status,'') As Detail_Status,IsNull(AM.Is_Late_Calc_On_HO_WO,0) As Is_Late_Calc_On_HO_WO,IsNull(AM.Is_Early_Calc_On_HO_WO,0) As Is_Early_Calc_On_HO_WO,
					IsNull(AM.late_minute,0) As late_minute,IsNull(AM.Early_minute,0) As Early_minute,IsNull(AM.Is_Leave_App,0) As Is_Leave_App,IsNull(AM.Other_Reason,'') As Other_Reason,
					IsNull(AM.Date_of_join,0) As Date_of_join,IsNull(AM.Left_date,0) As Left_date,
					DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time 
					,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time 
					,IsNull(AM.late_minute,0) as 'late_minutes'
					,IsNull(AM.Early_minute,0) as 'early_out'
					,E.Alpha_Emp_Code,E.Emp_full_Name,Branch_Name , IsNull(Dept_Name ,'') AS 'Dept_Name',IsNull(Grd_Name,'') AS 'Grd_Name', 
					IsNull(Desig_Name,'') AS 'Desig_Name',REPLACE(Branch_Address,'"','') AS 'Branch_Address',IsNull(Comp_Name,'') AS 'Comp_Name',
					IsNull(DBRD_Code,'') AS 'DBRD_Code',IsNull(d.P_days,0.0) AS 'P_days',IsNull(Emp_Late_mark,0) AS 'Emp_Late_mark',
					IsNull(Emp_Early_mark,0) AS 'Emp_Early_mark'
					,(CASE WHEN IsNull(AM.Reason,'') <> '' THEN '' ELSE 'disabled' END) AS Disable_Comment,Q_I.Grd_ID--,AM.R_Emp_ID,
					--,case when am.In_Date = IO_DateTime or am.Out_Date = IO_DateTime then Location else '' end Location
					, MIO.Location
					FROM #Att_Muster  AM 
					INNER JOIN T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
					INNER JOIN (SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark 
								FROM	T0095_Increment I 
										INNER JOIN #Emp_Cons EC on I.Increment_Id = EC.Increment_Id
								) Q_I ON E.EMP_ID = Q_I.EMP_ID	
					INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID 
					INNER JOIN T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID 
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID 
					LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date 
					Left outer join #tmpMobileInOut MIO on MIO.Emp_ID = am.Emp_Id and cast(MIO.IO_Datetime as Date) = cast(am.For_Date as Date) 
					and (MIO.Time = am.Status or MIO.Time =am.Status_2)
					--left Outer JOIN (SELECT	Max(IO_Datetime) as IO_DateTime ,Emp_ID,isnull(Location,'') as Location
					--			FROM	T9999_MOBILE_INOUT_DETAIL I  WITH (NOLOCK) 
					--			Group by Emp_ID,Location
					--			) Q2 ON AM.EMP_ID = Q2.EMP_ID and am.In_Date = IO_DateTime
								--case when am.Out_Date = '1900-01-01 00:00:00.000' then am.In_Date else am.Out_Date end = cast(IO_DateTime as date)
			ORDER BY Emp_Code,Am.For_Date
		
		END
	ELSE IF @constraint ='R'
	 BEGIN
	 
		--Select AM.*,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time ,case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes, E.Emp_code,E.Emp_full_Name
		--	, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name
	
	Select AM.*,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time 
			,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time 
			-- Changed By rohit on 18102013
			--,case when DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else DateDiff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes
			----,case when DateDiff(mi,Out_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else DateDiff(mi,Out_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end early_out
			--,case when DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else DateDiff(mi,Out_Date,cast(cast((case when AM.sh_in_time > AM.sh_out_time then DateAdd(d,1,AM.for_date) else AM.for_date end) as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end early_out
			,AM.late_minute as late_minutes
			,AM.Early_minute as early_out  
			-- Ended by rohit on 18102013			
			
			, E.Emp_code,E.Emp_full_Name, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name,DBRD_Code,IsNull(d.P_days,0.0) P_days,Emp_Late_mark,Emp_Early_mark,INC.Grd_ID,AM.R_Emp_ID
		From #Att_Muster  AM Inner join T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
		INNER JOIN #EMP_CONS EC ON AM.EMP_ID = EC.EMP_ID
		INNER JOIN T0095_INCREMENT INC ON INC.INCREMENT_ID = EC.INCREMENT_ID
		/* COMMENTED BY GADRIWALA MUSLIM 07102016 - INCREMENT ID USED DIRECTLY FROM #EMP_CONS INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark FROM T0095_Increment I inner join 
						--( select max(Increment_effective_Date) as For_Date , Emp_ID FROM T0095_Increment
						--where Increment_Effective_date <= @To_Date
						--and Cmp_ID = @Cmp_ID
						--group by emp_ID  ) Qry on
						--I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID FROM t0095_increment TI inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID FROM T0095_Increment
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
							) Qry on I.Increment_Id = Qry.Increment_Id
						)Q_I ON E.EMP_ID = Q_I.EMP_ID */ INNER JOIN 
			T0040_GRADE_MASTER GM ON INC.GRD_ID = GM.GRD_ID INNER JOIN 
			T0030_BRANCH_MASTER BM ON INC.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM ON INC.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM ON INC.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN 
			#Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date 
		where len(AM.Status)>2	
		Order by Emp_Code,Am.For_Date


	 end
	Else IF @Report_For = 'Att Reg Report'
			begin
			
				delete from #Att_Muster
				where (Is_Leave_App = 1) 
					or (chk_by_superior in('Approved','Rejected','Pending')) 
					or (Main_Status = 'P' and late_minute <= DateDiff(mi,for_date,cast(cast(for_date as varchar(11)) + ' ' + late_limit as datetime)) and Early_minute <= DateDiff(mi,for_date,cast(cast(for_date as varchar(11)) + ' ' + Early_Limit as datetime)))
					or Main_Status in ('HO','W')
					
				--Select	 --AM.* COMMENTED BY RAJPUT DON'T NEED TO TAKE UNUSED COLUMN IN ATTENDANCE REGULARIZATION REPORT (AS DISCUSSED WITH MR. KRISHNA)
				--		 AM.FOR_DATE
				--		,AM.IN_DATE
				--		,AM.OUT_DATE
				--		,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time 
				--		,DateDiff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.Early_Limit as datetime))early_time 
				--		,AM.late_minute as late_minutes
				--		,AM.Early_minute as early_out
				--		,E.Alpha_Emp_Code
				--		,E.Emp_full_Name
				--		,Branch_Name 
				--		,Dept_Name 
				--		,Grd_Name	
				--		,Desig_Name
				--		,Branch_Address
				--		,Comp_Name
				--		,E.DBRD_Code
				--		,IsNull(d.P_days,0.0) P_days
				--		,Emp_Late_mark,Emp_Early_mark
				--		,(CASE WHEN IsNull(AM.Reason,'') <> '' THEN '' ELSE 'disabled' END) AS Disable_Comment
				--		,Q_I.Grd_ID
				--		,AM.R_Emp_ID			
				--		,DBO.F_RETURN_HOURS (DURATION_IN_SEC) AS WORKING_HOUR
				--		,IsNull(d.Duration_in_sec,0) As Working_Sec
				--		,IsNull(DBO.F_RETURN_SEC(SHIFT_DURATION),0) * 1.5 as Req_For_App
				--		,CM.Cmp_Name
				--		,CM.Cmp_Address
				--		,TM.Type_Name
				--		,VS.Vertical_Name
				--		,SV.SubVertical_Name
				--		,@From_Date as From_Date
				--		,@To_Date as To_Date
				--		,E.Alpha_Code
				--		,E1.Emp_Full_Name as Reporting_Manager
				--From	#Att_Muster AM 
				--		INNER JOIN T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
				--		INNER JOIN (
				--						SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark ,I.Type_ID,I.Vertical_ID,I.SubVertical_ID
				--						FROM	T0095_Increment I 
				--								INNER JOIN (
				--												select	Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
				--												FROM	t0095_increment TI 
				--														INNER JOIN (
				--																		Select	Max(Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID 
				--																		FROM	T0095_Increment I 
				--																				INNER JOIN #Emp_Cons EC On I.Emp_ID= EC.Emp_ID
				--																		Where	Increment_effective_Date <= @to_date Group by I.emp_ID
				--																	) new_inc on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				--												Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
				--											) Qry on I.Increment_Id = Qry.Increment_Id
				--					)Q_I ON E.EMP_ID = Q_I.EMP_ID	
				--		INNER JOIN T0040_GRADE_MASTER GM ON Q_I.Grd_Id = gm.Grd_ID 
				--		INNER JOIN T0030_BRANCH_MASTER BM ON Q_I.BRANCH_ID = BM.BRANCH_ID
				--		INNER JOIN T0010_COMPANY_MASTER CM ON AM.Cmp_ID = CM.Cmp_ID
				--		--LEFT JOIN T0090_EMP_REPORTING_DETAIL ESD ON Am.R_Emp_ID = ESD.Emp_ID
				--		LEFT JOIN T0080_EMP_MASTER E1 on AM.R_Emp_ID = E1.Emp_Id --- Changed by Hardik and above line commented by Hardik as Duplicate Records coming Redmine Bug id : 1263
				--		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON Q_I.DEPT_ID = DM.DEPT_ID 
				--		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM ON Q_I.DESIG_ID = DGM.DESIG_ID
				--		LEFT OUTER JOIN t0040_type_master TM on Q_I.type_id = Tm.type_id 
				--		LEFT OUTER JOIN T0040_Vertical_Segment vs On Q_I.Vertical_ID = vs.Vertical_ID  
				--		LEFT OUTER JOIN T0050_SubVertical sv On Q_I.SubVertical_ID = sv.SubVertical_ID						  
				--		LEFT OUTER JOIN #Data d ON AM.Emp_ID=d.Emp_Id AND AM.For_Date=d.For_Date  
				--Order by E.Emp_Code,Am.For_Date

				return
			end
	
  else 
	 BEGIN
	 
		SELECT AM.*,DateDiff(MI,AM.FOR_DATE,CAST(CAST(AM.FOR_DATE AS VARCHAR(11)) + ' ' + AM.LATE_LIMIT AS DATETIME))LATE_TIME 
			,DateDiff(MI,AM.FOR_DATE,CAST(CAST(AM.FOR_DATE AS VARCHAR(11)) + ' ' + AM.EARLY_LIMIT AS DATETIME))EARLY_TIME 		
			,AM.LATE_MINUTE AS LATE_MINUTES,AM.EARLY_MINUTE AS EARLY_OUT ,E.EMP_CODE,E.EMP_FULL_NAME, BRANCH_NAME, DEPT_NAME ,
			GRD_NAME , DESIG_NAME,BRANCH_ADDRESS,COMP_NAME,DBRD_CODE,IsNull(D.P_DAYS,0.0) P_DAYS,EMP_LATE_MARK,EMP_EARLY_MARK,INC.Grd_ID,AM.R_Emp_ID
			
		FROM #ATT_MUSTER  AM INNER JOIN T0080_EMP_MASTER E ON AM.EMP_ID = E.EMP_ID
		INNER JOIN #EMP_CONS EC ON AM.EMP_ID = EC.EMP_ID
		INNER JOIN T0095_INCREMENT INC ON INC.INCREMENT_ID = EC.INCREMENT_ID
		/* COMMENTED BY GADRIWALA MUSLIM 07102016 - - INCREMENT ID USED DIRECTLY FROM #EMP_CONS  INNER JOIN ( SELECT I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.EMP_ID,IsNull(I.EMP_LATE_MARK,0) EMP_LATE_MARK,IsNull(I.EMP_EARLY_MARK,0) EMP_EARLY_MARK FROM T0095_INCREMENT I INNER JOIN 
						( SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS FOR_DATE , EMP_ID FROM T0095_INCREMENT
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @CMP_ID
						GROUP BY EMP_ID  
					  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_EFFECTIVE_DATE = QRY.FOR_DATE	
				    )Q_I ON E.EMP_ID = Q_I.EMP_ID */
		INNER JOIN T0040_GRADE_MASTER GM ON INC.Grd_Id = gm.Grd_ID 
		INNER JOIN T0030_BRANCH_MASTER BM ON INC.BRANCH_ID = BM.BRANCH_ID 
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON INC.DEPT_ID = DM.DEPT_ID 
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM ON INC.DESIG_ID = DGM.DESIG_ID 
		LEFT OUTER JOIN #DATA D ON AM.EMP_ID=D.EMP_ID AND AM.FOR_DATE=D.FOR_DATE		
		WHERE AM.STATUS=@CONSTRAINT
		ORDER BY EMP_CODE,AM.FOR_DATE
	 end
	

	
	SET @Report_For	= 'IN-OUT'
	SET @constraint=''
	
	if exists(select name FROM sysobjects WHERE xtype='U' AND name='#P_Day')
		drop table #P_Day
		
	CREATE TABLE #present
	(
		emp_id numeric(18,0),
		present_days numeric(18,1)
	)
	
	--insert into #present
	--exec SP_RPT_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,7
			
	CREATE TABLE #P_Day
	(
	   emp_id numeric(18,0),
	   Present numeric(18,2) default 0,
       WO numeric(18,2)  default 0,
       HO numeric(18,2) default 0,
       OD numeric(18,2) default 0,
       Absent  numeric(18,2) default 0,
       Leave  numeric(18,2) default 0,
       Total  numeric(18,2) default 0,
       D_Present numeric(18,2) default 0
 	)	

	--insert into #P_Day(Present,emp_id)
	--select IsNull(present_days,0),emp_id FROM #present 		
	insert into #P_Day(Total,emp_id)
 	select 0,emp_id FROM #Att_Muster WHERE Main_Status <> '-' AND for_date<=@To_Date  group by emp_id		-- Gadriwala 04022014 Change Getdate() to @To_Date
 	

 	UPDATE #P_DAY
 	  SET WO = AM.MAIN_STATUS
 	FROM #P_DAY PD INNER JOIN 
 	(
 		SELECT IsNull(COUNT(IsNull(MAIN_STATUS,'')),0)AS MAIN_STATUS,AMD.EMP_ID FROM #ATT_MUSTER AMD
 		LEFT OUTER JOIN  #DATA D ON AMD.EMP_ID=D.EMP_ID AND AMD.FOR_DATE=D.FOR_DATE 
 		WHERE AMD.MAIN_STATUS='W' AND (AMD.OD <> 'OD' 
 	) AND IsNull(D.P_DAYS,'0.0') <> '1.0' --AND IN_DATE IS NULL AND OUT_DATE IS NULL  
 	AND AMD.FOR_DATE<= @TO_DATE GROUP BY AMD.EMP_ID)AM -- GADRIWALA 04022014 CHANGE GETDATE() TO @TO_DATE
 	ON PD.EMP_ID=AM.EMP_ID
 	
 	UPDATE #P_DAY
 	  SET WO = IsNull(WO,0) + AM.MAIN_STATUS
 	FROM #P_DAY PD INNER JOIN 
 	(
 		SELECT SUM(IsNull(OD_COUNT,0))AS MAIN_STATUS,EMP_ID FROM #ATT_MUSTER 
 		WHERE MAIN_STATUS='W' AND OD ='OD' AND OD_COUNT='0.5' --AND IN_DATE IS NULL AND OUT_DATE IS NULL  
 		AND FOR_DATE<= @TO_DATE GROUP BY EMP_ID
 	 )AM -- GADRIWALA 04022014 CHANGE GETDATE() TO @TO_DATE
 		ON PD.EMP_ID=AM.EMP_ID
 	
 	 	
 	UPDATE #P_DAY
 	  SET OD = AM.STATUS
 	FROM #P_DAY PD INNER JOIN 
 	(
 		SELECT SUM(IsNull(OD_COUNT,0))AS STATUS,EMP_ID FROM #ATT_MUSTER 
 		WHERE (MAIN_STATUS='OD' OR OD = 'OD') AND FOR_DATE<=@TO_DATE 
 		GROUP BY EMP_ID
 	)AM -- GADRIWALA 04022014 CHANGE GETDATE() TO @TO_DATE
 	ON PD.EMP_ID=AM.EMP_ID

 	
 	UPDATE #P_DAY
 	  SET LEAVE = AM.STATUS
 	FROM #P_DAY PD INNER JOIN																									 	
 	(
 		SELECT IsNull(SUM(IsNull(LEAVE_COUNT,0)),0)AS STATUS,EMP_ID FROM #ATT_MUSTER 
 		WHERE (MAIN_STATUS='L' OR LEAVE_COUNT > 0 ) AND LEAVE_CODE <> 'LWP'
		--AND FOR_DATE<=@TO_DATE -- Commented by Niraj (15032022) for Digvijay ref. Sandipbhai
		GROUP BY EMP_ID
 	 )AM	-- GADRIWALA 04022014 CHANGE GETDATE() TO @TO_DATE
 	ON PD.EMP_ID=AM.EMP_ID
 	
 	UPDATE #P_DAY
 	  SET HO = AM.STATUS
 	FROM #P_DAY PD INNER JOIN 
 	(
 		SELECT IsNull(COUNT(IsNull(MAIN_STATUS,'')),0) AS STATUS,AMD.EMP_ID FROM #ATT_MUSTER AMD
 		LEFT OUTER JOIN  #DATA D ON AMD.EMP_ID=D.EMP_ID AND AMD.FOR_DATE=D.FOR_DATE 
 	    WHERE AMD.MAIN_STATUS='HO'  AND (AMD.OD <> 'OD' ) AND IsNull(D.P_DAYS,'0.0') <> '1.0' AND AMD.FOR_DATE<=@TO_DATE GROUP BY AMD.EMP_ID
 	)AM ON PD.EMP_ID=AM.EMP_ID      
 		
	 UPDATE #P_DAY
 	  SET HO = AM.STATUS
 	FROM #P_DAY PD INNER JOIN 
 	(
 		SELECT SUM(IsNull(OD_COUNT,0)) AS STATUS,EMP_ID FROM #ATT_MUSTER 
 		WHERE MAIN_STATUS='HO'  AND OD = 'OD' AND OD_COUNT='0.5'  AND FOR_DATE<= @TO_DATE GROUP BY EMP_ID
 	)AM   ON PD.EMP_ID=AM.EMP_ID       
 		
	UPDATE #P_DAY					--ALPESH 30-MAY-2012
		SET PRESENT = AM.STATUS	
 	FROM #P_DAY PD INNER JOIN
	(
		SELECT IsNull(SUM(IsNull(AAT.P_DAYS,0)),0)AS STATUS,EMP_ID FROM #DATA AAT 
		WHERE  AAT.FOR_DATE<=@TO_DATE GROUP BY EMP_ID
	 )AM ON PD.EMP_ID = AM.EMP_ID		
		
	UPDATE #P_DAY
 	  SET D_PRESENT = AM.STATUS
 	FROM #P_DAY PD INNER JOIN 
	(
 		SELECT IsNull(COUNT(MAIN_STATUS),0)AS STATUS,EMP_ID FROM #ATT_MUSTER 
 		WHERE LEN(MAIN_STATUS)>2 GROUP BY EMP_ID
 	)AM ON PD.EMP_ID=AM.EMP_ID 	
 	 	

	Declare @total numeric(18,0)
	declare @Temp_Date datetime
	SET @total = 0
	--Added by Jaina 26-12-2017 start
	--SET @TOTAL = DateDiff(D,@FROM_DATE,@TO_DATE) + 1
	IF @Date_of_join > @FROM_DATE
		SET @Temp_Date = @Date_of_join
	else
		SET @Temp_Date = @FROM_DATE
		
	IF @LEFT_DATE < @TO_DATE 
		SET @TOTAL = DateDiff(D,@LEFT_DATE,@TO_DATE) + 1
	ELSE IF @LEFT_DATE <= @FROM_DATE
		SET @TOTAL = DateDiff(D,@LEFT_DATE,@TO_DATE) + 1
	ELSE
		SET @TOTAL = DateDiff(D,@Temp_Date,@TO_DATE) + 1
	
	--Added by Jaina 26-12-2017 End
	
	Update #P_Day		
	set Total = @total,
	Absent = IsNull((@total - (IsNull(Present,0) + IsNull(WO,0) + IsNull(OD,0) + IsNull(Leave,0) + IsNull(HO,0) )),0)
 	-- Ended by rohit on 26082013
 	
	    --Comment by ronakk 14072022
 	    --IF @IsMobileInOut = 1 -- Added by Niraj (03032022)
		--select GETDATE() as get_Date
		select 28201 as 'emp_id'
 	--Select emp_id FROM #P_Day
	Drop Table #P_Day
		
RETURN




