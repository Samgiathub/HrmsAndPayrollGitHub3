    
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_STATEMENT_GET]    
 @Cmp_ID   numeric    
,@From_Date  datetime    
,@To_Date   datetime    
--,@Branch_ID  numeric   --Comment By Jaina 19-10-2015    
--,@Cat_ID   numeric     
--,@Grd_ID   numeric    
--,@Type_ID   numeric    
--,@Dept_ID   numeric    
--,@Desig_ID   numeric    
,@Branch_ID  varchar(Max)=''    
,@Cat_ID   varchar(Max)=''    
,@Grd_ID   varchar(Max)=''    
,@Type_ID   varchar(Max)=''    
,@Dept_ID   varchar(Max)=''    
,@Desig_ID   varchar(Max)=''    
,@Emp_ID   numeric    
,@constraint  varchar(MAX)    
,@Flag_For_Total tinyint=0--Added by Sumit for gettting Total Amount of ESIC Cal page    
,@Vertical_ID varchar(max)=''  --Added By Jaina 19-10-2015    
,@SubVertical_ID varchar(max)='' --Added By Jaina 19-10-2015    
,@Segment_Id varchar(MAX) =''  --Added By Jaina 23-10-2015    
----,@PBranch_ID varchar(max)= '' --Added By Jaina 06-10-2015    
----,@PVertical_ID varchar(max)= '' --Added By Jaina 06-10-2015    
----,@PSubVertical_ID varchar(max)= '' --Added By Jaina 06-10-2015    
----,@PDept_ID varchar(max)=''  --Added By Jaina 06-10-2015    
AS    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
     
 -- Added by Hardik 06/07/2018 for VIVO MP, Mid join and Mid left cases not coming due to 26 to 25 salary cycle    
  --   IF DAY(@From_Date) = '01'    
  --BEGIN    
  -- SET @From_Date = DATEADD(D,-5,@From_Date) -- FOR 26TH SALARY DATE    
  -- SET @TO_DATE = DATEADD(D,-5,@TO_DATE) -- FOR 26TH SALARY DATE    
  --END    
     
 Declare @AD_Def_ID numeric     
 --declare @EMPLOYER_CONT_PER numeric (18,2)    
 Declare @Emp_Share_Cont_Amount numeric     
 Declare @Employer_Share_Cont_Amount numeric     
 Declare @Total_Share_Cont_Amount numeric     
     
 --set @EMPLOYER_CONT_PER =0    
 set @AD_Def_ID =3    
 set @Emp_Share_Cont_Amount =0    
 set @Employer_Share_Cont_Amount = 0    
 set @Total_Share_Cont_Amount =0     
       
 IF @Branch_ID = '0' or  @Branch_ID=''    
  set @Branch_ID = null    
      
 IF @Cat_ID = '0' or @Cat_ID=''    
  set @Cat_ID = null    
    
 IF @Grd_ID = '0' or  @Grd_ID=''     
  set @Grd_ID = null    
    
 IF @Type_ID = '0' or @Type_ID=''    
  set @Type_ID = null    
    
 IF @Dept_ID = '0' or @Dept_ID=''      
  set @Dept_ID = null    
    
 IF @Desig_ID = '0' or @Desig_ID=''     
  set @Desig_ID = null    
    
 IF @Emp_ID = 0      
  set @Emp_ID = null    
    
 ----IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 06-10-2015    
 ---- set @PBranch_ID = null        
      
 ----if @PVertical_ID ='0' or @PVertical_ID = ''  --Added By Jaina 06-10-2015    
 ---- set @PVertical_ID = null    
    
 ----if @PsubVertical_ID ='0' or @PsubVertical_ID = '' --Added By Jaina 06-10-2015    
 ---- set @PsubVertical_ID = null    
      
 ----IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 06-10-2015    
 ---- set @PDept_ID = NULL      
    
 Declare @Sal_St_Date   Datetime        
 Declare @Sal_end_Date   Datetime        
 --Added By Jaina 06-10-2015 Start      
 if @Branch_ID is null    
 Begin     
  select   @Branch_ID = COALESCE(@Branch_ID + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID     
  set @Branch_ID = @Branch_ID + '#0'    
 End    
    
 If @Branch_ID is null    
  Begin     
     
   select Top 1 @Sal_St_Date  = Sal_st_Date     
     from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID        
     and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)        
  End    
 Else    
  Begin    
       
   select @Sal_St_Date  =Sal_st_Date     
     from T0040_GENERAL_SETTING As G1 WITH (NOLOCK)    
     inner JOIN (Select Branch_ID, Max(For_Date) As For_Date FROM dbo.Split(@Branch_ID,'#') S --- Change by Hardik 21/08/2019 for Mantis Bug Id : 0008055    
       Inner Join T0040_GENERAL_SETTING G WITH (NOLOCK) On Cast(S.data as numeric)=G.Branch_ID    
      Group By Branch_ID    
     ) T ON T.Branch_ID=G1.Branch_ID And T.For_Date = G1.For_Date    
     where cmp_ID = @cmp_ID     
     --and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)             
   --select @Sal_St_Date  =Sal_st_Date     
   --  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID        
   --  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)        
         
         
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
     set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)        
     set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))    
     set @From_Date = @Sal_St_Date    
     Set @To_Date = @Sal_end_Date       
  End      
     
 ----if @PVertical_ID is null    
 ----Begin     
 ---- select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment where Cmp_ID=@Cmp_ID     
      
 ---- If @PVertical_ID IS NULL    
 ----  set @PVertical_ID = '0';    
 ---- else    
 ----  set @PVertical_ID = @PVertical_ID + ',0'    
 ----End    
 ----if @PsubVertical_ID is null    
 ----Begin     
 ---- select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical where Cmp_ID=@Cmp_ID     
 ---- If @PsubVertical_ID IS NULL    
 ----  set @PsubVertical_ID = '0';    
 ---- else    
 ----  set @PsubVertical_ID = @PsubVertical_ID + ',0'    
 ----End    
 ----IF @PDept_ID is null    
 ----Begin    
 ---- select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID       
 ---- if @PDept_ID is null    
 ----  set @PDept_ID = '0';    
 ---- else    
 ----  set @PDept_ID = @PDept_ID + ',0'    
 ----End    
 --Added By Jaina 6-10-2015 End    
     
     
 --Declare #Emp_Cons Table    
 --(    
 -- Emp_ID numeric    
 --)    
     
 CREATE table #Emp_Settlement    
 (    
  Emp_ID numeric,    
  For_Date Datetime,    
  M_AD_Calculate_Amount Numeric(18,2),    
  M_AD_Percentage Numeric(18,2),    
  M_AD_Amount Numeric(18,2)    
 )    
    
    
 CREATE TABLE #Emp_Cons -- Ankit 09092014 for Same Date Increment    
  (          
    Emp_ID numeric ,         
    Branch_ID numeric,    
    Increment_ID numeric        
  )       
  --Comment By Jaina 19-10-2015    
  --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id     
  
    
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_ID,@SubVertical_ID,'',0,0,0,'0',0,0  --Added By Jaina 19-10-2015    
    
  
  
 --if @Constraint <> ''    
 -- begin    
 --  Insert Into #Emp_Cons    
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')     
 -- end    
 --else    
 -- begin    
       
       
 --  Insert Into #Emp_Cons    
    
 --  select I.Emp_Id from T0095_Increment I inner join     
 --    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment    
 --    where Increment_Effective_date <= @To_Date    
 --    and Cmp_ID = @Cmp_ID    
 --    group by emp_ID  ) Qry on    
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
           
 --  Where Cmp_ID = @Cmp_ID     
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
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
      
     
     
 --Added By Jaina 21-10-2015 Start    
   SELECT G.Branch_ID, G.Sal_st_Date, DATEADD(m, 1, G.Sal_st_Date) As Sal_End_Date,G.ESIC_EMPLOYER_CONTRIBUTION    
   INTO #GEN    
   FROM (    
      SELECT G1.Branch_ID,G1.ESIC_Employer_Contribution,    
       (CASE WHEN DAY(Sal_st_Date) > 1 THEN DATEADD(M,-1, DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date)) ELSE DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date) END ) AS Sal_st_Date     
      FROM T0040_GENERAL_SETTING G1 WITH (NOLOCK)    
        --inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=G1.Branch_ID    
        INNER JOIN (SELECT DISTINCT BRANCH_ID FROM #Emp_Cons E)  T ON T.Branch_ID=G1.Branch_ID --Changed by Ramiz on 24/04/2017 as from Admin Side Arrears was not Calculating     
      WHERE For_Date = (    
            SELECT Max(For_Date) FROM T0040_GENERAL_SETTING G2 WITH (NOLOCK)    
            --inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T1 ON T1.Branch_ID=G2.Branch_ID    
            WHERE For_Date < @To_Date and G1.Branch_id=G2.Branch_ID AND G1.Cmp_ID=G2.Cmp_ID    
           ) AND G1.Cmp_ID=@Cmp_ID    
   ) G      
     
 --Added By Jaina 21-10-2015 End    
       
    
     
 --Added By Jaina 7-10-2015 Start    
 --DELETE FROM #Emp_Cons    
 --WHERE NOT EXISTS (    
 --    select  E.Emp_ID     
 --    from #Emp_Cons as  E Inner JOIN T0095_INCREMENT as i ON i.Increment_ID = E.Increment_ID    
 --    where EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))    
 --      and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))    
 --      and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))    
 --      and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0))      
 --      AND #Emp_Cons.Increment_ID = E.Increment_ID    
 --   )    
 --Added By Jaina 7-10-2015 End    
     
  -----By Hardik 10/06/2013 for Salary Settlement Adding in ESIC Statement -----------    
 --Change By Jaina 21-10-2015    
 If Exists(Select S_Sal_Tran_Id From dbo.T0201_MONTHLY_SALARY_SETT as s WITH (NOLOCK)    
          inner join T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID=s.Increment_ID    
          INNER JOIN #Gen as G ON G.Branch_Id=i.Branch_ID    
           where S_Eff_Date Between G.Sal_st_Date And G.Sal_End_Date And S.Cmp_Id=@Cmp_Id)    
 BEGIN     
  INSERT INTO #Emp_Settlement    
  SELECT  SG.EMP_ID, @From_Date as For_Date, sum(M_AD_Calculated_Amount),0 AS ESIC_PER, sum(ESIC_Amount)  --changed by Jimit As per HMP case of settlement (calculate differenet Rate in April and Aug)    
  FROM T0201_MONTHLY_SALARY_SETT  SG  WITH (NOLOCK)    
  INNER JOIN     
   ( SELECT For_Date, Emp_ID, M_AD_Percentage as ESIC_PER, (M_AD_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_cutoff,0)) as ESIC_Amount,  --M_AD_Amount * 100 / M_AD_Percentage as M_AD_Calculated_Amount,    
    M_AD_Calculated_Amount,S_Sal_Tran_ID  --Changed By Ramiz on 04/12/2018    
    --SAL_TRAN_ID     
     FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)    
    INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID      
     WHERE AD_DEF_ID = @AD_Def_ID And ad_not_effect_salary <> 1 And ad.sal_type=1    
     and AD.CMP_ID = @CMP_ID    
    ) MAD on SG.Emp_ID = MAD.Emp_ID and SG.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID --AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID     
  INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID    
  INNER JOIN #Emp_Cons E_S on E.Emp_ID = E_S.Emp_ID     
  WHERE   E.CMP_ID = @CMP_ID And S_Eff_Date Between @From_Date And @To_Date    
  GROUP BY SG.EMP_ID--,ESIC_PER    
 END      
--------------------------------------------------End----------------------------------------------    
    
     
 --select TOP 1 @EMPLOYER_CONT_PER =ESIC_EMPLOYER_CONTRIBUTION    
 -- from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = ISNULL(@Branch_ID,Branch_ID)    
 -- and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@tO_DATE and Branch_ID = isnull(@Branch_ID,Branch_ID) and Cmp_ID = @Cmp_ID)    
 --Added By Jaina 21-10-2015    
     
 /*    
 select TOP 1 @EMPLOYER_CONT_PER =ESIC_EMPLOYER_CONTRIBUTION    
  from T0040_GENERAL_SETTING as G    
  inner JOIN #Gen as G1 ON G1.Branch_Id=G.Branch_ID  where cmp_ID = @cmp_ID and G.Branch_ID = ISNULL(G1.Branch_ID,G.Branch_ID)    
  and For_Date = ( select max(Sal_st_Date) from T0040_GENERAL_SETTING where For_Date <=G1.Sal_End_Date and G.Branch_ID = isnull(G1.Branch_ID,G.Branch_ID) and Cmp_ID = @Cmp_ID )    
 */    
      
 --select @Emp_Share_Cont_Amount = sum(Emp_Cont_Amount) ,     
 --    @Employer_Share_Cont_Amount = sum(Employer_Cont_Amount)     
 --From T0220_ESIC_Challan ec Where ec.Cmp_ID = @Cmp_ID and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) >= @From_date and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) <= @To_Date and     
 --isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0))    
 --set @Total_Share_Cont_amount =  @Emp_Share_Cont_Amount + @Employer_Share_Cont_Amount    
      
  --Added By Jaina 21-10-2015     
 select @Emp_Share_Cont_Amount = sum(Emp_Cont_Amount) ,     
     @Employer_Share_Cont_Amount = sum(Employer_Cont_Amount)     
 From T0220_ESIC_Challan ec WITH (NOLOCK)    
 inner JOIN #Gen as G1 on G1.Branch_Id=ec.Branch_ID    
 Where ec.Cmp_ID = @Cmp_ID and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) >= G1.Sal_st_Date and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) <= G1.Sal_End_Date and     
 isnull(Ec.Branch_ID,0) = isnull(G1.Branch_Id ,isnull(Ec.Branch_ID,0))    
 set @Total_Share_Cont_amount =  @Emp_Share_Cont_Amount + @Employer_Share_Cont_Amount      
     
     
  Declare @Count as numeric(18,0)    
    
  Declare @Ad_ID as numeric(18,0)    
    
      
      
select @Ad_ID=AD_ID  from T0050_AD_MASTER WITH (NOLOCK) where AD_DEF_ID=@AD_Def_ID and AD_not_effect_salary <>1 and CMP_ID=@Cmp_ID      
    
Declare @Non_Coun as numeric(18,0)    
Declare @Non_Coun_Gross as numeric(22,0)     
Declare @New_Emp_ID as numeric(18,0)    
set @Non_Coun=0    
declare curAD cursor for                        
select Distinct(Emp_ID) from #Emp_Cons     
 where Emp_ID not in(    
 Select MAD.Emp_ID    
   From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join     
     T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN     
  T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN     
   #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join     
     T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.SAL_tRAN_ID = MS.SAL_TRAN_ID INNER JOIN     
     T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID inner join    
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join     
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID INNER JOIN     
     T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MAD.CMP_ID = CM.CMP_ID      
  WHERE E.Cmp_ID = @Cmp_Id  and For_date >=@From_Date and For_date <=@To_Date    
    and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_not_effect_salary <>1 And sal_type<>1)    
     
 open curAD                          
  fetch next from curAD into @New_Emp_ID    
  while @@fetch_status = 0                        
   begin     
               if isnull(@Ad_ID,0) <> 0    
    BEgin    
     declare @New_ad_ID as numeric(18,0)    
     declare curAD_sub cursor for               
      select ad_id from T0060_EFFECT_AD_MASTER WITH (NOLOCK) where cmp_id=@Cmp_ID and Effect_ad_id=@ad_id    
     open curAD_sub                          
     fetch next from curAD_sub into @New_ad_ID    
      while @@fetch_status = 0                        
      begin     
       declare @ad_amount as numeric(22,0)    
       set @ad_amount=0    
       select @ad_amount = SUM(isnull(M_ad_amount,0)) from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where Emp_ID=@New_Emp_ID And AD_ID=@New_ad_ID and For_Date >=@From_Date and For_Date<=@To_Date     
       set @Non_Coun_Gross=isnull(@Non_Coun_Gross,0) + isnull(@ad_amount,0)    
      fetch next from curAD_sub into @New_ad_ID    
            end                        
     close curAD_sub                        
     deallocate curAD_sub    
    End    
        
               set @Non_Coun = @Non_Coun + 1    
     fetch next from curAD into @New_Emp_ID    
                      
  end                        
 close curAD                        
 deallocate curAD        
      
  Select @Count=isnull(count(Distinct(MAD.Emp_ID)),0)    
   From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join     
     T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN     
   T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN     
   #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join     
     T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.SAL_tRAN_ID = MS.SAL_TRAN_ID INNER JOIN     
     T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID inner join    
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join     
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID INNER JOIN     
     T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MAD.CMP_ID = CM.CMP_ID      
  WHERE E.Cmp_ID = @Cmp_Id  and For_date >=@From_Date and For_date <=@To_Date And MAD.M_AD_Amount>0    
    and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_not_effect_salary <>1 And sal_type<>1    
     
     
 --IF @Flag_For_Total=1     
 IF @Flag_For_Total=1  
  Begin      
     
 -- Changed By Ali 25112013 EmpName_Alias    
   Select Distinct M_AD_Tran_ID,MAD.Sal_Tran_ID,S_Sal_Tran_ID,L_Sal_Tran_ID,MAD.Emp_ID,MAD.Cmp_ID,MAD.AD_ID,MAD.For_Date,    
     MAD.M_AD_Percentage,MAD.M_AD_Amount + ISNULL(ES.M_AD_Amount,0) + Isnull(MAD.M_AREAR_AMOUNT,0)+ Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0) + ISNULL(ESICNT.Esic,0) as M_AD_Amount,    
     MAD.M_AD_Flag,MAD.M_AD_Actual_Per_Amount, --M_AREAR_AMOUNT Ankit 13012014    
     MAD.M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0) + Isnull(Arear_Calc_Amount,0) +     
     ISNULL(MS.Arear_Basic,0)+ ISNULL(MS.Basic_Salary_Arear_cutoff ,0) + ISNULL(ESICNT.Amount,0) as M_AD_Calculated_Amount,    
     MAD.Temp_Sal_Tran_ID,MAD.M_AD_NOT_EFFECT_ON_PT,MAD.M_AD_NOT_EFFECT_SALARY,MAD.M_AD_EFFECT_ON_OT,    
     MAD.M_AD_EFFECT_ON_EXTRA_DAY,MAD.Sal_Type,MAD.M_AD_EFFECT_DATE,MAD.M_AD_EFFECT_ON_LATE,MAD.M_AREAR_AMOUNT,    
     MAD.FOR_FNF,MAD.To_date,    
     isnull(@Count,0) as Total_Emp_Count,ISNULL(EmpName_Alias_ESIC,Emp_Full_Name) as Emp_full_Name,Date_Of_Join,E.Emp_Left_Date,Grd_Name,Alpha_Emp_Code as Emp_code,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL    
     ,G.ESIC_EMPLOYER_CONTRIBUTION as EMPLOYER_CONT_PER ,CMP_NAME,CMP_ADDRESS,Cm.ESic_No as Cmp_ESIC_No    
     ,SIN_NO AS ESIC_NO ,Month(MAD.To_Date) as Month ,Year(MAD.To_Date) as Year    
     --,ceiling(@EMPLOYER_CONT_PER * M_AD_Calculated_Amount /100)EMPLOYER_CONT_AMOUNT    
     --,round(@EMPLOYER_CONT_PER * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100,2)EMPLOYER_CONT_AMOUNT    
     ,ceiling(G.ESIC_EMPLOYER_CONTRIBUTION  * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100)EMPLOYER_CONT_AMOUNT --Ankit 13012014     
     ,MS.SAL_CAL_DAYS,DAY_SALARY , @From_Date as P_From_Date , @To_Date as P_To_Date    
     ,@Emp_Share_Cont_Amount  Emp_Share_Cont_Amount , @Employer_Share_Cont_Amount Employer_Share_Cont_Amount    
     ,@Total_Share_Cont_amount Total_Share_cont_Amount , dbo.F_Number_TO_Word(@Total_Share_Cont_amount) Total_share_Cont_Amount_In_Word,@Non_Coun as Non_Contribution,@Non_Coun_Gross as Non_Contribution_Gross    
     ,BM.Branch_Name    
     ,sb.SubBranch_Name    
     ,E.Alpha_Emp_Code,E.Emp_First_Name   --added jimit 15062015    
     ,VS.Vertical_Name,SV.SubVertical_Name    
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join     
       T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN     
    T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN     
     #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join     
       T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID INNER JOIN     
       T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID inner join    
       T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
       T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
       T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
       T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join     
       T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID left outer JOIN     
       #Gen G on G.Branch_Id= I_Q.Branch_ID Inner JOIN   --Jaina 21-10-2015    
       T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MAD.CMP_ID = CM.CMP_ID  Left Outer Join    
       #Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date Left Outer Join    
       (Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID --Ankit 13012014    
        From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)    
        Where AD_ID in (    
         Select AD_ID from T0060_EFFECT_AD_MASTER WITH (NOLOCK)    
         where CMP_ID=@Cmp_ID and EFFECT_AD_ID = (    
          select top 1 AD_ID From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID     
          and AD_DEF_ID=@AD_Def_ID))    
        and ( M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <>0 )    
        and For_Date >=@From_Date and For_Date <=@To_Date    
        Group by Emp_ID) Qry on    
        Ec.Emp_ID = Qry.Emp_ID left join     
        T0050_SubBranch SB WITH (NOLOCK) on I_Q.subBranch_ID =SB.SubBranch_ID Left join    
       -- T0210_ESIC_ON_NOT_EFFECT_ON_SALARY ESICNT on ESICNT.For_Date=MAD.To_date and ESICNT.Emp_Id=MAD.Emp_ID left join --and ESICNT.Ad_Id=MAD.AD_ID    
         (select For_Date,emp_id,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount     
         from T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  WITH (NOLOCK) group by emp_id,For_Date)    
         ESICNT on month(ESICNT.For_Date)=month(MAD.To_date) and year(ESICNT.For_Date) = year(MAD.To_date)  and ESICNT.Emp_Id=MAD.Emp_ID left join -- comment and added by rohit on 26042016    
        T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I_Q.Vertical_ID left join    
        T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=I_Q.SubVertical_ID    
            
    
    WHERE E.Cmp_ID = @Cmp_Id and month(MAD.For_Date) = month(@To_Date) and YEAR(MAD.For_Date)= year(@To_Date) --MAD.For_Date >=@From_Date and MAD.For_Date <=@To_Date    
      and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_NOT_EFFECT_SALARY <>1 And Sal_Type<>1     
      and MAD.M_AD_Amount > 0  --Added by Jaina 11-09-2017 after discuss with Hardikbhai    
       order by SIN_NO asc    
   End    
 Else  
   Begin    
   -- Changed By Ali 25112013 EmpName_Alias    
   Select Distinct M_AD_Tran_ID,MAD.Sal_Tran_ID,S_Sal_Tran_ID,L_Sal_Tran_ID,MAD.Emp_ID,MAD.Cmp_ID,MAD.AD_ID,MAD.For_Date,    
     MAD.M_AD_Percentage,MAD.M_AD_Amount + ISNULL(ES.M_AD_Amount,0) + Isnull(MAD.M_AREAR_AMOUNT,0) + Isnull(MAD.M_AREAR_AMOUNT_cutoff,0) as M_AD_Amount,MAD.M_AD_Flag,MAD.M_AD_Actual_Per_Amount, --M_AREAR_AMOUNT Ankit 13012014    
     MAD.M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0) + Isnull(Arear_Calc_Amount,0) + ISNULL(MS.Arear_Basic,0)+ ISNULL(MS.Basic_Salary_Arear_cutoff,0) as M_AD_Calculated_Amount,    
     MAD.Temp_Sal_Tran_ID,MAD.M_AD_NOT_EFFECT_ON_PT,MAD.M_AD_NOT_EFFECT_SALARY,MAD.M_AD_EFFECT_ON_OT,    
     MAD.M_AD_EFFECT_ON_EXTRA_DAY,MAD.Sal_Type,MAD.M_AD_EFFECT_DATE,MAD.M_AD_EFFECT_ON_LATE,MAD.M_AREAR_AMOUNT,    
     MAD.FOR_FNF,MAD.To_date,    
     isnull(@Count,0) as Total_Emp_Count,ISNULL(EmpName_Alias_ESIC,Emp_Full_Name) as Emp_full_Name,Date_Of_Join,E.Emp_Left_Date,Grd_Name,Alpha_Emp_Code as Emp_code,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL    
     ,G.ESIC_EMPLOYER_CONTRIBUTION as EMPLOYER_CONT_PER ,CMP_NAME,CMP_ADDRESS,Cm.ESic_No as Cmp_ESIC_No    
     ,SIN_NO AS ESIC_NO ,Month(MAD.To_Date) as Month ,Year(MAD.To_Date) as Year    
     --,ceiling(@EMPLOYER_CONT_PER * M_AD_Calculated_Amount /100)EMPLOYER_CONT_AMOUNT    
     --,round(@EMPLOYER_CONT_PER * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100,2)EMPLOYER_CONT_AMOUNT    
     ,ceiling(G.ESIC_EMPLOYER_CONTRIBUTION * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100)EMPLOYER_CONT_AMOUNT --Ankit 13012014    
     ,MS.SAL_CAL_DAYS,DAY_SALARY , @From_Date as P_From_Date , @To_Date as P_To_Date    
     ,@Emp_Share_Cont_Amount  Emp_Share_Cont_Amount , @Employer_Share_Cont_Amount Employer_Share_Cont_Amount    
     ,@Total_Share_Cont_amount Total_Share_cont_Amount , dbo.F_Number_TO_Word(@Total_Share_Cont_amount) Total_share_Cont_Amount_In_Word,@Non_Coun as Non_Contribution,@Non_Coun_Gross as Non_Contribution_Gross    
     ,BM.Branch_Name    
     ,sb.SubBranch_Name    
     ,E.Alpha_Emp_Code,E.Emp_First_Name   --added jimit 15062015    
     ,VS.Vertical_Name,SV.SubVertical_Name    
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join     
       T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN     
    T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN     
     #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join     
       T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID INNER JOIN     
       --T0095_INCREMENT I_Q ON MS.INCREMENT_ID = I_Q.INCREMENT_ID inner join COMMENTED BY RAJPUT ON 19042018 TRANSFER CASE PROBLEM - SUBBRANCH NAME WAS WRONG (CERA CLIENT)     
       T0095_INCREMENT INQ WITH (NOLOCK) ON EC.INCREMENT_ID = INQ.INCREMENT_ID INNER JOIN             
       T0040_GRADE_MASTER GM WITH (NOLOCK) ON INQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
       T0040_TYPE_MASTER ETM WITH (NOLOCK) ON INQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
       T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON INQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
       T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INQ.Dept_Id = DM.Dept_Id Inner join     
       T0030_Branch_Master BM WITH (NOLOCK) on INQ.Branch_ID = BM.Branch_ID left outer JOIN     
       #Gen G ON G.Branch_Id=INQ.Branch_ID INNER JOIN  --Added By Jaina 21-10-2015    
       T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MAD.CMP_ID = CM.CMP_ID  Left Outer Join    
       #Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date Left Outer Join    
       (Select isnull(SUM(M_AREAR_AMOUNT),0) + isnull(SUM(M_AREAR_AMOUNT_Cutoff),0) as Arear_Calc_Amount,Emp_ID --Ankit 13012014    
        From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)    
        Where AD_ID in (    
         Select AD_ID from T0060_EFFECT_AD_MASTER WITH (NOLOCK)    
         where CMP_ID=@Cmp_ID and EFFECT_AD_ID = (    
          select top 1 AD_ID From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID     
          and AD_DEF_ID=@AD_Def_ID))    
        and (M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_cutoff <>0 )    
        and For_Date >=@From_Date and For_Date <=@To_Date    
        Group by Emp_ID) Qry on    
        Ec.Emp_ID = Qry.Emp_ID left join     
        T0050_SubBranch SB WITH (NOLOCK) on INQ.subBranch_ID =SB.SubBranch_ID left join    
        T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=INQ.Vertical_ID left join    
        T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=INQ.SubVertical_ID    
    
    
    WHERE E.Cmp_ID = @Cmp_Id and MAD.For_Date >=@From_Date and MAD.For_Date <=@To_Date    
      and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_NOT_EFFECT_SALARY <>1 And Sal_Type<>1    
      and MAD.M_AD_Amount > 0  --Added by Jaina 11-09-2017 after discuss with Hardikbhai    
       order by SIN_NO asc    
   
ENd  
   
 return