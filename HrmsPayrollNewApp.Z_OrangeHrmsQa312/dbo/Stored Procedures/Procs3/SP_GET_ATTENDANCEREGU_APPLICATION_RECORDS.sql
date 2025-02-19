CREATE PROCEDURE [dbo].[SP_GET_ATTENDANCEREGU_APPLICATION_RECORDS]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0
AS
BEGIN
	Set Nocount ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	Declare @Scheme_ID AS Numeric(18,0)
	Declare @Leave AS Varchar(100)
	Declare @is_rpt_manager AS tinyint
	Declare @is_branch_manager AS tinyint
	Declare @is_HOD as tinyint   --Added by Jaina 30-04-2020
	Declare @Manager_HOD varchar(max) --Added by Jaina 30-04-2020  
	 
	Declare @SqlQuery AS NVarchar(max)
	Declare @SqlExcu AS NVarchar(max)
	declare @MaxLevel AS numeric(18,0)
	Declare @Rpt_level_Minus_1 AS Numeric(18,0)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 18072018
	 
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK)
		INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Attendance Regularization'

	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @SqlExcu = ''
	set @is_HOD = 0 
	
	CREATE table #Responsiblity_Passed
	 (		 
	     Emp_ID	Numeric(18,0)	
	    ,is_res_passed tinyint default 1  
	 )  
	 
	 INSERT INTO #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 INSERT INTO #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK)  WHERE pass_to_emp_id = @Emp_ID AND  getdate() >= from_date AND getdate() <= to_date  and Type='Attendance Regularization'   --Change by Jaina 24-04-2017
				
	
	CREATE table #tbl_Scheme_Leave 
	 (
		Scheme_ID			Numeric(18,0)
	   ,Leave				Varchar(100) 
	   ,Final_Approver		TinyInt
	   ,Is_Fwd_Leave_Rej	TinyInt
	   ,is_rpt_manager		TinyInt not null default 0
	   ,is_branch_manager	TinyInt not null default 0
	   ,rpt_level			numeric(18,0)
	   ,Max_Leave_Days		numeric(18,2)
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 18072018
	   ,Is_HOD				Tinyint default 0  --Added by Jaina 30042020
	 )  
	CREATE NONCLUSTERED INDEX Ix_tbl_Scheme_Leave_SchemeId ON #tbl_Scheme_Leave (Scheme_ID,Leave,rpt_level)
	
	
	CREATE table #tbl_Leave_App
	 (
		Leave_App_ID	Numeric(18,0)
	   ,Scheme_ID		Numeric(18,0)
	   ,Leave			Varchar(100) 
	   ,rpt_level		numeric(18,0)
	 )
	 CREATE NONCLUSTERED INDEX Ix_tbl_Leave_App_SchemeId ON #tbl_Leave_App (Scheme_ID,Leave_App_ID,Leave,rpt_level)
	 
	 if @Rpt_level > 0
		begin
			set @MaxLevel = @Rpt_level
		end
	else
		begin
			set @Rpt_level = 1
		end
	
	CREATE table #Leave
	(
		 Cmp_ID					numeric(18,0)
		,Emp_ID					numeric(18,0)
		,Emp_Name				nvarchar(200)
		,Emp_Full_Name			nvarchar(200)
		,IO_Tran_Id				numeric(18,0)
		,Emp_Code				nvarchar(100)
		,Alpha_Emp_code			nvarchar(100)
		,Reason					nvarchar(500)
		,App_Date				datetime
		,Rpt_Level				numeric(18,0)
		,Scheme_ID				numeric(18,0)
		,Leave					nvarchar(MAX)
		,Final_Approver			TinyInt
		,Is_Fwd_Leave_Rej		TinyInt
		,Superior				nvarchar(100)
		,For_Date				datetime
		,In_Time				datetime
		,Out_Time				datetime
		,is_pass_over			tinyint
		,Branch_id				numeric(18,0) 	
		,Is_Cancel_Late_In	tinyint default 0
		,Is_Cancel_Early_Out	tinyint default 0
		,Half_Full_day			nvarchar(200)
		,Other_Reason			varchar(MAX)
	    ,Max_Leave_Days			numeric(18,0) default 0   --Added by Jaina 29-04-2020
		,Actual_In_Time			datetime
		,Actual_Out_Time		datetime
		,Shift_Start_Time		datetime
		,Shift_End_Time		datetime
		)
		CREATE NONCLUSTERED INDEX Ix_Leave_CmpId_EmpId_SchemeId_IO_Tran_Id ON #Leave (Cmp_Id,Emp_Id,Scheme_ID,IO_Tran_Id,Rpt_Level)
		
		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD  WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM  WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Attendance Regularization')
			BEGIN
			
				IF @Type = 0
					BEGIN
					
						SELECT * FROM #Leave
					END
				ELSE IF @Type = 1
					BEGIN
					
						SELECT COUNT(1) AS LateComer FROM #Leave 
					END	
						
				RETURN
			END
			
		declare @Emp_ID_Cur numeric(18,0)
		declare @is_res_passed tinyint
		
		set @Emp_ID_Cur = 0
		set @is_res_passed = 0
 		
 		------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(max)
 		DECLARE @string_1	VARCHAR(MAX)
 		
 	--	SELECT @String = ( SELECT distinct(convert(nvarchar,EM.Cmp_ID)) + ','  
 	--	FROM T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
 	--		( SELECT max(Effect_Date) AS Effect_Date,Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 
 	--			WHERE ERD1.Effect_Date <= getdate() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL 
 	--																WHERE R_Emp_ID = @Emp_ID) GROUP by Emp_ID 
 	--		) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 	--		T0080_EMP_MASTER EM ON Em.Emp_ID = ERD.Emp_ID
		--WHERE ERD.R_Emp_ID = @Emp_ID for xml path (''))
		
		--Change by Jaina 24-04-2017
		SELECT @String =  (SELECT (convert(nvarchar,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK) INNER JOIN 
 			( SELECT max(Effect_Date) AS Effect_Date,ERD1.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1  WITH (NOLOCK) INNER join (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK) WHERE R_Emp_ID in (SELECT Emp_ID FROM #Responsiblity_Passed) ) Qry 
 				on ERD1.Emp_ID = Qry.Emp_ID
 				WHERE ERD1.Effect_Date <= getdate() and R_Emp_ID in (SELECT Emp_ID FROM #Responsiblity_Passed) GROUP by ERD1.Emp_ID
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM  WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID in (SELECT Emp_ID FROM #Responsiblity_Passed) GROUP by EM.Cmp_ID for xml path ('') )
							
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			end	
		
			
		
		Declare Employee_Cur Cursor
			For SELECT Emp_ID,is_res_passed FROM #Responsiblity_Passed GROUP by Emp_ID,is_res_passed
		Open Employee_Cur
		Fetch Next FROM Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
			Begin
			
			set @Rpt_level = 1
			 
			If @Emp_ID_Cur > 0
				Begin
			 	 
	 	 			declare @Manager_Branch numeric(18,0)
					set @Manager_Branch = 0
					set @Manager_HOD = 0
					if exists (SELECT 1 FROM T0095_MANAGERS  WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur)
						BEGIN
							SELECT @Manager_Branch = branch_id FROM T0095_MANAGERS WITH (NOLOCK)  WHERE Emp_id = @Emp_ID_Cur AND Effective_date = 
							(
								SELECT max(Effective_date) AS Effective_date FROM T0095_MANAGERS WITH (NOLOCK)  WHERE Emp_id = @Emp_ID_Cur AND Effective_date <= getdate()
							)
						END
				
		 	if exists (SELECT 1 from T0095_Department_Manager WITH (NOLOCK)  where Emp_id = @Emp_ID_Cur)
						BEGIN 
							SELECT @Manager_HOD = COALESCE(cast(@Manager_HOD as varchar(100)) + '#', '') + ''+ cast( dm.dept_id as varchar(100)) + ''
							from T0095_Department_Manager DM  WITH (NOLOCK) inner join 
							(select max(effective_date) as max_date,dept_id	 from T0095_Department_Manager WITH (NOLOCK)   group by dept_id) MDM 
							on DM.dept_id=MDM.dept_id and DM.effective_date=MDM.max_date
							where dm.emp_id=@Emp_ID_Cur
							print @Manager_HOD
						END
				WHILE @Rpt_level <= @MaxLevel
					Begin
					
								----------------------
				 Set @Rpt_level_Minus_1 = @Rpt_level - 1
				
					 if @Emp_ID_Cur > 0
						begin

							INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_HOD)
								SELECT  T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM,Is_HOD
								FROM T0050_Scheme_Detail  WITH (NOLOCK) 
								Inner Join T0040_Scheme_Master WITH (NOLOCK)  ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
								WHERE App_Emp_Id = @Emp_ID_Cur and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Attendance Regularization'  --Check Scheme Type --Ankit 13052014
								GROUP by T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM,Is_HOD

																
							IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
									BEGIN
									
										SET @string_1 = 'INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_HOD)
							 							SELECT T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days ,Is_RMToRM,Is_HOD
														FROM T0050_Scheme_Detail  WITH (NOLOCK) 
														Inner Join T0040_Scheme_Master  WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
														WHERE  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
															And T0040_Scheme_Master.Scheme_Type = ''Attendance Regularization'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')
														Group by T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM,Is_HOD'
										
										EXEC (@string_1)
										
									END
									--Added By Jimit 18072018										
										Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
												BEGIN
													 
													 SET @string_1 = 'INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM,Is_HOD)
																SELECT distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM,Is_HOD
																FROM T0050_Scheme_Detail WITH (NOLOCK)  
																Inner Join T0040_Scheme_Master WITH (NOLOCK)  ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																WHERE  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
																And T0040_Scheme_Master.Scheme_Type = ''Attendance Regularization''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
													
													  EXEC (@string_1)
														
												END	
							--INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days)
							-- 	SELECT distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days
							--	FROM T0050_Scheme_Detail 
							--	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
							--	WHERE  rpt_level = @Rpt_level and Is_RM = 1 
							--		And T0040_Scheme_Master.Scheme_Type = 'Attendance Regularization'	--Check Scheme Type --Ankit 13052014
								
								
							if @Manager_Branch > 0 
								begin
								
									INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_HOD)
										SELECT T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days ,Is_RMToRM,Is_HOD
										FROM T0050_Scheme_Detail  WITH (NOLOCK) 
										Inner Join T0040_Scheme_Master WITH (NOLOCK)  ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										WHERE rpt_level = @Rpt_level and Is_BM = 1 And T0040_Scheme_Master.Scheme_Type = 'Attendance Regularization'
										GROUP by T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days ,Is_RMToRM,Is_HOD
							
								end
								
							if @Manager_HOD <> '' ---Added by Jaina 30-04-2020
								begin						
									
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_HOD)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Is_RMToRM,Is_HOD
										From T0050_Scheme_Detail SD WITH (NOLOCK)  Inner Join T0040_Scheme_Master SM  WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										Where rpt_level = @Rpt_level and Is_HOD = 1 And SM.Scheme_Type = 'Attendance Regularization'
								END 
						end
					else
						begin
						
								INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Max_Leave_Days,Is_RMToRM,Is_HOD)
								SELECT T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Leave_Days,Is_RMToRM,Is_HOD
								FROM T0050_Scheme_Detail  WITH (NOLOCK) 
								Inner Join T0040_Scheme_Master  WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
								WHERE T0040_Scheme_Master.Scheme_Type = 'Attendance Regularization'	--Check Scheme Type --Ankit 13052014
								GROUP by T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM,Is_HOD
						end
						
					 declare @rpt_levle_cur tinyint
					 set @rpt_levle_cur = 0
					 
					
					
					Declare Final_Approver Cursor
						For SELECT distinct Scheme_Id, Leave,rpt_level FROM #tbl_Scheme_Leave 
					Open Final_Approver
					Fetch Next FROM Final_Approver Into @Scheme_ID, @Leave,@rpt_levle_cur
					WHILE @@FETCH_STATUS = 0
						Begin
						 			
							If Exists (SELECT Scheme_Detail_ID FROM T0050_Scheme_Detail WITH (NOLOCK)  
											WHERE Scheme_Id = @Scheme_ID And Leave = @Leave And Rpt_Level = @Rpt_level + 1 AND NOT_MANDATORY = 0)
								Begin
									Update #tbl_Scheme_Leave 
										Set Final_Approver = 0 
										WHERE Scheme_Id = @Scheme_ID And Leave = @Leave and rpt_level =  @Rpt_level
								End
							Else 
								Begin
									Update #tbl_Scheme_Leave 
										Set Final_Approver = 1 
										WHERE Scheme_Id = @Scheme_ID And Leave = @Leave  and rpt_level =  @Rpt_level
								End
											
							Fetch Next FROM Final_Approver Into @Scheme_ID, @Leave,@rpt_levle_cur
						End
					Close Final_Approver
					Deallocate Final_Approver	
					
				
					Declare cur_Scheme_Leave Cursor
						For SELECT Scheme_Id, Leave,is_rpt_manager,is_branch_manager,Is_RMToRM,Is_HOD FROM #tbl_Scheme_Leave WHERE rpt_level = @Rpt_level
					Open cur_Scheme_Leave
					Fetch Next FROM cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager,@Is_HOD
					WHILE @@FETCH_STATUS = 0
						Begin
							CREATE table #Emp_Cons 
							 (
							   Emp_ID numeric    
							 ) 
									If @is_branch_manager = 1
										Begin
												INSERT INTO #Emp_Cons(Emp_ID)    
													SELECT ES.Emp_ID 
													FROM T0095_EMP_SCHEME ES  WITH (NOLOCK) Inner Join
														(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) 
														 WHERE Effective_Date<=GETDATE()  And Type = 'Attendance Regularization'
														  GROUP BY emp_ID) Qry ON      
														 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID  And Type = 'Attendance Regularization'
													INNER join 
													(SELECT Branch_ID,I.Emp_ID FROM T0095_Increment I  WITH (NOLOCK) inner join     
													   (SELECT max(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK) 
													   WHERE Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry ON    
														I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) AS INC
														on INC.Emp_ID = Qry.Emp_ID
													WHERE ES.Scheme_Id = @Scheme_ID and INC.Branch_ID = @Manager_Branch
													
												 
												If @Rpt_level = 1
													Begin
														
														Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval WITH (NOLOCK)  
																												WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')'  									
																  + ' And ' + @Constrains	  
													End
												Else
													Begin
														
														Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 '  FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE (LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')
																		And LAD.IO_Tran_Id In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
														
												End
																																	
										End
									Else If @is_rpt_manager = 1
										BEGIN
												
												INSERT	INTO #Emp_Cons(Emp_ID)    
												SELECT	ERD.Emp_ID 
												FROM	T0090_EMP_REPORTING_DETAIL ERD 
														INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID 
																	FROM	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
																	WHERE	Effect_Date<=GETDATE() --and  R_emp_id = @Emp_ID_Cur --Commneted by Sumit for Multi Reporting Manager Case 11052016
																	GROUP BY emp_ID) RQry ON  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date and R_emp_id = @Emp_ID_Cur
														INNER JOIN T0095_EMP_SCHEME  ES  WITH (NOLOCK) ON ES.Emp_ID = ERD.Emp_ID 
														INNER JOIN (SELECT	MAX(Effective_Date) AS For_Date,Emp_ID 
																	FROM	T0095_EMP_SCHEME WITH (NOLOCK) 
																	WHERE	Effective_Date<=GETDATE() And Type = 'Attendance Regularization'
																	GROUP BY emp_ID) Qry ON ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Scheme_Id = @Scheme_ID  And Type = 'Attendance Regularization'
												WHERE	R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
												
												DELETE	FROM #Emp_Cons 
												WHERE	Emp_ID NOT IN	(
																		SELECT	ERD.Emp_ID 
																		FROM	T0090_EMP_REPORTING_DETAIL ERD  WITH (NOLOCK) 
																				INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date,ERD1.Emp_ID 
																							FROM	T0090_EMP_REPORTING_DETAIL ERD1  WITH (NOLOCK) 
																									INNER JOIN #Emp_Cons EC1 ON EC1.Emp_ID = ERD1.Emp_ID 
																							WHERE	Effect_Date<=GETDATE() 
																							GROUP BY ERD1.emp_ID
																							) RQry ON  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date and R_emp_id = @Emp_ID_Cur
																				INNER JOIN #Emp_Cons EC ON EC.Emp_ID = RQry.Emp_ID 
																		)		
														
												If @Rpt_level = 1
													Begin
														Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																												WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')'  									
																  + ' And ' + @Constrains
													End
												Else
													Begin
														Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave, '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE (LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')
																		And LAD.IO_Tran_Id In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
												End
										end	
									---------Added By Jimit 18072018-------------
									--Added by Jaina 30-04-2020 Start
									else if @is_HOD = 1
										BEGIN 
											
											Insert Into #Emp_Cons(Emp_ID)    
												Select ES.Emp_ID 
												From T0095_EMP_SCHEME ES Inner Join
													(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK) 
													 Where Effective_Date<=GETDATE() And Type='Attendance Regularization'
													 GROUP BY emp_ID) Qry on      
													 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Attendance Regularization'
												INNER JOIN 
												(select Branch_ID,I.Emp_ID,Dept_ID From T0095_Increment I  WITH (NOLOCK) inner join     
												   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment   WITH (NOLOCK)   
												   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
													I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
													on INC.Emp_ID = Qry.Emp_ID
												Where ES.Scheme_Id = @Scheme_ID --and INC.Dept_ID =@Manager_HOD
												and  INC.Dept_ID in(select data from dbo.Split(@Manager_HOD,'#'))				
													
												
											If @Rpt_level = 1 
												Begin 
													Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id 
																						FROM T0115_AttendanceRegu_Level_Approval WITH (NOLOCK)  
																						WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')'  									
																  + ' And ' + @Constrains
													
												End
											Else
												Begin     
													
													Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave, '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE (LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')
																		And LAD.IO_Tran_Id In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS varchar(2)) + ')
																	   )'    
																		
																  + ' And ' + @Constrains
													
												End

										End --Added by Jaina 30-04-2020 End
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
													
														DECLARE @date AS DATETIME
														SET @date = GETDATE()
														
														EXEC SP_RPT_FILL_EMP_CONS_WITH_REPORTING	@Cmp_ID=@Cmp_ID,@From_Date=@date,@To_Date=@date,@Branch_ID=0,
																									@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID = @Emp_ID_Cur,@Constraint='',@Sal_Type = 0,
																									@Salary_Cycle_id = 0,@Segment_Id = 0,@Vertical_Id = 0,@SubVertical_Id = 0,@SubBranch_Id= 0,
																									@New_Join_emp = 0,@Left_Emp = 0,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc	= 0,@Type = 0 ,
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Attendance Regularization' 										
														
														
														
														
													
														SET @SqlQuery =	   'SELECT  IO_Tran_Id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																			FROM	(SELECT LAD.IO_Tran_Id,For_Date,LAd.Alpha_Emp_Code,Emp_Name,Chk_By_Superior,LAD.Branch_ID,LAD.SubBranch_ID
																					From	View_Late_Emp LAD 
																							INNER JOIN #EMP_CONS_RM Ec ON LAD.Emp_Id = Ec.Emp_ID  
																							LEFT OUTER JOIN (SELECT IO_Tran_Id,Emp_ID,S_Emp_ID FROM T0115_AttendanceRegu_Level_Approval LA WITH (NOLOCK)  WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																												ON LAD.IO_Tran_Id=LA.IO_Tran_Id And LAD.EMP_ID=LA.EMP_ID
																					Where	 (LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval WITH (NOLOCK)  WHERE Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																									'And LAD.IO_Tran_Id In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) WHERE  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																								')																							
																					) T
																			WHERE	1=1  and ' + @Constrains	
																			
																			
																			
																
												
											END
													
												
										END
									
									------------Ended-----------------			
									Else if @is_rpt_manager = 0 and @is_branch_manager = 0 and @is_Reporting_To_Reporting_manager = 0 and @is_HOD = 0
										Begin
										
												INSERT INTO #Emp_Cons(Emp_ID)    
														SELECT ES.Emp_ID 
														FROM T0095_EMP_SCHEME ES  WITH (NOLOCK) Inner Join
															(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) 
															 WHERE Effective_Date<=GETDATE()  And Type = 'Attendance Regularization'
															 GROUP BY emp_ID) Qry ON      
															 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID  And Type = 'Attendance Regularization'
														WHERE ES.Scheme_Id = @Scheme_ID 
													
												If @Rpt_level = 1
													Begin
														Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +  cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																												WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')'  									
																  + ' And ' + @Constrains	  
													End
												Else
													Begin
														Set @SqlQuery = 	
														'SELECT LAD.IO_Tran_Id, ' + Cast(@Scheme_ID AS Varchar(3)) + ' AS Scheme_ID, ''' + @Leave + ''' AS Leave , '  +   cast(@Rpt_level AS VARCHAR(2)) +
															 ' FROM View_Late_Emp LAD
																Inner Join #Emp_Cons Ec ON LAD.Emp_Id = Ec.Emp_ID
															WHERE (LAD.IO_Tran_Id Not In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																											WHERE Rpt_Level = ' + Cast(@Rpt_level AS varchar(2)) + ')
																		And LAD.IO_Tran_Id In (SELECT IO_Tran_Id FROM T0115_AttendanceRegu_Level_Approval WITH (NOLOCK)  
																											WHERE Rpt_Level = ' + Cast(@Rpt_level_Minus_1 AS varchar(2)) + ')
																	   )'    
																  + ' And ' + @Constrains
													End
										end		
										
									INSERT INTO #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										exec (@SqlQuery)
									 
							Drop Table #Emp_Cons
							Fetch Next FROM cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager,@is_HOD
						End
					Close cur_Scheme_Leave
					Deallocate cur_Scheme_Leave
					
				 set @Rpt_level = @Rpt_level + 1
				End
			End 
				
				If @Emp_ID_Cur > 0
					Begin

						INSERT INTO #Leave
							SELECT distinct	LAD.Cmp_ID,LAD.Emp_ID,LAD.Emp_Name , LAD.Emp_Full_Name, LAD.IO_Tran_Id, LAD.Emp_Code, LAD.Alpha_Emp_code,LAD.Reason,LAD.App_Date,
								 Isnull(Qry1.rpt_level + 1,'1') AS Rpt_Level,TLAP.Scheme_ID, TLAP.Leave
								 , SL.Final_Approver,SL.Is_Fwd_Leave_Rej,
								 Lad.Superior,lad.For_Date
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else isnull(Qry1.In_Time, lad.In_Time) end AS In_Time -- Change by ronakk 21112022
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else isnull(Qry1.Out_Time,lad.Out_Time) end AS Out_Time -- Change by ronakk 21112022
								 , lad.In_Time  AS In_Time   -- Change by ronakk 23032023
								 ,lad.Out_Time  AS Out_Time  -- Change by ronakk 23032023
								 ,@is_res_passed, LAD.Branch_ID,
								 Isnull(Qry1.Is_Cancel_Late_In,LAD.Is_Cancel_Late_In) AS Is_Cancel_Late_In,Isnull(Qry1.Is_Cancel_Early_Out,Lad.Is_Cancel_Early_Out) AS Is_Cancel_Early_Out,Isnull(Qry1.Half_Full_day,Lad.Half_Full_day) AS Half_Full_day,
								 LAD.Other_Reason,sl.Max_Leave_Days  --Added by Jaina 29-04-2020  --Added By Jimit 03082018
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else LAD.Actual_In_Time end Actual_In_Time -- Change by ronakk 21112022
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else LAD.Actual_Out_Time end Actual_Out_Time  -- Change by ronakk 21112022
								 ,LAD.Actual_In_Time
								 ,LAD.Actual_Out_Time
								 ,s.Shift_St_Time,S.Shift_End_Time
							FROM View_Late_Emp LAD
									left outer join (SELECT lla.IO_Tran_Id AS App_ID, lla.In_Time, lla.Out_Time, Rpt_Level AS Rpt_Level ,lla.Is_Cancel_Late_In, lla.Is_Cancel_Early_Out,lla.Half_Full_day FROM T0115_AttendanceRegu_Level_Approval lla WITH (NOLOCK) 
														Inner join (SELECT max(rpt_level) AS rpt_level1, IO_Tran_Id
																		FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																		WHERE IO_Tran_Id In (SELECT Leave_App_ID FROM #tbl_Leave_App)
																		group by IO_Tran_Id 
																	) Qry
														on qry.IO_Tran_Id = lla.IO_Tran_Id and qry.rpt_level1 = lla.rpt_level
														
													) AS Qry1 
									On  LAD.IO_Tran_Id = Qry1.App_ID	-- This join is for getting updated FROM date,to date and leave period in case if any middle approver change it, then next should be see updated info and not old one 
									Inner join #tbl_Leave_App TLAP ON TLAP.Leave_App_ID = LAD.IO_Tran_Id 
									inner Join #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
									Inner join (SELECT Leave_App_ID FROM #tbl_Leave_App) Qry ON LAD.IO_Tran_Id = Qry.Leave_App_ID
									Left Outer Join 
													(select SM.shift_st_time,SM.shift_end_time,Emp_ID 
													from t0040_shift_master SM 
													right outer join (select Q.emp_id,Q1.for_date, Q1.shift_id 
																		from t0100_emp_shift_detail Q1 
																		inner join (select max(For_Date)as For_Date,Emp_ID 
																		from t0100_emp_shift_detail 
																		where For_Date <= Getdate()  
																		group by emp_ID )Q on Q1.emp_ID =Q.Emp_ID 
																		and Q1.For_DAte = Q.For_Date) Q_W 
													on SM.shift_id=Q_w.shift_id) S on S.Emp_ID = LAD.Emp_ID
							WHERE IO_Tran_Id In (SELECT Leave_App_ID FROM #tbl_Leave_App)	
						
					End
				Else
					Begin
						
						INSERT INTO #Leave
							SELECT distinct	
								 LAD.Cmp_ID,LAD.Emp_ID,LAD.Emp_Name ,LAD.Emp_Full_Name, LAD.IO_Tran_Id, LAD.Emp_Code, LAD.Alpha_Emp_code
								 ,LAD.Reason,LAD.App_Date,
								 Isnull(Qry1.rpt_level + 1,'1') AS Rpt_Level,'0' AS Scheme_ID, '' AS Leave,  '1' AS Final_Approver
								 , '0' AS Is_Fwd_Leave_Rej,
								 Lad.Superior,
								 lad.For_Date
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else isnull(Qry1.In_Time, lad.In_Time) end AS In_Time   -- Change by ronakk 21112022
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else isnull(Qry1.Out_Time,lad.Out_Time) end AS Out_Time  -- Change by ronakk 21112022
								 , lad.In_Time  AS In_Time   -- Change by ronakk 23032023
								 ,lad.Out_Time  AS Out_Time  -- Change by ronakk 23032023
								 ,@is_res_passed, LAD.Branch_ID,
								 Isnull(Qry1.Is_Cancel_Late_In,LAD.Is_Cancel_Late_In) AS Is_Cancel_Late_In
								 ,Isnull(Qry1.Is_Cancel_Early_Out,Lad.Is_Cancel_Early_Out) AS Is_Cancel_Early_Out
								 ,Isnull(Qry1.Half_Full_day,Lad.Half_Full_day) AS Half_Full_day,
								 LAD.Other_Reason,0 as Max_Leave_Days   --Added By Jimit 03082018
								 ,LAD.Actual_In_Time
								 ,LAD.Actual_Out_Time
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else LAD.Actual_In_Time end Actual_In_Time -- Change by ronakk 21112022
								 --,case when isnull(Chk_By_Superior,0) = 0 then null else LAD.Actual_Out_Time end Actual_Out_Time  -- Change by ronakk 21112022
								 ,s.Shift_St_Time,S.Shift_End_Time
							FROM View_Late_Emp	 LAD
									left outer join (SELECT lla.IO_Tran_Id AS App_ID, lla.In_Time, lla.Out_Time, Rpt_Level AS Rpt_Level ,lla.Is_Cancel_Late_In, lla.Is_Cancel_Early_Out,lla.Half_Full_day  FROM T0115_AttendanceRegu_Level_Approval lla WITH (NOLOCK) 
														inner join (SELECT max(rpt_level) AS rpt_level1, IO_Tran_Id
																		FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) 
																		group by IO_Tran_Id 
																	) Qry
														on qry.IO_Tran_Id = lla.IO_Tran_Id and qry.rpt_level1 = lla.rpt_level
													) AS Qry1 
									On  LAD.IO_Tran_Id = Qry1.App_ID
									Left Outer Join 
													(select SM.shift_st_time,SM.shift_end_time,Emp_ID 
													from t0040_shift_master SM 
													right outer join (select Q.emp_id,Q1.for_date, Q1.shift_id 
																		from t0100_emp_shift_detail Q1 
																		inner join (select max(For_Date)as For_Date,Emp_ID 
																		from t0100_emp_shift_detail 
																		where For_Date <= Getdate()  
																		group by emp_ID )Q on Q1.emp_ID =Q.Emp_ID 
																		and Q1.For_DAte = Q.For_Date) Q_W 
									on SM.shift_id=Q_w.shift_id) S on S.Emp_ID = LAD.Emp_ID
								WHERE
								 LAD.Cmp_ID = @Cmp_ID  and (Chk_By_Superior = 0 or Chk_By_Superior = 1)
					end			
				delete #tbl_Scheme_Leave
				delete #tbl_Leave_App
				
			
					Fetch Next FROM Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
			end 
		Close Employee_Cur
		Deallocate Employee_Cur
---Added by Jaina 29-04-2020 Start			
	    Declare @Month_st_Date as Datetime
		Declare @Month_End_date as Datetime
		declare @Branch_id as numeric(18,0)
		declare @For_Date as Datetime
		declare @Max_Leave_Days numeric(18,0)
		Declare @Total_Count numeric(18,0)
		Declare @A_Emp_Id numeric(18,0)
		Declare @cnt numeric(18,0) = 0

		Declare @Week_Start nvarchar(20)
		Declare @Week_End nvarchar(20)
		Declare @F_Count as numeric(18,0)= 0
		declare @TCnt as  numeric(18,0) = 0

		--select * from #Leave where Max_Leave_Days > 0 order by Emp_Id,For_Date asc
		

		Declare Attendance_Cur Cursor
			For select Emp_Id,Branch_id,For_Date,Max_Leave_Days from #Leave where Max_Leave_Days > 0 order by Emp_Id,For_Date asc
		Open Attendance_Cur
		Fetch Next FROM Attendance_Cur Into  @A_Emp_Id,@Branch_Id,@For_date,@Max_Leave_Days
		WHILE @@FETCH_STATUS = 0
			Begin
				
					select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,Month(@For_date),Year(@For_Date))
					
					if @For_date >= @Month_End_date
						begin
							If Month(@For_date) <> 12 -- Added by Hardik 24/12/2020 for Honda
								select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,Month(@For_date)+1,Year(@For_Date))
							Else
								select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,1,Year(@For_Date)+1)
						end
										
					-----------------------------------------------------------------------------------------------------
					--Code for Monday to Monday date
					--set @Week_Start = dateadd(week, datediff(week, 0, getdate()), 0)
					--set @Week_End = dateadd(week, datediff(week, 0, @Week_Start), +7)
					--select @Week_Start,@Week_End
					--select datename(dw,dateadd(week, datediff(week, 0, getdate()), 0))				
						
					
					
			        select @Total_Count = count(1) from T0150_EMP_INOUT_RECORD  WITH (NOLOCK) 
					where For_Date between @Month_st_Date and @Month_End_date and Reason <> ''
						  and App_Date is not null and Apr_Date is not null	and emp_id=@A_Emp_Id
					
					--print @A_Emp_Id
					--print @Total_Count
					--print @Max_Leave_Days
			
					--print 'aa'

					
					
								
					select @F_Count= count(1) from #Leave  L where Emp_id=@A_Emp_Id and Final_Approver = 1
					
								
					if  @Max_Leave_Days > 1										
						begin
							--select @F_Count,@Max_Leave_Days
							set @TCnt = @Max_Leave_Days - @Total_Count						
						end
					else
						begin
							set @TCnt = @Max_Leave_Days
						end
					
					if @Max_Leave_Days > @Total_Count and @TCnt > @F_Count
					begin					
						--select @A_Emp_Id,@F_Count	
						 update L set Final_Approver=1 from #Leave  L where Emp_id=@A_Emp_Id and For_date=@For_Date								 				 						 														
						 --set @F_Count =	@TCnt +  1			
					end
					
					
				 Fetch Next From Attendance_Cur Into @A_Emp_Id,@Branch_Id,@For_date,@Max_Leave_Days
			End
		Close Attendance_Cur
		Deallocate Attendance_Cur

		

			
		if @Type = 0
			begin
						
				If @Emp_ID_Cur > 0
					Begin
						SELECT * FROM #Leave order by #Leave.For_Date desc
					end
				else
					begin
						declare @queryExe AS nvarchar(1000)
						set @queryExe = 'SELECT * FROM #Leave WHERE ' + @Constrains + ' order by #Leave.For_Date desc '
						exec (@queryExe)
					end
			end
		else if @Type = 1
			begin
			
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL 
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT count(*) AS LateComer FROM #Leave						
					END
				ELSE
					SELECT count(*) AS LateComer FROM #Leave 
			end				
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Leave
	
END


