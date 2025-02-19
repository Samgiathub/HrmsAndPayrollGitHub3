

CREATE PROCEDURE [dbo].[P0200_Pre_ExitApplication]
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
	@status varchar(5),  --Change by Jaina 24-04-2019 
	@is_rehirable numeric(18,0),
	@feedback varchar(100),
	@sup_ack char(1),
	@interview_date datetime,
	@interview_time varchar(50),
	@Is_Process char(1),
	@Email_ForwardTo nvarchar(50),
	@DriveData_ForwardTo nvarchar(50),
	@Application_date datetime,   --Added By Jaina 04-06-2016
	@Clearance_ManagerID varchar(max) = '', --Added By Mukti(18082018) --Change by Jaina 21-08-2018
	@Rpt_Mng_ID int	 --Mukti(25122019)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
Declare @eid  numeric(18,0)
Declare @feedId as numeric(18,0)
Declare @Qid as integer
Declare @cnt as integer 
declare @Exit_Interview	int
 
set @cnt = 1

	if @s_emp_id = 0
		set @s_emp_id = null
	If @cmp_id <> 0
		Begin
			
			--Added By Jaina 22-04-2016
			IF NOT EXISTS( SELECT 1 FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE TYPE = 'Exit' AND EMP_ID = @EMP_ID AND CMP_ID = @CMP_ID)
			BEGIN
				Raiserror('Can''t do application for Exit, your Exit scheme have not assigned',18,2)
				RETURN -1	
			END
			
			--Added by Jaina 15-12-2018
			IF exists (SELECT 1 FROM T0200_Emp_ExitApplication WITH (NOLOCK) where emp_id=@EMP_ID and status='A')
			BEGIN
				Raiserror('Exit Application already exits',18,2)
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
				Application_date,  --Added By Jaina 04-06-2016
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
				@Application_date,  -- Added By Jaina 04-06-2016
				@Clearance_ManagerID
			)
			
			Select @Qid=Count(Question_Id) from T0200_Question_Master WITH (NOLOCK) Where Cmp_Id = @cmp_id and Is_Active= 1
			--While @cnt <= @qid
			--	Begin
			--		Select @eid = isnull(exit_id,0) from T0200_Exit_Interview where emp_id=@emp_id and cmp_id=@cmp_id 
			--		If @eid = 0
			--			Begin
							
			--				Update T0200_Exit_Interview set exit_id = @exit_id where emp_id = @emp_id and cmp_id = @cmp_id and Interview_id = (select top(@Qid) Interview_id From T0200_Exit_Interview Where cmp_id = @cmp_id and emp_id=@emp_id)
			--			End
			--		Select @eid = ISNULL(exit_id,0) from T0200_Exit_Feedback Where emp_id = @emp_id and cmp_id = @cmp_id 
			--			If @eid = 0
			--				Begin
							
			--					Update T0200_Exit_Feedback set exit_id = @exit_id where emp_id=@emp_id and cmp_id = @cmp_id and exit_feedback_id = (select top(@Qid) exit_feedback_id From T0200_Exit_Feedback Where cmp_id = @cmp_id and emp_id=@emp_id)
			--				End
			--		End
			--		set @cnt = @cnt+1
			--	End
			
			Select @eid = isnull(exit_id,0) from T0200_Exit_Interview WITH (NOLOCK) where emp_id=@emp_id and cmp_id=@cmp_id 
					Begin
					Select @eid = isnull(exit_id,0) from T0200_Exit_Interview WITH (NOLOCK) where emp_id=@emp_id and cmp_id=@cmp_id 
					If @eid = 0
						Begin
							
							Update T0200_Exit_Interview set exit_id = @exit_id where emp_id = @emp_id and cmp_id = @cmp_id and exit_id Is Null
						End
					Select @eid = ISNULL(exit_id,0) from T0200_Exit_Feedback WITH (NOLOCK) Where emp_id = @emp_id and cmp_id = @cmp_id 
						If @eid = 0
							Begin
							
								Update T0200_Exit_Feedback set exit_id = @exit_id where emp_id=@emp_id and cmp_id = @cmp_id and exit_id Is Null
							End
					End
					set @cnt = @cnt+1
				End
				
		--Added By Mukti(24122019)start
		Declare @res as varchar(250)
		DECLARE @reason_id as INT
		DECLARE @left_Id as INT
		Declare @Setting_value as INT
		SELECT @Setting_Value=Setting_Value FROM T0040_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Setting_Name='Once Exit Scheme Final Level Approved then consider Employee as Left'
		IF @Setting_Value=1
			BEGIN
				If @STATUS = 'P'
					Begin					
						SELECT @reason_id =reason from T0200_Emp_ExitApplication WITH (NOLOCK) where exit_id=@exit_id
						SELECT @res=Reason_Name from T0040_Reason_Master WITH (NOLOCK) where Res_Id=@reason_id
						--select @res,@last_date,@resig_date
						IF @Is_Process='Y'
							SET @Exit_Interview=1
						ELSE	
							SET @Exit_Interview=0
										
						EXEC P0100_LEFT_EMP 0,@cmp_id,@emp_id,@last_date,@resig_date,@reason,'',0,'I',0,@Exit_Interview,0,0,@resig_date,1,@Rpt_Mng_ID					
					End
			END
		--Added By Mukti(24122019)end
END



