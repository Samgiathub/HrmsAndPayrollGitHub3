



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0040_Form_Master] 
	@Form_ID numeric output
	,@Cmp_ID  numeric
	,@Form_Name varchar(50)
	,@Form_type tinyint =1
	,@Form_comments varchar(1000)
	,@System_Date dateTime
	,@Login_ID  numeric
	,@tran_type	varchar(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
		
	If @tran_type  = 'I' 
		Begin
			
			If Exists(select Form_ID From T0040_Form_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Form_Name) = upper(@Form_Name))
				begin
					set @Form_ID = 0
					return 
				end
			
			select @Form_ID = Isnull(max(Form_ID),0) + 1 	From T0040_Form_Master  WITH (NOLOCK)
			
			INSERT INTO T0040_Form_Master
			        (
						 Form_ID
						,Cmp_ID 
						,Form_name 
						,Form_type 
						,Form_Comments 
						,System_Date
						,Login_ID
			        )
				VALUES     
					(		@Form_ID
						,@Cmp_ID 
						,@Form_name 
						,@Form_type 
						,@Form_Comments 
						,@System_Date
						,@Login_ID
					)
		End
	Else if @Tran_Type = 'U'
 		begin
			If Exists(select Form_ID From T0040_Form_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Form_name) = upper(@Form_Name)
											and Form_ID <> @Form_ID )
				begin
					set @Form_ID = 0
					return 
				end

				UPDATE    T0040_Form_Master
				SET              
					     Form_ID=@Form_ID
						,Form_name =@Form_Name
						,Form_type =@Form_type
						,Form_Comments =@Form_Comments
						,System_Date=getdate()
						,Login_ID=@Login_ID
				where Form_ID = @Form_ID
		end
	Else If @Tran_Type = 'D'
		begin
				Delete From T0040_Form_Master Where Form_ID = @Form_ID
		end

	
	RETURN
	


	RETURN




