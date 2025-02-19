

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Sp_Check_Mac_Address]
	@UserName varchar(100),
	@Password varchar(500),
	@Mac_Address varchar(100)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	Declare @Login_ID as Numeric(18,0)
	Set @Login_ID = 0

    -- Insert statements for procedure here
    
    
	Select @Login_ID = Login_ID From T0011_LOGIN WITH (NOLOCK) Where (Login_Name = @UserName OR Login_Alias = @UserName) and Login_Password = @Password
	 if @Login_ID > 0  
		Begin
			Select EM.Emp_Full_Name,EM.Work_Email,LH.Ip_Address,
			--Replace(CONVERT(varchar(20),LH.Login_Date,105),'-','/') as Login_Date,
			convert(varchar(10),LH.Login_Date, 105) + right(convert(varchar(32),LH.Login_Date,100),8) as Login_Date,
			--Isnull(LH.MacAddress,'') as MacAddress,
			(Select MAX(MacAddress) From T0011_Login_History WITH (NOLOCK) Where Login_ID = @Login_ID and Login_Date < LH.Login_Date) as MacAddress,
			0 As MasterPwd,Isnull(LH.InterNetIP,'') as InterNetIP
			From T0011_Login_History LH WITH (NOLOCK)
			Inner JOIN (
					Select MAX(Login_Date) as LoginDate,Login_ID
					From T0011_Login_History WITH (NOLOCK) Where Login_ID = @Login_ID
					--AND Login_Date Not IN(
					--					Select MAX(Login_Date) as LoginDate
					--					From T0011_Login_History Where Login_ID = @Login_ID
					--		       )
					Group By Login_ID 
				) as Qry
			ON LH.Login_ID = Qry.Login_ID and LH.Login_Date = Qry.LoginDate
			Inner JOIN T0011_LOGIN TL WITH (NOLOCK) ON TL.Login_ID = LH.Login_ID
			Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = TL.Emp_ID
			Where LH.Login_ID = @Login_ID
		End
	Else
		Begin
			Select 1 As MasterPwd
		End	
END


