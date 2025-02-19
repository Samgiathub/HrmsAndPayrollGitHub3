
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_Login]
	@Login_ID numeric(18,0) output
   ,@Cmp_ID numeric(18,0)
   ,@Login_Name varchar(50)
   ,@Login_Password varchar(max)
   ,@Emp_ID numeric(18,0)
   ,@Branch_ID numeric(18,0)
   ,@Login_Rights_ID numeric(18,0)
   ,@trans_type char(1)
   ,@Is_Default numeric =0 -----1-->admin,2-->Employee,3-->Branch User(which Is Created By Default At Branch Create)Nikunj 21-04-2011
   ,@IS_HR tinyint = 0
   ,@Is_Accou tinyint =0
   ,@Email_ID varchar(60)=''
   ,@A_Email_ID varchar(60)='',
   @ChangedBy	Numeric = 0 ,
   @ChangedFromIP	Varchar(128) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Emp_ID = 0
		set @Emp_ID = null
		
	if @Branch_ID = 0				-- Added by Gadriwala 12022014
		set @Branch_ID = null	
		
	if @Login_Rights_ID = 0			-- Added by Gadriwala 12022014
		set @Login_Rights_ID =null
	
	Declare @Effective_Date Datetime	--Ankit 28032014
	IF Exists (Select 1 From T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID And Cmp_ID  = @Cmp_ID)
		Begin
			Select @Effective_Date = Date_Of_Join From T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID And Cmp_ID  = @Cmp_ID
		End
	Else
		Begin
			Select @Effective_Date = From_Date From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id = @Cmp_ID
		End

	--For Old Values in Audit Trail
	SELECT * INTO #T0011_LOGIN_DELETED FROM T0011_LOGIN WITH (NOLOCK) WHERE Emp_ID=@Emp_ID
		
	If @trans_type = 'I'
	begin
			--IF EXISTS(SELECT Login_ID from dbo.T0011_LOGIN where Login_Name = @Login_Name )
			--	begin
			--		set @Login_ID = 0
			--		REturn 
			--	end
			
			--**\\Changed the Condition for Company Transfer Case on 15/10/2015 By Ramiz and Ankit\\**--
			
			IF EXISTS(SELECT LO.Login_ID from dbo.T0011_LOGIN LO WITH (NOLOCK) inner join T0080_EMP_MASTER EM WITH (NOLOCK) on lo.Emp_ID = EM.Emp_ID where Login_Name = @Login_Name and Emp_Left <> 'Y') 
				begin
					set @Login_ID = 0
					REturn 
				end
			--**\\Ends Here\\**--
			
			 select @Login_ID = isnull(max(Login_ID),0) + 1  from dbo.T0011_LOGIN WITH (NOLOCK)
			 
			 INSERT INTO dbo.T0011_LOGIN
								   (Login_ID, Cmp_ID, Login_Name, Login_Password,Emp_ID,Branch_ID,Login_Rights_ID,Is_Default,IS_HR,Is_Accou,Email_ID,Email_ID_Accou,Effective_Date)
			 VALUES     (@Login_ID,@Cmp_ID,@Login_Name,@Login_Password,@Emp_ID,@Branch_ID,@Login_Rights_ID,@Is_Default,@IS_HR,@Is_Accou,@Email_ID,@A_Email_ID,@Effective_Date)
		end
	Else If @trans_type = 'U'
		begin
			IF EXISTS(SELECT Login_ID from dbo.T0011_LOGIN WITH (NOLOCK) where Login_Name = @Login_Name and Login_ID <> @Login_ID)
				begin
					set @Login_ID = 0
					REturn 
				end
			UPDATE    dbo.T0011_LOGIN
			SET       Login_Name = @Login_Name
					  ,Login_Password = @Login_Password
					  ,Emp_ID=@Emp_ID
					  ,Branch_ID=@Branch_ID
					  ,Login_Rights_ID=@Login_Rights_ID
					  ,Is_Default =@Is_Default
					  ,IS_HR=@IS_HR
					  ,Is_Accou=@Is_Accou
					  ,Email_ID=@Email_ID
					  ,Email_ID_Accou=@A_Email_ID
			WHERE      Login_ID = @Login_ID And Cmp_Id=@Cmp_Id
		end
	Else If @trans_type = 'D'
		begin
			DELETE FROM dbo.T0011_LOGIN WHERE Login_ID=@Login_ID And Cmp_Id=@Cmp_Id
		end

	--For New Values in Audit Trail
	SELECT * INTO #T0011_LOGIN_INSERTED FROM T0011_LOGIN WITH (NOLOCK) WHERE Emp_ID=@Emp_ID
	
	EXEC P9999_AUDIT_LOG @TableName='T0011_LOGIN', @IDFieldName='Login_ID',@Audit_Module_Name='Employee Login',
		@User_Id=@ChangedBy,@IP_Address=@ChangedFromIP,@MandatoryFields='Login_Name,Emp_ID',
		@Audit_Change_Type=@trans_type	
	RETURN




