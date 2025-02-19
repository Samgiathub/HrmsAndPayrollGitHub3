


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_rpt_Increment_Letter_Format1]
	 @Cmp_ID		numeric
	,@Year			int
	,@Month			int
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
	If @Desig_ID = 0
		set @Desig_ID = null
		
		DECLARE @From_Date AS DATETIME
		DECLARE @To_Date AS DATETIME
		
		--SET @From_Date = CAST(cast(@Year AS INT)-3 AS VARCHAR(5))+'-04-'+'01'
		
		IF 4 <= @Month 
		BEGIN 
				SET @From_Date = CAST(cast(@Year AS INT)-3 AS VARCHAR(5))+'-04-'+'01'
				SET @To_Date =  CAST(CAST(@Year AS INT)+1 AS VARCHAR(5))+'-03-'+'31'
				
		END 
		ELSE
			BEGIN
				SET @From_Date = CAST(cast(@Year AS INT)-4 AS VARCHAR(5))+'-04-'+'01'
				SET @To_Date =  CAST(CAST(@Year AS INT) AS VARCHAR(5))+'-03-'+'31'
				
			END
		
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
		
	EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0

		DECLARE @From_Year AS INT
		DECLARE @To_Year AS INT
		DECLARE @Next_From_Year AS INT
		DECLARE @Next_To_Year AS INT
		DECLARE @Temp_From_Date AS DATETIME
		DECLARE @Temp_To_Date AS DATETIME
		
		
		
		IF 4 <= @Month 
		BEGIN
			SET @Next_From_Year = @year - 3
			SET @Next_To_Year =  @year + 1 
		END
		ELSE
		BEGIN
			SET @Next_From_Year = @year - 4
			SET @Next_To_Year =  @year  
		END 
		
			
		SET @From_Year = @Next_From_Year
		SET @To_Year = @Next_To_Year
		
		
		CREATE TABLE #Increment_Letter_Year
		(
			 Row_ID					INT
			,Cmp_ID					INT
			,Emp_ID					INT
			,AllowDesc				VARCHAR(128)
			,AD_ID					INT
			,[Year_1]				NUMERIC(18,2)
			,[Year_2]				NUMERIC(18,2)
			,[Year_3]				NUMERIC(18,2)
			,[Year_4]				NUMERIC(18,2)
			,ad_part_of_ctc			TINYINT 
			,AD_NOT_EFFECT_SALARY	TINYINT	
			,Ref_No					varchar(50)--Mukti(11012017)
			,Issue_Date				DATETIME   --Mukti(11012017)
		);
		
		DECLARE @INC_String NVARCHAR(MAX);
		DECLARE @Allow_String NVARCHAR(MAX);
		DECLARE @Total_Earn_String NVARCHAR(MAX);
		DECLARE @INDEX INT
		DECLARE @FLAG CHAR(1)
	
		SET @INDEX = 1;
		
				INSERT INTO #Increment_Letter_Year(Row_ID, Cmp_ID, Emp_ID, AllowDesc, AD_ID)
				SELECT 0, @Cmp_ID, Emp_ID, 'Basic',0 FROM #Emp_Cons
		
				INSERT INTO #Increment_Letter_Year(Row_ID,Cmp_ID, Emp_ID, AllowDesc, AD_ID,ad_part_of_ctc,AD_NOT_EFFECT_SALARY,Ref_No,Issue_Date)
				SELECT	DISTINCT  0, EED.CMP_ID,EED.EMP_ID,ADM.AD_NAME ,ADM.AD_ID,ADM.AD_PART_OF_CTC ,ADM.AD_NOT_EFFECT_SALARY,ELR.Reference_No,ELR.Issue_Date
				FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
			    T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID = ADM.AD_ID INNER JOIN 
			    #Emp_Cons E ON EED.EMP_ID=E.Emp_ID left join 
			    T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = E.Emp_ID and ELR.Letter_Name='Increment Letter' --Mukti(11012017)
				WHERE EED.E_AD_FLAG = 'I' AND EED.FOR_DATE BETWEEN @From_Date AND @To_Date
						and ADM.Hide_In_Reports = 0  --Added by Jaina 22-05-2017
				
				UPDATE #Increment_Letter_Year
				SET ROW_ID = 1
				WHERE ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 0
				
				INSERT INTO #Increment_Letter_Year(Row_ID, Cmp_ID, Emp_ID, AllowDesc, AD_ID,Year_1,Year_2,Year_3,Year_4)
				SELECT 2, @Cmp_ID, Emp_ID, 'GROSS SALARY',0,0,0,0,0 FROM #Emp_Cons
				
				UPDATE #Increment_Letter_Year
				SET ROW_ID = 3
				WHERE ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1
				
				INSERT INTO #Increment_Letter_Year(Row_ID, Cmp_ID, Emp_ID, AllowDesc, AD_ID,Year_1,Year_2,Year_3,Year_4)
				SELECT 4, @Cmp_ID, Emp_ID, 'CTC',0,0,0,0,0 FROM #Emp_Cons
				
			
				
		WHILE @From_Year < @To_Year
			BEGIN
				SET @Temp_From_Date = cast(@From_Year as varchar(5))+'-04-01'
				SET @Temp_To_Date = cast(cast(@From_Year as int)+1as varchar(5))+'-03-31'
							
						SET @INC_String = 'UPDATE IL 
						SET Year_' + CAST(@INDEX AS varchar(3)) + ' =isnull(I.Basic_Salary,0) 
						FROM  #Increment_Letter_Year IL 
						INNER JOIN T0095_INCREMENT I  WITH (NOLOCK) ON IL.EMP_ID=I.EMP_ID 
						INNER JOIN  (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
						INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
						FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
						WHERE 	I3.Increment_Effective_Date <=  @Temp_To_Date
						GROUP BY I3.Emp_ID
						) I3 ON I2.Increment_Effective_Date = I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						WHERE	I2.Cmp_ID = @Cmp_Id 
						GROUP BY I2.Emp_ID
						) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
						WHERE	I1.Cmp_ID=@Cmp_Id											
						) qryI ON qryI.EMP_ID=I.Emp_ID	And qryI.Increment_ID = I.Increment_ID 	LEFT JOIN 
						T0080_EMP_MASTER E WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID 
						WHERE IL.AD_ID=0 '
						
																										
						EXEC sp_executesql @INC_String, N'@Temp_To_Date DATETIME, @Cmp_Id INT',@Temp_To_Date,@Cmp_Id
												
						SET @Allow_String ='UPDATE IL
						SET Year_'+CAST(@INDEX AS varchar(3))+' = isnull(EED.E_AD_AMOUNT,0) 
						FROM  #Increment_Letter_Year  IL INNER JOIN
						T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON IL.EMP_ID=EED.EMP_ID INNER JOIN 
						T0050_AD_MASTER ADM WITH (NOLOCK) ON EED.AD_ID = ADM.AD_ID INNER JOIN
						(SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
						INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
						FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
						WHERE	I3.Increment_Effective_Date <= @Temp_To_Date
						GROUP BY I3.Emp_ID
						) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						WHERE	I2.Cmp_ID = @Cmp_Id 
						GROUP BY I2.Emp_ID
						) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
						WHERE	I1.Cmp_ID=@Cmp_Id											
						) I ON I.EMP_ID=EED.Emp_ID AND I.Increment_ID = EED.INCREMENT_ID
						WHERE EED.E_AD_FLAG = ''I'' AND EED.AD_ID = IL.AD_ID AND EED.Emp_ID = I.EMP_ID '
						
						EXEC sp_executesql @Allow_String, N'@Temp_To_Date DATETIME, @Cmp_Id INT,@FLAG Char(1)', @Temp_To_Date,@Cmp_Id,@FLAG	
						
				
				SET @From_Year = @From_Year + 1
				SET @INDEX = @INDEX + 1;	
							
			END
			
			Update #Increment_Letter_Year SET Year_1 = QRY.year_1,Year_2 = QRY.Year_2,Year_3 = QRY.Year_3,Year_4 = QRY.Year_4   from #Increment_Letter_Year as a
			inner JOIN (
			SELECT Emp_ID,SUM(isnull(Year_1,0)) AS Year_1 ,SUM(isnull(Year_2,0)) AS Year_2,SUM(isnull(Year_3,0)) AS Year_3,SUM(isnull(Year_4,0)) AS Year_4 FROM #Increment_Letter_Year
			WHERE row_id IN (0,1)GROUP BY Emp_ID ) AS QRY
			ON a.Emp_ID = QRY.emp_id 
			WHERE a.Row_ID = 2
			
			Update #Increment_Letter_Year SET Year_1 = QRY.year_1,Year_2 = QRY.Year_2,Year_3 = QRY.Year_3,Year_4 = QRY.Year_4   from #Increment_Letter_Year as a
			inner JOIN (
			SELECT Emp_ID,SUM(isnull(Year_1,0)) AS Year_1 ,SUM(isnull(Year_2,0)) AS Year_2,SUM(isnull(Year_3,0)) AS Year_3,SUM(isnull(Year_4,0)) AS Year_4 FROM #Increment_Letter_Year
			WHERE row_id IN (0,1,3)GROUP BY Emp_ID ) AS QRY
			ON a.Emp_ID = QRY.emp_id 
			WHERE a.Row_ID = 4
					
			SELECT *,@From_Date From_Date,@To_Date To_Date   FROM #Increment_Letter_Year
			WHERE ISNULL(Year_1,0)> 0 OR ISNULL(Year_2,0)> 0 OR ISNULL(Year_3,0)> 0 OR ISNULL(Year_4,0)> 0
			ORDER BY Emp_ID, Row_ID
		

