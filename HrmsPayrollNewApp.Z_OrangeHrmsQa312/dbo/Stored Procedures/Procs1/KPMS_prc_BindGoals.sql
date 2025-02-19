-- exec KPMS_prc_BindGoals  
-- drop proc KPMS_prc_BindGoals  
CREATE procedure [dbo].[KPMS_prc_BindGoals]  
@rCmpId int,  
@sectionid int
  
as  
begin  
 declare @lResult varchar(max) = ''  
 
  
 select @lResult = '<option value="0"> -- Select -- </option>'  
 select @lResult = @lResult + '<option value="' + CONVERT(VARCHAR,Goal_ID) + '">' + Goal_Name + '</option>'  
 FROM KPMS_T0020_Goal_Master where Section_ID = @sectionid  and Cmp_Id = @rCmpId
  
 select @lResult as result  
end  
