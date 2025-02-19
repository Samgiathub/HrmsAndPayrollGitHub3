---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Trainee_Application_Records]
	@Cmp_ID		NUMERIC(18,0),
	@Emp_ID		NUMERIC(18,0),
	@Rpt_level	NUMERIC(18,0),
	@Constrains NVARCHAR(MAX),
	@Type		NUMERIC(18,0)= 0,
	@Emp_Search NVARCHAR(MAX)=' 1=1 ',
	@flag		VARCHAR(20)='Pending'
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--DECLARE @flag as varchar(20)
	
	--set @flag='Pending'
IF @flag='Pending' --FOR Pending Records at ess side
BEGIN
	DECLARE @Scheme_ID		AS NUMERIC(18,0)
	DECLARE @Leave			AS VARCHAR(100)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager	AS TINYINT
	DECLARE @SqlQuery			AS NVARCHAR(MAX)
	DECLARE @MaxLevel			AS NUMERIC(18,0)
	DECLARE @Rpt_level_Minus_1	AS NUMERIC(18,0)
	DECLARE @Manager_Branch		NUMERIC(18,0)  
	DECLARE @Emp_ID_Cur		NUMERIC(18,0)
	DECLARE @is_res_passed	TINYINT
	DECLARE @rpt_levle_cur	TINYINT
	
	DECLARE @Review_Month numeric(18,0)
	DECLARE	@Completed_Month  numeric(18,0)
	DECLARE @Review_Type  varchar(15)
	DECLARE @Date_Of_Join  DATETIME	
	DECLARE @ctr_Trainee_probation numeric(18,0)	
	DECLARE @new_Probation_date  DATETIME
	DECLARE @month numeric(18,0)
	
	DECLARE @Extend_Period NUMERIC(18,0)
	DECLARE @New_Probation_EndDate DATETIME
	DECLARE @Maxflag VARCHAR(15)
	DECLARE @Review_Total_month as NUMERIC(18,0)
	DECLARE @FinalExtend_Probation_EndDate as DATETIME
	
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 18072018
	DECLARE @Is_Trainee_Month_Days AS TINYINT
	SET @Emp_ID_Cur		= 0
	SET @is_res_passed	= 0
	SET @is_rpt_manager = 0
	SET @is_branch_manager = 0
	SET @rpt_levle_cur	= 0
	 
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Trainee'

	CREATE TABLE #Responsiblity_Passed
	 (		 
	     Emp_ID	NUMERIC(18,0)	
	    ,is_res_passed TINYINT DEFAULT 1  
	 )  
	 
	 INSERT INTO #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 INSERT INTO #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE pass_to_emp_id = @Emp_ID AND  GETDATE() >= from_date AND GETDATE() <= to_date  and Type='Trainee'  --Change by Jaina 24-04-2017
				
	 CREATE TABLE #tbl_Scheme_Leave 
	 (
		Scheme_ID			NUMERIC(18,0)
	   ,Leave				VARCHAR(100) 
	   ,Final_Approver		TINYINT
	   ,Is_Fwd_Leave_Rej	TINYINT
	   ,is_rpt_manager		TINYINT NOT NULL DEFAULT 0
	   ,is_branch_manager	TINYINT NOT NULL DEFAULT 0
	   ,rpt_level			NUMERIC(18,0)
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 18072018
	 )  
	
	CREATE TABLE #tbl_Leave_App
	 (
		Leave_App_ID	NUMERIC(18,0)
	   ,Scheme_ID		NUMERIC(18,0)
	   ,Leave			VARCHAR(100) 
	   ,rpt_level		NUMERIC(18,0)
	 )
	 
	IF @Rpt_level > 0
		BEGIN
			SET @MaxLevel = @Rpt_level
		END
	ELSE
		BEGIN
			SET @Rpt_level = 1
		END
		
	CREATE TABLE #Trainee
	(
	 Cmp_ID					NUMERIC(18,0)
	,Emp_ID					NUMERIC(18,0)
	,Emp_Full_Name			NVARCHAR(200)
	,Alpha_Emp_Code			NVARCHAR(100)
	,Emp_First_Name			NVARCHAR(200)
	,Branch_Name			NVARCHAR(100)
	,Branch_Id				NUMERIC(18,0) 					
	,Date_OF_Join			DATETIME
	,Probation_Date			DATETIME
	,Final_Approver			TINYINT
	,Rpt_Level				NUMERIC(18,0)
	,Scheme_ID				NUMERIC(18,0)
	,Is_Fwd_Leave_Rej		TINYINT
	,Desig_Id				NUMERIC(18,0)
	,Completed_Month		NUMERIC(18,0)
	,Review_Type			VARCHAR(15)
	,Is_Trainee_Month_Days  TINYINT
	,Approval_Period_Type VARCHAR(20)
	,Dept_Id				NUMERIC(18,0)
	,Probation_Evaluation_ID int
	)
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Trainee')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #Trainee
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT COUNT(1) AS Trainee_App FROM #Trainee 
							END
						ELSE
							SELECT COUNT(1) AS Trainee_App FROM #Trainee 
					END	
						
				RETURN
			END
			
		
		
		------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		DECLARE @string_1	VARCHAR(MAX)
 		
 		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 			( SELECT MAX(Effect_Date) AS Effect_Date,Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
 																	WHERE R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed)) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) FOR XML PATH (''))
		
		
			
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			END	
		
		
				
		DECLARE Employee_Cur CURSOR
			FOR SELECT DISTINCT Emp_ID,is_res_passed FROM #Responsiblity_Passed
		OPEN Employee_Cur
		FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @Rpt_level = 1
			 
				IF @Emp_ID_Cur > 0
					BEGIN
			 	 		SET @Manager_Branch = 0
						IF EXISTS (SELECT 1 FROM T0095_MANAGERS WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur)
							BEGIN
								SELECT @Manager_Branch = branch_id FROM T0095_MANAGERS WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur AND Effective_date = 
								(
									SELECT MAX(Effective_date) AS Effective_date FROM T0095_MANAGERS WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur AND Effective_date <= GETDATE()
								)
							END
						
		 				WHILE @Rpt_level <= @MaxLevel
							BEGIN
								SET @Rpt_level_Minus_1 = @Rpt_level - 1
								SET @rpt_levle_cur = 0
								
								IF @Emp_ID_Cur > 0
									BEGIN
										INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Is_RMToRM
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE App_Emp_Id = @Emp_ID_Cur AND rpt_level = @Rpt_level AND SM.Scheme_Type = 'Trainee'
									
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
											BEGIN
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
 																	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Is_RMToRM
																	From T0050_Scheme_Detail WITH (NOLOCK)
																	Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																	Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
																		And T0040_Scheme_Master.Scheme_Type = ''Trainee'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
													
												EXEC (@string_1)
											END
											
										--Added By Jimit 18072018										
										Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
												BEGIN
													 
													 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
																Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
																And T0040_Scheme_Master.Scheme_Type = ''Trainee''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
													
													  EXEC (@string_1)														
												END	
											
										IF @Manager_Branch > 0 
											BEGIN
												INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Is_RMToRM)
													SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level ,Is_RMToRM
													FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
													WHERE rpt_level = @Rpt_level AND Is_BM = 1 AND SM.Scheme_Type = 'Trainee'
										
											END
											
									END
								ELSE
									BEGIN									
										INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM 
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE SM.Scheme_Type = 'Trainee'
									END
						
						
					 			DECLARE Final_Approver CURSOR
									FOR SELECT DISTINCT Scheme_Id, Leave,rpt_level FROM #tbl_Scheme_Leave 
								OPEN Final_Approver
								FETCH NEXT FROM Final_Approver INTO @Scheme_ID, @Leave,@rpt_levle_cur
								WHILE @@FETCH_STATUS = 0
									BEGIN
									 			
										IF EXISTS (SELECT 1 FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave AND Rpt_Level = @Rpt_level + 1 AND NOT_MANDATORY = 0)
											BEGIN
												UPDATE #tbl_Scheme_Leave 
												SET Final_Approver = 0 
												WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave AND rpt_level =  @Rpt_level
											END
										ELSE 
											BEGIN
												UPDATE #tbl_Scheme_Leave 
												SET Final_Approver = 1 
												WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave  AND rpt_level =  @Rpt_level
											END
														
										FETCH NEXT FROM Final_Approver INTO @Scheme_ID, @Leave,@rpt_levle_cur
									END
								CLOSE Final_Approver
								DEALLOCATE Final_Approver	
										
								DECLARE cur_Scheme_Leave CURSOR
									FOR SELECT Scheme_Id, Leave,is_rpt_manager,is_branch_manager,Is_RMToRM FROM #tbl_Scheme_Leave WHERE rpt_level = @Rpt_level 
								OPEN cur_Scheme_Leave
								FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
								WHILE @@FETCH_STATUS = 0
									BEGIN
										CREATE TABLE #Emp_Cons 
										 (
										   Emp_ID NUMERIC    
										 ) 
											
										IF @is_branch_manager = 1
											BEGIN
										 		INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ES.Emp_ID FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
													INNER JOIN
														 ( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
															WHERE Scheme_Id = @Scheme_ID AND Effective_Date<=GETDATE() AND TYPE='Trainee' GROUP BY emp_ID
														 ) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Trainee'
													INNER JOIN 
														( SELECT Branch_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
														   ( SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)   
															  WHERE Increment_Effective_date <= GETDATE() AND Cmp_ID = @Cmp_ID GROUP BY emp_ID
															) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date 
														 ) AS INC ON INC.Emp_ID = Qry.Emp_ID
												WHERE ES.Scheme_Id = @Scheme_ID AND INC.Branch_ID = @Manager_Branch
													
												IF @Rpt_level = 1
													BEGIN
													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_TRAINEE_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))  AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
																  + ' And ' + @Emp_Search	  
														 
													END
												ELSE
													BEGIN													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_TRAINEE_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' 
																AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))
																AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															    And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															   )' + ' And ' + @Emp_Search
														
																 
													END
																																	
											END
										ELSE IF @is_rpt_manager = 1
											BEGIN
											--select 555
										 		INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ERD.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN 
														( SELECT MAX(Effect_Date) AS Effect_Date, Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
														  WHERE Effect_Date<=GETDATE() AND R_emp_id = @Emp_ID_Cur GROUP BY emp_ID
														) RQry ON  ERD.Emp_ID = RQry.Emp_ID AND ERD.Effect_Date = RQry.Effect_Date
													INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) ON ES.Emp_ID = ERD.Emp_ID 
													INNER JOIN
														( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														  WHERE Effective_Date<=GETDATE() AND TYPE='Trainee' GROUP BY emp_ID
														)  Qry ON  ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Trainee'
												WHERE R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
												
												DELETE FROM #Emp_Cons 
												WHERE Emp_ID NOT IN (
													Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN 
														( select MAX(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN #Emp_Cons EC1 on EC1.Emp_ID = ERD1.Emp_ID 
															where Effect_Date<=GETDATE() GROUP BY ERD1.emp_ID
														) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date and R_emp_id = @Emp_ID_Cur
													INNER JOIN #Emp_Cons EC on EC.Emp_ID = RQry.Emp_ID 
												)
													
												IF @Rpt_level = 1
													BEGIN
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_TRAINEE_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' 
														--AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))  
														AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')' 
																  + ' And ' + @Emp_Search	  
														--print @SqlQuery
													END
												ELSE
													BEGIN													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_TRAINEE_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															    And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															    )' + ' And ' + @Emp_Search																
													END
												
											END
										---------Added By Jimit 18072018-------------												
												ELSE IF @is_Reporting_To_Reporting_manager = 1 and @Rpt_level = 2
														BEGIN
															 IF @Rpt_level = 2
																	BEGIN
																			
																		IF Object_ID('tempdb..#EMP_CONS_RM') IS NOT NULL
																			DROP TABLE #EMP_CONS_RM
																			
																				
																				CREATE TABLE #EMP_CONS_RM 
																				(
																				   Emp_ID		NUMERIC,
																				   BRANCH_ID	NUMERIC,
																				   INCREMENT_ID NUMERIC,
																				   R_EMP_ID		NUMERIC DEFAULT 0 ,
																				   Scheme_ID	NUMERIC ,
																				   Rpt_Level	TinyINT
																				) 
																			
																				DECLARE @date as DATETIME
																				SET @date = GETDATE()
																				
																				EXEC SP_RPT_FILL_EMP_CONS_WITH_REPORTING	@Cmp_ID=@Cmp_ID,@From_Date=@date,@To_Date=@date,@Branch_ID=0,
																															@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID = @Emp_ID_Cur,@Constraint='',@Sal_Type = 0,
																															@Salary_Cycle_id = 0,@Segment_Id = 0,@Vertical_Id = 0,@SubVertical_Id = 0,@SubBranch_Id= 0,
																															@New_Join_emp = 0,@Left_Emp = 0,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc	= 0,@Type = 0 ,
																															@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Trainee' 										
																				
																			
																				SET @SqlQuery =	   'Select  Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																									FROM	(SELECT LAD.Emp_ID,LAd.Alpha_Emp_Code,Emp_First_Name,LAD.probation_date
																											From	V0080_EMP_TRAINEE_GET LAD 
																													INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																													LEFT OUTER JOIN (SELECT Emp_ID,S_Emp_ID,Status As App_Status FROM T0115_EMP_PROBATION_MASTER_LEVEL LA WITH (NOLOCK) WHERE Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) and S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																																		ON LAD.Emp_ID=LA.Emp_ID
																											Where	 (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) and Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																															'And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) and Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																														')																										
																											) T
																									WHERE	1=1  and ' + @Emp_Search	
																		
																	END															
														END												
												------------Ended-----------------
										ELSE IF @is_rpt_manager = 0 AND @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
											BEGIN
											
												INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ES.Emp_ID FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
												INNER JOIN
													( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														WHERE Scheme_Id = @Scheme_ID AND Effective_Date<=GETDATE() AND TYPE='Trainee' GROUP BY emp_ID
													 ) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date      AND Scheme_Id = @Scheme_ID AND TYPE='Trainee'
														WHERE ES.Scheme_Id = @Scheme_ID 
														
											 	IF @Rpt_level = 1
													BEGIN
													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_TRAINEE_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))  AND  Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'
															+ ' And ' + @Emp_Search	  
														 
													END
												ELSE
													BEGIN
													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_TRAINEE_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' 
															   AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))
															   AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															   And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Trainee'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															  )' + ' And ' + @Emp_Search
																  
																 
													END
												
											END	
										 
								
										INSERT INTO #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										EXEC (@SqlQuery)

										DROP TABLE #Emp_Cons
									
									

									  FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
									END
								CLOSE cur_Scheme_Leave
								DEALLOCATE cur_Scheme_Leave
					
								SET @Rpt_level = @Rpt_level + 1
							END						
					END			
		
				IF @Emp_ID_Cur > 0
					BEGIN			
					--print 'm'
					--SELECT * FROM V0080_EMP_TRAINEE_GET
					--select * from #tbl_Leave_App
						INSERT INTO #Trainee
						SELECT DISTINCT	
							LAD.Cmp_ID,LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Alpha_Emp_code, LAD.Emp_first_name, LAD.Branch_Name, LAD.Branch_ID,
							LAD.Date_Of_Join,--LAD.probation_date,
							CASE WHEN ISNULL(Qry1.probation_date,'') = '' THEN LAD.probation_date ELSE Qry1.probation_date END,
							SL.Final_Approver,ISNULL(Qry1.rpt_level + 1,'1') AS Rpt_Level, TLAP.Scheme_ID,SL.Is_Fwd_Leave_Rej , LAD.Desig_Id,
							LAD.Training_Month AS Completed_Month,LAD.Trainee_Review AS Review_Type,LAD.Is_Trainee_Month_Days,LAD.Approval_Period_Type,LAD.Dept_ID,isnull(Probation_Evaluation_ID,0)
						FROM V0080_EMP_TRAINEE_GET LAD 
							LEFT OUTER JOIN 
								( SELECT lla.Emp_id AS Emp_id, Rpt_Level AS Rpt_Level , lla.New_Probation_EndDate AS probation_date ,Probation_Evaluation_ID
									FROM T0115_EMP_PROBATION_MASTER_LEVEL lla WITH (NOLOCK) INNER JOIN 
										( SELECT MAX(rpt_level) AS rpt_level1, Emp_id FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) INNER JOIN
											( SELECT Leave_App_ID FROM #tbl_Leave_App) qry ON T0115_EMP_PROBATION_MASTER_LEVEL.Emp_id=qry.Leave_App_ID 
										  WHERE Flag = 'Trainee' AND Probation_Evaluation_ID = 0 GROUP BY Emp_id 
										) Qry ON qry.Emp_id = lla.Emp_id AND qry.rpt_level1 = lla.rpt_level and lla.Flag = 'Trainee' 
									WHERE NOT EXISTS ( SELECT New_Probation_EndDate FROM T0095_EMP_PROBATION_MASTER A WITH (NOLOCK) WHERE A.Flag = 'Trainee' and lla.Emp_id = A.Emp_ID AND A.New_Probation_EndDate = lla.New_Probation_EndDate )		
								) AS Qry1 ON  LAD.Emp_id = Qry1.Emp_id AND Qry1.Probation_Evaluation_ID = 0	-- This join is for getting updated from date,to date and leave period in case if any middle approver change it, then next should be see updated info and not old one 
							INNER JOIN #tbl_Leave_App TLAP  ON TLAP.Leave_App_ID = LAD.Emp_id 
							INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID AND SL.Leave = TLAP.Leave 
							AND  SL.rpt_level > ISNULL(Qry1.Rpt_Level,0) 
							AND  SL.rpt_level = TLAP.rpt_level
							INNER JOIN (SELECT Leave_App_ID FROM #tbl_Leave_App) qry ON lad.Emp_id=qry.Leave_App_ID		
					END
					
				
				DELETE #tbl_Scheme_Leave
				DELETE #tbl_Leave_App
				
			  FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
			END
		CLOSE Employee_Cur
		DEALLOCATE Employee_Cur
		
		--SELECT * FROM #Trainee
		--ADDED BY MUKTI(START)06122017		
		--DECLARE PROBATION_TRAINEE_DETAILS CURSOR FOR
		--	   SELECT Emp_ID,Completed_Month,Date_Of_Join,Review_Type FROM #Trainee --where emp_id=21158
		--OPEN PROBATION_TRAINEE_DETAILS
		--FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type
		--while @@fetch_status = 0
		--	BEGIN
		--			set @Extend_Period = 0			
					
		--			SELECT	@Extend_Period=ISNULL(Extend_Period,0), @New_Probation_EndDate=New_Probation_EndDate	
		--				FROM dbo.T0095_EMP_PROBATION_MASTER EM
		--			inner join 
		--			(SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER
		--			 WHERE Flag = 'Trainee' and Emp_ID = @Emp_ID GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id
		--			 WHERE  Flag = 'Trainee' and Emp_ID = @Emp_ID  
							 
		--			 IF (@Extend_Period > 0)
		--				BEGIN
		--					update #Trainee set Probation_Date=@New_Probation_EndDate,Review_Type='Final' where Emp_ID=@Emp_ID
		--				END
		--			 ELSE
		--				BEGIN					 
		--					IF @Review_Type <> ''
		--						BEGIN
		--							SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER 
		--							where Emp_ID=@Emp_ID and Flag = 'Trainee' 
									
		--							IF @Review_Type = 'Quarterly'
		--								set @month = 3
		--							else if @Review_Type = 'Six Monthly'
		--								set @month = 6
									
		--							IF @ctr_Trainee_probation > 0
		--								SET @Review_month=(@month * @ctr_Trainee_probation * 2) 
		--							ELSE
		--								SET @Review_month= @month
									
		--							SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(mm, @Review_month, @Date_Of_Join))
											
		--							IF @Completed_Month > @Review_month 
		--								BEGIN							
		--									update #Trainee set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID
		--								END
		--							ELSE
		--								BEGIN
		--									update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID
		--								END
		--						END
		--					ELSE
		--						BEGIN
		--							update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID
		--						END
		--				END
		--	FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type
		--End
		--close PROBATION_TRAINEE_DETAILS 
		--deallocate PROBATION_TRAINEE_DETAILS
		
		DECLARE PROBATION_TRAINEE_DETAILS CURSOR FOR
				   SELECT Emp_ID,Completed_Month,Date_Of_Join,Review_Type,Is_Trainee_Month_Days FROM #Trainee --where emp_id=21323
			OPEN PROBATION_TRAINEE_DETAILS
			FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Is_Trainee_Month_Days
			while @@fetch_status = 0
				BEGIN	
				--select @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type
					set @Extend_Period = 0	
					set @Review_Total_month =0	
						
					SELECT	@Extend_Period=ISNULL(Extend_Period,0),@New_Probation_EndDate=New_Probation_EndDate,@Maxflag=EM.Flag	
					FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NOLOCK)
					inner join 
						(SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
						        WHERE Emp_ID = @Emp_ID GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
					WHERE  Emp_ID = @Emp_ID  --and Flag = @flag  
					
					IF @Review_Type = 'Quarterly'
						set @month = 3
					else if @Review_Type = 'Six Monthly'
						set @month = 6
						 	
					 IF (@Extend_Period > 0 and @Maxflag = 'Trainee')
						BEGIN

							update #Trainee set Probation_Date=@New_Probation_EndDate,Review_Type='Final' where Emp_ID=@Emp_ID
						END
					--else IF (@Extend_Period > 0 and @Maxflag <> 'Trainee')
					--	BEGIN
					--		print 's'
					--		update #Trainee set Probation_Date=@New_Probation_EndDate,Review_Type=@Review_Type where Emp_ID=@Emp_ID
					--	END
					 ELSE
						BEGIN
							if EXISTS(SELECT New_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NOLOCK)
										inner join (SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
													WHERE Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation' GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
										WHERE  Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation')
								BEGIN
									SELECT @FinalExtend_Probation_EndDate=EM.New_Probation_EndDate,@New_Probation_EndDate=EM.Old_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NOLOCK)
									inner join (SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
														WHERE Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation' GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
									WHERE  Emp_ID = @Emp_ID and Flag='Trainee' and Final_Review=1 and Approval_Period_Type='Probation'	
											
									SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
									where Emp_ID=@Emp_ID and Flag = 'Trainee' 
									
									IF @ctr_Trainee_probation > 0	
										BEGIN	
											SELECT @New_Probation_EndDate=New_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK) 
											WHERE  Emp_ID = @Emp_ID and Flag='Trainee' 																			
											SET @Review_Total_month=(@month + (@ctr_Trainee_probation * @month))
										END
											
									SET @Review_month= @month		
									SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(mm, @Review_month, ISNULL(@New_Probation_EndDate,@Date_Of_Join)))
									
									if @FinalExtend_Probation_EndDate < @new_Probation_date									
										update #Trainee set Review_Type='Final',Probation_Date= @FinalExtend_Probation_EndDate where Emp_ID=@Emp_ID
									ELSE	
										update #Trainee set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID
								END							
							ELSE									
								BEGIN				
									IF @Review_Type <> ''
										BEGIN
											SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER  WITH (NOLOCK)
											where Emp_ID=@Emp_ID and Flag = 'Trainee' 
											
											
											IF @Is_Trainee_Month_Days=0	--for Month Completion Period	
												BEGIN
													IF @ctr_Trainee_probation > 0																						
															SET @Review_month=(@month + (@ctr_Trainee_probation * @month))												
													ELSE												
															SET @Review_month= @month
															
													SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(mm, @Review_month, @Date_Of_Join))
													IF @Completed_Month > @Review_month
															update #Trainee set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID												
													ELSE													
															update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID												
												END		
											 ELSE --for Days Completion Period	
												BEGIN												
													if @month = 3
														set @month=90
													else if @month = 6 
														set @month=180
														
													IF @ctr_Trainee_probation > 0																						
															SET @Review_month=(@month + (@ctr_Trainee_probation * @month)) 												
													ELSE												
															SET @Review_month= @month
															
													SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(DAY, @Review_month, @Date_Of_Join))
													
													--PRINT @new_Probation_date													
													--set @Review_month= DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,@Review_month),0)))
													IF @Completed_Month > @Review_month
															update #Trainee set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID												
													ELSE												
															update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(DAY,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID	--for Days period												
														
												END
														
										END
									ELSE
										BEGIN
											--update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID											
											IF @Is_Trainee_Month_Days=0
												update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID											
											ELSE
												update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(DAY,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID											
										END
								END
						END					
				--END
				FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Is_Trainee_Month_Days
			End
		close PROBATION_TRAINEE_DETAILS 
		deallocate PROBATION_TRAINEE_DETAILS
		--ADDED BY MUKTI(END)06122017		
		DECLARE @queryExe AS VARCHAR(MAX)
		IF @Type = 0
			BEGIN
				IF @Emp_ID_Cur > 0
					BEGIN
					--select * from #Trainee
						--SELECT 0 AS Tran_ID,0 AS Probation_Status,getdate() As Evaluation_Date,getdate() AS Old_Probation_EndDate, * FROM #Trainee ORDER BY #Trainee.Probation_Date DESC
						SET @queryExe = 'SELECT 0 AS Tran_ID,0 AS Probation_Status,getdate() As Evaluation_Date,getdate() AS Old_Probation_EndDate, * FROM #Trainee where ' + @Constrains +' and '+ @Emp_Search + ' ORDER BY #Trainee.Probation_Date DESC '
						EXEC (@queryExe)
					END
				ELSE
					BEGIN
				
						SET @queryExe = 'select 0 AS Tran_ID, * from #Trainee where ' + @Constrains +' and '+ @Emp_Search + ' order by #Trainee.Probation_Date desc '
						EXEC (@queryExe)
					END
			END
		ELSE IF @Type = 1
			BEGIN
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(1) AS Trainee_App FROM #Trainee 
					END
				ELSE
					SELECT COUNT(1) AS Trainee_App FROM #Trainee 
				
			END
		
		DROP TABLE #tbl_Scheme_Leave
		DROP TABLE #tbl_Leave_App
		DROP TABLE #Responsiblity_Passed
		DROP TABLE #Trainee	
	END
ELSE  --FOR Approved Records
	BEGIN
	DECLARE @Approval_Period_Type as VARCHAR(25)
		--SELECT @Approval_Period_Type=Approval_Period_Type FROM T0115_EMP_PROBATION_MASTER_LEVEL WHERE S_Emp_ID=@emp_id and Flag='Trainee' and Final_Review=1
		--if @Approval_Period_Type ='Probation'
		--	BEGIN
		--	print 'd'
		--		SET @queryExe = 'SELECT DISTINCT ET.Cmp_ID,ET.Emp_ID, ET.Emp_Full_Name, ET.Alpha_Emp_code, ET.Emp_first_name, ET.Branch_Name, ET.Branch_ID,
		--		ET.Date_Of_Join,
		--		CASE WHEN ISNULL(qry.probation_date,'''') = '''' THEN ET.probation_date ELSE qry.probation_date END AS Probation_Date,
		--				ISNULL(qry.rpt_level + 1,''1'') AS Rpt_Level,ET.Desig_Id ,qry.S_Emp_ID AS S_Emp_ID_A,qry.Status AS Status
		--				,qry.Evaluation_Date,qry.Old_Probation_EndDate,qry.Tran_Id,probation_Status
		--				,0 As Scheme_Id,0 As Final_Approver,0 As Is_Fwd_Leave_Rej,ET.Probation as Training_Month,Review_Type,qry.Training_ID,qry.Approval_Period_Type,
		--				qry.Major_Strength,qry.Major_Weakness,qry.Appraiser_Remarks,qry.Appraisal_Reviewer_Remarks,ET.Desig_Name,ET.Dept_Name,ET.[Type_Name],qry.Extend_Period,qry.New_Probation_EndDate,ET.DEPT_ID
		--		FROM	dbo.V0080_EMP_Probation_GET AS ET INNER JOIN
		--				  ( SELECT  PT.Emp_id AS Emp_id, Qry.Rpt_Level AS Rpt_Level , PT.New_Probation_EndDate AS probation_date,pt.S_Emp_ID,PT.Status,PT.Evaluation_Date,PT.Old_Probation_EndDate,PT.Tran_Id,PT.probation_Status,
		--				  PT.Training_ID,PT.Approval_Period_Type,PT.Major_Strength,PT.Major_Weakness,PT.Appraiser_Remarks,PT.Appraisal_Reviewer_Remarks,pt.Review_Type,pt.Extend_Period,pt.New_Probation_EndDate
		--					FROM   dbo.T0115_EMP_PROBATION_MASTER_LEVEL AS PT 
		--						INNER JOIN
		--							( SELECT MAX(Rpt_Level) AS Rpt_Level, Emp_id 
		--							  FROM dbo.T0115_EMP_PROBATION_MASTER_LEVEL PT1 WHERE FLAG = ''Trainee''  AND PT1.Approval_Period_Type=''Probation''						
		--							  GROUP BY Emp_id
		--							 ) AS Qry ON Qry.Rpt_Level = PT.Rpt_Level AND Qry.Emp_id = PT.Emp_id 
		--						INNER JOIN dbo.T0115_EMP_PROBATION_MASTER_LEVEL AS LA ON LA.Emp_id = PT.Emp_id
		--					WHERE PT.FLAG = ''Trainee'' AND  (PT.Status = ''A'' OR PT.Status = ''R'') 					
		--				  ) AS qry ON ET.Emp_ID = qry.Emp_ID
		--		where qry.S_Emp_ID='+cast(@emp_id as varchar(50))+' and isnull(qry.Extend_Period,0) > 0 and  '+ @Constrains +' and '+ @Emp_Search + ''
		--	END
		--else IF EXISTS(SELECT 1 FROM T0115_EMP_PROBATION_MASTER_LEVEL WHERE S_Emp_ID=@emp_id and Flag='Trainee' and Final_Review=1 AND ISNULL(Probation_Evaluation_ID,0) >0)
		--	BEGIN
		--	print 'm'
		--		SET @queryExe = 'SELECT  ET.Cmp_ID,ET.Emp_ID, ET.Emp_Full_Name, ET.Alpha_Emp_code, ET.Emp_first_name, ET.Branch_Name, ET.Branch_ID,
		--		ET.Date_Of_Join,
		--		CASE WHEN ISNULL(qry.probation_date,'''') = '''' THEN ET.probation_date ELSE qry.probation_date END AS Probation_Date,
		--				ISNULL(qry.rpt_level + 1,''1'') AS Rpt_Level,ET.Desig_Id ,qry.S_Emp_ID AS S_Emp_ID_A,qry.Status AS Status
		--				,qry.Evaluation_Date,qry.Old_Probation_EndDate,qry.Tran_Id,probation_Status
		--				,0 As Scheme_Id,0 As Final_Approver,0 As Is_Fwd_Leave_Rej,ET.Training_Month,Review_Type,qry.Training_ID,qry.Approval_Period_Type,
		--				qry.Major_Strength,qry.Major_Weakness,qry.Appraiser_Remarks,qry.Appraisal_Reviewer_Remarks,ET.Desig_Name,ET.Dept_Name,ET.[Type_Name],qry.Extend_Period,qry.New_Probation_EndDate,ET.DEPT_ID
		--		FROM	dbo.V0080_EMP_TRAINEE_GET AS ET INNER JOIN
		--				  ( SELECT  PT.Emp_id AS Emp_id, Qry.Rpt_Level AS Rpt_Level , PT.New_Probation_EndDate AS probation_date,pt.S_Emp_ID,PT.Status,Evaluation_Date,Old_Probation_EndDate,Tran_Id,probation_Status,
		--				  PT.Training_ID,PT.Approval_Period_Type,PT.Major_Strength,PT.Major_Weakness,PT.Appraiser_Remarks,PT.Appraisal_Reviewer_Remarks,pt.Review_Type,pt.Extend_Period,pt.New_Probation_EndDate
		--					FROM   dbo.T0115_EMP_PROBATION_MASTER_LEVEL AS PT 
		--						INNER JOIN
		--							( SELECT MAX(Rpt_Level) AS Rpt_Level, Emp_id 
		--							  FROM dbo.T0115_EMP_PROBATION_MASTER_LEVEL PT1 WHERE FLAG = ''Trainee'' 						
		--							  GROUP BY Emp_id
		--							 ) AS Qry ON Qry.Rpt_Level = PT.Rpt_Level AND Qry.Emp_id = PT.Emp_id 
		--						INNER JOIN dbo.V0080_EMP_TRAINEE_GET AS LA ON LA.Emp_id = PT.Emp_id
		--					WHERE PT.FLAG = ''Trainee'' AND  (PT.Status = ''A'' OR PT.Status = ''R'') 					
		--				  ) AS qry ON ET.Emp_ID = qry.Emp_ID
		--		where qry.S_Emp_ID='+cast(@emp_id as varchar(50))+' and  '+ @Constrains +' and '+ @Emp_Search + ''
		--	END
		--ELSE
			BEGIN
			
				SET @queryExe = 'SELECT  ET.Cmp_ID,ET.Emp_ID, ET.Emp_Full_Name, ET.Alpha_Emp_code, ET.Emp_first_name, ET.Branch_Name, ET.Branch_ID,
				ET.Date_Of_Join,
				CASE WHEN ISNULL(qry.probation_date,'''') = '''' THEN ET.probation_date ELSE qry.probation_date END AS Probation_Date,
						ISNULL(qry.rpt_level + 1,''1'') AS Rpt_Level,ET.Desig_Id ,qry.S_Emp_ID AS S_Emp_ID_A,qry.Status AS Status
						,qry.Evaluation_Date,qry.Old_Probation_EndDate,qry.Tran_Id,probation_Status
						,0 As Scheme_Id,0 As Final_Approver,0 As Is_Fwd_Leave_Rej,ET.Training_Month,Review_Type,qry.Training_ID,qry.Approval_Period_Type,
						qry.Major_Strength,qry.Major_Weakness,qry.Appraiser_Remarks,qry.Appraisal_Reviewer_Remarks,ET.Desig_Name,ET.Dept_Name,ET.[Type_Name],qry.Extend_Period,qry.New_Probation_EndDate,qry.Approval_Period_Type,ET.DEPT_ID,Probation_Evaluation_ID
				FROM	dbo.V0080_EMP_TRAINEE_GET AS ET INNER JOIN
						 ( SELECT  PT.Tran_Id,PT.Emp_id AS Emp_id, PT.Rpt_Level AS Rpt_Level , PT.New_Probation_EndDate AS probation_date,pt.S_Emp_ID,PT.Status,Evaluation_Date,Old_Probation_EndDate,probation_Status,
						  PT.Training_ID,PT.Approval_Period_Type,PT.Major_Strength,PT.Major_Weakness,PT.Appraiser_Remarks,PT.Appraisal_Reviewer_Remarks,pt.Review_Type,pt.Extend_Period,pt.New_Probation_EndDate,Probation_Evaluation_ID
							FROM   dbo.T0115_EMP_PROBATION_MASTER_LEVEL AS PT WITH (NOLOCK)
								INNER JOIN
									( SELECT MAX(PT1.Tran_Id) AS Tran_Id, Emp_id 
									  FROM dbo.T0115_EMP_PROBATION_MASTER_LEVEL PT1 WITH (NOLOCK) WHERE FLAG = ''Trainee''-- AND Probation_Evaluation_ID = 0						
									  GROUP BY Emp_id
									 ) AS Qry ON Qry.Tran_Id = PT.Tran_Id AND Qry.Emp_id = PT.Emp_id 
								INNER JOIN dbo.V0080_EMP_TRAINEE_GET AS LA ON LA.Emp_id = PT.Emp_id
							WHERE PT.FLAG = ''Trainee'' AND  (PT.Status = ''A'' OR PT.Status = ''R'')-- AND Probation_Evaluation_ID = 0					
						  ) AS qry ON ET.Emp_ID = qry.Emp_ID
				where qry.S_Emp_ID='+cast(@emp_id as varchar(50))+' and  '+ @Constrains +' and '+ @Emp_Search + ''
			END
	
		
			--PRINT @queryExe
		EXEC (@queryExe)
	END
END

