

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
create PROCEDURE [dbo].[P0100_LEAVE_CF_DETAIL_back_13072022]
		@Leave_CF_ID	numeric(18, 0) output
		,@Cmp_ID	    numeric(18, 0)
		,@Emp_ID	    numeric(18, 0)
		,@Leave_ID	    numeric(18, 0)
		,@CF_For_Date	datetime
		,@CF_From_Date	datetime
		,@CF_To_Date	datetime
		,@CF_P_Days		numeric(18, 1)
		,@CF_Leave_Days	numeric(18, 5)
		,@CF_Type		varchar(50)
		,@tran_type		char
		,@Leave_CompOff_Dates	VARCHAR(MAX)	=''	--Ankit 01022016
		,@Reset_Flag   tinyint = 0
		,@User_Id numeric(18,0) = 0  --Mukti(02072016)
		,@IP_Address varchar(30)= '' --Mukti(02072016)
		,@Advance_Leave_Balance numeric(18,2) = 0
		,@Advance_Leave_Recover_Balance numeric(18,2) = 0
		,@New_Joing_Falg numeric(1,0) = 0
		,@Login_ID Numeric(18,0) = 0
		,@IsMakerChecker BIT = null
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Leave_CompOff_Dates = ''
		SET @Leave_CompOff_Dates = NULL
		
	declare @Leave_CF_Type as varchar(50)
	select @Leave_CF_Type = Leave_CF_Type from t0040_leave_master WITH (NOLOCK) where Cmp_ID=@Cmp_ID and leave_id = @Leave_ID
	declare @Emp_left_date as datetime
	
	--Added By Mukti(start)02072016
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''
	--Added By Mukti(end)02072016
	
	declare @Is_Advance_Leave_Balance as Numeric(5,0)
	Declare @Emp_Type as Numeric(18,0)
	Declare @CF_Type_ID as Numeric(18,0)
	select @Leave_CF_Type = Leave_CF_Type,@Is_Advance_Leave_Balance = Is_Advance_Leave_Balance from t0040_leave_master WITH (NOLOCK) where Cmp_ID=@Cmp_ID and leave_id = @Leave_ID
	
	
	if @Leave_CF_Type = 'yearly' or @Leave_CF_Type = 'Quarterly' -- Added for Quarterly by Hardik 05/05/2016 for G&D
		BEGIN
			SET @CF_For_Date = DATEADD(dd,1,@CF_For_Date)
		end
	ELSE IF @Leave_CF_Type = 'Monthly'
		BEGIN
			IF @Is_Advance_Leave_Balance = 1
				SET @CF_For_Date = @CF_From_Date			
		END
	
	--begin
	--	--set @CF_For_Date = DATEADD(dd,1,@CF_To_Date) 
	--	if @Is_Advance_Leave_Balance = 1 --and @Leave_CF_Type = 2 
	--		Begin
				
	--			--Set @CF_From_Date = DATEADD(yy,1,@CF_From_Date)
	--			--Set @CF_To_Date	= DATEADD(yy,1,@CF_To_Date)
	--		End
	--	Else
	--		Begin
	--			set @CF_For_Date = DATEADD(dd,1,@CF_To_Date)
	--		End
	--end
	
	If @CF_Type <> 'Daily (On Present Day)' ----------- Add By Jignesh Patel 09-Sep-2021------
	Begin
	If Exists(Select 1 From T0100_LEAVE_CF_DETAIL WITH (NOLOCK) Where Emp_Id = @Emp_Id And Leave_Id = @Leave_Id And CF_For_Date = @CF_For_Date) -- Added by Hardik 04/12/2019 for Genchi client, as they have wrong entry generated if again Leave CF Job run
		Return
	End
	

	--Added by Hardik 21/04/2016 for Laps Days
	DECLARE @Grade_ID AS numeric
	DECLARE @Max_CF_From_Last_Yr_Balance numeric(18,1)
	Declare @Leave_Closing numeric(18,2)
	DECLARE @CF_Laps_Days numeric(18,2)
	DECLARE @Max_CF_From_Last_Yr_Balance_Leave_Detail numeric(18,1)
	DECLARE @Max_CF_Year INT
	DECLARE @CF_For_Date_Temp Datetime
	  --Added By Jimit 18042019
	DECLARE @LEAVE_RESET bit
	DECLARE @RELEASE_MONTH TINYINT
	SET @LEAVE_RESET = 0
	Declare @Leave_Closing_Laps numeric(22,8)
	Declare @Leave_Laps tinyint 			
	SET @Leave_Laps = 0
	--ended
	--SET @Max_CF_Year = 2
	SELECT @Max_CF_Year = No_Of_Allowed_Leave_CF_Yrs FROM T0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_ID=@LEAVE_ID
	
	DECLARE @TYPE_Id AS Int --Added By Jimit 18042019
	
	Set @CF_Laps_Days = 0
	
	select @Grade_ID = I.Grd_ID ,
			@TYPE_Id = I.[Type_Id]  --Added By Jimit 18042019

	from T0095_Increment I WITH (NOLOCK) inner join 
	(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @CF_To_Date And Emp_ID = @Emp_Id Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @CF_To_Date And TI.Emp_ID = @Emp_Id group by ti.emp_id) Qry on I.Increment_Id = Qry.Increment_Id
	
	 SELECT @Max_CF_From_Last_Yr_Balance =  Case When Isnull(LD.Max_CF_From_Last_Yr_Balance,0) > 0 THEN ld.Max_CF_From_Last_Yr_Balance 
												 ELSE lm.Max_CF_From_Last_Yr_Balance 
											END			
	 FROM	T0040_LEAVE_MASTER lm WITH (NOLOCK) inner join 
			T0050_LEAVE_DETAIL ld WITH (NOLOCK) on lm.Leave_ID = ld.Leave_ID 
	 Where	lm.Leave_ID = @Leave_Id And ld.Grd_ID = @Grade_ID
	 

	
	SELECT	@Leave_Closing = Leave_Closing
	FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join 
			(
				SELECT	Max(For_Date) AS For_Date 
				FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				WHERE	Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date<= @CF_To_Date
			) Qry on LT.For_Date = Qry.For_Date
	WHERE	Emp_ID = @Emp_Id AND Leave_ID = @Leave_ID

	IF @Max_CF_Year > 0
		BEGIN
			SELECT	@CF_Laps_Days = Laps
			FROM	dbo.fn_getLastYearCFDays(@Emp_ID, @CF_To_Date + 1, @Leave_ID)
		END
	ELSE IF @Max_CF_From_Last_Yr_Balance >0 And @Max_CF_From_Last_Yr_Balance < @Leave_Closing AND @Leave_CF_Type <> 'Monthly'
		BEGIN
			SET @CF_Laps_Days = @Leave_Closing - @Max_CF_From_Last_Yr_Balance
		END
	ELSE IF @Max_CF_From_Last_Yr_Balance >0 And @Max_CF_From_Last_Yr_Balance < @Leave_Closing AND @Leave_CF_Type = 'Monthly' --Added By Jimit 18042019
		BEGIN	 
		
				 SELECT @Release_MONTH = QW.Release_Month
				 FROM	T0040_TYPE_MASTER T WITH (NOLOCK) INNER JOIN 
							(
								SELECT	C.EFFECTIVE_DATE,C.LEAVE_ID,TYPE_ID,Release_Month
								FROM	T0050_CF_EMP_TYPE_DETAIL C WITH (NOLOCK) INNER JOIN
										(
											SELECT	MAX(EFFECTIVE_DATE) EFFECTIVE_DATE
											FROM	T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK)
											WHERE	CMP_ID = @CMP_ID AND LEAVE_ID = @LEAVE_ID AND TYPE_ID = @TYPE_ID								
										) QRY ON    C.EFFECTIVE_DATE=QRY.EFFECTIVE_DATE
							) QW ON QW.TYPE_ID = T.TYPE_ID  AND QW.LEAVE_ID = @LEAVE_ID 
					WHERE	T.CMP_ID=@CMP_ID 

					SELECT	@Leave_Closing_Laps = Leave_Closing			
					FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join 
							(
								SELECT	Max(For_Date) AS For_Date 
								FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
								WHERE	Emp_ID=@Emp_Id AND Leave_ID=@Leave_ID AND For_Date < @CF_From_Date
							) Qry on LT.For_Date = Qry.For_Date
					WHERE	Emp_ID = @Emp_Id AND Leave_ID = @Leave_ID


				If MONTH(@CF_To_Date) = @Release_MONTH
					BEGIN
							SET @CF_Laps_Days = @Leave_Closing_Laps - @Max_CF_From_Last_Yr_Balance
					END

		END --Ended
	
	
	
	---End Hardik 21/04/2016 for Laps Days
	Declare @TEMP_CF_LAPS_DAYS as numeric(18,4)   --Added By Jimit 24042019
	SET @TEMP_CF_LAPS_DAYS = 0

	select @Emp_left_date =Emp_left_date from t0080_emp_master WITH (NOLOCK) where emp_id=@Emp_ID -- Added by rohit on 29032016 for cera
	if isnull(@Emp_left_date,@CF_For_Date) < @CF_For_Date
	begin
		set @CF_For_Date = @Emp_left_date
	end
	
	If @tran_type  = 'I'
		Begin
			if @Reset_Flag = 1 
				begin					
					IF @Is_Advance_Leave_Balance = 1
						SET @CF_For_Date_Temp = @CF_To_Date	
					Else IF @Is_Advance_Leave_Balance = 0 and @Leave_CF_Type = 'yearly' -- Added By Nilesh Patel on 16082019 For DEC-2017 Month Leave is not reset and Mantis ID = 0007604
						SET @CF_For_Date_Temp = @CF_To_Date	
					Else
						Set @CF_For_Date_Temp = @CF_For_Date

					exec P_Reset_Leave_Balance @Cmp_ID=@Cmp_ID,@Leave_id=@leave_id,@Emp_ID = @Emp_ID,@For_Date = @CF_For_Date_Temp,@CF_To_Date=@CF_To_Date
							,@LEAVE_RESET = @LEAVE_RESET output  -- Added by rohit on 12052016  set Leave reset parameter to check the balance is reset based on the reset month or not
					exec Set_leave_transaction_table @Cmp_id_set = @Cmp_ID,@emp_id_Set = @Emp_ID,@leave_id_set =  @leave_id,@max_Date_Set = @CF_To_Date
				end	
				
			
			
			--IF @LEAVE_RESET = 0 And Isnull(@CF_Laps_Days,0) = 0 --Added By Jimit 18042019
			--	BEGIN

			--			exec P_Laps_CF_Leaves_Last_Year @Cmp_ID=@Cmp_ID,@Leave_id=@leave_id,@Emp_ID = @Emp_ID,
			--											@For_Date = @CF_For_Date,@CF_To_Date=@CF_To_Date,@Type_Id = @Type_Id
			--											,@CF_Laps_Days = @CF_Laps_Days  OUTPUT

			--			if @CF_Laps_Days <> 0
			--				BEGIN
			--					SET @TEMP_CF_LAPS_DAYS = @CF_Laps_Days
			--					Set @CF_Laps_Days = 0	
								
			--					--select @TEMP_CF_LAPS_DAYS,CF_Laps_Days,* from T0140_LEAVE_TRANSACTION where EMP_ID = 14842 and LEAVE_ID = 1194 and For_date >= '2018-03-01 00:00:00'							
			--				END
						
						

			--	END	  
			--Ended
				
				If Exists(Select Leave_CF_ID From T0100_LEAVE_CF_DETAIL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID 
							and CF_From_Date=@CF_From_Date and CF_To_Date = @CF_To_Date and Leave_ID =@LEAVE_ID and CF_IsMakerChecker is not null)
					BEGIN
					
						--Added By Mukti(start)02072016	
						exec P9999_Audit_get @table='T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
						--Added By Mukti(end)02072016
						
						

						Update	T0100_LEAVE_CF_DETAIL
						SET		-- CF_For_Date=@CF_For_Date
								CF_P_Days=@CF_P_Days,
								CF_Leave_Days=@CF_Leave_Days,
								CF_Type=@CF_Type,
								Leave_CompOff_Dates = @Leave_CompOff_Dates,
								CF_Laps_Days = @CF_Laps_Days,
								CF_IsMakerChecker = @IsMakerChecker
						WHERE	Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CF_From_Date=@CF_From_Date and CF_To_Date = @CF_To_Date and Leave_ID =@LEAVE_ID
						
						--Added By Mukti(start)02072016	
						exec P9999_Audit_get @table = 'T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
						--Added By Mukti(end)02072016	
					END				
				ELSE
					BEGIN
						
						if @New_Joing_Falg <> 1  --Added by nilesh patel on 27072016
							Begin
								select @Leave_CF_ID = Isnull(max(Leave_CF_ID),0) + 1 	From T0100_LEAVE_CF_DETAIL WITH (NOLOCK)
				          
						  
							INSERT INTO T0100_LEAVE_CF_DETAIL
								(Leave_CF_ID
								,Cmp_ID
								,Emp_ID
								,Leave_ID
								,CF_For_Date
								,CF_From_Date
								,CF_To_Date
								,CF_P_Days
								,CF_Leave_Days
								,CF_Type
								,Leave_CompOff_Dates
								,CF_Laps_Days
								,Advance_Leave_Balance
								,Advance_Leave_Recover_Balance
								,Last_Modify_Date
								,Last_Modify_By
								,CF_IsMakerChecker
							)
								VALUES     (	@Leave_CF_ID
												,@Cmp_ID
												,@Emp_ID
												,@Leave_ID
												,@CF_For_Date
												,@CF_From_Date
												,@CF_To_Date
												,@CF_P_Days
												,@CF_Leave_Days
												,@CF_Type
												,@Leave_CompOff_Dates
												,@CF_Laps_Days
												,@Advance_Leave_Balance
												,@Advance_Leave_Recover_Balance
												,GETDATE()
												,@Login_ID
												,@IsMakerChecker
											)
								
							--update T0100_LEAVE_CF_DETAIL set CF_IsMakerChecker = @IsMakerChecker where Emp_ID = @Emp_ID
								--Added By Mukti(start)02072016									
								exec P9999_Audit_get @table = 'T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
								set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
								--Added By Mukti(end)02072016
							End
							
				
					--Added By Jimit 24042019
					--	/* If Temp cf Laps days are greater then 0 then update the Laps days in last date of first quarter */
					If @TEMP_CF_LAPS_DAYS > 0 
						BEGIN
							 ALTER TABLE T0100_LEAVE_CF_DETAIL DISABLE TRIGGER Tri_T0100_LEAVE_CF_DETAIL
							 ALTER TABLE T0100_LEAVE_CF_DETAIL DISABLE TRIGGER Tri_T0100_LEAVE_CF_DETAIL_Update							 

								UPDATE	T0100_LEAVE_CF_DETAIL
								SET		CF_LAPS_DAYS = @TEMP_CF_LAPS_DAYS
								WHERE	CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND CF_FROM_DATE = @CF_FROM_DATE 
										AND CF_TO_DATE = @CF_TO_DATE AND LEAVE_ID = @LEAVE_ID						
						
							 ALTER TABLE T0100_LEAVE_CF_DETAIL ENABLE TRIGGER Tri_T0100_LEAVE_CF_DETAIL
							 ALTER TABLE T0100_LEAVE_CF_DETAIL ENABLE TRIGGER Tri_T0100_LEAVE_CF_DETAIL_Update
						END
					--Ended
				
					if @Is_Advance_Leave_Balance = 1 and isnull(@Advance_Leave_Balance,0) > 0  --Added by nilesh patel on 27072016
							Begin
								Declare @LEAVE_Tran_ID Numeric(18,0)
								
								Select @LEAVE_Tran_ID = Isnull(max(LEAVE_Tran_ID),0) + 1 	From T0100_LEAVE_CF_Advance_Leave_Balance WITH (NOLOCK)
								
								
						
								Declare @Advance_From_Date Datetime
								Declare @Advance_To_Date Datetime
								Declare @Advance_For_Date Datetime
								
								if @New_Joing_Falg = 1 
									Begin
										Set @Advance_From_Date = @CF_From_Date
										Set @Advance_To_Date =  @CF_To_Date 
										set @Advance_For_Date = @CF_From_Date
										set @Leave_CF_ID = 0
									End
								Else
									Begin
										if @Leave_CF_Type = 'yearly'
											Begin
												Set @Advance_From_Date = Dateadd(yy,1,@CF_From_Date) -- @CF_From_Date
												Set @Advance_To_Date =  Dateadd(yy,1,@CF_To_Date) --@CF_To_Date
												set @Advance_For_Date = @CF_For_Date
											End
										Else if @Leave_CF_Type = 'Quarterly' -- Added by Hardik 20/11/2018 for Diamines Client as advance given, leave transaction table showing wrong
											Begin
												Set @Advance_From_Date = DateAdd(month,3,@CF_From_Date)
												Set @Advance_To_Date = Dateadd(dd,-1,DateAdd(month,3,@Advance_From_Date))-- dbo.GET_MONTH_END_DATE(Month(@Advance_From_Date),YEAR(@Advance_From_Date))
												set @Advance_For_Date = @Advance_From_Date
											End	
										Else if @Leave_CF_Type = 'Quarterly'
											Begin
												Set @Advance_From_Date = DateAdd(month,3,@CF_From_Date)
												Set @Advance_To_Date = Dateadd(dd,-1,DateAdd(month,3,@Advance_From_Date))-- dbo.GET_MONTH_END_DATE(Month(@Advance_From_Date),YEAR(@Advance_From_Date))
												set @Advance_For_Date = @Advance_From_Date
											End	
										Else
											Begin
												Set @Advance_From_Date = DateAdd(month,1,@CF_From_Date)
												Set @Advance_To_Date =  dbo.GET_MONTH_END_DATE(Month(@Advance_From_Date),YEAR(@Advance_From_Date))
												set @Advance_For_Date = @Advance_From_Date
											End
									End
								
								INSERT INTO T0100_LEAVE_CF_Advance_Leave_Balance
								(
									LEAVE_Tran_ID,
									LEAVE_CF_ID,
									Cmp_ID,
									Emp_ID,
									Leave_ID,
									CF_For_Date,
									CF_From_Date,
									CF_To_Date,
									CF_Type,
									Is_Fnf,
									Advance_Leave_Balance,
									Last_Modify_Date,
									Last_Modify_By,
									CF_IsMakerChecker
								)
								VALUES     
								(	
									@LEAVE_Tran_ID	
									,@Leave_CF_ID
									,@Cmp_ID
									,@Emp_ID
									,@Leave_ID
									,@Advance_For_Date
									,@Advance_From_Date
									,@Advance_To_Date
									,@CF_Type
									,0
									,@Advance_Leave_Balance
									,GETDATE()
									,@Login_ID
									,@IsMakerChecker
								)
								
								if @Leave_CF_ID = 0
									Set @Leave_CF_ID = @LEAVE_Tran_ID
									
							End 
					
					
			end
		End
	Else if @Tran_Type = 'U'
		begin

		
			if @Reset_Flag = 1 
				begin
					
					-------------- Modify Jignesh Patel 09-Sep-2021------------
					----exec P_Reset_Leave_Balance @Cmp_ID=@Cmp_ID,@Leave_id=@leave_id,@Emp_ID = @Emp_ID,@For_Date = @CF_For_Date,@CF_To_Date=@CF_To_Date -- Added by rohit on 12052016
					exec P_Reset_Leave_Balance @Cmp_ID=@Cmp_ID,@Leave_id=@leave_id,@Emp_ID = @Emp_ID,@For_Date = @CF_For_Date,@CF_To_Date=@CF_To_Date ,@LEAVE_RESET = @LEAVE_RESET output 
					
					exec Set_leave_transaction_table @Cmp_id_set = @Cmp_ID,@emp_id_Set = @Emp_ID,@leave_id_set =  @leave_id,@max_Date_Set = @CF_To_Date
				end		

				------------------- Modify Jignesh Patel 14-Sep-2021------------
				If @CF_Type <> 'Daily (On Present Day)'
				Begin
				
				If Exists(Select Leave_CF_ID From T0100_LEAVE_CF_DETAIL WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and CF_From_Date=@CF_From_Date and  Leave_CF_ID <> @Leave_CF_ID)
				begin
						set @Leave_CF_ID = 0
						Return 
				end
				   
					--Added By Mukti(start)02072016	
						exec P9999_Audit_get @table='T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
					--Added By Mukti(end)02072016
				
				Update T0100_LEAVE_CF_DETAIL				
				set Leave_ID=@Leave_ID
					--,CF_For_Date=@CF_For_Date
					,CF_P_Days=@CF_P_Days
					,CF_Leave_Days=@CF_Leave_Days
					,CF_Type=@CF_Type
					,Leave_CompOff_Dates = @Leave_CompOff_Dates
					,CF_Laps_Days= @CF_Laps_Days
					,CF_IsMakerChecker = @IsMakerChecker
				where Leave_CF_ID = @Leave_CF_ID and emp_Id = @emp_Id 
				
				--Added By Mukti(start)02072016	
					exec P9999_Audit_get @table = 'T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				--Added By Mukti(end)02072016	

				End 

		else If @CF_Type = 'Daily (On Present Day)'
				Begin
				
					exec P9999_Audit_get @table='T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
								
					Update T0100_LEAVE_CF_DETAIL				
						set Leave_ID=@Leave_ID
						--,CF_For_Date=@CF_For_Date
						,CF_P_Days=@CF_P_Days
						,CF_Leave_Days=@CF_Leave_Days
						,CF_Type=@CF_Type
						,Leave_CompOff_Dates = @Leave_CompOff_Dates
						,CF_Laps_Days= @CF_Laps_Days
						,CF_IsMakerChecker = @IsMakerChecker
						where Leave_CF_ID = @Leave_CF_ID and emp_Id = @emp_Id  
						
						exec P9999_Audit_get @table = 'T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
						set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))

				End
				---------------------- End -------------------------------
		end
	Else if @Tran_Type = 'D'
		begin
				SELECT @EMP_ID = EMP_ID,
					   @LEAVE_ID = LEAVE_ID,
					   @CF_TO_DATE =CF_TO_DATE  
				FROM T0100_LEAVE_CF_DETAIL WITH (NOLOCK)
				WHERE  LEAVE_CF_ID = @LEAVE_CF_ID
		
			--Added by Jaina 06-03-2017 Start  (If Opening Leave Balance is delete than only credit balance is available and Leave Application is exists that time this condition check)
			  if exists( SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN 
					T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID = LAD.Leave_Application_ID INNER JOIN
					T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) ON LT.Emp_ID=la.Emp_ID AND LT.Leave_ID = LAD.Leave_ID
			        where LA.Emp_ID=@Emp_ID
						and LT.Leave_ID=@Leave_ID and LT.For_Date >= @CF_TO_DATE and isnull(LT.Leave_Posting,0)IS NULL
					and LT.Leave_Credit = LT.Leave_Closing)
			  BEGIN
					RAISERROR('Record can''t deleted, Reference Exits',16,2)
					return -1
			  END
			
			 if exists( SELECT 1 FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN 
					T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID INNER JOIN
					T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) ON LT.Emp_ID=la.Emp_ID AND LT.Leave_ID = LAD.Leave_ID
			        where LA.Emp_ID=@Emp_ID
						and LT.Leave_ID=@Leave_ID and LT.For_Date >= @CF_TO_DATE and isnull(LT.Leave_Posting,0)IS NULL
					and LT.Leave_Credit = LT.Leave_Closing)
			  BEGIN
					RAISERROR('Record can''t deleted, Reference Exits',16,2)
					return -1
			  END
		--Added by Jaina 06-03-2017 End
 
		if @Reset_Flag = 1 
				begin
					
					
					
					if exists(select emp_id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_ID and Leave_ID=@Leave_ID and For_Date=@CF_To_Date and isnull(Leave_Posting,0) > 0)
					begin
						update T0140_LEAVE_TRANSACTION 
						set Leave_Closing = leave_closing + leave_posting
						,Leave_Posting = 0
						from T0140_LEAVE_TRANSACTION where Emp_ID=@Emp_ID and Leave_ID=@Leave_ID and For_Date=@CF_To_Date and isnull(Leave_Posting,0) > 0	
						exec Set_leave_transaction_table @Cmp_id_set = @Cmp_ID,@emp_id_Set = @Emp_ID,@leave_id_set =  @leave_id,@max_Date_Set = @CF_To_Date
					
					end
					
				end	
				--Added By Mukti(start)02072016	
						exec P9999_Audit_get @table='T0100_LEAVE_CF_DETAIL' ,@key_column='Leave_CF_ID',@key_Values=@Leave_CF_ID,@String=@String output
						set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				--Added By Mukti(end)02072016
				Delete From T0100_LEAVE_CF_DETAIL Where Leave_CF_ID = @Leave_CF_ID
				Delete From T0100_LEAVE_CF_Advance_Leave_Balance Where Leave_CF_ID = @Leave_CF_ID
		end
		exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Leave Carry Forward',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
	RETURN