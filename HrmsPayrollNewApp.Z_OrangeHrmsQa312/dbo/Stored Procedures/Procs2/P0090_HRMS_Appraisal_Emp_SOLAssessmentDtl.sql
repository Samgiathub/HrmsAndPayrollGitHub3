



-- =============================================
-- Author:		<Ripal Patel>
-- ALTER date: <09-Jan-2013>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_Appraisal_Emp_SOLAssessmentDtl]
	@SOLAssessmentDtl_Id		numeric(18,0) output,
	@SOLAssessmentDtl_CmpId		numeric(18,0),
	@Fk_SOLAssessment_Id		numeric(18,0),
	@Fk_SOL						numeric(18,0),
	@FK_EmployeeId				numeric(18,0),
	@IndicativeExample			varchar(1000),
	@DepartmentActionPlan		varchar(1000),
	@FK_Rating_Emp				numeric(18,0),
	@FK_Rating_Sup				numeric(18,0),
	@ReviewSOL_Signoff			tinyint,
	@ReviewSOL_SignoffDate		Datetime,
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
			
			select @SOLAssessmentDtl_Id = ISNULL(MAX(SOLAssessmentDtl_Id),0)+1 from T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl WITH (NOLOCK)
			if @Fk_SOLAssessment_Id = 0 
				begin
					select @Fk_SOLAssessment_Id = MAX(SOLAssessment_Id) from T0090_HRMS_Appraisal_Emp_SOLAssessment WITH (NOLOCK)
				end
				
			if @ReviewSOL_SignoffDate = '1-1-1900'
			begin
				set @ReviewSOL_SignoffDate = NULL
				set @ReviewSOL_Signoff = NULL
			end	
			if @IndicativeExample = ''
				begin
					set @IndicativeExample = null
				end
			if @DepartmentActionPlan = ''
				begin
					set @DepartmentActionPlan = null
				end
			if @FK_Rating_Emp = 0
				begin
					set @FK_Rating_Emp = null
				end
			if @FK_Rating_Sup = 0
				begin
					set @FK_Rating_Sup = null
				end
							
			INSERT INTO T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
					   (SOLAssessmentDtl_Id
					   ,SOLAssessmentDtl_CmpId
					   ,Fk_SOLAssessment_Id
					   ,Fk_SOL
					   ,FK_EmployeeId
					   ,IndicativeExample
					   ,DepartmentActionPlan
					   ,FK_Rating_Emp
					   ,FK_Rating_Sup
					   ,ReviewSOL_Signoff
					   ,ReviewSOL_SignoffDate
					   ,Is_Emp_Manager
					   ,FK_SettingId
					   ,SOLAssessmentDtl_CreatedBy
					   ,SOLAssessmentDtl_CreatedDate)
				 VALUES
					   (@SOLAssessmentDtl_Id
					   ,@SOLAssessmentDtl_CmpId
					   ,@Fk_SOLAssessment_Id
					   ,@Fk_SOL
					   ,@FK_EmployeeId
					   ,@IndicativeExample
					   ,@DepartmentActionPlan
					   ,@FK_Rating_Emp
					   ,@FK_Rating_Sup
					   ,@ReviewSOL_Signoff
					   ,@ReviewSOL_SignoffDate
					   ,@Is_Emp_Manager
					   ,@FK_SettingId
					   ,@User_Id
					   ,GETDATE())
		end
	else if @Tran_type = 'U'
		begin
			if @IndicativeExample = ''
				begin
					set @IndicativeExample = null
				end
			if @DepartmentActionPlan = ''
				begin
					set @DepartmentActionPlan = null
				end
			if @FK_Rating_Emp = 0
				begin
					set @FK_Rating_Emp = null
				end
			if @FK_Rating_Sup = 0
				begin
					set @FK_Rating_Sup = null
				end
			UPDATE T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
				   SET IndicativeExample = @IndicativeExample
					  ,DepartmentActionPlan = @DepartmentActionPlan
					  ,FK_Rating_Emp = @FK_Rating_Emp
					  ,FK_Rating_Sup = @FK_Rating_Sup
					  ,ReviewSOL_Signoff = @ReviewSOL_Signoff
					  ,ReviewSOL_SignoffDate = @ReviewSOL_SignoffDate
					  ,FK_EmployeeId = @FK_EmployeeId
					  ,SOLAssessmentDtl_ModifyBy = @User_Id
					  ,SOLAssessmentDtl_ModifyDate = GETDATE()
				 WHERE SOLAssessmentDtl_Id = @SOLAssessmentDtl_Id
 
			--if @DepartmentActionPlan = '' and @FK_Rating_Sup = 0
			--	begin
			--		UPDATE T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
			--		   SET IndicativeExample = @IndicativeExample
			--			  ,FK_Rating_Emp = @FK_Rating_Emp
			--			  ,SOLAssessmentDtl_Year = @SOLAssessmentDtl_Year
			--			  ,SOLAssessmentDtl_ModifyBy = @User_Id
			--			  ,SOLAssessmentDtl_ModifyDate = GETDATE()
			--		 WHERE SOLAssessmentDtl_Id = @SOLAssessmentDtl_Id AND SOLAssessmentDtl_CmpId = @SOLAssessmentDtl_CmpId
			--	end
			--else if  @DepartmentActionPlan <> '' and @FK_Rating_Sup <> 0
			--	begin
			--		if @IndicativeExample = ''
			--			begin
			--				UPDATE T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
			--				   SET DepartmentActionPlan = @DepartmentActionPlan
			--					  ,FK_Rating_Sup = @FK_Rating_Sup
			--					  ,SOLAssessmentDtl_ModifyBy = @User_Id
			--					  ,SOLAssessmentDtl_ModifyDate = GETDATE()
			--				 WHERE SOLAssessmentDtl_Id = @SOLAssessmentDtl_Id AND SOLAssessmentDtl_CmpId = @SOLAssessmentDtl_CmpId
			--			end
			--		else
			--			begin
			--				UPDATE T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
			--				   SET IndicativeExample = @IndicativeExample
			--					  ,DepartmentActionPlan = @DepartmentActionPlan
			--					  ,FK_Rating_Sup = @FK_Rating_Sup
			--					  ,SOLAssessmentDtl_ModifyBy = @User_Id
			--					  ,SOLAssessmentDtl_ModifyDate = GETDATE()
			--				 WHERE SOLAssessmentDtl_Id = @SOLAssessmentDtl_Id AND SOLAssessmentDtl_CmpId = @SOLAssessmentDtl_CmpId
			--			end					
			--	end			
		end
	--else if @Tran_type = 'D'
	--	begin
	--		DELETE FROM T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl
	--		WHERE SOLAssessmentDtl_Id = @SOLAssessmentDtl_Id AND SOLAssessmentDtl_CmpId = @SOLAssessmentDtl_CmpId
	--	end
		
END



