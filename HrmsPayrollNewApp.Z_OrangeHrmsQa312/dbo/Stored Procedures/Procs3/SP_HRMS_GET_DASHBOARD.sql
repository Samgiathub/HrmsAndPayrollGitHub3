


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_GET_DASHBOARD]  
  @Cmp_ID numeric(18,0)  ,
  @branch_id numeric(18,0)  ,
  @login_Id numeric(18,0)=0
  --@rec_post_id numeric(18,0)  ,
  --@training_apr_id numeric(18,0)  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  DECLARE @pPrivilage_ID AS VARCHAR(MAX) 
	    SET @pPrivilage_ID = '0'
	
	DECLARE @pPrivilage_Department AS VARCHAR(MAX) 
		SET @pPrivilage_Department = '0'
		
	DECLARE @pPrivilage_Vertical AS VARCHAR(MAX) 
		SET @pPrivilage_Vertical = '0'
	    
	DECLARE @pPrivilage_Sub_Vertical AS VARCHAR(MAX) 
		SET @pPrivilage_Sub_Vertical = '0'
	
	DECLARE @Emp_Id AS NUMERIC(18,0)
		SET @Emp_Id = 0
	
	DECLARE @FDate AS DATETIME
	
	 SELECT TOP 1 @pPrivilage_ID=PM.branch_id_multi,@FDate=pd.FROM_DATE,
					@pPrivilage_Department = PM.Department_Id_Multi, 
					@pPrivilage_Vertical = PM.Vertical_ID_Multi,   
					@pPrivilage_Sub_Vertical = PM.SubVertical_ID_Multi,   
					@Emp_Id = em.Emp_ID  
      FROM  
				T0011_LOGIN lo WITH (NOLOCK) LEFT OUTER JOIN v0080_employee_master em on em.Emp_ID = lo.Emp_ID INNER JOIN
				T0090_EMP_PRIVILEGE_DETAILS PD WITH (NOLOCK) on lo.Login_ID = pd.Login_Id INNER JOIN
				T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) on pd.Privilege_Id = PM.Privilege_ID 
	 WHERE lo.Cmp_ID=@cmp_id AND pd.Login_Id=@login_Id  and ISNULL(em.emp_left,'N')='N' and Pd.From_Date <= GETDATE()
	 GROUP BY PM.branch_id_multi,pd.FROM_DATE,PM.Department_Id_Multi,PM.Vertical_ID_Multi,PM.SubVertical_ID_Multi,em.Emp_ID 
	 ORDER BY pd.FROM_DATE DESC 
	 
	  IF @pPrivilage_ID = '' or @pPrivilage_ID = '0'
		 SET @pPrivilage_ID = NULL

	  IF @pPrivilage_Vertical = '' or @pPrivilage_Vertical = '0'
		 SET @pPrivilage_Vertical = NULL
		
	  IF @pPrivilage_Sub_Vertical = '' or @pPrivilage_Sub_Vertical='0'
		 SET @pPrivilage_Sub_Vertical = NULL
	
	  IF @pPrivilage_Department = '' or @pPrivilage_Department='0'
		 SET @pPrivilage_Department = NULL
		 
	  IF @pPrivilage_ID is null
		BEGIN	
			SELECT   @pPrivilage_ID = COALESCE(@pPrivilage_ID + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			SET @pPrivilage_ID = @pPrivilage_ID + '#0'
		END
		
	  IF @pPrivilage_Vertical is null
		BEGIN	
			SELECT   @pPrivilage_Vertical = COALESCE(@pPrivilage_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			
			IF @pPrivilage_Vertical IS NULL
				SET @pPrivilage_Vertical = '0';
			ELSE
				SET @pPrivilage_Vertical = @pPrivilage_Vertical + '#0'		
		END
	  IF @pPrivilage_Sub_Vertical is null
		BEGIN	
			SELECT   @pPrivilage_Sub_Vertical = COALESCE(@pPrivilage_Sub_Vertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			
			IF @pPrivilage_Sub_Vertical IS NULL
				SET @pPrivilage_Sub_Vertical = '0';
			ELSE
				SET @pPrivilage_Sub_Vertical = @pPrivilage_Sub_Vertical + '#0'
		END
	  IF @pPrivilage_Department is null
		BEGIN
			SELECT   @pPrivilage_Department = COALESCE(@pPrivilage_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
			
			IF @pPrivilage_Department is null
				SET @pPrivilage_Department = '0';
			ELSE
				SET @pPrivilage_Department = @pPrivilage_Department + '#0'
		END
	
	 IF OBJECT_ID('tempdb..#Emp_Cons') is not null
		DROP TABLE #Emp_Cons 	
	
	SELECT	I1.EMP_ID, I1.INCREMENT_ID, BRANCH_ID , I1.Vertical_ID,I1.SubVertical_ID,I1.Dept_ID
       INTO #Emp_Cons 
	  FROM	T0095_INCREMENT I1 WITH (NOLOCK)
				INNER JOIN (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, Increment_Effective_Date, I2.Emp_ID
							FROM T0095_INCREMENT I2 WITH (NOLOCK)
							GROUP BY I2.Increment_Effective_Date, I2.Emp_ID) I2 ON I1.Increment_ID=I2.INCREMENT_ID
							INNER JOIN (SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date, I3.Emp_ID
										FROM	T0095_INCREMENT I3 WITH (NOLOCK)
										WHERE	I3.Increment_Effective_Date <=GETDATE()
										GROUP BY I3.Emp_ID) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.Emp_ID=I3.Emp_ID
					
		 WHERE 	I1.Cmp_ID=@Cmp_ID  
					and EXISTS (select Data from dbo.Split(@pPrivilage_ID, '#') B Where cast(B.data as numeric)=Isnull(I1.Branch_ID,0))
					and EXISTS (select Data from dbo.Split(@pPrivilage_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(I1.Vertical_ID,0))
					and EXISTS (select Data from dbo.Split(@pPrivilage_Sub_Vertical, '#') S Where cast(S.data as numeric)=Isnull(I1.SubVertical_ID,0))
					and EXISTS (select Data from dbo.Split(@pPrivilage_Department, '#') D Where cast(D.data as numeric)=Isnull(I1.Dept_ID,0))    		   
	  
	  
	SELECT COUNT(Resume_Id)AS Resumectr FROM T0055_Resume_Master WITH (NOLOCK) WHERE Resume_Status=0 AND Resume_ScreeningStatus=2 AND Cmp_ID= @Cmp_ID
		
	IF (ISNULL(@branch_id,'0')) <> '0'
		BEGIN
			SELECT COUNT(*)cnt FROM V0060_HRMS_Candidates_Finalization c INNER JOIN 
						  T0055_Resume_Master AS r WITH (NOLOCK) ON r.Resume_Id = c.Resume_ID LEFT JOIN 
						  T0090_HRMS_RESUME_HEALTH as h WITH (NOLOCK) on h.Resume_ID = c.Resume_ID INNER JOIN
						  #Emp_Cons E on E.branch_id = c.Branch_id
			WHERE c.cmp_id=@Cmp_ID AND  Acceptance=1 AND isnull(Accept_Appointment,0) <>2  
				  AND  Joining_date <=dateadd(dd,7,getdate()) AND Joining_date > GETDATE();
				  
			SELECT COUNT(*)cnt FROM V0060_HRMS_Candidates_Finalization c INNER JOIN 
						  T0055_Resume_Master AS r WITH (NOLOCK) ON r.Resume_Id = c.Resume_ID LEFT JOIN 
						  T0090_HRMS_RESUME_HEALTH AS h WITH (NOLOCK) ON h.Resume_ID = c.Resume_ID INNER JOIN
						  #Emp_Cons E on E.branch_id = c.Branch_id
			WHERE c.cmp_id=@Cmp_ID AND  Acceptance=1 AND isnull(Accept_Appointment,0) <>2 AND 
					(CONVERT(varchar(10),joining_date,105) = CONVERT(varchar(10),dateadd(dd,1,getdate()),105) OR  
					CONVERT(varchar(10),joining_date,105) = CONVERT(varchar(10),getdate(),105))
		END	
	ELSE	
		BEGIN
			SELECT COUNT(*)cnt FROM V0060_HRMS_Candidates_Finalization c Inner JOIN 
						  T0055_Resume_Master AS r WITH (NOLOCK) ON r.Resume_Id = c.Resume_ID LEFT JOIN 
						  T0090_HRMS_RESUME_HEALTH as h WITH (NOLOCK) on h.Resume_ID = c.Resume_ID 
			WHERE c.cmp_id=@Cmp_ID AND  Acceptance=1 AND isnull(Accept_Appointment,0) <>2  
				 AND  Joining_date <=dateadd(dd,7,getdate()) AND Joining_date > GETDATE();
				 
			SELECT COUNT(*)cnt FROM V0060_HRMS_Candidates_Finalization c Inner JOIN 
						  T0055_Resume_Master AS r WITH (NOLOCK) ON r.Resume_Id = c.Resume_ID LEFT JOIN 
						  T0090_HRMS_RESUME_HEALTH AS h WITH (NOLOCK) ON h.Resume_ID = c.Resume_ID 
			WHERE c.cmp_id=@Cmp_ID AND  Acceptance=1 AND isnull(Accept_Appointment,0) <>2 AND 
					(CONVERT(varchar(10),joining_date,105) = CONVERT(varchar(10),dateadd(dd,1,getdate()),105) or  CONVERT(varchar(10),joining_date,105) = CONVERT(varchar(10),getdate(),105))
		END
	
	SELECT COUNT(KPIPMS_Status) AS KPIPMS_Status FROM  T0080_KPIPMS_EVAL WITH (NOLOCK) WHERE cmp_id=@Cmp_ID AND KPIPMS_Status=4
	SELECT COUNT(Status) as Status FROM  T0080_EmpKPI WITH (NOLOCK) WHERE cmp_id=@Cmp_ID and Status=4 
	SELECT EmpKPI_Id,k.Emp_Id,k.Cmp_Id,Status,FinancialYr,emp_full_name,cat_name,dept_name,desig_name  
	FROM T0080_EmpKPI as k WITH (NOLOCK) LEFT JOIN 
		 T0080_EMP_MASTER_Clone as e WITH (NOLOCK) on e.emp_id=k.emp_id INNER JOIN 
		 T0095_INCREMENT i WITH (NOLOCK) on i.emp_id=e.emp_id INNER JOIN
		 (
			SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
			FROM   T0095_INCREMENT WITH (NOLOCK) INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
				FROM  T0095_INCREMENT WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID	
				GROUP BY Emp_ID
			)I2 on i2.Emp_ID = T0095_INCREMENT.Emp_ID
			WHERE Cmp_ID = @Cmp_ID	
			GROUP BY T0095_INCREMENT.Emp_ID
		 )I1 on I1.Emp_ID = I.Emp_ID and I1.Increment_ID = I.Increment_ID LEFT JOIN 
		 T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id=i.Dept_ID LEFT JOIN 
		 T0040_DESIGNATION_MASTER ds WITH (NOLOCK) ON ds.Desig_ID=i.Desig_Id LEFT JOIN 
		 T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID  = i.Cat_ID 
	WHERE k.Cmp_ID=@Cmp_ID   
		AND k.FinancialYr=DATEPART(YEAR, GETDATE()) AND Status=2
		
	SELECT EmpKPI_Id,k.Emp_Id,k.Cmp_Id,Status,FinancialYr,emp_full_name,cat_name,dept_name,desig_name  
	FROM T0080_EmpKPI as k WITH (NOLOCK) LEFT JOIN 
	     T0080_EMP_MASTER as e WITH (NOLOCK) on e.emp_id=k.emp_id LEFT JOIN 
	     T0095_INCREMENT i WITH (NOLOCK) on i.emp_id=e.emp_id INNER JOIN
		 (
			SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
			FROM   T0095_INCREMENT WITH (NOLOCK) INNER JOIN
			(
				SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
				FROM  T0095_INCREMENT WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_ID	
				GROUP BY Emp_ID
			)I2 on i2.Emp_ID = T0095_INCREMENT.Emp_ID
			WHERE Cmp_ID = @Cmp_ID	
			GROUP BY T0095_INCREMENT.Emp_ID
		 )I1 on I1.Emp_ID = I.Emp_ID and I1.Increment_ID = I.Increment_ID LEFT JOIN 
		 T0040_DEPARTMENT_MASTER d WITH (NOLOCK) ON d.Dept_Id=i.Dept_ID LEFT JOIN 
		 T0040_DESIGNATION_MASTER ds WITH (NOLOCK) ON ds.Desig_ID=i.Desig_Id LEFT JOIN 
		 T0030_CATEGORY_MASTER c WITH (NOLOCK) ON c.Cat_ID  = i.Cat_ID 
	WHERE k.Cmp_ID=@Cmp_ID and  
	      k.FinancialYr=DATEPART(YEAR, GETDATE()) and Status=3 
	      
	SELECT COUNT(KPIPMS_ID) cnt 
	FROM  T0080_KPIPMS_EVAL WITH (NOLOCK)
	WHERE cmp_id= @Cmp_ID and KPIPMS_Status=2
	
	SELECT COUNT(KPIPMS_ID) cnt 
	FROM  T0080_KPIPMS_EVAL WITH (NOLOCK)
	WHERE cmp_id= @Cmp_ID and KPIPMS_Status=3
	
	
	IF (ISNULL(@branch_id,'0')) <> '0'
		BEGIN
			SELECT COUNT(Training_App_ID)As Trainingctr 
			FROM v0100_HRMS_TRAINING_APPLICATION  ta INNER JOIN 
				T0080_emp_master em WITH (NOLOCK) on em.emp_id=ta.Posted_emp_id INNER JOIN 
				T0030_BRANCH_MASTER bm WITH (NOLOCK) on em.Branch_id=bm.Branch_id INNER JOIN
				#Emp_Cons E on E.branch_id = bm.Branch_ID
			WHERE ta.App_Status=0 AND ta.Cmp_ID= @Cmp_ID AND isnull(ta.emp_id,0) <> 0 
		END
	ELSE	
		BEGIN
			SELECT COUNT(Training_App_ID)As Trainingctr 
			FROM v0100_HRMS_TRAINING_APPLICATION 
			WHERE App_Status=0 and Cmp_ID= @Cmp_ID AND isnull(emp_id,0) <> 0
		END
		
		 
	
	 DECLARE @cur_month  INTEGER
     DECLARE @cur_day  INTEGER
     DECLARE @day_alerttill  INTEGER
     DECLARE @alertMonth	INTEGER
     DECLARE @alertday	INTEGER
     DECLARE @KPI_AlertNodays INTEGER
     
     SET @cur_month = DATEPART(MONTH,GETDATE())
     SET @cur_day   = DATEPART(DAY,GETDATE())
     
     DECLARE @flag as INT
     SET @flag = 0
     
     DECLARE cur CURSOR
		FOR     
			SELECT KPI_Month,KPI_AlertNodays,KPI_AlertDay FROM T0040_KPI_AlertSetting WITH (NOLOCK) WHERE Cmp_Id=@Cmp_ID AND KPI_Type=1
		OPEN cur
			FETCH NEXT FROM cur INTO @alertMonth,@KPI_AlertNodays,@alertday
			WHILE @@fetch_status = 0
				BEGIN
					IF @alertMonth = @cur_month
						BEGIN
							SET @day_alerttill = @alertday + @KPI_AlertNodays
							 If (@cur_day >= @alertday And @cur_day <= @day_alerttill) 
								BEGIN	
									SET @flag = 1	
									BREAK								
								END
							 ELSE
								SET @flag = 0								
						END
					ELSE
						SET @flag = 0
					FETCH NEXT FROM cur INTO @alertMonth,@KPI_AlertNodays,@alertday
				END
		CLOSE cur
		DEALLOCATE cur
	
	
	IF @flag = 0
		SELECT 0 as msg
	ELSE
		BEGIN
			SELECT 'Start the Appraisal process' as msg
		END
		
	SELECT module_status FROM t0011_module_detail WITH (NOLOCK) WHERE cmp_id = @Cmp_ID and module_name='Appraisal3'

	--current opening
	
	select location,rec_post_code,rec_post_id,job_title,rec_end_date,total_resume,total_candidate,cast(skill_detail as varchar(50)) as skill_detail  from  V0052_HRMS_Recruitment_Posted 
	where  case when Posted_status=1 then (case when isnull(datediff(dd,getdate(),Rec_End_date),0) > 0 then 'Open' else 'Close' end) else '' end='Open'  and cmp_id=@cmp_id --and  
	--isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0)) and
	  order by  newid()


	 --current Process
	 declare @for_date datetime
	set @for_date=cast(getdate() as varchar(11))
    declare @rec_cur_process table
    (
		from_date datetime,
		to_date datetime,
		rec_post_id numeric(18,0)
    )
	if @branch_id=0
		set @branch_id=null

    insert into @rec_cur_process
    select  min(from_date) as from_date,max(to_date)as to_date,rec_post_id from V0055_HRMS_Interview_Schedule where cmp_id=@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))  group by rec_post_id
	union all
	select  min(from_date) as from_date1,max(to_date) as to_date1,rec_post_id from  V0055_Interview_Process_Detail  where cmp_id=@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))group by rec_post_id 

	select RP.rec_post_code,RP.job_title,Rc.rec_post_id,Rc.from_date,rc.to_date,Process_Name from V0052_HRMS_Recruitment_Posted RP
	inner join V0055_Interview_Process_Detail IP ON IP.Rec_Post_ID=RP.Rec_Post_Id
	right outer join 
	(select max(to_date) as to_date,min(from_date) as from_date,rec_post_id from @rec_cur_process where isnull(from_date,'')<>'' and isnull(to_date,'')<>'' and to_date>@for_date group by rec_post_id) RC
	on Rc.rec_post_id=RP.rec_post_id
	-------------------
	
	select distinct Q1.Process_id,Q1.Process_name,Q1.from_date,Q1.to_date,emp_full_name_new,q.rec_post_id from V0055_HRMS_Interview_Schedule Q1
	 inner join 
	(select max(to_date) as to_date1 ,rec_post_id from @rec_cur_process where isnull(from_date,'')<>'' and isnull(to_date,'')<>'' and to_date>@for_date group by rec_post_id)Q
	on Q.rec_post_id=Q1.rec_post_id
	where to_date>=@for_date
	
	
	DECLARE @char_data table
	(
		month  varchar(50),
		month_i  int,
		year_i  int,
		year  varchar(50),
		Total_resume int,
		In_process int,
		Rejected int,
		Approved int
	)
	
		DECLARE @a datetime  
	DECLARE @b int 
	set @b=0 
	set @a = dateadd(mm, @b,@for_date)
	WHILE @a >= dateadd(yy, -1,@for_date)
	BEGIN    
		insert into @char_data(month,month_i,year,year_i)    
		select cast(DATENAME(month,@a)  as varchar(3)),datepart(month,@a),cast(datepart(yy,@a) as varchar(4)),datepart(yy,@a)
		set @b = @b - 1   
		set @a = dateadd(mm,@b,@for_date)
		
	END 
		--total
		update @char_data 
		set Total_resume=isnull(LT.total_resume,0)
		from @char_data AM 
		right outer join 
		(select count(resume_id) as total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3)) as month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master WITH (NOLOCK)
			where resume_posted_date<getdate() and resume_posted_date>datediff(mm,-12,getdate()) and cmp_id=@cmp_id 
			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
		)LT
		ON AM.month = LT.month and AM.year = LT.year
		--in process
		update @char_data 
		set In_process=isnull(LT.total_resume,0)
		from @char_data AM 
		right outer join 
		(select count(resume_id)total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3))month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master WITH (NOLOCK)
			where resume_posted_date<getdate() and cmp_id=@cmp_id 
			and resume_status=1 AND NOT exists (select Resume_id from t0060_Resume_final WITH (NOLOCK) WHERE Cmp_ID=@cmp_id)--Mukti(29012016) --1 condion NOT IN replaced with NOT exists Mukti(08022016)
			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
		)LT
		ON AM.month = LT.month and AM.year = LT.year
		
		--reject
		update @char_data 
		set Rejected=isnull(LT.total_resume,0)
		from @char_data AM 
		right outer join 
		(select count(resume_id)total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3))month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master WITH (NOLOCK)
			where resume_posted_date<getdate() and cmp_id=@cmp_id and resume_status=2--1 
			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
		)LT
		ON AM.month = LT.month and AM.year = LT.year
		
		--approve
		update @char_data 
		set Approved=isnull(LT.total_resume,0)
		from @char_data AM 
		right outer join 
		(	select count(resume_id)total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3))month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master WITH (NOLOCK) --v0055_RESUME_APPROVAL_STATUS 
			where resume_posted_date<getdate() and cmp_id=@cmp_id 
			and resume_status =1 AND EXISTS (select Resume_id from t0060_Resume_final WITH (NOLOCK) WHERE Resume_Status=1)--Mukti(29012016) condion IN replaced with exists Mukti(08022016)
			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
		)LT
		ON AM.month = LT.month and AM.year = LT.year

			select month + '-' + STUFF (year , 1 , 2 ,'' ) as  month ,isnull(Total_resume,0) as Total_resume ,isnull(In_process,0) as In_process ,isnull(Rejected,0) as Rejected,isnull(Approved,0) as Approved  from @char_data 
		
		select top 4 month + '-' + STUFF (year , 1 , 2 ,'' ) as  month ,isnull(Total_resume,0) as Total_resume ,isnull(In_process,0) as In_process ,isnull(Rejected,0) as Rejected,isnull(Approved,0) as Approved  from @char_data 
		
		--Finalize Resume
		--select app_full_name,resume_id,rec_post_id,login_name,job_title,approval_date,joining_date,branch_name from v0060_RESUME_FINAL where resume_status=1 and Joining_status<>1 and cmp_id=@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))
		select app_full_name,resume_id,rec_post_id,login_name,job_title,Dept_Name,Desig_Name,Grd_Name,CONVERT(VARCHAR(15),joining_date,103)as joining_date,branch_name from v0060_RESUME_FINAL where resume_status=1 and Joining_status<>1 and cmp_id=@cmp_id  and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))
		and ISNULL(Confirm_Emp_id,0) = 0 and Acceptance=1  --Mukti(04022016)
		order by joining_date DESC

			--upcming training	
		declare @bid as varchar(18)
		set @bid = @branch_id
		if @bid=0
			set @bid=null
	
		SELECT  training_apr_id,TRAINING_NAME,CONVERT(VARCHAR(15) ,Training_Date,103)as Training_Start_Date,CONVERT(VARCHAR(15),Training_end_Date,103)as Training_end_Date,Place,Provider_Name,Type,Description,From_Time,to_time
		FROM V0120_HRMS_TRAINING_APPROVAL  inner JOIN
		(
			SELECT min(From_date)From_date,max(To_date)To_date,Training_App_ID,min(from_time)from_time,max(to_time)to_time
			FROM T0120_HRMS_TRAINING_Schedule WITH (NOLOCK)
			GROUP by Training_App_ID
		)TS on TS.Training_App_ID = V0120_HRMS_TRAINING_APPROVAL.Training_App_ID
		WHERE CMP_ID=@CMP_ID  AND 
			From_date>=@FOR_DATE AND  isnull(branch_id,0)=isnull(@bid,isnull(branch_id,0)) 
		ORDER BY From_date asc
		
		-- application
		SELECT  training_app_id,TRAINING_NAME,training_desc,cast(emp_code as varchar(20)) + ' - ' + emp_full_name as posted_by,skill_name FROM v0100_HRMS_TRAINING_APPLICATION WHERE CMP_ID=@CMP_ID AND isnull(app_status,0)=0 AND isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0)) ORDER BY  newid()  DESC		-- training enrollment--
------------------------------------commented on 06/03/2017 to remove unused code-----------------------
--	if @branch_id =0
--		set @branch_id=null
--	if @rec_post_id=0
--		set @rec_post_id=null
--	if @training_apr_id=0
--		set @training_apr_id=null
		
--	declare @for_date datetime
--	set @for_date=cast(getdate() as varchar(11))
	
--	--current opening
	
--	select location,rec_post_code,rec_post_id,job_title,rec_end_date,total_resume,total_candidate,cast(skill_detail as varchar(50)) as skill_detail  from  V0052_HRMS_Recruitment_Posted 
--	where  case when Posted_status=1 then (case when isnull(datediff(dd,getdate(),Rec_End_date),0) > 0 then 'Open' else 'Close' end) else '' end='Open'  and cmp_id=@cmp_id and  
--	--isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0)) and
--	 rec_post_id=isnull(@rec_post_id,rec_post_id) order by  newid()
--    -------------------
--    --current Process
--    declare @rec_cur_process table
--    (
--		from_date datetime,
--		to_date datetime,
--		rec_post_id numeric(18,0)
--    )
--    insert into @rec_cur_process
--    select  min(from_date) as from_date,max(to_date)as to_date,rec_post_id from V0055_HRMS_Interview_Schedule where cmp_id=@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0)) and rec_post_id=isnull(@rec_post_id,rec_post_id) group by rec_post_id
--	union all
--	select  min(from_date) as from_date1,max(to_date) as to_date1,rec_post_id from  V0055_Interview_Process_Detail  where cmp_id=@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0)) and rec_post_id=isnull(@rec_post_id,rec_post_id) group by rec_post_id 
	
	
--	select RP.rec_post_code,RP.job_title,Rc.rec_post_id,Rc.from_date,rc.to_date from V0052_HRMS_Recruitment_Posted RP
--	right outer join 
--	(select max(to_date) as to_date,min(from_date) as from_date,rec_post_id from @rec_cur_process where isnull(from_date,'')<>'' and isnull(to_date,'')<>'' and to_date>@for_date group by rec_post_id) RC
--	on Rc.rec_post_id=RP.rec_post_id
--	-------------------
	
--	select distinct Q1.Process_id,Q1.Process_name,Q1.from_date,Q1.to_date,emp_full_name_new,q.rec_post_id from V0055_HRMS_Interview_Schedule Q1
--	 inner join 
--	(select max(to_date) as to_date1 ,rec_post_id from @rec_cur_process where isnull(from_date,'')<>'' and isnull(to_date,'')<>'' and to_date>@for_date group by rec_post_id)Q
--	on Q.rec_post_id=Q1.rec_post_id
--	where to_date>=@for_date
	
--	declare @char_data table
--	(
--		month  varchar(50),
--		month_i  int,
--		year_i  int,
--		year  varchar(50),
--		Total_resume int,
--		In_process int,
--		Rejected int,
--		Approved int
--	)
	
--	DECLARE @a datetime  
--	DECLARE @b int 
--	set @b=0 
--	set @a = dateadd(mm, @b,@for_date)
--	WHILE @a >= dateadd(yy, -1,@for_date)
--	BEGIN    
--		insert into @char_data(month,month_i,year,year_i)    
--		select cast(DATENAME(month,@a)  as varchar(3)),datepart(month,@a),cast(datepart(yy,@a) as varchar(4)),datepart(yy,@a)
--		set @b = @b - 1   
--		set @a = dateadd(mm,@b,@for_date)
		
--	END 
--		--total
--		update @char_data 
--		set Total_resume=isnull(LT.total_resume,0)
--		from @char_data AM 
--		right outer join 
--		(select count(resume_id) as total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3)) as month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master 
--			where resume_posted_date<getdate() and resume_posted_date>datediff(mm,-12,getdate()) and cmp_id=@cmp_id 
--			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
--		)LT
--		ON AM.month = LT.month and AM.year = LT.year
--		--in process
--		update @char_data 
--		set In_process=isnull(LT.total_resume,0)
--		from @char_data AM 
--		right outer join 
--		(select count(resume_id)total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3))month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master 
--			where resume_posted_date<getdate() and cmp_id=@cmp_id 
--			and resume_status=1 AND NOT exists (select Resume_id from t0060_Resume_final WHERE Cmp_ID=@cmp_id)--Mukti(29012016) --1 condion NOT IN replaced with NOT exists Mukti(08022016)
--			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
--		)LT
--		ON AM.month = LT.month and AM.year = LT.year
		
--		--reject
--		update @char_data 
--		set Rejected=isnull(LT.total_resume,0)
--		from @char_data AM 
--		right outer join 
--		(select count(resume_id)total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3))month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master 
--			where resume_posted_date<getdate() and cmp_id=@cmp_id and resume_status=2--1 
--			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
--		)LT
--		ON AM.month = LT.month and AM.year = LT.year
		
--		--approve
--		update @char_data 
--		set Approved=isnull(LT.total_resume,0)
--		from @char_data AM 
--		right outer join 
--		(	select count(resume_id)total_resume,cast(DATENAME(month, resume_posted_date) as varchar(3))month ,cast(datepart(yy,resume_posted_date) as varchar(4)) as year from t0055_resume_master--v0055_RESUME_APPROVAL_STATUS 
--			where resume_posted_date<getdate() and cmp_id=@cmp_id 
--			and resume_status =1 AND EXISTS (select Resume_id from t0060_Resume_final WHERE Resume_Status=1)--Mukti(29012016) condion IN replaced with exists Mukti(08022016)
--			group by cast(DATENAME(month, resume_posted_date) as varchar(3)),cast(datepart(yy,resume_posted_date) as varchar(4))
--		)LT
--		ON AM.month = LT.month and AM.year = LT.year
		
		
--		select month + '-' + STUFF (year , 1 , 2 ,'' ) as  month ,isnull(Total_resume,0) as Total_resume ,isnull(In_process,0) as In_process ,isnull(Rejected,0) as Rejected,isnull(Approved,0) as Approved  from @char_data 
		
--		select top 4 month + '-' + STUFF (year , 1 , 2 ,'' ) as  month ,isnull(Total_resume,0) as Total_resume ,isnull(In_process,0) as In_process ,isnull(Rejected,0) as Rejected,isnull(Approved,0) as Approved  from @char_data 
	
--		--Finalize Resume
--		--select app_full_name,resume_id,rec_post_id,login_name,job_title,approval_date,joining_date,branch_name from v0060_RESUME_FINAL where resume_status=1 and Joining_status<>1 and cmp_id=@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))
--		select app_full_name,resume_id,rec_post_id,login_name,job_title,Dept_Name,Desig_Name,Grd_Name,joining_date,branch_name from v0060_RESUME_FINAL where resume_status=1 and Joining_status<>1 and cmp_id=@cmp_id  and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))
--		and ISNULL(Confirm_Emp_id,0) = 0 and Acceptance=1  --Mukti(04022016)
--		order by joining_date DESC
				
--		---training -----
--		--------------------
--		--upcming training	
--		declare @bid as varchar(18)
--		set @bid = @branch_id
	
--		SELECT TOP 2 training_apr_id,TRAINING_NAME,Training_Date,Training_end_Date,Place,Provider_Name,Type,Description  FROM V0120_HRMS_TRAINING_APPROVAL WHERE CMP_ID=@CMP_ID AND training_apr_id=ISNULL(@training_apr_id,training_apr_id)AND tRAINING_END_DATE>=@FOR_DATE AND  isnull(branch_id,0)=isnull(@bid,isnull(branch_id,0)) ORDER BY Training_Date asc
		
--		-- application
--		SELECT TOP 2 training_app_id,TRAINING_NAME,training_desc,cast(emp_code as varchar(20)) + ' - ' + emp_full_name as posted_by,skill_name FROM v0100_HRMS_TRAINING_APPLICATION WHERE CMP_ID=@CMP_ID AND isnull(app_status,0)=0 AND isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0)) ORDER BY  newid()  DESC		-- training enrollment--
		
--		declare @count as numeric(18,0)
--		 if isnull(@branch_id,0) <> 0
--		  begin
			
--			 set @training_apr_id =0 
--			 --commeneted on 10 Jan 2015
--			--select @count = count(tran_emp_detail_id),@training_apr_id = training_apr_id from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by training_apr_id,emp_tran_status,cmp_id having cmp_id=@cmp_ID and emp_tran_status=0 and training_apr_id in (select top 1 Training_Apr_ID from V0130_HRMS_TRAINING_ALERT where cmp_id=@cmp_ID and branch_id=@branch_id and isnull(training_apr_id,0) <> 0 and Training_Date>= getdate() and Training_Date<=dateadd(day,alerts_Start_Days,getdate()) order by newid()) and emp_tran_status=0
--				select @count = count(tran_emp_detail_id),@training_apr_id = (select top 1 Training_Apr_ID from V0130_HRMS_TRAINING_ALERT where cmp_id=@Cmp_ID and  branch_id=@branch_id
--				and isnull(training_apr_id,0) <> 0 and Training_Date>= getdate() and Training_Date<=dateadd(day,alerts_Start_Days,getdate()) order by newid())
--				from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL 
--				group by training_apr_id,emp_tran_status,cmp_id having cmp_id=@Cmp_ID and emp_tran_status=0 
				
--			if @count > 0
--			   select top 2 training_apr_id,@count as emp_count,training_date,training_name,cast(description as varchar(20))as description from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id
--			 else
--			 --commeneted on 10 Jan 2015
--			   --select top 2 training_apr_id from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id and apr_status = 1
--			   	 select top 2 training_apr_id from T0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id and apr_status = 1

--			end
--		 else
--		  begin
--			 set @training_apr_id =0 
--			  --commeneted on 10 Jan 2015
--			--select @count = count(tran_emp_detail_id),@training_apr_id = training_apr_id from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL group by training_apr_id,emp_tran_status,cmp_id having cmp_id=@cmp_ID and emp_tran_status=0 and training_apr_id in (select top 1 Training_Apr_ID from V0130_HRMS_TRAINING_ALERT where cmp_id=@cmp_ID and isnull(training_apr_id,0) <> 0 and Training_Date>= getdate() and Training_Date<=dateadd(day,alerts_Start_Days,getdate()) order by newid()) and emp_tran_status=0
--			select @count = count(tran_emp_detail_id),@training_apr_id = (select top 1 Training_Apr_ID from V0130_HRMS_TRAINING_ALERT where cmp_id=@Cmp_ID 
--				and isnull(training_apr_id,0) <> 0 and Training_Date>= getdate() and Training_Date<=dateadd(day,alerts_Start_Days,getdate()) order by newid())
--				from V0130_HRMS_TRAINING_EMPLOYEE_DETAIL 
--				group by training_apr_id,emp_tran_status,cmp_id having cmp_id=@Cmp_ID and emp_tran_status=0 
--			if @count > 0
--			   select top 2 training_apr_id,@count as emp_count,training_date,training_name,cast(description as varchar(20))as description from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id and cmp_id =@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))
--			else
--			 --commeneted on 10 Jan 2015
--				--select top 2 training_apr_id from v0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id  and cmp_id =@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))
--			select top 2 training_apr_id from T0120_HRMS_TRAINING_APPROVAL where training_apr_id=@training_apr_id  and cmp_id =@cmp_id and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))

--		 end 						 		
--		 declare @chart_tra table
--		(
--			month  varchar(50),
--			month_i  int,
--			year_i  int,
--			year  varchar(50),
--			Total_tran int
--		)
		
--		set @b=0 
--		set @a = dateadd(mm, @b,@for_date)
		
--		print @for_date
--		print @a
		
--		WHILE @a >= dateadd(yy, -1,@for_date)
--		BEGIN 
--			insert into @chart_tra(month,month_i,year,year_i)    
--			select cast(DATENAME(month,@a)  as varchar(3)),datepart(month,@a),cast(datepart(yy,@a) as varchar(4)),datepart(yy,@a)
--			set @b = @b - 1   
--			set @a = dateadd(mm,@b,@for_date)
--		END 		--total
--		update @chart_tra 
--		set Total_tran=isnull(LT.total_trn,0)
--		from @chart_tra AM 
--		right outer join 
--		(select count(training_apr_id) as total_trn,cast(DATENAME(month, Training_End_Date) as varchar(3)) as month ,cast(datepart(yy,Training_End_Date) as varchar(4)) as year from v0120_HRMS_TRAINING_APPROVAL 
--			where Training_End_Date<getdate() and Training_End_Date>datediff(mm,-12,getdate()) and cmp_id=@cmp_id 
--			--and isnull(branch_id,0)=isnull(@branch_id,isnull(branch_id,0))commented By Mukti(29012016) 
--			and isnull(branch_id,0) IN (select data from dbo.split(branch_id,'#')) --Mukti(29012016)
--			group by cast(DATENAME(month, Training_End_Date) as varchar(3)),cast(datepart(yy,Training_End_Date) as varchar(4))
--		)LT 		ON AM.month = LT.month and AM.year = LT.year				select month + '-' + STUFF (year , 1 , 2 ,'' ) as  month ,isnull(Total_tran,0) as Total_tran  from @chart_tra 
--		-- yearly training chart--
		
--		if @training_apr_id=0
--			set @training_apr_id=null
			
--		-- training & participant--	
--		select top 4 TA.training_name,TA.Training_End_Date,isnull(QR.total_part,0) as total_part,QR.Training_Apr_ID,isnull(Q.total_a,0)as total_a,isnull(Q1.total_na,0) as total_na from 	
--		(select count(emp_id) as total_part,Training_Apr_ID,cmp_id  from v0130_HRMS_TRAINING_EMPLOYEE_DETAIL where isnull(Emp_tran_status,0)=1 and cmp_id=@cmp_id and training_end_date<@for_date and training_end_date>dateadd(yy,-1,@for_date) and emp_feedback=1 and sup_feedback=1 group by Training_Apr_ID,cmp_id)QR
--			left outer join
--		(select count(Tran_emp_Detail_ID) as total_a,Training_Apr_ID from v0140_HRMS_TRAINING_Feedback where  cmp_id=@cmp_id and is_attend=1 group by Training_Apr_ID) Q
--		on Q.Training_Apr_ID=Qr.Training_Apr_ID
--			left outer join
--		(select count(Tran_emp_Detail_ID) as total_na,Training_Apr_ID from v0140_HRMS_TRAINING_Feedback where cmp_id=@cmp_id and is_attend=0 group by Training_Apr_ID) Q1
--		on Q1.Training_Apr_ID=Qr.Training_Apr_ID
--		left outer join
--		(select Training_Apr_ID ,Training_End_Date,training_name + ' (' +cast(DATENAME(month, Training_End_Date) as varchar(3)) + '-' + right(cast(datepart(yy,Training_End_Date) as varchar(4)),2) + ')' as training_name from v0120_HRMS_TRAINING_APPROVAL where cmp_id=@cmp_id 
--		and isnull(branch_id,0)IN (select data from dbo.split(branch_id,'#')))TA --isnull(@branch_id,isnull(branch_id,0)))TA --Mukti(29012016)
--		on TA.Training_Apr_ID=Qr.Training_Apr_ID
--		where QR.cmp_id=@cmp_id  and QR.Training_Apr_ID=isnull(@training_apr_id,QR.Training_Apr_ID) order by Training_End_Date desc
--RETURN  




