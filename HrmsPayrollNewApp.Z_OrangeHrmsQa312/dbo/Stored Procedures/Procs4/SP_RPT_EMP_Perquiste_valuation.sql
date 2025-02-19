


CREATE PROCEDURE [dbo].[SP_RPT_EMP_Perquiste_valuation]
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(max) = ''  
 ,@New_Join_emp numeric = 0   
 ,@Left_Emp  Numeric = 0  
 ,@Salary_Cycle_id numeric = NULL  
 ,@Segment_Id  numeric = 0    
 ,@Vertical_Id numeric = 0    
 ,@SubVertical_Id numeric = 0    
 ,@SubBranch_Id numeric = 0   
 ,@F_Year  nvarchar(20) = ''   
AS  
 Set Nocount on   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
  
 if @Salary_Cycle_id = 0  
  set @Salary_Cycle_id =NULL  
  
 if @Branch_ID = 0  
  set @Branch_ID = null  
 if @Cat_ID = 0  
  set @Cat_ID = null  
     
 if @Type_ID = 0  
  set @Type_ID = null  
 if @Dept_ID = 0  
  set @Dept_ID = null  
 if @Grd_ID = 0  
  set @Grd_ID = null  
 if @Emp_ID = 0  
  set @Emp_ID = null  
    
 If @Desig_ID = 0  
  set @Desig_ID = null  
   
 If @Segment_Id = 0     
 set @Segment_Id = null  
 If @Vertical_Id = 0     
 set @Vertical_Id = null  
 If @SubVertical_Id = 0    
 set @SubVertical_Id = null   
 If @SubBranch_Id = 0    
 set @SubBranch_Id = null   
 Declare @Total_earning_Accom as Float  
 set @Total_earning_Accom = 0  
 Declare @Perqusite_Value_accom as float  
 set @Perqusite_Value_accom = 0  
 Declare @Total_earning_Leased_Accom as float  
 set @Total_earning_Leased_Accom = 0  
 Declare @FifteenPerEarning as float  
 set @FifteenPerEarning = 0  
 Declare @Perqusite_Value_accom_Leased as float  
 set @Perqusite_Value_accom_Leased = 0   
 Declare @Start_FYear as Int  
 Declare @End_FYear as Int  
 set @Start_FYear = 0  
 set @End_FYear = 0  
   
 if len(@F_Year) = 9  
 begin  
  set @Start_FYear = SUBSTRING(@F_Year,0,5)  
  set @End_FYear = SUBSTRING (@F_Year,6,10)  
 end  
      
 DECLARE @Show_Left_Employee_for_Salary AS TINYINT  
  SET @Show_Left_Employee_for_Salary = 0  
  
  SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0)   
  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'  
  
   
 Create table #Emp_Cons   
 (        
  Emp_ID numeric ,       
  Branch_ID numeric,  
  Increment_ID numeric      
 )        
   
   
 if @Constraint <> ''  
  begin  
   Insert Into #Emp_Cons  
   Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#')   
  end  
 else if @New_Join_emp = 1   
  begin  
  
   Insert Into #Emp_Cons        
   Select distinct emp_id,branch_id,Increment_ID   
   From V_Emp_Cons Where Cmp_id=@Cmp_ID   
    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
    and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
    and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
    and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
    and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))   
    and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))    
    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))   
    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))   
    and Emp_ID = isnull(@Emp_ID ,Emp_ID)    
    and Increment_Effective_Date <= @To_Date   
    and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date  
   Order by Emp_ID  
        
   Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment WITH (NOLOCK)  
   Where  Increment_effective_Date <= @to_date Group by emp_ID)  
  
  end  
 else if @Left_Emp = 1   
  begin  
  
   Insert Into #Emp_Cons        
   Select distinct emp_id,branch_id,Increment_ID   
   From V_Emp_Cons Where Cmp_id=@Cmp_ID   
    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
    and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
    and Grd_ID = isnull(@Grd_ID ,Grd_ID)            and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
    and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))     
    and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))     
    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))   
    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))   
    and Emp_ID = isnull(@Emp_ID ,Emp_ID)    
    and Increment_Effective_Date <= @To_Date   
    and Left_date >=@From_Date and Left_Date <=@to_Date  
   Order by Emp_ID  
        
   Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment WITH (NOLOCK)  
   Where  Increment_effective_Date <= @to_date Group by emp_ID)  
  end    
 else   
  begin  
  
     
   Insert Into #Emp_Cons        
        select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons   
          left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)  
       inner join   
       (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date  
       GROUP BY emp_id) Qry  
       on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC  
         ON QrySC.eid = V_Emp_Cons.Emp_ID  
    where   
       cmp_id=@Cmp_ID   
         and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
     and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
     and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
     and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
     and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
     and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))   
     and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))    
     and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))         
     and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))   
     and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))    
     and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))   
     and Emp_ID = isnull(@Emp_ID ,Emp_ID)     
        and Increment_Effective_Date <= @To_Date   
        and   
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )        
      or ( @To_Date  >= join_Date  and @To_Date <= left_date )        
      or (Left_date is null and @To_Date >= Join_Date)        
      or (@To_Date >= left_date  and  @From_Date <= left_date )  
      OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)  
      )   
      order by Emp_ID  
        
   delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)  
   where  Increment_effective_Date <= @to_date  
   group by emp_ID)   
  end  
    
    
   -- Added By Ali 20012014 -- Start  
     
   IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#perquisites_Details')  
   BEGIN  
    DROP TABLE #perquisites_Details  
   END    
     
   CREATE table #perquisites_Details  
   (  
      
    cmp_id numeric,  
    emp_id numeric,  
    fin_year nvarchar(50),  
    Gross_Salary numeric(18,2) default 0,  
    Total_Exp numeric(18,2) default 0  
   )   
     
   insert into #perquisites_Details  
   exec Rpt_Emp_Perquisites @Cmp_ID=@Cmp_Id,@From_Date=@From_Date  
   ,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID  
   ,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID  
   ,@Constraint=@Constraint  
   ,@Product_ID=0,@Taxable_Amount_Cond=0,@Form_ID=1,@F_Year = @F_Year  
   --Select * from #perquisites_Details  
   -- Added By Ali 20012014 -- End  
     
     
     
   IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#Final_Table')  
   BEGIN  
    DROP TABLE #Final_Table  
   END    
     
   CREATE table #Final_Table  
   (  
    Emp_ID numeric,  
    Cmp_Id numeric,  
    Emp_Code varchar(50),  
    Employee_Name varchar(500),  
    Financial_Year varchar(50),  
	Regime varchar(20), 
    Accom_Provided_in_Colony tinyint,  
    Accom_Provided_From datetime,  
    Accom_Provided_To datetime,  
    Leased_Accom tinyint,  
    Leased_Accom_From datetime,  
    Leased_Accom_To datetime,  
    Total_earning_Accom numeric(18,2),  
    Perqusite_Value_accom numeric(18,2),  
    Jan numeric(18,2),  
    Feb numeric(18,2),  
    Mar numeric(18,2),  
    Apr numeric(18,2),  
    May numeric(18,2),  
    Jun numeric(18,2),  
    Jul numeric(18,2),  
    Aug numeric(18,2),  
    Sep numeric(18,2),  
    Oct numeric(18,2),  
    Nov numeric(18,2),  
    Dec numeric(18,2),  
    Total_Leased_Accom_Rent numeric(18,2),  
    Total_earning_Leased_Accom numeric(18,2),  
    Total_15_Per_Earning numeric(18,2),  
    Perqusite_Value_accom_Leased numeric(18,2),  
    Total_Furnish_Amt numeric(18,2),  
    Perqusite_Value_For_Furniture numeric(18,2),   
    Perqusite_Value_For_GEW numeric(18,2),  
    Perqusite_Value_For_Car numeric(18,2),  
    Total_Perq_Amount numeric(18,2),  
    Change_Date datetime
   )   
     
   Insert into #Final_Table   
    Select Distinct   
    E.Emp_ID  
   ,E.Cmp_ID  
   ,E.Alpha_Emp_Code as Emp_Code  
   ,E.Emp_Full_Name as Employee_Name  
   ,ISNULL(PE.Financial_Year,ISNULL(PEC.Financial_Year,ISNULL(PEGEW.Financial_Year,@F_Year))) as Financial_Year  
   ,case when ITR.Regime = 'Tax Regime 2' then 'New Regime' else 'Old Regime'end as Regime
   ,ISNULL(PE.On_Rent,0) as  Accom_Provided_in_Colony  
   ,case when PE.On_Rent = 1 then PE.On_Rent_From else NULL end as Accom_Provided_From   
   ,case when PE.On_Rent = 1 then PE.On_Rent_To else Null end as Accom_Provided_To   
   ,ISNULL(PE.Cmp_Quarter,0) as Leased_Accom  
   ,case when PE.Cmp_Quarter = 1 then PE.Cmp_Quarter_From else Null end as  Leased_Accom_From   
   ,case when PE.Cmp_Quarter = 1 then PE.Cmp_Quarter_To else Null end as Leased_Accom_To   
   ,@Total_earning_Accom as Total_earning_Accom   
   ,@Perqusite_Value_accom as Perqusite_Value_accom  
   ,ISNULL(PEB.Jan,0.0) as Jan  
   ,ISNULL(PEB.Feb,0.0) as Feb  
   ,ISNULL(PEB.Mar,0.0) as Mar  
   ,ISNULL(PEB.Apr,0.0) as Apr  
   ,ISNULL(PEB.May,0.0) as May  
   ,ISNULL(PEB.Jun,0.0) as Jun  
   ,ISNULL(PEB.Jul,0.0) as Jul  
   ,ISNULL(PEB.Aug,0.0) as Aug  
   ,ISNULL(PEB.Sep,0.0) as Sep  
   ,ISNULL(PEB.Oct,0.0) as Oct  
   ,ISNULL(PEB.Nov,0.0) as Nov  
   ,ISNULL(PEB.Dec,0.0) as Dec  
   ,(ISNULL(PEB.Jan,0.0) + ISNULL(PEB.Feb,0.0) + ISNULL(PEB.Mar,0.0) + ISNULL(PEB.Apr,0.0) + ISNULL(PEB.May,0.0) + ISNULL(PEB.Jun,0.0) + ISNULL(PEB.Jul,0.0) + ISNULL(PEB.Aug,0.0) + ISNULL(PEB.Sep,0.0) + ISNULL(PEB.Oct,0.0) + ISNULL(PEB.Nov,0.0) + ISNULL(PEB.Dec,0.0)) as Total_Leased_Accom_Rent  
   ,@Total_earning_Leased_Accom as Total_earning_Leased_Accom   
   ,@FifteenPerEarning as Total_15_Per_Earning   
   ,@Perqusite_Value_accom_Leased as Perqusite_Value_accom_Leased   
   ,ISNULL(PE.Total_Furnish_Amt,0.0) as Total_Furnish_Amt  
   ,ROUND(ISNULL(PE.Total_Furnish_Amt,0.0) * 10 / 100,0) as Perqusite_Value_For_Furniture  
   ,ISNULL(PEGEW.Total_Amount,0.0) as Perqusite_Value_For_GEW  
   ,ISNULL(PEC.Total_perq_Amt,0.0) as Perqusite_Value_For_Car  
   ,(isnull(@Perqusite_Value_accom,0.0) + isnull(@Perqusite_Value_accom_Leased,0.0) + isnull(PE.Total_Furnish_Amt,0.0) + isnull(PEGEW.Total_Amount,0.0) + isnull(PEC.Total_perq_Amt,0.0)) as Total_Perq_Amount   
   ,ISNULL(PE.Change_Date,ISNULL(PEC.Change_Date,ISNULL(PEGEW.ChangeDate,''))) as Change_Date
   from dbo.T0080_EMP_MASTER E WITH (NOLOCK)   
   left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID   
   inner join  
   (select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf  from dbo.T0095_Increment I WITH (NOLOCK) inner join   
     ( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) -- Ankit 11092014 for Same Date Increment  
     where Increment_Effective_date <= @To_Date  
     and Cmp_ID = @Cmp_ID  
     group by emp_ID  ) Qry on  
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
     on E.Emp_ID = I_Q.Emp_ID    
   Inner join dbo.T0040_GENERAL_SETTING GS WITH (NOLOCK) on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID  INNER JOIN  
     ( SELECT MAX(FOR_DATE) AS FOR_DATE,BRANCH_ID FROM T0040_GENERAL_SETTING GS1 WITH (NOLOCK) --Ankit 27092014  
      WHERE FOR_DATE <= @TO_DATE AND CMP_ID = @CMP_ID GROUP BY BRANCH_ID  
     ) QRY1 ON GS.BRANCH_ID = QRY1.BRANCH_ID AND GS.FOR_DATE = QRY1.FOR_DATE   
   Left outer join dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID    
   Inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID    
   left outer join T0240_Perquisites_Employee PE WITH (NOLOCK) on E.Emp_ID = PE.Emp_id and Financial_Year = @F_Year  
   left outer join ( select Distinct  PEM.Perq_Tran_Id,Jan.Jan,Feb.Feb,Mar.Mar,Apr.Apr,MAy.May,Jun.Jun,Jul.Jul,Aug.Aug,Sep.Sep,Oct.Oct,Nov.Nov,Dec.Dec from T0250_Perquisites_Employee_Monthly_Rent PEM WITH (NOLOCK) inner join  
       (select case when month = 1 then ISNULL(Amount,0) end as Jan, Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK) where Year >= @Start_FYear and Year <= @End_FYear  and Month = 1) jan  on  Jan.Perq_Tran_Id = PEM.Perq_Tran_Id inner join   
       (select case when month = 2 then ISNULL(Amount,0) end as Feb,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 2) Feb on  Feb.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
       (select case when month = 3 then ISNULL(Amount,0) end as Mar,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 3) Mar on  Mar.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
       (select case when month = 4 then ISNULL(Amount,0) end as Apr,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 4) Apr on  Apr.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
          (select case when month = 5 then ISNULL(Amount,0) end as May,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 5) May on  MAy.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
                            (select case when month = 6 then ISNULL(Amount,0) end as Jun,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 6) Jun on  Jun.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
                            (select case when month = 7 then ISNULL(Amount,0) end as Jul,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 7) Jul on  Jul.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
                            (select case when month = 8 then ISNULL(Amount,0) end as Aug,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear  and Month = 8) Aug on  Aug.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
       (select case when month = 9 then ISNULL(Amount,0) end as Sep,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)   where Year >= @Start_FYear and Year <= @End_FYear   and Month = 9) Sep on  Sep.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
       (select case when month = 10 then ISNULL(Amount,0) end as Oct,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear and Month = 10) Oct on  Oct.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
       (select case when month = 11 then ISNULL(Amount,0) end as Nov,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear and Month = 11) Nov on  Nov.Perq_Tran_Id = PEM.Perq_Tran_Id inner join  
       (select case when month = 12 then ISNULL(Amount,0) end as Dec,Perq_Tran_Id from T0250_Perquisites_Employee_Monthly_Rent WITH (NOLOCK)  where Year >= @Start_FYear and Year <= @End_FYear and Month = 12) Dec on  Dec.Perq_Tran_Id = PEM.Perq_Tran_Id   
       where Year >= @Start_FYear and Year <= @End_FYear ) PEB on PEB.Perq_Tran_Id = PE.Tran_id   
   Left outer join T0240_Perquisites_Employee_Car PEC WITH (NOLOCK) on E.Emp_ID = PEC.emp_id AND PEC.Financial_Year = @F_Year  
   --And PE.Tran_id = PEC.perquisites_id   
   Left outer join T0240_PERQUISITES_EMPLOYEE_GEW PEGEW WITH (NOLOCK) on E.Emp_ID = PEGEW.emp_id  AND PEGEW.Financial_Year = @F_Year  
   Left outer join T0250_Perquisites_Employee_Monthly_GEW PEMG WITH (NOLOCK) on PEGEW.Trans_ID = PEMG.Perq_Tran_Id   
   Inner join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID
   left outer join T0095_IT_Emp_Tax_Regime ITR WITH (NOLOCK) on EC.Emp_ID = ITR.Emp_ID and PE.Financial_Year = ITR.Financial_Year  
   WHERE E.Cmp_ID = @Cmp_Id  
   ORDER BY E.Alpha_Emp_Code,E.Emp_Full_Name  
     
   -- Cursour for Calculation for accomodation By Ali -- Start  
     
   Declare @Cmp_id_C as numeric  
   Declare @Emp_id_C as numeric  
   Declare @Fin_year_C as varchar(50)  
   Declare @Gross_Sal as numeric(18,2)  
   Declare @Deduction as numeric(18,2)  
     
   Declare Perq_Calculation CURSOR FOR  
   Select cmp_id,emp_id,fin_year,Gross_Salary,Total_Exp from #perquisites_Details (Nolock)  
   OPEN Perq_Calculation  
    FETCH NEXT FROM Perq_Calculation INTO @Cmp_id_C,@Emp_id_C,@Fin_year_C,@Gross_Sal,@Deduction  
     WHILE @@FETCH_STATUS = 0  
     BEGIN  
      
      --Select @Cmp_id_C,@Emp_id_C,@Fin_year_C,@Gross_Sal,@Deduction  
        
      Declare @tran_id_rfa as numeric  
      Declare @Acc  as tinyint  
      Declare @Leased as tinyint  
      Declare @Acc_from as datetime  
      Declare @Acc_to as datetime  
      Declare @Leased_from as datetime  
      Declare @Leased_to as datetime  
      Declare @Acc_Amt as numeric(18,2)  
      Declare @Furnish as numeric(18,2)  
      Declare @Acc_per as numeric(18,2)  
      Declare @leased_Per as numeric(18,2)  
      Declare @Gross_Sal_Per_amount as numeric(18,2)  
      Declare @Acc_days as numeric(18,0)  
      Declare @Leased_days as numeric(18,0)  
      declare @dedu_per_day as numeric(18,2)        
      Declare @Date_Of_Join  datetime  
      Declare @Left_date   datetime  
      Declare @is_Left varchar(1)  
      Declare @year_days numeric(18,0)  
      Declare @Per_Total_Amount numeric(18,2)  
      Declare @Total_Leased_Accom_Rent_C as numeric  
      Declare @Final_Amt as numeric   
        
      Set @tran_id_rfa = 0   
      Set @Acc = 0   
      Set @Leased = 0   
      Set @Acc_Amt = 0   
      Set @Furnish = 0   
      Set @Per_Total_Amount = 0  
      set @Gross_Sal_Per_amount  = 0  
      set @Acc_per = 0  
      set @leased_Per = 0  
      set @Acc_days = 0  
      set @Leased_days = 0  
      set @dedu_per_day = 0  
      set @is_Left = 'N'  
      set @year_days = 365  
      set @Date_Of_Join = NULL  
      set @Left_date = NULL  
      Set @Total_Leased_Accom_Rent_C = 0  
      Set @Final_Amt = 0  
        
      if Exists(Select Tran_id from T0240_Perquisites_Employee WITH (NOLOCK) where Emp_id = @Emp_id_C and Financial_Year = @Fin_year_C)  
       Begin  
        select @Date_Of_Join = Date_Of_Join, @Left_date = isnull(Emp_Left_Date,NULL), @is_Left = isnull(Emp_Left,'N')  From T0080_emp_Master WITH (NOLOCK) where Emp_ID = @Emp_id_C   
        
        Declare @start_date as datetime   
        Declare @End_date as datetime   
        set @start_date = cast('01-Apr' + Left(@Fin_year_C,4) as datetime)  
        Set @End_date = cast('31-Mar' + Right(@Fin_year_C,4) as datetime)  
          
        if @is_Left = 'Y'  And @End_date > @Left_date  
         begin  
          if @start_date > @Date_Of_Join   
           begin  
             set @year_days = DATEDIFF(dd,@start_date ,@Left_date) + 1  
           end  
          else  
           begin  
             set @year_days = DATEDIFF(dd,@Date_Of_Join ,@Left_date) + 1  
           end       
         end  
        else  
         begin  
          if @start_date > @Date_Of_Join   
           begin  
             set @year_days = DATEDIFF(dd,@start_date ,@End_date) + 1  
           end  
          else  
  
           begin  
             set @year_days = DATEDIFF(dd,@Date_Of_Join ,@End_date) + 1  
           end  
         end  
  
        if @Deduction > 0   
         set @dedu_per_day = @Deduction/@year_days  
            
        SELECT @tran_id_rfa= tran_id, @ACC= ON_RENT, @LEASED=CMP_QUARTER,@ACC_FROM= ON_RENT_FROM,@ACC_TO= ON_RENT_TO,   
           @LEASED_FROM = CMP_QUARTER_FROM, @LEASED_TO = CMP_QUARTER_TO , @Acc_per = On_Rent_Per , @leased_Per = Cmp_Quater_Per  
           ,@Furnish = Total_Furnish_Amt  
        FROM  T0240_PERQUISITES_EMPLOYEE WITH (NOLOCK) where Emp_id = @Emp_id_C and Financial_Year = @Fin_year_C  
          
        if @Furnish > 0  
         set @Furnish = round(@Furnish * 10/100,0)  
          
        if @Acc = 1 and @LEASED = 1  
         begin  
          -- check left date condition start  
          if @is_Left = 'Y'  
           begin  
            if @ACC_TO > @LEASED_TO  
             begin  
              if @Acc_to > @Left_date  
               begin  
                set @Acc_to =  @Left_date  
               end  
             end  
            else  
             begin  
              if @LEASED_TO > @Left_date  
               begin  
                set @LEASED_TO =  @Left_date  
               end  
             end  
           end  
            
          set @Acc_days = DATEDIFF(d,@ACC_FROM,@ACC_TO) + 1  
          set @Leased_days = DATEDIFF(d,@LEASED_FROM,@LEASED_TO) + 1  
                 
          SELECT @ACC_AMT = SUM(AMOUNT)  FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK) WHERE PERQ_TRAN_ID = @TRAN_ID_RFA  
            
          SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL/@year_days * @Leased_days) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100  
            
          IF @GROSS_SAL_PER_AMOUNT < @Acc_Amt  
           begin  
            set @Per_Total_Amount = @Gross_Sal_Per_amount   
           end  
          Else  
           begin   
            set @Per_Total_Amount = @Acc_Amt   
           end  
            
          set @Per_Total_Amount = @Per_Total_Amount + ((((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)) * @ACC_PER)/100)  + @Furnish  
            
            
          update #Final_Table   
          SET    
          Total_earning_Accom = ROUND(((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)),0),  
          Total_earning_Leased_Accom = ROUND(((@GROSS_SAL/@year_days * @Leased_days) - (@dedu_per_day * @Leased_days)),0),  
          Perqusite_Value_accom = ROUND(((((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)) * @ACC_PER)/100),0),  
          Total_15_Per_Earning = ROUND(@GROSS_SAL_PER_AMOUNT,0)  
          where Cmp_Id = @Cmp_id_C  
          and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C  
            
          Select @Total_Leased_Accom_Rent_C = Total_Leased_Accom_Rent from #Final_Table   
          where Cmp_Id = @Cmp_id_C and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C   
            
          Set @Final_Amt = @GROSS_SAL_PER_AMOUNT   
          IF @Final_Amt > @Total_Leased_Accom_Rent_C  
           Set @Final_Amt = @Total_Leased_Accom_Rent_C  
            
          Update #Final_Table Set Perqusite_Value_accom_Leased = @Final_Amt  
          where Cmp_Id = @Cmp_id_C and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C  
            
         end  
        else if @Acc = 1 -- Accommodation Provided   
         begin   
          -- check left date condition start  
          if @is_Left = 'Y'  
           begin  
            if @Acc_to > @Left_date  
             begin  
              set @Acc_to =  @Left_date  
             end                
           end  
          -- check left date condition end  
          set @Acc_days = DATEDIFF(d,@ACC_FROM,@ACC_TO) + 1  
                     
          --set @Per_Total_Amount = (((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)) * @ACC_PER)/100 + @Furnish       
          set @Per_Total_Amount = (((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)) * @ACC_PER)/100  
            
          update #Final_Table SET    
          Total_earning_Accom = ROUND(((@Gross_Sal/@year_days * @Acc_days) - (@dedu_per_day * @Acc_days)),0)  
          , Perqusite_Value_accom = ROUND(@Per_Total_Amount,0)  where Cmp_Id = @Cmp_id_C  
          and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C  
                                           
         end  
          
        else if @LEASED = 1  -- Leased Accommodation   
         begin  
          -- check left date condition start  
          if @is_Left = 'Y'  
           begin  
            if @LEASED_TO > @Left_date  
             begin  
              set @LEASED_TO = @Left_date  
             end          
           end  
          -- check left date condition end  
                     
          set @Leased_days = DATEDIFF(d,@LEASED_FROM,@LEASED_TO) + 1      
          SELECT @ACC_AMT = SUM(AMOUNT)  FROM T0250_PERQUISITES_EMPLOYEE_MONTHLY_RENT WITH (NOLOCK)   
          WHERE PERQ_TRAN_ID = @TRAN_ID_RFA  
            
          if @is_left = 'N'  
           begin  
             
            SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL/@year_days * @Leased_days) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100  
           end  
          else  
           begin  
            SET @GROSS_SAL_PER_AMOUNT = (((@GROSS_SAL) - (@dedu_per_day * @Leased_days)) * @leased_Per)/100  
           end  
            
          IF @GROSS_SAL_PER_AMOUNT < @Acc_Amt  
           begin  
            --set @Per_Total_Amount = @Gross_Sal_Per_amount + @Furnish  
            set @Per_Total_Amount = @Gross_Sal_Per_amount  
           end  
          Else  
           begin   
            --set @Per_Total_Amount = @Acc_Amt + @Furnish  
            set @Per_Total_Amount = @Acc_Amt  
           end  
             
          update #Final_Table SET   
          Total_earning_Leased_Accom = ROUND(((@GROSS_SAL/@year_days * @Leased_days) - (@dedu_per_day * @Leased_days)),0)  
          ,Total_15_Per_Earning = ROUND(@Per_Total_Amount,0)  where Cmp_Id = @Cmp_id_C  
          and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C   
            
          Select @Total_Leased_Accom_Rent_C = Total_Leased_Accom_Rent from #Final_Table   
          where Cmp_Id = @Cmp_id_C and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C   
            
            
          Set @Final_Amt = @Per_Total_Amount   
          IF @Final_Amt > @Total_Leased_Accom_Rent_C  
           Set @Final_Amt = @Total_Leased_Accom_Rent_C  
            
          Update #Final_Table Set Perqusite_Value_accom_Leased = @Final_Amt  
          where Cmp_Id = @Cmp_id_C and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C   
            
         end  
       End  
      
       Update #Final_Table   
       Set Total_Perq_Amount = (Perqusite_Value_accom + Perqusite_Value_accom_Leased + Perqusite_Value_For_Furniture + Perqusite_Value_For_GEW + Perqusite_Value_For_Car)  
       where Cmp_Id = @Cmp_id_C and Emp_ID = @Emp_id_C and Financial_Year = @Fin_year_C   
            
            
     FETCH NEXT FROM Perq_Calculation INTO @Cmp_id_C,@Emp_id_C,@Fin_year_C,@Gross_Sal,@Deduction  
     END  
   CLOSE Perq_Calculation  
   DEALLOCATE Perq_Calculation  
  
  
  
CREATE TABLE #Perq_Customized  
 (  
  Cmp_Id Numeric,  
  Emp_Id numeric,  
  IT_Id numeric,  
  Financial_Year Varchar(9),  
  Amount Numeric(18,2),  
  IT_Name varchar(350)  
 )  
   
  
  INSERT INTO #Perq_Customized   
   (Cmp_Id, Emp_Id, IT_ID,IT_Name,Financial_Year,Amount)  
   SELECT PED.Cmp_Id, PED.Emp_Id, IM.IT_ID,IM.IT_Name,PED.Financial_Year,PED.Amount From T0240_Perquisites_Employee_Dynamic PED WITH (NOLOCK) Inner join  
    T0070_IT_MASTER IM WITH (NOLOCK) On PED.It_Id=IM.IT_ID  
    INNER JOIN #Emp_Cons EC On PED.emp_id = EC.Emp_ID  
   Where PED.Amount > 0 And PED.Financial_Year = @F_year And IM.Cmp_ID = @Cmp_id  
     
  
  
 DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)  
DECLARE @ColumnName AS NVARCHAR(MAX)  
  
  
SELECT @ColumnName= ISNULL(@ColumnName + ',','')   
       + QUOTENAME(Replace(Replace(Replace(Replace(IT_Name,' ' ,'_'),',','-'),'(','_'),')','_'))  
FROM (SELECT DISTINCT IT_Name FROM #Perq_Customized) AS IT_Name  
  

  
If not @ColumnName is null  
 begin  
 
  SET @DynamicPivotQuery =   
    N'Select * Into Perq_Cust From ( SELECT Emp_Id, Financial_Year, ' + @ColumnName + ' , (Isnull(' + REPLACE(@ColumnName,',',',0)+ Isnull(') + ',0)) as Total  
   FROM (Select Emp_Id,Amount,Replace(Replace(Replace(Replace(IT_Name,'' '' ,''_''),'','',''-''),''('',''_''),'')'',''_'') as IT_Name,Financial_Year From #Perq_Customized ) as S  
   PIVOT(sum(Amount)   
      FOR IT_Name IN (' + @ColumnName + ')) AS PVTTable )Qry'  
  
  EXEC sp_executesql @DynamicPivotQuery  
    --select * Into #Perq_Cust from #Perq_Customized  ---commented by mansi
  --select * Into #Perq_Cust from #Perq_Customized  ---added by mansi

  Drop table Perq_Cust  
 end  
     
	select * Into #Perq_Cust from #Perq_Customized --Changes location by ronakk 18042023
  
   -- Cursour for Calculation for accomodation By Ali -- End   
   -- Gadriwala Muslim 07042014 Replace(CONVERT(Varchar(25),Accom_Provided_From,103),'','/')  use this date format syntax  for Excel Export Report  
   Select   
    Emp_ID  
   ,Cmp_ID  
   ,Emp_Code as 'Employee_Code'  
   ,Employee_Name as 'Employee_Name'  
   ,Financial_Year as 'Financial_Year'  
   ,Regime as 'Employee_Regime'
   ,CASE Accom_Provided_in_Colony WHEN 1 THEN 'YES' ELSE 'NO' END as 'Accommodation_Provided_By_Company'  
   ,Replace(CONVERT(Varchar(25),Accom_Provided_From,103),'','/') as  'Accommodation_Provided_From_Date'  
   ,Replace(CONVERT(Varchar(25),Accom_Provided_To,103),'','/') as 'Accommodation_Provided_To_Date'  
   ,CASE Leased_Accom WHEN 1 THEN 'YES' ELSE 'NO' END as 'Leased_Accommodation'  
   ,Replace(CONVERT(Varchar(25),Leased_Accom_From,103),'','/') as 'Leased_Accommodation_From_Date'   
   ,Replace(CONVERT(Varchar(25),Leased_Accom_To,103),'','/')as 'Leased_Accommodation_To_Date'  
   ,Total_earning_Accom as 'Total_earning_on_which_Perq._Value_calculated_for_Accomodation_Provided_by_company'  
   ,Perqusite_Value_accom as 'Perqusite_valuation_for_Accomodation_Provided_By_Company_(A)'  
   ,Apr  
   ,May  
   ,Jun  
   ,Jul  
   ,Aug  
   ,Sep  
   ,Oct  
   ,Nov  
   ,[Dec]  
   ,Jan  
   ,Feb  
   ,Mar  
   ,Total_Leased_Accom_Rent as 'Total_Leased_Accommodation_Rent_(X)'  
   ,Total_earning_Leased_Accom as 'Total_earning_on_which_Perq._Value_calculated_for_Leased_Accomodation'  
   ,Total_15_Per_Earning as '15%_of_earning(15%)_(Y)'  
   ,Perqusite_Value_accom_Leased as 'Perqusite_valuation_for_leased_Accomodation_Lower_In_X_or_Y_(B)'  
   ,Total_Furnish_Amt as 'Total_Furnish_Amt.'  
   ,Perqusite_Value_For_Furniture as 'Perqusite_valuation_for_Furniture_(C)'  
   ,Perqusite_Value_For_GEW as 'Perqusite_valuation_for_Electricity_(D)'  
   ,Perqusite_Value_For_Car as 'Perqusite_valuation_for_car_(E)'  
   ,Total_Perq_Amount as 'Total_Perquisite_value-(A+B+C+D+E)'
   into #Final_Table_New From #Final_Table where Total_Perq_Amount <> 0  

 If Exists(Select 1 From #Final_Table_New)  
  BEGIN  
   If not object_id('tempdb..#Perq_Cust') IS null  
    begin 
	  
     Set @DynamicPivotQuery = 'Select FTN.*, ' + @ColumnName + ', [Total_Perquisite_value-(A+B+C+D+E)] + Total As Total_Perq   
          From #Final_Table_New FTN LEFT OUTER Join #Perq_Cust PC on FTN.Emp_Id = PC.Emp_ID  
         Union All   
         Select PC.Emp_Id,EM.Cmp_Id,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Financial_Year,''Null'', ''NO'',''NULL'',''NULL'',''NO'','''','''',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'  
          + @ColumnName + ',Total as Total_Perq  
         From #Perq_Cust PC Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) On PC.Emp_Id = EM.Emp_ID   
         Where PC.Emp_Id Not In (Select Emp_Id From #Final_Table_New)'            
		 
    End  
   Else  
    begin  
     Set @DynamicPivotQuery = 'Select FTN.*  
          From #Final_Table_New FTN'  
     
    End     
	
   EXEC(@DynamicPivotQuery)  
  END  
 Else  
  BEGIN  
  
   select EM.Alpha_Emp_Code As Employee_Code, EM.Emp_Full_Name As Employee_Name, PC.*   
   from #Perq_Cust PC Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) On PC.Emp_Id = EM.Emp_ID    
  END  
  
     
 RETURN  
  
  
