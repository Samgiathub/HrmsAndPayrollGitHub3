


CREATE PROCEDURE [dbo].[P0120_Leave_Auto_Escalate]  
--    @For_Date datetime 
AS  
	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON 

	Declare @For_Date datetime 	
	set @For_Date = getdate()
	
	
	
	Declare @cmp_id as numeric(18,0)
	Declare @Auto_Escalate_Period as numeric(18,0)
	declare @Auto_Approve as numeric(18,0)
	declare @is_Enable as tinyint
	declare @admin_login_id as numeric(18,0)
	declare @is_sql_agent as tinyint
	declare @is_auto_reject as tinyint
	
	declare @is_Rm as tinyint
	declare @is_Bm as TINYINT
	DECLARE @emp_branch AS NUMERIC
	Declare @App_Emp_ID As Numeric(18,0)
	Declare @Employee_Email varchar(max)
	Declare @Manager_Email AS Varchar(max)
	Declare @Curr_Manager_Email Varchar(max)
	Declare @Application_Date	Datetime
	
	set @cmp_id = 0
	set @Auto_Escalate_Period = 0
	set @Auto_Approve = 0
	set @is_Enable = 0
	set @admin_login_id = 0
	set @is_sql_agent = 0
	set @is_auto_reject  = 0 
	
	Declare leave_Escalation_Master Cursor
		For SELECT  Cmp_id, Is_Enable, Escalate_After_days, Auto_Approve, is_sql_job_agent, is_auto_reject FROM T9999_Auto_Escalate_Setting WITH (NOLOCK) where Is_Enable = 1		 
	Open leave_Escalation_Master
	Fetch Next From leave_Escalation_Master Into  @cmp_id, @is_Enable, @Auto_Escalate_Period, @Auto_Approve,@is_sql_agent ,@is_auto_reject
	WHILE @@FETCH_STATUS = 0
		Begin
			--------------------------------	
			
			
			
			--set @Auto_Escalate_Period = 1 
			--set @Auto_Approve = 0
			--set @is_Enable  = 1
			--set @is_sql_agent = 1
			
			select @admin_login_id = login_id from T0011_LOGIN WITH (NOLOCK) where Cmp_ID = @cmp_id and Login_Name like 'admin@%'
			
			Create table #LeaveAppRrd
			 (		 
				 leave_app_id	Numeric(18,0)	
				,is_approve tinyint default 0
				
			 )  
			
			if @is_Enable = 1
				begin

					if @Auto_Escalate_Period > 0 and @Auto_Approve > 0
						BEGIN	
							 if @Auto_Escalate_Period >= @Auto_Approve 
								begin
									insert INTO #LeaveAppRrd
									select Leave_Application_ID,1 from T0100_LEAVE_APPLICATION WITH (NOLOCK) where (Application_Status = 'P' or Application_Status = 'F') and Cmp_ID = @cmp_id and datediff(dd,System_Date,@For_Date)  >= @Auto_Approve
									and Leave_Application_ID not in 
									(select LA.Leave_Application_ID from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
										INNER JOIN T0115_Leave_Level_Approval lla WITH (NOLOCK) ON LA.Leave_Application_ID = lla.Leave_Application_ID
										where (la.Application_Status = 'P' or la.Application_Status = 'F') and la.Cmp_ID = @cmp_id and datediff(dd,lla.Approval_Date,@For_Date)  >= @Auto_Approve )
									
									insert INTO #LeaveAppRrd
									select distinct LA.Leave_Application_ID,1 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
									INNER JOIN (SELECT llas.* from T0115_Leave_Level_Approval llas WITH (NOLOCK) INNER JOIN
									(
									SELECT max(Rpt_Level) as rpt_level,Leave_Application_ID from T0115_Leave_Level_Approval WITH (NOLOCK)
									GROUP by Leave_Application_ID
									) as qry
									on llas.Leave_Application_ID = qry.Leave_Application_ID AND llas.Rpt_Level = qry.rpt_level) as  lla ON LA.Leave_Application_ID = lla.Leave_Application_ID
									where (lla.Approval_Status = 'P' or lla.Approval_Status = 'F') and lla.Cmp_ID = @cmp_id and datediff(dd,lla.System_Date,@For_Date)  >= @Auto_Approve 

								end
							else if @Auto_Escalate_Period < @Auto_Approve 
								BEGIN
									insert INTO #LeaveAppRrd
									select Leave_Application_ID,1 from T0100_LEAVE_APPLICATION WITH (NOLOCK) where (Application_Status = 'P' or Application_Status = 'F') and Cmp_ID = @cmp_id and datediff(dd,System_Date,@For_Date)  >= @Auto_Approve
									and Leave_Application_ID not in 
									(select LA.Leave_Application_ID from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
										INNER JOIN T0115_Leave_Level_Approval lla WITH (NOLOCK) ON LA.Leave_Application_ID = lla.Leave_Application_ID
										where (la.Application_Status = 'P' or la.Application_Status = 'F') and la.Cmp_ID = @cmp_id and datediff(dd,lla.Approval_Date,@For_Date)  >= @Auto_Approve )

									insert INTO #LeaveAppRrd
									select distinct LA.Leave_Application_ID,1 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
									INNER JOIN (SELECT llas.* from T0115_Leave_Level_Approval llas WITH (NOLOCK) INNER JOIN
									(
									SELECT max(Rpt_Level) as rpt_level,Leave_Application_ID from T0115_Leave_Level_Approval WITH (NOLOCK)
									GROUP by Leave_Application_ID
									) as qry
									on llas.Leave_Application_ID = qry.Leave_Application_ID AND llas.Rpt_Level = qry.rpt_level) as  lla ON LA.Leave_Application_ID = lla.Leave_Application_ID
									where (lla.Approval_Status = 'P' or lla.Approval_Status = 'F') and lla.Cmp_ID = @cmp_id and datediff(dd,lla.System_Date,@For_Date)  >= @Auto_Approve 


									insert INTO #LeaveAppRrd
									select Leave_Application_ID,0 from T0100_LEAVE_APPLICATION WITH (NOLOCK) where (Application_Status = 'P' or Application_Status = 'F') and Cmp_ID = @cmp_id and datediff(dd,System_Date,@For_Date)  >= @Auto_Escalate_Period 
									and Leave_Application_ID not in (SELECT leave_app_id  from #LeaveAppRrd)
									and Leave_Application_ID not in 
									(select LA.Leave_Application_ID from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
										INNER JOIN T0115_Leave_Level_Approval lla WITH (NOLOCK) ON LA.Leave_Application_ID = lla.Leave_Application_ID
										where (la.Application_Status = 'P' or la.Application_Status = 'F') and la.Cmp_ID = @cmp_id and datediff(dd,lla.Approval_Date,@For_Date)  >= @Auto_Escalate_Period )
										
									
									insert INTO #LeaveAppRrd
									select distinct LA.Leave_Application_ID,0 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
									INNER JOIN (SELECT llas.* from T0115_Leave_Level_Approval llas WITH (NOLOCK) INNER JOIN
									(
									SELECT max(Rpt_Level) as rpt_level,Leave_Application_ID from T0115_Leave_Level_Approval WITH (NOLOCK)
									GROUP by Leave_Application_ID
									) as qry
									on llas.Leave_Application_ID = qry.Leave_Application_ID AND llas.Rpt_Level = qry.rpt_level) as  lla ON LA.Leave_Application_ID = lla.Leave_Application_ID
									where (lla.Approval_Status = 'P' or lla.Approval_Status = 'F') and lla.Cmp_ID = @cmp_id and datediff(dd,lla.System_Date,@For_Date)  >= @Auto_Escalate_Period 

								end
						END
					else if @Auto_Escalate_Period > 0	
						Begin
						 
							--insert INTO #LeaveAppRrd
							--select Leave_Application_ID,0 from T0100_LEAVE_APPLICATION where (Application_Status = 'P' or Application_Status = 'F') and Cmp_ID = @cmp_id and datediff(dd,System_Date,@For_Date)  >= @Auto_Escalate_Period 
							
							insert INTO #LeaveAppRrd
							select Leave_Application_ID,0 from T0100_LEAVE_APPLICATION WITH (NOLOCK)
							where (Application_Status = 'P' or Application_Status = 'F') and Cmp_ID = @cmp_id --and Leave_Application_ID = 1108
								and datediff(dd,System_Date,@For_Date)  >= @Auto_Escalate_Period 
								and Leave_Application_ID not in (SELECT leave_app_id  from #LeaveAppRrd)
								and Leave_Application_ID not in 
								(select LA.Leave_Application_ID from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
									INNER JOIN T0115_Leave_Level_Approval lla WITH (NOLOCK) ON LA.Leave_Application_ID = lla.Leave_Application_ID
									where (la.Application_Status = 'P' or la.Application_Status = 'F') and la.Cmp_ID = @cmp_id and datediff(dd,la.System_Date,@For_Date)  >= @Auto_Escalate_Period )
										
						 
						 	insert INTO #LeaveAppRrd
							select distinct LA.Leave_Application_ID,0 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
								INNER JOIN (SELECT llas.* from T0115_Leave_Level_Approval llas WITH (NOLOCK) INNER JOIN
							(
							SELECT max(Rpt_Level) as rpt_level,Leave_Application_ID from T0115_Leave_Level_Approval WITH (NOLOCK)
							GROUP by Leave_Application_ID
							) as qry
							on llas.Leave_Application_ID = qry.Leave_Application_ID AND llas.Rpt_Level = qry.rpt_level) as  lla ON LA.Leave_Application_ID = lla.Leave_Application_ID
							where (lla.Approval_Status = 'P' or lla.Approval_Status = 'F') and lla.Cmp_ID = @cmp_id 
								and datediff(dd,lla.System_Date,@For_Date)  >= @Auto_Escalate_Period --and lla.Leave_Application_ID = 1108


									
						end
					else if @Auto_Approve > 0	
						begin
						
							insert INTO #LeaveAppRrd
							select Leave_Application_ID,1 from T0100_LEAVE_APPLICATION WITH (NOLOCK) where (Application_Status = 'P' or Application_Status = 'F') and Cmp_ID = @cmp_id and datediff(dd,System_Date,@For_Date)  >= @Auto_Approve
							and Leave_Application_ID not in 
									(select LA.Leave_Application_ID from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
										INNER JOIN T0115_Leave_Level_Approval lla WITH (NOLOCK) ON LA.Leave_Application_ID = lla.Leave_Application_ID
										where (la.Application_Status = 'P' or la.Application_Status = 'F') and la.Cmp_ID = @cmp_id and datediff(dd,lla.Approval_Date,@For_Date)  >= @Auto_Approve )
							
							
							insert INTO #LeaveAppRrd
									select distinct LA.Leave_Application_ID,1 from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
									INNER JOIN (SELECT llas.* from T0115_Leave_Level_Approval llas WITH (NOLOCK) INNER JOIN
									(
									SELECT max(Rpt_Level) as rpt_level,Leave_Application_ID from T0115_Leave_Level_Approval WITH (NOLOCK)
									GROUP by Leave_Application_ID
									) as qry
									on llas.Leave_Application_ID = qry.Leave_Application_ID AND llas.Rpt_Level = qry.rpt_level) as  lla ON LA.Leave_Application_ID = lla.Leave_Application_ID
									where (lla.Approval_Status = 'P' or lla.Approval_Status = 'F') and lla.Cmp_ID = @cmp_id and datediff(dd,lla.System_Date,@For_Date)  >= @Auto_Approve 

							
						end
										
					 
					declare @leave_app_id_cur as numeric(18,0) 
					declare @is_approve_cur as numeric(18,0) 
					declare @Emp_id_cur as numeric(18,0) 
					declare @Leave_ID_cur as Numeric(18,0)
					declare @From_Date_cur as Datetime
					declare @To_Date_cur as Datetime
					declare @Leave_Period_cur as Numeric(18,1)
					declare @Leave_Assign_As_cur as Varchar(15)
					declare @Leave_Reason_cur as Varchar(100)
					declare @M_Cancel_WO_HO_cur as TinyInt
					declare @Half_Leave_Date_cur as Datetime
					declare @S_Emp_ID_cur as Numeric(18,0)
					declare @Approval_Date_cur as Datetime
					declare @Approval_Status_cur as Char(1)
					declare @Approval_Comments_cur as Varchar(250)
					declare @Rpt_Level_cur as TinyInt
					declare @Tran_Type_cur as Char(1)
					declare @is_arrear as tinyint  
					declare @arrear_month as numeric(18,0)  
					declare @arrear_year as numeric(18,0) 
					declare @Leave_Approval_ID as numeric 
					declare @Login_ID as numeric  
					declare @System_Date as datetime  
					declare @User_Id as numeric(18,0) 
					declare @IP_Address as varchar(30)
					declare @Row_Id as numeric(18,0) 
					
					Set @leave_app_id_cur = 0
					Set @is_approve_cur = 0
					Set @Emp_id_cur = 0
					Set @Leave_ID_cur = 0
					Set @Leave_Period_cur = 0
					Set @Leave_Assign_As_cur = ''
					Set @Leave_Reason_cur = ''
					Set @M_Cancel_WO_HO_cur = 0
					Set @S_Emp_ID_cur = 0
					Set @Approval_Status_cur = ''
					Set @Approval_Comments_cur = ''
					Set @Rpt_Level_cur = 0
					Set @Tran_Type_cur = ''
					Set @is_arrear = 0
					Set @arrear_month = 0
					Set @arrear_year = 0
					Set @Leave_Approval_ID = 0
					Set @Login_ID = 0
					Set @User_Id = 0
					Set @IP_Address = ''
					set @Row_Id = 0
					
					
				 	
					Declare leave_Escalation_Cur Cursor
						For SELECT lar.leave_app_id,lar.is_approve FROM #LeaveAppRrd LAR	--WHERE 	lar.leave_app_id = 1108	
					Open leave_Escalation_Cur
					Fetch Next From leave_Escalation_Cur Into  @leave_app_id_cur,@is_approve_cur
					WHILE @@FETCH_STATUS = 0
						Begin
							--Begin Try	
							
									declare @tran_id numeric(18,0)					 
									declare @Rpt_Level_max numeric(18,0)
									Declare @profile as varchar(50)
									declare @body as nvarchar(max)
									declare @FullName as nvarchar(100)
									declare @LeaveType as nvarchar(100)
									declare @signature as nvarchar(max)
									
									set @profile = ''
									set @Rpt_Level_max = 0
									
									SELECT @Rpt_Level_max = isnull(max(Rpt_Level),0) FROM T0050_Scheme_Detail WITH (NOLOCK)
									where Scheme_Id = (SELECT Scheme_Id from T0095_EMP_SCHEME WITH (NOLOCK) where Emp_ID = @Emp_id_cur 
									AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME WITH (NOLOCK) where Emp_ID = @Emp_id_cur AND Effective_Date <= getdate() )) 
									AND  (SELECT Leave_ID from V0110_LEAVE_APPLICATION_DETAIL where Leave_Application_ID  = @leave_app_id_cur ) 
									IN (select data from dbo.split(leave,'#'))
									
									IF not exists(select 1 FROM T0115_Leave_Level_Approval WITH (NOLOCK) where Leave_Application_ID = @leave_app_id_cur)
										begin
										
												SELECT    @Emp_id_cur = Emp_ID , @Leave_ID_cur = Leave_ID , @From_Date_cur = From_Date , @To_Date_cur =To_Date
												,@Leave_Period_cur =  Leave_Period , @Leave_Assign_As_cur = Leave_Assign_As , @Leave_Reason_cur = Leave_Reason
												,@M_Cancel_WO_HO_cur = 0 , @Half_Leave_Date_cur = Half_Leave_Date , @S_Emp_ID_cur = S_Emp_ID , 
												@Approval_Date_cur = getdate() , @Approval_Status_cur = 'F' , @Approval_Comments_cur = 'Auto Escalate' 
												,@Rpt_Level_cur = 1 , @Tran_Type_cur = 'I' ,@is_arrear = 0 , @arrear_month = 0 , @arrear_year = 0
												FROM   T0100_LEAVE_APPLICATION  LA WITH (NOLOCK)
												inner JOIN 
												T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON la.Leave_Application_ID = LAD.Leave_Application_ID
												WHERE lad.Leave_Application_ID = @leave_app_id_cur
												
												
										end
									else
										begin	
											
											SELECT  @Emp_id_cur = Emp_ID , @Leave_ID_cur = Leave_ID , @From_Date_cur = From_Date , @To_Date_cur =To_Date
											,@Leave_Period_cur =  Leave_Period , @Leave_Assign_As_cur = Leave_Assign_As , @Leave_Reason_cur = Leave_Reason
											,@M_Cancel_WO_HO_cur = M_Cancel_WO_HO , @Half_Leave_Date_cur = Half_Leave_Date ,@S_Emp_ID_cur = S_Emp_ID , 
											@Approval_Date_cur = getdate() , @Approval_Status_cur = 'F' , @Approval_Comments_cur = 'Auto Escalate' 
											,@Rpt_Level_cur = Rpt_Level + 1 , @Tran_Type_cur = 'I' ,@is_arrear = is_Arrear , @arrear_month = arrear_month , @arrear_year = arrear_year
											FROM T0115_Leave_Level_Approval WITH (NOLOCK) WHERE Leave_Application_ID = @leave_app_id_cur and 
											Rpt_Level in (SELECT max(Rpt_Level) Rpt_Level FROM T0115_Leave_Level_Approval WITH (NOLOCK) WHERE Leave_Application_ID = @leave_app_id_cur)
											
											Select @S_Emp_ID_cur = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM From T0050_Scheme_Detail WITH (NOLOCK) 
											Where Rpt_Level = (@Rpt_Level_cur)
												AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
																(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
																where IES.effective_date <= getdate() AND Emp_ID = @Emp_id_cur And Type = 'Leave'
																GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave')
												And @Leave_ID_cur In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
											
											if @S_Emp_ID_cur = 0  and @is_Rm =1 
												begin
													SELECT @S_Emp_ID_cur = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
															(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
																where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_id_cur
															GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
														where ERD.Emp_ID = @Emp_id_cur
												End
											else IF @S_Emp_ID_cur = 0  and @is_Bm =1 
												BEGIN							
													SELECT @S_Emp_ID_cur = Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
													WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
												end 
												
										end
									
									
									
									IF @is_approve_cur = 0
										begin
											
																			 
											exec P0115_Leave_Level_Approval @tran_id output, @Cmp_ID, @leave_app_id_cur, @Emp_id_cur, @Leave_ID_cur , @From_Date_cur , @To_Date_cur , @Leave_Period_cur, @Leave_Assign_As_cur, @Leave_Reason_cur , @M_Cancel_WO_HO_cur , @Half_Leave_Date_cur ,@S_Emp_ID_cur ,@Approval_Date_cur , @Approval_Status_cur , @Approval_Comments_cur , @Rpt_Level_cur , @Tran_Type_cur , @is_arrear , @arrear_month , @arrear_year
											

											
											if @is_sql_agent = 1
												begin
												
													----Ankit For Next Manager Email ID Get ----
												
													set @is_Bm = 0
													set @is_Rm = 0
													Set @App_Emp_ID = 0
													SET @Employee_Email = ''
													SET @Manager_Email = ''
						
													Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM From T0050_Scheme_Detail WITH (NOLOCK)
													Where Rpt_Level = (@Rpt_Level_cur + 1)
														AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
																		(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
																		where IES.effective_date <= getdate() AND Emp_ID = @Emp_id_cur And Type = 'Leave'
																		GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave')
														And @Leave_ID_cur In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
													
													if @App_Emp_ID = 0  and @is_Rm =1 
														begin
															SELECT @App_Emp_ID = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
																	(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
																		where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_id_cur
																	GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
																where ERD.Emp_ID = @Emp_id_cur
														End
													else IF @App_Emp_ID = 0  and @is_Bm =1 
														BEGIN							
															SELECT @App_Emp_ID = Emp_id FROM T0095_MANAGERS WITH (NOLOCK) 
															WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
														end 
													
													SELECT @Manager_Email = Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_id = @App_Emp_ID
													
													---Get Current Level Manager Email
													
													set @is_Bm = 0
													set @is_Rm = 0
													Set @App_Emp_ID = 0
													SET @Curr_Manager_Email = ''
						
													--Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM From T0050_Scheme_Detail 
													--Where Rpt_Level = (@Rpt_Level_cur)
													--	AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES INNER join 
													--					(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES
													--					where IES.effective_date <= getdate() AND Emp_ID = @Emp_id_cur And Type = 'Leave'
													--					GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave')
													--	And @Leave_ID_cur In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
													
													--if @App_Emp_ID = 0  and @is_Rm =1 
													--	begin
													--		SELECT @App_Emp_ID = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
													--				(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1
													--					where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_id_cur
													--				GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
													--			where ERD.Emp_ID = @Emp_id_cur
													--	End
													--else IF @App_Emp_ID = 0  and @is_Bm =1 
													--	BEGIN							
													--		SELECT @App_Emp_ID = Emp_id FROM T0095_MANAGERS 
													--		WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
													--	end 
															
													SELECT @Curr_Manager_Email = Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_id = @S_Emp_ID_cur
																	
													----Ankit For Next Manager Email ID Get ----	
													
													select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
													if isnull(@profile,'') = ''
														begin
															select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
														end 
       												  
													
													
													select @body = Email_Signature From T0010_Email_Format_Setting WITH (NOLOCK) Where Cmp_ID = @cmp_id And Email_Type = 'Leave Application'
													
													
													SELECT @FullName = Emp_Full_Name , @LeaveType = Leave_Name,@Employee_Email = Work_Email ,@Application_Date = Application_Date
													from V0110_LEAVE_APPLICATION_DETAIL where Leave_Application_ID = @leave_app_id_cur
													
													IF ISNULL(@Curr_Manager_Email,'') <> ''
														Set @Employee_Email = @Employee_Email + ';' + @Curr_Manager_Email
												
												
												
													select @signature = Cmp_Signature from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @cmp_id
													set @signature = replace(@signature,'#Logo','')
													 
													set @body = replace(@body,'#status#',@Approval_Comments_cur)
													set @body = replace(@body,'#message#','Leave Approval')
													set @body = replace(@body,'#FullName#',@FullName)
													set @body = replace(@body,'#Leave_Type#',@LeaveType)
													set @body = replace(@body,'#From_Date#',convert(VARCHAR,@From_Date_cur,103))
													set @body = replace(@body,'#to_date#',convert(VARCHAR,@To_Date_cur,103))
													set @body = replace(@body,'#days#',@Leave_Period_cur)
													set @body = replace(@body,'#Period#',@Leave_Assign_As_cur)
													set @body = replace(@body,'#Reason#',@Leave_Reason_cur)
													set @body = replace(@body,'#Signature#',@signature)
													set @body = replace(@body,'#Approve#','')
													set @body = replace(@body,'#Reject#','')
													set @body = replace(@body,'#ApplicationDate#',convert(VARCHAR,@Application_Date,103))
													
													
													EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Manager_Email , @subject = 'Leave Approval', @body = @body, @body_format = 'HTML' , @copy_recipients = @Employee_Email
														
												end
										end
									else
										begin
											
											if @is_auto_reject = 1
												begin
													set @Approval_Status_cur = 'R'
												end
											else
												begin
													set @Approval_Status_cur = 'A'
												end
												
												
											exec P0120_LEAVE_APPROVAL @Leave_Approval_ID output,@leave_app_id_cur,@Cmp_ID , @Emp_id_cur, @S_Emp_ID_cur , @Approval_Date_cur , @Approval_Status_cur , @Approval_Comments_cur,@admin_login_id,@Approval_Date_cur,@Tran_Type_cur,@admin_login_id,''
											
											exec P0130_LEAVE_APPROVAL_DETAIL @Row_Id output,@Leave_Approval_ID, @Cmp_ID,@Leave_ID_cur , @From_Date_cur , @To_Date_cur, @Leave_Period_cur ,  @Leave_Assign_As_cur , @Leave_Reason_cur , @admin_login_id, @Approval_Date_cur, 0 , @Tran_Type_cur , @M_Cancel_WO_HO_cur, @Half_Leave_Date_cur ,@admin_login_id,''
											
											if @is_sql_agent = 1
												begin
													select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
													if isnull(@profile,'') = ''
														begin
															select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
														end 
       												  
													select @body = Email_Signature From T0010_Email_Format_Setting WITH (NOLOCK) Where Cmp_ID = @cmp_id And Email_Type = 'Leave Application'
													
													
													SELECT @FullName = Emp_Full_Name , @LeaveType = Leave_Name, @Employee_Email = Work_Email 
													from V0110_LEAVE_APPLICATION_DETAIL where Leave_Application_ID = @leave_app_id_cur
													
													select @signature = Cmp_Signature from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @cmp_id
													set @signature = replace(@signature,'#Logo','')
													 
													set @body = replace(@body,'#status#',@Approval_Comments_cur)
													set @body = replace(@body,'#message#','Leave Approval')
													set @body = replace(@body,'#FullName#',@FullName)
													set @body = replace(@body,'#Leave_Type#',@LeaveType)
													set @body = replace(@body,'#From_Date#',convert(VARCHAR,@From_Date_cur,103))
													set @body = replace(@body,'#to_date#',convert(VARCHAR,@To_Date_cur,103))
													set @body = replace(@body,'#days#',@Leave_Period_cur)
													set @body = replace(@body,'#Period#',@Leave_Assign_As_cur)
													set @body = replace(@body,'#Reason#',@Leave_Reason_cur)
													set @body = replace(@body,'#Signature#',@signature)
													set @body = replace(@body,'#Approve#','')
													set @body = replace(@body,'#Reject#','')
													
													if @Employee_Email <> ''   
													EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Employee_Email, @subject = 'Leave Approval', @body = @body, @body_format = 'HTML' , @copy_recipients = ''         
														
												end	
										end
											 
								--END TRY
								--BEGIN CATCH	
								--			Select  
								--			ERROR_NUMBER() AS ErrorNumber,
								--			ERROR_SEVERITY() AS ErrorSeverity,
								--			ERROR_STATE() as ErrorState,
								--			ERROR_PROCEDURE() as ErrorProcedure,
								--			ERROR_LINE() as ErrorLine,
								--			ERROR_MESSAGE() as ErrorMessage;  
								--End Catch
							Fetch Next From leave_Escalation_Cur Into @leave_app_id_cur,@is_approve_cur
						End
					Close leave_Escalation_Cur
					Deallocate leave_Escalation_Cur	
				
				end	
			
				drop TABLE #LeaveAppRrd	
			--------------------------
			Fetch Next From leave_Escalation_Master Into @cmp_id, @is_Enable, @Auto_Escalate_Period, @Auto_Approve,@is_sql_agent ,@is_auto_reject
		End
	Close leave_Escalation_Master
	Deallocate leave_Escalation_Master	
 RETURN
