



CREATE PROCEDURE [dbo].[Get_Recruitment_Application_Records]
	@Cmp_ID		NUMERIC(18,0),
	@Emp_ID		NUMERIC(18,0),
	@Rpt_level	NUMERIC(18,0),
	@Constrains NVARCHAR(MAX),
	@Type NUMERIC(18,0)= 0

AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

IF @Constrains = ''
	SET @Constrains = '1=1'


	DECLARE @Scheme_ID AS NUMERIC(18,0)
	DECLARE @Leave AS VARCHAR(100)
	DECLARE @is_rpt_manager AS TINYINT
	DECLARE @is_branch_manager AS TINYINT
	DECLARE @is_HR AS TINYINT --added 29 Jan 2015 sneha
	DECLARE @is_HOD AS TINYINT --added 29 Jan 2015 sneha
	 
	DECLARE @SqlQuery AS NVARCHAR(MAX)
	DECLARE @SqlExcu AS NVARCHAR(MAX)
	DECLARE @MaxLevel AS NUMERIC(18,0)
	DECLARE @Rpt_level_Minus_1 AS NUMERIC(18,0)
	
	
	--Added by Jaina 11-11-2016 start
	DECLARE @Is_Fwd_Leave_Reject INT = 0
	DECLARE @strWhere VARCHAR(100)
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT 
	--Added by Jaina 11-11-2016 end
	  
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Recruitment Request'

	SET @is_rpt_manager = 0
	SET @is_branch_manager = 0
	SET @SqlExcu = ''
	SET @is_HR =0--added 29 Jan 2015 sneha
	SET @is_HOD =0--added 29 Jan 2015 sneha
	
	
	CREATE TABLE #Responsiblity_Passed
	 (		 
	     Emp_ID	NUMERIC(18,0)	
	    ,is_res_passed TINYINT DEFAULT 1  
	 )  
	 
	 INSERT INTO #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 INSERT INTO #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE pass_to_emp_id = @Emp_ID AND  GETDATE() >= from_date AND GETDATE() <= to_date  
	
	 CREATE TABLE #tbl_Scheme_Leave 
	 (
		Scheme_ID			NUMERIC(18,0)
	   ,Leave				VARCHAR(100) 
	   ,Final_Approver		TINYINT
	   ,Is_Fwd_Leave_Rej	TINYINT
	   ,is_rpt_manager		TINYINT NOT NULL DEFAULT 0
	   ,is_branch_manager	TINYINT NOT NULL DEFAULT 0
	   ,is_HOD				TINYINT NOT NULL DEFAULT 0--added 29 Jan 2015 sneha
	   ,is_HR				TINYINT NOT NULL DEFAULT 0--added 29 Jan 2015 sneha
	   ,rpt_level			NUMERIC(18,0)
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0
	 )  
	
	CREATE TABLE #tbl_Leave_App
	 (
		Leave_App_ID	NUMERIC(18,0)
	   ,Scheme_ID		NUMERIC(18,0)
	   ,Leave			VARCHAR(100) 
	   ,rpt_level		NUMERIC(18,0)
	 )
	 
	 IF @Rpt_level > 0
		BEGIN
			SET @MaxLevel = @Rpt_level
		END
	ELSE
		BEGIN
			SET @Rpt_level = 1
		END
		
	CREATE TABLE #RecruitmentRequest
	(
		 Rec_Req_ID		NUMERIC(18,0)
		,Job_Title		VARCHAR(150)
		,Posted_date	DATETIME
		,Grade_Name		VARCHAR(150)
		,Desig_Name     VARCHAR(150)
		,Branch_Name	VARCHAR(150)
		,[TYPE_NAME]		VARCHAR(50)
		,Dept_Name		VARCHAR(50)
		,Skill_Detail   NVARCHAR(Max)
		,Job_Description NVARCHAR(Max)
		,No_Of_Vacancies NUMERIC(3,0)
		,App_Status 	TINYINT
		,Qualification_detail VARCHAR(500)
		,Experience_Detail	VARCHAR(500)
		,BusinessSegment_Name VARCHAR(50)
		,Vertical_Name	VARCHAR(50)
		,SubVertical_Name	VARCHAR(50)
		,Rpt_Level				NUMERIC(18,0)
		,Scheme_ID				NUMERIC(18,0)	
		,Final_Approver		TINYINT
		,Is_Fwd_Leave_Rej	TINYINT
		,is_pass_over		TINYINT
		,Alpha_Emp_Code      VARCHAR(200)	
		,Emp_Full_Name		VARCHAR(200)
		,Emp_Id				NUMERIC(18,0)		
		,Tran_Id				NUMERIC(18,0)
		,MRF_Code			VARCHAR(250)
	)
	
	--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Recruitment Request')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #RecruitmentRequest
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
						BEGIN
							TRUNCATE TABLE #Notification_Value

							INSERT INTO #Notification_Value
							SELECT COUNT(*) AS LoanAppCnt FROM #RecruitmentRequest 
						END
					END	
						
				RETURN
			END
			
	
	DECLARE @Emp_ID_Cur NUMERIC(18,0)
	DECLARE @is_res_passed TINYINT
	
	SET @Emp_ID_Cur = 0
	SET @is_res_passed = 0
	
	------Get Sub Employee Cmp_Id
 		
 		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		DECLARE @string_1	VARCHAR(MAX)
 		
 		SELECT @String = ( SELECT DISTINCT(CONVERT(NVARCHAR,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 			( SELECT MAX(Effect_Date) AS Effect_Date,Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
 				WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID IN (SELECT Emp_ID FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
 																	WHERE R_Emp_ID = @Emp_ID) GROUP BY Emp_ID 
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID = @Emp_ID FOR XML PATH (''))
		
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			END	
		
		----
	DECLARE @Manager_Branch NUMERIC(18,0)
	DECLARE @Manager_HOD VARCHAR(MAX) --added 29 Jan 2015 sneha
	DECLARE @Manager_HR VARCHAR(MAX) --added 29 Jan 2015 sneha
	
	
	
	DECLARE Employee_Cur CURSOR
		FOR SELECT DISTINCT Emp_ID,is_res_passed FROM #Responsiblity_Passed
	OPEN Employee_Cur
		FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Rpt_level = 1
		
		IF @Emp_ID_Cur > 0
			BEGIN				
				SET @Manager_Branch = 0
							
				SET @Manager_HOD = 0
				
				SET @Manager_HR = ''
				
				IF EXISTS (SELECT 1 FROM T0095_MANAGERS WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur)
					BEGIN 
						SELECT @Manager_Branch = branch_id FROM T0095_MANAGERS WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur AND Effective_date = 
						( 
							SELECT MAX(Effective_date) AS Effective_date FROM T0095_MANAGERS WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur AND Effective_date <= GETDATE()
						)
					END
					--added 29 Jan 2015 sneha
					IF EXISTS (SELECT 1 FROM T0095_Department_Manager WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur)
						BEGIN 
							SELECT @Manager_HOD = COALESCE(CAST(@Manager_HOD AS VARCHAR(100)) + '#', '') + ''+ CAST( dm.dept_id AS VARCHAR(100)) + ''
							FROM T0095_Department_Manager DM WITH (NOLOCK) INNER JOIN 
							(SELECT MAX(effective_date) AS max_date,dept_id	 FROM T0095_Department_Manager WITH (NOLOCK) GROUP BY dept_id) MDM 
							ON DM.dept_id=MDM.dept_id AND DM.effective_date=MDM.max_date
							WHERE dm.emp_id=@Emp_ID_Cur
						END
				
				--added 29 Jan 2015 sneha 
				
				IF EXISTS (SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur)
					BEGIN 
						SELECT @Manager_HR = ISNULL(Branch_id_multi,'') FROM T0011_LOGIN WITH (NOLOCK) WHERE Emp_id = @Emp_ID_Cur AND Is_HR = 1						
					END
					
					WHILE @Rpt_level <= @MaxLevel
						BEGIN
						 SET @Rpt_level_Minus_1 = @Rpt_level - 1
						  IF @Emp_ID_Cur > 0
							BEGIN 
								INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,is_HOD,is_HR,rpt_level,Is_RMToRM)
								SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,is_HOD,is_HR,rpt_level,Is_RMToRM
								FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								WHERE App_Emp_Id = @Emp_ID_Cur AND rpt_level = @Rpt_level AND SM.Scheme_Type = 'Recruitment Request'
								
								--select * from #tbl_Scheme_Leave
								IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
									BEGIN 									
										SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,is_HOD,is_HR,rpt_level,Is_RMToRM)
														Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,is_HOD,is_HR,rpt_level,Is_RMToRM 
														From T0050_Scheme_Detail WITH (NOLOCK)
														Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
														Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
															And T0040_Scheme_Master.Scheme_Type = ''Recruitment Request'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
										
										
										EXEC (@string_1)
										
									END									
								Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
									BEGIN
										 
										 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
													Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
													And T0040_Scheme_Master.Scheme_Type = ''Recruitment Request''' 
										
										  EXEC (@string_1)
											
									END				
									
								IF @Manager_Branch > 0 
								BEGIN								
									INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Is_RMToRM 
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE rpt_level = @Rpt_level AND Is_BM = 1 AND SM.Scheme_Type = 'Recruitment Request'							
								END
								IF @Manager_HOD <> '' ---29 jan 2016
								BEGIN								
									INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_HOD,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,SD.Is_HOD,rpt_level,Is_RMToRM 
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE rpt_level = @Rpt_level AND Is_HOD = 1 AND SM.Scheme_Type = 'Recruitment Request'							
								END
								IF @Manager_HR <> '' ---29 jan 2016
								BEGIN							
									INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_HR,rpt_level,Is_RMToRM)
										SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,SD.Is_HR,rpt_level,Is_RMToRM 
										FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										WHERE rpt_level = @Rpt_level AND SD.Is_HR = 1 AND SM.Scheme_Type = 'Recruitment Request'							
								END
							END
						ELSE
							BEGIN							
								INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM)
								SELECT DISTINCT SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level,Is_RMToRM 
								FROM T0050_Scheme_Detail  SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
								WHERE SM.Scheme_Type = 'Recruitment Request'
							END
							
							DECLARE @rpt_levle_cur TINYINT
							SET @rpt_levle_cur = 0
							
							DECLARE Final_Approver CURSOR
								FOR SELECT DISTINCT Scheme_Id, Leave,rpt_level FROM #tbl_Scheme_Leave 
							OPEN Final_Approver
							FETCH NEXT FROM Final_Approver INTO @Scheme_ID, @Leave,@rpt_levle_cur
							WHILE @@FETCH_STATUS = 0
								BEGIN					 			
									IF EXISTS (SELECT Scheme_Detail_ID FROM T0050_Scheme_Detail WITH (NOLOCK)
													WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave AND Rpt_Level = @Rpt_level + 1 AND not_mandatory = 0)
										BEGIN 
											UPDATE #tbl_Scheme_Leave 
												SET Final_Approver = 0 
												WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave AND rpt_level =  @Rpt_level
										END
									ELSE 
										BEGIN 
											UPDATE #tbl_Scheme_Leave 
												SET Final_Approver = 1 
												WHERE Scheme_Id = @Scheme_ID AND Leave = @Leave  AND rpt_level =  @Rpt_level
										END
													
									FETCH NEXT FROM Final_Approver INTO @Scheme_ID, @Leave,@rpt_levle_cur
								END
							CLOSE Final_Approver
							DEALLOCATE Final_Approver		
							
							--select * from #Responsiblity_Passed						
							--select * from #tbl_Scheme_Leave
							DECLARE cur_Scheme_Leave CURSOR
								FOR SELECT DISTINCT Scheme_Id, Leave,is_rpt_manager,is_branch_manager,is_HOD,is_HR,Is_RMToRM FROM #tbl_Scheme_Leave WHERE rpt_level = @Rpt_level
							OPEN cur_Scheme_Leave
							FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_HOD,@is_HR,@is_Reporting_To_Reporting_manager
							WHILE @@FETCH_STATUS = 0
								BEGIN				
								--select @is_Reporting_To_Reporting_manager,@Rpt_level				
									CREATE TABLE #Emp_Cons 
									 (
									   Emp_ID NUMERIC    
									 )									
									 IF @is_branch_manager = 1
										BEGIN 
											INSERT INTO #Emp_Cons(Emp_ID)    
											SELECT ES.Emp_ID 
												FROM T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
													(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
													 WHERE Effective_Date<=GETDATE() AND TYPE='Recruitment Request'
													 GROUP BY emp_ID) Qry ON      
													 ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date      
													 AND Scheme_Id = @Scheme_ID  AND TYPE='Recruitment Request'
												INNER JOIN 
												(SELECT Branch_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
												   (SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)   
												   WHERE Increment_Effective_date <= GETDATE() AND Cmp_ID = @Cmp_ID GROUP BY emp_ID) Qry ON    
													I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date ) AS INC
													ON INC.Emp_ID = Qry.Emp_ID
												WHERE ES.Scheme_Id = @Scheme_ID AND INC.Branch_ID = @Manager_Branch
											
											IF @Rpt_level = 1
												BEGIN 												
													SET @SqlQuery = 	
													'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
															 ' From V0050_HRMS_Recruitment_Request LAD
																Inner Join #Emp_Cons Ec on LAD.S_Emp_ID = Ec.Emp_ID
															Where LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
																	Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
																  + ' And ' + @Constrains   
													 
												END
											ELSE  
												BEGIN													
													SET @SqlQuery = 	
													'Select DISTINCT LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
																 '  From V0050_HRMS_Recruitment_Request LAD
																	Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
																Where (LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																													
																And LAD.Rec_Req_ID In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
																									Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
															   )'    
																
														   + ' And ' + @Constrains
														
												END											
										END
									ELSE IF @is_rpt_manager = 1
										BEGIN 										
											INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT DISTINCT ERD.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
													INNER JOIN 
														T0095_EMP_SCHEME  ES WITH (NOLOCK) ON ES.Emp_ID = ERD.Emp_ID 
													INNER JOIN
													(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														 WHERE Effective_Date<=GETDATE()
														 AND TYPE='Recruitment Request'
														 GROUP BY emp_ID) Qry ON  ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date      
														 AND Scheme_Id = @Scheme_ID AND TYPE='Recruitment Request'
													WHERE R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID
													
												
													
											IF @Rpt_level = 1 
												BEGIN 
													SET @SqlQuery = 	
													'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
														  + ' And ' + @Constrains	  
												END
											ELSE
												BEGIN     												
													SET @SqlQuery = 	
													'Select DISTINCT LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where (LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
														And LAD.Rec_Req_ID In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )'   
																  + ' And ' + @Constrains
												END
										END
									--added on 29 Jan 2016 start
									ELSE IF @is_HOD = 1
										BEGIN  
											INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ES.Emp_ID 
												FROM T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
													(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
													 WHERE Effective_Date<=GETDATE() AND TYPE='Recruitment Request'
													 GROUP BY emp_ID) Qry ON      
													 ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date AND Scheme_Id = @Scheme_ID AND TYPE='Recruitment Request'
												INNER JOIN 
												(SELECT Branch_ID,I.Emp_ID,Dept_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
												   (SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)   
												   WHERE Increment_Effective_date <= GETDATE() AND Cmp_ID = @Cmp_ID GROUP BY emp_ID) Qry ON    
													I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date ) AS INC
													ON INC.Emp_ID = Qry.Emp_ID
												WHERE ES.Scheme_Id = @Scheme_ID --and INC.Dept_ID =@Manager_HOD
												AND  INC.Dept_ID IN(SELECT DATA FROM dbo.Split(@Manager_HOD,'#'))
																		
													
											IF @Rpt_level = 1 
												BEGIN 
													SET @SqlQuery = 	
													'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
														  + ' And ' + @Constrains	  
												END
											ELSE
												BEGIN     												
													SET @SqlQuery = 	
													'Select DISTINCT LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where (LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
														And LAD.Rec_Req_ID In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )'   
																  + ' And ' + @Constrains
																  
												END
										End--added on 29 Jan 2016 eND
										--added on 29 Jan 2016 start
									ELSE IF @is_HR = 1
										BEGIN 
										--select @Manager_HR,@Scheme_ID
											INSERT INTO #Emp_Cons(Emp_ID)    
												SELECT ES.Emp_ID 
													FROM T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
														(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
														 WHERE Effective_Date<=GETDATE() AND TYPE='Recruitment Request'
														 GROUP BY emp_ID) Qry ON      
														 ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date      
														 AND Scheme_Id = @Scheme_ID  AND TYPE='Recruitment Request'
													INNER JOIN 
													(SELECT Branch_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
													   (SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK)    
													   WHERE Increment_Effective_date <= GETDATE() AND Cmp_ID = @Cmp_ID GROUP BY emp_ID) Qry ON    
														I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date ) AS INC
														ON INC.Emp_ID = Qry.Emp_ID
													WHERE ES.Scheme_Id = @Scheme_ID 
													AND  INC.Branch_ID IN (CASE @Manager_HR WHEN '' THEN INC.Branch_ID WHEN '0' THEN INC.Branch_ID
														ELSE (SELECT DATA FROM dbo.Split(@Manager_HR,'#')) END)											
													--SELECT * from #Emp_Cons
											IF @Rpt_level = 1 
												BEGIN 												
													SET @SqlQuery = 	
													'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
														  + ' And ' + @Constrains	  
												END
											ELSE
												BEGIN    												
													SET @SqlQuery = 	
													'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where (LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
														And LAD.Rec_Req_ID In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )'   
																  + ' And ' + @Constrains
												END
										End--added on 29 Jan 2016 eND
										
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
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Recruitment Request' 										
														
																										
												
													--select * from #EMP_CONS_RM
														SET @SqlQuery = 'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
														Where (LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
														And LAD.Rec_Req_ID In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																	   )'   
																  + ' And ' + @Constrains										
																  
																  print @SqlQuery
											END	
										END										
									ELSE IF @is_rpt_manager = 0 AND @is_branch_manager = 0 AND @is_HOD = 0 AND @is_HR = 0 AND @is_Reporting_To_Reporting_manager = 0
										BEGIN 		
																	
											INSERT INTO #Emp_Cons(Emp_ID)   
											SELECT ES.Emp_ID 
											FROM T0095_EMP_SCHEME ES WITH (NOLOCK) INNER JOIN
												(SELECT MAX(Effective_Date) AS For_Date, Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK)
												 WHERE Effective_Date<=GETDATE() 
												 AND TYPE='Recruitment Request'
												 GROUP BY emp_ID) Qry ON      
												 ES.Emp_ID = Qry.Emp_ID AND ES.Effective_Date = Qry.For_Date      
												 AND Scheme_Id = @Scheme_ID AND TYPE='Recruitment Request'
											WHERE ES.Scheme_Id = @Scheme_ID 
											
											IF @Rpt_level = 1
												BEGIN												
													SET @SqlQuery = 	
														'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  CAST(@Rpt_level AS VARCHAR(2)) +
														' From V0050_HRMS_Recruitment_Request LAD
														Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
														Where LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
														Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')'  									
														+ ' And ' + @Constrains	
												END
											ELSE
												BEGIN													
													SET @SqlQuery = 	
													'Select LAD.Rec_Req_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) +
													' From V0050_HRMS_Recruitment_Request LAD
													 Inner Join #Emp_Cons Ec on LAD.S_Emp_Id = Ec.Emp_ID
													Where (LAD.Rec_Req_ID Not In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
													Where Rpt_Level = ' + CAST(@Rpt_level AS VARCHAR(2)) + ')																											
													And LAD.Rec_Req_ID In (Select Rec_Req_ID From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
													Where Rpt_Level = ' + CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
													)'  		
													+ ' And ' + @Constrains																	
												END
										END										
										INSERT INTO #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
										EXEC (@SqlQuery)
										
										
										DROP TABLE #Emp_Cons
										FETCH NEXT FROM cur_Scheme_Leave INTO @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_HOD,@is_HR,@is_Reporting_To_Reporting_manager
								END
							CLOSE cur_Scheme_Leave
							DEALLOCATE cur_Scheme_Leave
							
							----------------
							 SET @Rpt_level = @Rpt_level + 1
					END
			END
					
			--SELECT * FROM #tbl_Scheme_Leave
			--SELECT * FROM #tbl_Leave_App
			--SELECT 11,@Emp_ID_Cur
			IF @Emp_ID_Cur > 0
			BEGIN			
					INSERT INTO #RecruitmentRequest
				 	SELECT DISTINCT	rr.Rec_Req_ID
					,rr.Job_Title
					,rr.Posted_date
					,''
					,rr.Desig_Name
					,rr.Branch_Name
					,rr.Type_Name
					,rr.Dept_Name
					,rr.Skill_detail
					,rr.Job_Description
					,rr.No_of_vacancies
					,rr.App_status
					,rr.Qualification_detail
					,rr.Experience_Detail
					,''
					,''
					,''
					,ISNULL(Qry1.rpt_level + 1,'1') AS Rpt_Level
					,TLAP.Scheme_ID
					,SL.Final_Approver
					,SL.Is_Fwd_Leave_Rej
					,@is_res_passed	
					,''
					,rr.Emp_Full_Name
					,rr.S_Emp_ID				
					,0
					,rr.MRF_Code
					FROM V0050_HRMS_Recruitment_Request rr
				 LEFT OUTER JOIN (SELECT DISTINCT RLA.Rec_Req_ID AS App_ID, 
					   Rpt_Level AS Rpt_Level , 
					   RLA.RecApp_Status
					   FROM T0052_Hrms_RecruitmentRequest_Approval RLA WITH (NOLOCK)
					INNER JOIN (SELECT MAX(rpt_level) AS rpt_level1, Rec_Req_ID
									FROM T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
									WHERE Rec_Req_ID IN (SELECT DISTINCT Leave_App_ID FROM #tbl_Leave_App)
									GROUP BY Rec_Req_ID
								) Qry
					ON qry.Rec_Req_ID = RLA.Rec_Req_ID AND qry.rpt_level1 = RLA.rpt_level) AS Qry1 
						ON  rr.Rec_Req_ID = Qry1.App_ID							
						INNER JOIN #tbl_Leave_App TLAP ON TLAP.Leave_App_ID = rr.Rec_Req_ID
						INNER JOIN #tbl_Scheme_Leave SL ON SL.Scheme_ID = TLAP.Scheme_ID AND SL.Leave = TLAP.Leave AND  SL.rpt_level > ISNULL(Qry1.Rpt_Level,0) AND  SL.rpt_level = TLAP.rpt_level
						WHERE Rec_Req_ID IN (SELECT DISTINCT Leave_App_ID FROM #tbl_Leave_App)
			END
		ELSE
			BEGIN
			
				INSERT INTO #RecruitmentRequest
					SELECT DISTINCT	rr.Rec_Req_ID
							,rr.Job_Title
							,rr.Posted_date
							,''
							,rr.Desig_Name
							,rr.Branch_Name
							,rr.Type_Name
							,rr.Dept_Name
							,rr.Skill_detail
							,rr.Job_Description
							,rr.No_of_vacancies
							,rr.App_status
							,rr.Qualification_detail
							,rr.Experience_Detail
							,''
							,''
							,''
							,ISNULL(Qry1.rpt_level + 1,'1') AS Rpt_Level
							,'0' AS Scheme_ID
							,'1' AS Final_Approver
							,'0' AS Is_Fwd_Leave_Rej		
							,@is_res_passed
							,''
							,''
							,rr.Emp_Full_Name
							,rr.S_Emp_ID
							,0
							,rr.MRF_Code
					FROM V0050_HRMS_Recruitment_Request rr
					LEFT OUTER JOIN (
					SELECT RLA.Rec_Req_ID AS App_ID, 
						   Rpt_Level AS Rpt_Level , 
						   RLA.RecApp_Status
						   FROM T0052_Hrms_RecruitmentRequest_Approval RLA WITH (NOLOCK)
						INNER JOIN (SELECT MAX(rpt_level) AS rpt_level1, Rec_Req_ID
										FROM T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
										WHERE Rec_Req_ID IN (SELECT Leave_App_ID FROM #tbl_Leave_App)
										GROUP BY Rec_Req_ID 
									) Qry
						ON qry.Rec_Req_ID = RLA.Rec_Req_ID AND qry.rpt_level1 = RLA.rpt_level						
					) AS Qry1 
					ON  rr.Rec_Req_ID = Qry1.App_ID
				WHERE
				 rr.Cmp_ID = @Cmp_ID  AND (rr.App_status = 4 OR rr.App_status = 1)
			END		
		FETCH NEXT FROM Employee_Cur INTO  @Emp_ID_Cur,@is_res_passed
	END
	CLOSE Employee_Cur
	DEALLOCATE Employee_Cur
	
	
	
	IF @Type = 0
			BEGIN
				
				IF @Emp_ID_Cur > 0
					BEGIN
						--Added By Jaina 11-11-2016 Start
						SELECT @Is_Fwd_Leave_Reject = Is_Fwd_Leave_Rej FROM #RecruitmentRequest
						IF @Is_Fwd_Leave_Reject = 0
							BEGIN
								SELECT DISTINCT 0 AS is_Final_Approved,#RecruitmentRequest.*,c.Cat_Name,d.Dept_Name,dg.Desig_Name FROM #RecruitmentRequest 
								INNER JOIN	T0095_INCREMENT inc WITH (NOLOCK) ON inc.Emp_ID = #RecruitmentRequest.Emp_ID AND inc.Increment_ID= (SELECT MAX(Increment_ID) FROM T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = #RecruitmentRequest.Emp_Id)
								LEFT JOIN T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID = inc.Cat_ID 
								LEFT JOIN T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id = inc.Dept_ID
								LEFT JOIN T0040_DESIGNATION_MASTER dg WITH (NOLOCK) ON dg.Desig_ID = inc.Desig_Id	
								WHERE App_Status <> 2 AND Is_Fwd_Leave_Rej = 0
							END
						--Added By Jaina 11-11-2016 End
						ELSE
							BEGIN
								SELECT DISTINCT 0 AS is_Final_Approved,#RecruitmentRequest.*,c.Cat_Name,d.Dept_Name,dg.Desig_Name FROM #RecruitmentRequest 
								INNER JOIN	T0095_INCREMENT inc WITH (NOLOCK) ON inc.Emp_ID = #RecruitmentRequest.Emp_ID AND inc.Increment_ID= (SELECT MAX(Increment_ID) FROM T0095_INCREMENT WITH (NOLOCK) WHERE Emp_ID = #RecruitmentRequest.Emp_Id)
								LEFT JOIN T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID = inc.Cat_ID 
								LEFT JOIN T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id = inc.Dept_ID
								LEFT JOIN T0040_DESIGNATION_MASTER dg WITH (NOLOCK) ON dg.Desig_ID = inc.Desig_Id	
							END
						
						
						
					END
				ELSE
					BEGIN
						DECLARE @queryExe AS NVARCHAR(1000)
						SET @queryExe = 'select 0 As is_Final_Approved, * from #RecruitmentRequest where ' + @Constrains 
						EXEC (@queryExe)					
					END
			END
		ELSE IF @Type = 1
			BEGIN
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value

						INSERT INTO #Notification_Value
						SELECT COUNT(1) AS LoanAppCnt FROM #RecruitmentRequest
					END
			END				
		
		DROP TABLE #tbl_Scheme_Leave
		DROP TABLE #tbl_Leave_App
		DROP TABLE #Responsiblity_Passed
		DROP TABLE #RecruitmentRequest
END




