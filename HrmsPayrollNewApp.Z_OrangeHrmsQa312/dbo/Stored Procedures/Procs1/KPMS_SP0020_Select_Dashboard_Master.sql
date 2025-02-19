CREATE PROCEDURE [dbo].[KPMS_SP0020_Select_Dashboard_Master]	
(
@Cmp_ID	INT
)
as
BEGIN
	declare @totalgoals int,@allotedGoals int

	select @totalgoals =   Isnull(count(distinct(GS_Id)),0) from KPMS_T0100_Goal_Setting

	SELECT @allotedGoals = Isnull(count(distinct(Goal_Setting_ID)),0) FROM KPMS_T0020_Goal_Allotment_Master_Test GROUP BY Goal_Setting_ID HAVING COUNT(Goal_Setting_ID)>1

	 select @totalgoals as TotalGoal, @allotedGoals as Allotedgoal    
END