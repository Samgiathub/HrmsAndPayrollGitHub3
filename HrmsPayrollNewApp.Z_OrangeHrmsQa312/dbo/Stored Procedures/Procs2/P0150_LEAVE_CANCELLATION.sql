---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_LEAVE_CANCELLATION]    
    @Tran_id numeric(12,0) output,
    @Cmp_id numeric(18,0),
    @Emp_id numeric(18,0),
	@Leave_Approval_id numeric(12,0),
	@For_date datetime,
	@Leave_period numeric(18,2),
	@Is_Approve tinyint,
	@Leave_id numeric(12,0),
	@Request_Date datetime,
    @tran_type  char(1)    ,
    @Comment nvarchar(200),
    @MComment nvarchar(200) = '',
    @AEmp_id numeric(18,0) = 0,
    @Day_Type varchar(100) = '',
    @Actual_Leave_period numeric(18,2),
    @Compoff_Work_Date varchar(200) = '',   --Added By Jaina 25-11-2015
    @User_Id numeric(18,0) = 0,  --Mukti(02072016)
    @IP_Address varchar(30)= '', --Mukti(02072016)
    @Backdated_Cancel tinyint = 0    --Added By Jaina 05-08-2016
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Added By Mukti(start)02072016
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
--Added By Mukti(end)02072016
	declare @Leave_Message as varchar(100)  --Added Bt Jaina 19-07-2016
	set @Leave_Message = ''
	
	--Added By Jaina 05-08-2016
		Declare @PDay as Numeric(18,2)
		DECLARE @Call_For_Leave_Cancel numeric(18,2)
		Declare @Used_Leave numeric(18,2)
		set @Used_Leave = 0
		set @Call_For_Leave_Cancel = 0
		set @PDay = 0
		
		CREATE TABLE #Data     
		(     
			Emp_Id     numeric ,     
			For_date   datetime,    
			Duration_in_sec  numeric,    
			Shift_ID   numeric ,    
			Shift_Type   numeric ,    
			Emp_OT    numeric ,    
			Emp_OT_min_Limit numeric,    
			Emp_OT_max_Limit numeric,    
			P_days    numeric(12,2) default 0,    
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
			Out_time datetime default null,
			Shift_End_Time datetime,			--Ankit 16112013
			OT_End_Time numeric default 0,	--Ankit 16112013
			Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
			Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
			GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		)  

	if @tran_type = 'I'	
		begin
		
			declare @Branch_ID as numeric(18,0)
			set @Branch_ID = 0	
		
			select  @Branch_ID = Branch_ID
				From T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)      --Changed by Hardik 10/09/2014 for Same Date Increment
				 where Increment_Effective_date <= @For_date    
				 and Cmp_ID = @Cmp_ID    
				 group by emp_ID) Qry on    
				 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
			  Where I.Emp_ID = @Emp_ID  
			  
	
			--IF  exists( SELECT 1 FROM T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_id and For_date = @For_date and Emp_id = @Emp_id and Day_type = @Day_Type)
			--	begin
			--			Raiserror('Already Exists',16,2)
			--			return -1		
			--	end
			-- Jainith Patel On 20_12_2012 For If Cancellation App Exists then don't Insert it Second Time S	
			--IF  exists( SELECT 1 FROM T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_id and For_date = @For_date and Emp_id = @Emp_id)
			--	begin
			--			Raiserror('Already Exists',16,2)
			--			return -1		
			--	end
			
			-- Added By Ali 10012014 -- Start
			Declare @cnt numeric
			Set @cnt = 0
			Set @cnt = (SELECT COUNT(1) FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK) where Cmp_Id = @Cmp_id and For_date = @For_date and Emp_id = @Emp_id)
			IF @cnt >=2
			BEGIN
				Raiserror('@@Already Exists@@',16,2)
				return -1	
			END
			-- Added By Ali 10012014 -- End

				 -- Added By Sajid and Deepal for IFSA 30-12-2021
			 Declare @Setting_Value INT = 0
			 Select @Setting_Value= Setting_Value From T0040_SETTING  WITH (NOLOCK) 
			 Where Setting_Name='This Months Salary Exists Validation If Salary Geneated.' and Cmp_ID=@cmp_Id
			 if (@Setting_Value = 0)
			 BEGIN
			
			
			-- Comment and Add by rohit For Salary Period 26-25 on 22072013		
			-- Jainith Patel On 20_12_2012 For If Cancellation App Exists then don't Insert it Second Time E	
			--IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE EMP_ID = @EMP_ID AND  month(Month_End_Date) = MONTH(@For_date) and year(Month_End_Date) = year(@For_date))
			--	Begin
			--		Raiserror('Month salary Exists',16,2)
			--		return -1
			--	End
		
			--Comment By Jaina 05-08-2016
			--IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE EMP_ID = @EMP_ID AND  Month_St_Date <=@For_date and isnull(Cutoff_Date,Month_End_Date) >= @For_date) --Added cutoffdate isnull condition for Leave cancellation application 17112015
			--	Begin
			--		Raiserror('Month salary Exists',16,2)
			--		return -1
			--	End
			-- Ended by rohit on 22072013
			
			--Added By Jaina 05-08-2016
			--SELECT EMP_ID,Month_St_Date,Month_End_Date,Cutoff_Date FROM  T0200_MONTHLY_SALARY WHERE EMP_ID = @EMP_ID AND  Month_St_Date <=@For_date and isnull(Cutoff_Date,Month_End_Date) >= @For_date
				IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND  Month_St_Date <=@For_date and isnull(Cutoff_Date,Month_End_Date) >= @For_date) --Added cutoffdate isnull condition for Leave cancellation application 17112015
				Begin
						set @Call_For_Leave_Cancel = 1
						Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@For_date,@For_date,0,0,0,0,0,0,@Emp_id,'',4,@Call_For_Leave_Cancel = @Call_For_Leave_Cancel
						
						select @PDay = P_days from #Data where Emp_Id = @Emp_id
								
						if @PDay <> 0
						BEGIN
								set @Backdated_Cancel = 1
								select @Used_Leave = Leave_period from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Emp_Id = @Emp_id AND For_date = @For_date
								IF @Used_Leave <> @PDay
								Begin
									if @Leave_period > @PDay
									Begin
										set @Leave_Message = 'You can apply for ' + CONVERT(varchar,@PDay) + ' Day'
										Raiserror(@Leave_Message ,16,2)
										return -1
									END
								END
								ELSE
								Begin
									Raiserror('@@Leave Cannot be cancelled. Salary already generated and there is no attendance history exist@@' ,16,2)
									return -1
								END
							End
						ELSE
							BEGIN
							--add @@ by chetan 040817 for showing only error message not warning message
									Raiserror('@@Monthly salary Exists@@',16,2)
									return -1
							END
				
				End
				END
				--Added By Jaina 05-08-2016 End


			-- Added by Hardik 27/02/2019 for Havmor
			IF EXISTS(SELECT 1 FROM T0210_LWP_Considered_Same_Salary_Cutoff WITH (NOLOCK) WHERE Emp_Id = @Emp_Id And For_Date = @For_Date)
				BEGIN
					Raiserror('@@Monthly salary Exists@@',16,2)
					return -1
				END
				
			IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE MONTH =  MONTH(@For_date) and YEAR =  year(@For_date) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))
				Begin
					Raiserror('@@Month Lock@@',16,2)
					return -1
				End
			
			--Added By Jaina 24-11-2015 (If Next Month Salary Generated After that Previous month Leave can't cancel.)
			if Exists(SELECT * FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_id and MONTH(Month_End_Date) = (MONTH(Month_End_Date)+1) )
			BEGIN
				Raiserror('@@Leave Can''t Cancel,Next Month Salary Exits@@',16,2)
				return -1
				
			END	
			
			
			select @Tran_id = isnull(max(Tran_id),0)+ 1  from dbo.T0150_LEAVE_CANCELLATION WITH (NOLOCK)
			
				
			INSERT INTO T0150_LEAVE_CANCELLATION
							  (Tran_id,Cmp_Id,Emp_id, Leave_Approval_id, For_date, Leave_period, Is_Approve, Request_Date,leave_id,Comment,day_type,Actual_Leave_Day,Compoff_Work_Date,Backdated_Cancel)  --Change By Jaina 26-11-2015
			VALUES     (@Tran_id,@Cmp_id,@Emp_id, @Leave_Approval_id, @For_date, @Leave_period, @Is_Approve, @Request_Date,@Leave_id,@Comment,@Day_Type,@Actual_Leave_period,@Compoff_Work_Date,@Backdated_Cancel)  --Change By Jaina 05-08-2016
		
			--Added By Mukti(start)02072016									
					exec P9999_Audit_get @table = 'T0150_LEAVE_CANCELLATION' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti(end)02072016
			
		end
	else if @tran_type = 'U'
		begin	
		
			IF  exists( SELECT 1 FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK) where For_date = @For_date and Emp_id = @Emp_id and Leave_Approval_id = @Leave_Approval_id and Is_Approve = 1 and Day_type = @Day_Type)
				begin
						Raiserror('@@Already Approved@@',16,2)
						return -1		
				end
			Else
			   begin
			--Added By Mukti(start)02072016	
				exec P9999_Audit_get @table='T0150_LEAVE_CANCELLATION' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti(end)02072016
			
			      update T0150_LEAVE_CANCELLATION 
				   set Is_Approve  = 1 ,
					MComment = @MComment,
					A_Emp_id = @AEmp_id,
					Day_Type = @Day_Type,
					Leave_period = @Leave_period,
					Compoff_Work_Date = @Compoff_Work_Date
			      where  Tran_id = @Tran_id
			      
			      --Added By Jaina 25-11-2015 Start ( For Comp off Leave Cancellation)
			      
						--SET @Compoff_Work_Date = NULL;
						
				DECLARE @Comp_Date datetime
				DECLARE @Leaveday numeric(18,2)
				Declare @Leaveid numeric
				
				DECLARE @Compoff_Credit as numeric(18,2)
				DECLARE @Compoff_Debit as  numeric (18,2)
				DECLARE @Compoff_Balance  as numeric (18,2)
				DECLARE @Compoff_Used as  numeric(18,2)	
				
				DECLARE @CANCEL_DAY NUMERIC(18,2);
				  --IF (@Compoff_Work_Date <> '1900-01-01') 
				  IF (@Compoff_Work_Date <> '') 
				  Begin
					
					declare @compOff_Date varchar(max)
					
					
					select @compOff_Date =Compoff_Work_Date, @Leave_id = Leave_id From T0150_LEAVE_CANCELLATION WITH (NOLOCK) where  Tran_id=@Tran_id
					
					
					IF OBJECT_ID('tempdb..#Comp_temp') IS NULL
					CREATE table #Comp_temp
					(
						comp_Date varchar(max),
						Leaveday varchar(max)
					)
					Insert into #Comp_temp (comp_Date,Leaveday)
					Select Cast(Left(DATA, 11) AS datetime) As comp_Date, Cast(RIGHT(DATA, LEN(DATA) - 12) AS numeric(18,2)) As LeaveDay
					From dbo.Split(@compOff_Date, '#') T
					
					
					
					SELECT @Comp_Date =comp_Date, @Leaveday= Leaveday FROM #Comp_temp
					
					DECLARE Cursor_date_t cursor for		
							Select Cast(Left(DATA, 11) AS datetime) As comp_Date, Cast(RIGHT(DATA, LEN(DATA) - 12) AS numeric(18,2)) As LeaveDay
							From dbo.Split(@compOff_Date, '#') T
					OPEN Cursor_date_t 					
							Fetch next from Cursor_date_t into @Comp_Date,@Leaveday
											 
					While @@fetch_status = 0                    
					Begin 
	
						SELECT   @Compoff_Credit=Compoff_Credit,
								 @Compoff_Debit=CompOff_Debit,
								 @Compoff_Balance =CompOff_Balance,
								 @Compoff_Used =CompOff_Used 
						FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_id AND For_Date=@Comp_Date AND Leave_ID=@Leave_id
						
						
						SELECT  @Compoff_Used =CompOff_Used
						FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@Emp_id AND For_Date=@For_date AND Leave_ID=@Leave_id
						
						
						--IF @Day_Type = 'Full Day'
						--Begin
						--	SET @CANCEL_DAY = 1
						--End
						--ElSE 
						--Begin
						--	SET @CANCEL_DAY = 0.5
						--End

						SET @Compoff_Debit = @Compoff_Debit-@Leaveday
						
						
						UPDATE T0140_LEAVE_TRANSACTION
						 SET  --CompOff_Credit = @Compoff_Credit,
							  CompOff_Debit = @Compoff_Debit,
							  CompOff_Balance = @Compoff_Balance + @Leaveday
						WHERE For_Date=@Comp_Date AND Emp_ID=@Emp_id AND Leave_ID=@Leave_id
						
						--select * from T0140_LEAVE_TRANSACTION WHERE Emp_ID=14771 AND For_Date=@Comp_Date							
						
						
						UPDATE T0140_LEAVE_TRANSACTION
						 SET  CompOff_Used = @Compoff_Used - @Leaveday
						WHERE For_Date=@For_date AND Emp_ID=@Emp_id AND Leave_ID=@Leave_id--and Leave_ID = @Leaveid
						
						
						fetch next from Cursor_date_t into @Comp_Date,@Leaveday	
					End
				Close Cursor_date_t                    
				Deallocate Cursor_date_t
				  End
				  
				--Added By Jaina 25-11-2015 End
				
			      --emp_id = @Emp_id
			      --and For_date = @For_date
			      --and Leave_Approval_id = @Leave_Approval_id
			      --and Leave_id = @Leave_id
			      --and
			      
			      --Added By Mukti(start)02072016	
					exec P9999_Audit_get @table = 'T0150_LEAVE_CANCELLATION' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				--Added By Mukti(end)02072016	
				
			  end
		end 
	else if @tran_type = 'D'
		begin
			if @Is_Approve = 0
				begin
					IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE MONTH =  MONTH(@For_date) and YEAR =  year(@For_date) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))
						Begin
							Raiserror('@@Month Lock@@',16,2)
							return -1
						End
				end
			
		
			
			-- Jainith Patel On 20_12_2012 For Leave Appliction Exist then don't Remove E
			
			--Added By Jaina 30-11-2015
			if EXISTS (SELECT 1 from T0040_LEAVE_MASTER as L WITH (NOLOCK) inner join T0140_LEAVE_TRANSACTION as LT WITH (NOLOCK) on L.Leave_Id=LT.Leave_ID where LT.Leave_ID = @Leave_Id AND L.Default_Short_Name='COMP')
			BEGIN
				PRINT 1	
			End 
			ELSE
			Begin
			
				-- Jainith Patel On 20_12_2012 For Leave Appliction Exist then don't Remove S
			--IF EXISTS(select LA1.Leave_Application_ID from  dbo.T0110_Leave_Application_Detail LAD1 inner join
			--			T0100_LEAVE_APPLICATION LA1 ON LAD1.Leave_Application_ID = LA1.Leave_Application_ID  
			--			left outer join T0120_leave_Approval LP1 ON LP1.Leave_Application_ID = LA1.Leave_Application_ID  
			--			left outer join dbo.T0130_Leave_Approval_Detail LAPD1 ON LAPD1.Leave_Approval_ID = LP1.Leave_Approval_ID  
			--			left outer join dbo.T0150_LEAVE_CANCELLATION LC1 ON LC1.Leave_Approval_ID = LP1.Leave_Approval_ID 
			--  where  LA1.cmp_id=@CMP_ID and LA1.Emp_ID = @Emp_id  
			--	 and isnull(Tran_id,0) <> @Tran_id and isnull(LC1.Leave_Approval_ID,0) <> @Leave_Approval_id
			--	 and (LAD1.To_Date >= @For_date and LAD1.From_Date <= @For_date))
			IF EXISTS(select LA1.Leave_Application_ID from  dbo.T0110_Leave_Application_Detail LAD1 WITH (NOLOCK) inner join
						T0100_LEAVE_APPLICATION LA1 WITH (NOLOCK) ON LAD1.Leave_Application_ID = LA1.Leave_Application_ID  
						left outer join T0120_leave_Approval LP1 WITH (NOLOCK) ON LP1.Leave_Application_ID = LA1.Leave_Application_ID  
						left outer join dbo.T0130_Leave_Approval_Detail LAPD1 WITH (NOLOCK) ON LAPD1.Leave_Approval_ID = LP1.Leave_Approval_ID  
						left outer join dbo.T0150_LEAVE_CANCELLATION LC1 WITH (NOLOCK) ON LC1.Leave_Approval_ID = LP1.Leave_Approval_ID 
			  where  LA1.cmp_id=@CMP_ID and LA1.Emp_ID = @Emp_id  
				 and isnull(Tran_id,0) <> @Tran_id and isnull(LP1.Leave_Approval_ID,0) <> @Leave_Approval_id and LC1.Leave_Approval_ID IS NULL
				 and (LAD1.To_Date >= @For_date and LAD1.From_Date <= @For_date)
				 AND (LAPD1.Leave_Assign_As <> LC1.Day_type OR LAD1.Leave_Assign_As <> LC1.Day_type)) --Above Commented by Sumit and also did changes on 29122016
			Begin
				
						Raiserror('@@Some Leave can''t be Deleted@@',16,2) --Change msg as per sandip bhai's suggestions on 29122016
						return -1
			End
			
			declare @Daytype as varchar(25)
			select @Daytype=Day_Type from T0150_LEAVE_CANCELLATION WITH (NOLOCK) WHERE Cmp_Id=@Cmp_id AND Emp_Id=@Emp_id AND Tran_id=@Tran_id
			
			if Exists(select 1 from T0130_Leave_Approval_Detail LAD WITH (NOLOCK)
			inner join T0120_leave_Approval La WITH (NOLOCK) on La.Leave_Approval_ID=LAD.Leave_Approval_ID 
			left JOIN T0150_LEAVE_CANCELLATION lc WITH (NOLOCK) ON lc.Emp_Id=LA.Emp_ID and lc.Leave_Approval_id=LA.Leave_Approval_ID  and lad.From_Date <= lc.For_date and LAD.To_Date >= lc.For_date 
			where (lad.Leave_Assign_As =@Daytype or lad.Leave_Assign_As ='Full Day')  and lc.Cmp_Id=@Cmp_id and la.Leave_Approval_ID = @Leave_Approval_id
			and isnull(lc.Cmp_Id,0)=0
			)
			BEGIN
					Raiserror('@@Leave Can''t Deleted,Same Date leave already approval@@',16,2)
					return -2
			End  --Added by Sumit on 27122016 Need to Check Cases
			
												
			if Exists(select 1 from T0130_Leave_Approval_Detail LAD WITH (NOLOCK)
						inner join T0120_leave_Approval La WITH (NOLOCK) on La.Leave_Approval_ID=LAD.Leave_Approval_ID 
						left JOIN T0150_LEAVE_CANCELLATION lc WITH (NOLOCK) ON lc.Emp_Id=LA.Emp_ID and lc.Leave_Approval_id=LA.Leave_Approval_ID  and lad.From_Date <= lc.For_date and LAD.To_Date >= lc.For_date 						
						where  LA.cmp_id=@CMP_ID and LA.Emp_ID = @Emp_id  
						and isnull(Tran_id,0) <> @Tran_id and isnull(LC.Leave_Approval_ID,0) <> @Leave_Approval_id
						and (LAD.To_Date >= @For_date and LAD.From_Date <= @For_date) 
						and lc.Is_Approve =0  --Change condition by Jaina 27-02-2017 
					 )
			BEGIN
									
					Raiserror('@@Leave Can''t Deleted, Same Date leave already applied@@',16,2)
					return -2
			End  -- Added this condition to check leave approval is not exists on same date when leave cancellation was there -- Sumit on 29122016
			
			--Comment By Jaina 05-08-2016 (In Leave Cancellation Status Form, When try to delete 0.5 leave, it will can't delete it because of this validation.)
			--if Exists(SELECT 1 FROM T0140_LEAVE_TRANSACTION where Emp_ID = @Emp_id AND For_Date = @For_date and Cmp_ID = @CMP_ID and (Isnull(Leave_Used,0)>0 or ISNULL(CompOff_Used,0) > 0)  )
			--BEGIN
					
			--		Raiserror('Leave Can''t Deleted,Same Date leave already approval',16,2)
			--		return -2
			--End 
			
			
			END	
			--Added By Mukti(start)02072016	
				exec P9999_Audit_get @table='T0150_LEAVE_CANCELLATION' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti(end)02072016
		
			Declare @L_Type varchar(50)
			select @L_Type = Day_type,@Leave_Period = Leave_period from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where Emp_Id=@Emp_id and Tran_id = @Tran_id 
				
			exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@For_date,@To_Date=@For_date,@Leave_Period=@Leave_Period,@Leave_Application_ID=0,@Leave_Assign_As=@L_Type,@Half_Leave_Date=NULL
			
			delete T0150_LEAVE_CANCELLATION 				
			where emp_id = @Emp_id
			and Tran_id = @Tran_id
			
			
		
		end	
     exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Leave Cancellation',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  --Mukti(02072016)
 RETURN    


