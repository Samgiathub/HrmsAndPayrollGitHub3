
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_DAILY_WAGES]    
	@M_Sal_Tran_ID  NUMERIC output    
	,@Emp_Id   NUMERIC    
	,@Cmp_ID   NUMERIC    
	,@Sal_Generate_Date DATETIME    
	,@Month_St_Date  DATETIME    
	,@Month_End_Date DATETIME    
	,@M_OT_Hours  NUMERIC(18,2)    
	,@Areas_Amount  NUMERIC(18,2)     
	,@M_IT_Tax   NUMERIC(18,2)    
	,@Other_Dedu  NUMERIC(18,2)    
	,@M_LOAN_AMOUNT  NUMERIC    
	,@M_ADV_AMOUNT  NUMERIC    
	,@IS_LOAN_DEDU  NUMERIC --(0,1)    
	,@Login_ID   NUMERIC = null    
	,@ErrRaise   VARCHAR(100)= null output    
	,@Is_Negetive  NUMERIC(1)     
	,@Status   VARCHAR(10)='Done'
	,@IT_M_ED_Cess_Amount NUMERIC(18,2)
	,@IT_M_Surcharge_Amount     NUMERIC(18,2)
	,@Allo_On_Leave NUMERIC(18,0)=1 
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	DECLARE @Var_Present NUMERIC(18,2)
	DECLARE @Var_Amount NUMERIC(18,2)
	SET @Var_Present =0.0
	SET @Var_Amount=0.0
  
	DECLARE @Sal_from AS DATETIME
	DECLARE @Sal_to AS DATETIME
  
	SET @Sal_from =@Month_ST_Date
	SET @Sal_to =@Month_End_Date
  
	SET @Var_Present =@M_LOAN_AMOUNT
	SET @Var_Amount=@M_ADV_AMOUNT 
 
	SET @Month_St_Date =CAST(@Month_St_Date AS VARCHAR(11))
	SET @Month_End_Date=CAST(@Month_End_Date AS VARCHAR(11))
  
	DECLARE @Sal_St_Date1  AS DATETIME
	SET @Sal_St_Date1=@Month_St_Date
	DECLARE @Sal_End_Date1  AS DATETIME
	SET @Sal_End_Date1=@Month_End_Date
  
 
   
	IF @Status =''    
		SET @Status ='Done'     
	-- Variable Declaration      
    
	 DECLARE @Sal_Receipt_No	NUMERIC    
	 DECLARE @Increment_ID		NUMERIC    
	 DECLARE @Sal_Tran_ID		NUMERIC     
	 DECLARE @Branch_ID			NUMERIC     
	 DECLARE @Emp_OT			NUMERIC     
	 DECLARE @Emp_OT_Min_Limit	VARCHAR(10)    
	 DECLARE @Emp_OT_Max_Limit	VARCHAR(10)    
	 DECLARE @Emp_OT_Min_Sec	NUMERIC    
	 DECLARE @Emp_OT_Max_Sec	NUMERIC    
	 DECLARE @Emp_OT_Sec		NUMERIC    
	 DECLARE @Emp_OT_Hours		VARCHAR(10)    
	 DECLARE @Wages_Type		VARCHAR(10)    
	 DECLARE @SalaryBasis		VARCHAR(5)    
	 DECLARE @Payment_Mode		VARCHAR(20)    
	 DECLARE @Fix_Salary		INT    
	 DECLARE @numAbsentDays		NUMERIC(12,1)           
	 DECLARE @numWorkingDays_Daily	NUMERIC(12,1)    
	 DECLARE @numAbsentDays_Daily	NUMERIC(12,1)    
	 DECLARE @Sal_cal_Days		NUMERIC(12,1)    
	 DECLARE @Absent_Days		NUMERIC(12,1)    
	 DECLARE @Holiday_Days		NUMERIC(12,1)    
	 DECLARE @Weekoff_Days		NUMERIC(12,1)    
	 DECLARE @Cancel_Holiday	NUMERIC(12,1)    
	 DECLARE @Cancel_Weekoff	NUMERIC(12,1)    
	 DECLARE @Working_days		NUMERIC(12,1)    
	 DECLARE @OutOf_Days		NUMERIC            
	 DECLARE @Total_leave_Days	NUMERIC(12,1)    
	 DECLARE @Paid_leave_Days	NUMERIC(12,1)    
     
	 DECLARE @Actual_Working_Hours	VARCHAR(20)    
	 DECLARE @Actual_Working_Sec	NUMERIC    
	 DECLARE @Holiday_Sec		NUMERIC     
	 DECLARE @Weekoff_Sec		NUMERIC     
	 DECLARE @Leave_Sec			NUMERIC    
     
	 DECLARE @Other_Working_Sec	NUMERIC     
	 DECLARE @Working_Hours		VARCHAR(20)    
	 DECLARE @Outof_Hours		VARCHAR(20)    
	 DECLARE @Total_Hours		VARCHAR(20)    
	 DECLARE @Shift_Day_Sec		NUMERIC    
	 DECLARE @Shift_Day_Hour	VARCHAR(20)    
	 DECLARE @Basic_Salary		NUMERIC(25,2)    
	 DECLARE @Gross_Salary		NUMERIC(25,2)    
	 DECLARE @Actual_Gross_Salary	NUMERIC(25,2)    
	 DECLARE @Gross_Salary_ProRata	NUMERIC(25,2)    
	 DECLARE @Day_Salary		NUMERIC(12,5)    
	 DECLARE @Hour_Salary		NUMERIC(12,5)    
	 DECLARE @Salary_amount		NUMERIC(12,5)    
	 DECLARE @Allow_Amount		NUMERIC(18,2)    
	 DECLARE @OT_Amount			NUMERIC(18,2)    
	 DECLARE @Other_allow_Amount	NUMERIC(18,2)    
	 DECLARE @Other_m_it_Amount	NUMERIC(18,2)  
	 DECLARE @Dedu_Amount		NUMERIC(18,2)    
	 DECLARE @Loan_Amount		NUMERIC(18,2)    
	 DECLARE @Loan_Intrest_Amount	NUMERIC(18,2)    
	 DECLARE @Advance_Amount	NUMERIC(18,2)    
	 DECLARE @Other_Dedu_Amount	NUMERIC(18,2)    
	 DECLARE @Total_Dedu_Amount	NUMERIC(18,2)    
	 DECLARE @Due_Loan_Amount	NUMERIC(18,2)    
	 DECLARE @Net_Amount		NUMERIC(18,2)    
	 DECLARE @Final_Amount		NUMERIC(18,2)    
	 DECLARE @Hour_Salary_OT	NUMERIC(18,2)    
	 DECLARE @ExOTSetting		NUMERIC(5,2)    
	 DECLARE @Inc_Weekoff		INT
	 DECLARE @Inc_Holiday		INT
 
	 DECLARE @Late_Adj_Day		NUMERIC(5,2)    
	 DECLARE @OT_Min_Limit		VARCHAR(20)    
	 DECLARE @OT_Max_Limit		VARCHAR(20)    
	 DECLARE @OT_Min_Sec		NUMERIC    
	 DECLARE @OT_Max_Sec		NUMERIC    
	 DECLARE @Is_OT_Inc_Salary  CHAR(1)    
	 DECLARE @Is_Daily_OT		CHAR(1)    
	 DECLARE @Fix_Shift_Hours	VARCHAR(20)    
	 DECLARE @Fix_OT_Work_Days	NUMERIC(18,2)    
	 DECLARE @Round				NUMERIC    

	 DECLARE @Restrict_Present_Days	CHAR(1)    
	 DECLARE @Is_Cancel_Holiday	NUMERIC(1,0)    
	 DECLARE @Is_Cancel_Weekoff	NUMERIC(1,0)    
	 DECLARE @Join_Date			DATETIME    
	 DECLARE @Left_Date			DATETIME     
	 --DECLARE @StrHoliday_Date	VARCHAR(1000)    
	 --DECLARE @StrWeekoff_Date	VARCHAR(1000)    
	 DECLARE @Update_Adv_Amount	NUMERIC     
	 DECLARE @Total_Claim_Amount	NUMERIC     
	 DECLARE @Is_PT				NUMERIC    
	 DECLARE @Is_Emp_PT			NUMERIC    
	 DECLARE @PT_Amount			NUMERIC    
	 DECLARE @PT_Calculated_Amount	NUMERIC     
	 DECLARE @LWF_Amount		NUMERIC     
	 DECLARE @LWF_App_Month		VARCHAR(50)    
	 DECLARE @Revenue_Amount	NUMERIC     
	 DECLARE @Revenue_On_Amount	NUMERIC     
	 DECLARE @LWF_compare_month	VARCHAR(5)    
	 DECLARE @PT_F_T_Limit		VARCHAR(20)    
	 DECLARE @Present_Days		NUMERIC(18,1)    
	 DECLARE @Half_Days			NUMERIC(18,1)    
	 DECLARE @Fix_late_W_Days	NUMERIC(5,1)    
	 DECLARE @Fix_late_W_Hours	VARCHAR(10)    
	 DECLARE @Fix_late_W_Shift_Sec	NUMERIC    
	 DECLARE @Late_deduction_Days	NUMERIC(5,1)    
	 DECLARE @Extra_Late_Deduction	NUMERIC(3,1)    
	 DECLARE @Hour_Salary_Late	NUMERIC(12,5)    
	 DECLARE @Late_Basic_Amount	NUMERIC (27,5)    
	 DECLARE @Sal_St_Date		DATETIME    
	 DECLARE @Sal_end_Date		DATETIME    
	 DECLARE @Sal_Fix_Days		NUMERIC(5,1)    
	 DECLARE @Bonus_Amount		NUMERIC(10,0)    
	 DECLARE @OT_Working_Day	NUMERIC(4,1)
	 DECLARE @StrMonth			VARCHAR(10)  
	 DECLARE @Is_Zero_Day_Salary	NUMERIC(2)--nikunj At 7-sep-2010 for zero day
	 DECLARE @count				NUMERIC
  
	 DECLARE @Wages_Amount	NUMERIC(18,0)

 SET @Wages_Amount =0
     
  -- Temporary Table 
  CREATE table #OT_Data
  (
	Emp_ID			NUMERIC ,
	Basic_Salary	NUMERIC(18,5),
	Day_Salary		NUMERIC(12,5),
	OT_Sec			NUMERIC,
	Ex_OT_Setting	NUMERIC(18,2),
	OT_Amount		NUMERIC,
	Shift_Day_Sec	int,
	OT_Working_Day	NUMERIC(4,1)
  )    
     
 SET @OutOf_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1    
 SET @Emp_OT   = 0    
 SET @Wages_Type  = ''    
 SET @SalaryBasis = ''    
 SET @Payment_Mode = ''    
 SET @Fix_Salary  = 0
 SET @numAbsentDays =0    
 SET @numWorkingDays_Daily = 0    
 SET @numAbsentDays_Daily  = 0    
 SET @Sal_cal_Days  = 0    
 SET @Absent_Days  = 0    
 SET @Holiday_Days  = 0    
 SET @Weekoff_Days  = 0    
 SET @Cancel_Holiday  = 0    
 SET @Cancel_Weekoff  = 0    
 SET @Working_days  = 0    
 SET @Total_leave_Days  = 0    
 SET @Paid_leave_Days  = 0    
 SET @Update_Adv_Amount = 0    
 SET @Total_Claim_Amount  = 0    
     
 SET @Actual_Working_Hours  =''    
 SET @Actual_Working_Sec = 0    
 SET @Holiday_Sec  = 0    
 SET @Weekoff_Sec  = 0    
 SET @Leave_Sec   = 0    
     
 SET @Other_Working_Sec =0    
 SET @Working_Hours  = ''    
 SET @Outof_Hours  = ''    
 SET @Total_Hours  = ''    
 SET @Shift_Day_Sec = 0     
 SET @Shift_Day_Hour   = ''    
 SET @Basic_Salary   = 0     
 SET @Day_Salary    = 0    
 SET @Hour_Salary   = 0    
 SET @Salary_amount   = 0    
 SET @Allow_Amount   = 0    
 SET @OT_Amount    = 0    
 SET @Other_allow_Amount  = @Areas_Amount    
 SET @Gross_Salary   = 0    
 SET @Dedu_Amount   = 0    
 SET @Loan_Amount   = 0    
 SET @Loan_Intrest_Amount = 0    
 SET @Advance_Amount   = 0    
 SET @Other_Dedu_Amount = @Other_Dedu  
 SET @Other_m_it_Amount = @M_IT_Tax       
 SET @Total_Dedu_Amount = 0    
 SET @Due_Loan_Amount = 0    
 SET @Net_Amount   = 0    
 SET @Final_Amount  = 0    
 SET @Hour_Salary_OT  = 0     
 SET @Inc_Weekoff = 1 
 SET @Inc_Holiday = 1    
 
 SET @Late_Adj_Day = 0    
 SET @ExOTSetting   = 0    
 SET @OT_Min_Limit   =''    
 SET @OT_Max_Limit   = ''    
 SET @Is_OT_Inc_Salary  = ''    
 SET @Is_Daily_OT   = 'N'    
 SET @Fix_Shift_Hours  = ''    
 SET @Fix_OT_Work_Days = 0    
 SET @OT_Min_Sec  = 0    
 SET @OT_Max_Sec  = 0    
 SET @Round = 0    
 SET @Restrict_Present_Days = 'Y'    
 SET @Is_Cancel_Weekoff = 0    
 SET @Is_Cancel_Holiday = 0    
 --SET @StrHoliday_Date = ''    
 --SET @StrWeekoff_Date = ''    
 SET @Emp_OT_Min_Limit = ''    
 SET @Emp_OT_Max_Limit = ''    
 SET @Emp_OT_Min_Sec = 0    
 SET @Emp_OT_Max_Sec = 0    
 SET @Emp_OT_Sec = @M_OT_Hours * 3600    
 SET @Is_PT = 0    
 SET @Is_Emp_PT = 0    
 SET @PT_Amount = 0    
 SET @PT_Calculated_Amount = 0    
 SET @LWF_Amount    =0    
 SET @LWF_App_Month  = ''    
 SET @Revenue_Amount   =0    
 SET @Revenue_On_Amount  = 0    
 SET @LWF_compare_month  =''    
 SET @PT_F_T_Limit = ''    
 SET @Fix_late_W_Days  = 0    
 SET @Fix_late_W_Hours  = ''    
 SET @Fix_late_W_Shift_Sec = 0     
 SET @Late_deduction_Days = 0    
 SET @Extra_Late_Deduction = 0    
 SET @Hour_Salary_Late  = 0    
 SET @Late_Basic_Amount  = 0    
 SET @Bonus_Amount = 0    
 SET @StrMonth='#' + CAST(Month(@Month_End_Date) AS VARCHAR(2)) + '#' 
  DECLARE @Emp_Part_Time NUMERIC
 SET @Emp_Part_Time =0
 
     
 -- For Calculate Present Days    
 CREATE table #Data     
  (     
	 Emp_Id     NUMERIC ,     
	 For_date   DATETIME,    
	 Duration_in_sec  NUMERIC,    
	 Shift_ID   NUMERIC ,    
	 Shift_Type   NUMERIC ,    
	 Emp_OT    NUMERIC ,    
	 Emp_OT_min_Limit NUMERIC,    
	 Emp_OT_max_Limit NUMERIC,    
	 P_days    NUMERIC(12,1) default 0,    
	 OT_Sec    NUMERIC default 0,
	 In_Time DATETIME default null,
	 Shift_Start_Time DATETIME default null,
	 OT_Start_Time NUMERIC default 0,
	 Shift_Change tinyint default 0 ,
	 Flag int default 0,
	 Weekoff_OT_Sec  NUMERIC default 0,
	 Holiday_OT_Sec  NUMERIC default 0,
	 Chk_By_Superior NUMERIC default 0,
	 IO_Tran_Id	   NUMERIC default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
	 OUT_Time DATETIME,  
	 Shift_End_Time DATETIME,		--Ankit 16112013
	 OT_End_Time NUMERIC default 0,	--Ankit 16112013
     Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
     Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
	 GatePass_Deduct_Days NUMERIC(18,2) default 0 -- Add by Gadriwala Muslim 05012014
  )    
  
  
	 While @Month_St_Date <=@Month_End_Date
	    Begin 
	        --Select @Month_St_Date
			IF Exists(Select Sal_tran_ID From T0200_MONTHLY_SALARY_Daily WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Emp_ID=@Emp_ID and @Month_ST_Date between Month_ST_Date and Month_end_Date)
					Begin   
						SET @Sal_tran_ID = 0
						Return 
					End
	
				Select @Sal_Tran_Id =  Isnull(max(Sal_Tran_Id),0)  + 1  From T0200_MONTHLY_SALARY_Daily  WITH (NOLOCK)   
				Select @Sal_Receipt_No =  isnull(max(sal_Receipt_No),0)  + 1  From T0200_MONTHLY_SALARY_Daily  WITH (NOLOCK) Where Month(Month_St_Date) = Month(@Month_St_DAte)     
				and YEar(Month_St_Date) = Year(@Month_End_Date) and Cmp_ID= @Cmp_ID   
				
				
				Select @Increment_ID = I.Increment_ID ,@Wages_Type = Wages_type,@SalaryBasis = Salary_Basis_On    
				,@Emp_OT = Emp_OT , @Payment_Mode = Payment_Mode ,    
				 @Actual_Gross_Salary = Gross_Salary ,@Basic_Salary =Basic_Salary,    
				 @Emp_OT_Min_Limit = Emp_OT_Min_Limit , @Emp_OT_Max_Limit = Emp_OT_Max_Limit, @Emp_Part_Time = isnull(Emp_Part_Time,0) ,        
				 @Branch_ID = Branch_ID,    
				 @Is_Emp_PT =isnull(Emp_PT,0),@Fix_Salary=isnull(Emp_Fix_Salary,0)    
				From T0095_Increment I WITH (NOLOCK) inner join     
				(select max(Increment_Id) AS Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)    --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @Month_End_Date and Cmp_ID = @Cmp_ID       
					group by emp_ID) Qry on    				
				I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id  Where I.Emp_ID = @Emp_ID       
					 		
							

			    Select @ExOTSetting = ExOT_Setting,@Inc_Weekoff = Inc_Weekoff,@Late_Adj_Day = isnull(Late_Adj_Day,0)    
					,@OT_Min_Limit = OT_APP_LIMIT ,@OT_Max_Limit = Isnull(OT_Max_Limit,'00:00')    
					,@Is_OT_Inc_Salary = isnull(OT_Inc_Salary,'N')     
					,@Is_Daily_OT = Is_Daily_OT,@Is_Cancel_Holiday = Is_Cancel_Holiday         
					,@Is_Cancel_Weekoff = Is_Cancel_Weekoff      
					,@Fix_Shift_Hours = ot_Fix_Shift_Hours    			  
					,@Fix_OT_Work_Days = isnull(OT_fiX_Work_Day,0)    
					,@Is_PT = isnull(Is_PT,0)    
					,@LWF_Amount = LWF_Amount , @LWF_App_Month = LWF_Month    
					,@Revenue_amount = Revenue_amount , @Revenue_on_Amount =Revenue_on_Amount ,@Wages_Amount =isnull(Wages_amount ,0)   
					,@Sal_St_Date  =Sal_st_Date , @Sal_Fix_Days = Sal_Fix_Days,@Inc_Holiday = isnull(Inc_Holiday,0),@Is_Zero_Day_Salary=isnull(Is_Zero_Day_Salary,0)
					from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
				and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    		 
				
				
				 SET @Sal_St_Date =@Month_St_Date
				 SET @Sal_End_Date =@Month_End_Date
				 IF isnull(@Sal_St_Date,'') = ''    
					Begin    
						SET @Sal_St_Date  = @Month_St_Date     
						SET @Sal_End_Date = @Month_End_Date    
						SET @Sal_Fix_Days = @OutOf_Days     
					End     
					Else IF day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
						Begin    
							SET @Sal_St_Date  = @Month_St_Date     
							SET @Sal_End_Date = @Month_End_Date    
							SET @Sal_Fix_Days = @OutOf_Days    
						End     
				else IF @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
					begin    
					-- Commeneted by rohit on 03-nov-2013 for nagamils for Salary not generate for 31-oct-2013
						--SET @Sal_St_Date =  CAST(CAST(day(@Sal_St_Date)as VARCHAR(5)) + '-' + CAST(datename(mm,dateadd(m,-1,@Month_St_Date)) AS VARCHAR(10)) + '-' +  CAST(year(dateadd(m,-1,@Month_St_Date) )as VARCHAR(10)) AS smallDATETIME)    
						--SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))           
					-- Ended by rohit on 03-nov-2013 for nagamils for Salary not generate for 31-oct-2013
						SET @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1    
       

		
			   IF isnull(@Sal_Fix_Days,0) = 0    
					SET @Sal_Fix_Days = @OutOf_Days    
				else    
					SET @OutOf_Days = @Sal_Fix_Days        
				end    
				
				SET  @Sal_St_Date =@Month_ST_Date
				SET @Sal_End_Date =@Month_end_Date
				

				 
  				Exec P0210_MONTHLY_LEAVE_INSERT @Cmp_ID ,@Emp_ID,@Sal_St_Date,@Sal_St_Date,@Sal_Tran_ID 
				Exec SP_CURR_T0100_EMP_SHIFT_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,null,null,@Shift_Day_Hour output   

				IF OBJECT_ID(N'tempdb..#EMP_WEEKOFF') IS NOT NULL
				BEGIN
					DROP TABLE #EMP_WEEKOFF
				END
				

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
				
				IF OBJECT_ID(N'tempdb..#EMP_HOLIDAY') IS NOT NULL
				BEGIN
					DROP TABLE #EMP_HOLIDAY
				END

				CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
				CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

				

				DECLARE @CONSTRAINT VARCHAR(10)
				SET @CONSTRAINT = CAST(@Emp_ID AS VARCHAR(10))
				EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Sal_St_Date, @TO_DATE=@Sal_End_Date, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW=0

				SELECT @Weekoff_Days = SUM(W_DAY) FROM #EMP_WEEKOFF WHERE Is_Cancel=0 AND Emp_ID=@Emp_Id
				SELECT @Holiday_Days = SUM(H_DAY) FROM #EMP_HOLIDAY WHERE Is_Cancel=0 AND Emp_ID=@Emp_Id
				SELECT @Cancel_Weekoff = COUNT(1) FROM #EMP_WEEKOFF WHERE Is_Cancel=1 AND Emp_ID=@Emp_Id
				SELECT @Cancel_Holiday = COUNT(1) FROM #EMP_HOLIDAY WHERE Is_Cancel=1 AND Emp_ID=@Emp_Id
				--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,@Sal_St_Date,@Join_Date,@left_Date,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output    
				--Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@Sal_St_Date,@Sal_St_Date,@Join_Date,@left_Date,@Is_Cancel_Holiday,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
				Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@Sal_St_Date,@Sal_St_Date,0,0,0,0,0,0,@emp_ID,'',4    
				

  
			 	DECLARE @P_DAys AS NUMERIC(18,1)
				select @Present_Days = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0), @Emp_OT_Sec = isnull(sum(OT_Sec),0) From  #Data where Emp_ID=@emp_ID     
					and For_Date>=@Sal_St_Date and For_Date <=@Sal_End_Date   --and Duration_In_Sec <>0
	   	 
	   			select @P_DAys = isnull(sum(P_Days),0), @Actual_Working_Sec =isnull(sum(Duration_In_Sec),0), @Emp_OT_Sec = isnull(sum(OT_Sec),0) From  #Data where Emp_ID=@emp_ID     
				 and For_Date>=@Sal_St_Date and For_Date <=@Sal_End_Date  
				 
				 
				 ---IF Present Days is Greter then 1  and Less then 2 then Count AS 1 Days-----------------
			     IF (@P_DAys >= 1 and @P_DAys < 2) 
			       Begin 
						SET @P_DAys =1
			       End
			      Else IF (@P_DAys >= 2  and @P_DAys < 3)
			      Begin 
						SET @P_DAys =2
			       End
			     ---------------------------------------------------------------------------------------------     
				     
				select @Shift_Day_Sec = dbo.F_Return_Sec(@Shift_Day_Hour)    
				select @Emp_OT_Min_Sec  = dbo.F_Return_Sec(@Emp_OT_Min_Limit)    
				select @Emp_OT_Max_Sec  = dbo.F_Return_Sec(@Emp_OT_Max_Limit)    
				select @Actual_Working_Hours = dbo.F_Return_Hours (@Actual_Working_Sec)  
				
				--select @Salary_Amount , @Allow_Amount , @Other_Allow_Amount , @Total_Claim_Amount  , @OT_Amount  , @Bonus_Amount,@Is_OT_Inc_Salary
				-------------------- Late Deduction ---------------------------    
					DECLARE @Late_Absent_Day  NUMERIC(18,1)    
					DECLARE @Total_LMark   NUMERIC(18,1)    
					DECLARE @Total_Late_Sec   NUMERIC     
					DECLARE @Late_Dedu_Amount  NUMERIC     
					DECLARE @Extra_Late_Dedu_Amount NUMERIC    
					DECLARE @late_Extra_Amount AS NUMERIC  
      
					Select @Late_Adj_Day =  isnull(Late_Adj_Day,0)   
					   from T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID and For_date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK)    
					  where Cmp_ID = @Cmp_ID and For_Date <=@Month_end_Date and Branch_ID =@Branch_ID)  
					SET @Late_Absent_Day = 0    
					SET @Total_LMark = 0    
					SET @Total_Late_Sec =0  
					    
						
					IF @Fix_late_W_Days =0 And @Wages_Type = 'Monthly'    
						SET @Fix_late_W_Days = @OutOf_Days    
					Else IF @Wages_Type <> 'Monthly'    
						SET @Fix_late_W_Days = 1     
					IF @Fix_late_W_Shift_Sec =0    
						SET @Fix_late_W_Shift_Sec =@Shift_Day_Sec    
             
					--exec SP_CALCULATE_LATE_DEDUCTION @emp_Id,@Cmp_ID,@Sal_St_Date,@Sal_end_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID    
					SET @Present_Days = @Present_Days - isnull(@Late_Absent_Day,0)    	  
  
					select @Total_leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail WITH (NOLOCK) where Emp_ID = @emp_ID and     
						TEMP_SAL_TRAN_ID = @Sal_Tran_ID     
  
					select @Paid_Leave_Days = isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail WITH (NOLOCK) where Emp_ID = @emp_ID and     
						TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'P'         
      
					----Nilay Late Mark Deduction  ---- 30 may 2009  
				IF @Late_Adj_Day < @Total_LMark
						Begin
							SET  @late_Extra_Amount=@Total_LMark - isnull(@Late_Adj_Day,0)    
						end
					Else
						Begin
							SET  @late_Extra_Amount=@Total_LMark 
						end
 		


 ----------------------------end -------------------------------    
      --select @Present_Days Deepal
				 IF @Inc_Weekoff = 1    
				  SET @Sal_cal_Days = @Present_Days 
				 Else    
				  SET @Sal_cal_Days = @Present_Days 
				  
				  SET @Absent_Days = @Outof_Days - (@Present_Days +  @WeekOff_Days + @Holiday_Days + @Paid_Leave_Days)    
				  IF @Absent_Days < 0     
					SET @Absent_Days =0     	

			 	IF @Wages_Type ='Weekly'
					SET @Salary_Amount  = Round(@Basic_Salary * @Sal_Cal_Days,@Round)    
       								

				--Exec SP_CALCULATE_ALLOWANCE_DEDUCTION_Daily @Sal_Tran_ID,@Emp_Id,@Cmp_ID,@Increment_ID,@Month_St_Date,@Month_End_Date,@Wages_Type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_cal_Days,@Working_Days,@OT_Amount output,@Day_Salary,@Branch_ID,@M_IT_Tax,NULL,@late_Extra_Amount,@Allo_On_Leave   --Added by mitesh on 27/08/2011 -- Daily Allow
				EXEC SP_CALCULATE_ALLOWANCE_DEDUCTION_Daily @Sal_Tran_ID,@emp_ID,@Cmp_ID,@Increment_ID,@month_St_Date,@Month_End_Date,@Wages_type,@Basic_Salary,@Gross_Salary_ProRata,@Salary_Amount,@Present_Days,@Absent_Days,@Paid_leave_Days,@Sal_Cal_Days,@Working_Days,@OT_Amount output,@Day_Salary ,@Branch_ID,@M_IT_Tax,Null,@late_Extra_Amount,@Allo_On_Leave

						 
			
				DECLARE @Temp_Allowance NUMERIC(22,0)
				DECLARE @Temp_Deduction NUMERIC(22,0)
				DECLARE @Temp_Allownace_PT NUMERIC(22,0)
				SET @Temp_Allowance=0
				SET @Temp_Deduction=0
				SET @Temp_Allownace_PT = 0
				
				 SELECT @Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL_DAILY  WITH (NOLOCK)     
				   WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
					and AD_ID not in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'')       

                      
				SELECT @Temp_Allowance = SUM(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL_DAILY  WITH (NOLOCK)     
					WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
					and AD_ID  in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0)           

				SET  @Allow_Amount = isnull(@Allow_Amount,0) + isnull(@Temp_Allowance,0)
  
				SELECT @Temp_Allownace_PT = SUM(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL_DAILY WITH (NOLOCK)      
				 WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I' and isnull(M_AD_Not_effect_ON_PT,0) = 1     
					and AD_ID  in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_ON_PT,0) = 1)
	                    
				SELECT @Dedu_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) FRom T0210_MONTHLY_AD_DETAIL_DAILY  WITH (NOLOCK)      
					WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D'      
					and AD_ID not in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and  isnull(AD_Not_effect_salary,0) = 1 OR isnull(Ad_Effect_Month,'')<>'')       
 
				SELECT @Temp_Deduction = SUM(ISNULL(M_AD_AMOUNT,0)) From T0210_MONTHLY_AD_DETAIL_DAILY  WITH (NOLOCK)      
					WHERE TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='D'      
					and AD_ID  in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 0 And Charindex(@Strmonth,Ad_Effect_Month )<> 0)           

				SET @Dedu_Amount = isnull(@Dedu_Amount,0) + isnull(@Temp_Deduction,0)
	
				Select @Bonus_Amount= isnull(Bonus_Amount,0) from T0180_bonus WITH (NOLOCK)  where Emp_Id =@Emp_ID and Bonus_Effect_Month =Month(@Month_End_Date) and Bonus_Effect_Year =Year(@Month_End_Date)
				 --Added by Mukti(09102017)start
				SELECT @Bonus_Amount	 = isnull(Total_Bonus_Amount,0) from dbo.T0100_Bonus_Slabwise WITH (NOLOCK) where Emp_Id =@Emp_ID and Bonus_Effect_Month =Month(@Month_End_Date) and Bonus_Effect_Year =Year(@Month_End_Date) and Bonus_Effect_on_Sal = 1
				--Added by Mukti(09102017)end
	
				Select @Advance_Amount =  round( isnull(Adv_closing,0),0) from T0140_Advance_Transaction WITH (NOLOCK) where emp_id = @emp_id and Cmp_ID = @Cmp_ID    
					and for_date = (select max(for_date) from  T0140_Advance_Transaction WITH (NOLOCK) where emp_id = @emp_id and Cmp_ID = @Cmp_ID    
					and for_date <=  @Month_End_Date)    
     
				IF @Advance_Amount < 0    
					SET @Advance_Amount = 0			
    
				SET @Advance_Amount = isnull(@Advance_Amount,0)  +  @Update_Adv_Amount    
     
            ---No required for daily wages employee---------------------------------
     
			   --Exec SP_CALCULATE_LOAN_PAYMENT @Cmp_ID ,@emp_Id,@Month_End_Date,@Sal_Tran_ID,0,@IS_LOAN_DEDU    
			   

				Select @Loan_Amount = Isnull(sum(Loan_Pay_Amount),0) From T0210_Monthly_Loan_Payment WITH (NOLOCK) where Temp_Sal_Tran_ID = @Sal_Tran_ID    
				SET @Due_Loan_Amount = 0    
     
				SELECT @Due_Loan_Amount = ISNULL(SUM(Loan_Closing),0) FROM T0140_LOAN_TRANSACTION  LT  WITH (NOLOCK) INNER JOIN     
					(SELECT MAX(FOR_DATE) AS FOR_dATE , LOAN_ID ,EMP_ID FROM T0140_LOAN_TRANSACTION  WITH (NOLOCK) WHERE EMP_iD = @EMP_ID AND CMP_ID = @CMP_ID    
						AND FOR_DATE <=@Month_end_Date    
						GROUP BY EMP_id ,LOAN_ID ) AS QRY  ON QRY.LOAN_ID  = LT.LOAN_ID    
						AND QRY.FOR_DATE = LT.FOR_DATE     
						AND QRY.EMP_ID = LT.EMP_ID    
      
				--Exec SP_CALCULATE_CLAIM_PAYMENT @Cmp_ID ,@emp_Id,@Month_End_Date,@Sal_Tran_ID,0,1    
     
				Select @Total_Claim_Amount  = Isnull(sum(Claim_Pay_Amount),0) From T0210_Monthly_Claim_Payment WITH (NOLOCK) where Temp_Sal_Tran_ID = @Sal_Tran_ID    
				DECLARE @Leave_Salary_Amount NUMERIC(22,2) 
  
				
				Exec dbo.P0200_MONTHLY_SALARY_GENERATE_LEAVE 0,@Emp_ID,@Cmp_ID,@Sal_Generate_Date,@Month_St_Date,@Month_end_Date,0,0,0,0,0,0,@Login_ID,'N','N',0,@Month_End_Date,0,@SAL_TRAN_ID
				select @Leave_Salary_Amount = isnull(sum(L_Net_Amount),0) From T0200_Monthly_Salary_Leave WITH (NOLOCK) Where emp_ID =@Emp_ID and month(L_Eff_Date) =month(@Month_End_Date)  and Year(L_Eff_Date) =Year(@Month_End_Date)      
  
			 --
				IF @Is_OT_Inc_Salary =1     
					SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount  + @OT_Amount  + @Bonus_Amount 
				else    
					SET @Gross_Salary = @Salary_Amount + @Allow_Amount + @Other_Allow_Amount + @Total_Claim_Amount   + @Bonus_Amount 
		

	
			  SET @Gross_Salary = @Gross_Salary+ @Leave_Salary_Amount 
     
     
		IF @Gross_Salary < @Revenue_on_Amount  and @Revenue_on_Amount> 0    
			SET @Revenue_Amount = 0    
		    SET @LWF_compare_month = '#'+ CAST(Month(@Month_St_Date)as VARCHAR(2)) + '#'    
     
     
		 IF charindex(@LWF_compare_month,@LWF_App_Month,1) = 0 or @LWF_App_Month =''    
		  Begin    
			 SET @LWF_Amount = 0    
		  End      
    
		 SET @Total_Dedu_Amount = isnull(@Dedu_Amount,0) + isnull(@Other_Dedu_Amount,0) + isnull(@Other_m_it_Amount,0) + isnull(@Advance_Amount,0) + isnull(@Loan_Amount,0)  + @PT_Amount + isnull(@LWF_Amount,0) +  isnull(@Revenue_Amount,0)    
		 SET @Gross_Salary = Round(@Gross_Salary,0)
		 SET @Total_Dedu_Amount = Round(@Total_Dedu_Amount,0)
		 SET @Net_Amount = Round(@Gross_Salary - @Total_Dedu_Amount,0)
		 
	
		Insert into T0200_MONTHLY_SALARY_Daily   
                         (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,     
                         Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,     
                         Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,     
                         Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,     
                         Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, PT_Calculated_Amount, PT_Amount,     
                         Total_Claim_Amount, M_IT_Tax, M_Adv_Amount, M_Loan_Amount, M_OT_Hours, LWF_Amount, Revenue_Amount, PT_F_T_Limit,     
                         Actually_Gross_Salary,Leave_Salary_Amount, Late_Sec, Late_Dedu_Amount, Late_Extra_Dedu_Amount, Late_Days,Salary_Status,Bonus_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount)    
			VALUES (@Sal_Tran_ID,@Sal_Receipt_No,@Emp_ID,@Cmp_ID,@Increment_ID,@Month_St_Date,@Month_St_Date,@Sal_Generate_Date,@Sal_cal_Days,@P_DAys,@Absent_Days,@Holiday_Days,@Weekoff_Days,@Cancel_Holiday,@Cancel_Weekoff,@Working_Days,@Outof_Days,@Total_Leave_Days,@Paid_Leave_Days,@Actual_Working_Hours,@Working_Hours,@Outof_Hours,@Emp_OT_Sec    
                          / 3600,@Total_Hours,@Shift_Day_Sec,@Shift_Day_Hour,@Basic_Salary,@Day_Salary,@Hour_Salary,@Salary_Amount,@Allow_Amount,@OT_Amount,@Other_Allow_Amount,@Gross_Salary,@Dedu_Amount,@Loan_Amount,@Loan_Intrest_Amount,@Advance_Amount,@Other_Dedu_Amount,@Total_Dedu_Amount,@Due_Loan_Amount,@Net_Amount,@PT_Calculated_Amount,@PT_Amount,@Total_Claim_Amount,@M_IT_Tax,@M_ADv_Amount,@M_Loan_Amount,@M_OT_Hours,@LWF_Amount,@REvenue_Amount,@PT_F_T_LIMIT,@Gross_Salary_ProRata,@Leave_Salary_Amount, @Total_Late_Sec, @Late_Dedu_Amount, @Extra_Late_Deduction, @Late_Absent_Day,@Status,@Bonus_Amount,@IT_M_ED_Cess_Amount,@IT_M_Surcharge_Amount)     
            
  
			
		Update T0210_MONTHLY_LEAVE_DETAIL    
				SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
				TEMP_SAL_TRAN_ID = NULL    
        
			WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID    
       
   UPDATE T0210_MONTHLY_AD_DETAIL     
   SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
     TEMP_SAL_TRAN_ID = NULL    
   WHERE EMP_ID = @EMP_ID AND TEMP_SAL_TRAN_ID = @SAL_TRAN_ID    
       
   alter table T0210_MONTHLY_LOAN_PAYMENT Disable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE    
       
   UPDATE T0210_MONTHLY_LOAN_PAYMENT    
   SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID  ,    
     TEMP_SAL_TRAN_ID = NULL    
   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID    
    AND LOAN_APR_ID IN (SELECT LOAN_APR_ID FROM T0120_LOAN_APPROVAL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)    
       
    --Comment By Jaina 28-11-2015  (Trigger is not Created) 
   --alter table T0210_MONTHLY_LOAN_PAYMENT Enable trigger Tri_T0210_MONTHLY_LOAN_PAYMENT_UPDATE    
       
   --alter table T0210_MONTHLY_CLAIM_PAYMENT Disable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE    
       
   UPDATE T0210_MONTHLY_CLAIM_PAYMENT    
   SET SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
     TEMP_SAL_TRAN_ID = NULL    
       
   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID    
    AND CLAIM_APR_ID IN (SELECT CLAIM_APR_ID FROM T0120_CLAIM_APPROVAL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)        
    
   --alter table T0210_MONTHLY_CLAIM_PAYMENT Enable trigger Tri_T0210_MONTHLY_CLAIM_PAYMENT_UPDATE    
       
   UPDATE T0210_PAYSLIP_DATA_DAILY    
   SET  SAL_TRAN_ID = TEMP_SAL_TRAN_ID ,    
     TEMP_SAL_TRAN_ID = NULL    
   WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID    
       
  SET @Month_St_Date = dateadd(d,1,@Month_St_Date)		
  
 End 	
   SET @M_Sal_Tran_ID =@Sal_Tran_ID
     
  
---Nagamills-----------------------------------------
   --IF Monday 1 + tuesday 1.5 + wednes 1.3  =  no of days eligible for incentive is 3 
   -- IF it is >= eligible day then incentive calculate AS  eligible days *  eligible amount
   -- for that u count AS Present days 
   -- Net salary = Sal_Cal_day * Amount + Incentive  
----------------------------------------------------    
--------Calculate Incentive -------------------
     Select @Present_days =Sum(Present_Days) from T0200_Monthly_Salary_Daily WITH (NOLOCK) where emp_id=@Emp_id and Month_St_Date >=@Sal_from and Month_end_Date <=@Sal_To
     Select @Sal_Cal_Days =Sum(Sal_Cal_days) from T0200_Monthly_Salary_Daily WITH (NOLOCK) where emp_id=@Emp_id and Month_St_Date >=@Sal_from and Month_end_Date <=@Sal_To
 
     IF @Present_days >=@Var_Present
	   Begin  		
			Update T0200_Monthly_Salary_Daily
			  SET Other_Allow_Amount = @Var_Present * @var_Amount
			where Sal_Tran_ID = @Sal_Tran_ID and emp_id=@emp_ID 
					
	   End		
--------Calculate Incentive -------------------   
RETURN 
 
    
    

