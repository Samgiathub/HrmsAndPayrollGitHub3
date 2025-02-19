



---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_WORK_MASTER]
	  @Work_ID numeric(18) output
	 ,@Work_Name varchar(50)
	 ,@Cmp_ID numeric(18,0)
	 ,@tran_type char
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @tran_type ='I' 
		begin
		
			if exists (Select Work_ID  from T0040_Work_Master WITH (NOLOCK) Where Upper(Work_Name) = Upper(@Work_Name)and Cmp_ID = @Cmp_ID) 
				begin
					set @Work_ID=0
				end
			else
				begin
					select @Work_ID = isnull(max(Work_ID),0) from T0040_Work_Master WITH (NOLOCK)
					if @Work_ID is null or @Work_ID = 0
						set @Work_ID =1
					else
						set @Work_ID = @Work_ID + 1			
						
					insert into T0040_Work_Master(Work_ID,Work_Name,Cmp_ID) values(@Work_ID,@Work_Name,@Cmp_ID)
					
				end
		end 
	else if @tran_type ='U' 
		begin
			if exists (Select Work_ID  from T0040_Work_Master WITH (NOLOCK) Where Upper(Work_Name )= upper(@Work_Name) and Work_ID <> @Work_ID and Cmp_ID = @Cmp_ID) 
				begin
					set @Work_ID=0
				end					
			else
				begin
					Update T0040_Work_Master Set Work_Name = @Work_Name where Work_ID = @Work_ID and Cmp_ID = @Cmp_ID 

				end
		end	
	else if 
	@tran_type ='d' or @tran_type ='D'
			delete  from T0040_Work_Master where Work_ID=@Work_ID 
			

	RETURN




