


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:

-- =============================================
CREATE PROCEDURE [dbo].[RPT_Training_Record]
	@Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max)  = null
	,@Cat_ID		varchar(Max) = null
	,@Grd_ID		varchar(Max)  = null
	,@Type_ID		varchar(Max)  = null
	,@Dept_ID		varchar(Max)  = null
	,@Desig_ID		varchar(Max) = null
	,@Training_ID	numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	Create Table #FinalTable
	(
		Emp_ID				numeric(18,0),
		Emp_Full_Name		varchar(100),
		Alpha_Emp_Code		varchar(100),
		Dept_Name			varchar(100),
		--Cmp_name			varchar(100),
		--cmp_Address			varchar(200),
		--cmp_logo			image,
		Training_Apr_Id		numeric(18,0),
		Training_Id			numeric(18,0),
		Training_Name		varchar(200),
		Training_Date		DATETIME,
		Training_Duration	Varchar(100),
		Training_Detail		varchar(200),
		Total_Days			int,
		Faculty				Varchar(100)
	)
	
	declare @col as numeric(18,0)
	
	if @Branch_ID = '0'
		set @Branch_ID = null
	if @Dept_ID = '0'
		set @Dept_ID = null
	if @Desig_ID = '0'
		set @Desig_ID = null
	if @Cat_ID = '0'
		set @Cat_ID = null
	if @Grd_ID = '0'
		set @Grd_ID = null
	if @Type_ID = '0'
		set @Type_ID = null	
	
	
		insert into #FinalTable(Emp_ID,Emp_Full_Name,Alpha_Emp_Code,Dept_Name,Training_Apr_Id,Training_Id,Training_Name,Training_Date,
								Training_Duration,Training_Detail,Total_Days,Faculty)
		select distinct t.Emp_ID,e.Emp_Full_Name,e.Alpha_Emp_Code,d.Dept_Name,t.Training_Apr_ID,a.Training_id,m.Training_name,
		--(CONVERT(varchar(15),training_Date,103)+'-'+CONVERT(varchar(15),Training_End_Date,103)),
		TST.From_date,Ts.duration,a.Description,ts.nodays,Faculty
		from t0130_HRMS_TRAINING_EMPLOYEE_DETAIL T WITH (NOLOCK) inner join 
		  T0150_EMP_Training_INOUT_RECORD r WITH (NOLOCK) on r.emp_id = t.Emp_ID and r.Training_Apr_ID=t.Training_Apr_ID inner join
		  T0120_HRMS_TRAINING_APPROVAL A WITH (NOLOCK) on A.Training_Apr_ID = t.Training_Apr_ID inner join
		  T0040_Hrms_Training_master M WITH (NOLOCK) on m.Training_id = a.Training_id inner join
		  T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = t.Emp_ID inner join
		  T0095_INCREMENT I WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and i.Increment_ID = (select MAX(increment_id) from T0095_INCREMENT WITH (NOLOCK) where emp_id=e.Emp_ID) left join
		  T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID inner JOIN
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
		where T.Cmp_ID = @Cmp_ID and t.Training_Apr_ID=@Training_ID and (t.Emp_tran_status=1 or t.Emp_tran_status=4)
		and (i.Branch_ID  in (ISNULL(@Branch_ID,i.Branch_ID)) or i.Branch_ID is null)  and (i.Dept_ID  in (ISNULL(@Dept_ID,i.Dept_ID)) or i.Dept_ID is null) 
		and (i.Desig_Id in (ISNULL(@Desig_ID,i.desig_id)) or i.desig_id is null)
		and (i.Cat_ID  in (ISNULL(@cat_id,i.Cat_ID)) or i.Cat_ID is null) 
		and (i.Grd_ID  in (ISNULL(@Grd_ID,i.Grd_ID)) or i.Grd_ID is null)
		and (i.Type_ID  in (ISNULL(@Type_ID,i.Type_ID))or i.Type_ID is null)
		
	
	select #FinalTable.*,c.Cmp_Name,c.Cmp_Address,c.cmp_logo from #FinalTable inner join 
	 T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id =@Cmp_ID
	
	drop table #FinalTable
END


