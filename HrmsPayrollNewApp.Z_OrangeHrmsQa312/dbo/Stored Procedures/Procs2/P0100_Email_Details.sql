



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_Email_Details]
		 @EmailId numeric(18)output
		,@Cmp_Id numeric
		,@Email_From_UserId numeric(18)=null
		,@Email_To_UserId numeric(18)=null
		,@Email_Subject varchar(100)=null
		,@Email_Messages text=null
		,@Email_Type varchar(50)=null
		,@Email_From_Status numeric(18)=null
		,@Email_To_Status numeric(18)=null
		,@Email_Read_Status numeric(18)=null
		,@Email_Css as varchar(50)
		,@tran_type varchar 

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Email_From_UserId =  0
 set @Email_From_UserId = NULL

		if @tran_type ='i' 
			begin
					select @EmailId = isnull(max(EmailId),0) from Tbl_Email_Details WITH (NOLOCK)
					if @EmailId is null or @EmailId = 0
						set @EmailId =1
					else
						set @EmailId = @EmailId + 1			
						
					insert into Tbl_Email_Details
					(
						 EmailId
						,Cmp_Id
						,Email_From_UserId
						,Email_To_UserId
						,Email_Subject
						,Email_Messages
						,Email_Type
						,Email_Datetime
						,Email_From_Status
						,Email_To_Status
						,Email_Read_Status
						,Email_Css)
					 values
					(	
						@EmailId
						,@Cmp_Id
						,@Email_From_UserId
						,@Email_To_UserId
						,@Email_Subject
						,@Email_Messages
						,@Email_Type
						,getdate()
						,@Email_From_Status
						,@Email_To_Status
						,@Email_Read_Status
						,@Email_Css
					)		

				end 
		 else if @tran_type ='u' or @tran_type ='U'
			begin
				if exists (select * from Tbl_Email_Details WITH (NOLOCK) where Email_From_UserId=@Email_From_UserId and EmailId=@EmailId and Cmp_Id=@Cmp_Id)
					begin
						Update Tbl_Email_Details 
								Set 
									Email_From_Status=@Email_From_Status
								where EmailId = @EmailId 
					end
				else
					begin
					Update Tbl_Email_Details 
								Set 
									Email_To_Status=@Email_From_Status,Email_Css=@Email_Css,Email_Read_Status=@Email_Read_Status
								where EmailId = @EmailId and Cmp_Id = @Cmp_Id			
					end		
				end
	else if @tran_type ='d'
			begin
			delete  from Tbl_Email_Details where EmailId = @EmailId and Cmp_Id = @Cmp_Id 
			end
	RETURN




