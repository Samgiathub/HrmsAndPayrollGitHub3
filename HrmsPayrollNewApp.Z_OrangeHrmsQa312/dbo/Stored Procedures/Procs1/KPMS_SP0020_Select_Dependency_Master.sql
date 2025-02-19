-- exec KPMS_SP0020_Select_Dependency_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_Dependency_Master
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Dependency_Master]	
(
@Cmp_ID	INT,
@Dependency_ID INT,
@Dependency_Code varchar(5) = NULL,
@Dependency_Type varchar(20)= NULL,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Dependency_Master WHERE Dependency_ID=@Dependency_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Dependency_Id FROM KPMS_T0020_Dependency_Master WITH(NOLOCK)
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
		AND (Dependency_Code LIKE @Dependency_Code + '%' OR @Dependency_Code = '')
		AND (Dependency_Type LIKE @Dependency_Type + '%' OR @Dependency_Type = '') ORDER BY Dependency_Id desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr><td>' + isnull(Dependency_Code,'') + '</td>
		<td>' + isnull(Dependency_Type,'') + '</td><td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Dependency_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Dependency_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Dependency_ID) + ',' + CONVERT(varchar,IsActive) + ')">	
		' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Dependency_Master,#Temp where Dependency_Id = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Dependency_Id,0) AS d_Id,ISNULL([Dependency_Code],'') as Code,ISNULL([Dependency_Type],'') as Dependency_Type 
		from KPMS_T0020_Dependency_Master Where (@Dependency_ID = 0 Or Dependency_ID=@Dependency_ID)
	END
END