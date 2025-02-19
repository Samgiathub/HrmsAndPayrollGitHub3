
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_EmployeeGoal_SupEval_Level]
	   @SupEval_Level_Id			numeric(18,0)
      ,@Cmp_Id						numeric(18,0)
      ,@Emp_Id						numeric(18,0)
      ,@Emp_GoalSetting_Review_Id	numeric(18,0)
      ,@EGS_Review_Level_Id			numeric(18,0)
      ,@SupEval_Id					numeric(18,0)
      ,@SupEval_Comments			Nvarchar(300) --Changed by Deepali -02Jun22
      ,@YearEnd_FinalRating			varchar(12)
      ,@YearEnd_NormalRating		varchar(12)
      ,@S_Emp_Id					numeric(18,0)
      ,@Approval_date				datetime
      ,@Rpt_Level					int
       ,@tran_type		varchar(1) =null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If Upper(@tran_type) ='I'
		BEGIN
			IF @EGS_Review_Level_Id =0
				BEGIN
					SELECT @EGS_Review_Level_Id = max(EGS_Review_Level_Id) from T0110_EmployeeGoalSetting_Evaluation_Approval WITH (NOLOCK)
					where rpt_level= @Rpt_Level and emp_id= @emp_id
				END
			select @SupEval_Level_Id = isnull(max(SupEval_Level_Id),0)+1 from T0115_EmployeeGoal_SupEval_Level WITH (NOLOCK)
			Insert into T0115_EmployeeGoal_SupEval_Level
			(
				SupEval_Level_Id
			  ,Cmp_Id
			  ,Emp_Id
			  ,Emp_GoalSetting_Review_Id
			  ,SupEval_Id
			  ,SupEval_Comments
			  ,YearEnd_FinalRating
			  ,YearEnd_NormalRating
			  ,S_Emp_Id
			  ,Approval_date
			  ,Rpt_Level
			  ,EGS_Review_Level_Id
			)
			VALUES
			(
			  @SupEval_Level_Id
			  ,@Cmp_Id
			  ,@Emp_Id
			  ,@Emp_GoalSetting_Review_Id
			  ,@SupEval_Id
			  ,@SupEval_Comments
			  ,@YearEnd_FinalRating
			  ,@YearEnd_NormalRating
			  ,@S_Emp_Id
			  ,@Approval_date
			  ,@Rpt_Level
			  ,@EGS_Review_Level_Id
			)
		END
END
