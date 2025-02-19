
CREATE PROCEDURE [dbo].[SP_Get_Compliance_Data] 
	@Cmp_ID VARCHAR(2)
	,@Branch_ID varchar(100) = ''
	,@Year nvarchar(50)
	,@submitionType varchar(2)
	

AS
BEGIN

declare @Abranch varchar(20) 
set @Abranch = @Branch_ID

set @Branch_ID =   '''%' + @Branch_ID + '%'''
--declare @branch varchar(20)= @Branch_ID  
declare @qry varchar(max) = ''

	declare @cyear varchar(10) = CAST(CAST(@year as int) + 1 as varchar) 

		

IF @submitionType = 1
BEGIN
	IF @year LIKE '%-%'
	BEGIN
		DECLARE @Fyear AS VARCHAR(50)

		SELECT @Fyear = data
		FROM dbo.Split('2024-2025', '-')
		WHERE Id = 1;

		DECLARE @FinYearStartDate AS VARCHAR(15) = @Fyear + '-01-01'
		DECLARE @FinancialYearStart DATE = '2024-04-01';-- Change this to the desired start date

		WITH Months
		AS (
			SELECT DATEADD(MONTH, number, @FinYearStartDate) AS MonthStart
			FROM master.dbo.spt_values
			WHERE type = 'P'
				AND number BETWEEN 0
					AND MONTH(GETDATE())-1  -- Generates tiill that month months
			)
		SELECT MonthStart
			,EOMONTH(MonthStart) AS MonthEnd
			,DATENAME(MONTH, MonthStart) AS [MonthNAme]
			,month(MonthStart) AS 'Month'
			,year(MonthStart) AS 'Year'
		INTO #tmpfmonth
		FROM Months;

		SELECT CM.Compliance_ID
			,CM.Compliance_Name
			,tm.[MonthNAme]
			,tm.Month
			,CM.DUE_DATE
			,tm.[Year]
		INTO #tmpfcmp
		FROM T0050_COMPLIANCE_MASTER CM
		CROSS JOIN #tmpfmonth tm
		WHERE CM.Compliance_Submition_Type = @submitionType AND Compliance_View_IN_Dash = 0 AND Cmp_ID = @Cmp_ID
		ORDER BY CM.Compliance_Name

		SELECT tr.*
			,CASE 
				WHEN Submission_Date IS NULL
					THEN CASE 
							WHEN tr.[Month] < month(GETDATE())
								AND YEAR(GETDATE()) = tr.[Year]
								THEN 'Due'
							ELSE 'pending'
							END
				ELSE 'paid'
				END AS 'status'
		FROM T0050_Repository_Master R
		RIGHT JOIN #tmpfcmp tr ON r.Month = tr.MonthNAme
			AND R.Compliance_ID = tr.Compliance_ID
			AND tr.[Year] = R.[Year]
	END
	ELSE
	BEGIN
		
		WITH cteDates (FirstOfMonth)
		AS (
			SELECT DATEADD(YEAR, DATEDIFF(YEAR, '19000101', @Year), '19000101') AS FirstOfMonth
			
			UNION ALL
			
			SELECT DATEADD(MONTH, 1, FirstOfMonth) AS FirstOfMonth
			FROM cteDates
			WHERE DATEPART(MONTH, FirstOfMonth) < 12
			)
		SELECT FirstOfMonth
			,DATENAME(MONTH, DATEADD(DAY, - 1, DATEADD(MONTH, 1, FirstOfMonth))) AS [MonthNAme]
			,month(DATEADD(DAY, - 1, DATEADD(MONTH, 1, FirstOfMonth))) AS 'Month'
			,month(DATEADD(DAY, - 1, DATEADD(MONTH, 2, FirstOfMonth))) AS 'DMonth'
			,DATEADD(DAY, - 1, DATEADD(MONTH, 1, FirstOfMonth)) AS LastOfMonth
		INTO #tmpmonth
		FROM cteDates;

		SELECT @Abranch as 'Branch'
		,@Year as 'CYear'
		,CM.Compliance_ID
			,CM.Compliance_Name
			,tm.[MonthNAme]
			,tm.Month
			,tm.DMonth
			,CM.DUE_DATE --
		INTO #tmpcmp
		FROM T0050_COMPLIANCE_MASTER CM
		CROSS JOIN #tmpmonth tm
		WHERE CM.Compliance_Submition_Type = @submitionType AND Compliance_View_IN_Dash = 0 AND Cmp_ID = @Cmp_ID
		ORDER BY CM.Compliance_Name

		--select * from #tmpcmp
		--/////////////////////////////////////// main query ///////////////////////
			--SELECT R.*,tr.*
			--,CONCAT(tr.DUE_DATE,'-',tr.[DMonth],'-',CASE WHEN tr.[DMonth] = 1 THEN 2025 ELSE 2024 END)C_Due_Date 
			--,CONVERT(DATETIME, CAST(tr.[DUE_DATE] as varchar(10)) + '-' + 
			--CASE WHEN LEN(CAST(tr.[Dmonth] as varchar(2))) = 1 then '0'+ CAST(tr.[Dmonth]  as varchar(2)) else CAST(tr.[Dmonth] as varchar(2)) END + '-'   
			--+ CASE WHEN CAST(tr.[month]  as varchar(2)) = '12' THEN @cyear ELSE R.Year END , 103)
			--,CASE       WHEN Submission_Date IS NULL       THEN 'Due'   
			--WHEN CAST(Submission_Date AS DATETIME) <= CONVERT(DATETIME, CAST(tr.[DUE_DATE] as varchar(10)) + '-' 
			--+ CASE WHEN LEN(CAST(tr.[Dmonth] as varchar(4))) = '1' then '0'+ CAST(tr.[Dmonth]  as varchar(4)) else CAST(tr.[Dmonth] as varchar(4)) END + '-'   
			-- + CASE WHEN CAST(tr.[month]  as varchar(2)) = 12 THEN @cyear ELSE R.Year END, 103)     
			--AND Branch_ID LIKE ('%73%')      
			--THEN 'Compliance'     
			--WHEN CAST(Submission_Date AS DATETIME) > CONVERT(DATETIME, CAST(tr.[DUE_DATE] as varchar(10)) + '-' + 
			--CASE WHEN LEN(CAST(tr.[Dmonth] as varchar(2))) = 1 then '0'+ CAST(tr.[Dmonth]  as varchar(2)) else CAST(tr.[Dmonth] as varchar(2)) END + '-'   
			--+ CASE WHEN CAST(tr.[month]  as varchar(2)) = '12' THEN @cyear ELSE R.Year END , 103)    
			--AND Branch_ID LIKE ('%73%')    
			--THEN 'Non Compliance' 
			--ELSE 'Due'      END AS 'status'   
			--FROM T0050_Repository_Master R    
			--RIGHT JOIN #tmpcmp tr ON r.Month = tr.MonthNAme     AND R.Compliance_ID = tr.Compliance_ID 
			--and R.Branch_ID LIKE ('%73%') and R.Year = tr.CYear 
		
		--//////////////////////////////////////////////////////////////////////////////
		
		set @qry =
		'SELECT R.*,tr.*,CONCAT(tr.DUE_DATE,''-'',tr.[DMonth],''-'',CASE WHEN tr.[DMonth] = 1 THEN ' + @cyear + ' ELSE ' +@Year  + ' END)C_Due_Date
			,CASE 
				WHEN Submission_Date IS NULL
					THEN ''Due''
				WHEN CAST(Submission_Date AS DATETIME) <= CONVERT(DATETIME, CAST(tr.[DUE_DATE] as varchar(10)) + ''-'' 
				+ CASE WHEN LEN(CAST(tr.[Dmonth] as varchar(4))) = 1 then ''0''+ CAST(tr.[Dmonth]  as varchar(4)) else CAST(tr.[Dmonth] as varchar(4)) END + ''-''
				 + CASE WHEN tr.[month]= 12 THEN ''' + @cyear + ''' ELSE R.Year END, 103)
				 AND Branch_ID LIKE (' + @Branch_ID +')
				 THEN ''Compliance'' 
				WHEN CAST(Submission_Date AS DATETIME) > CONVERT(DATETIME, CAST(tr.[DUE_DATE] as varchar(10)) + ''-''
				+ CASE WHEN LEN(CAST(tr.[Dmonth] as varchar(2))) = 1 then ''0''+ CAST(tr.[Dmonth]  as varchar(2)) else CAST(tr.[Dmonth] as varchar(2)) END + ''-'' 
				 + CASE WHEN tr.[month]  = 12 THEN ''' + @cyear + ''' ELSE R.Year END, 103)
				AND Branch_ID LIKE (' + @Branch_ID +') 
				THEN ''Non Compliance''
				ELSE ''Due''
				END AS ''status''
		FROM T0050_Repository_Master R
		RIGHT JOIN #tmpcmp tr ON r.Month = tr.MonthNAme
			AND R.Compliance_ID = tr.Compliance_ID and R.Branch_ID LIKE (' + @Branch_ID +') and R.Year = tr.CYear
			ORDER BY TR.Compliance_Name'
		
		--select @qry
		EXEC(@qry)
	END
END

ELSE IF @submitionType = 2
BEGIN
	IF @year LIKE '%-%'
	BEGIN
		select 123
	END
	ELSE
		BEGIN
			CREATE TABLE #tmpdata (
				id INT
				,cmpname VARCHAR(50)
				,cmpID INT
				,duemonth VARCHAR(10)
				,cyear VARCHAR(10)
				,Cyeartype tinyint
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
				,@cyeartype tinyint;

			DECLARE cursor_product CURSOR
			FOR
			SELECT DUE_DATE
				,DUE_Month
				,Compliance_Name
				,Compliance_ID
				,Compliance_Year_Type
			FROM t0050_compliance_master
			WHERE Compliance_Submition_Type = @submitionType AND Compliance_View_IN_Dash = 0  AND Cmp_ID = @Cmp_ID --and Compliance_Year_Type = 1 
				AND Compliance_View_IN_Dash = 0

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
				INSERT INTO #tmpdata (id,cmpname,cmpID,duemonth,cyear,Cyeartype)
				SELECT Id,@cmpname,@cmpID,CAST(data AS VARCHAR) duemonth
					,CASE WHEN Id > 2 AND Data < 8
							THEN @cyear
						ELSE @year
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
			----///////////////////////////////////////////// Tejas  ///////////////
			--SELECT tmp.cmpname AS 'Compliance_Name',CASE WHEN tmp.Cyeartype = 1 then 'Calendar Year' ELSE 'Financial Year'END Yeartype      
			--,'Q ' + CASE WHEN tmp.Cyeartype = 1 THEN CAST(datepart(q, CONVERT(DATE, (td.Duedate + '-' + CASE WHEN tmp.duemonth = 1 THEN '10'ELSE CAST((tmp.duemonth - 1) AS VARCHAR)END + '-' + tmp.cyear), 103))as varchar)         
			--ELSE CAST(datepart(q, CONVERT(DATE, (td.Duedate + '-' + CASE WHEN tmp.duemonth - 4 > 0 THEN CAST((tmp.duemonth - 4) AS VARCHAR) WHEN tmp.duemonth - 4 = 0 THEN CAST((12) AS VARCHAR)       
			--ELSE CAST((12 - 4) AS VARCHAR) END          + '-' + tmp.cyear), 103)           )as varchar) END  Qtr    
			--,CASE        WHEN tmp.duemonth = 1        THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + '10' + '-' + tmp.cyear, 103)) --'12'       
			--ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + CAST((tmp.duemonth - 3) AS VARCHAR) + '-' + tmp.cyear, 103))        END Qmonthstart      
			--,CASE        WHEN tmp.duemonth = 1        THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + '12' + '-' + tmp.cyear, 103)) --'12'      
			--ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + CAST((tmp.duemonth - 1) AS VARCHAR) + '-' + tmp.cyear, 103))        END Qmonthend     
			--,DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + tmp.duemonth + '-' + tmp.cyear, 103)) 'MonthNAme',RPm.Submission_Date  
			
			--,CONVERT(DATE, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)C_Due_Date,tmp.cmpID    
			--,RPm.Year , tmp.cyear
			--,CASE        WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATE, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)  and Rpm.Branch_ID LIKE ('%73%')  
			--THEN 'Compliance'       
			--WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)  and Rpm.Branch_ID LIKE ('%73%') 
			--THEN 'Non Compliance'       ELSE 'Due'       
			--END AS [Status]   
			--FROM #tmpdata tmp   
			--LEFT JOIN #Qdate td ON td.id = tmp.id AND td.cmpname = tmp.cmpname   
			--LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID    
			--AND  Rpm.Branch_ID LIKE ('%73%')  
			--AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + tmp.duemonth + '-' + tmp.cyear, 103))
			----AND RPm.Year = tmp.cyear
			--AND rpm.[year] = 2024 
			--//////////////////////////////////////////////////////////////////

		set	@qry = 
			 'SELECT tmp.cmpname AS ''Compliance_Name'',CASE WHEN tmp.Cyeartype = 1 then ''Calendar Year'' ELSE ''Financial Year''END Yeartype
				,''Q '' + CASE WHEN tmp.Cyeartype = 1 THEN CAST(datepart(q, CONVERT(DATE, (td.Duedate + ''-'' + CASE WHEN tmp.duemonth = 1 THEN ''10''ELSE CAST((tmp.duemonth - 1) AS VARCHAR)END + ''-'' + tmp.cyear), 103)
									)as varchar)
							ELSE CAST(datepart(q, CONVERT(DATE, (td.Duedate + ''-'' + 
							CASE WHEN tmp.duemonth - 4 > 0 THEN CAST((tmp.duemonth - 4) AS VARCHAR) WHEN tmp.duemonth - 4 = 0 THEN CAST((12) AS VARCHAR)
							ELSE CAST((12 - 4) AS VARCHAR) END
							 + ''-'' + tmp.cyear), 103)
									)as varchar)
							END  Qtr
				,CASE 
					WHEN tmp.duemonth = 1
						THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + ''10'' + ''-'' + tmp.cyear, 103)) --''12''
					ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + CAST((tmp.duemonth - 3) AS VARCHAR) + ''-'' + tmp.cyear, 103)) 
					END Qmonthstart
				,CASE 
					WHEN tmp.duemonth = 1
						THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + ''12'' + ''-'' + tmp.cyear, 103)) --''12''
					ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + CAST((tmp.duemonth - 1) AS VARCHAR) + ''-'' + tmp.cyear, 103)) 
					END Qmonthend
				,DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + tmp.duemonth + ''-'' + tmp.cyear, 103)) ''MonthNAme'',RPm.Submission_Date
				,CONCAT(td.Duedate,''-'',CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END,''-'', tmp.cyear)C_Due_Date,tmp.cmpID
				,CASE 
					WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATE, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103) 
					--AND RPm.Year = tmp.cyear' 
					+ ' and Rpm.Branch_ID LIKE (' +@Branch_ID +')
						THEN ''Compliance''
					WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103) 
					--AND RPm.Year = tmp.cyear' 
					+ ' and Rpm.Branch_ID LIKE (' + @Branch_ID + ')
						THEN ''Non Compliance''
					ELSE ''Due''
					END AS [Status]
			FROM #tmpdata tmp
			LEFT JOIN #Qdate td ON td.id = tmp.id AND td.cmpname = tmp.cmpname
			LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID 
			and Rpm.Branch_ID LIKE (' +@Branch_ID +  +')
			 AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + tmp.duemonth + ''-'' + tmp.cyear, 103))
			 --AND RPm.Year = tmp.cyear 
			 AND rpm.[year] = ' +@Year  
		
		--select @qry
		EXEC(@qry)
		
		END

	
END
ELSE IF @submitionType = 3
BEGIN
	CREATE TABLE #Hytmpdata (
				id INT
				,cmpname VARCHAR(50)
				,cmpID INT
				,duemonth VARCHAR(10)
				,cyear VARCHAR(10)
				,Cyeartype tinyint
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
				,@HYcyeartype tinyint;

			DECLARE cursor_product CURSOR
			FOR
			SELECT DUE_DATE
				,DUE_Month
				,Compliance_Name
				,Compliance_ID
				,Compliance_Year_Type
			FROM t0050_compliance_master
			WHERE Compliance_Submition_Type = @submitionType AND Compliance_View_IN_Dash = 0  AND Cmp_ID = @Cmp_ID --and Compliance_Year_Type = 1 
				

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
				INSERT INTO #HYtmpdata (id,cmpname,cmpID,duemonth,cyear,Cyeartype)
				SELECT Id,@Hycmpname,@HycmpID,CAST(data AS VARCHAR) duemonth
					,CASE WHEN Id >= 2 
					THEN @cyear
						ELSE @Year
						END AS cyear,@Hycyeartype
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
			--//////////////////////////////// Main Query/////////////////////////////////////////////////
			--SELECT tmp.cmpname AS 'Compliance_Name',CASE WHEN tmp.Cyeartype = 1 then 'Calendar Year' ELSE 'Financial Year'END Yeartype
			--	,'HY ' + CASE WHEN tmp.Cyeartype = 1 THEN 
			--										CASE WHEN (tmp.duemonth ) >= 7 THEN '1' ELSE '2' END
									
			--				ELSE CAST(datepart(q, CONVERT(DATE, (td.Duedate + '-' + 
			--				CASE WHEN tmp.duemonth - 6 >= 0 THEN CAST((tmp.duemonth - 9) AS VARCHAR) WHEN tmp.duemonth - 6 = 0 THEN CAST((12) AS VARCHAR)
			--				ELSE CAST((12 - 6) AS VARCHAR) END
			--				 + '-' + tmp.cyear), 103)
			--						)as varchar)
			--				END  Qtr
			--	,CASE 
			--		WHEN tmp.Cyeartype  = 1
			--			THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + CASE WHEN (tmp.duemonth - 6) >= 0 THEN CAST((tmp.duemonth - 6) AS VARCHAR) ELSE CAST((tmp.duemonth + 6) AS VARCHAR) END + '-' + tmp.cyear, 103))
			--			ELSE CASE WHEN (tmp.duemonth - 6) >= 0 THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + CAST((tmp.duemonth - 6) AS VARCHAR) + '-' + tmp.cyear, 103)) 
			--				ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + CAST((tmp.duemonth + 6) AS VARCHAR) + '-' + tmp.cyear, 103)) 
			--				END
			--		END Qmonthstart
			--	,CASE 
			--		WHEN tmp.duemonth = 1
			--			THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + '12' + '-' + tmp.cyear, 103)) --'12'
			--		ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + CAST((tmp.duemonth - 1) AS VARCHAR) + '-' + tmp.cyear, 103)) 
			--		END Qmonthend
			--	,DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + tmp.duemonth + '-' + tmp.cyear, 103)) 'MonthNAme'
			--	,CASE 
			--		WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)
			--		AND RPm.Year = @Year and Rpm.Branch_ID LIKE (@Branch_ID)	THEN 'Compliance'
			--		WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + '-' + CASE WHEN LEN(tmp.duemonth) = 1 then '0'+tmp.duemonth else tmp.duemonth END + '-' + tmp.cyear, 103)
			--		AND RPm.Year = @Year and Rpm.Branch_ID LIKE (@Branch_ID) THEN 'Non Compliance'
			--		ELSE 'Due'
			--		END AS [Status]
			--FROM #Hytmpdata tmp
			--LEFT JOIN #Hydate td ON td.id = tmp.id
			--	AND td.cmpname = tmp.cmpname
			--LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID
			--	AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + '-' + tmp.duemonth + '-' + tmp.cyear, 103))
			--/////////////////////////////////////////////////////////////////////////////////////////////
			set @qry = ' SELECT tmp.cmpname AS ''Compliance_Name'',CASE WHEN tmp.Cyeartype = 1 then ''Calendar Year'' ELSE ''Financial Year''END Yeartype
				,''HY'' + CASE WHEN tmp.Cyeartype = 1 THEN 
													CASE WHEN (tmp.duemonth ) >= 7 THEN ''1'' ELSE ''2'' END
									
							ELSE CAST(datepart(q, CONVERT(DATE, (td.Duedate + ''-'' + 
							CASE WHEN tmp.duemonth - 6 >= 0 THEN CAST((tmp.duemonth - 9) AS VARCHAR) WHEN tmp.duemonth - 6 = 0 THEN CAST((12) AS VARCHAR)
							ELSE CAST((12 - 6) AS VARCHAR) END
							 + ''-'' + tmp.cyear), 103)
									)as varchar)
							END  Qtr
				,CASE 
					WHEN tmp.Cyeartype  = 1
						THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + CASE WHEN (tmp.duemonth - 6) >= 0 THEN CAST((tmp.duemonth - 6) AS VARCHAR) ELSE CAST((tmp.duemonth + 6) AS VARCHAR) END + ''-'' + tmp.cyear, 103))
						ELSE CASE WHEN (tmp.duemonth - 6) >= 0 THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + CAST((tmp.duemonth - 6) AS VARCHAR) + ''-'' + tmp.cyear, 103)) 
							ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + CAST((tmp.duemonth + 6) AS VARCHAR) + ''-'' + tmp.cyear, 103)) 
							END
					END Qmonthstart
				,CASE 
					WHEN tmp.duemonth = 1
						THEN DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + ''12'' + ''-'' + tmp.cyear, 103)) --''12''
					ELSE DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + CAST((tmp.duemonth - 1) AS VARCHAR) + ''-'' + tmp.cyear, 103)) 
					END Qmonthend
				,DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + tmp.duemonth + ''-'' + tmp.cyear, 103)) ''MonthNAme'',RPm.Submission_Date
				,CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103)C_Due_Date
				,CASE 
					WHEN CAST(RPm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103)
					AND RPm.Year = tmp.cyear' 
					+ ' and Rpm.Branch_ID LIKE (' + @Branch_ID + ')	THEN ''Compliance''
					WHEN RPm.Submission_Date > CONVERT(DATETIME, td.Duedate + ''-'' + CASE WHEN LEN(tmp.duemonth) = 1 then ''0''+tmp.duemonth else tmp.duemonth END + ''-'' + tmp.cyear, 103)
					AND RPm.Year = tmp.cyear' 
					+ ' and Rpm.Branch_ID LIKE (' + @Branch_ID  + ') THEN ''Non Compliance''
					ELSE ''Due''
					END AS [Status]
			FROM #Hytmpdata tmp
			LEFT JOIN #Hydate td ON td.id = tmp.id
				AND td.cmpname = tmp.cmpname
			LEFT JOIN T0050_Repository_Master RPm ON RPm.Compliance_ID = tmp.cmpID and Rpm.Branch_ID LIKE (' +@Branch_ID +  +')
				AND RPm.Month = DATENAME(MONTH, CONVERT(DATE, td.Duedate + ''-'' + tmp.duemonth + ''-'' + tmp.cyear, 103))
				AND RPm.Year = tmp.cyear '

		EXEC(@qry)
END
ELSE IF @submitionType = 4
BEGIN	

	
	--////////////////// MAin Query ///////////////////////////
	--select Cmp.Compliance_Name , CONCAT('Year' , ' (',  CASE WHEN Cmp.Compliance_Year_Type = 0 THEN 'April To March' ELSE 'January To December' END , ')')Qtr
	--,RM.Submission_Date ,Compliance_Year_Type,RM.Branch_ID
	--	,CONVERT(DATETIME, CONCAT(Cmp.DUE_DATE , '-' , CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then '0' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END , '-' , 2025), 103) as C_Due_Date
	--,CASE WHEN   --Rm.Branch_ID LIKE (@Branch_ID) and
	-- CAST(Rm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, Cmp.DUE_DATE + '-' + CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then '0' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END + '-' + @cyear, 103)  THen 
	--								'Compliance' 
	--WHEN  --Rm.Branch_ID LIKE (@Branch_ID) and
	-- CAST(Rm.Submission_Date AS DATETIME) > CONVERT(DATETIME, Cmp.DUE_DATE + '-' + CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then '0' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END + '-' + @cyear, 103)  THen 
	--								'Non Compliance' 
	--								ELSE 'Due' END status 
	--								from t0050_compliance_master Cmp
	--LEFT JOIN 
	--(
	--	select RPM.Compliance_ID,RPM.[Year],(RPM.Submission_Date)Submission_Date,rpm.Branch_ID
	--	from T0050_Repository_Master RPM
	--	INNER JOIN (
	--	select RMC.Compliance_ID,RMC.[Year],MAX(RMC.Submission_Date)Submission_Date from T0050_Repository_Master RMC
	--	where RMC.[Year] = 2024 and RMC.Compliance_ID in (select Compliance_ID from T0050_COMPLIANCE_MASTER where Cmp_ID = 1 and Compliance_Submition_Type = 4 and Compliance_View_IN_Dash = 0)
	--	group by RMC.Compliance_ID,RMC.[Year]
	--	) RML ON RML.Compliance_ID = RPM.Compliance_ID  AND RMl.Submission_Date = RPM.Submission_Date 
	--)
	--RM On RM.Compliance_ID = CMp.Compliance_ID AND RM.[Year] = @Year
	--where Compliance_Submition_Type = @submitionType AND cmp.Compliance_View_IN_Dash = 0 AND cmp.Cmp_ID = @Cmp_ID
	--order by RM.[Year]
	--////////////////////////////////////////////////////////////////////
	
	set @qry =
	'select Cmp.Compliance_Name , CONCAT(''Year '' , ''('',  CASE WHEN Cmp.Compliance_Year_Type = 0 THEN ''April To March'' ELSE ''January To December'' END , '')'')Qtr
	,RM.Submission_Date ,Compliance_Year_Type
	,CONVERT(DATETIME, CONCAT(Cmp.DUE_DATE , ''-'' , CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then ''0'' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END , ''-'' , ' + @cyear + '), 103) as C_Due_Date
	,CASE WHEN Rm.Branch_ID LIKE (' + @Branch_ID +')
	and CAST(Rm.Submission_Date AS DATETIME) <= CONVERT(DATETIME, CONCAT(Cmp.DUE_DATE , ''-'' , CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then ''0'' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END , ''-'' , ' + @cyear + '), 103)  THen 
									''Compliance'' 
	WHEN Rm.Branch_ID LIKE (' + @Branch_ID + ') 
	and CAST(Rm.Submission_Date AS DATETIME) > CONVERT(DATETIME, CONCAT(Cmp.DUE_DATE , ''-'' , CASE WHEN LEN(Cmp.DUE_MONTH) = 1 then ''0'' +Cmp.DUE_MONTH else Cmp.DUE_MONTH END , ''-'' , ' + @cyear + '), 103)  THen 
									''Non Compliance'' 
									ELSE ''Due'' END status from t0050_compliance_master Cmp
	LEFT JOIN 
	(
		select RPM.Compliance_ID,RPM.[Year],(RPM.Submission_Date)Submission_Date,rpm.Branch_ID
		from T0050_Repository_Master RPM
		INNER JOIN (
		select RMC.Compliance_ID,RMC.[Year],MAX(RMC.Submission_Date)Submission_Date from T0050_Repository_Master RMC
		where RMC.[Year] = ''' + @Year +''' and RMC.Compliance_ID in (select Compliance_ID from T0050_COMPLIANCE_MASTER where Cmp_ID = 1 and Compliance_Submition_Type = 4 and Compliance_View_IN_Dash = 0)
		group by RMC.Compliance_ID,RMC.[Year]
		) RML ON RML.Compliance_ID = RPM.Compliance_ID  AND RMl.Submission_Date = RPM.Submission_Date 
	)
	RM On RM.Compliance_ID = CMp.Compliance_ID AND RM.[Year] = ' + @Year + ' 
	 where Compliance_Submition_Type = '  + @submitionType + 'AND cmp.Compliance_View_IN_Dash = 0 AND cmp.Cmp_ID = ' + @Cmp_ID +
	 ' order by RM.[Year]'
	--select (@qry)
	EXEC(@qry)
END
ELSE IF @submitionType = 5
BEGIN	
	select * from T0030_BRANCH_MASTER where @Branch_ID = @Branch_ID and Cmp_ID = @cmpID 
END

IF OBJECT_ID('tempdb..#tmpmonth') IS NOT NULL
	drop table #tmpmonth


IF OBJECT_ID('tempdb..#tmpfmonth') IS NOT NULL
	drop table #tmpfmonth	

IF OBJECT_ID('tempdb..#tmpcmp') IS NOT NULL
	drop table #tmpcmp
		
IF OBJECT_ID('tempdb..#tmpfcmp') IS NOT NULL
	drop table #tmpfcmp
		

IF OBJECT_ID('tempdb..#tmpdata') IS NOT NULL
	drop table #tmpdata


IF OBJECT_ID('tempdb..#Hytmpdata') IS NOT NULL
	drop table #Hytmpdata

IF OBJECT_ID('tempdb..#Qdate') IS NOT NULL
	drop table #Qdate


IF OBJECT_ID('tempdb..#Hydate') IS NOT NULL
	drop table #Hydate

END

