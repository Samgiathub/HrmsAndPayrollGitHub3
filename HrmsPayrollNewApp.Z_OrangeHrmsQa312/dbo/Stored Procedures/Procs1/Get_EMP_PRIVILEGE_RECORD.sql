


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_EMP_PRIVILEGE_RECORD]      
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 --,@Branch_ID  numeric   
 --,@Cat_ID  numeric 
 --,@Grd_ID  numeric 
 --,@Type_ID  numeric  
 --,@Dept_ID  numeric  
 --,@Desig_ID  numeric 
 ,@Branch_ID  varchar(max) = ''    
 ,@Cat_ID     varchar(max) = ''  
 ,@Grd_ID     varchar(max) = ''  
 ,@Type_ID    varchar(max) = ''   
 ,@Dept_ID    varchar(max) = ''   
 ,@Desig_ID   varchar(max) = '' 
 ,@Emp_ID  numeric 
 ,@Constraint varchar(max) = '' 
 ,@Emp_Search int=0     
 ,@St_Date datetime = NULL
 ,@End_Date datetime = NULL
 
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
       
 CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0
     
 /*    
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
        
       
       
 CREATE table #Emp_Cons 
 (      
  Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )      
         
       
 if @Constraint <> ''      
  begin      
   Insert Into #Emp_Cons      
   select  cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
  end      
 else      
  begin      
        
    if isnull(@St_Date,0) = 0 or isnull(@end_date,0) = 0
		begin 
		         
		   Insert Into #Emp_Cons      
		      select emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                     ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or Left_date is null and @To_Date >= Join_Date)      
						or @To_Date >= left_date  and  @From_Date <= left_date 
						order by Emp_ID
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
				where  Increment_effective_Date <= @to_date
				group by emp_ID)
				
		    
		end
  end */
  
  select Alpha_Emp_Code as Emp_Code,Emp_Full_Name,FROM_DATE,PRIVILEGE_NAME,PRIVILEGE_TYPE,Branch_ID
       from V0090_EMP_PRIVILEGE_DETAILS
       where Cmp_Id =@Cmp_ID and Trans_Id > 0 and PRIVILEGE_NAME <> '-' 
             and Emp_ID in (select Emp_ID From #Emp_Cons)
       Order By Alpha_Emp_Code asc
       
       
 RETURN      
      
      
    

