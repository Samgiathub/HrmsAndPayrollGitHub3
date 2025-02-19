

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_ADMIN_NOTIFICATION]
	@Cmp_ID			INT,
	@Emp_ID			INT,
	@Privilege_ID	INT = 0
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		DECLARE @Branch_ID INT
		CREATE TABLE #EMP_CONS
		(
			Emp_ID			INT,
			Branch_ID		INT,
			Increment_ID	INT
		)	

		DECLARE @P_Dept_ID VARCHAR(MAX)

		DECLARE @From_Date DateTime
		DECLARE @To_Date DateTime

		SET @From_Date  = DATEADD(MONTH, DATEDIFF(MONTH, 0, Getdate())-1, 0)		
		SET	@To_Date = GETDATE()

		/*
		Fill Emp Cons
		*/
		BEGIN
			INSERT INTO #Emp_Cons(EMP_ID, Branch_ID, Increment_ID)
			SELECT	I.EMP_ID, I.Branch_ID, I.Increment_ID
			FROM	T0095_INCREMENT I WITH (NOLOCK)
					INNER JOIN T0080_EMP_MASTER	 E WITH (NOLOCK) ON I.Emp_ID=E.Emp_ID
					INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) As Increment_Effective_Date
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.Increment_Effective_Date  <= GETDATE()
													GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
								GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_ID=I1.Increment_ID
			WHERE	IsNull(E.Emp_Left_Date, getdate()+1)  > getdate() AND E.Date_Of_Join < GETDATE()
		END


		CREATE TABLE #Notification
		(
			Row_ID		INT,
			Form_ID		INT,
			Form_Name	Varchar(512),			
			Category	Varchar(128),			
			Rec_Value	Numeric(18,2),			
			NotifyDate	DateTime,
			Alias		Varchar(512),
			Form_Url	Varchar(512),
			IsUpdated	BIT NULL
					
		)

		IF @Privilege_ID IS NULL
			SET @Privilege_ID = 0



		Insert Into #Notification(Row_ID, Form_ID,Form_Name,Category, Rec_Value, NotifyDate,Alias, Form_Url)
		SELECT	ROW_NUMBER() OVER(ORDER BY Sort_ID, Sort_ID_Check) ROW_ID, D.Form_ID, Form_Name, '', 0, GetDate(), D.Alias, D.Form_Url
		FROM	T0000_DEFAULT_FORM D WITH (NOLOCK)
				LEFT OUTER JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON D.Form_ID=PD.Form_Id AND PD.Privilage_ID=@Privilege_ID AND (Is_Edit + Is_View + Is_Save + Is_Delete  + Is_Print) > 0
		WHERE	D.Page_Flag='DE' AND (Case When @Privilege_ID > 0  AND IsNull(PD.Privilage_ID,0) = 0 Then 0 Else 1 End ) = 1  
				AND EXISTS(SELECT 1 FROM T0011_module_detail M WITH (NOLOCK) WHERE D.Module_name = M.module_name AND M.module_status=1)

		CREATE TABLE #Notification_Value(Rec_Value Numeric(12,2))

		DECLARE @Rec_Value Numeric(12,2)
		DECLARE @Where AS Varchar(MAX)
		
		
		--Attendance Regularization
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_262')
			BEGIN
				-----Ankit 29012015				
				SET @Where = '(Chk_By_Superior = 0) '

				IF EXISTS(SELECT 1  FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Current Month Attendance Regularization Count On Home Page' and ISNULL(Setting_Value,0) = 1)
					SET @Where = @Where  +  ' and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE()) '				
				
				EXEC dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,@Where,  1				
				
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_262'
			END
		
		--My Team Member Details
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_263')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1,
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_263'
			END

		--Timesheet Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_290')
			BEGIN				
				UPDATE	N
				SET		Rec_Value = (SELECT	COUNT(Timesheet_ID) 
									FROM	V0100_TS_Application TS
											INNER JOIN #EMP_CONS EC ON TS.Employee_ID=EC.Emp_ID
									Where	Timesheet_Type = 'Weekly' and Project_Status = 'Submitted'), 
						IsUpdated=1,
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_290'					
			END

		--Leave Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_265')
			BEGIN				
				exec dbo.SP_Get_Leave_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Application_Status = ''P'' or Application_Status = ''F'')',  1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_265'
			END

		--Leave Cancellation Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_266')
			BEGIN
				UPDATE	N
				SET		Rec_Value = (SELECT	COUNT(Row_ID) 
									FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
									WHERE	Approval_Status IN ('A', 'R')				
											AND EXISTS(SELECT 1 from T0150_LEAVE_CANCELLATION LC  WITH (NOLOCK) WHERE LC.is_approve = 0 AND LC.Leave_Approval_ID=LA.Leave_Approval_ID)), 
						IsUpdated=1,
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_266'			
			END

		--In Time
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_267')
			BEGIN
				PRINT 'In Time'
			END


		--Attendance Summary
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_268')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -2, 
						IsUpdated=1,
						Form_Url='javascript:__doPostBack("OpenEmployeeAttendance", "true")',
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_268'	
				
			END


		--Employee History
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_269')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -1, 
						IsUpdated=1,
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_268'	
			END

		--Current Year Salary Detail
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_270')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -2, 
						IsUpdated=1,
						Form_Url='javascript:__doPostBack("OpenYearlySalary", "true")',
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_271'		
			END

		--Holiday Calendar
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_271')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -2, 
						IsUpdated=1,
						Form_Url='javascript:__doPostBack("OpenYearlyHoliday", "true")',
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_271'		
			END

		--Leave Balance
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_272')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -2, 
						IsUpdated=1,
						Form_Url='javascript:__doPostBack("LeaveBalance", "true")',
						Category = 'Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_268'	
			END

		--For Training & Probation
		
		Declare @Dep_Reim_Days As Integer 
		Declare @is_all_emp_prob As Integer 
		Declare @ForDate As Datetime
		
		SET @Dep_Reim_Days = 0
		SET @is_all_emp_prob = 0
		
		SELECT	TOP 1 @Dep_Reim_Days=Dep_Reim_Days, @is_all_emp_prob=is_all_emp_prob, @ForDate = For_Date
		FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
		WHERE	Cmp_ID = @Cmp_ID and 
				Branch_ID = @Branch_ID and For_Date <= GETDATE() 
		ORDER BY For_Date DESC
						
		If @Dep_Reim_Days = 0 
			set @Dep_Reim_Days = 30

		--Probation Over
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_273')
			BEGIN
				

				SET @Where = N'0=0 and probation_date <= GETDATE()' 
			
				If @is_all_emp_prob = 0
					SET @Where = N'0=0 and ((Probation_Date >= GETDATE() and probation_date <= DATEADD(DD,' + cast (@Dep_Reim_Days AS NVARCHAR(MAX)) + ' ,GETDATE() )) or probation_date <= GETDATE() )' 
				
				exec SP_Get_Probation_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=@Where, @Type = 1
				
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_273'
			END

		--Trainee Over
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_300')
			BEGIN
				SET @Where = N'0=0 and probation_date <= GETDATE()' 
			
				If @is_all_emp_prob = 0
					SET @Where = N'0=0 and ((Probation_Date >= GETDATE() and probation_date <= DATEADD(DD,' + cast (@Dep_Reim_Days AS NVARCHAR(MAX)) + ' ,GETDATE() )) or probation_date <= GETDATE() )' 
				
				exec SP_Get_Trainee_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=@Where, @Type = 1

				
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_300'
			END

		--Comp Off Application
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_274')
			BEGIN
				SET @Rec_Value = 0
				IF EXISTS( SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND (CONVERT(varchar(11),from_date,120)) = convert(varchar(11),GETDATE(),120) and  convert(varchar(11),to_date,120) >= convert(varchar(11),GETDATE(),120) AND Pass_To_Emp_id=@EMP_ID AND Type='Comp off')
					BEGIN								
						SELECT @Rec_Value = COUNT(V.Compoff_App_ID) 
						FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO M WITH (NOLOCK) INNER JOIN 												
							V0110_COMPOFF_APPLICATION_DETAIL V ON M.Manger_Emp_id = V.S_Emp_ID 											
							INNER JOIN (SELECT	R1.EMP_ID, R_Emp_ID, R1.Effect_Date 										
											FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)					
													INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID			
																FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																GROUP BY Emp_ID	
																) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date	
											) R1 ON V.Emp_ID=R1.Emp_ID						
						WHERE Pass_To_Emp_id = @EMP_ID AND  getdate() >= from_date AND getdate() <= to_date and Type='Comp Off' 												
							and M.Cmp_id=@Cmp_id AND V.Application_Status='P' 	
						GROUP BY V.Compoff_App_ID											
					END
				ELSE
					BEGIN				
						SELECT	@Rec_Value = ISNULL(COUNT(Compoff_App_ID),0) 
						From	V0110_COMPOFF_APPLICATION_DETAIL COMP
								INNER JOIN (SELECT	R1.EMP_ID, R_Emp_ID, R1.Effect_Date 
											FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
													INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID
																FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																GROUP BY Emp_ID
																) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date
											) R1 ON COMP.Emp_ID=R1.Emp_ID
						Where	Application_Status='P' AND R1.R_Emp_ID=@emp_id	
					END

				UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_Ess_343'
			END

		--Pre Comp Off Application
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_Ess_343')
			BEGIN
				exec SP_Get_PreCompOff_Application_Records @Cmp_ID,@Emp_ID,0,'(App_Status = ''P'')',1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_Ess_343'				
			END

		--Your exit interview has been scheduled
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_275')
			BEGIN
				DECLARE @Exit_ID AS INT
				Select @Exit_ID = MAX(Exit_ID) From T0200_Emp_ExitApplication WITH (NOLOCK) Where cmp_id = @Cmp_id and emp_id= @Emp_id 								
				
				If  Exists(Select 1 From T0200_Exit_Interview WITH (NOLOCK) Where cmp_id = @Cmp_id and Exit_ID =@Exit_ID )
					BEGIN
						If Not Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id = @Cmp_id and emp_id =@Emp_id and Exit_ID =@Exit_ID)
							Select @Rec_Value = COUNT(1) from T0200_Emp_ExitApplication WITH (NOLOCK) Where emp_id = @Emp_id and cmp_id = @Cmp_id 
						ELSE
							BEGIN
								If Exists(Select 1 From T0200_Exit_Feedback WITH (NOLOCK) Where cmp_id = @Cmp_id and emp_id =@Emp_id and Exit_ID =@Exit_ID and is_draft = 1)
									Select @Rec_Value = COUNT(1) from T0200_Emp_ExitApplication WITH (NOLOCK) Where emp_id = @Emp_id and cmp_id = @Cmp_id 
							END

						IF @Rec_Value > 0
							UPDATE	N
							SET		Rec_Value = -2, 
									IsUpdated=1,
									Form_Url='javascript:__doPostBack("getNotice", "true")',
									Alias = 'Your exit interview has been scheduled'
							FROM	#Notification N			
							Where	Form_Name='TD_Home_ESS_275'	
					END
				UPDATE	N
				SET		Category='Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_275'	
			END

		--Exit Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_276')
			BEGIN
				--Added By Jaina 14-06-2016
				exec Get_Exit_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'1=1 and status = ''H''',@Type = 1	

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_276'				
			END

		--Reimbursement Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_277')
			BEGIN
				exec SP_Get_RC_Application_Records @Cmp_ID=@Cmp_Id,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'(Status = ''Pending'' and Submit_Flag=0)',@type= 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_277'
			END

		--Fill Up The Survey Form
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_345')
			BEGIN
				IF EXISTS(Select Survey_ID,Survey_Title from T0050_SurveyMaster WITH (NOLOCK) where Cmp_ID=@Cmp_ID AND GETDATE() >= SurveyStart_Date and CAST(GETDATE() as varchar(12)) <= Survey_OpenTill)
					UPDATE	#Notification 
					SET		IsUpdated=1, 
							Rec_Value=-1,
							Alias = 'Fill Up The Survey Form',
							Category='Payroll'
					WHERE	Form_Name = 'TD_Home_ESS_345' 				
			END

		--Pending Document's List
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_278')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -2, 
						IsUpdated=1,
						Form_Url='javascript:openDialog("pendingDocument")',
						Category='Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_278'	
			END

		--View Graphical Report
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_279')
			BEGIN
				UPDATE	N
				SET		Rec_Value = -1, 
						IsUpdated=1,
						Category='Payroll'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_279'	
			END

		--Loan Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_280')
			BEGIN
				EXEC SP_Get_Loan_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Loan_Status = ''N'')',  1			

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_280'
			END

		--About Me
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_285')
			BEGIN
				PRINT 'About Me'
			END

		--Travel Settlement Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_287')
			BEGIN
				exec SP_Get_Travel_Settlement_Application_Records @cmp_id ,@Emp_ID ,0 ,'(Status_New = ''P'')', 1			
				
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_287'
			END			

		--Claim Approvals
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_315')
			BEGIN
				exec SP_Get_Claim_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Claim_App_Status = ''P'' and Submit_Flag=0)', 1			

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_315'
			END			

		--Warning Details
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_264')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1,
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_264'
			END	

		--Who's Off
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_Ess_289')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1,
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_Ess_289'
			END

		--Reward your team
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_341')
			BEGIN
				DECLARE @Cat_ID INT

				SELECT @Cat_ID = Cat_ID from T0095_INCREMENT WITH (NOLOCK) where Increment_ID = (select max(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@Emp_ID)

				DECLARE @DateRange AS Varchar(128)

				Select	@Rec_Value = Count(1), @DateRange = Convert(varchar(10),Max(From_Date), 103) + ' to ' + Convert(varchar(10),Max(To_Date), 103)
				from	T0052_HRMS_InitiateReward WITH (NOLOCK)
				where	Cmp_Id=@Cmp_ID and From_Date <= GETDATE() and  GETDATE() <= To_Date 
						and (Dept_Id like '%' + @P_Dept_ID + '%' or Dept_Id ='') and Cat_Id = IsNull(@Cat_ID, Cat_ID) 
						and InitReward_Id = (SELECT MAX(InitReward_Id)	
											 FROM	T0052_HRMS_InitiateReward WITH (NOLOCK)
											 WHERE	Cmp_Id=@Cmp_ID and From_Date <= GETDATE() 
													AND GETDATE() <= To_Date and (Dept_Id like '%' + @P_Dept_ID + '%' or Dept_Id ='') 
													AND Cat_Id = IsNull(@Cat_ID, Cat_ID)) 

				UPDATE	#Notification
				SET		Rec_Value = Case When @Rec_Value > 0 Then -1 Else 0 End,
						IsUpdated = Case When @Rec_Value > 0 Then 1 Else IsUpdated End,
						Alias = 'Reward your team from ' + @DateRange,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_341'
			END

		--Change Request Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_Ess_342')
			BEGIN
				exec SP_Get_Change_Request_Records @Cmp_ID ,@Emp_ID ,0 ,'(Request_status=''Pending'')',  1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_Ess_342'
			END

		--Give Training Feedback
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_288')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1, --I don't know why
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_288' 
			END

		--Training Questionnaire
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_297')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1, --I don't know why
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_297' 
			END

		--OJT pending for last month joinees
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_298')
			BEGIN
				PRINT 'OJT pending for last month joinees'
			END

		--OJT pending since last year
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_299')
			BEGIN
				PRINT 'OJT pending since last year'
			END

		--Training Manager Feedback
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_307')
			BEGIN
				exec Get_Training_QuestionManager @R_Emp_ID=@Emp_ID, @Type=1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_307'
			END

		--Gate Pass Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_308')
			BEGIN
				exec SP_Get_GatePass_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'App_Status = ''P''', @Type = 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_308'
			END

		--Exit Clearance Detail
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_309')
			BEGIN
				--Added By Jaina 04-06-2016 (Exit Clearance Detail)
				IF EXISTS(SELECT 1 from T0040_SETTING WITH (NOLOCK) where cmp_id=@Cmp_ID and SETTING_NAME='Enable Exit Clearance Process Cost Center Wise' and Setting_Value=1)
					begin
						declare @Reminderday numeric	
						SET @Reminderday  = 0
						Select @Reminderday = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Setting_Name ='Reminder Days for Exit Clearance Cost Center Wise'	

						SELECT	@Rec_Value = COUNT(APPROVAL_ID)
						FROM	T0300_EXIT_CLEARANCE_APPROVAL EA WITH (NOLOCK)
								INNER JOIN T0095_EXIT_CLEARANCE EC WITH (NOLOCK) ON EA.HOD_ID = EC.EMP_ID AND (EC.Center_ID =EA.Center_ID)
								INNER JOIN T0200_Emp_ExitApplication E WITH (NOLOCK) ON EA.Exit_ID =E.Exit_ID
						WHERE	EA.NOC_STATUS='P' AND EA.HOD_ID = @Emp_ID AND EA.CMP_ID = @CMP_ID AND E.sup_ack = 'P' 
								and (GETDATE() BETWEEN DateAdd(DAY,@Reminderday,last_date) AND (last_date+1)or GETDATE() >= last_date)
					end
				else
					BEGIN
						SELECT	@Rec_Value = COUNT(APPROVAL_ID)
						FROM	T0300_EXIT_CLEARANCE_APPROVAL EA WITH (NOLOCK)
								INNER JOIN T0095_EXIT_CLEARANCE EC WITH (NOLOCK) ON EA.HOD_ID = EC.EMP_ID AND (EC.Dept_id = EA.Dept_Id)
								INNER JOIN T0200_Emp_ExitApplication E WITH (NOLOCK) ON EA.Exit_ID =E.Exit_ID
						WHERE	EA.NOC_STATUS='P' AND EA.HOD_ID = @Emp_ID AND EA.CMP_ID = @CMP_ID AND E.sup_ack = 'P' 
					END
				
				UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,
						Category='Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_309'
			END

		--Recruitment Openings
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_311')
			BEGIN
				DECLARE @Domain VARCHAR(1024)
				DECLARE @Form_URL VARCHAR(1024)
				Select	TOP 1 @Domain=Domain_Name  
				FROM	T0052_HRMS_Posted_Recruitment PR WITH (NOLOCK)
						INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = PR.Cmp_id 
				WHERE	PR.cmp_id=@Cmp_ID and Posted_status = 1 and Publish_ToEmp = 1 
						AND GETDATE() BETWEEN Publish_FromDate AND DateAdd(d,1,publish_todate)										
				
				IF @Domain IS NOT NULL
					BEGIN
						
						IF EXISTS(SELECT 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Current Opening Link New' and is_active_for_menu=1 )
							SELECT	@Form_URL=Form_url + '?id=' + @Domain + '&src=Employee' 
							from	T0000_DEFAULT_FORM WITH (NOLOCK) 
							WHERE	alias = 'Current Opening Link New' and is_active_for_menu=1 
						ELSE IF EXISTS(SELECT 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Current Opening Link' and is_active_for_menu=1 )
							SELECT	@Form_URL=Form_url + '?id=' + @Domain + '&src=Employee&flag=1' 
							from	T0000_DEFAULT_FORM WITH (NOLOCK)
							WHERE	alias = 'Current Opening Link' and is_active_for_menu=1 and Form_Url <> 'Current Opening Link'
						ELSE
							SET @Form_URL= 'View_Current_Open.aspx?id=' + @Domain + '&src=Employee&flag=1' 

						UPDATE	#Notification
						SET		Rec_Value = -1,
								IsUpdated=1,
								Form_Url = @Form_URL
						WHERE	Form_Name = 'TD_Home_ESS_311'
					END				
				UPDATE	#Notification
				SET		Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_311'
			END

		--Optional Holiday Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_312')
			BEGIN				
				SELECT	@Rec_Value = isnull(COUNT(Op_Holiday_App_ID),0) 
				FROM	V0100_Optional_Holiday_Application 				
				WHERE	Op_Holiday_Status='P' AND Emp_Superior=@Emp_ID and Emp_Left <> 'Y'
	
				UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_312'
			END

		--Overtime Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_313')
			BEGIN
				EXEC SP_Get_OT_Level_Approval_Records @Cmp_ID=@Cmp_ID,@Emp_ID=0,@R_Emp_ID = @Emp_Id,@From_Date = @From_Date,
										  @To_Date = @To_Date,@Rpt_level=0,@Return_Record_set = 4,
										  @Constraint = N'1=1 and status = ''P''',@Type = 1,@DEPT_Id =0,@GRD_Id = 0	
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value),
						IsUpdated=1,
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_313'
			END

		--Fill Self Assessment Probation Form
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_314')
			BEGIN
				SET @Where = ' AND Emp_ID=' + Cast(@Emp_ID As Varchar(10))  
				EXEC P_GET_PROBATION_TRAINEE_LIST @Cmp_ID=@Cmp_ID,@flag='Probation', @condition=@Where, @Type='HomePage'

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value),
						IsUpdated=1,
						Form_Url = Form_Url + '?Add=1',
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_314'
			END

		--Fill HR Checklist
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_316')
			BEGIN
				exec SP_Get_HR_Checklist_Details @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Type_ID = 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value),
						IsUpdated=1,
						Form_Url = 'javascript:__doPostBack("FillHRChecklist", "true")',
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_316'
			END

		--Induction Training Questionaries
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_317')
			BEGIN						
				SELECT	@Rec_Value = COUNT(DISTINCT HTM.TRAINING_ID) 
				FROM	T0040_HRMS_TRAINING_MASTER HTM WITH (NOLOCK)
						INNER JOIN T0030_HRMS_TRAINING_TYPE HTT WITH (NOLOCK) ON HTT.TRAINING_TYPE_ID = HTM.TRAINING_TYPE
						INNER JOIN T0050_EMP_WISE_CHECKLIST EWC WITH (NOLOCK) ON EWC.TRAINING_ID = HTM.TRAINING_ID
				WHERE	HTM.CMP_ID = @CMP_ID AND ISNULL(HTT.TYPE_INDUCTION,0) = 1 AND EWC.EMP_ID = @EMP_ID AND HTT.Induction_Traning_Dept = 1 -- For HR Department
						AND EWC.FILL_DATE <= GETDATE() AND EWC.PASSING_FLAG IN (0,2) -- 0 For No Exam Conduct , 2 For Fail Exam	
						AND EXISTS(Select 1 From T0150_HRMS_TRAINING_QUESTIONNAIRE HTQ WITH (NOLOCK) Where CHARINDEX(Cast(HTM.Training_id as Varchar(10)),HTQ.Training_Id) > 0)		
				
				UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,
						Form_Url = Form_Url + '?TFlag=1',
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_317'
			END

		--Fill Functional Checklist
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_318')
			BEGIN
				EXEC SP_Get_Fun_Checklist_Details @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Type_ID = 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value),
						IsUpdated=1,
						Form_Url='javascript:__doPostBack("OpenEmployeeAttendance", "true")',
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_318'
			END

		--Fill Functional Checklist
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_319')
			BEGIN
				SELECT	@Rec_Value = COUNT(TRAINING_ID) 
				FROM	(
						SELECT	DISTINCT HTM.TRAINING_ID
						FROM	T0040_HRMS_TRAINING_MASTER HTM WITH (NOLOCK)
								INNER JOIN T0030_HRMS_TRAINING_TYPE HTT WITH (NOLOCK) ON HTT.TRAINING_TYPE_ID = HTM.TRAINING_TYPE
								INNER JOIN T0050_EMP_WISE_FUN_CHECKLIST EWC WITH (NOLOCK) ON EWC.TRAINING_ID = HTM.TRAINING_ID						
						WHERE	HTM.CMP_ID = @CMP_ID AND ISNULL(HTT.TYPE_INDUCTION,0) = 1 AND EWC.EMP_ID = @EMP_ID AND HTT.Induction_Traning_Dept = 2 -- For HR Department
								AND EWC.FILL_DATE <= GETDATE() AND EWC.PASSING_FLAG IN (0,2) -- 0 For No Exam Conduct , 2 For Fail Exam
								AND EXISTS(Select 1 From T0150_HRMS_TRAINING_QUESTIONNAIRE HTQ WITH (NOLOCK) Where CHARINDEX(Cast(HTM.Training_id as Varchar(10)),HTQ.Training_Id) > 0)
						)T


				
				UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,
						Form_Url=Form_Url  + '?TFlag=2',
						Category = 'Payroll'
				WHERE	Form_Name = 'TD_Home_ESS_319'
			END


		/**********************************************************************
										Apprisal
		**********************************************************************/
		
		UPDATE	#Notification SET Category = '' WHERE Category IS NULL

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_291' --Apprisal Tab

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_310' --Training Calendar

		

		--My Appraisal Notification
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_292')
			BEGIN							
				UPDATE	#Notification
				SET		Rec_Value = (SELECT Count(1) FROM V0090_hrms_appraisal_status_Report 
									WHERE	Emp_ID=@Emp_ID and Is_Accept=2 and Invoke_Emp=2 and ISNULL(Inspection_Status,0)=0),
						IsUpdated=1,
						Alias='Your Appraisal is invoked. Kindly fill detail to make it effective.'
				WHERE	Form_Name = 'TD_Home_ESS_292'
			END

		--Appraisal Notification for Team
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_293')
			BEGIN							
				UPDATE	#Notification
				SET		Rec_Value = (SELECT Count(1) FROM V0090_hrms_appraisal_status_Report 
									WHERE	Emp_ID=@Emp_ID and Is_Accept=2 and Invoke_Emp=2 and ISNULL(Inspection_Status,0)=0),
						IsUpdated=1,
						Alias='Your Team Member''s Appraisal invoked, You want to give any suggestion.'
				WHERE	Form_Name = 'TD_Home_ESS_293'
			END

		--SELECT  N.*
		--FROM	#Notification N				
		
		DECLARE @JSONData NVarchar(Max)

		SELECT  @JSONData = COALESCE(@JSONData + ',', '') + '
					{
						"Row_ID" :' + Cast(Row_ID As Varchar(10)) + ',
						"Form_ID" :' + Cast(Form_ID As Varchar(10)) + ',
						"Form_Name" : "' + Form_Name + '",
						"Category" :' + ISNULL('"' + Category + '"', 'null') + ',
						"Rec_Value" :' + ISNULL('"' + Cast(Rec_Value As Varchar(18)) + '"', 'null') + ',
						"NotifyDate" :' + ISNULL('"' + Convert(Varchar(20), NotifyDate , 111) + '"', 'null') + ',
						"Alias" :' + ISNULL('"' + Alias + '"', 'null') + ',
						"Form_Url" :' + ISNULL('"' + Replace(Form_Url, '"', '''') + '"', 'null') + ',
						"IsUpdated" :' + Cast(IsNull(IsUpdated,0) As Varchar(3)) + '
					}'					
		FROM	#Notification N				
		
		IF @JSONData Is Not Null
			SET @JSONData = '['  + @JSONData +  ']'
		
		select @JSONData
		print @JSONData
		--Where	IsUpdated=1
	END
