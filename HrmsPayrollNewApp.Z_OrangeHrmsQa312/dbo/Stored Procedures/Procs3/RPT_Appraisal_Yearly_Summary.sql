


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	RPT_Appraisal_Yearly_Summary 9,0,'2015-04-01','2015-12-30',''
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Appraisal_Yearly_Summary]
	  @cmp_id    as numeric(18,0)
		,@emp_id    as numeric(18,0)
		,@frmdate   as datetime 
		,@enddate   as datetime 
		,@dyQuery   varchar(max)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
DECLARE @columns VARCHAR(8000)
DECLARE @query VARCHAR(max)
Declare @SQLCol VarChar(max)

--create table #TblYearly
--(   
--	 empid			numeric(18,0)
--    ,empcode         varchar(50)
--    ,empname        varchar(100)
--    ,Designation    varchar(100)
--    ,Grade			varchar(100)
--    ,Doj			date
--    ,dept           varchar(100)
--    ,branchname     varchar(100)
--    ,branchid      numeric(18,0)
--	,deptid			numeric(18,0)
--	,desigid			numeric(18,0)
--	,catid           numeric(18,0)
--	,typeid			numeric(18,0)
--	,grd_id       	numeric(18,0)
--	,appraisal_stdate datetime
--	,appraisal_endate datetime
--	,appraisal_score	numeric(18,0)
--	,apprisal_id	numeric(18,0)
--)

--insert into #TblYearly 
--select  HI.emp_id,Alpha_Emp_Code,Emp_Full_Name,Desig_Name,Grd_Name,Date_Of_Join,Dept_Name,Branch_Name,i.Branch_ID,i.Dept_ID,i.Desig_Id,i.Cat_ID,i.Type_ID,i.Grd_ID,HI.SA_Startdate,HI.SA_Enddate,HI.Overall_Score,hi.InitiateId
--from    T0050_HRMS_InitiateAppraisal HI inner join
--		T0080_EMP_MASTER E on E.Emp_ID = HI.Emp_Id inner join
--		T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and I.Increment_Effective_Date = (select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID = e.Emp_ID) left join
--		T0040_DEPARTMENT_MASTER D on d.Dept_Id = i.Dept_ID left join
--		T0040_DESIGNATION_MASTER DG on DG.Desig_ID = i.Desig_Id left join
--		T0040_GRADE_MASTER G on G.Grd_ID = i.Grd_ID left join 
--		T0030_BRANCH_MASTER B on b.Branch_ID = i.Branch_ID
--where   HI.Cmp_ID = @cmp_id and HI.SA_Startdate >= @frmdate and HI.SA_Enddate <= @enddate and HI.Overall_Status is not null
--order by InitiateId asc

--SELECT @columns = COALESCE(@columns + ',[' + cast(apprisal_id as varchar) + ']',
--			'[' + cast(apprisal_id as varchar)+ ']')
--			FROM #TblYearly 
--			GROUP BY apprisal_id
--			order by apprisal_id asc

create table #dyTable
(
	emp_id  numeric(18,0)
	,Employee_Code         varchar(50)
    ,Employee_Name        varchar(100)
    ,Doj			varchar(12)
)
create unique clustered index ix_dyTable on #dyTable(emp_id);

create table #dyTabletmp
(
	emp_id  numeric(18,0)
	,app_id  numeric(18,0)
	,cnt	int
)

declare @eid numeric(18,0)
declare @aid numeric(18,0)

declare @maxcnt as NUMERIC(18,0)

declare cur cursor
for 
	--select empid,apprisal_id from #TblYearly order by empid,apprisal_id asc
	select emp_id,InitiateId from T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK) where HI.Cmp_ID = @cmp_id and HI.SA_Startdate >= @frmdate and HI.SA_Enddate <= @enddate and HI.Overall_Status is not null and  HI.Overall_Status=5 order by emp_id,InitiateId asc
open cur
fetch next from cur into @eid,@aid
while @@FETCH_STATUS =0
	begin
		set @maxcnt = (select isnull(MAX(cnt),0)+1 from #dyTabletmp where  emp_id=@eid)		
		insert into #dyTabletmp
		values (@eid,@aid,@maxcnt)
		fetch next from cur into @eid,@aid
	end
close cur
deallocate cur

--select * from #dyTabletmp
--print convert(varchar(20), getdate(), 114);

declare @finalscore numeric(18,2) --06 Dec 2016
declare @avgscore numeric(18,2)--06 Dec 2016


declare @columnname as varchar(1000)
declare @i int
declare @iRwCnt int --rowcount
declare @sValue varchar(100)
declare @sValuet varchar(100)
declare @scnt  int
set @i = 0 --initialize
set @iRwCnt = @@ROWCOUNT
create clustered index idx_dyTabletmp on #dyTabletmp(emp_id,app_id,cnt) WITH FILLFACTOR = 100


while @iRwCnt > 0
	begin	
		select top 1 @sValue = emp_id,@sValuet =app_id,@scnt=cnt from #dyTabletmp --order by app_id desc	
		
		set @iRwCnt = @@ROWCOUNT 			
		if @iRwCnt > 0
			begin 
				if Not exists(select 1 from #dyTable where emp_id = @sValue)	
				begin
					IF Not EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'app1#dept' AND TABLE_NAME LIKE '#dyTable%')
					begin 
						alter table  #dyTable
						add  app1#dept  varchar(50)		
						alter table  #dyTable
						add  app1#desig  varchar(50)	
						alter table  #dyTable
						add  app1#RM  varchar(100)				
						alter table  #dyTable
						add  app1#stdate  varchar(12)
						alter table  #dyTable
						add  app1#enddate  varchar(12)
						alter table  #dyTable
						add  app1#score  numeric(18,2)
					End	
					insert into #dyTable (emp_id,Employee_Code,Employee_Name,Doj,app1#dept,app1#stdate,app1#enddate,app1#score,app1#desig,app1#RM)
						select @sValue,e.Alpha_Emp_Code,e.Emp_Full_Name,CONVERT(varchar(12),e.Date_Of_Join,103),Dept_Name,CONVERT(varchar(12), HI.SA_Startdate,103),CONVERT(varchar(12), HI.SA_Enddate,103),Hi.Overall_Score,dg.Desig_Name,(ERM.alpha_emp_code +'-'+ ERM.Emp_Full_Name) 
						from   T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK) inner join
								T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = HI.Emp_Id inner join
								 (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
										FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
												(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
												 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
														(
																SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
																FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
														) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
												 WHERE CMP_ID = @cmp_id
												 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
										where I.Cmp_ID= @cmp_id 
								)IE on IE.Emp_ID = E.Emp_ID LEFT JOIN
								--T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and I.Increment_Effective_Date = (select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID = e.Emp_ID and Increment_Effective_Date <= Hi.SA_Startdate) left join
								T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = IE.Dept_ID left join
								T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id left join
								T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = IE.Grd_ID left join 
								T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = IE.Branch_ID left join
								T0090_EMP_REPORTING_DETAIL RM WITH (NOLOCK) on RM.Emp_ID = E.Emp_ID and RM.Effect_Date = (select MAX(Effect_Date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID=e.Emp_ID ) and Effect_Date <= Hi.SA_Startdate left join
								T0080_EMP_MASTER ERM WITH (NOLOCK) on ERM.Emp_ID = RM.R_Emp_ID 
						Where HI.Emp_Id = @sValue and hi.InitiateId =@sValuet 
					--select * from #dyTable
				end
				else
					begin 
						
						--select  @i = COUNT(*) from #dyTable where emp_id = @sValue
						set @i = @scnt
						set @columnname = 'app'+ cast(@i as varchar) +'#dept'	
						
						IF Not EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @columnname AND TABLE_NAME LIKE '#dyTable%')		
							begin
								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] VARCHAR(50)'
								exec (@SQLCol)
								
								set @columnname = 'app'+ cast(@i as varchar) +'#desig'	
								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] VARCHAR(50)'
								exec (@SQLCol)
							
								set @columnname = 'app'+ cast(@i as varchar) +'#RM'	
								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] VARCHAR(100)'
								exec (@SQLCol)
								
								set @columnname = 'app'+ cast(@i as varchar) +'#stdate'	
								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] varchar(12)'
								exec (@SQLCol)
								
								set @columnname = 'app'+ cast(@i as varchar) +'#enddate'	
								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] varchar(12)'
								exec (@SQLCol)
								
								set @columnname = 'app'+ cast(@i as varchar) +'#score'	
								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] numeric(18,2)'
								exec (@SQLCol)
							end
							
							set @SQLCol =''
							set @SQLCol = ' update #dyTable
											set app'+ cast(@i as varchar) + '#dept = up.Dept_Name,
												app'+ cast(@i as varchar) + '#stdate = CONVERT(varchar(12), up.SA_Startdate,103),
												app'+ cast(@i as varchar) + '#enddate = CONVERT(varchar(12), up.SA_Enddate,103),
												app'+ cast(@i as varchar) + '#score = up.Overall_Score,
												app'+ cast(@i as varchar) + '#desig = up.Desig_Name,
												app'+ cast(@i as varchar) + '#RM = up.Emp_Full_Name												
											From (select Dept_Name,HI.SA_Startdate,hi.SA_Enddate,Hi.Overall_Score,dg.Desig_Name,(ERM.alpha_emp_code +''-''+ ERM.Emp_Full_Name)Emp_Full_Name
												  From T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK) inner join
												       T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = HI.Emp_Id inner join
												        (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
															FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
																	(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
																	 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
																			(
																					SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
																					FROM T0095_INCREMENT WHERE CMP_ID = '+ cast(@cmp_id as varchar) +' GROUP BY EMP_ID
																			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
																	 WHERE CMP_ID = '+ cast(@cmp_id as varchar) +'
																	 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
															where I.Cmp_ID= '+ cast(@cmp_id as varchar) +'
													)IE on IE.Emp_ID = E.Emp_ID LEFT JOIN
												       T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = IE.Dept_ID left join
												       T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id left join
												       T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = IE.Grd_ID left join
												       T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = IE.Branch_ID left join
													   T0090_EMP_REPORTING_DETAIL RM WITH (NOLOCK) on RM.Emp_ID = E.Emp_ID and RM.Effect_Date = (select MAX(Effect_Date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID=e.Emp_ID ) and Effect_Date <= Hi.SA_Startdate left join
													   T0080_EMP_MASTER ERM WITH (NOLOCK) on ERM.Emp_ID = RM.R_Emp_ID 
												    Where HI.Emp_Id ='+ @sValue +'and hi.InitiateId =' + @sValuet + ')up
											Where emp_id =' + @sValue 
											
							exec (@SQLCol)							
						set @i=0						
						set @columnname =''
					end
				delete from #dyTabletmp where app_id = @sValuet			
			end
	end

-----06 Dec 2016
IF Not EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Finalscore' AND TABLE_NAME LIKE '#dyTable%')
	BEGIN
		ALTER TABLE  #dyTable
		ADD  Finalscore  NUMERIC(18,2)
		,  AverageScore NUMERIC(18,2)
	END
	
update #dyTable
set #dyTable.Finalscore =k.Overall_Score,#dyTable.AverageScore =(Overall_Score/k.cnt)
from
	(select sum(HI.Overall_Score)Overall_Score,count(*)cnt,emp_id 
	from T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK)
	where HI.Cmp_ID = @cmp_id and HI.SA_Startdate >= @frmdate and 
	HI.SA_Enddate <= @enddate and HI.Overall_Status is not null and 
	 HI.Overall_Status=5 
	 GROUP by HI.Emp_Id)k
Where #dyTable.emp_id = k.Emp_Id
----------------------------------

set @query = 'select * from #dyTable'
if @dyQuery =''
	exec (@query)
Else
	exec (@query + ' where ' + @dyQuery)


--drop table #TblYearly
drop table #dyTable
drop table #dyTabletmp
--print convert(varchar(20), getdate(), 114);	
	
END

