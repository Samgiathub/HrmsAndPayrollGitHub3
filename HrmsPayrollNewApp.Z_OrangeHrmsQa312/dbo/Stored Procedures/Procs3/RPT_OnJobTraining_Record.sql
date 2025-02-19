


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_OnJobTraining_Record]
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
	
	 create table #finaltable
	(
		Emp_ID				numeric(18,0),
		Training_Apr_ID		numeric(18,0),
		Emp_Full_Name		varchar(100),
		Alpha_Emp_Code		varchar(100),
		Date_Of_Join		datetime,
		Dept_Name			varchar(100),
		Desig_Name			varchar(100),			
		Qual_Name			varchar(100),
		Experience			varchar(100),
		Training_Period		int,
		Training_Name		varchar(150),
		Training_Date		DATETIME,
		faculty				varchar(100),
		branch_id			numeric(18,0)
	)
	
	declare @col as numeric(18,0)
	
	declare cur_emp cursor
	for
		select emp_id from #Emp_Cons
	open cur_emp
		fetch next from cur_emp into @col
		while @@FETCH_STATUS=0
			Begin
				 insert into #finaltable(Emp_ID,Training_Apr_ID,Emp_Full_Name,Alpha_Emp_Code,Qual_Name,Desig_Name,Dept_Name,Date_Of_Join,
						Experience,Training_Name,Training_Date,faculty,Training_Period,branch_id)
				 Select distinct TE.Emp_ID,A.Training_Apr_ID,Emp_Full_Name,Alpha_Emp_Code,(q.Qual_Name+'-'+eq.Specialization) Qual_Name,dg.Desig_Name,d.Dept_Name,Date_Of_Join
				,case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar)<> 0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar) +  ' years ' else '' end +
				 case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar) <> 0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar) + ' months ' else '' end  +
			     case when cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar)<>0 then cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar) + ' days' else '' end as experience,
			     (A.training_code + '-' + M.Training_name),TST.From_date,A.Faculty,TS.nodays,i.Branch_ID 
			     --CONVERT(varchar(15),A.Training_Date,103) + '-' + CONVERT(varchar(15),Training_End_Date,103)Training_Date,			     
				From  T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) inner join
					  T0150_EMP_Training_INOUT_RECORD TI WITH (NOLOCK) on TI.emp_id = TE.Emp_ID and Ti.Training_Apr_Id=te.Training_Apr_ID inner join
					  T0120_HRMS_TRAINING_APPROVAL A WITH (NOLOCK) on A.Training_Apr_ID = TE.Training_Apr_ID inner join
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
					  )TST on TST.Training_App_ID = A.Training_App_ID INNER JOIN
					  T0030_Hrms_Training_Type TT WITH (NOLOCK) on TT.Training_Type_ID = A.Training_Type inner join
					  T0040_Hrms_Training_master M WITH (NOLOCK) on M.Training_id = A.Training_id inner Join
					  T0080_EMP_MASTER e WITH (NOLOCK) on e.emp_id = te.Emp_ID inner join 
					  T0095_INCREMENT I WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@col) left join
					  T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.Dept_ID left join
					  T0040_DESIGNATION_MASTER Dg WITH (NOLOCK) on dg.Desig_Id = i.Desig_Id left join
					  T0090_EMP_QUALIFICATION_DETAIL EQ WITH (NOLOCK) on EQ.Emp_ID = EQ.Emp_ID and EQ.Row_ID = (select MAX(Row_ID) from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) where Emp_ID=@col)left join
					  T0040_QUALIFICATION_MASTER Q WITH (NOLOCK) on q.Qual_ID = eq.Qual_ID 
				Where TE.Emp_ID=@col and A.Apr_Status=1 and tt.Type_OJT=1 --TE.Cmp_ID = @Cmp_ID and 
				fetch next from cur_emp into @col
			End
	close cur_emp
	deallocate cur_emp
	
	
	select Emp_ID,Training_Apr_ID,Emp_Full_Name,Alpha_Emp_Code,Qual_Name,Desig_Name,Dept_Name,CONVERT(varchar(15),Date_Of_Join,103)as Date_Of_Join, Experience,Training_Name,Training_Date,faculty,Training_Period
		   ,c.Cmp_Name,case when isnull(Branch_id,0) <> 0 then (select case when isnull(Branch_Address,'') = '' then c.cmp_Address else Branch_Address  end from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID=#finaltable.Branch_id) else c.cmp_Address end cmp_Address,c.cmp_logo
	from #finaltable inner join T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id=@Cmp_ID
	
	drop table #finaltable
	  
END


