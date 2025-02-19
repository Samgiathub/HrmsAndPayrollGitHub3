
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_SALARY_GET]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime  
 ,@Branch_ID  Numeric   
 ,@Cat_ID  Numeric  
 ,@Grd_ID  Numeric  
 ,@Type_ID  Numeric   
 ,@Dept_Id  Numeric  
 ,@Desig_Id  Numeric  
 ,@Emp_ID  Numeric  
    ,@Constraint varchar(MAX)  
      
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
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)
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
    
    
    
 -- Changed By Ali 22112013 EmpName_Alias  
 select I_Q.*   
  ,ISNULL(E.EmpName_Alias_Tax,cast( E.Emp_code as varchar) + ' - ' + E.Emp_Full_Name) as Emp_Full_Name  
  --, cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name  
  ,Emp_superior    
     ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender    
     ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,TP.Taxable_Amount,TP.IT_M_Surcharge_Amount,tP.IT_M_ED_Cess_Amount,TP.IT_M_Final_Amount,TP.IT_M_Amount  ,E.Emp_code  
  ,E.Alpha_Emp_Code,E.Emp_First_Name,tp.For_Date   --added jimit 02062015  
  ,case when ETR.Regime = 'Tax Regime 2' then 'New Regime' else 'Old Regime' end as Regime
  from T0080_EMP_MASTER E WITH (NOLOCK) left outer join     
  T0190_Tax_Planning TP  WITH (NOLOCK) on E.Emp_ID =TP.Emp_ID inner join  
      
    T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join    
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join     
    ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
    where Increment_Effective_date <= @To_Date    
    and Cmp_ID = @Cmp_ID    
    group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
    on E.Emp_ID = I_Q.Emp_ID  inner join    
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID     
	left outer join T0095_IT_Emp_Tax_Regime ETR WITH (NOLOCK) on E.Emp_ID = ETR.Emp_ID and ETR.Financial_Year = cast(year(@From_Date) as varchar) + '-' + cast(year(@To_Date) as varchar)
  WHERE E.Cmp_ID = @Cmp_Id    and For_Date >= @From_Date and For_date<= @To_date  
    And E.Emp_ID in (select Emp_ID From @Emp_Cons)   
    order by E.Emp_Code asc    
      
        
    
     RETURN   
  
  
  
  