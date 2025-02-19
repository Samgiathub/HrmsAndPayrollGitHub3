


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Rpt_PMS_Summary_Apprisal2]
     @cmp_id        numeric(18,0)
	,@From_Date     datetime 
	,@To_Date       datetime = getdate
	,@Branch_ID		varchar(Max) 
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) 
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)
	,@Desig_ID		varchar(Max)
	,@Emp_ID		Numeric(18,0)
	,@Constraint	varchar(MAX)=''
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
	
	IF @Constraint <> ''
		BEGIN
			Insert Into #Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		END
	ELSE
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 


DECLARE @minRange INT
	SET @minRange = null
	
	SELECT @minRange=MIN(Rate_Value) FROM T0030_HRMS_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID = @cmp_id
	
	CREATE TABLE #finalDetail
	(
		 Emp_Id					NUMERIC(18,0)
		,EmpCode				VARCHAR(50)
		,Emp_full_Name			VARCHAR(50)
		,Grade					VARCHAR(50)
		,Qualification			VARCHAR(500)
		,TotalExperience		INT
		,DOJ					DATETIME
		,Designation			VARCHAR(50)	
		,Department				VARCHAR(50)
		,Gross					NUMERIC(18,2)
		,GrossReimb				NUMERIC(18,2)
		,SalaryPM				NUMERIC(18,2)
		,CurrentCTC				NUMERIC(18,2)
		,WeightedScore			NUMERIC(18,2)
		,HODRating				VARCHAR(50)			
		,FinalRating			VARCHAR(50)	--NUMERIC(18,2)
		,HODPromoRecommend		VARCHAR(5)
		,PromoRecommend			VARCHAR(5)
		,PerIncrement			VARCHAR(50)	
		,HODRecommendPercent	NUMERIC(18,2)
		,HODAmount				NUMERIC(18,2)
		,FinalRecommendPercent	NUMERIC(18,2)
		,FinalAmount			NUMERIC(18,2)
		,Remarks				VARCHAR(100)
	)	
	
	INSERT INTO #finalDetail
	(Emp_Id,EmpCode,Emp_full_Name,Grade,Qualification,TotalExperience,DOJ,Designation,Department,Gross,GrossReimb,SalaryPM,
	 CurrentCTC,WeightedScore,HODRating,FinalRating,HODPromoRecommend,PromoRecommend,PerIncrement
	)(
		SELECT E.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,G.Grd_Name,EQ.qual_name,TEXE.totalexp,EM.Date_Of_Join,DG.Desig_Name,DM.Dept_Name,I.Gross_Salary,0,I.CTC,
			   (I.CTC*12),EG1.WeightedScore,
			   --isnull(es.YearEnd_FinalRating,0),es.YearEnd_NormalRating,
			   ISNULL(rm.description_value,''),rmn.description_value,
			   CASE WHEN ISNULL(es.Sup_PromoRecommend,0)= 1 THEN 'Yes' ELSE 'No' END,
			   CASE WHEN ISNULL(es.Final_PromoRecommend,0)= 1 THEN 'Yes' ELSE 'No' END,
			   (
				   SELECT CASE WHEN YearEnd_NormalRating = @minRange THEN 
					CASE WHEN Final_PromoRecommend =1 THEN 
						(
							SELECT RangeValue
							FROM T0050_KPI_IncrementRange t WITH (NOLOCK) INNER JOIN
								(
									SELECT max(EffectiveDate)EffectiveDate
									FROM T0050_KPI_IncrementRange WITH (NOLOCK)
									WHERE Cmp_ID = @cmp_id  AND EffectiveDate > = @From_Date and EffectiveDate <= @To_Date
									
								)T1 on T1.EffectiveDate = t.EffectiveDate
							WHERE Cmp_ID = @cmp_id and t.RangeName = cast(YearEnd_NormalRating as VARCHAR)+ '(Promotion)'
								 
						 )
					ELSE
						(
							SELECT RangeValue
							FROM T0050_KPI_IncrementRange t WITH (NOLOCK) INNER JOIN
								(
									SELECT max(EffectiveDate)EffectiveDate
									FROM T0050_KPI_IncrementRange WITH (NOLOCK)
									WHERE Cmp_ID = @cmp_id  AND EffectiveDate > = @From_Date and EffectiveDate <= @To_Date
									
								)T1 on T1.EffectiveDate = t.EffectiveDate
							WHERE Cmp_ID = @cmp_id and t.RangeName = cast(YearEnd_FinalRating as VARCHAR)+ '(Non Promotion)'
								  AND t.EffectiveDate > = @From_Date and t.EffectiveDate <= @To_Date
						 )
					END 
				ELSE
					( 
						SELECT RangeValue
						FROM T0050_KPI_IncrementRange t WITH (NOLOCK) INNER JOIN
								(
									SELECT max(EffectiveDate)EffectiveDate
									FROM T0050_KPI_IncrementRange WITH (NOLOCK)
									WHERE Cmp_ID = @cmp_id  AND EffectiveDate > = @From_Date and EffectiveDate <= @To_Date
									
								)T1 on T1.EffectiveDate = t.EffectiveDate
						WHERE Cmp_ID = @cmp_id and t.RangeName = cast(YearEnd_NormalRating as VARCHAR)
							  AND t.EffectiveDate > = @From_Date and t.EffectiveDate <= @To_Date
					)
				END
			)
		FROM  #Emp_Cons E INNER JOIN
			  T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = E.Emp_ID INNER JOIN
			  (
				SELECT I1.Emp_ID,I1.Grd_ID,I1.Dept_ID,I1.Desig_Id,I1.Type_ID,I1.Branch_ID,
						I1.Gross_Salary,I1.Basic_Salary,I1.CTC
				FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN
				(
					SELECT MAX(Increment_ID)Increment_ID, T0095_INCREMENT.Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
					(
						SELECT max(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK)
						WHERE Cmp_ID = @cmp_id 
						GROUP by T0095_INCREMENT.Emp_ID
					)I3 ON i3.Emp_ID = T0095_INCREMENT.Emp_ID
					WHERE Cmp_ID = @cmp_id
					GROUP by T0095_INCREMENT.Emp_ID
				)I2 ON I2.Increment_ID = I1.Increment_ID and I2.Emp_ID = I1.Emp_ID	
			  )I ON E.Emp_ID = I.Emp_ID LEFT JOIN
			  T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = I.Grd_ID LEFT JOIN
			  T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id LEFT JOIN
			  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = I.Dept_Id LEFT JOIN
			  (
				SELECT EQ1.Emp_ID, qual_name = STUFF((
					SELECT ', ' + Q.Qual_Name FROM T0090_EMP_QUALIFICATION_DETAIL EQ2 WITH (NOLOCK) LEFT JOIN
								T0040_QUALIFICATION_MASTER Q WITH (NOLOCK) on q.Qual_ID = EQ2.Qual_ID
					WHERE EQ2.Emp_ID = EQ1.Emp_ID 
					FOR XML PATH(''), TYPE).value('.[1]', 'varchar(max)'), 1, 2, '')
				FROM T0090_EMP_QUALIFICATION_DETAIL AS EQ1 WITH (NOLOCK)
				GROUP BY EQ1.Emp_ID
			  )EQ  ON EQ.Emp_ID = E.Emp_ID LEFT JOIN
			  T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK) on EG.Emp_Id = E.Emp_ID INNER JOIN
			  (
				SELECT SUM(WeightedScore)WeightedScore,Emp_GoalSetting_Review_Id
				FROM  T0100_EmployeeGoalSetting_Evaluation_Details WITH (NOLOCK)
				WHERE Cmp_Id = @cmp_id
				GROUP by Emp_GoalSetting_Review_Id
			  )EG1 on EG1.Emp_GoalSetting_Review_Id = EG.Emp_GoalSetting_Review_Id LEFT JOIN
			  T0100_EmployeeGoal_SupEval ES WITH (NOLOCK) on ES.Emp_GoalSetting_Review_Id = EG.Emp_GoalSetting_Review_Id LEFT JOIN
			 -- (
				----SELECT sum(Reim_Opening_Amount * DATEDIFF(MONTH,For_Date,@To_Date))totAmount,emp_id
				--SELECT sum(Reim_Opening_Amount)totAmount,emp_id
				-- FROM T0095_Reim_Opening
				-- WHERE For_Date >= @From_Date and For_Date<= @To_Date and
				--	cmp_id= @cmp_id
				-- GROUP by Emp_ID
			 -- )GRE on GRE.Emp_ID = E.Emp_ID LEFT JOIN
			  (
				SELECT (SUM(DATEDIFF (YEAR,Date_Of_Join,GETDATE()))+ ISNULL(exe.prevexp,0))totalexp,T0080_EMP_MASTER.Emp_ID
				 FROM T0080_EMP_MASTER WITH (NOLOCK) left	 JOIN
				 (
					 SELECT SUM(DATEDIFF (YEAR,St_Date,End_Date))prevexp,Emp_ID
					 FROM T0090_EMP_EXPERIENCE_DETAIL WITH (NOLOCK)
					 WHERE Cmp_ID = @cmp_id
					 GROUP by Emp_ID
				 )exe on exe.Emp_ID = T0080_EMP_MASTER.Emp_ID
				WHERE Cmp_ID= @cmp_id
				GROUP by T0080_EMP_MASTER.Emp_ID,exe.prevexp
			  )TEXE ON TEXE.Emp_ID = E.Emp_ID left JOIN
			  T0030_HRMS_RATING_MASTER RM WITH (NOLOCK) on cast(rm.Rate_ID as varchar)=ES.YearEnd_FinalRating and RM.Cmp_ID=ES.Cmp_Id left join
			  T0030_HRMS_RATING_MASTER RMN WITH (NOLOCK) on cast(rmn.Rate_ID as varchar)=ES.YearEnd_NormalRating and rmn.Cmp_ID=ES.Cmp_Id
			WHERE EG.CreatedDate >= @From_Date and EG.CreatedDate <= @To_Date and EG.Review_Type = 2
			--ORDER BY EM.Alpha_Emp_Code
	)
	
	
	UPDATE #finalDetail
	SET GrossReimb =  isnull(t.E_AD_AMOUNT,0) + Gross
	FROM 
	(
		SELECT E.emp_id,sum(E_AD_AMOUNT)E_AD_AMOUNT
		FROM #Emp_Cons E LEFT JOIN
		(
			SELECT  ISNULL(E_AD_AMOUNT,0)E_AD_AMOUNT, E_AD_FLAG, AD_Id , Allowance_Type,Qry_temp.INCREMENT_ID,Qry_temp.Emp_ID
					FROM 
					(
						SELECT DISTINCT EED.INCREMENT_ID,E.Emp_ID,EED.AD_ID,EED.E_AD_FLAG,
							 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
								Case When Qry1.E_Ad_Amount IS NULL Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
							 Else
								EED.E_AD_AMOUNT End As E_Ad_Amount,AD_LEVEL , AM.Allowance_Type
						FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
								T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
								( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
									From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
									( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
										Where  For_date <= @To_Date
									 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date AND Eedr.Ad_Id = Qry.Ad_Id 
								) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
						WHERE Case When Qry1.ENTRY_TYPE IS NULL Then '' Else Qry1.ENTRY_TYPE End <> 'D'							
							AND EED.CMP_ID = @cmp_id 
						AND am.AD_NOT_EFFECT_SALARY=1
						UNION ALL
						
						SELECT DISTINCT    EED.Increment_ID,EM.Emp_ID,EED.AD_ID, EED.E_AD_FLAG, EED.E_AD_AMOUNT,AD_LEVEL  , T0050_AD_MASTER.Allowance_Type
						FROM   dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
								( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE  For_date <= @To_Date GROUP BY Ad_Id )Qry 
									ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
								dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
								dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
						WHERE  EEd.ENTRY_TYPE = 'A'							
							AND EED.CMP_ID = @cmp_id 						
						) Qry_temp
						WHERE E_AD_AMOUNT >0 and Qry_temp.E_AD_FLAG <>'D'  and Qry_temp.Allowance_Type='R'
		)k on k.INCREMENT_ID = e.Increment_ID and k.Emp_ID = e.Emp_ID
		GROUP by E.Emp_ID
	)t
	WHERE #finalDetail.Emp_Id = t.Emp_ID 
	
	DECLARE @sel_year INT
	SET @sel_year = YEAR(@From_Date)	
	DECLARE @prev_year1 INT 
	SET @prev_year1  = YEAR(@From_Date)-1
	DECLARE @prev_year2 INT 
	SET @prev_year2  = YEAR(@From_Date)-2
	
	---SELECT @sel_year,@prev_year1,@prev_year2
	DECLARE @query as VARCHAR(MAX)
	DECLARE	 @columnName VARCHAR(50)
	
	
	SET @columnName = 'Increment' + cast(@prev_year2 as varchar)	
	SET @query = 'ALTER TABLE  #finalDetail 
				  ADD [' + @columnName + '] numeric(18,2)'
	EXEC (@query)
	
	SET @columnName = 'Increment' + cast(@prev_year1 as varchar)	
	SET @query = 'ALTER TABLE  #finalDetail 
				  ADD [' + @columnName + '] numeric(18,2)'
	EXEC (@query)
	
	SET @columnName = 'Rating' + cast(@prev_year2 as varchar)	
	SET @query = 'ALTER TABLE  #finalDetail 
				  ADD [' + @columnName + '] numeric(18,2)'
	EXEC (@query)
	
	SET @columnName = 'Rating' + cast(@prev_year1 as varchar)	
	SET @query = 'ALTER TABLE  #finalDetail 
				  ADD [' + @columnName + '] numeric(18,2)'
	EXEC (@query)
	
	DECLARE @empid as NUMERIC(18,0)
	DECLARE @colname as VARCHAR(50)
	
	DECLARE cur CURSOR
		FOR
			SELECT emp_id FROM #finalDetail
	OPEN cur
		FETCH NEXT FROM cur INTO @empid
		WHILE @@fetch_status = 0
			BEGIN
				SET @query = ''
				SET @colname =''
				SET @columnName =''
				--1st Increment
				IF EXISTS(SELECT 1 from	 T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @empid and DATEPART(YEAR,Increment_Effective_Date) = @prev_year2 and Increment_Type<>'Joining')	
					BEGIN
						SET @columnName = 'Increment' + cast(@prev_year2 as varchar)
						SET @query = 'UPDATE #finalDetail
									 SET  '+ @columnName +' = t.Increment_Amount
									 FROM (
											SELECT  Increment_Amount
											FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
												(
													SELECT MAX(Increment_ID)Increment_ID
													FROM T0095_INCREMENT WITH (NOLOCK)
													WHERE Emp_ID = '+ cast(@empid as VARCHAR) +' AND DATEPART(YEAR,Increment_Effective_Date) = '+ cast(@prev_year2 as VARCHAR) +'
												)inc on inc.Increment_ID = T0095_INCREMENT.Increment_ID 
											WHERE Emp_ID = '+ cast(@empid as VARCHAR) +'
										  )t
									WHERE Emp_Id =' + cast(@empid as VARCHAR)
							--PRINT @query
							EXEC(@query)
					END	
				ELSE
					BEGIN 
						SET @colname = 'Increment'+cast(@prev_year2 as VARCHAR) 
						SET @columnName = 'Increment' + cast(@prev_year2 as VARCHAR)
						
						IF EXISTS(SELECT * FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) WHERE Column_Name =  @colname )
							BEGIN 
								IF EXISTS(SELECT 1 FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id WHERE Column_Name = @colname and Emp_Id = @empid)
									BEGIN										
										SET @query = 'UPDATE #finalDetail
														SET '+ @columnName +' = t.Value
														FROM (
																SELECT Value 
																FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN
																	 T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id
																WHERE Column_Name ='''+ @colname +''' and Emp_Id ='	+ cast(@empid as VARCHAR) +'
															  )t
														WHERE Emp_Id ='	+ cast(@empid as VARCHAR)
										--print @query
										EXEC(@query)
									END
							END						
					END	
					
				--2nd Increment	
				SET @query = ''
				SET @colname =''
				SET @columnName =''	
				IF EXISTS(SELECT 1 from	 T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = @empid and DATEPART(YEAR,Increment_Effective_Date) = @prev_year1 and Increment_Type<>'Joining')	
					BEGIN
						SET @columnName = 'Increment' + cast(@prev_year1 as varchar)
						SET @query = 'UPDATE #finalDetail
									 SET  '+ @columnName +' = t.Increment_Amount
									 FROM (
											SELECT  Increment_Amount
											FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
												(
													SELECT MAX(Increment_ID)Increment_ID
													FROM T0095_INCREMENT WITH (NOLOCK)
													WHERE Emp_ID = '+ cast(@empid as VARCHAR) +' AND DATEPART(YEAR,Increment_Effective_Date) = '+ cast(@prev_year1 as VARCHAR) +'
												)inc on inc.Increment_ID = T0095_INCREMENT.Increment_ID 
											WHERE Emp_ID = '+ cast(@empid as VARCHAR) +'
										  )t
									WHERE Emp_Id =' + cast(@empid as VARCHAR)
							--PRINT @query
							EXEC(@query)
					END	
				ELSE
					BEGIN 
						SET @colname = 'Increment'+cast(@prev_year1 as VARCHAR) 
						SET @columnName = 'Increment' + cast(@prev_year1 as VARCHAR)
						
						IF EXISTS(SELECT * FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) WHERE Column_Name =  @colname )
							BEGIN 
								IF EXISTS(SELECT 1 FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id WHERE Column_Name = @colname and Emp_Id = @empid)
									BEGIN										
										SET @query = 'UPDATE #finalDetail
														SET '+ @columnName +' = t.Value
														FROM (
																SELECT Value 
																FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN
																	 T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id
																WHERE Column_Name ='''+ @colname +''' and Emp_Id ='	+ cast(@empid as VARCHAR) +'
															  )t
														WHERE Emp_Id ='	+ cast(@empid as VARCHAR)
										--print @query
										EXEC(@query)
									END
							END						
					END	
				
				--1st Rating
				SET @query = ''
				SET @colname =''
				SET @columnName =''
				IF EXISTS(SELECT 1 FROM	T0100_EmployeeGoal_SupEval ES WITH (NOLOCK) Inner join T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK) ON ES.Emp_GoalSetting_Review_Id = EG.Emp_GoalSetting_Review_Id WHERE es.Emp_ID = @empid and YEAR(EG.CreatedDate) = @prev_year2 and EG.Review_Type = 2)
					BEGIN 
						SET @columnName = 'Rating' + cast(@prev_year2 as varchar)
						SET @query = ' UPDATE #finalDetail
										SET '+ @columnName +' = t.YearEnd_NormalRating
										FROM (
												SELECT ES.YearEnd_NormalRating 
												FROM	T0100_EmployeeGoal_SupEval ES WITH (NOLOCK) INNER JOIN 
														T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK) ON ES.Emp_GoalSetting_Review_Id = EG.Emp_GoalSetting_Review_Id
												WHERE   es.Emp_ID = '+ cast(@empid as VARCHAR) +' and YEAR(EG.CreatedDate) = '+ cast(@prev_year2 as VARCHAR) +' and EG.Review_Type = 2
											)t
										WHERE emp_id =' + cast(@empid as VARCHAR)
						--print @query
						EXEC(@query)
					END
				ELSE
					BEGIN 
						SET @colname = 'Rating'+cast(@prev_year2 as VARCHAR) 
						SET @columnName = 'Rating' + cast(@prev_year2 as VARCHAR)						
						IF EXISTS(SELECT * FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) WHERE Column_Name =  @colname )
							BEGIN 
								IF EXISTS(SELECT 1 FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id WHERE Column_Name = @colname and Emp_Id = @empid)
									BEGIN
										SET @query = 'UPDATE #finalDetail
														SET '+ @columnName +' = t.Value
														FROM (
																SELECT Value 
																FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN
																	 T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id
																WHERE Column_Name ='''+ @colname +''' and Emp_Id ='	+ cast(@empid as VARCHAR) +'
															  )t
														WHERE Emp_Id ='	+ cast(@empid as VARCHAR)
										--print @query
										EXEC(@query)
									END
							END
					END
				
				--2nd Rating
				SET @query = ''
				SET @colname =''
				SET @columnName =''
				IF EXISTS(SELECT 1 FROM	T0100_EmployeeGoal_SupEval ES WITH (NOLOCK) Inner join T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK) ON ES.Emp_GoalSetting_Review_Id = EG.Emp_GoalSetting_Review_Id WHERE es.Emp_ID = @empid and YEAR(EG.CreatedDate) = @prev_year1 and EG.Review_Type = 2)
					BEGIN 
						SET @columnName = 'Rating' + cast(@prev_year1 as varchar)
						SET @query = ' UPDATE #finalDetail
										SET '+ @columnName +' = t.YearEnd_NormalRating
										FROM (
												SELECT ES.YearEnd_NormalRating 
												FROM	T0100_EmployeeGoal_SupEval ES WITH (NOLOCK) INNER JOIN 
														T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK) ON ES.Emp_GoalSetting_Review_Id = EG.Emp_GoalSetting_Review_Id
												WHERE   es.Emp_ID = '+ cast(@empid as VARCHAR) +' and YEAR(EG.CreatedDate) = '+ cast(@prev_year1 as VARCHAR) +' and EG.Review_Type = 2
											)t
										WHERE emp_id =' + cast(@empid as VARCHAR)
						--print @query
						EXEC(@query)
					END
				ELSE
					BEGIN 
						SET @colname = 'Rating'+cast(@prev_year1 as VARCHAR) 
						SET @columnName = 'Rating' + cast(@prev_year1 as VARCHAR)						
						IF EXISTS(SELECT * FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) WHERE Column_Name =  @colname )
							BEGIN 
								IF EXISTS(SELECT 1 FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id WHERE Column_Name = @colname and Emp_Id = @empid)
									BEGIN
										SET @query = 'UPDATE #finalDetail
														SET '+ @columnName +' = t.Value
														FROM (
																SELECT Value 
																FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) INNER JOIN
																	 T0082_Emp_Column WITH (NOLOCK) on mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id
																WHERE Column_Name ='''+ @colname +''' and Emp_Id ='	+ cast(@empid as VARCHAR) +'
															  )t
														WHERE Emp_Id ='	+ cast(@empid as VARCHAR)
										--print @query
										EXEC(@query)
									END
							END
					END	
					
				FETCH NEXT FROM cur INTO @empid
			END
	CLOSE cur
	DEALLOCATE cur



SET @query = ''		
SET @query = 'INSERT INTO #finalDetail
(Emp_Id,Gross,GrossReimb,SalaryPM,CurrentCTC,Increment' + cast(@prev_year2 as varchar)	+',Increment' + cast(@prev_year1 as varchar)+')
(SELECT max(Emp_Id)+1,SUM(Gross),sum(GrossReimb),sum(SalaryPM),sum(CurrentCTC),SUM(Increment' + cast(@prev_year2 as varchar)+'),SUM(Increment' + cast(@prev_year1 as varchar)+')
 FROM #finalDetail)'
 
EXEC (@query)


SET @query = ''
SET @query = '
			SELECT ROW_NUMBER() OVER ( ORDER BY emp_id)AS Srno				
			,EmpCode									AS  ''Employee Code''		
			,Emp_full_Name								AS  ''Employee Name''		
			,Grade					
			,Qualification		
			,TotalExperience		
			,DOJ					AS ''Date Of Joining''			
			,Designation
			,Department			
			,Gross					AS ''Gross(P.M)''		
			,GrossReimb				AS ''Gross+Reim''			
			,SalaryPM				AS ''Salary(P.M)''		
			,CurrentCTC				AS ''Current CTC(P.A)''	
			,Increment' + cast(@prev_year2 as varchar)	+'	
			,Increment' + cast(@prev_year1 as varchar)	+'	
			,Rating' + cast(@prev_year2 as varchar)	+'	
			,Rating' + cast(@prev_year1 as varchar)	+'	
			,WeightedScore	        AS ''Weighted Score in '+ cast(YEAR(@From_Date) as VARCHAR) +'''			
			,HODRating				AS ''HOD Rating''	
			,HODPromoRecommend		AS ''Promotion Recommended by HOD (Yes/No)''		
			,FinalRating		    AS ''Final Rating''	
			,PromoRecommend			AS ''Final Promotion Recommended (Yes/No)''		
			,PerIncrement		    AS ''%tage Range of Increment''		
			,HODRecommendPercent	AS ''HOD Recommend(%)''	
			,HODAmount				AS ''HOD Recommend Amount''	
			,FinalRecommendPercent	AS ''Directors Final Recom (%)''	
			,FinalAmount			AS ''Final Increment Amount''
			,Remarks				
	FROM #finalDetail'
	
	--print @query
	EXEC (@query)
	
	DROP TABLE #finalDetail
END

