



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <27-DEC-2012>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_Goal]
	@Goal_Id					numeric(18,0) Output,
	@Goal_CmpId					numeric(18,0),
	@Goal_Title					varchar(200),
	@FK_GoalType				numeric(18,0),
	@Employee_Comment			varchar(1000),
	@Employee_SignOff			tinyint,
	@Employee_SignOffDate		datetime,
	@Supervisor_Comment			varchar(1000),
	@Supervisor_SignOff			tinyint,
	@Supervisor_SignOffDate		datetime,
	@FK_EmployeeId				numeric(18,0),
	@FK_SupervisorId			numeric(18,0),
	--@Goal_StartDate			datetime,
	--@Goal_EndDate				datetime,
	@Goal_Year					numeric(18,0),
	@Tran_type					varchar(1),
	@User_Id					numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	if @Tran_type = 'I'
		begin
			select @Goal_Id = ISNULL(MAX(Goal_Id),0)+1 from T0090_HRMS_Appraisal_Emp_Goal WITH (NOLOCK)
			if @Employee_SignOffDate = '1-1-1900'
			begin
				set @Employee_SignOffDate = NULL
				set @Employee_SignOff = NULL
				Set @Employee_Comment = NULL
			end
				INSERT INTO T0090_HRMS_Appraisal_Emp_Goal
					   (Goal_Id
					   ,Goal_CmpId
					   ,Goal_Title
					   ,FK_GoalType
					   ,FK_EmployeeId
					   ,FK_SupervisorId
					   ,Employee_Comment
					   ,Employee_SignOff
					   ,Employee_SignOffDate				   
					   ,Goal_Year
					   ,Goal_CreatedBy
					   ,Goal_CreatedDate)
				 VALUES
					   (@Goal_Id
					   ,@Goal_CmpId
					   ,@Goal_Title
					   ,@FK_GoalType
					   ,@FK_EmployeeId
					   ,@FK_SupervisorId
					   ,@Employee_Comment
					   ,@Employee_SignOff
					   ,@Employee_SignOffDate			   
					   ,@Goal_Year
					   ,@User_Id
					   ,GETDATE())				   
				if ISNULL(@Employee_SignOff,0) = 1
				Begin				
				exec P0090_HRMS_Appraisal_Emp_Goal_SignoffHistory 0,@Goal_Id,@Employee_SignOffDate,'I',@User_Id
				end				
		end
	else if @Tran_type = 'U'
		begin
			if @Employee_SignOffDate = '1-1-1900'
			begin
				set @Employee_SignOff = NULL
				set @Employee_SignOffDate = NULL				
			end
			if @Employee_Comment = ''
			begin
				set @Employee_Comment = NULL
			end
			if @Supervisor_SignOffDate = '1-1-1900'
			begin
				set @Supervisor_SignOff = NULL
				set @Supervisor_SignOffDate = NULL
				set @Supervisor_Comment = NULL				
			end
			if @FK_SupervisorId = 0
			begin
				set @FK_SupervisorId = NULL
			end
			
			if	ISNULL(@Employee_SignOff,0) = 1
		    begin
				declare @check_signoff  tinyint
				select @check_signoff = ISNULL(Employee_SignOff,0) from T0090_HRMS_Appraisal_Emp_Goal WITH (NOLOCK) WHERE Goal_Id = @Goal_Id and Goal_CmpId = @Goal_CmpId
				if ( @check_signoff = 0)
				begin
					exec P0090_HRMS_Appraisal_Emp_Goal_SignoffHistory 0,@Goal_Id,@Employee_SignOffDate,'I',@User_Id
				end
			end 
			
			UPDATE T0090_HRMS_Appraisal_Emp_Goal
			   SET Goal_Title = @Goal_Title
				  ,FK_GoalType = @FK_GoalType
				  ,Employee_Comment = @Employee_Comment
				  ,Employee_SignOff = @Employee_SignOff
				  ,Employee_SignOffDate = @Employee_SignOffDate
				  ,Supervisor_Comment = @Supervisor_Comment
				  ,Supervisor_SignOff = @Supervisor_SignOff
				  ,Supervisor_SignOffDate = @Supervisor_SignOffDate
				  ,Goal_Year = @Goal_Year			  
				  ,Goal_ModifyBy = @User_Id
				  ,Goal_ModifyDate = GETDATE()
			 WHERE Goal_Id = @Goal_Id and Goal_CmpId = @Goal_CmpId
			 		
		end
	else if @Tran_type = 'D'
		begin
			select @Employee_SignOff = Employee_SignOff from T0090_HRMS_Appraisal_Emp_Goal WITH (NOLOCK) where Goal_Id = @Goal_Id AND Goal_CmpId = @Goal_CmpId
			set @Employee_SignOff = ISNULL(@Employee_SignOff,0)
			if @Employee_SignOff = 0
			begin				
					DELETE FROM T0090_HRMS_Appraisal_Emp_GoalDescription
								WHERE FK_GoalId = @Goal_Id AND GoalDescription_CmpId = @Goal_CmpId
					DELETE FROM T0090_HRMS_Appraisal_Emp_Goal_SignoffHistory
								WHERE FK_Goal_Id = @Goal_Id
					DELETE FROM T0090_HRMS_Appraisal_Emp_Goal
								WHERE Goal_Id = @Goal_Id AND Goal_CmpId = @Goal_CmpId
			end
			else
			begin
				set @Goal_Id = 0
				return
			end
		end
END



