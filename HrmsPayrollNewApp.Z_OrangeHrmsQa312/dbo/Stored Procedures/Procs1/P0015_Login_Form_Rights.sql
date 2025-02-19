



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0015_Login_Form_Rights]
			 @Tran_ID numeric(18) output
            ,@Login_ID numeric(18,0)
            ,@Cmp_ID numeric(18,0)
            ,@Form_ID numeric(18,0)
            ,@Branch_ID numeric(18,0)
            ,@Is_Save  Numeric(1,0)	
            ,@Is_Edit  Numeric(1,0)	
            ,@Is_Delete  Numeric(1,0)	
            ,@Is_View Numeric(1,0)
            ,@Is_Print Numeric(1,0)
            ,@Login_name Varchar(100)
            ,@Login_Password Varchar(100)
            ,@tran_type char
            ,@Is_HR tinyint 
            ,@Is_Accou tinyint
            ,@Email_ID varchar(60)
            ,@A_Email_ID varchar(60)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @loginname varchar(50)
	Declare @Domain_name varchar(50)
	Declare @count_@ numeric 
	declare @Login as numeric

   if @Login_Name=''
   set @Login_Name = ''
   
   if @Login_Password =''
   set @Login_Password=''
   
   if @Branch_ID = 0 
	   Set @Branch_ID = null
	   
	   
   
	 	Select @Domain_Name = Domain_Name From T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
	 	
	 	select @count_@ = dbo.OCCURS ('@',@Login_Name)
	 	
	 	
     	if substring(@Domain_Name,1,1) <> '@'	
			set @Domain_Name = '@' + @Domain_Name

		If @Count_@ >1 or (@Count_@ = 1 and charindex(@Domain_Name,@Login_Name,1)= 0 )
			begin
				raiserror('@@Wrong User Name@@',16,2)
				return
			end 
		Else if charindex(@Domain_Name,@Login_Name,1)> 0 
			set @loginname  = @Login_Name 
		Else 
			set @loginname = cast(@Login_Name as varchar(10)) + @Domain_Name		
	
	
	If @tran_type ='I' 
		begin	  
			
			IF  EXISTS(SELECT Login_ID  from T0011_LOGIN WITH (NOLOCK) where Login_Name = ltrim(@loginname) and Cmp_ID =@cmp_ID)
				 begin
						SELECT @Login_ID =Login_ID from T0011_LOGIN WITH (NOLOCK) where Login_Name = ltrim(@loginname) and Cmp_ID =@cmp_ID
				 end
			else
				begin	
					exec p0011_Login @Login_ID output,@Cmp_Id,@loginname,@Login_Password,0,null,null,'I',0,@Is_HR,@Is_Accou,@Email_ID,@A_Email_ID
				end
					
			
			  select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0015_Login_Form_Rights WITH (NOLOCK)

				Insert into T0015_Login_Form_Rights(Tran_ID,Login_ID,Cmp_ID ,Form_ID,Is_Save  ,Is_Edit,Is_Delete,Is_View,Is_Print)
            	values(@Tran_ID	,@Login_ID,@Cmp_ID ,@Form_ID,@Is_Save  ,@Is_Edit ,@Is_Delete,@Is_View,@Is_Print) 	
                   
			
            end 
                     
            Else if @tran_type='U'
				Begin
						Update T0011_LOGIN set IS_HR=@Is_HR,Is_Accou=@Is_Accou,Email_ID=@Email_ID,Email_ID_Accou=@A_Email_ID where Login_ID=@Login_ID
						
						if exists (select login_ID from T0015_Login_Form_Rights WITH (NOLOCK)  where form_ID =@Form_ID and Login_ID =@Login_ID )
							begin
									select @Tran_ID = Tran_ID from T0015_Login_Form_Rights WITH (NOLOCK)  where form_ID =@Form_ID and Login_ID =@Login_ID 
									Update T0015_Login_Form_Rights 
									set	   Is_Save=@Is_Save
										   ,Is_Edit=@Is_Edit
										   ,Is_Delete=@Is_Delete
										   ,Is_View=@Is_View
										   ,Is_Print=@Is_Print
									where Tran_ID = @Tran_ID  
								
							end
						else
							begin
									select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0015_Login_Form_Rights WITH (NOLOCK)

									Insert into T0015_Login_Form_Rights(Tran_ID,Login_ID,Cmp_ID ,Form_ID,Is_Save  ,Is_Edit,Is_Delete,Is_View,Is_Print)
									values(@Tran_ID	,@Login_ID,@Cmp_ID ,@Form_ID,@Is_Save  ,@Is_Edit ,@Is_Delete,@Is_View,@Is_Print) 	
								
							end
							
				End
				
	
	else if @tran_type ='D'
		Begin
			if exists(select Login_ID from T0011_Login WITH (NOLOCK) Where Login_ID = @Tran_ID and Is_Default = 0 And isnull(Emp_ID,0)=0 And isnull(Branch_ID,0)=0)
				begin
					delete from T0015_LOGIN_RIGHTS Where Login_ID = @Tran_ID
					delete from T0015_LOGIN_BRANCH_RIGHTS where Login_ID = @Tran_ID
					delete  from T0015_Login_Form_Rights where Login_ID = @Tran_ID
					delete from T0011_Login Where Login_ID = @Tran_ID
					
					
					set @Tran_ID =1
					Return 
				end
		end
	RETURN


	

