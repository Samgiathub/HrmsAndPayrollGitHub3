

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_WO_Application_Main]
	@WO_Application_Id as numeric(18,0) Output
	,@Cmp_Id as numeric(18,0)
	,@Emp_Id as numeric(18,0)
	,@S_Emp_Id as numeric(18,0)
	,@Status as varchar(1) = 'P'
	,@Login_Id as numeric(18,0)
	,@Month as numeric(18,0)
	,@Year as numeric(18,0)
	,@TRAN_TYPE VARCHAR(1)    --ADDED BY JAINA 13-09-2016
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
		Set @WO_Application_Id = 0
		
		--IF EXISTS (select WO_Application_Id from T0100_WO_Application_Main where Emp_Id = @Emp_Id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year And CONVERT(varchar(30),Application_Date,103) = CONVERT(varchar(30),GETDATE(),103)) 
		--	BEGIN
		--			Select @WO_Application_Id = WO_Application_Id from T0100_WO_Application_Main where Emp_Id = @Emp_Id and Cmp_Id = @Cmp_Id and MONTH = @Month and YEAR = @Year And CONVERT(varchar(30),Application_Date,103) = CONVERT(varchar(30),GETDATE(),103)
					
		--			Update T0100_WO_Application_Main 
		--			SEt Emp_Id = @Emp_Id,
		--			Cmp_Id	= @Cmp_Id,
		--			S_Emp_Id = @S_Emp_Id,
		--			Login_Id = @Login_Id,
		--			Application_Status = @Status					
		--			where WO_Application_Id = @WO_Application_Id
		--	END
		--ELSE
		--	BEGIN	
		--			Select @WO_Application_Id =  ISNULL(MAX(WO_Application_Id),0) + 1 from T0100_WO_Application_Main				
		--			INSERT INTO T0100_WO_Application_Main (WO_Application_Id,Cmp_Id,Emp_Id,S_Emp_Id,Application_Status,Login_Id,Month,Year)
		--			VALUES (@WO_Application_Id,@Cmp_Id,@Emp_Id,@S_Emp_Id,@Status,@Login_Id,@Month,@Year)
		--	END
		
		IF @TRAN_TYPE = 'I'
		Begin
			Select @WO_Application_Id =  ISNULL(MAX(WO_Application_Id),0) + 1 from T0100_WO_Application_Main WITH (NOLOCK)				
			
			INSERT INTO T0100_WO_Application_Main (WO_Application_Id,Cmp_Id,Emp_Id,S_Emp_Id,Application_Status,Login_Id,Month,Year)
			VALUES (@WO_Application_Id,@Cmp_Id,@Emp_Id,@S_Emp_Id,@Status,@Login_Id,@Month,@Year)
		End
		
		IF @TRAN_TYPE = 'U'
		Begin
			Update T0100_WO_Application_Main 
			SEt Emp_Id = @Emp_Id,
				Cmp_Id	= @Cmp_Id,
				S_Emp_Id = @S_Emp_Id,
				Login_Id = @Login_Id,
				Application_Status = @Status					
			where WO_Application_Id = @WO_Application_Id
		END
		
RETURN
END


