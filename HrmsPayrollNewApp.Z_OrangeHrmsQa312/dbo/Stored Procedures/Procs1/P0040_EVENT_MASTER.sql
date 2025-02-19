



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_EVENT_MASTER]
	  @Event_ID	numeric(18, 0) output
	 ,@Cmp_Id numeric(10)
	 ,@Emp_ID numeric(10)
	 ,@Event_Name varchar(50)
	 ,@Event_Type varchar(50)
	 ,@Event_Date datetime
	 ,@Event_Repeate varchar(50)
	 ,@Event_Show varchar(50)
	 ,@tran_type char
	 ,@Show_All numeric
	 ,@Login_Id numeric = 0
	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


if @tran_type ='I' 
		begin
				select @Event_ID = isnull(max(Event_ID),0) + 1 from T0040_Event_Master WITH (NOLOCK)
						
					insert into T0040_Event_Master
					(Event_ID,Cmp_Id,Emp_ID,Event_Name,Event_Type,Event_Date,Event_Repeate,Event_Show,ShowAll,Login_Id) 
					
					values(@Event_ID,@Cmp_Id,@Emp_ID,@Event_Name,@Event_Type,@Event_Date,@Event_Repeate,@Event_Show,@Show_All,@Login_Id)

		end 
	else if @tran_type ='U' 
		begin
			
				Update T0040_Event_Master 
				Set Event_ID = @Event_ID
				   ,Cmp_Id=@Cmp_ID 
				   ,Emp_ID=@Emp_ID
				   ,Event_Name=@Event_Name
				   ,Event_Type=@Event_Type
				   ,Event_Date=@Event_Date
				   ,Event_Repeate=@Event_Repeate
				   ,Event_Show=@Event_Show
				   ,ShowAll=@Show_All
				   ,Login_Id = @Login_Id
				where Event_ID = @Event_ID 
		end	
	else if upper(@tran_type) ='D'
		Begin
			delete  from T0040_Event_Master where Event_ID = @Event_ID 
		end
			

	RETURN




