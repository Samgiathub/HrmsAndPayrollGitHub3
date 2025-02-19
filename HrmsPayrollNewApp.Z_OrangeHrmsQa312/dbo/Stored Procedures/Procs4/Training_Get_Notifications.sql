
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Training_Get_Notifications 9,1,0
-- exec Training_Get_Notifications 9,0,0
-- exec Training_Get_Notifications 9,0,1
-- exec Training_Get_Notifications 9,1,1
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Training_Get_Notifications]
	  @cmp_id numeric(18,0)
	 ,@type int = 0  --0 as 1 month and 1 as 1 year, no training given
	 ,@OJT int = 1 --0 only OJTs and 1 as all, training type
	 ,@dept numeric(18,0) = null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	declare @Odept numeric(18,0)
	declare @col numeric(18,0)
	
	create table #final
	(
		 emp_id numeric(18,0)
		,emp_full_name varchar(100)
		,alpha_emp_code varchar(100)
		,doj datetime
		,dept_name varchar(100)
		,dept_id numeric(18,0)
	)
	--select i.emp_id
	--	from T0095_INCREMENT i left join 
	--	T0080_EMP_MASTER e on e.Emp_ID = i.Emp_ID 
	--	where i.Cmp_ID = 149 and i.Dept_ID = 343
	--	and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=149
	--	 and Increment_ID=i.Increment_ID)
	--	and e.emp_left <> 'Y'
		
	IF @dept =0 
		SET @dept = NULL

	if @OJT = 0
	begin
		declare curdept  cursor
		for  --dept where ojt is applicable
			select  Dept_Id
			from T0040_DEPARTMENT_MASTER WITH (NOLOCK)
			where Cmp_Id = @cmp_id and OJT_Applicable = 1 and dept_id = isnull(@dept,dept_id)
		open curdept
			fetch next from curdept into @Odept
			while @@FETCH_STATUS=0
			begin				
				if @type = 0
					begin
						declare cur  cursor
						for 
							select i.emp_id 
							from T0095_INCREMENT i WITH (NOLOCK) left join 
							T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = i.Emp_ID and i.Increment_ID=e.Increment_ID
							where i.Cmp_ID = @cmp_id and i.Dept_ID = @Odept
							--and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_ID=i.Increment_ID)
							and e.Date_Of_Join >= DATEADD(MM,-1,GETDATE()) and e.Date_Of_Join <= GETDATE() and e.emp_left <> 'Y'
						open cur
							fetch next from cur into @col
							while @@FETCH_STATUS = 0
							begin		
									
								if not exists(select 1 from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_ID=@col and (Emp_tran_status = 1 or Emp_tran_status=4) and cmp_id=@cmp_id)
									begin
										insert into #final (emp_id,emp_full_name,alpha_emp_code,dept_name,dept_id,doj)						 
										select  e.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,i.Dept_ID,e.Date_Of_Join
										from T0080_EMP_MASTER e WITH (NOLOCK)
										inner join T0095_INCREMENT i WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and i.Increment_ID=e.Increment_ID 
										--and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID = @cmp_id and Emp_ID=@col)
										left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.Dept_ID 
										where e.Cmp_ID=@cmp_id and e.Emp_ID=@col and i.Dept_ID=@Odept 
									end
								fetch next from cur into @col
							end
						close cur
						deallocate cur
					End
				Else 
					begin
						declare cur  cursor
						for 
							select i.emp_id
							from T0095_INCREMENT i WITH (NOLOCK) left join 
							T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = i.Emp_ID 
							where i.Cmp_ID = @cmp_id and i.Dept_ID = @Odept
							and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Cmp_ID=@cmp_id and Increment_ID=i.Increment_ID)
							and e.emp_left <> 'Y'
							--and e.Date_Of_Join >= DATEADD(YYYY,-1,GETDATE()) and e.Date_Of_Join <= GETDATE()
						open cur
							fetch next from cur into @col
							while @@FETCH_STATUS = 0
							begin
							
								if not exists(select 1 from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL e WITH (NOLOCK) inner join  T0120_HRMS_TRAINING_APPROVAL t WITH (NOLOCK) on t.Training_Apr_ID = e.Training_Apr_ID inner join T0030_Hrms_Training_Type h WITH (NOLOCK) on h.Training_Type_ID = t.Training_Type  where Emp_ID=@col and (Emp_tran_status = 1 or Emp_tran_status=4) and e.cmp_id=@cmp_id and t.Training_Date >= DATEADD(YYYY,-1,GETDATE()) and t.Training_Date <= GETDATE() and t.Apr_Status = 1 and h.Type_OJT = 1)
									begin
									--select 333,@col
										insert into #final (emp_id,emp_full_name,alpha_emp_code,dept_name,dept_id,doj)						 
										select  e.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,i.Dept_ID,e.Date_Of_Join
										from T0080_EMP_MASTER e WITH (NOLOCK)
										inner join T0095_INCREMENT i WITH (NOLOCK) on i.Increment_ID = e.Increment_ID 
										--and i.Increment_ID = (select MAX(Increment_ID) 
										--	  from T0095_INCREMENT where Cmp_ID = @cmp_id and Emp_ID=@col)
											  left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.Dept_ID 
										where e.Cmp_ID=@cmp_id and e.Emp_ID=@col and i.Dept_ID=@Odept 
									end
								fetch next from cur into @col
							end
						close cur
						deallocate cur
					end
				fetch next from curdept into @Odept
			End
		close curdept
		deallocate curdept
	end
Else
	begin
		if @type = 0
		begin
			declare cur  cursor
			for 
				select i.emp_id
				from T0095_INCREMENT i WITH (NOLOCK) left join 
				T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = i.Emp_ID and i.Increment_ID=e.Increment_ID
				where i.Cmp_ID = @cmp_id 
				--and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id and Increment_ID=i.Increment_ID)
				and e.Date_Of_Join >= DATEADD(MM,-1,GETDATE()) and e.Date_Of_Join <= GETDATE() and e.emp_left <> 'Y'
			open cur
				fetch next from cur into @col
				while @@FETCH_STATUS = 0
				begin
					if not exists(select 1 from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_ID=@col and (Emp_tran_status = 1 or Emp_tran_status=4) and cmp_id=@cmp_id)
						begin
							insert into #final (emp_id,emp_full_name,alpha_emp_code,dept_name,dept_id,doj)						 
							select  e.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,i.Dept_ID,e.Date_Of_Join
							from T0080_EMP_MASTER e WITH (NOLOCK) inner join T0095_INCREMENT i WITH (NOLOCK)
								  on i.Emp_ID = e.Emp_ID and i.Increment_ID=e.Increment_ID
								  -- and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID = @cmp_id and Emp_ID=@col)
								  left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.Dept_ID 
							where e.Cmp_ID=@cmp_id and e.Emp_ID=@col 
						end
					fetch next from cur into @col
				end
			close cur
			deallocate cur
		End
	Else 
		begin	
		
			declare cur  cursor
			for 
				select i.emp_id
				from T0095_INCREMENT i WITH (NOLOCK) left join 
				T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = i.Emp_ID and i.Increment_ID=e.Increment_ID
				where i.Cmp_ID = @cmp_id 
				--and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID=@cmp_id 
				--and Increment_ID=i.Increment_ID)
				and e.emp_left <> 'Y'
				--and e.Date_Of_Join >= DATEADD(YYYY,-1,GETDATE()) and e.Date_Of_Join <= GETDATE()
			open cur
				fetch next from cur into @col
				while @@FETCH_STATUS = 0
				begin
				---select 777,@col
					if not exists(select 1 from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL e WITH (NOLOCK)
					inner join  T0120_HRMS_TRAINING_APPROVAL t WITH (NOLOCK) on t.Training_Apr_ID = e.Training_Apr_ID  
					where Emp_ID=@col and (Emp_tran_status = 1 or Emp_tran_status=4) and e.cmp_id=@cmp_id and t.Training_Date >= DATEADD(YYYY,-1,GETDATE()) and t.Training_Date <= GETDATE() and t.Apr_Status = 1)
						begin
							insert into #final (emp_id,emp_full_name,alpha_emp_code,dept_name,dept_id,doj)						 
							select  e.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,inc.Dept_ID,e.Date_Of_Join
							from T0080_EMP_MASTER e WITH (NOLOCK) INNER JOIN
					       	T0095_INCREMENT Inc WITH (NOLOCK) on Inc.Emp_ID = e.Emp_ID INNER JOIN
							(SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
								FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
									 (
										SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
										FROM T0095_INCREMENT WITH (NOLOCK)
										GROUP BY Emp_ID
									 ) inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
								GROUP By T0095_INCREMENT.Emp_ID
							)inc2 ON inc2.Increment_ID = inc.Increment_ID and inc2.Emp_ID = inc.Emp_ID 	
								  --inner join T0095_INCREMENT i
								  --on i.Emp_ID = e.Emp_ID and 
								  --i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT where Cmp_ID = @cmp_id and Emp_ID=@col)
								  left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = inc.Dept_ID 
							where e.Cmp_ID=@cmp_id and e.Emp_ID=@col 
						end
					fetch next from cur into @col
				end
			close cur
			deallocate cur
		end
	end

select distinct emp_id,emp_full_name,alpha_emp_code,dept_id,dept_name,convert(VARCHAR(15),doj,103)doj
from #final order by  dept_name,alpha_emp_code

drop table #final
END

