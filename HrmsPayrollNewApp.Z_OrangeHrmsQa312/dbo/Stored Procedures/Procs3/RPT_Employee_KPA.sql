

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Employee_KPA]
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
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
	 CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric	  
	 ) 
 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
	Update #Emp_Cons  set Branch_ID = a.Branch_ID from (
		SELECT DISTINCT VE.Emp_ID,VE.branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE inner join
					  #Emp_Cons EC on  VE.Emp_ID = EC.Emp_ID
		)a
	where a.Emp_ID = #Emp_Cons.Emp_ID 	
	
	declare @col as numeric(18,0)
	
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
		--cmp_Address			varchar(200),
		cmp_Address			varchar(max), --added by aswini 18/01/2024
		cmp_logo			image,
	)
	create table #finalKPA
	(
		Emp_ID				numeric(18,0),
		Emp_KPA_Id			numeric(18,0),
		KPA_Content			varchar(1000),
		KPA_Target			varchar(1000),
		KPA_Weightage		numeric(18,2)
	)
	
	declare @deptid as numeric(18,0)
	declare @desigid as numeric(18,0)
	declare @inc_id as numeric(18,0)
	declare @KPA_Cnt as numeric(18,0)
	DECLARE @KPA_InitiateId AS INT 
	DECLARE @Emp_KPA_Id AS INT 
	DECLARE @Approval_Level AS VARCHAR(20)
	DECLARE @Effective_Date AS DATETIME
	
	declare cur_emp cursor
	for 
		select emp_id,Increment_ID from #Emp_Cons
	open cur_emp
		fetch next from cur_emp into @col,@inc_id	
		while @@FETCH_STATUS=0
			begin
				INSERT INTO #finaltable 
				Select E.Emp_ID,E.Emp_Full_Name,E.Alpha_Emp_Code,E.Date_Of_Join,E.Date_Of_Birth,
				       d.Dept_Name,dg.Desig_Name,b.Branch_Name,
				       case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar)<>0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  / 365) as varchar) + ' years ' else '' end +
					   case when cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar)<>0 then cast(floor(datediff(DAY, e.Date_Of_Join, getdate())  % 365 / 30) as varchar) + ' months ' else '' end +
					   case when cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar)<>0 then cast(datediff(DAY, e.Date_Of_Join, getdate())  % 30 as varchar) + ' days' else '' end as experience,
					   c.Cmp_Name, case when isnull(b.Branch_Address,'')='' then c.cmp_address else c.Cmp_Address end Cmp_Address,c.cmp_logo					  
				from		T0080_EMP_MASTER E WITH (NOLOCK)
				INNER JOIN	T0095_Increment I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID and I.Increment_ID=@inc_id
				LEFT JOIN	T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = I.Dept_ID
				LEFT JOIN	T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id
				LEFT JOIN   T0030_BRANCH_MASTER B WITH (NOLOCK) on B.Branch_ID = I.branch_id
				INNER JOIN  T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = @Cmp_ID
				Where E.Emp_ID = @col and e.Cmp_ID=@Cmp_ID
				
				SELECT @deptid =i.Dept_ID,@desigid = i.Desig_Id
						FROM T0095_Increment I WITH (NOLOCK)
						WHERE  I.Emp_ID = @col and I.Increment_ID= @inc_id

			IF EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA WITH (NOLOCK) WHERE Emp_Id=@col)
				BEGIN
					DECLARE CUR_KPA CURSOR
					FOR 
							SELECT MAX(Emp_KPA_Id)Emp_KPA_Id,AE.Emp_Id,KPA_InitiateId,Effective_Date				
							FROM T0060_Appraisal_EmployeeKPA AE WITH (NOLOCK)
							INNER JOIN #Emp_Cons EC ON EC.Emp_ID=AE.Emp_Id
							WHERE-- Effective_Date >= @From_Date and	
								   Effective_Date <= @To_Date
							GROUP BY AE.Emp_Id,KPA_InitiateId,Effective_Date
							OPEN CUR_KPA
					FETCH NEXT FROM CUR_KPA into @Emp_KPA_Id,@Emp_Id,@KPA_InitiateId,@Effective_Date		
					WHILE @@FETCH_STATUS=0
						BEGIN	
							SET @Approval_Level = ''
							
							SELECT @Approval_Level=Approval_Level FROM T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
							WHERE KPA_InitiateId=@KPA_InitiateId AND Effective_Date=@Effective_Date
							AND Emp_Id=@Emp_Id AND Emp_KPA_Id=@Emp_KPA_Id
							
							INSERT INTO #finalKPA
							SELECT @col,Emp_KPA_Id,KPA_Content,KPA_Target,KPA_Weightage FROM T0060_Appraisal_EmployeeKPA WITH (NOLOCK)
							WHERE KPA_InitiateId=@KPA_InitiateId AND Effective_Date=@Effective_Date
							AND Emp_Id=@Emp_Id AND Approval_Level=@Approval_Level
							
						fetch next from CUR_KPA into @Emp_KPA_Id,@Emp_Id,@KPA_InitiateId,@Effective_Date
						end
					close CUR_KPA
					deallocate CUR_KPA
				END
			ELSE
				BEGIN 				
					INSERT INTO #finalKPA
					SELECT @col,KPA_Id,KPA_Content,KPA_Target,KPA_Weightage
					FROM T0051_KPA_Master WITH (NOLOCK) INNER JOIN
					( 
						SELECT isnull(MAX(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_ID))Effective_Date,Desig_Id,Dept_Id
						FROM T0051_KPA_Master WITH (NOLOCK)									  
						WHERE Effective_Date <= @From_Date	and
							  CAST(@desigid as varchar(10)) in
							  (select Data from dbo.Split(isnull(T0051_KPA_Master.desig_id,''),'#')) 	AND
							  CAST(@deptid as varchar(10)) in
							  (select Data from dbo.Split(isnull(T0051_KPA_Master.dept_Id,''),'#'))
						GROUP BY Desig_Id,Dept_Id	
					 )k ON k.Effective_Date = T0051_KPA_Master.Effective_Date
					WHERE CAST(@desigid as varchar(10)) in
						(select Data from dbo.Split(isnull(T0051_KPA_Master.desig_id,''),'#')) 	AND
						CAST(@deptid as varchar(10)) in
						(select Data from dbo.Split(isnull(T0051_KPA_Master.dept_Id,''),'#'))
				END		
					
				--	END		
				--Else
				--	BEGIN	
				--		INSERT INTO #finalKPA
				--		SELECT SApparisal_ID as KPA_Id,SApparisal_Content as KPA_Content, null as KPA_Target 
				--		FROM T0040_SelfAppraisal_Master  
				--		WHERE SType=2 and @deptid in (select data from dbo.Split(SDept_Id,'#'))--modified on 16 Mar 2016 
				--		--SDept_Id like '%'+ cast(@deptid as varchar(18)) +'%'
				--	End		
				fetch next from cur_emp into @col,@inc_id		
			end
	close cur_emp
	deallocate cur_emp
	
	select * from #finaltable
	select * from #finalkpa
	
	drop table #finaltable
	drop table #finalkpa
END
