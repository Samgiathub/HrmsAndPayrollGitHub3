



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <27-dec-2012>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_GoalDescription]
	@GoalDescription_Id		numeric(18,0) Output,
	@FK_GoalId				numeric(18,0),
	@GoalDescription_CmpId	numeric(18,0),
	@GoalDescription		varchar(1000),
	@SuccessCriteria		varchar(1000),
	@FK_GoalType			numeric(18,0),
	@AbovePar				varchar(500),
	@AtPar					varchar(500),
	@BelowPar				varchar(500),
	@Employee_Comment		varchar(1000),
	@Supervisor_Comment		varchar(1000),
	@FK_Rating				numeric(18,0),
	@FK_EmployeeId			numeric(18,0),
	@FK_SupervisorId		numeric(18,0),
	@GoalDescription_Year	numeric(18,0),
	@Tran_type				varchar(1),
	@User_Id				numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	if @Tran_type = 'I'
		begin
			select @GoalDescription_Id = ISNULL(MAX(GoalDescription_Id),0)+1 from T0090_HRMS_Appraisal_Emp_GoalDescription WITH (NOLOCK)
			if @FK_GoalId = 0 
				begin
					select @FK_GoalId = MAX(Goal_Id) from T0090_HRMS_Appraisal_Emp_Goal WITH (NOLOCK)
				end
			INSERT INTO T0090_HRMS_Appraisal_Emp_GoalDescription
					   (GoalDescription_Id
					   ,FK_GoalId
					   ,GoalDescription_CmpId
					   ,GoalDescription
					   ,SuccessCriteria
					   ,FK_GoalType
					   ,AbovePar
					   ,AtPar
					   ,BelowPar
					   ,Employee_Comment
					   ,FK_Rating
					   ,FK_EmployeeId
					   ,GoalDescription_Year
					   ,GoalDescription_CreatedBy
					   ,GoalDescription_CreatedDate)
				 VALUES
					   (@GoalDescription_Id
					   ,@FK_GoalId
					   ,@GoalDescription_CmpId
					   ,@GoalDescription
					   ,@SuccessCriteria
					   ,@FK_GoalType
					   ,@AbovePar
					   ,@AtPar
					   ,@BelowPar
					   ,@Employee_Comment
					   ,@FK_Rating
					   ,@FK_EmployeeId
					   ,@GoalDescription_Year
					   ,@User_Id
					   ,GETDATE())
		end
	if @Tran_type = 'U'
		begin
			if @FK_Rating = 0
				begin
					set @FK_Rating = NULL
				end
			if @Supervisor_Comment = ''
			begin				
				UPDATE T0090_HRMS_Appraisal_Emp_GoalDescription
				   SET GoalDescription = @GoalDescription
					  ,SuccessCriteria = @SuccessCriteria
					  ,FK_GoalType = @FK_GoalType
					  ,AbovePar = @AbovePar
					  ,AtPar = @AtPar
					  ,BelowPar = @BelowPar
					  ,Employee_Comment = @Employee_Comment
					  ,FK_Rating = @FK_Rating
					  ,GoalDescription_ModifyBy = @User_Id
					  ,GoalDescription_ModifyDate = GETDATE()
				 WHERE GoalDescription_Id = @GoalDescription_Id AND
					   FK_GoalId = @FK_GoalId AND
					   GoalDescription_CmpId = @GoalDescription_CmpId
			end
			else
			begin
				UPDATE T0090_HRMS_Appraisal_Emp_GoalDescription
				   SET GoalDescription = @GoalDescription
					  ,SuccessCriteria = @SuccessCriteria
					  ,FK_GoalType = @FK_GoalType
					  ,AbovePar = @AbovePar
					  ,AtPar = @AtPar
					  ,BelowPar = @BelowPar
					  ,Employee_Comment = @Employee_Comment
					  ,Supervisor_Comment = @Supervisor_Comment
					  ,FK_Rating = @FK_Rating
					  ,FK_SupervisorId = @FK_SupervisorId
					  ,GoalDescription_ModifyBy = @User_Id
					  ,GoalDescription_ModifyDate = GETDATE()
				 WHERE GoalDescription_Id = @GoalDescription_Id AND
					   FK_GoalId = @FK_GoalId AND
					   GoalDescription_CmpId = @GoalDescription_CmpId
			end
			
		end
	if @Tran_type = 'D'
		begin
			DELETE FROM T0090_HRMS_Appraisal_Emp_GoalDescription
						WHERE GoalDescription_Id = @GoalDescription_Id AND
							  GoalDescription_CmpId = @GoalDescription_CmpId
		end
	
END



