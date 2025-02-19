




CREATE PROCEDURE [dbo].[ChangePassword]
	  @User_Id	numeric output	 
	 ,@Current_Password varchar(150)	-- Incresed lenth by Niraj (25032022) : Dishman Pharma
	 ,@Password	varchar(150)	-- Incresed lenth by Niraj (25032022) : Dishman Pharma
	 ,@Cmp_Id numeric	-- added by Alpesh 19-May-2011
AS

--if @Login_Name =''
--  set @Login_Name=''

  if @Current_Password=''
   set @Current_Password=''
   
   declare @Emp_Id numeric -- added by Alpesh 25-May-2011 
  
 -- changed by Alpesh 25-May-2011  
 If exists(select Login_ID from dbo.T0011_LOGIN WITH (NOLOCK) where Login_ID = @User_Id and Login_Password=@Current_Password and Cmp_ID=@Cmp_Id)
	Begin
		Update dbo.T0011_LOGIN  Set Login_Password = @Password	where Login_ID = @User_Id and Login_Password=@Current_Password  and Cmp_ID=@Cmp_Id
		
		select @Emp_Id=Emp_ID from dbo.T0011_LOGIN WITH (NOLOCK)   where Login_ID = @User_Id and Login_Password=@Password and Cmp_ID=@Cmp_Id
		
		--Added By Hiral 04 June, 2013 (To keep history of change password) (Start)
		Declare @Tran_ID As Numeric(18,0)
		select @Tran_ID = Isnull(Max(Tran_ID),0) + 1  from dbo.T0250_Change_Password_History WITH (NOLOCK) 
		Insert Into T0250_Change_Password_History
				(Tran_ID, Cmp_ID, Emp_ID, Password, Effective_From_Date)
			Values(@Tran_ID, @Cmp_Id, @Emp_Id, @Password, Getdate())
		--Added By Hiral 04 June, 2013 (To keep history of change password) (End)
		
		if exists(Select Chg_Pwd From dbo.T0080_Emp_Master WITH (NOLOCK)  Where Cmp_id=@Cmp_Id and Emp_ID=@Emp_Id and isnull(Chg_Pwd,0)=0)
		begin					
			Update dbo.T0080_Emp_Master Set Chg_Pwd = 2 Where Cmp_id=@Cmp_Id and Emp_ID=@Emp_Id and isnull(Chg_Pwd,0)=0
		end
     End 
  Else
	Begin
	  Set @User_Id=-1
	End
RETURN
--if @Login_Name =''
      	--  Begin		
		--  End	
      --else 
		--	Begin
	  	--		Update dbo.T0011_LOGIN  Set Login_Password = @Password	where Login_ID = @User_Id  and Login_Name=@Login_Name
		--	End	




