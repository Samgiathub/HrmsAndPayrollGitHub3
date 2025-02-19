

-- =============================================
-- Author:		<Muslim Gadriwala>
-- Create date: <09102014,,>
-- Description:	<Get Record Level Approval>
-- =============================================
create PROCEDURE [dbo].[SP_Get_OT_Level_Approval_Records_backup_24062024]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@R_Emp_ID	Numeric(18,0),
	@From_Date  datetime,
	@To_Date	datetime,
	@Rpt_level	Numeric(18,0),
	@Return_Record_set  tinyint = 2,
	@constraint varchar(max),
	@Type numeric(18,0)= 0,
	@Dept_ID numeric(18,0),
	@Grd_ID	 numeric(18,0)
AS
BEGIN
	Set Nocount on 
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
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 31012018 
	 
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD INNER JOIN T0040_Scheme_Master SM ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Over Time'

	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @SqlExcu = ''
	
	CREATE table #Responsiblity_Passed
	 (		 
	     Emp_ID	Numeric(18,0)	
	    ,is_res_passed tinyint default 1  
	 )  
	 
	 insert into #Responsiblity_Passed
	 SELECT @R_Emp_ID , 0
	 		
	 insert into #Responsiblity_Passed
	 SELECT DISTINCT manger_emp_id,1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO 
	 where pass_to_emp_id = @R_Emp_ID AND  getdate() >= from_date AND getdate() <= to_date and Type='OverTime'   --Added By Jimit 12122019
			
			
				
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
	   ,Is_RMToRM			TINYINT NOT NULL DEFAULT 0   --added By jimit 31012018
	 )  
	
	CREATE table #tbl_Leave_App
	 (
		Emp_Id			Numeric,
		For_Date		Datetime
	   ,Scheme_ID		Numeric(18,0)
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
		
	IF @Grd_ID = 0          
		set @Grd_ID = null          
	
	IF @Dept_ID = 0          
		set @Dept_ID = null 
		
	CREATE TABLE #Data         
   (         
	   Emp_Id   numeric ,         
	   For_date datetime,        
	   Duration_in_sec numeric,        
	   Shift_ID numeric ,        
	   Shift_Type numeric ,        
	   Emp_OT  numeric ,        
	   Emp_OT_min_Limit numeric,        
	   Emp_OT_max_Limit numeric,        
	   P_days  numeric(12,2) default 0,        
	   OT_Sec  numeric default 0  ,
	   In_Time datetime,
	   Shift_Start_Time datetime,
	   OT_Start_Time numeric default 0,
	   Shift_Change tinyint default 0,
	   Flag int default 0,
	   Weekoff_OT_Sec  numeric default 0,
	   Holiday_OT_Sec  numeric default 0,
	   Chk_By_Superior numeric default 0,
	   IO_Tran_Id	   numeric default 0, 
	   OUT_Time datetime,
	   Shift_End_Time datetime,			
	   OT_End_Time numeric default 0,	
	   Working_Hrs_St_Time tinyint default 0, 
	   Working_Hrs_End_Time tinyint default 0, 
	   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	   
   )  
   
   --IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK)
					  INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id WHERE SM.Scheme_Type = 'Over Time')
			BEGIN
				IF @Type = 0
					BEGIN
						SELECT * FROM #Data
					END
				ELSE IF @Type = 1
					BEGIN
						IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
							BEGIN
								TRUNCATE TABLE #Notification_Value
								INSERT INTO #Notification_Value
								SELECT 0 AS OTCOUNT
							END
						ELSE
							SELECT 0 AS OTCOUNT
					END	
						
				RETURN
			END
		

   SELECT * into #Data_Temp FROM #Data
   
   Create Table #Approved_OT
   (
	 Emp_ID numeric,
	 Work_date datetime
   )
   
    Create Table #OT_APPROVAL
    (
		Tran_Id	   numeric default 0, 
		Emp_Id   numeric ,         
	    For_date datetime,   
	    Working_Hour varchar(20),
	    OT_Hour varchar(20),
	    WeekOff_OT_Hour varchar(20),
	    Holiday_OT_Hour varchar(20),
	    P_Days_Count numeric(18,2),
	    Flag int default 0,
	    Shift_Start_Time datetime,
	    Shift_End_Time datetime,
	    In_Time datetime,
	    Out_Time datetime
    )
    
		declare @Emp_ID_Cur numeric(18,0)
		declare @is_res_passed tinyint
		
		

		set @Emp_ID_Cur = 0
		set @is_res_passed = 0
		
		
		
 		DECLARE @string_1	VARCHAR(MAX)
		
		--Added By Jimit 10102018
		CREATE table #Emp_Cons1 
						(
							Emp_ID numeric    
						) 
		CREATE UNIQUE CLUSTERED INDEX IX_Emp_Cons1_EMPID ON #Emp_Cons1(EMP_ID);
		--Ended
		DECLARE @String		VARCHAR(MAX)
 		DECLARE @Emp_Cmp_Id VARCHAR(MAX)
 		

		SELECT @String =  (SELECT (convert(nvarchar,EM.Cmp_ID)) + ','  
 		FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 			( select max(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER join (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) /*@Emp_ID*/ ) Qry 
 				on ERD1.Emp_ID = Qry.Emp_ID
 				where ERD1.Effect_Date <= getdate() and R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) /*@Emp_ID*/ GROUP by ERD1.Emp_ID
 			) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 			T0080_EMP_MASTER EM ON Em.Emp_ID = ERD.Emp_ID
		WHERE ERD.R_Emp_ID in (Select Emp_ID From #Responsiblity_Passed) --@Emp_ID   
		GROUP by EM.Cmp_ID for xml path ('') )		
		
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
			end	
			
					
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
						if exists (SELECT 1 from T0095_MANAGERS where Emp_id = @Emp_ID_Cur)
							BEGIN
								SELECT @Manager_Branch = branch_id from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur AND Effective_date = 
								(
										SELECT max(Effective_date) AS Effective_date from T0095_MANAGERS WITH (NOLOCK) 
										where Emp_id = @Emp_ID_Cur AND Effective_date <= getdate()
								)
							END
					WHILE @Rpt_level <= @MaxLevel
						Begin
							Set @Rpt_level_Minus_1 = @Rpt_level - 1
							if @Emp_ID_Cur > 0
								begin
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
										Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
										From T0050_Scheme_Detail WITH (NOLOCK) 
										Inner Join T0040_Scheme_Master  WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										Where App_Emp_Id = @R_Emp_ID and rpt_level = @Rpt_level	
										And T0040_Scheme_Master.Scheme_Type = 'Over Time'  
									 	 
									Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
							 			Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
										From T0050_Scheme_Detail WITH (NOLOCK)
										Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										Where  rpt_level = @Rpt_level and Is_RM = 1 
										And T0040_Scheme_Master.Scheme_Type = 'Over Time'	
								
								--Added By Jimit 31012018										
								 IF @Rpt_level = 2 AND ISNULL(@Emp_ID_Cur,0) <> '0'
									BEGIN
										 
										 SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Is_RMToRM)
													Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
													And T0040_Scheme_Master.Scheme_Type = ''Over Time''' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' Commented By Jimit as Cross Company Manager Login not showing application done by cross compny's Employee due to Scheme Id is not passing in the RM to RM's Sp (Dishman case)
										

										  EXEC (@string_1)
											
									END	
								--ENDED

								if @Manager_Branch > 0 
									begin
										Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
											Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Is_RMToRM 
											From T0050_Scheme_Detail WITH (NOLOCK)
											Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
											Where rpt_level = @Rpt_level and Is_BM = 1 
											And T0040_Scheme_Master.Scheme_Type = 'Over Time'
									end
								
								end
							else
								begin
										Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Max_Leave_Days,Is_RMToRM)
										Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Leave_Days,Is_RMToRM
										From T0050_Scheme_Detail WITH (NOLOCK)
										Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										Where T0040_Scheme_Master.Scheme_Type = 'Over Time'
								end								
							declare @rpt_levle_cur tinyint
							set @rpt_levle_cur = 0

							Declare Final_Approver Cursor
							For Select distinct Scheme_Id, Leave,rpt_level From #tbl_Scheme_Leave 
							Open Final_Approver
								Fetch Next From Final_Approver Into @Scheme_ID, @Leave,@rpt_levle_cur
							WHILE @@FETCH_STATUS = 0
								Begin
									If Exists (Select Scheme_Detail_ID From T0050_Scheme_Detail Where Scheme_Id = @Scheme_ID 
												And Leave = @Leave And Rpt_Level = @Rpt_level + 1 AND NOT_MANDATORY = 0)
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


						
							Declare cur_Scheme_Leave Cursor For 
								Select Scheme_Id, Leave,is_rpt_manager,is_branch_manager,Is_RMToRM From #tbl_Scheme_Leave where rpt_level = @Rpt_level
							Open cur_Scheme_Leave
								Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
								WHILE @@FETCH_STATUS = 0
								 begin
									
										
									TRUNCATE TABLE #Emp_Cons1
																
									If @is_branch_manager = 1
										begin	
											Insert Into #Emp_Cons1(Emp_ID)    
												select distinct	ES.Emp_ID 
												From	T0095_EMP_SCHEME ES 
														Inner Join(
																	select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																		where Effective_Date<=GETDATE()  And Type = 'Over Time'  And Cmp_ID = @Cmp_ID
																		GROUP BY emp_ID															
												    				) Qry on ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date 
																							and Scheme_Id = @Scheme_ID  And Type = 'Over Time'
														INNER JOIN T0095_Increment I ON ES.EMP_ID=I.EMP_ID
														INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
																	FROM	T0095_Increment I1 WITH (NOLOCK)
																			INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) As Increment_Effective_Date
																						FROM	T0095_Increment I2 WITH (NOLOCK)
																						WHERE	I2.Increment_Effective_Date <= getdate() 
																						GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
																	GROUP BY I1.Emp_ID)  I1 ON I1.Emp_ID=I.Emp_ID AND I1.Increment_ID=I.Increment_ID
													Where	ES.Scheme_Id = @Scheme_ID and I.Branch_ID = @Manager_Branch
															AND I.Cmp_ID = @Cmp_ID  AND isnull(I.Grd_ID,0) = isnull(@Grd_ID ,I.Grd_ID)      
															AND isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0)) 
														
																				
												set @constraint = null
												select  @constraint = COALESCE(@Constraint + '#','') + cast(EC.Emp_ID as varchar(18)) 
												from	#Emp_Cons1 EC

														--INNER join 
														-- (
														--		select I.Emp_ID From T0095_Increment I 
														--		inner join     
														--		(
														--			select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment    
														--			where Increment_Effective_date <= @From_Date 
														--			and Cmp_ID = @Cmp_ID  and isnull(Grd_ID,0) = isnull(@Grd_ID ,Grd_ID)      
														--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) group by emp_ID
														--		 ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
														-- ) as INC on INC.Emp_ID = EC.Emp_ID
													
													
												If @constraint <> ''
												begin		

													exec SP_CALCULATE_PRESENT_DAYS	@cmp_ID = @Cmp_ID,@From_Date = @From_Date,@To_Date = @To_Date,
																					@Branch_ID = 0,@Cat_ID = 0,@Grd_ID = 0,@Type_ID = 0,@Dept_ID = 0,@Desig_ID = 0,@Emp_ID = 0,
																					@constraint = @constraint,@Return_Record_set = 4,@StrWeekoff_Date = '',@Is_Split_Shift_Req = 0  	
																					
												end
													
																						
												Insert into #OT_APPROVAL
												select		isnull(Qry1.Tran_ID,0) as  Tran_ID,  DA.emp_ID,
															DA.For_date,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , 
															dbo.F_Return_Hours (OT_SEc) as OT_Hour, 
															dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
															dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour, 
															Da.P_days as P_Days_Count,Flag,Shift_Start_Time,Shift_End_Time,In_Time,OUT_Time
												  from		#Data DA  left outer join 
															(
																select	lla.Tran_Id As Tran_ID,lla.For_Date as For_Date,lla.Emp_ID, Rpt_Level as Rpt_Level 
																From	T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)	Inner join 
																		(
																			Select	max(rpt_level) as rpt_level1,Emp_ID,For_Date 
																			From	T0115_OT_LEVEL_APPROVAL  WITH (NOLOCK)
																			Where	For_Date  in ( select For_Date from #Data where Emp_ID in (select emp_ID from #Emp_Cons1 )) 
																			group by Emp_ID,For_Date
																		) Qry on qry.For_Date = lla.For_Date and Qry.Emp_ID = lla.Emp_ID and qry.rpt_level1 = lla.rpt_level														     
															) As Qry1 On  DA.For_Date = Qry1.For_Date and DA.Emp_Id = Qry1.Emp_ID
												 where (OT_Sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0) 						
										
										--select * from #OT_APPROVAL
										If @Rpt_level = 1
											Begin
												Set @SqlQuery = 	
													'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +   cast(@Rpt_level as VARCHAR(2)) +
														 ' From #OT_APPROVAL LAD 
															Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
															Where LAD.Tran_Id Not In (Select Tran_Id From T0115_OT_LEVEL_APPROVAL 
															Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  												 	  
											End
										Else
											Begin
												Set @SqlQuery = 	
													'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +   cast(@Rpt_level as VARCHAR(2)) +
														'  From #OT_APPROVAL LAD
														   Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
														   Where (	LAD.Tran_Id Not In 
																	(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL  WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + '
																	)
																	And LAD.Tran_Id In 
																	(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL  WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + '
																	)
																 )'    		  
											 End																											
										End
									Else If @is_rpt_manager = 1
										BEGIN
					
											

												Insert Into #Emp_Cons1(Emp_ID)    
												Select	distinct ERD.Emp_ID 
												From	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN	--Ankit 28012015
														(
															select	MAX(Effect_Date) as Effect_Date, Emp_ID 
															from	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
															where	Effect_Date<=GETDATE()
															GROUP BY emp_ID
														 ) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date INNER JOIN 
														 T0095_EMP_SCHEME  ES on ES.Emp_ID = ERD.Emp_ID INNER JOIN
														 (
																select	MAX(Effective_Date) as For_Date, Emp_ID 
																from	T0095_EMP_SCHEME WITH (NOLOCK)
																Where	Effective_Date<=GETDATE()  And Type = 'Over Time'
																GROUP BY emp_ID
														  ) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Scheme_Id = @Scheme_ID  And Type = 'Over Time' INNER JOIN 
														  T0095_Increment I ON ES.EMP_ID=I.EMP_ID INNER JOIN 
														  (
																SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
																FROM	T0095_Increment I1 WITH (NOLOCK) INNER JOIN 
																		(
																			SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) As Increment_Effective_Date
																			FROM	T0095_Increment I2 WITH (NOLOCK)
																			WHERE	I2.Increment_Effective_Date <= getdate() 
																			GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
																GROUP BY I1.Emp_ID
														  )  I1 ON I1.Emp_ID=I.Emp_ID AND I1.Increment_ID=I.Increment_ID														
												Where		R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  AND	
															--I.Cmp_ID = @Cmp_ID  AND 
															isnull(I.Grd_ID,0) = isnull(@Grd_ID ,I.Grd_ID) and
															isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0)) 	
	
										
											
												----Ankit 19032015
												Declare @Cur_Cmp_ID numeric
												SET @Cur_Cmp_ID = 0
												DECLARE Emp_Inout_Cur CURSOR FAST_FORWARD FOR 
													SELECT DISTINCT Cmp_ID FROM  #Emp_Cons1 EC INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.EMP_ID
												Open Emp_Inout_Cur
													Fetch Next From Emp_Inout_Cur Into @Cur_Cmp_ID
													WHILE @@FETCH_STATUS = 0
													Begin
															SET @CONSTRAINT  = NULL
															--Added BY Jimit 10102018														
															SELECT  @CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EC.EMP_ID AS VARCHAR(18)) 
															FROM	#EMP_CONS1 EC														
															--Ended


															TRUNCATE TABLE #Data

															Truncate table #Data_Temp
															exec SP_CALCULATE_PRESENT_DAYS @Cur_Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@CONSTRAINT,4,'',0  

															INSERT INTO #Data_Temp
															SELECT * FROM #data
															
														Fetch Next From Emp_Inout_Cur Into @Cur_Cmp_ID	
													end			
													Close Emp_Inout_Cur
													Deallocate Emp_Inout_Cur
											
											TRUNCATE TABLE #DATA

											INSERT INTO #Data
											SELECT * FROM #Data_Temp			
											----Ankit 19032015
														
														
												 
												Insert into #OT_APPROVAL
												select isnull(Qry1.Tran_ID,0) as  Tran_ID,  DA.emp_ID,DA.For_date,
												dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , 
												dbo.F_Return_Hours (OT_SEc) as OT_Hour, 
												dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
												dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour, 
												Da.P_days as P_Days_Count,Flag
												,Shift_Start_Time,Shift_End_Time,
												In_Time,OUT_Time
												  from #Data DA  
												left outer join 
												(
															select lla.Tran_Id As Tran_ID,lla.For_Date as For_Date,lla.Emp_ID, Rpt_Level as Rpt_Level 
															From T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
															Inner join 
															(
																Select	max(rpt_level) as rpt_level1,Emp_ID,For_Date 
																From	T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK)
																Where	For_Date  in ( select For_Date from #Data where Emp_ID in (select emp_ID from #Emp_Cons1 ))
																		and EXISTS (select 1 from #Data D where D.Emp_Id = OTA.Emp_ID)
																group by Emp_ID,For_Date
															 ) Qry on qry.For_Date = lla.For_Date and Qry.Emp_ID = lla.Emp_ID and qry.rpt_level1 = lla.rpt_level
														     
												) As Qry1 On  DA.For_Date = Qry1.For_Date and DA.Emp_Id = Qry1.Emp_ID
												 where (OT_Sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0)
												 	
												 	
											  If @Rpt_level = 1
												Begin
																			 
													Set @SqlQuery = 	
													'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +   cast(@Rpt_level as VARCHAR(2)) +
													 ' From #OT_APPROVAL LAD
													Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
													Where LAD.Tran_Id Not In 
													(		
															Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
															Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + '
													)' 

												End
											  Else
												Begin
													Set @SqlQuery = 	
													'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +   cast(@Rpt_level as VARCHAR(2)) +
													' From #OT_APPROVAL LAD Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
													  Where (LAD.Tran_Id Not In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																And LAD.Tran_Id In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + '
																		)
															)'    		
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
																									@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Over Time' 										
														
																										
												
												SET @Cur_Cmp_ID = 0
												DECLARE Emp_Inout_Cur CURSOR FAST_FORWARD FOR 
												SELECT DISTINCT Cmp_ID FROM  #EMP_CONS_RM EC INNER JOIN T0080_EMP_MASTER E ON EC.EMP_ID=E.EMP_ID
												Open Emp_Inout_Cur
												Fetch Next From Emp_Inout_Cur Into @Cur_Cmp_ID
												WHILE @@FETCH_STATUS = 0
													BEGIN																													
														SET @CONSTRAINT  = NULL
														
														--SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EC.EMP_ID AS VARCHAR(10))
														--FROM	(SELECT DISTINCT EMP_ID FROM #EMP_CONS_RM) EC 														
														--		INNER JOIN T0080_Emp_Master E ON E.Emp_ID=EC.Emp_ID
														--Where	E.Cmp_ID=@Cur_Cmp_ID
														
														--Added BY Jimit 10102018

														SELECT  @CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EC.EMP_ID AS VARCHAR(18)) 
														FROM	#EMP_CONS_RM EC
																INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.EMP_ID=I.EMP_ID
																INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.INCREMENT_ID) AS INCREMENT_ID
																			FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN 
																					(
																						SELECT	I2.EMP_ID, MAX(I2.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
																						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																						WHERE	I2.INCREMENT_EFFECTIVE_DATE <= GetDAte()
																						GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
																			GROUP BY I1.EMP_ID)  I1 ON I1.EMP_ID=I.EMP_ID AND I1.INCREMENT_ID=I.INCREMENT_ID
														WHERE	I.CMP_ID = @Cur_Cmp_ID  AND ISNULL(I.GRD_ID,0) = ISNULL(@GRD_ID ,I.GRD_ID)      
																			AND ISNULL(I.DEPT_ID,0) = ISNULL(@DEPT_ID ,ISNULL(I.DEPT_ID,0)) 
														--Ended

														--PRINT '3 : ' + @constraint
														TRUNCATE TABLE #Data
														TRUNCATE TABLE #Data_Temp

														exec SP_CALCULATE_PRESENT_DAYS @Cur_Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@CONSTRAINT,4,'',0  
														
														INSERT INTO #Data_Temp
														SELECT * FROM #data
																												
														Fetch Next From Emp_Inout_Cur Into @Cur_Cmp_ID															
													END			
												Close Emp_Inout_Cur
												Deallocate Emp_Inout_Cur
												
												TRUNCATE TABLE #DATA
												
												INSERT INTO #DATA
												SELECT * FROM #Data_Temp
													
												
																													
												Insert into #OT_APPROVAL
												select isnull(Qry1.Tran_ID,0) as  Tran_ID,  DA.emp_ID,DA.For_date,
												dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , 
												dbo.F_Return_Hours (OT_SEc) as OT_Hour, 
												dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
												dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour, 
												Da.P_days as P_Days_Count,Flag
												,Shift_Start_Time,Shift_End_Time,
												In_Time,OUT_Time
												  from #Data DA  
												left outer join 
												(
															select lla.Tran_Id As Tran_ID,lla.For_Date as For_Date,lla.Emp_ID, Rpt_Level as Rpt_Level 
															From T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
															Inner join 
															(
																Select	max(rpt_level) as rpt_level1,Emp_ID,For_Date 
																From	T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK)
																Where	For_Date  in ( select For_Date from #Data where Emp_ID in (select emp_ID from #EMP_CONS_RM ))
																		
																		and EXISTS (select 1 from #Data D where D.Emp_Id = OTA.Emp_ID)
																group by Emp_ID,For_Date
															 ) Qry on qry.For_Date = lla.For_Date and Qry.Emp_ID = lla.Emp_ID and qry.rpt_level1 = lla.rpt_level
														     
												) As Qry1 On  DA.For_Date = Qry1.For_Date and DA.Emp_Id = Qry1.Emp_ID
												 where (OT_Sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0)	
												 	
													
													
													Set @SqlQuery = 	
													'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +   cast(@Rpt_level as VARCHAR(2)) +
													' From	#OT_APPROVAL LAD Inner Join 
															#EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID 
															LEFT OUTER JOIN (SELECT Tran_Id,Emp_ID,S_Emp_ID FROM T0115_OT_LEVEL_APPROVAL LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																												ON LAD.Tran_Id=LA.Tran_Id And LAD.EMP_ID=LA.EMP_ID
													  Where (LAD.Tran_Id Not In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = EC.Rpt_Level )
																And LAD.Tran_Id In 
																		(
																			Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																			Where Rpt_Level = EC.Rpt_Level - 1 --AND Ec.R_Emp_Id = S_Emp_Id
																		)
															)'    			
																			
												--PRINT @SqlQuery
												
											END
													
												
										END
									
									------------Ended-----------------	
									
									
									Else if @is_rpt_manager = 0 and @is_branch_manager = 0 and @is_Reporting_To_Reporting_manager = 0
										Begin
											
											Insert Into #Emp_Cons1(Emp_ID)    
											Select ES.Emp_ID 
											From   T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
													(
														select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
														where Effective_Date<=GETDATE()  And Type = 'Over Time' GROUP BY emp_ID
													) Qry on ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date 
																					and Scheme_Id = @Scheme_ID And Type = 'Over Time'  INNER JOIN 
													T0095_Increment I WITH (NOLOCK) ON ES.EMP_ID=I.EMP_ID INNER JOIN 
													(
														SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
														FROM	T0095_Increment I1 WITH (NOLOCK) INNER JOIN 
																(
																	SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) As Increment_Effective_Date
																	FROM	T0095_Increment I2 WITH (NOLOCK)
																	WHERE	I2.Increment_Effective_Date <= getdate() 
																	GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
														GROUP BY I1.Emp_ID
													)  I1 ON I1.Emp_ID=I.Emp_ID AND I1.Increment_ID=I.Increment_ID
											Where	ES.Scheme_Id = @Scheme_ID AND	
													--I.Cmp_ID = @Cmp_ID  AND 
													isnull(I.Grd_ID,0) = isnull(@Grd_ID ,I.Grd_ID) and
													isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0)) 		

													
											
															set @Cur_Cmp_ID = 0
															Declare Emp_Inout_Cur Cursor FAST_FORWARD For
															 SELECT DISTINCT Cmp_ID FROM  #Emp_Cons1 EC INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID=E.EMP_ID
															Open Emp_Inout_Cur
																Fetch Next From Emp_Inout_Cur Into @Cur_Cmp_ID
																WHILE @@FETCH_STATUS = 0
																Begin
																		SET  @CONSTRAINT = Null
																		--Added BY Jimit 10102018																	
																		SELECT  @CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EC.EMP_ID AS VARCHAR(18)) 
																		FROM	#Emp_Cons1 EC																	
																		--Ended

																		TRUNCATE TABLE #Data
																		TRUNCATE TABLE #Data_Temp
																		exec SP_CALCULATE_PRESENT_DAYS @Cur_Cmp_ID,@From_Date,@To_Date,0,0,0,0,0,0,0,@CONSTRAINT,4,'',0

																		INSERT INTO #Data_Temp	--Ankit 19032015
																		SELECT * FROM #data	
																		
																	Fetch Next From Emp_Inout_Cur Into @Cur_Cmp_ID
																end			
																Close Emp_Inout_Cur
																Deallocate Emp_Inout_Cur	
											
															TRUNCATE TABLE #DATA
															
															
															INSERT INTO #Data	--Ankit 19032015
															SELECT * FROM #Data_Temp
											
															Insert into #OT_APPROVAL
															select isnull(Qry1.Tran_ID,0) as  Tran_ID,  DA.emp_ID,DA.For_date,
																	dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , 
																	dbo.F_Return_Hours (OT_SEc) as OT_Hour, 
																	dbo.F_Return_Hours (isnull(Weekoff_OT_Sec,0)) as Weekoff_OT_Hour,
																	dbo.F_Return_Hours (Holiday_OT_Sec) as Holiday_OT_Hour, 
																	Da.P_days as P_Days_Count,Flag
																	,Shift_Start_Time,Shift_End_Time,In_Time,OUT_Time
															from #Data DA  
																left outer join 
																(
																	select lla.Tran_Id As Tran_ID,lla.For_Date as For_Date,lla.Emp_ID, Rpt_Level as Rpt_Level 
																	From T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK)
																	Inner join 
																	(
																		Select max(rpt_level) as rpt_level1,OLT.Emp_ID,OLT.For_Date 
																		From T0115_OT_LEVEL_APPROVAL OLT WITH (NOLOCK)
																		inner join #Emp_Cons1 EC on EC.Emp_ID = OLT.Emp_ID Inner join
																		#DAta SDA on SDA.Emp_ID = OLT.Emp_ID and SDA.For_Date = OLT.For_Date 
																		group by OLT.Emp_ID,OLT.For_Date
																	) Qry on qry.For_Date = lla.For_Date and Qry.Emp_ID = lla.Emp_ID and qry.rpt_level1 = lla.rpt_level
										     
																) As Qry1 On  DA.For_Date = Qry1.For_Date and DA.Emp_Id = Qry1.Emp_ID
															 where (OT_Sec > 0 or Weekoff_OT_Sec > 0 or Holiday_OT_Sec > 0)
																		
												
													 		
											If @Rpt_level = 1
												Begin
													Set @SqlQuery = 	
														'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +  cast(@Rpt_level as VARCHAR(2)) +
															' From #OT_APPROVAL LAD Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
															  Where LAD.Tran_Id Not In 
															  (
																Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + '
															   )'  											  	  
												End
											Else
												Begin
													Set @SqlQuery = 	
														'Select EC.Emp_Id,For_Date, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, '  +   cast(@Rpt_level as VARCHAR(2)) +
														 ' From #OT_APPROVAL LAD Inner Join #Emp_Cons1 Ec on LAD.Emp_Id = Ec.Emp_ID
														   Where (LAD.Tran_Id Not In (
																						Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK) Where 
																						 Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + '
																					  ) And LAD.Tran_Id 
																					In (
																						Select Tran_Id From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
																						Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + '
																						)
																 )'    
												 End
										end	
										--select 202
									Insert Into #tbl_Leave_App (Emp_Id,For_Date, Scheme_ID,rpt_level)
										exec (@SqlQuery)
									--select 313
										delete from #Data
										DELETE from #Emp_Cons1
										--Drop Table #Emp_Cons1
									Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
								End
								Close cur_Scheme_Leave
								Deallocate cur_Scheme_Leave
											set @Rpt_level = @Rpt_level + 1
							End
					End 			 
					
					IF OBJECT_ID('tempdb..#OVERTIME') IS NOT NULL
					begin
							drop table #OVERTIME
					end
					
						--Added By Jimit 22102018
						CREATE TABLE #OVERTIME
							(								
								Tran_Id					NUMERIC(18,0) IDENTITY
								,Cmp_ID					NUMERIC(18,0)
								,Emp_ID					NUMERIC(18,0)								
								,Alpha_Emp_code			NVARCHAR(100)
								,For_DATE				DATETIME								
								,Emp_Full_Name			NVARCHAR(200)
								,Working_Hour			VARCHAR(10)
								,Ot_Hour				VARCHAR(10)
								,Flag					Numeric(18,0)
								,Weekoff_OT_Hour		VARCHAR(10)
								,Holiday_OT_Hour		VARCHAR(10)
								,P_Days_Count			NUMERIC(18,2)
								,Final_Approver			TINYINT
								,Is_Fwd_OT_Rej			TINYINT
								,rpt_level				TINYINT
								,Approved_OT_Hour		VARCHAR(10)
								,Approved_Weekoff_OT_Hour VARCHAR(10)
								,Approved_HO_OT_Hour	VARCHAR(10)
								,Is_Approved			TINYINT
								,Editable_Records		TINYINT
								,Remark					VARCHAR(500)
								,Final_Tran_ID			NUMERIC(18,0)
								,Shift_Start_Time		datetime
								,Shift_End_Time			datetime
								,In_Time				datetime
								,Out_Time				datetime
								,Comment				VARCHAR(1000) DEFAULT ''							
							)

					
					
						INSERT INTO #OVERTIME
						select distinct  
							EM.Cmp_ID,DA.emp_ID,EM.Alpha_EMP_CODE,DA.For_date,EM.Emp_Full_Name,
							Working_Hour,OT_Hour,Flag,Weekoff_OT_Hour,Holiday_OT_Hour, DA.P_Days_Count,
							SL.Final_Approver,SL.Is_Fwd_Leave_Rej as Is_Fwd_OT_Rej,SL.rpt_level , 
							--Commented By Jimit 29112019
							CAse WHen SL.Rpt_Level = 1 then ( case when isnull(Qry1.Approved_OT_Sec,0) = 0 then OT_Hour else dbo.F_Return_Hours(Qry1.Approved_OT_Sec) end ) 
								else dbo.F_Return_Hours(Qry1.Approved_OT_Sec) End as Approved_OT_Hour ,
							
							CASe WHEN SL.Rpt_Level = 1 then ( case when ISNULL(Qry1.Approved_WO_OT_Sec,0) = 0 then Weekoff_OT_Hour else dbo.F_Return_Hours(Qry1.Approved_WO_OT_Sec) end )
								else dbo.F_Return_Hours(Qry1.Approved_WO_OT_Sec) end as Approved_Weekoff_OT_Hour ,
							
							CASE WHEN SL.Rpt_Level = 1 then ( case when isnull(qry1.Approved_HO_OT_Sec,0) = 0 then  Holiday_OT_Hour else dbo.F_Return_Hours(Qry1.Approved_HO_OT_Sec) end )
								else dbo.F_Return_Hours(Qry1.Approved_HO_OT_Sec) end as Approved_HO_OT_Hour,
							--Ended
							--changed By Jimit 29112019 For solving the redmine bug 4699 for getting actual OT approved hours at second level
							--dbo.F_Return_Hours(Qry1.Approved_OT_Sec)  as Approved_OT_Hour ,
							--dbo.F_Return_Hours(Qry1.Approved_WO_OT_Sec) as Approved_Weekoff_OT_Hour ,
							--dbo.F_Return_Hours(Qry1.Approved_HO_OT_Sec)  as Approved_HO_OT_Hour,
							--Ended
							case when ISNULL(qry1.is_Approved,1) = 1 then 1 else qry1.is_approved end as Is_Approved ,
							1 as Editable_Records ,case when isnull(qry1.Remark,'') = '' then '' else Qry1.Remark end as Remark,
							0 as Final_Tran_ID,Shift_Start_Time,Shift_End_Time,In_Time,Out_Time,
							qry1.Comments   --Added By Jimit 04092018											
						 from #OT_APPROVAL DA  inner join 
								T0080_EMP_MASTER EM WITH (NOLOCK) on DA.Emp_ID = EM.Emp_ID left outer join 
							(	
								select lla.Tran_Id As App_ID, IsNull(Rpt_Level,0) as Rpt_Level,Approved_OT_Sec,Approved_WO_OT_Sec,Approved_HO_OT_Sec,
										Remark,is_approved,lla.Comments,lla.For_Date,lla.Emp_ID 
								From T0115_OT_LEVEL_APPROVAL lla WITH (NOLOCK) Inner join 
								(
									Select max(rpt_level) as rpt_level1, Emp_Id,For_Date 
									From T0115_OT_LEVEL_APPROVAL WITH (NOLOCK)
									--Where Tran_Id In (Select Leave_App_ID From #tbl_Leave_App) 
									group by Emp_Id,For_Date 
								) Qry on qry.For_Date = lla.For_Date and qry.rpt_level1 = lla.rpt_level And qry.Emp_ID = lla.Emp_ID
							) As Qry1 On  DA.Emp_Id = Qry1.Emp_ID And DA.For_date=Qry1.For_Date --DA.Tran_Id = Qry1.App_ID	
						Inner join #tbl_Leave_App TLAP On TLAP.For_Date = da.For_date And TLAP.Emp_Id = Da.Emp_Id
						inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID and SL.rpt_level > isnull(Qry1.Rpt_Level,0) 
									and  SL.rpt_level = TLAP.rpt_level 
						Left Outer join #Responsiblity_Passed RP on RP.Emp_ID = EM.Emp_ID
					    Where -- DA.Tran_Id In (Select distinct Leave_App_ID From #tbl_Leave_App) And
					    Not exists (select 1 from T0160_OT_APPROVAL WITH (NOLOCK) where Emp_ID = Da.Emp_Id and For_Date = Da.For_date)
					    and Not Exists (select 1 from T0120_CompOff_Approval WITH (NOLOCK) where Emp_ID = DA.Emp_Id and Extra_Work_Date = DA.For_date 
																				  and Approve_Status = 'A')
						order by DA.For_date
												
						
						Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
				end
				close Employee_Cur
				Deallocate Employee_Cur
				

				--Added By Jimit 22102018
						DELETE  OT
						FROM	#OVERTIME OT INNER JOIN
								T0095_INCREMENT IE ON IE.EMP_ID = OT.EMP_ID INNER JOIN 
								(
									SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 
									FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
											T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID	
											INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
														FROM	T0095_INCREMENT I3 WITH (NOLOCK)
														INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID	
														WHERE	I3.INCREMENT_EFFECTIVE_DATE <= GETDATE() AND 
														--I3.CMP_ID = @Cmp_Id AND 
																I3.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION')  										
														GROUP BY I3.EMP_ID  
														) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND 
														I2.EMP_ID=I3.EMP_ID 
									WHERE I2.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION') 
									GROUP BY I2.EMP_ID
								) I ON IE.EMP_ID = I.EMP_ID AND IE.INCREMENT_ID=I.INCREMENT_ID
						WHERE	(
									(IE.EMP_HOLIDAY_OT_RATE = 0 AND HOLIDAY_OT_HOUR <> '00:00') OR 
									(IE.EMP_WEEKOFF_OT_RATE = 0 AND WEEKOFF_OT_HOUR <> '00:00') OR
									(IE.EMP_WEEKDAY_OT_RATE = 0 AND OT_HOUR <> '00:00')
								)
						
						DECLARE @Setting_Value AS INT
							
						IF @Type = 0							
							BEGIN	
								--SELECT dbo.F_Get_OT_QUARTERLYHOURS(24471,'2020-09-10')
								SELECT *,dbo.F_Get_OT_QUARTERLYHOURS(Emp_ID,For_DATE)AS TOT_Qtr_Hours FROM #OVERTIME ORDER BY TOT_Qtr_Hours DESC,#OVERTIME.Emp_ID ASC
							END					
						ELSE IF @Type = 1
							BEGIN
								SELECT @Setting_Value=Setting_Value FROM T0040_SETTING where Setting_Name = 'Add number of Hours to restrict OT Approval' and cmp_Id =@cmp_id

								IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
									BEGIN
										TRUNCATE TABLE #Notification_Value
										IF(@Setting_Value > 0)
											BEGIN												
												--SELECT * FROM #OVERTIME WHERE CONVERT(VARCHAR(15),For_DATE,103)=CONVERT(VARCHAR(15),GETDATE(),103)
												INSERT INTO #Notification_Value
												SELECT COUNT(1) AS OTCOUNT FROM #OVERTIME WHERE CONVERT(VARCHAR(15),For_DATE,103)=CONVERT(VARCHAR(15),GETDATE(),103)
											END
										ELSE
											BEGIN	
												INSERT INTO #Notification_Value
												SELECT COUNT(1) AS OTCOUNT FROM #OVERTIME 
											END
									END
								ELSE
									SELECT COUNT(1) AS OTCOUNT FROM #OVERTIME 
								
							END	
						ELSE IF @Type = 2
							BEGIN
								INSERT INTO #PENDING_OVERTIME
								SELECT	Cmp_ID,Emp_ID,Alpha_Emp_code,For_DATE,
										Emp_Full_Name,Working_Hour,OT_Hour,Weekoff_OT_Hour,Holiday_OT_Hour
								FROM	#OVERTIME 
								ORDER BY #OVERTIME.Emp_ID ASC
							END		
					--Ended

							drop TABLE #tbl_Scheme_Leave
							drop TABLE #tbl_Leave_App
							drop TABLE #Responsiblity_Passed
							drop TABLE #Data
							drop TAbLE #Approved_OT
							drop TABLE #OVERTIME
							drop table #Emp_Cons1
		----drop TABLE #Leave
	
		END

