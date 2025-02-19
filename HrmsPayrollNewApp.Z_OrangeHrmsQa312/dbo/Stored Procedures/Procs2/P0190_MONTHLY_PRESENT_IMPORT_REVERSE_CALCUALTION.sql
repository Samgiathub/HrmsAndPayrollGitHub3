
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_MONTHLY_PRESENT_IMPORT_REVERSE_CALCUALTION]
	@Cmp_ID		numeric ,
	@Emp_Code	varchar(50),
	@Month		int,
	@Year		int,
	@CTC		numeric(18,2)  = 0,
	@Payable_CTC numeric(18,2)  = 0,
	@User_ID	int = 0
AS
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Tran_ID		 numeric
	Declare @Emp_ID			 numeric
	Declare @to_Date		 Datetime
	Declare @From_Date		 Datetime
	declare @payable_days        numeric(18,2)
	Declare @Salary_Cycle_id numeric
	Declare @Salary_St_date	 Datetime
	Declare @Salary_End_date	 Datetime
	declare @OutOf_Days numeric(18,2)
	declare @manual_salary_period numeric 
	declare @P_Days		numeric(18,2)
	declare @Extra_days	numeric(18,2)
	declare @Extra_day_Month	numeric(5)
	declare @Extra_day_Year	numeric(5)
	declare @Cancel_Weekoff_Day Numeric(5,1)
	declare @Cancel_Holiday Numeric(5,1)
	declare @Over_Time Numeric(5,1) 
	--DECLARE @StrHoliday_Date		Varchar(MAX)      
	--DECLARE @StrWeekoff_Date		Varchar(MAX)
	DECLARE @Holiday_Days			Numeric(12,2)      
	DECLARE @Weekoff_Days			Numeric(12,2)           
	--DECLARE @Cancel_Holiday_SP		Numeric(12,2)      
	--DECLARE @Cancel_Weekoff_SP		Numeric(12,2)  
	--DECLARE @Join_Date				Datetime      
	--DECLARE @Left_Date				Datetime   
	declare @Leave_Used				numeric(18,2)     
	
	Declare @M_Leave_Tran_Id as numeric 
	Declare @Leave_ID as numeric 
	Declare @Leave_Days as numeric(18,2)
	Declare @Leave_Type AS VARCHAR(50)
	Declare @Paid_Unpaid AS VARCHAR(5)   
	
	SET @Tran_ID = 0
	SET @Emp_ID	= 0
	SET @to_Date = NULL
	SET @From_Date = NULL
	SET @payable_days = 0
	SET @Salary_Cycle_id = 0
	SET @Salary_St_date = NULL
	SET @Salary_End_date = NULL
	SET @OutOf_Days = 0
	SET @manual_salary_period = 0
	SET @P_Days	= 0
	SET @Extra_days	= 0
	SET @Extra_day_Month = 0
	SET @Extra_day_Year	= 0
	SET @Cancel_Weekoff_Day = 0
	SET @Cancel_Holiday = 0
	SET @Over_Time = 0 
	--SET @StrHoliday_Date = ''  
	--SET @StrWeekoff_Date = ''
	SET @Holiday_Days = 0
	SET @Weekoff_Days = 0
	--SET @Cancel_Holiday_SP	= 0
	--SET @Cancel_Weekoff_SP	= 0
	--SET @Join_Date	= NULL
	--SET @Left_Date	= NULL
	SET @Leave_Used = 0
	
	SET @manual_salary_period = 0
	
	IF @Emp_Code = '' or @Month =0 or @Month > 12 or @Year < 2000
		return

	
	SELECT @Emp_ID = Emp_ID, @Cmp_ID =Cmp_id FROM T0080_Emp_Master e WITH (NOLOCK) WHERE Alpha_Emp_Code = @Emp_Code and Cmp_ID =@Cmp_ID  
	
	SELECT @From_Date = dbo.GET_MONTH_ST_DATE(@Month,@Year)
	SELECT @to_Date = dbo.GET_MONTH_END_DATE(@Month,@Year)

	IF @Emp_ID =0	
		return
		
	SELECT @Salary_Cycle_id = SalDate_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_id = @Emp_ID and Effective_date = (SELECT max(Effective_date) FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Emp_id = @Emp_ID AND Effective_date <= @to_Date)
	
	SELECT @Salary_St_date = Salary_st_date FROM T0040_Salary_Cycle_Master WITH (NOLOCK) WHERE Tran_Id = @Salary_Cycle_id
	
	
	 
	IF IsNull(@Salary_St_date,'') = ''    
	  BEGIN    
		   SET @From_Date  = @From_Date     
		   SET @to_Date = @to_Date    
		  SET @OutOf_Days = DATEDIFF(d,@From_Date,@to_Date) + 1
	  END     
	ELSE IF DAY(@Salary_St_date) =1   
	  BEGIN    
		   SET @From_Date  = @From_Date     
		   SET @to_Date = @to_Date 
		   SET @OutOf_Days = DATEDIFF(d,@From_Date,@to_Date) + 1	         
	  END     
	ELSE IF @Salary_St_date <> ''  and DAY(@Salary_St_date) > 1   
	  BEGIN    
		 
		    IF @manual_salary_period = 0   
				BEGIN
				   SET @Salary_St_date =  CAST(CAST(DAY(@Salary_St_date)AS VARCHAR(5)) + '-' + CAST(DATENAME(mm,DATEADD(m,-1,@From_Date)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(m,-1,@From_Date) )AS VARCHAR(10)) AS SMALLDATETIME)    
				   SET @Salary_End_date = DATEADD(d,-1,DATEADD(m,1,@Salary_St_date)) 
				   SET @OutOf_Days = DATEDIFF(d,@Salary_St_date,@Salary_End_date) + 1
		   
				   SET @From_Date = @Salary_St_date
				   SET @to_date = @Salary_End_date
				END
			ELSE
				BEGIN
					SELECT @Salary_St_date =from_date,@Salary_End_date=end_date FROM salary_period WHERE MONTH= MONTH(@From_Date) and YEAR=YEAR(@From_Date)
					SET @OutOf_Days = DATEDIFF(d,@Salary_St_date,@Salary_End_date) + 1
				   
				    SET @From_Date = @Salary_St_date
				    SET @to_date = @Salary_End_date 
				END    
		END
	
	 
	
		SET @payable_days = IsNull(@Payable_CTC,0) * IsNull(@OutOf_Days,0) / IsNull(@CTC,1)
		
		 
		
		IF @payable_days > IsNull(@OutOf_Days,0)
			SET @payable_days = IsNull(@OutOf_Days,0)
			
			
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
		
		CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

		DECLARE @CONSTRAINT VARCHAR(10)
		SET @CONSTRAINT = CAST(@Emp_ID AS VARCHAR(10))

		EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@From_Date, @TO_DATE=@to_date, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW = 0 	

		SELECT @Weekoff_Days = SUM(W_DAYS) FROM #EMP_WEEKOFF WHERE Emp_ID=@Emp_ID AND Is_Cancel=0
		SELECT @Holiday_Days = SUM(H_DAYS) FROM #EMP_HOLIDAY WHERE Emp_ID=@Emp_ID AND Is_Cancel=0

		SELECT @Cancel_Weekoff_Day = SUM(W_DAYS) FROM #EMP_WEEKOFF WHERE Emp_ID=@Emp_ID AND Is_Cancel=1
		SELECT @Cancel_Holiday = SUM(H_DAYS) FROM #EMP_HOLIDAY WHERE Emp_ID=@Emp_ID AND Is_Cancel=1
	
		--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@to_date,@Join_Date,@left_Date,0,@StrHoliday_Date OUTPUT,@Holiday_days OUTPUT,@Cancel_Holiday_SP OUTPUT,0,0,@StrWeekoff_Date
		--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@to_date,@Join_Date,@left_Date,0,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,@Weekoff_Days OUTPUT ,@Cancel_Weekoff_SP OUTPUT         

        
		
		-- Declare Cur_leave cursor for
		--	SELECT LT.Leave_ID ,Sum(LeavE_Used + Leave_encash_days),Leave_Type,Leave_Paid_Unpaid  FROM T0140_leave_Transaction LT
		--		Inner join T0040_Leave_Master LM on LT.Leave_ID = LM.Leave_ID and (IsNull(eff_in_salary,0) <> 1 
		--				or (IsNull(eff_in_salary,0) = 1 and IsNull(Leave_encash_days,0) <= 0) -- added by mitesh on 02/052012 for leave encashment with leave on same day
		--				or (IsNull(eff_in_salary,0) = 1 and IsNull(Leave_encash_days,0) >= 0 and IsNull(Leave_Used,0) > 0))
		--	WHERE Emp_ID = @Emp_ID and For_Date >=@From_Date and For_Date <=@To_date
		--	Group by Emp_ID,LT.Leave_ID,Leave_Type,Leave_Paid_Unpaid

		--open cur_leave
		--Fetch next FROM Cur_LEave into @Leave_ID ,@Leave_Days,@Leave_Type,@Paid_Unpaid	
		--while @@Fetch_status =0
		--BEGIN
			 
		--	SET @Leave_Used = @Leave_Used + @Leave_Days
				

		--	Fetch next FROM Cur_Leave into @Leave_ID ,@Leave_Days,@Leave_Type,@Paid_Unpaid		
		--END
		--close cur_Leave
		--Deallocate Cur_LEave
		
		
		  
	--IF @CTC > @Payable_CTC
	--	BEGIN
	--		declare @diff_days numeric(18,2)
			
	--		SET @diff_days = 0
			
	--		IF @payable_days < (IsNull(@Holiday_days,0) + IsNull(@Weekoff_Days,0) + IsNull(@Leave_Used,0))
	--			BEGIN
	--				SET @Cancel_Weekoff_Day = 0
	--				SET @diff_days = IsNull(@payable_days,0) - (IsNull(@Holiday_days,0) + IsNull(@Weekoff_Days,0) + IsNull(@Leave_Used,0))
	--				IF @diff_days < 0
	--					BEGIN
	--						IF @diff_days <= @Weekoff_Days
	--							BEGIN	
	--								SET @Cancel_Weekoff_Day = abs(@diff_days)
	--							end
							
	--					end
						
	--				IF @Cancel_Weekoff_Day < 0
	--					BEGIN
	--						SET @Cancel_Weekoff_Day = @Weekoff_Days
	--					end
						
	--				SET @P_Days = 0
	--				SET @Extra_days	= 0
	--				SET @Extra_day_Month = 0
	--				SET @Extra_day_Year	= 0					
	--				SET @Cancel_Holiday = 0
	--				SET @Over_Time = 0 
	--			end
	--		ELSE
	--			BEGIN
	--				SET @P_Days = IsNull(@payable_days,0) - (IsNull(@Holiday_days,0) + IsNull(@Weekoff_Days,0) + IsNull(@Leave_Used,0))
	--				SET @Extra_days	= 0
	--				SET @Extra_day_Month = 0
	--				SET @Extra_day_Year	= 0
	--				SET @Cancel_Weekoff_Day = 0
	--				SET @Cancel_Holiday = 0
	--				SET @Over_Time = 0 
	--		end
	--	end
	--ELSE 
	
	--IF @CTC = @Payable_CTC
	--	BEGIN
			SET @P_Days = IsNull(@payable_days,0) -- - (IsNull(@Holiday_days,0) + IsNull(@Weekoff_Days,0) + IsNull(@Leave_Used,0))
			SET @Extra_days	= 0
			SET @Extra_day_Month = 0
			SET @Extra_day_Year	= 0
			SET @Cancel_Weekoff_Day = 0
			SET @Cancel_Holiday = 0
			SET @Over_Time = 0 
	--	end
	--ELSE IF @CTC < @Payable_CTC
	--	BEGIN
	--		SET @P_Days = IsNull(@OutOf_Days,0) -- - (IsNull(@Holiday_days,0) + IsNull(@Weekoff_Days,0) + IsNull(@Leave_Used,0))
	--		SET @Extra_days	= @payable_days - @OutOf_Days
	--		SET @Extra_day_Month = MONTH(DATEADD(mm,-1,@to_Date))
	--		SET @Extra_day_Year	= YEAR(DATEADD(mm,-1,@to_Date))
	--		SET @Cancel_Weekoff_Day = 0
	--		SET @Cancel_Holiday = 0
	--		SET @Over_Time = 0 
	--	end
		
			----select	@P_Days 
			----SELECT  @Extra_days 
			----SELECT  @Extra_day_Month  
			----SELECT  @Extra_day_Year	 
			----SELECT  @Cancel_Weekoff_Day  
			----SELECT  @Cancel_Holiday  
			----SELECT  @Over_Time
			
	IF @payable_days >= (@Weekoff_Days + @Holiday_Days )
			BEGIN
				SET @payable_days = @payable_days - (@Weekoff_Days + @Holiday_Days)
				SET @P_Days = IsNull(@payable_days,0)
			End
		ELSE
			BEGIN
				SET @Cancel_Holiday = @Holiday_Days
				SET @Cancel_Weekoff_Day = @Weekoff_Days
			End
	  
	IF @payable_days = 0
	   BEGIN
	      SET @Cancel_Holiday = @Holiday_Days
	      SET @Cancel_Weekoff_Day = @Weekoff_Days
	   End
	   
		IF exists (SELECT Emp_ID FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND 
											MONTH =@MONTH AND YEAR =@YEAR )
				BEGIN

					UPDATE    T0190_MONTHLY_PRESENT_IMPORT
					SET       P_Days =@P_Days ,Extra_days =@Extra_days, Extra_Day_Month=@Extra_day_Month, 
								Extra_Day_Year = @Extra_day_Year, Cancel_Weekoff_Day = @Cancel_Weekoff_Day,
								Cancel_Holiday = @Cancel_Holiday,Over_Time=@Over_Time
								,Payble_Amount = @Payable_CTC, User_ID = @User_ID, Time_Stamp =  getdate()
					WHERE	 EMP_ID =@EMP_ID AND
							MONTH =@MONTH AND YEAR =@YEAR 
				
				END
		ELSE
				BEGIN
				
					--SELECT @Tran_ID =IsNull(max(tran_ID),0) +1 FROM T0190_MONTHLY_PRESENT_IMPORT 
					
					INSERT INTO T0190_MONTHLY_PRESENT_IMPORT
						( Emp_ID, Cmp_ID, Month, Year, For_Date, P_days,Extra_days,Extra_Day_Month,Extra_Day_Year,Cancel_Weekoff_Day, Cancel_Holiday,Over_Time,Payble_Amount,User_ID,Time_Stamp)
					VALUES
						( @Emp_ID, @Cmp_ID, @Month, @Year, @to_Date, @P_Days,@Extra_days,@Extra_Day_Month,@Extra_Day_Year,@Cancel_Weekoff_Day,@Cancel_Holiday,@Over_Time,@Payable_CTC,@User_ID,getdate())	
						
				END		
	RETURN




