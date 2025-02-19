

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_LEAVE_DETAIL]
	@Row_ID numeric(18,0) output
   ,@Leave_ID numeric(18,0)
   ,@Grd_ID numeric(18,0)
   ,@Cmp_ID numeric(18,0)
   ,@Leave_Days numeric(18,1)
   ,@tran_type varchar(1)
   ,@User_Id numeric(18,0) = 0 -- Added By Ali 07102013
   ,@IP_Address varchar(30)= '' -- Added By Ali 07102013
   -- Added By Ali 15042014 -- Start
   ,@Bal_After_Encash numeric(18,1) = 0 
   ,@Min_Leav_Encash numeric(18,1) = 0 
   ,@Max_Leav_Encash numeric(18,1) = 0 
   ,@NoOfAppli numeric(18,0) = 0 
   ,@Leave_Encash numeric(18,1) = 0 
   ,@Encash_Appli_After numeric(18,0) = 0 
   ,@Max_Leave_CF numeric(18,1) = 0 
   ,@Max_Accum_Bal numeric(18,1) = 0 
   ,@Min_Leave numeric(18,2) = 0 --Change by Jaina 04-02-2019
   ,@Max_Leave numeric(18,2) = 0  --Change by Jaina 04-02-2019
   ,@NoticePeriod numeric(18,0) = 0 
   ,@MaxLeaveApp numeric(18,2) = 0 --Added by Gadriwala Muslim 17092015
   ,@AfterResumingDuty numeric(18,0) = 0 --Added by Gadriwala Muslim 17092015
   ,@Max_Leave_CF_From_Last_Year numeric(18,1) = 0 --added jimit 09052016
   ,@Effect_Salary_Cycle numeric(18,0) = 0  --Added by Jaina 12-04-2017
   ,@Monthly_Max_Leave numeric(18,1) = 0  --Added by Jaina 12-04-2017
   ,@Is_Probation	numeric(18,0) = 0	-- Added by Divyaraj Kiri on 27/09/2024
   -- Added By Ali 15042014 -- End 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Declare @Old_Leave_ID numeric(18,0)
	--Declare @Old_Grd_ID numeric(18,0)
	--Declare @Old_Cmp_ID numeric(18,0)
	--Declare @Old_Leave_Days numeric(18,1)	
	--Declare @Old_Leave_Name as varchar(50)
	--Declare @Old_Grade_Name as varchar(50)
	--declare @Old_MaxLeaveApp as numeric(18,2) --Added by Gadriwala Muslim 17092015
	--declare @Old_AfterResumingDuty as numeric(18,2) --Added by Gadriwala Muslim 17092015
	 
	--Declare @New_Leave_Name as varchar(50)
	--Declare @New_Grade_Name as varchar(50)
	
	--Set @Old_Leave_ID = 0 
	--Set @Old_Grd_ID = 0 
	--Set @Old_Cmp_ID = 0 
	--Set @Old_Leave_Days = 0 	
	--Set @Old_Leave_Name = '' 
	--Set @Old_Grade_Name = '' 
	--Set @New_Leave_Name = '' 
	--Set @New_Grade_Name = '' 
	--set @Old_MaxLeaveApp = 0  --Added by Gadriwala Muslim 17092015
	--set @Old_MaxLeaveApp = 0  --Added by Gadriwala Muslim 17092015
	
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	set @String=''
	set @OldValue =''

	If @tran_type ='I' 
		begin
			if exists(select Row_ID from T0050_Leave_Detail WITH (NOLOCK) where(Leave_ID = @Leave_ID) and (Grd_ID = @Grd_ID) and (Cmp_ID = @Cmp_ID) )
			begin
				set @Row_ID = 0
				return
			end
			
				select @Row_ID = isnull(max(Row_ID),0) +1 from T0050_LEAVE_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0050_LEAVE_DETAIL (Leave_ID, Row_ID, Grd_ID, Cmp_ID, Leave_Days,
				Bal_After_Encash,Min_Leave_Encash,Max_Leave_Encash,Max_No_Of_Application,L_Enc_Percentage_Of_Current_Balance,Encash_Appli_After_month,Min_Leave_CF,Max_Accumulate_Balance,Min_Leave,Max_Leave,Notice_Period,Max_Leave_App,After_Resuming_Duty
				,Max_CF_From_Last_Yr_Balance,Effect_Salary_Cycle,Monthly_Max_Leave,Is_Probation) -- Changed by Gadriwala Muslim 17092015
				
				VALUES (@Leave_ID,@Row_ID,@Grd_ID,@Cmp_ID,@Leave_Days,
				@Bal_After_Encash,@Min_Leav_Encash,@Max_Leav_Encash,@NoOfAppli,@Leave_Encash,@Encash_Appli_After,@Max_Leave_CF,@Max_Accum_Bal,@Min_Leave,@Max_Leave,@NoticePeriod,@MaxLeaveApp,@AfterResumingDuty
				,@Max_Leave_CF_From_Last_Year,@Effect_Salary_Cycle,@Monthly_Max_Leave,@Is_Probation)	-- Changed by Gadriwala Muslim 17092015
				
				-- Added By Ali 07102013 -- Start						
				--select @New_Leave_Name = Leave_Name from T0040_LEAVE_MASTER  where Leave_ID = @Leave_ID  AND Cmp_ID = @Cmp_ID
				--Select @New_Grade_Name = Grd_Name from T0040_Grade_MASTER where Cmp_ID = @Cmp_ID And Grd_ID = @Grd_ID
				
				--set @OldValue = 'New Value' 
				--				+ '#' + 'Leave Name :' + ISNULL(@New_Leave_Name,'') 
				--				+ '#' + 'Grade Name :' + ISNULL(@New_Grade_Name,'') 
				--				+ '#' + 'Leave Days :' + CONVERT(nvarchar(20),ISNULL(@Leave_Days,0))
				--				+ '#' + 'Company :' + CONVERT(nvarchar(20),ISNULL(@Cmp_ID,0))
				--				+ '#' + 'Max Leave Application :' + CONVERT(nvarchar(5),ISNULL(@MaxLeaveApp,0))
				--				+ '#' + 'After resuming duty :' + CONVERT(nvarchar(5),ISNULL(@AfterResumingDuty,0))
								
				--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Details',@OldValue,@Row_ID,@User_Id,@IP_Address	
				-- Added By Ali 07102013 -- End
				
				--Added By Mukti(start)05072016
				exec P9999_Audit_get @table = 'T0050_LEAVE_DETAIL' ,@key_column='Row_ID',@key_Values=@row_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				--Added By Mukti(end)05072016
		end 
	Else If @tran_type ='U' 
		begin
			if exists(select Row_ID from T0050_Leave_Detail WITH (NOLOCK) where Leave_ID = @Leave_ID and Grd_ID = @Grd_ID 
										and Cmp_ID = @Cmp_ID and row_ID <> @row_ID)
				begin
					set @Row_ID = 0
					return
				end
				
				--Added By Mukti(start)05072016
				exec P9999_Audit_get @table='T0050_LEAVE_DETAIL WITH (NOLOCK)' ,@key_column='Row_ID',@key_Values=@row_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				--Added By Mukti(end)05072016		
				
				UPDATE    T0050_LEAVE_DETAIL
				SET       Leave_ID = @Leave_ID, Grd_ID = @Grd_ID, Cmp_ID = @Cmp_ID, Leave_Days = @Leave_Days,
						  Bal_After_Encash = @Bal_After_Encash
						  ,Min_Leave_Encash = @Min_Leav_Encash
						  ,Max_Leave_Encash = @Max_Leav_Encash
						  ,Max_No_Of_Application = @NoOfAppli
						  ,L_Enc_Percentage_Of_Current_Balance = @Leave_Encash
						  ,Encash_Appli_After_month = @Encash_Appli_After
						  ,Min_Leave_CF = @Max_Leave_CF
						  ,Max_Accumulate_Balance = @Max_Accum_Bal
						  ,Min_Leave = @Min_Leave
						  ,Max_Leave = @Max_Leave
						  ,Notice_Period = @NoticePeriod
						  ,Max_Leave_App = @MaxLeaveApp -- Added by Gadriwala Muslim 17092015
						  ,After_Resuming_Duty = @AfterResumingDuty -- Added by Gadriwala Muslim 17092015
						  ,Max_CF_From_Last_Yr_Balance = @Max_Leave_CF_From_Last_Year
						  ,Effect_Salary_Cycle = @Effect_Salary_Cycle  --Added by Jaina 12-04-2017
						  ,Monthly_Max_Leave = @Monthly_Max_Leave 
						  ,Is_Probation = @Is_Probation
				WHERE     (Row_ID = @Row_ID)
									
				--Added By Mukti(start)05072016
				exec P9999_Audit_get @table = 'T0050_LEAVE_DETAIL' ,@key_column='Row_ID',@key_Values=@Row_ID,@String=@String output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
				--Added By Mukti(end)05072016
			
		end
	Else If @tran_type ='D'
		begin
			--Select @Leave_ID = Leave_ID, @Grd_ID = Grd_ID from T0050_LEAVE_DETAIL where Row_ID=@Row_ID
			
			-- commented by mitesh on 26032013 -  if delete is used then exisiting leave application & approval 
			
			--if exists(select Leave_ID from T0130_LEAVE_APPROVAL_DETAIL where Leave_ID=@Leave_ID)
			--If Exists (Select I.Emp_ID from T0120_LEAVE_APPROVAL LA Inner Join
			--			T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID Inner Join
			--			T0095_INCREMENT I on LA.Emp_ID = I.Emp_ID
			--			Where Lad.Leave_ID = @Leave_ID and Grd_ID=@Grd_ID)
			--	begin
			--		Raiserror('@@Reference Exists In Leave Approval@@',16,2)
			--		return -1
			--	end
				
			--if exists(select Leave_ID from T0110_LEAVE_APPLICATION_DETAIL where Leave_ID=@Leave_ID)
			--If Exists (Select I.Emp_ID from T0100_LEAVE_APPLICATION LA Inner Join
			--			T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID Inner Join
			--			T0095_INCREMENT I on LA.Emp_ID = I.Emp_ID
			--			Where Lad.Leave_ID = @Leave_ID and Grd_ID=@Grd_ID)
			--	begin
			--		Raiserror('@@Reference Exists In Leave Application@@',16,2)
			--		return -1
			--	end								
			
			--Added By Mukti(start)05072016
				exec P9999_Audit_get @table='T0050_LEAVE_DETAIL' ,@key_column='Row_ID',@key_Values=@Row_ID,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			--Added By Mukti(end)05072016
				
			delete  from T0050_LEAVE_DETAIL where  (Row_ID = @Row_ID)
		end
		
		exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Leave Details',@OldValue,@Row_ID,@User_Id,@IP_Address
	RETURN




