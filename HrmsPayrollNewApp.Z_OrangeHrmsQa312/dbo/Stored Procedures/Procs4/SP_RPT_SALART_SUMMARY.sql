  
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[SP_RPT_SALART_SUMMARY]              
  @Cmp_ID   numeric              
 ,@From_Date  datetime              
 ,@To_Date   datetime              
 --,@Branch_ID  numeric              
 --,@Cat_ID   numeric               
 --,@Grd_ID   numeric              
 --,@Type_ID   numeric = 0                
 --,@Dept_ID   numeric              
 --,@Desig_ID   numeric         
 ,@Branch_ID  varchar(max)           
 ,@Cat_ID     varchar(max)               
 ,@Grd_ID     varchar(max)              
 ,@Type_ID    varchar(max) = ''              
 ,@Dept_ID    varchar(max)              
 ,@Desig_ID   varchar(max)             
 ,@Emp_ID   numeric  = 0               
 ,@constraint  varchar(MAX) = ''          
 ,@Report_Call varchar(20)='ALL'              
 ,@Salary_Cycle_id numeric = NULL              
 --,@Segment_Id  numeric = 0                
 --,@Vertical_Id numeric = 0               
 --,@SubVertical_Id numeric = 0               
 --,@SubBranch_Id numeric = 0   
 ,@Segment_Id  varchar(max) = ''                
 ,@Vertical_Id varchar(max) = ''              
 ,@SubVertical_Id varchar(max) = ''               
 ,@SubBranch_Id varchar(max) = ''              
 ,@With_Ctc numeric = 1  
 ,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 11-05-2017              
               
AS              
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 Declare @cnt as numeric(18,2)  
 SET @cnt = 0    
    
set @Show_Hidden_Allowance = 0  
          
 /* Declare @Emp_Cons Table  
  (  
  Emp_ID numeric ,       
  Branch_ID NUMERIC,  
  Increment_ID NUMERIC   
  )   */     
                
  Declare @FinalOutPut Table              
  (              
   F_LableName  varchar(200),              
   F_Amount  numeric(18,2) default 0,              
   F_Ad_F  varchar(5),          
   F_Sort_Nu numeric(18,2),          
   F_NOT_EFFECT_SALARY Numeric(18,2),              
   F_Part_Of_CTC   Numeric(18,2),  
   F_Hide_In_Reports tinyint,   --added by Jaina 11-05-2017  
   F_For_FNF tinyint  --Added by Jaina 5-12-2017  
  )              
                
  if exists (select * from [tempdb].dbo.sysobjects where name like '#FinalOutput' )                
  begin              
   drop table #FinalOutput                   
  end              
                 
                 
  CREATE TABLE #FinalOutput              
  (              
    F_Row_ID    numeric ,              
    F_Sr_No     varchar(30) ,              
    F_Particuler   varchar(200),              
    F_Director    numeric(18,2),              
    F_Other_than_Director numeric(18,2),              
    F_Total     numeric(18,2)              
  )                 
                
  insert into #FinalOutput              
  select 1,'','Total No. of employee',0,0,0              
                
  insert into #FinalOutput              
  select 2,'','Total working Day',0,0.0,0.0              
                
  insert into #FinalOutput              
  select 3,'','Arrear given to no. of employee',0,0,0              
                
  --insert into #FinalOutput              
  --select 4,'','Total  LTA earned',0,0,0              
                
  insert into #FinalOutput              
  select 5,'','Total CTC',0,0,0              
                
  insert into #FinalOutput              
  select 6,'','',null,null,null     
    
  CREATE TABLE #Emp_Cons -- Addedd by nilesh patel   
 (        
   Emp_ID numeric ,       
  Branch_ID numeric,  
  Increment_ID numeric      
 )   
  IF @With_Ctc = 0 or @With_Ctc = 1  
   Begin  
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',1,0  
   End  
  Else If @With_Ctc = 2  
  Begin  
   exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',2,0  
  End  
   
  
 /*               
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
                
 IF @Salary_Cycle_id = 0                
 set @Salary_Cycle_id = null               
 If @Segment_Id = 0                 
 set @Segment_Id = null              
 If @Vertical_Id = 0                 
 set @Vertical_Id = null              
 If @SubVertical_Id = 0                
 set @SubVertical_Id = null               
 If @SubBranch_Id = 0                
 set @SubBranch_Id = null               
     
   if @Constraint <> ''  
  begin  
   Insert Into @Emp_Cons  
   select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#')  
  end  
 else  
  begin  
     
     
      
   Insert Into @Emp_Cons  
     
     SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V   
     Inner Join  
      dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID   
   LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid   
         FROM T0095_Emp_Salary_Cycle ESC  
          INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id   
              FROM T0095_Emp_Salary_Cycle   
              WHERE Effective_date <= @To_Date  
              GROUP BY emp_id  
             ) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id  
        ) AS QrySC ON QrySC.eid = V.Emp_ID  
   WHERE   
        V.cmp_id=@Cmp_ID     
         AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))            
         AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)        
     AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)        
     AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))        
     AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))        
     AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
     AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))       
     And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))  
     And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))  
     And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))  
     And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0)) -- Added on 06082013  
     and month(ms.Month_End_Date)  = month(@To_Date) and year(ms.Month_End_Date)  = year(@To_Date)  
     and ms.Is_FNF = 0  
     AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id)   
        AND Increment_Effective_Date <= @To_Date   
        AND   
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )        
      OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )        
      OR (Left_date IS NULL AND @To_Date >= Join_Date)        
      OR (@To_Date >= left_date  AND  @From_Date <= left_date )  
      OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)  
      )  
      
   ORDER BY Emp_ID  
        
   DELETE  FROM @Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment  
    WHERE  Increment_effective_Date <= @to_date  
    GROUP BY emp_ID )  
      
     end    */  
                           
 Declare @Month numeric               
 Declare @Year numeric                
         
    
 -- Ankit 17072014 --  
   
 DECLARE @ROUNDING Numeric  
 Declare @Type_Net_Salary_Round varchar(15)  
 Set @ROUNDING = 2  
   
 If @Branch_ID = ''  
   Begin   
    select Top 1 @ROUNDING =Ad_Rounding, @Type_Net_Salary_Round = ISNULL(Type_Net_Salary_Round,'')  
      from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID      
      and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)    
        
   End  
 Else  
  Begin  
     -- Change by nilesh patel  
     select @ROUNDING =Ad_Rounding, @Type_Net_Salary_Round = ISNULL(Type_Net_Salary_Round,'')  
     from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID   
     --and Branch_ID = @Branch_ID  -- Comment by nilesh patel     
     and Branch_ID IN(SELECT cast(data  as numeric) FROM dbo.Split(@Branch_ID,'#')) -- Added by nilesh patel  
     and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date   
    -- and Branch_ID = @Branch_ID  
     and Branch_ID IN(SELECT cast(data  as numeric) FROM dbo.Split(@Branch_ID,'#'))     
     and Cmp_ID = @Cmp_ID)    
  End  
     
 -- Ankit 17072014 --           
 IF @ROUNDING = 1  
  set @ROUNDING = 0  
    
    
 DECLARE @ProductionBonus_Ad_Def_Id as NUMERIC ---added by jimit 24032017   
 Set @ProductionBonus_Ad_Def_Id = 20  
   
    
 if exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )                
  begin              
    drop table #Yearly_Salary                   
   end              
                  
 CREATE TABLE #Yearly_Salary               
   (              
    Row_ID   numeric IDENTITY (1,1) not null,              
    Cmp_ID   numeric ,              
    Emp_Id   numeric ,              
    Def_ID   Numeric ,              
    Lable_Name  varchar(100),              
    Month_1   numeric(18,2) default 0,              
    Month_2   numeric(18,2) default 0,              
    Month_3   numeric(18,2) default 0,              
    Month_4   numeric(18,2) default 0,              
    Month_5   numeric(18,2) default 0,              
    Month_6   numeric(18,2) default 0,              
    Month_7   numeric(18,2) default 0,              
    Month_8   numeric(18,2) default 0,              
    Month_9   numeric(18,2) default 0,              
    Month_10  numeric(18,2) default 0,              
    Month_11  numeric(18,2) default 0,              
    Month_12  numeric(18,2) default 0,              
    Total numeric(18,2) default 0,              
    AD_ID   numeric,               
    LOAN_ID   NUMERIC,              
    CLAIM_ID  NUMERIC,              
    Group_Def_ID numeric default 0,              
    AD_F   varchar(10),              
    Working_Day  Numeric(18,2) default 0,              
    NOT_EFFECT_SALARY Numeric,              
    Part_Of_CTC   Numeric,          
    Ad_Sort_Nu numeric default 0,  
    Hide_In_Reports tinyint default 0, --Added by Jaina 11-05-2017          
    For_FNF  numeric default 0 --Added by Jaina 5-12-2017  
   )              
 BEGIN             
		--delete T from  (
		--select ROW_NUMBER() OVER(ORDER BY Emp_ID ASC) AS 'Rowid',* from #Emp_Cons  ) T where T.Rowid > 20 -- tejas


      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select  @Cmp_ID,emp_ID,1,'Basic Salary','I',0,0,0,0 From #Emp_Cons                                            
        
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Ad_Sort_Nu,Hide_In_Reports,For_FNF)              
      select DISTINCT @Cmp_ID,EC.emp_ID,0,AD_NAME ,MAD.AD_ID,'I',Case When ((MAD.ReimShow=1 and isnull(mad.ReimAmount,0)>0)) then 0 else AM.AD_NOT_EFFECT_SALARY end ,  
       AM.AD_PART_OF_CTC,AM.AD_LEVEL,AM.Hide_In_Reports,AM.FOR_FNF           
      From #Emp_Cons EC INNER JOIN                
      T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID              
      WHERE M_AD_FLAG = 'i' AND  FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE               
      and (AM.AD_NOT_EFFECT_SALARY = 0 or (MAD.ReimShow=1 and isnull(mad.ReimAmount,0)>0))  
      and ad_Def_Id <> @ProductionBonus_Ad_Def_Id             
        
                    
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,2,'Arears','I',0,0,0,0 From #Emp_Cons               
                
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,16,'Settlement Amount','I',0,0,0,0 From #Emp_Cons              
        
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,17,'Leave Encash Amount','I',0,0,0,0 From #Emp_Cons     
                  
      -----------Added by Hasmukh 29032013 ------              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,20,'WD OT Amount','I',0,0,0,0 From #Emp_Cons               
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,21,'WO OT Amount','I',0,0,0,0 From #Emp_Cons               
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,22,'HO OT Amount','I',0,0,0,0 From #Emp_Cons               
       
        
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
      select @Cmp_ID,emp_ID,3,'Gross','I',0,0,0,0 From #Emp_Cons               
        
      IF @ROUNDING = 0  
   Begin  
    insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
    select @Cmp_ID,emp_ID,26,'Gross Round','I',0,0,0,0 From #Emp_Cons     
      
    insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)              
    select @Cmp_ID,emp_ID,27,'Total Gross','I',0,0,0,0 From #Emp_Cons     
        End  
     
      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
      --if @with_ctc = 1               
      --begin              
          
       Insert Into  #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF)          
    Select  @Cmp_ID,emp_Id,99,'Production_Bonus','I',0,0,0,0 From #Emp_Cons   
    
              
       insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Ad_Sort_Nu,Hide_In_Reports,For_FNF)              
       select DISTINCT @Cmp_ID,EC.emp_ID,0,AD_NAME ,MAD.AD_ID,'I',AM.AD_NOT_EFFECT_SALARY,AM.AD_PART_OF_CTC,AM.AD_LEVEL,AM.Hide_In_Reports,AM.FOR_FNF           
       From #Emp_Cons EC INNER JOIN                
       T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID              
       WHERE M_AD_FLAG = 'i' AND  FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE               
       and AM.AD_NOT_EFFECT_SALARY = 1 And AM.AD_Part_Of_CTC = 1              
               
       insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,NOT_EFFECT_SALARY,Part_Of_CTC)              
       select  @Cmp_ID,emp_ID,4,'CTC',1,1 From #Emp_Cons               
      --end              
                    
      --Ended by rohit on 09102013              
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,CLAIM_ID)              
      select @Cmp_ID,EC.emp_ID,0,CLAIM_NAME ,CLAIM_ID From #Emp_Cons EC INNER JOIN                
      ( SELECT DISTINCT CA.EMP_ID ,CA.CLAIM_ID,CLAIM_NAME FROM T0210_MONTHLY_CLAIM_PAYMENT CP WITH (NOLOCK) INNER JOIN  T0120_CLAIM_APPROVAL CA WITH (NOLOCK) ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
      INNER JOIN T0040_CLAIM_MASTER  CM WITH (NOLOCK) ON CA.CLAIM_ID = CM.CLAIM_ID               
        WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE )Q ON EC.EMP_ID = Q.EMP_ID              
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC,Ad_Sort_Nu)              
      select DISTINCT @Cmp_ID,EC.emp_ID,0,AD_NAME ,MAD.AD_ID,'D',AM.AD_NOT_EFFECT_SALARY,AM.AD_PART_OF_CTC,AM.AD_LEVEL  From #Emp_Cons EC INNER JOIN                
      T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID              
      WHERE M_AD_FLAG = 'D' AND  FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE               
      and AM.AD_NOT_EFFECT_SALARY = 0              
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      select @Cmp_ID,emp_ID,11,'PT','D',0,0 From #Emp_Cons               
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      select @Cmp_ID,emp_ID,12,'LWF','D',0,0 From #Emp_Cons               
              
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      select @Cmp_ID,emp_ID,13,'REVENUE','D',0,0 From #Emp_Cons               
                    
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      select @Cmp_ID,emp_ID,14,'ADVANCE','D',0,0 From #Emp_Cons              
                    
      --insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      --select @Cmp_ID,emp_ID,23,'LOAN','D',0,0 From #Emp_Cons              
      ---------Added By Jimit 20122017------------  
  Insert  INTO #Yearly_Salary(Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)    
  SELECT DISTINCT @Cmp_id,La.Emp_ID,23,LM.LOAN_NAME,'D',0,0    
  FROM T0210_MONTHLY_LOAN_PAYMENT MLP WITH (NOLOCK) INNER JOIN   
    T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLP.LOAN_APR_ID=LA.LOAN_APR_ID INNER JOIN  
    T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID=LM.LOAN_ID Inner Join   
    #Emp_Cons EC On LA.Emp_Id = EC.Emp_Id  
  WHERE MLP.LOAN_PAYMENT_DATE BETWEEN @From_Date AND @To_Date AND SAL_TRAN_ID IS NOT NULL AND MLP.CMP_ID = @Cmp_id  
  --GROUP BY LA.Emp_ID,LM.LOAN_NAME,LA.LOAN_ID,LM.Is_Principal_First_than_Int  
  ORDER BY LM.LOAN_NAME  
      -------------------ended----------------------------  
        
        
        
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      select @Cmp_ID,emp_ID,24,'Loan Int Amt','D',0,0 From #Emp_Cons               
                    
      insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
      select @Cmp_ID,emp_ID,25,'Oth Ded.','D',0,0 From #Emp_Cons                
        
      if @with_ctc = 2   --Added by Jaina 6-12-2017  
      begin  
    
  insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
  select @Cmp_ID,emp_ID,30,'Shortfall Deduction','D',0,0 From #Emp_Cons                
   end  
    End     
               
 insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
    select @Cmp_ID,emp_ID,15,'NET SALARY','N',0,0 From #Emp_Cons               
  
    --select @ROUNDING  
     IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
  Begin  
   insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
   select @Cmp_ID,emp_ID,28,'Net Round','NR',0,0 From #Emp_Cons     
     
   insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_F,NOT_EFFECT_SALARY,Part_Of_CTC)              
   select @Cmp_ID,emp_ID,29,'Total Net','NT',0,0 From #Emp_Cons     
    End  
      
      
   --select * from #Yearly_Salary  
      
 declare @Temp_Date datetime              
 declare @TempEnd_Date datetime              
 Declare @count numeric               
 set @Temp_Date = @From_Date               
 set @TempEnd_Date = dateadd(mm,1,@From_Date )  -1               
 set @count = 1               
--Added by Jaina 06-12-2017  
    Declare @sqlQuery as Varchar(Max)  
  Declare @Str_Month as varchar(Max)  
  set @sqlQuery = ''  
  set @Str_Month = ''             
               
 while @Temp_Date <=@To_Date               
   Begin              
     set @Month =month(@TempEnd_Date)              
     set @Year = year(@TempEnd_Date)              
         
       
     set @Str_Month = 'Month_' + CAST(@count as varchar(10))  
    
  set @sqlQuery = 'Update #Yearly_Salary               
      set ' + @Str_Month +' = Salary_Amount   + isnull(Arear_Basic ,0)  +  ISNULL(Basic_Salary_Arear_cutoff,0)   --Added By Jimit 08052018 (as recover amount of basic arear is not calculating in case of Cutoff)  
       From #Yearly_Salary  Ys  inner join   
         T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) =' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) =' + cast(@Year as varchar(10)) +              
       ' and Def_ID = ''1'''  
       
       
     exec (@sqlQuery)  
       
      
  set @sqlQuery= ''    
  set @sqlQuery = 'Update #Yearly_Salary               
      set '+ @Str_Month + '= Other_Allow_Amount              
       From #Yearly_Salary  Ys  inner join   
       T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +                          
       'and Def_ID = ''2'''  
  exec (@sqlQuery)  
      
  set @sqlQuery= ''   
  set @sqlQuery = 'Update #Yearly_Salary               
      set '+@Str_Month +' = Gross_Salary              
       From #Yearly_Salary Ys  inner join   
            T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +                                      
            'and Def_ID = ''3'''     
   
 exec (@sqlQuery)  
      
 set @sqlQuery= ''  
 set @sqlQuery ='Update #Yearly_Salary               
      set '+ @Str_Month + ' = Total_Earning_Fraction              
     From #Yearly_Salary  Ys  inner join   
       T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
     Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +'and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +                                      
      'and Def_ID = ''26'''       
 exec (@sqlQuery)  
      
 set @sqlQuery= ''       
 set @sqlQuery = 'Update #Yearly_Salary               
      set ' +@Str_Month +'= Gross_Salary  + Total_Earning_Fraction           
      From #Yearly_Salary  Ys  inner join   
        T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
     Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +                                      
        'and Def_ID = ''27'''  
 exec (@sqlQuery)  
      
 set @sqlQuery= ''       
 set @sqlQuery ='Update #Yearly_Salary               
      set ' + @Str_Month +'= PT_Amount               
     From #Yearly_Salary  Ys  inner join   
       T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
     Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +              
      'and Def_ID = ''11'''  
    exec (@sqlQuery)  
      
 set @sqlQuery= ''   
    set @sqlQuery = 'Update #Yearly_Salary               
      set ' +@Str_Month +'= LWF_Amount               
     From #Yearly_Salary  Ys  inner join   
       T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
     Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +              
      'and Def_ID = ''12'''  
    exec (@sqlQuery)  
      
 set @sqlQuery= ''   
    set @sqlQuery = 'Update #Yearly_Salary               
      set ' + @Str_Month +'= Revenue_Amount              
      From #Yearly_Salary  Ys  inner join   
        T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +              
      'and Def_ID = ''13'''                                
    exec (@sqlQuery)  
      
 set @sqlQuery= ''     
 set @sqlQuery ='Update #Yearly_Salary                
      set '+ @Str_Month +'= Advance_Amount              
     From #Yearly_Salary  Ys  inner join   
       T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
     Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +                          
      'and Def_ID = ''14'''              
    exec (@sqlQuery)  
      
 set @sqlQuery= ''     
    set @sqlQuery = 'Update #Yearly_Salary                
      set '+ @Str_Month +'= Net_Amount              
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +                          
       'and Def_ID = ''15'''                                         
    exec (@sqlQuery)  
      
 set @sqlQuery= ''       
        
    IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
 Begin  
  set @sqlQuery ='Update #Yearly_Salary                
       set '+ @Str_Month +'= Net_Amount - Net_Salary_Round_Diff_Amount             
      From #Yearly_Salary  Ys  inner join   
        T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
      'and Def_ID = ''15'''  
  exec (@sqlQuery)  
      
  set @sqlQuery= ''   
     set @sqlQuery = 'Update #Yearly_Salary                
       set '+ @Str_Month +'= Net_Salary_Round_Diff_Amount              
       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +  
        'and Def_ID = ''28'''  
  exec (@sqlQuery)  
      
  set @sqlQuery= ''         
  set @sqlQuery ='Update #Yearly_Salary                
       set '+ @Str_Month +'= Net_Amount              
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +  
       'and Def_ID = ''29'''  
       
  exec (@sqlQuery)  
      
  set @sqlQuery= ''         
   IF @With_CTC=2 --Added by Jaina 6-12-2017  
   BEGIN  
     
     set @sqlQuery = 'Update #Yearly_Salary                 
         set '+ @Str_Month + '= ms.Short_Fall_Dedu_Amount              
        From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
        Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) ='+ cast(@Year as varchar(10)) +              
         'and Def_ID = ''30'''  
       
     exec(@sqlQuery)  
       
   END  
 End  
    
    
 If @With_CTC = 1 or @With_CTC = 0  
  Begin    
   set @sqlQuery= ''                       
   set @sqlQuery ='Update #Yearly_Salary               
        set '+@Str_Month +'= case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount   
          else  m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0) + ISNULL(M_AREAR_AMOUNT_Cutoff,0) end         
       From #Yearly_Salary  Ys  inner join   
        T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID               
       Where mad.For_Date =  (select top 1 For_Date   
               from T0210_MONTHLY_AD_DETAIL TSMAD WITH (NOLOCK)  
               where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >='''+CAST(@Temp_Date as varchar(11)) +''' and To_date < dateadd(m,1,'''+ CAST(@Temp_Date AS varchar(11))+''')  
             order by tsmad.For_Date desc )              
         and isnull(mad.S_Sal_Tran_ID,0) = ''0'''  
   exec(@sqlQuery)  
  End  
 Else IF @With_CTC=2  
  Begin  
   set @sqlQuery= ''   
   set @sqlQuery ='Update #Yearly_Salary               
        set '+ @Str_Month+'= case when (mad.ReimShow = 1 and mad.ReimAmount > 0 and isnull(ys.NOT_EFFECT_SALARY,0) = 0) then mad.ReimAmount   
           else  m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0) + ISNULL(M_AREAR_AMOUNT_Cutoff,0) end        
       From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
          YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID               
       Where mad.For_Date =  (select top 1 For_Date   
               from T0210_MONTHLY_AD_DETAIL TSMAD WITH (NOLOCK)  
               where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= '''+ CAST(@Temp_Date AS varchar(11))+''' and To_date < dateadd(m,1,'''+ CAST(@Temp_Date AS varchar(11))+''')   
               order by tsmad.For_Date desc )              
         and isnull(mad.S_Sal_Tran_ID,0) = ''0'' And ((Ys.NOT_EFFECT_SALARY=0) or (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0))'    
     
   exec(@sqlQuery)  
   set @sqlQuery = ''  
     
   set @sqlQuery ='Update #Yearly_Salary               
        set '+ @Str_Month +'= case when (mad.ReimShow = 1 and mad.ReimAmount > 0 and isnull(ys.NOT_EFFECT_SALARY,0)= 0) then mad.ReimAmount   
           else  m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0) + ISNULL(M_AREAR_AMOUNT_Cutoff,0) end        
       From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
         YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID               
       Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD WITH (NOLOCK)   
              where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= '''+ cast(@Temp_Date AS varchar(11))+''' and To_date < dateadd(m,1,'''+ cast(@Temp_Date AS varchar(11))+''')  
              order by tsmad.For_Date desc )              
          and isnull(mad.S_Sal_Tran_ID,0) =''0'' and MAD.FOR_FNF=''1'''  
   exec(@sqlQuery)  
   
   
  End  
   
                   
      -- for settelment amount added by mitesh on 17072012              
      set @sqlQuery = ''  
      set @sqlQuery ='Update #Yearly_Salary               
      set '+ @Str_Month + '= Settelement_Amount              
       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
       'and  Def_ID = ''16'''              
      exec(@sqlQuery)  
      set @sqlQuery = ''  
      set @sqlQuery ='Update #Yearly_Salary               
      set '+ @Str_Month + '= Leave_Salary_Amount              
       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
       'and  Def_ID = ''17'''  
      exec(@sqlQuery)  
      set @sqlQuery = ''  
        
      -- for OT amount added by Hasmukh on 29032013              
      set @sqlQuery ='Update #Yearly_Salary               
      set ' + @Str_Month + '= OT_Amount              
       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +                          
       'and  Def_ID = ''20'''  
  exec(@sqlQuery)  
  set @sqlQuery = ''  
              
     set @sqlQuery ='Update #Yearly_Salary               
      set '+ @Str_Month +' = M_WO_OT_Amount              
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +  
       'and  Def_ID = ''21'''  
       
  exec(@sqlQuery)  
  set @sqlQuery = ''  
     set @sqlQuery ='Update #Yearly_Salary               
      set '+@Str_Month +'= M_HO_OT_Amount              
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
       'and  Def_ID = ''22'''  
     exec(@sqlQuery)  
     set @sqlQuery= ''  
                        
    --set @sqlQuery ='Update #Yearly_Salary               
    --  set '+ @Str_Month+' = Loan_Amount              
    -- From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
    -- Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
    --   'and  Def_ID = ''23'''  
    
    
     
--Commented by Hardik 09/01/2018 as this will add Loan Amount + Interest Amount, Interest Amount column is already below side, so no need to add Interest amount in loan amount  
-- +  Case when isnull(LM.Is_Principal_First_than_Int,0)<>1   
--then SUM(ISNULL(MLP.INTEREST_AMOUNT,0))   
--else 0 end  
                     
 set @sqlQuery = 'update  #Yearly_Salary   
     SET  '+ @Str_Month +'  = Loan_Amount  
     FROM #Yearly_Salary  Ys  inner join  
       (  
        select  (IsNULL(Sum(LOAN_PAY_AMOUNT),0)) as Loan_Amount  
          ,LM.Loan_Name,La.Emp_Id   
        FROM T0210_MONTHLY_LOAN_PAYMENT MLP WITH (NOLOCK) INNER JOIN   
          T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLP.LOAN_APR_ID=LA.LOAN_APR_ID INNER JOIN  
          T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID=LM.LOAN_ID INNER JOIN  
          #Emp_Cons Ec On Ec.Emp_ID = La.Emp_ID  
        WHERE month(MLP.LOAN_PAYMENT_DATE) = '+ cast(@Month as varchar(10)) +' AND year(MLP.LOAN_PAYMENT_DATE) = '+ cast(@Year as varchar(10)) +'  
          AND SAL_TRAN_ID IS NOT NULL AND MLP.CMP_ID = '+ cast(@Cmp_id as varchar(10))+'  
        GROUP BY LM.LOAN_NAME,LA.LOAN_ID,LM.Is_Principal_First_than_Int,La.Emp_Id  
        --ORDER BY LM.LOAN_NAME  
       )Q On  Q.Loan_Name = ys.Lable_Name and Q.emp_Id = ys.emp_Id '  
       --Where  Def_ID = ''23''' Q.emp_Id = ys.Emp_Id and  
            
         
   
 exec (@sqlQuery)  
 set @sqlQuery = ''  
              
 set @sqlQuery='Update #Yearly_Salary               
      set '+ @Str_Month +' = Loan_Intrest_Amount              
       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
      'and  Def_ID = ''24'''  
   exec(@sqlQuery)  
   set @sqlQuery = ''  
              
   set @sqlQuery ='Update #Yearly_Salary               
      set '+ @Str_Month +'= Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)               
       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) ='+ cast(@Month as varchar(10)) +'  and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +              
      'and  Def_ID = ''25'''  
   exec(@sqlQuery)  
   set @sqlQuery = ''  
        
              
      ------OT Amount---Hasmukh 29032013              
                    
                    
      -- Added Working Day -- Start              
      --Update #Yearly_Salary             
      --set Working_Day = Sal_Cal_Days              
      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
         
      set @sqlQuery = 'Update #Yearly_Salary             
       set Working_Day = Sal_Cal_Days              
      From #Yearly_Salary  Ys  inner join   
       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms WITH (NOLOCK) on ys.emp_ID = ms.emp_ID               
       Where Month(Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +'              
       and 1 = (CASE WHEN '+ CAST(@With_Ctc AS varchar(10)) + ' <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN '+ CAST(@With_Ctc AS varchar(10)) +'= 2 THEN 1  ELSE 0 END)   
       GROUP by Sal_Cal_Days,ms.emp_id ) SalCal ON ys.Emp_Id = SalCal.Emp_ID'  
    
      -- Added Working Day -- End              
      exec(@sqlQuery)  
      set @sqlQuery = ''  
               
      set @sqlQuery = 'Update #Yearly_Salary               
          set '+ @Str_Month +' = Claim_pay_amount   
        From #Yearly_Salary  Ys  inner join               
       (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount   
        From T0210_MONTHLY_CLAIM_PAYMENT CP WITH (NOLOCK)  
        INNER JOIN  T0120_CLAIM_APPROVAL CA WITH (NOLOCK) ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
        INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
        WHERE CLAIM_PAYMENT_DATE >='''+CAST(@FROM_DATE AS varchar(11))+''' AND CLAIM_PAYMENT_dATE <='''+CAST(@TO_DATE as varchar(11))+''' ) Q on ys.Emp_ID = q.emp_ID              
      Where Month(CLAIM_PAYMENT_DATE) = '+ cast(@Month as varchar(10)) +' and Year(CLAIM_PAYMENT_DATE) = '+ cast(@Year as varchar(10)) +'  
       And Q.Claim_Name Collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name'               
    
  exec(@sqlQuery)  
  set @sqlQuery = ''          
      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
      --if @with_Ctc = 1              
      --begin         
        
        
        ----M_AREAR_AMOUNT_Cutoff Add by tejas at 18022025 for #32790
       set @sqlQuery = 'Update #Yearly_Salary               
       set '+ @Str_Month +' = table_Sum_CTC.Sum_CTC              
      from #Yearly_Salary YSD inner join               
        (select Isnull(SUM(M_AD_Amount + (M_AREAR_AMOUNT_Cutoff)),0) as Sum_CTC,Def_ID  , T.emp_id             
         From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms WITH (NOLOCK) on ys.emp_ID = ms.emp_ID               
               inner join T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) on ms.sal_tran_id = T.sal_tran_id               
          inner join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
        Where Month(ms.Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(ms.Month_End_Date) = '+ cast(@Year as varchar(10)) +'              
         and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 
		 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = ''I'' and isnull(S_Sal_Tran_ID,0) = 0              
        group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
      where YSD.def_id = 4'     
                         
        exec(@sqlQuery)  
		
		 
        set @sqlQuery = ''  
          
       set @sqlQuery = 'Update #Yearly_Salary               
       set '+@Str_Month +' = Month_1 + Gross_Salary              
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
      Where Month(Month_End_Date) = '+ cast(@Month as varchar(10)) +' and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) +'                          
      and Def_ID = 4'              
          
		  	        --select Lable_Name,sum(Month_1) from #Yearly_Salary where Lable_Name= 'CTC' group by Lable_Name -- tejas

		--  select Month_1 + Gross_Salary as 'total',MS.Month_End_Date        
		--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID                
		--Where Month(Month_End_Date) = 11 and Year(Month_End_Date) = 2024                                  
		--and Def_ID = 4       -- tejas
         
		 exec(@sqlQuery)  
        set @sqlQuery = ''             
      --end    
        
      ---added by jimit 24032017  
         
  set @sqlQuery = 'UPDATE   CM         
       SET '+ @Str_Month +' = Q.Amount  
      FROM #Yearly_Salary CM   
       INNER JOIN (  
          SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
          FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
            INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
          WHERE MAD.Cmp_ID='+ CAST(@Cmp_Id  as varchar(10))+'  
            AND MONTH(MAD.For_Date) = '+ cast(@Month as varchar(10)) +'  and YEAR(MAD.For_Date) = '+ cast(@Year as varchar(10)) +'  
            AND Ad_Active = 1 AND AD_Flag = ''I'' AND ad_not_effect_salary = 0   
            AND AD_DEF_ID = '+ CAST(@ProductionBonus_Ad_Def_Id AS varchar(10)) +'          
          GROUP BY Mad.Emp_ID  
          )Q On CM.Emp_ID = Q.Emp_ID   
      where Def_ID = 99 '  
      --and Month(for_Date) = @Month and Year(for_Date) = @Year      
  exec (@sqlQuery)  
    
  set @Temp_Date = dateadd(m,1,@Temp_date)  
  set @TempEnd_date = dateadd(m,1,@TempEnd_date)  
  set @count = @count + 1    
 End  
    
    
    
  ---Added by Jaina 6-12-2017 End                    
--    if @count = 1               
--     begin                        
--      Update #Yearly_Salary               
--      set Month_1 = Salary_Amount   + isnull(Arear_Basic ,0)             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_1 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
              
--      Update #Yearly_Salary               
--      set Month_1 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_1 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_1 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
        
                    
--      Update #Yearly_Salary               
--      set Month_1 = PT_Amount               
--   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_1 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
--      Update #Yearly_Salary               
--      set Month_1 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_1 = Advance_Amount             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_1 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
        
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_1 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
    
--        Update #Yearly_Salary                
--     set Month_1 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_1 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
  
--  End  
    
    
                          
--      Update #Yearly_Salary               
--      set Month_1 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_1 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
  
--      -- for settelment amount added by mitesh on 17072012              
--      Update #Yearly_Salary               
--      set Month_1 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
         
--        Update #Yearly_Salary               
--      set Month_1 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--    set Month_1 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_1 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_1 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22     
         
             
              
--      Update #Yearly_Salary               
--      set Month_1 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_1 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_1 = Other_dedu_amount  + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017  
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25                          
        
        
              
--      ------OT Amount---Hasmukh 29032013              
                    
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary             
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
         
--       Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--  Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1            --FNF Condition Changed By Ramiz on 08/04/2016  
--  and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--  GROUP by Sal_Cal_Days,ms.emp_id ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
     
--      -- Added Working Day -- End              
                    
                  
--      Update #Yearly_Salary               
--      set Month_1 = Claim_pay_amount   
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount  From T0210_MONTHLY_CLAIM_PAYMENT CP   
--       INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name Collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name               
                 
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin         
        
         
        
--       Update #Yearly_Salary               
--       set Month_1 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--       (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4     
                         
                     
--       Update #Yearly_Salary               
--       set Month_1 = Month_1 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--      --end    
        
        
--      ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_1 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended  
        
                   
--      -- Ended by Rohit on 09102013              
                    
--     end              
--    else if @count = 2              
--     begin              
--      Update #Yearly_Salary               
--      set Month_2 = Salary_Amount   + isnull(Arear_Basic ,0)             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_2 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
                     
--      Update #Yearly_Salary               
--  set Month_2 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_2 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_2 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
   
--      Update #Yearly_Salary               
--      set Month_2 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_2 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
--      Update #Yearly_Salary               
--      set Month_2 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--   set Month_2 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_2 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
                     
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_2 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_2 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_2 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End    
             
--      Update #Yearly_Salary               
--      set Month_2 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
          
--      Update #Yearly_Salary               
--      set Month_2 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
                    
--      Update #Yearly_Salary               
--      set Month_2 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
              
--      Update #Yearly_Salary               
--      set Month_2 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
         
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_2 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_2 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_2 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_2 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_2 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_2 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year     
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1            --FNF Condition Changed By Ramiz on 08/04/2016  
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
              
--      -- Added Working Day -- End              
                    
--      Update #Yearly_Salary               
--      set Month_2 = Claim_pay_amount        
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
               
               
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_2 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--      (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4       
         
                   
                     
--       Update #Yearly_Salary               
--       set Month_2 = Month_2 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--      --end        
        
--      ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_2 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
               
--      -- Ended by Rohit on 09102013              
                    
               
--     end               
--    else if @count = 3              
--     begin              
--      Update #Yearly_Salary               
--      set Month_3 = Salary_Amount    + isnull(Arear_Basic ,0)       
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_3 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_3 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
         
--      Update #Yearly_Salary               
--      set Month_3 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_3 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
              
--      Update #Yearly_Salary               
--      set Month_3 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_3 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_3 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_3 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_3 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
        
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_3 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_3 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary         
--     set Month_3 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End  
              
--      Update #Yearly_Salary               
--      set Month_3 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_3 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
--      Update #Yearly_Salary               
--      set Month_3 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
         
--       Update #Yearly_Salary               
--      set Month_3 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
         
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_3 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_3 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_3 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_3 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_3 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_3 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--  --    Update #Yearly_Salary               
--  --    set Working_Day = Sal_Cal_Days              
--  --    From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--  --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
    
--  Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1            --FNF Condition Changed By Ramiz on 08/04/2016  
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
--    -- Added Working Day -- End              
      
              
              
--      Update #Yearly_Salary               
--      set Month_3 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
              
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_3 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--      (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
-- group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4                
                     
--       Update #Yearly_Salary               
--       set Month_3 = Month_3 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year       
--       and Def_ID = 4              
                     
--      --end   
        
--      ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_3 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                    
--      -- Ended by Rohit on 09102013              
              
              
--     end               
--    else if @count = 4              
--     begin              
--      Update #Yearly_Salary               
--      set Month_4 = Salary_Amount    + isnull(Arear_Basic ,0)            
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_4 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_4 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
         
--      Update #Yearly_Salary               
--      set Month_4 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_4 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_4 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_4 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year     
--       and Def_ID = 12              
         
              
--      Update #Yearly_Salary               
--      set Month_4 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_4 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_4 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
        
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_4 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_4 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_4 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End               
                   
--      Update #Yearly_Salary               
--      set Month_4 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_4 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
                    
--      Update #Yearly_Salary               
--      set Month_4 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
        
--       Update #Yearly_Salary               
--      set Month_4 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_4 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_4 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_4 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_4 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_4 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_4 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
              
--      ------OT Amount---Hasmukh 29032013     
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year     
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1            --FNF Condition Changed By Ramiz on 08/04/2016  
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
             
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_4 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD   
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
-- Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
              
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_4 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--       (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4                
                     
--       Update #Yearly_Salary               
--       set Month_4 = Month_4 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--     --end    
       
--      ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_4 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                  
--      -- Ended by Rohit on 09102013              
              
--     end               
--    else if @count = 5              
--     begin              
--      Update #Yearly_Salary               
--      set Month_5 = Salary_Amount      + isnull(Arear_Basic ,0)          
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_5 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
                     
--      Update #Yearly_Salary               
--      set Month_5 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_5 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_5 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_5 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_5 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_5 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_5 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_5 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
        
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_5 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_5 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_5 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End               
                   
--      Update #Yearly_Salary               
--      set Month_5 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_5 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
--      Update #Yearly_Salary               
--      set Month_5 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
         
--        Update #Yearly_Salary               
--      set Month_5 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
              
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_5 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_5 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_5 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_5 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_5 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year               and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_5 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year          
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
        
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_5 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
                    
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_5 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--       (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4                 
                     
--       Update #Yearly_Salary               
--       set Month_5 = Month_5 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end    
--       ---added by jimit 23032017  
         
--  UPDATE   CM         
--  SET  Month_5 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
         
                    
--      -- Ended by Rohit on 09102013              
              
--     end               
--    else if @count = 6              
--     begin              
--      print @Month               
--      print @year              
--      Update #Yearly_Salary               
--      set Month_6 = Salary_Amount    + isnull(Arear_Basic ,0)            
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_6 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_6 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_6 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_6 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_6 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_6 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_6 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_6 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_6 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
                     
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_6 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_6 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_6 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End  
               
--      Update #Yearly_Salary               
--      set Month_6 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_6 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
             
--      Update #Yearly_Salary               
--      set Month_6 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16   
         
--        Update #Yearly_Salary               
--      set Month_6 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17             
              
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_6 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_6 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_6 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_6 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_6 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_6 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year            
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year       
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
           
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_6 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
                    
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_6 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--       (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4              
                     
--       Update #Yearly_Salary               
--       set Month_6 = Month_6 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end      
--       ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_6 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                  
--      -- Ended by Rohit on 09102013              
--     end               
--    else if @count = 7              
--     begin              
--      Update #Yearly_Salary               
--      set Month_7 = Salary_Amount      + isnull(Arear_Basic ,0)          
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                    
--      Update #Yearly_Salary               
--      set Month_7 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_7 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_7 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_7 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_7 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_7 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_7 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_7 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_7 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--  and Def_ID = 15              
                     
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_7 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_7 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_7 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End  
                   
--      Update #Yearly_Salary               
--      set Month_7 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_7 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
                    
--      Update #Yearly_Salary               
--      set Month_7 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID              
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
              
--      Update #Yearly_Salary               
--      set Month_7 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
     
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_7 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_7 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year            
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_7 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_7 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
         
--      Update #Yearly_Salary               
--      set Month_7 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_7 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year       
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
           
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_7 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
                    
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_7 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--      (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4            
                     
--       Update #Yearly_Salary               
--       set Month_7 = Month_7 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end      
         
--       ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_7 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                  
--      -- Ended by Rohit on 09102013              
                    
--     end               
--    else if @count = 8              
--     begin              
--      Update #Yearly_Salary               
--      set Month_8 = Salary_Amount     + isnull(Arear_Basic ,0)           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_8 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
-- and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_8 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
         
--      Update #Yearly_Salary               
--      set Month_8 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year         
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_8 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_8 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_8 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_8 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_8 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_8 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
                     
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_8 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_8 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_8 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End             
    
--      Update #Yearly_Salary               
--      set Month_8 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--    T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_8 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
                    
--      Update #Yearly_Salary               
--      set Month_8 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
        
--      Update #Yearly_Salary               
--      set Month_8 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
               
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_8 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_8 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_8 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_8 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_8 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_8 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--     and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year     
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
             
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_8 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
                    
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_8 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--      (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4                
                     
--       Update #Yearly_Salary               
--       set Month_8 = Month_8 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end   
--        ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_8 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                     
--      -- Ended by Rohit on 09102013              
                    
--     end               
--    else if @count = 9              
--     begin              
--      Update #Yearly_Salary               
--      set Month_9 = Salary_Amount      + isnull(Arear_Basic ,0)          
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
-- set Month_9 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_9 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_9 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_9 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
        
--       and Def_ID = 27        
--      Update #Yearly_Salary               
--      set Month_9 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_9 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_9 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_9 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_9 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
        
-- IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_9 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_9 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_9 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End               
                   
--      Update #Yearly_Salary               
--      set Month_9 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_9 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
--      Update #Yearly_Salary               
--      set Month_9 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16    
         
--       Update #Yearly_Salary               
--      set Month_9 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
                    
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_9 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_9 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary   
--      set Month_9 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_9 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_9 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_9 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
           
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year    
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
              
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_9 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
              
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_9 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--      (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4                
                     
--       Update #Yearly_Salary               
--       set Month_9 = Month_9 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end       
--        ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_9 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                 
--      -- Ended by Rohit on 09102013              
              
--     end               
--    else if @count = 10              
--     begin              
--      Update #Yearly_Salary               
--      set Month_10 = Salary_Amount       + isnull(Arear_Basic ,0)         
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_10 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                            
--      Update #Yearly_Salary               
--      set Month_10 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_10 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_10 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_10 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_10 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_10 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_10 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_10 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
          
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_10 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_10 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_10 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End  
               
--      Update #Yearly_Salary               
--      set Month_10 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_10 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
                    
--      Update #Yearly_Salary               
--      set Month_10 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16    
         
--        Update #Yearly_Salary               
--      set Month_10 = Leave_Salary_Amount  
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
                    
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_10 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_10 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_10 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_10 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_10 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_10 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year     
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
             
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_10 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join        
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
                    
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_10 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--     (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4               
                     
--       Update #Yearly_Salary               
--       set Month_10 = Month_10 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end         
--       ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_10 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
               
--      -- Ended by Rohit on 09102013              
--   end               
--    else if @count = 11              
--     begin              
--      Update #Yearly_Salary               
--      set Month_11 = Salary_Amount      + isnull(Arear_Basic ,0)          
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                     
--      Update #Yearly_Salary               
--      set Month_11 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
--      Update #Yearly_Salary               
--      set Month_11 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
        
--      Update #Yearly_Salary               
--      set Month_11 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--  Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_11 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27        
              
--      Update #Yearly_Salary               
--      set Month_11 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_11 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_11 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_11 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_11 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
                     
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_11 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_11 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_11 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End  
               
--      Update #Yearly_Salary               
--      set Month_11 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on           
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
            
--      Update #Yearly_Salary               
--      set Month_11 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
--      Update #Yearly_Salary               
--      set Month_11 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year          
--       and  Def_ID = 16              
               
--             Update #Yearly_Salary               
--      set Month_11 = Leave_Salary_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year          
--       and  Def_ID = 17  
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_11 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_11 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_11 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_11 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_11 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_11 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017             
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID  
    
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_11 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
                    
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_11 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--      (select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4             
                     
--       Update #Yearly_Salary               
--       set Month_11 = Month_11 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end    
--        ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_11 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                    
--      -- Ended by Rohit on 09102013              
       
--     end               
--    else if @count = 12              
--     begin              
--      Update #Yearly_Salary               
--      set Month_12 = Salary_Amount      + isnull(Arear_Basic ,0)          
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 1              
                    
--      Update #Yearly_Salary               
--      set Month_12 = Other_Allow_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 2              
                     
                     
--      -- Changed By Paras 31-12-2012              
--       Update #Yearly_Salary               
--      set Month_12 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 3              
--      -- End by Paras on 31122012              
                     
--       -- Changed By rohit For Gross not Showing on 31122012              
--      Update #Yearly_Salary               
--      set Month_12 = Gross_Salary              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 3              
--      -- End by rohit on 31122012              
        
--      Update #Yearly_Salary               
--      set Month_12 = Total_Earning_Fraction              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 26  
        
--      Update #Yearly_Salary               
--      set Month_12 = Gross_Salary  + Total_Earning_Fraction           
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 27  
               
--      Update #Yearly_Salary               
--      set Month_12 = PT_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 11              
              
--      Update #Yearly_Salary               
--      set Month_12 = LWF_Amount               
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 12              
              
              
--      Update #Yearly_Salary               
--      set Month_12 = Revenue_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 13              
              
--      Update #Yearly_Salary                
--      set Month_12 = Advance_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 14              
                                          
--      Update #Yearly_Salary                
--      set Month_12 = Net_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 15              
        
--      IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
--  Begin  
--   Update #Yearly_Salary                
--     set Month_12 = Net_Amount - Net_Salary_Round_Diff_Amount             
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 15      
          
--        Update #Yearly_Salary                
--     set Month_12 = Net_Salary_Round_Diff_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 28  
           
--     Update #Yearly_Salary                
--     set Month_12 = Net_Amount              
--     From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--     Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--      and Def_ID = 29  
--  End               
                   
--      Update #Yearly_Salary               
--      set Month_12 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)  
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='A'  
                    
--      Update #Yearly_Salary               
--      set Month_12 = case when (mad.ReimShow=1 and mad.ReimAmount >0 and isnull(ys.NOT_EFFECT_SALARY,0)=0) then mad.ReimAmount else 0 end        
--      From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on               
--       YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID   Inner JOIN  
--       T0050_AD_MASTER AM on Mad.AD_ID=Am.AD_ID  
--      Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD   
--      where TSMAD.Emp_ID = MAD.Emp_ID and For_Date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)   
--      order by tsmad.For_Date desc )              
--      and isnull(mad.S_Sal_Tran_ID,0) = 0 And ISNULL(AM.Allowance_Type,'A')='R'  
                    
--      Update #Yearly_Salary               
--      set Month_12 = Settelement_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 16              
              
--            Update #Yearly_Salary               
--      set Month_12 = Leave_Salary_Amount  
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 17  
         
--      -- for OT amount added by Hasmukh on 29032013              
--      Update #Yearly_Salary               
--      set Month_12 = OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 20              
              
--      Update #Yearly_Salary               
--      set Month_12 = M_WO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 21              
              
--      Update #Yearly_Salary               
--      set Month_12 = M_HO_OT_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 22              
              
--      Update #Yearly_Salary               
--      set Month_12 = Loan_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 23              
              
--      Update #Yearly_Salary               
--      set Month_12 = Loan_Intrest_Amount              
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 24              
              
--      Update #Yearly_Salary               
--      set Month_12 = Other_dedu_amount + Isnull(ms.Late_Dedu_Amount,0)   --added by Jimit 29072017  
--      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and  Def_ID = 25              
--      ------OT Amount---Hasmukh 29032013              
                    
--      -- Added Working Day -- Start              
--      --Update #Yearly_Salary               
--      --set Working_Day = Sal_Cal_Days              
--      --From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--      --Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year    
        
--      Update #Yearly_Salary             
--       set Working_Day = Sal_Cal_Days              
--       From #Yearly_Salary  Ys  inner join   
--       ( SELECT Sal_Cal_Days As Sal_Cal_Days,ms.Emp_ID From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--   Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and Is_FNF <>1              
--   and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) <> 1  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
--   GROUP BY Sal_Cal_Days,ms.emp_id   
--  ) SalCal ON ys.Emp_Id = SalCal.Emp_ID            
    
--      -- Added Working Day -- End              
              
--      Update #Yearly_Salary               
--      set Month_12 = Claim_pay_amount              
--      From #Yearly_Salary  Ys  inner join               
--      (SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD                
--       INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id               
--       WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID              
--      Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name = YS.Lable_Name               
              
--      -- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013              
--      --if @with_Ctc = 1              
--      --begin               
--       Update #Yearly_Salary               
--       set Month_12 = table_Sum_CTC.Sum_CTC              
--       from #Yearly_Salary YSD inner join               
--(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id            
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
--       inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id               
--       inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID              
--       Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year              
--       and Def_ID = 4 and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0              
--       group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID           
--       where YSD.def_id = 4             
                     
--       Update #Yearly_Salary               
--       set Month_12 = Month_12 + Gross_Salary              
--       From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID               
--       Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year              
--       and Def_ID = 4              
                     
--       --end    
--       ---added by jimit 24032017  
         
--  UPDATE   CM         
--  SET  Month_12 = Q.Amount  
--  FROM #Yearly_Salary CM   
--    INNER JOIN (  
--    SELECT ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID  
--    FROM T0210_MONTHLY_AD_DETAIL MAD   
--      INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID              
--    WHERE MAD.Cmp_ID= @Cmp_Id   
--       AND MONTH(MAD.For_Date) =  @Month and YEAR(MAD.For_Date) = @Year  
--       AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0   
--       AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id  
--       --AND MAD.Emp_ID = @EMp_Id_Production  
--    GROUP BY Mad.Emp_ID  
--     )Q On CM.Emp_ID = Q.Emp_ID   
--  where Def_ID = 99 --and Month(for_Date) = @Month and Year(for_Date) = @Year              
         
--       ---ended   
                    
--      -- Ended by Rohit on 09102013                  
--     end                                                           
--    set @Temp_Date = dateadd(m,1,@Temp_date)              
--    set @TempEnd_date = dateadd(m,1,@TempEnd_date)              
--    set @count = @count + 1                
--   End              
          
          
        
 UPDATE #Yearly_Salary              
  SET TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9               
     + MONTH_10 + MONTH_11 + MONTH_12               
              
 Update #Yearly_Salary              
  set group_Def_ID = New_ID              
  from #Yearly_Salary y Inner join               
  ( select min(row_ID)New_ID ,Lable_NAme from #Yearly_Salary group by lable_name)q on y.Lable_NAme = q.lable_Name              
  
  
 If @Report_Call = '' or @Report_Call = 'ALL'              
   Begin                     
    -- Added -- Start                  
    SET @cnt = 0  
                   
 --Commented by Hardik 01/01/2018 As Count is coming wrong                   
    --Set @cnt = (select distinct count(distinct(Ys.Emp_Id))              
    --from #Yearly_Salary  Ys inner join               
    --( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I inner join               
    --( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment -- Ankit 10092014 for Same Date Increment          
    --where Increment_Effective_date <= @To_Date              
    --and Cmp_ID = @Cmp_ID              
    --group by emp_ID  ) Qry on              
    --I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )IQ on              
    --ys.emp_Id = iq.emp_Id )  
                  
 Select @Cnt = Count(1) From #Emp_Cons EC Where EXISTS(Select 1 From #Yearly_Salary YS Where Ec.Emp_ID = YS.Emp_Id)--Added by Hardik 01/01/2018  
                  
         
    Update #FinalOutput Set F_Other_than_Director = ISNULL(@cnt,0),F_Total = ISNULL(@cnt,0) where F_Row_ID = 1              
                  
    SET @cnt = 0              
    SET @cnt = (Select SUM (Working_Day) from (select Ys.Working_Day as Working_Day               
    from #Yearly_Salary  Ys   
  --inner join   --Comment By Ankit 16102015  
  --( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I inner join               
  --   ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  -- Ankit 10092014 for Same Date Increment             
  --   where Increment_Effective_date <= @To_Date              
  --   and Cmp_ID = @Cmp_ID              
  --   group by emp_ID  ) Qry on              
  --   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID)IQ on              
  --   ys.emp_Id = iq.emp_Id                     
       group by ys.Emp_Id,Working_Day) as tempWD)     
      
                  
    Update #FinalOutput Set F_Other_than_Director = ISNULL(@cnt,0),F_Total = ISNULL(@cnt,0) where F_Row_ID = 2                     
    -- Added -- End                                  
    
          
 INSERT INTO @FinalOutPut          
  Select Lable_Name              
  ,(SUM(Month_1) + SUM (Month_2)+ SUM (Month_3)+ SUM (Month_4)+ SUM (Month_5)+ SUM (Month_6)              
  + SUM (Month_7)+ SUM (Month_8)+ SUM (Month_9)+ SUM (Month_10)+ SUM (Month_11)+ SUM (Month_12))              
  ,AD_F,Ad_Sort_Nu,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF from (              
  select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name               
    ,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,Emp_Full_Name,              
    @From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID              
  from #Yearly_Salary  Ys inner join               
  ( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join               
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment             
     where Increment_Effective_date <= @To_Date              
     and Cmp_ID = @Cmp_ID              
     group by emp_ID  ) Qry on              
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )IQ on              
     ys.emp_Id = iq.emp_Id inner join              
     T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID INNER JOIN               
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN              
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN              
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN              
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id Inner join               
     T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID inner join               
     T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id              
  ) as temp Group By Lable_Name,AD_F,Ad_Sort_Nu,NOT_EFFECT_SALARY,Part_Of_CTC,Hide_In_Reports,For_FNF Order by Ad_Sort_Nu          
                 
   
 -- Added -- Start To Get CTC           
  SET @cnt = 0              
  SET @cnt = (Select (SUM(Month_1) + SUM (Month_2)+ SUM (Month_3)+ SUM (Month_4)+ SUM (Month_5)+ SUM (Month_6)              
    + SUM (Month_7)+ SUM (Month_8)+ SUM (Month_9)+ SUM (Month_10)+ SUM (Month_11)+ SUM (Month_12)) as TotalCTC              
   from (select  Ys.*              
   from #Yearly_Salary  Ys inner join               
   ( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join               
      ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)  -- Ankit 10092014 for Same Date Increment           
      where Increment_Effective_date <= @To_Date              
      and Cmp_ID = @Cmp_ID              
      group by emp_ID  ) Qry on              
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID )IQ on              
      ys.emp_Id = iq.emp_Id              
   Where Ys.Def_id = 4) as tempCTC )              
  Update #FinalOutput Set F_Other_than_Director = ISNULL(@cnt,0),F_Total = ISNULL(@cnt,0) where F_Row_ID = 5              
 -- Added -- End              
   
 -- Added by Ali for getting count of Arrers -- Start  
  SET @cnt = 0  
  --SET @cnt = (   
  --select COUNT(Emp_Id) from #Yearly_Salary where Def_id = 2   
  --AND (Month_1 <> 0   
  --OR Month_2 <> 0   
  --OR Month_3 <> 0   
  --OR Month_4 <> 0   
  --OR Month_5 <> 0   
  --OR Month_6 <> 0   
  --OR Month_7 <> 0   
  --OR Month_8 <> 0   
  --OR Month_9 <> 0   
  --OR Month_10 <> 0   
  --OR Month_11 <> 0   
  --OR Month_12 <> 0)  
  -- )  
    
  select @cnt = count(emp_id) from   
     (  
      (   
       select distinct MAD.Emp_ID as emp_id from T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
       INner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID   --Check Conditoin For FNF --ANkit 06072015  
         INNER JOIN #EMP_CONS EC ON EC.EMP_ID = MAD.EMP_ID -- Added By Ramiz on 06/05/2016  
         where To_date >= @From_Date and To_date <= @To_Date  and isnull(M_AREAR_AMOUNT,0) <> 0   
         and MAD.Cmp_ID = @Cmp_ID --AND ISNULL(MS.IS_FNF,0) = 0   
         and 1 = (CASE WHEN @With_Ctc <> 2 and ISNULL(MS.IS_FNF,0) = 0  THEN 1 WHEN @With_Ctc = 2 THEN 1  ELSE 0 END)   
         group by MAD.Emp_ID  )  
      ) as tbl1  
  
    
  --select distinct emp_id as emp_id from T0210_MONTHLY_AD_DETAIL where To_date >= @From_Date and To_date <= @To_Date  and isnull(M_AREAR_AMOUNT,0) <> 0 and Cmp_ID = @Cmp_ID group by emp_id  
    
    
  Update #FinalOutput Set F_Other_than_Director = ISNULL(@cnt,0),F_Total = ISNULL(@cnt,0) where F_Row_ID = 3    
    
    
 -- Added by Ali for getting count of Arrers -- END  
      
          

    IF @With_Ctc = 1          
    BEGIN          
              
  insert into #FinalOutput              
  select 100,'<b> (A) </b>','<b> Salary Breakup (I) </b>',null,null,null              
  
  
  insert into #FinalOutput              
  Select 100,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut              
  where F_Ad_F = 'I' AND F_NOT_EFFECT_SALARY = 0     
  --AND F_Amount > 0    
  AND F_LableName NOT IN (select data from dbo.split('Gross#Arears#HO OT Amount#WD OT Amount#WO OT Amount#Gross Round#Total Gross','#'))          
  Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu            
       
       
                  
  insert into #FinalOutput              
  Select 100,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut              
  where F_Ad_F = 'I' AND F_NOT_EFFECT_SALARY = 0     
  --AND F_Amount > 0    
  AND F_LableName IN (select data from dbo.split('Arears#HO OT Amount#WD OT Amount#WO OT Amount','#'))          
  Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu            
  
  
      
  --insert into #FinalOutput              
  --select 100,'','<b> TOTAL GROSS SALARY </b>',0,(Select ISNULL(SUM(F_Amount),0)        
  --from @FinalOutPut where F_LableName like 'Gross'),(Select ISNULL(SUM(F_Amount),0)           
  --from @FinalOutPut where F_LableName like 'Gross')              
  
  -------Ankit 16072014----------  
  insert into #FinalOutput              
  select 100,'','<b> TOTAL GROSS </b>',0,(Select ISNULL(SUM(F_Amount),0)        
  from @FinalOutPut where F_LableName like 'Gross'),(Select ISNULL(SUM(F_Amount),0)           
  from @FinalOutPut where F_LableName like 'Gross')     
    
  IF @ROUNDING = 1  
   Begin  
    insert into #FinalOutput              
    select 100,'','<b> TOTAL GROSS ROUND </b>',0,(Select ISNULL(SUM(F_Amount),0)        
    from @FinalOutPut where F_LableName like 'Gross Round'),(Select ISNULL(SUM(F_Amount),0)           
    from @FinalOutPut where F_LableName like 'Gross Round')              
      
    insert into #FinalOutput              
    select 100,'','<b> TOTAL GROSS SALARY </b>',0,(Select ISNULL(SUM(F_Amount),0)        
    from @FinalOutPut where F_LableName like 'Total Gross'),(Select ISNULL(SUM(F_Amount),0)           
    from @FinalOutPut where F_LableName like 'Total Gross')              
      
   End  
     
  -------Ankit 16072014----------  
    
  insert into #FinalOutput              
  select 0,'','',null,null,null              
                      
  insert into #FinalOutput              
  select 200,'<b> (B) </b>','<b> Salary Breakup (II) </b>',null,null,null                    
         
              
  insert into #FinalOutput              
  Select 100,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut              
  where F_Ad_F = 'I' AND F_NOT_EFFECT_SALARY = 1 AND F_Part_Of_CTC = 1     
  and (CASE WHEN @Show_Hidden_Allowance = 0  and  F_Hide_In_Reports = 1 THEN 0 else 1 END )=1  --Change By Jaina 11-05-2017  
  --AND F_Amount > 0    
  AND F_LableName NOT IN (select data from dbo.split('Gross#Arears#HO OT Amount#WD OT Amount#WO OT Amount#Gross Round#Total Gross','#'))          
  Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu            
    
--  select * from #FinalOutput  
--select * from #Yearly_Salary where def_Id = 23  
             --return
  --11-05-2017                  
  insert into #FinalOutput              
  Select 100,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut              
  where F_Ad_F = 'I' AND F_NOT_EFFECT_SALARY = 1 AND F_Part_Of_CTC = 1     
    
  --AND F_Amount > 0    
  AND F_LableName IN (select data from dbo.split('Arears#HO OT Amount#WD OT Amount#WO OT Amount','#'))          
  Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu            
         
        
             
  insert into #FinalOutput              
  select 0,'','',null,null,null              
                      
  insert into #FinalOutput              
  select 200,'<b> (C) </b>','<b> Deduction </b>',null,null,null              
                      
  insert into #FinalOutput              
  Select 200,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut               
  where F_Ad_F = 'D' --AND F_Amount > 0  
   Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu           
                      
  insert into #FinalOutput              
  select 200,'','<b> TOTAL DEDUCTION </b>',0,(Select ISNULL(SUM(F_Other_than_Director),0)        
  from #FinalOutput where F_Row_ID = 200),(Select ISNULL(SUM(F_Other_than_Director),0)               
  from #FinalOutput where F_Row_ID = 200)              
                      
  insert into #FinalOutput              
  select 0,'','',null,null,null              
  
  insert into #FinalOutput              
  select 300,'<b> (D) </b>','<b> NET AMOUNT </b>',0,(Select F_Amount from @FinalOutPut where F_Ad_F = 'N' )              
  ,(Select F_Amount from @FinalOutPut where F_Ad_F = 'N' )           
     
        IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
   Begin  
     
    insert into #FinalOutput              
    select 300,'<b> (D) </b>','<b> NET ROUND </b>',0,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NR' )              
    ,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NR' )           
    
    insert into #FinalOutput              
    select 300,'<b> (D) </b>','<b> TOTAL NET </b>',0,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NT' )              
    ,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NT' )           
    
   End          
 END                  
    ELSE          
    BEGIN          
            
  insert into #FinalOutput              
  select 100,'<b> (A) </b>','<b> Salary Breakup </b>',null,null,null        
          
  insert into #FinalOutput              
  Select 100,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut              
  where F_Ad_F = 'I' --AND F_NOT_EFFECT_SALARY = 0   
    AND (F_NOT_EFFECT_SALARY = 0   --ADded by Jaina 5-12-2017  
      OR (CASE WHEN @WITH_CTC = 2 AND F_NOT_EFFECT_SALARY = 1 and F_For_FNF = 1 THEN 1 ELSE 0 END) = 1)  
  --AND F_Amount > 0    
  AND F_LableName NOT IN (select data from dbo.split('Gross#Arears#HO OT Amount#WD OT Amount#WO OT Amount#Gross Round#Total Gross','#'))          
  Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu            
       
                  
  insert into #FinalOutput              
  Select 100,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut              
  where F_Ad_F = 'I' AND F_NOT_EFFECT_SALARY = 0     
  --AND F_Amount > 0    
  AND F_LableName IN (select data from dbo.split('Arears#HO OT Amount#WD OT Amount#WO OT Amount','#'))          
  Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu            
                         
  insert into #FinalOutput              
  select 100,'','<b> TOTAL GROSS SALARY </b>',0,(Select ISNULL(SUM(F_Amount),0)        
  from @FinalOutPut where F_LableName like 'Gross'),(Select ISNULL(SUM(F_Amount),0)               
  from @FinalOutPut where F_LableName like 'Gross')             
       
     insert into #FinalOutput              
  select 0,'','',null,null,null              
                      
  insert into #FinalOutput              
  select 200,'<b> (B) </b>','<b> Deduction </b>',null,null,null              
                      
  insert into #FinalOutput              
  Select 200,'',F_LableName,0,SUM(F_Amount) as Amt,SUM(F_Amount) as Amt from @FinalOutPut               
  where F_Ad_F = 'D' AND F_Amount > 0 Group By F_LableName,F_Ad_F,F_Sort_Nu order by F_Sort_Nu           
                      
  insert into #FinalOutput              
  select 200,'','<b> TOTAL DEDUCTION </b>',0,(Select ISNULL(SUM(F_Other_than_Director),0)              
  from #FinalOutput where F_Row_ID = 200),(Select ISNULL(SUM(F_Other_than_Director),0)             
  from #FinalOutput where F_Row_ID = 200)              
                      
  insert into #FinalOutput              
  select 0,'','',null,null,null              
                      
  insert into #FinalOutput              
  select 300,'<b> (C) </b>','<b> NET AMOUNT </b>',0,(Select F_Amount from @FinalOutPut where F_Ad_F = 'N')              
  ,(Select F_Amount from @FinalOutPut where F_Ad_F = 'N')           
          
        IF @Type_Net_Salary_Round <> ''--@ROUNDING = 0  
   Begin  
     
    insert into #FinalOutput              
    select 300,'<b> (C) </b>','<b> NET ROUND </b>',0,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NR')              
    ,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NR')     
      
    insert into #FinalOutput              
    select 300,'<b> (C) </b>','<b> TOTAL NET </b>',0,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NT')              
    ,(Select F_Amount from @FinalOutPut where F_Ad_F = 'NT')     
      
   End    
           
    END          
                 
    insert into #FinalOutput              
    select 0,'','',null,null,null              
    insert into #FinalOutput              
    select 0,'','',null,null,null              
    insert into #FinalOutput              
    select 0,'','',null,null,null              
      
    select * from #FinalOutput   WHERE (F_Total <> 0 OR F_Other_than_Director <> 0 OR F_Director <> 0 OR F_Sr_No <> '')   
                  
   End                 
 RETURN   
  
  
  
  