



CREATE PROCEDURE [dbo].[Get_Detail_LeaveWise_Encashment] 
	@cmp_id numeric
	,@from_date datetime
	,@to_date datetime
	--,@branch_id numeric -- Comment by nilesh patel on 29092014
	--,@Cat_ID numeric
	--,@grd_id numeric
	--,@Type_id numeric
	--,@dept_ID numeric
	--,@desig_ID numeric
	,@branch_id varchar(max)
	,@Cat_ID varchar(max) -- Added by nilesh patel on 29092014
	,@grd_id varchar(max)
	,@Type_id varchar(max)
	,@dept_ID varchar(max)
	,@desig_ID varchar(max)
	,@emp_id numeric
	,@constraint varchar(max)
	,@is_Emp NUMERIC = 0
	,@is_Column numeric = 0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	declare @chkConstraint1 as varchar(max)
	
	declare @qry1 as varchar(max)
	set @qry1 = ''
	if exists (select top 1 * from [tempdb].[dbo].sysobjects where name = '#V_Emp_Get_Info1' and type = 'u')
	begin
		drop table #V_Emp_Get_Info1
	end
	IF @constraint <> ''
	BEGIN
		set @chkConstraint1 = ' and mec.Emp_ID in (select cast(data as numeric) from dbo.Split ( ''' + @Constraint + ''',''#''))'
	END 
	
	CREATE TABLE #V_Emp_Get_Info1
	(
		emp_id numeric
		,branch_id numeric
		,Cmp_ID numeric
		,Increment_ID numeric
		,Join_Date datetime
		,Left_Date datetime
		,Emp_code numeric
		,dept_id numeric
		,grd_id numeric
		,desig_id numeric
		,type_id numeric
	)
	if @constraint <> ''
	begin
		set @qry1 = '
					insert into #V_Emp_Get_Info1
					SELECT DISTINCT mec.Emp_ID, mec.Branch_ID, mec.Cmp_ID, mec.Increment_ID, mec.Join_Date, mec.Left_Date,
					mec.Emp_Code,dept_id,grd_id,desig_id,type_id
					FROM V_Emp_Cons AS mec INNER JOIN
					(SELECT Emp_ID, MAX(Increment_ID) AS Increment_ID
					FROM V_Emp_Cons
					GROUP BY Emp_ID) AS ec ON mec.Emp_ID = ec.Emp_ID AND mec.Increment_ID = ec.Increment_ID
					WHERE (1 = 1)' + @chkConstraint1
		
		exec (@qry1)
	end
	else
	begin
		insert into #V_Emp_Get_Info1
		select distinct emp_id,branch_id,Cmp_ID,Increment_ID,Join_Date,Left_Date,Emp_code,dept_id,grd_id,desig_id,type_id
		from dbo.V_Emp_Cons where
		cmp_id=@Cmp_ID
		-- Comment by nilesh patel on 29092014
		--and Isnull(Cat_ID,0) = case when @Cat_ID = 0 then Isnull(Cat_ID,0) else Isnull(@Cat_ID , Isnull(Cat_ID,0)) end
		--and Branch_ID = case when @branch_id = 0 then Branch_ID else isnull(@Branch_ID ,Branch_ID) end
		--and Grd_ID = case when @grd_id = 0 then Grd_ID else isnull(@Grd_ID ,Grd_ID) end
		--and isnull(Dept_ID,0) = case when @dept_ID = 0 then isnull(Dept_ID,0) else isnull(@Dept_ID ,isnull(Dept_ID,0)) end
		--and Isnull(Type_ID,0) = case when @Type_id = 0 then Isnull(Type_ID,0) else isnull(@Type_ID ,Isnull(Type_ID,0)) end
		--and Isnull(Desig_ID,0) = case when @desig_ID = 0 then Isnull(Desig_ID,0) else isnull(@Desig_ID ,Isnull(Desig_ID,0)) end
		
			-- Added by nilesh patel on 29092014
		and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') ) 
		and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
		and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
		and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )
		and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') )  
		and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
		and Emp_ID = case when @emp_id = 0 then Emp_ID else isnull(@Emp_ID ,Emp_ID) end
		and Increment_Effective_Date <= @To_Date
		and
		((@From_Date >= join_Date and @From_Date <= left_date)
		or (@To_Date >= join_Date and @To_Date <= left_date)
		or (Left_date is null and @To_Date >= Join_Date)
		or (@To_Date >= left_date and @From_Date <= left_date))
		order by Emp_ID

		delete from #V_Emp_Get_Info1 where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment WITH (NOLOCK)
		where Increment_effective_Date <= @to_date AND Cmp_ID = @cmp_id
		group by emp_ID)
	END

	SELECT tlt.Emp_ID,tlt.Leave_ID,replace(RIGHT(CONVERT(NVARCHAR(11),For_Date,106),8),' ','_') AS For_Month,SUM(Leave_Encash_Days) AS Leave_Encash_Days  
	INTO #leave_count FROM dbo.T0140_LEAVE_TRANSACTION AS tlt WITH (NOLOCK)
	INNER JOIN #v_emp_get_info1 AS vegi1 ON vegi1.emp_id = tlt.Emp_ID AND vegi1.Cmp_ID = tlt.Cmp_ID
	WHERE ISNULL(Leave_Encash_Days,0) >0
	AND For_Date BETWEEN @from_date AND @to_date 
	GROUP BY tlt.Emp_ID,RIGHT(CONVERT(NVARCHAR(11),For_Date,106),8),Leave_ID 
	
	
	
	IF @is_Emp=1 AND @is_Column= 0
	BEGIN
		SELECT DISTINCT lc.Emp_ID,Alpha_Emp_Code,Emp_Full_Name,Mobile_No FROM #leave_count AS lc
		INNER JOIN dbo.T0080_EMP_MASTER AS tem WITH (NOLOCK) ON lc.Emp_ID = tem.Emp_ID
		RETURN 
	END
	
	

	DECLARE @colspivot as varchar(max) ,
			@query_leave as varchar(max) ,
			@colspivot_null as varchar(max) ,
			@colspivot_add as varchar(max) 
		
		Set	@colspivot  = ''
		Set	@query_leave = ''
		Set	@colspivot_null = ''
		Set	@colspivot_add = ''
				
	select @colsPivot_null = STUFF((SELECT ', isnull(' + QUOTENAME(cast(For_Month as varchar(max))) + ',0) AS ' + QUOTENAME(cast(For_Month as varchar(max)))
								from #leave_Count as a
								cross apply ( select 'Leave_Code' col, 1 so ) c 
								group by col,a.For_Month,so 
								order by CAST(replace(For_Month,'_',' ') AS DATETIME)
						FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

	select @colsPivot = STUFF((SELECT ',' + QUOTENAME(cast(For_Month as varchar(max))) 
								from #leave_Count as a
								cross apply ( select 'Leave_Code' col, 1 so ) c 
								group by col,a.For_Month,so 
								order by CAST(replace(For_Month,'_',' ') AS DATETIME)
						FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

	select @colsPivot_add = STUFF((SELECT '+' + QUOTENAME(cast(For_Month as varchar(max))) 
								from #leave_Count as a
								cross apply ( select 'Leave_Code' col, 1 so ) c 
								group by col,a.For_Month,so 
								order by CAST(replace(For_Month,'_',' ') AS DATETIME)
						FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')


	if exists (select 1 from #leave_count)
	begin
		set @query_leave = 'select Emp_id,leave_id,'+@colsPivot_null+' into Leave_Count_Pivot
			from (select Emp_ID,leave_id,For_Month, Leave_Encash_Days from #leave_Count) 
			as data pivot 
			( sum(Leave_Encash_Days) 
			for For_Month in ('+ @colsPivot +') ) p' 

		
		exec (@query_leave)
		
		SELECT * INTO #leave_count_pivot FROM Leave_Count_Pivot
		DROP TABLE leave_count_pivot

		

		IF @is_emp = 0 AND @is_column = 0
		begin
			SET @query_leave = 'SELECT tem.Alpha_Emp_Code as Emp_Code,tem.Emp_Full_Name,tbm.Branch_Name,tlm.Leave_Name,' + @colspivot_null + ',
			' + @colspivot_add + ' as Total,vegi.Branch_id FROM #V_Emp_Get_Info1 AS vegi 
			INNER JOIN dbo.T0080_EMP_MASTER AS tem WITH (NOLOCK) on vegi.emp_id = tem.Emp_ID 
			INNER JOIN dbo.T0030_BRANCH_MASTER AS tbm WITH (NOLOCK) ON vegi.branch_id = tbm.Branch_ID
			INNER JOIN #leave_count_pivot AS lcp ON vegi.emp_id = lcp.emp_id
			INNER JOIN dbo.T0040_LEAVE_MASTER AS tlm WITH (NOLOCK) ON lcp.leave_id = tlm.Leave_ID '
			
			EXEC (@query_leave)
		end
	end
	else
	begin
		select tem.Alpha_Emp_Code as Emp_Code, tem.Emp_Full_Name, tbm.Branch_Name, '' as Leave_Name,vegi.Branch_id from #V_Emp_Get_Info1 as vegi
		INNER JOIN dbo.T0080_EMP_MASTER AS tem WITH (NOLOCK) on vegi.emp_id = tem.Emp_ID 
		INNER JOIN dbo.T0030_BRANCH_MASTER AS tbm WITH (NOLOCK) ON vegi.branch_id = tbm.Branch_ID	
	end
	
	
END

