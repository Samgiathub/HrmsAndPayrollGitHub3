



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <09-Jan-2013>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_SOLAssessment]
	@SOLAssessment_Id			numeric(18,0) Output,
	@SOLAssessment_CmpId		numeric(18,0),	
	@FK_EmployeeId				numeric(18,0),
	@FK_SupervisorId			numeric(18,0),
	@Employee_SignOff			tinyint,
	@Employee_SignOffDate		datetime,
	@Supervisor_SignOff			tinyint,
	@Supervisor_SignOffDate		datetime,
	@SOLAssessment_StartDate	datetime,
	@SOLAssessment_EndDate		datetime,
	@SOLAssessment_Year			numeric(18,0),
	@Tran_type					varchar(1),
	@User_Id					numeric(18,0)
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	if @Tran_type = 'I'
		begin
			select @SOLAssessment_Id = ISNULL(MAX(SOLAssessment_Id),0)+1  from T0090_HRMS_Appraisal_Emp_SOLAssessment WITH (NOLOCK)
			if @Employee_SignOffDate = '1-1-1900'
			begin
				set @Employee_SignOffDate = NULL
				set @Employee_SignOff = NULL
			end			
				INSERT INTO T0090_HRMS_Appraisal_Emp_SOLAssessment
					   (SOLAssessment_Id
					   ,SOLAssessment_CmpId
					   ,FK_EmployeeId
					   ,FK_SupervisorId
					   ,SOLAssessment_Year		
					   ,SOLAssessment_CreatedBy
					   ,SOLAssessment_CreatedDate)
				 VALUES
					   (@SOLAssessment_Id
					   ,@SOLAssessment_CmpId				   
					   ,@FK_EmployeeId
					   ,@FK_SupervisorId
					   ,@SOLAssessment_Year
					   ,@User_Id
					   ,GETDATE())
					   
			if ISNULL(@Employee_SignOff,0) = 1
			Begin
				exec P0090_HRMS_Appraisal_Emp_SOLAssessment_SignoffHistory 0,@SOLAssessment_Id,@Employee_SignOffDate,'I',@User_Id
			end
			
		end
	else if @Tran_type = 'U'
		begin
			Set @Employee_SignOff = ISNULL(@Employee_SignOff,0)
			Set @Supervisor_SignOff = ISNULL(@Supervisor_SignOff,0)
			
			if @Employee_SignOffDate = '1-1-1900'
			begin
				set @Employee_SignOff = NULL
				set @Employee_SignOffDate = NULL				
			end			
			if @Supervisor_SignOffDate = '1-1-1900'
				begin
					set @Supervisor_SignOff = NULL
					set @Supervisor_SignOffDate = NULL		
				end
			if @FK_SupervisorId = 0
				begin
					set @FK_SupervisorId = NULL
				end	
			
			if ISNULL(@Employee_SignOff,0) = 1
			 begin
				declare @check_signoff  tinyint
				select @check_signoff = ISNULL(Employee_SignOff,0) from T0090_HRMS_Appraisal_Emp_SOLAssessment WITH (NOLOCK) WHERE SOLAssessment_Id = @SOLAssessment_Id AND SOLAssessment_CmpId = @SOLAssessment_CmpId
				if ( @check_signoff = 0)
				begin
					exec P0090_HRMS_Appraisal_Emp_SOLAssessment_SignoffHistory 0,@SOLAssessment_Id,@Employee_SignOffDate,'I',@User_Id
				end
			 end
			
			UPDATE T0090_HRMS_Appraisal_Emp_SOLAssessment
			   SET 
				   SOLAssessment_Year = @SOLAssessment_Year				  
				  ,SOLAssessment_ModifyBy = @User_Id
				  ,SOLAssessment_ModifyDate = GETDATE()
			 WHERE SOLAssessment_Id = @SOLAssessment_Id AND SOLAssessment_CmpId = @SOLAssessment_CmpId
			 
		end
	else if @Tran_type = 'D'
		begin
			select @Employee_SignOff = Employee_SignOff  from T0090_HRMS_Appraisal_Emp_SOLAssessment WITH (NOLOCK) WHERE SOLAssessment_Id = @SOLAssessment_Id AND SOLAssessment_CmpId = @SOLAssessment_CmpId
			set @Employee_SignOff = ISNULL(@Employee_SignOff,0)
			if @Employee_SignOff = 0
			begin
				if not exists(select 1 from T0090_HRMS_Appraisal_Emp_SOLAssessment WITH (NOLOCK) WHERE SOLAssessment_Id = @SOLAssessment_Id AND SOLAssessment_CmpId = @SOLAssessment_CmpId AND (FK_SupervisorId <> NULL or FK_SupervisorId <> 0))
				begin
					DELETE FROM T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
						WHERE Fk_SOLAssessment_Id = @SOLAssessment_Id AND SOLAssessmentDtl_CmpId = @SOLAssessment_CmpId
					DELETE FROM T0090_HRMS_Appraisal_Emp_SOLAssessment_SignoffHistory
						WHERE FK_SOLAssessment_Id = @SOLAssessment_Id					
					DELETE FROM T0090_HRMS_Appraisal_Emp_SOLAssessment
						WHERE SOLAssessment_Id = @SOLAssessment_Id AND SOLAssessment_CmpId = @SOLAssessment_CmpId					
				end
				else
				begin
					set @SOLAssessment_Id = 0
					return
				end
			end
			else
			begin
				set @SOLAssessment_Id = 0
				return
			end
		end
END



