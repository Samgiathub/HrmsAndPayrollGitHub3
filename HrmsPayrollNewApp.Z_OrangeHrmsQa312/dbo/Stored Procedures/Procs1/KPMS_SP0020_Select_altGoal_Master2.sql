-- exec KPMS_SP0020_Select_Role_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_Role_Master
Create PROCEDURE [dbo].[KPMS_SP0020_Select_altGoal_Master2]	
(
@Cmp_ID	INT,
@Role_ID INT,
--@Role_Code varchar(5) = NULL,
--@Role_Name varchar(20)= NULL,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Role_Master WHERE Role_ID=@Role_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Role_Id FROM KPMS_T0020_Role_Master WITH(NOLOCK)
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID ORDER BY Role_Id desc
		--AND (Role_Code LIKE @Role_Code + '%' OR @Role_Code = '')
		--AND (Role_Name LIKE @Role_Name + '%' OR @Role_Name = '')

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr><td>' + isnull(Role_Code,'') + '</td>
		<td>' + isnull(Role_Name,'') + '</td><td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Role_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Role_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Role_ID) + ',' + CONVERT(varchar,IsActive) + ')">	
		' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Role_Master,#Temp where Role_Id = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Role_Id,0) AS r_Id,ISNULL([Role_Code],'') as Code,ISNULL([Role_Name],'') as Role_Name 
		from KPMS_T0020_Role_Master Where (@Role_ID = 0 Or Role_ID=@Role_ID)
	END
END