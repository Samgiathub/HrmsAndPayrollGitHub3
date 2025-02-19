
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_SKILL_aswini]
		 @Row_ID numeric(18,0) output
		,@Resume_Id as numeric(18,0)
		,@Cmp_ID numeric(18,0)
		,@Skill_ID numeric 
		,@Skill_Comments varchar(250)
		,@Skill_Experience varchar(50)
		,@tran_type varchar(1)
		,@Attach_docs varchar(max)=''
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		if @Skill_ID = 0 
		set @Skill_ID =  null
		
		if Upper(@tran_type) ='I' 
			begin
				
				IF exists(select Skill_ID From T0090_HRMS_RESUME_SKILL WITH (NOLOCK) where Resume_Id = @Resume_Id and Skill_ID = @Skill_ID)
					begin
							set @Row_ID = 0
							return
					end
		
				select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_HRMS_RESUME_SKILL WITH (NOLOCK)
			
			
				INSERT INTO T0090_HRMS_RESUME_SKILL
				           (Row_ID,Resume_Id,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience,attach_Documents)
				VALUES     (@Row_ID,@Resume_Id,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience,@Attach_docs)		
				
			end 
	else if Upper(@tran_type) ='U' 
				begin
						IF Not exists(select Skill_ID From T0090_HRMS_RESUME_SKILL WITH (NOLOCK) where Resume_Id = @Resume_Id and Skill_ID = @Skill_ID and Row_Id<>@Row_Id)
						begin
							UPDATE    T0090_HRMS_RESUME_SKILL
								SET    Cmp_ID = @Cmp_ID,
								Resume_Id = @Resume_Id ,
								Skill_ID = @Skill_ID, Skill_Comments = @Skill_Comments, 
									   Skill_Experience = @Skill_Experience,attach_Documents=@Attach_docs
							WHERE     (Row_ID = @Row_ID and Resume_Id = @Resume_Id )
						End
						else
							begin
								set @Row_ID = 0
								return
							End
				end
	else if Upper(@tran_type) ='D'
				Begin
	
					Delete  from T0090_HRMS_RESUME_SKILL where Row_ID = @Row_ID
					
			    End		
	RETURN








