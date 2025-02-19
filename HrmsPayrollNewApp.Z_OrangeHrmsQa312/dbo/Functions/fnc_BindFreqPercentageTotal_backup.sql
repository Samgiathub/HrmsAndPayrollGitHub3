create function [dbo].[fnc_BindFreqPercentageTotal_backup](@Emp_ID int,@TargetAchiveid int,@GSG_Goal_Id int,@lvl_ass_id int)                              
returns varchar(max)    

as                              
begin                           

declare @depe_Goal_Id int
select @depe_Goal_Id = GSG_Goal_Id from KPMS_T0110_Goal_Setting_Goal where  GSG_Goal_Id = @GSG_Goal_Id
	
	declare @total varchar(max)= '' 
	declare @per varchar(max)= ''
	
	declare @achi varchar(max)=''
	declare @targetvalue varchar(max)=''

	DECLARE @final_result varchar(max)=''

if(@depe_Goal_Id > 0)
	begin
		declare @goalid int
		select @goalid  = GSG_Depend_Goal_Id from KPMS_T0110_Goal_Setting_Goal where GSG_Goal_Id = @GSG_Goal_Id and GSG_GoalSetting_Id =  1

		declare @goalid_type int
		select @goalid_type =  GSG_Depend_Type_Id from KPMS_T0110_Goal_Setting_Goal where GSG_Goal_Id = @GSG_Goal_Id and GSG_GoalSetting_Id =  1

		if(@goalid_type = 1)
			begin
				select @achi = TargetValues from KPMS_T0100_Level_Assign where GoalId = @goalid and GoalSettingId =  1 and level_assign_Id = @lvl_ass_id
			end
			else
			begin
				select @achi = Achievement from KPMS_T0110_TargetAchivement where GoalID = @goalid and emp_id = @Emp_ID and TargetAchiveid = @TargetAchiveid  
			end
	end
ELSE
BEGIN 

	declare @achi_val varchar(max)=''                 
	select @achi_val = Achievement from KPMS_T0110_TargetAchivement where emp_id= @Emp_ID and TargetAchiveid = @TargetAchiveid   

	select @achi = Achievement from KPMS_T0110_TargetAchivement where WeightageType = 2 and emp_id= @Emp_ID  and TargetAchiveid = @TargetAchiveid         
	select @targetvalue = targetvalue from KPMS_T0110_TargetAchivement where WeightageType = 2 and emp_id= @Emp_ID  and TargetAchiveid = @TargetAchiveid        
	
	if(@achi = @achi_val)
	begin
		select @total = (@achi*100/@targetvalue) 
		select @final_result = @total --+ '%'
	end
	else
	begin
		select @final_result = @achi_val
	end
END
	return @final_result

END  
  
