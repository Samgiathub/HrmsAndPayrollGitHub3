


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_Password_Format_Setting]    
    @Pwd_ID int out,
	@cmp_ID int,
	@Name varchar(max),
	@Format_ID varchar(max)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Update T0250_Password_Format_Setting set  Format_ID =@Format_ID where Pwd_ID = @Pwd_ID and Cmp_ID = @cmp_ID
  
  
			
RETURN




