
-- =============================================
-- Author:		<Muslim Gadriwala>
-- Create date: <09102014,,>
-- Description:	<Get Record Level Approval>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Get_OT_Level_Approval_Records_Backup_10072024] 
	@Cmp_ID NUMERIC(18, 0)
	,@Emp_ID NUMERIC(18, 0)
	,@R_Emp_ID NUMERIC(18, 0)
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Rpt_level NUMERIC(18, 0)
	,@Return_Record_set TINYINT = 2
	,@constraint VARCHAR(max)
	,@Type NUMERIC(18, 0) = 0
	,@Dept_ID NUMERIC(18, 0)
	,@Grd_ID NUMERIC(18, 0)
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @Scheme_ID AS NUMERIC(18, 0)
	DECLARE @Leave AS VARCHAR(100)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager AS TINYINT
	DECLARE @SqlQuery AS NVARCHAR(max)
	DECLARE @SqlExcu AS NVARCHAR(max)
	DECLARE @MaxLevel AS NUMERIC(18, 0)
	DECLARE @Rpt_level_Minus_1 AS NUMERIC(18, 0)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 31012018 

	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level), 1)
	FROM T0050_Scheme_Detail SD
	INNER JOIN T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id
	WHERE SM.Scheme_Type = 'Over Time'

	SET @is_rpt_manager = 0
	SET @is_branch_manager = 0
	SET @SqlExcu = ''

	CREATE TABLE #Responsiblity_Passed (
		Emp_ID NUMERIC(18, 0)
		,is_res_passed TINYINT DEFAULT 1
		)

	INSERT INTO #Responsiblity_Passed
	SELECT @R_Emp_ID
		,0

	INSERT INTO #Responsiblity_Passed
	SELECT DISTINCT manger_emp_id
		,1
	FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO
	WHERE pass_to_emp_id = @R_Emp_ID
		AND getdate() >= from_date
		AND getdate() <= to_date
		AND Type = 'OverTime' --Added By Jimit 12122019

	CREATE TABLE #tbl_Scheme_Leave (
		Scheme_ID NUMERIC(18, 0)
		,Leave VARCHAR(100)
		,Final_Approver TINYINT
		,Is_Fwd_Leave_Rej TINYINT
		,is_rpt_manager TINYINT NOT NULL DEFAULT 0
		,is_branch_manager TINYINT NOT NULL DEFAULT 0
		,rpt_level NUMERIC(18, 0)
		,Max_Leave_Days NUMERIC(18, 2)
		,Is_RMToRM TINYINT NOT NULL DEFAULT 0 --added By jimit 31012018
		)

	CREATE TABLE #tbl_Leave_App (
		Emp_Id NUMERIC
		,For_Date DATETIME
		,Scheme_ID NUMERIC(18, 0)
		,rpt_level NUMERIC(18, 0)
		)

	IF @Rpt_level > 0
	BEGIN
		SET @MaxLevel = @Rpt_level
	END
	ELSE
	BEGIN
		SET @Rpt_level = 1
	END

	IF @Grd_ID = 0
		SET @Grd_ID = NULL

	IF @Dept_ID = 0
		SET @Dept_ID = NULL

	CREATE TABLE #Data (
		Emp_Id NUMERIC
		,For_date DATETIME
		,Duration_in_sec NUMERIC
		,Shift_ID NUMERIC
		,Shift_Type NUMERIC
		,Emp_OT NUMERIC
		,Emp_OT_min_Limit NUMERIC
		,Emp_OT_max_Limit NUMERIC
		,P_days NUMERIC(12, 2) DEFAULT 0
		,OT_Sec NUMERIC DEFAULT 0
		,In_Time DATETIME
		,Shift_Start_Time DATETIME
		,OT_Start_Time NUMERIC DEFAULT 0
		,Shift_Change TINYINT DEFAULT 0
		,Flag INT DEFAULT 0
		,Weekoff_OT_Sec NUMERIC DEFAULT 0
		,Holiday_OT_Sec NUMERIC DEFAULT 0
		,Chk_By_Superior NUMERIC DEFAULT 0
		,IO_Tran_Id NUMERIC DEFAULT 0
		,OUT_Time DATETIME
		,Shift_End_Time DATETIME
		,OT_End_Time NUMERIC DEFAULT 0
		,Working_Hrs_St_Time TINYINT DEFAULT 0
		,Working_Hrs_End_Time TINYINT DEFAULT 0
		,GatePass_Deduct_Days NUMERIC(18, 2) DEFAULT 0 -- Add by Gadriwala Muslim 05012014
		)

	--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
	IF NOT EXISTS (
			SELECT 1
			FROM T0050_Scheme_Detail SD WITH (NOLOCK)
			INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
			WHERE SM.Scheme_Type = 'Over Time'
			)
	BEGIN
		IF @Type = 0
		BEGIN
			SELECT *
			FROM #Data
		END
		ELSE IF @Type = 1
		BEGIN
			IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
			BEGIN
				TRUNCATE TABLE #Notification_Value

				INSERT INTO #Notification_Value
				SELECT 0 AS OTCOUNT
			END
			ELSE
				SELECT 0 AS OTCOUNT
		END

		RETURN
	END

	SELECT *
	INTO #Data_Temp
	FROM #Data

	CREATE TABLE #Approved_OT (
		Emp_ID NUMERIC
		,Work_date DATETIME
		)

	CREATE TABLE #OT_APPROVAL (
		Tran_Id NUMERIC DEFAULT 0
		,Emp_Id NUMERIC
		,For_date DATETIME
		,Working_Hour VARCHAR(20)
		,OT_Hour VARCHAR(20)
		,WeekOff_OT_Hour VARCHAR(20)
		,Holiday_OT_Hour VARCHAR(20)
		,P_Days_Count NUMERIC(18, 2)
		,Flag INT DEFAULT 0
		,Shift_Start_Time DATETIME
		,Shift_End_Time DATETIME
		,In_Time DATETIME
		,Out_Time DATETIME
		)

	DECLARE @Emp_ID_Cur NUMERIC(18, 0)
	DECLARE @is_res_passed TINYINT

	SET @Emp_ID_Cur = 0
	SET @is_res_passed = 0

	DECLARE @string_1 VARCHAR(MAX)

	--Added By Jimit 10102018
	CREATE TABLE #Emp_Cons1 (Emp_ID NUMERIC)

	CREATE UNIQUE CLUSTERED INDEX IX_Emp_Cons1_EMPID ON #Emp_Cons1 (EMP_ID);

	--Ended
	DECLARE @String VARCHAR(MAX)
	DECLARE @Emp_Cmp_Id VARCHAR(MAX)

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
			INNER JOIN T0080_EMP_MASTER EM ON Em.Emp_ID = ERD.Emp_ID
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

	DECLARE Employee_Cur CURSOR
	FOR
	SELECT DISTINCT Emp_ID
		,is_res_passed
	FROM #Responsiblity_Passed

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

			IF EXISTS (
					SELECT 1
					FROM T0095_MANAGERS
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
				SET @Rpt_level_Minus_1 = @Rpt_level - 1

				IF @Emp_ID_Cur > 0
				BEGIN
					INSERT INTO #tbl_Scheme_Leave (
						Scheme_ID
						,Leave
						,Is_Fwd_Leave_Rej
						,is_rpt_manager
						,rpt_level
						,Max_Leave_Days
						,Is_RMToRM
						)
					SELECT DISTINCT T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,Is_RM
						,rpt_level
						,Leave_Days
						,Is_RMToRM
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					INNER JOIN T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					WHERE App_Emp_Id = @R_Emp_ID
						AND rpt_level = @Rpt_level
						AND T0040_Scheme_Master.Scheme_Type = 'Over Time'

					INSERT INTO #tbl_Scheme_Leave (
						Scheme_ID
						,Leave
						,Is_Fwd_Leave_Rej
						,is_rpt_manager
						,rpt_level
						,Max_Leave_Days
						,Is_RMToRM
						)
					SELECT DISTINCT T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,Is_RM
						,rpt_level
						,Leave_Days
						,Is_RMToRM
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					INNER JOIN T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					WHERE rpt_level = @Rpt_level
						AND Is_RM = 1
						AND T0040_Scheme_Master.Scheme_Type = 'Over Time'

					--Added By Jimit 31012018										
					IF @Rpt_level = 2
						AND ISNULL(@Emp_ID_Cur, 0) <> '0'
					BEGIN
						SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
													Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where  rpt_level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ' and Is_RMToRM = 1 
													And T0040_Scheme_Master.Scheme_Type = ''Over Time''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' Commented By Jimit as Cross Company Manager Login not showing application done by cross compny's Employee due to Scheme Id is not passing in the RM to RM's Sp (Dishman case)

						EXEC (@string_1)
					END

					--ENDED
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
						SELECT DISTINCT T0050_Scheme_Detail.Scheme_Id
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
							AND T0040_Scheme_Master.Scheme_Type = 'Over Time'
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
					SELECT DISTINCT T0050_Scheme_Detail.Scheme_Id
						,Leave
						,Is_Fwd_Leave_Rej
						,rpt_level
						,Leave_Days
						,Is_RMToRM
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					INNER JOIN T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					WHERE T0040_Scheme_Master.Scheme_Type = 'Over Time'
				END

				DECLARE @rpt_levle_cur TINYINT

				SET @rpt_levle_cur = 0

				DECLARE Final_Approver CURSOR
				FOR
				SELECT DISTINCT Scheme_Id
					,Leave
					,rpt_level
				FROM #tbl_Scheme_Leave

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
							FROM T0050_Scheme_Detail
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
					TRUNCATE TABLE #Emp_Cons1

					IF @is_branch_manager = 1
					BEGIN
						INSERT INTO #Emp_Cons1 (Emp_ID)
						SELECT DISTINCT ES.Emp_ID
						FROM T0095_EMP_SCHEME ES
						INNER JOIN (
							SELECT MAX(Effective_Date) AS For_Date
								,Emp_ID
							FROM T0095_EMP_SCHEME WITH (NOLOCK)
							WHERE Effective_Date <= GETDATE()
								AND Type = 'Over Time'
								AND Cmp_ID = @Cmp_ID
							GROUP BY emp_ID
							) Qry ON ES.Emp_ID = Qry.Emp_ID
							AND ES.Effective_Date = Qry.For_Date
							AND Scheme_Id = @Scheme_ID
							AND Type = 'Over Time'
						INNER JOIN T0095_Increment I ON ES.EMP_ID = I.EMP_ID
						INNER JOIN (
							SELECT I1.EMP_ID
								,MAX(I1.Increment_ID) AS Increment_ID
							FROM T0095_Increment I1 WITH (NOLOCK)
							INNER JOIN (
								SELECT I2.EMP_ID
									,MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date
								FROM T0095_Increment I2 WITH (NOLOCK)
								WHERE I2.Increment_Effective_Date <= getdate()
								GROUP BY I2.Emp_ID
								) I2 ON I1.Emp_ID = I2.Emp_ID
								AND I1.Increment_Effective_Date = I2.Increment_Effective_Date
							GROUP BY I1.Emp_ID
							) I1 ON I1.Emp_ID = I.Emp_ID
							AND I1.Increment_ID = I.Increment_ID
						WHERE ES.Scheme_Id = @Scheme_ID
							AND I.Branch_ID = @Manager_Branch
							AND I.Cmp_ID = @Cmp_ID
							AND isnull(I.Grd_ID, 0) = isnull(@Grd_ID, I.Grd_ID)
							AND isnull(I.Dept_ID, 0) = isnull(@Dept_ID, isnull(I.Dept_ID, 0))

						SET @constraint = NULL

						SELECT @constraint = COALESCE(@Constraint + '#', '') + cast(EC.Emp_ID AS VARCHAR(18))
						FROM #Emp_Cons1 EC

						--INNER join 
						-- (
						--		select I.Emp_ID From T0095_Increment I 
						--		inner join     
						--		(
						--			select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    
						--			where Increment_Effective_date <= @From_Date 
						--			and Cmp_ID = @Cmp_ID  and isnull(Grd_ID,0) = isnull(@Grd_ID ,Grd_ID)      
						--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) group by emp_ID
						--		 ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
						-- ) as INC on INC.Emp_ID = EC.Emp_ID
						IF @constraint <> ''
						BEGIN
							EXEC SP_CALCULATE_PRESENT_DAYS @cmp_ID = @Cmp_ID
								,@From_Date = @From_Date
								,@To_Date = @To_Date
								,@Branch_ID = 0
								,@Cat_ID = 0
								,@Grd_ID = 0
								,@Type_ID = 0
								,@Dept_ID = 0
								,@Desig_ID = 0
								,@Emp_ID = 0
								,@constraint = @constraint
								,@Return_Record_set = 4
								,@StrWeekoff_Date = ''
								,@Is_Split_Shift_Req = 0
						END

						INSERT INTO #OT_APPROVAL
						SELECT isnull(Qry1.Tran_ID, 0) AS Tran_ID
							,DA.emp_ID
							,DA.For_date
							,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
							,dbo.F_Return_Hours(OT_SEc) AS OT_Hour
							,dbo.F_Return_Hours(isnull(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
							,dbo.F_Return_Hours(Holiday_OT_Sec) AS Holiday_OT_Hour
							,Da.P_days AS P_Days_Count
							,Flag
							,Shift_Start_Time
							,Shift_End_Time
							,In_Time
							,OUT_Time
						FROM #Data DA
						LEFT OUTER JOIN (
							SELECT lla.Tran_Id AS Tran_ID
								,lla.For_Date AS For_Date
								,lla.Emp_ID
								,Rpt_Level AS Rpt_Level
							FROM T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
							INNER JOIN (
								SELECT max(rpt_level) AS rpt_level1
									,Emp_ID
									,For_Date
								FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
								WHERE For_Date IN (
										SELECT For_Date
										FROM #Data
										WHERE Emp_ID IN (
												SELECT emp_ID
												FROM #Emp_Cons1
												)
										)
								GROUP BY Emp_ID
									,For_Date
								) Qry ON qry.For_Date = lla.For_Date
								AND Qry.Emp_ID = lla.Emp_ID
								AND qry.rpt_level1 = lla.rpt_level
							) AS Qry1 ON DA.For_Date = Qry1.For_Date
							AND DA.Emp_Id = Qry1.Emp_ID
						WHERE (
								OT_Sec > 0
								OR Weekoff_OT_Sec > 0
								OR Holiday_OT_Sec > 0
								)

						--select * from #OT_APPROVAL
						IF @Rpt_level = 1
						BEGIN
							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From #OT_APPROVAL LAD 
															Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
															Where LAD.Tran_Id Not In (Select Tran_Id From T0115_OT_LEVEL_APPROVAL 
															Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + ')'
						END
						ELSE
						BEGIN
							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + '  From #OT_APPROVAL LAD
														   Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
														   Where (	LAD.Tran_Id Not In 
																	(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL  WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + '
																	)
																	And LAD.Tran_Id In 
																	(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL  WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS VARCHAR(2)) + '
																	)
																 )'
						END
					END
					ELSE IF @is_rpt_manager = 1
					BEGIN
						INSERT INTO #Emp_Cons1 (Emp_ID)
						SELECT DISTINCT ERD.Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
						INNER JOIN --Ankit 28012015
							(
							SELECT MAX(Effect_Date) AS Effect_Date
								,Emp_ID
							FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
							WHERE Effect_Date <= GETDATE()
							GROUP BY emp_ID
							) RQry ON ERD.Emp_ID = RQry.Emp_ID
							AND ERD.Effect_Date = RQry.Effect_Date
						INNER JOIN T0095_EMP_SCHEME ES ON ES.Emp_ID = ERD.Emp_ID
						INNER JOIN (
							SELECT MAX(Effective_Date) AS For_Date
								,Emp_ID
							FROM T0095_EMP_SCHEME WITH (NOLOCK)
							WHERE Effective_Date <= GETDATE()
								AND Type = 'Over Time'
							GROUP BY emp_ID
							) Qry ON ES.Emp_ID = Qry.Emp_ID
							AND ES.Effective_Date = Qry.For_Date
							AND Scheme_Id = @Scheme_ID
							AND Type = 'Over Time'
						INNER JOIN T0095_Increment I ON ES.EMP_ID = I.EMP_ID
						INNER JOIN (
							SELECT I1.EMP_ID
								,MAX(I1.Increment_ID) AS Increment_ID
							FROM T0095_Increment I1 WITH (NOLOCK)
							INNER JOIN (
								SELECT I2.EMP_ID
									,MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date
								FROM T0095_Increment I2 WITH (NOLOCK)
								WHERE I2.Increment_Effective_Date <= getdate()
								GROUP BY I2.Emp_ID
								) I2 ON I1.Emp_ID = I2.Emp_ID
								AND I1.Increment_Effective_Date = I2.Increment_Effective_Date
							GROUP BY I1.Emp_ID
							) I1 ON I1.Emp_ID = I.Emp_ID
							AND I1.Increment_ID = I.Increment_ID
						WHERE R_emp_id = @Emp_ID_Cur
							AND ES.Scheme_ID = @Scheme_ID
							AND
							--I.Cmp_ID = @Cmp_ID  AND 
							isnull(I.Grd_ID, 0) = isnull(@Grd_ID, I.Grd_ID)
							AND isnull(I.Dept_ID, 0) = isnull(@Dept_ID, isnull(I.Dept_ID, 0))

						----Ankit 19032015
						DECLARE @Cur_Cmp_ID NUMERIC

						SET @Cur_Cmp_ID = 0

						DECLARE Emp_Inout_Cur CURSOR FAST_FORWARD
						FOR
						SELECT DISTINCT Cmp_ID
						FROM #Emp_Cons1 EC
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID = E.EMP_ID

						OPEN Emp_Inout_Cur

						FETCH NEXT
						FROM Emp_Inout_Cur
						INTO @Cur_Cmp_ID

						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @CONSTRAINT = NULL

							--Added BY Jimit 10102018														
							SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EC.EMP_ID AS VARCHAR(18))
							FROM #EMP_CONS1 EC

							--Ended
							TRUNCATE TABLE #Data

							TRUNCATE TABLE #Data_Temp

							EXEC SP_CALCULATE_PRESENT_DAYS @Cur_Cmp_ID
								,@From_Date
								,@To_Date
								,0
								,0
								,0
								,0
								,0
								,0
								,0
								,@CONSTRAINT
								,4
								,''
								,0

							INSERT INTO #Data_Temp
							SELECT *
							FROM #data

							FETCH NEXT
							FROM Emp_Inout_Cur
							INTO @Cur_Cmp_ID
						END

						CLOSE Emp_Inout_Cur

						DEALLOCATE Emp_Inout_Cur

						TRUNCATE TABLE #DATA

						INSERT INTO #Data
						SELECT *
						FROM #Data_Temp

						----Ankit 19032015
						INSERT INTO #OT_APPROVAL
						SELECT isnull(Qry1.Tran_ID, 0) AS Tran_ID
							,DA.emp_ID
							,DA.For_date
							,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
							,dbo.F_Return_Hours(OT_SEc) AS OT_Hour
							,dbo.F_Return_Hours(isnull(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
							,dbo.F_Return_Hours(Holiday_OT_Sec) AS Holiday_OT_Hour
							,Da.P_days AS P_Days_Count
							,Flag
							,Shift_Start_Time
							,Shift_End_Time
							,In_Time
							,OUT_Time
						FROM #Data DA
						LEFT OUTER JOIN (
							SELECT lla.Tran_Id AS Tran_ID
								,lla.For_Date AS For_Date
								,lla.Emp_ID
								,Rpt_Level AS Rpt_Level
							FROM T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
							INNER JOIN (
								SELECT max(rpt_level) AS rpt_level1
									,Emp_ID
									,For_Date
								FROM T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK)
								WHERE For_Date IN (
										SELECT For_Date
										FROM #Data
										WHERE Emp_ID IN (
												SELECT emp_ID
												FROM #Emp_Cons1
												)
										)
									AND EXISTS (
										SELECT 1
										FROM #Data D
										WHERE D.Emp_Id = OTA.Emp_ID
										)
								GROUP BY Emp_ID
									,For_Date
								) Qry ON qry.For_Date = lla.For_Date
								AND Qry.Emp_ID = lla.Emp_ID
								AND qry.rpt_level1 = lla.rpt_level
							) AS Qry1 ON DA.For_Date = Qry1.For_Date
							AND DA.Emp_Id = Qry1.Emp_ID
						WHERE (
								OT_Sec > 0
								OR Weekoff_OT_Sec > 0
								OR Holiday_OT_Sec > 0
								)

						IF @Rpt_level = 1
						BEGIN
							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From #OT_APPROVAL LAD
													Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
													Where LAD.Tran_Id Not In 
													(		
															Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
															Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + '
													)'
						END
						ELSE
						BEGIN
							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From #OT_APPROVAL LAD Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
													  Where (LAD.Tran_Id Not In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + ')
																And LAD.Tran_Id In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS VARCHAR(2)) + '
																		)
															)'
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
								,@SCHEME_TYPE = 'Over Time'

							SET @Cur_Cmp_ID = 0

							DECLARE Emp_Inout_Cur CURSOR FAST_FORWARD
							FOR
							SELECT DISTINCT Cmp_ID
							FROM #EMP_CONS_RM EC
							INNER JOIN T0080_EMP_MASTER E ON EC.EMP_ID = E.EMP_ID

							OPEN Emp_Inout_Cur

							FETCH NEXT
							FROM Emp_Inout_Cur
							INTO @Cur_Cmp_ID

							WHILE @@FETCH_STATUS = 0
							BEGIN
								SET @CONSTRAINT = NULL

								--SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EC.EMP_ID AS VARCHAR(10))
								--FROM	(SELECT DISTINCT EMP_ID FROM #EMP_CONS_RM) EC 														
								--		INNER JOIN T0080_Emp_Master E ON E.Emp_ID=EC.Emp_ID
								--Where	E.Cmp_ID=@Cur_Cmp_ID
								--Added BY Jimit 10102018
								SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EC.EMP_ID AS VARCHAR(18))
								FROM #EMP_CONS_RM EC
								INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.EMP_ID = I.EMP_ID
								INNER JOIN (
									SELECT I1.EMP_ID
										,MAX(I1.INCREMENT_ID) AS INCREMENT_ID
									FROM T0095_INCREMENT I1 WITH (NOLOCK)
									INNER JOIN (
										SELECT I2.EMP_ID
											,MAX(I2.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
										FROM T0095_INCREMENT I2 WITH (NOLOCK)
										WHERE I2.INCREMENT_EFFECTIVE_DATE <= GetDAte()
										GROUP BY I2.EMP_ID
										) I2 ON I1.EMP_ID = I2.EMP_ID
										AND I1.INCREMENT_EFFECTIVE_DATE = I2.INCREMENT_EFFECTIVE_DATE
									GROUP BY I1.EMP_ID
									) I1 ON I1.EMP_ID = I.EMP_ID
									AND I1.INCREMENT_ID = I.INCREMENT_ID
								WHERE I.CMP_ID = @Cur_Cmp_ID
									AND ISNULL(I.GRD_ID, 0) = ISNULL(@GRD_ID, I.GRD_ID)
									AND ISNULL(I.DEPT_ID, 0) = ISNULL(@DEPT_ID, ISNULL(I.DEPT_ID, 0))

								--Ended
								--PRINT '3 : ' + @constraint
								TRUNCATE TABLE #Data

								TRUNCATE TABLE #Data_Temp

								EXEC SP_CALCULATE_PRESENT_DAYS @Cur_Cmp_ID
									,@From_Date
									,@To_Date
									,0
									,0
									,0
									,0
									,0
									,0
									,0
									,@CONSTRAINT
									,4
									,''
									,0

								INSERT INTO #Data_Temp
								SELECT *
								FROM #data

								FETCH NEXT
								FROM Emp_Inout_Cur
								INTO @Cur_Cmp_ID
							END

							CLOSE Emp_Inout_Cur

							DEALLOCATE Emp_Inout_Cur

							TRUNCATE TABLE #DATA

							INSERT INTO #DATA
							SELECT *
							FROM #Data_Temp

							INSERT INTO #OT_APPROVAL
							SELECT isnull(Qry1.Tran_ID, 0) AS Tran_ID
								,DA.emp_ID
								,DA.For_date
								,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
								,dbo.F_Return_Hours(OT_SEc) AS OT_Hour
								,dbo.F_Return_Hours(isnull(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
								,dbo.F_Return_Hours(Holiday_OT_Sec) AS Holiday_OT_Hour
								,Da.P_days AS P_Days_Count
								,Flag
								,Shift_Start_Time
								,Shift_End_Time
								,In_Time
								,OUT_Time
							FROM #Data DA
							LEFT OUTER JOIN (
								SELECT lla.Tran_Id AS Tran_ID
									,lla.For_Date AS For_Date
									,lla.Emp_ID
									,Rpt_Level AS Rpt_Level
								FROM T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
								INNER JOIN (
									SELECT max(rpt_level) AS rpt_level1
										,Emp_ID
										,For_Date
									FROM T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK)
									WHERE For_Date IN (
											SELECT For_Date
											FROM #Data
											WHERE Emp_ID IN (
													SELECT emp_ID
													FROM #EMP_CONS_RM
													)
											)
										AND EXISTS (
											SELECT 1
											FROM #Data D
											WHERE D.Emp_Id = OTA.Emp_ID
											)
									GROUP BY Emp_ID
										,For_Date
									) Qry ON qry.For_Date = lla.For_Date
									AND Qry.Emp_ID = lla.Emp_ID
									AND qry.rpt_level1 = lla.rpt_level
								) AS Qry1 ON DA.For_Date = Qry1.For_Date
								AND DA.Emp_Id = Qry1.Emp_ID
							WHERE (
									OT_Sec > 0
									OR Weekoff_OT_Sec > 0
									OR Holiday_OT_Sec > 0
									)

							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From	#OT_APPROVAL LAD Inner Join 
															#EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID 
															LEFT OUTER JOIN (SELECT Tran_Id,Emp_ID,S_Emp_ID FROM T0115_OT_LEVEL_APPROVAL LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																												ON LAD.Tran_Id=LA.Tran_Id And LAD.EMP_ID=LA.EMP_ID
													  Where (LAD.Tran_Id Not In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = EC.Rpt_Level )
																And LAD.Tran_Id In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = EC.Rpt_Level - 1 --AND Ec.R_Emp_Id = S_Emp_Id
																		)
															)'
								--PRINT @SqlQuery
						END
					END
							------------Ended-----------------	
					ELSE IF @is_rpt_manager = 0
						AND @is_branch_manager = 0
						AND @is_Reporting_To_Reporting_manager = 0
					BEGIN
						INSERT INTO #Emp_Cons1 (Emp_ID)
						SELECT ES.Emp_ID
						FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
						INNER JOIN (
							SELECT MAX(Effective_Date) AS For_Date
								,Emp_ID
							FROM T0095_EMP_SCHEME WITH (NOLOCK)
							WHERE Effective_Date <= GETDATE()
								AND Type = 'Over Time'
							GROUP BY emp_ID
							) Qry ON ES.Emp_ID = Qry.Emp_ID
							AND ES.Effective_Date = Qry.For_Date
							AND Scheme_Id = @Scheme_ID
							AND Type = 'Over Time'
						INNER JOIN T0095_Increment I WITH (NOLOCK) ON ES.EMP_ID = I.EMP_ID
						INNER JOIN (
							SELECT I1.EMP_ID
								,MAX(I1.Increment_ID) AS Increment_ID
							FROM T0095_Increment I1 WITH (NOLOCK)
							INNER JOIN (
								SELECT I2.EMP_ID
									,MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date
								FROM T0095_Increment I2 WITH (NOLOCK)
								WHERE I2.Increment_Effective_Date <= getdate()
								GROUP BY I2.Emp_ID
								) I2 ON I1.Emp_ID = I2.Emp_ID
								AND I1.Increment_Effective_Date = I2.Increment_Effective_Date
							GROUP BY I1.Emp_ID
							) I1 ON I1.Emp_ID = I.Emp_ID
							AND I1.Increment_ID = I.Increment_ID
						WHERE ES.Scheme_Id = @Scheme_ID
							AND
							--I.Cmp_ID = @Cmp_ID  AND 
							isnull(I.Grd_ID, 0) = isnull(@Grd_ID, I.Grd_ID)
							AND isnull(I.Dept_ID, 0) = isnull(@Dept_ID, isnull(I.Dept_ID, 0))

						SET @Cur_Cmp_ID = 0

						DECLARE Emp_Inout_Cur CURSOR FAST_FORWARD
						FOR
						SELECT DISTINCT Cmp_ID
						FROM #Emp_Cons1 EC
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID = E.EMP_ID

						OPEN Emp_Inout_Cur

						FETCH NEXT
						FROM Emp_Inout_Cur
						INTO @Cur_Cmp_ID

						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @CONSTRAINT = NULL

							--Added BY Jimit 10102018																	
							SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EC.EMP_ID AS VARCHAR(18))
							FROM #Emp_Cons1 EC

							--Ended
							TRUNCATE TABLE #Data

							TRUNCATE TABLE #Data_Temp

							EXEC SP_CALCULATE_PRESENT_DAYS @Cur_Cmp_ID
								,@From_Date
								,@To_Date
								,0
								,0
								,0
								,0
								,0
								,0
								,0
								,@CONSTRAINT
								,4
								,''
								,0

							INSERT INTO #Data_Temp --Ankit 19032015
							SELECT *
							FROM #data

							FETCH NEXT
							FROM Emp_Inout_Cur
							INTO @Cur_Cmp_ID
						END

						CLOSE Emp_Inout_Cur

						DEALLOCATE Emp_Inout_Cur

						TRUNCATE TABLE #DATA

						INSERT INTO #Data --Ankit 19032015
						SELECT *
						FROM #Data_Temp

						INSERT INTO #OT_APPROVAL
						SELECT isnull(Qry1.Tran_ID, 0) AS Tran_ID
							,DA.emp_ID
							,DA.For_date
							,dbo.F_Return_Hours(Duration_in_Sec) AS Working_Hour
							,dbo.F_Return_Hours(OT_SEc) AS OT_Hour
							,dbo.F_Return_Hours(isnull(Weekoff_OT_Sec, 0)) AS Weekoff_OT_Hour
							,dbo.F_Return_Hours(Holiday_OT_Sec) AS Holiday_OT_Hour
							,Da.P_days AS P_Days_Count
							,Flag
							,Shift_Start_Time
							,Shift_End_Time
							,In_Time
							,OUT_Time
						FROM #Data DA
						LEFT OUTER JOIN (
							SELECT lla.Tran_Id AS Tran_ID
								,lla.For_Date AS For_Date
								,lla.Emp_ID
								,Rpt_Level AS Rpt_Level
							FROM T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
							INNER JOIN (
								SELECT max(rpt_level) AS rpt_level1
									,OLT.Emp_ID
									,OLT.For_Date
								FROM T0115_OT_LEVEL_APPROVAL OLT WITH (NOLOCK)
								INNER JOIN #Emp_Cons1 EC ON EC.Emp_ID = OLT.Emp_ID
								INNER JOIN #DAta SDA ON SDA.Emp_ID = OLT.Emp_ID
									AND SDA.For_Date = OLT.For_Date
								GROUP BY OLT.Emp_ID
									,OLT.For_Date
								) Qry ON qry.For_Date = lla.For_Date
								AND Qry.Emp_ID = lla.Emp_ID
								AND qry.rpt_level1 = lla.rpt_level
							) AS Qry1 ON DA.For_Date = Qry1.For_Date
							AND DA.Emp_Id = Qry1.Emp_ID
						WHERE (
								OT_Sec > 0
								OR Weekoff_OT_Sec > 0
								OR Holiday_OT_Sec > 0
								)

						IF @Rpt_level = 1
						BEGIN
							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From #OT_APPROVAL LAD Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
															  Where LAD.Tran_Id Not In 
															  (
																Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) Where Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + '
															   )'
						END
						ELSE
						BEGIN
							SET @SqlQuery = 'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ' + cast(@Rpt_level AS VARCHAR(2)) + ' From #OT_APPROVAL LAD Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
														   Where (LAD.Tran_Id Not In (
																						Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) Where 
																						 Rpt_Level = ' + Cast(@Rpt_level AS VARCHAR(2)) + '
																					  ) And LAD.Tran_Id 
																					In (
																						Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																						Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS VARCHAR(2)) + '
																						)
																 )'
						END
					END

					--select 202
					INSERT INTO #tbl_Leave_App (
						Emp_Id
						,For_Date
						,Scheme_ID
						,rpt_level
						)
					EXEC (@SqlQuery)

					--select 313
					DELETE
					FROM #Data

					DELETE
					FROM #Emp_Cons1

					--Drop Table #Emp_Cons1
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

				SET @Rpt_level = @Rpt_level + 1
			END
		END

		IF OBJECT_ID('tempdb..#OVERTIME') IS NOT NULL
		BEGIN
			DROP TABLE #OVERTIME
		END

		--Added By Jimit 22102018
		CREATE TABLE #OVERTIME (
			Tran_Id NUMERIC(18, 0) IDENTITY
			,Cmp_ID NUMERIC(18, 0)
			,Emp_ID NUMERIC(18, 0)
			,Alpha_Emp_code NVARCHAR(100)
			,For_DATE DATETIME
			,Emp_Full_Name NVARCHAR(200)
			,Working_Hour VARCHAR(10)
			,Ot_Hour VARCHAR(10)
			,Flag NUMERIC(18, 0)
			,Weekoff_OT_Hour VARCHAR(10)
			,Holiday_OT_Hour VARCHAR(10)
			,P_Days_Count NUMERIC(18, 2)
			,Final_Approver TINYINT
			,Is_Fwd_OT_Rej TINYINT
			,rpt_level TINYINT
			,Approved_OT_Hour VARCHAR(10)
			,Approved_Weekoff_OT_Hour VARCHAR(10)
			,Approved_HO_OT_Hour VARCHAR(10)
			,Is_Approved TINYINT
			,Editable_Records TINYINT
			,Remark VARCHAR(500)
			,Final_Tran_ID NUMERIC(18, 0)
			,Shift_Start_Time DATETIME
			,Shift_End_Time DATETIME
			,In_Time DATETIME
			,Out_Time DATETIME
			,Comment VARCHAR(1000) DEFAULT ''
			)

		INSERT INTO #OVERTIME
		SELECT DISTINCT EM.Cmp_ID
			,DA.emp_ID
			,EM.Alpha_EMP_CODE
			,DA.For_date
			,EM.Emp_Full_Name
			,Working_Hour
			,OT_Hour
			,Flag
			,Weekoff_OT_Hour
			,Holiday_OT_Hour
			,DA.P_Days_Count
			,SL.Final_Approver
			,SL.Is_Fwd_Leave_Rej AS Is_Fwd_OT_Rej
			,SL.rpt_level
			,
			--Commented By Jimit 29112019
			CASE 
				WHEN SL.Rpt_Level = 1
					THEN (
							CASE 
								WHEN isnull(Qry1.Approved_OT_Sec, 0) = 0
									THEN OT_Hour
								ELSE dbo.F_Return_Hours(Qry1.Approved_OT_Sec)
								END
							)
				ELSE dbo.F_Return_Hours(Qry1.Approved_OT_Sec)
				END AS Approved_OT_Hour
			,CASE 
				WHEN SL.Rpt_Level = 1
					THEN (
							CASE 
								WHEN ISNULL(Qry1.Approved_WO_OT_Sec, 0) = 0
									THEN Weekoff_OT_Hour
								ELSE dbo.F_Return_Hours(Qry1.Approved_WO_OT_Sec)
								END
							)
				ELSE dbo.F_Return_Hours(Qry1.Approved_WO_OT_Sec)
				END AS Approved_Weekoff_OT_Hour
			,CASE 
				WHEN SL.Rpt_Level = 1
					THEN (
							CASE 
								WHEN isnull(qry1.Approved_HO_OT_Sec, 0) = 0
									THEN Holiday_OT_Hour
								ELSE dbo.F_Return_Hours(Qry1.Approved_HO_OT_Sec)
								END
							)
				ELSE dbo.F_Return_Hours(Qry1.Approved_HO_OT_Sec)
				END AS Approved_HO_OT_Hour
			,
			--Ended
			--changed By Jimit 29112019 For solving the redmine bug 4699 for getting actual OT approved hours at second level
			--dbo.F_Return_Hours(Qry1.Approved_OT_Sec)  as Approved_OT_Hour ,
			--dbo.F_Return_Hours(Qry1.Approved_WO_OT_Sec) as Approved_Weekoff_OT_Hour ,
			--dbo.F_Return_Hours(Qry1.Approved_HO_OT_Sec)  as Approved_HO_OT_Hour,
			--Ended
			CASE 
				WHEN ISNULL(qry1.is_Approved, 1) = 1
					THEN 1
				ELSE qry1.is_approved
				END AS Is_Approved
			,1 AS Editable_Records
			,CASE 
				WHEN isnull(qry1.Remark, '') = ''
					THEN ''
				ELSE Qry1.Remark
				END AS Remark
			,0 AS Final_Tran_ID
			,Shift_Start_Time
			,Shift_End_Time
			,In_Time
			,Out_Time
			,qry1.Comments --Added By Jimit 04092018											
		FROM #OT_APPROVAL DA
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON DA.Emp_ID = EM.Emp_ID
		LEFT OUTER JOIN (
			SELECT lla.Tran_Id AS App_ID
				,IsNull(Rpt_Level, 0) AS Rpt_Level
				,Approved_OT_Sec
				,Approved_WO_OT_Sec
				,Approved_HO_OT_Sec
				,Remark
				,is_approved
				,lla.Comments
				,lla.For_Date
				,lla.Emp_ID
			FROM T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
			INNER JOIN (
				SELECT max(rpt_level) AS rpt_level1
					,Emp_Id
					,For_Date
				FROM T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
				--Where Tran_Id In (Select Leave_App_ID From #tbl_Leave_App) 
				GROUP BY Emp_Id
					,For_Date
				) Qry ON qry.For_Date = lla.For_Date
				AND qry.rpt_level1 = lla.rpt_level
				AND qry.Emp_ID = lla.Emp_ID
			) AS Qry1 ON DA.Emp_Id = Qry1.Emp_ID
			AND DA.For_date = Qry1.For_Date --DA.Tran_Id = Qry1.App_ID	
		INNER JOIN #tbl_Leave_App TLAP ON TLAP.For_Date = da.For_date
			AND TLAP.Emp_Id = Da.Emp_Id
		INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID
			AND SL.rpt_level > isnull(Qry1.Rpt_Level, 0)
			AND SL.rpt_level = TLAP.rpt_level
		LEFT OUTER JOIN #Responsiblity_Passed RP ON RP.Emp_ID = EM.Emp_ID
		WHERE -- DA.Tran_Id In (Select distinct Leave_App_ID From #tbl_Leave_App) And
			NOT EXISTS (
				SELECT 1
				FROM T0160_OT_APPROVAL WITH (NOLOCK)
				WHERE Emp_ID = Da.Emp_Id
					AND For_Date = Da.For_date
				)
			AND NOT EXISTS (
				SELECT 1
				FROM T0120_CompOff_Approval WITH (NOLOCK)
				WHERE Emp_ID = DA.Emp_Id
					AND Extra_Work_Date = DA.For_date
					AND Approve_Status = 'A'
				)
		ORDER BY DA.For_date

		FETCH NEXT
		FROM Employee_Cur
		INTO @Emp_ID_Cur
			,@is_res_passed
	END

	CLOSE Employee_Cur

	DEALLOCATE Employee_Cur

	--Added By Jimit 22102018
	DELETE OT
	FROM #OVERTIME OT
	INNER JOIN T0095_INCREMENT IE ON IE.EMP_ID = OT.EMP_ID
	INNER JOIN (
		SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID
			,I2.EMP_ID
		FROM T0095_INCREMENT I2 WITH (NOLOCK)
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID = E.EMP_ID
		INNER JOIN (
			SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
				,I3.EMP_ID
			FROM T0095_INCREMENT I3 WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID = E3.EMP_ID
			WHERE I3.INCREMENT_EFFECTIVE_DATE <= GETDATE()
				AND
				--I3.CMP_ID = @Cmp_Id AND 
				I3.INCREMENT_TYPE NOT IN (
					'TRANSFER'
					,'DEPUTATION'
					)
			GROUP BY I3.EMP_ID
			) I3 ON I2.INCREMENT_EFFECTIVE_DATE = I3.INCREMENT_EFFECTIVE_DATE
			AND I2.EMP_ID = I3.EMP_ID
		WHERE I2.INCREMENT_TYPE NOT IN (
				'TRANSFER'
				,'DEPUTATION'
				)
		GROUP BY I2.EMP_ID
		) I ON IE.EMP_ID = I.EMP_ID
		AND IE.INCREMENT_ID = I.INCREMENT_ID
	WHERE (
			(
				IE.EMP_HOLIDAY_OT_RATE = 0
				AND HOLIDAY_OT_HOUR <> '00:00'
				)
			OR (
				IE.EMP_WEEKOFF_OT_RATE = 0
				AND WEEKOFF_OT_HOUR <> '00:00'
				)
			OR (
				IE.EMP_WEEKDAY_OT_RATE = 0
				AND OT_HOUR <> '00:00'
				)
			)

	DECLARE @Setting_Value AS INT

	IF @Type = 0
	BEGIN
		--SELECT dbo.F_Get_OT_QUARTERLYHOURS(24471,'2020-09-10')
		SELECT *
			,dbo.F_Get_OT_QUARTERLYHOURS(Emp_ID, For_DATE) AS TOT_Qtr_Hours
		FROM #OVERTIME
		ORDER BY --TOT_Qtr_Hours DESC
			#OVERTIME.Emp_ID,For_DATE ASC
	END
	ELSE IF @Type = 1
	BEGIN
		SELECT @Setting_Value = Setting_Value
		FROM T0040_SETTING
		WHERE Setting_Name = 'Add number of Hours to restrict OT Approval'
			AND cmp_Id = @cmp_id

		IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
		BEGIN
			TRUNCATE TABLE #Notification_Value

			IF (@Setting_Value > 0)
			BEGIN
				--SELECT * FROM #OVERTIME WHERE CONVERT(VARCHAR(15),For_DATE,103)=CONVERT(VARCHAR(15),GETDATE(),103)
				INSERT INTO #Notification_Value
				SELECT COUNT(1) AS OTCOUNT
				FROM #OVERTIME
				WHERE CONVERT(VARCHAR(15), For_DATE, 103) = CONVERT(VARCHAR(15), GETDATE(), 103)
			END
			ELSE
			BEGIN
				INSERT INTO #Notification_Value
				SELECT COUNT(1) AS OTCOUNT
				FROM #OVERTIME
			END
		END
		ELSE
			SELECT COUNT(1) AS OTCOUNT
			FROM #OVERTIME
	END
	ELSE IF @Type = 2
	BEGIN
		INSERT INTO #PENDING_OVERTIME
		SELECT Cmp_ID
			,Emp_ID
			,Alpha_Emp_code
			,For_DATE
			,Emp_Full_Name
			,Working_Hour
			,OT_Hour
			,Weekoff_OT_Hour
			,Holiday_OT_Hour
		FROM #OVERTIME
		ORDER BY #OVERTIME.Emp_ID ASC
	END

	--Ended
	DROP TABLE #tbl_Scheme_Leave

	DROP TABLE #tbl_Leave_App

	DROP TABLE #Responsiblity_Passed

	DROP TABLE #Data

	DROP TABLE #Approved_OT

	DROP TABLE #OVERTIME

	DROP TABLE #Emp_Cons1
		----drop TABLE #Leave
END