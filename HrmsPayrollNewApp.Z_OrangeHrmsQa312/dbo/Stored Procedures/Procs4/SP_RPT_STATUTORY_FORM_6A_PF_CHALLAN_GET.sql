
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_6A_PF_CHALLAN_GET]    
    
 @Cmp_ID  numeric    
,@From_Date  datetime    
,@To_Date  datetime    
--,@Branch_ID  numeric
,@Branch_ID  VARCHAR(MAX)=''	--Ankit 22082015
--,@Cat_ID  numeric     
--,@Grd_ID  numeric    
--,@Type_ID  numeric    
--,@Dept_ID  numeric    
--,@Desig_ID  numeric  
,@Cat_ID  varchar(max)=''    --Added By Jaina 5-11-2015 Start   
,@Grd_ID  varchar(max)=''   
,@Type_ID  varchar(max)=''    
,@Dept_ID  varchar(max)=''    
,@Desig_ID  varchar(max)=''  --Added By Jaina 5-11-2015 End    
,@Emp_ID  numeric    
,@constraint  varchar(max)    
,@Segment_Id  varchar(max)=''  --Added By Jaina 5-11-2015 Start
,@Vertical_Id varchar(max)=''
,@SubVertical_Id varchar(max)=''
,@SubBranch_Id varchar(max)=''  --Added By Jaina 5-11-2015 End   
,@Format  tinyint = 5 --Added By Mukti(15022017)  
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 --Added By Mukti(start)17022017
 if @Format=7 --For Type Regular Salary Challan Details
	set @Format=9
 else if @Format=8--For Type Arrear Salary Challan Details
	set @Format=10
 ELSE if @Format in (0 , 4 , 5,11)	--Solved By Ramiz on 08/01/2019 as per discussion with Nimesh Bhai  ---Add 11 Fromat for New Consolidate Report
   set  @Format=5 --For Type Consolidated Salary Challan Details
 --Added By Mukti(end)17022017
 
	EXEC [dbo].[SP_RPT_STATUTORY_FORM_3A_GET_EXPORT_TEXT] @Cmp_ID=@Cmp_Id,@From_Date =@From_Date,@To_Date = @To_Date, @Branch_ID = @Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID= @Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Segment_Id=@Segment_Id,@Vertical_Id=@Vertical_Id,@SubVertical_Id=@SubVertical_Id,@SubBranch_Id=@SubBranch_Id,@Format=@Format

	/*
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

 If @Segment_Id = '0' or @Segment_Id=''		--Added By Jaina 5-11-2015 Start 
	set @Segment_Id = null
 If @Vertical_Id = '0' or @Vertical_Id=''		 
	set @Vertical_Id = null
 If @SubVertical_Id = '0' or @SubVertical_Id='' 	 
	set @SubVertical_Id = null	
 If @SubBranch_Id = '0' or @SubBranch_Id=''	--Added By Jaina 5-11-2015 End 
	set @SubBranch_Id = null	
	    
 
 CREATE TABLE #Emp_Cons
 (
	Emp_ID	numeric,
	Branch_ID numeric,  --Added By Jaina 5-11-2015
    Increment_ID numeric --Added By Jaina 5-11-2015   
 )  
     
 --Added By Jaina 5-11-2015
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    	

 --Comment By Jaina 5-11-2015	
 --if @Constraint <> ''    
 -- begin    
 --  Insert Into @Emp_Cons    
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')     
 -- end    
 --else    
 -- begin    
       
       
 --  Insert Into @Emp_Cons    
    
 --  select I.Emp_Id from T0095_Increment I inner join     
 --    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment    
 --    where Increment_Effective_date <= @To_Date    
 --    and Cmp_ID = @Cmp_ID    
 --    group by emp_ID  ) Qry on    
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
           
 --  Where Cmp_ID = @Cmp_ID     
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
 --  --and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
 --  and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))    
 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
 --  and I.Emp_ID in     
 --   ( select Emp_Id from    
 --   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry    
 --   where cmp_ID = @Cmp_ID   and      
 --   (( @From_Date  >= join_Date  and  @From_Date <= left_date )     
 --   or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
 --   or Left_date is null and @To_Date >= Join_Date)    
 --   or @To_Date >= left_date  and  @From_Date <= left_date )     
       
 -- end    
    
  Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID --and Branch_ID = @Branch_ID    
			  and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date --and Branch_ID = @Branch_ID 
								and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
								and Cmp_ID = @Cmp_ID)    
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
  from T0040_General_setting gs inner join     
  T0050_General_Detail gd on gs.gen_Id =gd.gen_ID     
  where gs.Cmp_Id=@cmp_Id --and Branch_ID = isnull(@Branch_ID,Branch_ID)    
  and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
  and For_Date in (select max(For_Date) from T0040_General_setting  g inner join     
     T0050_General_Detail d on g.gen_Id =d.gen_ID       
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
	cmp_full_pf		  Tinyint	,
	Arear_M_AD_Amount		NUMERIC(18,2),
	Arear_M_AD_Calculated_Amount NUMERIC(18,2),
	Arear_Month_Salary_exists tinyint default 0,
	PF_AC21			  NUMERIC DEFAULT 0 -- Ankit 05042016 [ELSAMEX Client : Chintanbhai]
    )    
       -- (m_ad_Calculated_Amount + Arear_Basic) added by mitesh on 08/02/2012
     
       
      INSERT INTO @EMP_SALARY    
      SELECT  sg.Cmp_ID ,SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount     
     ,0 ,sg.Month_st_Date,SG.Month_End_date    
     ,MAD.PF_PER,MAD.PF_AMOUNT, (m_ad_Calculated_Amount + ISNULL(arear_basic,0) + ISNULL(Basic_Salary_Arear_cutoff,0) + isnull(CMD_new.Other_PF_Calculate,0)) as m_ad_Calculated_Amount  ,@PF_Limit,0,0,0,isnull(VPF,0),dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')    
     ,SG.Sal_Cal_Days,0,0,NULL,0,Isnull(sg.Arear_Day,0),e.Nationality
	 ,isnull(emp_auto_vpf,0) --added by hasmukh on 06 08 2013 for company full pf
	 ,ISNULL(Qry_arear.Arear_M_AD_Amount,0),ISNULL(Qry_arear.Arear_M_AD_Calculated_Amount,0)
	 ,0,0
    FROM    T0200_MONTHLY_SALARY  SG  INNER JOIN     
    (select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from     
     T0210_MONTHLY_AD_DETAIL AD INNER JOIN T0050_AD_MASTER AM ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID    
     and ad_not_effect_salary <> 1
     and AD.CMP_ID = @CMP_ID and isnull(Sal_Type,0)=0) MAD on SG.Emp_ID = MAD.Emp_ID    
     AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN    
     T0080_EMP_MASTER E ON SG.EMP_ID = E.EMP_ID inner join
	 t0095_increment inc on Sg.increment_id = inc.increment_id inner join    
    #EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID        
      left outer join
      
     (Select 	Emp_ID , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
					T0210_MONTHLY_AD_DETAIL AD INNER JOIN T0050_AD_MASTER AM ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<> 1
					and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND  CMD.SAL_TRAN_ID = SG.SAL_tRAN_ID  
	 left outer join  -- Added by rohit on 05102015
				(Select Emp_ID,sum((isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0))) as Other_PF_Calculate ,SAL_tRAN_ID 
				from	T0210_MONTHLY_AD_DETAIL AD INNER JOIN T0050_AD_MASTER AM ON AD.AD_ID = AM.AD_ID 
				where	EXISTS(SELECT	1 
									FROM	dbo.T0060_EFFECT_AD_MASTER EAM
											inner join T0050_AD_MASTER AM1 on EAM.Effect_AD_ID = AM1.AD_ID and EAM.CMP_ID = AM1.CMP_ID
									WHERE	AM1.AD_DEF_ID  = @PF_DEF_ID AND Am1.Cmp_ID  = @Cmp_ID AND EAM.AD_ID=AD.AD_ID
								) And ad_not_effect_salary <> 1 and sal_type<>1 and AD.CMP_ID = @CMP_ID group by emp_id,SAL_tRAN_ID
				) CMD_new on SG.Emp_ID= CMD_new.Emp_ID AND SG.SAL_tRAN_ID = CMD_new.SAL_TRAN_ID					 				
		LEFT OUTER JOIN	--Get Arear Calculated Amount --Ankit 06042016
				( SELECT MAD1.Emp_ID , m_ad_Amount AS arear_m_ad_Amount , m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount	 ,MAD1.For_Date,MAD1.To_date
				  FROM	T0210_MONTHLY_AD_DETAIL MAD1 INNER JOIN 
						T0050_AD_MASTER AM ON MAD1.AD_ID = AM.AD_ID  INNER JOIN
						#EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID
				  WHERE ad_DEF_id = @PF_DEF_ID  AND ad_not_effect_salary <> 1 AND sal_type<>1
				)  Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID 
						AND Qry_arear.For_Date >= CASE WHEN SG.Arear_Month <> 0 THEN dbo.GET_MONTH_ST_DATE(SG.Arear_Month,SG.Arear_Year) ELSE dbo.GET_MONTH_ST_DATE(NULL,NULL) END
						AND Qry_arear.to_date <= CASE WHEN SG.Arear_Month <> 0 THEN dbo.GET_MONTH_END_DATE(SG.Arear_Month,SG.Arear_Year) ELSE dbo.GET_MONTH_END_DATE(NULL,NULL) END
						
  WHERE   e.CMP_ID = @CMP_ID     
     and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date --changes by Falak on 04-jan-2011 bcoz the condition wrong 
  
  
  --select Arear_Month,Arear_Year ,ES.EMP_ID
        Update @EMP_SALARY set Arear_Month_Salary_exists = 1
        from @EMP_SALARY ES Inner jOIn T0200_MONTHLY_SALARY MS ON ES.EMP_ID = MS.Emp_ID
        WHERE  MS.CMP_ID = @CMP_ID and MS.Arear_Month <> 0 and MS.Month_St_Date >=@From_Date  and MS.Month_End_Date <= @To_Date 
        and Exists ( Select Sal_Tran_ID from T0200_MONTHLY_SALARY MS1 where ES.EMP_ID = MS1.Emp_ID and MOnth(MS1.Month_St_Date) =  MS.Arear_Month and year(MS1.Month_St_Date) =  MS.Arear_Year  ) 
  			
  	
  
  -----By Hasmukh 11-02-2012 For Settlement Pf Effect In main challan----Start
If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)
	Begin 
				INSERT INTO @EMP_SALARY
				SELECT  sg.Cmp_ID,SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date
					 ,MAD.PF_PER,MAD.PF_AMOUNT,m_ad_Calculated_Amount ,@PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,S_MONTH_ST_DATE,'N','N'),
					 SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,e.Nationality
					 ,isnull(emp_auto_vpf,0) --added by hasmukh on 06 08 2013 for company full pf 
					, 0,0,0,0
					FROM t0201_monthly_salary_sett  SG  INNER JOIN 
					( select Emp_ID , m_ad_Percentage as PF_PER , (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
						T0210_MONTHLY_AD_DETAIL AD INNER JOIN T0050_AD_MASTER AM ON AD.AD_ID = AM.AD_ID  
						where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
						and AD.CMP_ID = @CMP_ID and (m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) > 0 -- Greter Than Zero Condition --Ankit 06062016
					) MAD on SG.Emp_ID = MAD.Emp_ID 
						AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E ON SG.EMP_ID = E.EMP_ID inner join
						t0095_increment inc on Sg.increment_id = inc.increment_id inner join
					#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID	
					left outer join
					--Change Condition from Sal_Tran_Id to S_Sal_Tran_Id by Hardik 03/12/2016 for Wonder case for Twice Salary Settlement      
					--(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
					(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,AD.S_Sal_Tran_ID  from 
						T0210_MONTHLY_AD_DETAIL AD INNER JOIN T0050_AD_MASTER AM ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type=1
						and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.S_Sal_Tran_ID = CMD.S_Sal_Tran_ID --Change Condition from Sal_Tran_Id to S_Sal_Tran_Id by Hardik 03/12/2016 for Wonder case for Twice Salary Settlement      
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
    
    
  --update @EMP_SALARY    
  --set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit    
  -- ,PF_833 = @AC_10_1_Max_Limit    
  -- ,PF_367 = PF_Amount - @AC_10_1_Max_Limit    
  --where PF_SALARY_AMOUNT > PF_Limit and PF_Amount > 0   
     
      update @EMP_SALARY    
  set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit    
   ,PF_833 = @AC_10_1_Max_Limit    
   ,PF_367 = PF_Amount - @AC_10_1_Max_Limit    
  where PF_SALARY_AMOUNT > PF_Limit and PF_Amount > 0   AND Arear_Month_Salary_exists = 0
  
   update @EMP_SALARY    
  set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit    
   ,PF_833 = ROUND( (CASE WHEN (ISNULL(Arear_M_AD_Calculated_Amount,0) + (PF_SALARY_AMOUNT - SALARY_AMOUNT )) > PF_LIMIT THEN PF_LIMIT ELSE PF_SALARY_AMOUNT END) * 0.0833,0)    
   ,PF_367 = PF_Amount - ROUND((CASE WHEN (ISNULL(Arear_M_AD_Calculated_Amount,0) + (PF_SALARY_AMOUNT - SALARY_AMOUNT )) > PF_LIMIT THEN PF_LIMIT ELSE PF_SALARY_AMOUNT END) * 0.0833,0)   
  where PF_SALARY_AMOUNT > PF_Limit and PF_Amount > 0   AND Arear_Month_Salary_exists = 1
  
  
     
  update @EMP_SALARY    
  set PF_833 = 0    
   ,PF_367 = PF_Amount     
  where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0
  
  Update @EMP_SALARY --Ankit 09052016
	  set PF_LIMIT = PF_SALARY_AMOUNT
	 where PF_SALARY_AMOUNT < @PF_Limit
  
  
  Update @EMP_SALARY     --Ankit 09052016
		set PF_833 =   0    
		  ,PF_LIMIT =  0   
		where PF_833 = 0	 
	 
  Update @EMP_SALARY 
		set EDLI_Wages = PF_SALARY_AMOUNT
		, PF_AC21 = (PF_SALARY_AMOUNT * @AC_21_1) / 100	--Ankit 05042016
  where PF_AMOUNT > 0
	
 --Update @EMP_SALARY 
	--set EDLI_Wages = @PF_Limit-- 6500
 --where PF_SALARY_AMOUNT > @PF_Limit--6500 
	--	and PF_AMOUNT > 0 
	
	
	Update @EMP_SALARY 
	set EDLI_Wages = @PF_Limit-- 6500
	, PF_AC21 = (@PF_Limit * @AC_21_1) / 100	--Ankit 05042016
 where PF_SALARY_AMOUNT > @PF_Limit--6500 
		and PF_AMOUNT > 0 AND  Arear_Month_Salary_exists = 0
		
 Update @EMP_SALARY 
 set EDLI_Wages = ROUND( (CASE WHEN (ISNULL(Arear_M_AD_Calculated_Amount,0) + (PF_SALARY_AMOUNT - SALARY_AMOUNT )) > @PF_Limit THEN @PF_Limit ELSE PF_SALARY_AMOUNT END),0)
 ,PF_LIMIT =ROUND( (CASE WHEN (ISNULL(Arear_M_AD_Calculated_Amount,0) + (PF_SALARY_AMOUNT - SALARY_AMOUNT )) > @PF_Limit THEN @PF_Limit ELSE PF_SALARY_AMOUNT END),0)
 , PF_AC21 = ( (ROUND( (CASE WHEN (ISNULL(Arear_M_AD_Calculated_Amount,0) + (PF_SALARY_AMOUNT - SALARY_AMOUNT )) > @PF_Limit THEN @PF_Limit ELSE PF_SALARY_AMOUNT END),0)) * @AC_21_1) / 100	--Ankit 05042016
 where PF_SALARY_AMOUNT > @PF_Limit--6500 
		and PF_AMOUNT > 0 AND  Arear_Month_Salary_exists = 1
 
 --select PF_LIMIT,* from @EMP_SALARY --where Arear_Month_Salary_exists = 1 order by EMP_ID
 
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
  Declare @dblAC_21 as numeric (22,2)    --Ankit 05042016 
  
      
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
    set @dblAC_21 = 0
     
     
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
    
    select  @dblAC_21 = round(sum(PF_AC21),0)		--Ankit 05042016
    from @EMP_SALARY    
    where Cmp_ID = @Cmp_ID and  [month] = @month and [year] = @year and PF_Amount > 0    
    
        
    SELECT @Total_Family_Pension_Subscriber = count(emp_ID ) from @EMP_SALARY    
    Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0    
       
       
    
    --SELECT @Total_Family_Pension_Wages_Amount =  (sum(PF_SALARY_AMOUNT) -sum(PF_Diff_6500)) 
    --from @EMP_SALARY    
    --Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  
    
    
    --SELECT @Total_EDLI_Wages_Amount = (sum(PF_SALARY_AMOUNT) -sum(PF_Diff_6500)) 
    --from @EMP_SALARY    
    --Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0 
    
    --Ankit 09052016
     SELECT @Total_Family_Pension_Wages_Amount =  sum(PF_LIMIT) 
    from @EMP_SALARY    
    Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0
    
    
    SELECT @Total_EDLI_Wages_Amount = sum(EDLI_Wages)
    from @EMP_SALARY    
   -- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0
    --Ankit 09052016
    
    
    set @Total_EDLI_Subscriber = @Total_Subscriber     
    --set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit 
    set @dbl833 = isnull(@dbl833,0)     
    set @Total_Wages_Due = @Total_Wages_Due     
    set @Total_PF_Amount = @Total_PF_Amount     
    set @dblAC1_1 = @dbl367 
    set @dblAC10_1 = @dbl833    
    set @dblAC1_2 = @Total_PF_Amount    
    set @dblAC2_3  = round( @Total_Wages_Due * @AC_2_3/100,0 )    
    set @dblAC21_1 = ISNULL(@dblAC_21 ,0) --round(@Total_EDLI_Wages_Amount * @AC_21_1/100 ,0)    --Comment By Ankit 15072016
    
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
      
      select @Payment_Date = Payment_Date  from T0220_PF_CHALLAN where [Month] = Month(@TEMP_DATE) and [YEAR] = YEAR(@Temp_Date)
      
      IF @AC_21_1 = 0	--'' Ankit 29072016 [Nirma Client Case - Email Date - Fri, Jul 29, 2016 at 4:05 PM]
		  BEGIN
			SET	@dblAC22_3 = @dblAC22_4
			SET @dblAC22_4 = 0
		  END
        
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
     
     
   
 select * from @EMP_SALARY_Challan ES inner join T0010_COMPANY_MASTER CM on ES.Cmp_ID=CM.Cmp_Id 
     
     
      
RETURN     
    
   
*/
