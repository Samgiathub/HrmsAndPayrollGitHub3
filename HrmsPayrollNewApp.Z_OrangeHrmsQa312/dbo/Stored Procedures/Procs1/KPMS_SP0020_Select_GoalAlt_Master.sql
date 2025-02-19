--Galt_Status_Name	User_ID	Created_Date	Modify_Date

--select * from KPMS_T0020_Goal_Allotment_Master
-- exec [KPMS_SP0020_Select_GoalAlt_Master] 67,0,'','',1,2,''
-- drop proc [KPMS_SP0020_Select_GoalAlt_Master]
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_GoalAlt_Master]	
(
@Cmp_ID	INT,
@GoalAlt_ID INT,
@GoalSheet_Name varchar,
--@Effect_date VARCHAR,
@Galt_Dept_Name varchar,
@Galt_Desig_Name varchar,
@Galt_Emp_Name varchar,
@Galt_Status_Name varchar,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
	--SELECT @Effect_date = CASE ISNULL(@Effect_date,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Effect_date, 105), 23) END
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Allotment_Master WHERE GoalAlt_ID=@GoalAlt_ID and Galt_Status_Name < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
		INSERT INTO #Temp
		SELECT GoalAlt_ID FROM KPMS_T0020_Goal_Allotment_Master WITH(NOLOCK)
		WHERE Galt_Status_Name < 2 and Cmp_ID=@Cmp_ID
		AND (GoalSheet_Name LIKE @GoalSheet_Name + '%' OR @GoalSheet_Name = '')ORDER BY GoalAlt_ID desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr>
		<td>' + isnull(GoalSheet_Name,'') + '</td>
		<td>' + isnull(Galt_Dept_Name,'') + '</td>
		<td>' + isnull(Galt_Desig_Name,'') + '</td>
		<td>' + isnull(Galt_Emp_Name,'') + '</td>
		<td>' + isnull(Galt_Status_Name,'') + '</td>
		<td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,GoalAlt_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,GoalAlt_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		</td></tr>' from KPMS_T0020_Goal_Allotment_Master,#Temp where GoalAlt_ID = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(GoalAlt_ID,0) AS s_Id,ISNULL([GoalSheet_Name],'') as GoalSheet_Name 
		from KPMS_T0020_Goal_Allotment_Master Where (@GoalAlt_ID = 0 Or GoalAlt_ID=@GoalAlt_ID)
	END
END