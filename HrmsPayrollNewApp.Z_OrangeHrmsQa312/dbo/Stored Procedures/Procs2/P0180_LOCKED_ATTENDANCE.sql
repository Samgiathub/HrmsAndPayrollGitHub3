

-- =============================================
-- Author:		<Author,,Jimit>
-- Create date: <Create Date,,22022019>
-- Description:	<Description,,For Inserting Attendance Lock Record>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0180_LOCKED_ATTENDANCE]
	 @LOCK_ID		INT
	,@CMP_ID		INT
	,@EMP_ID		INT
	,@MONTH			TINYINT
	,@YEAR			SMALLINT
	,@CONSTRAINTS	VARCHAR(MAX) = ''

	,@LOGIN_ID		NUMERIC(18,0)	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #EMP_CONS_SAL(EMP_ID numeric PRIMARY KEY, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
	
	INSERT INTO #EMP_CONS_SAL (EMP_ID) 
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@CONSTRAINTS, '#') T
	WHERE 	T.Data <> '' AND  NOT EXISTS(SELECT	1 
										 FROM	T0180_LOCKED_ATTENDANCE LA WITH (NOLOCK)
										 WHERE	[MONTH] = @MONTH AND [YEAR] = @YEAR AND LA.Emp_Id = CAST(T.DATA AS numeric))							 
			--AND  NOT EXISTS(SELECT	1                                                                      ---Commented by Mr.Mehul for Bug #25439
			--				FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
			--				WHERE	MONTH(MS.Month_End_Date) = @MONTH AND YEAR(MS.Month_End_Date) = @YEAR 
			--						AND MS.Emp_Id = CAST(T.DATA AS numeric))							 

	
	
	

	DECLARE @TO_DATE   DATETIME
	DECLARE @FROM_DATE DATETIME	
	SELECT @FROM_DATE = DBO.GET_MONTH_ST_DATE(@MONTH,@YEAR)
	SELECT @TO_DATE = DBO.GET_MONTH_END_DATE(@MONTH,@YEAR)
	DECLARE @nFromDate NUMERIC
	SET @nFromDate = CAST(@from_date AS NUMERIC) - 1

	SELECT	-1 AS Branch_ID, C.EMP_ID, CM.Salary_St_Date 
	INTO	#EMP_SAL_CYCLE
	from	T0095_Emp_Salary_Cycle C WITH (NOLOCK)
			INNER JOIN t0040_salary_cycle_master CM WITH (NOLOCK) ON C.SalDate_ID=CM.Tran_ID
			INNER JOIN #EMP_CONS_SAL E ON C.Emp_id=E.EMP_ID
	where	effective_date =(
						SELECT	MAX(effective_date) 
						from	T0095_Emp_Salary_Cycle C1 WITH (NOLOCK)
						where	C1.EMP_ID = C.Emp_id AND effective_date <=  @TO_DATE
								)
	
	
		

	SELECT	DISTINCT I.EMP_ID,(CASE WHEN IsNull(G.Manual_Salary_Period,0) =1 THEN ISNULL(SP.from_date,g.Sal_St_Date) ELSE  CAST(@nFromDate  + Day(g.Sal_St_Date) AS DATETIME) END) AS Sal_St_Date, 
			(CASE WHEN IsNull(G.Manual_Salary_Period,0) =1 THEN 
				ISNULL(SP.end_date,(Case when Year(g.Cutoffdate_salary) > 1900 then g.Cutoffdate_salary else dateadd(d,-1, dateadd(m,1,g.Sal_St_Date)) end)) 
			ELSE 
				(Case when Year(g.Cutoffdate_salary) > 1900 then g.Cutoffdate_salary else dateadd(d,-1, dateadd(m,1,g.Sal_St_Date)) end)
			END) AS Sal_End_Date, IsNull(G.Manual_Salary_Period,0) As Manual_Salary_Period, (Case When Year(g.Cutoffdate_salary) > 1900 Then 1 Else 0 END) As Is_CutOff
			,ISNULL(Cutoffdate_salary,'1900-01-01') AS Cutoffdate_salary
	INTO	#SAL_CYCLE
	FROM	t0030_branch_master b WITH (NOLOCK) inner join 
			t0040_general_setting g WITH (NOLOCK) on b.branch_id=g.branch_id
			INNER JOIN (SELECT MAX(FOR_DATE) AS FOR_DATE, BRANCH_ID FROM t0040_general_setting G1 WITH (NOLOCK) WHERE G1.For_Date <= @TO_DATE GROUP BY G1.BRANCH_ID) G1 ON G.Branch_ID=G1.BRANCH_ID AND G.FOR_DATE=G1.FOR_DATE
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON B.BRANCH_ID=I.BRANCH_ID
			INNER JOIN #EMP_CONS_SAL E ON I.Emp_id=E.EMP_ID
			LEFT OUTER JOIN #EMP_SAL_CYCLE SC ON E.EMP_ID=SC.EMP_ID
			INNER JOIN (
						SELECT	I2.EMP_ID, MAX(I2.INCREMENT_ID) AS INCREMENT_ID 
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN #EMP_CONS_SAL E ON I2.Emp_id=E.EMP_ID
								INNER JOIN (SELECT I3.EMP_ID, MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
											 FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #EMP_CONS_SAL E ON I3.Emp_id=E.EMP_ID
											 WHERE I3.Increment_Effective_Date <= @TO_DATE
											 GROUP BY I3.Emp_ID
											 ) I3 ON I2.Emp_ID=I3.EMP_ID AND I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE
						WHERE	I3.Increment_Effective_Date <= @TO_DATE
						GROUP BY I2.Emp_ID) I2 ON I.EMP_ID=I2.EMP_ID AND I.INCREMENT_ID=I2.INCREMENT_ID
			LEFT OUTER JOIN Salary_Period SP ON SP.month = MONTH(@FROM_DATE) AND SP.year = YEAR(@FROM_DATE)	
	WHERE	(SC.EMP_ID IS NULL OR IsNull(G.Manual_Salary_Period,0) = 0)

	

	DELETE ESC FROM #EMP_SAL_CYCLE ESC INNER JOIN #SAL_CYCLE SC ON ESC.Emp_id=SC.EMP_ID


	

	CREATE TABLE #SALARY_CYCLE(ROW_ID BIGINT IDENTITY(1,1) PRIMARY KEY, EMP_CONS VARCHAR(MAX), SAL_ST_DATE DATETIME, SAL_END_DATE DATETIME, Manual_Salary_Period tinyint, Is_CutOff Bit,Cutoffdate_salary DATETIME);

	INSERT INTO #SALARY_CYCLE
	SELECT (SELECT (SELECT	Cast(EMP_ID As Varchar(10)) + '#'
					 FROM	#SAL_CYCLE SC
					 WHERE	SC.SAL_ST_DATE=SC1.SAL_ST_DATE AND SC.SAL_END_DATE=SC1.SAL_END_DATE
							FOR XML PATH('')						 
					)), SAL_ST_DATE, SAL_END_DATE, Manual_Salary_Period, Is_CutOff,Cutoffdate_salary
	FROM	(SELECT SAL_ST_DATE, SAL_END_DATE, Manual_Salary_Period,Is_CutOff,Cutoffdate_salary FROM  #SAL_CYCLE SC1  GROUP BY SAL_ST_DATE, SAL_END_DATE,Manual_Salary_Period,Is_CutOff,Cutoffdate_salary) SC1
	UNION ALL
	SELECT	(SELECT (SELECT CAST(EMP_ID AS VARCHAR(20)) + '#'
				FROM #EMP_SAL_CYCLE C1
				WHERE C1.Salary_St_Date = C2.Salary_St_Date 
				FOR XML PATH(''))) AS EMP_ID, C2.Salary_St_Date, DATEADD(d, -1, dateadd(m, 1, C2.Salary_St_Date)) As Salary_End_Date, Cast(0 AS tinyint) As Manual_Salary_Period, 0 AS Is_CutOff
				,'1900-01-01' as Cutoffdate_salary
	FROM	(SELECT Salary_St_Date FROM #EMP_SAL_CYCLE GROUP BY Salary_St_Date) C2 
	
	DECLARE @EMP_CONS VARCHAR(MAX)
		
	DECLARE @SAL_ST_DATE				DATETIME    
	DECLARE @SAL_END_DATE				DATETIME  
	DECLARE @CUTOFFDATE_SALARY			DATETIME
	DECLARE @Manual_Salary_Period		TINYINT
	DECLARE @IS_CUTOFF					TINYINT

	
	
	DECLARE CUR_EMP CURSOR FAST_FORWARD FOR
	SELECT EMP_CONS, SAL_ST_DATE, SAL_END_DATE,Manual_Salary_Period, IS_CutOff,Cutoffdate_salary
	FROM #SALARY_CYCLE
	
	
	OPEN CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_CONS, @SAL_ST_DATE, @SAL_END_DATE,@MANUAL_SALARY_PERIOD,@IS_CUTOFF,@CUTOFFDATE_SALARY
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF (@Manual_Salary_Period <> 1 )
				BEGIN
					IF ABS(DATEDIFF(m, @FROM_DATE, @SAL_ST_DATE)) < 2
						BEGIN
							IF DAY(@Sal_St_Date) = 1
								BEGIN
									SET @SAL_END_DATE = DATEADD(yyyy,  YEAR(@TO_DATE) - YEAR(@SAL_END_DATE) , @SAL_END_DATE);
									SET @SAL_END_DATE = DATEADD(m,  MONTH(@TO_DATE) - MONTH(@SAL_END_DATE) , @SAL_END_DATE);
								
									SET @SAL_ST_DATE = DATEADD(m,  MONTH(@FROM_DATE) - MONTH(@SAL_ST_DATE) , @SAL_ST_DATE);
									SET @SAL_ST_DATE = DATEADD(yyyy,  YEAR(@FROM_DATE) - YEAR(@SAL_ST_DATE) , @SAL_ST_DATE);
								
									if @IS_CUTOFF <> 1 
										SET @SAL_END_DATE = DATEADD(d,-1,DATEADD(m, 1,@SAL_ST_DATE));
								
									if @IS_CUTOFF = 1   
										set @SAL_ST_DATE = DATEADD(d,1,DATEADD(m, -1,@SAL_END_DATE))
								END
							ELSE
								BEGIN
									SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    							
									SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
								END
						END
					Else 
						Begin						
							SET @SAL_END_DATE=DATEADD(D,-1,DATEADD(m,1,@Sal_St_date))
						End	
				END
																		
				SELECT @LOCK_ID = ISNULL(MAX(LOCK_ID),0) + 1 FROM T0180_LOCKED_ATTENDANCE WITH (NOLOCK)															
				
				SELECT @EMP_CONS = LEFT(@EMP_CONS, LEn(@EMP_CONS) - 1)	

				
									
				INSERT INTO T0180_LOCKED_ATTENDANCE 
				SELECT	@LOCK_ID + id,@CMP_ID,CAST(T.DATA AS INT),@MONTH,@YEAR,@SAL_ST_DATE,@SAL_END_DATE,ISNULL(@CUTOFFDATE_SALARY,'1900-01-01'),
						@LOGIN_ID,GETDATE()
				FROM	DBO.Split(@EMP_CONS,'#') T				
							

				

				EXEC P_ATTENDANCE_LOCK @Cmp_ID,@SAL_ST_DATE,@SAL_END_DATE,@EMP_CONS
												
			
			FETCH NEXT FROM CUR_EMP INTO @EMP_CONS, @SAL_ST_DATE, @SAL_END_DATE,@Manual_Salary_Period,@IS_CUTOFF,@CUTOFFDATE_SALARY
		END
						
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP

	
				
RETURN

