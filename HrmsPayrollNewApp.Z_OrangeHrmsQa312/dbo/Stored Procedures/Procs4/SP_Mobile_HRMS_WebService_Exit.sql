
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Exit]
	@exit_id numeric(18,0),
	@emp_id numeric(18,0),
	@cmp_id numeric(18,0),
	@branch_id numeric(18,0),
	@desig_id numeric(18,0),
	@s_emp_id numeric(18,0),
	@resig_date datetime,
	@last_date datetime,
	@reason numeric(18,0),
	@comments varchar(100),
	@status varchar(5), --Change by Jaina 24-04-2019
	@is_rehirable numeric(18,0),
	@feedback varchar(100),
	@sup_ack char(1),
	@interview_date datetime,
	@interview_time varchar(50),
	@Is_Process char(1),
	@Email_ForwardTo nvarchar(50),
	@DriveData_ForwardTo nvarchar(50),
	-----------left-------
	@left_Id numeric(18,0),
	@new_employer as varchar(100),
	@Is_terminate as tinyint,
	@Uniform_return numeric(18,0),
	@Exit_Interview numeric(18,0),
	@Notice_Period numeric(18,0),
	@Is_Death tinyint,
	@tran_type varchar(1),   
	@Rpt_Mng_ID numeric = 0, -- Added by Gadriwala 20112013
	@Application_date datetime =null,  --Added By Jaina 11-05-2016
	@Exit_App_Doc varchar(max) = '', --Added by Rajput on 11052018
	@Clearance_ManagerID varchar(max) = '', --Mukti(02082018)Exit Clearance Manager List of cost center
	@Result VARCHAR(100) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--select * from T0200_Emp_ExitApplication
	 if @s_emp_id = 0
		set @s_emp_id = null
	Declare @res as varchar(250)
	DECLARE @reason_id as INT
	Declare @Setting_value as INT
	
	If UPPER(@tran_type) = 'I'
		BEGIN
			---Added By Jaina 04-06-2016
			IF NOT EXISTS( SELECT 1 FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE TYPE = 'Exit' AND EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID)
			BEGIN
				--Raiserror('Can''t do application for Exit, your Exit scheme have not assigned',18,2)
				SET @Result = 'Can not do application for Exit, your Exit scheme have not assigned#False#'
				SELECT @Result
				RETURN -1	
			END
			
			
			select @exit_id = isnull(max(exit_id),0) + 1 From T0200_Emp_ExitApplication WITH (NOLOCK)
		
			Insert into T0200_Emp_ExitApplication(
				exit_id,
				emp_id,
				cmp_id,
				branch_id,
				desig_id,
				resignation_date,
				last_date,
				reason,
				comments,
				status,
				is_rehirable ,
				s_emp_id,
				feedback,
				sup_ack,
				interview_date,
				interview_time,
				Is_Process,
				Email_ForwardTo,
				DriveData_ForwardTo,
				Rpt_Mng_ID,
				Application_date,
				Exit_App_Doc,
				Clearance_ManagerID
			)
			values(
				@exit_id,
				@emp_id,
				@cmp_id,
				ISNULL(@branch_id,0),
				ISNULL(@desig_id,0),
				@resig_date,
				isnull(@last_date,0),
				isnull(@reason,'null'),
				isnull(@comments,0),
				@status,
				isnull(@is_rehirable,0),
				@s_emp_id,
				isnull(@feedback,'null'),
				isnull(@sup_ack,0),
				@interview_date,
				@interview_time,
				@Is_Process,
				@Email_ForwardTo,
				@DriveData_ForwardTo,
				@Rpt_Mng_ID,
				@Application_date,   --Added By Jaina 04-06-2016
				@Exit_App_Doc, -- Added by Rajput on 11052018
				@Clearance_ManagerID
			)



			
			IF @STATUS = 'P' AND @IS_PROCESS = 'Y'
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM T0200_EXIT_INTERVIEW WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)	
						EXEC GET_INTERVIEW_QUESTION_ASSIGNED @CMP_ID = @CMP_ID,@EXIT_ID = @EXIT_ID,@EMP_ID =@EMP_ID,@INSERT_QUESTIONS = 1
			END			

			SET @Result = 'Exit Applicaiton Done#True#'+CAST(@exit_id AS varchar(11))

			SELECT @Result
		END
	
	If @tran_type ='U' --general update
		begin	
			update T0200_Emp_ExitApplication
			set resignation_date = @resig_date, 
			last_date = @last_date,
			s_emp_id = @s_emp_id,
			sup_ack = @sup_ack,
			feedback=@feedback,
			is_rehirable = @is_rehirable,
			status = @status,
			Is_Process = @Is_Process,
			Rpt_Mng_ID = @Rpt_Mng_ID, -- Added by Gadriwala 20112013
			Clearance_ManagerID=@Clearance_ManagerID
			where
			exit_id = @exit_id and cmp_id = @cmp_id
			
			--ADDED BY GADRIWALA MUSLIM 30082016
			
			IF @STATUS = 'P' AND @IS_PROCESS = 'Y'
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM T0200_EXIT_INTERVIEW WITH (NOLOCK) WHERE EMP_ID = @EMP_ID)	
						EXEC GET_INTERVIEW_QUESTION_ASSIGNED @CMP_ID = @CMP_ID,@EXIT_ID = @EXIT_ID,@EMP_ID =@EMP_ID,@INSERT_QUESTIONS = 1
				END
			
			--Added By Mukti(24122019)start
			SELECT @Setting_Value=Setting_Value FROM T0040_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Setting_Name='Once Exit Scheme Final Level Approved then consider Employee as Left'
			IF @Setting_Value=1
				BEGIN
					If @STATUS = 'P'
						Begin					
							SELECT @reason_id =reason from T0200_Emp_ExitApplication WITH (NOLOCK) where exit_id=@exit_id
							SELECT @res=Reason_Name from T0040_Reason_Master WITH (NOLOCK) where Res_Id=@reason_id
							--select @res,@last_date,@resig_date
							EXEC P0100_LEFT_EMP @left_Id,@cmp_id,@emp_id,@last_date,@resig_date,@reason,@new_employer,@Is_terminate,'I',@Uniform_return,@Exit_Interview,@Notice_Period,@Is_Death,@resig_date,1,@Rpt_Mng_ID					
						End
				END
			--Added By Mukti(24122019)end
		end
	if @tran_type = 'M' -- superior update
		begin
			update T0200_Emp_ExitApplication
			set 
			is_rehirable = @is_rehirable,
			s_emp_id = @s_emp_id,
			feedback = @feedback,
			sup_ack = @sup_ack
			where
			exit_id = @exit_id and cmp_id = @cmp_id
		end
	if @tran_type = 'S' -- Schedule interview
		Begin
			update T0200_Emp_ExitApplication
			set interview_date = @interview_date,
			interview_time = @interview_time,
			status = @status
			Where cmp_id = @cmp_id and exit_id = @exit_id 
		End
	if @tran_type = 'C' -- Change status
	Begin
	--print 'kk'
		update T0200_Emp_ExitApplication
		set 
		status = @status
		Where cmp_id = @cmp_id and exit_id = @exit_id 
		If @tran_type ='C' and @status = 'A'
			Begin
				set @tran_type = 'I'
				--If @reason = 1
				--	set @res = 'Career Growth'
				--Else If @reason = 2
				--	set @res = 'Change in career growth'
				--Else If @reason = 3
				--	set @res = 'Furthur Education'
				--Else If @reason = 4
				--	set @res = 'Re-Location'
				--Else If @reason = 5
				--	set @res = 'Health Reason'
				--Else If @reason = 6
				--	set @res = 'Personal Reason'
				--Else If @reason = 7
				--	set @res = ''
				SELECT @reason_id =reason from T0200_Emp_ExitApplication WITH (NOLOCK) where exit_id=@exit_id
				SELECT @res=Reason_Name from T0040_Reason_Master WITH (NOLOCK) where Res_Id=@reason_id
				
				exec P0100_LEFT_EMP @left_Id,@cmp_id,@emp_id,@last_date,@resig_date,@res,@new_employer,@Is_terminate,@tran_type,@Uniform_return,@Exit_Interview,@Notice_Period,@Is_Death,@resig_date,1,@Rpt_Mng_ID
			End
	End
	--if @tran_type = 'D'
	--	begin
	--		if exists (select exit_id from T0200_Exit_Interview where exit_id=@exit_id and cmp_id= @cmp_id)
	--			begin
	--			print @exit_id
	--			end
	--		else
	--			delete from T0200_Emp_ExitApplication 
	--							where exit_id=@exit_id and cmp_id = @cmp_id
	--	end
	



