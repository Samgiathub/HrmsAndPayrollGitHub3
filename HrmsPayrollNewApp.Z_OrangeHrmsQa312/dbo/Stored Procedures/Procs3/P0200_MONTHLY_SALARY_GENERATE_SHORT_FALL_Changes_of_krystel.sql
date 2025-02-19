
Create PROCEDURE [dbo].[P0200_MONTHLY_SALARY_GENERATE_SHORT_FALL_Changes_of_krystel]
 @M_Sal_Tran_ID		Numeric output
,@Emp_Id			Numeric
,@Cmp_ID			Numeric
,@Month_St_Date		Datetime
,@Month_End_Date	Datetime
,@Short_Fall_Days		Numeric(18,1)
,@G_Short_Fall_W_Days   numeric(18,0)=0
,@Is_Gradewise_Short_Fall int=0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	-- Variable Declaration 	

	declare @Sal_Receipt_No			Numeric
	Declare @Increment_ID			Numeric
	DEclare @Sal_Tran_ID			numeric 
	Declare @Branch_ID				numeric 
	declare @Wages_Type				varchar(10)
	declare @SalaryBasis			varchar(5)
	Declare @numWorkingDays_Daily	Numeric(12,1)
	Declare @Sal_cal_Days			Numeric(12,1)
	declare @OutOf_Days				Numeric        
	
	Declare @Shift_Day_Sec			Numeric
	Declare @Shift_Day_Hour			varchar(20)
	Declare @Basic_Salary			Numeric(25,2)
	Declare @Gross_Salary			Numeric(25,2)
	Declare @Actual_Gross_Salary	Numeric(25,2)
	Declare @Gross_Salary_ProRata	numeric(25,2)
	Declare @Day_Salary				Numeric(12,5)
	Declare @Hour_Salary			Numeric(12,5)
	Declare @Salary_amount			Numeric(12,5)
	Declare @Allow_Amount			Numeric(18,2)
	
	Declare @Net_Amount				Numeric(18,2)
	Declare @Short_Fall_W_Days		numeric(5,1)

	--Rohit on 26062013
	Declare @sal_St_Date  datetime
	Declare @Sal_End_Date Datetime
	Declare @Left_Date Datetime
	set @sal_St_Date =''
	set @Sal_End_Date=''
	set @Left_Date=''
	-- Ended by rohit
	--set @OutOf_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1
	declare @tmp_mon_end_date datetime
	select @tmp_mon_end_date = dbo.GET_MONTH_END_DATE(month(@Month_End_Date),year(@Month_End_Date))	
	
	set @OutOf_Days = datediff(d,@Month_St_Date,@tmp_mon_end_date) + 1


	Set @Wages_Type		= ''
	Set @SalaryBasis	= ''
	Set @numWorkingDays_Daily = 0
	Set @Sal_cal_Days	 = 0
	Set @Shift_Day_Sec	= 0 
	Set @Shift_Day_Hour		 = ''
	Set @Basic_Salary		 = 0 
	Set @Day_Salary			 = 0
	Set @Hour_Salary		 = 0
	Set @Salary_amount		 = 0
	Set @Allow_Amount		 = 0
	Set @Gross_Salary		 = 0
	Set @Net_Amount			= 0
	set @Short_Fall_W_Days = 0
	
		select @Increment_ID = I.Increment_ID ,@Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On,
			 @Actual_Gross_Salary = Gross_Salary ,@Basic_Salary = IsNull(Basic_Salary,0),
			 @Branch_ID = Branch_ID
			From T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @Month_End_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
		Where I.Emp_ID = @Emp_ID

		-- Added By Sajid 30112021 START (For Allowance Base Calcualte Short Fall Days)
		DECLARE @temp_t_amt NUMERIC(18,4)
		SELECT @temp_t_amt = ISNULL(SUM(E_AD_amount),0)
					FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN  
						( Select Max(For_Date) For_Date, Ad_Id From T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
							Where Emp_Id  = @Emp_Id And For_date <= @Month_End_Date 
							Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
						INNER JOIN dbo.T0050_AD_MASTER ADM ON EEd.AD_ID = ADM.AD_ID                     
					WHERE emp_id = @emp_id 
							And Adm.AD_ACTIVE = 1 AND ISNULL(ADM.AD_EFFECT_ON_SHORT_FALL,0) = 1 and ADM.AD_FLAG='I' 
         -- Added By Sajid 30112021 END
		 --Comment by ronak as per discussion with chintan bhai 06032023
	select 	@Short_Fall_W_Days = isnull(Fnf_Fix_Day,0),@sal_St_Date=isnull(Sal_St_Date,'') from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

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
			else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
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
  
 --Rohit on 26062013
		--Comment by ronak as per discussion with chintan bhai 06032023
	    --if @Is_Gradewise_Short_Fall=1
		--Begin 
		--	set @Short_Fall_W_Days=@G_Short_Fall_W_Days
		--End
		
	---select @Short_Fall_W_Days
		
	if @Short_Fall_W_Days > 0
		set @OutOf_Days = @Short_Fall_W_Days
	
	
	
	Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_Id,@Cmp_ID,@Month_End_Date,null,null,@Shift_Day_Hour output
	
	select @Shift_Day_Sec = dbo.F_Return_Sec(@Shift_Day_Hour)
	
    
	set @Sal_cal_Days = @Short_Fall_Days 
	
    
  
	If @Wages_Type = 'Monthly' 
		begin
			set @Day_Salary = 	@Basic_Salary / @Outof_Days 
	
			--set @Gross_Salary_ProRata = @Actual_Gross_Salary/@Outof_Days
			set @Gross_Salary_ProRata = (@Basic_Salary+@temp_t_amt)/@Outof_Days  -- Added by Sajid 30112021 
	
		end 
	Else
		set @Day_Salary = 	@Basic_Salary
		
		if isnull(@Shift_Day_Sec,0) < = 0
			set @Shift_Day_Sec = 28800
	Set @Hour_Salary	= @Day_Salary * 3600 / @Shift_Day_Sec	 

		
    
	Set @Salary_Amount  = Round(@Day_Salary * @Sal_Cal_Days,0)
	
	set @Gross_Salary_ProRata = Round(@Gross_Salary_ProRata * @Sal_Cal_Days,0)
	
	EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION_SHORT_FALL @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Short_Fall_Days,@Sal_Cal_Days,@Outof_Days,@Day_Salary ,@Branch_ID
	
	

	SELECT @Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) From #Salary_AD  Where Emp_ID = @Emp_ID 
																	
	set @Allow_Amount = isnull(@Allow_Amount,0)
	
	Set @Gross_Salary = @Salary_Amount + @Allow_Amount 
	
	set @Net_Amount = @Gross_Salary 
	
	Insert Into #Salary(Company_ID,Emp_Id,From_Date,To_Date,Shoft_Fall_days,Salary_Amount,Allow_Amount,Gross_Salary)
	Select @Cmp_ID,@Emp_ID,@Month_St_Date,@Month_End_Date,@Short_Fall_Days,@Salary_Amount,@Allow_Amount,@Gross_Salary_ProRata

	RETURN




