



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0053_HRMS_Recruitment_Form]
	 @Rec_form_id	numeric(18, 0)	output
	,@cmp_id	numeric(18, 0)	
	,@Rec_Post_Id	numeric(18, 0)	
	,@form_id	numeric(18, 0)	
	,@Form_name	varchar(150)	
	,@status	int	
	,@Trans_Type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Trans_Type  = 'I'
		Begin
			--IF @Rec_form_id <> 0--modified on 8/11/2012 by sneha
			--	BEGIN
			--	If Exists(Select Rec_form_id From T0053_HRMS_Recruitment_Form  Where Cmp_ID = @Cmp_ID and Form_name = @Form_name)
			--		begin
			--			set @Rec_form_id = 0
			--			Return 
			--		end
			--	END
			--ELSE --commented on 22 Jun 2016 sneha
				BEGIN
					If Not EXISTS (select 1 from T0053_HRMS_Recruitment_Form WITH (NOLOCK) where Rec_Post_Id= @rec_Post_id and Form_name=@form_name)
						BEGIN
							select @Rec_form_id= Isnull(max(Rec_form_id),0) + 1 From T0053_HRMS_Recruitment_Form WITH (NOLOCK)
							INSERT INTO T0053_HRMS_Recruitment_Form 
							( Rec_form_id
							 ,cmp_id
							 ,Rec_Post_Id
							 ,form_id
							 ,Form_name
							 ,status
							)
							Values
							( @Rec_form_id
							 ,@cmp_id
							 ,@Rec_Post_Id
							 ,@form_id
							 ,@Form_name
							 ,@status
							)
						End
					ELSE	
						BEGIN --added on 15-dec-2015
							Update T0053_HRMS_Recruitment_Form
							set status = @status
							where Form_name=@form_name and Rec_Post_Id = @rec_post_id
						End
				END
					                    
			End
		
	Else if @Trans_Type = 'D'
		begin
			Delete From T0053_HRMS_Recruitment_Form Where Rec_form_id= @Rec_form_id
		end

	RETURN




