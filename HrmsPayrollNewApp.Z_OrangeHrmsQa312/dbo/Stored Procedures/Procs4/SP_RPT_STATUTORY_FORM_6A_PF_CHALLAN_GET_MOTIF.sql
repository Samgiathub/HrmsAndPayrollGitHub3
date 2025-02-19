



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_6A_PF_CHALLAN_GET_MOTIF]            
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
,@constraint  varchar(5000)   
,@Sal_Type  numeric = 0
,@PBranch_ID varchar = '0'
,@Salary_Cycle_id numeric = 0	 -- Added By Gadriwala Muslim 21082013
 ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
 ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	

AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
       
declare @PF_LIMIT as numeric      
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
  
    if @Salary_Cycle_id = 0  -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = NULL
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
   

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
   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))				 -- Added By Gadriwala Muslim 21082013
   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))			 -- Added By Gadriwala Muslim 21082013
   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))		 -- Added By Gadriwala Muslim 21082013
  
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
      
 --------      
 DECLARE @TEMP_DATE AS DATETIME      
 SET @TEMP_DATE = @FROM_DATE      
       
      
 Declare @AC_1_1 numeric(10,2)      
 Declare @AC_1_2 numeric(10,2)      
 Declare @AC_2_3 numeric(10,2)      
 Declare @AC_10_1 numeric(10,2)      
 Declare @AC_21_1 numeric(10,2)      
 Declare @AC_22_3 numeric(10,2)      
 Declare @AC_22_4 numeric(10,2)      
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
  where gs.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)      
  and For_Date in (select max(For_Date) from T0040_General_setting  g WITH (NOLOCK) inner join       
     T0050_General_Detail d WITH (NOLOCK) on g.gen_Id =d.gen_ID         
  where g.Cmp_Id=@cmp_Id and Branch_ID = isnull(@Branch_ID,Branch_ID)      
       and For_Date <=@To_Date )      
               
   
   
  if @AC_21_1 =0  and @AC_10_1 > 0      
   Begin      
    set @AC_22_4 = @AC_22_3      
    set @AC_22_3= 0      
   end       
       
  DECLARE @EMP_SALARY TABLE      
   (      
    Cmp_ID     numeric,      
    EMP_ID     NUMERIC,      
    MONTH     NUMERIC,      
    YEAR     NUMERIC,      
    SALARY_AMOUNT   NUMERIC,      
    OTHER_PF_SALARY   NUMERIC,      
    MONTH_ST_DATE   DATETIME,      
    MONTH_END_DATE   DATETIME,      
    PF_PER     NUMERIC(18,2),      
    PF_AMOUNT    NUMERIC,      
    PF_SALARY_AMOUNT  NUMERIC,      
    PF_LIMIT    numeric,      
    PF_367     NUMERIC,      
    PF_833     NUMERIC,      
    PF_DIFF_6500   NUMERIC,      
    EMP_AGE     NUMERIC(5,1)       
    )      
         
      INSERT INTO @EMP_SALARY      
      SELECT  sg.Cmp_ID ,SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount       
     ,0 ,sg.Month_st_Date,SG.Month_End_date      
     ,MAD.PF_PER,MAD.PF_AMOUNT  , m_ad_Calculated_Amount,@PF_Limit,0,0,0,dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')      
    FROM  T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN       
    ( select Emp_ID , m_ad_Percentage as PF_PER , m_ad_Amount as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from       
     T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID      
     and ad_not_effect_salary <> 1  
     and AD.CMP_ID = @CMP_ID and isnull(Sal_Type,0)=0) MAD on SG.Emp_ID = MAD.Emp_ID       
     AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN      
     T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join      
    @EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID                    
   WHERE e.CMP_ID = @CMP_ID       
     and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date        
      
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
   Total_EDLI_Wages_Amount    numeric(18, 0)      
        
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
      
    --if  ( @AC_22_3 *  @Total_EDLI_Wages_Amount )/100 > 2       
     --set @dblAC22_3 =  Round((@AC_22_3 *  @Total_EDLI_Wages_Amount )/100,0)      
    --else      
     --set @dblAC22_3 = 2      
     --set @dblAC22_4 =  Round((@AC_22_4 *  @Total_EDLI_Wages_Amount )/100,0)      
       
     	--Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 5 to 500
	If @dblAC2_3 < 500
		Set @dblAC2_3 = 500
		
		
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
			IF  ( @AC_22_4 *  @Total_EDLI_Wages_Amount )/100 > 0  
				set @dblAC22_4 = 200   
		end
       
         
     if @Total_Subscriber > 0       
    begin      
      insert into @EMP_SALARY_Challan ( Cmp_ID , Total_Subscriber , Total_Wages_Due ,Total_PF_Diff_Limit ,      
            AC1_1 , AC1_2, AC2_3 , AC10_1 , AC21_1 ,AC22_3 ,For_Date,PF_Limit,AC22_4,      
            Total_Family_Pension_Subscriber,Total_Family_Pension_Wages_Amount,Total_EDLI_Subscriber,Total_EDLI_Wages_Amount)      
      values ( @Cmp_ID , @Total_Subscriber , @Total_Wages_Due ,@Total_PF_Diff_Limit ,      
            @dblAC1_1 , @dblAC1_2, @dblAC2_3 , @dblAC10_1 , @dblAC21_1 ,@dblAC22_3,@Temp_DAte ,@PF_Limit,@dblAC22_4,      
            @Total_Family_Pension_Subscriber,@Total_Family_Pension_Wages_Amount,@Total_EDLI_Subscriber,@Total_EDLI_Wages_Amount)      
    end                   
      
    SET @TEMP_DATE = DATEADD(M,1,@TEMP_DATE)      
  END  
 select * from @EMP_SALARY_Challan      
RETURN       
      
      
      

