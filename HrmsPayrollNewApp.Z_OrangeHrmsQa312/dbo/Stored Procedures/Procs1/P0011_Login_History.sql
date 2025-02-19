



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_Login_History]
	@Row_ID AS NUMERIC output,
	@Login_Name AS VARCHAR(50),
	@Login_Date AS DateTime,
	@Ip_Address as varchar(100),
	@tran_type varchar(1)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 if @Tran_Type = 'D'
		begin
				Delete From T0011_Login_History Where Row_ID= @Row_ID
		end

	RETURN




