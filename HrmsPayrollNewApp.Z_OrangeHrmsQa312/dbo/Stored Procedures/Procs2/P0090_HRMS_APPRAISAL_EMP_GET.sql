

 
 ---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
 CREATE PROCEDURE [dbo].[P0090_HRMS_APPRAISAL_EMP_GET]
    @cmp_id  numeric
	,@branch_id  numeric
	,@Dashboard int
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


--declare @temp table
CREATE Table #temp
	(
		emp_id  numeric
	   ,effective_date  datetime
	   ,branch_id numeric
	   ,Grade_id numeric  --Ripal 23July2014
	)
--declare @temp_data table
CREATE Table #temp_data
	(
		emp_id  numeric
	   ,effective_date  datetime
	   ,duration numeric
	   ,appraisal_duration numeric
	)
--declare @temp_final table
CREATE Table #temp_final
	(
		emp_id  numeric
	   ,start_date  datetime
	   ,end_date  datetime
	   ,Email Varchar(50)
	)

declare @brch_id as numeric
declare @dept_id as numeric
declare @desig_id as numeric 
declare @grade_id as numeric
declare @appraisal_duration as numeric
declare @Actual_CTC as numeric
		
		
--If condition Remove by Ripal 22July2014
--select emp_id,datediff(mm,max(increment_effective_date),getdate()) from dbo.T0095_INCREMENT group by emp_id,cmp_id having cmp_id=@cmp_id	

		Declare curUser cursor Local for 
			 select branch_id,dept_id,desig_id,grade_id,appraisal_duration,Actual_CTC 
					from dbo.T0050_HRMS_APPRAISAL_SETTING WITH (NOLOCK)
					where cmp_id=@cmp_id
		  open curUser
			
			Fetch next from curUser Into @brch_id,@dept_id,@desig_id,@grade_id,@appraisal_duration,@Actual_CTC
			while @@Fetch_Status = 0
				begin
				
				  insert into #temp(emp_id,effective_date,branch_id,Grade_id)
				  select emp_id,increment_effective_date,branch_id,grd_id
						from dbo.T0095_INCREMENT WITH (NOLOCK)
						where INCREMENT_id IN (SELECT MAX(INCREMENT_ID) FROM dbo.T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID=@CMP_ID GROUP BY EMP_ID) 
							  AND branch_id=@brch_id 
						      and grd_id=@grade_id 
						      and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
							  and Isnull(dept_id,0) = isnull(@dept_id ,Isnull(dept_id,0)) 
							  AND CMP_ID=@CMP_ID
				  and Basic_Salary >=@Actual_CTC --06-Jul-2010 Nikunj
				  
				  insert into #temp_data(effective_date,emp_id,duration,appraisal_duration)
						 select max(effective_date),emp_id , (datediff(dd,max(effective_date),getdate())/30),@appraisal_duration
								from #temp group by emp_id,branch_id,Grade_id
								having branch_id = @brch_id And
									   Grade_id = @grade_id
		
				  --if (@branch_id > 0)
				  -- begin
						--insert into @temp_data(effective_date,emp_id,duration,appraisal_duration)
						--select max(effective_date),emp_id ,(datediff(dd,max(effective_date),getdate())/30),@appraisal_duration 
						--		from @temp 
						--		group by emp_id,branch_id 
						--		having branch_id = @branch_id
				  -- end
				  --else
				  -- begin
						-- insert into @temp_data(effective_date,emp_id,duration,appraisal_duration)
						-- select max(effective_date),emp_id ,(datediff(dd,max(effective_date),getdate())/30),@appraisal_duration 
						--		from @temp 
						--		group by emp_id,branch_id 
				  -- end
				   
				 Fetch next from curUser Into @brch_id,@dept_id,@desig_id,@grade_id,@appraisal_duration,@Actual_CTC
				 
    			end
			Close curUser
			Deallocate curUser 
			
			--select * from @temp
			--select * from @temp_data
	
	insert into #temp_final(emp_id,start_date,end_date)				
	select distinct emp_id,effective_date as start_date,dateadd(dd,datediff(dd,effective_date,getdate()),effective_date)as end_date  
		from #temp_data
	 where emp_id not in (select emp_id from dbo.v0090_Hrms_Appraisal_Status_Report where for_date>=effective_date and is_accept =0) --is_accept = 2 to 0 change by Ripal 23July2014
		   And emp_id not in (select emp_id from dbo.v0090_Hrms_Appraisal_Status_Report where for_date>=effective_date and is_accept =2
											and	(datediff(dd,End_date,getdate())/30) < appraisal_duration)
		   And duration >= appraisal_duration
	 
if @Dashboard=1
	Begin
		select Count(q.Emp_Id) As Count  
			from  #temp_final q left outer join 
				  t0080_emp_master f WITH (NOLOCK) on f.emp_id=q.emp_id
			where f.Emp_Left<>'Y' --Added By Ripal 22July2014
	End
Else
	Begin
		
		select q.*,f.Alpha_Emp_Code + '-' + f.emp_full_name as Emp_Full_Name,f.Work_Email,F.Mobile_No,
			   f.Branch_Name,f.Grd_Name,0 as Is_Lock 
			from  #temp_final q left join 
			      V0080_Employee_Master f on f.emp_id=q.emp_id 
			where f.Emp_Left<>'Y' -- added by sneha 10sep2013
			order by f.Branch_Name,f.Grd_Name --Added by Ripal 23July2014
	End

--if @Dashboard=1
--Begin		
--		--select emp_id,datediff(mm,max(increment_effective_date),getdate()) from dbo.T0095_INCREMENT group by emp_id,cmp_id having cmp_id=@cmp_id
	
--		Declare curUser cursor Local for 
--			 select branch_id,dept_id,desig_id,grade_id,appraisal_duration,Actual_CTC from dbo.T0050_HRMS_APPRAISAL_SETTING where cmp_id=@cmp_id			 
--		  open curUser			
--			Fetch next from curUser Into @brch_id,@dept_id,@desig_id,@grade_id,@appraisal_duration,@Actual_CTC
--			while @@Fetch_Status = 0
--				begin								
--				  insert into @temp(emp_id,effective_date,branch_id)
--				  select emp_id,increment_effective_date,branch_id from dbo.T0095_INCREMENT where INCREMENT_id IN
--				  (SELECT MAX(INCREMENT_ID) FROM dbo.T0095_INCREMENT GROUP BY EMP_ID)AND  branch_id=@brch_id 
--				  and grd_id=@grade_id and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
--				  and Isnull(dept_id,0) = isnull(@dept_id ,Isnull(dept_id,0)) AND CMP_ID=@CMP_ID
--				  and Basic_Salary >=@Actual_CTC --06-Jul-2010 Nikunj			  
				  			  
--				  --Change the From Gross salary to Basic Salary Because gross Salary is not inserted properly sometime.
--				  --and Gross_Salary >=@Actual_CTC
				  
--				  --and dept_id=@dept_id and desig_id=@desig_id 				  
--				  if (@branch_id > 0)
--				   begin
--					insert into @temp_data(effective_date,emp_id,duration,appraisal_duration)
--				    select max(effective_date),emp_id , datediff(mm,max(effective_date),getdate()),@appraisal_duration from @temp group by emp_id,branch_id having branch_id = @branch_id
--				   end
--				  else
--				   begin
--					 insert into @temp_data(effective_date,emp_id,duration,appraisal_duration)
--				     select max(effective_date),emp_id , datediff(mm,max(effective_date),getdate()),@appraisal_duration from @temp group by emp_id,branch_id 
--				   end 
--				 Fetch next from curUser Into @brch_id,@dept_id,@desig_id,@grade_id,@appraisal_duration,@Actual_CTC
--    			end
--			Close curUser
--			Deallocate curUser 				
			    
--				insert into @temp_final(emp_id,start_date,end_date)				
--				select distinct emp_id,effective_date as start_date, dateadd(mm,duration,effective_date)as end_date  from @temp_data
--				 --where emp_id not in (select emp_id from dbo.V0090_Hrms_Appraisal_Initiation_Detail where for_date>=effective_date and is_accept =2)
--				 where emp_id not in (select emp_id from dbo.v0090_Hrms_Appraisal_Status_Report where for_date>=effective_date and is_accept =2)
--				 And  duration >= appraisal_duration 		  
--		  select Count(q.Emp_Id) As Count  from  @temp_final q left outer join dbo.t0080_emp_master f on f.emp_id=q.emp_id
		  
--Return
--End
--Else
--Begin			
--		--select emp_id,datediff(mm,max(increment_effective_date),getdate()) from dbo.T0095_INCREMENT group by emp_id,cmp_id having cmp_id=@cmp_id	
--		Declare curUser cursor Local for 
--			 select branch_id,dept_id,desig_id,grade_id,appraisal_duration,Actual_CTC from dbo.T0050_HRMS_APPRAISAL_SETTING where cmp_id=@cmp_id
			 
--		  open curUser
			
--			Fetch next from curUser Into @brch_id,@dept_id,@desig_id,@grade_id,@appraisal_duration,@Actual_CTC
--			while @@Fetch_Status = 0
--				begin
				

--				  insert into @temp(emp_id,effective_date,branch_id)
--				  select emp_id,increment_effective_date,branch_id from dbo.T0095_INCREMENT where INCREMENT_id IN
--				  (SELECT MAX(INCREMENT_ID) FROM dbo.T0095_INCREMENT GROUP BY EMP_ID)AND  branch_id=@brch_id 
--				  and grd_id=@grade_id and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
--				  and Isnull(dept_id,0) = isnull(@dept_id ,Isnull(dept_id,0)) AND CMP_ID=@CMP_ID
--				  and Basic_Salary >=@Actual_CTC--06-Jul-2010 Nikunj
--				  --and Gross_Salary >=@Actual_CTC
				  
--				  --and dept_id=@dept_id and desig_id=@desig_id 
--				  if (@branch_id > 0)
--				   begin
--					insert into @temp_data(effective_date,emp_id,duration,appraisal_duration)
--				    select max(effective_date),emp_id , datediff(mm,max(effective_date),getdate()),@appraisal_duration from @temp group by emp_id,branch_id having branch_id = @branch_id
--				   end
--				  else
--				   begin
--					 insert into @temp_data(effective_date,emp_id,duration,appraisal_duration)
--				     select max(effective_date),emp_id , datediff(mm,max(effective_date),getdate()),@appraisal_duration from @temp group by emp_id,branch_id 
--				   end 
--				 Fetch next from curUser Into @brch_id,@dept_id,@desig_id,@grade_id,@appraisal_duration,@Actual_CTC
--    			end
--			Close curUser
--			Deallocate curUser 
--			--select * from @temp_data
			
--				insert into @temp_final(emp_id,start_date,end_date)				
--				select distinct emp_id,effective_date as start_date, dateadd(mm,duration,effective_date)as end_date  from @temp_data
--				 --where emp_id not in (select emp_id from dbo.V0090_Hrms_Appraisal_Initiation_Detail where for_date>=effective_date and is_accept =2)
--				 where emp_id not in (select emp_id from dbo.v0090_Hrms_Appraisal_Status_Report where for_date>=effective_date and is_accept =2)
--				 And  duration >= appraisal_duration 
		  
--		--  select q.*,f.emp_full_name,f.Work_Email,F.Mobile_No,f.Branch_ID,f.Grd_ID from  @temp_final q left outer join dbo.t0080_emp_master f on f.emp_id=q.emp_id where f.Emp_Left<>'Y'--modified on jan 25 2013
--	  select q.*,f.Alpha_Emp_Code + '-' + f.emp_full_name as Emp_Full_Name,f.Work_Email,F.Mobile_No,f.Branch_Name,f.Grd_Name from  @temp_final q left join dbo.V0080_Employee_Master f on f.emp_id=q.emp_id where f.Emp_Left<>'Y' -- added by sneha 10 sep 2013
--RETURN
--End


