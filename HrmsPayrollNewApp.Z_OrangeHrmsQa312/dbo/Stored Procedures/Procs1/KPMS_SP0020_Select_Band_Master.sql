CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Band_Master]	
(
@Cmp_ID	INT,
@Band_ID INT,
@Band_Code varchar(5) = NULL,
@Band_Name varchar(20)= NULL,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Band_Master WHERE Band_ID=@Band_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Band_Id FROM KPMS_T0020_Band_Master WITH(NOLOCK)
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
		AND (Band_Code LIKE @Band_Code + '%' OR @Band_Code = '')
		AND (Band_Name LIKE @Band_Name + '%' OR @Band_Name = '')ORDER BY Band_Id desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr><td>' + isnull(Band_Code,'') + '</td>
		<td>' + isnull(Band_Name,'') + '</td><td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Band_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Band_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Band_ID) + ',' + CONVERT(varchar,IsActive) + ')">	
		' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Band_Master,#Temp where Band_Id = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Band_Id,0) AS b_Id,ISNULL([Band_Code],'') as Code,ISNULL([Band_Name],'') as Band_Name 
		from KPMS_T0020_Band_Master Where (@Band_ID = 0 Or Band_ID=@Band_ID)
	END
END