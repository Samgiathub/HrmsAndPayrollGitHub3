

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Inventory]
	@Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID 
  
	declare @col as numeric(18,0)
  
	create table #finaltable
	(
		Emp_ID				numeric(18,0),
		Emp_Full_Name		varchar(100),
		Alpha_Emp_Code		varchar(100),
		Date_Of_Join		datetime,
		Present_Street		varchar(200),
		Date_Of_Birth		datetime,
		Blood_Group			varchar(50),
		Gender				varchar(50),
		zip_code			varchar(50),
		Dept_Name			varchar(100),
		Desig_Name			varchar(100),			
		Qual_Name			varchar(100),
		Experience			varchar(100),
		Cmp_name			varchar(100),
		cmp_Address			varchar(200),
		cmp_logo			image,
		Branch_id			numeric(18,0)
	)
	
	create table #finaltraining
	(
		Emp_ID				numeric(18,0),
		Training_Apr_Id		numeric(18,0),
		Training_Name       varchar(100),
		Training_code		varchar(50),
		Training_StartTime	varchar(50),
		Training_EndTime	varchar(50),
		Training_StartDate	datetime,
		Training_EndDate	datetime,
		Duration			numeric(18,2),--Mukti(21072017)
		Faculty				varchar(100),
		Remarks				varchar(200)
	)
  
  
	declare cur_emp cursor
	for
		select emp_id from #Emp_Cons
	open cur_emp
		fetch next from cur_emp into @col
		while @@FETCH_STATUS=0
			begin
				--get emp details
				insert into #finaltable(Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Date_Of_Join,Present_Street,Date_Of_Birth,Blood_Group,Gender,zip_code,
								Dept_Name,Desig_Name,Qual_Name,Cmp_name,cmp_Address,cmp_logo,Experience,Branch_id)
				select e.Emp_ID,Emp_Full_Name,Alpha_Emp_Code,e.Date_Of_Join,e.Present_Street,e.Date_Of_Birth,e.Blood_Group,
					case when e.Gender ='F' then 'Female' else 'Male' end,e.zip_code,
				       d.Dept_Name,dg.Desig_Name,(q.Qual_Name+'-'+eq.Specialization) Qual_Name,c.Cmp_Name,c.Cmp_Address,c.cmp_logo,
						  case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar)<>0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar) + ' years ' else '' end +
						  case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar)<>0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar) + ' months ' else '' end +
						  case when cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar)<>0 then cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar) + ' days' else '' end as experience,i.Branch_ID					
				from T0080_EMP_MASTER e WITH (NOLOCK) inner join 
				T0095_INCREMENT I WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col) left join
				T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.Dept_ID left join
				T0040_DESIGNATION_MASTER Dg WITH (NOLOCK) on dg.Desig_Id = i.Desig_Id left join
				T0090_EMP_QUALIFICATION_DETAIL EQ WITH (NOLOCK) on EQ.Emp_ID = EQ.Emp_ID and EQ.Row_ID = (select MAX(Row_ID) from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) where Emp_ID=@col)left join
				T0040_QUALIFICATION_MASTER Q WITH (NOLOCK) on q.Qual_ID = eq.Qual_ID inner join
				T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id = e.Cmp_ID 
				where e.Cmp_ID = @Cmp_ID and e.Emp_ID=@col	
				
				--get emp training details
				insert into #finaltraining(Emp_ID,Training_Apr_Id,Training_Name,Training_code,Training_StartTime,Training_EndTime,Training_StartDate,Training_EndDate,Duration,Faculty,Remarks)
				select E.Emp_ID,e.Training_Apr_ID,t.Training_name,isnull(a.Training_Code,a.Training_Apr_ID),a.Training_FromTime,a.Training_ToTime,TST.From_date,TST.To_date,TS.duration,Faculty,a.Comments   
				from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL E WITH (NOLOCK) inner join 
					 T0150_EMP_Training_INOUT_RECORD I WITH (NOLOCK) on I.emp_id = e.Emp_ID and i.Training_Apr_Id=e.Training_Apr_ID inner join
					 T0120_HRMS_TRAINING_APPROVAL A WITH (NOLOCK) on a.Training_Apr_ID = e.Training_Apr_ID inner Join
					 T0040_Hrms_Training_master T WITH (NOLOCK) on t.Training_id = a.Training_id inner JOIN
					(
						SELECT T0120_HRMS_TRAINING_Schedule.Training_App_ID,SUM(nodays)nodays,SUM(CONVERT(numeric(18,2),(duration)))duration
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
						GROUP BY T0120_HRMS_TRAINING_Schedule.Training_App_ID
					)TS	ON A.Training_App_ID = TS.Training_App_ID inner JOIN 
					(
						SELECT MIN(From_date)From_date,MAX(To_date)To_date,Training_App_ID						
						FROM   T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
						GROUP  BY Training_App_ID
					)TST on TST.Training_App_ID = A.Training_App_ID 
				where E.Emp_ID = @col --and e.cmp_id=@Cmp_ID --commented on 29122015
				fetch next from cur_emp into @col
			end
	close cur_emp
	deallocate cur_emp	
	
	select #finaltable.Emp_ID,Emp_Full_Name,Alpha_Emp_Code,convert(varchar(12),Date_Of_Join,101)Date_Of_Join,Present_Street,convert(varchar(12),Date_Of_Birth,101)Date_Of_Birth,Blood_Group,
	Gender ,zip_code,
	Dept_Name,Desig_Name,Qual_Name,Experience,Cmp_name,case when isnull(Branch_id,0) <> 0 then (select case when isnull(Branch_Address,'') = '' then cmp_Address else Branch_Address  end from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=#finaltable.Branch_id) else cmp_Address end cmp_Address,cmp_logo from #finaltable --inner join 
	--#finaltraining on #finaltraining.Emp_ID = #finaltable.Emp_ID 
		
	select distinct Training_Apr_Id,Emp_ID,(Training_code+ '-' +Training_Name)Training_Name,
	training_StartDate, training_endDate, Duration,Faculty,Remarks --(Training_StartTime+ '-' +Training_EndTime)Duration commented by Mukti(21072017)
	 from #finaltraining order by training_StartDate asc
	
	drop table #finaltable
	drop table #finaltraining
END

