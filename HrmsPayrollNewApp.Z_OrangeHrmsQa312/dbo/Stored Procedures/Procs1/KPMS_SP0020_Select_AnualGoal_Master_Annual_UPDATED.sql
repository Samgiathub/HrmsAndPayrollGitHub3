-- exec KPMS_SP0020_Select_AnualGoal_Master 67,0,'','',1,2,''          
-- drop proc KPMS_SP0020_Select_AnualGoal_Master          
CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_AnualGoal_Master_Annual_UPDATED]           
(          
@Cmp_ID INT,          
@GS_Id INT,          
@Title varchar(100)= NULL,          
@Fromdate varchar(50) = null,          
@Todate varchar(50) = null,          
@rPageIndex INT,          
@rPageSize INT            
)          
as           
BEGIN          
 IF @GS_Id = 0        
 BEGIN          
  DECLARE @lResult varchar(max) =  '',@lPaging VARCHAR(MAX) = ''          
  DECLARE @lTotalRecords INT = 0          
  SELECT @rPageSize = CASE WHEN @rPageSize is null or isnull(@rPageSize,0) = 0 then 5 else @rPageSize end          
          
  CREATE TABLE #Temp(tid INT IDENTITY(1,1),rId INT)           
  INSERT INTO #Temp          
  SELECT GS_Id FROM KPMS_T0100_Goal_Setting WITH(NOLOCK)          
  WHERE GS_StatusId < 2 and Cmp_ID=@Cmp_ID          
  AND (GS_SheetName LIKE @Title + '%' OR @Title = '')ORDER BY GS_Id desc          
          
  select @lTotalRecords = COUNT(1) from #Temp          
  SELECT @lPaging = @lPaging + dbo.fnc_SearchPagingFormat(@rPageIndex, @lTotalRecords, @rPageSize)          
          
  select @lResult = @lResult + '<tr>          
  <td>' + isnull(GS_SheetName,'') + '</td>          
  <td>( ' + isnull(convert(varchar,GS_FromDate,103),'') + '  -  ' + isnull(convert(varchar,GS_ToDate,103),'') + ' )</td>          
  <td>' + case when IsLock = 0 then '<a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,GS_Id) +')">
  <i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>'else'<i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i>'end+'     
  <a href="javascript:;" onclick="ChangeStatus(' + CONVERT(VARCHAR,GS_Id) + ',2)"><i class="fa fa-trash fa-lg" aria-hidden="true"></i></a>  
  <a href="javascript:;" onclick="EditData(' + CONVERT(VARCHAR,GS_Id) + ')"><i class="fa fa-pencil-square-o fa-lg" aria-hidden="true"></i></a>
  </td></tr>' from KPMS_T0100_Goal_Setting ,#Temp where GS_Id = rId          
  and tid between (@rPageSize * ( @rPageIndex-1)) + 1 And @rPageIndex * @rPageSize ORDER BY tid          
           
  select @lResult as Result,@lPaging as Paging          
 END          
 ELSE          
 BEGIN          
  declare @lSectionResult varchar(max) = ''          
          
  select @lSectionResult = @lSectionResult + '<div class="col-md-12"><div class="card card-primary card-outline" group="sections"><div class="card-header"><div class="form-group"><div class="row">          
  <div class="col-md-2" group="headersection"><label>Section Name</label><select class="custom-select drpSectionName0" id="drpSection" onchange="DrpSec2(0,1)"></select></div>         
  <div class="col-md-3" group="headersection"><label>Weightage Value</label><input type="text" name="Weightage_Value" class="form-control txtSectionWeightage" onkeypress="return isNumberKey(event);" placeholder="80" value="' + convert(varchar,GSS_WeightageValue) + '" /></div>                 
 <div class="col-md-3">
                                            <label>Section Type</label>
                                            <select class="custom-select drpSectiontype0" id="drpSectionType">
                                                <option value="0">--Select--</option>
                                                <option value="1">Section_A_Wise</option>
                                                <option value="2">Section_B_Wise</option>
                                            </select>
                                        </div>
									    <div class="col-md-1">
                                            <a href="javascript:;" onclick="Valid_section(this);">
                                                <i class="fas fa-plus-circle float-right"></i>
                                            </a>
                                        </div>
                                        <div class="col-md-0.25">
                                            <a href="javascript:;" onclick="RemoveSection(this);">
                                                <i class="fas fa-trash float-right"></i>
                                            </a>
                                        </div></div></div></div><div class="collapse show"><div class="card-body table-responsive p-0 dvSection">          
  <table class="table table-hover text-nowrap sectiontable"><thead><tr><th width="13%">Goal</th><th width="13%">Sub Goal</th><th width="10%">Frequency</th>
  <th width="8%">Weightage Value</th><th width="5%">Dependency</th><th width="10%">Depen. Module</th><th width="10%">Depen. Type</th>         
  <th width="5%">Action</th></tr></thead><tbody class="tblParentGoal">' + dbo.[fnc_GetSectionInnerResultForEditData_Annual_Updated](@Cmp_ID,GSS_SectionId) + '</tbody></table></div></div></div></div>'            
--   <th width="5%">Action</th></tr></thead><tbody class="tblParentGoal">' + dbo.fnc_GetSectionInnerResult(@Cmp_ID,GSS_SectionId,GSG_FrequecyId,GSG_WeightageType_Id) + '</tbody></table></div></div></div></div>'   
 from KPMS_T0100_Goal_Setting as GM          
  inner join KPMS_T0110_Goal_Setting_Section GS on GM.GS_Id = GS.GSS_Goal_Setting_Id          
  inner join KPMS_T0020_Section_Master on GS.GSS_SectionId = Section_ID          
  inner join KPMS_T0110_Goal_Setting_Goal GSG on GSG.GSG_GoalSetting_Id = gs.GSS_Goal_Setting_Id    
  Where (@GS_Id = 0 Or GS_Id = @GS_Id)          
        
        
          
  SELECT ISNULL(GS_Id,0) AS G_Id,ISNULL([GS_SheetName],'') as Title,          
  CONVERT(VARCHAR, CONVERT(varchar, GS_FromDate, 103)) as GS_FromDate ,          
  CONVERT(VARCHAR, CONVERT(varchar, GS_ToDate, 103)) as GS_ToDate,GS_WeightageTypeId,GS_WeightageValue,GS_StatusId,          
  @lSectionResult as SectionResult          
  from KPMS_T0100_Goal_Setting as GM            
  Where (@GS_Id = 0 Or GS_Id = @GS_Id)          
          
  select isnull(GSB_Title,'') as Title,isnull(GSB_Min,0) as MinScore,isnull(GSB_Max,0) as MaxScore          
  from KPMS_T0110_GoalSettingScore where GSB_GoalSettingId = @GS_Id order by GSB_Min          
 END          
END