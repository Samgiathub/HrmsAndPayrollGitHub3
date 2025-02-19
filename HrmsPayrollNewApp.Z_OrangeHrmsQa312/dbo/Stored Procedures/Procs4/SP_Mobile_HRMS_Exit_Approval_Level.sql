
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_Exit_Approval_Level]
	@TRAN_ID NUMERIC(18,0) OUTPUT,
	@EXIT_ID NUMERIC(18,0),
	@EMP_ID NUMERIC(18,0),
	@CMP_ID NUMERIC(18,0),
	@BRANCH_ID NUMERIC(18,0),
	@DESIG_ID NUMERIC(18,0),
	@S_EMP_ID NUMERIC(18,0),
	@RESIG_DATE DATETIME,
	@LAST_DATE DATETIME,
	@REASON NUMERIC(18,0),
	@COMMENTS VARCHAR(100),
	@STATUS varchar(5),  --Change by Jaina 23-04-2019
	@IS_REHIRABLE NUMERIC(18,0),
	@FEEDBACK VARCHAR(100),
	@SUP_ACK CHAR(1),
	@INTERVIEW_DATE DATETIME,
	@INTERVIEW_TIME VARCHAR(50),
	@IS_PROCESS CHAR(1),
	@EMAIL_FORWARDTO NVARCHAR(50),
	@DRIVEDATA_FORWARDTO NVARCHAR(50),
	@TRAN_TYPE VARCHAR(1),   
	@RPT_MNG_ID NUMERIC = 0,
	@RPT_LEVEL TINYINT,
	@FINAL_APPROVAL TINYINT,
	@IS_FWD_REJECT TINYINT,
	@Application_date datetime,  --Added By Jaina 11-05-2016
	@Approval_date datetime,  --Added By Jaina 11-05-2016
	@Clearance_ManagerID varchar(max) = '' --Mukti(02082018)Exit Clearance Manager List of cost center
	,@Result VARCHAR(100) OUTPUT
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	DECLARE @Setting_Value as INT
	
	IF UPPER(@TRAN_TYPE) = 'I'
		BEGIN
			
			SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK)

		
			INSERT INTO T0300_EMP_EXIT_APPROVAL_LEVEL(
				TRAN_ID,
				EXIT_ID,
				EMP_ID,
				CMP_ID,
				BRANCH_ID,
				DESIG_ID,
				RESIGNATION_DATE,
				LAST_DATE,
				REASON,
				COMMENTS,
				STATUS,
				IS_REHIRABLE ,
				S_EMP_ID,
				FEEDBACK,
				SUP_ACK,
				INTERVIEW_DATE,
				INTERVIEW_TIME,
				IS_PROCESS,
				EMAIL_FORWARDTO,
				DRIVEDATA_FORWARDTO,
				RPT_MNG_ID,
				RPT_LEVEL,
				FINAL_APPROVAL,
				IS_FWD_REJECT,
				Application_date,  --Added By Jaina 11-05-2016
				Approval_date,  --Added By Jaina 11-05-2016
				Clearance_ManagerID
			)
			VALUES(
				@TRAN_ID,
				@EXIT_ID,
				@EMP_ID,
				@CMP_ID,
				ISNULL(@BRANCH_ID,0),
				ISNULL(@DESIG_ID,0),
				@RESIG_DATE,
				ISNULL(@LAST_DATE,0),
				ISNULL(@REASON,'NULL'),
				ISNULL(@COMMENTS,0),
				@STATUS,
				ISNULL(@IS_REHIRABLE,0),
				@S_EMP_ID,
				ISNULL(@FEEDBACK,'NULL'),
				ISNULL(@SUP_ACK,0),
				@INTERVIEW_DATE,
				@INTERVIEW_TIME,
				@IS_PROCESS,
				@EMAIL_FORWARDTO,
				@DRIVEDATA_FORWARDTO,
				@RPT_MNG_ID,
				@RPT_LEVEL,
				@FINAL_APPROVAL,
				@IS_FWD_REJECT,
				@Application_date,  --Added By Jaina 11-05-2016
				@Approval_date,   --Added By Jaina 11-05-2016
				@Clearance_ManagerID
			)
	
			
			if @STATUS = 'LR'
			begin
				exec SP_Mobile_HRMS_WebService_Exit @exit_id=@EXIT_ID,@emp_id=@EMP_ID,@cmp_id=@CMP_ID,@branch_id=@BRANCH_ID,@desig_id=@DESIG_ID,@s_emp_id=@S_EMP_ID,@resig_date=@RESIG_DATE,@last_date=@LAST_DATE,@reason=@REASON,@comments=@COMMENTS,@status=@STATUS,@is_rehirable=@IS_REHIRABLE,@feedback=@FEEDBACK,@sup_ack=@SUP_ACK,@interview_date=@INTERVIEW_DATE,@interview_time=@INTERVIEW_TIME,@Is_Process=@IS_PROCESS,@Email_ForwardTo=@EMAIL_FORWARDTO,@DriveData_ForwardTo=@DRIVEDATA_FORWARDTO,@left_Id=0,@new_employer='',@Is_terminate=0,@Uniform_return=0,@Exit_Interview=0,@Notice_Period=0,@Is_Death=0,@tran_type='U',@Rpt_Mng_ID=@RPT_MNG_ID,@Application_date=@Application_date,@Exit_App_Doc='',@Clearance_ManagerID=@Clearance_ManagerID,@result = ''
			end

	If(@TRAN_ID > 0)
	Begin
			SET @Result = 'Data Inserted succesfully#True#'
			SELECT @Result
	End

	END
		
		
		if @TRAN_TYPE = 'D'
		begin
		--Added By Mukti(24122019)start
			SELECT @Setting_Value=Setting_Value FROM T0040_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Setting_Name='Once Exit Scheme Final Level Approved then consider Employee as Left'
			IF @Setting_Value=1
				BEGIN
					IF exists(select 1 from T0100_LEFT_EMP WITH (NOLOCK) where cmp_ID = @cmp_ID and Emp_ID = @Emp_ID)
					BEGIN
						Raiserror('@@can''t Delete Exit Approval,Employee already Left @@',18,2)
						return -1
					END
				END	
		--Added By Mukti(24122019)end
					
			if exists(select 1 from T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK) where RPT_Level = @RPT_Level + 1 and cmp_ID = @cmp_ID and Emp_ID = @Emp_ID and Exit_id = @Exit_id)
				begin
					Raiserror('@@can''t Delete Exit Approval, Reference Exists @@',18,2)
					return -1
				end
			IF exists(select 1 from T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK) where  Tran_ID = @Tran_ID  and cmp_ID = @cmp_ID)
				begin
					delete from T0300_EMP_EXIT_APPROVAL_LEVEL where  Tran_ID = @Tran_ID  and cmp_ID = @cmp_ID
				end	
			else
			begin
						Raiserror('@@can''t Delete Exit Approval, It''s not Exists @@',18,2)
						return -1
				end			
		end
END

