



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Check_Continues_leave_Days]
	
	@CMP_ID AS numeric,
	@Emp_Id AS numeric,
	@Leave_id numeric,
	@From_Date datetime,
	@Period numeric(5,1),
	@Type nvarchar(1) = 'E'
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @isContinue tinyint
	declare @last_date datetime
	declare @total_leave numeric(18,2)
	DECLARE @Weekoff_as_leave tinyint
	DECLARE @Holiday_as_leave tinyint
	declare @new_Last_date datetime
	declare @leave_taken numeric(18,2)
	declare @Cancel_WO_HO_on_Leave_Days numeric(18,2)
	declare @max_attempt numeric(18,0)
	declare @branch_id numeric(18,0)
	
	DECLARE @StrWeekoff_Date varchar(Max)
	DECLARE @Weekoff_Days   Numeric(12,1)    
	DECLARE @Cancel_Weekoff   Numeric(12,1)  
	DECLARE @StrHoliday_Date   varchar(Max) 
	DECLARE @Holiday_days   Numeric(12,1)  
	DECLARE @Cancel_Holiday  Numeric(12,1)  
	
	set @branch_id = 0
	set @max_attempt = 1
	set @Cancel_WO_HO_on_Leave_Days = 0
	set @total_leave = @Period
	set @isContinue = 1
	set @last_date = 	DATEADD(dd,-1,@from_date)
	
		
			  select @Branch_ID = Branch_ID				
				From T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)     --Changed by Hardik 10/09/2014 for Same Date Increment
				 where Increment_Effective_date <= @From_Date
				 and Cmp_ID = @Cmp_ID    
				 group by emp_ID) Qry on    
				 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
			  Where I.Emp_ID = @Emp_ID  
			  
			  
	select @Weekoff_as_leave = weekoff_as_leave, @Holiday_as_leave = Holiday_as_leave , @Cancel_WO_HO_on_Leave_Days = isnull(No_Days_To_Cancel_WOHO,0) from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_id
	
	
	if @Weekoff_as_leave = 1 and @Holiday_as_leave = 1 and @Cancel_WO_HO_on_Leave_Days > 0
		begin
			select @Cancel_WO_HO_on_Leave_Days = isnull(max(No_Days_To_Cancel_WOHO),@Cancel_WO_HO_on_Leave_Days) from T0040_LEAVE_MASTER WITH (NOLOCK) where Weekoff_as_leave = 1 and Holiday_as_leave = 1 and No_Days_To_Cancel_WOHO >= @Cancel_WO_HO_on_Leave_Days and Leave_ID <> @Leave_id and Cmp_ID = @CMP_ID
		end
	
	
	while(@isContinue = 1)
		begin
				
				set @StrWeekoff_Date = ''
				Set @Weekoff_Days =0
				Set @Cancel_Weekoff = 0		
				set @StrHoliday_Date = '' 
				set @Holiday_days   = 0
				set @Cancel_Holiday  = 0											
				set @leave_taken = 0
				
				
				
				-- check if previous day is not weekoff
				Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@last_date,@last_date,null,null,@Weekoff_as_leave,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output   
				
				if @Weekoff_Days = 1
					begin
						set @last_date = DATEADD(dd,-1,@last_date)
						
					end
				
				-- check if previous more than 2day weekof
				while @Weekoff_Days <> 0
					begin	
						set @Weekoff_Days = 0
						Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@last_date,@last_date,null,null,@Weekoff_as_leave,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output   		
						
						if @Weekoff_Days = 1
							begin
								set @last_date = DATEADD(dd,-1,@last_date)
								--set @Weekoff_Days = 0
							end
					end
				
				
				
				-- check if previous day is not Holiday
				Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@last_date,@last_date,null,null,@Holiday_as_leave,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_Id,@StrWeekoff_Date
						
				if @Holiday_days = 1
					begin
						set @last_date = DATEADD(dd,-1,@last_date)
						
					end
								
				while @Holiday_days <> 0
					begin	
						set @Holiday_days = 0
						Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@last_date,@last_date,null,null,@Holiday_as_leave,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_Id,@StrWeekoff_Date
						if @Holiday_days = 1
							begin
								set @last_date = DATEADD(dd,-1,@last_date)
								--set @Holiday_days = 0
							end
					end
					
					
					
				select @leave_taken = isnull(lad.Leave_Period,0) , @new_Last_date = lad.From_Date from T0120_LEAVE_APPROVAL la WITH (NOLOCK) inner join
					T0130_LEAVE_APPROVAL_DETAIL lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
					where Emp_ID = @Emp_Id and (From_Date <= @last_date and To_Date >= @last_date) and la.Approval_Status = 'A' and lad.Leave_ID in (select Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Weekoff_as_leave = 1 and Holiday_as_leave = 1 and Cmp_ID = @CMP_ID)
				
				
				
				if @leave_taken = 0
					begin 
						set @isContinue = 0
					end
				else
					begin	
						set @total_leave = @total_leave + @leave_taken
						set @last_date = DATEADD(dd,-1,@new_Last_date)
					end
					
				if @max_attempt >= 30
					begin
						set @isContinue = 0
					end
					
				set @max_attempt = @max_attempt + 1
				
				
				
		end
		
		--select @Weekoff_as_leave = weekoff_as_leave, @Holiday_as_leave = Holiday_as_leave , @Cancel_WO_HO_on_Leave_Days = isnull(No_Days_To_Cancel_WOHO,0) from T0040_LEAVE_MASTER where Leave_ID = @Leave_id
	 
	    if @total_leave = @Period 
			begin
				select 1 [Allow_for_leave]
			end
		else if @Weekoff_as_leave = 1 and @Holiday_as_leave = 1
			begin
				if @Cancel_WO_HO_on_Leave_Days > 0
					begin 
						if @total_leave >=  @Cancel_WO_HO_on_Leave_Days
							begin
								select 0 [Allow_for_leave]
							end
						else
							begin
								select 1 [Allow_for_leave]
							end
						
					end
				else
					begin	
						select 1 [Allow_for_leave]
					end
				
			end
		else
			begin	
				select 1 [Allow_for_leave]
			end
	
RETURN




