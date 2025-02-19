

-- Created by rohit for Pf trust Report on 02022016
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_6A_PF_CHALLAN_GET_PF_Trust]    
    
 @Cmp_ID  numeric    
,@From_Date  datetime    
,@To_Date  datetime    
,@Branch_ID  VARCHAR(MAX)=''
,@Cat_ID  varchar(max)=''   
,@Grd_ID  varchar(max)=''   
,@Type_ID  varchar(max)=''    
,@Dept_ID  varchar(max)=''    
,@Desig_ID  varchar(max)='' 
,@Emp_ID  numeric    
,@constraint  varchar(max)    
,@Segment_Id  varchar(max)=''
,@Vertical_Id varchar(max)=''
,@SubVertical_Id varchar(max)=''
,@SubBranch_Id varchar(max)=''
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
     
declare @PF_LIMIT as numeric    
 Declare @PF_DEF_ID  numeric     
 set @PF_DEF_ID =2    
      
 set @PF_LIMIT = 15000     
     
 IF @Branch_ID = '' or @Branch_ID='0'       
  set @Branch_ID = null    
      
 IF @Cat_ID = '0' or @Cat_ID=''       
  set @Cat_ID = null    
    
 IF @Grd_ID = '0' or @Grd_ID=''       
  set @Grd_ID = null    
    
 IF @Type_ID = '0' or @Type_ID=''      
  set @Type_ID = null    
    
 IF @Dept_ID = '0' or @Dept_ID=''      
  set @Dept_ID = null    
    
 IF @Desig_ID = '0' or @Desig_ID=''      
  set @Desig_ID = null    
    
 IF @Emp_ID = 0      
  set @Emp_ID = null    

 If @Segment_Id = '0' or @Segment_Id=''		
	set @Segment_Id = null
 If @Vertical_Id = '0' or @Vertical_Id=''		 
	set @Vertical_Id = null
 If @SubVertical_Id = '0' or @SubVertical_Id='' 	 
	set @SubVertical_Id = null	
 If @SubBranch_Id = '0' or @SubBranch_Id=''	
	set @SubBranch_Id = null	
	    
 
 CREATE TABLE #Emp_Cons
 (
	Emp_ID	numeric,
	Branch_ID numeric,  
    Increment_ID numeric
 )  
     
 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    	

-- Added by rohit for PF trust employee filter
		delete from #EMP_CONS where Emp_ID in(select Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where isnull(is_PF_Trust ,0) = 0)
	--ended by rohit for pf trust filter

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
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID --and Branch_ID = @Branch_ID    
			  and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date --and Branch_ID = @Branch_ID 
								and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
								and Cmp_ID = @Cmp_ID)    
		End    
       
 if isnull(@Sal_St_Date,'') = ''    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if day(@Sal_St_Date) =1 
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	begin    
	   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   set @From_Date = @Sal_St_Date
	   Set @To_Date = @Sal_end_Date   
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
     
 Set @AC_1_1  = 0    
 Set @AC_1_2  = 0    
 Set @AC_2_3  = 0    
 Set @AC_10_1 = 0    
 Set @AC_21_1 = 0    
 Set @AC_22_3 = 0    
 Set @AC_22_4 = 0    
     
  select Top 1 @AC_1_1 = ACC_1_1 ,@AC_1_2 = ACC_1_2,@AC_2_3 =ACC_2_3,    
   @AC_10_1 = ACC_10_1,@AC_22_3 =ACC_22_3,@PF_Limit = ACC_10_1_Max_Limit,    
   @AC_21_1 =ACC_21_1 ,@PF_Pension_Age = isnull(PF_Pension_Age,0)    
  from T0040_General_setting gs WITH (NOLOCK) inner join     
  T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     
  where gs.Cmp_Id=@cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
  and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
  and For_Date in (select max(For_Date) from T0040_General_setting  g WITH (NOLOCK) inner join     
     T0050_General_Detail d WITH (NOLOCK) on g.gen_Id =d.gen_ID       
  where g.Cmp_Id=@cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
		and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
		and For_Date <=@To_Date )    
    
     
             
  if @AC_21_1 =0  and @AC_10_1 > 0    
   Begin    
    set @AC_22_4 = @AC_22_3    
    set @AC_22_3= 0    
   end     
     
  DECLARE @EMP_SALARY TABLE    
   (    
    Cmp_ID			  NUMERIC,    
    EMP_ID			  NUMERIC,    
    MONTH			  NUMERIC,    
    YEAR			  NUMERIC,    
    SALARY_AMOUNT     NUMERIC,    
    OTHER_PF_SALARY   NUMERIC,    
    MONTH_ST_DATE     DATETIME,    
    MONTH_END_DATE    DATETIME,    
    PF_PER			  NUMERIC(18,2),    
    PF_AMOUNT		  NUMERIC,    
    PF_SALARY_AMOUNT  NUMERIC,    
    PF_LIMIT		  NUMERIC,    
    PF_367			  NUMERIC,    
    PF_833			  NUMERIC,    
    PF_DIFF_6500	  NUMERIC, 
    VPF				  NUMERIC,   
    EMP_AGE			  NUMERIC(5,1),
    Sal_Cal_Day		  Numeric(18,2), 
	Absent_days		  NUMERIC(18,2),
	Is_Sett           TinyINt Default 0,    
	Sal_Effec_Date    DateTime Default GetDate(), 
	EDLI_Wages		  Numeric,
	Arear_Day		  Numeric(18,2),
	Nationality		  Varchar(100),
	cmp_full_pf		  Tinyint	
    )    
       -- (m_ad_Calculated_Amount + Arear_Basic) added by mitesh on 08/02/2012
     
       
      INSERT INTO @EMP_SALARY    
      SELECT  sg.Cmp_ID ,SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount     
     ,0 ,sg.Month_st_Date,SG.Month_End_date    
     ,MAD.PF_PER,MAD.PF_AMOUNT, (m_ad_Calculated_Amount + ISNULL(arear_basic,0) + ISNULL(Basic_Salary_Arear_cutoff,0) + isnull(CMD_new.Other_PF_Calculate,0)) as m_ad_Calculated_Amount  ,@PF_Limit,0,0,0,isnull(VPF,0),dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')    
     ,SG.Sal_Cal_Days,0,0,NULL,0,Isnull(sg.Arear_Day,0),e.Nationality
	 ,isnull(emp_auto_vpf,0) --added by hasmukh on 06 08 2013 for company full pf
    FROM    T0200_MONTHLY_SALARY  SG WITH (NOLOCK) INNER JOIN     
    (select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from     
     T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID    
     and ad_not_effect_salary <> 1
     and AD.CMP_ID = @CMP_ID and isnull(Sal_Type,0)=0) MAD on SG.Emp_ID = MAD.Emp_ID    
     AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN    
     T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
	 t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join    
    #EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID        
      left outer join      
     (Select 	Emp_ID , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<> 1
					and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND  CMD.SAL_TRAN_ID = SG.SAL_tRAN_ID  
	 left outer join  -- Added by rohit on 05102015
				(Select Emp_ID,sum((isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0))) as Other_PF_Calculate ,SAL_tRAN_ID 
				from	T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID 
				where	EXISTS(SELECT	1 
									FROM	dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)
											inner join T0050_AD_MASTER AM1 WITH (NOLOCK) on EAM.Effect_AD_ID = AM1.AD_ID and EAM.CMP_ID = AM1.CMP_ID
									WHERE	AM1.AD_DEF_ID  = @PF_DEF_ID AND Am1.Cmp_ID  = @Cmp_ID AND EAM.AD_ID=AD.AD_ID
								) And ad_not_effect_salary <> 1 and sal_type<>1 and AD.CMP_ID = @CMP_ID group by emp_id,SAL_tRAN_ID
				) CMD_new on SG.Emp_ID= CMD_new.Emp_ID AND SG.SAL_tRAN_ID = CMD_new.SAL_TRAN_ID					 				
  WHERE   e.CMP_ID = @CMP_ID     
     and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date --changes by Falak on 04-jan-2011 bcoz the condition wrong 
  
  
  -----By Hasmukh 11-02-2012 For Settlement Pf Effect In main challan----Start
If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)
	Begin 
				INSERT INTO @EMP_SALARY
				SELECT  sg.Cmp_ID,SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date
					 ,MAD.PF_PER,MAD.PF_AMOUNT,m_ad_Calculated_Amount ,@PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,S_MONTH_ST_DATE,'N','N'),
					 SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,e.Nationality
					 ,isnull(emp_auto_vpf,0) --added by hasmukh on 06 08 2013 for company full pf 
					FROM t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
					( select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
						and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
						t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join
					#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID	
					left outer join
					(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type=1
						and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID
			WHERE   e.CMP_ID = @CMP_ID 
						And S_Eff_Date Between @From_Date And @To_Date
 					--and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date 
				Update @EMP_SALARY Set 
				Salary_Amount= ES.Salary_Amount+Qry.Salary_Amount,
				PF_Amount=ES.PF_Amount+Qry.PF_Amount,
				PF_Salary_Amount=ES.PF_Salary_Amount+Qry.PF_Salary_Amount,
				VPF = es.VPF + Qry.VPF From 
				@EMP_SALARY As ES INNER JOIN
				(Select SUM(Salary_Amount) As Salary_Amount,SUM(PF_Amount) As PF_Amount,SUM(PF_Salary_Amount) As PF_Salary_Amount,SUM(VPF) as VPF,Emp_Id,Sal_Effec_Date From @EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)

				Delete From @EMP_SALARY where Is_Sett=1
	End		
--------------------------------------------------End----------------------------------------------
     
   
  Set @AC_10_1_Max_Limit = round(@PF_Limit*@AC_10_1/100,0)    
          
          
  Update @EMP_SALARY    
  set   PF_833 = round(PF_SALARY_AMOUNT * @AC_10_1/100,0)    
    ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * @AC_10_1/100,0)     
  where PF_SALARY_AMOUNT <= PF_Limit and PF_Amount > 0   
    
    
  update @EMP_SALARY    
  set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit    
   ,PF_833 = @AC_10_1_Max_Limit    
   ,PF_367 = PF_Amount - @AC_10_1_Max_Limit    
  where PF_SALARY_AMOUNT > PF_Limit and PF_Amount > 0   
     
     
     
  update @EMP_SALARY    
  set PF_833 = 0    
   ,PF_367 = PF_Amount     
  where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0
  
  Update @EMP_SALARY 
		set EDLI_Wages = PF_SALARY_AMOUNT
  where PF_AMOUNT > 0
	
 Update @EMP_SALARY 
	set EDLI_Wages = @PF_Limit-- 6500
 where PF_SALARY_AMOUNT > @PF_Limit--6500 
		and PF_AMOUNT > 0
  
     Update @EMP_SALARY 
     set PF_Amount = PF_Amount + isnull(VPF  ,0)

-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013
	
	Declare @PF_541 As Numeric(18,2)
	Declare @PF_NOT_FUll_AMT As Numeric(18,2)
	Set @PF_541 = 0
	SET @PF_NOT_FUll_AMT = 0
	
	Set @PF_541 = round(@PF_Limit * 0.0833,0)
	SET @PF_NOT_FUll_AMT = round(@PF_Limit * 12/100,0)
	
	--Update @EMP_SALARY			-----Comment By Ankit 10082015
	--set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
	--	,PF_833 = @PF_541--541
	--	,PF_367 = round(PF_Limit * 12/100,0) - @PF_541--541
	--where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0

	Update @EMP_SALARY		--PF 8.33 and 3.67 Calculate On actual PF Amount deduct ----Condition Add By Ankit After discuss with Hardikbhai 10082015
	set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
		,PF_833 = PF_Amount - round((PF_SALARY_AMOUNT * 3.67)/100 ,0) 
		,PF_367 = round((PF_SALARY_AMOUNT * 3.67)/100 ,0) 
	where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0	
	
	Update @EMP_SALARY    
	set PF_833 = 0    
		,PF_367 = PF_AMOUNT --@PF_NOT_FUll_AMT--780		---Set Actual PF Amount (Employee arear case)--Ankit 10082015
		,PF_LIMIT =0   
	where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0 and PF_Amount > @PF_NOT_FUll_AMT and cmp_full_pf = 0 
-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013

  --Added by Hardik for Foreign Employee who pay full PF on 17/05/2012
  Update @EMP_SALARY    
  set   PF_833 = round(PF_SALARY_AMOUNT * @AC_10_1/100,0)    
    ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * @AC_10_1/100,0)
    ,PF_DIFF_6500=0, PF_LIMIT = 0
  where  Nationality not like 'India%' and Nationality <> ''
   
   
--------------------------------------------- PF CHALLAN CALCULATION    

--------------------------------Added by rohit for Pf Trust on 28012016---------------------------------
   
  Update @EMP_SALARY    
  set   PF_833 = case when E.is_PF_Trust=1 then 0 else PF_833 end
  from @EMP_SALARY  ES inner join t0080_emp_master E on
  Es.EMP_ID=E.Emp_ID
   
  
   
   --------------------------------Ended by rohit for Pf Trust on 28012016---------------------------------
   


 declare @EMP_SALARY_Challan table    
  (    
       
   Cmp_ID     numeric,    
   Total_Subscriber   numeric ,    
   Total_Wages_Due    numeric(18,2),    
   Total_PF_Diff_Limit   numeric(18,2),    
   AC1_1      numeric(18,2) default 0,    
   AC1_2      numeric(18,2) default 0,    
   AC2_3      numeric(18,2) default 0,    
   AC10_1      numeric(18,2) default 0,    
   AC21_1      numeric(18,2) default 0,    
   AC22_3      numeric(18,2) default 0,    
   AC22_4      numeric(18,2) default 0,    
   For_Date     datetime,
   Payment_Date datetime,    
   PF_Limit     numeric,    
   Total_Family_Pension_Subscriber  numeric(18, 0),    
   Total_Family_Pension_Wages_Amount numeric(18, 0),    
   Total_EDLI_Subscriber    numeric(18, 0),    
   Total_EDLI_Wages_Amount    numeric(18, 0)  ,
   VPF  numeric(18,0)  
      
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
  Declare @dblAC22_4 numeric     
  Declare @dbl833 as numeric (22,2)    
  Declare @dbl367 as numeric (22,2)    
  declare @Total_PF_Amount as numeric     
  DEclare @MONTH numeric      
  Declare @Year numeric     
  Declare @Total_Family_Pension_Subscriber  numeric(18, 0)    
  Declare @Total_Family_Pension_Wages_Amount  numeric(18, 0)    
  Declare @Total_EDLI_Subscriber     numeric(18, 0)    
  Declare @Total_EDLI_Wages_Amount    numeric(18, 0)  
  Declare @VPF as numeric(18,0)    
  
  
      
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
    set @dbl833 = 0    
    set @dbl367 = 0    
    set @dblAC22_4 =0    
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
    
    Select @VPF =VPf from @EMP_SALARY  where Cmp_ID = @Cmp_ID and  [month] = @month and [year] = @year and PF_Amount > 0    
        
    SELECT @Total_Family_Pension_Subscriber = count(emp_ID ) from @EMP_SALARY    
    Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0    
       
       
    
    SELECT @Total_Family_Pension_Wages_Amount = (sum(PF_SALARY_AMOUNT)-sum(PF_Diff_6500)) from @EMP_SALARY    
    Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0    
    
    
    
    set @Total_EDLI_Subscriber = @Total_Subscriber     
    set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit    
    set @dbl833 = isnull(@dbl833,0)     
    set @Total_Wages_Due = @Total_Wages_Due     
    set @Total_PF_Amount = @Total_PF_Amount     
    set @dblAC1_1 = @dbl367 
    set @dblAC10_1 = @dbl833    
    set @dblAC1_2 = @Total_PF_Amount    
    set @dblAC2_3  = round( @Total_Wages_Due * @AC_2_3/100,0 )    
    set @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1/100 ,0)    
	 --select @AC_22_3
	 --if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
     --set @dblAC22_3 =  Round((@AC_22_3 *  @Total_EDLI_Wages_Amount )/100,0)    
     --else    
     --set @dblAC22_3 = 2    
	 --set @dblAC22_4 =  Round((@AC_22_4 *  @Total_EDLI_Wages_Amount )/100,0)    

	--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 5 to 500
	If @dblAC2_3 < 500
		Set @dblAC2_3 = 500
	
    
    --Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 2 to 200
    --if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2     
    if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 200     
		begin
			set @dblAC22_3 =  Round((@AC_22_3 *  @Total_EDLI_Wages_Amount )/100,0)    
		end
    else
		begin
			IF  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 0    
				set @dblAC22_3 = 200    
		end
	
    if  ( @AC_22_4 *  @Total_EDLI_Wages_Amount )/100 > 200    
		begin
			set @dblAC22_4 =  Round((@AC_22_4 *  @Total_EDLI_Wages_Amount )/100,0) 
		end
	else 
		begin
			IF  Round((@AC_22_4 *  @Total_EDLI_Wages_Amount )/100,0) > 0  
				set @dblAC22_4 = 200   
		end
    
       DEclare @Payment_Date Datetime 
      --Added By Falak on 19-MAY-2011
      
      select @Payment_Date = Payment_Date  from T0220_PF_CHALLAN WITH (NOLOCK) where [Month] = Month(@TEMP_DATE) and [YEAR] = YEAR(@Temp_Date)
        
     if @Total_Subscriber > 0     
    begin    
      insert into @EMP_SALARY_Challan ( Cmp_ID , Total_Subscriber , Total_Wages_Due ,Total_PF_Diff_Limit ,    
            AC1_1 , AC1_2, AC2_3 , AC10_1 , AC21_1 ,AC22_3 ,For_Date,Payment_Date,PF_Limit,AC22_4,    
            Total_Family_Pension_Subscriber,Total_Family_Pension_Wages_Amount,Total_EDLI_Subscriber,Total_EDLI_Wages_Amount,VPF)    
      values ( @Cmp_ID , @Total_Subscriber , @Total_Wages_Due ,@Total_PF_Diff_Limit ,    
             isnull(@dblAC1_1,0) , @dblAC1_2, @dblAC2_3 , @dblAC10_1 , @dblAC21_1 ,@dblAC22_3,@Temp_DAte,@Payment_Date ,@PF_Limit,@dblAC22_4,    
            @Total_Family_Pension_Subscriber,@Total_Family_Pension_Wages_Amount,@Total_EDLI_Subscriber,@Total_EDLI_Wages_Amount,@VPF)    
    end                 
    
    SET @TEMP_DATE = DATEADD(M,1,@TEMP_DATE)    
  END    
     
     
   
 select * from @EMP_SALARY_Challan ES inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ES.Cmp_ID=CM.Cmp_Id 
     
     
      
RETURN     
    

