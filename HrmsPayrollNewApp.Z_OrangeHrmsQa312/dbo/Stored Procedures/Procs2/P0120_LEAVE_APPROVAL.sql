CREATE PROCEDURE [dbo].[P0120_LEAVE_APPROVAL]  
    @Leave_Approval_ID numeric output  
   ,@Leave_Application_ID numeric  
   ,@Cmp_ID numeric  
   ,@Emp_ID numeric  
   ,@S_Emp_ID numeric  
   ,@Approval_Date datetime  
   ,@Approval_Status char(1)  
   ,@Approval_Comments varchar(250)  
   ,@Login_ID numeric  
   ,@System_Date datetime  
   ,@tran_type as varchar(1)  
   ,@User_Id numeric(18,0) = 0 
   ,@IP_Address varchar(30)= '' 
   ,@Is_Backdated_App tinyint =0  --added jimit 25122014
   ,@Is_Auto_Leave_From_Salary tinyint = 0	--added by Binal 09042020

AS
	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON  
   
	DECLARE @str_Emp_Code as varchar(5)  
	DECLARE @Emp_Code as varchar(5)  
  
	Declare @Old_Leave_Approval_ID numeric
	Declare @Old_Cmp_ID numeric
	Declare @Old_Leave_ID numeric
	Declare @Old_From_Date datetime
	Declare @Old_To_Date datetime
	Declare @Old_Leave_Period numeric(18,1)
	Declare @Old_Leave_Assign_As varchar(15)
	Declare @Old_Leave_Reason varchar(100)
	Declare @Old_Login_ID numeric(18,0)		 
	Declare @Old_System_Date datetime
	Declare @Old_Is_import int 
	Declare @Old_tran_type varchar(1)
	Declare @Old_M_Cancel_WO_HO tinyint 
	Declare @Old_Half_Leave_Date datetime 
	declare @OldValue as varchar(max)
	Declare @Old_Emp_Name				nvarchar(60)			
	Declare @Old_Leave_Name				nvarchar(50)	
	Declare @New_Emp_Name				nvarchar(60)			
	Declare @New_Leave_Name				nvarchar(50)	
	Declare @cut_off_date As Datetime
	 
	set @Old_Leave_Approval_ID = 0
	set @Old_Cmp_ID  = 0
	set @Old_Leave_ID  = 0
	set @Old_From_Date  = null
	set @Old_To_Date  = null
	set @Old_Leave_Period  = 0
	set @Old_Leave_Assign_As  = ''
	set @Old_Leave_Reason  = ''
	set @Old_Login_ID  = 0
	set @Old_System_Date  = null
	set @Old_Is_import  = 0
	set @Old_tran_type  = ''
	set @Old_M_Cancel_WO_HO  = 0
	set @Old_Half_Leave_Date  = null
	set @OldValue = ''
	set @New_Emp_Name = ''
	set @New_Leave_Name = ''
	Set @Old_Emp_Name				= ''
	Set @Old_Leave_Name			= ''
	
    
	if @Leave_application_ID =0  
		set @Leave_application_ID = null  
     
	if @S_Emp_ID = 0   
		set @S_Emp_ID =null  
		
	if @Approval_Comments='Leave Approved From Salary.'
		Set @Is_Auto_Leave_From_Salary =1 

	Declare @Fromdate as Date
	Select @Fromdate = From_Date from T0100_LEAVE_APPLICATION LA inner join T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAD.Leave_Application_ID 
	where LA.Leave_Application_ID = @Leave_Application_ID  and LA.Emp_ID = @Emp_ID and La.Cmp_ID = @Cmp_ID
	
	if @EMP_ID = 0
	Begin 
	
			If ((SELECT count(1) FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
										T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
										AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
										T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@Fromdate)) AND [MONTH] = MONTH(EOMONTH(@Fromdate))
										inner join T0100_LEAVE_APPLICATION LA on LA.Emp_ID = E.Emp_ID
										inner join T0110_LEAVE_APPLICATION_DETAIL LAD on LAD.Leave_Application_ID = LA.Leave_Application_ID
										WHERE E.CMP_ID = @CMP_ID) > 0)
			BEGIN
				Raiserror('@@ Attendance Lock for this Period. @@',16,2)
				return -1								
			END
	END
	ELSe
	BEgIN
	
			If ((SELECT count(1) FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
										T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
										AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
										T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@Fromdate)) AND [MONTH] = MONTH(EOMONTH(@Fromdate))
										inner join T0100_LEAVE_APPLICATION LA on LA.Emp_ID = E.Emp_ID
										inner join T0110_LEAVE_APPLICATION_DETAIL LAD on LAD.Leave_Application_ID = LA.Leave_Application_ID
										WHERE E.CMP_ID = @CMP_ID aND SPE.EMP_ID = @Emp_Id) > 0)
			BEGIN
				Raiserror('@@ Attendance Lock for this Period. @@',16,2)
				return -1								
			END
	ENd
	
	IF EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL WITH (NOLOCK) WHERE Leave_Application_ID=@Leave_Application_ID AND Approval_Status = @Approval_Status)
		AND @tran_type IN ('I', 'U') AND @Leave_Approval_ID = 0
		BEGIN 
		--set  @Leave_Approval_ID=
				RETURN;
				
		END

	If Isnull(@Leave_Approval_Id,0) > 0 AND @tran_type = 'D'
		BEGIN
			Select @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID from T0120_LEAVE_APPROVAL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID
			Select @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID from T0100_LEAVE_APPLICATION WITH (NOLOCK) where Leave_Application_ID = @Leave_Approval_ID
		END


	DECLARE @Is_Consider_LWP_In_Same_Month tinyint -- Added by Hardik 22/02/2019 for Havmor
	Set @Is_Consider_LWP_In_Same_Month = 0
	
	SELECT @Is_Consider_LWP_In_Same_Month = ISNULL(Setting_Value,0) 
	FROM T0040_SETTING WITH (NOLOCK)
	WHERE Setting_Name = 'Consider LWP in Same Month for Cutoff Salary' And Cmp_Id = @Cmp_Id

	If @Is_Consider_LWP_In_Same_Month = 1 And EXISTS (SELECT 1 FROM T0210_LWP_Considered_Same_Salary_Cutoff WITH (NOLOCK) WHERE Emp_Id = @Emp_Id And Leave_Approval_ID = @Leave_Approval_Id)
		BEGIN
			RAISERROR ('Reference Exists in Salary',16,2)
			RETURN -1
		END	
		
	If @tran_type  = 'I'  
		Begin  
   
			-- commented by rohit because flag pass from page.
			-- --condition added by Hardik for Email approval, previous month leave not approved from email
			-- If Isnull(@Leave_Application_ID,0) > 0
				--Select @Is_Backdated_App = is_backdated_application from T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Application_ID
	
			SELECT  @Leave_Approval_ID = Isnull(max(Leave_Approval_ID),0) + 1  From T0120_LEAVE_APPROVAL WITH (NOLOCK) 
			IF EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL WITH (NOLOCK) WHERE Leave_Application_ID=@Leave_Application_ID AND EMP_ID=@EMP_ID and Cmp_ID=@Cmp_ID) -- ADDED BY RAJPUT ON 02022018 FOR APPROVE TIME DUPLICATE ROW WAS INSERTED
				BEGIN 
			
				   SELECT @Leave_Approval_ID=Leave_Approval_ID FROM T0120_LEAVE_APPROVAL WITH (NOLOCK) WHERE Leave_Application_ID=@Leave_Application_ID AND EMP_ID=@EMP_ID and Cmp_ID=@Cmp_ID
				   RETURN	
						
				END 
				if(isnull(@Leave_Application_ID,0) <> 0)
				Begin
					set @emp_id=(select Top 1 emp_id from T0100_LEAVE_APPLICATION where Leave_application_id=@Leave_Application_ID and cmp_id=@Cmp_ID)
				END

			INSERT INTO T0120_LEAVE_APPROVAL  
						(Leave_Approval_ID, Leave_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status, Approval_Comments, Login_ID,System_Date,Is_Backdated_App,Is_Auto_Leave_From_Salary)                
			VALUES     
					(@Leave_Approval_ID,@Leave_Application_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@Approval_Date,@Approval_Status,@Approval_Comments,@Login_ID,@System_Date,@Is_Backdated_App,@Is_Auto_Leave_From_Salary)   
					 --- select 'True','Leave Approved Successfully'  -- commented by Yogesh on 28062023
					 
					-- select * from T0120_LEAVE_APPROVAL where Leave_Approval_ID=@Leave_Approval_ID
		End  
	Else if @Tran_Type = 'U'  
		BEGIN  
			DELETE FROM T0130_LEAVE_APPROVAL_DETAIL where Leave_Approval_ID = @Leave_Approval_ID
			UPDATE  T0120_LEAVE_APPROVAL  
			SET		Leave_Application_ID = @Leave_Application_ID,
					Cmp_ID = @Cmp_ID, 
					Emp_ID = @Emp_ID,
					S_Emp_ID = @S_Emp_ID,
					Approval_Date = @Approval_Date,
					Approval_Status = @Approval_Status,    
					Approval_Comments = @Approval_Comments,
					Login_ID = @Login_ID,
					System_Date = @System_Date,
					Is_Backdated_App = @Is_Backdated_App,
					Is_Auto_Leave_From_Salary = @Is_Auto_Leave_From_Salary 
		   where Leave_Approval_ID = @Leave_Approval_ID  
		END
	ELSE IF @Tran_Type = 'D'
		BEGIN
			

			Declare @From_Date	datetime
			Declare @To_Date	datetime
			declare @Branch_ID as numeric(18,0)
			declare @m_cancel_wo_ho_tmp as tinyint
			declare @Present_import_tran_id as nvarchar(1000)
			declare @Extra_days as nvarchar(1000)
			declare @Tran_id as numeric(18,0)
			declare @Rm_emp_id as numeric(18,0)
			DECLARE @Leave_Out_Time DATETIME 
			DECLARE @Leave_In_Time DATETIME 
			declare @Leave_Approval_Status varchar(10)
			declare @Half_Leave datetime
			Declare @Leave_type varchar(50)

			Declare @App_FromDate datetime
			Declare @App_Todate datetime
			Declare @App_Code numeric(18,0)
			Declare @MSG varchar(500)
			Declare @Is_Backdated as tinyint
					   
			Select @Is_Backdated = ISNULL(is_backdated_application,0),@App_FromDate = From_Date,@App_Todate = To_Date,@App_Code = Application_Code
			From T0100_LEAVE_APPLICATION LA WITH (NOLOCK) inner join
				T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID = LAd.Leave_Application_ID
			Where LA.Leave_Application_Id In (Select Leave_Application_ID From T0120_LEAVE_APPROVAL WITH (NOLOCK) Where Leave_Approval_ID = @Leave_Approval_ID)
			
			--Added by Jaina 28-10-2020 (Case is : Leave Application is done for 13-10 For Sick Leave And Approve it for 15-10 and change it Privilege leave. Again apply for 13-10 Sick Leave. And Delete 15-10 Leave Approval That time Duplicate Leave Show. So this validation is added.)
			
			
			DECLARE @LEAVE_PERIOD AS NUMERIC(18,0) ,
			@LEAVE_ASSIGN_AS AS VARCHAR (50)
			
			SELECT @LEAVE_PERIOD = Leave_Period,@LEAVE_ASSIGN_AS = Leave_Assign_As FROM T0130_LEAVE_APPROVAL_DETAIL 
			WHERE Cmp_ID = @Cmp_ID AND Leave_Approval_ID = @Leave_Approval_ID


			--select *
			--From T0100_LEAVE_APPLICATION LA WITH (NOLOCK) inner join
			--	T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID = LAd.Leave_Application_ID
			--Where ((LAD.From_Date >= @App_FromDate and LAD.From_Date <= @App_Todate) or
			--		(lad.To_Date >= @App_FromDate  and lad.To_Date <= @App_Todate) or
			--		(@App_FromDate >= LAD.From_Date and @App_FromDate <= LAD.To_Date) or
			--		(@App_Todate >=LAD.From_Date and @App_Todate <=LAD.To_Date))								
			--	and Emp_ID =@Emp_ID and Application_Code <> @App_Code --and Leave_Period >= 1

			--RETURN

			DECLARE @Leave_Count as numeric
	
			select @Leave_Count = Count(LA.Leave_Application_ID)
			From T0100_LEAVE_APPLICATION LA WITH (NOLOCK) inner join
				T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID = LAd.Leave_Application_ID
			Where ((LAD.From_Date >= @App_FromDate and LAD.From_Date <= @App_Todate) or
					(lad.To_Date >= @App_FromDate  and lad.To_Date <= @App_Todate) or
					(@App_FromDate >= LAD.From_Date and @App_FromDate <= LAD.To_Date) or
					(@App_Todate >=LAD.From_Date and @App_Todate <=LAD.To_Date))								
				and Emp_ID =@Emp_ID and Application_Code <> @App_Code and Leave_Period >= 1 


			if @Leave_Count > 1
			begin
							if exists (select 1
					From T0100_LEAVE_APPLICATION LA WITH (NOLOCK) inner join
						T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID = LAd.Leave_Application_ID
					Where ((LAD.From_Date >= @App_FromDate and LAD.From_Date <= @App_Todate) or
							(lad.To_Date >= @App_FromDate  and lad.To_Date <= @App_Todate) or
							(@App_FromDate >= LAD.From_Date and @App_FromDate <= LAD.To_Date) or
							(@App_Todate >=LAD.From_Date and @App_Todate <=LAD.To_Date))								
						and Emp_ID =@Emp_ID and Application_Code <> @App_Code and Leave_Period >= 1 ) -- added leave period by deepal for deleting two half leaves for same date 18022022
					Begin
						Set @MSG ='Leave Already Exists For This Date : ' + convert(varchar,@App_FromDate,103)
						Raiserror( @MSG ,16,2)
									return -1	
					End
			end

			
			DECLARE @empId as numeric(18) = 0
			Declare @FDate as date
			SELECT @empId = Emp_ID , @FDate = From_Date from T0120_LEAVE_APPROVAL LA inner join T0130_LEAVE_APPROVAL_DETAIL LAD on LA.Leave_Approval_ID = LAD.Leave_Approval_ID
			where LAD.Leave_Approval_ID = @Leave_Approval_ID --and Cmp_ID = @Cmp_ID 
			If ((SELECT count(1) FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
										T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN							  
										T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN							
										T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@FDate))
										AND [MONTH] = MONTH(EOMONTH(@FDate))
								WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @empId) > 0)
			BEGIN
				Raiserror('@@ Attendance Lock for this Period. @@',16,2)
				return -1								
			END
		

			--if exists (select 1
			--From T0100_LEAVE_APPLICATION LA WITH (NOLOCK) inner join
			--	T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) on LA.Leave_Application_ID = LAd.Leave_Application_ID
			--Where ((LAD.From_Date >= @App_FromDate and LAD.From_Date <= @App_Todate) or
			--		(lad.To_Date >= @App_FromDate  and lad.To_Date <= @App_Todate) or
			--		(@App_FromDate >= LAD.From_Date and @App_FromDate <= LAD.To_Date) or
			--		(@App_Todate >=LAD.From_Date and @App_Todate <=LAD.To_Date))								
			--	and Emp_ID =@Emp_ID and Application_Code <> @App_Code)
			--Begin
			--	Set @MSG ='Leave Already Exists For This Date : ' + convert(varchar,@App_FromDate,103)
			--	Raiserror( @MSG ,16,2)
			--				return -1	
			--End

			
			
			
			IF ISNULL(@Leave_Application_ID,0) = 0
				BEGIN
					

					Select @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@Leave_Approval_Status = Approval_Status  
					from T0120_LEAVE_APPROVAL WITH (NOLOCK)
					where Leave_Approval_ID = @Leave_Approval_ID

					Select @From_Date = From_Date, @To_Date = To_Date, @Leave_Out_Time = Leave_out_time, @Leave_In_Time = Leave_In_Time,@Half_Leave = Half_Leave_Date,@Leave_type = Leave_Assign_As 
					from T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)
					where Leave_Approval_ID = @Leave_Approval_ID


					select @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID,@From_Date = Application_Date from T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Approval_ID
				
					--Set @Is_Backdated = 0
					--Comment by Jaina  4-11-2020 Put it above
					--Select @Is_Backdated = ISNULL(is_backdated_application,0),@App_FromDate = From_Date,@App_Todate = To_Date,@App_Code = Application_Code
					--From T0100_LEAVE_APPLICATION LA inner join
					--	T0110_LEAVE_APPLICATION_DETAIL LAD on LA.Leave_Application_ID = LAd.Leave_Application_ID
					--Where LA.Leave_Application_Id In (Select Leave_Application_ID From T0120_LEAVE_APPROVAL Where Leave_Approval_ID = @Leave_Approval_ID)

				
				
					set @Branch_ID = 0
				
					select  @Branch_ID = Branch_ID
					From	T0095_Increment I WITH (NOLOCK)
							INNER JOIN (SELECT	MAX(Increment_Id) as Increment_Id , Emp_ID 
										FROM	T0095_Increment WITH (NOLOCK)   
										where	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID    
										GROUP BY emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
					Where	I.Emp_ID = @Emp_ID  
						  
								
					--commented by Mukti(15112017)start	
					--IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WHERE (MONTH =  MONTH(@To_Date) and YEAR =  year(@To_Date)) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0) And @Is_Backdated = 0 AND @Is_Backdated_App = 0)
					--		Begin
					--		    select  @cut_off_date= isnull(MAX(Cutoff_Date),@To_Date) from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID  
					--			if @cut_off_date >= @To_Date 
					--			begin
					--				Raiserror('Month Lock',16,2)
					--				return -1
					--			end
					--		End
					--commented by Mukti(15112017)end
				
					--Added by Mukti(15112017)start
					DECLARE @MONTH_ST_DATE DATETIME   
					DECLARE @MONTH_END_DATE DATETIME  
					DECLARE @MONTH_LOCK INTEGER 
					DECLARE @YEAR_LOCK INTEGER   
					DECLARE @Cutoffdate_Salary DATETIME 
					DECLARE @CUTOFFDATE AS VARCHAR(15)  
				
					SELECT @Cutoffdate_Salary=isnull(Cutoffdate_Salary,'1900-01-01') FROM DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID =@Cmp_id	AND BRANCH_ID = @Branch_id
					AND FOR_DATE = (SELECT MAX(FOR_DATE) FROM DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE
					FOR_DATE <=@FROM_DATE AND BRANCH_ID = @Branch_id AND CMP_ID =@Cmp_id)
						
					SET @CUTOFFDATE = Convert(Varchar(4),DatePart(YYYY,@FROM_DATE)) + '-' + Convert(Varchar(2),MONTH(@FROM_DATE)) + '-' + Convert(Varchar(2),DatePart(D,@Cutoffdate_Salary)) 
					
										
					if @Cutoffdate_Salary <> '1900-01-01'
						BEGIN
							if @FROM_DATE > @CUTOFFDATE   
								BEGIN
									 SET @MONTH_LOCK =  Month(DateAdd(MONTH,1,@FROM_DATE))  
									 SET @YEAR_LOCK=YEAR(DateAdd(YEAR,1,@FROM_DATE))  
								END
							ELSE  
								BEGIN
									SET @MONTH_LOCK = Month(@FROM_DATE)  
									SET @YEAR_LOCK=YEAR(@FROM_DATE)  
								END
						END
					ELSE
						BEGIN
							SELECT @MONTH_ST_DATE= Sal_St_Date,@MONTH_END_DATE = Sal_End_Date FROM F_Get_SalaryDate (@Cmp_id,@Branch_id,MONTH(@FROM_DATE),YEAR(@FROM_DATE))
							If @FROM_DATE >= @MONTH_ST_DATE And @FROM_DATE <= @MONTH_END_DATE  
								BEGIN
								  SET @MONTH_LOCK = Month(@FROM_DATE)  
								  SET @YEAR_LOCK=YEAR(@FROM_DATE)  
								END
							Else  
								BEGIN
								  SET @MONTH_LOCK = Month(DateAdd(MONTH,1,@FROM_DATE))  
								  SET @YEAR_LOCK=YEAR(DateAdd(YEAR,1,@FROM_DATE))  
								 END  
						END
						
					IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE (MONTH =  @MONTH_LOCK and YEAR =  @YEAR_LOCK) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0) And @Is_Backdated = 0)
						Begin
						   IF EXISTS(select 1 from T0040_SETTING WITH (NOLOCK) where cmp_id=@CMP_ID and setting_name='Restrict User to Apply Leave if Month is Locked' and setting_value = 1)  
								BEGIN
									Raiserror('Month Lock',16,2)
									return -1								
								END							
						End
					--Added by Mukti(15112017)end		
				
					IF EXISTS( select 1 from dbo.T0150_LEAVE_CANCELLATION LC1 WITH (NOLOCK) where  LC1.cmp_id=@Cmp_ID and LC1.Emp_ID = @Emp_ID 
							   and  LC1.Leave_Approval_ID=@Leave_Approval_ID --and (LC1.For_Date >= '2012-12-17 00:00:00.000' and LC1.For_Date <= '2012-12-17 00:00:00.000')
							   )     -- JAinith Patel -20-12-2012 - Cancelation exits then dont delete leave approval
							begin
						
								Raiserror('Leave can''t be Deleted Reference Exist',16,2)
								return -1
							end
				
					if @Leave_Approval_Status ='R'   --Added by Jaina 17-04-2017
						BEGIN
							BEGIN TRY
								  exec P_Check_Leave_Availability @Cmp_Id=@Cmp_Id,@Emp_ID=@Emp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Half_Date=@Half_Leave,@Leave_type=@Leave_type,@Raise_Error=1
							END TRY
							BEGIN CATCH
									DECLARE @ERROR_MSG VARCHAR(MAX)
									SET @ERROR_MSG =  ERROR_MESSAGE()
									RAISERROR(@ERROR_MSG,16,2)
									RETURN -1		
							END CATCH
						 END
						 				
				  --Added by Jaina 14-05-2018
				 IF exists(SELECT 1 FROM T0135_Paternity_Leave_Detail PL WITH (NOLOCK) INNER JOIN
					T0090_Change_Request_Approval CR WITH (NOLOCK) on PL.For_Date = CR.Child_Birth_Date AND pl.Emp_Id = CR.Emp_ID 
					where Pl.Cmp_Id=@Cmp_Id AND PL.Emp_Id=@Emp_id AND PL.Laps_Status='Done')
				BEGIN
					Raiserror('Leave can''t be Deleted After Validate Period',16,2)
					return -1
				END
					 ---Commented by Hardik 03/07/2015 for If employee taken first half and second half leave with Application and now he want to delete first half leave then this condition will not allow to delete				    
					set @Present_import_tran_id = 0
					set @Extra_days = 0
							
						
							
					select @m_cancel_wo_ho_tmp = M_Cancel_WO_HO from T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID
						
					update T0120_LEAVE_APPROVAL set M_Cancel_WO_HO = isnull(@m_cancel_wo_ho_tmp,0) where Leave_Approval_ID = @Leave_Approval_ID
							 
					select @Extra_days = Arrear_Days , @Present_import_tran_id = Present_import_tran_id 
					from T0140_BACK_DATED_ARREAR_LEAVE WITH (NOLOCK) where  Leave_approval_id = @Leave_Approval_ID
							 
					IF EXISTS (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days = @Extra_days)
						BEGIN
							DECLARE @Month Numeric
							Declare @Year Numeric
									
							SELECT @Month = Month , @Year = Year from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days = @Extra_days
									
							IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(Month_End_Date) = @Month 
											AND YEAR(Month_End_Date) = @YEAR and Emp_ID = @Emp_id)
								BEGIN								
									Raiserror('Leave can''t be Deleted, Salary Exists',16,2)
									return -1
								END
						END

						
					
					--Added By Jimit 07072018
					Declare @Is_Backdated_Leave as tinyint
					Declare @Leave_From_date as DateTime
					Set @Is_Backdated_Leave = 0	
					
					if @Leave_Approval_ID > 0
						BEGIN
							select	@Is_Backdated_Leave = IsNull(Is_Backdated_App,0) ,
									@Leave_From_date = Lad.To_Date
							from	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)Inner Join
									T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LAD.Leave_Approval_ID = La.Leave_Approval_ID 							
							where	Emp_Id = @Emp_id and La.Leave_Approval_ID = @Leave_Approval_ID				
						END
					--else
					--	begin										
					--		select	@Is_Backdated_Leave = IsNull(lad.,0),
					--				@Leave_From_date = Lad.To_Date
					--		from	T0100_LEAVE_APPLICATION LA Inner Join
					--				T0110_LEAVE_APPLICATION_DETAIL LAD ON LAD.Leave_Application_ID = La.Leave_Application_ID 															
					--		where	Emp_Id = @Emp_id and La.Leave_Application_ID = @Leave_Application_ID	
					--	END
					
					
				
					--print 'aa'
					--print @Leave_From_date
					--print 'cc'
					IF @Is_Backdated_Leave = 0
						BEGIN
							
							 IF EXISTS (SELECT	1 
										FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)												
										WHERE	MONTH(Month_End_Date) = Month(@From_Date) 
												AND YEAR(Month_End_Date) = year(@From_Date) and Emp_ID = @Emp_id
												ANd @Leave_From_date < Isnull(Cutoff_Date,Month_End_Date))
								BEGIN
								--Print @From_Date
								-- Print @Emp_id 
								--Print @Leave_From_date
								
									Raiserror('@@Leave can''t be Deleted, Salary Exists@@',16,2)
									return -1
								END
						END
					--Ended				
					
													
					if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days = @Extra_days)
						begin
							update T0190_MONTHLY_PRESENT_IMPORT set Backdated_Leave_Days = 0 where Tran_ID = @Present_import_tran_id 		
						end
					else if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days > @Extra_days)
						begin
							update T0190_MONTHLY_PRESENT_IMPORT set Backdated_Leave_Days = Backdated_Leave_Days - @Extra_days where Tran_ID = @Present_import_tran_id 
						end
					else if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days < @Extra_days)
						begin
							update T0190_MONTHLY_PRESENT_IMPORT set Backdated_Leave_Days = 0 where Tran_ID = @Present_import_tran_id 						
						end
							
					Delete T0140_BACK_DATED_ARREAR_LEAVE where Leave_Approval_ID = @Leave_Approval_ID 
							 
					---Delete If all Field are Zero - Ankit 28062016
					IF EXISTS( SELECT  1 FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Tran_ID = @Present_import_tran_id and Backdated_Leave_Days = 0 )
						BEGIN
							DELETE FROM T0190_MONTHLY_PRESENT_IMPORT 
							WHERE EMP_ID =@EMP_ID AND Tran_ID = @Present_import_tran_id
								AND P_Days = 0 AND Extra_Days = 0 AND Backdated_Leave_Days = 0 
									
						END
					---
							 
							 
							 
						-- Added By Hiral 09 Aug,2013 (Start)
					Declare @Level_Leave_App_ID As Numeric(18,0),@Leaveapp_id as numeric

					--added by Mr.Mehul on 12122022 @semping to delete level wise leave application 
					DECLARE @SEmpid as numeric(18,0) 
					Select @SEmpid = Emp_id from T0011_LOGIN where cmp_id = @cmp_id and Login_ID = @User_Id
					--added by Mr.Mehul on 12122022 @semping to delete level wise leave application 


					/*Following Condition Added By Nimesh on 22-Oct-2018
						If Application is pending or not approved for final level then
						@Leave_Approval_ID is considered as a @Level_Leave_App_ID
					*/ 
					
					if @Approval_Status = 'P'
						AND EXISTS(SELECT 1 FROM T0115_Leave_Level_Approval WITH (NOLOCK) WHERE S_Emp_ID=@S_Emp_ID AND Leave_Application_ID= @Leave_Approval_ID)
						AND NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL WITH (NOLOCK) WHERE  Leave_Approval_ID= @Leave_Approval_ID)
						SET @Level_Leave_App_ID= @Leave_Approval_ID
						
					ELSE 
						SELECT @Level_Leave_App_ID = Leave_Application_ID From T0120_LEAVE_APPROVAL WITH (NOLOCK) Where Leave_Approval_ID = @Leave_Approval_ID

					
					If @Level_Leave_App_ID Is Not Null Or @Level_Leave_App_ID <> 0
						Begin
							Delete From T0115_Leave_Level_Approval Where Leave_Application_ID = @Level_Leave_App_ID and S_Emp_ID = @SEmpid --added by Mr.Mehul on 12122022 @semping to delete level wise leave application 
						End
						
					-- Added By Hiral 09 Aug,2013 (End)
					
					DELETE FROM T0115_Leave_Level_Approval where Tran_ID = @Tran_id and Leave_Application_ID IN (SELECT Leave_Application_ID from T0120_LEAVE_APPROVAL where Leave_Approval_ID = @Leave_Approval_ID)
					
					Select @Leaveapp_id = Leave_Application_id from T0120_LEAVE_APPROVAL Where Leave_Approval_ID = @Leave_Approval_ID  

					
					if @SEmpid is null 
					begin 
						DELETE FROM T0115_Leave_Level_Approval where Leave_Application_ID = @Leaveapp_id
					end
					else
					begin
						DELETE FROM T0115_Leave_Level_Approval where Leave_Application_ID = @Leave_Approval_ID and S_Emp_ID = @SEmpid --added by Mr.Mehul on 12122022 @semping to delete level wise leave application 	
					end
				
					Delete from T0130_LEAVE_APPROVAL_DETAIL where Leave_Approval_ID = @Leave_Approval_ID  --Nikunj 29-March-2010 because while deleting it shows error of f.k.
					Delete From T0120_LEAVE_APPROVAL Where Leave_Approval_ID = @Leave_Approval_ID  

					--DELETE FROM T0110_LEAVE_APPLICATION_DETAIL WHERE Leave_Application_ID = @Leave_Approval_ID
					DELETE FROM T0110_LEAVE_APPLICATION_DETAIL WHERE Leave_Application_ID IN (SELECT Leave_Application_ID from T0120_LEAVE_APPROVAL where Leave_Approval_ID = @Leave_Approval_ID)
					DELETE FROM T0100_LEAVE_APPLICATION WHERE Leave_Application_ID IN (SELECT Leave_Application_ID from T0120_LEAVE_APPROVAL where Leave_Approval_ID = @Leave_Approval_ID)
					--DELETE FROM T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Approval_ID
												 
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
						,@Old_Half_Leave_Date  = Half_Leave_Date from
					 T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where  Leave_Approval_ID = @Leave_Approval_ID
			
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @old_Leave_ID
		
			
					set @OldValue = ' old Value # Leave Approval : ' + convert(nvarchar(10),ISNULL(@Leave_Approval_ID,0)) + ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@old_cmp_id,0)) + ' # Employee Name : ' + ISNULL(@old_Emp_Name,'') + ' # Leave Name : ' + ISNULL(@Old_Leave_Name,'') + ' # Leave Id : ' + convert(nvarchar(10),ISNULL(@old_Leave_ID,0)) + ' # From Date : '  +  CASE ISNULL(@Old_From_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_From_Date) END + ' # To Date : ' + CASE ISNULL(@Old_To_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_To_Date) END + ' # Leave Period : ' + convert(nvarchar(10),ISNULL(@Old_Leave_Period,0))  + ' # Assign as : ' +  ISNULL(@Old_Leave_Assign_As,0) + ' # Reason : ' + ISNULL(@Old_Leave_Reason,'') + ' # Login id : '  + convert(nvarchar(10),ISNULL(@Old_Login_ID,0)) + ' # Date : ' + CASE ISNULL(@Old_System_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_System_Date) END + ' # Half Date Leave : '  +  CASE ISNULL(@Old_Half_Leave_Date,0) WHEN 0 THEN '' ELSE  convert(nvarchar(21),@Old_Half_Leave_Date) END   
				end
			Else if @Approval_Status = 'A' and ISNULL(@Leave_Application_Id,0) > 0 
				BEGIN
					
					Select @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID  from T0120_LEAVE_APPROVAL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID
					Select @From_Date = From_Date, @To_Date = To_Date from T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID
					
					

					
					set @Branch_ID = 0
				
					select  @Branch_ID = Branch_ID
								From T0095_Increment I WITH (NOLOCK) inner join     
								 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)   
								 where Increment_Effective_date <= @To_Date    
								 and Cmp_ID = @Cmp_ID    
								 group by emp_ID) Qry on    
								 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
							  Where I.Emp_ID = @Emp_ID  
						  
					
					IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE (MONTH =  MONTH(@To_Date) and YEAR =  year(@To_Date)) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0) And @Is_Backdated = 0 AND @Is_Backdated_App = 0)
							Begin
								--Raiserror('Month Lock',16,2)
								--return -1
							
								select  @cut_off_date= isnull(MAX(Cutoff_Date),@To_Date) from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID  

								if @cut_off_date >= @To_Date 
								begin
									Raiserror('Month Lock',16,2)
									return -1
								end
							End
					IF EXISTS( select 1 from dbo.T0150_LEAVE_CANCELLATION LC1 WITH (NOLOCK) where  LC1.cmp_id=@Cmp_ID and LC1.Emp_ID = @Emp_ID 
							   and  LC1.Leave_Approval_ID=@Leave_Approval_ID --and (LC1.For_Date >= '2012-12-17 00:00:00.000' and LC1.For_Date <= '2012-12-17 00:00:00.000')
							   )     -- JAinith Patel -20-12-2012 - Cancelation exits then dont delete leave approval
							begin
						
								Raiserror('Leave can''t be Deleted Reference Exist',16,2)
								return -1
							end
				
				    
					 IF EXISTS(select LA1.Leave_Application_ID from  dbo.T0110_Leave_Application_Detail LAD1 WITH (NOLOCK) inner join
										T0100_LEAVE_APPLICATION LA1 WITH (NOLOCK) ON LAD1.Leave_Application_ID = LA1.Leave_Application_ID  
										left outer join T0120_leave_Approval LP1 WITH (NOLOCK) ON LP1.Leave_Application_ID = LA1.Leave_Application_ID  
										left outer join dbo.T0130_Leave_Approval_Detail LAPD1 WITH (NOLOCK) ON LAPD1.Leave_Approval_ID = LP1.Leave_Approval_ID  
							  where  LA1.cmp_id=@Cmp_ID and LA1.Emp_ID = @Emp_ID  
								 and LA1.application_Status <> 'R' and isnull(LAPD1.Leave_Approval_ID,@Leave_Approval_ID)<>@Leave_Approval_ID
								 and ((@From_Date >= LAD1.from_date and @From_Date <= LAD1.to_date) or 
									  (@To_Date >= LAD1.from_date and 	@To_Date <= LAD1.to_date) or 
									  (LAD1.from_date >= @From_Date and LAD1.from_date <= @To_Date) or
									  (LAD1.to_date >= @From_Date and LAD1.to_date <= @To_Date)
									  )
								 and isnull(LAPD1.Leave_Approval_ID,0) not in (select  LP2.Leave_Approval_ID from T0120_leave_Approval LP2 WITH (NOLOCK) inner join
																		 dbo.T0130_Leave_Approval_Detail LAPD2 WITH (NOLOCK) ON LAPD2.Leave_Approval_ID = LP2.Leave_Approval_ID  
																		 inner join dbo.T0150_LEAVE_CANCELLATION LC2 WITH (NOLOCK) ON LC2.Leave_Approval_ID = LP2.Leave_Approval_ID 
																	 where  LC2.cmp_id=@Cmp_ID and LC2.Emp_ID = @Emp_ID
																		 and (LC2.For_Date >= @From_Date and LC2.For_Date <= @To_Date)
																	   )
								)							           
						   begin
					   
								Raiserror('Leave can''t be Deleted Reference Exist',16,2)
								return -1
							end
				
					set @Present_import_tran_id = 0
					set @Extra_days = 0
							
					select @m_cancel_wo_ho_tmp = M_Cancel_WO_HO from T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID
					update T0120_LEAVE_APPROVAL set M_Cancel_WO_HO = @m_cancel_wo_ho_tmp where Leave_Approval_ID = @Leave_Approval_ID
							 
					select @Extra_days = Arrear_Days , @Present_import_tran_id = Present_import_tran_id from T0140_BACK_DATED_ARREAR_LEAVE WITH (NOLOCK) where  Leave_approval_id = @Leave_Approval_ID
			 
					if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days = @Extra_days)
						begin
							--if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days = @Extra_days AND P_Days = 0)
							--	begin
							--		delete T0190_MONTHLY_PRESENT_IMPORT where Tran_ID = @Present_import_tran_id 
							--	end
							--else
								begin
									update T0190_MONTHLY_PRESENT_IMPORT set Extra_Days = 0,Backdated_Leave_Days = 0 where Tran_ID = @Present_import_tran_id   -- Backdated_Leave_Days = 0 ADDED BY RAJPUT ON 07082018 IMPORT TABLE DOES NOT RESET 
								end
						end
					else if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days > @Extra_days)
						begin
							update T0190_MONTHLY_PRESENT_IMPORT set Backdated_Leave_Days = Backdated_Leave_Days - @Extra_days where Tran_ID = @Present_import_tran_id 
						end
					else if exists (SELECT 1 from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) where Emp_ID = @Emp_id AND Tran_ID = @Present_import_tran_id AND Backdated_Leave_Days < @Extra_days)
						begin
							update T0190_MONTHLY_PRESENT_IMPORT set Backdated_Leave_Days = 0 where Tran_ID = @Present_import_tran_id 						
						end
							
					Delete T0140_BACK_DATED_ARREAR_LEAVE where Leave_Approval_ID = @Leave_Approval_ID 
							 
					---Delete If all Field are Zero ---- ADDED BY RAJPUT ON 07082018
					IF EXISTS( SELECT  1 FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Tran_ID = @Present_import_tran_id and Backdated_Leave_Days = 0 )
						BEGIN
						
							DELETE FROM T0190_MONTHLY_PRESENT_IMPORT WHERE EMP_ID =@EMP_ID AND Tran_ID = @Present_import_tran_id
								AND P_Days = 0 AND Extra_Days = 0 AND Backdated_Leave_Days = 0 
									
						END
					--- End ---		 

					set @Rm_emp_id = 0
					set @Tran_id = 0
							
					select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_Leave_Level_Approval WITH (NOLOCK) where  Leave_Application_ID = @Leave_Application_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_Leave_Level_Approval WITH (NOLOCK) where  Leave_Application_ID = @Leave_Application_ID )
							
					if @Rm_emp_id = @S_Emp_ID 
						begin
							delete T0115_Leave_Level_Approval where Tran_ID = @Tran_id and Leave_Application_ID = @Leave_Application_ID
						end
							 
				--Added By Jimit 07072018
					--Declare @Is_Backdated_Leave as tinyint
					Set @Is_Backdated_Leave = 0	
					
					select @Is_Backdated_Leave = IsNull(Is_Backdated_App,0) from T0120_LEAVE_APPROVAL WITH (NOLOCK) 
					where Emp_Id = @Emp_id and Leave_Approval_ID = @Leave_Approval_ID				
					IF @Is_Backdated_Leave = 0
						BEGIN
						
							 IF EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE MONTH(Month_End_Date) = Month(@From_Date) 
									AND YEAR(Month_End_Date) = year(@From_Date) and Emp_ID = @Emp_id)
								BEGIN
									Raiserror('Leave can''t be Deleted Reference Exist In Salary',16,2)
									return -1
								END
						END
					--Ended	
					Delete from T0130_LEAVE_APPROVAL_DETAIL where Leave_Approval_ID = @Leave_Approval_ID  --Nikunj 29-March-2010 because while deleting it shows error of f.k.
					Delete From T0120_LEAVE_APPROVAL Where Leave_Approval_ID = @Leave_Approval_ID  
							 
							 
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
						,@Old_Half_Leave_Date  = Half_Leave_Date from
					 T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where  Leave_Approval_ID = @Leave_Approval_ID
			
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @old_Leave_ID
		
			
					set @OldValue = ' old Value # Leave Approval : ' + convert(nvarchar(10),ISNULL(@Leave_Approval_ID,0)) + ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@old_cmp_id,0)) + ' # Employee Name : ' + ISNULL(@old_Emp_Name,'') + ' # Leave Name : ' + ISNULL(@Old_Leave_Name,'') + ' # Leave Id : ' + convert(nvarchar(10),ISNULL(@old_Leave_ID,0)) + ' # From Date : '  +  CASE ISNULL(@Old_From_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_From_Date) END + ' # To Date : ' + CASE ISNULL(@Old_To_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_To_Date) END + ' # Leave Period : ' + convert(nvarchar(10),ISNULL(@Old_Leave_Period,0))  + ' # Assign as : ' +  ISNULL(@Old_Leave_Assign_As,0) + ' # Reason : ' + ISNULL(@Old_Leave_Reason,'') + ' # Login id : '  + convert(nvarchar(10),ISNULL(@Old_Login_ID,0)) + ' # Date : ' + CASE ISNULL(@Old_System_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_System_Date) END + ' # Half Date Leave : '  +  CASE ISNULL(@Old_Half_Leave_Date,0) WHEN 0 THEN '' ELSE  convert(nvarchar(21),@Old_Half_Leave_Date) END   
							 
				end			
			else if @Approval_Status = 'P' and isnull(@Leave_Application_ID,0) > 0
				begin 
				
					set @Rm_emp_id = 0
					set @Tran_id = 0
				
					select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_Leave_Level_Approval WITH (NOLOCK) where  Leave_Application_ID = @Leave_Application_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_Leave_Level_Approval WITH (NOLOCK) where  Leave_Application_ID = @Leave_Application_ID )
				
					if @Rm_emp_id = @S_Emp_ID 
						begin
							delete T0115_Leave_Level_Approval where Tran_ID = @Tran_id and Leave_Application_ID = @Leave_Application_ID
						end
				
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
						,@Old_Half_Leave_Date  = Half_Leave_Date from
					 T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where  Leave_Approval_ID = @Leave_Approval_ID
			
					select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID
					select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @old_Leave_ID
		
			
					set @OldValue = ' old Value # Leave Approval : ' + convert(nvarchar(10),ISNULL(@Leave_Approval_ID,0)) + ' # Cmp Id : ' + convert(nvarchar(10),ISNULL(@old_cmp_id,0)) + ' # Employee Name : ' + ISNULL(@old_Emp_Name,'') + ' # Leave Name : ' + ISNULL(@Old_Leave_Name,'') + ' # Leave Id : ' + convert(nvarchar(10),ISNULL(@old_Leave_ID,0)) + ' # From Date : '  +  CASE ISNULL(@Old_From_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_From_Date) END + ' # To Date : ' + CASE ISNULL(@Old_To_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_To_Date) END + ' # Leave Period : ' + convert(nvarchar(10),ISNULL(@Old_Leave_Period,0))  + ' # Assign as : ' +  ISNULL(@Old_Leave_Assign_As,0) + ' # Reason : ' + ISNULL(@Old_Leave_Reason,'') + ' # Login id : '  + convert(nvarchar(10),ISNULL(@Old_Login_ID,0)) + ' # Date : ' + CASE ISNULL(@Old_System_Date,0) WHEN 0 THEN '' ELSE convert(nvarchar(21),@Old_System_Date) END + ' # Half Date Leave : '  +  CASE ISNULL(@Old_Half_Leave_Date,0) WHEN 0 THEN '' ELSE  convert(nvarchar(21),@Old_Half_Leave_Date) END   
				end	
				
			IF ISNULL(@Leave_Application_ID,0) = 0
				BEGIN
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Admin Leave Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
				END
			ELSE
				BEGIN
					exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
				END
			
		END  
 RETURN
