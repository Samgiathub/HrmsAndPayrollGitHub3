  
CREATE PROCEDURE [dbo].[kpms_Final_ESS_Result]   
(
	@final_result INT,
	@TargetAchiveid INT      --isnull(,'') as
)
AS     
  
   BEGIN  

   --update KPMS_T0110_TargetAchivement set Actual_Achievement = @final_result where TargetAchiveid = @TargetAchiveid -- Discussed with prapti to change the actual_ach column to ach column 03012022
  update KPMS_T0110_TargetAchivement set Achievement = @final_result where TargetAchiveid = @TargetAchiveid

End

select * from KPMS_T0110_TargetAchivement