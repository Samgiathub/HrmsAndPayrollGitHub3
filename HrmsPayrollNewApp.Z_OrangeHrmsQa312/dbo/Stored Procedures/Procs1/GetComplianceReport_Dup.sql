
CREATE PROCEDURE [dbo].[GetComplianceReport_Dup] @Cmp_ID INT
	,@Branch_ID VARCHAR(MAX) = ''
	,@Year VARCHAR(100)
	,@Submission_Type VARCHAR(100)
	,@YearType VARCHAR(100)
	,@month VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DynamicSQL NVARCHAR(MAX);
	DECLARE @Columns NVARCHAR(MAX);
	DECLARE @qry VARCHAR(max) = ''
	DECLARE @cyear VARCHAR(10) = CAST(CAST(@year AS INT) + 1 AS VARCHAR)
	DECLARE @duemonth VARCHAR(3)
	DECLARE @Lbranch VARCHAR(max)

	SET @Lbranch = replace(@Branch_ID, '#', ',')
	--select @Branch_ID
	SET @Lbranch = '''%' + @Lbranch + '%'''
	SET @duemonth = CAST(@month + 1 AS VARCHAR)

	SELECT @Columns = STRING_AGG(QUOTENAME(Compliance_Name), ', ')
	FROM T0050_COMPLIANCE_MASTER
	WHERE Cmp_ID = @Cmp_ID
		AND Compliance_Submition_Type = @Submission_Type
		AND Compliance_Year_Type = (CAST(@YearType AS INT) - 1)

	--select @Columns
	--SELECT @DynamicSQL = Contr_PersonName from T0035_CONTRACTOR_DETAIL_MASTER WHERE Branch_ID=@Branch_ID 
	--SELECT @Columns AS Compliance_Columns,@DynamicSQL AS Contr_PersonName
	-------------------------------------------------------------------------------------------------------
	CREATE TABLE #TmpMonthData (
		Branch_Name VARCHAR(50)
		,Compliance_Name VARCHAR(50)
		,STATUS VARCHAR(5)
		);

	CREATE TABLE #branchdata (
		Branch_ID INT
		,Branch_Name VARCHAR(50)
		,Complince_ID INT
		);

	IF @Submission_Type = 1
	BEGIN
		TRUNCATE TABLE #TmpMonthData

		SELECT @Year AS 'CYear'
			,CM.Compliance_ID
			,CM.Compliance_Name
			,CM.DUE_DATE --
		INTO #tmpcmp
		FROM T0050_COMPLIANCE_MASTER CM
		WHERE CM.Compliance_Submition_Type = @Submission_Type
			AND Compliance_View_IN_Dash = 0
			AND Cmp_ID = @Cmp_ID
		ORDER BY CM.Compliance_Name

		--SELECT R.*,BM.Branch_Name,tr.Compliance_Name--,CONCAT(tr.DUE_DATE,'-', 6,'-',CASE WHEN 6 = 1 THEN  2025  ELSE  2024 END)C_Due_Date 
		--,CASE       WHEN Submission_Date IS NULL       THEN '-'    
		--WHEN MONTH(Submission_Date) = 6AND DAY(Submission_Date) <= tr.[DUE_DATE]  AND R.Year =  2024   AND (tr.[DUE_DATE] <= DAY(GETDATE()) OR 6 <= MONTH(GETDATE())) --AND R.Branch_ID LIKE ('%1,26,31,73%')  
		--THEN '1'  
		--WHEN MONTH(Submission_Date) = 6 AND DAY(Submission_Date) > tr.[DUE_DATE]  AND R.Year =  2024 --AND R.Branch_ID LIKE ('%1,26,31,73%')
		--THEN '0'  else '0'         END AS 'status' 
		--FROM T0050_Repository_Master R   
		--RIGHT JOIN #tmpcmp tr ON R.[Month] = DateName( month , DateAdd( month ,5 , -1 )) AND     R.Compliance_ID = tr.Compliance_ID and R.Year = tr.CYear --and R.Branch_ID LIKE ('%'+ CAST(BM.Branch_ID as varchar)  +'%')
		--left join T0030_BRANCH_MASTER BM ON BM.Cmp_ID = '1' 
		--WHERE BM.Branch_ID IN ((select data from dbo.Split('1#26#31#73','#')))
		--ORDER BY bm.Branch_Name
		SET @qry = 'INSERT into #TmpMonthData	
		SELECT BM.Branch_Name,tr.Compliance_Name
			,CASE 
				WHEN Submission_Date IS NULL
					THEN ''-''
				WHEN MONTH(Submission_Date) = ' + @duemonth + 'AND DAY(Submission_Date) <= tr.[DUE_DATE]  AND R.Year =  ' + @Year + ' 
				AND (tr.[DUE_DATE] <= DAY(GETDATE()) OR ' + @duemonth + ' <= MONTH(GETDATE()))  THEN ''1'' 
				WHEN MONTH(Submission_Date) = ' + @duemonth + ' AND DAY(Submission_Date) > tr.[DUE_DATE]  AND R.Year =  ' + @Year + ' THEN ''0''
				ELSE ''0''
				END AS ''status''
		FROM T0050_Repository_Master R
		RIGHT JOIN #tmpcmp tr ON R.[Month] = DateName( month , DateAdd( month ,' + CAST(@month AS VARCHAR) + ' , -1 )) AND
			R.Compliance_ID = tr.Compliance_ID and R.Year = tr.CYear
		left join T0030_BRANCH_MASTER BM ON BM.Cmp_ID = ''' + CAST(@Cmp_ID AS VARCHAR) + ''' ' + ' WHERE BM.Branch_ID IN ((select data from dbo.Split(''' + @Branch_ID + ''',''#'')))'

		--select @qry
		EXEC (@qry)

		--SELECT *
		--FROM #TmpMonthData
		SET @qry = 'SELECT *
		FROM (
			SELECT Branch_Name,Compliance_Name
				,[STATUS]
			FROM #TmpMonthData 
			
			) t
			
		PIVOT(MAX([status]) FOR Compliance_Name IN (' + @Columns + ')) AS pivot_table'

		EXEC (@qry)
	END
	ELSE IF @Submission_Type = 2
	BEGIN
		TRUNCATE TABLE #TmpMonthData

		CREATE TABLE #tmpdata (
			id INT
			,cmpname VARCHAR(50)
			,cmpID INT
			,duemonth VARCHAR(10)
			,cyear VARCHAR(10)
			,Cyeartype TINYINT
			)

		CREATE TABLE #Qdate (
			id INT
			,cmpname VARCHAR(50)
			,Duedate VARCHAR(50)
			)

		DECLARE @Due_Date VARCHAR(50)
			,@Due_Month VARCHAR(50)
			,@cmpname VARCHAR(50)
			,@cmpID INT
			,@cyeartype TINYINT;

		DECLARE cursor_product CURSOR
		FOR
		SELECT DUE_DATE
			,DUE_Month
			,Compliance_Name
			,Compliance_ID
			,Compliance_Year_Type
		FROM t0050_compliance_master
		WHERE Compliance_Submition_Type = @Submission_Type
			AND Compliance_View_IN_Dash = 0
			AND Cmp_ID = @Cmp_ID --and Compliance_Year_Type = 1 
			AND Compliance_View_IN_Repo = 0
			AND Compliance_Year_Type = CAST(@YearType AS INT) - 1

		OPEN cursor_product;

		FETCH NEXT
		FROM cursor_product
		INTO @Due_Date
			,@Due_Month
			,@cmpname
			,@cmpID
			,@cyeartype;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #tmpdata (
				id
				,cmpname
				,cmpID
				,duemonth
				,cyear
				,Cyeartype
				)
			SELECT Id
				,@cmpname
				,@cmpID
				,CAST(data AS VARCHAR) duemonth
				,CASE 
					WHEN Id > 2
						AND Data < 8
						THEN CAST(year(DATEADD(year, 1, GETDATE())) AS VARCHAR)
					ELSE CAST(YEAR(GETDATE()) AS VARCHAR)
					END AS cyear
				,@cyeartype
			FROM dbo.Split(@Due_Month, '#')

			--select * from #tmpdata
			INSERT INTO #Qdate (
				id
				,cmpname
				,Duedate
				)
			SELECT Id
				,@cmpname
				,data
			FROM dbo.Split(@Due_Date, '#')

			INSERT INTO #branchdata
			SELECT Bm.Branch_ID
				,BM.Branch_Name
				,@cmpID AS Complince_ID
			FROM T0030_BRANCH_MASTER BM
			WHERE BM.Cmp_ID = 1
				AND Is_Contractor_Branch = 1
				AND Branch_ID IN (
					SELECT data
					FROM dbo.Split(@Branch_ID, '#')
					)

			FETCH NEXT
			FROM cursor_product
			INTO @Due_Date
				,@Due_Month
				,@cmpname
				,@cmpID
				,@cyeartype;
		END;

		CLOSE cursor_product;

		DEALLOCATE cursor_product;

		--select * from #tmpdata
		--select * from #Qdate
		--select * from #branchdata
		SET @qry = 'INSERT into #TmpMonthData
			SELECT BM.Branch_Name,tmp.cmpname AS ''Compliance_Name''
				,CASE 
					WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATE, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103) AND RPm.Year = ' + @Year + ' 
						THEN ''1''
					WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103) AND RPm.Year = ' + @Year + 
			' 
						THEN ''0''
					ELSE ''-''
					END AS [Status]
			FROM #branchdata BM
			LEFT JOIN #tmpdata tmp  ON BM.Complince_ID = tmp.cmpID
			LEFT JOIN #Qdate td ON td.id = tmp.id
				AND td.cmpname = tmp.cmpname
			LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID
				AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + tmp.duemonth + ''-'' + tmp.cyear, 103)) 
				AND BM.Branch_ID  IN (select data from dbo.Split(RPm.Branch_ID,'',''))
			WHERE tmp.Cyeartype = (CAST(' + @YearType + ' as int) - 1) and tmp.id = ' + @month + ' 
			ORDER BY bm.Branch_Name,tmp.cmpname'

		--select @qry
		--SELECT BM.Branch_Name,BM.Branch_ID,tmp.cmpname AS 'Compliance_Name',tmp.cmpID     ,RPm.Submission_Date      
		--,CONCAT(td.Duedate,'-',CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END,'-', 2024)C_Due_Date     
		--,CASE    WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATE, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth
		--else tmp.duemonth END + '-' + tmp.cyear, 103) AND RPm.Year = 2024       
		--THEN '1'       WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103) AND RPm.Year = 2024    
		--THEN '0'       ELSE '-'       END AS [Status]    
		--FROM #branchdata BM
		--LEFT JOIN #tmpdata tmp  ON BM.Complince_ID = tmp.cmpID
		--LEFT JOIN #Qdate td ON td.id = tmp.id      AND td.cmpname = tmp.cmpname    
		--LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID   
		--AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + tmp.duemonth + '-' + tmp.cyear, 103))    
		--AND BM.Branch_ID  IN (select data from dbo.Split(RPm.Branch_ID,','))
		--WHERE tmp.Cyeartype = (CAST(1 as int) - 1) and tmp.id = 1  --AND BM.Branch_ID IN ((select data from dbo.Split(@Branch_ID ,'#')))
		--   ORDER BY bm.Branch_Name
		EXEC (@qry)

		SET @qry = 'SELECT *
		FROM (
			SELECT Branch_Name,Compliance_Name
				,[STATUS]
			FROM #TmpMonthData 
			
			) t
			
		PIVOT(MIN([status]) FOR Compliance_Name IN (' + @Columns + ')) AS pivot_table'

		EXEC (@qry)
	END
	ELSE IF @Submission_Type = 3
	BEGIN
		TRUNCATE TABLE #TmpMonthData

		CREATE TABLE #Hytmpdata (
			id INT
			,cmpname VARCHAR(50)
			,cmpID INT
			,duemonth VARCHAR(10)
			,cyear VARCHAR(10)
			,Cyeartype TINYINT
			)

		CREATE TABLE #Hydate (
			id INT
			,cmpname VARCHAR(50)
			,Duedate VARCHAR(50)
			)

		DECLARE @HyDue_Date VARCHAR(50)
			,@HyDue_Month VARCHAR(50)
			,@Hycmpname VARCHAR(50)
			,@HycmpID INT
			,@HYcyeartype TINYINT;

		DECLARE cursor_product CURSOR
		FOR
		SELECT DUE_DATE
			,DUE_Month
			,Compliance_Name
			,Compliance_ID
			,Compliance_Year_Type
		FROM t0050_compliance_master
		WHERE Compliance_Submition_Type = @Submission_Type
			AND Compliance_View_IN_Dash = 0
			AND Cmp_ID = @Cmp_ID --and Compliance_Year_Type = 1 
			AND Compliance_View_IN_Dash = 0
			AND Compliance_Year_Type = CAST(@YearType AS INT) - 1

		OPEN cursor_product;

		FETCH NEXT
		FROM cursor_product
		INTO @HyDue_Date
			,@HyDue_Month
			,@Hycmpname
			,@HycmpID
			,@Hycyeartype;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #HYtmpdata (
				id
				,cmpname
				,cmpID
				,duemonth
				,cyear
				,Cyeartype
				)
			SELECT Id
				,@Hycmpname
				,@HycmpID
				,CAST(data AS VARCHAR) duemonth
				,CASE 
					WHEN CAST(data AS INT) = 1
						THEN CAST(year(DATEADD(year, 1, GETDATE())) AS VARCHAR)
					ELSE CAST(YEAR(GETDATE()) AS VARCHAR)
					END AS cyear
				,@Hycyeartype
			FROM dbo.Split(@HyDue_Month, '#')

			--select * from #Hytmpdata
			INSERT INTO #Hydate (
				id
				,cmpname
				,Duedate
				)
			SELECT Id
				,@Hycmpname
				,data
			FROM dbo.Split(@HyDue_Date, '#')

			INSERT INTO #branchdata
			SELECT Bm.Branch_ID
				,BM.Branch_Name
				,@HycmpID AS Complince_ID
			FROM T0030_BRANCH_MASTER BM
			WHERE BM.Cmp_ID = 1
				AND Is_Contractor_Branch = 1
				AND Branch_ID IN (
					SELECT data
					FROM dbo.Split(@Branch_ID, '#')
					)

			FETCH NEXT
			FROM cursor_product
			INTO @HyDue_Date
				,@HyDue_Month
				,@Hycmpname
				,@HycmpID
				,@Hycyeartype;
		END;

		CLOSE cursor_product;

		DEALLOCATE cursor_product;

		--select * from #Hytmpdata
		--select * from #Hydate
		--select * from #branchdata
		--//////////////////////////////// Main Query/////////////////////////////////////////////////
		--SELECT BM.Branch_Name,tmp.cmpname AS 'Compliance_Name'
		--	,CASE 
		--		WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)
		--		AND RPm.Year = @Year THEN '1'
		--		WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)
		--		AND RPm.Year = @Year  THEN '0'
		--		ELSE ''
		--		END AS [Status]
		--FROM  #branchdata BM
		--LEFT JOIN #Hytmpdata tmp  ON BM.Complince_ID = tmp.cmpID
		--LEFT JOIN #Hydate td ON td.id = tmp.id      AND td.cmpname = tmp.cmpname    
		--LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID   
		--AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + tmp.duemonth + '-' + tmp.cyear, 103))    
		--AND BM.Branch_ID  IN (select data from dbo.Split(RPm.Branch_ID,','))
		--WHERE tmp.Cyeartype = (CAST(1 as int) - 1) and tmp.id = 1  --AND BM.Branch_ID IN ((select data from dbo.Split(@Branch_ID ,'#')))
		--   ORDER BY bm.Branch_Name, tmp.cmpname
		--/////////////////////////////////////////////////////////////////////////////////////////////
		SET @qry = ' INSERT into #TmpMonthData
				SELECT BM.Branch_Name,tmp.cmpname AS ''Compliance_Name''
				,CASE 
					WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103)
					AND RPm.Year = ' + @Year + ' THEN ''1''
					WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103)
					AND RPm.Year = ' + @Year + 
			' THEN ''0''
					ELSE ''''
					END AS [Status]
			FROM #branchdata BM
			LEFT JOIN #Hytmpdata tmp  ON BM.Complince_ID = tmp.cmpID
			LEFT JOIN #Hydate td ON td.id = tmp.id      AND td.cmpname = tmp.cmpname    
			LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID   
			AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + tmp.duemonth + ''-'' + tmp.cyear, 103))    
			AND BM.Branch_ID  IN (select data from dbo.Split(RPm.Branch_ID,'',''))
			WHERE tmp.Cyeartype = (CAST(1 as int) - 1) and tmp.id = 1  --AND BM.Branch_ID IN ((select data from dbo.Split(@Branch_ID ,''#'')))
		    ORDER BY bm.Branch_Name, tmp.cmpname'

		EXEC (@qry)

		--////////////////////////////////Pivot data //////////////////////////////////////////
		SET @qry = 'SELECT *
		FROM (
			SELECT Branch_Name,Compliance_Name
				,[STATUS] 
			FROM #TmpMonthData 
			) t
			
		PIVOT(MIN([status]) FOR Compliance_Name IN (' + @Columns + ')) AS pivot_table'

		EXEC (@qry)
	END
	ELSE IF @Submission_Type = 4
	BEGIN
		TRUNCATE TABLE #TmpMonthData

		DECLARE cursor_product CURSOR
		FOR
		SELECT DUE_DATE
			,DUE_Month
			,Compliance_Name
			,Compliance_ID
			,Compliance_Year_Type
		FROM t0050_compliance_master
		WHERE Compliance_Submition_Type = @Submission_Type
			AND Compliance_View_IN_Dash = 0
			AND Cmp_ID = @Cmp_ID --and Compliance_Year_Type = 1 
			AND Compliance_View_IN_Dash = 0
			AND Compliance_Year_Type = CAST(@YearType AS INT) - 1

		OPEN cursor_product;

		FETCH NEXT
		FROM cursor_product
		INTO @HyDue_Date
			,@HyDue_Month
			,@Hycmpname
			,@HycmpID
			,@Hycyeartype;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #branchdata
			SELECT Bm.Branch_ID
				,BM.Branch_Name
				,@HycmpID AS Complince_ID
			FROM T0030_BRANCH_MASTER BM
			WHERE BM.Cmp_ID = 1
				AND Is_Contractor_Branch = 1
				AND Branch_ID IN (
					SELECT data
					FROM dbo.Split(@Branch_ID, '#')
					)

			FETCH NEXT
			FROM cursor_product
			INTO @HyDue_Date
				,@HyDue_Month
				,@Hycmpname
				,@HycmpID
				,@Hycyeartype;
		END;

		CLOSE cursor_product;

		DEALLOCATE cursor_product;

		--//////////////////////////////// Main Query/////////////////////////////////////////////////
		--select BM.Branch_Name,Cmp.Compliance_Name 
		--,CASE WHEN   CAST(Rm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, Cmp.DUE_DATE + '-' + CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then '0' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END + '-' + @cyear, 103)  THen 
		--								'1' 
		--WHEN CAST(Rm.Submission_Date AS DATETIME) > CONVERT(DATETIME, Cmp.DUE_DATE + '-' + CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then '0' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END + '-' + @cyear, 103)  THen 
		--								'0' 
		--								ELSE '' END status 
		--FROM t0050_compliance_master Cmp
		--LEFT JOIN #branchdata BM ON BM.Complince_ID = Cmp.Compliance_ID
		--LEFT JOIN T0050_Repository_Master RM On RM.Compliance_ID = CMp.Compliance_ID AND RM.[Year] = @Year AND BM.Branch_ID  IN (select data from dbo.Split(RM.Branch_ID,','))
		--WHERE Compliance_Submition_Type = @Submission_Type AND cmp.Compliance_View_IN_Dash = 0 AND  Compliance_View_IN_Repo = 0 and Compliance_Year_Type = CAST(@YearType as int) -1 AND cmp.Cmp_ID = @Cmp_ID
		--ORDER BY RM.[Year]
		--/////////////////////////////////////////////////////////////////////////////////////////////
		SET @qry = 'select BM.Branch_Name,Cmp.Compliance_Name 
	,CASE WHEN  CAST(Rm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, CONCAT(Cmp.DUE_DATE , ''-'' , CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then ''0'' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END , ''-'' , ' + @cyear + '), 103)  THen 
									''1'' 
	WHEN CAST(Rm.Submission_Date AS DATETIME) > CONVERT(DATETIME, CONCAT(Cmp.DUE_DATE , ''-'' , CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then ''0'' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END , ''-'' , ' + @cyear + '), 103)  THen 
									''0'' 
									ELSE '''' END status 
	from t0050_compliance_master Cmp
	INNER JOIN #branchdata BM ON BM.Complince_ID = Cmp.Compliance_ID
	LEFT JOIN T0050_Repository_Master RM On RM.Compliance_ID = CMp.Compliance_ID AND RM.[Year] = ' + @Year + ' AND BM.Branch_ID  IN (select data from dbo.Split(RM.Branch_ID,'',''))
	 where Compliance_Submition_Type = ' + @Submission_Type + ' AND cmp.Compliance_View_IN_Dash = 0 AND Compliance_View_IN_Repo = 0 and Compliance_Year_Type = CAST(' + @YearType + 
			' as int) -1
	  order by RM.[Year]'

		--select (@qry)
		EXEC (@qry)
	END
END