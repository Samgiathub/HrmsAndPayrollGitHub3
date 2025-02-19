


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0110_EmployeeGoalSetting_Approval]
	 @EGS_Level_Id			numeric(18,0) output	
	,@Cmp_Id				numeric(18,0)
	,@Emp_Id				numeric(18,0)	
	,@S_Emp_Id				numeric(18,0)
	,@Emp_GoalSetting_Id	numeric(18,0)
	,@Approval_date			datetime
	,@Approval_Comments		varchar(500)
	,@Login_id				numeric(18,0)
	,@Rpt_Level				int
	,@Approval_Status		int
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
			IF Exists(Select 1 From T0110_EmployeeGoalSetting_Approval WITH (NOLOCK) Where Emp_ID=@Emp_ID and Emp_GoalSetting_Id=@Emp_GoalSetting_Id And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
				Begin
					Set @EGS_Level_Id = 0
					Select @EGS_Level_Id
					Return 
				End
			Select @EGS_Level_Id = ISNULL(MAX(EGS_Level_Id),0) + 1 From T0110_EmployeeGoalSetting_Approval WITH (NOLOCK)
			
			Insert Into T0110_EmployeeGoalSetting_Approval
					(
							EGS_Level_Id,
							Emp_GoalSetting_Id,
							Cmp_ID, 
							Emp_ID, 
							S_Emp_ID, 
							Approval_Date, 
							Approval_Status,
							Approval_Comments, 
							Login_ID,
							Rpt_Level
					)
				Values (
							@EGS_Level_Id, 
							@Emp_GoalSetting_Id, 
							@Cmp_ID, 
							@Emp_ID, 
							@S_Emp_ID, 
							@Approval_Date,
							@Approval_Status, 
							@Approval_Comments, 
							@Login_ID, 
							@Rpt_Level
						)
		END	
END


