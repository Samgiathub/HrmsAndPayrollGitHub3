  
CREATE  PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_3A_GET_EXPORT_TEXT080322]  
  @Cmp_ID   numeric  
 ,@From_Date  datetime  
 ,@To_Date   datetime  
 ,@Branch_ID  varchar(max)=''  --Added By Jaina 5-11-2015 Start  
 ,@Cat_ID   varchar(max)=''   
 ,@Grd_ID   varchar(max)=''  
 ,@Type_ID   varchar(max)=''  
 ,@Dept_ID   varchar(max)=''  
 ,@Desig_ID   varchar(max)='' --Added By Jaina 5-11-2015 End  
 ,@Emp_ID   numeric  
 ,@constraint  varchar(MAX)  
 ,@Segment_Id  varchar(max)=''  --Added By Jaina 5-11-2015 Start  
 ,@Vertical_Id varchar(max)=''  
 ,@SubVertical_Id varchar(max)=''  
 ,@SubBranch_Id varchar(max)=''  --Added By Jaina 5-11-2015 End      
 ,@Format  tinyint = 2 --Added By Jimit 03012016 End     
 ,@Export_Type  varchar(100) = ''  --added by chetan 031017   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
    
 DECLARE @PF_LIMIT as numeric  
 DECLARE @PF_DEF_ID as numeric  
 DECLARE @Edli_charge as numeric(18,2) -- Added by rohit for Edli employee wise.  
 DECLARE @Admin_Charge_Empwise AS NUMERIC(18,2) --Added By Ramiz on 21/10/2018  
   
 SET @PF_LIMIT = 15000  
 SET @PF_DEF_ID = 2  
   
 IF @Branch_ID = '0' or @Branch_ID=''  
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
  
 If @Segment_Id = '0' or @Segment_Id=''  --Added By Jaina 5-11-2015 Start   
  set @Segment_Id = null  
    
 If @Vertical_Id = '0' or @Vertical_Id=''     
  set @Vertical_Id = null  
    
 If @SubVertical_Id = '0' or @SubVertical_Id=''     
  set @SubVertical_Id = null   
    
 If @SubBranch_Id = '0' or @SubBranch_Id='' --Added By Jaina 5-11-2015 End   
  set @SubBranch_Id = null   
       
  CREATE table #Emp_Cons  
  (  
  Emp_ID numeric,  
  Branch_ID numeric,  --Added By Jaina 5-11-2015  
  Increment_ID numeric --Added By Jaina 5-11-2015     
  )    
   
 --Added By Mukti(17022017)start  
  DECLARE @EMP_SALARY_Challan table      
   (                 
    Cmp_ID     numeric,      
    Total_NonPF_Subscriber numeric,  
    Total_NonPF_Wages numeric(18,2),  
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
          
  Declare @Total_Wages_Due as numeric(18,2)      
  Declare @Total_Subscriber as numeric      
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
  Declare @AC_2_3 numeric(10,2)  
  Declare @AC_21_1 numeric(10,2)      
  Declare @AC_22_3 numeric(10,4)      
  Declare @AC_22_4 numeric(10,4)    
  DEclare @Payment_Date Datetime  
  Declare @Sal_St_Date   Datetime      
  Declare @Sal_end_Date   Datetime  
  Declare @IS_NCP_PRORATA as int    
 --Added By Mukti(17022017)end  
  DECLARE @PF_Pension_Age as numeric(18,2)  
  DECLARE @manual_salary_period as numeric(18,0)  
  DECLARE @Total_NonPF_Subcriber as numeric  
  DECLARE @Total_NonPF_Wages as numeric(18,2)    
   
 --Added By Jaina 5-11-2015  
 EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0       
   
 Set @IS_NCP_PRORATA = 0   
   
 If @Branch_ID is null  
  BEGIN   
   SELECT TOP 1 @Sal_St_Date  = Sal_st_Date, @PF_LIMIT =  PF_LIMIT, @IS_NCP_PRORATA = IS_NCP_PRORATA,@EDLI_CHARGE = ISNULL(GD.ACC_21_1,0) ,   
    @Admin_Charge_Empwise = ISNULL(GD.ACC_21_1,0) , @PF_Pension_Age = ISNULL(GD.PF_PENSION_AGE,0), @manual_salary_period=isnull(Manual_Salary_Period ,0)   
   FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)  
    INNER JOIN T0050_GENERAL_DETAIL GD WITH (NOLOCK) On GS.Gen_ID = GD.GEN_ID And GS.Cmp_ID = GD.CMP_ID      
   WHERE GS.Cmp_ID = @cmp_ID and For_Date = ( SELECT max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)  
  END  
 ELSE  
  BEGIN  
   --select @Sal_St_Date  =Sal_st_Date, @PF_LIMIT =  PF_LIMIT , @IS_NCP_PRORATA = IS_NCP_PRORATA,@Edli_charge=GD.ACC_21_1  
   --  from T0040_GENERAL_SETTING GS Inner Join T0050_GENERAL_DETAIL GD On GS.Gen_ID = GD.GEN_ID And GS.Cmp_ID = GD.CMP_ID  
   --  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=GS.Branch_ID   
   --  where GS.Cmp_ID = @cmp_ID   
   --  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING G1  
   --  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T1 ON T1.Branch_ID=G1.Branch_ID   
   --  where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)  
  
      
  
     
   SELECT @Sal_St_Date  = Sal_st_Date, @PF_LIMIT =  PF_LIMIT , @IS_NCP_PRORATA = IS_NCP_PRORATA,@EDLI_CHARGE = ISNULL(GD.ACC_21_1,0) ,   
     @Admin_Charge_Empwise = ISNULL(GD.ACC_21_1,0) , @PF_Pension_Age = ISNULL(GD.PF_PENSION_AGE,0), @manual_salary_period=isnull(Manual_Salary_Period ,0)   
   FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)  
    INNER JOIN T0050_GENERAL_DETAIL GD WITH (NOLOCK) ON GS.GEN_ID =GD.GEN_ID       
   WHERE GS.CMP_ID = @CMP_ID  
    AND EXISTS (SELECT Data from dbo.Split(ISNULL(@Branch_ID,gs.Branch_ID), '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))  --Added By Jaina 5-11-2015  
    AND For_Date IN ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING G WITH (NOLOCK)  
          WHERE G.Cmp_Id = @cmp_Id AND G.For_Date <= @To_Date   
          AND EXISTS (select Data from dbo.Split(ISNULL(@Branch_ID,G.Branch_ID), '#') B Where cast(B.data as numeric)=Isnull(G.Branch_ID,0))  --Added By Jaina 5-11-2015  
        )   
  
  END      
  
  IF ISNULL(@Sal_St_Date,'') = ''      
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
     --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)      
     --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))  
     --set @From_Date = @Sal_St_Date  
     --Set @To_Date = @Sal_end_Date     
  
   if @manual_salary_period = 0   
    begin  
     SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)      
     SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))   
          
     SET @From_Date = @Sal_St_Date  
     SET @To_Date = @Sal_End_Date   
    end   
   else  
    begin  
     select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)  
           
     SET @From_Date = @Sal_St_Date  
     SET @To_Date = @Sal_End_Date   
    end     
  End  
    
 --------  
 DECLARE @TEMP_DATE AS DATETIME   
   
 DECLARE @PF_REPORT TABLE  
  (  
   MONTH  NUMERIC ,  
   YEAR  NUMERIC ,  
   FOR_DATE DATETIME  
  )  
   
 SET @TEMP_DATE = @FROM_DATE  
   
 WHILE @TEMP_DATE <= @TO_DATE  
  BEGIN  
   INSERT INTO @PF_REPORT (MONTH,YEAR,FOR_DATE)  
   VALUES(MONTH(@TEMP_DATE),YEAR(@TEMP_DATE),@TEMP_DATE)   
     
   SET @TEMP_DATE = DATEADD(m,1,@TEMP_DATE)  
  END  
  
 If Object_ID('tempdb..#EMP_PF_REPORT') is NOT Null  
  begin  
   drop table #EMP_PF_REPORT  
  end  
     
 CREATE table #EMP_PF_REPORT   
  (  
   CMP_ID NUMERIC,  
   EMP_CODE NUMERIC,  
   EMP_ID  NUMERIC,  
   EMP_NAME VARCHAR(85) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   PF_NO  VARCHAR(85) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   MONTH  NUMERIC,  
   YEAR  NUMERIC,  
   FOR_DATE DATETIME  
  )  
    
 INSERT INTO  #EMP_PF_REPORT  
 SELECT  QRY.CMP_ID,QRY.EMP_CODE,QRY.EMP_ID,Emp_Name,  
  Case When CHARINDEX('/',PF_NO,1) > 0 Then  
    Right(Right(PF_NO,CHARINDEX('/',Reverse(PF_NO),1)-1),7)  
  Else   
   Left(PF_NO,50)  
  End ,t.month, t.year, t.for_Date from @PF_Report t cross join   
 ( SELECT DISTINCT SG.CMP_ID,SG.EMP_ID ,E.EMP_CODE   
   ,Replace(Replace(Replace(Replace(ISNULL(E.EmpName_Alias_PF,E.Emp_First_Name + ' ' + E.Emp_Second_Name + ' '+ E.Emp_Last_Name),'Mr. ',''),'Ms. ',''),'Dr. ',''),'Mrs. ','') As Emp_Name  
   ,E.SSN_No as PF_NO FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN   
   ( select Emp_ID , M_AD_Percentage as PF_PER , M_AD_Amount as PF_Amount ,sal_Tran_ID  
     from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID where AD_DEF_ID = @PF_DEF_ID   
     and ad_not_effect_salary <> 1  
     and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID   
      and SG.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN  
    T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID INNER JOIN  
    #EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID      
  WHERE   e.CMP_ID = @CMP_ID   
    and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date )QRY      
  
  
 If Object_ID('tempdb..#EMP_DETAIL') is NOT Null  
  begin  
   drop table #EMP_DETAIL  
  end  
     
  CREATE TABLE #EMP_DETAIL  
  (  
   CMP_ID    NUMERIC,  
   EMP_ID    NUMERIC,  
   FATHER_HUSBAND_NAME VARCHAR(150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   RELATION   Varchar(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   DOB     Varchar(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   GENDER    Varchar(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   DOJ     Varchar(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   LEFT_DATE   Varchar(13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,  
   LEFT_REASON   Varchar(4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL  
  )  
  
 INSERT INTO  #EMP_DETAIL  
 SELECT  QRY.CMP_ID,QRY.EMP_ID,  
  Case When Month(Date_Of_Join)= Month(@To_Date) And Year(Date_Of_Join) = Year(@To_Date) Then  
   ISNULL(Father_name,'') + '#~#' --Add ISNULL Condition --Ankit 19012015  
  Else  
    '#~#'   
  End,  
  Case When Month(Date_Of_Join)= Month(@To_Date) And Year(Date_Of_Join) = Year(@To_Date) Then  
    Case When Gender = 'F' And Marital_Status = 1 Then  
     'S#~#'Else 'F#~#'   
    End  
  Else  
   '#~#'   
  End,  
  Case When Month(Date_Of_Join)= Month(@To_Date) And Year(Date_Of_Join) = Year(@To_Date) Then  
   isnull(Convert(varchar(10),Date_Of_Birth,103),'')+ '#~#'   
  Else  
    '#~#'   
  End,  
  Case When Month(Date_Of_Join)= Month(@To_Date) And Year(Date_Of_Join) = Year(@To_Date) Then  
   Gender + '#~#'   
  Else  
    '#~#'   
  End,  
  Case When Month(Date_Of_Join)= Month(@To_Date) And Year(Date_Of_Join) = Year(@To_Date) Then  
    Convert(varchar(10),Date_Of_Join,103)+ '#~#'   
  Else  
    '#~#'   
  End,  
  Case When Month(Emp_Left_Date)= Month(@To_Date) And Year(Emp_Left_Date) = Year(@To_Date) Then  
    Convert(varchar(10),Emp_Left_Date,103)+ '#~#'   
  Else  
    '#~#'   
  End,  
  Case When Month(Emp_Left_Date)= Month(@To_Date) And Year(Emp_Left_Date) = Year(@To_Date) Then  
   Case When Is_Death = 1 then  
    'D' Else 'C'  
   End  
  Else  
    ''   
  End  
  from (Select top 1 * from @PF_Report) t cross join   
 ( SELECT DISTINCT SG.CMP_ID,SG.EMP_ID ,E.EMP_CODE ,E.Emp_First_Name + ' '+ E.Emp_Last_Name As Emp_Name,SSN_NO as PF_NO,  
   E.Father_name,E.Date_Of_Join,E.Date_Of_Birth,E.Gender,E.Marital_Status,E.Emp_Left_Date, LE.Is_Death  
  FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN   
   ( select Emp_ID , M_AD_Percentage as PF_PER , M_AD_Amount as PF_Amount ,sal_Tran_ID  
     from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID where AD_DEF_ID = @PF_DEF_ID   
     and ad_not_effect_salary <> 1  
     and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID   
      and SG.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN  
    T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID INNER JOIN  
    #EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID LEFT OUTER JOIN  
    T0100_LEFT_EMP LE WITH (NOLOCK) ON E.Emp_ID = LE.Emp_ID  
  WHERE   e.CMP_ID = @CMP_ID   
    and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date )QRY      
  
  
 If Object_ID('tempdb..#EMP_SALARY') is NOT Null  
  begin  
   drop table #EMP_SALARY  
  end  
   
  CREATE table #EMP_SALARY   
   (  
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
    VPF                   NUMERIC,  
    Emp_Age     NUMERIC,  
    Sal_Cal_Day    Numeric(18,2), -- Added by Falak on 09-MAY-2011  
    Absent_days    NUMERIC,  
    Is_Sett                 TinyINt Default 0,    --Nikunj 25-04-2011  
    Sal_Effec_Date          DateTime Default GetDate(), --Nikunj 25-04-2011  
    EDLI_Wages    Numeric,  
    Arear_Day    Numeric(18,2),  
    arrear_days    numeric(18,1),  
    VPF_PER     Numeric(18,2),  
    Arrear_Wages   Numeric, --Hardik 17/04/2012  
    Arrear_PF_Amount  Numeric, --Hardik 17/04/2012  
    Arrear_PF_833   Numeric, --Hardik 17/04/2012  
    Arrear_PF_367   Numeric,  --Hardik 17/04/2012,  
    Nationality    varchar(100),  
    cmp_full_pf    Tinyint,      
    Arear_M_AD_Amount  NUMERIC(18,2),  
    Arear_M_AD_Calculated_Amount NUMERIC(18,2),  
    Arrear_Wages_833  Numeric default 0, --Hardik 12/01/2017  
    Gross_Salary   Numeric(18,2), --Mukti(18022017)  
    Arrear_VPF_Amount       Numeric(18,2), --Hardik 26/12/2017  
    PF_Admin_Charge_Empwise Numeric(18,2), --Ramiz 20/10/2018  
    Edli_Charge_EmpWise  Numeric(18,2), --Ramiz 20/10/2018  
    Arrear_PF_Admin_Charge_Empwise Numeric(18,2),  
    Arrear_Edli_Charge_EmpWise  Numeric(18,2),  
    PFsettID  integer  
    )  
     
    
   DECLARE @String as varchar(max)  
             
      INSERT INTO #EMP_SALARY  
        
     
      SELECT    
   --m_ad_Calculated_Amount a,sg.basic_salary b, Isnull(Qr_1.M_AREAR_AMOUNT1,0) c,  
   --m_ad_Calculated_Amount + case when sg.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) end,  
   SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount   
     ,0 ,sg.Month_st_Date,SG.Month_End_date  
     ,MAD.PF_PER,  
      MAD.PF_AMOUNT  ,--(m_ad_Calculated_Amount + Arear_Basic) as m_ad_Calculated_Amount,  
     --(m_ad_Calculated_Amount )--+ Isnull(Basic_Salary_Arear_cutoff,0)) --+ isnull(Other_PF_Calculate,0))   
    case when @Format IN (8) then   
       --Arear_Basic  + case when sg.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end   
       Case When (Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end + Arear_M_AD_Calculated_Amount) < @PF_LIMIT then  
        Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end    
       Else  
        Case When Arear_M_AD_Calculated_Amount < @PF_Limit And OAB.Basic_Salary < @PF_LIMIT  Then   
         @PF_LIMIT - Arear_M_AD_Calculated_Amount   
        Else Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end    
        End  
       End          
  
      when @Format in (4,5,10,2) then  m_ad_Calculated_Amount + case when sg.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end   
    else  m_ad_Calculated_Amount end as m_ad_Calculated_Amount ,  
     --m_ad_Calculated_Amount as m_ad_Calculated_Amount,  
       
     @PF_Limit,0,0,0,isnull(CMD.VPF,0),dbo.F_GET_AGE(Date_of_Birth,MONTH_ST_DATE,'N','N')  
     ,SG.Sal_Cal_Days,0,0,NULL,0,Isnull(sg.Arear_Day,0) -- Added by Falak on 09-MAY-2011  
     ,SG.arear_day,VPF_PER, -- added by mitesh on 18/02/2012  
     case when @Format in (3,8,4,10,2) then   
     --(Isnull(Arear_Basic,0)) + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end    
     Case When (Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end + Arear_M_AD_Calculated_Amount) < @PF_LIMIT then  
        Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end    
       Else  
        Case When Arear_M_AD_Calculated_Amount < @PF_Limit And OAB.Basic_Salary < @PF_LIMIT  Then   
         @PF_LIMIT - Arear_M_AD_Calculated_Amount   
        Else Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end    
        End  
       End   
    else (Isnull(Arear_Basic,0))  end  as Arear_Basic --+ Isnull(Basic_Salary_Arear_cutoff,0) + isnull(Other_PF_Calculate,0) ) as Arear_Basic   
    ,Isnull(M_AREAR_AMOUNT,0)    
    ,0,0,Nationality  
     ,isnull(emp_auto_vpf,0) --added by hasmukh on 06 08 2013 for company full pf  
     ,ISNULL(Qry_arear.Arear_M_AD_Amount,0),ISNULL(Qry_arear.Arear_M_AD_Calculated_Amount,0)+ Isnull(Other_Arear_Basic,0)- Isnull(Arear_Basic,0)  
     ,0,SG.Gross_Salary,VPF_Arear  
     , 0 , 0 , 0 , 0,isnull(inc.Is_1time_PF_Member,0)  
  
    FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN   
    (Select ad.Emp_ID , m_ad_Percentage as PF_PER , --(m_ad_Amount + M_AREAR_AMOUNT) as PF_Amount,  
      (m_ad_Amount + isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount,(isnull(M_AREAR_AMOUNT,0) ) as M_AREAR_AMOUNT --+isnull(M_AREAR_AMOUNT_Cutoff,0)) as M_AREAR_AMOUNT ,  + ISNULL(Arear_Basic,0)  
       ,m_ad_Calculated_Amount + Case When @Format in (4,5,2) then ISNULL(Arear_Basic,0) Else 0 end + (case when isnull(ad.M_AREAR_AMOUNT_Cutoff,0)=0 then 0 else MS.Basic_Salary_Arear_cutoff end) as m_ad_Calculated_Amount ,ad.SAL_tRAN_ID   
     ,M_AREAR_AMOUNT_Cutoff  
     from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID   
     inner join t0200_monthly_salary MS WITH (NOLOCK) on AD.sal_tran_id = ms.sal_tran_id  
     where ad_DEF_id = @PF_DEF_ID  And ad_not_effect_salary <> 1 and sal_type<>1  
      and AD.CMP_ID = @CMP_ID   
    )MAD on SG.Emp_ID = MAD.Emp_ID    
      AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN  
      T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join  
      t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join  
      #EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID  
    left outer join  
    --(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID,AD.M_AD_Percentage as VPF_PER    
     (Select Emp_ID,  
    --(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,  
    M_AD_Amount AS VPF, isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0) as VPF_Arear,  
    SAL_tRAN_ID,AD.M_AD_Percentage as VPF_PER    
     from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID   
     where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<>1  
          and AD.CMP_ID = @CMP_ID  
     ) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID      
    left outer join  -- Added by rohit on 05102015  
    (Select Emp_ID,(isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as Other_PF_Calculate ,SAL_tRAN_ID   
     from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID    
     where AD.ad_id = (SELECT  TOP 1 EAM.AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)  --Added By Jaina 5-11-2015 (Top 1)  
               inner join T0050_AD_MASTER AM WITH (NOLOCK) on EAM.Effect_AD_ID = AM.AD_ID and EAM.CMP_ID = AM.CMP_ID  
           WHERE AM.AD_DEF_ID  = @PF_DEF_ID AND Am.Cmp_ID  = @Cmp_ID  
          )And ad_not_effect_salary <> 1 and sal_type<>1  
     and AD.CMP_ID = @CMP_ID  
    ) CMD_new on SG.Emp_ID= CMD_new.Emp_ID AND SG.SAL_tRAN_ID = CMD_new.SAL_TRAN_ID         
    LEFT OUTER JOIN --Get Arear Calculated Amount --Ankit 06042016  
    ( SELECT MAD1.Emp_ID , m_ad_Amount AS arear_m_ad_Amount , m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount,  
      MAD1.For_Date,MAD1.To_date  
      FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN  
      T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN  
      #EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID  
      WHERE ad_DEF_id = @PF_DEF_ID  AND ad_not_effect_salary <> 1 AND sal_type<>1  
    )  Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID   
      AND Qry_arear.For_Date >= CASE WHEN SG.Arear_Month <> 0 THEN dbo.GET_MONTH_ST_DATE(SG.Arear_Month,SG.Arear_Year) ELSE dbo.GET_MONTH_ST_DATE(NULL,NULL) END  
      AND Qry_arear.to_date <= CASE WHEN SG.Arear_Month <> 0 THEN dbo.GET_MONTH_END_DATE(SG.Arear_Month,SG.Arear_Year) ELSE dbo.GET_MONTH_END_DATE(NULL,NULL) END        
    LEFT OUTER JOIN  
     (Select MS.Emp_ID, Sum(MS.Arear_Basic) As Other_Arear_Basic, MS.Arear_Month, MS.Arear_Year,basic_salary  
      From T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN  
        #EMP_CONS EC1 on MS.Emp_ID = EC1.Emp_ID  
      WHERE Isnull(MS.Arear_Month,0) <> 0 And Isnull(MS.Arear_Year,0) <> 0 And MS.Month_End_Date <=@To_Date  
      GROUP BY MS.Emp_ID, MS.Arear_Month, MS.Arear_Year,basic_salary  
     )OAB On SG.Emp_ID=OAB.Emp_ID And SG.Arear_Month=OAB.Arear_Month And SG.Arear_Year=OAB.Arear_Year   
      
    LEFT OUTER JOIN(  
         SELECT MAD1.EMP_ID,ISNULL(SUM(M_AREAR_AMOUNT),0) + ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0) as M_AREAR_AMOUNT1,MONTH(MAD1.To_DATE) as monthArrear,Year(MAD1.To_DATE) as YearArrear  
         FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN  
           T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN  
           #EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID  
         WHERE MONTH(MAD1.To_DATE) = MONTH(@TO_DATE) And YEAR(MAD1.To_DATE) = YEAR(@To_Date)  
           AND ad_not_effect_salary = 0 and AD_FLAG = 'I' --and M_AREAR_AMOUNT <> 0 -- Commented by Hardik 07/08/2020 for WHFL Case, cutoff Allowance minus amounts not adding in PF Wages  
           and AM.ad_id in (SELECT  EAM.AD_ID    
               FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)   
                 inner join T0050_AD_MASTER AM WITH (NOLOCK) on EAM.Effect_AD_ID = AM.AD_ID and EAM.CMP_ID = AM.CMP_ID  
               WHERE AM.AD_DEF_ID  = @PF_DEF_ID AND Am.Cmp_ID  = @Cmp_ID  
               )  
         GROUP BY MAD1.Emp_ID,Mad1.To_date  
        )Qr_1 ON Qr_1.EMP_ID = SG.Emp_id --and SG.Arear_Month=Qr_1.monthArrear And SG.Arear_Year=Qr_1.YearArrear  
      
  WHERE   e.CMP_ID = @CMP_ID --changed by Falak on 04-JAN-2010 due error in condition and more than one record for same emp binds.  
     and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date    
  
  
--In form 3a you have to saw March Challn Paid in April.for This Setting you can see in Report Leval Formula.Nikunj  
-----By nikunj 25-04-2011 For Settlement Pf Effect In Form 3A--------------------------Start  
If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)  
 Begin   
    --print 111---mansi  
       
    INSERT INTO #EMP_SALARY  
    SELECT  SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date  
      ,MAD.PF_PER,MAD.PF_AMOUNT,m_ad_Calculated_Amount ,@PF_Limit,0,0,0,0--isnull(CMD.VPF,0)  
      ,dbo.F_GET_AGE(Date_of_Birth,S_MONTH_ST_DATE,'N','N'),  
      --SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,0,VPF, -- Added by Falak on 09-MAY-2011  
      SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,0,VPF_PER, -- Added by Falak on 09-MAY-2011 --Hardik 26/12/2017  
      0,(ISNULL(M_AREAR_AMOUNT,0)) as M_AREAR_AMOUNT ,0,0,Nationality  
      ,isnull(emp_auto_vpf,0) --added by hasmukh on 06 08 2013 for company full pf  
      ,ISNULL(Qry_arear.Arear_M_AD_Amount,0),ISNULL(Qry_arear.Arear_M_AD_Calculated_Amount,0),0  
      ,SG.S_Gross_Salary,VPF_Arear ,  0 , 0 , 0 , 0  
      ,0 --added mansi  
     FROM t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN   
     ( select Emp_ID , m_ad_Percentage as PF_PER , --(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as PF_Amount  
      m_ad_Amount as PF_Amount,(isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as M_AREAR_AMOUNT,  
      m_ad_Calculated_Amount ,S_SAL_tRAN_ID from   
      T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID    
      where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1  
      and AD.CMP_ID = @CMP_ID AND m_ad_Amount <> 0 ---- Greter Than Zero Condition --Ankit 06062016  
     ) MAD on SG.Emp_ID = MAD.Emp_ID   
      AND SG.S_SAL_tRAN_ID = MAD.S_SAL_TRAN_ID INNER JOIN  
      T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join  
      t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join  
     #EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID   
     left outer join  
     --Change Condition from Sal_Tran_Id to S_Sal_Tran_Id by Hardik 03/12/2016 for Wonder case for Twice Salary Settlement  
     --(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from   
     (Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF_Arear,AD.S_Sal_Tran_ID,AD.M_AD_Percentage as VPF_PER  from   
      T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type=1  
      and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.S_Sal_Tran_ID = CMD.S_Sal_Tran_ID  
     LEFT OUTER JOIN --Get Arear Calculated Amount --Ankit 06042016  
     ( SELECT MAD1.Emp_ID , m_ad_Amount AS arear_m_ad_Amount , m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount,MAD1.For_Date,MAD1.To_date,Sal_Tran_ID  
       FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN   
       T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN  
       #EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID  
       WHERE ad_DEF_id = @PF_DEF_ID  AND ad_not_effect_salary <> 1 AND sal_type<>1  
     )  Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID AND SG.Sal_Tran_ID = Qry_arear.Sal_Tran_ID   
   WHERE   e.CMP_ID = @CMP_ID   
      And S_Eff_Date Between @From_Date And @To_Date  
      --and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date   
        
        
      ---Ankit----  
     Update #EMP_SALARY  
    set  
      PF_833 =  PF_SALARY_AMOUNT * 0.0833,  
      PF_367 =  PF_AMOUNT - (PF_SALARY_AMOUNT * 0.0833)  
    where Is_Sett=1  
      
  
      
     UPDATE #EMP_SALARY  
    SET    
     Arrear_PF_833 = CASE WHEN (PF_833 + ROUND(Arear_M_AD_Calculated_Amount * 0.0833,2)) > 1250 THEN 1250 - ROUND((Arear_M_AD_Calculated_Amount * 0.0833),2) ELSE PF_833 END  
     ,Arrear_PF_367 = (PF_Amount)  - CASE WHEN (PF_833 + ROUND(Arear_M_AD_Calculated_Amount * 0.0833,2)) > 1250 THEN 1250 - ROUND((Arear_M_AD_Calculated_Amount * 0.0833),2) ELSE PF_833 END  
    where Round((Arear_M_AD_Calculated_Amount * 0.0833),0) < 1250 and Is_Sett=1 and Arear_M_AD_Calculated_Amount<>0  
      
  
      
    UPDATE #EMP_SALARY  
    SET   
     Arrear_PF_833 = 0  
     ,Arrear_PF_367 = (PF_Amount)   
    where ROUND((Arear_M_AD_Calculated_Amount * 0.0833),0) >= 1250 and Is_Sett=1  
      
      
      
      ---Ankit ----  
       
    --Update #EMP_SALARY Set   
    --Salary_Amount= ES.Salary_Amount+Qry.Salary_Amount,  
    --PF_Amount=ES.PF_Amount+Qry.PF_Amount,  
    --PF_Salary_Amount=ES.PF_Salary_Amount+Qry.PF_Salary_Amount,   
    --VPF = es.VPF + qry.VPF From   
    --#EMP_SALARY As ES INNER JOIN  
    --(Select SUM(Salary_Amount) As Salary_Amount,SUM(PF_Amount) As PF_Amount,SUM(PF_Salary_Amount) As PF_Salary_Amount,SUM(VPF) as VPF,Emp_Id,Sal_Effec_Date From #EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID
 And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)  
  
    Update #EMP_SALARY   
    Set Arrear_Wages_833 = Case When isnull(Arear_M_AD_Calculated_Amount,0) + PF_SALARY_AMOUNT <= PF_Limit then  -- Chnage SALARY_AMOUNT to PF_SALARY_AMOUNT BY Hardik 26/09/2018 for Daimines  
           PF_SALARY_AMOUNT   
          When PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount,0) then  
            PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount,0)  
          Else 0  End,  
     Arrear_PF_833 = round((Case When isnull(Arear_M_AD_Calculated_Amount,0) + PF_SALARY_AMOUNT <= PF_Limit then   
           PF_SALARY_AMOUNT   
          When PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount,0) then  
            PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount,0)  
          Else 0  End) * 0.0833,0)  
    Where Is_Sett=1  
  
  
  
    --- Commented above code by Hardik and Add below code by Hardik 03/01/2013 for Settlement Amount show in Arear Columns  
    Update #EMP_SALARY Set   
    Arrear_Wages= Isnull(Arrear_Wages,0) + Isnull(Qry.PF_Salary_Amount,0),  
    Arrear_PF_Amount= Isnull(Arrear_PF_Amount,0) + Isnull(Qry.PF_Amount,0)  
    --VPF = es.VPF + qry.VPF --Hardik 26/12/2017  
    ,Arrear_PF_833 = qry.Arrear_PF_833  
    ,Arrear_PF_367 = qry.Arrear_PF_367  
    ,PF_833 = 0,PF_367 =0,  
    is_sett=2,  
    Arrear_Wages_833=Qry.Arrear_Wages_833,  
    Arrear_VPF_Amount=Qry.Arrear_VPF_Amount --Hardik 26/12/2017  
    From   
    #EMP_SALARY As ES INNER JOIN  
    (Select SUM(Salary_Amount) As Salary_Amount,SUM(PF_Amount) As PF_Amount,SUM(PF_Salary_Amount) As PF_Salary_Amount,SUM(VPF) as VPF,Emp_Id,Sal_Effec_Date   
      ,SUM(Arrear_PF_833) as Arrear_PF_833,SUM(Arrear_PF_367) AS Arrear_PF_367,Sum(Arrear_Wages_833) as Arrear_Wages_833, SUM(Arrear_VPF_Amount) As Arrear_VPF_Amount  
    From #EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)  
  
    Delete From #EMP_SALARY where Is_Sett=1  
 End    
------------------------------------------------------------------------------------------End  
    
    
  DECLARE @PF_NOT_FUll_AMT As Numeric(18,2)  
  DECLARE @PF_541 As Numeric(18,2)  
    
  --DECLARE @PF_Pension_Age as numeric(18,2)  
  --SELECT TOP 1 @PF_Pension_Age = isnull(GD.PF_PENSION_AGE,0)  
  --FROM T0040_General_setting gs   
  -- INNER JOIN T0050_General_Detail gd on gs.gen_Id =gd.gen_ID       
  --WHERE gs.Cmp_Id=@cmp_Id  
  -- AND EXISTS (select Data from dbo.Split(ISNULL(@Branch_ID,gs.Branch_ID), '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))  --Added By Jaina 5-11-2015  
  -- AND For_Date IN ( SELECT MAX(For_Date) FROM T0040_General_setting  g  
  --       --INNER JOIN  T0050_General_Detail d on g.gen_Id = d.gen_ID  --Commented By Ramiz , as it is not Required ( 20/10/2018)  
  --       WHERE g.Cmp_Id = @cmp_Id AND For_Date <= @To_Date   
  --       AND EXISTS (select Data from dbo.Split(ISNULL(@Branch_ID,branch_ID), '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))  --Added By Jaina 5-11-2015  
  --     )   
      
   
  SET @PF_541 = 0  
  SET @PF_NOT_FUll_AMT = 0  
    
  Set @PF_541 = round(@PF_Limit * 0.0833,0)  
  SET @PF_NOT_FUll_AMT = round(@PF_Limit * 12/100,0)  
    
  update #EMP_SALARY  
  set   PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)  
    ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0)  
  where PF_SALARY_AMOUNT <= PF_Limit  
  
  Update #EMP_SALARY   
  Set Arrear_Wages_833 = Case When isnull(Arear_M_AD_Calculated_Amount,0) + Arrear_Wages <= PF_Limit then   
         Arrear_Wages   
        When PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount,0) then  
          PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount,0)  
        Else 0  End,  
     Arrear_PF_833 = round((Case When isnull(Arear_M_AD_Calculated_Amount,0) + Arrear_Wages <= PF_Limit then   
        Arrear_Wages   
       When PF_LIMIT > isnull(Arear_M_AD_Calculated_Amount,0) then  
         PF_LIMIT - isnull(Arear_M_AD_Calculated_Amount,0)  
       Else 0  End) * 0.0833,0)  
  Where Is_Sett<>2  
    
  update #EMP_SALARY  
  set Arrear_PF_367 = Arrear_PF_Amount - Arrear_PF_833  
   --Case When Round(PF_Limit*0.0833,0) <= round(PF_SALARY_AMOUNT * 0.0833,0) + round(Arrear_Wages * 0.0833,0) Then  
   -- Arrear_PF_Amount - Arrear_PF_833  
   --Else  
   -- round(Arrear_Wages * 0.0367,0)  
   --End  
  --where isnull(Arear_M_AD_Calculated_Amount,0) + Arrear_Wages  <= PF_Limit  
    
    
  --- When give Version to AIA, Comment below porting, Hardik 22/05/2018  
  Update #EMP_SALARY  
  set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit  
   ,PF_833 = @PF_541  
   ,PF_367 = PF_Amount - @PF_541  
   ,Arrear_PF_833 = ROUND(Arrear_PF_833,0) --0  
   ,Arrear_PF_367 = CASE WHEN Arrear_PF_833 <> 0 THEN ROUND(Arrear_PF_367,0) ELSE Arrear_PF_Amount END   
   --,Arrear_PF_367 =Arrear_PF_Amount   
  where PF_SALARY_AMOUNT > PF_Limit  
    
  --- When give Version to AIA, Uncomment below porting and Comment Above Portion, Hardik 22/05/2018  
  /*  
  Update #EMP_SALARY  
  SET PF_Diff_6500 = PF_SALARY_AMOUNT  + Arrear_Wages - PF_Limit  
   ,PF_833 = @PF_541  
   ,PF_367 = PF_Amount - @PF_541  
   ,Arrear_PF_833 = 0  
   ,Arrear_PF_367 = Arrear_PF_Amount  
  where PF_SALARY_AMOUNT + Arrear_Wages > PF_Limit  
  */  
  
   
  Update #EMP_SALARY      
  set PF_833 = 0      
   ,PF_367 = PF_Amount    
   ,PF_LIMIT =0  
   ,Arrear_PF_833 = 0       
   ,Arrear_PF_367 = Arrear_PF_Amount  
  where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age>0    
    
  Update #EMP_SALARY   
    set PF_LIMIT = PF_SALARY_AMOUNT  
   where PF_SALARY_AMOUNT < @PF_LIMIT  
  
  
  Update #EMP_SALARY      
   set PF_833 =   0      
     ,PF_LIMIT =  0  
     --,Arrear_PF_833 = 0    Added By Jimit 08032018 as case at WCl Arrear amount is set to 0 when regular PF amount is 0  
   where PF_833 = 0  
      
   Update #EMP_SALARY   
   set EDLI_Wages = PF_SALARY_AMOUNT  
     
   Update #EMP_SALARY   
   set EDLI_Wages = @PF_LIMIT  
   where PF_SALARY_AMOUNT > @PF_LIMIT   
  
-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013  
   
   
  --Update #EMP_SALARY  
  --set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit  
  -- ,PF_833 = @PF_541  
  -- ,PF_367 = round(PF_Limit * 12/100,0) - @PF_541  
  --where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0  
  
  --Update #EMP_SALARY      
  --set PF_833 = 0      
  -- ,PF_367 = PF_AMOUNT--@PF_NOT_FUll_AMT ---Set Actual PF Amount (Employee arear case)--Ankit 10082015   
  -- ,PF_LIMIT =0     
  --where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0 and PF_Amount > @PF_NOT_FUll_AMT and cmp_full_pf = 0   
  
  Update #EMP_SALARY  --PF 8.33 and 3.67 Calculate On actual PF Amount deduct ----Condition Add By Ankit After discuss with Hardikbhai 10082015  
  set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit  
   ,PF_833 =  round((PF_LIMIT * 8.33)/100 ,0)   
   ,PF_367 = PF_Amount - round((PF_LIMIT * 8.33)/100 ,0)   
  where PF_SALARY_AMOUNT > PF_Limit and cmp_full_pf = 0 and PF_Limit > 0   
    
  Update #EMP_SALARY      
  set PF_833 = 0      
   ,PF_367 = PF_AMOUNT -- round(PF_LIMIT * 12/100,0) --@PF_NOT_FUll_AMT  ---Set Actual PF Amount (Employee arear case)--Ankit 10082015  
   ,PF_LIMIT =0     
  where Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0 and PF_Amount > @PF_NOT_FUll_AMT and cmp_full_pf = 0   
  
    
-------------------------------Company Contribution in PF limit-----------------------------------------Hasmukh 06082013  
  
   --Added by Hardik for Foreign Employee who pay full PF on 17/05/2012  
   Update #EMP_SALARY      
   set   PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)      
  ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0)  
  ,PF_DIFF_6500=0, PF_LIMIT = 0  
   where  Nationality not like 'India%' and Nationality <> '' and Nationality not like 'BHARAT%' ---added By Deepali on 21nov2021  
  
     
   --Update #EMP_SALARY   
   --set PF_Amount = PF_Amount + ISNULL(VPF,0)  
  Update #EMP_SALARY   
  Set Arrear_Wages=0   
  Where Isnull(Arrear_PF_Amount,0) = 0  
  
  -- Added by rohit on 14042016 for Pf trust Employee pf amount and other then pension fund transfer to pf trust account.   
   update #EMP_SALARY  
   set PF_AMOUNT = 0  
   ,PF_367 =0  
   from #EMP_SALARY ES   
   inner join T0080_EMP_MASTER Em on Es.EMP_ID = Em.Emp_ID   
   where isnull(is_PF_Trust,0) = 1  
  -- Ended by rohit on 14042016 for Pf trust Employee pf amount and other then pension fund transfer to pf trust account.  
  
    
  --HNB  
  IF @Format IN (2,3)  
   UPDATE #EMP_SALARY  
   SET --PF_SALARY_AMOUNT = PF_SALARY_AMOUNT + Arrear_Wages,  
    Arrear_Wages=0,  
    PF_AMOUNT = PF_AMOUNT + Arrear_PF_Amount,  
    Arrear_PF_Amount = 0,  
    --PF_833 = PF_833 + Arrear_PF_833,  
    Arrear_PF_833 = 0,  
    PF_367 = (PF_AMOUNT + Arrear_PF_Amount) - PF_833,  
    Arrear_PF_367 = 0--,  
    --PF_LIMIT = PF_LIMIT + Arrear_Wages_833,  
    --Arrear_Wages_833 = 0  
   WHERE Arrear_PF_Amount < 0  
    
    
  --Added By Ramiz on 20/10/2018--( As discussed By Hardik bhai , Admin Charge for PF and Arrear PF will be Same , so taking in single Variable )  
   UPDATE #EMP_SALARY  
   SET PF_Admin_Charge_Empwise = ROUND(((PF_SALARY_AMOUNT * @Admin_Charge_Empwise) / 100),2),  
    Edli_Charge_EmpWise = ROUND(((EDLI_Wages * @Edli_charge) / 100),2),  
    Arrear_PF_Admin_Charge_Empwise = ROUND(((Arrear_Wages * @Admin_Charge_Empwise) / 100),2),  
    Arrear_Edli_Charge_EmpWise = ROUND(((Arrear_Wages_833 * @Edli_charge) / 100),2)  
     
  /*************************************************************************  
       FORMATS STARTS FROM 3 FOR PDF AND 0,1 & 2 ARE FOR EXCEL  
       MAX FORMAT USED :- 10  
  *************************************************************************/  
      
     -- Deepal 14122021 PF And Pension setting   
    update #EMP_SALARY   
    set pf_833 = case when PFsettID = 1 then 0 else pf_833 end ,  
    PF_367 = case when PFsettID = 1 then PF_367 + pf_833 else PF_367 end   
    --ENd Deepal 14122021 PF And Pension setting   
  
 ---Hardik 10/01/2017    
 IF @Format = 3  
  BEGIN  
   Delete #EMP_PF_REPORT From #EMP_PF_REPORT EPR Inner Join #EMP_SALARY ES on EPR.EMP_ID = ES.EMP_ID Where Isnull(ES.Arrear_PF_Amount,0) = 0  
   Delete #EMP_SALARY where Isnull(Arrear_PF_Amount,0) =0  
  END  
 --ELSE   
   
 If @Format=4  ---For PF Statement Consolidated  
  BEGIN  
    SELECT EPF.*  
     ,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) as PF_AMOUNT   
     ,PF_PER,PF_Limit  as PF_Limit--+ Isnull(Es.Arrear_Wages_833,0) as PF_Limit   --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.  
     ,EDLI_Wages  as EDLI_Wages, --+ Isnull(es.Arrear_Wages_833,0) as EDLI_Wages, --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.  
     PF_SALARY_AMOUNT  as PF_SALARY_AMOUNT, --+ Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT,  --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.  
     PF_833  as PF_833--+ Isnull(Arrear_PF_833,0) as PF_833  
     --,PF_367 + Isnull(Arrear_PF_367,0) as PF_367  
     ,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) - ISNULL(PF_833,0) as PF_367  
     --,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,  
     ,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF + Isnull(ES.Arrear_VPF_Amount,0) as VPF,E.Basic_Salary,E.Emp_code,--Hardik 26/12/2017  
     UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name End  ))  as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig
_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO  
     ,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,  
     CAST(  
       (  
        CASE WHEN (@IS_NCP_PRORATA = 1) Then   
         [dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)  
        Else   
         Ms.Absent_Days  
        End  
       ) AS Numeric(18,2)) as Absent_Days,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)  
     ,ES.arrear_days,ES.VPF_PER  
     ,BM.Branch_Name,date_of_join  
     ,E.Alpha_Emp_Code,E.Emp_First_Name  --added jimit 25052015  
     ,dgm.Desig_Dis_No                   --added jimit 25092015  
     ,(EDLI_Wages + Isnull(es.Arrear_Wages_833,0))*@Edli_charge/100 as EDLI  
     ,vs.Vertical_Name,sv.SubVertical_name,Isnull(E.UAN_No,'')as UAN_No,'' as Format_Type  
     ,ES.Gross_Salary as Gross_Salary --added jimit 02072016  
     ,BM.Branch_Address -- Added By Sajid 21122021  
    FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join  
     T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
     LEFT OUTER JOIN  #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH   
       AND EPF.YEAR = ES.YEAR  left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and    
       ES.YEAR =year(MS.Month_St_Date) INNER JOIN   
       ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join   
      ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment  
      where Increment_Effective_date <= @To_Date  
      and Cmp_ID = @Cmp_ID  
      group by emp_ID  ) Qry on  
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
     E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
     T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
     T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Left Outer Join   
     T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.Vertical_ID = vs.Vertical_ID LEFT OUTER JOIN  
     T0050_SubVertical sv WITH (NOLOCK) on Q_I.SubVertical_ID = sv.SubVertical_ID inner join  
     #EMP_DETAIL ED On EPF.EMP_ID = ED.EMP_ID  
    where Pf_Amount  <> 0 --Added By Jimit 25052018  
    order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)     
   END  
   --Added By Mukti(start)16022017  
 ELSE If @Format=7  ---For PF Statement Regular Salary  
  BEGIN  
    SELECT EPF.*       --,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) as PF_AMOUNT   
     --PF_Limit + Isnull(Es.Arrear_Wages_833,0) as PF_Limit,EDLI_Wages + Isnull(es.Arrear_Wages_833,0) as EDLI_Wages,   
     --PF_SALARY_AMOUNT + Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT  
     --,PF_833 + Isnull(Arrear_PF_833,0) as PF_833  
     --,PF_367 + Isnull(Arrear_PF_367,0) as PF_367  
     ,(PF_AMOUNT)as PF_AMOUNT,PF_PER,PF_Limit as PF_Limit,EDLI_Wages as EDLI_Wages,      
     PF_SALARY_AMOUNT as PF_SALARY_AMOUNT,PF_833 as PF_833  
     ,PF_367 as PF_367,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,  
     UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name End  ))  as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig
_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO  
     ,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,  
     CAST(  
       (  
        CASE WHEN (@IS_NCP_PRORATA = 1) Then   
         [dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)  
        Else   
         Ms.Absent_Days  
        End  
       ) AS Numeric(18,2)) as Absent_Days,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)  
     ,ES.arrear_days,ES.VPF_PER  
     ,BM.Branch_Name,date_of_join  
     ,E.Alpha_Emp_Code,E.Emp_First_Name  --added jimit 25052015  
     ,dgm.Desig_Dis_No                   --added jimit 25092015  
     --,(EDLI_Wages + Isnull(es.Arrear_Wages_833,0))*@Edli_charge/100 as EDLI  
     ,(EDLI_Wages + Isnull(es.Arrear_Wages_833,0))*@Edli_charge/100 as EDLI  
     ,vs.Vertical_Name,sv.SubVertical_name,Isnull(E.UAN_No,'')as UAN_No,'Regular Salary' as Format_Type  
     ,(ES.Gross_Salary - (ISNULL(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0))) as Gross_Salary   
     --0 as Gross_Salary--added jimit 02072016  
    FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join  
     T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
     LEFT OUTER JOIN  #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH   
       AND EPF.YEAR = ES.YEAR  left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and    
       ES.YEAR =year(MS.Month_St_Date) INNER JOIN   
       ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join   
      ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment  
      where Increment_Effective_date <= @To_Date  
      and Cmp_ID = @Cmp_ID  
      group by emp_ID  ) Qry on  
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
     E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
     T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
     T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Left Outer Join   
     T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.Vertical_ID = vs.Vertical_ID LEFT OUTER JOIN  
     T0050_SubVertical sv WITH (NOLOCK) on Q_I.SubVertical_ID = sv.SubVertical_ID inner join  
     #EMP_DETAIL ED On EPF.EMP_ID = ED.EMP_ID      
    order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)     
  END  
  ELSE If @Format=8  ---For PF Statement Arrear Salary  
   BEGIN  
    SELECT EPF.*  
     --,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) as PF_AMOUNT   
     ,Isnull(Arrear_PF_Amount,0) as PF_AMOUNT   
     ,PF_PER,  
     (case when Emp_Age >= @PF_PEnsion_Age and @PF_PEnsion_Age > 0 then 0 else Isnull(Es.Arrear_Wages_833,0) end) as PF_Limit  
     --Isnull(Es.Arrear_Wages_833,0) as PF_Limit  
     ,Isnull(es.Arrear_Wages_833,0) as EDLI_Wages  
     --,PF_SALARY_AMOUNT + Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT  
     ,Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT  
     --,PF_833 + Isnull(Arrear_PF_833,0) as PF_833  
     ,Isnull(Arrear_PF_833,0) as PF_833  
     --,PF_367 + Isnull(Arrear_PF_367,0) as PF_367  
     ,Isnull(Arrear_PF_367,0) as PF_367  
     --,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,  
     ,PF_Diff_6500,EMP_SECOND_NAME,Isnull(ES.Arrear_VPF_Amount,0) As VPF,E.Basic_Salary,E.Emp_code,--Hardik 26/12/2017  
     UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name End  ))  as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig
_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO  
     ,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,  
     CAST(  
       (  
        CASE WHEN (@IS_NCP_PRORATA = 1) Then   
         [dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)  
        Else   
         Ms.Absent_Days  
        End  
       ) AS Numeric(18,2)) as Absent_Days,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)  
     ,ES.arrear_days,ES.VPF_PER  
     ,BM.Branch_Name,date_of_join  
     ,E.Alpha_Emp_Code,E.Emp_First_Name  --added jimit 25052015  
     ,dgm.Desig_Dis_No                   --added jimit 25092015  
     ,(EDLI_Wages + Isnull(es.Arrear_Wages_833,0))*@Edli_charge/100 as EDLI  
     ,vs.Vertical_Name,sv.SubVertical_name,Isnull(E.UAN_No,'')as UAN_No,'Arrear Salary' as Format_Type  
     --,ES.Gross_Salary --added jimit 02072016  
     ,0 as Gross_Salary --added jimit 07042018 for wonder cement  
        
    FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join  
     T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
     LEFT OUTER JOIN  #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR    
     left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and    
       ES.YEAR =year(MS.Month_St_Date) INNER JOIN   
       ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join   
      ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment  
      where Increment_Effective_date <= @To_Date  
      and Cmp_ID = @Cmp_ID  
      group by emp_ID  ) Qry on  
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
     E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
     T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
     T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Left Outer Join   
     T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.Vertical_ID = vs.Vertical_ID LEFT OUTER JOIN  
     T0050_SubVertical sv WITH (NOLOCK) on Q_I.SubVertical_ID = sv.SubVertical_ID inner join  
     #EMP_DETAIL ED On EPF.EMP_ID = ED.EMP_ID  
    where  Isnull(ES.Arrear_PF_Amount,0)<> 0  --Mukti(16022017)  
    order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)     
   END  
   --Added By Mukti(end)16022017  
  Else if @Format=5 ---For PF Challan  
   begin  
    --------------------------------------------- PF CHALLAN CALCULATION   
     --declare @EMP_SALARY_Challan table --commented By Mukti(17022017)start     
     -- (      
             
     --  Cmp_ID     numeric,      
     --  Total_Subscriber   numeric ,      
     --  Total_Wages_Due    numeric(18,2),      
     --  Total_PF_Diff_Limit   numeric(18,2),      
     --  AC1_1      numeric(18,2) default 0,      
     --  AC1_2      numeric(18,2) default 0,      
     --  AC2_3      numeric(18,2) default 0,      
     --  AC10_1      numeric(18,2) default 0,      
     --  AC21_1      numeric(18,2) default 0,      
     --  AC22_3      numeric(18,2) default 0,      
     --  AC22_4      numeric(18,2) default 0,      
     --  For_Date     datetime,  
     --  Payment_Date datetime,      
     --  PF_Limit     numeric,      
     --  Total_Family_Pension_Subscriber  numeric(18, 0),      
     --  Total_Family_Pension_Wages_Amount numeric(18, 0),      
     --  Total_EDLI_Subscriber    numeric(18, 0),      
     --  Total_EDLI_Wages_Amount    numeric(18, 0)  ,  
     --  VPF  numeric(18,0)    
            
     -- )      
          
     -- declare @Total_Wages_Due as numeric(18,2)      
     -- declare @Total_Subscriber as numeric      
     -- Declare @Total_PF_Diff_Limit as numeric      
     -- Declare @dblAC1_1 as numeric(22,2)      
     -- Declare @dblAC1_2 as numeric(22,2)      
     -- Declare @dblAC2_3 as numeric(22,2)      
     -- Declare @dblAC10_1 as numeric(22,2)      
     -- Declare @dblAC21_1 as numeric(22,2)      
     -- Declare @dblAC22_3 as numeric(22,2)      
     -- Declare @dblAC22_4 numeric       
     -- Declare @dbl833 as numeric (22,2)      
     -- Declare @dbl367 as numeric (22,2)      
     -- declare @Total_PF_Amount as numeric       
     -- DEclare @MONTH numeric        
     -- Declare @Year numeric       
     -- Declare @Total_Family_Pension_Subscriber  numeric(18, 0)      
     -- Declare @Total_Family_Pension_Wages_Amount  numeric(18, 0)      
     -- Declare @Total_EDLI_Subscriber     numeric(18, 0)      
     -- Declare @Total_EDLI_Wages_Amount    numeric(18, 0)    
     -- Declare @VPF as numeric(18,0)   
     -- Declare @AC_2_3 numeric(10,2)  
     -- Declare @AC_21_1 numeric(10,2)      
     -- Declare @AC_22_3 numeric(10,4)      
     -- Declare @AC_22_4 numeric(10,4)--commented By Mukti(17022017)end  
      
      SELECT @Total_NonPF_Subcriber = count(MS.Emp_ID) , @Total_NonPF_Wages = Sum(isnull(ms.Gross_Salary,0))   
      FROM #EMP_CONS EC inner join   
      T0200_MONTHLY_SALARY MS ON Ec.Emp_ID = MS.Emp_id  
      inner join T0210_MONTHLY_AD_DETAIL MD   
      ON ms.Sal_Tran_ID = MD.Sal_Tran_ID and ms.Emp_ID = md.Emp_ID  
      and Month_St_Date = @FROM_DATE and Month_End_Date = @To_Date  
      and AD_ID in (68)  
      and md.M_AD_Amount = 0    
  
      select Top 1 @AC_2_3 =ACC_2_3,      
       @AC_22_3 =ACC_22_3,@PF_Limit = ACC_10_1_Max_Limit,      
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
        
     update E  
     SET    E.PF_SALARY_AMOUNT = E.PF_SALARY_AMOUNT  --+ case when sg.basic_salary < @PF_Limit then  Isnull(Q.M_AREAR_AMOUNT1,0) else 0 end   
      ,E.PF_LIMIT =  case  when E.PF_LIMIT + Isnull(E.Arrear_Wages_833,0) < @PF_LIMIT  then E.PF_LIMIT + Isnull(E.Arrear_Wages_833,0)  else @PF_LIMIT end  
      ,E.EDLI_Wages =  case  when E.EDLI_Wages + Isnull(E.Arrear_Wages_833,0) < @PF_LIMIT  then E.EDLI_Wages + Isnull(E.Arrear_Wages_833,0)  else @PF_LIMIT end  
      --E.Arrear_Wages = E.Arrear_Wages + case when sg.basic_salary < @PF_Limit then  Isnull(Q.M_AREAR_AMOUNT1,0) else 0 end,  
      --E.Arrear_Wages_833 = E.Arrear_Wages_833 + case when sg.basic_salary < @PF_Limit then  Isnull(Q.M_AREAR_AMOUNT1,0) else 0 end  
     from  #EMP_SALary E  
      LEFT OUTER JOIN  
       (  
        SELECT MAD1.EMP_ID,ISNULL(SUM(M_AREAR_AMOUNT),0) M_AREAR_AMOUNT1,MONTH(MAD1.To_DATE) as monthArrear,Year(MAD1.To_DATE) as YearArrear  
          FROM T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN  
            T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN  
            #EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID  
          WHERE MONTH(MAD1.To_DATE) = MONTH(@TO_DATE) And YEAR(MAD1.To_DATE) = YEAR(@To_Date)  
            AND ad_not_effect_salary = 0 and AD_FLAG = 'I' and M_AREAR_AMOUNT <> 0  
            and AM.ad_id in (SELECT  EAM.AD_ID    
                FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)    
                  inner join T0050_AD_MASTER AM WITH (NOLOCK) on EAM.Effect_AD_ID = AM.AD_ID and EAM.CMP_ID = AM.CMP_ID  
                WHERE AM.AD_DEF_ID  = @PF_DEF_ID AND Am.Cmp_ID  = @Cmp_ID  
                )  
          GROUP BY MAD1.Emp_ID,Mad1.To_date         
       )Q On Q.EMP_Id = E.EMP_ID  
       Inner Join T0200_MONTHLY_SALARY SG WITH (NOLOCK) On Sg.Emp_ID = Q.Emp_ID and month(Sg.Month_End_Date) = monthArrear and YEAR(Sg.Month_End_Date)= YearArrear  
  
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
           
     select @Total_Subscriber =  count(1), @Total_Wages_Due = isnull(sum(PF_Salary_Amount  ),0) -- + isnull(sum(Arrear_Wages ),0)      
      ,@Total_PF_Amount = isnull(sum(PF_Amount),0) + isnull(sum(Arrear_PF_Amount),0)        
     from #EMP_SALARY      
     where  [month] = @month and [year] = @year   
       
     select  @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500),0) ,  
     @dbl833 = round(sum(PF_833),0),   --+ sum(Isnull(Arrear_PF_833,0)),   
     --@dbl367 = round(sum(PF_367),0 )+ sum(Isnull(Arrear_PF_367,0)),  
     @dbl367 = round(sum(PF_AMOUNT),0 )+ sum(Isnull(Arrear_PF_Amount,0)) - sum(ISNULL(PF_833,0)),       
     @VPF =ISNULL( Sum(VPF),0) + Isnull(Sum(Arrear_VPF_Amount),0) --Added By jimit 05012018  
                    from #EMP_SALARY  
     where [month] = @month and [year] = @year and (PF_Amount > 0 or Arrear_PF_Amount > 0)  --change By Jimit 09032018  
       
     SELECT @Total_Family_Pension_Subscriber = count(emp_ID ) from #EMP_SALARY      
     Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0   
       
   --select PF_833,* from #EMP_SALARY where EMP_ID = 1741  
     
       
     --Ankit 09052016  
      SELECT @Total_Family_Pension_Wages_Amount =  sum(PF_LIMIT) --+  Isnull(sum(Arrear_Wages_833),0)   
     from #EMP_SALARY      
     Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  -- and Arear_Month_Salary_exists = 0  
               
     SELECT @Total_EDLI_Wages_Amount = sum(EDLI_Wages) --+  Isnull(sum(Arrear_Wages_833),0)  
     from #EMP_SALARY      
       -- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0  
     --Ankit 09052016  
       
     set @Total_EDLI_Subscriber = @Total_Subscriber       
     --set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit   
     set @dbl833 = isnull(@dbl833,0)       
     set @Total_Wages_Due = @Total_Wages_Due       
     set @Total_PF_Amount = @Total_PF_Amount       
     set @dblAC1_1 = @dbl367   
     set @dblAC10_1 = @dbl833      
     set @dblAC1_2 = @Total_PF_Amount  + @VPF    
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
          
       -- DEclare @Payment_Date Datetime   
       --Added By Falak on 19-MAY-2011  
            
       select @Payment_Date = Payment_Date  from T0220_PF_CHALLAN WITH (NOLOCK) where [Month] = Month(@TEMP_DATE) and [YEAR] = YEAR(@Temp_Date)  
              
      if @Total_Subscriber > 0       
     begin      
       insert into @EMP_SALARY_Challan ( Cmp_ID ,Total_NonPF_Subscriber,Total_NonPF_Wages , Total_Subscriber , Total_Wages_Due ,Total_PF_Diff_Limit ,      
       AC1_1 , AC1_2, AC2_3 , AC10_1 , AC21_1 ,AC22_3 ,For_Date,Payment_Date,PF_Limit,AC22_4,      
       Total_Family_Pension_Subscriber,Total_Family_Pension_Wages_Amount,Total_EDLI_Subscriber,Total_EDLI_Wages_Amount,VPF)      
       values ( @Cmp_ID ,@Total_NonPF_Subcriber,@Total_NonPF_Wages, @Total_Subscriber , @Total_Wages_Due ,@Total_PF_Diff_Limit ,      
        isnull(@dblAC1_1,0) , @dblAC1_2, @dblAC2_3 , @dblAC10_1 , @dblAC21_1 ,@dblAC22_3,@Temp_DAte,@Payment_Date ,@PF_Limit,@dblAC22_4,      
       @Total_Family_Pension_Subscriber,@Total_Family_Pension_Wages_Amount,@Total_EDLI_Subscriber,@Total_EDLI_Wages_Amount,@VPF)      
     end                   
          
     SET @TEMP_DATE = DATEADD(M,1,@TEMP_DATE)      
      END   
     -- print 'm'  
     select * from @EMP_SALARY_Challan ES inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ES.Cmp_ID=CM.Cmp_Id  
   End  
 Else if @Format=9 ---For PF Challan(Regular Salary)  
  BEGIN  
    --------------------------------------------- PF CHALLAN CALCULATION   
      select Top 1 @AC_2_3 =ACC_2_3,      
       @AC_22_3 =ACC_22_3,@PF_Limit = ACC_10_1_Max_Limit,      
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
     from #EMP_SALARY      
     where  [month] = @month and [year] = @year   
       
     select  @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500),0) ,  
     @dbl833 = round(sum(PF_833),0),   
     @dbl367 = round(sum(PF_367),0),       
     @VPF =ISNULL(Sum(VPF),0)  
     from #EMP_SALARY      
     where [month] = @month and [year] = @year and PF_Amount > 0   
       
     SELECT @Total_Family_Pension_Subscriber = count(emp_ID ) from #EMP_SALARY      
     Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0   
       
     --Ankit 09052016  
     SELECT --@Total_Family_Pension_Wages_Amount =  sum(PF_LIMIT)+ + Isnull(sum(Arrear_Wages_833),0)   
     @Total_Family_Pension_Wages_Amount =  sum(PF_LIMIT)  
     from #EMP_SALARY      
     Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0  
          
        
     SELECT --@Total_EDLI_Wages_Amount = sum(EDLI_Wages)+ + Isnull(sum(Arrear_Wages_833),0)  
     @Total_EDLI_Wages_Amount = sum(EDLI_Wages)  
     from #EMP_SALARY      
       -- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0  
     --Ankit 09052016         
          
     --   print @AC_21_1  
     --   print @Total_EDLI_Wages_Amount   
     --print @Total_PF_Amount                 
     --print @VPF  
       
     set @Total_EDLI_Subscriber = @Total_Subscriber       
     --set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit   
     set @dbl833 = isnull(@dbl833,0)       
     set @Total_Wages_Due = @Total_Wages_Due       
     set @Total_PF_Amount = @Total_PF_Amount       
     set @dblAC1_1 = @dbl367   
     set @dblAC10_1 = @dbl833      
     set @dblAC1_2 = @Total_PF_Amount  + @VPF    
     set @dblAC2_3  = round( @Total_Wages_Due * @AC_2_3/100,0 )      
     set @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1/100 ,0)      
        
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
          
       -- DEclare @Payment_Date Datetime   
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
   End    
 Else if @Format=10 ---For PF Challan(Arrear Salary)  
  BEGIN  
    --------------------------------------------- PF CHALLAN CALCULATION   
      select Top 1 @AC_2_3 =ACC_2_3,      
       @AC_22_3 =ACC_22_3,@PF_Limit = ACC_10_1_Max_Limit,      
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
           
     select @Total_Subscriber =  count(*), @Total_Wages_Due = isnull(sum(Arrear_Wages),0)   
      ,@Total_PF_Amount = isnull(sum(Arrear_PF_Amount),0)      
     from #EMP_SALARY      
     where  [month] = @month and [year] = @year and Arrear_PF_Amount>0  
       
     select  @Total_PF_Diff_Limit = isnull(sum(PF_Diff_6500),0) ,  
     --@dbl833 = round(sum(Isnull(Arrear_PF_833,0))),   
     --@dbl367 = sum(Isnull(Arrear_PF_367,0)),  
     @dbl833 = round(sum(Arrear_PF_833),0),   
     @dbl367 = round(sum(Arrear_PF_367),0),   
     @VPF =ISNULL( Sum(Arrear_VPF_Amount),0)    --change By Jimit 08022018  
     from #EMP_SALARY      
     where [month] = @month and [year] = @year and (PF_Amount > 0 or Arrear_PF_Amount > 0) --change By Jimit 09032018  
       
     SELECT @Total_Family_Pension_Subscriber = count(emp_ID ) from #EMP_SALARY      
     Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0 and Arrear_PF_Amount>0   
       
     --Ankit 09052016  
     SELECT @Total_Family_Pension_Wages_Amount =Isnull(sum(Arrear_Wages_833),0)   
     from #EMP_SALARY      
     Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0  
               
     SELECT @Total_EDLI_Wages_Amount =Isnull(sum(Arrear_Wages_833),0)  
     from #EMP_SALARY      
       -- Where isnull(Emp_Age,0) < @PF_PEnsion_Age and @PF_PEnsion_Age >0  --  and Arear_Month_Salary_exists = 0  
     --Ankit 09052016         
          
     --   print @AC_21_1  
     --   print @Total_EDLI_Wages_Amount   
     --print @Total_PF_Amount                 
     --print @VPF  
       
     set @Total_EDLI_Subscriber = @Total_Subscriber       
     --set @Total_EDLI_Wages_Amount = @Total_Wages_Due - @Total_PF_Diff_Limit   --cmd ankit   
     set @dbl833 = isnull(@dbl833,0)       
     set @Total_Wages_Due = @Total_Wages_Due       
     set @Total_PF_Amount = @Total_PF_Amount       
     set @dblAC1_1 = @dbl367   
     set @dblAC10_1 = @dbl833      
     set @dblAC1_2 = @Total_PF_Amount  + @VPF    
     set @dblAC2_3  = round( @Total_Wages_Due * @AC_2_3/100,0 )      
     set @dblAC21_1 = round(@Total_EDLI_Wages_Amount * @AC_21_1/100 ,0)      
        
     --Changed by Hardik 04/03/2015 as PF rule changed Minimum Rs. 5 to 500  
     --If @dblAC2_3 < 500     (Commented By Jimit 07042018 as Rule change rule that if Amount less than 500 then set actual Amount)  
      --Set @dblAC2_3 = 500          
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
   End    
 Else if @Format = 6  -- For Left Employee text file generation  
  BEGIN  
   Select month(@To_Date) as Month,year(@To_Date) as Year,   
   Isnull(E.UAN_No,'') + '#~#' + isnull(Convert(varchar(10),LE.Left_Date,103),'')  + '#~#' + Isnull(LE.LeftReasonValue,0) As Text_String,  
   Grd_Name,Type_Name,dept_Name,Desig_Name,Cmp_Name,Cmp_Address,Alpha_Emp_Code,Desig_Dis_No,Emp_First_Name  
   FROM T0080_EMP_MASTER E WITH (NOLOCK) Inner join  
   T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
      INNER JOIN   
     ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type FROM T0095_Increment I WITH (NOLOCK) inner join   
      ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment  
      where Increment_Effective_date <= @To_Date  
      and Cmp_ID = @Cmp_ID  
      group by emp_ID  ) Qry on  
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
   E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
   T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
   T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
   T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
   T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
   T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Inner Join  
   #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID  
   Where (E.Emp_Left = 'Y' or Emp_Left_Date is not null) And LE.Left_Date Between @From_Date AND @To_Date  
   --Where PF_Amount > 0  
   order by RIGHT(REPLICATE(N' ', 500) + E.Alpha_Emp_Code, 500)  
   Return   
  End  
 Else if @Format = 11 -- For consolidated Report ( Regual + Arrear Amt) Without Limit --Added by Jaina 16-09-2020  
  Begin  
    SELECT EPF.*  
     ,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) as PF_AMOUNT   
     ,PF_PER,PF_Limit  as PF_Limit--+ Isnull(Es.Arrear_Wages_833,0) as PF_Limit   --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.  
     ,EDLI_Wages  as EDLI_Wages, --+ Isnull(es.Arrear_Wages_833,0) as EDLI_Wages, --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.  
     PF_SALARY_AMOUNT  as PF_SALARY_AMOUNT, --+ Isnull(ES.Arrear_Wages,0) as PF_SALARY_AMOUNT,  --CHANGD By Jimit 11092019 for not addig again Arrear Wage it has been added already while inserting pf salary amount.  
     PF_833 + Arrear_PF_833  as PF_833--+ Isnull(Arrear_PF_833,0) as PF_833  
     --,PF_367 + Isnull(Arrear_PF_367,0) as PF_367  
     --,(PF_AMOUNT)+ Isnull(Arrear_PF_Amount,0) - ISNULL(PF_833,0) as PF_367  
     ,PF_367 + Arrear_PF_367 As PF_367  
     --,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,  
     ,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF + Isnull(ES.Arrear_VPF_Amount,0) as VPF,E.Basic_Salary,E.Emp_code,--Hardik 26/12/2017  
     UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name End  ))  as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desi
g_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO  
     ,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,  
     CAST(  
       (  
        CASE WHEN (@IS_NCP_PRORATA = 1) Then   
         [dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)  
        Else   
         Ms.Absent_Days  
        End  
       ) AS Numeric(18,2)) as Absent_Days,ES.Sal_Cal_Day --Modified by Nimesh 2015-06-22 (Absent_days was not displaying decimal values)  
     ,ES.arrear_days,ES.VPF_PER  
     ,BM.Branch_Name,date_of_join  
     ,E.Alpha_Emp_Code,E.Emp_First_Name  --added jimit 25052015  
     ,dgm.Desig_Dis_No                   --added jimit 25092015  
     ,(EDLI_Wages + Isnull(es.Arrear_Wages_833,0))*@Edli_charge/100 as EDLI  
     ,vs.Vertical_Name,sv.SubVertical_name,Isnull(E.UAN_No,'')as UAN_No,'' as Format_Type  
     ,ES.Gross_Salary as Gross_Salary --added jimit 02072016  
    FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join  
     T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
     LEFT OUTER JOIN  #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH   
       AND EPF.YEAR = ES.YEAR  left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and    
       ES.YEAR =year(MS.Month_St_Date) INNER JOIN   
       ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join   
      ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment  
      where Increment_Effective_date <= @To_Date  
      and Cmp_ID = @Cmp_ID  
      group by emp_ID  ) Qry on  
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
     E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
     T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
     T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Left Outer Join   
     T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.Vertical_ID = vs.Vertical_ID LEFT OUTER JOIN  
     T0050_SubVertical sv WITH (NOLOCK) on Q_I.SubVertical_ID = sv.SubVertical_ID inner join  
     #EMP_DETAIL ED On EPF.EMP_ID = ED.EMP_ID  
    where Pf_Amount  <> 0 --Added By Jimit 25052018  
    order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)     
   END  
 ELSE  
  BEGIN  
   --Added by chetan 031017 for show ECR file in individual column  
   IF @Export_Type = '4'  
    BEGIN  
     SELECT ISNULL(E.UAN_No,'') AS UAN_NO ,UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  CASE WHEN ISNULL(Emp_Second_Name,'')<>'' THEN + ' ' + Emp_Second_Name ELSE '' END + CASE WHEN ISNULL(Emp_Last_Name,'')<>'' THEN + ' ' + Emp_Last_Name ELSE '' END  )
) AS EMP_FULL_NAME  
       , CAST(CAST(ROUND(ISNULL(Ms.Gross_Salary,0) - (ISNULL(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0)),0) AS NUMERIC) AS VARCHAR(10))   
       AS GROSS_WAGES  
       , CAST(PF_SALARY_AMOUNT AS VARCHAR(10)) AS EPF_WAGES, CAST(PF_LIMIT AS VARCHAR(10)) EPS_WAGES  
       , CAST(EDLI_Wages AS VARCHAR(10)) AS EDLI_WAGES, CAST(PF_AMOUNT + ISNULL(VPF,0) AS VARCHAR(10)) AS EPF_CONTRI_REMITTED  
       , CAST(PF_833 AS VARCHAR(10)) AS EPS_CONTRI_REMITTED, CAST(PF_367 AS VARCHAR(10)) AS  EPF_EPS_DIFF_REMITTED  
       , CASE WHEN @IS_NCP_PRORATA = 1 THEN CAST([dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days) AS VARCHAR(2)) ELSE Case When Ms.Absent_Days < 
0 Then '0' Else Cast(Ms.Absent_Days As Varchar(4)) End END AS NCP_DAYS  
       , CAST(0 AS VARCHAR(10)) As REFUND_OF_ADVANCES   
     FROM #EMP_PF_REPORT EPF   
       INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID   
       LEFT OUTER JOIN T0100_left_emp LE WITH (NOLOCK) ON E.Emp_ID =Le.Emp_ID   
       LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR    
       LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON ES.EMP_ID=MS.Emp_ID AND ES.MONTH=MONTH(MS.Month_St_Date) AND ES.YEAR =YEAR(MS.Month_St_Date)   
       INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON E.Emp_ID = I.EMP_ID   
       INNER JOIN #Emp_Cons EC ON I.Increment_ID = EC.Increment_ID AND I.Emp_ID = EC.Emp_ID    
       INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_Id = gm.Grd_ID   
       INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.BRANCH_ID = BM.BRANCH_ID   
       LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID   
       LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.DESIG_ID = DGM.DESIG_ID   
       LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) ON I.Type_ID = Tm.Type_Id    
       INNER JOIN T0010_company_Master cm WITH (NOLOCK) ON e.cmp_ID = cm.cmp_Id   
       INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID   
       LEFT OUTER JOIN T0040_Vertical_Segment vs WITH (NOLOCK) ON I.Vertical_ID = vs.Vertical_ID   
       LEFT OUTER JOIN T0050_SubVertical sv WITH (NOLOCK) ON I.SubVertical_ID = sv.SubVertical_ID  
       ORDER BY RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)  
    END  
   ELSE IF (@Format = 0 AND @Export_Type = 'CUSTOMIZED_EXCEL') -- CODE ADDED BY RAMIZ ON 19/10/2018  
    BEGIN  
     --Comment by deepal   
       /*********** GENERAL PORTION OF EMPLOYEE DETAILS ************************/  
     -- SELECT E.ALPHA_EMP_CODE , ISNULL(EMPNAME_ALIAS_PF,Emp_Full_Name) as EMP_FULL_NAME ,BM.BRANCH_NAME as BRANCH, DM.Dept_Name AS DEPARTMENT ,DGM.Desig_Name AS DESIGNATION , GM.Grd_Name AS GRADE  
     --  ,CCM.Center_Name AS COST_CENTER , CCM.CENTER_CODE , CTM.Cat_Name AS CATEGORY , VS.Vertical_Name AS VERTICAL ,SV.SubVertical_name AS SUBVERTICAL , BS.Segment_Name AS BUSINESS_SEGMENT   
     --  ,CONVERT(VARCHAR(20) , E.DATE_OF_JOIN , 103) AS DATE_OF_JOIN   
     --  ,E.UAN_NO  
     --  ,EPF.PF_NO  
     --  /*********** NORMAL PF PORTION STARTS HERE ************************/  
     --  ,ES.PF_SALARY_AMOUNT as PF_WAGES , ES.PF_LIMIT AS PENSION_WAGES, EDLI_Wages as EDLI_WAGES  
     --  ,PF_AMOUNT as PF_AMOUNT , ES.VPF AS VOLUNTARY_PF   
     --  ,(ES.PF_AMOUNT + ES.VPF) AS TOTAL_EMPLOYEE_CONTRIBUTION  
     --  ,ES.PF_367  as Employee_Pf_367--as '+ @dynColChg +'  
     --  ,ES.PF_833 as PENSION_FUND_833, (ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYER_CONTRIBUTION  
     --  ,(ES.PF_AMOUNT + ES.VPF + ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYEE_AND_EMPLOYER_CONTRIBUTION  
     --  ,ES.PF_Admin_Charge_Empwise AS PF_ADMIN_CHARGE_02 ,ES.Edli_Charge_EmpWise AS EDLI_CHARGE_21 ,ROUND((ES.PF_Admin_Charge_Empwise + ES.Edli_Charge_EmpWise),0) as TOTAL_FUND_PF , E.BASIC_SALARY  
     --  ,(ES.Gross_Salary - (ISNULL(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0))) as Gross_Salary  
     --  ,CAST((  
     --    CASE WHEN (@IS_NCP_PRORATA = 1) Then   
     --     [dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days)  
     --    Else   
     --     Case When Ms.Absent_Days < 0 Then 0 Else Ms.Absent_Days End  
     --    End  
     --   ) AS Numeric(18,2)) as NCP_DAYS  
         
     --  /*********** ARREAR PORTION STARTS HERE ************************/  
     --  ,ES.ARREAR_DAYS  
     --  ,ISNULL(ES.Arrear_Wages,0) AS PF_ARREARS_WAGES  
     --  ,ISNULL(ES.Arrear_Wages_833,0) AS PENSION_ARREARSWAGES  
     --  ,ISNULL(ES.Arrear_Wages_833,0) AS EDLI_ARREARS_WAGES  
     --  ,ISNULL(ES.Arrear_PF_Amount,0) AS PF_ARREARS  
     --  ,ISNULL(ES.Arrear_VPF_Amount,0) AS VOLUNTARY_PF_ARREARS  
     --  ,(ISNULL(ES.Arrear_PF_Amount,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_EMP_CONTRIBUTION_ARREARS  
     --  ,ISNULL(ES.Arrear_PF_367,0) AS EMPLOYER_PF_ARREARS  
     --  ,ISNULL(ES.Arrear_PF_833,0) AS PENSION_FUND_ARREARS  
     --  ,(ISNULL(ES.Arrear_PF_367,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_EMPLOYER_CONTRIBUTION_ARREARS  
     --  ,ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS ADMIN_CHARGE_02_ARREARS   
     --  ,ISNULL(Arrear_Edli_Charge_EmpWise,0) AS EDLI_CHARGE_21_ARREARS  
     --  ,ROUND((Arrear_PF_Admin_Charge_Empwise + Arrear_Edli_Charge_EmpWise),0) AS TOTAL_FUNDS_ARREARS  
         
     --  /*********** TOTAL OF PF & ARREARS STARTS HERE ************************/  
     --  ,(ISNULL(ES.PF_AMOUNT,0) + ISNULL(ES.Arrear_PF_Amount,0)) AS TOTAL_PF       --  ,(ISNULL(ES.VPF,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_VOLUNTARY_PF  
     --  ,(ISNULL(ES.PF_367,0) + ISNULL(ES.Arrear_PF_367,0)) AS TOTAL_EMPLOYER_PF  
     --  ,(ISNULL(ES.PF_833,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_PENSION_FUND  
     --  ,(ES.PF_AMOUNT + ISNULL(ES.Arrear_PF_Amount,0) + ES.VPF + ISNULL(ES.Arrear_VPF_Amount,0) + ES.PF_367 + ISNULL(ES.Arrear_PF_367,0) + ES.PF_833 + ISNULL(ES.Arrear_PF_833,0) ) AS CONTRIBUTION_TOTAL  
     --  ,ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS TOTAL_ADMIN_CHARGE_02  
     --  ,ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0) AS TOTAL_EDLI_CHARGE_21  
     --  ,ROUND(ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) + ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0),0) AS TOTAL_FUNDS  
     --FROM #EMP_PF_REPORT EPF   
     -- INNER JOIN  T0080_EMP_MASTER E  ON EPF.EMP_ID = E.EMP_ID  
     -- INNER JOIN  #EMP_CONS EC ON EC.Emp_ID = EPF.EMP_ID  
     -- INNER JOIN  #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID  
     -- INNER JOIN  T0095_INCREMENT INC ON INC.INCREMENT_ID = EC.INCREMENT_ID AND INC.EMP_ID = EC.EMP_ID  
     -- INNER JOIN  T0040_GRADE_MASTER GM ON INC.GRD_ID = GM.GRD_ID   
     -- INNER JOIN  T0030_BRANCH_MASTER BM ON INC.BRANCH_ID = BM.BRANCH_ID  
     -- INNER JOIN  T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID  
     -- INNER JOIN  T0040_DESIGNATION_MASTER DGM ON INC.DESIG_ID = DGM.DESIG_ID  
     -- LEFT OUTER JOIN T0100_LEFT_EMP LE ON E.EMP_ID = LE.EMP_ID   
     -- LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR  
     -- LEFT OUTER JOIN T0200_MONTHLY_SALARY MS on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and  ES.YEAR =year(MS.Month_St_Date)  
     -- LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON INC.DEPT_ID = DM.DEPT_ID   
     -- LEFT OUTER JOIN T0040_TYPE_MASTER TM ON INC.TYPE_ID = TM.TYPE_ID  
     -- LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS ON INC.VERTICAL_ID = VS.VERTICAL_ID  
     -- LEFT OUTER JOIN T0050_SUBVERTICAL SV ON INC.SUBVERTICAL_ID = SV.SUBVERTICAL_ID  
     -- LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM ON INC.Center_ID = CCM.Center_ID  
     -- LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM ON INC.Cat_ID = CTM.Cat_ID  
     -- LEFT OUTER JOIN T0040_Business_Segment BS ON INC.Segment_ID = BS.Segment_ID  
      
      DECLARE @query as varchar(max)  
      DECLARE @query1 as varchar(max)  
      DECLARE @dynColChg as varchar(50)  
      IF month(@To_Date) in (5,6,7) and year(@To_Date) = 2020  
      BEGIN   
        set @dynColChg = 'EMPLOYER_PF_167'  
      END   
      ELSE  
      BEGIN  
       set @dynColChg = 'EMPLOYER_PF_367'  
      END  
        
      set @query = 'SELECT E.ALPHA_EMP_CODE , ISNULL(EMPNAME_ALIAS_PF,Emp_Full_Name) as EMP_FULL_NAME ,BM.BRANCH_NAME as BRANCH  
         , DM.Dept_Name AS DEPARTMENT ,DGM.Desig_Name AS DESIGNATION , GM.Grd_Name AS GRADE ,CCM.Center_Name AS COST_CENTER , CCM.CENTER_CODE   
         , CTM.Cat_Name AS CATEGORY ,VS.Vertical_Name AS VERTICAL ,SV.SubVertical_name AS SUBVERTICAL , BS.Segment_Name AS BUSINESS_SEGMENT   
         ,CONVERT(VARCHAR(20),E.DATE_OF_JOIN,103) AS DATE_OF_JOIN ,E.UAN_NO,EPF.PF_NO  
         /* NORMAL PF PORTION STARTS HERE */  
         ,ES.PF_SALARY_AMOUNT as PF_WAGES , ES.PF_LIMIT AS PENSION_WAGES, EDLI_Wages as EDLI_WAGES  
         ,PF_AMOUNT as PF_AMOUNT , ES.VPF AS VOLUNTARY_PF ,(ES.PF_AMOUNT + ES.VPF) AS TOTAL_EMPLOYEE_CONTRIBUTION  
         ,ES.PF_367 as '+ @dynColChg +',ES.PF_833 as PENSION_FUND_833, (ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYER_CONTRIBUTION  
         ,(ES.PF_AMOUNT + ES.VPF + ES.PF_367 + ES.PF_833) AS TOTAL_EMPLOYEE_AND_EMPLOYER_CONTRIBUTION  
         ,ES.PF_Admin_Charge_Empwise AS PF_ADMIN_CHARGE_02 ,ES.Edli_Charge_EmpWise AS EDLI_CHARGE_21 ,ROUND((ES.PF_Admin_Charge_Empwise + ES.Edli_Charge_EmpWise),0) as TOTAL_FUND_PF , E.BASIC_SALARY  
         ,(ES.Gross_Salary - (ISNULL(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0))) as Gross_Salary  
         ,CAST((CASE WHEN '+ convert(varchar(100),@IS_NCP_PRORATA)+' = 1  Then [dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days ,'+convert(varchar(100),@PF_LIMIT)+',ms.Absent_Days,Wages_Type,Week
off_Days)Else Case When Ms.Absent_Days < 0 Then 0 Else Ms.Absent_Days End End) AS Numeric(18,2)) as NCP_DAYS  
         /* ARREAR PORTION STARTS HERE */  
         ,ES.ARREAR_DAYS,ISNULL(ES.Arrear_Wages,0) AS PF_ARREARS_WAGES  
         ,ISNULL(ES.Arrear_Wages_833,0) AS PENSION_ARREARSWAGES,ISNULL(ES.Arrear_Wages_833,0) AS EDLI_ARREARS_WAGES  
         ,ISNULL(ES.Arrear_PF_Amount,0) AS PF_ARREARS,ISNULL(ES.Arrear_VPF_Amount,0) AS VOLUNTARY_PF_ARREARS  
         ,(ISNULL(ES.Arrear_PF_Amount,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_EMP_CONTRIBUTION_ARREARS  
         ,ISNULL(ES.Arrear_PF_367,0) AS EMPLOYER_PF_ARREARS,ISNULL(ES.Arrear_PF_833,0) AS PENSION_FUND_ARREARS  
         ,(ISNULL(ES.Arrear_PF_367,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_EMPLOYER_CONTRIBUTION_ARREARS,ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS ADMIN_CHARGE_02_ARREARS   
         ,ISNULL(Arrear_Edli_Charge_EmpWise,0) AS EDLI_CHARGE_21_ARREARS,ROUND((Arrear_PF_Admin_Charge_Empwise + Arrear_Edli_Charge_EmpWise),0) AS TOTAL_FUNDS_ARREARS  
         /* TOTAL OF PF & ARREARS STARTS HERE */  
         ,(ISNULL(ES.PF_AMOUNT,0) + ISNULL(ES.Arrear_PF_Amount,0)) AS TOTAL_PF,(ISNULL(ES.VPF,0) + ISNULL(ES.Arrear_VPF_Amount,0)) AS TOTAL_VOLUNTARY_PF  
         ,(ISNULL(ES.PF_367,0) + ISNULL(ES.Arrear_PF_367,0)) AS TOTAL_EMPLOYER_PF,(ISNULL(ES.PF_833,0) + ISNULL(ES.Arrear_PF_833,0)) AS TOTAL_PENSION_FUND  
         ,(ES.PF_AMOUNT + ISNULL(ES.Arrear_PF_Amount,0) + ES.VPF + ISNULL(ES.Arrear_VPF_Amount,0) + ES.PF_367 + ISNULL(ES.Arrear_PF_367,0) + ES.PF_833 + ISNULL(ES.Arrear_PF_833,0) ) AS CONTRIBUTION_TOTAL  
         ,ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) AS TOTAL_ADMIN_CHARGE_02  
         ,ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0) AS TOTAL_EDLI_CHARGE_21  
         ,ROUND(ES.PF_Admin_Charge_Empwise + ISNULL(Arrear_PF_Admin_Charge_Empwise,0) + ES.Edli_Charge_EmpWise + ISNULL(Arrear_Edli_Charge_EmpWise,0),0) AS TOTAL_FUNDS'  
      SET @query1 = 'FROM #EMP_PF_REPORT EPF   
         INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID  
         INNER JOIN #EMP_CONS EC ON EC.Emp_ID = EPF.EMP_ID  
         INNER JOIN #EMP_DETAIL ED ON EPF.EMP_ID = ED.EMP_ID  
         INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON INC.INCREMENT_ID = EC.INCREMENT_ID AND INC.EMP_ID = EC.EMP_ID  
         INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON INC.GRD_ID = GM.GRD_ID   
         INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.BRANCH_ID = BM.BRANCH_ID  
         INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  
         INNER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON INC.DESIG_ID = DGM.DESIG_ID  
         LEFT OUTER JOIN T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID   
         LEFT OUTER JOIN #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH AND EPF.YEAR = ES.YEAR  
         LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and  ES.YEAR =year(MS.Month_St_Date)  
         LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INC.DEPT_ID = DM.DEPT_ID   
         LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON INC.TYPE_ID = TM.TYPE_ID  
         LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS WITH (NOLOCK) ON INC.VERTICAL_ID = VS.VERTICAL_ID  
         LEFT OUTER JOIN T0050_SUBVERTICAL SV WITH (NOLOCK) ON INC.SUBVERTICAL_ID = SV.SUBVERTICAL_ID  
         LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON INC.Center_ID = CCM.Center_ID  
         LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON INC.Cat_ID = CTM.Cat_ID  
         LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON INC.Segment_ID = BS.Segment_ID'  
     execute(@query + ' '+ @query1)  
     --Update by Deepal --09062020  
    END  
   ELSE IF (@Format = 1 AND @Export_Type = 'CUSTOMIZED_EXCEL') -- ADDED BY JIMIT 29/10/2018  
    BEGIN  
      SELECT EPF.EMP_CODE,UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name Else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name Else '' End  )) as Emp_Full_Name,  
        Cmp_Name,bm.Branch_Name,Grd_Name,dept_Name,Desig_Name,Type_Name,vs.Vertical_Name,sv.SubVertical_name,E.UAN_No,E.Basic_Salary,Ms.Gross_Salary,Le.Left_Date,Le.Left_Reason,round(MS.Absent_Days,0)Absent_Days,ES.Sal_Cal_Day,  
          ES.arrear_days ,ES.Arear_M_AD_Amount,ES.Arrear_Wages,  
        EPF.FOR_DATE,EPF.[MONTH],EPF.[YEAR],EPF.PF_NO,(PF_AMOUNT) PF_AMOUNT ,PF_PER,PF_Limit,EDLI_Wages , PF_SALARY_AMOUNT,PF_833,PF_367,  
        PF_Diff_6500,ES.VPF,cm.PF_No as CPF_NO,  
        @From_Date P_From_Date ,@To_Date P_To_Date,ES.VPF_PER,ES.Arrear_PF_Amount,ES.Arrear_Wages_833,ES.Arrear_PF_833,ES.Arrear_PF_367,  
        (CASE WHEN @To_Date >= '2016-12-01' then  
         --(CASE When @Format = 2 THEN       
           Isnull(E.UAN_No,'') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) 
+   
           '#~#' + CAST(Cast(Round(Isnull(Ms.Gross_Salary,0) - (Isnull(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0)),0) as numeric) AS varchar(10)) + '#~#'  
           + CAST(PF_SALARY_AMOUNT As Varchar(10)) + '#~#' + CAST(PF_LIMIT As Varchar(10)) + '#~#'  
           + CAST(EDLI_Wages As Varchar(10)) + '#~#' + CAST(PF_AMOUNT + ISNULL(VPF,0) AS Varchar(10)) + '#~#'   
           + CAST(PF_833 AS Varchar(10)) + '#~#' + CAST(PF_367 AS Varchar(10)) + '#~#'  
           + Case When @IS_NCP_PRORATA = 1 Then CAST([dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days) As Varchar(2)) Else Case When  cast(Ms.Absent_Days as numeric(18,0)) < 0 Then '0' Else Cast(cast(Ms.Absent_Days as numeric(18,0)) As Varchar(6)) End End + '#~#'   
           + CAST(0 As Varchar(10))  
          --ELSE  
          -- IsNull(E.UAN_No,'') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) + '#~#' + CAST(Arrear_Wages As Varchar(10)) + '#~#'   
          -- + Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#'   
          -- + Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#'   
           
          -- + CAST(cast(round((Isnull(Arrear_PF_Amount,0) + Isnull(Arrear_VPF_Amount,0)),0) as Numeric)AS Varchar(10))+ '#~#'  
          
          -- + CAST(Arrear_PF_367 AS Varchar(10)) + '#~#' + CAST(Arrear_PF_833 AS Varchar(10))  
             --END)  
        ELSE  
          EPf.PF_NO + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'') <>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) + '#~#' + 
Cast(PF_SALARY_AMOUNT AS Varchar(10)) + '#~#'  
         
         + CAST(PF_LIMIT As Varchar(10)) + '#~#' + CAST(PF_AMOUNT AS Varchar(10)) + '#~#'  
         + CAST(PF_AMOUNT AS Varchar(10)) + '#~#' +  CAST(PF_833 AS Varchar(10)) + '#~#'  
         +  CAST(PF_833 AS Varchar(10)) + '#~#' +  CAST(PF_367 AS Varchar(10)) + '#~#'  
         
         +  CAST(PF_367 AS Varchar(10)) + '#~#' +   
           Case When @IS_NCP_PRORATA = 1 Then   
               CAST([dbo].[F_Get_NCP_Days] (MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days) As Varchar(2))   
           Else   Case When Ms.Absent_Days < 0 Then '0' Else Cast(Ms.Absent_Days As Varchar(10)) End   
           End + '#~#'  
         + CAST(0 As Varchar(10)) + '#~#' + CAST(Arrear_Wages As Varchar(10)) + '#~#'  
         + CAST(Arrear_PF_Amount As varchar(10)) + '#~#' + CAST(Arrear_PF_367 As varchar(10)) + '#~#'  
         + CAST(Arrear_PF_833 As Varchar(10)) + '#~#' + ED.FATHER_HUSBAND_NAME +  
         ED.RELATION + ED.DOB + ED.GENDER + ED.DOJ + ED.DOJ + ED.LEFT_DATE + ED.LEFT_DATE + ED.LEFT_REASON       
        end)As Text_String,@PF_LIMIT as Pf_Max_Limit  
      FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join  
      T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
      LEFT OUTER JOIN  #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH   
        AND EPF.YEAR = ES.YEAR  left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and    
        ES.YEAR =year(MS.Month_St_Date) INNER JOIN   
        ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join   
       ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)   
       where Increment_Effective_date <= @To_Date  
       and Cmp_ID = @Cmp_ID  
       group by emp_ID  ) Qry on  
       I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
    E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
    T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
    T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
    T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
    T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
    T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Inner Join   
    #EMP_DETAIL ED On EPF.EMP_ID = ED.EMP_ID LEFT outer JOIN  
    T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.Vertical_ID = vs.Vertical_ID LEFT OUTER JOIN  
    T0050_SubVertical sv WITH (NOLOCK) on Q_I.SubVertical_ID = sv.SubVertical_ID      
    order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)  
    END      
   ELSE --IF (@Format = 2)  
    BEGIN  
     SELECT EPF.*--, (SALARY_AMOUNT + ISNULL(OTHER_PF_SALARY,0) ) as SALARY_AMOUNT  
      ,(PF_AMOUNT) PF_AMOUNT ,PF_PER,PF_Limit,EDLI_Wages , PF_SALARY_AMOUNT,PF_833,PF_367  
      ,PF_Diff_6500,EMP_SECOND_NAME,ES.VPF,E.Basic_Salary,E.Emp_code,  
      UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name Else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name Else '' End  )) as Emp_Full_Name,Grd_Name,Type_Name
,dept_Name,Desig_Name,Cmp_Name,Cmp_Address,cm.PF_No as CPF_NO  
      ,@From_Date P_From_Date ,@To_Date P_To_Date,Father_Name,Le.Left_Date,Le.Left_Reason,round(MS.Absent_Days,0)Absent_Days,ES.Sal_Cal_Day  
      ,ES.arrear_days,ES.VPF_PER,ES.Arear_M_AD_Amount,ES.Arrear_Wages,ES.Arrear_PF_Amount,ES.Arrear_Wages_833,ES.Arrear_PF_833,ES.Arrear_PF_367,  
        
      --added by jimit 02012017  new online format after 1st december 2016 and old format before it.  
     (CASE WHEN @To_Date >= '2016-12-01' then  
       (CASE When @Format = 2 THEN       
         Isnull(E.UAN_No,'') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) + 
  
         '#~#' + CAST(Cast(Round(Isnull(Ms.Gross_Salary,0) - (Isnull(MS.Arear_Gross,0) + ISNULL(Ms.Settelement_Amount,0)),0) as numeric) AS varchar(10)) + '#~#'  
         + CAST(PF_SALARY_AMOUNT As Varchar(10)) + '#~#' + CAST(PF_LIMIT As Varchar(10)) + '#~#'  
         + CAST(EDLI_Wages As Varchar(10)) + '#~#' + CAST(PF_AMOUNT + ISNULL(VPF,0) AS Varchar(10)) + '#~#'   
         + CAST(PF_833 AS Varchar(10)) + '#~#' + CAST(PF_367 AS Varchar(10)) + '#~#'  
         + Case When @IS_NCP_PRORATA = 1 Then CAST([dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days) As Varchar(2)) Else 
Case When Ms.Absent_Days < 0 Then '0' Else Cast(Ms.Absent_Days As Varchar(10)) End End + '#~#'  
         + CAST(0 As Varchar(10))  
        ELSE  
         IsNull(E.UAN_No,'') + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) + 
'#~#' + CAST(Arrear_Wages As Varchar(10)) + '#~#'   
         + Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#'   
         + CAST(Arrear_Wages_833 As Varchar(10)) + '#~#'   --EDLI Wages  
         --+ Case When Isnull(Arrear_PF_833,0) <>0 then CAST(Arrear_Wages_833 As Varchar(10)) ELSE Cast(0 as varchar) END + '#~#' --Commented By Jimit 12-11-2018 as there is case at WCl for Employee Age greather than pension age Edli Wages amount 0       
     
         --+ CAST(cast(round((Isnull(Arrear_PF_Amount,0) + Isnull(Arrear_VPF_Amount,0)),0) as Numeric)AS Varchar(10)) + '#~#'  
         + CAST(cast(round((Isnull(Arrear_PF_Amount,0) + Isnull(Arrear_VPF_Amount,0)),0) as Numeric)AS Varchar(10))+ '#~#'  
          
         + CAST(Arrear_PF_367 AS Varchar(10)) + '#~#' + CAST(Arrear_PF_833 AS Varchar(10))  
           END)  
      ELSE  
        EPf.PF_NO + '#~#' + UPPER(ISNULL(EmpName_Alias_PF,Emp_First_Name +  Case when isnull(Emp_Second_Name,'')<>'' then + ' ' + Emp_Second_Name else '' End + Case when isnull(Emp_Last_Name,'')<>'' then + ' ' + Emp_Last_Name else '' End  )) + '#~#' + Cast(PF_SALARY_AMOUNT AS Varchar(10)) + '#~#'  
       --+ CAST(PF_SALARY_AMOUNT As Varchar(10)) + '#~#' + ----Golcha For Basic allowance amount Imported and effect on PF after discuss with Hardikbhai --Ankit 09092015  
       + CAST(PF_LIMIT As Varchar(10)) + '#~#' + CAST(PF_AMOUNT AS Varchar(10)) + '#~#'  
       + CAST(PF_AMOUNT AS Varchar(10)) + '#~#' +  CAST(PF_833 AS Varchar(10)) + '#~#'  
       +  CAST(PF_833 AS Varchar(10)) + '#~#' +  CAST(PF_367 AS Varchar(10)) + '#~#'  
       --+  CAST(PF_367 AS Varchar(10)) + '#~#' + CAST(Cast(Ms.Absent_Days As Numeric) As Varchar(2)) + '#~#'  
       +  CAST(PF_367 AS Varchar(10)) + '#~#' +   
         Case When @IS_NCP_PRORATA = 1 Then   
             CAST([dbo].[F_Get_NCP_Days] (/*@From_Date,@To_Date*/ MS.Month_St_Date ,MS.Month_End_Date,Ms.Basic_Salary,Ms.Salary_Amount,Ms.Sal_Cal_Days,@PF_LIMIT,ms.Absent_Days,Wages_Type,Weekoff_Days) As Varchar(2))   
         Else   Case When Ms.Absent_Days < 0 Then '0' Else Cast(Ms.Absent_Days As Varchar(4)) End  
         End + '#~#'  
       + CAST(0 As Varchar(10)) + '#~#' + CAST(Arrear_Wages As Varchar(10)) + '#~#'  
       + CAST(Arrear_PF_Amount As varchar(10)) + '#~#' + CAST(Arrear_PF_367 As varchar(10)) + '#~#'  
       + CAST(Arrear_PF_833 As Varchar(10)) + '#~#' + ED.FATHER_HUSBAND_NAME +  
       ED.RELATION + ED.DOB + ED.GENDER + ED.DOJ + ED.DOJ + ED.LEFT_DATE + ED.LEFT_DATE + ED.LEFT_REASON       
      end)As Text_String  
      ,Dgm.Desig_Dis_No,E.Alpha_Emp_Code,E.Emp_First_Name  --added jimit 25092015  
      ,vs.Vertical_Name,sv.SubVertical_name,bm.Branch_Name,@PF_LIMIT as Pf_Max_Limit     --added jimit 14042017   
      ,E.UAN_No  --added by jimit 07062017  
      ,BM.Comp_Name,BM.Branch_Address --added by jimit 27062017  
      ,Ms.Gross_Salary   --Added By Jimit 25122017  
      FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID left outer join  
      T0100_left_emp LE WITH (NOLOCK) on E.Emp_ID =Le.Emp_ID   
      LEFT OUTER JOIN  #EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH   
        AND EPF.YEAR = ES.YEAR  left outer join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on ES.EMP_ID=MS.Emp_ID and ES.MONTH=month(MS.Month_St_Date) and    
        ES.YEAR =year(MS.Month_St_Date) INNER JOIN   
        ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID,Wages_Type,I.Vertical_ID,I.SubVertical_ID FROM T0095_Increment I WITH (NOLOCK) inner join   
       ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) -- Ankit 09092014 for Same Date Increment  
       where Increment_Effective_date <= @To_Date  
       and Cmp_ID = @Cmp_ID  
       group by emp_ID  ) Qry on  
       I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )Q_I ON  
    E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN   
    T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN  
    T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN   
    T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join   
    T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join   
    T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id Inner Join   
    #EMP_DETAIL ED On EPF.EMP_ID = ED.EMP_ID LEFT outer JOIN  
    T0040_Vertical_Segment vs WITH (NOLOCK) on Q_I.Vertical_ID = vs.Vertical_ID LEFT OUTER JOIN  
    T0050_SubVertical sv WITH (NOLOCK) on Q_I.SubVertical_ID = sv.SubVertical_ID  
    Where PF_Amount > 0  
    order by RIGHT(REPLICATE(N' ', 500) + EPF.PF_NO, 500)  
    END  
  END  
  
  DROP TABLE #EMP_PF_REPORT--Nikunj  
  DROP TABLE #EMP_SALARY--Nikunj  
    
  
RETURN  