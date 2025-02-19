
CREATE PROCEDURE [dbo].[Mobile_HRMS_P0100_TRAVEL_APPROVAL]
	 @Tran_ID				NUMERIC(18,0)	
	,@Travel_Application_ID NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Approval_Date			Datetime
	,@Approval_Status		Char(1)
	,@Approval_Comments		Varchar(250)
	,@Login_ID				NUMERIC(18,0)
	,@Rpt_Level				TinyInt
	,@Total					Numeric(18,2)
	,@Tran_Type				Char(1) 
	,@Attached_Doc_File		nvarchar(max)
	,@User_Id				NUMERIC(18,0) = 0 
	,@TourAgendaPlanned		XML
	,@Travel_Details		XML
	,@Travel_Adv_Details    XML
	,@Travel_Other_Details  XML
	,@Result				VARCHAR(70)OUTPUT
	,@TravelTypeId          NUMERIC(18,0)
	,@Chk_International     NUMERIC(18,0) = 0
AS

BEGIN
--select @Travel_Other_Details
--
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	

	Declare @Create_Date As Datetime
	Declare @SchemeId as numeric(18,0)	  = 0
	Declare @ReportLevel as numeric(18,0) = 0
	
	Set @Create_Date = GETDATE()

	declare @mx_rptlvl int
		SELECT @SchemeId = Scheme_ID 
		FROM T0095_EMP_SCHEME S
		INNER JOIN (
			SELECT max(Effective_Date) as EffDate,Tran_ID 
			FROM T0095_EMP_SCHEME S1 
			WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
			group by Tran_id
		) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'


	select @mx_rptlvl = max(Rpt_Level) from T0050_Scheme_Detail where Scheme_Id = @SchemeId



	If @S_Emp_ID = 0
	Begin 
		Set @S_Emp_ID = NULL


		DECLARE @KRA_Tour varchar(250) 
		DECLARE @IMP_Business_Appoint varchar(250) 
		DECLARE @Tour_Agenda varchar(250) 
		
		--SELECT @SchemeId = Scheme_ID 
		--FROM T0095_EMP_SCHEME S
		--INNER JOIN (
		--	SELECT max(Effective_Date) as EffDate,Tran_ID 
		--	FROM T0095_EMP_SCHEME S1 
		--	WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
		--	group by Tran_id
		--) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		--WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'

		--select @SchemeId

		Select @ReportLevel = Rpt_Level  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 

		IF @ReportLevel = 0
		Begin
			Select @S_Emp_ID = S_Emp_ID  from T0100_TRAVEL_APPLICATION where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
			
			SELECT @ReportLevel = 
			sd.Rpt_Level 
			FROM T0050_SCHEME_DETAIL SD 
			INNER JOIN  T0080_DynHierarchy_Value DV on SD.Dyn_Hier_Id = DV.DynHierColId
			INNER JOIN T0095_INCREMENT I on I.Increment_ID = DV.IncrementId
			WHERE sd.Scheme_Id = @SchemeId and DV.DynHierColValue = @S_Emp_ID and Dv.Emp_ID = @Emp_ID and Dv.Cmp_ID = @Cmp_ID

			SELECT @ReportLevel = @ReportLevel + 1 
			set @S_Emp_ID = 0	
		END
		ELSE
		IF @ReportLevel > 0
		Begin
			Select @S_Emp_ID = S_Emp_ID  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID order by Tran_Id desc
			
			SELECT @ReportLevel = 
			sd.Rpt_Level 
			FROM T0050_SCHEME_DETAIL SD 
			INNER JOIN  T0080_DynHierarchy_Value DV on SD.Dyn_Hier_Id = DV.DynHierColId
			INNER JOIN T0095_INCREMENT I on I.Increment_ID = DV.IncrementId
			WHERE sd.Scheme_Id = @SchemeId and DV.DynHierColValue = @S_Emp_ID and Dv.Emp_ID = @Emp_ID and Dv.Cmp_ID = @Cmp_ID

			SELECT @ReportLevel = @ReportLevel + 1 
			set @S_Emp_ID = 0	
		END
		ELSE
		BEGIN 
			SET @ReportLevel = @ReportLevel + 1
		END

		if @ReportLevel > 0
		Begin 
			IF isnull(@S_Emp_ID,0) = 0	
				select @S_Emp_ID = DynHierColValue from T0050_Scheme_Detail SD
				Inner join T0080_DynHierarchy_Value Dy
				on SD.Dyn_Hier_Id = DY.DynHierColId and sd.Scheme_Id = @SchemeId 
				and dy.Emp_ID = @Emp_ID and Rpt_Level = @ReportLevel
		END
	END
	

	If UPPER(@Tran_Type) = 'I'
		Begin
			--IF  Exists(Select 1 From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) Where Emp_ID=@Emp_ID and Travel_Application_ID=@Travel_Application_ID And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
			--	BEGIN
			--		Set @Tran_ID = 0
			--		Select @Tran_ID
			--		Return 
			--	End
			
			--IF EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL WHERE Emp_ID = @Emp_ID AND )
			


			Select @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
			
				IF (@TourAgendaPlanned.exist('/NewDataSet/TourAgendaPlanned') = 1)
					 BEGIN
					 
						SELECT 
							Table1.value('(Tour_Agenda/text())[1]','VARCHAR(200)') AS u_Tour_Agenda, 
							Table1.value('(IMP_Business_Appoint/text())[1]','VARCHAR(200)') AS u_IMP_Business_Appoint,
							Table1.value('(KRA_Tour/text())[1]','VARCHAR(200)') AS u_KRA_Tour,
							Table1.value('(Approval_Comments/text())[1]','VARCHAR(300)') AS Approval_Comment
							INTO #MyTeamDetailsTemp FROM @TourAgendaPlanned.nodes('/NewDataSet/TourAgendaPlanned') AS Temp(Table1)

							MERGE T0115_TRAVEL_LEVEL_APPROVAL AS TARGET  
							USING #MyTeamDetailsTemp AS SOURCE ON Travel_Application_ID = @Travel_Application_ID and Tran_ID = @Tran_ID and Rpt_Level = @Rpt_Level
							WHEN MATCHED THEN 
							UPDATE SET   
							Cmp_ID=@Cmp_ID, Emp_ID = @Emp_ID, S_Emp_ID = @S_Emp_ID,
							Approval_Date = @Approval_Date, Approval_Status = @Approval_Status,Approval_Comments = @Approval_Comments,
							Login_ID= @Login_ID,Total =@Total, System_date = getdate(),Rpt_Level = @Rpt_Level,
							Tour_Agenda = u_Tour_Agenda,IMP_Business_Appoint = u_IMP_Business_Appoint,KRA_Tour = u_KRA_Tour,@Approval_Comments = Approval_Comment,
							Attached_Doc_File = @Attached_Doc_File						
							
							WHEN NOT MATCHED BY TARGET THEN                              
								INSERT                      
								(                      
									Tran_ID,Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status,Approval_Comments, Login_ID,Total, System_date,Rpt_Level,chk_Adv,chk_Agenda,Tour_Agenda,IMP_Business_Appoint,KRA_Tour,Attached_Doc_File						
								)                      
								VALUES                      
								(                      
									@Tran_ID, @Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, Approval_Comment, @Login_ID, @Total, @Create_Date,@Rpt_Level,0,0,u_Tour_Agenda,u_IMP_Business_Appoint,u_KRA_Tour,@Attached_Doc_File
								); 
								 SELECT @Tour_Agenda = u_Tour_Agenda,@IMP_Business_Appoint = u_IMP_Business_Appoint,@KRA_Tour = u_KRA_Tour,@Approval_Comments = Approval_Comment FROM #MyTeamDetailsTemp 

								 
						END
					ELSE
					 BEGIN
						IF Exists(select 1 from T0115_TRAVEL_LEVEL_APPROVAL where Travel_Application_ID = @Travel_Application_ID and Tran_Id = @Tran_ID)
						Begin
							UPDATE T0115_TRAVEL_LEVEL_APPROVAL SET   
							Tran_ID =@Tran_ID, Cmp_ID=@Cmp_ID, Emp_ID = @Emp_ID, S_Emp_ID = @S_Emp_ID,
							Approval_Date = @Approval_Date, Approval_Status = @Approval_Status,Approval_Comments = @Approval_Comments,
							Login_ID= @Login_ID,Total =@Total, System_date = getdate(),Rpt_Level = @Rpt_Level,
							Tour_Agenda =Tour_Agenda,IMP_Business_Appoint = IMP_Business_Appoint,KRA_Tour = KRA_Tour,
							Attached_Doc_File = @Attached_Doc_File where Tran_Id = @Tran_ID and Cmp_ID=@Cmp_ID
						End
						Else
							BEGIN
									INSERT INTO T0115_TRAVEL_LEVEL_APPROVAL             
									(                      
										Tran_ID,Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status,Approval_Comments, Login_ID,Total, System_date,Rpt_Level,chk_Adv,chk_Agenda,Tour_Agenda,IMP_Business_Appoint,KRA_Tour,Attached_Doc_File						
									)                      
									VALUES                      
									(                      
										@Tran_ID, @Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID, @Total, @Create_Date,@Rpt_Level,0,0,'','','',@Attached_Doc_File
									);     
							END
						END
					
				IF @Tran_ID >0
				BEGIN
					SET @Result = 'Successfully'
					select @Result
				END
		END

		
		EXEC Mobile_HRMS_TRAVEL_APPROVAL_DETAIL_LEVEL_APR @Cmp_ID=@Cmp_ID,
		@Travel_App_ID=@Travel_Application_ID,@Instruct_Emp_ID=@Emp_ID,@Tran_Type=@Tran_Type,@User_Id=@User_Id,
		@Tran_ID=@Tran_ID,@Travel_Details= @Travel_Details,@TravelTypeId=@TravelTypeId
		
		
		
		EXEC SP_Mobile_HRMS_WebService_Travel_OTHER_DETAIL_APR @Travel_Apr_Other_Detail_Id = 0,@Tran_Type = @Tran_Type,@Tran_ID =@Tran_ID,
		@Cmp_ID=@Cmp_ID,@Travel_Other_Details = @Travel_Other_Details	
		
		
		EXEC Mobile_HRMS_TRAVEL_ADVANCE_DETAIL_APR @Row_Adv_ID = 0,@Travel_App_ID = @Travel_Application_ID, @Cmp_ID = @Cmp_ID,
		@Tran_ID = @Tran_ID, @Tran_Type = @Tran_Type, @Travel_Adv_Details = @Travel_Adv_Details
		
		

		If (@mx_rptlvl = @Rpt_Level or @Approval_Status = 'R')
			BEGIN
				DECLARE @p1 int set @p1=0 exec MOBILE_HRMS_P0120_TRAVEL_APPROVAL @Travel_Approval_ID=@p1 output,
				@Travel_Application_ID=@Travel_Application_ID,
				@Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@S_Emp_ID=@S_Emp_ID,@Approval_Date=@Approval_Date,@Approval_Status=@Approval_Status,
				@Travel_Details = @Travel_Details,
				@Approval_Comments=@Approval_Comments,
				@Login_ID=@Login_ID,@Is_Import=0,@Total=@Total,@Chk_Adv='0',@Chk_Agenda='0',
				@Tour_Agenda=@Tour_Agenda,@IMP_Business_Appoint=@IMP_Business_Appoint,@KRA_Tour=@KRA_Tour,
				@Attached_Doc_File=@Attached_Doc_File,@Tran_Type=@Tran_Type,@User_Id=@User_Id,@IP_Address='' 
				,@Travel_Other_Details = @Travel_Other_Details
				,@Travel_Adv_Details   = @Travel_Adv_Details
				,@TravelTypeId = @TravelTypeId
				select @p1	
			END
			
		End
	