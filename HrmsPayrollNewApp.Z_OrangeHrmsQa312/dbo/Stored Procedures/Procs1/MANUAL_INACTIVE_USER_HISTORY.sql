




-- =============================================
-- Author:		<Alpesh>
-- ALTER date:  <20-Apr-2012>
-- Description:	
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[MANUAL_INACTIVE_USER_HISTORY]
  @History_Id	numeric  output      
 ,@Cmp_ID		numeric        
 ,@Login_Id 	numeric        
 ,@Reason		nvarchar(200)     
 ,@Is_Active	tinyint
 ,@User_ID 		numeric        
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	

	
	Declare @Emp_ID		numeric(18, 0)
	--Declare @History_Id	numeric(18, 0)
	Declare @Active_Status nvarchar(15)
	
	If @Is_Active = 0
		begin
			set @Active_Status = 'InActive'
		end
	Else
		begin
			set @Active_Status = 'Active'
		end
	
	if exists(Select Emp_ID from T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Login_ID=@Login_Id)
		Begin
			Select @Emp_ID = Emp_ID from T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Login_ID=@Login_Id	
			
			Update T0011_LOGIN set Is_Active=@Is_Active where Cmp_ID=@Cmp_ID and Login_ID=@Login_Id
			
			Select @History_Id = isnull(max(History_Id),0)+1 from T0020_INACTIVE_USER_HISTORY WITH (NOLOCK)
	
			Insert into T0020_INACTIVE_USER_HISTORY
			values(@History_Id,@Cmp_ID,@Emp_ID,@User_ID,@Reason,GETDATE(),@Active_Status)	
		End
	
	
	
END




