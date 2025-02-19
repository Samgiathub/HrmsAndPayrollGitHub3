

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_EmpKPI_Approval]
		 @Tran_Id			numeric(18,0) output
		,@EmpKPI_Id			numeric(18,0)
		,@Cmp_Id			numeric(18,0)
		,@Emp_Id			numeric(18,0)
		,@S_Emp_Id			numeric(18,0)
		,@Approval_date		datetime
		,@Approval_Comments	varchar(500)
		,@Login_id			numeric(18,0)
		,@Rpt_Level			int
		,@Approval_Status	int
		,@Tran_Type			Char(1) 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL

	If UPPER(@Tran_Type) = 'I'
		Begin
			
			IF Exists(Select 1 From T0090_EmpKPI_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and EmpKPI_Id=@EmpKPI_Id And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @Tran_ID = 0
					Select @Tran_ID
					Return 
				End
		
			Select @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0090_EmpKPI_Approval WITH (NOLOCK)
			
			Insert Into T0090_EmpKPI_Approval
					(Tran_ID,EmpKPI_Id, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status,Approval_Comments, Login_ID,Rpt_Level)
			Values (@Tran_ID, @EmpKPI_Id, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID, @Rpt_Level)
			
		End
END

