CREATE function [dbo].[fnc_BindGridData2](@Type int,@levelAssignId int)      
returns varchar(max)        
as        
begin      
	declare @lResult varchar(max) = ''      
		select @lResult = @lResult + '<td attrGroupId="' + convert(Varchar,1) + '" attrLevelId="' + convert(varchar,Level_ID) + '">'+ CONVERT(varchar,la_LevelValue) +'</td>'
		FROM KPMS_T0040_Level_Master inner join tbl_LevelAssignValues on Level_ID = la_LevelId      
		where IsActive = 1 and la_LevelAssignId =   @levelAssignId   
return @lResult      
end    
    



--select * from KPMS_T0040_Level_Master    
--select * from tbl_LevelAssignValues    
--select * from KPMS_T0100_Level_Assign    
  
--  begin      
-- declare @lResult varchar(max) = ''      
-- select @lResult = @lResult + '<td attrGroupId="' + convert(Varchar,1) + '" attrLevelId="' + convert(varchar,Level_ID) + '">'+ CONVERT(varchar,la_LevelValue) +'</td>'
-- FROM KPMS_T0040_Level_Master inner join tbl_LevelAssignValues on Level_ID = la_LevelId      
-- where IsActive = 1 and la_LevelAssignId =   @levelAssignId   
-- return @lResult      
--end    
    