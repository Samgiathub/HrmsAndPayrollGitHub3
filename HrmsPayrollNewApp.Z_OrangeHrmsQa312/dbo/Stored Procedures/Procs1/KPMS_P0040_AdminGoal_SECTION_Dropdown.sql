
-- EXEC P0040_ROLE_MASTER_DROPDOWN  
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN  KPMS_P0040_BindSectionDropdown
CREATE PROCEDURE [dbo].[KPMS_P0040_AdminGoal_SECTION_Dropdown]  
@rCmpId INT,
@sectionid INT,
@Goaid int,
@Flag int,
@selectedSEc_ID varchar(5)
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @ddlSetion VARCHAR(MAX) = ''  
 DECLARE @ddlGoal VARCHAR(MAX) = ''  
 DECLARE @ddlSubGoal VARCHAR(MAX) = '' 

 if(@Flag = 0)
begin
 SELECT @ddlSetion = '<option value="0"> -- Select -- </option>'  
 SELECT @ddlSetion = @ddlSetion + '<option value="' + CONVERT(VARCHAR,Section_ID) + '">' + Section_Name	 + '</option>'  
 FROM KPMS_T0020_Section_Master WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  and IsActive = 1 
 end

 if(@Flag = 1)
begin
	SELECT @ddlGoal = '<option value="0"> -- Select -- </option>'  
    SELECT @ddlGoal = @ddlGoal + '<option value="' + CONVERT(VARCHAR,Goal_ID) + '">' + Goal_Name + '</option>'  
    FROM KPMS_T0020_Goal_Master WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  and IsActive = 1 and Section_ID = @sectionid
end
else if(@Flag = 2)
begin
	SELECT @ddlSubGoal = '<option value="0"> -- Select -- </option>'  
    SELECT @ddlSubGoal = @ddlSubGoal + '<option value="' + CONVERT(VARCHAR,SubGoal_ID) + '">' + SubGoal_Name + '</option>'  
	 FROM KPMS_T0020_SubGoal_Master WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  and IsActive = 1 and Goal_ID = @Goaid
end

else if(@flag = 4)
begin
	SELECT @ddlGoal = '<option value="0"> -- Select -- </option>'  
    SELECT @ddlGoal = @ddlGoal + '<option value="' + CONVERT(VARCHAR,Goal_ID) + '">' + Goal_Name + '</option>'  
    FROM KPMS_T0020_Goal_Master WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  and IsActive = 1 and Section_ID = @selectedSEc_ID
end

 SELECT @rCmpId AS CmpId,@ddlSetion AS SetionResult,@ddlGoal as GoalResult,@ddlSubGoal as SubGoalResult

END  



