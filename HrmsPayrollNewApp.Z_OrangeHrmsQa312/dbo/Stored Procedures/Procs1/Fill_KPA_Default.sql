

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Fill_KPA_Default]
	  @cmp_id	 numeric(18,0)
	 ,@init_id numeric(18,0)
	 ,@emp_id  numeric(18,0)
	 ,@flag   varchar(10)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	if @flag='RM'
		BEGIN
			Select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Achievement as Score,KPA_Critical as Criteria,
			KPA_Final,KPA_Score,null as kpa_target,isnull(KPA_Weightage,1) as KPA_Weightage,
			ISNULL(KPA_AchievementEmp,0) KPA_AchievementEmp,ISNULL(KPA_AchievementRM,KPA_AchievementEmp)KPA_AchievementRM,
			kpa_performace_measure,actual_achievement,kpa_achievement,kpa_type_id,RM_Comments,
			case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
			ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage from T0052_HRMS_KPA WITH (NOLOCK)
			left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId 
			where T0052_HRMS_KPA.InitiateId=@init_id and T0052_HRMS_KPA.Emp_Id=@emp_id
		END
	else if @flag='HOD'
		BEGIN
			Select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Achievement as Score,
			KPA_Critical as Criteria,
			KPA_Final,KPA_Score,null as kpa_target,isnull(KPA_Weightage,1) as KPA_Weightage,
			ISNULL(KPA_AchievementEmp,0) KPA_AchievementEmp,ISNULL(KPA_AchievementRM,KPA_AchievementEmp)KPA_AchievementRM,
			kpa_performace_measure,actual_achievement,kpa_achievement,kpa_type_id,RM_Comments,
			case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
			ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage,
			case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
			when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
			when ISNULL(KPA_Weightage,0) > 0 then ISNULL(KPA_Weightage,0) end as HOD_Weightage,
			case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
			case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
			when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
			when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as HOD_Rating,
			ISNULL(KPA_AchievementHOD,0)KPA_AchievementHOD,
			case when ISNULL(HOD_Comments,'') <>'' then ISNULL(HOD_Comments,'') else ISNULL(RM_Comments,'')end as HOD_Comments
			from T0052_HRMS_KPA WITH (NOLOCK)
			left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId 
			where T0052_HRMS_KPA.InitiateId=@init_id and T0052_HRMS_KPA.Emp_Id=@emp_id
		END
	else if @flag='GH'
		BEGIN
			Select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,
			KPA_Critical as Criteria,
			KPA_Achievement as Score,KPA_Final,KPA_Score,null as kpa_target,
			isnull(KPA_Weightage,1) as KPA_Weightage,ISNULL(KPA_AchievementEmp,0) KPA_AchievementEmp,
			ISNULL(KPA_AchievementRM,0)KPA_AchievementRM,kpa_performace_measure,actual_achievement,kpa_achievement,kpa_type_id,
			RM_Comments,
			case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
			ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage,

			case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
			when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
			when ISNULL(KPA_Weightage,0) > 0 then ISNULL(KPA_Weightage,0) end as HOD_Weightage,

			case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
			when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
			when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as HOD_Rating,
						
			case when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
			when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0) 
			when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementHOD,
		
			case when ISNULL(GH_Weightage,0) > 0 then ISNULL(GH_Weightage,0)
			when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
			when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0)
			when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as GH_Weightage,
			
			case when ISNULL(GH_Rating,0) > 0 then ISNULL(GH_Rating,0)
			when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
			when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0)
			when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as GH_Rating,
		
			case when ISNULL(KPA_AchievementGH,0) > 0 then ISNULL(KPA_AchievementGH,0)
			when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
			when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0)
			when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementGH,
		
			ISNULL(HOD_Comments,'')HOD_Comments,
			case when ISNULL(GH_Comments,'') <>'' then ISNULL(GH_Comments,'') when ISNULL(HOD_Comments,'') <>'' then ISNULL(HOD_Comments,'') else ISNULL(KPA_Critical,'')end as GH_Comments
			from T0052_HRMS_KPA WITH (NOLOCK)
			left join T0050_HRMS_InitiateAppraisal WITH (NOLOCK) on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId 
			where T0052_HRMS_KPA.InitiateId=@init_id and T0052_HRMS_KPA.Emp_Id=@emp_id
		END
		--ELSE
		--	BEGIN 	
		--	print 'mm'		
		--					select null as SApparisal_ID, KPA_ID,KPA_Content as KPA,KPA_Target,isnull(KPA_Weightage,0) as KPA_Weightage
		--					,ISNULL(KPA_Achievement,0) as Score,KPA_Critical as Criteria ,ISNULL(KPA_AchievementEmp,0) KPA_AchievementEmp,
		--					RM_Comments,KM.KPA_Type_Id,KM.KPA_Type,Actual_Achievement,
		--					ISNULL(RM_Weightage,KPA_Weightage)as RM_Weightage,							
		--					case when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
		--					when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0) 
		--					when ISNULL(KPA_Weightage,0) > 0 then ISNULL(KPA_Weightage,0) end as HOD_Weightage,
							
		--					case when ISNULL(GH_Weightage,0) > 0 then ISNULL(GH_Weightage,0)
		--					when ISNULL(HOD_Weightage,0) > 0 then ISNULL(HOD_Weightage,0)
		--					when ISNULL(RM_Weightage,0) > 0 then ISNULL(RM_Weightage,0)
		--					when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as GH_Weightage,
							
		--					case when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) else ISNULL(KPA_Achievement,0) end as RM_Rating,
		--					case when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
		--					when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0) 
		--					when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as HOD_Rating,
							
		--					case when ISNULL(GH_Rating,0) > 0 then ISNULL(GH_Rating,0)
		--					when ISNULL(HOD_Rating,0) > 0 then ISNULL(HOD_Rating,0)
		--					when ISNULL(RM_Rating,0) > 0 then ISNULL(RM_Rating,0)
		--					when ISNULL(KPA_Achievement,0) > 0 then ISNULL(KPA_Achievement,0) end as GH_Rating,
							
		--					ISNULL(KPA_AchievementRM,KPA_AchievementEmp)as KPA_AchievementRM,
		--					case when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
		--					when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0) 
		--					when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementHOD,
							
		--					case when ISNULL(KPA_AchievementGH,0) > 0 then ISNULL(KPA_AchievementGH,0)
		--					when ISNULL(KPA_AchievementHOD,0) > 0 then ISNULL(KPA_AchievementHOD,0)
		--					when ISNULL(KPA_AchievementRM,0) > 0 then ISNULL(KPA_AchievementRM,0)
		--					when ISNULL(KPA_AchievementEmp,0) > 0 then ISNULL(KPA_AchievementEmp,0) end as KPA_AchievementGH,
		--					HOD_Comments,GH_Comments,KPA_Performace_Measure
		--				from T0052_HRMS_KPA 
		--					left join T0050_HRMS_InitiateAppraisal on T0050_HRMS_InitiateAppraisal.InitiateId=T0052_HRMS_KPA.InitiateId  
		--					left join T0040_HRMS_KPAType_Master KM on T0052_HRMS_KPA.kpa_Type_ID=KM.KPA_Type_Id
		--					where T0052_HRMS_KPA.Emp_Id=@emp_id
		--				and T0052_HRMS_KPA.InitiateId = @init_id
		--			END				
			

	
END
