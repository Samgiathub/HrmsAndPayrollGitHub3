

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_GENERATE_LEAVE]
 @L_Sal_Tran_ID			Numeric output
,@Emp_Id				Numeric
,@Cmp_ID				Numeric
,@L_Sal_Generate_Date	datetime
,@L_Month_St_Date		Datetime
,@L_Month_End_Date		Datetime
,@Areas_Amount			Numeric(18,4) 
,@M_IT_Tax				NUMERIC
,@Other_Dedu			Numeric(18,4)
,@M_LOAN_AMOUNT			NUMERIC
,@M_ADV_AMOUNT			NUMERIC
,@IS_LOAN_DEDU			NUMERIC --(0,1)
,@Login_ID				Numeric = null
,@ErrRaise				Varchar(100)= null output
,@Is_Negetive			Varchar(1)
,@L_Sal_Type			VARCHAR(20)
,@L_EFF_DATE			DATETIME
,@Is_FNF				int = 0
,@SAL_TRAN_ID			numeric=null
,@StrWeekoff_Date		Varchar(Max)=''      -- Hardik 07/09/2012
,@Weekoff_Days			Numeric(18,4)=0     -- Hardik 07/09/2012
,@Cancel_Weekoff		Numeric(18,4)=0     -- Hardik 07/09/2012
,@StrHoliday_Date		Varchar(Max)=''      -- Hardik 07/09/2012
,@Holiday_Days			Numeric(18,4) =0    -- Hardik 07/09/2012
,@Cancel_Holiday		Numeric(18,4) =0    -- Hardik 07/09/2012
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
	-- Variable Declaration 	

	Declare @Present_Days			Numeric(18,4) 
	declare @Sal_Receipt_No			Numeric
	Declare @Increment_ID			Numeric
	Declare @Branch_ID				numeric 
	declare @Emp_OT					numeric 
	Declare @Emp_OT_Min_Limit		varchar(10)
	Declare @Emp_OT_Max_Limit		varchar(10)
	Declare	@Emp_OT_Min_Sec			numeric
	Declare @Emp_OT_Max_Sec			numeric
	Declare @Emp_OT_Sec				numeric
	Declare @Emp_OT_Hours			varchar(10)
	declare @Wages_Type				varchar(10)
	declare @SalaryBasis			varchar(5)
	declare @Payment_Mode			varchar(20)
	declare @Fix_Salary				varchar(1)
	declare @numAbsentDays			Numeric(12,1)				   
	Declare @numWorkingDays_Daily	Numeric(12,1)
	declare @numAbsentDays_Daily	Numeric(12,1)
	Declare @Sal_cal_Days			Numeric(18,4)
	Declare @Absent_Days			Numeric(12,1)
--	Declare @Holiday_Days			Numeric(12,1)
--	Declare @Weekoff_Days			Numeric(12,1)
--	Declare @Cancel_Holiday			Numeric(12,1)
--	Declare @Cancel_Weekoff			Numeric(12,1)
	Declare @Working_days			Numeric(12,1)
	declare @OutOf_Days				Numeric        
	Declare @Total_leave_Days		Numeric(12,1)
	Declare @Paid_leave_Days		Numeric(12,1)
	
	Declare @Actual_Working_Hours	varchar(20)
	Declare @Working_Hours			varchar(20)
	Declare @Outof_Hours			varchar(20)
	Declare @Total_Hours			varchar(20)
	Declare @Shift_Day_Sec			Numeric
	Declare @Shift_Day_Hour			varchar(20)
	Declare @Basic_Salary			Numeric(25,2)
	Declare @Gross_Salary			Numeric(25,2)
	Declare @Actual_Gross_Salary	Numeric(25,2)
	Declare @Gross_Salary_ProRata	numeric(25,2)
	Declare @Day_Salary				Numeric(12,5)
	Declare @Hour_Salary			Numeric(12,5)
	Declare @Salary_amount			Numeric(18,5) -- changes done by deepal as per solved issue in wonder
	Declare @Allow_Amount			Numeric(18,4)
	Declare @OT_Amount				Numeric(18,4)
	Declare @Other_allow_Amount		Numeric(18,4)
	Declare @Dedu_Amount			Numeric(18,4)
	Declare @Loan_Amount			Numeric(18,4)
	Declare @Loan_Intrest_Amount	Numeric(18,4)
	Declare @Advance_Amount			Numeric(18,4)
	Declare @Other_Dedu_Amount		Numeric(18,4)
	Declare @Total_Dedu_Amount		Numeric(18,4)
	Declare @Due_Loan_Amount		Numeric(18,4)
	Declare @Net_Amount				Numeric(18,4)
	Declare @Final_Amount			Numeric(18,4)
	Declare @Hour_Salary_OT			Numeric(18,4)
	Declare @ExOTSetting			Numeric(5,2)
	--Declare @Inc_Weekoff			char(1)
	Declare @Inc_Weekoff			Numeric
	Declare @Late_Adj_Day			Numeric(5,2)
	Declare @OT_Min_Limit			varchar(20)
	Declare @OT_Max_Limit			varchar(20)
	Declare @OT_Min_Sec				Numeric
	Declare @OT_Max_Sec				Numeric
	Declare @Is_OT_Inc_Salary		Float
	Declare @Is_Daily_OT			char(1)
	Declare @Fix_Shift_Hours		varchar(20)
	Declare @Fix_OT_Work_Days		Numeric(18,4)
	Declare @Round					Numeric
	declare @Restrict_Present_Days	char(1)
	Declare @Is_Cancel_Holiday		numeric(1,0)
	Declare @Is_Cancel_Weekoff		numeric(1,0)
	Declare @Join_Date				Datetime
	Declare @Left_Date				Datetime	
--	Declare @StrHoliday_Date		varchar(1000)
--	Declare @StrWeekoff_Date		varchar(1000)
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
	Declare @Modify_date			Datetime
	Declare @Lv_Encash_W_Day		Numeric(18,4)
	Declare @Wages_Amount			numeric(18,0)
	Declare @IS_Rounding			TinyInt 
	Declare @upto_date				datetime
	Declare @upto_Basic_Salary	numeric(25,2)
	Declare @upto_Gross_Salary	numeric(25,2)
	Declare @Allow_Effect_on_Leave Numeric(25,2) --Hardik 01/05/2012
	Declare @Increment_Id_New Numeric --Hardik 01/05/2012
	Declare @Encashment_Rate Numeric(18,2) -- Rohit on 18112014
	Declare @Type_Id Numeric
	
	declare @chk_lv_on_working tinyint -- rohit on 25112014
	Declare @Lv_Encash_Cal_On varchar(50) --Sumit 13052015
	set @chk_lv_on_working = 0
	
	Declare @Gross_Salary_ProRata_New	numeric(25,2)
	set @Gross_Salary_ProRata_New	= 0
	
	set @Type_Id = 0
	set @Encashment_Rate = 1
	set @upto_Basic_Salary	= 0 
	set @upto_Gross_Salary	= 0 
	Set @Allow_Effect_on_Leave = 0
	set @OutOf_Days = datediff(d,@L_Month_St_Date,@L_Month_End_Date) + 1
	
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
	--Set @Holiday_Days	 = 0
	--Set @Weekoff_Days	 = 0
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
	--set @Inc_Weekoff = 'Y'
	set @Inc_Weekoff = 1	--Ankit 10032014
	set @Late_Adj_Day = 0
	set @ExOTSetting			= 0
	set @OT_Min_Limit			=''
	set @OT_Max_Limit			= ''
	set @Is_OT_Inc_Salary		= 0
	set @Is_Daily_OT			= 'N'
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
	set @Emp_OT_Sec = 0
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
	set @Lv_Encash_W_Day = 0
	set @Modify_date = getdate()
	set @IS_Rounding = 0
	
	
	set @Wages_Amount =0
    SET @Lv_Encash_Cal_On = '' --Added by Sumit 13052015
  
  --  Declare @Effective  as DateTime

	select @Increment_ID = I.Increment_ID ,@Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On
			,@Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode ,
			 @Actual_Gross_Salary = Gross_Salary ,@Basic_Salary =Basic_Salary,
			 @Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit,
			 @Branch_ID = Branch_ID,
			 @Is_Emp_PT =isnull(Emp_PT,0)
			 ,@Type_Id = type_id -- Rohit on 18112014
			from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @L_Month_End_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
		Where I.Emp_ID = @Emp_ID
			
	
		
	If @L_Sal_Tran_ID > 0 
		Begin

				Delete from dbo.T0210_MONTHLY_AD_DETAIL				Where emp_id = @emp_id	and L_Sal_Tran_ID = @L_Sal_Tran_ID 
				Delete from dbo.T0210_MONTHLY_LOAN_PAYMENT			Where L_Sal_Tran_ID = @L_Sal_Tran_ID
				Select @Sal_Receipt_No =  L_Sal_Receipt_No from dbo.T0200_MONTHLY_SALARY_LEAVE WITH (NOLOCK) Where L_Sal_Tran_ID =@L_Sal_Tran_ID
				Delete from dbo.T0200_MONTHLY_SALARY_LEAVE where  sal_tran_ID=@SAL_TRAN_ID 
				
		End		
	Else
		Begin

			Select @L_Sal_Tran_ID =  Isnull(max(L_Sal_Tran_ID),0)  + 1   from dbo.T0200_MONTHLY_SALARY_LEAVE WITH (NOLOCK)
			Select @Sal_Receipt_No =  isnull(max(L_sal_Receipt_No),0)  + 1  from dbo.T0200_MONTHLY_SALARY_LEAVE WITH (NOLOCK) Where Month(L_Month_St_Date) = Month(@L_Month_St_Date) 
							and YEar(L_Month_St_Date) = Year(@L_Month_End_Date) and Cmp_ID= @Cmp_ID
							
				
		
			INSERT INTO T0200_MONTHLY_SALARY_LEAVE
			                      (L_Sal_Tran_ID, L_Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, L_Month_St_Date, L_Month_End_Date, L_Sal_Generate_Date, L_Sal_Cal_Days, 
			                      L_Working_Days, L_Outof_Days, L_Shift_Day_Sec, L_Shift_Day_Hour, L_Basic_Salary, L_Day_Salary, L_Hour_Salary, L_Salary_Amount, 
			                      L_Allow_Amount, L_Other_Allow_Amount, L_Gross_Salary, L_Dedu_Amount, L_Loan_Amount, L_Loan_Intrest_Amount, L_Advance_Amount, 
			                      L_Other_Dedu_Amount, L_Total_Dedu_Amount, L_Due_Loan_Amount, L_Net_Amount, L_Actually_Gross_Salary, L_PT_Amount, 
			                      L_PT_Calculated_Amount, L_M_Adv_Amount, L_M_Loan_Amount, L_M_IT_Tax, L_LWF_Amount, L_Revenue_Amount, L_PT_F_T_Limit, L_Sal_Type, 
			                      L_Eff_Date, Login_ID, Modify_Date,IS_FNF,SAL_TRAN_ID)
			VALUES     (@L_Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@L_Month_St_Date,@L_Month_End_Date,@L_Sal_Generate_Date,0,0,0,0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',@L_Sal_Type,@L_Eff_Date,@Login_ID,@Modify_Date,@Is_FNF,@SAL_TRAN_ID)
		
		--Select * from 	 T0200_MONTHLY_SALARY_LEAVE
		End
		
		
	
	select @ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff,@Late_Adj_Day = isnull(Late_Adj_Day,0)
		,@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = Isnull(OT_Max_Limit,'00:00')
		,@Is_OT_Inc_Salary = isnull(OT_Inc_Salary,0) 
		,@Is_Daily_OT = Is_Daily_OT 
		,@Is_Cancel_Holiday = Is_Cancel_Holiday
		,@Is_Cancel_Weekoff = Is_Cancel_Weekoff
		,@Fix_Shift_Hours = ot_Fix_Shift_Hours
		,@Fix_OT_Work_Days = isnull(OT_fiX_Work_Day,0)
		,@Is_PT = isnull(Is_PT,0)
		,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month
		,@Revenue_amount = Revenue_amount , @Revenue_on_Amount =Revenue_on_Amount
		,@Lv_Encash_W_Day = isnull(Lv_Encash_W_Day,0),@IS_ROUNDING = ISNULL(AD_Rounding,0)
		,@chk_lv_on_working = ISNULL(chk_lv_on_working,0) -- rohit on 25112014
		,@Lv_Encash_Cal_On=ISNULL(Lv_Encash_Cal_On,'') --Added by Sumit 13052015
		from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
		and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@L_Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
		 
	
					
--	Exec P0210_MONTHLY_LEAVE_INSERT @Cmp_ID ,@Emp_ID,@L_Month_St_Date,@L_Month_End_Date,@L_Sal_Tran_ID
	Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_Id,@Cmp_ID,@L_Month_End_Date,null,null,@Shift_Day_Hour output
	
	--Commented by Hardik 07/09/2012 it is passed from Parameter
	--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@L_Month_St_Date,@L_Month_End_Date,@Join_Date,@Left_date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID
	--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@L_Month_St_Date,@L_Month_End_Date,@Join_Date,@Left_date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,1

	
	select @Shift_Day_Sec = dbo.F_Return_Sec(@Shift_Day_Hour)
	select @Emp_OT_Min_Sec = dbo.F_Return_Sec(@Emp_OT_Min_Limit)
	select @Emp_OT_Max_Sec = dbo.F_Return_Sec(@Emp_OT_Max_Limit)
	
	
	--if @Inc_Weekoff <> 'Y'	
	
	if @Inc_Weekoff <> 1	--Ankit 10032014
		Set @Working_Days = @Outof_Days - @WeekOff_Days 
	else
		Set @Working_Days = @Outof_Days 
	
	
		Declare  @leave_temp table
			(
			leave_Id numeric(18,0),
			Leave_Encase_Day numeric(18,4)
			)
	
						
--	if @Present_Days > @Working_Days and @Restrict_Present_Days = 'Y'
--		begin
--			set @Present_Days = @Working_Days
--		end
--	If @Inc_Weekoff = 'Y'
--		set @Sal_cal_Days = @Present_Days + @Holiday_Days + @Weekoff_Days + @Paid_Leave_Days
--	Else
--		set @Sal_cal_Days = @Present_Days + @Holiday_Days + @Paid_Leave_Days


--	IF @Sal_cal_Days > @Working_Days and @Restrict_Present_Days = 'Y'
--		SET @Sal_cal_Days = @Working_Days 

-- Added by rohit For Add allowance which effect to leave encash  and commenet code of Allowance add on 07012015
	Create table #Tbl_Get_AD
			(
				Emp_ID numeric(18,0),
				Ad_ID numeric(18,0),
				for_date datetime,
				E_Ad_Percentage numeric(18,5),
				M_Ad_Amount numeric(18,2)
				
			)
			
			Select @upto_date= max(Upto_Date) from dbo.T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) 
			where Emp_Id =@emp_ID and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date 
				and lv_Encash_apr_Status ='A' and isnull(eff_in_salary,0)=1			
									
			declare @Temp_Date as datetime
			set @Temp_Date = Isnull(@upto_date,@L_Month_End_Date)

			INSERT INTO #Tbl_Get_AD
				Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@Temp_Date,@Emp_Id
		
				
			Select @Allow_Effect_on_Leave = SUM(M_Ad_Amount) from #Tbl_Get_AD EED 
				Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID 
			Where EED.EMP_ID = @Emp_Id And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1		
		
			
-- ended by rohit For Add allowance which effect to leave encash on 07012015

	if isnull(@Is_FNF,0)=0
		Begin
			Select @Present_Days = isnull(sum(LV_encash_apr_Days),0) from dbo.T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) where Emp_Id =@emp_ID and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and isnull(eff_in_salary,0)=1
			
			-- Changed by Gadriwala Muslim 01012015 - Start
			Select @Present_Days = isnull(sum(case when lm.Apply_Hourly =1 and isnull(lm.Default_Short_Name,'') = 'COMP' then  FLOOR(CAST(LV_encash_apr_Days AS FLOAT)/CAST(8 AS FLOAT)*16)/16 else LV_encash_apr_Days end) ,0) 
			from dbo.T0120_LEAVE_ENCASH_APPROVAL LEA WITH (NOLOCK) inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on  LEA.Leave_ID = lm.Leave_ID 
			where Emp_Id =@emp_ID and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and isnull(eff_in_salary,0)=1
			-- Changed by Gadriwala Muslim 01012015 - End
			
			insert into @leave_temp
			Select lm.Leave_ID,isnull(sum(case when lm.Apply_Hourly =1 and isnull(lm.Default_Short_Name,'') = 'COMP' then  FLOOR(CAST(LV_encash_apr_Days AS FLOAT)/CAST(8 AS FLOAT)*16)/16 else LV_encash_apr_Days end) ,0) 
			from dbo.T0120_LEAVE_ENCASH_APPROVAL LEA WITH (NOLOCK) inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on  LEA.Leave_ID = lm.Leave_ID 
			where Emp_Id =@emp_ID and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and isnull(eff_in_salary,0)=1
									group by lm.Leave_ID 
							
										
			Select @upto_date= max(Upto_Date) from dbo.T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) where Emp_Id =@emp_ID and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and isnull(eff_in_salary,0)=1									
			

	--		select @upto_Basic_Salary = Basic_Salary , @upto_Gross_Salary = Actually_Gross_Salary from dbo.T0200_MONTHLY_SALARY where Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID and Sal_Tran_ID = (select top 1 Sal_Tran_ID from dbo.T0200_MONTHLY_SALARY where Emp_ID = @Emp_Id and Month_End_Date <= @upto_date and Cmp_ID = @Cmp_ID order by sal_tran_id  desc)
			select @upto_Basic_Salary = Isnull(Basic_Salary,0),@upto_Gross_Salary = Gross_Salary,@Increment_Id_New = I.Increment_ID
				from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
						where Increment_Effective_date <= Isnull(@upto_date,@L_Month_End_Date)
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
				Where I.Emp_ID = @Emp_ID
			
			--Commeneted by rohit add code befor if condition on 07012016
			--Select @Allow_Effect_on_Leave = SUM(E_AD_AMOUNT) from dbo.T0100_EMP_EARN_DEDUCTION EED 
			--	Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
			--Where INCREMENT_ID = @Increment_Id_New And EMP_ID = @Emp_Id And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1
			
--			Select @Allow_Effect_on_Leave = SUM(Qry1.E_AD_AMOUNT) from
--(
--select Case When Qry1.E_AD_AMOUNT IS null Then eed.E_AD_AMOUNT Else Qry1.E_AD_AMOUNT End As E_AD_AMOUNT
--from dbo.T0100_EMP_EARN_DEDUCTION EED 
--				Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
--				LEFT OUTER JOIN
--				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
--					From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
--					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
--						Where Emp_Id = @Emp_Id
--						And For_date <= Isnull(@upto_date,@L_Month_End_Date)
--					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
--				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
--			Where INCREMENT_ID = @Increment_Id_New And EED.EMP_ID = @Emp_Id And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1
--			And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'

--UNION ALL			

--SELECT E_Ad_Amount
--		FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
--			( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
--				Where Emp_Id  = @Emp_Id And For_date <= Isnull(@upto_date,@L_Month_End_Date) 
--				Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
--		   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
--		WHERE emp_id = @emp_id 
--				And Adm.AD_ACTIVE = 1
--				And EEd.ENTRY_TYPE = 'A'
--				And Isnull(ADM.AD_EFFECT_ON_LEAVE,0) = 1
--				) Qry1

			
			
		End
	else
		Begin

			Declare @sal_St_Date  datetime
			Declare @Sal_End_Date Datetime

			set @sal_St_Date =''
			set @Sal_End_Date=''
			set @Left_Date=''

			--Rohit on 26062013
			select @Left_Date = isnull(Emp_Left_Date,'') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
			

			if isnull(@Left_Date,'') <> ''
				Begin 
				 
					if isnull(@Sal_St_Date,'') = ''    
						begin    
						
							set @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Left_Date),year(@Left_Date))    
							set @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Left_Date),year(@Left_Date))
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
							
						end     
					else if day(@Sal_St_Date) = 1 --and month(@Sal_St_Date)= 1    
						begin    
						
							set @Sal_St_Date  = dbo.GET_MONTH_ST_DATE (MONTH(@Left_Date),year(@Left_Date))    
							set @Sal_End_Date = dbo.GET_MONTH_End_DATE (MONTH(@Left_Date),year(@Left_Date))
							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1  
							
						end     
					else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						begin    
						
							set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Left_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Left_Date) )as varchar(10)) as smalldatetime)    
							set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			
							if @Sal_End_Date>=@Left_Date
								begin 
									set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
								end
					else
						begin
						
							set @Sal_St_Date = dateadd(mm,1,@Sal_St_Date)
							set @Sal_End_Date = dateadd(mm,1,@Sal_End_Date)

							set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
						end
			end
			END 
			
			---- Changed by Gadriwala Muslim 01012015 - Start	
			Select @Present_Days = isnull(sum(case when lm.Apply_Hourly =1 and isnull(lm.Default_Short_Name,'') = 'COMP' then  (LV_encash_apr_Days * 0.125) else LV_encash_apr_Days end) ,0) 
			from dbo.T0120_LEAVE_ENCASH_APPROVAL LEA WITH (NOLOCK) inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on  LEA.Leave_ID = lm.Leave_ID 
			where Emp_Id =@emp_ID and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and Is_FNF=1
			-- Changed by Gadriwala Muslim 01012015 - End							
			Select @Present_Days = isnull(sum(LV_encash_apr_Days),0) from dbo.T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) where Emp_Id =@emp_ID --and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and Is_FNF=1
			
				insert into @leave_temp
			Select LM.leave_id,isnull(sum(case when lm.Apply_Hourly =1 and isnull(lm.Default_Short_Name,'') = 'COMP' then  (LV_encash_apr_Days * 0.125) else LV_encash_apr_Days end) ,0) 
			from dbo.T0120_LEAVE_ENCASH_APPROVAL LEA WITH (NOLOCK) inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on  LEA.Leave_ID = lm.Leave_ID 
			where Emp_Id =@emp_ID --and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A' and Is_FNF=1	
									group by Lm.Leave_Id

			
									
			Select  @upto_date= max(Upto_Date) from dbo.T0120_LEAVE_ENCASH_APPROVAL WITH (NOLOCK) where Emp_Id =@emp_ID --and Lv_Encash_Apr_Date >=@L_Month_St_Date and LV_Encash_Apr_Date <=@L_Month_End_Date
									and lv_Encash_apr_Status ='A'  and Is_FNF=1

				
			
	--		select @upto_Basic_Salary = Basic_Salary , @upto_Gross_Salary = Actually_Gross_Salary from dbo.T0200_MONTHLY_SALARY where Emp_ID = @Emp_Id and Cmp_ID = @Cmp_ID and Sal_Tran_ID = (select top 1 Sal_Tran_ID from dbo.T0200_MONTHLY_SALARY where Emp_ID = @Emp_Id and Month_End_Date <= @upto_date and Cmp_ID = @Cmp_ID  order by sal_tran_id  desc)
			select @upto_Basic_Salary = Isnull(Basic_Salary,0),@upto_Gross_Salary = Gross_Salary,@Increment_Id_New = I.Increment_ID
				from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
						where Increment_Effective_date <= Isnull(@upto_date,@L_Month_End_Date)
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
				Where I.Emp_ID = @Emp_ID
					
			--Commeneted by rohit add code befor if condition on 07012016										
			--Select @Allow_Effect_on_Leave = SUM(E_AD_AMOUNT) from dbo.T0100_EMP_EARN_DEDUCTION EED 
			--	Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
			--Where INCREMENT_ID = @Increment_Id_New And EMP_ID = @Emp_Id And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1
			
--			Select @Allow_Effect_on_Leave = SUM(Qry1.E_AD_AMOUNT) from
--(
--select Case When Qry1.E_AD_AMOUNT IS null Then eed.E_AD_AMOUNT Else Qry1.E_AD_AMOUNT End As E_AD_AMOUNT
--from dbo.T0100_EMP_EARN_DEDUCTION EED 
--				Inner Join T0050_AD_MASTER AM on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID 
--				LEFT OUTER JOIN
--				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE 
--					From T0110_EMP_Earn_Deduction_Revised EEDR INNER JOIN
--					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
--						Where Emp_Id = @Emp_Id
--						And For_date <= Isnull(@upto_date,@L_Month_End_Date)
--					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
--				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                  
--			Where INCREMENT_ID = @Increment_Id_New And EED.EMP_ID = @Emp_Id And Isnull(AM.AD_EFFECT_ON_LEAVE,0) = 1
--			And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'

--UNION ALL			

--SELECT E_Ad_Amount
--		FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED INNER JOIN  
--			( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised 
--				Where Emp_Id  = @Emp_Id And For_date <= Isnull(@upto_date,@L_Month_End_Date) 
--				Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
--		   INNER JOIN dbo.T0050_AD_MASTER ADM  ON EEd.AD_ID = ADM.AD_ID                     
--		WHERE emp_id = @emp_id 
--				And Adm.AD_ACTIVE = 1
--				And EEd.ENTRY_TYPE = 'A'
--				And Isnull(ADM.AD_EFFECT_ON_LEAVE,0) = 1
--				) Qry1

				
			
		End	
	
		Set @upto_Basic_Salary = @upto_Basic_Salary + isnull(@Allow_Effect_on_Leave,0)
		Set @Basic_Salary = @Basic_Salary + isnull(@Allow_Effect_on_Leave,0)

					
		 Set @Sal_cal_Days = @Present_Days 

	--if @Sal_cal_Days =0
	--	begin
	--		Delete from dbo.T0200_MONTHLY_SALARY_LEAVE Where L_Sal_Tran_ID=@L_Sal_Tran_ID
	--		set @L_Sal_Tran_ID =0
	--		return 
	--	end
	
	
	--if  isnull(@upto_Basic_Salary,0) <= 0  and isnull(@upto_Gross_Salary,0) <= 0
	--	BEGIN
	
	--		If @Wages_Type = 'Monthly' 
	--			if @Lv_Encash_W_Day > 0 
	--				begin					
	--					set @Day_Salary = 	@Basic_Salary / @Lv_Encash_W_Day
	--					set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Lv_Encash_W_Day
	--				end
	--			else if @chk_lv_on_working = 1
	--				begin										
	--					set @Day_Salary = 	@Basic_Salary / (@Outof_Days - @Weekoff_Days -@Holiday_Days)
	--					set @Gross_Salary_ProRata = @Actual_Gross_Salary/(@Outof_Days - @Weekoff_Days - @Holiday_Days) -- rohit on 25112014
	--				end 
	--			else if @Inc_Weekoff = 1
	--				begin										
	--					set @Day_Salary = 	@Basic_Salary / @Outof_Days 
	--					set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days						
	--				end 
	--			else
	--				begin					
	--					set @Day_Salary = 	@Basic_Salary / @Working_Days
	--					set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days
	--				end 
	--		Else
	--			Begin				
	--				set @Day_Salary = 	@Basic_Salary
	--			End
		
	--	END
	--ELSE
	--	BEGIN
			
	--		If @Wages_Type = 'Monthly' 
	--			if @Lv_Encash_W_Day > 0 
	--				begin
	--					set @Day_Salary = 	@upto_Basic_Salary / @Lv_Encash_W_Day
	--					set @Gross_Salary_ProRata = @upto_Gross_Salary/@Lv_Encash_W_Day
						
	--				end
	--			else if @chk_lv_on_working = 1
	--				begin										
	--					set @Day_Salary = 	@Basic_Salary / (@Outof_Days - @Weekoff_Days -@Holiday_Days)
	--					set @Gross_Salary_ProRata = @Actual_Gross_Salary/(@Outof_Days - @Weekoff_Days - @Holiday_Days) -- rohit on 25112014
	--				end 
	--			else if @Inc_Weekoff = 1
	--				begin
					
	--					set @Day_Salary = 	@upto_Basic_Salary / @Outof_Days 
	--					set @Gross_Salary_ProRata = @upto_Gross_Salary/@Outof_Days
	--				end 
	--			else
	--				begin
	--					set @Day_Salary = 	@upto_Basic_Salary / @Working_Days
	--					set @Gross_Salary_ProRata = @upto_Gross_Salary/@Working_Days
					
	--				end 
	--		Else
	--			Begin
	--				set @Day_Salary = 	@upto_Basic_Salary
	--			End
				
	--	END
	
	
	
	--Set @Hour_Salary	= @Day_Salary * 3600	/  @Shift_Day_Sec	 
	--Set	@Hour_Salary_OT = @Day_Salary * 3600    /  @Shift_Day_Sec 
	
	--select @Encashment_Rate = isnull(Encashment_Rate,1)  from T0040_TYPE_MASTER where TYPE_ID=@Type_Id  -- Rohit on 18112014
	
	--Set @Salary_Amount  = Round(@Day_Salary * @Encashment_Rate * @Sal_Cal_Days,@Round)
	
	--set @Gross_Salary_ProRata = Round(@Gross_Salary_ProRata* @Encashment_Rate * @Sal_Cal_Days,@Round)
	
	declare @curLeave_id numeric
declare @CurLeave_Encase_Day numeric(18,4)
declare @CurLv_Encase_Calculation_Day numeric(18,2)
Declare @Temp_Lv_Encash_W_Day As Numeric(18,2)
declare @cur_Salary_Amount as numeric(18,2)


Declare CusrCompanyMST cursor for	                  
select LT.leave_id , isnull(LT.Leave_Encase_Day,0),isnull(Lm.Lv_Encase_Calculation_Day,0) from @leave_temp LT inner join t0040_leave_master LM WITH (NOLOCK) on LT.leave_id = LM.Leave_id where LT.Leave_Encase_Day <> 0 --where LT.Leave_Encase_Day > 0 -- Comment by nilesh for consider advance Leave 
Open CusrCompanyMST
Fetch next from CusrCompanyMST into @curLeave_id,@CurLeave_Encase_Day,@CurLv_Encase_Calculation_Day
While @@fetch_status = 0                    
	Begin     

if @CurLv_Encase_Calculation_Day > 0
begin 
	set @Temp_Lv_Encash_W_Day = @CurLv_Encase_Calculation_Day 
end
else
begin
	set @Temp_Lv_Encash_W_Day = @Lv_Encash_W_Day 
end
	
	if  isnull(@upto_Basic_Salary,0) <= 0  and isnull(@upto_Gross_Salary,0) <= 0
		BEGIN
	
			If @Wages_Type = 'Monthly' 
				if @Temp_Lv_Encash_W_Day > 0 
					begin					
						set @Day_Salary = 	@Basic_Salary / @Temp_Lv_Encash_W_Day
						set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Temp_Lv_Encash_W_Day
					end
				else if @chk_lv_on_working = 1
					begin		
												
						set @Day_Salary = 	@Basic_Salary / (@Outof_Days - @Weekoff_Days -@Holiday_Days)
						set @Gross_Salary_ProRata = @Actual_Gross_Salary/(@Outof_Days - @Weekoff_Days - @Holiday_Days) -- rohit on 25112014
					end 
				else if @Inc_Weekoff = 1
					begin										
						set @Day_Salary = 	@Basic_Salary / @Outof_Days 
						set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days						
					end 
				else
				begin
									
						set @Day_Salary = 	@Basic_Salary / @Working_Days
						set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Working_Days
					end 
			Else
				Begin		
				
					set @Day_Salary = 	@Basic_Salary
				End
		
		END
	ELSE
		BEGIN
			
			If @Wages_Type = 'Monthly' 
				if @Temp_Lv_Encash_W_Day > 0 
					begin
						
						set @Day_Salary = 	@upto_Basic_Salary / @Temp_Lv_Encash_W_Day
						set @Gross_Salary_ProRata = @upto_Gross_Salary/@Temp_Lv_Encash_W_Day
						
					end
				else if @chk_lv_on_working = 1
					begin		
													
						set @Day_Salary = 	@Basic_Salary / (@Outof_Days - @Weekoff_Days -@Holiday_Days)
						set @Gross_Salary_ProRata = @Actual_Gross_Salary/(@Outof_Days - @Weekoff_Days - @Holiday_Days) -- rohit on 25112014
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
				
		END
	
	
	
	Set @Hour_Salary	= @Day_Salary * 3600	/  @Shift_Day_Sec	 
	Set	@Hour_Salary_OT = @Day_Salary * 3600    /  @Shift_Day_Sec 
	
	select @Encashment_Rate = isnull(Encashment_Rate,1)  from T0040_TYPE_MASTER WITH (NOLOCK) where TYPE_ID=@Type_Id  -- Rohit on 18112014
	
	-- Ankit 27022016 -- For Half Encash Day Payment
	IF EXISTS ( SELECT 1 FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE Cmp_ID =  @cmp_id and Leave_ID = @curLeave_id and ISNULL(Leave_EncashDay_Half_Payment,0) = 1 ) And @CurLeave_Encase_Day >0
		BEGIN
			SET @Day_Salary = @Day_Salary / 2
		END
	
	--select @Salary_Amount,@Day_Salary,@Encashment_Rate,@CurLeave_Encase_Day
	
	Set @cur_Salary_Amount =  Round(@Day_Salary * @Encashment_Rate * @CurLeave_Encase_Day,@Round)
	Set @Salary_Amount  = @Salary_Amount + Round(@Day_Salary * @Encashment_Rate * @CurLeave_Encase_Day,@Round)
	--select @Salary_Amount
	set @Gross_Salary_ProRata_New = @Gross_Salary_ProRata_New + Round(@Gross_Salary_ProRata* @Encashment_Rate * @CurLeave_Encase_Day,@Round)
	
	
	-----------------Added by Sumit for getting Leave Encashment Amount 13052015----------------------------------------------------------
	insert into t0200_salary_leave_Encashment(Leave_ID,Sal_Tran_ID,L_Day_Salary,Encashment_Rate,Encashment_Days,Encashment_Amount,L_Cal_Encash_Days,Month_St_Date,Month_End_Date,Emp_ID,Cmp_ID,Lv_Encash_cal_on,Cal_Amount)
										values(@curLeave_id,isnull(@SAL_TRAN_ID,0),@Day_Salary,@Encashment_Rate,@CurLeave_Encase_Day,@cur_Salary_Amount,@Temp_Lv_Encash_W_Day,@L_Month_St_Date,@L_Month_End_Date,@Emp_Id,@Cmp_ID,@Lv_Encash_Cal_On,@Basic_Salary)
	
	-----------------Ended by Sumit---------------------------------------------------------------------------------
	
	
	fetch next from CusrCompanyMST  into @curLeave_id,@CurLeave_Encase_Day,@CurLv_Encase_Calculation_Day
	end
close CusrCompanyMST                    
deallocate CusrCompanyMST	
	
	--select @Salary_Amount,@Day_Salary,@Encashment_Rate
					--print @Sal_St_Date
					--print @Sal_End_Date
					--print @OutOf_Days
					--print @Present_Days
					--print @upto_date
					--print @upto_Basic_Salary
					--print @upto_Gross_Salary
					--print @Allow_Effect_on_Leave
					--print @Day_Salary
					--print @Gross_Salary_ProRata
					--print @Working_Days
	--IF @EMP_OT = 1
	--	Begin
	--		If @Emp_OT_Sec > 0  and @Emp_OT_Min_Sec > 0 and @Emp_OT_Sec < @Emp_OT_Min_Sec
	--			set @Emp_OT_Sec = 0
	--		Else If @Emp_OT_Sec > 0 and @Emp_OT_Max_Sec > 0 and @Emp_OT_Sec > @Emp_OT_Max_Sec
	--			set @Emp_OT_Sec = @Emp_OT_Max_Sec
				
	--		If @Emp_OT_Sec > 0
	--			set @OT_Amount = round((@Emp_OT_Sec/3600) * @Hour_Salary_OT,0)
				
	--		If @ExOTSetting > 0 and @OT_Amount > 0
	--			set @OT_Amount = @OT_Amount + @OT_Amount * @ExOTSetting 
			
			
				
	--		select @Emp_OT_Hours = dbo.F_Return_Hours(@Emp_OT_Sec)
	--	End
	--else
	--	Begin
	--		set @Emp_OT_Sec = 0
	--		set @OT_Amount = 0
	--		set @Emp_OT_Hours = '00:00'
			
	--	End
	
	
	-- commented by mitesh on 28/12/2011
	--EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION @L_Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@L_Month_St_Date,@L_Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@numAbsentDays,@Paid_leave_Days,@Sal_Cal_Days,@Working_Days,@OT_Amount,@Day_Salary ,@Branch_ID,@M_IT_Tax,Null,0,1,0,0,@IS_ROUNDING
	
	SELECT @Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			WHERE L_Sal_Tran_ID = @L_Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'
				and AD_ID not in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and  isnull(AD_Not_effect_salary,0) = 1) 
																	
	SELECT @Dedu_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
			WHERE L_Sal_Tran_ID = @L_Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D'
				and AD_ID not in (select AD_ID from dbo.T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and  isnull(AD_Not_effect_salary,0) = 1) 
				
				
				
	set @Dedu_Amount = isnull(@Dedu_Amount,0)
	set @Allow_Amount = isnull(@Allow_Amount,0)
	
		
	/*Select @Advance_Amount =  round( isnull(Adv_closing,0),0) from dbo.T0140_Advance_Transaction where emp_id = @emp_id and Cmp_ID = @Cmp_ID
	and for_date = (select max(for_date) from  T0140_Advance_Transaction where emp_id = @emp_id and Cmp_ID = @Cmp_ID
		and for_date <=  @L_Month_End_Date)
	
	set @Advance_Amount = isnull(@Advance_Amount,0)  +  @Update_Adv_Amount
	
	
	
	exec SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@L_Month_End_Date,@L_Sal_Tran_ID,0,@IS_LOAN_DEDU
	
	
	Select @Loan_Amount = Isnull(sum(Loan_Pay_Amount),0) from dbo.T0210_Monthly_Loan_Payment where L_Sal_Tran_ID = @L_Sal_Tran_ID
	
	set @Due_Loan_Amount = 0
	
	 SELECT @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) from dbo.T0140_LOAN_TRANSACTION  LT INNER JOIN 
	( SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID from dbo.T0140_LOAN_TRANSACTION  WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID
	AND FOR_DATE <=@L_Month_End_Date
	GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID
	AND QRY.FOR_DATE = LT.FOR_DATE 
	AND QRY.EMP_ID = LT.EMP_ID
			
	*/
	
	
	Set @Gross_Salary = isnull(@Salary_Amount,0) + isnull(@Allow_Amount,0) + isnull(@Other_Allow_Amount,0) + isnull(@Total_Claim_Amount ,0) 

--	If @Is_Emp_PT =1 and @Is_PT = 1 
--		begin
--			set  @PT_Calculated_Amount = @Gross_Salary
--			exec SP_CALCULATE_PT_AMOUNT @CMP_ID,@EMP_ID,@L_Month_End_Date,@PT_Calculated_Amount,@PT_AMOUNT OUTPUT,@PT_F_T_LIMIT output,@Branch_ID
--		end
	
	
	-- commented by hasmukh on 28/12/2011
	
	--if   @Gross_Salary < @Revenue_on_Amount  and @Revenue_on_Amount> 0  
	--	set @Revenue_Amount = 0
	
	--set @LWF_compare_month = '#'+ cast(Month(@L_Month_St_Date)as varchar(2)) + '#'
	
	
	--if charindex(@LWF_compare_month,@LWF_App_Month,1) = 0 or @LWF_App_Month =''
	--	begin
	--		set @LWF_Amount = 0
	--	end		



	Set @Total_Dedu_Amount = isnull(@Dedu_Amount,0) + isnull(@Other_Dedu_Amount,0) + isnull(@Advance_Amount,0) + isnull(@Loan_Amount,0)  + isnull(@PT_Amount,0)
	

	
	Set @Net_Amount = isnull(@Gross_Salary,0) - isnull(@Total_Dedu_Amount,0)
	
	
	--select @Salary_Amount as Basic_L,@Gross_Salary as Gross_L,@Net_Amount as Net_L
	
	UPDATE  T0200_MONTHLY_SALARY_LEAVE
	SET		Increment_ID = @Increment_ID, 
			L_Month_St_Date = @L_Month_St_Date, L_Month_End_Date = @L_Month_End_Date, L_Sal_Generate_Date = @L_Sal_Generate_Date, 
			L_Sal_Cal_Days = @Sal_cal_Days, L_Working_Days = @Working_Days, 
			L_Outof_Days = @Outof_Days,L_Shift_Day_Sec = @Shift_Day_Sec, L_Shift_Day_Hour = @Shift_Day_Hour, L_Basic_Salary = isnull(@Basic_Salary,0), 
			L_Day_Salary = @Day_Salary, L_Hour_Salary = @Hour_Salary, L_Salary_Amount = @Salary_Amount, L_Allow_Amount = @Allow_Amount, 
			L_Other_Allow_Amount = @Other_Allow_Amount, L_Gross_Salary = @Gross_Salary, L_Dedu_Amount = @Dedu_Amount, 
			L_Loan_Amount = @Loan_Amount, L_Loan_Intrest_Amount = @Loan_Intrest_Amount, L_Advance_Amount = @Advance_Amount, 
			L_Other_Dedu_Amount = @Other_Dedu_Amount, L_Total_Dedu_Amount = @Total_Dedu_Amount, L_Due_Loan_Amount = @Due_Loan_Amount, 
			L_Net_Amount = @Net_Amount ,L_PT_Amount = @PT_Amount,L_PT_Calculated_Amount = @PT_Calculated_Amount
			,L_M_IT_Tax = @M_IT_Tax , L_M_Loan_Amount = @M_Loan_Amount ,L_M_Adv_Amount = @M_Adv_Amount
			,L_LWF_Amount = @LWF_Amount , L_Revenue_Amount = @Revenue_Amount ,L_PT_F_T_LIMIT = @PT_F_T_LIMIT
			,L_Actually_Gross_Salary = @Gross_Salary_ProRata_New
	WHERE L_Sal_Tran_ID =@L_Sal_Tran_ID AND EMP_ID = @EMP_ID

	RETURN



