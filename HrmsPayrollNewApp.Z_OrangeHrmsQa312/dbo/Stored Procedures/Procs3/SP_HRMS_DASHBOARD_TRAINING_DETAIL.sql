



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_DASHBOARD_TRAINING_DETAIL]
	@Cmp_ID numeric(18,0),
	@Training_Status Char(1)	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Training_Status = 'A' 	
	  Begin 

	  select dbo.T0110_Training_Application_Detail.Training_App_ID,Training_Title,Skill_name,dbo.T0080_Emp_Master.Emp_Full_name,App_Status,'Approved' as Status  from v0100_Training_Application inner join T0110_Training_Application_Detail WITH (NOLOCK) on
			dbo.V0100_Training_Application.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master WITH (NOLOCK) on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.V0100_Training_Application.cmp_id = @Cmp_ID and dbo.V0100_Training_Application.App_Status = @Training_Status
			
	 End
	 
	 else if 	@Training_Status='R'
			
			select dbo.T0110_Training_Application_Detail.Training_App_ID,Training_Title,Skill_name,dbo.T0080_Emp_Master.Emp_Full_name,App_Status,'Reject' as Status  from v0100_Training_Application inner join T0110_Training_Application_Detail WITH (NOLOCK) on
			dbo.V0100_Training_Application.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master WITH (NOLOCK) on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.V0100_Training_Application.cmp_id = @Cmp_ID and dbo.V0100_Training_Application.App_Status = @Training_Status
			
	 else if 	@Training_Status='N'
			
			select dbo.T0110_Training_Application_Detail.Training_App_ID,Training_Title,Skill_name,dbo.T0080_Emp_Master.Emp_Full_name,App_Status,'New' as Status  from v0100_Training_Application inner join T0110_Training_Application_Detail WITH (NOLOCK) on
			dbo.V0100_Training_Application.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master WITH (NOLOCK) on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.V0100_Training_Application.cmp_id = @Cmp_ID and dbo.V0100_Training_Application.App_Status = @Training_Status		
	    	
	RETURN




