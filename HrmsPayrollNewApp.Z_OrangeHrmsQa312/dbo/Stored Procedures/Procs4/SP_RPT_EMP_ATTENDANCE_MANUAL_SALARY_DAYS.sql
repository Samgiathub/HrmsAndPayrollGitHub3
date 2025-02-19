---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_ATTENDANCE_MANUAL_SALARY_DAYS]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	--,@Cat_ID 		numeric
	,@Cat_ID 		varchar(MAX) = '' --Added by nilesh patel on 03-11-2014
	--,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Grd_ID 		varchar(MAX) = ''
	--,@Dept_ID 		numeric
    ,@Dept_ID 		varchar(MAX) = ''
	,@Desig_ID 		varchar(MAX) = ''
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_For	varchar(50) = ''
	,@Export_Type	varchar(50) = ''
	,@Branch_Constraint varchar(MAX) = '' -- Added By Gadriwala 11092013
	,@Salary_Cycle_id numeric
	--,@Segment_ID numeric Comment by nilesh patel on 03112014 
	--,@Vertical numeric
	--,@SubVertical numeric
	--,@subBranch numeric
	,@Segment_ID Varchar(1000) = '' --Added by nilesh patel on 03112014 
	,@Vertical Varchar(1000) = '' --Added by nilesh patel on 03112014 
	,@SubVertical Varchar(1000) = '' --Added by nilesh patel on 03112014 
	,@subBranch Varchar(1000) = '' --Added by nilesh patel on 03112014 
	,@is_Cutoffdate tinyint=0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	-- added by mitesh for actual days present in manual salary on 16012013
	
 CREATE table #Data     
  (     
	Emp_Id     numeric ,     
	For_date   datetime,    
	Duration_in_sec  numeric,    
	Shift_ID   numeric ,    
	Shift_Type   numeric ,    
	Emp_OT    numeric ,    
	Emp_OT_min_Limit numeric,    
	Emp_OT_max_Limit numeric,    
	P_days    numeric(12,1) default 0,    
	OT_Sec    numeric default 0,
	In_Time datetime default null,
	Shift_Start_Time datetime default null,
	OT_Start_Time numeric default 0,
	Shift_Change tinyint default 0 ,
	Flag Int Default 0  ,
	Weekoff_OT_Sec  numeric default 0,
	Holiday_OT_Sec  numeric default 0,
	Chk_By_Superior numeric default 0,
	IO_Tran_Id	   numeric default 0,
	Out_time datetime default null
  )    
    
	Create NONCLUSTERED INDEX IX_Data ON dbo.#data
	(
	Emp_Id,
	Shift_ID,
	For_Date) 
	
		
	Declare @Is_Cancel_Holiday  numeric(1,0)
	Declare @Is_Cancel_Weekoff	numeric(1,0)	
	

	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	) 
  -- Create New Sp by Nilesh Patel on 27-08-2014 
     --EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Salary_Cycle_id,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@constraint	-- Changed By Gadriwala 11092013
	-- exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical,@SubVertical,@SubBranch,0,0,0,'0',0,0  
	If EXISTS(Select 1 from T0080_emp_master where EMP_Id = @Emp_ID and EMP_LEFT = 'N' and Cmp_ID = @Cmp_ID)
	BEGIN
		exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical,@SubVertical,@SubBranch,0,0,0,'0',0,0  
	END
	ELSE
	BEGIN
		EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Salary_Cycle_id,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@constraint	-- Changed By Gadriwala 11092013
	END
	 
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	Declare @strHoliday_Date As Varchar(max)
	Declare @StrWeekoff_Date  varchar(max)
	
	DECLARE @Is_Consider_LWP_In_Same_Month tinyint -- Added by Hardik 19/02/2019 for Havmor
	Set @Is_Consider_LWP_In_Same_Month = 0
	
	SELECT @Is_Consider_LWP_In_Same_Month = ISNULL(Setting_Value,0) 
	FROM T0040_SETTING WITH (NOLOCK)
	WHERE Setting_Name = 'Consider LWP in Same Month for Cutoff Salary' And Cmp_Id = @Cmp_Id

	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 37 - ( @Date_Diff)                   --- Changes from 36 to 37 by mihir adeshara 07062012
	set @New_To_Date = dateadd(d,@date_diff,@To_Date)
	Set @StrHoliday_Date = ''      
	set @StrWeekoff_Date = ''
	

	
	If OBJECT_ID('tempdb..##Att_Muster1') IS NULL 
		Begin
			 CREATE table ##Att_Muster1
			  (
					Emp_Id		numeric , 
					Cmp_ID		numeric,			 
					Leave_Count	numeric(5,1) default 0,
					WO	numeric(5,1) default 0,
					HO	numeric(5,1) default 0,
					Total_cycle_days numeric(18,0),
					Total_Present numeric(18,2)
			  )
		end

	CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )  

	CREATE table #Emp_Weekoff
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			W_Day		numeric(3,1)
	  )	  
	 

	 
	insert into ##Att_Muster1 (Emp_ID,Cmp_ID)
	SELECT Emp_id  , @Cmp_ID  from #Emp_Cons
	
	Declare @Month_St_Date datetime
	declare @Month_End_Date datetime

	set @Month_St_Date = @From_Date
	set @Month_End_Date = @To_Date


	declare @is_salary_cycle_emp_wise as tinyint -- added by Gadriwala 07102013
	set @is_salary_cycle_emp_wise = 0
    select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'
		
	Declare cur_emp cursor for 
		select Emp_ID From #Emp_Cons 
	open cur_emp
	fetch next from Cur_Emp into @Emp_ID 
	while @@fetch_Status = 0
		begin 
			Declare @Sal_St_Date   Datetime   
			Declare @Sal_End_Date   Datetime   
			declare @OutOf_Days numeric(18,2)
			Declare @leave_count as numeric(18,2)
			
			Declare @Is_Left as varchar
			Declare @Join_Date as datetime
			declare @Left_Date as datetime
			
			--Added by Hardik 23/01/2014 as Kataria has Presentday Problem
			set @From_Date = @Month_St_Date  
			set @To_Date = @Month_End_Date 
			
			-- added by mitesh for checking join / left date and set working days accordinly START
			select @Is_Left = Emp_Left , @Join_Date = isnull(Date_Of_Join,@from_date) , @Left_Date = isnull(Emp_Left_Date,@to_date)  
			from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
			
			
			if upper(@is_left) = 'Y'	
				Begin
					if @Left_Date < @To_date
						BEGIN
							set @to_date = @left_date
						END						
				End
			else
				Begin
					if @Join_date > @from_Date
						BEGIN	
							set @From_Date = @Join_Date
						END
				End
			-- added by mitesh for checking join / left date and set working days accordinly END
			
			 
			
			declare @manual_salary_Period as numeric(18,0)-- Comment and added By rohit on 11022013
			
			--set @Month_St_Date = @From_Date
			--set @Month_End_Date = @To_Date
			Set @leave_count = 0
			set @OutOf_Days = datediff(d,@From_Date,@To_date) + 1
			
			
			select 	@Branch_ID = Branch_ID From dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
			Where I.Emp_ID = @Emp_ID
			
		 
			select @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0) ,@Sal_St_Date  =Sal_st_Date 
			,@manual_salary_Period= isnull(manual_salary_Period ,0) 
			from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
			and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
			
			--Added By Gadriwala 08102013 - Start Referance SP P0200_MONTHLY_SALARY_GENERATE_PRORATA
		    
		    if @is_salary_cycle_emp_wise = 1
			begin
				
				declare @Salary_Cycle_id_0 as numeric
				set @Salary_Cycle_id_0  = 0
			
				SELECT @Salary_Cycle_id_0 = salDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where emp_id = @Emp_Id AND effective_date =
				(SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle  WITH (NOLOCK)
				where emp_id = @Emp_Id AND effective_date <=  @Month_End_Date
				GROUP by emp_id)
				
				SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id_0	
				
			end
		    else
				begin
					 If @Branch_ID is null
					 Begin 
						select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
						  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
						  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)    
					 End
					Else
					Begin
						select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
						  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
						  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
					End 
				end	
				
		--Added By Gadriwala 08102013 - End

		
			if isnull(@Sal_St_Date,'') = ''    
			begin    
			   set @From_Date  = @Month_St_Date     
			   set @To_Date = @Month_End_Date    
			   set @OutOf_Days = @OutOf_Days
			end     
			else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
			begin    
			   set @From_Date  = @Month_St_Date     
			   set @To_Date = @Month_End_Date    
			   set @OutOf_Days = @OutOf_Days    	         
			end     
			else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
			   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			   --set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
			   
			   --Set @Month_St_Date = @Sal_St_Date
			   --Set @Month_End_Date = @Sal_End_Date    
			   if @manual_salary_Period =0 
					begin    
					   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)    
					   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
					   set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					   
					   --Set @Month_St_Date = @Sal_St_Date	--Comment by ankit on 25042013
					   --Set @Month_End_Date = @Sal_End_Date    
					   Set @From_Date = @Sal_St_Date
					   Set @To_Date = @Sal_End_Date 
					end
				Else
					begin
						select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
						Set @From_Date = @Sal_St_Date
					    Set @To_Date = @Sal_End_Date    
						 set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1
					End	
					
			end
			
			if upper(@is_left) = 'Y'	
				Begin
					if @Left_Date < @To_date
						BEGIN
							set @to_date = @left_date
						END						
				End
			else
				Begin
					if @Join_date > @from_Date
						BEGIN	
							set @From_Date = @Join_Date
						END
				End
				
			  set @OutOf_Days = datediff(d,@From_Date,@to_date) + 1
			
			--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
			--Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
			if @is_Cutoffdate =1 -- Added by rohit on 10012015
			begin
				Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
				Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,9,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
			end
			else
			begin
				Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
				Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
			end
		
			
			
			--select @leave_count  = isnull(sum(isnull(CASE WHEN Apply_Hourly = 0 THEN Leave_Used  ELSE Leave_Used *0.125 END,0)) + sum(isnull(CompOff_Used,0)),0)  -- Changed By Gadriwala 01102014
			--from dbo.T0140_LEAVE_TRANSACTION LT
			--inner join T0040_LEAVE_MASTER LM
			--on LT.Leave_ID = LM.Leave_ID 			
			--where For_Date >= @From_Date and For_Date <= @To_Date and isnull(Lt.Leave_Encash_Days,0) = 0 and Emp_ID = @Emp_ID
			
			--Changed by Gadriwala 01012015 - Start
			-- For Regular Leave
			if @is_Cutoffdate <> 1
			begin
			
			select @leave_count  = isnull(sum(isnull(CASE WHEN Apply_Hourly = 0 THEN Leave_Used   ELSE Leave_Used *0.125 END,0)),0) 
			from dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
			Inner join dbo.T0040_Leave_Master LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(Leave_Used,0) > 0))) and isnull(LM.Default_Short_Name,'') <> 'COMP'
			where For_Date >= @From_Date and For_Date <= @To_Date 
					and Emp_ID = @Emp_ID 
					
			-- For CompOFf Leave
			select @leave_count  = @leave_count +   isnull(sum(isnull(CASE WHEN Apply_Hourly = 0 THEN case when CompOff_Used >= Leave_Encash_Days then CompOff_Used - Leave_Encash_Days else CompOff_Used end ELSE case when CompOff_Used >= Leave_Encash_Days then (CompOff_Used - Leave_Encash_Days) * 0.125 Else CompOff_Used * 0.125 End END,0)),0) 
			from dbo.T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
			Inner join dbo.T0040_Leave_Master LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
			or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(CompOff_Used,0) > 0))) and isnull(LM.Default_Short_Name,'') = 'COMP'
			where For_Date >= @From_Date and For_Date <= @To_Date 
					and Emp_ID = @Emp_ID 
			end
			ELSE IF @Is_Cutoffdate = 1 And @Is_Consider_LWP_In_Same_Month = 1 -- Added Condition by Hardik 19/02/2019 for Havmor
				BEGIN
					INSERT INTO #LWP_LEAVE_AFTER_CUTOFF 
						(Emp_Id, Leave_Approval_Id, Leave_Id, Leave_Period, For_Date)
					SELECT LT.Emp_ID, Leave_Approval_ID, LT.Leave_ID, LT.Leave_Used, LT.For_Date
					From T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
						INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON LT.LEAVE_ID=L.LEAVE_ID
						INNER JOIN (SELECT	 LAD.Leave_Approval_ID, LA.Emp_ID,LAD.Leave_Assign_As, LAD.From_Date,LAD.To_Date, LAD.Leave_Period
									FROM	T0120_LEAVE_APPROVAL LA  WITH (NOLOCK)
									INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
									WHERE	LA.Emp_ID=@EMP_ID And LA.Approval_Status = 'A') A ON LT.EMP_ID=A.EMP_ID AND LT.FOR_DATE BETWEEN A.FROM_DATE AND A.TO_DATE
					Where LT.For_Date BETWEEN @From_Date And @To_Date And LT.Emp_ID = @Emp_ID And L.Leave_Paid_Unpaid = 'U'	
					
					DELETE #Emp_Weekoff WHERE FOR_DATE IN (SELECT FOR_DATE FROM #LWP_LEAVE_AFTER_CUTOFF) -- ADDED BY HARDIK 02/12/2020 FOR UNISON AS THEY HAVE FULL MONTH ABSENT AND AFTER CUTOFF ENTERED LWP LEAVE.. SO WEEKOFF SHOULD NOT COUNT FOR LWP LEAVE

					Select @leave_count = Sum(Leave_Period) From #LWP_LEAVE_AFTER_CUTOFF Where Emp_Id = @Emp_Id
				END
			
			--Changed by Gadriwala 01012015 - End	
			update ##Att_Muster1 SET Leave_Count = @leave_count,Total_cycle_days = @OutOf_Days  where Emp_ID = @Emp_ID
			
		 	set @Emp_ID=0
		 
			fetch next from Cur_Emp into @Emp_ID 			
		end 
	close cur_Emp
	Deallocate cur_Emp
	

			
	Update ##Att_Muster1 
	set HO = eh.H_Day
	From ##Att_Muster1 AM inner join (SELECT sum(H_Day) H_Day,emp_id FROM #Emp_Holiday group by emp_id) as eh on am.emp_ID = eh.emp_ID 
	
	Update ##Att_Muster1 
	set  WO =  ew.W_Day
	From ##Att_Muster1   AM inner join (SELECT sum(W_Day) W_Day,emp_id FROM #Emp_Weekoff group by emp_id) as ew on am.emp_ID = ew.emp_ID  
	and W_Day > 0
		
	update ##Att_Muster1 SET Total_Present = (isnull(Total_cycle_days ,0) - (isnull(leave_count,0) + isnull(HO,0) + isnull(WO,0)  ) )  
	
	--select * from ##Att_Muster1 order by emp_id
	
	
			
	RETURN
