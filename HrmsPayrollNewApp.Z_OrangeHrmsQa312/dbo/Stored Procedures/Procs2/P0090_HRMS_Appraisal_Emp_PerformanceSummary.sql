



-- =============================================
-- Author:		Ripal Patel
-- ALTER date: 07-Jan-2013
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_PerformanceSummary]
	@PS_Id					numeric(18,0) Output,
	@PS_CmpId				numeric(18,0),
	@PS_EmployeeComment		varchar(500),
	@PS_SupervisorComment	varchar(500),
	@Cp_EmployeeComment		varchar(500),
	@Cp_SupervisorComment	varchar(500),
	@FK_Rating				numeric(18,0),
	@FK_EmployeeId			numeric(18,0),
	@FK_SupervisorId		numeric(18,0),
	@Employee_SignOff		tinyint,
	@Employee_SignOffDate	datetime,
	@Supervisor_SignOff		tinyint,
	@Supervisor_SignOffDate	datetime,
	@PS_StartDate			datetime,
	@PS_EndDate				datetime,
	@PS_Year				numeric(18,0),
	@Tran_type				varchar(1),
	@User_Id				numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Tran_type = 'I'
		begin
			select @PS_Id = ISNULL(MAX(PS_Id),0)+1  from T0090_HRMS_Appraisal_Emp_PerformanceSummary WITH (NOLOCK)
			if @Employee_SignOffDate = '1-1-1900'
			begin
				set @Employee_SignOffDate = NULL
				set @Employee_SignOff = NULL
			end
			INSERT INTO T0090_HRMS_Appraisal_Emp_PerformanceSummary
					   (PS_Id
					   ,PS_CmpId					   
					   ,FK_EmployeeId
					   ,FK_SupervisorId					   
					   ,PS_Year
					   ,PS_CreatedBy
					   ,PS_CreatedDate)
				 VALUES
					   (@PS_Id
					   ,@PS_CmpId					   
					   ,@FK_EmployeeId
					   ,@FK_SupervisorId					   
					   ,@PS_Year
					   ,@User_Id
					   ,GETDATE())
			
			if ISNULL(@Employee_SignOff,0) = 1
			Begin
			exec P0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory 0,@PS_Id,@Employee_SignOffDate,'I',@User_Id
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
		if @FK_Rating = 0
			begin
				set @FK_Rating = NULL
			end
		if @PS_SupervisorComment = ''
			begin
				set @PS_SupervisorComment = NULL
			end
		if @Cp_SupervisorComment = ''
			begin
				set @Cp_SupervisorComment = NULL
			end
			
		 if ISNULL(@Employee_SignOff,0) = 1
		    begin
				declare @check_signoff  tinyint
				select @check_signoff = ISNULL(Employee_SignOff,0) from T0090_HRMS_Appraisal_Emp_PerformanceSummary WITH (NOLOCK) WHERE PS_Id = @PS_Id AND PS_CmpId = @PS_CmpId
				if ( @check_signoff = 0)
				begin
					exec P0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory 0,@PS_Id,@Employee_SignOffDate,'I',@User_Id
				end
		    end

			UPDATE T0090_HRMS_Appraisal_Emp_PerformanceSummary
			   SET PS_EmployeeComment = @PS_EmployeeComment
				  ,PS_SupervisorComment = @PS_SupervisorComment
				  ,Cp_EmployeeComment = @Cp_EmployeeComment
				  ,Cp_SupervisorComment = @Cp_SupervisorComment
				  ,FK_Rating = @FK_Rating				  
				  ,PS_Year = @PS_Year
				  ,Employee_SignOff = @Employee_SignOff
				  ,Employee_SignOffDate = @Employee_SignOffDate
				  ,Supervisor_SignOff = @Supervisor_SignOff
                  ,Supervisor_SignOffDate = @Supervisor_SignOffDate
				  ,PS_ModifyBy = @User_Id
				  ,PS_ModifyDate = GETDATE()
			 WHERE PS_Id = @PS_Id AND PS_CmpId = @PS_CmpId
		 
	end
	else if @Tran_type = 'D'
	begin
		select @Employee_SignOff = Employee_SignOff  from T0090_HRMS_Appraisal_Emp_PerformanceSummary WITH (NOLOCK) WHERE PS_Id = @PS_Id AND PS_CmpId = @PS_CmpId
		set @Employee_SignOff = ISNULL(@Employee_SignOff,0)
		if @Employee_SignOff = 0
		begin
			if not exists(select 1 from T0090_HRMS_Appraisal_Emp_PerformanceSummary WITH (NOLOCK) WHERE PS_Id = @PS_Id AND PS_CmpId = @PS_CmpId and (FK_SupervisorId <> NULL or FK_SupervisorId <> 0) )
			begin
				DELETE FROM T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory
					WHERE FK_PS_Id = @PS_Id
				DELETE FROM T0090_HRMS_Appraisal_Emp_PerformanceSummary
					WHERE PS_Id = @PS_Id AND PS_CmpId = @PS_CmpId
			end
			else
			begin
				set @PS_Id = 0
				return
			end
		end
		else
		begin
			set @PS_Id = 0
			return
		end		
	end
END



