




-----------------------------------------------------
--ALTER BY:
--Modified By :
--Description:
--Notes :  Please dont put the Select @allowanc like that...
--Late Modified and Review Please Put Comments
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--------------------------------------------------------
CREATE PROCEDURE [dbo].[SP_CALCULATE_ALLOWANCE_DEDUCTION_Telemart]                    
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
  @Allo_On_Leave numeric(18,0)=1,    
  @Out_Of_Days  numeric(18,0)=0 , 
  @Areas_dAYS NUMERIC(18,2) =0                        
AS                    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
                      
       
 DECLARE @AD_DEF_ID   int                    
 DECLARE @IT_DEF_ID   int                    
 DECLARE @PF_DEF_ID   int                    
 DECLARE @ESIC_DEF_ID  int                     
 DECLARE @Join_Time_Def_ID int                    
                      
 SET @IT_DEF_ID = 1                    
 SET @PF_DEF_ID = 2                    
 SET @ESIC_DEF_ID = 3                    
 set @Join_Time_Def_ID = 101                    
                      
 DECLARE @AD_ID      numeric                    
 DECLARE  @Late_Mode as varchar(50)                  
 DECLARE  @Late_Scan as varchar(50)                  
 DECLARE  @Tmp_amount as numeric(18,2)  
 DECLARE @P_Days as numeric(18,2)
 --DECLARE @Out_Of_Days as numeric(18,2)   
 SET @P_Days= 0
 --SET @Out_Of_Days=0
   
               
 DECLARE @M_AD_Percentage   numeric(12,5)                    
 DECLARE @M_AD_Amount    numeric(12,5)                    
 DECLARE @M_AD_Flag     varchar(1)                    
 DECLARE @Max_Upper     numeric(27,5)                    
 DECLARE @varCalc_On     varchar(50)                    
 DECLARE @Calc_On_Allow_Dedu   numeric(18,2)                     
 DECLARE @Other_Allow_Amount   numeric(18,2)  
 DECLARE @ESIC_Calculate_Amount numeric(18,2)                  
 DECLARE @M_AD_Actual_Per_Amount  numeric(18,5)                    
 DECLARE @Temp_Percentage numeric(18,5)                    
 DECLARE @Type    varchar(20)                    
 DECLARE @M_AD_Tran_ID  numeric                    
 DECLARE @PF_Limit   numeric                     
 DECLARE @Emp_Full_Pf  numeric                     
 DECLARE @ESIC_Limit   numeric                     
 DECLARE @M_AD_NOT_EFFECT_ON_PT  numeric(1,0)                    
 DECLARE @M_AD_NOT_EFFECT_SALARY  Numeric(1,0)                    
 DECLARE @M_AD_EFFECT_ON_OT   Numeric(1,0)                    
 DECLARE @M_AD_EFFECT_ON_EXTRA_DAY Numeric(1,0)                    
 DECLARE @M_AD_effect_on_Late  int   
 DECLARE @AD_Effect_Month      varchar(50)     
 DECLARE @StrMonth varchar(5)          
 --                    
 DECLARE @PaySlip_Tran_ID   numeric                     
 DECLARE @Allowance_Data    varchar(8000)                    
 DECLARE @Deduction_Data    varchar(8000)                    
 DECLARE @AD_Name     varchar(50)                    
 DECLARE @Join_Date     Datetime                    
 DECLARE @OT_Basic_Salary	numeric(18,2)
 DECLARE @ESIC_Basic_Salary numeric(18,2)
 DECLARE @Shift_Day_Sec		int
 DECLARE @OT_Sec			numeric
 DECLARE @Ex_OT_Setting		numeric(18,2)
 DECLARE @OT_Working_Day	numeric(4,1)
 DECLARE @E_Ad_Amount numeric(18,2)
 DECLARE @AD_CAL_TYPE varchar(10) 
 DECLARE @AD_EFFECT_FROM varchar(15) 
 DECLARE @PERFORM_POINTS NUMERIC(18,2)
 DECLARE @Gr_Salary as numeric(18,2)
 DECLARE @Emp_Ot_Hours Numeric(18,2)
 DECLARE @Hourly_Salary Numeric(18,5)
 
 Declare @IS_NOT_EFFECT_ON_LWP numeric(1,0) 
 Declare @Salary_Cal_Day_LWP numeric(12,1)
 Declare @Salary_Amount_LWP numeric(25,5)
 
             
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
 set @Gr_Salary =0
 
 set @IS_NOT_EFFECT_ON_LWP = 0 
 set @Salary_Cal_Day_LWP = @Salary_Cal_Day
 set @Salary_Amount_LWP = @Salary_Amount
               
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
 SET @PERFORM_POINTS=0.00
 
 
 
 Select  @OT_Basic_Salary = Basic_salary,@Day_Salary = Day_Salary,@OT_Sec=OT_Sec,@Ex_OT_Setting =Ex_OT_Setting ,@Shift_Day_Sec = Shift_Day_Sec 
	,@OT_Working_Day = OT_Working_Day ,@Emp_Ot_Hours=Emp_OT_Hour,@Hourly_Salary=Hourly_Salary 
 from #OT_DATA
       
   -- set @ESIC_Basic_Salary = @OT_Basic_Salary 
    set @ESIC_Basic_Salary = @Basic_Salary	      
    
    
  SELECT @PF_Limit = PF_Limit  ,@ESIC_Limit = ISNULL(ESIC_Upper_Limit,0)                    
  FROM dbo.T0040_GENERAL_SETTING g WITH (NOLOCK) INNER JOIN T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID                    
  WHERE g.cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                    
  AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date AND Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)                    
                     
  select @Emp_Full_Pf = isnull(Emp_Full_Pf,0),@Gr_Salary = Gross_salary from dbo.T0095_Increment WITH (NOLOCK) where increment_id = @Increment_ID                    
                    
  select @Join_Date = Date_of_join From dbo.t0080_emp_master WITH (NOLOCK) where emp_ID =@Emp_ID                    
                      
  
  DEclare @Unpaid_Leave numeric(12,1) 
    SELECT @Unpaid_Leave = isnull(sum(leave_Days),0) from dbo.T0210_Monthly_LEave_Detail WITH (NOLOCK) where Emp_ID = @emp_ID and       
					TEMP_SAL_TRAN_ID = @Sal_Tran_ID and Leave_Paid_Unpaid = 'U'
                    
  if @PF_Limit = 0                    
   set @PF_Limit = 6500                    
                      
                      
  if isnull(@Sal_Tran_ID,0)   >0                    
   begin                    
    set @Allowance_Data = '<table width="100%" cellpedding="3">'                    
    select @PaySlip_Tran_ID = isnull(max(PaySlip_Tran_ID),0)+ 1 from dbo.T0210_PAYSLIP_DATA WITH (NOLOCK)
    INSERT INTO dbo.T0210_PAYSLIP_DATA                    
           (PaySlip_Tran_ID, Sal_Tran_ID, Cmp_ID, Allowance_Data, Deduction_Data, Temp_Sal_Tran_ID)               
    VALUES     (@PaySlip_Tran_ID, NULL, @Cmp_ID, @Allowance_Data, @allowance_Data, @Sal_Tran_ID)                                               
   end                    
                     
 declare curAD cursor for                    
  select EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
    isnull(AD_NOT_EFFECT_ON_PT,0),Isnull(AD_NOT_EFFECT_SALARY,0),isnull(AD_EFFECT_ON_OT,0),isnull(AD_EFFECT_ON_EXTRA_DAY,0)                     
    ,AD_Name,isnull(AD_effect_on_Late,0) ,isnull(AD_Effect_Month,''),isnull(AD_CAL_TYPE,''),isnull(AD_EFFECT_FROM,''),isnull(ADM.AD_NOT_EFFECT_ON_LWP,0)
  From dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join                    
   dbo.T0050_AD_MASTER ADM WITH (NOLOCK) on EEd.AD_ID = ADM.AD_ID                     
   where emp_id = @emp_id and increment_id = @Increment_Id 
  order by AD_LEVEL, E_AD_Flag desc                    
 open curAD                      
  fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,
  @M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_Month,@AD_CAL_TYPE,
  @AD_EFFECT_FROM,@IS_NOT_EFFECT_ON_LWP
               
  while @@fetch_status = 0                    
   begin                    
       
    
   set @E_Ad_Amount = @M_AD_Amount             
    set @Tmp_amount = 0  
      Declare @Allow_Amount numeric(22,2)
				set @Allow_Amount=0
    
    --- Changes done for EFFECT On LWP by Falak on 06-jan-2010
   If @IS_NOT_EFFECT_ON_LWP = 1
    begin
				
		set @Salary_Cal_Day = @Salary_Cal_Day_LWP 
		set @Salary_Amount  = @Salary_Amount_LWP  
		set @Salary_Cal_Day = @Salary_Cal_Day + @Unpaid_Leave
		if @Salary_cal_Day > @Tot_Salary_Day
			set @Salary_Cal_Day = @Tot_Salary_Day 
		set @Salary_Amount   = Round((@Basic_Salary  * @Salary_Cal_Day )/ @Tot_Salary_Day,0)
		--set @Salary_Cal_Day = @Salary_Cal_Day_LWP
		--set @Salary_Amount = @Basic_Salary_LWP		
    end
    else
    begin		
		set @Salary_Amount = @Salary_Amount_LWP
		set @Salary_Cal_Day = @Salary_Cal_Day_LWP  				
    end		
    
                     
    IF @varCalc_On ='Gross Salary'                     
		BEGIN	
				If @AD_Def_ID=3 
					Begin					
					
							SELECT @Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) From dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
						WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
						--AND AD_ID in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and Ad_Calculate_On='Transfer OT' or Ad_def_Id=5)       
						AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1) --Changed by Falak on 02-MAY-2011
						--SET @Calc_On_Allow_Dedu = @Gross_Salary_ProRata + ISNULL(@Allow_Amount,0)--chanegd By Nikunj 22-03-2011 because For ESIC Calculation OT Must be there												
						SET @Calc_On_Allow_Dedu = @Salary_Amount  + ISNULL(@Allow_Amount,0)--Changed Falak on 02-MAY-2011
					End					
				Else
					Begin
						SET @Calc_On_Allow_Dedu = @Gross_Salary_ProRata --Changed by Falak on 16-Mar-2011 for telemart
				    End
				
    	END	
    ELSE IF @varCalc_On ='Arrears'  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
    	 BEGIN
    			SELECT @Allow_Amount = SUM(ISNULL(M_AD_AMOUNT,0)) From dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)      
				WHERE Temp_Sal_Tran_ID = @Sal_Tran_ID and Emp_ID = @Emp_ID and m_AD_Flag ='I'      
				AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and isnull(AD_Not_effect_salary,0) = 1)       																
				
			 SET @Out_Of_Days = datediff(d,@From_Date,@To_Date) + 1      
	         DECLARE @Gr_Days as numeric(18,2)
			 DECLARE @Gr_Salary_amount as  numeric(18,2)
			 SET @Gr_Days =0
			 SET @Gr_Salary_amount =0			 
			 SELECT @Gr_Salary_amount = Gross_salary,@Salary_Amount= Basic_Salary from dbo.T0095_Increment WITH (NOLOCK) where increment_id = @Increment_ID     			 
			 SET   @Gr_Salary_amount = Round(@Gr_Salary_amount * @Salary_Cal_Day/@Out_Of_Days,0) 
			 SET   @Salary_Amount =  ROUND(@Salary_Amount * @Salary_Cal_Day /@Out_Of_Days ,0)
			 SET   @Basic_Salary =  @Salary_Amount
			 SET   @Calc_On_Allow_Dedu = Round(@Gr_Salary_amount - (@Basic_Salary  + @Allow_Amount),0)
			 SET   @M_AD_Amount =@Calc_On_Allow_Dedu				 			  
    	 END    	 
    ELSE IF @varCalc_On ='Basic Salary'  
		SET @Calc_On_Allow_Dedu = @Salary_Amount            
    ELSE  
		BEGIN
			SET @Calc_On_Allow_Dedu = @Basic_Salary                    
		END  
  
    IF @M_AD_Percentage > 0                     
		SET @M_AD_Actual_Per_Amount = @M_AD_Percentage                    
    ELSE                   
		SET @M_AD_Actual_Per_Amount = @M_AD_Amount                    
          
    SET @Other_Allow_Amount = 0         
    SET @ESIC_Calculate_Amount=0           
                        
    SELECT @Other_Allow_Amount = ISNULL(SUM(M_AD_amount),0)  FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
    WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID                     
		 AND For_Date >=@From_Date AND For_Date <=@To_Date                
		 AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
		 AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
		 AND AD_ID IN                     
    (SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER WITH (NOLOCK)                    
    WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)  
    
       
        
    SELECT @ESIC_Calculate_Amount = ISNULL(SUM(E_AD_amount),0)  FROM  dbo.T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
    WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID                     
    --and For_Date >=@From_Date and For_Date <=@To_Date                
	AND Increment_Id = @Increment_Id
    AND AD_ID IN                     
    (SELECT AD_ID  FROM  dbo.T0060_EFFECT_AD_MASTER  WITH (NOLOCK) WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)                    
    
   SET @Calc_On_Allow_Dedu = ISNULL(@Calc_On_Allow_Dedu,0) + ISNULL(@Other_Allow_Amount ,0)  
   IF @varCalc_On <>'Gross Salary'    
		SET @ESIC_Basic_Salary = ISNULL(@ESIC_Basic_Salary,0) + ISNULL(@ESIC_Calculate_Amount,0)     
	----------------------------For ESIC range Calcuation from april to september as per Govt. ------------------------     	
    DECLARE @sal_tran_id1 NUMERIC(18,0)  
    SET  @sal_tran_id1=0           
     IF MONTH(@From_Date)> 4 AND MONTH(@From_Date)< = 9 AND @AD_DEF_ID=3
		BEGIN
			SELECT @sal_tran_id1=M_AD_tran_id FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN  dbo.T0050_AD_MASTER am WITH (NOLOCK)
			ON MAD.ad_id= am.ad_id
			WHERE emp_id=@emp_id AND MAD.cmp_id=@cmp_id	AND YEAR(@From_Date)=YEAR(MAD.for_date) 
			AND MONTH(MAD.for_date) > 4 AND MONTH(MAD.for_date) <= 9 AND ad_def_id=3 AND M_Ad_amount>0
		END
	IF 	MONTH(@From_Date)>= 10 AND MONTH(@From_Date)< = 12 AND @AD_DEF_ID=3
		begin 
			select @sal_tran_id1=M_AD_tran_id from dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join dbo.T0050_AD_MASTER am WITH (NOLOCK)
			on MAD.ad_id= am.ad_id
			where emp_id=@emp_id and MAD.cmp_id=@cmp_id	and year(@From_Date)=year(MAD.for_date) 
			and month(MAD.for_date)>=10 and month(MAD.for_date)<= 12 and ad_def_id=3 and M_Ad_amount>0
		end
	if	month(@From_Date)>= 1 and month(@From_Date)< = 3 and @AD_DEF_ID=3
	begin 
			select @sal_tran_id1=M_AD_tran_id from dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join dbo.T0050_AD_MASTER am WITH (NOLOCK)
			on MAD.ad_id= am.ad_id
			where emp_id=@emp_id and MAD.cmp_id=@cmp_id	and  month(for_date)>=1 and month(MAD.for_date)<= 3 and M_Ad_amount>0
			and year(@From_Date)=year(MAD.for_date) and ad_def_id=3-- or year(@From_Date)-1=year(for_date)
			if month(@From_Date)= 1
				begin
					select @sal_tran_id1=M_AD_tran_id from dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join dbo.T0050_AD_MASTER am WITH (NOLOCK)
					on MAD.ad_id= am.ad_id
					where emp_id=@emp_id and MAD.cmp_id=@cmp_id	and  month(MAD.for_date)>=10 and month(MAD.for_date)<= 12
					and year(@From_Date)-1=year(MAD.for_date) and ad_def_id=3 and M_Ad_amount>0
				End
		end
	----------------------------For ESIC range Calcuation from april to september as per Govt. ------------------------     	
    If @varCalc_On = 'Transfer OT'                     
      Begin  
			Declare @T_amt numeric
				Set @T_amt=0
				--by Falak on 23/12/2010		
			select @T_amt = ISNULL(SUM(M_AD_amount),0)  FROM dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND For_Date >=@From_Date AND For_Date <=@To_Date                
				AND ISNULL(Temp_Sal_Tran_ID,0) = ISNULL(@Sal_Tran_ID,ISNULL(Temp_Sal_Tran_ID,0))                    
				AND ISNULL(L_Sal_Tran_ID,0) = ISNULL(@L_Sal_Tran_ID,ISNULL(L_Sal_Tran_ID,0))                    
				AND AD_ID IN (SELECT AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID)
				--select @OT_Basic_Salary,@OT_Working_Day,@Shift_Day_Sec,@Hourly_Salary				
				set @T_Amt =  Round(@OT_Sec * ((@T_Amt /@OT_Working_Day) /@Shift_Day_Sec),0)
				--select @T_amt As T_AMt
				--set @T_Amt = Round(@Emp_Ot_Hours*Round(((@T_Amt/@OT_Working_Day)*3600)/@Shift_Day_Sec,0),0)
				--set @T_Amt = Round(@OT_Sec * ((@T_Amt /@OT_Working_Day) /@Shift_Day_Sec),0)
				--select @T_amt,@OT_Sec--,@Hourly_Salary,@Ex_OT_Setting
			Set @varCalc_On ='FIX'  
			If @Wages_type ='Monthly'
			   Begin
			   		If @OT_Working_Day <> 0 and @Shift_Day_Sec <> 0
			  			Begin			
			  				set @OT_Amount = Round(@OT_Sec * (@OT_Basic_Salary /@OT_Working_Day) /@Shift_Day_Sec,0)			  			
			  				--Set @OT_Amount =  Round(@Emp_Ot_Hours*Round(@Hourly_Salary,0),0)
			  				--select @OT_Amount,@Emp_Ot_Hours
			  				set @OT_Amount = @OT_Amount + @T_amt
			  				Set @OT_Amount = @OT_Amount + @OT_Amount * @Ex_OT_Setting                            					
			    			Set @M_AD_Amount = @OT_Amount     					
			   				Set @OT_Amount = 0      
			   			End
		       End
			Else
				Begin
					Set @OT_Amount = Round(@OT_Sec * (@OT_Basic_Salary) /@Shift_Day_Sec,0)
					set @OT_Amount = @OT_Amount + @T_amt 
					Set @OT_Amount = @OT_Amount + @OT_Amount * @Ex_OT_Setting					                           
					Set @M_AD_Amount = @OT_Amount     
					Set @OT_Amount = 0                    
				End				       
      End                        
             
 Else if @varCalc_On='Late'                      
	Begin  
		select @Tmp_amount = Limit,@Late_Mode=late_Mode,@Late_Scan=Calculate_On from dbo.T0040_Late_Extra_Amount WITH (NOLOCK)
			 where CMP_ID = @CMP_ID                    
					and  @late_Extra_Days >= from_Days and @late_Extra_Days <=To_days                    
					and Allowance_ID =@AD_ID    
      
    if @Late_Mode ='%'  
		begin  
			set @M_AD_Amount = Round(@M_AD_Amount * @Tmp_amount /100,0)  
		end  
    else  
		begin  
			set @M_AD_Amount = @Tmp_amount  
		end  
  End 
   
 Else if @varCalc_On='Leave Senario'  
	Begin
	if @Allo_On_Leave = 1
		Begin
				DEclare	@Total_Leave_Days numeric(18,1)
				Declare @Leave_Type varchar(10)
				
					select @Leave_Type=Leave_Type from dbo.T0050_AD_MASTER WITH (NOLOCK) where AD_ID=@AD_ID  
				
					if @Leave_Type='Paid'
						set @Leave_Type='P'
					if 	@Leave_Type='UnPaid'
						set @Leave_Type='U'
					if 	@Leave_Type='Both'
						set @Leave_Type='B'
						
						if 	@Leave_Type <> 'B'
							BEgin
								-- Changed By Gadriwala Muslim 02102014
								select @Total_Leave_Days = isnull(sum(leave_used),0) + ISNULL(sum(CompOff_Used),0) from dbo.T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
								and For_Date >=@From_Date and For_Date <=@To_date and Leave_ID in 
								(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type <> 'Company Purpose' And Leave_Paid_Unpaid=@Leave_Type)
							End
						else
							BEgin -- Changed By Gadriwala Muslim 02102014
								select @Total_Leave_Days = isnull(sum(leave_used),0) + ISNULL(sum(CompOff_Used),0) from dbo.T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
								and For_Date >=@From_Date and For_Date <=@To_date and Leave_ID in 
								(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type <> 'Company Purpose' )
							End	
							
							select @Tmp_amount = Limit,@Late_Mode=late_Mode,@Late_Scan=Calculate_On from dbo.T0040_Late_Extra_Amount  WITH (NOLOCK)                  
								   where CMP_ID = @CMP_ID                    
							and  @Total_Leave_Days >= from_Days and @Total_Leave_Days <=To_days                    
							and Allowance_ID =@AD_ID  And Limit>0
							
					
					if @From_Date < @Join_Date  And @To_Date >= @Join_Date
						BEgin
						
							if @Late_Mode ='%'  
								begin  
									set @M_AD_Amount = Round(@M_AD_Amount * @Tmp_amount /100,0) 
									set @M_AD_Amount=(@M_AD_Amount/@Tot_Salary_Day)*@Salary_Cal_Day
									
								end  
							else  
								BEgin
									--select @Tot_Salary_Day,@Salary_Cal_Day
									set @M_AD_Amount = @Tmp_amount 
									set @M_AD_Amount=(@M_AD_Amount/@Tot_Salary_Day)*@Salary_Cal_Day
									 
								End
						End		
					else
						BEgin
							if @Late_Mode ='%'  
								begin  
									set @M_AD_Amount = Round(@M_AD_Amount * @Tmp_amount /100,0)  
								end  
							else  
								begin  
									set @M_AD_Amount = @Tmp_amount  
								end  			
						End
					End	
		End		
	
Else if @varCalc_On='Bonus' 
	BEgin
		 set @M_AD_Amount=0
			DEclare @Yearly_Bonus_Amount numeric(22,2)
			set @Yearly_Bonus_Amount =0
			select @Yearly_Bonus_Amount = isnull(Yearly_Bonus_Amount,0) from dbo.T0095_Increment WITH (NOLOCK) where Increment_Id=@Increment_Id
		IF ISNULL(@Yearly_Bonus_Amount,0) > 0
			Begin
			if @Ad_EFFECT_FROM = 'Joining'
				Begin 
							Declare @Eff_Month as numeric 
							Declare @Eff_Year as numeric
							set @Eff_Month = month(@Join_Date)
							set @Eff_Year=year(Dateadd(yy,0,@From_Date))
							if  @M_AD_Percentage >0  
								Begin
									set  @M_AD_Amount = ((@Yearly_Bonus_Amount*@M_AD_Percentage)/100)
								End
							else
								BEgin
									set @M_AD_Amount =@Yearly_Bonus_Amount
								End	
								EXEC dbo.P0100_ANUAL_BONUS 0,@Cmp_ID,@Emp_ID,@Ad_ID,@M_AD_Amount,@Eff_Month,@Eff_Year,@Sal_Tran_ID,'I'		
								set @M_AD_Amount=0
					if month(@Join_Date)=month(@To_Date) And Year(@Join_Date)<> Year(@To_Date)
						Begin
							select @M_AD_Amount = sum(isnull(Amount,0)) from dbo.t0100_Anual_bonus WITH (NOLOCK) where month(@From_Date)=Effective_Month And Year(@From_Date)=Effective_Year
							And Emp_ID=@Emp_ID and Ad_ID=@Ad_ID and Cmp_Id=@Cmp_ID
						End
				End
			else if @Ad_EFFECT_FROM = 'Confirmation'
				BEgin
							   Declare @Date_Confirmation Datetime
							   select @Date_Confirmation = isnull(Emp_Confirm_Date,'') from dbo.t0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID
				if @Date_Confirmation <> '' And @Date_Confirmation < @To_Date
					begin 
								if  @M_AD_Percentage>0  
										Begin
											set  @M_AD_Amount = ((@Yearly_Bonus_Amount*@M_AD_Percentage)/100)
										End
								else
										BEgin
											set @M_AD_Amount =@Yearly_Bonus_Amount
										End	
							Declare @Eff_Month_Con as numeric 
							Declare @Eff_Year_Con as numeric
							set @Eff_Month_Con = month(@Date_Confirmation)
							set @Eff_Year_Con=Year(Dateadd(yy,0,@From_Date))
							if  @M_AD_Percentage >0  
								Begin
									set  @M_AD_Amount = ((@Yearly_Bonus_Amount*@M_AD_Percentage)/100)
								End
							else
								BEgin
									set @M_AD_Amount =@Yearly_Bonus_Amount
								End	
								
						EXEC dbo.P0100_ANUAL_BONUS 0,@Cmp_ID,@Emp_ID,@Ad_ID,@M_AD_Amount,@Eff_Month_Con,@Eff_Year_Con,@Sal_Tran_ID,'I'		
						set @M_AD_Amount=0
					End
							if @Date_Confirmation <> ''
								Begin
									if month(@Date_Confirmation)=month(@To_Date) And Year(@Date_Confirmation)<> Year(@To_Date)
										BEgin			
												select @M_AD_Amount = sum(isnull(Amount,0)) from dbo.t0100_Anual_bonus WITH (NOLOCK) where month(@From_Date)=Effective_Month And Year(@From_Date)=Effective_Year
												And Emp_ID=@Emp_ID and Ad_ID=@Ad_ID and Cmp_Id=@Cmp_ID
										End
								End
				End
			End	
	End	
 Else if @varCalc_On='Present Senario'                      
  BEGIN  
  
		DECLARE	@C_Paid_Days numeric(18,1)
		DECLARE	@A_Days		numeric(18,1)
		 --Changed by Gadriwala Muslim 02102014
  		SELECT  @C_Paid_Days = ISNULL(SUM(leave_used),0) + ISNULL(sum(CompOff_Used),0) FROM dbo.T0140_LEavE_Transaction WITH (NOLOCK) WHERE Emp_Id =@Emp_ID 
				AND For_Date >=@From_Date AND For_Date <=@To_date AND Leave_ID IN
					(SELECT  Leave_ID FROM T0040_LEave_Master WITH (NOLOCK) WHERE Cmp_Id =@Cmp_ID AND Leave_Type <> 'Company Purpose')
					
		SET @A_Days = @numAbsentDays + @C_Paid_Days
		
		IF @A_Days <=0
			BEGIN
				SELECT @Tmp_amount = MAX(Limit),@Late_Mode=late_Mode,@Late_Scan=Calculate_On FROM dbo.T0040_Late_Extra_Amount  WITH (NOLOCK)                  
				 WHERE CMP_ID = @CMP_ID                    
			   AND Allowance_ID =@AD_ID  GROUP BY late_Mode,Calculate_On,Allowance_ID
			END
		ELSE
			BEGIN	
				SELECT @Tmp_amount = Limit,@Late_Mode=late_Mode,@Late_Scan=Calculate_On from dbo.T0040_Late_Extra_Amount WITH (NOLOCK)                   
				WHERE CMP_ID = @CMP_ID                    
				AND  @A_Days >= from_Days and @A_Days <=To_days                    
				AND Allowance_ID =@AD_ID    
			END
			
    IF @Late_Mode ='%'  
		BEGIN  
			SET @M_AD_Amount = ROUND(@M_AD_Amount * @Tmp_amount /100,0)  
		END
    ELSE  
		BEGIN  
			SET @M_AD_Amount = @Tmp_amount  
		END  
	 END
	 
   Else IF @varCalc_On='Present Days'
	Begin --by Falak on 23/12/2010
		DEclare	@C_Days numeric(18,1)
		--Declare @P_Days numeric(18,1)
		--Changed by Gadriwala Muslim 02102014
  		select @C_Days = isnull(sum(leave_used),0) + ISNULL(sum(CompOff_Used),0) from dbo.T0140_LEavE_Transaction WITH (NOLOCK) where Emp_Id =@Emp_ID 
				and For_Date >=@From_Date and For_Date <=@To_date and Leave_ID in 
				(select Leave_ID from T0040_LEave_Master WITH (NOLOCK) where Cmp_Id =@Cmp_ID and Leave_Type <> 'Company Purpose')
		set @P_Days = @Present_Days + @C_Days 
		if @P_Days < 0 
			set @M_AD_Amount = 0
		else
			set @M_AD_Amount = @P_Days * @M_AD_Amount 
				
	End 
    ELSE IF @M_AD_Flag = 'I'            
		BEGIN    
			IF  @M_AD_Percentage > 0                    
			  BEGIN                    
					IF ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper AND @Max_Upper > 0                    
						BEGIN                    
							SET @M_AD_Amount = @Max_Upper                     
						END                     
			ELSE                      
					BEGIN		                   
						
						SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)                     
						--select @M_AD_Amount
					END                    
			END                     
    ELSE
	BEGIN                    

     IF UPPER(@varCalc_On) ='FIX'                    
      BEGIN  
			-------------Comments for Nagamills ------------------------------
			--IF @Salary_Cal_Day <=15 
			 -- BEGIN
			   --    set @M_AD_Amount=Round(@M_AD_Amount * @Salary_Cal_Day /@Out_OF_Days,0)
			  --End
			 --Else 
			  --Begin
					  SET @M_AD_Amount=@M_AD_Amount  
			 -- End       
			 -------------Comments for Nagamills ------------------------------	                  
      END                    
     ELSE IF @Wages_type = 'Monthly' And @varCalc_On <> 'Arrears'  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
       BEGIN                  
			SET @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Tot_Salary_Day                     
       END                  
     ELSE                     
       BEGIN                    
		IF @varCalc_On <> 'Arrears'  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016                     
			SET @M_AD_Amount =  @M_AD_Amount * @Salary_Cal_Day                     
       END                         

   END                     
  END                    
     ELSE ---- Start Deduction                     
       BEGIN       
                  
	IF  @M_AD_Percentage > 0                    
	 BEGIN                    
		  IF @PF_DEF_ID = @AD_DEF_ID                    
			BEGIN                     
				IF  @Emp_Full_PF = 0 AND @PF_LIMIT > 0 AND @Calc_On_Allow_Dedu > @PF_LIMIT                     
					SET @Calc_On_Allow_Dedu = @PF_Limit                    
					SET @M_AD_Amount = ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)                    
			END   
			                 
		ELSE IF @ESIC_DEF_ID = @AD_DEF_ID                    
			BEGIN         
				IF @ESIC_Limit <> 0  
					BEGIN
						IF @ESIC_Basic_Salary <= @ESIC_Limit
								BEGIN
									SET @M_AD_Amount = CEILING((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100)) 
								END
						ELSE IF @sal_tran_id1 <> 0
								BEGIN	
									SET @M_AD_Amount = CEILING((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))   
								END		
						ELSE
								BEGIN
									SET @M_AD_Amount=0
								END	
					END		
				ELSE
					BEGIN
								SET @M_AD_Amount = CEILING((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100))   	
					END		
											
    		END                  
    		
		ELSE IF ROUND((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper AND @Max_Upper > 0                    
			BEGIN                    
				SET @M_AD_Amount = @Max_Upper                     
			END                      
		Else                    
			begin                    
			set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)                     
			end           

    End                     
        Else                    
    begin                    

		  if @IT_DEF_ID = @AD_DEF_ID                     
	        BEGIN                    
				IF @IT_TAX_AMOUNT > 0                     
				SET @M_AD_Amount = @IT_TAX_AMOUNT                    
			END                     
			else If upper(@varCalc_On) ='FIX'                    
			Begin                    
			       set @M_AD_Amount=@M_AD_Amount
			End                    
			Else if @Wages_type = 'Monthly'                         
			Begin                    
				set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Tot_Salary_Day                     
			End                    
     Else                     
        Begin                    
      set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)                     
        End                     
    End                     
      End                    
        
  
                    
     If @varCalc_On = 'Import'               
      Begin                  
		   set @M_AD_Amount = 0                    
		   select @M_AD_Amount = Amount from dbo.T0190_Monthly_AD_Detail_import WITH (NOLOCK) Where Emp_ID=@Emp_ID and AD_ID =@AD_ID and For_DAte>=@From_Date and For_Date <=@To_Date                    
      End                    
      
     If Upper(@varCalc_On) ='PERFORMANCE'         
      Begin 
			SELECT @PERFORM_POINTS=SUM(ISNULL(PERCENTAGE,0)) FROM dbo.T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND MONTH(FOR_DATE)=MONTH(@From_Date)  AND YEAR(FOR_DATE)=YEAR(@From_Date)       
			--IF @PERFORM_POINTS > 100
			--	SET @PERFORM_POINTS=100  -- change by Falak : 17-Aug-2010 as per client requirement to add percentage > 100
				
			--SELECT @PERFORM_POINTS	--Comment By Girish on 08-Mar-2010 
			--Note Don't Put this type of Select In Main Database
			set @M_AD_Amount = (@M_AD_Amount  * ISNULL(@PERFORM_POINTS,0))/100                
      End   
      
              
                      
     if @AD_DEF_ID = @Join_Time_Def_ID                     
      Begin                    
        if Month(@From_Date) <> Month(@Join_Date) or year(@From_Date) <> year(@Join_Date)                     
        Begin                    
         set @M_AD_Amount =0                     
        End                    
      End                    
                         
                         
     SELECT @M_AD_Tran_ID = ISNULL(MAX(M_AD_Tran_ID),0) + 1 FROM dbo.T0210_MONTHLY_AD_DETAIL  WITH (NOLOCK)                     
     SET @M_AD_Amount = ROUND(@M_AD_Amount,0)                    
  
   ----------for Selected Month----------------------------------------                  
		if @AD_Effect_Month <> '' and charindex(@StrMonth,@AD_Effect_Month) = 0 And isnull(@AD_CAL_TYPE,'')='' 
			Begin  
				set @M_AD_Amount = 0  
			End  
  --------------------------------------------------------------------
	 if @M_AD_EFFECT_ON_OT = 1
		Begin
		
			if @Wages_type ='Monthly'
				set  @OT_Basic_Salary = @OT_Basic_Salary + @E_Ad_Amount
			else if @M_AD_Percentage > 0                     
				set  @OT_Basic_Salary = @OT_Basic_Salary + Round(@Day_Salary * @M_AD_Actual_Per_Amount/100,0) 
			else 
				set  @OT_Basic_Salary = @OT_Basic_Salary + @M_AD_Actual_Per_Amount 
		End

  	if @AD_Effect_Month <> '' and charindex(@StrMonth,@AD_Effect_Month) <> 0 And isnull(@AD_CAL_TYPE,'')<>'' 
			Begin  
				if @AD_CAL_TYPE = 'Quaterly'
				  select @M_AD_Amount=isnull(@M_AD_Amount,0) +isnull(SUM(ISNULL(M_AD_AMOUNT,0)),0) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where For_Date >= dateadd(m,-2,@From_Date) And For_Date <= @To_Date And Ad_ID = @Ad_ID
				if @AD_CAL_TYPE = 'Half Yearl'
				  select @M_AD_Amount=isnull(@M_AD_Amount,0) +isnull(SUM(ISNULL(M_AD_AMOUNT,0)),0) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where For_Date >= dateadd(m,-5,@From_Date) And For_Date <= @To_Date	And Ad_ID = @Ad_ID 
				if @AD_CAL_TYPE = 'Yearly'
				  select @M_AD_Amount=isnull(@M_AD_Amount,0) +isnull(SUM(ISNULL(M_AD_AMOUNT,0)),0) from dbo.T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where For_Date >= dateadd(m,-11,@From_Date) And For_Date <= @To_Date And Ad_ID = @Ad_ID	  
				  
			End  
		
		DECLARE @M_AREARS_AMOUNT AS NUMERIC(18,2)
		SET		@M_AREARS_AMOUNT =0
		
		IF @AREAS_DAYS > 0
		  BEGIN
			IF 	@M_AD_Amount > 0			
				BEGIN										
					SET @M_AREARS_AMOUNT = ROUND(@M_AD_Amount * @AREAS_DAYS/@Out_Of_Days,0)
					SET @M_AD_Amount=@M_AREARS_AMOUNT + @M_AD_Amount
			    END				    
		  END		
		  
      if @M_AD_Amount is null
		set @M_AD_Amount =0    		 				
					INSERT INTO dbo.T0210_MONTHLY_AD_DETAIL                    
                          (M_AD_Tran_ID, Sal_Tran_ID,Temp_Sal_Tran_ID ,L_Sal_Tran_ID,Emp_ID, Cmp_ID, AD_ID, For_Date, M_AD_Percentage, M_AD_Amount, M_AD_Flag, M_AD_Actual_Per_Amount,                     
                           M_AD_Calculated_Amount,M_AD_NOT_EFFECT_ON_PT,M_AD_NOT_EFFECT_SALARY,M_AD_EFFECT_ON_OT,M_AD_EFFECT_ON_EXTRA_DAY,SAL_TYPE,M_AD_effect_on_Late,M_AREAR_AMOUNT)                    
					VALUES     (@M_AD_Tran_ID, null,@Sal_Tran_ID,@L_Sal_Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @From_Date, @M_AD_Percentage, @M_AD_Amount, @M_AD_Flag, @M_AD_Actual_Per_Amount,                     
                           @Calc_On_Allow_Dedu,@M_AD_NOT_EFFECT_ON_PT,@M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY,0,@M_AD_effect_on_Late,@M_AREARS_AMOUNT)                    
                                             
     if isnull(@Sal_Tran_ID,0) > 0                    
      begin                    
       set @Deduction_Data  = ''              
       set @Allowance_Data  = ''                    
                         
                         
       if @M_AD_Flag ='D'                     
     set @Deduction_Data = '<Tr>  <td width=200> <Font size =1 > ' + @AD_Name + '</Font></td> <td> <Font size =1 > '  +    cast(@M_AD_Amount as varchar(20)) + '</Font></td>'  + '</Tr>'                                     
       else                        
         set @Allowance_Data  = '<Tr> <td width=200> <Font size =1 > ' + @AD_Name + '</Font></td> <td> <Font size =1 > '  +    cast(@M_AD_Amount as varchar(20)) + '</Font></td>'  + '</Tr>'                                     
                   
                  
       UPDATE dbo.T0210_PAYSLIP_DATA                     
       SET  Allowance_Data = Allowance_Data + @Allowance_Data,                    
         Deduction_Data = Deduction_Data + @Deduction_Data                    
       WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID                    
      end                    
               
    fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On,@AD_DEF_ID,@M_AD_NOT_EFFECT_ON_PT,
    @M_AD_NOT_EFFECT_SALARY,@M_AD_EFFECT_ON_OT,@M_AD_EFFECT_ON_EXTRA_DAY ,@AD_Name,@M_AD_effect_on_Late,@AD_Effect_Month,@AD_CAL_TYPE,@AD_EFFECT_FROM
    ,@IS_NOT_EFFECT_ON_LWP
                  
   end                    
 close curAD                    
 deallocate curAD                      
   if isnull(@Sal_Tran_ID,0)   >0                    
    begin                    
    UPDATE dbo.T0210_PAYSLIP_DATA                     
    SET  Allowance_Data = Allowance_Data + '</table>',                    
      Deduction_Data = Deduction_Data + '</table>'                    
    WHERE TEMP_SAL_TRAN_ID = @SAL_TRAN_ID            
   end                           
 RETURN                    
                    
                    
                    

