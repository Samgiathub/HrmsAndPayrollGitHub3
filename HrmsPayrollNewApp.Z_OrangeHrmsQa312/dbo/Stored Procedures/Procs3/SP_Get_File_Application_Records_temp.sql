


CREATE PROCEDURE [dbo].[SP_Get_File_Application_Records_temp]
	@Cmp_ID		NUMERIC(18,0),
	@Emp_ID		NUMERIC(18,0),
	@Rpt_level	NUMERIC(18,0),
	@Constrains NVARCHAR(MAX),
	@Type		NUMERIC(18,0)= 0
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	DECLARE @Scheme_ID AS NUMERIC(18,0)
	DECLARE @Leave AS VARCHAR(100)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager AS TINYINT
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT
	 
	DECLARE @SqlQuery AS NVARCHAR(MAX)
	DECLARE @SqlExcu AS NVARCHAR(MAX)
	DECLARE @MaxLevel AS NUMERIC(18,0)
	DECLARE @Rpt_level_Minus_1 AS NUMERIC(18,0)
	
	DECLARE @Emp_ID_Cur		NUMERIC(18,0)
	DECLARE @is_res_passed	TINYINT
	
	SET @Emp_ID_Cur = 0
	SET @is_res_passed = 0
	SET @is_rpt_manager = 0
	SET @is_branch_manager = 0
	SET @SqlExcu = '' 
	 
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type ='File Management'

	CREATE TABLE #Responsiblity_Passed
	 (		 
	     Emp_ID	NUMERIC(18,0)	
	    ,is_res_passed TINYINT DEFAULT 1  
	 )  
	 
	CREATE TABLE #tbl_Scheme_Leave 
	 (
		Scheme_ID			NUMERIC(18,0)
	   ,Leave				VARCHAR(100) 
	   ,Final_Approver		TINYINT
	   ,Is_Fwd_Leave_Rej	TINYINT
	   ,is_rpt_manager		TINYINT NOT NULL DEFAULT 0
	   ,is_branch_manager	TINYINT NOT NULL DEFAULT 0
	   ,rpt_level			NUMERIC(18,0)
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0
	 )  
	
	CREATE TABLE #tbl_Leave_App
	 (
		Leave_App_ID	NUMERIC(18,0)
	   ,Scheme_ID		NUMERIC(18,0)
	   ,Leave			VARCHAR(100) 
	   ,rpt_level		NUMERIC(18,0)
	 )
	 
CREATE TABLE #File
	(
		 Cmp_ID					NUMERIC(18,0)						
		,Emp_ID					NUMERIC(18,0)					
		,File_App_Id		    NUMERIC(18,0)							
		,Alpha_Emp_code			NVARCHAR(100)				
		,Emp_first_name			NVARCHAR(200)				
		,Emp_Full_Name			NVARCHAR(200)					
		,S_Emp_Id				numeric(18, 0)						
		,Application_Date		VARCHAR(10) --DATETIME				
		,File_Number			varchar(50)								
		,F_StatusId				int									
		,F_TypeId				numeric(18, 0)						
		,Subject				varchar(500)					
		,Description			varchar(MAX)						
		,Process_Date			VARCHAR(10)--DATETIME					
		,File_App_Doc			varchar(MAX)							
		,[User ID]				varchar(MAX)							
		,Branch_id				NUMERIC(18,0) 								
		,Branch_Name			NVARCHAR(100)								
		,Final_Approver			TINYINT										
		,Rpt_Level				NUMERIC(18,0)										
		,Scheme_ID				NUMERIC(18,0)									
		,Is_Fwd_Leave_Rej		TINYINT											
		,Emp_Remarks			NVARCHAR(500)							
		,Forward_Emp_Id			numeric(18, 0)								
		,Submit_Emp_Id			numeric(18, 0)										
		,Status					NVARCHAR(100)								
		,Tran_ID				numeric(22,0)--added
		,Forward_Employee		nvarchar(50)--added 1 st july
		,updatedbyEmp		   NUMERIC(18,0)		--added 5 st july
	)

	 
	 INSERT INTO #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 INSERT INTO #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK)
	 WHERE pass_to_emp_id = @Emp_ID AND  GETDATE() >= from_date AND GETDATE() <= to_date  and Type='File Management'   --Change by Jaina 14-03-2017
				
		
		
	IF @Rpt_level > 0
		BEGIN
			SET @MaxLevel = @Rpt_level
		END
	ELSE
		BEGIN
			SET @Rpt_level = 1
		END
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		--print @Type
	IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'File Management')
		BEGIN
			IF @Type = 0
				BEGIN
					SELECT * FROM #File
				END
			ELSE IF @Type = 1
				BEGIN
					IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
						BEGIN
							TRUNCATE TABLE #Notification_Value
							INSERT INTO #Notification_Value
							SELECT COUNT(1) AS File_App FROM #File 
						   select * from	#Notification_Value
						END
					ELSE
						SELECT COUNT(1) AS File_App FROM #File 
				END	
					
			RETURN
		END
			
		
		------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		DECLARE @string_1	VARCHAR(MAX)
 		SET @String = ''
 		SET @Emp_Cmp_Id = ''
 		SET @string_1 = ''
 		
 		
 		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 			( SELECT MAX(Effect_Date) AS Effect_Date,Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) 
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
 																	WHERE R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed)/*@Emp_ID*/) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed)--@Emp_ID 
		FOR XML PATH (''))
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			END	
		
		IF @Emp_Cmp_Id =''
			SET @Emp_Cmp_Id = NULL
		----

		
		
		DECLARE Employee_Cur CURSOR
			FOR SELECT DISTINCT Emp_ID,is_res_passed FROM #Responsiblity_Passed
		OPEN Employee_Cur
		FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
				
		
				IF @Emp_ID_Cur > 0
					BEGIN
				 	 
	 	 				DECLARE @Manager_Branch NUMERIC(18,0)
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
								IF @Emp_ID_Cur > 0
									BEGIN
									--print 'ab'
										INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE App_Emp_Id = @Emp_ID_Cur AND rpt_level = @Rpt_level AND SM.Scheme_Type = 'File Management'
									
										
										
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
											BEGIN
												
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
 																Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
																And T0040_Scheme_Master.Scheme_Type = ''File Management'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
												
												--print @string_1
												EXEC (@string_1)												
												
											END
										--Added By Jimit 19122017										
										Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
												BEGIN
													 
													 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
 																Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
																And T0040_Scheme_Master.Scheme_Type = ''File Management''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' Commented By Jimit as Cross Company Manager Login not showing application done by cross compny's Employee due to Scheme Id is not passing in the RM to RM's Sp (Dishman case)
													
													  EXEC (@string_1)
														
												END
								
										IF @Manager_Branch > 0 
											BEGIN
												INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Is_RMToRM)
												SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Is_RMToRM
												FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
												WHERE rpt_level = @Rpt_level AND Is_BM = 1 AND SM.Scheme_Type = 'File Management'
										
											END
								
									END
								ELSE
									BEGIN
										INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM 
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE SM.Scheme_Type = 'File Management'
									END
								
								
								
								DECLARE @rpt_levle_cur TINYINT
								SET @rpt_levle_cur = 0
				
								DECLARE Final_Approver CURSOR
									FOR SELECT DISTINCT Scheme_Id, Leave,rpt_level 
									FROM #tbl_Scheme_Leave 
								OPEN Final_Approver
								FETCH NEXT FROM Final_Approver INTO @Scheme_ID, @Leave,@rpt_levle_cur
								WHILE @@FETCH_STATUS = 0
									BEGIN
									 	IF EXISTS (SELECT Scheme_Detail_ID FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave AND Rpt_Level = @Rpt_level + 1 AND NOT_MANDATORY = 0)
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
					
								
								
								DECLARE cur_Scheme_Leave CURSOR FOR 
									SELECT Scheme_Id, Leave,is_rpt_manager,is_branch_manager,Is_RMToRM FROM #tbl_Scheme_Leave WHERE rpt_level = @Rpt_level
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
												SELECT ES.Emp_ID 
												FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
													INNER JOIN
														( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														  WHERE Effective_Date<=GETDATE() AND TYPE='File Management' GROUP BY emp_ID
														 ) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='File Management'
													INNER JOIN 
													( SELECT Branch_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
													   ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)   
															WHERE Increment_Effective_date <= GETDATE() /*AND Cmp_ID = @Cmp_ID */
															GROUP BY emp_ID
														) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID 
													) AS INC ON INC.Emp_ID = Qry.Emp_ID
												WHERE ES.Scheme_Id = @Scheme_ID AND INC.Branch_ID = @Manager_Branch
												
												
												IF @Rpt_level = 1
													BEGIN														
														SET @SqlQuery = 	
														'Select LAD.File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_File_App_Admin_Side LAD
														 INNER JOIN #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where 
														 LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
														  And ' + @Constrains	  
														 
													END
												ELSE
													BEGIN
												
														SET @SqlQuery = 
														'Select LAD.File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_File_App_Admin_Side LAD
															INNER JOIN #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																And LAD.File_App_Id In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															) And  ' + @Constrains
														
																 
													END
																																	
											END
										ELSE IF @is_rpt_manager = 1
											BEGIN

										 		INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ERD.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN 
													( SELECT MAX(Effect_Date) AS Effect_Date, Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
													  WHERE Effect_Date<=GETDATE() GROUP BY emp_ID
													) RQry ON  ERD.Emp_ID = RQry.Emp_ID AND ERD.Effect_Date = RQry.Effect_Date
													INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) ON ES.Emp_ID = ERD.Emp_ID 
													INNER JOIN
													( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
													  WHERE Effective_Date<=GETDATE() AND TYPE='File Management' GROUP BY emp_ID
													 ) Qry ON  ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='File Management'
													WHERE R_emp_id = @Emp_ID_Cur or ES.Scheme_ID = @Scheme_ID  
												--WHERE R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
										

												DELETE FROM #Emp_Cons 
												WHERE Emp_ID NOT IN (
													SELECT ERD.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN 
														( SELECT MAX(Effect_Date) AS Effect_Date,ERD1.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN #Emp_Cons EC1 ON EC1.Emp_ID = ERD1.Emp_ID 
															WHERE Effect_Date<=GETDATE() GROUP BY ERD1.emp_ID
														) RQry ON  ERD.Emp_ID = RQry.Emp_ID AND ERD.Effect_Date = RQry.Effect_Date AND R_emp_id = @Emp_ID_Cur
													INNER JOIN #Emp_Cons EC ON EC.Emp_ID = RQry.Emp_ID 
												)

												
													--print @Rpt_level
												IF @Rpt_level = 1
													BEGIN				
														SET @SqlQuery =  'Select File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																			FROM	(SELECT LAD.File_App_Id,ISNULL(LA.F_StatusId,LAD.F_StatusId) As F_StatusId,Emp_First_Name,alpha_emp_Code
																					From	V0080_File_App_Admin_Side LAD Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																							LEFT OUTER JOIN (SELECT File_App_Id,Emp_ID,S_Emp_ID,F_StatusId As F_StatusId FROM T0115_File_Level_Approval LA WITH (NOLOCK) WHERE Rpt_Level=' + CAST(@Rpt_level AS VARCHAR(2)) + ') LA ON LAD.EMP_ID=LA.S_EMP_ID And LAD.File_App_Id=LA.File_App_Id
																					Where	LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																					) T
																			WHERE	1=1 And ' + @Constrains	 
														--print (@SqlQuery)
													END
												ELSE
													BEGIN
														SET @SqlQuery = 	
														'Select LAD.File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_File_App_Admin_Side LAD
															INNER JOIN #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where ( LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																And LAD.File_App_Id In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															   )'  + ' And ' + @Constrains
													END
												
											END
											
										-----------Added By Jimit 16122017-----------------
										ELSE IF @is_Reporting_To_Reporting_manager = 1 and @Rpt_level = 2
											BEGIN
												
												
										IF @Rpt_level = 2
											BEGIN
															
												
												
												IF Object_ID('tempdb..#EMP_CONS_RM') IS NOT NULL
													DROP TABLE #EMP_CONS_RM
													--BEGIN	
														
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
														--print @scheme_id
														EXEC SP_RPT_FILL_EMP_CONS_WITH_REPORTING	@Cmp_ID=@Cmp_ID,@From_Date=@date,@To_Date=@date,@Branch_ID=0,
																									@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID = @Emp_ID_Cur,@Constraint='',@Sal_Type = 0,
																									@Salary_Cycle_id = 0,@Segment_Id = 0,@Vertical_Id = 0,@SubVertical_Id = 0,@SubBranch_Id= 0,
																									@New_Join_emp = 0,@Left_Emp = 0,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc	= 0,@Type = 0 ,
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'File Management' 										
														
													--END
												
												--SELECT	top 1 @Rpt_level,*												
												--FROM	(SELECT LAD.APP_ID,ISNULL(LA.App_Status,LAD.App_Status) As App_Status
												--From	V0100_GATE_PASS_APPLICATION LAD INNER JOIN 
												--		#EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID LEFT OUTER JOIN
												--		 (
												--			SELECT  App_ID,Emp_ID,S_Emp_ID,Apr_Status As App_Status 
												--			FROM	T0115_GATE_PASS_LEVEL_APPROVAL LA 
												--			WHERE	S_Emp_ID = @Emp_ID 
												--		 ) LA ON LAD.App_ID=LA.App_ID And LAD.EMP_ID=LA.S_EMP_ID
												--Where	(
												--			LAD.APP_ID Not In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where Rpt_Level = @Rpt_level) And 
												--			LAD.APP_ID In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where  Rpt_Level = @Rpt_level_Minus_1)
														
												--) T
												--WHERE T.App_Status = 'P'
												
												-- pending from below mansi
														
												SET @SqlQuery =	   'Select  File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																	FROM	(SELECT LAD.File_App_Id,ISNULL(LA.F_StatusId,LAD.F_StatusId) As F_StatusId,Emp_First_Name,alpha_emp_Code
																			From	V0080_File_App_Admin_Side LAD 
																					INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																					LEFT OUTER JOIN (SELECT File_App_Id,Emp_ID,S_Emp_ID,F_StatusId As F_StatusId FROM T0115_File_Level_Approval LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																										ON LAD.File_App_Id=LA.File_App_Id And LAD.EMP_ID=LA.EMP_ID
																			Where	(LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																						'And LAD.File_App_Id In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																					')
																					AND NOT EXISTS(SELECT 1 FROM #tbl_Leave_App T WHERE T.Leave_App_ID=LAD.File_App_Id)
																			) T
																	WHERE	1=1  and ' + @Constrains	  	
													
												
													
												--SET @SqlQuery =	'Select top 1 LAD.APP_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
												--		'From V0100_GATE_PASS_APPLICATION LAD
												--			INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID
												--		 Where ( LAD.APP_ID Not In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
												--					And LAD.APP_ID In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
												--			    )' + ' And ' + @Constrains
													
													
													
															--SELECT @RPT_LEVEL, * FROM #EMP_CONS_RM						
												--SET @SqlQuery = 'Select LAD.APP_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
												--				'From	V0100_GATE_PASS_APPLICATION LAD
												--						INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID
												--				Where	(LAD.APP_ID Not In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')
												--						And LAD.APP_ID In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where  Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
												--						)' + ' And ' + @Constrains
																								
													
												
											END
													
												
										END
										------------------ended----------------------------
														
										ELSE IF @is_rpt_manager = 0 AND @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
											BEGIN
											
												INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ES.Emp_ID 
												FROM T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
													( SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Effective_Date<=GETDATE() AND TYPE='File Management' GROUP BY emp_ID
													) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='File Management'
												WHERE ES.Scheme_Id = @Scheme_ID 
												
													
											 		--print @rpt_level	
												IF @Rpt_level = 1
													BEGIN
														SET @SqlQuery =
														'Select LAD.File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_File_App_Admin_Side LAD
															INNER JOIN #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'
															+ ' And ' + @Constrains	  
														 
													END
												ELSE
													BEGIN
														
														SET @SqlQuery = 	
														'Select LAD.File_App_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														'From V0080_File_App_Admin_Side LAD
															INNER JOIN #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														 Where ( LAD.File_App_Id Not In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
																	And LAD.File_App_Id In (Select File_App_Id From T0115_File_Level_Approval WITH (NOLOCK) Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															    )' + ' And ' + @Constrains
													END
												
											END
										 

										
										INSERT INTO #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										EXEC (@SqlQuery)
										--select * from #Emp_Cons--mansi
										--select * from #EMP_CONS_RM
										--print @SqlQuery
										--if exists(select 1 from #tbl_Leave_App)
										--	Select APP_ID, 544 As Scheme_ID, '0' As Leave , 2, App_Status,Apr_Status,Emp_ID
										--	FROM	(SELECT LAD.APP_ID,ISNULL(LA.App_Status,LAD.App_Status) As App_Status, LA.App_Status As Apr_Status, lad.Emp_ID
										--			From	V0100_GATE_PASS_APPLICATION LAD 
										--					INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID
										--					LEFT OUTER JOIN (SELECT App_ID,Emp_ID,S_Emp_ID,Apr_Status As App_Status 
										--									FROM T0115_GATE_PASS_LEVEL_APPROVAL LA 
										--									where	Rpt_Level <= 2) LA ON LAD.App_ID=LA.App_ID
										--			Where	(LAD.APP_ID Not In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where Rpt_Level = 2)
										--						And LAD.APP_ID In (Select APP_ID From T0115_GATE_PASS_LEVEL_APPROVAL Where  Rpt_Level = 1)
										--					)
										--			) T
										--	WHERE	1=1 And 0=0 And App_Status = 'P'
										
								
							
										DROP TABLE #Emp_Cons
										FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
									END
								CLOSE cur_Scheme_Leave
								DEALLOCATE cur_Scheme_Leave
					
						
								SET @Rpt_level = @Rpt_level + 1
							END

							
					END 
			
			
			--select * from #tbl_Scheme_Leave
				IF @Emp_ID_Cur > 0
					BEGIN
					--select * from #tbl_Scheme_Leave
					
						INSERT INTO #File
						select distinct * from (
						SELECT DISTINCT	
							 LAD.Cmp_ID,LAD.Emp_ID,LAD.File_App_Id as App_ID ,LAD.Alpha_Emp_code,LAD.Emp_first_name, LAD.Emp_Full_Name,
							 lad.S_Emp_Id,lad.Application_Date  ,lad.File_Number,
							 lad.F_StatusId,
							 lad.F_TypeId,
							 isnull(lad.Subject,'')as Subject,isnull(lad.Description,'') as Description,
							 lad.Process_Date  ,stuff(file_App_Doc, 1, charindex('#', file_App_Doc), '') as File_App_Doc--added 27-04-22
							 --isnull(right(File_App_Doc, len(File_App_Doc) - 17),'')as File_App_Doc--added 20-04-22
							 --isnull(lad.File_App_Doc,'')as File_App_Doc-commented 20-04-22
							 ,lad.[User ID],lad.Branch_id,lad.Branch_Name,
							 SL.Final_Approver,ISNULL(Qry1.rpt_level + 1,'0') AS Rpt_Level
							 --(case when lad.F_StatusId=3 then Qry2.rpt_level else ISNULL(Qry1.rpt_level + 1,'0') end)AS Rpt_Level
							 --ISNULL(Qry1.rpt_level + 1,'1') AS Rpt_Level
							 , TLAP.Scheme_ID,SL.Is_Fwd_Leave_Rej
							 --,LAD.Remarks
							  ,'' as Emp_Remarks,0 as Forward_Emp_Id,0 as Submit_Emp_Id
							 ,fsc.S_Name
							 ,0 as Tran_ID--added
							 ,'' as Forward_Employee--added 1 st july
							  ,0 as updatedbyEmp--added 5 th july
							 --,(case when File_Apr_Id<>0 then fapc.S_Name else fsc.S_Name end)
						FROM V0080_File_App_Admin_Side LAD
						left join T0030_File_Status_Common as fsc on fsc.S_ID = lad.F_StatusId
							LEFT OUTER JOIN (Select  lla.File_App_Id AS App_ID, MAX(rpt_level) AS rpt_level,lla.F_StatusId												
												FROM T0115_File_Level_Approval lla WITH (NOLOCK) 
												group by File_App_Id,F_StatusId
												) AS Qry1 ON  LAD.File_App_Id = Qry1.App_ID	-- This join is for getting updated from date,to date and leave period in case if any middle approver change it, then next should be see updated info and not old one 

							inner JOIN #tbl_Leave_App TLAP ON TLAP.Leave_App_ID = LAD.File_App_Id 
							INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID AND SL.Leave = TLAP.Leave AND  SL.rpt_level > ISNULL(Qry1.Rpt_Level,0) AND  SL.rpt_level = TLAP.rpt_level 
							inner JOIN (SELECT Leave_App_ID FROM #tbl_Leave_App) qry ON lad.File_App_Id=qry.Leave_App_ID		
				 			where (ISNULL(Qry1.rpt_level + 1,'0')=0 or (ISNULL(Qry1.rpt_level + 1,'0'))>(select isnull(max(rpt_level),0) from T0115_File_Level_Approval where File_App_Id=LAD.File_App_Id))
					union 
					SELECT DISTINCT	
							 LAD.Cmp_ID,LAD.Emp_ID,LAD.File_App_Id as App_ID ,LAD.Alpha_Emp_code,LAD.Emp_first_name, LAD.Emp_Full_Name,
							 flfw.S_Emp_Id,lad.Application_Date  ,lad.File_Number,
							 flfw.F_StatusId,
							 flfw.F_TypeId,
							 isnull(flfw.Subject,'')as Subject,isnull(flfw.Description,'') as Description,
							 lad.Process_Date  ,
							 stuff(flfw.file_App_Doc, 1, charindex('#', flfw.file_App_Doc), '') as File_App_Doc--added 27-04-22
							 --isnull(right(File_App_Doc, len(File_App_Doc) - 17),'')as File_App_Doc--added 20-04-22
							 --isnull(lad.File_App_Doc,'')as File_App_Doc-commented 20-04-22
							 ,flfw.[User ID],lad.Branch_id,lad.Branch_Name,
							 --Sm.Final_Approver,--ISNULL(Qry1.rpt_level + 1,'0') AS Rpt_Level
							 0 as Final_Approver,
							 ISNULL(flfw.Rpt_Level,0)as Rpt_Level
							-- (case when lad.F_StatusId=3 then Qry2.rpt_level else ISNULL(Qry1.rpt_level + 1,'0') end)AS Rpt_Level
							 --ISNULL(Qry1.rpt_level + 1,'1') AS Rpt_Level
							 , sm.Scheme_ID,0 as Is_Fwd_Leave_Rej
							 --,LAD.Remarks
							  ,isnull(flfw.Approval_Comments,'') as Emp_Remarks,flfw.Forward_Emp_Id as Forward_Emp_Id
							  ,flfw.Submit_Emp_Id as Submit_Emp_Id
							 ,fsc.S_Name
							 ,flfw.Tran_Id as Tran_ID--added
							 ,em.Emp_Full_Name as Forward_Employee--added 1 st july
							   ,isnull(lg.Emp_ID,0) as updatedbyEmp--added 5 th july
							 --,(case when File_Apr_Id<>0 then fapc.S_Name else fsc.S_Name end)
						FROM V0080_File_App_Admin_Side LAD
						inner join T0030_File_Status_Common as fsc on fsc.S_ID = lad.F_StatusId	
						inner join T0095_EMP_SCHEME as sm on sm.Emp_ID = lad.Emp_ID and type='File Management'
						LEFT OUTER JOIN (Select  lla.File_App_Id AS App_ID, MAX(rpt_level) AS rpt_level--,lla.F_StatusId												
												FROM T0115_File_Level_Approval lla WITH (NOLOCK) 
													--where lla.File_App_Id=177
												group by File_App_Id--,F_StatusId 
											
												) AS Qry2 ON  LAD.File_App_Id = Qry2.App_ID	
						inner join T0115_File_Level_Approval fla on fla.File_App_Id=qry2.App_ID and qry2.rpt_level=fla.Rpt_Level
						inner join T0115_File_Level_Approval_Forward as flfw on flfw.File_App_Id = lad.File_App_Id  --and flfw.F_StatusId=qry2.F_StatusId and flfw.Rpt_Level=(qry2.rpt_level)
						inner join T0011_LOGIN lg on lg.Login_ID=flfw.[User ID]
						inner join T0080_EMP_MASTER em on em.Emp_ID=flfw.Forward_Emp_Id
						where qry2.rpt_level=flfw.Rpt_Level and
						 fla.F_StatusId=flfw.F_StatusId 
					    --INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = flfw.Scheme_ID AND  SL.rpt_level = TLAP.rpt_level 
						
						--innER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = sm.Scheme_ID --AND SL.Leave = TLAP.Leave AND  SL.rpt_level > ISNULL(Qry1.Rpt_Level,0) AND  SL.rpt_level = TLAP.rpt_level 
						)as T
					   
					END
				
						
				DELETE #tbl_Scheme_Leave
				DELETE #tbl_Leave_App
				
			
				FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
			END 
		CLOSE Employee_Cur
		DEALLOCATE Employee_Cur
		
		declare @sqlqr as varchar(max)

		IF @Type = 0
			BEGIN
				--print 1
				IF @Emp_ID_Cur > 0
					BEGIN
					
						SELECT 0 AS FA_Id,* FROM #File 
						ORDER BY #File.File_App_Id DESC 
                          -- select * from #tbl_Leave_App
							
	
					END
				ELSE
					BEGIN
				
						DECLARE @queryExe AS NVARCHAR(1000)
						SET @queryExe = 'select 0 AS FA_Id,* from #File where ' + @Constrains + ' order by #File.File_App_Id'
						
						EXEC (@queryExe)
					END
			END
		ELSE IF @Type = 1
			BEGIN

				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN

						TRUNCATE TABLE #Notification_Value 
									
						set @sqlqr='INSERT INTO #Notification_Value
						Select COUNT(1) AS File_App from(select * from #file where '+ @Constrains+ ')as T'
						 --print @sqlqr
				 exec(@sqlqr)
						--SELECT COUNT(1) AS File_App FROM #File
					END
				ELSE
				
				  set @sqlqr='Select COUNT(1) AS File_App from(select * from #file where '+ @Constrains+ ')as T'
				-- print @sqlqr
				 exec(@sqlqr)
					--SELECT COUNT(1) AS File_App FROM #File 
				
			END				
		
		DROP TABLE #tbl_Scheme_Leave
		DROP TABLE #tbl_Leave_App
		DROP TABLE #Responsiblity_Passed
		DROP TABLE #File
	
END


