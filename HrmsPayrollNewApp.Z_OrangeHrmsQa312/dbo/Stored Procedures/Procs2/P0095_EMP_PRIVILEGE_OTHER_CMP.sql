

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_EMP_PRIVILEGE_OTHER_CMP]
	@Cmp_id numeric(18),
	@Emp_id numeric(18),
	@O_Cmp_id numeric(18),
	@O_Privilege_id numeric(18),
	@Tran_Type nvarchar(1) ,
	@Privilege_For	Numeric(18) = 0		-- Parameter ** 0-Employee : 1-Guest User	----Ankit 22062015
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
		if @Tran_Type = 'I'
			begin
			
				IF @Privilege_For = 0
					BEGIN
						IF not exists (SELECT 1 from T0095_EMP_PRIVILEGE_OTHER_CMP WITH (NOLOCK) where Emp_id = @Emp_id AND O_Privilege_id = @O_Privilege_id)
							begin
								INSERT INTO T0095_EMP_PRIVILEGE_OTHER_CMP
											  (Cmp_id, Emp_id, O_Cmp_id, O_Privilege_id, is_active, Last_Updated)
								VALUES     (@Cmp_id,@Emp_id,@O_Cmp_id,@O_Privilege_id,1,getdate())
							end
					END
				ELSE IF @Privilege_For = 1
					BEGIN
						IF not exists (SELECT 1 from T0095_EMP_PRIVILEGE_OTHER_CMP WITH (NOLOCK) where Login_ID = @Emp_id AND O_Privilege_id = @O_Privilege_id)
							begin
								INSERT INTO T0095_EMP_PRIVILEGE_OTHER_CMP
											  (Cmp_id, Emp_id, O_Cmp_id, O_Privilege_id, is_active, Last_Updated,Login_Id)
								VALUES     (@Cmp_id,0,@O_Cmp_id,@O_Privilege_id,1,getdate(),@Emp_id)
							end
					END	
					
			end
		else if  @Tran_Type = 'D'
			begin
			
				IF @Privilege_For = 0
					BEGIN
						Delete T0095_EMP_PRIVILEGE_OTHER_CMP where Cmp_id = @Cmp_id and Emp_id = @Emp_id
					END
				ELSE IF @Privilege_For = 1
					BEGIN
						Delete T0095_EMP_PRIVILEGE_OTHER_CMP where Cmp_id = @Cmp_id and Login_ID = @Emp_id
					END	
					
			end
		else if  @Tran_Type = 'S'
			BEGIN
				select * from T0095_EMP_PRIVILEGE_OTHER_CMP WITH (NOLOCK) where Emp_id =@Emp_id
			end
END

