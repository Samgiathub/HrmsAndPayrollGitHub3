
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0110_Leave_Application_Detail]
	@Leave_Application_ID	numeric
   ,@Emp_Id					numeric
   ,@Cmp_ID					numeric
   ,@Leave_ID				numeric
   ,@From_Date				datetime
   ,@To_Date				datetime
   ,@Leave_Period			numeric(18,2)
   ,@Leave_Assign_As		varchar(15)
   ,@Leave_Reason			nvarchar(max) -- Changed By Gadriwala Muslim 22092015
   ,@Row_ID					numeric output
   ,@Login_ID				numeric
   ,@System_Date			datetime
   ,@tran_type				varchar(1)
   ,@Half_Leave_Date		datetime 
   ,@Leave_App_Docs			varchar(Max)=''	-- Added by rohit on 13122013
   ,@User_Id numeric(18,0) = 0 
   ,@IP_Address varchar(30)= '' 
   ,@Leave_Out_Time  Datetime = NULL  --Ankit 21022014
   ,@Leave_In_Time   Datetime = NULL  --Ankit 21022014
   ,@NightHalt			numeric(18,0) = 0
   ,@strLeaveCompOff_Dates varchar(max) = '' -- Added by Gadriwala Muslim 01102014
   ,@Half_Payment tinyint=0 --Hardik 19/12/2014
   ,@Warning_flag tinyint=0 -- Added by Gadriwala Muslim 22092015
   ,@Rules_Violate tinyint = 0 -- Added by Gadriwala Muslim 24092015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		--set @To_Date = dateadd(d,round(@Leave_Period ,0)-1 ,@From_Date) -- commented by MItesh on 27/12/2011
	
	IF ISNULL(@Leave_Period,0) = 0 AND @tran_type ='I' 	--Ankit 28062016
		BEGIN
			RAISERROR ('Zero Leave Period is not allowed' , 16, 2)
			RETURN;
		END 

	if @Emp_Id = 0
	Begin 
		Declare @Empid as numeric = 0
		Select @Empid = Emp_ID from T0100_LEAVE_APPLICATION LA 
		inner join T0110_LEAVE_APPLICATION_DETAIL LAD on LAD.Leave_Application_ID = LA.Leave_Application_ID
		set @Emp_Id = @Empid
	END

	--START Deepal Below is for Leave Base on Desgination DT:- 23092024
	If @tran_type in ('I','U')
	BEGIN
			DECLARE  @ID as int = 0
			Select @ID = Cat_ID 
			From T0095_Increment I 
			INNER JOIN
			( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
				FROM T0095_INCREMENT I2 
				INNER JOIN 
				(
					SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
					FROM T0095_INCREMENT I3
					WHERE I3.Increment_effective_Date <= GETDATE() and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' AND I3.EMP_ID = @Emp_ID
					GROUP BY I3.EMP_ID  
				 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
				 WHERE I2.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
				 GROUP BY I2.emp_ID  
			) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @Emp_ID 
	
			
			if NOT exists(SELECT 1 FROM LEAVEODLIMITDESIGNATIONWISE WHERE LEAVEID = @LEAVE_ID AND Id = @ID)
			BEGIN
					Declare @ODLimit as tinyint = 5

					If exists(SELECT 1 FROM V0110_Leave_Application_Detail V Inner join T0040_LEAVE_MASTER LM on V.Leave_ID = LM.Leave_ID and Leave_Code = 'OD'  		
						WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_Id and (Application_Status = 'P' or Application_Status='F') and V.Leave_ID = @Leave_ID 
						AND From_Date >= DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0)  and To_Date <= DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) AND Leave_Application_ID <> @Leave_Application_ID)
					BEGIN
			
						Declare @leaveCountButNotApproved as int = 0
						SELECT @leaveCountButNotApproved = Sum(Leave_Period) FROM V0110_Leave_Application_Detail V WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_Id and (Application_Status = 'P' or Application_Status='F') and Leave_ID = @Leave_ID
						AND From_Date >= DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0)  and To_Date <= DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) and Leave_Application_ID <> @Leave_Application_ID 
					
						--If EXISTS(SELECT 1 FROM LEAVEODLIMITDESIGNATIONWISE WHERE LEAVEID = @LEAVE_ID AND Id = @ID AND @ODLimit < (cast(isnull(@leaveCountButNotApproved,0) as int) + cast(isnull(@Leave_Period,0) as int)))	
						if @ODLimit < (cast(isnull(@leaveCountButNotApproved,0) as int) + cast(isnull(@Leave_Period,0) as int))
						BEGIN
								RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
								RETURN;
						END
					ENd
			
					if EXISTS(select 1 from T0040_LEAVE_MASTER where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_ID and Leave_Code = 'OD')
					BEGIN
						if @Leave_Period > @ODLimit 
						BEGIN
								RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
								RETURN;
						END
					END

					if EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Leave_ID = @Leave_ID 
							  AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1))
					BEGIN 		
							Declare @LeaveUsed as int =0
							SELECT @LeaveUsed = sum(Leave_Used) 
							FROM T0140_LEAVE_TRANSACTION L Inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID and Leave_Code = 'OD' 
							WHERE L.Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and L.Leave_ID = @Leave_ID AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) AND Leave_Used = 1

							If @ODLimit < (cast(isnull(@LeaveUsed,0) as int) + cast(isnull(@Leave_Period,0) as int))
							BEGIN
								RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
								RETURN;
							END
					END

					--if EXISTS(select 1 from LeaveODLimitDesignationWise where LeaveId = @Leave_ID and CmpId = @Cmp_ID)
					--BEGIN 		
					--	if EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and Leave_ID = @Leave_ID AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1))
					--	BEGIN 		
					--		Declare @LeaveUsed as int =0
					--		SELECT @LeaveUsed = sum(Leave_Used) 
					--		FROM T0140_LEAVE_TRANSACTION L Inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID and Leave_Code = 'OD' 
					--		WHERE L.Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id and L.Leave_ID = @Leave_ID AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) AND Leave_Used = 1
					--		If EXISTS(SELECT 1 FROM LEAVEODLIMITDESIGNATIONWISE WHERE LEAVEID = @LEAVE_ID AND Id = @ID AND ODLIMIT < (cast(isnull(@LEAVEUSED,0) as int) + cast(isnull(@Leave_Period,0) as int)))	
					--		BEGIN
					--			--print 2
					--			RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
					--			RETURN;
					--		END
					--	END
					--	else
					--	BEGIN
					--		if EXISTS(select 1 from LeaveODLimitDesignationWise where Id = @ID and LeaveId = @Leave_ID and @Leave_Period  > ODLimit)
					--		BEGIN
					--			RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
					--			RETURN;
					--		END
					--	END
					--END
			END
		END
	--END Deepal Below is for Leave Base on Desgination DT:- 23092024

	--if @EMP_ID = 0
	--Begin 
	--		If ((SELECT count(1) FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
	--									T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
	--									AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
	--									T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@From_Date)) AND [MONTH] = MONTH(EOMONTH(@From_Date))
	--									inner join T0100_LEAVE_APPLICATION LA on LA.Emp_ID = E.Emp_ID
	--									inner join T0110_LEAVE_APPLICATION_DETAIL LAD on LAD.Leave_Application_ID = LA.Leave_Application_ID
	--									WHERE E.CMP_ID = @CMP_ID) > 0)
	--		BEGIN
	--			--delete from T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Application_ID
	--			Raiserror('@@ Attendance Lock for this Period. @@',16,2)
	--			return -1								
	--		END
	--END
	--ELSe
	--BEgIN
			If ((SELECT count(1) FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
										T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
										AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
										T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@From_Date)) AND [MONTH] = MONTH(EOMONTH(@From_Date))
										inner join T0100_LEAVE_APPLICATION LA on LA.Emp_ID = E.Emp_ID
										inner join T0110_LEAVE_APPLICATION_DETAIL LAD on LAD.Leave_Application_ID = LA.Leave_Application_ID
										WHERE E.CMP_ID = @CMP_ID aND SPE.EMP_ID = @Emp_Id) > 0)
			BEGIN
				--delete from T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Application_ID
				Raiserror('@@ Attendance Lock for this Period. @@',16,2)
				return -1								
			END
	--ENd
	
	----Advance Leave Restriction --Ankit 03092016----
	DECLARE @UpToDate	VARCHAR(100)
	DECLARE @UpTo_Days	NUMERIC
	DECLARE @UpTo_Error VARCHAR(500)
	SET @UpToDate = ''
	SET @UpTo_Days = 0
	SET @UpTo_Error = ''
	
	SELECT @UpTo_Days = setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE cmp_Id = @Cmp_ID AND Setting_Name='Add number of days to apply leave in advance'
	
	IF @UpTo_Days <> 0 AND @To_Date >= DATEADD(d,@UpTo_Days,@From_Date)
		BEGIN
			SET @UpToDate = CONVERT(VARCHAR(15),DATEADD(d,@UpTo_Days,@From_Date),103)
			SET @UpTo_Error = '@@ You Can Apply Leave Up To ' + @UpToDate + '(' + CAST(@UpTo_Days AS VARCHAR(5)) +') Days. @@'
			RAISERROR (@UpTo_Error , 16, 2)
			RETURN;
		END	
	-------------------------------------
	
	if @leave_out_time = '1900-01-01'
	begin
		SET @leave_out_time = NULL
	end
	
	if @leave_in_time = '1900-01-01'
	begin
		SET @leave_in_time = NULL
	end
	
	Declare @Leave_Paid_Unpaid varchar(1)
	--Alpesh 04-Jul-2012
	Declare @tmpFrom_Date	datetime
	Declare @tmpTo_Date		datetime
	Declare @Total_Leave_Days	numeric(18,2)
	Declare @Leave_Max		numeric(18,2)
	
	Declare @Old_Leave_Application_ID	numeric
	Declare @Old_Emp_Id					numeric
	Declare @Old_Cmp_ID					numeric
	Declare @Old_Leave_ID				numeric
	Declare @Old_From_Date				datetime
	Declare @Old_To_Date				datetime
	Declare @Old_Leave_Period			numeric(18,1)
	Declare @Old_Leave_Assign_As		varchar(15)
	Declare @Old_Leave_Reason			varchar(100)
	Declare @Old_Row_ID					numeric 
	Declare @Old_Login_ID				numeric
	Declare @Old_System_Date			datetime
	Declare @Old_Half_Leave_Date		datetime 
	Declare @Old_Emp_Name				nvarchar(60)			
	Declare @Old_Leave_Name				nvarchar(50)	
	declare @OldValue as varchar(max)
	Declare @OldNightHalt				numeric(18,0)
	Declare @Old_strLeaveCompOff_Dates  varchar(max) -- Added by Gadriwala Muslim 01102014
	Declare @New_Emp_Name				nvarchar(60)			
	Declare @New_Leave_Name				nvarchar(50)	
	Declare @Old_Leave_App_Docs			varchar(max) -- Added by rohit on 13122013
	Declare @apply_hourly as numeric
	declare @Old_Rules_Violate as tinyint -- Added by Gadriwala Muslim 24092015
	declare @Old_Warning_flag as tinyint -- Added by Gadriwala muslim 24092015
	Declare @Old_Half_Payment varchar --Hardik 19/12/2014
	
	Declare @Total_Cancel_Day as Numeric(18,0) -- Added by rohit on 26072014
	set @Total_Cancel_Day = 0
	
		set @apply_hourly = 0
	
	set @New_Emp_Name = ''
	set @New_Leave_Name = ''
	set @OldValue = ''
	Set @Old_Leave_Application_ID	= 0
	Set @Old_Emp_Id				= 0
	Set @Old_Cmp_ID				= 0
	Set @Old_Leave_ID				= 0
	Set @Old_From_Date			= null
	Set @Old_To_Date				= null
	Set @Old_Leave_Period			= 0
	Set @Old_Leave_Assign_As		= ''
	Set @Old_Leave_Reason			= ''
	Set @Old_Row_ID				= 0
	Set @Old_Login_ID				= 0
	Set @Old_System_Date			= null
	Set @Old_Half_Leave_Date		= null
	Set @Old_Emp_Name				= ''
	Set @Old_Leave_Name			= ''
	Set @Old_Leave_App_Docs         = '' 
	Set @OldNightHalt = 0
	Set @Old_strLeaveCompOff_Dates  = '' -- Added by Gadriwala Muslim 01102014
	If isnull(@Leave_Out_Time,'') = ''  
	   set @Leave_Out_Time = 0  
	If isnull(@Leave_In_Time,'') = ''  
	   set @Leave_In_Time = 0    
	Set  @Old_Half_Payment=0
	
	set @Old_Rules_Violate  = 0 -- Added by gadriwala Muslim 24092015
	set @Old_Warning_flag = 0  -- Added by gadriwala Muslim 24092015
	
	--Added by Jaina 23-06-2017 Start
	Declare @Leave_Code varchar(10)
	select @Leave_Code = Leave_Code from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID
	
	if (@FROM_DATE < convert(datetime,convert(char(10),getdate(),103),103))
		AND exists(SELECT 1 from sys.procedures where name='P_Validate_Leave_SLS')
	BEGIN
		EXEC P_Validate_Leave_SLS @Cmp_Id=@Cmp_Id,@Emp_Id=@Emp_Id,@Leave_Id=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date ,@Leave_Period=@Leave_Period,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date,@Leave_Application_ID=@Leave_Application_ID   --Change by Jaina 05-07-2017
	END
	--Added by Jaina 23-06-2017 End
	
	--Paternity Leave Validation
	--Added by Jaina 07-05-2018	Start	
	DECLARE @F_date datetime
	declare @T_date datetime
	declare @message varchar(200)
						
	if exists (select 1 from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_id and Leave_Type = 'Paternity Leave')
	BEGIN
		
		
		Create table #Paternity_Leave
		(
			Leave_Tran_Id numeric(18,0),
			Emp_id numeric(18,0),
			For_Date datetime,
			Leave_Opening numeric(18,2),
			Leave_Closing numeric(18,2),
			Laps_Days numeric(18,2),
			From_Date datetime,
			To_Date datetime
		)
		
		insert INTO #Paternity_Leave
		EXEC P_RESET_PATERNITY_LEAVE @CMP_ID = @CMP_ID,@EMP_ID=@EMP_ID
		
		

		if exists (select 1 from #PATERNITY_LEAVE where Emp_id = @Emp_id)
		BEGIN						
			IF NOT EXISTS(SELECT 1 FROM #PATERNITY_LEAVE WHERE @FROM_DATE BETWEEN FROM_DATE AND TO_DATE AND
			@TO_DATE BETWEEN FROM_DATE AND TO_DATE AND Emp_id=@emp_ID)
			BEGIN
				SELECT @F_date = From_Date, @T_date = To_Date 
				FROM #PATERNITY_LEAVE WHERE Emp_id=@emp_ID
										
				set @message = '@@You can apply leave between '+ convert(varchar(11),@F_date,103) + ' To ' + convert(varchar(11),@T_date,103) + '@@'
				
				RAISERROR(@message ,16,2)
				return
			END
		END
	EnD
	--Added by Jaina 07-05-2018	End
	
	--Added by Jaina 21-01-2019 Start
	DECLARE @ExitNoice int = 0	
	SELECT @ExitNoice = Restrict_LeaveAfter_ExitNotice FROM T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Leave_ID=@Leave_ID
	
	IF exists (select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id=@Cmp_id and emp_id=@Emp_id AND (status='H' OR status = 'P'))
				AND @ExitNoice =1
		BEGIN
			 if exists (select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id=@Cmp_id and emp_id=@Emp_id AND (status='H' or status = 'P')
						and ((@From_date between resignation_date AND last_date) AND (@To_Date BETWEEN resignation_date and last_date))	)
				  BEGIN
						set @message = '@@You can''t apply this leave after exit application @@'				
						RAISERROR(@message ,16,2)
						return
				  END	
			  IF exists (SELECT 1 FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID AND (Left_Date <= @From_Date OR  left_date <= @To_date) and Cmp_ID= @Cmp_ID)
					BEGIN
							RAISERROR('Left Employee Can''t Apply Leave',16,2)
							RETURN -1
					END		
			  
		END												
	ELSE
		BEGIN																	
				IF exists (SELECT 1 FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID AND (Left_Date <= @From_Date OR  left_date <= @To_date) and Cmp_ID= @Cmp_ID)
					BEGIN											
						RAISERROR('Left Employee Can''t Apply Leave',16,2)						
						return						
					END				
		END
	
	--Added by Jaina 21-01-2019 End
	
	if @tran_type ='I' 
		BEGIN	
			
			Declare @Leave_negative_Allow tinyint
			Set @Leave_negative_Allow = 0
	   
			Select @Leave_negative_Allow = Leave_negative_Allow,@Leave_Paid_Unpaid = Leave_Paid_Unpaid, @Leave_Max=isnull(Leave_Max,0),
				@apply_hourly = ISNULL(Apply_Hourly,0) 
			from T0040_Leave_Master WITH (NOLOCK) where cmp_id = @Cmp_ID and Leave_ID = @Leave_ID
	   
		  -- Added by Ali 18042014 -- Start
		  -- Overwrite @Leave_Max value 
			Declare @Year as numeric
			Set @Year = YEAR(GETDATE())
		
			IF MONTH(GETDATE())> 3
				BEGIN
					SET @Year = @Year + 1
				END
		
			Declare @date as varchar(20)  
			Set @date = '31-Mar-'+ convert(varchar(5),@Year) 
		
			Set @Leave_Max = (select 
			case when ISNULL(temp.Max_Leave,0)=0 then lm.Leave_Max else temp.Max_Leave end as Leave_Max		
			from T0040_Leave_MASTER LM WITH (NOLOCK) left join 
			(	Select Max_Leave,Leave_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_ID 
				and Cmp_ID = @Cmp_ID and Grd_ID in (Select I.Grd_ID from   dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN 
				(SELECT MAX(Increment_Id) AS Increment_Id,Emp_ID FROM dbo.T0095_Increment IM WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
				WHERE Increment_Effective_date <= @date GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID 
				AND I.Increment_Id = Qry.Increment_Id INNER JOIN
				dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID 
				where em.Cmp_ID = @Cmp_ID and em.Emp_ID = @Emp_Id)
			) as temp on LM.leave_id = temp.leave_id 
			where LM.Leave_ID = @Leave_ID )
		  -- Added by Ali 18042014 -- End

			
			If @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'	--Ankit 22022014
				begin
					set @Total_Leave_Days = @Total_Leave_Days * 0.125
					set @Leave_Period = @Leave_Period * 0.125
				end
		
			
			Declare @Leave_Balance numeric(18,2)
			--Set @Leave_Balance = 0
			
			
			If @Leave_Paid_Unpaid = 'p'
				BEGIN		
					if @Leave_negative_Allow = 0 
						Begin	
							--commented bcoz giving wrong negative bal	
							--select @Leave_Balance = isnull(Leave_Closing,0) - @Leave_Period from T0140_LEave_Transaction where cmp_id = @cmp_id and LEave_id = @LEave_id and emp_id = @Emp_Id
							--and for_date <=(Select max(For_date) from T0140_Leave_Transaction where leave_id = @Leave_id and emp_id = @Emp_id)
				
							-- Alpesh 22-Jul-2011 
				
							Declare @Leave_Short_Name as varchar(25)
							set @Leave_Short_Name = ''
							select @Leave_Short_Name = isnull(Default_Short_Name,'') from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID and Cmp_ID = @Cmp_ID
							--if @Leave_Short_Name <> 'COMP'
			
							if (@Leave_Short_Name <> 'COMP'and @Leave_Short_Name <> 'COPH' and @Leave_Short_Name <> 'COND')
								begin
									select @Leave_Balance = isnull(Leave_Closing,0) - @Leave_Period from T0140_LEave_Transaction WITH (NOLOCK) where cmp_id = @cmp_id and LEave_id = @LEave_id and emp_id = @Emp_Id
									and for_date =(Select max(For_date) from T0140_Leave_Transaction WITH (NOLOCK) where leave_id = @Leave_id and emp_id = @Emp_id and cmp_id = @cmp_id)
				
									set @Leave_Balance = isnull(@Leave_Balance,-1)	
									
									If isnull(@Leave_Balance,0) < 0			
										Begin								
											RAISERROR ('Balance not available on given Date' , 16, 2) 
											Return
										End
								end						
						End		
				END									
			
				
			
			if (@Leave_Period = 0.5 and @Leave_Assign_As = 'Full Day')
			begin
					RAISERROR('@@You Must Select First Half or Second Half For Half Day Leave@@',16,2)
					RETURN 
			end
			--Check Continuous Leave and Max Monthly Leave
			exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period
			,@Leave_Application_ID=@Leave_Application_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date
			
			--Check Consecutive Leave with Present Days
			--exec P_Check_Present_Days_On_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_Application_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date
			
			select @Row_ID = isnull(max(Row_ID),0) +1 from dbo.T0110_Leave_Application_Detail WITH (NOLOCK)
			
			select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
			select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID
		
			set @OldValue = ' New Value # Leave Application : ' + convert(nvarchar(10),@Leave_Application_ID) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Leave Name : ' + @Old_Leave_Name + ' # Leave Id : ' + convert(nvarchar(10),@Leave_ID) + ' # From Date : '  + convert(nvarchar(21),@From_Date) + ' # To Date : ' + convert(nvarchar(21),@To_Date) + ' # Leave Period : ' + convert(nvarchar(10),@Leave_Period ) + ' # Assign as : ' +  @Leave_Assign_As + ' # Reason : ' + @Leave_Reason + ' # Login id : '  + convert(nvarchar(10),@Login_ID) + ' # Date : ' + convert(nvarchar(21),@System_Date) + ' # Half Date Leave : '  +  	convert(nvarchar(21),@Half_Leave_Date) + ' # Leave App Doc : ' + convert(varchar(max),@Leave_App_Docs) + ' # NightHalt : ' + CAST(@NightHalt as varchar(max)) + '# Leave Comp-Off Dates : ' + @strLeaveCompOff_Dates + '# Half_Payment : ' + cast(@Half_Payment as varchar(1))+ '# Warning_Flag : ' + cast(@Warning_flag as varchar(1))+ '# Ruels_Violate : ' + cast(@Rules_Violate as varchar(1))
		
		
			INSERT INTO dbo.T0110_Leave_Application_Detail
				(Leave_Application_ID, Cmp_ID, Leave_ID, From_Date, To_Date, Leave_Period, Leave_Assign_As, Leave_Reason, Row_ID, Login_ID, System_Date, Half_Leave_Date,Leave_App_Doc,leave_Out_time,leave_In_time,NightHalt,Leave_CompOff_Dates,Half_Payment,Warning_flag,Rules_violate) -- Changed by Gadriwala Muslim 22092015
			VALUES  
				(@Leave_Application_ID,@Cmp_ID,@Leave_ID,@From_Date,@To_Date,@Leave_Period,@Leave_Assign_As,@Leave_Reason,@Row_ID,@Login_ID,@System_Date,@Half_Leave_Date,@Leave_App_Docs,@Leave_Out_Time,@Leave_In_Time,@NightHalt,@strLeaveCompOff_Dates,@Half_Payment,@Warning_flag,@Rules_Violate) -- Changed by Gadriwala Muslim 22092015
			
		END		
	ELSE IF @tran_type ='U' 
		BEGIN
			--Alpesh 04-Jul-2012 -> For Continuous Leave Check Beyond Max Limit
			--Set @tmpFrom_Date = DATEADD(d,-1,@From_Date)
			--Set @tmpTo_Date = DATEADD(d,1,@To_Date)
			
			
			select @New_Leave_Name = Leave_Name,@apply_hourly = ISNULL(Apply_Hourly,0) from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID		
		
			
				If @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'
				begin
					set @Total_Leave_Days = @Total_Leave_Days * 0.125
					set @Leave_Period  = @Leave_Period  * 0.125
				end
					
			exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_Application_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date
			
			--Check Consecutive Leave with Present Days
			---exec P_Check_Present_Days_On_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@Leave_Application_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date
			
			Select
				 @old_cmp_id = Cmp_ID 
				,@old_Leave_ID  = Leave_ID 
				,@Old_From_Date = From_Date
				,@Old_To_Date = To_Date 
				,@Old_Leave_Period = Leave_Period 
				,@old_Leave_Assign_As  = Leave_Assign_As 
				,@old_Leave_Reason  = Leave_Reason 
				,@Old_Login_ID = Login_ID 
				,@Old_System_Date = System_Date 
				,@Old_Half_Leave_Date  = Half_Leave_Date
				,@Old_Leave_App_Docs = Leave_App_doc  --Added by rohit on 13122013
				,@OldNightHalt=NightHalt
				,@Old_strLeaveCompOff_Dates = Leave_CompOff_Dates -- Added by Gadriwala Muslim 01102014
				,@Old_Half_Payment =  Half_Payment 
				,@Old_Warning_flag = Warning_flag  -- Added by Gadriwala Muslim 24092015
				,@Old_Rules_Violate = Rules_violate  -- Added by Gadriwala Muslim 24092015
				 from
	         T0110_Leave_Application_Detail  WITH (NOLOCK) where  Row_ID = @Row_ID  
		
		
			select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
			select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @old_Leave_ID
		
			select @New_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
			
			--select @Leave_Application_ID,@old_cmp_id,@old_Emp_Name,@Old_Leave_Name,@old_Leave_ID,@Old_From_Date,@Old_To_Date,@Old_Leave_Period,@Old_Leave_Assign_As
			
			set @OldValue = ' old Value 
								# Leave Application : ' + convert(NVARCHAR(10), @Leave_Application_ID) + ' 
								# Cmp Id : ' + convert(NVARCHAR(10), @old_cmp_id) + ' 
								# Employee Name : ' + @old_Emp_Name + ' 
								# Leave Name : ' + @Old_Leave_Name + ' 
								# Leave Id : ' + convert(NVARCHAR(10), @old_Leave_ID) + ' 
								# From Date : '  + isnull(convert(NVARCHAR(21), @Old_From_Date),'') + ' 
								# To Date : ' + isnull(convert(NVARCHAR(21), @Old_To_Date),'') + ' 
								# Leave Period : ' + convert(NVARCHAR(10), @Old_Leave_Period ) + ' 
								# Assign as : ' +  @Old_Leave_Assign_As + ' 
								# Reason : ' + @Old_Leave_Reason + ' 
								# Login id : '  + convert(NVARCHAR(10), @Old_Login_ID) + ' 
								# Date : ' + convert(NVARCHAR(21), @System_Date) + ' 
								# Half Date Leave : '  +  convert(NVARCHAR(21), @Old_Half_Leave_Date) + ' 
								# Leave App Doc : ' + convert(varchar(max),@Old_Leave_App_Docs) + ' 
								# NightHalt : ' + CAST(@OldNightHalt as varchar(max)) + '
								# Leave_CompOff_Dates :' + @Old_strLeaveCompOff_Dates + '
								# Half_Payment :' + @Old_Half_Payment + '
								# Warning Flag:' + cast(@Old_Warning_flag as varchar(1)) + '
								# Rules violate:' + cast(@Old_Rules_Violate as nvarchar(1))+ ' 
							# New Value 
								# Leave Application : ' + convert(NVARCHAR(10), @Leave_Application_ID) + ' 
								# Cmp Id : ' + convert(NVARCHAR(10), @Cmp_ID) + ' 
								# Employee Name : ' + @New_Emp_Name + ' 
								# Leave Name : ' + @New_Leave_Name + ' 
								# Leave Id : ' + convert(NVARCHAR(10), @Leave_ID) + ' 
								# From Date : '  + convert(NVARCHAR(21), @From_Date) + ' 
								# To Date : ' + convert(NVARCHAR(21), @To_Date) + ' 
								# Leave Period : ' + convert(NVARCHAR(10), @Leave_Period)  + ' 
								# Assign as : ' +  @Leave_Assign_As + ' 
								# Reason : ' + @Leave_Reason + ' 
								# Login id : '  + convert(NVARCHAR(10), @Login_ID) + ' 
								# Date : ' + convert(NVARCHAR(21), @System_Date) + ' 
								# Half Date Leave : '  +  convert(NVARCHAR(21), @Half_Leave_Date) + ' 
								# Leave App Doc : ' + convert(varchar(max), @Leave_App_Docs) + ' 
								# NightHalt : ' + CAST(@nighthalt as varchar(max)) + '
								# Leave_CompOff_Dates :' + @strLeaveCompOff_Dates + '
								# Half_Payment :' + Cast(@Half_Payment as varchar(1)) + '
								# Warning Flag:' + cast(@Warning_flag as varchar(1)) + '
								# Rules violate:' + cast(@Rules_Violate as nvarchar(1))
					

		
			---- End ----				
			--If @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'	--Ankit 22022014
			--		begin
			--			set @Total_Leave_Days = @Total_Leave_Days * 0.125
			--			set @Leave_Period = @Leave_Period * 0.125
			--		end			

			UPDATE dbo.T0110_Leave_Application_Detail SET
				 Cmp_ID = @Cmp_ID
				,Leave_ID = @Leave_ID
				,From_Date = @From_Date
				,To_Date = @To_Date
				,Leave_Period = @Leave_Period
				,Leave_Assign_As = @Leave_Assign_As
				,Leave_Reason = @Leave_Reason
				,Login_ID = @Login_ID
				,System_Date = @System_Date
				,Half_Leave_Date = @Half_Leave_Date
				,Leave_App_Doc = @Leave_App_Docs	
				,leave_Out_time = @Leave_Out_Time
				,leave_In_time = @Leave_In_Time
				,NightHalt = @NightHalt
				,Leave_CompOff_Dates = @strLeaveCompOff_Dates --Added by Gadriwala Muslim 01102014
				,Half_Payment = @Half_Payment
				,Warning_flag = @Warning_flag -- Added by Gadriwala Muslim 22092015
				,Rules_violate = @Rules_Violate -- Added by Gadriwala Muslim 24092015
	        --where  Row_ID = @Row_ID  				                      
	         where Leave_Application_ID = @Leave_Application_ID   --Change By Jaina 27-10-2015
		END
	ELSE IF @tran_type ='D' 
		BEGIN
			select @Row_ID = Row_ID from T0110_LEAVE_APPLICATION_DETAIL  WITH (NOLOCK) where	Leave_Application_ID = @Leave_Application_ID  --Added by Jaina 04-1-2017		
		
			Select	@old_cmp_id = Cmp_ID 
					,@old_Leave_ID  = Leave_ID 
					,@Old_From_Date = From_Date
					,@Old_To_Date = To_Date 
					,@Old_Leave_Period = Leave_Period 
					,@old_Leave_Assign_As  = Leave_Assign_As 
					,@old_Leave_Reason  = Leave_Reason 
					,@Old_Login_ID = Login_ID 
					,@Old_System_Date = System_Date 
					,@Old_Half_Leave_Date  = Half_Leave_Date 
					,@Old_Leave_App_Docs = Leave_App_Doc
					,@OldNightHalt = NightHalt
					,@Old_strLeaveCompOff_Dates = Leave_CompOff_Dates --Added by Gadriwala Muslim 01102014
					from
			T0110_Leave_Application_Detail  WITH (NOLOCK) where  Row_ID = @Row_ID  
			
			select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
			select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @old_Leave_ID
					
			set @OldValue = ' old Value # Leave Application : ' + convert(nvarchar(10),@Leave_Application_ID) + ' # Cmp Id : ' + convert(nvarchar(10),@old_cmp_id) + ' # Employee Name : ' + @old_Emp_Name + ' # Leave Name : ' + @Old_Leave_Name + ' # Leave Id : ' + convert(nvarchar(10),@old_Leave_ID ) + ' # From Date : '  + convert(nvarchar(21),@Old_From_Date) + ' # To Date : ' + convert(nvarchar(21),@Old_To_Date) + ' # Leave Period : ' + convert(nvarchar(10),@Old_Leave_Period)  + ' # Assign as : ' +  @Old_Leave_Assign_As + ' # Reason : ' + @Old_Leave_Reason + ' # Login id : '  + convert(nvarchar(10),@Old_Login_ID) + ' # Date : ' + convert(nvarchar(21),@Old_System_Date) + ' # Half Date Leave : '  +  convert(nvarchar(21),@Old_Half_Leave_Date) + ' # Leave App Doc : ' + convert(varchar(max),@Old_Leave_App_Docs) + ' # NightHalt : ' + Cast(@OldNightHalt as varchar(max)) + '# Leave CompOff Dates : ' + @Old_strLeaveCompOff_Dates + '# Half_Payment : ' + @Old_Half_Payment
		
			
			IF NOT EXISTS (SELECT 1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN 	T0115_Leave_Level_Approval LLA WITH (NOLOCK) ON LA.Leave_Application_ID = LLA.Leave_Application_ID  
								WHERE LA.Cmp_ID = @Cmp_ID AND LA.Leave_Application_ID = @Leave_Application_ID)   --Added By Jaina 07-07-2016 
			BEGIN
				
					DELETE FROM dbo.T0110_Leave_Application_Detail where Row_Id = @Row_Id and  Leave_Application_ID = @Leave_Application_ID 
					--DELETE FROM dbo.T0110_Leave_Application_Detail where Leave_Application_ID = @Leave_Application_ID --because row_Id is not availabel in Table
		
					IF  NOT EXISTS(SELECT Leave_Application_ID  from dbo.T0110_Leave_Application_Detail WITH (NOLOCK)  Where Leave_Application_ID = @Leave_Application_ID )
						BEGIN
							DELETE FROM dbo.T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Application_ID
						End
			END
			ELSE
				BEGIN
						RAISERROR('@@Already Approved By Reporter@@',16,2)
						RETURN 
				END
								
			
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Application',@OldValue,@Emp_Id,@User_Id,@IP_Address,1
		END


