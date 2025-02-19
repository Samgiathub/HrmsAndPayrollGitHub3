

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[HRMS_Home_Graph_Details]
	@cmp_id as numeric(18,0)
	,@year as  int = 0
	,@month_sel  as int = 0 --added on 22062016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
if @year= 0
set @year = DATEPART(YEAR,getdate())
	
	---table to get candidate demographic
create table #GenderCount
(
	Gender   VARCHAR(6)
	,Gendercnt	numeric(18,0)
	,Totalcnt numeric(18,0)
	,perGender numeric(18,2)
)

declare @femalecnt numeric(18,0)
	,@malecnt numeric(18,0)
	,@Totalcnt numeric(18,0)
	,@perfemale numeric(18,2)
	,@permale numeric(18,2)


select @Totalcnt=count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
and datepart(yyyy,Resume_Posted_date) = @year
select @malecnt=count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
and Gender ='M' and datepart(yyyy,Resume_Posted_date) = @year
select @femalecnt=count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
and Gender ='F' and datepart(yyyy,Resume_Posted_date) = @year

set @perfemale = 0

if @Totalcnt<>0 and @femalecnt<>0
 set @perfemale = (@femalecnt/@Totalcnt)*100


set @permale = 0
if @Totalcnt<>0 and @malecnt<>0
set @permale = (@malecnt/@Totalcnt)*100

INSERT into #GenderCount
values('Female',@femalecnt,@Totalcnt,@perfemale)
INSERT into #GenderCount
values('Male',@malecnt,@Totalcnt,@permale)

select * from #GenderCount

---table to get Recruitment summary

create table #recSummary
(
	Process  varchar(15)
	,RecCnt	 numeric(18,0)
)
INSERT INTO #recSummary
select 'Applied',count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id and datepart(yyyy,Resume_Posted_date) = @year
INSERT INTO #recSummary
select 'Approved',count(1) from T0055_Resume_Master R WITH (NOLOCK) left JOIN
T0060_RESUME_FINAL F WITH (NOLOCK) on r.Resume_Id = f.Resume_ID
where R.Cmp_id=@cmp_id and datepart(yyyy,Resume_Posted_date) = @year
and R.Resume_Status = 1 and F.Resume_Status = 1 and (datepart(yyyy,Resume_Posted_date) = @year or  datepart(yyyy,F.Approval_Date) = @year)
INSERT INTO #recSummary 
select 'Shortlisted',count(1) from T0055_Resume_Master R WITH (NOLOCK) left JOIN
T0060_RESUME_FINAL F WITH (NOLOCK) on r.Resume_Id = f.Resume_ID
where R.Cmp_id=@cmp_id and datepart(yyyy,Resume_Posted_date) = @year
and R.Resume_Status = 1 and F.Resume_Status is null
INSERT INTO #recSummary
select 'Pending',count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
and Resume_Status = 0 and datepart(yyyy,Resume_Posted_date) = @year
INSERT INTO #recSummary
select 'Reject',count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
and Resume_Status = 2 and datepart(yyyy,Resume_Posted_date) = @year
INSERT INTO #recSummary
select 'Hold',count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
and Resume_Status = 3 and datepart(yyyy,Resume_Posted_date) = @year
INSERT INTO #recSummary
select 'Recruited',count(1) from T0060_RESUME_FINAL WITH (NOLOCK) where Cmp_id=@cmp_id
and Confirm_Emp_id >0  and datepart(yyyy,Joining_date) = @year

select * from #recSummary

--Monthly recruitment summary
create table #recSummary_Monthly
(
	 Month varchar(20)
	,Applied NUMERIC(18,0)
	,Approved NUMERIC(18,0)
	,Shortlisted NUMERIC(18,0)
	,Pending NUMERIC(18,0)
	,Reject NUMERIC(18,0)
	,Hold NUMERIC(18,0)
	,Recruited NUMERIC(18,0)
)


;with CTE AS
(
	SELECT YEAR(GETDATE()) AS YEARPart
),
CTE1 AS
(
	SELECT YEARPart,DATENAME(MM,CAST('1'+'/1'+'/'+CAST(YEARPart AS VARCHAR(4)) AS DATETIME)) AS MonthName,
	2 AS MonthPart
	FROM CTE
	
	UNION ALL
	
	SELECT YEARPart,DATENAME(MM,CAST(CAST(MonthPart AS VARCHAR(2))+'/1'+'/'+CAST(YEARPart AS VARCHAR(4)) AS DATETIME)) AS MonthName,
	MonthPart+1 AS MonthPart
	FROM CTE1
	WHERE MonthPart<=12
)
INSERT INTO #recSummary_Monthly (Month)
SELECT MonthName
FROM CTE1


declare @month as varchar(15)
declare @datestring as varchar(20)
declare cur CURSOR
for 
select Month from #recSummary_Monthly
open cur
fetch next from cur into @month
while @@fetch_status = 0
	BEGIN 
		set @datestring =''
		SET @datestring = @month + ' 1 ' + cast(@year as varchar)
		--SET @getmonth = MONTH(CAST(@datestring AS DATETIME))
	
		update #recSummary_Monthly
		set  Applied =(select count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id and datepart(yyyy,Resume_Posted_date) = @year and datepart(month,Resume_Posted_date)=MONTH(CAST(@datestring AS DATETIME)))
			,Approved=(select count(1) from T0055_Resume_Master R WITH (NOLOCK) left JOIN
						T0060_RESUME_FINAL F WITH (NOLOCK) on r.Resume_Id = f.Resume_ID
						where R.Cmp_id=@cmp_id and datepart(yyyy,Resume_Posted_date) = @year
						and R.Resume_Status = 1 and F.Resume_Status = 1 and (datepart(yyyy,Resume_Posted_date) = @year or  datepart(yyyy,F.Approval_Date) = @year) and ((datepart(month,Resume_Posted_date) = MONTH(CAST(@datestring AS DATETIME)) or  datepart(month,F.Approval_Date) = MONTH(CAST(@datestring AS DATETIME)))))
			,Shortlisted =(select count(1) from T0055_Resume_Master R WITH (NOLOCK) left JOIN
							T0060_RESUME_FINAL F WITH (NOLOCK) on r.Resume_Id = f.Resume_ID
							where R.Cmp_id=@cmp_id and datepart(yyyy,Resume_Posted_date) = @year and datepart(month,Resume_Posted_date) = MONTH(CAST(@datestring AS DATETIME))
							and R.Resume_Status = 1 and F.Resume_Status is null)
			,Pending =(select count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
						and Resume_Status = 0 and datepart(yyyy,Resume_Posted_date) = @year and datepart(month,Resume_Posted_date) = MONTH(CAST(@datestring AS DATETIME)))
			,Reject =(select count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
					 and Resume_Status = 2 and datepart(yyyy,Resume_Posted_date) = @year and datepart(month,Resume_Posted_date) = MONTH(CAST(@datestring AS DATETIME)))
			,Hold =(select count(1) from T0055_Resume_Master WITH (NOLOCK) where Cmp_id=@cmp_id
					and Resume_Status = 3 and datepart(yyyy,Resume_Posted_date) = @year and datepart(month,Resume_Posted_date) = MONTH(CAST(@datestring AS DATETIME)))
			,Recruited=(select count(1) from T0060_RESUME_FINAL WITH (NOLOCK) where Cmp_id=@cmp_id
					and Confirm_Emp_id >0 and datepart(yyyy,Joining_date) = @year and datepart(month,Joining_date) = MONTH(CAST(@datestring AS DATETIME)))
		Where #recSummary_Monthly.Month = @month
		fetch next from cur into @month
	END
close cur
deallocate cur

SELECT * from #recSummary_Monthly

--- get actual vacancy,recruited
CREATE TABLE #tblVacancy
(
	 P_Name varchar(15)
	,Count  NUMERIC(18,0)
)

--declare @vcnt 

Insert into #tblVacancy
select 'Vacancy',sum(No_of_vacancies)
from T0050_HRMS_Recruitment_Request RE WITH (NOLOCK) left JOIN
T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on p.Rec_Req_ID = Re.Rec_Req_ID 
where App_status = 1  and Re.cmp_id=@cmp_id 
and datepart(yyyy,P.Rec_Post_date)=@year

Insert into #tblVacancy 
select 'Joined',count(1) 
from T0060_RESUME_FINAL F WITH (NOLOCK) INNER JOIN
T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on p.Rec_Post_Id = F.Rec_post_Id
where  F.Confirm_Emp_id > 0 and F.cmp_id=@cmp_id
and datepart(yyyy,F.Joining_date)=@year

select * from #tblVacancy

---Insert No. Of Openings
CREATE TABLE #Openingtbl
(
	 JobTitle		varchar(500)
	 ,post_id		NUMERIC(18,0)
	,Vacancy		NUMERIC(18,0)
	,Applications   NUMERIC(18,0)
	,Joined			NUMERIC(18,0)
)

insert into #Openingtbl(JobTitle,post_id,Vacancy)
select p.Rec_Post_Code +'-'+ P.Job_title,P.Rec_Post_Id,No_of_vacancies
FROM T0050_HRMS_Recruitment_Request RE WITH (NOLOCK) left JOIN
T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on p.Rec_Req_ID = Re.Rec_Req_ID 
 WHERE App_status = 1  and Re.cmp_id=@cmp_id 
and datepart(yyyy,P.Rec_Post_date)=@year

declare @Rec_Post_Id as NUMERIC(18,0)
declare cur CURSOR
for 
	select post_id from #Openingtbl	
open cur
	fetch next from cur into @Rec_Post_Id
	while @@fetch_status = 0
	BEGIN
		
		update #Openingtbl
		set Joined = v.Joined
		From (select count(1)Joined
				from T0060_RESUME_FINAL F WITH (NOLOCK) INNER JOIN
					 T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on p.Rec_Post_Id = F.Rec_post_Id
				where P.Rec_Post_Id= @Rec_Post_Id and  F.Confirm_Emp_id > 0)v
		where post_id = @Rec_Post_Id
		
		update #Openingtbl
		set Applications = v.applications
		From (select count(1)applications
				from T0055_Resume_Master F WITH (NOLOCK) INNER JOIN
					 T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on p.Rec_Post_Id = F.Rec_post_Id
				where P.Rec_Post_Id= @Rec_Post_Id )v
		where post_id = @Rec_Post_Id		
		
		fetch next from cur into @Rec_Post_Id
	END
close cur
deallocate cur


select * from #Openingtbl

--***********************training******************------------------
---added on 10/02/2017 by Sneha to set according to new chnages made in training module by Muslim

CREATE TABLE #trainingAttendance
(
	Training_Name		varchar(200)
	,Training_st_Date	DATETIME	---added on 9 Feb 2017
	,Training_End_Date	DATETIME
	,total_part			numeric(18,0)
	,Training_Apr_Id	numeric(18,0)
	,total_a			numeric(18,0)
	,total_na			numeric(18,0)
	,Man_days			int			---added on 9 Feb 2017
	,duration			numeric(18,2)
	,no_of_days			int
)

INSERT INTO #trainingAttendance (Training_Name,Training_st_Date,Training_End_Date,total_part,Training_Apr_Id,total_a,total_na,duration,no_of_days,Man_days)
SELECT (isnull(TA.Training_Code,TA.Training_Apr_ID) +'-'+ TM.Training_name),TAS.From_date,TAS.To_date,isnull(total_part,0),TA.Training_Apr_ID,
		isnull(count(distinct(TI.emp_id)),0),
		CASE WHEN (isnull(TE1.total_part,0)-isnull(count(DISTINCT(TI.emp_id)),0))< 0 THEN 0 ELSE (isnull(TE1.total_part,0)-isnull(count(DISTINCT(TI.emp_id)),0)) end,
		TS.duration,isnull(TS.nodays,0),
		case when (((TS.duration*TS.nodays))*isnull(count(distinct(TI.emp_id)),0))=0 then 0 else  isnull((((TS.duration*TS.nodays))*isnull(count(distinct(TI.emp_id)),0))/duration,0) end
		--,(((TS.duration*TA.no_of_day))*isnull(count(distinct(TI.emp_id)),0))/isnull(TS.duration,0)
FROM  T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) inner JOIN
	  T0040_Hrms_Training_master TM	WITH (NOLOCK) on TM.Training_id = TA.Training_id left JOIN
	  (
			SELECT T0120_HRMS_TRAINING_Schedule.Training_App_ID,SUM(nodays)nodays,SUM(CONVERT(numeric(18,2),(TS1.duration)))duration
			FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK) inner JOIN
			(
				SELECT (DATEDIFF(DAY,From_date,To_date))+1 nodays,To_date,From_date,Training_App_ID,
				(REPLACE(CONVERT(varchar(5),(SELECT CONVERT(DATETIME, ISNULL(to_time,'')))-(SELECT CONVERT(DATETIME,ISNULL(from_time,''))),114),':','.'))duration,
				From_Time,To_Time
				FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
				GROUP by Training_App_ID,To_date,From_date,From_Time,To_Time
			)TS1 on T0120_HRMS_TRAINING_Schedule.Training_App_ID = TS1.Training_App_ID and 
			T0120_HRMS_TRAINING_Schedule.From_date = ts1.From_date and 
			T0120_HRMS_TRAINING_Schedule.To_date = ts1.To_date
		GROUP by T0120_HRMS_TRAINING_Schedule.Training_App_ID
	  )TS on TS.Training_App_ID = TA.Training_App_ID LEFT JOIN
	  (
			SELECT count(TE.Emp_ID) total_part,TE.Training_Apr_ID 
			FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK)
			WHERE (TE.Emp_tran_status=1 or TE.Emp_tran_status=4) 
			GROUP BY Training_Apr_ID
	  )TE1 on TE1.Training_Apr_ID = TA.Training_Apr_ID left JOIN
	 T0150_EMP_Training_INOUT_RECORD TI WITH (NOLOCK) on ti.Training_Apr_Id = TA.Training_Apr_ID left JOIN
	 (
		SELECT max(To_date)To_date,min(From_date)From_date,Training_App_ID
		from T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
		GROUP by Training_App_ID
	 )TAS on TAS.Training_App_ID = TA.Training_App_ID
where TA.Cmp_ID =@cmp_id and DATEPART(YYYY,From_date)= @year and DATEPART(MONTH,From_date)= @month_sel 
	 and TA.Apr_Status=1
GROUP by Training_Code,TM.Training_name,TA.Training_Apr_ID,total_part,TS.duration,TAS.From_date,TAS.To_date,TS.nodays

SELECT * FROM #trainingAttendance ORDER BY Training_st_Date
---commented on 10/02/2017 by Sneha to set according to new chnages made in training module by Muslim
--create table #trainingAttendance
--(
--	 Training_Name		varchar(200)	
--	,Training_End_Date	DATETIME
--	,total_part			numeric(18,0)
--	,Training_Apr_Id	numeric(18,0)
--	,total_a			numeric(18,0)
--	,total_na			numeric(18,0)
--)

--insert into #trainingAttendance (Training_Name,Training_Apr_Id,Training_End_Date,total_part,total_a,total_na)
--SELECT (isnull(TA.Training_Code,TA.Training_Apr_ID) +'-'+ TM.Training_name),TA.Training_Apr_ID,TA.Training_End_Date,isnull(TE1.total_part,0),
--isnull(count(distinct(TI.emp_id)),0),
--case when (isnull(TE1.total_part,0)-isnull(count(distinct(TI.emp_id)),0))< 0 then 0 else (isnull(TE1.total_part,0)-isnull(count(distinct(TI.emp_id)),0)) end
--FROM   V0120_HRMS_TRAINING_APPROVAL TA INNER JOIN -- Changed by Gadriwala Muslim 06012017
--	   T0100_HRMS_TRAINING_APPLICATION TP ON TP.Training_App_ID = TA.Training_App_ID INNER JOIN
--	   T0040_Hrms_Training_master TM ON TM.Training_id = TP.Training_id LEFT JOIN
--	   (select count(TE.Emp_ID) total_part,TE.Training_Apr_ID FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE 
--		where (TE.Emp_tran_status=1 or TE.Emp_tran_status=4) GROUP BY Training_Apr_ID)TE1 on TE1.Training_Apr_ID = TA.Training_Apr_ID left JOIN
--		T0150_EMP_Training_INOUT_RECORD TI on ti.Training_Apr_Id = TA.Training_Apr_ID
--Where  TA.Cmp_ID = @cmp_id and DATEPART(YYYY,TA.Training_Date)= @year and DATEPART(MONTH,TA.Training_Date)= @month_sel
--group by TA.Training_Apr_ID,Training_Code,TM.Training_name,Training_End_Date,total_part,Training_Date
--order by ta.Training_Date asc

--select * from #trainingAttendance 

--SELECT  (isnull(TA.Training_Code,TA.Training_Apr_ID) +'-'+ TM.Training_name)Training_name,TA.Training_End_Date,isnull(TE1.total_part,0)total_part,TA.Training_Apr_ID,isnull(TI.total_a,0)total_a,case when (isnull(TE1.total_part,0)-isnull(ti.total_a,0))< 0 then 0 else (isnull(TE1.total_part,0)-isnull(ti.total_a,0)) end total_na
--		FROM   T0120_HRMS_TRAINING_APPROVAL TA INNER JOIN
--			   T0100_HRMS_TRAINING_APPLICATION TP ON TP.Training_App_ID = TA.Training_App_ID INNER JOIN
--			   T0040_Hrms_Training_master TM ON TM.Training_id = TP.Training_id LEFT JOIN
--			   (select count(TE.Emp_ID) total_part,TE.Training_Apr_ID FROM T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE 
--				where (TE.Emp_tran_status=1 or TE.Emp_tran_status=4) GROUP BY Training_Apr_ID)TE1 on TE1.Training_Apr_ID = TA.Training_Apr_ID  LEFT JOIN
--			   (select DISTINCT count(emp_id)total_a,Training_Apr_Id from T0150_EMP_Training_INOUT_RECORD where cmp_id=@cmp_id GROUP by emp_id,Training_Apr_Id )TI on TI.Training_Apr_Id = TA.Training_Apr_ID
--			Where  TA.Cmp_ID = @cmp_id and DATEPART(YYYY,TA.Training_Date)= @year	
--		and DATEPART(MONTH,TA.Training_Date)= @month_sel	

create table #TrainingPlan
(
	trainingType  varchar(200)
	,noofTraining INT
)

INSERT INTO #TrainingPlan
SELECT 'Planned',count(1)
FROM    V0120_HRMS_TRAINING_APPROVAL --T0052_Hrms_Training_Event_Calender_Yearly -- Changed by Gadriwala Muslim 06012017
where Cmp_Id = @cmp_id and year(Training_date) = @year and month(Training_date) = @month_sel

INSERT INTO #TrainingPlan
SELECT 'Executed',count(1)
FROM  V0120_HRMS_TRAINING_APPROVAL  -- Changed by Gadriwala Muslim 06012017
where Cmp_ID = @cmp_id and datepart(yyyy,Training_Date)=@year 
	and datepart(MONTH,Training_Date)=@month_sel and Apr_Status = 1
	and exists (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
select * from #TrainingPlan


-----training type vs. no. of trainings in a month
delete from #TrainingPlan

alter table  #TrainingPlan
add Noofparticipnat int

declare @Training_Type_ID NUMERIC(18,0)
declare @Training_TypeName VARCHAR(50)

--declare cur CURSOR
--FOR
--	select Training_Type_ID,Training_TypeName from T0030_Hrms_Training_Type where Cmp_Id=@cmp_id
--open cur
--	fetch next from cur into @Training_Type_ID,@Training_TypeName
--	while @@fetch_status = 0
--		BEGIN
--			INSERT into #TrainingPlan
--			select @Training_TypeName,count(1)
--			from T0120_HRMS_TRAINING_APPROVAL 
--			where Training_Type = @Training_Type_ID and datepart(MONTH,Training_Date)=@month_sel
--					and datepart(YEAR,Training_Date)=@year  and Apr_Status =1 and 
--					exists (select 1 from T0150_EMP_Training_INOUT_RECORD where Training_Apr_Id =T0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			
--			fetch next from cur into @Training_Type_ID,@Training_TypeName
--		END
--close cur
--deallocate cur

--select * from #TrainingPlan


-----training type vs. participants
delete from #TrainingPlan
declare @trainingaprid  NUMERIC(18,0)
declare @cnt  int
declare @rescnt  int
set @rescnt =0

set @Training_TypeName = 0
set @Training_TypeName = ''

DECLARE cur CURSOR
FOR
	SELECT Training_Type_ID,Training_TypeName FROM T0030_Hrms_Training_Type WITH (NOLOCK) WHERE Cmp_Id=@cmp_id
OPEN cur
	FETCH NEXT FROM cur INTO @Training_Type_ID,@Training_TypeName
	WHILE @@fetch_status = 0
		BEGIN 
			
			INSERT INTO #TrainingPlan (trainingType,noofTraining)
			SELECT @Training_TypeName,count(1)
			FROM V0120_HRMS_TRAINING_APPROVAL  -- Changed by Gadriwala Muslim 06012017
			WHERE Training_Type = @Training_Type_ID and DATEPART(MONTH,Training_Date)=@month_sel
					AND DATEPART(YEAR,Training_Date)=@year  and Apr_Status =1 
					--and EXISTS (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			
			SET @rescnt = 0
			DECLARE cur1 CURSOR
			FOR
				SELECT Training_Apr_ID
				FROM V0120_HRMS_TRAINING_APPROVAL  -- Changed by Gadriwala Muslim 06012017
				WHERE Training_Type = @Training_Type_ID and DATEPART(MONTH,Training_Date)=@month_sel
						AND DATEPART(YEAR,Training_Date)=@year and Apr_Status =1 
						and	EXISTS (SELECT 1 FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			OPEN cur1
				FETCH NEXT FROM cur1 INTO @trainingaprid
				WHILE @@fetch_status = 0
					BEGIN
						
						SELECT @cnt = COUNT(DISTINCT emp_id)
						FROM T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) WHERE Training_Apr_Id = @trainingaprid
						FETCH NEXT FROM cur1 INTO @trainingaprid
						
						SET @rescnt = @rescnt + @cnt						
					END
			CLOSE cur1
			DEALLOCATE cur1	
			
			UPDATE #TrainingPlan
			SET Noofparticipnat = @rescnt WHERE trainingType = @Training_TypeName
										
			FETCH NEXT FROM cur INTO @Training_Type_ID,@Training_TypeName
		END
CLOSE cur
DEALLOCATE cur

select * from #TrainingPlan

-----training type vs. training details
CREATE TABLE #trainingdetails
(
	 TrainingType		VARCHAR(200)
	,TrainingName		VARCHAR(200)
	,TrainingCode		VARCHAR(50)
	,TrainingDate		DATETIME
	,TrainingEndDate	DATETIME
	,TrainingFromTime	VARCHAR(50)	
	,TrainingToTime		VARCHAR(50)	
)

set @Training_TypeName = 0
set @Training_TypeName = ''

DECLARE cur CURSOR
FOR
	SELECT Training_Type_ID,Training_TypeName FROM T0030_Hrms_Training_Type WITH (NOLOCK) WHERE Cmp_Id=@cmp_id
OPEN cur
	FETCH NEXT FROM cur INTO @Training_Type_ID,@Training_TypeName
	WHILE @@fetch_status = 0
		BEGIN
			INSERT INTO #trainingdetails
			SELECT @Training_TypeName,TM.Training_name,Training_Code, From_date,To_date,from_time,to_time
			FROM V0120_HRMS_TRAINING_APPROVAL 
			inner JOIN(SELECT min(From_date)From_date,max(To_date)To_date,Training_App_ID,min(from_time)from_time,max(to_time)to_time
				FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
				GROUP by Training_App_ID
			)TS on TS.Training_App_ID = V0120_HRMS_TRAINING_APPROVAL.Training_App_ID
			inner JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) on tm.Training_id =V0120_HRMS_TRAINING_APPROVAL.Training_id 
			WHERE TM.Training_Type = @Training_Type_ID and datepart(MONTH,Training_Date)=@month_sel
						and datepart(YEAR,Training_Date)=@year and Apr_Status =1 and
						exists (select 1 from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK) where Training_Apr_Id =V0120_HRMS_TRAINING_APPROVAL.training_apr_id)
			FETCH NEXT FROM cur INTO @Training_Type_ID,@Training_TypeName
		END
CLOSE cur
DEALLOCATE cur

select TrainingType,TrainingName,TrainingCode,convert(varchar(15),TrainingDate,105)TrainingDate,convert(varchar(15),TrainingEndDate,105) TrainingEndDate,TrainingFromTime,TrainingToTime
from #trainingdetails order by TrainingDate desc


drop TABLE  #GenderCount
drop TABLE  #recSummary
drop TABLE  #recSummary_Monthly
drop TABLE  #tblVacancy
drop TABLE  #Openingtbl
drop TABLE  #trainingAttendance
drop TABLE  #TrainingPlan
drop TABLE  #trainingdetails
END
