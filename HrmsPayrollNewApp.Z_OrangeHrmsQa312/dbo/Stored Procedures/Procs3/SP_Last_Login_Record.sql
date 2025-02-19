



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Last_Login_Record]
	@CMP_ID		NUMERIC 	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		Declare @For_date as DateTime
 		Select @For_Date = Max(Login_date) from T0011_Login_history WITH (NOLOCK) where Cmp_ID=@Cmp_ID
                Select Cast(Login_date as Varchar) as Login_Date from T0011_Login_history WITH (NOLOCK)
                      where Login_date=@For_Date and Cmp_ID = @Cmp_ID
	
		
	RETURN




