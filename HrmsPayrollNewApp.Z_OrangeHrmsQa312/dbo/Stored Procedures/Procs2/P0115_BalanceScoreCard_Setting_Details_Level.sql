


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_BalanceScoreCard_Setting_Details_Level]
	   @Tran_Id					numeric(18,0)
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@BSC_Setting_Detail_Id	numeric(18,0)
      ,@KPI_Id					numeric(18,0)
      ,@BSC_Objective			nvarchar(max)
      ,@BSC_Measure				nvarchar(200)
      ,@BSC_Target				nvarchar(100)
      ,@BSC_Formula				nvarchar(100)
      ,@BSC_Weight				numeric(18,2)
      ,@Rpt_Level				int
      ,@BSC_Level_Id			numeric(18,0)
      ,@tran_type				varchar(1) =null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		BEGIN
			IF @BSC_Level_Id =0
				BEGIN
					SELECT @BSC_Level_Id = max(BSC_Level_Id) from T0110_BalanceScoreCard_Setting_Approval WITH (NOLOCK)
					where rpt_level= @Rpt_Level and emp_id= @emp_id
					
				END
				
			select @Tran_Id = isnull(max(Tran_Id),0)+1 from T0115_BalanceScoreCard_Setting_Details_Level WITH (NOLOCK)
			
			INSERT INTO T0115_BalanceScoreCard_Setting_Details_Level
			(
				   Tran_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,BSC_Setting_Detail_Id
				  ,KPI_Id
				  ,BSC_Objective
				  ,BSC_Measure
				  ,BSC_Target
				  ,BSC_Formula
				  ,BSC_Weight
				  ,Rpt_Level
				  ,BSC_Level_Id
			)
			VALUES
			(
				   @Tran_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@BSC_Setting_Detail_Id
				  ,@KPI_Id
				  ,@BSC_Objective
				  ,@BSC_Measure
				  ,@BSC_Target
				  ,@BSC_Formula
				  ,@BSC_Weight
				  ,@Rpt_Level
				  ,@BSC_Level_Id
			)
		END
END


