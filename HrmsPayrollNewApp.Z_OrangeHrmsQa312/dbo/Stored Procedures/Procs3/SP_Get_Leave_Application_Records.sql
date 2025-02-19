
CREATE PROCEDURE [dbo].[SP_Get_Leave_Application_Records] 
	@Cmp_ID NUMERIC(18, 0)
	,@Emp_ID NUMERIC(18, 0)
	,@Rpt_level NUMERIC(18, 0)
	,@Constrains NVARCHAR(max)
	,@Type NUMERIC(18, 0) = 0
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	--select @Constrains return
	DECLARE @Scheme_ID AS NUMERIC(18, 0)
	DECLARE @Leave AS VARCHAR(max)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager AS TINYINT
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 05012018
	DECLARE @SqlQuery AS NVARCHAR(max)
	DECLARE @SqlExcu AS NVARCHAR(max)
	DECLARE @MaxLevel AS NUMERIC(18, 0)
	DECLARE @Rpt_level_Minus_1 AS NUMERIC(18, 0)

	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level), 1)
	FROM T0050_Scheme_Detail SD WITH (NOLOCK)
	INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
	WHERE SM.Scheme_Type = 'Leave'

	SET @is_rpt_manager = 0
	SET @is_branch_manager = 0
	SET @SqlExcu = ''

	CREATE TABLE #Responsiblity_Passed (
		Emp_ID NUMERIC(18, 0)
		,is_res_passed TINYINT DEFAULT 1
		)

	CREATE NONCLUSTERED INDEX Ix_Responsiblity_Passed_Emp_Id_Is_Res_Passed ON #Responsiblity_Passed (
		Emp_ID
		,is_res_passed
		)

	INSERT INTO #Responsiblity_Passed
	SELECT @Emp_ID
		,0

	INSERT INTO #Responsiblity_Passed
	SELECT DISTINCT manger_emp_id
		,1
	FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK)
	WHERE pass_to_emp_id = @Emp_ID
		AND getdate() >= from_date
		AND getdate() <= to_date
		AND Type = 'Leave' --Change by Jaina 14-03-2017
		--select * from #Responsiblity_Passed				

	CREATE TABLE #tbl_Scheme_Leave (
		Scheme_ID NUMERIC(18, 0)
		,Leave VARCHAR(max)
		,Final_Approver TINYINT
		,Is_Fwd_Leave_Rej TINYINT
		,is_rpt_manager TINYINT NOT NULL DEFAULT 0
		,is_branch_manager TINYINT NOT NULL DEFAULT 0
		,rpt_level NUMERIC(18, 0)
		,Max_Leave_Days NUMERIC(18, 2) --Hardik 07/03/2014
		,Is_RMToRM TINYINT NOT NULL DEFAULT 0
		)

	CREATE NONCLUSTERED INDEX Ix_tbl_Scheme_SchemeId ON #tbl_Scheme_Leave (
		Scheme_ID
		,rpt_level
		)

	CREATE TABLE #tbl_Leave_App (
		Leave_App_ID NUMERIC(18, 0)
		,Scheme_ID NUMERIC(18, 0)
		,Leave VARCHAR(500)
		,rpt_level NUMERIC(18, 0)
		)

	CREATE NONCLUSTERED INDEX Ix_tbl_Leave_App_SchemeId ON #tbl_Leave_App (
		Scheme_ID
		,Leave_App_ID
		,Leave
		,rpt_level
		)

	IF @Rpt_level > 0
	BEGIN
		SET @MaxLevel = @Rpt_level
	END
	ELSE
	BEGIN
		SET @Rpt_level = 1
	END

	CREATE TABLE #Leave (
		Row_ID NUMERIC(18, 0)
		,Cmp_ID NUMERIC(18, 0)
		,Leave_ID NUMERIC(18, 0)
		,Emp_ID NUMERIC(18, 0)
		,Emp_Full_Name NVARCHAR(200)
		,Leave_Name NVARCHAR(200)
		,Application_Code NVARCHAR(100)
		,Application_Status NVARCHAR(100)
		,Senior_Employee NVARCHAR(100)
		,Leave_Application_ID NUMERIC(18, 0)
		,Emp_first_name NVARCHAR(200)
		,Emp_Code NVARCHAR(100)
		,Branch_Name NVARCHAR(100)
		,Desig_Name NVARCHAR(100)
		,Alpha_Emp_code NVARCHAR(100)
		--,Leave_Reason			nvarchar(500)
		,Leave_Reason NVARCHAR(max) --Changed by Sumit 
		,Application_Date DATETIME
		,Rpt_Level NUMERIC(18, 0)
		,Scheme_ID NUMERIC(18, 0)
		,Leave NVARCHAR(MAX)
		,Final_Approver TINYINT
		,Is_Fwd_Leave_Rej TINYINT
		,From_Date DATETIME
		,to_date DATETIME
		,Leave_Period NUMERIC(18, 2)
		,is_pass_over TINYINT
		,Actual_leave_id NUMERIC(18, 0)
		,Actual_cancel_wo_ho TINYINT DEFAULT 0
		,Branch_id NUMERIC(18, 0)
		,Is_Backdated_Application VARCHAR(1)
		,Leave_Type VARCHAR(50)
		,Vertical_ID NUMERIC(18, 0) --Added By Jaina 1-10-2015
		,SubVertical_Id NUMERIC(18, 0) --Added By Jaina 1-10-2015
		,Dept_ID NUMERIC(18, 0) --Added By Jaina 1-10-2015
		,Dept_Name NVARCHAR(100)
		,Leave_Application_Status VARCHAR(10) --Mukti(20092017)
		)

	CREATE NONCLUSTERED INDEX Ix_Leave_CmpId_EmpId_SchemeId ON #Leave (
		Cmp_Id
		,Emp_Id
		,Scheme_ID
		,Rpt_Level
		)

	--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
	IF NOT EXISTS (
			SELECT 1
			FROM T0050_Scheme_Detail SD WITH (NOLOCK)
			INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
			WHERE SM.Scheme_Type = 'Leave'
			)
	BEGIN
		IF @Type = 0
		BEGIN
			SELECT *
			FROM #Leave
		END
		ELSE IF @Type = 1
		BEGIN
			SELECT COUNT(*) AS LeaveAppCnt
			FROM #Leave
		END

		RETURN
	END

	DECLARE @Emp_ID_Cur NUMERIC(18, 0)
	DECLARE @is_res_passed TINYINT

	SET @Emp_ID_Cur = 0
	SET @is_res_passed = 0

	------Get Sub Employee Cmp_Id
	DECLARE @String VARCHAR(MAX)
	DECLARE @Emp_Cmp_Id VARCHAR(MAX)
	DECLARE @string_1 VARCHAR(MAX)

	--	SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
	--	FROM T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
	--		( SELECT MAX(Effect_Date) as Effect_Date,Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 
	--			WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL 
	--																WHERE R_Emp_ID = @Emp_ID) GROUP BY Emp_ID 
	--		) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
	--		T0080_EMP_MASTER EM ON Em.Emp_ID = ERD.Emp_ID
	--WHERE ERD.R_Emp_ID = @Emp_ID for xml path (''))
	SELECT @String = (
			SELECT (convert(NVARCHAR, EM.Cmp_ID)) + ','
			FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
			INNER JOIN (
				SELECT max(Effect_Date) AS Effect_Date
					,ERD1.Emp_ID
				FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
				INNER JOIN (
					SELECT Emp_ID
					FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					WHERE R_Emp_ID IN (
							SELECT Emp_ID
							FROM #Responsiblity_Passed
							) /*@Emp_ID*/
					) Qry ON ERD1.Emp_ID = Qry.Emp_ID
				WHERE ERD1.Effect_Date <= getdate()
					AND R_Emp_ID IN (
						SELECT Emp_ID
						FROM #Responsiblity_Passed
						) /*@Emp_ID*/
				GROUP BY ERD1.Emp_ID
				) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID
				AND Tbl1.Effect_Date = ERD.Effect_Date
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
			WHERE ERD.R_Emp_ID IN (
					SELECT Emp_ID
					FROM #Responsiblity_Passed
					) --@Emp_ID   
			GROUP BY EM.Cmp_ID
			FOR XML path('')
			)

	IF (@String IS NOT NULL)
	BEGIN
		SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
	END

	----
	SELECT ES.Emp_ID
		,Scheme_Id
		,For_Date
	INTO #Emp_Scheme
	FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
	INNER JOIN (
		SELECT MAX(Effective_Date) AS For_Date
			,Emp_ID
		FROM T0095_EMP_SCHEME WITH (NOLOCK)
		WHERE Effective_Date <= GETDATE()
			AND Type = 'Leave' --and Scheme_Id = @Scheme_ID -- max date issue ON 12092013 - mitesh
		GROUP BY emp_ID
		) Qry ON ES.Emp_ID = Qry.Emp_ID
		AND ES.Effective_Date = Qry.For_Date
		AND Type = 'Leave'
		
	DECLARE Employee_Cur CURSOR
	FOR
	SELECT Emp_ID
		,is_res_passed
	FROM #Responsiblity_Passed
	GROUP BY Emp_ID
		,is_res_passed

	OPEN Employee_Cur

	FETCH NEXT
	FROM Employee_Cur
	INTO @Emp_ID_Cur
		,@is_res_passed

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Rpt_level = 1
		
		IF @Emp_ID_Cur > 0
		BEGIN
			DECLARE @Manager_Branch NUMERIC(18, 0)
			
			SET @Manager_Branch = 0
			
			--SELECT 1,@Emp_ID_Cur
			--		FROM T0095_MANAGERS WITH (NOLOCK)
			--		WHERE Emp_id = @Emp_ID_Cur
			IF EXISTS (
					SELECT 1
					FROM T0095_MANAGERS WITH (NOLOCK)
					WHERE Emp_id = @Emp_ID_Cur
					)
			BEGIN

				SELECT @Manager_Branch = branch_id
				FROM T0095_MANAGERS WITH (NOLOCK)
				WHERE Emp_id = @Emp_ID_Cur
					AND Effective_date = (
						SELECT max(Effective_date) AS Effective_date
						FROM T0095_MANAGERS WITH (NOLOCK)
						WHERE Emp_id = @Emp_ID_Cur
							AND Effective_date <= getdate()
						)
			END
			
			WHILE @Rpt_level <= @MaxLevel
			BEGIN
				----------------------
				SET @Rpt_level_Minus_1 = @Rpt_level - 1
				
				IF @Emp_ID_Cur > 0
				BEGIN
					--select @Emp_ID_Cur,@Rpt_level	
					INSERT INTO #tbl_Scheme_Leave (
						Scheme_ID
						,Leave
						,Is_Fwd_Leave_Rej
						,is_rpt_manager
						,rpt_level
						,Max_Leave_Days
						,Is_RMToRM
						)
					----Select distinct Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Leave_Days From T0050_Scheme_Detail Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level
					SELECT T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,Is_RM
						,rpt_level
						,Leave_Days
						,Is_RMToRM
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					INNER JOIN T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					WHERE App_Emp_Id = @Emp_ID_Cur
						AND rpt_level = @Rpt_level
						AND T0040_Scheme_Master.Scheme_Type = 'Leave' --Check Scheme Type --Ankit 13052014
					GROUP BY T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,Is_RM
						,rpt_level
						,Leave_Days
						,Is_RMToRM

					IF @Rpt_level = 1
						AND ISNULL(@Emp_Cmp_Id, 0) <> '0'
					BEGIN
						SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
							 							Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
														From T0050_Scheme_Detail WITH (NOLOCK) 
														Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
														Where  rpt_level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ' and Is_RM = 1 
															And T0040_Scheme_Master.Scheme_Type = ''Leave'' and T0040_Scheme_Master.Cmp_Id In  (' + @Emp_Cmp_Id + ')'

						EXEC (@string_1)
					END
							--Added By Jimit 05012018										
					ELSE IF @Rpt_level = 2
						AND ISNULL(@Emp_Cmp_Id, 0) <> '0'
					BEGIN
						SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
 																Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Leave_Days,Is_RMToRM
																From T0050_Scheme_Detail  WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ' and Is_RMToRM = 1 
																And T0040_Scheme_Master.Scheme_Type = ''Leave''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' Commented By Jimit as Cross Company Manager Login not showing application done by cross compny's Employee due to Scheme Id is not passing in the RM to RM's Sp (Dishman case)

						EXEC (@string_1)
					END
					
					--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days)
					-- 	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days
					--	From T0050_Scheme_Detail 
					--	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					--	Where  rpt_level = @Rpt_level and Is_RM = 1 
					--		And T0040_Scheme_Master.Scheme_Type = 'Leave'	
					--Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level
					--	From T0095_EMP_SCHEME ES Inner Join
					--		(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME
					--		 where Effective_Date<=GETDATE()
					--		 AND Cmp_ID = @Cmp_ID GROUP BY Emp_ID) Qry on      
					--		 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date Inner Join
					--		T0050_Scheme_Detail SD on ES.Scheme_ID = SD.Scheme_Id 
					--Where rpt_level = @Rpt_level And App_Emp_ID = @Emp_ID_Cur
					IF @Manager_Branch > 0
					BEGIN
						INSERT INTO #tbl_Scheme_Leave (
							Scheme_ID
							,Leave
							,Is_Fwd_Leave_Rej
							,is_branch_manager
							,rpt_level
							,Max_Leave_Days
							,Is_RMToRM
							)
						SELECT T0040_Scheme_Master.Scheme_Id
							,Leave
							,Is_Fwd_Leave_Rej
							,Is_BM
							,rpt_level
							,Leave_Days
							,Is_RMToRM
						FROM T0050_Scheme_Detail WITH (NOLOCK)
						INNER JOIN T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
						WHERE rpt_level = @Rpt_level
							AND Is_BM = 1
							AND T0040_Scheme_Master.Scheme_Type = 'Leave'
						GROUP BY T0040_Scheme_Master.Scheme_Id
							,Leave
							,Is_Fwd_Leave_Rej
							,Is_BM
							,rpt_level
							,Leave_Days
							,Is_RMToRM
					END
				END
				ELSE
				BEGIN
					INSERT INTO #tbl_Scheme_Leave (
						Scheme_ID
						,Leave
						,Is_Fwd_Leave_Rej
						,rpt_level
						,Max_Leave_Days
						,Is_RMToRM
						)
					--Select distinct Scheme_Id, Leave, Is_Fwd_Leave_Rej From T0050_Scheme_Detail Where    Cmp_Id = @Cmp_ID
					----Select distinct Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level,Leave_Days From T0050_Scheme_Detail-- Where Scheme_id IN (Select Scheme_Id From T0040_Scheme_Master Where Cmp_Id = @Cmp_ID) 
					SELECT T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,rpt_level
						,Leave_Days
						,Is_RMToRM
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					INNER JOIN T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					WHERE T0040_Scheme_Master.Scheme_Type = 'Leave' --Check Scheme Type --Ankit 13052014
					GROUP BY T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,rpt_level
						,Leave_Days
						,Is_RMToRM
				END
				
				
				--select * from #tbl_Scheme_Leave
				DECLARE @rpt_levle_cur TINYINT

				SET @rpt_levle_cur = 0

				--select * from #tbl_Scheme_Leave
				DECLARE Final_Approver CURSOR
				FOR
				SELECT Scheme_Id
					,Leave
					,rpt_level
				FROM #tbl_Scheme_Leave
				GROUP BY Scheme_Id
					,Leave
					,rpt_level

				OPEN Final_Approver

				FETCH NEXT
				FROM Final_Approver
				INTO @Scheme_ID
					,@Leave
					,@rpt_levle_cur

				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF EXISTS (
							SELECT Scheme_Detail_ID
							FROM T0050_Scheme_Detail WITH (NOLOCK)
							WHERE Scheme_Id = @Scheme_ID
								AND Leave = @Leave
								AND Rpt_Level = @Rpt_level + 1
								AND NOT_MANDATORY = 0
							)
					BEGIN
						UPDATE #tbl_Scheme_Leave
						SET Final_Approver = 0
						WHERE Scheme_Id = @Scheme_ID
							AND Leave = @Leave
							AND rpt_level = @Rpt_level
					END
					ELSE
					BEGIN
						UPDATE #tbl_Scheme_Leave
						SET Final_Approver = 1
						WHERE Scheme_Id = @Scheme_ID
							AND Leave = @Leave
							AND rpt_level = @Rpt_level
					END

					FETCH NEXT
					FROM Final_Approver
					INTO @Scheme_ID
						,@Leave
						,@rpt_levle_cur
				END

				CLOSE Final_Approver

				DEALLOCATE Final_Approver

				--select * from #tbl_Scheme_Leave
				DECLARE cur_Scheme_Leave CURSOR
				FOR
				SELECT Scheme_Id
					,Leave
					,is_rpt_manager
					,is_branch_manager
					,Is_RMToRM
				FROM #tbl_Scheme_Leave
				WHERE rpt_level = @Rpt_level

				OPEN cur_Scheme_Leave

				FETCH NEXT
				FROM cur_Scheme_Leave
				INTO @Scheme_ID
					,@Leave
					,@is_rpt_manager
					,@is_branch_manager
					,@is_Reporting_To_Reporting_manager

				WHILE @@FETCH_STATUS = 0
				BEGIN
					CREATE TABLE #Emp_Cons (Emp_ID NUMERIC)

					CREATE NONCLUSTERED INDEX IX_Emp_Cons_Emp_Id ON #Emp_Cons (Emp_ID)
					
					IF @is_branch_manager = 1
					BEGIN
						SELECT ES.Emp_ID
						FROM #Emp_Scheme ES
						INNER JOIN (
							SELECT Branch_ID
								,I.Emp_ID
							FROM T0095_Increment I WITH (NOLOCK)
							INNER JOIN (
								SELECT MAX(Increment_effective_Date) AS For_Date
									,Emp_ID
								FROM T0095_Increment WITH (NOLOCK)
								WHERE Increment_Effective_date <= GETDATE()
									AND Branch_ID = @Manager_Branch -- /* Cmp_ID = @Cmp_ID - Comment Cmp_ID AND Add Branch ID - For Cross Company Branch manager - Ankit 25062016 */ 
								GROUP BY emp_ID
								) Qry ON I.Emp_ID = Qry.Emp_ID
								AND I.Increment_effective_Date = Qry.For_Date
							) AS INC ON INC.Emp_ID = ES.Emp_ID
						WHERE ES.Scheme_Id = @Scheme_ID
							AND INC.Branch_ID = @Manager_Branch

						--select @Manager_Branch
						INSERT INTO #Emp_Cons (Emp_ID)
						SELECT ES.Emp_ID
						FROM #Emp_Scheme ES
						INNER JOIN (
							SELECT Branch_ID
								,I.Emp_ID
							FROM T0095_Increment I WITH (NOLOCK)
							INNER JOIN (
								SELECT MAX(Increment_effective_Date) AS For_Date
									,Emp_ID
								FROM T0095_Increment WITH (NOLOCK)
								WHERE Increment_Effective_date <= GETDATE()
									AND Branch_ID = @Manager_Branch -- /* Cmp_ID = @Cmp_ID - Comment Cmp_ID AND Add Branch ID - For Cross Company Branch manager - Ankit 25062016 */ 
								GROUP BY emp_ID
								) Qry ON I.Emp_ID = Qry.Emp_ID
								AND I.Increment_effective_Date = Qry.For_Date
							) AS INC ON INC.Emp_ID = ES.Emp_ID
						WHERE ES.Scheme_Id = @Scheme_ID
							AND INC.Branch_ID = @Manager_Branch
							
						IF @Rpt_level = 1
						BEGIN
							SET @SqlQuery = 'Select LAD.Leave_Application_ID, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , ' + cast(@Rpt_level AS VARCHAR(2)) + ' From V0110_LEAVE_APPLICATION_DETAIL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Leave_ID in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail  WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur AS VARCHAR(50)) + ' And rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + 
								' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval WITH (NOLOCK) 
																												Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + ')' + ' And ' + @Constrains
						END
						ELSE
						BEGIN
							SET @SqlQuery = 'Select LAD.Leave_Application_ID, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , ' + cast(@Rpt_level AS VARCHAR(2)) + '  From V0110_LEAVE_APPLICATION_DETAIL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Leave_ID in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail  WITH (NOLOCK)
																												WHERE Is_BM =  1 ' + ' And rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + ' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval  WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast
								(@Rpt_level AS VARCHAR(2)) + ')
																											
																		And LAD.Leave_Application_ID In (Select Leave_Application_ID From T0115_Leave_Level_Approval WITH (NOLOCK) 
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )' + ' And ' + @Constrains
						END
					END
					ELSE IF @is_rpt_manager = 1
					BEGIN
						INSERT INTO #Emp_Cons (Emp_ID)
						SELECT ERD.Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
						INNER JOIN (
							SELECT MAX(Effect_Date) AS Effect_Date
								,Emp_ID
							FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
							WHERE Effect_Date <= GETDATE()
								AND R_emp_id = @Emp_ID_Cur
							GROUP BY emp_ID
							) RQry ON ERD.Emp_ID = RQry.Emp_ID
							AND ERD.Effect_Date = RQry.Effect_Date
							AND R_emp_id = @Emp_ID_Cur
						INNER JOIN #Emp_Scheme ES ON ERD.Emp_ID = ES.Emp_ID
						WHERE R_emp_id = @Emp_ID_Cur
							AND ES.Scheme_ID = @Scheme_ID

						DELETE EC
						FROM #Emp_Cons EC
						LEFT OUTER JOIN (
							SELECT ERD.Emp_ID
							FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
							INNER JOIN (
								SELECT MAX(Effect_Date) AS Effect_Date
									,ERD1.Emp_ID
								FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
								INNER JOIN #Emp_Cons EC1 ON EC1.Emp_ID = ERD1.Emp_ID
								WHERE Effect_Date <= GETDATE()
								GROUP BY ERD1.emp_ID
								) RQry ON ERD.Emp_ID = RQry.Emp_ID
								AND ERD.Effect_Date = RQry.Effect_Date
								AND R_emp_id = @Emp_ID_Cur
							INNER JOIN #Emp_Cons EC ON EC.Emp_ID = RQry.Emp_ID
							) ERD1 ON EC.EMP_ID = ERD1.EMP_ID
						WHERE ERD1.EMP_ID IS NULL

						IF @Rpt_level = 1
						BEGIN
							SET @SqlQuery = 'Select LAD.Leave_Application_ID, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , ' + cast(@Rpt_level AS VARCHAR(2)) + ' From V0110_LEAVE_APPLICATION_DETAIL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Leave_ID in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail  WITH (NOLOCK)
																												WHERE is_RM = 1 ' + ' And rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + ' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval  WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(
									@Rpt_level AS VARCHAR(2)) + ')' + ' And ' + @Constrains
						END
						ELSE
						BEGIN
							SET @SqlQuery = 'Select LAD.Leave_Application_ID, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From V0110_LEAVE_APPLICATION_DETAIL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Leave_ID in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail  WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur AS VARCHAR(50)) + + ' And rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + 
								' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval  WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + ')
																											
																		And LAD.Leave_Application_ID In (Select Leave_Application_ID From T0115_Leave_Level_Approval  WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )' + ' And ' + @Constrains
						END
					END
							---------Added By Jimit 05012018-------------
					ELSE IF @is_Reporting_To_Reporting_manager = 1
						AND @Rpt_level = 2
					BEGIN
						IF @Rpt_level = 2
						BEGIN
							IF Object_ID('tempdb..#EMP_CONS_RM') IS NOT NULL
								DROP TABLE #EMP_CONS_RM
								
							CREATE TABLE #EMP_CONS_RM (
								Emp_ID NUMERIC
								,BRANCH_ID NUMERIC
								,INCREMENT_ID NUMERIC
								,R_EMP_ID NUMERIC DEFAULT 0
								,Scheme_ID NUMERIC
								,Rpt_Level TINYINT
								)

							DECLARE @date AS DATETIME

							SET @date = GETDATE()

							EXEC SP_RPT_FILL_EMP_CONS_WITH_REPORTING @Cmp_ID = @Cmp_ID
								,@From_Date = @date
								,@To_Date = @date
								,@Branch_ID = 0
								,@Cat_ID = 0
								,@Grd_ID = 0
								,@Type_ID = 0
								,@Dept_ID = 0
								,@Desig_ID = 0
								,@Emp_ID = @Emp_ID_Cur
								,@Constraint = ''
								,@Sal_Type = 0
								,@Salary_Cycle_id = 0
								,@Segment_Id = 0
								,@Vertical_Id = 0
								,@SubVertical_Id = 0
								,@SubBranch_Id = 0
								,@New_Join_emp = 0
								,@Left_Emp = 0
								,@SalScyle_Flag = 0
								,@PBranch_ID = 0
								,@With_Ctc = 0
								,@Type = 0
								,@Scheme_Id = @Scheme_ID
								,@Rpt_Level = 2
								,@SCHEME_TYPE = 'Leave'

							--SELECT @Emp_ID_Cur,* from #EMP_CONS_RM 
							SET @SqlQuery = 'Select  Leave_Application_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , ' + CAST(@Rpt_level AS VARCHAR(2)) + '
																			FROM	(SELECT LAD.Leave_Application_ID,LAD.Application_Status,from_date,To_Date,LAd.Alpha_Emp_Code,Leave_Name,Emp_First_Name
																					From	V0110_LEAVE_APPLICATION_DETAIL LAD 
																							INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																							LEFT OUTER JOIN (SELECT Leave_Application_ID,Emp_ID,S_Emp_ID,Approval_Status As App_Status FROM T0115_Leave_Level_Approval LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + 
								') LA 
																												ON LAD.Leave_Application_ID=LA.Leave_Application_ID And LAD.EMP_ID=LA.EMP_ID
																					Where	Leave_ID in (Select cast(data  as numeric) 
																											From dbo.Split (stuff((SELECT ''#'' + Leave  
																																		FROM T0050_Scheme_Detail  WITH (NOLOCK)
																																		WHERE		rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + ' FOR XML PATH('''')
																																   ),1,1,''''
																																  ),''#''
																															)
																									   ) 	 																							
																							ANd (
																									LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' + --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
								'And LAD.Leave_Application_ID In (Select Leave_Application_ID From T0115_Leave_Level_Approval WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1 and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
								')
																							--AND NOT EXISTS(SELECT 1 FROM #tbl_Leave_App T WHERE T.Leave_App_ID=LAD.Leave_Application_ID)
																					) T
																			WHERE	1=1  and ' + @Constrains
								--App_Emp_Id = Ec.Emp_Id '-- + cast(@Emp_ID_Cur as varchar(50)) + ' And + 
						END
					END
							------------Ended-----------------
					ELSE IF @is_rpt_manager = 0
						AND @is_branch_manager = 0
						AND @is_Reporting_To_Reporting_manager = 0
					BEGIN
						INSERT INTO #Emp_Cons (Emp_ID)
						SELECT ES.Emp_ID
						FROM #Emp_Scheme ES
						WHERE ES.Scheme_Id = @Scheme_ID

						IF @Rpt_level = 1
						BEGIN
							SET @SqlQuery = 'Select LAD.Leave_Application_ID, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , ' + cast(@Rpt_level AS VARCHAR(2)) + ' From V0110_LEAVE_APPLICATION_DETAIL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Leave_ID in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail  WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur AS VARCHAR(50)) + ' And rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + 
								' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval WITH (NOLOCK) 
																												Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + ')' + ' And ' + @Constrains
						END
						ELSE
						BEGIN
							SET @SqlQuery = 'Select LAD.Leave_Application_ID, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , ' + cast(@Rpt_level AS VARCHAR(2)) + ' From V0110_LEAVE_APPLICATION_DETAIL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Leave_ID in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK) 
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur AS VARCHAR(50)) + ' And rpt_level = ' + cast(@Rpt_level AS VARCHAR(2)) + + ' And Scheme_ID = ' + cast(@Scheme_ID AS VARCHAR(3)) + + ' And Leave = ''' + @Leave + '''' + 
								' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval  WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + ')
																											
																		And LAD.Leave_Application_ID In (Select Leave_Application_ID From T0115_Leave_Level_Approval  WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )' + ' And ' + @Constrains
						END
					END

					--Where Scheme_Id In (Select distinct Scheme_Id From T0050_Scheme_Detail Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level)
					INSERT INTO #tbl_Leave_App (
						Leave_App_ID
						,Scheme_ID
						,Leave
						,rpt_level
						)
					EXEC (@SqlQuery)

					DROP TABLE #Emp_Cons

					FETCH NEXT
					FROM cur_Scheme_Leave
					INTO @Scheme_ID
						,@Leave
						,@is_rpt_manager
						,@is_branch_manager
						,@is_Reporting_To_Reporting_manager
				END

				CLOSE cur_Scheme_Leave

				DEALLOCATE cur_Scheme_Leave

				--------------------------
				SET @Rpt_level = @Rpt_level + 1
			END
		END

		
		--If @Rpt_level = 1
		--	Begin
		--		Select 
		--			LAD.Row_ID, LAD.Leave_ID, LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Leave_Name, LAD.Application_Code
		--			,LAD.Application_Status, LAD.Senior_Employee, LAD.Leave_Application_ID, LAD.Emp_first_name, LAD.Emp_Code, LAD.Branch_Name
		--			,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Leave_Reason, LAD.Application_Date
		--			,@Rpt_level As Rpt_Level, TLAP.Scheme_ID, TLAP.Leave, SL.Final_Approver, SL.Is_Fwd_Leave_Rej
		--			,LAD.From_Date, LAD.To_Date, LAD.Leave_Period
		--			From V0110_LEAVE_APPLICATION_DETAIL LAD
		--				Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Leave_Application_ID
		--				inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave
		--			Where Leave_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
		--	End
		--Else
		--	Begin		
		--select * from #tbl_Leave_App
		--select * from #tbl_Scheme_Leave
		--select lla.Leave_Application_ID As App_ID, lla.From_Date, lla.To_Date, lla.Leave_Period,(Rpt_Level) as Rpt_Level from T0115_Leave_Level_Approval lla
		--				inner join (Select max(rpt_level) as rpt_level1, Leave_Application_ID
		--								From T0115_Leave_Level_Approval 
		--								Where Leave_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
		--								group by Leave_Application_ID 
		--							) Qry
		--				on qry.leave_application_id = lla.leave_application_id and qry.rpt_level1 = lla.rpt_level
		
		IF @Emp_ID_Cur > 0
		BEGIN
			INSERT INTO #Leave
			SELECT DISTINCT LAD.Row_ID
				,Lad.Cmp_ID
				,LAD.Leave_ID
				,LAD.Emp_ID
				,LAD.Emp_Full_Name
				,isnull(lm.Leave_Name, LAD.Leave_Name)
				,LAD.Application_Code
				,LAD.Application_Status
				,LAD.Senior_Employee
				,LAD.Leave_Application_ID
				,LAD.Emp_first_name
				,LAD.Emp_Code
				,LAD.Branch_Name
				,LAD.Desig_Name
				,LAD.Alpha_Emp_code
				,REPLACE(LAD.Leave_Reason, CHAR(34), '') -- Changed by Niraj (30122021)
				,CONVERT(DATETIME, CONVERT(CHAR(10), LAD.Application_Date, 103), 103) AS Application_Date
				,isnull(Qry1.rpt_level + 1, '1') AS Rpt_Level
				,TLAP.Scheme_ID
				,TLAP.Leave
				,CASE 
					WHEN Max_Leave_Days > 0
						THEN CASE 
								WHEN isnull(Qry1.Leave_Period, lad.Leave_Period) <= Max_Leave_Days
									THEN 1
								ELSE 0
								END
					ELSE SL.Final_Approver
					END
				,SL.Is_Fwd_Leave_Rej
				,isnull(Qry1.From_Date, lad.from_date) AS From_Date
				,isnull(Qry1.To_Date, lad.to_date) AS to_date
				,isnull(Qry1.Leave_Period, lad.Leave_Period) AS Leave_Period
				,@is_res_passed
				,Qry1.Leave_ID
				,Qry1.M_Cancel_WO_HO
				,LAD.Branch_ID
				,CASE lad.is_backdated_application
					WHEN 1
						THEN '*'
					ELSE ''
					END AS Is_Backdated_Application
				,CASE 
					WHEN LM.Apply_Hourly = 1
						THEN 'hour(s)'
					ELSE 'day(s)'
					END AS Leave_Type -- Changed by Gadriwala Muslim 24042015
				,LAD.Vertical_Id
				,LAD.Subvertical_Id
				,LAD.Dept_ID
				,LAD.Dept_Name
				,--Added By Jaina 1-10-2015
				CASE 
					WHEN Application_Status = 'P'
						THEN 'Pending'
					WHEN Application_Status = 'A'
						THEN 'Approved'
					WHEN Application_Status = 'R'
						THEN 'Rejected'
					END AS Leave_Application_Status
			FROM V0110_LEAVE_APPLICATION_DETAIL LAD
			LEFT OUTER JOIN (
				SELECT lla.Leave_Application_ID AS App_ID
					,lla.From_Date
					,lla.To_Date
					,lla.Leave_Period
					,Rpt_Level AS Rpt_Level
					,lla.Leave_ID
					,lla.M_Cancel_WO_HO
				FROM T0115_Leave_Level_Approval lla WITH (NOLOCK)
				INNER JOIN (
					SELECT max(rpt_level) AS rpt_level1
						,Leave_Application_ID
					FROM T0115_Leave_Level_Approval WITH (NOLOCK)
					INNER JOIN (
						SELECT Leave_App_ID
						FROM #tbl_Leave_App
						) qry ON T0115_Leave_Level_Approval.Leave_Application_ID = qry.Leave_App_ID
					--Where Leave_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
					GROUP BY Leave_Application_ID
					) Qry ON qry.leave_application_id = lla.leave_application_id
					AND qry.rpt_level1 = lla.rpt_level
				) AS Qry1 ON LAD.Leave_Application_ID = Qry1.App_ID -- This join is for getting updated from date,to date and leave period in case if any middle approver change it, then next should be see updated info and not old one 
			INNER JOIN #tbl_Leave_App TLAP ON TLAP.Leave_App_ID = LAD.Leave_Application_ID
			INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID
				AND SL.Leave = TLAP.Leave
				AND SL.rpt_level > isnull(Qry1.Rpt_Level, 0)
				AND SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
			INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID = LM.Leave_ID -- Changed by Gadriwala Muslim 11062015  
			INNER JOIN (
				SELECT Leave_App_ID
				FROM #tbl_Leave_App
				) qry ON lad.Leave_Application_ID = qry.Leave_App_ID
			--Where Leave_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)	
			WHERE LAD.Cmp_ID = @Cmp_ID
				AND (
					Application_Status = 'P'
					OR Application_Status = 'F'
					)
		END
		ELSE
		BEGIN
			--	LAD.Senior_Employee
			INSERT INTO #Leave
			SELECT DISTINCT LAD.Row_ID
				,LAD.Cmp_ID
				,LAD.Leave_ID
				,LAD.Emp_ID
				,LAD.Emp_Full_Name
				,isnull(lm.Leave_Name, LAD.Leave_Name)
				,LAD.Application_Code
				,LAD.Application_Status
				,LAD.Senior_Employee
				,LAD.Leave_Application_ID
				,LAD.Emp_first_name
				,LAD.Emp_Code
				,LAD.Branch_Name
				,LAD.Desig_Name
				,LAD.Alpha_Emp_code
				,REPLACE(LAD.Leave_Reason, CHAR(34), '') -- Changed by Niraj (30122021)
				,CONVERT(DATETIME, CONVERT(CHAR(10), LAD.Application_Date, 103), 103) AS Application_Date
				,isnull(Qry1.rpt_level + 1, '1') AS Rpt_Level
				,'0' AS Scheme_ID
				,'' AS Leave
				,'1' AS Final_Approver
				,'0' AS Is_Fwd_Leave_Rej
				,isnull(Qry1.From_Date, lad.from_date) AS From_Date
				,isnull(Qry1.To_Date, lad.to_date) AS to_date
				,isnull(Qry1.Leave_Period, lad.Leave_Period) AS Leave_Period
				,@is_res_passed
				,Qry1.Leave_ID
				,Qry1.M_Cancel_WO_HO
				,LAD.Branch_ID
				,CASE lad.is_backdated_application
					WHEN 1
						THEN '*'
					ELSE ''
					END AS Is_Backdated_Application
				,CASE 
					WHEN LM.Apply_Hourly = 1
						THEN 'hour(s)'
					ELSE 'day(s)'
					END AS Leave_Type -- Changed by Gadriwala Muslim 24042015
				,LAD.Vertical_Id
				,LAD.Subvertical_Id
				,LAD.Dept_ID
				,LAD.Dept_Name
				,--Added By Jaina 1-10-2015
				CASE 
					WHEN Application_Status = 'P'
						THEN 'Pending'
					WHEN Application_Status = 'A'
						THEN 'Approved'
					WHEN Application_Status = 'R'
						THEN 'Rejected'
					END AS Leave_Application_Status
			FROM V0110_LEAVE_APPLICATION_DETAIL LAD
			LEFT OUTER JOIN (
				SELECT lla.Leave_Application_ID AS App_ID
					,lla.From_Date
					,lla.To_Date
					,lla.Leave_Period
					,Rpt_Level AS Rpt_Level
					,lla.Leave_ID
					,lla.M_Cancel_WO_HO
				FROM T0115_Leave_Level_Approval lla WITH (NOLOCK)
				INNER JOIN (
					SELECT max(rpt_level) AS rpt_level1
						,Leave_Application_ID
					FROM T0115_Leave_Level_Approval WITH (NOLOCK)
					--Where Leave_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
					GROUP BY Leave_Application_ID
					) Qry ON qry.leave_application_id = lla.leave_application_id
					AND qry.rpt_level1 = lla.rpt_level
				) AS Qry1 ON LAD.Leave_Application_ID = Qry1.App_ID
			INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID = LM.Leave_ID -- Changed by Gadriwala Muslim 11062015  
			WHERE LAD.Cmp_ID = @Cmp_ID
				AND (
					Application_Status = 'P'
					OR Application_Status = 'F'
					)
		END

		--End
		----	end
		----else
		----	begin
		----		set @SqlExcu = ' Select 
		----							LAD.Row_ID, LAD.Leave_ID, LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Leave_Name, LAD.Application_Code
		----							,LAD.Application_Status, LAD.Senior_Employee, LAD.Leave_Application_ID, LAD.Emp_first_name, LAD.Emp_Code, LAD.Branch_Name
		----							,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Leave_Reason, LAD.Application_Date
		----							,' + cast(@Rpt_level AS NVARCHAR(2)) + ' As Rpt_Level, 0 AS Scheme_ID , 0 as Leave, 0 as Final_Approver, 0 as Is_Fwd_Leave_Rej
		----							,'''' as From_Date, '''' as To_Date, 0 as Leave_Period
		----							From V0110_LEAVE_APPLICATION_DETAIL LAD 
		----							WHERE ' + @Constrains
		----					print @SqlExcu		
		----		exec (@SqlExcu)
		----	end
		--Declare @SqlQuery As NVarchar(max)
		--Declare @Rpt_level_Minus_1 As Numeric(18,0)
		--Set @Rpt_level_Minus_1 = @Rpt_level - 1
		--CREATE TABLE #Emp_Cons 
		-- (
		--   Emp_ID numeric    
		-- )            
		--If @Emp_ID_Cur = 0
		--	Begin
		--		Insert Into #Emp_Cons(Emp_ID)    
		--			Select Emp_ID From T0095_EMP_SCHEME Where Scheme_Id In (Select distinct Scheme_Id From T0050_Scheme_Detail Where rpt_level = @Rpt_level)			
		--		Select LAD.*, @Rpt_level As Rpt_Level
		--			From V0110_LEAVE_APPLICATION_DETAIL LAD	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
		--			Where Leave_ID in (Select cast(data  as numeric) From dbo.Split (stuff((SELECT '#'+ Leave FROM T0050_Scheme_Detail WHERE rpt_level = @Rpt_level FOR XML PATH('') ),1,1,''),'#'))
		--	End
		--Else
		--	Begin			
		--		Insert Into #Emp_Cons(Emp_ID)    
		--			Select Emp_ID From T0095_EMP_SCHEME Where Scheme_Id In (Select distinct Scheme_Id From T0050_Scheme_Detail Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level)
		--		If @Rpt_level = 1
		--			Begin
		--				Set @SqlQuery = 	
		--				'Select LAD.* , ' + Cast(@Rpt_level As Varchar(2)) + ' As Rpt_Level  
		--					From V0110_LEAVE_APPLICATION_DETAIL LAD Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
		--					Where Leave_ID in (Select cast(data  as numeric) From dbo.Split (stuff((SELECT ''#'' + Leave FROM T0050_Scheme_Detail WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) + ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) + ' FOR XML PATH('''')),1,1,''''),''#''))
		--						  And LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')' + ' And ' + @Constrains				  
		--			End
		--		Else
		--			Begin
		--				Set @SqlQuery = 	
		--				'Select LAD.* , ' + Cast(@Rpt_level As Varchar(2)) + ' As Rpt_Level  
		--					From V0110_LEAVE_APPLICATION_DETAIL LAD Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
		--					Where Leave_ID in (Select cast(data  as numeric) From dbo.Split (stuff((SELECT ''#'' + Leave FROM T0050_Scheme_Detail WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) + ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) + ' FOR XML PATH('''')),1,1,''''),''#''))	   
		--						  And (LAD.Leave_Application_ID Not In (Select Leave_Application_ID From T0115_Leave_Level_Approval Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')										
		--								And LAD.Leave_Application_ID In (Select Leave_Application_ID From T0115_Leave_Level_Approval 
		--																	Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + '))'    
		--						  + ' And ' + @Constrains
		--			End	 
		--		exec (@SqlQuery)				    
		--	End
		DELETE #tbl_Scheme_Leave

		DELETE #tbl_Leave_App

		FETCH NEXT
		FROM Employee_Cur
		INTO @Emp_ID_Cur
			,@is_res_passed
	END

	CLOSE Employee_Cur

	DEALLOCATE Employee_Cur

	
	IF @Type = 0
	BEGIN
		IF @Emp_ID_Cur > 0
		BEGIN
			-- Changed By Ali 28112013 
			--select * from #Leave order by #Leave.From_Date desc
			---- Display Leave From Date In & Out Time -- Ankit 05082016
			SELECT L.*
				,dbo.F_GET_AMPM(Q1.In_Date) AS In_Time
				,CASE 
					WHEN CAST(CONVERT(VARCHAR(16), Max_In_Date, 120) AS DATETIME) > CAST(CONVERT(VARCHAR(16), Out_Date, 120) AS DATETIME)
						THEN dbo.F_GET_AMPM(Max_In_Date)
					ELSE dbo.F_GET_AMPM(Out_Date)
					END AS Out_Time
			FROM #Leave L
			LEFT OUTER JOIN (
				SELECT EI1.Emp_ID
					,MIN(In_Time) In_Date
					,For_Date
				FROM dbo.T0150_Emp_Inout_Record EI1 WITH (NOLOCK)
				INNER JOIN #Leave L1 ON L1.Emp_ID = EI1.Emp_ID
					AND EI1.For_Date BETWEEN L1.From_Date
						AND L1.To_Date
				GROUP BY EI1.Emp_ID
					,For_Date
				) Q1 ON Q1.Emp_Id = L.emp_ID
				AND L.From_Date = Q1.For_Date
			LEFT OUTER JOIN (
				SELECT EI2.Emp_Id
					,MAX(Out_Time) Out_Date
					,For_Date
				FROM dbo.T0150_Emp_Inout_Record EI2 WITH (NOLOCK)
				INNER JOIN #Leave L1 ON L1.Emp_ID = EI2.Emp_ID
					AND EI2.For_Date BETWEEN L1.From_Date
						AND L1.To_Date
				GROUP BY EI2.Emp_ID
					,For_Date
				) Q2 ON Q2.Emp_Id = L.emp_ID
				AND L.From_Date = Q2.For_Date
			LEFT OUTER JOIN
				--Added by Hardik 23/07/2012 for First IN And Last OUT (it will take Max In Punch as OUT and calculate Hours)
				(
				SELECT EI3.Emp_Id
					,MAX(In_Time) Max_In_Date
					,For_Date
				FROM dbo.T0150_Emp_Inout_Record EI3
				INNER JOIN #Leave L1 ON L1.Emp_ID = EI3.Emp_ID
					AND EI3.For_Date BETWEEN L1.From_Date
						AND L1.To_Date
				GROUP BY EI3.Emp_ID
					,For_Date
				) Q4 ON Q4.Emp_Id = L.emp_ID
				AND L.From_Date = Q4.For_Date
			ORDER BY L.From_Date DESC
				----Ankit 05082016
		END
		ELSE
		BEGIN
			-- Changed By Ali 28112013 
			DECLARE @queryExe AS NVARCHAR(1000)

			SET @queryExe = 'select * from #Leave where ' + @Constrains + ' order by #Leave.From_Date desc '

			EXEC (@queryExe)
		END
	END
	ELSE IF @Type = 1
	BEGIN
		IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #Notification_Value

			INSERT INTO #Notification_Value
			SELECT count(*) AS LeaveAppCnt
			FROM #Leave
		END
		ELSE
			SELECT count(*) AS LeaveAppCnt
			FROM #Leave
	END
	ELSE IF @Type = 2
	BEGIN
		DECLARE @queryExe1 AS NVARCHAR(max)

		SET @queryExe1 = 'select count(1) as Total_Pending_Leave from #Leave where ' + @Constrains + ''

		EXEC (@queryExe1)
	END

	DROP TABLE #tbl_Scheme_Leave

	DROP TABLE #tbl_Leave_App

	DROP TABLE #Responsiblity_Passed

	DROP TABLE #Leave
END