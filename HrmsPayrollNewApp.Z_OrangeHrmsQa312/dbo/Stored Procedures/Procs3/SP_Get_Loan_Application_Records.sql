
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Loan_Application_Records]
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
	Declare @Leave As Varchar(500)
	Declare @is_rpt_manager As tinyint
	Declare @is_branch_manager As tinyint
	 
	Declare @SqlQuery As NVarchar(max)
	Declare @SqlExcu As NVarchar(max)
	declare @MaxLevel as numeric(18,0)
	Declare @Rpt_level_Minus_1 As Numeric(18,0)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 31012018
	
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Loan'

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
	 SELECT DISTINCT manger_emp_id,1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) where pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date and Type='Loan'  --Change by Jaina 24-04-2017 
			
	--Select * from #Responsiblity_Passed
		
	CREATE table #tbl_Scheme_Leave 
	 (
		Scheme_ID			Numeric(18,0)
	   ,Leave				Varchar(200) 
	   ,Final_Approver		TinyInt
	   ,Is_Fwd_Leave_Rej	TinyInt
	   ,is_rpt_manager		TinyInt not null default 0
	   ,is_branch_manager	TinyInt not null default 0
	   ,rpt_level			numeric(18,0)
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 31012018
	 )  
	
	CREATE table #tbl_Leave_App
	 (
		Leave_App_ID	Numeric(18,0)
	   ,Scheme_ID		Numeric(18,0)
	   ,Leave			Varchar(200) 
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
		


	CREATE table #Loan
	(
		 Loan_ID				numeric(18,0)
		,Emp_ID					numeric(18,0)
		,Emp_Full_Name			nvarchar(200)
		,Loan_Name				nvarchar(200)
		,Loan_App_Code			nvarchar(100)
		,Loan_Status			nvarchar(100)
		,Senior_Employee		nvarchar(100)
		,Loan_App_ID			numeric(18,0)
		,Emp_first_name			nvarchar(200)
		,Emp_Code				nvarchar(100)
		,Branch_Name			nvarchar(100)
		,Desig_Name				nvarchar(100)
		,Alpha_Emp_code			nvarchar(100)
		,Loan_App_Comments		nvarchar(500)
		,Application_Date		datetime
		,Rpt_Level				numeric(18,0)
		,Scheme_ID				numeric(18,0)
		,Loan					nvarchar(MAX)
		,Final_Approver			TinyInt
		,Is_Fwd_Leave_Rej		TinyInt
		,is_pass_over			tinyint
		,Actual_leave_id		numeric(18,0) 			
		,Branch_id				numeric(18,0)
		,Loan_App_Amount		numeric(18,0)
		,Loan_Apr_Amount		numeric(18,0)
		,Loan_Apr_ID			numeric(18,0)
		)
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Loan')
			BEGIN

					
				IF @Type = 0
					BEGIN
						SELECT * FROM #Loan
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT COUNT(*) as LoanAppCnt from #Loan 
							END
						ELSE
							SELECT COUNT(*) as LoanAppCnt from #Loan 
					END	
						
				RETURN
			END
			
		declare @Emp_ID_Cur numeric(18,0)
		declare @is_res_passed tinyint
		
		set @Emp_ID_Cur = 0
		set @is_res_passed = 0
		
		------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		DECLARE @string_1	VARCHAR(MAX)
 		
 		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)  INNER JOIN 
 			( SELECT MAX(Effect_Date) as Effect_Date,Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) 
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
 																	WHERE R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed)) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) for xml path (''))
		


		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			end	
		

		--Added  by ronakk 09112022
		
		Declare @AppEmp as Numeric(18,0)
		select @AppEmp = AppEmp from T0080_Loan_HycScheme LT
		inner join T0080_DynHierarchy_Value DV on DV.Emp_ID = LT.AppEmp and Dv.DynHierColValue = LT.RptEmp and DV.DynHierColId = LT.DynHierId
		where Dv.DynHierColValue = @Emp_ID 




		Select distinct Tran_ID,ES.Cmp_ID,ES.Emp_ID,ES.Scheme_Id,Type,Effective_Date,IsMakerChecker,RptLevel,DynHierId,LoanTypeId,DynHierarchyId,DynHierColName,DynHierColValue,DynHierColId,IncrementId
		,AppId
		into #TempLoanDH1
		from T0095_EMP_SCHEME ES
		inner join (
			SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T 
			Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
				where Emp_ID = @AppEmp And Type = 'Loan'
			AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID = @AppEmp And Type = 'Loan' AND Effective_Date <= getdate()) 
		) Q on ES.Scheme_Id = Q.Scheme_id
		inner join T0080_Loan_HycScheme LHS on ES.Emp_ID = LHS.AppEmp and  ES.Scheme_ID = LHS.SchemeIId
		Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = LHS.DynHierId and Es.Emp_ID = Dv.Emp_ID  
		where DynHierColValue = @Emp_ID 

		select * into #TempLoanDH from 	#TempLoanDH1  --where IncrementId in (select max(IncrementId) from #TempLoanDH1 group by Scheme_ID )

		--select * from #TempLoanDH1

		--End  by ronakk 09112022


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
						
							    ---Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
								---Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
								---From T0050_Scheme_Detail SD WITH (NOLOCK)  Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								---Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level And SM.Scheme_Type = 'Loan'

							--Added by ronakk 09112022

											
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
											Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Is_RMToRM
											From T0050_Scheme_Detail SD WITH (NOLOCK)
											Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
											inner join #TempLoanDH TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID and tt.RptLevel = @Rpt_level
											Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) 
											and Sd.rpt_level = @Rpt_level And SM.Scheme_Type = 'Loan' and SD.Cmp_Id = @Cmp_ID 
										    union All											 
										    Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
										    From T0050_Scheme_Detail SD WITH (NOLOCK)  Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										    Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level And SM.Scheme_Type = 'Loan'
												
						
										
						   --End by ronakk 09112022


					
						  		

							IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
								BEGIN
								    
									

									SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
			 										Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
														And T0040_Scheme_Master.Scheme_Type = ''Loan'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
									
									EXEC (@string_1)

								

								END
							--Added By Jimit 31012018										
							Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
									BEGIN
										 
										 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
													Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
													And T0040_Scheme_Master.Scheme_Type = ''Loan''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' Commented By Jimit as Cross Company Manager Login not showing application done by cross compny's Employee due to Scheme Id is not passing in the RM to RM's Sp (Dishman case)
										
										  EXEC (@string_1)

										
											
									END					 	 
							--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level)
							--	Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level 
							--	From T0050_Scheme_Detail SD Inner Join T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id
							--	Where  rpt_level = @Rpt_level and Is_RM = 1 And SM.Scheme_Type = 'Loan'
							
							if @Manager_Branch > 0 
								begin
								
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Is_RMToRM)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,SD.Is_RMToRM
										From T0050_Scheme_Detail SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and Is_BM = 1 And SM.Scheme_Type = 'Loan'
							
								end
								
						end
					else
						begin
								Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM)
								Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level,SD.Is_RMToRM
								From T0050_Scheme_Detail  SD WITH (NOLOCK) Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								Where SM.Scheme_Type = 'Loan'
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
									
									--Select * From #tbl_Scheme_Leave where rpt_level = @Rpt_level

									if @is_branch_manager = 1
										begin
										 
												Insert Into #Emp_Cons(Emp_ID)    
													Select ES.Emp_ID 
													From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK) 
														 where Effective_Date<=GETDATE() And Type='Loan'
														 GROUP BY emp_ID) Qry on      
														 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID  And Type='Loan'
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
														'Select LAD.Loan_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0100_LOAN_APPLICATION LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Loan_ID in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE  ' --+ cast(@Emp_ID_Cur as varchar(50)) 
																														+ ' rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + ' AND LAD.Loan_Apr_ID IS NULL And ' + @Constrains	  
														 
													End
												Else
													Begin
														
														
														Set @SqlQuery = 	
														'Select LAD.Loan_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 '  From V0100_LOAN_APPLICATION LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Loan_ID in (Select cast(data  as numeric) 
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
																  And (LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK) 
																											Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																											
																		And LAD.Loan_App_ID In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
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
															T0095_EMP_SCHEME  ES WITH (NOLOCK)  on ES.Emp_ID = ERD.Emp_ID 
														INNER JOIN
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK) 
															 where Effective_Date<=GETDATE()
															 And Type='Loan'
															 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID And Type='Loan'
														Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
												
												DELETE FROM #Emp_Cons 
													WHERE Emp_ID NOT IN (
																	Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
																	INNER JOIN 
																		( select MAX(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN #Emp_Cons EC1 on EC1.Emp_ID = ERD1.Emp_ID 
																			where Effect_Date<=GETDATE() GROUP BY ERD1.emp_ID
																		) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date and R_emp_id = @Emp_ID_Cur
																	INNER JOIN #Emp_Cons EC on EC.Emp_ID = RQry.Emp_ID 
																)	

												If @Rpt_level = 1
													Begin
						
														Set @SqlQuery = 	
														'Select LAD.Loan_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0100_LOAN_APPLICATION LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Loan_ID in (Select cast(data  as numeric)
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
																	  And LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + ' AND LAD.Loan_Apr_ID IS NULL And ' + @Constrains	  
																  
														--print @SqlQuery
													End
												Else
													Begin
														Set @SqlQuery = 	
														'Select LAD.Loan_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0100_LOAN_APPLICATION LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Loan_ID in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE  ' --+ cast(@Emp_ID_Cur as varchar(50))  +
																														+ '  rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																											
																		And LAD.Loan_App_ID In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
												End
												
										end			
										
									---------Added By Jimit 05012018-------------
									
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
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Loan' 										
														
																										
												
													--select * from #EMP_CONS_RM
																		
													
														SET @SqlQuery =	   'Select  Loan_App_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																			FROM	(SELECT LAD.Loan_App_ID,LAD.Loan_Status,Loan_App_Date,LAd.Alpha_Emp_Code,Loan_Name,Emp_First_Name,Loan_App_Amount
																					From	V0100_LOAN_APPLICATION LAD 
																							INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																							LEFT OUTER JOIN (SELECT Loan_App_ID,Emp_ID,S_Emp_ID,Loan_Apr_Status As App_Status FROM T0115_Loan_Level_Approval LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																												ON LAD.Loan_App_ID=LA.Loan_App_ID And LAD.EMP_ID=LA.EMP_ID
																					Where	Loan_Id in (Select cast(data  as numeric) 
																											From dbo.Split (stuff((SELECT ''#'' + Leave  
																																		FROM T0050_Scheme_Detail WITH (NOLOCK)
																																		WHERE		rpt_level = '+ cast(@Rpt_level as varchar(2)) +
																																				+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																																				+ ' And Leave = ''' + @Leave + '''' +
																																			' FOR XML PATH('''')
																																   ),1,1,''''
																																  ),''#''
																															)
																									   ) 	 																							
																							ANd (
																									LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																									'And LAD.Loan_App_ID In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																								')
																							--AND NOT EXISTS(SELECT 1 FROM #tbl_Leave_App T WHERE T.Leave_App_ID=LAD.Loan_App_ID)
																					) T
																			WHERE	1=1  and ' + @Constrains	
																			
																			
																			
											END
													
												
										END
									
									------------Ended-----------------
										
									else if @is_rpt_manager = 0 and @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
										begin

											

												        --Insert Into #Emp_Cons(Emp_ID)    
													    -- --Select Emp_ID 
													    -- --	From T0095_EMP_SCHEME 
													    -- --	Where Scheme_Id = @Scheme_ID
														--Select ES.Emp_ID 
														--From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
														--	(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK) 
														--	 where Effective_Date<=GETDATE() --and Scheme_Id = @Scheme_ID -- max date issue on 12092013 - mitesh
														--	 And Type='Loan'
														--	 --AND Cmp_ID = @Cmp_ID 
														--	 GROUP BY emp_ID) Qry on      
														--	 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID And Type='Loan'
														--Where ES.Scheme_Id = @Scheme_ID 



														--Added  by ronakk 09112022

														
															IF ((SELECT COUNT(1) FROM #TempLoanDH ) > 0)  and  ((SELECT count(1) FROM #TempLoanDH where RptLevel=@Rpt_level ) = 1)
															BEGIN 
																Insert Into #Emp_Cons(Emp_ID) 
													

																Select distinct ES.Emp_ID 
																From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																	 Where Effective_Date<=GETDATE() And Type='Loan'
																	 GROUP BY emp_ID) Qry on      
																	 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date 
																	 and Scheme_Id = @Scheme_ID And Type='Loan'
																inner join T0080_Loan_HycScheme TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
																Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId
																Where ES.Scheme_Id = @Scheme_ID  --and  TTH.RptLevel= @Rpt_level
																union  all
																 Select ES.Emp_ID 
																 From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																  (select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK) 
																  where Effective_Date<=GETDATE() And Type='Loan'
																  GROUP BY emp_ID) Qry on      
																  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID And Type='Loan'
																 Where ES.Scheme_Id = @Scheme_ID
												

																

															END 
															ELSE
															BEGIN
															
																 Insert Into #Emp_Cons(Emp_ID)    
																 Select ES.Emp_ID 
																 From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																  (select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK) 
																  where Effective_Date<=GETDATE() And Type='Loan'
																  GROUP BY emp_ID) Qry on      
																  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID And Type='Loan'
																 Where ES.Scheme_Id = @Scheme_ID
												

															END

														--End by ronakk 09112022
									

																


														
												If @Rpt_level = 1
													Begin
													
													

														Set @SqlQuery = 	
														'Select LAD.Loan_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0100_LOAN_APPLICATION LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Loan_ID in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE  ' --+ cast(@Emp_ID_Cur as varchar(50)) 
																														+ '  rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																	  And LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																  + 'AND LAD.Loan_Apr_ID IS NULL And ' + @Constrains	
																  
										
													End
												Else
													Begin
														
														
													
														Set @SqlQuery = 	
														'Select LAD.Loan_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
															 ' From V0100_LOAN_APPLICATION LAD
																Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
															Where Loan_ID in (Select cast(data  as numeric) 
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE ' -- + cast(@Emp_ID_Cur as varchar(50)) 
																														+ ' rpt_level = ' + cast(@Rpt_level as varchar(2)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(3)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )	   
																  And (LAD.Loan_App_ID Not In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																											
																		And LAD.Loan_App_ID In (Select Loan_App_ID From T0115_Loan_Level_Approval WITH (NOLOCK)
																											Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
																  
																 
												End
												
										end		
										 


									insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										exec (@SqlQuery)


										
									--Added by ronakk 23012023
									if ((select count(1) from #tbl_Leave_App) > 0 )
												Begin
													IF OBJECT_ID(N'tempdb..#temp') IS NOT NULL
													BEGIN
														DROP TABLE #temp
													END

													SELECT *,cast(data  as numeric) as Val into #temp 
													FROM #tbl_Leave_App
													CROSS APPLY dbo.Split(Leave,'#') 
													
	
													IF @is_rpt_manager = 1
													Begin 
															
														DELETE  from #tbl_Leave_App where Leave_App_ID not in(
														select Distinct La.Leave_App_ID from #temp  LA
																inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave
																inner join V0100_LOAN_APPLICATION VAD on LA.Val = VAD.Loan_ID and LA.Leave_App_ID = VAD.Loan_App_ID)
														
													END
													else
													BEGIN 
														  IF @is_Reporting_To_Reporting_manager = 1
														  Begin

																DELETE TA from #temp TA where TA.Val not in (
																		select Distinct VAD.Loan_ID from #temp  LA 
																		inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave 
																		inner join V0100_LOAN_APPLICATION VAD on LA.Val = VAD.Loan_ID and LA.Leave_App_ID = VAD.Loan_App_ID
																)
														END
													END
												END

									--End by ronakk 23012023

							Drop Table #Emp_Cons
							Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
						End
					Close cur_Scheme_Leave
					Deallocate cur_Scheme_Leave
					
			--------------------------
				 set @Rpt_level = @Rpt_level + 1
				End
			End 

			

			--Added by ronakk 23012023

								Set @Rpt_level_Minus_1 = @Rpt_level - 1

								
								If ((Select count(1) from #TempLoanDH ) > 0) and ( (Select RptLevel from #TempLoanDH where RptLevel=@Rpt_level ) = 1) 
								Begin 
								
									IF OBJECT_ID(N'tempdb..#tempLeaveAPP') IS NOT NULL
									BEGIN
										DROP TABLE #tempLeaveAPP
									END
									
						
						
									select * into #tempLeaveAPP 
									from #tbl_Leave_App

									If ((select count(1) from #tempLeaveAPP) > 0)
										Truncate table #tbl_Leave_App
								
									insert into #tbl_Leave_App
									select distinct  LP.* from #tempLeaveAPP LP
									left join T0080_Loan_HycScheme TS 
									on  Lp.Leave_App_ID = TS.AppId and Ts.RptEmp = @Emp_ID
									and LP.Scheme_ID = Ts.SchemeIId
	
									
									Delete LP 
									from #tbl_Leave_App LP inner join T0080_Loan_HycScheme TS 
									on LP.Scheme_ID = TS.SchemeIId 
									and TS.RptEmp = @Emp_ID
									and Lp.Leave_App_ID  in (select AppId from T0080_Loan_HycScheme where RptEmp = @Emp_Id)

								END
								else
								Begin 

								
									if ((select count(1) from #tbl_Leave_App) > 0 )
									Begin
									
										if ((select count(1) from #temp) > 0)
										Begin

										
											IF OBJECT_ID(N'tempdb..#tbl_Leave_App') IS NOT NULL
											BEGIN
												Truncate table #tbl_Leave_App
											END

											INSERT into #tbl_Leave_App
											Select distinct  TL.Leave_App_ID,Tl.Scheme_ID,TL.Leave,TL.rpt_level
											from #temp T 
												inner join  (
													select * from #temp 
												)  TL on t.Val = TL.data and t.Scheme_ID = Tl.Scheme_ID and T.Leave_App_ID = TL.Leave_App_ID
												
													IF Object_ID('tempdb..#EMP_CONS_RM') IS NOT NULL
													Begin
													
														Delete LA from  #tbl_Leave_App LA 
														inner join T0115_Loan_Level_Approval L on LA.Leave_App_ID = L.Loan_App_Id 
														inner join #EMP_CONS_RM EM on EM.Emp_ID = L.Emp_ID
													END
													
										

											DELETE from #temp  where Val not in (
											select Distinct VAD.Loan_ID from #temp  LA 
											inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave 
											inner join V0100_LOAN_APPLICATION VAD on LA.Val = VAD.Loan_ID and LA.Leave_App_ID = VAD.Loan_App_ID)

											
													
										
											--DELETE TA from #tbl_Leave_App TA where TA.Leave not in (select Val from #temp)
										

											DELETE from #temp  where Data not in (
											SELECT Distinct VAD.Loan_ID from #temp  LA 
											inner join V0100_LOAN_APPLICATION VAD on  LA.Leave_App_ID = VAD.Loan_App_ID and LA.Val= LA.Val)
												


											DELETE TA from #tbl_Leave_App TA where TA.Scheme_ID not in (select Scheme_ID from #temp)
											--NEW added by deepal with ronak Date :- 24012023
												Delete LA from  #tbl_Leave_App LA 
												inner join T0115_Loan_Level_Approval L on LA.Leave_App_ID = L.Loan_App_Id 
												and LA.rpt_level = L.Rpt_Level --Added by ronakk 13032023
								            --NEW added by deepal with ronak Date :- 24012023
											

										END
										ELSE
										Begin
											DELETE TA from #tbl_Leave_App TA
											inner join  (
												select Distinct La.Leave_App_ID from #tbl_Leave_App  LA 
												inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave
												inner join V0100_LOAN_APPLICATION VAD on LA.Leave = VAD.Loan_ID and LA.Leave_App_ID = VAD.Loan_App_ID
											) a on TA.Leave_App_ID <> A.Leave_App_ID
										END
									END
								END






			--End by ronakk 23012023


				If @Emp_ID_Cur > 0
					Begin
							
						 	 		 									 
						   insert INTO #Loan
							Select distinct	
								LAD.Loan_ID, LAD.Emp_ID, LAD.Emp_Full_Name, isnull(lm.Loan_Name, LAD.Loan_Name), LAD.Loan_App_Code
								--,Isnull(Qry1.Loan_Apr_Status, LAD.Loan_status) as Loan_status
								,LAD.Loan_status
								, '', LAD.Loan_App_ID, LAD.Emp_first_name, LAD.Emp_Code, LAD.Branch_Name
								,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Loan_App_Comments, LAD.Loan_App_Date
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID, TLAP.Leave, SL.Final_Approver, SL.Is_Fwd_Leave_Rej
								--,isnull(Qry1.From_Date, lad.from_date) as From_Date, isnull(Qry1.To_Date,lad.to_date) as to_date, isnull(Qry1.Leave_Period,lad.Leave_Period) as Leave_Period
								 ,@is_res_passed, Qry1.Loan_Id ,LAD.Branch_ID , LAD.Loan_App_Amount, IsNULL(LAD.Loan_Apr_Amount,0) As Loan_Apr_Amount,LAD.Loan_Apr_ID
								From V0100_LOAN_APPLICATION LAD
									left outer join (select lla.Loan_App_ID As App_ID, Rpt_Level as Rpt_Level , lla.Loan_ID ,lla.Loan_Apr_Status From T0115_Loan_Level_Approval lla WITH (NOLOCK) 
														inner join (Select max(rpt_level) as rpt_level1, Loan_App_ID
																		From T0115_Loan_Level_Approval WITH (NOLOCK)
																		Where Loan_App_ID In (Select Leave_App_ID From #tbl_Leave_App)
																		group by Loan_App_ID 
																	) Qry
														on qry.Loan_App_ID = lla.Loan_App_ID and qry.rpt_level1 = lla.rpt_level
														
													) As Qry1 
									On  LAD.Loan_App_ID = Qry1.App_ID	-- This join is for getting updated from date,to date and leave period in case if any middle approver change it, then next should be see updated info and not old one 
									Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Loan_App_ID
									inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
									left outer join T0040_LOAN_MASTER LM WITH (NOLOCK) on Qry1.Loan_ID = LM.Loan_ID
				 			Where Loan_App_ID In (Select Leave_App_ID From #tbl_Leave_App)	--and LAD.Cmp_ID=@cmp_Id Comment by nilesh on 09102015 For Cross Company 
				 				AND LAD.Loan_Apr_ID IS NULL
					end
				else
					begin
							insert INTO #Loan
							Select distinct	
								 LAD.Loan_ID, LAD.Emp_ID, LAD.Emp_Full_Name,isnull(lm.Loan_Name, LAD.Loan_Name), LAD.Loan_App_Code
								--,Isnull(Qry1.Loan_Apr_Status, LAD.Loan_status) as Loan_status
								,LAD.Loan_status
								, '', LAD.Loan_App_ID, LAD.Emp_first_name, LAD.Emp_Code, LAD.Branch_Name
								,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Loan_App_Comments, LAD.Loan_App_Date
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,'0' as Scheme_ID, '' as Leave,  '1' as Final_Approver, '0' as Is_Fwd_Leave_Rej
								--,isnull(Qry1.From_Date, lad.from_date) as From_Date, isnull(Qry1.To_Date,lad.to_date) as to_date, isnull(Qry1.Leave_Period,lad.Leave_Period) as Leave_Period
								,@is_res_passed , Qry1.Loan_Id ,LAD.Branch_ID, LAD.Loan_App_Amount, IsNULL(LAD.Loan_Apr_Amount,0) As Loan_Apr_Amount,LAD.Loan_Apr_ID
								From V0100_LOAN_APPLICATION	 LAD
									left outer join (select lla.Loan_App_ID As App_ID, Rpt_Level  as Rpt_Level, lla.Loan_ID , lla.Loan_Apr_Status From T0115_Loan_Level_Approval lla WITH (NOLOCK) 
														inner join (Select max(rpt_level) as rpt_level1, Loan_App_ID
																		From T0115_Loan_Level_Approval WITH (NOLOCK)
																		--Where Leave_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
																		group by Loan_App_ID 
																	) Qry
														on qry.Loan_App_ID = lla.Loan_App_ID and qry.rpt_level1 = lla.rpt_level
													) As Qry1 
									On  LAD.Loan_App_ID = Qry1.App_ID
								left outer JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) on Qry1.Loan_ID = LM.Loan_ID
								WHERE
								-- LAD.Cmp_ID = @Cmp_ID  and  Comment by nilesh on 09102015 For Cross Company 
								 (LAD.Loan_status = 'N' or LAD.Loan_status = 'A')
								 
								
						
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
						select 0 As is_Final_Approved,* from #Loan order by #Loan.Application_Date desc
					end
				else
					begin
						declare @queryExe as nvarchar(1000)
						set @queryExe = 'select 0 As is_Final_Approved, * from #Loan where ' + @Constrains + ' order by #Loan.Application_Date desc '
						exec (@queryExe)
					end
			end
		else if @Type = 1
			begin
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(*) as LoanAppCnt from #Loan 
					END
				ELSE
					SELECT COUNT(*) as LoanAppCnt from #Loan 
				
			end				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Loan
		
		 
END



