
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_JOINING_EMP_DELETE]
	@Cmp_Id					numeric(18,0)
	,@Resume_Id				numeric(18,0)output
		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @inter_process1 as numeric(18,0)
		declare @s_empid1 as numeric(18,0)
	
	Begin
			
		if exists (Select *  from T0055_HRMS_Interview_Schedule hs WITH (NOLOCK) inner join T0060_RESUME_FINAL rf WITH (NOLOCK) on hs.Resume_Id=rf.Resume_ID and hs.Cmp_Id=rf.Cmp_ID and rf.Confirm_Emp_id<>0 Where hs.Cmp_Id= @CMP_ID AND hs.Resume_Id = @Resume_Id)
			begin
				RAISERROR ('This details cannot be deleted because it exists in employee master', 16, 2)
				return  
			end
		else
			begin	
				select @inter_process1=Interview_Process_Detail_Id,@s_empid1=S_Emp_Id from T0055_HRMS_Interview_Schedule WITH (NOLOCK) where Resume_Id=@Resume_Id					
				--delete from T0060_Hrms_Interview_Feedback_detail where Emp_id=@s_empid1
				--delete  from T0055_HRMS_Interview_Schedule where Resume_Id=@Resume_Id
				--delete from T0080_IT_OnBoardingDet where IT_OnBoarding_ID=@it_boardid
				--delete from T0040_IT_OnBoarding where Resume_Id=@Resume_Id
				
				--delete from T0055_Interview_Process_Detail where Interview_Process_detail_Id=@inter_process1 	
				--delete from T0090_HRMS_RESUME_IMMIGRATION where Resume_Id=@Resume_Id
				update T0060_RESUME_FINAL set Acceptance=0,Resume_Status=1,Accept_Appointment=0 where Resume_Id=@Resume_Id  --Accept_Appointment added 18052015
				update T0055_Resume_Master set Resume_Status=1 where Resume_Id=@Resume_Id --Mukti 23072015
			end
	end
select @Resume_Id	 
return




