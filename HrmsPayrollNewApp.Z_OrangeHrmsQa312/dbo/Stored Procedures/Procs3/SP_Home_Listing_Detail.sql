

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Home_Listing_Detail]   
   @Cmp_ID numeric(18,0),  
   @Branch_ID numeric(18,0)  ,
   @emp_id numeric(18,0)  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	create table #Temp 
	(  
		Leave numeric(18,0),  
		Loan NUmeric(18,0),  
		Claim numeric(18,0),
		Tran_Pen numeric(18,0),
		Tran_Apr numeric(18,0), 
		Tran_Rej numeric(18,0),
		Rec_Sch numeric(18,0),
		News varchar(5000),
		travel numeric(18,0),
		travel_settlement numeric(18,0)
		--LateComer numeric(18,0) default 0  
	)  
    
  
	Declare @Loan as numeric(18,0)
	declare @row_id as numeric(18,0)   
	Declare @Claim as numeric(18,0)
	declare @Tran_Pen as numeric(18,0)
	Declare @Tran_Apr as numeric(18,0)
	Declare @Tran_Rej as numeric(18,0)
	Declare @Rec_Sch as numeric(18,0)   
	Declare @LateComer as numeric(18,0)
	Declare @Reim_count as numeric(18,0)
	--Declare @Leavecancel as numeric(18,0)
	Declare @travel as numeric(18,0)
	Declare @travel_settlement as numeric(18,0)
	
	
	
	set @travel = 0
	set @travel_settlement = 0
	
		Set @LateComer = 0
	
		Set @LateComer = 0
	  
		if @Branch_ID is null  
		 set @Branch_ID=0  

		 if @Branch_ID = 0  
		  BEgin  
		   
		   
		   insert into #Temp   
		   Select Count(Leave_Application_ID),0,0,0,0,0,0,'',0,0 from dbo.V0110_Leave_Application_Detail where Application_status='P' and cmp_ID=@Cmp_ID    
		   Select @Loan=Count(Loan_App_ID) from dbo.V0100_LOAN_APPLICATION where Loan_status='N' and cmp_ID=@Cmp_ID    
		   Select @Claim=Count(claim_App_ID) from dbo.V0100_Claim_Application_New where Claim_App_Status='P' and cmp_ID=@Cmp_ID and Submit_Flag=0
		   		  
		    Select @Reim_count= COUNT(Rc_App_ID)  From dbo.V0100_RC_Application Where Cmp_ID = @Cmp_ID and APP_Status=0 and Submit_Flag=0
					
		   select @Tran_Pen=0,@Tran_Apr=0,@Tran_Rej=0
		   Select @travel = Count(travel_Application_ID) from dbo.V0100_TRAVEL_APPLICATION where Application_status='P' and cmp_ID=@Cmp_ID    
		   select @travel_settlement = count(travel_set_application_id) from dbo.V0140_Travel_Settlement_Application where status='P' and cmp_ID=@Cmp_ID    
		   
		   
		   --Select @Leavecancel = COUNT(Row_ID) from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R') and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 
		   --Select @LateComer=count(Emp_Id) From View_Late_Emp Where cmp_ID=@Cmp_ID And Emp_Superior=@emp_id	Group By Emp_Id--Modified By nikunj 04-06-2011
		   /*select @Tran_Pen=count(dbo.V0100_Training_Application.Training_App_id)  from v0100_Training_Application inner join T0110_Training_Application_Detail on
			dbo.V0100_Training_Application.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.V0100_Training_Application.cmp_id = @Cmp_ID and dbo.V0100_Training_Application.App_Status = 'N'
		   select @Tran_Apr=count(Training_Apr_id) from V0130_hrms_Traininig_Feedback_Super_Details where cmp_id = @cmp_id and Apr_Status = 'A'   
		   select @Tran_Rej= count(dbo.v0120_Training_Approval.Training_App_id)  from v0120_Training_Approval inner join T0110_Training_Application_Detail on
			dbo.v0120_Training_Approval.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.v0120_Training_Approval.cmp_id = @cmp_id and dbo.v0120_Training_Approval.Apr_Status = 'R'
		   select @Rec_Sch=count(distinct(resume_id)) from T0055_hrms_interview_schedule where cmp_id = @cmp_id	*/
		  end  
		 else  
		  BEgin  
		  
		  insert into #Temp   
		   Select Count(Leave_Application_ID),0,0,0,0,0,0,'',0,0 from dbo.V0110_Leave_Application_Detail where Application_status='P' and cmp_ID=@Cmp_ID  and Branch_ID=@Branch_ID   
		  
		   
		   Select @Loan=Count(Loan_App_ID) from dbo.V0100_LOAN_APPLICATION where Loan_status='N' and cmp_ID=@Cmp_ID  and Branch_ID=@Branch_ID  

		   Select @Claim=Count(claim_App_ID) from dbo.V0100_Claim_Application_New where Claim_App_Status='P' and cmp_ID=@Cmp_ID  and Branch_ID=@Branch_ID and Submit_Flag=0

			Select @Reim_count= COUNT(Rc_App_ID)  From dbo.V0100_RC_Application Where Cmp_ID = @Cmp_ID and APP_Status=0 and Branch_ID=@Branch_ID and Submit_Flag=0
			
		    select @Tran_Pen=0,@Tran_Apr=0,@Tran_Rej=0
		     Select @travel = Count(travel_Application_ID) from dbo.V0100_TRAVEL_APPLICATION where Application_status='P' and cmp_ID=@Cmp_ID  and Branch_ID=@Branch_ID
		   select @travel_settlement = count(travel_set_application_id) from dbo.V0140_Travel_Settlement_Application where status='P' and cmp_ID=@Cmp_ID and Branch_ID=@Branch_ID  
		  
		    --Select @Leavecancel = COUNT(Row_ID) from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R') and Branch_ID=@Branch_ID and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 
		    --Select @LateComer=count(Emp_Id) From View_Late_Emp Where cmp_ID=@Cmp_ID And Emp_Superior=@emp_id And Branch_ID=@Branch_ID Group By Emp_Id--Modified By nikunj 04-06-2011
		  /* select @Tran_Pen=count(dbo.V0100_Training_Application.Training_App_id)  from v0100_Training_Application inner join T0110_Training_Application_Detail on
			dbo.V0100_Training_Application.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.V0100_Training_Application.cmp_id = @Cmp_ID and dbo.V0100_Training_Application.App_Status = 'N' and branch_id = @Branch_ID
		   select @Tran_Apr=count(Training_Apr_id) from V0130_hrms_Traininig_Feedback_Super_Details where cmp_id = @cmp_id and Apr_Status = 'A' and branch_id = @branch_id
		   select @Tran_Rej= count(dbo.v0120_Training_Approval.Training_App_id)  from v0120_Training_Approval inner join T0110_Training_Application_Detail on
			dbo.v0120_Training_Approval.Training_App_id = T0110_Training_Application_Detail.Training_App_id
			inner join dbo.T0080_Emp_Master on
			dbo.T0110_Training_Application_Detail.Emp_id = dbo.T0080_Emp_Master.Emp_id
			where dbo.v0120_Training_Approval.cmp_id = @cmp_id and dbo.v0120_Training_Approval.Apr_Status = 'R'and branch_id = @branch_id
		   select @Rec_Sch=count(distinct(resume_id)) from T0055_hrms_interview_schedule where cmp_id = @cmp_id	*/
		  End 		  
	    
		   Declare @News as varchar(5000)  
		   Declare @News_Letter_ID numeric(18,0)  
		   Declare @News_Title varchar(50)  
		   Declare @News_Description varchar(1000)  
		   set @News=''  
		  
		   --select * from T0040_NEWS_LETTER_MASTER where Cmp_ID=@Cmp_ID And Start_Date <= Getdate() And End_Date >= getdate() And Is_Visible=1  
		   
		  
		   
		   /*Commented by Nimesh (Used Coalesce statement instead of loop)  
			PRINT CONVERT(VARCHAR(20), GETDATE(), 114) + ' STEP:1';
			Declare Cur_News cursor for         
			select News_Letter_ID,News_Title,News_Description  from  dbo.T0040_NEWS_LETTER_MASTER where Cmp_ID=@Cmp_ID And Start_Date <= Getdate() And End_Date >= getdate() And Is_Visible=1 and Flag_T =isnull(0,1)  Order by News_Letter_ID   
			open Cur_News        
			fetch next from Cur_News into  @News_Letter_ID,@News_Title,@News_Description  
			While @@Fetch_Status=0        
				begin        		       
					set @News = @News +'<B>' + @News_Title +'</B>' + ' : ' + @News_Description + '                 '  
		       
					fetch next from Cur_News into  @News_Letter_ID,@News_Title,@News_Description  
				end        
			close Cur_News        
			Deallocate Cur_News    
			*/
			
			SELECT	@News = COALESCE(@News + '','') + '<B>' + News_Title +'</B>' + ' : ' + News_Description + '                 '    
			FROM	dbo.T0040_NEWS_LETTER_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID And Start_Date <= Cast(Getdate() as varchar(11))
					And End_Date >= Cast(getdate() as varchar(11)) And Is_Visible=1 and Flag_T =isnull(0,1)  
					AND 1 = Case When CHARINDEX('#'+Cast(@BRANCH_ID as varchar(10)) +'#' ,'#'+  Isnull(Branch_Wise_News_Announ,@BRANCH_ID) +'#')  > 0 Then 1 Else 0 END
					Order by News_Letter_ID 
					
			if @News <> ''  
				set @News = '<Marquee scrollamount=2   >' + @News + '</Marquee>'     
				
			Update #Temp set News=@News, Loan=@Loan,Claim=@Claim,Tran_Pen=@Tran_Pen,Tran_Apr=@Tran_Apr,Tran_Rej=@Tran_Rej,Rec_Sch=@Rec_Sch,travel=@travel,travel_settlement=@travel_settlement
		    
			select * from #Temp 
			 
			
			 --ADDED BY GADRIWALA MUSLIM 15112016 --  ALL HRMS TRAING NOTIFICATION DETAILS SET IN THIS NEW STORE PROCEDURE
			EXEC GET_HRMS_TRAINING_DETAILS_HOME_PAGE @CMP_ID = @CMP_ID,@BRANCH_ID = @BRANCH_ID,@EMP_ID = @EMP_ID 
		
		
			declare @for_date varchar(50) 
			set @for_date= cast(getdate() as varchar(11))
		   
			select 0 as training_apr_id 
	
			select 0 as Tran_feedback_ID --added on 7 dec 2015 sneha
			

		  -- employee history detail 
				declare @doc_title as varchar(50)
				set @doc_title=''
				declare @total_pending as numeric(18,0)
				declare @total_approved as numeric(18,0)
				select @Branch_ID=branch_id from dbo.v0080_employee_master where cmp_id=@cmp_id and emp_id=@emp_id
				if @Branch_ID=0
				set @Branch_ID=null
				
				select  @total_pending= count(Emp_doc_ID) from dbo.v0090_EMP_HR_DOC_Detail 
				where ((emp_id=@emp_id and accetpeted=0)) and (branch_id=isnull(@branch_id,branch_id) or isnull(branch_id,0)=0)

				select  @total_approved= count(Emp_doc_ID) from dbo.v0090_EMP_HR_DOC_Detail 
				where ((emp_id=@emp_id and accetpeted<>0 and @for_date<DATEADD(dd,3,accepted_date)) 
				or  (isnull(emp_id,0)=0)and @for_date<DATEADD(dd,3,accepted_date)) and (branch_id=isnull(@branch_id,branch_id) or isnull(branch_id,0)=0) 

				if isnull(@total_pending,0)=1
					select  @doc_title=doc_title from dbo.v0090_EMP_HR_DOC_Detail where ((emp_id=@emp_id and accetpeted=0)) and (branch_id=isnull(@branch_id,branch_id) or isnull(branch_id,0)=0) 
				else if isnull(@total_pending,0)=0
					select  @doc_title=doc_title from dbo.v0090_EMP_HR_DOC_Detail where ((emp_id=@emp_id and accetpeted<>0 and @for_date<DATEADD(dd,3,accepted_date)) or (isnull(emp_id,0)=0)and @for_date<DATEADD(dd,3,accepted_date)) and (branch_id=isnull(@branch_id,branch_id) or isnull(branch_id,0)=0) 


				select @row_id = count(row_id) from dbo.T0011_Login_History WITH (NOLOCK) where login_id in (select login_id from dbo.t0011_login WITH (NOLOCK) where emp_id=@emp_id and cmp_id=@cmp_id) 

		        select @row_id as rows_id,isnull(@total_pending,0)  + isnull(@total_approved,0) as days_display ,@doc_title as doc_title
		        
			 -- for common request 06-oct-2010
			select count(request_id) as total_pending from dbo.V0090_Common_Request_Detail where emp_login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=0
			
			select top 2 request_id,request_type,case when cast(request_date as varchar(11))=cast(getdate() as varchar(11)) then  cast(DATEPART ( hh , request_date) as varchar(10)) + ':' + cast(DATEPART ( mi , request_date) as varchar(10))else cast(request_date as varchar(11))end as request_date,cast (request_detail as varchar(30)) as request_detail,case when isnull(emp_name1,'')='' then replace(login_name1,domain_name1,'') else emp_name1 end  as posted_by 
			from dbo.V0090_Common_Request_Detail where login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=0 order by newid(),request_date desc
			
			select count(request_id) as total_posted from V0090_Common_Request_Detail where login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=0
			
			select top 2 request_id,request_type,case when cast(request_date as varchar(11))=cast(getdate() as varchar(11)) then  cast(DATEPART ( hh , request_date) as varchar(10)) + ':' + cast(DATEPART ( mi , request_date) as varchar(10))else cast(request_date as varchar(11))end as request_date,cast(feedback_detail as varchar(30))as feedback_detail,case when isnull(emp_name,'')='' then replace(login_name,domain_name,'') else emp_name end  as replied_by 
			from dbo.V0090_Common_Request_Detail where emp_login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=1 order by newid(),request_date desc
			
			select  count(request_id)as total_feedback from dbo.V0090_Common_Request_Detail where emp_login_id=(select login_id from t0011_login WITH (NOLOCK) where emp_id=@emp_id) and status=1
			 		
			
			--For Recruitment alert
			declare @staus_re as int
			set @staus_re=0
			--declare @data table
			Create TABLE #Data
			(
				Interview_Process_detail_ID numeric(18,0)
				,Rec_Post_ID numeric(18,0)
				,Process_ID numeric(18,0)
				,Process_Name varchar(50)
				,Job_title varchar(100)
				,from_date datetime
				,to_date datetime
				,noofInterviews INT
				--,from_time varchar(50)
				--,to_time varchar(50)
				,status int
			)
			--CREATE NONCLUSTERED INDEX IX_Data_Interview_Process_detail_ID_Rec_Post_ID_Process_ID on #Data (Interview_Process_detail_ID,Rec_Post_ID,Process_ID)
			
			SET @staus_re=1
			---added on 03/11/2017--(start)
			INSERT INTO #Data(Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,noofInterviews,status)
			SELECT IPS2.Interview_Process_Detail_Id,IPS2.Rec_Post_Id,V.Process_ID,V.Process_Name,V.Job_title
				  ,IPS2.fdate,IPS2.tdate,IPS2.cnt,@staus_re --,IPS.From_Date,IPS.To_Date,IPS.From_Time,IPS.To_Time,0
			FROM V0055_Interview_Process_Detail V 
			INNER JOIN (
							SELECT min(From_Date)fdate,max(To_Date)tdate,count(1)cnt,Interview_Process_Detail_Id,Rec_Post_Id
							FROM   T0055_HRMS_Interview_Schedule WITH (NOLOCK)
							WHERE Cmp_Id = @cmp_id AND Rating is NULL 
								  AND (S_Emp_Id = @emp_id OR S_Emp_Id2 = @emp_id
								  OR S_Emp_Id3 = @emp_id OR S_Emp_ID4 = @emp_id)
								  AND (From_Date > DATEADD(dd,-3,@for_date) and From_Date>=@for_date)
								  AND From_Time <> '0'
							GROUP BY Interview_Process_Detail_Id,Rec_Post_Id
						)IPS2 ON IPS2.Interview_Process_Detail_Id = V.Interview_Process_detail_ID and IPS2.Rec_Post_Id = V.Rec_Post_ID
			WHERE V.Cmp_ID = @cmp_id  
			ORDER BY IPS2.fdate
			
			SELECT Interview_Process_detail_ID,Rec_Post_ID,Process_ID,Process_Name,Job_title,from_date,to_date,noofInterviews,status 
			FROM #Data
			---added on 03/11/2017--(end)
			
			If exists(select Module_Id From dbo.T0011_module_detail WITH (NOLOCK) where Cmp_id=@Cmp_ID and module_name='Payroll' and Isnull(chg_pwd,0)=0)			
			begin
				--Added By Hiral 04 June, 2013 For Password Expiry (Start)
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
						--If Convert(varchar(25),@Effective_From_Date,121) = '1900-01-01 00:00:00.000'
						begin
								--Select System_Date From T0080_Emp_Master Where Cmp_ID = @Cmp_ID And Emp_ID = @emp_id -- Changed By Gadriwala 10012014
								Select @Effective_From_Date  = System_Date From T0080_Emp_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_ID = @emp_id -- Changed By Gadriwala 10012014
								--select @Effective_From_Date
								if @Effective_From_Date IS NULL
									set @Effective_From_Date = '1900-01-01 00:00:00.000'
								
								 
						end
						
						--Comment by Jaina 29-11-2016 
						--If DATEADD(dd, @Pass_Exp_Days - @Reminder_Days , @Effective_From_Date) <= Getdate()
						--Change by Jaina 29-11-2016 Start
						
						Declare @Expire_Date datetime
						declare @Notice_Date datetime
						--select @Effective_From_Date
						set @Expire_Date = DATEADD(dd, @Pass_Exp_Days , @Effective_From_Date)
						
						If @Expire_Date <= getDate() or @Expire_Date >= getDate()
						Begin
						
							set @Notice_Date = DATEADD(dd, @Pass_Exp_Days - @Reminder_Days , @Effective_From_Date)
							--Set @Notice_Days = DATEDIFF(DAY, @Effective_From_Date, Getdate())
							
							 IF @Notice_Date <= getdate()
							--IF Convert(varchar(19),@Notice_Date,103) <= CONVERT(VARCHAR(19),GETDATE(),103)
							Begin
								
								Set @Notice_Days =ABS(DATEDIFF(DAY, @Expire_Date,GETDATE()))
								
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
							
				select Isnull(Em.Chg_Pwd,0)Chg_Pwd, Md.module_status, @Notice_Days As Notice_Days ,DATEADD(dd, @Pass_Exp_Days , @Effective_From_Date) As Expire_Date,@Pass_Exp_Days As Pass_Exp_Days   --Change By Jaina 29-11-2016
				From dbo.T0080_Emp_Master As Em WITH (NOLOCK)
				Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK) On Em.Cmp_id=Md.Cmp_Id 
				Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID 		
				
				--Added By Hiral 04 June, 2013 For Password Expiry (End)
				
				----Commented By Hiral 04 June, 2013 (To Add One More Column)	
				--select Isnull(Em.Chg_Pwd,0)Chg_Pwd, Md.module_status From T0080_Emp_Master As Em Inner Join T0011_Module_Detail As MD 
				--On Em.Cmp_id=Md.Cmp_Id Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID				
			end
		ELSE	--- Added condition by Hardik 20/07/2015 to disable Change Password Popup on ESS side for Active Directory Login
			BEGIN
				select 2 as Chg_Pwd, Md.module_status, 0 As Notice_Days From dbo.T0080_Emp_Master As Em  WITH (NOLOCK)
					Inner Join dbo.T0011_Module_Detail As MD WITH (NOLOCK)
				On Em.Cmp_id=Md.Cmp_Id Where Em.emp_Id=@emp_id And EM.Cmp_Id=@Cmp_ID and MD.module_name = 'Payroll' --and MD.module_name='HRMS'
			End			
	
			
			-----Ankit 29012015
			 DECLARE @ShowCurrMonth_Count NUMERIC
			 SET @ShowCurrMonth_Count = 0
			 
			 SELECT @ShowCurrMonth_Count = ISNULL(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Current Month Attendance Regularization Count On Home Page'
			
			 -----Ankit 29012015
			
			IF @ShowCurrMonth_Count = 1
				BEGIN
					If @emp_id =0
						Begin
							Select count(Emp_Id) as LateComer From View_Late_Emp 
							Where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
												where R_Emp_ID = @emp_id ) 
									And Chk_By_Superior=0 and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE())
						End
					Else
						Begin
							exec dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0) and month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE()) ',  1
						End
				END
			ELSE
				BEGIN
					If @emp_id =0
						Begin
							Select count(Emp_Id) as LateComer From View_Late_Emp 
							Where Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK)
												where R_Emp_ID = @emp_id ) 
									And Chk_By_Superior=0
						End
					Else
						Begin

							exec dbo.SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS @Cmp_ID ,@Emp_ID ,0 ,'(Chk_By_Superior = 0)',  1
			
						End
				END	
			--Ankit 16062014

		--- By Alpesh on 10-Jun-2011 for Birthday
		exec Get_Birthday_Anniversary_reminder @Cmp_ID,0 --Mukti(11042016)
		

	 if @emp_id =0 
		begin
			select	count(Leave_Application_ID) as LeaveAppCnt from dbo.V0110_LEAVE_APPLICATION_DETAIL 
			where	Emp_ID in (select Emp_ID from dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) 
					and (Application_Status = 'P' or Application_Status = 'F') --
		end
	else
		begin
			--select count(Leave_Application_ID) as LeaveAppCnt from V0110_LEAVE_APPLICATION_DETAIL where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) and (Application_Status = 'P' ) --or Application_Status = 'F'
			--changed by mitesh on 14122013
			exec dbo.SP_Get_Leave_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Application_Status = ''P'' or Application_Status = ''F'')',  1
		end
		
			
		if @emp_id =0 
			begin
				Select	COUNT(Row_ID) as LeaveCancel 
				from	V0120_LEAVE_APPROVAL 
				where	(Approval_Status = 'A' or Approval_Status='R')
						and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 	
			end
	   else
			begin
			
				Select COUNT(Row_ID) as LeaveCancel from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')
				and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) 
				and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION WITH (NOLOCK) where is_approve = 0))
			end
	
	
  
	  --Select COUNT(Row_ID) as LeaveCancel from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R') and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 		
	  --Select COUNT(Row_ID) as LeaveCancel from V0120_LEAVE_APPROVAL where (Approval_Status = 'A' or Approval_Status='R')
		 --and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) 
		 --and (leave_approval_id in (select distinct Leave_Approval_id from T0150_LEAVE_CANCELLATION where Cmp_Id = @Cmp_ID and is_approve = 0)) and Cmp_ID = @Cmp_ID 	
		 
	 -- Hiral Probation Finishing Within Reminder Days (Start)
		Declare @Dep_Reim_Days As Integer 
		Declare @is_all_emp_prob As Integer 
		Declare @ForDate As Datetime
		
		set @Dep_Reim_Days = 0
		set @is_all_emp_prob = 0
		
		select @Dep_Reim_Days=Dep_Reim_Days, @is_all_emp_prob=is_all_emp_prob, @ForDate = MAX(For_Date) From T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and 
				Branch_ID = @Branch_ID and For_Date <= GETDATE() Group By Gen_ID,Probation,Dep_Reim_Days,is_all_emp_prob
		
		Declare @Prob_Const NVARCHAR(MAX)	--Ankit 21012016
		If @Dep_Reim_Days = 0 
			set @Dep_Reim_Days = 30
			
		If @is_all_emp_prob = 0
			Begin
				set @Prob_Const = N'0=0 and (( probation_date >= GETDATE() and probation_date <= DATEADD(DD,' + cast (@Dep_Reim_Days AS NVARCHAR(MAX)) + ' ,GETDATE() )) or probation_date <= GETDATE() )' 
				--select count(Emp_ID) as Pro_OverCnt from V0080_EMP_PROBATION_GET where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id )
				--and probation_date >= GETDATE() and probation_date <= DATEADD(DD,@Dep_Reim_Days,GETDATE())
			End
		Else If @is_all_emp_prob = 1
			Begin
				set @Prob_Const = N'0=0 and probation_date <= GETDATE()' 
				--select count(Emp_ID) as Pro_OverCnt from V0080_EMP_PROBATION_GET where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id )
				--and probation_date >= GETDATE()
			End
		
			
		
		exec SP_Get_Probation_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=@Prob_Const, @Type = 1
		

	  
		--Added by Jaina 25-04-2017 	
		--IF EXISTS( SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WHERE CMP_ID = @CMP_ID AND (CONVERT(varchar(11),from_date,120)) = convert(varchar(11),GETDATE(),120) and  convert(varchar(11),to_date,120) >= convert(varchar(11),GETDATE(),120))
		IF EXISTS( SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND (CONVERT(varchar(11),from_date,120)) = convert(varchar(11),GETDATE(),120) and  convert(varchar(11),to_date,120) >= convert(varchar(11),GETDATE(),120) AND Pass_To_Emp_id=@EMP_ID AND Type='Comp off')
			BEGIN								
			  SELECT COUNT(V.Compoff_App_ID) As COMPOFF 
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
			BEgin
				
				SELECT	ISNULL(COUNT(Compoff_App_ID),0) As COMPOFF 
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
		  -----------
	  
	
	  if @emp_id =0 
		begin
			select count(RC_APP_ID) as Reim_App 
			from V0100_RC_Application 
			where  APP_Status = 0  and  Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) 
				   and Submit_Flag=0	
		end
	 else
		begin
			--select count(RC_APP_ID) as Reim_App from V0100_RC_Application 
			--where  APP_Status = 0  and Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @emp_id ) 
			--Ankit 26062014
			exec SP_Get_RC_Application_Records @Cmp_ID=@Cmp_Id,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'(Status = ''Pending'' and Submit_Flag=0)',@type= 1
		end 
	
	
	
	If @emp_id =0	--Ankit 21052014
		Begin
			Select count(Loan_App_ID) as LoanAppCnt from V0100_LOAN_APPLICATION 
			where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Loan_Status = 'N')
		End
	Else
		Begin
			Exec SP_Get_Loan_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Loan_Status = ''N'')',  1			
		End
		
	if @emp_id =0 
		begin
			select count(travel_Application_id) as travelAppCnt from V0100_TRAVEL_APPLICATION where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Application_Status = 'P' or Application_Status = 'F') --
		end
	else
		begin
			exec SP_Get_Travel_Application_Records @Cmp_ID,@Emp_ID,0,N'Application_Status = ''P''',1
		end

			
	
	if @emp_id =0 
		begin
			select  count(travel_set_application_id) as travelSettlementAppCnt from V0140_Travel_Settlement_Application where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Status = 'P' or Status = 'F') --
		end
	else
		begin
			
			exec SP_Get_Travel_Settlement_Application_Records @cmp_id ,@Emp_ID ,0 ,'(Status_New = ''P'')', 1			
		end
		
	
	If @emp_id =0	--Sumit 03022015
		Begin
			Select count(Claim_App_ID) as ClaimAppCnt from V0100_Claim_Application_New where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where R_Emp_ID = @emp_id ) and (Claim_App_Status = 'P' and Submit_Flag=0)
		End
	Else
		Begin
			
			exec SP_Get_Claim_Application_Records @Cmp_ID ,@Emp_ID ,0 ,'(Claim_App_Status = ''P'' and Submit_Flag=0)', 1			
		End
	
	
	--added by sneha on 08 Aug 2015
		select distinct a.Training_id,e.Emp_ID,t.Training_name,isnull(a.Training_Code,a.Training_Apr_ID) Training_Code,
		(isnull(a.Training_Code,a.Training_Apr_ID) +' - '+t.Training_name)Training,Training_Date
		from dbo.T0130_HRMS_TRAINING_EMPLOYEE_DETAIL E WITH (NOLOCK)
			inner join dbo.V0120_HRMS_TRAINING_APPROVAL a on a.Training_Apr_ID= e.Training_Apr_ID
			inner join dbo.T0150_EMP_Training_INOUT_RECORD i WITH (NOLOCK) on i.emp_id = e.Emp_ID  and i.For_date = a.Training_Date
			left join  dbo.T0160_HRMS_Training_Questionnaire_Response ans WITH (NOLOCK) on ans.Emp_id=e.Emp_ID and ans.Training_Apr_ID=a.Training_Apr_ID
			inner join dbo.T0040_Hrms_Training_master t WITH (NOLOCK) on t.Training_id = a.Training_id
			cross join dbo.T0152_Hrms_Training_Quest_Final r WITH (NOLOCK) inner join T0150_HRMS_TRAINING_Questionnaire q WITH (NOLOCK) on q.Training_Que_ID = r.Training_Que_ID 
			--left outer join (
			--		select emp_id,Training_Apr_ID from dbo.T0160_HRMS_Training_Questionnaire_Response where  cmp_id=@Cmp_ID
			--	) as es on es.Training_Apr_ID=a.Training_Apr_ID and es.emp_id <> e.Emp_ID
		where e.Emp_ID = @emp_id  and (e.Emp_tran_status = 1 or e.Emp_tran_status=4) and Training_End_Date <= GETDATE()
			and i.Training_Apr_ID is not null and ans.Tran_Response_Id IS NULL --Modified by Nimesh on 18-Dec-2015 (Removed NOT EXISTS CONDITION and ADDED LEFT JOIN)
			--and not EXISTS(select 1 from T0160_HRMS_Training_Questionnaire_Response  where emp_id = e.Emp_ID and Training_Apr_ID =a.Training_Apr_ID )
			--and e.Emp_ID not in (select emp_id from dbo.T0160_HRMS_Training_Questionnaire_Response where Training_Apr_ID=a.Training_Apr_ID and cmp_id=@Cmp_ID)
			and EXISTS (select Data from dbo.Split(q.Training_Id, '#') PB Where pb.Data=a.Training_id) and q.Questionniare_Type =1
		order by Training_id
		--end by sneha on 08 Aug 2015	 
	
	
		--Added By Jaina 28-10-2015 Start
	If @emp_id =0	
		Begin						
			--select count(Request_id) as ChangeRequest from V0090_Change_Request_Application where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL where R_Emp_ID = @Emp_ID ) and (Request_status='Pending')
			 select count(Request_id) as LoanAppCnt from V0090_Change_Request_Application where Emp_ID in (SELECT T0090_EMP_REPORTING_DETAIL.Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) Where Effect_Date <= getdate() AND R_Emp_ID = @Emp_ID )and (Request_status='Pending')
		End
	Else
		Begin			
			 exec SP_Get_Change_Request_Records @Cmp_ID ,@Emp_ID ,0 ,'(Request_status=''Pending'')',  1
		End
	--Added By Jaina 28-10-2015 End
		
	
	  
	--Added By Jaina 23-11-2015	
	--SELECT ISNULL(COUNT(PreCompOff_App_ID),0) AS PRECOMPOFF FROM V0110_PrecompOff_Application WHERE App_Status='P' AND Emp_ID in (SELECT T0090_EMP_REPORTING_DETAIL.Emp_ID from T0090_EMP_REPORTING_DETAIL Where Effect_Date <= getdate() AND R_Emp_ID = @Emp_ID )
	exec SP_Get_PreCompOff_Application_Records @Cmp_ID,@Emp_ID,0,'(App_Status = ''P'')',1
	
	--Trainee Over Employee count --Ankit 10022016
	
	exec SP_Get_Trainee_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=@Prob_Const, @Type = 1
	
	--GatePass Application Count  - Datatable Number -30  --Ankit 060602016
	exec SP_Get_GatePass_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'App_Status = ''P''', @Type = 1
	
	
	--Added By Jaina 04-06-2016 (Exit Clearance Detail)
	DECLARE @Show_clearance NUMERIC
	declare @Setting_CostCenter numeric
	declare @Reminderday numeric
	
	SET @Show_clearance = 0
	set @Setting_CostCenter = 0
	set @Reminderday  = 0
			 
	SELECT @Show_clearance = IsNull(Setting_Value,0) FROM dbo.T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Setting_Name='Exit Clearance Require'
	select @Setting_CostCenter = Setting_Value from T0040_SETTING WITH (NOLOCK) where cmp_id=@Cmp_ID and setting_name='Enable Exit Clearance Process Cost Center Wise'
	Select @Reminderday = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Setting_Name ='Reminder Days for Exit Clearance Cost Center Wise'	
	
	if @Setting_CostCenter = 1  --Added by Jaina 07-09-2018
		begin
			SELECT	COUNT(APPROVAL_ID) AS APPROVAL_ID 
			FROM	T0300_EXIT_CLEARANCE_APPROVAL EA WITH (NOLOCK)
					INNER JOIN T0095_EXIT_CLEARANCE EC WITH (NOLOCK) ON EA.HOD_ID = EC.EMP_ID AND (EC.Center_ID =EA.Center_ID)
					INNER JOIN T0200_Emp_ExitApplication E WITH (NOLOCK) ON EA.Exit_ID =E.exit_id
			WHERE	EA.NOC_STATUS='P' AND EA.HOD_ID = @Emp_ID AND EA.CMP_ID = @CMP_ID AND E.sup_ack = 'P' 
			and (GETDATE() BETWEEN DateAdd(DAY,@Reminderday,last_date) AND (last_date+1)or GETDATE() >= last_date)
		end
	else
		BEGIN
			SELECT	COUNT(APPROVAL_ID) AS APPROVAL_ID 
			FROM	T0300_EXIT_CLEARANCE_APPROVAL EA WITH (NOLOCK)
					INNER JOIN T0095_EXIT_CLEARANCE EC WITH (NOLOCK) ON EA.HOD_ID = EC.EMP_ID AND (EC.Dept_id = EA.Dept_Id)
					INNER JOIN T0200_Emp_ExitApplication E WITH (NOLOCK) ON EA.Exit_ID =E.exit_id
			WHERE	EA.NOC_STATUS='P' AND EA.HOD_ID = @Emp_ID AND EA.CMP_ID = @CMP_ID AND E.sup_ack = 'P' 
		END
		
	
		
	--Added By Jaina 14-06-2016
	exec Get_Exit_Application_Records @Cmp_ID=@Cmp_ID,@Emp_ID=@emp_id,@Rpt_level=0,@Constrains=N'1=1 and status = ''H''',@Type = 1	
	
	--Added by Sumit on 03102016
	select isnull(COUNT(Op_Holiday_App_ID),0) as OPHolidayCount 
	from V0100_Optional_Holiday_Application 
	--where Cmp_ID=@Cmp_ID and Op_Holiday_Status='P' and Emp_Superior=@emp_id
	WHERE	Op_Holiday_Status='P' AND Emp_Superior=@Emp_ID and Emp_Left <> 'Y'   --Added by Jaina 30-10-2018 ( Cross company issue)
	
	--Added By Jimit 07082018
	DECLARE	@FROMDATE AS DATETIME
	DECLARE	@ToDATE AS DATETIME
	--SET		@FROMDATE = COnvert(datetime,(Convert(Varchar(4),YEAR(GETDATE())) + '-' + Convert(Varchar(4),(MONTH(GETDATE()) -1)) + '-' + '01')) 
	SET		@FROMDATE =DATEADD(MONTH, DATEDIFF(MONTH, 0, Getdate())-1, 0)
	SET		@ToDATE = GETDATE()

	--EXEC SP_Get_OT_Level_Approval_Records @Cmp_ID=@Cmp_ID,@Emp_ID=0,@R_Emp_ID = @Emp_Id,@From_Date = @FROMDATE,
	--									  @To_Date = @ToDATE,@Rpt_level=0,@Return_Record_set = 4,
	--									  @Constraint = N'1=1 and status = ''P''',@Type = 1,@DEPT_Id =0,@GRD_Id = 0	

	SELECT  0 AS OTCOUNT --Getting Performance Down

	exec SP_Get_HR_Checklist_Details @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Type_ID = 1

	
	SELECT COUNT(DISTINCT HTM.TRAINING_ID) as HR_Quest_Count
		FROM T0040_HRMS_TRAINING_MASTER HTM WITH (NOLOCK)
			INNER JOIN T0030_HRMS_TRAINING_TYPE HTT WITH (NOLOCK) ON HTT.TRAINING_TYPE_ID = HTM.TRAINING_TYPE
			INNER JOIN T0050_EMP_WISE_CHECKLIST EWC WITH (NOLOCK) ON EWC.TRAINING_ID = HTM.TRAINING_ID
			--INNER JOIN T0150_HRMS_TRAINING_QUESTIONNAIRE HTQ ON CAST(HTQ.TRAINING_ID AS VARCHAR) = CAST(HTM.TRAINING_ID AS VARCHAR)
	WHERE HTM.CMP_ID = @CMP_ID AND ISNULL(HTT.TYPE_INDUCTION,0) = 1 AND EWC.EMP_ID = @EMP_ID AND HTT.Induction_Traning_Dept = 1 -- For HR Department
		  AND EWC.FILL_DATE <= GETDATE() AND EWC.PASSING_FLAG IN (0,2) -- 0 For No Exam Conduct , 2 For Fail Exam	
		  AND EXISTS(Select 1 From T0150_HRMS_TRAINING_QUESTIONNAIRE HTQ WITH (NOLOCK) Where CHARINDEX(Cast(HTM.Training_id as Varchar(10)),HTQ.Training_Id) > 0)
			
	EXEC SP_Get_Fun_Checklist_Details @Cmp_ID=@Cmp_ID,@Emp_ID=@Emp_ID,@Type_ID = 1

	SELECT COUNT(DISTINCT HTM.TRAINING_ID) as Fun_Quest_Count
		FROM T0040_HRMS_TRAINING_MASTER HTM WITH (NOLOCK)
			INNER JOIN T0030_HRMS_TRAINING_TYPE HTT WITH (NOLOCK) ON HTT.TRAINING_TYPE_ID = HTM.TRAINING_TYPE
			INNER JOIN T0050_EMP_WISE_FUN_CHECKLIST EWC WITH (NOLOCK) ON EWC.TRAINING_ID = HTM.TRAINING_ID
			--INNER JOIN T0150_HRMS_TRAINING_QUESTIONNAIRE HTQ ON CAST(HTQ.TRAINING_ID AS VARCHAR) = CAST(HTM.TRAINING_ID AS VARCHAR)
	WHERE HTM.CMP_ID = @CMP_ID AND ISNULL(HTT.TYPE_INDUCTION,0) = 1 AND EWC.EMP_ID = @EMP_ID AND HTT.Induction_Traning_Dept = 2 -- For HR Department
		  AND EWC.FILL_DATE <= GETDATE() AND EWC.PASSING_FLAG IN (0,2) -- 0 For No Exam Conduct , 2 For Fail Exam
		  AND EXISTS(Select 1 From T0150_HRMS_TRAINING_QUESTIONNAIRE HTQ WITH (NOLOCK) Where CHARINDEX(Cast(HTM.Training_id as Varchar(10)),HTQ.Training_Id) > 0)
	
	RETURN


