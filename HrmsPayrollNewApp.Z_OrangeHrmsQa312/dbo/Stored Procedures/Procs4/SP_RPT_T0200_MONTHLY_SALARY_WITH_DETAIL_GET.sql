

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0200_MONTHLY_SALARY_WITH_DETAIL_GET]        
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
 ,@constraint  varchar(5000)        
 ,@Sal_Type  numeric = 0        
      
      
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON        
         
        
 IF @Branch_ID = 0          
   set @Branch_ID = null        
          
 IF @Cat_ID = 0          
 set @Cat_ID = null        
        
 IF @Grd_ID = 0          
 set @Grd_ID = null        
        
 IF @Type_ID = 0          
 set @Type_ID = null        
        
 IF @Dept_ID = 0          
 set @Dept_ID = null        
        
 IF @Desig_ID = 0          
 set @Desig_ID = null        
        
 IF @Emp_ID = 0          
 set @Emp_ID = null        
        
 Declare @Emp_Cons Table        
  (        
 Emp_ID numeric        
   )        
         
 if @Constraint <> ''        
  begin        
    Insert Into @Emp_Cons        
    select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
  end        
 else        
   begin        
     Insert Into @Emp_Cons        
          
     select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join         
    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)       
    where Increment_Effective_date <= @To_Date        
    and Cmp_ID = @Cmp_ID        
    group by emp_ID  ) Qry on        
    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date         
                 
     Where Cmp_ID = @Cmp_ID         
     and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
     and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
     and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
     and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
     and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
     and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
     and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
     and I.Emp_ID in         
   ( select Emp_Id from        
   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry        
   where cmp_ID = @Cmp_ID   and          
   (( @From_Date  >= join_Date  and  @From_Date <= left_date )         
   or ( @To_Date  >= join_Date  and @To_Date <= left_date )        
   or Left_date is null and @To_Date >= Join_Date)        
   or @To_Date >= left_date  and  @From_Date <= left_date )         
  end        
           
  Declare @Emp_Salary Table        
  (        
   Cmp_ID    numeric,        
   Emp_ID    numeric,        
   Sal_Tran_ID   numeric,        
   Increment_ID  numeric,        
   Sal_Month   numeric,        
   Sal_Year   Numeric,        
   Salary_Amount  numeric(18,2),        
   Allowance_1   numeric(18,2),        
   Allowance_2   numeric(18,2),        
   Allowance_3   numeric(18,2),        
   Allowance_4   numeric(18,2),        
   Allowance_5   numeric(18,2),        
   Allowance_6   numeric(18,2),        
   Allowance_7   numeric(18,2),        
   Allowance_8   numeric(18,2),        
   Allowance_9   numeric(18,2),        
   Allowance_10  numeric(18,2),        
   Other_Allowance  numeric(18,0),        
   Gross_Salary  numeric(18,2),        
   PF_Calc_On_Amount numeric(18,2),        
   ESIC_Calc_On_Amount numeric(18,2),        
   PF_Amount   numeric(18,2),        
   ESIC_Amount   Numeric(18,2),        
   PT_Amount   numeric(18,2),        
   Adv_Amount   numeric(18,2),        
   Loan_Amount   numeric(18,2),         
   Deduction_1   numeric(18,2),        
   Deduction_2   numeric(18,2),        
   Deduction_3   numeric(18,2),        
   Deduction_4   numeric(18,2),        
   Deduction_5   numeric(18,2),        
   Other_Dedu_Amount numeric (18,2),         
   Net_Amount   numeric (18,2),        
   Sal_cal_Days  numeric(12,1),        
   Total_claim_Amount numeric (18,2),        
   Total_Dedu_Amount numeric (18,2) ,      
   P_Day numeric(5,2),      
   Ab_Day numeric(5,2),      
   Holiday numeric(5,2),      
   Weekoff_Day numeric(5,2),      
   OT_Amount numeric(18,2),      
   Total_Leave_Days numeric(5,2),  
   Actual_working_Hours varchar(50),  
   Hour_Salary  varchar(50)  
  
  
    
  )          
          
          
  Insert into @Emp_Salary ( Cmp_ID,Emp_ID,Sal_Tran_ID,Increment_ID,Sal_Month,Sal_Year,Salary_Amount,Allowance_1,Allowance_2,Allowance_3,Allowance_4,Allowance_5,Allowance_6,        
         Allowance_7,Allowance_8,Allowance_9,Allowance_10,Other_Allowance,Gross_Salary,PF_Calc_On_Amount,ESIC_Calc_On_Amount,PF_Amount,ESIC_Amount,PT_Amount,        
         Adv_Amount,Loan_Amount,Deduction_1,Deduction_2,Deduction_3,Deduction_4,Deduction_5 ,Other_Dedu_Amount,Net_Amount,Sal_cal_Days,Total_claim_Amount,Total_Dedu_Amount,P_Day,Ab_Day,Holiday,Weekoff_Day,OT_Amount,Total_Leave_Days,Actual_working_Hours,Hour_Salary )        
        
  SElect @cmp_ID,Emp_ID,null,null,month(@To_date),YEar(@To_date),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','' from @Emp_Cons              
        
        
  if @Sal_Type = 0        
   begin          
    Update  @Emp_Salary        
    set Increment_ID = ms.Increment_ID,        
     Sal_Month  =  Month(ms.Month_St_Date),        
     Sal_Year  =  Year(ms.Month_St_Date),        
     Salary_Amount =  ms.Salary_Amount,        
     Other_Allowance =  ms.Other_Allow_Amount,        
     Gross_Salary =  ms.Gross_Salary,        
     PT_Amount  =  ms.PT_Amount ,        
     Adv_Amount  =  ms.Advance_Amount,        
     Loan_Amount  =  ms.Loan_Amount,        
     Other_Dedu_Amount = ms.Other_Dedu_Amount ,        
     Net_Amount    = ms.Net_Amount,        
     Sal_cal_Days   = ms.Sal_cal_Days,        
     Total_claim_Amount = ms.Total_claim_Amount,        
     Total_Dedu_Amount = ms.Total_Dedu_Amount ,      
     P_Day =   ms.Present_Days,      
     Ab_Day =ms.Absent_Days,      
   Holiday =ms.Holiday_Days,      
   Weekoff_Day =ms.Weekoff_Days,      
   OT_Amount =ms.OT_Amount,      
   Total_Leave_Days =ms.Total_Leave_Days,     
   Actual_working_Hours=ms.Actual_working_Hours ,  
Hour_Salary=ms.Hour_Salary  
           
    From @Emp_Salary es Inner join T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID and Sal_month = month(ms.Month_end_Date)and Sal_Year = Year(ms.Month_end_Date)        
    Where ms.Cmp_ID = @Cmp_Id         
     and ms.Salary_Amount >0   And Isnull(IS_FNF,0)=1        
     and ms.Month_St_Date >=@From_Date and ms.Month_End_Date <=@To_Date        
             
             
             
   end         
    else if @sal_Type =1           
   begin            
    Update  @Emp_Salary        
     set Increment_ID = ms.Increment_ID,        
      Salary_Amount =  Salary_Amount + ms.S_Salary_Amount,        
      Other_Allowance =  Other_Allowance + ms.s_Other_Allow_Amount,        
      Gross_Salary =  Gross_Salary + ms.s_Gross_Salary,        
      PT_Amount  =  PT_Amount + ms.s_PT_Amount ,        
      Adv_Amount  =  Adv_Amount + ms.s_Advance_Amount,        
      Loan_Amount  =  Loan_Amount  + ms.s_Loan_Amount,        
      Other_Dedu_Amount = Other_Dedu_Amount + ms.s_Other_Dedu_Amount ,        
      Net_Amount    = Net_Amount + ms.s_Net_Amount,        
      Sal_cal_Days   = Sal_cal_Days + ms.S_M_Present_Days,        
      Total_claim_Amount = Total_claim_Amount + ms.s_Total_claim_Amount,        
      Total_Dedu_Amount = Total_Dedu_Amount + ms.s_Total_Dedu_Amount        
    From @Emp_Salary es Inner join T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID and Sal_month = month(ms.s_Month_end_Date)and Sal_YEar = Year(ms.s_Month_end_Date)        
    Where ms.Cmp_ID = @Cmp_Id         
     and ms.S_Net_Amount >0        
     and ms.s_Month_St_Date >=@From_Date and ms.s_Month_End_Date <=@To_Date        
   end        
  else if @Sal_Type =2         
   begin        
    Update  @Emp_Salary        
    set Increment_ID  = ms.Increment_ID,        
      Salary_Amount  =   Salary_Amount + ms.L_Salary_Amount,        
      Other_Allowance  =   Other_Allowance + ms.L_Other_Allow_Amount,        
      Gross_Salary  =   Gross_Salary + ms.l_Gross_Salary,        
      PT_Amount   =   PT_Amount + ms.l_PT_Amount ,        
      Adv_Amount   =   Adv_Amount + ms.L_Advance_Amount,        
      Loan_Amount   =   Loan_Amount  + ms.L_Loan_Amount,        
      Other_Dedu_Amount =   Other_Dedu_Amount + ms.l_Other_Dedu_Amount ,        
      Net_Amount   =   Net_Amount + ms.L_Net_Amount,        
      Sal_cal_Days  =   Sal_cal_Days + ms.L_Sal_cal_Days,        
      Total_Dedu_Amount =   Total_Dedu_Amount + ms.L_Total_Dedu_Amount        
    From @Emp_Salary es Inner join T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID and Sal_month = month(ms.L_Month_end_Date)and Sal_Year = Year(ms.L_Month_end_Date)        
    Where ms.Cmp_ID = @Cmp_Id         
     and ms.L_Salary_Amount >0        
     and ms.L_Month_St_Date >=@From_Date and ms.L_Month_End_Date <=@To_Date        
        
   end        
  else        
   begin        
    Update  @Emp_Salary        
    set Increment_ID = ms.Increment_ID,        
     Sal_Month  =  Month(ms.Month_St_Date),        
     Sal_Year  =  Year(ms.Month_St_Date),        
     Salary_Amount =  ms.Salary_Amount,        
     Other_Allowance =  ms.Other_Allow_Amount,        
     Gross_Salary =  ms.Gross_Salary,        
     PT_Amount  =  ms.PT_Amount ,        
     Adv_Amount  =  ms.Advance_Amount,        
     Loan_Amount  =  ms.Loan_Amount,        
     Other_Dedu_Amount = ms.Other_Dedu_Amount ,        
     Net_Amount    = ms.Net_Amount,        
     Sal_cal_Days   = ms.Sal_cal_Days,        
     Total_claim_Amount = ms.Total_claim_Amount,        
     Total_Dedu_Amount = ms.Total_Dedu_Amount        
    From @Emp_Salary es Inner join T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID and Sal_month = month(ms.Month_end_Date)and Sal_Year = Year(ms.Month_end_Date)        
    Where ms.Cmp_ID = @Cmp_Id         
     and ms.Salary_Amount >0        
     and ms.Month_St_Date >=@From_Date and ms.Month_End_Date <=@To_Date        
           
    Update  @Emp_Salary        
     set Increment_ID = ms.Increment_ID,        
      Salary_Amount =  Salary_Amount + ms.S_Salary_Amount,        
      Other_Allowance =  Other_Allowance + ms.s_Other_Allow_Amount,        
      Gross_Salary =  Gross_Salary + ms.s_Gross_Salary,        
      PT_Amount  =  PT_Amount + ms.s_PT_Amount ,        
      Adv_Amount  =  Adv_Amount + ms.s_Advance_Amount,        
      Loan_Amount  =  Loan_Amount  + ms.s_Loan_Amount,        
      Other_Dedu_Amount = Other_Dedu_Amount + ms.s_Other_Dedu_Amount ,        
      Net_Amount    = Net_Amount + ms.s_Net_Amount,        
      Sal_cal_Days   = Sal_cal_Days + ms.S_M_Present_Days,        
      Total_claim_Amount = Total_claim_Amount + ms.s_Total_claim_Amount,        
      Total_Dedu_Amount = Total_Dedu_Amount + ms.s_Total_Dedu_Amount        
    From @Emp_Salary es Inner join T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID and Sal_month = month(ms.s_Month_end_Date)and Sal_Year = Year(ms.s_Month_end_Date)        
    Where ms.Cmp_ID = @Cmp_Id         
     and ms.S_Net_Amount >0        
     and ms.s_Month_St_Date >=@From_Date and ms.s_Month_End_Date <=@To_Date        
        
    Update  @Emp_Salary        
    set Increment_ID  = ms.Increment_ID,        
      Salary_Amount  =   Salary_Amount + ms.L_Salary_Amount,        
      Other_Allowance  =   Other_Allowance + ms.L_Other_Allow_Amount,        
     Gross_Salary  =   Gross_Salary + ms.l_Gross_Salary,        
      PT_Amount   =   PT_Amount + ms.l_PT_Amount ,        
      Adv_Amount   =   Adv_Amount + ms.L_Advance_Amount,        
      Loan_Amount   =   Loan_Amount  + ms.L_Loan_Amount,        
      Other_Dedu_Amount =   Other_Dedu_Amount + ms.l_Other_Dedu_Amount ,        
      Net_Amount   =   Net_Amount + ms.L_Net_Amount,        
      Sal_cal_Days  =   Sal_cal_Days + ms.L_Sal_cal_Days,        
      Total_Dedu_Amount =   Total_Dedu_Amount + ms.L_Total_Dedu_Amount        
    From @Emp_Salary es Inner join T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID and Sal_month = month(ms.L_Month_end_Date)and Sal_year = Year(ms.L_Month_end_Date)        
    Where ms.Cmp_ID = @Cmp_Id         
     and ms.L_Salary_Amount >0        
     and ms.L_Month_St_Date >=@From_Date and ms.L_Month_End_Date <=@To_Date        
        
   end        
         
  if @Sal_Type = 1         
   begin        
  Update  @Emp_Salary        
  set  Allowance_1 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2) Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 21 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
              
  Update  @Emp_Salary        
  set Allowance_2 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 22 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
            
  Update  @Emp_Salary        
  set Allowance_3 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 23 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
             
  Update  @Emp_Salary        
  set Allowance_4 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 24 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
             
  Update  @Emp_Salary        
  set Allowance_5 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 25 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
             
         
  Update  @Emp_Salary        
  set Deduction_1 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 1 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
             
               
  Update  @Emp_Salary        
  set Deduction_2 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 2 and For_Date >=@From_DAte and For_Date <=@To_Date        
 group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
         
         
  Update  @Emp_Salary        
  set Deduction_3 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK)        
   Inner join @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 3 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
         
         
  Update  @Emp_Salary        
  set Deduction_4 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 4 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
         
         
  Update  @Emp_Salary        
  set Deduction_5 = M_AD_Amount         
  from @Emp_Salary es inner join         
  (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
   @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2)  Inner join         
   T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
  Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 5 and For_Date >=@From_DAte and For_Date <=@To_Date        
  group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
  end        
 else        
  begin        
    If @Sal_Type =3        
     set @Sal_Type = null        
   Update  @Emp_Salary        
   set  Allowance_1 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
     @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0))Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 11 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
                
   Update  @Emp_Salary        
   set Allowance_2 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 12 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
              
   Update  @Emp_Salary        
   set Allowance_3 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 13 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
              
   Update  @Emp_Salary        
   set Allowance_4 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 14 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
              
   Update  @Emp_Salary        
   set Allowance_5 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 15 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
              
          
   Update  @Emp_Salary        
   set Deduction_1 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 1 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
              
                
   Update  @Emp_Salary        
   set Deduction_2 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 2 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year     
          
          
   Update  @Emp_Salary        
   set Deduction_3 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad  WITH (NOLOCK)       
    Inner join @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 3 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
          
          
   Update  @Emp_Salary        
   set Deduction_4 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 4 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
          
          
   Update  @Emp_Salary        
   set Deduction_5 = M_AD_Amount         
   from @Emp_Salary es inner join         
   (select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join         
    @emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0)) Inner join         
    T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID         
   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 5 and For_Date >=@From_DAte and For_Date <=@To_Date        
   group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year        
                 
  end        
        
         
         
 Select MS.*,Emp_full_Name,Grd_Name,Branch_Address,Comp_name,branch_name        
   ,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,        
   SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(ms.Net_Amount) as Net_Amount_In_Word        
   ,Bank_Name ,CMP_NAME,CMP_ADDRESS,Sal_St_Date        
   ,Branch_Name,I_Q.Gross_Salary as CTC       
   From @Emp_Salary MS Inner join         
  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN         
   @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join         
   T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID INNER JOIN         
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join   
     T0040_General_setting GS WITH (NOLOCK) on I_Q.Branch_ID =GS.Branch_ID left outer join
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer Join         
     T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID inner join         
     T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID        
        
  WHERE E.Cmp_ID = @Cmp_Id and ms.Salary_Amount >0         
           
         
        
 RETURN         
    
    
        

