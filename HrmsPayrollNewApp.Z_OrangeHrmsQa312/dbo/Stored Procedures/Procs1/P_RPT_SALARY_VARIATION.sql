

CREATE PROCEDURE [dbo].[P_RPT_SALARY_VARIATION]
	 @CMP_ID				Numeric
	,@From_Date			DATETIME
	,@To_Date 			DATETIME 
	,@Branch_ID			VARCHAR(MAX) = ''
	,@Cat_ID			VARCHAR(MAX) = ''
	,@Grd_ID 			VARCHAR(MAX) = ''
	,@Type_ID 			VARCHAR(MAX) = ''
	,@Dept_ID 			VARCHAR(MAX) = ''
	,@Desig_ID 			VARCHAR(MAX) = ''
	,@Emp_ID 			Numeric = 0
	,@Constraint		VARCHAR(max) = ''
	,@Type int =0 --Added by ronakk 22122023
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	IF OBJECT_ID('tempdb..#Emp_Cons') is not null
		Drop TABLE #Emp_Cons

	CREATE TABLE #Emp_Cons
	(      
		Emp_ID NUMERIC,
		Branch_ID NUMERIC,
		Increment_ID NUMERIC   
	)
	
	INSERT INTO #Emp_Cons 
	SELECT Data,0,0 From dbo.Split(@Constraint,'#')
	
	UPDATE EC
			SET EC.Increment_ID = EI.INCREMENT_ID,
				EC.Branch_ID = EI.Branch_ID
		FROM #Emp_Cons EC 
		INNER JOIN T0095_INCREMENT EI ON EC.Emp_ID = EI.Emp_ID
		INNER JOIN (
					SELECT MAX(TI.INCREMENT_ID) AS INCREMENT_ID,TI.EMP_ID
					FROM T0095_INCREMENT TI WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE,Emp_ID
									FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE 
										 AND CMP_ID = @CMP_ID --AND EMP_ID = @EMP_ID 
										 AND INCREMENT_TYPE <> 'TRANSFER' AND INCREMENT_TYPE <> 'DEPUTATION'
									GROUP BY Emp_ID
								) AS NEW_INC ON TI.INCREMENT_EFFECTIVE_DATE=NEW_INC.INCREMENT_EFFECTIVE_DATE
					WHERE TI.INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND INCREMENT_TYPE <> 'TRANSFER' 
						  AND INCREMENT_TYPE <> 'DEPUTATION'
					GROUP BY TI.EMP_ID
		) AS QRY ON EI.INCREMENT_ID = QRY.INCREMENT_ID AND EI.EMP_ID = QRY.EMP_ID
		
	
	--Added by ronakk for Variance Report 05012023
	If @Type = 0
	Begin

	DECLARE @SAL_INCREMENT_ID NUMERIC

	DECLARE @INCREMENT_ID NUMERIC
	SET @INCREMENT_ID = 0
	
	DECLARE @SAL_TO_DATE DATETIME
	
	IF OBJECT_ID('TEMPDB..#EMP_ACTUAL_SAL') IS NOT NULL
		BEGIN
			DROP TABLE #EMP_ACTUAL_SAL
		END
		
	CREATE TABLE #EMP_ACTUAL_SAL
	(
		SR_NO NUMERIC,
		EMP_ID NUMERIC,
		AD_ID NUMERIC,
		AD_DESCRIPRION VARCHAR(500),
		PREV_AD_AMOUNT NUMERIC(18,2),
		CURR_AD_AMOUNT NUMERIC(18,2),
		DIFF_AMOUNT NUMERIC(18,2),
		REASON VARCHAR(200),
		AD_FLAG NUMERIC(1,0)
	)
	
	IF OBJECT_ID('TEMPDB..#AD_TABLE') IS NOT NULL
		BEGIN
			DROP TABLE #AD_TABLE
		END
		
	CREATE TABLE #AD_TABLE
	(
		EMP_ID NUMERIC,
		AD_ID NUMERIC,
		E_AD_AMOUNT NUMERIC(18,2),
		AD_NAME VARCHAR(500),
		REASON VARCHAR(200),
		AD_FLAG Numeric(1,0) -- 0 For Earning & 1 For Deduction
	)
	
	IF OBJECT_ID('TEMPDB..#SAL_AD_TABLE') IS NOT NULL
		BEGIN
			DROP TABLE #SAL_AD_TABLE
		END
	
	CREATE TABLE #SAL_AD_TABLE
	(
		EMP_ID NUMERIC,
		AD_ID NUMERIC,
		E_AD_AMOUNT NUMERIC(18,2),
		AD_NAME VARCHAR(500),
		REASON VARCHAR(200),
		AD_FLAG Numeric(1,0) -- 0 For Earning & 1 For Deduction
	)
	

	DECLARE CUR_EMP CURSOR FOR
	SELECT EMP_ID,Increment_ID FROM #EMP_CONS
	OPEN CUR_EMP 
	FETCH NEXT FROM CUR_EMP INTO @Emp_ID,@INCREMENT_ID
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			print 123445
			--SELECT @INCREMENT_ID = EI.INCREMENT_ID
			--FROM	T0095_INCREMENT EI 
			--INNER JOIN (
			--			SELECT MAX(TI.INCREMENT_ID) AS INCREMENT_ID,TI.EMP_ID
			--			FROM T0095_INCREMENT TI 
			--			INNER JOIN (
			--							SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE 
			--							FROM T0095_INCREMENT
			--							WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE 
			--								 AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID 
			--								 AND INCREMENT_TYPE <> 'TRANSFER' AND INCREMENT_TYPE <> 'DEPUTATION'
			--						) AS NEW_INC ON TI.INCREMENT_EFFECTIVE_DATE=NEW_INC.INCREMENT_EFFECTIVE_DATE
			--			WHERE TI.INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND EMP_ID = @EMP_ID AND INCREMENT_TYPE <> 'TRANSFER' 
			--				  AND INCREMENT_TYPE <> 'DEPUTATION'
			--			GROUP BY TI.EMP_ID
			--) AS QRY ON EI.INCREMENT_ID = QRY.INCREMENT_ID AND EI.EMP_ID = QRY.EMP_ID
			
			
			INSERT INTO #AD_TABLE
			SELECT @Emp_ID,0,Basic_Salary,'Basic_Sal','Increment',0 From T0095_INCREMENT WITH (NOLOCK) Where Increment_ID = @INCREMENT_ID and Emp_ID = @Emp_ID
			
			INSERT INTO #AD_TABLE
			SELECT @Emp_ID,AD_ID,0,AD_NAME,' ',(CASE WHEN AD_FLAG = 'I' THEN 0 ELSE 1 END) From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = @Cmp_ID
			
			IF OBJECT_ID('TEMPDB..#AD_TABLE_STR') IS NOT NULL
				BEGIN
					DROP TABLE #AD_TABLE_STR
				END
				
			--INSERT INTO #AD_TABLE
			SELECT EMP_ID,AD_ID,E_AD_AMOUNT,AD_NAME,QRY.REASON INTO #AD_TABLE_STR
			FROM (
					SELECT EED.AD_ID,
						 CASE WHEN QRY1.INCREMENT_ID >= EED.INCREMENT_ID THEN
							CASE WHEN QRY1.E_AD_PERCENTAGE IS NULL THEN EED.E_AD_PERCENTAGE ELSE QRY1.E_AD_PERCENTAGE END 
						 ELSE
							EED.E_AD_PERCENTAGE END AS E_AD_PERCENTAGE,
						 CASE WHEN QRY1.INCREMENT_ID >= EED.INCREMENT_ID THEN
							CASE WHEN QRY1.E_AD_AMOUNT IS NULL THEN EED.E_AD_AMOUNT ELSE QRY1.E_AD_AMOUNT END 
						 ELSE
							EED.E_AD_AMOUNT END AS E_AD_AMOUNT,
						E_AD_FLAG,E_AD_MAX_LIMIT ,AD_CALCULATE_ON ,AD_DEF_ID ,                    
						ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
						ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
						ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
						AD_NAME,ISNULL(AD_EFFECT_ON_LATE,0) AS AD_EFFECT_ON_LATE,
						ISNULL(AD_EFFECT_MONTH,'') AS AD_EFFECT_MONTH,
						ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
						ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
						ISNULL(ADM.ALLOWANCE_TYPE,'A') AS ALLOWANCE_TYPE, 
						ISNULL(ADM.AUTO_PAID,0) AS AUTOPAID,
						ADM.AD_LEVEL,ADM.IS_ROUNDING, 
						CASE WHEN QRY1.INCREMENT_ID >= EED.INCREMENT_ID THEN
							QRY1.IS_CALCULATE_ZERO
						 ELSE
							ISNULL(EED.IS_CALCULATE_ZERO,0) END AS IS_CALCULATE_ZERO,
						EED.EMP_ID,
						'Increment' AS REASON
					FROM DBO.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
						   DBO.T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
							( SELECT EEDR.EMP_ID, EEDR.AD_ID, EEDR.FOR_DATE, EEDR.E_AD_AMOUNT,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.INCREMENT_ID, EEDR.IS_CALCULATE_ZERO
								FROM T0110_EMP_EARN_DEDUCTION_REVISED EEDR WITH (NOLOCK) INNER JOIN
								( SELECT MAX(FOR_DATE) FOR_DATE, AD_ID FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
									WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @TO_DATE
								 GROUP BY AD_ID )QRY ON EEDR.FOR_DATE = QRY.FOR_DATE AND EEDR.AD_ID = QRY.AD_ID 
							) QRY1 ON EED.AD_ID = QRY1.AD_ID AND EED.EMP_ID = QRY1.EMP_ID  AND QRY1.FOR_DATE>=EED.FOR_DATE                
					WHERE EED.EMP_ID = @EMP_ID AND EED.INCREMENT_ID = @INCREMENT_ID AND ADM.AD_ACTIVE = 1
							AND CASE WHEN QRY1.ENTRY_TYPE IS NULL THEN '' ELSE QRY1.ENTRY_TYPE END <> 'D'
					UNION 
					
					SELECT EED.AD_ID,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_FLAG,E_AD_MAX_LIMIT ,AD_CALCULATE_ON ,AD_DEF_ID ,                    
						ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
						ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
						ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
						ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY
						,AD_NAME,ISNULL(AD_EFFECT_ON_LATE,0) AS AD_EFFECT_ON_LATE ,ISNULL(AD_EFFECT_MONTH,'') AS AD_EFFECT_MONTH,
						ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
						ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
						ISNULL(ADM.ALLOWANCE_TYPE,'A') AS ALLOWANCE_TYPE, 
						ISNULL(ADM.AUTO_PAID,0) AS AUTOPAID,
						ADM.AD_LEVEL,ADM.IS_ROUNDING,ISNULL(EED.IS_CALCULATE_ZERO,0) AS IS_CALCULATE_ZERO,
						EED.EMP_ID,
						'Revised Allowance' AS REASON
					FROM DBO.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
						( SELECT MAX(FOR_DATE) FOR_DATE, AD_ID FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
							WHERE EMP_ID  = @EMP_ID AND FOR_DATE <= @TO_DATE 
							GROUP BY AD_ID )QRY ON EED.FOR_DATE = QRY.FOR_DATE AND EED.AD_ID = QRY.AD_ID                   
					   INNER JOIN DBO.T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID = ADM.AD_ID                     
					WHERE EMP_ID = @EMP_ID 
							AND ADM.AD_ACTIVE = 1
							AND EED.ENTRY_TYPE = 'A'
							AND EED.INCREMENT_ID = @INCREMENT_ID
				) QRY
	

				SELECT TOP 1 @SAL_TO_DATE = MONTH_END_DATE,
							 @SAL_INCREMENT_ID = INCREMENT_ID 
				FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
					WHERE EMP_ID = @EMP_ID AND MONTH_END_DATE <= @FROM_DATE 
				ORDER BY MONTH_END_DATE DESC
				
			Update ADT
				SET  E_AD_AMOUNT = ATS.E_AD_AMOUNT,
					 REASON = ATS.REASON
			From #AD_TABLE ADT Inner Join #AD_TABLE_STR ATS
			ON ADT.AD_ID = ATS.AD_ID AND ADT.EMP_ID = ATS.EMP_ID 
			WHERE ATS.EMP_ID = @Emp_ID And ADT.AD_FLAG = 0 and ADT.AD_ID <> 0
			
			INSERT INTO #AD_TABLE
			SELECT @Emp_ID,0,Gross_Salary,'Gross Sal','Increment',0 From T0095_INCREMENT WITH (NOLOCK) Where Increment_ID = @INCREMENT_ID and Emp_ID = @Emp_ID
			
			Update ADT
				SET  E_AD_AMOUNT = ATS.E_AD_AMOUNT,
					 REASON = ATS.REASON
			From #AD_TABLE ADT Inner Join #AD_TABLE_STR ATS
			ON ADT.AD_ID = ATS.AD_ID AND ADT.EMP_ID = ATS.EMP_ID 
			WHERE ATS.EMP_ID = @Emp_ID And ADT.AD_FLAG = 1  and ADT.AD_ID <> 0
			
			
			INSERT INTO #SAL_AD_TABLE
			SELECT @Emp_ID,0,Basic_Salary,'Basic_Sal','Increment',0 From T0095_INCREMENT WITH (NOLOCK) Where Increment_ID = @SAL_INCREMENT_ID and Emp_ID = @Emp_ID
			
			INSERT INTO #SAL_AD_TABLE
			SELECT @Emp_ID,AD_ID,0,AD_NAME,' ',(CASE WHEN AD_FLAG = 'I' THEN 0 ELSE 1 END) From T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = @Cmp_ID
			
			IF OBJECT_ID('TEMPDB..#AD_TABLE_STR_TABLE') IS NOT NULL
				BEGIN
					DROP TABLE #AD_TABLE_STR_TABLE
				END
			
			--INSERT INTO #SAL_AD_TABLE
			SELECT EMP_ID,AD_ID,E_AD_AMOUNT,AD_NAME,QRY.REASON  INTO #AD_TABLE_STR_TABLE
			FROM (
				SELECT EED.AD_ID,
					 CASE WHEN QRY1.INCREMENT_ID >= EED.INCREMENT_ID /*QRY1.FOR_DATE > EED.FOR_DATE*/ THEN
						CASE WHEN QRY1.E_AD_PERCENTAGE IS NULL THEN EED.E_AD_PERCENTAGE ELSE QRY1.E_AD_PERCENTAGE END 
					 ELSE
						EED.E_AD_PERCENTAGE END AS E_AD_PERCENTAGE,
					 CASE WHEN QRY1.INCREMENT_ID >= EED.INCREMENT_ID /*QRY1.FOR_DATE > EED.FOR_DATE*/ THEN
						CASE WHEN QRY1.E_AD_AMOUNT IS NULL THEN EED.E_AD_AMOUNT ELSE QRY1.E_AD_AMOUNT END 
					 ELSE
						EED.E_AD_AMOUNT END AS E_AD_AMOUNT,
					E_AD_FLAG,E_AD_MAX_LIMIT ,AD_CALCULATE_ON ,AD_DEF_ID ,                    
					ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
					ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
					ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
					AD_NAME,ISNULL(AD_EFFECT_ON_LATE,0) AS AD_EFFECT_ON_LATE,
					ISNULL(AD_EFFECT_MONTH,'') AS AD_EFFECT_MONTH,
					ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
					ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
					ISNULL(ADM.ALLOWANCE_TYPE,'A') AS ALLOWANCE_TYPE, 
					ISNULL(ADM.AUTO_PAID,0) AS AUTOPAID,
					ADM.AD_LEVEL,ADM.IS_ROUNDING, 
					CASE WHEN QRY1.INCREMENT_ID >= EED.INCREMENT_ID /*QRY1.FOR_DATE > EED.FOR_DATE*/ THEN
						QRY1.IS_CALCULATE_ZERO
					 ELSE
						ISNULL(EED.IS_CALCULATE_ZERO,0) END AS IS_CALCULATE_ZERO,
					EED.EMP_ID,
					'Increment' AS REASON
				FROM DBO.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
					   DBO.T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
						( SELECT EEDR.EMP_ID, EEDR.AD_ID, EEDR.FOR_DATE, EEDR.E_AD_AMOUNT,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.INCREMENT_ID, EEDR.IS_CALCULATE_ZERO
							FROM T0110_EMP_EARN_DEDUCTION_REVISED EEDR WITH (NOLOCK) INNER JOIN
							( SELECT MAX(FOR_DATE) FOR_DATE, AD_ID FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
								WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @SAL_TO_DATE 
							 GROUP BY AD_ID )QRY ON EEDR.FOR_DATE = QRY.FOR_DATE AND EEDR.AD_ID = QRY.AD_ID 
						) QRY1 ON EED.AD_ID = QRY1.AD_ID AND EED.EMP_ID = QRY1.EMP_ID  AND QRY1.FOR_DATE>=EED.FOR_DATE                
				WHERE EED.EMP_ID = @EMP_ID AND EED.INCREMENT_ID = @SAL_INCREMENT_ID AND ADM.AD_ACTIVE = 1
						AND CASE WHEN QRY1.ENTRY_TYPE IS NULL THEN '' ELSE QRY1.ENTRY_TYPE END <> 'D'
				UNION 
				
				SELECT EED.AD_ID,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_FLAG,E_AD_MAX_LIMIT ,AD_CALCULATE_ON ,AD_DEF_ID ,                    
					ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
					ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
					ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
					ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY
					,AD_NAME,ISNULL(AD_EFFECT_ON_LATE,0) AS AD_EFFECT_ON_LATE ,ISNULL(AD_EFFECT_MONTH,'') AS AD_EFFECT_MONTH,
					ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
					ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
					ISNULL(ADM.ALLOWANCE_TYPE,'A') AS ALLOWANCE_TYPE, 
					ISNULL(ADM.AUTO_PAID,0) AS AUTOPAID,
					ADM.AD_LEVEL,ADM.IS_ROUNDING,ISNULL(EED.IS_CALCULATE_ZERO,0) AS IS_CALCULATE_ZERO,
					EED.EMP_ID,
					'Revised Allowance' AS REASON
				FROM DBO.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
					( SELECT MAX(FOR_DATE) FOR_DATE, AD_ID FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)
						WHERE EMP_ID  = @EMP_ID AND FOR_DATE <= @SAL_TO_DATE 
						GROUP BY AD_ID )QRY ON EED.FOR_DATE = QRY.FOR_DATE AND EED.AD_ID = QRY.AD_ID                   
				   INNER JOIN DBO.T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID = ADM.AD_ID                     
				WHERE EMP_ID = @EMP_ID 
						AND ADM.AD_ACTIVE = 1
						AND EED.ENTRY_TYPE = 'A'
						AND EED.INCREMENT_ID = @SAL_INCREMENT_ID
				) QRY
			
		
			
			Update ADT
				SET  E_AD_AMOUNT = ATS.E_AD_AMOUNT,
					 REASON = ATS.REASON
			From #SAL_AD_TABLE ADT Inner Join #AD_TABLE_STR_TABLE ATS
			ON ADT.AD_ID = ATS.AD_ID AND ADT.EMP_ID = ATS.EMP_ID
			WHERE ATS.EMP_ID = @Emp_ID And ADT.AD_FLAG = 0  and ADT.AD_ID <> 0
			
			INSERT INTO #SAL_AD_TABLE
			SELECT @Emp_ID,0,Gross_Salary,'Gross Sal','Increment',0 From T0095_INCREMENT WITH (NOLOCK) Where Increment_ID = @SAL_INCREMENT_ID and Emp_ID = @Emp_ID
				
			Update ADT
				SET  E_AD_AMOUNT = ATS.E_AD_AMOUNT,
					 REASON = ATS.REASON
			From #SAL_AD_TABLE ADT Inner Join #AD_TABLE_STR_TABLE ATS
			ON ADT.AD_ID = ATS.AD_ID AND ADT.EMP_ID = ATS.EMP_ID
			WHERE ATS.EMP_ID = @Emp_ID And ADT.AD_FLAG = 1 and ADT.AD_ID <> 0
				
			FETCH NEXT FROM CUR_EMP INTO @Emp_ID,@INCREMENT_ID	
		END
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP
	
	
	
	INSERT INTO #EMP_ACTUAL_SAL
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY EMP_ID ORDER BY EMP_ID) AS SR_NO,
		EMP_ID,
		AD_ID,
		AD_NAME,
		0,
		E_AD_AMOUNT,
		0,
		REASON,
		AD_FLAG
	FROM #AD_TABLE
	
	IF NOT EXISTS(SELECT 1 FROM #EMP_ACTUAL_SAL EAS INNER JOIN #SAL_AD_TABLE SAT ON EAS.EMP_ID = SAT.EMP_ID AND EAS.AD_ID = SAT.AD_ID and EAS.AD_DESCRIPRION = SAT.AD_NAME)
		BEGIN
	
			INSERT INTO #EMP_ACTUAL_SAL
			SELECT 
				ROW_NUMBER() OVER(PARTITION BY EMP_ID ORDER BY EMP_ID) AS SR_NO,
				EMP_ID,
				AD_ID,
				AD_NAME,
				E_AD_AMOUNT,
				0,
				0,
				REASON,
				AD_FLAG
			FROM #SAL_AD_TABLE
		END
	ELSE
		BEGIN

			UPDATE EAS
				SET PREV_AD_AMOUNT = SAT.E_AD_AMOUNT
			FROM #EMP_ACTUAL_SAL EAS 
			INNER JOIN #SAL_AD_TABLE SAT ON EAS.EMP_ID = SAT.EMP_ID AND EAS.AD_ID = SAT.AD_ID and EAS.AD_DESCRIPRION = SAT.AD_NAME
		END
	
	UPDATE EAS
		SET DIFF_AMOUNT =  ISNULL(EAS.CURR_AD_AMOUNT,0) - ISNULL(EAS.PREV_AD_AMOUNT,0)
	From  #EMP_ACTUAL_SAL EAS
	
	DECLARE @cols AS NVARCHAR(MAX),@query  AS NVARCHAR(MAX)

	select  @cols = coalesce(@cols +' ',' ') + Replace(T.AD_DESCRIPRION,' ','_') + ','
	from (
	     select DISTINCT AD_DESCRIPRION
		 from #EMP_ACTUAL_SAL  where DIFF_AMOUNT <> 0
	) T order BY AD_DESCRIPRION


	
	Set @cols = LEFT(@cols, LEN(@cols) - 1)


	IF OBJECT_ID('tempdb..##TempPivot') IS NOT NULL
		Begin
			DROP TABLE ##TempPivot
		End
		
	set @query = '
				 SELECT * Into ##TempPivot
				 FROM (
				 SELECT 1 as Row_ID,''Prev. Month'' as Salary_Month, EMP_ID,' + @cols + ' from 
				 (
					select EMP_ID,Replace(AD_DESCRIPRION,'' '',''_'') as AD_DESCRIPRION,PREV_AD_AMOUNT
					from #EMP_ACTUAL_SAL --where DIFF_AMOUNT <> 0
				 ) x
				pivot 
				(
					SUM(PREV_AD_AMOUNT)
					for AD_DESCRIPRION in (' + @cols + ')
				) p 
				
				Union ALL
				
				SELECT 2 as Row_ID,''Curr. Month'' as Salary_Month, EMP_ID,' + @cols + ' from 
				 (
					select EMP_ID,Replace(AD_DESCRIPRION,'' '',''_'') as AD_DESCRIPRION,CURR_AD_AMOUNT
					from #EMP_ACTUAL_SAL --where DIFF_AMOUNT <> 0
				 ) x
				pivot 
				(
					SUM(CURR_AD_AMOUNT)
					for AD_DESCRIPRION in (' + @cols + ')
				) p 
				
				Union ALL
				
				SELECT 3 as Row_ID,''Diff. Month'' as Salary_Month, EMP_ID,' + @cols + ' from 
				 (
					select EMP_ID,Replace(AD_DESCRIPRION,'' '',''_'') as AD_DESCRIPRION,DIFF_AMOUNT
					from #EMP_ACTUAL_SAL --where DIFF_AMOUNT <> 0
				 ) x
				pivot 
				(
					SUM(DIFF_AMOUNT)
					for AD_DESCRIPRION in (' + @cols + ')
				) p 
				) Tmp'
	print @query
	execute(@query); 


	Select * Into #Temp from ##TempPivot order by Emp_ID,Row_ID
	

	Drop TABLE ##TempPivot
	
	

	Declare @query_str Varchar(max)
	set @query_str = ''
	
	set @query_str = 'SELECT
					CASE WHEN ROW_NUMBER() OVER(PARTITION BY EAS.EMP_ID ORDER BY EAS.EMP_ID) = 1 THEN 1 ELSE 0 END AS Flag,
						CASE WHEN ROW_NUMBER() OVER(PARTITION BY EAS.EMP_ID ORDER BY EAS.EMP_ID) = 1 THEN EM.Alpha_Emp_Code ELSE '' '' END AS Alpha_Emp_Code,
						CASE WHEN ROW_NUMBER() OVER(PARTITION BY EAS.EMP_ID ORDER BY EAS.EMP_ID) = 1 THEN EM.Emp_Full_Name ELSE '' '' END AS Emp_Full_Name,
						CASE WHEN ROW_NUMBER() OVER(PARTITION BY EAS.EMP_ID ORDER BY EAS.EMP_ID) = 1 THEN BM.Branch_Name ELSE '' '' END AS Branch_Name,
						CASE WHEN ROW_NUMBER() OVER(PARTITION BY EAS.EMP_ID ORDER BY EAS.EMP_ID) = 1 THEN DSG.Desig_Name ELSE '' '' END AS Desig_Name,
						CASE WHEN ROW_NUMBER() OVER(PARTITION BY EAS.EMP_ID ORDER BY EAS.EMP_ID) = 1 THEN D.Dept_Name ELSE '' '' END AS Dept_Name,
						EAS.Salary_Month,
						 ' + @cols + '
					FROM #Temp EAS 
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EAS.EMP_ID = EM.EMP_ID
					INNER JOIN #Emp_Cons EC ON EM.EMP_ID = EC.Emp_ID
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = I.Branch_ID
					INNER JOIN T0040_DESIGNATION_MASTER DSG WITH (NOLOCK) ON DSG.Desig_ID = I.Desig_Id
					inner join T0040_DEPARTMENT_MASTER D on D.Dept_Id = I.Dept_ID
					order by D.Dept_Name,EAS.Emp_ID,Row_ID'
	print @query_str
	execute(@query_str); 
	return
	
	end
	else
	Begin
	--Added by ronakk for Variance Report 05012023
	
--Declare @From_Date Datetime = '2023-11-01'
--Declare @To_Date Datetime = '2023-11-30'


Declare @Temp_Date Datetime =Dateadd(month,-1, @From_Date)
Declare @PreF_Date Datetime
Declare @PreT_Date Datetime
set @PreF_Date = DATEADD(MONTH, DATEDIFF(MONTH, 0, @Temp_Date) , 0)  
set @PreT_Date =  DATEADD(SECOND, -1, DATEADD(MONTH, 1,  DATEADD(MONTH, DATEDIFF(MONTH, 0, @Temp_Date) , 0) ) )

--Levels of Shorting
--0 for Earning [Part A]
--1 For Dededucton [Part B]
--2 for Rimbersment [Part C]
--3 for CTC [Part D]
--4 for othet then CTC [Part E]


Create Table #Earning 
(
	rn int,
	sr int,
	Emp_id int,
	AD_id int,
	Particuler nvarchar(max),
	Prev_Amt numeric(18,2),
	Curr_Amt numeric(18,2),
	Diff_Amt numeric(18,2)

)

-------------------------------------------For Basic Sal--------------------------------------------------







insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Basic Salary' Particuler ,
(isnull(Prev.salary_Amount,0)) Prev_Amt,(isnull(Curr.salary_Amount,0))  Curr_Amt
,(isnull(Curr.salary_Amount,0)) - (isnull(Prev.salary_Amount,0)) Diff_Amt
from #Emp_Cons EC 
left join  (select MS.Emp_ID,(salary_Amount  + isnull(Arear_Basic,0)) salary_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,(salary_Amount  + isnull(Arear_Basic,0)) salary_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on EC.Emp_ID = Curr.Emp_ID 




Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #Earning E
inner join (select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Basic Salary' Particuler ,
isnull(sum(Prev.S_Salary_Amount),0) Prev_Amt,isnull(sum(Curr.S_Salary_Amount),0) Curr_Amt
,isnull(sum(Curr.S_Salary_Amount),0) - isnull(sum(Prev.S_Salary_Amount),0) Diff_Amt
from #Emp_Cons EC
left join  (select MS.Emp_ID,Sum(S_Salary_Amount) S_Salary_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID =  EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_Salary_Amount) S_Salary_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID
Group by EC.Emp_ID) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Basic Salary'

-------------------------------------------For Basic Sal--------------------------------------------------


-------------------------------------------For OT Amount--------------------------------------------------

insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'OT Amount' Particuler ,
isnull(Prev.OT_Amount,0) Prev_Amt,isnull(Curr.OT_Amount,0) Curr_Amt
,isnull(Curr.OT_Amount,0) - isnull(Prev.OT_Amount,0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,OT_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,OT_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID 





Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #Earning E
inner join (
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'OT Amount' Particuler ,
isnull(sum(Prev.S_OT_Amount),0) Prev_Amt,isnull(sum(Curr.S_OT_Amount),0) Curr_Amt
,isnull(sum(Curr.S_OT_Amount),0) - isnull(sum(Prev.S_OT_Amount),0) Diff_Amt
from  #Emp_Cons EC
left join  (select MS.Emp_ID,Sum(S_OT_Amount) S_OT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_OT_Amount) S_OT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID  = EC.Emp_ID
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'OT Amount'

-------------------------------------------For OT Amount--------------------------------------------------


-------------------------------------------For Week Off Working--------------------------------------------------

insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Week Off Working' Particuler ,
isnull(Prev.M_WO_OT_Amount,0) Prev_Amt,isnull(Curr.M_WO_OT_Amount,0) Curr_Amt
,isnull(Curr.M_WO_OT_Amount,0) - isnull(Prev.M_WO_OT_Amount,0) Diff_Amt
from  #Emp_Cons EC  
left join  (select MS.Emp_ID,M_WO_OT_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,M_WO_OT_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on  Curr.Emp_ID = EC.Emp_ID 




Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #Earning E
inner join (select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Week Off Working' Particuler ,
isnull(sum(Prev.S_WO_OT_Amount),0) Prev_Amt,isnull(sum(Curr.S_WO_OT_Amount),0) Curr_Amt
,isnull(sum(Curr.S_WO_OT_Amount),0) - isnull(sum(Prev.S_WO_OT_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_WO_OT_Amount) S_WO_OT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,Sum(S_WO_OT_Amount) S_WO_OT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)    
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID 
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Week Off Working'



-------------------------------------------For Week Off Working--------------------------------------------------

-------------------------------------------For Holiday Working--------------------------------------------------

insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Holiday Working' Particuler ,
isnull(Prev.M_HO_OT_Amount,0) Prev_Amt,isnull(Curr.M_HO_OT_Amount,0) Curr_Amt
,isnull(Curr.M_HO_OT_Amount,0) - isnull(Prev.M_HO_OT_Amount,0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,M_HO_OT_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,M_HO_OT_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on  Curr.Emp_ID =EC.Emp_ID



Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #Earning E
inner join (
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Holiday Working' Particuler ,
isnull(sum(Prev.S_HO_OT_Amount),0) Prev_Amt,isnull(sum(Curr.S_HO_OT_Amount),0) Curr_Amt
,isnull(sum(Curr.S_HO_OT_Amount),0) - isnull(sum(Prev.S_HO_OT_Amount),0) Diff_Amt
from #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_HO_OT_Amount) S_HO_OT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_HO_OT_Amount) S_HO_OT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date) 
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID =EC.Emp_ID
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Holiday Working'


-------------------------------------------For Holiday Working--------------------------------------------------

-------------------------------------------For Leave Encash Amount--------------------------------------------------

insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Leave Encash Amount' Particuler ,
isnull(Prev.Leave_Salary_Amount ,0) Prev_Amt,isnull(Curr.Leave_Salary_Amount,0) Curr_Amt
,isnull(Curr.Leave_Salary_Amount,0) - isnull(Prev.Leave_Salary_Amount,0) Diff_Amt
from  #Emp_Cons EC
left join  (select MS.Emp_ID,Leave_Salary_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,Leave_Salary_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID 

-------------------------------------------For Leave Encash Amount--------------------------------------------------


-------------------------------------------For Claim Amount--------------------------------------------------

insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Claim Amount' Particuler ,
isnull(Prev.Total_Claim_Amount ,0) Prev_Amt,isnull(Curr.Total_Claim_Amount,0) Curr_Amt
,isnull(Curr.Total_Claim_Amount,0) - isnull(Prev.Total_Claim_Amount,0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Total_Claim_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,Total_Claim_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID 





Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #Earning E
inner join (
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Claim Amount' Particuler ,
isnull(sum(Prev.S_Total_Claim_Amount),0) Prev_Amt,isnull(sum(Curr.S_Total_Claim_Amount),0) Curr_Amt
,isnull(sum(Curr.S_Total_Claim_Amount),0) - isnull(sum(Prev.S_Total_Claim_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_Total_Claim_Amount) S_Total_Claim_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_Total_Claim_Amount) S_Total_Claim_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Claim Amount'


-------------------------------------------For Claim Amount--------------------------------------------------


-------------------------------------------For Travel Amount--------------------------------------------------

insert into #Earning   
select 0 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Travel Amount' Particuler ,
isnull(Prev.Travel_Amount,0) Prev_Amt,isnull(Curr.Travel_Amount,0) Curr_Amt
,isnull(Curr.Travel_Amount,0) - isnull(Prev.Travel_Amount,0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Travel_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Travel_Amount from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID


-------------------------------------------For Travel Amount--------------------------------------------------


------------------------------------------------For Earnig ---------------------------------------------------

Insert into #Earning  
select 0 as rn,AD.AD_LEVEL,EC.Emp_ID,AD.AD_ID,AD.AD_NAME,
0 PrvAmt,0 CurAmt
,0 DiffAmt
from  #Emp_Cons EC
cross join T0050_AD_MASTER AD
where CMP_ID =@CMP_ID and AD_NOT_EFFECT_SALARY =0 and AD_FLAG ='I' 



Update Curr set Curr_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #Earning Curr on Curr.Emp_id = MAD.Emp_id and Curr.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @From_Date and @To_Date and S_Sal_Tran_ID is null


Update Prev set Prev_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0)) ,Diff_Amt = Curr_Amt - (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #Earning Prev on Prev.Emp_id = MAD.Emp_id and Prev.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @PreF_Date and @PreT_Date and S_Sal_Tran_ID is null


Update Curr set Curr.Curr_Amt = (Curr.Curr_Amt + Sett.CurrAmt) ,Diff_Amt = (Curr.Curr_Amt + Sett.CurrAmt) - Prev_Amt
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as CurrAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #Earning Curr on Curr.Emp_id = Sett.Emp_id and Curr.AD_id = Sett.AD_ID


Update prev set prev.Prev_Amt = (prev.Prev_Amt + Sett.PrvAmt),prev.Diff_Amt = prev.Curr_Amt - (prev.Prev_Amt + Sett.PrvAmt)
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as PrvAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #Earning prev on prev.Emp_id = Sett.Emp_id and prev.AD_id = Sett.AD_ID

Update #Earning set Diff_Amt = case when Curr_amt > 0 and Prev_amt = 0 then Curr_amt else Prev_amt END  where  Prev_amt = 0 and Curr_amt > 0



------------------------------------------------For Earnig ---------------------------------------------------
--select * from #Earning


Create Table #EmployeeContribution 
(
	rn int,
	sr int,
	Emp_id int,
	AD_id int,
	Particuler nvarchar(max),
	Prev_Amt numeric(18,2),
	Curr_Amt numeric(18,2),
	Diff_Amt numeric(18,2)

)

-------------------------------------------For LWF Sal Ded--------------------------------------------------

insert into  #EmployeeContribution 
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'LWF' Particuler ,
isnull(Prev.LWF_Amount,0) Prev_Amt,isnull(Curr.LWF_Amount,0) Curr_Amt
,isnull(Curr.LWF_Amount,0) - isnull(Prev.LWF_Amount,0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,LWF_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID =  EC.Emp_ID
left join  (select MS.Emp_ID,LWF_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID =  EC.Emp_ID 







Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #EmployeeContribution E
inner join (
select 1 as rn,0 as sr , EC.Emp_ID,0 AD_id,'LWF' Particuler ,
isnull(sum(Prev.S_LWF_Amount),0) Prev_Amt,isnull(sum(Curr.S_LWF_Amount),0) Curr_Amt
,isnull(sum(Curr.S_LWF_Amount),0) - isnull(sum(Prev.S_LWF_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_LWF_Amount) S_LWF_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID =  EC.Emp_ID 
left join  (select MS.Emp_ID,Sum(S_LWF_Amount) S_LWF_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID =  EC.Emp_ID
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'LWF'


-------------------------------------------For LWF Sal Ded--------------------------------------------------


-------------------------------------------For PT Sal Ded--------------------------------------------------





insert into  #EmployeeContribution 
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'PT' Particuler ,
isnull(Prev.PT_Amount,0) Prev_Amt,isnull(Curr.PT_Amount,0) Curr_Amt
,isnull(Curr.PT_Amount,0) - isnull(Prev.PT_Amount,0) Diff_Amt 
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,PT_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,PT_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID


Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #EmployeeContribution E
inner join (
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'PT' Particuler ,
isnull(sum(Prev.S_PT_Amount),0) Prev_Amt,isnull(sum(Curr.S_PT_Amount),0) Curr_Amt
,isnull(sum(Curr.S_PT_Amount),0) - isnull(sum(Prev.S_PT_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_PT_Amount) S_PT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_PT_Amount) S_PT_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)    
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'PT'


-------------------------------------------For PT Sal Ded--------------------------------------------------



-------------------------------------------For Advance Amount--------------------------------------------------

insert into  #EmployeeContribution 
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Advance Amount' Particuler ,
isnull(Prev.Advance_Amount,0) Prev_Amt,isnull(Curr.Advance_Amount,0) Curr_Amt
,isnull(Curr.Advance_Amount,0) - isnull(Prev.Advance_Amount,0) Diff_Amt 
from #Emp_Cons EC
left join  (select MS.Emp_ID,Advance_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Advance_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID






Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #EmployeeContribution E
inner join (
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Advance Amount' Particuler ,
isnull(sum(Prev.S_M_Adv_Amount),0) Prev_Amt,isnull(sum(Curr.S_M_Adv_Amount),0) Curr_Amt
,isnull(sum(Curr.S_M_Adv_Amount),0) - isnull(sum(Prev.S_M_Adv_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_M_Adv_Amount) S_M_Adv_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_M_Adv_Amount) S_M_Adv_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)    
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID =EC.Emp_ID
  
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Advance Amount'

-------------------------------------------For Advance Amount--------------------------------------------------


-------------------------------------------For Loan Amount--------------------------------------------------

insert into  #EmployeeContribution 
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Loan Amount' Particuler ,
isnull(Prev.Loan_Amount,0) Prev_Amt,isnull(Curr.Loan_Amount,0) Curr_Amt
,isnull(Curr.Loan_Amount,0) - isnull(Prev.Loan_Amount,0) Diff_Amt 
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Loan_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,Loan_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID 




Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #EmployeeContribution E
inner join (
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Loan Amount' Particuler ,
isnull(sum(Prev.S_Loan_Amount),0) Prev_Amt,isnull(sum(Curr.S_Loan_Amount),0) Curr_Amt
,isnull(sum(Curr.S_Loan_Amount),0) - isnull(sum(Prev.S_Loan_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_Loan_Amount) S_Loan_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Sum(S_Loan_Amount) S_Loan_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)  
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID
group by EC.Emp_ID
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Loan Amount'


-------------------------------------------For Loan Amount--------------------------------------------------

-------------------------------------------For Loan Interest--------------------------------------------------

insert into  #EmployeeContribution 
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Loan Interest' Particuler ,
isnull(Prev.Loan_Intrest_Amount,0) Prev_Amt,isnull(Curr.Loan_Intrest_Amount,0) Curr_Amt
,isnull(Curr.Loan_Intrest_Amount,0) - isnull(Prev.Loan_Intrest_Amount,0) Diff_Amt 
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Loan_Intrest_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,Loan_Intrest_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date 
			) Curr on Curr.Emp_ID = EC.Emp_ID




Update E set E.Prev_Amt = (E.Prev_Amt + Sett.Prev_Amt),
			 E.Curr_Amt = (E.Curr_Amt + Sett.Curr_Amt ),
			 E.Diff_Amt = (E.Diff_Amt + Sett.Diff_Amt ) from #EmployeeContribution E
inner join (
select 1 as rn,0 as sr , EC.Emp_ID ,0 AD_id,'Loan Interest' Particuler ,
isnull(sum(Prev.S_Loan_Intrest_Amount),0) Prev_Amt,isnull(sum(Curr.S_Loan_Intrest_Amount),0) Curr_Amt
,isnull(sum(Curr.S_Loan_Intrest_Amount),0) - isnull(sum(Prev.S_Loan_Intrest_Amount),0) Diff_Amt
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,Sum(S_Loan_Intrest_Amount) S_Loan_Intrest_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
				group by MS.Emp_ID,S_Eff_Date
			) Prev on Prev.Emp_ID = EC.Emp_ID 
left join  (select MS.Emp_ID,Sum(S_Loan_Intrest_Amount) S_Loan_Intrest_Amount from T0201_Monthly_Salary_Sett MS 
				inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
				where cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date) 
				group by MS.Emp_ID,S_Eff_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID 
  
group by  EC.Emp_ID 
) AS Sett on Sett.Emp_ID = E.Emp_id and E.Particuler = Sett.Particuler
where E.Particuler = 'Loan Interest'


-------------------------------------------For Loan Interest--------------------------------------------------

-------------------------------------------For Travel Advance Amount--------------------------------------------------

insert into  #EmployeeContribution 
select 1 as rn,0 as sr ,EC.Emp_ID,0 AD_id,'Travel Advance Amount' Particuler ,
isnull(Prev.travel_Advance_Amount,0) Prev_Amt,isnull(Curr.travel_Advance_Amount,0) Curr_Amt
,isnull(Curr.travel_Advance_Amount,0) - isnull(Prev.travel_Advance_Amount,0) Diff_Amt 
from  #Emp_Cons EC 
left join  (select MS.Emp_ID,travel_Advance_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date 
			) Prev on Prev.Emp_ID = EC.Emp_ID
left join  (select MS.Emp_ID,travel_Advance_Amount from T0200_MONTHLY_SALARY MS 
			inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date
			) Curr on Curr.Emp_ID = EC.Emp_ID 
 


-------------------------------------------For Travel Advance Amount--------------------------------------------------



------------------------------------------For Deduction of Comp -----------------------------------------



Insert into #EmployeeContribution  
select 1 as rn,AD.AD_LEVEL,EC.Emp_ID,AD.AD_ID,AD.AD_NAME,
0 PrvAmt,0 CurAmt
,0 DiffAmt
from  #Emp_Cons EC
cross join T0050_AD_MASTER AD
where CMP_ID =@CMP_ID  and AD_PART_OF_CTC = 0  and AD_FLAG ='D' 

Update Curr set Curr_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #EmployeeContribution Curr on Curr.Emp_id = MAD.Emp_id and Curr.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @From_Date and @To_Date and S_Sal_Tran_ID is null


Update Prev set Prev_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0)) ,Diff_Amt = Curr_Amt - (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #EmployeeContribution Prev on Prev.Emp_id = MAD.Emp_id and Prev.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id 
and For_Date between @PreF_Date and @PreT_Date 
and S_Sal_Tran_ID is null


Update Curr set Curr.Curr_Amt = (Curr.Curr_Amt + Sett.CurrAmt) ,Diff_Amt = (Curr.Curr_Amt + Sett.CurrAmt) - Prev_Amt
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as CurrAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #EmployeeContribution Curr on Curr.Emp_id = Sett.Emp_id and Curr.AD_id = Sett.AD_ID


Update prev set prev.Prev_Amt = (prev.Prev_Amt + Sett.PrvAmt),prev.Diff_Amt = prev.Curr_Amt - (prev.Prev_Amt + Sett.PrvAmt)
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as PrvAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #EmployeeContribution prev on prev.Emp_id = Sett.Emp_id and prev.AD_id = Sett.AD_ID

Update #EmployeeContribution set Diff_Amt = case when Curr_amt > 0 and Prev_amt = 0 then Curr_amt else Prev_amt END  where  Prev_amt = 0 and Curr_amt > 0



------------------------------------------For Deduction of Comp -----------------------------------------
--select * from #EmployeeContribution

Create Table #EmplyerContribution
(
	rn int,
	sr int,
    Emp_id int,
	AD_id int,
	Particuler nvarchar(max),
	Prev_Amt numeric(18,2),
	Curr_Amt numeric(18,2),
	Diff_Amt numeric(18,2)

)

------------------------------------------For CTC of Comp -----------------------------------------


Insert into #EmplyerContribution  
select 3 as rn,AD.AD_LEVEL,EC.Emp_ID,AD.AD_ID,AD.AD_NAME,
0 PrvAmt,0 CurAmt
,0 DiffAmt
from  #Emp_Cons EC
cross join T0050_AD_MASTER AD
where CMP_ID =@CMP_ID  and AD_PART_OF_CTC = 1 and AD_NOT_EFFECT_SALARY =1 and Allowance_Type ='A'

Update Curr set Curr_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #EmplyerContribution Curr on Curr.Emp_id = MAD.Emp_id and Curr.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @From_Date and @To_Date and S_Sal_Tran_ID is null


Update Prev set Prev_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0)) ,Diff_Amt = Curr_Amt - (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #EmplyerContribution Prev on Prev.Emp_id = MAD.Emp_id and Prev.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @PreF_Date and @PreT_Date and S_Sal_Tran_ID is null


Update Curr set Curr.Curr_Amt = (Curr.Curr_Amt + Sett.CurrAmt) ,Diff_Amt = (Curr.Curr_Amt + Sett.CurrAmt) - Prev_Amt
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as CurrAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #EmplyerContribution Curr on Curr.Emp_id = Sett.Emp_id and Curr.AD_id = Sett.AD_ID

Update prev set prev.Prev_Amt = (prev.Prev_Amt + Sett.PrvAmt),prev.Diff_Amt = prev.Curr_Amt - (prev.Prev_Amt + Sett.PrvAmt)
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as PrvAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #EmplyerContribution prev on prev.Emp_id = Sett.Emp_id and prev.AD_id = Sett.AD_ID


Update #EmplyerContribution set Diff_Amt = case when Curr_amt > 0 and Prev_amt = 0 then Curr_amt else Prev_amt END  where  Prev_amt = 0 and Curr_amt > 0



------------------------------------------For Deduction of Comp -----------------------------------------


Create Table #Reimbursement
(
	rn int,
	sr int,
    Emp_id int,
	AD_id int,
	Particuler nvarchar(max),
	Prev_Amt numeric(18,2),
	Curr_Amt numeric(18,2),
	Diff_Amt numeric(18,2)

)

------------------------------------------For Reimbursement -----------------------------------------


Insert into #Reimbursement  
select 2 as rn,AD.AD_LEVEL,EC.Emp_ID,AD.AD_ID,AD.AD_NAME,
0 PrvAmt,0 CurAmt
,0 DiffAmt
from  #Emp_Cons EC
cross join T0050_AD_MASTER AD
where CMP_ID =@CMP_ID and AD_PART_OF_CTC = 1 and AD_NOT_EFFECT_SALARY =1   and Allowance_Type ='R'

Update Curr set Curr_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #Reimbursement Curr on Curr.Emp_id = MAD.Emp_id and Curr.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @From_Date and @To_Date and S_Sal_Tran_ID is null


Update Prev set Prev_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0)) ,Diff_Amt = Curr_Amt - (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #Reimbursement Prev on Prev.Emp_id = MAD.Emp_id and Prev.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @PreF_Date and @PreT_Date and S_Sal_Tran_ID is null



Update Curr set Curr.Curr_Amt = (Curr.Curr_Amt + Sett.CurrAmt) ,Diff_Amt = (Curr.Curr_Amt + Sett.CurrAmt) - Prev_Amt
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as CurrAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #Reimbursement Curr on Curr.Emp_id = Sett.Emp_id and Curr.AD_id = Sett.AD_ID


Update prev set prev.Prev_Amt = (prev.Prev_Amt + Sett.PrvAmt),prev.Diff_Amt = prev.Curr_Amt - (prev.Prev_Amt + Sett.PrvAmt)
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as PrvAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #Reimbursement prev on prev.Emp_id = Sett.Emp_id and prev.AD_id = Sett.AD_ID

Update #Reimbursement set Diff_Amt = case when Curr_amt > 0 and Prev_amt = 0 then Curr_amt else Prev_amt END  where  Prev_amt = 0 and Curr_amt > 0

------------------------------------------For Reimbursement -----------------------------------------



Create Table #OtherthenCTC
(
	rn int,
	sr int,
    Emp_id int,
	AD_id int,
	Particuler nvarchar(max),
	Prev_Amt numeric(18,2),
	Curr_Amt numeric(18,2),
	Diff_Amt numeric(18,2)

)


------------------------------------------For OtherthenCTC  -----------------------------------------

Insert into #OtherthenCTC  
select 4 as rn,AD.AD_LEVEL,EC.Emp_ID,AD.AD_ID,AD.AD_NAME,
0 PrvAmt,0 CurAmt
,0 DiffAmt
from  #Emp_Cons EC
cross join T0050_AD_MASTER AD
where CMP_ID =@CMP_ID and AD_PART_OF_CTC = 0 and AD_NOT_EFFECT_SALARY =1 and AD_FLAG ='I'

Update Curr set Curr_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #OtherthenCTC Curr on Curr.Emp_id = MAD.Emp_id and Curr.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @From_Date and @To_Date and S_Sal_Tran_ID is null


Update Prev set Prev_Amt = (M_AD_Amount + isnull(M_AREAR_AMOUNT,0)) ,Diff_Amt = Curr_Amt - (M_AD_Amount + isnull(M_AREAR_AMOUNT,0))
from T0210_MONTHLY_AD_DETAIL MAD 
inner join #OtherthenCTC Prev on Prev.Emp_id = MAD.Emp_id and Prev.AD_id = MAD.AD_ID
where MAD.Cmp_ID = @Cmp_id and For_Date between @PreF_Date and @PreT_Date and S_Sal_Tran_ID is null



Update Curr set Curr.Curr_Amt = (Curr.Curr_Amt + Sett.CurrAmt)  ,Diff_Amt = (Curr.Curr_Amt + Sett.CurrAmt) - Prev_Amt
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as CurrAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #OtherthenCTC Curr on Curr.Emp_id = Sett.Emp_id and Curr.AD_id = Sett.AD_ID


Update prev set prev.Prev_Amt = (prev.Prev_Amt + Sett.PrvAmt),prev.Diff_Amt = prev.Curr_Amt - (prev.Prev_Amt + Sett.PrvAmt)
from
(select Mss.Emp_ID,S.AD_ID,  isnull(sum(M_AD_Amount),0) as PrvAmt
from T0201_MONTHLY_SALARY_SETT MSS 
left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
where S.cmp_id =@cmp_id and Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date)   
group by Mss.Emp_ID, s.AD_ID) Sett
inner join #OtherthenCTC prev on prev.Emp_id = Sett.Emp_id and prev.AD_id = Sett.AD_ID

Update #OtherthenCTC set Diff_Amt = case when Curr_amt > 0 and Prev_amt = 0 then Curr_amt else Prev_amt END  where  Prev_amt = 0 and Curr_amt > 0


------------------------------------------For OtherthenCTC  -----------------------------------------

If 1=1
Begin


--For Summery ----------------------------------------------------------------------------------------------------------
select 
 -1 as RN,'[Head Count]' as Particuler ,
(select Count(MS.Emp_ID) Prev from T0200_MONTHLY_SALARY MS 
inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date ) PrvAmt,

(select Count(MS.Emp_ID) Curr from T0200_MONTHLY_SALARY MS 
inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date ) CurrAmt,


((select Count(MS.Emp_ID) Curr from T0200_MONTHLY_SALARY MS 
inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
where cmp_id =@cmp_id and month_st_date >= @From_Date and Month_End_Date < = @To_Date ) 
-
(select Count(MS.Emp_ID) Prev from T0200_MONTHLY_SALARY MS 
inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
where cmp_id =@cmp_id and month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date )) Diff

union
select 0 as RN,'[Earning]' as Particuler ,null PrvAmt,null CurrAmt,null Diff
union
Select 0,Particuler,sum(Prev_Amt),sum(Curr_Amt),sum(Diff_Amt) from #Earning
group by Particuler
union
select 01,'[Gross Salary]',isnull(sum(Prev_Amt),0),isnull(sum(Curr_Amt),0),isnull(sum(Diff_Amt),0) from #Earning
union
select 8,null,null,null,null
union
select 9,'[Employee Contribution]',null,null,null
union
Select 10,Particuler,sum(Prev_Amt),sum(Curr_Amt),sum(Diff_Amt) from #EmployeeContribution
group by Particuler
union
select 11,'[Total Deduction]',isnull(sum(Prev_Amt),0),isnull(sum(Curr_Amt),0),isnull(sum(Diff_Amt),0) from #EmployeeContribution
union

SELECT top 1  12,'[Net Take Home]',
  LEAD(prv, 1, 0) OVER (ORDER BY rn) - prv as  prv,
  LEAD(crr, 1, 0) OVER (ORDER BY rn) - crr as  crr,
  LEAD(diff, 1, 0) OVER (ORDER BY rn) - diff as  diff
FROM
(
select 1 rn,isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff from #EmployeeContribution
union
select 2 rn,isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff from #Earning
) as Src

union
select 13,null,null,null,null
union
select 14,'[Reimbursement]',null,null,null
union
Select 15,Particuler,sum(Prev_Amt),sum(Curr_Amt),sum(Diff_Amt) from #Reimbursement
group by Particuler
union
Select 16,'[Total Reimbursement]',isnull(sum(Prev_Amt),0),isnull(sum(Curr_Amt),0),isnull(sum(Diff_Amt),0) from #Reimbursement
union
select 28,null,null,null,null
union
select 29,'[Employer Contribution]',null,null,null
union
Select 30,Particuler,sum(Prev_Amt),sum(Curr_Amt),sum(Diff_Amt) from #EmplyerContribution
group by Particuler
union
select 31,'[Total Employer Contribution]',isnull(sum(Prev_Amt),0),isnull(sum(Curr_Amt),0),isnull(sum(Diff_Amt),0)  from #EmplyerContribution
union
select 33,'[CTC]', isnull(sum(prv),0) prv,isnull(sum(crr),0) crr,isnull(sum(diff),0) diff from
(
select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff from #Earning
union
Select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff from #Reimbursement
union
select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff  from #EmplyerContribution
) src
union
select 34,null,null,null,null
union
select 40,'[Other then CTC]',null,null,null
union
Select 41,Particuler,sum(Prev_Amt),sum(Curr_Amt),sum(Diff_Amt) from #OtherthenCTC
group by Particuler
union
select 42,'[Total Other then CTC]',isnull(sum(Prev_Amt),0),isnull(sum(Curr_Amt),0),isnull(sum(Diff_Amt),0) from #OtherthenCTC
union
select 43,'[Total Other then CTC] + [CTC]', isnull(sum(prv),0) prv,isnull(sum(crr),0) crr,isnull(sum(diff),0) diff from
(
select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff from #Earning
union
Select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff from #Reimbursement
union
select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff  from #EmplyerContribution
union
select isnull(sum(Prev_Amt),0) prv,isnull(sum(Curr_Amt),0) crr,isnull(sum(Diff_Amt),0) diff  from #OtherthenCTC
) src



---For Summery -----------------------------------------------------------------------------------------------------
End


Create Table #FinalEmpDetails
(
rn int IDENTITY(1,1) PRIMARY KEY,
Particuler nvarchar(max),
Emp_Code nvarchar(max),
Emp_FullName nvarchar(max),
Branch nvarchar(max),
Grade nvarchar(max),
Department nvarchar(max),
Designation nvarchar(max),
EMPLOYEE_TYPE  nvarchar(max),   
CATEGORY nvarchar(max),
DATE_OF_JOIN Datetime,
Date_OF_Left Datetime,
Allownce_Name nvarchar(max),
Previous_Amt Numeric(18,2),
Current_Amt Numeric(18,2),
Difference_Amt Numeric(18,2),
Remarks Nvarchar(Max)
)



If 1=1
Begin

Declare @rn int
declare @Partic nvarchar(max)

DECLARE cr_Allow_Sep CURSOR FAST_FORWARD FOR

select rn,Particuler from
(select * from #Earning
union
select * from #EmployeeContribution
union
select * from #Reimbursement
union
select 3 as RN,null,null,null,null as Particuler ,null PrvAmt,null CurrAmt,1 Diff --Break
union
select * from #EmplyerContribution
union
select * from #OtherthenCTC
) FinalTab
where Diff_Amt <> 0
group by Particuler,rn 

OPEN cr_Allow_Sep				
fetch next from cr_Allow_Sep into @rn,@Partic
while @@fetch_status = 0
Begin
				
		
insert into #FinalEmpDetails	
select  @Partic,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails
select '',EM.Alpha_Emp_Code,EM.Emp_Full_Name,BM.Branch_Name,GM.Grd_Name,D.Dept_Name,DM.Desig_Name,
TM.Type_Name,CM.Cat_Name,EM.Date_Of_Join,EM.Emp_Left_Date,
FinalTab.Particuler, FinalTab.Prev_Amt,FinalTab.Curr_Amt,FinalTab.Diff_Amt
,Case 
When AD.AD_CALCULATE_ON='Import' then isnull(ADI.Comments,'')

When (Month(EM.Emp_Left_Date) = Month(@PreT_Date) and year(EM.Emp_Left_Date) = year(@PreT_Date))
	 or (Month(EM.Emp_Left_Date) = Month(@To_Date) and year(EM.Emp_Left_Date) = year(@To_Date))
	 Then 'Left'

When (Month(EM.Date_Of_Join) = Month(@PreT_Date) and year(EM.Date_Of_Join) = year(@PreT_Date))
or (Month(EM.Date_Of_Join) = Month(@To_Date) and year(EM.Date_Of_Join) = year(@To_Date))
	Then 'Joining'

When (Increment_Effective_Date>=@PreT_Date) or (I.Increment_Effective_Date >= @To_Date)
Then 'Increment'

else
'Loss of Pay'
end
from
(select * from #Earning
union
select * from #EmployeeContribution
union
select * from #Reimbursement
union
select * from #EmplyerContribution
union
select * from #OtherthenCTC
) FinalTab
inner join T0080_EMP_MASTER EM on EM.Emp_ID = FinalTab.Emp_id
inner join T0095_INCREMENT I on I.Emp_ID = FinalTab.Emp_id and EM.Increment_ID = I.Increment_ID
left join T0190_MONTHLY_AD_DETAIL_IMPORT ADI on ADI.AD_ID = FinalTab.AD_id and ADI.Emp_ID = FinalTab.Emp_id and [Month] = month(@To_Date) and [Year] = year(@To_Date)
left join T0050_AD_MASTER Ad ON FinalTab.AD_id = AD.AD_ID
left join T0040_DESIGNATION_MASTER DM on DM.Desig_ID = I.Desig_Id
left join T0030_BRANCH_MASTER BM on BM.Branch_ID = I.Branch_ID
left join T0040_DEPARTMENT_MASTER D on D.Dept_Id = I.Dept_ID
left join T0040_GRADE_MASTER GM on GM.Grd_ID = I.Grd_ID
left join T0040_TYPE_MASTER TM on TM.Type_ID = I.Type_ID
left join T0030_CATEGORY_MASTER CM on CM.Cat_ID = I.Cat_ID
where Diff_Amt <> 0 and FinalTab.Particuler = @Partic



insert into #FinalEmpDetails	
select '[ Total of '+FinalTab.Particuler+' ]',null,null,null,null,null,null,null,null,null,null,
'[ Total of '+FinalTab.Particuler+' ]', Sum(FinalTab.Prev_Amt),Sum(FinalTab.Curr_Amt),Sum(FinalTab.Diff_Amt),'[Total]'

from
(select * from #Earning
union
select * from #EmployeeContribution
union
select * from #Reimbursement
union
select * from #EmplyerContribution
union
select * from #OtherthenCTC
) FinalTab
where Diff_Amt <> 0 and FinalTab.Particuler = @Partic
group by FinalTab.Particuler

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null


if @rn =3 and @Partic is null
Begin

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null


insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  '[Breakup after Net Take Home]',Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null

insert into #FinalEmpDetails	
select  null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null,Null, Null,Null,Null,Null



End


If @Partic in ('Basic Salary','OT Amount','Week Off Working','Holiday Working','Claim Amount','LWF','PT','Advance Amount','Loan Amount','Loan Interest')
Begin

		if @Partic = 'Basic Salary'
		Begin
		
			Update #FinalEmpDetails set Remarks='Arrear' where Allownce_Name = @Partic
			and Emp_Code in (Select EM.Alpha_Emp_Code from T0200_MONTHLY_SALARY MS 
            inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
			inner join T0080_EMP_MASTER EM on EM.Emp_ID = EC.Emp_id
			where MS.Cmp_ID =@cmp_id and
			((month_st_date >= @PreF_Date and Month_End_Date < = @PreT_Date)
			or (month_st_date >= @From_Date and Month_End_Date < = @To_Date))
			and isnull(Arear_Basic,0) > 0)
		
		
		End

 
	   

		Update #FinalEmpDetails set Remarks='Settlement' where Allownce_Name = @Partic
		and Emp_Code in 	(select EM.Alpha_Emp_Code from T0201_Monthly_Salary_Sett MS 
		inner join #Emp_Cons EC on EC.Emp_ID = MS.Emp_ID
		inner join T0080_EMP_MASTER EM on EM.Emp_ID = EC.Emp_id
		where MS.Cmp_ID =@cmp_id and(( Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date))
		or ( Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)))
		group by MS.Emp_ID,S_Eff_Date,EM.Alpha_Emp_Code)


		if @Partic  in ('LWF','PT','Loan Amount','Loan Interest')
		Begin	
			Update #FinalEmpDetails set Remarks='' where Allownce_Name = @Partic
		End


End
else
Begin


		Update FS set Remarks='Arrear' from #FinalEmpDetails FS
		inner join 
		   (select  EM.Alpha_Emp_Code,AD.AD_NAme
		   from T0210_MONTHLY_AD_DETAIL MAD 
		   inner join #Emp_Cons EC on EC.Emp_ID = MAD.Emp_ID
		   inner join T0080_EMP_MASTER EM on EM.Emp_ID = EC.Emp_id
		   inner join T0050_AD_MASTER AD on AD.AD_ID = MAD.AD_ID
		   where MAD.Cmp_ID = @Cmp_id and 
		   ((For_Date between @PreF_Date and @PreT_Date) or (For_Date between @From_Date and @To_Date))
			and S_Sal_Tran_ID is null and  isnull(M_AREAR_AMOUNT,0) > 0) SR
			on FS.Emp_Code = SR.Alpha_Emp_Code and  FS.Allownce_Name = SR.AD_Name



		Update FS set Remarks='Settlement' from #FinalEmpDetails FS
		inner join 
		(select EM.Alpha_Emp_Code,AD.AD_Name
		from T0201_MONTHLY_SALARY_SETT MSS 
		left join T0210_MONTHLY_AD_DETAIL S on mss.S_Sal_Tran_ID = s.S_Sal_Tran_ID
		inner join #Emp_Cons EC on EC.Emp_ID = MSS.Emp_ID
		inner join T0080_EMP_MASTER EM on EM.Emp_ID = EC.Emp_id
		inner join T0050_AD_MASTER AD on AD.AD_ID = S.AD_ID
		where S.cmp_id =@cmp_id and (( Month(S_Eff_Date) =Month(@PreT_Date) and Year(S_Eff_Date) = Year(@PreT_Date))
		or ( Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)))
		and AD.AD_Name = @Partic and S.M_AD_Amount <>0
		group by Mss.Emp_ID, s.AD_ID,EM.Alpha_Emp_Code,AD.AD_Name) SR 
		on FS.Emp_Code = SR.Alpha_Emp_Code and  FS.Allownce_Name = SR.AD_Name
		

		--For TDS Remark Remove
		Update FS set Remarks='' from #FinalEmpDetails FS
		inner join 
		 (SELECT AD_NAME FROM T0050_AD_MASTER 
		 where CMP_ID = @CMP_ID and AD_DEF_ID in (1,13)) AD on AD.AD_NAME = FS.Allownce_Name 


End

	fetch next from cr_Allow_Sep into @rn,@Partic
End
close cr_Allow_Sep	
deallocate cr_Allow_Sep




Select * from #FinalEmpDetails order by rn

End

drop table #Earning
drop table #EmployeeContribution
drop table #Reimbursement
drop table #EmplyerContribution
drop table #OtherthenCTC
drop Table #FinalEmpDetails

	
	
	
	end

	
END

