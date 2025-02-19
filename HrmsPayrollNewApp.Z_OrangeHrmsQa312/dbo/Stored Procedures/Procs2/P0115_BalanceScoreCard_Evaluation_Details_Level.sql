


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_BalanceScoreCard_Evaluation_Details_Level]
	   @Tran_Id						numeric(18,0)
      ,@Cmp_Id						numeric(18,0)
      ,@Emp_Id						numeric(18,0)
      ,@Emp_BSC_Review_Detail_Id	numeric(18,0)
      ,@Emp_BSC_Review_Level_Id		numeric(18,0)
      ,@Rpt_Level					int
      ,@BSC_Setting_Detail_Id		numeric(18,0)
      ,@Actual						nvarchar(100)
      ,@Sup_Score					varchar(50)
      ,@WeightedScore				numeric(18,2)
      ,@tran_type					varchar(1) =null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		BEGIN
			IF @Emp_BSC_Review_Level_Id =0
				BEGIN
					SELECT @Emp_BSC_Review_Level_Id = max(Emp_BSC_Review_Level_Id) from T0110_BalanceScoreCard_Evaluation_Approval WITH (NOLOCK)
					where rpt_level= @Rpt_Level and emp_id= @emp_id
				END
			SELECT @Tran_Id = isnull(max(Tran_Id),0)+1 from T0115_BalanceScoreCard_Evaluation_Details_Level WITH (NOLOCK)
			
			INSERT INTO T0115_BalanceScoreCard_Evaluation_Details_Level
			(
				   Tran_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_BSC_Review_Detail_Id
				  ,Emp_BSC_Review_Level_Id
				  ,Rpt_Level
				  ,BSC_Setting_Detail_Id
				  ,Actual
				  ,Sup_Score
				  ,WeightedScore
			)
			VALUES
			(
				   @Tran_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_BSC_Review_Detail_Id
				  ,@Emp_BSC_Review_Level_Id
				  ,@Rpt_Level
				  ,@BSC_Setting_Detail_Id
				  ,@Actual
				  ,@Sup_Score
				  ,@WeightedScore
			)
		END
END


