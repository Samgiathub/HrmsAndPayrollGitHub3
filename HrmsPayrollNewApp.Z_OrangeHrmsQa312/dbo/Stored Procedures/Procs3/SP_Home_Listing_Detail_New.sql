

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Home_Listing_Detail_New]   
   @Cmp_ID numeric(18,0),  
   @Branch_ID numeric(18,0)  ,
   @emp_id numeric(18,0)  
AS  

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Payroll_Module Numeric(5,0)
	Declare @HRMS_Module Numeric(5,0)

	Select @HRMS_Module = isnull(module_status,0) From T0011_module_detail WITH (NOLOCK) Where Cmp_id = @Cmp_ID and module_name = 'HRMS'
	Select @Payroll_Module = isnull(module_status,0) From T0011_module_detail WITH (NOLOCK) Where Cmp_id = @Cmp_ID and module_name = 'Payroll'

	if @Branch_ID is null  
		set @Branch_ID = 0  

	Declare @for_date varchar(50) 
		set @for_date = cast(getdate() as varchar(11))

	--PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP:1';
	-- For Payroll Provision
	if @Payroll_Module = 1 
		Begin
			if OBJECT_ID('tempdb..#Temp') is not null
				drop table #Temp

			create table #Temp 
			(  
				News varchar(5000),
			)  
	    
			Declare @News as varchar(5000)  
			Declare @News_Letter_ID numeric(18,0)  
			Declare @News_Title varchar(50)  
			Declare @News_Description varchar(1000)  
			set @News=''
		   
			SELECT	@News = COALESCE(@News + '','') + '<B>' + News_Title +'</B>' + ' : ' + News_Description + '                 '    
			FROM	dbo.T0040_NEWS_LETTER_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Start_Date <= Cast(Getdate() as varchar(11))
			And End_Date >= Cast(getdate() as varchar(11)) And Is_Visible=1 and Flag_T =isnull(0,1)  Order by News_Letter_ID 

			if @News <> ''  
				set @News = '<Marquee scrollamount=2   >' + @News + '</Marquee>' 
	
			Insert into #Temp
				select @News  
		    
			select * from #Temp
			
			if @HRMS_Module = 1 
				Begin
					EXEC GET_HRMS_TRAINING_DETAILS_HOME_PAGE @CMP_ID = @CMP_ID,@BRANCH_ID = @BRANCH_ID,@EMP_ID = @EMP_ID 
				End
			Else
				Begin
					SELECT  0 as TRAINING_APR_ID,'' as TRAINING_NAME, '' AS TRAINING_DATE,'' AS DESCRIPTION1 
					SELECT 0 as TRAINING_APR_ID,'' as TRAINING_NAME,'' AS DESCRIPTION1,'' as COMMENTS,'' as DEPT_NAME,'' AS TRAINING_DATE, '' AS LAST_DATE 
					SELECT '' as TRAINING_NAME, '' AS APR_STATUS_NAME
					SELECT 0 as TRAINING_ID,0 as EMP_ID,'' as TRAINING_NAME,'' as TRAINING_CODE,'' as TRAINING,'' AS TRAINING_DATE,'' AS 'Provider_Name','' AS TRAINING_END_DATE,0 as TRAINING_APR_ID
				End

			select 0 as training_apr_id 
	
			select 0 as Tran_feedback_ID 

			--hide other logic due to not getting any code for show details & Form detail is not available in Default form.
			select 0 as rows_id,0 as days_display ,'' as doc_title

			select count(request_id) as total_pending from dbo.V0090_Common_Request_Detail where emp_login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=0
			
			select top 2 request_id,request_type,case when cast(request_date as varchar(11))=cast(getdate() as varchar(11)) then  cast(DATEPART ( hh , request_date) as varchar(10)) + ':' + cast(DATEPART ( mi , request_date) as varchar(10))else cast(request_date as varchar(11))end as request_date,cast (request_detail as varchar(30)) as request_detail,case when isnull(emp_name1,'')='' then replace(login_name1,domain_name1,'') else emp_name1 end  as posted_by 
			from dbo.V0090_Common_Request_Detail where login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=0 order by newid(),request_date desc
			
			select count(request_id) as total_posted from V0090_Common_Request_Detail where login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=0
			
			select top 2 request_id,request_type,case when cast(request_date as varchar(11))=cast(getdate() as varchar(11)) then  cast(DATEPART ( hh , request_date) as varchar(10)) + ':' + cast(DATEPART ( mi , request_date) as varchar(10))else cast(request_date as varchar(11))end as request_date,cast(feedback_detail as varchar(30))as feedback_detail,case when isnull(emp_name,'')='' then replace(login_name,domain_name,'') else emp_name end as replied_by 
			from dbo.V0090_Common_Request_Detail where emp_login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=1 order by newid(),request_date desc
			
			select  count(request_id)as total_feedback from dbo.V0090_Common_Request_Detail where emp_login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=1

			if @HRMS_Module = 1 
				Begin
					declare @staus_re as int
					set @staus_re=0
			
					Create TABLE #Data
					(
						Interview_Process_detail_ID numeric(18,0)
						,Rec_Post_ID numeric(18,0)
						,Process_ID numeric(18,0)
						,Process_Name varchar(50)
						,Job_title varchar(100)
						,from_date datetime
						,to_date datetime
						,from_time varchar(50)
						,to_time varchar(50)
						,status int
					)
			
					set @staus_re=1
			
					insert into #Data(Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,from_time,to_time,status)
					Select IP.Interview_Process_detail_ID,IP.Rec_Post_ID,IP.Process_ID,Process_Name,Job_title,
						case when isnull(from_p_date,'') <> '' and from_p_date>from_date then from_p_date else from_date end as from_date,
						case when isnull(to_p_date,'')<>'' and to_p_date>to_date then to_p_date else to_date end to_date,from_time,to_time,@staus_re 
					 from dbo.v0055_Interview_Process_Detail IP
					left outer join  (select min(from_date) as from_p_date,max(to_date) as to_p_date,Interview_Process_detail_ID,rec_post_id 
						from dbo.t0055_HRMS_Interview_Schedule WITH (NOLOCK) where (s_emp_id=@emp_id or s_emp_id2=@emp_id or s_emp_id3=@emp_id or s_emp_id4=@emp_id)  
						group by Interview_Process_detail_ID,rec_post_id) Q 
					on Q.Interview_Process_detail_ID=IP.Interview_Process_detail_ID and Q.Rec_Post_ID=IP.Rec_Post_ID 
					where IP.cmp_id=@cmp_id and (IP.s_emp_id =@emp_id or IP.s_emp_id2 = @emp_id or IP.s_emp_id3 = @emp_id or IP.s_emp_id4 = @emp_id) 
					and (From_date>dateadd(dd,-3,@for_date) and From_date>@for_date)
			 					
					set @staus_re=0
							
					insert into #Data(Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,from_time,to_time,status)
					Select IP.Interview_Process_detail_ID,IP.Rec_Post_ID,IP.Process_ID,ip.Process_Name,ip.Job_title,case when isnull(from_p_date,'') <> '' and from_p_date>ip.from_date then from_p_date else ip.from_date end as from_date,case when isnull(to_p_date,'')<>'' and to_p_date>ip.to_date then to_p_date else ip.to_date end to_date,ip.from_time,ip.to_time,@staus_re 
					 from dbo.v0055_Interview_Process_Detail IP 
					left outer join  (select min(from_date) as from_p_date,max(to_date) as to_p_date,Interview_Process_detail_ID,rec_post_id 
					from dbo.t0055_HRMS_Interview_Schedule WITH (NOLOCK) where (s_emp_id=@emp_id or s_emp_id2=@emp_id or s_emp_id3=@emp_id or s_emp_id4=@emp_id)  group by Interview_Process_detail_ID,rec_post_id) Q 
					on Q.Interview_Process_detail_ID=IP.Interview_Process_detail_ID and Q.Rec_Post_ID=IP.Rec_Post_ID
					where IP.cmp_id=@cmp_id and (IP.s_emp_id =@emp_id or IP.s_emp_id2 = @emp_id or IP.s_emp_id3 = @emp_id or IP.s_emp_id4 = @emp_id)
					and (ip.From_Date > DATEADD(DD,-3,@for_date) and ip.From_Date >= @for_date or ip.To_Date = @for_date)
					and  not exists (select Rec_Post_ID from #Data where Rec_Post_ID=ip.Rec_Post_ID)
			
					select top 2 Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,from_time,to_time,status 
					from #Data
				End 
			Else
				Begin
					Select 0 as Interview_Process_detail_ID,0 as Rec_Post_ID,0 as Process_ID,'' as Process_Name,'' as Job_title,'' as from_date,'' as to_date,'' as from_time,'' as to_time,0  as status
				End 

			If exists(select Module_Id From dbo.T0011_module_detail WITH (NOLOCK) where Cmp_id=@Cmp_ID and module_name='Payroll' and Isnull(chg_pwd,0)=0)			
				begin
				Declare @Enable_Validation	As TinyInt
				Declare @Pass_Exp_Days		As Numeric(18,0)
				Declare @Reminder_Days		As Numeric(18,0)
				Declare @Effective_From_Date As Datetime
				Declare @Notice_Days		As Numeric(18,0)
				Set @Notice_Days = 0
				
				Select @Enable_Validation = Isnull(Enable_Validation,0), @Pass_Exp_Days = Isnull(Pass_Exp_Days,0), 
						@Reminder_Days = Isnull(Reminder_Days,0) From dbo.T0011_Password_Settings WITH (NOLOCK) Where Cmp_ID = @Cmp_ID
						
				If @Enable_Validation = 1 And @Pass_Exp_Days > 0
					Begin
						Select @Effective_From_Date = Isnull(Max(Effective_From_Date),'') From dbo.T0250_Change_Password_History WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
						
						If @Effective_From_Date = '1900-01-01 00:00:00.000'
						begin
								
								Select @Effective_From_Date  = System_Date From T0080_Emp_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @emp_id 
								
								if @Effective_From_Date IS NULL
									set @Effective_From_Date = '1900-01-01 00:00:00.000'
						end
						
						--Comment by Jaina 29-11-2016 
						--If DATEADD(dd, @Pass_Exp_Days - @Reminder_Days , @Effective_From_Date) <= Getdate()
						--Change by Jaina 29-11-2016 Start
						
						Declare @Expire_Date datetime
						declare @Notice_Date datetime
						
						set @Expire_Date = DATEADD(dd, @Pass_Exp_Days , @Effective_From_Date)
						
						If @Expire_Date <= getDate() or @Expire_Date >= getDate()
						Begin
						
							set @Notice_Date = DATEADD(dd, @Pass_Exp_Days - @Reminder_Days , @Effective_From_Date)
							--Set @Notice_Days = DATEDIFF(DAY, @Effective_From_Date, Getdate())
							
							 IF @Notice_Date <= getdate()
							--IF Convert(varchar(19),@Notice_Date,103) <= CONVERT(VARCHAR(19),GETDATE(),103)
							Begin
								
								Set @Notice_Days =ABS(DATEDIFF(DAY, @Expire_Date,GETDATE()))
								print @Notice_Days
								if @Notice_Days  >= 0
								begin
									Update dbo.T0080_Emp_Master Set Chg_Pwd = 0 Where Cmp_id = @Cmp_Id and Emp_ID = @Emp_Id
								end
							End
						
						End
						--Change by Jaina 29-11-2016 End											
					End				
				else
					Begin
						Select @Effective_From_Date = Isnull(Max(Effective_From_Date),'') From dbo.T0250_Change_Password_History WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
							if @Effective_From_Date <> '' 
								Update dbo.T0080_Emp_Master Set Chg_Pwd = 2 Where Cmp_id = @Cmp_Id and Emp_ID = @Emp_Id		 --Added By Gadriwala 10012013
					End
							
				select Isnull(Em.Chg_Pwd,0)Chg_Pwd, Md.module_status, @Notice_Days As Notice_Days ,DATEADD(dd, @Pass_Exp_Days , @Effective_From_Date) As Expire_Date   --Change By Jaina 29-11-2016
				From dbo.T0080_Emp_Master As Em WITH (NOLOCK)
				Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK) On Em.Cmp_id=Md.Cmp_Id 
				Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID 
					
			end
			ELSE	--- Added condition by Hardik 20/07/2015 to disable Change Password Popup on ESS side for Active Directory Login
				BEGIN
				select 2 as Chg_Pwd, Md.module_status, 0 As Notice_Days From dbo.T0080_Emp_Master As Em WITH (NOLOCK)
					Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK)
				On Em.Cmp_id=Md.Cmp_Id Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID and MD.module_name = 'Payroll' --and MD.module_name='HRMS'
			End	
			PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP:1';
			 DECLARE @ShowCurrMonth_Count NUMERIC
			 SET @ShowCurrMonth_Count = 0
			 
			 SELECT @ShowCurrMonth_Count = ISNULL(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Current Month Attendance Regularization Count On Home Page'
print @ShowCurrMonth_Count
			 IF @ShowCurrMonth_Count = 1
				BEGIN
					--If @emp_id =0
					--	Begin
					--		Select count(Emp_Id) as LateComer From View_Late_Emp 
					--		Where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL 
					--							where R_Emp_ID = @emp_id ) 
					--				And Chk_By_Superior=0 and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE())
					--	End
					--Else
					--	Begin
							exec dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0) and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE()) ',  1
					--  End
				END
			ELSE
				BEGIN
					--If @emp_id =0
					--	Begin
					--		Select count(Emp_Id) as LateComer From View_Late_Emp 
					--		Where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL 
					--							where R_Emp_ID = @emp_id ) 
					--				And Chk_By_Superior=0
					--	End
					--Else
					--	Begin
							exec dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0)',  1
					--	End
				END	
PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP:1';
return
			exec Get_Birthday_Anniversary_reminder @Cmp_ID,0

			-- if @emp_id =0 
			--	begin
			--		select count(Leave_Application_ID) as LeaveAppCnt from dbo.V0110_LEAVE_APPLICATION_DETAIL where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) 
			--		and (Application_Status = 'P' or Application_Status = 'F') 
			--	end
			--else
			--	begin
					exec dbo.SP_Get_Leave_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Application_Status = ''P'' or Application_Status = ''F'')',  1
			--	end

			--if @emp_id =0 
			--	begin
			--		Select COUNT(Row_ID) as LeaveCancel from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')
			--		and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 	
			--	end
			--else
			--	begin
					Select COUNT(Row_ID) as LeaveCancel from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')
					and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) 
					and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where is_approve = 0))
			--	end

			Declare @Dep_Reim_Days As Integer 
			Declare @is_all_emp_prob As Integer 
			Declare @ForDate As Datetime
		
			set @Dep_Reim_Days = 0
			set @is_all_emp_prob = 0
		
			select @Dep_Reim_Days=Dep_Reim_Days, @is_all_emp_prob=is_all_emp_prob, @ForDate = MAX(For_Date) From T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and 
					Branch_ID = @Branch_ID and For_Date <= GETDATE() Group By Gen_ID,Probation,Dep_Reim_Days,is_all_emp_prob
		
			Declare @Prob_Const NVARCHAR(MAX)
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

			exec SP_Get_Probation_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=@Prob_Const, @Type = 1

			SELECT	ISNULL(COUNT(Compoff_App_ID),0) As COMPOFF 
			From	V0110_COMPOFF_APPLICATION_DETAIL COMP
					INNER JOIN (SELECT	R1.EMP_ID, R_Emp_ID, R1.Effect_Date,R1.Cmp_ID 
								FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID
													FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) where Cmp_ID = @Cmp_ID
													GROUP BY Emp_ID
													) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date
								) R1 ON COMP.Emp_ID=R1.Emp_ID and COMP.Cmp_ID = R1.Cmp_ID
			Where	Application_Status='P' AND R1.R_Emp_ID=@emp_id

			--if @emp_id =0 
			--	begin
			--		select count(RC_APP_ID) as Reim_App 
			--		from V0100_RC_Application 
			--		where  APP_Status = 0  and  Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) 
			--			   and Submit_Flag=0	
			--	end
			--else
			--	begin
					exec SP_Get_RC_Application_Records @Cmp_ID=@Cmp_Id,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'(Status = ''Pending'' and Submit_Flag=0)',@type= 1
			--	end

			--If @emp_id =0	--Ankit 21052014
			--	Begin
			--		Select count(Loan_App_ID) as LoanAppCnt from V0100_LOAN_APPLICATION 
			--		where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) and (Loan_Status = 'N')
			--	End
			--Else
			--	Begin
					Exec SP_Get_Loan_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Loan_Status = ''N'')',  1
				--End

			--if @emp_id =0 
			--	begin
			--		select count(travel_Application_id) as travelAppCnt from V0100_TRAVEL_APPLICATION where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) and (Application_Status = 'P' or Application_Status = 'F') --
			--	end
			--else
			--	begin
					exec SP_Get_Travel_Application_Records @Cmp_ID,@Emp_ID,0,N'Application_Status = ''P''',1
			--	end

			--if @emp_id =0 
			--	begin
			--		select  count(travel_set_application_id) as travelSettlementAppCnt from V0140_Travel_Settlement_Application where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) and (Status = 'P' or Status = 'F')
			--	end
			--else
			--	begin
					exec SP_Get_Travel_Settlement_Application_Records @cmp_id ,@Emp_ID ,0 ,'(Status_New = ''P'')', 1
			--	end

			--If @emp_id =0	--Sumit 03022015
			--	Begin
			--		Select count(Claim_App_ID) as ClaimAppCnt from V0100_Claim_Application_New where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) and (Claim_App_Status = 'P' and Submit_Flag=0)
			--	End
			--Else
			--	Begin
					exec SP_Get_Claim_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Claim_App_Status = ''P'' and Submit_Flag=0)', 1
			--	End
			if @HRMS_Module = 1 
				Begin
					select distinct a.Training_id,e.Emp_ID,t.Training_name,isnull(a.Training_Code,a.Training_Apr_ID) Training_Code,
					(isnull(a.Training_Code,a.Training_Apr_ID) +' - '+t.Training_name)Training,Training_Date
					from dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL E WITH (NOLOCK)
						inner join dbo.V0120_HRMS_TRAINING_APPROVAL a on a.Training_Apr_ID= e.Training_Apr_ID
						inner join dbo.T0150_EMP_Training_INOUT_RECORD i WITH (NOLOCK) on i.emp_id = e.Emp_ID  and i.For_date = a.Training_Date
						left join  dbo.T0160_HRMS_Training_Questionnaire_Response ans WITH (NOLOCK) on ans.Emp_id=e.Emp_ID and ans.Training_Apr_ID=a.Training_Apr_ID
						inner join dbo.T0040_Hrms_Training_master t WITH (NOLOCK) on t.Training_id = a.Training_id
						cross join dbo.T0152_Hrms_Training_Quest_Final r WITH (NOLOCK) inner join T0150_HRMS_TRAINING_Questionnaire q WITH (NOLOCK) on q.Training_Que_ID = r.Training_Que_ID
					where e.Emp_ID = @emp_id  and (e.Emp_tran_status = 1 or e.Emp_tran_status=4) and Training_End_Date <= GETDATE()
						and i.Training_Apr_ID is not null and ans.Tran_Response_Id IS NULL
						and EXISTS (select Data from dbo.Split(q.Training_Id, '#') PB Where pb.Data=a.Training_id) and q.Questionniare_Type =1
					order by Training_id
				End
			Else
				Begin
					select distinct 0 as Training_id,0 as Emp_ID,'' as Training_name,'' as Training_Code,'' as Training,'' as Training_Date
				End

			--If @emp_id =0	
			--	Begin
			--		 select count(Request_id) as LoanAppCnt from V0090_Change_Request_Application where Emp_ID in (SELECT T0090_EMP_REPORTING_DETAIL.Emp_ID from T0090_EMP_REPORTING_DETAIL Where Effect_Date <= getdate() AND R_Emp_ID = @Emp_ID )and (Request_status='Pending')
			--	End
			--Else
			--	Begin
					 exec SP_Get_Change_Request_Records @Cmp_ID ,@Emp_ID ,0 ,'(Request_status=''Pending'')',  1
			--	End
			--Added By Jaina 23-11-2015	
	
					exec SP_Get_PreCompOff_Application_Records @Cmp_ID,@Emp_ID,0,'(App_Status = ''P'')',1
	
					exec SP_Get_Trainee_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@flag='Pending',@Rpt_level=0,@Constrains=@Prob_Const, @Type = 1
	
					exec SP_Get_GatePass_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'App_Status = ''P''', @Type = 1

					SELECT COUNT(APPROVAL_ID) AS APPROVAL_ID FROM T0300_EXIT_CLEARANCE_APPROVAL EA WITH (NOLOCK)
					INNER JOIN T0095_EXIT_CLEARANCE EC WITH (NOLOCK) ON EA.HOD_ID = EC.EMP_ID and EC.Dept_id = EA.Dept_Id
					inner JOIN T0200_Emp_ExitApplication E WITH (NOLOCK) on EA.Exit_ID =E.exit_id
					WHERE EA.NOC_STATUS='P' AND EA.HOD_ID = @EMP_ID AND EA.CMP_ID = @CMP_ID and E.sup_ack = 'P' 

					exec Get_Exit_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'1=1 and status = ''H''',@Type = 1	
	
					select isnull(COUNT(Op_Holiday_App_ID),0) as OPHolidayCount from V0100_Optional_Holiday_Application where Cmp_ID=@Cmp_ID and Op_Holiday_Status='P' and Emp_Superior=@emp_id

		End 

	 
	RETURN


