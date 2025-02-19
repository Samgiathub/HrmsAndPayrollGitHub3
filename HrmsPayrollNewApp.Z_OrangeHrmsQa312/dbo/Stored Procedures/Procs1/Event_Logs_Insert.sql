

-- =============================================
-- Author     :	Alpesh
-- ALTER date: 23-May-2012
-- Description:	
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Event_Logs_Insert]
 @Log_Id		numeric(18, 0)
,@Cmp_Id		numeric(18, 0)
,@Emp_Id		numeric(18, 0)
,@Login_Id		numeric(18, 0)
,@Module_Name	nvarchar(100)
,@Error_Name	nvarchar(100)
,@Description	nvarchar(MAX)
,@Event_Flag	tinyint
,@Remarks		nvarchar(MAX)
,@SysDate		DateTime = NULL

AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @SysDate IS NULL
		SET @SysDate = GETDATE()
	

	begin tran
	--Changed by Gadriwala Muslim 17012017
	--if not exists(select log_id from Event_Logs where @Module_Name = @Module_Name and Emp_Id = @Emp_Id and Description = @Description)
	--	begin

			Select @Log_Id = ISNULL(max(Log_Id),0)+1 from Event_Logs WITH (NOLOCK)
			
			Insert Into Event_Logs (Log_Id,Cmp_Id,Emp_Id,Login_Id,Module_Name,Error_Name,Description,System_Date,Event_Flag,Remarks)
			Values (@Log_Id,@Cmp_Id,@Emp_Id,@Login_Id,@Module_Name,@Error_Name,@Description,@SysDate,@Event_Flag,@Remarks)
	--	end
	--else
	--	begin	
			
	--		Select @Log_Id =  Log_Id  from Event_Logs where @Module_Name = @Module_Name and Emp_Id = @Emp_Id and Description = @Description
			
	--			UPDATE    Event_Logs
	--			SET       Error_Name = @Error_Name, 
	--					  Description = @Description, 
	--					  System_Date = GETDATE(), 
	--					  Event_Flag = @Event_Flag, 
	--					  Remarks = @Remarks
	--			WHERE Log_Id = @Log_Id
			
	--	end
	
	commit tran
END


