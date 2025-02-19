



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE    PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_12A_GET]    
  @Cmp_ID  numeric    
 ,@From_Date  datetime    
 ,@To_Date  datetime    
 ,@Branch_ID  numeric    
 ,@Cat_ID  numeric     
 ,@Grd_ID  numeric    
 ,@Type_ID  numeric    
 ,@Dept_ID  numeric    
 ,@Desig_ID  numeric    
 ,@Emp_ID  numeric    
 ,@constraint  varchar(max)    
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
     
 declare @PF_LIMIT  numeric    
 Declare @PF_DEF_ID  numeric     
     
 set @PF_DEF_ID =2    
      
 set @PF_LIMIT = 15000     
     
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
    

Declare @Month_Temp as numeric
Declare @Year_Temp as numeric
Declare @From_Date_Temp as datetime
Declare @To_Date_Temp as datetime
Declare @From_Date_Temp1 as datetime
Declare @To_Date_Temp1 as datetime

If MONTH(@From_Date) >= 4 And MONTH(@From_Date) <= 12
	Begin
		Select @Month_Temp = MONTH (@From_Date)
		Select @Year_Temp = Year	(@From_Date)
		
		Select @From_Date_Temp = '01-Apr' + Cast(@Year_Temp As varchar(4))
		Select @To_Date_Temp = '31-Mar' + Cast(@Year_Temp + 1 As varchar(4))
	End
Else
	Begin
		Select @Month_Temp = MONTH (@To_Date)
		Select @Year_Temp = Year	(@To_Date)
		
		Select @From_Date_Temp = '01-Apr' + Cast(@Year_Temp -1 As varchar(4))
		Select @To_Date_Temp = '31-Mar' + Cast(@Year_Temp As varchar(4))
	End
	
 --------    
 DECLARE @TEMP_DATE AS DATETIME    
     
     
 SET @TEMP_DATE = @FROM_DATE    
     
 Declare @AC_1_1 numeric(10,2)    
 Declare @AC_1_2 numeric(10,2)    
 Declare @AC_2_3 numeric(10,2)    
 Declare @AC_10_1 numeric(10,2)    
 Declare @AC_21_1 numeric(10,2)    
 Declare @AC_22_3 numeric(10,4)    
 Declare @AC_22_4 numeric(10,4)    
 Declare @AC_10_1_Max_Limit numeric(10,2)     
 Declare @PF_Pension_Age numeric(5,1)    
     
 Declare @Pre_Month_Subscriber  numeric     
 Declare @Pre_Left_Subscriber numeric    
 Declare @Pre_Join_Subscriber numeric    
     
 Declare @Pre_month      numeric     
Declare @Pre_Year      numeric     
 Declare @Pre_Month_Pension_Subscriber Numeric    
 Declare @Pre_Month_EDLI_Subscriber  Numeric   
 Declare @Current_Month_Pension_Subscriber  numeric
 Declare @Left_Pension_Subscriber numeric
 Declare  @Curr_Month numeric
 declare  @Curr_Year as numeric   
     
 set @Pre_month = month(dateadd(m,-1,@From_Date) )    
 set @Pre_Year = Year(dateadd(m,-1,@From_Date) )    
 set @Curr_Month=month(dateadd(m,0,@From_Date) )   
 set @Curr_Year= Year(dateadd(m,0,@From_Date) )  
     
 Set @AC_1_1  = 0    
 Set @AC_1_2  = 0    
 Set @AC_2_3  = 0    
 Set @AC_10_1 = 0    
 Set @AC_21_1 = 0    
 Set @AC_22_3 = 0    
 Set @AC_22_4 = 0    
     
  select Top 1 @AC_1_1 = ACC_1_1 ,@AC_1_2 = ACC_1_2,@AC_2_3 =ACC_2_3,    
   @AC_10_1 = ACC_10_1,@AC_22_3 =ACC_22_3,@PF_Limit = PF_Limit,    
   @AC_21_1 =ACC_21_1 ,@PF_Pension_Age = isnull(PF_Pension_Age,0)    
  from T0040_General_setting gs WITH (NOLOCK) inner join     
  T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
  where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
  and For_Date in (select max(For_Date) from T0040_General_setting WITH (NOLOCK) where Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)    
       and For_Date <=@To_Date )    
    
      
  if @AC_21_1 =0  and @AC_10_1 > 0    
   Begin    
    set @AC_22_4 = @AC_22_3    
    set @AC_22_3= 0    
   end     
  
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
	   
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date_Temp1  = @From_Date     
		   set @To_Date_Temp1 = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date_Temp1  = @From_Date     
		   set @To_Date_Temp1 = @To_Date    
		end     
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date_Temp1 = @Sal_St_Date
		   Set @To_Date_Temp1 = @Sal_end_Date   
		End
       
  set @Pre_Month_Subscriber = 0    
      
  select @Pre_Month_Subscriber  = isnull(Total_subscriber,0) From T0220_PF_CHALLAN  WITH (NOLOCK)   
    where Cmp_id =@Cmp_ID and Month = Month(dateadd(m,-1,@FROM_DATE)) and Year = Year(dateadd(m,-1,@FROM_DATE))    
      and isnull(Branch_ID ,0) = isnull(@Branch_ID,isnull(Branch_ID ,0))   
    
      
  --select @Pre_Left_Subscriber = isnull(count(Emp_ID),0) from T0100_LEFT_EMP  Where Cmp_ID =@Cmp_ID and 
  --  lEFT_Date >=dateadd(m,-1,@from_Date) and LEFT_Date <=dateadd(m,-1,@To_Date)    
  --And Emp_ID not  in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD inner join T0050_AD_MASTER AM on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=@From_Date And MAD.For_Date <=@To_Date And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)
		--	And Emp_ID in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD inner join T0050_AD_MASTER AM on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=dateadd(m,-1,@From_Date) And MAD.For_Date <=dateadd(m,-1,@To_Date) And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)
			
  select @Pre_Left_Subscriber = isnull(count(Emp_ID),0) from T0100_LEFT_EMP WITH (NOLOCK) Where Cmp_ID =@Cmp_ID     
		and lEFT_Date >=@from_Date and lEFT_Date <=@To_Date
		And Emp_ID in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=@From_Date_Temp1 And MAD.For_Date <=@To_Date_Temp1 And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)    
  	
      
  select @Pre_Join_Subscriber = isnull(count(Emp_ID),0) from T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID =@Cmp_ID     
		and Date_of_Join >=@from_Date and Date_of_Join <=@To_Date
		And Emp_ID in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=@From_Date_Temp1 And MAD.For_Date <=@To_Date_Temp1 And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)    
   
   
  select @Pre_Month_Pension_Subscriber = Total_Family_Pension_Subscriber  from T0220_PF_CHALLAN WITH (NOLOCK)    
		where Cmp_ID = @Cmp_ID and month = @Pre_month and year = @Pre_Year    
    
	select @Pre_Month_EDLI_Subscriber = Total_EDLI_Subscriber  from T0220_PF_CHALLAN WITH (NOLOCK)    
		where Cmp_ID = @Cmp_ID and month = @Pre_month and year = @Pre_Year    
  
     
  DECLARE @EMP_SALARY TABLE    
   (    
    Cmp_ID			  numeric,    
    EMP_ID			  NUMERIC,    
    MONTH		      NUMERIC,    
    YEAR			  NUMERIC,    
    SALARY_AMOUNT     NUMERIC,    
    OTHER_PF_SALARY   NUMERIC,    
    MONTH_ST_DATE     DATETIME,    
    MONTH_END_DATE    DATETIME,    
    PF_PER            NUMERIC(18,2),    
    PF_AMOUNT         NUMERIC,    
    PF_SALARY_AMOUNT  NUMERIC,    
    PF_LIMIT          numeric,    
    PF_367			  NUMERIC,    
    PF_833			  NUMERIC,    
    PF_DIFF_6500	  NUMERIC,    
    VPF				  NUMERIC,  
    EMP_AGE			  NUMERIC(5,1),
    Sal_Cal_Day		  Numeric, 
	Absent_days		  NUMERIC,
	Is_Sett           TinyINt Default 0,    
	Sal_Effec_Date    DateTime Default GetDate(), 
	EDLI_Wages		  Numeric,
	Nationality		  Varchar(100)     
    )    
    
    -- (m_ad_Calculated_Amount + Arear_Basic) added by mitesh on 08/02/2012
       
      INSERT INTO @EMP_SALARY    
      SELECT  sg.Cmp_ID ,SG.EMP_ID,MONTH(SG.Month_End_date),YEAR(SG.Month_End_date),SG.Salary_Amount     
    -- ,0 ,sg.Month_st_Date,SG.Month_End_date    
		,0 ,@From_Date,@To_Date
     ,MAD.PF_PER,MAD.PF_AMOUNT  , (m_ad_Calculated_Amount + Arear_Basic) as m_ad_Calculated_Amount ,@PF_Limit,0,0,0,VPF,dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')    
     ,SG.Sal_Cal_Days,0,0,NULL,0,e.Nationality
    FROM    T0200_MONTHLY_SALARY  SG WITH (NOLOCK) INNER JOIN     
    ( select Emp_ID , m_ad_Percentage as PF_PER , (isnull(m_ad_Amount,0) + isnull(M_AREAR_AMOUNT,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from     
     T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID    
     and ad_not_effect_salary <> 1
     and AD.CMP_ID = @CMP_ID and isnull(Sal_Type,0)=0) MAD on SG.Emp_ID = MAD.Emp_ID     
     AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN    
     T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join    
    @EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID        
        
   left outer join      
     (Select 	Emp_ID , (M_AD_Amount + isnull(M_AREAR_AMOUNT,0)) as VPF,SAL_tRAN_ID  from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM  WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND  CMD.SAL_TRAN_ID = SG.SAL_tRAN_ID  
  WHERE   e.CMP_ID = @CMP_ID     
     and SG.Month_St_Date >=@From_Date_Temp1  and SG.Month_End_Date <= @To_Date_Temp1 --changes by Falak on 04-jan-2011 bcoz the condition wrong   
   
  -----By Hasmukh 11-02-2012 For Settlement Pf Effect In main challan----Start
		If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)
			Begin 
				INSERT INTO @EMP_SALARY
				SELECT  sg.Cmp_ID,SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date
					 ,MAD.PF_PER,MAD.PF_AMOUNT,m_ad_Calculated_Amount ,@PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,S_MONTH_ST_DATE,'N','N'),
					 SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,Nationality 
					FROM t0201_monthly_salary_sett  SG WITH (NOLOCK) INNER JOIN 
					( select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
						and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
					@EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID	
					left outer join
					(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as VPF,SAL_tRAN_ID  from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type=1
						and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID
			WHERE   e.CMP_ID = @CMP_ID 
						And S_Eff_Date Between @From_Date And @To_Date
 					--and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date 
				Update @EMP_SALARY Set 
				Salary_Amount= ES.Salary_Amount+Qry.Salary_Amount,
				PF_Amount=ES.PF_Amount+Qry.PF_Amount,
				PF_Salary_Amount=ES.PF_Salary_Amount+Qry.PF_Salary_Amount From 
				@EMP_SALARY As ES INNER JOIN
				(Select SUM(Salary_Amount) As Salary_Amount,SUM(PF_Amount) As PF_Amount,SUM(PF_Salary_Amount) As PF_Salary_Amount,Emp_Id,Sal_Effec_Date From @EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)

				Delete From @EMP_SALARY where Is_Sett=1
		End		
--------------------------------------------------End----------------------------------------------  
    
  set @AC_10_1_Max_Limit = round(@PF_Limit*@AC_10_1/100,0)    
      
     
  update @EMP_SALARY    
  set   PF_833 = round(PF_SALARY_AMOUNT * @AC_10_1/100,0)    
    ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * @AC_10_1/100,0)     
  where PF_SALARY_AMOUNT <= PF_Limit    
    
    
  update @EMP_SALARY    
  set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit    
   ,PF_833 = @AC_10_1_Max_Limit    
   ,PF_367 = PF_Amount - @AC_10_1_Max_Limit    
  where PF_SALARY_AMOUNT > PF_Limit    
     
  update @EMP_SALARY    
  set PF_833 = 0    
   ,PF_367 = PF_Amount     
  where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age>0    
      
     
          Update @EMP_SALARY 
     set PF_Amount = PF_Amount + isnull(VPF  ,0)
     
     
--------------------------------------------- PF CHALLAN CALCULATION    
 declare @EMP_SALARY_Challan table    
  (    
       
   Cmp_ID     numeric,    
   Total_Subscriber   numeric ,    
   Total_Wages_Due    numeric(18,2),    
   Total_PF_Diff_Limit   numeric(18,2),    
   AC1_1      numeric(18,2),    
   AC1_2      numeric(18,2),    
   AC2_3      numeric(18,2),    
   AC10_1      numeric(18,2),    
   AC21_1      numeric(18,2),    
   AC22_3      numeric(18,2),
   AC22_4      numeric(18,2),    
   For_Date     datetime,    
   PF_Limit     numeric,    
   Total_Family_Pension_Subscriber  numeric(18, 0),    
   Total_Family_Pension_Wages_Amount numeric(18, 0),    
   Total_EDLI_Subscriber    numeric(18, 0),    
   Total_EDLI_Wages_Amount    numeric(18, 0)  ,
   Current_Month_Pension_Subscriber   numeric(18, 0)  ,
   Left_Month_EDLI_Subscriber numeric(18, 0)  
  )    
    
  declare @Total_Wages_Due as numeric(18,2)    
  declare @Total_Subscriber as numeric    
  Declare @Total_PF_Diff_Limit as numeric    
  Declare @dblAC1_1 as numeric(22,2)    
  Declare @dblAC1_2 as numeric(22,2)    
  Declare @dblAC2_3 as numeric(22,2)    
  Declare @dblAC10_1 as numeric(22,2)    
  Declare @dblAC21_1 as numeric(22,2)    
  Declare @dblAC22_3 as numeric(22,2)
  Declare @dblAC22_4 numeric --Added By Falak 0n 15-MAR-2011    
  Declare @dbl833 as numeric (22,2)    
  Declare @dbl367 as numeric (22,2)    
  declare @Total_PF_Amount as numeric     
  DEclare @MONTH numeric      
  Declare @Year numeric     
  Declare @Total_Family_Pension_Subscriber  numeric(18, 0)    
  Declare @Total_Family_Pension_Wages_Amount  numeric(18, 0)    
  Declare @Total_EDLI_Subscriber     numeric(18, 0)    
  Declare @Total_EDLI_Wages_Amount    numeric(18, 0)        
      
      
 SET @TEMP_DATE = @FROM_DATE    
 WHILE @TEMP_DATE <=@TO_DATE    
  BEGIN    
    set @Total_Subscriber = 0    
    set @Total_Wages_Due = 0     
    set @Total_PF_Diff_Limit = 0    
    set @Total_PF_Amount = 0    
    
    set @dblAC1_1  = 0    
    set @dblAC1_2  = 0    
    set @dblAC2_3  = 0    
    set @dblAC10_1 = 0    
    set @dblAC21_1 = 0    
    set @dblAC22_3 = 0
    set @dblAC22_4 =0     
    set @dbl833 = 0    
    set @dbl367 = 0    
    SET @MONTH = MONTH(@TEMP_DATE)    
    SET @YEAR = YEAR(@TEMP_DATE)     
    set @Total_Family_Pension_Subscriber  = 0    
    set @Total_Family_Pension_Wages_Amount  = 0    
    set @Total_EDLI_Subscriber     = 0    
    set @Total_EDLI_Wages_Amount    = 0        
        
      
    
    select @Total_Subscriber =  count(*), @Total_Wages_Due = isnull(sum(PF_Salary_Amount  ),0)      
     ,@Total_PF_Amount = isnull(sum(PF_Amount),0)      
    from @EMP_SALARY    
    where Cmp_ID = @Cmp_ID and  [month] = @month and [year] = @year      
    
    
     
    select  @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500),0)     
    from @EMP_SALARY    
    where Cmp_ID = @Cmp_ID and  [month] = @month and [year] = @year and PF_Amount > 0    
        
    select  @dbl833 = round(sum(PF_833),0)     
    from @EMP_SALARY    
    where Cmp_ID = @Cmp_ID and  [month] = @month and [year] = @year and PF_Amount > 0    
        
    select  @dbl367 = round(sum(PF_367),0 )     
    from @EMP_SALARY    
    where Cmp_ID = @Cmp_ID and  [month] = @month and [year] = @year and PF_Amount > 0    

    
     SELECT @Current_Month_Pension_Subscriber = count(ES.emp_ID) from @EMP_SALARY ES Inner join
     T0080_emp_Master E WITH (NOLOCK) on ES.Emp_ID =E.Emp_ID 
    Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  and Month(Date_OF_Join)=@Curr_Month
    and Year(Date_OF_Join) =@Curr_year
   

  --  select  @Left_Pension_Subscriber = isnull(count(E.Emp_ID),0) from T0100_LEFT_EMP  E inner join T0080_emp_master EM on E.Emp_ID =EM.Emp_ID
  --   Where E.Cmp_ID =@Cmp_ID  and isnull(dbo.F_GET_AGE(isnull(Date_of_Birth,''),@From_Date,'N','N'),0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0 
  --And E.Emp_ID not  in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD inner join T0050_AD_MASTER AM on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=@From_Date And MAD.For_Date <=@To_Date And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)
		--	And E.Emp_ID in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD inner join T0050_AD_MASTER AM on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=dateadd(m,-1,@From_Date) And MAD.For_Date <=dateadd(m,-1,@To_Date) And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)	
		--	and lEFT_Date >=dateadd(m,-1,@from_Date) and LEFT_Date <=dateadd(m,-1,@To_Date)
	
	select  @Left_Pension_Subscriber = isnull(count(E.Emp_ID),0) from T0100_LEFT_EMP  E WITH (NOLOCK) inner join T0080_emp_master EM WITH (NOLOCK) on E.Emp_ID =EM.Emp_ID
     Where E.Cmp_ID =@Cmp_ID  and isnull(dbo.F_GET_AGE(isnull(Date_of_Birth,''),@From_Date,'N','N'),0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0
     and lEFT_Date >=@from_Date and lEFT_Date <=@To_Date 
		And E.Emp_ID in (select MAD.Emp_ID from T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID=AM.AD_ID where MAD.For_Date >=@From_Date_Temp1 And MAD.For_Date <=@To_Date_Temp1 And MAD.Cmp_ID=@Cmp_ID And AM.AD_DEF_ID=2)    
   
   
    set @Total_EDLI_Subscriber = @Total_Subscriber     
    set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit

	  update @EMP_SALARY    
	  set   PF_833 = round(PF_SALARY_AMOUNT * @AC_10_1/100,0)    
		,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * @AC_10_1/100,0)     
	  	 ,PF_DIFF_6500 = 0, PF_LIMIT = 0
	where  Nationality not like 'India%' and Nationality <> ''
           
    --Added by Falak on 15-MAR-2011
    SELECT @Total_Family_Pension_Wages_Amount = (sum(PF_SALARY_AMOUNT)-sum(PF_Diff_6500)) from @EMP_SALARY    
    Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  
   
    set @dbl833 = isnull(@dbl833,0)     
    set @Total_Wages_Due = @Total_Wages_Due     
    set @Total_PF_Amount = @Total_PF_Amount   
         
    set @dblAC1_1 = @dbl367    
    set @dblAC10_1 = @dbl833    
    set @dblAC1_2 = @Total_PF_Amount    
    
        
    set @dblAC2_3  =  round(@Total_Wages_Due * @AC_2_3/100,0)
   
    
    set @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1/100 ,0)    
    --Commented by Falak on 15-MAR-2011
    /*
    if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
     set @dblAC22_3 =  Round((@AC_22_3 *  @Total_EDLI_Wages_Amount )/100,0)    
    else    
     set @dblAC22_3 = 2    
    */
    --added by Falak on 15-MAR-2011 
    if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
		begin
			set @dblAC22_3 =  Round((@AC_22_3 *  @Total_EDLI_Wages_Amount )/100,0)    
		end
    else
		begin
			IF  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 0    
				set @dblAC22_3 = 2    
		end
	
    if  ( @AC_22_4 *  @Total_EDLI_Wages_Amount )/100 > 2    
		begin
			set @dblAC22_4 =  Round((@AC_22_4 *  @Total_EDLI_Wages_Amount )/100,0) 
		end
	else 
		begin
			IF  ( @AC_22_4 *  @Total_EDLI_Wages_Amount )/100 > 0  
				set @dblAC22_4 = 2   
		end    
    
         
     if @Total_Subscriber > 0     
    begin    
      insert into @EMP_SALARY_Challan ( Cmp_ID , Total_Subscriber , Total_Wages_Due ,Total_PF_Diff_Limit,    
            AC1_1 , AC1_2, AC2_3 , AC10_1 , AC21_1 ,AC22_3,AC22_4,For_Date,PF_Limit,    
            Total_Family_Pension_Subscriber,Total_Family_Pension_Wages_Amount,Total_EDLI_Subscriber,Total_EDLI_Wages_Amount)    
      values ( @Cmp_ID , @Total_Subscriber , @Total_Wages_Due ,@Total_PF_Diff_Limit ,    
            @dblAC1_1 , @dblAC1_2, @dblAC2_3 , @dblAC10_1 , @dblAC21_1 ,@dblAC22_3,@dblAC22_4,@Temp_DAte ,@PF_Limit,    
            @Total_Family_Pension_Subscriber,@Total_Family_Pension_Wages_Amount,@Total_EDLI_Subscriber,@Total_EDLI_Wages_Amount)    
    end                 
    
    SET @TEMP_DATE = DATEADD(M,1,@TEMP_DATE)    
  END    
 select esc.* ,PF_No, Cmp_Name,Cmp_Address     
     ,@From_Date P_From_Date ,@To_Date P_To_Date,@Pre_Month_Subscriber  as Pre_Month_Subscriber    
     ,@Pre_Left_Subscriber as Pre_Left_Subscriber ,@Pre_Join_Subscriber as Pre_Join_Subscriber     
     ,@Pre_Month_Pension_Subscriber as Pre_Month_Pension_Subscriber    
     ,@Pre_Month_EDLI_Subscriber as Pre_Month_EDLI_Subscriber  
     ,@Current_Month_Pension_Subscriber   as Current_Month_Pension_Subscriber
     ,@Left_Pension_Subscriber   as Current_Month_EDLI_Subscriber
     ,@From_Date_Temp as Currncy_From_date
     ,@To_Date_Temp as Currncy_To_date
 From @EMP_SALARY_Challan esc inner join T0010_Company_Master cm WITH (NOLOCK) on esc.Cmp_ID= cm.cmp_ID   
 
        
RETURN     
    
    


