


---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Graphics_Home_Age]      
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
 ,@Constraint varchar(5000) = '' 
 ,@Emp_Search int=0     

 
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
       
    
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
   Emp_ID numeric ,     
  Branch_ID numeric    
 )      
       
 if @Constraint <> ''      
  begin      
   Insert Into @Emp_Cons      
   select  cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
  end      
 else      
  begin      
        
  
		   Insert Into @Emp_Cons      
		      
		   select I.Emp_Id,I.Branch_ID from T0095_Increment I WITH (NOLOCK) inner join       
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
  
  IF OBJECT_ID('tempdb..#Age_Table') IS NOT NULL
		BEGIN
			DROP TABLE #Age_Table
		END	    
  
  CREATE TABLE #Age_Table
  (	
	cmp_id numeric(18),
	branch_id numeric(18),	
	Age_15 numeric(18,0),
	Age_15_30 numeric(18,0),
	Age_30_45 numeric(18,0),
	Age_45_60 numeric(18,0),
	Age_60_100 numeric(18,0),
	Total     numeric(18,0)		
  )
  
   insert into #Age_Table
   SELECT @cmp_ID,@Branch_ID,0,0,0,0,0,0
   
  
   Update #Age_Table
   set age_15 = q.age_15
   from #Age_Table A inner join 
   (SELECT Cmp_ID,COUNT(*) as age_15  from T0080_EMP_MASTER WITH (NOLOCK)     
     where    DATEDIFF(yy,Date_Of_Birth,GETDATE())  BETWEEN 0 and 15 and Isnull(Branch_ID,0) = Isnull(@Branch_ID ,Isnull(Branch_ID,0))
     and  Isnull(Grd_ID,0) = Isnull(@grd_ID ,Isnull(Grd_ID,0))
       and  Isnull(Dept_ID,0) = Isnull(@Dept_ID ,Isnull(Dept_ID,0))
     
      group by cmp_ID
    ) q ON a.cmp_id = q.Cmp_ID 
   
	
	 Update #Age_Table
   set Age_15_30 = q.age_30
   from #Age_Table A inner join 
   (SELECT Cmp_ID,COUNT(*) as age_30  from T0080_EMP_MASTER WITH (NOLOCK)    
     where    DATEDIFF(yy,Date_Of_Birth,GETDATE())  BETWEEN 16 and 30  and Isnull(Branch_ID,0) = Isnull(@Branch_ID ,Isnull(Branch_ID,0))
		   and  Isnull(Grd_ID,0) = Isnull(@grd_ID ,Isnull(Grd_ID,0))
       and  Isnull(Dept_ID,0) = Isnull(@Dept_ID ,Isnull(Dept_ID,0))
      group by cmp_ID
    ) q ON a.cmp_id = q.Cmp_ID 
	
  
	 Update #Age_Table
   set Age_30_45 = q.age_45
   from #Age_Table A inner join 
   (SELECT Cmp_ID,COUNT(*) as age_45  from T0080_EMP_MASTER WITH (NOLOCK)     
     where    DATEDIFF(yy,Date_Of_Birth,GETDATE())  BETWEEN 31 and 45  and Isnull(Branch_ID,0) = Isnull(@Branch_ID ,Isnull(Branch_ID,0))
         and  Isnull(Grd_ID,0) = Isnull(@grd_ID ,Isnull(Grd_ID,0))
       and  Isnull(Dept_ID,0) = Isnull(@Dept_ID ,Isnull(Dept_ID,0))
      group by cmp_ID
    ) q ON a.cmp_id = q.Cmp_ID 
    
     Update #Age_Table
   set Age_45_60 = q.age_60
   from #Age_Table A inner join 
   (SELECT Cmp_ID,COUNT(*) as age_60  from T0080_EMP_MASTER WITH (NOLOCK)    
     where    DATEDIFF(yy,Date_Of_Birth,GETDATE())  BETWEEN 46 and 60  and Isnull(Branch_ID,0) = Isnull(@Branch_ID ,Isnull(Branch_ID,0))
        and  Isnull(Grd_ID,0) = Isnull(@grd_ID ,Isnull(Grd_ID,0))
       and  Isnull(Dept_ID,0) = Isnull(@Dept_ID ,Isnull(Dept_ID,0))
      group by cmp_ID
    ) q ON a.cmp_id = q.Cmp_ID 
    
    
     Update #Age_Table
   set Age_45_60 = q.age_100
   from #Age_Table A inner join 
   (SELECT Cmp_ID,COUNT(*) as age_100  from T0080_EMP_MASTER WITH (NOLOCK)    
     where    DATEDIFF(yy,Date_Of_Birth,GETDATE())  BETWEEN 61 and 100  and Isnull(Branch_ID,0) = Isnull(@Branch_ID ,Isnull(Branch_ID,0))
         and  Isnull(Grd_ID,0) = Isnull(@grd_ID ,Isnull(Grd_ID,0))
       and  Isnull(Dept_ID,0) = Isnull(@Dept_ID ,Isnull(Dept_ID,0))
      group by cmp_ID
    ) q ON a.cmp_id = q.Cmp_ID 
    
      Update #Age_Table
   set Total = q.age_total
   from #Age_Table A inner join 
   (SELECT Cmp_ID,COUNT(*) as age_total  from T0080_EMP_MASTER WITH (NOLOCK)     
     where  Date_Of_Birth is not null and  DATEDIFF(yy,Date_Of_Birth,GETDATE()) BETWEEN 0 and 101  and Isnull(Branch_ID,0) = Isnull(@Branch_ID ,Isnull(Branch_ID,0))
         and  Isnull(Grd_ID,0) = Isnull(@grd_ID ,Isnull(Grd_ID,0))
       and  Isnull(Dept_ID,0) = Isnull(@Dept_ID ,Isnull(Dept_ID,0))
      group by cmp_ID
    ) q ON a.cmp_id = q.Cmp_ID 
  
  
  select * from #Age_Table
  
 RETURN


