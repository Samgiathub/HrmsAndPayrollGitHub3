

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Update_Emp_Search_Type]
	  @Cmp_ID	numeric(18,0) 
	 ,@Emp_Id numeric(18,0) 
	 ,@Login_Id numeric(18,0) 
	 ,@Emp_Search_Type int
AS
Begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		If @Emp_Id > 0
			Begin
				Update dbo.T0011_LOGIN  Set Emp_Search_Type = @Emp_Search_Type	where Login_ID = @Login_Id and Emp_Id=@Emp_Id 
			End
		Else
			Begin
				Update dbo.T0011_LOGIN  Set Emp_Search_Type = @Emp_Search_Type	where Login_ID = @Login_Id
			End
End



