




----------------------------------------------------------------------------------------------
--ALTER BY:
--Modified By :
--Description:
--Notes :  Please dont put the Select @Emp_Id like that...
--Late Modified and Review Please Put Comments
---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
----------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_GENERATE_MANUAL1]      
 @M_Sal_Tran_ID  Numeric output      
,@Emp_Id   Numeric      
,@Cmp_ID   Numeric      
,@Sal_Generate_Date datetime      
,@Month_St_Date  Datetime      
,@Month_End_Date Datetime      
,@Present_Days  Numeric(18,1)      
,@M_OT_Hours  Numeric(18,2)      
,@Areas_Amount  Numeric(18,2)       
,@M_IT_Tax   NUMERIC(18,2)      
,@Other_Dedu  numeric(18,2)      
,@M_LOAN_AMOUNT  NUMERIC      
,@M_ADV_AMOUNT  NUMERIC      
,@IS_LOAN_DEDU  NUMERIC --(0,1)      
,@Login_ID   Numeric = null      
,@ErrRaise   Varchar(100)= null output      
,@Is_Negetive  Varchar(1)  
,@Status   varchar(10)='Done'  
,@IT_M_ED_Cess_Amount numeric(18,2)
,@IT_M_Surcharge_Amount numeric(18,2)
,@Allo_On_Leave numeric(18,0)=1
    
AS  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
       
 if @Status =''      
  set @Status ='Done'      
        
      
      
 declare @Sal_Receipt_No   Numeric      
 Declare @Increment_ID   Numeric      
 DEclare @Sal_Tran_ID   numeric       
 Declare @Branch_ID    numeric       
 declare @Emp_OT     numeric       
 Declare @Emp_OT_Min_Limit  varchar(10)      
 Declare @Emp_OT_Max_Limit  varchar(10)  
 Declare @late_Extra_Amount as numeric      
 Declare @Emp_OT_Min_Sec   numeric      
 Declare @Emp_OT_Max_Sec   numeric      
 Declare @Emp_OT_Sec    numeric      
 Declare @Emp_OT_Hours   varchar(10)      
 declare @Wages_Type    varchar(10)      
 declare @SalaryBasis   varchar(5)      
 declare @Payment_Mode   varchar(20)      
 declare @Fix_Salary    int
 declare @numAbsentDays   Numeric(12,1)             
 Declare @numWorkingDays_Daily Numeric(12,1)      
 declare @numAbsentDays_Daily Numeric(12,1)      
 Declare @Sal_cal_Days   Numeric(12,1)      
 Declare @Absent_Days   Numeric(12,1)      
 Declare @Holiday_Days   Numeric(12,1)      
 Declare @Weekoff_Days   Numeric(12,1)      
 Declare @Cancel_Holiday   Numeric(12,1)      
 Declare @Cancel_Weekoff   Numeric(12,1)      
 Declare @Working_days   Numeric(12,1)      
 declare @OutOf_Days    Numeric              
 Declare @Total_leave_Days  Numeric(12,1)      
 Declare @Paid_leave_Days  Numeric(12,1)      
 Declare @Unpaid_Leave      Numeric(12,1)      
 Declare @Actual_Working_Hours varchar(20)      
 Declare @Actual_Working_Sec  numeric      
 Declare @Working_Hours   varchar(20)      
 Declare @Outof_Hours   varchar(20)      
 Declare @Total_Hours   varchar(20)      
 Declare @Shift_Day_Sec   Numeric      
 Declare @Shift_Day_Hour   varchar(20)      
 Declare @Basic_Salary   Numeric(25,2)      
 Declare @Gross_Salary   Numeric(25,2)      
 Declare @Actual_Gross_Salary Numeric(25,2)      
 Declare @Gross_Salary_ProRata numeric(25,2)      
 Declare @Day_Salary    Numeric(12,5)      
 Declare @Hour_Salary   Numeric(12,5)      
 Declare @Salary_amount   Numeric(12,5)      
 Declare @Allow_Amount   Numeric(18,2)      
 Declare @OT_Amount    Numeric(18,2)      
 Declare @Other_allow_Amount  Numeric(18,2)      
 Declare @Dedu_Amount   Numeric(18,2)      
 Declare @Loan_Amount   Numeric(18,2)      
 Declare @Loan_Intrest_Amount Numeric(18,2)      
 Declare @Advance_Amount   Numeric(18,2)      
 Declare @Other_Dedu_Amount  Numeric(18,2)   
 Declare @Other_m_it_Amount numeric(18,2)   
 Declare @Total_Dedu_Amount  Numeric(18,2)      
 Declare @Due_Loan_Amount  Numeric(18,2)      
 Declare @Net_Amount    Numeric(18,2)      
 Declare @Final_Amount   Numeric(18,2)      
 Declare @Hour_Salary_OT   Numeric(18,2)      
 Declare @ExOTSetting   Numeric(5,2)      
 Declare @Inc_Weekoff   char(1) 
 Declare @Inc_Holiday   char(1) 
      
 Declare @Late_Adj_Day   Numeric(5,2)      
 Declare @OT_Min_Limit   varchar(20)      
 Declare @OT_Max_Limit   varchar(20)      
 Declare @OT_Min_Sec    Numeric      
 Declare @OT_Max_Sec    Numeric      
 Declare @Is_OT_Inc_Salary  char(1)      
 Declare @Is_Daily_OT   char(1)      
 Declare @Fix_Shift_Hours  varchar(20)      
 Declare @Fix_OT_Work_Days  Numeric(18,2)      
 Declare @Round     Numeric      
 declare @Restrict_Present_Days char(1)      
 Declare @Is_Cancel_Holiday  tinyint      
 Declare @Is_Cancel_Weekoff  tinyint    
 Declare @Join_Date    Datetime      
 Declare @Left_Date    Datetime       
 Declare @StrHoliday_Date  varchar(1000)      
 Declare @StrWeekoff_Date  varchar(1000)      
 Declare @Update_Adv_Amount  numeric       
 Declare @Total_Claim_Amount  numeric       
 Declare @Is_PT     numeric      
 Declare @Is_Emp_PT    numeric      
 Declare @PT_Amount    numeric      
 Declare @PT_Calculated_Amount numeric       
 Declare @LWF_Amount    numeric       
 Declare @LWF_App_Month   varchar(50)      
 Declare @Revenue_Amount   numeric       
 Declare @Revenue_On_Amount  numeric       
 Declare @LWF_compare_month  varchar(5)      
 declare @PT_F_T_Limit   varchar(20)      
 Declare @Lv_Salary_Effect_on_PT  tinyint       
 Declare @Leave_Salary_Amount numeric(12,0)      
 Declare @Settelement_Amount numeric(12,0)      
 Declare @Bonus_Amount		numeric(10,0)
 Declare @OT_Working_Day	numeric(4,1) 
 Declare @StrMonth varchar(10)         
 Declare @Is_Zero_Day_Salary Numeric(2)--nikunj At 7-sep-2010 for zero day
 
 -- Temporary Table 
  CREATE table #OT_Data
  (
	Emp_ID			numeric ,
	Basic_Salary	numeric(18,5),
	Day_Salary		numeric(12,5),
	OT_Sec			numeric,
	Ex_OT_Setting	tinyint,
	OT_Amount		numeric,
	Shift_Day_Sec	int,
	OT_Working_Day	numeric(4,1)
  )    
  
 
CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	 
	     
 set @OutOf_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1      
 Set @Emp_OT   = 0      
 Set @Wages_Type  = ''      
 Set @SalaryBasis = ''      
 Set @Payment_Mode = ''      
 Set @Fix_Salary  = 0      
 Set @numAbsentDays =0      
 Set @numWorkingDays_Daily = 0      
 Set @numAbsentDays_Daily  = 0      
 Set @Sal_cal_Days  = 0      
 Set @Absent_Days  = 0      
 Set @Holiday_Days  = 0      
 Set @Weekoff_Days  = 0      
 Set @Cancel_Holiday  = 0      
 Set @Cancel_Weekoff  = 0      
 Set @Working_days  = 0      
 Set @Total_leave_Days  = 0      
 Set @Paid_leave_Days  = 0      
 set @Update_Adv_Amount = 0      
 set @Total_Claim_Amount  = 0      
 set @Unpaid_Leave =0
 Set @Actual_Working_Hours  =''      
 set @Actual_Working_Sec =0      
 Set @Working_Hours  = ''      
 Set @Outof_Hours  = ''      
 Set @Total_Hours  = ''      
 Set @Shift_Day_Sec = 0       
 Set @Shift_Day_Hour   = ''      
 Set @Basic_Salary   = 0       
 Set @Day_Salary    = 0      
 Set @Hour_Salary   = 0      
 Set @Salary_amount   = 0      
 Set @Allow_Amount   = 0      
 Set @OT_Amount    = 0      
 Set @Other_allow_Amount  = @Areas_Amount      
 Set @Gross_Salary   = 0      
 Set @Dedu_Amount   = 0      
 Set @Loan_Amount   = 0      
 Set @Loan_Intrest_Amount = 0      
 Set @Advance_Amount   = 0      
 Set @Other_Dedu_Amount = @Other_Dedu 
 set @Other_m_it_Amount = @M_IT_Tax     
 Set @Total_Dedu_Amount = 0      
 Set @Due_Loan_Amount = 0      
 Set @Net_Amount   = 0      
 Set @Final_Amount  = 0      
 set @Hour_Salary_OT  = 0       
 set @Inc_Weekoff = 1  
 set @Inc_Holiday =1
 
 set @Late_Adj_Day = 0      
 set @ExOTSetting   = 0      
 set @OT_Min_Limit   =''      
 set @OT_Max_Limit   = ''      
 set @Is_OT_Inc_Salary  = ''      
 set @Is_Daily_OT   = 'N'      
 set @Fix_Shift_Hours  = ''      
 set @Fix_OT_Work_Days = 0      
 set @OT_Min_Sec  = 0      
 set @OT_Max_Sec  = 0      
 set @Round = 0      
 set @Restrict_Present_Days = 'Y'      
 set @Is_Cancel_Weekoff = 0  
 set @Is_Cancel_Holiday = 0       
 Set @StrHoliday_Date = ''      
 set @StrWeekoff_Date = ''      
 set @Emp_OT_Min_Limit = ''      
 set @Emp_OT_Max_Limit = ''      
 set @Emp_OT_Min_Sec = 0      
 set @Emp_OT_Max_Sec = 0      
 set @Emp_OT_Sec = @M_OT_Hours * 3600      
 set @Is_PT = 0      
 set @Is_Emp_PT = 0      
 set @PT_Amount = 0      
 set @PT_Calculated_Amount = 0      
 set @LWF_Amount    =0      
 set @LWF_App_Month  = ''      
 set @Revenue_Amount   =0      
 set @Revenue_On_Amount  = 0      
 set @LWF_compare_month  =''      
 set @PT_F_T_Limit = ''      
 set @Lv_Salary_Effect_on_PT  =0      
 set @Leave_Salary_Amount = 0      
 set @Settelement_Amount  = 0      
 set @Bonus_Amount	 =0       
 set @StrMonth='#' + cast(Month(@Month_End_Date) as varchar(2)) + '#' 
 Declare @Emp_Part_Time numeric
 Set @Emp_Part_Time =0
 Declare @Wages_Amount as numeric(18,0)
 set @Wages_Amount =0
     
       
 
  Declare @Increment_Effective_Date as dateTime
        
  select @Increment_ID = Increment_ID ,@Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On      
   ,@Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode ,     @Increment_Effective_Date =Increment_effective_Date, 
    @Actual_Gross_Salary = Gross_Salary ,@Basic_Salary =Basic_Salary,      
    @Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit, @Emp_Part_Time = isnull(Emp_Part_Time,0) ,    
    @Branch_ID = Branch_ID,      
    @Is_Emp_PT =isnull(Emp_PT,0),@Fix_Salary=isnull(Emp_Fix_Salary,0)      
   From T0095_Increment I WITH (NOLOCK) inner join       
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)     
     where Increment_Effective_date <= @Month_End_Date      
     and Cmp_ID = @Cmp_ID      
     group by emp_ID  ) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
  Where I.Emp_ID = @Emp_ID      
  
    Declare @Wage_Amount as numeric(18,2)
    set @Wage_Amount =0 
     

    Declare @Joint as dateTime
    if exists (Select Date_Of_Join from T0080_emp_Master WITH (NOLOCK) where emp_id=@Emp_ID and Month(Date_Of_Join) =Month(@Month_St_Date))
      Begin
  
		set @Increment_Effective_Date= @Month_St_Date		
      End
    

    Declare @Actual_Gross as numeric(18,2)
     set @Actual_Gross =0    
     
   
		select @ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff,@Late_Adj_Day = isnull(Late_Adj_Day,0)      
				,@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = Isnull(OT_Max_Limit,'00:00')      
				,@Is_OT_Inc_Salary = isnull(OT_Inc_Salary,'N')       
				,@Is_Daily_OT = Is_Daily_OT       
				,@Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)      
				,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)      
				,@Fix_Shift_Hours = ot_Fix_Shift_Hours      
				,@Fix_OT_Work_Days = isnull(OT_fiX_Work_Day,0)      
				,@Is_PT = isnull(Is_PT,0)      
				,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month      
				,@Revenue_amount = Revenue_amount , @Revenue_on_Amount = Revenue_on_Amount     ,@Wages_Amount=Wages_Amount ,@Actual_Gross =Actual_Gross
				,@Lv_Salary_Effect_on_PT = Lv_Salary_Effect_on_PT,@Inc_Holiday = isnull(Inc_Holiday,0),@Is_Zero_Day_Salary=isnull(Is_Zero_Day_Salary,0)
				from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID      
			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)      
      
    

	   Declare @Old_Present_Days2 as numeric(18,2)
	   set @Old_Present_Days2 = 0
	   set @Old_Present_Days2 =@Present_Days

----------------------------------------------------------- 

   
  	IF @Month_St_Date <= @Increment_Effective_Date
		Begin		
		  
		   Declare @Old_OutOf_Days1 as numeric(18,2)
		   Declare @Old_Present_Days1 as numeric(18,2)
		   
		   
		    set @Old_OutOf_Days1 = 0
		    set @Old_Present_Days1 = 0
		    set @Old_Present_Days2 = 0
		    
		   
			set @Old_OutOf_Days1 = datediff(d,@Month_St_Date,@Increment_Effective_Date)  
		    set @Present_Days  =@Present_Days + @Weekoff_Days+@Holiday_Days
		    
		    If  @Present_Days > @Old_OutOf_Days1
		      Begin 
					
		         set @Old_Present_Days1 = @Old_OutOf_Days1
		         set @Old_Present_Days2 = @Present_Days - @Old_OutOf_Days1

		      End  
		    Else 
		       Begin    
				 
		         set @Old_Present_Days1 = @Present_Days     
		       End 
		    

		   If @Actual_Gross = 1
			Begin 
         
			  
				 Declare @Old_Actuall_Gross_Salary as numeric(18,2)
				Set @Old_Actuall_Gross_Salary =0.0
			   
				 Declare @old_basic_Salary as numeric(18,2)
				 set @old_basic_Salary =0.0
			   

				  Select @Old_Actuall_Gross_Salary = Gross_Salary,@old_basic_Salary=basic_salary from T0095_Increment WITH (NOLOCK) where Increment_Effective_Date  < @Increment_Effective_Date and emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID
 
				  set @Old_Actuall_Gross_Salary = Round(@Old_Actuall_Gross_Salary * @Old_Present_Days1/@Outof_Days,0) 	
				  set @old_basic_Salary =  Round(@old_basic_Salary * @Old_Present_Days1/@Outof_Days,0) 	

  

            End      		
		End



		Exec P0200_MONTHLY_SALARY_GENERATE_MANUAL @M_Sal_Tran_ID output, @Emp_Id, @Cmp_ID , @Sal_Generate_Date , @Month_St_Date , @Month_End_Date, @Old_Present_Days2 , @M_OT_Hours , @Areas_Amount , @M_IT_Tax , @Other_Dedu , @M_LOAN_AMOUNT , @M_ADV_AMOUNT , @IS_LOAN_DEDU , @Login_ID, @ErrRaise , @Is_Negetive , @Status , @IT_M_ED_Cess_Amount, @IT_M_Surcharge_Amount , @Allo_On_Leave,@Old_basic_Salary ,@Old_Actuall_Gross_Salary ,@Present_Days 

  Return




