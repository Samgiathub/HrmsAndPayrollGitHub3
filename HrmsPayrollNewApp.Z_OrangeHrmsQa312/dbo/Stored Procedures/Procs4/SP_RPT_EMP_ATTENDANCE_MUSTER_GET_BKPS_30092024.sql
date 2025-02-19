CREATE PROCEDURE [dbo].[SP_RPT_EMP_ATTENDANCE_MUSTER_GET_BKPS_30092024]
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
	,@Export_Type	varchar(50) = ''
	,@Type			numeric = 0  -- Added By Ali 03032014
	,@Con_Absent_Days   numeric = 0  -- Added By Nilesh Patel on 28102015 For Continues Absent Report
	,@Cancel_WKOF Numeric = 0 --Added By Ramiz on 14/04/2016 for Continues Absent  
	,@P_Branch varchar(max) = ''  --Added By Jaina 09-08-2016
	,@P_Department varchar(max) = ''   --Added By Jaina 09-08-2016
	,@P_Vertical varchar(max) = ''  --Added By Jaina 09-08-2016
	,@P_SubVertical varchar(max) = ''  --Added By Jaina 09-08-2016	
	,@Leave_Flag Numeric(18,0) = 0	
	,@Opt_Para numeric = 0
	--,@Segment_Id	numeric = 0  --Mukti(10082020)
AS
	SET NOCOUNT ON	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF;

	DECLARE @MANUAL_SALARY_PERIOD TINYINT	

	IF @Export_Type = 'Calendar'  or @Export_Type = 'Attendance Regularization' or  (@Report_For='Complete_Absent' And @Export_Type='999') --Added by Jaina 18-07-2020 Attendance Condition
		BEGIN
			DECLARE @Sal_St_Date DateTime 
			DECLARE @Sal_End_Date DateTime
			Declare @Late_Early_Ded_Combine Numeric
			Set @Late_Early_Ded_Combine = 0
			Declare @LateEarly_MonthWise Numeric(2,0) 
			SET @LateEarly_MonthWise = 0
			Declare @Late_Mark_Scenario Numeric(2,0) --Added by nilesh patel 
			SET @Late_Mark_Scenario = 1

			IF @BRANCH_ID IS NULL or @BRANCH_ID = 0
				BEGIN 
					-- CHANGED BY GADRIWALA MUSLIM 06102016 - REPLACE INNER MAX QUERY TO INNER JOIN MAX QUERY
					SELECT TOP 1 @SAL_ST_DATE  = SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=ISNULL(MANUAL_SALARY_PERIOD ,0)
					,@Late_Early_Ded_Combine = Isnull(Is_Chk_Late_Early_Mark,0)
					,@LateEarly_MonthWise = Isnull(LateEarly_MonthWise,0),
                @Late_Mark_Scenario = ISNULL(Late_Mark_Scenario,1)
						FROM T0040_GENERAL_SETTING GS WITH (NOLOCK) INNER JOIN (
							SELECT  MAX(FOR_DATE) FOR_DATE FROM T0040_GENERAL_SETTING WITH (NOLOCK) 
							WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID
						) QRY ON QRY.FOR_DATE = GS.FOR_DATE
						WHERE CMP_ID = @CMP_ID    
							  
				END
			ELSE
				BEGIN
					-- CHANGED BY GADRIWALA MUSLIM 06102016 - REPLACE INNER MAX QUERY TO INNER JOIN MAX QUERY
					SELECT @SAL_ST_DATE  =SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=ISNULL(MANUAL_SALARY_PERIOD ,0)
					,@Late_Early_Ded_Combine = Isnull(Is_Chk_Late_Early_Mark,0)
					,@LateEarly_MonthWise = Isnull(LateEarly_MonthWise,0)
					,@Late_Mark_Scenario = ISNULL(Late_Mark_Scenario,1)
				FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)  INNER JOIN
						(
							SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING  WITH (NOLOCK) 
							WHERE FOR_DATE <= @TO_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
							GROUP BY BRANCH_ID
						)QRY ON QRY.FOR_DATE = GS.FOR_DATE AND QRY.BRANCH_ID= GS.BRANCH_ID
						WHERE CMP_ID = @CMP_ID AND GS.BRANCH_ID = @BRANCH_ID    					
				END 
					
		
		
			if isnull(@Sal_St_Date,'') = ''    
					begin    
						set @From_Date  = @From_Date     
						set @To_Date = @To_Date    
						--set @OutOf_Days = @OutOf_Days
					end  
						     
				else if day(@Sal_St_Date) =1
					begin    
						set @From_Date  = @From_Date     
						set @To_Date = @To_Date    
						--set @OutOf_Days = @OutOf_Days    	         
					end
							  		  
				else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						begin   
						if @manual_salary_period = 0 
							begin
								set @Sal_St_Date = DATEADD(D,DAY(@Sal_St_Date), DATEADD(d, Day(@From_Date) *-1, @From_Date))
								IF DAY(@Sal_St_Date) > Day(@From_Date)
									set @Sal_St_Date = DATEADD(M, -1, @Sal_St_Date)
											
								--set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
								set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
								--set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						
								Set @From_Date = @Sal_St_Date
								Set @To_Date = @Sal_End_Date 
							end 
						else
							begin
								select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
								--set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
								Set @From_Date = @Sal_St_Date
								Set @To_Date = @Sal_End_Date 
							end   
						end
		END
	CREATE TABLE #Data     
	(     
		Emp_Id     numeric ,     
		For_date   datetime,    
		Duration_in_sec  numeric, 
		Shift_ID   numeric ,    
		Shift_Type   numeric ,    
		Emp_OT    numeric ,    
		Emp_OT_min_Limit numeric,    
		Emp_OT_max_Limit numeric,    
		P_days    numeric(12,3) default 0,
		OT_Sec    numeric default 0,
		In_Time datetime default null,
		Shift_Start_Time datetime default null,
		OT_Start_Time numeric default 0,
		Shift_Change tinyint default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0,
		Out_time datetime default null,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    
    
	CREATE NONCLUSTERED INDEX IX_Data ON dbo.#data
	(
		Emp_Id,
		Shift_ID,
		For_Date
	) 
	
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	--IF @Segment_Id =0
	--	SET @Segment_Id = NULL

	--Added By Jaina 09-08-2016 Start	
	 IF (@P_Branch = '' OR @P_Branch = '0') 
		SET @P_Branch = NULL;    
	
	 IF (@P_Vertical = '' OR @P_Vertical = '0')
		SET @P_Vertical = NULL
	
	IF (@P_Subvertical = '' OR @P_Subvertical = '0') 
		set @P_Subvertical = NULL
	
	IF (@P_Department = '' OR @P_Department = '0') 
		set @P_Department = NULL

	if @P_Branch is null
		Begin	
			select   @P_Branch = COALESCE(@P_Branch + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK)  where Cmp_ID=@Cmp_ID 
			set @P_Branch = @P_Branch + ',0'
		End
	
	if @P_Vertical is null
		Begin	
			select   @P_Vertical = COALESCE(@P_Vertical + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK)  where Cmp_ID=@Cmp_ID 
		
			If @P_Vertical IS NULL
				set @P_Vertical = '0';
			else
				set @P_Vertical = @P_Vertical + ',0'		
		End
	if @P_Subvertical is null
		Begin	
			select   @P_Subvertical = COALESCE(@P_Subvertical + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK)  where Cmp_ID=@Cmp_ID 
		
			If @P_Subvertical IS NULL
				set @P_Subvertical = '0';
			else
				set @P_Subvertical = @P_Subvertical + ',0'
		End
	IF @P_Department is null
		Begin
			select   @P_Department = COALESCE(@P_Department + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK)  where Cmp_ID=@Cmp_ID 		
		
			if @P_Department is null
				set @P_Department = '0';
			else
				set @P_Department = @P_Department + ',0'
		End
	
	
	--Added By Jaina 09-08-2016 End
	
	Declare @Is_Cancel_Holiday  numeric(1,0)
	Declare @Is_Cancel_Weekoff	numeric(1,0)	
	CREATE TABLE #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	 )      
	
	
	-- Ankit 08092014 for Same Date Increment
	
	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0
		
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);

	IF @Report_For = 'EMP RECORD' 
		BEGIN
			
			/*Commented by Nimesh 04-Sep-2015
			-- Addded By Ali 13/01/2014 -- Start
			SET @leave_Footer = STUFF(@leave_Footer, CHARINDEX('COMP', @leave_Footer), 4, 'CO')
			SET @leave_Footer = STUFF(@leave_Footer, CHARINDEX('LWP', @leave_Footer), 4, 'UP ')
			-- Addded By Ali 13/01/2014 -- End
			*/
			Select E.Emp_ID ,E.Emp_code, E.Alpha_Emp_Code, E.Emp_First_Name, E.Emp_full_Name ,Comp_Name,Branch_Address
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name
			,Type_Name 
			,CMP_NAME,CMP_ADDRESS
			,@From_Date as P_From_date ,@To_Date as P_To_Date,BM.BRANCH_ID		
			,'' as Leave_Footer 
			,E.Enroll_No
			,IsNUll(DM.Dept_Dis_no,0) as Dept_Dis_no  --added jimit 04082015
			,ISNULL(DGM.Desig_Dis_No,0) as Desig_Dis_No --added jimit 24082015
			,VS.Vertical_Name,SV.SubVertical_Name     --added jimit 27042016
			,SB.SubBranch_Name
			,(select top 1 Director_Name from T0010_COMPANY_DIRECTOR_DETAIL WITH (NOLOCK)  where Cmp_ID = @Cmp_ID) as CMP_Director_Name
			,E.Father_name, Case E.Gender  When 'M' Then 'Male' When 'F' Then 'Female' Else '' End Gender -- Added by Hardik 21/10/2020 for Trident

			From #Emp_Cons EC INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
			( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID,I.Vertical_ID,I.SubVertical_ID, I.subBranch_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK)  ON Q_I.DESIG_ID = DGM.DESIG_ID INNER JOIN 
			dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK)  ON CM.CMP_ID = E.CMP_ID Left outer join 
			dbo.T0040_Type_Master tm WITH (NOLOCK)  on Q_I.Type_ID = tm.Type_ID LEFT outer JOIN
			T0040_Vertical_Segment VS WITH (NOLOCK) 	On Vs.Vertical_ID = Q_I.vertical_Id LEFT OUTER JOIN
			T0050_SubVertical SV WITH (NOLOCK)  ON sv.SubVertical_ID = Q_I.SubVertical_ID LEFT OUTER JOIN
			T0050_SubBranch SB WITH (NOLOCK)  ON SB.SubBranch_ID = Q_I.SubBranch_ID
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
			
			return 
		END
	--PRINT 'ATT 2 :' + CONVERT(VARCHAR(20), GETDATE(), 114)

	--- Added by Hardik 02/04/2019 for NLMK
	CREATE TABLE #EMP_GEN_SETTINGS_ATT
	(
		EMP_ID NUMERIC PRIMARY KEY,
		BRANCH_ID NUMERIC,
		Half_day_Excepted_count INT,
		Gen_Id INT
	) 
	
	INSERT INTO #EMP_GEN_SETTINGS_ATT
	SELECT EMP_ID,Branch_ID,0,0 FROM #Emp_Cons
	
    UPDATE	TG
    SET		Half_day_Excepted_count = G.Half_day_Excepted_count,
			Gen_Id = G.GEN_Id
    FROM	#EMP_GEN_SETTINGS_ATT TG 
			INNER JOIN  T0040_GENERAL_SETTING G WITH (NOLOCK)  ON TG.BRANCH_ID=G.BRANCH_ID
			INNER JOIN (SELECT	MAX(GEN_ID) AS GEN_ID, G1.BRANCH_ID
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK) 
								INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE , BRANCH_ID
											FROM	T0040_GENERAL_SETTING G2 WITH (NOLOCK) 
											WHERE	G2.For_Date <= @TO_DATE AND G2.Cmp_ID = @Cmp_Id
											GROUP	BY G2.Branch_ID) G2 ON G1.Branch_ID=G2.Branch_ID AND G1.For_Date=G2.FOR_DATE
						GROUP BY G1.Branch_ID) G1 ON G.Gen_ID=G1.GEN_ID AND G.Branch_ID=G1.Branch_ID


	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	Declare @strHoliday_Date As Varchar(max)
	Declare @StrWeekoff_Date  varchar(max)

	Declare @OD_Compoff_As_Present tinyint --Hardik 21/07/2014
	Set @OD_Compoff_As_Present = 0 --Hardik 21/07/2014
	
	--Hardik 21/07/2014
	SELECT @OD_COMPOFF_AS_PRESENT = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK)  
	WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @CMP_ID
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 

	 set @Date_Diff = 38 - ( @Date_Diff)                   --Added new Column for Gate Pass
	               
		
	set @New_To_Date = dateadd(d,@date_diff,@To_Date)
	Set @StrHoliday_Date = ''      
	set @StrWeekoff_Date = ''
	
	Declare @Att_Period  table
	  (
		For_Date	datetime Primary key,
		Row_ID		numeric
	  );
	--CREATE UNIQUE CLUSTERED INDEX IX_ATT_PERIOD ON @Att_Period (FOR_DATE);
	
	/*********************************************
	Added by Nimesh on 16-Nov-2015
	Replaced while loop with a simple select query
	*********************************************/
	
	INSERT INTO @Att_Period (For_Date,Row_ID)
	SELECT	DATEADD(d, T.ROW_ID-1, @From_Date), ROW_ID
	FROM	(
				SELECT	
				TOP 40 ROW_NUMBER() OVER(ORDER BY OBJECT_ID) AS ROW_ID 
				FROM	SYS.objects
			) T
	WHERE	DATEADD(d, T.ROW_ID-1, @From_Date) <= @New_To_Date 
	 
	 
	/*
	set @For_Date = @From_Date
	set @Row_ID = 1
	While @For_Date <= @New_To_Date
		begin
			----PRINT @For_Date
			insert into @Att_Period 
			select @For_Date ,@Row_ID
			set @Row_ID =@Row_ID + 1
			set @for_Date = dateadd(d,1,@for_date)
		end
	*/
	
	--if	exists (select * from [tempdb].dbo.sysobjects where name like '#Att_Muster' )		
	IF OBJECT_ID('tempdb..#Att_Muster') IS NOT NULL
		begin
			drop table #Att_Muster
		end
			
	
	 CREATE TABLE #Att_Muster 
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			[Status]	varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
			Leave_Count	numeric(12,3),--numeric(5,2),
			WO_HO		varchar(3), --2 to 3 char changed by Sumit for showing 'OHO' optional Holiday on 9/11/2016
			Status_2	varchar(20),
			Row_ID		numeric ,
			WO_HO_Day	numeric(3,2) default 0,
			P_days		numeric(12,3) default 0, 
			A_days		numeric(12,3) default 0,
			Join_Date	Datetime default null,
			Left_Date	Datetime default null,
			GatePass_Days numeric(18,2) default 0, --Added by Gadriwala Muslim 07042015
			Late_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
			Early_deduct_Days numeric(18,2) default 0  --Added by Gadriwala Muslim 07042015
	  )
	  
	CREATE UNIQUE NONCLUSTERED INDEX IX_ATT_MUSTER ON #Att_Muster (Emp_ID, For_Date);

	--PRINT 'ATT 3 :' + CONVERT(VARCHAR(20), GETDATE(), 114)
	 
	INSERT INTO #Att_Muster (Emp_ID,Cmp_ID,For_Date,row_ID)
	SELECT 	Emp_ID ,@Cmp_ID ,For_Date,Row_ID 
	FROM @Att_Period CROSS JOIN #Emp_Cons	
	
	
	
	--PRINT 'STATE 2 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
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
		begin
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
		end
		ELSE IF @Report_For = 'ABSENT_CON' AND @Cancel_WKOF <> 1 
		begin
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0
		end
	END
	

	
	/********************************************************************
	Added by Nimesh : End of Declaration
	*********************************************************************/
	--PRINT 'STATE 3 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	-- Hardik 17/06/2013 
	--insert into #Att_Muster_Manual (Emp_ID,Cmp_ID,For_Date,row_ID)
	--Select 	E.Emp_ID ,@Cmp_ID ,For_Date,row_ID from @Att_Period cross join #Emp_Cons E 
	--	Inner join T0170_EMP_ATTENDANCE_IMPORT T on E.Emp_ID = T.Emp_ID
	--Where Month = Month(@To_Date) And Year = Year(@To_Date)
	
	--Delete #Att_Muster Where Emp_Id in (Select Emp_Id From #Att_Muster_Manual)
	
	/*Commented by Nimesh on 31-Oct-2015 (Moved this line after following cursor to make priority to import data first)
	Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@emp_ID,@Constraint,4,'',1   
	--Exec dbo.SP_CALCULATE_PRESENT_DAYS_TEST_hardik @Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,@emp_ID,@Constraint,4   
	*/
	
	Declare @Cur_Impt_Emp_ID as numeric   -- Added by Gadriwala Muslim 15052015
	
	/**************************************************************************************
	Commented by Nimesh on 16-Nov-2015
	We are using new holiday/weekoff stored procedure that retrieves the data for all 
	employee at once.
	
	
	--Hardik 08/07/2013
	Declare @Join_Date as Datetime
	Declare @Left_Date as Datetime
	
	Declare cur_emp cursor fast_forward for 
		Select Emp_ID From #Emp_Cons
	open cur_emp
	fetch next from Cur_Emp into @Cur_Impt_Emp_ID 
	while @@fetch_Status = 0
		begin 

				--Hardik 08/07/2013		
				Set @Join_Date = Null
				Set @Left_Date = Null

				exec dbo.SP_EMP_JOIN_LEFT_DATE_GET @Cur_Impt_Emp_ID ,@Cmp_ID ,@From_Date,@To_date,@Join_Date output,@Left_Date output				
				Update #Att_Muster Set Join_Date = @Join_Date, Left_Date = @Left_Date Where Emp_Id = @Cur_Impt_Emp_ID
				
			----Added Condition by Hardik 14/06/2013 for Manual In Out Import
			If not exists (Select 1 From T0170_EMP_ATTENDANCE_IMPORT Where Emp_ID = @Cur_Impt_Emp_ID And Month = Month(@To_Date) And Year = Year(@To_Date))
				Begin
					select 	@Branch_ID = Branch_ID From dbo.T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment	-- Ankit 08092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
					Where I.Emp_ID = @Cur_Impt_Emp_ID

					select @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)
					from dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
					and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
					
					--Added by Hardik on 28/09/2011 for check working hours for Half day
					--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
					
					--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Cur_Impt_Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
					--Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Cur_Impt_Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
					
					-- --End of Added by Mihir Adeshara 07062012
				End
				-- Don't Delete this Comment Because this thing used in sales india for Showing LC in report. on 07082013
				--exec SP_RPT_EMP_LATE_RECORD_GET @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',@Report_Type='LateSecond'
			set @Cur_Impt_Emp_ID=0
			set @StrHoliday_Date = ''
			set @StrWeekoff_Date = ''

			fetch next from Cur_Emp into @Cur_Impt_Emp_ID 
		end 
	close cur_Emp

	Deallocate cur_Emp
	*/
	UPDATE	#ATT_MUSTER
	SET		JOIN_DATE=ISNULL(L1.JOIN_DATE, L2.JOIN_DATE),LEFT_DATE = ISNULL(L1.LEFT_DATE,L2.LEFT_DATE)
	FROM	#ATT_MUSTER A 
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON A.EMP_ID=E.EMP_ID
			LEFT OUTER JOIN (
				SELECT	MAX(ELJ.JOIN_DATE) AS JOIN_DATE,MAX(ELJ.LEFT_DATE) AS LEFT_DATE,ElJ.EMP_ID  -- CHANGED BY GADRIWALA MUSLIM 03102016 - ADD MAX(LEFT_DATE),#ATT_MUSTER INNER JOIN
				FROM	T0110_EMP_LEFT_JOIN_TRAN ELJ WITH (NOLOCK)  INNER JOIN
				#ATT_MUSTER AM ON ELJ.EMP_ID =AM.EMP_ID 
				WHERE ELJ.CMP_ID = @CMP_ID AND ELJ.LEFT_DATE <= @TO_DATE
				GROUP BY ELJ.EMP_ID
			) L1 ON L1.EMP_ID=E.EMP_ID
			LEFT OUTER JOIN (
				SELECT	MAX(ELJ.JOIN_DATE) AS JOIN_DATE,MAX(ELJ.LEFT_DATE) AS LEFT_DATE,ElJ.EMP_ID -- CHANGED BY GADRIWALA MUSLIM 03102016 - ADD MAX(LEFT_DATE),#ATT_MUSTER INNER JOIN
				FROM	T0110_EMP_LEFT_JOIN_TRAN  ELJ WITH (NOLOCK)  INNER JOIN
				#ATT_MUSTER AM ON ELJ.EMP_ID =AM.EMP_ID 
				WHERE	ELJ.CMP_ID = @CMP_ID
				GROUP BY ELJ.EMP_ID
			) L2 ON L2.EMP_ID=E.EMP_ID 
			--LEFT OUTER JOIN ( -- COMMENTED BY GADRIWALA MUSLIM 03102016 - NOT REQUIRE CODE
			--	SELECT	LEFT_DATE, EMP_ID, JOIN_DATE 
			--	FROM	T0110_EMP_LEFT_JOIN_TRAN 
			--	WHERE	CMP_ID = @CMP_ID
			--) L3 ON L3.EMP_ID=E.EMP_ID AND L3.JOIN_DATE = ISNULL(L1.JOIN_DATE, L2.JOIN_DATE)
	 WHERE	E.CMP_ID=@CMP_ID
	
	

	---Hardik 17/06/2013 for Manual In Out Import Record
	Declare @Att_Detail as Varchar(Max)
	Declare @Data as varchar(10)
	Declare @Pre_Data as varchar(10)
	Declare @Count as numeric
	Declare @Date_Diff1 as Numeric
	Declare @Temp_From_Date as datetime
	Declare @Temp_To_Date as datetime
	DECLARE @ATT_FIRST_HALF AS NVARCHAR(MAX) -- ADDED BY GADRIWALA MUSLIM 03102016
	DECLARE @ATT_SECOND_HALF AS NVARCHAR(MAX)-- ADDED BY GADRIWALA MUSLIM 03102016
	

	DECLARE @ImportedEmpCons Varchar(max);	
	SET @ImportedEmpCons = '';
	
	DECLARE CUR_EMP CURSOR FAST_FORWARD FOR  
	SELECT I.EMP_ID, ATT_DETAIL FROM T0170_EMP_ATTENDANCE_IMPORT I  WITH (NOLOCK) 
	INNER JOIN #EMP_CONS E ON I.EMP_ID = E.EMP_ID
	WHERE MONTH = MONTH(@TO_DATE) AND YEAR = YEAR(@TO_DATE)
	OPEN CUR_EMP
		FETCH NEXT FROM CUR_EMP INTO @CUR_IMPT_EMP_ID,@ATT_DETAIL
	WHILE @@FETCH_STATUS = 0
		BEGIN 			
			SET @ATT_FIRST_HALF = ''
			SET @ATT_SECOND_HALF = ''
	
			Set @Temp_From_Date = @From_Date
			Set @Temp_To_Date = @To_Date
			set @Date_Diff1 = datediff(d,@From_Date,@To_Date) + 1
			Set @Count = 1
			IF @REPORT_FOR = 'ABSENT_CUTOFF'  --ADDED BY HARDIK 02/02/2016
				BEGIN
					SET @COUNT = DAY(@TEMP_FROM_DATE)
					SET @DATE_DIFF1 = @DATE_DIFF1 + DAY(@FROM_DATE)
				END		
			IF @ATT_DETAIL <> ''
				BEGIN
						SET @IMPORTEDEMPCONS = @IMPORTEDEMPCONS + CAST(@CUR_IMPT_EMP_ID AS VARCHAR(10)) + '#'
						SELECT @ATT_FIRST_HALF = DATA FROM DBO.SPLIT(@ATT_DETAIL,'/') WHERE ID = 1
						SELECT @ATT_SECOND_HALF = DATA FROM DBO.SPLIT(@ATT_DETAIL,'/') WHERE ID = 2
						WHILE @COUNT <= @DATE_DIFF1
							BEGIN
									SELECT @DATA = DATA FROM DBO.SPLIT(@ATT_FIRST_HALF,'#')  WHERE ID = @COUNT
									IF @DATA <> ''
										BEGIN
										UPDATE #ATT_MUSTER 
										SET STATUS = @DATA, 
											P_DAYS = QRY.PRESENT_DAY,
											A_DAYS = QRY.ABSENT_DAY,
											WO_HO = QRY.WO_HO,
											WO_HO_DAY = QRY.WO_HO_DAY
											FROM #ATT_MUSTER AM INNER JOIN
											(
													SELECT  EMP_ID,FOR_DATE,
													CASE WHEN @DATA = 'P' THEN  1 ELSE  0 END AS PRESENT_DAY,
													CASE WHEN @DATA = 'A' THEN  1 ELSE 0 END AS ABSENT_DAY,
													CASE WHEN @DATA = 'W' OR @DATA = 'HO' THEN  1 ELSE 0 END AS WO_HO_DAY,
													CASE WHEN @DATA = 'W' OR @DATA = 'HO' THEN  @DATA ELSE NULL END AS WO_HO
													FROM #ATT_MUSTER
													WHERE EMP_ID = @CUR_IMPT_EMP_ID AND FOR_DATE = @TEMP_FROM_DATE
												
											)QRY ON QRY.EMP_ID = AM.EMP_ID and QRY.FOR_DATE = AM.FOR_DATE
										
											WHERE AM.EMP_ID = @CUR_IMPT_EMP_ID AND AM.FOR_DATE = @TEMP_FROM_DATE
										END
									SET @DATA = ''
									SELECT @DATA = DATA FROM DBO.SPLIT(@ATT_SECOND_HALF,'#')  WHERE ID = @COUNT
									IF @DATA <> ''
										BEGIN
											UPDATE #ATT_MUSTER SET 
											P_DAYS = QRY.PRESENT_DAY,
											A_DAYS = QRY.ABSENT_DAY,
											STATUS = QRY.STATUS
											FROM #ATT_MUSTER AM INNER JOIN
											(
													SELECT  EMP_ID,FOR_DATE,
													CASE WHEN	(@DATA = 'P' AND STATUS= 'A') 
															OR (@DATA = 'A' AND STATUS= 'P') 
															OR  (@DATA <> 'P' AND @DATA <> 'A' AND @DATA <> 'W' AND @DATA <> 'HO' AND STATUS='P') 
															OR  (STATUS <> 'P' AND STATUS <> 'A' AND STATUS <> 'W' AND STATUS <> 'HO' AND @DATA='P') 
														THEN  0.5 ELSE  P_DAYS END AS PRESENT_DAY,
													CASE WHEN (@DATA = 'A' AND STATUS= 'P') 
															OR (@DATA = 'P' AND STATUS= 'A') 
															OR  (@DATA <> 'P' AND @DATA <> 'A' AND @DATA <> 'W' AND @DATA <> 'HO' AND STATUS='A') 
															OR  (STATUS <> 'P' AND STATUS <> 'A' AND STATUS <> 'W' AND STATUS <> 'HO' AND @DATA='A') 
													THEN  0.5 ELSE A_DAYS END AS ABSENT_DAY,
													CASE WHEN (@DATA = 'P' AND STATUS= 'A') 
															OR (@DATA = 'A' AND STATUS= 'P') 
														THEN  'HF' ELSE STATUS END AS STATUS
													FROM #ATT_MUSTER
													WHERE EMP_ID = @CUR_IMPT_EMP_ID AND FOR_DATE = @TEMP_FROM_DATE
												
											)QRY ON QRY.EMP_ID = AM.EMP_ID and QRY.FOR_DATE = AM.FOR_DATE
										
											WHERE AM.EMP_ID = @CUR_IMPT_EMP_ID AND AM.FOR_DATE = @TEMP_FROM_DATE
											
										END
									
								SET @COUNT = @COUNT + 1
								SET @TEMP_FROM_DATE = DATEADD(D,1,@TEMP_FROM_DATE)
								SET @DATA = ''		
							END
						
				END		
		
				FETCH NEXT FROM CUR_EMP INTO @CUR_IMPT_EMP_ID,@ATT_DETAIL
		END
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP
	
	
	--Moved line from above by Nimesh on 31-Oct-2015
	DECLARE @NotImportedEmp Varchar(max);
	SET @ImportedEmpCons = @ImportedEmpCons + '0';	
	
	SELECT	@NotImportedEmp = COALESCE(@NotImportedEmp + '#', '') + Cast(E.Emp_ID As Varchar(10)) 
	FROM	#Emp_Cons E LEFT OUTER JOIN (SELECT Cast(Data As Numeric) As Emp_ID From dbo.Split(@ImportedEmpCons, '#') ) T
			ON E.Emp_ID=T.Emp_ID 
	WHERE	T.Emp_ID IS NULL
	

	
	if (@NotImportedEmp <> '0' AND @NotImportedEmp <> '')
		BEGIN
		
			SELECT * INTO #TMP_EMP_CONS FROM #Emp_Cons
			TRUNCATE TABLE #Emp_Cons			
			Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@emp_ID,@NotImportedEmp,4,'',1   			
			TRUNCATE TABLE #Emp_Cons
			INSERT INTO #Emp_Cons 
			SELECT * FROM #TMP_EMP_CONS
		END
		
		

if  object_id('tempdb..#Emp_Inout') IS NOT NULL --exists (select 1 from [tempdb].dbo.sysobjects where name like '#Emp_Inout' )        
 begin      
  drop table #Emp_Inout  
 end  
 
if @Report_For IN ('Monthly Generate' , 'For_SAP')
BEGIN
 CREATE TABLE #Emp_Inout       
  (      
   emp_id     numeric ,      
   for_Date    datetime,      
   Dept_id    numeric null ,      
   Grd_ID    numeric null,      
   Type_ID   numeric null,      
   Desig_ID    numeric null,      
   Shift_ID    numeric null ,      
   In_Time    datetime null,      
   Out_Time   datetime null,      
   Duration    varchar(20) null,      
   Duration_sec  numeric  null,      
   Late_In    varchar(20) null,      
   Late_Out    varchar(20) null,      
   Early_In    varchar(20) null,      
   Early_Out    varchar(20) null,      
   Leave     varchar(5) null,      
   Shift_Sec    numeric null,      
   Shift_Dur    varchar(20) null,      
   Total_work    varchar(20) null,      
   Less_Work    varchar(20) null,      
   More_Work    varchar(20) null,      
   Reason     varchar(200) null,    
   Other_Reason varchar(300) null, --Added By Jaina 12-09-2015     
   AB_LEAVE    VARCHAR(20) NULL,      
   Late_In_Sec   numeric null,      
   Late_In_count   numeric null,      
   Early_Out_sec   numeric null,      
   Early_Out_Count  numeric null,      
   Total_Less_work_Sec numeric null,      
   Shift_St_Datetime  datetime null,      
   Shift_en_Datetime  datetime null,      
   Working_Sec_AfterShift numeric null,      
   Working_AfterShift_Count numeric null ,      
   Leave_Reason   varchar(250) null,      
   Inout_Reason   varchar(250) null,  
   SysDate  datetime   ,  
   Total_Work_Sec numeric Null,  
   Late_Out_Sec   numeric null,  
   Early_In_sec   numeric null,
   Total_More_work_Sec numeric null ,  
   Is_OT_Applicable tinyint null,
   Monthly_Deficit_Adjust_OT_Hrs tinyint null,
   Late_Comm_sec  numeric null,
   Branch_Id Numeric default 0,
   P_days	numeric(12,3) default 0, 
   vertical_Id numeric default 0,  --added jimit 15062016
   subvertical_Id numeric default 0,  --added jimit 15062016
   Leave_FromDate	Datetime null, --add by Mukti(13092017)
   Leave_ToDate	Datetime null, --add by Mukti(13092017)
   Break_Start_Time	Datetime null,--added by Mukti 09102017
   Break_End_Time	Datetime null, --added by Mukti 09102017
   Break_Duration	VARCHAR(10) null, --added by Mukti 09102017
   Rest_Duration_Sec NUMERIC DEFAULT 0, --added by Mukti 09042018
   Rest_Duration	VARCHAR(10) DEFAULT '', --added by Mukti 09042018
  )      

--Added By Mukti(22102019)because this parameters exist in SP_RPT_EMP_INOUT_RECORD_GET
ALTER TABLE #Emp_Inout ADD DEPARTMENT_IN_TIME DATETIME NULL 
ALTER TABLE #Emp_Inout ADD DEPARTMENT_OUT_TIME DATETIME NULL
ALTER TABLE #Emp_Inout ADD GATE_IN_DEVICE_IP NVARCHAR(100) NULL 
ALTER TABLE #Emp_Inout ADD GATE_OUT_DEVICE_IP NVARCHAR(100) NULL
ALTER TABLE #Emp_Inout ADD DEPARTMENT_INOUT_DEVICE_IP NVARCHAR(100) NULL
--Added by Mukti(22102019)end

--PRINT 'STATE 6 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	
	exec SP_RPT_EMP_INOUT_RECORD_GET_MEMO @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@constraint,@PBranch_ID='0',@Report_call = 'Monthly Generate'
	
	
	--COMMENTED BY RAJPUT  - DON'T REQUIRED TO CALL WHOLE SP CONDITION OF SP_RPT_EMP_INOUT_RECORD_GET ON 12062019
	--IF @Report_For = 'For_SAP' --Mukti(29092017)
	--	exec SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@constraint,@PBranch_ID='0',@Report_call = 'Monthly Generate'
	--ELSE
	--	exec SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@constraint,@PBranch_ID='0',@Report_call = @Report_For
	
	--PRINT 'STATE 6.1 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
END 

	----Added Condition by Hardik 14/06/2013 for Manual In Out Import
	--If not exists (Select 1 From T0170_EMP_ATTENDANCE_IMPORT Where Emp_ID = @Emp_ID And Month = Month(@To_Date) And Year = Year(@To_Date))
	--	Begin
	
				UPDATE #ATT_MUSTER
				SET STATUS =  CASE WHEN IS_SPLIT_SHIFT = 1 THEN 'S' WHEN IS_TRAINING_SHIFT = 1 THEN 'T'  ELSE 'P' END, P_DAYS = 1
				FROM #ATT_MUSTER AM 
				INNER JOIN #DATA D ON AM.FOR_DATE = D.FOR_DATE AND AM.EMP_ID = D.EMP_ID
				LEFT OUTER JOIN T0040_SHIFT_MASTER S  WITH (NOLOCK) ON D.SHIFT_ID = S.SHIFT_ID
				WHERE --NOT EIR.IN_TIME IS NULL AND NOT EIR.OUT_TIME IS NULL AND--ADDED BY FALAK 01-APR-2011
				AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND D.P_DAYS = 1
				

				-----Added by Sid for Present Days other than 1 and 0.5 -- 20/06/2014 ----
				UPDATE #ATT_MUSTER SET STATUS = QRY.STATUS ,P_DAYS = QRY.P_DAYS
				FROM #ATT_MUSTER AM
				INNER JOIN
				(  
					SELECT AM.EMP_ID,AM.FOR_DATE,D.P_DAYS, CASE 
					WHEN D.P_DAYS IN (0.25, 0.375, 0.38, 0.125, 0.13) THEN 'QD' 
					WHEN (EIR.HALF_FULL_DAY = 'First Half'  AND EIR.CHK_BY_SUPERIOR=1) THEN  'FH'
					WHEN (EIR.HALF_FULL_DAY = 'Second Half' AND EIR.CHK_BY_SUPERIOR=1) THEN  'SH'
					WHEN D.P_DAYS IN (0.75, 0.625, 0.63, 0.875, 0.870, 0.88) THEN '3QD'
					ELSE 'HF' END AS STATUS
					FROM	#ATT_MUSTER AM INNER JOIN #Data D ON AM.For_Date=D.For_date AND AM.Emp_Id=D.Emp_Id
							LEFT OUTER JOIN  DBO.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  ON D.EMP_ID = EIR.EMP_ID AND D.For_date=EIR.For_Date
					where AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND D.P_DAYS IN (0.125, 0.13, 0.25, 0.375, 0.38, 0.5, 0.625, 0.63, 0.75, 0.875, 0.870, 0.88)
				)QRY ON AM.FOR_DATE =QRY.FOR_DATE AND AM.EMP_ID = QRY.EMP_ID

				--PRINT 'ATT 10 :' + CONVERT(VARCHAR(20), GETDATE(), 114)	
				/* COMMENTED BY GADRIWALA MUSLIM 04102016  UPDATED IN ONE SINGLE QUERY NOT REQUIRE MULTIPLE QUERY 
				update #Att_Muster
				set Status =  'HF', P_days = D.P_Days
				from #Att_Muster AM inner join dbo.T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
				AND AM.FOR_DATE = EIR.FOR_DATE Inner Join #Data D on Am.For_Date = D.For_date And Am.Emp_Id = d.Emp_Id
					Left Outer Join T0040_SHIFT_MASTER S on D.Shift_ID = S.Shift_ID
				where --NOT EIR.IN_TIME IS NULL and NOT EIR.OUT_TIME IS NULL and--added by Falak 01-APR-2011
				Am.For_Date >=@From_Date and Am.For_Date <=@To_Date And D.P_days > 0 and d.P_days < 1 
				
				-----Added by Sid Ends -- 20/06/2014 ----
				
				--Added by Hardik on 28/09/2011 for check working hours for Half day
				update #Att_Muster
				set Status = 'HF' , P_days = 0.5
				from #Att_Muster AM inner join dbo.T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
				AND AM.FOR_DATE = EIR.FOR_DATE Inner Join #Data D on Am.For_Date = D.For_date And Am.Emp_Id = d.Emp_Id
				where --NOT EIR.IN_TIME IS NULL and NOT EIR.OUT_TIME IS NULL and
				Am.For_Date >=@From_Date and Am.For_Date <=@To_Date And D.P_days = 0.5 
				
				
					
				--Alpesh 27-Jul-2011
				update #Att_Muster
				set Status = case EIR.Half_Full_day when 'First Half' then 'FH' when 'Second Half' then 'SH' else '' end, P_days = 0.5
				from #Att_Muster AM inner join dbo.T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
				AND AM.FOR_DATE = EIR.FOR_DATE 
				where (EIR.Half_Full_day='First Half' or EIR.Half_Full_day='Second Half') and EIR.Chk_By_Superior=1
				and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date


				--Added by Hardik on 09/01/2016 As per Client requirement QD (Quarter Day)
				update AM
				set Status = 'QD', P_days=D.P_days
				from #Att_Muster AM Inner Join #Data D on Am.For_Date = D.For_date And Am.Emp_Id = d.Emp_Id
				where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date And D.P_days = 0.25
				
				--Added by Hardik on 09/01/2016 As per Client requirement QD (Quarter Day)
				--update AM
				--set Status = '3QD', P_days=D.P_days
				--from #Att_Muster AM Inner Join #Data D on Am.For_Date = D.For_date And Am.Emp_Id = d.Emp_Id
				--where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date And D.P_days = 0.75
				
			*/
				
			--Select Leave_Used,  case Leave_Used when 0.5 then 0.5 else 0 end, --P_days=0,
			--		Leave_Used
			--	from #Att_Muster AM inner join ( select sum(Isnull(LTSUB.Leave_Used,0)) as Leave_Used,LTSUB.For_Date,LTSUB.Emp_ID from dbo.T0140_LEAVE_TRANSACTION LTSUB inner join t0040_leave_master lm on LTSUB.leave_id = lm.leave_id where lm.leave_paid_unpaid = 'P' group by LTSUB.For_Date,LTSUB.Emp_ID )LT ON AM.EMP_ID = LT.EMP_ID
			--	AND AM.FOR_DATE = LT.FOR_DATE 
			--	where LT.Leave_Used  >0
			--	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date	 

				
		  -- Added by rohit on 27082016
		  
			
		  
			update #Att_Muster  
			set Status_2 = 'P'
			from #Att_Muster AM Inner Join #Data D on Am.For_Date = D.For_date And Am.Emp_Id = d.Emp_Id  
			where 
			Am.For_Date >=@From_Date and Am.For_Date <=@To_Date 
			And ( isnull(D.holiday_ot_sec,0) <> 0 or isnull(D.Weekoff_Ot_sec,0) <> 0 )
		  -- Ended by rohit on 27082016
		 
		
		--PRINT 'ATT 11 :' + CONVERT(VARCHAR(20), GETDATE(), 114)	
		UPDATE #ATT_MUSTER
				SET LEAVE_COUNT = LEAVE_USED,  --P_DAYS = CASE LEAVE_USED WHEN 0.5 THEN 0.5 ELSE 0 END, --P_DAYS=0,
					STATUS_2 = LEAVE_USED
				FROM #ATT_MUSTER AM INNER JOIN
				 ( 
					SELECT (
					SUM(ISNULL(
						CASE WHEN LM.APPLY_HOURLY = 0 THEN 
						(
							LTSUB.LEAVE_USED + 
							( 
								CASE WHEN ISNULL(LTSUB.COMPOFF_USED,0) > 0 THEN  
									ISNULL(LTSUB.COMPOFF_USED,0)  - ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0)
								ELSE 
									0 
								END
							)
						) 
						ELSE CASE WHEN 
								(
									LTSUB.LEAVE_USED +
									(
										CASE WHEN ISNULL(LTSUB.COMPOFF_USED,0) > 0 THEN  
											ISNULL(LTSUB.COMPOFF_USED,0)  - ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0)
										ELSE 
											0 
										END
									)
								 ) > 8 THEN 1 
								 ELSE 
								 (
									LTSUB.LEAVE_USED + 
									(
										CASE WHEN ISNULL(LTSUB.COMPOFF_USED,0) > 0 THEN  
											ISNULL(LTSUB.COMPOFF_USED,0)  - ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0)
										ELSE 
											0 
										END
									  )
								  ) * 0.125 
								 END 
							END,0)) )  AS LEAVE_USED,
							LTSUB.FOR_DATE,LTSUB.EMP_ID FROM DBO.T0140_LEAVE_TRANSACTION LTSUB  WITH (NOLOCK) 
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LTSUB.LEAVE_ID = LM.LEAVE_ID 
							WHERE LM.LEAVE_PAID_UNPAID = 'P' GROUP BY LTSUB.FOR_DATE,LTSUB.EMP_ID 
						)LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
					WHERE LT.LEAVE_USED  >0 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE
				
				--PRINT 'ATT 12 :' + CONVERT(VARCHAR(20), GETDATE(), 114)	
				UPDATE #ATT_MUSTER
				SET  STATUS_2 = LEAVE_USED
				FROM #ATT_MUSTER AM INNER JOIN 
				( 
					SELECT (
								SUM(
									ISNULL(LTSUB.LEAVE_USED,0)) + 
									CASE WHEN SUM(ISNULL(LTSUB.COMPOFF_USED,0)) >0 THEN 
										(SUM(ISNULL(LTSUB.COMPOFF_USED,0)) - SUM(ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0)) ) 
									ELSE 
										0 
									END
									) AS LEAVE_USED,LTSUB.FOR_DATE,LTSUB.EMP_ID 
					FROM 	DBO.T0140_LEAVE_TRANSACTION LTSUB WITH (NOLOCK) 
							INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) on LTSUB.LEAVE_ID = LM.LEAVE_ID and LTSUB.Cmp_ID=Lm.Cmp_ID
					WHERE	LM.Apply_Hourly = 0  
					GROUP BY LTSUB.FOR_DATE,LTSUB.EMP_ID 
				)LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
				WHERE LT.LEAVE_USED  > 0 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE
				
				
				update #Att_Muster
				set  Status_2 =  replace(CAST(Leave_Used as varchar(20)),'.00','') + ' Hr.' --+ ')'
				from #Att_Muster AM inner join 
				( select (sum(Isnull(LTSUB.Leave_Used,0)) + Case when sum(isnull(LTSUB.CompOff_Used,0)) >0 then (sum(isnull(LTSUB.CompOff_Used,0)) - sum(isnull(LTSUB.Leave_Encash_Days,0)) ) else 0 end) as Leave_Used,LTSUB.For_Date,LTSUB.Emp_ID 
				from dbo.T0140_LEAVE_TRANSACTION LTSUB WITH (NOLOCK)  inner join t0040_leave_master lm WITH (NOLOCK)  on LTSUB.leave_id = lm.leave_id and LTSUB.Cmp_ID=Lm.Cmp_ID
				 where lm.Apply_Hourly=1 group by LTSUB.For_Date,LTSUB.Emp_ID )LT ON AM.EMP_ID = LT.EMP_ID				
				AND AM.FOR_DATE = LT.FOR_DATE 
				--inner join T0040_LEAVE_MASTER LM on LM.Leave_ID=LT.Le
				where LT.Leave_Used  >0
				and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date --Changed by Sumit on 26112016
				
				

				UPDATE #ATT_MUSTER 
				SET  A_DAYS = LEAVE_USED --(1 - (LEAVE_USED)) + LEAVE_USED --, P_DAYS = (1 - (LEAVE_COUNT + LEAVE_USED))
				FROM #ATT_MUSTER AM INNER JOIN 
				( 
					SELECT (
											SUM(ISNULL(LTSUB.LEAVE_USED,0)) 
										+ ( SUM(ISNULL(LTSUB.COMPOFF_USED,0)) 
										-   SUM(ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0)) 
							)
					) AS LEAVE_USED,LTSUB.FOR_DATE,LTSUB.EMP_ID FROM DBO.T0140_LEAVE_TRANSACTION LTSUB WITH (NOLOCK)  
				INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LTSUB.LEAVE_ID = LM.LEAVE_ID 
				WHERE LM.LEAVE_PAID_UNPAID <> 'P' GROUP BY LTSUB.FOR_DATE,LTSUB.EMP_ID )LT ON AM.EMP_ID = LT.EMP_ID
				AND AM.FOR_DATE = LT.FOR_DATE WHERE LT.LEAVE_USED  > 0
				AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND P_DAYS < 1

				
			
				
				UPDATE #ATT_MUSTER 
				SET  A_DAYS = 0.5 - P_days
				FROM #ATT_MUSTER AM INNER JOIN 
				( 
					SELECT (
										SUM(ISNULL(LTSUB.LEAVE_USED,0))
									 + (SUM(ISNULL(LTSUB.COMPOFF_USED,0)) 
									 - SUM(ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0))
						    )
				 ) AS LEAVE_USED,LTSUB.FOR_DATE,LTSUB.EMP_ID 
					 FROM DBO.T0140_LEAVE_TRANSACTION LTSUB WITH (NOLOCK)  INNER JOIN 
					 T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LTSUB.LEAVE_ID = LM.LEAVE_ID 
					 GROUP BY LTSUB.FOR_DATE,LTSUB.EMP_ID 
				)LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
				WHERE LT.LEAVE_USED  = 0.5 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE --AND P_DAYS = 0

				
 
	
				--Added by Hardik 20/06/2013 for if Employee on Half day LWP and half day Absent so Full day will consider as Absent
				UPDATE #ATT_MUSTER 
				SET  A_DAYS = 1 
				FROM #ATT_MUSTER AM INNER JOIN 
				( 
					SELECT (	   SUM(ISNULL(LTSUB.LEAVE_USED,0)) 
								+ (SUM(ISNULL(LTSUB.COMPOFF_USED,0)) 
								- SUM(ISNULL(LTSUB.LEAVE_ENCASH_DAYS,0)))
							) AS LEAVE_USED,LTSUB.FOR_DATE,LTSUB.EMP_ID FROM DBO.T0140_LEAVE_TRANSACTION LTSUB  WITH (NOLOCK) 
					INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) ON LTSUB.LEAVE_ID = LM.LEAVE_ID 
					WHERE LM.LEAVE_PAID_UNPAID <> 'P' GROUP BY LTSUB.FOR_DATE,LTSUB.EMP_ID 
				)LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
				WHERE LT.LEAVE_USED  = 0.5 AND AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND P_DAYS = 0 AND ISNULL(LEAVE_COUNT,0) = 0
					
					
				--PRINT 'ATT 13 :' + CONVERT(VARCHAR(20), GETDATE(), 114)	
				-- commented and change by rohit on 26092014
				---Added by Sid for Part Day Leave 18/06/2014 ----------
				--update #Att_Muster 
				--set  A_days = 1-(leave_Used ) 
				--from #Att_Muster AM inner join 
				--( select sum(Isnull(LTSUB.Leave_Used,0)) as Leave_Used,LTSUB.For_Date,LTSUB.Emp_ID 
				--from dbo.T0140_LEAVE_TRANSACTION LTSUB inner join t0040_leave_master lm on LTSUB.leave_id = lm.leave_id 
				--where lm.Apply_Hourly = 0 group by LTSUB.For_Date,LTSUB.Emp_ID )LT ON AM.EMP_ID = LT.EMP_ID
				--AND AM.FOR_DATE = LT.FOR_DATE 
				--where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date and P_days = 0 and Isnull(Leave_Count,0) > 0

				--update #Att_Muster 
				--set  P_days = 1-(leave_Used) 
				--from #Att_Muster AM inner join ( select sum(Isnull(LTSUB.Leave_Used,0)) as Leave_Used,LTSUB.For_Date,LTSUB.Emp_ID from dbo.T0140_LEAVE_TRANSACTION LTSUB inner join t0040_leave_master lm on LTSUB.leave_id = lm.leave_id where lm.Apply_Hourly = 0 group by LTSUB.For_Date,LTSUB.Emp_ID )LT ON AM.EMP_ID = LT.EMP_ID
				--AND AM.FOR_DATE = LT.FOR_DATE 
				--where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date and P_days > 0 and Isnull(Leave_Count,0) > 0

				
			
				UPDATE 	AM 
				--SET  P_DAYS = (1 - A_days) - leave_count 
				SET  	A_DAYS = 1 - (D.P_days + leave_count )
				FROM 	#ATT_MUSTER AM 
						INNER JOIN #DATA D ON AM.EMP_ID=D.EMP_ID AND AM.For_Date=D.FOR_DATE
				--INNER JOIN ( SELECT SUM(ISNULL(LTSUB.LEAVE_USED,0)) AS LEAVE_USED,LTSUB.FOR_DATE,LTSUB.EMP_ID 
				--FROM DBO.T0140_LEAVE_TRANSACTION LTSUB INNER JOIN T0040_LEAVE_MASTER LM ON LTSUB.LEAVE_ID = LM.LEAVE_ID 
				--WHERE LM.APPLY_HOURLY = 1 GROUP BY LTSUB.FOR_DATE,LTSUB.EMP_ID )LT ON AM.EMP_ID = LT.EMP_ID
				--AND AM.FOR_DATE = LT.FOR_DATE 
				WHERE AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND D.P_DAYS > 0 AND ISNULL(LEAVE_COUNT,0) > 0
				
					
				--update #Att_Muster 
				--set  A_days = 1 - isnull(leave_count,0) - isnull(P_days,0) - isnull(WO_HO_Day ,0)
				--from #Att_Muster AM 
				----inner join ( select sum(Isnull(LTSUB.Leave_Used,0)) as Leave_Used,LTSUB.For_Date,LTSUB.Emp_ID from dbo.T0140_LEAVE_TRANSACTION LTSUB inner join t0040_leave_master lm on LTSUB.leave_id = lm.leave_id where lm.Apply_Hourly = 1 group by LTSUB.For_Date,LTSUB.Emp_ID )LT ON AM.EMP_ID = LT.EMP_ID
				----AND AM.FOR_DATE = LT.FOR_DATE 
				--where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date and P_days = 0 and Isnull(Leave_Count,0) > 0
				
				
				---Added by Sid Ends-------------------------------------

			/*	Update #Att_Muster 
				set WO_HO = 'W',
					WO_HO_Day =1
				From #Att_Muster   AM inner join 
				( select ESD.* from T0100_WEEKOFF_ADJ ESD inner join 
					( select max(For_Date)as For_Date ,Emp_ID from T0100_WEEKOFF_ADJ 
					where For_Date <= @For_Date and Cmp_Id = @Cmp_ID
					group by emp_ID )Q on ESD.emp_ID =Q.Emp_ID and ESD.For_DAte = Q.For_Date)Q_W 
					on AM.Emp_ID = Q_W.Emp_Id
				where charindex(datename(dw,AM.For_Date),Q_W.weekoff_day,0) >0
				and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
			*/	
				
				Update #Att_Muster 
				set WO_HO = 'W',
					WO_HO_Day =ew.W_Day
				From #Att_Muster   AM inner join #Emp_Weekoff ew on am.emp_ID = ew.emp_ID and am.For_date =ew.For_Date
				and W_Day > 0

				
								
				Update #Att_Muster 
				set WO_HO = 'HO',
					WO_HO_Day =eh.H_Day
				From #Att_Muster   AM inner join #Emp_Holiday eh on am.emp_ID = eh.emp_ID and am.For_date =Eh.For_Date
				
				

				--Update #Att_Muster 
				--set WO_HO = 'OPH',
				--	WO_HO_Day =eh.H_Day
				--From #Att_Muster   AM inner join #Emp_Holiday
				--eh on am.emp_ID = eh.emp_ID and am.For_date =Eh.For_Date
				--Inner join 
				--#Emp_WeekOff_Holiday EH1 on EH.FOR_DATE=EH1.for
				 
				
				UPDATE #ATT_MUSTER
				SET STATUS = 'HHO' 
				FROM #ATT_MUSTER AM INNER JOIN DBO.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  ON AM.EMP_ID = EIR.EMP_ID
				AND AM.FOR_DATE = EIR.FOR_DATE INNER JOIN #DATA D ON AM.FOR_DATE = D.FOR_DATE AND AM.EMP_ID = D.EMP_ID
				WHERE --NOT EIR.IN_TIME IS NULL AND NOT EIR.OUT_TIME IS NULL AND
				AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND (D.P_DAYS = 0.5)  AND (AM.WO_HO = 'HO' or  AM.WO_HO ='OHO')

				--Code added by Sumit on 9/11/2016------------------------------------------------------------
				Update #Att_Muster 
				set WO_HO = 'OHO',
					WO_HO_Day =eh.H_Day
				From #Att_Muster   AM inner join #Emp_Holiday eh on am.emp_ID = eh.emp_ID 
				and am.For_date =Eh.For_Date				
				inner join #EMP_WEEKOFF_HOLIDAY EWH on EWH.Emp_ID=EH.EMP_ID				
				where charindex(convert(varchar(11),AM.FOR_DATE,109),EWH.OptHolidayDate,0) > 0 
				and am.Emp_Id=ewh.Emp_ID --Added by Sumit on 9/11/2016 for Optional Holiday
				
				----------------------------------------------------------------------------------------------
				--For Full Day WeekOff/Holiday Full Day Work
				
				Update #Att_Muster
				set Status_2 ='CO-' + WO_HO, P_days =1
				Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' or WO_HO = 'OHO')and WO_HO_Day =1
				and For_Date >=@From_Date and For_Date <=@To_Date
												
				--For Half Day WeekOff/Holiday Half Day Work
				Update #Att_Muster
				set Status_2 = 'CO-' + WO_HO , P_days =0.5
				Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' or WO_HO = 'OHO' )and WO_HO_Day =0.5
				and For_Date >=@From_Date and For_Date <=@To_Date

				--For Full Day WeekOff/Holiday Half Day Work
				Update #Att_Muster
				set Status_2 = 'CO-' + WO_HO , P_days =0.5
				Where Status = 'HF' and 	( WO_HO = 'W' or WO_HO = 'HO' or WO_HO = 'OHO' )and WO_HO_Day =1
				and For_Date >=@From_Date and For_Date <=@To_Date
				
				
				--PRINT 'ATT 14 :' + CONVERT(VARCHAR(20), GETDATE(), 114)		

				UPDATE #ATT_MUSTER
				SET STATUS =WO_HO
				WHERE (
						ISNULL(STATUS,'') <> 'P' 
					AND ISNULL(STATUS,'') <> 'FH' 
					AND ISNULL(STATUS,'') <> 'SH' 
					AND ISNULL(STATUS,'') <> 'HF' 
					AND ISNULL(STATUS,'') <> 'HHO'
				) AND ( WO_HO = 'HO' or WO_HO = 'W' or WO_HO = 'OHO') 
				AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE
				
				
				
				Update #Att_Muster
				set Status ='A'
				Where Status is null
				and For_Date >=@From_Date and For_Date <=@To_Date
		
				
				-- Need to check Here Deepal :- 30-04-2023
				Update #Att_Muster
				set A_days = 0.5 
				Where Status = 'HF' and isnull(Leave_Count,0) = 0 
				and For_Date >=@From_Date and For_Date <=@To_Date and p_days=0.5
				-- Need to check Here Deepal :- 30-04-2023

				
				
				UPDATE	#Att_Muster
				SET		[Status] = (CASE WHEN [Status] IN ('QD','3QD') THEN [Status] + '/' ELSE '' END)  + SUBSTRING(LT.Leave_code,2,LEN(LT.Leave_code)) + CASE WHEN Leave_Used <> 1 AND WO_HO_Day > 0 THEN '/' + WO_HO ELSE '' END ,
						WO_HO_Day = CASE WHEN Leave_Used = 1 THEN 0 ELSE WO_HO_Day END,
						WO_HO = CASE WHEN Leave_Used = 1 THEN NULL ELSE WO_HO END
				FROM	#Att_Muster AM 
						INNER JOIN (
									SELECT  LT1.Cmp_ID,  LT1.Emp_ID, LT1.For_Date, LT1.Leave_ID, (case when (Ea.Default_Short_Name='COMP' or Ea.Default_Short_Name='COPH' or Ea.Default_Short_Name='COND') then isnull(LT1.compOff_Used,0) - isnull(lt1.Leave_Encash_Days,0) else isnull(lt1.leave_used,0) end) as Leave_Used ,Leave_Encash_Days,  --Changed by Gadriwala Muslim 02102014
											(	
												SELECT	'/' + lmin.Leave_Code 
												FROM	dbo.T0040_LEAVE_MASTER AS lmin WITH (NOLOCK)  
												WHERE	EXISTS (
																	SELECT	TOP 1 1
																	FROM	dbo.T0140_LEAVE_TRANSACTION AS LT2 WITH (NOLOCK)  
																	WHERE	lt2.For_Date = LT1.For_Date and lt2.Emp_ID = LT1.Emp_ID 
																			AND (LT2.Leave_Used > 0 or (LT2.compOff_Used - LT2.Leave_Encash_Days) > 0)
																			AND LT2.Leave_ID=lmin.Leave_ID
																 )  
														FOR XML PATH ('')
											) AS LEAVE_CODE  --Changed by Gadriwala Muslim 02102014
									FROM	dbo.T0140_LEAVE_TRANSACTION AS LT1  WITH (NOLOCK) 
											LEFT OUTER JOIN  dbo.T0040_LEAVE_MASTER AS EA WITH (NOLOCK)  ON LT1.Leave_ID = EA.Leave_ID WHERE LT1.Cmp_ID=@Cmp_ID 
									) LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
				WHERE	LT.Leave_Used  >0  --and Status='A'
						--(CASE	WHEN Leave_Used > 0 AND Leave_Used = Leave_Encash_Days THEN 0 --- Commented by Hardik 03/02/2018, Commented Case When for Aculife, As taken Leave on 1st date and also encash 1 day then Leave is not showing in Atten. register
						--				WHEN lt.Leave_Used <> 0 THEN 1
						--				ELSE 0
						--		 END) =1					
					
						AND Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
				
				
				--PRINT 'ATT 15 :' + CONVERT(VARCHAR(20), GETDATE(), 114)		
				/*************************************************************
				Replaced following loop with these code to update the status 
				for Holiday and Weekoff using single query statement
				*************************************************************/
				UPDATE	#Att_Muster 
				SET		Status_2 = ISNULL(Status_2,'')  + '-HO' 
				FROM	#Att_Muster A INNER JOIN
						(	SELECT	EMP_ID, FOR_DATE
							FROM	#EMP_HOLIDAY H
							WHERE	H.IS_CANCEL=0 AND H.H_DAY <> 0
						) H ON A.Emp_Id=H.EMP_ID AND A.For_Date=H.FOR_DATE
				WHERE	ISNULL(Leave_Count,0) > 0 
						
				UPDATE	#Att_Muster 
				SET		Status_2 = ISNULL(Status_2,'') + '-W' 
				FROM	#Att_Muster A INNER JOIN
						(	SELECT	EMP_ID, FOR_DATE
							FROM	#Emp_WeekOff W
							WHERE	W.Is_Cancel=0 AND W.W_Day <> 0
						) W ON A.Emp_Id=W.Emp_ID AND A.For_Date=W.For_Date
				WHERE	ISNULL(Leave_Count,0) > 0 
				
				
				/*************************************************************************
				Commented by Nimesh : Now we already have a table for Holiday/Weekoff data 
				for all employee #EMP_HOLIDAY and #Emp_WeekOff
				**************************************************************************
				
				-- Added by Gadriwala Muslim 03042015 - Start
				
				Declare @Cur_OD_Emp_ID numeric(18,0)
				Declare @Cur_OD_For_Date as datetime
				Declare @Slab_Type as varchar(4)
				IF OBJECT_ID('tempdb..#WeekOff_Holiday') IS NOT NULL
				DROP TABLE #WeekOff_Holiday
				
				Create Table #WeekOff_Holiday
				(
					
					Weekoff_days            tinyint,
					Holidays                tinyint,
					Weekoff_Dates           nvarchar(max),
					Holiday_Dates           nvarchar(max)
				)
				
				
						
				--WHERE	Emp_Id = @Cur_OD_Emp_ID and For_date = @Cur_OD_For_Date
				
				Declare CurOD cursor for select Emp_ID,For_date from  #Att_Muster where isnull(Leave_Count,0) > 0 
				
				Open CurOD
					Fetch next from CurOD into @Cur_OD_Emp_ID,@Cur_OD_For_Date
					while @@FETCH_STATUS = 0 
						begin
						
						
								
								delete from  #WeekOff_Holiday
								
								exec Sp_Get_Holiday_Weekoff @cmp_ID,@Cur_OD_For_Date,@Cur_OD_For_Date,@Cur_OD_Emp_ID
						
						
						if exists(select 1 from #WeekOff_Holiday where Holidays = 1)
							set @Slab_Type = 'HO'		
						else if exists(select 1 from #WeekOff_Holiday where Weekoff_days = 1)	
							set @Slab_Type = 'W'
						else
							set @Slab_Type = 'WD'
							
							If @Slab_Type = 'HO' or @Slab_Type = 'W'
								begin
										update #Att_Muster set Status_2 = isnull(Status_2,'') + '-' +  @Slab_Type 
										where emp_ID = @Cur_OD_Emp_ID and For_date = @Cur_OD_For_Date
							     end
							
							Fetch next from CurOD into @Cur_OD_Emp_ID,@Cur_OD_For_Date
						end
				close CurOD
				deallocate CurOD			
				-- Added by Gadriwala Muslim 03042015 - End
				
				
				*/
				
				--Alpesh 06-Jul-2012 -> If leave is unpaid n someone is present
				--update #Att_Muster
				--set Leave_Count = 0
				--	,Status='P'
				--	,Status_2=''
				--from #Att_Muster AM inner join (SELECT  LT1.Cmp_ID,  LT1.Emp_ID, LT1.For_Date, LT1.Leave_ID, (LT1.Leave_Used + isnull(LT1.CompOff_Used,0)) as Leave_Used, lm.Leave_Paid_Unpaid from T0140_LEAVE_TRANSACTION LT1
				--inner join T0040_LEAVE_MASTER lm on lm.Leave_ID=LT1.Leave_ID)LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
				--where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date and P_days=1 and LT.Leave_Paid_Unpaid='U'
				---- End ----	
		
				--- Added by Hardik 03/01/2015 for Wonder
				UPDATE #ATT_MUSTER
				SET P_DAYS=0, A_DAYS=1
				FROM #ATT_MUSTER AM INNER JOIN 
				(
					SELECT  LT1.CMP_ID,  LT1.EMP_ID, LT1.FOR_DATE, LT1.LEAVE_ID, (LT1.LEAVE_USED + ISNULL(LT1.COMPOFF_USED,0)) AS LEAVE_USED, 
					LM.LEAVE_PAID_UNPAID FROM T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) 
					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LM.LEAVE_ID=LT1.LEAVE_ID 
				WHERE LM.CMP_ID=@CMP_ID
				)LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
				WHERE AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE 
				AND P_DAYS=1 AND LT.LEAVE_PAID_UNPAID='U' AND LEAVE_USED>0
				
				
				
				UPDATE #ATT_MUSTER 
				SET  A_DAYS = 1 - ISNULL(AM.LEAVE_COUNT,0) - ISNULL(AM.P_DAYS,0) - ISNULL(AM.WO_HO_DAY ,0)
				FROM #ATT_MUSTER AM 
				WHERE AM.FOR_DATE >=@FROM_DATE AND AM.FOR_DATE <=@TO_DATE AND P_DAYS >= 0 
				AND P_DAYS < 1 AND ISNULL(LEAVE_COUNT,0) >= 0
				
				update #Att_Muster 
				set  A_days = 0
				from #Att_Muster AM 
				where Am.For_Date >=@From_Date and Am.For_Date <=@To_Date and A_days < 0 
				
				--Added by Gadriwala Muslim 06042015 - Start
					   
						update #Att_Muster
						set  GatePass_Days = isnull(GatePass_Deduct_Days,0)
						from #Att_Muster AM inner join dbo.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  ON AM.EMP_ID = EIR.EMP_ID
						AND AM.FOR_DATE = EIR.FOR_DATE Inner Join #Data D on Am.For_Date = D.For_date And Am.Emp_Id = d.Emp_Id
						where 
						Am.For_Date >=@From_Date and Am.For_Date <=@To_Date And isnull(D.GatePass_Deduct_Days,0) >0  
						
						
						Update #Att_Muster 
						set Status = Q.gate_Pass
						from #Att_Muster AM 
						inner join       
							(select Emp_Id ,sum(Isnull(GatePass_Days,0)) as gate_Pass From #Att_Muster 
								Where  For_Date>=@From_Date and For_DAte <=@to_Date 
								group by Emp_ID
							)Q on Am.Emp_ID = Q.Emp_ID
						where AM.Row_ID = 38
				--Added by Gadriwala Muslim 06042015 - End

		--End
		
---Hardik 08/07/2013 for Mid Joining.. it will show - (Dash) in Register
				update #Att_Muster
				set Leave_Count = Null
					,Status='-'
					,Status_2=''
					,WO_HO=''
					,WO_HO_Day=0
					,A_Days = 0 ---------------- Add by jignesh 04-08-2014
					,P_Days = 0
				from #Att_Muster AM 
				Where Am.For_Date < Join_Date and For_Date>=@From_Date and For_DAte <=@to_Date
	
				---Hardik 08/07/2013 for Mid Left.. it will show - (Dash) in Register
				update #Att_Muster
				set Leave_Count = Null
					,Status='-'
					,Status_2=''
					,WO_HO=''
					,WO_HO_Day=0
					,A_Days = 0 ---------------- Add by jignesh 04-08-2014
					,P_Days = 0
				from #Att_Muster AM 
				Where Am.For_Date > Left_Date and For_Date>=@From_Date and For_DAte <=@to_Date
	
				---Hardik 08/07/2013 for Mid Left.. it will show - (Dash) in Register
				update #Att_Muster
				set Leave_Count = Null
					,Status='-'
					,Status_2=''
					,WO_HO=''
					,WO_HO_Day=0
					,A_Days = 0 ---------------- Add by jignesh 04-08-2014
					,P_Days = 0
				from #Att_Muster AM 
				Where Am.For_Date > GetDate() And Isnull(Leave_Count,0) = 0 And For_Date>=@From_Date and For_DAte <=@to_Date
		
				--PRINT 'ATT 16 :' + CONVERT(VARCHAR(20), GETDATE(), 114)		

				UPDATE #ATT_MUSTER
				SET STATUS = 'A'  , P_days = 0
				FROM #ATT_MUSTER AM 
				INNER JOIN DBO.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  
				ON AM.EMP_ID = EIR.EMP_ID AND AM.FOR_DATE = EIR.FOR_DATE 
				WHERE EIR.Chk_By_Superior = 2 and Sup_Comment = 'From Reject All'

				UPDATE #ATT_MUSTER
				SET STATUS = 'P'  , P_days = 1,A_days = 0
				FROM #ATT_MUSTER AM 
				INNER JOIN DBO.T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  
				ON AM.EMP_ID = EIR.EMP_ID AND AM.FOR_DATE = EIR.FOR_DATE 
				WHERE EIR.Chk_By_Superior = 1 --and Sup_Comment = 'Approved'

				--Added By Jimit 01042019
					IF @REPORT_FOR = 'Complete_Absent' And @Export_Type Not In (999,5)
						BEGIN	
						
							  DELETE	ATM 
							  FROM		#Att_Muster ATM LEFT OUTER JOIN
										T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  ON EIR.EMP_ID = ATM.EMP_ID and EIR.FOR_DATE = ATM.FOR_DATE
							  WHERE		EXISTS(
													SELECT	1 
													FROM	T0150_EMP_INOUT_RECORD EIR1  WITH (NOLOCK) 
													WHERE	EIR1.EMP_ID = EIR.EMP_ID AND EIR1.FOR_DATE = ATM.FOR_DATE
												   )					
						END
				--Ended

				
	-- Added by rohit on 28012015 for Inductothrm for Showing regularship in attendance register.
	CREATE TABLE #regularship
	(
	emp_id  numeric(18,0),
	flag  tinyint
	)
	
	----PRINT 'STATE 7 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	
	declare @Rg_Flag as numeric
	set @Rg_Flag = 0
	
	select @Rg_Flag = isnull(setting_value,0) from T0040_SETTING WITH (NOLOCK)  where Setting_Name ='Show RG in Attendance register' and Cmp_ID=@Cmp_ID
	
	IF ISNULL(@RG_FLAG,0) = 1
		BEGIN
	
			DECLARE @CURCMP_ID NUMERIC
		
		
		
			DECLARE @IS_ELIGIBLE AS TINYINT
		    DECLARE @CALCULATE_DATE AS DATETIME 
			DECLARE @EARNING_GROSS AS NUMERIC
			DECLARE @SALARY_CAL_DAY AS NUMERIC
			DECLARE @OUT_OF_DAYS AS NUMERIC 
			DECLARE @ABSENT_DAYS AS NUMERIC 
			DECLARE @SALARY_AMOUNT AS NUMERIC 
			DECLARE @AD_ID AS NUMERIC 
			
			DECLARE CUSRCOMPANYMST CURSOR fast_forward FOR	                  
			SELECT DISTINCT EMP_ID FROM #ATT_MUSTER
			OPEN CUSRCOMPANYMST
			FETCH NEXT FROM CUSRCOMPANYMST INTO @CURCMP_ID
			WHILE @@FETCH_STATUS = 0                    
				BEGIN     
							
					
					SET  @CALCULATE_DATE  = @FROM_DATE
					SET @EARNING_GROSS = 0
					SET @ABSENT_DAYS = 0
					SET @SALARY_AMOUNT = 0
					SET @AD_ID = 46
					SET @OUT_OF_DAYS = DATEDIFF(DD,@FROM_DATE,@TO_DATE+1)
					SET @SALARY_CAL_DAY = @OUT_OF_DAYS
					SET @IS_ELIGIBLE = 1
					
					EXEC CHECK_ELIGIBLE_FORMULA_WISE @CMP_ID,@CURCMP_ID,@AD_ID,@CALCULATE_DATE,@EARNING_GROSS,@SALARY_CAL_DAY,@OUT_OF_DAYS,@IS_ELIGIBLE OUTPUT,@ABSENT_DAYS,@SALARY_AMOUNT
					
					INSERT INTO #REGULARSHIP 
					VALUES (@CURCMP_ID,@IS_ELIGIBLE)
					
					FETCH NEXT FROM CUSRCOMPANYMST INTO @CURCMP_ID	
				END
				CLOSE CUSRCOMPANYMST                    
				DEALLOCATE CUSRCOMPANYMST

		end		
	--PRINT 'ATT 17 :' + CONVERT(VARCHAR(20), GETDATE(), 114)					
	-- Ended by rohit on 28012015
	----PRINT 'STATE 7.1 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	declare @LeaveCode as varchar(max);
	set @LeaveCode=Null;
	
	select		@LeaveCode	=	COALESCE(@LeaveCode + ',','') + Leave_Code Collate SQL_Latin1_General_CP1_CI_AS 
	From		T0040_Leave_Master  WITH (NOLOCK) 
	where Cmp_Id = @Cmp_Id And (Leave_Type = 'Company Purpose' or Default_Short_Name='COMP')
	--Added by Sumit on 29112016------------------------------------------

	
	
	If @OD_Compoff_As_Present = 1
		Begin
			UPDATE #ATT_MUSTER
			SET STATUS =cast(Round(Q.P_DAYS + Isnull(Q1.OD_Compoff,0),2) as numeric(18,2)) --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)
			-- --Changed by Sumit on 03022017 --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)
			FROM #ATT_MUSTER AM INNER JOIN 
			(SELECT EMP_ID ,SUM(ISNULL(P_DAYS,0))P_DAYS FROM #ATT_MUSTER 
				--Where (Status = 'P' or Status = 'FH' or Status = 'SH' or Status = 'HF') and For_Date>=@From_Date and For_DAte <=@to_Date And (status_2 <>'CO' or status_2 is null) and (isnull(WO_HO,'') <> 'W' and isnull(WO_HO,'') <> 'HO') ---When employee Work on holiday or weekoff it should not count in present day
				WHERE FOR_DATE>=@FROM_DATE AND FOR_DATE <=@TO_DATE AND (STATUS_2 <>'CO' OR STATUS_2 IS NULL) --AND (ISNULL(WO_HO,'') <> 'W' /*AND ISNULL(WO_HO,'') <> 'HO'*/) ---WHEN EMPLOYEE WORK ON HOLIDAY OR WEEKOFF IT SHOULD NOT COUNT IN PRESENT DAY
				--and (isnull(WO_HO,'') <> 'W' /*and isnull(WO_HO,'') <> 'HO'*/) Comment by nilesh patel on 26022016 due to Holiday is Consider As Present day when work on holiday
				--AND WO_HO IS NULL  --Addded by nilesh patel on 26022016 due to Holiday is not Consider As Present day when work on holiday
				AND ( WO_HO IS NULL OR status = 'HHO' ) --Or Condition For Half Holiday Calcualte in Present Day - Ankit 22082016
				GROUP BY EMP_ID)Q ON AM.EMP_ID = Q.EMP_ID	--NIKUNJ 27-04-2011							
			LEFT OUTER JOIN 
				(select	sum(((IsNull(LT.CompOff_Used,0) - IsNull(LT.Leave_Encash_Days,0)) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID
				from	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
						INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LT.Leave_ID=LM.Leave_ID						
				where	(Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID
						AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
				group by Emp_ID
				)Q1 on Am.Emp_ID = Q1.Emp_ID --Changed by Sumit on 30112016
			where Row_ID = 32
			
			
			
		End
	Else
		Begin	
			update #Att_Muster
			set Status = cast(round(q.P_Days ,2) as numeric(18,2))--q.P_Days 
			from #Att_Muster AM inner join 
			(select Emp_Id ,sum(Isnull(P_Days,0))P_Days From #Att_Muster 
				--Where (Status = 'P' or Status = 'FH' or Status = 'SH' or Status = 'HF') and For_Date>=@From_Date and For_DAte <=@to_Date And (status_2 <>'CO' or status_2 is null) and (isnull(WO_HO,'') <> 'W' and isnull(WO_HO,'') <> 'HO') ---When employee Work on holiday or weekoff it should not count in present day
				Where For_Date>=@From_Date and For_DAte <=@to_Date And (status_2 <>'CO' or status_2 is null) --and (isnull(WO_HO,'') <> 'W' /*and isnull(WO_HO,'') <> 'HO'*/) ---When employee Work on holiday or weekoff it should not count in present day
				--and (isnull(WO_HO,'') <> 'W' /*and isnull(WO_HO,'') <> 'HO'*/) Comment by nilesh patel on 26022016 due to Holiday is Consider As Present day when work on holiday
				--AND WO_HO IS NULL  --Addded by nilesh patel on 26022016 due to Holiday is not Consider As Present day when work on holiday
				AND ( WO_HO IS NULL OR status = 'HHO' ) --Or Condition For Half Holiday Calcualte in Present Day - Ankit 22082016
				group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID	--Nikunj 27-04-2011							
			where Row_ID = 32	
			
			
					
		End
		
--PRINT 'ATT 18 :' + CONVERT(VARCHAR(20), GETDATE(), 114)					

----PRINT 'STATE 7.2 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	--Left Outer Join 
	--(select Emp_Id ,sum(Isnull(Leave_Count,0))Half_Leave From #Att_Muster 
	--	Where Leave_Count = 0.5 and For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID																	--Nikunj 27-04-2011							
	--where Row_ID = 32
							
	--update #Att_Muster
	--set Status = q.P_Days --+ Isnull(Half_Leave,0)
	--from #Att_Muster AM inner join 
	--(select Emp_Id ,sum(Isnull(P_Days,0))P_Days From #Att_Muster 
	--	--Where (Status = 'P' or Status = 'FH' or Status = 'SH' or Status = 'HF') and For_Date>=@From_Date and For_DAte <=@to_Date And (status_2 <>'CO' or status_2 is null) and (isnull(WO_HO,'') <> 'W' and isnull(WO_HO,'') <> 'HO') ---When employee Work on holiday or weekoff it should not count in present day
	--	Where For_Date>=@From_Date and For_DAte <=@to_Date And (status_2 <>'CO' or status_2 is null) and (isnull(WO_HO,'') <> 'W' and isnull(WO_HO,'') <> 'HO') ---When employee Work on holiday or weekoff it should not count in present day
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID	--Nikunj 27-04-2011							
	--Left Outer Join 
	--(select Emp_Id ,sum(Isnull(Leave_Count,0))Half_Leave From #Att_Muster 
	--	Where Leave_Count = 0.5 and For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID																	--Nikunj 27-04-2011							
	--where Row_ID = 32	
	
	Update #Att_Muster
	SET A_days = 1
	Where [Status] ='A' and (For_Date BETWEEN @From_Date and @To_Date)
	--Where Status ='A' and For_Date >=@From_Date and For_Date <=@To_Date
	
	-- Added by Gadriwala Muslim 26082014 for Half Day Holiday Absent
	Update #Att_Muster
	SET A_days = 0.5 ,Status = 'HHO' 
	Where ([Status] ='HO' or [Status] ='OHO')  and (P_days = 0.00 and WO_HO_Day = 0.5) and (For_Date between @From_Date and @To_Date)
	
				
		--------------------------------	
	--update #Att_Muster
	--set Status = AB_Days + Isnull(Half_Cnt,0)
	--from #Att_Muster AM inner join 
	--(select Emp_Id ,count(Status)as AB_Days 
	--	From #Att_Muster --Alpesh 27-Jul-2011
	--	Where (Status = 'A')  and For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--Left Outer Join 
	--	(select Emp_Id ,isnull(sum(P_days),0) As Half_Cnt
	--	From #Att_Muster 
	--	Where (Status = 'FH' or Status = 'SH')and For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID
	--where Row_ID = 33
	
	----PRINT 'STATE 7.3 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	
	--- ####---- 

	--Added By Nilesh Patel on 04-01-2018 -- Set 3 Decimal instead of two decimal for Part Leave Calculation of Cliantha -- 0.375 is round of 0.38 -- Total day 31.01
	UPDATE	#Att_Muster
	SET		Status = CAST(round(AB_Days,3) as numeric(18,3))--AB_Days --+ Isnull(Half_Cnt,0) -- Comment by nilesh on 16102015 after discussion with Hardik bhai  
	FROM	#Att_Muster AM 
			INNER JOIN (SELECT	Emp_Id,SUM(IsNull(A_days,0))as AB_Days 
						From	#Att_Muster 
						Where	For_Date>=@From_Date and For_DAte <=@to_Date and (isnull(WO_HO,'') <> 'W' /*and isnull(WO_HO,'') <> 'HO'*/ )
						GROUP BY Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
			LEFT OUTER JOIN (SELECT	Emp_Id,SUM((1-(isnull(P_days,0) + isnull(leave_count,0)))) As Half_Cnt
							 FROM	#Att_Muster 
							 WHERE	(Status = 'FH' or Status = 'SH') and For_Date>=@From_Date and For_DAte <=@to_Date and (isnull(WO_HO,'') <> 'W' /*and isnull(WO_HO,'') <> 'HO'*/ )
							 GROUP BY Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID
	WHERE	Row_ID = 33
	
	--Hardik 21/07/2014
	If @OD_Compoff_As_Present = 1 
		Begin
			--update #Att_Muster
			--set Status = CAST(round(Leave - Isnull(OD_Compoff,0),2 )as numeric(18,2))--Changed by Sumit on 03022017--Leave - Isnull(OD_Compoff,0)
			--from #Att_Muster AM inner join       --Commented by Alpesh 27-Jul-2011 bcoz all leave has diff status 
			--(select Emp_Id ,sum(Isnull(Leave_Count,0)) as Leave From #Att_Muster --(select Emp_Id ,count(Leave_Count) as Leave From #Att_Muster --added by Falak 01-APR-2011
			--	Where  For_Date>=@From_Date and For_DAte <=@to_Date --Status = 'L' and // 
			--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
			--Left Outer Join 
			--	(select Emp_Id ,sum(Isnull(Leave_Count,0))OD_Compoff From #Att_Muster 
			--		Where For_Date>=@From_Date and For_DAte <=@to_Date And
			--		(	
			--			CHARINDEX(RIGHT(Status,LEN(Status)-CHARINDEX('/',Status)),ISNULL(@LEAVECODE,'')) > 0
			--			or CHARINDEX(left(Status,LEN(Status)-CHARINDEX('/',Status)),ISNULL(@LEAVECODE,'')) > 0
			--		)
			--		--Status in (Select Leave_Code Collate SQL_Latin1_General_CP1_CI_AS From T0040_Leave_Master where Cmp_Id = @Cmp_Id And Leave_Type = 'Company Purpose' or Default_Short_Name='COMP')  --or Default_Short_Name='COPH' or Default_Short_Name='COND'
			--	group by Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID				
			--where Row_ID = 34


			--Below Portion is commented by Mr.Mehul on 09032023 for not calculating leave days as per leave setting 'add in working hour'
			--update #Att_Muster
			--set Status = CAST(round(Leave - Isnull(OD_Compoff,0),2 )as numeric(18,2))--Changed by Sumit on 03022017--Leave - Isnull(OD_Compoff,0)
			--from #Att_Muster AM inner join       --Commented by Alpesh 27-Jul-2011 bcoz all leave has diff status 
			--(select Emp_Id ,sum(Isnull(Leave_Count,0)) as Leave From #Att_Muster --(select Emp_Id ,count(Leave_Count) as Leave From #Att_Muster --added by Falak 01-APR-2011
			--	Where  For_Date>=@From_Date and For_DAte <=@to_Date --Status = 'L' and // 
			--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
			--Left Outer Join 
			--	(select	sum((CASE WHEN Leave_Code='COMP' THEN	LT.CompOff_Used - IsNull(LT.Leave_Encash_Days,0) ELSE LT.Leave_Used END) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID
			--	from	T0140_LEAVE_TRANSACTION LT  WITH (NOLOCK) 
			--			INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LT.Leave_ID=LM.Leave_ID						
			--	where	(Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID
			--			AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
			--	group by Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID				
			--where Row_ID = 34

			update #Att_Muster
			set Status =  CAST(round(Leave - Isnull(OD_Compoff,0) -Isnull(Leave_ADD_In_Present,0),3 )as numeric(18,3))--Changed by Sumit on 03022017--Leave - Isnull(OD_Compoff,0)
			from #Att_Muster AM inner join       --Commented by Alpesh 27-Jul-2011 bcoz all leave has diff status 
			(select Emp_Id ,sum(Isnull(Leave_Count,0)) as Leave From #Att_Muster --(select Emp_Id ,count(Leave_Count) as Leave From #Att_Muster --added by Falak 01-APR-2011
				Where  For_Date>=@From_Date and For_DAte <=@to_Date --Status = 'L' and // 
				group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
			Left Outer Join 
				(select	sum((CASE WHEN Leave_Code='COMP' THEN	LT.CompOff_Used - IsNull(LT.Leave_Encash_Days,0) ELSE LT.Leave_Used END) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID
				from	T0140_LEAVE_TRANSACTION LT 
						INNER JOIN  T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID						
						INNER JOIN #Emp_Cons EC ON LT.Emp_ID = EC.Emp_ID
				where	(Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Cmp_ID
						AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
				group by LT.Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID	
			Left Outer Join   --- Added by Hardik 08/01/2021 for Cliantha
				(select	CAST(sum(Leave_Used)/8 AS NUMERIC(18,3)) AS Leave_ADD_In_Present,lt.Emp_ID
				from	T0140_LEAVE_TRANSACTION LT 
						INNER JOIN  T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID
						INNER JOIN #Emp_Cons EC ON LT.Emp_ID = EC.Emp_ID
				where	Isnull(LM.Add_In_Working_Hour,0) = 1 and LT.Cmp_ID=@Cmp_ID
						AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
				group by LT.Emp_ID)Q2 on Am.Emp_ID = Q2.Emp_ID				
			where Row_ID = 34

		End
	Else
		Begin
			
			--Below Portion is commented by Mr.Mehul on 09032023 for not calculating leave days as per leave setting 'add in working hour'

			--update #Att_Muster
			--set Status = CAST(round(Leave ,3) as numeric(18,3))--Leave  --Changed by Sumit on 0302201
			--from #Att_Muster AM inner join       --Commented by Alpesh 27-Jul-2011 bcoz all leave has diff status 
			--(select Emp_Id ,sum(Isnull(Leave_Count,0)) as Leave From #Att_Muster --(select Emp_Id ,count(Leave_Count) as Leave From #Att_Muster --added by Falak 01-APR-2011
			--	Where  For_Date>=@From_Date and For_DAte <=@to_Date --Status = 'L' and // 
			--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
			----left outer join T0040_LEAVE_MASTER LM on Lm.Leave_ID = AM.
			--where Row_ID = 34

			update #Att_Muster
			set Status = CAST(round(Leave -Isnull(Leave_ADD_In_Present,0) ,3) as numeric(18,3))    --Leave  --Changed by Sumit on 0302201
			from #Att_Muster AM inner join       --Commented by Alpesh 27-Jul-2011 bcoz all leave has diff status 
			(select Emp_Id ,sum(Isnull(Leave_Count,0)) as Leave From #Att_Muster --(select Emp_Id ,count(Leave_Count) as Leave From #Att_Muster --added by Falak 01-APR-2011
				Where  For_Date>=@From_Date and For_DAte <=@to_Date --Status = 'L' and // 
				group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
			Left Outer Join   --- Added by Hardik 08/01/2021 for Cliantha
				(select	sum(Leave_Used)/8  AS Leave_ADD_In_Present,lt.Emp_ID
				from	T0140_LEAVE_TRANSACTION LT 
						INNER JOIN  T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID						
				where	Isnull(LM.Add_In_Working_Hour,0) = 1 and LT.Cmp_ID=@Cmp_ID
						AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
				group by Emp_ID)Q2 on Am.Emp_ID = Q2.Emp_ID				
			where Row_ID = 34

			
		End
		
	--PRINT 'ATT 19 :' + CONVERT(VARCHAR(20), GETDATE(), 114)					
   ----PRINT 'STATE 7.4 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	
	/*update #Att_Muster
	set Status = W_H_Days
	from #Att_Muster AM inner join 
	(select Emp_Id ,sum(WO_HO_Day) as W_H_Days From #Att_Muster 
		Where WO_HO_Day =1 and( Status = 'W'or Status ='HO' ) and For_Date>=@From_Date and For_DAte <=@to_Date 
		group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	where Row_ID = 35*/

	--if OBJECT_ID('tempdb..#tmp') is not null
	--	select *
	--	from #Att_Muster AM LEFT OUTER JOIN 
	--		(select Emp_Id ,sum(Isnull(WO_HO_Day,0)) as W_H_Days From #Att_Muster 
	--			Where WO_HO_Day =1 and WO_HO='W' and For_Date>=@From_Date and For_DAte <=@to_Date 
	--			--Where WO_HO_Day =1 and Status='W' and For_Date>=@From_Date and For_DAte <=@to_Date -- week_off work should not consider in absent/present Mitesh 26102012
	--			group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--		Left Outer Join 
	--			(select Emp_Id ,sum(isnull(WO_HO_Day,0)) As Half_WeekOff
	--			From #Att_Muster 
	--			Where (WO_HO='W' and WO_HO_Day=0.5)and For_Date>=@From_Date and For_DAte <=@to_Date 
	--			group by Emp_ID)Q1 on Am.Emp_ID = Q1.Emp_ID
	--		where Row_ID = 35
	
	

	UPDATE	AM
	SET		Status = IsNull(W_H_Days,0)  + Isnull(Half_WeekOff,0)
	FROM	#Att_Muster AM 
			LEFT OUTER JOIN	(SELECT	Emp_Id,SUM(IsNull(WO_HO_Day,0)) AS W_H_Days 
							FROM	#Att_Muster 
							WHERE	WO_HO_Day =1 AND WO_HO='W' AND For_Date>=@From_Date AND For_DAte <=@to_Date 
							GROUP BY Emp_ID) Q ON Am.Emp_ID = Q.Emp_ID
			LEFT OUTER JOIN (SELECT Emp_Id,SUM(IsNull(WO_HO_Day,0)) As Half_WeekOff
							FROM	#Att_Muster 
							WHERE	(WO_HO='W' and WO_HO_Day=0.5)and For_Date>=@From_Date and For_DAte <=@to_Date 
							GROUP BY Emp_ID)Q1 ON Am.Emp_ID = Q1.Emp_ID
	WHERE Row_ID = 35
	
	
	--Changed By Nikunj 28-04-2011
	---Here Above Status remove by nikunj and Out WO_HO='W' becuase if we come at week off then also we have to see in week off also.
	--For Ex.If 5 sundays in month then and we come 2 sunday then week off must be says 5 only not 3.becuase week offf is 5
	----PRINT 'STATE 7.5 :' + CONVERT(VARCHAR(20), GETDATE(), 114);

	--Commented by Hardik 31/07/2018 as this query already put on above query with Left Outer join
	--update #Att_Muster
	--set Status = cAST(isnull(Status,'0') AS NUMERIC(9,2)) --+ Cast(W_H_Days as numeric(18,2)) -- Changed By Ali 03032014
	--from #Att_Muster AM inner join 
	--(select Emp_Id ,sum(Isnull(WO_HO_Day,0)) as W_H_Days From #Att_Muster 
	--	Where WO_HO_Day =0.5 And WO_HO = 'W' and For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 35

	update #Att_Muster
	set Status = IsNull(W_H_Days,0)
	from #Att_Muster AM Left Outer Join
	(select Emp_Id ,sum(Isnull(WO_HO_Day,0)) as W_H_Days From #Att_Muster 
		Where (WO_HO_Day =1 or WO_HO_Day =0.5) and (WO_HO='HO' or WO_HO='OHO')   and For_Date>=@From_Date and For_DAte <=@to_Date -- and Status='HO'
		group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	where Row_ID = 36
	
	
	--PRINT 'ATT 20 :' + CONVERT(VARCHAR(20), GETDATE(), 114)					
	----PRINT 'STATE 8 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	--- Added by Mihir Adeshara 07062012
		Create Table #Late_Early_Deduction
		(
			Emp_ID numeric(18,0),
			For_Date datetime,
			Late_Deduct_Days numeric(18,2),
			Early_Deduct_Days numeric(18,2)
		 )
		 
		 --create unique nonclustered index IX_Late_Early_Deduction on #Late_Early_Deduction (Emp_ID,For_Date);

		-- select @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,'Late',0,1
		 --exec rpt_Late_Early_Mark_Deduction_Details @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,'Late',0,1
	--PRINT 'ATT 21 :' + CONVERT(VARCHAR(20), GETDATE(), 114)					
	
	----PRINT 'STATE 9 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	
			IF @Late_Early_Ded_Combine = 1
			BEGIN
				exec rpt_Late_Early_Mark_Combine_Deduction @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,1
			END
			ELSE
			BEGIN
					--IF @Late_Mark_Scenario = 2  and  Exists(select 1 from T0050_GENERAL_LATEMARK_SLAB where DEDUCTION_TYPE = 'Hours' and CMP_ID = @Cmp_ID)
					if @Late_Mark_Scenario = 2  and  Exists(select 1 from T0050_GENERAL_LATEMARK_SLAB GLS inner join #EMP_GEN_SETTINGS_ATT EG on EG.Gen_Id = GLS.GEN_ID where GLS.DEDUCTION_TYPE = 'Hours' and CMP_ID = @Cmp_ID)
					BEGIN
							exec rpt_Late_Early_Mark_Combine_Deduction @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,1
					END
					ELSE
					BEGIN
							exec rpt_Late_Early_Mark_Deduction_Details @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,'Late',0,1
					END
					
					--EXEC RPT_LATE_EARLY_MARK_DEDUCTION_DETAILS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,'LATE',0,1
			END
	
		update #Att_Muster 
		set Status_2 =   '*',Late_deduct_Days=els.Late_Deduct_Days
			from #Att_Muster AM 
			inner join #Late_Early_Deduction els on am.emp_ID = els.emp_ID and am.For_date =els.For_Date 
			where AM.Status <> 'A' and els.Late_Deduct_Days = 0 
			
				
		update #Att_Muster 
		set Status_2 =   'LC',Late_deduct_Days=els.Late_Deduct_Days
			from #Att_Muster AM inner join #Late_Early_Deduction els on am.emp_ID = els.emp_ID and am.For_date =els.For_Date 
			where AM.Status <> 'A' and els.Late_Deduct_Days>0  --- Changed by Gadriwala Muslim 24062015
		
		--Added by Hardik 02/12/2015 for Early Deduction day
		update #Att_Muster 
		set Status_2 =   'EC',Early_deduct_Days=els.Early_Deduct_Days
			from #Att_Muster AM inner join #Late_Early_Deduction els on am.emp_ID = els.emp_ID and am.For_date =els.For_Date 
			where AM.Status <> 'A' and els.Early_Deduct_Days>0  
			
			
		-- Added by Hardik 02/04/2019 for NLMK
		DECLARE @QRY NVARCHAR(500)

		SET @QRY = 'UPDATE AM SET Status_2 = ''**''
					FROM #Att_Muster AM INNER JOIN
					(SELECT ROW_NUMBER() Over(PARTITION by Emp_Id Order by for_Date) AS Row_Num, A.Emp_Id,A.For_Date 
						FROM #Att_Muster A WHERE A.A_days = 0.5) QRY ON AM.For_Date=QRY.For_Date AND AM.Emp_Id=QRY.Emp_Id
					Inner Join #EMP_GEN_SETTINGS_ATT EG On AM.Emp_Id = EG.Emp_Id 
					Where Qry.Row_Num <= EG.Half_day_Excepted_count'
		
		EXECUTE sys.sp_executesql @QRY

		

		If @EXPORT_TYPE = 'Excel'
			BEGIN
				update #Att_Muster
				set Status = q.Late_Early_Deduct_Days
				from #Att_Muster AM inner join 
				(select e.Emp_Id ,SUM(e.Late_Deduct_Days) Late_Early_Deduct_Days From #Late_Early_Deduction  e
					inner join #Att_Muster SAM on SAM.For_Date = e.For_Date and sam.Emp_Id = e.Emp_ID
					Where e.For_Date>=@From_Date and e.For_Date <=@to_Date and SAM.status <> 'A'  -- Changed by Gadriwala Muslim 24062015
					group by e.Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
				where Row_ID = 37
			END
		ELSE
			BEGIN
			
				update #Att_Muster
				set Status = q.Late_Early_Deduct_Days
				from #Att_Muster AM inner join 
				(select e.Emp_Id ,SUM(e.Late_Deduct_Days) + SUM(e.Early_Deduct_Days) as Late_Early_Deduct_Days From #Late_Early_Deduction  e
					inner join #Att_Muster SAM on SAM.For_Date = e.For_Date and sam.Emp_Id = e.Emp_ID
					Where e.For_Date>=@From_Date and e.For_Date <=@to_Date and SAM.status <> 'A'  -- Changed by Gadriwala Muslim 24062015
					group by e.Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
				where Row_ID = 37
			END
		
		
			if @Late_Mark_Scenario = 2  and  Exists(select 1 from T0050_GENERAL_LATEMARK_SLAB GLS inner join #EMP_GEN_SETTINGS_ATT EG on EG.Gen_Id = GLS.GEN_ID where GLS.DEDUCTION_TYPE = 'Hours' and CMP_ID = @Cmp_ID)
			begin
						
						Declare @TotalSumOfLateAndEarlyDeduction as Numeric(18,2) = 0
	
						if exists(select 1 From #Late_Early_Deduction where Late_Deduct_Days > 0 or Early_Deduct_Days > 0)
						BEGIN
							
							Select @TotalSumOfLateAndEarlyDeduction = (Isnull(sum([dbo].[F_Return_Sec](replace(Late_Deduct_Days,'.',':')) ),0) + 
										Isnull(sum([dbo].[F_Return_Sec](replace(Early_Deduct_Days,'.',':')) ),0)) / (3600*8)
							--Sum(dbo.F_Return_Sec(cast(Replace(Late_Deduct_Days,'.',':') as Time))) +  Sum(dbo.F_Return_Sec(cast(Replace(Early_Deduct_Days,'.',':') as Time))) 
							From #Late_Early_Deduction where Late_Deduct_Days > 0 or Early_Deduct_Days > 0
							
							--set @TotalSumOfLateAndEarlyDeduction = dbo.F_Return_Hours(@TotalSumOfLateAndEarlyDeduction)
							
							update #Att_Muster set Status = @TotalSumOfLateAndEarlyDeduction from #Att_Muster where Row_ID = 37

						END

			END
	
	
		Update #Att_Muster
		set Status = isnull(status,'0.00')
		where row_ID = 37
			
	
	--update #Att_Muster
	--set Status = LC_Count
	--from #Att_Muster AM inner join 
	--(select Emp_Id ,Count(Isnull(Late_sec,0)) as LC_Count From #Emp_Late_Second  e
	--	Where e.For_Date>=@From_Date and e.For_Date <=@to_Date and e.Late_Sec > 0 
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 37
	
	-- Added by rohit on 28012014 for inductotherm for Showing RegularShip in the Attendance register.
	
	update #Att_Muster
	set Status = case when isnull(RG.flag,0) = 1 then 'RG' else '-' end
	from #Att_Muster AM inner join #regularship RG on Am.Emp_Id = RG.emp_id
	where Row_ID = 37
	
	----PRINT 'STATE 10 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
--ended by rohit on 28012014

	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);


-- Added by rohit For Leave Name Showing With Leave Code in Footer on 08082013
	Declare @leave_Footer varchar(MAX)
	
	SELECT	@leave_Footer = COALESCE( @leave_Footer + '', '') + LEFT ((CASE WHEN Apply_Hourly=1 then Left(s.Leave_name, 20) + '(Hourly) ' else Left(s.Leave_name, 25) end) + SPACE(30), 30)
	FROM	( 
				SELECT	DISTINCT (LEFT(upper(Leave_Code) + SPACE(4), 4) + ': ' + lower(Leave_name)  + space(30)) AS leave_name,Cmp_ID,Apply_Hourly
				FROM	T0040_LEAVE_MASTER t WITH (NOLOCK) 
						WHERE	EXISTS (
											SELECT	TOP 1 1
											FROM	dbo.T0140_LEAVE_TRANSACTION AS LT2 WITH (NOLOCK)  Inner Join #Emp_Cons EC on LT2.Emp_Id =  EC.Emp_ID
											WHERE	(LT2.Leave_Used > 0 or LT2.compOff_Used > 0)
													AND LT2.Leave_ID=t.Leave_ID and LT2.For_Date BETWEEN @From_Date and @To_date
										 ) 
			) S
	WHERE	S.Cmp_id = @Cmp_ID
	ORDER BY S.leave_name



if @Report_For = ''
	begin
		
		if @Opt_Para = 1
		begin 
				
				update #Att_Muster
					set Status = Status + '-' + Status_2 -- CAST('-0.5' as varchar)
					--where Status_2 = '0.50' --and Leave_Count = 0.5
					where Isnull(Leave_Count,0) > 0
					
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Dishman')) --Added Condition for Dishman Company show Absent As LWP 30082017
						 BEGIN
							Update #Att_Muster SET Status = 'LWP' Where Status = 'A' 
						 End
					
					--select * from #Att_Muster AM
					--Inner join dbo.T0100_EMP_SHIFT_DETAIL ESD With (nolock) on AM.Emp_ID = esd.Emp_ID and am.For_Date = esd.For_Date
					------where  Am.Status in ('P','HO')
					--return

					Insert Into #Att_Muster_Excel
					Select  AM.* , E.Alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name ,
					BM.Branch_Address,BM.comp_name
					, BM.Branch_Name , DM.Dept_Name ,GM.Grd_Name , DGM.Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
					,DGM.Desig_Dis_No   --added jimit 24082015
					,sbb.SubBranch_Name --Added by Jimit 24082018
					,esd.shift_id --added by mehul on 04022023
					From	#Att_Muster  AM 
							INNER JOIN #EMP_CONS EM ON EM.EMP_ID=AM.EMP_ID
							Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
							INNER JOIN (	
											select	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.SubBranch_ID 
											from	T0095_INCREMENT I WITH (NOLOCK) 
											INNER JOIN (
															SELECT	MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
															FROM	T0095_INCREMENT I  WITH (NOLOCK) 
																	INNER JOIN (
																					SELECT	MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																					FROM	T0095_INCREMENT I3 WITH (NOLOCK) 
																					WHERE	I3.Increment_effective_Date <= @To_Date
																					GROUP BY I3.EMP_ID  
																				) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
														   where I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Cmp_ID 
														   group by I.emp_ID  
														) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
											
											--SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.SubBranch_ID 
											--FROM	dbo.T0095_Increment I 
											--		inner join (
											--						select	max(Increment_ID) as Increment_ID , Emp_ID 
											--						From	dbo.T0095_Increment	-- Ankit 08092014 for Same Date Increment
											--						where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
											--						group by emp_ID  
											--					) Qry on I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
										)Q_I ON E.EMP_ID = Q_I.EMP_ID 
							INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID 
							INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON Q_I.BRANCH_ID = BM.BRANCH_ID 
							LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID 
							LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
							LEFT OUTER Join dbo.T0050_SubBranch SBB  WITH (NOLOCK) ON Q_I.SubBranch_ID = SBB.SubBranch_ID
							Inner join dbo.T0100_EMP_SHIFT_DETAIL ESD With (nolock) on AM.Emp_ID = esd.Emp_ID and am.For_Date = esd.For_Date
							--where  Am.Status in ('P','HO')
					Order by	Case When IsNumeric(e.Alpha_Emp_Code) = 1 
									then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
								When IsNumeric(e.Alpha_Emp_Code) = 0 
									then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
								Else e.Alpha_Emp_Code
								End,For_date
					--Order by E.Emp_Code,Am.For_Date	


		end
		else
		begin
		   --- Added by Jignesh 08-Nov-2012
		if @Export_Type  = 'EXCEL'
			begin
					
					--------- Added by Siddharth 03/12/2013
					update #Att_Muster
					set Status = Status + '-' + Status_2 -- CAST('-0.5' as varchar)
					--where Status_2 = '0.50' --and Leave_Count = 0.5
					where Isnull(Leave_Count,0) > 0
					
					IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Dishman')) --Added Condition for Dishman Company show Absent As LWP 30082017
						 BEGIN
							Update #Att_Muster SET Status = 'LWP' Where Status = 'A' 
						 End
					
					
					Insert Into #Att_Muster_Excel
					Select  AM.* , E.Alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name ,
					BM.Branch_Address,BM.comp_name
					, BM.Branch_Name , DM.Dept_Name ,GM.Grd_Name , DGM.Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
					,DGM.Desig_Dis_No   --added jimit 24082015
					,sbb.SubBranch_Name --Added by Jimit 24082018
					--,shift_id --added by mehul on 04022023
					From	#Att_Muster  AM 
							INNER JOIN #EMP_CONS EM ON EM.EMP_ID=AM.EMP_ID
							Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
							INNER JOIN (	
											select	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.SubBranch_ID 
											from	T0095_INCREMENT I WITH (NOLOCK) 
											INNER JOIN (
															SELECT	MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
															FROM	T0095_INCREMENT I  WITH (NOLOCK) 
																	INNER JOIN (
																					SELECT	MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																					FROM	T0095_INCREMENT I3 WITH (NOLOCK) 
																					WHERE	I3.Increment_effective_Date <= @To_Date
																					GROUP BY I3.EMP_ID  
																				) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
														   where I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Cmp_ID 
														   group by I.emp_ID  
														) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
											
											--SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.SubBranch_ID 
											--FROM	dbo.T0095_Increment I 
											--		inner join (
											--						select	max(Increment_ID) as Increment_ID , Emp_ID 
											--						From	dbo.T0095_Increment	-- Ankit 08092014 for Same Date Increment
											--						where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
											--						group by emp_ID  
											--					) Qry on I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
										)Q_I ON E.EMP_ID = Q_I.EMP_ID 
							INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID 
							INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON Q_I.BRANCH_ID = BM.BRANCH_ID 
							LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID 
							LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
							LEFT OUTER Join dbo.T0050_SubBranch SBB  WITH (NOLOCK) ON Q_I.SubBranch_ID = SBB.SubBranch_ID
					Order by	Case When IsNumeric(e.Alpha_Emp_Code) = 1 
									then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
								When IsNumeric(e.Alpha_Emp_Code) = 0 
									then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
								Else e.Alpha_Emp_Code
								End,For_date
					--Order by E.Emp_Code,Am.For_Date	
					
			End		
			
		else
			begin			
			/*Commented by Nimesh 04-Sep-2015
			-- Addded By Ali 13/01/2014 -- Start
			
			Update #Att_Muster Set status = 'CO' where Status = 'COMP'
			Update #Att_Muster Set status = 'UP' where Status = 'LWP' 
			*/
			
			--SET @leave_Footer = STUFF(@leave_Footer, CHARINDEX('COMP', @leave_Footer), 4, 'CO')
			--SET @leave_Footer = STUFF(@leave_Footer, CHARINDEX('LWP', @leave_Footer), 4, 'LP')
			
			-- Addded By Ali 13/01/2014 -- End
			----PRINT 'STATE 11 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
			
			
			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Dishman')) --Added Condition for Dishman Company show Absent As LWP 30082017
                 BEGIN
					Update #Att_Muster SET Status = 'LWP' Where Status = 'A' 
                 End
			
			
						
			--- End of Added by Mihir Adeshara 07062012
			Select AM.Emp_Id
				,AM.Emp_Id,AM.Cmp_ID,AM.For_Date,AM.[Status],
				--AM.Leave_Count,
				CAST(ROUND(AM.Leave_Count,2) as numeric(18,2)) as Leave_Count,
				AM.WO_HO,AM.Status_2,AM.Row_ID,AM.WO_HO_Day,
				--round(AM.P_days,2,0),
				CAST(ROUND(AM.P_days,2) as numeric(18,2)) as P_days,

				--AM.A_days,
				CAST(ROUND(AM.A_days,2) as numeric(18,2)) as A_days,
				
				AM.Join_Date,AM.Left_Date,AM.GatePass_Days,AM.Late_deduct_Days,AM.Early_deduct_Days
				,E.Emp_code,cast( E.Alpha_Emp_Code as varchar(20)) + ' - '+E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name,Cmp_Name
				, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
				,@leave_Footer As Leave_Footer ,E.Enroll_No
				,IsNUll(DM.Dept_Dis_no,0) as Dept_Dis_no ,Tm.[Type_Name]  --added jimit 05082015
				,DGM.Desig_Dis_No   --added jimit 24082015
				,VS.Vertical_Name,SV.SubVertical_Name     --added jimit 27042016
				,SB.SubBranch_Name --Added by Hardik 26/03/2018 for Kheti Bank
				,(select top 1 Director_Name from T0010_COMPANY_DIRECTOR_DETAIL WITH (NOLOCK)  where Cmp_ID = @Cmp_ID) as CMP_Director_Name
				,E.Father_name, Case E.Gender  When 'M' Then 'Male' When 'F' Then 'Female' Else '' End Gender -- Added by Hardik 21/10/2020 for Trident
			 From  #Att_Muster  AM 
			 Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
			INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.type_ID, I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
							(	select max(Increment_ID) as Increment_ID , i2.Emp_ID 
								From dbo.T0095_Increment i2 WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
									 inner join #Att_Muster a on i2.Emp_ID=a.Emp_Id
								where Increment_Effective_date <= @To_Date
										and i2.Cmp_ID = @Cmp_ID
								group by i2.emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 			
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK)  ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
				dbo.T0040_Type_Master tm  WITH (NOLOCK) on Q_I.Type_ID = tm.Type_ID LEFT outer JOIN
				T0040_Vertical_Segment VS WITH (NOLOCK) 	On Vs.Vertical_ID = Q_I.vertical_Id LEFT OUTER JOIN
				T0050_SubVertical SV WITH (NOLOCK)  ON sv.SubVertical_ID = Q_I.SubVertical_ID LEFT OUTER JOIN
				T0050_SubBranch SB WITH (NOLOCK)  ON SB.SubBranch_ID = Q_I.SubBranch_ID
				INNER JOIN T0010_COMPANY_MASTER C  WITH (NOLOCK) ON  E.Cmp_ID=C.Cmp_Id
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End,For_date
			--Order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) ,For_date
			----PRINT 'STATE 12 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
		end
	
		end

    
	end 

	

else if @Report_For = 'AttReg' --Added by Nimesh 24-Jun-2015 (FOR Payable Present Days calculation)
	begin			
		/* Discussed with Nimesh Bhai and Commented this Code by Ramiz on 17/11/2016, it was just for Better Space Utilization in Reports		
		
		Update #Att_Muster Set status = 'CO' where Status = 'COMP'
		Update #Att_Muster Set status = 'UP' where Status = 'LWP' 
	*/
		INSERT INTO #Att_Muster	(Emp_Id,Cmp_ID,For_Date,[Status],Leave_Count,WO_HO,Status_2,Row_ID,WO_HO_Day,
							P_days,A_days,Join_Date,Left_Date,GatePass_Days,Late_deduct_Days,Early_deduct_Days)
		SELECT	Emp_Id,Cmp_ID,DateAdd(d,1,For_Date),0.00,NULL,NULL,NULL,39,0.00,0.00,0.00,Join_Date,Left_Date,0.00,0.00,0.00
		FROM	#Att_Muster
		WHERE	ROW_ID=38
		
		
		DECLARE @WO_Inc as tinyint,
				@HO_Inc as tinyint,
				@Payable_Present_days numeric(18,2)
		
		DECLARE @WeekOff_Days numeric(18,2),
				@Holiday_Days numeric(18,2),
				@LC_Days numeric(18,2),
				@GP_Days numeric(18,2),
				@Paid_Leave numeric(18,2),
				@Present_Days numeric(18,2);
		
		DECLARE @EmpID Numeric(18,0),
				@CmpID Numeric(18,0),
				@BranchID Numeric(18,0);
		
		DECLARE cur_PD CURSOR
		FAST_FORWARD 
		FOR 
		SELECT	A.Emp_ID,A.Cmp_ID,I.Branch_ID 
		FROM	#Att_Muster A INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON A.Cmp_ID=E.Cmp_ID AND A.Emp_Id=E.Emp_ID			
				INNER JOIN (SELECT Branch_ID,Emp_ID,Cmp_ID 
							FROM  T0095_INCREMENT I  WITH (NOLOCK) 
							WHERE I.Increment_ID=(SELECT MAX(Increment_ID)
												  FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
												  WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID
												  )
							) I ON E.Emp_ID=I.Emp_ID AND E.Cmp_ID=I.Cmp_ID 					
		WHERE ISNULL(E.Extra_AB_Deduction,0) = 0 AND A.ROW_ID=38;
		OPEN cur_PD
		FETCH NEXT FROM cur_PD INTO @EmpID,@CmpID,@BranchID
		WHILE (@@FETCH_STATUS = 0)
		BEGIN				
			set @WO_Inc = 0
			set @HO_Inc = 0
			set @Payable_Present_days = 0
					
			--select @Emp_Branch_Id = branch_id from dbo.T0095_INCREMENT
			--where Emp_ID = @temp_Emp_ID and Increment_ID = 
			--(select MAX(Increment_ID) from dbo.T0095_INCREMENT where Emp_ID = @temp_Emp_ID and Increment_Effective_Date<= @To_Date)
			
			SELECT	@HO_Inc =  Inc_Holiday,@WO_Inc = Inc_Weekoff ,@Late_Early_Ded_Combine = Isnull(Is_Chk_Late_Early_Mark,0)
			FROM	T0040_GENERAL_SETTING  WITH (NOLOCK) 
			WHERE	Branch_ID = @BranchID
					AND For_Date = (SELECT	MAX(For_Date)
									FROM	dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) 
									WHERE	For_Date <= @To_Date AND Branch_ID = @BranchID 
											AND Cmp_ID = @Cmp_ID
									)   
			
			
			
			Select @WeekOff_Days=WeekOff_Days,@Holiday_Days=Holiday_Days,@LC_Days=LC_Days,@GP_Days=GP_Days,@Paid_Leave=Paid_Leave,@Present_Days=Present_Days
			FROM	(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS WeekOff_Days FROM #Att_Muster A Where Cmp_ID=@CmpID AND Emp_Id=@EmpID AND Row_ID=35) W,
					(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS Holiday_Days FROM #Att_Muster A Where Cmp_ID=@CmpID AND Emp_Id=@EmpID AND Row_ID=36) HO,
					(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS LC_Days FROM #Att_Muster A Where Cmp_ID=@CmpID AND Emp_Id=@EmpID AND Row_ID=37) LC,
					(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS GP_Days FROM #Att_Muster A Where Cmp_ID=@CmpID AND Emp_Id=@EmpID AND ISNULL([Row_ID],0)=38) GP,
					(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS Paid_Leave FROM #Att_Muster A Where Cmp_ID=@CmpID AND Emp_Id=@EmpID AND ISNULL([Row_ID],0)=34) L,
					(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS Present_Days FROM #Att_Muster A Where Cmp_ID=@CmpID AND Emp_Id=@EmpID AND ISNULL([Row_ID],0)=32) P
			
			--select @WeekOff_Days = case when W = '' then 0 else cast(W as numeric(18,2)) end,
			--	   @Holiday_Days = case when H = '' then 0 else cast(H as numeric(18,2)) end, 
			--	   @LC_Days = case when LC = '' then 0 else cast(Lc as numeric(18,2)) end,
			--	   @GP_Days = case when GP = '' then 0 else cast(GP as numeric(18,2)) end,
			--	   @Paid_Leave = case when L = '' then 0 else CAST(L as numeric(18,2))end  
			--from #CrossTab where Code = @Code
									
			
			set @Payable_Present_days = isnull(@Present_days,0) 
			
			IF ISNULL(@HO_Inc,0) = 1
				SET @Payable_Present_days = @Payable_Present_days +  ISNULL(@Holiday_Days,0)
				
			IF ISNULL(@Wo_Inc,0) = 1
				SET @Payable_Present_days = @Payable_Present_days +  ISNULL(@WeekOff_Days,0)	
				
			SET	@Payable_Present_days = (@Payable_Present_days + ISNULL(@Paid_Leave,0)) - (ISNULL(@LC_Days,0) + ISNULL(@GP_Days,0))
			
			
			IF @Payable_Present_days < 0 
				SET @Payable_Present_days	= 0
			 
			UPDATE	#Att_Muster SET [Status]= @Payable_Present_days 
			WHERE	Emp_Id = @EmpID AND Cmp_ID=@CmpID AND Row_ID=39
			
			
			FETCH NEXT FROM cur_PD INTO @EmpID,@CmpID,@BranchID
		END
		
		
		
		--- End of Added by Mihir Adeshara 07062012
		Select AM.* , E.Emp_code,cast( E.Alpha_Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
			,@leave_Footer as Leave_Footer,E.Enroll_No
		 ,DGM.Desig_Dis_No       --added jimit 24082015
		 ,vs.Vertical_Name,sv.SubVertical_Name  --added jimit 27042016
		 From  #Att_Muster  AM Inner join dbo.T0080_EMP_MASTER E  WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Vertical_ID,I.SubVertical_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			dbo.T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			dbo.T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT outer JOIN
			T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = Q_I.Vertical_ID Left outer JOIN
			T0050_SubVertical Sv WITH (NOLOCK)  On sv.SubVertical_ID = Q_I.SubVertical_ID
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
		When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
			Else e.Alpha_Emp_Code
		End,For_date
		--Order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) ,For_date
		
	end	
else if @Report_For = 'WithOD' --Added by Nimesh 26-Jun-2015 (Retrieving OD Detail Instead of GP In Attendance Register Format 1)
	begin
	
	/* Discussed with Nimesh Bhai and Commented this Code By Ramiz on 17/11/2016 , it was just for Better Space Utilization in Reports		
		
		Update #Att_Muster Set status = 'CO' where Status = 'COMP'
	*/
		
		
		-- Comment by nilesh patel on 09062016 After discussion with Hardik Bhai 
			--Update #Att_Muster Set status = 'UP' where Status = 'LWP' 
		-- Comment by nilesh patel on 09062016 After discussion with Hardik Bhai 
		
		--Display OD Leave in seperate column (OD) 
		--We have replaced GP column with OD column.(Row_ID=38)
		IF @OD_Compoff_As_Present = 0
		BEGIN			
			UPDATE	#Att_Muster
			SET		[Status] = Isnull(OD_Compoff,0)
			FROM	#Att_Muster AM INNER JOIN 
					(
						SELECT	AM.Emp_Id, SUM(CASE WHEN CHARINDEX('/', [STATUS]) > 0 THEN 0.5 ELSE AM.Leave_Count END) AS OD_Compoff 
						From	#Att_Muster AM 
						INNER JOIN (
									SELECT	Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS  AS Leave_Code
									FROM	T0040_Leave_Master  WITH (NOLOCK) 
									WHERE	Cmp_Id = @Cmp_Id AND (Leave_Type = 'Company Purpose' OR Default_Short_Name='COMP') --OR Default_Short_Name='COPH' OR Default_Short_Name='COND'
								)  T ON [STATUS] = T.LEAVE_CODE OR CHARINDEX(T.LEAVE_CODE , [STATUS]) > 0
					Where	For_Date>=@From_Date and For_DAte <= @to_Date 
					GROUP BY Emp_ID
					)Q1 ON Am.Emp_ID = Q1.Emp_ID		
			WHERE	Row_ID = 38;	
			
			--OD Leave should not be considered in Leave Column because we have already taken separate column for this.
			--Even it should not be displayed in both column OD and Leave when the OD leaves are calcuated in present days.
			UPDATE	#Att_Muster
			SET		[Status] = [Status] - Isnull(OD_Compoff,0)
			FROM	#Att_Muster AM INNER JOIN 
					(
						SELECT	AM.Emp_Id, SUM(CASE WHEN CHARINDEX('/', [STATUS]) > 0 THEN 0.5 ELSE AM.Leave_Count END) AS OD_Compoff 
						From	#Att_Muster AM 
						INNER JOIN (
									SELECT	Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS  AS Leave_Code
									FROM	T0040_Leave_Master WITH (NOLOCK)  
									WHERE	Cmp_Id = @Cmp_Id AND (Leave_Type = 'Company Purpose' OR Default_Short_Name='COMP') --OR Default_Short_Name='COPH' OR Default_Short_Name='COND'
								)  T ON [STATUS] = T.LEAVE_CODE OR CHARINDEX(T.LEAVE_CODE , [STATUS]) > 0
					Where	For_Date>=@From_Date and For_DAte <= @to_Date 
					GROUP BY Emp_ID
					)Q1 ON Am.Emp_ID = Q1.Emp_ID		
			WHERE	Row_ID = 34;	
			--------------End-------------------------	
		END
		ELSE
		BEGIN
			UPDATE	#Att_Muster
			SET		[Status] = 0
			WHERE	Row_ID = 38
		END
		
		
		
		--- End of Added by Mihir Adeshara 07062012
		Select AM.* , E.Emp_code,cast( E.Alpha_Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
			,@leave_Footer as Leave_Footer,E.Enroll_No
			,IsNUll(DM.Dept_Dis_no,0) as Dept_Dis_no ,tm.Type_Name
			,vs.Vertical_Name,Sv.SubVertical_Name   --added jimit 27012016
		 From  #Att_Muster  AM Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID,I.Vertical_ID,I.SubVertical_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM  WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			dbo.T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			dbo.T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID  Left outer join 
		dbo.T0040_Type_Master tm WITH (NOLOCK)  on Q_I.Type_ID = tm.Type_ID LEFT outer JOIN
			T0040_Vertical_Segment vs WITH (NOLOCK)  on vs.Vertical_ID = Q_I.Vertical_ID Left outer JOIN
			T0050_SubVertical Sv WITH (NOLOCK)  On sv.SubVertical_ID = Q_I.SubVertical_ID
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
		When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
			Else e.Alpha_Emp_Code
		End,For_date
	end
else if @Report_For = 'Absent' or @Report_For = 'ABSENT_CON' or @Report_For = 'Complete_Absent'
	begin
		   If Object_Id('tempdb..#Att_Muster_with_shift') Is Null
			   CREATE TABLE #Att_Muster_with_shift
				  (
						Emp_Id		numeric , 
						Cmp_ID		numeric,
						For_Date	datetime,
						Status		varchar(10),
						Leave_Count	numeric(12,3),--numeric(5,1),
						WO_HO		varchar(2),
						Status_2	varchar(10),
						Row_ID		numeric ,
						WO_HO_Day	numeric(4,1) default 0,
						P_days		numeric(12,3) default 0, 
						---A_days		numeric(5,1) default 0, --- changes  1- 2 jignesh 12-Dec-2019
						A_days		numeric(5,2) default 0,
						Join_Date	Datetime default null,
						Left_Date	Datetime default null,
						GatePass_Days numeric(18,2) default 0, --Added by Gadriwala Muslim 07042015
						Late_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
						Early_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
						shift_id	numeric
				  )
			
			declare @cur_shift_id numeric
			declare @cur_for_date datetime
			declare @cur_emp_id numeric
			
			set @cur_emp_id = 0 
			set @cur_shift_id = 0
			set @cur_for_date = NULL
			insert into #Att_Muster_with_shift
			select A.*,D.Shift_ID from #Att_Muster A  Left Outer JOIN
				#Data D On A.For_Date = D.For_date And A.Emp_Id = D.Emp_Id  --- Added Join by Hardik 30/01/2019 for Cliantha as Auto shift not showing
			where A.for_date >= @from_date and A.for_date <= @to_date and A_days > 0   --status = 'A' --comment by hasmukh on 14122012 for half day absent not was not shown before

			--- Added Below by Hardik 30/01/2019 for Cliantha as Auto shift not showing
			Update A 
			Set shift_id = dbo.fn_get_Shift_From_Monthly_Rotation(A.Cmp_Id,A.Emp_Id,A.For_Date)
			From #Att_Muster_with_shift A
			Where Isnull(A.shift_id,0) = 0
			
			if @Leave_Flag = 1
				Begin
					insert into #Att_Muster_Absent
					select *,'' from #Att_Muster  where for_date >= @from_date and for_date <= @to_date and A_days > 0 
					return 
				End
					
			/*Commented by Nimesh 20 May 2015
			declare curShift cursor for
				select for_date,Shift_id,esd.emp_id from T0100_Emp_Shift_Detail ESD inner join
				#Emp_Cons ec on ec.emp_id = esd.emp_id where for_date <= @to_date
			open curShift
				fetch curShift into  @cur_for_date,@cur_shift_id,@cur_emp_id
			while @@fetch_status = 0
				begin 
					
					update #Att_Muster_with_shift set shift_id = @cur_shift_id where for_date >= @cur_for_date and emp_id =@cur_emp_id
					
					fetch curShift into  @cur_for_date,@cur_shift_id	,@cur_emp_id	
				end
				
			close curShift                    
			deallocate curShift    
			*/
							
			--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
			
			
			Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @to_date, @constraint
			
			DECLARE @Tmp_Date DATETIME;
			SET @Tmp_Date = @From_Date;
			
			WHILE (@Tmp_Date <= @To_Date) BEGIN					
				--Updating default shift info From Shift Detail
				UPDATE	#Att_Muster_with_shift SET shift_id = Shf.Shift_ID
				FROM	#Att_Muster_with_shift D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
				FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)  INNER JOIN  
						(SELECT MAX(For_Date) AS For_Date,ESD.Emp_ID FROM T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)  Inner Join #Emp_Cons EC On ESD.Emp_ID=EC.Emp_ID 
							WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @Tmp_Date GROUP BY ESD.Emp_ID) S ON 
							esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
						Shf.Emp_ID = D.EMP_ID 
				WHERE	D.For_Date=@Tmp_Date
				
				
				--Updating Shift ID From Rotation
				UPDATE	#Att_Muster_with_shift 
				SET		SHIFT_ID=SM.SHIFT_ID
				FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK)  ON R.R_ShiftID=SM.Shift_ID					
				WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 
						AND Emp_Id=R.R_EmpID AND For_Date=@Tmp_Date
						AND R.R_Effective_Date=(
												SELECT	MAX(R_Effective_Date)
												FROM	#Rotation R1	
												WHERE	R1.R_EmpID=Emp_Id AND R_Effective_Date<=@Tmp_Date
											   ) 							
						
				--Updating Shift ID For Shift_Type=0
				UPDATE	#Att_Muster_with_shift
				SET		SHIFT_ID=Shf.SHIFT_ID
				FROM	#Att_Muster_with_shift D 
						INNER JOIN (
									SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
									FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)   Inner Join #Emp_Cons EC On ESD.Emp_ID=EC.Emp_ID 
									WHERE	esd.Emp_ID IN (
															SELECT	R.R_EmpID 
															FROM	#Rotation R
															WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 
															GROUP BY R.R_EmpID
														  ) 
											AND Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date 
									) Shf ON Shf.Emp_ID = D.Emp_Id
				WHERE	For_date=@Tmp_Date

				--Updating Shift ID For Shift_Type=1
				UPDATE	#Att_Muster_with_shift
				SET		SHIFT_ID=Shf.SHIFT_ID
				FROM	#Att_Muster_with_shift D 
						INNER JOIN (
									SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
									FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)  Inner Join #Emp_Cons EC On ESD.Emp_ID=EC.Emp_ID 
									WHERE	esd.Emp_ID NOT IN (
																SELECT	R.R_EmpID 
																FROM	#Rotation R
																WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 
																GROUP BY R.R_EmpID
															  ) 
											AND Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND IsNull(esd.Shift_Type,0)=1 AND For_Date = @Tmp_Date 
									) Shf ON Shf.Emp_ID = D.Emp_Id
				WHERE	For_date=@Tmp_Date		   
		    
		        
				SET @Tmp_Date = DATEADD(d,1,@tmp_date) 					
			END
			--End Nimesh
		if @Report_For <> 'ABSENT_CON'	
			Begin
			if (@Export_Type='4') --Absent Excel Report Generate --Sumit 17082016
				Begin
					SELECT  E.Alpha_Emp_Code as [Employee Code], E.Emp_Full_Name as [Employee Name]
							,Branch_Name as Branch , Dept_Name as Department,Grd_Name as Grade, Desig_Name as Designation 
							,vs.Vertical_Name as VERTICAL , SV.SubVertical_Name AS SubVertical, BS.Segment_Name AS Business_Segment
							,SM.Shift_Name as [Shift Name], CONVERT(VARCHAR(12),AM.For_Date,103) as [For Date]
							,Am.Status,Am.A_days as [Absent Days]
					From #Att_Muster_with_shift  AM 
						INNER JOIN dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
						INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID , i.Vertical_ID , i.SubVertical_ID , I.Segment_ID
									 FROM dbo.T0095_Increment I  WITH (NOLOCK) 
										INNER JOIN 
											(SELECT max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK) 
											 WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
											 GROUP BY emp_ID
											 ) Qry on I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
									)Q_I ON E.EMP_ID = Q_I.EMP_ID
						LEFT OUTER join		dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID
						INNER JOIN		dbo.T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID
						LEFT OUTER JOIN	dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON Q_I.DEPT_ID = DM.DEPT_ID
						LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK)  ON Q_I.DESIG_ID = DGM.DESIG_ID
						LEFT OUTER JOIN dbo.T0040_Vertical_Segment VS WITH (NOLOCK)  ON Q_I.Vertical_ID = VS.Vertical_ID
						LEFT OUTER JOIN dbo.T0050_SubVertical SV WITH (NOLOCK)  ON Q_I.SubVertical_ID = sv.SubVertical_ID
						LEFT OUTER JOIN dbo.T0040_Business_Segment BS  WITH (NOLOCK) ON Q_I.Segment_ID = BS.Segment_ID
						LEFT OUTER join		dbo.T0040_SHIFT_MASTER SM  WITH (NOLOCK) ON SM.SHIFT_ID = AM.SHIFT_ID
						INNER JOIN		dbo.T0010_COMPANY_MASTER cm WITH (NOLOCK)  on cm.cmp_id = am.cmp_id
						LEFT OUTER join		dbo.T0040_TYPE_MASTER TM WITH (NOLOCK)  ON TM.Type_ID = Q_I.Type_ID						
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						Else e.Alpha_Emp_Code
					End,For_date
				
				
				
				End
			if (@Export_Type='999') --For Auto Leave Adjust with Absent --Hardik 23/03/2020
				Begin
					Select *,0,0 from #Att_Muster_with_shift Where A_days In (1,0.5)
				End
			Else  
				Begin
					Select AM.* , E.Alpha_Emp_Code as Emp_code, E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
						, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
						 ,SM.Shift_Name, cm.cmp_name , cm.cmp_address
						 ,case when isnull(E.Mobile_No,'0') = '0' then '' else E.Mobile_No  end as Mobile_No
						 ,E.Emp_First_Name ,TM.Type_Name 
						 --,Q_ER.Reporting_Manager,
						 ,(Select Stuff((Select E.Alpha_Emp_Code + ' - ' + E.EMP_FULL_NAME --as Reporting_Manager--,Qr_ER.Emp_ID,Qr_ER.R_Emp_ID,E.Cmp_ID,Qr_ER.Effect_Date 
						 From T0080_EMP_MASTER E  WITH (NOLOCK) Left OUTER JOIN 
							 ( SELECT ER.Emp_ID,ER.R_Emp_ID,ER.Cmp_ID,ER.Effect_Date FROM T0090_EMP_REPORTING_DETAIL ER  WITH (NOLOCK) inner join 
								( select max(Effect_Date) as Effect_Date,Emp_ID From T0090_EMP_REPORTING_DETAIL	 WITH (NOLOCK) 
								where Effect_Date <= @TO_Date and Am.Emp_Id = T0090_EMP_REPORTING_DETAIL.Emp_ID
								and Cmp_ID = @Cmp_Id
								group by emp_ID  ) Qry on 
							ER.Emp_ID = Qry.Emp_ID and Er.Effect_Date = Qry.Effect_Date )Qr_ER On Qr_ER.R_Emp_ID=E.Emp_id and Qr_ER.Cmp_ID = E.Cmp_ID  
						WHERE E.Cmp_ID = @Cmp_Id and Q_I.Emp_ID = Qr_ER.Emp_ID FOR XML PATH('')), 1,1,'')) as Reporting_Manager
				 
						 ,vs.Vertical_Name,sb.SubVertical_Name  --added jimit 04042016
					From #Att_Muster_with_shift  AM Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
					INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID,I.Vertical_ID,I.SubVertical_ID FROM dbo.T0095_Increment I  WITH (NOLOCK) inner join 
									( select max(i.Increment_ID) as Increment_ID , i.Emp_ID From dbo.T0095_Increment i WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
										Inner Join #Emp_Cons EC On i.Emp_ID=EC.Emp_ID 
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by i.emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
						E.EMP_ID = Q_I.EMP_ID LEFT OUTER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK)  ON Q_I.DESIG_ID = DGM.DESIG_ID  LEFT OUTER JOIN
						T0040_SHIFT_MASTER SM  WITH (NOLOCK) ON SM.SHIFT_ID = AM.SHIFT_ID inner join
						T0010_COMPANY_MASTER cm WITH (NOLOCK)  on cm.cmp_id = am.cmp_id LEFT OUTER JOIN
						T0040_TYPE_MASTER TM WITH (NOLOCK)  ON TM.Type_ID = Q_I.Type_ID LEFT Outer JOIN
						T0040_Vertical_Segment VS WITH (NOLOCK)  ON vs.Vertical_ID = Q_I.Vertical_ID Left Outer JOIN
						T0050_SubVertical Sb WITH (NOLOCK)  On sb.SubVertical_ID = Q_I.SubVertical_ID	
					
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
					When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
						Else e.Alpha_Emp_Code
					End,For_date	
				End
			--Order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) ,For_date
				End 
		Else if @Report_For = 'ABSENT_CON'
			BEGIN
				
				create table #tmp_Absent_Con(
					Emp_ID numeric, 
					F_DT datetime,
					T_Dt datetime,
					Absent_Days Numeric(18,0)
				)
				
				Insert Into	#tmp_Absent_Con(Emp_ID,F_DT,T_Dt,Absent_Days)
				Select Emp_Id, For_Date,NULL,0 From #Att_Muster_with_shift where status <> 'LWP'
				
				
				
				select  t.Emp_ID, t.F_DT, t1.F_DT as toDate  
				into #tmp_Absent_Con_1
				from #tmp_Absent_Con t
					left outer join (select Emp_ID, t1.F_DT from #tmp_Absent_Con t1
									where	not exists(select 1 from #tmp_Absent_Con t2 where t2.F_DT=dateadd(d, 1, t1.F_DT) AND t2.Emp_ID = t1.Emp_ID)
									) t1 on t.F_DT=t1.F_DT  AND t.Emp_ID=t1.Emp_ID
				
				
				select ROW_NUMBER() over(PARTITION by t1.Emp_ID order by Emp_ID,toDate) as Row_ID, toDate ,t1.Emp_ID
				INTO #tmp_Absent_Con_2
				from #tmp_Absent_Con_1 t1
				group by toDate,Emp_ID
				
				select isnull(t1.toDate,t3.F_DT) as fromDate , t2.toDate ,t3.Emp_ID
				INTO #tmp_Absent_Con_3
				from #tmp_Absent_Con_2 t1 inner join #tmp_Absent_Con_2 t2 on t1.Row_id+1=t2.Row_id and t1.Emp_ID=t2.Emp_ID
					inner join (select DateAdd(d,-1,min(F_DT)) As F_DT,Emp_ID From #tmp_Absent_Con group BY Emp_ID) t3 on t2.Emp_ID=t3.Emp_ID
					
				
				Update 	#tmp_Absent_Con_1
				SET		todate	=  t2.toDate
				from #tmp_Absent_Con_1 t1 inner join #tmp_Absent_Con_3 t2 on t1.F_Dt > t2.FromDate and t1.F_Dt <= t2.ToDate and t1.Emp_ID =t2.Emp_ID
				where t1.toDate is null
				
				-- Added by rohit for contineous absent mail on 08042016
				IF OBJECT_ID('tempdb..##tmp_Absent_Con_1') IS not NULL
				begin 
					drop table ##tmp_Absent_Con_1
				end
				select * into  ##tmp_Absent_Con_1 from #tmp_Absent_Con_1
				-- Ended by rohit for contineous absent mail on 08042016
				
				
				
				select EM.EMp_ID, EM.Alpha_Emp_Code as Emp_code, EM.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
				, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
				 , cm.cmp_name , cm.cmp_address
				 ,case when isnull(EM.Mobile_No,'0') = '0' then '' else EM.Mobile_No  end as Mobile_No
				 ,EM.Emp_First_Name  
				,F_Dt,toDate, (DATEDIFF(d, t1.F_DT, t1.toDate) +1) as Absent_Day ,TM.Type_Name 
				--,Q_ER.Reporting_Manager
				
				
				
				,(Select Stuff((Select E.Alpha_Emp_Code + ' - ' + E.EMP_FULL_NAME --as Reporting_Manager--,Qr_ER.Emp_ID,Qr_ER.R_Emp_ID,E.Cmp_ID,Qr_ER.Effect_Date 
				 From T0080_EMP_MASTER E WITH (NOLOCK)  Left OUTER JOIN 
					 ( SELECT ER.Emp_ID,ER.R_Emp_ID,ER.Cmp_ID,ER.Effect_Date FROM T0090_EMP_REPORTING_DETAIL ER  WITH (NOLOCK) inner join 
						( select max(Effect_Date) as Effect_Date,Emp_ID From T0090_EMP_REPORTING_DETAIL	 WITH (NOLOCK) 
						where Effect_Date <= @TO_Date
						and Cmp_ID = @Cmp_Id
						group by emp_ID  ) Qry on 
					ER.Emp_ID = Qry.Emp_ID and Er.Effect_Date = Qry.Effect_Date )Qr_ER On Qr_ER.R_Emp_ID=E.Emp_id and Qr_ER.Cmp_ID = E.Cmp_ID  
				WHERE E.Cmp_ID = @Cmp_Id and Q_I.Emp_ID = Qr_ER.Emp_ID FOR XML PATH('')), 1,1,'')) as Reporting_Manager
				
				,vs.Vertical_Name,sb.SubVertical_Name  --added jimit 25042016
				from #tmp_Absent_Con_1	t1
				Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON t1.Emp_ID = EM.Emp_ID
				INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID,I.Vertical_ID,I.SubVertical_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				EM.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
				dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK)  ON Q_I.DESIG_ID = DGM.DESIG_ID  INNER JOIN
				T0010_COMPANY_MASTER cm WITH (NOLOCK)  on cm.cmp_id = EM.cmp_id 
				INNER JOIN
				T0040_TYPE_MASTER TM WITH (NOLOCK)  ON TM.Type_ID = Q_I.Type_ID  LEFT Outer JOIN
				--(Select E.Alpha_Emp_Code + ' - ' + E.EMP_FULL_NAME as Reporting_Manager,Qr_ER.Emp_ID,Qr_ER.R_Emp_ID,E.Cmp_ID,Qr_ER.Effect_Date 
				-- From T0080_EMP_MASTER E Left OUTER JOIN 
				--	 ( SELECT ER.Emp_ID,ER.R_Emp_ID,ER.Cmp_ID,ER.Effect_Date FROM T0090_EMP_REPORTING_DETAIL ER inner join 
				--		( select max(Effect_Date) as Effect_Date,Emp_ID From T0090_EMP_REPORTING_DETAIL	
				--		where Effect_Date <= @TO_Date
				--		and Cmp_ID = @Cmp_Id
				--		group by emp_ID  ) Qry on 
				--	ER.Emp_ID = Qry.Emp_ID and Er.Effect_Date = Qry.Effect_Date )Qr_ER On Qr_ER.R_Emp_ID=E.Emp_id and Qr_ER.Cmp_ID = E.Cmp_ID  
				--WHERE E.Cmp_ID = @Cmp_Id)Q_ER On Q_Er.Emp_ID = Q_I.Emp_ID 	Left Outer JOIN
				T0040_Vertical_Segment VS WITH (NOLOCK)  ON vs.Vertical_ID = Q_I.Vertical_ID Left Outer JOIN
				T0050_SubVertical Sb  WITH (NOLOCK) On sb.SubVertical_ID = Q_I.SubVertical_ID	
				
				where t1.F_DT=(select min(F_DT) as F_DT From #tmp_Absent_Con_1 t2 where t1.toDate=t2.toDate and t1.Emp_ID = t2.Emp_ID group by toDate)
					--t1.F_DT=(select min(F_DT) as F_DT From #tmp_Absent_Con_1 t2 where t1.toDate=t2.toDate group by toDate) 
				and (DATEDIFF(d, t1.F_DT, t1.toDate) +1) >= @Con_Absent_Days
				--Added By Jaina 11-08-2016 Start
				and EXISTS (select Data from dbo.Split(@P_Branch, ',') B Where cast(B.data as numeric)=Isnull(Q_I.Branch_ID,0))
				and EXISTS (select Data from dbo.Split(@P_Vertical, ',') VE Where cast(VE.data as numeric)=Isnull(Q_I.Vertical_ID,0))
				and EXISTS (select Data from dbo.Split(@P_SubVertical, ',') S Where cast(S.data as numeric)=Isnull(Q_I.SubVertical_ID,0))
				and EXISTS (select Data from dbo.Split(@P_Department, ',') D Where cast(D.data as numeric)=Isnull(Q_I.Dept_ID,0))    		          			
				--Added By Jaina 11-08-2016 End
				Order by Case When IsNumeric(EM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
				When IsNumeric(EM.Alpha_Emp_Code) = 0 then Left(EM.Alpha_Emp_Code + Replicate('',21), 20)
					Else EM.Alpha_Emp_Code
				End--,For_date
				
			End 
	end

   -- Added by rohit on 24092013
else if @Report_For = 'Monthly Generate'
	BEGIN
		select Attendance.*,cast(monthly_leave_count.monthly_leave as NUMERIC)monthly_leave,
		isnull(Late_sec_Count.month_Less_Work,0)/60 as month_less_Work_minute,month_Less_Work,
		dbo.F_Return_Hours(isnull(Late_sec_Count.month_Less_Work,0) ) as month_less_Work_Hours,
		isnull(mis_punch_Count.Month_mis_punch,0)as Month_mis_punch,
		--,t0080_emp_master.emp_full_name,
		(t0080_emp_master.Emp_First_Name + ' ' + t0080_emp_master.Emp_Second_Name + ' ' + t0080_emp_master.Emp_Last_Name)as emp_full_name
		,t0080_emp_master.alpha_Emp_code
		,@From_Date as P_From_date ,@To_Date as P_To_Date,CM.cmp_name,CM.cmp_address,VE.Branch_Name,VE.Desig_Name,ve.Dept_Name,t0080_emp_master.Alpha_Emp_Code
		,T0080_EMP_MASTER.Emp_First_Name --added jimit 26062015
		from ( select cast(status as numeric) as monthly_uninformed_leave,emp_id from  #Att_Muster where Row_id = 33 ) as Attendance 
		inner join t0080_emp_master WITH (NOLOCK)  on Attendance.emp_id = t0080_emp_master.emp_id
		inner JOIN V0080_EMP_MASTER_INCREMENT_GET VE on VE.Emp_ID = t0080_emp_master.emp_id
		left join
		( select status as monthly_leave,emp_id from  #Att_Muster where Row_id = 34 ) as monthly_leave_count on
		Attendance.emp_id = monthly_leave_count.emp_id
		left join ( select Sum(total_less_Work_Sec) as month_Less_Work,emp_id  from #Emp_Inout
		Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
		and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
		and ( In_Time is not null  or Out_Time is not null  or ab_leave is not null ) group by emp_id ) as Late_sec_Count on 
		Attendance.emp_id = Late_sec_Count.emp_id
		left join 
		( select Count(*) as Month_mis_punch,emp_id  from #Emp_Inout
		Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
		and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
		and ( In_Time is not null  and  isnull(Out_Time,'')='' and isnull(ab_leave,'')='') group by emp_id ) as mis_punch_Count on 
		Attendance.emp_id = mis_punch_Count.emp_id
		left join t0010_company_master CM WITH (NOLOCK)  on t0080_emp_master.cmp_id = cm.cmp_id
	END   
Else if @Report_For = 'For_SAP'  --Mukti(29092017)
		BEGIN	
		--select * from 	#Emp_Inout
			update #Emp_Inout set 
			--Less_Work=dbo.F_Return_Hours(isnull(Duration_sec,0))
			Less_Work=dbo.F_Return_Hours(isnull(Shift_Sec,0)- isnull(Duration_sec,0))
			where AB_Leave in(select Leave_Code from T0040_LEAVE_MASTER WITH (NOLOCK)  where Cmp_ID=@cmp_id and Leave_Paid_Unpaid='U')
			--select * from 	#Emp_Inout
			 CREATE TABLE #Backdated_Leave			 
				  (
					Emp_Id		numeric , 
					For_date	DATETIME,
					period      numeric(18,2),
					Absence	VARCHAR(32),
					[Hours] numeric(18,2)
				   )			
			
			insert into #Backdated_Leave   
			SELECT DISTINCT EI.Emp_Id,LT.For_Date,LT.Back_Dated_Leave,'LWP1',			
			(CAST((dbo.F_Return_Sec(SM.Shift_Dur) / 3600) AS NUMERIC(9,2))*LT.Back_Dated_Leave) from #Emp_Inout EI
			inner join T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  on EI.Emp_ID=LT.Emp_ID			
			inner join T0040_LEAVE_MASTER LM  WITH (NOLOCK) on LT.Leave_ID=LM.Leave_ID AND Leave_Paid_Unpaid ='P'			
			inner join T0040_SHIFT_MASTER SM  WITH (NOLOCK) on SM.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(lt.Cmp_ID,LT.Emp_ID,LT.For_Date)
			where LT.Back_Dated_Leave > 0 and LT.For_Date >= DATEADD(month, -1, @from_date) and LT.For_Date <= DATEADD(month, -1, @to_date)
			
			INSERT INTO #Backdated_Leave(Emp_Id, FOR_DATE, PERIOD, Absence,[Hours])
			select Emp_id,For_Date,Period,'PRNT',[Hours] from #Backdated_Leave
			
			--select * from #Backdated_Leave
			--insert into #In_Out_SAP
			--select * from #Emp_Inout
					
			--insert into #In_Out_SAP 
			select VE.Old_Ref_No,VE.Alpha_Emp_Code,VE.Emp_ID,VE.Emp_Full_Name,EI.for_Date as[Start Date],EI.for_Date as[End Date]
				,Less_Work,
				case when (EIR.Chk_By_Superior=1 AND (isnull(EIR.Half_Full_day,'') ='First Half' or isnull(EIR.Half_Full_day,'') ='Second Half')) then ([Hours]/2) else EI.[Hours] end as [Hours],
				CM.Cmp_Name,CM.Cmp_Id,Absence,VE.Grd_Name,VE.Dept_Name,VE.Desig_Name,VE.Branch_Name,
				TM.[Type_Name],vs.Vertical_Name,sb.SubVertical_Name,CM.Cmp_Address,VE.Emp_First_Name,VE.Emp_code, 
				isnull(eir.Chk_By_Superior,0)as Chk_By_Superior								
			FROM V0080_EMP_MASTER_INCREMENT_GET VE
			--#Emp_Cons EC inner join V0080_EMP_MASTER_INCREMENT_GET VE on VE.Emp_ID=EC.Emp_ID
			--INNER join #Emp_Inout EI on VE.Emp_ID=EI.emp_id 
			INNER JOIN (SELECT	ROW_NUMBER() OVER(PARTITION BY emp_id ORDER BY for_Date) AS ROW_ID, EMP_ID, FOR_DATE, Less_Work,'LWP1' as Absence,
						CAST((dbo.F_Return_Sec(Less_Work) / 3600) AS NUMERIC(9,2)) AS [Hours] 
						FROM	#Emp_Inout
						--LEFT JOIN  T0150_EMP_INOUT_RECORD EIR ON EI.EMP_ID = EIR.EMP_ID AND EI.For_date=EIR.For_Date 
						WHERE  for_date >= @from_date and for_date <= @to_date AND dbo.F_Return_Sec(Less_Work) > 1200 AND LEN(Less_Work) = 5
						UNION 
						SELECT	ROW_NUMBER() OVER(PARTITION BY emp_id ORDER BY for_Date) + 100 AS ROW_ID,EMP_ID, FOR_DATE, '00:00' AS Less_Work,Absence,[hours]
						FROM	#Backdated_Leave) EI ON VE.Emp_ID=EI.emp_id
			--LEFT JOIN(
			--	select Chk_By_Superior,EMP_ID,For_date from  T0150_EMP_INOUT_RECORD where IsNull(Chk_By_Superior,0) = 1
			--	)EIR ON EI.EMP_ID = EIR.EMP_ID AND EI.For_date=EIR.For_Date 
			LEFT JOIN  T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK)  ON EI.EMP_ID = EIR.EMP_ID AND EI.For_date=EIR.For_Date 
			--inner join #Backdated_Leave BL on BL.Emp_Id=VE.Emp_ID			
			inner join t0010_company_master CM WITH (NOLOCK)  on VE.cmp_id = cm.cmp_id	
			left join T0040_TYPE_MASTER TM WITH (NOLOCK)  ON TM.[Type_ID] = VE.[Type_ID]	
			left join T0040_Vertical_Segment VS WITH (NOLOCK)  ON vs.Vertical_ID = VE.Vertical_ID 
			left join T0050_SubVertical Sb  WITH (NOLOCK) On sb.SubVertical_ID = VE.SubVertical_ID
			where	len(Less_Work) = 5  
			and NOT (IsNull(EIR.Chk_By_Superior,0) = 1 AND isnull(EIR.Half_Full_day,'') = 'Full Day')
			ORDER BY EI.ROW_ID
			
			
		end
else if @Report_For = 'Absent History'   -- Added By Gadriwala Muslim 08082014
	Begin
	
	  CREATE TABLE #Att_Muster_with_shift_History
				  (
						Emp_Id		numeric , 
						Cmp_ID		numeric,
						For_Date	datetime,
						Status		varchar(10),
						Leave_Count	numeric(5,1),
						WO_HO		varchar(3),
						Status_2	varchar(10),
						Row_ID		numeric ,
						WO_HO_Day	numeric(4,1) default 0,
						P_days		numeric(12,3) default 0,
						A_days		numeric(5,1) default 0,
						Join_Date	Datetime default null,
						Left_Date	Datetime default null,
						GatePass_Days numeric(18,2) default 0, --Added by Gadriwala Muslim 07042015
						Late_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
						Early_deduct_Days numeric(18,2) default 0,  --Added by Gadriwala Muslim 07042015
						shift_id	numeric
				  )
				
				declare @cur_shift_id_AB_History numeric
				declare @cur_for_date_AB_History datetime
				declare @cur_emp_id_AB_History numeric
				
				set @cur_emp_id_AB_History = 0 
				set @cur_shift_id_AB_History = 0
				set @cur_for_date_AB_History = NULL
				
				insert into #Att_Muster_with_shift_History
				select *,0 from #Att_Muster  where for_date >= @from_date and for_date <= @to_date and A_days > 0--status = 'A' --comment by hasmukh on 14122012 for half day absent not was not shown before
				
				/*Commented by Nimesh 20 May 2015
				declare curShift cursor for
					select for_date,Shift_id,esd.emp_id from T0100_Emp_Shift_Detail ESD inner join
					#Emp_Cons ec on ec.emp_id = esd.emp_id where for_date <= @to_date
				open curShift
					fetch curShift into  @cur_for_date_AB_History,@cur_shift_id_AB_History,@cur_emp_id_AB_History
				while @@fetch_status = 0
					begin 
						
						update #Att_Muster_with_shift_History set shift_id = @cur_shift_id_AB_History where for_date >= @cur_for_date_AB_History and emp_id =@cur_emp_id_AB_History
						
						fetch curShift into  @cur_for_date_AB_History,@cur_shift_id_AB_History	,@cur_emp_id_AB_History	
					end
					
				 close curShift                    
				 deallocate curShift    
				*/
				
				--Add by Nimesh 21 April, 2015
				--This sp retrieves the Shift Rotation as per given employee id and effective date.
				--it will fetch all employee's shift rotation detail if employee id is not specified.
				--IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
				--	Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
				--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
				Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @to_date, @constraint
				
				DECLARE @Tmp_Date_H DATETIME;
				SET @Tmp_Date_H = @From_Date;
				
				WHILE (@Tmp_Date_H <= @To_Date) BEGIN	
					
					--Updating default shift info From Shift Detail
					UPDATE	#Att_Muster_with_shift_History SET SHIFT_ID = Shf.Shift_ID
					FROM	#Att_Muster_with_shift_History D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
					FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)  INNER JOIN  
							(SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)  
								WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @Tmp_Date_H GROUP BY Emp_ID) S ON 
								esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
							Shf.Emp_ID = D.EMP_ID 
					WHERE	D.For_Date=@Tmp_Date_H
														
					--Updating Shift ID From Rotation
					UPDATE	#Att_Muster_with_shift_History 
					SET		SHIFT_ID=SM.SHIFT_ID
					FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK)  ON R.R_ShiftID=SM.Shift_ID					
					WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date_H) As Varchar) 
							AND Emp_Id=R.R_EmpID AND For_Date=@Tmp_Date_H
							AND R.R_Effective_Date=(
													SELECT	MAX(R_Effective_Date)
													FROM	#Rotation R1 
													WHERE	R1.R_EmpID=Emp_Id AND R_Effective_Date<=@Tmp_Date_H
													) 
									 
								
					--Updating Shift ID For Shift_Type=0
					UPDATE	#Att_Muster_with_shift_History
					SET		SHIFT_ID=Shf.SHIFT_ID
					FROM	#Att_Muster_with_shift_History D 
							INNER JOIN (
										SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
										FROM	T0100_EMP_SHIFT_DETAIL esd  WITH (NOLOCK) 
										WHERE	esd.Emp_ID IN (
																SELECT	R.R_EmpID 
																FROM	#Rotation R
																WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date_H) As Varchar) 
																GROUP BY R.R_EmpID
															  ) 
												AND Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date_H 
										) Shf ON Shf.Emp_ID = D.Emp_Id
					WHERE	For_date=@Tmp_Date_H
					
					--Updating Shift ID For Shift_Type=1
					UPDATE	#Att_Muster_with_shift_History
					SET		SHIFT_ID=Shf.SHIFT_ID
					FROM	#Att_Muster_with_shift_History D 
							INNER JOIN (
										SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
										FROM	T0100_EMP_SHIFT_DETAIL esd  WITH (NOLOCK) 
										WHERE	esd.Emp_ID NOT IN (
																	SELECT	R.R_EmpID 
																	FROM	#Rotation R
																	WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date_H) As Varchar) 
																	GROUP BY R.R_EmpID
																  ) 
												AND Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND IsNull(esd.Shift_Type,0)=1 AND For_Date = @Tmp_Date_H 
										) Shf ON Shf.Emp_ID = D.Emp_Id
					WHERE	For_date=@Tmp_Date_H

					
			        
					SET @Tmp_Date_H = DATEADD(d,1,@Tmp_Date_H) 					
				END
				--End Nimesh
				
				Select AM.*
				From #Att_Muster_with_shift_History  AM Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
				INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
					E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM  WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
					dbo.T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM  WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK)  ON Q_I.DESIG_ID = DGM.DESIG_ID  INNER JOIN
					T0040_SHIFT_MASTER SM  WITH (NOLOCK) ON SM.SHIFT_ID = AM.SHIFT_ID inner join
					T0010_COMPANY_MASTER cm  WITH (NOLOCK) on cm.cmp_id = am.cmp_id
				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				End	,For_date
				--Order by RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) ,For_date
			
		
	 
		END
	else if @Report_For = 'Absent_Cutoff'
		begin			
			insert into #Att_Muster_with_shift
			select *,0 from #Att_Muster  where for_date >= @from_date and for_date <= @to_date and A_days > 0--status = 'A' --comment by hasmukh on 14122012 for half day absent not was not shown before
		end
	-- ended by rohit on 24092013
		----PRINT 'STATE 30 :' + CONVERT(VARCHAR(20), GETDATE(), 114);
	ELSE IF @Report_For = 'Consolidated'	--Added by Nimesh Parmar for Consolidated Report
		BEGIN							
				update #Att_Muster
				set Status = Status + CAST('-0.5' as varchar)
				where Status_2 = '0.50' --and Leave_Count = 0.5
				
												
				INSERT INTO #ATT_CONS (EMP_ID,CMP_ID,FOR_DATE,[STATUS],LEAVE_COUNT,ROW_ID,WO_HO_DAY,P_DAYS,A_DAYS,LATE_DEDUCT_DAYS,EARLY_DEDUCT_DAYS,
						EMP_CODE,EMP_FULL_NAME,BRANCH_NAME,DEPT_NAME,GRD_NAME,DESIG_NAME,
						P_FROM_DATE,P_TO_DATE,BRANCH_ID,DESIG_DIS_NO,SHIFT_ID)
				Select  AM.Emp_Id,AM.Cmp_Id,AM.For_Date,AM.[Status],AM.Leave_Count,AM.Row_ID,AM.WO_HO_Day,AM.P_days,AM.A_days,AM.Late_deduct_Days,AM.Early_deduct_Days,
						E.Alpha_Emp_code,E.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name , DM.Dept_Name ,GM.Grd_Name , DGM.Desig_Name,
						@From_Date AS P_From_date ,@To_Date AS P_To_Date ,BM.BRANCH_ID,DGM.Desig_Dis_No,D.Shift_ID
				From	#Att_Muster  AM 
						INNER JOIN dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
						INNER JOIN #Emp_Cons EC on EC.Emp_ID = E.Emp_ID	
						LEFT OUTER JOIN #Data D ON AM.Emp_Id=D.Emp_Id AND AM.For_Date=D.For_date
						INNER JOIN T0095_INCREMENT I WITH (NOLOCK)  ON EC.Increment_ID=I.Increment_ID
						INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  ON I.Grd_Id = gm.Grd_ID 
						INNER JOIN  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON I.BRANCH_ID = BM.BRANCH_ID 
						LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON I.DEPT_ID = DM.DEPT_ID 
						LEFT OUTER JOIN  dbo.T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON I.DESIG_ID = DGM.DESIG_ID 
	
				INSERT INTO #ATT_CONS (EMP_ID,CMP_ID,FOR_DATE,[STATUS],LEAVE_COUNT,ROW_ID,WO_HO_DAY,P_DAYS,A_DAYS,LATE_DEDUCT_DAYS,EARLY_DEDUCT_DAYS,
						EMP_CODE,EMP_FULL_NAME,BRANCH_NAME,DEPT_NAME,GRD_NAME,DESIG_NAME,
						P_FROM_DATE,P_TO_DATE,BRANCH_ID,DESIG_DIS_NO,SHIFT_ID)
	
				Select  AM.Emp_Id,AM.Cmp_Id,T.FOR_DATE,NULL,AM.Leave_Count,AM.Row_ID,AM.WO_HO_Day,AM.P_days,AM.A_days,AM.Late_deduct_Days,AM.Early_deduct_Days,
						AM.EMP_CODE,AM.Emp_Full_Name as Emp_Full_Name,AM.Branch_Name , AM.Dept_Name ,AM.Grd_Name , AM.Desig_Name,
						@From_Date AS P_From_date ,@To_Date AS P_To_Date ,AM.BRANCH_ID,AM.Desig_Dis_No,NULL
				From	#ATT_CONS AM 
						INNER JOIN (SELECT EMP_ID, MAX(ROW_ID) AS ROW_ID FROM #ATT_CONS GROUP BY EMP_ID) AM1 ON AM.ROW_ID=AM1.ROW_ID AND AM.EMP_ID=AM1.EMP_ID
						CROSS APPLY (
										SELECT	DATEADD(d, T.ROW_ID, @FROM_DATE) AS FOR_DATE 
										FROM	(
													SELECT	TOP 366 (ROW_NUMBER() OVER (ORDER BY OBJECT_ID) -1) AS ROW_ID
													FROM	SYS.OBJECTS 
												) T																										
									) T 
						
				WHERE	NOT EXISTS(SELECT FOR_DATE FROM #ATT_CONS A WHERE A.EMP_ID=AM.EMP_ID AND A.FOR_DATE=T.FOR_DATE)
						AND T.FOR_DATE <= @TO_DATE
	
				--UPDATE	A
				--SET		LEAVE_COUNT = L_COUNT,
				--		[STATUS] = LEAVE_CODE
				--FROM	#ATT_CONS A 
				--		INNER JOIN (
				--						SELECT	SUM(LEAVE_USED) AS L_COUNT, LEAVE_CODE, LT.EMP_ID, FOR_DATE
				--						FROM	T0140_LEAVE_TRANSACTION LT INNER JOIN T0040_LEAVE_MASTER LM ON LT.Leave_ID=LM.Leave_ID 
				--								INNER JOIN #EMP_CONS E ON LT.Emp_ID=E.Emp_ID 
				--						WHERE	FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE AND LT.CMP_ID=@Cmp_ID
				--						GROUP BY LEAVE_CODE, LT.EMP_ID, FOR_DATE
				--					) L ON A.EMP_ID=L.Emp_ID AND A.FOR_DATE=L.For_Date
	
		END	
	ELSE IF @Report_For = 'ATT_STATUS'
		BEGIN
		
		
					---Added By Jimit  23022018 for RK Calculating Payable Paid Days
					INSERT INTO #Att_Muster	(Emp_Id,Cmp_ID,For_Date,[Status],Leave_Count,WO_HO,Status_2,Row_ID,WO_HO_Day,
							P_days,A_days,Join_Date,Left_Date,GatePass_Days,Late_deduct_Days,Early_deduct_Days)
					SELECT	Emp_Id,Cmp_ID,DateAdd(d,1,For_Date),0.00,NULL,NULL,NULL,39,0.00,0.00,0.00,Join_Date,Left_Date,0.00,0.00,0.00
					FROM	#Att_Muster
					WHERE	ROW_ID=38
	
		
					DECLARE @WO_Inc1 as tinyint,
							@HO_Inc1 as tinyint,
							@Payable_Present_days1 numeric(18,2)
					
					DECLARE @WeekOff_Days1 numeric(18,2),
							@Holiday_Days1 numeric(18,2),
							@LC_Days1 numeric(18,2),
							@GP_Days1 numeric(18,2),
							@Paid_Leave1 numeric(18,2),
							@Present_Days1 numeric(18,2);
					
					DECLARE @EmpID1 Numeric(18,0),
							@CmpID1 Numeric(18,0),
							@BranchID1 Numeric(18,0);
					
					DECLARE cur_PD CURSOR
					FAST_FORWARD 
					FOR 
					SELECT	A.Emp_ID,A.Cmp_ID,I.Branch_ID 
					FROM	#Att_Muster A INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON A.Cmp_ID=E.Cmp_ID AND A.Emp_Id=E.Emp_ID			
							INNER JOIN (SELECT Branch_ID,Emp_ID,Cmp_ID 
										FROM  T0095_INCREMENT I  WITH (NOLOCK) 
										WHERE I.Increment_ID=(SELECT MAX(Increment_ID)
															  FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
															  WHERE I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID
															  )
										) I ON E.Emp_ID=I.Emp_ID AND E.Cmp_ID=I.Cmp_ID 					
					WHERE ISNULL(E.Extra_AB_Deduction,0) = 0 AND A.ROW_ID=38;
					OPEN cur_PD
					FETCH NEXT FROM cur_PD INTO @EmpID1,@CmpID1,@BranchID1
					WHILE (@@FETCH_STATUS = 0)
					BEGIN				
						set @WO_Inc1 = 0
						set @HO_Inc1 = 0
						set @Payable_Present_days1 = 0
						
						SELECT	@HO_Inc1 =  Inc_Holiday,@WO_Inc1 = Inc_Weekoff ,@Late_Early_Ded_Combine = Isnull(Is_Chk_Late_Early_Mark,0)
						FROM	T0040_GENERAL_SETTING  WITH (NOLOCK) 
						WHERE	Branch_ID = @BranchID1
								AND For_Date = (SELECT	MAX(For_Date)
												FROM	dbo.T0040_GENERAL_SETTING  WITH (NOLOCK) 
												WHERE	For_Date <= @To_Date AND Branch_ID = @BranchID1 
														AND Cmp_ID = @Cmp_ID
												)   
						
						
						
						Select @WeekOff_Days1=WeekOff_Days,@Holiday_Days1=Holiday_Days,@LC_Days1=LC_Days,@GP_Days1=GP_Days,@Paid_Leave1=Paid_Leave,@Present_Days1=Present_Days
						FROM	(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS WeekOff_Days FROM #Att_Muster A Where Cmp_ID=@CmpID1 AND Emp_Id=@EmpID1 AND Row_ID=35) W,
								(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS Holiday_Days FROM #Att_Muster A Where Cmp_ID=@CmpID1 AND Emp_Id=@EmpID1 AND Row_ID=36) HO,
								(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS LC_Days FROM #Att_Muster A Where Cmp_ID=@CmpID1 AND Emp_Id=@EmpID1 AND Row_ID=37) LC,
								(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS GP_Days FROM #Att_Muster A Where Cmp_ID=@CmpID1 AND Emp_Id=@EmpID1 AND ISNULL([Row_ID],0)=38) GP,
								(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS Paid_Leave FROM #Att_Muster A Where Cmp_ID=@CmpID1 AND Emp_Id=@EmpID1 AND ISNULL([Row_ID],0)=34) L,
								(SELECT SUM(Cast([Status] AS NUMERIC(18,2))) AS Present_Days FROM #Att_Muster A Where Cmp_ID=@CmpID1 AND Emp_Id=@EmpID1 AND ISNULL([Row_ID],0)=32) P
						
						
						
						set @Payable_Present_days1 = isnull(@Present_days1,0) 
						
						IF ISNULL(@HO_Inc1,0) = 1
							SET @Payable_Present_days1 = @Payable_Present_days1 +  ISNULL(@Holiday_Days1,0)
							
						IF ISNULL(@Wo_Inc1,0) = 1
							SET @Payable_Present_days1 = @Payable_Present_days1 +  ISNULL(@WeekOff_Days1,0)	
							
						SET	@Payable_Present_days1 = (@Payable_Present_days1 + ISNULL(@Paid_Leave1,0)) - (ISNULL(@LC_Days1,0) + ISNULL(@GP_Days1,0))
						
						
						IF @Payable_Present_days1 < 0 
							SET @Payable_Present_days1	= 0
						 
						UPDATE	#Att_Muster SET [Status]= @Payable_Present_days1
						WHERE	Emp_Id = @EmpID1 AND Cmp_ID=@CmpID1 AND Row_ID=39
						
						FETCH NEXT FROM cur_PD INTO @EmpID1,@CmpID1,@BranchID1
					END	
				--------Ended---------------------------------------
			INSERT	INTO #EMP_ATTENDANCE(EMP_ID,FOR_DATE,ROW_ID,CAPTION,STATUS1,STATUS2,R_TYPE)
			SELECT	Emp_Id,For_Date,Row_ID,REPLACE(RIGHT(CONVERT(CHAR(10), For_Date, 102),5), '.','_'), [Status],Status_2, CASE WHEN For_Date > @To_Date THEN 1 ELSE 0 END 
			FROM	#Att_Muster
			ORDER BY Emp_Id, For_Date,Row_ID
		END
	ELSE IF @Report_For = 'Form - D'
		begin
		--SS
			IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Dishman')) --Added Condition for Dishman Company show Absent As LWP 30082017
                 BEGIN
					Update #Att_Muster SET Status = 'LWP' Where Status = 'A' 
                 End
			
			Update #Att_Muster set Status = DATEDIFF(dd,@From_Date,@To_Date) + 1 where Row_Id = 37
			
			
			Insert Into #Att_Muster
			SELECT	Emp_Id, 
					Cmp_ID,
					DateAdd(D,1,For_Date),
					NULL,
					NULL,
					NULL,
					NULL,
					39,
					0,
					0, 
					0,
					Join_Date,
					Left_Date,
					0,
					0,
					0 
			from	#Att_Muster
			WHERE   ROW_Id = 38
			
			
			
			delete from #Att_Muster where Row_id in (34,38)
			
			UPdate  A
			SET  [Status] = dbo.F_Return_Hours (OT)
			FRom  #Att_Muster A 
			      left join 
							(	SELECT	(Sum(isnull(Approved_OT_Sec,0)) + Sum(isnull(Approved_WO_OT_Sec,0)) + Sum(isnull(Approved_HO_OT_Sec,0))) AS OT ,EMP_Id
								FROM	T0160_OT_APPROVAL
								WHERE	For_Date Between @From_Date AND @To_Date
								GROUP BY EMP_Id
							)Q ON Q.EMP_ID = A.EMP_ID
			WHERE  A.Row_Id = 39
			      
			Insert Into #Att_Muster
			SELECT	Emp_Id, 
					Cmp_ID,
					DateAdd(D,1,For_Date),
					NULL,
					NULL,
					NULL,
					NULL,
					40,
					0,
					0, 
					0,
					Join_Date,
					Left_Date,
					0,
					0,
					0 
			from	#Att_Muster
			WHERE   ROW_Id = 39
			
			Select AM.Emp_Id
				,AM.Emp_Id,AM.Cmp_ID,AM.For_Date,cast(AM.[Status] as varchar(10)) as [Status],
				--AM.Leave_Count,
				CAST(ROUND(AM.Leave_Count,2) as numeric(18,2)) as Leave_Count,
				AM.WO_HO,AM.Status_2,AM.Row_ID,AM.WO_HO_Day,
				--round(AM.P_days,2,0),
				CAST(ROUND(AM.P_days,2) as numeric(18,2)) as P_days,
				--AM.A_days,
				CAST(ROUND(AM.A_days,2) as numeric(18,2)) as A_days,
				AM.Join_Date,AM.Left_Date,AM.GatePass_Days,AM.Late_deduct_Days,AM.Early_deduct_Days
				,E.Emp_code,cast( E.Alpha_Emp_Code as varchar(20)) + ' - '+E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name,Cmp_Name
				, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.BRANCH_ID
				,@leave_Footer As Leave_Footer ,E.Enroll_No
				,IsNUll(DM.Dept_Dis_no,0) as Dept_Dis_no ,Tm.[Type_Name]  --added jimit 05082015
				,DGM.Desig_Dis_No   --added jimit 24082015
				,VS.Vertical_Name,SV.SubVertical_Name     --added jimit 27042016
				,SB.SubBranch_Name --Added by Hardik 26/03/2018 for Kheti Bank
				--,dbo.F_Return_Hours (OT_SEC) OT_HOurs
			From  #Att_Muster  AM 
			 Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID
			INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.type_ID, I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID FROM dbo.T0095_Increment I WITH (NOLOCK)  inner join 
							(	select max(Increment_ID) as Increment_ID , i2.Emp_ID 
								From dbo.T0095_Increment i2 WITH (NOLOCK) 	-- Ankit 08092014 for Same Date Increment
									 inner join #Att_Muster a on i2.Emp_ID=a.Emp_Id
								where Increment_Effective_date <= @To_Date
										and i2.Cmp_ID = @Cmp_ID
								group by i2.emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
				E.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM  WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
				dbo.T0030_BRANCH_MASTER BM  WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 			
				dbo.T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
				dbo.T0040_Type_Master tm WITH (NOLOCK)  on Q_I.Type_ID = tm.Type_ID LEFT outer JOIN
				T0040_Vertical_Segment VS WITH (NOLOCK) 	On Vs.Vertical_ID = Q_I.vertical_Id LEFT OUTER JOIN
				T0050_SubVertical SV  WITH (NOLOCK) ON sv.SubVertical_ID = Q_I.SubVertical_ID LEFT OUTER JOIN
				T0050_SubBranch SB  WITH (NOLOCK) ON SB.SubBranch_ID = Q_I.SubBranch_ID
				INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK)  ON  E.Cmp_ID=C.Cmp_Id
				
				--#Data DT on AM.EMp_id = DT.Emp_Id and AM.For_Date = DT.For_date
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End,For_date
			
			 
			
			If Object_Id('tempdb..#PivotTable') Is not null 
				DROP TABLE #PivotTable
			
			
			CREATE TABLE #PivotTable
			(
				EMP_ID NUMERIC,
				ROW_Id VARCHAR(5),
				STATUS VARCHAR(10),
				OT     NUMERIC(18,0)
			)
			
			
			INSERT INTO #PivotTable
			SELECT AM.EMP_ID,Row_Id,STATUS,0
			From	#Att_Muster  AM 
					Inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK)  ON AM.EMP_ID = E.EMP_ID	
			WHERE  ROW_ID > 31					
			Order by ROW_ID,Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End,For_date
			
			UPDATE	T
			SET		T.Ot = Q.OT
			FROM	#PivotTable T
					INNER JOIN (
									SELECT	(Sum(isnull(Approved_OT_Sec,0)) + Sum(isnull(Approved_WO_OT_Sec,0)) + Sum(isnull(Approved_HO_OT_Sec,0))) AS OT ,EMP_Id
									FROM	T0160_OT_APPROVAL
									WHERE	For_Date Between @From_Date AND @To_Date
									GROUP BY EMP_Id
					            )Q ON Q.EMP_ID = T.EMP_ID
			
			--SELECT * FROM #PivotTable
			
			Declare @query1 VARCHAR(MAX)
			Declare @COL AS VARCHAR(MAX)
			Declare @SUM_COL AS VARCHAR(MAX)
			
			IF OBJECT_ID('tempdb..#TempPivotTable') IS NOT NULL
				Begin
					DROP TABLE #TempPivotTable
				End
			
		CREATE TABLE #TempPivotTable
			(
				EMP_Id 		Varchar(10),
				OT			Varchar(10),				
				P_Day		NUMERIC(18,2),  --32
				A_Day		NUMERIC(18,2),  --33
				W_Day		NUMERIC(18,2),  --35
				H_Day		NUMERIC(18,2),  --36
				T_Day		As Cast(ROUND(P_Day + A_Day + W_Day + H_Day ,0) As Numeric(5,2))		
				
			)
			
			--SET @COL =	   'P_Day,A_Day,W_Day,H_Day,T_Day'
			SET @SUM_COL = 'SUM(P_Day),SUM(A_Day),SUM(W_Day),SUM(H_Day)'
			
			set @query1 = '	 INSERT Into #TempPivotTable
							 SELECT * 
							 FROM (
									 SELECT * FROM
									 (
										SELECT	CAST(Emp_Id AS VARCHAR(10)) Emp_Id,Row_Id,
												 Status,CAST(OT AS VARCHAR(10)) OT 
										from	#PivotTable										
									 ) x
									pivot 
									(
										MAX(Status) for Row_Id in ([32],[33],[35],[36])										
									) p 									
								)Q 
								' 
			EXEC (@query1)	
			
			set @query1 = ' INSERT INTO #TempPivotTable
							SELECT ''Total'',dbo.F_Return_Hours(SUM(CAST(OT AS NUMERIC(18,0)))),' + @SUM_COL + '
							FROM   #TempPivotTable'
				
			EXEC (@query1)
			
			select	* 
			from	#TempPivotTable
			WHERE	EMp_Id = 'Total'
			
					
		END
RETURN




