
CREATE PROCEDURE [dbo].[SP_Get_Claim_Application_Records]
	@Cmp_ID		Numeric(18,5),
	@Emp_ID		Numeric(18,5),
	@Rpt_level	Numeric(18,5),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0,
	@OrderBy	varchar(100)=''
AS
BEGIN
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	
	Declare @Scheme_ID As Numeric(18,5)
	Declare @Leave As Varchar(4000)
	Declare @is_rpt_manager As tinyint
	Declare @is_branch_manager As tinyint
	 
	Declare @SqlQuery As NVarchar(max)
	Declare @SqlExcu As NVarchar(max)
	declare @MaxLevel as numeric(18,5)
	Declare @Rpt_level_Minus_1 As Numeric(18,5)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 18072018
	  
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD INNER JOIN T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Claim'

	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @SqlExcu = ''
	
	CREATE table #Responsiblity_Passed
	 (		 
	     Emp_ID	Numeric(18,5)	
	    ,is_res_passed tinyint default 1  
	 )  
	 
	 insert into #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 insert into #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO where pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date  
			
	CREATE table #tbl_Scheme_Leave 
	 (
		Scheme_ID			Numeric(22,0)
	   ,Leave				Varchar(4000) 
	   ,Final_Approver		Numeric(22,0) default 0
	   ,Is_Fwd_Leave_Rej	Numeric(22,0) 
	   ,is_rpt_manager		TinyInt not null default 0
	   ,is_branch_manager	TinyInt not null default 0
	   ,rpt_level			numeric(18,0)
	   ,Max_Leave_Days		numeric(18,5) --Hardik 07/03/2014
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 18072018
	    ,Is_Intimation		TINYINT NOT NULL DEFAULT 0
	 )  
	
	CREATE table #tbl_Leave_App
	 (
		Leave_App_ID	Numeric(22,0)
	   ,Scheme_ID		Numeric(22,0) DEFAULT 0
	   ,Leave			Varchar(4000) 
	   ,rpt_level		numeric(22,0)
	 )
	 
	 if @Rpt_level > 0
		begin
			set @MaxLevel = @Rpt_level
		end
	else
		begin
			set @Rpt_level = 1
		end
		
	CREATE table #Claim
	(
		 Emp_ID					numeric(22,0)
		,Emp_Full_Name			nvarchar(max)
		,Supervisor				nvarchar(max)
		,S_Emp_ID				numeric(22,0)
		,Claim_App_ID			numeric(18,0)
		,Claim_App_Code			nvarchar(max)
		,Branch_Name			nvarchar(max)
		,Desig_Name				nvarchar(max)
		,Alpha_Emp_code			nvarchar(max)
		,Claim_App_Date			datetime
		,Claim_App_Status		varchar(max)
		--,Claim_Type	varchar(max)
		,Claim_approval_id		numeric(22,0)
		,Rpt_Level				numeric(22,0)
		,Scheme_ID				numeric(22,0)
		,Final_Approver			numeric(22,0)
		,Is_Fwd_Leave_Rej		numeric 
		,Desig_ID				Numeric(22,0)
		,Tran_ID				numeric(22,0)
		,Submit_Flag			numeric
		,Branch_ID				NUMERIC(22,0) --Added by Rajput on 07032018
		,Grd_ID					NUMERIC(22,0) --Added by Rajput on 07032018
		,Attachment				VARCHAR(max) default 'Not-Attached'
		,MobileAttachment		VARCHAR(max)  --Added by Deepal on 14/10/2020
		,Approval_Date			datetime
		,Claim_Name				VARCHAR(max)
		,Is_Intimation		numeric
		,App_Amount			decimal(18,2)
		,Approval_Amount	numeric
		,Claim_Date_Label varchar(500)
		,Claim_Approval_Amount numeric(22,5)
		)
		
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD INNER JOIN T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Claim')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #Claim
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT COUNT(1) AS ClaimAppCnt from #Claim
							END
						ELSE
							SELECT COUNT(1) AS ClaimAppCnt from #Claim
					END	
						
				RETURN
			END
		
		declare @Emp_ID_Cur numeric(18,5)
		declare @is_res_passed tinyint
		
		set @Emp_ID_Cur = 0
		set @is_res_passed = 0
 			
 		------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		DECLARE @string_1	VARCHAR(MAX)
 		
 		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
 			( SELECT MAX(Effect_Date) as Effect_Date,Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL 
 																	WHERE R_Emp_ID = @Emp_ID) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID = @Emp_ID for xml path (''))
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			end	
		
		----
 				
		Declare Employee_Cur Cursor
			For Select distinct Emp_ID,is_res_passed From #Responsiblity_Passed
		Open Employee_Cur
		Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
			Begin
			
				set @Rpt_level = 1
				 
				If @Emp_ID_Cur > 0
					Begin
					
				 	 	declare @Manager_Branch numeric(18,5)
						set @Manager_Branch = 0
						if exists (SELECT 1 from T0095_MANAGERS where Emp_id = @Emp_ID_Cur)
							BEGIN
							
								SELECT @Manager_Branch = branch_id from T0095_MANAGERS where Emp_id = @Emp_ID_Cur AND Effective_date = 
								(
									SELECT max(Effective_date) AS Effective_date from T0095_MANAGERS where Emp_id = @Emp_ID_Cur AND Effective_date <= getdate()
								)
							END
					
		 				WHILE @Rpt_level <= @MaxLevel
							Begin
								 Set @Rpt_level_Minus_1 = @Rpt_level - 1
							
									 If @Emp_ID_Cur > 0
										Begin
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_Intimation)
												Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM,Is_Intimation
												From T0050_Scheme_Detail 
												Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
												Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Claim'
											
											IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
												BEGIN
												
													SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_Intimation)
							 										Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM,Is_Intimation 
																	From T0050_Scheme_Detail 
																	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																	Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(50)) +' and Is_RM = 1 
																		And T0040_Scheme_Master.Scheme_Type = ''Claim'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
													
													EXEC (@string_1)
													
												END
												--Added By Jimit 18072018										
												Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
														BEGIN
															 
															 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM,Is_Intimation)
																		Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM,Is_Intimation
																		From T0050_Scheme_Detail 
																		Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																		Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(50)) +' and Is_RMToRM = 1 
																		And T0040_Scheme_Master.Scheme_Type = ''Claim''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
															
															  EXEC (@string_1)
																
														END		
															 	 
										--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days)
										--	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days
										--	From T0050_Scheme_Detail 
										--	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--	Where  rpt_level = @Rpt_level and Is_RM = 1 And T0040_Scheme_Master.Scheme_Type = 'Claim'
											
										If @Manager_Branch > 0 
											Begin
												Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_Intimation)
													Select distinct T0040_Scheme_Master.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Is_RMToRM,Is_Intimation 
													From T0050_Scheme_Detail 
													Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where rpt_level = @Rpt_level and Is_BM = 1 And T0040_Scheme_Master.Scheme_Type = 'Claim'
											
											End
											
									end
								 Else
									Begin
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Max_Leave_Days,Is_RMToRM,Is_Intimation)
												Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Leave_Days,Is_RMToRM,Is_Intimation
												From T0050_Scheme_Detail 
												Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
												Where T0040_Scheme_Master.Scheme_Type = 'Claim'
									End
									
								 declare @rpt_levle_cur tinyint
								 set @rpt_levle_cur = 0
								 
								
								
								Declare Final_Approver Cursor
									For Select distinct Scheme_Id, Leave,rpt_level From #tbl_Scheme_Leave 
								Open Final_Approver
								Fetch Next From Final_Approver Into @Scheme_ID, @Leave,@rpt_levle_cur
								WHILE @@FETCH_STATUS = 0
									Begin
									 			
										If Exists (Select Scheme_Detail_ID From T0050_Scheme_Detail 
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
												 
												If @is_branch_manager = 1
													Begin
									 					Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME
																 Where Effective_Date<=GETDATE() And Type='Claim'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Claim'
															INNER JOIN 
															(select Branch_ID,I.Emp_ID From T0095_Increment I inner join     
															   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment    
															   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
																I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
																on INC.Emp_ID = Qry.Emp_ID
															Where ES.Scheme_Id = @Scheme_ID and INC.Branch_ID = @Manager_Branch
															
														 
														 
														If @Rpt_level = 1
															Begin
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(50)) +
																	 ' From V0100_CLAIM_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																		INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON  App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(50)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(30)) +'
																	Where (Claim_ID in (select data from dbo.split(T1.leave,''#'')) or (T1.Leave=''0''))																		
																		AND LAD.Claim_App_ID Not In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL Where Rpt_Level = ' + Cast(@Rpt_level as varchar(50)) + ')'  									
																		+ ' And ' + @Constrains 
																 
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Claim_App_ID, ' + Cast(@Scheme_ID As Varchar(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(50)) +
																	 '  From V0100_CLAIM_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																		INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON Is_BM = 1 '
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(50)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(30)) +'
																	Where (Claim_ID in (select data from dbo.split(T1.leave,''#'')) or (T1.Leave=''0''))																		
																	AND (LAD.Claim_App_ID Not In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																								  Where Rpt_Level = ' + Cast(@Rpt_level as varchar(50)) + ')																													
																				And LAD.Claim_App_ID In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(50)) + ')
																			   )'    
																				
																		   + ' And ' + @Constrains
															End
																																				
													End
												Else if @is_rpt_manager = 1
													Begin
													
														--Insert Into #Emp_Cons(Emp_ID)    
														--	Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD 
														--		inner join 
														--			T0095_EMP_SCHEME  ES on ES.Emp_ID = ERD.Emp_ID 
														--		INNER JOIN
														--		(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME
														--		 Where Effective_Date<=GETDATE() And Type='Claim'
														--		 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Claim'
														--		Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID

														Insert Into #Emp_Cons(Emp_ID)    
													Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
														(select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL
															 where Effect_Date<=GETDATE()
															 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
														INNER JOIN 
															T0095_EMP_SCHEME  ES on ES.Emp_ID = ERD.Emp_ID 
														INNER JOIN
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME
															 where Effective_Date<=GETDATE() And Type = 'Claim'--and Scheme_Id = @Scheme_ID -- max date issue on 12092013 - mitesh
															 --AND Cmp_ID = @Cmp_ID 
															 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID And Type = 'Claim'
														Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID      
														
														DELETE FROM #Emp_Cons 
														WHERE Emp_ID NOT IN (
															Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD 
															INNER JOIN 
																( select MAX(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 INNER JOIN #Emp_Cons EC1 on EC1.Emp_ID = ERD1.Emp_ID 
																	where Effect_Date<=GETDATE() GROUP BY ERD1.emp_ID
																) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date and R_emp_id = @Emp_ID_Cur
															INNER JOIN #Emp_Cons EC on EC.Emp_ID = RQry.Emp_ID 
														)
															
														If @Rpt_level = 1
															Begin
																
																Set @SqlQuery = 	
																'Select LAD.Claim_App_ID, ' + Cast(@Scheme_ID As Varchar(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(50)) +
																	 ' From V0100_CLAIM_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																		--INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON  is_RM = 1  And rpt_level = ' + cast(@Rpt_level as varchar(50)) +'																														
																	Where Claim_ID in (Select cast(data  as numeric)
																					From dbo.Split (stuff((SELECT ''#'' + Leave  
																												FROM T0050_Scheme_Detail WITH (NOLOCK)
																												WHERE is_RM = 1 ' 
																														+ ' And rpt_level = ' + cast(@Rpt_level as varchar(50)) +
																														+ ' And Scheme_ID = ' + cast(@Scheme_ID as varchar(30)) +
																														+ ' And Leave = ''' + @Leave + '''' +
																													' FOR XML PATH('''')
																										   ),1,1,''''
																										  ),''#''
																									)
																			   )
																			AND LAD.Claim_App_ID Not In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(50)) + ')'  									
																		  + ' And ' + @Constrains
																	--print @SqlQuery	  
																	
															End
														Else
															Begin
																Set @SqlQuery = 	
																'Select LAD.Claim_App_ID, ' + Cast(@Scheme_ID As Varchar(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(50)) +
																 ' From V0100_CLAIM_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON  T1.App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50)) +' And T1.rpt_level = ' + cast(@Rpt_level as varchar(50)) +'																														
																	Where (Claim_ID in (select data from dbo.split(T1.leave,''#'')) or (T1.Leave=''0''))
																			AND  (LAD.Claim_Application_ID Not In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(50)) + ')
																												
																			And LAD.Claim_App_ID In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(50)) + ')
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
																				   Rpt_Level	NUMERIC
																				) 
																			
																				DECLARE @date as DATETIME
																				SET @date = GETDATE()
																				
																				EXEC SP_RPT_FILL_EMP_CONS_WITH_REPORTING	@Cmp_ID=@Cmp_ID,@From_Date=@date,@To_Date=@date,@Branch_ID=0,
																															@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID = @Emp_ID_Cur,@Constraint='',@Sal_Type = 0,
																															@Salary_Cycle_id = 0,@Segment_Id = 0,@Vertical_Id = 0,@SubVertical_Id = 0,@SubBranch_Id= 0,
																															@New_Join_emp = 0,@Left_Emp = 0,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc	= 0,@Type = 0 ,
																															@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Claim' 										
																				
																			
																				SET @SqlQuery =	   'Select  Claim_App_ID, ' + CAST(@Scheme_ID AS VARCHAR(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(50)) + '
																									FROM	(SELECT LAD.Claim_App_ID,LAD.Claim_App_Status,Claim_App_Date,LAd.Alpha_Emp_Code,Emp_First_Name,Submit_Flag,Claim_Name
																											From	V0100_CLAIM_APPLICATION LAD 
																													INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																													LEFT OUTER JOIN (SELECT Claim_App_ID,Emp_ID,S_Emp_ID,Claim_Apr_Status As App_Status FROM T0115_CLAIM_LEVEL_APPROVAL LA WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(100)) + ') LA 
																																		ON LAD.Claim_App_ID=LA.Claim_App_ID And LAD.EMP_ID=LA.EMP_ID
																													INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON  T1.rpt_level = ' + cast(@Rpt_level as varchar(50)) +
																														+ ' And T1.Scheme_ID = ' + cast(@Scheme_ID as varchar(30)) +'
																											Where (Claim_ID in (select data from dbo.split(T1.leave,''#'')) or (T1.Leave=''0''))																											
																											and (LAD.Claim_App_ID Not In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																															'And LAD.Claim_App_ID In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																														')																										
																											) T
																									WHERE	1=1  and ' + @Constrains	
																	END															
														END												
												------------Ended-----------------
												Else if @is_rpt_manager = 0 and @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
													Begin
														Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME
																 Where Effective_Date<=GETDATE() And Type='Claim'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Claim'
															Where ES.Scheme_Id = @Scheme_ID 
																	
										 				If @Rpt_level = 1
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Claim_App_ID, ' + Cast(@Scheme_ID As Varchar(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(50)) +
																 ' From V0100_CLAIM_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON  T1.App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50))+ ' and T1.rpt_level= ' + cast(@Rpt_level as varchar(50)) +'																														
																Where (Claim_ID in (select data from dbo.split(T1.leave,''#'')) or (T1.Leave=''0''))
																	  And LAD.Claim_App_ID Not In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																									Where Rpt_Level = ' + Cast(@Rpt_level as varchar(50)) + ')'  									
																	  + ' And ' + @Constrains	 
															End
														Else
															Begin
																Set @SqlQuery = 	
																'Select LAD.Claim_App_ID, ' + Cast(@Scheme_ID As Varchar(30)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(50)) +
																 ' From V0100_CLAIM_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	INNER JOIN T0050_Scheme_Detail T1 WITH (NOLOCK) ON T1.App_Emp_Id = ' + cast(@Emp_ID_Cur as varchar(50))  +' and T1.rpt_level= ' + cast(@Rpt_level as varchar(50)) +'																														
																	Where (Claim_ID in (select data from dbo.split(T1.leave,''#'')) or (T1.Leave=''0''))																	
																				and (LAD.Claim_App_ID Not In (Select CLaim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(50)) + ')
																												
																			And LAD.Claim_App_ID In (Select Claim_App_ID From T0115_CLAIM_LEVEL_APPROVAL 
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(50)) + ')
																		   )'    
																			
																	  + ' And ' + @Constrains
															End

															
															
													End		
													 
														
												Insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)												
												exec (@SqlQuery)

												
										
										Drop Table #Emp_Cons
										Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
									End
								Close cur_Scheme_Leave
								Deallocate cur_Scheme_Leave
								
							 set @Rpt_level = @Rpt_level + 1
							End
					End
		
		If @Emp_ID_Cur > 0
					Begin
					
				Insert INTO #Claim
							Select 	Distinct
								LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Emp_Superior,LAD.Claim_App_ID, LAD.Claim_App_Code,LAD.Branch_Name
								,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Claim_App_Date ,LAD.Claim_App_Status
								,LAD.Claim_Approval_id
								--LAD.Claim_apr_id
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, 
								TLAP.Scheme_ID, SL.Final_Approver,SL.Is_Fwd_Leave_Rej
								,Desig_ID,0,LAD.Submit_Flag,LAD.Branch_ID,LAD.Grd_ID,(CASE WHEN ISNULL(LAD.CLAIM_APP_DOC,'') <> '' THEN 'Attached' ELSE 'Not-Attached' END) AS CLAIM_APP_DOC
								,LAD.CLAIM_APP_DOC as MobileAttachment -- Add by deepal for mobile API 14/10/2020
								,Qry1.Approval_Date -- Add by deepal for mobile API 14/10/2020
								,isnull(REVERSE(STUFF(REVERSE((SELECT DISTINCT  CD.Claim_Name + ','
									FROM          V0100_Claim_Application_New_Detail CD WITH (NOLOCK)
									WHERE      CD.Claim_App_ID IN
															   (SELECT     cast(data AS numeric(18, 0))
																 FROM          dbo.Split(ISNULL(LAD.Claim_App_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') 
							,Is_Intimation
							,cast(LAD.Claim_App_Amount as decimal(18,2)) as Claim_App_Amount
							,Claim_Apr_Amount
							,isnull(Claim_Date_Label,'') as Claim_Date_Label
							--,isnull(cla.Claim_Apr_Amnt,0) as Claim_Apr_Amnt
							,0
							From V0100_Claim_Application LAD
								left outer join (select lla.Claim_App_Id As App_ID, Rpt_Level as Rpt_Level , lla.Claim_Apr_Status,Approval_Date,lla.Claim_Apr_Amount From T0115_Claim_LEVEL_APPROVAL lla
													inner join (Select max(rpt_level) as rpt_level1, Claim_App_ID
																	From T0115_Claim_LEVEL_APPROVAL
																	Where Claim_App_ID In (Select Leave_App_ID From #tbl_Leave_App)
																	group by Claim_App_ID 
																) Qry
													on qry.Claim_App_ID = lla.Claim_App_ID and qry.rpt_level1 = lla.rpt_level
													
												) As Qry1 
								On  LAD.Claim_App_ID = Qry1.App_ID
								left outer join
								 #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Claim_App_ID and Claim_ID in (select data from dbo.split(TLAP.leave,'#')) or (TLAP.Leave='0')
								left outer Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID
								---And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level  --or Qry1.Rpt_Level = 0)
								left outer join T0115_CLAIM_LEVEL_APPROVAL_DETAIL cla on cla.Claim_App_ID = Qry1.App_ID
								--inner join T0115_CLAIM_LEVEL_APPROVAL_DETAIL cla on cla.Claim_App_ID = Qry1.App_ID
								Where LAD.Claim_App_ID In (Select Leave_App_ID From #tbl_Leave_App)	
								And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level  --or Qry1.Rpt_Level = 0)
								--and cla.Rpt_Level = Qry1.Rpt_Level
					End
				Else
					Begin
					
						Insert INTO #Claim
							Select distinct	
								LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Emp_Superior,LAD.Claim_App_ID, LAD.Claim_App_Code ,LAD.Branch_Name
								,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Claim_App_Date ,LAD.Claim_App_Status 
								,LAD.Claim_approval_id
								--LAD.Claim_approval_id
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,'0' as Scheme_ID, '1' as Final_Approver, '0' as Is_Fwd_Leave_Rej
								,Desig_ID,0,LAD.Submit_Flag,LAD.Branch_ID,LAD.Grd_ID,
								(CASE WHEN ISNULL(LAD.CLAIM_APP_DOC,'') <> '' THEN 'Attached' ELSE 'Not-Attached' END) AS CLAIM_APP_DOC
							,LAD.CLAIM_APP_DOC as MobileAttachment -- Add by deepal for mobile API 14/10/2020
							,Qry1.Approval_Date -- Add by deepal for mobile API 14/10/2020	
							,isnull(REVERSE(STUFF(REVERSE((SELECT  DISTINCT   CD.Claim_Name + ','
									FROM          V0100_Claim_Application_New_Detail CD WITH (NOLOCK)
									WHERE      CD.Claim_App_ID IN
															   (SELECT     cast(data AS numeric(18, 0))
																 FROM          dbo.Split(ISNULL(LAD.Claim_App_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') ,Is_Intimation,cast(LAD.Claim_App_Amount as decimal(18,2)) as Claim_App_Amount,Claim_Apr_Amount,isnull(Claim_Date_Label,'') as Claim_Date_Label,
														 isnull(cla.Claim_Apr_Amnt,0) as Claim_Apr_Amnt
														 --0
							From V0100_Claim_Application LAD
									left outer join (select lla.Claim_App_ID As App_ID, Rpt_Level  as Rpt_Level,lla.Claim_Apr_Status,Approval_Date,Claim_Apr_Amount From T0115_CLAIM_LEVEL_APPROVAL lla
														inner join (Select max(rpt_level) as rpt_level1, Claim_App_ID
																		From T0115_CLAIM_LEVEL_APPROVAL 
																		group by Claim_App_ID 
																	) Qry
														on qry.Claim_App_ID = lla.Claim_App_ID and qry.rpt_level1 = lla.rpt_level
													) As Qry1 
									On  LAD.Claim_App_ID = Qry1.App_ID
									left outer join
									--INNER JOIN 
									T0115_CLAIM_LEVEL_APPROVAL_DETAIL cla on cla.Claim_App_ID = Qry1.App_ID
									INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON SD.rpt_level= Qry1.Rpt_Level 
									INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id AND SM.Scheme_Type = 'Claim'
									INNER JOIN T0095_EMP_SCHEME ES WITH (NOLOCK) ON ES.Emp_ID = LAD.Emp_ID  
									INNER JOIN(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME
									
									   WHERE Effective_Date<=GETDATE() AND TYPE='Claim'
									   GROUP BY emp_ID) Qry ON ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND ES.Scheme_Id = SD.Scheme_Id      
							WHERE LAD.Cmp_ID = @Cmp_ID and cla.Rpt_Level = Qry1.Rpt_Level
						
					End			
					
						
				delete #tbl_Scheme_Leave
				delete #tbl_Leave_App
				
			
					Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
			End
		Close Employee_Cur
		Deallocate Employee_Cur
			
		declare @queryExe as nvarchar(max)
		

		If @Type = 0
			Begin
				If @Emp_ID_Cur > 0
					Begin						
						set @queryExe ='select  *,claimtbl.claim_app_status as Application_Status from #Claim AS claimtbl where ' + @Constrains + ' ' + @OrderBy --order by #Claim.Claim_App_Date desc						
						exec (@queryExe)						
					End
				Else
					Begin					
						set @queryExe='';						
						set @queryExe = 'select *,claimtbl.claim_app_status as Application_Status from #Claim as claimtbl where ' + @Constrains + ' ' + @OrderBy -- order by #Claim.Claim_App_Date desc 
						exec (@queryExe)						

					End
			End
		Else if @Type = 1
			Begin
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(1) AS ClaimAppCnt from #Claim
					END
				ELSE
					SELECT COUNT(1) AS ClaimAppCnt from #Claim
				
				return
			End				
		--select * from #Claim
	
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Claim
	
END


