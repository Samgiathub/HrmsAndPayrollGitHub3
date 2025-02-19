
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_COMPOFF_APPLICATION] 
	@Compoff_App_ID NUMERIC OUTPUT
   ,@Cmp_ID NUMERIC
   ,@EMP_ID NUMERIC
   ,@S_EMP_ID NUMERIC
   ,@CompOff_App_Date DateTime
   ,@Extra_Work_Date DateTime
   ,@Extra_Work_Hours Varchar(10)
   ,@Application_Status Char(1)
   ,@Extra_Work_Reason Varchar(250)
   ,@Login_ID Numeric
   ,@System_Date DateTime
   ,@Trans_Type Varchar(1)
   ,@CompOff_Type varchar(2) = ''
   ,@User_Id numeric(18,0) = 0 -- Add By Mukti 05072016
   ,@IP_Address varchar(100)= '' -- Add By Mukti 05072016
   ,@OT_TYPE TINYINT = 0 -- Sumit on 09122016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   Declare @Compoff_min_hours as numeric(18,2)   
   Declare @CompOffdayslimit as numeric
   Declare @Compoffdayslimitdate as DateTime
   Declare @Extra_Workhrs as numeric(18,2)
   Declare @Grd_ID as numeric
   Declare @Leave_ID as numeric
   Declare @Is_CompOff as numeric
   Declare @Is_WD as Numeric
   Declare @Is_WOHO as Numeric  
   Declare @Is_HO_CompOff as Numeric
   Declare @IS_W_CompOff as Numeric
   --Declare @StrWeekoff_Date VARCHAR(1000)
   --Declare @StrHoliday_Date VARCHAR(1000)   
   
   Declare @Branch_ID as numeric
     Set @Branch_ID = 0
       set @Extra_Work_Reason = dbo.fnc_ReverseHTMLTags(@Extra_Work_Reason)  --added by mansi 091221  
   --Set @StrWeekoff_Date = ''
   --Set @StrHoliday_Date = ''
   if @S_EMP_ID = 0     
      set @S_EMP_ID = NULL     
  
  -- Add By Mukti 05072016(start)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
 -- Add By Mukti 05072016(end)	
	
  If (@Trans_Type = 'D') 
     BEGIN
        Select @Emp_ID =  Emp_ID from T0100_CompOff_Application WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Compoff_App_ID = @Compoff_App_ID 
     END 
     
  Select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) where Default_Short_Name = 'COMP' and Cmp_ID = @Cmp_ID
     
  select @Branch_ID = Branch_ID, @Grd_ID = Grd_ID  From T0095_Increment I WITH (NOLOCK) inner join     
   (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)   --Changed by Hardik 10/09/2014 for Same Date Increment  
   where Increment_Effective_date <= @CompOff_App_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID 
   
   
      -- commented by mitesh on 16022013 - as for avail compoff balance salary is not related. it will check from general setting.
	--  If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And 
	--		((@Extra_Work_Date >= Month_St_Date and @Extra_Work_Date <= Month_End_Date) or 
	--				(@Extra_Work_Date >= Month_St_Date and 	@Extra_Work_Date <= Month_End_Date) or 
	--				(Month_St_Date >= @Extra_Work_Date and Month_St_Date <= @Extra_Work_Date) or
	--				(Month_End_Date >= @Extra_Work_Date and Month_End_Date <= @Extra_Work_Date)))
	--		Begin
	--			Raiserror('@@This Months Salary Exists@@',18,2)
	--			return -1
	--		End
		
		
	--IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WHERE (MONTH =  MONTH(@Extra_Work_Date) and YEAR =  YEAR(@Extra_Work_Date)) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))
	--		Begin
	--			Raiserror('@@Month Lock@@',18,2)
	--			return -1
	--		End
	
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
     
	Select 			@Is_CompOff = ISNULL(Is_CompOff, 0), 
					@Is_WD = ISNULL(Is_CompOff_WD, 0), 
					@Is_WOHO = ISNULL(Is_CompOff_WOHO, 0),  
					@Is_HO_CompOff = Is_HO_CompOff,
					@IS_W_CompOff = Is_W_CompOff ,
					@Is_Cancel_Holiday = Is_Cancel_Holiday, @Is_Cancel_Weekoff = Is_Cancel_Weekoff	
       from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID   
       and For_Date = (select Max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @CompOff_App_Date and Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
    
	
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

   
   IF @Trans_Type = 'I'
     BEGIN
       Set @Extra_Workhrs = Cast(REPLACE(@Extra_Work_Hours,':','.') as numeric(18,2))
        
        IF((@Is_CompOff = 0) OR (@Is_WD = 0 AND @IS_W_CompOff = 0 AND @Is_HO_CompOff = 0)) --OR (@Is_WD = 0 And @Is_WOHO = 0))
			BEGIN
				Raiserror('@@Comp-off not applicable@@',18,2)
				Return -1
			END 
		
		If Exists(Select CompOff_Appr_ID from T0120_CompOff_Approval WITH (NOLOCK) where Extra_Work_Date = @Extra_Work_Date and Emp_ID = @EMP_ID and Cmp_ID = @Cmp_ID  and Approve_Status = 'A')
			BEGIN
				Raiserror('@@Already Approved@@',18,2)
				Return -1
			END
			
        If Not Exists(Select Row_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_ID and Grd_ID= @Grd_ID and Cmp_ID = @Cmp_ID)
          BEGIN
            Raiserror('@@Comp-Off leave not assigned to grade@@',18,2)
	        Return -1
          END
       
       --EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id, @Cmp_ID, @Extra_Work_Date, @Extra_Work_Date, NULL, NULL, @Is_Cancel_Holiday, @StrHoliday_Date OUTPUT, 0, 0, 0, @Branch_ID, @StrWeekoff_Date  
       --EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_Id, @Cmp_ID, @Extra_Work_Date, @Extra_Work_Date, NULL, NULL, @Is_Cancel_Weekoff, @StrHoliday_Date, @StrWeekoff_Date OUTPUT, 0, 0
	   	
	   
	    -- Changed by Gadriwala Muslim 11122014 - Start
	   
	   IF (@Is_WD = 0)
		begin
			--If  @StrWeekoff_Date = '' and @StrHoliday_Date = ''
			IF @WH_STATUS = 0
				begin
					Raiserror('@@Weekdays not allowed@@',18,2)
					Return -1
				end
				
		end
		If (@IS_W_CompOff = 0)
			begin
				--if @StrWeekoff_Date <> ''
				IF @WH_STATUS = 1			--@WH_STATUS <> 1( Commented and Changed By Ramiz on 24/12/18)
					begin
						Raiserror('@@WeekOff date not allowed@@',18,2)
						Return -1
					end
			end
		If (@IS_HO_CompOff = 0)
			begin
				--if @StrHoliday_Date <> ''
				IF @WH_STATUS = 2			--@WH_STATUS <> 2( Commented and Changed By Ramiz on 24/12/18)
					begin
						Raiserror('@@Holiday date not allowed@@',18,2)
						Return -1
					end
			end
		-- Changed by Gadriwala Muslim 11122014 - Start
	 
		--IF(@Is_WD = 1 And (@IS_W_CompOff = 0 And @Is_HO_CompOff = 0))--@Is_WOHO = 0)
		--BEGIN
		--	IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0 OR CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0 
		--	BEGIN
		--		Raiserror('@@only Weekdays allowed@@',18,2)
		--		Return -1
		--	END
		--END
			
  --      IF(@Is_WD = 0 And @IS_W_CompOff = 1)
		--	BEGIN
		--		IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) = 0
		--			BEGIN
		--				IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) = 0 
		--					BEGIN
		--						Raiserror('@@only WO allowed@@',18,2)
		--						Return -1
		--					END				
		--			END
		--	END
			
  --      IF(@Is_WD = 0 And @Is_HO_CompOff = 1)
		--	BEGIN
		--		IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) = 0
		--			BEGIN
		--				IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) = 0 
		--					BEGIN
		--						Raiserror('@@only HO allowed@@',18,2)
		--						Return -1
		--					END				
		--			END
		--	END			
       IF(@Extra_Work_Date > @CompOff_App_Date)
         BEGIN
           Raiserror('@@Future date not allowed@@',18,2)
	       Return -1
         END
       
       --If (@CompOffdayslimit <> 0)
       --  BEGIN
       --    Set @Compoffdayslimitdate = DATEADD(D,ISNULL(@CompOffdayslimit * -1,0), @CompOff_App_Date)           
       --    	  IF(@Compoffdayslimitdate > @Extra_Work_Date)
	      --      BEGIN
	      --        Raiserror('@@Extra work date is less then days limit@@',18,2)
	      --        Return -1
	      --      END
       --  END
       
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
	   Declare @Var_Compoff_min_hours varchar(10)
	   set @Var_Compoff_min_hours = ''
		----------------Added by Sid ------------03/03/2014
	   	 --if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0
		 IF @WH_STATUS = 1
	   		 BEGIN
	   			SELECT @var_Compoff_min_hours =W_CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK)
	   			WHERE Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
	   		 END
	   	 --else if CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0
		ELSE IF @WH_STATUS = 2
			BEGIN
				SELECT @var_Compoff_min_hours =H_CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK)
				WHERE Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
			END
	   	 ELSE
	   		 BEGIN
	   			SELECT @var_Compoff_min_hours =CompOff_Min_Hours from T0040_GENERAL_SETTING WITH (NOLOCK)
	   			WHERE Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
	   		 END
       
		IF @Var_Compoff_min_hours = '00:00'
			BEGIN
				SELECT @Var_Compoff_min_hours = isnull(Compoff_min_hrs,'00:00') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
			
				if @Var_Compoff_min_hours = ''
					set @Var_Compoff_min_hours = '00:00'
			end
		----------------End by Sid ------------03/03/2014
		
		
		set @Compoff_min_hours = Cast(Replace(@Var_Compoff_min_hours,':','.')as numeric(18,2))

		if (@Extra_Workhrs < @Compoff_min_hours)
			BEGIN
				Raiserror('@@Extra work hours less then Min applicable Comp-Off hours@@',18,2)
				Return -1
			END
       
       IF Exists( Select Compoff_App_ID from T0100_CompOff_Application WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID and Extra_Work_Date = @Extra_Work_Date)
         BEGIN
           Raiserror('@@Application for this date is already registered@@',18,2)
		   Return -1
         END
         
        select @Compoff_App_ID = isnull(Max(Compoff_App_ID),0) + 1 from T0100_CompOff_Application WITH (NOLOCK)
         
        INSERT INTO T0100_CompOff_Application    
                    (Compoff_App_ID, Cmp_ID, Emp_ID, S_Emp_ID, Application_Date, Extra_Work_Date, Extra_Work_Hours, Application_Status, Extra_Work_Reason, Login_ID, System_Datetime,CompOff_Type,OT_TYPE)    
        VALUES  (@Compoff_App_ID, @Cmp_ID, @EMP_ID, @S_EMP_ID, @CompOff_App_Date, @Extra_Work_Date, @Extra_Work_Hours, @Application_Status, @Extra_Work_Reason, @Login_ID, @System_Date,@CompOff_Type,@OT_TYPE)     
        
        -- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0100_CompOff_Application' ,@key_column='Compoff_App_ID',@key_Values=@Compoff_App_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 05072016(end)	
     END
   ELSE IF @Trans_Type = 'U'
     BEGIN
       
       Set @Extra_Workhrs = Cast(REPLACE(@Extra_Work_Hours,':','.') as numeric(18,2))
       
       IF((@Is_CompOff = 0) OR (@Is_WD = 0 AND @IS_W_CompOff = 0 AND @Is_HO_CompOff = 0)) --OR (@Is_WD = 0 And @Is_WOHO = 0))
			BEGIN
				Raiserror('@@Comp-off not applicable@@',18,2)
				Return -1
			END 
			
      If Exists(Select CompOff_Appr_ID from T0120_CompOff_Approval WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID and Extra_Work_Date = @Extra_Work_Date and Approve_Status = 'A')
			BEGIN
				Raiserror('@@Already Approved@@',18,2)
				Return -1
			END
			
        If Not Exists(Select Row_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_ID and Grd_ID= @Grd_ID and Cmp_ID = @Cmp_ID)
          BEGIN
            Raiserror('@@Comp-Off leave not assigned to grade@@',18,2)
	        Return -1
          END
        
      
	   --EXEC SP_EMP_HOLIDAY_DATE_GET @Emp_Id, @Cmp_ID, @Extra_Work_Date, @Extra_Work_Date, NULL, NULL, @Is_Cancel_Holiday, @StrHoliday_Date OUTPUT, 0, 0, 0, @Branch_ID, @StrWeekoff_Date  
	   -- EXEC SP_EMP_WEEKOFF_DATE_GET @Emp_Id, @Cmp_ID, @Extra_Work_Date, @Extra_Work_Date, NULL, NULL, @Is_Cancel_Weekoff, @StrHoliday_Date, @StrWeekoff_Date OUTPUT, 0, 0
	    -- Changed by Gadriwala Muslim 11122014 - Start
	   IF (@Is_WD = 0)
		begin
			--If  @StrWeekoff_Date = '' and @StrHoliday_Date = ''
			IF @WH_STATUS = 0
				begin
					Raiserror('@@Weekdays not allowed@@',18,2)
					Return -1	
				end
				
		end
		If (@IS_W_CompOff = 0)
			begin
				--if @StrWeekoff_Date <> ''
				IF @WH_STATUS <> 1
					begin
						Raiserror('@@WeekOff date not allowed@@',18,2)
						Return -1	
					end
			end
		If (@IS_HO_CompOff = 0)
			begin
				--if @StrHoliday_Date <> ''
				IF @WH_STATUS <> 2
					begin
						Raiserror('@@Holiday date not allowed@@',18,2)
						Return -1	
					end
			end
			
   --    IF(@Is_WD = 1 And @Is_WOHO = 0)
			--BEGIN
			--	IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) > 0 OR CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) > 0 
			--		BEGIN
			--			Raiserror('@@only Weekdays allowed@@',18,2)
			--			Return -1
			--		END
			--END
			
   --     IF(@Is_WD = 0 And @Is_WOHO = 1)
			--BEGIN
			--	IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrWeekoff_Date,0) = 0
			--		BEGIN
			--			IF CHARINDEX(CAST(@Extra_Work_Date as varchar(11)),@StrHoliday_Date,0) = 0 
			--				BEGIN
			--					Raiserror('@@only WO/HO allowed@@',18,2)
			--					Return -1
			--				END				
			--		END
			--END
			  
		IF(@Extra_Work_Date > @CompOff_App_Date)
			BEGIN
				Raiserror('@@Future date not allowed@@',18,2)
				Return -1
			END      
       
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
       --If (@CompOffdayslimit <> 0)
       --  BEGIN
       --    Set @Compoffdayslimitdate = DATEADD(D,isnull(@CompOffdayslimit * -1,0),@CompOff_App_Date)
       --    	  IF(@Compoffdayslimitdate > @Extra_Work_Date)
	      --      BEGIN
	      --        Raiserror('@@Extra work date is less then days limit@@',18,2)
	      --        Return -1
	      --      END
       --  END
       --Start Add By paras 05062013  
       --select @Compoff_min_hours = Cast(Replace(CompOff_Min_hrs,':','.')as numeric(18,2)) from T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
       set @Var_Compoff_min_hours = ''
	   	 
       select @Var_Compoff_min_hours = isnull(Compoff_min_hrs,'00:00') from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
	   
	   if @Var_Compoff_min_hours = ''
			set @Var_Compoff_min_hours = '00:00'

	   set @Compoff_min_hours = Cast(Replace(@Var_Compoff_min_hours,':','.')as numeric(18,2))
	   --End Add By paras 0050562013  
       if (@Extra_Workhrs < @Compoff_min_hours)
          BEGIN
            Raiserror('@@Extra work hours less then Minimum applicable Comp-Off hours@@',18,2)
	        Return -1
          END
       
       IF Exists( Select Compoff_App_ID from T0100_CompOff_Application WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID and Extra_Work_Date = @Extra_Work_Date and Compoff_App_ID <> @Compoff_App_ID)
         BEGIN
           Raiserror('@@Application for this date is already registered@@',18,2)
		   Return -1
         END
           
      -- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table='T0100_CompOff_Application' ,@key_column='Compoff_App_ID',@key_Values=@Compoff_App_ID,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
	  -- Add By Mukti 05072016(end)
			
       UPDATE T0100_CompOff_Application    
       SET    Cmp_ID = @Cmp_ID, Emp_ID = @Emp_ID, S_Emp_ID = @S_Emp_ID, Application_Date = @CompOff_App_Date, Extra_Work_Date = @Extra_Work_Date,
              Extra_Work_Hours = @Extra_Work_Hours, Application_Status = @Application_Status, Extra_Work_Reason = @Extra_Work_Reason, 
              Login_ID = @Login_ID, System_Datetime = @System_Date,CompOff_Type = @CompOff_Type,   
              OT_Type = @OT_Type --Sumit on 09122016 COND
              where Compoff_App_ID = @Compoff_App_ID 
              
     	-- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table = 'T0100_CompOff_Application' ,@key_column='Compoff_App_ID',@key_Values=@Compoff_App_ID,@String=@String output
			set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
		 -- Add By Mukti 05072016(end)              
     END
   ELSE IF @Trans_Type = 'D'
     BEGIN
       -- Add By Mukti 05072016(start)
			exec P9999_Audit_get @table='T0100_CompOff_Application' ,@key_column='Compoff_App_ID',@key_Values=@Compoff_App_ID,@String=@String output
			set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
	  -- Add By Mukti 05072016(end) 
	  DELETE FROM T0120_CompOff_Approval WHERE CompOff_App_ID = @Compoff_App_ID
       DELETE FROM T0100_CompOff_Application where Compoff_App_ID = @Compoff_App_ID    
     END
          
     exec P9999_Audit_Trail @CMP_ID,@Trans_Type,'Comp-off Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
RETURN
