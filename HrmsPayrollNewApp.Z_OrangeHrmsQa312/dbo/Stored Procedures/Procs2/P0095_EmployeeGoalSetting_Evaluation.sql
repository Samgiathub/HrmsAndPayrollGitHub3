
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_EmployeeGoalSetting_Evaluation]
	   @Emp_GoalSetting_Review_Id	numeric(18,0) OUT
      ,@Cmp_Id						numeric(18,0)
      ,@Emp_Id						numeric(18,0)
      ,@FinYear						int
      ,@Review_Type					int
      ,@Review_Status				numeric(18,0)
      ,@Emp_Comments				varchar(300) =''
      ,@Manager_Comments			varchar(300) =''
      ,@AdditionalAchievement		varchar(1000)=''
      ,@Tran_Type			varchar(1)
      ,@User_Id				numeric(18,0)
      ,@IP_Address			varchar(30)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @OldValue as varchar(max)
	declare @OldReview_Type as varchar(10)
	declare @OldReview_Status as varchar(18)
	declare @OldFinYear as varchar(4)
	declare @OldEmp_Comment as varchar(300)
	declare @OldManager_Comment as varchar(300)
	declare @OldAdditionalAchievement as varchar(1000)
	declare @oldDate as varchar(50)
	
	set @OldValue =''
	set @OldReview_Type =''
	set @OldReview_Status =''
	set @OldFinYear =''
	set @OldEmp_Comment =''
	set @OldManager_Comment =''
	set @OldAdditionalAchievement =''
	set @oldDate =''
	
	If @Tran_Type = 'I'
		BEGIN
			-- to check whether final review exists for fin year
			IF EXISTS(select 1 from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@FinYear and Review_Type=2)
				BEGIN 
					SET @Emp_GoalSetting_Review_Id = 0 
					Select @Emp_GoalSetting_Review_Id
					RETURN
				END
				-- to check whether unclosed review exists for fin year
			IF EXISTS(select 1 from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where Emp_Id=@Emp_Id and FinYear=@FinYear and Review_Status<>4)
				BEGIN 
					SET @Emp_GoalSetting_Review_Id = 0 
					Select @Emp_GoalSetting_Review_Id
					RETURN
				END
			select @Emp_GoalSetting_Review_Id = isnull(max(Emp_GoalSetting_Review_Id),0)+1 from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK)
			Insert	Into T0095_EmployeeGoalSetting_Evaluation
			(
				   Emp_GoalSetting_Review_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,FinYear
				  ,Review_Type
				  ,Review_Status
				  ,Emp_Comments
				  ,Manager_Comments
				  ,AdditionalAchievement
				  ,CreatedDate
				  ,CreatedBy
			)
			VALUES
			(
				  @Emp_GoalSetting_Review_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@FinYear
				  ,@Review_Type
				  ,@Review_Status
				  ,@Emp_Comments
				  ,@Manager_Comments
				  ,@AdditionalAchievement
				  ,GETDATE()
				  ,@User_Id
			)
			
			set @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' 
										+ 'Status :' + case when @Review_Status = 0 then 'Draft' when @Review_Status=1 then 'Send For Employee Review' when @Review_Status=3 then 'Approved By Employee' when @Review_Status =4 then 'Approved By Manager' end + '#' 
										+ 'Review Type :' + case when @Review_Type = 1 then 'Interim' else 'Final' end + '#' + 'Employee Comments :' +ISNULL(@Emp_Comments,'') + '#' + 'Manager Comment :' + isnull(@Manager_Comments,'') + '#' + 'Additional Achievements :' + @AdditionalAchievement  + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'U'
		BEGIN
			select @OldReview_Status = cast(Review_Status as varchar),@OldReview_Type=cast(review_type as VARCHAR) ,@OldFinYear =cast(FinYear as varchar),
				  @OldEmp_Comment =isnull(Emp_Comments,''),@OldManager_Comment = isnull(Manager_Comments,''),
				  @oldDate= isnull(ModifiedDate,CreatedDate) 
			From dbo.T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
			
			UPDATE T0095_EmployeeGoalSetting_Evaluation
			SET Review_Status = @Review_Status
				,FinYear	= @FinYear
				,Emp_Comments= @Emp_Comments				
				,Manager_Comments = @Manager_Comments
				,AdditionalAchievement = @AdditionalAchievement
				,ModifiedDate = GETDATE()
				,ModifiedBy	= @User_Id
			WHERE Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
			
			set @OldValue =  'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@OldFinYear as varchar) + '#' 
										+ 'Status :' + case when @OldReview_Status = 0 then 'Draft' when @OldReview_Status=1 then 'Send For Employee Review' when @OldReview_Status=3 then 'Approved By Employee' when @OldReview_Status =4 then 'Approved By Manager' end + '#' 
										+ 'Review Type :' + case when @OldReview_Type = 1 then 'Interim' else 'Final' end + '#' + 'Employee Comments :' +ISNULL(@OldEmp_Comment,'') + '#' + 'Manager Comment :' + isnull(@OldManager_Comment,'') + '#' + 'Additional Achievements :' + @OldAdditionalAchievement  + '#' + 'Date :' +  cast(GETDATE() as varchar)
							+'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' 
										+ 'Status :' + case when @Review_Status = 0 then 'Draft' when @Review_Status=1 then 'Send For Employee Review' when @Review_Status=3 then 'Approved By Employee' when @Review_Status =4 then 'Approved By Manager' end + '#' 
										+ 'Review Type :' + case when @Review_Type = 1 then 'Interim' else 'Final' end + '#' + 'Employee Comments :' +ISNULL(@Emp_Comments,'') + '#' + 'Manager Comment :' + isnull(@Manager_Comments,'') + '#' + 'Additional Achievements :' + @AdditionalAchievement  + '#' + 'Date :' +  cast(GETDATE() as varchar)
		END
	ELSE IF  @Tran_Type = 'D'	
		BEGIN
			select @OldReview_Status = cast(Review_Status as varchar),@OldReview_Type=cast(review_type as VARCHAR) ,@OldFinYear =cast(FinYear as varchar),
				  @OldEmp_Comment =isnull(Emp_Comments,''),@OldManager_Comment = isnull(Manager_Comments,''),
				  @oldDate= isnull(ModifiedDate,CreatedDate) 
			From dbo.T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID and Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
			
			set @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@OldFinYear as varchar) + '#' 
										+ 'Status :' + case when @OldReview_Status = 0 then 'Draft' when @OldReview_Status=1 then 'Send For Employee Review' when @OldReview_Status=3 then 'Approved By Employee' when @OldReview_Status =4 then 'Approved By Manager' end + '#' 
										+ 'Review Type :' + case when @OldReview_Type = 1 then 'Interim' else 'Final' end + '#' + 'Employee Comments :' +ISNULL(@OldEmp_Comment,'') + '#' + 'Manager Comment :' + isnull(@OldManager_Comment,'') + '#' + 'Additional Achievements :' + @OldAdditionalAchievement  + '#' + 'Date :' +  cast(GETDATE() as varchar)
			
			DELETE FROM T0115_EmployeeGoal_SupEval_Level WHERE EGS_Review_Level_Id in 
			(select EGS_Review_Level_Id from  T0110_EmployeeGoalSetting_Evaluation_Approval WITH (NOLOCK) where Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id)
			DELETE FROM T0115_EmployeeGoalSetting_Evaluation_Details_Level WHERE EGS_Review_Level_Id in 
			(select EGS_Review_Level_Id from  T0110_EmployeeGoalSetting_Evaluation_Approval WITH (NOLOCK) where Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id)
			DELETE FROM T0110_EmployeeGoalSetting_Evaluation_Approval WHERE Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
			DELETE FROM T0100_EmployeeGoal_SupEval WHERE Emp_GoalSetting_Review_Id =@Emp_GoalSetting_Review_Id
			DELETE FROM T0100_EmployeeGoalSetting_Evaluation_Details WHERE Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
			DELETE FROM T0095_EmployeeGoalSetting_Evaluation WHERE Emp_GoalSetting_Review_Id = @Emp_GoalSetting_Review_Id
		END
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee Goal Review',@OldValue,@Emp_GoalSetting_Review_Id,@User_Id,@IP_Address

END

