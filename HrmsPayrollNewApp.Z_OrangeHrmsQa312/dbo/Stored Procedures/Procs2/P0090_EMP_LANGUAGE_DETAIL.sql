

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_LANGUAGE_DETAIL]
		 @Row_ID		as numeric output
		,@Lang_ID		as Numeric 
		,@Emp_ID		as Numeric 
		,@Cmp_ID		as numeric 
		,@Lang_Fluency  as varchar(20)
		,@Lang_Ability	as varchar(200)
		,@tran_type varchar(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Old_lang_ID as numeric
set @Old_lang_ID = 0

if @Lang_ID = 0 
	set @Lang_ID = null

		If @tran_type ='I' 
			begin
				if exists(select Lang_ID from T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK)
							Where Emp_ID = @Emp_ID and Lang_ID = @Lang_ID and Cmp_ID = @Cmp_ID )			-- and upper(Lang_Fluency) = upper(@Lang_Fluency)  and upper(Lang_Ability) = upper(@Lang_Ability)
					begin
						set @Lang_ID = 0
						return 
					end								
				
				select @Row_ID = isnull(max(Row_ID),0) +1 from T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_LANGUAGE_DETAIL
				                      (Row_ID, Emp_Id, Cmp_ID, Lang_ID, Lang_Fluency, Lang_Ability)
				VALUES     (@Row_ID, @Emp_Id, @Cmp_ID, @Lang_ID, @Lang_Fluency, @Lang_Ability)
				
			end 
	Else If @tran_type ='U' 
				begin
				select @Old_lang_ID = lang_ID from T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK) Where Emp_ID = @Emp_ID and Row_ID = @Row_ID and Cmp_ID = @Cmp_ID
					if @Old_lang_ID <> @Lang_ID 
					begin
						if exists(select Lang_ID from T0090_EMP_LANGUAGE_DETAIL WITH (NOLOCK) Where Emp_ID = @Emp_ID and Lang_ID = @Lang_ID and Cmp_ID = @Cmp_ID )
						begin
							set @Lang_ID = 0
							set @Row_ID = 0
							return 	
						end
					end
					UPDATE    T0090_EMP_LANGUAGE_DETAIL
					SET       Lang_Ability =@Lang_Ability, Lang_Fluency =@Lang_Fluency,Lang_ID = @Lang_ID
					WHERE      Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Row_ID = @Row_ID and Lang_ID= @Old_lang_ID
				end
	Else If @tran_type ='D'
			Begin
					delete  from T0090_EMP_LANGUAGE_DETAIL where  Emp_ID =@Emp_ID and Cmp_ID = @Cmp_ID and Row_ID = @Row_ID  -- Row_ID =@Row_ID and Emp_ID =@Emp_ID
					
			End
					

	RETURN




