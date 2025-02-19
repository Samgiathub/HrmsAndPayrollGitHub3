


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0110_BalanceScoreCard_Evaluation_Approval]
	   @Emp_BSC_Review_Level_Id	numeric(18,0) output	
      ,@Cmp_Id					numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@S_Emp_Id				numeric(18,0)
      ,@Emp_BSC_Review_Id		numeric(18,0)
      ,@Approval_Date			datetime
      ,@Approval_Comments		varchar(500)
      ,@Login_Id				numeric(18,0)
      ,@Rpt_Level				int	
      ,@Approval_Status			int
      ,@Tran_Type				Char(1) 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
		
	If UPPER(@Tran_Type) = 'I'
		BEGIN
			IF Exists(Select 1 From T0110_BalanceScoreCard_Evaluation_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and Emp_BSC_Review_Id=@Emp_BSC_Review_Id And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Emp_BSC_Review_Level_Id = 0
					Select @Emp_BSC_Review_Level_Id
					Return 
				End
				
			SELECT @Emp_BSC_Review_Level_Id = ISNULL(MAX(Emp_BSC_Review_Level_Id),0) + 1 From T0110_BalanceScoreCard_Evaluation_Approval WITH (NOLOCK) 
			Insert Into T0110_BalanceScoreCard_Evaluation_Approval
			(
				   Emp_BSC_Review_Level_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,S_Emp_Id
				  ,Emp_BSC_Review_Id
				  ,Approval_Date
				  ,Approval_Comments
				  ,Login_Id
				  ,Rpt_Level
				  ,Approval_Status
			)
			VALUES
			(
				   @Emp_BSC_Review_Level_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@S_Emp_Id
				  ,@Emp_BSC_Review_Id
				  ,@Approval_Date
				  ,@Approval_Comments
				  ,@Login_Id
				  ,@Rpt_Level
				  ,@Approval_Status
			)
		END	
END


