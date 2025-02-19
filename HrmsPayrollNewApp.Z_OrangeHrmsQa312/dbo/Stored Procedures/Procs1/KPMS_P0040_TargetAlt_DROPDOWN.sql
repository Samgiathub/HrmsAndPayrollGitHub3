CREATE PROCEDURE [dbo].[KPMS_P0040_TargetAlt_DROPDOWN]  
@rCmpId INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  

 DECLARE @lGoalSheet VARCHAR(MAX) = ''    
 DECLARE @lDesiResult VARCHAR(MAX) = ''    
 DECLARE @lDeptResult VARCHAR(MAX) = ''    
 DECLARE @lEmpResult VARCHAR(MAX) = ''    
 DECLARE @lSatusResult VARCHAR(MAX) = ''    
 DECLARE @lEmpFullNameResult VARCHAR(MAX) = ''  
 DECLARE @lLevelResult VARCHAR(MAX) = '' 
 	 DECLARE @lEmpFullName varchar(MAx)=''
  
  
  
 SELECT @lGoalSheet = '<option value="0"> -- Select -- </option>'  
 SELECT @lGoalSheet = @lGoalSheet + '<option value="' + CONVERT(VARCHAR,GS_Id) + '">' + GS_SheetName + '</option>'  
 FROM KPMS_T0100_Goal_Setting WITH(NOLOCK) WHERE GS_StatusId= 1 AND Cmp_ID = @rCmpId and IsLock= 1 and IsDraft = 0  

  select @lEmpFullName = '<option value = "0">-- Select -- </option>'
select @lEmpFullName = @lEmpFullName  + '<option value = "'+CONVERT(VARCHAR,gat.EMP_ID)+'"> '+ Emp_Full_Name +' </option>'  FROM KPMS_T0020_Goal_Allotment_Master_Test as gat inner join T0080_EMP_MASTER em on em.Emp_ID = gat.Emp_ID  WHERE gat.Cmp_ID = @rCmpId 

  
 SELECT @lDeptResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lDeptResult = @lDeptResult + '<option value="' + CONVERT(VARCHAR,gat.Dept_Id) + '">' +  Dept_Name + '</option>'  
FROM KPMS_T0020_Goal_Allotment_Master_Test as gat inner join T0040_DEPARTMENT_MASTER em on em.Dept_Id = gat.Dept_Id WHERE gat.Cmp_ID = @rCmpId  --group by gat.dept_Id
  
 SELECT @lDesiResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lDesiResult = @lDesiResult + '<option value="' + CONVERT(VARCHAR,gat.Desig_ID) + '">' + Desig_Name + '</option>'  
FROM KPMS_T0020_Goal_Allotment_Master_Test as gat inner join V0040_DESIGNATION_MASTER em on em.Desig_ID = gat.Desig_ID WHERE gat.Cmp_ID = @rCmpId  --group by gat.desig_id

  

 SELECT @lSatusResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lSatusResult = @lSatusResult + '<option value="' + CONVERT(VARCHAR,Status_ID) + '">' + Status_Name + '</option>'  
 FROM KPMS_T0040_GoalStatus_Master WITH(NOLOCK)   
  
  SELECT @lLevelResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lLevelResult = @lLevelResult + '<option value="' + CONVERT(VARCHAR,Level_Group_ID) + '">' + Level_Group_Name + '</option>'  
 FROM KPMS_T0040_Level_Group_Master WITH(NOLOCK)   
  
 SELECT @rCmpId AS CmpId  
 ,@lGoalSheet AS GoalSheet,@lDeptResult as DeptResult, @lDesiResult as DesigResult,@lEmpResult as EmpResult  
 ,@lSatusResult as StatusResult,@lEmpFullName AS EmpFullNameResult,REPLACE(@lEmpFullNameResult,'-- Select --','-- Select --') AS EmpFullNameResult  
 ,@lLevelResult as LevelResult  
   
  
END  
