-- exec KPMS_SP0020_Select_SubGoal_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_SubGoal_Master
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_SubGoal_Master]	
(
@Cmp_ID	INT,

@SubGoal_ID INT,
@SubGoal_Name varchar(300)= NULL,
@Goal_ID Int,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_SubGoal_Master WHERE SubGoal_ID=@SubGoal_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT SubGoal_Id FROM KPMS_T0020_SubGoal_Master --as SM
		--Inner Join KPMS_T0020_Goal_Master as GM WITH(NOLOCK) on SM.Goal_ID=GM.Goal_ID
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
		AND (Goal_ID = @Goal_ID OR @Goal_ID = 0)
		AND (SubGoal_Name LIKE @SubGoal_Name + '%' OR @SubGoal_Name = '')ORDER BY SubGoal_Id desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr>
		<td>' + isnull(Section_Name,'') + '</td>
		<td>' + isnull(Goal_Name,'') + '</td>
		<td>'+ isnull(SubGoal_Name,'') +'</td>
		<td><a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,SubGoal_ID) + ',' + CONVERT(VARCHAR,sm.Goal_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,SubGoal_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,SubGoal_ID) + ',' + CONVERT(varchar,SM.IsActive) + ')">	
		' + CASE SM.IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_SubGoal_Master as SM
		Inner Join KPMS_T0020_Goal_Master as GM on SM.Goal_ID=GM.Goal_ID
		inner join KPMS_T0020_Section_Master as sec on sec.Section_ID=gm.Section_ID
		,#Temp where SubGoal_Id = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(SubGoal_Id,0) AS s_Id,ISNULL([SubGoal_Name],'') as SubGoal_Name,ISNULL([SM].Goal_ID,'') as Goal_Name 
		from KPMS_T0020_SubGoal_Master as SM
		Inner Join KPMS_T0020_Goal_Master as GM on SM.Goal_ID=GM.Goal_ID
		Where (@SubGoal_ID = 0 Or SubGoal_ID=@SubGoal_ID)
	END
END

---- Delete from KPMS_T0020_SubGoal_Master