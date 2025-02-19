



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <22_Feb_2013>
-- @Is_Emp_Manager = 1(Employee) , 2(Manager), 3(Manager's Manager), 4(Business Hr)
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_GoalReview]
	@ReviewGoal_Id				numeric(18,0) Output,
	@ReviewGoal_CmpId			numeric(18,0),
	@FK_GoalId					numeric(18,0),
	@FK_GoalDescriptionId		numeric(18,0),
	@FK_EmployeeId				numeric(18,0),
	@Comment					varchar(1000),
	@FK_Rating					numeric(18,0),
	@ReviewGoal_Signoff			tinyint,
	@ReviewGoal_SignoffDate		Datetime,
	@Is_Emp_Manager				tinyint,
	@FK_SettingId				numeric(18,0),
	@Tran_type					varchar(1),
	@User_Id					numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	if @Tran_type = 'I'
		begin
			select @ReviewGoal_Id = ISNULL(MAX(ReviewGoal_Id),0)+1 from T0090_HRMS_Appraisal_Emp_GoalReview WITH (NOLOCK)
			if @ReviewGoal_SignoffDate = '1-1-1900'
			begin
				set @ReviewGoal_SignoffDate = NULL
				set @ReviewGoal_Signoff = NULL
			end
			INSERT INTO T0090_HRMS_Appraisal_Emp_GoalReview
					   (ReviewGoal_Id
					   ,ReviewGoal_CmpId
					   ,FK_GoalId
					   ,FK_GoalDescriptionId
					   ,FK_EmployeeId
					   ,Comment
					   ,FK_Rating
					   ,ReviewGoal_Signoff
					   ,ReviewGoal_SignoffDate
					   ,Is_Emp_Manager
					   ,FK_SettingId
					   ,ReviewGoal_CreatedBy
					   ,ReviewGoal_CreatedDate)
				 VALUES
					   (@ReviewGoal_Id
					   ,@ReviewGoal_CmpId
					   ,@FK_GoalId
					   ,@FK_GoalDescriptionId
					   ,@FK_EmployeeId
					   ,@Comment
					   ,@FK_Rating
					   ,@ReviewGoal_Signoff
					   ,@ReviewGoal_SignoffDate
					   ,@Is_Emp_Manager
					   ,@FK_SettingId
					   ,@User_Id
					   ,GETDATE())
		end
	else if @Tran_type = 'U'
		begin
			if @ReviewGoal_SignoffDate = '1-1-1900'
			begin
				set @ReviewGoal_SignoffDate = NULL
				set @ReviewGoal_Signoff = NULL
			end
			UPDATE T0090_HRMS_Appraisal_Emp_GoalReview
			   SET Comment = @Comment
				  ,FK_Rating = @FK_Rating
				  ,FK_EmployeeId = @FK_EmployeeId
				  ,ReviewGoal_Signoff = @ReviewGoal_Signoff
				  ,ReviewGoal_SignoffDate = @ReviewGoal_SignoffDate		  
				  ,ReviewGoal_ModifyBy = @User_Id
				  ,ReviewGoal_ModifyDate = GETDATE()
			 WHERE ReviewGoal_Id = @ReviewGoal_Id
		end
END



