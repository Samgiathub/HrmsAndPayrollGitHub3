
CREATE FUNCTION [dbo].[Fuc_GetAchievement] 
(
    @month int
)
returns varchar(max)                            
as  
BEGIN
		Declare @Achievement  INT 
		declare @month_num int 
		
		select @Achievement = Achievement from KPMS_T0110_TargetAchivement  WHERE goalid = 1 AND goalAlt_id = 2 and Month_Num = @month

		select @month_num = Month_Num from KPMS_T0110_TargetAchivement where Month_Num = @month and sectionid =1 and goalid =1 and subgoalid =1
		SET @Achievement =
			CASE 
				WHEN @month_num!=0 THEN
				@Achievement 
				ELSE  0
			END			
			Return @Achievement
END

