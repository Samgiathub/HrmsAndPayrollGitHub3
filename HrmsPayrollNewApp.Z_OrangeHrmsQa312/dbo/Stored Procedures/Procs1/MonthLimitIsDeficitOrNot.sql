
CREATE PROCEDURE [dbo].[MonthLimitIsDeficitOrNot]
	@CMP_ID int,
	@MonthExemptLimitInSec NUMERIC(18,0),
	@EmployeeId bigint = 0
AS  
BEGIN  

 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ANSI_WARNINGS OFF  


		If @EmployeeId != 0
		BEGIN
			CREATE TABLE #Emp_Cons 
			(  
				Emp_ID numeric ,   
				Branch_ID numeric,
				Increment_ID numeric  
			);
			CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);

			insert into #Emp_Cons
			SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK) 
															INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																		FROM	T0095_INCREMENT I3 WITH (NOLOCK) 
																		WHERE	I3.Increment_Effective_Date <= GetDATE() and I3.emp_id = @EmployeeId
																		GROUP BY I3.Emp_ID
																		) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
													WHERE	I2.Cmp_ID = @Cmp_Id 
													GROUP BY I2.Emp_ID
					) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
			WHERE	I1.Cmp_ID=@Cmp_Id	
		END

		--delete d from #Data d inner join  (
		--		select d.For_date , d.emp_id from #DATA D 
		--		inner join  T0140_LEAVE_TRANSACTION L 
		--		on d.EMP_ID = L.Emp_ID and d.for_date = l.For_Date
		--		where Leave_Used > 0
		--) as a on a.emp_id = d.emp_id and d.for_date = a.for_date
		--Where D.P_Days=0

		Select *
		,CASE WHEN LATEMINUTESEC > 0 AND LATEMINUTESEC > EmpLateLimitSec THEN (LATEMINUTESEC - EmpLateLimitSec) ELSE 0 END AS ActualLateLimit
		,CASE WHEN EARLYMINUTESEC > 0 AND EARLYMINUTESEC > EmpEarlyLimitSec THEN (EARLYMINUTESEC - EmpEarlyLimitSec) ELSE 0 END AS ActualEarlyLimit
		,0 as DeductMonthLimit
		,DateDiff(s,Shift_Start_Time,Shift_end_Time) as ShiftDurationSec
		into #TempData1
		from (
			select AM.*
					, @MonthExemptLimitInSec as MonthLimitSec
					,case when dbo.F_Return_sec(Emp_Late_Limit) > 0 then dbo.F_Return_sec(Emp_Late_Limit) else dbo.F_Return_sec(GS.Late_Limit) END as EmpLateLimitSec
					,Case when Cast(Shift_Start_Time as Time) <> '00:00' then 
						case when  DateDiff(s,Shift_Start_Time,In_Time) < 0 
							 then 0 
								when  DATEDIFF(S,SHIFT_START_TIME,IN_TIME) > LTRIM(DATEDIFF(S, 0, EMP_LATE_LIMIT)) 
									then DATEDIFF(S,SHIFT_START_TIME,IN_TIME)
							 else 0 
						end
					Else
						Case when DateDiff(s,Shift_Start_Time,In_Time) < 0 then 0
						     when DateDiff(s,Shift_Start_Time,In_Time) >  LTRIM(DATEDIFF(s, 0, Emp_Late_Limit)) then  
							      DateDiff(s,Shift_Start_Time,In_Time)
						else 0 end
					End  as LateMinuteSec
			,case when dbo.F_Return_sec(Emp_Early_Limit) > 0 then dbo.F_Return_sec(Emp_Early_Limit) else dbo.F_Return_sec(GS.Early_Limit) END as EmpEarlyLimitSec
			,Case when Cast(Shift_End_Time as Time) <> '00:00' then 
						case when  DateDiff(s,OUT_time,Shift_End_Time) < 0 
							 then 0 
								when  DateDiff(s,OUT_time,Shift_End_Time) > LTRIM(DATEDIFF(S, 0, Emp_Early_Limit)) 
									then DateDiff(s,OUT_time,Shift_End_Time)
							 else 0 
						end
					Else
						Case when DateDiff(s,OUT_time,Shift_End_Time) < 0 then 0
						     when DateDiff(s,OUT_time,Shift_End_Time) >  LTRIM(DATEDIFF(s, 0, Emp_Early_Limit)) then  
							      DateDiff(s,OUT_time,Shift_End_Time)
						else 0 end
					End  as EarlyMinuteSec
			FROM #DATA AM INNER JOIN #Emp_Cons E ON AM.Emp_ID=E.Emp_ID and Am.P_days > 0 
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON E.INCREMENT_ID=I.INCREMENT_ID
			INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON I.Branch_ID = GS.Branch_ID
			INNER JOIN(
						Select MAX(For_Date) as ForDate,Branch_ID FROM T0040_GENERAL_SETTING 
						Where Cmp_ID = @CMP_ID
						GROUP By Branch_ID
					  ) as QRY ON GS.For_Date = QRY.ForDate AND GS.Branch_ID = QRY.Branch_ID
		    WHERE (CASE WHEN GS.IS_LATE_MARK = 0 THEN 0 ELSE I.Emp_Late_Mark END) = 1  or	(I.Emp_Early_mark = 1 ) 
		) a
	
	--select Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT,Emp_OT_min_Limit
	--	,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change
	--	,Flag,Weekoff_OT_Sec,Holiday_OT_Sec,Chk_By_Superior,IO_Tran_Id,OUT_Time,Shift_End_Time
	--	,OT_End_Time,Working_Hrs_St_Time,Working_Hrs_End_Time,GatePass_Deduct_Days
	--	,MonthLimitSec,EmpLateLimitSec,LateMinuteSec,EmpEarlyLimitSec,EarlyMinuteSec,ActualLateLimit,ActualEarlyLimit,DeductMonthLimit
	--	,ShiftDurationHours
	--	,dbo.F_Return_Hours(Duration_in_sec) as EmpWorkingDurInHours
	-- from  #TempData1
	

	select ROW_NUMBER() over(order by Emp_Id) as rn,* into #tmpEmp_cons from #Emp_Cons
	
	Delete T
	from #TempData1  t inner join 
	(
		select l.For_Date ,E.emp_Id
		from T0140_LEAVE_TRANSACTION L WITH (NOLOCK) 
		inner join #data E on L.Emp_ID = E.Emp_id and L.For_Date = e.For_date
		--where EMP_Id in (3,14) 
		and Leave_Used >0
	) a on t.for_date = a.For_Date and T.emp_Id = a.emp_id

	select ROW_NUMBER() OVER(partition by (emp_Id) ORDER BY (SELECT NULL)) AS RowNo,
	Emp_Id,For_date,Duration_in_sec,Shift_ID,Shift_Type,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit,P_days,OT_Sec,In_Time,Shift_Start_Time,OT_Start_Time,Shift_Change
	,Flag,Weekoff_OT_Sec,Holiday_OT_Sec,Chk_By_Superior,IO_Tran_Id,OUT_Time,Shift_End_Time,OT_End_Time,Working_Hrs_St_Time,Working_Hrs_End_Time,GatePass_Deduct_Days
	,MonthLimitSec,EmpLateLimitSec,LateMinuteSec,EmpEarlyLimitSec,EarlyMinuteSec,ActualLateLimit,ActualEarlyLimit,DeductMonthLimit,ShiftDurationSec
		into #TempData
	from #TempData1 
	where Duration_in_sec < ShiftDurationSec



	Declare @empCount as int = 0
	DECLARE @empCounter INT = 1
	DECLARE @empID numeric(9,0) = 0
	select @empCount = count(1) from #tmpEmp_cons

	Declare @EmpWiseMonthExemptLimitInSec as numeric = 0
	set @EmpWiseMonthExemptLimitInSec = @MonthExemptLimitInSec
	WHILE (@empCounter <= @empCount)
	BEGIN
						select @empID  = emp_id from #tmpEmp_cons where rn = @empCounter
						Declare @rowCount As Int = 0
						select @rowCount = count(1) from #TEMPDATA  where emp_id = @empID
						Declare @TotalLateAndEarlyMinuteSec as numeric(18,0) = 0
						Declare @TotalActualLimit as numeric(18,0) = 0
						Declare @For_date as DATE
						Declare @EMP_Id as int
						DECLARE @Counter INT = 1
						set @MonthExemptLimitInSec = @EmpWiseMonthExemptLimitInSec

						WHILE (@Counter <= @rowCount)
						BEGIN
								select @TotalLateAndEarlyMinuteSec = (LateMinuteSec + EarlyMinuteSec)
								,@TotalActualLimit = (ActualLateLimit + ActualEarlyLimit)
								,@For_date =T.For_date
								,@EMP_Id = t.Emp_ID
								from #TEMPDATA t 
								left join T0140_LEAVE_TRANSACTION L WITH (NOLOCK)  on T.emp_id =L.Emp_ID and T.For_date = L.For_Date and Leave_Used <> 1
								where RowNo = @Counter and T.emp_id = @empID
								
								if @TotalLateAndEarlyMinuteSec > 0
								BEGIN
										-- select (@MonthExemptLimitInSec- @TotalActualLimit),@For_date
										if ((@MonthExemptLimitInSec- @TotalActualLimit) >= 0) 
										BEGIN	
											update #TEMPDATA set DeductMonthLimit = @MonthExemptLimitInSec- @TotalActualLimit ,P_days = 1  where RowNo = @Counter and emp_id = @empID
										END
								END
								IF ((@MonthExemptLimitInSec- @TotalActualLimit) >= 0) 
								BEGIN	
									 SET @MonthExemptLimitInSec = @MonthExemptLimitInSec - @TotalActualLimit
								END
								else 
								BEGIN
											update #TEMPDATA set P_days = 0.5  where RowNo = @Counter and emp_id = @empID
								END
								SET @Counter  = @Counter  + 1
						END
						if Exists(select 1 from #TEMPDATA)
						BEGIN
							Update d SET d.P_days = t.P_days
							FROM #data d 
							INNER JOIN #TEMPDATA T 
							ON d.For_date = t.For_date and D.Emp_Id = T.Emp_Id 
							where t. emp_id = @empID
						END
			
			set @empCounter = @empCounter + 1
	END -- Outer while	
END  
