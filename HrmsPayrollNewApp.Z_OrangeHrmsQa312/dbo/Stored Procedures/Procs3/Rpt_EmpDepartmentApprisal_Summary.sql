

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_EmpDepartmentApprisal_Summary]
	     @cmp_id    as numeric(18,0)
		--,@deptId    as numeric(18,0)=null
		,@deptId    as varchar(max)='' --Mukti(16062017)
		,@emp_id    as numeric(18,0)=null
		,@frmdate   as datetime 
		,@enddate   as datetime = getdate
		,@dyQuery   varchar(max)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	declare @sno	   as numeric(18,0)	
	declare @col1      as numeric(18,0)
	set @sno =null
	if @deptId IS NULL  --Mukti(17062017)
	BEGIN
		set @deptId = ''
	END
	create table #TblAchievement
	(   
		 empid			numeric(18,2) --numeric(18,2)
		,dept           varchar(100)
		,achieveid    numeric(18,0)
		--,branchid       numeric(18,0)
		--,deptid			numeric(18,0)
		--,desigid		numeric(18,0)
		--,catid          numeric(18,0)
		--,typeid			numeric(18,0)
		--,grd_id       	numeric(18,0)
		,achievement   varchar(100)		
	)
	
create table #tbl1
(
	achivementid  numeric(18,0)
	,achievement_level  varchar(50)
	,emp_id   numeric(18,0)
	,actualper numeric(18,2)
)
	
	DECLARE @query VARCHAR(max)
	DECLARE @columns VARCHAR(8000)
	declare @empcount as numeric(18,0)
	declare @deptcnt as numeric(18,0)
	declare @actualper as numeric(18,2)
	declare @col2 as numeric(18,0)	
	
	if @frmdate is null
	begin
		--if @deptId<>0
		if @deptId <> '' --Mukti(17062017)
			begin				
				insert into #TblAchievement(dept,empid,achievement,achieveid)
				(Select (i.Dept_Name),(i.Emp_Id),(cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),1
				from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
				on Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as I  
				on i.Achivement_Id = r.Range_ID 
				where r.cmp_id=@cmp_id and range_type=2 --and i.Dept_ID=@deptId --and range_dept like '%#' + CAST(@deptId as varchar(50)) + '#%' 
				and ISNULL(i.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(i.Dept_ID,0)),'#'))--Mukti(17062017) 
					AND isnull(a.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
					AND isnull(r.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				group by Dept_Name,i.Emp_Id,Achievement_Level,Achievement_Sort)			--and i.Emp_Id is not null 
			
					
				insert into #TblAchievement (achievement,empid,dept,achieveid)				
			    select (cast(b.Achievement_Sort as varchar)+'-'+ Achievement_Level),Percent_Allocate,' Bell Curve Policy for %age of employee count',0 from T0050_HRMS_RangeDept_Allocation as A WITH (NOLOCK) inner join T0040_Achievement_Master As B WITH (NOLOCK)
			    on a.Cmp_id = b.Cmp_id and A.Range_ID = b.AchievementId
			    where a.Cmp_id = @cmp_id and --Dept_ID = @deptId 
			    ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(Dept_ID,0)),'#'))--Mukti(17062017) 
			    and b.Achievement_Type = 2						
				AND isnull(B.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)	
				---
			
			declare cur1 cursor
							for 
								select AchievementId from T0040_Achievement_Master WITH (NOLOCK) where achievement_type=2 
								AND isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
									(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
							open cur1
								fetch next from cur1 into @col2
								while @@FETCH_STATUS = 0
									begin
									insert into #tbl1(achievement_level,achivementid,emp_id) (
										select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),a.AchievementId,i.emp_id from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id 
										 where a.AchievementId=@col2 and --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y' and a.cmp_id = @cmp_id
										 AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)	)--23/09/2016
										 
										 select @empcount=COUNT(i.Emp_ID) from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id  
										 where a.AchievementId=@col2 and --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y' and a.cmp_id = @cmp_id
										 AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										 
										 
										if @emp_id is null
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on 
												i.Emp_Id=e.Emp_ID
												where --e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' 
											End
										Else
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on
												i.Emp_Id=e.Emp_ID
												where --e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' and Emp_Superior=@emp_id
											End
										
										set @actualper = (@empcount * 100)/@deptcnt 
										update #tbl1 set actualper = @actualper where achivementid=@col2
										fetch next from cur1 into @col2
									End
							close cur1
							deallocate cur1	
			
			insert into #TblAchievement (achievement,empid,dept,achieveid)
			select distinct(A.Achievement_Level),actualper,' Actual %age of employees count ',0 from #tbl1 as A inner join T0040_Achievement_Master As B WITH (NOLOCK)
			on  A.achivementid = b.AchievementId where 
			b.Achievement_Type = 2 AND isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
						(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master  WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										
			----	
				
				SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
				'[' + cast(achievement as varchar)+ ']')
				FROM #TblAchievement
				GROUP BY achievement
				order by achievement desc
				
				SET @query = 'SELECT dept,achieveid ,'+ @columns +'
								FROM (
									SELECT 
									* 
									FROM #TblAchievement  where dept ='' Bell Curve Policy for %age of employee count'' or dept ='' Actual %age of employees count ''
									) as s
								PIVOT
								(
								 
									max(empid)
									FOR [achievement] IN (' + @columns + ') 
								
								)AS T'  
   
   	 
   	 
   	 SET @query = @query +  ' Union all SELECT dept,achieveid ,'+ @columns +'
								FROM (
									SELECT 
									* 
									FROM #TblAchievement  where dept <>'' Bell Curve Policy for %age of employee count'' and dept <>'' Actual %age of employees count ''
									
									) as s
								PIVOT
								(
									count(empid) 
									FOR [achievement] IN (' + @columns + ') 
									
									
								)AS T'  
			End
		else
			BEGIN 
				insert into #TblAchievement(dept,empid,achievement,achieveid)
				(Select (i.Dept_Name),(i.Emp_Id),(cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),1
				from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
				on Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as I  
				on i.Achivement_Id = r.Range_ID 
				where r.cmp_id=@cmp_id and range_type=2  
				AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				group by Dept_Name,i.Emp_Id,Achievement_Level,Achievement_Sort)				--and i.Emp_Id is not null 
				
				
				
				SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
				'[' + cast(achievement as varchar)+ ']')
				FROM #TblAchievement
				GROUP BY achievement
				order by achievement desc
				
				SET @query = 'SELECT (dept),achieveid,'+ @columns +'
								FROM (
									SELECT 
										* 
									FROM #TblAchievement
								) as s
								PIVOT
								(
									Count(empid)
									FOR [achievement] IN (' + @columns + ')
								)AS T'
			END
	End
Else
	Begin
		--if @deptId<>0
		if @deptId <> '' 
			begin
				insert into #TblAchievement(dept,empid,achievement,achieveid)
				(Select (i.Dept_Name),(i.Emp_Id),(cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),1
				from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
				on Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as I 
				on i.Achivement_Id = r.Range_ID 
				where r.cmp_id=@cmp_id and range_type=2  and --i.Dept_ID=@deptId  
				ISNULL(i.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(i.Dept_ID,0)),'#'))--Mukti(17062017) 
				and (i.SA_Startdate between @frmdate and @enddate  or i.SA_Startdate is null) and Achievement_Type=2  --and range_dept like '%#' + CAST(@deptId as varchar(50)) + '#%' 
				AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				group by Dept_Name,i.Emp_Id,Achievement_Level,Achievement_Sort)		
				
				
				insert into #TblAchievement (achievement,empid,dept,achieveid)				
			    select (cast(b.Achievement_Sort as varchar)+'-'+ Achievement_Level),Percent_Allocate ,' Bell Curve Policy for %age of employee count',0 from T0050_HRMS_RangeDept_Allocation as A WITH (NOLOCK) inner join T0040_Achievement_Master As B WITH (NOLOCK)
			    on a.Cmp_id = b.Cmp_id and A.Range_ID = b.AchievementId
			    where a.Cmp_id = @cmp_id and --Dept_ID = @deptId 
			    ISNULL(Dept_ID,0) in(SELECT CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(Dept_ID,0)),'#'))--Mukti(17062017) 
			    and b.Achievement_Type = 2	
				AND isnull(B.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				
				---
			
			declare cur1 cursor
							for 
								select AchievementId from T0040_Achievement_Master WITH (NOLOCK) where achievement_type=2 
								AND isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
							open cur1
								fetch next from cur1 into @col2
								while @@FETCH_STATUS = 0
									begin
									insert into #tbl1(achievement_level,achivementid,emp_id) (
										select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),a.AchievementId,i.emp_id from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id  
										 where a.AchievementId=@col2 and --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y' and a.cmp_id = @cmp_id
										 AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										 AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate))
										 
										 select @empcount=COUNT(i.Emp_ID) from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id  
										 where a.AchievementId=@col2 and --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y' and a.cmp_id = @cmp_id
										 AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										 AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										 
										 
										if @emp_id is null
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on
												i.Emp_Id=e.Emp_ID
												where --e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' 
											End
										Else
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on
												i.Emp_Id=e.Emp_ID
												where --e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' and Emp_Superior=@emp_id
											End
																			
										
										set @actualper = (@empcount * 100)/@deptcnt 
										update #tbl1 set actualper = @actualper where achivementid=@col2
										fetch next from cur1 into @col2
									End
							close cur1
							deallocate cur1	
			
			
			
			insert into #TblAchievement (achievement,empid,dept,achieveid)
			select distinct(A.Achievement_Level),actualper,' Actual %age of employees count ',0 from #tbl1 as A inner join T0040_Achievement_Master As B WITH (NOLOCK)
			on  A.achivementid = b.AchievementId where 
			b.Achievement_Type = 2
			----	
				
				
				SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
				'[' + cast(achievement as varchar)+ ']')
				FROM #TblAchievement
				GROUP BY achievement
				order by achievement desc
				
				SET @query = 'SELECT dept,achieveid ,'+ @columns +'
								FROM (
									SELECT 
									* 
									FROM #TblAchievement  where dept ='' Bell Curve Policy for %age of employee count'' or dept ='' Actual %age of employees count ''
									) as s
								PIVOT
								(
								 
									max(empid)
									FOR [achievement] IN (' + @columns + ') 
								
								)AS T'  
   
   	 
   	 
   	 SET @query = @query +  ' Union all SELECT dept,achieveid ,'+ @columns +'
								FROM (
									SELECT 
									* 
									FROM #TblAchievement  where dept <>'' Bell Curve Policy for %age of employee count'' and dept <>'' Actual %age of employees count ''
									
									) as s
								PIVOT
								(
									count(empid) 
									FOR [achievement] IN (' + @columns + ') 
									
									
								)AS T'  
			End
		Else
			Begin 
				if @emp_id is NULL
				begin
				insert into #TblAchievement(dept,empid,achievement,achieveid)
				(Select (i.Dept_Name),(i.Emp_Id),(cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),1
				from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK) 
				on Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as I  
				on i.Achivement_Id = r.Range_ID 
				where r.cmp_id=@cmp_id and range_type=2  and (i.SA_Startdate between @frmdate and @enddate  or i.SA_Startdate is null) and Achievement_Type=2
				AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
					(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
				group by Dept_Name,i.Emp_Id,Achievement_Level,Achievement_Sort)		
				END
			ELSE
				Begin 
					insert into #TblAchievement(dept,empid,achievement,achieveid)
					(Select (i.Dept_Name),(i.Emp_Id),(cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),1
					from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
					on Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as I  
					on i.Achivement_Id = r.Range_ID left join T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) on er.Emp_ID = i.Emp_Id and er.Effect_Date =(select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=i.emp_id and Effect_Date<=@frmdate)
					where r.cmp_id=@cmp_id and range_type=2  and (i.SA_Startdate between @frmdate and @enddate  or i.SA_Startdate is null) and Achievement_Type=2 and er.R_Emp_ID=@emp_id
					AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
						(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
					AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
						(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
					group by Dept_Name,i.Emp_Id,Achievement_Level,Achievement_Sort)	
				end
				
				
					SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
					'[' + cast(achievement as varchar)+ ']')
					FROM #TblAchievement 
					GROUP BY achievement
					order by achievement desc
				
				
				
				SET @query = 'SELECT (dept),achieveid,'+ @columns +'
								FROM (
									SELECT 
										* 
									FROM #TblAchievement 
								) as s
								PIVOT
								(
									count(empid)
									FOR [achievement] IN (' + @columns + ')
								)AS T'
				
				
				
			End
	End
	--set @query = 'select ROW_NUMBER() OVER (ORDER BY dept) AS Srno ,* from (' + @query + ') as tbl1 where dept is not null '

	--EXECUTE(@query)
	
	
	
	if @dyQuery <> ''
		begin
			set @query = 'select ROW_NUMBER() OVER (PARTITION BY achieveid ORDER BY dept) AS Srno ,* from (' + @query + ') as tbl1 where dept is not null '
			exec (@query +  @dyquery ) 
		--print (@query +  @dyquery )
		End
	else
		begin
			set @query = 'select ROW_NUMBER() OVER (PARTITION BY achieveid ORDER BY dept) AS Srno ,* from (' + @query + ') as tbl1 where dept is not null '
			EXECUTE(@query)			
		End	
		
	DROP table #tbl1
	drop table #TblAchievement
END
----------------

