


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0053_PerformanceAssessment_Summary]
	 @cmpid as numeric(18,0)
	,@deptid as numeric(18,0)
	,@year as varchar(50)
	,@sup as numeric(18,0)=null
	,@grd as numeric(18,0)=null
	,@type as int = 0 --added on 17 feb 2016 --0 RM/GH 1 = HOD
	,@sadate as datetime = null -- added on 21 sep 2016
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

SELECT @sadate = MAX(SA_Startdate) 
FROM   T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
WHERE  Cmp_ID = @cmpid and DATEPART(YEAR, SA_Startdate)=@year

if @sup is null
	set @sup =0

CREATE table #rangeCount
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
	SELECT ISNULL(max(Effective_Date),From_Date)Effective_Date--,AchievementId
	From  T0040_Achievement_Master WITH (NOLOCK)
	INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = T0040_Achievement_Master.Cmp_ID
	WHERE T0010_COMPANY_MASTER.Cmp_Id = @cmpid and isnull(Effective_Date,From_Date )<= @sadate and Achievement_Type =2 
	GROUP by From_Date
)A1 on A1.Effective_Date = ISNULL(A.Effective_Date,From_Date)--A.AchievementId = A1.AchievementId
LEFT JOIN
(
	SELECT	Range_ID,Percent_Allocate
	FROM	T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
			INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = T0050_HRMS_RangeDept_Allocation.Cmp_ID INNER JOIN
			(
				SELECT ISNULL(MAX(Effective_Date),From_Date)Effective_Date--,RangeDept_ID
				FROM T0050_HRMS_RangeDept_Allocation WITH (NOLOCK)
				INNER JOIN T0010_COMPANY_MASTER WITH (NOLOCK) ON T0010_COMPANY_MASTER.Cmp_Id = T0050_HRMS_RangeDept_Allocation.Cmp_ID
				WHERE T0050_HRMS_RangeDept_Allocation.Cmp_ID = @cmpid and  Dept_ID = @deptid
					  and isnull(Effective_Date,From_Date )<= @sadate
				GROUP by From_Date --RangeDept_ID
			)RA1 on RA1.Effective_Date = ISNULL(T0050_HRMS_RangeDept_Allocation.Effective_Date,From_Date) --RA1.RangeDept_ID = T0050_HRMS_RangeDept_Allocation.RangeDept_ID
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
		IF @type = 0
			BEGIN
				INSERT INTO #emp_details
				SELECT IA.Achivement_Id,(EM.Alpha_Emp_Code+'-'+ EM.Emp_Full_Name),E.Emp_Id 
				FROM   #Emp_Cons E INNER JOIN
					   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN
					   T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_Id inner JOIN
						(
							SELECT ER1.R_Emp_ID ,er1.emp_id 
							FROM T0090_EMP_REPORTING_DETAIL ER1 WITH (NOLOCK) INNER JOIN
							(
								SELECT MAX(Effect_Date) AS Effect_Date , EMP_ID 
								FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE CMP_ID = @cmpid GROUP BY EMP_ID
							)ER2 on ER2.Emp_ID = ER1.Emp_ID
							WHERE ER1.Cmp_ID=@cmpid
						)ER on ER.Emp_ID = E.Emp_Id	
				WHERE  DATEPART(YEAR, IA.SA_Startdate)=@year and IA.Cmp_ID=@cmpid and ER.R_Emp_ID = @sup
								
			end
		ELSE IF @type =1
			BEGIN
				INSERT INTO #emp_details
				SELECT IA.Achivement_Id,(EM.Alpha_Emp_Code+'-'+ EM.Emp_Full_Name),E.Emp_Id 
				FROM   #Emp_Cons E INNER JOIN
					   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN
					   T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_Id LEFT JOIN
						(
							SELECT T0095_Department_Manager.Dept_Id,Emp_id 
							FROM T0095_Department_Manager WITH (NOLOCK) INNER JOIN
							(
								SELECT MAX(Effective_Date) AS Effective_Date , Dept_Id 
								FROM T0095_Department_Manager WITH (NOLOCK) 
								WHERE Cmp_id=@cmpid GROUP BY Dept_Id
							)DM1 on DM1.Dept_Id = T0095_Department_Manager.Dept_Id
							where Cmp_id=@cmpid 
						)DM on DM.Dept_Id = @deptid
				WHERE  DATEPART(YEAR, IA.SA_Startdate)=@year and IA.Cmp_ID=@cmpid and @sup =  (case when isnull(IA.hod_id,0) <> 0  then IA.hod_id else dm.Emp_id end)
					and IA.SendToHOD=1
			END	
			
			SELECT @dept_cnt =COUNT(*)
			FROM   #Emp_Cons E INNER JOIN
				   T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = E.Emp_ID INNER JOIN
				   T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_Id
			WHERE  DATEPART(YEAR, IA.SA_Startdate)=@year and IA.Cmp_ID=@cmpid	
	end
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
				--SELECT isnull(COUNT(E.empid),0)ecount,R.rangeid
				--FROM #emp_details E inner	join
				--	 #rangeCount  R ON r.rangeid = E.rangeid
				--GROUP by R.rangeid
				SELECT SUM(T.ecount)ecount,Range_AchievementId
				FROM 
				(				
					SELECT  ISNULL(COUNT(E.empid),0) ecount,R.Range_ID,Range_AchievementId --ISNULL(COUNT(E.empid),0)
					FROM   #emp_details E inner JOIN
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

--SELECT rangeid as RangeId,Achievement,percentage_allocation as PercentageAllocated,isnull(Actual_Percentage,0) as ActualAllocation,isnull(empcount,0) as NoofEmployees,empid as Employee
--FROM #rangeCount
DECLARE @tab as varchar(8000)
set @tab = '	
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


exec (@tab)

--SELECT * FROM #rangeCount
--SELECT * FROM #emp_details

DROP TABLE #rangeCount
DROP TABLE #Emp_Cons
DROP TABLE #emp_details
END

------------commented on 20/02/2017 to remove loops and bring the result of previous years too--------------------------
--declare @col as  numeric(18,0)
--declare @col1 as  numeric(18,0)

--IF @sadate is NULL -- added on 21 sep 2016
--	BEGIN
--		select @sadate = from_date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid
--	END

--create table #rangeCount
--(
--	 rangeid  numeric(18,0)
--	,Achievement varchar(100)
--	,percentage_allocation numeric(18,2)
--	,Actual_Percentage numeric(18,2)
--	,empcount numeric(18,0)
--	,empid  numeric(18,0)
--)

--create table #emptbl
--(
--	 rangeid numeric(18,0)
--	,empname varchar(100)
--	,empid numeric(18,0)
--)
--if @sup <> 0 and @type=0
--	begin		
--		insert into #emptbl
--		(
--			rangeid,
--			empname,
--			empid
--		)
--		(
		
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname,e.Emp_ID
--			from T0050_HRMS_InitiateAppraisal as e left join 
--				V0080_Employee_Details as d on 
--				d.Emp_ID=e.Emp_Id 	INNER JOIN        
--				(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
--						FROM T0095_INCREMENT I INNER JOIN
--								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--								 FROM T0095_INCREMENT Inner JOIN
--										(
--												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--												FROM T0095_INCREMENT WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--								 WHERE CMP_ID = @cmpid
--								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--						where I.Cmp_ID= @cmpid 
--				)i on i.Emp_ID = e.Emp_ID	inner JOIN
--				(
--					SELECT ER1.R_Emp_ID ,er1.emp_id 
--					FROM T0090_EMP_REPORTING_DETAIL ER1 INNER JOIN
--					(
--						SELECT MAX(Effect_Date) AS Effect_Date , EMP_ID 
--						FROM T0090_EMP_REPORTING_DETAIL WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--					)ER2 on ER2.Emp_ID = ER1.Emp_ID
--					WHERE ER1.Cmp_ID=@cmpid
--				)ER on er.Emp_ID = e.Emp_Id		
--			where Overall_Score= ISNULL(Overall_Score,Overall_Score) and			
--				i.Dept_ID=@deptid  and 
--				e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year 
--				and er.R_Emp_ID = @sup
--			--select Achivement_Id, 
--			--(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname,e.Emp_ID
--			--from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on 
--			--d.Emp_ID=e.Emp_Id 	 inner JOIN T0095_INCREMENT I ON I.Emp_ID = E.Emp_ID and
--			--I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--			--and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(e.SA_Startdate as varchar(12))))		
--			--where Overall_Score= ISNULL(Overall_Score,Overall_Score) and			
--			--i.Dept_ID=@deptid  and 
--			--e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year 
--			--and d.Emp_Superior=isnull(0,Emp_Superior)
--		)
		
--	End
--if  @type=1
--	begin
--		insert into #emptbl
--		(
--			rangeid,
--			empname,
--			empid
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname,e.Emp_ID
--			from T0050_HRMS_InitiateAppraisal as e left join 
--				V0080_Employee_Details as d on 
--				d.Emp_ID=e.Emp_Id 	INNER JOIN        
--				(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
--						FROM T0095_INCREMENT I INNER JOIN
--								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--								 FROM T0095_INCREMENT Inner JOIN
--										(
--												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--												FROM T0095_INCREMENT WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--								 WHERE CMP_ID = @cmpid
--								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--						where I.Cmp_ID= @cmpid 
--				)i on i.Emp_ID = e.Emp_ID LEFT JOIN
--				(
--					select T0095_Department_Manager.Dept_Id,Emp_id 
--					from T0095_Department_Manager INNER JOIN
--					(
--						SELECT MAX(Effective_Date) AS Effective_Date , Dept_Id 
--						from T0095_Department_Manager
--						where Cmp_id=@cmpid GROUP by Dept_Id
--					)DM1 on DM1.Dept_Id = T0095_Department_Manager.Dept_Id
--					where Cmp_id=@cmpid 
--				)DM on DM.Dept_Id = i.Dept_ID
--			where Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID=@deptid   and DATEPART(YYYY,SA_Startdate)=@year 
--			and @sup =  (case when isnull(e.hod_id,0) <> 0  then e.hod_id else dm.Emp_id end)
--			and e.SendToHOD=1
--			--select Achivement_Id, 
--			--(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname,e.Emp_ID
--			--from T0050_HRMS_InitiateAppraisal as e inner join 
--			--T0080_EMP_MASTER as d on d.Emp_ID=e.Emp_Id inner join
--			--T0095_INCREMENT as i on i.Emp_ID = d.Emp_ID and i.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=d.emp_id)
--			--left join T0095_Department_Manager DM on dm.Dept_Id = i.Dept_ID and dm.Effective_Date=(select max(Effective_Date) from T0095_Department_Manager where dept_id=@deptid)
--			--where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid   and DATEPART(YYYY,SA_Startdate)=@year 
--			--and @sup =  (case when isnull(e.hod_id,0) <> 0  then e.hod_id else dm.Emp_id end)
--			--and e.SendToHOD=1
--		)		
--	END
--Else
--	begin 
--		insert into #emptbl
--		(
--			rangeid,
--			empname,
--			empid
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname,e.Emp_ID
--			from T0050_HRMS_InitiateAppraisal as e LEFT join 
--				V0080_Employee_Details as d on 
--				d.Emp_ID=e.Emp_Id 	INNER JOIN        
--				(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
--						FROM T0095_INCREMENT I INNER JOIN
--								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--								 FROM T0095_INCREMENT INNER JOIN
--										(
--												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--												FROM T0095_INCREMENT WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--								 WHERE CMP_ID = @cmpid
--								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--						where I.Cmp_ID= @cmpid 
--				)i on i.Emp_ID = e.Emp_ID
--			where Overall_Score= ISNULL(Overall_Score,Overall_Score) AND			
--				i.Dept_ID=@deptid  AND 
--				e.Cmp_ID=@cmpid AND DATEPART(YYYY,SA_Startdate)=@year 
--			--select Achivement_Id, 
--			--(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname,e.Emp_ID
--			--from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on 
--			--d.Emp_ID=e.Emp_Id 	 inner JOIN T0095_INCREMENT I ON I.Emp_ID = E.Emp_ID and
--			--I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--			--and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(e.SA_Startdate as varchar(12))))		
--			--where Overall_Score= ISNULL(Overall_Score,Overall_Score) and			
--			--i.Dept_ID=@deptid  and 
--			--e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year 
			
--		)
--	End


--declare @achievement as  varchar(50)
--declare @percentalloc as numeric(18,2)
--declare @empcount as numeric(18,0)
--declare @deptcnt as numeric(18,0)
--declare @actualper as numeric(18,2)
--declare @allid as numeric(18,2)
--declare @eid as numeric(18,2)

--declare cur  cursor
--for 
--	select T0040_Achievement_Master.achievementid
--	from T0040_Achievement_Master inner JOIN
--	(
--		select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid))Effective_Date,AchievementId
--		from T0040_Achievement_Master
--		where Cmp_ID= @cmpid and achievement_type =2  and 
--		Effective_Date<= @sadate
--		GROUP by AchievementId
--	) AM on Am.AchievementId = T0040_Achievement_Master.AchievementId
--	where cmp_id=@cmpid and achievement_type =2 

	
--	open cur
--		Fetch Next From cur into @col
--		WHILE @@FETCH_STATUS = 0
--			begin 
--				declare cur1  cursor
--				for
--					select T0050_HRMS_RangeDept_Allocation.RangeDept_ID 
--					from T0050_HRMS_RangeDept_Allocation inner JOIN
--					(
--						select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid))Effective_Date,RangeDept_ID
--						from T0050_HRMS_RangeDept_Allocation
--						where Cmp_ID= @cmpid  and range_id=@col  and Dept_ID = @deptid
--						  and Effective_Date <= @sadate
--						GROUP by RangeDept_ID
--					)RA on RA.RangeDept_ID = T0050_HRMS_RangeDept_Allocation.RangeDept_ID
					
					
--					open cur1  
--						Fetch Next From cur1 into @col1
--						WHILE @@FETCH_STATUS = 0
--							begin  
--								SELECT @achievement = Achievement_Level FROM T0040_Achievement_Master WHERE cmp_id=@cmpid and achievement_type =2 and AchievementId=@col
--								SELECT @percentalloc = Percent_Allocate FROM T0050_HRMS_RangeDept_Allocation WHERE Cmp_ID=@cmpid and Dept_ID= @deptid and RangeDept_ID=@col1
--								--print @col1
--								IF @sup <> 0
--									BEGIN 
--										IF @type=1
--											BEGIN
--													SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--														FROM      dbo.T0040_Achievement_Master left JOIN
--																  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--																  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--																  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--																  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id INNER JOIN        
--																		(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Increment_Effective_Date
--																				FROM T0095_INCREMENT I INNER JOIN
--																						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--																						 FROM T0095_INCREMENT Inner JOIN
--																								(
--																										SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																										FROM T0095_INCREMENT WHERE CMP_ID = @cmpid 													
--																										GROUP BY EMP_ID
--																								) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--																						 WHERE CMP_ID = @cmpid 
--																						 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--																				WHERE I.Cmp_ID= @cmpid 
--																		)i on i.Emp_ID = d.Emp_ID AND Increment_Effective_Date <=cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))
--		  															LEFT JOIN
--																		(
--																			SELECT T0095_Department_Manager.Dept_Id,Emp_id 
--																			FROM T0095_Department_Manager INNER JOIN
--																			(
--																				SELECT MAX(Effective_Date) AS Effective_Date , Dept_Id 
--																				from T0095_Department_Manager
--																				where Cmp_id=@cmpid and Dept_Id=@deptid GROUP by Dept_Id
--																			)DM1 on DM1.Dept_Id = T0095_Department_Manager.Dept_Id
--																			WHERE Cmp_id=@cmpid 
--																		)DM ON DM.Dept_Id = i.Dept_ID  
--														WHERE   T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) 
--														and @sup = (CASE WHEN isnull(dbo.T0050_HRMS_InitiateAppraisal.hod_id,0) <> 0  then dbo.T0050_HRMS_InitiateAppraisal.hod_id else dm.Emp_id end) and 
--														d.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID and T0050_HRMS_InitiateAppraisal.SendToHOD=1 AND
--														ISNULL(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--														(SELECT isnull(max(Effective_Date),(SELECT From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--														isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--														(SELECT isnull(max(Effective_Date),(SELECT From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)
													
--													---commented on 30 Nov 2016--------------------------
--													--select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and  Achivement_Id=@col1 and DATEPART(YYYY,SA_Startdate)=@year and d.Emp_Superior=isnull(@sup,Emp_Superior)
--													--SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--													--FROM        dbo.T0040_Achievement_Master left JOIN
--													--					  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--													--					  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--													--					  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--													--					  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN T0095_INCREMENT I ON I.Emp_ID = d.Emp_ID and
--													--		I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--													--		and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))			  
--													--		left JOIN	T0095_Department_Manager DM ON dm.Dept_Id = I.Dept_ID and dm.Effective_Date =
--													--(select max(Effective_Date) from T0095_Department_Manager where Dept_Id = @deptid)
--													--Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) 
--													--and @sup = (case when isnull(dbo.T0050_HRMS_InitiateAppraisal.hod_id,0) <> 0  then dbo.T0050_HRMS_InitiateAppraisal.hod_id else dm.Emp_id end) and 
--													--d.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID and T0050_HRMS_InitiateAppraisal.SendToHOD=1 AND
--													--isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													--(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													--isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													--(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
													
--											END
--										ELSE
--											BEGIN
--												SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--												FROM        dbo.T0040_Achievement_Master left JOIN
--																	  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--																	  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--																	  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--																	  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN 
--																	(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Increment_Effective_Date
--																		FROM T0095_INCREMENT I INNER JOIN
--																				(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--																				 FROM T0095_INCREMENT Inner JOIN
--																						(
--																								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																								FROM T0095_INCREMENT WHERE CMP_ID = @cmpid 													
--																								GROUP BY EMP_ID
--																						) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--																				 WHERE CMP_ID = @cmpid 
--																				 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--																		where I.Cmp_ID= @cmpid 
--																)i on i.Emp_ID = d.Emp_ID and Increment_Effective_Date <=cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))		  
--												Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Emp_Superior=isnull(@sup,Emp_Superior) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID	 AND
--															isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--															(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
												
--												---commented on 30 Nov 2016--------------------------
--												--SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--												--FROM        dbo.T0040_Achievement_Master left JOIN
--												--					  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--												--					  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--												--					  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--												--					  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN T0095_INCREMENT I ON I.Emp_ID = d.Emp_ID and
--												--			I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--												--			and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))			  
--												--Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Emp_Superior=isnull(@sup,Emp_Superior) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID	 AND
--												--			isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--												--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
												
--											End
											
--										SELECT   @eid=(T0050_HRMS_InitiateAppraisal.emp_id)  
--										FROM        dbo.T0040_Achievement_Master left JOIN
--															  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--															  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--															  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--															  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN 
--															(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Increment_Effective_Date
--																FROM T0095_INCREMENT I INNER JOIN
--																		(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--																		 FROM T0095_INCREMENT Inner JOIN
--																				(
--																						SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																						FROM T0095_INCREMENT WHERE CMP_ID = @cmpid 													
--																						GROUP BY EMP_ID
--																				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--																		 WHERE CMP_ID = @cmpid 
--																		 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--																where I.Cmp_ID= @cmpid 
--														)i on i.Emp_ID = d.Emp_ID and Increment_Effective_Date <=cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))				  
--														inner JOIN
--														(
--															SELECT ER1.R_Emp_ID ,er1.emp_id 
--															FROM T0090_EMP_REPORTING_DETAIL ER1 INNER JOIN
--															(
--																SELECT MAX(Effect_Date) AS Increment_Effective_Date , EMP_ID 
--																FROM T0090_EMP_REPORTING_DETAIL WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--															)ER2 on ER2.Emp_ID = ER1.Emp_ID
--															WHERE ER1.Cmp_ID=@cmpid
--														)ER on er.Emp_ID = d.Emp_Id	
--										Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and er.R_Emp_ID=isnull(@sup,R_Emp_ID) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--													isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016	
										
--										---commented on 30 Nov 2016-----------------------	
--										--SELECT   @eid=(T0050_HRMS_InitiateAppraisal.emp_id)  
--										--FROM        dbo.T0040_Achievement_Master left JOIN
--										--					  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--										--					  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--										--					  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--										--					  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN T0095_INCREMENT I ON I.Emp_ID = d.Emp_ID and
--										--					I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--										--					and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))			  
--										--Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Emp_Superior=isnull(@sup,Emp_Superior) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--										--			isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--										--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--										--			isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--										--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
										
--										--select @deptcnt = COUNT(emp_id) from T0080_EMP_MASTER where Dept_ID=@deptid and Cmp_ID=@cmpid and Emp_Left<>'Y' and Emp_Superior = @sup
										
										
--										select  @deptcnt = COUNT(e.emp_id) 
--										from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										i.Emp_Id=e.Emp_ID 
--										 INNER JOIN        
--											(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
--													FROM T0095_INCREMENT I INNER JOIN
--															(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--															 FROM T0095_INCREMENT Inner JOIN
--																	(
--																			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																			FROM T0095_INCREMENT WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--																	) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--															 WHERE CMP_ID = @cmpid
--															 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID
--													where I.Cmp_ID= @cmpid 
--											)IE on ie.Emp_ID = e.Emp_ID
--										where IE.Dept_ID=@deptid  and Emp_Left<>'Y' 
--										and DATEPART(YYYY,SA_Startdate)=@year  
--										---commented on 30 Nov 2016------------------
--										--select @deptcnt = COUNT(e.emp_id) 
--										--from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										--i.Emp_Id=e.Emp_ID inner join T0095_INCREMENT ie on ie.Emp_ID=e.emp_id and ie.Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=e.emp_id)
--										--where ie.Dept_ID=@deptid  and Emp_Left<>'Y' 
--										--and DATEPART(YYYY,SA_Startdate)=@year 
										
--										--select @deptcnt = COUNT(e.emp_id) 
--										--from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										--i.Emp_Id=e.Emp_ID
--										--where e.Dept_ID=@deptid and e.Cmp_ID=@cmpid and Emp_Left<>'Y' and Emp_Superior = @sup   
--										--and DATEPART(YYYY,SA_Startdate)=@year 
--									End									
--								Else
--									begin
--										--select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id left join T0040_HRMS_RangeMaster as r on r.Range_ID=e.Achivement_Id  where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid  and  Achivement_Id=@col1 and DATEPART(YYYY,SA_Startdate)=@year and r.Range_ID = @col1
																			
--										SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--										FROM      dbo.T0040_Achievement_Master left JOIN
--												  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--												  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--												  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--												  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id INNER JOIN        
--														(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Increment_Effective_Date
--																FROM T0095_INCREMENT I INNER JOIN
--																		(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--																		 FROM T0095_INCREMENT Inner JOIN
--																				(
--																						SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																						FROM T0095_INCREMENT WHERE CMP_ID = @cmpid 													
--																						GROUP BY EMP_ID
--																				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--																		 WHERE CMP_ID = @cmpid 
--																		 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--																where I.Cmp_ID= @cmpid 
--														)i on i.Emp_ID = d.Emp_ID and Increment_Effective_Date <=cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))
		  											
--											Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--													isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--													isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--													(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016 
										
--										-----commented on 30 Nov 2016----
--										--SELECT   @empcount=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--										--FROM        dbo.T0040_Achievement_Master left JOIN
--										--					  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--										--					  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--										--					  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--										--					  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id 
--										--					  inner JOIN T0095_INCREMENT I ON I.Emp_ID = d.Emp_ID and
--										--					I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--										--					and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))			  
--										--Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--										--			isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--										--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--										--			isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--										--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
										
--										SELECT    @eid=count(T0050_HRMS_InitiateAppraisal.emp_id)  
--										FROM        dbo.T0040_Achievement_Master left JOIN
--															  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--															  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--															  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--															  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN 
--															(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Increment_Effective_Date
--																FROM T0095_INCREMENT I INNER JOIN
--																		(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--																		 FROM T0095_INCREMENT Inner JOIN
--																				(
--																						SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																						FROM T0095_INCREMENT WHERE CMP_ID = @cmpid 													
--																						GROUP BY EMP_ID
--																				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--																		 WHERE CMP_ID = @cmpid 
--																		 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--																where I.Cmp_ID= @cmpid 
--														)i on i.Emp_ID = d.Emp_ID and Increment_Effective_Date <=cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))	
--										WHERE    T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--												isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--												(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--												isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--												(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
										
--										-----commented on 30 Nov 2016----
--										--SELECT   @eid=(T0050_HRMS_InitiateAppraisal.emp_id) 
--										--FROM        dbo.T0040_Achievement_Master left JOIN
--										--					  dbo.T0040_HRMS_RangeMaster ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0040_HRMS_RangeMaster.Range_AchievementId left JOIN
--										--					  dbo.T0050_HRMS_InitiateAppraisal ON dbo.T0040_HRMS_RangeMaster.Range_ID = dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id left JOIN
--										--					  dbo.T0050_HRMS_RangeDept_Allocation ON dbo.T0040_Achievement_Master.AchievementId = dbo.T0050_HRMS_RangeDept_Allocation.Range_ID left join
--										--					  V0080_Employee_Details as d on d.emp_id=T0050_HRMS_InitiateAppraisal.emp_id inner JOIN T0095_INCREMENT I ON I.Emp_ID = d.Emp_ID and
--										--		I.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = I.Emp_ID
--										--		and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(T0050_HRMS_InitiateAppraisal.SA_Startdate as varchar(12))))			  
--										--Where        T0050_HRMS_RangeDept_Allocation.Dept_ID=@deptid  and DATEPART(YYYY,SA_Startdate)=@year and T0050_HRMS_RangeDept_Allocation.RangeDept_ID=@col1 and Overall_Score= ISNULL(Overall_Score,Overall_Score) and i.Dept_ID = T0050_HRMS_RangeDept_Allocation.Dept_ID AND
--										--			isnull(T0040_Achievement_Master.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--										--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_Achievement_Master where cmp_id=@cmpid and effective_date<= @sadate) AND
--										--			isnull(T0040_HRMS_RangeMaster.Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) = 
--										--			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmpid)) from T0040_HRMS_RangeMaster where cmp_id=@cmpid and effective_date<= @sadate)-- added on 21 sep 2016
--										--select @deptcnt = COUNT(emp_id) from T0080_EMP_MASTER where Dept_ID=@deptid and Cmp_ID=@cmpid and Emp_Left<>'Y' 
										
--										select  @deptcnt = COUNT(e.emp_id) 
--										from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										i.Emp_Id=e.Emp_ID 
--										 INNER JOIN        
--											(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,Increment_Effective_Date
--													FROM T0095_INCREMENT I INNER JOIN
--															(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--															 FROM T0095_INCREMENT Inner JOIN
--																	(
--																			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--																			FROM T0095_INCREMENT WHERE CMP_ID = @cmpid GROUP BY EMP_ID
--																	) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--															 WHERE CMP_ID = @cmpid
--															 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--													where I.Cmp_ID= @cmpid 
--											)IE on ie.Emp_ID = e.Emp_ID
--										where IE.Dept_ID=@deptid  and Emp_Left<>'Y' and Increment_Effective_Date <= cast(I.SA_Startdate as varchar(12)) 
--										and DATEPART(YYYY,SA_Startdate)=@year  
--										---commented on 30 Nov 2016------------------
--										--select @deptcnt = COUNT(e.emp_id) 
--										--from T0080_EMP_MASTER as e left join T0050_HRMS_InitiateAppraisal as I on
--										--i.Emp_Id=e.Emp_ID --inner join T0095_INCREMENT ie on ie.Emp_ID=e.emp_id and ie.Increment_Effective_Date=(select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=e.emp_id)
--										--inner JOIN T0095_INCREMENT Ie ON Ie.Emp_ID = e.Emp_ID and
--										--		Ie.Increment_ID = (select max(i2.Increment_ID) from T0095_INCREMENT  i2 where i2.Emp_ID = Ie.Emp_ID
--										--		and i2.Increment_Effective_Date = (select max(i3.Increment_Effective_Date) from T0095_INCREMENT i3 WHERE i3.Emp_ID = i2.Emp_ID and Increment_Effective_Date <= cast(I.SA_Startdate as varchar(12))))
--										--where ie.Dept_ID=@deptid  and Emp_Left<>'Y' 
--										--and DATEPART(YYYY,SA_Startdate)=@year 
--									End		
															
--								set @actualper = (@empcount * 100)/@deptcnt
								
--								insert into #rangeCount(rangeid,Achievement,percentage_allocation,Actual_Percentage,empcount,empid)values(@col,@achievement,@percentalloc,@actualper,@empcount,@eid)
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
--	on t2.empid = t1.empid
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
---------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----first table for getting employee count in a range
--create table #rangeCount
--(
--	 rangeid  numeric(18,0)
--	,Achievement varchar(100)
--	,percentage_allocation numeric(18,2)
--	,Actual_Percentage numeric(18,2)
--	,empcount numeric(18,0)
--)
----second table for getting employees in a range
--create table #emptbl
--(
--	 rangeid numeric(18,0)
--	,empname varchar(100)
--)
--if @sup <> 0
--	begin
		
--		insert into #emptbl
--		(
--			rangeid,
--			empname
--		)
--		(
--			select Achivement_Id, 
--			(d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  as empname
--			from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and d.Grd_ID=@grd and e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year and d.Emp_Superior=isnull(@sup,Emp_Superior)
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
--			from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid  and e.Cmp_ID=@cmpid and DATEPART(YYYY,SA_Startdate)=@year 
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
--	select range_id from T0040_HRMS_RangeMaster where cmp_id=@cmpid and range_type=2 and Range_Dept like '%' + cast(@deptid as varchar(50)) + '%' --and Range_grade like '%' + cast(@grd as varchar(50)) + '%'
--	open cur
--		Fetch Next From cur into @col
--		WHILE @@FETCH_STATUS = 0
--			begin
--				--select @peralloc=a.Percent_allocate,@range_name=r.Range_Level from T0050_HRMS_RangeDept_Allocation as a left join T0040_HRMS_RangeMaster as r on r.Range_ID = a.Range_ID where a.cmp_id=@cmpid and dept_id=@deptid and  a.Range_ID=@col
--				--select @peralloc=Range_Percent_Allocate,@range_name=Range_Level from T0040_HRMS_RangeMaster where cmp_id=@cmpid and range_type=2 and Range_Dept like '%' + cast(@deptid as varchar(50)) + '%'  and  Range_ID=@col
--				--select @col
--				--select @peralloc=a.Percent_allocate,@range_name=r.Achievement_Level from T0050_HRMS_RangeDept_Allocation as a left join T0040_Achievement_Master as r on r.AchievementId = a.Range_ID where a.cmp_id=@cmpid and dept_id=@deptid and  r.AchievementId=@col
--				select @peralloc=l.Percent_Allocate,@range_name=a.Achievement_Level from T0040_HRMS_RangeMaster as r left join T0040_Achievement_Master as a on a.AchievementId = r.Range_AchievementId left join T0050_HRMS_RangeDept_Allocation as l on l.Range_ID = a.AchievementId where a.cmp_id=@cmpid and dept_id=@deptid and  r.Range_ID=@col 
--				if @sup <> 0
--					begin
--						select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid and  Achivement_Id=@col and DATEPART(YYYY,SA_Startdate)=@year and d.Emp_Superior=isnull(@sup,Emp_Superior)
--					End
--				Else
--					begin
--						select @empcount=count(e.Emp_Id)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=@deptid  and  Achivement_Id=@col and DATEPART(YYYY,SA_Startdate)=@year 
--					End	
--				select @deptcnt = COUNT(emp_id) from T0080_EMP_MASTER where Dept_ID=@deptid and Cmp_ID=@cmpid and Emp_Left<>'Y'
--				set @actualper = (@empcount * 100)/@deptcnt
				
--				--select @empname= (d.Alpha_Emp_Code +'-'+ d.Emp_Full_Name)  from T0050_HRMS_InitiateAppraisal as e left join V0080_Employee_Details as d on d.Emp_ID=e.Emp_Id where Overall_Score= ISNULL(Overall_Score,Overall_Score) and d.Dept_ID=41 and  Achivement_Id=@col	
--				insert into #rangeCount(rangeid,Achievement,percentage_allocation,Actual_Percentage,empcount) values(@col,@range_name,@peralloc,@actualper,@empcount)
--				Fetch Next From cur into @col
--			End		
--	Close cur	
--Deallocate cur

--create table #finaltbl
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

------------------------

