-- EXEC KPMS_P0100_ROLE_MODULE_ASSIGN    
-- DROP PROCEDURE KPMS_P0100_ROLE_MODULE_ASSIGN    
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
CREATE PROCEDURE [dbo].[KPMS_P0100_ROLE_Module_ASSIGN]    
@rModule_Id INT,    
@rCmpId int,    
@rPermissionStr VARCHAR(MAX),    
@rType INT,    
@IsActive bit    
AS    
BEGIN    
 SET NOCOUNT ON;    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
 SET ARITHABORT ON;    
    
 IF @rType = 1    
  BEGIN    
       
    
   DECLARE @lXML XML    
   SET @lXML = CAST(@rPermissionStr AS xml)    
       
   DECLARE @tbltmp TABLE(tid INT IDENTITY(1,1),t_ModuleId INT,t_Status bit)   
   INSERT INTO @tbltmp     
   SELECT T.c.value('@ModuleId','INT') AS MainId,    
   T.c.value('@status','bit') AS status    
   FROM @lXML.nodes('/Permissions/Permission') AS T(c)    
       
   MERGE KPMS_T0115_Module_Rights AS TARGET    
   USING @tbltmp AS SOURCE ON t_ModuleId = Module_Id and Cmp_id = @rCmpId
   WHEN MATCHED THEN    
       
	UPDATE SET IsActive = t_Status,Emp_Role_Id = @rModule_Id, Modify_Date = getdate()    
   WHEN NOT MATCHED BY TARGET THEN    
    INSERT    
    (    
     Emp_Role_Id,Module_Id,IsActive,Cmp_id    
    )    
    VALUES    
    (    
     @rModule_Id,t_ModuleId,t_Status,@rCmpId    
    );    
  END      
 SELECT 1 AS res    
END  
  
