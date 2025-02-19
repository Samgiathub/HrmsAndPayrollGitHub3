

CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Travel_application]
	 @Travel_Application_ID	NUMERIC(18,0) 	
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Application_Date		Datetime
	,@Application_Code		Varchar(20)
	,@Application_Status	Char(1)
	,@Login_ID				NUMERIC(18,0)
	,@chk_Adv				tinyint
	,@chk_Agenda			tinyint
	,@Tour_Agenda			nvarchar(Max)
	,@IMP_Business_Appoint  nvarchar(Max)
	,@KRA_Tour				nvarchar(max)
	,@Attached_Doc_File		nvarchar(max)
	,@Tran_Type				Char(1) 
	,@Chk_International		tinyint=0
	--,@User_Id numeric(18,0) = 0 
	,@User_Id				Varchar(20) = '0'
	,@IP_Address varchar(30)= '192.168.1.94'
	,@TravelTypeId			NUMERIC(18,0) 
	,@Result				varchar(100) OUTPUT
	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Create_Date As Datetime
	Declare @Modify_Date As Datetime
	Declare @App_Code As Numeric(18,0)
	
	Set @Create_Date = GETDATE()
	Set @Modify_Date = GETDATE()
	
	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL
	
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''

	Declare @SchemeId as numeric(18,0)	  = 0
	Declare @ReportLevel as numeric(18,0) = 0

	SELECT @SchemeId = Scheme_ID 
	FROM T0095_EMP_SCHEME S
	INNER JOIN (
		SELECT max(Effective_Date) as EffDate,Tran_ID 
		FROM T0095_EMP_SCHEME S1 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
		group by Tran_id
	) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
	WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'

	Select @ReportLevel = Rpt_Level  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID

	set @ReportLevel = @ReportLevel + 1
	
	select @S_Emp_ID = Emp_Superior from T0080_EMP_MASTER where emp_id = @Emp_ID and Cmp_ID = @Cmp_ID
	
	If UPPER(@Tran_Type) = 'I' OR @TRAN_TYPE ='M'
		Begin
			
			SET @APPLICATION_STATUS = 'P'
			IF (@TRAN_TYPE = 'M')
				SET @APPLICATION_STATUS = 'D'
			
			
			---- ADDED BY RAJPUT ON 12042019 DELETE CODE REPLACE FROM PAGE LEVEL TO SP -----
			
			IF EXISTS(SELECT 1  FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
				DELETE FROM T0110_TRAVEL_ADVANCE_DETAIL WHERE CMP_ID=@CMP_ID AND Travel_App_ID=@Travel_Application_ID
			IF EXISTS(SELECT 1  FROM T0110_Travel_Application_Other_Detail WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
				DELETE FROM T0110_Travel_Application_Other_Detail WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@Travel_Application_ID
			IF EXISTS(SELECT 1  FROM T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
				DELETE FROM T0110_TRAVEL_APPLICATION_DETAIL WHERE CMP_ID=@CMP_ID AND Travel_App_ID=@Travel_Application_ID
			IF EXISTS(SELECT 1  FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND TRAVEL_APP_ID = @Travel_Application_ID)
				DELETE FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@Travel_Application_ID
			
			---- END ----
			
			IF EXISTS	(SELECT 1	FROM T0100_TRAVEL_APPLICATION WITH (NOLOCK)
									WHERE TRAVEL_APPLICATION_ID = @Travel_Application_ID AND EMP_ID = @Emp_ID AND 
									CMP_ID = @Cmp_ID AND APPLICATION_STATUS='D')
				BEGIN
					
					
					UPDATE	T0100_TRAVEL_APPLICATION
					SET		APPLICATION_DATE=@APPLICATION_DATE,
							CHK_ADV=@CHK_ADV,
							APPLICATION_STATUS=@APPLICATION_STATUS,
							CHK_AGENDA=@CHK_AGENDA,
							TOUR_AGENDA=@TOUR_AGENDA,
							IMP_BUSINESS_APPOINT=@IMP_BUSINESS_APPOINT,
							KRA_TOUR=@KRA_TOUR,
							ATTACHED_DOC_FILE=@ATTACHED_DOC_FILE,
							CHK_INTERNATIONAL=@CHK_INTERNATIONAL
					WHERE	TRAVEL_APPLICATION_ID=@TRAVEL_APPLICATION_ID	
							
				END	
			ELSE
				BEGIN
					Select @Travel_Application_ID = ISNULL(MAX(Travel_Application_ID),0) + 1 From T0100_TRAVEL_APPLICATION WITH (NOLOCK)
					Set @App_Code = @Travel_Application_ID + 1000		
					set @Application_Code = cast(@App_Code as Varchar(20))  

					Insert Into T0100_TRAVEL_APPLICATION 
							(Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Application_Date, Application_Code, Application_Status, Login_ID, Create_Date,chk_Adv,chk_Agenda,Tour_Agenda,IMP_Business_Appoint,KRA_Tour,Attached_Doc_File,Chk_International)
						Values (@Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Application_Date, @Application_Code, @Application_Status, @Login_ID, @Create_Date,@chk_Adv,@chk_Agenda,@Tour_Agenda,@IMP_Business_Appoint,@KRA_Tour,@Attached_Doc_File,@Chk_International)
						
				
					-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table = 'T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
					-- Add By Mukti 11072016(end)	
				END
				IF(@Travel_Application_ID > 0)
				Begin
					set @Result = 'Succesfully#true#'+cast(@Travel_Application_ID as varchar(30))
				End
				
		End
	Else If UPPER(@Tran_Type)='U'  --Added by sumit 01092015
		begin
		
			
			---- ADDED BY RAJPUT ON 12042019 DELETE CODE REPLACE FROM PAGE LEVEL TO SP -----
			
			IF EXISTS(SELECT 1  FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
				DELETE FROM T0110_TRAVEL_ADVANCE_DETAIL WHERE CMP_ID=@CMP_ID AND Travel_App_ID=@Travel_Application_ID
			IF EXISTS(SELECT 1  FROM T0110_Travel_Application_Other_Detail WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
				DELETE FROM T0110_Travel_Application_Other_Detail WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@Travel_Application_ID
			IF EXISTS(SELECT 1  FROM T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
				DELETE FROM T0110_TRAVEL_APPLICATION_DETAIL WHERE CMP_ID=@CMP_ID AND Travel_App_ID=@Travel_Application_ID
			IF EXISTS(SELECT 1  FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND TRAVEL_APP_ID = @Travel_Application_ID)
				DELETE FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@Travel_Application_ID
			
					exec P9999_Audit_get @table='T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				
			update T0100_TRAVEL_APPLICATION
			set Application_Date=@Application_Date,
			chk_Adv=@chk_Adv,
			Application_Status=@Application_Status,
			chk_Agenda=@chk_Agenda,
			Tour_Agenda=@Tour_Agenda,
			IMP_Business_Appoint=@IMP_Business_Appoint,
			KRA_Tour=@KRA_Tour,
			Attached_Doc_File=@Attached_Doc_File,
			chk_international=@Chk_International
			where Travel_Application_ID=@Travel_Application_ID
			
				exec P9999_Audit_get @table = 'T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
			
				IF(@Travel_Application_ID > 0)
				Begin
					set @Result = 'Travel Application Updated Successfully#True#'
					select @Result
				End

		End	 --Ended by sumit		
	Else If UPPER(@Tran_Type) = 'D'
		Begin
			-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)
				
			DELETE FROM dbo.T0110_TRAVEL_ADVANCE_DETAIL where Travel_App_ID = @Travel_Application_ID
			DELETE FROM dbo.T0110_TRAVEL_APPLICATION_DETAIL where  Travel_App_ID = @Travel_Application_ID     
			DELETE FROM dbo.T0110_Travel_Application_Other_Detail where  Travel_App_ID = @Travel_Application_ID     
			DELETE FROM dbo.T0100_TRAVEL_APPLICATION where Travel_Application_ID= @Travel_Application_ID
			DELETE FROM DBO.T0110_TRAVEL_APPLICATION_MODE_DETAIL WHERE Travel_APP_ID= @Travel_Application_ID
			Delete from T0080_Travel_HycScheme where AppId = @Travel_Application_ID

				IF(@Travel_Application_ID > 0)
				Begin
					set @Result = 'Travel Application deleted Successfully#True#'
					select @Result
				End
			
		End
					set @User_Id = cast(@Login_ID as int)	

	exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
END


