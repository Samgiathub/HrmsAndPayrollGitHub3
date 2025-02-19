

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
create PROCEDURE [dbo].[SP_Get_Travel_Application_Records_alsoWorking_11022022]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0,
	@OrderBy varchar(500)=''
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
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Travel'

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
	 SELECT DISTINCT manger_emp_id,1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO 
	 WITH (NOLOCK) where pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date  
		
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
		
	CREATE table #Travel
	(
		 Emp_ID					numeric(18,0)
		,Emp_Full_Name			nvarchar(200)
		,Supervisor				nvarchar(100)
		,Travel_Application_ID	numeric(18,0)
		,Application_Code		numeric(18,0)
		,Branch_Name			nvarchar(100)
		,Desig_Name				nvarchar(100)
		,Alpha_Emp_code			nvarchar(100)
		,Application_Date		datetime
		,Application_Status     Char(1)
		,Travel_Set_Application_id	numeric(18,0)
		,Travel_approval_id		numeric(18,0)
		,Rpt_Level				numeric(18,0)
		,Scheme_ID				numeric(18,0)
		,Final_Approver			TinyInt
		,Is_Fwd_Leave_Rej		TinyInt
		,DynHierRepId			numeric(18,0)
		)
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Travel')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #Travel
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT COUNT(1) AS travelAppCnt from #Travel
							END
						ELSE
							Begin
								SELECT COUNT(1) AS travelAppCnt from #Travel 
							END
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
 																	WHERE R_Emp_ID = @Emp_ID) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID = @Emp_ID for xml path (''))
		
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
				
			end	
		
		--------------------------------------------------------------------------- Add by Deepal 10022022
		Select Tran_ID,ES.Cmp_ID,ES.Emp_ID,ES.Scheme_Id,Type,Effective_Date,IsMakerChecker,RptLevel,DynHierId,TravelTypeId,DynHierarchyId,DynHierColName,DynHierColValue,DynHierColId,IncrementId
		into #Temp12 
		from T0095_EMP_SCHEME ES
		inner join (
			SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T 
			Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
				where Emp_ID = @Emp_ID And Type = 'Travel'
			AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID = @Emp_ID And Type = 'Travel' AND Effective_Date <= getdate()) 
		) Q on ES.Scheme_Id = Q.Scheme_id
		inner join T0080_Travel_HycScheme TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
		Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId
		where DynHierColValue = @Emp_ID
		--------------------------------------------------------------------------- ENd
		
		

		--Declare @APPEmp as Numeric(18,0)  = 0
		--Select @APPEmp = Emp_id  from #Temp12 

		--delete from #Temp12 where RptLevel = 1
		--						--select rpt_level from T0115_TRAVEL_LEVEL_APPROVAL where Emp_ID = @APPEmp and S_Emp_ID = @Emp_ID and Approval_Status = 'A' and Rpt_Level = @Rpt_level
		
		
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
									
										--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
										--	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
										--	From T0050_Scheme_Detail WITH (NOLOCK)
										--	Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--	Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel'
										if ((Select count(1) from #Temp12) > 0) and @Rpt_level = 1 
										BEGIN

											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
											Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
											From T0050_Scheme_Detail SD WITH (NOLOCK)
											Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
											inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID
											Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) 
											and rpt_level = @Rpt_level And SM.Scheme_Type = 'Travel' and SD.Cmp_Id = @Cmp_ID 
										END
										ELSe
										Begin 
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
											--Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
											--From T0050_Scheme_Detail WITH (NOLOCK)
											--Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
											--Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel'
											Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
											--,isnull(DynHierColId,0) as DynHierId
											From T0050_Scheme_Detail WITH (NOLOCK)
											Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
											inner join T0080_DynHierarchy_Value Dy on T0050_Scheme_Detail.Dyn_Hier_Id = DY.DynHierColId and Dy.DynHierColValue = @Emp_ID
											Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0)  and rpt_level = @Rpt_level 
											And T0040_Scheme_Master.Scheme_Type = 'Travel' 
											and T0050_Scheme_Detail.Cmp_Id = @Cmp_ID
										END
											
										
										
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
										BEGIN
											
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
	 															Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM 
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
																	And T0040_Scheme_Master.Scheme_Type = ''Travel'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
												
												EXEC (@string_1)
										END						 	 
										--Added By Jimit 18072018		
										
										Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
										BEGIN
										
										
														Declare @App_Emp_ID as numeric(18,0) = 0
														Select @App_Emp_ID = App_Emp_ID from T0050_Scheme_Detail where Scheme_Id = @Scheme_ID 
														
														if @App_Emp_ID = 0
														begin
															SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
																			Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
																			From T0050_Scheme_Detail WITH (NOLOCK)
																			Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																			Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
																			And T0040_Scheme_Master.Scheme_Type = ''Travel'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
														End
														Else
														Begin
															set @string_1 = ''
															SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
																			Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
																			From T0050_Scheme_Detail WITH (NOLOCK)
																			Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																			Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +'  and app_emp_id = '+ cast(@Emp_ID_Cur AS VARCHAR(50))+'
																			And T0040_Scheme_Master.Scheme_Type = ''Travel'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
																
													
													End
														EXEC (@string_1)
												END
										--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days)
										--	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days
										--	From T0050_Scheme_Detail 
										--	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--	Where  rpt_level = @Rpt_level and Is_RM = 1 And T0040_Scheme_Master.Scheme_Type = 'Travel'
											
										If @Manager_Branch > 0 
											Begin
												Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
													Select distinct T0040_Scheme_Master.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Is_RMToRM 
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where rpt_level = @Rpt_level and Is_BM = 1 And T0040_Scheme_Master.Scheme_Type = 'Travel'
											End
											
									end
								 Else
									Begin
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Max_Leave_Days,Is_RMToRM)
												Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Leave_Days,Is_RMToRM
												From T0050_Scheme_Detail WITH (NOLOCK)
												Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
												Where T0040_Scheme_Master.Scheme_Type = 'Travel'
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
												 
												If @is_branch_manager = 1
													Begin
									 					Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Travel'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
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
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0100_TRAVEL_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains 
																 
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 '  From V0100_TRAVEL_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																													
																				And LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
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
																 Where Effective_Date<=GETDATE() And Type='Travel'
																 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
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
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0100_TRAVEL_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0100_TRAVEL_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																												
																			And LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
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
																															@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Travel' 										
																				
																			
																				SET @SqlQuery =	   'Select  Travel_Application_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																									FROM	(SELECT LAD.Travel_Application_ID,LAD.Application_Status,Application_Date,LAd.Alpha_Emp_Code,Emp_First_Name
																											From	V0100_TRAVEL_APPLICATION LAD 
																													INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																													LEFT OUTER JOIN (SELECT Travel_Application_ID,Emp_ID,S_Emp_ID,Approval_Status As App_Status FROM T0115_TRAVEL_LEVEL_APPROVAL LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																																		ON LAD.Travel_Application_ID=LA.Travel_Application_ID And LAD.EMP_ID=LA.EMP_ID
																											Where	 (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																															'And LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																														')																										
																											) T
																									WHERE	1=1  and ' + @Constrains	
																		
																	END															
														END												
												------------Ended-----------------

												Else if @is_rpt_manager = 0 and @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
													Begin
															-- Backup 11022022 ForSetting
															--Insert Into #Emp_Cons(Emp_ID)    
															--Select ES.Emp_ID 
															--From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
															--	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															--	 Where Effective_Date<=GETDATE() And Type='Travel'
															--	 GROUP BY emp_ID) Qry on      
															--	 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
															--Where ES.Scheme_Id = @Scheme_ID 
															-- Backup 11022022 ForSetting

															Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Travel'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
															inner join T0080_Travel_HycScheme TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
															Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId
															Where ES.Scheme_Id = @Scheme_ID 

														
										 				If @Rpt_level = 1
															Begin
																
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0100_TRAVEL_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) 
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																	  + ' And ' + @Constrains	 
															End
														Else
															Begin
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																'From V0100_TRAVEL_APPLICATION LAD
																 Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																 Where (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																			and LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																+ ' And ' + @Constrains
															End
														
													End		
													 
														select @SqlQuery
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

					
					--delete from #tbl_Scheme_Leave where rpt_level = 1
				--	delete from #tbl_Leave_App    where Leave_App_ID in (3,4)
				--	select * from T0080_Travel_HycScheme 
				--select * from #tbl_Scheme_Leave
				--select * from #tbl_Leave_App   

					If @Emp_ID_Cur > 0
						Begin
							Insert INTO #Travel
							Select distinct	
									LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Travel_Application_ID, LAD.Application_Code,LAD.Branch_Name
									,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Application_Date ,LAD.Application_Status
									,LAD.Travel_Set_Application_id,LAD.travel_approval_id
									,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID
									, SL.Final_Approver,SL.Is_Fwd_Leave_Rej
									,DynHierColValue From V0100_TRAVEL_APPLICATION LAD
									left outer join (select lla.Travel_Application_Id As App_ID, Rpt_Level as Rpt_Level , lla.Approval_Status 
													 From T0115_TRAVEL_LEVEL_APPROVAL lla WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, Travel_Application_ID
																		From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																		Where Travel_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
																		group by Travel_Application_ID 
																	) Qry
														on qry.Travel_Application_ID = lla.Travel_Application_ID and qry.rpt_level1 = lla.rpt_level
													) As Qry1 
									On  LAD.Travel_Application_ID = Qry1.App_ID
									Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Travel_Application_ID 
									inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave
									and  SL.rpt_level > isnull(Qry1.Rpt_Level,0)
									and  SL.rpt_level = TLAP.rpt_level  -- or Qry1.Rpt_Level = 0)
									--inner join T0080_Travel_HycScheme TT on TT.SchemeIId = 
							Where (Travel_Application_ID In (Select Leave_App_ID From #tbl_Leave_App) or Lad.S_emp_ID = @Emp_ID) 
						--	and DynHierColValue = @Emp_ID_Cur

							--Insert INTO #Travel
							--Select distinct	
							--	LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Travel_Application_ID, LAD.Application_Code,LAD.Branch_Name
							--	,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Application_Date ,LAD.Application_Status
							--	,LAD.Travel_Set_Application_id,LAD.travel_approval_id
							--	,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID, SL.Final_Approver,SL.Is_Fwd_Leave_Rej,DynHierColValue
							--From V0100_TRAVEL_APPLICATION LAD
							--	left outer join (select lla.Travel_Application_Id As App_ID, Rpt_Level as Rpt_Level , lla.Approval_Status 
							--					 From T0115_TRAVEL_LEVEL_APPROVAL lla WITH (NOLOCK)
							--						inner join (Select max(rpt_level) as rpt_level1, Travel_Application_ID
							--										From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
							--										Where Travel_Application_ID In (Select Leave_App_ID From #tbl_Leave_App)
							--										group by Travel_Application_ID 
							--									) Qry
							--						on qry.Travel_Application_ID = lla.Travel_Application_ID and qry.rpt_level1 = lla.rpt_level
							--					) As Qry1 
							--	On  LAD.Travel_Application_ID = Qry1.App_ID
							--	Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Travel_Application_ID
							--	inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) 
							--	and  SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
							--Where Travel_Application_ID In (Select Leave_App_ID From #tbl_Leave_App) or Lad.S_emp_ID = @Emp_ID
							--and DynHierColValue = @Emp_ID_Cur
			 			
						End
					Else
						Begin

						
						Insert INTO #Travel
							Select distinct	
								LAD.Emp_ID, LAD.Emp_Full_Name, LAD.Supervisor,LAD.Travel_Application_ID, LAD.Application_Code ,LAD.Branch_Name
								,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.Application_Date ,LAD.Application_Status 
								,LAD.Travel_Set_Application_id,LAD.travel_approval_id
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,'0' as Scheme_ID, '1' as Final_Approver, '0' as Is_Fwd_Leave_Rej
							From V0100_TRAVEL_APPLICATION LAD
									left outer join (select lla.Travel_Application_ID As App_ID, Rpt_Level  as Rpt_Level,lla.Approval_Status From T0115_TRAVEL_LEVEL_APPROVAL lla WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, Travel_Application_ID
																		From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																		group by Travel_Application_ID 
																	) Qry
														on qry.Travel_Application_ID = lla.Travel_Application_ID and qry.rpt_level1 = lla.rpt_level
													) As Qry1 
									On  LAD.Travel_Application_ID = Qry1.App_ID
							WHERE LAD.Cmp_ID = @Cmp_ID 
								
						
					End			
					
				delete #tbl_Scheme_Leave
				delete #tbl_Leave_App
				
			
					Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
			End
		Close Employee_Cur
		Deallocate Employee_Cur
		
		declare @queryExe as nvarchar(1000)
		
		
		If @Type = 0
			Begin
				If @Emp_ID_Cur > 0
					Begin
						set @queryExe=''
						set @queryExe='select *,dbo.F_GET_Emp_Visit('+  cast(@Cmp_ID as varchar(50)) +',#Travel.Travel_Application_ID,1) as Emp_Visit from #Travel ' + @OrderBy --order by #Travel.Application_Date desc						
						exec (@queryExe)
					End
				Else
					Begin
						set @queryExe=''
						set @queryExe = 'select *,dbo.F_GET_Emp_Visit('+cast(@Cmp_ID as varchar(50))+',#Travel.Travel_Application_ID,1) as Emp_Visit from #Travel where ' + @Constrains + ' ' + @OrderBy						
						exec (@queryExe)
					End
			End
		Else if @Type = 1
			Begin
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(1) AS travelAppCnt from #Travel
					END
				ELSE
					Begin
						SELECT COUNT(1) AS travelAppCnt from #Travel 
					END
				return
			End				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Travel
	
END


