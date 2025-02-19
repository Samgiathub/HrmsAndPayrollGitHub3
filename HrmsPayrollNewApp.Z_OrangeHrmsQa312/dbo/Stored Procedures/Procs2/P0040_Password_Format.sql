


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Password_Format]    
    @pwd_Fmt_ID int out,
	@cmp_ID int,
	@pwd_Name varchar(max),
	@Pwd_Format varchar(max),
	@Tran_Type varchar(1)  ,
	@User_Id numeric(18,0) = 0,
    @IP_Address varchar(30)= '' 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 declare @OldValue as varchar(max)
 declare @OldPwdName as varchar(max)
 declare @OldPwdFormat as varchar(max)
 
 
  set @OldValue = ''
  set @OldPwdName = ''
  set @OldPwdFormat = ''
  
  --------
  
  --select pwd_frmt_ID,Cmp_ID,Name,FORMAT from T0040_Password_Format
	
		
	If Upper(@tran_type) ='I'
			begin
				if exists (Select pwd_frmt_ID  from T0040_Password_Format WITH (NOLOCK) Where Upper(Name) = Upper(@pwd_Name) and cmp_ID = @Cmp_ID) 
					begin
						set @pwd_Fmt_ID = 0
						Return 
					end
				
				
				select @pwd_Fmt_ID = isnull(max(pwd_frmt_ID),0) + 1 from T0040_Password_Format WITH (NOLOCK)
				
				INSERT INTO T0040_Password_Format
				                      (pwd_frmt_ID, cmp_Id, Name, FORMAT)
				VALUES     (@pwd_Fmt_ID,@Cmp_Id,@pwd_Name,@Pwd_Format)
            
				 
			  set @OldValue = 'New Value' + '#'+ 'Format Name :' +ISNULL( @pwd_Name,'') + '#' + 'Password Format :' + ISNULL( @Pwd_Format,'') + '#' 
			
			end 
	Else If  Upper(@tran_type) ='U' 
			begin
				if exists (Select pwd_frmt_ID  from T0040_Password_Format WITH (NOLOCK) Where Upper(Name) = Upper(@pwd_Name) and pwd_frmt_ID <> @pwd_Fmt_ID and Cmp_ID = @cmp_ID ) 
					begin
						set @pwd_Fmt_ID = 0
						Return
					end
				
		        select @OldPwdName  =ISNULL(Name,'') ,@OldPwdFormat  =isnull(FORMAT,'') From dbo.T0040_Password_Format WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and pwd_frmt_ID = @pwd_Fmt_ID		
					
				UPDATE    T0040_Password_Format
				SET      Name = @pwd_Name, Format = @Pwd_Format 
				WHERE     pwd_frmt_ID = @pwd_Fmt_ID
				
				set @OldValue = 'old Value' + '#'+ 'Format Name :' + @OldPwdName  + '#' + 'Password Format:' + @OldPwdFormat  + '#' 
               + 'New Value' + '#'+ 'Format Name :' +ISNULL( @pwd_Name,'') + '#' + 'Password Format :' + ISNULL( @Pwd_Format,'') + '#' 
               -----
				end
			
	Else If  Upper(@tran_type) ='D'
			Begin
			
			 select @OldPwdName  =ISNULL(Name,'') ,@OldPwdFormat  =ISNULL(FORMAT,'') From dbo.T0040_Password_Format WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and pwd_frmt_ID = @pwd_Fmt_ID		
				if exists(select Format_ID from T0250_Password_Format_Setting WITH (NOLOCK) where Format_ID = @pwd_Fmt_ID and Cmp_ID = @cmp_ID)
				begin
					set @pwd_Fmt_ID = 0
					return
				end
				DELETE FROM T0040_Password_Format WHERE pwd_frmt_ID = @pwd_Fmt_ID
					
				set @OldValue = 'old Value' + '#'+ 'Format Name :' +ISNULL( @OldPwdName,'') + '#' + 'Password Format :' + ISNULL( @OldPwdFormat,'') + '#' 
				-----
			End
				select @Cmp_ID,@Tran_Type,'Password Format Setting',@OldValue,@pwd_Fmt_ID,@User_Id,@IP_Address
				
				exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Password Format Setting',@OldValue,@pwd_Fmt_ID,@User_Id,@IP_Address
			
	RETURN




