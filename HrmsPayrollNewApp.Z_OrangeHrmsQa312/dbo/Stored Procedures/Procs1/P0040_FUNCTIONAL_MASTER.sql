



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_FUNCTIONAL_MASTER]
	@Type_ID AS NUMERIC output,
	@Type_Name AS VARCHAR(50),
	@CMP_ID AS NUMERIC,
	@Description as varchar(1000),
	@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
				If Exists(Select Type_ID From T0040_FUNCTIONAL_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Type_Name) = upper(@Type_Name))
					begin
						set @Type_ID = 0
						Return 
					end
				
				select @Type_ID= Isnull(max(Type_ID),0) + 1 	From T0040_FUNCTIONAL_MASTER  WITH (NOLOCK)
				
				INSERT INTO T0040_FUNCTIONAL_MASTER
				                      (Type_ID, Cmp_ID, Type_Name,Description)
				VALUES     (@Type_ID, @Cmp_ID,@Type_Name,@Description)
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select Type_ID From T0040_FUNCTIONAL_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Type_Name) = upper(@Type_Name) and Type_ID <> @Type_ID)
					begin
						set @Type_ID = 0
						Return 
					end

				Update T0040_FUNCTIONAL_MASTER
				set Type_Name=@Type_Name
				    , Description=@Description
				where Type_ID = @Type_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0040_FUNCTIONAL_MASTER Where Type_ID= @Type_ID
		end

	RETURN




