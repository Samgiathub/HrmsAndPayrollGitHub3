

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_KPIPMS_EVAL_Approval]
	 @Tran_Id			numeric(18,0) out
	,@KPIPMS_ID			numeric(18,0)
	,@Cmp_Id			numeric(18,0)
	,@Emp_Id			numeric(18,0)
	,@S_Emp_Id			numeric(18,0)
	,@Approval_date		datetime
	,@Rpt_Level			int
	,@Approval_Status	int
	,@KPIPMS_Type		int
	,@KPIPMS_Name		varchar(50)
	,@KPIPMS_FinalRating	numeric(18,0)
	,@KPIPMS_SupEarlyComment varchar(500)
	,@Manager_Score		numeric(18,0)
	,@Tran_Type				Char(1) 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
	
	If UPPER(@Tran_Type) = 'I'
		Begin
			
			IF Exists(Select 1 From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and KPIPMS_ID=@KPIPMS_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
		
			Select @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
			
			Insert Into T0090_KPIPMS_EVAL_Approval
					(Tran_ID,KPIPMS_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status, Rpt_Level,KPIPMS_Type,KPIPMS_Name,KPIPMS_FinalRating,KPIPMS_SupEarlyComment,Manager_Score)
			Values (@Tran_ID, @KPIPMS_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Rpt_Level, @KPIPMS_Type, @KPIPMS_Name, @KPIPMS_FinalRating,@KPIPMS_SupEarlyComment,@Manager_Score)
			
		End
END

