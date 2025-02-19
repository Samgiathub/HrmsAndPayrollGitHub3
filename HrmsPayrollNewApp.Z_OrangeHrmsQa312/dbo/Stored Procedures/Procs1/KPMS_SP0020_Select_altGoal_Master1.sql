-- exec KPMS_SP0020_Select_Weightage_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_Weightage_Master
-- select * from KPMS_SP0020_Select_GoalAlt_Master
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_altGoal_Master1]	
(
@Cmp_ID	INT,
@GoalAlt_ID INT,
@GoalSheet_Name varchar,
--@Galt_Dept_Name varchar,
--@Galt_Desig_Name varchar,
--@Galt_Emp_Name varchar,
--@Galt_Status_Name varchar,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Allotment_Master_Test WHERE Goal_Allot_ID=@GoalAlt_ID and IsActive < 2)
	BEGIN
		
	DECLARE @lResult VARCHAR(MAX) = '',@lPaging VARCHAR(MAX) = '', @lResultAdd VARCHAR(MAX) = ''
	DECLARE @lTotalRecords INT = 0
	SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

	CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)

	INSERT INTO #Temp
	SELECT Goal_Allot_ID FROM KPMS_T0020_Goal_Allotment_Master_Test WITH(NOLOCK)
	WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
	AND (GoalSheet_Name LIKE @GoalSheet_Name + '%' OR @GoalSheet_Name = '')ORDER BY Goal_Allot_ID desc

	select @lTotalRecords = COUNT(1) from #Temp
	SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr>
		<td>' + isnull(GoalSheet_Name,'') + '</td>		
		<td>' + isnull( CONVERT(VARCHAR,Dept_Name),'') + '</td>
		<td>' + isnull( CONVERT(VARCHAR,Desig_Name),'') + '</td>
		<td>' + isnull( CONVERT(VARCHAR,Emp_Full_Name),'') + '</td>
		<td>' + isnull(Status_Name,'') + '</td>
		<td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Goal_Allot_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_Allot_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
			<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Goal_Allot_ID) + ',' + CONVERT(varchar,gam.IsActive) + ')">	
		' + CASE gam.IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Goal_Allotment_Master_Test as gam
				inner join KPMS_T0040_GoalStatus_Master as GSM on GSM.Cmp_Id = gam.Cmp_Id
				Inner join T0040_DEPARTMENT_MASTER as dsm on dsm.Dept_Id = gam.Dept_Id
				Inner join T0040_DESIGNATION_MASTER as ds on ds.Desig_ID = gam.Desig_ID
				Inner join T0080_EMP_MASTER as em on em.Emp_ID = gam.Emp_ID ,#Temp where Goal_Allot_ID = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Goal_Allot_ID,0) AS G_Id,ISNULL(GoalSheet_Name,'') as GoalSheet_Name,ISNULL(Dept_ID,'') as Dept_ID 
		from KPMS_T0020_Goal_Allotment_Master_Test Where (Goal_Allot_ID = 0 Or Goal_Allot_ID=@GoalAlt_ID)
	END
END