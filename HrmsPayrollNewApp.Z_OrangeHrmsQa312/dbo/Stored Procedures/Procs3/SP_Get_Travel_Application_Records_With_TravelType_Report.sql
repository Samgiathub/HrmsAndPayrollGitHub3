
CREATE  PROCEDURE [dbo].[SP_Get_Travel_Application_Records_With_TravelType_Report]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0,
	@OrderBy varchar(500)=''
	,@travelType Varchar(Max) ='0'
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
	Declare @rpt_Level_travel int 
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
	   ,Travel_Type_ID	int
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
		--select @String
		
		
		IF (@String IS NOT NULL)
			BEGIN
				SET @Emp_Cmp_Id = LEFT(@String, LEN(@String) - 1)
				
			end	
		else 
		Begin 
				set @Emp_Cmp_Id = @Cmp_ID
		END
		
		--Create table #Temp13 (Tran_ID integer,cmp_id  integer,Emp_ID  integer,Scheme_Id  integer,Type Varchar(50),Effective_Date datetime,IsMakerChecker bit,RptLevel integer,
	 --DynHierId integer,TravelTypeId Varchar(100),DynHierarchyId integer,DynHierColName varchar(20),DynHierColValue integer,DynHierColId integer,IncrementId integer,AppId integer)
		
		--================================Code Commented by Yogesh on 02022023=======================================================================================================
		--Declare @AppEmp as Numeric(18,0)
		--set @AppEmp=isnull((select top 1  AppEmp from T0080_Travel_HycScheme TT
		--inner join T0080_DynHierarchy_Value DV on DV.Emp_ID = TT.AppEmp and Dv.DynHierColValue = Tt.RptEmp and DV.DynHierColId = TT.DynHierId
		--where Dv.DynHierColValue = @Emp_ID ),0)
		--Declare @AppEmp as Varchar(18,0)
		--================================Code Commented by Yogesh on 02022023=======================================================================================================
		--================================Code Added by Yogesh on 02022023=======================================================================================================
		select distinct AppEmp,Cmp_ID into #AppEmp1 from T0080_Travel_HycScheme TT
		inner join T0080_DynHierarchy_Value DV on DV.Emp_ID = TT.AppEmp and Dv.DynHierColValue = Tt.RptEmp and DV.DynHierColId = TT.DynHierId
		where Dv.DynHierColValue = @Emp_ID
		
		select ROW_NUMBER() OVER(PARTITION BY Cmp_ID ORDER BY AppEmp ASC) as Rno ,AppEmp into #AppEmp  from #AppEmp1
		--================================Code Added by Yogesh on 02022023=======================================================================================================


		
		--------------------------------------------------------------------------- Add by Deepal 10022022
		Select distinct Tran_ID,ES.Cmp_ID,ES.Emp_ID,ES.Scheme_Id,Type,Effective_Date,IsMakerChecker,RptLevel,DynHierId,TravelTypeId,DynHierarchyId,DynHierColName,DynHierColValue,DynHierColId,IncrementId
		,AppId
		into #Temp12 
		from T0095_EMP_SCHEME ES
		inner join (
			SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T 
			Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
			inner join T0110_TRAVEL_APPLICATION_DETAIL TAD on Convert(Varchar,TAD.Instruct_Emp_ID) in (select AppEmp from #AppEmp) --Code Added by Yogesh on 02022023
				where Emp_ID in (select AppEmp from #AppEmp) And Type = 'Travel' 
				 and  t1.Leave LIKE  '%' +(Convert(Varchar,TAD.TravelTypeId)) +'%'
				 
				--and t1.leave LIKE Convert(Varchar,tad.TravelTypeId)+'%'--and CONVERT(varchar,TAD.TravelTypeId) in( t1.Leave) --and Leave in (18,17,16,15)
			--AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID in (select AppEmp from #AppEmp) And Type = 'Travel' AND Effective_Date <= getdate())  Code commented by 22052023
			AND Effective_Date in (SELECT Effective_Date from T0095_EMP_SCHEME where Emp_ID in (select AppEmp from #AppEmp) And Type = 'Travel' AND Effective_Date <= getdate())  
		) Q on ES.Scheme_Id = Q.Scheme_id
		inner join T0080_Travel_HycScheme TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId 
		--and TTH.TravelTypeId in (select Leave From T0050_Scheme_Detail where Scheme_Id = Q.Scheme_ID)
		Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId and Es.Emp_ID = Dv.Emp_ID 
		where DynHierColValue = @Emp_ID 
		--where Dv.Emp_ID in (select AppEmp from #AppEmp)
		--------------------------------------------------------------------------- ENd
		--select * from #Temp12
	--drop table #Temp12
	--return
		Declare Employee_Cur Cursor
			For Select distinct Emp_ID,is_res_passed From #Responsiblity_Passed
		Open Employee_Cur
		Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed

	--	select * from #Responsiblity_Passed
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
									BEGIN
										
										--Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Leave_Days,Is_RMToRM
										--From T0050_Scheme_Detail SD WITH (NOLOCK)
										--Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										--inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID and tt.RptLevel = @Rpt_level
										--inner join T0115_TRAVEL_LEVEL_APPROVAL TL on TL.Emp_ID=@Emp_ID and tl.Rpt_Level=@Rpt_level
										--Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) 
										--and Sd.rpt_level = @Rpt_level And SM.Scheme_Type = 'Travel' and SD.Cmp_Id = @Cmp_ID
										--union all
										--Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
										--From T0050_Scheme_Detail WITH (NOLOCK)
										--Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel'
										
										--Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Leave_Days,Is_RMToRM
										--From T0050_Scheme_Detail SD WITH (NOLOCK)
										--Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										--inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID and tt.RptLevel = @Rpt_level
										--inner join T0115_TRAVEL_LEVEL_APPROVAL TL on TL.Emp_ID=@AppEmp --and tl.Rpt_Level=@Rpt_level --'added new line by yogesh on 02012023
										--Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) 
										--and Sd.rpt_level = @Rpt_level And SM.Scheme_Type = 'Travel' and SD.Cmp_Id = @Cmp_ID
										
										--Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Leave_Days,Is_RMToRM
										--From T0050_Scheme_Detail SD WITH (NOLOCK)
										--Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										--inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID and tt.RptLevel = @Rpt_level
										----left join T0115_TRAVEL_LEVEL_APPROVAL TL on 
										-- --and tl.Rpt_Level=@Rpt_level --'added new line by yogesh on 02012023 --comment by deepal 05012023
										--Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) -- and TL.Emp_ID=@AppEmp
										--and Sd.rpt_level = 1 
										--And SM.Scheme_Type = 'Travel' and SD.Cmp_Id = @Cmp_ID
										
										--return

										-- Deepal Add the Logic 28122022
										Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
										Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Leave_Days,Is_RMToRM
										From T0050_Scheme_Detail SD WITH (NOLOCK)
										Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID and tt.RptLevel = @Rpt_level
										--inner join T0115_TRAVEL_LEVEL_APPROVAL TL on TL.Emp_ID=@AppEmp --and tl.Rpt_Level=@Rpt_level --'added new line by yogesh on 02012023 --comment by deepal 05012023
										Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) 
										and Sd.rpt_level = @Rpt_level And SM.Scheme_Type = 'Travel' and SD.Cmp_Id = @Cmp_ID
										union all
										Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
										From T0050_Scheme_Detail WITH (NOLOCK)
										Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel'
										
										
										--select * from #tbl_Scheme_Leave
										
										--select * from #temp12
										--if ((Select count(1) from #Temp12 ) > 0) and @Rpt_level >= 1
										--BEGIN
										--	Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
										--	Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Leave_Days,Is_RMToRM
										--	From T0050_Scheme_Detail SD WITH (NOLOCK)
										--	Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
										--	inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID and tt.RptLevel = @Rpt_level
										--	Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) 
										--	and Sd.rpt_level = @Rpt_level And SM.Scheme_Type = 'Travel' and SD.Cmp_Id = @Cmp_ID
										--END
										--Else
										--Begin 
										--	Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
										--	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
										--	From T0050_Scheme_Detail WITH (NOLOCK)
										--	Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--	Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel'
										--END
										-- Deepal Add the Logic 28122022
										
										
										
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
										BEGIN
											
											
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
	 															Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM 
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
																	And T0040_Scheme_Master.Scheme_Type = ''Travel'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
												
													--SET @string_1 = 'Insert Into #tbl_Scheme_Leave (SD.Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
	 												--Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM 
													--from T0095_EMP_SCHEME eS
													--inner join T0050_Scheme_Detail SD WITH (NOLOCK) on es.Scheme_ID=sd.Scheme_Id
													--inner Join T0040_Scheme_Master WITH (NOLOCK) ON sd.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													--Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
													--And T0040_Scheme_Master.Scheme_Type = ''Travel'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')' +'And Es.Emp_id='+ CAST(@AppEmp as Varchar(10))
														
												EXEC (@string_1)
												
										END						 	 
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
													--	
												END
												
										Else IF @Rpt_level = 3 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
										BEGIN
										
														--Declare @App_Emp_ID as numeric(18,0) = 0
														
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
											
									
										If isnull(@Manager_Branch,0) > 0 
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
								
								--select * from #tbl_Scheme_Leave

								 declare @rpt_levle_cur tinyint
								 set @rpt_levle_cur = 0
								 
							
								 
								Declare Final_Approver Cursor For 
									Select distinct Scheme_Id, Leave,rpt_level From #tbl_Scheme_Leave 
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
													--select * from #tbl_Scheme_Leave
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
							
							---------------------------------------------------------------------------------------------------------------------------------------------
								Declare cur_Scheme_Leave Cursor FOR
									Select distinct Scheme_Id, Leave,is_rpt_manager,is_branch_manager,Is_RMToRM From #tbl_Scheme_Leave where rpt_level = @Rpt_level
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
																	 ',isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id From V0100_TRAVEL_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And and ' + @Constrains 
																		  
																 
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ',isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id  From V0100_TRAVEL_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																													
																				And LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																			   )'    		
																		   + 'And ' + @Constrains
																		   
															End
																																				
													End
												Else if @is_rpt_manager = 1
													Begin
														
														if ((Select count(1) from #Temp12 ) > 0) and @Rpt_level = 1
														BEGIN
														
														--select @Scheme_ID
															Insert Into #Emp_Cons(Emp_ID)    
															Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
															(select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																 where Effect_Date<=GETDATE() 
																 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
																	INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
																		left JOIN -- change made from inner join to Left join by yogesh on 01032023 
																	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																	 Where Effective_Date<=GETDATE() And Type='Travel'
																	 GROUP BY emp_ID) Qry 
																	 on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID 
																	 And es.Type='Travel'
																	 
														END
														ELSE
														BEGIN
															
															Insert Into #Emp_Cons(Emp_ID)    
															Select ERD.Emp_ID 
															From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) 
															INNER JOIN 
															(
																select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
																where Effect_Date<=GETDATE()
																GROUP BY emp_ID
															 ) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
																INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
																	left JOIN -- change made from inner join to Left join by yogesh on 01032023 
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Travel'
																 GROUP BY emp_ID
																) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
																Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  

															
														END

											
													
														
															DELETE FROM #Emp_Cons 
															WHERE Emp_ID not  in (
																Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
																INNER JOIN 
																	( select MAX(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN #Emp_Cons EC1 on EC1.Emp_ID = ERD1.Emp_ID 
																		where Effect_Date<=GETDATE() GROUP BY ERD1.emp_ID
																	) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date 
																	and R_emp_id = @Emp_ID_Cur
																INNER JOIN #Emp_Cons EC on EC.Emp_ID = RQry.Emp_ID 
																--INNER JOIN T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID
															)

															--select * from #Emp_Cons
															

														If @Rpt_level = 1
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ',isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id From V0100_TRAVEL_APPLICATION LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																											 Where Rpt_Level in( ' + Cast(@Rpt_level as varchar(2)) + '))'  									
																		  + ' And ' + @Constrains
																
																--select @SqlQuery
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ',isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id From V0100_TRAVEL_APPLICATION LAD
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
																				
																				
																				SET @SqlQuery =	   'Select  Travel_Application_ID, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + ',Travel_Type_Id
																									FROM	(SELECT LAD.Travel_Application_ID,LAD.Application_Status,Application_Date,LAd.Alpha_Emp_Code,Emp_First_Name,isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id
																											From	V0100_TRAVEL_APPLICATION LAD 
																													INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																													LEFT OUTER JOIN (SELECT Travel_Application_ID,Emp_ID,S_Emp_ID,Approval_Status As App_Status FROM T0115_TRAVEL_LEVEL_APPROVAL LA WITH (NOLOCK) WHERE S_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																																		ON LAD.Travel_Application_ID=LA.Travel_Application_ID And LAD.EMP_ID=LA.EMP_ID
																											Where	 (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																															'And LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																														')																										
																											) T
																									WHERE	1=1  and ' + @Constrains
																									--select @SqlQuery
																						

																	END	
														END


												
												ELSE IF @Emp_ID_Cur <> 0 and @Rpt_level = 3
												BEGIN
													
														Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type='Travel'
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
														

														If @Rpt_level = 3
															Begin
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ',isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id From V0100_TRAVEL_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																 Where (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')																												
																			And LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																	  + ' And ' + @Constrains

															End
												END

												Else if @is_rpt_manager = 0 and @is_branch_manager = 0 AND @is_Reporting_To_Reporting_manager = 0
													Begin
														
															--IF ((SELECT COUNT(1) FROM #TEMP12 ) > 0) 
															--BEGIN 
														
															--	Insert Into #Emp_Cons(Emp_ID)    
															--	Select distinct ES.Emp_ID 
															--	From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
															--		(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															--		 Where Effective_Date<=GETDATE() And Type='Travel'
															--		 GROUP BY emp_ID) Qry on      
															--		 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
															--	inner join T0080_Travel_HycScheme TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
															--	--and RptEmp =@Emp_ID -- Deepal New add 14022022
															--	Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId
															--	Where ES.Scheme_Id = @Scheme_ID
															
															--END 
															--ELSE
															--BEGIN
															
															
															--	Insert Into #Emp_Cons(Emp_ID)    
															--	Select ES.Emp_ID 
															--	From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
															--		(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															--		 Where Effective_Date<=GETDATE() And Type='Travel'
															--		 GROUP BY emp_ID) Qry on      
															--		 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
															--	Where ES.Scheme_Id = @Scheme_ID 
																
															--END
															--if ((SELECT COUNT(1) FROM #TEMP12 ) > 0)
															--begin

															--end

															--select @Rpt_level
															
															IF ((SELECT COUNT(1) FROM #TEMP12 ) > 0) and  ((SELECT count(1) FROM #TEMP12 where RptLevel=@Rpt_level ) = 1) --Added 'and  'Condition by Yogesh on 05012022
															begin
															
																Insert Into #Emp_Cons(Emp_ID)    
																Select distinct ES.Emp_ID 
																From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																	 Where Effective_Date<=GETDATE() And Type='Travel'
																	 GROUP BY emp_ID) Qry on      
																	 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
																inner join T0080_Travel_HycScheme TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
																--and RptEmp =@Emp_ID -- Deepal New add 14022022
																Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId
																Where ES.Scheme_Id = @Scheme_ID

																union all
																Select ES.Emp_ID 
																From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																	 Where Effective_Date<=GETDATE() And Type='Travel'
																	 GROUP BY emp_ID) Qry on      
																	 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
																Where ES.Scheme_Id = @Scheme_ID 
																
																
															end
															else--Added 'and  'Condition by Yogesh on 05012022
															begin
														
													

													

													
															
																	Insert Into #Emp_Cons(Emp_ID)    
																		Select ES.Emp_ID 
																		From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																			(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																			 Where Effective_Date<=GETDATE() And Type='Travel'
																			 GROUP BY emp_ID) Qry on      
																			 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel'
																		Where ES.Scheme_Id = @Scheme_ID 
																
															end

										 				If @Rpt_level = 1
														Begin
																--Test 15022023
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +' 
																, isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id 
																From V0100_TRAVEL_APPLICATION LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) 
																													Where Rpt_Level <= ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																	  + 'And ' + @Constrains	
																	-- select @SqlQuery 
														
														End
														
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Application_ID, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																',isnull(LAD.Travel_Type_Id,0) as Travel_Type_Id From V0100_TRAVEL_APPLICATION LAD
																 Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																 Where (LAD.Travel_Application_ID Not In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																			and LAD.Travel_Application_ID In (Select Travel_Application_ID From T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																+ ' And ' + @Constrains

																
															End
														
														
													End	

												
												Insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level,Travel_Type_ID)
												exec (@SqlQuery)
												
									--select * from #tbl_Leave_App
												
												if ((select count(1) from #tbl_Leave_App) > 0 )
												Begin
												
													
													IF OBJECT_ID(N'tempdb..#temp') IS NOT NULL
													BEGIN
														DROP TABLE #temp
													END
													
													
													--ROW_NUMBER() OVER(PARTITION BY Travel_Type_ID ORDER BY data ASC) as Rno ,
													SELECT *,cast(data  as numeric) as Val into #temp 
													FROM #tbl_Leave_App
													CROSS APPLY dbo.Split(Leave,'#') 


													IF @is_rpt_manager = 1
													Begin 
															
														DELETE  from #tbl_Leave_App where Leave_App_ID not in(
														select Distinct La.Leave_App_ID from #temp  LA
																inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave
																inner join V0100_TRAVEL_APPLICATION VAD on LA.Val = VAD.Travel_Type_Id and LA.Leave_App_ID = VAD.Travel_Application_ID)

																
														
													END
													else
													BEGIN 
														  IF @is_Reporting_To_Reporting_manager = 1
														  Begin
														  
																--select Distinct VAD.Travel_Type_ID from #temp  LA 
																--	inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave 
																--	inner join V0100_TRAVEL_APPLICATION VAD on LA.Val = VAD.Travel_Type_Id and LA.Leave_App_ID = VAD.Travel_Application_ID
																DELETE TA from #temp TA where TA.Travel_Type_ID not in (
																		select Distinct VAD.Travel_Type_ID from #temp  LA 
																		inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave 
																		inner join V0100_TRAVEL_APPLICATION VAD on LA.Val = VAD.Travel_Type_Id and LA.Leave_App_ID = VAD.Travel_Application_ID
																) --a on TA.Travel_Type_ID <> A.Travel_Type_Id
																
																--DELETE TA from #tbl_Leave_App TA
																--inner join  #temp LA 
																--on  TA.Travel_Type_ID <> La.Travel_Type_ID

																
														END
													END
												END

										Drop Table #Emp_Cons
										Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_Reporting_To_Reporting_manager
									End
								Close cur_Scheme_Leave
								Deallocate cur_Scheme_Leave
								
							 set @Rpt_level = @Rpt_level + 1
							End

					End
					---------------------------------------------------------------------------------------------------------------------------------------------
				--select * from #tbl_Leave_App
				--select * from  #tbl_Scheme_Leave
				
					-- Add by Deepal 14022022

					-- Loop Added by Yogesh on 05012023 Start----------------------
					--set @Rpt_level = 1

					--WHILE @Rpt_level <= @MaxLevel
					--		Begin
							
								Set @Rpt_level_Minus_1 = @Rpt_level - 1
								If ((Select count(1) from #Temp12 ) > 0) and ( (Select RptLevel from #Temp12 where RptLevel=@Rpt_level ) = 1) --Added 'and  'Condition by Yogesh on 05012022
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
									left join T0080_Travel_HycScheme TS -- Code Change Inner join to Left join  by yogesh on 21122022
									on  Lp.Leave_App_ID = TS.AppId and Ts.RptEmp = @Emp_ID
									and LP.Scheme_ID = Ts.SchemeIId
									
									--inner join T0115_TRAVEL_LEVEL_APPROVAL LA
									--on La.Emp_ID=ts.AppEmp and la.Travel_Application_ID=TS.AppId and la.Rpt_Level=lp.rpt_level
									
									--Comment by deepal 27122022
									--Delete LP 
									--from #tbl_Leave_App LP inner join T0080_Travel_HycScheme TS 
									--on LP.Scheme_ID = TS.SchemeIId 
									--and TS.RptEmp = @Emp_ID
									--and Lp.Leave_App_ID <> TS.AppId 
									--Comment by deepal 27122022
								--	select * from T0080_Travel_HycScheme --where RptEmp = @Emp_ID
								--	select * from #tbl_Leave_App-- where RptEmp=@Emp_ID
									--select @Emp_ID


									--Delete LP 
									--from #tbl_Leave_App LP inner join T0080_Travel_HycScheme TS 
									--on LP.Scheme_ID = TS.SchemeIId 
									--and TS.RptEmp = @Emp_ID
									--and Lp.Leave_App_ID not in (select AppId from T0080_Travel_HycScheme where RptEmp = @Emp_ID)

									
									--select * from T0080_Travel_HycScheme
									--select @Emp_ID
									
									Delete LP 
									--select * 
									from #tbl_Leave_App LP inner join T0080_Travel_HycScheme TS 
									on LP.Scheme_ID = TS.SchemeIId 
									and TS.RptEmp = @Emp_ID
									and Lp.Leave_App_ID  in (select AppId from T0080_Travel_HycScheme where RptEmp = @Emp_Id)

									
									
									--Add by Deepal 14022022
									
									--	select distinct LP.* from #tempLeaveAPP LP
									--inner join T0080_Travel_HycScheme TS -- Code Change Inner join to Left join  by yogesh on 21122022
									--on  Lp.Leave_App_ID = TS.AppId --and Ts.RptEmp = @Emp_ID
									--and LP.Scheme_ID = Ts.SchemeIId
									

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
											Select distinct  TL.Leave_App_ID,Tl.Scheme_ID,TL.Leave,TL.rpt_level,Tl.Travel_Type_ID 
											from #temp T 
												inner join  (
													select * from #temp 
												)  TL on t.Travel_Type_ID = TL.data and t.Scheme_ID = Tl.Scheme_ID and T.Leave_App_ID = TL.Leave_App_ID
												
										IF Object_ID('tempdb..#EMP_CONS_RM') IS NOT NULL
										Begin
											Delete LA from  #tbl_Leave_App LA 
											inner join T0115_TRAVEL_LEVEL_APPROVAL L on LA.Leave_App_ID = L.Travel_Application_ID 
											inner join #EMP_CONS_RM EM on EM.Emp_ID = L.Emp_ID
										END
										

											DELETE from #temp  where Travel_Type_ID not in (
											select Distinct VAD.Travel_Type_ID from #temp  LA 
											inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave 
											inner join V0100_TRAVEL_APPLICATION VAD on LA.Val = VAD.Travel_Type_Id and LA.Leave_App_ID = VAD.Travel_Application_ID)

											DELETE TA from #tbl_Leave_App TA where TA.Travel_Type_ID not in (select Travel_Type_ID from #temp)

											DELETE from #temp  where Data not in (
											SELECT Distinct VAD.Travel_Type_Id from #temp  LA 
											inner join V0100_TRAVEL_APPLICATION VAD on  LA.Leave_App_ID = VAD.Travel_Application_ID and LA.Travel_Type_ID= LA.Val)
												
											DELETE TA from #tbl_Leave_App TA where TA.Scheme_ID not in (select Scheme_ID from #temp)

											
										END
										ELSE
										Begin
									
											DELETE TA from #tbl_Leave_App TA
											inner join  (
												select Distinct La.Leave_App_ID from #tbl_Leave_App  LA 
												inner join T0050_Scheme_Detail SD on LA.rpt_level = SD.Rpt_Level and LA.Leave = SD.Leave
												inner join V0100_TRAVEL_APPLICATION VAD on LA.Travel_Type_ID = VAD.Travel_Type_Id and LA.Leave_App_ID = VAD.Travel_Application_ID
											) a on TA.Leave_App_ID <> A.Leave_App_ID
										END
									END
								END
					
					--set @Rpt_level = @Rpt_level + 1
					--End
						-- Loop Added by Yogesh on 05012023 End----------------------	
					If @Emp_ID_Cur > 0
						Begin
						--select @Emp_ID
						--select * from #tbl_Leave_App
						
						
						--	Insert INTO #Travel
							Select distinct	
							
									  LAD.Application_Code as Application_Code,LAD.Application_Date as Application_Date,LAD.Alpha_Emp_code as Emp_code
									  , LAD.Emp_Full_Name as Emp_Full_Name , LAD.Branch_Name as Branch_Name, isnull(LAD.Supervisor,'Admin') as Manager,LAD.Application_Status as Application_Status--,LAD.Travel_Application_ID,LAD.Travel_Set_Application_id--,LAD.Travel_Application_ID
									--,LAD.Desig_Name ,LAD.Emp_ID
									--,LAD.Travel_Set_Application_id,LAD.travel_approval_id
									----,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID , SL.Final_Approver,SL.Is_Fwd_Leave_Rej ,DynHierColValue
									--,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, '0' as Scheme_ID, SL.Final_Approver,SL.Is_Fwd_Leave_Rej ,DynHierColValue
									From V0100_TRAVEL_APPLICATION LAD
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
							--order by Lad.travel_set_Application_id asc
							--and DynHierColValue = @Emp_ID_Cur
							
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
						
						
					--	Insert INTO #Travel
							Select distinct	
								LAD.Application_Code as Application_Code , LAD.Application_Date as Application_Date, LAD.Alpha_Emp_code as Emp_code, LAD.Emp_Full_Name as Emp_Full_Name
								, LAD.Branch_Name as Branch_Name, LAD.Supervisor as Manager,LAD.Application_Status as Application_Status--, LAD.Travel_Application_ID--LAD.Travel_Application_IDLAD.Emp_ID,
								--,LAD.Desig_Name 
								--,LAD.Travel_Set_Application_id--,LAD.travel_approval_id
								--,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,'0' as Scheme_ID, '1' as Final_Approver, '0' as Is_Fwd_Leave_Rej
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
							--order by Lad.travel_set_Application_id asc
								
						
					End			
					
				delete #tbl_Scheme_Leave
				delete #tbl_Leave_App
				
			
					Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
			End
		Close Employee_Cur
		Deallocate Employee_Cur
		
		declare @queryExe as nvarchar(1000)
		
		--select * from #Travel
		
		--If @Type = 0
		--	Begin
			
		--		If @Emp_ID_Cur > 0
		--			Begin
						
		--				set @queryExe=''
		--				set @queryExe='select *,dbo.F_GET_Emp_Visit('+  cast(@Cmp_ID as varchar(50)) +',#Travel.Travel_Application_ID,1) as Emp_Visit from #Travel Order by #Travel.Travel_Application_ID' --+ @OrderBy --order by #Travel.Application_Date desc						
		--				exec (@queryExe)
		--			End
		--		Else
		--			Begin
						
		--				set @queryExe=''
		--				set @queryExe = 'select *,dbo.F_GET_Emp_Visit('+cast(@Cmp_ID as varchar(50))+',#Travel.Travel_Application_ID,1) as Emp_Visit from #Travel where Order by #Travel.Travel_Application_ID'-- + @Constrains + ' ' + @OrderBy						
		--				exec (@queryExe)
		--			End
		--	End
			
		--Else if @Type = 1
		--	Begin

		--		IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
		--			BEGIN
		--				TRUNCATE TABLE #Notification_Value
		--				INSERT INTO #Notification_Value
		--				SELECT COUNT(1) AS travelAppCnt from #Travel
		--			END
		--		ELSE
		--			Begin
					
		--				SELECT COUNT(1) AS travelAppCnt from #Travel 
		--			END
		--		return
		--	End				
		drop table #Temp12
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Travel
	
END


