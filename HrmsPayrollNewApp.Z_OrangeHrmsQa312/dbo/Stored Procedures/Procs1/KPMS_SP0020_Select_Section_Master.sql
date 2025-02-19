-- exec KPMS_SP0020_Select_Section_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_Section_Master
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Section_Master]	
(
@Cmp_ID	INT,
@Section_ID INT,
@Section_Name varchar(20)= NULL,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Section_Master WHERE Section_ID=@Section_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Section_Id FROM KPMS_T0020_Section_Master WITH(NOLOCK)
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
		AND (Section_Name LIKE @Section_Name + '%' OR @Section_Name = '')ORDER BY Section_Id desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr>
		<td>' + isnull(Section_Name,'') + '</td><td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Section_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Section_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Section_ID) + ',' + CONVERT(varchar,IsActive) + ')">	
		' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Section_Master,#Temp where Section_Id = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Section_Id,0) AS s_Id,ISNULL([Section_Name],'') as Section_Name 
		from KPMS_T0020_Section_Master Where (@Section_ID = 0 Or Section_ID=@Section_ID)
	END
END