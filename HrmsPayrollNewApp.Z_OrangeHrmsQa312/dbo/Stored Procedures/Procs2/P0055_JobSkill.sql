

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_JobSkill]
	  @Job_Skill_Id			numeric(18,0) OUTPUT
      ,@Cmp_Id				numeric(18,0)
      ,@Job_Id				numeric(18,0)
      ,@Skill_Id			numeric(18,0)
      ,@Mandatory			bit
      ,@Secondary			bit
      ,@Tran_Type			char(1)
	  ,@User_Id				numeric(18,0)	
	  ,@IP_Address			varchar(100)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	
If @Tran_Type = 'I'
		BEGIN
			if @Job_Id=0
				begin
					select @Job_Id = max(Job_Id)  from T0050_JobDescription_Master WITH (NOLOCK)
				end
			
		
			select @Job_Skill_Id = isnull(max(Job_Skill_Id),0)+1 from T0055_JobSkill WITH (NOLOCK)
			Insert into T0055_JobSkill
			(
				 Job_Skill_Id
				,Cmp_Id
				,Job_Id
				,Skill_Id
				,Mandatory
				,Secondary
			)
			VALUES
			(
				 @Job_Skill_Id
				,@Cmp_Id
				,@Job_Id
				,@Skill_Id
				,@Mandatory
				,@Secondary
			)
		END
	Else If @Tran_Type = 'U'
		BEGIN
			Update T0055_JobSkill
			SET   Skill_Id = @Skill_Id
				 ,Mandatory = @Mandatory
				 ,Secondary = @Secondary
			WHERE Job_Skill_Id = @Job_Skill_Id
		END
	Else If @Tran_Type = 'D'
		BEGIN
			Delete from T0055_JobSkill where Job_Skill_Id = @Job_Skill_Id
		END
END

