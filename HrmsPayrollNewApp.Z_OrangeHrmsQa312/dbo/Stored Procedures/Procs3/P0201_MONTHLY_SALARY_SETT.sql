
---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0201_MONTHLY_SALARY_SETT]
	@S_Sal_Tran_ID		Numeric output
	,@Emp_Id			Numeric
	,@Cmp_ID			Numeric
	,@S_Sal_Generate_Date datetime
	,@S_Month_St_Date		Datetime
	,@s_Month_End_Date	Datetime
	,@M_Present_Days	Numeric(18,1)
	,@M_OT_Hours		Numeric(18,2)
	,@Areas_Amount		Numeric(18,2) 
	,@M_IT_Tax			NUMERIC
	,@Other_Dedu		numeric(18,2)
	,@M_LOAN_AMOUNT		NUMERIC
	,@M_ADV_AMOUNT		NUMERIC
	,@IS_LOAN_DEDU		NUMERIC --(0,1)
	,@Login_ID			Numeric 
	,@ErrRaise			Varchar(100) output
	,@Is_Negetive		Varchar(1)
	,@S_Sal_Type		VARCHAR(20)
	,@S_EFF_DATE		DATETIME
	,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 17102013
	,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 17102013
	,@Effect_On_Salary Numeric(5,0) = 1 --Added by nilesh patel on 29032017
AS
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


	-- Added for audit trail by Ali 17102013 -- start
	Declare @Old_Emp_Id as numeric
	Declare @OldValue as varchar(max)
	Declare @Old_Emp_Name as varchar(200)
	Declare @Old_sal_Tran_ID as numeric
	Declare @Old_Increment_ID as numeric 
	Declare @Old_S_Month_St_Date as datetime
	Declare @Old_s_Month_End_Date as datetime
	Declare @Old_S_Sal_Generate_Date as datetime
	Declare @Old_Sal_cal_Days as numeric 
	Declare @Old_Working_Days as numeric
	Declare @Old_Outof_Days as numeric
	Declare @Old_Shift_Day_Sec as numeric
	Declare @Old_Shift_Day_Hour as varchar(20)
	Declare @Old_S_Basic_Salary as numeric
	Declare @Old_Day_Salary as numeric
	Declare @Old_Hour_Salary as numeric
	Declare @Old_S_Salary_Amount as numeric
	Declare @Old_Allow_Amount as numeric
	Declare @Old_OT_Amount as numeric
	Declare @Old_Other_Allow_Amount as numeric
	Declare @Old_S_Gross_Salary as numeric
	Declare @Old_Dedu_Amount as numeric
	Declare @Old_Loan_Amount as numeric
	Declare @Old_Loan_Intrest_Amount as numeric
	Declare @Old_Advance_Amount as numeric
	Declare @Old_Other_Dedu_Amount as numeric 
	Declare @Old_Total_Dedu_Amount as numeric
	Declare @Old_Due_Loan_Amount as numeric
	Declare @Old_Net_Amount as numeric 
	Declare @Old_S_PT_Amount as numeric
	Declare @Old_PT_Calculated_Amount as numeric
	Declare @Old_Total_Claim_Amount as numeric
	Declare @Old_M_OT_Hours as numeric
	Declare @Old_M_IT_Tax as numeric
	Declare @Old_M_Loan_Amount as numeric
	Declare @Old_M_Adv_Amount as numeric 
	Declare @Old_LWF_Amount as numeric
	Declare @Old_Revenue_Amount as numeric
	Declare @Old_PT_F_T_LIMIT as varchar(20)
	Declare @Old_S_Gross_Salary_ProRata as numeric
	Declare @Old_S_Sal_Type as varchar(20)
	Declare @Old_S_EFF_DATE as date
								
	-- Added by Hardik 14/11/2018 for Shoft Shift Yard Client
	DECLARE @Shift_Wise_OT_Rate TINYINT
	DECLARE @Shift_Wise_OT_Calculated tinyint
	SET @Shift_Wise_OT_Rate = 0

	SELECT @Shift_Wise_OT_Rate = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where CMP_ID = @Cmp_Id and Setting_Name = 'Enable Shift Wise Over Time Rate'

								
	Set @Old_Emp_Id = 0
	Set @OldValue = ''
	Set @Old_Emp_Name =''
	Set @Old_sal_Tran_ID = 0
	Set @Old_Increment_ID = 0 
	Set @Old_S_Month_St_Date = NULL
	Set @Old_s_Month_End_Date = NULL
	Set @Old_S_Sal_Generate_Date = NULL
	Set @Old_Sal_cal_Days = 0 
	Set @Old_Working_Days = 0
	Set @Old_Outof_Days = 0
	Set @Old_Shift_Day_Sec = 0
	Set @Old_Shift_Day_Hour = ''
	Set @Old_S_Basic_Salary = 0
	Set @Old_Day_Salary = 0
	Set @Old_Hour_Salary = 0
	Set @Old_S_Salary_Amount = 0
	Set @Old_Allow_Amount = 0
	Set @Old_OT_Amount = 0
	Set @Old_Other_Allow_Amount = 0
	Set @Old_S_Gross_Salary = 0
	Set @Old_Dedu_Amount = 0
	Set @Old_Loan_Amount = 0
	Set @Old_Loan_Intrest_Amount = 0
	Set @Old_Advance_Amount = 0
	Set @Old_Other_Dedu_Amount = 0 
	Set @Old_Total_Dedu_Amount = 0
	Set @Old_Due_Loan_Amount = 0
	Set @Old_Net_Amount = 0 
	Set @Old_S_PT_Amount = 0
	Set @Old_PT_Calculated_Amount = 0
	Set @Old_Total_Claim_Amount = 0
	Set @Old_M_OT_Hours = 0
	Set @Old_M_IT_Tax = 0
	Set @Old_M_Loan_Amount = 0
	Set @Old_M_Adv_Amount = 0 
	Set @Old_LWF_Amount = 0
	Set @Old_Revenue_Amount = 0
	Set @Old_PT_F_T_LIMIT = ''
	Set @Old_S_Gross_Salary_ProRata = 0
	Set @Old_S_Sal_Type = ''
	Set @Old_S_EFF_DATE = NULL
	-- Added for audit trail by Ali 17102013 -- start

								
	
	
	-- commneted by rohit for data taken from salary table on 06062016
	CREATE table #Data     
	(     
	  Emp_Id     numeric ,     
	  For_date   datetime,    
	  Duration_in_sec  numeric,    
	  Shift_ID   numeric ,    
	  Shift_Type   numeric ,    
	  Emp_OT    numeric ,    
	  Emp_OT_min_Limit numeric,    
	  Emp_OT_max_Limit numeric,    
	  P_days    numeric(12,1) default 0,    
	  OT_Sec    numeric default 0,
	  In_Time datetime default null,
	  Shift_Start_Time datetime default null,
	  OT_Start_Time numeric default 0,
	  Shift_Change tinyint default 0 ,
	  Flag Int Default 0  ,
	  Weekoff_OT_Sec  numeric default 0,
	  Holiday_OT_Sec  numeric default 0	,
	  Chk_By_Superior numeric default 0,
	  IO_Tran_Id	   numeric default 0,
	  OUT_Time Datetime ,
	  Shift_End_Time datetime,			--Ankit 16112013
	  OT_End_Time numeric default 0,		--Ankit 16112013
	  Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
	  Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	  GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    
   
   	CREATE table #dayDiff
	(
		id numeric,
		data numeric									
	)
	
	
	-- Variable Declaration 	
	
	declare @S_Sal_Receipt_No			Numeric
	Declare @Increment_ID			Numeric
	DEclare @Sal_Tran_ID			numeric 
	Declare @Branch_ID				numeric 
	declare @Emp_OT					numeric 
	Declare @Emp_OT_Min_Limit		varchar(10)
	Declare @Emp_OT_Max_Limit		varchar(10)
	Declare	@Emp_OT_Min_Sec			numeric
	Declare @Emp_OT_Max_Sec			numeric
	Declare @Emp_OT_Sec				numeric
	Declare @Emp_OT_Hours			varchar(10)
	declare @Wages_Type				varchar(10)
	declare @SalaryBasis			varchar(20)
	declare @Payment_Mode			varchar(20)
	declare @Fix_Salary				varchar(1)
	declare @numAbsentDays			Numeric(12,2)				   
	Declare @numWorkingDays_Daily	Numeric(12,2)
	declare @numAbsentDays_Daily	Numeric(12,2)
	Declare @Present_Days			Numeric(12,2)
	Declare @Sal_cal_Days			Numeric(12,2)
	Declare @Absent_Days			Numeric(12,2)
	Declare @Holiday_Days			Numeric(12,2)
	Declare @Weekoff_Days			Numeric(12,2)
	Declare @Cancel_Holiday			Numeric(12,2)
	Declare @Cancel_Weekoff			Numeric(12,2)
	Declare @Working_days			Numeric(12,2)
	declare @OutOf_Days				Numeric        
	Declare @Total_leave_Days		Numeric(12,2)
	Declare @Paid_leave_Days		Numeric(12,2)
	
	Declare @Actual_Working_Hours	varchar(20)
	Declare @Working_Hours			varchar(20)
	Declare @Outof_Hours			varchar(20)
	Declare @Total_Hours			varchar(20)
	Declare @Shift_Day_Sec			Numeric
	Declare @Shift_Day_Hour			varchar(20)
	Declare @Basic_Salary			Numeric(25,2)
	Declare @Gross_Salary			Numeric(25,2)
	Declare @Actual_Gross_Salary	Numeric(25,2)
	Declare @Gross_Salary_ProRata	numeric(25,5)
	Declare @Day_Salary				Numeric(12,5)
	Declare @Hour_Salary			Numeric(12,5)
	Declare @Salary_amount			Numeric(12,5)
	Declare @Allow_Amount			Numeric(18,2)
	Declare @REim_Amount			Numeric(18,2)
	Declare @OT_Amount				Numeric(18,2)
	Declare @Other_allow_Amount		Numeric(18,2)
	Declare @Dedu_Amount			Numeric(18,2)
	Declare @Loan_Amount			Numeric(18,2)
	Declare @Loan_Intrest_Amount	Numeric(18,2)
	Declare @Advance_Amount			Numeric(18,2)
	Declare @Other_Dedu_Amount		Numeric(18,2)
	Declare @Total_Dedu_Amount		Numeric(18,2)
	Declare @Due_Loan_Amount		Numeric(18,2)
	Declare @Net_Amount				Numeric(18,2)
	Declare @Final_Amount			Numeric(18,2)
	Declare @Hour_Salary_OT			Numeric(18,2)
	Declare @ExOTSetting			Numeric(5,2)
	Declare @Inc_Weekoff			tinyint
	Declare @Late_Adj_Day			Numeric(5,2)
	Declare @OT_Min_Limit			varchar(20)
	Declare @OT_Max_Limit			varchar(20)
	Declare @OT_Min_Sec				Numeric
	Declare @OT_Max_Sec				Numeric
	Declare @Is_OT_Inc_Salary		tinyint
	Declare @Is_Daily_OT			tinyint
	Declare @Fix_Shift_Hours		varchar(20)
	Declare @Fix_OT_Work_Days		Numeric(18,2)
	Declare @Round					Numeric
	declare @Restrict_Present_Days	char(1)
	Declare @Is_Cancel_Holiday		numeric(1,0)
	Declare @Is_Cancel_Weekoff		numeric(1,0)
	Declare @Join_Date				Datetime
	Declare @Left_Date				Datetime	
	Declare @StrHoliday_Date		varchar(3000)
	Declare @StrWeekoff_Date		varchar(3000)
	Declare @Update_Adv_Amount		numeric 
	Declare @Total_Claim_Amount		numeric 
	Declare @Is_PT					numeric
	Declare @Is_Emp_PT				numeric
	Declare @PT_Amount				numeric
	Declare @PT_Calculated_Amount	numeric 
	Declare @LWF_Amount				numeric 
	Declare @LWF_App_Month			varchar(50)
	Declare @Revenue_Amount			numeric 
	Declare @Revenue_On_Amount		numeric 
	Declare @LWF_compare_month		varchar(5)
	declare @PT_F_T_Limit			varchar(20)
	Declare @Basic_Salary_Sett		Numeric(25,5)
	Declare @Salary_amount_Sett			Numeric(12,2)
	Declare @Gross_Salary_ProRata_Sett	numeric(25,5)
	Declare @Old_Basic_Salary			Numeric(25,2)
	Declare @Old_Salary_amount			Numeric(12,2)
	Declare @Old_Gross_Salary_ProRata	numeric(25,5)
	Declare @Old_Gross_Salary			Numeric(25,2)
	Declare @Old_PT_Amount					numeric
	Declare @LWF_Amount_Old	numeric
	Declare @Is_Rounding	Tinyint
	declare @increment_date datetime
	declare @Actual_Working_Sec   NUMERIC    
	declare @Inc_Holiday numeric
	
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime    
	Declare @Is_Negative_Ot Int 	
	Declare @Is_OT_Auto_Calc tinyint
	declare @Emp_WO_OT_Sec		Numeric --Mitesh 30/11/2011
	declare @Emp_HO_OT_Sec		Numeric 
	declare @is_monthly_Salary tinyint 
	
	DECLARE @Emp_OT_Hours_Num		NUMERIC(18,2)	--OverTime Variable
	DECLARE @Emp_WO_OT_Hours_Num	NUMERIC(22,3)	
	DECLARE @Emp_HO_OT_Hours_Num	NUMERIC(22,3)
	DECLARE @Emp_WO_OT_Rate			NUMERIC(5,1)
	DECLARE @Emp_HO_OT_Rate			NUMERIC(5,1)
	DECLARE @WO_OT_Amount			NUMERIC(22,3)
	DECLARE @HO_OT_Amount			NUMERIC(22,3)
	DECLARE @Fix_OT_Hour_Rate_WD	NUMERIC(18,3)
	DECLARE @Emp_WD_OT_Rate			NUMERIC(5,1)
	DECLARE @Fix_OT_Hour_Rate_WOHO	NUMERIC(18,3)
	DECLARE @Sett_Increment_ID	NUMERIC
	
	SET @Sett_Increment_ID = 0
	set @is_monthly_Salary = 0 
	set @Actual_Working_Sec = 0
	set @Is_Negative_Ot = 0
	set @Inc_Holiday = 0
	set @OutOf_Days = datediff(d,@S_Month_St_Date,@s_Month_End_Date) + 1
	Set @Emp_OT			= 0
	Set @Wages_Type		= ''
	Set @SalaryBasis	= ''
	Set @Payment_Mode	= ''
	Set @Fix_Salary		= ''
	Set @numAbsentDays	=0
	Set @numWorkingDays_Daily = 0
	Set @numAbsentDays_Daily  = 0
	Set @Sal_cal_Days	 = 0
	Set @Absent_Days	 = 0
	Set @Holiday_Days	 = 0
	Set @Weekoff_Days	 = 0
	Set @Cancel_Holiday	 = 0
	Set @Cancel_Weekoff	 = 0
	Set @Working_days	 = 0
	Set @Total_leave_Days  = 0
	Set @Paid_leave_Days  = 0
	set @Update_Adv_Amount	= 0
	set @Total_Claim_Amount	 = 0
	
	Set @Actual_Working_Hours  =''
	Set @Working_Hours  = ''
	Set @Outof_Hours  = ''
	Set @Total_Hours  = ''
	Set @Shift_Day_Sec	= 0 
	Set @Shift_Day_Hour		 = ''
	Set @Basic_Salary		 = 0 
	Set @Day_Salary			 = 0
	Set @Hour_Salary		 = 0
	Set @Salary_amount		 = 0
	Set @Allow_Amount		 = 0
	Set @REim_Amount		= 0
	Set @OT_Amount			 = 0
	Set @Other_allow_Amount	 = @Areas_Amount
	Set @Gross_Salary		 = 0
	Set @Dedu_Amount		 = 0
	Set @Loan_Amount		 = 0
	Set @Loan_Intrest_Amount = 0
	Set @Advance_Amount		 = 0
	Set @Other_Dedu_Amount	= @Other_Dedu
	Set @Total_Dedu_Amount	= 0
	Set @Due_Loan_Amount	= 0
	Set @Net_Amount			= 0
	Set @Final_Amount		= 0
	set @Hour_Salary_OT		= 0	
	set @Inc_Weekoff = 0
	set @Late_Adj_Day = 0
	set @ExOTSetting			= 0
	set @OT_Min_Limit			=''
	set @OT_Max_Limit			= ''
	set @Is_OT_Inc_Salary		= 0
	set @Is_Daily_OT			= 0
	set @Fix_Shift_Hours		= ''
	set @Fix_OT_Work_Days	= 0
	set @OT_Min_Sec	 = 0
	set @OT_Max_Sec	 = 0
	set @Round = 0
	set @Restrict_Present_Days = 'Y'
	set @Is_Cancel_Weekoff = 0
	set @Is_Cancel_Holiday = 0
	Set @StrHoliday_Date = ''
	set @StrWeekoff_Date = ''
	set @Emp_OT_Min_Limit = ''
	set @Emp_OT_Max_Limit = ''
	set @Emp_OT_Min_Sec	= 0
	set @Emp_OT_Max_Sec = 0
	set @Emp_OT_Sec = @M_OT_Hours * 3600
	set @Is_PT = 0
	set @Is_Emp_PT = 0
	set @PT_Amount = 0
	set @PT_Calculated_Amount = 0
	set @LWF_Amount				=0
	set @LWF_App_Month		=	''
	set @Revenue_Amount			=0
	set @Revenue_On_Amount		= 0
	set @LWF_compare_month		=''
	set @PT_F_T_Limit = ''
	Set @Basic_Salary_Sett			=0
	Set @Salary_amount_Sett			=0
	Set @Gross_Salary_ProRata_Sett	=0
	set @Old_Basic_Salary = 0
	set @Old_Salary_amount			=0 
	set @Old_Gross_Salary_ProRata	=0
	set @Present_Days =0
	set @Old_Gross_Salary =0
	set @Old_PT_Amount =0
	set @LWF_Amount_Old=0 
	Declare @Wages_Amount as numeric(18,2)
	Set @Wages_Amount =0
	set @Is_Rounding = 0
	
	SET @Emp_OT_Hours_Num	= 0	--OverTime Variable
	SET @Emp_WO_OT_Hours_Num = 0	
	SET @Emp_HO_OT_Hours_Num = 0	
	SET @Emp_WO_OT_Rate	= 0	
	SET @Emp_HO_OT_Rate	= 0	
	SET @WO_OT_Amount	= 0	
	SET @HO_OT_Amount	= 0	
	SET @Fix_OT_Hour_Rate_WD = 0
	SET @Emp_WD_OT_Rate  = 0
	SET @Fix_OT_Hour_Rate_WOHO = 0
		
		
		select @Branch_ID = Branch_ID			
		From T0095_Increment I WITH (NOLOCK) inner join 
				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
				where Increment_Effective_date <= @s_Month_End_Date
				and Cmp_ID = @Cmp_ID
				group by emp_ID  ) Qry on
				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
		Where I.Emp_ID = @Emp_ID


	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@s_Month_End_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@s_Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End 
	
	if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @S_Month_St_Date  = @S_Month_St_Date     
			   set @s_Month_End_Date = @s_Month_End_Date    
			   set @OutOf_Days = @OutOf_Days
		  end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
		  begin    
			   set @S_Month_St_Date  = @S_Month_St_Date     
			   set @s_Month_End_Date = @s_Month_End_Date    
			   set @OutOf_Days = @OutOf_Days    	         
		  end     
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		  begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@S_Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@S_Month_St_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			   set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			   
			   Set @S_Month_St_Date = @Sal_St_Date
			   Set @s_Month_End_Date = @Sal_End_Date    
		  end
	
      
	 
		select @Increment_ID = I.Increment_ID ,@Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On
			,@Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode ,
			 @Actual_Gross_Salary = Gross_Salary ,@Basic_Salary =Basic_Salary,
			 @Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit,
			 @Branch_ID = Branch_ID,
			 @Is_Emp_PT =isnull(Emp_PT,0) , @increment_date = Increment_Effective_Date,
			 @Emp_WD_OT_Rate = isnull(Emp_WeekDay_OT_Rate,0), 
			 @Fix_OT_Hour_Rate_WD=Fix_OT_Hour_Rate_WD,
			 @Emp_WO_OT_Rate = isnull(Emp_WeekOff_OT_Rate,0) , @Emp_HO_OT_Rate = isnull(Emp_Holiday_OT_Rate,0), @Fix_OT_Hour_Rate_WOHO = Fix_OT_Hour_Rate_WO_HO, 
			 @Fix_Salary=isnull(Emp_Fix_Salary,0) --Added by nilesh Patel on 25112015 --Start
			 ,@Basic_Salary_Sett = ISNULL(I.Increment_Amount,0)	--Ankit 02022016
		From T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @s_Month_End_Date
					and Cmp_ID = @Cmp_ID and Increment_type <> 'Transfer' and Increment_type <> 'Deputation' --Added by Hasmukh for Transfer & deputation condition remove 01082014
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
		Where I.Emp_ID = @Emp_ID
		
		if @increment_date = @S_Month_St_Date
		Begin 
			set @increment_date = @S_Month_St_Date
		END
		else if @increment_date <= @S_Month_St_Date -- Deepal 09092021 To check the mid increment 
		Begin 
			set @increment_date = @S_Month_St_Date
		END

		-- Added by rohit for check mid increment on 02082016
		Declare @check_flag as tinyint
		set @check_flag = 0
		
		if Day(@increment_date) <> Day(@s_Month_St_DAte)
		BEGIN
			Set @check_flag = 1
		END
		
		---------------------- Start Added By Hasmukh as above condtion has been changed 01082014-----------------------
		select @Branch_ID = Branch_ID			 
			From T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @s_Month_End_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
		Where I.Emp_ID = @Emp_ID
		---------------------- End 01082014------------------------------------------------------------------------


	--	Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@S_Month_St_DAte,@S_Month_End_DAte,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output
	-- commeneted by rohit for holiday and weekoff taken from salary table on 06062016	
	--if @check_flag =1
	--begin
	--	Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@s_Month_St_DAte,@s_Month_End_DAte,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
	--end	
	--	Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@s_Month_St_DAte,@s_Month_End_DAte,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
	
	
	
	If @S_Sal_Tran_ID > 0 
		Begin	
		
			Delete FROM T0210_MONTHLY_AD_DETAIL				Where emp_id = @emp_id	and S_Sal_Tran_ID = @S_Sal_Tran_ID 
			Delete FROM T0210_MONTHLY_LOAN_PAYMENT			Where S_Sal_Tran_ID = @S_Sal_Tran_ID
			select @Sal_Tran_ID = Sal_Tran_ID ,@Sal_cal_Days = Sal_cal_Days ,@Old_Basic_Salary = Basic_Salary, @Working_Days = Working_Days 
					,@Old_Salary_amount = Salary_amount,@Old_Gross_Salary_ProRata = Actually_Gross_Salary,@Present_Days =Present_Days,@Old_Gross_Salary = Gross_Salary
					,@Old_PT_Amount = PT_Amount,@LWF_Amount_Old = LWF_Amount , @is_monthly_Salary = isnull(is_monthly_salary,0)
			from T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND MONTH(Month_End_Date) =MONTH(@s_Month_End_Date)AND YEAR(Month_End_Date) =YEAR(@s_Month_End_Date)
			Select @S_Sal_Receipt_No =  S_Sal_Receipt_No From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) Where S_Sal_Tran_ID =@S_Sal_Tran_ID

			if isnull(@Sal_Tran_ID,0) = 0 and  @M_Present_Days = 0 
				Begin
					
					Delete from T0201_MONTHLY_SALARY_SETT where S_Sal_Tran_ID =@S_Sal_Tran_ID and emp_ID =@Emp_ID
					
				end
			
		End		
	Else
		Begin	
			
			Select @S_Sal_Tran_ID =  Isnull(max(S_Sal_Tran_ID),0)  + 1   From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
			Select @S_Sal_Receipt_No =  isnull(max(s_sal_Receipt_No),0)  + 1 
			From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
			Where Month(s_Month_St_Date) = Month(@S_Month_St_Date) 
							and YEar(s_Month_St_Date) = Year(@s_Month_End_Date) and Cmp_ID= @Cmp_ID

							

			if @Wages_Type='Daily'	
				begin
					select @Sal_Tran_ID = Sal_Tran_ID ,@Sal_cal_Days = Sal_cal_Days ,@Old_Basic_Salary = Day_Salary , @Working_Days = Working_Days 
							,@Old_Salary_amount = Salary_amount,@Old_Gross_Salary_ProRata = Actually_Gross_Salary,@Present_Days =Present_Days ,@Old_Gross_Salary = Gross_Salary
							,@Old_PT_Amount = PT_Amount,@LWF_Amount_Old = LWF_Amount , @is_monthly_Salary = isnull(is_monthly_salary,0)
							,@Emp_OT_Hours_Num = ISNULL(OT_Hours,0) , @Emp_WO_OT_Hours_Num = ISNULL(M_WO_OT_Hours,0) , @Emp_HO_OT_Hours_Num = ISNULL(M_HO_OT_Hours,0),
							@numAbsentDays = ISNULL(Absent_Days,0) -- Added by nilesh patel on 25112015
							,@Present_Days = Present_Days ,@Sal_cal_Days = Sal_Cal_Days,@Weekoff_Days=Weekoff_Days, -- Added by rohit on 06062016
							@Holiday_Days=@Holiday_Days,@Paid_leave_Days=Paid_Leave_Days,@Working_Days = Working_Days,@Outof_Days = Outof_Days
					from T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND MONTH(Month_End_Date) =MONTH(@S_MONTH_End_dATE)AND YEAR(MONTH_End_DATE) =YEAR(@S_MONTH_End_dATE)
				end
			else
				begin
					select @Sal_Tran_ID = Sal_Tran_ID ,@Sal_cal_Days = Sal_cal_Days + Isnull(Qry.Arear_Day,0) + ISNULL(Qry_Cutoff.Arear_Day_Previous_month,0)  ,@Old_Basic_Salary = Basic_Salary, @Working_Days = Working_Days 
							,@Old_Salary_amount = Salary_amount,@Old_Gross_Salary_ProRata = Actually_Gross_Salary,@Present_Days =Present_Days ,@Old_Gross_Salary = Gross_Salary
							,@Old_PT_Amount = PT_Amount,@LWF_Amount_Old = LWF_Amount , @is_monthly_Salary = isnull(is_monthly_salary,0)
							,@Emp_OT_Hours_Num = ISNULL(OT_Hours,0) , @Emp_WO_OT_Hours_Num = ISNULL(M_WO_OT_Hours,0) , @Emp_HO_OT_Hours_Num = ISNULL(M_HO_OT_Hours,0),
							@numAbsentDays = ISNULL(Absent_Days,0) -- Added by nilesh patel on 25112015
							,@Present_Days = Present_Days ,@Weekoff_Days=Weekoff_Days, -- Added by rohit on 06062016
							@Holiday_Days=@Holiday_Days,@Paid_leave_Days=Paid_Leave_Days,@Working_Days = Working_Days,@Outof_Days = Outof_Days
					from T0200_MONTHLY_SALARY WITH (NOLOCK) Left Outer Join
						(Select Emp_ID, Arear_Day from T0200_MONTHLY_SALARY  WITH (NOLOCK)  --- Added by Hardik 18/10/2017 for Aculife, Arear Days Calculation not working in Settlement
							Where EMP_ID = @EMP_ID AND Arear_Month =MONTH(@S_MONTH_End_dATE)AND Arear_Year =YEAR(@S_MONTH_End_dATE)) Qry
						On T0200_MONTHLY_SALARY.Emp_ID= Qry.Emp_ID Left Outer Join
						(Select Emp_ID, Arear_Day_Previous_month from T0200_MONTHLY_SALARY WITH (NOLOCK)
							Where EMP_ID = @EMP_ID AND Month(Month_End_Date) =MONTH(dateadd(mm,1,@S_MONTH_End_dATE))AND Year(Month_End_Date) =YEAR(dateadd(mm,1,@S_MONTH_End_dATE))) Qry_Cutoff
						On T0200_MONTHLY_SALARY.Emp_ID= Qry_Cutoff.Emp_ID
					WHERE T0200_MONTHLY_SALARY.EMP_ID = @EMP_ID AND MONTH(Month_End_Date) =MONTH(@S_MONTH_End_dATE)AND YEAR(Month_End_Date) =YEAR(@S_MONTH_End_dATE)
					
					
					--'' Get old amount IF Same Sett Exists Then --Ankit 02012016
					IF EXISTS( SELECT 1 FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND MONTH(S_Month_End_Date) =MONTH(@S_MONTH_End_dATE)AND YEAR(S_MONTH_END_DATE) =YEAR(@S_MONTH_End_dATE) )
						BEGIN
							SELECT @Old_Basic_Salary = @Old_Basic_Salary + S_Basic_Salary  
								,@Old_Salary_amount = @Old_Salary_amount + S_Salary_Amount
								,@Old_Gross_Salary_ProRata =  @Old_Gross_Salary_ProRata + S_Actually_Gross_Salary
								,@Old_Gross_Salary = @Old_Gross_Salary +  S_Gross_Salary
								,@Old_PT_Amount = @Old_PT_Amount + S_PT_Amount
							FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND MONTH(S_Month_End_Date) =MONTH(@S_MONTH_End_dATE)AND YEAR(S_Month_End_Date) =YEAR(@S_MONTH_End_dATE)
						END
				end
	
	
			--Ankit For Allow Settlement in twice a month	--04122015	
					
			SELECT @Sett_Increment_ID = Increment_ID
			FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
			WHERE emp_id = @emp_id  AND Cmp_ID= @Cmp_ID AND MONTH(S_Month_End_Date) = MONTH(@S_MONTH_End_dATE) AND YEAR(S_Month_End_Date) = YEAR(@S_MONTH_End_dATE)
				AND MONTH(S_Eff_Date) = MONTH(@S_Eff_Date) AND YEAR(S_Eff_Date) = YEAR(@S_Eff_Date)
			
			if isnull(@Sal_Tran_ID,0) = 0 and  @M_Present_Days = 0 
				begin
					SET @S_Sal_Tran_ID = -101
					Return
				end
			
			
			if exists(select emp_id from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where emp_id=@emp_id and sal_tran_id=@Sal_Tran_ID 
						AND  Increment_ID = @Sett_Increment_ID)
				begin
					SET @S_Sal_Tran_ID = 0
					Return
				end
				
			
								
			INSERT INTO T0201_MONTHLY_SALARY_SETT
								  (S_Sal_Tran_ID, Sal_Tran_ID, S_Sal_Receipt_No, Cmp_ID, Increment_ID, Emp_ID, S_Month_St_Date, S_Month_End_Date, S_Sal_Generate_Date, 
								  S_Sal_Cal_Days, S_Working_Days, S_Outof_Days, S_OT_Hours, S_Shift_Day_Sec, S_Shift_Day_Hour, S_Basic_Salary, S_Day_Salary, 
								  S_Hour_Salary, S_Salary_Amount, S_Allow_Amount, S_OT_Amount, S_Other_Allow_Amount, S_Gross_Salary, S_Dedu_Amount, S_Loan_Amount, 
								  S_Loan_Intrest_Amount, S_Advance_Amount, S_Other_Dedu_Amount, S_Total_Dedu_Amount, S_Due_Loan_Amount, S_Net_Amount, 
								  S_Actually_Gross_Salary, S_PT_Amount, S_PT_Calculated_Amount, S_Total_Claim_Amount, S_M_OT_Hours, S_M_Adv_Amount, S_M_Loan_Amount, 
								  S_M_IT_Tax, S_LWF_Amount, S_Revenue_Amount, S_PT_F_T_Limit, S_Sal_Type, S_Eff_Date, Login_ID, Modify_Date,Effect_On_Salary)
			VALUES     (@S_Sal_Tran_ID,@Sal_Tran_ID,@S_Sal_Receipt_No,@Cmp_ID,@Increment_ID,@Emp_ID,@S_Month_St_Date,@S_Month_End_Date,@S_Sal_Generate_Date,
								   0, 0, 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '',@S_Sal_Type,@S_Eff_Date,@Login_ID,getdate(),@Effect_On_Salary)
			
		End
		
		select @ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff, @Inc_Holiday = Inc_Holiday,@Late_Adj_Day = isnull(Late_Adj_Day,0)
		,@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = Isnull(OT_Max_Limit,'00:00')
		,@Is_OT_Inc_Salary = isnull(OT_Inc_Salary,0) 
		,@Is_Daily_OT = Is_Daily_OT 
		,@Is_Cancel_Holiday = Is_Cancel_Holiday
		,@Is_Cancel_Weekoff = Is_Cancel_Weekoff
		,@Fix_Shift_Hours = ot_Fix_Shift_Hours
		,@Fix_OT_Work_Days = isnull(OT_fiX_Work_Day,0)
		,@Is_PT = isnull(Is_PT,0)
		,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month
		,@Revenue_amount = Revenue_amount , @Revenue_on_Amount =Revenue_on_Amount,@Wages_Amount =Wages_Amount
		,@Is_Rounding = AD_Rounding
		,@Is_Negative_Ot=Isnull(Is_Negative_Ot,0),@Is_OT_Auto_Calc = isnull(Is_OT_Auto_Calc,0)
		,@Restrict_Present_Days = Restrict_Present_days
		from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@s_Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

		if month(@s_Month_End_Date) = MONTH(@increment_date) and year(@s_Month_End_Date) = year(@increment_date) -- condition added by mitesh on 27/12/2011
			begin
				
				declare @temp_old_salary numeric(12,2)
				declare @temp_Old_Gross_Salary_ProRata numeric(25,5)
				declare @temp_sal_cal_days numeric(12,2)
				
				set @temp_old_salary = @Old_Salary_amount 
				set @temp_sal_cal_days = @Sal_cal_Days
				set @temp_Old_Gross_Salary_ProRata = @Old_Gross_Salary_ProRata
			
				
				
				-------- start --------
				if @check_flag = 1 -- Uncommented by rohit for mid increment case.on 02082016
				begin
				-- commeneted by rohit for data taken from salary on 06062016
					If @Is_Negative_Ot =1
					Begin 		
						If Exists(Select Tran_Id From T0160_OT_Approval WITH (NOLOCK) Where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And For_Date>=@increment_date and For_Date <=@s_Month_End_Date )
							Begin
									Select @Present_Days = ISNULL(P_Days_Count,0),@Actual_Working_Sec= ISNULL(SUM(Working_Sec),0), @Emp_OT_Sec =  ISNULL(Sum(Approved_OT_Sec),0), @Emp_WO_OT_Sec = ISNULL(sum(Approved_WO_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Approved_HO_OT_Sec),0) From T0160_OT_Approval WITH (NOLOCK) Where Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And For_Date>=@increment_date and For_Date <=@s_Month_End_Date Group By P_days_count								
									Set @Actual_Working_Sec = @Actual_Working_Sec*3600												
							End
						Else
							Begin
								--Added by Hardik 01/05/2017 for Manual Imported Attendance for Aculife
								IF EXISTS(SELECT EMP_ID FROM T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND [Month]=Month(@S_Month_End_Date) and [year]=YEAR(@S_Month_End_Date))
									Begin			
										exec SP_GET_PRESENT_DAYS @EMP_ID,@Cmp_ID,@increment_date,@S_Month_End_Date, @Present_Days output,@Absent_Days output,@Holiday_Days output,@Weekoff_Days output,1
										Set @Actual_Working_Sec = 0
										Set @Emp_OT_Sec = 0
										Set @Emp_WO_OT_Sec = 0
										Set @Emp_HO_OT_Sec = 0
									End
								Else
									BEGIN
							
										Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@increment_date,@S_Month_End_Date,0,0,0,0,0,0,@emp_ID,'',4 
										
										select @Present_Days = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0), @Emp_OT_Sec = isnull(sum(OT_Sec),0), @Emp_WO_OT_Sec = ISNULL(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Holiday_OT_Sec),0)  From  #Data where Emp_ID=@emp_ID     
											and For_Date >= @increment_date and For_Date <=@s_Month_End_Date  
									END

							End
					End
				Else
					Begin
						--Added by Hardik 01/05/2017 for Manual Imported Attendance for Aculife
						IF EXISTS(SELECT EMP_ID FROM T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and EMP_ID=@EMP_ID AND [Month]=Month(@S_Month_End_Date) and [year]=YEAR(@S_Month_End_Date))
							Begin			
								exec SP_GET_PRESENT_DAYS @EMP_ID,@Cmp_ID,@increment_date,@S_Month_End_Date, @Present_Days output,@Absent_Days output,@Holiday_Days output,@Weekoff_Days output,1
								Set @Actual_Working_Sec = 0
								Set @Emp_OT_Sec = 0
								Set @Emp_WO_OT_Sec = 0
								Set @Emp_HO_OT_Sec = 0
							End
						Else
							BEGIN
								Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@increment_date,@S_Month_End_Date,0,0,0,0,0,0,@emp_ID,'',4  
								
								if @Is_OT_Auto_Calc = 0
									begin
									
									
										update #Data         
											set OT_Sec = 0 ,Weekoff_OT_Sec = 0, Holiday_OT_Sec = 0 -- * 3600        
											from #Data -- d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
									
										update #Data         
											  set OT_Sec = isnull(Approved_OT_Sec,0), Weekoff_OT_Sec = isnull(Approved_WO_OT_Sec,0), Holiday_OT_Sec = isnull(Approved_HO_OT_Sec,0)  -- * 3600        
											from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date     
									end

									select @Present_Days = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0), @Emp_OT_Sec = isnull(sum(OT_Sec),0), 
										@Emp_WO_OT_Sec = ISNULL(sum(Weekoff_OT_Sec),0) ,@Emp_HO_OT_Sec =  ISNULL(sum(Holiday_OT_Sec),0)  
									From  #Data where Emp_ID=@emp_ID     
									and For_Date>=@increment_date and For_Date <=@s_Month_End_Date  
							END
							
								
							
				  End
				 --ended by rohit on 06062016
					
					declare @daysdiff as numeric
					declare @daysdiffMonth as numeric
					 --commeneted by rohit for data taken from Salary table on 06062016
					if @is_monthly_Salary = 0
							begin
								
								--if day(@increment_date) > 1
								--	begin
								--		set @Sal_cal_Days = @Sal_cal_Days - day(dateadd(dd,-1,@increment_date))
								--	end
								--else
								--	begin
								--		set @Sal_cal_Days = @Sal_cal_Days -- - day(@increment_date)
								--	end
								
								
								if @increment_date < @s_Month_End_Date
									begin
										
									--	insert into #dayDiff
									--	select * from dbo.Split(dbo.F_GET_AGE(dateadd(dd,-1,@increment_date),@s_Month_End_Date,'y','Y'),'.')
									
										set @daysdiff =0
										set @daysdiffMonth =0
																						
										set @daysdiff = datediff(d,dateadd(dd,-1,@increment_date),@s_Month_End_Date)
										
																			
										if @daysdiff > 0 and @Sal_cal_Days >= @daysdiff
											begin										
												set @Sal_cal_Days = @daysdiff
											end
										else 
											begin										
												set @Sal_cal_Days = @Sal_cal_Days
											end
										end
									else if @increment_date = @s_Month_End_Date
										begin												
											set @Sal_cal_Days = 1
										end
									
							end
						else
							begin
									
									--select @Paid_Leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and     
									--	  SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'P' --and For_Date >= @increment_date
										  
											
											
									--if @Paid_Leave_Days  > 0
									--	begin
									--		set @Paid_Leave_Days = 0
											
																						
									--		select @Paid_Leave_Days = Sum(LeavE_Used) From T0140_leave_Transaction LT
									--			Inner join T0040_Leave_Master LM on LT.Leave_ID = LM.Leave_ID And isnull(LT.Eff_In_Salary,0)=0
									--			Where Emp_ID = @Emp_ID and For_Date >=@increment_date  and For_Date <=@s_Month_End_Date and lm.Leave_Paid_Unpaid = 'P'
												
										  
									--	end
										
									Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@increment_date,@s_Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
									Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@increment_date,@s_Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
									
									--Commented by Hardik 02/08/2016 as Aculife has issue when Mid increment
									--select @Paid_Leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail where Emp_ID = @emp_ID and     
									--	  SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'P'
									
									--Added below condition by Hardik 02/08/2016 for Mid Increment case									
									--where emp_id=@emp_id and For_Date >= @increment_date and For_Date <= @s_Month_End_Date and
									--	Leave_Id in (Select Leave_Id From T0040_LEAVE_MASTER where cmp_id=@cmp_Id and Leave_Paid_Unpaid='P')
									
									SELECT	@Paid_Leave_Days = Isnull(SUM(Case When lm.Default_Short_Name='COMP' 
									Then CompOff_Used Else Leave_Used End),0) --18082017 ADDED BY RAJPUT COMP-OFF LEAVE DOES NOT COME IN SALARY SETTLEMENT
									from	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
											INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
									where	emp_id=@emp_id and For_Date >= @increment_date and For_Date <= @s_Month_End_Date 
											AND LM.cmp_id=@cmp_Id and LM.Leave_Paid_Unpaid='P'
									
		

									---Added by Hardik 23/03/2015 for Vital Soft as they want to show All Half Paid leave in Count and don't want to show Absent Days. 
										DECLARE @Total_Half_Paid_Leave as NUMERIC(18, 4)
										
										SELECT @Total_Half_Paid_Leave = Isnull(SUM(Leave_Used),0)+ Isnull(SUM(CompOff_Used),0) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)
										where emp_id=@emp_id and For_Date >= @increment_date and For_Date <= @s_Month_End_Date and
											Leave_Id in (Select Leave_Id From T0040_LEAVE_MASTER WITH (NOLOCK) where cmp_id=@cmp_Id and Isnull(Half_Paid,0)=1) and Isnull(Half_Payment_Days,0)=0
									 
										if @Total_Half_Paid_Leave > 0
											BEGIN
												--Set @Total_leave_Days = @Total_leave_Days + (ISNULL(@Total_Half_Paid_Leave,0)/2)
												Set @Paid_leave_Days = @Paid_leave_Days + (ISNULL(@Total_Half_Paid_Leave,0)/2)
											End
									---- End by Hardik 23/03/2015
									if @Fix_Salary <> 1 
										Begin
											If @Inc_Weekoff = 1
												begin
													if @Inc_Holiday = 1
														set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days + @Holiday_Days
													else 		
														set @Sal_cal_Days = @Present_Days +  @Weekoff_Days + @Paid_Leave_Days  
												end
											Else 
												 begin
												   if @Inc_Holiday = 1
														set @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days + @Holiday_Days
													else 		
														set @Sal_cal_Days = @Present_Days  + @Paid_Leave_Days  
												 end
										End
									
								
								 IF @Sal_cal_Days > @Working_Days and @Restrict_Present_Days = 'Y'    
								  SET @Sal_cal_Days = @Working_Days     

										---Added this condition by Hardik on 30/03/2015 as Sal Cal days are more than Actual working days..
										set @daysdiff =0
										set @daysdiffMonth =0

									if @increment_date < @s_Month_End_Date
										begin																						
											set @daysdiff = datediff(d,dateadd(dd,-1,@increment_date),@s_Month_End_Date)
										
											if @daysdiff > 0 and @Sal_cal_Days >= @daysdiff
												begin										
													set @Sal_cal_Days = @daysdiff
												end
											else 
												begin										
													set @Sal_cal_Days = @Sal_cal_Days
												end
											end
									else if @increment_date = @s_Month_End_Date
										begin												
											set @Sal_cal_Days = 1
										end
								  
							end
					end		
					-- ended by rohit on 06062016
			  -------- end --------
			 
			 -- set @Sal_cal_Days = @temp_sal_cal_days
			--select @temp_old_salary,@temp_sal_cal_days,@Sal_cal_Days
			--	set @Sal_cal_Days = @Sal_cal_Days - day(@increment_date)
				IF @temp_sal_cal_days > 0
					BEGIN
						set @Old_Salary_amount = ( @temp_old_salary / @temp_sal_cal_days ) * @Sal_cal_Days
						set @Old_Gross_Salary_ProRata = ( @temp_Old_Gross_Salary_ProRata / @temp_sal_cal_days ) * @Sal_cal_Days
					END
				ELSE
					BEGIN
						set @Old_Salary_amount = 0
						set @Old_Gross_Salary_ProRata = 0
					END
				
				
			end
					
		Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_Id,@Cmp_ID,@s_Month_End_Date,null,null,@Shift_Day_Hour output
		select @Shift_Day_Sec = dbo.F_Return_Sec(@Shift_Day_Hour)
		select @Emp_OT_Min_Sec = dbo.F_Return_Sec(@Emp_OT_Min_Limit)
		select @Emp_OT_Max_Sec = dbo.F_Return_Sec(@Emp_OT_Max_Limit)

	
	if isnull(@sal_Tran_ID,0)=0
		begin
			if @Inc_Weekoff <> 1
				Set @Working_Days = @Outof_Days - @WeekOff_Days 
			else
				Set @Working_Days = @Outof_Days 
		end

	--if @Fix_Salary =1 -- Added by rohit on 01102016
	--begin
	--Set @Sal_cal_Days = @Working_Days 
	--end
	--Changed By Jimit 03042019 As calculate Proraated days when given bacdated mid increment Bug No. 8159
	if @Fix_Salary = 1 
		BEGIN
			If @Inc_Weekoff = 1
				begin
					if @Join_Date >= @S_Month_St_Date and @Join_Date <= @S_Month_End_Date 
						Begin
							if @Inc_Holiday = 1
								SET @Sal_cal_Days = (datediff(d,@Join_Date,@S_Month_End_Date) + 1)
							else 
								SET @Sal_cal_Days = datediff(d,@Join_Date,@S_Month_End_Date) + 1 - @Holiday_Days
						End
					Else
						Begin
							if @Inc_Holiday = 1
								SET @Sal_cal_Days = datediff(d,@S_Month_St_Date,isnull(@left_date,@S_Month_End_Date)) + 1
							else 
								SET @Sal_cal_Days = (datediff(d,@S_Month_St_Date,isnull(@left_date,@S_Month_End_Date)) + 1) - @Holiday_Days 
						End
				end
			Else 
				begin
					if @Join_Date >= @S_Month_St_Date and @Join_Date <= @S_Month_End_Date 
						Begin
							if @Inc_Holiday = 1
								SET @Sal_cal_Days = datediff(d,@Join_Date,@S_Month_End_Date) + 1 - @Weekoff_Days
							else 
								SET @Sal_cal_Days = datediff(d,@Join_Date,@S_Month_End_Date) + 1 - @Holiday_Days - @Weekoff_Days
						End
					Else
						Begin
							if @Inc_Holiday = 1
								SET @Sal_cal_Days = (datediff(d,@S_Month_St_Date,isnull(@left_date,@S_Month_End_Date)) + 1) - @Weekoff_Days
							else 		
								SET @Sal_cal_Days = (datediff(d,@S_Month_St_Date,isnull(@left_date,@S_Month_End_Date)) + 1) - @Holiday_Days - @Weekoff_Days
						End
				end 
		END
	--Ended


	SET @Basic_Salary = @Basic_Salary - @old_Basic_Salary		--Added By Ankit 06082015
	
	-----------------------For OT Day Rate Add by ronak k 18092023 -------------------------
	
	Declare @GrossOT decimal(18,2)
	Declare @OTDay_Salary decimal(18,2)
	
	SELECT @GrossOT =  ISNULL(SUM(E_AD_amount),0)
			- (select Sum(isnull(M_AD_Actual_Per_Amount,0)) from T0210_MONTHLY_AD_DETAIL MAD
					inner join T0050_AD_MASTER AD on AD.AD_ID = MAD.AD_ID
					where Emp_ID =@Emp_Id and For_Date between @S_Month_St_Date and @s_Month_End_Date
					and S_Sal_Tran_ID is null and  AD.AD_ACTIVE = 1 AND ISNULL(AD.AD_EFFECT_ON_OT,0) = 1 
					and MAD.M_AD_Flag <> 'D')

				FROM (
					SELECT 
							Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
							Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
							Else
							eed.e_ad_Amount End As E_Ad_Amount,ADM.AD_NAME
					FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
							dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID    LEFT OUTER JOIN
							( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID
								From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
								( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
									Where Emp_Id = @Emp_Id And For_date <= @s_Month_End_Date Group by Ad_Id 
									) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
							) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
					WHERE EED.EMP_ID = 2030 AND eed.increment_id = @Increment_ID And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_OT,0) = 1 
							And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
					UNION ALL
											
					SELECT E_AD_Amount,ADM.AD_NAME
					FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
						( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) 
							Where Emp_Id  = 2030 And For_date <= @s_Month_End_Date
							Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
						INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID                     
					WHERE emp_id = @Emp_Id 
							And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_OT,0) = 1 
							And EEd.ENTRY_TYPE = 'A' AND eed.increment_id = @Increment_ID
					) Qry

-------------------------------------------------------------------------END --------------------------------------------------------
	
	If @Wages_Type = 'Monthly' 
		if @Inc_Weekoff = 1 And @Inc_Holiday = 1
			begin
				set @Day_Salary = 	@Basic_Salary / @Outof_Days 
				set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days
				set  @OTDay_Salary = (@Basic_Salary+@GrossOT) / @Outof_Days   --Added by ronakk 18092023
			end 
		else
			begin
				set @Day_Salary = 	@Basic_Salary / @Working_Days
				set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days
				set  @OTDay_Salary = (@Basic_Salary+@GrossOT) / @Working_Days  --Added by ronakk 18092023
			end 
	Else
		set @Day_Salary = 	@Basic_Salary
		


If @SalaryBasis='Fix Hour Rate'--Nikunj 19-04-2011
	Begin			 		
		 Set @Hour_Salary = @Day_Salary
	End
Else
	Begin
		if @Shift_Day_Sec > 0
			begin
			
				SET @Hour_Salary = @Day_Salary * 3600/@Shift_Day_Sec
				SET @Hour_Salary_OT = @OTDay_Salary * 3600/@Shift_Day_Sec --Change by ronakk 18092023
			End	
	End	
	
declare @Temp_Salary_Amount_Sett as Numeric(18,2) --Hardik 13/06/2012 for increment given in Percentage of allowance also
	
	Set @Salary_Amount =  Round(@Day_Salary * @M_Present_Days,@Round) 
	

	-- change by falak on 06-sep-2010
	if @M_Present_Days > 0
		Begin 
			If @Is_Rounding = 1   -- addded by hasmukh for rounding/decimal on 16 11 2011
				set @Gross_Salary_ProRata	= Round(@Gross_Salary_ProRata * @M_Present_Days,@Round)
			Else
				set @Gross_Salary_ProRata	= @Gross_Salary_ProRata * @M_Present_Days
		End
	
	IF @Is_Rounding = 1   -- addded by hasmukh for rounding/decimal on 16 11 2011
		BEGIN
			SET @Salary_Amount_Sett			=  Round(@Day_Salary * @Sal_Cal_Days,@Round) --- @old_Salary_Amount	 -- @old_Salary_Amount Comment By Ankit 06082015
			Set @Temp_Salary_Amount_Sett    = Round(@Day_Salary * @Sal_Cal_Days,@Round) --Hardik 13/06/2012 for increment given in Percentage of allowance also
			set @Gross_Salary_ProRata_Sett	= Round(@Gross_Salary_ProRata * @Sal_Cal_Days,@Round)  - @old_Gross_Salary_PRorata	
		END
	ELSE
		BEGIN		
			Set @Salary_Amount_Sett			= @Day_Salary * @Sal_Cal_Days --- @old_Salary_Amount	-- @old_Salary_Amount Comment By Ankit 06082015
			Set @Temp_Salary_Amount_Sett    = @Day_Salary * @Sal_Cal_Days --Hardik 13/06/2012 for increment given in Percentage of allowance also
			set @Gross_Salary_ProRata_Sett	= @Gross_Salary_ProRata * @Sal_Cal_Days - @old_Gross_Salary_PRorata	
		END
	
	
	--set @Basic_Salary = @Basic_Salary - @old_Basic_Salary	----This Line Add before Cal Days Salary --Ankit 06082015

		--Added by Hardik 14/11/2018 for Shift Wise OT Rate, For Shoft Ship Yard 
		Set @Shift_Wise_OT_Calculated = 0
		
		If @EMP_OT = 1 And @Shift_Wise_OT_Rate = 1 And Isnull(@Emp_WD_OT_Rate,0) = 9 And Isnull(@Emp_WO_OT_Rate,0) = 9 And Isnull(@Emp_HO_OT_Rate,0) = 9
			BEGIN
				Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@S_Month_St_Date,@S_Month_End_Date,0,0,0,0,0,0,@emp_ID,'',4 

				If @StrWeekoff_Date = ''
					Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@increment_date,@s_Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output
				
				If @StrHoliday_Date = ''
					Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@increment_date,@s_Month_End_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
				
				SELECT	D.EMP_ID, D.Shift_ID, D.For_Date, 
						Case When @Is_OT_Auto_Calc = 1 Then Isnull(D.OT_Sec,0) Else Isnull(OA.Approved_OT_Sec,0) End As OT_Sec, 
						Case When @Is_OT_Auto_Calc = 1 Then Isnull(D.Holiday_OT_Sec,0) Else Isnull(OA.Approved_HO_OT_Sec,0) End As Holiday_OT_Sec, 
						Case When @Is_OT_Auto_Calc = 1 Then Isnull(D.Weekoff_OT_Sec,0) Else Isnull(OA.Approved_WO_OT_Sec,0) End As Weekoff_OT_Sec, 
						Case WHEN H.For_Date IS NOT NULL THEN SM.Shift_Holiday_OT_Rate ELSE 0 END HO_OT_Rate,
						Case WHEN W.For_Date IS NOT NULL THEN SM.Shift_WeekOff_OT_Rate ELSE 0 END WO_OT_Rate,
						Case WHEN H.For_Date IS NULL AND W.For_Date IS NULL Then SM.Shift_WeekDay_OT_Rate Else 0 END As WD_OT_Rate,
						Cast(0.00 As Numeric(18,2)) As HO_OT_Amount, 
						Cast(0.00 As Numeric(18,2)) As WO_OT_Amount, 
						Cast(0.00 As Numeric(18,2)) As WD_OT_Amount,
						Cast(Isnull(@Hour_Salary_OT,0) As Numeric(18,4)) As Hourly_Salary
				INTO	#ShiftWiseOT
				FROM	#Data D
						INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON D.Shift_ID=SM.Shift_ID
						LEFT OUTER JOIN (SELECT Id,Cast(Data As Datetime)as For_Date FROM dbo.Split(@StrWeekoff_Date,';')) W On D.For_date = W.For_Date
						LEFT OUTER JOIN (SELECT Id,Cast(Data As Datetime)as For_Date FROM dbo.Split(@StrHoliday_Date,';')) H On D.For_date = H.For_Date
						--LEFT OUTER JOIN #Emp_WeekOff_Sal W ON D.Emp_ID=W.Emp_ID AND D.For_Date = W.For_Date AND W.Is_Cancel=0
						--LEFT OUTER JOIN #Emp_Holiday_Sal H ON D.Emp_ID=H.Emp_ID AND D.For_Date = H.For_Date AND H.Is_Cancel=0
						LEFT OUTER JOIN T0160_OT_APPROVAL OA ON OA.Emp_ID=D.Emp_Id And OA.For_Date = D.For_Date And OA.Is_Approved = 1
				WHERE	D.Emp_Id = @Emp_Id And D.For_date Between @S_Month_St_Date And @s_Month_End_Date


				DELETE	#ShiftWiseOT 
				WHERE	(ISNULL(HO_OT_Rate,0) + ISNULL(WO_OT_Rate,0) + ISNULL(WD_OT_Rate,0) = 0) OR
						(ISNULL(OT_Sec,0) + ISNULL(Holiday_OT_Sec,0) + ISNULL(Weekoff_OT_Sec,0) = 0)

				/*
				UPDATE	#ShiftWiseOT
				SET		HO_OT_Amount = Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec),':','.') As Numeric(18,2)) * HO_OT_Rate * @Hour_Salary_OT,
						WO_OT_Amount = Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec),':','.')As Numeric(18,2)) * WO_OT_Rate * @Hour_Salary_OT,
						WD_OT_Amount = Cast(Replace(dbo.F_Return_Hours(OT_Sec),':','.')As Numeric(18,2)) * WD_OT_Rate * @Hour_Salary_OT
				*/
				
				UPDATE	#ShiftWiseOT
				SET		HO_OT_Amount = (Holiday_OT_Sec/3600) * HO_OT_Rate * @Hour_Salary_OT,
						WO_OT_Amount = (Weekoff_OT_Sec/3600) * WO_OT_Rate * @Hour_Salary_OT,
						WD_OT_Amount = (OT_Sec/3600) * WD_OT_Rate * @Hour_Salary_OT

				SELECT
					@Emp_HO_OT_Hours_Num = Cast(Replace(dbo.F_Return_Hours(SUM(Holiday_OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_HO_OT_Sec = Sum(Holiday_OT_Sec), 
					@HO_OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(HO_OT_Amount),0) Else Sum(HO_OT_Amount) End,0),
					
					@Emp_WO_OT_Hours_Num = Cast(Replace(dbo.F_Return_Hours(SUM(Weekoff_OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_WO_OT_Sec = Sum(Weekoff_OT_Sec), 
					@WO_OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(WO_OT_Amount),0) Else Sum(WO_OT_Amount) End,0),
					
					@Emp_OT_Hours_Num = Cast(Replace(dbo.F_Return_Hours(SUM(OT_Sec)),':','.') As Numeric(18,2)),
					@Emp_OT_Sec = Sum(OT_Sec), 
					@OT_Amount = Isnull(Case When @IS_ROUNDING = 1 Then Round(Sum(WD_OT_Amount),0) Else Sum(WD_OT_Amount) End,0)
				FROM #ShiftWiseOT

				Set @Shift_Wise_OT_Calculated = 1
			END	


	
	IF @EMP_OT = 1 AND @Shift_Wise_OT_Calculated = 0
		Begin
			--If @Emp_OT_Sec > 0  and @Emp_OT_Min_Sec > 0 and @Emp_OT_Sec < @Emp_OT_Min_Sec
			--	set @Emp_OT_Sec = 0
			--Else If @Emp_OT_Sec > 0 and @Emp_OT_Max_Sec > 0 and @Emp_OT_Sec > @Emp_OT_Max_Sec
			--	set @Emp_OT_Sec = @Emp_OT_Max_Sec
				
			--If @Emp_OT_Sec > 0
			--	set @OT_Amount = round((@Emp_OT_Sec/3600) * @Hour_Salary_OT,0)
				
			--If @ExOTSetting > 0 and @OT_Amount > 0
			--	set @OT_Amount = @OT_Amount + @OT_Amount * @ExOTSetting 
				
			--select @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)
			
			
			
			--'' Over Time Calculation --Ankit 06082015
			
			IF @Emp_OT_Hours_Num > 0
				BEGIN
					IF @Is_Rounding = 1
						BEGIN
							IF @Fix_OT_Hour_Rate_WD = 0	
								SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Hour_Salary_OT,@Round) * @Emp_WD_OT_Rate,@Round) 
							Else
								SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Fix_OT_Hour_Rate_WD,@Round) * @Emp_WD_OT_Rate,@Round) 
						END
					ELSE
						BEGIN
							IF @Fix_OT_Hour_Rate_WD = 0	
								SET @OT_Amount = ((@Emp_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_WD_OT_Rate 
							ELSE
								SET @OT_Amount = ((@Emp_OT_Hours_Num) * @Fix_OT_Hour_Rate_WD) * @Emp_WD_OT_Rate 
						END
				END
			
			IF @Emp_WO_OT_Hours_Num > 0
				BEGIN
					If @Is_Rounding = 1
						BEGIN
							IF @Fix_OT_Hour_Rate_WOHO = 0	
								SET @WO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @Hour_Salary_OT,@Round) * @Emp_WO_OT_Rate,@Round) 
							ELSE
								SET @WO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO,@Round) * @Emp_WO_OT_Rate,@Round) 
						END
					ELSE
						BEGIN
							IF @Fix_OT_Hour_Rate_WOHO = 0	
								SET @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_WO_OT_Rate   
							ELSE
								SET @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO) * @Emp_WO_OT_Rate  	
						END	
				END
				
			IF @Emp_HO_OT_Hours_Num > 0   
				BEGIN
					IF @Is_Rounding = 1
						BEGIN
							IF @Fix_OT_Hour_Rate_WOHO = 0
								SET @HO_OT_Amount = Round(ROUND((@Emp_HO_OT_Hours_Num) * @Hour_Salary_OT,@Round) * @Emp_HO_OT_Rate,@Round)
							ELSE
								SET @HO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO,@Round) * @Emp_HO_OT_Rate,@Round) 	
						END
					ELSE
						BEGIN
							SET @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec / 3600
							
							IF @Fix_OT_Hour_Rate_WOHO = 0
								SET @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num) * @Hour_Salary_OT) * @Emp_HO_OT_Rate
							ELSE
								SET @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num) * @Fix_OT_Hour_Rate_WOHO) * @Emp_HO_OT_Rate
						END	
				END
				
			--'' Over Time Calculation --Ankit 06082015
			
		End
	else
		IF @Shift_Wise_OT_Calculated = 0
			Begin
				set @Emp_OT_Sec = 0
				set @OT_Amount = 0
				set @Emp_OT_Hours = '00:00'
				
			End
	
	
	EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION_SETT @S_Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@S_Month_St_Date,@s_Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,
	@Salary_Amount,@Present_Days,@numAbsentDays,@Paid_leave_Days,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,@Basic_Salary_Sett,
	@Gross_Salary_ProRata_Sett,@Salary_Amount_Sett,@Sal_Tran_ID,@M_Present_Days,@Old_Basic_Salary,@Old_Gross_Salary_ProRata,@Old_Salary_Amount,@Is_Rounding,@Outof_Days,
	@WO_OT_Amount output,@HO_OT_Amount output,@Shift_Day_Sec,@Emp_WD_OT_Rate,@Emp_OT_Hours_Num
	,@Fix_OT_Work_Days,@Emp_WO_OT_Hours_Num,@Emp_HO_OT_Hours_Num,@Emp_WO_OT_Rate,@Emp_HO_OT_Rate
	
	If @Is_Rounding = 1
		begin
			set @Salary_Amount = round(@Salary_Amount + @Salary_Amount_Sett,@Round)
			set @Gross_Salary_ProRata = round(@Gross_Salary_ProRata + @Gross_Salary_ProRata_Sett,@Round)
		end
	else
		begin
			set @Salary_Amount = @Salary_Amount + @Salary_Amount_Sett
			set @Gross_Salary_ProRata = @Gross_Salary_ProRata + @Gross_Salary_ProRata_Sett
		end
		
	SELECT @Allow_Amount = ISNULL(SUM(M_AD_AMOUNT),0) From T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
			inner JOIN dbo.T0050_AD_Master AM WITH (NOLOCK) ON MAD.AD_ID= AM.AD_ID
			WHERE S_Sal_Tran_ID = @S_Sal_Tran_ID and Emp_ID = @Emp_ID and M_AD_Flag ='I'
				and isnull(AD_Not_effect_salary,0) = 0 
				And Isnull(Allowance_Type,'A') = 'A'  
	
	SELECT @Dedu_Amount = ISNULL(SUM(M_AD_AMOUNT),0) FRom T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			WHERE S_Sal_Tran_ID = @S_Sal_Tran_ID and Emp_ID = @Emp_ID and M_AD_Flag ='D'
				and AD_ID not in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1) 

		--Added By Jimit 03082018 case at Arkray AutoPaid reim Amount is not adding in settlement
			SELECT	@Reim_amount = ISNULL(SUM(M_AD_AMOUNT),0)
					FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner JOIN dbo.T0050_AD_Master AM WITH (NOLOCK) ON MAD.AD_ID= AM.AD_ID
					WHERE	MAD.S_SAL_TRAN_ID = @S_Sal_Tran_ID and m_AD_Flag ='I' and Emp_ID = @Emp_ID  and AM.Cmp_Id=@Cmp_ID 
							and (isnull(AD_Not_effect_salary,0) = 1 and isnull(MAD.ReimShow,0) = 1) And Allowance_Type = 'R' 
							And (Isnull(AD_EFFECT_MONTH,'') = '' or CHARINDEX(AD_EFFECT_MONTH,Month(@s_Month_End_Date))>0 ) -- Added by Hardik 06/07/2020 for Amilife client
		--ended
         
	set @Dedu_Amount = isnull(@Dedu_Amount,0)
	set @Allow_Amount = isnull(@Allow_Amount,0) + ISNULL(@Reim_amount,0)
	
/*	Select @Advance_Amount =  round( isnull(Adv_closing,0),0) from T0140_Advance_Transaction where emp_id = @emp_id and Cmp_ID = @Cmp_ID
	and for_date = (select max(for_date) from  T0140_Advance_Transaction where emp_id = @emp_id and Cmp_ID = @Cmp_ID
		and for_date <=  @s_Month_End_Date)
	
	set @Advance_Amount = isnull(@Advance_Amount,0)  +  @Update_Adv_Amount
	
	
	
	exec SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@s_Month_End_Date,@S_Sal_Tran_ID,0,@IS_LOAN_DEDU
	
	
	Select @Loan_Amount = Isnull(sum(Loan_Pay_Amount),0) From T0210_Monthly_Loan_Payment where S_Sal_Tran_ID = @S_Sal_Tran_ID
	
	set @Due_Loan_Amount = 0
	
	 SELECT @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) FROM T0140_LOAN_TRANSACTION  LT INNER JOIN 
	( SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID FROM T0140_LOAN_TRANSACTION  WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID
	AND FOR_DATE <=@s_Month_End_Date
	GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID
	AND QRY.FOR_DATE = LT.FOR_DATE 
	AND QRY.EMP_ID = LT.EMP_ID
			
*/
		
		Set @Gross_Salary = ROUND(@Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount + ISNULL(@OT_Amount,0) + ISNULL(@WO_OT_Amount,0) + ISNULL(@HO_OT_Amount,0)  ,@Round)
		
		--- Commented by Hardik 12/06/2013 as per Govt Rule Once PT is deducted from Salary then you can not deduct PT again in Settlement as per HMP, Baroda
		
		--If @Is_Emp_PT =1 and @Is_PT = 1 
		--	begin
		--		set  @PT_Calculated_Amount = @Old_Gross_Salary + @Gross_Salary
		--		exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@s_Month_End_Date,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID

		--		set @PT_AMOUNT = @PT_AMOUNT - @Old_PT_Amount
		--		set @PT_Calculated_Amount = @Gross_Salary
		--	end
	
	
		if   @Gross_Salary < @Revenue_on_Amount  and @Revenue_on_Amount> 0
			set @Revenue_Amount = 0
	
		set @LWF_compare_month = '#'+ cast(Month(@S_Month_End_Date)as varchar(2)) + '#'
	
										-- change by falak on 06-sep-2010
		/*Following condition Commented by Nimesh 31-Mar-2017 (LWF Amount cannot be taken in settlement)*/
		--if charindex(@LWF_compare_month,@LWF_App_Month,1) = 0 or @LWF_App_Month ='' or @LWF_Amount_Old > 0
			begin				
				set @LWF_Amount = 0
			end		
		
					
		
		Set @Total_Dedu_Amount = @Dedu_Amount + @Other_Dedu_Amount + @Advance_Amount + @Loan_Amount  + @PT_Amount + @LWF_Amount +  @Revenue_Amount	
	
		Set @Net_Amount = @Gross_Salary - @Total_Dedu_Amount
							
	
		UPDATE  T0201_MONTHLY_SALARY_SETT
		SET	  Sal_Tran_ID = @sal_Tran_ID,Increment_ID = @Increment_ID, 
              S_Month_St_Date = @S_Month_St_Date, S_Month_End_Date = @s_Month_End_Date, S_Sal_Generate_Date = @S_Sal_Generate_Date, 
              s_Sal_Cal_Days = @Sal_cal_Days, S_Working_Days = @Working_Days, 
              S_Outof_Days = @Outof_Days, S_Shift_Day_Sec = @Shift_Day_Sec, s_Shift_Day_Hour = @Shift_Day_Hour, S_Basic_Salary = @Basic_Salary, 
              S_Day_Salary = @Day_Salary, s_Hour_Salary = @Hour_Salary, s_Salary_Amount = @Salary_Amount, s_Allow_Amount = @Allow_Amount, 
              s_OT_Amount = @OT_Amount, s_Other_Allow_Amount = @Other_Allow_Amount, s_Gross_Salary = @Gross_Salary, s_Dedu_Amount = @Dedu_Amount, 
              S_Loan_Amount = @Loan_Amount, s_Loan_Intrest_Amount = @Loan_Intrest_Amount, s_Advance_Amount = @Advance_Amount, 
              s_Other_Dedu_Amount = @Other_Dedu_Amount, s_Total_Dedu_Amount = @Total_Dedu_Amount, s_Due_Loan_Amount = @Due_Loan_Amount, 
              s_Net_Amount = @Net_Amount ,s_PT_Amount = @PT_Amount,s_PT_Calculated_Amount = @PT_Calculated_Amount ,s_Total_Claim_Amount = @Total_Claim_Amount
              ,s_M_OT_Hours = @M_OT_Hours , s_M_IT_Tax = @M_IT_Tax , s_M_Loan_Amount = @M_Loan_Amount ,s_M_Adv_Amount = @M_Adv_Amount
			  ,s_LWF_Amount = @LWF_Amount , s_Revenue_Amount = @Revenue_Amount ,s_PT_F_T_LIMIT = @PT_F_T_LIMIT
			  ,s_Actually_Gross_Salary = @Gross_Salary_ProRata
			  ,S_Sal_Type =@S_Sal_Type ,S_EFF_DATE=@S_EFF_DATE
			  ,S_OT_Hours = @Emp_OT_Hours_Num , S_WO_OT_Hours = @Emp_WO_OT_Hours_Num , S_HO_OT_Hours = @Emp_HO_OT_Hours_Num	,S_WO_OT_Amount = @WO_OT_Amount ,S_HO_OT_Amount = ISNULL(@HO_OT_Amount,0)
		WHERE S_Sal_Tran_ID =@S_Sal_Tran_ID AND EMP_ID = @EMP_ID

											-- Added for audit trail by Ali 17102013 -- Start
												Select 
												  @Old_sal_Tran_ID = Sal_Tran_ID,
												  @Old_Increment_ID = Increment_ID, 
												  @Old_S_Month_St_Date = S_Month_St_Date, 
												  @Old_s_Month_End_Date = S_Month_End_Date, 
												  @Old_S_Sal_Generate_Date = S_Sal_Generate_Date, 
												  @Old_Sal_cal_Days = S_Sal_Cal_Days, 
												  @Old_Working_Days = S_Working_Days, 
												  @Old_Outof_Days = S_Outof_Days, 
												  @Old_Shift_Day_Sec = S_Shift_Day_Sec, 
												  @Old_Shift_Day_Hour = S_Shift_Day_Hour, 
												  @Old_S_Basic_Salary = S_Basic_Salary, 
												  @Old_Day_Salary = S_Day_Salary, 
												  @Old_Hour_Salary = s_Hour_Salary, 
												  @Old_s_Salary_Amount = s_Salary_Amount, 
												  @Old_Allow_Amount = s_Allow_Amount, 
												  @Old_OT_Amount = s_OT_Amount, 
												  @Old_Other_Allow_Amount = s_Other_Allow_Amount, 
												  @Old_s_Gross_Salary = s_Gross_Salary, 
												  @Old_Dedu_Amount = s_Dedu_Amount, 
												  @Old_Loan_Amount = S_Loan_Amount, 
												  @Old_Loan_Intrest_Amount = s_Loan_Intrest_Amount, 
												  @Old_Advance_Amount = s_Advance_Amount, 
												  @Old_Other_Dedu_Amount = s_Other_Dedu_Amount, 
												  @Old_Total_Dedu_Amount = s_Total_Dedu_Amount, 
												  @Old_Due_Loan_Amount = s_Due_Loan_Amount, 
												  @Old_Net_Amount = s_Net_Amount ,
												  @Old_s_PT_Amount = s_PT_Amount,
												  @Old_PT_Calculated_Amount = s_PT_Calculated_Amount ,
												  @Old_Total_Claim_Amount = s_Total_Claim_Amount,
												  @Old_M_OT_Hours = s_M_OT_Hours , 
												  @Old_M_IT_Tax = s_M_IT_Tax , 
												  @Old_M_Loan_Amount = s_M_Loan_Amount ,
												  @Old_M_Adv_Amount = s_M_Adv_Amount,
												  @Old_LWF_Amount = s_LWF_Amount , 
												  @Old_Revenue_Amount = s_Revenue_Amount ,
												  @Old_PT_F_T_LIMIT = s_PT_F_T_LIMIT,
												  @Old_S_Gross_Salary_ProRata = s_Actually_Gross_Salary,
												  @Old_S_Sal_Type =S_Sal_Type ,
												  @Old_S_EFF_DATE = S_EFF_DATE		
												From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
												WHERE S_Sal_Tran_ID =@S_Sal_Tran_ID AND EMP_ID = @EMP_ID
												
												
												Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)
									
												set @OldValue = 'New Value' 
													+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Increment ID :' + CONVERT(nvarchar(100),ISNULL(@Old_Increment_ID,0))													
													+ '#' + 'Month Start Date :' + cast(ISNULL(@Old_S_Month_St_Date,'') as nvarchar(11))
													+ '#' + 'Month End Date :' + cast(ISNULL(@Old_s_Month_End_Date,'') as nvarchar(11))
													+ '#' + 'Salary Generate Date :' + cast(ISNULL(@Old_S_Sal_Generate_Date,'') as nvarchar(11))
													+ '#' + 'Salary Cal Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Sal_cal_Days,0))
													+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Working_Days,0))
													+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Outof_Days,0))
													+ '#' + 'Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_Shift_Day_Sec,0))
													+ '#' + 'Shift Day In Hour :' + ISNULL(@Old_Shift_Day_Hour,'')
													+ '#' + 'Basic Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Basic_Salary,0))
													+ '#' + 'Day Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_Day_Salary,0))
													+ '#' + 'Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_Hour_Salary,0))
													+ '#' + 'Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Salary_Amount,0))
													+ '#' + 'Total Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Salary_Amount,0))
													+ '#' + 'Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Allow_Amount,0))
													+ '#' + 'OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_OT_Amount,0))
													+ '#' + 'Other Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Allow_Amount,0))
													+ '#' + 'Gross Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Gross_Salary,0))
													+ '#' + 'Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Dedu_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Loan_Amount,0))
													+ '#' + 'Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Loan_Intrest_Amount,0))
													+ '#' + 'Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Advance_Amount,0))
													+ '#' + 'Other Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Dedu_Amount,0))
													+ '#' + 'Total Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Dedu_Amount,0))
													+ '#' + 'Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Due_Loan_Amount,0))
													+ '#' + 'Net Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Net_Amount,0))
													+ '#' + 'PT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_S_PT_Amount,0))
													+ '#' + 'PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_PT_Calculated_Amount,0))
													+ '#' + 'Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Claim_Amount,0))
													+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_M_OT_Hours,0))
													+ '#' + 'IT Tax :' + CONVERT(nvarchar(100),ISNULL(@Old_M_IT_Tax,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_M_Loan_Amount,0))
													+ '#' + 'Adv Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_M_Adv_Amount,0))
													+ '#' + 'LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_LWF_Amount,0))
													+ '#' + 'Revenue Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Revenue_Amount,0))
													+ '#' + 'PT F T LIMIT :' + ISNULL(@Old_PT_F_T_LIMIT,0)
													+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Gross_Salary_ProRata,0))
													+ '#' + 'Salary Type :' + ISNULL(@Old_S_Sal_Type,0)
													+ '#' + 'Effective DATE :' + cast(ISNULL(@Old_S_EFF_DATE,'') as nvarchar(11))
																											
												exec P9999_Audit_Trail @Cmp_ID,'I','Salary Settlement',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
												
											-- Added for audit trail by Ali 17102013 -- End	
		-- Added by deepal where Total M_AD_amount is 0 then delete 29102021				
		Declare @MADAmt as numeric(18,2)= 0
		select @MADAmt = sum(M_AD_Amount) from T0210_MONTHLY_AD_DETAIL where S_Sal_Tran_ID = @S_Sal_Tran_ID and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id

		If @Gross_Salary = 0 AND @Total_Dedu_Amount = 0  and @MADAmt = 0  --uncommented BY Jimit 04072017
			BEGIN				
				delete from T0210_MONTHLY_AD_DETAIL where S_Sal_Tran_ID =@S_Sal_Tran_ID and Emp_ID = @Emp_Id
				Delete from T0201_MONTHLY_SALARY_SETT where S_Sal_Tran_ID =@S_Sal_Tran_ID and Emp_ID = @Emp_Id				
			End
		-- Added by deepal where Total M_AD_amount is 0 then delete 29102021					
	RETURN



