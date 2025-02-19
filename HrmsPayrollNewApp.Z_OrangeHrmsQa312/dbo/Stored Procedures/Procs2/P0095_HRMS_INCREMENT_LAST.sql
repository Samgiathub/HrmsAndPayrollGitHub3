



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_HRMS_INCREMENT_LAST]    
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
 ,@Constraint varchar(5000)     
As  
  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
--set  @Cmp_ID =26  
--set @From_Date ='01-sep-2009'  
--set @To_Date  ='30-sep-2009'  
--set @Branch_ID = 0    
-- set @Cat_ID  =0    
 --set @Grd_ID   = 0    
 --set @Type_ID   = 0    
--set @Dept_ID    = 0    
--set @Desig_ID   = 0    
--set @Emp_ID   = 0  
--set @Constraint = ''   

If @From_date=''
	Set @From_Date='Jan  1 1947 12:00AM'	 
If @To_date=''
	Set @To_date=getdate()	 
    
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
      
     
     
 Declare @Emp_Cons Table    
 (    
   Emp_ID numeric    
  ,Increment_eff_Date datetime  
 )    
     
 if @Constraint <> ''    
  begin    
   Insert Into @Emp_Cons(emp_id)  
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')             
  
        select I.Emp_Id,Increment_Effective_date,(Em.Alpha_Emp_Code+'-'+ em.emp_full_name) as Emp_Full_Name,em.Work_Email,em.Mobile_No,em.Alpha_Emp_Code,em.Emp_code,em.Branch_ID,b.Branch_Name,em.Grd_ID,g.Grd_Name from dbo.T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment  WITH (NOLOCK)   --Changed by Hardik 10/09/2014 for Same Date Increment 
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID)Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id inner join @Emp_Cons EC on I.Emp_ID = Ec.Emp_Id inner join dbo.T0080_emp_master em WITH (NOLOCK) on i.emp_id=em.emp_id 
     left join T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Branch_ID = em.Branch_ID left join
     T0040_GRADE_MASTER g WITH (NOLOCK) on g.Grd_ID = em.Grd_ID
     where i.cmp_id=@cmp_id order by em.emp_id   
    
     
  end    
 else    
  begin  
       
   Insert Into @Emp_Cons(emp_id,Increment_eff_Date)    
    
   select I.Emp_Id,Increment_Effective_date from dbo.T0095_Increment I WITH (NOLOCK) inner join  --Changed by Hardik 10/09/2014 for Same Date Increment     
     ( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment  WITH (NOLOCK)  
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
   Where Cmp_ID = @Cmp_ID     
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))    
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
   and I.Emp_ID in     
    ( select Emp_Id from (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry    
    where cmp_ID = @Cmp_ID   and      
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )     
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
    or Left_date is null and @To_Date >= Join_Date)    
    or @To_Date >= left_date  and  @From_Date <= left_date )
    

End

--Select e.Emp_Code,e.emp_id,ec.Increment_eff_date, e.emp_full_name,e.Work_Email,e.Mobile_No from dbo.T0080_emp_master E inner join @Emp_cons EC on E.Emp_ID = EC.Emp_ID where E.Cmp_Id = @Cmp_Id order by E.Emp_Id 
Select E.Alpha_Emp_Code,e.Emp_Code,e.emp_id,ec.Increment_eff_date, emp_full_name,e.Work_Email,e.Mobile_No,E.Alpha_Emp_Code,E.Emp_code,E.Branch_ID,b.Branch_Name,E.Grd_ID,g.Grd_Name from dbo.T0080_emp_master E WITH (NOLOCK) inner join @Emp_cons EC on E.Emp_ID = EC.Emp_ID 
left join T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Branch_ID = E.Branch_ID left join
     T0040_GRADE_MASTER g WITH (NOLOCK) on g.Grd_ID = E.Grd_ID
where E.Cmp_Id = @Cmp_Id And ec.Increment_eff_date Between @From_date And @To_date  order by E.Emp_Id 

   --Select * from dbo.T0080_emp_master E inner join @Emp_cons EC on E.Emp_ID = EC.Emp_ID  
 RETURN    
  



