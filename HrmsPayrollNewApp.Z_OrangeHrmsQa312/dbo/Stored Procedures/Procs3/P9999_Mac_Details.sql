

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Mac_Details]
	 @Tran_id as numeric(18) 
	,@Mac_master_id as numeric(18) 
	,@Cmp_id as numeric(18) 
	,@Mac_Address as varchar(50)
	,@Emp_id as numeric(18)
	,@Is_Active as numeric(18) 
	,@Modified_by as numeric(18) 
	,@Tran_Type as Varchar(1)
	,@PC_Name as varchar(50)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	
	Declare @Created_Date datetime
	Declare @Last_modified datetime
		
	set @Created_Date= getdate()
	set @Last_modified= getdate()
	
	if @Tran_Type = 'I'
		begin
			

			INSERT INTO T9999_MAC_DETAIL
					  (Mac_master_id, Cmp_id, Mac_Address, Emp_id, Is_Active, Created_Date, Last_modified, Modified_by,PC_Name)
			VALUES     (@Mac_master_id,@Cmp_id,@Mac_Address,@Emp_id,@Is_Active,@Created_Date,@Last_modified,@Modified_by,@PC_Name)
			
		end
	else if @Tran_type = 'U'
		begin
		
			UPDATE  T9999_MAC_DETAIL
			SET     Mac_Address = @Mac_Address, Emp_id = @Emp_id, Is_Active = @Is_Active, 
					Last_modified = @Last_modified, Modified_by = @Modified_by
					,PC_Name=@PC_Name
			Where	Tran_id = @Tran_id and Cmp_id = @Cmp_id
				
		end
	else if @Tran_type = 'D'
		begin
			
			Delete T9999_MAC_DETAIL where Tran_id = @Tran_id and Cmp_id = @Cmp_id --and Mac_master_id = @Mac_master_id
			
		end
END


