 
CREATE PROCEDURE [dbo].[KPMS_DASHBOARD_DETAILS_Target/Achievement]   
(
	@Cmp_ID	INT,
	@Emp_ID VARCHAR(MAX)      
)
AS     
  
   BEGIN  
		
		Select SUM(targetvalue) AS TARGETVALUE,sum(Achievement) AS ACHIEEMENT from KPMS_T0110_TargetAchivement 
			where Emp_ID=cast(@Emp_ID as int) and Cmp_ID=@Cmp_ID
End

