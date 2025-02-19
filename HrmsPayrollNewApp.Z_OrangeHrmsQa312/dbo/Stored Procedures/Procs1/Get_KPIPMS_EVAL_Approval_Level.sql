


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Get_KPIPMS_EVAL_Approval_Level 9,1353,1,'LAD.KPIPMS_Status =0',0
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_KPIPMS_EVAL_Approval_Level]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  	Declare @Scheme_ID As Numeric(18,0)
	Declare @Leave As Varchar(100)
	Declare @is_rpt_manager As tinyint
	Declare @is_branch_manager As tinyint
	 
	Declare @SqlQuery As NVarchar(max)
	Declare @SqlExcu As NVarchar(max)
	declare @MaxLevel as numeric(18,0)
	Declare @Rpt_level_Minus_1 As Numeric(18,0)
	  
	set @MaxLevel =5
	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @SqlExcu = ''
	
	
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
		
		
	Create table #Appraisal
	(
		KPIPMS_ID					numeric(18,0)
		,Emp_ID						numeric(18,0)
		,Emp_Full_Name				nvarchar(200)
		,KPIPMS_Status				int
		,FinancialYr				int
		,KPIPMS_Type				int
		,KPIPMS_Name				varchar(50)
		,KPIPMS_FinalRating			varchar(500)
		,KPIPMS_SupEarlyComment		varchar(500)
		,Manager_Score				numeric(18,2) --added on 26 Mar 2015
		,KPIMPS_SupAppOn			datetime
		,Rpt_Level					numeric(18,0)
		,Scheme_ID					numeric(18,0)	
		,Final_Approver				TinyInt
		,Is_Fwd_Leave_Rej			TinyInt
		,is_pass_over				tinyint
		,Alpha_Emp_Code				Varchar(200)		
		,Tran_Id					numeric(18,0)
		,Request_Apr_id				numeric(18,0)
	)
	
		declare @Emp_ID_Cur numeric(18,0)
		declare @is_res_passed tinyint
		
		set @Emp_ID_Cur = 0
		set @is_res_passed = 0
		
				
		Declare Employee_Cur Cursor
			For Select distinct Emp_ID,is_res_passed From #Responsiblity_Passed
		Open Employee_Cur
		Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
			Begin
			
			set @Rpt_level = 1
			
			If @Emp_ID_Cur > 0
				Begin
			 	 
	 	 			declare @Manager_Branch numeric(18,0)
					set @Manager_Branch = 0
					if exists (SELECT 1 from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur)
						BEGIN
							SELECT @Manager_Branch = branch_id from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur AND Effective_date = 
							(
								SELECT max(Effective_date) AS Effective_date from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur AND Effective_date <= getdate()
							)
						END
				
		 
			 	
				WHILE @Rpt_level <= @MaxLevel
					Begin
				 		
				 Set @Rpt_level_Minus_1 = @Rpt_level - 1
				
					 if @Emp_ID_Cur > 0
						begin

							Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level 
								From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level And SM.Scheme_Type = 'Appraisal Review'
							
													 	 
							Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level 
								From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where  rpt_level = @Rpt_level and Is_RM = 1 And SM.Scheme_Type = 'Appraisal Review'
							
							
							
							if @Manager_Branch > 0 
								begin
								
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level 
										From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and Is_BM = 1 And SM.Scheme_Type = 'Appraisal Review'
							
								end
								
						end
					else
						begin
								Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level 
								From T0050_Scheme_Detail  SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where SM.Scheme_Type = 'Appraisal Review'
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
											Where Scheme_Id = @Scheme_ID And Leave = @Leave And Rpt_Level = @Rpt_level + 1 AND NOT_MANDATORY = 0)
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
						For Select Scheme_Id, Leave,is_rpt_manager,is_branch_manager From #tbl_Scheme_Leave where rpt_level = @Rpt_level
					Open cur_Scheme_Leave
					Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager
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
														 where Effective_Date<=GETDATE() And Type='Appraisal Review'
														 GROUP BY emp_ID) Qry on      
														 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
														 and Scheme_Id = @Scheme_ID  And Type='Appraisal Review'
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
														'Select LAD.KPIPMS_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0080_KPIPMS_Eval LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where LAD.KPIPMS_ID Not In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																		Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																	  + ' And ' + @Constrains   
														 
													End
												Else
													Begin	 										
														Set @SqlQuery = 	
														'Select LAD.KPIPMS_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 '  From V0080_KPIPMS_Eval LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where (LAD.KPIPMS_ID Not In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																													
																				And LAD.KPIPMS_ID In (Select T0090_KPIPMS_EVAL_Approval WITH (NOLOCK) From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																			   )'    
																				
																		   + ' And ' + @Constrains
																  
																 
												End
																																	
										end
									else if @is_rpt_manager = 1
										BEGIN	
												Insert Into #Emp_Cons(Emp_ID)    
													Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
														(select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
															 where Effect_Date<=GETDATE()
															 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
														inner join 
															T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
														INNER JOIN
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															 where Effective_Date<=GETDATE()
															 And Type='Appraisal Review'
															 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
															 and Scheme_Id = @Scheme_ID And Type='Appraisal Review'
														Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
												
												If @Rpt_level = 1 
													Begin 
						
														Set @SqlQuery = 	
														'Select LAD.KPIPMS_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0080_KPIPMS_Eval LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																		Where LAD.KPIPMS_ID Not In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																					Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains	  
																  
													
													End
												Else
													Begin  
														Set @SqlQuery = 	
														'Select LAD.KPIPMS_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0080_KPIPMS_Eval LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.KPIPMS_ID Not In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																			And LAD.KPIPMS_ID In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																			
																	  + ' And ' + @Constrains
												End
												
										end			
									else if @is_rpt_manager = 0 and @is_branch_manager = 0
										begin 
												Insert Into #Emp_Cons(Emp_ID)   
														Select ES.Emp_ID 
														From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
															(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															 where Effective_Date<=GETDATE() 
															 And Type='Appraisal Review'
															 GROUP BY emp_ID) Qry on      
															 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
															 and Scheme_Id = @Scheme_ID And Type='Appraisal Review'
														Where ES.Scheme_Id = @Scheme_ID 
														
											 	 
												If @Rpt_level = 1
													Begin	 										
														Set @SqlQuery = 	
														'Select LAD.KPIPMS_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0080_KPIPMS_Eval LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where LAD.KPIPMS_ID Not In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																							Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																	  + ' And ' + @Constrains	
																  
															
													End
												Else
													Begin												
														Set @SqlQuery = 	
														'Select LAD.KPIPMS_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0080_KPIPMS_Eval LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.KPIPMS_ID Not In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																												
																			And LAD.KPIPMS_ID In (Select KPIPMS_ID From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																			
																	  + ' And ' + @Constrains
												End
												
										end		
										 
									--print (@SqlQuery)
									insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										exec (@SqlQuery)
									
								
							Drop Table #Emp_Cons
							Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager
						End
					Close cur_Scheme_Leave
					Deallocate cur_Scheme_Leave
					
			--------------------------
				 set @Rpt_level = @Rpt_level + 1
				End
			End 
			
				If @Emp_ID_Cur > 0
					Begin	
											 
						  insert INTO #Appraisal
									Select distinct	
										ekpi.KPIPMS_ID,	
										ekpi.Emp_ID,
										ekpi.Emp_Full_Name,
										--(case when ekpi.KPIPMS_Status = 0 Then '3' when ekpi.KPIPMS_Status = 4 then 'Approved' when ekpi.KPIPMS_Status = 1 then 'Rejected'  End),
										ekpi.KPIPMS_Status,
										ekpi.KPIPMS_FinancialYr,
										ekpi.KPIPMS_Type,
										ekpi.KPIPMS_Name,
										ekpi.KPIPMS_FinalRating,
										ekpi.KPIPMS_SupEarlyComment,
										ekpi.KPIPMS_ManagerScore, --added on 26 Mar 2015
										ekpi.KPIMPS_SupAppOn,										
										isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,
										TLAP.Scheme_ID,
										SL.Final_Approver, 
										SL.Is_Fwd_Leave_Rej,
										@is_res_passed,
										ekpi.Alpha_Emp_Code,
										0,
										0
									From V0080_KPIPMS_Eval ekpi
										left outer join (
										select RLA.KPIPMS_ID As App_ID, 
											   Rpt_Level as Rpt_Level , 
											   RLA.approval_Status
											   From T0090_KPIPMS_EVAL_Approval RLA WITH (NOLOCK)
											inner join (Select max(rpt_level) as rpt_level1, KPIPMS_ID
															From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
															Where KPIPMS_ID In (Select Leave_App_ID From #tbl_Leave_App)
															group by KPIPMS_ID
														) Qry
											on qry.KPIPMS_ID = RLA.KPIPMS_ID and qry.rpt_level1 = RLA.rpt_level
											
										) As Qry1 
						On  ekpi.KPIPMS_ID = Qry1.App_ID	
						Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = ekpi.KPIPMS_ID
						inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level
						Where KPIPMS_ID In (Select Leave_App_ID From #tbl_Leave_App)	--and (ekpi.KPIPMS_Status = 4 or ekpi.KPIPMS_Status = 1)
					end
				 else
					begin
						
						 insert INTO #Appraisal
							Select distinct	
													ekpi.KPIPMS_ID,
													ekpi.Emp_ID,
													ekpi.Emp_Full_Name	,
													--(case when ekpi.KPIPMS_Status = 3 Then 'Pending' when ekpi.KPIPMS_Status = 4 then 'Approved' when ekpi.KPIPMS_Status = 1 then 'Rejected'  End),
													ekpi.KPIPMS_Status,
													ekpi.KPIPMS_FinancialYr,
													ekpi.KPIPMS_Type,
													ekpi.KPIPMS_Name,
													ekpi.KPIPMS_FinalRating,
													ekpi.KPIPMS_SupEarlyComment	,
													ekpi.KPIPMS_ManagerScore,	--added on 26 mar 2015
													ekpi.KPIMPS_SupAppOn,													
													isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,
													'0' as Scheme_ID, 
													'1' as Final_Approver, 
													'0' as Is_Fwd_Leave_Rej	,	
													@is_res_passed,
													ekpi.Alpha_Emp_Code,
													0,
													0						
													From  V0080_KPIPMS_Eval ekpi
													left outer join (
													select RLA.KPIPMS_ID As App_ID, 
														   Rpt_Level as Rpt_Level , 
														   RLA.approval_Status
														   From T0090_KPIPMS_EVAL_Approval RLA WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, KPIPMS_ID
																		From T0090_KPIPMS_EVAL_Approval WITH (NOLOCK)
																		Where KPIPMS_ID In (Select Leave_App_ID From #tbl_Leave_App)
																		group by KPIPMS_ID 
																	) Qry
														on qry.KPIPMS_ID = RLA.KPIPMS_ID and qry.rpt_level1 = RLA.rpt_level
														
													) As Qry1 
									On  ekpi.KPIPMS_ID = Qry1.App_ID
								WHERE
								 ekpi.Cmp_ID = @Cmp_ID  and (ekpi.KPIPMS_Status = 4 or ekpi.KPIPMS_Status = 1)
						
					end	
					
				delete #tbl_Scheme_Leave
				delete #tbl_Leave_App
					Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
			end 
		Close Employee_Cur
		Deallocate Employee_Cur
		
		if @Type = 0
			begin
				
				If @Emp_ID_Cur > 0
					Begin
						select 0 As is_Final_Approved,* from #Appraisal 
					end
				else
					begin
						declare @queryExe as nvarchar(1000)
						set @queryExe = 'select 0 As is_Final_Approved, * from #Appraisal where ' + @Constrains 
						exec (@queryExe)
					end
			end
		else if @Type = 1
			begin
				select count(*) as LoanAppCnt from #Appraisal
			end				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Appraisal
END


