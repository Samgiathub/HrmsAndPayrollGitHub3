CREATE PROCEDURE [dbo].[SP_RPT_EMP_LEAVE_BALANCE_GET] @Company_Id NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID VARCHAR(max) = ''
	,@Cat_ID VARCHAR(max) = ''
	,@Grade_ID VARCHAR(max) = ''
	,@Type_ID VARCHAR(max) = ''
	,@Dept_ID VARCHAR(max) = ''
	,@Desig_ID VARCHAR(max) = ''
	,@Emp_ID NUMERIC = 0
	,@Constraint VARCHAR(max) = ''
	,@New_Join_emp NUMERIC = 0
	,@Left_Emp NUMERIC = 0
	,@Salary_Cycle_id NUMERIC = 0
	,@Segment_Id VARCHAR(max) = '' -- Added By Nilesh patel 29092014
	,@Vertical_Id VARCHAR(max) = '' -- Added By Nilesh patel 29092014
	,@SubVertical_Id VARCHAR(max) = '' -- Added By Nilesh patel 29092014	
	,@SubBranch_Id VARCHAR(max) = '' -- Nilesh patel 29092014	
	,@Report_Type VARCHAR(50) = '' -- Added By Jignesh Patel 13-Dec-2013	
	,@report_leave AS VARCHAR(max) = ''
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

/*IF @Salary_Cycle_id = 0
		SET @Salary_Cycle_id =NULL*/
DECLARE @cmp_id AS NUMERIC

SET @cmp_id = @Company_Id

DECLARE @grd_id AS VARCHAR(max)

SET @grd_id = @Grade_ID

CREATE TABLE #Emp_Cons (
	Emp_ID NUMERIC
	,Branch_ID NUMERIC
	,Increment_ID NUMERIC
	)

EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID
	,@From_Date
	,@To_Date
	,@Branch_ID
	,@Cat_ID
	,@Grd_ID
	,@Type_ID
	,@Dept_ID
	,@Desig_ID
	,@Emp_ID
	,@constraint
	,0
	,@Salary_Cycle_id
	,@Segment_Id
	,@Vertical_Id
	,@SubVertical_Id
	,@SubBranch_Id
	,@New_Join_emp
	,@Left_Emp
	,0
	,'0'
	,0
	,0

--if exists(SELECT 1 FROM sys.tables where name = 'leave_temp')
--	drop table leave_temp;
CREATE TABLE #TMP_LEAVE_DETAIL (
	leave_ID NUMERIC
	,leave_Name VARCHAR(128) PRIMARY KEY
	)

IF @Report_Type LIKE 'Balance%'
	OR @report_type = 'COMPOFF-RECORD'
BEGIN
	DECLARE @cols AS NVARCHAR(MAX)
	DECLARE @query AS NVARCHAR(MAX)
	DECLARE @Col_name AS NVARCHAR(MAX)
	DECLARE @query_CompOff AS NVARCHAR(MAX) --changed by Gadriwala 02102014

	--added by mansi start 
	IF OBJECT_ID(N'tempdb..#L_master') IS NOT NULL
	BEGIN
		DROP TABLE #L_master
	END

	SELECT Leave_ID
		,Leave_Name
		,Cmp_ID
	INTO #L_master
	FROM T0040_LEAVE_MASTER
	WHERE Cmp_ID = @cmp_id

	UPDATE #L_master
	SET Leave_Name = Replace(Leave_Name, '_', ' ')
	WHERE Leave_Name LIKE '%_%'

	--added by mansi end 
	IF @report_leave = ''
	BEGIN
		IF @Report_Type = 'Balance'
			OR @report_type = 'COMPOFF-RECORD'
			--added by mansi start 
		BEGIN
			SET @query = '
								INSERT INTO #TMP_LEAVE_DETAIL
								SELECT * from(
									SELECT Leave_ID, REPLACE(REPLACE(rtrim(ltrim(Leave_Name)), ''_'', ''__''),'' '',''_'') AS leave_Name FROM #L_master where Cmp_ID = ' + cast(@cmp_ID AS NVARCHAR(max)) + '
										union
									SELECT Leave_ID, REPLACE(REPLACE(rtrim(ltrim(Leave_Name)), ''_'', ''__''),'' '',''_'') + ''_Balance'' AS leave_Name FROM #L_master
									where cmp_id = ' + cast(@cmp_ID AS NVARCHAR(max)) + ') AS a
									order by leave_Name'
		END
				--added by mansi end 
				----commented by mansi start 
				--BEGIN
				--	SET @query = '
				--		INSERT INTO #TMP_LEAVE_DETAIL
				--		SELECT * from(
				--			SELECT Leave_ID, REPLACE(REPLACE(rtrim(ltrim(Leave_Name)), ''_'', ''__''),'' '',''_'') AS leave_Name FROM T0040_LEAVE_MASTER where Cmp_ID = '+cast(@cmp_ID AS nVARCHAR(max))+'
				--				union
				--			SELECT Leave_ID, REPLACE(REPLACE(rtrim(ltrim(Leave_Name)), ''_'', ''__''),'' '',''_'') + ''_Balance'' AS leave_Name FROM t0040_Leave_Master
				--			where cmp_id = '+cast(@cmp_ID AS nVARCHAR(max))+') AS a
				--			order by leave_Name'
				--END
				--	--commented by mansi end 
		ELSE IF @Report_Type = 'Balance_Column'
		BEGIN
			SET @query = '
								INSERT INTO #TMP_LEAVE_DETAIL
								SELECT * from(
									SELECT Leave_ID,REPLACE(REPLACE(rtrim(ltrim(Leave_Name)), ''_'', ''__''),'' '',''_'') AS leave_Name 
									FROM T0040_LEAVE_MASTER where Cmp_ID = ' + cast(@cmp_ID AS NVARCHAR(max)) + ') AS a
									order by leave_Name'
		END

		EXEC (@query)
			--update #TMP_LEAVE_DETAIL set leave_Name='PL_Heli' where leave_Name='PL__Heli'---by mansi
	END
	ELSE
	BEGIN
		IF @Report_Type = 'Balance'
			OR @report_type = 'COMPOFF-RECORD'
		BEGIN
			INSERT INTO #TMP_LEAVE_DETAIL
			SELECT *
			FROM (
				SELECT Leave_ID
					,REPLACE(rtrim(ltrim(Leave_Name)), ' ', '_') AS Leave_Name
				FROM T0040_LEAVE_MASTER LM
				INNER JOIN dbo.Split(@report_leave, '#') AS D1 ON LM.Leave_Name = D1.Data
				WHERE Cmp_ID = @cmp_ID
				
				UNION
				
				SELECT Leave_ID
					,REPLACE(rtrim(ltrim(Leave_Name)), ' ', '_') + '_Balance' AS leave_Name
				FROM T0040_LEAVE_MASTER LM
				INNER JOIN dbo.Split(@report_leave, '#') AS D1 ON LM.Leave_Name = D1.Data
				WHERE Cmp_id = @cmp_ID
				) AS A
			ORDER BY leave_Name
		END
		ELSE
		BEGIN
			INSERT INTO #TMP_LEAVE_DETAIL
			SELECT *
			FROM (
				SELECT Leave_ID
					,REPLACE(rtrim(ltrim(Leave_Name)), ' ', '_') AS leave_Name
				FROM T0040_LEAVE_MASTER LM
				INNER JOIN dbo.split(@report_leave, '#') AS D1 ON LM.Leave_Name = D1.data
				WHERE Cmp_ID = @Cmp_ID
				) AS A
			ORDER BY leave_Name
		END
	END

	--select * from #TMP_LEAVE_DETAIL
	--SELECT * INTO #leave_temp FROM #TMP_LEAVE_DETAIL
	--drop table leave_temp
	SELECT @cols = STUFF((
				SELECT DISTINCT ',' + QUOTENAME(REPLACE(rtrim(ltrim(Leave_Name)), ' ', '_'))
				FROM #TMP_LEAVE_DETAIL
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	SELECT @Col_name = STUFF((
				SELECT DISTINCT ',' + QUOTENAME(leave_Name) + ' AS ' + '''' + leave_Name + ''''
				FROM #TMP_LEAVE_DETAIL
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	--Changed by Gadriwala Muslim 02102014
	CREATE TABLE #T2 (
		Emp_ID NUMERIC
		,For_Date DATETIME
		)

	--CREATE UNIQUE CLUSTERED INDEX IX_T1_LEAVE ON #T2(EMP_ID, FOR_DATE)
	SET @query = NULL;

	SELECT @query = COALESCE(@query + ';', '') + 'ALTER TABLE #T2 ADD ' + DATA + ' NUMERIC(18,4) '
	FROM dbo.Split(@cols, ',') T

	EXECUTE (@Query)

	--Create table #T1_COMP
	--(
	--	Emp_ID		Numeric,
	--	For_Date	DateTime
	--)
	--CREATE UNIQUE CLUSTERED INDEX IX_T1_COMP_LEAVE ON #T1_COMP(EMP_ID, FOR_DATE)
	--SET @query  = NULL;
	--SELECT	@query  = COALESCE(@query + ';', '') +  'ALTER TABLE #T1_COMP ADD ' + DATA + ' NUMERIC(18,4) '
	--FROM	dbo.Split(@cols, ',') T
	--Execute(@Query)
	SET @query = '
					INSERT INTO #T2
					SELECT emp_ID,For_date,' + @cols + ' FROM 
				 (SELECT e.cmp_ID,e.emp_ID,e.For_Date, REPLACE(rtrim(ltrim(s.Leave_Name)),'' '',''_'') AS leave_Name,(e.leave_used + IsNull(e.Back_Dated_Leave,0)) AS leave_used
					FROM T0140_LEAVE_TRANSACTION  e
					inner join T0040_LEAVE_MASTER s
					  on e.Leave_ID = s.Leave_ID and isnull(s.Default_Short_Name,'''') <> ''Comp'' 
					  inner join #emp_cons ec on e.emp_id = ec.emp_id
					  where isnull(e.IsMakerChaker,0) <> 1 and e.cmp_ID = ' + CONVERT(VARCHAR(10), @Cmp_ID) + ' and For_Date >= ''' + CONVERT(VARCHAR(20), @From_Date) + ''' and For_Date <= ''' + Convert(VARCHAR(20), @to_Date) + '''
					group by e.cmp_ID,e.emp_ID,s.leave_Name,e.leave_used,e.for_Date,e.Back_Dated_Leave) x
				 pivot 
				 (
					sum(leave_used)
					for leave_Name in(' + @cols + ')
				 ) p  '
	--Added by Gadriwala Muslim 02102014
	SET @query_CompOff = '
					INSERT INTO #T2
					SELECT emp_ID,For_date,' + @cols + ' FROM 
					 (SELECT e.cmp_ID,e.emp_ID,e.For_Date, REPLACE(rtrim(ltrim(s.Leave_Name)),'' '',''_'') AS leave_Name, (e.CompOff_Used - e.Leave_Encash_Days)  AS CompOff_Used
						FROM T0140_LEAVE_TRANSACTION  e
						inner join T0040_LEAVE_MASTER s
						  on e.Leave_ID = s.Leave_ID  and isnull(s.Default_Short_Name,'''') = ''Comp''
						  inner join #emp_cons ec on e.emp_id = ec.emp_id
						  where isnull(e.IsMakerChaker,0) <> 1 and  e.cmp_ID = ' + CONVERT(VARCHAR(10), @Cmp_ID) + ' and For_Date >= ''' + CONVERT(VARCHAR(20), @From_Date) + ''' and For_Date <= ''' + Convert(VARCHAR(20), @to_Date) + '''
						group by e.cmp_ID,e.emp_ID,s.leave_Name,e.leave_used,e.for_Date,e.CompOff_Used,e.Leave_Encash_Days) x
					 pivot 
					 (
						sum(CompOff_Used)
						for leave_Name in(' + @cols + ')
					 ) p  '

	--if exists(SELECT 1 FROM sys.tables where name ='t1' )
	--BEGIN
	--	drop table t1
	--end
	--      if exists(SELECT 1 FROM sys.tables where name ='t1_Comp' ) --Added by Gadriwala Muslim 02102014
	--BEGIN
	--	drop table t1_Comp
	--end
	EXECUTE (@Query)

	EXECUTE (@query_CompOff) --Changed by Gadriwala Muslim 02102014

	--SELECT * INTO #t2 FROM t1  
	--union all
	--SELECT * FROM  t1_Comp		--Changed by Gadriwala Muslim 02102014
	--drop table t1
	--drop table t1_Comp			--Added by Gadriwala Muslim 02102014
	/*
			
			
			
				SET @sumColumn = replace(replace(@Col_name ,'[','sum(['),']','])')
			
				SET @valQur = 'SELECT emp_id,'+ @sumColumn + ' INTO t2 FROM  #t2 group by Emp_id'
	        
				if exists(SELECT 1 FROM sys.tables where name ='t2' )
				BEGIN
					drop table t2
				end
	
				Execute(@valQur)
	   
	
				SELECT * INTO #t3 FROM t2
				drop table t2
			
			
  			--SET @sumColumn = 'sum(' + replace(@Col_name,']','),sum(')
			
				exec(@valQur)
		
			
	   			*/
	DECLARE @valQur AS VARCHAR(max)
	DECLARE @sumColumn AS VARCHAR(max)

	CREATE TABLE #T3 (
		Emp_ID NUMERIC
		,For_Date DATETIME
		)

	CREATE UNIQUE CLUSTERED INDEX IX_T3_LEAVE ON #T3 (
		EMP_ID
		,FOR_DATE
		)

	DECLARE @d AS NVARCHAR

	SET @query = NULL;

	SELECT @query = COALESCE(@query + ';', '') + 'ALTER TABLE #T3 ADD ' + DATA + ' NUMERIC(18,4) '
	FROM dbo.Split(@cols, ',') T

	EXECUTE (@Query)

	SELECT @sumColumn = COALESCE(@sumColumn + ',', '') + 'SUM(' + DATA + ') AS ' + DATA
	FROM dbo.Split(@cols, ',') T

	SET @query = 'INSERT INTO #T3
									SELECT Emp_ID,For_Date,' + @sumColumn + ' FROM #T2
									GROUP BY Emp_ID,For_Date'

	EXECUTE (@Query)

	CREATE TABLE #temp_CompOff (
		Emp_ID NUMERIC
		,Leave_opening DECIMAL(18, 2)
		,Leave_Used DECIMAL(18, 2)
		,Leave_Closing DECIMAL(18, 2)
		,Leave_Code VARCHAR(max)
		,Leave_Name VARCHAR(max)
		,Leave_ID NUMERIC
		,CompOff_String VARCHAR(max) DEFAULT NULL -- Added by Gadriwala 18022015
		)

	CREATE TABLE #leave_Balance_Comp_Temp (
		Emp_ID NUMERIC(18, 2)
		,Leave_ID NUMERIC
		,For_date DATETIME
		,Leave_Closing DECIMAL(18, 2)
		,Leave_Code VARCHAR(max)
		)

	DECLARE @Default_Short_Name AS VARCHAR(25)
	DECLARE @compOff_Leave_ID AS NUMERIC(18, 0)
	DECLARE @Leave_Emp_ID NUMERIC(18, 0)

	SET @Default_Short_Name = ''

	SELECT @compOff_Leave_ID = leave_id
	FROM T0040_LEAVE_MASTER
	WHERE Default_Short_Name = 'COMP'
		AND Cmp_ID = @CMP_ID

	IF @report_leave = ''
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM sys.tables
				WHERE name = 'leave_Balance_Comp_Temp'
				)
			DROP TABLE leave_Balance_Comp_Temp

		IF EXISTS (
				SELECT 1
				FROM sys.tables
				WHERE name = 'leave_Balance_Temp'
				)
			DROP TABLE leave_Balance_Temp

		--Changed by Gadriwala Muslim 02102014
		--updated by mansi 29-09-23 start
		SET @query = 'SELECT     Emp_ID, Leave_ID,''' + convert(NVARCHAR(10), @to_Date, 101) + ''' AS For_Date, Leave_Closing, REPLACE(rtrim(ltrim(Leave_Name)),'' '',''_'') AS Leave_Name
									INTO            [leave_Balance_Temp]
									FROM         (SELECT    LT.Cmp_ID,LT.Emp_ID, LT.Leave_ID, LT.For_Date, LT.Leave_Closing, LM.Leave_Name
													FROM		T0140_LEAVE_TRANSACTION AS LT 
															INNER JOIN (SELECT  Emp_ID, Leave_ID, MAX(For_Date) AS For_Date
																		FROM	T0140_LEAVE_TRANSACTION
																		WHERE   (For_Date <= ''' + convert(NVARCHAR(10), @to_Date, 101) + 
			''')
																		GROUP BY Emp_ID, Leave_ID) AS LT1 ON LT.Emp_ID = LT1.Emp_ID
																		AND LT.Leave_ID = LT1.Leave_ID AND LT.For_Date = LT1.For_Date 
													INNER JOIN [#emp_cons] AS EC ON LT.Emp_ID = EC.emp_id 
													INNER JOIN T0040_LEAVE_MASTER AS LM ON LT.Leave_ID = LM.Leave_ID 
													AND IsNull(LM.Default_Short_Name,'''') <> ''COMP'') AS A
									WHERE 
									Cmp_ID=' + Cast(@Cmp_ID AS VARCHAR(10))

		--updated by mansi end 29-09-23 end
		-----commented by mansi start 29-09-23
		--		SET @query = 'SELECT     Emp_ID, Leave_ID,''' + convert(nVARCHAR(10),@to_Date,101)+''' AS For_Date, Leave_Closing, REPLACE(rtrim(ltrim(Leave_Name)),'' '',''_'') AS Leave_Name
		--			INTO            [leave_Balance_Temp]
		--			FROM         (SELECT    LT.Cmp_ID,LT.Emp_ID, LT.Leave_ID, LT.For_Date, LT.Leave_Closing, LM.Leave_Name
		--							FROM		T0140_LEAVE_TRANSACTION AS LT 
		--									INNER JOIN (SELECT  Emp_ID, Leave_ID, MAX(For_Date) AS For_Date
		--												FROM	T0140_LEAVE_TRANSACTION
		--												WHERE   (For_Date <= '''+convert(nVARCHAR(10),@to_Date,101)+''')
		--												GROUP BY Emp_ID, Leave_ID) AS LT1 ON LT.Emp_ID = LT1.Emp_ID
		--												AND LT.Leave_ID = LT1.Leave_ID AND LT.For_Date = LT1.For_Date 
		--							INNER JOIN [#emp_cons] AS EC ON LT.Emp_ID = EC.emp_id 
		--							INNER JOIN T0040_LEAVE_MASTER AS LM ON LT.Leave_ID = LM.Leave_ID 
		--							AND IsNull(LM.Default_Short_Name,'''') <> ''COMP'') AS A
		--			WHERE isnull(AS.IsMakerChaker,0) <> 1 and 
		--			Cmp_ID=' + Cast(@Cmp_ID AS VARCHAR(10))
		----commented by mansi end 29-09-23
		EXEC (@query)

		----Added by Gadriwala Muslim 02102014	
		--	SET @query_CompOff ='SELECT LT.Emp_ID,LT.Leave_ID,''' + convert(nVARCHAR(10),@to_Date,101)+''' AS For_Date,isnull(sum(CompOff_Balance),0) AS Leave_Closing
		--					 ,LM.leave_Code INTO [leave_Balance_Comp_Temp]  FROM T0140_Leave_Transaction LT inner join
		--			          [#emp_cons] AS ec ON LT.Emp_ID = ec.emp_id inner join
		--			         T0040_Leave_Master AS LM on LT.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'''') = ''Comp''
		--					where LT.cmp_ID = ''' + CONVERT(nVARCHAR(10),@cmp_ID) + ''' and For_Date <= ''' + Convert(nVARCHAR(10),@To_Date,101) + '''
		--			         group by LT.emp_ID,LT.Leave_ID,LM.leave_Code'
		IF @report_type = 'Balance'
			OR @report_type = 'COMPOFF-RECORD'
		BEGIN
			INSERT INTO #temp_CompOff
			EXEC GET_COMPOFF_DETAILS_ALL @To_Date
				,@Cmp_ID
				,@Constraint
				,@compOff_Leave_ID
				,2

			IF EXISTS (
					SELECT 1
					FROM #temp_CompOff
					)
			BEGIN
				INSERT INTO #leave_Balance_Comp_Temp
				SELECT Emp_ID
					,Leave_ID
					,@To_Date AS for_date
					,Leave_Closing
					,Replace(Leave_Name, ' ', '_')
				FROM #temp_CompOFf --Replaced Leave_Code to Leave_Name by Nimesh 02-Jul-2015
			END

			IF @report_type = 'COMPOFF-RECORD'
				RETURN
					--DECLARE curCompOffBalance CURSOR FOR SELECT Emp_ID FROM #emp_cons Order by Emp_ID  
					--open curCompOffBalance  
					--FETCH NEXT FROM curCompOffBalance INTO @Leave_Emp_ID  
					--WHILE @@FETCH_STATUS = 0  
					--	BEGIN  
					--		delete FROM #temp_CompOff	
					--		exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
					--		If exists(SELECT 1 FROM #temp_CompOff)
					--		BEGIN
					--			insert INTO #leave_Balance_Comp_Temp
					--				SELECT @Leave_Emp_ID AS Emp_ID,Leave_ID,@To_Date AS for_date,Leave_Closing,Replace(Leave_Name, ' ','_') FROM #temp_CompOFf --Replaced Leave_Code to Leave_Name by Nimesh 02-Jul-2015
					--		end	
					--		FETCH NEXT FROM curCompOffBalance INTO @Leave_Emp_ID  
					--	end   
					--close curCompOffBalance  
					--deallocate curCompOffBalance  
		END
				--exec(@query_CompOff) --Added by Gadriwala Muslim 02102014	
	END
	ELSE
	BEGIN
		SELECT Emp_ID
			,Leave_ID
			,@to_Date AS For_Date
			,Leave_Closing
			,Leave_Name
		INTO [leave_Balance_Temp]
		FROM (
			SELECT LT.Emp_ID
				,LT.Leave_ID
				,LT.For_Date
				,LT.Leave_Closing
				,LM.Leave_Name
			FROM T0140_LEAVE_TRANSACTION AS LT
			INNER JOIN (
				SELECT Emp_ID
					,Leave_ID
					,MAX(For_Date) AS For_Date
				FROM T0140_LEAVE_TRANSACTION
				WHERE isnull(IsMakerChaker, 0) <> 1
					AND (For_Date <= @to_Date)
				GROUP BY Emp_ID
					,Leave_ID
				) AS LT1 ON LT.Emp_ID = LT1.Emp_ID
				AND LT.Leave_ID = LT1.Leave_ID
				AND LT.For_Date = LT1.For_Date
			INNER JOIN [#emp_cons] AS EC ON LT.Emp_ID = EC.Emp_ID
			INNER JOIN T0040_LEAVE_MASTER AS LM ON LT.Leave_ID = LM.Leave_ID
				AND IsNull(lm.Default_Short_Name, '') <> 'COMP' --Changed by Gadriwala Muslim 02102014
			INNER JOIN dbo.Split(@report_leave, '#') AS RL ON LM.Leave_Name = RL.Data
			) AS A

		--Added by Gadriwala Muslim 02102014
		--SELECT LT.Emp_ID,LT.Leave_ID,@to_Date AS For_Date,isnull(sum(CompOff_Balance),0) AS Leave_Closing
		--			,LM.leave_Code INTO [leave_Balance_Comp_Temp] FROM T0140_Leave_Transaction LT inner join
		--	          [#emp_cons] AS ec ON LT.Emp_ID = ec.emp_id inner join
		--	      T0040_Leave_Master AS LM on LT.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') = 'Comp'
		--			where LT.cmp_ID = @cmp_ID and For_Date <= @To_Date
		--	         group by LT.emp_ID,LT.Leave_ID,LM.Leave_Code		
		IF @report_type = 'Balance'
			OR @report_type = 'COMPOFF-RECORD'
		BEGIN
			INSERT INTO #temp_CompOff
			EXEC GET_COMPOFF_DETAILS_ALL @To_Date
				,@Cmp_ID
				,@Constraint
				,@compOff_Leave_ID
				,2

			IF EXISTS (
					SELECT 1
					FROM #temp_CompOff
					)
			BEGIN
				INSERT INTO #leave_Balance_Comp_Temp
				SELECT Emp_ID
					,Leave_ID
					,@To_Date AS for_date
					,Leave_Closing
					,Replace(Leave_Name, ' ', '_')
				FROM #temp_CompOFf --Replaced Leave_Code to Leave_Name by Nimesh 02-Jul-2015
			END
					--DECLARE curCompOffBalance CURSOR FOR SELECT Emp_ID FROM #emp_cons Order by Emp_ID  
					--open curCompOffBalance  
					--FETCH NEXT FROM curCompOffBalance INTO @Leave_Emp_ID  
					--WHILE @@FETCH_STATUS = 0  
					--	BEGIN  
					--		delete FROM #temp_CompOff	
					--		exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
					--		If exists(SELECT 1 FROM #temp_CompOff)
					--		BEGIN
					--			insert INTO #leave_Balance_Comp_Temp
					--			SELECT @Leave_Emp_ID AS Emp_ID,Leave_ID AS Leave_ID,@to_Date AS for_date,Leave_Closing,Replace(Leave_Name, ' ','_')  FROM #temp_CompOFf  --Replaced Leave_Code to Leave_Name by Nimesh 02-Jul-2015
					--		end	
					--		FETCH NEXT FROM curCompOffBalance INTO @Leave_Emp_ID  
					--	end   
					--close curCompOffBalance  
					--deallocate curCompOffBalance  	       
		END
	END

	SELECT *
	INTO #leave_balance_temp
	FROM leave_balance_temp
	
	UNION ALL
	
	SELECT *
	FROM #leave_Balance_Comp_Temp --changed by Gadriwala Muslim 02102014

	--IF EXISTS(SELECT 1 FROM SYS.tables WHERE NAME='t1')
	--	DROP TABLE t1
	DROP TABLE leave_balance_temp

	--drop table leave_Balance_Comp_Temp --Added by Gadriwala Muslim 02102014
	IF @report_type = 'Balance'
		OR @report_type = 'COMPOFF-RECORD'
	BEGIN
		DECLARE @cols_balance AS VARCHAR(max)
		DECLARE @cols_name_bal AS VARCHAR(max)

		SELECT @cols_balance = STUFF((
					SELECT DISTINCT ',' + QUOTENAME(Leave_Name)
					FROM #leave_balance_temp
					FOR XML PATH('')
						,TYPE
					).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

		SELECT @cols_name_bal = STUFF((
					SELECT DISTINCT ',' + QUOTENAME(Leave_Name) + ' AS ' + '''' + cast(Leave_Name AS VARCHAR) + ''''
					FROM #leave_balance_temp AS t2
					FOR XML PATH('')
						,TYPE
					).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

		CREATE TABLE #LEAVE_PIVOT (
			EMP_ID NUMERIC
			,FOR_DATE DATETIME
			)

		SET @query = NULL;

		SELECT @query = COALESCE(@query + ';', '') + ' ALTER TABLE #LEAVE_PIVOT ADD ' + DATA + ' NUMERIC(18,4)'
		FROM dbo.Split(@cols_balance, ',') C

		--select Leave_name from #leave_balance_temp
		EXEC (@query);

		SET @query = 'INSERT INTO #LEAVE_PIVOT 
										SELECT emp_ID,For_date,' + @cols_balance + ' FROM 
										(SELECT Emp_ID,For_date,Leave_Name,IsNull(leave_closing,0) As leave_closing  FROM #leave_balance_temp) x
										pivot 
										(
											sum(leave_closing)
											for Leave_Name in(' + @cols_balance + ')
										) p  '

		EXEC (@query)

		--SELECT * INTO #t4 FROM t1
		DECLARE @leave_code_temp AS VARCHAR(max)
		DECLARE @leave_code_temp1 AS VARCHAR(max)

		--SELECT * FROM t1
		--SELECT * FROM t2
		--SELECT * FROM #t3
		--SELECT * FROM #t4
		DECLARE cur CURSOR
		FOR
		SELECT DISTINCT Leave_Name
		FROM #leave_balance_temp

		OPEN cur

		FETCH NEXT
		FROM cur
		INTO @leave_Code_temp

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--SET @leave_Code_temp = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@leave_Code_temp)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
			SET @leave_code_temp1 = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@leave_Code_temp)), '+', '_'), '''', '_'), ',', '_'), '.', '_'), '  ', ' '), '%', ''), '-', ' '), '@', ''), '(', ''), ')', ''), ' ', '_'), '__', '_'), '__', '_'), '/', '') + '_balance'
			SET @leave_code_temp1 = quotename(@leave_code_temp1)
			SET @leave_code_temp = quotename(@leave_code_temp)
			SET @Query = 'UPDATE T3
												set		' + @leave_code_temp1 + ' = LP.' + @leave_code_temp + '
												FROM	#T3 T3 INNER JOIN #LEAVE_PIVOT LP ON T3.emp_id = LP.emp_id'

			EXEC (@query)

			FETCH NEXT
			FROM cur
			INTO @leave_Code_temp
		END

		CLOSE cur

		DEALLOCATE cur
	END

	SELECT E.Alpha_Emp_Code
		,E.Emp_Full_Name
		,T3.*
		,I_Q.Branch_ID
	FROM dbo.T0080_EMP_MASTER E
	LEFT OUTER JOIN dbo.T0100_Left_Emp l ON E.Emp_ID = l.Emp_ID
	INNER JOIN (
		SELECT I.Emp_Id
			,Grd_ID
			,Branch_ID
			,Cat_ID
			,Desig_ID
			,Dept_ID
			,Type_ID
		FROM dbo.T0095_INCREMENT I
		INNER JOIN (
			SELECT MAX(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM dbo.T0095_INCREMENT
			WHERE Increment_Effective_Date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY Emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) I_Q ON E.Emp_ID = I_Q.Emp_ID
	INNER JOIN dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID
	LEFT OUTER JOIN dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID
	LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id
	LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id
	INNER JOIN dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID
	INNER JOIN dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
	LEFT OUTER JOIN #T3 T3 ON E.Emp_ID = T3.Emp_ID
	INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID
	WHERE E.Cmp_ID = @Cmp_Id
	ORDER BY CASE 
			WHEN IsNumeric(e.Alpha_Emp_Code) = 1
				THEN Right(Replicate('0', 21) + e.Alpha_Emp_Code, 20)
			WHEN IsNumeric(e.Alpha_Emp_Code) = 0
				THEN Left(e.Alpha_Emp_Code + Replicate('', 21), 20)
			ELSE e.Alpha_Emp_Code
			END
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
END
ELSE IF @Report_Type LIKE 'Total%'
BEGIN
	DECLARE @cols_T AS NVARCHAR(MAX) --, @query  AS NVARCHAR(MAX), @Col_name AS nVARCHAR(MAX)

	CREATE TABLE #Leave_Name (Leave_Name VARCHAR(128))

	IF @report_leave = ''
	BEGIN
		IF @Report_Type = 'Total'
		BEGIN
			SET @query = '
								INSERT INTO #Leave_Name 
								SELECT	Leave_Name
								FROM	(SELECT	REPLACE(rtrim(ltrim(Leave_Name)),'' '',''_'') AS Leave_Name 
										FROM	T0040_LEAVE_MASTER 
										WHERE	Cmp_ID = ' + cast(@cmp_ID AS NVARCHAR(max)) + ') AS A
								ORDER BY Leave_Name'
		END
		ELSE IF @Report_Type = 'Total_Column'
		BEGIN
			SET @query = '
								INSERT INTO #Leave_Name 
								SELECT	Leave_Name
								FROM	(SELECT	REPLACE(rtrim(ltrim(Leave_Name)),'' '',''_'') AS Leave_Name 
											FROM	T0040_LEAVE_MASTER 
											WHERE	Cmp_ID = ' + cast(@cmp_ID AS NVARCHAR(max)) + ') AS A
								ORDER BY Leave_Name'
		END

		EXEC (@query)
	END
	ELSE
	BEGIN
		IF @Report_Type = 'Total'
		BEGIN
			INSERT INTO #Leave_Name
			SELECT Leave_Name
			FROM (
				SELECT REPLACE(rtrim(ltrim(Leave_Name)), ' ', '_') AS Leave_Name
				FROM T0040_LEAVE_MASTER LM
				INNER JOIN dbo.split(@report_leave, '#') AS D1 ON REPLACE(rtrim(ltrim(LM.Leave_Name)), ' ', '_') = REPLACE(rtrim(ltrim(D1.data)), ' ', '_')
				WHERE Cmp_ID = @cmp_ID
				) AS A
			ORDER BY Leave_Name
		END
		ELSE
		BEGIN
			INSERT INTO #Leave_Name
			SELECT Leave_Name
			FROM (
				SELECT REPLACE(rtrim(ltrim(Leave_Name)), ' ', '_') AS Leave_Name
				FROM T0040_LEAVE_MASTER LM
				INNER JOIN dbo.split(@report_leave, '#') AS D1 ON REPLACE(rtrim(ltrim(LM.Leave_Name)), ' ', '_') = REPLACE(rtrim(ltrim(D1.data)), ' ', '_')
				WHERE Cmp_ID = @cmp_ID
				) AS A
			ORDER BY Leave_Name
		END
	END

	--SELECT * INTO #TMP_LEAVE_DETAIL FROM leave_temp
	--drop table leave_temp
	SELECT @cols_T = STUFF((
				SELECT DISTINCT ',' + QUOTENAME(Leave_Name)
				FROM #Leave_Name
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	SELECT @Col_name = STUFF((
				SELECT DISTINCT ',' + QUOTENAME(Leave_Name) + ' AS ' + '''' + cast(Leave_Name AS VARCHAR) + ''''
				FROM #Leave_Name
				FOR XML PATH('')
					,TYPE
				).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

	--Changed by Gadriwala Muslim 02102014
	CREATE TABLE #LEAVE_TRAN (
		Emp_ID NUMERIC
		,For_Date DATETIME
		)

	SET @query = NULL;

	SELECT @query = COALESCE(@query + ';', '') + ' ALTER TABLE #LEAVE_TRAN ADD ' + DATA + ' NUMERIC(18,4)'
	FROM dbo.Split(@cols_T, ',') T

	EXEC (@query);

	SET @query = 'INSERT	INTO #LEAVE_TRAN
							SELECT	Emp_ID,For_Date,' + @cols_T + ' 
							FROM	(SELECT LT.cmp_ID,LT.emp_ID,LT.For_Date, replace(LM.Leave_Name,'' '',''_'') AS Leave_Name,
											(LT.leave_used + IsNull(LT.Back_Dated_Leave,0)) AS Leave_Used
									FROM	T0140_LEAVE_TRANSACTION LT
											INNER JOIN T0040_LEAVE_MASTER LM on LT.Leave_ID = LM.Leave_ID AND IsNull(LM.Default_Short_Name,'''') <> ''comp''
											INNER JOIN #Emp_Cons EC ON LT.Emp_id = EC.Emp_id
									WHERE isnull(LT.IsMakerChaker,0) <> 1 and 	LT.Cmp_ID = ' + CONVERT(VARCHAR(10), @Cmp_ID) + ' 
											AND For_Date >= ''' + CONVERT(VARCHAR(20), @From_Date) + ''' 
											AND For_Date <= ''' + Convert(VARCHAR(20), @to_Date) + '''
									GROUP BY LT.cmp_ID,LT.Emp_ID,LM.Leave_Name,LT.Leave_Used,LT.Back_Dated_Leave,LT.for_Date) X
							PIVOT (
									SUM(Leave_Used) FOR Leave_Name IN(' + @cols_T + ')
									) p'

	EXEC (@query);

	CREATE TABLE #LEAVE_TRAN_COMP (
		Emp_ID NUMERIC
		,For_Date DATETIME
		)

	SET @query = NULL;

	SELECT @query = COALESCE(@query + ';', '') + ' ALTER TABLE #LEAVE_TRAN_COMP ADD ' + DATA + ' NUMERIC(18,4)'
	FROM dbo.Split(@cols_T, ',') T

	EXEC (@query);

	SET @query = 'INSERT	INTO #LEAVE_TRAN_COMP
							SELECT	Emp_ID,For_Date,' + @cols_T + ' 
							FROM	(SELECT LT.cmp_ID,LT.emp_ID,LT.For_Date, REPLACE(LM.Leave_Name,'' '',''_'') AS Leave_Name,
											(LT.CompOff_Used - IsNull(LT.Leave_Encash_Days,0)) AS Leave_Used
									FROM	T0140_LEAVE_TRANSACTION LT
											INNER JOIN T0040_LEAVE_MASTER LM ON LT.Leave_ID = LM.Leave_ID AND IsNull(LM.Default_Short_Name,'''') = ''comp''
											INNER JOIN #Emp_Cons EC ON LT.Emp_id = EC.Emp_id
									WHERE	isnull(LT.IsMakerChaker,0) <> 1 and  LT.Cmp_ID = ' + CONVERT(VARCHAR(10), @Cmp_ID) + ' 
											AND For_Date >= ''' + CONVERT(VARCHAR(20), @From_Date) + ''' 
											AND For_Date <= ''' + Convert(VARCHAR(20), @to_Date) + '''
									GROUP BY LT.cmp_ID,LT.Emp_ID,LM.Leave_Name,LT.CompOff_Used,LT.Leave_Encash_Days,LT.for_Date) X
							PIVOT (
									SUM(Leave_Used) FOR Leave_Name IN(' + @cols_T + ')
									) p'

	----Added by Gadriwala Muslim 02102014
	--SET @query  = 'SELECT Emp_ID,For_date,' + @cols_T + ' INTO t1_Comp FROM 
	--				(SELECT e.cmp_ID,e.emp_ID,e.For_Date, replace(s.Leave_Name,'' '',''_'') AS Leave_Name,(e.CompOff_Used - e.Leave_Encash_Days) AS leave_used
	--					FROM T0140_LEAVE_TRANSACTION  e
	--					inner join T0040_LEAVE_MASTER s
	--					on e.Leave_ID = s.Leave_ID  and isnull(s.Default_Short_Name,'''') = ''comp''
	--					inner join #emp_cons ec on e.emp_id = ec.emp_id
	--				where e.cmp_ID = ' + CONVERT(VARCHAR(10),@Cmp_ID) + ' and For_Date >= ''' + CONVERT(VARCHAR(20),@From_Date) + ''' and For_Date <= ''' + Convert(VARCHAR(20),@to_Date) + '''
	--				group by e.cmp_ID,e.emp_ID,s.Leave_Name,e.CompOff_Used,e.Leave_Encash_Days,e.for_Date) x
	--				pivot 
	--				(sum(leave_used)
	--	for Leave_Name in(' + @cols_T + ')) p'
	--if exists(SELECT 1 FROM sys.tables where name ='t1' )
	--	BEGIN
	--		drop table t1
	--	end
	--      if exists(SELECT 1 FROM sys.tables where name ='t1_Comp' ) --Added by Gadriwala Muslim 02102014
	--	BEGIN
	--		drop table t1_Comp
	--	end
	EXECUTE (@Query)

	EXECUTE (@query_CompOff) --Added by Gadriwala Muslim 02102014

	SELECT *
	INTO #LEAVE_TRAN_MAIN
	FROM #LEAVE_TRAN
	
	UNION ALL
	
	SELECT *
	FROM #LEAVE_TRAN_COMP

	--SELECT * INTO #t2_T FROM t1 
	--	union all
	--SELECT * FROM t1_Comp  --Added by Gadriwala Muslim 02102014
	--drop table t1
	--drop table t1_Comp --Added by Gadriwala Muslim 02102014
	CREATE TABLE #LEAVE_TRAN_SUM (Emp_ID NUMERIC)

	SET @query = NULL

	SELECT @Query = COALESCE(@Query + ';', '') + ' ALTER TABLE #LEAVE_TRAN_SUM ADD ' + DATA + ' NUMERIC(18,4)'
	FROM dbo.Split(@cols_T, ',') C

	EXEC (@Query)

	SET @sumColumn = replace(replace(@Col_name, '[', 'sum(['), ']', '])')
	SET @valQur = 'INSERT INTO #LEAVE_TRAN_SUM
						SELECT Emp_ID,' + @sumColumn + ' FROM  #LEAVE_TRAN_MAIN GROUP BY Emp_ID'

	--      SET @Query = 'if exists(SELECT 1 FROM sys.tables where name =''t2'' )
	--				BEGIN
	--					drop table t2
	--				end'
	--Execute(@Query)
	EXECUTE (@valQur)

	--SELECT t2.*,(isnull(t3.Leave_Used,0) + ISNULL(t4.CompOFF_Used,0)) AS Total_Leave_Used INTO #t3_T FROM t2
	--left outer join (
	--SELECT Cmp_ID ,Emp_ID , sum(Leave_Used ) AS leave_used FROM (
	--SELECT     e.Cmp_ID, e.Emp_ID,  sum(case when Apply_Hourly = 1 then ((e.Leave_Used) * 0.125) else (e.Leave_Used + IsNULL(e.Back_Dated_Leave,0)) end)  AS Leave_Used
	--				FROM         T0140_LEAVE_TRANSACTION AS e INNER JOIN
	--					  T0040_LEAVE_MASTER AS s ON e.Leave_ID = s.Leave_ID and isnull(s.Default_Short_Name,'') <> 'COMP' INNER JOIN
	--					  [#emp_cons] AS ec ON e.Emp_ID = ec.emp_id
	--					  --inner join #TMP_LEAVE_DETAIL AS ltt on s.leave_Code = ltt.Leave_Name
	--				WHERE     (e.Cmp_ID = @Cmp_ID) AND (e.For_Date >= @from_date) AND (e.For_Date <= @to_date)
	--GROUP BY e.Cmp_ID, e.Emp_ID,Apply_Hourly ) t5 group by Cmp_ID,emp_id) t3 on t2.Emp_ID = t3.Emp_ID
	--left outer join 
	--(SELECT     e.Cmp_ID, e.Emp_ID, case when Apply_Hourly = 1 then (sum(e.CompOff_Used - e.Leave_Encash_Days) * 0.125) else sum(e.CompOff_Used - e.Leave_Encash_Days) end AS CompOFF_Used --Added by Gadriwala Muslim 02102014
	--				FROM         T0140_LEAVE_TRANSACTION AS e INNER JOIN
	--					  T0040_LEAVE_MASTER AS s ON e.Leave_ID = s.Leave_ID and isnull(s.Default_Short_Name,'') = 'COMP' INNER JOIN
	--					  [#emp_cons] AS ec ON e.Emp_ID = ec.emp_id
	--					  --inner join #TMP_LEAVE_DETAIL AS ltt on s.leave_Code = ltt.Leave_Name
	--				WHERE     (e.Cmp_ID = @Cmp_ID) AND (e.For_Date >= @from_date) AND (e.For_Date <= @to_date)
	--GROUP BY e.Cmp_ID, e.Emp_ID,s.Apply_Hourly) t4 on t2.Emp_ID = t4.Emp_ID
	SELECT LTS.*
		,(isnull(LT2.Leave_Used, 0) + ISNULL(LT3.CompOFF_Used, 0)) AS Total_Leave_Used
	INTO #t3_T
	FROM #LEAVE_TRAN_SUM LTS
	LEFT OUTER JOIN (
		SELECT Cmp_ID
			,Emp_ID
			,SUM(Leave_Used) AS Leave_Used
		FROM (
			SELECT LT.Cmp_ID
				,LT.Emp_ID
				,SUM(CASE 
						WHEN Apply_Hourly = 1
							THEN ((LT.Leave_Used) * 0.125)
						ELSE (LT.Leave_Used + IsNULL(LT.Back_Dated_Leave, 0))
						END) AS Leave_Used
			FROM T0140_LEAVE_TRANSACTION AS LT
			INNER JOIN T0040_LEAVE_MASTER AS LM ON LT.Leave_ID = LM.Leave_ID
				AND IsNull(LM.Default_Short_Name, '') <> 'COMP'
			INNER JOIN [#Emp_Cons] AS EC ON LT.Emp_ID = EC.emp_id
			WHERE isnull(LT.IsMakerChaker, 0) <> 1
				AND (LT.Cmp_ID = @Cmp_ID)
				AND (LT.For_Date >= @From_Date)
				AND (LT.For_Date <= @To_Date)
			GROUP BY LT.Cmp_ID
				,LT.Emp_ID
				,Apply_Hourly
			) LT1
		GROUP BY Cmp_ID
			,Emp_ID
		) LT2 ON LTS.Emp_ID = LT2.Emp_ID
	LEFT OUTER JOIN (
		SELECT LT.Cmp_ID
			,LT.Emp_ID
			,CASE 
				WHEN Apply_Hourly = 1
					THEN (SUM(LT.CompOff_Used - LT.Leave_Encash_Days) * 0.125)
				ELSE SUM(LT.CompOff_Used - LT.Leave_Encash_Days)
				END AS CompOFF_Used --Added by Gadriwala Muslim 02102014
		FROM T0140_LEAVE_TRANSACTION AS LT
		INNER JOIN T0040_LEAVE_MASTER AS LM ON LT.Leave_ID = LM.Leave_ID
			AND IsNull(LM.Default_Short_Name, '') = 'COMP'
		INNER JOIN [#Emp_Cons] AS EC ON LT.Emp_ID = EC.emp_id
		WHERE isnull(LT.IsMakerChaker, 0) <> 1
			AND (LT.Cmp_ID = @Cmp_ID)
			AND (LT.For_Date >= @from_date)
			AND (LT.For_Date <= @to_date)
		GROUP BY LT.Cmp_ID
			,LT.Emp_ID
			,LM.Apply_Hourly
		) LT3 ON LTS.Emp_ID = LT3.Emp_ID

	--if exists(SELECT 1 FROM sys.tables where name ='t2' )
	--	BEGIN
	--		drop table t2
	--	end	
	--SET @sumColumn = 'sum(' + replace(@Col_name,']','),sum(')
	--exec(@valQur)
	SELECT E.Alpha_Emp_Code
		,E.Emp_Full_Name
		,DM.Dept_Name AS Department
		,CTM.CAT_Name
		,T3_T.*
		,I_q.Branch_ID
	FROM dbo.T0080_EMP_MASTER E
	LEFT OUTER JOIN dbo.T0100_Left_Emp l ON E.Emp_ID = l.Emp_ID
	INNER JOIN (
		SELECT I.Emp_Id
			,Grd_ID
			,Branch_ID
			,Cat_ID
			,Desig_ID
			,Dept_ID
			,Type_ID
		FROM dbo.T0095_INCREMENT I
		INNER JOIN (
			SELECT MAX(Increment_ID) AS Increment_ID
				,Emp_ID
			FROM dbo.T0095_Increment -- Ankit 11092014 for Same Date Increment
			WHERE Increment_Effective_date <= @To_Date
				AND Cmp_ID = @Cmp_ID
			GROUP BY Emp_ID
			) Qry ON I.Emp_ID = Qry.Emp_ID
			AND I.Increment_ID = Qry.Increment_ID
		) I_Q ON E.Emp_ID = I_Q.Emp_ID
	INNER JOIN dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID
	LEFT OUTER JOIN dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID
	LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id
	LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id
	LEFT OUTER JOIN dbo.T0030_CATEGORY_MASTER CTM ON I_Q.CAT_ID = CTM.CAT_ID
	INNER JOIN dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID
	INNER JOIN dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID
	INNER JOIN #T3_T T3_T ON E.Emp_ID = T3_T.Emp_ID
	INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID
	WHERE E.Cmp_ID = @Cmp_Id
	ORDER BY CASE 
			WHEN IsNumeric(e.Alpha_Emp_Code) = 1
				THEN Right(Replicate('0', 21) + e.Alpha_Emp_Code, 20)
			WHEN IsNumeric(e.Alpha_Emp_Code) = 0
				THEN Left(e.Alpha_Emp_Code + Replicate('', 21), 20)
			ELSE e.Alpha_Emp_Code
			END
END

RETURN
