CREATE function [dbo].[fnc_LevelAchi](@GSG_FrequecyId int,@la_LevelAssignId int,@la_AllotmentId int,@Emp_ID int,@Cmp_Id int)                          
returns varchar(max)                          
as                          
begin                       
         
  declare @total varchar(max)=''        
   
	---select * from KPMS_T0110_TargetAchivement Actual_Achievement

			--select la_LevelValue from tbl_LevelAssignValues where la_LvlGrpId = 1 and la_AllotmentId = 1 and la_LevelAssignId =1

			select @total = @total + Actual_Target from KPMS_T0110_TargetAchivement where emp_id = @Emp_ID and Freq_id = @GSG_FrequecyId and levelAssignid = @la_LevelAssignId and Cmp_Id = @Cmp_Id;  
			--select @total    

			Declare @FRom int
			select @FRom = min(la_LevelValue) from tbl_LevelAssignValues where la_LvlGrpId =1 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId and Cmp_Id = @Cmp_Id;

			Declare @To int
			select @To = Max(la_LevelValue) from tbl_LevelAssignValues where la_LvlGrpId = 1 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId  and Cmp_Id = @Cmp_Id;

			declare @mid int
			select @mid = la_LevelValue from tbl_LevelAssignValues where la_LvlGrpId = 1 and la_AllotmentId = @la_AllotmentId and la_LevelAssignId = @la_LevelAssignId and (la_LevelValue>@FRom) and (la_LevelValue<@to)  and Cmp_Id = @Cmp_Id;

			--select @FRom,@To,@mid

			declare @level varchar(50)='';

			if(@total<=@FRom)
			Begin
					select @level = 'N/A'
					--return 'N/A';
			End
			else if(@total>=@FRom and @total<=@mid)
			Begin
				--return 'Level1'
				select @level = 'Level1';
			End
			if(@total>=@mid and @total<=@To)
			Begin
				--return 'Level2'
				select @level = 'Level2';
			End
			if(@total>=@To)
			Begin
				--return 'Level3'
				select @level = 'Level3'
			End
		   return @level         
END


