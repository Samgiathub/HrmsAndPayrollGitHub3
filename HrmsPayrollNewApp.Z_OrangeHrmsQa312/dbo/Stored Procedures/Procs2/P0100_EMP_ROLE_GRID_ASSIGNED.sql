-- EXEC P0100_EMP_ROLE_GRID_ASSIGNED
-- DROP PROCEDURE P0100_EMP_ROLE_GRID_ASSIGNED
CREATE PROCEDURE P0100_EMP_ROLE_GRID_ASSIGNED
@rPageIndex INT,
@rBranchId INT,
@rDepartmentId INT,
@rDesignationId INT,
@rGradeId INT,
@rEmployeeId INT,
@rSortBy VARCHAR(100),
@rPageSize INT,
@rRoleId INT,
@risDelete INT
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @lResult VARCHAR(MAX) = '',@lPaging VARCHAR(MAX) = '',@lResultAdd VARCHAR(MAX) = ''
	DECLARE @lTotalRecords INT = 0
	CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	CREATE TABLE #Temp2(tid INT IDENTITY(1,1),rrId INT)

	INSERT INTO #Temp
	SELECT Emp_Role_Id FROM T0100_Emp_Role_Assign AS eROLE WITH(NOLOCK)
	INNER JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON EMP.Emp_ID = eRole.Emp_Id
	WHERE (EMP.Dept_ID = @rDepartmentId OR @rDepartmentId = 0)
	AND (Role_Id = @rRoleId or @rRoleId = 0)
	AND (EMP.Branch_ID = @rBranchId OR @rBranchId = 0)
	AND (EMP.Desig_Id = @rDesignationId OR @rDesignationId = 0)
	AND (EMP.Grd_ID = @rGradeId OR @rGradeId = 0)
	AND (EMP.Emp_ID = @rEmployeeId OR @rEmployeeId = 0)

	INSERT INTO #Temp2
	EXEC ('SELECT Emp_Role_Id FROM T0100_Emp_Role_Assign WITH(NOLOCK),#Temp WHERE rId = Emp_Role_Id ORDER BY ' + @rSortBy)

	SELECT @lTotalRecords = COUNT(1) FROM #Temp2
	SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

	SELECT @lResult = @lResult + '<tr><td>' + ISNULL(r_Title,'') + '</td><td>' + ISNULL(Alpha_Emp_Code,'') + '</td>
		<td>' + ISNULL(Initial,'') + ' ' + ISNULL(Emp_First_Name,'') + ' ' + ISNULL(Emp_Last_Name,'') + '</td>
		<td>' + CASE WHEN @risDelete > 0 OR  @risDelete = -1 THEN + '
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Emp_Role_Id) + ',' + CONVERT(VARCHAR,eROLE.Emp_Id) + ',' + CONVERT(VARCHAR,eROLE.Role_Id) + ')"><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Emp_Role_Id) + ',2)"><i class="fa fa-trash" aria-hidden="true"></i></a>
		' ELSE '<i class="fa fa-trash" aria-hidden="true"></i>' END + '</td></tr>'
	FROM T0100_Emp_Role_Assign AS eROLE WITH(NOLOCK)
	INNER JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON EMP.Emp_ID = eRole.Emp_Id
	INNER JOIN T0040_Task_Role_Master tROLE WITH(NOLOCK) ON eRole.Role_Id = tROLE.Role_Id,#Temp2
	WHERE Emp_Role_Id = rrId and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid

	SELECT Result = @lResult,Paging = @lPaging
END