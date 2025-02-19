


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Rpt_TrainingAppraisal 9,null,null,'2014-04-01',null,''
 -- exec Rpt_TrainingAppraisal 9,null,null,'2014-04-01',null,''
 ---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_TrainingAppraisal]
	@cmp_id    as numeric(18,0)	
	--,@deptId    as numeric(18,0)=null
	,@deptId    as varchar(max)='' --Mukti(16062017)
	,@emp_id    as numeric(18,0)=null
	,@frmdate   as datetime 
	,@enddate   as datetime = getdate
	,@dyQuery   varchar(max)=''
	--,@type      as int  
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
create table #table1
(
	 trainid			varchar(100)
	,trainname			varchar(100)	
	,Initiation_Id		numeric(18,0)
	,Emp_Id				numeric(18,0)
	,EmpCode			varchar(100)
	,Emp_Full_Name		varchar(100)
	,Department			varchar(100)
	,branch				varchar(100)
	,designation		varchar(100)
	,Supportive			varchar(max)
	,Functional			varchar(max)
	,Anyother			varchar(500)
	,branchid			numeric(18,0) --Mukti(07112016)
	,Dept_ID			numeric(18,0)
	,desigid			numeric(18,0)
	,grd_id				numeric(18,0)
	,catid				numeric(18,0)
	,typeid				numeric(18,0)
)
	
create table #table2
(
	 trainid numeric(18,0)
	,trainname varchar(800)
	,type_t int
)

create table #table3
(
	   InitiateId		numeric(18,0)
      ,Emp_Id			numeric(18,0)
      ,Type_t			varchar(50)
      ,TrainingAreas	varchar(500)
)

declare @sno	   as numeric(18,0)	
set @sno=null
declare @col1      as varchar(100)
declare @col2	   as numeric(18,0)
declare @InitiateId as numeric(18,0)
declare @EmpId		as numeric(18,0)
declare @Type_t		as  varchar(50)
declare @TrainingAreas	as  varchar(50)
declare @OtherTraining as varchar(100)

insert into #table2 (trainid,trainname,type_t)
(select Skill_ID,('SK_' + replace(skill_name,' ','')),1 from T0040_SKILL_MASTER WITH (NOLOCK) where Cmp_ID=@cmp_id)
insert into #table2 (trainid,trainname,type_t)
(select Training_id,('GM_' + replace(Training_name,' ','')),2 from T0040_Hrms_Training_master WITH (NOLOCK) where Cmp_ID=@cmp_id)

insert into #table3 (InitiateId,Emp_Id,Type_t,TrainingAreas)
(select distinct InitiateId,Emp_Id,[type],
SUBSTRING(
	( select (',' + TrainingAreas)
		from T0052_HRMS_AppTrainingDetail t2 WITH (NOLOCK)
		where t2.InitiateId = t1.InitiateId and  [type]='Function'
		order by InitiateId
		for xml path ( '' ) ),2,1000)
from  T0052_HRMS_AppTrainingDetail t1 WITH (NOLOCK)
where Cmp_ID=@cmp_id and [type]='Function')
insert into #table3 (InitiateId,Emp_Id,Type_t,TrainingAreas)
(select distinct InitiateId,Emp_Id,[type],
SUBSTRING(
	( select (',' + TrainingAreas)
		from T0052_HRMS_AppTrainingDetail t2 WITH (NOLOCK)
		where t2.InitiateId = t1.InitiateId and  [type]='Support'
		order by InitiateId
		for xml path ( '' ) ),2,1000)
from  T0052_HRMS_AppTrainingDetail t1 WITH (NOLOCK)
where Cmp_ID=@cmp_id and [type]='Support')


--(select InitiateId,Emp_Id,type,TrainingAreas from T0052_HRMS_AppTrainingDetail where cmp_id=@cmp_id)


declare cur2 cursor
for 
select trainid,trainname from #table2 where type_t = 1
	open cur2
		fetch next from cur2 into @col2,@col1
			while @@FETCH_STATUS = 0
			begin
				insert into #table1(Initiation_Id,Emp_Id,trainid,trainname,EmpCode,Emp_Full_Name,Department,branch,designation,branchid,Dept_ID,desigid,grd_id,catid,typeid) 
				(select t.InitiateId,t.Emp_Id,@col2,@col1,v.Alpha_Emp_Code,v.Emp_Full_Name,Dept_Name,b.branch_name,v.Desig_Name,v.Branch_ID,v.Dept_ID,v.Desig_Id,v.Grd_ID,v.Cat_ID,v.[Type_ID]  from   V0050_HRMS_InitiateAppraisal as v 
					left join T0052_HRMS_AppTraining as t WITH (NOLOCK) on t.InitiateId=v.InitiateId					  
					left join T0080_EMP_MASTER as em WITH (NOLOCK) on em.Emp_ID=v.Emp_Id
					left join T0095_INCREMENT as inc WITH (NOLOCK) on inc.Emp_ID = em.Emp_ID 
					left join T0030_BRANCH_MASTER as b WITH (NOLOCK) on b.Branch_ID=inc.Branch_ID
					--left join T0052_HRMS_AppTrainDetail as ap on ap.InitiateId = v.InitiateId
					where t.Recommended_ThisYear like '%'+ cast(@col2 as varchar) +'%' and t.Type='skill' and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=v.Emp_Id )
					and datepart(YYYY,v.SA_Startdate) = DATEPART(YYYY,@frmdate)) 
				fetch next from cur2 into @col2,@col1
			end
	close cur2
deallocate cur2


declare cur2 cursor
for 
select trainid,trainname from #table2 where type_t =2
	open cur2
		fetch next from cur2 into @col2,@col1
			while @@FETCH_STATUS = 0
			begin
				insert into #table1(Initiation_Id,Emp_Id,trainid,trainname,EmpCode,Emp_Full_Name,Department,branch,designation,branchid,Dept_ID,desigid,grd_id,catid,typeid) 
				(select t.InitiateId,t.Emp_Id,@col2,@col1,v.Alpha_Emp_Code,v.Emp_Full_Name,Dept_Name,b.branch_name,v.Desig_Name,v.Branch_ID,v.Dept_ID,v.Desig_Id,v.Grd_ID,v.Cat_ID,v.[Type_ID]  from   V0050_HRMS_InitiateAppraisal as v 
					left join T0052_HRMS_AppTraining as t WITH (NOLOCK) on t.InitiateId=v.InitiateId					  
					left join T0080_EMP_MASTER as em WITH (NOLOCK) on em.Emp_ID=v.Emp_Id
					left join T0095_INCREMENT as inc WITH (NOLOCK) on inc.Emp_ID = em.Emp_ID 
					left join T0030_BRANCH_MASTER as b WITH (NOLOCK) on b.Branch_ID=inc.Branch_ID
					where Recommended_ThisYear like '%'+ cast(@col2 as varchar) +'%' and t.Type='GM' and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=v.Emp_Id )
					and datepart(YYYY,v.SA_Startdate) = DATEPART(YYYY,@frmdate)) 	
				fetch next from cur2 into @col2,@col1
			end
	close cur2
deallocate cur2


declare cur2 cursor
for 
select InitiateId,Emp_Id,Type_t,TrainingAreas from #table3 
open cur2
		fetch next from cur2 into @InitiateId,@EmpId,@Type_t,@TrainingAreas
			while @@FETCH_STATUS = 0
			begin
				Update #table1 set Supportive = @TrainingAreas where Initiation_Id = @InitiateId and @Type_t = 'Support'
				Update #table1 set Functional = @TrainingAreas where Initiation_Id = @InitiateId and @Type_t = 'Function'
				fetch next from cur2 into @InitiateId,@EmpId,@Type_t,@TrainingAreas
			End
close cur2
deallocate cur2	

declare cur2 cursor
for 
select InitiateId,OtherTraining from T0052_HRMS_AppTrainDetail WITH (NOLOCK) where type ='Function'
open cur2
		fetch next from cur2 into @InitiateId,@OtherTraining
			while @@FETCH_STATUS = 0
			begin			
				Update #table1 set Anyother = @OtherTraining where Initiation_Id = @InitiateId 
				fetch next from cur2 into @InitiateId,@OtherTraining
			End
close cur2
deallocate cur2	

DECLARE @query VARCHAR(max)
DECLARE @columns nVARCHAR(max)


SELECT @columns = COALESCE(@columns + ',[' + cast(trainname as varchar) + ']',
			'[' + cast(trainname as varchar)+ ']')
			 FROM #table1
			GROUP BY trainname
			order by trainname desc			

			SET @query = 'SELECT  Branch,Department,EmpCode,Emp_Full_Name,designation,Supportive,Functional,Anyother,'+ @columns +',branchid,Dept_ID,desigid,grd_id,catid,typeid	
							FROM (
								SELECT 
									Initiation_Id ,trainname,Emp_Full_Name,EmpCode,Department,branch,designation,Supportive,Functional,Anyother,branchid,Dept_ID,desigid,grd_id,catid,typeid		
								FROM #table1
							)  as s 
							PIVOT
							(
								 count(Initiation_Id) 
								FOR [trainname] IN (' + @columns + ')
							)AS T'							
		
--set @query= 'select ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Department,Branch,empcode) AS Srno ,Branch,Department,EmpCode,Emp_Full_Name,designation,'+ @columns +',Supportive,Functional,Anyother from (' + @query + ') as tbl1 where empcode is not null  '
PRINT @dyQuery
if @dyQuery <> '' --added by Mukti(07112016)
		begin
			set @query= 'select ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Department,Branch,empcode) AS Srno ,EmpCode,Emp_Full_Name as ''Employee Name'',Branch,Department,designation as Designation,'+ @columns +',Supportive,Functional as ''Functional/Technical'',Anyother as ''Any Other'',branchid,Dept_ID,desigid,grd_id,catid,typeid from (' + @query + ') as tbl1 where empcode is not null  '
			print (@query +  @dyquery + ' ORDER BY Branch,Department') 
			exec (@query +  @dyquery + ' ORDER BY Branch,Department') 
		END
ELSE
		begin			
			set @query= 'select ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Department,Branch,empcode) AS Srno ,EmpCode,Emp_Full_Name as ''Employee Name'',Branch,Department,designation as Designation,'+ @columns +',Supportive,Functional as ''Functional/Technical'',Anyother as ''Any Other'',branchid,Dept_ID,desigid,grd_id,catid,typeid from (' + @query + ') as tbl1 where empcode is not null  '		
			exec (@query + ' ORDER BY Branch,Department')		
		END
		
--select * from #table2
--select * from #table1
--select * from #table3



drop table #table2
drop table #table3
drop table #table1

End

----------------------------------------------------------------------------------

--	 @cmp_id    as numeric(18,0)
--	,@deptId    as numeric(18,0)=null
--	,@emp_id    as numeric(18,0)=null
--	,@frmdate   as datetime 
--	,@enddate   as datetime = getdate
--	,@dyQuery   varchar(max)=''
--	,@type      as int
--AS
--BEGIN
	
	
	
--	declare @sno	   as numeric(18,0)	=null
--	declare @col1      as varchar(100)
--	declare @col2	   as numeric
	
----main
--create table #table1
--(
--	 trainid			varchar(100)
--	,trainname			varchar(100)	
--	,Initiation_Id		numeric(18,0)
--	,Emp_Id				numeric(18,0)
--	,EmpCode			varchar(100)
--	,Emp_Full_Name		varchar(100)
--	,Department			varchar(100)
--	,branch				varchar(100)
--	,designation		varchar(100)
--)
------training table in which skill or training master can be inserted
-- create table #table2
--(
--	 skillid numeric(18,0)
--	,skillname varchar(100)
--)

--if @type=1
--	begin 
--		insert into #table2 (skillid,skillname)
--		(select Skill_ID,skill_name from T0040_SKILL_MASTER where Cmp_ID=@cmp_id)
		
--		declare cur2 cursor
--		for 
--		select skillid,skillname from #table2
--			open cur2
--				fetch next from cur2 into @col2,@col1
--					while @@FETCH_STATUS = 0
--					begin
--						insert into #table1(Initiation_Id,Emp_Id,trainid,trainname,EmpCode,Emp_Full_Name,Department,branch,designation) 
--						(select t.InitiateId,t.Emp_Id,@col2,@col1,v.Alpha_Emp_Code,v.Emp_Full_Name,Dept_Name,b.branch_name,v.Desig_Name  from   V0050_HRMS_InitiateAppraisal as v 
--							left join T0052_HRMS_AppTraining as t on t.InitiateId=v.InitiateId					  
--							left join T0080_EMP_MASTER as em on em.Emp_ID=v.Emp_Id
--							left join T0095_INCREMENT as inc on inc.Emp_ID = em.Emp_ID 
--							left join T0030_BRANCH_MASTER as b on b.Branch_ID=inc.Branch_ID
--							where Recommended_ThisYear like '%'+ cast(@col2 as varchar) +'%' and t.Type='skill' and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=v.Emp_Id ))	
--						fetch next from cur2 into @col2,@col1
--					end
--			close cur2
--		deallocate cur2
--	End
--else if @type=2
--	begin
--		insert into #table2 (skillid,skillname)
--		(select Training_id,Training_name from T0040_Hrms_Training_master where Cmp_ID=@cmp_id)
		
--		declare cur2 cursor
--		for 
--		select skillid,skillname from #table2
--		open cur2
--		fetch next from cur2 into @col2,@col1
--			while @@FETCH_STATUS = 0
--			begin
--				insert into #table1(Initiation_Id,Emp_Id,trainid,trainname,EmpCode,Emp_Full_Name,Department,branch,designation) 
--				(select t.InitiateId,t.Emp_Id,@col2,@col1,v.Alpha_Emp_Code,v.Emp_Full_Name,Dept_Name,b.branch_name,v.Desig_Name  from   V0050_HRMS_InitiateAppraisal as v 
--					left join T0052_HRMS_AppTraining as t on t.InitiateId=v.InitiateId					  
--					left join T0080_EMP_MASTER as em on em.Emp_ID=v.Emp_Id
--					left join T0095_INCREMENT as inc on inc.Emp_ID = em.Emp_ID 
--					left join T0030_BRANCH_MASTER as b on b.Branch_ID=inc.Branch_ID
--					where Recommended_ThisYear like '%'+ cast(@col2 as varchar) +'%' and t.Type='GM' and inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID=v.Emp_Id ))	
--				fetch next from cur2 into @col2,@col1
--			end
--		close cur2
--		deallocate cur2
--	End
	
--DECLARE @query VARCHAR(max)
--DECLARE @columns VARCHAR(8000)

--SELECT @columns = COALESCE(@columns + ',[' + cast(trainname as varchar) + ']',
--			'[' + cast(trainname as varchar)+ ']')
--			 FROM #table1
--			GROUP BY trainname
--			order by trainname desc

--SET @query = 'SELECT  Branch,Department,EmpCode,Emp_Full_Name,designation,'+ @columns +' 
--							FROM (
--								SELECT 
--									Initiation_Id ,trainname,Emp_Full_Name,EmpCode,Department,branch,designation
--								FROM #table1 
--							)  as s 
--							PIVOT
--							(
--								 count(Initiation_Id) 
--								FOR [trainname] IN (' + @columns + ')
--							)AS T'



--set @query= 'select ROW_NUMBER() OVER (PARTITION BY Department ORDER BY Department,Branch,empcode) AS Srno ,Branch,Department,EmpCode,Emp_Full_Name,designation,'+ @columns +' from (' + @query + ') as tbl1 where empcode is not null  '
--exec (@query  + @dyQuery + ' ORDER BY Branch,Department')

--drop table  #table2
--drop table  #table1
--END

