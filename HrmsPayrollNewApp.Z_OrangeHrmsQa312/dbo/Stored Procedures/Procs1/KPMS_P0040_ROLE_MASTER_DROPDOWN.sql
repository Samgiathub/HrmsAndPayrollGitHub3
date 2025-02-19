-- EXEC P0040_ROLE_MASTER_DROPDOWN  
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN  
CREATE PROCEDURE [dbo].[KPMS_P0040_ROLE_MASTER_DROPDOWN]  
@rCmpId INT,  
@rCurrentDate VARCHAR(100),  
@rpBranchIdMulti VARCHAR(MAX),  
@rpBranchId INT,  
@rpDepartmentIdMulti VARCHAR(MAX),  
@rParentTaskId INT = NULL  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @lRoleResult VARCHAR(MAX) = '',@lTaskTypeResult VARCHAR(MAX) = ''  
 DECLARE @lProjectResult VARCHAR(MAX) = '',@lTaskCatResult VARCHAR(MAX) = ''  
 DECLARE @lStatusResult VARCHAR(MAX) = '',@lPriorityResult VARCHAR(MAX) = ''  
 DECLARE @lActivityResult VARCHAR(MAX) = '',@lEmpResult2 VARCHAR(MAX) = ''  
  
 DECLARE @lBranchResult VARCHAR(MAX) = '',@lDepartmentResult VARCHAR(MAX) = ''  
 DECLARE @lDesignationResult VARCHAR(MAX) = '',@lGradeResult VARCHAR(MAX) = ''  
 DECLARE @lTaskResult VARCHAR(MAX) = '',@lEmpResult VARCHAR(MAX) = ''  
  
 DECLARE @lDefaultStatusValue INT  
  

  
 SELECT @lEmpResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lEmpResult = @lEmpResult + '<option value="-101"><< Me >></option>'  
 SELECT @lEmpResult = @lEmpResult + '<option value="' + CONVERT(VARCHAR,eROLE.Emp_Id) + '">  
 ' + Alpha_Emp_Code + ' ' + ISNULL(Initial,'') + ' - ' + ISNULL(Emp_First_Name,'') + ' ' + ISNULL(Emp_Last_Name,'') + '</option>'  
 FROM KPMS_T0100_Emp_Role_Assign AS eROLE WITH(NOLOCK)  
 INNER JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON eROLE.Emp_Id = EMP.Emp_ID  
  
 SELECT @lEmpResult2 = @lEmpResult2 + '<span data-key="' + CONVERT(VARCHAR,eROLE.Emp_Id) + '">  
 <input id="cmbEmployee_' + CONVERT(VARCHAR,eROLE.Emp_Id) + '" type="checkbox" onclick="getValues(this);">  
 <label for="cmbEmployee_' + CONVERT(VARCHAR,eROLE.Emp_Id) + '">' + Alpha_Emp_Code + ' ' + ISNULL(Initial,'') + ' - ' + ISNULL(Emp_First_Name,'') + ' ' + ISNULL(Emp_Last_Name,'') + '</label></span><br>'  
 FROM KPMS_T0100_Emp_Role_Assign AS eROLE WITH(NOLOCK)  
 INNER JOIN T0080_EMP_MASTER AS EMP WITH(NOLOCK) ON eROLE.Emp_Id = EMP.Emp_ID  
    
 SELECT @lRoleResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lRoleResult = @lRoleResult + '<option value="' + CONVERT(VARCHAR,Role_Id) + '">' + Role_Name + '</option>'  
 FROM KPMS_T0020_Role_Master WITH(NOLOCK) WHERE IsActive= 1  AND Cmp_ID = @rCmpId


 SELECT @lBranchResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lBranchResult = @lBranchResult + '<option value="' + CONVERT(VARCHAR,Branch_ID) + '"  
 ' + CASE WHEN @rpBranchId = Branch_ID THEN 'selected="selected"' else '' end + '>' + Branch_Name + '</option>'  
 FROM T0030_Branch_master WITH(NOLOCK)  
 LEFT JOIN dbo.Split(@rpBranchIdMulti,'#') ON Data = Branch_ID AND Data <> '' AND Data <> 0  
 WHERE (InActive_EffeDate > @rCurrentDate OR InActive_EffeDate IS NULL)  
 AND Cmp_ID = @rCmpId ORDER BY Branch_Name  
  
 SELECT @lDesignationResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lDesignationResult = @lDesignationResult + '<option value="' + CONVERT(VARCHAR,Desig_ID) + '">' + Desig_Name + '</option>'  
 FROM T0040_DESIGNATION_MASTER WITH(NOLOCK)   
 WHERE (InActive_EffeDate > @rCurrentDate OR InActive_EffeDate IS NULL)  
 AND Cmp_ID = @rCmpId ORDER BY Desig_Name  
  
 SELECT @lDepartmentResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lDepartmentResult = @lDepartmentResult + '<option value="' + CONVERT(VARCHAR,Dept_Id) + '"  
 ' + CASE WHEN @rpBranchId = Dept_Id THEN 'selected="selected"' else '' end + '>' + Dept_Name + '</option>'  
 FROM T0040_Department_Master WITH(NOLOCK)  
 LEFT JOIN dbo.Split(@rpDepartmentIdMulti,'#') ON Data = Dept_Id AND Data <> '' AND Data <> 0  
 WHERE (InActive_EffeDate > @rCurrentDate OR InActive_EffeDate IS NULL)  
 AND Cmp_ID = @rCmpId ORDER BY Dept_Name  
 
  
 SELECT @rCmpId AS CmpId,convert(varchar,getdate(),103) AS TodayDate,  
 @lActivityResult AS ActivityResult,REPLACE(@lActivityResult,'-- Select --','-- ALL --') AS ActivityResultALL,  
 @lRoleResult AS RoleResult,REPLACE(@lRoleResult,'-- Select --','-- ALL --') AS RoleResultALL,   
 @lEmpResult AS EmpResult,REPLACE(@lEmpResult,'-- Select --','-- ALL --') AS EmpResultALL,  
 @lEmpResult2 AS EmpResult2,REPLACE(@lEmpResult2,'-- Select --','-- ALL --') AS EmpResult2ALL,  
 @lBranchResult AS BranchResult,REPLACE(@lBranchResult,'-- Select --','-- ALL --') AS BranchResultALL,  
 @lDesignationResult AS DesignationResult,REPLACE(@lDesignationResult,'-- Select --','-- ALL --') AS DesignationResultALL,  
 @lDepartmentResult AS DepartmentResult,REPLACE(@lDepartmentResult,'-- Select --','-- ALL --') AS DepartmentResultALL,  
 @lGradeResult AS GradeResult,REPLACE(@lGradeResult,'-- Select --','-- ALL --') AS GradeResultALL,  
 ISNULL(@lDefaultStatusValue,0) AS DefaultStatusValue  
END