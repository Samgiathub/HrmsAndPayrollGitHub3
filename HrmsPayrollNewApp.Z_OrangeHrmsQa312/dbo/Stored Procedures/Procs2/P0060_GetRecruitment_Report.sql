
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_GetRecruitment_Report]
	 @rec_post_id as numeric(18,0)
	,@cmp_id as numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @rec_post_id =0
	begin
		set @rec_post_id = null
	end



----------------------------1st table
CREATE TABLE #table1
(
	 Rec_post_id		numeric(18,0)	
	,Rec_Post_Code      varchar(100) 
	,Job_Title			varchar(100)
	,Login_id           numeric(18,0)
	,systemdate         datetime
	,Location           varchar(100)
	,requestby			varchar(50)
)

insert into #table1
(	
	 Rec_post_id
	,Rec_Post_Code 			
	,Job_Title			
	,Login_id 
	,systemdate        
	,Location          
	,requestby			
)
(
	select 
	p.Rec_Post_Id,	
	P.Rec_Post_Code,
	p.Job_title,
	h.Login_id,
	h.System_Date,
	CASE WHEN p.Location IS NOT NULL THEN
	  (SELECT     BM.Branch_Name + ','
		FROM          T0030_BRANCH_MASTER BM WITH (NOLOCK) 
		WHERE      BM.Branch_ID IN
								   (SELECT     cast(data AS numeric(18, 0))
									 FROM          dbo.Split(ISNULL(P.Location, '0'), '#')
									 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END,
	isnull(e.Emp_Full_Name,'Admin') as Emp_Full_Name
	from 
	T0052_HRMS_Posted_Recruitment as p WITH (NOLOCK) left join	
	T0050_HRMS_Recruitment_Request as h WITH (NOLOCK) on h.Rec_Req_ID = p.Rec_Req_ID left join 
	T0011_LOGIN as L WITH (NOLOCK) on L.Login_ID=h.Login_ID left join
	T0080_EMP_MASTER as e WITH (NOLOCK) on e.Emp_ID = L.Emp_ID 
	where p.Cmp_id=@cmp_id and p.Rec_Post_Id =isnull(@rec_post_id,Rec_Post_Id)
)

--select * from #table1
---------------------------------------------------------
----------------table 2
CREATE TABLE #table2
(
	 rec_post_id     numeric(18,0)
	,Resume_Id       numeric(18,0)
	,ResumeCode      varchar(50)
	,ApplicantName   varchar(100)
	,Mobile_No       varchar(50)
)

insert into #table2
(
	 rec_post_id     
	,Resume_Id 
	,ResumeCode      
	,ApplicantName   
	,Mobile_No      
)
(
	select r.Rec_Post_Id,r.Resume_Id,r.Resume_Code,r.Emp_First_Name +' '+ r.Emp_Last_Name as applicantname,r.Mobile_No
	from   T0055_Resume_Master as r WITH (NOLOCK) left join
		   T0052_HRMS_Posted_Recruitment as p WITH (NOLOCK) on p.Rec_Post_Id=r.Rec_Post_Id
	Where   r.Rec_Post_Id = isnull(@rec_post_id,r.Rec_Post_Id) --r.Cmp_id=@cmp_id and

)
--select * from #table2
-------------------------------------
-------------------------table 3

CREATE TABLE #table3
(	
	rec_post_id     numeric(18,0)
	 ,Resume_Id       numeric(18,0)
	,ResumeCode      varchar(50)
	,ApplicantName   varchar(100)
	,interviewdate   datetime
)
insert into #table3
(
	rec_post_id  
	,Resume_Id       
	,ResumeCode      
	,ApplicantName   
	,interviewdate 
)
(
	 select r.Rec_Post_Id,r.Resume_Id,Resume_Code,(Emp_First_Name+' '+Emp_Last_Name)as emp_full_name
		,(select min(From_Date) from T0055_HRMS_Interview_Schedule as i WITH (NOLOCK) where i.Resume_Id=r.Resume_Id) as interview_date
    from T0055_Resume_Master as r WITH (NOLOCK) 
    where   r.Cmp_id=@cmp_id and Resume_Status <> 0 and r.Rec_Post_Id=isnull(@rec_post_id,Rec_Post_Id)
)

 --select * from #table3
--------------------------------------
-------------------------------- table 5
CREATE TABLE #table51
(
	 recpostid    numeric(18,0)
	,resumeid     numeric(18,0)
	,resumecode   varchar(50)
	,resumename   varchar(100)
	,reason       varchar(500)
) 

insert into #table51
(
	recpostid    
	,resumeid     
	,resumecode   
	,resumename
	,reason   
)
(
	select v.Rec_Post_Id,v.Resume_Id,r.Resume_Code,r.Emp_First_Name+' '+r.Emp_Last_Name as resumename,v.Comments from v0055_HRMS_Interview_Schedule as v
	left join T0055_Resume_Master as r WITH (NOLOCK)  on r.Resume_Id=v.Resume_Id 
	where v.Cmp_Id=@cmp_id and v.Rec_Post_Id=isnull(@rec_post_id,v.Rec_Post_Id) and v.Status = 2
)


CREATE TABLE #table52
(
	  recpostid    numeric(18,0)
	,resumeid     numeric(18,0)
	,resumecode   varchar(50)
	,resumename   varchar(100)
	,reason       varchar(500)
) 

insert into #table52
(
	recpostid    
	,resumeid     
	,resumecode   
	,resumename
	,reason  
)
(
	select v.Rec_Post_Id,v.Resume_Id,r.Resume_Code,r.Emp_First_Name+' '+r.Emp_Last_Name as resumename,v.Comments from v0055_HRMS_Interview_Schedule as v
	left join T0055_Resume_Master as r WITH (NOLOCK) on r.Resume_Id=v.Resume_Id 
	where v.Cmp_Id=@cmp_id and v.Rec_Post_Id=isnull(@rec_post_id,v.Rec_Post_Id) and v.Status = 3
)


CREATE TABLE #table5
(
	  recpostid    numeric(18,0)
	,resumeid     numeric(18,0)
	,resumecode   varchar(50)
	,resumename   varchar(100)
	,reason       varchar(500)
) 
insert into #table5
(
	recpostid    
	,resumeid     
	,resumecode   
	,resumename
	,reason  
)
(
select * from #table51 union all
select * from #table52
)

--select * from #table5

--------------------------------------
-----------------------table 6

CREATE TABLE #table6
(
	  recpostid    numeric(18,0)
	,resumeid     numeric(18,0)
	,resumecode   varchar(50)
	,resumename   varchar(100)
	,Joiningdate      datetime
) 
insert into #table6
(
	recpostid    
	,resumeid     
	,resumecode   
	,resumename
	,Joiningdate  
)
(
	select f.Rec_post_Id,f.Resume_ID,r.Resume_Code,r.Emp_First_Name+' '+r.Emp_Last_Name as resumename,f.Joining_date from T0060_RESUME_FINAL as f WITH (NOLOCK)
	left join T0055_Resume_Master as r WITH (NOLOCK) on r.Resume_Id=f.Resume_ID and r.Rec_Post_Id=f.Rec_post_Id
	where f.Cmp_ID=@cmp_id and f.Rec_post_Id=isnull(@rec_post_id,f.Rec_post_Id) 
)

--select * from #table6
--------------------------------------
------------------ table 4
CREATE TABLE #table4  
(
	recpostid numeric(18,0),
	resumeid numeric(18,0),
	resumename  varchar(50),
	process  varchar(100)
)

insert into #table4 (recpostid,resumeid,resumename,process) 
(select s.Rec_Post_Id,s.Resume_Id,(r.Resume_Code+'-'+r.Emp_First_Name+' '+r.Emp_Last_Name) as resumename,Replace(Replace(Replace(i.Process_Name,' ','_'),')','_'),'__','_') 
from T0055_HRMS_Interview_Schedule as s WITH (NOLOCK) left join 
T0055_Interview_Process_Detail as p WITH (NOLOCK) on p.Interview_Process_detail_ID = s.Interview_Process_Detail_Id left join
t0040_hrms_r_process_master  as i WITH (NOLOCK) on i.Process_ID=p.Process_ID left join 
T0055_Resume_Master as r WITH (NOLOCK) on r.Resume_Id = s.Resume_Id
where s.Cmp_id=@cmp_id )

--select 111,* from #table4


DECLARE @columns VARCHAR(8000)
SELECT @columns = COALESCE(@columns + ',[' + cast(process as varchar) + ']',
'[' + cast(process as varchar)+ ']')
FROM #table4
GROUP BY process

if @columns IS NOT NULL
	EXEC('select * INTO ##temptable from 
    (select * from #table4)T
    PIVOT(max(resumename) for [process] in ('+@columns+')) p ')
   
--print @query
--------------------------------------

---------------------------------final table
CREATE TABLE #finaltable
(	
	 Rec_post_id		numeric(18,0)	
	,Login_id           numeric(18,0)
	,Resume_Id       numeric(18,0),
	Man_Power_Requested_For		varchar(100)	
	,Location           varchar(100)
	,Date_of_MPR         datetime	
	,Requestors_Name	varchar(100)
	,Application_Received varchar(150)	
	,Contact_No			varchar(50)
	,Shortlisted		varchar(150)	
	,Interview_Date		datetime
	,Rejected			varchar(150)	
	,On_Hold			varchar(150)	
	,Reason             varchar(500)
	,Selected			varchar(150)
	,Joining_Date       datetime
	
)

insert into #finaltable
(
	Rec_post_id		
	,Login_id           
	,Resume_Id ,      
	Man_Power_Requested_For		
	,Location           
	,Date_of_MPR         
	,Requestors_Name	
	,Application_Received 
	,Contact_No		
	,Shortlisted		
	,Interview_Date		
	,Rejected			
	,On_Hold			
	,Reason            
	,Selected			
	,Joining_Date     
)
(
select   
	t1.Rec_post_id
			,t1.Login_id
			,t2.Resume_Id ,
			t1.Rec_Post_Code +'-'+t1.Job_Title 
			,t1.Location   			
			,t1.systemdate  
			,t1.requestby
			,t2.ResumeCode  +'-'+t2.ApplicantName 
			,t2.Mobile_No  
			,t3.ResumeCode +'-'+t3.ApplicantName
			,t3.interviewdate
			,t51.resumecode +'-'+ t51.resumename			
			,t52.resumecode +'-'+t52.resumename
			,t5.reason
			,t6.resumecode +''+t6.resumename
			,t6.Joiningdate
	from #table1 as t1 left join
	#table2 as t2 on t2.rec_post_id = t1.Rec_post_id left join
	#table3 as t3 on t3.rec_post_id = t1.Rec_post_id and t3.Resume_Id = t2.Resume_Id left join
	#table5 as t5 on t5.recpostid   = t1.Rec_post_id and t5.resumeid = t2.Resume_Id  left join
	#table51 as t51 on t51.recpostid = t1.Rec_post_id and t51.resumeid = t2.Resume_Id left join
	#table52 as t52 on t52.recpostid = t1.Rec_post_id and t52.resumeid = t2.Resume_Id left join
	#table6  as t6 on t6.recpostid = t1.Rec_post_id and t6.resumeid = t2.Resume_Id 
)
------------------------------
-----============ cursor to get columns ====================
DECLARE @DynamicSQL nvarchar(500)
Declare @DynemicColumnName as varchar(max)
set @DynemicColumnName = ''	

if @columns IS NOT NULL
BEGIN
declare @col as varchar(100)
DECLARE @ColName nvarchar(100)
declare cur cursor
for 
select name  from tempdb.sys.columns  where object_id =
object_id('tempdb..##temptable') and column_id>2
open cur


Fetch Next From cur into @col
	--Print @col
	WHILE @@FETCH_STATUS = 0
		begin
			begin			
			SET @ColName=@col
			--SET @DynamicSQL = 'CREATE TABLE #finaltable ADD ['+ CAST(Replace(Replace(Replace(@ColName,' ','_'),')','_'),'__','_') AS NVARCHAR(100)) +'] NVARCHAR(100) NULL'			
			--changed By Mukti 24122014(start)
			 SET @DynamicSQL = 'Alter table #finaltable ADD ['+ CAST(Replace(Replace(Replace(@ColName,' ','_'),')','_'),'__','_') AS NVARCHAR(100)) +'] NVARCHAR(100) NULL'			
			--changed By Mukti 24122014(end)
			exec sp_executesql @DynamicSQL			
			Fetch Next From cur into @col
			--print @DynamicSQL	
			--print @ColName
		End 
		End 
	Close cur	
	Deallocate cur

	
-----============ cursor ends to get columns ====================
-----============ cursor to update columns ====================
declare @coln as varchar(max)
DECLARE @Colfinal nvarchar(max) 
declare @tempcol varchar(100)
DECLARE @values nvarchar(max)
DECLARE @SQL NVARCHAR(max)
DECLARE @SQL1 VARCHAR(max)
DECLARE @value nvarchar(max)

Declare @RecpostId as numeric
Declare @resumeid as numeric


	SET @Colfinal = ''
	
declare curname cursor
for 
	select name  from tempdb.sys.columns  where object_id =
	object_id('tempdb..##temptable') and column_id>2
	
open curname
Fetch Next From curname into @coln

WHILE @@FETCH_STATUS = 0
	begin
	
			If @DynemicColumnName = ''
				Set @DynemicColumnName = '[' + cast(replace(Replace(Replace(@coln,' ','_'),')','_'),'__','_')as varchar(100)) + ']'
			Else
				Set @DynemicColumnName = @DynemicColumnName + ',[' + cast(replace(Replace(Replace(@coln,' ','_'),')','_'),'__','_')as varchar(100))+ ']'

		If exists(select 1 from tempdb.sys.tables where name like '##table11')
			Drop Table ##table11		
		
		
		Set @SQL = 'Select Recpostid,resumeid, [' + cast(replace(Replace(Replace(@coln,' ','_'),')','_'),'__','_') as varchar(100)) + '] Into ##table11 From ##temptable where not [' + @ColN + '] is null'
		
		exec (@SQL)
		
		declare curname1 cursor for 
			select * from ##table11
		open curname1
		Fetch Next From curname1 into @RecpostId,@resumeid,@value
		WHILE @@FETCH_STATUS = 0
			begin
				Set @SQL1 = ' Update #finaltable Set [' + Replace(Replace(Replace(@coln,' ','_'),')','_'),'__','_') + '] = ''' + @value + ''' Where Rec_post_id = ' + cast(@RecpostId as varchar(100)) + ' And Resume_Id = ' + cast(@resumeid as varchar(100))
				Exec (@sql1)


			Fetch Next From curname1 into  @RecpostId,@resumeid,@value
	End		
Close curname1
Deallocate curname1


			Fetch Next From curname into @coln
	End		
Close curname	
Deallocate curname      

END

-----============ cursor ends to update columns ====================
declare @t as varchar(8000)
	IF @columns IS NOT NULL
		BEGIN
			set @t = '	
					Select 
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  Man_Power_Requested_For
					Else '''' End ''Man Power Requested For'',	
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  cast(Location AS varchar(100))
					Else '''' End ''Location'',			
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  cast( Date_of_MPR AS varchar(12))
					Else '''' End ''Date of MPR'',					        
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  cast( Requestors_Name AS varchar(100))
					Else '''' End ''Requestors Name'',		
					 Application_Received as ''Application Received''
					,Contact_No as ''Contact No''
					,Shortlisted  
					,cast(Interview_Date as varchar(12)) as ''Interview Date''
					,' + @DynemicColumnName + '
					,Rejected 
					,On_Hold as ''On Hold''
					,reason  
					,Selected
					,cast(Joining_Date as varchar(12)) as ''Joining Date''
			from #finaltable'
		END
ELSE
	BEGIN
		set @t = '	
					Select 
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  Man_Power_Requested_For
					Else '''' End ''Man Power Requested For'',	
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  cast(Location AS varchar(100))
					Else '''' End ''Location'',			
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  cast( Date_of_MPR AS varchar(12))
					Else '''' End ''Date of MPR'',					        
					Case When row_number() OVER ( PARTITION BY Rec_post_id order by Rec_post_id) = 1
					Then  cast( Requestors_Name AS varchar(100))
					Else '''' End ''Requestors Name'',		
					 Application_Received as ''Application Received''
					,Contact_No as ''Contact No''
					,Shortlisted  
					,cast(Interview_Date as varchar(12)) as ''Interview Date''
					,Rejected 
					,On_Hold as ''On Hold''
					,reason  
					,Selected
					,cast(Joining_Date as varchar(12)) as ''Joining Date''
			from #finaltable'
	END
print @t
exec (@t)
--select * from #finaltable
--select  name  from tempdb.sys.columns  where object_id =
--	object_id('tempdb..#finaltable') and column_id>2

drop table #table1
drop table #table2
drop table #table3
drop table #table4
drop table #table5
drop table #table51
drop table #table52
drop table #table6
drop table #finaltable
If exists(select 1 from tempdb.sys.tables where name like '##table11')
	drop table ##table11
If exists(select 1 from tempdb.sys.tables where name like '##temptable')
	drop table ##temptable

END
