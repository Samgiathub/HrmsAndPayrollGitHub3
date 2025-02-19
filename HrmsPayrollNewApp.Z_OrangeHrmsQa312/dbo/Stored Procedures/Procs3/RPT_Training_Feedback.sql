

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Feedback]
	@Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max)
	,@Training_ID	numeric(18,0)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	--added on 16 dec 2015
	if @Branch_ID ='0'
		set @Branch_ID =NULL
	if @Cat_ID ='0'
		set @Cat_ID =NULL
	if @Grd_ID ='0'
		set @Grd_ID =NULL
	if @Type_ID ='0'
		set @Type_ID =NULL
	if @Dept_ID ='0'
		set @Dept_ID =NULL
	if @Desig_ID ='0'
		set @Desig_ID =NULL
	
	
	
	create table #finalTable
	(
		emp_id				numeric(18,0),
		Training_apr_id		numeric(18,0),
		Emp_Full_Name		varchar(100),
		Alpha_Emp_Code		varchar(100),
		Dept_Name			varchar(100),
		Desig_name			varchar(100),
		Training_Id			numeric(18,0),
		Training_Name		varchar(200),
		Training_FromDate	datetime,
		Training_ToDate		datetime,
		Training_FromTime	datetime,
		Training_ToTime		datetime,
		Venue				varchar(100),
		Faculty				varchar(100),
		Dob					datetime,
		Doj					datetime,
		Qualification		varchar(100),
		Emp_Address			varchar(500),
		Training_Code		varchar(50),
		Branch_id			numeric(18,0)
	)
	create table #final
	(
		Question			nvarchar(500),
		Question_Type		varchar(50),
		Training_Que_ID		numeric(18,0),
		emp_Id				numeric(18,0),
		Training_Id			numeric(18,0),
		Training_Apr_ID		numeric(18,0),
		Answer				nvarchar(Max)
	)
	
	
	declare @col as numeric(18,0)
	declare @col1 as numeric(18,0)
	declare @queid as numeric(18,0)
	declare @col2 as numeric(18,0)
	
	insert into #FinalTable(emp_id,Training_apr_id,Emp_Full_Name,Alpha_Emp_Code,Dept_Name,Training_Id,Training_Name,
							Training_FromDate,Training_ToDate,Training_FromTime,Training_ToTime,Venue,Faculty,Desig_name,
							Dob,Doj,Qualification,Emp_Address,Training_Code,Branch_id)
	select distinct t.Emp_ID,t.Training_Apr_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,a.Training_id,m.Training_name,
			TST.From_date,TST.To_date,TST.From_Time,TST.To_Time,a.Place,a.Faculty,dg.Desig_Name,
			convert(varchar(12),e.Date_Of_Birth,101),convert(varchar(12),e.Date_Of_Join,101),(q.Qual_Name +':'+eq.Specialization) ,(e.Present_Street + ' ' + e.Present_City + ' ' + e.Present_Post_Box + ' ' + e.Present_City +' '+ e.Present_State),
			isnull(a.Training_Code,a.Training_Apr_ID),i.Branch_ID
	from t0130_HRMS_TRAINING_EMPLOYEE_DETAIL T WITH (NOLOCK) inner join 
	  T0150_EMP_Training_INOUT_RECORD r WITH (NOLOCK) on r.emp_id = t.Emp_ID and r.Training_Apr_ID=t.Training_Apr_ID inner join
	  V0120_HRMS_TRAINING_APPROVAL A on A.Training_Apr_ID = t.Training_Apr_ID inner join -- Changed by Gadriwala Muslim 28112016
	  (
		SELECT T0120_HRMS_TRAINING_Schedule.Training_App_ID,SUM(nodays)nodays,SUM(CONVERT(numeric(18,2),(duration)))duration
		--,TS1.From_Time,TS1.To_Time
		FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) INNER JOIN
					(
						SELECT (DATEDIFF(DAY,From_date,To_date))+1 nodays,To_date,From_date,Training_App_ID,
								(REPLACE(CONVERT(varchar(5),(SELECT CONVERT(DATETIME, ISNULL(to_time,'')))-(SELECT CONVERT(DATETIME,ISNULL(from_time,''))),114),':','.'))duration,
							From_Time,To_Time
						FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
						GROUP BY Training_App_ID,To_date,From_date,From_Time,To_Time
					)TS1 on T0120_HRMS_TRAINING_Schedule.Training_App_ID = TS1.Training_App_ID and 
					T0120_HRMS_TRAINING_Schedule.From_date = ts1.From_date and 
					T0120_HRMS_TRAINING_Schedule.To_date = ts1.To_date
					GROUP BY T0120_HRMS_TRAINING_Schedule.Training_App_ID,TS1.From_Time,TS1.To_Time
				)TS	ON A.Training_App_ID = TS.Training_App_ID inner JOIN 
				(
					SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID,
					MIN(CONVERT(TIME,From_Time))From_Time,MAX(CONVERT(TIME,To_Time))To_Time						
					FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
					GROUP  BY Training_App_ID
	  )TST on TST.Training_App_ID = A.Training_App_ID INNER JOIN
	  T0040_Hrms_Training_master M WITH (NOLOCK) on m.Training_id = a.Training_id inner join
	  T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = t.Emp_ID inner join
	  T0095_INCREMENT I WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and i.Increment_ID = (select MAX(increment_id) from T0095_INCREMENT WITH (NOLOCK) where emp_id=e.Emp_ID) left join
	  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID  left join
	  T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id left join
	  T0090_EMP_QUALIFICATION_DETAIL EQ  WITH (NOLOCK) on EQ.Emp_ID = e.Emp_ID and eq.Row_ID = (select MAX(row_id) from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) where Emp_ID = e.emp_id) left join
	  T0040_QUALIFICATION_MASTER Q WITH (NOLOCK) on q.Qual_ID = eq.Qual_ID 
	where T.Cmp_ID = @Cmp_ID and t.Training_Apr_ID=@Training_ID and (t.Emp_tran_status=1 or t.Emp_tran_status=4)
	and (i.Branch_ID  in (ISNULL(@Branch_ID,i.Branch_ID)) or i.Branch_ID is null)  and (i.Dept_ID  in (ISNULL(@Dept_ID,i.Dept_ID)) or i.Dept_ID is null) 
		and (i.Desig_Id in (ISNULL(@Desig_ID,i.desig_id)) or i.desig_id is null)
		and (i.Cat_ID  in (ISNULL(@cat_id,i.Cat_ID)) or i.Cat_ID is null) 
		and (i.Grd_ID  in (ISNULL(@Grd_ID,i.Grd_ID)) or i.Grd_ID is null)
		and (i.Type_ID  in (ISNULL(@Type_ID,i.Type_ID))or i.Type_ID is null)
		
	
	declare cur cursor
	for
		select  training_id,emp_id from #finalTable
	open cur
		fetch next from cur into @col1,@col
		while @@FETCH_STATUS = 0
		begin
			insert into #final (Question,Question_Type,Training_Que_ID,emp_Id,Training_Id,Training_Apr_ID)
			select Question ,Question_Type,Training_Que_ID,@col,@col1,@Training_ID
			from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK)
			where Cmp_Id = @Cmp_ID and Questionniare_Type=0 
			--and training_id like + '%' + cast(@col1 as varchar(18))--commnted by sneha on 16 dec 2015
			and exists(select Data from dbo.Split(Training_Id, '#') PB Where pb.Data=cast(@col1 as varchar(18)))--added by sneha on 16 dec 2015 
			order by T0150_HRMS_TRAINING_Questionnaire.Sorting_No 
			
			declare cur_emp cursor
			for
				select training_Que_id from #final where emp_id = @col and Training_Id=@col1
			open cur_emp
				fetch next from cur_emp into @col2
				while @@FETCH_STATUS = 0
				begin
					update #final	
					set Answer=a.Answer
					from (select Answer from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where  Training_Apr_ID=@Training_ID and emp_Id=@col and Training_Id=@col1 and Tran_Question_Id=@col2)a
					where emp_Id=@col and Training_Id=@col1 and Training_Que_ID=@col2 and Training_Apr_ID=@Training_ID --Cmp_Id = @Cmp_ID and removed on 29 dec 2015
					fetch next from cur_emp into @col2
				end
			close cur_emp
			deallocate cur_emp
			fetch next from cur into @col1,@col
		End
	close cur
	deallocate cur
	
		
	select #FinalTable.emp_id,
					Training_apr_id		,
					Emp_Full_Name	,
					Alpha_Emp_Code,
					Dept_Name	,
					Desig_name,
					Training_Id	,
					Training_Name,
					Training_FromDate as Training_FromDate,
					Training_ToDate as Training_ToDate,
					Training_FromTime,
					Training_ToTime	,
					Venue	,
					Faculty	,
					convert(varchar(12),Dob,101)Dob,
					convert(varchar(12),Doj,101)Doj	,
					Qualification,
					Emp_Address	,
					Training_Code,
					c.Cmp_Name,
					case when isnull(Branch_id,0) <> 0 then (select case when isnull(Branch_Address,'') = '' then c.cmp_Address else Branch_Address  end from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=#finaltable.Branch_id) else c.cmp_Address end cmp_Address,c.cmp_logo from #FinalTable inner join 
			T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id =@Cmp_ID	order by emp_Id	
	
	select * from #final order by emp_Id 
	
	drop table #final 
	drop table #finalTable
END

