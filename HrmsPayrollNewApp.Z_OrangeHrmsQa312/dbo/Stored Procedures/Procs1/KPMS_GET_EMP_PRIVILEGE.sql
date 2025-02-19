


  -- EXEC KPMS_GET_EMP_PRIVILEGE 14565
CREATE PROCEDURE [dbo].[KPMS_GET_EMP_PRIVILEGE]  
  @Emp_ID AS numeric
AS  
 Set Nocount on   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
  
BEGIN

select M.Module_Name,P.Page_Name,A.*,B.* from KPMS_T0100_Emp_Role_Assign as A Inner Join KPMS_T0125_Page_Rights AS B 
On  A.Emp_Role_Id = B.Emp_Role_Id
Inner join KPMS_T0120_Page_Master as P On P.Page_Id = B.Page_Id 
Inner Join KPMS_T0110_Module_Master as M On M.Module_Id = B.Module_Id
Where Emp_id = @Emp_Id

/*
 declare @Module_Status as varchar(max)  
 declare @Module as varchar(max)  
 declare @PageRight as varchar(max)  
						
			select B.Emp_Id , C.Module_Id,	Page_Id	,Is_Save,	Is_Edit	,Is_Delete,	Is_View 
			from KPMS_T0125_Page_Rights AS A Inner Join KPMS_T0100_Emp_Role_Assign  AS B
			On A.Emp_Role_Id = B.Role_Id 
			Inner Join KPMS_T0115_Module_Rights as C On A.Module_Id = C.Module_Id 
			And C.Emp_Role_Id = A.Emp_Role_Id 
			Where B.Emp_Id = @Emp_ID

	
			--select * from KPMS_T0100_Emp_Role_Assign as era inner join KPMS_T0125_Page_Rights as pr on era.Role_Id = pr.Emp_Role_Id where Emp_Id = 14565
*/

END  