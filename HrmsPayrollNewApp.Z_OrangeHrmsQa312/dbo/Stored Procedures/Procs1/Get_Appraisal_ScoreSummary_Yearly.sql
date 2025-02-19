---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Get_Appraisal_ScoreSummary_Yearly]
	  @cmp_id as numeric(18,0)=0
	 ,@fin_year as int
	 ,@emp_id as int = 0
	 ,@init_date datetime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	BEGIN
		
	CREATE TABLE #Final_Table
	(
		 Financial_Year INT
		,Emp_Id			NUMERIC(18,0)
		,Alpha_Emp_Code VARCHAR(50)
		,Emp_Full_Name	VARCHAR(100)
		,Total_Score	NUMERIC(18,2)
		,Average_Score	NUMERIC(18,2)
		,Achievement	VARCHAR(100)		
	)	
	
	CREATE TABLE #Final_Table1
	(
		 InitiateId INT
		,Emp_Id			NUMERIC(18,0)
		,Alpha_Emp_Code VARCHAR(50)
		,Emp_Full_Name	VARCHAR(100)
		,Final_Evaluation VARCHAR(15)
		,SA_Startdate   VARCHAR(15)
		,SA_Enddate		VARCHAR(15)
		,Duration		varchar(20)
		,KPA_Final		NUMERIC(18,2)
		,PF_Final		NUMERIC(18,2)
		,PO_Final		NUMERIC(18,2)
		,Overall_Score  VARCHAR(15)
		,Achivement_Id	NUMERIC(18,0)
		,Range_Level	VARCHAR(100)		
	)
	
	DECLARE @deptid  NUMERIC(18,0)
    DECLARE @grad_Id  NUMERIC(18,0)
	
	IF @emp_id <>0	
		BEGIN
			DECLARE @overall_score NUMERIC(18,2)
			DECLARE @cnt INT
			DECLARE @avg_score NUMERIC(18,2)
			DECLARE @range_id NUMERIC(18,0)	
		
			INSERT into #Final_Table1(InitiateId,Emp_Id,Final_Evaluation,SA_Startdate,SA_Enddate,Duration,KPA_Final,PF_Final,PO_Final,Overall_Score,Achivement_Id,Range_Level)
			SELECT InitiateId,Emp_Id,CASE WHEN Final_Evaluation =0 THEN 'Interim' ELSE 'Final' END Final_Evaluation,CONVERT(varchar,SA_Startdate,103),CONVERT(varchar,SA_Enddate,103),
				  (dbo.F_GET_MONTH_NAME(Duration_FromMonth) +' - '+ dbo.F_GET_MONTH_NAME(Duration_ToMonth))Duration,KPA_Final,PF_Final,PO_Final,Overall_Score,Achivement_Id,
				  rm.Range_Level
			FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) inner JOIN
			T0040_HRMS_RangeMaster RM WITH (NOLOCK) inner JOIN
				(
					SELECT max(Effective_Date)Effective_Date,Range_ID
					FROM T0040_HRMS_RangeMaster WITH (NOLOCK)
					WHERE Cmp_ID=@cmp_id  and Range_Type=2
					GROUP by Range_ID
				)RM1 on RM1.Range_ID = RM.Range_ID 
			 ON rm.Range_ID = Achivement_Id and RM.Effective_Date <= SA_Startdate
			 WHERE Emp_Id=@emp_id and Financial_Year =@fin_year and Range_Type=2
			 
			 
			SELECT @deptid= I.Dept_ID,@grad_Id=I.Grd_ID
			FROM   T0095_INCREMENT I WITH (NOLOCK)
			INNER JOIN (
							SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK)
							INNER JOIN (
											SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
											FROM T0095_INCREMENT WITH (NOLOCK)
											WHERE Increment_Effective_Date <= @init_date
											GROUP BY Emp_ID
									)I3 ON I3.Emp_ID = T0095_INCREMENT.Emp_ID
							GROUP BY T0095_INCREMENT.Emp_ID 
					)I2	ON I.Emp_ID = I2.Emp_ID AND I2.Increment_ID = I.Increment_ID
			WHERE I.Emp_ID = @emp_id						
		END
		
		
		SELECT @overall_score= sum(Overall_Score) 
		FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
		WHERE Emp_Id=@emp_id and Financial_Year =@fin_year

		SELECT @cnt = count (*)
		FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
		WHERE Emp_Id=@emp_id and Financial_Year =@fin_year
		
		SET @avg_score = @overall_score/@cnt
		
		
		INSERT into #Final_Table
		SELECT @fin_year,@emp_id,E.Alpha_Emp_Code,E.Emp_Full_Name,@overall_score,@avg_score,Range_Level  
		FROM T0040_HRMS_RangeMaster RM WITH (NOLOCK) inner JOIN
			(
				select max(Effective_Date)Effective_Date--,Range_ID
				from T0040_HRMS_RangeMaster WITH (NOLOCK)
				where Cmp_ID=@cmp_id  and Range_Type=2
					and Effective_Date <= @init_date
				--GROUP by Range_ID
			)RM1 ON RM1.Effective_Date = RM.Effective_Date --RM1.Range_ID = RM.Range_ID
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = @emp_id
		WHERE Range_Type = 2 and RM.Range_From <= @avg_score and rm.Range_To>=@avg_score
		AND CAST(@deptid AS VARCHAR) IN (SELECT Data FROM dbo.Split(Range_Dept,'#'))
		AND CAST(@grad_Id AS VARCHAR) IN (SELECT Data FROM dbo.Split(Range_Grade,'#'))
		--AND CAST(@deptid AS VARCHAR) IN (
		--							REPLACE(LEFT(RIGHT(RM.Range_Dept,LEN(RM.Range_Dept)-1),len(RIGHT(RM.Range_Dept,LEN(RM.Range_Dept)-1))-1),'#',',')
		--							)
		--AND CAST(@grad_Id AS VARCHAR) IN (
		--							REPLACE(LEFT(RIGHT(RM.Range_Grade,LEN(RM.Range_Grade)-1),len(RIGHT(RM.Range_Grade,LEN(RM.Range_Grade)-1))-1),'#',',')
		--						)
		
		
		INSERT into #Final_Table1(InitiateId,Emp_Id,Final_Evaluation,SA_Startdate,SA_Enddate,Duration,KPA_Final,PF_Final,PO_Final,Overall_Score,Achivement_Id,Range_Level)
		SELECT  0,@emp_id,'Total Score', Total_Score,'Average Score',Average_Score,0,0,0,'Achieved',0,Achievement
		from 
		#Final_Table
		
		SELECT 				
				 InitiateId 
				,Emp_Id		
				,Alpha_Emp_Code
				,Emp_Full_Name	
				, case when Final_Evaluation='Interim' then  Final_Evaluation + '-' + cast(ROW_NUMBER() OVER (PARTITION BY Final_Evaluation order by Emp_Id) as VARCHAR) else Final_Evaluation end Final_Evaluation
				,SA_Startdate  
				,SA_Enddate		
				,Duration		
				,KPA_Final		
				,PF_Final		
				,PO_Final		
				,Overall_Score 
				,Achivement_Id	
				,Range_Level 
		FROM  #Final_Table1 
		
		
		DROP TABLE #Final_Table
		DROP TABLE #Final_Table1
	END
-------------------------------------commented on 1 Dec 2016---------------
--ALTER PROCEDURE [dbo].[Get_Appraisal_ScoreSummary_Yearly]
--	 @emp_id as numeric(18,0)=0
--	 ,@year as int
--	 ,@cmp_id as numeric(18,0)
--	 ,@dept as numeric(18,0)=null--added on 18 feb 2016
--AS
--BEGIN
--	SET NOCOUNT ON;
--	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--	SET ARITHABORT ON;

--   create table #dyTable
--(
--	emp_id  numeric(18,0)
--	,Employee_Code         varchar(50)
--    ,Employee_Name        varchar(100)
--    ,dept				  varchar(100)   
	
--)

--create table #dyTabletmp
--(
--	emp_id  numeric(18,0)
--	,app_id  numeric(18,0)
--	--,cnt	int
--) 

--declare @eid as numeric(18,0)
--declare @appid as numeric(18,0)
--declare @cnt  as int
--set @cnt = 1
--declare @eacnt  as int
--set @eacnt = 0
--declare @columnname as varchar(1000)
--DECLARE @query VARCHAR(max)
--Declare @SQLCol VarChar(max)


--declare @KPATotal as numeric(18,2)
--declare @EATotal as numeric(18,2)
--declare @KPATotaltmp as numeric(18,2)
--declare @EATotaltmp as numeric(18,2)

--set @KPATotal = 0
--set @EATotal =0
--set @KPATotaltmp = 0
--set @EATotaltmp =0

--declare @kpaweight as numeric(18,2)
--declare @EAweight as numeric(18,2)
--declare @kpaweight_tmp as numeric(18,2)
--declare @EAweight_tmp as numeric(18,2)
--declare @finalTotal as numeric(18,2)
--set @finalTotal =0
--set @kpaweight_tmp =0
--set @EAweight_tmp =0
--declare @tmpemp as numeric(18,0)--added on 18 feb 2016
--set @tmpemp =0--added on 18 feb 2016

--if @emp_Id <> 0
--	begin
--		insert into #dyTabletmp
--		select emp_id,InitiateId
--		--(select isnull(MAX(cnt),0)+1 from #dyTabletmp where  emp_id=@emp_id) 
--		from T0050_HRMS_InitiateAppraisal HI
--		where HI.Cmp_ID = @cmp_id and emp_id = @emp_id and datepart(YYYY,SA_Startdate)=@year order by InitiateId asc
--	END
--ELSE
--	BEGIN
--		insert into #dyTabletmp
--		select emp_id,InitiateId
--		--(select isnull(MAX(cnt),0)+1 from #dyTabletmp where  emp_id=@emp_id) 
--		from T0050_HRMS_InitiateAppraisal HI
--		where HI.Cmp_ID = @cmp_id  and datepart(YYYY,SA_Startdate)=@year order by emp_id,InitiateId asc
--	END

	
--declare cur cursor
--for
--	select emp_id,app_id from #dyTabletmp
--open cur
--	fetch next from cur into @eid,@appid
--	while @@FETCH_STATUS =0
--		Begin
--				set @SQLCol =''
--				if Not exists(select 1 from #dyTable where emp_id = @eid)
--					BEGIN
--						IF Not EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Appraisal1#KPAScore' AND TABLE_NAME LIKE '#dyTable%')
--							BEGIN
--								alter table  #dyTable
--								add  Appraisal1#KPAScore  numeric(18,2)
								
--								if exists(select 1 from T0052_Emp_SelfAppraisal where InitiateId = @appid)
--									BEGIN
--										alter table  #dyTable
--										add  Appraisal1#EAScore  numeric(18,2)
--										set @eacnt =@eacnt+1										
--									END
--							END
--						insert into #dyTable(emp_id,Employee_Name,Employee_Code,dept,Appraisal1#KPAScore)
--						select hi.Emp_Id,e.Emp_Full_Name,e.Alpha_Emp_Code,D.Dept_Name,(isnull(hi.KPA_Final,0)+isnull(hi.PF_Final,0)+isnull(hi.PO_Final,0))
--						from  T0050_HRMS_InitiateAppraisal HI inner JOIN
--							  T0080_EMP_MASTER E on e.Emp_ID = hi.Emp_Id inner JOIN
--							  T0095_INCREMENT I on i.Emp_ID = e.Emp_ID and i.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id = @eid) left JOIN
--							  T0040_DEPARTMENT_MASTER D on d.Dept_Id = i.Dept_ID 
--						where HI.emp_id = @eid and HI.InitiateId=@appid and d.Dept_Id=(isnull(@dept,d.Dept_Id))
						
--						IF  EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Appraisal1#EAScore' AND TABLE_NAME LIKE '#dyTable%')
--							BEGIN 
--								set @SQLCol = 'Update #dyTable
--								set Appraisal1#EAScore = EA.Weightage
--								From ( select sum(Weightage)  Weightage
--										from T0052_Emp_SelfAppraisal where emp_id =' + cast(@eid as varchar(18))  +' and InitiateId =' + cast(@appid as varchar(18)) +' )EA
--								WHERE emp_id =' + cast(@eid as varchar(18)) 	
--								exec (@SQLCol)							
								
--							END
--					END
--				ELSE
--					BEGIN
--						set @columnname = 'Appraisal'+ cast(@cnt as varchar) +'#KPAScore'
--						IF Not EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @columnname AND TABLE_NAME LIKE '#dyTable%')		
--							BEGIN
--								set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] numeric(18,2)'
--								exec (@SQLCol)
								
								
--								if exists(select 1 from T0052_Emp_SelfAppraisal where InitiateId = @appid)
--									BEGIN
--										set @eacnt =@eacnt + 1	
--										set @SQLCol =''
--										set @columnname = 'Appraisal'+ cast(@cnt as varchar) +'#EAScore'
--										set @SQLCol ='ALTER TABLE  #dyTable ADD [' + @columnname + '] numeric(18,2)'
--										exec (@SQLCol)																													
--									END
--							END
--						set @SQLCol =''
						
--						set @SQLCol = ' update #dyTable
--								 set Appraisal'+ cast(@cnt as varchar) + '#KPAScore =s.KPA_Final
--								 From (select hi.KPA_Final
--									  from T0050_HRMS_InitiateAppraisal HI where emp_id=' + cast(@eid as varchar(18)) + ' and HI.InitiateId ='+ cast(@appid as varchar(18)) +')S
--								 WHERE emp_id =' + cast(@eid as varchar(18)) 
--						exec (@SQLCol)
						
--						IF  EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Appraisal'+ cast(@cnt as varchar)+'#EAScore' AND TABLE_NAME LIKE '#dyTable%')
--							BEGIN 
--								set @SQLCol = 'Update #dyTable
--											set Appraisal' + cast(@cnt as varchar)+ '#EAScore = EA.Weightage
--											From ( select sum(Weightage)  Weightage
--													from T0052_Emp_SelfAppraisal where emp_id =' + cast(@eid as varchar(18))  +' and InitiateId =' + cast(@appid as varchar(18)) +' )EA
--											WHERE emp_id =' + cast(@eid as varchar(18)) 	
--											exec (@SQLCol)
--							END
--					END
					
--					select @KPATotaltmp = (isnull(hi.KPA_Final,0)+isnull(hi.PF_Final,0)+isnull(hi.PO_Final,0)) from  T0050_HRMS_InitiateAppraisal HI where HI.emp_id = @eid and HI.InitiateId=@appid
--					set @KPATotal = @KPATotal +@KPATotaltmp
					
--					select @EATotaltmp = isnull(sum(HI.Weightage),0) from T0052_Emp_SelfAppraisal HI where HI.emp_id = @eid and HI.InitiateId=@appid
--					set @EATotal = @EATotal + @EATotaltmp
					
--					--select @tmpemp,@eid,@cnt
--					if @tmpemp <> @eid and @tmpemp=0
--						BEGIN
--							set @tmpemp = @eid
--							set @cnt = 1
--						End		
--					else 
--						BEGIN
--							set @tmpemp = @eid
--							set @cnt = @cnt +1
--						END		
--					--select @tmpemp,@eid,@cnt
--			fetch next from cur into @eid,@appid
--		End
--close cur
--deallocate cur

--set @tmpemp =0

--alter table  #dyTable
--add  KPATotal  numeric(18,2)
--alter table  #dyTable
--add  EATotal  numeric(18,2)

-- alter table  #dyTable
--add  FinalKPA  numeric(18,2)
--alter table  #dyTable
--add  FinalEA  numeric(18,2)
--alter table  #dyTable
--add  FinalTotal  numeric(18,2)
--alter table  #dyTable
--add  Achievement  varchar(100)

--  ----get achivement level
--declare @dept_Id as numeric(18,0)
--declare @Grd_Id as numeric(18,0)
--declare @achive as varchar(100) 
--set @achive =''

--declare cur cursor
--for
--	select emp_id,app_id from #dyTabletmp
--open cur
--	fetch next from cur into @eid,@appid
--	while @@FETCH_STATUS =0
--		Begin
--				if @tmpemp <> @eid or @tmpemp=0
--					BEGIN
--						set @cnt = 1
--						set @KPATotal =0
--						set @EATotal =0
--						set @kpaweight =0
--						set @kpaweight_tmp =0
--						set @EAweight =0
--						set @EAweight_tmp =0
--					END
--				Else
--					BEGIN 
--						set @cnt = @cnt+1
--					END
--			select @KPATotaltmp = (isnull(hi.KPA_Final,0)+isnull(hi.PF_Final,0)+isnull(hi.PO_Final,0)) from  T0050_HRMS_InitiateAppraisal HI where HI.emp_id = @eid and HI.InitiateId=@appid
--					set @KPATotal = @KPATotal +@KPATotaltmp
					
--					select @EATotaltmp = isnull(sum(HI.Weightage),0) from T0052_Emp_SelfAppraisal HI where HI.emp_id = @eid and HI.InitiateId=@appid
--					set @EATotal = @EATotal + @EATotaltmp
					
						

--set @SQLCol = 'Update #dyTable
--				Set KPATotal='+ cast(@KPATotal as VARCHAR(21)) +'
--				,EATotal=' + cast(@EATotal as VARCHAR(21)) +
--				'Where emp_id=' +  cast(@eid as VARCHAR(18))
--exec (@SQLCol)
 
-- select @kpaweight = isnull(EKPA_Weightage,0),@EAweight=isnull(SA_Weightage,0)
-- from T0060_Appraisal_EmpWeightage where emp_id = @eid and cmp_id = @cmp_id
 
---- select @KPATotal,@kpaweight,@cnt
--if @cnt =0 
--	set @cnt=1
----ELSE if @cnt > 1
----	set @cnt=@cnt-1
	
-- if @kpaweight <> 0
--	set @kpaweight_tmp = (@KPATotal*@kpaweight)/(@cnt*100)
	
--if @eacnt =0 
--	set @eacnt=1
-- if @EAweight <> 0
--	set @EAweight_tmp = (@EATotal*@EAweight)/(@eacnt*100)
 
-- set @finalTotal =@kpaweight_tmp +@EAweight_tmp
 

 
-- select @dept_Id=Dept_ID,@Grd_Id=Grd_ID
-- from T0095_INCREMENT where emp_id = @eid and Increment_Effective_Date=
-- (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id = @eid)



-- select   @achive = (Range_Level + ' [' + cast(Range_From as varchar(21)) +'-'+ cast(Range_To as varchar(21)) +' ]' )
-- from T0040_HRMS_RangeMaster where cmp_id = @cmp_id and
-- cast(@dept_Id as varchar(18))in (select data from dbo.split(Range_Dept,'#'))
-- and cast(@Grd_Id as varchar(18) ) in (select data from dbo.split(Range_Grade,'#'))
-- and Range_Type = 2 and (range_from <= @finalTotal  and range_to >=  @finalTotal)




--set @SQLCol = 'Update #dyTable
--				Set FinalKPA='+ cast(@kpaweight_tmp as VARCHAR(21)) +'
--				,FinalEA=' + cast(@EAweight_tmp as VARCHAR(21)) + '
--				,FinalTotal =' + cast(@finalTotal as VARCHAR(21)) + '
--				,Achievement =''' +  cast(@achive as VARCHAR(100)) + '''
--				Where emp_id=' +  cast(@eid as VARCHAR(18))
				
--exec (@SQLCol)
--				set @tmpemp = @eid	
--		fetch next from cur into @eid,@appid
--		End
--close cur
--deallocate cur

 

 
-- select * from #dyTable order by emp_id

-- drop table #dyTabletmp
--drop table #dyTable
--END
