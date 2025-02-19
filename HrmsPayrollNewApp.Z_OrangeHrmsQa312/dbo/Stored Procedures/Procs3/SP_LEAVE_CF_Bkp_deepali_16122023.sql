
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create  PROCEDURE [dbo].[SP_LEAVE_CF_Bkp_deepali_16122023]  
	@leave_Cf_ID	NUMERIC(18,0) OUTPUT,  
	@Cmp_ID			NUMERIC ,  
	@From_Date		DATETIME,  
	@To_Date		DATETIME,  
	@For_Date		DATETIME,  
	@Branch_ID		NUMERIC,  
	@Cat_ID			NUMERIC,  
	@Grd_ID			NUMERIC,  
	@Type_ID		NUMERIC,  
	@Dept_ID		NUMERIC,  
	@Desig_ID		NUMERIC,  
	@Emp_Id			NUMERIC ,  
	@Constraint		VARCHAR(MAX)='',  
	@P_LeavE_ID		NUMERIC, 
	@Is_FNF			INT = 0,   --Added by Falak ON 02-FEB-2011 
	@Inc_HOWO		INT=0 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
      
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
 
	---- To Calculate Present Days
	CREATE table #Data     
	(     
		Emp_Id     NUMERIC ,     
		For_date   DATETIME,    
		Duration_in_sec  NUMERIC,    
		Shift_ID   NUMERIC ,    
		Shift_Type   NUMERIC ,    
		Emp_OT    NUMERIC ,    
		Emp_OT_min_Limit NUMERIC,    
		Emp_OT_MAX_Limit NUMERIC,    
		P_days    NUMERIC(12,1) default 0,    
		OT_Sec    NUMERIC default 0,
		In_Time DATETIME default NULL,
		Shift_Start_Time DATETIME default NULL,
		OT_Start_Time NUMERIC default 0,
		Shift_Change tinyint default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  NUMERIC default 0,
		Holiday_OT_Sec  NUMERIC default 0	,
		Chk_By_Superior NUMERIC default 0,
		IO_Tran_Id	   NUMERIC default 0,
		OUT_Time DATETIME,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time NUMERIC default 0,		--Ankit 16112013 
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_END_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	 )    
	 ---- END ---- 
 
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)       
		
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,
								@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,
								@constraint=@constraint,@SalScyle_Flag=3,@Type=0
		
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);

	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution = 1;
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

			SET @Required_Execution = 1;
		END

	IF @Required_Execution = 1
		BEGIN
			DECLARE @HW_FROM_DATE DATETIME
			DECLARE @HW_TO_DATE DATETIME
			
			SET @HW_FROM_DATE = DATEADD(D,-15, @FROM_DATE)
			SET @HW_TO_DATE = DATEADD(D,15, @TO_DATE)

			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@HW_FROM_DATE, @TO_DATE=@HW_TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		
		END 

 --DECLARE #Emp_Cons Table  
 --(  
 -- Emp_ID NUMERIC  
 --)   
   
 --IF @Constraint <> ''  
	--BEGIN  
	--	INSERT INTO #Emp_Cons(Emp_ID)  
	--	SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#')   
	--END  
 --ELSE  
	--BEGIN  
	--	INSERT INTO #Emp_Cons(Emp_ID)  
	 
	--	SELECT I.Emp_Id FROM T0095_Increment I INNER JOIN   
	--	 ( SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment  
	--	 WHERE Increment_Effective_date <= @To_Date  
	--	 AND Cmp_ID = @Cmp_ID  
	--	 GROUP BY emp_ID  ) QRY ON  
	--	 I.Emp_ID = QRY.Emp_ID AND I.Increment_effective_Date = QRY.For_Date   
		     
	--	WHERE Cmp_ID = @Cmp_ID   
	--	AND IsNull(Cat_ID,0) = IsNull(@Cat_ID ,IsNull(Cat_ID,0))  
	--	AND Branch_ID = IsNull(@Branch_ID ,Branch_ID)  
	--	AND Grd_ID = IsNull(@Grd_ID ,Grd_ID)  
	--	AND IsNull(Dept_ID,0) = IsNull(@Dept_ID ,IsNull(Dept_ID,0))  
	--	AND IsNull(Type_ID,0) = IsNull(@Type_ID ,IsNull(Type_ID,0))  
	--	AND IsNull(Desig_ID,0) = IsNull(@Desig_ID ,IsNull(Desig_ID,0))  
	--	AND I.Emp_ID = IsNull(@Emp_ID ,I.Emp_ID)   
	--	AND I.Emp_ID IN (SELECT Emp_Id FROM (SELECT emp_id, cmp_ID, join_Date, IsNull(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN) QRY  
	--	WHERE cmp_ID = @Cmp_ID   AND    
	--	(( @FROM_Date  >= join_Date  AND  @FROM_Date <= left_date )   
	--	or ( @To_Date  >= join_Date  AND @To_Date <= left_date )  
	--	or Left_date IS NULL AND @To_Date >= Join_Date)  
	--	or @To_Date >= left_date  AND  @FROM_Date <= left_date )   
	--END  

    
	DECLARE @Leave_ID			NUMERIC   
	DECLARE @Leave_MAX_Bal		NUMERIC(18,2)  
	DECLARE @Leave_CF_Type		VARCHAR(20)  
	DECLARE @Leave_PDays		NUMERIC(12,2)  
	DECLARE @Leave_get_Against_PDays NUMERIC(12,2)  
	DECLARE @Leave_Precision	NUMERIC(2)   
	DECLARE @P_Days				NUMERIC(12,1)  
	DECLARE @Leave_CF_Days		NUMERIC(5,2)  
	DECLARE @Leave_Closing		NUMERIC(12,2)  
	DECLARE @CF_Full_Days		NUMERIC(1,0)  
	DECLARE @CF_Days			NUMERIC(12,2)  
	DECLARE @C_Paid_Days		NUMERIC(5,2)
	DECLARE @Weekoff_Days		NUMERIC(12,2)
	DECLARE @UnPaid_Days		NUMERIC(12,2)
	DECLARE @Working_Days		NUMERIC(12,2)
	DECLARE @Leave_Paid_Days	NUMERIC(5,2)
	--DECLARE @Leave_CF_ID NUMERIC   
  
	----Alpesh 30-Apr-2012
	DECLARE @Is_Cancel_Holiday  NUMERIC(1,0)    
	DECLARE @Is_Cancel_Weekoff  NUMERIC(1,0)
	DECLARE @Left_Date			DATETIME     
	--DECLARE @StrHoliday_Date	VARCHAR(MAX)    
	--DECLARE @StrWeekoff_Date	VARCHAR(MAX)
	DECLARE @Cancel_Weekoff		NUMERIC(18, 0)
	DECLARE @Cancel_Holiday		NUMERIC(18, 0)
	DECLARE @Emp_Left_Date		DATETIME
  
	DECLARE @Is_CF_On_Sal_Days	tinyint
	DECLARE @Days_As_Per_Sal_Days tinyint
	DECLARE @MAX_Accumulate_Balance	NUMERIC(18, 2)
	DECLARE @Min_Present_Days	 NUMERIC(18, 2)
	DECLARE @CF_Effective_Date DATETIME
	DECLARE @CF_Type_ID		 NUMERIC(18, 0)
	DECLARE @Reset_Months		 NUMERIC(18, 0)
	DECLARE @Duration			 VARCHAR(15)
	DECLARE @CF_Months		 nVARCHAR(50)
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
	DECLARE @MAX_CF_Date AS DATETIME --Added By Ramiz ON 12/05/2016
	DECLARE @Is_Advance_Leave NUMERIC(1,0) --Added by nilesh Patel ON 11072016 
	----END----
  
	SET @Is_Cancel_Weekoff = 0    
	SET @Is_Cancel_Holiday = 0    
	--SET @StrHoliday_Date = ''    
	--SET @StrWeekoff_Date = ''  
	SET @flag = 0
	SET @Leave_Paid_Days = 0  
	SET @MinPDays_Type = 0 
	SET @Date_Of_Join = NULL -- Added by Gadriwala Muslim 10022015
	SET @MAX_CF_Date = NULL --Added By Ramiz ON 12/05/2016
	SET @Is_Advance_Leave = 0

	SELECT @Inc_HOWO = IsNull(Is_Ho_Wo,0),@Is_Advance_Leave = IsNull(Is_Advance_Leave_Balance,0) FROM Dbo.T0040_Leave_Master WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID            
	SELECT @Inc_Holiday = IsNull(Including_Holiday,0) FROM Dbo.T0040_Leave_Master WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID  --Added by nilesh Patel ON 28032015                
	SELECT @Inc_Weekoff = IsNull(Including_WeekOff,0) FROM Dbo.T0040_Leave_Master WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id AND Leave_Id=@P_LeavE_ID  --Added by nilesh Patel ON 28032015                   
	
	CREATE table #Old_CF 
	(
		tran_id    NUMERIC(18,0),
		emp_id     NUMERIC(18,0),
		for_date   DATETIME
	);
  
	-- Added By Gadriwala Muslim 18022015	
	CREATE TABLE #Temp_CompOff
	(
		Leave_opening	decimal(18,2),
		Leave_Used		decimal(18,2),
		Leave_Closing	decimal(18,2),
		Leave_Code		VARCHAR(MAX),
		Leave_Name		VARCHAR(MAX),
		Leave_ID		NUMERIC,
		CompOff_String  VARCHAR(MAX) default NULL -- Added by Gadriwala 18022015
	)	
	
	--Added by Jaina 27-09-2017
	if @Is_FNF = 1 
	BEGIN
		if exists(SELECT 1 from sys.procedures where name='P_Validate_Leave_SLS')
			RETURN
	end														

	IF @Is_FNF = 1 
		BEGIN
			INSERT	INTO #Old_CF
			SELECT	Leave_CF_ID,Emp_ID,CF_For_Date 
			FROM	t0100_leave_cf_detail  WITH (NOLOCK) 
			WHERE	Cmp_ID =@Cmp_ID AND Emp_ID = @Emp_Id 
			ORDER BY emp_ID ASC  
		END
	Declare @OD_Compoff_As_Present tinyint
	Set @OD_Compoff_As_Present = 0
				
	Select @OD_Compoff_As_Present = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name='OD and CompOff Leave Consider As Present'				

	         
	DECLARE curEmp CURSOR FAST_FORWARD FOR   
	--SELECT	I.Emp_Id ,I.Grd_ID, I.Branch_ID,I.Type_ID,Emp_Left_Date,Date_Of_Join 
	--FROM	T0095_INCREMENT I 
	--		INNER JOIN (SELECT	MAX(Increment_effective_Date) AS For_Date,Emp_ID 
	--					FROM	T0095_INCREMENT 
	--					WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID 
	--					GROUP BY Emp_ID) QRY ON I.Emp_ID = QRY.Emp_ID AND I.Increment_effective_Date = QRY.For_Date 
	--		INNER JOIN #Emp_Cons EC ON i.emp_ID = EC.emp_ID 
 --   INNER JOIN T0080_EMP_MASTER e ON e.emp_ID=ec.emp_ID WHERE I.Cmp_ID = @Cmp_ID   
	
	--Added By jimit 19092018 as case at acculife same date increment calculate encashment amount twice   
	select I.Emp_Id ,I.Grd_ID, I.Branch_ID,I.Type_ID,Emp_Left_Date,Date_Of_Join 
	from   T0095_Increment I  WITH (NOLOCK) INNER JOIN
	       (										
		   SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 									
		   FROM	    T0095_Increment I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment											
		            INNER JOIN (
					             SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								 FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID
								 WHERE I3.Increment_effective_Date <= @to_date AND I3.Cmp_ID =@Cmp_ID	
								 GROUP BY I3.EMP_ID  					
								) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID	
		    GROUP BY I2.Emp_ID										
			) I_Q ON I.Emp_ID = I_Q.Emp_ID AND I.Increment_ID=I_Q.Increment_ID inner join
			 #Emp_Cons ec on i.emp_ID =ec.emp_ID inner join 
			T0080_EMP_MASTER e WITH (NOLOCK) on e.emp_ID=ec.emp_ID Where I.Cmp_ID = @Cmp_ID	
	--ended		
	OPEN curEmp  
	FETCH NEXT FROM curEmp INTO @Emp_ID,@Grd_ID,@Branch_ID,@Type_ID,@Emp_Left_Date,@Date_Of_Join   
	WHILE @@FETCH_STATUS =0  
		BEGIN  
			SET @C_Paid_Days = 0			
			SET @Weekoff_Days = 0
			SET @UnPaid_Days = 0
			SET @Working_Days = 0
			SET @P_Days = 0
			
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
			DECLARE @is_leave_CF_Prorata tinyint
			DECLARE @Default_Short_Name VARCHAR(10) -- Added by Gadriwala 23022015
			DECLARE @Tran_Leave_ID NUMERIC(18,0) -- Added by Gadriwala 23022015
			--Hardik 19/09/2012		  
			DECLARE @bln_Flag AS VARCHAR(3)
			DECLARE @Date AS DATETIME
			
			SET @Default_Short_Name = ''  -- Added by Gadriwala 23022015
			SET @Apply_Hourly = 0 -- Added by Gadriwala 23022015

			IF @Branch_ID IS NULL
				BEGIN 
					SELECT	TOP 1 @Sal_St_Date = Sal_st_Date,@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,
							@Is_CF_On_Sal_Days = Is_CF_On_Sal_Days, @Days_As_Per_Sal_Days = Days_As_Per_Sal_Days 
					FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
					WHERE	Cmp_ID = @cmp_ID AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@From_Date AND Cmp_ID = @Cmp_ID)    
				END
			ELSE
				BEGIN
					SELECT	@Sal_St_Date = Sal_st_Date,@Is_Cancel_Holiday = Is_Cancel_Holiday,@Is_Cancel_Weekoff = Is_Cancel_Weekoff,
							@Is_CF_On_Sal_Days = Is_CF_On_Sal_Days, @Days_As_Per_Sal_Days = Days_As_Per_Sal_Days 
					FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
					WHERE	Cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID 
							AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@From_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
				END    
		
		
				
			DECLARE curLeave CURSOR FAST_FORWARD FOR   
			SELECT	LM.Leave_ID,LM.Leave_Max_Bal,Leave_CF_Type,Leave_PDays,Leave_Get_Against_PDays,IsNull(Leave_Precision,0) AS Leave_Precision,
					Leave_Days,LM.Max_Accumulate_Balance,Min_Present_Days,Is_Leave_CF_Rounding,Is_Leave_CF_Prorata,QRY.Effective_Date,CF.CF_Type_ID,
					CF.Reset_Months,CF.Duration,CF.CF_Months,CF.Release_Month,CF.Reset_Month_String,LM.MinPdays_Type,
					IsNull(LM.Default_Short_Name ,'') AS Default_Short_Name,LM.Trans_Leave_ID,IsNull(LM.Apply_Hourly,0) As Apply_Hourly
			FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
					INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON LM.Leave_ID = LD.Leave_ID
					INNER JOIN T0050_CF_EMP_TYPE_DETAIL cf WITH (NOLOCK) ON CF.Leave_ID=LM.Leave_ID
					INNER JOIN (SELECT	MAX(Effective_Date) AS Effective_Date,Leave_ID 
								FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
								WHERE	Cmp_ID=@Cmp_ID AND Leave_ID=@P_LeavE_ID 
								GROUP BY Leave_ID) QRY ON QRY.Leave_ID=CF.Leave_ID AND QRY.Effective_Date=CF.Effective_Date
			WHERE	LM.cmp_ID =@Cmp_ID AND Grd_ID =@Grd_ID AND LM.leave_ID = IsNull(@P_LeavE_ID,LM.leave_ID)  
					AND LeavE_Paid_Unpaid ='P' AND CF.Type_ID=@Type_ID AND LM.Leave_CF_Type <> 'None'

			OPEN curLeave   
			FETCH NEXT FROM curLeave INTO @Leave_ID,@Leave_MAX_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@MAX_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@MinPDays_Type,@Default_Short_Name,@Tran_Leave_ID,@Apply_Hourly
			WHILE @@FETCH_STATUS = 0  
				BEGIN  
					-- Added by Ali 21042014 -- State				
					IF EXISTS(SELECT Min_Leave_CF FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID)
						BEGIN
							DECLARE @Min_Leave_CF_Temp AS NUMERIC(18,1)
							SELECT  @Min_Leave_CF_Temp = Min_Leave_CF 
							FROM	T0050_LEAVE_DETAIL WITH (NOLOCK)
							WHERE	Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID
									
							IF @Min_Leave_CF_Temp > 0
								SET @Leave_MAX_Bal = @Min_Leave_CF_Temp
						END
							
					IF EXISTS(SELECT MAX_Accumulate_Balance FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID)
						BEGIN
							DECLARE @MAX_Accumulate_Balance_Temp AS NUMERIC(18,1)
							SELECT  @MAX_Accumulate_Balance_Temp = MAX_Accumulate_Balance FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Grd_ID = @Grd_ID AND Leave_ID = @P_LeavE_ID AND Cmp_ID = @Cmp_ID
									
							IF @MAX_Accumulate_Balance_Temp > 0
								SET @MAX_Accumulate_Balance = @MAX_Accumulate_Balance_Temp
						END
							
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
									IF EXISTS(SELECT 1 FROM dbo.Split2(@CF_Months,'#') WHERE items>=MONTH(@For_Date)) AND @Duration <> 'Yearly' --Condition Added by Hardik 20/02/2017 AS it will giving wrong date for Yearly (Wonder F&F Case)
										BEGIN 
											SELECT	@For_Date=dbo.GET_MONTH_ST_DATE(MIN(CAST(items AS NUMERIC)),YEAR(@For_Date)) 
											FROM	dbo.Split2(@CF_Months,'#') 
											WHERE	items>=MONTH(@For_Date)
										END
									ELSE
										BEGIN		
											SELECT	@For_Date=dbo.GET_MONTH_ST_DATE(MIN(CAST(items AS NUMERIC)),YEAR(dateadd(yy,1,@For_Date))) 
											FROM	dbo.Split2(@CF_Months,'#')
										END
								END
						END
									
					IF @Duration = 'Yearly' or @Duration = 'Half Yearly' or @Duration = 'Quarterly'
						BEGIN
							IF @Days_As_Per_Sal_Days = 0
								BEGIN
									SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
									SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))																								
								END
							ELSE
								BEGIN
									IF @Sal_St_Date <> ''  AND day(@Sal_St_Date) > 1   
										BEGIN
											SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))																																		
											SET @Month_END_Date = CAST(CAST(day(@Sal_St_Date)-1 AS VARCHAR(5)) + '-' + CAST(datename(mm,@Month_END_Date) AS VARCHAR(10)) + '-' +  CAST(YEAR(@Month_END_Date) AS VARCHAR(10)) AS smallDATETIME)    
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))
											SET @Month_St_Date  = CAST(CAST(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(datename(mm,dateadd(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(dateadd(m,-1,@Month_St_Date) ) AS VARCHAR(10)) AS smallDATETIME)    
										END
									ELSE IF IsNull(@Sal_St_Date,'') = '' or day(@Sal_St_Date) = 1
										BEGIN
											SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(DATEADD(m,-@tmpPeriod,@Month_END_Date)),YEAR((DATEADD(m,-@tmpPeriod,@Month_END_Date))))
										END 
								END
								
								IF CHARINDEX('#'+CAST(MONTH(@For_Date) AS varchar)+'#','#'+@CF_Months+'#') > 0
									BEGIN	
										SET @flag = 1
									END
							--ELSE
							--	BEGIN
							--		raiserror('You Cannot Carry Forward IN This Month.',16,2)
							--		return -1
							--	END
						END	
					ELSE
						BEGIN
							IF @Days_As_Per_Sal_Days = 0
								BEGIN
									SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
									SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))										
								END
							ELSE
								BEGIN
									IF @Sal_St_Date <> ''  AND day(@Sal_St_Date) > 1   
										BEGIN
											SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
											SET @Month_END_Date = CAST(CAST(day(@Sal_St_Date)-1 AS VARCHAR(5)) + '-' + CAST(datename(mm,@Month_END_Date) AS VARCHAR(10)) + '-' +  CAST(YEAR(@Month_END_Date) AS VARCHAR(10)) AS smallDATETIME)    
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))
											SET @Month_St_Date  = CAST(CAST(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(datename(mm,dateadd(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(dateadd(m,-1,@Month_St_Date) ) AS VARCHAR(10)) AS smallDATETIME)    
										END
									ELSE IF IsNull(@Sal_St_Date,'') = '' or day(@Sal_St_Date) = 1
										BEGIN
											SET @Month_END_Date = DATEADD(d,-1,dbo.GET_MONTH_ST_DATE(MONTH(@For_Date),YEAR(@For_Date)))
											SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))
										END
								END
									
							SET @flag = 1
						END
					---- END ----				 	
				
					---- SET Month_END_Date IF It Is FNF
					IF @Is_FNF = 1
						BEGIN
							IF @Emp_Left_Date IS NOT NULL  -- Added by rohit ON 24102015 for cera for Credit Leave ON left month for Emp.
								BEGIN
									SET @Month_END_Date = dbo.GET_MONTH_END_DATE(MONTH(@Emp_Left_Date),YEAR(@Emp_Left_Date))
									IF @Month_End_Date < @Month_St_Date
										Set @Month_St_Date  = dbo.GET_MONTH_ST_DATE(month(DATEADD(m,-@tmpPeriod,@Month_End_Date)),year((DATEADD(m,-@tmpPeriod,@Month_End_Date)))) --Added by Rajput on 22122017 Case due to Leave Worker Privilege Leave count was wrong come when employee left in dec-2017(Hold salary)  And make FNF on Jan-2018 (CERA Client) 
										
									IF (@Duration ='Monthly') -- Added by rohit ON 23012016 for monthly type ON 23012016
										begin
										SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))
										end
								END
							
							IF @Emp_Left_Date IS NOT NULL AND @Emp_Left_Date > @Month_St_Date AND @Emp_Left_Date < @Month_END_Date
								begin
										SET @Month_END_Date = @Emp_Left_Date
										
										IF @Month_End_Date < @Month_St_Date
											Set @Month_St_Date  = dbo.GET_MONTH_ST_DATE(month(DATEADD(m,-@tmpPeriod,@Month_End_Date)),year((DATEADD(m,-@tmpPeriod,@Month_End_Date)))) --Added by Rajput on 22122017 Case due to Leave Worker Privilege Leave count was wrong come when employee left in dec-2017(Hold salary)  And make FNF on Jan-2018 (CERA Client) 
											
										IF (@Duration ='Monthly') -- Added by rohit ON 23012016 for monthly type ON 23012016
										begin
										SET @Month_St_Date  = dbo.GET_MONTH_ST_DATE(MONTH(@Month_END_Date),YEAR(@Month_END_Date))
										end
								end
						END
					---- END ----
						
					IF @Default_Short_Name <> 'COMP'
						BEGIN
							---- Get Leave Balance ----
							SELECT	@Leave_Closing = LEAVE_CLOSING 
							FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
									INNER JOIN (SELECT	MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID 
												FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
												WHERE	EMP_ID = @EMP_ID AND FOR_DATE <= @Month_END_Date 
												GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
									INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID AND IsNull(LM.Default_Short_Name,'') <> 'COMP'      
							WHERE	LT.LeavE_ID = @Leave_ID   
						
							IF @Leave_Closing IS NULL
								SET @Leave_Closing = 0
							---- END ----
							
							IF @Duration = 'Yearly' AND @Release_Month = MONTH(@Month_END_Date)
								BEGIN
									IF IsNull(@Reset_Months,0) > 0 -- Added by rohit for ReSET month zero not reSET the balance ON 04012013
										BEGIN
											---- For Reset	
											IF @Reset_Months <= 12
												BEGIN
													IF CHARINDEX('#'+CAST(MONTH(@For_Date) AS varchar)+'#','#'+@Reset_Month_String+'#') > 0
														BEGIN
															IF EXISTS(SELECT Leave_Tran_Id FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID AND IsNull(LM.Default_Short_Name,'') <> 'COMP'  WHERE Emp_ID=@Emp_Id AND LT.Leave_ID=@Leave_ID AND For_Date=@Month_END_Date )
																BEGIN
																	SELECT @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date=@Month_END_Date
																	
																	UPDATE T0140_LEAVE_TRANSACTION set
																		--Leave_Opening = 0,
																		Leave_Closing = 0,
																		Leave_Posting = @Leave_Closing
																	WHERE Leave_Tran_ID = @Leave_Tran_ID 
																END
															ELSE
																BEGIN												
																	IF @Default_Short_Name <> 'COMP' 
																		BEGIN
																			SELECT @Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
																					
																			INSERT INTO T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
																			VALUES(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_END_Date,@Leave_Closing,0,@Leave_Closing,0,@Leave_Closing)
																		END
																END
														END
												END
											ELSE
												BEGIN
													--Hardik 18/09/2012 for ReSET Year checking (added new SP)
													SET @bln_Flag = 'NO'
																	
													EXEC SP_CHECK_LEAVE_RESET_YEAR @For_Date, @CF_Effective_Date, @Reset_Months,@bln_Flag OUTPUT, @Date OUTPUT
																	
													--IF @Reset_Months = MONTH(@For_Date) AND YEAR(DATEADD(m,@Reset_Months,@Month_END_Date)) = YEAR(@For_Date)
													IF @Reset_Month_String = MONTH(@For_Date) AND @bln_Flag = 'YES'
														BEGIN
															--IF EXISTS(SELECT Leave_Tran_Id FROM T0140_LEAVE_TRANSACTION WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date=DATEADD(m,@Reset_Months,@Month_END_Date))
															IF EXISTS(SELECT Leave_Tran_Id FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID AND IsNull(LM.Default_Short_Name,'') <> 'COMP' WHERE Emp_ID=@Emp_Id AND LT.Leave_ID=@Leave_ID AND For_Date= @Month_END_Date)
																BEGIN
																	SELECT @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date = @Month_END_Date
																					
																	UPDATE	T0140_LEAVE_TRANSACTION 
																	SET		Leave_Closing = 0,
																			Leave_Posting = @Leave_Closing
																	WHERE	Leave_Tran_ID = @Leave_Tran_ID 
																END
															ELSE
																BEGIN
																	IF @Default_Short_Name <> 'COMP'
																		BEGIN
																			SELECT @Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
																					
																			INSERT INTO T0140_LEAVE_TRANSACTION
																				(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
																			VALUES
																				(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_END_Date,@Leave_Closing,0,@Leave_Closing,0,@Leave_Closing)
																		END	
																END
														END
												END  
											---- END ----
										END
								END

							IF @flag = 1
								BEGIN
									IF @CF_Type_ID = 1 or @CF_Type_ID = 3
										BEGIN
											---- Carry Forward ON Salary or Not
											IF @Is_CF_On_Sal_Days = 1
												BEGIN
													DECLARE @M_WO_Days NUMERIC(18,2)
													DECLARE @M_HO_Days NUMERIC(18,2)
																	
													SET @M_WO_Days = 0
													SET @M_HO_Days = 0
													SET @WO_Days = 0
													SET @HO_Days = 0
													
													If @Duration <> 'Yearly' --- Added condition by Hardik 24/02/2020 for Cera as Yearly Leave Period, not taking all months present if leave duration is yearly.
														BEGIN
															SELECT	@P_Days=SUM(Present_Days), @M_WO_Days=SUM(Weekoff_Days), @M_HO_Days=SUM(Holiday_Days), @Sal_cal_days = IsNull(SUM(Sal_Cal_Days),0) 
															FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
															WHERE	Emp_Id=@Emp_ID AND 
																	--Month_St_Date >= @Month_St_Date AND --Commented by Hardik 29/11/2017 for AIA, As they have changed Salary Cycle from 26 to 1st from Jan-2017 so January month is not coming
																	--Month_End_Date >= @Month_St_Date AND --Added by Hardik 29/11/2017 for AIA
																	--Month_St_Date <= @Month_END_Date	 --Commented by Nimesh On 08-Aug-2018 (Mid Left Case Not Working in Elsamax)
																	@Month_END_Date BETWEEN Month_St_Date AND Month_End_Date --If Employee is left on 25-Jun-2018 and Hold Salary is done for 01-Jun-2018 TO 30-Jun-2018. Then @Month_End_Date is taking value '2018-06-25' (Left Date) which will eliminate the condition.
														END
													ELSE
														BEGIN
															SELECT	@P_Days=SUM(Present_Days), @M_WO_Days=SUM(Weekoff_Days), @M_HO_Days=SUM(Holiday_Days), @Sal_cal_days = IsNull(SUM(Sal_Cal_Days),0) 
															FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
															WHERE	Emp_Id=@Emp_ID AND 
																	Month_End_Date >= @Month_St_Date AND --Added by Hardik 29/11/2017 for AIA
																	Month_St_Date <= @Month_END_Date	 --Commented by Nimesh On 08-Aug-2018 (Mid Left Case Not Working in Elsamax)
														END
																	
																		
													IF @Is_FNF = 1
														BEGIN
															SET @temp_month_st_date = dbo.GET_MONTH_ST_DATE(MONTH(@to_date),YEAR(@to_date))
															IF @Sal_St_Date <> '' AND day(@Sal_St_Date) > 1   
																BEGIN    
																	SET @Sal_St_Date =  CAST(CAST(day(@Sal_St_Date) AS VARCHAR(5)) + '-' + CAST(datename(mm,dateadd(m,-1,@temp_month_st_date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(dateadd(m,-1,@temp_month_st_date) ) AS VARCHAR(10)) AS smallDATETIME)    
																	SET @temp_month_st_date = @Sal_St_Date
																END	
															--Hardik 05/06/2020 for wonder.. same month join and left case.. weekoff taking more
															If @temp_month_st_date < @Date_Of_Join
																Set @temp_month_st_date = @Date_Of_Join

															--Hardik 24/09/2020 for wonder.. same month join and left case.. weekoff taking more
															If @To_Date > @Emp_Left_Date
																Set @To_Date = @Emp_Left_Date


															SELECT	@FNF_Pdays = IsNull(P_days,0) 
															FROM	T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK)
															WHERE	Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_ID AND Month = MONTH(@To_Date) AND Year = YEAR(@To_Date)
																	
															--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@temp_month_st_date,@To_Date,null,@To_Date,0,'',@StrWeekoff_Date OUTPUT,@WO_Days OUTPUT ,@Cancel_Weekoff OUTPUT         
															--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@temp_month_st_date,@To_Date,null,@To_Date,0,@StrHoliday_Date OUTPUT,@HO_Days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date  	 
															SELECT	@WO_Days = SUM(W_DAY)
															FROM	#EMP_WEEKOFF W
															WHERE	Emp_ID = @Emp_Id AND For_Date BETWEEN @temp_month_st_date AND @To_Date
															
															SELECT	@HO_Days = SUM(H_DAY)
															FROM	#EMP_HOLIDAY W
															WHERE	Emp_ID = @Emp_Id AND For_Date BETWEEN @temp_month_st_date AND @To_Date
														END
																			
													SET @WO_Days = IsNull(@WO_Days,0) + IsNull(@M_WO_Days,0)
													SET @HO_Days = IsNull(@HO_Days,0) + IsNull(@M_HO_Days,0)														
																			
												END
											ELSE
												BEGIN
													IF @Is_FNF = 1 AND @Duration = 'Daily (On Present Day)' AND @Emp_Left_Date IS NOT NULL
														BEGIN
															SELECT @MAX_CF_DATE = MAX(CF_FOR_DATE) + 1 FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE   CMP_ID =@CMP_ID AND  EMP_ID = @EMP_ID
															SELECT @MONTH_ST_DATE = @MAX_CF_DATE
															SELECT @Month_END_Date = @EMP_LEFT_DATE
														END
																
													--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Date_Of_Join,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@WO_Days OUTPUT ,@Cancel_Weekoff OUTPUT    
													--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Month_St_Date,@Month_END_Date,@Date_Of_Join,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date OUTPUT,@HO_Days OUTPUT,@Cancel_Holiday OUTPUT,0,@Branch_ID,@StrWeekoff_Date
													SELECT	@WO_Days = SUM(W_DAY)
													FROM	#EMP_WEEKOFF W
													WHERE	Emp_ID = @Emp_Id AND For_Date BETWEEN @Month_St_Date AND @Month_END_Date
															
													SELECT	@HO_Days = SUM(H_DAY)
													FROM	#EMP_HOLIDAY W
													WHERE	Emp_ID = @Emp_Id AND For_Date BETWEEN @Month_St_Date AND @Month_END_Date		
																		
													EXEC SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Month_St_Date,@Month_END_Date,0,0,0,0,0,0,@emp_ID,'',4  
																		
													SELECT @P_Days = IsNull(SUM(P_Days),0) FROM #Data WHERE Emp_ID=@emp_ID AND For_Date>=@Month_St_Date AND For_Date <=@Month_END_Date  
												END										
											---- END ----
										END	
									---- Get Present Days,HO AND WO
														
									-- Comment By Nilesh Patel ON 28032015 --Start
									-- Add provision of SELECT Leave Details IN Leave Master So this Condition IS NOT Require (After Discuss with Hardik Bhai it is commented) 
									--SELECT @C_Paid_Days = IsNull(SUM(leave_used),0) FROM T0140_LEavE_Transaction WHERE Emp_Id =@Emp_ID 
									--AND For_Date >= @Month_St_Date AND For_Date <= @Month_END_Date AND Leave_ID IN 
									--(SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type ='Company Purpose' AND IsNull(Default_short_Name,'') <> 'COMP')
									-- Comment By Nilesh Patel ON 28032015 --END
														
									SET @C_Paid_Days = 0
														
									-- Comment by nilesh patel ON 28032015 --Start
									--SELECT @Leave_Paid_Days = IsNull(SUM(leave_used),0) FROM T0140_LEavE_Transaction WHERE Emp_Id = @Emp_ID  --added by hasmukh ON 03012013 for include paid leave IN prorate calculation
									--AND For_Date >= @Month_St_Date AND For_Date <= @Month_END_Date AND Leave_ID IN 
									--(SELECT Leave_ID FROM T0040_LEave_Master WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose' AND Leave_Paid_Unpaid = 'P' AND IsNull(Default_short_Name,'') <> 'COMP')
									-- Comment by nilesh patel ON 28032015 --Start
													  	
									--Added by nilesh patel ON 28032015 --Start
													  
									IF @Inc_HOWO = 1 
										BEGIN
											DECLARE @IncludingLeaveType VARCHAR(100)
											SELECT	@IncludingLeaveType = Including_Leave_Type 
											FROM	T0040_LEave_Master WITH (NOLOCK)
											WHERE	Leave_ID = @Leave_ID
											
											IF @IncludingLeaveType IS NOT NULL and @IncludingLeaveType <> ''--'' IF Including leave Checkbox is selected but Leave Type details are not Selected 
												BEGIN
													
													
													SELECT	@Leave_Paid_Days = (IsNull(SUM(leave_used),0) + IsNull(SUM(Back_Dated_Leave),0)) 
													FROM	T0140_LEavE_Transaction WITH (NOLOCK)
													WHERE	Emp_Id = @Emp_ID 
															AND	For_Date >= @Month_St_Date AND For_Date <= @Month_END_Date 
															AND	Leave_ID IN (	SELECT	Leave_ID 
																				FROM	T0040_LEave_Master  WITH (NOLOCK)
																				WHERE	Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' 
																						AND IsNull(Default_short_Name,'') <> 'COMP'  AND Leave_Type <> 'Company Purpose'
																						AND T0040_LEAVE_MASTER.Leave_ID IN (SELECT	CAST(Data AS NUMERIC(18,0)) 
																															FROM	dbo.Split((	SELECT	Including_Leave_Type 
																																				FROM	T0040_LEave_Master WITH (NOLOCK)
																																				WHERE	Leave_ID = @Leave_ID
																																				),'#')
																															)
																			)
													
												IF (@OD_Compoff_As_Present = 0)	--- Added by Hardik 07/01/2019 for Cera as they have included Compoff in Present so again adding Compoff in present		
													SELECT	@Leave_Paid_Days = IsNull(@Leave_Paid_Days,0) + IsNull(SUM(CompOff_Used),0) 
													FROM	T0140_LEavE_Transaction WITH (NOLOCK)
													WHERE	Emp_Id = @Emp_ID AND For_Date >= @Month_St_Date AND For_Date <= @Month_END_Date 
															AND Leave_ID IN (	SELECT	Leave_ID 
																				FROM	T0040_LEave_Master  WITH (NOLOCK)
																				WHERE	Cmp_Id =@Cmp_ID AND Leave_Paid_Unpaid = 'P' 
																						AND (IsNull(Default_short_Name,'') = 'COMP' OR Leave_Type = 'Company Purpose')
																						AND T0040_LEAVE_MASTER.Leave_ID IN(	SELECT	CAST(Data AS NUMERIC(18,0)) 
																															FROM	dbo.Split((SELECT	Including_Leave_Type 
																																				FROM	T0040_LEave_Master WITH (NOLOCK)
																																				WHERE	Leave_ID = @Leave_ID
																																			),'#')
																														)
																			)
																		
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
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)
											ELSE IF @Inc_HOWO = 1 AND @Inc_Holiday = 1 
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@HO_Days,0) + IsNull(@Leave_Paid_Days,0)
											ELSE IF @Inc_HOWO = 1 AND @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) + IsNull(@Leave_Paid_Days,0)
											ELSE IF @Inc_Holiday = 1 AND @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0) + IsNull(@HO_Days,0) 
											ELSE IF @Inc_Holiday = 1 
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@HO_Days,0) 
											ELSE IF @Inc_Weekoff = 1
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) + IsNull(@WO_Days,0)
											ELSE IF @Inc_HOWO = 1
												SET @P_Days = IsNull(@P_Days,0) + @C_Paid_Days + IsNull(@FNF_Pdays,0) +IsNull(@Leave_Paid_Days,0)
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
											--Added by nilesh patel ON 28032015 -END 
										END
									---- END ----						
												
									---- Carry Forward Type
									IF @CF_Type_ID = 1	---- Prorata
										BEGIN
											--Added by nilesh patel ON 02042015(Add provision ON Present getting Employee Type Wise)
			  								SELECT	@Leave_Pdays = IsNull(LCP.Present_Day,0),@Leave_Get_Against_PDays = IsNull(LCP.Leave_Again_Present_Day,0) 
											FROM	T0050_LEAVE_CF_Present_Day LCP WITH (NOLOCK)
													INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																FROM	T0050_LEAVE_CF_Present_Day  WITH (NOLOCK)
																WHERE	Cmp_ID = @Cmp_ID AND Leave_ID = @P_LeavE_ID AND Type_ID = @Type_ID 
																		AND Effective_Date <= @Month_END_Date 
																GROUP BY Leave_ID,Type_ID) QRY ON LCP.Effective_Date = QRY.Effective_Date AND LCP.Leave_ID = QRY.Leave_ID AND LCP.Type_ID = QRY.Type_ID
											WHERE	LCP.Cmp_ID = @Cmp_ID AND LCP.Leave_ID = @P_LeavE_ID AND LCP.Type_ID = @Type_ID AND LCP.Effective_Date <= @Month_END_Date

											IF @Leave_Get_Against_PDays > 0 AND @Leave_pDays > 0	
			  									BEGIN
			  										IF @is_leave_CF_Rounding = 1   --Added by hasmukh 21012012
			  											SET @Leave_CF_Days = Round(@P_Days * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays,0)  
			  										ELSE 
			  											SET @Leave_CF_Days = @P_Days * IsNull(@Leave_Get_Against_PDays,0)/@Leave_Pdays

												END
										END
									ELSE IF @CF_Type_ID = 2		---- Monthly Fix
										BEGIN
											IF @Is_FNF = 1
												BEGIN
													IF @Is_Advance_Leave = 1 AND @Duration = 'Yearly'
														BEGIN
															DECLARE @Leave_Days NUMERIC(18,2);
															SET @Leave_Days = 0
															DECLARE @Fix_Leave_Days NUMERIC(18,2);
															SET @Fix_Leave_Days = 0
																						
															SELECT	@Leave_Days = IsNull(CF_M_Days,0) 
															FROM	T0050_LEAVE_CF_MONTHLY_SETTING LCF WITH (NOLOCK)
																	INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																				FROM	T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
																				WHERE	MONTH(For_Date)= MONTH(@Month_END_Date) 
																				GROUP BY Leave_ID,Type_ID
																				)QRY ON LCF.Effective_Date=QRY.Effective_Date AND LCF.Leave_ID=QRY.Leave_ID AND LCF.Type_ID=QRY.Type_ID
															WHERE	LCF.Cmp_ID=@Cmp_ID AND LCF.Type_ID=@Type_ID AND LCF.Leave_ID=@P_LeavE_ID 
																	AND MONTH(LCF.For_Date) = (CASE WHEN @Release_Month = 1 THEN 12 ELSE @Release_Month - 1 END)
																	--AND YEAR(LCF.For_Date) = YEAR(@Month_END_Date)
																				
															SELECT	@Fix_Leave_Days = Advance_Leave_Balance 
															FROM	T0100_LEAVE_CF_Advance_Leave_Balance WITH (NOLOCK)
															WHERE	Emp_ID = @Emp_ID AND Leave_ID = @P_LeavE_ID AND @Month_END_Date Between CF_From_Date AND CF_To_Date
																				
																				
															IF @Fix_Leave_Days > 0
																BEGIN
																	IF @Leave_Days < @Fix_Leave_Days
																		SET @Leave_Days = @Fix_Leave_Days
																END
																				
															IF YEAR(@Date_Of_Join) = YEAR(@Emp_Left_Date)
																BEGIN
																	DECLARE @YEAR_ST_DATE_1 AS DATETIME
																	IF @Release_Month = 1
																		BEGIN
																			SET @Leave_CF_Days = (@Leave_Days/12) * (DATEDIFF(MONTH,@Date_Of_Join,@Emp_Left_Date) + 1)
																			SET @Leave_Get_Against_PDays = @Leave_Days
																		END
																	ELSE IF @Release_Month > 3
																		BEGIN
																			SET @YEAR_ST_DATE_1 = (CASE When MONTH(@Emp_Left_Date) > 3 Then
																											dbo.GET_YEAR_START_DATE(YEAR(@Emp_Left_Date) + 1, @Release_Month - 1,0)
																										ELSE
																											dbo.GET_YEAR_START_DATE(YEAR(@Emp_Left_Date), @Release_Month - 1,0)
																									END)
																								 
																			SET	@Leave_CF_Days = (@Leave_Days/12) * (DATEDIFF(MONTH,@YEAR_ST_DATE_1,@Emp_Left_Date) + 1)
																			SET @Leave_Get_Against_PDays = @Leave_Days
																		END
																END
															ELSE
																BEGIN
																	DECLARE @YEAR_ST_DATE AS DATETIME
																	IF @Release_Month = 1 
																		BEGIN
																			SET @YEAR_ST_DATE = dbo.GET_YEAR_START_DATE(YEAR(@Month_END_Date),12,1)
																		END
																	ELSE IF @Release_Month > 3
																		BEGIN
																			SET @YEAR_ST_DATE = (CASE	When MONTH(@Emp_Left_Date) > 3 Then
																											dbo.GET_YEAR_START_DATE(YEAR(@Emp_Left_Date) + 1, @Release_Month - 1,0)
																										ELSE
																											dbo.GET_YEAR_START_DATE(YEAR(@Emp_Left_Date), @Release_Month - 1,0)
																								 END)
																		END
																						
																	SET @Leave_CF_Days = (@Leave_Days/12) * (DATEDIFF(MONTH,@YEAR_ST_DATE,@Month_END_Date) + 1)
																	SET @Leave_Get_Against_PDays = @Leave_Days
																END
														END
													ELSE
														BEGIN
															SELECT	@Leave_CF_Days = IsNull(CF_M_Days,0) 
															FROM	T0050_LEAVE_CF_MONTHLY_SETTING LCF WITH (NOLOCK)
																	INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																				FROM	T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
																				WHERE	MONTH(For_Date)= MONTH(@Month_END_Date) 
																				GROUP BY Leave_ID,Type_ID
																			 )QRY ON LCF.Effective_Date=QRY.Effective_Date AND LCF.Leave_ID=QRY.Leave_ID AND LCF.Type_ID=QRY.Type_ID
															WHERE	LCF.Cmp_ID=@Cmp_ID AND LCF.Type_ID=@Type_ID AND LCF.Leave_ID=@P_LeavE_ID AND MONTH(LCF.For_Date)= MONTH(@Month_END_Date) 
															
															SET @Leave_Get_Against_PDays = @Leave_CF_Days
														END
												END
											ELSE
												BEGIN 
													IF EXISTS(SELECT Leave_ID FROM T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) WHERE Leave_ID=@Leave_ID AND MONTH(For_Date)=MONTH(@Month_END_Date) AND CF_M_Days <> 0)  
														BEGIN
															--SELECT @Leave_CF_Days = CF_M_Days FROM T0050_LEAVE_CF_MONTHLY_SETTING WHERE Leave_ID=@LEave_ID AND MONTH(For_Date)=MONTH(@Month_END_Date) AND YEAR(For_Date)=YEAR(@Month_END_Date) ORDER BY leave_tran_id 
															-- Comment by nilesh patel ON 02042015 -start due to add provision of Type Monthly Fix
															--SELECT @Leave_CF_Days = IsNull(CF_M_Days,0) FROM T0050_LEAVE_CF_MONTHLY_SETTING WHERE Leave_ID=@Leave_ID AND MONTH(For_Date)=MONTH(@Month_END_Date) AND CF_M_Days <> 0												 
															-- Comment by nilesh patel ON 02042015 -END
																			  
															--Added by nilesh patel ON 02042015 -Start
															SELECT	@Leave_CF_Days = IsNull(CF_M_Days,0) 
															FROM	T0050_LEAVE_CF_MONTHLY_SETTING LCF WITH (NOLOCK)
																	INNER JOIN(	SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																				FROM	T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
																				WHERE	MONTH(For_Date)= MONTH(@Month_END_Date) AND CF_M_Days <> 0 
																				GROUP BY Leave_ID,Type_ID
																			 )QRY ON LCF.Effective_Date=QRY.Effective_Date AND LCF.Leave_ID=QRY.Leave_ID AND LCF.Type_ID=QRY.Type_ID
															WHERE	LCF.Cmp_ID=@Cmp_ID AND LCF.Type_ID=@Type_ID AND LCF.Leave_ID=@P_LeavE_ID AND MONTH(LCF.For_Date)= MONTH(@Month_END_Date) AND LCF.CF_M_Days <> 0
														END
													ELSE
														BEGIN
															SET @Leave_CF_Days = 0
														END
												END
										END	
									ELSE IF @CF_Type_ID = 3		---- Slab
										BEGIN
											SELECT	@Leave_CF_Days = CF_Days 
											FROM	T0050_LEAVE_CF_SLAB cf WITH (NOLOCK)
													INNER JOIN (SELECT	MAX(Effective_Date) Effective_Date,Leave_ID,Type_ID 
																FROM	T0050_LEAVE_CF_SLAB WITH (NOLOCK)
																WHERE	Effective_Date <= @Month_END_Date 
																GROUP BY Leave_ID,Type_ID
																) QRY ON CF.Effective_Date=QRY.Effective_Date AND CF.Leave_ID=QRY.Leave_ID AND CF.Type_ID=QRY.Type_ID
											WHERE	CF.Cmp_ID=@Cmp_ID AND CF.Type_ID=@Type_ID AND CF.Leave_ID=@P_LeavE_ID AND From_Days <= @P_Days AND To_Days >= @P_Days
										END
									ELSE IF @CF_Type_ID = 4		---- Flat
										BEGIN
											SELECT @Flat_Days = Leave_Days FROM T0050_LEAVE_DETAIL WITH (NOLOCK) WHERE Leave_ID=@Leave_ID AND Grd_ID=@Grd_ID AND Cmp_ID=@Cmp_ID
											--	SELECT @join_dt = Date_Of_Join FROM T0080_EMP_MASTER WHERE Emp_ID=@Emp_Id AND Cmp_ID=@Cmp_ID 
																
											IF @Flat_Days IS NULL
												SET @Flat_Days = 0
																
																
											IF @Date_Of_Join > @Month_St_Date AND @is_leave_CF_Prorata = 1
												BEGIN
													SET @total_days = datediff(d,dateadd(dd,-1,@Date_Of_Join),@Month_END_Date)	
																		
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
														
									---- MAX Leave To Carry Forward		
									IF IsNull(@Leave_CF_Days,0) > IsNull(@Leave_MAX_Bal,0) AND IsNull(@Leave_MAX_Bal,0) > 0
										BEGIN
											SET @Leave_CF_Days = IsNull(@Leave_MAX_Bal,0)		
										END							 
														
									---- MAX Accumulate Balance 
									---- IF @MAX_Accumulate_Balance = 100, @Leave_Closing = 97, @Leave_CF_Days = 5 Then @Leave_CF_Days = 3 AND @Exceed_CF_Days = 2 						
									IF IsNull(@Leave_Closing,0) + @Leave_CF_Days > IsNull(@MAX_Accumulate_Balance,0) AND IsNull(@MAX_Accumulate_Balance,0) > 0
										BEGIN
											SET @Leave_CF_Days = IsNull(@MAX_Accumulate_Balance,0) - IsNull(@Leave_Closing,0)
											SET @Exceed_CF_Days = IsNull(@Leave_Closing,0) + @Leave_CF_Days - IsNull(@MAX_Accumulate_Balance,0)
										END
									ELSE
										BEGIN
											SET @Exceed_CF_Days = 0
										END
												
									IF @Leave_CF_Days < 0	--Alpesh 17-Aug-2012
										SET @Leave_CF_Days = 0
														
									IF @Is_FNF = 1
										BEGIN
											SET @Min_Present_Days = 0	--Alpesh 25-Jul-2012 dont chk min. present days IF doing FNF
										END
									
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
															---- Carry Forward Entry		
															IF EXISTS(SELECT Emp_ID FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP')  
																BEGIN  
																	SELECT @Leave_CF_ID =Leave_CF_ID  FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND  Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP' 
																	IF @Is_FNF = 1
																		BEGIN   																									
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = @Month_END_Date,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @P_Days,
																					CF_Leave_Days = @Leave_CF_Days,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days,
																					is_fnf = @Is_FNF
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID   
																		END
																	ELSE
																		BEGIN
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @P_Days,
																					CF_Leave_Days = @Leave_CF_Days,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID  
																		END
																END
															ELSE  
																BEGIN  
																	SELECT	@Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  
																	FROM	T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)
																		           
																	IF @Is_FNF = 1
																		BEGIN
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
																			VALUES 
																				(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF)  
																		END
																	ELSE
																		BEGIN
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
																			VALUES 
																				(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END , @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF)  
																		END
																END 
														END	
													ELSE
														BEGIN
															IF EXISTS(SELECT Emp_ID FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP')  
																BEGIN  
																	SELECT @Leave_CF_ID =Leave_CF_ID  FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND  Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP' 
																				             
																	IF @Is_FNF = 1
																		BEGIN   
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = @Month_END_Date,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @P_Days,
																					CF_Leave_Days = @Leave_CF_Days,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days,
																					is_fnf = @Is_FNF 
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID   
																		END
																	ELSE
																		BEGIN
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @P_Days,
																					CF_Leave_Days = @Leave_CF_Days,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID  
																		END
																END
															ELSE  
																BEGIN  
																	SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)
																		           
																	IF @Is_FNF = 1
																		BEGIN 
																			IF @Duration = 'Yearly' AND @Release_Month <> MONTH(@Month_END_Date) AND @CF_Type_ID = 4
																				BEGIN
																					SET @Leave_CF_Days = 0
																				END
																			ELSE	
																				BEGIN	
																					INSERT INTO T0100_LEAVE_CF_DETAIL  
																						(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
																					VALUES 
																						(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@is_fnf)  
																				END
																		END
																	ELSE
																		BEGIN
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
																			VALUES 
																				(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END , @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF)  
																		END
																END 	
														END 								
												END
											ELSE
												BEGIN
													IF IsNull(@P_Days,0) >= IsNull(@Min_Present_Days,0)
														BEGIN
															---- Carry Forward Entry		
															IF EXISTS(SELECT Emp_ID FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP')  
																BEGIN  
																	SELECT @Leave_CF_ID =Leave_CF_ID  FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND  Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP' 
																				             
																	IF @Is_FNF = 1
																		BEGIN   
																			UPDATE	T0100_LEAVE_CF_DETAIL
																			SET		CF_For_Date = @Month_END_Date,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @P_Days,
																					CF_Leave_Days = @Leave_CF_Days,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days,
																					is_fnf = @Is_FNF
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID   
																		END
																	ELSE
																		BEGIN
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @P_Days,
																					CF_Leave_Days = @Leave_CF_Days,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days  
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID  
																		END
																END
															ELSE  
																BEGIN  
																	SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)
																		
																	IF @Is_FNF = 1
																		BEGIN 
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
																			VALUES (@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF)  
																		END
																	ELSE
																		BEGIN
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
																			VALUES (@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END , @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF)  
																		END
																END 
														END											
												END
										END
									ELSE
										BEGIN
											---- Carry Forward Entry	
											IF EXISTS(SELECT Emp_ID FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@Leave_ID AND Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP' AND CF_For_Date = (Case When @Duration = 'Yearly' and IsNULL(Is_FNF,0) = 1 Then @For_Date  ELSE @Month_END_Date END))  --Added Is_FNF Condition by Jimit 23012018 as case at WCL Leave encash days increment when Process FNF again after deleting
												BEGIN  
													SELECT	@Leave_CF_ID =Leave_CF_ID  
													FROM	T0100_LEAVE_CF_DETAIL WITH (NOLOCK)
													WHERE	Leave_ID =@Leave_ID AND  Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND CF_Type <> 'COMP' 
															AND CF_For_Date = (Case When @Duration = 'Yearly' and IsNULL(Is_FNF,0) = 1 Then @For_Date  ELSE @Month_END_Date END)
																			 
													IF @Is_FNF = 1
													
														BEGIN
														
															UPDATE	T0100_LEAVE_CF_DETAIL 
															SET		CF_For_Date = @Month_END_Date,
																	CF_From_Date = @Month_St_Date,
																	CF_To_Date = @Month_END_Date,
																	CF_P_Days = @P_Days,
																	CF_Leave_Days = @Leave_CF_Days,
																	CF_Type = @Leave_CF_Type,
																	Exceed_CF_Days = @Exceed_CF_Days,
																	is_fnf = @Is_FNF
															WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID  
														END
													ELSE
														BEGIN
															
															UPDATE	T0100_LEAVE_CF_DETAIL 
															SET		CF_For_Date = Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END,
																	CF_From_Date = @Month_St_Date,
																	CF_To_Date = @Month_END_Date,
																	CF_P_Days = @P_Days,
																	CF_Leave_Days = @Leave_CF_Days,
																	CF_Type = @Leave_CF_Type,
																	Exceed_CF_Days = @Exceed_CF_Days
															WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID 
														END 
												END  
											ELSE  
												BEGIN 
													SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)
													IF @Is_FNF = 1
														BEGIN    
															INSERT INTO T0100_LEAVE_CF_DETAIL  
																(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf,Advance_Leave_Balance)  
															VALUES 
																(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, @P_Days, IsNull(@Leave_CF_Days,0), @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF,@Leave_Get_Against_PDays)  
														END
													ELSE
														BEGIN 
															INSERT INTO T0100_LEAVE_CF_DETAIL  
																(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,is_fnf)  
															VALUES 
																(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @Leave_ID,Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END , @Month_St_Date, @Month_END_Date, @P_Days, @Leave_CF_Days, @Leave_CF_Type, @Exceed_CF_Days,@Is_FNF)  
														END
												END  
											---- END ----
										END

									IF @Duration = 'Monthly'	AND @Default_Short_Name <> 'COMP'					
										BEGIN
											IF IsNull(@Reset_Months,0) > 0 -- Added by rohit for ReSET month zero not reSET the balance ON 04012013
												BEGIN
													---- For Reset	
													IF @Reset_Months <= 12
														BEGIN
															IF CHARINDEX('#'+CAST(MONTH(@For_Date) AS varchar)+'#','#'+@Reset_Month_String+'#') > 0
																BEGIN
																	IF EXISTS(SELECT Leave_Tran_Id FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date=@Month_END_Date)
																		BEGIN												
																			SELECT @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date=@Month_END_Date
																			
																			UPDATE	T0140_LEAVE_TRANSACTION 
																			SET		Leave_Closing = 0,
																					Leave_Posting = @Leave_Closing
																			WHERE	Leave_Tran_ID = @Leave_Tran_ID 
																		END
																	ELSE
																		BEGIN												
																			SELECT	@Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 
																			FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
																			
																			INSERT INTO T0140_LEAVE_TRANSACTION
																				(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
																			VALUES
																				(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_END_Date,@Leave_Closing,0,0,0,@Leave_Closing)
																		END
																END
														END
													ELSE
														BEGIN
															--Hardik 18/09/2012 for ReSET Year checking (added new SP)
															SET @bln_Flag = 'NO'
															
															EXEC SP_CHECK_LEAVE_RESET_YEAR @For_Date, @CF_Effective_Date, @Reset_Months,@bln_Flag OUTPUT, @Date OUTPUT
															
															--IF @Reset_Months = MONTH(@For_Date) AND YEAR(DATEADD(m,@Reset_Months,@Month_END_Date)) = YEAR(@For_Date)
															IF @Reset_Month_String = MONTH(@For_Date) AND @bln_Flag = 'YES'
																BEGIN
																	--IF EXISTS(SELECT Leave_Tran_Id FROM T0140_LEAVE_TRANSACTION WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date=DATEADD(m,@Reset_Months,@Month_END_Date))
																	IF EXISTS(SELECT Leave_Tran_Id FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date= @Month_END_Date)
																		BEGIN
																			SELECT @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date = @Month_END_Date
																			
																			UPDATE T0140_LEAVE_TRANSACTION 
																			SET		Leave_Closing = 0,
																					Leave_Posting = @Leave_Closing
																			WHERE	Leave_Tran_ID = @Leave_Tran_ID 
																		END
																	ELSE
																		BEGIN
																			SELECT	@Leave_Tran_ID = IsNull(MAX(Leave_Tran_ID),0) + 1 FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
																			
																			INSERT	INTO T0140_LEAVE_TRANSACTION
																				(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
																			VALUES
																				(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_END_Date,@Leave_Closing,0,0,0,@Leave_Closing)
																		END
																END
														END  
												END
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
													    	IF EXISTS(SELECT Emp_ID FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@tran_Leave_ID AND Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND IsNull(CF_Type,'') = 'COMP')  
																BEGIN  
																	SELECT @Leave_CF_ID =Leave_CF_ID  FROM  T0100_LEAVE_CF_DETAIL WITH (NOLOCK) WHERE Leave_ID =@tran_Leave_ID AND  Emp_ID =@Emp_ID AND MONTH(CF_To_Date) =Month (@Month_END_Date) AND YEAR(CF_To_Date) =YEAR(@Month_END_Date) AND IsNull(CF_Type,'') = 'COMP' 
																	IF @Is_FNF = 1
																		BEGIN    
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = @Month_END_Date,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @CompOff_Closing_Balance,
																					CF_Leave_Days = @CompOff_Closing_Balance,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days,
																					Leave_CompOff_Dates =  @Leave_CompOff_Dates,
																					is_fnf=@Is_FNF
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID  
																		END
																	ELSE
																		BEGIN
																			UPDATE	T0100_LEAVE_CF_DETAIL 
																			SET		CF_For_Date = Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END,
																					CF_From_Date = @Month_St_Date,
																					CF_To_Date = @Month_END_Date,
																					CF_P_Days = @CompOff_Closing_Balance,
																					CF_Leave_Days = @CompOff_Closing_Balance,
																					CF_Type = @Leave_CF_Type,
																					Exceed_CF_Days = @Exceed_CF_Days,
																					Leave_CompOff_Dates =  @Leave_CompOff_Dates 
																			WHERE	LEAVE_CF_ID = @Leave_CF_ID AND Emp_ID =@Emp_ID  
																		END 
																END  
															ELSE  
																BEGIN  
																	SELECT @Leave_CF_ID = IsNull(MAX(Leave_CF_ID),0) + 1  FROM T0100_LEAVE_CF_DETAIL  WITH (NOLOCK)

																	IF @Is_FNF = 1
																		BEGIN    
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,Leave_CompOff_Dates,is_fnf)  
																			VALUES 
																				(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @tran_Leave_ID, @Month_END_Date, @Month_St_Date, @Month_END_Date, @CompOff_Closing_Balance, @CompOff_Closing_Balance, @Leave_CF_Type, @Exceed_CF_Days,@Leave_CompOff_Dates,@Is_FNF)  
																		END
																	ELSE
																		BEGIN 
																			INSERT INTO T0100_LEAVE_CF_DETAIL  
																				(Leave_CF_ID, Cmp_ID, Emp_ID, Leave_ID, CF_For_Date, CF_From_Date, CF_To_Date, CF_P_Days, CF_Leave_Days, CF_Type, Exceed_CF_Days,Leave_CompOff_Dates,is_fnf)  
																			VALUES 
																				(@Leave_CF_ID, @Cmp_ID, @Emp_ID, @tran_Leave_ID,Case When @Duration = 'Yearly' Then @For_Date  ELSE @Month_END_Date END , @Month_St_Date, @Month_END_Date, @CompOff_Closing_Balance, @CompOff_Closing_Balance, @Leave_CF_Type, @Exceed_CF_Days,@Leave_CompOff_Dates,@Is_FNF)  
																		END
																END  
														END
																			
												END
										END	
								END
						END
					
					FETCH NEXT FROM curLeave INTO @Leave_ID,@Leave_MAX_Bal,@Leave_CF_Type,@Leave_Pdays,@Leave_Get_Against_PDays,@Leave_Precision,@Leave_CF_Days,@MAX_Accumulate_Balance,@Min_Present_Days,@is_leave_CF_Rounding,@is_leave_CF_Prorata,@CF_Effective_Date,@CF_Type_ID,@Reset_Months,@Duration,@CF_Months,@Release_Month,@Reset_Month_String,@MinPDays_Type,@Default_Short_Name,@Tran_Leave_ID,@Apply_Hourly
				END  
			  
			CLOSE curLeave  
			DEALLOCATE curLeave  				
			  
			FETCH NEXT FROM curEmp INTO @Emp_ID,@Grd_ID,@Branch_ID,@Type_ID,@Emp_Left_Date,@Date_Of_Join       
	    END 
   CLOSE curEmp  
   DEALLOCATE curEmp  
   

   IF EXISTS(SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID = @P_LeavE_ID AND IsNull(Default_Short_Name,'') = 'COMP')
		BEGIN
			SELECT @P_LeavE_ID = Trans_Leave_ID FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Leave_ID = @P_LeavE_ID AND IsNull(Default_Short_Name,'') = 'COMP' 			
		END
   
	IF @Is_FNF = 1
		BEGIN
			SELECT	Leave_CF_ID,CF_LEAVE_Days,CF_P_DAYS,cf_type,Leave_ID,Emp_ID,Advance_Leave_Balance 
			FROM	T0100_LEAVE_CF_DETAIL WITH (NOLOCK)
			WHERE	CF_From_Date = @Month_St_Date AND CF_To_Date = @Month_END_Date AND Cmp_ID =@Cmp_ID 
					AND LeavE_ID = IsNull(@P_LeavE_ID,LeavE_ID) AND Emp_ID = @Emp_Id 
					AND LEAVE_CF_ID NOT IN (SELECT tran_id FROM #Old_CF) 
		END
   ELSE
		BEGIN
	 		SELECT	Leave_CF_ID,CF_LEAVE_Days,CF_P_DAYS,cf_type,Leave_ID,Emp_ID,Advance_Leave_Balance 
			FROM	T0100_LEAVE_CF_DETAIL WITH (NOLOCK)   
			WHERE	CF_From_Date =@Month_St_Date AND cf_to_date = @Month_END_Date AND Cmp_ID =@Cmp_ID 
					AND LeavE_ID = IsNull(@P_LeavE_ID,LeavE_ID) 
			ORDER BY emp_ID ASC  
		END
   

