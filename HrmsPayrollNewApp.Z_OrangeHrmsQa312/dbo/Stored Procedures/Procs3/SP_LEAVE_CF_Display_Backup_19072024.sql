CREATE PROCEDURE [dbo].[SP_LEAVE_CF_Display_Backup_19072024]  
	@leave_Cf_ID NUMERIC(18,0) output,  
	@Cmp_ID  NUMERIC ,  
	@From_Date Datetime ,  
	@To_Date Datetime ,  
	@For_Date Datetime ,  
	@Branch_ID NUMERIC,  
	@Cat_ID  NUMERIC,  
	@Grd_ID  NUMERIC,  
	@Type_ID NUMERIC,  
	@Dept_ID NUMERIC,  
	@Desig_ID NUMERIC,  
	@Emp_Id  NUMERIC ,  
	@Constraint varchar(max)='',  
	@P_LeavE_ID NUMERIC, 
	@Is_FNF int = 0,   --Added by Falak on 02-FEB-2011 
	@Inc_HOWO int=0,
	@Segment_ID		NUMERIC = 0,
	@subBranch_ID		NUMERIC = 0,
	@Vertical_ID		NUMERIC = 0,
	@SubVertical_ID	NUMERIC = 0,
	@CallFor	Varchar(24) = ''
AS  
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF; 
   
	/*
		@CallFor  =  ''					:: Default Value
		@CallFor  =  'ADD_EMPLOYEE'		:: When user creates a new employee with advance leave balance then parameter @CallFor value will be 'ADD_EMPLOYEE'
	*/
   
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
   
	IF @P_LeavE_ID =0  
		SET @P_LeavE_ID = NULL  
 
 	IF @Segment_ID	 = 0
		SET @Segment_ID	 = NULL
	IF @subBranch_ID = 0
		SET @subBranch_ID = NULL
	IF @Vertical_ID	 = 0
		SET @Vertical_ID = NULL
	IF @SubVertical_ID	= 0	
		SET @SubVertical_ID = NULL
 
	---- To Calculate Present Days
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
		P_days    NUMERIC(18,2) DEFAULT 0,    
		OT_Sec    NUMERIC DEFAULT 0,
		In_Time DATETIME DEFAULT null,
		Shift_Start_Time DATETIME DEFAULT null,
		OT_Start_Time NUMERIC DEFAULT 0,
		Shift_Change tinyint DEFAULT 0 ,
		Flag Int DEFAULT 0  ,
		Weekoff_OT_Sec  NUMERIC DEFAULT 0,
		Holiday_OT_Sec  NUMERIC DEFAULT 0	,
		Chk_By_Superior NUMERIC DEFAULT 0,
		IO_Tran_Id	   NUMERIC DEFAULT 0,
		OUT_Time DATETIME,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time NUMERIC DEFAULT 0,		--Ankit 16112013 
		Working_Hrs_St_Time tinyint DEFAULT 0, --Hardik 14/02/2014
		Working_Hrs_END_Time tinyint DEFAULT 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18,2) DEFAULT 0 -- Add by Gadriwala Muslim 05012014	  
	)    
	---- END ----   


    ---For SLS Client (Fix 2 Year)
	CREATE TABLE #CF_Slab_FixYear
	(
		From_Month NUMERIC(18,2),
		To_Month NUMERIC(18,2),
		CF_Days NUMERIC(18,2)
	)

	INSERT INTO #CF_Slab_FixYear ( From_Month,To_Month,CF_Days) VALUES (1,3,1)
	INSERT INTO #CF_Slab_FixYear ( From_Month,To_Month,CF_Days) VALUES (12,12,1)
	INSERT INTO #CF_Slab_FixYear ( From_Month,To_Month,CF_Days) VALUES (8,11,2)
	INSERT INTO #CF_Slab_FixYear ( From_Month,To_Month,CF_Days) VALUES (4,7,3)

	CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   	
	 
	DECLARE @Multi_Branch_ID VARCHAR(512)
	select @Multi_Branch_ID = Multi_Branch_ID FROM T0040_Leave_Master WITH (NOLOCK) WHERE Leave_ID=@P_LeavE_ID

	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@FROM_Date=@FROM_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,
			@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@Constraint,@Sal_Type=0,@Salary_Cycle_ID=0,@Segment_ID=@Segment_ID,
			@Vertical_Id=@Vertical_Id,@SubVertical_Id = @SubVertical_Id,@SubBranch_Id=@SubBranch_Id,@New_Join_emp=0,@Left_Emp=0,@SalScyle_Flag=2


	--Following Line Added By Nimesh (On 13-Nov-2018 for Genchi Client) Only those employees' leave should be carry forwarded whose branch is included in Leave Master
	IF (LEN(@Multi_Branch_ID) > 0)
		DELETE EC FROM #EMP_CONS EC	
		WHERE 	NOT EXISTS(SELECT 1 FROM dbo.Split(@Multi_Branch_ID, '#') T WHERE Cast(Data As INT) = EC.Branch_ID)

	DECLARE @HasTable Bit
	SET @HasTable = 1
	IF OBJECT_ID('tempdb..#LEAVE_CF_DETAIL') IS NULL
		BEGIN
			SET @HasTable = 0
			CREATE TABLE #LEAVE_CF_DETAIL
			(
				[LEAVE_CF_ID] [NUMERIC](18, 0) NOT NULL identity(1,1),
				[Cmp_ID] [NUMERIC](18, 0) NOT NULL,
				[Emp_ID] [NUMERIC](18, 0) NOT NULL,
				[Leave_ID] [NUMERIC](18, 0) NOT NULL,
				[CF_For_Date] [DATETIME] NOT NULL,
				[CF_From_Date] [DATETIME] NOT NULL,
				[CF_To_Date] [DATETIME] NOT NULL,
				[CF_P_Days] [NUMERIC](18, 2) NOT NULL,
				[CF_Leave_Days] [NUMERIC](22, 8) NOT NULL,
				[CF_Type] [varchar](200) NOT NULL,
				[Exceed_CF_Days] [NUMERIC](22, 8) NULL,
				[Leave_CompOff_Dates] [nvarchar](MAX) NULL,
				[Is_Fnf] [tinyint] NOT NULL,
				[Advance_Leave_Balance] [NUMERIC](18, 2) NOT NULL DEFAULT 0,
				[Advance_Leave_Recover_balance] [NUMERIC](18, 2) NOT NULL DEFAULT 0,
				[Is_Advance_Leave_Balance][tinyint] NOT NULL DEFAULT 0
			)
		END 


	DECLARE @Leave_ID NUMERIC   
	DECLARE @Leave_Max_Bal NUMERIC(18,2)  
	DECLARE @Leave_CF_Type VARCHAR(200)  
	DECLARE @Leave_PDays NUMERIC(12,2)  
	DECLARE @Leave_get_Against_PDays NUMERIC(12,2)   --Change by Jaina10-11-2017
	DECLARE @Leave_Precision NUMERIC(2)   
	DECLARE @P_Days NUMERIC(18,2)  
	DECLARE @Leave_CF_Days NUMERIC(5,2)  
	DECLARE @Leave_Closing NUMERIC(12,2)  
	DECLARE @CF_Full_Days NUMERIC(1,0)  
	DECLARE @CF_Days NUMERIC(12,2)  
	DECLARE @C_Paid_Days NUMERIC(5,2)
	DECLARE @Weekoff_Days NUMERIC(12,2)
	DECLARE @UnPaid_Days NUMERIC(12,2)
	DECLARE @Working_Days NUMERIC(12,2)
	DECLARE @Leave_Paid_Days NUMERIC(5,2)
	--DECLARE @Leave_CF_ID NUMERIC   
  
	----Alpesh 30-Apr-2012
	DECLARE @Is_Cancel_Holiday  NUMERIC(1,0)    
	DECLARE @Is_Cancel_Weekoff  NUMERIC(1,0)
	DECLARE @Left_Date		DATETIME     
	DECLARE @StrHoliday_Date  VARCHAR(MAX)    
	DECLARE @StrWeekoff_Date  VARCHAR(MAX)
	DECLARE @Cancel_Weekoff	NUMERIC(18, 0)
	DECLARE @Cancel_Holiday   NUMERIC(18, 0)

	DECLARE @Emp_Left_Date	DATETIME
  
	DECLARE @Is_CF_On_Sal_Days tinyint
	DECLARE @Days_As_Per_Sal_Days tinyint
	DECLARE @Max_Accumulate_Balance	NUMERIC(18, 2)
	DECLARE @Min_Present_Days	 NUMERIC(18, 2)
	DECLARE @CF_Effective_Date DATETIME
	DECLARE @CF_Type_ID		 NUMERIC(18, 0)
	DECLARE @Reset_Months		NUMERIC(18, 0)
	DECLARE @Duration			VARCHAR(200)
	DECLARE @CF_Months			NVARCHAR(50)
	DECLARE @Release_Month	 NUMERIC(18, 0)
	DECLARE @Reset_Month_String nVARCHAR(50)
	DECLARE @MinPDays_Type tinyint  -- Added by Gadriwala Muslim 10022015
	DECLARE @Date_Of_Join DATETIME -- Added by Gadriwala Muslim 10022015
	DECLARE @tmpPeriod	NUMERIC
	DECLARE @flag			NUMERIC
	DECLARE @Exceed_CF_Days	NUMERIC(18, 3)
  
	DECLARE @Sal_cal_days NUMERIC(18,2)
	DECLARE @FNF_Pdays NUMERIC(18,2)
	DECLARE @Holiday_days NUMERIC (18,2)
	DECLARE @temp_month_st_date DATETIME
	DECLARE @Inc_Holiday NUMERIC(1,0) --Added by nilesh Patel ON 28032015   
	DECLARE @Inc_Weekoff NUMERIC(1,0) --Added by nilesh Patel ON 28032015  
	DECLARE @Is_Advance_Leave_Balance NUMERIC(1,0) -- Added by nilesh patel ON 03022016 
	DECLARE @Advance_Leave_Balance NUMERIC(18,2) -- Added by nilesh patel ON 03022016 
	DECLARE @Advance_Leave_Recover_balance NUMERIC(18,2) -- Added by nilesh patel ON 03022016 
	----END----
  
	DECLARE @CF_For_Date DateTime
  
	DECLARE @Fix_Salary tinyint	--Added by Hardik 30/01/2017 for GTPL
  
	SET @Is_Cancel_Weekoff = 0    
	SET @Is_Cancel_Holiday = 0    
	SET @StrHoliday_Date = ''    
	SET @StrWeekoff_Date = ''  
	SET @flag = 0
	SET @Leave_Paid_Days = 0  
	SET @MinPDays_Type = 0
	SET @Is_Advance_Leave_Balance =0 
	SET @Advance_Leave_Balance = 0
	SET @Advance_Leave_Recover_balance = 0 
	SET @Date_Of_Join = NULL -- Added by Gadriwala Muslim 10022015
   

	--SELECT @Inc_HOWO = IsNull(Is_Ho_Wo,0) FROM Dbo.T0040_Leave_Master WHERE Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID            
	--SELECT @Inc_Holiday = IsNull(Including_Holiday,0) FROM Dbo.T0040_Leave_Master WHERE Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID  --Added by nilesh Patel ON 28032015                
	--SELECT @Inc_Weekoff = IsNull(Including_WeekOff,0) FROM Dbo.T0040_Leave_Master WHERE Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID  --Added by nilesh Patel ON 28032015                   
	SELECT	@Inc_HOWO = IsNull(Is_Ho_Wo,0),@Inc_Holiday = IsNull(Including_Holiday,0),@Inc_Weekoff = IsNull(Including_WeekOff,0),
			@Is_Advance_Leave_Balance = IsNull(Is_Advance_Leave_Balance,0) 
	FROM	Dbo.T0040_Leave_Master WITH (NOLOCK)
	WHERE	Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID            

	Declare @OD_Compoff_As_Present tinyint
	Set @OD_Compoff_As_Present = 0
				
	Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name='OD and CompOff Leave Consider As Present'				

	 Declare @Add_Alt_WO_Carry_Fwd TINYINT --- Added this setting for AIA client to add Alternate weekoff in Present Days Fix, by Hardik 07/01/2020
	 set @Add_Alt_WO_Carry_Fwd = 0


	CREATE TABLE #old_cf 
	(
		tran_id    NUMERIC(18,0),
		emp_id     NUMERIC(18,0),
		for_date   DATETIME
	);
  
	-- Added By Gadriwala Muslim 18022015	
	CREATE TABLE #temp_CompOff
	(
		Leave_opening	DECIMAL(18,2),
		Leave_Used		DECIMAL(18,2),
		Leave_Closing	DECIMAL(18,2),
		Leave_Code		VARCHAR(MAX),
		Leave_Name		VARCHAR(MAX),
		Leave_ID		NUMERIC,
		CompOff_String  VARCHAR(MAX) DEFAULT NULL -- Added by Gadriwala 18022015
	)	
															

	IF @Is_FNF = 1 
		BEGIN
			INSERT	INTO #Old_CF
			SELECT	Leave_CF_ID,Emp_ID,CF_For_Date 
			FROM	T0100_LEAVE_CF_DETAIL WITH (NOLOCK)   
			WHERE	Cmp_ID =@Cmp_ID AND Emp_ID = @Emp_Id 
			ORDER BY emp_ID ASC  
		END	

	CREATE TABLE #Include_Leaves
	(
		Leave_ID	NUMERIC,
		IsInclude	BIT
	)

	DECLARE @FLMonthSalStDate DateTime
	DECLARE @FLMonthSalEndDate DateTime

	DECLARE @Sal_St_Date    DATETIME    
	DECLARE @Sal_END_Date   DATETIME  
	DECLARE @Month_St_Date  DATETIME    
	DECLARE @Month_END_Date DATETIME
	DECLARE @WO_Days		  NUMERIC
	DECLARE @HO_Days		  NUMERIC(18,2)
	DECLARE @Leave_CF_Month NUMERIC
	DECLARE @temp_dt		  DATETIME
	DECLARE @Is_Leave_ReSET tinyint
	DECLARE @Leave_Tran_ID  NUMERIC -- Added by Gadriwala 23022015
	DECLARE @Apply_Hourly tinyint -- Added by Gadriwala 23022015
	DECLARE @Flat_Days NUMERIC(10,2)
	DECLARE @total_days NUMERIC(10,2)
--  DECLARE @join_dt DATETIME
	DECLARE @is_leave_CF_Rounding tinyint
	DECLARE @is_leave_CF_Prorata TINYINT
	DECLARE @Default_Short_Name VARCHAR(10) -- Added by Gadriwala 23022015
	DECLARE @Tran_Leave_ID NUMERIC(18,0) -- Added by Gadriwala 23022015
--Hardik 19/09/2012		  
	DECLARE @bln_Flag AS VARCHAR(3)
	DECLARE @Date AS DATETIME
	
	
	--Added by Nilesh Patel on 30122017 -- start
	-- for Present Day Max Limit for AIA 
	-- (EL Leave Carry Fwd Slab) 
	-- Yearly Present Day Less than 240
	-- Present Day Slab Present Day 18 again Leave Balance 1
	-- Above 240 Present Day Change Salb
	-- Present Day Slab Present Day 15 again Leave Balance 1
	
	DECLARE @Present_Day_Max_Limit Numeric(18,2)
	Set @Present_Day_Max_Limit = 0
	
	Declare @Above_MaxLimit_P_Days Numeric(18,2)
	Set @Above_MaxLimit_P_Days = 0
	
	Declare @Above_MaxLimit_Leave_Days Numeric(18,2)
	Set @Above_MaxLimit_Leave_Days = 0
	
	Declare @Allowed_CF_Join_After_Day Numeric(9,2)
	SET	@Allowed_CF_Join_After_Day  = 0
	
	declare @Lv_Month as Numeric
	set @Lv_Month = 0
	--Added by Nilesh Patle on 30122017 -- End

	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

	CREATE TABLE #EMP_WEEKOFF
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		Cmp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
		
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)	
	
	DECLARE @WH_FROM_DATE DATETIME
	DECLARE @WH_TO_DATE DATETIME
	DECLARE @manual_salary_period TINYINT

	SET @WH_FROM_DATE = DATEADD(D, -10, @From_Date)
	SET @WH_TO_DATE = DATEADD(D, 10, @To_Date)
	
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@WH_FROM_DATE, @TO_DATE=@WH_TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		

-- Commented by  Deepal 14062024	
--	--Added by ronakk 12042023

--			SELECT @Duration =  Leave_CF_Type from	T0040_LEAVE_MASTER LM WITH (NOLOCK)	
--			WHERE	LM.cmp_ID =@Cmp_ID AND LM.leave_ID = @P_LeavE_ID AND LeavE_Paid_Unpaid ='P' AND LM.Leave_CF_Type <> 'None'

--					IF @Duration = 'Yearly'
--						SET @tmpPeriod = 11											
--					ELSE IF @Duration = 'Half Yearly'
--						SET @tmpPeriod = 5
--					ELSE IF @Duration = 'Quarterly'
--						SET @tmpPeriod = 2

--					IF @Duration = 'Yearly' OR @Duration = 'Half Yearly' OR @Duration = 'Quarterly'
--						BEGIN
						
--									SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
--									SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))			
--						END	

--	--End by ronakk 12042023

-----Added by ronakk 06042023
--		EXEC SP_CALCULATE_PRESENT_DAYS @cmp_id,@Month_St_Date,@Month_END_Date,0,0,0,0,0,0,@Emp_Id,@Constraint,4 ,1

--		IF OBJECT_ID('tempdb..#TempPdaysForCF') IS Not NULL
--		BEGIN
--					Drop Table #TempPdaysForCF
--		End

--		select sum(P_days) as PDAY,Emp_Id, @From_Date as For_date into #TempPdaysForCF  from #Data
--		group by Emp_Id


----End by ronakk 06042023
-- Commented by  Deepal 14062024	

	--SELECT	I.Emp_Id ,I.Grd_ID, I.Branch_ID,I.Type_ID,Emp_Left_Date,Date_Of_Join,IsNull(I.Emp_Fix_Salary,0) 
	--FROM	T0095_Increment I WITH (NOLOCK)
	--		INNER JOIN #EMP_CONS EC ON I.Increment_ID=EC.Increment_ID	
	--		INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) ON EC.emp_ID=E.emp_ID		
			
	
	--SELECT	I.Emp_Id ,I.Grd_ID, I.Branch_ID,I.Type_ID,Emp_Left_Date,Date_Of_Join,IsNull(I.Emp_Fix_Salary,0) 
	--FROM	
	--T0095_Increment I WITH (NOLOCK)
	--INNER JOIN  --Commented and New Code Added By Ramiz on 12/12/2017
	--						( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
 --                               FROM T0095_INCREMENT I2 
 --                                   INNER JOIN 
 --                                   (
 --                                           SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
 --                                           FROM T0095_INCREMENT I3
 --                                           WHERE I3.Increment_effective_Date <= @Month_End_Date and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' AND I3.EMP_ID = @Emp_ID
 --                                           GROUP BY I3.EMP_ID  
 --                                       ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
 --                              WHERE I2.INCREMENT_EFFECTIVE_DATE <= @Month_End_Date and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
 --                              GROUP BY I2.emp_ID  
 --                           ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID 
	--INNER JOIN #EMP_CONS EC  ON I.Increment_ID=EC.Increment_ID	
	--INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) ON EC.emp_ID=E.emp_ID	
	         
	--return

	DECLARE curEmp CURSOR FAST_FORWARD FOR   
	SELECT	I.Emp_Id ,I.Grd_ID, I.Branch_ID,I.Type_ID,Emp_Left_Date,Date_Of_Join,IsNull(I.Emp_Fix_Salary,0) 
	FROM	T0095_Increment I WITH (NOLOCK)
			INNER JOIN #EMP_CONS EC ON I.Increment_ID=EC.Increment_ID	
			INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) ON EC.emp_ID=E.emp_ID				
	OPEN curEmp  
	FETCH NEXT FROM curEmp INTO @Emp_ID,@Grd_ID,@Branch_ID,@Type_ID,@Emp_Left_Date,@Date_Of_Join,@Fix_Salary 
	WHILE @@FETCH_STATUS =0  	
		BEGIN  
			SET @C_Paid_Days = 0			
			SET @Weekoff_Days = 0
			SET @UnPaid_Days = 0
			SET @Working_Days = 0
			SET @P_Days = 0
			
			SET @Sal_St_Date = NULL
			SET @Sal_END_Date = NULL
			SET @Month_St_Date = NULL    
			SET @Month_END_Date = NULL
			SET @WO_Days = NULL
			SET @HO_Days = NULL
			SET @Leave_CF_Month = NULL
			SET @temp_dt = NULL
			SET @Is_Leave_ReSET = NULL
			SET @Leave_Tran_ID = NULL
			SET @Apply_Hourly = 0
			SET @Flat_Days = NULL
			SET @total_days = NULL
			SET @is_leave_CF_Rounding = NULL
			SET @is_leave_CF_Prorata = NULL
			SET @Default_Short_Name = ''
			SET @Tran_Leave_ID = NULL
			SET @bln_Flag = NULL
			SET @Date = NULL
			SET @manual_salary_period = 0
			
			IF @Branch_ID IS NULL
				BEGIN 
					SELECT	TOP 1 @Sal_St_Date = Sal_st_Date,@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,
							@Is_CF_On_Sal_Days = Is_CF_On_Sal_Days, @Days_As_Per_Sal_Days = Days_As_Per_Sal_Days , @Lv_Month = Lv_Month,
							@manual_salary_period = ISNULL(Manual_Salary_Period,0)
					FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
					WHERE	Cmp_ID = @cmp_ID 
							AND For_Date = (SELECT	MAX(For_Date) 
											FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
											WHERE	For_Date <=@From_Date AND Cmp_ID = @Cmp_ID)    
				END
			ELSE
				BEGIN
					SELECT	@Sal_St_Date = Sal_st_Date,@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,
							@Is_CF_On_Sal_Days = Is_CF_On_Sal_Days, @Days_As_Per_Sal_Days = Days_As_Per_Sal_Days , @Lv_Month = Lv_Month,
							@manual_salary_period = ISNULL(Manual_Salary_Period,0)
					FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
					WHERE	Cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID    
							AND For_Date = (SELECT	MAX(For_Date) 
											FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
											WHERE	For_Date <=@From_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
				END    
						


			--SELECT	LM.Leave_ID,LM.Leave_Max_Bal ,Leave_CF_Type,Leave_PDays,Leave_Get_Against_PDays,IsNull(Leave_Precision,0) AS Leave_Precision,
			--		Leave_Days,LM.Max_Accumulate_Balance,Min_Present_Days,Is_Leave_CF_Rounding,Is_Leave_CF_Prorata,QRY.Effective_Date,
			--		CF.CF_Type_ID,CF.Reset_Months,CF.Duration,CF.CF_Months,CF.Release_Month,CF.Reset_Month_String,LM.MinPdays_Type,
			--		IsNull(LM.Default_Short_Name ,'') AS Default_Short_Name,LM.Trans_Leave_ID,IsNull(LM.Apply_Hourly,0) As Apply_Hourly,
			--		IsNull(Allowed_CF_Join_After_Day,0) As Allowed_CF_Join_After_Day,Isnull(Add_Alt_WO_Carry_Fwd,0)
			--FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
			--		INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
			--		INNER JOIN T0050_CF_EMP_TYPE_DETAIL CF WITH (NOLOCK) ON CF.Leave_ID=LM.Leave_ID
			--		INNER JOIN (SELECT	MAX(Effective_Date) AS Effective_Date,Leave_ID 
			--					FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
			--					WHERE	Cmp_ID=@Cmp_ID AND Leave_ID=@P_LeavE_ID 
			--					GROUP BY Leave_ID) QRY ON QRY.Leave_ID=CF.Leave_ID AND QRY.Effective_Date=CF.Effective_Date
			--WHERE	LM.cmp_ID =@Cmp_ID AND Grd_ID =@Grd_ID AND LM.leave_ID = IsNull(@P_LeavE_ID,LM.leave_ID)  
			--		AND LeavE_Paid_Unpaid ='P' AND CF.Type_ID=@Type_ID AND LM.Leave_CF_Type <> 'None'

					
			DECLARE curLeave CURSOR FAST_FORWARD FOR   
			SELECT	LM.Leave_ID,LM.Leave_Max_Bal ,Leave_CF_Type,Leave_PDays,Leave_Get_Against_PDays,IsNull(Leave_Precision,0) AS Leave_Precision,
					Leave_Days,LM.Max_Accumulate_Balance,Min_Present_Days,Is_Leave_CF_Rounding,Is_Leave_CF_Prorata,QRY.Effective_Date,
					CF.CF_Type_ID,CF.Reset_Months,CF.Duration,CF.CF_Months,CF.Release_Month,CF.Reset_Month_String,LM.MinPdays_Type,
					IsNull(LM.Default_Short_Name ,'') AS Default_Short_Name,LM.Trans_Leave_ID,IsNull(LM.Apply_Hourly,0) As Apply_Hourly,
					IsNull(Allowed_CF_Join_After_Day,0) As Allowed_CF_Join_After_Day,Isnull(Add_Alt_WO_Carry_Fwd,0)
			FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
					INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID   
					INNER JOIN T0050_CF_EMP_TYPE_DETAIL CF WITH (NOLOCK) ON CF.Leave_ID=LM.Leave_ID
					INNER JOIN (SELECT	MAX(Effective_Date) AS Effective_Date,Leave_ID 
								FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
								WHERE	Cmp_ID=@Cmp_ID AND Leave_ID=@P_LeavE_ID 
								GROUP BY Leave_ID) QRY ON QRY.Leave_ID=CF.Leave_ID AND QRY.Effective_Date=CF.Effective_Date
			WHERE	LM.cmp_ID =@Cmp_ID AND Grd_ID =@Grd_ID AND LM.leave_ID = IsNull(@P_LeavE_ID,LM.leave_ID)  
					AND LeavE_Paid_Unpaid ='P' AND CF.Type_ID=@Type_ID AND LM.Leave_CF_Type <> 'None'
			  
			OPEN curLeave   
			FETCH NEXT FROM curLeave INTO @Leave_ID,@Leave_Max_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@Max_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@MinPDays_Type,@Default_Short_Name,@Tran_Leave_ID,@Apply_Hourly, @Allowed_CF_Join_After_Day,@Add_Alt_WO_Carry_Fwd
			WHILE @@FETCH_STATUS =0  
				BEGIN  
				

					/*Weather this leave is assigned to selected employee's branch or not.*/
					IF NOT EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER L WITH (NOLOCK)
									WHERE (
												EXISTS(SELECT 1 FROM dbo.Split(L.Multi_Branch_ID,'#') T Where Data <> '' AND Cast(Data As Numeric) = @Branch_ID)
											OR	IsNull(L.Multi_Branch_ID, '') = ''
											)
								  )
						CONTINUE;
				
				
					UPDATE	IL
					SET		IsInclude = 0
					FROM	#Include_Leaves IL 

					UPDATE	IL
					SET		IsInclude = 1
					FROM	T0040_LEAVE_MASTER LM
							CROSS APPLY (SELECT	CAST(DATA  AS NUMERIC) AS LEAVE_ID 
										FROM	dbo.Split(LM.Including_Leave_Type, '#') T 
												INNER JOIN T0040_LEAVE_MASTER LM1 WITH (NOLOCK) ON CAST(DATA AS NUMERIC) = LM1.Leave_ID
										WHERE	Leave_Paid_Unpaid = 'P' AND DATA <> '') T
							INNER JOIN #Include_Leaves IL ON LM.LEAVE_ID=IL.Leave_ID
					WHERE	LM.Leave_ID = @Leave_ID 
					
					-- Added by Ali 21042014 -- State				
					IF EXISTS(SELECT Min_Leave_CF FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID)
						BEGIN
							DECLARE @Min_Leave_CF_Temp AS NUMERIC(18,1)
							SELECT  @Min_Leave_CF_Temp = Min_Leave_CF 
							FROM	T0050_LEAVE_DETAIL WITH (NOLOCK)
							WHERE	Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID
									
							IF @Min_Leave_CF_Temp > 0
								SET @Leave_Max_Bal = @Min_Leave_CF_Temp
						END
							
					--deepal and sandip comment :- 11012023							
					IF EXISTS(SELECT Max_Accumulate_Balance FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID)
						BEGIN
							DECLARE @Max_Accumulate_Balance_Temp AS NUMERIC(18,1)
							SELECT  @Max_Accumulate_Balance_Temp = Max_Accumulate_Balance 
							FROM	T0050_LEAVE_DETAIL WITH (NOLOCK)
							WHERE	Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID
								
							IF @Max_Accumulate_Balance_Temp > 0
								SET @Max_Accumulate_Balance = @Max_Accumulate_Balance_Temp

								
						END
					--deepal and sandip comment :- 11012023
						--IF EXISTS(SELECT Max_Accumulate_Balance FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE  Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID)
						--BEGIN
						
						--	DECLARE @Max_Accumulate_Balance_Temp AS NUMERIC(18,1)
						--	SELECT  @Max_Accumulate_Balance_Temp = Max_Accumulate_Balance 
						--	FROM	T0040_LEAVE_MASTER WITH (NOLOCK)
						--	WHERE	 Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID
									
						--	IF @Max_Accumulate_Balance_Temp > 0
						--		SET @Max_Accumulate_Balance = @Max_Accumulate_Balance_Temp
								
						--END
						
						
					-- Added by Ali 21042014 -- State
					 
					---- Get Start n END Date
					IF @Duration = 'Yearly'
						SET @tmpPeriod = 11											
					ELSE IF @Duration = 'Half Yearly'
						SET @tmpPeriod = 5
					ELSE IF @Duration = 'Quarterly'
						SET @tmpPeriod = 2

					
					IF @Is_FNF = 1	--Alpesh 25-Jul-2012 SET @For_Date for FNF
						BEGIN
							IF @CF_Months <> '0'
								BEGIN
									IF EXISTS(SELECT 1 FROM dbo.Split2(@CF_Months,'#') WHERE items>=MONTH(@For_Date))
										SELECT @For_Date=dbo.GET_MONTH_ST_DATE(Min(CAST(items AS NUMERIC)),YEAR(@For_Date)) FROM dbo.Split2(@CF_Months,'#') WHERE items>=MONTH(@For_Date)
									ELSE
										SELECT @For_Date=dbo.GET_MONTH_ST_DATE(Min(CAST(items AS NUMERIC)),YEAR(DATEADD(yy,1,@For_Date))) FROM dbo.Split2(@CF_Months,'#')
								END
						END

					
					
					
					IF @Duration = 'Yearly' OR @Duration = 'Half Yearly' OR @Duration = 'Quarterly'
						BEGIN
						
							IF @Days_As_Per_Sal_Days = 0
								BEGIN
									SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
									SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))																								
									
								END
							ELSE
								BEGIN
									IF @Sal_St_Date <> ''  AND DAY(@Sal_St_Date) > 1   
										BEGIN
											SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))																																		
											SET @Month_END_Date = CAST(CAST(DAY(@Sal_St_Date)-1 AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,@Month_END_Date) AS VARCHAR(10)) + '-' +  CAST(YEAR(@Month_END_Date) AS VARCHAR(10)) AS SMALLDATETIME)    
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))
											SET @Month_St_Date  = CAST(CAST(DAY(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,DATEADD(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(m,-1,@Month_St_Date) ) AS VARCHAR(10)) AS SMALLDATETIME)    
										END
									ELSE IF IsNull(@Sal_St_Date,'') = '' OR DAY(@Sal_St_Date) = 1
										BEGIN
											IF  @Is_Advance_Leave_Balance = 1 AND @CF_Type_ID = 2 
												BEGIN
													SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),(YEAR(@For_Date) + 1)))
													SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))																								
												END
											ELSE
												BEGIN
													SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
													SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))
												END
										END 
								END
							
							
							IF CHARINDEX(CAST(MONTH(@For_Date) AS varchar),@CF_Months) > 0
								OR EXISTS(SELECT	1 
										  FROM		T0050_LEAVE_CF_SLAB CFS WITH (NOLOCK)
													INNER JOIN (SELECT	MAX(EFFECTIVE_DATE) AS EFFECTIVE_DATE, LEAVE_ID 
																FROM	T0050_LEAVE_CF_SLAB CFS1 WITH (NOLOCK)
																WHERE	Effective_Date <= GETDATE() 
																GROUP BY Leave_ID) CFS1 ON CFS.Leave_ID=CFS1.Leave_ID
										  WHERE		CFS.Leave_ID=@Leave_ID AND Slab_Flag='J')
								BEGIN	
									SET @flag = 1
								END
									
							DECLARE @FIN_START AS DATETIME
							DECLARE @FIN_END AS DATETIME
								
							SELECT	@FIN_START = dbo.GET_YEAR_START_DATE(YEAR(getdate()), MONTH(getdate()),0), 
									@FIN_END = dbo.GET_YEAR_END_DATE(YEAR(getdate()), MONTH(getdate()),0)

							IF EXISTS(SELECT 1 FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID=@Leave_ID AND Emp_ID=@Emp_Id 
											AND (CF_For_Date BETWEEN @FIN_START AND @FIN_END) AND MONTH(CF_For_Date) <> @CF_Months
											AND CF_Type <> 'Import')
											-- Add by deepal CF_Type condition ticket ID 16332 dt :- 11/1/2021 
								AND @Duration = 'Yearly' 
								SET @flag = 0
							
							if EXISTS(SELECT 1 FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID=@Leave_ID AND Emp_ID=@Emp_Id 
												AND (CF_For_Date BETWEEN @FIN_START AND @FIN_END) AND MONTH(CF_For_Date) = @CF_Months
														AND NOT (DAY(CF_For_Date) = DAY(@Date_Of_Join)  AND MONTH(CF_For_Date) = MONTH(@Date_Of_Join))														
														AND NOT (DAY(GETDATE()) = DAY(@Date_Of_Join) AND MONTH(GETDATE()) = MONTH(@Date_Of_Join))
														AND CF_Type <> 'Import')
														-- Add by deepal CF_Type condition ticket ID 16332 dt :- 11/1/2021 
									AND @Duration = 'Yearly' 
								BEGIN										
									set @flag = 0
								END 
							
							
						END	
					ELSE
						BEGIN

							IF @manual_salary_period = 1
								BEGIN
									select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@Month_End_Date) and YEAR=year(@Month_End_Date)

									SET @Month_St_Date = @Sal_St_Date
									SET @Month_End_Date = @Sal_End_Date 

								END
							ELSE IF @Is_Advance_Leave_Balance = 1
								BEGIN
									SET @For_Date = @From_Date
									SET @Month_END_Date = DATEADD(M, 1, @For_Date)		
								END
							ELSE								
								SET @Month_END_Date = @For_Date
																							
								
							SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date)))																
							
							IF @Days_As_Per_Sal_Days = 0
								BEGIN
									SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))										
								END
							ELSE
								BEGIN
									IF @Sal_St_Date <> ''  AND DAY(@Sal_St_Date) > 1   
										BEGIN
											SET @Month_END_Date = CAST(CAST(DAY(@Sal_St_Date)-1 AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,@Month_END_Date) AS VARCHAR(10)) + '-' +  CAST(YEAR(@Month_END_Date) AS VARCHAR(10)) AS SMALLDATETIME)    
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))
											SET @Month_St_Date  = CAST(CAST(DAY(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,DATEADD(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(m,-1,@Month_St_Date) ) AS VARCHAR(10)) AS SMALLDATETIME)    
										END
									ELSE IF IsNull(@Sal_St_Date,'') = '' OR DAY(@Sal_St_Date) = 1
										BEGIN
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))
										END
								END
							SET @flag = 1
						END
						---- END ----				 	
					
					---------------Jignesh Patel 09-Sep-2021- For Daily-------------
						If @Duration = 'Daily (On Present Day)'
						Begin
							SET @Month_St_Date=@From_Date 
							SET @Month_END_Date=@To_Date 
						End 
						IF @Sal_St_Date <> ''  AND DAY(@Sal_St_Date) > 1   
						BEGIN
							----SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))																																		
							SET @Month_END_Date = CAST(CAST(DAY(@Sal_St_Date)-1 AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,@Month_END_Date) AS VARCHAR(10)) + '-' +  CAST(YEAR(@Month_END_Date) AS VARCHAR(10)) AS SMALLDATETIME)    
							-----SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))
							SET @Month_St_Date  = CAST(CAST(DAY(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,DATEADD(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(m,-1,@Month_St_Date) ) AS VARCHAR(10)) AS SMALLDATETIME)    
						END
					-------------------End Fof ------------------

					
				
					---- SET Month_END_Date IF It Is FNF
					IF @Is_FNF = 1
						BEGIN
							IF @Emp_Left_Date is not NULL AND @Emp_Left_Date > @Month_St_Date AND @Emp_Left_Date < @Month_END_Date
								SET @Month_END_Date = @Emp_Left_Date
						END
					---- END ----
					IF @Is_Advance_Leave_Balance = 1
						SET @CF_For_Date = @For_Date
					Else
						SET @CF_For_Date = @Month_END_Date
						
					
					--select @Leave_ID,@Leave_Max_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@Max_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@MinPDays_Type,@Default_Short_Name,@Tran_Leave_ID,@Apply_Hourly, @Allowed_CF_Join_After_Day,@Add_Alt_WO_Carry_Fwd
					



					IF @Default_Short_Name <> 'COMP'
						BEGIN
						
							---- Get Leave Balance ----
							SELECT @Leave_Closing = LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN    
								(
									SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION  WITH (NOLOCK) 
									WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @Month_END_Date GROUP BY EMP_ID,LEAVE_ID) Q 
									ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE Inner join
								T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID AND IsNull(LM.Default_Short_Name,'') <> 'COMP'      
							WHERE LT.LeavE_ID =@LEave_ID   
						
							IF @Leave_Closing IS NULL
								SET @Leave_Closing = 0
							---- END ----
							
							IF @flag = 1
								BEGIN
									
									DECLARE @SLAB_FLAG AS CHAR(1)=''
									SELECT @SLAB_FLAG=SLAB_FLAG FROM T0050_LEAVE_CF_SLAB WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Type_ID=@Type_ID AND Leave_ID=@P_LeavE_ID 					
											
									--IF @CF_Type_ID IN (1,2,4) OR ( @CF_Type_ID = 3 AND @SLAB_FLAG <> 'J')  --Added by Jaina 13-11-2017 (After Discuss with Hardikbhai)
									
									IF @CF_Type_ID IN (1) OR ( @CF_Type_ID = 3 AND @SLAB_FLAG <> 'J')  --Added by Jaina 13-11-2017 (After Discuss with Hardikbhai)
										BEGIN
 											---- Carry Forward ON Salary OR Not
											
											IF @Is_CF_On_Sal_Days = 1
												BEGIN
													DECLARE @M_WO_Days NUMERIC(18,2)
													DECLARE @M_HO_Days NUMERIC(18,2)
																	
													Declare @P_Days_Locked Numeric(18,2)
													Declare @WO_Days_Locked Numeric(18,2)
													Declare @HO_Days_Locked Numeric(18,2)
													Declare @Alternate_WeekName Varchar(50)
													Declare @Alternate_Weekdays Numeric(18,2)
													DECLARE @LEAVE_USED  NUMERIC(18,2)

													Set @M_WO_Days = 0
													Set @M_HO_Days = 0
													Set @WO_Days = 0
													Set @HO_Days = 0
																		
													Set @P_Days_Locked = 0
													Set @WO_Days_Locked = 0
													Set @HO_Days_Locked = 0
													Set @Alternate_Weekdays = 0
													SET @LEAVE_USED = 0
													
													
													
													IF @Fix_Salary = 0
														SELECT	@P_Days=(sum(Present_Days) + Isnull(Sum(MS.Arear_Day_Previous_month),0) + Isnull(Sum(MS.Arear_Day),0)),
																@M_WO_Days=SUM(Weekoff_Days),
																@M_HO_Days=SUM(Holiday_Days),
																@Sal_cal_days = IsNull(SUM(Sal_Cal_Days),0),
																@LEAVE_USED = ISNULL(SUM(Paid_Leave_Days),0)
														FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
														WHERE	Emp_Id=@Emp_ID AND Month_St_Date >= @Month_St_Date AND Month_END_Date <= @Month_END_Date	
													ELSE
														--SELECT	@P_Days=(sum(Present_Days) + Isnull(Sum(MS.Arear_Day_Previous_month),0) + Isnull(Sum(MS.Arear_Day),0)),
														--Above Line is commented by Deepal For Manaksia Date :- 26-02-2021 Ticke Id 16978
														SELECT	@P_Days=IsNull(SUM(Sal_Cal_Days),0),
																@M_WO_Days=0,
																@M_HO_Days=0,
																@Sal_cal_days = IsNull(SUM(Sal_Cal_Days),0) 
														FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
														WHERE	Emp_Id=@Emp_ID AND Month_St_Date >= @Month_St_Date AND Month_END_Date <= @Month_END_Date	


														SELECT @P_Days_Locked = SUM(P_Days), @WO_Days_Locked = Sum(W_Days), @HO_Days_Locked = Sum(H_Days)
														FROM T0180_LOCKED_ATTENDANCE LA  WITH (NOLOCK) INNER JOIN
															T0185_LOCKED_IN_OUT LIO WITH (NOLOCK) ON LA.Lock_Id = LIO.Lock_Id LEFT OUTER JOIN
															(SELECT MAX(MONTH_END_DATE) AS MONTH_END_DATE, EMP_ID 
																FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
															WHERE CMP_ID=@Cmp_ID GROUP BY EMP_ID) Qry On LA.Emp_Id = Qry.Emp_ID
														WHERE LA.To_Date > Isnull(Qry.MONTH_END_DATE,@month_st_date) And LA.From_Date >= @month_st_date And LA.To_Date <= @month_end_date
															And LA.Emp_Id = @Emp_ID
														GROUP BY LA.Emp_Id																		

														Set @P_Days = Isnull(@P_Days,0) + Isnull(@P_Days_Locked,0)
														Set @M_WO_Days = Isnull(@M_WO_Days,0) + Isnull(@WO_Days_Locked,0)
														Set @HO_Days_Locked = Isnull(@M_HO_Days,0) + Isnull(@HO_Days_Locked,0)

														If Isnull(@Add_Alt_WO_Carry_Fwd,0) = 1  --- For AIA, Need to Put 1 in Leave Master table for Particular Leave
															BEGIN
																Select @Alternate_WeekName = Isnull(Alt_W_Name,'')
																From T0100_WEEKOFF_ADJ A WITH (NOLOCK)
																	Inner Join(
																				Select Emp_ID,Max(For_Date) as Fdate 
																					From T0100_WEEKOFF_ADJ WITH (NOLOCK)
																				Where For_Date <= @To_Date And Emp_Id = @Emp_ID
																				GROUP By Emp_ID 
																			) As Qry ON A.Emp_ID = Qry.Emp_ID and A.For_Date = Qry.Fdate

																If @Alternate_WeekName <> ''
																	Begin
																		EXEC SP_GET_HW_ALL @CONSTRAINT=@Emp_Id,@CMP_ID=@Cmp_ID, @FROM_DATE=@month_st_date, @TO_DATE=@month_end_date, @All_Weekoff = 0, @Exec_Mode=0

																		Select @Alternate_Weekdays = SUM(EW.W_Day)
																		From #Emp_WeekOff EW 
																		Where Upper(EW.Weekoff_day) = Upper(@Alternate_WeekName)
																				
																		Set @P_Days = Isnull(@P_Days,0) + Isnull(@Alternate_Weekdays,0)
																	End
															END
																			
																	
																		IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Month_St_Date >= @Month_St_Date AND Month_End_Date <= @Month_End_Date	AND IsNull(CutOff_Date,Month_End_Date) < Month_End_Date)
																				AND @Duration = 'Yearly'  --Added by Jaina 04-06-2020
																			BEGIN																																							
																				
																				SET @FLMonthSalStDate = @Month_St_Date
																				SET @FLMonthSalEndDate = DATEADD(D, -1, DATEADD(M, 1, @FLMonthSalStDate))
																				
																				/*If Leave Carry Forward Period is 01/01/2017 to 31/12/2017. Then there is previous month Absent Arrear Days exist of Dec-2016 in Jan-2017 Salary 
																				Which should not be considered in CutOff Date Case
																				*/
																				SELECT	@P_Days = @P_Days + IsNull(Abs(MS.Arear_Day_Previous_month),0)
																				FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK) 																						
																				WHERE	MS.Emp_Id=@Emp_ID AND Month_St_Date >= @FLMonthSalStDate AND Month_End_Date <= @FLMonthSalEndDate																																													
																				

																				SET @FLMonthSalEndDate = @Month_End_Date
																				SET @FLMonthSalStDate = DATEADD(M, -1, DATEADD(D, 1, @FLMonthSalEndDate))
	
																				SELECT	@P_Days = @P_Days - IsNull(SUM(IsNull(((CASE WHEN IsNull(CompOff_Used,0) > 0 THEN CompOff_Used Else Leave_Used End) - IsNull(Leave_Encash_Days,0)) * (case when LM.Apply_Hourly=1 then 0.125 else 1 end),0)),0)
																				FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID=LM.LEAVE_ID
																						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON LT.Emp_ID=MS.Emp_ID AND LT.FOR_DATE > IsNull(MS.Cutoff_Date, MS.Month_End_Date) AND LT.FOR_DATE <= MS.Month_End_Date
																						INNER JOIN #Include_Leaves IL ON LT.Leave_ID=IL.Leave_ID
																				WHERE	LT.Emp_Id=@Emp_ID AND Month_St_Date >= @Month_St_Date AND Month_End_Date <= @Month_End_Date	
																						AND ((CASE WHEN CompOff_Used > 0 THEN CompOff_Used Else Leave_Used End) - IsNull(Leave_Encash_Days,0)) > 0
																						AND LT.For_Date < @FLMonthSalStDate	--We are considering actual present of last month
																				
																				
																				Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@FLMonthSalStDate,@FLMonthSalEndDate,0,0,0,0,0,0,@emp_ID,'',4 ,1 -- Comment by Deepal 29012022 to resolved the issue Msg 614, Level 16, State 1, Procedure SP_LEAVE_CF_Display, Line 1682 [Batch Start Line 0] Could not locate bookmark due to data movement.
																		
																				/*Adding Last Month Of Actual Present*/
																				SELECT	@P_Days = @P_Days + IsNull(SUM(P_Days),0) 
																				FROM	#Data D
																				WHERE	Emp_ID=@emp_ID AND For_Date>=@FLMonthSalStDate AND For_Date <=@FLMonthSalEndDate
																				

																				/*Deducting Last Month Of Salary Present*/
																				SELECT	@P_Days = @P_Days - IsNull(Present_Days,0)
																				FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
																				WHERE	MS.Emp_ID=@Emp_Id AND MS.Month_End_Date BETWEEN @FLMonthSalStDate AND @FLMonthSalEndDate
																				
																																								
																				/*Deducting Canceled WeekOff (Absent) Consifered as Present After CutOff Date*/
																				SELECT	@P_Days = @P_Days + Isnull(SUM(1 - W_Day),0)
																				FROM	#EMP_WEEKOFF T
																						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON T.FOR_DATE > IsNull(MS.Cutoff_Date, MS.Month_End_Date) AND T.FOR_DATE <= MS.Month_End_Date
																				WHERE	Is_Cancel=1 AND For_Date BETWEEN @Month_St_Date AND (@FLMonthSalStDate-1)
													
																				SELECT	@P_Days = @P_Days + Isnull(SUM(1 - H_DAY),0)
																				FROM	#EMP_HOLIDAY T
																						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON T.FOR_DATE > IsNull(MS.Cutoff_Date, MS.Month_End_Date) AND T.FOR_DATE <= MS.Month_End_Date
																				WHERE	Is_Cancel=1 AND For_Date BETWEEN @Month_St_Date AND (@FLMonthSalStDate-1)
																				

																			END

																		 
													IF @Is_FNF = 1
														BEGIN
															SET @temp_month_st_date = dbo.GET_MONTH_ST_DATE(MONTH(@to_date),YEAR(@to_date))
															IF @Sal_St_Date <> '' AND DAY(@Sal_St_Date) > 1   
																BEGIN    
																	SET @Sal_St_Date =  CAST(CAST(DAY(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,DATEADD(m,-1,@temp_month_st_date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(m,-1,@temp_month_st_date) ) AS VARCHAR(10)) AS SMALLDATETIME)    
																	SET @temp_month_st_date = @Sal_St_Date
																END	
																				
															SELECT	@FNF_Pdays = IsNull(P_days,0) 
															FROM	T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK)
															WHERE	Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID 
																	AND Month = MONTH(@To_Date) AND Year = YEAR(@To_Date)
																	
															--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@temp_month_st_date,@To_Date,null,@To_Date,0,'',@StrWeekoff_Date OUTPUT,@WO_Days OUTPUT ,@Cancel_Weekoff OUTPUT         
															--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@temp_month_st_date,@To_Date,null,@To_Date,0,@StrHoliday_Date OUTPUT,@HO_Days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date  	 

															SELECT	@WO_Days = SUM(W_Day)
															FROM	#EMP_WEEKOFF
															WHERE	Is_Cancel=0 AND For_Date BETWEEN @temp_month_st_date AND @To_Date

															SELECT	@HO_Days = SUM(H_DAY)
															FROM	#EMP_HOLIDAY
															WHERE	Is_Cancel=0 AND For_Date BETWEEN @temp_month_st_date AND @To_Date
														END
																			
													SET @WO_Days = IsNull(@WO_Days,0) + IsNull(@M_WO_Days,0)
													SET @HO_Days = IsNull(@HO_Days,0) + IsNull(@M_HO_Days,0)
																			
												END
											ELSE
												BEGIN
													--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Date_Of_Join,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    
													--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Date_Of_Join,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@HO_Days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
													
													SELECT	@WO_Days = SUM(W_Day)
													FROM	#EMP_WEEKOFF
													WHERE	Is_Cancel=0 AND For_Date BETWEEN @Month_St_Date AND @Month_END_Date And Emp_Id = @Emp_Id
													
													SELECT	@HO_Days = SUM(H_DAY)
													FROM	#EMP_HOLIDAY
													WHERE	Is_Cancel=0 AND For_Date BETWEEN @Month_St_Date AND @Month_END_Date And Emp_Id = @Emp_Id
																
																
													EXEC SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Month_St_Date,@Month_END_Date,0,0,0,0,0,0,@emp_ID,'',4 ,1-- Comment by Deepal 29012022 to resolved the issue Msg 614, Level 16, State 1, Procedure SP_LEAVE_CF_Display, Line 1682 [Batch Start Line 0] Could not locate bookmark due to data movement.
													
													
													
													--select @P_Days=PDAY from #TempPdaysForCF WHERE Emp_ID=@emp_ID  --Change by ronakk 06042023


													SELECT @P_Days = IsNull(SUM(P_Days),0) FROM #Data WHERE Emp_ID=@emp_ID AND For_Date>=@Month_St_Date AND For_Date <=@Month_END_Date  
													
												END										
											---- END ----
										END	
									
																								
									SET @C_Paid_Days = 0
									SET @Leave_Paid_Days = 0	
									-- Comment by nilesh patel ON 28032015 --Start
									--SELECT @Leave_Paid_Days = IsNull(SUM(leave_used),0) FROM T0140_LEavE_Transaction WHERE Emp_Id = @Emp_ID  --added by hasmukh ON 03012013 for include paid leave IN prorate calculation
									--AND For_Date >= @Month_St_Date AND For_Date <= @Month_END_Date AND Leave_ID IN 
									--(SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose' AND Leave_Paid_Unpaid = 'P' AND IsNull(Default_short_Name,'') <> 'COMP')
									-- Comment by nilesh patel ON 28032015 --Start
													  	
									--Added by nilesh patel ON 28032015 --Start
													 
									IF @Inc_HOWO = 1 
										BEGIN
											DECLARE @IncludingLeaveType VARCHAR(max) = ''
											SELECT	@IncludingLeaveType = IsNull(Including_Leave_Type,0) 
											FROM	T0040_LEave_Master WITH (NOLOCK)
											WHERE Leave_ID = @Leave_ID
											
											create table #AdjustWithLeave(tid int identity(1,1),LeaveId int)
											insert into #AdjustWithLeave
											select Leave_ID from T0040_LEAVE_MASTER where Cmp_ID = @Cmp_ID and Is_Late_Adj = 1
											and Leave_ID in (select Data from dbo.Split(@IncludingLeaveType,'#') where Data <> '')

											IF @IncludingLeaveType is not NULL And @IncludingLeaveType <> '' --'' IF Including leave Checkbox is selected but Leave Type details are not Selected 
												BEGIN
												
													--SELECT @Leave_Paid_Days = IsNull(SUM(leave_used),0)  from
													--		(SELECT CASE WHEN LM.Apply_Hourly = 1 THEN (LT.Leave_Used * 0.125) ELSE LT.leave_used END AS leave_used  FROM T0140_LEavE_Transaction LT INNER JOIN T0040_LEAVE_MASTER LM ON LT.leave_id= LM.leave_id
													--		 WHERE LT.Emp_Id = @Emp_ID 
													--AND LT.For_Date >= @Month_St_Date AND LT.For_Date <= @Month_END_Date AND LT.Leave_ID IN 
													--(SELECT Leave_ID FROM T0040_LEave_Master  WHERE Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' AND IsNull(Default_short_Name,'') <> 'COMP'
													--AND T0040_LEAVE_MASTER.Leave_ID IN(SELECT CAST(Data AS NUMERIC(18,0)) FROM dbo.Split((SELECT Including_Leave_Type FROM T0040_LEave_Master WHERE Leave_ID = @Leave_ID),'#')))) ast
													SELECT	@Leave_Paid_Days = IsNull(SUM(leave_used),0) 
													FROM	(SELECT CASE WHEN LM.Apply_Hourly =1 THEN 
																		CASE WHEN (LT.Leave_Used * 0.125) > 1 THEN 
																				1 
																		ELSE 
																				(LT.Leave_Used * 0.125)  
																		END 
																	ELSE 
																		LT.Leave_Used 
																	END AS leave_used
													  		FROM	T0140_LEavE_Transaction LT WITH (NOLOCK)
																	INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.leave_id= LM.leave_id
													  		WHERE	LT.Emp_Id = @Emp_ID AND LT.For_Date >= @Month_St_Date AND LT.For_Date <= @Month_END_Date 
																	AND LT.Leave_ID IN (SELECT	Leave_ID 
																						FROM	T0040_LEave_Master  WITH (NOLOCK)
																						WHERE	Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' 
																								AND IsNull(Default_short_Name,'') <> 'COMP' AND Leave_Type <> 'Company Purpose'
																								AND T0040_LEAVE_MASTER.Leave_ID IN (SELECT	CAST(Data AS NUMERIC(18,0)) 
																																	FROM	dbo.Split((SELECT	Including_Leave_Type 
																																						FROM	T0040_LEave_Master WITH (NOLOCK)
																																						WHERE	Leave_ID = @Leave_ID),'#')
																																	)
																						)
																		) ASP
																		
													--IF (@OD_Compoff_As_Present = 0)	--- Added by Hardik 07/01/2019 for Cera as they have included Compoff in Present so again adding Compoff in present
													--	SELECT	@Leave_Paid_Days = IsNull(@Leave_Paid_Days,0) + IsNull(SUM(CompOff_Used),0) + Isnull(Sum(leave_used),0)
													--	FROM	(SELECT		CASE WHEN LM.Apply_Hourly = 1 THEN 
													--							((LT.CompOff_Used - LT.Leave_Encash_Days) * 0.125) 
													--						ELSE 
													--							(LT.CompOff_Used - LT.Leave_Encash_Days) 
													--						END AS CompOff_Used,
													--						CASE WHEN LM.Apply_Hourly =1 THEN 
													--							CASE WHEN (LT.Leave_Used * 0.125) > 1 THEN 
													--								1 
													--							ELSE 
													--								(LT.Leave_Used * 0.125)  
													--							END 
													--						ELSE 
													--							LT.Leave_Used 
													--						END AS leave_used																			
													--			FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
													--					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.leave_id =LM.leave_ID 
													--			WHERE	LT.Emp_Id = @Emp_ID AND LT.For_Date >= @Month_St_Date AND LT.For_Date <= @Month_END_Date 
													--					AND LT.Leave_ID IN (SELECT	Leave_ID 
													--										FROM	T0040_LEAVE_MASTER  WITH (NOLOCK)
													--										WHERE	Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' 
													--												AND IsNull(Default_short_Name,'') = 'COMP' OR Leave_Type = 'Company Purpose'
													--												AND T0040_LEAVE_MASTER.Leave_ID IN (SELECT	CAST(Data AS NUMERIC(18,0)) 
													--																					FROM dbo.Split((SELECT	Including_Leave_Type 
													--																									FROM	T0040_LEave_Master WITH (NOLOCK)
													--																									WHERE	Leave_ID = @Leave_ID),'#')
													--																					)
													--										)
													--			) AST

													--IF (@OD_Compoff_As_Present = 1)	---Deepal As discussed with sandip QA copy the above query and change the condition from 0 to 1 -- 30062021
														SELECT	@Leave_Paid_Days = IsNull(@Leave_Paid_Days,0) + IsNull(SUM(CompOff_Used),0) + Isnull(Sum(leave_used),0)
														FROM	(SELECT		CASE WHEN LM.Apply_Hourly = 1 THEN 
																				((LT.CompOff_Used - LT.Leave_Encash_Days) * 0.125) 
																			ELSE 
																				(LT.CompOff_Used - LT.Leave_Encash_Days) 
																			END AS CompOff_Used,
																			CASE WHEN LM.Apply_Hourly =1 THEN 
																				CASE WHEN (LT.Leave_Used * 0.125) > 1 THEN 
																					1 
																				ELSE 
																					(LT.Leave_Used * 0.125)  
																				END 
																			ELSE 
																				LT.Leave_Used 
																			END AS leave_used																			
																FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.leave_id =LM.leave_ID 
																WHERE	LT.Emp_Id = @Emp_ID AND LT.For_Date >= @Month_St_Date AND LT.For_Date <= @Month_END_Date 
																		AND LT.Leave_ID IN (SELECT	Leave_ID 
																							FROM	T0040_LEAVE_MASTER  WITH (NOLOCK)
																							WHERE	Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' 
																									AND IsNull(Default_short_Name,'') = 'COMP' OR Leave_Type = 'Company Purpose'
																									AND T0040_LEAVE_MASTER.Leave_ID IN (SELECT	CAST(Data AS NUMERIC(18,0)) 
																																		FROM dbo.Split((SELECT	Including_Leave_Type 
																																						FROM	T0040_LEave_Master WITH (NOLOCK)
																																						WHERE	Leave_ID = @Leave_ID),'#')
																																		)
																							)
																) AST

																--IF (@OD_Compoff_As_Present = 0)	---Deepal As discussed with sandip QA copy the above query and change the condition from 0 to 1 -- 30062021
																--			SELECT	@Leave_Paid_Days = IsNull(@Leave_Paid_Days,0) + IsNull(SUM(CompOff_Used),0) + Isnull(Sum(leave_used),0)
																--			FROM	(SELECT		CASE WHEN LM.Apply_Hourly = 1 THEN 
																--									((LT.CompOff_Used - LT.Leave_Encash_Days) * 0.125) 
																--								ELSE 
																--									(LT.CompOff_Used - LT.Leave_Encash_Days) 
																--								END AS CompOff_Used,
																--								CASE WHEN LM.Apply_Hourly =1 THEN 
																--									CASE WHEN (LT.Leave_Used * 0.125) > 1 THEN 
																--										1 
																--									ELSE 
																--										(LT.Leave_Used * 0.125)  
																--									END 
																--								ELSE 
																--									LT.Leave_Used 
																--								END AS leave_used																			
																--					FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																--							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.leave_id =LM.leave_ID 
																--					WHERE	LT.Emp_Id = @Emp_ID AND LT.For_Date >= @Month_St_Date AND LT.For_Date <= @Month_END_Date 
																--							AND LT.Leave_ID IN (SELECT	Leave_ID 
																--												FROM	T0040_LEAVE_MASTER  WITH (NOLOCK)
																--												WHERE	Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' 
																--														AND IsNull(Default_short_Name,'') = 'COMP' OR Leave_Type = 'Company Purpose'
																--														AND T0040_LEAVE_MASTER.Leave_ID IN (SELECT	CAST(Data AS NUMERIC(18,0)) 
																--																							FROM dbo.Split((SELECT	Including_Leave_Type 
																--																											FROM	T0040_LEave_Master WITH (NOLOCK)
																--																											WHERE	Leave_ID = @Leave_ID),'#')
																--																							)
																--												)
																--					) AST

														
																												
														if @Is_CF_On_Sal_Days = 1
															select @Leave_Paid_Days = @Leave_Paid_Days + Leave_Adj_L_Mark From T0140_LEAVE_TRANSACTION
															inner join #AdjustWithLeave on Leave_ID = LeaveId
															where Emp_ID = @Emp_Id and For_Date between @From_Date and @To_Date
															and Leave_Adj_L_Mark > 0 --and CHARINDEX(convert(varchar,@P_LeavE_ID),@IncludingLeaveType) > 0
														
														drop table #AdjustWithLeave
												END 
											ELSE
												BEGIN
													SET @Leave_Paid_Days = 0
												END
										END
									ELSE
										BEGIN
											SET @Leave_Paid_Days = 0
										END 
														
									--Added by nilesh patel ON 28032015 --Start
									
			  						IF @P_Days IS NULL
										SET @P_Days = 0
									IF @WO_Days IS NULL
										SET @WO_Days = 0
									IF @HO_Days IS NULL
										SET @HO_Days = 0
									IF @C_Paid_Days IS NULL
										SET @C_Paid_Days = 0	
																				
									--Added by Mr.Mehul on 28122022
									Declare @SettingChk as Tinyint,@leave_included as varchar(200)
									select @SettingChk = Is_Ho_Wo,@leave_included =Including_Leave_Type from T0040_LEAVE_MASTER where Cmp_ID = @Cmp_ID and leave_id = @P_LeavE_ID

									if @SettingChk = 1 
									Begin
										
										SELECT	@Leave_Paid_Days = Sum(isnull(Leave_Used,0)) + Sum(isnull(CompOff_Used,0)) 											
										FROM	T0140_LEAVE_TRANSACTION LT 
										INNER JOIN T0040_LEAVE_MASTER LM ON LT.leave_id =LM.leave_ID 
										WHERE	LT.Emp_Id = @Emp_ID AND LT.For_Date >= @Month_St_Date AND LT.For_Date <= @Month_END_Date 
										AND LT.Leave_ID IN ((SELECT	CAST(Data AS NUMERIC(18,0)) 
										FROM dbo.Split((SELECT @leave_included),'#')T Where T.Data <> '')) 
										 
									End
									--Added by Mr.Mehul on 28122022
									

									--Added by Mr.Mehul on 15-02-2023

									--select @P_Days = count(IO_Tran_Id) from T0150_EMP_INOUT_RECORD 
									--where emp_id = @Emp_Id and For_Date between @From_Date and @To_Date


									--Added by Mr.Mehul on 15-02-2023
						

									IF @Is_FNF = 1
										BEGIN
											-- Comment by nilesh patel ON 28032015 Start
											--IF @Inc_HOWO = 1
											--	SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)
											--ELSE
											--	SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0)
											-- Comment by nilesh patel ON 28032015 END
																
										  --Added by nilesh patel ON 28032015 -Start
											IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 AND @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) +  IsNull(@Leave_Paid_Days,0)
											ELSE IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) + IsNull(@HO_Days,0) +  IsNull(@Leave_Paid_Days,0)
											ELSE IF @Inc_HOWO = 1 AND @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) +  IsNull(@Leave_Paid_Days,0)
											ELSE IF @Inc_Holiday = 1 AND @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) 
											ELSE IF @Inc_Holiday = 1 
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) + IsNull(@HO_Days,0) 
											ELSE IF @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0)
											ELSE IF @Inc_HOWO = 1
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0) +  IsNull(@Leave_Paid_Days,0)
											ELSE
												SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@FNF_Pdays,0)
																	
											--Added by nilesh patel ON 28032015 -END 
										
										END
									ELSE
										BEGIN
											-- Comment by nilesh patel ON 28032015 Start
											--IF @Inc_HOWO = 1											
											--	SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)
											--ELSE
											--	SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0)
											-- Comment by nilesh patel ON 28032015 END
											
											--Added by nilesh patel ON 28032015 -Start
											
											IF @Fix_Salary = 0
												BEGIN						

													
													IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 AND @Inc_Weekoff = 1
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)
													ELSE IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)
													ELSE IF @Inc_HOWO = 1 AND @Inc_Weekoff = 1
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + IsNull(@Leave_Paid_Days,0)
													ELSE IF @Inc_Holiday = 1 AND @Inc_Weekoff = 1
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0)
													ELSE IF @Inc_Holiday = 1 
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@HO_Days,0)
													ELSE IF @Inc_Weekoff = 1
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@WO_Days,0)
													ELSE IF @Inc_HOWO = 1
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0) + IsNull(@Leave_Paid_Days,0)
													ELSE
														SET @P_Days = IsNull(@P_Days,0) + IsNull(@C_Paid_Days,0)


														
												END
																	
											--Added by nilesh patel ON 28032015 -END 
										END
									---- END ----						
											
									
									---- Carry Forward Type	
									
									IF @CF_Type_ID = 1	---- Prorata
										BEGIN
											--Added by nilesh patel ON 02042015(Add provision ON Present getting Employee Type Wise)
																
			  								SELECT	@Leave_Pdays = IsNull(LCP.Present_Day,0),
													@Leave_Get_Against_PDays = IsNull(LCP.Leave_Again_Present_Day,0),
													@Present_Day_Max_Limit = IsNull(Present_Day_Max_Limit,0),
													@Above_MaxLimit_P_Days = IsNull(Above_MaxLimit_P_Days,0),
													@Above_MaxLimit_Leave_Days = IsNull(Above_MaxLimit_Leave_Days,0)
											FROM	T0050_LEAVE_CF_Present_Day LCP WITH (NOLOCK)
													INNER JOIN(SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																FROM	T0050_LEAVE_CF_Present_Day  WITH (NOLOCK)
																WHERE	Cmp_ID = @Cmp_ID AND Leave_ID = @P_LeavE_ID AND Type_ID = @Type_ID 
																		AND Effective_Date <= @Month_END_Date 
																GROUP BY Leave_ID,Type_ID) QRY ON LCP.Effective_Date = QRY.Effective_Date AND LCP.Leave_ID = QRY.Leave_ID AND LCP.Type_ID = QRY.Type_ID
											WHERE	LCP.Cmp_ID = @Cmp_ID AND LCP.Leave_ID = @P_LeavE_ID AND LCP.Type_ID = @Type_ID AND LCP.Effective_Date <= @Month_END_Date
											
											

											IF @Leave_Get_Against_PDays > 0 AND @Leave_pDays > 0	
			  									BEGIN
												
			  										IF @is_leave_CF_Rounding = 1   --Added by hasmukh 21012012
			  											BEGIN
			  												--SET @Leave_CF_Days = 0
			  												if @Present_Day_Max_Limit > 0 And @P_Days > @Present_Day_Max_Limit 
			  													Begin
			  														SET @Leave_CF_Days = Round(@Present_Day_Max_Limit * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)
			  														IF @Above_MaxLimit_P_Days > 0
			  															Begin
			  																SET @Leave_CF_Days = @Leave_CF_Days + Round((@P_Days - @Present_Day_Max_Limit) * IsNull(@Above_MaxLimit_Leave_Days,0)/@Above_MaxLimit_P_Days,0)
			  															End
			  													End
			  												Else
			  													Begin
			  														SET @Leave_CF_Days = Round(@P_Days * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)
			  													End
			  											END
			  										ELSE
			  											BEGIN
			  												--SET @Leave_CF_Days = 0
			  												if @Present_Day_Max_Limit > 0 And @P_Days > @Present_Day_Max_Limit 
			  													Begin
			  														SET @Leave_CF_Days = @Present_Day_Max_Limit * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays
			  														
			  														IF @Above_MaxLimit_P_Days > 0 
			  															Begin
			  																SET @Leave_CF_Days =  @Leave_CF_Days + (@P_Days - @Present_Day_Max_Limit) * (IsNull(@Above_MaxLimit_Leave_Days,0)/@Above_MaxLimit_P_Days)
			  															End
			  													End
			  												Else
			  													Begin
			  														SET @Leave_CF_Days = @P_Days * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays
			  													End
														END
														
														
																	
													IF @Is_Advance_Leave_Balance = 1 
			  											BEGIN
														
			  												IF @P_Days > @Leave_Pdays
			  													BEGIN
			  														IF EXISTS(SELECT 1 FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID)
			  															BEGIN
			  																SET @Leave_CF_Days = 0
			  																SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  																SET @Advance_Leave_Recover_balance = 0
			  															END
																	ELSE IF cast(@Advance_Leave_Recover_balance as int) = 0 and not EXISTS(SELECT 1 FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID) -- by deepal with ronak and sandip bhai 24012022
																	BEGIN
																			SET @Leave_CF_Days = 0
			  																SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  																SET @Advance_Leave_Recover_balance = 0
																	END
			  														ELSE
			  															BEGIN
			  																SET @Leave_CF_Days = @Leave_CF_Days
			  																SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  															END
			  													END
			  												ELSE
			  													BEGIN													
			  														IF @Duration = 'Yearly'
			  															BEGIN
			  																DECLARE @CF_From_Date DATETIME
			  																DECLARE @CF_To_Date DATETIME
			  																--IF YEAR(@Date_Of_Join) = YEAR(@To_Date) -- For New Joining Case 
			  																--	SET @CF_For_Date = @To_Date
			  																--ELSE
			  																--	SET @CF_For_Date = DATEADD(YEAR,-1,@For_Date) --For Yearwise CF Case 
			  																							
			  																IF YEAR(@Date_Of_Join) = YEAR(@To_Date) -- For New Joining Case
			  																	BEGIN 
			  																		SET @CF_From_Date = @From_Date
			  																		SET @CF_To_Date = @To_Date
			  																	END
			  																ELSE
			  																	BEGIN
			  																		SET @CF_From_Date =  @From_Date --DATEADD(YEAR,-1,@From_Date)
			  																		SET @CF_To_Date = @To_Date --DATEADD(YEAR,-1,@To_Date)
			  																	END 
			  																							
			  																							
			  																IF EXISTS(SELECT 1 FROM T0100_LEAVE_CF_Advance_Leave_Balance WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID AND CF_To_Date BETWEEN @CF_From_Date AND @CF_To_Date ) --CF_For_Date >= @CF_For_Date AND CF_For_Date <= @CF_For_Date
			  																	BEGIN
			  																		DECLARE @Advance_Cry_Fwd_1 NUMERIC(18,2)
			  																		SET @Advance_Cry_Fwd_1 = 0
			  																		SELECT @Advance_Cry_Fwd_1 = Advance_Leave_Balance FROM T0100_LEAVE_CF_Advance_Leave_Balance WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID AND CF_To_Date BETWEEN @CF_From_Date AND @CF_To_Date -- AND CF_For_Date >= @CF_For_Date AND CF_For_Date <= @CF_For_Date
			  																									
			  																		SET @Leave_CF_Days = @Leave_CF_Days - @Advance_Cry_Fwd_1
			  																		SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  																		SET @Advance_Leave_Recover_balance = @Leave_CF_Days
			  																	END
			  																ELSE
			  																	BEGIN
			  																		SET @Leave_CF_Days = @Leave_CF_Days
			  																		SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  																		SET @Advance_Leave_Recover_balance = 0
			  																	END
			  															END
			  														ELSE IF @Duration = 'Monthly'
			  															BEGIN			  																						
			  																IF EXISTS(SELECT 1 FROM T0100_LEAVE_CF_Advance_Leave_Balance  WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID AND CF_For_Date BETWEEN @From_Date AND @To_Date /*AND CF_From_Date >= @From_Date AND CF_To_Date <= @To_Date*/ )
			  																	BEGIN
			  																		DECLARE @Advance_Cry_Fwd NUMERIC(18,2)
			  																		SET @Advance_Cry_Fwd = 0
			  																		SELECT @Advance_Cry_Fwd = Advance_Leave_Balance FROM T0100_LEAVE_CF_Advance_Leave_Balance WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID AND CF_For_Date BETWEEN @From_Date AND @To_Date --AND CF_From_Date >= @From_Date AND CF_To_Date <= @To_Date
			  																		SET @Leave_CF_Days = @Leave_CF_Days - @Advance_Cry_Fwd
			  																		SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  																		SET @Advance_Leave_Recover_balance = @Leave_CF_Days
			  																	END
			  																ELSE
			  																	BEGIN
			  																		SET @Leave_CF_Days = @Leave_CF_Days
			  																		SET @Advance_Leave_Balance = @Leave_Get_Against_PDays
			  																		SET @Advance_Leave_Recover_balance = 0
			  																	END
			  															END
			  													END 
			  																		
			  											END
												END	
										END
									ELSE IF @CF_Type_ID = 2		---- Monthly Fix
										BEGIN
											IF EXISTS(SELECT Leave_ID FROM T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) WHERE Leave_ID=@Leave_ID AND MONTH(For_Date)=MONTH(@Month_END_Date) AND CF_M_Days <> 0)  
												BEGIN  
													--SELECT @Leave_CF_Days = CF_M_Days FROM T0050_LEAVE_CF_MONTHLY_SETTING WHERE Leave_ID=@LEave_ID AND MONTH(For_Date)=MONTH(@Month_END_Date) AND YEAR(For_Date)=YEAR(@Month_END_Date) ORDER BY leave_tran_id 
													-- Comment by nilesh patel ON 02042015 -start due to add provision of Type Monthly Fix
													--SELECT @Leave_CF_Days = IsNull(CF_M_Days,0) FROM T0050_LEAVE_CF_MONTHLY_SETTING WHERE Leave_ID=@Leave_ID AND MONTH(For_Date)=MONTH(@Month_END_Date) AND CF_M_Days <> 0												 
													-- Comment by nilesh patel ON 02042015 -END
													DECLARE @CF_Month_Days as numeric(18,2) = 0
													DECLARE @CF_Month_DaysAfterJoining as numeric(18,2) = 0
																		  
													--Added by nilesh patel ON 02042015 -Start
													SELECT	@CF_Month_Days = IsNull(CF_M_Days,0), 
															@CF_Month_DaysAfterJoining = IsNull(CF_M_DaysAfterJoining,0)
													FROM	T0050_LEAVE_CF_MONTHLY_SETTING LCF WITH (NOLOCK)
															INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																		FROM	T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
																		WHERE	MONTH(For_Date)= MONTH(@Month_END_Date) AND CF_M_Days <> 0 
																		GROUP BY Leave_ID,Type_ID) QRY ON LCF.Effective_Date=QRY.Effective_Date AND LCF.Leave_ID=QRY.Leave_ID AND LCF.Type_ID=QRY.Type_ID
													WHERE	LCF.Cmp_ID=@Cmp_ID AND LCF.Type_ID=@Type_ID AND LCF.Leave_ID=@P_LeavE_ID 
															AND MONTH(LCF.For_Date)= MONTH(@Month_END_Date) AND LCF.CF_M_Days <> 0
													

													--Added by Mehul on 13062022 to get Leave Credit Day
													declare @setval numeric(18,0) = 0
													declare @valdays numeric(18,2) = 0
													declare @monthdays numeric(18,2) = 0
													declare @caldays numeric(18,2) = 0
													declare @flag1 numeric(18,2) = 0
													Select @setval = Is_Leave_CF_Prorata from T0040_LEAVE_MASTER where cmp_id = @cmp_id and leave_id = @leave_id

													if @setval = 1 
													begin
														IF CAST(@Date_Of_Join AS DATE) >  CAST(@From_Date AS dATE) 
														BEGIN
															Set @flag1 = 1
															Set @valdays = DATEDIFF(day, @Date_Of_Join, @Month_END_Date) + 1
															Set @monthdays = DATEDIFF(day, @From_Date, @Month_END_Date) + 1  
															Set @caldays = (@CF_Month_Days / @monthdays) * @valdays
														END
													end

													--Added by Jaina 10-11-2017
													IF @CF_Month_Days > 0
														if @flag1 = 1
														begin
															set @Leave_CF_Days = @caldays
														end
														else
														begin
															set @Leave_CF_Days = @CF_Month_Days
														end
													else
														set @Leave_CF_Days = 0
														
													--In case of employee is joined after 15th then employee is not elligible for full month leave credit	 
													/*
													If Month(@Month_END_Date) = Month(@Date_Of_Join) AND Year(@Month_END_Date) = Year(@Date_Of_Join) 
														AND Day(@Date_Of_Join) >= @Allowed_CF_Join_After_Day AND @CF_Month_Days > 0
														SET @Leave_CF_Days = @CF_Month_DaysAfterJoining
													*/
													If Month(@Month_END_Date) = Month(@Date_Of_Join) AND Year(@Month_END_Date) = Year(@Date_Of_Join) 
														AND Day(@Date_Of_Join) >= @Allowed_CF_Join_After_Day AND @CF_Month_Days > 0 And @Allowed_CF_Join_After_Day>0
														BEGIN
															IF @Is_Advance_Leave_Balance <> 1 /*Condition added by Hardikbhai (For Normal Leave CF scenario)*/
																SET @Leave_CF_Days = @CF_Month_DaysAfterJoining
															ELSE IF @Is_Advance_Leave_Balance = 1 AND @CallFor = 'ADD_EMPLOYEE' /*This condition added by Nimesh on 05-Feb-2019 (CF process while creating Employee)*/
																SET @Leave_CF_Days = @CF_Month_DaysAfterJoining
														END
														

														
													IF @Is_Advance_Leave_Balance = 1
														BEGIN
															SET @Advance_Leave_Balance = @Leave_CF_Days
															if cast(@Leave_Closing as int) <= 0 
																Set	@Leave_CF_Days = 0 -- Dpal 11012023

															SET @Advance_Leave_Recover_balance = 0
														END													
													--Added By Ramiz & Nimesh on 20-Jul-2018--
													/*
														EXPLANATION:- THIS CODE IS FOR NEW JOINING EMPLOYEES OF LAST YEAR. IF EMPLOYEES DATE OF JOIN IS COMING IN LAST 1 YEAR THOSE EMPLOYEE WILL GO IN THIS CONDITION.
																	  THEN IT WILL CHECK THE LAST DATE OF CARRY FORWARD DONE , AND THEN WILL TAKE ITS LAST DATE AND WILL CALCULATE PRORATA FROM THAT DATE TILL LAST DATE OF CARRY FORWARD MONTH.
													*/
													
													DECLARE @Conf_Join_Date DateTime
													SET @Conf_Join_Date = DATEADD(M, @Lv_Month, @Date_Of_Join)
													
													IF @is_leave_CF_Prorata = 1 --AND DATEDIFF(MM, @Conf_Join_Date, @Month_END_Date) < 5
														AND @Conf_Join_Date > @Month_END_Date
														BEGIN
														
														--set @Leave_CF_Days = 0
														
															IF OBJECT_ID('tempdb..#CF_MONTHLY') IS NULL
																BEGIN
																	SELECT	LCF.*
																	INTO	#CF_MONTHLY
																	FROM	T0050_LEAVE_CF_MONTHLY_SETTING LCF WITH (NOLOCK)
																			INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																						FROM	T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
																						WHERE	MONTH(For_Date) = MONTH(@Month_END_Date) AND CF_M_Days <> 0 
																						GROUP BY Leave_ID,Type_ID) QRY ON LCF.Effective_Date=QRY.Effective_Date AND LCF.Leave_ID=QRY.Leave_ID AND LCF.Type_ID=QRY.Type_ID
																	WHERE	LCF.Cmp_ID = @Cmp_ID AND LCF.Type_ID = @Type_ID AND LCF.Leave_ID = @P_LeavE_ID AND CF_M_Days <> 0
																END
															

															
															DECLARE @START_DATE DATETIME
															DECLARE @END_DATE DATETIME
															DECLARE @END_DATE_NEXT DATETIME

														
															SELECT	@END_DATE = DATEADD(M, 1, FOR_DATE)-1
															FROM	#CF_MONTHLY
															WHERE	MONTH(For_Date) = MONTH(@Month_END_Date) AND CF_M_Days > 0

															SELECT	@END_DATE_NEXT = DATEADD(M, 1, FOR_DATE)-1
															FROM	#CF_MONTHLY
															WHERE	MONTH(For_Date) > MONTH(@Conf_Join_Date) AND CF_M_Days > 0
															ORDER BY For_Date DESC

															IF @END_DATE IS NOT NULL
																BEGIN 	
																	SET @END_DATE = DATEADD(YYYY, YEAR(@Month_END_Date) - YEAR(@END_DATE) , @END_DATE)		
																	SET @END_DATE_NEXT = DATEADD(YYYY, YEAR(@Month_END_Date) - YEAR(@END_DATE_NEXT) , @END_DATE_NEXT)
																	
																	SELECT	TOP 1 @START_DATE = DATEADD(M, 1, FOR_DATE)
																	FROM	(											
																				SELECT	1 AS ID, MAX(FOR_DATE) FOR_DATE
																				FROM	#CF_MONTHLY
																				WHERE	MONTH(For_Date) < MONTH(@END_DATE) AND CF_M_Days > 0
																				UNION 
																				SELECT	2 AS ID, MAX(FOR_DATE) FOR_DATE
																				FROM	#CF_MONTHLY
																				WHERE	CF_M_Days > 0
																			) T
																	WHERE	FOR_DATE IS NOT NULL
																	ORDER BY ID
															
																	
																	IF MONTH(@START_DATE) < MONTH(@END_DATE)
																		SET @START_DATE = DATEADD(YYYY, YEAR(@END_DATE) - YEAR(@START_DATE) , @START_DATE)
																	ELSE
																		SET @START_DATE = DATEADD(YYYY, YEAR(@END_DATE) - YEAR(@START_DATE) -1 , @START_DATE)
																

																	/*
																	IF @Conf_Join_Date > @START_DATE AND @Conf_Join_Date < @END_DATE																
																		SET @Leave_CF_Days = (DATEDIFF(D, @Conf_Join_Date, @END_DATE) * @Leave_CF_Days) / DATEDIFF(D, @START_DATE, @END_DATE)
																	ELSE IF @Conf_Join_Date > 	@END_DATE
																		SET @Leave_CF_Days =0
																	*/
								
																SET @Leave_CF_Days = (DATEDIFF(D, @Conf_Join_Date,@END_DATE_NEXT) * @Leave_CF_Days) / DATEDIFF(D, @START_DATE, @END_DATE)
																
																																	
																	IF @is_leave_CF_Rounding = 1
																		SET  @Leave_CF_Days = ROUND(@Leave_CF_Days/0.5 , 0) * 0.5  -- Rounding to Nearest 0.5

																END
																
															DROP TABLE #CF_MONTHLY
														 END
												END
										END	
									ELSE IF @CF_Type_ID = 3		---- Slab
										BEGIN
											--Added by Rajput 01052017
											DECLARE @TOTALMONTH AS NUMERIC(16,0)
											SET @TOTALMONTH=DATEDIFF(MONTH, @Date_Of_Join, @To_Date)
																
											
																
											IF(@SLAB_FLAG <> '')	
												BEGIN
													IF(@SLAB_FLAG='J')
														BEGIN
															--Added by Jaina 06-06-2017 Start
															/*For SLS Client*/

															DECLARE @TMP_CF_DATE DATETIME
															DECLARE @CURRENET_DATE DATETIME
															DECLARE @T_Month AS NUMERIC
															
															SET @TMP_CF_DATE = DATEADD(YY, YEAR(@To_Date) - YEAR(@Date_Of_Join), @Date_Of_Join)
															SET @T_Month = DATEDIFF(MONTH, @Date_Of_Join, GETDATE())
																			
															IF @TMP_CF_DATE = CAST(getdate() AS date) AND DATEDIFF(YY, @Date_Of_Join, @To_Date) % 2 = 0
																BEGIN
																	--IF @T_Month = 24  --(2 year)
																	IF @T_Month % 24 = 0
																		BEGIN
																			IF MONTH(@Date_Of_Join) = MONTH(Getdate()) 
																				SELECT	@LEAVE_CF_DAYS = CF_DAYS 
																				FROM	#CF_Slab_FixYear 
																				WHERE	MONTH(GETDATE()) between From_Month AND To_Month																															
																		END																											
																END
															--Added by Jaina 06-06-2017 END
															ELSE IF CHARINDEX(CAST(MONTH(@For_Date) AS varchar),@CF_Months) > 0
																BEGIN
																	IF MONTH(@Date_Of_Join) <= MONTH(Getdate()) 
																		SELECT	@LEAVE_CF_DAYS = CF_DAYS 
																		FROM	T0050_LEAVE_CF_SLAB CF WITH (NOLOCK)
																				INNER JOIN (SELECT	MAX(EFFECTIVE_DATE) EFFECTIVE_DATE,LEAVE_ID,TYPE_ID 
																							FROM	T0050_LEAVE_CF_SLAB WITH (NOLOCK)
																							WHERE	EFFECTIVE_DATE <= @MONTH_END_DATE 
																							GROUP BY LEAVE_ID,TYPE_ID) QRY ON CF.EFFECTIVE_DATE=QRY.EFFECTIVE_DATE AND CF.LEAVE_ID=QRY.LEAVE_ID AND CF.TYPE_ID=QRY.TYPE_ID
																		WHERE	CF.CMP_ID=@CMP_ID AND CF.TYPE_ID=@TYPE_ID AND CF.LEAVE_ID=@P_LEAVE_ID 
																				AND FROM_DAYS <= @TOTALMONTH AND TO_DAYS >= @TOTALMONTH
																END
														END
													ELSE
														BEGIN 
															SELECT	@LEAVE_CF_DAYS = CF_DAYS 
															FROM	T0050_LEAVE_CF_SLAB CF WITH (NOLOCK)
																	INNER JOIN (SELECT	MAX(EFFECTIVE_DATE) EFFECTIVE_DATE,LEAVE_ID,TYPE_ID 
																				FROM	T0050_LEAVE_CF_SLAB WITH (NOLOCK)
																				WHERE	EFFECTIVE_DATE <= @MONTH_END_DATE 
																				GROUP BY LEAVE_ID,TYPE_ID) QRY ON CF.EFFECTIVE_DATE=QRY.EFFECTIVE_DATE AND CF.LEAVE_ID=QRY.LEAVE_ID AND CF.TYPE_ID=QRY.TYPE_ID
															WHERE	CF.CMP_ID=@CMP_ID AND CF.TYPE_ID=@TYPE_ID AND CF.LEAVE_ID=@P_LEAVE_ID AND FROM_DAYS <= @P_DAYS AND TO_DAYS >= @P_DAYS
														END
												END		
											--SELECT @Leave_CF_Days = CF_Days FROM T0050_LEAVE_CF_SLAB cf INNER JOIN (SELECT MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID FROM T0050_LEAVE_CF_SLAB WHERE Effective_Date <= @Month_END_Date GROUP BY Leave_ID,Type_ID) qry
											--on CF.Effective_Date=QRY.Effective_Date AND CF.Leave_ID=QRY.Leave_ID AND CF.Type_ID=QRY.Type_ID
											--WHERE CF.Cmp_ID=@Cmp_ID AND CF.Type_ID=@Type_ID AND CF.Leave_ID=@P_LeavE_ID AND From_Days <= @P_Days AND To_Days >= @P_Days															
										END
									ELSE IF @CF_Type_ID = 4		---- Flat
										BEGIN
											SELECT @Flat_Days = Leave_Days FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Leave_ID=@Leave_ID AND Grd_ID=@Grd_ID AND Cmp_ID=@Cmp_ID
											--	SELECT @join_dt = Date_Of_Join FROM T0080_EMP_MASTER WHERE Emp_ID=@Emp_Id AND Cmp_ID=@Cmp_ID 
																
											IF @Flat_Days IS NULL
												SET @Flat_Days = 0
																
																
											IF @Date_Of_Join > @Month_St_Date AND @is_leave_CF_Prorata = 1
												BEGIN
													SET @total_days = DATEDIFF(d,DATEADD(dd,-1,@Date_Of_Join),@Month_END_Date)	
																		
													IF @is_leave_CF_Rounding = 1		--Added by hasmukh 21012012								
														SET @Leave_CF_Days = Round(IsNull(@total_days,0)*@Flat_Days/DATEDIFF(d,@Month_St_Date,@Month_END_Date),0)	
													ELSE 
														SET @Leave_CF_Days = IsNull(@total_days,0)*@Flat_Days/DATEDIFF(d,@Month_St_Date,@Month_END_Date)
												END
											ELSE
												BEGIN
													SET @Leave_CF_Days = @Flat_Days
												END	
										END	
									-- Check this --
									--IF exists (SELECT Leave_ID FROM T0050_LEAVE_CF_SETTING WHERE Leave_ID=@Leave_ID )  
									--	 BEGIN  
									--		   SELECT @CF_Days = CF_Days,@CF_Full_Days = CF_Full_Days FROM T0050_LEAVE_CF_SETTING WHERE Leave_ID =@Leave_ID   
									--		   AND @P_days >= From_Pdays AND   @P_days <=To_PDays    
													                
									--		   IF @CF_Full_Days = 0  
									--			SET @Leave_CF_Days = @CF_Days   
									--	 END  
									-- END --										
														
									---- Max Leave To Carry Forward		
									IF IsNull(@Leave_CF_Days,0) > IsNull(@Leave_Max_Bal,0) AND IsNull(@Leave_Max_Bal,0) > 0
										SET @Leave_CF_Days = IsNull(@Leave_Max_Bal,0)		
														
									---- Max Accumulate Balance 
									---- IF @Max_Accumulate_Balance = 100, @Leave_Closing = 97, @Leave_CF_Days = 5 THEN @Leave_CF_Days = 3 AND @Exceed_CF_Days = 2 	
									
									IF IsNull(@Leave_Closing,0) + @Leave_CF_Days > IsNull(@Max_Accumulate_Balance,0) AND IsNull(@Max_Accumulate_Balance,0) > 0
										BEGIN
											SET @Leave_CF_Days = IsNull(@Max_Accumulate_Balance,0) - IsNull(@Leave_Closing,0)
											SET @Exceed_CF_Days = IsNull(@Leave_Closing,0) + @Leave_CF_Days - IsNull(@Max_Accumulate_Balance,0)
											
											if @Is_Advance_Leave_Balance = 1 -- dpal 11012023
												set @Advance_Leave_Balance = @Leave_CF_Days
										END
									ELSE
										SET @Exceed_CF_Days = 0
														
									IF @Leave_CF_Days < 0 AND @Is_Advance_Leave_Balance <> 1	--Alpesh 17-Aug-2012
										SET @Leave_CF_Days = 0
														
									IF @Is_FNF = 1
										SET @Min_Present_Days = 0	--Alpesh 25-Jul-2012 dont chk min. present days IF doing FNF
												
												
												
									IF IsNull(@Min_Present_Days,0) > 0
										BEGIN
											IF @MinPDays_Type = 1  -- Added by Gadriwala Muslim 10022015(Minimum Present Day Percentage Wise Calculate) 
												BEGIN
													DECLARE @Yearly_days NUMERIC(18,0)
													DECLARE @Min_Present_days_per_wise NUMERIC(18,2)
																			
													IF @Date_Of_Join > @Month_St_Date
														SET @Yearly_days = DATEDIFF(D,@Date_Of_Join,@Month_END_Date) + 1
													ELSE
														SET @Yearly_days = DATEDIFF(D,@Month_St_Date,@Month_END_Date) + 1
																				

													
													SET @Yearly_days = @Yearly_days -  (@WO_Days + @HO_Days)
													SET  @Min_Present_days_per_wise = @Yearly_days * @Min_Present_Days / 100
													
													

													IF IsNull(@P_Days,0) >= IsNull(@Min_Present_days_per_wise,0)
														BEGIN
															IF @Is_FNF = 1
																BEGIN 
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
																END
															ELSE
																BEGIN
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  																			
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @Leave_ID, CASE WHEN @Duration = 'Yearly' THEN @For_Date  ELSE @CF_For_Date END , @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
																END
														END	
													ELSE
														BEGIN
															IF @Is_FNF = 1
																BEGIN 
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@is_fnf,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
																END
															ELSE
																BEGIN
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @Leave_ID, CASE WHEN @Duration = 'Yearly' THEN @For_Date  ELSE @CF_For_Date END , @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
																END
														END 								
												END
											ELSE
												BEGIN
												
													IF IsNull(@P_Days,0) >= IsNull(@Min_Present_Days,0)
														BEGIN
															---- Carry Forward Entry		
															IF @Is_FNF = 1
																BEGIN 
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
																END
															ELSE
																BEGIN
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @Leave_ID, CASE WHEN @Duration = 'Yearly' THEN @For_Date  ELSE @CF_For_Date END , @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
																END
														END 
												END
										END
									ELSE
										BEGIN 
											---- Carry Forward Entry	
											--SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL  

											IF @Is_FNF = 1
												BEGIN    
													INSERT INTO #LEAVE_CF_DETAIL  
														( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
													VALUES 
														( @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
												END
											ELSE
												BEGIN
												
													INSERT INTO #LEAVE_CF_DETAIL  
														( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance,Advance_Leave_Recover_balance,Is_Advance_Leave_Balance)  
													VALUES 
														( @Cmp_ID, @Emp_ID, @Leave_ID,CASE WHEN @Duration = 'Yearly' THEN @For_Date  ELSE @CF_For_Date END , @Month_St_Date, @Month_END_Date, isnull(@P_Days,0), isnull(@Leave_CF_Days,0), @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Balance ELSE 0 END),(CASE WHEN @Is_Advance_Leave_Balance = 1 THEN @Advance_Leave_Recover_balance ELSE 0 END),@Is_Advance_Leave_Balance)  
						
														 
												END
											---- END ----											
										END
								END
						END
					ELSE
						BEGIN
							IF @Default_Short_Name = 'COMP'
								BEGIN
									IF @Flag = 1 
										BEGIN
											IF @Tran_Leave_ID > 0 
												BEGIN
													SET @Leave_CF_Type  = 'COMP'					
															 	
													DELETE FROM #temp_CompOff
															 
													EXEC GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@EMP_ID,@LEave_ID,0,0,2	
															 
													DECLARE @Leave_CompOff_Dates AS VARCHAR(MAX)
													SET @Leave_CompOff_Dates = ''
													DECLARE @CompOff_Closing_Balance AS NUMERIC(18,2)
													SET @CompOff_Closing_Balance = 0
															
													SELECT @Leave_CompOff_Dates = IsNull(CompOff_String,''),@CompOff_Closing_Balance = IsNull(Leave_Closing,0) FROM #temp_CompOff
																
													IF @CompOff_Closing_Balance > 0 
														BEGIN
															IF @Apply_Hourly = 1
																SET @CompOff_Closing_Balance = @CompOff_Closing_Balance * 0.125
														END 
															 
													IF 	@CompOff_Closing_Balance > 0 
														BEGIN
															-- SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL  
															IF @Is_FNF = 1
																BEGIN    
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,Leave_CompOff_Dates,is_fnf)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @tran_Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, isnull(@CompOff_Closing_Balance,0), @CompOff_Closing_Balance, @Leave_CF_Type, @Exceed_CF_Days,@Leave_CompOff_Dates,@Is_FNF)  
																END
															ELSE
																BEGIN 
																	INSERT INTO #LEAVE_CF_DETAIL  
																		( Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,Leave_CompOff_Dates,is_fnf)  
																	VALUES 
																		( @Cmp_ID, @Emp_ID, @tran_Leave_ID,CASE WHEN @Duration = 'Yearly' THEN @For_Date  ELSE @CF_For_Date END , @Month_St_Date, @Month_END_Date, isnull(@CompOff_Closing_Balance,0), @CompOff_Closing_Balance, @Leave_CF_Type, @Exceed_CF_Days,@Leave_CompOff_Dates,@Is_FNF)  
																END
														END
												END
										END	
								END
						END
					
					FETCH NEXT FROM curLeave INTO @Leave_ID,@Leave_Max_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@Max_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@MinPDays_Type,@Default_Short_Name,@Tran_Leave_ID,@Apply_Hourly,@Allowed_CF_Join_After_Day,@Add_Alt_WO_Carry_Fwd
				END  
			  
			CLOSE curLeave  
			DEALLOCATE curLeave  				
			  
			FETCH NEXT FROM curEmp INTO @Emp_ID,@Grd_ID,@Branch_ID,@Type_ID,@Emp_Left_Date,@Date_Of_Join,@Fix_Salary       
	    END 
	    
   CLOSE curEmp  
   DEALLOCATE curEmp  
   
   
   IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID = @P_LeavE_ID AND IsNull(Default_Short_Name,'') = 'COMP')
		BEGIN
			SELECT @P_LeavE_ID = Trans_Leave_ID FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID = @P_LeavE_ID AND IsNull(Default_Short_Name,'') = 'COMP' 			
		END
   
	--  IF @Is_FNF = 1
	--BEGIN
	--	   SELECT Leave_CF_ID,CF_LEAVE_Days,CF_P_DAYS,cf_type,Leave_ID,Emp_ID FROM t0100_leave_cf_detail   
	--	   WHERE cf_from_date =@Month_St_Date AND cf_to_date = @Month_END_Date AND Cmp_ID =@Cmp_ID 
	--	   AND LeavE_ID = IsNull(@P_LeavE_ID,LeavE_ID) AND Emp_ID = @Emp_Id AND LEAVE_CF_ID not IN (SELECT tran_id FROM #Old_CF) 
	--END
	--  ELSE
	--BEGIN
	-- 	   SELECT Leave_CF_ID,CF_LEAVE_Days,CF_P_DAYS,cf_type,Leave_ID,Emp_ID FROM t0100_leave_cf_detail   
	--	   WHERE cf_from_date =@Month_St_Date AND cf_to_date = @Month_END_Date AND Cmp_ID =@Cmp_ID 
	--	   AND LeavE_ID = IsNull(@P_LeavE_ID,LeavE_ID) ORDER BY emp_ID ASC  
	--END

	
	
	IF @HasTable = 0
		BEGIN 
		
			if @Is_Advance_Leave_Balance = 0
			begin 
				
					SELECT	--CF.*, 
						IsNull(CFD.LEAVE_CF_ID,CF.LEAVE_CF_ID) AS LEAVE_CF_ID,
						IsNull(CFD.Cmp_ID,CF.Cmp_ID) AS Cmp_ID,
						IsNull(CFD.Emp_ID,CF.Emp_ID) AS Emp_ID,
						IsNull(CFD.Leave_ID,CF.Leave_ID) AS Leave_ID,
						IsNull(CFD.CF_For_Date,CF.CF_For_Date) AS CF_For_Date,
						IsNull(CFD.CF_From_Date,CF.CF_From_Date) AS CF_From_Date,
						IsNull(CFD.CF_To_Date,CF.CF_To_Date) AS CF_To_Date,
						IsNull(CFD.CF_P_Days,CF.CF_P_Days) AS CF_P_Days,
						IsNull(CFD.CF_Leave_Days,CF.CF_Leave_Days) AS CF_Leave_Days,
						IsNull(CFD.CF_Type,CF.CF_Type) AS CF_Type,
						IsNull(CFD.Exceed_CF_Days,CF.Exceed_CF_Days) AS Exceed_CF_Days,
						IsNull(CFD.Leave_CompOff_Dates,CF.Leave_CompOff_Dates) AS Leave_CompOff_Dates,
						IsNull(CFD.Is_Fnf,CF.Is_Fnf) AS Is_Fnf,
						EM.Alpha_Emp_Code,em.Emp_Full_Name,LM.Leave_Name,
						CASE WHEN DATEDIFF(DD,EM.date_of_join,@To_Date) < 30 THEN 1 ELSE 0 END AS new_join_flag,
						--,CASE WHEN DATEDIFF(DD,EM.date_of_join,@To_Date) < 1916 THEN 1 ELSE 0 END AS new_join_flag,
						EM.date_of_join,DATEDIFF(DD,EM.date_of_join,@To_Date)  AS diff,
						--@Advance_Leave_Balance AS Advance_leave_Balance,
						--@Advance_Leave_Recover_balance AS Advance_Leave_Recover_balance,
						--@Is_Advance_Leave_Balance AS Is_Advance_Leave_Balance
						CF.Advance_Leave_Balance AS Advance_leave_Balance,
						CF.Advance_Leave_Recover_balance AS Advance_Leave_Recover_balance,
						CF.Is_Advance_Leave_Balance AS Is_Advance_Leave_Balance
				FROM	#LEAVE_CF_DETAIL CF 
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON CF.Emp_ID = Em.Emp_ID 
						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON CF.Leave_ID = LM.Leave_ID
						LEFT JOIN T0100_LEAVE_CF_DETAIL CFD WITH (NOLOCK) ON CF.Emp_ID = CFD.Emp_ID AND CF.Leave_ID = CFD.Leave_ID AND CF.cf_from_date = CFD.cf_from_date 
									AND  CF.CF_To_Date = CFD.CF_To_Date
				WHERE CFD.LEAVE_CF_ID IS NULL	--ADDED BY RAMIZ ON 02/03/2019 AFTER DISCUSSION WITH HARDIK BHAI , TO RESTRICT TRANSACTION ERRORS
				ORDER BY Em.Alpha_Emp_Code
			end
			else
			begin 
				SELECT	--CF.*, 
						IsNull(CFD.LEAVE_CF_ID,CF.LEAVE_CF_ID) AS LEAVE_CF_ID,
						IsNull(CFD.Cmp_ID,CF.Cmp_ID) AS Cmp_ID,
						IsNull(CFD.Emp_ID,CF.Emp_ID) AS Emp_ID,
						IsNull(CFD.Leave_ID,CF.Leave_ID) AS Leave_ID,
						IsNull(CFD.CF_For_Date,CF.CF_For_Date) AS CF_For_Date,
						IsNull(CFD.CF_From_Date,CF.CF_From_Date) AS CF_From_Date,
						IsNull(CFD.CF_To_Date,CF.CF_To_Date) AS CF_To_Date,
						IsNull(CFD.CF_P_Days,CF.CF_P_Days) AS CF_P_Days,
						0.00 AS CF_Leave_Days,
						IsNull(CFD.CF_Type,CF.CF_Type) AS CF_Type,
						IsNull(CFD.Exceed_CF_Days,CF.Exceed_CF_Days) AS Exceed_CF_Days,
						IsNull(CFD.Leave_CompOff_Dates,CF.Leave_CompOff_Dates) AS Leave_CompOff_Dates,
						IsNull(CFD.Is_Fnf,CF.Is_Fnf) AS Is_Fnf,
						EM.Alpha_Emp_Code,em.Emp_Full_Name,LM.Leave_Name,
						CASE WHEN DATEDIFF(DD,EM.date_of_join,@To_Date) < 30 THEN 1 ELSE 0 END AS new_join_flag,
						--,CASE WHEN DATEDIFF(DD,EM.date_of_join,@To_Date) < 1916 THEN 1 ELSE 0 END AS new_join_flag,
						EM.date_of_join,DATEDIFF(DD,EM.date_of_join,@To_Date)  AS diff,
						--@Advance_Leave_Balance AS Advance_leave_Balance,
						--@Advance_Leave_Recover_balance AS Advance_Leave_Recover_balance,
						--@Is_Advance_Leave_Balance AS Is_Advance_Leave_Balance
						CF.Advance_Leave_Balance AS Advance_leave_Balance,
						CF.Advance_Leave_Recover_balance AS Advance_Leave_Recover_balance,
						CF.Is_Advance_Leave_Balance AS Is_Advance_Leave_Balance
				FROM	#LEAVE_CF_DETAIL CF 
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON CF.Emp_ID = Em.Emp_ID 
						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON CF.Leave_ID = LM.Leave_ID
						LEFT JOIN T0100_LEAVE_CF_DETAIL CFD WITH (NOLOCK) ON CF.Emp_ID = CFD.Emp_ID AND CF.Leave_ID = CFD.Leave_ID AND CF.cf_from_date = CFD.cf_from_date 
									AND  CF.CF_To_Date = CFD.CF_To_Date
				WHERE CFD.LEAVE_CF_ID IS NULL	--ADDED BY RAMIZ ON 02/03/2019 AFTER DISCUSSION WITH HARDIK BHAI , TO RESTRICT TRANSACTION ERRORS
				ORDER BY Em.Alpha_Emp_Code
			end

			
		END
   
RETURN
