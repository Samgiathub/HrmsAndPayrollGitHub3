-- EXEC P0040_Bind_ALL_TASK_MASTERS_GRID
-- DROP PROCEDURE P0040_Bind_ALL_TASK_MASTERS_GRID
CREATE PROCEDURE [dbo].[P0040_Bind_ALL_TASK_MASTERS_GRID]
@rPageIndex INT,
@rCode VARCHAR(50),
@rTitle VARCHAR(200),
@rSortBy VARCHAR(100),
@rPageSize INT,
@risEdit INT = NULL,
@risDelete INT = NULL,
@rType INT -- 1- ROLE, 2- STATUS, 3- TASK TYPE, 4- TASK CATEGORY, 5- PRIORITY, 6- PROJECT, 7- ACTIVITY
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @lResult VARCHAR(MAX) = '',@lPaging VARCHAR(MAX) = ''
	DECLARE @lTotalRecords INT = 0

	CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	CREATE TABLE #Temp2(tid INT IDENTITY(1,1),rrId INT)
	IF @rType = 1 -- ROLE
		BEGIN
			INSERT INTO #Temp
			SELECT Role_Id FROM T0040_Task_Role_Master WITH(NOLOCK)
			WHERE r_Status < 2
			AND (r_Code LIKE @rCode + '%' OR @rCode = '')
			AND (r_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Role_Id FROM T0040_Task_Role_Master WITH(NOLOCK),#Temp WHERE rId = Role_Id ORDER BY ' + @rSortBy)
		END
	ELSE IF @rType = 2 -- STATUS
		BEGIN
			INSERT INTO #Temp
			SELECT Status_Id FROM T0040_Status_Master WITH(NOLOCK)
			WHERE s_Status < 2
			AND (s_Code LIKE @rCode + '%' OR @rCode = '')
			AND (s_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Status_Id FROM T0040_Status_Master WITH(NOLOCK),#Temp WHERE rId = Status_Id ORDER BY ' + @rSortBy)
		END
	ELSE IF @rType = 3 -- TASK TYPE
		BEGIN
			INSERT INTO #Temp
			SELECT Task_Type_Id FROM T0040_Tasks_Type_Master WITH(NOLOCK)
			WHERE ttm_Status < 2
			AND (ttm_Code LIKE @rCode + '%' OR @rCode = '')
			AND (ttm_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Task_Type_Id FROM T0040_Tasks_Type_Master WITH(NOLOCK),#Temp WHERE rId = Task_Type_Id ORDER BY ' + @rSortBy)
		END
	ELSE IF @rType = 4 -- TASK CATEGORY
		BEGIN
			INSERT INTO #Temp
			SELECT Task_Cat_Id FROM T0040_Task_Category_Master WITH(NOLOCK)
			WHERE tc_Status < 2
			AND (tc_Code LIKE @rCode + '%' OR @rCode = '')
			AND (tc_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Task_Cat_Id FROM T0040_Task_Category_Master WITH(NOLOCK),#Temp WHERE rId = Task_Cat_Id ORDER BY ' + @rSortBy)
		END
	ELSE IF @rType = 5 -- PRIORITY
		BEGIN
			INSERT INTO #Temp
			SELECT Priority_Id FROM T0040_Priority_Master WITH(NOLOCK)
			WHERE pm_Status < 2
			AND (pm_Code LIKE @rCode + '%' OR @rCode = '')
			AND (pm_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Priority_Id FROM T0040_Priority_Master WITH(NOLOCK),#Temp WHERE rId = Priority_Id ORDER BY ' + @rSortBy)
		END
	ELSE IF @rType = 6 -- PROJECT
		BEGIN
			INSERT INTO #Temp
			SELECT Project_Id FROM T0040_Task_Project_Master WITH(NOLOCK)
			WHERE pr_Status < 2
			AND (pr_Code LIKE @rCode + '%' OR @rCode = '')
			AND (pr_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Project_Id FROM T0040_Task_Project_Master WITH(NOLOCK),#Temp WHERE rId = Project_Id ORDER BY ' + @rSortBy)
		END
	ELSE IF @rType = 7 -- ACTIVITY
		BEGIN
			INSERT INTO #Temp
			SELECT Activity_Id FROM T0040_Task_Activity_Master WITH(NOLOCK)
			WHERE am_Status < 2
			AND (am_Code LIKE @rCode + '%' OR @rCode = '')
			AND (am_Title LIKE @rTitle + '%' OR @rTitle = '')

			INSERT INTO #Temp2
			EXEC ('SELECT Activity_Id FROM T0040_Task_Activity_Master WITH(NOLOCK),#Temp WHERE rId = Activity_Id ORDER BY ' + @rSortBy)
		END

	SELECT @lTotalRecords = COUNT(1) FROM #Temp2
	SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

	IF @rType = 1 -- ROLE
		BEGIN
			SELECT @lResult = @lResult + '<tr><td><input type="checkbox" name="chkUser" value="'+CONVERT(VARCHAR,Role_Id)+'"></td><td>' + ISNULL(r_Code,'') + '</td><td>' + ISNULL(r_Title,'') + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Role_Id) + ',' + CONVERT(VARCHAR,r_Status) + ')">' +
				CASE r_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE r_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Role_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Role_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Task_Role_Master WITH(NOLOCK),#Temp2
			WHERE Role_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid			
		END
	ELSE IF @rType = 2
		BEGIN
			SELECT @lResult = @lResult + '<tr><td>' + ISNULL(s_Code,'') + '</td><td>' + ISNULL(s_Title,'') + '</td><td>' + convert(varchar,isnull(s_Percentage,'0')) + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Status_Id) + ',' + CONVERT(VARCHAR,s_Status) + ')">' +
				CASE s_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE s_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Status_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Status_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Status_Master WITH(NOLOCK),#Temp2
			WHERE Status_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid			
		END
	ELSE IF @rType = 3
		BEGIN
			SELECT @lResult = @lResult + '<tr><td>' + ISNULL(ttm_Code,'') + '</td><td>' + ISNULL(ttm_Title,'') + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Task_Type_Id) + ',' + CONVERT(VARCHAR,ttm_Status) + ')">' +
				CASE ttm_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE ttm_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Task_Type_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Task_Type_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Tasks_Type_Master WITH(NOLOCK),#Temp2
			WHERE Task_Type_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid
		END
	ELSE IF @rType = 4
		BEGIN
			SELECT @lResult = @lResult + '<tr><td>' + ISNULL(tc_Code,'') + '</td><td>' + ISNULL(tc_Title,'') + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Task_Cat_Id) + ',' + CONVERT(VARCHAR,tc_Status) + ')">' +
				CASE tc_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE tc_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Task_Cat_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Task_Cat_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Task_Category_Master WITH(NOLOCK),#Temp2
			WHERE Task_Cat_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid
		END
	ELSE IF @rType = 5
		BEGIN
			SELECT @lResult = @lResult + '<tr><td>' + ISNULL(pm_Code,'') + '</td><td>' + ISNULL(pm_Title,'') + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Priority_Id) + ',' + CONVERT(VARCHAR,pm_Status) + ')">' +
				CASE pm_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE pm_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Priority_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Priority_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Priority_Master WITH(NOLOCK),#Temp2
			WHERE Priority_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid
		END
	ELSE IF @rType = 6
		BEGIN
			SELECT @lResult = @lResult + '<tr><td>' + ISNULL(pr_Code,'') + '</td><td>' + ISNULL(pr_Title,'') + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Project_Id) + ',' + CONVERT(VARCHAR,pr_Status) + ')">' +
				CASE pr_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE pr_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Project_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Project_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Task_Project_Master WITH(NOLOCK),#Temp2
			WHERE Project_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid
		END
	ELSE IF @rType = 7
		BEGIN
			SELECT @lResult = @lResult + '<tr><td>' + ISNULL(am_Code,'') + '</td><td>' + ISNULL(am_Title,'') + '</td>
				<td>' + CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Activity_Id) + ',' + CONVERT(VARCHAR,am_Status) + ')">' +
				CASE am_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END + '</a>'
				ELSE CASE am_Status WHEN 1 THEN '<i class="fa fa-check" aria-hidden="true"></i>' ELSE '<i class="fa fa-times" aria-hidden="true"></i>' END END
				+ CASE WHEN @risEdit > 0 OR  @risEdit = -1 THEN + '
				<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Activity_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
				' ElSE '<i class="fa fa-pencil-square-o" aria-hidden="true"></i>' END +'
				' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
				<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Activity_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
				' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END +'</td></tr>'
			FROM T0040_Task_Activity_Master WITH(NOLOCK),#Temp2
			WHERE Activity_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid
		END

	SELECT Result = @lResult,Paging = @lPaging
END