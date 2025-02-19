
CREATE function [dbo].[fnc_BindGridData](@GoalAlt_ID int,@level_assign_Id Int)                            
returns varchar(max)                              
as   

begin  

 declare @lResult varchar(max) = ''    
 

DECLARE @LOCAL_DATA TABLE
(Title varchar(5000), 
 la_LevelAssignId  Int, 
 la_LevelId Int
)

  Insert into @LOCAL_DATA
  select * from (select distinct  '<td attrLevelId="' + convert(varchar,Level_ID) + '" attrgroupid="' + convert(varchar,level_Grp_Id) + '">                                
  <input class="form-control form-control-lg txt' + Level_Name + '" type="text" placeholder="Input" value="' + CONVERT(varchar,la_LevelValue) + '" onkeypress="isNumberKey(event);"/></td>'                            
  as Title ,la_LevelAssignId,la_LevelId FROM KPMS_T0040_Level_Master left join tbl_LevelAssignValues on Level_ID = la_LevelId                            
  where IsActive = 1 and la_AllotmentId = @GoalAlt_ID  And la_LevelAssignId=@level_assign_Id
  ) as Q order by la_LevelAssignId,	la_LevelId

   select @lResult = @lResult +Title
  from (
  --select distinct  '<td attrLevelId="' + convert(varchar,Level_ID) + '" attrgroupid="' + convert(varchar,level_Grp_Id) + '">                                
  --<input class="form-control form-control-lg txt' + Level_Name + '" type="text" placeholder="Input" value="' + CONVERT(varchar,la_LevelValue) + '" onkeypress="isNumberKey(event);"/></td>'                            
  --as Title ,la_LevelAssignId,la_LevelId FROM KPMS_T0040_Level_Master left join tbl_LevelAssignValues on Level_ID = la_LevelId                            
  --where IsActive = 1 and la_AllotmentId = @GoalAlt_ID   And la_LevelAssignId=@level_assign_Id
  Select * from @LOCAL_DATA
  ) as A

  --select distinct @lResult = @lResult + '<td attrLevelId="' + convert(varchar,Level_ID) + '" attrgroupid="' + convert(varchar,level_Grp_Id) + '">                                
  --<input class="form-control form-control-lg txt' + Level_Name + '" type="text" placeholder="Input" value="' + CONVERT(varchar,la_LevelValue) + '" onkeypress="isNumberKey(event);"/></td>'                            
  --FROM KPMS_T0040_Level_Master left join tbl_LevelAssignValues on Level_ID = la_LevelId                            
  --where IsActive = 1 and la_AllotmentId =   @GoalAlt_ID                         
  return @lResult                            
end         
        
  --  select distinct '<td attrLevelId="' + convert(varchar,Level_ID) + '" attrgroupid="' + convert(varchar,level_Grp_Id) + '">                                
  --<input class="form-control form-control-lg txt' + Level_Name + '" type="text" placeholder="Input" value="' + CONVERT(varchar,la_LevelValue) + '" onkeypress="isNumberKey(event);"/></td>'                            
  --FROM KPMS_T0040_Level_Master inner join tbl_LevelAssignValues on Level_ID = la_LevelId                            
  --where IsActive = 1 and la_AllotmentId =   1  
  
  
   