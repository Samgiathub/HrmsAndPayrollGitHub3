CREATE PROCEDURE [dbo].[Mobile_HRMS_P0100_TRAVEL_APPLICATION]
	 @Travel_Application_ID	NUMERIC(18,0)	
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Login_ID				NUMERIC(18,0)
	,@Tran_Type				CHAR(1) 
	,@User_Id				NUMERIC(18,0) = 0 
	,@IP_Address			VARCHAR(30)= ''
	,@TravelTypeId			NUMERIC(18,0)
	,@Application_Status	char
	,@Application_Date		Datetime
	,@TourAgendaPlanned		XML
	,@Travel_Details		XML
	,@Travel_Adv_Details    XML
	,@Travel_Other_Details  XML
	,@Result				VARCHAR(70)OUTPUT
	,@AttachedDocuments		as varchar(max)
	,@Chk_International     int = 0

AS
BEGIN	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
		DECLARE @Create_Date As Datetime
		DECLARE @Modify_Date As Datetime
		DECLARE @App_Code As Numeric(18,0)
		DECLARE @Application_Code Varchar(20)
		SET @Create_Date = GETDATE()
		SET @Modify_Date = GETDATE()
	
		IF @S_Emp_ID = 0
			Set @S_Emp_ID = NULL
	
		DECLARE @OldValue as  varchar(max)
		DECLARE @String_val as varchar(max)
		SET @String_val=''
		SET @OldValue =''

		DECLARE @SchemeId as numeric(18,0) = 0
		DECLARE @ReportLevel as numeric(18,0) = 0

		SELECT @SchemeId = Scheme_ID 
		FROM T0095_EMP_SCHEME S
		INNER JOIN (
			SELECT max(Effective_Date) as EffDate,Tran_ID 
			FROM T0095_EMP_SCHEME S1 
			WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
			group by Tran_id
		) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'

		SELECT @ReportLevel = Rpt_Level  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID

		SET @ReportLevel = @ReportLevel + 1

		SELECT @S_Emp_ID = Emp_Superior from T0080_EMP_MASTER where emp_id = @Emp_ID and Cmp_ID = @Cmp_ID

		IF UPPER(@Tran_Type) = 'I' 
			BEGIN
				IF EXISTS(SELECT 1  FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
					DELETE FROM T0110_TRAVEL_ADVANCE_DETAIL WHERE CMP_ID=@CMP_ID AND Travel_App_ID=@Travel_Application_ID
				IF EXISTS(SELECT 1  FROM T0110_Travel_Application_Other_Detail WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
					DELETE FROM T0110_Travel_Application_Other_Detail WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@Travel_Application_ID
				IF EXISTS(SELECT 1  FROM T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND Travel_App_ID = @Travel_Application_ID)
					DELETE FROM T0110_TRAVEL_APPLICATION_DETAIL WHERE CMP_ID=@CMP_ID AND Travel_App_ID=@Travel_Application_ID
				IF EXISTS(SELECT 1  FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND TRAVEL_APP_ID = @Travel_Application_ID)
					DELETE FROM T0110_TRAVEL_APPLICATION_MODE_DETAIL WHERE CMP_ID=@CMP_ID AND TRAVEL_APP_ID=@Travel_Application_ID
				
				
				SELECT @Travel_Application_ID = ISNULL(MAX(Travel_Application_ID),0) + 1 From T0100_TRAVEL_APPLICATION WITH (NOLOCK)
				
				Set @App_Code = @Travel_Application_ID + 1000		
				set @Application_Code = cast(@App_Code as Varchar(20))  
					
					IF(@TourAgendaPlanned.exist('/NewDataSet/TourAgendaPlanned') = 1)
						BEGIN
							SELECT 
							Table1.value('(Tour_Agenda/text())[1]','VARCHAR(200)') AS Tour_Agenda, 
							Table1.value('(IMP_Business_Appoint/text())[1]','VARCHAR(200)') AS IMP_Business_Appoint,
							Table1.value('(KRA_Tour/text())[1]','VARCHAR(200)') AS KRA_Tour
							INTO #MyTeamDetailsTemp FROM @TourAgendaPlanned.nodes('/NewDataSet/TourAgendaPlanned') AS Temp(Table1)

							MERGE T0100_TRAVEL_APPLICATION AS TARGET                      
							USING #MyTeamDetailsTemp AS SOURCE ON Travel_Application_ID = @Travel_Application_ID
							WHEN NOT MATCHED BY TARGET THEN                              
								INSERT                      
								(                      
									Tour_Agenda,IMP_Business_Appoint,KRA_Tour,Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Application_Date, Application_Code, Application_Status, Login_ID ,Create_Date,chk_Adv,chk_Agenda,Attached_Doc_File,Chk_International							
								)                      
								VALUES                      
								(                      
									Tour_Agenda,IMP_Business_Appoint,KRA_Tour,@Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Application_Date, @Application_Code, @Application_Status, @Login_ID, @Create_Date,0,0,@AttachedDocuments,@Chk_International
								); 
						END
					Else
					BEGIN
							INSERT into T0100_TRAVEL_APPLICATION             
								(                      
									Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Application_Date, Application_Code, Application_Status, Login_ID ,Create_Date,chk_Adv,chk_Agenda,Attached_Doc_File,Chk_International,Tour_Agenda,IMP_Business_Appoint,KRA_Tour
								)                      
								VALUES                      
								(                      
									@Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Application_Date, @Application_Code, @Application_Status, @Login_ID, @Create_Date,0,0,@AttachedDocuments,@Chk_International,'','',''
								);      
						
					END

				EXEC P9999_Audit_get @table = 'T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
				SET @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
		
							IF @Travel_Application_ID >0
							BEGIN
								SET @Result = 'Data Inserted Successfully'
								SELECT @Result
							END
		END

		ELSE IF UPPER(@Tran_Type)='U'  
			BEGIN
			Declare @Tour_Agenda varchar(260)
			Declare @IMP_Business_Appoint varchar(260)
			Declare @KRA_Tour varchar(260)

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
				
					IF(@TourAgendaPlanned.exist('/NewDataSet/TourAgendaPlanned') = 1)
					 BEGIN
							SELECT 
							Table1.value('(Tour_Agenda/text())[1]','VARCHAR(200)') AS Tour_Agenda, 
							Table1.value('(IMP_Business_Appoint/text())[1]','VARCHAR(200)') AS IMP_Business_Appoint,
							Table1.value('(KRA_Tour/text())[1]','VARCHAR(200)') AS KRA_Tour
							INTO #MyTeamDetailsTemp2 FROM @TourAgendaPlanned.nodes('/NewDataSet/TourAgendaPlanned') AS Temp(Table1)
							
							SELECT @Tour_Agenda = Tour_Agenda,@IMP_Business_Appoint = IMP_Business_Appoint,@KRA_Tour = KRA_Tour 
							FROM #MyTeamDetailsTemp2
							
								UPDATE T0100_TRAVEL_APPLICATION
									SET APPLICATION_DATE = @APPLICATION_DATE,
									CHK_ADV = 0,
									APPLICATION_STATUS = @APPLICATION_STATUS,
									CHK_AGENDA = 0,
									TOUR_AGENDA = @TOUR_AGENDA,
									IMP_BUSINESS_APPOINT = @IMP_BUSINESS_APPOINT,
									KRA_TOUR = @KRA_TOUR,
									ATTACHED_DOC_FILE = @AttachedDocuments,
									CHK_INTERNATIONAL = @Chk_International
									WHERE TRAVEL_APPLICATION_ID = @TRAVEL_APPLICATION_ID
					 END
						Else
						BEGIN
								UPDATE T0100_TRAVEL_APPLICATION
									SET APPLICATION_DATE = @APPLICATION_DATE,
									CHK_ADV = 0,
									APPLICATION_STATUS = @APPLICATION_STATUS,
									CHK_AGENDA = 0,
									ATTACHED_DOC_FILE = @AttachedDocuments,
									CHK_INTERNATIONAL = @Chk_International
									WHERE TRAVEL_APPLICATION_ID = @TRAVEL_APPLICATION_ID    
					END
			
			
					exec P9999_Audit_get @table = 'T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
					
					
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
			
						
						   IF @Travel_Application_ID >0
						   BEGIN
						   		SET @Result = 'Data Updated Successfully'
						   		SELECT @Result
						   END
			END	
		
		ELSE IF UPPER(@Tran_Type) = 'D'
			BEGIN
				exec P9999_Audit_get @table='T0100_TRAVEL_APPLICATION' ,@key_column='Travel_Application_ID',@key_Values=@Travel_Application_ID,@String=@String_val output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				
				DELETE FROM dbo.T0110_TRAVEL_ADVANCE_DETAIL where Travel_App_ID = @Travel_Application_ID
				DELETE FROM dbo.T0110_TRAVEL_APPLICATION_DETAIL where  Travel_App_ID = @Travel_Application_ID     
				DELETE FROM dbo.T0110_Travel_Application_Other_Detail where  Travel_App_ID = @Travel_Application_ID     
				DELETE FROM dbo.T0100_TRAVEL_APPLICATION where Travel_Application_ID= @Travel_Application_ID
				DELETE FROM DBO.T0110_TRAVEL_APPLICATION_MODE_DETAIL WHERE Travel_APP_ID= @Travel_Application_ID
				Delete from T0080_Travel_HycScheme where AppId = @Travel_Application_ID


					IF @Travel_Application_ID >0
					BEGIN
							SET @Result = 'Data Deleted Successfully'
							SELECT @Result
					END
			END
	

		EXEC P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Application',@OldValue,@Emp_ID,@User_Id,@IP_Address,1

		EXEC Mobile_HRMS_P0110_TRAVEL_APPLICATION_DETAIL @Travel_App_Detail_ID=@Travel_Application_ID,@Cmp_ID=@Cmp_ID,@Travel_App_ID=@Travel_Application_ID,
		@Instruct_Emp_ID=@Emp_ID,@Tran_Type=@Tran_Type,@User_Id=@User_Id,@TravelTypeId=@TravelTypeId,
		@Travel_Details= @Travel_Details
		
		EXEC Mobile_HRMS_TRAVEL_Other_APPLICATION_DETAIL @Travel_App_Other_Detail_Id = 0,@Tran_Type = @Tran_Type,
		@Travel_App_ID=@Travel_Application_ID,@Cmp_ID=@Cmp_ID,@Travel_Other_Details = @Travel_Other_Details

		EXEC Mobile_HRMS_TRAVEL_ADVANCE_DETAIL @Cmp_ID=@Cmp_ID,@Travel_App_ID = @Travel_Application_ID,@Tran_Type=@Tran_Type,	
		@Travel_Adv_Details = @Travel_Adv_Details

END


