


-- =============================================
-- Author:		<Ankit>
-- Create date: <21012016>
-- Description:	<Get Trainee & Probation Approval Manager History>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[S_EMP_PROBATION_EMPLOYEE_APPROVAL_LEVEL_GET]
	@Cmp_Id		NUMERIC(18,0)
	,@Emp_ID	NUMERIC(18,0)
	,@Rpt_Level	INTEGER = 0	
	,@Type		VARCHAR(15) = 'Probation'
	,@Probation_Evaluation_ID NUmeric = 0
	,@Is_Report		varchar(15)=''
	,@TranID	int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	DECLARE @Def_ID	NUMERIC(18,0)
	DECLARE @flag INT
	DECLARE @Skill_ID INT
	DECLARE @Skill_Name VARCHAR(1000)
	DECLARE @flagSelfAssessment INT
	DECLARE @flagDefaultProbation INT
	
	SET @Def_ID = 0
	
	IF ISNULL(@Type,'')  = ''
		SET @Type = 'Probation'
	
	IF EXISTS(SELECT Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id and Setting_Value > 0 and Setting_Name ='Set days to fill Self Assessment Probation Details')
	BEGIN
		SET @flagSelfAssessment=1
	END
	
	IF EXISTS(SELECT Setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id and Setting_Value=1 and Setting_Name ='Enable Probation/Trainee Assessment With Score')
	BEGIN
		SET @flagDefaultProbation=1
	END	
	
	--SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY Probation_Evaluation_ID)as TotalProb,
	--Probation_Evaluation_ID--,EPM.Evaluation_Date--,EPM.Tran_Id 
	--INTO #Emp_Probation
	--FROM T0115_EMP_PROBATION_MASTER_LEVEL EPM 
	--WHERE EPM.Emp_id= @Emp_ID and EPM.Cmp_id=@Cmp_Id
	--GROUP by EPM.Probation_Evaluation_ID,Evaluation_Date--,EPM.Tran_Id
	
	--SELECT Tran_Id,Rpt_Level,EPM.Probation_Evaluation_ID,EPM.Evaluation_Date
	--INTO #Emp_Probation
	--FROM T0115_EMP_PROBATION_MASTER_LEVEL EPM	
	--WHERE Emp_id = @Emp_Id AND Probation_Evaluation_ID <= @Probation_Evaluation_ID and EPM.Rpt_Level >0
		
	CREATE table #Emp_Probation
	(
	TotalProb INT,
	Old_Probation_EndDate DATETIME
	)
	
	IF @Is_Report = 'Report' and @TranID > 0
		BEGIN
		print 12
			INSERT INTO #Emp_Probation
			SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY Old_Probation_EndDate)as TotalProb,Old_Probation_EndDate			
			FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK)
			WHERE Emp_id=@Emp_Id and Tran_Id=@Probation_Evaluation_ID --GROUP BY Old_Probation_EndDate
		END
	IF @Is_Report = 'Report' and @Probation_Evaluation_ID > 0
		BEGIN
		print 123
			INSERT INTO #Emp_Probation
			SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY Old_Probation_EndDate)as TotalProb,Old_Probation_EndDate			
			FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
			WHERE Emp_id=@Emp_Id and Probation_Evaluation_ID=@Probation_Evaluation_ID --GROUP BY Old_Probation_EndDate
		END
	ELSE
		BEGIN
			INSERT INTO #Emp_Probation
			SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY Old_Probation_EndDate)as TotalProb,Old_Probation_EndDate			
			FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK)
			WHERE Emp_id=@Emp_Id GROUP BY Old_Probation_EndDate
		END
	--select * from #Emp_Probation
	--IF @Rpt_Level = 0
	--	SELECT @Rpt_Level = MAX(Rpt_Level) + 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL EPM 
	--	WHERE EPM.Emp_id	= @Emp_ID AND Probation_Evaluation_ID = @Probation_Evaluation_ID 	
	
	CREATE TABLE #Lable
    (
		Sr_No			NUMERIC(18,0) IDENTITY(1,1) NOT NULL ,
		Def_ID			NUMERIC(18,0),
		Skill_Attr_ID	NUMERIC(18,0) DEFAULT NUll,
		Lable_name		VARCHAR(MAX),
		Emp_id			NUMERIC(18,0) DEFAULT 0,
		Employee_Rating	Varchar(500) DEFAULT NUll,
		Rpt_Mgr_1	Varchar(500) DEFAULT NUll,
		Rpt_Mgr_2	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_3	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_4	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_5	Varchar(200) DEFAULT NUll,
		flag		INT,
		Old_Probation_EndDate datetime,
		Weightage INT,
		Max_rate NUMERIC(18,2),		
		Tot_Skill_Weightage NUMERIC(18,2),		
		Tot_Attribute_Weightage NUMERIC(18,2),
		skill_Total NUMERIC(18,2),	
		Final_Rating NUMERIC(18,2)	
    )
    
    CREATE TABLE #Scheme_Table
    (
		Emp_id		NUMERIC		DEFAULT 0,
		--Scheme_Type Varchar(50),
		--Scheme_Id numeric,
		Rpt_Mgr_1	Varchar(500) DEFAULT NUll,
		Rpt_Mgr_2	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_3	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_4	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_5	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_6 Varchar(200), 
		Rpt_Mgr_7 Varchar(200),
		Rpt_Mgr_8 Varchar(200),
		Max_Level	int	
    )       
   
    DECLARE @From_date	DATETIME 
	SET @From_date = GETDATE()
	
	INSERT INTO #Scheme_Table
	exec SP_RPT_SCHEME_DETAILS_ESS_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_date,@To_Date=@From_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_Id,@Constraint=@Emp_Id,@Report_Type = @Type
--select * from #Scheme_Table
	DECLARE @DESIG_ID INT
	DECLARE @DEPT_ID INT
	SELECT @DESIG_ID=Desig_Id,@DEPT_ID=Dept_ID FROM V0095_Increment_All_Data where Emp_ID=@emp_id

	--select * from #Scheme_Table	
	DECLARE @Evaluation_Date1 as DATETIME
	DECLARE @TotalProb as INT
	DECLARE @Tran_Id as INT
	DECLARE @Old_Probation_EndDate as DATETIME
	DECLARE @Review_Type as VARCHAR(20)	
	DECLARE @TITLE AS VARCHAR(150)
	DECLARE @Max_rate as INT
	DECLARE @Exe_Query VARCHAR(MAX)
	SET @Exe_Query = ''			
	
	DECLARE CurrTotProbation CURSOR FOR		
		SELECT TotalProb,Old_Probation_EndDate FROM #Emp_Probation		
	OPEN CurrTotProbation	
	FETCH NEXT FROM CurrTotProbation INTO @TotalProb,@Old_Probation_EndDate
		WHILE @@FETCH_STATUS = 0
			BEGIN				
	PRINT @Old_Probation_EndDate			
		SELECT @Probation_Evaluation_ID=EPM.Probation_Evaluation_ID,
		@Evaluation_Date1=EPM.Evaluation_Date,@Tran_Id=Tran_Id,@Review_Type=EPM.Review_Type 
		FROM T0115_EMP_PROBATION_MASTER_LEVEL EPM WITH (NOLOCK)
		WHERE Emp_id = @Emp_Id and EPM.Old_Probation_EndDate=@Old_Probation_EndDate
		 and EPM.Rpt_Level >0
					
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 0, 'Employee Record',@Old_Probation_EndDate
			    
				UPDATE #Lable SET Emp_id = @Emp_Id
				
				UPDATE #Lable
				SET	Employee_Rating ='Self Rating',
					Rpt_Mgr_1  = ST.Rpt_Mgr_1,
					Rpt_Mgr_2  = ST.Rpt_Mgr_2,
					Rpt_Mgr_3  = ST.Rpt_Mgr_3,
					Rpt_Mgr_4  = ST.Rpt_Mgr_4,
					Rpt_Mgr_5  = ST.Rpt_Mgr_5
				FROM #Lable L INNER JOIN #Scheme_Table ST ON L.Emp_id = ST.Emp_id
				WHERE L.Lable_name = 'Employee Record'
				
				IF @TotalProb=1
					SET @TITLE=cast(@TotalProb as VARCHAR(10)) + 'st Assessment On Evaluation Date: ' + CONVERT(VARCHAR(15),@Evaluation_Date1,103) + '(' + @Review_Type +')'					
				ELSE IF @TotalProb=2
					SET @TITLE=cast(@TotalProb as VARCHAR(10)) + 'nd Assessment On Evaluation Date: ' + CONVERT(VARCHAR(15),@Evaluation_Date1,103) + '(' + @Review_Type +')'										
				ELSE IF @TotalProb=3
					SET @TITLE=cast(@TotalProb as VARCHAR(10)) + 'rd Assessment On Evaluation Date: ' + CONVERT(VARCHAR(15),@Evaluation_Date1,103) + '(' + @Review_Type +')'										
				ELSE
					SET @TITLE=cast(@TotalProb as VARCHAR(10)) + 'th Assessment On Evaluation Date: ' + CONVERT(VARCHAR(15),@Evaluation_Date1,103) + '(' + @Review_Type +')'										
						
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,flag,Old_Probation_EndDate)				
				SELECT 1,@TITLE,222,@Old_Probation_EndDate
										
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 2, @Type + ' Period',@Old_Probation_EndDate
			    
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 3, 'Employee Type',@Old_Probation_EndDate
			    
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 4, 'Extended Days',@Old_Probation_EndDate
			    
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 5, 'Extended Date',@Old_Probation_EndDate
   
		   IF @flagDefaultProbation=1
			   BEGIN
					SET @Def_ID = @Def_ID + 1
					INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
					SELECT 6,'Major Strengths/Contribution/Goals',@Old_Probation_EndDate
				    
					SET @Def_ID = @Def_ID + 1
					INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
					SELECT 7,'Major Weaknesses',@Old_Probation_EndDate
			   END	
		   ELSE
				BEGIN
					SET @Def_ID = @Def_ID + 1
					INSERT INTO #Lable(Def_ID,Lable_name,flag,Old_Probation_EndDate)
					SELECT 6,'Major Strengths/Contribution/Goals',333,@Old_Probation_EndDate
				    
					SET @Def_ID = @Def_ID + 1
					INSERT INTO #Lable(Def_ID,Lable_name,flag,Old_Probation_EndDate)
					SELECT 7,'Major Weaknesses',333,@Old_Probation_EndDate
			   END	
		    
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 8,'Remarks of Appraiser',@Old_Probation_EndDate
			    
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 9, 'Remarks of Appraisal Reviewer',@Old_Probation_EndDate
			    
				SET @Def_ID = @Def_ID + 1
				INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate)
				SELECT 10,'Skills',@Old_Probation_EndDate
   
				IF @Type='Probation'
					set @flag=0
				else 
					set @flag=1			    
			   
			   SELECT @Max_rate=Max(To_Rate)  FROM T0040_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID     
			   IF @flagDefaultProbation =1
				BEGIN
						INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,Old_Probation_EndDate,flag,Weightage,Max_rate,Tot_Skill_Weightage)
    					SELECT  10,SW.Skill_ID,SM.Skill_Name,@Old_Probation_EndDate,11,SW.Weightage,@Max_rate,es.Skill_Weightage
						FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
						INNER JOIN 
							(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
							 WHERE Cmp_ID = @Cmp_Id AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and [TYPE]=@flag)Qry ON Es.Effect_Date = Qry.Effect_date 
						INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
						INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID 
						WHERE ES.Cmp_ID = @Cmp_Id AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@flag 
						Order By Skill_Name ASC
				END
			   ELSE	
			   BEGIN
				   DECLARE Curr_Skill CURSOR FOR
						 SELECT  SW.Skill_ID,SM.Skill_Name
						FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
						INNER JOIN 
							(SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
							 WHERE Cmp_ID = @Cmp_Id AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and [TYPE]=@flag)Qry ON Es.Effect_Date = Qry.Effect_date 
						INNER JOIN T0110_SKILL_WEIGHTAGE SW WITH (NOLOCK) ON ES.Tran_ID = SW.Tran_Id 
						INNER JOIN T0040_SKILL_MASTER SM WITH (NOLOCK) ON SM.Skill_ID = SW.Skill_ID 
						WHERE ES.Cmp_ID = @Cmp_Id AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@flag 
						Order By Skill_Name ASC
					OPEN Curr_Skill
					FETCH NEXT FROM Curr_Skill INTO @Skill_ID,@Skill_Name
						WHILE @@FETCH_STATUS = 0
							BEGIN
								INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,flag,Old_Probation_EndDate)
								values (10,@Skill_ID,@Skill_Name,999,@Old_Probation_EndDate)
								
								INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,flag,Old_Probation_EndDate)
								SELECT 10,@Skill_ID,'Strengths',111,@Old_Probation_EndDate		
								
								INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,flag,Old_Probation_EndDate)
								SELECT 10,@Skill_ID,'Other Factors to Improve',111,@Old_Probation_EndDate	
								
								INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,flag,Old_Probation_EndDate)
								SELECT 10,@Skill_ID,'Rating',111,@Old_Probation_EndDate	
								
								INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,flag,Old_Probation_EndDate)
								SELECT 10,@Skill_ID,'Remarks',111,@Old_Probation_EndDate		
								
								FETCH NEXT FROM Curr_Skill INTO @Skill_ID,@Skill_Name
							END
					CLOSE Curr_Skill	
					DEALLOCATE Curr_Skill
			   END
				SET @Def_ID = @Def_ID + 1	
				
				IF EXISTS(SELECT 1 FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
						  INNER JOIN 
								 (SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
								  WHERE Cmp_ID =@Cmp_Id AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and [TYPE]=@flag) Qry ON Es.Effect_Date = Qry.Effect_date 
						  INNER JOIN T0110_Attribute_Weightage AW WITH (NOLOCK) ON ES.Tran_ID = AW.Tran_Id 
						  INNER JOIN T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) ON AM.Attribute_ID = AW.Attr_Id 
						  WHERE ES.Cmp_ID =@Cmp_Id AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@flag)
				BEGIN			
					INSERT INTO #Lable(Def_ID,Lable_name,Old_Probation_EndDate,flag)
					SELECT 11,'Attribute',@Old_Probation_EndDate,22
				    
					INSERT INTO #Lable(Def_ID,Skill_Attr_ID,Lable_name,Old_Probation_EndDate,flag,Weightage,Max_rate,Tot_Attribute_Weightage)
					--SELECT @Def_ID,Attribute_ID ,Attribute_Name From T0040_ATTRIBUTE_MASTER Where Cmp_ID = @Cmp_Id Order By Attribute_Name ASC
					SELECT 11, AW.Attr_Id ,AM.Attribute_Name,@Old_Probation_EndDate,22,AW.Weightage,@Max_rate,es.Attr_Weightage
					FROM T0100_EMP_Skill_Attr_Assign ES WITH (NOLOCK)
					INNER JOIN 
						 (SELECT MAX(Effect_Date) As Effect_date FROM T0100_EMP_Skill_Attr_Assign WITH (NOLOCK)
						  WHERE Cmp_ID =@Cmp_Id AND ((ISNULL(Desig_Id,0)<>0 AND Desig_Id = @Desig_Id) OR(ISNULL(Dept_Id,0)<>0 AND Dept_Id = @Dept_Id)) and [TYPE]=@flag) Qry ON Es.Effect_Date = Qry.Effect_date 
					INNER JOIN T0110_Attribute_Weightage AW WITH (NOLOCK) ON ES.Tran_ID = AW.Tran_Id 
					INNER JOIN T0040_ATTRIBUTE_MASTER AM WITH (NOLOCK) ON AM.Attribute_ID = AW.Attr_Id 
					WHERE ES.Cmp_ID =@Cmp_Id AND ((ISNULL(ES.Desig_Id,0)<>0 AND ES.Desig_Id = @Desig_Id) OR(ISNULL(ES.Dept_Id,0)<>0 AND ES.Dept_Id = @Dept_Id)) and ES.[TYPE]=@flag
					Order By Attribute_Name ASC				
				END
				--UPDATE #Lable SET Probation_Evaluation_ID=@Probation_Evaluation_ID
				--WHERE Probation_Evaluation_ID=NULL
			--END	
		--FETCH NEXT FROM CurrProbationEvaluation INTO @Probation_Evaluation_ID,@Evaluation_Date,@TotalProb,@Tran_Id
		--END
		--CLOSE CurrProbationEvaluation	
		--DEALLOCATE CurrProbationEvaluation
						
	FETCH NEXT FROM CurrTotProbation INTO @TotalProb,@Old_Probation_EndDate
	END
	CLOSE CurrTotProbation	
	DEALLOCATE CurrTotProbation
			
	--SELECT * FROM #Lable
	DECLARE @CurrTran_ID	NUMERIC
	DECLARE @CurrRpt_Level	NUMERIC
	DECLARE @Extend_Period INT
	SET @CurrTran_ID = 0
	SET @CurrRpt_Level = 0	
	
	DECLARE Curr_Trainee CURSOR FOR
		SELECT DISTINCT EPM.Tran_Id,EPM.Rpt_Level,EPM.Probation_Evaluation_ID,EPM.Old_Probation_EndDate,EPM.Extend_Period 
		FROM T0115_EMP_PROBATION_MASTER_LEVEL EPM WITH (NOLOCK)
		INNER JOIN #Emp_Probation EP ON EPM.Old_Probation_EndDate=EP.Old_Probation_EndDate
		WHERE Emp_id = @Emp_Id AND EPM.Rpt_Level >0	AND EPM.Cmp_id=@CMP_ID	
	OPEN Curr_Trainee	
	FETCH NEXT FROM Curr_Trainee INTO @CurrTran_ID,@CurrRpt_Level,@Probation_Evaluation_ID,@Old_Probation_EndDate,@Extend_Period
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @Exe_Query = ''
				--	select @CurrTran_ID,@CurrRpt_Level
				SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(Approval_Period_Type,'''')
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),L.Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + ''' AND Def_ID = 2'
				--PRINT @Exe_Query
				EXEC (@Exe_Query)
				SET @Exe_Query = ''
				
				-- Employee Type
				SET @Exe_Query = 'UPDATE #Lable
				SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(T.Type_Name,'''')
				FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
				INNER JOIN T0040_TYPE_MASTER AS T ON EM.Emp_Type_Id = T.Type_ID
				WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),L.Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + ''' AND Def_ID = 3' 
				--PRINT @Exe_Query
				EXEC (@Exe_Query)
				SET @Exe_Query = ''				
				
				IF @Extend_Period >0
				BEGIN
					SET @Exe_Query = 'UPDATE #Lable
						SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(Extend_Period,0)
						FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
						WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),L.Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + ''' AND Def_ID = 4'
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
					
					SET @Exe_Query = 'UPDATE #Lable 
						SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = CASE WHEN isnull(Extend_Period,0) > 0 Then CONVERT(VARCHAR(15),New_Probation_EndDate,103) Else ''''  END
						FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
						WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),L.Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + ''' AND Def_ID = 5'
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
				END
				--
			--IF @flagDefaultProbation=1
			--BEGIN
				SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(Major_Strength,'''')
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND Def_ID = 6'
				
				EXEC (@Exe_Query)
				SET @Exe_Query = ''
				
				SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(Major_Weakness,'''')
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND Def_ID = 7'
				
				EXEC (@Exe_Query)
				SET @Exe_Query = ''
				
				SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(Appraiser_Remarks,'''')
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND Def_ID = 8'
				
				EXEC (@Exe_Query)
				SET @Exe_Query = ''
				
				SET @Exe_Query = 'UPDATE #Lable
				SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(Appraisal_Reviewer_Remarks,'''')
				FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
				WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND Def_ID = 9'
						
				EXEC (@Exe_Query)
				SET @Exe_Query = ''
			--END	
			if @flagDefaultProbation=1
				BEGIN
				print @CurrRpt_Level
					----Skill----
					SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(EPS.Skill_Rating,0)
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EPS ON L.Skill_Attr_ID = EPS.Skill_ID 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + '''  AND Def_ID = 10'
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''	
				END
			ELSE
				BEGIN	
				print 'k'
					----Skill Strength----					
					SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = EPS.strengths
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EPS ON L.Skill_Attr_ID = EPS.Skill_ID 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + '''  AND Lable_name=''Strengths'' AND ISNULL(EPS.strengths,'''')<>'''' '
					print @Exe_Query
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
					
					----Skill Other Factors----					
					SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = EPS.Other_Factors
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EPS ON L.Skill_Attr_ID = EPS.Skill_ID 					
					WHERE EPS.Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND EPS.EMP_ID=' + CAST(@EMP_ID AS VARCHAR(20)) + ' AND CONVERT(VARCHAR(15),L.Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + '''  AND Lable_name=''Other Factors to Improve'' AND ISNULL(EPS.Other_Factors,'''')<>'''' '
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
					
					----Skill Rating----					
					SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = Title
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EPS ON L.Skill_Attr_ID = EPS.Skill_ID 					
					INNER JOIN T0040_RATING_MASTER RM ON RM.Rating_Id=EPS.Skill_Rating
					WHERE EPS.Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND EPS.EMP_ID=' + CAST(@EMP_ID AS VARCHAR(20)) + ' AND CONVERT(VARCHAR(15),L.Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + '''  AND Lable_name=''Rating'' '
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
					
					----Skill Remarks----
					SET @Exe_Query = 'UPDATE #Lable
					SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = EPS.Remarks
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EPS ON L.Skill_Attr_ID = EPS.Skill_ID 
					WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + ''' AND Lable_name=''Remarks'' AND ISNULL(EPS.Remarks,'''')<>'''' '
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
				END
				----Attribute----
				SET @Exe_Query = 'UPDATE #Lable
				SET Rpt_Mgr_'+ CAST(@CurrRpt_Level AS VARCHAR(100)) +' = isnull(EPA.Attr_Rating,0)
				FROM #Lable L INNER JOIN T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_Level EPA ON L.Skill_Attr_ID = EPA.Attribute_ID 
				WHERE Tran_ID = ' + CAST(@CurrTran_ID AS VARCHAR(100)) + ' AND CONVERT(VARCHAR(15),Old_Probation_EndDate,103)= ''' + CONVERT(VARCHAR(15),@Old_Probation_EndDate,103) + ''' AND Def_ID = 11' 
				
				EXEC (@Exe_Query)
				SET @Exe_Query = ''
				
				FETCH NEXT FROM Curr_Trainee INTO @CurrTran_ID,@CurrRpt_Level,@Probation_Evaluation_ID,@Old_Probation_EndDate,@Extend_Period
			END
	CLOSE Curr_Trainee	
	DEALLOCATE Curr_Trainee
				
					----Skill----
					SET @Exe_Query = 'UPDATE #Lable
					SET Final_Rating = isnull(EPS.Skill_Rating,0)
					FROM #Lable L INNER JOIN T0100_EMP_PROBATION_SKILL_DETAIL EPS ON L.Skill_Attr_ID = EPS.Skill_ID
					INNER JOIN T0095_EMP_PROBATION_MASTER EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate and EPS.EMP_PROB_ID=EM.Probation_Evaluation_ID
					WHERE EM.Probation_Evaluation_ID = ' + CAST(@Probation_Evaluation_ID AS VARCHAR(100)) + ''
					print @Exe_Query
					EXEC (@Exe_Query)
					SET @Exe_Query = ''

					----Attribute----
					SET @Exe_Query = 'UPDATE #Lable
					SET Final_Rating = isnull(EPS.Attr_Rating,0)
					FROM #Lable L INNER JOIN T0100_EMP_PROBATION_ATTRIBUTE_DETAIL EPS ON L.Skill_Attr_ID = EPS.Attribute_ID
					INNER JOIN T0095_EMP_PROBATION_MASTER EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate and EPS.EMP_PROB_ID=EM.Probation_Evaluation_ID
					WHERE EM.Probation_Evaluation_ID = ' + CAST(@Probation_Evaluation_ID AS VARCHAR(100)) + ''
					print @Exe_Query
					EXEC (@Exe_Query)
					SET @Exe_Query = ''

				--DECLARE @Tran_ID AS NUMERIC(18,0)	
				select @Tran_ID=Tran_Id FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK)
				WHERE Emp_id=@EMP_ID AND Cmp_id=@CMP_ID and Is_Self_Rating=1 and Probation_Status=0
				
				IF @Tran_ID > 0
					BEGIN
					SET @Exe_Query = ''						
					SET @Exe_Query = 'UPDATE #Lable
						SET Employee_Rating = isnull(Approval_Period_Type,0)
						FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
						WHERE Tran_ID = ' + CAST(@Tran_ID AS VARCHAR(100)) + ' AND Def_ID = 2 and Is_Self_Rating=1 and Probation_Status=0'
					--PRINT @Exe_Query
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
					
					IF @flagDefaultProbation=1
					BEGIN
						SET @Exe_Query = 'UPDATE #Lable
							SET Employee_Rating = isnull(Major_Strength,'''')
							FROM #Lable L INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
							WHERE Tran_ID = ' + CAST(@Tran_ID AS VARCHAR(100)) + ' AND Def_ID = 6 and Is_Self_Rating=1 and Probation_Status=0'
						
						EXEC (@Exe_Query)
						SET @Exe_Query = ''
					END	
					----Skill----
					SET @Exe_Query = 'UPDATE #Lable
					SET Employee_Rating = isnull(EPS.Skill_Rating,0)
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL EPS ON L.Skill_Attr_ID = EPS.Skill_ID
					INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
					WHERE EPS.Tran_ID = ' + CAST(@Tran_ID AS VARCHAR(100)) + ' AND Def_ID = 10 and Is_Self_Rating=1'
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''
					
					----Attribute----
					SET @Exe_Query = 'UPDATE #Lable
					SET Employee_Rating = EPA.Attr_Rating
					FROM #Lable L INNER JOIN T0115_EMP_PROBATION_ATTRIBUTE_DETAIL_Level EPA ON L.Skill_Attr_ID = EPA.Attribute_ID
					INNER JOIN T0115_EMP_PROBATION_MASTER_LEVEL EM ON L.Old_Probation_EndDate = EM.Old_Probation_EndDate 
					WHERE EPA.Tran_ID = ' + CAST(@Tran_ID AS VARCHAR(100)) + ' AND Def_ID = 11 and Is_Self_Rating=1' 
					
					EXEC (@Exe_Query)
					SET @Exe_Query = ''					
				END
    SELECT * FROM #Lable  
    
END

