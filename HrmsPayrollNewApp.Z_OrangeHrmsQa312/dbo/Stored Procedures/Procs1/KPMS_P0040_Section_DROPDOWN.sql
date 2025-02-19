-- EXEC P0040_ROLE_MASTER_DROPDOWN  
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN  
CREATE PROCEDURE [dbo].[KPMS_P0040_Section_DROPDOWN]  
@rCmpId INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @lSectionResult VARCHAR(MAX) = ''  
 DECLARE @lGoalResult VARCHAR(MAX) = ''  
 DECLARE @lGoalResult_depe VARCHAR(MAX) = ''  
 DECLARE @lYearResult VARCHAR(MAX) = ''    
 DECLARE @lGoalSheet VARCHAR(MAX) = ''    
 DECLARE @lDesiResult VARCHAR(MAX) = ''    
 DECLARE @lDeptResult VARCHAR(MAX) = ''    
 DECLARE @lEmpResult VARCHAR(MAX) = ''    
 DECLARE @lSatusResult VARCHAR(MAX) = ''    
 DECLARE @lEmpFullNameResult VARCHAR(MAX) = ''  
 DECLARE @lLevelResult VARCHAR(MAX) = '' 
 DECLARE @lEmpFullName varchar(MAx)=''

 SELECT @lEmpResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lEmpResult = @lEmpResult + '<option value="' + CONVERT(VARCHAR,Emp_ID) + '">'+ CONVERT(VARCHAR,Alpha_Emp_Code)+ '  -  '+ Emp_Full_Name + '</option>'  
 FROM T0080_EMP_MASTER WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  and  Emp_Left <> 'y'  
  
 SELECT @lSectionResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lSectionResult = @lSectionResult + '<option value="' + CONVERT(VARCHAR,Section_ID) + '">' + Section_Name + '</option>'  
 FROM KPMS_T0020_Section_Master WITH(NOLOCK) WHERE IsActive= 1 AND Cmp_ID = @rCmpId  
  
 SELECT @lGoalResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lGoalResult = @lGoalResult + '<option value="' + CONVERT(VARCHAR,Goal_ID) + '">' + Goal_Name + '</option>'  
 FROM KPMS_T0020_Goal_Master WITH(NOLOCK) WHERE IsActive= 1 AND Cmp_ID = @rCmpId  

  
 SELECT @lYearResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lYearResult = @lYearResult + '<option ' + CASE WHEN IsDefault = 1 THEN 'selected="selected"' else '' end + ' value="' + CONVERT(VARCHAR,Batch_Detail_Id) + '">' + CONVERT(VARCHAR,YEAR(From_Date)) + ' - ' + CONVERT(VARCHAR,YEAR(To_Date)) + '</option>'  
 FROM KPMS_T0020_BatchYear_Detail WITH(NOLOCK) WHERE IsActive = 1  AND IsDefault = 1-- AND Cmp_ID = @rCmpId
  
  SELECT @lGoalSheet = '<option value="0"> -- Select -- </option>'  
 SELECT @lGoalSheet = @lGoalSheet + '<option value="' + CONVERT(VARCHAR,GS_Id) + '">' + GS_SheetName + '</option>'  
 FROM KPMS_T0100_Goal_Setting WITH(NOLOCK) WHERE GS_StatusId= 1 AND Cmp_ID = @rCmpId and IsLock= 1 and IsDraft = 0  
  
  SELECT @lGoalResult_depe = '<option value="0"> -- Select -- </option>'  
 SELECT @lGoalResult_depe = @lGoalResult_depe + '<option value="' + CONVERT(VARCHAR,GS_Id) + '">' + GS_SheetName + '</option>'  
 FROM KPMS_T0100_Goal_Setting_WithoutDepe WITH(NOLOCK) WHERE GS_StatusId= 1 AND Cmp_ID = @rCmpId and IsLock= 1 --and IsDraft = 0 

 SELECT @lDeptResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lDeptResult = @lDeptResult + '<option value="' + CONVERT(VARCHAR,Dept_Id) + '">' + Dept_Name + '</option>'  
 FROM T0040_DEPARTMENT_MASTER WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  
  
 SELECT @lDesiResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lDesiResult = @lDesiResult + '<option value="' + CONVERT(VARCHAR,Desig_ID) + '">' + Desig_Name + '</option>'  
 FROM T0040_DESIGNATION_MASTER WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  
  
 select @lEmpFullName = '<option value = "0">-- Select -- </option>'
 select @lEmpFullName = @lEmpFullName + '<option value = "'+CONVERT(VARCHAR,EMP_ID)+'"> '+ Emp_Full_Name +' </option>'  from T0080_EMP_MASTER WHERE Cmp_ID = @rCmpId  and  Emp_Left <> 'y'     

 SELECT @lSatusResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lSatusResult = @lSatusResult + '<option value="' + CONVERT(VARCHAR,Status_ID) + '">' + Status_Name + '</option>'  
 FROM KPMS_T0040_GoalStatus_Master WITH(NOLOCK) where Cmp_ID = @rCmpId 
  
 SELECT @lLevelResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lLevelResult = @lLevelResult + '<option value="' + CONVERT(VARCHAR,Level_Group_ID) + '">' + Level_Group_Name + '</option>'  
 FROM KPMS_T0040_Level_Group_Master WITH(NOLOCK) 
  
 SELECT @rCmpId AS CmpId  
 ,@lSectionResult AS SectionResult,REPLACE(@lSectionResult,'-- Select --','-- ALL --') AS SectionResultALL  
 ,@lGoalResult AS GoalResult,REPLACE(@lGoalResult,'-- Select --','-- ALL --') AS GoalResultALL  
 ,@lYearResult AS YearResult,REPLACE(@lYearResult,'-- Select --','-- Select --') AS YearResultALL  
 ,@lGoalSheet AS GoalSheet,@lDeptResult as DeptResult, @lDesiResult as DesigResult,@lEmpResult as EmpResult  
 ,@lSatusResult as StatusResult,@lEmpFullName AS EmpFullNameResult,REPLACE(@lEmpFullNameResult,'-- Select --','-- Select --') AS EmpFullNameResult  
 ,@lLevelResult as LevelResult ,@lGoalResult_depe as GoalResult_Withoutdepe  
  
END  

