
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Probation_Application_Records]
	@Cmp_ID		NUMERIC(18,0),
	@Emp_ID		NUMERIC(18,0),
	@Rpt_level	NUMERIC(18,0),
	@Constrains NVARCHAR(MAX),
	@Type		NUMERIC(18,0)= 0,
	@Emp_Search NVARCHAR(MAX)=' 1=1 ',
	@flag		varchar(50) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	
	DECLARE @Scheme_ID		AS NUMERIC(18,0)
	DECLARE @Leave			AS VARCHAR(100)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager	AS TINYINT
	DECLARE @Is_PRM	As TINYINT
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
	DECLARE @Is_Probation_Month_Days AS TINYINT
	
	SET @Emp_ID_Cur		= 0
	SET @is_res_passed	= 0
	SET @is_rpt_manager = 0
	SET @is_branch_manager = 0
	SET @rpt_levle_cur	= 0
	 
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM  WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Probation'

	CREATE TABLE #Responsiblity_Passed
	 (		 
	     Emp_ID	NUMERIC(18,0)	
	    ,is_res_passed TINYINT DEFAULT 1  
	 )  
	 
	 INSERT INTO #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 INSERT INTO #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE pass_to_emp_id = @Emp_ID AND  GETDATE() >= from_date AND GETDATE() <= to_date  and Type='Probation'  --Change by Jaina 24-04-2017
						
	 CREATE TABLE #tbl_Scheme_Leave 
	 (
		Scheme_ID			NUMERIC(18,0)
	   ,Leave				VARCHAR(100) 
	   ,Final_Approver		TINYINT
	   ,Is_Fwd_Leave_Rej	TINYINT
	   ,is_rpt_manager		TINYINT NOT NULL DEFAULT 0
	   ,is_branch_manager	TINYINT NOT NULL DEFAULT 0
	   ,rpt_level			NUMERIC(18,0)
	   ,Is_PRM				TINYINT NOT NULL DEFAULT 0  -- Added by rohit on 17082016
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
	,Is_Probation_Month_Days TINYINT
	,Approval_Period_Type Varchar(25)
	,Dept_ID			int
	)
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Probation')
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
								SELECT COUNT(1) FROM #Trainee where Approval_Period_Type <> 'Confirm' 
							END
						ELSE
							SELECT COUNT(1) AS Pro_OverCnt FROM #Trainee where Approval_Period_Type <> 'Confirm' 
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
		-- Added by rohit for probation manager on 31082016
		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM t0080_emp_master Em WITH (NOLOCK) INNER JOIN 
 		T0080_EMP_MASTER ERD WITH (NOLOCK) ON Em.Manager_Probation = ERD.Emp_ID
		WHERE ERD.Emp_ID = @Emp_ID FOR XML PATH (''))

			IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = case when isnull(@Emp_Cmp_Id ,'')='' then '' else cast(@Emp_Cmp_Id as varchar(max)) + ',' end  + LEFT(@String, LEN(@String) - 1)
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

										INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_PRM,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_PRM,Is_RMToRM
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE App_Emp_Id = @Emp_ID_Cur AND rpt_level = @Rpt_level AND SM.Scheme_Type = 'Probation'
										
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
											BEGIN
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_PRM,Is_RMToRM)
 																	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,IS_PRM ,Is_RMToRM
																	From T0050_Scheme_Detail WITH (NOLOCK)
																	Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																	Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' 
																	and (Is_RM = 1 or Is_PRM = 1) 
																	--and T0050_Scheme_Detail.Cmp_id = '+ CAST(@Cmp_ID AS VARCHAR(50)) +' -- Deepal 16032022 To check the Cross company
																	And T0040_Scheme_Master.Scheme_Type = ''Probation'' 
																	--and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +') -- Deepal 16032022 To check the Cross company
																	'
												
												EXEC (@string_1)
											END
										IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
											BEGIN
											
												Declare @App_Emp_ID as numeric(18,0) = 0
												Declare @App_Cmp_ID as numeric(18,0) = 0
												Select @App_Cmp_ID = scheme_id from #tbl_Scheme_Leave
												Select @App_Emp_ID = App_Emp_ID from T0050_Scheme_Detail where Scheme_Id = @App_Cmp_ID 

												if @App_Emp_ID = 0
												begin
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_PRM,Is_RMToRM)
 																	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,IS_PRM ,Is_RMToRM
																	From T0050_Scheme_Detail WITH (NOLOCK)
																	Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																	Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and (Is_PRM = 1  or Is_RMToRM = 1)
																		And T0040_Scheme_Master.Scheme_Type = ''Probation'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
												
												End
												Else
												begin
													Set @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_PRM,Is_RMToRM)
 																	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,IS_PRM ,Is_RMToRM
																	From T0050_Scheme_Detail WITH (NOLOCK)
																	Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																	Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and T0050_Scheme_Detail.Scheme_ID = '+ cast(@Scheme_ID AS VARCHAR(50))+'
																	And T0040_Scheme_Master.Scheme_Type = ''Probation'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' 
												end
												EXEC (@string_1)
											END	
											--Added By Jimit 18072018										
										--Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
										--		BEGIN
													 
										--			 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
										--						Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
										--						From T0050_Scheme_Detail 
										--						Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--						Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
										--						And T0040_Scheme_Master.Scheme_Type = ''Probation''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
													
										--			  EXEC (@string_1)														
										--		END
										
										IF @Manager_Branch > 0 
											BEGIN
												INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Is_PRM,Is_RMToRM)
													SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level ,IS_PRM,Is_RMToRM
													FROM T0050_Scheme_Detail SD WITH (NOLOCK) 
													INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
													WHERE rpt_level = @Rpt_level AND (Is_BM = 1 or Is_PRM=1) AND SM.Scheme_Type = 'Probation'
										
											END
									END								
								ELSE
									BEGIN
									--select 456
										INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,IS_PRM,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level,IS_PRM ,Is_RMToRM
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE SM.Scheme_Type = 'Probation'
									END
						--select * from #tbl_Scheme_Leave
						
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
									FOR SELECT Scheme_Id, Leave,is_rpt_manager,is_branch_manager,IS_PRM,Is_RMToRM FROM #tbl_Scheme_Leave WHERE rpt_level = @Rpt_level
								OPEN cur_Scheme_Leave
								FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@Is_PRM,@is_Reporting_To_Reporting_manager
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
															WHERE Scheme_Id = @Scheme_ID AND Effective_Date<=GETDATE() AND TYPE='Probation' GROUP BY emp_ID
														 ) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Probation'
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
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
																  + ' And ' + @Emp_Search	
													END
												ELSE
													BEGIN
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' 
																AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))
																AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															    And LAD.Emp_ID In (Select Emp_Id From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															   )' + ' And ' + @Emp_Search
													END																																	
											END
										ELSE IF @is_rpt_manager = 1
											BEGIN
											
											
										 		INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ERD.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN 
														( SELECT MAX(Effect_Date) AS Effect_Date, Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
														  WHERE Effect_Date<=GETDATE() AND R_emp_id = @Emp_ID_Cur GROUP BY emp_ID
														) RQry ON  ERD.Emp_ID = RQry.Emp_ID AND ERD.Effect_Date = RQry.Effect_Date
													INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) ON ES.Emp_ID = ERD.Emp_ID 
													INNER JOIN
														( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														  WHERE Effective_Date<=GETDATE() AND TYPE='Probation' GROUP BY emp_ID
														)  Qry ON  ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Probation'
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
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))  AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')' 
																  + ' And ' + @Emp_Search	  
														
														 
													END
												ELSE
													BEGIN
													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation''  AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															    And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															    )' + ' And ' + @Emp_Search
													END
													
											END
										ELSE IF @is_PRM = 1
											BEGIN
											
										 		INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ERD.Emp_ID FROM T0080_EMP_MASTER ERD WITH (NOLOCK)
													INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) ON ES.Emp_ID = ERD.Emp_ID 
													INNER JOIN
														( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														  WHERE Effective_Date<=GETDATE() AND TYPE='Probation' GROUP BY emp_ID
														)  Qry ON  ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Probation'
												WHERE Manager_Probation = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
												
												DELETE FROM #Emp_Cons 
												WHERE Emp_ID NOT IN (
													Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN T0080_emp_master RQry WITH (NOLOCK) on  ERD.Emp_ID = RQry.Emp_ID  and Manager_Probation  = @Emp_ID_Cur
													INNER JOIN #Emp_Cons EC on EC.Emp_ID = RQry.Emp_ID 
												)
													
												IF @Rpt_level = 1
													BEGIN
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation''  AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))  AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')' 
																  + ' And ' + @Emp_Search	  
														
													END
												ELSE
													BEGIN
													
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															    And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
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
																															@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Probation' 										
																				
																			
																				SET @SqlQuery =	   'Select  Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																									FROM	(SELECT LAD.Emp_ID,LAd.Alpha_Emp_Code,Emp_First_Name
																											From	V0080_EMP_Probation_GET LAD 
																													INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID 
																											Where	 (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) and Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																															'And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) and Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																														')																										
																											) T
																									WHERE	1=1  and ' + @Emp_Search	
																		--print @SqlQuery
																	END															
														END												
												------------Ended-----------------
									    ELSE IF @is_rpt_manager = 0 AND @is_branch_manager = 0 and @is_Reporting_To_Reporting_manager = 0
											BEGIN

											
											
												INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ES.Emp_ID FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
												INNER JOIN
													(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														WHERE Effective_Date<=GETDATE() AND TYPE='Probation' GROUP BY emp_ID
													) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Probation'
														WHERE ES.Scheme_Id = @Scheme_ID 
														--select * from #Emp_Cons
											 	IF @Rpt_level = 1
													BEGIN
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation''  AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))  AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'
															+ ' And ' + @Emp_Search	  
														 
													END
												ELSE
													BEGIN
														SET @SqlQuery = 	
														'Select LAD.Emp_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_EMP_PROBATION_GET LAD
															Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Emp_ID Not In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' 
															   AND Probation_Evaluation_ID = CAST(0 AS Varchar(2))
															   AND Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
															   And LAD.Emp_ID In (Select Emp_ID From T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) Where Flag = ''Probation'' AND Probation_Evaluation_ID = CAST(0 AS Varchar(2)) AND Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															  )' + ' And ' + @Emp_Search
																  
															
													END
													
											END	
										

										INSERT INTO #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										EXEC (@SqlQuery)
										

										DROP TABLE #Emp_Cons
										
									  FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@Is_PRM,@is_Reporting_To_Reporting_manager
									END
								CLOSE cur_Scheme_Leave
								DEALLOCATE cur_Scheme_Leave
					
								SET @Rpt_level = @Rpt_level + 1
							END
						
					END
				
				--select * from #tbl_Leave_App -- where Leave_App_ID = 398
				--select * from #tbl_Scheme_Leave 
				--delete from #tbl_Scheme_Leave where Scheme_ID = 26 and rpt_level = 1 
				
				--select * from V0080_EMP_PROBATION_GET where Emp_ID = 398
				--select * FROM V0080_EMP_PROBATION_GET where Cmp_ID=120
				--select * from T0115_EMP_PROBATION_MASTER_LEVEL where Cmp_id=120		
				--select * from #tbl_Leave_App

				IF @Emp_ID_Cur > 0
					BEGIN

					 	INSERT INTO #Trainee
						SELECT DISTINCT	
							LAD.Cmp_ID,LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Alpha_Emp_code, LAD.Emp_first_name, LAD.Branch_Name, LAD.Branch_ID,
							LAD.Date_Of_Join,--LAD.probation_date,
							--CASE WHEN ISNULL(Qry1.probation_date,'') = '' THEN LAD.probation_date ELSE Qry1.probation_date END,
							cast('1900-01-01' as datetime) AS Probation_Date,
							SL.Final_Approver,ISNULL(Qry1.rpt_level + 1,'1') AS Rpt_Level, TLAP.Scheme_ID,SL.Is_Fwd_Leave_Rej , LAD.Desig_Id,
							LAD.Probation AS Completed_Month,LAD.Probation_Review AS Review_Type,LAD.Is_Probation_Month_Days
							,ISNULL(LAD.Approval_Period_Type,''),LAD.Dept_ID
						FROM V0080_EMP_PROBATION_GET LAD 
							LEFT OUTER JOIN 
								( SELECT lla.Emp_id AS Emp_id, Rpt_Level AS Rpt_Level , lla.New_Probation_EndDate AS probation_date ,Probation_Evaluation_ID,S_Emp_ID,[Status] 
									FROM T0115_EMP_PROBATION_MASTER_LEVEL lla WITH (NOLOCK)
										INNER JOIN 
											( SELECT MAX(rpt_level) AS rpt_level1, Emp_id FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) 
												where T0115_EMP_PROBATION_MASTER_LEVEL.Emp_id in (SELECT Leave_App_ID FROM #tbl_Leave_App)
												and Flag = 'Probation'  AND Probation_Evaluation_ID = 0
												GROUP BY Emp_id 
										) Qry ON qry.Emp_id = lla.Emp_id AND qry.rpt_level1 = lla.rpt_level AND Flag = 'Probation'
									--WHERE lla.New_Probation_EndDate NOT IN ( SELECT New_Probation_EndDate FROM T0095_EMP_PROBATION_MASTER A WHERE lla.Emp_id = A.Emp_ID )	--Added For EXISTS 
									--WHERE Probation_Evaluation_ID = 0 --NOT EXISTS ( SELECT New_Probation_EndDate FROM T0095_EMP_PROBATION_MASTER A WHERE A.Flag = 'Probation' and lla.Emp_id = A.Emp_ID AND A.New_Probation_EndDate = lla.New_Probation_EndDate )	
								) AS Qry1 ON  LAD.Emp_id = Qry1.Emp_id AND Qry1.Probation_Evaluation_ID = 0	 -- This join is for getting updated from date,to date and leave period in case if any middle approver change it, then next should be see updated info and not old one 
							INNER JOIN #tbl_Leave_App TLAP  ON TLAP.Leave_App_ID = LAD.Emp_id 
							INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID 
							AND SL.Leave = TLAP.Leave 
							AND  SL.rpt_level > ISNULL(Qry1.Rpt_Level,0) 
							AND  SL.rpt_level = TLAP.rpt_level
							INNER JOIN (SELECT Leave_App_ID FROM #tbl_Leave_App) qry ON lad.Emp_id=qry.Leave_App_ID	
						WHERE ISNULL(LAD.Emp_Left,'N') <> 'Y' 
						--and LAD.Cmp_ID=@cmp_id 
					END
					

				DELETE #tbl_Scheme_Leave
				DELETE #tbl_Leave_App
				
			  FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
			END
		CLOSE Employee_Cur
		DEALLOCATE Employee_Cur
		--select * from #Trainee
		--ADDED BY MUKTI(START)06122017
		--DECLARE @Is_Month_Days AS TINYINT
		--SELECT Emp_ID,Completed_Month,Date_Of_Join,Review_Type,Is_Probation_Month_Days FROM #Trainee where emp_id=22744
		DECLARE PROBATION_TRAINEE_DETAILS CURSOR FOR
				   SELECT Emp_ID,Completed_Month,Date_Of_Join,Review_Type,Is_Probation_Month_Days FROM #Trainee --where emp_id=22744
			OPEN PROBATION_TRAINEE_DETAILS
			FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Is_Probation_Month_Days
			while @@fetch_status = 0
				BEGIN
					set @Extend_Period = 0	
					set @Review_Total_month =0	
						
					SELECT	@Extend_Period=ISNULL(Extend_Period,0),@New_Probation_EndDate=New_Probation_EndDate,@Maxflag=EM.Flag	
					FROM dbo.T0095_EMP_PROBATION_MASTER EM WITH (NOLOCK)
					inner join 
						(SELECT MAX(Probation_Evaluation_ID) AS Probation_Evaluation_Id FROM  dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
						        WHERE Emp_ID = @Emp_ID GROUP BY Emp_ID)as qry on EM.Probation_Evaluation_ID=qry.Probation_Evaluation_Id --Flag = @flag and 
					WHERE  Emp_ID = @Emp_ID  --and Flag = @flag  
					--select @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Extend_Period,@New_Probation_EndDate
					IF @Review_Type = 'Quarterly'
						set @month = 3
					else if @Review_Type = 'Six Monthly'
						set @month = 6
						 	
					 IF (@Extend_Period > 0) --and @Maxflag = 'Probation'
						BEGIN							
							update #Trainee set Probation_Date=@New_Probation_EndDate,Review_Type='Final' where Emp_ID=@Emp_ID
						END
					--else IF (@Extend_Period > 0 and @Maxflag <> 'Probation')
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
											--PRINT @FinalExtend_Probation_EndDate
											
									SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
									where Emp_ID=@Emp_ID and Flag = 'Probation' 
									
									IF @ctr_Trainee_probation > 0	
										BEGIN	
										
											SELECT @New_Probation_EndDate=New_Probation_EndDate FROM dbo.T0095_EMP_PROBATION_MASTER  WITH (NOLOCK)
											WHERE  Emp_ID = @Emp_ID and Flag='Probation' 																			
											SET @Review_Total_month=(@month + (@ctr_Trainee_probation * @month))
										END
											
									SET @Review_month= @month		
									SET @new_Probation_date=DATEADD(dd, - 1, DATEADD(mm, @Review_month, ISNULL(@New_Probation_EndDate,@Date_Of_Join)))
									--select @New_Probation_EndDate,@FinalExtend_Probation_EndDate,@new_Probation_date,@Review_month,@Review_Total_month,@Completed_Month,@ctr_Trainee_probation,@Emp_ID
									if @FinalExtend_Probation_EndDate < @new_Probation_date									
										update #Trainee set Review_Type='Final',Probation_Date= @FinalExtend_Probation_EndDate where Emp_ID=@Emp_ID
									ELSE	
										update #Trainee set Probation_Date= @new_Probation_date where Emp_ID=@Emp_ID
								END							
							ELSE									
								BEGIN				
									IF @Review_Type <> ''
										BEGIN
										
											SELECT @ctr_Trainee_probation=count(Probation_Evaluation_ID) from T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
											where Emp_ID=@Emp_ID and Flag = 'Probation' 
											
											IF @Is_Probation_Month_Days=0	--for Month Completion Period	
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
											IF @Is_Probation_Month_Days=0
												update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(mm,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID											
											ELSE
												update #Trainee set Probation_Date=DATEADD(dd, - 1, DATEADD(DAY,@Completed_Month,@Date_Of_Join)),Review_Type='Final' where Emp_ID=@Emp_ID											
										END
								END
						END					
				--END
				FETCH NEXT FROM PROBATION_TRAINEE_DETAILS into @Emp_ID,@Completed_Month,@Date_Of_Join,@Review_Type,@Is_Probation_Month_Days
			End
		close PROBATION_TRAINEE_DETAILS 
		deallocate PROBATION_TRAINEE_DETAILS		
		
		--ADDED BY MUKTI(END)06122017		
		--SELECT * FROM #Trainee
		DECLARE @queryExe AS NVARCHAR(1000)
		IF @Type = 0
			BEGIN				
				--IF @Emp_ID_Cur > 0
				--	BEGIN
				--		--SELECT * FROM #Trainee ORDER BY #Trainee.Probation_Date DESC
				--		SET @queryExe = 'select * from #Trainee where ' + @Constrains +' and '+ @Emp_Search + ' order by #Trainee.Probation_Date desc '
				--		print @queryExe
				--		EXEC (@queryExe)
				--	END
				--ELSE
				--	BEGIN
						SET @queryExe = 'select * from #Trainee where ' + @Constrains +' and '+ @Emp_Search + ' order by #Trainee.Probation_Date desc '
						--print @queryExe
						EXEC (@queryExe)
					--END
			END
		ELSE IF @Type = 1
			BEGIN
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(1) FROM #Trainee where Approval_Period_Type <> 'Confirm' 
					END
				ELSE
					SELECT COUNT(1) AS Pro_OverCnt FROM #Trainee where Approval_Period_Type <> 'Confirm' 
				
			END
		
		DROP TABLE #tbl_Scheme_Leave
		DROP TABLE #tbl_Leave_App
		DROP TABLE #Responsiblity_Passed
		DROP TABLE #Trainee
	
END


