
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_LANGUAGE_DETAIL_APP]
	 @Row_ID		as int output
	,@Emp_Tran_ID bigint
	,@Emp_Application_ID int
	,@Lang_ID		as int 
	,@Cmp_ID		as int 
	,@Lang_Fluency  as varchar(20)
	,@Lang_Ability	as varchar(200)						
	,@tran_type varchar(1)
	,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Old_lang_ID AS INT
	SET @Old_lang_ID = 0

	if @Lang_ID = 0 
		set @Lang_ID = null

	If @tran_type ='I' 
		BEGIN
			IF EXISTS(	SELECT	Lang_ID FROM T0065_EMP_LANGUAGE_DETAIL_APP WITH (NOLOCK)
						Where	Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID 
								AND Lang_ID = @Lang_ID and Cmp_ID = @Cmp_ID 
					 )			-- and upper(Lang_Fluency) = upper(@Lang_Fluency)  and upper(Lang_Ability) = upper(@Lang_Ability)
				BEGIN
					SET @Lang_ID = 0
					RETURN 
				END								
			
			SELECT @Row_ID = IsNull(MAX(Row_ID),0) +1 from T0065_EMP_LANGUAGE_DETAIL_APP WITH (NOLOCK)
			
			INSERT INTO T0065_EMP_LANGUAGE_DETAIL_APP
						(Row_ID,Emp_Tran_ID,Emp_Application_ID,Cmp_ID, Lang_ID, Lang_Fluency, Lang_Ability,Approved_Emp_ID,Approved_Date,Rpt_Level)
			VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID, @Lang_ID, @Lang_Fluency, @Lang_Ability,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
			
		END 
	Else If @tran_type ='U' 
				begin
					select @Old_lang_ID = lang_ID from T0065_EMP_LANGUAGE_DETAIL_APP WITH (NOLOCK) 
					Where Emp_Tran_ID=@Emp_Tran_ID  and Row_ID = @Row_ID and Cmp_ID = @Cmp_ID
					
					if @Old_lang_ID <> @Lang_ID 
					begin
						if exists(select Lang_ID from T0065_EMP_LANGUAGE_DETAIL_APP WITH (NOLOCK)
							Where Emp_Tran_ID=@Emp_Tran_ID  and Lang_ID = @Lang_ID and Cmp_ID = @Cmp_ID )
						begin
							set @Lang_ID = 0
							set @Row_ID = 0
							return 	
						end
					end
					UPDATE    T0065_EMP_LANGUAGE_DETAIL_APP
					SET       Lang_Ability =@Lang_Ability, Lang_Fluency =@Lang_Fluency,Lang_ID = @Lang_ID,
							  Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level
					WHERE      Cmp_ID = @Cmp_ID and Emp_Tran_ID=@Emp_Tran_ID  and Row_ID = @Row_ID and Lang_ID= @Old_lang_ID
				end
	Else If @tran_type ='D'
			Begin
					delete  from T0065_EMP_LANGUAGE_DETAIL_APP where  Emp_Tran_ID=@Emp_Tran_ID  and Cmp_ID = @Cmp_ID and Row_ID = @Row_ID  
			End
					

	RETURN


select  * from T0065_EMP_LANGUAGE_DETAIL_APP  WITH (NOLOCK)


