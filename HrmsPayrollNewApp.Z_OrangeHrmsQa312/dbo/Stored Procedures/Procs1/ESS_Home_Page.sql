
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[ESS_Home_Page] 
	@Cmp_ID Numeric(18,0),
	@Branch_ID Numeric(18,0),
	@emp_id Numeric(18,0),
	@Privilege_Id Numeric(18,0)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
    IF Object_ID('tempdb..#Temp_Emp_Rights') is not null
		Drop TABLE #Temp_Emp_Rights
    
    Create Table #Temp_Emp_Rights
    (
		ID	INT IDENTITY(1,1),
		Form_Name Varchar(2000),
		Form_Details Varchar(2000),
		Form_Url Varchar(2000),
		Pending_Count Numeric(18,0) DEFAULT (0)
    )
    
    IF Object_ID('tempdb..#Temp_Privilege') is not null
		Drop TABLE #Temp_Privilege
    
    Create Table #Temp_Privilege
    (
		Form_Name Varchar(200)
    )
    
     Exec GET_EMP_PRIVILEGE @Cmp_ID,@Privilege_Id,1
    
	
    --Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_262','Attendance Regularization','Emp_Inout_New.aspx?id=1')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_263','My Team Member Details','Employee_Downline.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_290','Timesheet Approval','Timesheet_Approval.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_265','Leave Approval','Leave_Approve.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_266','Leave Cancellation Approval','Leave_Cancelation_Approval.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_267','In Time(Show In Time Details)','Emp_Inout_New.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_268','Attendance Summary','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_269','Employee History','ESS_Employee_History.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_270','Current Year Salary Detail','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_271','Holiday Calendar','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_272','Leave Balance','')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_273','Probation Over','Employee_Probation.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_300','Trainee Over','Employee_Probation.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_274','Comp Off Application','CompOff_Approval.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_Ess_343','Pre Comp Off Application','PreCompOff_Approval.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_275','Your exit interview has been scheduled','Emp_ExitApplication.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_276','Exit Approval','Emp_ManagerFeedback.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_277','Reimbursement Approval','Employee_ReimClaim_Approval.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_345','Fill Up The Survey Form','ess_surveyform.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_278','Pending Documents List','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_279','View Graphical Report','Graphical_chart_Ess.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_280','Loan Approval','Loan_Approve_Ess.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_285','About Me','')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_286','Travel Approval','Travel_Approval_Superior.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_287','Travel Settlement Approval','Travel_Settlement_Approval_Superior.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_315','Claim Approvals','Claim_Approval_superior.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_264','Warning Details','Employee_Warning.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_Ess_289','Whosoff','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_341','Reward your team from " & dt_rewardAlert.Rows(0)("From_date") & " to " & dt_rewardAlert.Rows(0)("To_date")','Ess_HRMS_EmployeeReward.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_Ess_342','Change Request Approval','Change_Request_Approval.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_288','Give Training Feedback','ESS_TrainingFeedback.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_297','Training Questionnaire','Ess_TrainingAnswers.aspx')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_298','OJT pending for last month joinees','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_299','OJT pending since last year','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_307','Training Manager Feedback','ESS_Manager_TrainingFeedback.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_308','GatePass Approval','Ess_GatePass_Approval.aspx')
	--Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_309','Exit Clearance Detail','Emp_Exit_Clearance_Approval.aspx')
	
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_281','Graph','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_282','Attendance Graph','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_283','Attendance Summary','')
	Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url)  Values('TD_Home_ESS_284','Attendance Hourly Summary','')
    
    Delete FROM #Temp_Emp_Rights Where Form_Name Not in(Select Form_Name From #Temp_Privilege)
    	
    --For Attendance Regularazation --Start
    if exists(Select 1 From #Temp_Emp_Rights where Form_Name = 'TD_Home_ESS_262')
		BEGIN
			DECLARE @ShowCurrMonth_Count NUMERIC
			SET @ShowCurrMonth_Count = 0
			DECLARE @LateComer_Count As Numeric(18,0)
			SET @LateComer_Count = 0
			
			SELECT @ShowCurrMonth_Count = ISNULL(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Current Month Attendance Regularization Count On Home Page'
			IF @ShowCurrMonth_Count = 1
				BEGIN
					If @emp_id =0
						Begin
							Select @LateComer_Count = count(Emp_Id) From View_Late_Emp 
							Where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											 where R_Emp_ID = @emp_id ) 
							And Chk_By_Superior=0 and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE())

							Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url, Pending_Count)  Values('TD_Home_ESS_262','Attendance Regularization','Emp_Inout_New.aspx?id=1', @LateComer_Count)							
						End
					Else
						Begin	
							Insert INTO #Temp_Emp_Rights(Pending_Count)
							exec dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0) and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE()) ',  1

							UPDATE #Temp_Emp_Rights 
							SET		Form_Name='TD_Home_ESS_262', Form_Details= 'Attendance Regularization',
								 	Form_Url='Emp_Inout_New.aspx?id=1'
							WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
						End
				END
			ELSE
				BEGIN
					If @emp_id =0
						Begin
							Select @LateComer_Count = count(Emp_Id) From View_Late_Emp 
							Where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
													where R_Emp_ID = @emp_id ) 
									And Chk_By_Superior=0
							Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url, Pending_Count)  Values('TD_Home_ESS_262','Attendance Regularization','Emp_Inout_New.aspx?id=1', @LateComer_Count)														
						End
					Else
						Begin
							Insert INTO #Temp_Emp_Rights(Pending_Count)  Values(@LateComer_Count)							
							exec dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0)',  1,@LateComer_Count
							UPDATE #ReminderCount SET Form_Name='TD_Home_ESS_262' where id=IDENT_CURRENT('#Temp_Emp_Rights')
						End
				END
			Update #Temp_Emp_Rights SET Pending_Count = @LateComer_Count  where Form_Name = 'TD_Home_ESS_262'
		END	
    --For Attendance Regularazation --End
    
    -- For Leave Approval -- Start
    if exists(Select 1 From #Temp_Emp_Rights where Form_Name = 'TD_Home_ESS_265')
		BEGIN
			DECLARE @Leave_Apr_Count As Numeric(18,0)
			SET @Leave_Apr_Count = 0
			
			if @emp_id =0 
				begin
					SELECT	@Leave_Apr_Count = COUNT(Leave_Application_ID) 
					FROM	dbo.V0110_LEAVE_APPLICATION_DETAIL T
							INNER JOIN (SELECT DISTINCT Emp_ID FROM dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE R_Emp_ID = @emp_id ) T1 on T.EMP_ID=T1.Emp_ID
					WHERE	(Application_Status = 'P' or Application_Status = 'F') 
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_265','Leave Approval','Leave_Approve.aspx', @Leave_Apr_Count)					
				end
			else
				begin
					Insert INTO #Temp_Emp_Rights(Pending_Count) 							
					exec dbo.SP_Get_Leave_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Application_Status = ''P'' or Application_Status = ''F'')',  1 ,@Leave_Apr_Count

					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_ESS_265', Form_Details= 'Leave Approval',
							Form_Url='Leave_Approve.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
				end
				
			--Update #Temp_Emp_Rights SET Pending_Count = @Leave_Apr_Count  where Form_Name = 'TD_Home_ESS_265'
		End
    -- For Leave Approval -- End
    
    -- For Leave Cancellation -- Start
    if exists(Select 1 From #Temp_Emp_Rights where Form_Name = 'TD_Home_ESS_266')
		BEGIN
			DECLARE @Leave_Cancellation_Count As Numeric(18,0)
			SET @Leave_Cancellation_Count = 0
			
			if @emp_id =0 
				begin
					Select @Leave_Cancellation_Count = COUNT(Row_ID) from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')
					and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 	
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_266','Leave Cancellation Approval','Leave_Cancelation_Approval.aspx',@Leave_Cancellation_Count)
				end
		    else
				begin
					Select @Leave_Cancellation_Count = COUNT(Row_ID) from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')
					and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) 
					and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where is_approve = 0))
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_266','Leave Cancellation Approval','Leave_Cancelation_Approval.aspx',@Leave_Cancellation_Count)
				end
			
			--Update #Temp_Emp_Rights SET Pending_Count = @Leave_Apr_Count  where Form_Name = 'TD_Home_ESS_266'
		End
	
	-- For Leave Cancellation -- End
	
	-- For Probation Over -start
	Declare @Prob_Const NVARCHAR(MAX)
	IF exists(SELECT 1 from #Temp_Emp_Rights where Form_Name='TD_Home_ESS_273')
		BEGIN
			Declare @Dep_Reim_Days As Integer 
			Declare @is_all_emp_prob As Integer 
			Declare @ForDate As Datetime
			Declare @Pro_OverCnt Numeric(18,0)
			Set @Pro_OverCnt = 0
			set @Dep_Reim_Days = 0
			set @is_all_emp_prob = 0
		
			select @Dep_Reim_Days=Dep_Reim_Days, @is_all_emp_prob=is_all_emp_prob, @ForDate = MAX(For_Date) From T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and 
					Branch_ID = @Branch_ID and For_Date <= GETDATE() Group By Gen_ID,Probation,Dep_Reim_Days,is_all_emp_prob
		
				
			If @Dep_Reim_Days = 0 
				set @Dep_Reim_Days = 30
			
			If @is_all_emp_prob = 0
				Begin
					set @Prob_Const = N'0=0 and (( probation_date >= GETDATE() and probation_date <= DATEADD(DD,' + cast (@Dep_Reim_Days AS NVARCHAR(MAX)) + ' ,GETDATE() )) or probation_date <= GETDATE() )' 
				End
			Else If @is_all_emp_prob = 1
				Begin
					set @Prob_Const = N'0=0 and probation_date <= GETDATE()'
				End
			
			Insert INTO #Temp_Emp_Rights(Pending_Count)
			exec SP_Get_Probation_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=@Prob_Const, @Type = 1,@W_Count = @Pro_OverCnt OUTPUT

			UPDATE	#Temp_Emp_Rights 
			SET		Form_Name='TD_Home_ESS_273', Form_Details= 'Probation Over',
					Form_Url='Employee_Probation.aspx'
			WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')

			--Update #Temp_Emp_Rights SET Pending_Count = @Pro_OverCnt  where Form_Name = 'TD_Home_ESS_273'
		END
    -- For Probation Over -End
    
    -- For Comp off Application -Start
	IF exists(SELECT 1 from #Temp_Emp_Rights where Form_Name='TD_Home_ESS_274')	
		BEGIN
			Declare @Comp_Off_App_Count Numeric(18,0)
			Set @Comp_Off_App_Count = 0
			SELECT	@Comp_Off_App_Count = ISNULL(COUNT(Compoff_App_ID),0)  From	V0110_COMPOFF_APPLICATION_DETAIL COMP
				INNER JOIN (SELECT	R1.EMP_ID, R_Emp_ID, R1.Effect_Date 
							FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
									INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID
												FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
												GROUP BY Emp_ID
												) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date
							) R1 ON COMP.Emp_ID=R1.Emp_ID
			Where	Application_Status='P' AND R1.R_Emp_ID=@emp_id
			
			Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_274','Comp Off Application','CompOff_Approval.aspx',@Comp_Off_App_Count)
			--Update #Temp_Emp_Rights SET Pending_Count = @Comp_Off_App_Count  where Form_Name = 'TD_Home_ESS_274'
		END
	-- For Comp off Application -End
	
	-- For Reimbrustment Approval -Start
	IF exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_277')
		BEGIN
			Declare @Reim_Apr_Count Numeric(18,0)
			Set @Reim_Apr_Count = 0
			if @emp_id =0 
				begin
					select @Reim_Apr_Count = count(RC_APP_ID) from V0100_RC_Application where  APP_Status = 0  and  Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) 
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_277','Reimbursement Approval','Employee_ReimClaim_Approval.aspx',@Reim_Apr_Count)
				end
			else
				begin
					Insert INTO #Temp_Emp_Rights(Pending_Count)
					exec SP_Get_RC_Application_Records @Cmp_ID=@Cmp_Id,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'(Status = ''Pending'' )',@type= 1,@W_Count = @Reim_Apr_Count Output

					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_ESS_277', Form_Details= 'Reimbursement Approval',
							Form_Url='Employee_ReimClaim_Approval.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')

				end 
			--Update #Temp_Emp_Rights SET Pending_Count = @Reim_Apr_Count  where Form_Name = 'TD_Home_ESS_277'
		END
	-- For Reimbrustment Approval -End
	
	-- For Loan Approval -Start
	if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_280')
		BEGIN
			Declare @Loan_Apr_Count Numeric(18,0)
			Set @Loan_Apr_Count = 0
			If @emp_id =0	
				Begin						
					 select @Loan_Apr_Count = count(Request_id) from V0090_Change_Request_Application where Emp_ID in (SELECT T0090_EMP_REPORTING_DETAIL.Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Effect_Date <= getdate() AND R_Emp_ID = @Emp_ID )and (Request_status='Pending')
					 Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_280','Loan Approval','Loan_Approve_Ess.aspx',@Loan_Apr_Count)
				End
			Else
				Begin
					Insert INTO #Temp_Emp_Rights(Pending_Count)
					exec SP_Get_Loan_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Loan_Status = ''N'')',  1,@Loan_Apr_Count

					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_ESS_280', Form_Details= 'Loan Approval',
							Form_Url='Loan_Approve_Ess.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
				End
			Update #Temp_Emp_Rights SET Pending_Count = @Loan_Apr_Count  where Form_Name = 'TD_Home_ESS_280'
		END
    -- For Loan Approval -End
    
    -- For Travel Approval --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_286')
		BEGIN
			Declare @Travel_Apr_Count Numeric(18,0)
			Set @Travel_Apr_Count = 0
			
			if @emp_id =0 
				begin
					select @Travel_Apr_Count = count(travel_Application_id) from V0100_TRAVEL_APPLICATION where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Application_Status = 'P' or Application_Status = 'F') --
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_286','Travel Approval','Travel_Approval_Superior.aspx',@Travel_Apr_Count)
				end
			else
				begin
					Insert INTO #Temp_Emp_Rights(Pending_Count)
					exec SP_Get_Travel_Application_Records @Cmp_ID,@Emp_ID,0,N'Application_Status = ''P''',1,@Travel_Apr_Count
					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_ESS_286', Form_Details= 'Travel Approval',
							Form_Url='Travel_Approval_Superior.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
				end
			
			--Update #Temp_Emp_Rights SET Pending_Count = @Travel_Apr_Count  where Form_Name = 'TD_Home_ESS_286'
		END
    -- For Travel Approval --End
    
    -- For Travel Settelment --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_287')
		BEGIN
			Declare @Travel_Sett_Count Numeric(18,0)
			Set @Travel_Sett_Count = 0
			
			if @emp_id =0 
				begin
					select  @Travel_Sett_Count = count(travel_set_application_id) from V0140_Travel_Settlement_Application where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Status = 'P' or Status = 'F') 
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_287','Travel Settlement Approval','Travel_Settlement_Approval_Superior.aspx',@Travel_Sett_Count)
				end
			else
				begin
					Insert INTO #Temp_Emp_Rights(Pending_Count)
					exec SP_Get_Travel_Settlement_Application_Records @cmp_id ,@Emp_ID ,0 ,'(Status_New = ''P'')', 1,@Travel_Sett_Count OUTPUT
					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_ESS_287', Form_Details= 'Travel Settlement Approval',
							Form_Url='Travel_Settlement_Approval_Superior.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
				end
			--Update #Temp_Emp_Rights SET Pending_Count = @Travel_Sett_Count  where Form_Name = 'TD_Home_ESS_287'
		END
    -- For Travel Settelment --End
    
    -- For Claim Approval --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_315')
		BEGIN
			Declare @Claim_Apr_Count Numeric(18,0)
			Set @Claim_Apr_Count = 0
			
			If @emp_id =0	--Sumit 03022015
				Begin
					Select @Claim_Apr_Count = count(Claim_App_ID) from V0100_Claim_Application_New where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Claim_App_Status = 'P')
					Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_315','Claim Approvals','Claim_Approval_superior.aspx')
				End
			Else
				Begin
					Insert INTO #Temp_Emp_Rights(Pending_Count)
					exec SP_Get_Claim_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Claim_App_Status = ''P'')',  1 , '', @Claim_Apr_Count OUTPUT
					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_ESS_315', Form_Details= 'Claim Approvals',
							Form_Url='Claim_Approval_superior.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
				End
			--Update #Temp_Emp_Rights SET Pending_Count = @Claim_Apr_Count  where Form_Name = 'TD_Home_ESS_315'
		END
    -- For Claim Approval --End
    
    -- For Change Request Approval --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_Ess_342')
		BEGIN
			Declare @Change_Request_Apr_Count Numeric(18,0)
			Set @Change_Request_Apr_Count = 0
			
			If @emp_id =0	
				Begin
					 select @Change_Request_Apr_Count = count(Request_id) from V0090_Change_Request_Application where Emp_ID in (SELECT T0090_EMP_REPORTING_DETAIL.Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Effect_Date <= getdate() AND R_Emp_ID = @Emp_ID )and (Request_status='Pending')
					 Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_Ess_342','Change Request Approval','Change_Request_Approval.aspx',@Change_Request_Apr_Count)
				End
			Else
				Begin
					Insert INTO #Temp_Emp_Rights(Pending_Count)
					exec SP_Get_Change_Request_Records @Cmp_ID ,@Emp_ID ,0 ,'(Request_status=''Pending'')',  1,@Change_Request_Apr_Count OUTPUT
					
					UPDATE #Temp_Emp_Rights 
					SET		Form_Name='TD_Home_Ess_342', Form_Details= 'Change Request Approval',
							Form_Url='Change_Request_Approval.aspx'
					WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')
				End			
			--Update #Temp_Emp_Rights SET Pending_Count = @Change_Request_Apr_Count  where Form_Name = 'TD_Home_Ess_342'
		END
	-- For Change Request Approval --End
	
	-- For Pre Comp-Off Application --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_Ess_343')
		BEGIN
			Declare @Pre_Comp_App_Count Numeric(18,0)
			Set @Pre_Comp_App_Count = 0
			
			Insert INTO #Temp_Emp_Rights(Pending_Count)
			exec SP_Get_PreCompOff_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Rpt_level=0,@Constrains='(App_Status = ''P'')',@Type=1,@Pre_Comp_App_Count=@Pre_Comp_App_Count OUTPUT

			UPDATE #Temp_Emp_Rights 
			SET		Form_Name='TD_Home_Ess_343', Form_Details= 'Pre Comp Off Application',
					Form_Url='PreCompOff_Approval.aspx'
			WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')

			--Update #Temp_Emp_Rights SET Pending_Count = @Pre_Comp_App_Count  where Form_Name = 'TD_Home_Ess_343'			
		END
	-- For Pre Comp-Off Application --End
	
	-- For Trainee Over --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_Ess_300')
		BEGIN
			Declare @Trainee_Over_Count Numeric(18,0)
			Set @Trainee_Over_Count = 0
			
			Insert INTO #Temp_Emp_Rights(Pending_Count)
			exec SP_Get_Trainee_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@flag='Pending',@Constrains=@Prob_Const, @Type = 1,@W_Count =  @Trainee_Over_Count OUTPUT

			UPDATE #Temp_Emp_Rights 
			SET		Form_Name='TD_Home_ESS_300', Form_Details= 'Trainee Over',
					Form_Url='Employee_Probation.aspx'
			WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')

			--Update #Temp_Emp_Rights SET Pending_Count = @Trainee_Over_Count  where Form_Name = 'TD_Home_Ess_300'
		END
	-- For Trainee Over --End
	
	-- For GatePass --Start
    if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_Ess_308')
		BEGIN
			Declare @Getpass_Apr_Count Numeric(18,0)
			Set @Getpass_Apr_Count = 0
			
			Insert INTO #Temp_Emp_Rights(Pending_Count)
			exec SP_Get_GatePass_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'App_Status = ''P''', @Type = 1,@W_Count = @Getpass_Apr_Count OUTPUT

			UPDATE #Temp_Emp_Rights 
			SET		Form_Name='TD_Home_ESS_308', Form_Details= 'GatePass Approval',
					Form_Url='Ess_GatePass_Approval.aspx'
			WHERE id=IDENT_CURRENT('#Temp_Emp_Rights')

			--Update #Temp_Emp_Rights SET Pending_Count = @Getpass_Apr_Count  where Form_Name = 'TD_Home_Ess_308'
		END
	-- For GatePass --End
	
	-- For Exit Clearance Detail --Start
	if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_309')
		BEGIN
			
			Declare @Exist_Clearance_Count Numeric(18,0)
			Set @Exist_Clearance_Count = 0
			
			SELECT @Exist_Clearance_Count = COUNT(APPROVAL_ID) FROM T0300_EXIT_CLEARANCE_APPROVAL EA WITH (NOLOCK)
			INNER JOIN T0095_EXIT_CLEARANCE EC WITH (NOLOCK) ON EA.HOD_ID = EC.EMP_ID and EC.Dept_id = EA.Dept_Id
			inner JOIN T0200_Emp_ExitApplication E WITH (NOLOCK) on EA.Exit_ID =E.exit_id
			WHERE EA.NOC_STATUS='P' AND EA.HOD_ID = @EMP_ID AND EA.CMP_ID = @CMP_ID and E.sup_ack = 'P' 
			
			Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_309','Exit Clearance Detail','Emp_Exit_Clearance_Approval.aspx',@Exist_Clearance_Count)
			--Update #Temp_Emp_Rights SET Pending_Count = @Exist_Clearance_Count where Form_Name = 'TD_Home_ESS_309'
		END
	-- For Exit Clearance Detail --End
	
	-- For Exit Approval Detail --Start
	if Exists(Select 1 From #Temp_Emp_Rights Where Form_Name='TD_Home_ESS_276')
		BEGIN
			Insert INTO #Temp_Emp_Rights(Form_Name,Form_Details,Form_Url,Pending_Count)  Values('TD_Home_ESS_276','Exit Approval','Emp_ManagerFeedback.aspx',@Exist_Clearance_Count)
			--Update #Temp_Emp_Rights SET Pending_Count = @Exist_Clearance_Count where Form_Name = 'TD_Home_ESS_276'
		END	
	-- For Exit Approval Detail --End	
    
    Select T.*,F.Module_name From #Temp_Emp_Rights T Left Outer Join T0000_DEFAULT_FORM F WITH (NOLOCK) ON T.Form_Name=F.Form_Name

END

