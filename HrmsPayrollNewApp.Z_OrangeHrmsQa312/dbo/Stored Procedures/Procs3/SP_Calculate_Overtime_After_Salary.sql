

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec SP_Calculate_Overtime_After_Salary @Cmp_id=149,@FROM_DATE='2017-07-01',@TO_DATE='2017-07-31',@BRANCH_ID=0,@CAT_ID=0,@Grade_ID=0,@TYPE_ID=0,@DEPT_ID=0,@DESIG_ID=0,@EMP_ID=0,@CONSTRAINT=''
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Calculate_Overtime_After_Salary]
  @Cmp_id   NUMERIC      
 ,@FROM_DATE  DATETIME
 ,@TO_DATE  DATETIME     
 ,@Branch_ID 	varchar(max)
 ,@Cat_ID 		VARCHAR(MAX) = ''
 ,@Grd_ID 		VARCHAR(MAX) = ''
 ,@Type_ID 		VARCHAR(MAX) = ''
 ,@Dept_ID 		VARCHAR(MAX) = ''
 ,@Desig_ID 		VARCHAR(MAX) = ''
 ,@Vertical_ID		VARCHAR(MAX) = ''
 ,@SubVertical_ID	VARCHAR(MAX) = ''
 ,@Segment_Id VARCHAR(MAX) = ''	
 ,@SubBranch_ID	VARCHAR(MAX) = ''	
 ,@Emp_ID 		numeric = 0
 ,@constraint 	varchar(MAX) = ''
 ,@BasicDA_OT_Salary numeric(18,2) = 0
 ,@Total_Late_OT_Hours numeric(18,2) = 0
 ,@OT_Amount numeric(18,2)=0 output
 ,@WO_OT_Amount numeric(18,2) = 0 output
 ,@HO_OT_Amount numeric(18,2) = 0 output
 ,@Total_OT_Amount numeric(18,2) = 0 output
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	IF @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null
		
	IF @Cat_ID = '0'  or @Cat_ID = '' 
		set @Cat_ID = null

	IF @Grd_ID = '0'  or @Grd_ID = ''
		set @Grd_ID = null

	IF @Type_ID = '0'  or @Type_ID = ''  
		set @Type_ID = null

	IF @Dept_ID = '0'  or @Dept_ID = ''
		set @Dept_ID = null

	IF @Desig_ID = '0' or @Desig_ID = ''  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		

	CREATE TABLE #EMP_CONS 
	(
		EMP_ID	NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC 
	)
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               
	
	
	
	CREATE TABLE #Data         
		(         
		   Emp_Id   numeric ,         
		   For_date datetime,        
		   Duration_in_sec numeric,        
		   Shift_ID numeric ,        
		   Shift_Type numeric ,        
		   Emp_OT  numeric ,        
		   Emp_OT_min_Limit numeric,        
		   Emp_OT_max_Limit numeric,        
		   P_days  numeric(12,3) default 0,        
		   OT_Sec  numeric default 0  ,
		   In_Time datetime,
		   Shift_Start_Time datetime,
		   OT_Start_Time numeric default 0,
		   Shift_Change tinyint default 0,
		   Flag int default 0,
		   Weekoff_OT_Sec  numeric default 0,
		   Holiday_OT_Sec  numeric default 0,
		   Chk_By_Superior numeric default 0,
		   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		   OUT_Time datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	   )    
	   
    
    declare @month_St_Date datetime
    declare @Month_End_Date datetime
    set @month_St_Date =@FROM_DATE
    set @Month_End_Date = @To_Date
    
    declare @For_date datetime
    declare @Working_Sec varchar(10)
    declare @OT_Sec varchar(10)
    declare @Weekoff_OT_Sec varchar(10)
    declare @Holiday_OT_Sec varchar(10)
    declare @P_Days_Count numeric(18,2)
    declare @System_date datetime
    
    declare @Emp_OT				NUMERIC     
	declare @Emp_OT_Min_Limit   VARCHAR(10)    
	declare @Emp_OT_Max_Limit   VARCHAR(10)    
	declare @Emp_OT_Min_Sec     NUMERIC    
	declare @Emp_OT_Max_Sec     NUMERIC    
	declare @Emp_OT_Sec         NUMERIC    
	declare @Emp_OT_Hours       VARCHAR(10)    
	
	declare @Emp_WO_OT_Sec		Numeric --Mitesh 30/11/2011
	declare @Emp_WO_OT_Hours	Varchar(10) --Mitesh 30/11/2011   
	
	declare @Emp_HO_OT_Sec		Numeric --Rathod 15/11/2011
	declare @Emp_HO_OT_Hours	Varchar(10) --Rathod 15/11/2011 
	declare @Basic_Salary			NUMERIC(18, 4)   
	declare @Emp_WD_OT_Rate numeric(5,1)
	declare @Emp_WO_OT_Rate numeric(5,1)
	declare @Emp_HO_OT_Rate numeric(5,1) 
	Declare @Fix_OT_Work_Days  NUMERIC(18, 4)    
	DECLARE @FIX_OT_HOUR_RATE_WD NUMERIC(18,2)  --ADDED BY JAINA 15-03-2017
	SET @FIX_OT_HOUR_RATE_WD = 0
	DECLARE @FIX_OT_HOUR_RATE_WO_HO NUMERIC(18,2) 	--ADDED BY JAINA 15-03-2017
	SET @FIX_OT_HOUR_RATE_WO_HO = 0	
	Declare @Emp_OT_Hours_Var As Varchar(10)--Nikunj
	Declare @Emp_OT_Hours_Num As NUMERIC(18, 4)--Nikunj
	DECLARE @Grade_BasicSalary	NUMERIC(18, 4)

	Declare @Emp_WO_OT_Hours_Var As Varchar(10) --Hardik 29/11/2011
	Declare @Emp_WO_OT_Hours_Num As Numeric(22,3)--Hardik 29/11/2011
	Declare @Emp_HO_OT_Hours_Var As Varchar(10) --Hardik 29/11/2011
	Declare @Emp_HO_OT_Hours_Num As Numeric(22,3)--Hardik 29/11/2011
	declare @IS_ROUNDING AS NUMERIC(1,0)
	declare @Hour_Salary_OT		 NUMERIC(18, 4)
	Declare @Fix_OT_Shift_Sec  Numeric    
	
	Declare @OT_Working_Day	numeric(4,1)
	DECLARE @Grade_BasicSalary_Night	NUMERIC(18,2)
	DECLARE @Gradewise_Salary_Enabled	tinyint    --Added By Ramiz for Mafatlals
	
	Declare @OT_Min_Limit		VARCHAR(20)    
	Declare @OT_Max_Limit		VARCHAR(20)    
	Declare @OT_Min_Sec		NUMERIC    
	Declare @OT_Max_Sec		NUMERIC    
	Declare @Fix_OT_Shift_Hours   VARCHAR(20)
	Declare @Late_Adj_Again_OT NUMERIC(5,0)
	Declare @Is_Late_Mark_Gen  Numeric
	declare @Salary_Cycle_id as numeric
	DECLARE @mid_Deficit_Sec	NUMERIC(18, 0)	
	DECLARE @mid_Deficit_Dedu_Amount	NUMERIC(18, 0)	
	
	
	declare @Day_Salary				NUMERIC(22,5)    
	declare @Increment_Id numeric(18,0) = 0
	declare @SalaryBasis        VARCHAR(20)    
	declare @Wages_Type         VARCHAR(10)    
	declare @Inc_Weekoff			 INT
	declare @Inc_Holiday			 INT
	declare @OutOf_Days			NUMERIC 
	declare @is_salary_cycle_emp_wise as tinyint -- added by mitesh on 03072013           
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime
	declare @manual_salary_period as numeric(18,0)
	Declare @Sal_Fix_Days   numeric(5,2)    
	DECLARE @Salary_Depends_on_Production AS TINYINT
	declare @Sal_cal_Days		NUMERIC(18, 4)    
	Declare @Monthly_Deficit_Adjust_OT_Hrs tinyint --Hardik 11/11/2013 for Pakistan
	DECLARE @CutoffDate_Salary as DATETIME
	declare @Actual_Gross_Salary	NUMERIC(18, 4)    
	declare @Emp_Shift_Sec numeric(18,0)  
	declare @Shift_OT_Rate numeric(18,4)
	DECLARE @WORKING_DAYS_DAY_RATE	NUMERIC(18, 4)
	SET @WORKING_DAYS_DAY_RATE=0; --ADDED BY SUMIT ON 09/11/2016   
	declare @Is_Auto_OT numeric(18,0)
	
	Set @Total_Late_OT_Hours = 0
	Set @Late_Adj_Again_OT = 0
	Set @Is_Late_Mark_Gen = 0
	SET @Gradewise_Salary_Enabled = 0
	set @Fix_OT_Shift_Hours = ''    
	Set @SalaryBasis = ''    
	Set @Day_Salary    = 0   
	Set @Wages_Type  = ''     
	set @Inc_Weekoff = 1 
	set @Inc_Holiday = 1    
	set @OutOf_Days = datediff(d,@Month_St_Date,@Month_End_Date) + 1    
	SET @Sal_St_Date = NULL;
	Set @Salary_Depends_on_Production=0
	Set @Sal_cal_Days  = 0  
	Set @Monthly_Deficit_Adjust_OT_Hrs = 0 
	set @mid_Deficit_Dedu_Amount	= 0	 
	Set @Fix_OT_Shift_Sec = 0
	set @Emp_Shift_Sec = 0
	set @Shift_OT_Rate = 0
	
	CREATE TABLE #OT_Data
	(
		Emp_ID			numeric ,
		Basic_Salary	NUMERIC(18,5),
		Day_Salary		NUMERIC(12,5),
		OT_Sec			numeric,
		Ex_OT_Setting	NUMERIC(18, 4),
		OT_Amount		numeric,
		Shift_Day_Sec	INT,
		OT_Working_Day	NUMERIC(4,1),
		Emp_OT_Hour     NUMERIC(18, 4),
		Hourly_Salary   NUMERIC(18,5) , 
		WO_OT_Sec		Numeric,
		WO_OT_Amount	NUMERIC(22,3),
		WO_OT_Hour		NUMERIC(22,3),
		HO_OT_Sec		Numeric,
		HO_OT_Amount	NUMERIC(22,3),
		HO_OT_Hour		NUMERIC(22,3)
	)    
	
	CREATE TABLE #EMP_OVERTIME
	(
		EMP_ID NUMERIC(18,0),
		OT_W_HOUR NUMERIC(18,4),
		OT_AMOUNT NUMERIC(18,2),
		OT_WO_HOUR NUMERIC(18,4),
		OT_WO_AMOUNT NUMERIC(18,2),
		OT_HO_HOUR NUMERIC(18,4),
		OT_HO_AMOUNT NUMERIC(18,2),
		BASIC_OT_SALARY NUMERIC(18,2),
		WORKING_DAYS NUMERIC(18,2),
		OT_HOUR_RATE NUMERIC(18,4),
		SHIFT_SEC NUMERIC(18,0)
	)
	
	SET @IS_SALARY_CYCLE_EMP_WISE = 0
	SELECT @IS_SALARY_CYCLE_EMP_WISE = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND SETTING_NAME = 'SALARY CYCLE EMPLOYEE WISE'
	
	
	
	DECLARE CUR_OVERTIME CURSOR FOR
		SELECT EMP_ID,BRANCH_ID,INCREMENT_ID FROM #EMP_CONS					
	OPEN CUR_OVERTIME
	FETCH NEXT FROM CUR_OVERTIME  INTO @EMP_ID,@BRANCH_ID,@INCREMENT_ID 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			
			SELECT  @EMP_OT = EMP_OT,@BASIC_SALARY = ISNULL(BASIC_SALARY,0),@SALARYBASIS = SALARY_BASIS_ON , @WAGES_TYPE = WAGES_TYPE,      
							@EMP_OT_MIN_LIMIT = EMP_OT_MIN_LIMIT , @EMP_OT_MAX_LIMIT = EMP_OT_MAX_LIMIT,         
							@BRANCH_ID = BRANCH_ID, 
							@ACTUAL_GROSS_SALARY = ISNULL(GROSS_SALARY,0),   
							@EMP_WD_OT_RATE = ISNULL(EMP_WEEKDAY_OT_RATE,0) , @EMP_WO_OT_RATE = ISNULL(EMP_WEEKOFF_OT_RATE,0) , @EMP_HO_OT_RATE = ISNULL(EMP_HOLIDAY_OT_RATE,0)
							,@FIX_OT_HOUR_RATE_WD = ISNULL(FIX_OT_HOUR_RATE_WD,0)    --ADDED BY JAINA 15-03-2017
							,@FIX_OT_HOUR_RATE_WO_HO = ISNULL(FIX_OT_HOUR_RATE_WO_HO,0) --ADDED BY JAINA 15-03-2017
							,@MONTHLY_DEFICIT_ADJUST_OT_HRS = ISNULL(MONTHLY_DEFICIT_ADJUST_OT_HRS,0)
							,@GRD_ID =I.GRD_ID
			FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN     
							 ( 
								SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK)   
								WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE    
										AND CMP_ID = @CMP_ID AND INCREMENT_TYPE <> 'TRANSFER' AND INCREMENT_TYPE <> 'DEPUTATION'   
								GROUP BY EMP_ID
							  ) QRY ON    
								I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
								WHERE I.EMP_ID = @EMP_ID
			
			SELECT @IS_ROUNDING = ISNULL(AD_ROUNDING,1)
				  ,@INC_WEEKOFF = INC_WEEKOFF
				  ,@INC_HOLIDAY = ISNULL(INC_HOLIDAY,0)
				  ,@FIX_OT_SHIFT_HOURS = OT_FIX_SHIFT_HOURS    					
				  ,@FIX_OT_WORK_DAYS = ISNULL(OT_FIX_WORK_DAY,0)   
				  ,@SAL_FIX_DAYS = SAL_FIX_DAYS
				  ,@OT_MIN_LIMIT = OT_APP_LIMIT ,@OT_MAX_LIMIT = ISNULL(OT_MAX_LIMIT,'00:00')     			
				  ,@LATE_ADJ_AGAIN_OT = ISNULL(LATE_ADJ_AGAIN_OT,0) -- ADDED BY NILESH PATEL ON 03062016
				  ,@IS_LATE_MARK_GEN = IS_LATE_MARK
				  ,@Is_Auto_OT = Is_OT_Auto_Calc
			FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID    
					AND FOR_DATE = ( SELECT MAX(FOR_DATE) 
									 FROM T0040_GENERAL_SETTING WITH (NOLOCK) 
									 WHERE FOR_DATE <=@TO_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID)    
		
			Set @IS_ROUNDING = 1
			
			SELECT  @SALARY_DEPENDS_ON_PRODUCTION = SALARY_DEPENDS_ON_PRODUCTION
			FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @EMP_ID	
						
			DECLARE @ALLOWANCE_AMOUNT NUMERIC(18,2) = 0	
			DECLARE @ALLOWANCE_RATE NUMERIC(18,2) = 0
			DECLARE @WORKING_DAY NUMERIC(18,2) = 0
			DECLARE @SHIFT_DAY_SEC NUMERIC(18,2) = 0
			DECLARE @SETTING_VALUE NUMERIC(18,0) = 0
			
			SELECT @WORKING_DAY = WORKING_DAYS,
				   @SHIFT_DAY_SEC = SHIFT_DAY_SEC,
				   @SAL_CAL_DAYS = SAL_CAL_DAYS
			FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE EMP_ID	= @EMP_ID AND  MONTH(MONTH_END_DATE) = MONTH(@TO_DATE) AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE)
	
			IF @FIX_OT_WORK_DAYS > 0
				SET @SAL_CAL_DAYS = @FIX_OT_WORK_DAYS
			ELSE
				SET @SAL_CAL_DAYS = @SAL_CAL_DAYS
				
			SELECT @SETTING_VALUE = SETTING_VALUE FROM T0040_SETTING WITH (NOLOCK) WHERE SETTING_NAME='AFTER SALARY OVERTIME PAYMENT PROCESS' AND CMP_ID=@CMP_ID
			
			IF @SETTING_VALUE = 1
			BEGIN
				
				IF EXISTS(SELECT EMP_ID FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND  MONTH(MONTH_END_DATE) = MONTH(@TO_DATE) AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE))
				BEGIN
				
						If Isnull(@Monthly_Deficit_Adjust_OT_Hrs,0) = 1 And @SalaryBasis = 'Hour'
						Begin
						
							Exec SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID,@Month_St_Date,@CutoffDate_Salary,@Branch_ID,0,0,0,0,0,@Emp_ID,'','SALARY'
						
							Declare @Hour_Rate_Deficit NUMERIC(18, 4)
							Declare @Actual_OT_Sec NUMERIC(18, 4)
							Declare @Actual_OT_Hours Varchar(10)
							Declare @Shift_Sec_1 NUMERIC(18, 4)
							
							Set @Actual_OT_Sec = 0
							Set @Actual_OT_Hours = ''
							
							Select @mid_Deficit_Sec = Isnull(Actual_Deficit_Sec,0),
								@Shift_Sec_1 = Shift_Sec, @Emp_OT_Sec = Actual_OT_Sec, 
								@Actual_OT_Hours = Actual_OT_Hour
							From ##Salary Where Emp_Id = @Emp_Id

							Set @Hour_Rate_Deficit = 0
							Set @Hour_Rate_Deficit = @Actual_Gross_Salary / (@Shift_Sec_1/3600)
						
							Set @mid_Deficit_Dedu_Amount = (@mid_Deficit_Sec /3600) * @Hour_Rate_Deficit
						End
							
						SELECT @FIX_OT_SHIFT_SEC = DBO.F_RETURN_SEC(ISNULL(@FIX_OT_SHIFT_HOURS,'00:00'))   
				
						IF @IS_SALARY_CYCLE_EMP_WISE = 1
							BEGIN
								
								SET @SALARY_CYCLE_ID  = 0
								
								SELECT	@SALARY_CYCLE_ID = SALDATE_ID 
								FROM	T0095_EMP_SALARY_CYCLE WITH (NOLOCK)
								WHERE	EMP_ID = @EMP_ID 
										AND EFFECTIVE_DATE =(
													SELECT	MAX(EFFECTIVE_DATE) 
													FROM	T0095_EMP_SALARY_CYCLE WITH (NOLOCK)
													WHERE	EMP_ID = @EMP_ID AND EFFECTIVE_DATE <=  @MONTH_END_DATE
															)
								
								SELECT @SAL_ST_DATE = SALARY_ST_DATE FROM T0040_SALARY_CYCLE_MASTER WITH (NOLOCK) WHERE TRAN_ID = @SALARY_CYCLE_ID
								
								---ADDED BY HARDIK 16/08/2016 AS IF SAL CYCLE IS ENABLED FOR USE OF VERTICAL, SUB VERTICAL THEN SALARY DATE 26 IS NOT WORKING
								IF @SAL_ST_DATE IS NULL
									BEGIN
										SELECT	TOP 1 @SAL_ST_DATE  = SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=ISNULL(MANUAL_SALARY_PERIOD ,0) -- COMMENT AND ADDED BY ROHIT ON 11022013																	
										FROM	T0040_GENERAL_SETTING WITH (NOLOCK) 
										WHERE	CMP_ID = @CMP_ID  AND BRANCH_ID = @BRANCH_ID 
										AND FOR_DATE = ( SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
														WHERE FOR_DATE <=@MONTH_END_DATE AND CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID) 
									END					
							END
						ELSE
							BEGIN

										SELECT	@SAL_ST_DATE  =SAL_ST_DATE ,@MANUAL_SALARY_PERIOD=ISNULL(MANUAL_SALARY_PERIOD ,0) -- COMMENT AND ADDED BY ROHIT ON 11022013
										FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
										WHERE	CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID    
												AND FOR_DATE = ( SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE FOR_DATE <=@MONTH_END_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID)    
								
							END	
			
						IF ISNULL(@SAL_ST_DATE,'') = ''    
							BEGIN    
								SET @MONTH_ST_DATE  = @MONTH_ST_DATE     
								SET @MONTH_END_DATE = @MONTH_END_DATE    
								SET @OUTOF_DAYS = @OUTOF_DAYS
							END     
						ELSE IF DAY(@SAL_ST_DATE) =1 --AND MONTH(@SAL_ST_DATE)= 1    
							BEGIN    
								
								SET @MONTH_ST_DATE  = @MONTH_ST_DATE     
								SET @MONTH_END_DATE = @MONTH_END_DATE    
								SET @OUTOF_DAYS = @OUTOF_DAYS    	       
								 
							END     
						ELSE IF @SAL_ST_DATE <> ''  AND DAY(@SAL_ST_DATE) > 1   
							BEGIN    	  
										   
								IF @MANUAL_SALARY_PERIOD = 0 
									BEGIN
										SET @SAL_ST_DATE =  CAST(CAST(DAY(@SAL_ST_DATE)AS VARCHAR(5)) + '-' + CAST(DATENAME(MM,DATEADD(M,-1,@MONTH_ST_DATE)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(M,-1,@MONTH_ST_DATE) )AS VARCHAR(10)) AS SMALLDATETIME)    
										SET @SAL_END_DATE = DATEADD(D,-1,DATEADD(M,1,@SAL_ST_DATE)) 
										SET @OUTOF_DAYS = DATEDIFF(D,@SAL_ST_DATE,@SAL_END_DATE) + 1
								   
										SET @MONTH_ST_DATE = @SAL_ST_DATE
										SET @MONTH_END_DATE = @SAL_END_DATE 
									END 
								ELSE
									BEGIN
										SELECT @SAL_ST_DATE=FROM_DATE,@SAL_END_DATE=END_DATE FROM SALARY_PERIOD WHERE MONTH= MONTH(@MONTH_ST_DATE) AND YEAR=YEAR(@MONTH_ST_DATE)
										SET @OUTOF_DAYS = DATEDIFF(D,@SAL_ST_DATE,@SAL_END_DATE) + 1
									   
										SET @MONTH_ST_DATE = @SAL_ST_DATE
										SET @MONTH_END_DATE = @SAL_END_DATE 
									END   
									-- ENDED BY ROHIT ON 11022013
							  END
				
							IF ISNULL(@SAL_FIX_DAYS,0) > 0    				   
								SET @OUTOF_DAYS = @SAL_FIX_DAYS        
						
						SELECT @Allowance_Amount=sum(E_Ad_Amount)
							FROM (
								SELECT EED.AD_ID,
									
									--Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_Ad_Percentage End As E_AD_Percentage,
									--Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
									 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
										Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
									 Else
										eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
									 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
										Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
									 Else
										eed.e_ad_Amount End As E_Ad_Amount,
									E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
									ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
									ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
									ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
									AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late,
									ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
									ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
									ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
									ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
									ISNULL(ADM.auto_paid,0) as AutoPaid,
									ADM.AD_LEVEL,ADM.is_rounding
								FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
									   dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
										( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
											From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
											( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
												Where Emp_Id = @Emp_Id And For_date <= @to_date
											 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
										) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID  And Qry1.FOR_DATE>=EED.FOR_DATE                
								WHERE EED.EMP_ID = @emp_id AND eed.increment_id = @Increment_Id And Adm.AD_ACTIVE = 1
										and ADM.AD_EFFECT_ON_OT = 1
										And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
								UNION 
								
								SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
									ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
									ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
									ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
									ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY
									,AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
									ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
									ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
									ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
									isnull(ADM.auto_paid,0) as AutoPaid,
									ADM.AD_LEVEL,ADM.is_rounding
								FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
									( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
										Where Emp_Id  = @Emp_Id And For_date <= @to_date 
										Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
								   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
								WHERE emp_id = @emp_id 
										And Adm.AD_ACTIVE = 1
										and ADM.AD_EFFECT_ON_OT = 1
										And EEd.ENTRY_TYPE = 'A'
										AND EED.Increment_ID = @Increment_Id
								) Qry
						
							--select @BASIC_SALARY , ISNULL(@ALLOWANCE_AMOUNT,0)
							
							SET @BASIC_SALARY = @BASIC_SALARY + ISNULL(@ALLOWANCE_AMOUNT,0)
							
							IF @WAGES_TYPE = 'MONTHLY'     
								IF @INC_WEEKOFF = 1    
									BEGIN 
										IF @INC_HOLIDAY = 1
											BEGIN 
												
												SET @DAY_SALARY =  ISNULL(@BASIC_SALARY,0) / ISNULL(@OUTOF_DAYS,0)
												
											END	
										ELSE
											BEGIN
												
												IF (@WORKING_DAY > 0)
													SET @DAY_SALARY =  ISNULL(@BASIC_SALARY,0) / ISNULL(@WORKING_DAY,0) --@WORKING_DAYS CHANGED BY SUMIT ON 9/11/2016
												ELSE
													SET @DAY_SALARY =  0;
												
												SET @OT_WORKING_DAY = @WORKING_DAY
											END
									END   
								ELSE    
									BEGIN
										
										IF ISNULL(@SAL_FIX_DAYS,0) = 0		--SAL FIX DAYS CONDITION ADDED BY RAMIZ ON 24/11/2015
											BEGIN
												IF (@WORKING_DAY > 0)
													BEGIN
													IF @SALARY_DEPENDS_ON_PRODUCTION = 1 AND @SAL_CAL_DAYS > 0
														BEGIN
														  SET @DAY_SALARY =  @BASIC_SALARY / @SAL_CAL_DAYS
														END
													  ELSE
														BEGIN
														   SET @DAY_SALARY =  @BASIC_SALARY / @WORKING_DAY --@WORKING_DAYS 
														END
													END
												ELSE
													BEGIN
														SET @DAY_SALARY =  0
													END
											END
										ELSE
											BEGIN
												SET @DAY_SALARY =  @BASIC_SALARY / @OUTOF_DAYS 
											END
										
									END     
							 ELSE    
								BEGIN
									SET @DAY_SALARY	  =  @BASIC_SALARY    
								END
								
							
							If @SalaryBasis='Fix Hour Rate'--Nikunj 19-04-2011
									Begin			 		
										print 1
										--Set @Hour_Salary = @Day_Salary			 
									End
								Else
									Begin
							
										--Set @Hour_Salary = @Day_Salary * 3600 /@Shift_Day_Sec
											 
										--Added Condition by Hardik 13/11/2013 for Sharp Images, Pakistan
										
										If Isnull(@Monthly_Deficit_Adjust_OT_Hrs,0) = 1 And @SalaryBasis = 'Hour'
											Begin
												
												Set @Hour_Salary_OT = @Hour_Rate_Deficit
												Set @Emp_WO_OT_Sec = 0
												Set @Emp_HO_OT_Sec = 0
												
											End
										else
												Begin
													
													If Isnull(@Fix_OT_Work_Days,0) = 0
														BEGIN
															
															IF ISNULL(@FIX_OT_SHIFT_SEC,0) > 0
																BEGIN
																	SET @HOUR_SALARY_OT = @DAY_SALARY * 3600  /  @FIX_OT_SHIFT_SEC        
																	SET @EMP_SHIFT_SEC = @FIX_OT_SHIFT_SEC 
																END
															ELSE
																BEGIN										
																	SET @HOUR_SALARY_OT = @DAY_SALARY * 3600  /  @SHIFT_DAY_SEC
																	SET @EMP_SHIFT_SEC = @SHIFT_DAY_SEC
																END
														END	
													Else
														BEGIN
															
															IF ISNULL(@FIX_OT_SHIFT_SEC,0) > 0
																BEGIN
																	SET @HOUR_SALARY_OT =  ((@BASIC_SALARY) / @FIX_OT_WORK_DAYS) * 3600  /  @FIX_OT_SHIFT_SEC
																	SET @EMP_SHIFT_SEC = @FIX_OT_SHIFT_SEC 
																END
															ELSE
																BEGIN
																	SET @HOUR_SALARY_OT =  ((@BASIC_SALARY) / @FIX_OT_WORK_DAYS) * 3600  /  @SHIFT_DAY_SEC
																	SET @EMP_SHIFT_SEC = @SHIFT_DAY_SEC
																END
															
														end
													
												End			
										End		 
					
						--SELECT @HRA_Amount = isnull(MAD.M_AD_Amount,0) FROM T0210_MONTHLY_AD_DETAIL MAD inner JOIN
						--		  T0050_AD_MASTER Ad ON Ad.AD_ID = MAD.AD_ID
						--where mad.Emp_ID=@Emp_ID AND Ad.CMP_ID=@Cmp_id  and For_Date =  @from_date	 and Ad.AD_EFFECT_ON_OT = 1
						
						
				
						--select @HRA_Amount,@Working_Day,@SHIFT_DAY_SEC
						set @Allowance_Rate  = ((isnull(@Allowance_Amount,0) / isnull(@Sal_cal_Days,0)) * 3600) / @SHIFT_DAY_SEC
						
						--select @Hour_Salary_OT
						--set @Hour_Salary_OT = (((@Basic_Salary + isnull(@Allowance_Amount,0)) / isnull(@Sal_cal_Days,0)) * 3600) / @SHIFT_DAY_SEC
						if @Fix_OT_Hour_Rate_WD > 0
							set @Fix_OT_Hour_Rate_WD = @Fix_OT_Hour_Rate_WD + @Allowance_Rate
						if @FIX_OT_HOUR_RATE_WO_HO > 0	
							set @FIX_OT_HOUR_RATE_WO_HO = @FIX_OT_HOUR_RATE_WO_HO + @Allowance_Rate
							
						if @Fix_OT_Hour_Rate_WD > 0 or @FIX_OT_HOUR_RATE_WO_HO > 0	
							begin	
								set @Shift_OT_Rate = @Fix_OT_Hour_Rate_WD + @FIX_OT_HOUR_RATE_WO_HO
							end
						else
							begin	
								set @Shift_OT_Rate = @Hour_Salary_OT
							end
					End
					
			end
	
	
			
				--select * from #Data
				--exec P_GET_EMP_INOUT @cmp_id,@From_Date,@To_Date
				if exists (select 1 from T0160_OT_APPROVAL WITH (NOLOCK) where Emp_ID = @Emp_ID and month(For_Date)= month(@To_date) and year(For_Date) <= year(@To_date)) OR @Is_Auto_OT = 1
				BEGIN
					
					if @Is_Auto_OT = 0
						BEGIN
								Select  @Emp_OT_Sec =  ISNULL(Sum(Approved_OT_Sec),0), 
										@Emp_WO_OT_Sec = ISNULL(sum(Approved_WO_OT_Sec),0) ,
										@Emp_HO_OT_Sec =  ISNULL(sum(Approved_HO_OT_Sec),0) 
								From T0160_OT_Approval OT WITH (NOLOCK) inner JOIN #EMP_CONS E on  OT.Emp_ID=E.EMP_ID
								Where OT.Emp_Id=@Emp_Id And Cmp_Id=@Cmp_Id And month(For_Date)= month(@To_date) and year(For_Date) = year(@To_date) 
								and OT.Is_Approved= 1
								--Group By P_days_count								
						END
					else
						BEGIN
								print 56
								exec  SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,4
								
								select @Emp_OT_Sec =  ISNULL(Sum(OT_SEC),0), 
										@Emp_WO_OT_Sec = ISNULL(sum(Weekoff_OT_Sec),0) ,
										@Emp_HO_OT_Sec =  ISNULL(sum(Holiday_OT_Sec),0)  
								from #Data where Emp_Id=@Emp_Id 
								 and month(For_Date)= month(@To_date) and year(For_Date) = year(@To_date)
								
						end
					
					
					IF @EMP_OT = 1    
					Begin  
							
						If @Emp_OT_Sec > 0  and @Emp_OT_Min_Sec > 0 and @Emp_OT_Sec < @Emp_OT_Min_Sec    
							set @Emp_OT_Sec = 0    
						Else If @Emp_OT_Sec > 0 and @Emp_OT_Max_Sec > 0 and @Emp_OT_Sec > @Emp_OT_Max_Sec    
							set @Emp_OT_Sec = @Emp_OT_Max_Sec    
							
						If @Emp_OT_Sec > 0   
						BEGIN 
							--select @Emp_OT_Sec
							Set @Emp_OT_Hours_Var = dbo.F_Return_Hours(@Emp_OT_Sec)    --Nikunj
							Set @Emp_OT_Hours_Var =Replace(@Emp_OT_Hours_Var,':','.')--Nikunj
							set @Emp_OT_Hours_Num = @Emp_OT_Sec/3600 --Added Hardik 06072013
									
								
							if @IS_ROUNDING = 1   --Added by Jaina 15-03-2017
								Begin
										
									if @Fix_OT_Hour_Rate_WD = 0   --Added by Jaina 15-03-2017
											SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Hour_Salary_OT,0) * @Emp_WD_OT_Rate,0)
									else
											SET @OT_Amount = Round(ROUND((@Emp_OT_Hours_Num) * @Fix_OT_Hour_Rate_WD,0) * @Emp_WD_OT_Rate,0) 
								END
							ELSE
								BEGIN
								
									if @Fix_OT_Hour_Rate_WD = 0   
											set @OT_Amount = (@Emp_OT_Hours_Num * @Hour_Salary_OT * @Emp_WD_OT_Rate)     				
										
									else
											set @OT_Amount = (@Emp_OT_Hours_Num * @Fix_OT_Hour_Rate_WD * @Emp_WD_OT_Rate )      													
											
								END		
							--select @Emp_OT_Hours_Num,@Hour_Salary_OT,@Emp_WD_OT_Rate
						END
						
						If @Emp_WO_OT_Sec > 0    
						BEGIN
							SET @Emp_WO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_WO_OT_Sec)
							Set @Emp_WO_OT_Hours_Var = Replace(@Emp_WO_OT_Hours_Var,':','.')
							--Set @Emp_WO_OT_Hours_Num = Convert (Numeric(22,3), @Emp_WO_OT_Hours_Var)
							set @Emp_WO_OT_Hours_Num = @Emp_WO_OT_Sec/3600 --Added Hardik 06072013
							
							if @IS_ROUNDING = 1   --Added by Jaina 15-03-2017
								begin
														
									IF @FIX_OT_HOUR_RATE_WO_HO = 0   --ADDED BY JAINA 15-03-2017
											set @WO_OT_Amount = round(ROUND((@Emp_WO_OT_Hours_Num) * @Hour_Salary_OT,0) * @Emp_WO_OT_Rate ,0)      				
									ELSE
											set @WO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @FIX_OT_HOUR_RATE_WO_HO,0) * @Emp_WO_OT_Rate,0) 
								End
							else
								begin
										
									IF @FIX_OT_HOUR_RATE_WO_HO = 0   --ADDED BY JAINA 15-03-2017
											set @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num * @Hour_Salary_OT )* @Emp_WO_OT_Rate )
									ELSE
											set @WO_OT_Amount = ((@Emp_WO_OT_Hours_Num * @FIX_OT_HOUR_RATE_WO_HO) * @Emp_WO_OT_Rate )      				
								end
							
							
						END	
						
						IF @Emp_HO_OT_Sec > 0    
						BEGIN
							SET @Emp_HO_OT_Hours_Var = dbo.F_Return_Hours(@Emp_HO_OT_Sec)
							Set @Emp_HO_OT_Hours_Var = Replace(@Emp_HO_OT_Hours_Var,':','.')
							--Set @Emp_HO_OT_Hours_Num = Convert (Numeric(22,3), @Emp_HO_OT_Hours_Var)
							set @Emp_HO_OT_Hours_Num = @Emp_HO_OT_Sec/3600 --Added Hardik 06072013
						
							if @IS_ROUNDING = 1  --Added by Jaina 15-03-2017
								begin
						
									if @FIX_OT_HOUR_RATE_WO_HO = 0   --Added by Jaina 15-03-2017
										set @HO_OT_Amount = round(ROUND((@Emp_HO_OT_Hours_Num) * @Hour_Salary_OT,0) * @Emp_HO_OT_Rate,0)      				
									else
										set @HO_OT_Amount = Round(ROUND((@Emp_WO_OT_Hours_Num) * @FIX_OT_HOUR_RATE_WO_HO,0) * @Emp_HO_OT_Rate,0) 	
								
								End
							else
								begin
															
									if @FIX_OT_HOUR_RATE_WO_HO = 0   --Added by Jaina 15-03-2017
										set @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num * @Hour_Salary_OT )* @Emp_HO_OT_Rate)      				
									else
										set @HO_OT_Amount = ((@Emp_HO_OT_Hours_Num * @FIX_OT_HOUR_RATE_WO_HO) * @Emp_HO_OT_Rate )      				
								End
						
						
						END	
					
					END
				END
				--else 
				--	begin
				--		--RAISERROR('Ovetime Approval Is Required',16,2)
				--		return
				--	end
					
					IF @IS_ROUNDING = 1
						begin
							--select @OT_Amount@WO_OT_Amount > 0 or @HO_OT_Amount>0
							IF @OT_Amount>0 or @WO_OT_Amount > 0 or @HO_OT_Amount>0
								insert #Emp_Overtime
								select @EMP_ID,isnull(@Emp_OT_Hours_Num,0),isnull(@OT_Amount,0),isnull(@Emp_WO_OT_Hours_Num,0),isnull(@WO_OT_Amount,0),isnull(@Emp_HO_OT_Hours_Num,0),isnull(@HO_OT_Amount,0),(@Basic_Salary),@Sal_cal_Days,@Shift_OT_Rate,@Emp_Shift_Sec
							
						END
					ELSE
						BEGIN
							IF @OT_Amount>0 or @WO_OT_Amount > 0 or @HO_OT_Amount>0
								insert #Emp_Overtime
								select @EMP_ID,isnull(@Emp_OT_Hours_Num,0),ROUND(isnull(@OT_Amount,0),0),isnull(@Emp_WO_OT_Hours_Num,0),ROUND(isnull(@WO_OT_Amount,0),0),isnull(@Emp_HO_OT_Hours_Num,0),ROUND(isnull(@HO_OT_Amount,0),0),(@Basic_Salary),@Sal_cal_Days,@Shift_OT_Rate,@Emp_Shift_Sec	
						END
								
					set @OT_Amount = 0 
					set @WO_OT_Amount = 0 
					set @HO_OT_Amount = 0
						  
						fetch next from Cur_Overtime  into @EMP_ID,@Branch_Id,@Increment_Id
				end
	
					
	close Cur_Overtime
	deallocate Cur_Overtime
	 
		 select * from #Emp_Overtime
	  

END

