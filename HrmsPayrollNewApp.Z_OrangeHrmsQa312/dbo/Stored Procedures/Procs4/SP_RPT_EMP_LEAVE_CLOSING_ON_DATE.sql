CREATE PROCEDURE [dbo].[SP_RPT_EMP_LEAVE_CLOSING_ON_DATE] 
	@Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_Id NUMERIC
	,@Desig_Id NUMERIC
	,@Emp_ID NUMERIC
	,@Leave_ID NUMERIC
	,@Constraint VARCHAR(MAX)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

CREATE TABLE #Emp_Leave_Bal (
	Cmp_ID NUMERIC
	,Emp_ID NUMERIC
	,For_Date DATETIME
	,Leave_Closing_1 NUMERIC(18, 2)
	,Leave_Closing_2 NUMERIC(18, 2)
	,Leave_Closing_3 NUMERIC(18, 2)
	,Leave_Closing_4 NUMERIC(18, 2)
	,Leave_Closing_5 NUMERIC(18, 2)
	,Leave_Name_1 VARCHAR(50)
	,Leave_Name_2 VARCHAR(50)
	,Leave_Name_3 VARCHAR(50)
	,Leave_Name_4 VARCHAR(50)
	,Leave_Name_5 VARCHAR(50)
	)

IF @Branch_ID = 0
	SET @Branch_ID = NULL

IF @Cat_ID = 0
	SET @Cat_ID = NULL

IF @Type_ID = 0
	SET @Type_ID = NULL

IF @Dept_ID = 0
	SET @Dept_ID = NULL

IF @Grd_ID = 0
	SET @Grd_ID = NULL

IF @Desig_ID = 0
	SET @Desig_ID = NULL

IF @Emp_ID = 0
	SET @Emp_ID = NULL

IF @Leave_ID = 0
	SET @Leave_ID = NULL

DECLARE @Emp_Cons TABLE (Emp_ID NUMERIC)

IF @Constraint <> ''
BEGIN
	INSERT INTO #Emp_Leave_Bal (
		Cmp_Id
		,Emp_Id
		,For_Date
		)
	SELECT @Cmp_ID
		,cast(data AS NUMERIC)
		,@From_Date
	FROM dbo.Split(@Constraint, '#')
END
ELSE
BEGIN
	INSERT INTO #Emp_Leave_Bal (
		Cmp_Id
		,Emp_Id
		,For_Date
		)
	SELECT @Cmp_ID
		,I.Emp_Id
		,@From_Date
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT max(Increment_ID) AS Increment_ID
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @Cmp_ID
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_ID = Qry.Increment_ID
	WHERE Cmp_ID = @Cmp_ID
		AND Isnull(Cat_ID, 0) = Isnull(@Cat_ID, Isnull(Cat_ID, 0))
		AND Branch_ID = isnull(@Branch_ID, Branch_ID)
		AND Grd_ID = isnull(@Grd_ID, Grd_ID)
		AND isnull(Dept_ID, 0) = isnull(@Dept_ID, isnull(Dept_ID, 0))
		AND Isnull(Type_ID, 0) = isnull(@Type_ID, Isnull(Type_ID, 0))
		AND Isnull(Desig_ID, 0) = isnull(@Desig_ID, Isnull(Desig_ID, 0))
		AND I.Emp_ID = isnull(@Emp_ID, I.Emp_ID)
		AND I.Emp_ID IN (
			SELECT Emp_Id
			FROM (
				SELECT emp_id
					,cmp_ID
					,join_Date
					,isnull(left_Date, @To_date) AS left_Date
				FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)
				) qry
			WHERE cmp_ID = @Cmp_ID
				AND (
					(
						@From_Date >= join_Date
						AND @From_Date <= left_date
						)
					OR (
						@To_Date >= join_Date
						AND @To_Date <= left_date
						)
					OR Left_date IS NULL
					AND @To_Date >= Join_Date
					)
				OR @To_Date >= left_date
				AND @From_Date <= left_date
			)
END

CREATE TABLE #temp_CompOff (
	Leave_opening DECIMAL(18, 2)
	,Leave_Used DECIMAL(18, 2)
	,Leave_Closing DECIMAL(18, 2)
	,Leave_Code VARCHAR(max)
	,Leave_Name VARCHAR(max)
	,Leave_ID NUMERIC
	,CompOff_String VARCHAR(max) DEFAULT NULL -- Added by Gadriwala 18022015
	)

CREATE TABLE #temp_Leave (
	Row_ID NUMERIC(18, 0) identity
	,Leave_ID NUMERIC(18, 0)
	,Leave_Code VARCHAR(25)
	,Default_Short_Name VARCHAR(25)
	)

INSERT INTO #temp_Leave
SELECT TOP 5 isnull(Leave_ID, 0)
	,Leave_Code
	,isnull(Default_Short_Name, '')
FROM T0040_LEAVE_MASTER WITH (NOLOCK)
WHERE (
		1 = (
			CASE isnull(leave_Status, 0)
				WHEN 0
					THEN (
							CASE 
								WHEN isnull(InActive_Effective_Date, @To_Date) > @To_Date
									THEN 1
								ELSE 0
								END
							)
				ELSE 1
				END
			)
		)
	AND Cmp_ID = @Cmp_ID
ORDER BY Leave_Sorting_No ASC

IF @Leave_Id IS NULL
BEGIN
	DECLARE @Default_Short_Name AS VARCHAR(25)
	DECLARE @compOff_Leave_ID AS NUMERIC(18, 0)
	DECLARE @Leave_Emp_ID NUMERIC(18, 0)

	SET @Default_Short_Name = ''

	SELECT @Default_Short_Name = ISNULL(Default_Short_Name, '')
		,@compOff_Leave_ID = Leave_ID
	FROM #temp_Leave
	WHERE Row_ID = 1

	IF @Default_Short_Name = 'COMP'
	BEGIN
		DECLARE curCompOffBalance CURSOR
		FOR
		SELECT Emp_ID
		FROM #Emp_Leave_Bal
		ORDER BY Emp_ID

		OPEN curCompOffBalance

		FETCH NEXT
		FROM curCompOffBalance
		INTO @Leave_Emp_ID

		WHILE @@fetch_status = 0
		BEGIN
			DELETE
			FROM #temp_CompOff

			EXEC GET_COMPOFF_DETAILS @To_Date
				,@Cmp_ID
				,@Leave_Emp_ID
				,@compOff_Leave_ID
				,0
				,0
				,2

			UPDATE #Emp_Leave_Bal
			SET Leave_Closing_1 = isnull(tc.Leave_Closing, 0)
				,Leave_Name_1 = tc.Leave_Code
			FROM #temp_CompOff tc
			WHERE Emp_ID = @Leave_Emp_ID

			FETCH NEXT
			FROM curCompOffBalance
			INTO @Leave_Emp_ID
		END

		CLOSE curCompOffBalance

		DEALLOCATE curCompOffBalance
	END
	ELSE
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Closing_1 = leave_Bal.Leave_Closing
			,Leave_Name_1 = LeavE_Code
		FROM #Emp_Leave_Bal LB
		INNER JOIN (
			SELECT lt.Emp_Id
				,lt.LeavE_Id
				,LeavE_Closing
				,LeavE_Code
			FROM T0140_leave_Transaction LT WITH (NOLOCK)
			INNER JOIN (
				SELECT max(For_Date) For_Date
					,Emp_ID
					,lt.leave_ID
					,Lm.LeavE_Code
				FROM T0140_leave_Transaction lt WITH (NOLOCK)
				INNER JOIN T0040_LEave_Master lm WITH (NOLOCK) ON lt.leavE_ID = lm.leave_ID
				INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
					AND Row_ID = 1
				WHERE For_date <= @To_Date
					AND lt.Cmp_ID = @Cmp_ID
					AND lt.cmp_ID = @Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from									-- Changed By Gadriwala Muslim 01102014 for CompOff
										(select top 1 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
										)*/
				GROUP BY Emp_ID
					,lt.LEave_ID
					,Lm.LeavE_Code
				) q ON Lt.Emp_Id = Q.Emp_ID
				AND lt.For_Date = Q.For_Date
				AND lt.Leave_ID = Q.LEave_ID
			) Leave_Bal ON LB.Emp_ID = leave_Bal.Emp_ID
	END

	SET @Default_Short_Name = ''

	SELECT @Default_Short_Name = ISNULL(Default_Short_Name, '')
		,@compOff_Leave_ID = Leave_ID
	FROM #temp_Leave
	WHERE Row_ID = 2

	IF @Default_Short_Name = 'COMP'
	BEGIN
		DECLARE curCompOffBalance CURSOR
		FOR
		SELECT Emp_ID
		FROM #Emp_Leave_Bal
		ORDER BY Emp_ID

		OPEN curCompOffBalance

		FETCH NEXT
		FROM curCompOffBalance
		INTO @Leave_Emp_ID

		WHILE @@fetch_status = 0
		BEGIN
			DELETE
			FROM #temp_CompOff

			EXEC GET_COMPOFF_DETAILS @To_Date
				,@Cmp_ID
				,@Leave_Emp_ID
				,@compOff_Leave_ID
				,0
				,0
				,2

			UPDATE #Emp_Leave_Bal
			SET Leave_Closing_2 = isnull(tc.Leave_Closing, 0)
				,Leave_Name_2 = tc.Leave_Code
			FROM #temp_CompOff tc
			WHERE Emp_ID = @Leave_Emp_ID

			FETCH NEXT
			FROM curCompOffBalance
			INTO @Leave_Emp_ID
		END

		CLOSE curCompOffBalance

		DEALLOCATE curCompOffBalance
	END
	ELSE
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Closing_2 = leave_Bal.Leave_Closing
			,Leave_Name_2 = LeavE_Code
		FROM #Emp_Leave_Bal LB
		INNER JOIN (
			SELECT lt.Emp_Id
				,lt.LeavE_Id
				,LeavE_Closing
				,LeavE_Code
			FROM T0140_leave_Transaction LT WITH (NOLOCK)
			INNER JOIN (
				SELECT max(For_Date) For_Date
					,Emp_ID
					,lt.leave_ID
					,LM.LeavE_Code
				FROM T0140_leave_Transaction lt WITH (NOLOCK)
				INNER JOIN T0040_LEave_Master lm WITH (NOLOCK) ON lt.leavE_ID = lm.leave_ID
				INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
					AND Row_ID = 2
				WHERE For_date <= @To_Date
					AND lt.Cmp_ID = @Cmp_ID
					AND lt.cmp_ID = @Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from						-- Changed By Gadriwala Muslim 01102014 for CompOff
									(select top 2 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
									)*/
				GROUP BY Emp_ID
					,lt.LEave_ID
					,Lm.LeavE_Code
				) q ON Lt.Emp_Id = Q.Emp_ID
				AND lt.For_Date = Q.For_Date
				AND lt.Leave_ID = Q.LEave_ID
			) Leave_Bal ON LB.Emp_ID = leave_Bal.Emp_ID
	END

	SET @Default_Short_Name = ''

	SELECT @Default_Short_Name = ISNULL(Default_Short_Name, '')
		,@compOff_Leave_ID = Leave_ID
	FROM #temp_Leave
	WHERE Row_ID = 3

	IF @Default_Short_Name = 'COMP'
	BEGIN
		DECLARE curCompOffBalance CURSOR
		FOR
		SELECT Emp_ID
		FROM #Emp_Leave_Bal
		ORDER BY Emp_ID

		OPEN curCompOffBalance

		FETCH NEXT
		FROM curCompOffBalance
		INTO @Leave_Emp_ID

		WHILE @@fetch_status = 0
		BEGIN
			DELETE
			FROM #temp_CompOff

			EXEC GET_COMPOFF_DETAILS @To_Date
				,@Cmp_ID
				,@Leave_Emp_ID
				,@compOff_Leave_ID
				,0
				,0
				,2

			UPDATE #Emp_Leave_Bal
			SET Leave_Closing_3 = isnull(tc.Leave_Closing, 0)
				,Leave_Name_3 = tc.Leave_Code
			FROM #temp_CompOff tc
			WHERE Emp_ID = @Leave_Emp_ID

			FETCH NEXT
			FROM curCompOffBalance
			INTO @Leave_Emp_ID
		END

		CLOSE curCompOffBalance

		DEALLOCATE curCompOffBalance
	END
	ELSE
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Closing_3 = leave_Bal.Leave_Closing
			,Leave_Name_3 = LeavE_Code
		FROM #Emp_Leave_Bal LB
		INNER JOIN (
			SELECT lt.Emp_Id
				,lt.LeavE_Id
				,LeavE_Closing
				,LeavE_Code
			FROM T0140_leave_Transaction LT WITH (NOLOCK)
			INNER JOIN (
				SELECT max(For_Date) For_Date
					,Emp_ID
					,lt.leave_ID
					,LM.LeavE_Code
				FROM T0140_leave_Transaction lt WITH (NOLOCK)
				INNER JOIN T0040_LEave_Master lm WITH (NOLOCK) ON lt.leavE_ID = lm.leave_ID
				INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
					AND Row_ID = 3
				WHERE For_date <= @To_Date
					AND lt.Cmp_ID = @Cmp_ID
					AND lt.cmp_ID = @Cmp_ID /* and lm.Leave_ID in (select top 1 leave_id from							-- Changed By Gadriwala Muslim 01102014 for CompOff
									(select top 3 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
									)*/
				GROUP BY Emp_ID
					,lt.LEave_ID
					,Lm.LeavE_Code
				) q ON Lt.Emp_Id = Q.Emp_ID
				AND lt.For_Date = Q.For_Date
				AND lt.Leave_ID = Q.LEave_ID
			) Leave_Bal ON LB.Emp_ID = leave_Bal.Emp_ID
	END

	SET @Default_Short_Name = ''

	SELECT @Default_Short_Name = ISNULL(Default_Short_Name, '')
		,@compOff_Leave_ID = Leave_ID
	FROM #temp_Leave
	WHERE Row_ID = 4

	IF @Default_Short_Name = 'COMP'
	BEGIN
		DECLARE curCompOffBalance CURSOR
		FOR
		SELECT Emp_ID
		FROM #Emp_Leave_Bal
		ORDER BY Emp_ID

		OPEN curCompOffBalance

		FETCH NEXT
		FROM curCompOffBalance
		INTO @Leave_Emp_ID

		WHILE @@fetch_status = 0
		BEGIN
			DELETE
			FROM #temp_CompOff

			--exec GET_COMPOFF_DETAILS @To_Date,@Cmp_ID,@Leave_Emp_ID,@compOff_Leave_ID,0,0,2	
			UPDATE #Emp_Leave_Bal
			SET Leave_Closing_4 = isnull(tc.Leave_Closing, 0)
				,Leave_Name_4 = tc.Leave_Code
			FROM #temp_CompOff tc
			WHERE Emp_ID = @Leave_Emp_ID

			FETCH NEXT
			FROM curCompOffBalance
			INTO @Leave_Emp_ID
		END

		CLOSE curCompOffBalance

		DEALLOCATE curCompOffBalance
	END
	ELSE
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Closing_4 = leave_Bal.Leave_Closing
			,Leave_Name_4 = LeavE_Code
		FROM #Emp_Leave_Bal LB
		INNER JOIN (
			SELECT lt.Emp_Id
				,lt.LeavE_Id
				,LeavE_Closing
				,LeavE_Code
			FROM T0140_leave_Transaction LT WITH (NOLOCK)
			INNER JOIN (
				SELECT max(For_Date) For_Date
					,Emp_ID
					,lt.leave_ID
					,lm.LeavE_Code
				FROM T0140_leave_Transaction lt WITH (NOLOCK)
				INNER JOIN T0040_LEave_Master lm WITH (NOLOCK) ON lt.leavE_ID = lm.leave_ID
				INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
					AND Row_ID = 4
				WHERE For_date <= @To_Date
					AND lt.Cmp_ID = @Cmp_ID
					AND lt.cmp_ID = @Cmp_ID /*and lm.Leave_ID in (select top 1 leave_id from								-- Changed By Gadriwala Muslim 01102014 for CompOff
									(select top 4 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
									)*/
				GROUP BY Emp_ID
					,lt.LEave_ID
					,lm.LeavE_Code
				) q ON Lt.Emp_Id = Q.Emp_ID
				AND lt.For_Date = Q.For_Date
				AND lt.Leave_ID = Q.LEave_ID
			) Leave_Bal ON LB.Emp_ID = leave_Bal.Emp_ID
	END

	SET @Default_Short_Name = ''

	SELECT @Default_Short_Name = ISNULL(Default_Short_Name, '')
		,@compOff_Leave_ID = Leave_ID
	FROM #temp_Leave
	WHERE Row_ID = 5

	IF @Default_Short_Name = 'COMP'
	BEGIN
		DECLARE curCompOffBalance CURSOR
		FOR
		SELECT Emp_ID
		FROM #Emp_Leave_Bal
		ORDER BY Emp_ID

		OPEN curCompOffBalance

		FETCH NEXT
		FROM curCompOffBalance
		INTO @Leave_Emp_ID

		WHILE @@fetch_status = 0
		BEGIN
			DELETE
			FROM #temp_CompOff

			EXEC GET_COMPOFF_DETAILS @To_Date
				,@Cmp_ID
				,@Leave_Emp_ID
				,@compOff_Leave_ID
				,0
				,0
				,2

			UPDATE #Emp_Leave_Bal
			SET Leave_Closing_5 = isnull(tc.Leave_Closing, 0)
				,Leave_Name_5 = Leave_Code
			FROM #temp_CompOff tc
			WHERE Emp_ID = @Leave_Emp_ID

			FETCH NEXT
			FROM curCompOffBalance
			INTO @Leave_Emp_ID
		END

		CLOSE curCompOffBalance

		DEALLOCATE curCompOffBalance
	END
	ELSE
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Closing_5 = leave_Bal.Leave_Closing
			,Leave_Name_5 = LeavE_Code
		FROM #Emp_Leave_Bal LB
		INNER JOIN (
			SELECT lt.Emp_Id
				,lt.LeavE_Id
				,LeavE_Closing
				,LeavE_Code
			FROM T0140_leave_Transaction LT WITH (NOLOCK)
			INNER JOIN (
				SELECT max(For_Date) For_Date
					,Emp_ID
					,lt.leave_ID
					,lm.LeavE_Code
				FROM T0140_leave_Transaction lt WITH (NOLOCK)
				INNER JOIN T0040_LEave_Master lm WITH (NOLOCK) ON lt.leavE_ID = lm.leave_ID
				INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
					AND Row_ID = 5
				WHERE For_date <= @To_Date
					AND lt.Cmp_ID = @Cmp_ID
					AND lt.cmp_ID = @Cmp_ID /*and lm.Leave_ID in (/*select top 1 leave_id from						-- Changed By Gadriwala Muslim 01102014 for CompOff
								(select top 5 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end ))  and Cmp_ID=@Cmp_ID order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
								*/ select leave_ID from #temp_Leave where Row_ID = 5)*/
				GROUP BY Emp_ID
					,lt.LEave_ID
					,lm.LeavE_Code
				) q ON Lt.Emp_Id = Q.Emp_ID
				AND lt.For_Date = Q.For_Date
				AND lt.Leave_ID = Q.LEave_ID
			) Leave_Bal ON LB.Emp_ID = leave_Bal.Emp_ID
	END
END
ELSE
BEGIN
	IF EXISTS (
			SELECT 1
			FROM T0040_LEAVE_MASTER WITH (NOLOCK)
			WHERE Leave_ID = @Leave_ID
				AND isnull(Default_Short_Name, '') = 'COMP'
			)
	BEGIN
		DECLARE @L_Emp_ID NUMERIC(18, 0)

		DECLARE curCompOffBalance CURSOR
		FOR
		SELECT Emp_ID
		FROM #Emp_Leave_Bal
		ORDER BY Emp_ID

		OPEN curCompOffBalance

		FETCH NEXT
		FROM curCompOffBalance
		INTO @L_Emp_ID

		WHILE @@fetch_status = 0
		BEGIN
			DELETE
			FROM #temp_CompOff

			EXEC GET_COMPOFF_DETAILS @To_Date
				,@Cmp_ID
				,@L_Emp_ID
				,@Leave_ID
				,0
				,0
				,2

			UPDATE #Emp_Leave_Bal
			SET Leave_Closing_1 = isnull(tc.Leave_Closing, 0)
			FROM #temp_CompOff tc
			WHERE Emp_ID = @L_Emp_ID

			FETCH NEXT
			FROM curCompOffBalance
			INTO @L_Emp_ID
		END

		CLOSE curCompOffBalance

		DEALLOCATE curCompOffBalance
	END
	ELSE
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Closing_1 = leave_Bal.Leave_Closing
			,Leave_Name_1 = LeavE_Code
		FROM #Emp_Leave_Bal LB
		INNER JOIN (
			SELECT lt.Emp_Id
				,lt.LeavE_Id
				,LeavE_Closing
				,LeavE_Code
			FROM T0140_leave_Transaction LT WITH (NOLOCK)
			INNER JOIN (
				SELECT max(For_Date) For_Date
					,Emp_ID
					,lt.leave_ID
					,LeavE_Code
				FROM T0140_leave_Transaction lt WITH (NOLOCK)
				INNER JOIN T0040_LEave_Master lm WITH (NOLOCK) ON lt.leavE_ID = lm.leave_ID
				WHERE For_date <= @To_Date
					AND lt.Cmp_ID = @Cmp_ID
					AND lt.cmp_ID = @Cmp_ID
					AND lm.Leave_ID = isnull(@Leave_ID, lm.Leave_ID)
					AND isnull(Default_Short_Name, '') <> 'COMP' -- Changed By Gadriwala Muslim 01102014
				GROUP BY Emp_ID
					,lt.LEave_ID
					,LeavE_Code
				) q ON Lt.Emp_Id = Q.Emp_ID
				AND lt.For_Date = Q.For_Date
				AND lt.Leave_ID = Q.LEave_ID
			) Leave_Bal ON LB.Emp_ID = leave_Bal.Emp_ID
	END
END

IF @Leave_ID IS NULL
BEGIN
	IF EXISTS (
			SELECT emp_ID
			FROM #Emp_Leave_Bal
			WHERE isnull(Leave_Name_1, '') = ''
			)
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Name_1 = q.Leave_Code
		FROM #Emp_Leave_Bal B
		INNER JOIN (
			SELECT cmp_ID
				,lm.Leave_Code
				,Leave_Name
			FROM T0040_LEave_Master lm WITH (NOLOCK)
			INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
				AND Row_ID = 1
			WHERE Cmp_Id = @Cmp_ID /*and Leave_ID in (select top 1 leave_id from																																									
																	(select top 1 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/
			) q ON b.Cmp_ID = q.Cmp_ID
	END

	IF EXISTS (
			SELECT emp_ID
			FROM #Emp_Leave_Bal
			WHERE isnull(Leave_Name_2, '') = ''
			)
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Name_2 = q.Leave_Code
		FROM #Emp_Leave_Bal B
		INNER JOIN (
			SELECT cmp_ID
				,lm.Leave_Code
				,Leave_Name
			FROM T0040_LEave_Master lm WITH (NOLOCK)
			INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
				AND Row_ID = 2
			WHERE Cmp_Id = @Cmp_ID /*and Leave_ID in (select top 1 leave_id from																																							
																	(select top 2 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/
			) q ON b.Cmp_ID = q.Cmp_ID
	END

	IF EXISTS (
			SELECT emp_ID
			FROM #Emp_Leave_Bal
			WHERE isnull(Leave_Name_3, '') = ''
			)
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Name_3 = q.Leave_Code
		FROM #Emp_Leave_Bal B
		INNER JOIN (
			SELECT cmp_ID
				,lm.Leave_Code
				,Leave_Name
			FROM T0040_LEave_Master lm WITH (NOLOCK)
			INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
				AND Row_ID = 3
			WHERE Cmp_Id = @Cmp_ID /*and Leave_ID in (select top 1 leave_id from																																								
																	(select top 3 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID  order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/
			) q ON b.Cmp_ID = q.Cmp_ID
	END

	IF EXISTS (
			SELECT emp_ID
			FROM #Emp_Leave_Bal
			WHERE isnull(Leave_Name_4, '') = ''
			)
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Name_4 = q.Leave_Code
		FROM #Emp_Leave_Bal B
		INNER JOIN (
			SELECT cmp_ID
				,lm.Leave_Code
				,Leave_Name
			FROM T0040_LEave_Master lm WITH (NOLOCK)
			INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
				AND Row_ID = 4
			WHERE Cmp_Id = @Cmp_ID /* and Leave_ID in (select top 1 leave_id from																																								
																	(select top 4 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID   order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/
			) q ON b.Cmp_ID = q.Cmp_ID
	END

	IF EXISTS (
			SELECT emp_ID
			FROM #Emp_Leave_Bal
			WHERE isnull(Leave_Name_5, '') = ''
			)
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Name_5 = q.Leave_Code
		FROM #Emp_Leave_Bal B
		INNER JOIN (
			SELECT cmp_ID
				,lm.Leave_Code
				,Leave_Name
			FROM T0040_LEave_Master lm WITH (NOLOCK)
			INNER JOIN #temp_Leave tl ON tl.Leave_ID = lm.Leave_ID
				AND Row_ID = 5
			WHERE Cmp_Id = @Cmp_ID /* and Leave_ID in (select top 1 leave_id from																																								
																	(select top 5 leave_id,Leave_Sorting_No,Leave_Def_ID from T0040_LEAVE_MASTER where (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,@To_Date)>@To_Date then 1 else 0 end ) else  1 end )) and Cmp_ID=@Cmp_ID   order by Leave_Sorting_No asc) leave  order by Leave_Sorting_No desc 
																	)*/
			) q ON b.Cmp_ID = q.Cmp_ID
	END
END
ELSE
BEGIN
	IF EXISTS (
			SELECT emp_ID
			FROM #Emp_Leave_Bal
			WHERE Leave_Name_1 <> ''
			)
	BEGIN
		UPDATE #Emp_Leave_Bal
		SET Leave_Name_1 = q.Leave_Code
		FROM #Emp_Leave_Bal B
		INNER JOIN (
			SELECT cmp_ID
				,Leave_Code
				,Leave_Name
			FROM T0040_LEave_Master WITH (NOLOCK)
			WHERE Cmp_Id = @Cmp_ID
				AND Leave_Id = ISNULL(@Leave_Id, Leave_ID)
			) q ON b.Cmp_ID = q.Cmp_ID
	END
END

--Ronakb010824 add vertical
SELECT el.*
	,EMp_full_Name
	,BM.Branch_Address
	,Comp_Name
	,Emp_code
	,Alpha_Emp_Code
	,Emp_First_Name
	,Grd_NAme
	,branch_Name
	,desig_Name
	,Dept_Name
	,V.Vertical_Name
	,SubVertical_Name
	,SubBranch_Name
	,type_Name
	,Street_1
	,Cmp_Name
	,Cmp_Address
	,@To_Date P_To_Date
	,BM.Branch_ID
FROM #Emp_Leave_Bal el
INNER JOIN T0080_Emp_master e WITH (NOLOCK) ON el.emp_ID = e.emp_ID
INNER JOIN (
	SELECT I.Emp_Id
		,Branch_Id
		,Grd_Id
		,Type_ID
		,desig_Id
		,dept_ID
		,Vertical_ID
		,SubVertical_ID
		,SubBranch_ID
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT max(Increment_ID) AS Increment_ID
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @Cmp_ID
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_ID = Qry.Increment_ID
	) I_Q ON el.emp_ID = i_Q.Emp_ID
INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID
LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID
LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id
INNER JOIN T0040_Vertical_Segment V WITH (NOLOCK) ON I_Q.Vertical_ID = V.Vertical_ID
INNER JOIN T0050_SubVertical SV WITH (NOLOCK) ON I_Q.SubVertical_ID = SV.SubVertical_ID
INNER JOIN T0050_SubBranch SB WITH (NOLOCK) ON I_Q.SubBranch_ID = SB.SubBranch_ID
INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON e.Cmp_ID = cm.Cmp_ID
ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)

DROP TABLE #Emp_Leave_Bal

RETURN
