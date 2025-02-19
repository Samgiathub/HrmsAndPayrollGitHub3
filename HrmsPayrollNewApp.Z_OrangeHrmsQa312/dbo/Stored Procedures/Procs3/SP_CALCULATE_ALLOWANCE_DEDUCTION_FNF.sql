
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_ALLOWANCE_DEDUCTION_FNF]                    
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
 declare @M_AD_Amount    numeric(12,5)                    
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
 declare @For_FNF tinyint
             
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
                     
 set @Allowance_Data = ''                    
 set @Deduction_Data = ''                    
 set @PaySlip_Tran_ID = 0  
 set @E_Ad_Amount=0       
 set @AD_CAL_TYPE=''    
 set @AD_EFFECT_FROM=''
 SET @PERFORM_POINTS=0
 set @For_FNF = 1                     
                      
  if isnull(@Sal_Tran_ID,0)   >0                    
   begin                    
    set @Allowance_Data = '<table width="100%" cellpedding="3">'                    
    select @PaySlip_Tran_ID = isnull(max(PaySlip_Tran_ID),0)+ 1 from T0210_PAYSLIP_DATA WITH (NOLOCK)                    
    INSERT INTO T0210_PAYSLIP_DATA                    
           (PaySlip_Tran_ID, Sal_Tran_ID, Cmp_ID, Allowance_Data, Deduction_Data, Temp_Sal_Tran_ID)                    
    VALUES     (@PaySlip_Tran_ID, NULL, @Cmp_ID, @Allowance_Data, @allowance_Data, @Sal_Tran_ID)                                               
   end       
   
  
                     
 declare curAD cursor for                    
  select EFAD.From_Date,EFAD.To_Date,EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
    isnull(AD_NOT_EFFECT_ON_PT,0),Isnull(AD_NOT_EFFECT_SALARY,0),isnull(AD_EFFECT_ON_OT,0),isnull(AD_EFFECT_ON_EXTRA_DAY,0)                     
    ,AD_Name,isnull(AD_effect_on_Late,0) ,isnull(AD_Effect_Month,''),isnull(AD_CAL_TYPE,''),isnull(AD_EFFECT_FROM,'')
  from EMP_FNF_ALLOWANCE_DETAILS EFAD WITH (NOLOCK) inner join  
    T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) on EFAD.Emp_ID=EED.Emp_ID And EFAD.Ad_ID=EED.Ad_ID inner join                    
   T0050_AD_MASTER ADM WITH (NOLOCK) on EEd.AD_ID = ADM.AD_ID                     
   where EED.emp_id = @emp_id and increment_id = @Increment_Id  And isnull(FNF_ID,0)=0                    
  order by AD_LEVEL, E_AD_Flag desc                    
 open curAD                      
  fetch next from curAD into @All_From_Date,@All_To_Date,@AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_Month,@AD_CAL_TYPE,@AD_EFFECT_FROM
               
  while @@fetch_status = 0                    
   begin                       
      
		SELECT  @M_AD_Amount = sum(isnull(M_AD_Amount,0)) + sum(isnull(M_AREAR_AMOUNT,0)) 
		FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID=@Emp_ID And Ad_ID = @Ad_ID
			And To_date >= @All_From_Date And To_date<=@All_To_Date          
    
		--select * from T0210_MONTHLY_AD_DETAIL where Emp_Id=@Emp_ID And Ad_ID=@Ad_ID
		--select @M_AD_Amount	
		SET @M_AD_NOT_EFFECT_SALARY = 0	
			SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)  	
   			
   			
      if @M_AD_Amount is null
		set @M_AD_Amount = 0     
		              
					INSERT INTO T0210_MONTHLY_AD_DETAIL                    
                          (M_AD_Tran_ID, Sal_Tran_ID,Temp_Sal_Tran_ID ,L_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount,                     
                           M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE,M_AD_effect_on_Late,FOR_FNF,To_Date)                    
					VALUES     (@M_AD_Tran_ID, null,@Sal_Tran_ID,@L_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @From_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount,                     
                           @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,0,@M_AD_effect_on_Late,@For_FNF,@To_Date)                    
                     --   select * from T0210_MONTHLY_AD_DETAIL where Emp_Id=@Emp_ID And Ad_ID=@Ad_ID   
                                             
    /* if isnull(@Sal_Tran_ID,0) > 0                    
      begin                    
       set @Deduction_Data  = ''              
       set @Allowance_Data  = ''                    
              
                         
      if @M_AD_Flag ='D'                     
     set @Deduction_Data = '<Tr>  <td width=200> <Font size =1 > ' + @AD_Name + '</Font></td> <td> <Font size =1 > '  +    cast(@M_AD_Amount as varchar(20)) + '</Font></td>'  + '</Tr>'                                     
       else                        
         set @Allowance_Data  = '<Tr> <td width=200> <Font size =1 > ' + @AD_Name + '</Font></td> <td> <Font size =1 > '  +    cast(@M_AD_Amount as varchar(20)) + '</Font></td>'  + '</Tr>'                                     
                   
                  
       UPDATE T0210_PAYSLIP_DATA                     
       SET  Allowance_Data = Allowance_Data + @Allowance_Data,                    
         Deduction_Data = Deduction_Data + @Deduction_Data                    
       WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID                
      end       */                        
     
     Update EMP_FNF_ALLOWANCE_DETAILS  set FNF_ID = @M_AD_Tran_ID where  Emp_ID=@Emp_ID And Ad_ID=@Ad_ID
               
    fetch next from curAD into @All_From_Date,@All_To_Date,@AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_Month,@AD_CAL_TYPE,@AD_EFFECT_FROM
                  
   end                    
 close curAD                    
 deallocate curAD      
                   
 /*  if isnull(@Sal_Tran_ID,0) >0                    
    begin                    
    UPDATE T0210_PAYSLIP_DATA                     
    SET  Allowance_Data = Allowance_Data + '</table>',                    
      Deduction_Data = Deduction_Data + '</table>'                    
    WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID            
   end                    
   */            
   --Select @Deduction_Data
                  
 RETURN                    
                    
                    
                    

