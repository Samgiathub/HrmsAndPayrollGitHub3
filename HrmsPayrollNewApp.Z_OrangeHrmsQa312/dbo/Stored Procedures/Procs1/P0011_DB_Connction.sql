



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_DB_Connction]
	  @row_id		 numeric(18) output
	 ,@database_name varchar(100)
	 ,@User_id       varchar(50) 
	 ,@pwd           varchar(50)
	 ,@connection    varchar(500)
	 ,@cmp_id        numeric(18,0)
	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
			if exists (Select @row_id  from T0011_DB_Connction WITH (NOLOCK) Where Upper(database_name) = Upper(@database_name)and isnull(Cmp_ID,0) = @Cmp_ID) 
				begin
					set @row_id=0
				end
			else
				begin
					select @row_id = (isnull(max(row_id),0) + 1) from T0011_DB_Connction WITH (NOLOCK)
					
					insert into T0011_DB_Connction(row_id,database_name,user_id,pwd,connection,Cmp_ID) values(@row_id,@database_name,@user_id,@pwd,@connection,@cmp_ID)
				end
RETURN




