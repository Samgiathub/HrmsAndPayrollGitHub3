
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Leave_Application_Tracking]  
	 @Cmp_id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime 
	,@Branch_ID		numeric	 = 0
	,@Grd_ID 		numeric = 0
	,@Type_ID 		numeric = 0
	,@Dept_ID 		numeric = 0
	,@Desig_ID 		numeric = 0
	,@Emp_ID 		numeric  = 0
	,@Constraint	varchar(max)  = ''
	,@Cat_ID        numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical_id Numeric = 0 
	,@SubVertical_id Numeric = 0 
	,@subBranch_id Numeric = 0 
	,@Leave_Status varchar(1) = ''  --added By Jimit 07052018 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
	
		if @Salary_Cycle_id = 0
		set @Salary_Cycle_id =NULL

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
	
	If @Segment_Id = 0		
	set @Segment_Id = null
	If @Vertical_Id = 0		
	set @Vertical_Id = null
	If @SubVertical_Id = 0	
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	
	set @SubBranch_Id = null	
	
	IF @Leave_Status = 'S' or 	@Leave_Status =''
		set @Leave_Status = null

	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)      
 
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		begin
			
				-- below condition changed by mitesh on 05072013
				Insert Into #Emp_Cons      
				select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
				left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				ON QrySC.eid = V_Emp_Cons.Emp_ID
				where 
				cmp_id=@Cmp_ID 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))     
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
				and Increment_Effective_Date <= @To_Date 
				and 
					  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )
						OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						) 
						order by Emp_ID
						


				-- Commented and Added by rohit on 17122013 for polycab issue employee transfer
				--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
				--	where  Increment_effective_Date <= @to_date
				--	group by emp_ID)

				Delete From #Emp_Cons Where Increment_ID Not In
					(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
					(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
					Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
					on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
					Where Increment_effective_Date <= @to_date)
				-- Commented and Added by rohit on 17122013 
				
				
				--Insert Into #Emp_Cons      
				--   select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
				--   cmp_id=@Cmp_ID 
				--    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				--and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				--and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				--and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
				--   and Increment_Effective_Date <= @To_Date 
				--   and 
				--                 ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						--	or (Left_date is null and @To_Date >= Join_Date)      
						--	or (@To_Date >= left_date  and  @From_Date <= left_date )
						--	OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						--	) 
						--	order by Emp_ID
							
				--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
				--	where  Increment_effective_Date <= @to_date
				--	group by emp_ID)
		
	end
	/*Below code commented and New above code added by Sumit on 27102016 */
	
	
	
	-----Added By Jimit 07052018------
	
	IF OBJECT_ID('DBO.TEMPDB..#RMRORM') IS NOT NULL
			DROP TABLE #RMRORM
		
			CREATE TABLE #RMRORM
			(
				EMP_ID				NUMERIC,
				R_EMP_ID			NUMERIC				
			)
			
			Insert	INTO #RMRORM
			SELECT EC.Emp_Id,RM.R_Emp_ID From #Emp_Cons EC Inner Join V0010_Get_Max_Reporting_manager RM ON EC.Emp_ID = RM.Emp_ID
			
			
			UPDATE  RM
			SET	    RM.R_Emp_Id = Q.R_Emp_ID 
			FROM	#RMRORM RM INNER JOIN
					#Emp_Cons EC On Ec.Emp_ID = Rm.Emp_ID INNER JOIN
					(
						SELECT	ERD.R_Emp_ID , ERD.Emp_ID
						FROM	
								T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN
								(
									SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
									FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									WHERE	 Effect_Date <= GETDATE()
									GROUP BY emp_ID
								) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
								INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD.R_EMP_ID 
						WHERE EXISTS (
										SELECT	DISTINCT ERD1.EMP_ID
										FROM	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) INNER JOIN
												(
													SELECT	 MAX(Effect_Date) as Effect_Date, Emp_ID 
													from	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
													WHERE	 Effect_Date <= GETDATE()
													GROUP BY emp_ID
												) RQry on  ERD1.Emp_ID = RQry.Emp_ID and ERD1.Effect_Date = RQry.Effect_Date
										INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = ERD1.R_EMP_ID AND ERD.Emp_ID = E.Emp_ID 
										Inner Join #Emp_Cons ECS On ECS.Emp_ID  = ERD1.Emp_ID 				
									)
					)Q On Q.Emp_ID = Rm.R_EMP_ID
	
	------------Ended------------
	
			
	--VLAD.Application_Date add by chetan 280617
	SELECT  LevDetail.*,LM.Leave_Code , CM.Cmp_Name,VLAD.Application_Date FROM V0110_LEAVE_APPLICATION_DETAIL VLAD 
		inner JOIN 
		(
					Select  isnull(LLA.From_Date, LAD.From_Date) as From_Date, isnull(LLA.To_Date,LAD.To_Date) as To_Date, isnull(LLA.Leave_Period,LAD.Leave_Period) as Leave_Period
					,isnull(LLA.Leave_Reason,LAD.Leave_Reason) as Leave_Reason, ISNULL(LLA.Approval_Status,LAD.Application_Status) as Application_Status
					,isnull(LLA.Rpt_Level ,1) As Rpt_Level,ISNULL(LLA.System_Date,lad.System_Date) as  System_Date,  EM.Alpha_Emp_Code , EM.Emp_Full_Name  ,ISNULL(LLA.Leave_Application_ID, LAD.Leave_Application_ID ) as Leave_Application_ID,
					(Qry_Reporting.Alpha_Emp_Code + ' - ' + Qry_Reporting.Emp_Full_Name) as Manager , isnull(LLA.Approval_Comments,LAD.Application_comments) as comment ,isnull(LLA.Half_Leave_Date, LAD.Half_Leave_Date) as Half_Leave_Date
					,ISNULL(LLA.Leave_Assign_As,LAD.Leave_Assign_As) as Leave_Assign_As
					,SD.Is_RM,SD.Is_RMToRM
					From V0110_LEAVE_APPLICATION_DETAIL LAD 			
					inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LAD.Emp_ID = EM.Emp_ID
					Left join
					(SELECT   R1.Emp_ID, Effect_Date AS Effect_Date,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
					 FROM     dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
							  INNER JOIN 
										(SELECT		MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
										 FROM		T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) 
										 INNER JOIN 
														(SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID FROM T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK) WHERE R3.Effect_Date < GETDATE() GROUP BY R3.Emp_ID)
															R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date GROUP BY R2.Emp_ID
														 ) 
										R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID
										inner join t0080_emp_master Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
					) AS Qry_Reporting ON EM.Emp_ID = Qry_Reporting.Emp_ID --Added by sumit for showing reporting manager 13102016
					left join T0115_Leave_Level_Approval LLA WITH (NOLOCK)
					on LAD.Leave_Application_ID=LLA.Leave_Application_ID --and LAD.Emp_ID=LLA.Emp_ID
					and Qry_Reporting.R_Emp_ID=LLA.S_Emp_ID		
					--add by chetan 290617 for reporting manager tick on scheme than show in report
					Left join T0095_EMP_SCHEME ES WITH (NOLOCK) on LAD.Emp_ID = ES.Emp_ID 
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID,Cmp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Leave' and Cmp_ID = @Cmp_ID
													GROUP BY emp_ID,Cmp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID 
										 AND ES.Effective_Date = QES.For_Date
										 AND Type = 'Leave'	
										 AND ES.Cmp_ID = QES.Cmp_ID 									  
					INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK)
								on ES.Scheme_ID=SD.Scheme_Id AND ES.Type='Leave'
								where (SD.Is_RM=1 and sd.Is_RMToRM = 0)
									  and ISNULL(LLA.Approval_Status,LAD.Application_Status) = IsNULL(@Leave_Status,ISNULL(LLA.Approval_Status,LAD.Application_Status)) --Added By Jimit 07052018
			Union
					Select		isnull(LLA.From_Date,LAD.From_Date) as From_Date, ISNULL(LLA.To_Date,LAD.To_Date),isnull(LLA.Leave_Period,LAD.Leave_Period),				
								ISNULL(LLA.Leave_Reason,LAD.Leave_Reason) as Leave_Reason, isnull(LLA.Approval_Status,LAD.Application_Status),isnull(SD.Rpt_Level,0) as Rpt_Level,
								isnull(LLA.System_Date,LAD.System_Date) as System_Date,ISNULL(EMP.Alpha_Emp_Code,LAD.Alpha_Emp_Code) as Alpha_Emp_Code , ISNULL(EMP.Emp_Full_Name,LAD.Emp_Full_Name) as Emp_Full_Name,
								isnull(LLA.Leave_Application_ID, LAD.Leave_Application_ID) as Leave_Application_ID,
								(isnull(RM.Alpha_Emp_Code,EMP.Alpha_Emp_Code) + ' - ' + isnull(RM.Emp_Full_Name,EMp.Emp_Full_Name)) as Manager,
								isnull(LLA.Approval_Comments,LAD.Application_Comments) as comment,isnull(LLA.Half_Leave_Date,LAD.Half_Leave_Date) as Half_Leave_Date,
								isnull(LLA.Leave_Assign_As,LAD.Leave_Assign_As) as Leave_Assign_As
								,SD.Is_RM,SD.Is_RMToRM
					From		T0050_Scheme_Detail SD WITH (NOLOCK) 
								inner join T0095_EMP_SCHEME ES WITH (NOLOCK)
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Leave'
													GROUP BY emp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID and ES.Effective_Date = QES.For_Date and Type = 'Leave'										  
								on ES.Scheme_ID=SD.Scheme_Id and ES.Type='Leave'				
								inner join T0080_EMP_MASTER EMP WITH (NOLOCK) on EMP.Emp_ID=ES.Emp_ID		
								left Outer join V0110_LEAVE_APPLICATION_DETAIL LAD on EMP.Emp_ID=LAD.Emp_ID 
								Left Outer join T0115_Leave_Level_Approval LLA WITH (NOLOCK) on LLA.S_Emp_ID=SD.App_Emp_ID and LLA.Emp_ID=ES.Emp_ID--on LLA.S_Emp_ID=SD.App_Emp_ID --and LLA.Rpt_Level=SD.Rpt_Level				  				
								--left Outer join V0110_LEAVE_APPLICATION_DETAIL LAD on EMP.Emp_ID=LAD.Emp_ID 
								and isnull(LLA.Leave_Application_ID,LAD.Leave_Application_ID)=LAD.Leave_Application_ID--and LLA.Leave_Application_ID=LAD.Leave_Application_ID
								left Outer JOIN T0080_EMP_MASTER RM WITH (NOLOCK) ON RM.Emp_ID=SD.App_Emp_ID --and RM.Cmp_ID=SD.Cmp_Id
					where		(SD.Is_RM=0 and SD.Is_RMToRM =0) --Changed by Sumit on 14102016
								and ISNULL(LLA.Approval_Status,LAD.Application_Status) = IsNULL(@Leave_Status,ISNULL(LLA.Approval_Status,LAD.Application_Status))	--Added By Jimit 07052018
			--added By Jimit 07052018
			UNION
				Select  isnull(LLA.From_Date, LAD.From_Date) as From_Date, isnull(LLA.To_Date,LAD.To_Date) as To_Date, isnull(LLA.Leave_Period,LAD.Leave_Period) as Leave_Period
					,isnull(LLA.Leave_Reason,LAD.Leave_Reason) as Leave_Reason, ISNULL(LLA.Approval_Status,LAD.Application_Status) as Application_Status
					,isnull(LLA.Rpt_Level ,2) As Rpt_Level,ISNULL(LLA.System_Date,lad.System_Date) as  System_Date,  EM.Alpha_Emp_Code , EM.Emp_Full_Name  ,ISNULL(LLA.Leave_Application_ID, LAD.Leave_Application_ID ) as Leave_Application_ID,
					(Q.Alpha_Emp_Code + ' - ' + Q.Emp_Full_Name) as Manager 					
					,isnull(LLA.Approval_Comments,LAD.Application_comments) as comment ,isnull(LLA.Half_Leave_Date, LAD.Half_Leave_Date) as Half_Leave_Date
					,ISNULL(LLA.Leave_Assign_As,LAD.Leave_Assign_As) as Leave_Assign_As
					,Sd.Is_RM,Sd.Is_RMToRM
					From V0110_LEAVE_APPLICATION_DETAIL LAD 			
					inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LAD.Emp_ID = EM.Emp_ID
					Left OUTER JOIN ( select R1.Emp_ID,Alpha_Emp_Code, Em.emp_full_name,R_Emp_ID
									   FROM	 #RMRORM R1 Inner JOIN T0080_EMP_MASTER Em WITH (NOLOCK) On R1.R_emp_id = Em.emp_id
											 
											 ) Q On Q.EMP_ID = em.Emp_ID
					left join T0115_Leave_Level_Approval LLA WITH (NOLOCK)
					on LAD.Leave_Application_ID=LLA.Leave_Application_ID --and LAD.Emp_ID=LLA.Emp_ID
					and Q.R_Emp_ID=LLA.S_Emp_ID		
					--add by chetan 290617 for reporting manager tick on scheme than show in report
					Left join T0095_EMP_SCHEME ES WITH (NOLOCK) on LAD.Emp_ID = ES.Emp_ID 
								Inner Join
										 (select	MAX(Effective_Date) as For_Date, Emp_ID,Cmp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
													where Effective_Date<=GETDATE() And Type = 'Leave' and Cmp_ID = @Cmp_ID
													GROUP BY emp_ID,Cmp_ID
										 ) QES on ES.Emp_ID = QES.Emp_ID 
										 AND ES.Effective_Date = QES.For_Date
										 AND Type = 'Leave'	
										 AND ES.Cmp_ID = QES.Cmp_ID 									  
					INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK)
								on ES.Scheme_ID=SD.Scheme_Id AND ES.Type='Leave'
								where (SD.Is_RM=0 and sd.Is_RMToRM = 1)
									and ISNULL(LLA.Approval_Status,LAD.Application_Status) = IsNULL(@Leave_Status,ISNULL(LLA.Approval_Status,LAD.Application_Status))	--Added By Jimit 07052018
										
			
		
		) 
		as LevDetail on VLAD.Leave_Application_ID = LevDetail.Leave_Application_ID 
		inner JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = VLAD.Leave_ID
		inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON VLAD.Cmp_ID = CM.Cmp_Id
		where VLAD.cmp_id = @Cmp_id --and (VLAD.Application_Status = 'P' OR VLAD.Application_Status = 'F') comment by chetan 30062017
		and VLAD.emp_id in (SELECT Emp_ID  from #emp_cons)
		and LevDetail.From_Date >= @From_Date and LevDetail.To_Date <= @To_Date		
	ORDER BY LevDetail.leave_application_id,LevDetail.Rpt_Level
	
	
	
	/*Below code commented and New above code added by Sumit on 27102016 */
	--SELECT  LevDetail.*,LM.Leave_Code , CM.Cmp_Name FROM V0110_LEAVE_APPLICATION_DETAIL VLAD 
	--	inner JOIN 
	--	(
	--	Select  From_Date, To_Date, Leave_Period, Leave_Reason, Application_Status, 0 As Rpt_Level, lad.System_Date ,  EM.Alpha_Emp_Code , EM.Emp_Full_Name  , Leave_Application_ID , (EMp.Alpha_Emp_Code + ' - ' + EMp.Emp_Full_Name) as Manager , LAD.Application_comments as comment , LAD.Half_Leave_Date  , LAD.Leave_Assign_As 
	--	From V0110_LEAVE_APPLICATION_DETAIL LAD 
	--	inner JOIN T0080_EMP_MASTER EM ON LAD.Emp_ID = EM.Emp_ID 
	--	left join T0080_EMP_MASTER emp on emp.Emp_ID=em.Emp_Superior
	--	Union 
		
	--	Select From_Date, To_Date, Leave_Period, Approval_Comments, Approval_Status, Rpt_Level, LLA.System_Date , '' as Alpha_Emp_Code , '' as Emp_Full_Name , Leave_Application_ID ,(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name) as Manager , lla.Approval_Comments as comment , LLA.Half_Leave_Date , LLA.Leave_Assign_As 
	--	From T0115_Leave_Level_Approval LLA 
	--	inner JOIN T0080_EMP_MASTER EM ON lla.S_Emp_ID = EM.Emp_ID 

	--	) as LevDetail on VLAD.Leave_Application_ID = LevDetail.Leave_Application_ID 
	--	inner JOIN T0040_LEAVE_MASTER LM ON LM.Leave_ID = VLAD.Leave_ID
	--	inner JOIN T0010_COMPANY_MASTER CM ON VLAD.Cmp_ID = CM.Cmp_Id
	--	where VLAD.cmp_id = @Cmp_id and (VLAD.Application_Status = 'P' OR VLAD.Application_Status = 'F')
	--	and VLAD.emp_id in (SELECT Emp_ID  from #emp_cons)
	--	and LevDetail.From_Date >= @From_Date and LevDetail.To_Date <= @To_Date
		
	--ORDER BY LevDetail.leave_application_id,LevDetail.Rpt_Level



RETURN
