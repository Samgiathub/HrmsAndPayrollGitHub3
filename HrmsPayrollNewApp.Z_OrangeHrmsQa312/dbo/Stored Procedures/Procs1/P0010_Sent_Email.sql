



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0010_Sent_Email]
		@Email_Detail_ID numeric output
       ,@From_Email varchar(20)
	   ,@To_Email Varchar(20)
	   ,@Cmp_ID numeric(18,0)
	   ,@From_Emp_ID numeric(18,0)
	   ,@Subject varchar(20)
	   ,@Message varchar(5000)
	   ,@Attachment varchar(500)
	   ,@Email_Date datetime
	   ,@Email_CC varchar(20)
	   ,@Email_BCC varchar(20)
	   ,@Email_Status varchar(2)	
	   ,@Ip_Address varchar(20)
       ,@tran_type varchar
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

       if  @Email_CC=''
         set @Email_CC=''
         
          if  @Email_BCC=''
         set @Email_BCC=''
         
         if @Attachment=''
         set @Attachment=''
         
		if @tran_type ='I' 
			begin
					select @Email_Detail_ID = isnull(max(Email_Detail_ID),0) from T0010_Sent_Email WITH (NOLOCK)
					if @Email_Detail_ID is null or @Email_Detail_ID = 0
						set @Email_Detail_ID =1
					else
						set @Email_Detail_ID = @Email_Detail_ID + 1			
						
				 insert into T0010_Sent_Email
					(
						 Email_Detail_ID
						,From_Email
						,To_Email
						,Cmp_ID
						,From_Emp_ID
						,Subject
						,Message
						,Email_Date
						,Email_CC
						,Email_BCC
						,Email_Status
						,Ip_Address
						,Attachment
					)
					 values
					(	
					     @Email_Detail_ID
						,@From_Email
						,@To_Email
						,@Cmp_ID
						,@From_Emp_ID
						,@Subject
						,@Message
						,@Email_Date
						,@Email_CC
						,@Email_BCC
						,@Email_Status
						,@Ip_Address
						,@Attachment
					)
						
				end 
	RETURN




