-- EXEC P0040_ROLE_MASTER_DROPDOWN        
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN        
  
--exec KPMS_P0040_Achievement_Section_DROPDOWN @rCmpId=120  
--go  
CREATE PROCEDURE [dbo].[KPMS_P0040_Achievement_GetSheetdata_ddl_DROPDOWN]        
@GoalId INT        
AS        
BEGIN        
 SET NOCOUNT ON;        
 SET ARITHABORT ON;        
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;        
        
 DECLARE @Sheetname VARCHAR(MAX) = ''    
  DECLARE @lDeptResult VARCHAR(MAX) = ''     
  DECLARE @lDesiResult VARCHAR(MAX) = ''     
  DECLARE @lEmpResult VARCHAR(MAX) = ''    
     
 SELECT  @lDeptResult = '<option value="0"> -- Select -- </option>'        
 SELECT  @lDeptResult = @lDeptResult + '<option value="' + CONVERT(VARCHAR,gat.Dept_Id) + '">' + Dept_Name + '</option>'        
 FROM T0040_DEPARTMENT_MASTER as dm inner join KPMS_T0020_Goal_Allotment_Master_Test as gat on dm.Dept_Id = gat.Dept_ID  where Goal_Setting_ID = @GoalId
 
 
 SELECT @lDesiResult = '<option value="0"> -- Select -- </option>'        
 SELECT @lDesiResult = @lDesiResult + '<option value="' + CONVERT(VARCHAR,gat.Desig_ID) + '">' + Desig_Name + '</option>'        
 FROM T0040_DESIGNATION_MASTER as dm WITH(NOLOCK) inner join KPMS_T0020_Goal_Allotment_Master_Test as gat on dm.Desig_ID = gat.Desig_ID where Goal_Setting_ID = @GoalId
  
  
  SELECT @lEmpResult = '<option value="0"> -- Select -- </option>'        
  SELECT @lEmpResult = @lEmpResult + '<option value="' + CONVERT(VARCHAR,gat.Emp_ID) + '">'+ CONVERT(VARCHAR,Alpha_Emp_Code)+ '  -  '+ Emp_Full_Name + '</option>'      
 FROM T0080_EMP_MASTER as em WITH(NOLOCK) inner join KPMS_T0020_Goal_Allotment_Master_Test as gat on em.Emp_ID= gat.Emp_ID  where Goal_Setting_ID = @GoalId  
  
  select @Sheetname AS Sheetname,@lDeptResult as DeptResult, @lDesiResult as DesigResult,@lEmpResult as EmpResult    
    
END        
    
    
