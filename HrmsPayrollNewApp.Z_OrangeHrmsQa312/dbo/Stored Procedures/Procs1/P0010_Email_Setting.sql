

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--Created by rohit for Email Settings on 19042016
CREATE PROCEDURE [dbo].[P0010_Email_Setting]  
   @tran_id  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@MailServer varchar(1000)
   ,@MailServer_Port numeric(18,0)
   ,@MailServer_UserName nvarchar(2000)  
   ,@MailServer_Password nvarchar(500)  
   ,@Ssl tinyint
   ,@MailServer_DisplayName  nvarchar(500) 
   ,@From_Email Nvarchar(500) 
   ,@isMES tinyint = 0 
   ,@MESURI nvarchar(500)='' 
   ,@MESReplyTo	nvarchar(500)= ''
   ,@To_Email nvarchar(500)=''
   ,@tran_type char(1) = 'I'
   ,@User_Id numeric(18,0) = 0 
   ,@IP_Address varchar(30)= '' 
   ,@Email_Setting varchar(max)='' output
   ,@Server_link varchar(max) = ''
AS  
 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;
 
declare @OldValue as  varchar(max)
Declare @String as varchar(max)
set @String=''
set @OldValue =''

if exists (Select Tran_Id from T0010_Email_Setting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID) 
begin
	set @tran_type ='U'
end

-- Added by rohit on 28062016
declare @profile_name as varchar(50)
set @profile_name =  'Db_Mail_' + cast(@Cmp_ID as varchar(3))

exec[P_Create_mail_Profile] @profile_name  =@profile_name,@description ='',@Email_Address = @MailServer_UserName, @mailserver_name = @MailServer,
@port = @MailServer_Port,@enable_ssl = @Ssl ,@username = @MailServer_UserName, @password = @MailServer_Password,@display_name =@MailServer_DisplayName ,@cmp_id=@cmp_id,@link = @Server_link , @trans_Type =@tran_type

-- Ended by rohit on 28062016

if Upper(@tran_type) ='I' 
			begin
					Select @Tran_Id = isnull(max(Tran_Id),0)+1  from T0010_Email_Setting WITH (NOLOCK)
						
					insert into T0010_Email_Setting(tran_Id,cmp_id,MailServer,MailServer_Port,MailServer_UserName,MailServer_Password,Ssl,MailServer_DisplayName,From_Email,isMES,MESURI,MESReplyTo,system_date,user_id,To_Email)
					values(@tran_Id,@Cmp_ID,@MailServer,@MailServer_Port,@MailServer_UserName,@MailServer_Password,@Ssl,@MailServer_DisplayName,@From_Email,@isMES,@MESURI,@MESReplyTo,GETDATE(),@User_Id,@To_Email)
					
					
					exec P9999_Audit_get @table = 'T0010_Email_Setting' ,@key_column='cmp_id',@key_Values=@Cmp_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					--

			end 
	else if upper(@tran_type) ='U' 
		begin
			   
			   	exec P9999_Audit_get @table='T0010_Email_Setting' ,@key_column='Cmp_id',@key_Values=@Cmp_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				Update T0010_Email_Setting 
				Set
				MailServer=@MailServer,
				MailServer_Port=@MailServer_Port,
				MailServer_UserName=@MailServer_UserName,
				MailServer_Password=@MailServer_Password,
				Ssl=@Ssl,
				MailServer_DisplayName=@MailServer_DisplayName,
				From_Email=@From_Email,
				isMES=@isMES,
				MESURI=@MESURI,
				MESReplyTo=@MESReplyTo,
				system_date=GETDATE(),
				user_id=@user_id,
				To_Email =@To_Email
				where cmp_id=@Cmp_ID
				
				exec P9999_Audit_get @table='T0010_Email_Setting' ,@key_column='Cmp_id',@key_Values=@cmp_id,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			 
			 
		end	
set @Email_Setting =  isnull(@String ,'')
exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Email Settings',@OldValue,@Tran_Id,@User_Id,@IP_Address
return
