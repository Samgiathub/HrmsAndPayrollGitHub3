

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_Medical_Checkup] 
 @Tran_ID		NUMERIC(18,0) OUTPUT
,@Cmp_ID        numeric(18,0)
,@Emp_ID        numeric(18,0)
,@Medical_ID    numeric(18,0)
,@For_Date		datetime 
,@Description   varchar(max)
,@tran_type		char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @tran_type = 'I'
		begin
				IF Not EXISTS( SELECT Tran_ID FROM dbo.T0090_EMP_Medical_Checkup WITH (NOLOCK)
							WHERE cmp_ID= @cmp_ID and emp_ID = @Emp_ID and Medical_ID = @Medical_ID 
									and For_Date = @For_Date )
				BEGIN
					select @Tran_ID = isnull(MAX(Tran_ID),0) + 1 from dbo.T0090_EMP_Medical_Checkup WITH (NOLOCK)
					Insert into dbo.T0090_EMP_Medical_Checkup(Tran_ID,Cmp_ID,Emp_ID,Medical_ID,For_Date,Description)  
						values(@Tran_ID,@Cmp_ID,@Emp_ID,@Medical_ID,@For_Date,@Description)	
				END
			else
				Begin
						set @Tran_ID = 0
						return
				end
			
		end
	else if @tran_type = 'U'
		begin
				If exists (
							SELECT Tran_ID FROM dbo.T0090_EMP_Medical_Checkup WITH (NOLOCK)
							WHERE cmp_ID= @cmp_ID and emp_ID = @Emp_ID and Medical_ID = @Medical_ID 
							and For_Date = @For_Date and Tran_ID = @Tran_ID
					  )
				begin			
						Update dbo.T0090_EMP_Medical_Checkup set 
						cmp_ID = @Cmp_ID,
						emp_ID = @Emp_ID,
						Medical_ID = @Medical_ID,
						For_Date = @For_Date,
						Description = @Description		
						where Tran_ID = @Tran_ID
				end
			else
				begin
					set @Tran_ID = 0
						return
				end
			
		end
	else if @tran_type = 'D' 
		begin
			--Added for Delete Message Not display successfully after Medical Record Deleted --Ankit 30112015
			SELECT TOP 1 @Tran_ID = Tran_Id FROM  dbo.T0090_EMP_Medical_Checkup WITH (NOLOCK) where For_Date = @For_Date and Emp_ID = @Emp_ID
			
			delete from  dbo.T0090_EMP_Medical_Checkup where For_Date = @For_Date and Emp_ID = @Emp_ID	
		end
	
		
	
RETURN




