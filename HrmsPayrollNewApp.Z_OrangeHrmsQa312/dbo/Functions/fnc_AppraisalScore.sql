CREATE function [dbo].[fnc_AppraisalScore](@GSG_FrequecyId int,@la_LevelAssignId int,@la_AllotmentId int,@Emp_ID int)                          
returns varchar(max)                          
as                          
begin                       
         
  declare @total varchar(max)=''        
	
			select @total = @total + Actual_Target from KPMS_T0110_TargetAchivement where emp_id = @Emp_ID and Freq_id = @GSG_FrequecyId and levelAssignid = @la_LevelAssignId;  
	
			Declare @FRom int
			select @FRom = min(la_LevelValue) from tbl_LevelAssignValues where la_LvlGrpId =1 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId

			Declare @To int
			select @To = Max(la_LevelValue) from tbl_LevelAssignValues where la_LvlGrpId = 1 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId

			declare @mid int
			select @mid = la_LevelValue from tbl_LevelAssignValues where la_LvlGrpId = 1 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId and (la_LevelValue>@FRom) and (la_LevelValue<@to)

			declare @level varchar(50)='';

			if(@total<=@FRom)
			Begin
					select @level = 'N/A'
			End
			else if(@total>=@FRom and @total<=@mid)
			Begin
				select @level = 'Level1';
			End
			if(@total>=@mid and @total<=@To)
			Begin
				select @level = 'Level2';
			End
			if(@total>=@To)
			Begin
				select @level = 'Level3'
			End
			
		declare @score int
		
			Declare @FRom2 int
			select @FRom2 = min(la_LevelValue) from tbl_LevelAssignValues where la_LvlGrpId =2 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId

			Declare @To2 int
			select @To2 = Max(la_LevelValue) from tbl_LevelAssignValues where la_LvlGrpId = 2 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId

			declare @mid2 int
			select @mid2 = la_LevelValue from tbl_LevelAssignValues where la_LvlGrpId = 2 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId and (la_LevelValue>@FRom2) and (la_LevelValue<@To2)

		
		if(@level = 'Level1')
		begin
			select @score = @FRom2;
		end
		else if(@level = 'Level2')
		Begin
			select @score = @mid2;
		end
		else if(@level = 'Level3')
		begin
			select @score = @To2;
		end
			else
		begin
			select @score = 0;	
		end

		   return @score         
END


