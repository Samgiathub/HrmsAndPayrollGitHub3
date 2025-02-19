
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Attendance_Detail_For_Mail_Apporval]
	  @Cmp_id numeric(18,0)
	 ,@Emp_id numeric(18,0)	
	 ,@Curr_rpt_level  numeric(18,0)
	 ,@IO_Tran_Id numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		--Added by Jaina 01-05-2020 Start

			Declare @Scheme_Id numeric(18,0)
			Declare @Is_HOD tinyint
			Declare @Increment_Id numeric(18,0)
			Declare @Dept_Id numeric(18,0)
			
			Declare @Manager_HOD numeric(18,0)
			Declare @Is_RMToRM numeric(18,0) = 0
			DECLARE @R_Emp_Id1 as NUMERIC
			SET	@R_Emp_Id1 = 0
			DECLARE @R_Emp_Id2 as NUMERIC = 0
			
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


		INSERT INTO #tbl_Scheme_Leave (Scheme_ID, Leave,Is_Fwd_Leave_Rej,is_rpt_manager,rpt_level,Max_Leave_Days,Is_RMToRM,Is_HOD)
					SELECT  T0050_Scheme_Detail.Scheme_Id, Leave, Is_Fwd_Leave_Rej,Is_RM,rpt_level,Leave_Days,Is_RMToRM,Is_HOD
					FROM T0050_Scheme_Detail WITH (NOLOCK)
					Inner Join T0040_Scheme_Master WITH (NOLOCK) ON T0050_Scheme_Detail.Scheme_Id = T0040_Scheme_Master.Scheme_Id
					WHERE rpt_level = @Curr_rpt_level	And T0040_Scheme_Master.Scheme_Type = 'Attendance Regularization'  --Check Scheme Type --Ankit 13052014
						 and T0050_Scheme_Detail.Scheme_Id = 
						 (
							SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK)
													  WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Attendance Regularization')
								And Type = 'Attendance Regularization'
							
						)


			--select * from #tbl_Scheme_Leave

			SELECT @INCREMENT_ID = INCREMENT_ID FROM FN_GETEMPINCREMENT(@CMP_ID,@EMP_ID,GETDATE())
			SELECT @DEPT_ID = DEPT_ID,@Branch_id = Branch_ID FROM T0095_INCREMENT WITH (NOLOCK) WHERE INCREMENT_ID = @INCREMENT_ID
	
			SELECT @IS_HOD = IS_HOD, @Is_RMToRM = Is_RMToRM FROM #TBL_SCHEME_LEAVE
			IF @IS_HOD = 1
			BEGIN
									
				SELECT @MANAGER_HOD = EMP_ID
					FROM T0095_DEPARTMENT_MANAGER DM WITH (NOLOCK) INNER JOIN 
					(SELECT MAX(EFFECTIVE_DATE) AS MAX_DATE,DEPT_ID	 FROM T0095_DEPARTMENT_MANAGER WITH (NOLOCK) GROUP BY DEPT_ID) MDM 
					ON DM.DEPT_ID=MDM.DEPT_ID AND DM.EFFECTIVE_DATE=MDM.MAX_DATE
					WHERE DM.DEPT_ID=@DEPT_ID
						
			END
		--Added by Jaina 01-05-2020 END	

	--Added By Jimit 03112018
			
			if @Is_RMToRM = 1
			Begin
					SELECT	@R_Emp_Id1 = R_Emp_ID 
					FROM	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
							(
								select	max(Effect_Date) as Effect_Date,emp_id 
								from	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
								where	ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
								GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
					where ERD.Emp_ID = @Emp_ID
			
					If @R_Emp_Id1 <> 0
						BEGIN
						
								SELECT @R_Emp_Id2 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
									(select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
										where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
									GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
								where ERD.Emp_ID = @R_Emp_Id1								
						
						
						END
					------------------Ended----------------------	
			END

						

    if exists (SELECT Rpt_Level FROM T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) WHERE IO_Tran_ID = @IO_Tran_Id )
		begin
			

		




			Select distinct
			LLA.* , tbl1.Rpt_Level as Rpt_Level_1,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval --,tbl1.Is_Fwd_Leave_Rej
			,ISNULL((Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then VLA.Emp_ID 
																	when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 03112018
																	when isnull(tbl1.Is_HOD,0) = 1 then @Manager_HOD   --Added by Jaina 01-05-2020
																 ELSE (CASE WHEN tbl1.Is_BM > 0 THEN 
			(
						SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
						WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = 
						(
							
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = LLA.Emp_ID
						
						) 
						AND Effective_Date <= LLA.For_Date) AND dbo.T0095_MANAGERS.branch_id = 
						(
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = lla.Emp_ID
						)

			)
			 else tbl1.App_Emp_ID END) END ) ELSE tbl1.App_Emp_ID  end ),0) as s_emp_id_Scheme_current
			 ,tbl1.Leave_Days As Max_Leave_Days  --Added by Jaina 01-05-2020
			Into #Leave
			from 
			T0115_AttendanceRegu_Level_Approval LLA WITH (NOLOCK)
			inner join  T0150_EMP_INOUT_RECORD	VLA WITH (NOLOCK) on VLA.IO_Tran_Id = LLA.IO_Tran_Id	
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) where T0115_AttendanceRegu_Level_Approval.IO_Tran_ID = @IO_Tran_ID) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM	, Leave_Days		
				,SD.Is_RMToRM --Added By Jimit 03112018
				,sd.Is_HOD  --Added by Jaina 01-05-2020
				
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Attendance Regularization')
								And Type = 'Attendance Regularization'
							) 
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Attendance Regularization')
					And Type = 'Attendance Regularization'
				)
				and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) where T0115_AttendanceRegu_Level_Approval.IO_Tran_ID = @IO_Tran_Id)
				
			) as tbl1
			where lla.IO_Tran_ID = @IO_Tran_Id 
			 and lla.Rpt_Level = (select max(Rpt_Level) from T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) where T0115_AttendanceRegu_Level_Approval.IO_Tran_ID = @IO_Tran_Id)
			 and tbl1.Rpt_Level <= @Curr_rpt_level

			 

			 ---Added by Jaina 01-05-2020 Start			

			 select @Max_Leave_Days = Max_Leave_Days ,@For_date = For_Date from #Leave
			 --select @Max_Leave_Days
			if @Max_Leave_Days > 0 
			begin
				select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,Month(@For_date),Year(@For_Date))

				if @For_date >= @Month_End_date
				begin
					select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,Month(@For_date)+1,Year(@For_Date))
				end
			
			--select * from T0150_EMP_INOUT_RECORD 
			--					where For_Date between @Month_st_Date and @Month_End_date and Reason <> ''
			--						  and App_Date is not null and Apr_Date is not null	and Emp_ID = @Emp_id
			
				--select @Total_Count
				select @Total_Count = count(1) from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
								where For_Date between @Month_st_Date and @Month_End_date and Reason <> ''
									  and App_Date is not null and Apr_Date is not null	and Emp_ID = @Emp_id
			--select @Total_Count
				if @Max_Leave_Days > @Total_Count
					update L set is_final_approval=1 from #Leave  L where Emp_id=@Emp_id and For_date=@For_Date

			END

			select * from #Leave
			---Added by Jaina 01-05-2020 End
		End
	Else
		Begin
		   
		 
			SELECT 
			distinct  LAD.* , tbl1.Rpt_Level as Rpt_Level_1,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,'' As Effective_Date,
			(Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then 
				(
					SELECT  TOP 1 ERD.R_Emp_ID   FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
 					( select max(Effect_Date) as Effect_Date,ERD1.Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
 					INNER join (Select Emp_ID From T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID = LAD.Emp_ID ) Qry 
 						on ERD1.Emp_ID = Qry.Emp_ID
 						where ERD1.Effect_Date <= getdate() and ERD1.Emp_ID = LAD.Emp_ID GROUP by ERD1.Emp_ID
 					) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date INNER JOIN
 					T0080_EMP_MASTER EM WITH (NOLOCK) ON Em.Emp_ID = ERD.Emp_ID
					WHERE ERD.Emp_ID = LAD.Emp_ID
				    
				
				)
				when isnull(tbl1.Is_RMToRM,0) = 1 THEN	@R_Emp_Id2  --Added By Jimit 03112018
				when isnull(tbl1.Is_HOD,0) = 1 Then @Manager_HOD  --Added by Jaina 01-05-2020
			else tbl1.App_Emp_ID end ) else tbl1.App_Emp_ID end) as s_emp_id_Scheme_current
			,tbl1.Leave_Days As Max_Leave_Days
			Into #Leave1
			FROM T0150_EMP_INOUT_RECORD LAD WITH (NOLOCK)
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days
				,SD.Is_RMToRM,sd.Is_HOD
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Attendance Regularization')
								And Type = 'Attendance Regularization'
							)
							--AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) --and Rpt_Level = 1
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Attendance Regularization')
					And Type = 'Attendance Regularization'
				)
				--AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) 
				and SD.Rpt_Level = 1
			) as tbl1
			WHERE LAD.IO_Tran_Id = @IO_Tran_Id and LAD.Chk_By_Superior = 0

			---Added by Jaina 01-05-2020 Start			
			--select * from #Leave1 where emp_id=@Emp_id
			 select @Max_Leave_Days = Max_Leave_Days ,@For_date = For_Date from #Leave1
			 --select @Max_Leave_Days
			if @Max_Leave_Days > 0 
			begin
				select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,Month(@For_date),Year(@For_Date))

				if @For_date >= @Month_End_date
				begin
					select @Month_st_Date = Sal_St_Date,@Month_End_date = Sal_End_Date from F_Get_SalaryDate(@Cmp_Id,@Branch_Id,Month(@For_date)+1,Year(@For_Date))
				end

				select @Total_Count = count(1) from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
								where For_Date between @Month_st_Date and @Month_End_date and Reason <> ''
									  and App_Date is not null and Apr_Date is not null and Emp_ID=@Emp_id
						
				if @Max_Leave_Days > @Total_Count
				begin
					
					update L set is_final_approval=1 from #Leave1  L where Emp_id=@Emp_id and For_date=@For_Date
					
				end
			END

			select * from #Leave1
			---Added by Jaina 01-05-2020 End
			
		End

		
		
END

