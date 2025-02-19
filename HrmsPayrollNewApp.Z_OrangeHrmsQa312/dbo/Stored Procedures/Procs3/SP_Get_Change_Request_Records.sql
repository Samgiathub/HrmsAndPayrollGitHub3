
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Change_Request_Records]
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
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 18072018
	  
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Change Request'

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
	 SELECT DISTINCT manger_emp_id,1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK)
	 where pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date  and Type='Change Request'   --Change by Jaina 14-03-2017
				
	
	CREATE table #tbl_Scheme_Leave 
	 (
		Scheme_ID			Numeric(18,0)
	   ,Leave				Varchar(100) 
	   ,Final_Approver		TinyInt
	   ,Is_Fwd_Leave_Rej	TinyInt
	   ,is_rpt_manager		TinyInt not null default 0
	   ,is_branch_manager	TinyInt not null default 0
	   ,rpt_level			numeric(18,0)
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 18072018
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
		
	Create table #ChangeRequest
	(
		Request_id          numeric(18,0),
		Emp_ID              numeric(18,0),
		Request_Type_id     numeric(18,0),
		Change_Reason       nvarchar(500),
		Request_Date        datetime,
		Shift_From_Date     datetime,
		Shift_To_Date       datetime,
		Curr_Details        nvarchar(Max),
		New_Details         nvarchar(Max),
		Curr_Tehsil 		Varchar(200),
		Curr_District 		Varchar(200),
		Curr_Thana 			Varchar(200),
		Curr_City_Village 	Varchar(200),
		Curr_State 			Varchar(200),
		Curr_Pincode 		Numeric(18,0),
		New_Tehsil 			Varchar(200),
		New_District 		Varchar(200),
		New_Thana 			Varchar(200),
		New_City_Village 	Varchar(200),
		New_State 			Varchar(200),
		New_Pincode 		Numeric(18,0),
		Request_status 		Varchar(200),
		Rpt_Level			numeric(18,0),		
		Scheme_ID			numeric(18,0),
		Leave               nvarchar(MAX),
		Final_Approver		TinyInt,
		Is_Fwd_Leave_Rej	TinyInt,
		is_pass_over		tinyint,
		Request_Type        Varchar(200),
		Alpha_Emp_Code      Varchar(200),
		Emp_Full_Name       Varchar(Max),
		Tran_Id				numeric(18,0),
		Request_Apr_id		numeric(18,0),
		Child_Birth_Date	varchar(25) --Added by Jaina 17-05-2018
	)
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Change Request')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #ChangeRequest
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT COUNT(1) as LoanAppCnt FROM #ChangeRequest 
							END
						ELSE
							SELECT COUNT(1) AS LoanAppCnt FROM #ChangeRequest 
					END	
				RETURN
			END
		
		
		declare @Emp_ID_Cur numeric(18,0)
		declare @is_res_passed tinyint
		DECLARE @string_1	VARCHAR(MAX)
		
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
						
							Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Is_RMToRM
								From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level And SM.Scheme_Type = 'Change Request'
							
													 	 
							Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Is_RMToRM
								From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where  rpt_level = @Rpt_level and Is_RM = 1 And SM.Scheme_Type = 'Change Request'
							
							
							
								--Added By Jimit 18072018										
							IF @Rpt_level = 2 
									BEGIN
										 
										 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
													Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
													And T0040_Scheme_Master.Scheme_Type = ''Change Request''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
										
										  EXEC (@string_1)
											
									END
							
							
							if @Manager_Branch > 0 
								begin
								
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Is_RMToRM)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level ,Is_RMToRM
										From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and Is_BM = 1 And SM.Scheme_Type = 'Change Request'
							
								end
								
						end
					else
						begin
								Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Is_RMToRM
								From T0050_Scheme_Detail  SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where SM.Scheme_Type = 'Change Request'
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
						For Select Scheme_Id, Leave,is_rpt_manager,is_branch_manager,Is_RMToRM From #tbl_Scheme_Leave where rpt_level = @Rpt_level
					Open cur_Scheme_Leave
					Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
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
														 where Effective_Date<=GETDATE() And Type='Change Request'
														 GROUP BY emp_ID) Qry on      
														 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
														 and Scheme_Id = @Scheme_ID  And Type='Change Request'
													INNER join 
													(select Branch_ID,I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
													   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
													   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
														I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
														on INC.Emp_ID = Qry.Emp_ID
													Where ES.Scheme_Id = @Scheme_ID and INC.Branch_ID = @Manager_Branch
													
												If @Rpt_level = 1
													Begin
													
														Set @SqlQuery = 	
														'Select CRA.Request_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0090_Change_Request_Application CRA
																Inner Join #Emp_Cons Ec on CRA.Emp_Id = Ec.Emp_ID
															Where Request_Type_id in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And CRA.Request_id Not In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + ' And ' + @Constrains	  
														 
													End
												Else
													Begin
														
														
														Set @SqlQuery = 	
														'Select CRA.Request_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 '  From V0090_Change_Request_Application CRA
																Inner Join #Emp_Cons Ec on CRA.Emp_Id = Ec.Emp_ID
															Where Request_Type_id in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE Is_BM =  1 ' 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (CRA.Request_id Not In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																											
																		And CRA.Request_id In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK) 
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'    
																		
																   + ' And ' + @Constrains
																  
																 
												End
																																	
										end
									else if @is_rpt_manager = 1
										BEGIN
												 
												Insert Into #Emp_Cons(Emp_ID)    
													Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
														INNER JOIN	--Ankit 28012014
														(select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
															 where Effect_Date<=GETDATE()
															 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
														INNER JOIN 
															T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
														INNER JOIN
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															 where Effective_Date<=GETDATE()
															 And Type='Change Request'
															 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
															 and Scheme_Id = @Scheme_ID And Type='Change Request'
														Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
												
												If @Rpt_level = 1
													Begin
														
														Set @SqlQuery = 	
														'Select CRA.Request_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0090_Change_Request_Application CRA
																Inner Join #Emp_Cons Ec on CRA.Emp_Id = Ec.Emp_ID
															Where Request_Type_id in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE is_RM = 1 ' 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And CRA.Request_id Not In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + ' And ' + @Constrains	  
																  
														
													End
												Else
													Begin
														Set @SqlQuery = 	
														'Select CRA.Request_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0090_Change_Request_Application CRA
																Inner Join #Emp_Cons Ec on CRA.Emp_Id = Ec.Emp_ID
															Where Request_Type_id in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50))  +
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (CRA.Request_id Not In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																											
																		And CRA.Request_id In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
												End
												
										end		
										
									---------Added By Jimit 18072018-------------
									
									ELSE IF @is_Reporting_To_Reporting_manager = 1 and @Rpt_level = 2
											BEGIN
												
												
										IF @Rpt_level = 2
											BEGIN											
												
												
												IF Object_ID('tempdb..#EMP_CONS_RM') IS NOT NULL
													DROP TABLE #EMP_CONS_RM
													
														
														CREATE TABLE #EMP_CONS_RM 
														(
														   Emp_ID		NUMERIC,
														   BRANCH_ID	NUMERIC,
														   INCREMENT_ID NUMERIC,
														   R_EMP_ID		NUMERIC DEFAULT 0 ,
														   Scheme_ID	NUMERIC ,
														   Rpt_Level	TinyINT
														) 
													
														DECLARE @date as DATETIME
														SET @date = GETDATE()
														
														EXEC SP_RPT_FILL_EMP_CONS_WITH_REPORTING	@Cmp_ID=@Cmp_ID,@From_Date=@date,@To_Date=@date,@Branch_ID=0,
																									@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID = @Emp_ID_Cur,@Constraint='',@Sal_Type = 0,
																									@Salary_Cycle_id = 0,@Segment_Id = 0,@Vertical_Id = 0,@SubVertical_Id = 0,@SubBranch_Id= 0,
																									@New_Join_emp = 0,@Left_Emp = 0,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc	= 0,@Type = 0 ,
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Change Request' 										
														
														
														
														SET @SqlQuery =	   'Select  Request_id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																			FROM	(SELECT LAD.Request_id,LAD.Request_status,Request_Date,LAd.Alpha_Emp_Code,Emp_First_Name,LAd.Status
																					From	V0090_Change_Request_Application LAD 
																							INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																							LEFT OUTER JOIN (SELECT Request_id,Emp_ID,S_Emp_ID,Request_Apr_Status As App_Status FROM T0115_Request_Level_Approval LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																												ON LAD.Request_id=LA.Request_id And LAD.EMP_ID=LA.EMP_ID
																					Where	 (LAD.Request_id Not In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																							'And LAD.Request_id In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																								') 
																								and Request_Type_id in (Select cast(data  as numeric) 
																												From dbo.Split (stuff((SELECT ''#'' + Leave  
																																			FROM T0050_Scheme_Detail WITH (NOLOCK)
																																			WHERE   rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																																					+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																																					+ ' And Leave = ''' + @Leave + '''' +
																																				' FOR XML PATH('''')
																																	   ),1,1,''''
																																	  ),''#''
																																)
																										   )																							   																							  
																							--AND NOT EXISTS(SELECT 1 FROM #tbl_Leave_App T WHERE T.Request_id=LAD.Request_id)
																					) T
																			WHERE	1=1  and ' + @Constrains	
																			
																			
																	   
																		--print @SqlQuery
																			
																
												
											END
													
												
										END
									
									------------Ended-----------------
											
									else if @is_rpt_manager = 0 and @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
										begin
												 
												Insert Into #Emp_Cons(Emp_ID)    
												
														Select ES.Emp_ID 
														From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
															(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															 where Effective_Date<=GETDATE() 
															 And Type='Change Request'
															 GROUP BY emp_ID) Qry on      
															 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      
															 and Scheme_Id = @Scheme_ID And Type='Change Request'
														Where ES.Scheme_Id = @Scheme_ID 
														
											 	 
												If @Rpt_level = 1
													Begin
														
														Set @SqlQuery = 	
														'Select CRA.Request_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0090_Change_Request_Application CRA
																Inner Join #Emp_Cons Ec on CRA.Emp_Id = Ec.Emp_ID
															Where Request_Type_Id in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And CRA.Request_Id Not In (Select Request_Id From T0115_Request_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + ' And ' + @Constrains	
																  
															
													End
												Else
													Begin
														
														
														Set @SqlQuery = 	
														'Select CRA.Request_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0090_Change_Request_Application CRA
																Inner Join #Emp_Cons Ec on CRA.Emp_Id = Ec.Emp_ID
															Where Request_Type_id in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (CRA.Request_id Not In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																											
																		And CRA.Request_id In (Select Request_id From T0115_Request_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
														
														   
																 
												End
												
										end		
										 
										
									insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
									exec (@SqlQuery)
									 		
									
								
							Drop Table #Emp_Cons
							Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
						End
					Close cur_Scheme_Leave
					Deallocate cur_Scheme_Leave
					
			--------------------------
				 set @Rpt_level = @Rpt_level + 1
				End
			End 
			
				If @Emp_ID_Cur > 0
					Begin
							
						 	 		 									 
						  insert INTO #ChangeRequest
							Select distinct	
							CRA.Request_id,
													CRA.Emp_ID,
													CRA.Request_Type_id,
													CRA.Change_Reason,
													CRA.Request_Date,
													CRA.Shift_From_Date,
													CRA.Shift_To_Date,
													CRA.Curr_Details,
													CRA.New_Details,
													CRA.Curr_Tehsil,
													CRA.Curr_District,
													CRA.Curr_Thana,
													CRA.Curr_City_Village,
													CRA.Curr_State,
													CRA.Curr_Pincode,
													CRA.New_Tehsil,
													CRA.New_District,
													CRA.New_Thana,
													CRA.New_City_Village,
													CRA.New_State,
													CRA.New_Pincode,
													--CRA.Status
													(case when CRA.Status = 'P' Then 'Pending' when CRA.Status = 'A' then 'Approved' when CRA.Status = 'R' then 'Rejected'  End)
													,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, 
													TLAP.Scheme_ID,
													TLAP.Leave, 
													SL.Final_Approver, 
													SL.Is_Fwd_Leave_Rej,
													@is_res_passed,
													CRA.Request_type,
													CRA.Alpha_Emp_Code,
													CRA.Emp_Full_Name,
													0,
													0,
													CRA.Child_Birth_Date
													From V0090_Change_Request_Application CRA
													left outer join (
													select RLA.Request_id As App_ID, 
														   Rpt_Level as Rpt_Level , 
														   RLA.Request_Type_id,
														   RLA.Request_Apr_Status
														   From T0115_Request_Level_Approval RLA WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, Request_id
																		From T0115_Request_Level_Approval WITH (NOLOCK)
																		Where Request_id In (Select Leave_App_ID From #tbl_Leave_App)
																		group by Request_id
																	) Qry
														on qry.Request_id = RLA.Request_id and qry.rpt_level1 = RLA.rpt_level
														
													) As Qry1 
									On  CRA.Request_id = Qry1.App_ID	
									Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = CRA.Request_id
									inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level 
									--left outer join T0040_LOAN_MASTER LM on Qry1.Loan_ID = LM.Loan_ID
				 			Where Request_id In (Select Leave_App_ID From #tbl_Leave_App)	
					end
				 else
					begin
						
						 insert INTO #ChangeRequest
							Select distinct	
							CRA.Request_id,
													CRA.Emp_ID,
													CRA.Request_Type_id,
													CRA.Change_Reason,
													CRA.Request_Date,
													CRA.Shift_From_Date,
													CRA.Shift_To_Date,
													CRA.Curr_Details,
													CRA.New_Details,
													CRA.Curr_Tehsil,
													CRA.Curr_District,
													CRA.Curr_Thana,
													CRA.Curr_City_Village,
													CRA.Curr_State,
													CRA.Curr_Pincode,
													CRA.New_Tehsil,
													CRA.New_District,
													CRA.New_Thana,
													CRA.New_City_Village,
													CRA.New_State,
													CRA.New_Pincode,
													--CRA.Status
													(case when CRA.Status = 'P' Then 'Pending' when CRA.Status = 'A' then 'Approved' when CRA.Status = 'R' then 'Rejected'  End)
													,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, 
													TLAP.Scheme_ID,
													TLAP.Leave, 
													SL.Final_Approver, 
													SL.Is_Fwd_Leave_Rej,
													@is_res_passed,
													CRA.Request_type,
													CRA.Alpha_Emp_Code,
													CRA.Emp_Full_Name,
													0,
													0,
													CRA.Child_Birth_Date
													From V0090_Change_Request_Application CRA
													left outer join (
													select RLA.Request_id As App_ID, 
														   Rpt_Level as Rpt_Level , 
														   RLA.Request_Type_id,
														   RLA.Request_Apr_Status
														   From T0115_Request_Level_Approval RLA WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, Request_id
																		From T0115_Request_Level_Approval WITH (NOLOCK)
																		Where Request_id In (Select Leave_App_ID From #tbl_Leave_App)
																		group by Request_id 
																	) Qry
														on qry.Request_id = RLA.Request_id and qry.rpt_level1 = RLA.rpt_level
														
													) As Qry1 
									On  CRA.Request_id = Qry1.App_ID
								WHERE
								 CRA.Cmp_ID = @Cmp_ID  and (CRA.status = 'N' or CRA.status = 'A')
						
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
						select 0 As is_Final_Approved,* from #ChangeRequest order by #ChangeRequest.Request_Date desc 
					end
				else
					begin
						declare @queryExe as nvarchar(1000)
						set @queryExe = 'select 0 As is_Final_Approved, * from #ChangeRequest where ' + @Constrains + ' order by #ChangeRequest.Request_Date desc '  
						exec (@queryExe)
					END
			END
		ELSE IF @Type = 1
			BEGIN
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(1) as LoanAppCnt FROM #ChangeRequest 
					END
				ELSE
					SELECT COUNT(1) AS LoanAppCnt FROM #ChangeRequest 
				
			END				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #ChangeRequest
		
		 
END


