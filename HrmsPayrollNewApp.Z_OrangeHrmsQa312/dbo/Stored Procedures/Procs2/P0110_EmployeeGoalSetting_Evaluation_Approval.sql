
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0110_EmployeeGoalSetting_Evaluation_Approval]
	   @EGS_Review_Level_Id			numeric(18,0) Out
      ,@Cmp_Id						numeric(18,0)
      ,@Emp_Id						numeric(18,0)
      ,@S_Emp_Id					numeric(18,0)
      ,@Emp_GoalSetting_Review_Id	numeric(18,0)
      ,@Approval_date				datetime
      ,@Approval_Comments			nvarchar(300) --Changed by Deepali -02Jun22
      ,@AdditionalAchievement		nvarchar(1000) --Changed by Deepali -02Jun22
      ,@Login_Id					numeric(18,0)
      ,@Rpt_Level					int
      ,@Approval_Status				int
      ,@Tran_Type					Char(1) 
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @S_Emp_ID = 0
		SET @S_Emp_ID = NULL
		
	If UPPER(@Tran_Type) = 'I'
		BEGIN
			IF Exists(Select 1 From T0110_EmployeeGoalSetting_Evaluation_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and Emp_GoalSetting_Review_Id=@Emp_GoalSetting_Review_Id And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @EGS_Review_Level_Id = 0
					Select @EGS_Review_Level_Id
					Return 
				End
			SELECT @EGS_Review_Level_Id = ISNULL(MAX(EGS_Review_Level_Id),0) + 1 From T0110_EmployeeGoalSetting_Evaluation_Approval WITH (NOLOCK)
			
			Insert Into T0110_EmployeeGoalSetting_Evaluation_Approval
			(
				   EGS_Review_Level_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,S_Emp_Id
				  ,Emp_GoalSetting_Review_Id
				  ,Approval_date
				  ,Approval_Comments
				  ,AdditionalAchievement
				  ,Login_Id
				  ,Rpt_Level
				  ,Approval_Status
			)
			VALUES
			(
				   @EGS_Review_Level_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@S_Emp_Id
				  ,@Emp_GoalSetting_Review_Id
				  ,@Approval_date
				  ,@Approval_Comments
				  ,@AdditionalAchievement
				  ,@Login_Id
				  ,@Rpt_Level
				  ,@Approval_Status
			)
		END
END
