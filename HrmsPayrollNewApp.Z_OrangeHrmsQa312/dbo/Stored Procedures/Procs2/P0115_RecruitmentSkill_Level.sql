

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_RecruitmentSkill_Level]
	 @Row_Id		numeric(18,0)OUTPUT
	,@Cmp_Id		numeric(18,0)
	,@RecApp_Id		numeric(18,0)
	,@Skill_Id		numeric(18,0)
	,@Mandatory		bit
	,@Secondary		bit
	,@tran_type		 varchar(1) 
    ,@User_Id		 numeric(18,0) = 0
	,@IP_Address	 varchar(30)= '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	 If Upper(@tran_type) ='I'
		BEGIN
			if @RecApp_Id=0
				begin 
					select @RecApp_Id = max(RecApp_Id)  from T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) where cmp_id = @cmp_id
				end
			select @Row_Id = isnull(max(Row_Id),0) + 1 from T0115_RecruitmentSkill_Level WITH (NOLOCK)
			Insert into T0115_RecruitmentSkill_Level
			(
				Row_Id
				,Cmp_Id
				,RecApp_Id
				,Skill_Id
				,Mandatory
				,Secondary
			)
			VALUES
			(
				@Row_Id
				,@Cmp_Id
				,@RecApp_Id
				,@Skill_Id
				,@Mandatory
				,@Secondary
			)
		END
	Else If  Upper(@tran_type) ='U' 
		BEGIN
			Update T0115_RecruitmentSkill_Level
			SET		Skill_Id = @Skill_Id
					,Mandatory = @Mandatory
					,Secondary = @Secondary
			WHERE Row_Id = @Row_Id
		END
	Else If  Upper(@tran_type) ='D'
		Begin 
			DELETE FROM T0115_RecruitmentSkill_Level WHERE Row_Id = @Row_Id 
		END
END

