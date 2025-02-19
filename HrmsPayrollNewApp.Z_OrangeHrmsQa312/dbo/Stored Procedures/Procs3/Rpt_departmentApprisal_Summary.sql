
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_departmentApprisal_Summary]
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
    empid			numeric(18,0)
    ,empcode         varchar(50)
    ,empname        varchar(100)
    ,Designation    varchar(100)
    ,Grade			varchar(100)
    ,Doj			date
    ,dept           varchar(100)
    ,branchname     varchar(100)
    ,branchid      numeric(18,0)
	,deptid			numeric(18,0)
	,desigid			numeric(18,0)
	,catid           numeric(18,0)
	,typeid			numeric(18,0)
	,grd_id       	numeric(18,0)
	,achivementid   numeric(18,0)
	,achievement    varchar(100)
	,score			varchar(50) --numeric(18,2)
	,achsort		numeric(18)
	,is_emp		tinyint
	,promotion    varchar(100)    --may 19 2014
)

create table #tbl1
(
	achivementid  numeric(18,0)
	,achievement_level  varchar(50)
	,emp_id   numeric(18,0)
	,actualper numeric(18,2)
	,achsort  numeric(18,0)
)

DECLARE @query VARCHAR(max)
DECLARE @columns VARCHAR(8000)
declare @deptCount numeric(18,0)

declare @empcount as numeric(18,0)
declare @deptcnt as numeric(18,0)
declare @actualper as numeric(18,2)
declare @col2 as numeric(18,0)	

if @frmdate is null
	begin
		--if @deptId<>0
		if @deptId <> ''
			begin						
			insert into #TblAchievement(achievement,achivementid,empid,Designation,grade,empcode,empname,Doj,dept,branchname,branchid,deptid,desigid,catid,typeid,grd_id ,score,achsort,is_emp,promotion)
			select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),AchievementId,inc.emp_id,ds.Desig_Name,G.Grd_Name,em.Alpha_Emp_Code,em.Emp_Full_Name,em.Date_Of_Join,d.Dept_Name,b.Branch_Name,inc.Branch_ID,inc.Dept_ID,inc.Desig_Id,inc.Cat_ID,inc.Type_ID,inc.grd_id,i.Overall_Score,Achievement_Sort,1,
			case when isnull(i.Promo_Grade,0) <> 0 THEN gm.Grd_Name + '-' + isnull(dg.Desig_Name,'') else dg.Desig_Name END --Mukti(14072017)
			from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
			on   Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as i WITH (NOLOCK)
			on   i.Achivement_Id = r.Range_ID  left join T0080_EMP_MASTER as em WITH (NOLOCK)
			on em.Emp_ID=i.Emp_Id left join T0095_INCREMENT as inc WITH (NOLOCK)
			on   inc.Emp_ID=i.Emp_Id left join T0040_DESIGNATION_MASTER as ds WITH (NOLOCK)
			on ds.Desig_ID=inc.Desig_Id left join T0040_GRADE_MASTER as g WITH (NOLOCK)
			on g.Grd_ID = inc.Grd_ID 
			left join T0040_GRADE_MASTER as gm WITH (NOLOCK) on gm.Grd_ID = i.Promo_Grade
			left join T0030_BRANCH_MASTER as b WITH (NOLOCK)
			on b.Branch_ID = inc.Branch_ID left join T0030_CATEGORY_MASTER as c WITH (NOLOCK)
			on c.Cat_ID = inc.Cat_ID left join T0040_TYPE_MASTER as t WITH (NOLOCK)
			on t.Type_ID = inc.type_id left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
			on dg.Desig_ID=i.Promo_Desig left join T0040_DEPARTMENT_MASTER as D WITH (NOLOCK)
			on d.Dept_Id = inc.Dept_ID	 
			where r.cmp_id=@cmp_id  and range_type=2  and i.Emp_ID is not null --and i.Dept_ID=@deptId 
			and ISNULL(i.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(i.Dept_ID,0)),'#'))--Mukti(17062017) 
			and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=i.Emp_Id )
			AND isnull(a.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			AND isnull(r.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			 order by a.Achievement_Sort desc --and range_dept like '%#' + CAST(@deptId as varchar(50)) + '#%' )
			 
			 --select * from #TblAchievement
			 	--insert bell curve		
			 	
			insert into #TblAchievement (achievement,score,empcode,empname,is_emp)
			select (cast(b.Achievement_Sort as varchar)+'-'+ Achievement_Level),cast(Percent_Allocate as varchar(50)) + '%','','Bell Curve Policy for %age of employee count against deptt. strength ',0 from T0050_HRMS_RangeDept_Allocation as A WITH (NOLOCK) inner join T0040_Achievement_Master As B WITH (NOLOCK)
			on a.Cmp_id = b.Cmp_id and A.Range_ID = b.AchievementId
			where a.Cmp_id = @cmp_id and --Dept_ID = @deptId 
			ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@deptId,ISNULL(Dept_ID,0)),'#'))--Mukti(17062017) 
			and b.Achievement_Type = 2
			AND isnull(B.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
				(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			order by b.Achievement_Sort desc
		
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
									insert into #tbl1(achievement_level,achivementid,emp_id,achsort) 
										select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),a.AchievementId,i.emp_id,a.Achievement_Sort from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id
										 where a.AchievementId=@col2 and 
										 --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y' 
										 AND isnull(r.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
										 AND isnull(a.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster  WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
										 order by a.Achievement_Sort desc 
										 
										 select @empcount=COUNT(i.Emp_ID) from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id
										 AND isnull(r.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
										 AND isnull(a.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
											(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
										 where a.AchievementId=@col2 and 
										 --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y' 
										 
										 if @emp_id is null
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on 
												i.Emp_Id=e.Emp_ID
												where 
												--e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' 
											End
										Else
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on
												i.Emp_Id=e.Emp_ID
												where 
												--e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' and Emp_Superior=@emp_id
											End
										if @deptcnt > 0
										begin
											set @actualper = (@empcount * 100)/@deptcnt 
											update #tbl1 set actualper = @actualper where achivementid=@col2
											fetch next from cur1 into @col2
										end
									End
							close cur1
							deallocate cur1	
			
			insert into #TblAchievement (achievement,score,empcode,empname,is_emp)
			select distinct(A.Achievement_Level),cast(actualper as varchar(50))+'%','','Actual %age of employees count against deptt. Strength',0 from #tbl1 as A inner join T0040_Achievement_Master As B WITH (NOLOCK)
			on  A.achivementid = b.AchievementId where 
			b.Achievement_Type = 2 AND 
			isnull(B.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			----
			SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
			'[' + cast(achievement as varchar)+ ']')
			 FROM #TblAchievement
			GROUP BY achievement
			order by achievement desc
		 
				
				SET @query = 'SELECT dept as Department,Branchname as Branch,empcode As EmpCode,empname As EmpName,designation as Designation,Grade,convert(varchar(24),doj,103)as doj,promotion as ''Promotion Recommended'',branchid,deptid,desigid,catid,typeid,grd_id,is_emp,'+ @columns +'
							FROM (
								SELECT 
									* 
								FROM #TblAchievement 
							)  as s 
							PIVOT
							(
								max(score)
								FOR [achievement] IN (' + @columns + ')
							)AS T'
			End
		Else
			Begin	
				--if @deptId=0
				--	begin
				--		set @deptId=null
				--	End			
				insert into #TblAchievement(achievement,achivementid,empid,Designation,grade,empcode,empname,Doj,dept,branchname,branchid,deptid,desigid,catid,typeid,grd_id,score,is_emp,promotion)
			   (select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),AchievementId,inc.emp_id,ds.Desig_Name,G.Grd_Name,em.Alpha_Emp_Code,em.Emp_Full_Name,em.Date_Of_Join,d.Dept_Name,b.Branch_Name,inc.Branch_ID,inc.Dept_ID,inc.Desig_Id,inc.Cat_ID,inc.Type_ID,inc.grd_id,i.Overall_Score,1,
			   case when isnull(i.Promo_Grade,0) <> 0 THEN gm.Grd_Name + '-' + isnull(dg.Desig_Name,'') else dg.Desig_Name END --Mukti(14072017)
			from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
			on   Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as i WITH (NOLOCK)
			on   i.Achivement_Id = r.Range_ID  left join T0080_EMP_MASTER as em WITH (NOLOCK)
			on em.Emp_ID=i.Emp_Id left join T0095_INCREMENT as inc WITH (NOLOCK)
			on   inc.Emp_ID=i.Emp_Id left join T0040_DESIGNATION_MASTER as ds WITH (NOLOCK)
			on ds.Desig_ID=inc.Desig_Id left join T0040_GRADE_MASTER as g WITH (NOLOCK)
			on g.Grd_ID = inc.Grd_ID left join T0040_GRADE_MASTER as gm WITH (NOLOCK)
			on gm.Grd_ID = i.Promo_Grade left join T0030_BRANCH_MASTER as b WITH (NOLOCK)
			on b.Branch_ID = inc.Branch_ID left join T0030_CATEGORY_MASTER as c WITH (NOLOCK)
			on c.Cat_ID = inc.Cat_ID left join T0040_TYPE_MASTER as t WITH (NOLOCK)
			on t.Type_ID = inc.type_id left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
			on dg.Desig_ID=i.Promo_Desig left join T0040_DEPARTMENT_MASTER as D WITH (NOLOCK)
			on d.Dept_Id = inc.Dept_ID 	 
			where r.cmp_id=@cmp_id and a.Cmp_ID=@cmp_id and range_type=2 and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=i.Emp_Id )  
			AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate))--23/09/2016
			
				

				SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
				'[' + cast(achievement as varchar)+ ']')
				FROM #TblAchievement 
				GROUP BY achievement
				order by achievement desc
					
				SET @query = 'SELECT dept as Department,Branchname as Branch,empcode As EmpCode,empname As EmpName,designation as Designation,Grade,convert(varchar(24),doj,103)as doj,promotion as ''Promotion Recommended'',branchid,deptid,desigid,catid,typeid,grd_id ,is_emp,'+ @columns +'
								FROM (
									SELECT 
										* 
									FROM #TblAchievement 
								) as s
								PIVOT
								(
									max(score)
									FOR [achievement] IN (' + @columns + ')
								)AS T'
					
			End
	End
Else
	begin
		--if @deptId<>0		
		if @deptId <> ''  --Mukti(17062017)
			begin				
			insert into #TblAchievement(achievement,achivementid,empid,Designation,grade,empcode,empname,Doj,dept,branchid,branchname,deptid,desigid,catid,typeid,grd_id,score,is_emp,promotion)
			(select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),AchievementId,inc.emp_id,ds.Desig_Name,G.Grd_Name,em.Alpha_Emp_Code,em.Emp_Full_Name,em.Date_Of_Join,d.Dept_Name,inc.Branch_ID,b.Branch_Name,inc.Dept_ID,inc.Desig_Id,inc.Cat_ID,inc.Type_ID,inc.grd_id,i.Overall_Score,1,
			case when isnull(i.Promo_Grade,0) <> 0 THEN gm.Grd_Name + '-' + isnull(dg.Desig_Name,'') else dg.Desig_Name END --Mukti(14072017)
			from T0040_Achievement_Master as a WITH (NOLOCK) left join T0040_HRMS_RangeMaster r WITH (NOLOCK)
			on   Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as i
			on   i.Achivement_Id = r.Range_ID  left join T0080_EMP_MASTER as em WITH (NOLOCK)
			on em.Emp_ID=i.Emp_Id left join T0095_INCREMENT as inc WITH (NOLOCK)
			on   inc.Emp_ID=i.Emp_Id left join T0040_DESIGNATION_MASTER as ds WITH (NOLOCK)
			on ds.Desig_ID=inc.Desig_Id left join T0040_GRADE_MASTER as g WITH (NOLOCK)
			on g.Grd_ID = inc.Grd_ID left join T0040_GRADE_MASTER as gm WITH (NOLOCK)
			on gm.Grd_ID = i.Promo_Grade left join T0030_BRANCH_MASTER as b WITH (NOLOCK)
			on b.Branch_ID = inc.Branch_ID left join T0030_CATEGORY_MASTER as c WITH (NOLOCK)
			on c.Cat_ID = inc.Cat_ID left join T0040_TYPE_MASTER as t WITH (NOLOCK)
			on t.Type_ID = inc.type_id left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
			on dg.Desig_ID=i.Promo_Desig left join T0040_DEPARTMENT_MASTER as D WITH (NOLOCK)
			on d.Dept_Id = inc.Dept_ID	 	 
			 where r.cmp_id=@cmp_id and a.Cmp_ID=@cmp_id and range_type=2 and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=i.Emp_Id ) 
			 and --i.Dept_ID=@deptId 
			 ISNULL(i.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(i.Dept_ID,0)),'#'))--Mukti(17062017) 
			 and (i.SA_Startdate between @frmdate and @enddate) or (i.SA_Startdate is null and Achievement_Type=2  and a.Cmp_ID=@cmp_id) 
			 AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate))--23/09/2016)
				

			insert into #TblAchievement (achievement,score,empcode,empname)
			select (cast(b.Achievement_Sort as varchar)+'-'+ Achievement_Level),cast(Percent_Allocate as varchar(50)) + '%','','Bell Curve Policy for %age of employee count against deptt. strength' from T0050_HRMS_RangeDept_Allocation as A WITH (NOLOCK) inner join T0040_Achievement_Master As B WITH (NOLOCK)
			on a.Cmp_id = b.Cmp_id and A.Range_ID = b.AchievementId
			where a.Cmp_id = @cmp_id and --Dept_ID = @deptId 
			ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(Dept_ID,0)),'#'))--Mukti(17062017) 
			and b.Achievement_Type = 2
AND			isnull(B.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
				(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0050_HRMS_RangeDept_Allocation WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016

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
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y'
										 AND isnull(a.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
										(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
										AND isnull(r.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
										(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate))
										 
										 select @empcount=COUNT(i.Emp_ID) from T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) left join
										 T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=i.Achivement_Id left join
										 T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId left join 
										 T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID=i.Emp_Id
										 where a.AchievementId=@col2 and --e.Dept_ID=@deptId 
										 ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
										 and e.Emp_Left<>'Y'
										 AND isnull(a.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
										(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
										AND isnull(r.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
										(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)
										 
										if @emp_id is null
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on 
												i.Emp_Id=e.Emp_ID
												where --e.Dept_ID=@deptId
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' 
											End
										Else
											begin
												select @deptcnt = COUNT(e.emp_id) 
												from T0080_EMP_MASTER as e WITH (NOLOCK) inner join T0050_HRMS_InitiateAppraisal as I WITH (NOLOCK) on
												i.Emp_Id=e.Emp_ID
												where --e.Dept_ID=@deptId 
												ISNULL(e.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@DeptID,ISNULL(e.Dept_ID,0)),'#'))--Mukti(17062017) 
												and e.Cmp_ID=@cmp_id and Emp_Left<>'Y' and Emp_Superior=@emp_id
											End
										if @deptcnt > 0
										begin
											set @actualper = (@empcount * 100)/@deptcnt 
											update #tbl1 set actualper = @actualper where achivementid=@col2
											fetch next from cur1 into @col2
										end
									End
							close cur1
							deallocate cur1	
			
			insert into #TblAchievement (achievement,score,empcode,empname)
			select distinct(A.Achievement_Level),cast(actualper as varchar(50))+'%','','Actual %age of employees count against deptt. Strength' from #tbl1 as A inner join T0040_Achievement_Master As B WITH (NOLOCK)
			on  A.achivementid = b.AchievementId where 
			b.Achievement_Type = 2
			----


				SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
			'[' + cast(achievement as varchar)+ ']')
			FROM #TblAchievement
			GROUP BY achievement
			order by achievement desc	
			
				SET @query = 'SELECT dept as Department,Branchname as Branch,empcode As EmpCode,empname As EmpName,designation as Designation,Grade,convert(varchar(24),doj,103)as doj,promotion as ''Promotion Recommended'' ,branchid,deptid,desigid,catid,typeid,grd_id,is_emp ,'+ @columns +'
							FROM (
								SELECT 
									* 
								FROM #TblAchievement
							) as s
							PIVOT
							(
								max(score)
								FOR [achievement] IN (' + @columns + ')
							)AS T'
						
			End
		Else
			Begin	
				--if @deptId=0
				--	begin
				--		set @deptId=null
				--	End	
								
				insert into #TblAchievement(achievement,achivementid,empid,Designation,grade,empcode,empname,Doj,dept,branchid,branchname,deptid,desigid,catid,typeid,grd_id,score,is_emp,promotion)
			(select (cast(a.Achievement_Sort as varchar)+'-'+ Achievement_Level),AchievementId,inc.emp_id,ds.Desig_Name,G.Grd_Name,em.Alpha_Emp_Code,em.Emp_Full_Name,em.Date_Of_Join,d.Dept_Name,inc.Branch_ID,b.Branch_Name,inc.Dept_ID,inc.Desig_Id,inc.Cat_ID,inc.Type_ID,inc.grd_id,i.Overall_Score,1,
			case when isnull(i.Promo_Grade,0) <> 0 THEN gm.Grd_Name + '-' + isnull(dg.Desig_Name,'') else dg.Desig_Name END --Mukti(14072017)
			from T0040_Achievement_Master as a WITH (NOLOCK)  left join T0040_HRMS_RangeMaster r WITH (NOLOCK) 
			on   Range_AchievementId= a.AchievementId left join V0050_HRMS_InitiateAppraisal as i
			on   i.Achivement_Id = r.Range_ID  left join T0080_EMP_MASTER as em WITH (NOLOCK)
			on em.Emp_ID=i.Emp_Id left join T0095_INCREMENT as inc WITH (NOLOCK)
			on   inc.Emp_ID=i.Emp_Id left join T0040_DESIGNATION_MASTER as ds WITH (NOLOCK)
			on ds.Desig_ID=inc.Desig_Id left join T0040_GRADE_MASTER as g WITH (NOLOCK)
			on g.Grd_ID = inc.Grd_ID left join T0040_GRADE_MASTER as gm WITH (NOLOCK) on gm.Grd_ID = i.Promo_Grade
			left join T0030_BRANCH_MASTER as b WITH (NOLOCK)
			on b.Branch_ID = inc.Branch_ID left join T0030_CATEGORY_MASTER as c WITH (NOLOCK)
			on c.Cat_ID = inc.Cat_ID left join T0040_TYPE_MASTER as t WITH (NOLOCK)
			on t.Type_ID = inc.type_id left join T0040_DESIGNATION_MASTER as dg WITH (NOLOCK)
			on dg.Desig_ID=i.Promo_Desig left join T0040_DEPARTMENT_MASTER as D WITH (NOLOCK)
			on d.Dept_Id = inc.Dept_ID	 	 
			where r.cmp_id=@cmp_id and a.Cmp_ID=@cmp_id and range_type=2 and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=i.Emp_Id )  and i.SA_Startdate between @frmdate and @enddate or (i.SA_Startdate is null and Achievement_Type=2 and a.Cmp_ID=@cmp_id)  
				AND isnull(A.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_Achievement_Master WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate)--23/09/2016
			AND isnull(R.Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) = 
			(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) from T0040_HRMS_RangeMaster WITH (NOLOCK) where cmp_id=@cmp_id and effective_date<= @frmdate) )				

				--select * from #TblAchievement

				SELECT @columns = COALESCE(@columns + ',[' + cast(achievement as varchar) + ']',
				'[' + cast(achievement as varchar)+ ']')
				FROM #TblAchievement
				GROUP BY achievement
				order by achievement desc
				
				SET @query = 'SELECT dept as Department,Branchname as Branch, empcode As EmpCode,empname As EmpName,designation as Designation,Grade,convert(varchar(24),doj,103)as doj,promotion as ''Promotion Recommended'' ,branchid,deptid,desigid,catid,typeid,grd_id,is_emp ,'+ @columns +'
								FROM (
									SELECT 
										* 
									FROM #TblAchievement
								) as s
								PIVOT
								(
									max(score)
									FOR [achievement] IN (' + @columns + ')
								)AS T'
					
			End
	End



if @dyQuery <> ''
begin
	
set @query= 'select ROW_NUMBER() OVER (PARTITION BY is_emp ORDER BY Department,Branch,empcode) AS Srno ,* from (' + @query + ') as tbl1 where empcode is not null and empcode <> '''' '
exec (@query +  @dyquery + ' order by Department,Branch,empcode') 
print (@query +  @dyquery )
End
else
	begin
	
		set @query = 'select ROW_NUMBER() OVER (PARTITION BY is_emp ORDER BY Department,Branch,empcode) AS Srno ,* from (' + @query + ') as tbl1 where empcode is not null and empcode <> '''' order by Department,Branch,empcode asc '
		--		select @query
		EXECUTE(@query)
		print (@query)

	End
	
DROP	table #tbl1
drop table #TblAchievement

END
------------------

