




----Alpesh 16-Apr-2012
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0020_INACTIVE_USER_HISTORY]    
   @Cmp_ID		numeric,    
   @Login_ID	numeric
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Emp_ID		numeric(18, 0)
	Declare @History_Id numeric(18, 0)
	Declare @InActive_Days numeric(18, 2)
	--Declare @Absent_Days numeric(18, 2)
	--Declare @Leave_Days numeric(18, 2)
	Declare @Branch_Id	numeric
	
	declare @StrWeekoff_Date nvarchar(max)
	declare @StrHoliday_Date nvarchar(max)
	declare @Weekoff_Days	 numeric(18, 2)
	declare @Holiday_Days	 numeric(18, 2)
	declare @Cancel_Weekoff	 numeric	
	declare @Cancel_Holiday	 numeric	
	declare @From_Date		 datetime
	declare @To_Date		 datetime
	declare @DOJ			 datetime
	declare @tmp_Date		 datetime
	
	Declare curMain cursor for Select e.Emp_ID from T0080_EMP_MASTER e WITH (NOLOCK) inner join T0011_Login l WITH (NOLOCK) on e.Emp_ID=l.Emp_ID
	  where e.Cmp_ID=@Cmp_ID and (Emp_Left='N' or (Emp_Left='Y' and Emp_Left_Date > GETDATE())) and l.Is_Active=1 order by Emp_ID  
	Open curMain
	Fetch Next From curMain into @Emp_ID
	
	While @@FETCH_STATUS = 0
	Begin							
		Select @Branch_Id = Branch_ID from T0095_Increment EI WITH (NOLOCK) where Increment_Id in   --Changed by Hardik 10/09/2014 for Same Date Increment
		(select max(Increment_Id) as Increment_Id from T0095_Increment WITH (NOLOCK) where Increment_Effective_date <= @From_Date  and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id) and Emp_ID = @Emp_Id			
		Select @From_Date = isnull(max(for_date),getdate()) from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID
		
		If convert(varchar(10),@From_Date,120) <> convert(varchar(10),GETDATE(),120) 
			set @From_Date =DATEADD(d,1,@From_Date)
			
		Set @To_Date = GETDATE()
		select @DOJ = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_Id
		set @Holiday_Days = 0
		Select @InActive_Days = setting_value FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID and Setting_Name='InActive User After Days'
		
		Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@DOJ,null,0,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_Id,@StrWeekoff_Date,1
		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@DOJ,null,0,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,0,0,1   
		
		Declare @i int
		set @i = 0
		set @tmp_Date = @To_Date
		
		While @i < @InActive_Days and convert(varchar(10),@tmp_Date,120) >= convert(varchar(10),@From_Date,120)
			begin
				if not (charindex(CONVERT(nvarchar(11),@tmp_Date,109),@StrWeekoff_Date) > 0 OR charindex(CONVERT(nvarchar(11),@tmp_Date,109),@StrHoliday_Date) > 0)
					begin						
						if exists(Select 1 from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and convert(varchar(10),For_Date,120) = convert(varchar(10),@tmp_Date,120) and (Leave_Used=1 or CompOff_Used = 1)) -- Changed By Gadriwala Muslim 02102014
							begin
								return
							end
							
						set @i = @i+1
					end
				----select @tmp_Date,@i
				set @tmp_Date = DATEADD(d,-1,@tmp_Date)
				
			end
		
		----select @StrWeekoff_Date,@StrHoliday_Date			
				
		
		if @i = @InActive_Days
			Begin
				Select @History_Id = Isnull(max(History_Id),0) + 1  From T0020_INACTIVE_USER_HISTORY WITH (NOLOCK)
				
				Insert Into T0020_INACTIVE_USER_HISTORY
				values(@History_Id,@Cmp_ID,@Emp_ID,@Login_ID,'Auto',GETDATE(),'InActive')	
			End
				
		
		Fetch Next From curMain into @Emp_ID
	End
	
	close curMain
	deallocate curMain
	
	
     
 RETURN




