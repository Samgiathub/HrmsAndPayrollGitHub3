


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0053_PerformanceAssessment_Allocate]
	 @cmpid as numeric(18,0)
	,@deptid as numeric(18,0)
	,@year as varchar(50)
	,@sup as int =null --varchar(50)=null
	,@grd as numeric(18,0)=null
	,@sadate as datetime = null -- added on 21 sep 2016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	SELECT @sadate = MAX(SA_Startdate) 
	FROM   T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
	WHERE  Cmp_ID = @cmpid and DATEPART(YEAR, SA_Startdate)=@year

	CREATE TABLE #rangeCount
	(
		 rangeid  numeric(18,0)
		,Achievement varchar(100)
		,percentage_allocation numeric(18,2)
		,Actual_Percentage numeric(18,2)
		,empcount numeric(18,0)
		,empid  numeric(18,0)
	)
	
INSERT INTO #rangeCount(rangeid,Achievement,percentage_allocation)
SELECT A.AchievementId,A.Achievement_Level,RA.Percent_Allocate
FROM 
T0040_Achievement_Master A WITH (NOLOCK) 
INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = A.Cmp_ID INNER JOIN
(
	SELECT isnull(max(Effective_Date),From_Date)Effective_Date--,AchievementId
	From  T0040_Achievement_Master WITH (NOLOCK)
	INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = T0040_Achievement_Master.Cmp_ID
	WHERE T0040_Achievement_Master.Cmp_ID = @cmpid and isnull(Effective_Date,From_Date )<= @sadate and Achievement_Type =2 
	GROUP by From_Date--AchievementId
)A1   on A1.Effective_Date =  ISNULL(A.Effective_Date,From_Date)---A.AchievementId = A1.AchievementId
LEFT JOIN
(
	SELECT	Range_ID,Percent_Allocate
	FROM	T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
			INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = T0050_HRMS_RangeDept_Allocation.Cmp_ID	INNER JOIN
			(
				SELECT isnull(max(Effective_Date),From_Date)Effective_Date--,RangeDept_ID
				FROM T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
				INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = T0050_HRMS_RangeDept_Allocation.Cmp_ID
				WHERE T0050_HRMS_RangeDept_Allocation.Cmp_ID = @cmpid and  Dept_ID = @deptid
					  AND isnull(Effective_Date,From_Date )<= @sadate
				GROUP by From_Date --RangeDept_ID
			)RA1 ON RA1.Effective_Date = ISNULL(T0050_HRMS_RangeDept_Allocation.Effective_Date,From_Date)-- RA1.RangeDept_ID = T0050_HRMS_RangeDept_Allocation.RangeDept_ID
	WHERE T0050_HRMS_RangeDept_Allocation.Cmp_ID = @cmpid and  Dept_ID = @deptid
)RA on RA.Range_ID = A.AchievementId
WHERE A.Cmp_ID = @cmpid  and A.Achievement_Type =2 

CREATE TABLE #Emp_Cons 
 (      
   Emp_ID numeric ,     
   Branch_ID numeric,
   Increment_ID numeric    
 )  
EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @cmpid,@sadate,@sadate,0,0,0,0,@deptid,0,0,'',0,0,'','','','',0,0,0,'0',0,0 
	
CREATE TABLE #emp_details
(
	 rangeid  numeric(18,0)
	,empname  varchar(100)
	,empid    numeric(18,0)	
)
DECLARE @dept_cnt as int=0

IF isnull(@sup,0)<>0
	BEGIN	
			INSERT INTO #emp_details
			SELECT IA.Achivement_Id,(EM.Alpha_Emp_Code+'-'+ EM.Emp_Full_Name),E.Emp_Id 
			FROM   #Emp_Cons E INNER JOIN
				   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN
				   T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_Id
			WHERE  DATEPART(YEAR, IA.SA_Startdate)=@year and IA.Cmp_ID=@cmpid 
					and IA.GH_Id = isnull(@sup,0)
				  --and  EM.Old_Ref_No=isnull(@sup,0)
				  
			SELECT @dept_cnt =COUNT(*)
			FROM   #Emp_Cons E INNER JOIN
				   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN
				   T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_Id
			WHERE  DATEPART(YEAR, IA.SA_Startdate)=@year and IA.Cmp_ID=@cmpid	
	END	
ELSE
	BEGIN
		    INSERT INTO #emp_details
			SELECT IA.Achivement_Id,(EM.Alpha_Emp_Code+'-'+ EM.Emp_Full_Name),E.Emp_Id 
			FROM   #Emp_Cons E INNER JOIN
				   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN
				   T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_Id
			WHERE  DATEPART(YEAR, IA.SA_Startdate)=@year and IA.Cmp_ID=@cmpid
			
			SELECT @dept_cnt =COUNT(E.empid)
			FROM #emp_details E 	
	END
	

	
	UPDATE #rangeCount
			SET empcount = isnull(RC.ecount,0)
				,Actual_Percentage = case when isnull(rc.ecount,0) <>0 then isnull((RC.ecount *100 )/@dept_cnt,0) else 0 end 
			FROM	
			(
				SELECT SUM(T.ecount)ecount,Range_AchievementId
				FROM 
				(				
					SELECT  ISNULL(COUNT(E.empid),0) ecount,R.Range_ID,Range_AchievementId --ISNULL(COUNT(E.empid),0)
					FROM   #emp_details E INNER JOIN
						  (
								SELECT rm.Range_ID,Range_AchievementId
								FROM T0040_HRMS_RangeMaster rm WITH (NOLOCK) INNER JOIN
									#rangeCount rn on rn.rangeid = rm.Range_AchievementId
								WHERE Cmp_ID = @cmpid and Range_Type = 2
						  )R on R.Range_ID = E.rangeid
					GROUP by R.Range_ID,Range_AchievementId
				)T
				GROUP by Range_AchievementId
			)RC 
			WHERE #rangeCount.rangeid = RC.Range_AchievementId	
			
	--SELECT * FROM #rangeCount
	
	DECLARE @tab AS VARCHAR(8000)
	SET @tab = '	
			Select 
			Case When row_number() OVER ( PARTITION BY rangeid order by rangeid) = 1
			Then  cast(rangeid AS varchar(100))
			Else '''' End ''RangeId'',	
			Case When row_number() OVER ( PARTITION BY rangeid order by rangeid) = 1
			Then  cast(Achievement AS varchar(100))
			Else '''' End ''Achievement'',			
			Case When row_number() OVER ( PARTITION BY rangeid order by rangeid) = 1
			Then  cast( isnull(percentage_allocation,0) AS varchar(12))
			Else '''' End ''PercentageAllocated'',	
			Case When row_number() OVER ( PARTITION BY rangeid order by rangeid) = 1
			Then  cast( isnull(Actual_Percentage,0) AS varchar(12))
			Else '''' End ''ActualAllocation'',					        
			Case When row_number() OVER ( PARTITION BY rangeid order by rangeid) = 1
			Then  cast( isnull(empcount,0) AS varchar(100))
			Else '''' End ''NoofEmployees'',		
			 isnull(empid,''0'') as ''Employee''
	from #rangeCount'

	EXEC (@tab)

	DROP TABLE #rangeCount
	DROP TABLE #Emp_Cons
	DROP TABLE #emp_details
END
-----------------------------commented on 21 Feb 2017 to remove loop and issues due to multiple initiation----------------------
--if @grd=0
--	set @grd=null

--if @sadate is NULL -- added on 21 sep 2016
--	BEGIN
--		select @sadate = from_date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid
--	END

--declare @col1 as  numeric(18,0)

--CREATE TABLE #rangeCount
--(
--	 rangeid  numeric(18,0)
--	,Achievement varchar(100)
--	,percentage_allocation numeric(18,2)
--	,Actual_Percentage numeric(18,2)
--	,empcount numeric(18,0)
--	,empid  numeric(18,0)
--)

--CREATE TABLE #emptbl
--(
--	 rangeid numeric(18,0)
--	,empname varchar(100)
--	,empid numeric(18,0)
--)
--if @sup <> ''
--	begin
		
--		insert into #emptbl
--		(
--			rangeid,
--			empname
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname
--			from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id 
--			 inner JOIN T0095_INCREMENT I ON I.Emp_ID = D.Emp_ID and
--			I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--			and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(e.SA_Startdate as varchar(12))))
--			where Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID=@deptid   and e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year and d.Old_Ref_No=isnull(@sup,Old_Ref_No)
--		)
--	End
--Else
--	begin
--		insert into #emptbl
--		(
--			rangeid,
--			empname
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname
--			from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id 
--			 inner JOIN T0095_INCREMENT I ON I.Emp_ID = E.Emp_ID and
--			I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--			and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(e.SA_Startdate as varchar(12))))
--			where Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID=@deptid  and e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year and d.Old_Ref_No=isnull(@sup,Old_Ref_No)
--		)
--	End

--declare @col as  numeric(18,0)
--declare @peralloc as numeric(18,2)
--declare @empcount as numeric(18,0)
--declare @range_name as varchar(100)
--declare @empname as varchar(100)
--declare @deptcnt as numeric(18,0)
--declare @actualper as numeric(18,2)
--declare @achievement as  varchar(50)
--declare @allid as numeric(18,2)
--declare @eid as numeric(18,2)

--declare cur  cursor
--for 
--	select achievementid from T0040_Achievement_Master where cmp_id=@cmpid and achievement_type =2 and  
--		  isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--		  (select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016 
--	open cur
--		Fetch Next From cur into @col
--		WHILE @@FETCH_STATUS = 0
--			begin 
--				declare cur1  cursor
--				for
--					select RangeDept_ID from T0050_HRMS_RangeDept_Allocation where range_id=@col and Cmp_ID= @cmpid and Dept_ID = @deptid AND
--					isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0050_HRMS_RangeDept_Allocation where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
--					open cur1
--						Fetch Next From cur1 into @col1 
--						WHILE @@FETCH_STATUS = 0
--							begin
--								select @achievement = Achievement_Level from T0040_Achievement_Master where cmp_id=@cmpid and achievement_type =2 and AchievementId=@col
--								select @peralloc = Percent_Allocate from T0050_HRMS_RangeDept_Allocation where Cmp_ID=@cmpid and Dept_ID= @deptid and RangeDept_ID=@col1
								
--								if @sup <> ''
--									begin 
--										--select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and  Achivement_Id=@col1 and DATEPART(YYYY,SA_Startdate)=@year and d.Emp_Superior=isnull(@sup,Emp_Superior)
--										SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--										FROM        dbo.T0040_Achievement_Master left JOIN
--															  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--															  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--															  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--															  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id  inner JOIN T0095_INCREMENT I ON I.Emp_ID = D.Emp_ID and
--															  I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--															  and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))
--										Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and  d.Old_Ref_No=isnull(@sup,Old_Ref_No) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--													isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
										
--										SELECT   @eid=(T0050_HRMS_InitiateAppraisal.emp_id)  
--										FROM        dbo.T0040_Achievement_Master left JOIN
--															  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--															  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--															  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--															  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN T0095_INCREMENT I ON I.Emp_ID = D.Emp_ID and
--															  I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--															  and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))
--										Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Old_Ref_No=isnull(@sup,Old_Ref_No) and d.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--													isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
--										--select @deptcnt = COUNT(emp_id) from T0080_EMP_MASTER where Dept_ID=@deptid and Cmp_ID=@cmpid and Emp_Left<>'Y' and  Old_Ref_No = @sup
										
--										select @deptcnt = COUNT(e.emp_id) 
--										from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										i.Emp_Id=e.Emp_ID inner JOIN T0095_INCREMENT Ic ON I.Emp_ID = e.Emp_ID and
--										  Ic.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = Ic.Emp_ID
--										  and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(i.SA_Startdate as varchar(12))))
--										where ic.Dept_ID=@deptid and e.Cmp_ID=@cmpid and Emp_Left<>'Y' and Old_Ref_No = @sup   
--										and DATEPART(YYYY,SA_Startdate)=@year 
--									End									
--								Else
--									begin
--										--select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id left join T0040_HRMS_RangeMaster as r on r.Range_ID=e.Achivement_Id  where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid  and  Achivement_Id=@col1 and DATEPART(YYYY,SA_Startdate)=@year and r.Range_ID = @col1
--										SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--										FROM        dbo.T0040_Achievement_Master left JOIN
--															  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--															  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--															  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--															  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id   INNER JOIN T0095_INCREMENT I ON I.Emp_ID = D.Emp_ID and
--															  I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--															  and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))
--										Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--													isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
										
--										SELECT   @eid=(T0050_HRMS_InitiateAppraisal.emp_id) 
--										FROM        dbo.T0040_Achievement_Master left JOIN
--															  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--															  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--															  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--															  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id  INNER JOIN T0095_INCREMENT I ON I.Emp_ID = D.Emp_ID and
--															  I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--															  and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))
--										Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--													isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
--										--select @deptcnt = COUNT(emp_id) from T0080_EMP_MASTER where Dept_ID=@deptid and Cmp_ID=@cmpid and Emp_Left<>'Y' 
										
--										select @deptcnt = COUNT(e.emp_id) 
--										from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										i.Emp_Id=e.Emp_ID inner JOIN T0095_INCREMENT Ic ON I.Emp_ID = e.Emp_ID and
--										Ic.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = Ic.Emp_ID
--										and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(i.SA_Startdate as varchar(12))))
--										where e.Dept_ID=@deptid and e.Cmp_ID=@cmpid and Emp_Left<>'Y'  
--										and DATEPART(YYYY,SA_Startdate)=@year 
--									End									
--								set @actualper = (@empcount * 100)/@deptcnt
								
--								insert into #rangeCount(rangeid,Achievement,percentage_allocation,Actual_Percentage,empcount,empid)values(@col,@achievement,@peralloc,@actualper,@empcount,@eid)
--								Fetch Next From cur1 into @col1
--							End
--						close cur1
--						deallocate cur1
--				Fetch Next From cur into @col
--			End		
--Close cur	
--Deallocate cur


--CREATE TABLE #finaltbl
--(
--	 fnlrangeid  numeric(18,0)
--	,fnlAchievement varchar(100)
--	,fnlpercentage_allocation numeric(18,2)
--	,fnlactualper numeric(18,2)
--	,fnlempcount numeric(18,0)
--	,fnlempname varchar(100)
--)
--insert #finaltbl
--(
--	fnlrangeid
--	,fnlAchievement
--	,fnlpercentage_allocation
--	,fnlactualper
--	,fnlempcount
--	,fnlempname
--)
--(
--	select 
--	 t1.rangeid
--	,t1.Achievement
--	,t1.percentage_allocation
--	,t1.Actual_Percentage
--	,t1.empcount
--	,t2.empname
--	from #rangeCount as t1 left join #emptbl as t2
--	on t2.rangeid = t1.rangeid
--)

--declare @tab as varchar(8000)
--set @tab = '	
--		Select 
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast(fnlrangeid AS varchar(100))
--		Else '''' End ''RangeId'',	
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast(fnlAchievement AS varchar(100))
--		Else '''' End ''Achievement'',			
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast( fnlpercentage_allocation AS varchar(12))
--		Else '''' End ''PercentageAllocated'',	
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast( fnlactualper AS varchar(12))
--		Else '''' End ''ActualAllocation'',					        
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast( fnlempcount AS varchar(100))
--		Else '''' End ''NoofEmployees'',		
--		 isnull(fnlempname,''-'') as ''Employee''
--from #finaltbl'


--exec (@tab)

--drop table #rangeCount
--drop table #emptbl
--drop table #finaltbl



----first table for getting employee count in a range
--CREATE TABLE #rangeCount
--(
--	 rangeid  numeric(18,0)
--	,Achievement varchar(100)
--	,percentage_allocation numeric(18,2)
--	,Actual_Percentage numeric(18,2)
--	,empcount numeric(18,0)
--)
----first table for getting employees in a range
--CREATE TABLE #emptbl
--(
--	 rangeid numeric(18,0)
--	,empname varchar(100)
--)
--if @sup <> ''
--	begin
		
--		insert into #emptbl
--		(
--			rangeid,
--			empname
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname
--			from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and d.Grd_ID=@grd  and e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year and d.Old_Ref_No=isnull(@sup,Old_Ref_No)
--		)
--	End
--Else
--	begin
--		insert into #emptbl
--		(
--			rangeid,
--			empname
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname
--			from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid  and d.Grd_ID=@grd and e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year and d.Old_Ref_No=isnull(@sup,Old_Ref_No)
--		)
--	End

--declare @col as  numeric(18,0)
--declare @peralloc as numeric(18,2)
--declare @empcount as numeric(18,0)
--declare @range_name as varchar(100)
--declare @empname as varchar(100)
--declare @deptcnt as numeric(18,0)
--declare @actualper as numeric(18,2)

--declare cur  cursor
--for 	
--	select range_id from T0040_HRMS_RangeMaster where cmp_id=@cmpid and range_type=2 and Range_Dept like '%' + cast(@deptid as varchar(50)) + '%' and Range_grade like '%' + cast(isnull(@grd,Range_grade) as varchar(50)) + '%'
--	open cur
--		Fetch Next From cur into @col
--		WHILE @@FETCH_STATUS = 0
--			begin
--				--select @peralloc=a.Percent_allocate,@range_name=r.Range_Level from T0050_HRMS_RangeDept_Allocation as a left join T0040_HRMS_RangeMaster as r on r.Range_ID = a.Range_ID where a.cmp_id=@cmpid and dept_id=@deptid and  a.Range_ID=@col
				
--				select @peralloc=Range_Percent_Allocate,@range_name=Range_Level from T0040_HRMS_RangeMaster where cmp_id=@cmpid and range_type=2  and  Range_ID=@col and Range_Dept like '%' + cast(@deptid as varchar(50)) + '%' and Range_grade like '%' + cast(@grd as varchar(50)) + '%'
--				if @sup <> ''
--					begin
--						select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and d.Grd_ID=@grd and  Achivement_Id=@col and DATEPART(YYYY,SA_Startdate)=@year and d.Old_Ref_No=isnull(@sup,Old_Ref_No)
--					End
--				Else
--					begin
--						select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and d.Grd_ID=@grd and  Achivement_Id=@col and DATEPART(YYYY,SA_Startdate)=@year and d.Old_Ref_No=isnull(@sup,Old_Ref_No)
--					End	
--				select @deptcnt = COUNT(emp_id) from T0080_EMP_MASTER where Dept_ID=@deptid and Cmp_ID=@cmpid and Emp_Left<>'Y' and Old_Ref_No=isnull(@sup,Old_Ref_No) 
--				set @actualper = (@empcount * 100)/@deptcnt
				
--				--select @empname= (d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=41 and  Achivement_Id=@col	
--				insert into #rangeCount(rangeid,Achievement,percentage_allocation,Actual_Percentage,empcount) values(@col,@range_name,@peralloc,@actualper,@empcount)
--				Fetch Next From cur into @col
--			End		
--	Close cur	
--Deallocate cur

--CREATE TABLE #finaltbl
--(
--	 fnlrangeid  numeric(18,0)
--	,fnlAchievement varchar(100)
--	,fnlpercentage_allocation numeric(18,2)
--	,fnlactualper numeric(18,2)
--	,fnlempcount numeric(18,0)
--	,fnlempname varchar(100)
--)
--insert #finaltbl
--(
--	fnlrangeid
--	,fnlAchievement
--	,fnlpercentage_allocation
--	,fnlactualper
--	,fnlempcount
--	,fnlempname
--)
--(
--	select 
--	 t1.rangeid
--	,t1.Achievement
--	,t1.percentage_allocation
--	,t1.Actual_Percentage
--	,t1.empcount
--	,t2.empname
--	from #rangeCount as t1 left join #emptbl as t2
--	on t2.rangeid = t1.rangeid
--)

--declare @tab as varchar(8000)
--set @tab = '	
--		Select 
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast(fnlrangeid AS varchar(100))
--		Else '''' End ''RangeId'',	
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast(fnlAchievement AS varchar(100))
--		Else '''' End ''Achievement'',			
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast( fnlpercentage_allocation AS varchar(12))
--		Else '''' End ''PercentageAllocated'',	
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast( fnlactualper AS varchar(12))
--		Else '''' End ''ActualAllocation'',					        
--		Case When row_number() OVER ( PARTITION BY fnlrangeid order by fnlrangeid) = 1
--		Then  cast( fnlempcount AS varchar(100))
--		Else '''' End ''NoofEmployees'',		
--		 isnull(fnlempname,''-'') as ''Employee''
--from #finaltbl'


--exec (@tab)

--drop table #rangeCount
--drop table #emptbl
--drop table #finaltbl
--END
------------------

