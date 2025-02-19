



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0091_HRMS_RESUME_HEALTH_DETAIL]
	 @Row_D_ID	numeric(18, 0)	output
	,@cmp_id	numeric(18, 0)	
	,@Row_ID	numeric(18, 0)	
	,@Que_Id	numeric(18, 0)	
	,@Que_Tag	varchar(1000)	
	,@answer_tag	varchar(1000)	
	,@Trans_Type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @Trans_Type  = 'I'
		Begin
				If Exists(Select Row_D_ID From T0091_HRMS_RESUME_HEALTH_DETAIL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Row_ID = @Row_ID and Que_Tag=@Que_Tag)
					begin
						set @Row_D_ID = 0
					Return 
				end
				
				select @Row_D_ID= Isnull(max(Row_D_ID),0) + 1 	From T0091_HRMS_RESUME_HEALTH_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0091_HRMS_RESUME_HEALTH_DETAIL
				                      ( Row_D_ID
										,cmp_id
										,Row_ID
										,Que_Id
										,Que_Tag
										,answer_tag
										)
				VALUES					(@Row_D_ID
										,@cmp_id
										,@Row_ID
										,@Que_Id
										,@Que_Tag
										,@answer_tag)
		End
	Else if @Trans_Type = 'U'
		begin
				Update T0091_HRMS_RESUME_HEALTH_DETAIL
				set 
					answer_tag=@answer_tag
   
				where Que_Tag = @Que_Tag and Row_ID=@Row_ID and cmp_id=@cmp_id
				
		end
	Else if @Trans_Type = 'D'
		begin
				Delete From T0091_HRMS_RESUME_HEALTH_DETAIL Where Row_D_ID= @Row_D_ID
				
		end

	RETURN




