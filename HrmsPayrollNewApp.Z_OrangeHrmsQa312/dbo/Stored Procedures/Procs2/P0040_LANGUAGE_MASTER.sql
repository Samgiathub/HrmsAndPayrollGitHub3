



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_LANGUAGE_MASTER]
	@LANG_ID AS NUMERIC output,
	@CMP_ID AS NUMERIC,
	@LANG_NAME AS VARCHAR(100),
		@tran_type as varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
		
	If @tran_type  = 'I'
		Begin
				if Exists(select Lang_ID from T0040_LANGUAGE_MASTER WITH (NOLOCK) where upper(Lang_Name) =upper(@Lang_Name)
								and cmp_ID = @Cmp_ID )
					begin
						set @Lang_ID = 0
						return 
					end
				
				select @LANG_ID = Isnull(max(LANG_ID),0) + 1 	From T0040_LANGUAGE_MASTER  WITH (NOLOCK)
				
				INSERT INTO T0040_LANGUAGE_MASTER
				                      (LANG_ID, Cmp_ID, Lang_Name)
				VALUES     (@LANG_ID, @Cmp_ID, @Lang_Name)
		End
	Else if @Tran_Type = 'U'
		begin
				if Exists(select Lang_ID from T0040_LANGUAGE_MASTER  WITH (NOLOCK) where upper(Lang_Name) =upper(@Lang_Name)
								and cmp_ID = @Cmp_ID and Lang_ID <> @Lang_ID)
					begin
						set @Lang_ID = 0
						return 
					end

				Update T0040_LANGUAGE_MASTER
				set Lang_Name = @Lang_Name
				
				where LANG_ID = @LANG_ID
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0040_LANGUAGE_MASTER Where LANG_ID = @LANG_ID
		end

	RETURN




