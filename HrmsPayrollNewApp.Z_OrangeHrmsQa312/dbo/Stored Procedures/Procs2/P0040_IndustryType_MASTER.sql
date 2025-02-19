
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_IndustryType_MASTER]
	@CMP_ID AS NUMERIC,
	@IndustryType AS VARCHAR(150),
	@tran_type as varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		
	If @tran_type  = 'I'
		Begin
				if Exists(select 1 from T0040_IndustryType_MASTER WITH (NOLOCK) where upper(IndustryType) =upper(@IndustryType)
								and cmp_ID = @Cmp_ID )
					begin						
						return 
					end
				
				--select @LANG_ID = Isnull(max(LANG_ID),0) + 1 	From T0040_LANGUAGE_MASTER 
				
				INSERT INTO T0040_IndustryType_MASTER
				                      (Cmp_ID, IndustryType)
				VALUES     (@Cmp_ID, @IndustryType)
		End
	Else if @Tran_Type = 'U'
		begin
				if Exists(select 1 from T0040_IndustryType_MASTER WITH (NOLOCK) where upper(IndustryType) =upper(@IndustryType)
								and cmp_ID = @Cmp_ID)
					begin												
						return 
					end

				Update T0040_IndustryType_MASTER
				set IndustryType = @IndustryType
				
				where IndustryType = @IndustryType
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0040_IndustryType_MASTER Where IndustryType = @IndustryType
		end

	RETURN




