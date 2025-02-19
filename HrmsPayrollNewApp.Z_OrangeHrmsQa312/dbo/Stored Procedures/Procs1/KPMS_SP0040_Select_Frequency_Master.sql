
CREATE PROCEDURE [dbo].[KPMS_SP0040_Select_Frequency_Master]	
(
@Cmp_ID	INT,
@Frequency_ID INT,
@Frequency_Code varchar(5) = NULL,
@Frequency varchar(20)= NULL,
@rPageIndex INT,
@rPageSize INT,
@rSortBy VARCHAR(100)
)
as
BEGIN
	IF NOT EXISTS(Select 1 From KPMS_T0040_Frequency_Master WHERE Frequency_ID=@Frequency_ID and IsActive < 2)
	BEGIN
		DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''
		DECLARE @lTotalRecords INT = 0
		SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end

		CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)
	
		INSERT INTO #Temp
		SELECT Frequency_ID FROM KPMS_T0040_Frequency_Master WITH(NOLOCK)
		WHERE IsActive < 2 and Cmp_ID=@Cmp_ID
		AND (Frequency_Code LIKE @Frequency_Code + '%' OR @Frequency_Code = '')
		AND (Frequency LIKE @Frequency + '%' OR @Frequency = '')ORDER BY Frequency_ID desc

		select @lTotalRecords = COUNT(1) from #Temp
	--	SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)
	SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)

		select @lResult = @lResult + '<tr><td>' + isnull(Frequency_Code,'') + '</td>
		<td>' + isnull(Frequency,'') + '</td><td>
		<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Frequency_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Frequency_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>
		<a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Frequency_ID) + ',' + CONVERT(varchar,IsActive) + ')">	
		' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'
		</a></td></tr>' from KPMS_T0040_Frequency_Master,#Temp where Frequency_ID = rId 
		and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid --desc
		--and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY Frequency_ID desc --tid 
	
		select @lResult as Result,@lPaging as Paging
	END
	ELSE
	BEGIN
		SELECT ISNULL(Frequency_ID,0) AS r_Id,ISNULL([Frequency_Code],'') as Code,ISNULL([Frequency],'') as Frequency 
		from KPMS_T0040_Frequency_Master Where (@Frequency_ID = 0 Or Frequency_ID=@Frequency_ID) 
	END
END

--select *from KPMS_T0040_Frequency_Master