---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_MONTHLY_PRESENT_IMPORT]
	@Cmp_ID		numeric ,
	@Emp_Code	varchar(50),
	@Month		int,
	@Year		int,
	@P_Days		numeric(18,2),
	@Extra_days	numeric(18,2),
	@Extra_day_Month	numeric(18,2),
	@Extra_day_Year	numeric(18,2),
	@Cancel_Weekoff_Day numeric(18,2),
	@Cancel_Holiday numeric(18,2),
	@Over_Time numeric(18,2) =0,
	@Payable_Amount numeric(18,2)  = 0,
	@Leave_Approval_id numeric(18,0)  = 0,
	@Backdated_Leave_Days numeric(18,2) = 0, -- Added by Hardik 02/09/2014
	@Flag			char ='I' ,-- Added by rohit on 01112014
	@WO_OT_Hours	numeric(18,2) = 0 ,	--Jimit 06012015
	@HO_OT_Hours	numeric(18,2) = 0 ,	--Jimit 06012015
	@Tran_Id		NUMERIC =0, --Added By Mukti 19012015
	@Log_Status		Int = 0 Output,	--Nilesh Patel on 14032016
	@Present_on_holiday	numeric(18,2) = 0,
	@GUID Varchar(2000) = '' --Added by nilesh Patel on 15062016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Declare @Tran_ID	numeric
	Declare @Emp_ID		numeric
	Declare @For_Date	Datetime
	
	---UnComment Below 2 Lines FOR AIA, Backdated Leave Arear not given.. So Fix Make it 0.. by Hardik 07/03/2018
	--Set @Leave_Approval_id=0
	--Set @Backdated_Leave_Days = 0

		
	Declare @Apply_Hourly as tinyint
	Declare @Leave_Assign_As as varchar(30)
		Declare @Leave_Paid_Unpaid as varchar(1)
	Set @Apply_Hourly = 0
	Set @Leave_Assign_As = ''
	set @Leave_Paid_Unpaid = ''
	
	if @P_Days Is Null
		Begin
			Set @P_Days = 0
		End
		
	if @Extra_days Is Null
		Begin
			Set @Extra_days = 0
		End
	
	if @Extra_day_Month Is Null
		Begin
			Set @Extra_day_Month = 0
		End
	
	if @Extra_day_Year Is Null
		Begin
			Set @Extra_day_Year = 0
		End
	
	if @Cancel_Weekoff_Day Is Null
		Begin
			Set @Cancel_Weekoff_Day = 0
		End
	
	if @Cancel_Holiday Is Null
		Begin
			Set @Cancel_Holiday = 0
		End
	
	--if @Emp_Code = '' or @Month =0 or @Month > 12 or @Year < 2000
	--	Begin 
	--		set @Log_Status = 1
	--		return
	--	End
		

	if @Flag='A'
	begin
		set @Emp_ID = @Emp_Code
	end
	else
	begin
		select @Emp_ID = Emp_ID from T0080_Emp_Master e WITH (NOLOCK) where Cmp_ID =@Cmp_ID  and Alpha_Emp_Code = @Emp_Code
	end
	
	if @Emp_ID is null
		Begin
			Set @Emp_ID = 0
		End
		
	if @Emp_ID = 0 
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE,'Enter proper Employee Code',GetDate(),'Monthly Present',@GUID)			
			RETURN
		End
	
	if @Month = 0
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Month Details Doesn''t exists',@EMP_CODE,'Enter proper Month Details',GetDate(),'Monthly Present',@GUID)			
			RETURN
		End

	if @Year = 0
		Begin
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Year Details Doesn''t exists',@EMP_CODE,'Enter proper Year Details',GetDate(),'Monthly Present',@GUID)			
			RETURN
		End
		
		--Added by ronakk 13042023
		if @Extra_day_Month <> 0 and @Extra_day_Year <> 0
		Begin
		
				--Added by ronakk 23032023 for Bug #4287
				Declare @DateofJoin datetime
				select @DateofJoin =  Date_Of_Join from T0080_EMP_MASTER where Emp_ID=@Emp_ID
				If year(@DateofJoin) > @Extra_day_Year
				Begin

					INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Arear days not allowed before joining date.',@EMP_CODE,'Enter proper extra year and month Details',GetDate(),'Monthly Present',@GUID)			
					RETURN

				End
				else if month(@DateofJoin) > @Extra_day_Month
				Begin
				  
					 INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Arear days not allowed before joining date.',@EMP_CODE,'Enter proper extra year and month Details',GetDate(),'Monthly Present',@GUID)			
					 RETURN

				End
				--End by ronakk 23032023 for Bug #4287

		
		End
		--End by ronakk 13042023
		
	select @For_Date = dbo.GET_MONTH_END_DATE(@Month,@Year)

	if @Emp_ID =0	
		Begin 
			set @Log_Status = 1
			return
		End
		
	if (exists(select 1 from t0200_monthly_salary WITH (NOLOCK) where emp_id=@emp_id and month(Month_End_Date) =@Month and 
				year(Month_End_Date) =@Year) and IsNull(@Leave_Approval_id,0) = 0) --Added By Mukti 19012015 if salary exist than not update
		begin
			set @Log_Status = 1
			INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@EMP_CODE ,'Same month Salary exists',@EMP_CODE,'Same month Salary exists',GetDate(),'Monthly Present',@GUID)			
			return
		end
		
	if exists (Select Emp_ID From T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND 
										MONTH =@MONTH AND YEAR =@YEAR )
			BEGIN
			Select @Tran_ID = Tran_ID From T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND 
										MONTH =@MONTH AND YEAR =@YEAR
							
							Select @Apply_Hourly = ISNULL(L.Apply_Hourly,0),@Leave_Assign_As=lad.Leave_Assign_As , @Leave_Paid_Unpaid = Leave_Paid_Unpaid
							From T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) Inner Join T0040_LEAVE_MASTER L WITH (NOLOCK) on LAD.Leave_ID = L.Leave_ID
							Where Leave_Approval_ID = @Leave_Approval_ID
							
							--if @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'
							if @apply_hourly = 1 or @Leave_Assign_As = 'Part Day'  --changed By Jimit as Bug No 8662
								BEGIN
									set @Backdated_Leave_Days= @Backdated_Leave_Days * 0.125
								END										
										
				--Changed from Bottom to Up by Ramiz on 25/05/2015---
				IF EXISTS(SELECT 1 FROM T0140_BACK_DATED_ARREAR_LEAVE WITH (NOLOCK) WHERE Leave_approval_id=@Leave_Approval_id)
					DELETE FROM T0140_BACK_DATED_ARREAR_LEAVE WHERE Leave_approval_id=@Leave_Approval_id AND Emp_id=@Emp_ID
														
				IF @Backdated_Leave_Days > 0 And isnull(@Leave_Approval_id,0) > 0 And @Leave_Paid_Unpaid = 'P'
					INSERT INTO T0140_BACK_DATED_ARREAR_LEAVE
						(Cmp_id, Emp_id, Leave_approval_id, Arrear_Days, Present_import_tran_id)
					VALUES     
						(@Cmp_id,@Emp_id,@Leave_approval_id,@Backdated_Leave_Days,@Tran_ID)							
			
			
				if isnull(@Leave_Approval_id,0) = 0 
					begin					
						UPDATE    T0190_MONTHLY_PRESENT_IMPORT
						SET       P_Days =@P_Days ,Extra_days =@Extra_days, Extra_Day_Month=@Extra_day_Month, 
									Extra_Day_Year = @Extra_day_Year, Cancel_Weekoff_Day = @Cancel_Weekoff_Day,
									Cancel_Holiday = @Cancel_Holiday,Over_Time=@Over_Time
									,Payble_Amount = @Payable_Amount--, Backdated_Leave_Days = @Backdated_Leave_Days
									,WO_OT_Hour = @WO_OT_Hours
									,HO_OT_Hour = @HO_OT_Hours
									,Present_on_holiday = @Present_on_holiday
						WHERE	 EMP_ID =@EMP_ID AND
								MONTH =@MONTH AND YEAR =@YEAR
								
								
					end
				else
					begin
						select @Backdated_Leave_Days = SUM(Arrear_Days) from T0140_BACK_DATED_ARREAR_LEAVE WITH (NOLOCK) where Emp_id = @Emp_id and Present_import_tran_id = @Tran_ID   --Added By Ramiz on  25/05/2015
					
						UPDATE    T0190_MONTHLY_PRESENT_IMPORT
						SET       Extra_Day_Month=@Extra_day_Month, 
									Extra_Day_Year = @Extra_day_Year, Backdated_Leave_Days = /* Backdated_Leave_Days */ + ISNULL(@Backdated_Leave_Days,0) /* Backdated_Leave_Days --Comment by Ankit Issue while add/rollback previous month Leave */
						WHERE	 EMP_ID =@EMP_ID AND
								MONTH =@MONTH AND YEAR =@YEAR
					end
					
									--,leave_approval_id = leave_approval_id + ',' +  cast(@Leave_Approval_id as NVARCHAR(10))
					 
				--INSERT INTO T0140_BACK_DATED_ARREAR_LEAVE
				--	(Cmp_id, Emp_id, Leave_approval_id, Arrear_Days, Present_import_tran_id)
				--VALUES     
				--	(@Cmp_id,@Emp_id,@Leave_approval_id,@Backdated_Leave_Days,@Tran_ID)
							
														
			
			END
	ELSE
			BEGIN
				--select @Tran_ID =isnull(max(tran_ID),0) +1 from T0190_MONTHLY_PRESENT_IMPORT -- commented by mitesh on 18022014
	--Added By Mukti(start)19012015
				if @tran_id > 0
					begin
					if not exists(select 1 from t0200_monthly_salary WITH (NOLOCK) where emp_id=@emp_id and month(Month_End_Date) =@Month and year(Month_End_Date) =@Year  )
						begin
							update T0190_MONTHLY_PRESENT_IMPORT
								set Month=@Month,Year=@Year,For_Date=@For_Date,P_days=@P_Days,
								Extra_days=@Extra_days,Extra_Day_Month=@Extra_Day_Month,Extra_Day_Year=@Extra_Day_Year,
								Cancel_Weekoff_Day=@Cancel_Weekoff_Day, Cancel_Holiday=@Cancel_Holiday,Over_Time=@Over_Time,
								Payble_Amount=@Payable_Amount,Backdated_Leave_Days=@Backdated_Leave_Days,WO_OT_Hour=@WO_OT_Hours,
								HO_OT_Hour=@HO_OT_Hours
							WHERE  EMP_ID =@EMP_ID AND Tran_Id=@Tran_Id
						end
					end
	--Added By Mukti(end)19012015
				else
					begin
							
							Select @Apply_Hourly = ISNULL(L.Apply_Hourly,0),@Leave_Assign_As=lad.Leave_Assign_As , @Leave_Paid_Unpaid = Leave_Paid_Unpaid
							From T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) Inner Join T0040_LEAVE_MASTER L WITH (NOLOCK) on LAD.Leave_ID = L.Leave_ID
							Where Leave_Approval_ID = @Leave_Approval_ID
							
							--if @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'
							if @apply_hourly = 1 or @Leave_Assign_As = 'Part Day'  --changed By Jimit as Bug No 8662
								BEGIN
									set @Backdated_Leave_Days= @Backdated_Leave_Days * 0.125
								END
					If @Leave_approval_id > 0 And @Leave_Paid_Unpaid = 'U'
								BEGIN
									Set @Leave_approval_id = 0
									Set @Backdated_Leave_Days = 0
								END
							INSERT INTO T0190_MONTHLY_PRESENT_IMPORT
								( Emp_ID, Cmp_ID, Month, Year, For_Date, P_days,Extra_days,Extra_Day_Month,Extra_Day_Year,Cancel_Weekoff_Day, Cancel_Holiday,Over_Time,Payble_Amount,Backdated_Leave_Days,WO_OT_Hour,HO_OT_Hour,Present_on_holiday)
							VALUES
								(  @Emp_ID, @Cmp_ID, @Month, @Year, @For_Date, @P_Days,@Extra_days,@Extra_Day_Month,@Extra_Day_Year,@Cancel_Weekoff_Day,@Cancel_Holiday,@Over_Time,@Payable_Amount,@Backdated_Leave_Days,@WO_OT_Hours,@HO_OT_Hours,@Present_on_holiday)	
								
							select @Tran_ID = tran_ID from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month = @Month and Year = @Year 
							
							if isnull(@Leave_Approval_id,0) > 0
								Begin
									INSERT INTO T0140_BACK_DATED_ARREAR_LEAVE
											(Cmp_id, Emp_id, Leave_approval_id, Arrear_Days, Present_import_tran_id)
									VALUES     (@Cmp_id,@Emp_id,@Leave_approval_id,@Backdated_Leave_Days,@Tran_ID)
								End				
				end
			END	
			
	-- Commented by Hardik 01/09/2020 for Iconic and Other client, they are importing 0 days as present			
	---Delete If all Field are Zero - Ankit 28062016
	--DELETE FROM T0190_MONTHLY_PRESENT_IMPORT 
	--WHERE EMP_ID =@EMP_ID AND MONTH =@MONTH AND YEAR =@YEAR
	--	AND P_Days = 0 AND Extra_Days = 0 AND Cancel_Weekoff_Day = 0 AND Cancel_Holiday = 0 
	--	AND Over_Time = 0 AND Payble_Amount = 0 AND Backdated_Leave_Days = 0 AND WO_OT_Hour = 0 AND HO_OT_Hour = 0 AND Present_on_holiday = 0
	---
	
				
	RETURN




