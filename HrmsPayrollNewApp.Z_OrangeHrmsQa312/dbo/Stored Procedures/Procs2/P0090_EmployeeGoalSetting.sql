
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EmployeeGoalSetting]
	   @Emp_GoalSetting_Id	numeric(18,0) out
      ,@Cmp_Id				numeric(18,0)
      ,@Emp_Id				numeric(18,0)
      ,@EGS_Status			numeric(18,0)
      ,@FinYear				int
      ,@Emp_Comment			NVARCHAR(300)='' --Changed by Deepali -02Jun22
      ,@Manager_Comment		NVARCHAR(300)='' --Changed by Deepali -02Jun22
      ,@Tran_Type			varchar(1)
      ,@User_Id				numeric(18,0)
      ,@IP_Address			varchar(30)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

declare @OldValue as nvarchar(max) --Changed by Deepali -02Jun22
declare @OldEGS_Status as varchar(18)
declare @OldFinYear as varchar(4)
declare @OldEmp_Comment as nvarchar(300) --Changed by Deepali -02Jun22
declare @OldManager_Comment as nvarchar(300)  --Changed by Deepali -02Jun22
declare @oldDate as varchar(50)

set @OldValue =''
set @OldEGS_Status = ''
set @OldFinYear = ''
set @OldEmp_Comment =''
set @OldManager_Comment =''
set @oldDate =''


	SET NOCOUNT ON;
	If @Tran_Type = 'I'
		BEGIN
			if EXISTS(select 1 from T0090_EmployeeGoalSetting WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@FinYear)
				BEGIN 
					SET @Emp_GoalSetting_Id = 0 
					Select @Emp_GoalSetting_Id
					RETURN
				END
			select @Emp_GoalSetting_Id = isnull(max(Emp_GoalSetting_Id),0)+1 from T0090_EmployeeGoalSetting WITH (NOLOCK)
			INSERT INTO T0090_EmployeeGoalSetting
			(
				 Emp_GoalSetting_Id
				,Cmp_Id
				,Emp_Id
				,EGS_Status
				,FinYear
				,Emp_Comment
				,Manager_Comment
				,CreatedDate
				,CreatedBy
			)VALUES
			(
				@Emp_GoalSetting_Id
				,@Cmp_Id
				,@Emp_Id
				,@EGS_Status
				,@FinYear
				,@Emp_Comment
				,@Manager_Comment
				,GETDATE()
				,@User_Id
			)
			
			set @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @EGS_Status = 0 then 'Draft' when @EGS_Status=1 then 'Send For Employee Review' when @EGS_Status=3 then 'Approved By Employee' when @EGS_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@Emp_Comment,'') + '#' + 'Manager Comment :' + isnull(@Manager_Comment,'') + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'U'
		BEGIN
			
			select @OldEGS_Status = cast(EGS_Status as varchar) ,@OldFinYear =cast(FinYear as varchar),@OldEmp_Comment =isnull(Emp_Comment,''),@OldManager_Comment = isnull(Manager_Comment,''),@oldDate= isnull(ModifiedDate,CreatedDate) From dbo.T0090_EmployeeGoalSetting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Id = @Emp_GoalSetting_Id
			
			UPDATE T0090_EmployeeGoalSetting
			SET EGS_Status = @EGS_Status
				,FinYear	= @FinYear
				,Emp_Comment= @Emp_Comment				
				,Manager_Comment = @Manager_Comment
				,ModifiedDate = GETDATE()
				,ModifiedBy	= @User_Id
			WHERE Emp_GoalSetting_Id = @Emp_GoalSetting_Id
			
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + @OldFinYear + '#' + 'Status :' + case when @OldEGS_Status = 0 then 'Draft' when @OldEGS_Status=1 then 'Send For Employee Review' when @OldEGS_Status=3 then 'Approved By Employee' when @OldEGS_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@OldEmp_Comment,'') + '#' + 'Manager Comment :' + isnull(@OldManager_Comment,'') + '#' + 'Date :' +  @oldDate +
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Status :' + case when @EGS_Status = 0 then 'Draft' when @EGS_Status=1 then 'Send For Employee Review' when @EGS_Status=3 then 'Approved By Employee' when @EGS_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@Emp_Comment,'') + '#' + 'Manager Comment :' + isnull(@Manager_Comment,'') + '#' + 'Date :' + cast(GETDATE() as varchar)
			
		END
	ELSE IF  @Tran_Type = 'D'	
		BEGIN
			select @OldEGS_Status = EGS_Status ,@OldFinYear =FinYear,@OldEmp_Comment =isnull(Emp_Comment,''),@OldManager_Comment = isnull(Manager_Comment,''),@oldDate= isnull(ModifiedDate,CreatedDate) From dbo.T0090_EmployeeGoalSetting WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Id = @Emp_GoalSetting_Id
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + @OldFinYear + '#' + 'Status :' + case when @OldEGS_Status = 0 then 'Draft' when @OldEGS_Status=1 then 'Send For Employee Review' when @OldEGS_Status=3 then 'Approved By Employee' when @OldEGS_Status =4 then 'Approved By Manager' end + '#' + 'Employee comment :' +ISNULL(@OldEmp_Comment,'') + '#' + 'Manager Comment :' + isnull(@OldManager_Comment,'') + '#' + 'Date :' +  @oldDate
			
			DELETE FROM T0115_EmployeeGoalSetting_Details_Level WHERE EGS_Level_Id in 
			(select EGS_Level_Id from  T0110_EmployeeGoalSetting_Approval  WITH (NOLOCK) where Emp_GoalSetting_Id= @Emp_GoalSetting_Id)
			DELETE FROM T0110_EmployeeGoalSetting_Approval WHERE Emp_GoalSetting_Id = @Emp_GoalSetting_Id
			DELETE FROM T0095_EmployeeGoalSetting_Details WHERE Emp_GoalSetting_Id = @Emp_GoalSetting_Id
			DELETE FROM T0090_EmployeeGoalSetting WHERE Emp_GoalSetting_Id = @Emp_GoalSetting_Id
						
		END
		
	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Goal Setting',@OldValue,@Emp_GoalSetting_Id,@User_Id,@IP_Address
END

