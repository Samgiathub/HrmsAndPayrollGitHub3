

CREATE PROCEDURE [dbo].[P0040_Sms_Setting]
	@Bd_ID As Numeric(18,0) Output,
	@Cmp_Id As Numeric(18,0),
	@Branch_Id As Numeric(18,0),
	@Url As Varchar(200),
	@UserId As Varchar(50),
	@Password As Varchar(50),
	@SenderId As Varchar(50),
	@Message_Text As Varchar(160),	
	@Trans_Type As Char(1),
	@Anniversary_Text As Varchar(160),	
	@Attendance_Text As Varchar(160),
	@ForgotPassword_Text As Varchar(250)=''
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

--Nikunj 18-Jan-2011
	 
	If @Branch_Id=0
	   Set @Branch_Id=NULL
	   
	 If @Trans_Type='I'	 
		Begin	
				If Exists(Select Bd_Id From dbo.T0040_Sms_Setting WITH (NOLOCK) Where ISNULL(Branch_Id,0)=ISNULL(@Branch_Id,ISNULL(Branch_Id,0)) And Cmp_Id=@Cmp_Id)
					Begin							
						Set @Bd_Id=0							
						Return 
					End
				
						Select @Bd_Id = IsNULL(Max(Bd_Id),0)+1 From dbo.T0040_Sms_Setting WITH (NOLOCK) 
		
			Insert Into dbo.T0040_Sms_Setting (Bd_Id,Cmp_Id,Branch_Id,Url,UserId,Password,SenderId,Message_Text,Anniversary_Text,Attendance_Text,ForgotPassword_Text)
			 Values (@Bd_Id,@Cmp_Id,@Branch_Id,@Url,@UserId,@Password,@SenderId,@Message_Text,@Anniversary_Text,@Attendance_Text,@ForgotPassword_Text)						
			
		End
	Else If @Trans_Type='U'	 
		Begin 
				Update dbo.T0040_Sms_Setting Set
					Cmp_Id = @Cmp_Id,
					Branch_Id = @Branch_Id,
					Url = @Url,
					UserId = @UserId,
					Password = @Password,
					SenderId = @SenderId,
					Message_Text = @Message_Text,
					Anniversary_Text =@Anniversary_Text,
					Attendance_Text = @Attendance_Text,
					ForgotPassword_Text=@ForgotPassword_Text
				Where Bd_Id = @Bd_Id
		End
	Else If @Trans_Type='D'
		Begin		
			Delete From dbo.T0040_Sms_Setting Where Bd_Id=@Bd_Id		
		End 
	RETURN




