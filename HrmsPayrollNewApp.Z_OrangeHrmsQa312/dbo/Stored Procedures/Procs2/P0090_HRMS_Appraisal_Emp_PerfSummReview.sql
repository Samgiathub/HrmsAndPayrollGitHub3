




-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <04_Mar_2013>
-- @Is_Emp_Manager = 1(Employee) , 2(Manager), 3(Manager's Manager), 4(Business Hr)
-- ---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_PerfSummReview]
	@PSReview_Id				numeric(18,0) output,
	@FK_PSId					numeric(18,0),
	@FK_EmployeeId				numeric(18,0),
	@PS_Comment					varchar(1000),
	@CP_Comment					varchar(1000),
	@FK_RatingId				numeric(18,0),
	@PSReview_Signoff			tinyint,
	@PSReview_SignoffDate		Datetime,
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
			select @PSReview_Id = ISNULL(MAX(PSReview_Id),0)+1 from T0090_HRMS_Appraisal_Emp_PerfSummReview WITH (NOLOCK)
			if @PSReview_SignoffDate = '1-1-1900'
			begin
				set @PSReview_SignoffDate = NULL
				set @PSReview_Signoff = NULL
			end
			if @FK_PSId = 0
			 begin
				select @FK_PSId = MAX(PS_Id) from T0090_HRMS_Appraisal_Emp_PerformanceSummary WITH (NOLOCK)
			 end			
			INSERT INTO T0090_HRMS_Appraisal_Emp_PerfSummReview
				   (PSReview_Id
				   ,FK_PSId
				   ,FK_EmployeeId
				   ,PS_Comment
				   ,CP_Comment
				   ,FK_RatingId
				   ,PSReview_Signoff
				   ,PSReview_SignoffDate
				   ,Is_Emp_Manager
				   ,FK_SettingId
				   ,PSReview_CreatedBy
				   ,PSReview_CreatedDate)
			 VALUES
				   (@PSReview_Id
				   ,@FK_PSId
				   ,@FK_EmployeeId
				   ,@PS_Comment
				   ,@CP_Comment
				   ,@FK_RatingId
				   ,@PSReview_Signoff
				   ,@PSReview_SignoffDate
				   ,@Is_Emp_Manager
				   ,@FK_SettingId
				   ,@User_Id
				   ,GETDATE())
		end
	else if @Tran_type = 'U'
		begin
			if @PSReview_SignoffDate = '1-1-1900'
			begin
				set @PSReview_SignoffDate = NULL
				set @PSReview_Signoff = NULL
			end
			UPDATE T0090_HRMS_Appraisal_Emp_PerfSummReview
			   SET PS_Comment = @PS_Comment
				  ,CP_Comment = @CP_Comment
				  ,FK_RatingId = @FK_RatingId
				  ,PSReview_Signoff = @PSReview_Signoff
				  ,PSReview_SignoffDate = @PSReview_SignoffDate
				  ,FK_EmployeeId = @FK_EmployeeId
				  ,PSReview_ModifyBy = @User_Id
				  ,PSReview_ModifyDate = GETDATE()
			 WHERE PSReview_Id = @PSReview_Id
		end
END



