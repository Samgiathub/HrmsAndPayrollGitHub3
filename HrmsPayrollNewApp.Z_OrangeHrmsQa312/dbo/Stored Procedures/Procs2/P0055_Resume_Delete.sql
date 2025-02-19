
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0055_Resume_Delete]
@cmp_id					numeric(18,0)
,@Resume_Id					numeric(18) output
       
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Begin
		if not exists(select resume_id from T0060_RESUME_FINAL WITH (NOLOCK)  where Resume_ID =@Resume_Id and Cmp_ID=@cmp_id)
		begin
			delete from T0055_HRMS_Interview_Schedule where Resume_Id =@Resume_Id
			delete from T0090_HRMS_RESUME_EXPERIENCE where Resume_Id=@Resume_Id 
			delete from T0090_HRMS_RESUME_Skill where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_qualification where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_IMMIGRATION where Resume_Id=@Resume_Id
			delete from T0091_HRMS_RESUME_HEALTH_DETAIL where row_id in (select row_id from T0090_HRMS_RESUME_HEALTH WITH (NOLOCK) where Resume_Id=@Resume_Id)
			delete from T0090_HRMS_RESUME_HEALTH where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_EARN_DEDUCTION where Resume_Id=@Resume_Id
			delete from T0090_HRMS_RESUME_NOMINEE where Resume_ID=@Resume_Id
			delete  from T0055_Resume_Master where Resume_Id=@Resume_Id
			return @Resume_Id 
		end
		else
		begin 
		
		       Raiserror('@@ Resume is Processed.So, its Not Delete.Contact Corporate HR @@',16,2)  
			return -1
		end
		end
	RETURN




