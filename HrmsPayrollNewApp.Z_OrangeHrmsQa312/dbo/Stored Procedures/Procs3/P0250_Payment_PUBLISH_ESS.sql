


-- created by rohit for publish payment slip option on 25-apr-2017
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_Payment_PUBLISH_ESS]
	 @Publish_ID  numeric output
	,@Cmp_Id numeric(18,0)
	,@Branch_ID  numeric(18,0)
	,@Month numeric(5,0)
	,@Year numeric(5,0)
	,@Is_Publish tinyint
	,@User_ID numeric(18,0)
	,@Emp_ID numeric(18,0)
	,@Comments as varchar(max) = ''
	,@Ad_id as numeric(18,0)
	,@Process_Type as varchar(500)
	,@process_type_id as numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @process_id as numeric(18,0)
set @process_id = @process_type_id
if @process_type_id >=9000
	BEGIN
--		set @Ad_id = 0
		set @process_id = 0
	END

					if exists (select 1 from T0250_Payment_PUBLISH_ESS WITH (NOLOCK) where MONTH = @Month and YEAR = @Year and Cmp_ID = @Cmp_Id and Emp_ID = @Emp_ID and Ad_id = @Ad_id AND Process_Type = @Process_Type and process_type_id = @process_id)
						begin	
						
							UPDATE    T0250_Payment_PUBLISH_ESS
								SET Is_Publish = @Is_Publish, User_ID = @User_ID, System_Date = GETDATE()
								,Comments = @Comments
								  where MONTH = @Month and YEAR = @Year and Cmp_ID = @Cmp_Id  and Emp_Id = @Emp_ID and Ad_id = @Ad_id AND Process_Type = @Process_Type and process_type_id = @process_id
						end
					else
					begin
							select @Publish_ID = Isnull(max(Publish_ID),0) + 1 	From T0250_Payment_PUBLISH_ESS	WITH (NOLOCK)
							INSERT INTO T0250_Payment_PUBLISH_ESS
						(Publish_ID, Cmp_ID, Branch_ID,Emp_ID, Month,Year, Is_Publish, User_ID, System_Date,Comments,Ad_id,Process_Type,process_type_id)
						VALUES  (@Publish_ID,@Cmp_ID,@Branch_ID,@Emp_ID,@Month,@Year,@Is_Publish,@User_ID,GETDATE(),@Comments,@Ad_id, @Process_Type ,@process_id)
						
					end

	RETURN




