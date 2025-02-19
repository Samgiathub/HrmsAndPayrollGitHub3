


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Update_Appraisal_Details]
	@init_id		numeric(18,0) output  
   ,@cmp_id			numeric(18,0)   
   ,@emp_id			numeric(18,0)
   ,@flag			varchar(15)      
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	declare @SendToHOD as int
	declare @GH_Id as int
	declare @SendToRM as int
	declare @KPA_ID as numeric(18,0)
	declare @ESA_ID as numeric(18,0)	
	declare @kpa_weightage as numeric(18,2)	
	declare @kpa_rating as numeric(18,2)
	declare @kpa_score as numeric(18,2)
	declare @kpa_comments as varchar(max)
	
	declare @sa_weightage as numeric(18,2)	
	declare @sa_rating as numeric(18,2)
	declare @sa_score as numeric(18,2)
	declare @sa_comments as varchar(max)
	
	select @SendToHOD=isnull(SendToHOD,0),@GH_Id=isnull(GH_Id,0),@SendToRM=ISNULL(Rm_Required,0)
	from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id
	
	SELECT @SendToHOD,@SendToRM,@GH_Id,@emp_id,@init_id
	if @flag='GH'
		BEGIN	
			DECLARE KPA_details CURSOR FOR						
						select case when @SendToHOD =1 then isnull(HOD_Weightage,0) else isnull(RM_Weightage,0) end,
						case when @SendToHOD =1 then isnull(HOD_Rating,0) else isnull(RM_Rating,0) end,
						case when @SendToHOD =1 then isnull(KPA_AchievementHOD,0) else isnull(KPA_AchievementRM,0) end,
						case when @SendToHOD =1 then HOD_Comments else RM_Comments end,KPA_ID
						from T0052_HRMS_KPA WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id			
			OPEN KPA_details
				fetch next from KPA_details into @kpa_weightage,@kpa_rating,@kpa_score,@kpa_comments,@KPA_ID
					while @@fetch_status = 0
						Begin
						if not exists(SELECT 1 from T0052_HRMS_KPA WITH (NOLOCK) where cmp_id=@cmp_id and (ISNULL(GH_Weightage,0) > 0) and emp_id =@emp_id and InitiateId=@init_id and KPA_ID=@KPA_ID)
							BEGIN
								update T0052_HRMS_KPA
								set GH_Weightage=@kpa_weightage,
								GH_Rating=@kpa_rating,
								KPA_AchievementGH=@kpa_score,
								GH_Comments=@kpa_comments
								where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id and KPA_ID=@KPA_ID
							END
						--end
						fetch next from KPA_details into @kpa_weightage,@kpa_rating,@kpa_score,@kpa_comments,@KPA_ID
					End
			close KPA_details	
			deallocate KPA_details
			
			DECLARE SA_details CURSOR FOR						
						select case when @SendToHOD =1 then isnull(HOD_Weightage,0) else isnull(RM_Weightage,0) end,
						case when @SendToHOD =1 then isnull(HOD_Rating,0) else isnull(RM_Rating,0) end,
						case when @SendToHOD =1 then isnull(Final_HOD_Score,0) else isnull(Final_RM_Score,0) end,
						case when @SendToHOD =1 then HOD_Comments else RM_Comments end,ESA_ID
						from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id			
			OPEN SA_details
				fetch next from SA_details into @sa_weightage,@sa_rating,@sa_score,@sa_comments,@ESA_ID
					while @@fetch_status = 0
						Begin
							if not exists(SELECT 1 from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and (ISNULL(GH_Weightage,0) > 0) and emp_id =@emp_id and InitiateId=@init_id and ESA_ID=@ESA_ID)
								BEGIN
									update T0052_HRMS_EmpSelfAppraisal
									set GH_Weightage=@sa_weightage,
									GH_Rating=@sa_rating,
									Final_GH_Score=@sa_score,
									GH_Comments=@sa_comments
									where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id and ESA_ID=@ESA_ID		
								END
						--end
						fetch next from SA_details into @sa_weightage,@sa_rating,@sa_score,@sa_comments,@ESA_ID
					End
			close SA_details	
			deallocate SA_details
		END
	ELSE if @flag='HOD'
		BEGIN	
			DECLARE KPA_details CURSOR FOR						
						select case when @SendToRM =1 then isnull(RM_Weightage,0) else isnull(KPA_Weightage,0) end,
						case when @SendToRM =1 then isnull(RM_Rating,0) else isnull(KPA_Achievement,0) end,
						case when @SendToRM =1 then isnull(KPA_AchievementRM,0) else isnull(KPA_AchievementEmp,0) end,
						case when @SendToRM =1 then RM_Comments else '' end,KPA_ID
						from T0052_HRMS_KPA WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id			
			OPEN KPA_details
				fetch next from KPA_details into @kpa_weightage,@kpa_rating,@kpa_score,@kpa_comments,@KPA_ID
					while @@fetch_status = 0
						Begin
							if not exists(SELECT 1 from T0052_HRMS_KPA WITH (NOLOCK) where cmp_id=@cmp_id and (ISNULL(HOD_Weightage,0) > 0) and emp_id =@emp_id and InitiateId=@init_id and KPA_ID=@KPA_ID)
								BEGIN
									update T0052_HRMS_KPA
									set HOD_Weightage=@kpa_weightage,
									HOD_Rating=@kpa_rating,
									KPA_AchievementHOD=@kpa_score,
									HOD_Comments=@kpa_comments
									where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id and KPA_ID=@KPA_ID
								END
						--end
						fetch next from KPA_details into @kpa_weightage,@kpa_rating,@kpa_score,@kpa_comments,@KPA_ID
					End
			close KPA_details	
			deallocate KPA_details
			
			DECLARE SA_details CURSOR FOR						
						select case when @SendToRM =1 then isnull(RM_Weightage,0) else isnull(Emp_Weightage,0) end,
						case when @SendToRM =1 then isnull(RM_Rating,0) else isnull(Emp_Rating,0) end,
						case when @SendToRM =1 then isnull(Final_RM_Score,0) else isnull(Final_Emp_Score,0) end,
						case when @SendToRM =1 then RM_Comments else '' end,ESA_ID
						from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id			
			OPEN SA_details
				fetch next from SA_details into @sa_weightage,@sa_rating,@sa_score,@sa_comments,@ESA_ID
					while @@fetch_status = 0
						Begin
							if not exists(SELECT 1 from T0052_HRMS_EmpSelfAppraisal WITH (NOLOCK) where cmp_id=@cmp_id and (ISNULL(HOD_Weightage,0) > 0) and emp_id =@emp_id and InitiateId=@init_id and ESA_ID=@ESA_ID)
								BEGIN
									update T0052_HRMS_EmpSelfAppraisal
									set HOD_Weightage=@sa_weightage,
									HOD_Rating=@sa_rating,
									Final_HOD_Score=@sa_score,
									HOD_Comments=@sa_comments
									where cmp_id=@cmp_id and emp_id =@emp_id and InitiateId=@init_id and ESA_ID=@ESA_ID		
								END
						--end
						fetch next from SA_details into @sa_weightage,@sa_rating,@sa_score,@sa_comments,@ESA_ID
					End
			close SA_details	
			deallocate SA_details
		END
END

