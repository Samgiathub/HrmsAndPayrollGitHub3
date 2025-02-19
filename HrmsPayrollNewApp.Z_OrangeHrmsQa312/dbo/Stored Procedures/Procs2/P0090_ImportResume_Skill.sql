

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_ImportResume_Skill]
	 @cmp_id			numeric(18,0)
	,@Resume_Code		varchar(100)
	,@Skill_Name		varchar(100)
	,@Skill_Comments	varchar(250)
	,@Skill_Experience	varchar(50)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


declare @Skill_id numeric(18,0)
declare @Resume_ID numeric(18,0)

	If @Resume_Code <>''
		Begin
			If exists(select 1 from T0055_Resume_Master WITH (NOLOCK) where Resume_Code= @Resume_Code)
				Begin
					select @Resume_ID=Resume_Id from T0055_Resume_Master WITH (NOLOCK) where Resume_Code=@Resume_Code
					If @Skill_Name <> ''
						Begin
							if exists(select 1 from T0040_SKILL_MASTER WITH (NOLOCK) where upper(Skill_Name)=upper(@skill_name) and Cmp_ID=@cmp_id)
								Begin
									select @Skill_id = Skill_ID from T0040_SKILL_MASTER WITH (NOLOCK) where  upper(Skill_Name)=upper(@skill_name) and Cmp_ID=@cmp_id
									exec P0090_HRMS_RESUME_SKILL 0,@Resume_ID,@cmp_id,@Skill_id,@Skill_Comments,@Skill_Comments,'I'
								End
							Else
								Begin
									declare @p1 int
									set @p1=0
									exec P0040_SKILL_MASTER @Skill_ID=@p1 output,@Skill_Name=@skill_name,@Cmp_ID=@cmp_id,@Description='',@tran_type='Inse',@User_Id=0,@IP_Address='127.0.0.1'
									select @p1
									select @Skill_id = Skill_ID from T0040_SKILL_MASTER WITH (NOLOCK) where  upper(Skill_Name)=upper(@skill_name) and Cmp_ID=@cmp_id
									exec P0090_HRMS_RESUME_SKILL 0,@Resume_ID,@cmp_id,@Skill_id,@Skill_Comments,@Skill_Comments,'I'
									
								End
						End	
				End
			Else
				Begin
					Raiserror('This resume donot exists,Please enter resume details first.',16,2)
				End
		End
	Else
		Begin
			Raiserror('Enter Resume Code',16,2)
		End
END

