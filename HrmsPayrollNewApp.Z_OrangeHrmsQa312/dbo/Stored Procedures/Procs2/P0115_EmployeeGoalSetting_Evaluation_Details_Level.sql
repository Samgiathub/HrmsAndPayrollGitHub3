-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_EmployeeGoalSetting_Evaluation_Details_Level]
	   @Tran_Id				numeric(18,0)		
      ,@Cmp_Id				numeric(18,0)
      ,@Emp_Id				numeric(18,0)
      ,@Emp_GoalSetting_Review_Detail_Id	numeric(18,0)
      ,@EGS_Review_Level_Id	numeric(18,0)
      ,@Rpt_Level			int
      ,@Emp_GoalSetting_Detail_Id numeric(18,0)
      ,@Actual				nvarchar(1000)
      ,@Sup_Score			varchar(50)
      ,@Sup_Feedback		nvarchar(300)  --Changed by Deepali -02Jun22
      ,@WeightedScore		numeric(18,2)
      ,@tran_type			varchar(1) =null
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
					print @EGS_Review_Level_Id
				END
			select @Tran_Id = isnull(max(Tran_Id),0)+1 from T0115_EmployeeGoalSetting_Evaluation_Details_Level WITH (NOLOCK)
			
			INSERT INTO T0115_EmployeeGoalSetting_Evaluation_Details_Level
			(
				  Tran_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_GoalSetting_Review_Detail_Id
				  ,EGS_Review_Level_Id
				  ,Rpt_Level
				  ,Emp_GoalSetting_Detail_Id
				  ,Actual
				  ,Sup_Score
				  ,Sup_Feedback
				  ,WeightedScore
			)
			VALUES
			(
				   @Tran_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_GoalSetting_Review_Detail_Id
				  ,@EGS_Review_Level_Id
				  ,@Rpt_Level
				  ,@Emp_GoalSetting_Detail_Id
				  ,@Actual
				  ,@Sup_Score
				  ,@Sup_Feedback
				  ,@WeightedScore
			)
		END
END
--SP-6
