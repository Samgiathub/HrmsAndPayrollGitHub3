-- EXEC P0040_ROLE_MASTER_DROPDOWN        
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN        
  
--exec KPMS_P0040_Achievement_Section_DROPDOWN @rCmpId=120  
--go  
CREATE PROCEDURE [dbo].[KPMS_P0040_Achievement_Section_DROPDOWN]        
@rCmpId INT        
AS        
BEGIN        
 SET NOCOUNT ON;        
 SET ARITHABORT ON;        
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;        
        
 DECLARE @Sheetname VARCHAR(MAX) = ''    
  DECLARE @lDeptResult VARCHAR(MAX) = ''     
  DECLARE @lDesiResult VARCHAR(MAX) = ''     
  DECLARE @lEmpResult VARCHAR(MAX) = ''    
    
 SELECT @Sheetname = '<option value="0"> -- Select -- </option>'        
 SELECT  @Sheetname = @Sheetname + '<option value="' + CONVERT(VARCHAR,GS_Id) + '">' + GoalSheet_Name + '</option>'        
 FROM KPMS_T0020_Goal_Allotment_Master_Test WITH(NOLOCK)   inner join KPMS_T0100_Goal_Setting on gs_id=Goal_Setting_ID  
     
 SELECT  @lDeptResult = '<option value="0"> -- Select -- </option>'        
 SELECT  @lDeptResult = @lDeptResult + '<option value="' + CONVERT(VARCHAR,gat.Dept_Id) + '">' + Dept_Name + '</option>'        
 FROM T0040_DEPARTMENT_MASTER as dm inner join KPMS_T0020_Goal_Allotment_Master_Test as gat on dm.Dept_Id = gat.Dept_ID  where dm.Cmp_Id =@rCmpId  
        
 SELECT @lDesiResult = '<option value="0"> -- Select -- </option>'        
 SELECT @lDesiResult = @lDesiResult + '<option value="' + CONVERT(VARCHAR,gat.Desig_ID) + '">' + Desig_Name + '</option>'        
 FROM T0040_DESIGNATION_MASTER as dm WITH(NOLOCK) inner join KPMS_T0020_Goal_Allotment_Master_Test as gat on dm.Desig_ID = gat.Desig_ID   
  
  
  SELECT @lEmpResult = '<option value="0"> -- Select -- </option>'        
  SELECT @lEmpResult = @lEmpResult + '<option value="' + CONVERT(VARCHAR,gat.Emp_ID) + '">'+ CONVERT(VARCHAR,Alpha_Emp_Code)+ '  -  '+ Emp_Full_Name + '</option>'      
 FROM T0080_EMP_MASTER as em WITH(NOLOCK) inner join KPMS_T0020_Goal_Allotment_Master_Test as gat on em.Emp_ID= gat.Emp_ID   
  
 --select @lEmpFullName = '<option value = "0">-- Select -- </option --select @lEmpFullName = @lEmpFullName + '<option value = "'+CONVERT(VARCHAR,EMP_ID)+'"> '+ Emp_Full_Name>'      
 --+' </option>'  from T0080_EMP_MASTER WHERE Cmp_ID = @rCmpId  and  Emp_Left <> 'y'           
    
  select @Sheetname AS Sheetname,@lDeptResult as DeptResult, @lDesiResult as DesigResult,@lEmpResult as EmpResult    
    
END        
    
    
--Goal_Allot_ID Cmp_ID Goal_Setting_ID GoalSheet_Name Galt_Effect_Date Dept_ID Desig_ID Emp_ID User_ID Created_Date Modify_Date IsActive IsLock    
--1 120 1 2022 VKT 2021-12-09 00:00:00 327 621 14561 7017 2022-01-27 14:51:10.390 NULL 0 0