-- exec KPMS_SP0020_Select_Goal_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_Goal_Master
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Goal_Master]	
(
@Cmp_ID	INT,
@Goal_ID INT,
@Goal_Name varchar(20)= NULL,
@Section_Id Int,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Master WHERE Goal_ID=@Goal_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Goal_Id FROM KPMS_T0020_Goal_Master as GM WITH(NOLOCK) Inner Join
		KPMS_T0020_Section_Master as SM WITH(NOLOCK) on GM.Section_ID=sm.Section_ID
		WHERE GM.IsActive < 2 and GM.Cmp_ID=@Cmp_ID
		AND (GM.Section_ID = @Section_Id OR @Section_Id = 0)
		--AND (gm.Section_ID LIKE @Section_Id + '%' OR @Section_Id = '')
		AND (Goal_Name LIKE @Goal_Name + '%' OR @Goal_Name = '')ORDER BY Goal_Id desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr>
		<td>' + isnull(Section_Name,'') + '</td>
		<td>' + isnull(Goal_Name,'') + '</td>
		<td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Goal_ID) + ',' + CONVERT(VARCHAR,GM.Section_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_ID) + ',' + CONVERT(varchar,GM.IsActive) + ')">	
		' + CASE GM.IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Goal_Master GM
	Inner Join KPMS_T0020_Section_Master as SM on GM.Section_ID=SM.Section_ID,#Temp where Goal_Id = rId 
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize and sm.IsActive = 1 ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Goal_Id,0) AS s_Id,ISNULL([Goal_Name],'') as Goal_Name--,ISNULL([Section_ID],'') as Section_ID 
		from KPMS_T0020_Goal_Master as GM 
		Where (@Goal_ID = 0 Or Goal_ID=@Goal_ID)
	END
END