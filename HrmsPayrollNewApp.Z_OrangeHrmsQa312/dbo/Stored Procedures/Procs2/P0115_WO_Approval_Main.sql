

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0115_WO_Approval_Main]
	@WO_Approval_Id as numeric(18,0) Output
	,@WO_Application_Id as numeric(18,0) 
	,@Cmp_Id as numeric(18,0)
	,@Emp_Id as numeric(18,0)
	,@S_Emp_Id as numeric(18,0)
	,@Status as varchar(1)
	,@Login_Id as numeric(18,0)
	,@Month as numeric(18,0)
	,@Year as numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
		Set NoCount On;		
		Set @WO_Approval_Id = 0		
		
		IF EXISTS (Select WO_Approval_Id from  T0115_WO_Approval_Main WITH (NOLOCK) where WO_Application_Id = @WO_Application_Id and Cmp_Id = @Cmp_Id and Emp_Id = @Emp_Id and MONTH = @Month And Year = @Year)
			BEGIN
			
				Select @WO_Approval_Id = WO_Approval_Id from  T0115_WO_Approval_Main WITH (NOLOCK) where WO_Application_Id = @WO_Application_Id and Cmp_Id = @Cmp_Id and Emp_Id = @Emp_Id and MONTH = @Month And Year = @Year
				Update T0115_WO_Approval_Main 
					Set Cmp_Id = @Cmp_Id,Emp_Id = @Emp_Id, S_Emp_Id = @S_Emp_Id, Approva_Status = @Status
					Where WO_Approval_Id = @WO_Approval_Id
			END
		ELSE
			BEGIN
				Select @WO_Approval_Id =  ISNULL(MAX(WO_Approval_Id),0) + 1 from T0115_WO_Approval_Main	WITH (NOLOCK)			
				INSERT INTO T0115_WO_Approval_Main (WO_Approval_Id,WO_Application_Id,Cmp_Id,Emp_Id,S_Emp_Id,Approva_Status,Login_Id,Month,Year)
				VALUES (@WO_Approval_Id,@WO_Application_Id,@Cmp_Id,@Emp_Id,@S_Emp_Id,@Status,@Login_Id,@Month,@Year)
			END
		
		
RETURN
END


