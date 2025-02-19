
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Employee_KPA_Scores]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime 
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	CREATE TABLE #Emp_Cons 
	(      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	) 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE INNER JOIN
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID 
	
	declare @col as numeric(18,0)	
	declare @init as numeric(18,0)	
	create table #finaltable
	(
		Emp_ID				numeric(18,0),
		Emp_Full_Name		varchar(100),
		Alpha_Emp_Code		varchar(100),
		Date_Of_Join		datetime,
		Date_Of_Birth		datetime,
		Dept_Name			varchar(100),
		Desig_Name			varchar(100),
		Branch_name			varchar(100),
		Experience			varchar(100),
		Cmp_name			varchar(100),
		cmp_Address			varchar(200),
		cmp_logo			image,
		SA_StartDate		DATETIME, 
		SA_EndDate			DATETIME,
		initiateId			NUMERIC(18,0)
	)
	create table #finalKPA
	(
		Emp_ID				numeric(18,0),
		Emp_KPA_Id			numeric(18,0),
		KPA_Content			varchar(1000),
		KPA_Target			varchar(1000),
		KPA_Weightage		numeric(18,2),
		initiateId			NUMERIC(18,0),
		KPA_Emp_Score		numeric(18,2),
		KPA_Manager_Score	numeric(18,2),
		KPA_Final_Score		numeric(18,2)
	)
	
	
	declare cur_emp cursor
	for 
		select emp_id from #Emp_Cons
	open cur_emp
		fetch next from cur_emp into @col	
		while @@FETCH_STATUS=0
			begin
				insert into #finaltable
				Select AI.Emp_ID,E.Emp_Full_Name,E.Alpha_Emp_Code,E.Date_Of_Join,E.Date_Of_Birth,
				       d.Dept_Name,dg.Desig_Name,b.Branch_Name,
				       case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar)<>0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar) + ' years ' else '' end +
					   case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar)<>0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar) + ' months ' else '' end +
					   case when cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar)<>0 then cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar) + ' days' else '' end as experience,
					   c.Cmp_Name, case when isnull(b.Branch_Address,'')='' then c.cmp_address else c.Cmp_Address end Cmp_Address,c.cmp_logo,AI.SA_Startdate,AI.SA_Enddate,AI.InitiateId					  
				from   T0050_HRMS_InitiateAppraisal AI WITH (NOLOCK) 
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = AI.Emp_Id
				INNER JOIN	T0095_Increment I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID and I.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where emp_id=@col)
				LEFT  JOIN	T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID
				LEFT  JOIN	T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id
				LEFT  JOIN  T0030_BRANCH_MASTER B WITH (NOLOCK) on B.Branch_ID = I.branch_id
				INNER JOIN  T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = @Cmp_ID
				Where AI.Emp_ID = @col and AI.Cmp_ID=@Cmp_ID
								
				fetch next from cur_emp into @col	
			END
	close cur_emp
	DEALLOCATE cur_emp
	
	set @col = null
	
	declare cur_emp cursor
	for 
		select emp_id,initiateId from #finaltable
	open cur_emp
		fetch next from cur_emp into @col,@init	
		while @@FETCH_STATUS=0
			BEGIN
				INSERT INTO #finalKPA
				SELECT @col,KPA_ID,KPA_Content,KPA_Target,KPA_Weightage,@init,KPA_AchievementEmp,KPA_AchievementRM,KPA_Achievement
				FROM T0052_HRMS_KPA WITH (NOLOCK) where InitiateId= @init and emp_id=@col
								
				FETCH NEXT FROM cur_emp INTO @col,@init		
			END
	close cur_emp
	DEALLOCATE cur_emp	
	
	SELECT  Emp_ID,
		    Emp_Full_Name,
			Alpha_Emp_Code,
			convert(varchar(12),Date_Of_Join,103) Date_Of_Join,
			convert(varchar(12),Date_Of_Birth,103) Date_Of_Birth,
			Dept_Name,
			Desig_Name,
			Branch_name,
			Experience,
			Cmp_name,
			cmp_Address,
			cmp_logo,
			convert(varchar(12),SA_StartDate,103) SA_StartDate, 
			convert(varchar(12),SA_EndDate,103) SA_EndDate,
			initiateId	 
	FROM #finaltable
	
	select Emp_ID
		   ,Emp_KPA_Id
		   ,KPA_Content
		   ,KPA_Target
		   ,isnull(KPA_Weightage,0)KPA_Weightage
		   ,initiateId
		   ,isnull(KPA_Emp_Score,0)KPA_Emp_Score
		   ,isnull(KPA_Manager_Score,0)KPA_Manager_Score
		   ,isnull(KPA_Final_Score,0) KPA_Final_Score
	from #finalKPA
END

