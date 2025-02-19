CREATE PROCEDURE [dbo].[KPMS_SP0040_Select_Level_Master]   
(  
@Cmp_ID INT,  
@Level_ID INT,  
@Level_Code varchar(5) = NULL,  
@Level_Name varchar(20)= NULL,  
@LvlGrp int,  
@rPageIndex INT,  
@rPageSize INT,  
@rSortBy VARCHAR(100)  
)  
as  
BEGIN  
 IF NOT EXISTS(Select 1 From KPMS_T0040_Level_Master WHERE Level_ID=@Level_ID and IsActive < 2)  
 BEGIN  
  DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''  
  DECLARE @lTotalRecords INT = 0  
  SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end  
  
  CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)  
   
  INSERT INTO #Temp  
  SELECT Level_ID FROM KPMS_T0040_Level_Master WITH(NOLOCK)  
  WHERE IsActive < 2 and Cmp_ID=@Cmp_ID  
  AND (Level_Code LIKE @Level_Code + '%' OR @Level_Code = '')  
  AND (level_Grp_Id = @LvlGrp  OR @LvlGrp = 0)   
  AND (Level_Name LIKE @Level_Name + '%' OR @Level_Name = '')ORDER BY Level_ID desc  
  
  select @lTotalRecords = COUNT(1) from #Temp  
  SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)  
  
  select @lResult = @lResult + '<tr><td>' + isnull(Level_Code,'') + '</td>  
  <td>' + isnull(Level_Group_Name,'') + '</td>  
  <td>' + isnull(Level_Name,'') + '</td><td>  
  <a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,Level_ID) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>  
  <a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Level_ID) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>  
  <a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,Level_ID) + ',' + CONVERT(varchar,IsActive) + ')">   
  ' + CASE IsActive WHEN 1 THEN '<i class="fa fa-check fa-lg" aria-hidden="true"></i>' ELSE '<i class="fa fa-times fa-lg" aria-hidden="true"></i>' END +'  
  </a></td></tr>' from KPMS_T0040_Level_Master as lm Inner  join KPMS_T0040_Level_Group_Master as lgm on lm.level_Grp_Id=lgm.Level_Group_ID ,#Temp where Level_ID = rId  
  and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid   
   
  select @lResult as Result,@lPaging as Paging  
 END  
 ELSE  
 BEGIN  
  SELECT ISNULL(Level_ID,0) AS L_Id,ISNULL([Level_Code],'') as Code,ISNULL([Level_Name],'') as Level,ISNULL([level_Grp_Id],'') as LevelGrp   
  from KPMS_T0040_Level_Master Where (@Level_ID = 0 Or Level_ID=@Level_ID)  
 END  
END