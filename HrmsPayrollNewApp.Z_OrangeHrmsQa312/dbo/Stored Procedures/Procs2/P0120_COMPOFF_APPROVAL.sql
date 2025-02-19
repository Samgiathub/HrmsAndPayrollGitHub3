

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0120_COMPOFF_APPROVAL]  
	@CompOff_Approval_ID Numeric output  
   ,@CompOff_Application_ID Numeric  
   ,@Cmp_ID Numeric  
   ,@Emp_ID Numeric  
   ,@S_Emp_ID Numeric
   ,@Extra_Work_Date DateTime  
   ,@Approval_Date DateTime  
   ,@Extra_Work_Hours Varchar(10)
   ,@Sanctioned_Hours Varchar(10)
   ,@Approval_Status Char(1)  
   ,@Extra_Work_Reason varchar(250)
   ,@Approval_Comments Varchar(250) 
   ,@Contact_No Varchar(30)
   ,@Email_ID Varchar(50)
   ,@Login_ID Numeric  
   ,@System_Date Datetime  
   ,@Tran_type as Varchar(1)  
   ,@User_Id numeric(18,0) = 0 -- Add By Mukti 05072016
   ,@IP_Address varchar(30)= '' -- Add By Mukti 05072016

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  Declare @sanctione_hrs as numeric(18,2)
  Declare @Compoff_min_hours as numeric(18,2)
  Declare @Branch_ID as numeric
  Declare @Gen_ID as numeric
  Declare @Grd_ID as numeric
  Declare @Leave_ID as numeric
  Declare @CompOffdayslimit as numeric
  Declare @Compoffdayslimitdate as DateTime
  Declare @Fromhrs as numeric(18,2)
  Declare @Tohrs as numeric(18,2)
  Declare @Days as numeric(18,2)
  Declare @Com_Days as numeric(18,2)  
  Declare @Is_CompOff as numeric
  Declare @Is_WD as Numeric
  Declare @Is_WOHO as Numeric  
  Declare @Is_HO_CompOff as Numeric
  Declare @Is_W_CompOff as Numeric
  --Declare @StrWeekoff_Date VARCHAR(1000)
  --Declare @StrHoliday_Date VARCHAR(1000)
  
  --Set @StrWeekoff_Date = ''
  --Set @StrHoliday_Date = ''
  
 -- Add By Mukti 05072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
 -- Add By Mukti 05072016(end)	
   set @Com_Days = 0  --Added by Jaina 28-08-2018
	select @Cmp_ID=cmp_id from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID -- Added by rohit on 05122013
    
	If @CompOff_Application_ID = 0  
		Set @CompOff_Application_ID = NULL  
   
	If @S_Emp_ID  = 0
		Set @S_Emp_ID = NULL
    
	Set @Branch_ID = 0
  
    Select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Default_Short_Name = 'COMP' and Cmp_ID = @Cmp_ID
    
    select @Branch_ID = Branch_ID, @Grd_ID = Grd_ID From T0095_Increment I WITH (NOLOCK) inner join     
     (select Max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)  
     where Increment_Effective_date <= @Approval_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date Where I.Emp_ID = @Emp_ID     
     
     --Added by Gadriwala 24/11/2014 - Start
	declare @Holiday_CompOff_Limit as numeric
	declare @Holiday_From_Date as varchar(11)
	Declare @Weekoff_CompOff_Limit as numeric
	declare @Weekoff_From_Date as varchar(11)
	Declare	@Weekday_CompOff_Limit as numeric
	declare @Weekday_From_Date as varchar(11)
	
	Declare	@Weekday_CompOff_Limit_BranchWise as numeric
	declare @Holiday_CompOff_Limit_BranchWise as numeric
	Declare @Weekoff_CompOff_Limit_BranchWise as numeric
	
	-- First Employeewise Limit Setting
	select @Weekday_CompOff_Limit = CompOff_WD_APP_Days ,
		   @Weekoff_CompOff_Limit =CompOff_WO_App_Days, 
		   @Holiday_CompOff_Limit= CompOff_HO_App_Days 
	from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID 
		
		--Second Branchwise Limit Setting 
	If @Weekday_CompOff_Limit = 0 or @Weekoff_CompOff_Limit = 0 or @Holiday_CompOff_Limit = 0
		begin
				select @Weekday_CompOff_Limit_BranchWise = isnull(CompOff_Days_Limit,0),
					   @Holiday_CompOff_Limit_BranchWise = isnull(H_CompOff_Days_Limit,0),
					   @Weekoff_CompOff_Limit_BranchWise = isnull(W_CompOff_Days_Limit,0) 
				from T0040_GENERAL_SETTING WITH (NOLOCK)
				where Branch_ID = @branch_id	
		end
	
	If @Weekday_CompOff_Limit = 0 
		set @Weekday_CompOff_Limit = @Weekday_CompOff_Limit_BranchWise
	If @Holiday_CompOff_Limit = 0 
		set @Holiday_CompOff_Limit = @Holiday_CompOff_Limit_BranchWise
	If @Weekoff_CompOff_Limit = 0 
		set @Weekoff_CompOff_Limit = @Weekoff_CompOff_Limit_BranchWise
	
	-- Third Default Limit Setting if Employee & Branch wise Zero
	
	if  @Weekday_CompOff_Limit = 0 
		set @Weekday_CompOff_Limit = 60
	if  @Holiday_CompOff_Limit = 0 
		set @Holiday_CompOff_Limit = 60
	if	@Weekoff_CompOff_Limit = 0
		set @Weekoff_CompOff_Limit = 60
	
	
	set  @Holiday_From_Date = Convert(varchar(25),DATEADD(D,@Holiday_CompOff_Limit * -1,@Extra_Work_Date))		
	set  @Weekoff_From_Date = Convert(varchar(25),DATEADD(D,@Weekoff_CompOff_Limit * -1,@Extra_Work_Date))
	set  @Weekday_From_Date = Convert(varchar(25),DATEADD(D,@Weekday_CompOff_Limit * -1,@Extra_Work_Date))		
	--Added by Gadriwala 24/11/2014 - End
    Declare @Is_Cancel_Holiday tinyint
	Declare @Is_Cancel_Weekoff tinyint
    set @Is_Cancel_Holiday = 0
    set @Is_Cancel_Weekoff = 0
	select Top 1 @Gen_ID  = ISNULL(Gen_ID, 0),
			@Is_CompOff = ISNULL(Is_CompOff, 0), @Is_WD = ISNULL(Is_CompOff_WD, 0), 
			@Is_WOHO = ISNULL(Is_CompOff_WOHO, 0)
			,@Is_HO_CompOff = Is_HO_CompOff			----Added By Sid 24/02/2014
			,@Is_W_CompOff = Is_W_CompOff,  ----Added By Sid 24/02/2014
			@Is_Cancel_Holiday = Is_Cancel_Holiday, @Is_Cancel_Weekoff = Is_Cancel_Weekoff			
    from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID   
    and For_Date = ( select Max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @Approval_Date and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)

	IF((@Is_CompOff = 0) OR (@Is_WD = 0 And @Is_HO_CompOff = 0 And @Is_W_CompOff = 0))-- @Is_WOHO = 0))
    BEGIN
		Raiserror('@@Comp-off not applicable@@',18,2)
	    Return -1
    END


	--EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id,@Cmp_ID, @Extra_Work_Date, @Extra_Work_Date,NULL, NULL, 9, @StrHoliday_Date OUTPUT,0, 0, 0, @Branch_ID,@StrWeekoff_Date    
	--EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_Id,@Cmp_ID,@Extra_Work_Date,@Extra_Work_Date,NULL,NULL,9,@StrHoliday_Date,@StrWeekoff_Date OUTPUT,0,0

	
	/*FOLLOWING CODE ADDED BY NIMESH ON 18-SEP-2017 (WE ARE TRYING TO REMOVE THE OLD METHOD SP_EMP_WEEKOFF_DATE_GET AND SP_EMP_HOLIDAY_DATE_GET*/
	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		
	CREATE TABLE #EMP_WEEKOFF
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		

	DECLARE @CONSTRAINT VARCHAR(20)
	SET @CONSTRAINT = CAST(@Emp_Id AS VARCHAR(10))

	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@Extra_Work_Date, @TO_DATE=@Extra_Work_Date, @All_Weekoff = 1, @Exec_Mode=0		

	DECLARE @WH_STATUS TINYINT
	IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date=@Extra_Work_Date) 
		SET @WH_STATUS = 1
	ELSE IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE FOR_DATE=@Extra_Work_Date)	
		SET @WH_STATUS = 2
	ELSE
		SET @WH_STATUS = 0

	
	
	If Not Exists(Select Row_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_ID and Grd_ID= @Grd_ID and Cmp_ID = @Cmp_ID)
		BEGIN
			Raiserror('@@Comp-Off leave not assigned to grade@@',18,2)
			return -1
		END
	Declare @Var_Compoff_min_hours varchar(10)  -- Add By Paras 05-06-2013
	If @Tran_type = 'I'
		BEGIN    
			Set @sanctione_hrs = Cast(REPLACE(@Sanctioned_Hours,':','.') as numeric(18,2))     
			--Set @sanctione_hrs = dbo.F_Return_Sec(@Sanctioned_Hours)/3600
			IF(@Extra_Work_Date > GETDATE())
				BEGIN
					Raiserror('@@Future date not allowed@@',18,2)
					Return -1
				END
	   	
		   --	set @sanctione_hrs = floor(@sanctione_hrs*2)/2
	   	
	   		IF(@Is_WD = 0 And @Is_W_CompOff = 1 And @Is_HO_CompOff = 0)
				BEGIN
					--IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) = 0
					IF @WH_STATUS <> 1
						BEGIN
							Raiserror('@@only WO allowed@@',18,2)
							Return -1
						END				
				END
		
			IF(@Is_WD = 0 And @Is_HO_CompOff = 1 and @Is_W_CompOff = 0)
				BEGIN
					--IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) = 0 
					IF @WH_STATUS <> 2
						BEGIN
							Raiserror('@@only HO allowed@@',18,2)
							Return -1
						END				
				END
		
			IF(@Is_WD = 1 And @Is_W_CompOff = 0 And @Is_HO_CompOff = 0)
				BEGIN
					--IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0 OR CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0 
					IF @WH_STATUS <> 0
						BEGIN
							Raiserror('@@only Weekdays allowed@@',18,2)
							Return -1
						END
				END	
			if (@CompOff_Application_ID is null )
				begin
		
				--If (@CompOffdayslimit <> 0)
				--BEGIN
				--	Set @Compoffdayslimitdate = DATEADD(D,isnull(@CompOffdayslimit * -1,0),CONVERT(VARCHAR(10), GETDATE(), 101))	  
				--		IF(@Compoffdayslimitdate > @Extra_Work_Date)
				--		BEGIN
				--			Raiserror('@@Extra work date is less then days limit@@',18,2)
				--			Return -1
				--		END
				--END
				 --Added by Gadriwala Muslim 24/11/2014 - Start
					   --if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0 
					   IF @WH_STATUS = 1
							begin
								 IF(@Weekoff_From_Date > @Extra_Work_Date)
									 BEGIN
										   Raiserror('@@Extra work date is less then days limit@@',18,2)
											 Return -1
									  END	
							end
						--else if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0 
						ELSE IF @WH_STATUS = 2
							begin
								 IF(@Holiday_From_Date > @Extra_Work_Date)
									 BEGIN
										   Raiserror('@@Extra work date is less then days limit@@',18,2)
											 Return -1
									  END
							end
						else
							begin
								  IF(@Weekday_From_Date > @Extra_Work_Date)
									 BEGIN
										   Raiserror('@@Extra work date is less then days limit@@',18,2)
											 Return -1
									  END
							end	
					--Added by Gadriwala Muslim 24/11/2014 - End
				 end  
	      
			--Start Add By Paras 05-06-2013
		
		
			set @Var_Compoff_min_hours = ''
	   	
	   		----------------Added by Sid ------------03/03/2014
	   		 --if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0
			 IF @WH_STATUS = 1
	   			 begin
	   				select @var_Compoff_min_hours =W_CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK)
	   				where Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
	   			 end
	   		 --else if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0
			 ELSE IF @WH_STATUS = 2
	   			 begin
	   				select @var_Compoff_min_hours =H_CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK)
	   				where Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
	   			end
	   		 else
	   			 begin
	   				select @var_Compoff_min_hours =CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK)
	   				where Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
	   			 end
       
			if isnull(@Var_Compoff_min_hours,'00:00') = '00:00'
				begin
					select @Var_Compoff_min_hours = isnull(Compoff_min_hrs,'00:00') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
			
					if @Var_Compoff_min_hours = ''
						set @Var_Compoff_min_hours = '00:00'
				end
			----------------End by Sid ------------03/03/2014 
		
			if @Var_Compoff_min_hours = ''
				set @Var_Compoff_min_hours = '00:00'
		
			set @Compoff_min_hours = Cast(Replace(@Var_Compoff_min_hours,':','.')as numeric(18,2))
			--End Add By Paras 05-06-2013 
       
			if (@sanctione_hrs < @Compoff_min_hours)
				BEGIN
					Raiserror('@@Sanctioned hours less then Min hours@@',18,2)
					Return -1
				END
        
			IF Exists(Select Tran_ID  from T0160_OT_APPROVAL WITH (NOLOCK) where For_Date = @Extra_Work_Date and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Is_Approved = 1)
				BEGIN
					Raiserror('@@OT Approved@@',18,2)
					Return -1
				END
			---------------Added by Sid 24/02/2014 ----------------------
  			Declare @Apply_Hourly as Numeric(18,2) 
			Declare @slab_type as varchar(1) 
			Declare @weekoff_date as varchar(max)
			Declare @Holiday_date as varchar(max)
			Declare @Sanctioned_Hours_temp as numeric(18,2)
	
			Set @Apply_Hourly 	= 0
			Set @slab_type = 'C'
			Set @Sanctioned_Hours_temp  = 1
	
			select @Apply_Hourly = Apply_Hourly from T0040_LEAVE_MASTER WITH (NOLOCK)
			where Leave_Code = 'COMP' and Cmp_ID = @Cmp_ID
	
			if @Apply_Hourly = 1
				begin
					--set @Sanctioned_Hours_temp = cast(replace(@sanctioned_hours,':','.') as numeric(18,2))
					set @sanctioned_hours_temp = dbo.f_return_sec(@sanctioned_hours)/3600
				end
	
			SET @sanctioned_hours_temp = floor(@sanctioned_hours_temp*2)/2	
	
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
	
	
			--insert into @Get_WO_HO 
			--EXEC [SP_RPT_EMP_ATTENDANCE_MUSTER_IN_EXCEL_New]
			--	@cmp_id = @cmp_id,@from_date = @Extra_Work_Date,@to_date = @Extra_Work_Date, @branch_id = 0,@Cat_ID = 0,@grd_id = 0,@Type_id = 0
			--	,@dept_ID = 0,@desig_ID = 0,@emp_id = @Emp_ID ,@constraint = '',@Report_For = 'WHO'

			--select @weekoff_date = Weekoff_Date,@Holiday_date = Holiday_Date  from @Get_WO_HO
	
			--if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0 
			IF @WH_STATUS = 1
				set @slab_type = 'W'
			--else if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0 
			ELSE IF @WH_STATUS = 2
				set @slab_type = 'H'	
			else
				set @slab_type = 'C'
	
			
	
			--if CHARINDEX(replace(convert(nvarchar(11),@Extra_Work_Date,106),' ','-'),@Holiday_date)>0
			--	set @slab_type = 'H'
			--else if CHARINDEX(replace(convert(nvarchar(11),@Extra_Work_Date,106),' ','-'),@weekoff_date)>0
			--	set @slab_type = 'W'
			--else
			--	set @slab_type = 'C'
  
			---------------Added by Sid 24/02/2014 ----------------------
  
			--The following code added by Nimesh (Slab in General Settings like 0 to 3.59, 4 to 7.59 and value in @sanctione_hrs variable getting stored like 7.88, 7.98) 05-Dec-2017
			--set @sanctione_hrs = @sanctione_hrs * 3600
			--set @sanctione_hrs = ((@sanctione_hrs - (@sanctione_hrs % 3600)) / 3600) + ( (@sanctione_hrs % 3600) / 60 / 100)
		
			Declare curapp cursor for
			SELECT From_hours, To_hours, Deduction_Days from T0050_GENERAL_DETAIL_SLAB WITH (NOLOCK) where GEN_ID = @Gen_ID and Slab_Type = @slab_type			--------Added by Sid 24/02/2014

			Open curapp
			Fetch Next from curapp into @Fromhrs, @Tohrs, @Days
			WHILE @@fetch_status = 0
				BEGIN
					IF(@sanctione_hrs >= @Fromhrs and @sanctione_hrs <= @Tohrs)
						BEGIN        
							IF (ISNULL(@Days, 0) <> 0)
								Set @Com_Days = @Days  * @Sanctioned_Hours_temp			----Added by Sid 24/02/2014 
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
      
			IF Exists(select CompOff_Appr_ID from T0120_CompOff_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and Extra_Work_Date = @Extra_Work_Date and Approve_Status = 'A')
				BEGIN
					if @Approval_Comments <> 'Auto Comp-Off Approval with job'   ---added by jimit 12092016  NO need to Raise error when running with Job.
						begin
							Raiserror('@@This Application is Already approved@@',18,2)
						end
					Return -1
				END       
       
			SELECT  @CompOff_Approval_ID = Isnull(Max(CompOff_Appr_ID),0) + 1  From T0120_CompOff_Approval  WITH (NOLOCK) 
    
			INSERT INTO T0120_CompOff_Approval  
					   (CompOff_Appr_ID, CompOff_App_ID, Cmp_ID, Emp_ID, S_Emp_ID, Extra_Work_Date, Approve_Date, Extra_Work_Hours, Sanctioned_Hours, Approve_Status, Extra_Work_Reason, Approve_Comments, Contact_No, Email_ID, Login_ID, System_Datetime, CompOff_Days)                
			VALUES (@CompOff_Approval_ID, @CompOff_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Extra_Work_Date, @Approval_Date, @Extra_Work_Hours, @Sanctioned_Hours, @Approval_Status, @Extra_Work_Reason, @Approval_Comments, @Contact_No, @Email_ID, @Login_ID, @System_Date, @Com_Days)   
        
            
			UPDATE T0100_CompOff_Application
				SET Application_Status= @Approval_Status
			WHERE Compoff_App_ID = @CompOff_Application_ID and
					Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID  
                
		 -- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0120_CompOff_Approval' ,@key_column='CompOff_Appr_ID',@key_Values=@CompOff_Approval_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)	          
		END
	Else If @Tran_type = 'U'
		BEGIN
			If Exists(select CompOff_Appr_ID from T0120_CompOff_Approval WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID and CompOff_Appr_ID = @CompOff_Approval_ID and Approve_Status='R')
				BEGIN
					Raiserror('@@This Application is Rejected you cannot approve it@@',18,2)
					Return -1
				END
        
			-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table='T0120_CompOff_Approval' ,@key_column='CompOff_Appr_ID',@key_Values=@CompOff_Approval_ID,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)
	  
			UPDATE	T0120_CompOff_Approval  
			SET		CompOff_App_ID = @CompOff_Application_ID,
					Cmp_ID = @Cmp_ID, 
					Emp_ID = @Emp_ID,
					S_Emp_ID = @S_Emp_ID,
					Extra_Work_Date = @Extra_Work_Date,
					Approve_Date = @Approval_Date,
					Extra_Work_Hours = @Extra_Work_Hours,
					Sanctioned_Hours = @Sanctioned_Hours,	
					Approve_Status = @Approval_Status, 
					Extra_Work_Reason = @Extra_Work_Reason,   
					Approve_Comments = @Approval_Comments,
					Contact_No = @Contact_No,
					Email_ID = @Email_ID,
					Login_ID = @Login_ID,			  
					CompOff_Days = @Com_Days
			Where	CompOff_Appr_ID = @CompOff_Approval_ID 
		
			-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0120_CompOff_Approval' ,@key_column='CompOff_Appr_ID',@key_Values=@CompOff_Approval_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 05072016(end)     
		END
	Else If @Tran_type = 'D'
		BEGIN
			--Declare @Approve_Date as DateTime       
			--      Declare @Leave_Used as numeric(18,2)
			--      Declare @App_ID as numeric 
			--      Select @Approve_Date = Approve_Date from T0120_CompOff_Approval where CompOff_Appr_ID = @CompOff_Approval_ID and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID             
			--      Select @Leave_Used = Sum(Leave_Used) from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Leave_ID = @Leave_ID and For_Date >= @Approve_Date
            
			--      Select @App_ID = ISNULL(CompOff_App_ID,0)  from T0120_CompOff_Approval where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CompOff_Appr_ID = @CompOff_Approval_ID
			--      IF(@Leave_Used > 0)
			--      BEGIN
			--	Raiserror('@@Leave Used approval cannot be deleted@@',18,2)
			--    Return -1
			--END 
			--      Else
			--      BEGIN           
			--	Delete From T0120_CompOff_Approval Where CompOff_Appr_ID = @CompOff_Approval_ID and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
            
			--          Update T0100_CompOff_Application Set Application_Status = 'P' 
			--		where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Compoff_App_ID = @App_ID
			--      END
			-- Added by Gadriwala Muslim 01102014 - Start
			Declare @CompOff_Debit as numeric(18,2)
			Declare @strLeave_CompOff_dates as varchar(max)
			set @strLeave_CompOff_dates = ''
        
			Declare @App_ID as numeric 
		 
			Select @Extra_Work_Date = Extra_Work_Date from T0120_CompOff_Approval WITH (NOLOCK) where CompOff_Appr_ID = @CompOff_Approval_ID and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID             
       
			Select @CompOff_debit = isnull(CompOff_Debit,0) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and Leave_ID = @Leave_ID and For_Date = @Extra_Work_Date
        
			-- Check Leave Application Exist or Not Gadriwala muslim 11092014 - Start
			Create Table #Leave_Applied
			(
				Leave_Date datetime,
				Leave_Period numeric(18,2)
			)		  
			SELECT  @strLeave_CompOff_dates = @strLeave_CompOff_dates + '#' + Leave_CompOff_Dates  
			FROM	V0110_LEAVE_APPLICATION_DETAIL 
			WHERE	Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
					and Application_Status = 'P' and Leave_ID = @leave_ID and  isnull(Leave_CompOff_Dates,'') <> ''
		
		
			Insert into #Leave_Applied(Leave_date,Leave_Period)
			SELECT  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10) 
			from dbo.SPlit(@strLeave_CompOff_dates,'#') where Data <> ''
			-- Check Leave Application Exist or Not Gadriwala muslim 11092014 - End	 
			Select @App_ID = ISNULL(CompOff_App_ID,0)  from T0120_CompOff_Approval WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CompOff_Appr_ID = @CompOff_Approval_ID
			IF(@CompOff_debit > 0) or exists( select 1 from #Leave_Applied where Leave_Date =@Extra_Work_Date)
				BEGIN
					Raiserror('@@Leave Used approval cannot be deleted@@',18,2)
					Return -1
				END 
			Else
				BEGIN  
					-- Add By Mukti 05072016(start)
						exec P9999_Audit_get @table='T0120_CompOff_Approval' ,@key_column='CompOff_Appr_ID',@key_Values=@CompOff_Approval_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					-- Add By Mukti 05072016(end)
                 
					Delete From T0120_CompOff_Approval Where CompOff_Appr_ID = @CompOff_Approval_ID and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
            
					Update T0100_CompOff_Application Set Application_Status = 'P' 
						where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Compoff_App_ID = @App_ID
				END
			-- Added by Gadriwala Muslim 01102014 - End
		END    
   EXEC P9999_Audit_Trail @CMP_ID,@Tran_type,'Comp-off Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN
