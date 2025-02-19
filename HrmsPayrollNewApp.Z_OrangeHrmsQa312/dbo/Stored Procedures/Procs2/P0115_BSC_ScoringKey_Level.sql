


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0115_BSC_ScoringKey_Level]
	   @Row_Id					numeric(18,0)
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@Tran_Id					numeric(18,0)
      ,@BSC_Setting_Detail_Id	numeric(18,0)
      ,@Key_Name				varchar(50)
      ,@Key_Value				nvarchar(100)
      ,@BSC_Level_Id			numeric(18,0)
      ,@Rpt_Level				int
      ,@tran_type				varchar(1) =null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		BEGIN
			IF @tran_Id=0
				BEGIN
					SELECT @Tran_Id = max(Tran_Id) from T0115_BalanceScoreCard_Setting_Details_Level WITH (NOLOCK)
					where rpt_level= @Rpt_Level and emp_id= @emp_id and BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
				END
			IF @BSC_Level_Id =0
				BEGIN
					SELECT @BSC_Level_Id = max(BSC_Level_Id) from T0115_BalanceScoreCard_Setting_Details_Level WITH (NOLOCK)
					where rpt_level= @Rpt_Level and emp_id= @emp_id and BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id and tran_Id = @tran_Id
				END
				
			Insert into T0115_BSC_ScoringKey_Level
			(
					Row_Id
				  ,Cmp_Id
				  ,Tran_Id
				  ,BSC_Setting_Detail_Id
				  ,Key_Name
				  ,Key_Value
				  ,BSC_Level_Id
				  ,Rpt_Level
			)
			VALUES	
			(
				   @Row_Id
				  ,@Cmp_Id
				  ,@Tran_Id
				  ,@BSC_Setting_Detail_Id
				  ,@Key_Name
				  ,@Key_Value
				  ,@BSC_Level_Id
				  ,@Rpt_Level
			)
		END
END


