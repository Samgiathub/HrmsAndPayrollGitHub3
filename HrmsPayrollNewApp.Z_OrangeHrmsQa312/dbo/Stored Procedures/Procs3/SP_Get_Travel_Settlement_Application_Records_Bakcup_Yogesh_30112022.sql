
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

Create PROCEDURE [dbo].[SP_Get_Travel_Settlement_Application_Records_Bakcup_Yogesh_30112022]
	@Cmp_ID		Numeric(18,0),
	@Emp_ID		Numeric(18,0),
	@Rpt_level	Numeric(18,0),
	@Constrains Nvarchar(max),
	@Type numeric(18,0)= 0,
	@OrderBy varchar(500)=''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	Declare @Scheme_ID As Numeric(18,0)
	Declare @Leave As Varchar(100)
	Declare @is_rpt_manager As tinyint
	Declare @is_branch_manager As tinyint
	declare @is_hod as tinyint
	 
	Declare @SqlQuery As NVarchar(max)
	Declare @SqlExcu As NVarchar(max)
	declare @MaxLevel as numeric(18,0)
	Declare @Rpt_level_Minus_1 As Numeric(18,0)
	  
	DECLARE @is_Reporting_To_Reporting_manager AS TINYINT --Added By Jimit 18072018
	--set @MaxLevel =5
	SELECT @MaxLevel = ISNULL(MAX(Rpt_Level),1) FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
	WHERE SM.Scheme_Type = 'Travel Settlement'
	
	set @is_rpt_manager = 0
	set @is_branch_manager = 0
	set @is_hod=0
	
	set @SqlExcu = ''
	
	CREATE table #Responsiblity_Passed
	 (		 
	     Emp_ID	Numeric(18,0)	
	    ,is_res_passed tinyint default 1  
	 )  
	 
	 insert into #Responsiblity_Passed
	 SELECT @Emp_ID , 0
	 		
	 insert into #Responsiblity_Passed
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
	   ,Max_Leave_Days		numeric(18,2) --Hardik 07/03/2014
	   ,Is_Aprvl_Ovrlimit	tinyint
	   ,Is_HOD				tinyint not null default 0 --Added by Sumit 17092015
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
		,S_Emp_ID				numeric(18,0)
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
		,Advance_Amount			numeric(18,2)
		,Cmp_ID					numeric(18,0)
		,Tran_ID				numeric(18,0)
		,Is_Aprvl_Ovlimit		tinyint
		,Travel_App_Code        numeric(18,0)
		,Approved_Expense		numeric(18,2)
		,DirectEntry tinyint default 0
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
		Declare @TravelTypeSetting as integer=(Select Setting_Value from T0040_SETTING where Setting_Name = 'Enable Travel Type in Travel Module / Travel Expense' and Cmp_ID = @Cmp_ID)
	   		 	  
		-----------------------------------------------------------------------------------------------------------------------------------------------------------




		--IF SCHEME ARE NOT IN MASTER THEN RETURN	--Ankit 19102015
		IF NOT EXISTS(SELECT 1 FROM T0050_Scheme_Detail SD WITH (NOLOCK) INNER JOIN T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
		WHERE SM.Scheme_Type = 'Travel Settlement')
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
								SELECT COUNT(1) AS travelSettlementAppCnt from #Travel 
							END
						ELSE
							SELECT COUNT(1) AS travelSettlementAppCnt from #Travel 
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
				--select @Emp_Cmp_Id as a
			end	
		
		Declare @AppEmp as Numeric(18,0)
		select @AppEmp = AppEmp from T0080_Travel_HycScheme_Sett TT
		inner join T0080_DynHierarchy_Value DV on DV.Emp_ID = TT.AppEmp and Dv.DynHierColValue = Tt.RptEmp and DV.DynHierColId = TT.DynHierId
		where Dv.DynHierColValue = @Emp_ID 

		--select @Emp_ID,@AppEmp
		----------------------------------------------------------------------------- Add by Deepal 10022022
	
		Select distinct Tran_ID,ES.Cmp_ID,ES.Emp_ID,ES.Scheme_Id,Type,Effective_Date,IsMakerChecker,RptLevel
		,DynHierId,TravelTypeId,DynHierarchyId,DynHierColName,DynHierColValue,DynHierColId,IncrementId
		,AppId
		into #Temp12 
		from T0095_EMP_SCHEME ES
		inner join (
			SELECT DISTINCT T.Scheme_Id from T0095_EMP_SCHEME T 
			Inner Join T0050_Scheme_Detail T1 ON T.Scheme_ID = T1.Scheme_Id 
				where Emp_ID = @AppEmp And Type = 'Travel Settlement' and t1.Leave!='0'
			AND Effective_Date = (SELECT max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID = @AppEmp And Type = 'Travel Settlement' AND Effective_Date <= getdate()) 
		) Q on ES.Scheme_Id = Q.Scheme_id
		inner join T0080_Travel_HycScheme_Sett TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
		Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId and Es.Emp_ID = Dv.Emp_ID
		where DynHierColValue = @Emp_ID
		----------------------------------------------------------------------------- ENd
	
		----
 		declare @Manager_HOD as varchar(max)--numeric(18,0)
 		declare @Manager_Branch as varchar(max) --numeric(18,0)Code change if employee assigned for multi branch 02022016
		Declare Employee_Cur Cursor
			For Select distinct Emp_ID,is_res_passed From #Responsiblity_Passed
		Open Employee_Cur
		Fetch Next From Employee_Cur Into  @Emp_ID_Cur,@is_res_passed
		WHILE @@FETCH_STATUS = 0
			Begin
			
				set @Rpt_level = 1				 
				If @Emp_ID_Cur > 0
					Begin
					
						set @Manager_Branch = '0'
						if exists (SELECT 1 from T0095_MANAGERS WITH (NOLOCK) where Emp_id = @Emp_ID_Cur)
							BEGIN
							
								--SELECT @Manager_Branch = branch_id from T0095_MANAGERS where Emp_id = @Emp_ID_Cur AND Effective_date = 
								--(
								--	SELECT max(Effective_date) AS Effective_date from T0095_MANAGERS where Emp_id = @Emp_ID_Cur AND Effective_date <= getdate()
								--)
								select @Manager_Branch= COALESCE(cast(@Manager_Branch as varchar(100)) + ',', '') + ''+ cast( BM.branch_id as varchar(100)) + ''
									 from T0095_MANAGERS BM WITH (NOLOCK) inner join 
									(select max(effective_date) as max_date,branch_id	 from T0095_MANAGERS WITH (NOLOCK)  group by branch_id) BMB 
									on BM.branch_id=BMB.branch_id and BM.effective_date=BMB.max_date
									where BM.emp_id=@Emp_ID_Cur and BMB.max_date <= getdate()
							END							
							set @Manager_HOD='0'
						--select @Emp_ID_Cur
						
						if Exists(select 1 from T0095_Department_Manager WITH (NOLOCK) where Emp_id=@Emp_ID_Cur)
							Begin
								--select @Manager_HOD=dept_ID from T0095_Department_Manager where Emp_ID=@Emp_ID_Cur and Effective_Date =
								--(
								--	select MAX(effective_date) as Effective_date from T0095_Department_Manager where Emp_ID=@Emp_ID_Cur AND Effective_date <= getdate()
								--)
								select @Manager_HOD= COALESCE(cast(@Manager_HOD as varchar(100)) + ',', '') + ''+ cast( dm.dept_id as varchar(100)) + ''
									 from T0095_Department_Manager DM WITH (NOLOCK) inner join 
									(select max(effective_date) as max_date,dept_id	 from T0095_Department_Manager WITH (NOLOCK)  group by dept_id) MDM 
									on DM.dept_id=MDM.dept_id and DM.effective_date=MDM.max_date
									where dm.emp_id=@Emp_ID_Cur and MDM.max_date <= getdate()
							End
						--select @Rpt_level,@MaxLevel
		 				WHILE @Rpt_level <= @MaxLevel
							Begin
							
								 Set @Rpt_level_Minus_1 = @Rpt_level - 1
							
								 If @Emp_ID_Cur > 0
									Begin
										
											
											--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_Aprvl_Ovrlimit,Is_HOD,Is_RMToRM)
											--Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Approval_Overlimit_Travel_Settlmnt,isnull(Is_HOD,0),Is_RMToRM
											--From T0050_Scheme_Detail WITH (NOLOCK)
											--Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
											--inner join T0080_DynHierarchy_Value Dy on 
											--(T0050_Scheme_Detail.Dyn_Hier_Id = DY.DynHierColId or T0050_Scheme_Detail.Dyn_Hier_Id = 0)
											--and Dy.DynHierColValue = @Emp_ID
											--Where (App_Emp_Id = @Emp_ID OR App_Emp_Id = 0) and rpt_level = @Rpt_level	
											--And T0040_Scheme_Master.Scheme_Type = 'Travel Settlement'

										--select @Rpt_level,@Emp_ID
										
										if ((Select count(1) from #Temp12 ) > 0) and @Rpt_level >= 1
										
										BEGIN
												
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
											Select distinct SD.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,SD.rpt_level ,Leave_Days,Is_RMToRM
											From T0050_Scheme_Detail SD WITH (NOLOCK)
											Inner Join T0040_Scheme_Master SM WITH (NOLOCK) ON SD.Scheme_Id = SM.Scheme_Id
											inner join #Temp12 TT WITH (NOLOCK) on TT.Scheme_ID = SD.Scheme_Id and Tt.DynHierColValue = @Emp_ID 
											and tt.RptLevel = @Rpt_level
											Where (App_Emp_Id = @Emp_ID Or  App_Emp_Id = 0) and 
											Sd.rpt_level = @Rpt_level And SM.Scheme_Type = 'Travel Settlement' and SD.Cmp_Id = @Cmp_ID 
										
										
												

										END
										ELSe
										Begin 
								
										----------------------------------------------Added by yogesh on 14102022-----------------------------------------------------------------------------------
									

										--select distinct App_Emp_ID from T0050_Scheme_Detail SD inner join T0095_EMP_SCHEME ES on es.Scheme_ID=sd.Scheme_Id
										--	where es.Emp_ID=@Emp_ID and sd.Scheme_Id=(
										--	select distinct Max(sd.Scheme_Id) as sc from T0050_Scheme_Detail SD inner join T0095_EMP_SCHEME ES on es.Scheme_ID=sd.Scheme_Id 
										--	where es.Emp_ID=@Emp_ID  and es.Type='Travel Settlement' and sd.Leave!='0')
											--if @TravelTypeSetting=1 
											--begin
											--set @AppEmp=(select distinct App_Emp_ID from T0050_Scheme_Detail SD inner join T0095_EMP_SCHEME ES on es.Scheme_ID=sd.Scheme_Id
											--where es.Emp_ID=@Emp_ID and sd.Scheme_Id=(
											--select distinct Max(sd.Scheme_Id) as sc from T0050_Scheme_Detail SD inner join T0095_EMP_SCHEME ES on es.Scheme_ID=sd.Scheme_Id
											--where es.Emp_ID=@Emp_ID and es.Type='Travel Settlement' and sd.Leave!='0'))
											--end
											--Else
											--begin
											--set @AppEmp=(select distinct App_Emp_ID from T0050_Scheme_Detail SD inner join T0095_EMP_SCHEME ES on es.Scheme_ID=sd.Scheme_Id
											--where es.Emp_ID=@Emp_ID and sd.Scheme_Id=(
											--select distinct Max(sd.Scheme_Id) as sc from T0050_Scheme_Detail SD inner join T0095_EMP_SCHEME ES on es.Scheme_ID=sd.Scheme_Id
											--where es.Emp_ID=@Emp_ID and es.Type='Travel Settlement' and sd.Leave='0'))
											--end
										
											--select @Rpt_level,@AppEmp	
											---------------------------------------------------------------------------------------------------------------------------------
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM)
											Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Is_RMToRM
											From T0050_Scheme_Detail WITH (NOLOCK)
											Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
		--Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel Settlement' 'Commented by yogesh and added a new line below on 14102022
											Where App_Emp_Id = @Emp_ID and rpt_level = @Rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Travel Settlement' and Leave!='0'


										END
											--select * from #tbl_Scheme_Leave
									
											
										IF @Rpt_level = 1 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
										
											BEGIN
											
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_Aprvl_Ovrlimit,Is_RMToRM)
	 															Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Approval_Overlimit_Travel_Settlmnt,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RM = 1 
																	And T0040_Scheme_Master.Scheme_Type = ''Travel Settlement''  And T0050_Scheme_Detail.Leave!=''0'' and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
												
												EXEC (@string_1)
												--select @string_1
												--Select @Rpt_level
												--select * from #tbl_Scheme_Leave
												
											END						 	 
										Else IF @Rpt_level = 2 AND ISNULL(@Emp_Cmp_Id,0) <> '0'
											BEGIN
												SET @string_1 = 'Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_Aprvl_Ovrlimit,Is_RMToRM)
	 															Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days,Approval_Overlimit_Travel_Settlmnt,Is_RMToRM
																From T0050_Scheme_Detail WITH (NOLOCK)
																Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
																Where  rpt_level = '+ CAST(@Rpt_level AS VARCHAR(2)) +' and Is_RMToRM = 1 
																	And T0040_Scheme_Master.Scheme_Type = ''Travel Settlement'' And T0050_Scheme_Detail.Leave!=''0'' --and T0040_Scheme_Master.Cmp_Id In  ('+ @Emp_Cmp_Id +')'
												
												EXEC (@string_1)
												--Select @Rpt_level
												--select * from #tbl_Scheme_Leave
												
											END	
										--Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days)
										--	Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level ,Leave_Days
										--	From T0050_Scheme_Detail 
										--	Inner Join T0040_Scheme_Master ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
										--	Where  rpt_level = @Rpt_level and Is_RM = 1 And T0040_Scheme_Master.Scheme_Type = 'Travel Settlement'
											
										If @Manager_Branch is not null and @Manager_Branch <> '0' -- Deepal changes to @Manager_Branch <> 0 dt :- 07112022 to display notification
											Begin
											
												Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_Aprvl_Ovrlimit,Is_HOD,Is_RMToRM)
													Select distinct T0040_Scheme_Master.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Approval_Overlimit_Travel_Settlmnt,isnull(Is_HOD,0),Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where rpt_level = @Rpt_level and Is_BM = 1 And T0040_Scheme_Master.Scheme_Type = 'Travel Settlement' and T0050_Scheme_Detail.Leave!='0'
											End
										if @Manager_HOD is not null
											Begin
											
												Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_branch_manager,rpt_level,Max_Leave_Days,Is_Aprvl_Ovrlimit,Is_HOD,Is_RMToRM)
													Select distinct T0040_Scheme_Master.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_BM,rpt_level,Leave_Days,Approval_Overlimit_Travel_Settlmnt,isnull(Is_HOD,0),Is_RMToRM
													From T0050_Scheme_Detail WITH (NOLOCK)
													Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
													Where rpt_level = @Rpt_level and Is_HOD = 1 And T0040_Scheme_Master.Scheme_Type = 'Travel Settlement' and T0050_Scheme_Detail.Leave!='0'
											
											End		
											
									end
								 Else
									Begin
											Insert Into #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,rpt_level,Max_Leave_Days,Is_Aprvl_Ovrlimit,Is_HOD,Is_RMToRM)
												Select distinct T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,rpt_level ,Leave_Days,Approval_Overlimit_Travel_Settlmnt,isnull(Is_HOD,0),Is_RMToRM
												From T0050_Scheme_Detail WITH (NOLOCK)
												Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
												Where T0040_Scheme_Master.Scheme_Type = 'Travel Settlement' and T0050_Scheme_Detail.Leave!='0'
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
														Where Scheme_Id = @Scheme_ID And Leave = @Leave And Rpt_Level = @Rpt_level + 1 AND NOT_MANDATORY = 0 and T0050_Scheme_Detail.Leave!='0')
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
									For 
									Select Scheme_Id, Leave,is_rpt_manager,is_branch_manager,is_hod,Is_RMToRM From #tbl_Scheme_Leave where rpt_level = @Rpt_level
								Open cur_Scheme_Leave
								Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_hod,@is_Reporting_To_Reporting_manager
								WHILE @@FETCH_STATUS = 0
									Begin
										CREATE table #Emp_Cons 
										 (
										   Emp_ID numeric    
										 ) 
												 
												If @is_branch_manager = 1
													Begin
													Set @SqlQuery ='
									 					Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type=''Travel Settlement''
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id ='+cast(@Scheme_ID as varchar(100))+' And Type=''Travel Settlement''
															INNER JOIN 
															(select Branch_ID,I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
															   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
															   where Increment_Effective_date <= getdate() and Cmp_ID = '+cast(@Cmp_ID as varchar(100))+' group by emp_ID) Qry on    
																I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
																on INC.Emp_ID = Qry.Emp_ID
															Where ES.Scheme_Id = '+cast(@Scheme_ID as varchar(100))+' and INC.Branch_ID in ('+cast(@Manager_Branch as varchar(max))+')'
														Exec (@SqlQuery);
														set @SqlQuery='';
																												 
														
														If @Rpt_level = 1
															Begin															
																Set @SqlQuery = 	
																'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0140_Travel_Settlement_Application_New_Level LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains 
																 
															End
														Else
															Begin
														
															
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 '  From V0140_Travel_Settlement_Application_New_Level LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where (LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																													
																				And LAD.Travel_Set_Application_id In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																			   )'    
																				
																		   + ' And ' + @Constrains
																		   
															--print @SqlQuery			   
															End
																																				
													End
												Else if (@is_hod=1)
													Begin
														--Insert Into #Emp_Cons(Emp_ID)    
														--	Select ES.Emp_ID 
														--	From T0095_EMP_SCHEME ES Inner Join
														--		(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME
														--		 Where Effective_Date<=GETDATE() And Type='Travel Settlement'
														--		 GROUP BY emp_ID) Qry on      
														--		 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel Settlement'
														--	INNER JOIN 
														--	(select Branch_ID,I.Emp_ID,Dept_ID From T0095_Increment I inner join     
														--	   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment    
														--	   where Increment_Effective_date <= getdate() and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
														--		I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
														--		on INC.Emp_ID = Qry.Emp_ID
														--	Where ES.Scheme_Id = @Scheme_ID and INC.Dept_ID =@Manager_HOD
														set @SqlQuery='Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																 Where Effective_Date<=GETDATE() And Type=''Travel Settlement''
																 GROUP BY emp_ID) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id ='+cast( @Scheme_ID as varchar(100))+' And Type=''Travel Settlement''
															INNER JOIN 
															(select Branch_ID,I.Emp_ID,Dept_ID From T0095_Increment I WITH (NOLOCK) inner join     
															   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)    
															   where Increment_Effective_date <= getdate() and Cmp_ID ='+cast(@Cmp_ID as varchar(100))+' group by emp_ID) Qry on    
																I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date ) as INC
																on INC.Emp_ID = Qry.Emp_ID
															Where ES.Scheme_Id = '+cast(@Scheme_ID as varchar(100))+' and INC.Dept_ID in ('+cast(@Manager_HOD as varchar(max))+')'
															
														Exec(@SqlQuery); 
														set @SqlQuery=''
														
														If @Rpt_level = 1
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0140_Travel_Settlement_Application_New_Level LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains 
																 
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 '  From V0140_Travel_Settlement_Application_New_Level LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where (LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																													
																				And LAD.Travel_Set_Application_id In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
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
														--		 Where Effective_Date<=GETDATE() And Type='Travel Settlement'
														--		 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel Settlement'
														--		Where R_emp_id = @Emp_ID_Cur AND ES.Scheme_ID = @Scheme_ID  
													Insert Into #Emp_Cons(Emp_ID)    
													Select ERD.Emp_ID From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
														(select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
															 where Effect_Date<=GETDATE()
															 GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
														INNER JOIN 
															T0095_EMP_SCHEME  ES WITH (NOLOCK) on ES.Emp_ID = ERD.Emp_ID 
														INNER JOIN
														(select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
															 where Effective_Date<=GETDATE() And Type = 'Travel Settlement'--and Scheme_Id = @Scheme_ID -- max date issue on 12092013 - mitesh
															 --AND Cmp_ID = @Cmp_ID 
															 GROUP BY emp_ID) Qry on  ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date      and Scheme_Id = @Scheme_ID And Type = 'Travel Settlement'
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
																'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																	 ' From V0140_Travel_Settlement_Application_New_Level LAD
																		Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																														Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																		  + ' And ' + @Constrains
																					  
																		  
															End
														Else
															Begin
															
																Set @SqlQuery = 	
																'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave, '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0140_Travel_Settlement_Application_New_Level LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																												
																			And LAD.Travel_Set_Application_id In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
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
																															@New_Join_emp = 0,@Left_Emp = 0,@SalScyle_Flag = 0 ,@PBranch_ID = 0,@With_Ctc =0,@Type = 0 ,
																															@Scheme_Id = @Scheme_ID ,@Rpt_Level = 2 ,@SCHEME_TYPE = 'Travel Settlement' 										
																				
																			
																				SET @SqlQuery =	   'Select  Travel_Set_Application_id, ' + CAST(@Scheme_ID AS VARCHAR(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   CAST(@Rpt_level AS VARCHAR(2)) + '
																									FROM	(SELECT LAD.Travel_Set_Application_id,LAD.Status_New,For_date,LAd.Alpha_Emp_Code,Emp_First_Name
																											From	V0140_Travel_Settlement_Application_New_Level LAD 
																													INNER JOIN #EMP_CONS_RM Ec on LAD.Emp_Id = Ec.Emp_ID  
																													LEFT OUTER JOIN (SELECT Travel_Set_Application_id,Emp_ID,Manager_Emp_ID As S_Emp_ID,Status As App_Status FROM T0115_Travel_Settlement_Level_Approval LA WITH (NOLOCK) WHERE Manager_Emp_ID = ' + CAST(@Emp_ID_Cur AS VARCHAR(10)) + ') LA 
																																		ON LAD.Travel_Set_Application_id=LA.Travel_Set_Application_id And LAD.EMP_ID=LA.EMP_ID
																											Where	 (LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK) Where Rpt_Level = EC.Rpt_Level) ' +  --' + CAST(@Rpt_level AS VARCHAR(2)) + ')
																															'And LAD.Travel_Set_Application_id In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK) Where  Rpt_Level = EC.Rpt_Level - 1) ' +-- and Ec.R_Emp_Id = S_Emp_Id) ' + --+ CAST(@Rpt_level_Minus_1 AS VARCHAR(2)) + ')
																														')																													
																											) T
																									WHERE	1=1  and ' + @Constrains	
																		
																	END															
														END												
												------------Ended-----------------
														
												Else if @is_rpt_manager = 0 and @is_branch_manager = 0 and @is_Reporting_To_Reporting_manager = 0
													Begin
														Insert Into #Emp_Cons(Emp_ID)    
															Select ES.Emp_ID 
															From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
																(
																	 Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
																	 Where Effective_Date<=GETDATE() And Type='Travel Settlement'
																	 GROUP BY emp_ID
																 ) Qry on      
																 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel Settlement'
															Where ES.Scheme_Id = @Scheme_ID 
														
														--Insert Into #Emp_Cons(Emp_ID)    
														--	Select distinct ES.Emp_ID 
														--	From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
														--		(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
														--		 Where Effective_Date<=GETDATE() And Type='Travel Settlement'
														--		 GROUP BY emp_ID) Qry on      
														--		 ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date and Scheme_Id = @Scheme_ID And Type='Travel Settlement'
														--	inner join T0080_Travel_HycScheme_Sett TTH on ES.Emp_ID = TTH.AppEmp and  ES.Scheme_ID = TTh.SchemeIId
														--	--and RptEmp =@Emp_ID -- Deepal New add 14022022
														--	Inner join T0080_DynHierarchy_Value Dv on DV.DynHierColId = TTH.DynHierId
														--	Where ES.Scheme_Id = @Scheme_ID 
														
													
										 				If @Rpt_level = 1
															Begin
																--Set @SqlQuery = 	
																--'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
																-- ' From V0140_Travel_Settlement_Application_New_Level LAD
																--	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																--	Where LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																--													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																--	  + ' And ' + @Constrains	 

																	  Set @SqlQuery = 	
																'Select LAD.Travel_approval_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +  cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0140_Travel_Settlement_Application_New_Level LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																	Where LAD.Travel_approval_Id Not In (Select Travel_approval_Id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																													Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')'  									
																	  + ' And ' + @Constrains
															End
														Else
															Begin
															
																--Set @SqlQuery = 	
																--'Select LAD.Travel_Set_Application_id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																-- ' From V0140_Travel_Settlement_Application_New_Level LAD
																--	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																--Where (LAD.Travel_Set_Application_id Not In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																--												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																--			And LAD.Travel_Set_Application_id In (Select Travel_Set_Application_id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																--												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																--		   )'    
																			
																--	  + ' And ' + @Constrains
															
														
														
																 Set @SqlQuery = 	
																'Select LAD.Travel_approval_Id, ' + Cast(@Scheme_ID As Varchar(3)) + ' As Scheme_ID, ''' + @Leave + ''' As Leave , '  +   cast(@Rpt_level as VARCHAR(2)) +
																 ' From V0140_Travel_Settlement_Application_New_Level LAD
																	Inner Join #Emp_Cons Ec on LAD.Emp_Id = Ec.Emp_ID
																Where (LAD.Travel_approval_Id Not In (Select Travel_approval_Id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level as varchar(2)) + ')
																			And LAD.Travel_approval_Id In (Select Travel_approval_Id From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																												Where Rpt_Level = ' + Cast(@Rpt_level_Minus_1 as varchar(2)) + ')
																		   )'    
																			
																	  + ' And ' + @Constrains
														
															End

													End		
													
														
												Insert into #tbl_Leave_App (Leave_App_ID, Scheme_ID, Leave,rpt_level)
												
												exec (@SqlQuery)
												
												
										
										Drop Table #Emp_Cons
										Fetch Next From cur_Scheme_Leave Into @Scheme_ID, @Leave, @is_rpt_manager , @is_branch_manager,@is_hod,@is_Reporting_To_Reporting_manager
									End
								Close cur_Scheme_Leave
								Deallocate cur_Scheme_Leave
								
							 set @Rpt_level = @Rpt_level + 1
							End
					End
				
				--select * from #tbl_Scheme_Leave  --where scheme_id in (684,688,680,126)
				--select * from #tbl_Leave_App 
				--	select * from V0140_Travel_Settlement_Application_New_Level

				
							-- Add by Deepal 14022022
					Declare @App_Emp_ID as numeric(18,0) = 0
					IF ((Select count(1) from #Temp12 ) = 0)
					Begin
						Select @App_Emp_ID = App_Emp_ID from T0050_Scheme_Detail where Scheme_Id = @Scheme_ID 
					END		
					
					If ((Select count(1) from #Temp12 ) > 0) and @App_Emp_ID = 0
					Begin 
						IF OBJECT_ID(N'tempdb..#tempLeaveAPP') IS NOT NULL
						BEGIN
						DROP TABLE #tempLeaveAPP
						END

						
						select * into #tempLeaveAPP 
						from #tbl_Leave_App
						--select * from #tbl_Leave_App
						If ((select count(1) from #tempLeaveAPP) > 0)
							Truncate table #tbl_Leave_App


						--select LP.* from #tempLeaveAPP LP
						--inner join T0080_Travel_HycScheme_Sett TS 
						--on  Lp.Leave_App_ID = TS.AppId and Ts.RptEmp = @Emp_ID and LP.Scheme_ID = Ts.SchemeIId
					
							
						insert into #tbl_Leave_App
						select LP.* from #tempLeaveAPP LP
						inner join T0080_Travel_HycScheme_Sett TS 
						on  Lp.Leave_App_ID = TS.AppId and Ts.RptEmp = @Emp_ID and LP.Scheme_ID = Ts.SchemeIId
						
						--Delete LP from #tbl_Leave_App LP
						--inner join T0080_Travel_HycScheme TS 
						--on LP.Scheme_ID = TS.SchemeIId and Lp.Leave_App_ID <> TS.AppId and TS.RptEmp = @Emp_ID
						-- Add by Deepal 14022022
					END
					
					--select @Emp_ID_Cur as abc
				If @Emp_ID_Cur > 0
					Begin
				
						----Insert INTO #Travel
						--	Select distinct	LAD.Emp_ID, LAD.Emp_Full_Name,LAD.Supervisor,
						--		LAD.Emp_Superior,LAD.Travel_Approval_ID,LAD.Travel_Set_Application_ID,
						--		LAD.Branch_Name,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.For_date ,LAD.Status_New,LAD.Travel_Set_Application_id,LAD.travel_approval_id
						--		,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID, SL.Final_Approver,SL.Is_Fwd_Leave_Rej
						--		,LAD.Advance_Amount,LAD.Cmp_ID,LAD.Tran_ID,isnull(SL.Is_Aprvl_Ovrlimit,0),LAD.Travel_App_Code
						--		,Qry1.Approved_Expence,LAD.DirectEntry
						--	From V0140_Travel_Settlement_Application_New_Level LAD
						--		left outer join (select lla.Travel_Approval_ID As App_ID, Rpt_Level as Rpt_Level , lla.Status,lla.Approved_Expance as Approved_Expence
						--		,lla.Travel_Set_Application_id as Travel_Set_App_ID From T0115_Travel_Settlement_Level_Approval lla WITH (NOLOCK)
						--							inner join (Select max(rpt_level) as rpt_level1, Travel_Approval_ID,Travel_Set_Application_id
						--											From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
						--											--Where Travel_Approval_ID In (Select Leave_App_ID From #tbl_Leave_App)
						--											group by Travel_Approval_ID,Travel_Set_Application_id
						--										) Qry
						--							on qry.Travel_Set_Application_id = lla.Travel_Set_Application_id and qry.rpt_level1 = lla.rpt_level
													
						--						) As Qry1 
						--		On  LAD.Travel_Approval_ID = Qry1.App_ID
						--		--Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Travel_Set_Application_id -- Comment by deepal :- 18022022
						--		Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Travel_Approval_ID
						--		inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave
						--		and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
						--Where Travel_Approval_ID In (Select Leave_App_ID From #tbl_Leave_App)
					
						Insert INTO #Travel
							Select distinct	LAD.Emp_ID, LAD.Emp_Full_Name,LAD.Supervisor,
								LAD.Emp_Superior,LAD.Travel_Approval_ID,LAD.Travel_Set_Application_ID,
								LAD.Branch_Name,LAD.Desig_Name, LAD.Alpha_Emp_code, LAD.For_date ,LAD.Status_New,LAD.Travel_Set_Application_id,LAD.travel_approval_id
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level, TLAP.Scheme_ID, SL.Final_Approver,SL.Is_Fwd_Leave_Rej
								,LAD.Advance_Amount,LAD.Cmp_ID,LAD.Tran_ID,isnull(SL.Is_Aprvl_Ovrlimit,0),LAD.Travel_App_Code
								,Qry1.Approved_Expence,LAD.DirectEntry
							From V0140_Travel_Settlement_Application_New_Level LAD
								left outer join (select lla.Travel_Approval_ID As App_ID, Rpt_Level as Rpt_Level , lla.Status,lla.Approved_Expance as Approved_Expence
								,lla.Travel_Set_Application_id as Travel_Set_App_ID From T0115_Travel_Settlement_Level_Approval lla WITH (NOLOCK)
													inner join (Select max(rpt_level) as rpt_level1, Travel_Approval_ID,Travel_Set_Application_id
																	From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK)
																	--Where Travel_Approval_ID In (Select Leave_App_ID From #tbl_Leave_App)
																	group by Travel_Approval_ID,Travel_Set_Application_id
																) Qry
													on qry.Travel_Set_Application_id = lla.Travel_Set_Application_id and qry.rpt_level1 = lla.rpt_level
													
												) As Qry1 
								On  LAD.Travel_Set_Application_id = Qry1.Travel_Set_App_ID
								--Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Travel_Set_Application_id -- Comment by deepal :- 18022022
								Inner join #tbl_Leave_App TLAP On TLAP.Leave_App_ID = LAD.Travel_Approval_ID
								inner Join #tbl_Scheme_Leave SL On SL.Scheme_ID = TLAP.Scheme_ID And SL.Leave = TLAP.Leave
								and  SL.rpt_level > isnull(Qry1.Rpt_Level,0) and  SL.rpt_level = TLAP.rpt_level -- or Qry1.Rpt_Level = 0)
						--Where Travel_Set_Application_id In (Select Leave_App_ID From #tbl_Leave_App)	
						Where Travel_Approval_ID In (Select Leave_App_ID From #tbl_Leave_App)	
			 		--select * from #travel
					End
				Else
					Begin
					
					
						Insert INTO #Travel
							Select distinct	
								LAD.Emp_ID, LAD.Emp_Full_Name, 
								LAD.Supervisor,
								LAD.Emp_Superior,
								LAD.Travel_Approval_ID, 
								LAD.Travel_Set_Application_id ,
								LAD.Branch_Name
								,LAD.Desig_Name, 
								LAD.Alpha_Emp_code, 
								LAD.For_date ,
								--LAD.Status 
								LAD.Status_New
								,LAD.Travel_Set_Application_id,LAD.travel_approval_id
								,isnull(Qry1.rpt_level + 1,'1') As Rpt_Level,'0' as Scheme_ID, '1' as Final_Approver, '0' as Is_Fwd_Leave_Rej
								,LAD.Advance_Amount,LAD.Cmp_ID,LAD.Tran_ID,'0' as Is_Aprvl_Ovrlmit,LAD.Travel_App_Code
								,ISNULL(Qry1.Approved_Expence,0) as Approved_Expence
								,LAD.DirectEntry
							From V0140_Travel_Settlement_Application_New_Level LAD
									left outer join (select lla.Travel_Approval_ID As App_ID, Rpt_Level  as Rpt_Level,lla.Status,lla.Approved_Expance as Approved_Expence,lla.Travel_Set_Application_id as Travel_Set_App_ID From T0115_Travel_Settlement_Level_Approval lla WITH (NOLOCK)
														inner join (Select max(rpt_level) as rpt_level1, Travel_Approval_ID,Travel_Set_Application_id
																		From T0115_Travel_Settlement_Level_Approval WITH (NOLOCK) 
																		group by Travel_Approval_ID,Travel_Set_Application_id
																	) Qry
														on qry.Travel_Set_Application_id = lla.Travel_Set_Application_id and qry.rpt_level1 = lla.rpt_level
													) As Qry1 
									On  LAD.Travel_Set_Application_id = Qry1.Travel_Set_App_ID
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
						SET @queryExe='select * from #Travel ' + @OrderBy --order by #Travel.Application_Date desc
						exec (@queryExe);
					End
				Else
					Begin
						set @queryExe=''
						set @queryExe = 'select * from #Travel where ' + @Constrains  + ' ' + @OrderBy	
						exec (@queryExe);
					End
			End
		Else if @Type = 1
			Begin
				IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
					BEGIN
						TRUNCATE TABLE #Notification_Value
						INSERT INTO #Notification_Value
						SELECT COUNT(1) AS travelSettlementAppCnt from #Travel 
					END
				ELSE
					SELECT COUNT(1) AS travelSettlementAppCnt from #Travel 
				
				return
			End				
		
		
		
		drop TABLE #tbl_Scheme_Leave
		drop TABLE #tbl_Leave_App
		drop TABLE #Responsiblity_Passed
		drop TABLE #Travel
	
END

