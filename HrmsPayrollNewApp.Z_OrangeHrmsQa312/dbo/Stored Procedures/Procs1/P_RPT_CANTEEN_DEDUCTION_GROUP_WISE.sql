

-- =============================================
-- Author:		<Author,,Jimit Soni>
-- Create date: <Create Date,,28112019>
-- Description:	<Description,,For Canteen Report Department Wise>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_RPT_CANTEEN_DEDUCTION_GROUP_WISE]
	 @CMP_ID			NUMERIC(18,0)	
	,@FROM_DATE			DATETIME
	,@TO_DATE		    DATETIME	
	,@BRANCH_ID			VARCHAR(MAX) = ''
	,@CAT_ID			VARCHAR(MAX) = ''
	,@GRD_ID			VARCHAR(MAX) = ''
	,@TYPE_ID			VARCHAR(MAX) = ''
	,@DEPT_ID			VARCHAR(MAX) = ''
	,@DESIG_ID			VARCHAR(MAX) = ''
	,@EMP_ID			NUMERIC  = 0
	,@CONSTRAINT		VARCHAR(MAX) = ''
	,@SALARY_CYCLE_ID	NUMERIC = NULL
	,@SEGMENT_ID		VARCHAR(MAX) = ''	
	,@VERTICAL_ID		VARCHAR(MAX) = ''	 
	,@SUBVERTICAL_ID	VARCHAR(MAX) = ''	
	,@SUBBRANCH_ID		VARCHAR(MAX) = ''
	,@CANTEEN_ID		VARCHAR(MAX) = ''
	,@DEVICEIPS			VARCHAR(MAX) = ''
	,@GROUPBY			VARCHAR(2) = ''
	,@FORMAT			Int  = 2            --Group Wise - Meal Wise
												--Meal Wise -  Group Wise
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

				SET @FROM_DATE = CONVERT(DATETIME,CONVERT(CHAR(10), @FROM_DATE, 103), 103);
				SET @TO_DATE= CONVERT(DATETIME,CONVERT(CHAR(10), @TO_DATE, 103) + ' 23:59:59', 103);

	
				CREATE TABLE #EMP_CONS 
				(      
					EMP_ID NUMERIC ,     
					BRANCH_ID NUMERIC,
					INCREMENT_ID NUMERIC    
				) 

				IF @CONSTRAINT = '' AND @EMP_ID > 0
					SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(10))
	
				EXEC DBO.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,'1900-01-01',@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,@SALARY_CYCLE_ID,@SEGMENT_ID,@VERTICAL_ID,
															@SUBVERTICAL_ID,@SUBBRANCH_ID,0,0,0,'0',0,0    
	
	
				DELETE E FROM #EMP_CONS E INNER JOIN  T0080_EMP_MASTER EM ON E.EMP_ID=EM.EMP_ID
				WHERE ISNULL(EM.ENROLL_NO,0) = 0

		
				ALTER TABLE  #EMP_CONS ADD ENROLL_NO NUMERIC(18,0);
				ALTER TABLE  #EMP_CONS ADD GRADE NUMERIC(18,0);
				UPDATE	#EMP_CONS 
				--SET		ENROLL_NO = E.ENROLL_NO,GRADE=I.GRD_ID
				SET		ENROLL_NO = E.Emp_Canteen_Code,GRADE=I.GRD_ID -- Changed by Hardik 08/01/2019 for Backbone client as per discussion with Chintan, As per canteen code Report should be come
				FROM	T0080_EMP_MASTER E 
						INNER JOIN  T0095_INCREMENT I  ON E.EMP_ID = I.EMP_ID
						INNER JOIN (
										SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID
										FROM	T0095_INCREMENT WITH (NOLOCK)   
										WHERE	INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @CMP_ID
										GROUP BY EMP_ID
									) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID 
				 WHERE	#EMP_CONS.EMP_ID=E.EMP_ID AND E.CMP_ID=@CMP_ID

				--RETRIEVING CANTEEN DETAILS IN TEMP TABLE.
				SELECT	M.CMP_ID,M.CNT_ID,CAST(FROM_TIME AS DATETIME) AS FROM_TIME, CAST(TO_TIME AS DATETIME) AS TO_TIME,
						EFFECTIVE_DATE,AMOUNT,GRD_ID,IP_ID 
						,D.SUBSIDY_AMOUNT,D.TOTAL_AMOUNT
				INTO	#CANTEEN1
				FROM	DBO.T0050_CANTEEN_MASTER M WITH (NOLOCK)
						INNER JOIN T0050_CANTEEN_DETAIL D WITH (NOLOCK) ON M.CNT_ID=D.CNT_ID AND M.CMP_ID=D.CMP_ID 
				WHERE	D.EFFECTIVE_DATE <= @TO_DATE AND M.CMP_ID=@CMP_ID


				IF OBJECT_ID('TEMPDB..#DATES') IS NOT NULL
					DROP TABLE #DATES

				CREATE TABLE #DATES
				(
					FOR_DATES DATE
				)

		
				INSERT	INTO #DATES
				SELECT  TOP (DATEDIFF(DAY, @FROM_DATE, @TO_DATE) + 1)
						Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FROM_DATE)
				FROM    sys.all_objects a
						CROSS JOIN sys.all_objects b;	


				--FILTERING CANTEEN DETAILS
				IF (@CANTEEN_ID <> '' AND @CANTEEN_ID <> '0')
				BEGIN
						DELETE FROM #CANTEEN1 WHERE CNT_ID NOT IN (SELECT DATA FROM DBO.SPLIT(@CANTEEN_ID, '#'))
				END	

				SELECT	ROW_NUMBER() OVER(ORDER BY I.IO_TRAN_ID) AS ROWID,E.EMP_ID,T.*,I.IO_DATETIME,I.IP_ADDRESS,IP.DEVICE_NO, IP.DEVICE_NAME,I.IO_TRAN_ID
				INTO	#TEMP
				FROM	DBO.T9999_DEVICE_INOUT_DETAIL I WITH (NOLOCK) 
						INNER JOIN	T0040_IP_MASTER IP WITH (NOLOCK) ON I.IP_ADDRESS=IP.IP_ADDRESS AND IP.CMP_ID=@CMP_ID
						INNER JOIN	#EMP_CONS E ON I.ENROLL_NO=E.ENROLL_NO 
						LEFT JOIN	#CANTEEN1 T ON E.GRADE = T.GRD_ID  AND IP.IP_ID = T.IP_ID		
				WHERE	(I.IN_OUT_FLAG='10' OR I.IP_ADDRESS='CANTEEN' OR IP.DEVICE_NO >= 200) 
						AND (I.IO_DATETIME BETWEEN @FROM_DATE AND @TO_DATE) AND IP.IS_CANTEEN =1
						--AND I.CMP_ID=@CMP_ID
				ORDER BY E.EMP_ID,I.IO_DATETIME


				
				--Filtering Records as per Selected Device IP
				IF (@DEVICEIPS <> '' AND @DEVICEIPS <> '0')
				BEGIN		
						DELETE FROM #TEMP WHERE IP_ADDRESS <> @DEVICEIPS
				END	


			--UPDATING FROM_TIME AND TO_TIME FOR NIGHT SHIFT
			UPDATE	#TEMP
			SET		FROM_TIME = ((CASE WHEN (DATEDIFF(N, CAST(CAST(IO_DATETIME AS DATE) AS DATETIME), IO_DATETIME) < 720 AND FROM_TIME > TO_TIME )  
							THEN DATEADD(D,-1,FROM_TIME) 
						ELSE
							FROM_TIME 
						END
					) + CONVERT(DATETIME,CONVERT(CHAR(10),IO_DATETIME, 103), 103)),
					TO_TIME = ((CASE WHEN (DATEDIFF(N, CAST(CAST(IO_DATETIME AS DATE) AS DATETIME), IO_DATETIME) > 720 AND FROM_TIME > TO_TIME )  
							THEN DATEADD(D,1,TO_TIME) 
						ELSE
							TO_TIME
						END
					) + CONVERT(DATETIME,CONVERT(CHAR(10),IO_DATETIME, 103), 103))
	
	
	
			--REMOVING GAP BETWEEN TWO IN-OUT DETAIL WHICH IS LESS THAN 5 MINUTES
			EXEC DBO.P0050_CANTEEN_REMOVE_IO_GAP @CMP_ID, @FROM_DATE, @TO_DATE


			SELECT	E.EMP_ID,E.EMP_CODE,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,E.EMP_FIRST_NAME,E.GENDER,E.DATE_OF_JOIN,ISNULL(E.CAT_ID,0) AS CAT_ID,
					ISNULL(DM.DEPT_ID,0) AS DEPT_ID,ISNULL(DM.DEPT_NAME,'NotAssigned') AS DEPT_NAME,DGM.DESIG_ID,DGM.DESIG_NAME,GM.GRD_ID,GM.GRD_NAME,
					ETM.[TYPE_ID],ETM.[TYPE_NAME],BM.BRANCH_NAME,BM.BRANCH_ADDRESS,BM.COMP_NAME,BM.BRANCH_ID,
					CM.CMP_ID,CM.CMP_ADDRESS,CM.CMP_NAME,CT.IO_DATETIME,CT.AMOUNT,CT.FROM_TIME,CT.TO_TIME,C.CNT_NAME,
					ISNULL(I_Q.VERTICAL_ID,0) Vertical_Id,Isnull(I_Q.VERTICAL_NAME,'NotAssigned') VERTICAL_NAME ,
					ISNULL(I_Q.SUBVERTICAL_ID,0) SUBVERTICAL_ID,Isnull(I_Q.SUBVERTICAL_NAME,'NotAssigned') SUBVERTICAL_NAME,CT.IP_ADDRESS,CT.DEVICE_NO,CT.DEVICE_NAME
					,CONVERT(DATETIME,CONVERT(VARCHAR(10), CT.IO_DATETIME, 111)) AS FOR_DATE,CT.IO_TRAN_ID,DBO.F_GET_AMPM(CT.IO_DATETIME) AS IN_TIME
					,'' AS REASON	
					,CT.SUBSIDY_AMOUNT,CT.TOTAL_AMOUNT,C.CNT_ID,ISNULL(Cat_Name,'NotAssigned') CAT_NAME
					,ISnull(sb.subBranch_ID,0) AS subBranch_ID,Isnull(sb.SubBranch_Name,'NotAssigned') SubBranch_Name
					,ISnull(bs.Segment_ID,0) AS Segment_ID,Isnull(bs.Segment_Name,'NotAssigned') Segment_Name
					,ISNULL(cc.center_id,0) as center_id,ISNULL(Center_Name,'NotAssigned') Center_Name
			INTO	#RPT1
			FROM	DBO.T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN DBO.T0100_LEFT_EMP L WITH (NOLOCK) ON E.EMP_ID =  L.EMP_ID INNER JOIN
					(
						SELECT	I.EMP_ID , GRD_ID,BRANCH_ID,CAT_ID,DESIG_ID,DEPT_ID,TYPE_ID,BANK_ID,INC_BANK_AC_NO,
								I.VERTICAL_ID,I.SUBVERTICAL_ID,V.VERTICAL_NAME,SV.SUBVERTICAL_NAME,subBranch_ID,Segment_ID,center_Id
						FROM	DBO.T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
								(
									SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM DBO.T0095_INCREMENT WITH (NOLOCK)
									WHERE	INCREMENT_EFFECTIVE_DATE <= @TO_DATE
											AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID
								) QRY ON
								I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
								LEFT OUTER JOIN DBO.T0040_VERTICAL_SEGMENT V WITH (NOLOCK) ON I.CMP_ID=V.CMP_ID AND I.VERTICAL_ID=V.VERTICAL_ID			
								LEFT OUTER JOIN DBO.T0050_SUBVERTICAL SV WITH (NOLOCK) ON I.CMP_ID=SV.CMP_ID AND I.SUBVERTICAL_ID=SV.SUBVERTICAL_ID
					) I_Q ON E.EMP_ID = I_Q.EMP_ID  INNER JOIN 
						DBO.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.GRD_ID = GM.GRD_ID LEFT OUTER JOIN
						DBO.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.TYPE_ID = ETM.TYPE_ID LEFT OUTER JOIN
						DBO.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN
						DBO.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.DEPT_ID = DM.DEPT_ID INNER JOIN 
						DBO.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN 
						DBO.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID INNER JOIN
						#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID INNER JOIN 
						#TEMP CT ON CT.EMP_ID=E.EMP_ID LEFT JOIN
						DBO.T0050_CANTEEN_MASTER C WITH (NOLOCK) ON CT.CNT_ID=C.CNT_ID LEFT OUTER JOIN
						T0030_CATEGORY_MASTER CA WITH (NOLOCK) ON CA.CAT_Id = I_Q.CAT_ID LEFT OUTER JOIn
						T0050_SubBranch SB WITH (NOLOCK) ON SB.SubBranch_ID = I_Q.subBranch_ID LEFT OUTER JOIn
						T0040_Business_Segment BS WITH (NOLOCK) ON BS.Segment_ID = I_Q.Segment_ID Left Outer Join
						T0040_COST_CENTER_MASTER cc WITH (NOLOCK) On cc.center_Id = I_Q.center_Id
			WHERE	E.CMP_ID = @CMP_ID 
			ORDER BY (
						CASE	WHEN ISNUMERIC(E.ALPHA_EMP_CODE) = 1 
									THEN RIGHT(REPLICATE('0',21) + E.ALPHA_EMP_CODE, 20)
								WHEN ISNUMERIC(E.ALPHA_EMP_CODE) = 0 
									THEN LEFT(E.ALPHA_EMP_CODE + REPLICATE('',21), 20)
								ELSE 
									E.ALPHA_EMP_CODE
						END
					), CT.IO_DATETIME

				

					DECLARE @SQL VARCHAR(MAX)
					DECLARE @COLS VARCHAR(MAX)

					DECLARE @STRING AS VARCHAR(MAX)
					SET @STRING=''
					
					DECLARE @STRING_2 AS VARCHAR(MAX)
					SET @STRING_2=''
					
					DECLARE @STRING_3 AS VARCHAR(MAX)
					SET @STRING_3=''
					
					IF @GROUPBY = '' OR @GROUPBY = '-1'
					SET @GROUPBY = '0'	
					
					
					DECLARE @STRING_1 VARCHAR(MAX)
					SET @STRING_1 = ''
					IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'TEMPGROUP2')
						DROP TABLE TEMPGROUP2
					
					IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'TEMPGROUP3')
						DROP TABLE TEMPGROUP3
						
					IF @GROUPBY IS NOT NULL
						BEGIN
							SET @STRING_2 = 'SELECT (CASE WHEN '+ @GROUPBY +'=''0'' THEN ''BRANCH_NAME'' WHEN '+ @GROUPBY +' =''1'' THEN ''GRADE'' WHEN '+ @GROUPBY +' =''2'' THEN ''CATEGORY'' WHEN '+ @GROUPBY +' =''3'' THEN ''DEPARTMENT'' WHEN '+ @GROUPBY +' =''4'' THEN ''DESIGNATION'' WHEN '+ @GROUPBY +' =''5'' THEN ''TYPENAME'' WHEN '+ @GROUPBY +' =''6'' THEN ''VERTICAL_NAME'' WHEN '+ @GROUPBY +' =''7'' THEN ''SUB_VERTICAL'' WHEN '+ @GROUPBY +' =''8'' THEN ''SUB_BRANCH'' WHEN '+ @GROUPBY +' =''9'' THEN ''SEGMENT_NAME'' WHEN '+ @GROUPBY +' =''10'' THEN ''CENTER_CODE'' END ) AS DESCRIPTION INTO TEMPGROUP2'
							EXEC(@STRING_2)
							SELECT @STRING_2 = DESCRIPTION FROM TEMPGROUP2							
							
						END 	

						IF OBJECT_ID('TEMPDB..#COUNT') IS NOT NULL
							DROP TABLE #COUNT

						CREATE TABLE #COUNT
						(
							GROUP_Id		NUMERIC(18,0),
							GROUP_NAME		VARCHAR(50),
							CANTEEN_TYPE	VARCHAR(50),
							COUNT1			NUMERIC(18,0),
							FOR_DATE		DATE
							--,AMOUNT			NUMERIC(18,2)				
						)

						DECLARE @GROUPING AS VARCHAR(MAX);
						
						
					IF @GROUPBY='0' --------FOR GROUPBY BRANCH---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Branch_ID,Branch_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Branch_ID,Branch_Name,FOR_DATE,C.Cnt_Name
								ORder By Branch_ID,Branch_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Branch_ID,Branch_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

								
								If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
									
								

						END

					ELSE IF @GROUPBY='1'  --------FOR GROUPBY GRADE---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Grd_ID,Grd_NAME,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Grd_ID,Grd_NAME,FOR_DATE,C.Cnt_Name
								ORder By Grd_ID,Grd_NAME,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Grd_ID,Grd_NAME,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

								
								If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)

									

						END


					ELSE IF @GROUPBY='2'  --------FOR GROUPBY CATEGORY---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	CAT_ID,CAT_NAME,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY CAT_ID,CAT_NAME,FOR_DATE,C.Cnt_Name
								ORder By CAT_ID,CAT_NAME,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,CAT_ID,CAT_NAME,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q

									

								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

								
								If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)

									
									
						END
					
					ELSE IF @GROUPBY='3'  ---------FOR GROUPBY DEPARTMENT---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Dept_ID,Dept_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Dept_ID,Dept_Name,FOR_DATE,C.Cnt_Name
								ORder By Dept_ID,Dept_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Dept_ID,Dept_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'GrandTotal' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q

									

								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

								
								If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)

									
								
						END

					ELSE IF @GROUPBY='4'  ---------FOR GROUPBY DESIGNATION---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Desig_ID,Desig_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Desig_ID,Desig_Name,FOR_DATE,C.Cnt_Name
								ORder By Desig_ID,Desig_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Desig_ID,Desig_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

								
								If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								

						END

					ELSE IF @GROUPBY='5'  ---------FOR GROUPBY TYPENAME---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Type_ID,Type_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Type_ID,Type_Name,FOR_DATE,C.Cnt_Name
								ORder By Type_ID,Type_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Type_ID,Type_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

								
								If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								

								
						END					

					ELSE IF @GROUPBY='6'  ---------FOR GROUPBY DIVISION WISE---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Vertical_Id,Vertical_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Vertical_Id,Vertical_Name,FOR_DATE,C.Cnt_Name
								ORder By Vertical_Id,Vertical_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Vertical_Id,Vertical_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

									If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								

								
						END

					ELSE IF @GROUPBY='7'  ---------FOR GROUPBY SUBVERTICAL WISE---------------------------
						BEGIN 	
								INSERT	INTO #COUNT
								SELECT	SUBVERTICAL_ID,SUBVERTICAL_NAME,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY SUBVERTICAL_ID,SUBVERTICAL_NAME,FOR_DATE,C.Cnt_Name
								ORder By SUBVERTICAL_ID,SUBVERTICAL_NAME,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,SUBVERTICAL_ID,SUBVERTICAL_NAME,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

									If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								


						END

					ELSE IF @GROUPBY='8'  ---------FOR GROUPBY SUBBRANCH WISE---------------------------
					BEGIN 	
								INSERT	INTO #COUNT
								SELECT	subBranch_ID,subBranch_NAME,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY subBranch_ID,subBranch_NAME,FOR_DATE,C.Cnt_Name
								ORder By subBranch_ID,subBranch_NAME,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,subBranch_ID,subBranch_NAME,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

									If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								

								
					END

					ELSE IF @GROUPBY='9'  ---------FOR GROUPBY SEGMENT_NAME WISE---------------------------
					BEGIN 	
								INSERT	INTO #COUNT
								SELECT	Segment_ID,Segment_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY Segment_ID,Segment_Name,FOR_DATE,C.Cnt_Name
								ORder By Segment_ID,Segment_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,Segment_ID,Segment_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

									If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								

								
					END

					ELSE IF @GROUPBY='10'  ---------FOR GROUPBY CENTER_CODE WISE---------------------------
					BEGIN 	
							INSERT	INTO #COUNT
								SELECT	center_id,Center_Name,C.Cnt_Name,COUNT(C.EMP_ID),FOR_DATE--,0
								FROM	#RPT1 C 																					
								GROUP BY center_id,Center_Name,FOR_DATE,C.Cnt_Name
								ORder By center_id,Center_Name,FOR_DATE,C.Cnt_Name
								
								INSERT	INTO #COUNT
								SELECT  distinct GROUP_Id,GROUP_NAME,CANTEEN_TYPE,0,D.FOR_DATES--,0
								FROM	#COUNT C 										
										CROSS JOIN #DATES D
								WHERE	 NOT EXISTS (SELECT 1 FROM #COUNT AS I WHERE I.FOR_DATE = D.FOR_DATES AND I.CANTEEN_TYPE = C.CANTEEN_TYPE)
								
								
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99997 as GROUP_Id,'Total Meal' as GROUP_NAME, CANTEEN_TYPE as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												GROUP BY 	CANTEEN_TYPE,GROUP_Id,GROUP_NAME,FOR_DATe
											)Q
							
								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99998 as GROUP_Id,'Total Amount' as GROUP_NAME, Cnt_Name  as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
												FROM		#RPT1 	
												GROUP BY 	Cnt_Name,center_id,Center_Name,FOR_DATe
											)Q
								

								INSERT INTO #COUNT
								SELECT * FROM
											(
												SELECT		99999 as GROUP_Id, 'TotalGroup' as GROUP_NAME,  'Total' as CANTEEN_TYPE,SUM(COUNT1) as COunt1,FOR_DATe
												FROM		#COUNT 	
												WHERE		GROUP_Id = 99998
												GROUP BY 	FOR_DATe
											)Q
							
								--INSERT INTO #COUNT
								--SELECT * FROM
								--			(
								--				SELECT		99999  as GROUP_Id,'TotalGroup' as GROUP_NAME, 'Total Amount' as CANTEEN_TYPE,SUM(AMOUNT) as COUNT1,FOR_DATe
								--				FROM		#RPT1 	
								--				GROUP BY 	FOR_DATe
								--			)Q
																
								Update #COUNT
								SET	   COUNT1 = NULL
								where  COUNT1 =0

									If @FORMAT = 3 
									BEGIN 
											SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
												FROM (SELECT Distinct  Isnull('['  + CANTEEN_TYPE  + '#' +   GROUP_NAME +  ']',0) AS GROPU_HEADER
														,GROUP_Id,CANTEEN_TYPE
													FROM	#COUNT
												) Q Order by CANTEEN_TYPE,Q.GROUP_ID,Q.GROPU_HEADER 
												FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '')   

											SET	@GROUPING = 'CANTEEN_TYPE  + ''#'' +   GROUP_NAME'
									END
								ELSE If @FORMAT = 2
									BEGIN 
												SELECT @cols = STUFF((SELECT ',' + GROPU_HEADER AS ColName
													  FROM (SELECT Distinct Isnull('['  + GROUP_NAME  + '#' +   CANTEEN_TYPE +  ']',0) AS GROPU_HEADER
																,GROUP_Id,CANTEEN_TYPE
														 FROM	#COUNT
														) Q Order by Q.GROUP_ID,Q.GROPU_HEADER,CANTEEN_TYPE
													 FOR XML PATH(''), TYPE).value ('.', 'nVARCHAR(max)'), 1, 1, '') 

											SET	@GROUPING = 'GROUP_NAME  + ''#'' +  CANTEEN_TYPE '
									END

								

								  SET @SQL = '	SELECT * 
												FROM 
														(
								  
															SELECT	FOR_DATE,' + @COLS + '
															FROM	 
															(								
																SELECT	CONVERT(VARCHAR(12),FOR_DATE,103) FOR_DATE,' + @GROUPING + ' AS GROUPHEADER,COUNT1
																FROM	#COUNT P
																
																UNION ALL

																SELECT		''TOTAL MEAL'',' + @GROUPING + '  AS GROUPHEADER,SUM(COUNT1)
																FROM		#COUNT		
																GROUP BY	CANTEEN_TYPE,GROUP_NAME
																			
															) YS 
															PIVOT 
															(
																SUM(COUNT1) FOR GROUPHEADER IN (' + @COLS + ')
															) PVT
															
															
														)Q'
								
									
										
									EXEC (@SQL)
								

					END
END


