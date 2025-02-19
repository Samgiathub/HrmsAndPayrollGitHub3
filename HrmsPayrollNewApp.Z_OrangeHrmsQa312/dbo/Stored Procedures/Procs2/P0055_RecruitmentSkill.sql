

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_RecruitmentSkill] 
	   @Rec_Skill_Id	numeric(18,0) OUTPUT
      ,@Cmp_Id			numeric(18,0)
      ,@Rec_Req_ID		numeric(18,0)
      ,@Skill_Id		numeric(18,0)
      ,@Mandatory		bit
      ,@Secondary		bit
      ,@Tran_Type		char(1)
	  ,@User_Id			numeric(18,0)	
	  ,@IP_Address		varchar(100)
	  ,@Comments		Varchar(max)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	If @Tran_Type = 'I'
		BEGIN
			if @Rec_Req_ID=0
				begin
					select @Rec_Req_ID = max(Rec_Req_ID)  from T0050_HRMS_Recruitment_Request WITH (NOLOCK) where cmp_id = @cmp_Id
				end
			select @Rec_Skill_Id = isnull(max(Rec_Skill_Id),0)+1 from T0055_RecruitmentSkill WITH (NOLOCK)
			Insert into T0055_RecruitmentSkill
			(
				 Rec_Skill_Id
				,Cmp_Id
				,Rec_Req_ID
				,Skill_Id				
				,Mandatory
				,Secondary
				,Comments
			)
			VALUES
			(
				 @Rec_Skill_Id
				,@Cmp_Id
				,@Rec_Req_ID
				,@Skill_Id
				,@Mandatory
				,@Secondary
				,@Comments
			)
		END 
	Else If @Tran_Type = 'U'
		BEGIN
			Update T0055_RecruitmentSkill
			SET   Skill_Id = @Skill_Id
				 ,Mandatory = @Mandatory
				 ,Secondary = @Secondary
				 ,Comments=@Comments
			WHERE Rec_Skill_Id = @Rec_Skill_Id
		END
	Else If @Tran_Type = 'D'
		BEGIN
			Delete from T0055_RecruitmentSkill where Rec_Skill_Id = @Rec_Skill_Id
		END
END

