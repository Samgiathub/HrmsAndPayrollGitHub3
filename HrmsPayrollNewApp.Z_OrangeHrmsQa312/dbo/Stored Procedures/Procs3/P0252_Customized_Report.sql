
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0252_Customized_Report]
	@Tran_Id numeric(18,0) output
   ,@Cmp_ID numeric(18,0)
   ,@Name varchar(200)
   ,@Report_Type varchar(200)
   ,@Report_Field nvarchar(Max)
   ,@user_Id numeric(18,0)
   ,@trans_type char
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @trans_type = 'D'
	
		begin
			select @Tran_Id=Tran_ID FROM dbo.T0252_Customized_Report WITH (NOLOCK)
			WHERE Name = @Name AND Report_Type =@Report_Type And Cmp_Id=@Cmp_Id and user_Id=@user_Id

			DELETE FROM dbo.T0252_Customized_Report 
			WHERE Tran_ID=@Tran_Id
		end
	ELSE
		BEGIN
			SELECT @Tran_Id = Tran_Id from T0252_Customized_Report WITH (NOLOCK) where Name = @Name and Cmp_Id=@Cmp_ID and user_Id =@user_Id and Report_Type =@Report_Type			
			IF IsNull(@Tran_Id,0) > 0
				UPDATE	dbo.T0252_Customized_Report
				SET		Report_Field= @Report_Field
				WHERE	Tran_Id=@Tran_Id
			ELSE
				BEGIN 
					INSERT INTO dbo.T0252_Customized_Report
						(Cmp_ID, Name , Report_Type,Report_Field,user_Id)
					VALUES
						(@Cmp_ID ,@Name,@Report_Type ,@Report_Field ,@user_Id)
					SELECT @Tran_Id = SCOPE_IDENTITY();
				END
		END
	
	RETURN




