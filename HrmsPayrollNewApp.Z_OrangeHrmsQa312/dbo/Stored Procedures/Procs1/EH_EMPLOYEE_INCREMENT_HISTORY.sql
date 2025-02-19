


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_EMPLOYEE_INCREMENT_HISTORY]      
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
			 ( select max(Increment_id) as Increment_id , Emp_ID from T0095_Increment  WITH (NOLOCK)      --Changed by Hardik 10/09/2014 for Same Date Increment
			 where Increment_Effective_date <= @To_Date      
			 and Cmp_ID = @Cmp_ID      
			 group by emp_ID  ) Qry on      
			 I.Emp_ID = Qry.Emp_ID and I.Increment_id = Qry.Increment_id      
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
	Row_ID numeric,
	cmp_id numeric(18),
	inc_id numeric(18),
	Emp_id numeric(18),
	Emp_Code nvarchar(50),
	Emp_Full_Name nvarchar(100),
	Basic_Salary numeric(18,2),
	Gross_Salary numeric(18,2),
	CTC numeric(18,2),
	Increment_date datetime,
	Revised_date datetime,
	B_Growth_Per numeric(18,3),
	G_Growth_Per numeric(18,3),
	C_Growth_Per numeric(18,3),
	Inc_after_days numeric(18),
	Salary_Basic_On varchar(255),
	Wages_type varchar(255),
	Joining_Type varchar(255)
	
	
	
  )
  
	declare @C_Emp_id numeric(18)
	declare @Revised_date datetime
	declare @B_Growth_Per numeric(18,3)
	declare @G_Growth_Per numeric(18,3)
	declare @C_Growth_Per numeric(18,3)
	
	declare @Count numeric(18)
	declare @P_C_Emp_id numeric(18)
	declare @P_Revised_date datetime
	declare @P_B_Growth_Per numeric(18,3)
	declare @P_G_Growth_Per numeric(18,3)
	declare @P_C_Growth_Per numeric(18,3)
	
	set @Count = 0
	set @P_C_Emp_id = 0
	set @P_B_Growth_Per = 0
	set @P_G_Growth_Per = 0
	set @P_C_Growth_Per = 0
	
  
  insert into #Inc_History
  select  ROW_NUMBER() OVER(PARTITION BY inc.cmp_id,inc.Emp_id ORDER BY inc.emp_id,inc.Increment_Effective_Date,Inc.Increment_Id) As RowID, inc.cmp_id,inc.increment_id,inc.emp_id,em.alpha_emp_code,em.emp_full_name,inc.basic_Salary , inc.gross_salary,inc.ctc,Increment_date,inc.increment_effective_date,0,0,0,0 
	,inc.Salary_Basis_On,inc.Wages_Type,inc.Increment_Type
  from t0095_increment inc WITH (NOLOCK)
  inner join t0080_emp_master em WITH (NOLOCK) on inc.emp_id = em.emp_id
  inner join @Emp_Cons ec on  ec.emp_id = inc.emp_id
  --where inc.Increment_Effective_Date between @From_Date and @To_Date
    order by inc.emp_id,inc.increment_effective_date
    
    
  declare curInc cursor for    
	select emp_id,Basic_Salary,Gross_Salary,CTC,Revised_date from #Inc_History   order by emp_id,Revised_date
  open curInc
	fetch next from curInc into @C_Emp_id,@B_Growth_Per,@G_Growth_Per,@C_Growth_Per,@Revised_date
	while @@fetch_status = 0
		begin 
			
			if @Count = 0 or @P_C_Emp_id <> @C_Emp_id
				begin
					set @P_C_Emp_id = @C_Emp_id
					set @P_B_Growth_Per = @B_Growth_Per
					set @P_G_Growth_Per = @G_Growth_Per
					set @P_C_Growth_Per = @C_Growth_Per
					set @P_Revised_date = @Revised_date
				end
			else
				begin
					
					declare @diff as numeric(18,2)
					declare @B_perc as numeric(18,3)
					set @diff = 0
					
					--basic
					
					set @diff = @B_Growth_Per - @P_B_Growth_Per
					
					if @P_B_Growth_Per > 0
						begin
							set @B_perc = (@diff/@P_B_Growth_Per) * 100
						end
					else
						begin
							set @B_perc = 0
						end
					
					update #Inc_History set B_Growth_Per = @B_perc where emp_id = @C_Emp_id and Revised_date = @Revised_date
					
					-- gross 
					set @diff = 0
					
					set @diff = @G_Growth_Per - @P_G_Growth_Per
					
					if @P_G_Growth_Per > 0
						begin
							set @B_perc = (@diff/@P_G_Growth_Per) * 100
						end
					else
						begin
							set @B_perc = 0
						end
					
					update #Inc_History set G_Growth_Per = @B_perc where emp_id = @C_Emp_id and Revised_date = @Revised_date
					
					-- CTC
					
					set @diff = 0
					
					set @diff = @C_Growth_Per - @P_C_Growth_Per
					
					if @P_C_Growth_Per > 0
						begin
							set @B_perc = (@diff/@P_C_Growth_Per) * 100
						end
					else
						begin
							set @B_perc = 0
						end
					
					update #Inc_History set C_Growth_Per = @B_perc where emp_id = @C_Emp_id and Revised_date = @Revised_date
					
					
					declare @days numeric(18)
					set @days = 0
					
					set @days  = abs(datediff(dd,@P_Revised_date,@Revised_date))  + 1
					
					update #Inc_History set Inc_after_days = @days where emp_id = @C_Emp_id and Revised_date = @Revised_date
										
					set @P_C_Emp_id = @C_Emp_id
					set @P_B_Growth_Per = @B_Growth_Per
					set @P_G_Growth_Per = @G_Growth_Per
					set @P_C_Growth_Per = @C_Growth_Per
					set @P_Revised_date = @Revised_date
					
				end
			
			set @Count = @Count + 1		
			fetch next from curInc into @C_Emp_id,@B_Growth_Per,@G_Growth_Per,@C_Growth_Per,@Revised_date
		end  
	close curInc
	deallocate curInc	
  
	
 CREATE table #Inc_History_new
  (
	Row_ID numeric,
	cmp_id numeric(18),
	inc_id numeric(18),
	Emp_id numeric(18),
	Emp_Code nvarchar(50),
	Emp_Full_Name nvarchar(100),
	Basic_Salary VARCHAR(255),
	Gross_Salary VARCHAR(255),
	CTC VARCHAR(255),
	Increment_date datetime,
	Revised_date datetime,	
	Inc_after_days numeric(18),
	Salary_Basic_On varchar(255),
	Wages_type varchar(255),
	Joining_type	 varchar(255),	
	Is_CTCChange int  default 0,
	Is_GrossChange int  default 0,
	Is_BasicChange int  default 0
  )
  
  insert into #Inc_History_new
 select Row_ID,cmp_id,inc_id,Emp_id,Emp_Code,Emp_Full_Name,
 Basic_Salary,Gross_Salary,CTC,Increment_date,Revised_date,Inc_after_days,Salary_Basic_On,Wages_type,Joining_type,0,0,0
 from #Inc_History
 


 Declare @N_Basic_Salary numeric(18,2)
 Declare @N_Gross_Salary numeric(18,2)
 Declare @N_CTC_Salary numeric(18,2)
 Declare @N_Revis_Date DateTime
 Declare @N_Row_ID numeric(18,0)
 
 Declare @O_Basic_Salary numeric(18,2)
 Declare @O_Gross_Salary numeric(18,2)
 Declare @O_CTC_Salary numeric(18,2)
 Declare @O_Revis_Date DateTime
 Declare @O_Row_ID numeric(18,2)
 
 
 Declare @NEW_Basic_Salary VARCHAR(255)
 Declare @NEW_Gross_Salary VARCHAR(255)
 Declare @NEW_CTC_Salary VARCHAR(255)

    declare curInc cursor for    
	select Row_ID,Basic_Salary,Gross_Salary,CTC,Revised_date from #Inc_History   order by emp_id,Revised_date
  open curInc
	fetch next from curInc into @N_Row_ID,@N_Basic_Salary,@N_Gross_Salary,@N_CTC_Salary,@N_Revis_Date
	while @@fetch_status = 0
		begin 
				declare @Ac_Row_ID as numeric
				set @Ac_Row_ID = @N_Row_ID
				If @N_Row_ID > 1				
				BEGIN					
					SET @N_Row_ID = @N_Row_ID - 1
					SELECT @O_Basic_Salary = Basic_Salary, @O_Gross_Salary = Gross_Salary,@O_CTC_Salary =  CTC					
					from #Inc_History where Row_ID = @N_Row_ID
					
					IF @O_Basic_Salary <> @N_Basic_Salary
					BEGIN
						SET @NEW_Basic_Salary = @N_Basic_Salary
						Update #Inc_History_new
						set Basic_Salary = @NEW_Basic_Salary , Is_BasicChange= 1
						
						where Row_ID =@Ac_Row_ID 
						
					END
					IF @O_Gross_Salary <> @N_Gross_Salary
					BEGIN
						SET @NEW_Gross_Salary =  @N_Gross_Salary 
						Update #Inc_History_new
						set Gross_Salary = @NEW_Gross_Salary, Is_GrossChange= 1
						where Row_ID =@Ac_Row_ID 
					END
					
					IF @O_CTC_Salary <> @N_CTC_Salary
					BEGIN
				
						SET @NEW_CTC_Salary =  @N_CTC_Salary 						
							Update #Inc_History_new
						set CTC = @NEW_CTC_Salary , Is_CTCChange= 1
						where Row_ID =@Ac_Row_ID
					END
					
				
					
				END
			set @Count = @Count + 1		
			fetch next from curInc into @N_Row_ID,@N_Basic_Salary,@N_Gross_Salary,@N_CTC_Salary,@N_Revis_Date
		end  
	close curInc
	deallocate curInc	
 


select 
Row_ID ,
	cmp_id ,
	inc_id ,
	Emp_id ,
	Emp_Code ,
	Emp_Full_Name ,
	isnull(Basic_Salary,0) Basic_Salary,
	isnull(Gross_Salary,0) Gross_Salary ,
	isnull(CTC,0) CTC,
	
	Convert(varchar(10), Increment_date,103) Incrment_date ,	
	Convert(varchar(10), Revised_date,103) Revised_date ,	
	Inc_after_days ,
	Salary_Basic_On ,
	Wages_type,
	Joining_type ,
	isnull(Is_CTCChange,0) Is_CTCChange,
	isnull(Is_GrossChange,0) Is_GrossChange,
	isnull(Is_BasicChange,0) Is_BasicChange	


from #Inc_History_new order BY Increment_date desc

  
 RETURN


