



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_HRMS_SKILL]
	@Row_ID AS NUMERIC output
	,@Resume_ID AS NUMERIC(18,0)
	,@Cmp_ID    NUMERIC(18,0)
	,@Skill_ID  NUMERIC(18,0)
	,@Skill_Comments VARCHAR(50)
	,@Skill_Experience  NUMERIC(18,2)
	,@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @tran_type  = 'I'
		Begin
				If Exists(Select Row_ID From t0090_HRMS_SKIL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SKILL_id = @Skill_ID)
					begin
						set @Row_ID = 0
						Return 
					end
				
				select @Row_ID= Isnull(max(Row_ID),0) + 1 	From t0090_HRMS_SKIL WITH (NOLOCK)
				
				INSERT INTO t0090_HRMS_SKIL (Row_ID,Resume_ID,Cmp_ID,Skill_ID,Skill_Comments,Skill_Experience)
				Values(@Row_ID,@Resume_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience)
				                    
		End
	Else if @Tran_Type = 'U'
		begin
				

			Update t0090_HRMS_SKIL
			   set Row_ID =@Row_ID,
			       Resume_ID=@Resume_ID,
			       Cmp_ID=@Cmp_ID,
			       Skill_ID=@Skill_ID,
			       Skill_Comments = @Skill_Comments,
			       Skill_Experience = @Skill_Experience
			Where   Row_ID = @Row_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From t0090_HRMS_SKIL Where Row_ID= @Row_ID
		end

	RETURN




