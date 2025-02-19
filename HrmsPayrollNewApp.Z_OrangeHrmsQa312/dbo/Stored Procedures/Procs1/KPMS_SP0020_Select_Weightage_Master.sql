-- exec KPMS_SP0020_Select_Weightage_Master 67,0,'','',1,2,''
-- drop proc KPMS_SP0020_Select_Weightage_Master
-- select * from KPMS_T0020_Weightage_Master
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Weightage_Master]	
(
@Cmp_ID	INT,


@Weightage_ID INT,
@Weightage_Code varchar(5) = NULL,
@Weightage_Type varchar(20)= NULL,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0020_Weightage_Master WHERE Weightage_ID=@Weightage_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Weightage_Id FROM KPMS_T0020_Weightage_Master WITH(NOLOCK)
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
		AND (Weightage_Code LIKE @Weightage_Code + '%' OR @Weightage_Code = '')
		AND (Weightage_Type LIKE @Weightage_Type + '%' OR @Weightage_Type = '') ORDER BY Weightage_Id desc

		select @lTotalRecords = COUNT(1) from #Temp
		SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr><td>' + isnull(Weightage_Code,'') + '</td>
		<td>' + isnull(Weightage_Type,'') + '</td><td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Weightage_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Weightage_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Weightage_ID) + ',' + CONVERT(varchar,IsActive) + ')">	
		' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0020_Weightage_Master,#Temp where Weightage_Id = rId
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Weightage_Id,0) AS w_Id,ISNULL([Weightage_Code],'') as Code,ISNULL([Weightage_Type],'') as Weightage_Type 
		from KPMS_T0020_Weightage_Master Where (@Weightage_ID = 0 Or Weightage_ID=@Weightage_ID)
	END
END