CREATE PROCEDURE SP_LogIn_Log_Details (
@Type nvarchar(10),
@Cmp_Id	int	= null,
@User_Id	nvarchar(100)	= null,
@IPAddress	nvarchar(100)	= null
)
AS
Begin
	If @Type = 'LogIn'
	Begin
		IF EXISTS (select Top(1) * from  LogInLogDetails  where  USER_ID=@User_Id and IPAddress<>@IPAddress Order by Id Desc )
		Begin
			Select 1 as Islogged
		End
		Else
		Begin			
			IF Not EXISTS (select * from  LogInLogDetails  where  USER_ID=@User_Id and IPAddress=@IPAddress )
			Begin
				Insert into LogInLogDetails (Cmp_Id,User_Id,IPAddress,LogInDateTime)
				Values (@Cmp_Id,@User_Id,@IPAddress,GETDATE())
			End		
			Select 0 as Islogged
		End
	End

	If @Type = 'LogOut'
	Begin
		Delete from LogInLogDetails  where  USER_ID=@User_Id and IPAddress=@IPAddress 
	End

	If @Type = 'AllLogOut'
	Begin
		Delete from LogInLogDetails  where  USER_ID=@User_Id and IPAddress<>@IPAddress 
	End
End