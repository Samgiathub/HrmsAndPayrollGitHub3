


-- =============================================
-- Author:		<Mihir Trivedi>
-- ALTER date: <01/06/2012>
-- Description:	<will show gatable compoff>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Compoff_Duration]
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@For_Date DateTime,
	@Sanctioned_Hours Varchar(10)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    Declare @Branch_ID as Numeric
	Declare @Gen_ID as Numeric
	Declare @sanctione_hrs Numeric(18,2)
	Declare @Fromhrs Numeric(18,2)
	Declare @Tohrs Numeric(18,2)
	Declare @Days Numeric(18,2)
	Declare @Comp_Days Numeric(18,2)
	Declare @Apply_Hourly as Numeric(18,2) 
	Declare @slab_type as varchar(1) 
	Declare @weekoff_date as varchar(max)
	Declare @Holiday_date as varchar(max)
	Declare @Sanctioned_Hours_temp as numeric(18,2) 
	
	Set @Apply_Hourly = 0
	Set @Sanctioned_Hours_temp = 1
	Set @slab_type  = 'C'	
	select @Apply_Hourly = Apply_Hourly from T0040_LEAVE_MASTER WITH (NOLOCK)
	where Leave_Code = 'COMP' and Cmp_ID = @Cmp_ID
	
	if @Apply_Hourly = 1
	begin
		set @Sanctioned_Hours_temp = cast(dbo.f_return_Sec(@sanctioned_hours)/3600 as numeric(18,2))
		set @Sanctioned_Hours_temp = FLOOR(@Sanctioned_Hours_temp)+ case when ROUND(@Sanctioned_Hours_temp,0)>FLOOR(@Sanctioned_Hours_temp) then 0.5 else 0 end
	end
	
	--declare @Get_WO_HO as table
	--(
	--	Emp_ID	numeric,
	--	Cmp_ID	numeric,
	--	Branch_ID	numeric,
	--	Weekoff_Date	varchar(max),
	--	Holiday_Date	varchar(max),
	--	Weekoff_Count	numeric,
	--	Holiday_Count	numeric,
	--	Total_Weekoff_Date	varchar(max),
	--	Total_Weekoff_Count	numeric
	--)
	
    
   
	Select @Branch_ID = Branch_ID From T0095_Increment I WITH (NOLOCK) INNER JOIN     
     (select Max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)  
     where Increment_Effective_date <= @For_Date and Cmp_ID = @Cmp_ID group by Emp_ID) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID  
	
	--insert into @Get_WO_HO 
	--EXEC [SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_New]
	--	@cmp_id = @cmp_id,@from_date = @For_Date,@to_date = @For_Date ,@branch_id = @branch_id,@Cat_ID = 0,@grd_id = 0,@Type_id = 0
	--	,@dept_ID = 0,@desig_ID = 0,@emp_id = @Emp_ID ,@constraint = '',@Report_For = 'WHO'

	----select * from @Get_WO_HO
	--select @weekoff_date = Weekoff_Date,@Holiday_date = Holiday_Date  from @Get_WO_HO
	
	
	
	--if CHARINDEX(replace(convert(nvarchar(11),@for_date,106),' ','-'),@Holiday_date)>0
	--	set @slab_type = 'H'
	--else if CHARINDEX(replace(convert(nvarchar(11),@for_date,106),' ','-'),@weekoff_date)>0
	--	set @slab_type = 'W'
	--else
	--	set @slab_type = 'C'
	Declare @Is_Cancel_Holiday tinyint
   Declare @Is_Cancel_Weekoff tinyint
   Declare @Emp_Week_Detail numeric(18,0)
   Declare @StrHoliday_Date varchar(Max)
   Declare @StrWeekoff_Date varchar(Max)
   Declare @Weekoff_Days   Numeric(12,1) 
   Declare @Holiday_days Numeric(18,2)
   Declare @Cancel_Weekoff   Numeric(12,1) 
   Declare @Cancel_Holiday Numeric(18,2) 
   set @Is_Cancel_Holiday = 0
   set @Is_Cancel_Weekoff = 0
   
		Select @Is_Cancel_Holiday = Is_Cancel_Holiday, @Is_Cancel_Weekoff = Is_Cancel_Weekoff
	From dbo.T0040_GENERAL_SETTING WITH (NOLOCK)
	Where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	and For_Date = (select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@For_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	
	set @StrWeekoff_Date=''
	set @Weekoff_Days=0
	set @Cancel_Weekoff=0
			
	Set @StrHoliday_Date =''
	Set @Holiday_days = 0
	Set @Cancel_Holiday =0
	

		EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id, @Cmp_ID, @For_Date, @For_Date, NULL, NULL,@Is_Cancel_Holiday, @StrHoliday_Date OUTPUT, 0, 0, 0, @Branch_ID, @StrWeekoff_Date  
		EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_Id, @Cmp_ID, @For_Date, @For_Date, NULL, NULL, @Is_Cancel_Weekoff, @StrHoliday_Date, @StrWeekoff_Date OUTPUT, 0, 0

	  if CHARINDEX(CAST(@For_Date as varchar(11)),@StrWeekoff_Date,0) > 0 
			set @slab_type = 'W'
	  else if CHARINDEX(CAST(@For_Date as varchar(11)),@StrHoliday_Date,0) > 0 
			set @slab_type = 'H'	
	  else
			set @slab_type = 'C'
	  
     
	Select Top 1 @Gen_ID  = ISNULL(Gen_ID, 0)
       from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID   
       and For_Date = ( select Max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @For_Date and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
    
     --Set @sanctione_hrs = Cast(REPLACE(@Sanctioned_Hours,':','.') as numeric(18,2))       		
     set @sanctione_hrs = cast(dbo.f_return_sec(@sanctioned_hours)/3600 as numeric(18,2))
          
          
	Declare curapp cursor for
        select From_hours, To_hours, Deduction_Days from T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) where GEN_ID = @Gen_ID and Slab_Type = @slab_type
       Open curapp
       Fetch Next from curapp into @Fromhrs, @Tohrs, @Days
       WHILE @@fetch_status = 0
         BEGIN
          IF(@sanctione_hrs >= @Fromhrs and @sanctione_hrs <= @Tohrs)
            BEGIN
             IF (ISNULL(@Days, 0) <> 0)
				BEGIN					
					Set @Comp_Days = @Days * @Sanctioned_Hours_temp
				END				 
			 ELSE
			   BEGIN
					Raiserror('@@Null Days cannot insert@@',18,2)
					Return -1
			   END          
            END
        Fetch next from curapp into @Fromhrs, @Tohrs, @Days   
		 END 
     Close curapp
     Deallocate curapp
     
 set @Comp_Days = FLOOR(@Comp_Days)+ case when ROUND(@Comp_Days,0)>FLOOR(@Comp_Days) then 0.5 else 0 end
 
 Select isnull(@Comp_Days,0) as CompOff_Days
 

 
END
RETURN


