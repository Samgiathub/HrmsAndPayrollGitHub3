---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---


CREATE PROCEDURE [dbo].[EH_EMPLOYEE_TRANSFER_HISTORY]      
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
  
  IF OBJECT_ID('tempdb..#Inc_History') IS NOT NULL
		BEGIN
			DROP TABLE #Inc_History
		END	
  
  CREATE table #Inc_History
  (
    Row_ID numeric, --Mukti(27022017)
	cmp_id numeric(18),
	inc_id numeric(18),
	Emp_id numeric(18),
	Emp_Code nvarchar(50),
	Emp_Full_Name nvarchar(100),
	Revised_date datetime,
	Inc_after_days numeric(18),
	Branch_ID numeric(18),
	Grade_ID numeric(18),
	Dept_ID numeric(18),
	Desig_ID numeric(18),
	Type_ID numeric(18),
	Manager varchar(255),
	Shift_ID numeric,
	Date_Of_Join datetime,
	Group_date datetime,
	Increment_Type  varchar(255)
  )
  

---Get record from date of joining-	
  
  insert into #Inc_History
  select ROW_NUMBER() OVER(PARTITION BY inc.cmp_id,inc.Emp_id ORDER BY inc.emp_id,inc.Increment_Effective_Date,Inc.Increment_Id) As RowID,
  inc.cmp_id,inc.increment_id,inc.emp_id,em.alpha_emp_code,em.emp_full_name,inc.Increment_Effective_Date,inc.basic_Salary ,   
  inc.Branch_ID,inc.Grd_ID,inc.Dept_ID,inc.Desig_Id,inc.Type_ID, em.Emp_Superior,em.Shift_ID, em.Date_Of_Join, em.GroupJoiningDate,
  inc.Increment_Type
   from t0095_increment inc WITH (NOLOCK)
  inner join t0080_emp_master em WITH (NOLOCK) on inc.emp_id = em.emp_id
  inner join @Emp_Cons ec on  ec.emp_id = inc.emp_id
		 and ec.Branch_ID = inc.Branch_ID --Added By Jaina 1-09-2015  
 --  where inc.Increment_Effective_Date between @From_Date and @To_Date
  order by inc.emp_id,inc.increment_effective_date
    
---Get record from date of joining-		
	
  

select I.Row_ID,I.cmp_id,I.Emp_Code,Convert(varchar(10),Revised_date,103) as Revised_date, Convert(varchar(10),I.Date_Of_Join,103) as Date_Of_Join,
Convert(varchar(10),I.Group_date,103) as Group_date,I.Increment_Type,

B.Branch_Name,G.Grd_Name,D.Dept_Name,DE.Desig_Name,T.Type_Name, isnull(E.Emp_Full_Name,'') as Manager, s.Shift_Name 
from #Inc_History I 
	inner join T0030_BRANCH_MASTER  B WITH (NOLOCK) ON I.Branch_ID = B.Branch_ID
	inner join T0040_GRADE_MASTER  G WITH (NOLOCK) ON I.Grade_ID = G.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER  D WITH (NOLOCK) ON I.Dept_ID = D.Dept_Id
	inner join T0040_DESIGNATION_MASTER  DE WITH (NOLOCK) ON I.Desig_ID = DE.Desig_ID
	inner join T0040_SHIFT_MASTER  s WITH (NOLOCK) On I.Shift_ID = s.Shift_ID
	left outer join T0080_EMP_MASTER E WITH (NOLOCK) ON I.Manager = E.Emp_ID
	left outer join T0040_TYPE_MASTER  T WITH (NOLOCK) ON I.Type_ID = T.Type_ID

order by I.Row_ID desc	--Mukti(27022017)	
--order by I.Revised_date desc	
  
 RETURN


