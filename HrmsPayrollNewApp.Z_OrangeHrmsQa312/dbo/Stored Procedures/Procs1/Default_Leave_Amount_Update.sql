

-- Created By rohit for update default setting to all company on 31012013
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Default_Leave_Amount_Update]        
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
SET ANSI_WARNINGS OFF; 
begin
	declare @Lv_Encash_Apr_ID as numeric(18,0)
	declare @Cmp_ID as numeric(18,0)
	declare @Emp_id as numeric(18,0)
	declare @Leave_ID as numeric
	declare @Lv_Encash_Apr_Date datetime
	declare @Lv_Encash_Apr_Days as numeric(18,2)
	declare @Upto_Date as datetime

	declare @Increment_Id_New as numeric(18,0)
	declare @upto_Gross_Salary as numeric(18,2)
	declare @upto_Basic_Salary as numeric(18,2)
	declare @Branch_ID as numeric(18,0)
	declare @Type_Id as numeric(18,0)
	declare @Wages_Type as varchar(500)
	declare @SalaryBasis as varchar(500)
	declare @Allow_Effect_on_Leave as numeric(18,2)
	Declare @Sal_St_Date as datetime
	Declare @Sal_End_Date as datetime
	declare @OutOf_Days as numeric(18,2)
	declare @Is_Cancel_Holiday as tinyint
	Declare @Is_Cancel_Weekoff as tinyint
	Declare @Lv_Encash_W_Day as numeric(18,2)
	Declare @chk_lv_on_working as tinyint
	Declare @Lv_Encash_Cal_On as varchar(500)
	Declare @IS_ROUNDING as tinyint
	Declare @Holiday_days as numeric(18,2)
	Declare @WeekOff_Days as numeric(18,2)
	Declare @Inc_Weekoff as numeric(18,2)
	Declare @Inc_holiday as numeric(18,2)
	Declare @Working_Days as numeric(18,2)
	Declare @Day_Salary as numeric(18,2)
	declare @Gross_Salary_ProRata as numeric(18,2)
	Declare @Salary_Amount as numeric(18,2)
	Declare @Encashment_Rate as numeric(18,2)
	DECLARE @Temp_Date as Datetime
	declare @Temp_Lv_Encash_W_Day as numeric(18,2)
	declare @Leave_EncashDay_Half_Payment as numeric(18,2)
	
		Create table #Tbl_Get_AD
			(
				Emp_ID numeric(18,0),
				Ad_ID numeric(18,0),
				for_date datetime,
				E_Ad_Percentage numeric(18,5),
				M_Ad_Amount numeric(18,2)
				
			)

		DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
 
 
	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
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
			DECLARE @CONSTRAINT VARCHAR(MAX)

			SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
			FROM	(SELECT	DISTINCT Emp_id	
					 FROM	T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK)
					 WHERE	IsNull(Leave_Encash_Amount,0) = 0 and Lv_Encash_Apr_Status = 'A' ) T

			DECLARE @FROM_DATE DATETIME
			SET	@FROM_DATE = Isnull(@upto_date,@Lv_Encash_Apr_Date)
			SET	@FROM_DATE = DATEADD(D, ((DAY(@FROM_DATE) + 10) * -1), @FROM_DATE)

			DECLARE @TO_DATE DATETIME
			SET	@TO_DATE = DATEADD(D, 45, @FROM_DATE)

			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @Is_FNF = 1, @All_Weekoff = 0, @Exec_Mode=0

		END 
	


	Declare CursLeaveEncase cursor for	                  
	select Lv_Encash_Apr_ID,Cmp_ID,Emp_id,Leave_ID,Lv_Encash_Apr_Date,Lv_Encash_Apr_Days,Upto_Date 
	from T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) where isnull(Leave_Encash_Amount,0) = 0 and Lv_Encash_Apr_Status = 'A' 
	Open CursLeaveEncase
	Fetch next from CursLeaveEncase into @Lv_Encash_Apr_ID,@Cmp_ID,@Emp_id,@Leave_ID,@Lv_Encash_Apr_Date,@Lv_Encash_Apr_Days,@Upto_Date 
	While @@fetch_status = 0                    
		Begin     
	
		set @Salary_Amount = 0	
		set @Increment_Id_New = 0
		set @upto_Gross_Salary =0
		set @upto_Basic_Salary =0
		set @Branch_ID = 0
		set @Type_Id = 0
		set @Wages_Type =''
		set @SalaryBasis =''
		set @Allow_Effect_on_Leave = 0
		
		set @OutOf_Days =0
		set @Is_Cancel_Holiday = 0
		set @Is_Cancel_Weekoff = 0
		set @Lv_Encash_W_Day = 0
		set @chk_lv_on_working = 0
		set @Lv_Encash_Cal_On = ''
		set @IS_ROUNDING = 0
		set @Holiday_days = 0
		set @WeekOff_Days = 0
		set @Inc_Weekoff = 0
		set @Inc_holiday = 0
		set @Working_Days = 0
		set @Day_Salary =0
		set @Gross_Salary_ProRata = 0
		set @Salary_Amount =0
		set @Encashment_Rate = 0
		set @Temp_Lv_Encash_W_Day = 0
		set @Leave_EncashDay_Half_Payment = 0
		
		
		
	set @Temp_Date = Isnull(@upto_date,@Lv_Encash_Apr_Date)
	
	SELECT @Temp_Lv_Encash_W_Day = Lv_Encase_Calculation_Day,@Leave_EncashDay_Half_Payment = Leave_EncashDay_Half_Payment
	FROM T0040_leave_Master WITH (NOLOCK)
	WHERE Leave_ID = @Leave_ID 
	
	select @upto_Basic_Salary = Basic_Salary,@upto_Gross_Salary = Gross_Salary,@Increment_Id_New = I.Increment_ID,@Type_Id=I.Type_ID,@Branch_ID=I.Branch_ID,
	@Wages_Type=Wages_Type,@SalaryBasis=Salary_Basis_On 
		from dbo.T0095_Increment I WITH (NOLOCK) inner join 
		(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
			(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
			Where Increment_effective_Date <= @Temp_Date Group by emp_ID) new_inc
			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
			Where TI.Increment_effective_Date <= @Temp_Date group by ti.emp_id) Qry on I.Increment_Id = Qry.Increment_Id
		Where I.Emp_ID = @Emp_ID
		

			TRUNCATE TABLE #Tbl_Get_AD

			INSERT INTO #Tbl_Get_AD
				Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@Temp_Date,@Emp_Id

			Select @Allow_Effect_on_Leave = SUM(M_Ad_Amount) from #Tbl_Get_AD EED 
				Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID 
			Where EED.EMP_ID = @Emp_Id And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1
		
	
	
				select 
					@Is_Cancel_Holiday = Is_Cancel_Holiday
					,@Is_Cancel_Weekoff = Is_Cancel_Weekoff
					,@Lv_Encash_W_Day = isnull(Lv_Encash_W_Day,0),@IS_ROUNDING = ISNULL(AD_Rounding,0)
					,@chk_lv_on_working = ISNULL(chk_lv_on_working,0) 
					,@Lv_Encash_Cal_On=ISNULL(Lv_Encash_Cal_On,'') 
					,@Inc_Weekoff=Inc_Weekoff 
					
					from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
					and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Temp_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

					if isnull(@Sal_St_Date,'') = ''    
						begin    
						
							set @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Temp_Date),year(@Temp_Date))    
							set @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Temp_Date),year(@Temp_Date))
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
							
						end     
					else if day(@Sal_St_Date) = 1 --and month(@Sal_St_Date)= 1    
						begin    
						
							set @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Temp_Date),year(@Temp_Date))    
							set @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Temp_Date),year(@Temp_Date))
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1  
							
						end     
					else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						begin    
						
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Temp_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Temp_Date) )as varchar(10)) as smalldatetime)    
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			                set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						end	
					else
						begin
						
							set @Sal_St_Date = dateadd(mm,1,@Sal_St_Date)
							set @Sal_End_Date = dateadd(mm,1,@Sal_End_Date)

							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						end
			
		 
		set @upto_Basic_Salary = isnull(@upto_Basic_Salary ,0) + isnull(@Allow_Effect_on_Leave,0)

		SELECT	@Holiday_days = COUNT(1)
		FROM	#EMP_HOLIDAY
		WHERE	FOR_DATE BETWEEN @Sal_St_Date AND @Sal_End_Date AND EMP_ID=@Emp_id AND IS_CANCEL=0

		SELECT	@Weekoff_Days = COUNT(1)
		FROM	#EMP_WEEKOFF
		WHERE	FOR_DATE BETWEEN @Sal_St_Date AND @Sal_End_Date AND EMP_ID=@Emp_id AND IS_CANCEL=0

		--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,@Sal_End_Date,null,null,@Is_Cancel_Holiday,null ,@Holiday_days output,null,0,@Branch_ID
		--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,@Sal_End_Date,null,null,@Is_Cancel_weekoff,null,null ,@Weekoff_Days output ,null ,0,1

		if @Temp_Lv_Encash_W_Day > 0
		begin 
			set @Lv_Encash_W_Day = @Temp_Lv_Encash_W_Day 
		end
		
		---Added By Jimit 08022018
				DECLARE @LV_ENCASH_W_DAY_Master as NUMERIC
				SELECT @LV_ENCASH_W_DAY_Master = LEAVE_ENCASH_WORKING_DAYS 
				FROM T0080_EMP_MASTER WITH (NOLOCK)
				WHERE EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID				
				
				IF @LV_ENCASH_W_DAY_Master > 0
					SET @Lv_Encash_W_Day = @LV_ENCASH_W_DAY_Master					
		---Ended
		
		
		if @Inc_Weekoff <> 1
			Set @Working_Days = @Outof_Days - @WeekOff_Days 
		else
			Set @Working_Days = @Outof_Days 
	
			If @Wages_Type = 'Monthly' 
				if @Lv_Encash_W_Day > 0 
					begin
						
						set @Day_Salary = 	@upto_Basic_Salary / @Lv_Encash_W_Day
						set @Gross_Salary_ProRata = @upto_Gross_Salary/@Lv_Encash_W_Day
						
					end
				else if @chk_lv_on_working = 1
					begin		
													
						set @Day_Salary = 	@upto_Basic_Salary / (@Outof_Days - @Weekoff_Days -@Holiday_Days)
						set @Gross_Salary_ProRata = @upto_Gross_Salary/(@Outof_Days - @Weekoff_Days - @Holiday_Days) -- rohit on 25112014
					end 
				else if @Inc_Weekoff = 1
					begin
					
						set @Day_Salary = 	@upto_Basic_Salary / @Outof_Days 
						set @Gross_Salary_ProRata = @upto_Gross_Salary/@Outof_Days
					end 
				else
					begin
					
						set @Day_Salary = 	@upto_Basic_Salary / @Working_Days
						set @Gross_Salary_ProRata = @upto_Gross_Salary/@Working_Days
					
					end 
			Else
				Begin
				
					set @Day_Salary = 	@upto_Basic_Salary
				End
	
			select @Encashment_Rate = isnull(Encashment_Rate,1)  from T0040_TYPE_MASTER WITH (NOLOCK) where TYPE_ID=@Type_Id  
			Set @Salary_Amount  = isnull(@Salary_Amount,0) + isnull(Round(@Day_Salary * @Encashment_Rate * @Lv_Encash_Apr_Days,0),0)
		
			IF @Leave_EncashDay_Half_Payment = 1
				SET @Salary_Amount = @Salary_Amount / 2
			
		
			update T0120_LEAVE_ENCASH_APPROVAL 
			set Leave_Encash_Amount = @Salary_Amount
			where Lv_Encash_Apr_ID = @Lv_Encash_Apr_ID and Emp_ID= @Emp_id
			

		--select  @strsetting
			fetch next from CursLeaveEncase into @Lv_Encash_Apr_ID,@Cmp_ID,@Emp_id,@Leave_ID,@Lv_Encash_Apr_Date,@Lv_Encash_Apr_Days,@Upto_Date 	
		end
		close CursLeaveEncase                    
		deallocate CursLeaveEncase
	return
	end

