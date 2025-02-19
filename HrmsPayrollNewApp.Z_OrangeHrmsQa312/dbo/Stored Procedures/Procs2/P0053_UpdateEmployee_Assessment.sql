

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	rollback data in self appraisal form and comments in initiate table
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0053_UpdateEmployee_Assessment]
		@Cmp_ID			as numeric(18,0),
		@InitiateId		as numeric(18,0),
		@Emp_Id			as numeric(18,0),
		@Section		as integer		
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @KPA_Default as int = 0
DECLARE @final_score as numeric(18,0)

	SELECT @KPA_Default=isnull(A.KPA_Default,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@InitiateId
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id
	--print @Self_Assessment_With_Answer
if @Section = 1
	Begin
	if not exists (select 1 from  T0052_HRMS_PerformanceAnswer WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID=@Cmp_ID)
		begin
			delete from  T0052_HRMS_KPA where InitiateId=@InitiateId and Cmp_ID=@Cmp_ID
		if not exists (select 1 from  T0052_HRMS_KPA WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID=@Cmp_ID)
			begin
				if not exists (select 1 from  T0052_HRMS_AttributeFeedback WITH (NOLOCK) where Initiation_Id=@InitiateId and Cmp_ID = @Cmp_ID)
					begin
						if not exists (select 1 from  T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID)
							begin
								if not exists (select 1 from  T0052_HRMS_AppTrainingDetail WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID)
									begin
										if not exists (select 1 from  T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID)
											begin
												DELETE FROM T0052_Emp_SelfAppraisal where InitiateId = @InitiateId and  Cmp_ID=@Cmp_ID	
												DELETE FROM T0052_HRMS_EmpSelfAppraisal where InitiateId = @InitiateId and  Cmp_ID=@Cmp_ID	
												DELETE FROM T0050_HRMS_EmpOA_Feedback where Initiation_Id = @InitiateId and Cmp_ID=@Cmp_ID
												UPDATE		T0050_HRMS_InitiateAppraisal 
												SET			SA_AppComments  =   null,
															SA_EmpComments  =	null,
															SA_Status		=   4,
															SA_SubmissionDate = null,
															SA_ApprovedDate	  = null,
															Overall_Score   = 0,
															Overall_Score_RM   = 0

												WHERE	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID
											End
									End
							End
					End
				Else
					begin
							INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
							VALUES (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
							RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
								SET @InitiateId=0	
							RETURN
					End
			End
		Else
			Begin			
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
				RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
					set @InitiateId=0	
				return
			End
		End
	Else
		Begin
			Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
			Values (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
			RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
			set @InitiateId=0			
			return
		End
	End	
else if @Section = 2 --delete RM record
	Begin
	print 'RM_delete'
		--IF NOT EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE  isnull(Overall_Status,0) in(3,4,5,6,7,10,11)  AND InitiateId= @InitiateId) -- old Code Commented by Deepali 
		IF NOT EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE  isnull(Overall_Status,0) in(3,4,5,7,10,11)  AND InitiateId= @InitiateId) --Added by Deepali - 03092022
		
			BEGIN
			print 'RM start delete'
				--delete from T0052_HRMS_EmpSelfAppraisal where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
				delete from T0052_HRMS_PerformanceAnswer where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
				delete from T0052_HRMS_AttributeFeedback where Initiation_Id=@InitiateId and Cmp_ID = @Cmp_ID
				delete from T0052_HRMS_AppTraining where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
				delete from T0052_HRMS_AppTrainingDetail where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
				delete from T0052_HRMS_AppTrainDetail where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
				
				Update	T0050_HRMS_InitiateAppraisal 		
				set		KPA_Score		= null,
						KPA_Final		= null,
						PF_Score		= null,
						Inc_YesNo		= null,
						Inc_Reason		= null,
						PF_Final		= null,
						PO_Score		= null,
						PO_Final		= null,
						Overall_Score   = 0,
						Achivement_Id   = null,
						AppraiserComment = null,
						Promo_YesNo     = null,
						Promo_Desig		= null,
						Promo_Wef		= null,
						JR_YesNo		= null,
						JR_From			= null,
						JR_To			= null,
						ReviewerComment = null,
						Appraiser_Date	= null,
						SA_Status       = 0,
						SA_ApprovedBy	= null,
						Per_ApprovedBy  = null,
						Overall_Status = 0,		
						GH_Comment		= null,						
						Overall_Score_RM = 0					
			Where	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID
			
			if @KPA_Default =0
				BEGIN		
					Update	T0050_HRMS_InitiateAppraisal 		
					set	SA_Status = 0
					Where InitiateId = @InitiateId and Cmp_ID = @Cmp_ID
						
					update T0050_HRMS_EmpOA_Feedback set RM_Comments='' 
					where Initiation_Id=@InitiateId  and Cmp_ID = @Cmp_ID
					
					update T0052_HRMS_KPA
					set RM_Weightage = null,
						RM_Rating = null,
						KPA_AchievementRM = null,
						RM_Comments = NULL 
					Where  InitiateId=@InitiateId and Cmp_ID = @Cmp_ID					
					
					update T0052_HRMS_EmpSelfAppraisal
					set RM_Weightage = null,
						RM_Rating = null,
						Final_RM_Score = 0,
						RM_Comments = NULL 
					Where  InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
				END
			ELSE
				BEGIN
					delete from T0050_HRMS_EmpOA_Feedback where Initiation_Id= @InitiateId and Cmp_ID = @Cmp_ID
					delete from T0052_HRMS_KPA where InitiateId=@InitiateId  and Cmp_ID = @Cmp_ID						
				END
					
				delete from T0110_HRMS_Appraisal_PlanDetails Where	InitiateId = @InitiateId and Cmp_ID = @Cmp_ID and Approval_Level='RM'
			END
		ELSE			
		
		delete from T0110_HRMS_Appraisal_OtherDetails Where	InitiateId = @InitiateId and Cmp_ID = @Cmp_ID and Approval_Level='RM'
		IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE  isnull(Overall_Status,0) in(3,4,5,7,10,11)  AND InitiateId= @InitiateId) --Added by Deepali - 03092022
	
			BEGIN
				INSERT INTO dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				VALUES (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
				RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
					SET @InitiateId=0	
				RETURN
			END
	End
else if @Section = 3 --delete for Group Head records
	Begin
		--delete from T0052_HRMS_PerformanceAnswer where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_KPA where InitiateId=@InitiateId  and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AttributeFeedback where Initiation_Id=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AppTraining where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AppTrainingDetail where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AppTrainDetail where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		if exists(select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where InitiateId =	@InitiateId and SendToHOD =1) 
			BEGIN --added on 9 Feb 2016
				Update		T0050_HRMS_InitiateAppraisal 			
				set			Overall_Status = 6,		
							GH_Comment		= null,					
							Per_ApprovedBy  = null,
							Overall_Score_GH = 0
				Where	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID
			END
		Else
			BEGIN
				Update		T0050_HRMS_InitiateAppraisal 			
				set			Overall_Status = 0,		
							GH_Comment		= null,					
							Per_ApprovedBy  = null,
							Overall_Score_GH = 0
				Where	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID
			End
		
		select @final_score= case when ISNULL(Overall_Score_HOD,0) > 0 then Overall_Score_HOD 
							 when ISNULL(Overall_Score_RM,0) > 0 then Overall_Score_RM else Overall_Score end
		from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
		Where InitiateId= @InitiateId and  Cmp_ID = @Cmp_ID 
		
		Update	T0050_HRMS_InitiateAppraisal 			
		set
			Overall_Score= @final_score
		Where InitiateId= @InitiateId and  Cmp_ID= @Cmp_ID 
		
		update T0050_HRMS_EmpOA_Feedback set GH_Comments='' 
		where Initiation_Id=@InitiateId  and Cmp_ID = @Cmp_ID
						
		delete from T0110_HRMS_Appraisal_OtherDetails Where	InitiateId = @InitiateId and Cmp_ID = @Cmp_ID and Approval_Level='GH'
		delete from T0110_HRMS_Appraisal_PlanDetails Where	InitiateId = @InitiateId and Cmp_ID = @Cmp_ID and Approval_Level='GH'
		
		UPDATE T0052_HRMS_KPA
		SET GH_Weightage = null,
			GH_Rating = null,
			KPA_AchievementGH = null,
			GH_Comments = NULL 
		WHERE  InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		
		UPDATE T0052_HRMS_EmpSelfAppraisal 
		set GH_Weightage = null,
			GH_Rating= null,
			Final_GH_Score = 0,
			GH_Comments = null
		where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
	End
else if @Section = 4 --delete final stage record
	Begin
		--delete from T0052_HRMS_PerformanceAnswer where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_KPA where InitiateId=@InitiateId  and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AttributeFeedback where Initiation_Id=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AppTraining where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AppTrainingDetail where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		--delete from T0052_HRMS_AppTrainDetail where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		Update		T0050_HRMS_InitiateAppraisal 			
		set			Overall_Status = 1,		
					ReviewerComment = null
		Where	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID		
		
	End
else if @Section = 5 --delete for HOD records
		BEGIN
			Update		T0050_HRMS_InitiateAppraisal 			
			set			Overall_Status = 0,		
						GH_Comment		= null,					
						Per_ApprovedBy  = null,
						Overall_Score_HOD = 0,
						Hod_Comment = null
			Where	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID
			
			select @final_score= case when ISNULL(Overall_Score_RM,0) > 0 then Overall_Score_RM else Overall_Score end
			from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)
			Where InitiateId= @InitiateId and  Cmp_ID = @Cmp_ID 
			
			Update	T0050_HRMS_InitiateAppraisal 			
			set
				Overall_Score= @final_score
			Where InitiateId= @InitiateId and  Cmp_ID= @Cmp_ID 
			
			delete from T0110_HRMS_Appraisal_OtherDetails Where	InitiateId = @InitiateId and Cmp_ID = @Cmp_ID and Approval_Level='HOD'
			delete from T0110_HRMS_Appraisal_PlanDetails Where	InitiateId = @InitiateId and Cmp_ID = @Cmp_ID and Approval_Level='HOD'
		
			update T0050_HRMS_EmpOA_Feedback set HOD_Comments='' 
			where Initiation_Id=@InitiateId  and Cmp_ID = @Cmp_ID
		
			UPDATE T0052_HRMS_KPA
			SET HOD_Weightage = null,
				HOD_Rating = null,
				KPA_AchievementHOD = null,
				HOD_Comments = NULL 
			WHERE  InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
			
			UPDATE T0052_HRMS_EmpSelfAppraisal 
			set HOD_Weightage = null,
				HOD_Rating= null,
				Final_HOD_Score = 0,
				HOD_Comments = null
			where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID
		End
if @Section = 6-- delete from emp assessment if status is approved - 08/11/2017
	Begin
	if not exists (select 1 from  T0052_HRMS_PerformanceAnswer WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID=@Cmp_ID)
		begin
			delete from  T0052_HRMS_KPA where InitiateId=@InitiateId and Cmp_ID=@Cmp_ID
		if not exists (select 1 from  T0052_HRMS_KPA WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID=@Cmp_ID)
			begin
				if not exists (select 1 from  T0052_HRMS_AttributeFeedback WITH (NOLOCK) where Initiation_Id=@InitiateId and Cmp_ID = @Cmp_ID)
					begin
						if not exists (select 1 from  T0052_HRMS_AppTraining WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID)
							begin
								if not exists (select 1 from  T0052_HRMS_AppTrainingDetail WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID)
									begin
										if not exists (select 1 from  T0052_HRMS_AppTrainDetail WITH (NOLOCK) where InitiateId=@InitiateId and Cmp_ID = @Cmp_ID)
											begin
												Update		T0050_HRMS_InitiateAppraisal 
												Set			SA_AppComments  =   null,
															SA_EmpComments  =	null,
															SA_Status		=   0,
															SA_SubmissionDate = null,
															SA_ApprovedDate	  = null					
												Where	    InitiateId		=	@InitiateId and  Cmp_ID = @Cmp_ID
												DELETE FROM T0052_HRMS_EmpSelfAppraisal where InitiateId = @InitiateId and  Cmp_ID=@Cmp_ID	
											End
									End
							End
					End
				Else
					begin
							Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
							Values (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
							RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
								set @InitiateId=0	
							return
					End
			End
		Else
			Begin			
				Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
				Values (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
				RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
					set @InitiateId=0	
				return
			End
		End
	Else
		Begin
			Insert Into dbo.T0080_Import_Log(Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type) 
			Values (0,@Cmp_Id,0,'reference exists ',0,'reference exists ',GetDate(),'Appraisal')	
			RAISERROR('@@Record cannot be deleted,reference exists',16,2)	
			set @InitiateId=0			
			return
		End
	End
END


