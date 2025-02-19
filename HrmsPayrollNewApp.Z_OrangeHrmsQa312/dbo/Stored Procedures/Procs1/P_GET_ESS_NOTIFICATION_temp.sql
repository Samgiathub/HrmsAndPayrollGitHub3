

/* This sp is used  for top bar notification with count */
CREATE PROCEDURE [dbo].[P_GET_ESS_NOTIFICATION_temp]
	@Cmp_ID			INT,
	@Emp_ID			INT,
	@Privilege_ID	INT = 0
AS
	BEGIN
			SET NOCOUNT ON;
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
		DECLARE @Desig_Id INT
		DECLARE @EmpBranch_ID INT
		DECLARE @CAPTION AS VARCHAR(1000)
		SET @From_Date  = DATEADD(MONTH, DATEDIFF(MONTH, 0, Getdate())-1, 0)		
		SET	@To_Date = GETDATE()

		print @From_Date
		print @To_date
		/*
		Fill Emp Cons
		*/
		BEGIN
			INSERT INTO #Emp_Cons(EMP_ID, Branch_ID, Increment_ID)
			SELECT	I.EMP_ID, I.Branch_ID, I.Increment_ID
			FROM	T0095_INCREMENT I WITH (NOLOCK)
					INNER JOIN T0080_EMP_MASTER	 E ON I.Emp_ID=E.Emp_ID
					INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) As Increment_Effective_Date
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.Increment_Effective_Date  <= GETDATE()
													GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
										WHERE	I1.Increment_Effective_Date  <= GETDATE()
								GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_ID=I1.Increment_ID					
					INNER JOIN T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)	ON I.Emp_ID=R.Emp_ID
					INNER JOIN (SELECT	EMP_ID, MAX(R1.Effect_Date) As Effect_Date
								FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)							
								WHERE	R1.Effect_Date <= GETDATE()
								GROUP BY EMP_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Effect_Date=R1.Effect_Date		
			WHERE	R.R_Emp_ID=@Emp_ID AND  IsNull(E.Emp_Left_Date, getdate()+1)  > getdate() AND E.Date_Of_Join < GETDATE()
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
		SELECT	ROW_NUMBER() OVER(ORDER BY Sort_ID, Sort_ID_Check) ROW_ID, D.Form_ID, Form_Name, '', 0, GetDate(), Isnull(D.Alias,''), Isnull(D.Form_Url,'')
		FROM	T0000_DEFAULT_FORM D WITH (NOLOCK)
				LEFT OUTER JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON D.Form_ID=PD.Form_Id AND PD.Privilage_ID=@Privilege_ID AND (Is_Edit + Is_View + Is_Save + Is_Delete  + Is_Print) > 0
		WHERE	D.Page_Flag='DE' AND (Case When @Privilege_ID > 0  AND IsNull(PD.Privilage_ID,0) = 0 Then 0 Else 1 End ) = 1  
				AND EXISTS(SELECT 1 FROM T0011_module_detail M 
						WHERE ( IsNull(D.Module_name, 'Payroll') = M.module_name  )				
						 AND M.module_status=1)
   --select * from #Notification
 		declare @curr_row_id  int=0
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve')
			BEGIN
		
				set @curr_row_id=(select max(Row_ID) from #Notification)
				IF not EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_forward')
				begin
				Insert Into #Notification(Row_ID, Form_ID,Form_Name,Category, Rec_Value, NotifyDate,Alias, Form_Url)
				values((@curr_row_id+1),20396,'TD_Home_ESS_File_Approve_forward','', 0, GetDate(),'File Approval Forward To Emp','')
				end
				set @curr_row_id=(select max(Row_ID) from #Notification)
				IF not EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_Forward_By')
				begin
				Insert Into #Notification(Row_ID, Form_ID,Form_Name,Category, Rec_Value, NotifyDate,Alias, Form_Url)
				values((@curr_row_id+1),20397,'TD_Home_ESS_File_Approve_Forward_By','', 0, GetDate(),'File Approval Forward By Emp','')
				end
				set @curr_row_id=(select max(Row_ID) from #Notification)
				IF not EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_Forward_By')
				begin
				Insert Into #Notification(Row_ID, Form_ID,Form_Name,Category, Rec_Value, NotifyDate,Alias, Form_Url)
				values((@curr_row_id+1),20398,'TD_Home_ESS_File_Approve_Reivew','', 0, GetDate(),'File Approval Review To Emp','')
				end
				set @curr_row_id=(select max(Row_ID) from #Notification)
					IF not EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_Forward_By')
				begin
				Insert Into #Notification(Row_ID, Form_ID,Form_Name,Category, Rec_Value, NotifyDate,Alias, Form_Url)
				values((@curr_row_id+1),20399,'TD_Home_ESS_File_Approve_Reivew_By','', 0, GetDate(),'File Approval Review By Emp','')
				end
			END
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
						Category = 'Payroll',
						Form_Url='Emp_Inout_New.aspx?id=1'
				WHERE	Form_Name = 'TD_Home_ESS_262'
			END
		
	    --My Team Member Details
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_263')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1,
						IsUpdated=1,
						Category = 'Payroll',
						Form_Url='Employee_Downline.aspx'
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
						Category = 'Payroll',
						Form_Url='Timesheet_Approval.aspx'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_290'					
			END
			
		--Leave Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_265')
			BEGIN
				declare @Y_From_Date as varchar(50)
				declare @Y_TO_Date as varchar(50)
				declare @Constrains as VARCHAR(1000)
				set @Y_From_Date = dbo.GET_YEAR_START_DATE (year(GETDATE()),month(getdate()),1)
				set @Y_TO_Date = dbo.GET_YEAR_END_DATE (year(GETDATE()),month(getdate()),1)
				set @Constrains = '(Application_Status = ''P'' or Application_Status = ''F'') 
									And From_Date >= '''+ cast(@Y_From_Date as varchar(25)) +''' 
									and To_Date <= '''+ cast(@Y_TO_Date as varchar(25)) +''''		
				
				exec dbo.SP_Get_Leave_Application_Records @Cmp_ID ,@Emp_ID ,0 ,@Constrains, 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll',
						Form_Url='Leave_Approve.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_265'
			END

		--Leave Cancellation Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_266')
			BEGIN
				UPDATE	N
				SET		Rec_Value = (SELECT	COUNT(1) 
									FROM	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
											INNER JOIN #EMP_CONS EC ON LA.Emp_ID=EC.Emp_ID
									WHERE	LA.Approval_Status IN ('A', 'R')				
											AND EXISTS(SELECT 1 from T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) WHERE LC.is_approve = 0 AND LC.Leave_Approval_ID=LA.Leave_Approval_ID)), 
						IsUpdated=1,
						Category = 'Payroll',
						Form_Url='Leave_Cancelation_Approval.aspx'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_266'			
			END

		--In Time commented binal 23102019 due to not need 
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_267')
		--	BEGIN				
		--		PRINT 'In Time'
		--	END

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
						Category = 'Payroll',
						Form_Url = 'ESS_Employee_History.aspx'
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

	    --Holiday Calendar Not need binal comment 23102019
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_271')
		--	BEGIN
		--		UPDATE	N
		--		SET		Rec_Value = -2, 
		--				IsUpdated=1,
		--				Form_Url='javascript:__doPostBack("OpenYearlyHoliday", "true")',
		--				Category = 'Payroll'
		--		FROM	#Notification N			
		--		Where	Form_Name='TD_Home_ESS_271'		
		--	END

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
						Category = 'Payroll',
						Form_Url = 'Employee_Probation.aspx'
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
						Category = 'Payroll',
						Form_Url = 'Employee_Probation.aspx'
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
											FROM	T0090_EMP_REPORTING_DETAIL R1  WITH (NOLOCK)
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
						Category = 'Payroll',
						Form_Url='CompOff_Approval.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_274'
			END

		--Pre Comp Off Application
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_Ess_343')
			BEGIN
				exec SP_Get_PreCompOff_Application_Records @Cmp_ID,@Emp_ID,0,'(App_Status = ''P'')',1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category = 'Payroll',
						Form_Url='PreCompOff_Approval.aspx'
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
									/*Form_Url='javascript:__doPostBack("getNotice", "true")',*/
									Form_Url='My_ExitInterview.aspx',/*added in 04122020 by binal*/
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
						Category='Payroll',
						Form_Url='Emp_ManagerFeedback.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_276'				
			END

		--Reimbursement Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_277')
			BEGIN
				exec SP_Get_RC_Application_Records @Cmp_ID=@Cmp_Id,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'(Status = ''Pending'' and Submit_Flag=0)',@type= 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url = 'Employee_ReimClaim_Approval.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_277'
			END

		--Fill Up The Survey Form
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_345')
			BEGIN
				SELECT @Desig_Id=Desig_Id,@EmpBranch_ID=Branch_ID from V0080_EMP_MASTER_INCREMENT_GET where emp_id=@emp_id
				IF EXISTS(Select Survey_ID,Survey_Title from T0050_SurveyMaster WITH (NOLOCK) 
						  WHERE Cmp_ID=@Cmp_ID and (@Emp_ID in (SELECT cast(data AS numeric(18, 0)) FROM  dbo.Split(ISNULL(dbo.T0050_SurveyMaster.survey_empid, '0'), '#') WHERE data <> '') or 
						  @desig_id  in (SELECT cast(data AS numeric(18, 0)) FROM  dbo.Split(ISNULL(dbo.T0050_SurveyMaster.desig_id, '0'), '#') WHERE data <> '') or 
						  @Branch_ID = Branch_Id)  and GETDATE() >= SurveyStart_Date and CAST(GETDATE() as varchar(12)) <= Survey_OpenTill)
						  
					UPDATE	#Notification 
					SET		IsUpdated=1, 
							Rec_Value=-1,
							Alias = 'Fill Up The Survey Form',
							Category='Payroll',
							Form_Url='ess_surveyform.aspx'
					WHERE	Form_Name = 'TD_Home_ESS_345' 				
			END

		--Pending Document's List
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_278')
		--	BEGIN
		--		UPDATE	N
		--		SET		Rec_Value = -2, 
		--				IsUpdated=1,
		--				Form_Url='javascript:openDialog("pendingDocument")',
		--				Category='Payroll'
		--		FROM	#Notification N			
		--		Where	Form_Name='TD_Home_ESS_278'	
		--	END

		--View Graphical Report removed page unnecessary
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_279')
		--	BEGIN
		--		UPDATE	N
		--		SET		Rec_Value = -1, 
		--				IsUpdated=1,
		--				Category='Payroll',
		--				Form_Url='Graphical_chart_Ess.aspx'
		--		FROM	#Notification N			
		--		Where	Form_Name='TD_Home_ESS_279'	
		--	END

		--Loan Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_280')
			BEGIN
				EXEC SP_Get_Loan_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Loan_Status = ''N'')',  1			

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url='Loan_Approve_Ess.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_280'
			END

		--About Me
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_285')
		--	BEGIN
		--		PRINT 'About Me'
		--	END

		--Travel Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_286')
			BEGIN
				exec SP_Get_Travel_Application_Records @Cmp_ID,@Emp_ID,0,N'Application_Status = ''P''',1			
				
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url = 'Travel_Approval_Superior.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_286'
			END	


		--Travel Settlement Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_287')
			BEGIN
				exec SP_Get_Travel_Settlement_Application_Records @cmp_id ,@Emp_ID ,0 ,'(Status_New = ''P'')', 1			
				
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url = 'Travel_Settlement_Approval_Superior.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_287'
			END		

		--Claim Approvals
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_315')
			BEGIN
				exec SP_Get_Claim_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Claim_App_Status = ''P'' and Submit_Flag=0)', 1			

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url='Claim_Approval_superior.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_315'
			END	

		--Warning Details
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_264')
		--	BEGIN
		--		UPDATE	#Notification
		--		SET		Rec_Value = -1,
		--				IsUpdated=1,
		--				Category='Payroll',
		--				Form_Url='Employee_Warning.aspx'
		--		WHERE	Form_Name = 'TD_Home_ESS_264'
		--	END	

		--Who's Off
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_Ess_289')
		--	BEGIN				
		--		UPDATE	#Notification
		--		SET		Rec_Value = -1,
		--				IsUpdated=1,
		--				Category='Payroll',
		--				Form_Url='WhosOffInMyTeam.aspx'
		--		WHERE	Form_Name = 'TD_Home_Ess_289'
		--	END

		--Reward your team

		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_341')
			BEGIN
				DECLARE @Cat_ID varchar(10)

				SELECT @Cat_ID = Cat_ID from T0095_INCREMENT WITH (NOLOCK) where Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where Emp_ID=@Emp_ID)

				DECLARE @DateRange AS Varchar(128)

				Select	@Rec_Value = Count(1), @DateRange = Convert(varchar(10),Max(From_Date), 103) + ' to ' + Convert(varchar(10),Max(To_Date), 103)
				from	T0052_HRMS_InitiateReward WITH (NOLOCK) 
				where	Cmp_Id=@Cmp_ID and From_Date <= GETDATE() and  GETDATE() <= To_Date 
						and (Dept_Id like '%' + @P_Dept_ID + '%' or Dept_Id ='') AND CHARINDEX(IsNull(@Cat_ID, Cat_ID),Cat_Id) > 0 
						and InitReward_Id = (SELECT MAX(InitReward_Id)	
											 FROM	T0052_HRMS_InitiateReward WITH (NOLOCK) 
											 WHERE	Cmp_Id=@Cmp_ID and From_Date <= GETDATE() 
													AND GETDATE() <= To_Date and (Dept_Id like '%' + @P_Dept_ID + '%' or Dept_Id ='') 
													AND CHARINDEX(IsNull(@Cat_ID, Cat_ID),Cat_Id) > 0) 

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
						Category='Payroll',
						Form_Url='Change_Request_Approval.aspx'
				WHERE	Form_Name = 'TD_Home_Ess_342'
			END

		--Give Training Feedback
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_288')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1, --I don't know why
						IsUpdated=1,
						Category='Payroll',
						Form_Url='ESS_TrainingFeedback.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_288' 
			END

		--Training Questionnaire
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_297')
			BEGIN
				UPDATE	#Notification
				SET		Rec_Value = -1, --I don't know why
						IsUpdated=1,
						Category='Payroll',
						Form_Url='Ess_TrainingAnswers.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_297' 
			END

		----OJT pending for last month joinees
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_298')
		--	BEGIN
		--		PRINT 'OJT pending for last month joinees'
		--	END

		----OJT pending since last year
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_299')
		--	BEGIN
		--		PRINT 'OJT pending since last year'
		--	END

		--Training Manager Feedback
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_307')
			BEGIN
				exec Get_Training_QuestionManager @R_Emp_ID=@Emp_ID, @Type=1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url='ESS_Manager_TrainingFeedback.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_307'
			END

	    --Gate Pass Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_308')
			BEGIN
				exec SP_Get_GatePass_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'App_Status = ''P''', @Type = 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url='Ess_GatePass_Approval.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_308'
			END

		--File Approval start
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve')
			BEGIN
			exec SP_Get_File_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'F_StatusId in(1,4)', @Type = 1
				--exec SP_Get_GatePass_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'App_Status = ''P''', @Type = 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,
						Category='Payroll',
						Form_Url='ESS_File_Approve.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_File_Approve'

				Declare @N_count as numeric(18,0)=0,@NFB_count as numeric(18,0)=0,@NR_count as numeric(18,0)=0,@NRB_count as numeric(18,0)=0
					IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_forward')
					BEGIN
			
						set @N_count=(Select  count(1)  from(select File_App_Id from VIEW_File_FINAL_N_LEVEL_APPROVAL 
											  where F_StatusId=3 and Forward_Emp_Id=13974 and (updatedbyEmp<>13974 or isnull(updatedbyEmp,0)=0))as t) 
						--print @N_count

						UPDATE	#Notification
						SET		Rec_Value = @N_count,
								IsUpdated=1,
								Category='Payroll'
								,Form_Url='ESS_File_Approve.aspx'
								,Alias='File Approval Forward To Emp'
						WHERE	Form_Name = 'TD_Home_ESS_File_Approve_forward'
					END

					IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_Forward_By')
					BEGIN
			
						set @NFB_count=(Select  count(1)  from(select File_App_Id from VIEW_File_FINAL_N_LEVEL_APPROVAL 
											  where F_StatusId=3 and Submit_Emp_Id=@Emp_ID and (updatedbyEmp<>@Emp_ID or isnull(updatedbyEmp,0)=0))as t) 
					
						UPDATE	#Notification
						SET		Rec_Value = @NFB_count,
								IsUpdated=1,
								Category='Payroll',
								Form_Url='ESS_File_Approve.aspx'
								,Alias='File Approval Forward By Emp'
						WHERE	Form_Name = 'TD_Home_ESS_File_Approve_Forward_By'
					END

					IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_Reivew')
					BEGIN
			
						set @NR_count=(Select  count(1)  from(select File_App_Id from VIEW_File_FINAL_N_LEVEL_APPROVAL 
											  where F_StatusId=5 and Review_Emp_Id=@Emp_ID and (updatedbyEmp<>@Emp_ID or isnull(updatedbyEmp,0)=0))as t) 
						
						UPDATE	#Notification
						SET		Rec_Value = @NR_count,
								IsUpdated=1,
								Category='Payroll',
								Form_Url='ESS_File_Approve.aspx'
								,Alias='File Approval Review To Emp'
						WHERE	Form_Name = 'TD_Home_ESS_File_Approve_Reivew'
					END

					IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_File_Approve_Reivew_By')
					BEGIN
			
						set @NRB_count=(Select  count(1)  from(select File_App_Id from VIEW_File_FINAL_N_LEVEL_APPROVAL 
											  where F_StatusId=5 and Reviewed_by_Emp_Id=@Emp_ID and (updatedbyEmp<>@Emp_ID or isnull(updatedbyEmp,0)=0))as t) 
						
						UPDATE	#Notification
						SET		Rec_Value = @NRB_count,
								IsUpdated=1,
								Category='Payroll',
								Form_Url='ESS_File_Approve.aspx'
								,Alias='File Approval Review By Emp'
						WHERE	Form_Name = 'TD_Home_ESS_File_Approve_Reivew_By'
					END
			END

			
			--File Approval end
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
						Category='Payroll',
						Form_Url='Emp_Exit_Clearance_Approval.aspx'
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
							from	T0000_DEFAULT_FORM  WITH (NOLOCK)
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
						Category = 'Payroll',
						Form_Url='Optional_HO_Approval_Manager.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_312'
			END
		
		--Own Your Vehicle Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_358')
			BEGIN				
				UPDATE	N
				SET		Rec_Value = (SELECT	COUNT(Vehicle_App_ID) 
									FROM	V0100_VEHICLE_APPLICATION VA
											INNER JOIN #EMP_CONS EC ON VA.emp_id=EC.Emp_ID
									Where	App_Status = 'PENDING'), 
						IsUpdated=1,
						Category = 'Payroll',
						Form_Url='Vehicle_Approval.aspx'
				FROM	#Notification N			
				Where	Form_Name='TD_Home_ESS_358'					
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
			--select 1233--mansi
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


		--Overtime Approval
		IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_313')
			BEGIN
				print 'm'
				EXEC SP_Get_OT_Level_Approval_Records @Cmp_ID=@Cmp_ID,@Emp_ID=0,@R_Emp_ID = @Emp_Id,@From_Date = @From_Date,
										  @To_Date = @To_Date,@Rpt_level=0,@Return_Record_set = 4,
										  @Constraint = N'1=1 and status = ''P''',@Type = 1,@DEPT_Id =0,@GRD_Id = 0	
				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value),
						IsUpdated=1,
						Category = 'Payroll',
						Form_Url='Employee_OT.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_313'
			END

		--Recruitment Application Approval	
			IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_357')
			BEGIN
				exec dbo.Get_Recruitment_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'', 1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,						
						Form_Url='Recruitment_Application_Approval.aspx'
				WHERE	Form_Name = 'TD_Home_ESS_357'
			END
		--Resume Screening	
			IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_HR_7')
			BEGIN
				--exec dbo.Get_Recruitment_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'', 1
				exec dbo.SP_GET_RESUME_DETAIL_ESS @Rec_Post_Id=0,@key_words='',@location='',@experiance='0',@from_date='',@to_date='',@age='0',@status='4',@screendempby=@Emp_ID,@Type=1

				UPDATE	#Notification
				SET		Rec_Value = (select TOP 1 Rec_Value FROM #Notification_Value ),
						IsUpdated=1,						
						Form_Url='ess_resumescreening.aspx'
				WHERE	Form_Name = 'TD_Home_HR_7'
			END
			
		IF EXISTS(SELECT 1 FROM T0011_module_detail WHERE module_status=1 AND module_name='Appraisal2' AND CMP_ID=@Cmp_ID)
		BEGIN
	---------------------------------------Self Assessment(Start)----------------------------------------------
			--IF EXISTS(SELECT InitiateId,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate 
			--		  FROM T0050_HRMS_InitiateAppraisal 
			--		  WHERE Emp_Id = @emp_id AND   
			--				SA_Startdate <= CONVERT(varchar(10),GETDATE(),120) and (SA_Enddate >= CONVERT(varchar(10),GETDATE(),120) 
			--				and SA_Status in(3,4)) and SA_SendToRM <> 1)
			--	BEGIN	
			--		SELECT @Rec_Value =InitiateId--,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate 
			--		FROM  T0050_HRMS_InitiateAppraisal inner JOIN
			--				(
			--					SELECT (case when SA_Status =2 then 1 when SA_Status = 1 then 0
			--					when (SA_Status= 4 or SA_Status = 0 or SA_Status = 3) then case when SA_Enddate>= '2017-03-31' then 1 else 0  end  else 0 end) show,InitiateId as initid
			--					from T0050_HRMS_InitiateAppraisal
			--					where Emp_Id = @emp_id
			--					and   SA_Startdate <= CONVERT(varchar(10),GETDATE(),120)
			--				)t on t.initid = T0050_HRMS_InitiateAppraisal.InitiateId
			--		WHERE Emp_Id = @emp_id AND   
			--			  SA_Startdate <= CONVERT(varchar(10),GETDATE(),120) and t.show = 1 --and ( SA_Enddate >= CONVERT(varchar(10),GETDATE(),120) and SA_Status<>1) and SA_SendToRM <> 1
							
			--		SELECT @Form_URL=CASE WHEN isnull(Form_url,'SelfAppraisal_Form.aspx')<>'' THEN Form_url +'?Initid=' + cast(@Rec_Value AS VARCHAR) ELSE 'SelfAppraisal_Form.aspx?Initid=' + cast(@Rec_Value AS VARCHAR) END 
			--		FROM T0000_DEFAULT_FORM 
			--		WHERE Form_Name='TD_Home_ESS_294'	
					
			--		UPDATE	#Notification
			--		SET		Rec_Value = 1,
			--				IsUpdated=1,					
			--				Form_Url= @Form_URL
			--		WHERE	Form_Name = 'TD_Home_ESS_294'
			--	END
---------------------------------------Self Assessment(End)----------------------------------------------
---------------Performance Assessment Pending(RM_Level)Start------------
				DECLARE @initcount INT = 0
				SELECT @Rec_Value = COUNT(i.InitiateId) 
				FROM  T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) INNER JOIN
				T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) on ERD.Emp_ID = i.Emp_Id
				 INNER JOIN 
				(
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID FROM
					T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,T0090_EMP_REPORTING_DETAIL.Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
							 T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) ON IA.Emp_Id = T0090_EMP_REPORTING_DETAIL.Emp_ID
						WHERE Effect_Date<= IA.SA_Startdate AND ((SA_Status=0) or (SA_Status=1 and Overall_Status=8) or (SA_Status=1 and Overall_Status=9))
						GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID
					)ERD1 ON ERD1.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
				)ERD2 ON ERD2.Row_ID = erd.Row_ID AND ERD2.Emp_ID = ERD.Emp_ID
				WHERE ERD.R_Emp_ID = @emp_id AND ((SA_Status=0) or (I.SA_Status=1 and I.Overall_Status=8) or (I.SA_Status=1 and I.Overall_Status=9))				
				AND DATEPART(YYYY,SA_Startdate) =DATEPART(YYYY,GETDATE())
				
				DECLARE @KPA_Default as INT
				set @KPA_Default = 0
				Select top 1 @KPA_Default=KPA_Default from T0050_AppraisalLimit_Setting where cmp_id=@Cmp_ID ORDER by Limit_Id desc
				--select @Rec_Value,333
				SELECT @Form_URL=CASE WHEN isnull(Form_url,'Ess_EmpAssessment.aspx') <> '' THEN Form_url 
				WHEN @KPA_Default=1 THEN 'Ess_EmpAssessment.aspx' ELSE 'Ess_PerformanceAssessment.aspx' END 
				FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name='TD_Home_ESS_295'	
				SET @CAPTION=''
				SELECT @CAPTION=Alias  FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID=@Cmp_ID AND CaptionCode='Reporting Manager'

				UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,					
						Form_Url= @Form_URL,
						Alias='Appraisal Approval'
				WHERE	Form_Name = 'TD_Home_ESS_295'
		-------------Performance Assessment Pending(RM_Level)End------------

		-------------Performance Assessment Pending(HOD_Level) Start------------
			SELECT @Rec_Value =count(DISTINCT InitiateId) --AS InitiateId 
			FROM V0050_HRMS_InitiateAppraisal V INNER JOIN
				 T0095_INCREMENT inc WITH (NOLOCK) on inc.Emp_ID = v.Emp_Id INNER JOIN
				 (
					SELECT max(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
					(
						SELECT max(Increment_Effective_Date)Increment_Effective_Date,T0095_INCREMENT.Emp_ID
						FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
							 T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) on i.Emp_Id = T0095_INCREMENT.Emp_ID
						WHERE T0095_INCREMENT.Cmp_ID =@Cmp_ID and Increment_Effective_Date <= I.SA_Startdate
						GROUP by T0095_INCREMENT.Emp_ID
					)inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
					WHERE Cmp_ID = @Cmp_ID
					GROUP BY T0095_INCREMENT.Emp_ID
				 )inc2 ON inc2.Increment_ID = inc.Increment_ID and inc2.Emp_ID = inc.Emp_ID LEFT JOIN
				 T0095_Department_Manager DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID LEFT JOIN
				 (
					SELECT max(Effective_Date)Effective_Date,Dept_Id
					FROM T0095_Department_Manager WITH (NOLOCK)	
					WHERE Cmp_id = @Cmp_ID
					GROUP BY Dept_Id
				 )DM1 ON DM1.Dept_Id = DM.Dept_Id
			WHERE DATEPART(YYYY,SA_Startdate) = DATEPART(YYYY,GETDATE()) and 
			(V.Overall_Status=2 or V.Overall_Status=10 or Overall_Status =(CASE WHEN SendToHOD =1 and Overall_Status =0 THEN Overall_Status when SendToHOD =0 and Overall_Status is not null then null else null end)) 
			and SendToHOD =1 and @emp_id = (CASE WHEN isnull(v.hod_id,0) <> 0  THEN v.hod_id ELSE dm.Emp_id END)
		 
			SELECT @Form_URL=CASE WHEN isnull(Form_url,'Ess_ApprisalHODApproval.aspx')<>'' THEN Form_url  ELSE 'Ess_ApprisalHODApproval.aspx' END 
			FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
			WHERE Form_Name='TD_Home_ESS_350'	
			SET @CAPTION=''
			SELECT @CAPTION=Alias  FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID=@Cmp_ID AND CaptionCode='HOD'

			UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,					
						Form_Url= @Form_URL,
						Alias='Appraisal Approval'
			WHERE	Form_Name = 'TD_Home_ESS_350'
	-------------Performance Assessment Pending(HOD_Level) End------------

	-------------Performance Assessment Pending(GH_Level) Start------------
			SELECT @Rec_Value = COUNT(InitiateId) 
			FROM V0050_HRMS_InitiateAppraisal 
			WHERE  DATEPART(YYYY,SA_Startdate) = DATEPART(YYYY,GETDATE()) AND 
			(Overall_Status=11 or Overall_Status =(CASE WHEN (ISNULL(SendToHOD,0) =1 and Overall_Status =0) THEN null WHEN (isnull(SendToHOD,0) = 0 and Overall_Status=0) THEN Overall_Status WHEN (isnull(SendToHOD,0) = 1 and Overall_Status=7) THEN Overall_Status END))  
			AND GH_Id = @emp_id			
			
			SELECT @Form_URL=CASE WHEN isnull(Form_url,'Ess_AppraisalFinalization.aspx')<>'' THEN Form_url  ELSE 'Ess_AppraisalFinalization.aspx' END
			FROM T0000_DEFAULT_FORM WITH (NOLOCK) 
			WHERE Form_Name='TD_Home_ESS_296'	
			SET @CAPTION=''
			SELECT @CAPTION=Alias  FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID=@Cmp_ID AND CaptionCode='Group Head/GH'

			UPDATE	#Notification
				SET		Rec_Value = @Rec_Value,
						IsUpdated=1,					
						Form_Url= @Form_URL,
						Alias='Appraisal Approval'
			WHERE	Form_Name = 'TD_Home_ESS_296'
	-------------Performance Assessment Pending(GH_Level) End------------
	-----------------------Goal Approval(Start)-----------------------------------------
				DECLARE @CTR_R_EMP_ID AS INT
				DECLARE @CTR_HOD_ID AS INT
								
				SELECT @CTR_R_EMP_ID=COUNT(1)
				FROM V0055_Hrms_Initiate_KPASetting 
				WHERE R_Emp_ID=@EMP_ID AND Initiate_Status IN(2,6) AND Cmp_Id=@CMP_ID
				
				SELECT @CTR_HOD_ID=COUNT(1)
				FROM V0055_Hrms_Initiate_KPASetting 
				WHERE Hod_Id=@EMP_ID AND Initiate_Status IN(5,8) AND Cmp_Id=@CMP_ID
				
				SET @CAPTION=''
				SELECT @CAPTION=Alias  FROM T0040_CAPTION_SETTING WITH (NOLOCK) WHERE CMP_ID=@Cmp_ID AND CaptionCode='KPA'
				--SELECT (@CTR_R_EMP_ID+@CTR_HOD_ID)apprcnt,
	 		--	CASE WHEN @KPA_Default=1 then 'Ess_EmployeeKPA_Approval_one.aspx' else 'Ess_EmployeeKPA_Approval.aspx' end as Form_Name	
				UPDATE	#Notification
				SET		Rec_Value = (@CTR_R_EMP_ID+@CTR_HOD_ID),
						IsUpdated=1,					
						Form_Url= CASE WHEN @KPA_Default=1 then 'Ess_EmployeeKPA_Approval_one.aspx' else 'Ess_EmployeeKPA_Approval.aspx' end,
						Alias= @CAPTION + ' Approval'
				WHERE	Form_Name = 'TD_Home_ESS_356'
-----------------------Goal Approval(End)-----------------------------------------
		END

				/**********************************************************************
										Apprisal
		**********************************************************************/
		
		UPDATE	#Notification SET Category = '' WHERE Category IS NULL

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_291' --Apprisal Tab

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_310' --Training Calendar

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_271' --Delete Holiday Calander binal 23102019

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_268' --Delete Attendance Summary binal 23102019

		DELETE FROM #Notification WHERE Form_Name = 'TD_Home_ESS_267' --Delete In Time : binal 23102019
		
		
		
		--moved to P_HRMS_HOME_DASHBOARD_NOTIFICATIONS on 24102019
		--My Appraisal Notification
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_292')
		--	BEGIN							
		--		UPDATE	#Notification
		--		SET		Rec_Value = (SELECT Count(1) FROM V0090_hrms_appraisal_status_Report 
		--							WHERE	Emp_ID=@Emp_ID and Is_Accept=2 and Invoke_Emp=2 and ISNULL(Inspection_Status,0)=0),
		--				IsUpdated=1,
		--				Alias='Your Appraisal is invoked. Kindly fill detail to make it effective.'
		--		WHERE	Form_Name = 'TD_Home_ESS_292'
		--	END

		--Appraisal Notification for Team
		--IF EXISTS(SELECT 1 FROM #Notification WHERE Form_Name='TD_Home_ESS_293')
		--	BEGIN							
		--		UPDATE	#Notification
		--		SET		Rec_Value = (SELECT Count(1) FROM V0090_hrms_appraisal_status_Report 
		--							WHERE	Emp_ID=@Emp_ID and Is_Accept=2 and Invoke_Emp=2 and ISNULL(Inspection_Status,0)=0),
		--				IsUpdated=1,
		--				Alias='Your Team Member''s Appraisal invoked, You want to give any suggestion.'
		--		WHERE	Form_Name = 'TD_Home_ESS_293'
		--	END
		--end  24102019

		--Select * FROM #Notification N	

		Select distinct * FROM #Notification N	
		--where ( N.Form_Url='ess_surveyform.aspx' or N.Form_ID =9339 or  N.Form_Name ='TD_Home_ESS_345')
				
			
		/*
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
		*/
		--Where	IsUpdated=1
	END
