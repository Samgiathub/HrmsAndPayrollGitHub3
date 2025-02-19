



CREATE PROCEDURE [dbo].[SP_CALCULATE_ALLOWANCE_DEDUCTION_FOR_FNF]                    
  @Sal_Tran_ID   NUMERIC, -- Normal Salary Generation                    
  @Emp_Id     Numeric ,                    
  @Cmp_ID     Numeric ,                    
  @Increment_ID   Numeric ,                    
  @From_Date    Datetime,                    
  @To_Date    Datetime,                    
  @Wages_type    varchar(10),                    
  @Basic_Salary   Numeric(25,5),                    
  @Gross_Salary_ProRata Numeric(25,5),                    
  @Salary_Amount   numeric(25,5),                    
  @Present_Days   numeric(12,1),                    
  @numAbsentDays   numeric(12,1) ,                    
  @Leave_Days    numeric(18,1),                    
  @Salary_Cal_Day   numeric(18,1),                    
  @Tot_Salary_Day   numeric(18,1),                    
  @OT_Amount    numeric(18,2) output,                    
  @Day_Salary    numeric(12,5),                    
  @Branch_ID    numeric ,                    
  @IT_TAX_AMOUNT   numeric ,                    
  @L_Sal_Tran_ID   numeric = null ,-- Leave Salary Generation                    
  @late_Extra_Days     numeric(18,1)=0,
  @Allo_On_Leave numeric(18,0)=1                   
AS                    
  SET NOCOUNT ON 
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET ARITHABORT ON                    
                      
                    
 DECLARE @AD_DEF_ID   int                    
 DECLARE @IT_DEF_ID   int                    
 DECLARE @PF_DEF_ID   int                    
 DECLARE @ESIC_DEF_ID  int                     
 Declare @Join_Time_Def_ID int                    
                      
 SET @IT_DEF_ID = 1                    
 SET @PF_DEF_ID = 2                    
 SET @ESIC_DEF_ID = 3                    
 set @Join_Time_Def_ID = 101                    
                      
 declare @AD_ID      numeric                    
 dECLARE  @Late_Mode as varchar(50)                  
 Declare  @Late_Scan as varchar(50)                  
 Declare  @Tmp_amount as numeric(18,2)     
   
               
 declare @M_AD_Percentage   numeric(12,5)                    
 declare @M_AD_Amount    numeric(18,5)                    
 declare @M_AD_Flag     varchar(1)                    
 declare @Max_Upper     numeric(27,5)                    
 Declare @varCalc_On     varchar(50)                    
 Declare @Calc_On_Allow_Dedu   numeric(18,2)                     
 Declare @Other_Allow_Amount   numeric(18,2)  
 Declare @ESIC_Calculate_Amount numeric(18,2)                  
 Declare @M_AD_Actual_Per_Amount  numeric(18,5)                    
 declare @Temp_Percentage numeric(18,5)                    
 Declare @Type    varchar(20)                    
 Declare @M_AD_Tran_ID  numeric                    
 Declare @PF_Limit   numeric                     
 Declare @Emp_Full_Pf  numeric                     
 Declare @ESIC_Limit   numeric                     
 Declare @M_AD_NOT_EFFECT_ON_PT  numeric(1,0)                    
 Declare @M_AD_NOT_EFFECT_SALARY  Numeric(1,0)                    
 Declare @M_AD_EFFECT_ON_OT   Numeric(1,0)                    
 Declare @M_AD_EFFECT_ON_EXTRA_DAY Numeric(1,0)                    
 declare @M_AD_effect_on_Late  int   
 Declare @AD_Effect_Month      varchar(50)     
 Declare @StrMonth varchar(5)          
 --                    
 Declare @PaySlip_Tran_ID   numeric                     
 Declare @Allowance_Data    varchar(8000)                    
 Declare @Deduction_Data    varchar(8000)                    
 Declare @AD_Name     varchar(50)                    
 Declare @Join_Date     Datetime                    
 Declare @OT_Basic_Salary	numeric(18,2)
 Declare @ESIC_Basic_Salary numeric(18,2)
 Declare @Shift_Day_Sec		int
 Declare @OT_Sec			numeric
 Declare @Ex_OT_Setting		numeric(18,1)
 Declare @OT_Working_Day	numeric(4,1)
 Declare @E_Ad_Amount numeric(18,2)
 Declare @AD_CAL_TYPE varchar(10) 
 Declare @AD_EFFECT_FROM varchar(15) 
 DECLARE @PERFORM_POINTS NUMERIC(18,0)
 DECLARE @All_From_Date Datetime
 DECLARE @All_To_Date Datetime
 
 
 Declare @allowance_type as varchar(10)
 Declare @Not_effect_On_salary as numeric(18,2)
 
 declare @For_FNF tinyint
             
 set @allowance_type       =''
 set @Not_effect_On_salary       =0
 set @Calc_On_Allow_Dedu = 0.0                    
 set @Late_Scan=''                
 SET @varCalc_On = ''                    
 set @Late_Scan=''                  
 set @Other_Allow_Amount = 0     
 set @ESIC_Calculate_Amount=0               
 set @Calc_On_Allow_Dedu = 0.0                    
 SET @varCalc_On = ''                    
 set @PF_Limit = 0                    
 set @Emp_Full_Pf =0                     
 set @ESIC_Limit = 0                    
 set @PaySlip_Tran_ID = 0                    
 set @StrMonth = '#' + cast(Month(@To_datE) as varchar(2)) + '#'  
                    
 If @Sal_Tran_ID = 0                    
  set @Sal_Tran_ID = null                    
                     
 If @L_Sal_Tran_ID =0                    
  set @L_Sal_Tran_ID = null                     
                      
 set @M_AD_Actual_Per_Amount = 0.0                    
 set @For_FNF = 1                 
 set @Allowance_Data = ''                    
 set @Deduction_Data = ''                    
 set @PaySlip_Tran_ID = 0  
 set @E_Ad_Amount=0       
 set @AD_CAL_TYPE=''    
 set @AD_EFFECT_FROM=''
 SET @PERFORM_POINTS=0
 DECLARE @GPF_DEF_ID	INT	
 SET @GPF_DEF_ID = 14
                      
  --if isnull(@Sal_Tran_ID,0)   >0                    
  -- begin                    
  --  set @Allowance_Data = '<table width="100%" cellpedding="3">'                    
  --  select @PaySlip_Tran_ID = isnull(max(PaySlip_Tran_ID),0)+ 1 from T0210_PAYSLIP_DATA                     
  --  INSERT INTO T0210_PAYSLIP_DATA                    
  --         (PaySlip_Tran_ID, Sal_Tran_ID, Cmp_ID, Allowance_Data, Deduction_Data, Temp_Sal_Tran_ID)                    
  --  VALUES     (@PaySlip_Tran_ID, NULL, @Cmp_ID, @Allowance_Data, @allowance_Data, @Sal_Tran_ID)                                               
  -- end                    
  
  

 declare curAD cursor for                    
 select FFA.AD_Id,ffA.AD_Flag,FFA.Amount,AD_PERCENTAGE,  AD_NOT_EFFECT_ON_PT, AD_NOT_EFFECT_SALARY, AD_EFFECT_ON_OT, AD_EFFECT_ON_EXTRA_DAY, 
AD_EFFECT_ON_LATE,  FOR_FNF, ADM.Allowance_Type, ADM.AD_NOT_EFFECT_SALARY  from EMP_FOR_FNF_ALLOWANCE FFA inner join                    
T0050_AD_MASTER ADM WITH (NOLOCK) on FFA.AD_ID = ADM.AD_ID                     
where Emp_id = @Emp_Id and Month(For_Date) = Month(@To_Date) and Year(For_Date) = Year(@To_Date) --and For_Date = @From_Date             ---Condition changed by Hardik 25/03/2016 for BMA
 open curAD                      
  fetch next from curAD into @AD_ID,@M_AD_Flag,@M_AD_Amount,@M_AD_Percentage,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,
							@M_AD_EFFECT_ON_EXTRA_DAY ,@M_AD_effect_on_Late,@For_FNF,@allowance_type,@Not_effect_On_salary
               
  while @@fetch_status = 0                    
   begin                       
      
      --select @For_FNF
		SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)  	
		
     IF (@allowance_type ='R' and @Not_effect_On_salary = 1)
      BEGIN
        SET @M_AD_NOT_EFFECT_SALARY = 0                     
      END
      
      IF @Allowance_type = 'R' OR @AD_DEF_ID  = @GPF_DEF_ID -- Ankit 29032016
		ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  ENABLE TRIGGER Tri_T0210_MONTHLY_AD_DETAIL
	  ELSE
		ALTER TABLE dbo.T0210_MONTHLY_AD_DETAIL  DISABLE TRIGGER Tri_T0210_MONTHLY_AD_DETAIL
   			
      if @M_AD_Amount is null
		set @M_AD_Amount =0   
		
		
		              
					INSERT INTO T0210_MONTHLY_AD_DETAIL                    
                          (M_AD_Tran_ID, Sal_Tran_ID,Temp_Sal_Tran_ID ,L_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount,                     
                           M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE,M_AD_effect_on_Late,FOR_FNF,To_Date)                    
					VALUES     (@M_AD_Tran_ID, null,@Sal_Tran_ID,@L_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @From_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount,                     
                           @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,0,@M_AD_effect_on_Late,@For_FNF,@To_Date)                    
                     
      
    fetch next from curAD into @AD_ID,@M_AD_Flag,@M_AD_Amount,@M_AD_Percentage,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,
    @M_AD_EFFECT_ON_EXTRA_DAY ,@M_AD_effect_on_Late,@For_FNF,@allowance_type,@Not_effect_On_salary
                  
   end                    
 close curAD                    
 deallocate curAD 
 
 
  --select * from T0210_Monthly_AD_Detail where emp_id=2848 and for_Date='2014-08-01 00:00:00' and ad_ID=235     
                   
 RETURN                    
                    
                    
                    

