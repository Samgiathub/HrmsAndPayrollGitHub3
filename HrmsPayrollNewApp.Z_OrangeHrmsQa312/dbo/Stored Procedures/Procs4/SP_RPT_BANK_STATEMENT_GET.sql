
  
 --exec SP_RPT_BANK_STATEMENT_GET @Cmp_ID=119,@From_Date='2020-12-01 00:00:00',@To_Date='2020-12-31 00:00:00',@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='14111# 14112# 14113# 14114# 14115# 26748# 26777# 13961#13962# 13966# 14010# 14013# 26748# 26777# 13961# 13962# 13966# 14010# 14013# 14017# 14027# 14029# 14047# 14048# 14049# 14051# 14056# 14057# 14059#14062# 14063# 14087# 14087# 14088# 14104# 14141# 14142# 14144# 14190# 14191# 14193',@Sal_Type=0,@Bank_ID='',@Payment_mode='',@Salary_Cycle_id=0,@Segment_Id=0,@Vertical_Id=0,@SubVertical_Id=0,@SubBranch_Id=0,@Salary_Status='Done',@Report_for=2                      
                       
                      
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---                            
CREATE PROCEDURE [dbo].[SP_RPT_BANK_STATEMENT_GET]                           
  @Cmp_ID   numeric                              
 ,@From_Date  datetime                              
 ,@To_Date   datetime                              
 ,@Branch_ID  numeric                              
 ,@Cat_ID   numeric                               
 ,@Grd_ID   numeric                              
 ,@Type_ID   numeric                              
 ,@Dept_ID   numeric                              
 ,@Desig_ID   numeric                              
 ,@Emp_ID   numeric                              
 ,@constraint  varchar(max)                              
 ,@Sal_Type   numeric = 0                              
 --,@Bank_ID   numeric = 0                              
 ,@Bank_ID   VARCHAR(MAX) = '' --changed by ramiz on 18/03/2019                            
 ,@Payment_mode  varchar(20) ='Transfer'                              
 ,@salary_status varchar(50) = 'All' --Salary Status (All , Done , Hold , Zero , Negative)                            
 ,@Director_details tinyint = 0                               
 ,@Salary_Cycle_id numeric = NULL                            
 ,@Segment_Id  numeric = 0                               
 ,@Vertical_Id  numeric = 0                               
 ,@SubVertical_Id numeric = 0  -- Added By Gadriwala Muslim 21082013                             
 ,@SubBranch_Id  numeric = 0   -- Added By Gadriwala Muslim 21082013                             
 ,@Report_For  NUMERIC = 0   --Use Format-6 For Rk  -- Ankit 15062015                            
 ,@is_column  tinyint = 0   --For Columns --Added By Ramiz on 09/05/2018                            
 ,@Report_Type  varchar(20) = '' --Report Type ( Details or Summary ) Added By Ramiz on 14/05/2018                            
 ,@Employee_Type varchar(50) = 'ALL'  --Employee Status ( ALL , Current , Left ) Added By Ramiz on 14/05/2018                            
 ,@Export_Type  numeric = 0 --Added By Ramiz for Excel and text and PDF , different select Queries   
 ,@Ben_Email nvarchar(max) = '' --Add by Ronakk for the HDFC to HDFC & IMFL Company SBI Gateway Report  27012022
 ,@Client_Code nvarchar(max) = '' --Add by Ronakk for the IMFL Company SBI Gateway Report 27012022
 ,@Deb_Ac_No nvarchar(max) = '' --Add by Ronakk for the IMFL Company SBI Gateway Report 27012022
AS                              
SET NOCOUNT ON                             
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                          
SET ARITHABORT ON                            
                               
   DECLARE @SAL_STATUS VARCHAR(32)                            
   SET @SAL_STATUS = @salary_status                            
                               
 IF @salary_status NOT IN ('Done', 'Hold')                            
 set @salary_status = NULL                            
                                
 IF @Branch_ID = 0                                
 SET @Branch_ID = null                              
                                
 IF @Cat_ID = 0                                
 SET @Cat_ID = null                              
                              
 IF @Grd_ID = 0                                
 SET @Grd_ID = null                              
                              
 IF @Type_ID = 0                                
 SET @Type_ID = null                              
                              
 IF @Dept_ID = 0                                
 SET @Dept_ID = null                              
               
 IF @Desig_ID = 0                                
 SET @Desig_ID = null                              
                              
 IF @Emp_ID = 0                                
 SET @Emp_ID = null                              
                     
 --IF @Bank_ID =0                              
 --SET @Bank_ID = null                             
                              
IF @Bank_ID = ''                              
 SET @Bank_ID = null                            
                              
 IF @Salary_Cycle_id = 0  -- Added By Gadriwala Muslim 21082013                            
 SET @Salary_Cycle_id = null                             
                             
 IF @Segment_Id = 0   -- Added By Gadriwala Muslim 21082013                            
 SET @Segment_Id = null                            
                             
 IF @Vertical_Id = 0   -- Added By Gadriwala Muslim 21082013                            
 SET @Vertical_Id = null                            
                             
 IF @SubVertical_Id = 0  -- Added By Gadriwala Muslim 21082013                        
 SET @SubVertical_Id = null                             
                             
 IF @SubBranch_Id = 0  -- Added By Gadriwala Muslim 21082013                            
 SET @SubBranch_Id = null                             
                            
 IF @Payment_mode = ''  --Ankit 30122015                            
 SET @Payment_mode = 'Bank Transfer'                            
                              
 IF @Report_Type = 'Summary'                            
 SET @Employee_Type = 'ALL'                            
                             
 CREATE TABLE #Emp_Cons                             
 (                                  
   Emp_ID numeric ,                                 
   Branch_ID numeric,                            
   Increment_ID numeric                                
 )                                
                               
 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id                             
                            
 IF @Payment_mode = 'Transfer'                              
 SET @Payment_mode = 'Bank Transfer'                              
                            
                             
  DECLARE @Sal_St_Date   DATETIME                                
  DECLARE @Sal_end_Date   DATETIME                              
                              
  -- Comment and added By rohit on 11022013                            
  declare @manual_salary_period as numeric(18,0)                            
  set @manual_salary_period = 0                            
                             
 If @Branch_ID is null                            
  Begin                             
   select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013                            
     from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID                                
     and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)                                
  End                            
 Else                            
  Begin                            
   select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013                            
     from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                                
     and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)                                
  End                                
                              
                                  
                                 
 if isnull(@Sal_St_Date,'') = ''                                
 begin                                
    set @From_Date  = @From_Date                                 
    set @To_Date = @To_Date                                
 end                                 
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1                                
 begin                                
    set @From_Date  = @From_Date                                 
 set @To_Date = @To_Date                                
 end                                 
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1                               
 begin                                
  -- Added By rohit on 11022013                            
    if @manual_salary_period = 0                               
   Begin                            
      set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)                              
      set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))                             
     -- set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1                            
                                
      Set @From_Date = @Sal_St_Date                            
      Set @To_Date = @Sal_End_Date                            
   End                            
  Else                            
   Begin                            
    select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)                            
   -- set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1                            
                                  
    Set @From_Date = @Sal_St_Date                            
    Set @To_Date = @Sal_End_Date                             
   End                             
 -- Comment and added By rohit on 11022013                                  
                                   
 End                              
                             
                    
                            
--CODE ADDED BY RAMIZ TO TAKE SELECTED BANKS IN TEMP TABLE--                            
SELECT TOP 0 * INTO #BANK_MASTER                             
FROM T0040_BANK_MASTER BM WITH (NOLOCK)                            
IF LEN(ISNULL(@Bank_ID, '')) = 0                            
 INSERT INTO #BANK_MASTER                             
 SELECT  * FROM T0040_BANK_MASTER BM WITH (NOLOCK)                          
 WHERE BM.CMP_ID = @CMP_ID                            
ELSE                            
 INSERT INTO #BANK_MASTER                             
 SELECT  BM.* FROM T0040_BANK_MASTER BM WITH (NOLOCK)                            
   inner join (SELECT CAST(Data As Numeric) As BANK_ID FROM dbo.Split(@Bank_ID,'#') T                             
      WHERE T.Data <> '' and IsNumeric(T.Data) = 1                            
    )  T ON T.BANK_ID = BM.BANK_ID                            
                             
                             
                            
  CREATE TABLE #Emp_Salary                            
  (                              
   Sal_Tran_ID   numeric(18, 0) ,                              
   S_Sal_Tran_ID  numeric(18, 0) ,                              
   L_Sal_Tran_ID  numeric(18, 0) ,                              
   Sal_Receipt_No   numeric(18, 0) ,                              
   Emp_ID    numeric(18, 0) ,                              
   Cmp_ID    numeric(18, 0) ,                              
   Increment_ID   numeric(18, 0) ,                              
   Month_St_Date   datetime ,                              
   Month_End_Date   datetime ,                              
   Sal_Generate_Date  datetime ,                              
   Sal_Cal_Days   numeric(18, 1) ,                              
   Present_Days   numeric(18, 1) ,                              
   Absent_Days   numeric(18, 1) ,                              
   Holiday_Days   numeric(18, 1) ,                              
   Weekoff_Days   numeric(18, 1) ,                              
   Cancel_Holiday   numeric(18, 1) ,                              
   Cancel_Weekoff   numeric(18, 1) ,                              
   Working_Days   numeric(18, 1) ,                              
   Outof_Days   numeric(18, 1)  ,                              
   Total_Leave_Days  numeric(18, 1) ,                              
   Paid_Leave_Days  numeric(18, 1) ,                              
   Actual_Working_Hours  varchar (20) ,                              
   Working_Hours   varchar (20) ,                              
   Outof_Hours   varchar (20) ,                              
   OT_Hours   numeric(18, 1)  ,                              
   Total_Hours   varchar (20) ,                              
   Shift_Day_Sec   numeric(18, 0) ,                              
   Shift_Day_Hour   varchar (20) ,                              
   Basic_Salary   numeric(18, 2) ,                              
   Day_Salary   numeric(18, 5)  ,                              
   Hour_Salary   numeric(18, 5) ,                              
   Salary_Amount   numeric(18, 2) ,                              
   Allow_Amount   numeric(18, 2) ,                              
   OT_Amount   numeric(18, 2)  ,                              
   Other_Allow_Amount  numeric(18, 2) ,                              
   Gross_Salary   numeric(18, 2) ,                              
   Dedu_Amount   numeric(18, 2) ,                              
   Loan_Amount   numeric(18, 2) ,                              
   Loan_Intrest_Amount  numeric(18, 2) ,                              
   Advance_Amount   numeric(18, 2) ,                              
   Other_Dedu_Amount  numeric(18, 2) ,                              
   Total_Dedu_Amount  numeric(18, 2) ,                              
   Due_Loan_Amount  numeric(18, 2) ,                              
   Net_Amount   numeric(18, 2) ,                              
   Actually_Gross_Salary  numeric(18, 2) ,                              
   PT_Amount   numeric(18, 0) ,                            
   PT_Calculated_Amount  numeric(18, 0) ,                              
   Total_Claim_Amount  numeric(18, 0) ,                              
   M_OT_Hours   numeric(18, 1) ,                              
   M_Adv_Amount   numeric(18, 0) ,                              
   M_Loan_Amount   numeric(18, 0) ,                              
   M_IT_Tax   numeric(18, 0) ,                              
   LWF_Amount   numeric(18, 0) ,                              
   Revenue_Amount   numeric(18, 0) ,                              
   PT_F_T_Limit   varchar (20),                            
   SALARY_STATUS  varchar (20)                                 
  )                            
                             
 /* FOR BINDING COLUMNS */                            
 IF @IS_COLUMN = 1 AND @Report_Type = 'Details'                            
  BEGIN                             
   SELECT TOP 0 E.Alpha_Emp_Code , E.Emp_Full_Name , E.Date_Of_Join , E.Emp_Left AS Employee_Status,                            
     CM.Cat_Name , I_Q.Payment_Mode , BK.Bank_Name , I_Q.Inc_Bank_AC_No  , E.Ifsc_Code , MS.Net_Amount      
     ,E.Bank_BSR -- Added by Sajid 28-01-2021                            
     ,'Salary ' + DATENAME(month, @TO_DATE) +'' +Convert(Varchar(4),DATEPART(Year,@TO_DATE)) AS 'Narration' -- Added by Sajid 28-01-2021 for Molkem Client                            
   FROM #EMP_SALARY MS                            
    INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON MS.emp_ID = E.emp_ID                             
    INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) ON MS.Increment_ID = I_Q.Increment_ID                            
    LEFT OUTER JOIN #BANK_MASTER BK ON I_Q.Bank_ID = BK.Bank_ID                            
    LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I_Q.Cat_ID = CM.Cat_ID                            
   RETURN                             
  END                            
                                 
                            
                              
 IF @Sal_Type = 0                              
    BEGIN                            
                               
   INSERT INTO #Emp_Salary                              
      (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,                               
      Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,                               
      Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,                               
      Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,                               
      Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,                               
      PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,                               
      PT_F_T_Limit , SALARY_STATUS)                            
   SELECT 
	 distinct
      ms.Sal_Tran_ID, Sal_Receipt_No, ms.Emp_ID, ms.Cmp_ID, Ms.Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,                               
      Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,                               
      Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,                               
      Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,                               
      Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount
	  --, (ms.Net_Amount + ad.M_AD_Amount)
	  , ms.Net_Amount 
	  , Actually_Gross_Salary, PT_Amount,                               
      PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,                               
      PT_F_T_Limit  , SALARY_STATUS                             
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)      
	inner join T0210_MONTHLY_AD_DETAIL  ad on ms.emp_ID = ad.emp_ID --and ms.Sal_Tran_ID = ad.Sal_Tran_ID
   INNER JOIN #Emp_Cons ec on ms.emp_ID = ec.emp_ID                               
    WHERE ms.Cmp_ID = @Cmp_Id and isnull(is_FNF,0)=0 --and Salary_Amount >0                            
     AND Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
     --AND MS.salary_status = isnull(@salary_status,ms.salary_status) and Net_Amount > 0                            
     --CASE WHEN is Added By Ramiz on 14/05/2018                            
     AND 1 = CASE  WHEN @SAL_STATUS IN ('Done', 'Hold', 'All') AND Net_Amount > 0                            
         AND ms.salary_status = isnull(@salary_status,ms.salary_status)                            
        THEN 1                    
       WHEN @SAL_STATUS = 'Negative' and Net_Amount < 0                            
        THEN 1                            
          WHEN  @SAL_STATUS = 'Zero'  and Net_Amount = 0                            
        THEN 1                            
         ELSE 0 END                            
                       
					   
                         
    END                              
 ELSE IF @Sal_Type = 1                               
  BEGIN                            
    INSERT INTO #Emp_Salary                              
    (S_Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,                  
    Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,                               
    Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,                               
    Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,                               
    Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,                      
    PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,                               
    PT_F_T_Limit , SALARY_STATUS)                              
    SELECT ms.S_Sal_Tran_ID, S_Sal_Receipt_No, ms.Emp_ID, ms.Cmp_ID, ms.Increment_ID, S_Month_St_Date, S_Month_End_Date, S_Sal_Generate_Date
	, S_Sal_Cal_Days, S_M_Present_Days,                               
    0, 0, 0, 0, 0, s_Working_Days, s_Outof_Days, 0,0,                    
    '', '', '', 0, '', S_Shift_Day_Sec, S_Shift_Day_Hour, S_Basic_Salary, S_Day_Salary,                               
    S_Hour_Salary, S_Salary_Amount, S_Allow_Amount, S_OT_Amount, S_Other_Allow_Amount, S_Gross_Salary
	, S_Dedu_Amount, S_Loan_Amount, S_Loan_Intrest_Amount,                               
    S_Advance_Amount, S_Other_Dedu_Amount, S_Total_Dedu_Amount, S_Due_Loan_Amount, S_Net_Amount, S_Actually_Gross_Salary, S_PT_Amount,                               
    S_PT_Calculated_Amount, S_Total_Claim_Amount, S_M_OT_Hours, S_M_Adv_Amount, S_M_Loan_Amount, S_M_IT_Tax, S_LWF_Amount, S_Revenue_Amount,                               
    S_PT_F_T_Limit , ''                             
  FROM T0201_MONTHLY_SALARY_Sett ms  WITH (NOLOCK)  
  
  inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID                               
  WHERE ms.Cmp_ID = @Cmp_Id                       
   --and S_Salary_Amount >0                              
   --and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date                             
   and Month(S_Month_End_Date) = Month(@To_Date) and Year(S_Month_End_Date) =Year(@To_Date)                            
   and Net_Amount > 0   --added jimit 05082015                            
  END                              
 ELSE IF @Sal_Type = 2                              
  BEGIN                            
    INSERT INTO #Emp_Salary                              
    (l_Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,                               
    Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,                               
    Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,                               
    Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,                               
    Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,                               
    PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,                               
    PT_F_T_Limit , salary_status)                              
                                
    SELECT L_Sal_Tran_ID, l_Sal_Receipt_No, ms.Emp_ID, Cmp_ID, ms.Increment_ID, l_Month_St_Date, l_Month_End_Date, L_Sal_Generate_Date, l_Sal_Cal_Days, 0,                               
   0, 0, 0, 0, 0, L_Working_Days, l_Outof_Days, 0, 0,                               
    '', '', '', 0, '', l_Shift_Day_Sec, l_Shift_Day_Hour, l_Basic_Salary, l_Day_Salary,                               
    l_Hour_Salary, l_Salary_Amount, l_Allow_Amount, 0, l_Other_Allow_Amount, L_Gross_Salary, L_Dedu_Amount, L_Loan_Amount, L_Loan_Intrest_Amount,                               
    L_Advance_Amount, L_Other_Dedu_Amount, L_Total_Dedu_Amount, L_Due_Loan_Amount, L_Net_Amount, L_Actually_Gross_Salary, L_PT_Amount,                               
   l_PT_Calculated_Amount, 0, 0, l_M_Adv_Amount, l_M_Loan_Amount, l_M_IT_Tax, l_LWF_Amount, l_Revenue_Amount,                               
    l_PT_F_T_Limit  , ''                             
  FROM T0200_MONTHLY_SALARY_Leave ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID                               
  WHERE ms.Cmp_ID = @Cmp_Id                               
   --and L_Salary_Amount >0                              
   and L_Month_St_Date >=@From_Date and L_Month_End_Date <=@To_Date                              
    and Net_Amount > 0   --added jimit 05082015                            
  END                              
 ELSE                               
  BEGIN                            
    INSERT INTO #Emp_Salary                              
    (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,                              
    Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,                               
    Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,                               
    Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,                               
    Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,                               
    PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,                               
    PT_F_T_Limit , salary_status)                              
                                
    SELECT null, null, Emp_ID, @Cmp_ID, null, @From_Date, @To_Date, null, 0, 0,                               
    0, 0, 0, 0, 0, 0, 0, 0, 0,'', '', '', 0, '', 0, '', 0, 0,0, 0, 0, 0, 0, 0, 0,0, 0,                               
    0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, '' ,''                             
    FROM #Emp_Cons ec                               
                                   
                                  
   UPDATE #Emp_Salary                              
   SET Sal_Tran_ID = ms.Sal_Tran_ID,                               
   Sal_Receipt_No = ms.Sal_Receipt_No,                               
   Increment_ID = ms.Increment_ID,                               
   Sal_Generate_Date = ms.Sal_Generate_Date,                               
   Sal_Cal_Days = ms.Sal_Cal_Days,                               
   Present_Days = ms.Present_Days,                           
   Absent_Days = ms.Absent_Days,                               
   Holiday_Days = ms.Holiday_Days,                               
   Weekoff_Days = ms.Weekoff_Days,                               
   Cancel_Holiday = ms.Cancel_Holiday,                              
   Cancel_Weekoff = ms.Cancel_Weekoff,                               
   Working_Days = ms.Working_Days,                               
   Outof_Days = ms.Outof_Days,                               
   Total_Leave_Days = ms.Total_Leave_Days,                 
   Paid_Leave_Days = ms.Paid_Leave_Days,                               
   Actual_Working_Hours = ms.Actual_Working_Hours,                               
   Working_Hours = ms.Working_Hours,                               
   Outof_Hours = ms.Outof_Hours,                               
   OT_Hours = ms.OT_Hours,                               
   Total_Hours = ms.Total_Hours,                               
   Shift_Day_Sec = ms.Shift_Day_Sec,                               
   Shift_Day_Hour = ms.Shift_Day_Hour,                               
   Basic_Salary = ms.Basic_Salary,                               
   Day_Salary = ms.Day_Salary,                               
   Hour_Salary = ms.Hour_Salary,                               
   Salary_Amount = ms.Salary_Amount,                               
   Allow_Amount = ms.Allow_Amount,                               
   OT_Amount = ms.OT_Amount, Other_Allow_Amount = ms.Other_Allow_Amount,                               
   Gross_Salary = ms.Gross_Salary, Dedu_Amount = ms.Dedu_Amount,                               
   Loan_Amount = ms.Loan_Amount, Loan_Intrest_Amount = ms.Loan_Intrest_Amount, Advance_Amount = ms.Advance_Amount,                               
   Other_Dedu_Amount = ms.Other_Dedu_Amount, Total_Dedu_Amount = ms.Total_Dedu_Amount, Due_Loan_Amount = ms.Due_Loan_Amount,                               
   Net_Amount = ms.Net_Amount, Actually_Gross_Salary = ms.Actually_Gross_Salary,                               
   PT_Amount = ms.PT_Amount, PT_Calculated_Amount = ms.PT_Calculated_Amount, Total_Claim_Amount = ms.Total_Claim_Amount,                               
   M_OT_Hours = ms.M_OT_Hours, M_Adv_Amount = ms.M_Adv_Amount, M_Loan_Amount = ms.M_Loan_Amount, M_IT_Tax = ms.M_IT_Tax, LWF_Amount = ms.LWF_Amount,                               
   Revenue_Amount = ms.Revenue_Amount, PT_F_T_Limit = ms.PT_F_T_Limit  ,                            
   salary_status = Ms.Salary_Status                            
   FROM #Emp_Salary es Inner join T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID                               
   WHERE ms.Cmp_ID = @Cmp_Id                               
   --and ms.Salary_Amount >0                              
   --and ms.Month_St_Date >=@From_Date and ms.Month_End_Date <=@To_Date                              
   and Month(ms.Month_End_Date) = Month(@To_Date) and Year(ms.Month_End_Date) =Year(@To_Date)                            
   and ms.salary_status = isnull(@salary_status,ms.salary_status)                            
                            
                                  
   Update #Emp_Salary                              
   set S_Sal_Tran_ID = ms.S_Sal_Tran_ID,                      
   Increment_ID = ms.Increment_ID,                          
   Sal_Cal_Days = Sal_Cal_Days + ms.S_M_Present_Days,                               
   Present_Days = Present_Days + ms.S_M_Present_Days,                               
   Shift_Day_Sec = ms.S_Shift_Day_Sec,                               
   Shift_Day_Hour = ms.S_Shift_Day_Hour,                               
   Basic_Salary = Basic_Salary + ms.S_Basic_Salary,                               
   Day_Salary = Day_Salary + ms.S_Day_Salary,                               
   Hour_Salary = Hour_Salary + S_Hour_Salary,                               
   Salary_Amount = Salary_Amount + S_Salary_Amount,                               
   Allow_Amount = Allow_Amount + S_Allow_Amount,                               
   OT_Amount = OT_Amount + s_OT_Amount,                             
   Other_Allow_Amount = Other_Allow_Amount + S_Other_Allow_Amount,                               
   Gross_Salary = Gross_Salary + S_Gross_Salary,                             
Dedu_Amount = Dedu_Amount + S_Dedu_Amount,                               
   Loan_Amount = Loan_Amount + S_Loan_Amount,                             
   Loan_Intrest_Amount = Loan_Intrest_Amount + S_Loan_Intrest_Amount,                             
   Advance_Amount = Advance_Amount + S_Advance_Amount,                               
   Other_Dedu_Amount = Other_Dedu_Amount + s_Other_Dedu_Amount,                             
   Total_Dedu_Amount = Total_Dedu_Amount  + S_Total_Dedu_Amount,                             
   Due_Loan_Amount = S_Due_Loan_Amount,                               
   Net_Amount = Net_Amount + S_Net_Amount,                             
   Actually_Gross_Salary = Actually_Gross_Salary + S_Actually_Gross_Salary,                               
   PT_Amount = PT_Amount + S_PT_Amount,                             
   PT_Calculated_Amount = PT_Calculated_Amount + S_PT_Calculated_Amount,                            
   LWF_Amount = LWF_Amount + S_LWF_Amount,                             
   Revenue_Amount = Revenue_Amount + s_Revenue_Amount,            PT_F_T_Limit = S_PT_F_T_Limit                            
   FROM #Emp_Salary ES                             
    INNER JOIN T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID                               
   WHERE ms.Cmp_ID = @Cmp_Id                               
     --and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date                              
     and Month(S_Month_End_Date) = Month(@To_Date) and Year(S_Month_End_Date) =Year(@To_Date)                            
                              
                                  
   Update #Emp_Salary                              
   set L_Sal_Tran_ID = ms.L_Sal_Tran_ID,                               
   Sal_Cal_Days = Sal_Cal_Days + L_Sal_Cal_Days,                               
   Basic_Salary = Basic_Salary + L_Basic_Salary,                               
   Day_Salary = Day_Salary + L_Day_Salary,                               
   Hour_Salary = Hour_Salary + L_Hour_Salary,                               
   Salary_Amount = Salary_Amount + L_Salary_Amount,                               
   Allow_Amount = Allow_Amount + L_Allow_Amount,                               
   Other_Allow_Amount = Other_Allow_Amount + L_Other_Allow_Amount,                               
   Gross_Salary = Gross_Salary + L_Gross_Salary, Dedu_Amount = Dedu_Amount + L_Dedu_Amount,                              
   Loan_Amount = Loan_Amount + L_Loan_Amount, Loan_Intrest_Amount = Loan_Intrest_Amount + L_Loan_Intrest_Amount, Advance_Amount = Advance_Amount + L_Advance_Amount,                               
   Other_Dedu_Amount = Other_Dedu_Amount + L_Other_Dedu_Amount, Total_Dedu_Amount = Total_Dedu_Amount  + L_Total_Dedu_Amount, Due_Loan_Amount = L_Due_Loan_Amount,                               
   Net_Amount = Net_Amount + L_Net_Amount, Actually_Gross_Salary = Actually_Gross_Salary + L_Actually_Gross_Salary,                               
   PT_Amount = PT_Amount + L_PT_Amount, PT_Calculated_Amount = PT_Calculated_Amount + L_PT_Calculated_Amount                                
   , LWF_Amount = LWF_Amount + L_LWF_Amount, Revenue_Amount = Revenue_Amount + L_Revenue_Amount, PT_F_T_Limit = L_PT_F_T_Limit                              
   From #Emp_Salary es                             
   Inner join T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID                               
   Where ms.Cmp_ID = @Cmp_Id                               
   and L_Month_St_Date >=@From_Date and L_Month_End_Date <=@To_Date                              
  END                              
                            
                             
 IF @Report_Type = ''                            
  BEGIN                            
   CREATE TABLE #Total                            
   (                            
     Cmp_ID numeric(18,0),                              
     Total_Amount numeric(18,2),                            
     Bank_Id Numeric(18,2)                               
   )                            
                
				
    IF @Payment_mode = 'Cash'                               
    BEGIN                            
     IF Len(isNull(@Bank_ID ,'')) > 0                            
      BEGIN                             
       INSERT INTO #TOTAL                            
       SELECT @Cmp_id,isnull(Sum(Isnull(Net_Amount,0)),0  ),0                
       FROM #EMP_SALARY MS                             
        INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                            
        INNER JOIN T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
       INNER JOIN #BANK_MASTER BM ON I_Q.BANK_ID = BM.BANK_ID                            
       WHERE E.Cmp_ID = @Cmp_Id --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0))                            
       and I_q.Payment_mode = @Payment_mode and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
      END                            
     ELSE                            
      BEGIN                            
       INSERT INTO #TOTAL                            
       SELECT @Cmp_id,isnull(Sum(Isnull(Net_Amount,0)),0  ),0                            
       FROM #EMP_SALARY MS                             
        INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                     
        INNER JOIN T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
       WHERE E.Cmp_ID = @Cmp_Id                            
       and I_q.Payment_mode = @Payment_mode and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
      END                            
                                    
    END                            
    ELSE                            
    BEGIN       
	print 123--mansi
     IF Len(isNull(@Bank_ID ,'')) > 0                            
      BEGIN                       
	  
     INSERT INTO #TOTAL                              
        SELECT @Cmp_id,isnull(Sum(Isnull(Net_Amount,0)),0  ),I_Q.Bank_ID                             
        FROM #Emp_Salary MS                             
         INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON MS.emp_ID = E.Emp_ID                            
         INNER JOIN T0095_Increment I_Q WITH (NOLOCK) ON Ms.Increment_ID = I_Q.Increment_ID   
	     INNER JOIN #BANK_MASTER BM  ON I_Q.BANK_ID = BM.BANK_ID                            
		
	 WHERE E.Cmp_ID = @Cmp_Id      
		 --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0))  --and Salary_Amount >0                            
         and I_q.Payment_mode = @Payment_mode                              
         and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
        GROUP BY I_q.bank_id                             
      END
	  
     ELSE                            
      BEGIN       
	  
     INSERT INTO #TOTAL                              
     SELECT @Cmp_id,isnull(Sum(Isnull(Net_Amount,0)),0),I_Q.Bank_ID 
     FROM #Emp_Salary MS                             
	   INNER JOIN T0080_EMP_MASTER E  WITH (NOLOCK) ON MS.emp_ID = E.Emp_ID                            
	   INNER JOIN T0095_Increment I_Q WITH (NOLOCK) ON Ms.Increment_ID = I_Q.Increment_ID    
	  WHERE E.Cmp_ID = @Cmp_Id                               
     --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0))  --and Salary_Amount >0                            
     and I_q.Payment_mode = @Payment_mode                              
     and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
     GROUP BY I_q.bank_id                             

      END                            
     END                            
                               
   IF @Report_For = 0                            
    BEGIN     
	print 245--mansi
      IF @Director_details = 0                            
      BEGIN                 
	  

						 SELECT identity(int, 1,1) as SRNO,MS.*,
					   Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Emp_full_Name,Branch_Address,Branch_name,Comp_name,Grd_Name,DAteName(M,Month_End_Date)as Month,YEar(Month_End_Date)as Year                            
						 ,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth,SSN_No as PF_No,SIN_No as ESIC_No 
						 ,dbo.F_Number_TO_Word(Net_Amount) as Net_Amount_In_Word                              
						 ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name,                             
						 Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No As Cmp_Acc_No, I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no,I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no1,                            
						 Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(tem.Total_Amount as varchar(15)),15) As varchar(20)) Else CAST(tem.Total_Amount as varchar(30)) End As Total_Amount,                            
						 dbo.F_Number_TO_Word(tem.Total_Amount) as Total_Amount_In_Word,CCM.Center_Name --Added by Jaina 10-08-2015                                   
						 ,@Payment_mode as Payment_Mode,bk.Bank_ID,bk.Bank_Address  --Changed by Falak on 01-FEB-2011                              
						 ,E.Ifsc_Code,BM.Branch_ID,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , -- added by mitesh on 08052012,   
						 
						 

						 Case 
						 When @@SERVERNAME = 'IND-HRDB-SRV' then CAST(Net_Amount as varchar(30))  -- Added by ronakk 05052022 for Inditrade
						 When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20))
						 Else CAST(Net_Amount as varchar(30)) End As Net_Amt       
						 
						 ,bk.Bank_BSR_Code  , CONVERT(varchar(30), Month_End_Date,112) as Month_Last_Date --added jimit 27042016  
						 ,bk.Bank_Branch_Name --added by ronakk 02022022
						 ,format(Month_End_Date,'dd/MM/yyyy')  as MED --add by ronakk 27012022
						  ,'Salary: '+CONVERT(varchar(30),format(Month_End_Date,'yyyy-MM'),112) as Remark2 --add by ronakk 27012022
						 ,Case When Bank_Code like '%SBI%' then 'DCR' else 'NEFT' End as Product_Code --add by ronakk 27012022
						 ,E.Emp_First_Name , E.Emp_Last_Name , cm.Cmp_Email , @Export_Type as Export_Type                            
						 ,cast(I_Q.Inc_Bank_Ac_no as varchar(30)) + '  '+ Bank_Code + '    ' +'C'+ Cast(RIGHT ('00000000000000' + cast(Net_Amount as varchar(17)),17) As varchar(20)) + ' BYSALARY' as text_string --added by krushna 18112019 for HMP                            
						INTO #FINAL_TABLE                            
						FROM #Emp_Salary MS                             
					   INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                            
					   INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
					   INNER JOIN  T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID                            
					   LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID                            
					   LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id                             
					   LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id                             
					   INNER JOIN  T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID                            
					   LEFT OUTER JOIN #BANK_MASTER bk on i_Q.Bank_ID = Bk.Bank_ID                            
					   LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_Q.Center_ID                            
					   INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID --ADDED BY JAINA 10-08-2015                              
					   LEFT OUTER JOIN #Total   tem on cm.cmp_id = tem.cmp_id  and ISNULL(I_q.Bank_ID,0) = ISNULL(tem.Bank_Id,0) -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
						WHERE E.Cmp_ID = @Cmp_Id                      
						 --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
						 and I_q.Payment_mode = @Payment_mode                              
						 and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
						 Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)                            
						 When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)                            
						 Else e.Alpha_Emp_Code  End                          
				               


     --Added By Ramiz on 18/03/2019                            
		 IF Len(isNull(@Bank_ID ,'')) > 0                            
		   delete from #FINAL_TABLE Where Bank_ID IS NULL                            
   

			 SELECT *,'CR' as CR,'SALARY' as NARRATION ,'N' as Txn,Emp_ID+2 as NEFT,@Ben_Email as Ben_Email,
			 'SLOR'+CONVERT(varchar(30),format(Month_End_Date,'ddMMyy'),112)+cast(format(SRNO,'00000') as varchar(30)) as Remark1, --added by ronakk 27012021
			 @Client_Code as Client_Code ,@Deb_Ac_No as Debt_AC_No
			 FROM #FINAL_TABLE  
	 
      END                            
      ELSE                            
      BEGIN                            
     print 247--mansi                   
     SELECT MS.*,Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Emp_full_Name,Branch_Address,branch_name,Comp_name,Grd_Name,DAteName(M,Month_End_Date)as Month,YEar(Month_End_Date)as Year                             
     ,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth , SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Net_Amount) as Net_Amount_In_Word                              
     ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name,                               
     Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No As Cmp_Acc_No,I_Q.Inc_Bank_Ac_no,I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no1,                            
    Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(tem.Total_Amount as varchar(15)),15) As varchar(20)) Else CAST(tem.Total_Amount as varchar(30)) End As Total_Amount,                            
     dbo.F_Number_TO_Word(tem.Total_Amount) as Total_Amount_In_Word                              
     ,@Payment_mode as Payment_Mode,bk.Bank_ID,bk.Bank_Address  --Changed by Falak on 01-FEB-2011                              
     ,E.Ifsc_Code,BM.Branch_ID,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , -- added by mitesh on 08052012,                            
     Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)) End As Net_Amt                            
     ,CDD.Director_Name,CDD.Director_Designation                            
     ,bk.Bank_BSR_Code   --added jimit 27042016                            
                                      
                            
   INTO #FINAL_TABLE1                            
   FROM #Emp_Salary MS                             
      Inner join  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                      
      inner join  T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                               
      inner join  T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID                            
      LEFT OUTER JOIN  T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID                            
      LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id                            
      LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id                            
      INNER JOIN  T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID                     
      Left outer Join  #BANK_MASTER bk on i_Q.Bank_ID = Bk.Bank_ID                            
      INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID                            
      LEFT OUTER JOIN  #Total   tem on cm.cmp_id = tem.cmp_id and I_q.Bank_ID = tem.Bank_Id                            
      LEFT OUTER JOIN                            
    (SELECT top 1 * FROM T0010_COMPANY_DIRECTOR_DETAIL WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID ) CDD ON CDD.Cmp_Id = CM.Cmp_Id          
   WHERE E.Cmp_ID = @Cmp_Id                               
     --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
     and I_q.Payment_mode = @Payment_mode                              
     and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
    Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)                            
  When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)                            
   Else e.Alpha_Emp_Code                            
     End                            
                                   
     --Added By Ramiz on 18/03/2019                            
     IF Len(isNull(@Bank_ID ,'')) > 0                            
   delete from #FINAL_TABLE1 Where Bank_ID IS NULL                            
          
     SELECT * FROM #FINAL_TABLE1                            
      END                            
    END                          
 Else If @Report_For = 2                           
     BEGIN                        
    print '11-SBI'                        
                                      
    SELECT MS.*,Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Emp_full_Name,Branch_Address,Branch_name,Comp_name,Grd_Name,DAteName(M,Month_End_Date)as Month,YEar(Month_End_Date)as Year                            
      ,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth,SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Net_Amount) as Net_Amount_In_Word                              
      ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name,                             
      Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No As Cmp_Acc_No, I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no,I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no1,                            
      Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(tem.Total_Amount as varchar(15)),15) As varchar(20)) Else CAST(tem.Total_Amount as varchar(30)) End As Total_Amount,                            
      dbo.F_Number_TO_Word(tem.Total_Amount) as Total_Amount_In_Word,CCM.Center_Name --Added by Jaina 10-08-2015                                   
      ,@Payment_mode as Payment_Mode,bk.Bank_ID,bk.Bank_Address  --Changed by Falak on 01-FEB-2011                              
      ,E.Ifsc_Code,BM.Branch_ID,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , -- added by mitesh on 08052012,                  
      Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)) End As Net_Amt                            
      ,bk.Bank_BSR_Code  , CONVERT(varchar(30), Month_End_Date,112) as Month_Last_Date --added jimit 27042016                            
      ,E.Emp_First_Name , E.Emp_Last_Name , cm.Cmp_Email , @Export_Type as Export_Type                            
      ,cast(I_Q.Inc_Bank_Ac_no as varchar(30)) + '  '+ Bank_Code + '    ' +'C'+ Cast(RIGHT ('00000000000000' + cast(Net_Amount as varchar(17)),17) As varchar(20)) + ' BYSALARY' as text_string --added by krushna 18112019 for HMP                            
                                                     
     INTO #FINAL_TABLE2                            
     FROM #Emp_Salary MS                             
    INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                            
    INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
    INNER JOIN  T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID                            
    LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID                            
    LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id                             
    LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id                             
    INNER JOIN  T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID                            
    LEFT OUTER JOIN #BANK_MASTER bk on i_Q.Bank_ID = Bk.Bank_ID                            
    LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_Q.Center_ID                
    INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID --ADDED BY JAINA 10-08-2015                              
    LEFT OUTER JOIN #Total   tem on cm.cmp_id = tem.cmp_id  and ISNULL(I_q.Bank_ID,0) = ISNULL(tem.Bank_Id,0) -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
     WHERE E.Cmp_ID = @Cmp_Id                               
      --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
      and I_q.Payment_mode = @Payment_mode                              
      and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
      Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)                    
      When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)                            
      Else e.Alpha_Emp_Code                            
      End                            
      --Added By Ramiz on 18/03/2019                            
      IF Len(isNull(@Bank_ID ,'')) > 0                            
    delete from #FINAL_TABLE2 Where Bank_ID IS NULL                            
                                    
      --SELECT * FROM #FINAL_TABLE2                           
                            
    SELECT E.cmp_Id,bk.Bank_ID,E.Emp_ID as Id,E.Alpha_Emp_Code as Code,'CR' as Pay_As,Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Account_Name,                        
    I_Q.Inc_Bank_Ac_no as Bank_Ac_No,    
    (case when E.Ifsc_Code like '%SBI%' then  TRIM('SBI' FROM E.Ifsc_Code) else E.Ifsc_Code end)as Bank_BSR_Code,    
    --right(E.Ifsc_Code,5) as Bank_BSR_Code,        
    ms.Net_Amount as Amount,        
    --sum(ms.Net_Amount)as totalamt,        
    --Cast(Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)) End as numeric(18,2)) As Amount,                        
    Format(getdate(),'dd-MM-yyyy') as Date_of_Transaction,                        
    Bk.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))+(E.Alpha_Emp_Code) as UniqueRefNo,                        
    'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10))) as Description,                        
    Bank_Ac_No+'#'+(case when E.Ifsc_Code like '%SBI%' then  TRIM('SBI' FROM E.Ifsc_Code) else E.Ifsc_Code end)+'#'+Format(getdate(),'dd/MM/yyyy')+'##'+(Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)        
      )End)+'#'+Bk.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))+'#'+Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name)+'#'+'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))as Text_String,bk.Bank_Name,bk.Bank_Code                      
     ,Cm.Cmp_Address    
     INTO #TABLE_Emp_SBI                            
     FROM #Emp_Salary MS                             
    INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                            
    INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
    LEFT OUTER JOIN T0040_BANK_MASTER bk on I_Q.Bank_ID = Bk.Bank_ID        --LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_Q.Center_ID                            
    INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID --ADDED BY JAINA 10-08-2015                              
    LEFT OUTER JOIN #Total   tem on cm.cmp_id = tem.cmp_id  and ISNULL(I_q.Bank_ID,0) = ISNULL(tem.Bank_Id,0) -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
     WHERE E.Cmp_ID = @Cmp_Id            and Bank_Code like '%SBI%'                
      --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
      and I_q.Payment_mode = @Payment_mode                              
      and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
      Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)                            
      When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)                            
      Else e.Alpha_Emp_Code                            
      End           
              
        Select distinct (e.Amount)as Net_amt,e.Account_Name,Cmp_ID  
  into #Totlsum  
  from #TABLE_Emp_SBI e  
       Where Cmp_id =@Cmp_ID     
    
    --select * from #Totlsum  
  
      select Cm.Cmp_Id,B.Bank_ID,''as Id,'' as Code,'DR' as Pay_As,cm.Cmp_Name as Account_Name,b.Bank_Ac_No,     
      (case when B.Bank_BSR_Code like '%SBI%' then  TRIM('SBI' FROM B.Bank_BSR_Code) else B.Bank_BSR_Code end)as Bank_BSR_Code,    
     -- (case when B.bank_Code like '%SBI%' then right(B.Bank_BSR_Code,5) else B.Bank_BSR_Code end) as Bank_BSR_Code,--cast(Sum(FT2.Net_Amount)as numeric(18,2))as Amount        
      --sum(cast(es.Amount as numeric(18,2)))as Amount        
     sum(ts.Net_amt) as Amount        
      --sum(es.Amount)as Amount        
    -- (Ts.TotalAmount)as Amount        
      ,Format(getdate(),'dd-MM-yyyy') as Date_of_Transaction                        
      ,B.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))+'000' as UniqueRefNo,                        
      'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10))) as Description,                        
      B.Bank_Ac_No+'#'+(case when B.Bank_BSR_Code like '%SBI%' then  TRIM('SBI' FROM B.Bank_BSR_Code) else B.Bank_BSR_Code end)+'#'+Format(getdate(),'dd/MM/yyyy')+'#'+cast((sum(ts.Net_amt))as varchar)+'##'+B.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast (Year(@To_Date)as varchar(10)))+'000'+'#'+cm.Cmp_Name+'#'+ 'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10))) as Text_String                         
      ,b.Bank_Name ,b.Bank_Code     
       ,Cm.Cmp_Address    
      into #SBICmpDetail                        
      from T0010_COMPANY_MASTER CM          
      --inner join #totalEmp_sumSBI TS with(nolock) on Ts.Cmp_ID=Cm.Cmp_Id        
      left join T0040_BANK_MASTER B with(nolock) on cm.Cmp_Id=B.Cmp_Id            
      left join  #Totlsum TS with(nolock) on Cm.Cmp_Id=ts.Cmp_Id  
      --left join #TABLE_Emp_SBI ES with(nolock) on es.Cmp_ID=cm.Cmp_Id        
     -- left join #FINAL_TABLE2 FT2 on FT2.Cmp_ID=B.Cmp_Id                        
      -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
     WHERE B.Cmp_ID = @Cmp_Id   and B.Is_Default='Y'                        
     group by Cm.Cmp_Name,b.Bank_Ac_No,b.Bank_BSR_Code,b.Bank_Code,CM.Cmp_Id,B.Bank_ID,b.Bank_Name ,b.Bank_Code,Cm.Cmp_Address --,ts.TotalAmount                            
      --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
                          
    --select Distinct * from  #SBICmpDetail                        
                           
                        
                          
       --select  lbl as Pay_As,Account_Name,Bank_Ac_No as Account_No,Bank_BSR_Code as BR_Code,Amount,Date_of_Transaction,UniqueRefNo,Description,Text_String                      
       --from (                        
       --select  distinct Cmp_Id,Bank_ID,lbl,Account_Name,Bank_Ac_No,Bank_BSR_Code,Amount,Date_of_Transaction,UniqueRefNo,Description,Text_String,Bank_Name,Bank_Code  from #SBICmpDetail where Cmp_Id=@Cmp_ID                      
       --union                         
       --select  distinct Cmp_ID,Bank_ID,lbl,Account_Name,Bank_Ac_No,Bank_BSR_Code,Amount,Date_of_Transaction,UniqueRefNo,Description,Text_String,Bank_Name,Bank_Code from  #TABLE_Emp_SBI   where @Cmp_ID=@Cmp_ID and Bank_Code like '%SBI%'                  
  
    
       --)as T  order by lbl desc          
               
      CREATE TABLE #sbifinaltbl ( Pay_As varchar(5) not null,Account_Name varchar(250),Account_No varchar(30) null,Bank_BSR_Code varchar(25),Amount numeric(18,2),Date_of_Transaction nvarchar(30),UniqueRefNo nvarchar(250),Description nvarchar(500),Text_String nvarchar(800),Cmp_Address varchar(500))            
        Insert into   #sbifinaltbl                       
       select  distinct Pay_As,Account_Name,Bank_Ac_No as Account_No,Bank_BSR_Code,Amount,Date_of_Transaction,UniqueRefNo,Description,Text_String,Cmp_Address  from #SBICmpDetail where Cmp_Id=@Cmp_ID                      
       union                         
       select  distinct Pay_As,Account_Name,Bank_Ac_No as Account_No,Bank_BSR_Code,Amount,Date_of_Transaction,UniqueRefNo,Description,Text_String,Cmp_Address from  #TABLE_Emp_SBI   where @Cmp_ID=@Cmp_ID and Bank_Code like '%SBI%'                      
            
     select Pay_As,Account_Name,Account_No,Bank_BSR_Code,Amount,Date_of_Transaction,Upper(UniqueRefNo)as UniqueRefNo,UPPER(Description)as Description,UPPER(Text_String)as  Text_String,Cmp_Address  
      --,((cast(DATEDIFF(mm, @To_Date, @From_Date)as varchar(10)))+'/'+(cast(DATEDIFF(yyyy, @To_Date, @From_Date)as varchar(10)))) AS Mon_Yr  
  ,format(@From_Date,'dd-MM-yyyy') as From_Date,format(@To_Date,'dd-MM-yyyy') as To_Date,(Format(@To_Date,'MM')+'/'+Format(@To_Date,'yyyy'))as Mon_Yr  
  into #TmpFnlSbi        
     from #sbifinaltbl order by Pay_As desc        
              
      select row_number() over (order by Date_of_Transaction) as Sr_NO,*  from #TmpFnlSbi        
              
                                               
       print 10000                        
    --   SELECT * FROM #TbFinalSBI                           
                            
  END                    
  Else If @Report_For = 3                           
     BEGIN                  
    print '12-NON-SBI'                        
                           
     SELECT MS.*,Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Emp_full_Name,Branch_Address,Branch_name,Comp_name,Grd_Name,DAteName(M,Month_End_Date)as Month,YEar(Month_End_Date)as Year                            
    ,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth,SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Net_Amount) as Net_Amount_In_Word                              
    ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name,                             
    Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No As Cmp_Acc_No, I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no,I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no1,                            
    Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(tem.Total_Amount as varchar(15)),15) As varchar(20)) Else CAST(tem.Total_Amount as varchar(30)) End As Total_Amount,                            
    dbo.F_Number_TO_Word(tem.Total_Amount) as Total_Amount_In_Word,CCM.Center_Name --Added by Jaina 10-08-2015                                   
    ,@Payment_mode as Payment_Mode,bk.Bank_ID,bk.Bank_Address  --Changed by Falak on 01-FEB-2011                              
    ,E.Ifsc_Code,BM.Branch_ID,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , -- added by mitesh on 08052012,                            
    Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)) End As Net_Amt                            
    ,bk.Bank_BSR_Code  , CONVERT(varchar(30), Month_End_Date,112) as Month_Last_Date --added jimit 27042016                            
    ,E.Emp_First_Name , E.Emp_Last_Name , cm.Cmp_Email , @Export_Type as Export_Type                            
    ,cast(I_Q.Inc_Bank_Ac_no as varchar(30)) + '  '+ Bank_Code + '    ' +'C'+ Cast(RIGHT ('00000000000000' + cast(Net_Amount as varchar(17)),17) As varchar(20)) + ' BYSALARY' as text_string --added by krushna 18112019 for HMP                            
                                                     
      INTO #FINAL_TABLE3                            
      FROM #Emp_Salary MS                             
     INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                     
     INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
     INNER JOIN  T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID                            
     LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID                            
     LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id                             
     LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id                             
     INNER JOIN  T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID                            
     LEFT OUTER JOIN #BANK_MASTER bk on i_Q.Bank_ID = Bk.Bank_ID                            
     LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_Q.Center_ID                            
     INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID --ADDED BY JAINA 10-08-2015                              
     LEFT OUTER JOIN #Total   tem on cm.cmp_id = tem.cmp_id  and ISNULL(I_q.Bank_ID,0) = ISNULL(tem.Bank_Id,0) -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
      WHERE E.Cmp_ID = @Cmp_Id                               
    --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
    and I_q.Payment_mode = @Payment_mode                              
    and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
    Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)                    
    When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)                            
    Else e.Alpha_Emp_Code                            
    End                            
    --Added By Ramiz on 18/03/2019                            
    IF Len(isNull(@Bank_ID ,'')) > 0                            
     delete from #FINAL_TABLE3 Where Bank_ID IS NULL                            
                                    
    --SELECT * FROM #FINAL_TABLE3                          
                            
    
     
                                       
     SELECT E.cmp_Id,bk.Bank_ID,E.Emp_ID as Id,E.Alpha_Emp_Code as Code,'CR' as Pay_As,Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Account_Name,                        
     I_Q.Inc_Bank_Ac_no as Bank_Ac_No,E.Ifsc_Code as Bank_BSR_Code,                      
     Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30)) End As Amount,                        
     Format(getdate(),'dd-MM-yyyy') as Date_of_Transaction,                        
     Bk.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))+(E.Alpha_Emp_Code)  as UniqueRefNo,                        
     'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10))) as Description,                        
     Bank_Ac_No+'#'+E.Ifsc_Code+'#'+Format(getdate(),'dd/MM/yyyy')+'##'+(Case When Bank_Name like '%UTI%' or Bank_Name like '%Axis%' Then Cast(RIGHT ('000000000000' + cast(Net_Amount as varchar(15)),15) As varchar(20)) Else CAST(Net_Amount as varchar(30))
  
  End)+'#'+Bk.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))+'#'+Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name)+'#'+'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date) as varchar(10)))
as Text_String,bk.Bank_Name,bk.Bank_Code                      
      ,cm.Cmp_Address    
  INTO #TABLE_Emp_NonSBI                            
      FROM #Emp_Salary MS                             
     INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                            
     INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                            
     LEFT OUTER JOIN T0040_BANK_MASTER bk on I_Q.Bank_ID = Bk.Bank_ID        --LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = I_Q.Center_ID                            
     INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID --ADDED BY JAINA 10-08-2015                              
     LEFT OUTER JOIN #Total   tem on cm.cmp_id = tem.cmp_id  and ISNULL(I_q.Bank_ID,0) = ISNULL(tem.Bank_Id,0) -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
      WHERE E.Cmp_ID = @Cmp_Id            and Bank_Code not like '%SBI%'                    
    --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
    and I_q.Payment_mode = @Payment_mode                              
    and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
    Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)                            
    When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)                            
    Else e.Alpha_Emp_Code                            
    End          
      
  
     Select distinct cast((e.Amount)as numeric(18,2))as Net_amt,e.Account_Name,Cmp_ID  
  into #TotlsumNonSBI  
  from #TABLE_Emp_NonSBI e  
       Where Cmp_id =@Cmp_ID     
  --select * from #TotlsumNonSBI  
  
  select Cm.Cmp_Id,B.Bank_ID,''as Id,'' as Code,'DR' as Pay_As,cm.Cmp_Name as Account_Name,b.Bank_Ac_No,    
  (case when b.bank_code like '%SBI%' then  TRIM('SBI' FROM b.Bank_BSR_Code) else b.Bank_BSR_Code end)as Bank_BSR_Code,    
  sum(ts.Net_amt)as Amount  
  ,Format(getdate(),'dd-MM-yyyy') as Date_of_Transaction                        
  ,B.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10)))+'000' as UniqueRefNo,                        
  'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10))) as Description,                        
  Bank_Ac_No+'#'+(case when b.bank_code like '%SBI%' then  TRIM('SBI' FROM b.Bank_BSR_Code) else b.Bank_BSR_Code end)+'#'+Format(getdate(),'dd/MM/yyyy')+'#'+cast((sum(ts.Net_amt))as varchar)+'##'+B.Bank_Code+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(
cast(Year(@To_Date)as varchar(10)))+'000'+'#'+cm.Cmp_Name+'#'+ 'SALARY'+CAST(DATENAME(month, @To_Date) AS varCHAR(3))+(cast(Year(@To_Date)as varchar(10))) as Text_String               
  ,b.Bank_Name ,b.Bank_Code                         
  ,cm.Cmp_Address    
  into #NonSBICmpDetail                        
  from T0010_COMPANY_MASTER CM                        
  inner join T0040_BANK_MASTER B with(nolock) on cm.Cmp_Id=B.Cmp_Id                        
  left join #TotlsumNonSBI TS with(nolock) on ts.Cmp_ID=cm.Cmp_Id  
  -- Bank_Id Join Comment by Ankit while Open cash employee..total amount not get in Report                             
    WHERE B.Cmp_ID = @Cmp_Id   and B.Is_Default='Y'                        
    group by Cm.Cmp_Name,b.Bank_Ac_No,b.Bank_BSR_Code,b.Bank_Code,CM.Cmp_Id,B.Bank_ID,b.Bank_Name ,b.Bank_Code,cm.Cmp_Address                             
  --and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0)) -- and Salary_Amount >0                            
                          
       --select Distinct * from  #NonSBICmpDetail  
  
      CREATE TABLE #nonsbifinaltbl ( Pay_As varchar(5) not null,Bank_Ac_No varchar(30) null,BR_code varchar(25),IFSC_Code varchar(25),Date_of_Transaction nvarchar(30),Dr_Amonut numeric(18,2),Cr_Amount numeric(18,2),UniqueRefNo nvarchar(250),Account_Name varchar(250),Description nvarchar(500),Text_String nvarchar(800),Cmp_Address varchar(500))            
      Insert into   #nonsbifinaltbl                       
     select  distinct Pay_As,Bank_Ac_No,Bank_BSR_Code as BR_Code,'' as IFSC_Code,Date_of_Transaction,Amount as Dr_Amount,'0.00' as Cr_Amount,UniqueRefNo,Account_Name,Description,Text_String,Cmp_Address  from #NonSBICmpDetail where Cmp_Id=@Cmp_ID          
           
     union  all                       
     select  distinct Pay_As,Bank_Ac_No,'' as BR_Code,Bank_BSR_Code as IFSC_Code,Date_of_Transaction,'0.00' as Dr_Amount,Amount as Cr_Amount,UniqueRefNo,Account_Name,Description,Text_String,Cmp_Address from  #TABLE_Emp_NonSBI   where @Cmp_ID=@Cmp_ID and Bank_Code not like '%SBI%'                      
                        
      select Pay_As,Bank_Ac_No,BR_code,IFSC_Code,Date_of_Transaction,Dr_Amonut,Cr_Amount,Upper(UniqueRefNo)as UniqueRefNo,Account_Name,upper(Description)as Description,UPPER(Text_String)as Text_String,Cmp_Address,  
   format(@From_Date,'dd-MM-yyyy') as From_Date,format(@To_Date,'dd-MM-yyyy') as To_Date
   ,(Format(@To_Date,'MM')+'/'+Format(@To_Date,'yyyy'))as Mon_Yr  
  into #NonSBITMP      
  from #nonsbifinaltbl order by Pay_As desc          
 select  row_number() over (order by Date_of_Transaction) as Sr_NO ,* from #NonSBITMP      
      --select row_number() over (order by Account_Name) as Sr_NO ,* from #nonsbifinaltbl order by lbl desc            
      --select row_number() over (order by NSF.Account_Name) as Sr_NO ,NSF.Cmp_Id,NSF.Bank_Ac_No as Account_No,NSCD.Bank_BSR_Code as BR_Code,ENS.Bank_BSR_Code as IFSC_Code,            
      --NSF.Date_of_Transaction,NSCD.Amount as Dr_Amount,ENS.Amount as Cr_Amount,NSF.UniqueRefNo,NSF.Account_Name,NSF.Description,NSF.Text_String            
      --from  #nonsbifinaltbl  NSF            
      --left join #NonSBICmpDetail NSCD  on NSCD.Cmp_Id=NSF.Cmp_Id            
--left join #TABLE_Emp_NonSBI ENS on ENS.Cmp_ID=NSF.Cmp_Id            
            
                      
   --   SELECT * FROM #TbFinalSBI                           
                           
                        
  END                        
   ELSE                            
    BEGIN                          
                         
     Declare @Fix_column varchar(8)                            
     Declare @Account_No varchar(11)                            
     Declare @Amount varchar(16)                            
     Declare @Text varchar(65)                            
     Declare @text1 Varchar(65)                            
     Declare @Final_String varchar(102)                            
                            
     Set @Fix_column = '01000000'                            
     Set @Text = 'SALARY CREDITED FOR THE MONTH OF'                            
     Set @Text1 = 'DEBITED SALARY FOR THE MONTH OF'                            
                            
                            
     SELECT @Fix_column + Right( '00000000000' + Cast(Isnull(I.Inc_Bank_AC_No,0) as varchar(100)),11) +                             
    Right('0000000000000000' + Cast(Replace(M.Net_Amount,'.','') as Varchar(100)),16)  + ' ' +                             
    Left(@Text + ' ' + DATENAME(MONTH,M.Month_End_Date) + ' ' + cast(Year(M.Month_End_Date) as varchar(100)) + '00000000000000000000000000000000000000000000000000000000000000000',65)                            
    As Final_String                            
    ,EM.Alpha_Emp_Code,Isnull(EmpName_Alias_PrimaryBank,Emp_full_Name) As Emp_full_Name,M.Month_St_Date,M.Month_End_Date                            
                                    
     FROM T0200_MONTHLY_SALARY M WITH (NOLOCK)                            
   INNER JOIN T0095_Increment I WITH (NOLOCK) on M.Emp_ID = I.Emp_ID and m.Increment_ID = i.Increment_ID                            
   INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON M.Emp_ID = EM.Emp_ID                            
   INNER JOIN #Emp_Cons ec ON M.Emp_ID =ec.emp_ID                              
     WHERE --Month(M.Month_End_Date)=@Month and year(M.Month_End_Date)=@Year And I.Bank_ID=@Bank_Id                            
    M.Cmp_ID = @Cmp_Id --and ISNULL(I.Bank_ID,0) = ISNULL(@Bank_ID,ISNULL(I.Bank_ID,0))                            
    AND I.Payment_mode = @Payment_mode                              
    AND Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) =Year(@To_Date)                            
    AND ISNULL(Is_FNF,0) = 0                            
    AND M.Net_Amount > 0                             
                                  
     UNION ALL                            
                            
     SELECT RIGHT('00000000000' + Cast(Isnull(B.Bank_Ac_No,0) as varchar(100)),19) +                             
    RIGHT('0000000000000000' + Cast(Replace(Sum(M.Net_Amount),'.','') as Varchar(100)),16)  + ' ' +                             
    LEFT(@Text1 + ' ' + DATENAME(MONTH,M.Month_St_Date) + ' ' + cast(Year(M.Month_St_Date) as varchar(100)) + '00000000000000000000000000000000000000000000000000000000000000000',65)                            
    As Final_String                             
    , NULL,NULL, NULL,NULL                            
     FROM T0200_MONTHLY_SALARY M WITH (NOLOCK)                            
   INNER JOIN  T0095_Increment I WITH (NOLOCK) on M.Emp_ID = I.Emp_ID and m.Increment_ID = i.Increment_ID                            
   INNER JOIN #BANK_MASTER B on I.Bank_ID = B.Bank_ID                            
   INNER JOIN  #Emp_Cons ec ON M.Emp_ID =ec.emp_ID                             
     WHERE --Month(M.Month_End_Date)=@Month and year(M.Month_End_Date)=@Year and I.Bank_ID=@Bank_Id                            
    M.Cmp_ID = @Cmp_Id --and ISNULL(I.Bank_ID,0) = ISNULL(@Bank_ID,ISNULL(I.Bank_ID,0))                            
    AND I.Payment_mode = @Payment_mode                              
    AND Month(M.Month_St_Date) = Month(@To_Date) and Year(M.Month_St_Date) =Year(@To_Date) AND ISNULL(Is_FNF,0) = 0                            
    AND M.Net_Amount > 0                             
     GROUP BY Month_St_Date,Bank_Ac_No                            
    END                            
  END                            
 ELSE IF @Report_Type = 'Details'                            
  BEGIN                            
    IF @Employee_Type = 'ALL'                            
  BEGIN                            
    SELECT ( '="' + E.Alpha_Emp_Code + '"') as Alpha_Emp_Code , Isnull(E.EmpName_Alias_PrimaryBank,E.Emp_full_Name) As Emp_full_Name , REPLACE(CONVERT(VARCHAR(20) , E.DATE_OF_JOIN , 106),' ','-') AS Date_of_Join ,                             
   CASE WHEN E.Emp_Left = 'Y' THEN 'Left Employee' ELSE 'Active Employee' END AS Employee_Status,                            
   CM.Cat_Name , I_Q.Payment_Mode , BK.Bank_Name , ( '="' + I_Q.Inc_Bank_AC_No + '"') as Inc_Bank_Ac_No  , E.Ifsc_Code , MS.Net_Amount                                   
   ,E.Bank_BSR -- Added by Sajid 28-01-2021 for Molkem Client                            
   ,'Salary ' + DATENAME(month, @TO_DATE) +'' +Convert(Varchar(4),DATEPART(Year,@TO_DATE)) AS 'Narration' -- Added by Sajid 28-01-2021 for Molkem Client                            
    FROM #EMP_SALARY MS                            
  INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON MS.emp_ID = E.emp_ID                             
  INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) ON E.Increment_ID = I_Q.Increment_ID                            
  LEFT OUTER JOIN #BANK_MASTER BK ON I_Q.Bank_ID = BK.Bank_ID                            
  LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I_Q.Cat_ID = CM.Cat_ID                            
    WHERE I_Q.Payment_Mode = @Payment_mode                            
 END                            
   ELSE IF @Employee_Type = 'Current'                            
    BEGIN                            
   --REMOVING LEFT EMPLOYEES                            
   DELETE ES                            
   FROM #EMP_SALARY ES                            
    INNER JOIN  T0080_EMP_MASTER EM ON ES.EMP_ID = EM.emp_ID                             
   WHERE EM.Emp_Left_Date BETWEEN ES.Month_St_Date and ES.Month_End_Date            
                            
    SELECT ( '="' + E.Alpha_Emp_Code + '"') as Alpha_Emp_Code , Isnull(E.EmpName_Alias_PrimaryBank,E.Emp_full_Name) As Emp_full_Name , REPLACE(CONVERT(VARCHAR(20) , E.DATE_OF_JOIN , 106),' ','-') as Date_of_Join  ,                             
     CASE WHEN E.Emp_Left = 'Y' THEN 'Left Employee' ELSE 'Active Employee' END AS Employee_Status,                            
     CM.Cat_Name , I_Q.Payment_Mode , BK.Bank_Name , ( '="' + I_Q.Inc_Bank_AC_No + '"') as Inc_Bank_Ac_No   , E.Ifsc_Code , MS.Net_Amount                            
     ,E.Bank_BSR -- Added by Sajid 28-01-2021 for Molkem Client                            
     ,'Salary ' + DATENAME(month, @TO_DATE) +'' +Convert(Varchar(4),DATEPART(Year,@TO_DATE)) AS 'Narration' -- Added by Sajid 28-01-2021 for Molkem Client                            
   FROM #EMP_SALARY MS                            
    INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON MS.emp_ID = E.emp_ID                             
    INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) ON MS.Increment_ID = I_Q.Increment_ID                            
    LEFT OUTER JOIN #BANK_MASTER BK ON I_Q.Bank_ID = BK.Bank_ID                            
    LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I_Q.Cat_ID = CM.Cat_ID                            
   WHERE I_Q.Payment_Mode = @Payment_mode                            
    END                            
   ELSE IF @Employee_Type = 'Left'                            
    BEGIN                            
     SELECT ( '="' + E.Alpha_Emp_Code + '"') as Alpha_Emp_Code , Isnull(E.EmpName_Alias_PrimaryBank,E.Emp_full_Name) As Emp_full_Name , REPLACE(CONVERT(VARCHAR(20) , E.DATE_OF_JOIN , 106),' ','-') AS Date_of_Join ,                             
      CASE WHEN E.Emp_Left = 'Y' THEN 'Left Employee' ELSE 'Active Employee' END AS Employee_Status,                            
      CM.Cat_Name , I_Q.Payment_Mode , BK.Bank_Name , ( '="' + I_Q.Inc_Bank_AC_No + '"') as Inc_Bank_Ac_No   , E.Ifsc_Code , MS.Net_Amount                            
      ,E.Bank_BSR  -- Added by Sajid 28-01-2021 for Molkem Client                            
      ,'Salary ' + DATENAME(month, @TO_DATE) +'' +Convert(Varchar(4),DATEPART(Year,@TO_DATE)) AS 'Narration' -- Added by Sajid 28-01-2021 for Molkem Client                            
    FROM #EMP_SALARY MS                            
     INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON MS.emp_ID = E.emp_ID                             
     INNER JOIN  T0095_Increment I_Q WITH (NOLOCK) ON MS.Increment_ID = I_Q.Increment_ID                            
     LEFT OUTER JOIN #BANK_MASTER BK ON I_Q.Bank_ID = BK.Bank_ID                            
     LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON I_Q.Cat_ID = CM.Cat_ID                            
    WHERE I_Q.Payment_Mode = @Payment_mode                             
     AND E.Emp_Left_Date BETWEEN Ms.Month_St_Date and Ms.Month_End_Date                            
   END                            
  END                            
 ELSE IF @Report_Type = 'Summary'                            
  BEGIN                            
  CREATE TABLE #TOTAL_SUMMARY                            
   (                            
    Sr_No   NUMERIC(18,0) IDENTITY NOT NULL,                             
    Particular  VARCHAR(72),                          
    Head_Count  NUMERIC(18,0),                            
    Net_Amount NUMERIC(18,2),                            
   )                            
                               
   /* FOR BINDING COLUMNS */                            
   IF @IS_COLUMN = 1                             
    BEGIN                        
  print 500                        
   SELECT TOP 0 * FROM #TOTAL_SUMMARY                            
   RETURN                             
  END                            
                               
   --INSERTING ALL DONE SALARY                            
   INSERT INTO #TOTAL_SUMMARY                            
    SELECT CASE WHEN MS.SALARY_STATUS = 'Done' And I_q.Payment_mode = 'Bank Transfer'                             
     THEN 'All Bank Payment'                             
    WHEN MS.SALARY_STATUS = 'Done' And I_q.Payment_mode = 'Cheque'                             
     THEN 'Cheque Payment'                            
    WHEN MS.SALARY_STATUS = 'Done' And I_q.Payment_mode = 'Cash'                            
     THEN 'Cash Payment'                            
    WHEN MS.SALARY_STATUS = 'Hold' And I_q.Payment_mode = 'Bank Transfer'                             
     THEN 'Bank Transfer - Resigned & Hold Case'                             
    WHEN MS.SALARY_STATUS = 'Hold' And I_q.Payment_mode = 'Cheque'                             
     THEN 'Cheque - Resigned & Hold Case'                            
    WHEN MS.SALARY_STATUS = 'Hold' And I_q.Payment_mode = 'Cash'                            
     THEN 'Cash - Resigned & Hold Case'                             
    ELSE I_q.Payment_mode END , COUNT(MS.Emp_ID) , ISNULL(Sum(Isnull(Net_Amount,0)),0)                            
    FROM #EMP_SALARY MS                            
  INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID                            
  INNER JOIN T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID                               
    WHERE MS.Cmp_ID = @Cmp_Id                             
    GROUP BY MS.SALARY_STATUS , I_Q.PAYMENT_MODE                            
                               
                               
   --INSERTING ZERO SALARY IN SUMMARY                            
    INSERT INTO #Total_Summary                            
    SELECT 'Zero Payment' , COUNT(MS.Emp_ID) , 0                            
    FROM #Emp_Salary MS                            
    WHERE MS.Cmp_ID = @Cmp_Id AND NET_AMOUNT = 0                            
                               
    --INSERTING NEGATIVE SALARY IN SUMMARY                            
    INSERT INTO #Total_Summary                 
    SELECT 'Negative Salary' , COUNT(MS.Emp_ID) , 0                            
    FROM #Emp_Salary MS                            
    WHERE MS.Cmp_ID = @Cmp_Id AND NET_AMOUNT < 0                            
                               
    --INSERTING TOTAL SALARY IN SUMMARY                            
  INSERT INTO #Total_Summary                            
    SELECT 'TOTAL SALARY' , COUNT(MS.Emp_ID) , ISNULL(SUM(ISNULL(Net_Amount,0)),0)                            
    FROM #Emp_Salary MS                            
    WHERE MS.Cmp_ID = @Cmp_Id                            
                               
  SELECT Sr_No , Particular , Head_Count , Net_Amount FROM #TOTAL_SUMMARY                            
   END                            
 RETURN 
