

CREATE PROCEDURE [dbo].[SP_Get_PreCompOff_Application_Records]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0,
	@Items_Per_Page numeric(18,0)= 15, --Mukti(13092016)for sorting
	@Page_No numeric(18,0)=1--Mukti(13092016)for sorting
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	Declare @Scheme_ID As Numeric(18,0)
	Declare @Leave As Varchar(100)
	Declare @is_rpt_manager As tinyint
	Declare @is_branch_manager As tinyint
	 
	Declare @SqlQuery As NVarchar(max)
	Declare @SqlExcu As NVarchar(max)
	declare @MaxLevel as numeric(18,0)
	Declare @Rpt_level_Minus_1 As Numeric(18,0)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 05062018
	 
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Pre-CompOff'

	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @SqlExcu = ''
	
	CREATE table #Responsiblity_Passed
	 (		 
	     Emp_ID	Numeric(18,0)	
	    ,is_res_passed tinyint default 1  
	 )  
	 
	 insert into #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 insert into #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 
	 from T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK)
	 where pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date and Type='Pre Comp Off'    --Change by Jaina 14-03-2017
	
	
	 
	CREATE table #tbl_Scheme_Leave 
	 (
		Scheme_ID			Numeric(18,0)
	   ,Leave				Varchar(100) 
	   ,Final_Approver		TinyInt
	   ,Is_Fwd_Leave_Rej	TinyInt
	   ,is_rpt_manager		TinyInt not null default 0
	   ,is_branch_manager	TinyInt not null default 0
	   ,rpt_level			numeric(18,0)
	   ,Max_Leave_Days		numeric(18,2) --Hardik 07/03/2014
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 05062018
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
	
	--Create Table #Pre_ComOff_Application
	--(
	--   [Tran_ID] numeric(18,0) default 0
 --     ,[PreCompOff_App_ID] numeric(18,0)
 --     ,[Emp_ID] numeric(18,0)
 --     ,[From_Date] datetime
 --     ,[To_Date] datetime
 --     ,[Period] numeric(18,2)
 --     ,[Remarks] nvarchar(max)
 --     ,[Approval_Status] char(1)
 --     ,[RPT_Level]   tinyint
 --     ,[Is_FWD_REJECT] tinyint
	--)	
		
	CREATE table #Pre_ComOff_Application
	(
		 Tran_ID					numeric(18,0)		
		 ,Emp_ID					numeric(18,0)
		,Emp_Full_Name			nvarchar(200)
		,Emp_First_Name			nvarchar(200)
		,S_Emp_ID				nvarchar(100)
		,PreCompOff_App_ID		numeric(18,0)
		,PreCompOff_App_date	datetime
		,Alpha_Emp_code			nvarchar(100)
		,From_Date				datetime
		,To_Date				datetime
		,Period					numeric(18,2)
		,Remarks				nvarchar(max)
		,App_Status				Char(1)
		,Rpt_Level				numeric(18,0)
		,Scheme_ID				numeric(18,0)
		,Final_Approver			TinyInt
		,Is_Fwd_Rej				TinyInt
		,Branch_Id				Varchar(max)  --Added By Jaina 04-09-2015
		,Vertical_Id  numeric(18,0)  --Added By Jaina 1-10-2015
		,Subvertical_Id numeric(18,0) --Added By Jaina 1-10-2015
		,Dept_Id numeric(18,0) --Added By Jaina 1-10-2015
		)
		
			--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Pre-CompOff')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #Pre_ComOff_Application
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT count(1) as PreCompOffAppCnt from #Pre_ComOff_Application 
							END
						ELSE
							SELECT count(1) as PreCompOffAppCnt from #Pre_ComOff_Application 
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
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 			( SELECT MAX(Effect_Date) as Effect_Date,Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) 
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
 																	WHERE R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) /*@Emp_ID*/) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) --@Emp_ID 
		for xml path (''))
		
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			end	
		ELSE
			BEGIN
				SET @Emp_Cmp_Id = @Cmp_ID
			END	
		
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
							
								 If @Emp_ID_Cur > 0
									Begin
										Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
											Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
											From T0050_Scheme_Detail WITH (NOLOCK)
											Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
											Where App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Pre-CompOff'
											--Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Pre-CompOff'
												
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
											BEGIN
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
			 													Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
																	And T0040_Scheme_Master.Scheme_Type = ''Pre-CompOff'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
									
												EXEC (@string_1)
												
											END	
									
										--Added By Jimit 05062018										
										Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
												BEGIN
													 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
																Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
																And T0040_Scheme_Master.Scheme_Type = ''Pre-CompOff''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
													
													  EXEC (@string_1)
														
												END	
											
											
																 	 
										--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days)
										--	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days
										--	From T0050_Scheme_Detail 
										--	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--	Where  rpt_level = @Rpt_level and Is_RM = 1 And T0040_Scheme_Master.Scheme_Type = 'Pre-CompOff'
											
										If @Manager_Branch > 0 
											Begin
												Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
													Select distinct T0040_Scheme_Master.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where rpt_level = @Rpt_level and Is_BM = 1 And T0040_Scheme_Master.Scheme_Type = 'Pre-CompOff'
												
											End
												
									end
								 Else
									Begin
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Max_Leave_Days,Is_RMToRM)
												Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Leave_Days,Is_RMToRM
												From T0050_Scheme_Detail WITH (NOLOCK) 
												Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
												Where T0040_Scheme_Master.Scheme_Type = 'Pre-CompOff'
									End
									
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
												 --Select Scheme_Id, Leave,is_rpt_manager,is_branch_manager From #tbl_Scheme_Leave where rpt_level = @Rpt_level
												If @is_branch_manager = 1
													Begin
									 					Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Pre-CompOff'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Pre-CompOff'
															INNER JOIN 
															(select Branch_ID,I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
															   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)  
															   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
																I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
																on INC.Emp_ID = Qry.Emp_ID
															Where ES.Scheme_Id = @Scheme_ID and INC.Branch_ID = @Manager_Branch
															
														 
														
														If @Rpt_level = 1
															Begin
																Set @SqlQuery = 	
																'Select LAD.PreCompOff_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0110_PrecompOff_Application LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains 
																 
															End
														Else
															Begin
																Set @SqlQuery = 	
																'Select LAD.PreCompOff_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 '  From V0110_PrecompOff_Application LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where (LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																													
																				And LAD.PreCompOff_App_ID In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																			   )'    
																				
																		   + ' And ' + @Constrains
															
																			   	  
															End
																																				
													End
												Else if @is_rpt_manager = 1
													Begin
														
														Insert Into #Emp_Cons(Emp_ID)    
															Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
														(select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
															 where Effect_Date<=GETDATE()
															 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
																INNER JOIN 
																	T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
																INNER JOIN
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Pre-CompOff'
																 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Pre-CompOff'
																Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
														
														
														
														--select * from #Emp_Cons where Emp_ID=17101
														
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
																'Select LAD.PreCompOff_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0110_PrecompOff_Application LAD
																		inner join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains

																														
															End
														Else
															Begin
																Set @SqlQuery = 	
																'Select LAD.PreCompOff_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0110_PrecompOff_Application LAD
																	inner join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																												
																			And LAD.PreCompOff_App_ID In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																			
																	  + ' And ' + @Constrains
															End
															
													end		
												
											---------Added By Jimit 17052018-------------
									
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
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Pre-CompOff' 										
														
														
														
														SET @SqlQuery =	   'Select  PreCompOff_App_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																			FROM	(SELECT LAD.PreCompOff_App_ID,LAD.App_Status,PreCompOff_App_date,LAd.Alpha_Emp_Code,Emp_First_Name,Emp_full_Name,From_Date,To_date
																					From	V0110_PrecompOff_Application LAD 
																							INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																							LEFT OUTER JOIN (SELECT PreCompOff_App_ID,Emp_ID,S_Emp_ID,Approval_Status As App_Status FROM T0115_PreCompOff_Approval_Level LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																												ON LAD.PreCompOff_App_ID=LA.PreCompOff_App_ID And LAD.EMP_ID=LA.EMP_ID
																					Where	 (LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																									'And LAD.PreCompOff_App_ID In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																								')
																							--AND NOT EXISTS(SELECT 1 FROM #tbl_Leave_App T WHERE T.PreCompOff_App_ID=LAD.PreCompOff_App_ID)
																					) T
																			WHERE	1=1  and ' + @Constrains	
																			
																			
																			
											END
													
												
										END
									
									------------Ended-----------------
																								
												Else if @is_rpt_manager = 0 and @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
													Begin
														
													
														Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Pre-CompOff'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Pre-CompOff'
															Where ES.Scheme_Id = @Scheme_ID 
																	
										 				If @Rpt_level = 1
															Begin
																Set @SqlQuery = 	
																'Select LAD.PreCompOff_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0110_PrecompOff_Application LAD
																	inner join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																	  + ' And ' + @Constrains	 
																
															End
														Else
															Begin
																Set @SqlQuery = 	
																'Select LAD.PreCompOff_App_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0110_PrecompOff_Application LAD
																	inner join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.PreCompOff_App_ID Not In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																												
																			And LAD.PreCompOff_App_ID In (Select PreCompOff_App_ID From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
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
						--select * from #tbl_Leave_App
						--select lla.Tran_ID, lla.PreCompOff_App_ID As App_ID, Rpt_Level as Rpt_Level , lla.Approval_Status,Lla.From_Date,LLA.To_Date,LLA.Period,LLA.Remarks 
						--From T0115_PreCompOff_Approval_Level lla
						--							inner join (Select max(rpt_level) as rpt_level1, PreCompOff_App_ID
						--											From T0115_PreCompOff_Approval_Level
						--											Where PreCompOff_App_ID In (Select Leave_App_ID From #tbl_Leave_App)
						--											group by PreCompOff_App_ID 
						--										) Qry
						--							on qry.PreCompOff_App_ID = lla.PreCompOff_App_ID and qry.rpt_level1 = lla.rpt_level
													
													
						Insert INTO #Pre_ComOff_Application
							Select distinct	
								0 as Tran_ID,LAD.Emp_ID, LAD.Emp_Full_Name,LAD.Emp_First_Name, LAD.S_Emp_ID, LAD.PreCompOff_App_ID, LAD.PreCompOff_App_date 
								, LAD.Alpha_Emp_code,isnull(Qry1.From_Date,LAD.From_date),isnull(Qry1.To_date,LAD.To_Date),isnull(Qry1.Period,LAD.Period),ISNULL(qry1.Remarks,LAD.Remarks),LAD.App_Status
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID, SL.Final_Approver,SL.Is_Fwd_Leave_Rej
								,B.Branch_ID,B.Vertical_ID,B.SubVertical_ID,B.Dept_ID   --Added By Jaina 1-10-2015
							From V0110_PrecompOff_Application LAD
								left outer join (select lla.Tran_ID, lla.PreCompOff_App_ID As App_ID, Rpt_Level as Rpt_Level , lla.Approval_Status,Lla.From_Date,LLA.To_Date,LLA.Period,LLA.Remarks From T0115_PreCompOff_Approval_Level lla WITH (NOLOCK)
													inner join (Select max(rpt_level) as rpt_level1, PreCompOff_App_ID
																	From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																	Where PreCompOff_App_ID In (Select Leave_App_ID From #tbl_Leave_App)
																	group by PreCompOff_App_ID 
																) Qry
													on qry.PreCompOff_App_ID = lla.PreCompOff_App_ID and qry.rpt_level1 = lla.rpt_level
													
												) As Qry1 
								On  LAD.PreCompOff_App_ID = Qry1.App_ID 
								--Added By Jaina 04-09-2015 Start
									INNER JOIN T0080_EMP_MASTER WITH (NOLOCK) on T0080_EMP_MASTER.Emp_ID = LAD.Emp_ID INNER JOIN
                      
									  (
										SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID 
										FROM	T0095_INCREMENT I WITH (NOLOCK)
										WHERE	I.INCREMENT_ID = (
																	SELECT	TOP 1 INCREMENT_ID
																	FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																	WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID 
																	ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
																)
									  ) AS B ON B.EMP_ID = dbo.T0080_EMP_MASTER.EMP_ID AND B.CMP_ID=dbo.T0080_EMP_MASTER.CMP_ID --Added By Jaina 04-09-2015 End
								Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.PreCompOff_App_ID
								inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
						Where PreCompOff_App_ID In (Select Leave_App_ID From #tbl_Leave_App)	
							
						--select * from #Pre_ComOff_Application
					End
				Else
					Begin
						Insert INTO #Pre_ComOff_Application
							Select distinct	
								 0 as Tran_ID, LAD.Emp_ID, LAD.Emp_Full_Name,LAD.Emp_First_Name, LAD.S_Emp_ID, LAD.PreCompOff_App_ID, LAD.PreCompOff_App_date
								,LAD.Alpha_Emp_code,isnull(Qry1.From_Date,LAD.From_date),isnull(Qry1.To_date,LAD.To_Date),isnull(Qry1.Period,LAD.Period),ISNULL(qry1.Remarks,LAD.Remarks),LAD.App_Status, isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,'0' as Scheme_ID, '1' as Final_Approver, '0' as Is_Fwd_Leave_Rej
								,B.Branch_ID,B.Vertical_ID,B.SubVertical_ID,B.Dept_ID   --Added By Jaina 1-10-2015
							From V0110_PrecompOff_Application LAD
									left outer join (select lla.Tran_ID as Tran_ID, lla.PreCompOff_App_ID As App_ID, Rpt_Level  as Rpt_Level,lla.Approval_Status,Lla.From_Date,LLA.To_Date,LLA.Period,LLA.Remarks  From T0115_PreCompOff_Approval_Level lla WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, PreCompOff_App_ID
																		From T0115_PreCompOff_Approval_Level WITH (NOLOCK)
																		group by PreCompOff_App_ID 
																	) Qry
														on qry.PreCompOff_App_ID = lla.PreCompOff_App_ID and qry.rpt_level1 = lla.rpt_level
													) As Qry1 
									On  LAD.PreCompOff_App_ID = Qry1.App_ID
							--Added By Jaina 04-09-2015 Start
									INNER JOIN T0080_EMP_MASTER WITH (NOLOCK) on T0080_EMP_MASTER.Emp_ID = LAD.Emp_ID INNER JOIN
                      
									  (
										SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID 
										FROM	T0095_INCREMENT I WITH (NOLOCK)
										WHERE	I.INCREMENT_ID = (
																	SELECT	TOP 1 INCREMENT_ID
																	FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																	WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID 
																	ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
																)
									  ) AS B ON B.EMP_ID = dbo.T0080_EMP_MASTER.EMP_ID AND B.CMP_ID=dbo.T0080_EMP_MASTER.CMP_ID --Added By Jaina 04-09-2015 End
																					
							WHERE LAD.Cmp_ID = @Cmp_ID
								
						
					End			
					
				delete #tbl_Scheme_Leave
				delete #tbl_Leave_App
				
			
					Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
			End
		Close Employee_Cur
		Deallocate Employee_Cur
			
			
		If @Type = 0
			Begin
				If @Emp_ID_Cur > 0
					Begin					
						select * from #Pre_ComOff_Application --commented by Mukti(08092016)order by #Pre_ComOff_Application.PreCompOff_App_date desc
					End
				Else
					Begin
						declare @queryExe as nvarchar(1000)
						DECLARE @ORDER_BY AS VARCHAR(32);
						SET @ORDER_BY = RIGHT(@Constrains,len (@Constrains) - CHARINDEX('ORDER BY' , @Constrains) - 7)
						--set @queryExe = 'select * from #Pre_ComOff_Application where ' + @Constrains + ' order by #Pre_ComOff_Application.PreCompOff_App_date desc ' --commented by Mukti(08092016)
						set @queryExe = 'select ROW_NUMBER() OVER(ORDER BY ' + @ORDER_BY + ') AS ROW_ID, * from #Pre_ComOff_Application where ' + @Constrains + ''--Mukti(08092016)
						--print @queryExe
						exec (@queryExe)

						

					End
			End
		Else if @Type = 1
			Begin
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						select count(1) as PreCompOffAppCnt from #Pre_ComOff_Application 
					END
				ELSE
					select count(1) as PreCompOffAppCnt from #Pre_ComOff_Application 
				
				return
			End				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Pre_ComOff_Application
	
END


