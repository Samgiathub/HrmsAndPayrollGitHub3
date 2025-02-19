


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:exec [Get_Candidate_Approval_Record] 9,1353,1,''
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Candidate_Approval_Record]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	if @Constrains = ''
		set @Constrains = '1=1'
	
	
	Declare @Scheme_ID As Numeric(18,0)
	Declare @Leave As Varchar(100)
	Declare @is_rpt_manager As tinyint
	Declare @is_branch_manager As tinyint
	Declare @is_HR As tinyint --added 29 Jan 2015 sneha
	Declare @is_HOD As tinyint --added 29 Jan 2015 sneha
	 
	Declare @SqlQuery As NVarchar(max)
	Declare @SqlExcu As NVarchar(max)
	declare @MaxLevel as numeric(18,0)
	Declare @Rpt_level_Minus_1 As Numeric(18,0)
	  
	set @MaxLevel =5
	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @SqlExcu = ''
	set @is_HR =0--added 29 Jan 2015 sneha
	set @is_HOD =0--added 29 Jan 2015 sneha
	
	
	CREATE table #Responsiblity_Passed
	 (		 
	     Emp_ID	Numeric(18,0)	
	    ,is_res_passed tinyint default 1  
	 )  
	 
	 Insert into #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 Insert into #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) where pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date  
	 
	 CREATE table #tbl_Scheme_Leave 
	 (
		Scheme_ID			Numeric(18,0)
	   ,Leave				Varchar(100) 
	   ,Final_Approver		TinyInt
	   ,Is_Fwd_Leave_Rej	TinyInt
	   ,is_rpt_manager		TinyInt not null default 0
	   ,is_branch_manager	TinyInt not null default 0
	   ,is_HOD				TinyInt not null default 0--added 29 Jan 2015 sneha
	   ,is_HR				TinyInt not null default 0--added 29 Jan 2015 sneha
	   ,rpt_level			numeric(18,0)
	 )  
	
	CREATE table #tbl_Leave_App
	 (
		Leave_App_ID	Numeric(18,0)
	   ,Scheme_ID		Numeric(18,0)
	   ,Leave			Varchar(100) 
	   ,rpt_level		numeric(18,0)
	 )
	 
	  if @Rpt_level > 0
		begin
			set @MaxLevel = @Rpt_level
		end
	 else
		begin
			set @Rpt_level = 1
		end
	 
	Create table #CandidateApproval
	(
		Rpt_Level				numeric(18,0)
		,Scheme_ID				numeric(18,0)	
		,Final_Approver		TinyInt
		,Is_Fwd_Leave_Rej	TinyInt
		,is_pass_over		tinyint
		,Alpha_Emp_Code      Varchar(200)	
		,Emp_Full_Name		Varchar(200)
		,Emp_Id				numeric(18,0)
		,ResumeFinal_ID			numeric(18,0)
		,Grade_Name		varchar(50)
		,Desig_Name     varchar(50)
		,Branch_Name	varchar(50)
		,[Type_Name]		varchar(50)
		,Dept_Name		varchar(50)
		,CanApp_Status	int
		,Resume_ID		numeric(18,0)
		,App_Full_Name	Varchar(200)
		,Joining_date	datetime
		,job_title		varchar(100)
		,Tran_Id		numeric(18,0)
		,Rec_post_ID	numeric(18,0)
	)
	
	declare @Emp_ID_Cur numeric(18,0)
	declare @is_res_passed tinyint
	
	set @Emp_ID_Cur = 0
	set @is_res_passed = 0
	
	------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		DECLARE @string_1	VARCHAR(MAX)
 		
 		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 			( SELECT MAX(Effect_Date) as Effect_Date,Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
 																	WHERE R_Emp_ID = @Emp_ID) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID = @Emp_ID for xml path (''))
		
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			end	
		
		----
		declare @Manager_Branch numeric(18,0)
		Declare @Manager_HOD varchar(max) --added 29 Jan 2015 sneha
		Declare @Manager_HR varchar(max) --added 29 Jan 2015 sneha
	Declare Employee_Cur Cursor
		For Select distinct Emp_ID,is_res_passed From #Responsiblity_Passed
	Open Employee_Cur
		Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
		Begin
			set @Rpt_level = 1
			If @Emp_ID_Cur > 0
				Begin
					
					set @Manager_Branch = 0
					
					set @Manager_HOD = 0
					
					set @Manager_HR = ''
					
					if exists (SELECT 1 from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur)
					BEGIN 
						SELECT @Manager_Branch = branch_id from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur AND Effective_date = 
						( 
							SELECT max(Effective_date) AS Effective_date from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur AND Effective_date <= getdate()
						)
					END
					--added 29 Jan 2015 sneha 
					
					if exists (SELECT 1 from T0095_Department_Manager WITH (NOLOCK) where Emp_id = @Emp_ID_Cur)
						BEGIN 
							SELECT @Manager_HOD = COALESCE(cast(@Manager_HOD as varchar(100)) + '#', '') + ''+ cast( dm.dept_id as varchar(100)) + ''
							from T0095_Department_Manager DM WITH (NOLOCK) inner join 
							(select max(effective_date) as max_date,dept_id	 from T0095_Department_Manager WITH (NOLOCK) group by dept_id) MDM 
							on DM.dept_id=MDM.dept_id and DM.effective_date=MDM.max_date
							where dm.emp_id=@Emp_ID_Cur
						END
					--added 29 Jan 2015 sneha
					if exists (SELECT 1 from T0011_LOGIN WITH (NOLOCK) where Emp_id = @Emp_ID_Cur)
						BEGIN 
							SELECT @Manager_HR = Branch_id_multi from T0011_LOGIN WITH (NOLOCK) where Emp_id = @Emp_ID_Cur AND Is_HR = 1						
						END
					
					WHILE @Rpt_level <= @MaxLevel
						Begin
							 Set @Rpt_level_Minus_1 = @Rpt_level - 1
							if @Emp_ID_Cur > 0
							  begin  
								Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,is_HOD,is_HR,rpt_level)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,is_HOD,is_HR,rpt_level 
								From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level And SM.Scheme_Type = 'Candidate Approval'
								
								IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
									BEGIN 
										SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,is_HOD,is_HR,rpt_level)
														Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,is_HOD,is_HR,rpt_level  
														From T0050_Scheme_Detail WITH (NOLOCK)
														Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
														Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
															And T0040_Scheme_Master.Scheme_Type = ''Candidate Approval'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' --,Max_Leave_Days,Leave_Days
										
										EXEC (@string_1)
										
									END		
														 	 
								--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level)
								--Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level 
								--From T0050_Scheme_Detail SD Inner Join T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id
								--Where  rpt_level = @Rpt_level and Is_RM = 1 And SM.Scheme_Type = 'Candidate Approval'
								
								
								if @Manager_Branch > 0 
								begin								
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level 
										From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and Is_BM = 1 And SM.Scheme_Type = 'Candidate Approval'							
								end
								if @Manager_HOD <> '' ---29 jan 2016
								begin						
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_HOD,rpt_level)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,SD.Is_HOD,rpt_level 
										From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and Is_HOD = 1 And SM.Scheme_Type = 'Candidate Approval'		
													
								end
								if @Manager_HR <> '' ---29 jan 2016
								begin								
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_HR,rpt_level)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,SD.Is_HR,rpt_level 
										From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and SD.Is_HR = 1 And SM.Scheme_Type = 'Candidate Approval'							
								end
							End
						Else
							begin
								Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level 
								From T0050_Scheme_Detail  SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where SM.Scheme_Type = 'Candidate Approval'
							end
							
																					
							declare @rpt_levle_cur tinyint
							set @rpt_levle_cur = 0
							
							Declare Final_Approver Cursor
								For Select distinct Scheme_Id, Leave,rpt_level From #tbl_Scheme_Leave 
							Open Final_Approver
							Fetch Next From Final_Approver Into @Scheme_ID, @Leave,@rpt_levle_cur
							WHILE @@FETCH_STATUS = 0
								Begin
									If Exists (Select Scheme_Detail_ID From T0050_Scheme_Detail WITH (NOLOCK)
													Where Scheme_Id = @Scheme_ID And Leave = @Leave And Rpt_Level = @Rpt_level + 1 AND not_mandatory = 0)
										Begin
											Update #tbl_Scheme_Leave 
												Set Final_Approver = 0 
												Where Scheme_Id = @Scheme_ID And Leave = @Leave and rpt_level =  @Rpt_level
										End
									Else 
										Begin
											Update #tbl_Scheme_Leave 
												Set Final_Approver = 1 
												Where Scheme_Id = @Scheme_ID And Leave = @Leave  and rpt_level =  @Rpt_level
										End
													
									Fetch Next From Final_Approver Into @Scheme_ID, @Leave,@rpt_levle_cur	
								End
							Close Final_Approver	
							Deallocate Final_Approver	
							
							Declare cur_Scheme_Leave Cursor
								For Select Scheme_Id, Leave,is_rpt_manager,is_branch_manager,is_HOD,is_HR From #tbl_Scheme_Leave where rpt_level = @Rpt_level
							Open cur_Scheme_Leave
							Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_HOD,@is_HR
							WHILE @@FETCH_STATUS = 0
								Begin
									CREATE table #Emp_Cons 
									 (
									   Emp_ID numeric    
									 )
									
									 if @is_branch_manager = 1
										begin 
											Insert Into #Emp_Cons(Emp_ID)    
											Select ES.Emp_ID 
											From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
												(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
												 where Effective_Date<=GETDATE() And Type='Candidate Approval'
												 GROUP BY emp_ID) Qry on      
												 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
												 and Scheme_Id = @Scheme_ID  And Type='Candidate Approval'
											INNER join 
											(select Branch_ID,I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
											   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)  
											   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
												I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
												on INC.Emp_ID = Qry.Emp_ID
											Where ES.Scheme_Id = @Scheme_ID and INC.Branch_ID = @Manager_Branch
											
											If @Rpt_level = 1
												Begin 	 
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From v0060_RESUME_FINAL LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_ID = Ec.Emp_ID
															Where LAD.Rec_Req_ID Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK) 
																	Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + ' And ' + @Constrains   
													
												End
											Else  
												Begin	 										
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																 '  From v0060_RESUME_FINAL LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																													
																And LAD.Tran_Id In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
																									Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
															   )'    
																
														   + ' And ' + @Constrains
														
												End	  	
										End
									else if @is_rpt_manager = 1
										BEGIN  
											Insert Into #Emp_Cons(Emp_ID)    
												Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													inner join 
														T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
													INNER JOIN
													(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
														 where Effective_Date<=GETDATE()
														 And Type='Candidate Approval'
														 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
														 and Scheme_Id = @Scheme_ID And Type='Candidate Approval'
													Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID 
													
											If @Rpt_level = 1 
												Begin 
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
														  + ' And ' + @Constrains	  
												End
											Else
												Begin     
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																											
														And LAD.Tran_Id In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'   
																  + ' And ' + @Constrains
												End
											
										End
									--added on 29 Jan 2016 start
									else if @is_HOD = 1
										BEGIN 
											Insert Into #Emp_Cons(Emp_ID)    
												Select ES.Emp_ID 
												From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
													(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													 Where Effective_Date<=GETDATE() And Type='Candidate Approval'
													 GROUP BY emp_ID) Qry on      
													 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Candidate Approval'
												INNER JOIN 
												(select Branch_ID,I.Emp_ID,Dept_ID From T0095_Increment I WITH (NOLOCK) inner join     
												   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
												   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
													I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
													on INC.Emp_ID = Qry.Emp_ID
												Where ES.Scheme_Id = @Scheme_ID --and INC.Dept_ID =@Manager_HOD
												and  INC.Dept_ID in(select data from dbo.Split(@Manager_HOD,'#'))				
													
												
											If @Rpt_level = 1 
												Begin 
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
														  + ' And ' + @Constrains	  
												End
											Else
												Begin     
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																											
														And LAD.Tran_Id In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'   
																  + ' And ' + @Constrains
												End

										End--added on 29 Jan 2016 end
									--added on 29 Jan 2016 start
									else if @is_HR = 1
										BEGIN
											Insert Into #Emp_Cons(Emp_ID)    
												Select ES.Emp_ID 
													From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
														 where Effective_Date<=GETDATE() And Type='Candidate Approval'
														 GROUP BY emp_ID) Qry on      
														 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
														 and Scheme_Id = @Scheme_ID  And Type='Candidate Approval'
													INNER join 
													(select Branch_ID,I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
													   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
													   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
														I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
														on INC.Emp_ID = Qry.Emp_ID
													Where ES.Scheme_Id = @Scheme_ID 
													and  INC.Branch_ID in (case @Manager_HR when '0' then INC.Branch_ID 
														else (select data from dbo.Split(@Manager_HR,'#')) end)	
												
											If @Rpt_level = 1 
												Begin 
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval 
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
														  + ' And ' + @Constrains	  
												End
											Else
												Begin     
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where (LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																											
														And LAD.Tran_Id In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'   
																  + ' And ' + @Constrains
												End	
										End--added on 29 Jan 2016 end
									else if @is_rpt_manager = 0 and @is_branch_manager = 0 and @is_HOD = 0 and @is_HR = 0
										Begin  
											Insert Into #Emp_Cons(Emp_ID)   
											Select ES.Emp_ID 
											From T0095_EMP_SCHEME ES Inner Join
												(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
												 where Effective_Date<=GETDATE() 
												 And Type='Candidate Approval'
												 GROUP BY emp_ID) Qry on      
												 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
												 and Scheme_Id = @Scheme_ID And Type='Candidate Approval'
											Where ES.Scheme_Id = @Scheme_ID  
											
											If @Rpt_level = 1
												begin 
													Set @SqlQuery = 	
														'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
														' From v0060_RESUME_FINAL LAD
														Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
														Where LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval 
														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
														+ ' And ' + @Constrains														
												end
											Else
												Begin									
													Set @SqlQuery = 	
													'Select LAD.Tran_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
													' From v0060_RESUME_FINAL LAD
													 Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
													Where (LAD.Tran_Id Not In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																											
													And LAD.Tran_Id In (Select ResumeFinal_ID From T0052_ResumeFinal_Approval WITH (NOLOCK)
													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
													)'  		
													+ ' And ' + @Constrains												
																								
												End
												
										End
										
										insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										exec (@SqlQuery)
										
										
										Drop Table #Emp_Cons
										Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_HOD,@is_HR
								End
							close cur_Scheme_Leave
							deallocate cur_Scheme_Leave
							
							 set @Rpt_level = @Rpt_level + 1
						End
				End
				
				If @Emp_ID_Cur > 0
					begin 
						insert INTO #CandidateApproval
						Select distinct	isnull(Qry1.rpt_level + 1,'1') As Rpt_Level
								,TLAP.Scheme_ID
								,SL.Final_Approver
								,SL.Is_Fwd_Leave_Rej
								,@is_res_passed	
								,rr.Alpha_Emp_Code
								,rr.Emp_Full_Name
								,rr.Emp_id
								,rr.Tran_ID
								,rr.Grd_Name
								,rr.Desig_Name
								,rr.Branch_Name
								,rr.Type_Name
								,rr.Dept_Name
								,rr.Resume_Status
								,rr.Resume_ID
								,rr.App_Full_name
								,rr.Joining_date
								,rr.Job_title
								,rr.Tran_ID
								,rr.Rec_post_Id
						from v0060_RESUME_FINAL rr
					 left outer join (select RLA.ResumeFinal_ID As App_ID, 
						   Rpt_Level as Rpt_Level , 
						   RLA.CanApp_Status
						   From T0052_ResumeFinal_Approval RLA WITH (NOLOCK)
						inner join (Select max(rpt_level) as rpt_level1, ResumeFinal_ID
										From T0052_ResumeFinal_Approval WITH (NOLOCK)
										Where ResumeFinal_ID In (Select Leave_App_ID From #tbl_Leave_App)
										group by ResumeFinal_ID
									) Qry
						on qry.ResumeFinal_ID = RLA.ResumeFinal_ID and qry.rpt_level1 = RLA.rpt_level) As Qry1 
						On  rr.Tran_ID = Qry1.App_ID	
						Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = rr.Tran_ID
						inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level
						Where Tran_ID In (Select Leave_App_ID From #tbl_Leave_App)
					   and rr.Resume_Status <>2
					End
				Else
			Begin 
				insert INTO #CandidateApproval
					Select distinct	isnull(Qry1.rpt_level + 1,'1') As Rpt_Level
								,'0' as Scheme_ID
								,'1' as Final_Approver
								,'0' as Is_Fwd_Leave_Rej		
								,@is_res_passed
								,@is_res_passed	
								,rr.Alpha_Emp_Code
								,rr.Emp_Full_Name
								,rr.Emp_id
								,rr.Tran_ID
								,rr.Grd_Name
								,rr.Desig_Name
								,rr.Branch_Name
								,rr.Type_Name
								,rr.Dept_Name
								,rr.Resume_Status
								,rr.Resume_ID
								,rr.App_Full_name
								,rr.Joining_date
								,rr.Job_title
								,rr.Tran_ID
								,rr.Rec_post_Id
					from v0060_RESUME_FINAL rr
					left outer join (
					select RLA.ResumeFinal_ID As App_ID, 
						   Rpt_Level as Rpt_Level , 
						   RLA.CanApp_Status
						   From T0052_ResumeFinal_Approval RLA WITH (NOLOCK)
						inner join (Select max(rpt_level) as rpt_level1, ResumeFinal_ID
										From T0052_ResumeFinal_Approval WITH (NOLOCK)
										Where ResumeFinal_ID In (Select Leave_App_ID From #tbl_Leave_App)
										group by ResumeFinal_ID 
									) Qry
						on qry.ResumeFinal_ID = RLA.ResumeFinal_ID and qry.rpt_level1 = RLA.Rpt_Level						
					) As Qry1 
					On  rr.Tran_ID = Qry1.App_ID
				WHERE
				 rr.Cmp_ID = @Cmp_ID   and rr.Resume_Status <>2
			End	
			
			select * from #CandidateApproval
			
			Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
		End
	close Employee_Cur
	Deallocate Employee_Cur
	
	if @Type = 0
			begin
				
				If @Emp_ID_Cur > 0
					Begin
						select 0 As is_Final_Approved,#CandidateApproval.*,c.Cat_Name,d.Dept_Name,dg.Desig_Name from #CandidateApproval 
						inner join	T0095_INCREMENT inc WITH (NOLOCK) on inc.Emp_ID = #CandidateApproval.Emp_ID and inc.Increment_ID= (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = #CandidateApproval.Emp_Id)
						left join T0030_CATEGORY_MASTER c WITH (NOLOCK) on c.Cat_ID = inc.Cat_ID 
						left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = inc.Dept_ID
						left join T0040_DESIGNATION_MASTER dg WITH (NOLOCK) on dg.Desig_ID = inc.Desig_Id
					end
				else
					begin
						declare @queryExe as nvarchar(1000)
						set @queryExe = 'select 0 As is_Final_Approved, * from #CandidateApproval where ' + @Constrains 
						exec (@queryExe)					
					end
			end
		else if @Type = 1
			begin
				select count(*) as LoanAppCnt from #CandidateApproval
			end				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #CandidateApproval
END



--ALTER PROCEDURE [dbo].[Get_Candidate_Approval_Record]
--	  @superior as numeric(18,0) 
--	 ,@cmp_id as numeric(18,0)
--	 ,@constraint as varchar(800)=''
--	 ,@orderby  as varchar(800)=''
--AS
--BEGIN
--	declare @emp_id as numeric(18,0)
--	declare @sup_id as numeric(18,0)
--	declare @scheme_id as numeric(18,0)
--	declare @tran_id as numeric(18,0)
--	declare @query as varchar(max)
--	---------------------------
--	declare @is_RM	numeric(18,0)
--	declare @App_empid	numeric(18,0)
--	declare @rpt_level	 int
--	declare @maxrpt int
--	declare @suplevel int
--	declare @prevapprover numeric(18,0)
--	declare @prevsup numeric(18,0)
--	declare @apprcnt int
--	declare @prevapprover1 numeric(18,0)
--	declare @prevstatus int
	
--create table #emp_scheme
--(
--	emp_id			numeric(18,0)
--	,scheme_id		numeric(18,0)
--	,type			varchar(50)
--	,rec_req_id		numeric(18,0)
--)	
--create table #scheme_level
--(
--	scheme_detailid	numeric(18,0)
--	,schemeid		numeric(18,0)	
--	,r_cmp_id		numeric(18,0)
--	,Is_RM			int
--	,Is_BM			int
--	,App_empid		numeric(18,0)
--	,rpt_level		int
--	,Leave			varchar(100)
--	,emp_id			numeric(18,0)
--)	
--create table #final
--(
--	 Tran_ID			numeric(18,0)
--	,Resume_ID			numeric(18,0)
--	,Resume_Status		int
--	,Cmp_ID				numeric(18,0)
--	,Rec_post_Id		numeric(18,0)
--	,Approval_Date		datetime
--	,Comments			varchar(500)
--	,Branch_id			numeric(18,0)
--	,Grd_id				numeric(18,0)	
--	,Desig_id			numeric(18,0)	
--	,Dept_id			numeric(18,0)	
--	,Acceptance			int
--	,Acceptance_Date    datetime
--	,Medical_inspection	int
--	,Police_Incpection	int
--	,Ref_1				varchar(500)
--	,Ref_2				varchar(500)
--	,Joining_date		datetime
--	,Basic_Salay		numeric(18,2)
--	,Login_id			numeric(18,0)
--	,Joining_status		numeric(18,0)
--	,Branch_name		varchar(100)
--	,Grd_Name			varchar(100)
--	,app_full_name		varchar(200)
--	,emp_first_name		varchar(100)
--	,emp_last_name		varchar(100)
--	,Job_Title			varchar(100)
--	,Dept_Name			varchar(100)
--	,Desig_name			varchar(100)
--	,Login_name			varchar(100)
--	,Total_CTC			numeric(18,2)
--	,ReportingManager_Id numeric(18,0)
--	,Rec_Post_code		varchar(100)
--	,BusinessHead		numeric(18,0)
--	,Level2_Approval	int
--	,SalaryCycle_Id		numeric(18,0)
--	,ShiftId			numeric(18,0)
--	,EmploymentTypeId	numeric(18,0)
--	,Name				varchar(100)
--	,Type_name			varchar(100)
--	,Shift_name			varchar(100)
--	,Rec_Post_date		datetime
--	,Rec_start_date		datetime
--	,Rec_End_Date		datetime
--	,BusinessSegment_Id	numeric(18,0)
--	,Vertical_Id		numeric(18,0)
--	,SubVertical_Id		numeric(18,0)
--	,Vertical_Name		varchar(100)
--	,Segment_Name		varchar(100)
--	,SubVertical_Name	varchar(100)
--	,Resume_Code		varchar(100)
--	,Present_Street		varchar(200)
--	,Present_City		varchar(100)
--	,Present_State		varchar(100)
--	,Present_Post_Box	int
--	,Primary_Email		varchar(50)
--	,Assigned_Cmpid		numeric(18,0)
--	,Latter_Format		numeric(18,0)
--	,latterfile_Name	VARCHAR(MAX)
--	,Confirm_Emp_id		numeric(18,0)
--	,Category_Id		numeric(18,0)
--	,Contract_Id		numeric(18,0)
--	,Currency_Id		numeric(18,0)
--	,Relocation_cost	numeric(18,2)
--	,Flight_cost		numeric(18,2)
--	,Accommodation_cost numeric(18,2)
--	,Visa_cost			numeric(18,2)
--	,AnnualLeave_Id		numeric(18,0)
--	,Mobile_No			numeric(18,0)
--	,rpt_level			int
--	,scheme_id			numeric(18,0)
--)

--Declare cur_applicant Cursor
--for		select l.emp_id,r.tran_id
--		from T0060_RESUME_FINAL r left join T0011_LOGIN l on l.Login_ID=r.Login_id 
--		left join t0080_emp_master  e on e.emp_id=l.Login_id 
--		where r.Cmp_id=@cmp_id and acceptance=0 and Resume_Status=1  and l.Emp_ID is not null	
--open cur_applicant
--	fetch next  from cur_applicant into  @emp_id,@tran_id
--	while @@FETCH_STATUS = 0	
--		begin
--			if not exists(select 1 from #emp_scheme where emp_id=@emp_id)
--				begin
--					insert into #emp_scheme(emp_id,scheme_id,type,rec_req_id)
--					--(select @emp_id,Scheme_ID,Type,@tran_id from T0095_EMP_SCHEME where Emp_ID=@emp_id and TYPE='Recruitment' and Effective_Date<= GETDATE())commented By Mukti 16022015
--					 select top 1 es.Emp_ID,es.Scheme_ID,type,Tran_Id from T0095_EMP_SCHEME es
--					 where es.Emp_ID=@emp_id and es.Effective_Date <= (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME 
--					 WHERE Emp_ID = @emp_id  AND effective_date <= getdate() And Type = 'Candidate Approval') 
--					 And es.Type = 'Candidate Approval' order by Tran_Id desc  --Added By Mukti 16022015
					 
--				End
--			fetch next  from cur_applicant into  @emp_id,@tran_id
--		End
--close cur_applicant
--deallocate cur_applicant

----select * from #emp_scheme

--Declare cur_scheme cursor
--for select scheme_id,emp_id from #emp_scheme
--open cur_scheme	
--	fetch next from cur_scheme into @scheme_id,@emp_id	
--	while @@FETCH_STATUS = 0	
--		begin				
--			 insert into #scheme_level(scheme_detailid,schemeid,r_cmp_id,Is_RM,Is_BM,App_empid,rpt_level,Leave,emp_id) 
--			 (select Scheme_Detail_Id,Scheme_Id,R_Cmp_Id,Is_RM,Is_BM,App_Emp_ID,Rpt_Level,Leave,@emp_id
--			  from T0050_Scheme_Detail where Scheme_Id= @scheme_id and Leave='Candidate Approval' )				
--		  fetch next from cur_scheme into @scheme_id,@emp_id
--		End
--close cur_scheme
--deallocate cur_scheme

----select * from #scheme_level

--declare cur_supcheck cursor
--For select schemeid,emp_id,Is_Rm,rpt_level,App_empid from #scheme_level
--open cur_supcheck	
--	fetch next from cur_supcheck into @scheme_id,@emp_id,@is_RM,@rpt_level,@App_empid
--	while @@FETCH_STATUS = 0
--	begin
--		declare cur_suplevel cursor
--			For select r.tran_id
--						from T0060_RESUME_FINAL r left join T0011_LOGIN l on l.Login_ID=r.Login_id 
--						left join t0080_emp_master  e on e.emp_id=l.Login_id 
--						where r.Cmp_id=@cmp_id and acceptance=0 and l.Emp_ID =@emp_id and Resume_Status=1 
--				open cur_suplevel	
--				fetch next from cur_suplevel into @tran_id
--				while @@FETCH_STATUS = 0
--					begin 
--						if @is_RM = 1
--							begin 
--								--select @sup_id = Emp_Superior from T0080_EMP_MASTER where Emp_ID=@emp_id commented By Mukti 14022015
								
--								--Added By Mukti(start)14022015
--									select @sup_id =rd.r_emp_id from t0080_emp_master em 
--									inner join T0090_EMP_REPORTING_DETAIL rd on em.emp_id=rd.emp_id and em.cmp_id=rd.cmp_id
--									and rd.Effect_Date = (SELECT max(Effect_Date) FROM T0090_EMP_REPORTING_DETAIL 
--									WHERE Emp_ID = @emp_id AND effect_date <= getdate())where em.emp_id=@emp_id 
--								--Added By Mukti(end)14022015
								
--								if @sup_id = @superior
--									begin
--										if not exists(select * from T0052_ResumeFinal_Approval where ResumeFinal_ID=@tran_id and Approver_EmpId=@superior)
--											begin
--												insert into #final(Tran_ID,Resume_ID,Resume_Status,Cmp_ID,Rec_post_Id,Approval_Date	,Comments,Branch_id	,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id	,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,Confirm_Emp_id,Category_Id,Contract_Id,Currency_Id,Relocation_cost,Flight_cost,Accommodation_cost,Visa_cost,AnnualLeave_Id,Mobile_No,rpt_level,scheme_id)
--												(select Tran_ID,Resume_ID,Resume_Status,v0060_RESUME_FINAL.Cmp_ID,Rec_post_Id,Approval_Date,Comments,v0060_RESUME_FINAL.Branch_id,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,v0060_RESUME_FINAL.Login_ID,Joining_status,Branch_Name,Grd_Name,app_full_name,Emp_First_Name,Emp_Last_Name,Job_title,Dept_Name,Desig_Name,v0060_RESUME_FINAL.Login_Name,Total_CTC,ReportingManager_Id,Rec_Post_Code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,TYPE_NAME,Shift_Name,Rec_Post_date,Rec_Start_date,Rec_End_date,BusinessSegment_Id,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_email,Assigned_Cmpid,latterfile_Name,0,0,0,0,0,0,0,0,0,0,@rpt_level,@scheme_id  from v0060_RESUME_FINAL left join T0011_LOGIN l on l.Login_ID=v0060_RESUME_FINAL.Login_id where l.Emp_ID=@emp_id and  Acceptance=0 and Tran_ID=@tran_id)
--											End
--									End
--							End
--						Else
--							Begin 
--								if @superior = @App_empid 
--									begin 
--										if @rpt_level = 1
--											begin  
--												if not exists(select * from T0052_ResumeFinal_Approval where ResumeFinal_ID=@tran_id)
--													begin 
--														if not exists(select * from T0052_ResumeFinal_Approval where ResumeFinal_ID=@tran_id and Approver_EmpId=@superior) 
--															begin 
--																insert into #final(Tran_ID,Resume_ID,Resume_Status,Cmp_ID,Rec_post_Id,Approval_Date	,Comments,Branch_id	,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id	,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,Confirm_Emp_id,Category_Id,Contract_Id,Currency_Id,Relocation_cost,Flight_cost,Accommodation_cost,Visa_cost,AnnualLeave_Id,Mobile_No,Latter_Format,rpt_level,scheme_id)
--																(select Tran_ID,Resume_ID,Resume_Status,@Cmp_ID,Rec_post_Id,Approval_Date,Comments,v0060_RESUME_FINAL.Branch_id,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,v0060_RESUME_FINAL.Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,v0060_RESUME_FINAL.Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,0,0,0,0,0,0,0,0,0,0,Latter_Format,@rpt_level,@scheme_id  from v0060_RESUME_FINAL left join T0011_LOGIN l on l.Login_ID=v0060_RESUME_FINAL.Login_id where l.Emp_ID=@emp_id and  Acceptance=0 and Tran_ID=@tran_id)
--															End
--													End
--											End
--										Else 
--											begin
--												select @maxrpt = MAX(Rpt_Level) from T0050_Scheme_Detail where Scheme_Id= @scheme_id 
--												select @apprcnt = COUNT(CanApp_Id) from T0052_ResumeFinal_Approval where  ResumeFinal_ID=@tran_id
--												select @suplevel=Rpt_Level from T0050_Scheme_Detail where Scheme_Id= @scheme_id and App_Emp_ID=@superior
												
																												
--												if @suplevel= @maxrpt 
--													begin
--														if  exists(select * from T0052_ResumeFinal_Approval where ResumeFinal_ID=@tran_id)
--															begin
--																select @prevstatus=CanApp_Status from T0052_ResumeFinal_Approval where CanApp_Id = (select MAX(CanApp_Id) from T0052_ResumeFinal_Approval where ResumeFinal_ID = @tran_id)
																	
--																if  @prevstatus = 1
--																	begin
--																		if (@apprcnt+1)=@maxrpt
--																		begin
--																			insert into #final(Tran_ID,Resume_ID,Resume_Status,Cmp_ID,Rec_post_Id,Approval_Date	,Comments,Branch_id	,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id	,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,Confirm_Emp_id,Category_Id,Contract_Id,Currency_Id,Relocation_cost,Flight_cost,Accommodation_cost,Visa_cost,AnnualLeave_Id,Mobile_No,Latter_Format,rpt_level,scheme_id)
--																			(select Tran_ID,Resume_ID,Resume_Status,@Cmp_ID,Rec_post_Id,Approval_Date,Comments,v0060_RESUME_FINAL.Branch_id,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,v0060_RESUME_FINAL.Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,v0060_RESUME_FINAL.Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,0,0,0,0,0,0,0,0,0,0,Latter_Format,@rpt_level,@scheme_id  from v0060_RESUME_FINAL left join T0011_LOGIN l on l.Login_ID=v0060_RESUME_FINAL.Login_id where l.Emp_ID=@emp_id and  Acceptance=0 and Tran_ID=@tran_id)
																																	
--																		end
--																	End
--															End
--													End
--												Else
--													begin
--														if  exists(select * from T0052_ResumeFinal_Approval where ResumeFinal_ID=@tran_id)
--														begin  
--															select @prevapprover=Approver_EmpId,@prevstatus=CanApp_Status from T0052_ResumeFinal_Approval where CanApp_Id = (select MAX(CanApp_Id) from T0052_ResumeFinal_Approval where ResumeFinal_ID = @tran_id)
																											
--															if  @prevstatus = 1
--																begin 
--																	if (@apprcnt+1) < @maxrpt
--																	begin
--																		if (@apprcnt +1) = @suplevel
--																			begin
--																				if not exists(select * from T0052_ResumeFinal_Approval where ResumeFinal_ID=@tran_id and Approver_EmpId=@superior) 
--																					begin
--																						insert into #final(Tran_ID,Resume_ID,Resume_Status,Cmp_ID,Rec_post_Id,Approval_Date	,Comments,Branch_id	,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id	,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,Confirm_Emp_id,Category_Id,Contract_Id,Currency_Id,Relocation_cost,Flight_cost,Accommodation_cost,Visa_cost,AnnualLeave_Id,Mobile_No,Latter_Format,rpt_level,scheme_id)
--																						(select Tran_ID,Resume_ID,Resume_Status,@Cmp_ID,Rec_post_Id,Approval_Date,Comments,v0060_RESUME_FINAL.Branch_id,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,v0060_RESUME_FINAL.Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,v0060_RESUME_FINAL.Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id	,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,0,0,0,0,0,0,0,0,0,0,Latter_Format,@rpt_level,@scheme_id  from v0060_RESUME_FINAL left join T0011_LOGIN l on l.Login_ID=v0060_RESUME_FINAL.Login_id where l.Emp_ID=@emp_id and  Acceptance=0 and Tran_ID=@tran_id)
--																					End
--																			End
--																	End
--																End
--														End
--													End
--											End
--									End
--							End
--						fetch next from cur_suplevel into @tran_id
--					End
--				close cur_suplevel
--				deallocate cur_suplevel		
--		fetch next from cur_supcheck into @scheme_id,@emp_id,@is_RM,@rpt_level,@App_empid
--	End
--close cur_supcheck
--deallocate cur_supcheck

--set @query='select Tran_ID,Resume_ID,Resume_Status,Cmp_ID,Rec_post_Id,Approval_Date	,Comments,Branch_id	,Grd_id,Desig_id,Dept_id,Acceptance,Acceptance_Date,Medical_inspection,Police_Incpection,Ref_1,Ref_2,Joining_date,Basic_Salay,Login_id,Joining_status,Branch_name,Grd_Name,app_full_name,emp_first_name,emp_last_name,Job_Title,Dept_Name,Desig_name,Login_name,Total_CTC,ReportingManager_Id,Rec_Post_code,BusinessHead,Level2_Approval,SalaryCycle_Id,ShiftId,EmploymentTypeId,Name,Type_name,Shift_name,Rec_Post_date,Rec_start_date,Rec_End_Date,BusinessSegment_Id	,Vertical_Id,SubVertical_Id,Vertical_Name,Segment_Name,SubVertical_Name,Resume_Code,Present_Street,Present_City,Present_State,Present_Post_Box,Primary_Email,Assigned_Cmpid,latterfile_Name,Confirm_Emp_id,Category_Id,Contract_Id,Currency_Id,Relocation_cost,Flight_cost,Accommodation_cost,Visa_cost,AnnualLeave_Id,Latter_Format,Mobile_No,rpt_level,scheme_id from #final'
--	exec(@query + @constraint + @orderby) 
----print(@query + @constraint)
----select * from #final 
----select * from #scheme_level
----select * from #emp_scheme

--drop table #emp_scheme	
--drop table #scheme_level
--End


