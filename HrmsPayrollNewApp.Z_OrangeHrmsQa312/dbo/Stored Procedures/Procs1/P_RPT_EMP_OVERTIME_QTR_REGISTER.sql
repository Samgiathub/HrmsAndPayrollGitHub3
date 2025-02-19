

-----------------------------------------------

--ADDED JIMIT 30062018------
---Overtime Register ENPAY---
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_OVERTIME_QTR_REGISTER]      
     @COMPANY_ID	NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		NUMERIC	
	,@GRADE_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@CAT_ID        NUMERIC = 0	
	,@SEGMENT_ID NUMERIC = 0 
	,@VERTICAL NUMERIC = 0 
	,@SUBVERTICAL NUMERIC = 0 
	,@SUBBRANCH NUMERIC = 0 
	,@SUMMARY VARCHAR(MAX)=''
	,@PBRANCH_ID VARCHAR(200) = '0'
	--,@ORDER_BY   VARCHAR(30) = 'CODE'     
    
    
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)	
	EXEC SP_RPT_FILL_EMP_CONS	@COMPANY_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRADE_ID,@TYPE_ID,@DEPT_ID,
								@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0  
								
	
	
	CREATE TABLE #OVERTIME_REGISTER
	(
		
	    CMP_ID			NUMERIC(18,0)
	   ,EMP_ID			NUMERIC(18,0) PRIMARY KEY
	   ,CENTER_CODE		NVARCHAR(100)
	   ,EMP_CODE	VARCHAR(50)
	   ,EMP_FULL_NAME	VARCHAR(250)	   
	   ,DEPARTMENT		NVARCHAR(100)	   
	   ,BRANCH_ID       NUMERIC(18,0)
	   ,BRANCH_NAME	    VARCHAR(250)	   
	   ,DESIGNATION		NVARCHAR(100)
	   ,GRADE			NVARCHAR(100)
	   ,CATEGORY		NVARCHAR(100)
	   ,DIVISION		NVARCHAR(100)
	   ,SUB_BRANCH		NVARCHAR(100)
	   ,SEGMENT_NAME	NVARCHAR(100)
	   
	)
	
	
	INSERT INTO #OVERTIME_REGISTER 
	SELECT		E.CMP_ID,E.EMP_ID,CC.CENTER_CODE,E.ALPHA_EMP_CODE AS EMP_CODE ,ISNULL(E.EMPNAME_ALIAS_SALARY,E.EMP_FULL_NAME),
				DM.DEPT_NAME,BM.BRANCH_ID,BM.BRANCH_NAME,
				DNM.DESIG_NAME,GA.GRD_NAME,CT.CAT_NAME AS CATEGORY,VT.VERTICAL_NAME,SB.SUBBRANCH_NAME,
				BSG.SEGMENT_NAME
	FROM		T0080_EMP_MASTER E WITH (NOLOCK)	INNER JOIN
				( 
					SELECT	I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,
							I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID 
					FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
							( 
								SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
								FROM	T0095_INCREMENT WITH (NOLOCK)
								WHERE	INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @COMPANY_ID
								GROUP BY EMP_ID 
							 ) QRY ON	I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID 
				 )INC_QRY ON E.EMP_ID = INC_QRY.EMP_ID INNER JOIN 
				 #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID LEFT OUTER JOIN 
				 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC_QRY.BRANCH_ID = BM.BRANCH_ID	LEFT OUTER JOIN 
				 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INC_QRY.DEPT_ID = DM.DEPT_ID	left outer join 
				 T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID left outer join 
				 T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID LEFT OUTER JOIN 
				 T0030_CATEGORY_MASTER CT WITH (NOLOCK) on CT.Cat_ID=Inc_Qry.Cat_Id LEFT OUTER JOIN 
				 T0040_VERTICAL_SEGMENT VT WITH (NOLOCK) ON VT.VERTICAL_ID=INC_QRY.VERTICAL_ID LEFT OUTER JOIN 
				 T0050_SUBVERTICAL ST WITH (NOLOCK) ON ST.SUBVERTICAL_ID=INC_QRY.SUBVERTICAL_ID LEFT OUTER JOIN 
				 T0050_SUBBRANCH SB WITH (NOLOCK) ON SB.SUBBRANCH_ID=INC_QRY.SUBBRANCH_ID LEFT OUTER JOIN 
				 T0040_BUSINESS_SEGMENT BSG WITH (NOLOCK) ON BSG.SEGMENT_ID=INC_QRY.SEGMENT_ID LEFT OUTER JOIN 
				 T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.CENTER_ID = INC_QRY.CENTER_ID LEFT OUTER JOIN 
				 T0040_GRADE_MASTER GA WITH (NOLOCK) ON INC_QRY.GRD_ID = GA.GRD_ID--INNER JOIN 
				 --T0200_MONTHLY_SALARY MS ON MS.EMP_ID = EC.EMP_ID AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE) AND 
				 --YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) AND ISNULL(IS_FNF,0) = 0
				
				
			----------------------GETTING OT HOURS------------------------
			DECLARE @TEST AS VARCHAR(4000)
			--SET @TEST = 'ALTER TABLE  #OVERTIME_REGISTER  ADD ARREAR_OT_HOURS VARCHAR(20) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS;'			
			--EXEC(@TEST)
			
			DECLARE @DURATION AS VARCHAR(MAX)
			DECLARE @FOR_DATE AS VARCHAR(10)
			DECLARE @INSERT_WEEKDAY VARCHAR(MAX)
			DECLARE @VALUE_WEEKDAY VARCHAR(MAX)
			DECLARE @WEEKDAY VARCHAR(2)
				
			DECLARE @CODE AS VARCHAR(20)
			DECLARE @QRY AS VARCHAR(4000)
			DECLARE	@FORDATE AS NUMERIC(18,0)
			
			DECLARE @MONTH  AS VARCHAR(5)
			DECLARE @YEAR	AS VARCHAR(5)
			
			Declare @Temp_to_date dateTime
			set @Temp_to_date = @FROM_DATE
			
			SET @MONTH = MONTH(@FROM_DATE)
			SET @YEAR = YEAR(@FROM_DATE)
			

			SET @INSERT_WEEKDAY = ''
			 SET @VALUE_WEEKDAY = ''
			--/////////////////////// Added by tejas //////////////////////////////////
							DECLARE @StartDate  DATETIME = @FROM_DATE,  
							@EndDate    DATETIME = @TO_DATE,
							@str varchar(max) = '',
							@tblstr nvarchar(max)= '';
							
							CREATE Table #temp(
							MonthName nvarchar(10),
							QTR int,
							[month] int,
							[low] int,
							[high] int,
							[year] int
							)

							IF YEAR(@StartDate) = YEAR(@EndDate) 
							BEGIN
								insert into #temp
								SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)) AS [MonthName],DATEPART(Q,DATEADD(MONTH, x.number, @StartDate))QTR,MONTH(DATEADD(MONTH, x.number, @StartDate))as 'month',x.[low]
								,y.[high]
								,CASE WHEN MONTH(DATEADD(MONTH, x.number, @StartDate)) = 12 THEN 
									CASE WHEN y.number > 0 THEN YEAR(DATEADD(YEAR, (y.number)-1, @StartDate))
									ELSE YEAR(DATEADD(YEAR, (y.number), @StartDate))END
								ELSE YEAR(DATEADD(YEAR, (y.number), @StartDate))
								END as 'year'
								FROM    master.dbo.spt_values x
								INNER JOIN master.dbo.spt_values y ON  x.[status] = y.[status] 
								WHERE   x.type = 'P' and y.type = 'P'          
								AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)  
								AND     y.number <= DATEDIFF(YEAR, @StartDate, @EndDate);
							END
							ELSe 
							BEGIN
								insert into #temp
								SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)) AS [MonthName],DATEPART(Q,DATEADD(MONTH, x.number, @StartDate))QTR,MONTH(DATEADD(MONTH, x.number, @StartDate))as 'month',x.[low]
								,y.[high]
								,CASE WHEN MONTH(DATEADD(MONTH, x.number, @StartDate)) = 12 THEN 
								CASE WHEN y.number > 0 THEN YEAR(DATEADD(YEAR, (y.number)-1, @StartDate))
								ELSE YEAR(DATEADD(YEAR, (y.number), @StartDate))END
								ELSE YEAR(DATEADD(YEAR, (y.number), @StartDate))
								END as 'year'
								FROM    master.dbo.spt_values x
								INNER JOIN master.dbo.spt_values y ON  x.[low] = y.[high]  
								WHERE   x.type = 'P' and y.type = 'P'          
								AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)  
								AND     y.number <= DATEDIFF(YEAR, @StartDate, @EndDate);
							ENd
							
							IF YEAR(@StartDate) = YEAR(@EndDate) 
							BEGIN
								insert into #temp (QTR,MonthName,[month],[year])
									SELECT  DISTINCT DATEPART(Q,DATEADD(MONTH, x.number, @StartDate)) AS QTR , 'Z Q' + CAST(DATEPART(Q,DATEADD(MONTH, x.number, @StartDate))as varchar) + ' ' +
									CASE WHEN MONTH(DATEADD(MONTH, x.number, @StartDate)) = 12 THEN CAST(YEAR(DATEADD(YEAR, (y.number)-1, @StartDate))AS varchar)
									ELSE CAST(YEAR(DATEADD(YEAR, (y.number), @StartDate)) as varchar)
									END 
									 AS [MonthName] 
									,15,CASE WHEN MONTH(DATEADD(MONTH, x.number, @StartDate)) = 12 THEN CAST(YEAR(DATEADD(YEAR, (y.number)-1, @StartDate))AS varchar)
									ELSE CAST(YEAR(DATEADD(YEAR, (y.number), @StartDate)) as varchar)
									END
									FROM    master.dbo.spt_values x  
									INNER JOIN master.dbo.spt_values y ON x.[status] = y.[status] 
									WHERE   x.type = 'P'   and y.type = 'p'       
									AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)  
									AND     y.number <= DATEDIFF(YEAR, @StartDate, @EndDate);
							END
							ELSE
							BEGIN
								insert into #temp (QTR,MonthName,[month],[year])
									SELECT  DISTINCT DATEPART(Q,DATEADD(MONTH, x.number, @StartDate)) AS QTR , 'Z Q' + CAST(DATEPART(Q,DATEADD(MONTH, x.number, @StartDate))as varchar) + ' ' +
									CASE WHEN MONTH(DATEADD(MONTH, x.number, @StartDate)) = 12 THEN CAST(YEAR(DATEADD(YEAR, (y.number)-1, @StartDate))AS varchar)
									ELSE CAST(YEAR(DATEADD(YEAR, (y.number), @StartDate)) as varchar)
									END 
									 AS [MonthName] 
									,15,CASE WHEN MONTH(DATEADD(MONTH, x.number, @StartDate)) = 12 THEN CAST(YEAR(DATEADD(YEAR, (y.number)-1, @StartDate))AS varchar)
									ELSE CAST(YEAR(DATEADD(YEAR, (y.number), @StartDate)) as varchar)
									END
									FROM    master.dbo.spt_values x  
									INNER JOIN master.dbo.spt_values y ON x.[low] = y.[high]  
									WHERE   x.type = 'P'   and y.type = 'p'       
									AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate)  
									AND     y.number <= DATEDIFF(YEAR, @StartDate, @EndDate);
							END
							
							Delete from #temp where ([Year] < (YEAR(@STARTDATE)) OR [YEAR] > (YEAR(@EndDate)))
							update #temp set [MonthName] =  LEFT([MonthName],3)+ '-' + CAST([year]as varchar)  from #temp where [month] <=12
							
							--select * from #temp

							select  ROW_NUMBER() OVER(ORDER BY [year],QTR ASC) AS Row#,REPLACE(REPLACE([MonthName],'Z','Total'),' ','_')as [MonthName],[MONTH],QTR,[YEAR] INTO #TMP1 from #temp  order by [year],QTR,[month]
							
							--select * from #TMP1
							
							--DECLARE @Counter INT 
							--SET @Counter=1
							--WHILE ( @Counter <= (select COUNT(1) from #TMP1))
							--BEGIN
							--	set @str = ''
							--   select  @str = 'ALTER TABLE #OVERTIME_REGISTER ADD [' + + ColumnName + '] INT NULL'   from #TMP1 where Row# = @Counter
							--   --select @str
							--   EXEC(@str)
							--    SET @Counter  = @Counter  + 1
							--END
							
							select [MonthName],[month],[year],E.EMP_ID,QTR
							into #TMP3
							from #TMP1 t cross join #EMP_CONS E

								ALTER TAble #Tmp3 add [Hours] NUMERIC(18,2) default 0 
							
                                        

                                        Update T set
                                        T.[Hours] = DBO.f_return_sec(A1.Hrs)
                                        from #TMP3 T inner join 
                                        (select a.Hrs,a.Emp_ID,a.[month] from 
                                        (				
                                                        --SELECT OTA.EMP_ID,[month], REPLACE(dbo.f_return_HOURs(Approved_OT_Hours  + Approved_WO_OT_Hours + Approved_HO_OT_Hours) ,':','.')as Hrs
														SELECT OTA.EMP_ID,[month], REPLACE(dbo.f_return_HOURs(SUM(dbo.f_return_sec(format((CAST(Approved_OT_Hours as decimal(10,2))),'0000.00')))+SUM(dbo.f_return_sec(format((CAST(Approved_WO_OT_Hours as decimal(10,2))),'0000.00')))+SUM(dbo.f_return_sec(format((CAST(Approved_HO_OT_Hours as decimal(10,2))),'0000.00')))),':','.')as Hrs
                                                                FROM #TMP3 Tmp 
                                                                INNER JOIN T0160_OT_APPROVAL OTA WITH (NOLOCK)  ON Tmp.EMP_ID = OTA.Emp_ID and Tmp.[month] = Month(OTA.For_Date) and Tmp.[year] = year(OTA.For_Date)  
                                                                WHERE  Is_Approved=1 AND MONTH(FOR_DATE) IN(Tmp.[month]) and YEAR(FOR_DATE)= Tmp.[year]   
                                                                group by OTA.EMP_ID,Tmp.[month]
                                        ) a ) a1 on T.EMP_ID = A1.Emp_ID and T.month = a1.month


										UPDAte t1
										set [Hours] = Hrs
										from #TMP3 t1 inner join (
											select EMP_ID,QTR,SUM([Hours]) as 'Hrs'
											from #TMP3
											Group by EMP_ID,QTR
										) t2 on t1.EMP_ID = t2.EMP_ID and t1.QTR = t2.QTR
										where t1.[month] = 15

                                        select *,REPLACE(dbo.f_return_HOURs(hours),':','.')as hhr into #tmp2 from #TMP3
										SELECT @str = @str + '[' + [MonthName] + '],' FROM #TMP1 
										set @str = SUBSTRING(@str,0,LEN(@str))

CREATE TABLE #OT
(
	Emp_ID INT NULL
)
							DECLARE @Counter INT,@clr nvarchar(max) 

							SET @Counter=1
							WHILE ( @Counter <= (select COUNT(1) from #TMP1))
							BEGIN
								set @clr = ''
							   select  @clr = 'ALTER TABLE #OT ADD [' + + [monthname] + '] nvarchar(MAX) NULL'   from #TMP1 where Row# = @Counter
							   --select @str
							   EXEC(@clr)
							    SET @Counter  = @Counter  + 1
							END
set @tblstr ='INSERT INTO #OT SELECT *  FROM (SELECT [monthname],hhr,Emp_ID FROM #Tmp2 ) t PIVOT( MAX(hhr) FOR [monthname] IN ('+ @str +' )) AS pivot_table'
EXEC(@tblstr)
							
						
--							DECLARE @StartDate  DATETIME = '2024-05-01 00:00:00',  
--        @EndDate    DATETIME = '2024-06-030 00:00:00',
--		@str varchar(max) = '',
--		@tblstr varchar(max)= '';  
  
--SELECT  DATENAME(MONTH, DATEADD(MONTH, x.number, @StartDate)) AS MonthName,MONTH(DATEADD(MONTH, x.number, @StartDate))as 'month'  into #temp  
--FROM    master.dbo.spt_values x  
--WHERE   x.type = 'P'          
--AND     x.number <= DATEDIFF(MONTH, @StartDate, @EndDate);  


--ALTER TABLE #temp ADD [Hours] NVARCHAR(5) NOT NULL DEFAULT ('00.00')
--select  ROW_NUMBER() OVER(ORDER BY [month],[MonthName] ASC) AS Row#,REPLACE(REPLACE(MonthName,'Z','TOT'),' ','_')as ColumnName,[MONTH],[Hours] INTO #TMP1 from #temp 
----select * from #TMP1
--DECLARE @Counter INT 
--SET @Counter=1
--WHILE ( @Counter <= (select COUNT(1) from #TMP1))
--BEGIN
--	update #TMP1 set [Hours] = (SELECT REPLACE(dbo.f_return_HOURs(SUM(dbo.f_return_sec(format((CAST(Approved_OT_Hours as decimal(10,2))),'00.00')))+SUM(dbo.f_return_sec(format((CAST(Approved_WO_OT_Hours as decimal(10,2))),'00.00')))+SUM(dbo.f_return_sec(format((CAST(Approved_HO_OT_Hours as decimal(10,2))),'00.00')))),':','.')
--						FROM #TMP1 Tmp 
--						INNER JOIN T0160_OT_APPROVAL OTA WITH (NOLOCK)  ON Tmp.month = MONTH(OTA.For_Date)
--						WHERE Emp_ID=274 AND Is_Approved=1 AND MONTH(FOR_DATE) IN(Tmp.[month]) and YEAR(FOR_DATE)='2024'  and Tmp.Row# = @Counter)
--	where Row# = @Counter 
  
--    SET @Counter  = @Counter  + 1
--END
--select * from #TMP1

--drop table #temp
--drop table #TMP1
--drop table #TMP2
			
			----------------------------------------ENDED----------------------------------------------------
			
			CREATE TABLE #DATA         
			(         
			   EMP_ID   NUMERIC ,         
			   FOR_DATE DATETIME,        
			   DURATION_IN_SEC NUMERIC,        
			   SHIFT_ID NUMERIC ,        
			   SHIFT_TYPE NUMERIC ,        
			   EMP_OT  NUMERIC ,        
			   EMP_OT_MIN_LIMIT NUMERIC,        
			   EMP_OT_MAX_LIMIT NUMERIC,        
			   P_DAYS  NUMERIC(12,3) DEFAULT 0,        
			   OT_SEC  NUMERIC DEFAULT 0  ,
			   IN_TIME DATETIME,
			   SHIFT_START_TIME DATETIME,
			   OT_START_TIME NUMERIC DEFAULT 0,
			   SHIFT_CHANGE TINYINT DEFAULT 0,
			   FLAG INT DEFAULT 0,
			   WEEKOFF_OT_SEC  NUMERIC DEFAULT 0,
			   HOLIDAY_OT_SEC  NUMERIC DEFAULT 0,
			   CHK_BY_SUPERIOR NUMERIC DEFAULT 0,
			   IO_TRAN_ID	   NUMERIC DEFAULT 0, 
			   OUT_TIME DATETIME,
			   SHIFT_END_TIME DATETIME,			
			   OT_END_TIME NUMERIC DEFAULT 0,	
			   WORKING_HRS_ST_TIME TINYINT DEFAULT 0, 
			   WORKING_HRS_END_TIME TINYINT DEFAULT 0, 
			   GATEPASS_DEDUCT_DAYS NUMERIC(18,2) DEFAULT 0 
		   )    
		   
		  
		--DECLARE @OT_HOURS	AS NUMERIC(18,2)
		--EXEC SP_CALCULATE_PRESENT_DAYS	@COMPANY_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRADE_ID,@TYPE_ID,
		--								@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,4
			 
		
	IF OBJECT_ID('tempdb..#EMP_GEN_SETTINGS') IS NULL
		BEGIN
			CREATE TABLE #EMP_GEN_SETTINGS
			(
				EMP_ID		NUMERIC PRIMARY KEY,
				BRANCH_ID	NUMERIC,
				Is_Auto_OT	tinyint
			) 
		END

		INSERT INTO #EMP_GEN_SETTINGS
		SELECT  EMP_ID,EC.BRANCH_ID,G.is_OT_Auto_Calc
		FROM	#EMP_CONS EC INNER JOIN
				T0040_GENERAL_SETTING G WITH (NOLOCK) ON EC.BRANCH_ID=G.BRANCH_ID INNER JOIN
				(
					SELECT	MAX(GEN_ID) AS GEN_ID,G1.BRANCH_ID
					FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK) INNER JOIN 
							(
								SELECT	MAX(FOR_DATE) AS FOR_DATE , BRANCH_ID
								FROM	T0040_GENERAL_SETTING G2 WITH (NOLOCK)
								WHERE	G2.For_Date <= @TO_DATE
								GROUP	BY G2.Branch_ID
							) G2 ON G1.Branch_ID=G2.Branch_ID AND G1.For_Date=G2.FOR_DATE
					GROUP BY G1.Branch_ID
				) G1 ON G.Gen_ID=G1.GEN_ID AND G.Branch_ID=G1.Branch_ID

				
		
		
		set @Temp_to_date = @FROM_DATE	
		SET @FOR_DATE = DAy(@FROM_DATE)
	
		--WHILE @Temp_to_date <= @To_date
		--	BEGIN
											
		--		--SET @FOR_DATE =  @FORDATE 
		--		SET @INSERT_WEEKDAY = '[' + @FOR_DATE + '-' +  LEFT(DATENAME(MONTH,@Temp_to_date),3) + ']'
		--		SET @MONTH = Month(@Temp_to_date)
		--		SET @YEAR = year(@Temp_to_date)
																						
				
				
		--	END		
			 
			 SELECT ROW_NUMBER() Over(ORDER by OT.Emp_Id) SR_NO,OT.CENTER_CODE,OT.EMP_CODE ,OT.EMP_FULL_NAME,OT.DEPARTMENT ,OT.BRANCH_ID ,OT.BRANCH_NAME ,OT.DESIGNATION ,OT.GRADE	,OT.CATEGORY ,OT.DIVISION ,OT.SUB_BRANCH ,OT.SEGMENT_NAME,PT.* 
			 FROM #OVERTIME_REGISTER OT
			 INNER JOIN #OT PT ON OT.EMP_ID = PT.Emp_ID
			 Order By OT.EMP_ID
								 
	
	

