
CREATE PROCEDURE [dbo].[MonthLimitLateExemption_Backup_DIvyaraj_22072024]    
@CMP_ID int,
@MonthExemptLimitInSec NUMERIC(18,0)
AS  
BEGIN  

 SET NOCOUNT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
 SET ANSI_WARNINGS OFF  
 
		--delete from #DATA where For_date in ('2024-04-02 00:00:00.000','2024-04-06 00:00:00.000')
		delete d from #Data d inner join  (
				select d.For_date , d.emp_id from #DATA D 
				inner join  T0140_LEAVE_TRANSACTION L 
				on d.EMP_ID = L.Emp_ID and d.for_date = l.For_Date
				where Leave_Used > 0
		) as a on a.emp_id = d.emp_id and d.for_date = a.for_date
		Where D.P_Days=0

		--select * from T0140_LEAVE_TRANSACTION where emp_id = 1106
		
		Select *,CASE WHEN LATEMINUTESEC > 0 AND LATEMINUTESEC > EmpLateLimitSec THEN (LATEMINUTESEC - EmpLateLimitSec) ELSE 0 END AS ActualLateLimit
		,0 as DeductMonthLimit		
		into #TempData1
		from (
			select AM.*
					, @MonthExemptLimitInSec as MonthLimitSec
					,case when dbo.F_Return_sec(Emp_Late_Limit) > 0 then dbo.F_Return_sec(Emp_Late_Limit) else dbo.F_Return_sec(GS.Late_Limit) END as EmpLateLimitSec
					,Case when Cast(Shift_Start_Time as Time) <> '00:00' then 
						case when DateDiff(s,Shift_Start_Time,In_Time) < 0 then 0 when  DateDiff(s,Shift_Start_Time,In_Time) > LTRIM(DATEDIFF(s, 0, Emp_Late_Limit)) then  
							      DateDiff(s,Shift_Start_Time,In_Time)
						else 0 end
					Else
						Case when DateDiff(s,Shift_Start_Time,In_Time) < 0 then 0
						     when DateDiff(s,Shift_Start_Time,In_Time) >  LTRIM(DATEDIFF(s, 0, Emp_Late_Limit)) then  
							      DateDiff(s,Shift_Start_Time,In_Time)
						else 0 end
					End  as LateMinuteSec
			FROM #DATA AM INNER JOIN #Emp_Cons E ON AM.Emp_ID=E.Emp_ID and Am.P_days > 0 
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON E.INCREMENT_ID=I.INCREMENT_ID
			INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON I.Branch_ID = GS.Branch_ID
			INNER JOIN(
						Select MAX(For_Date) as ForDate,Branch_ID FROM T0040_GENERAL_SETTING 
						Where Cmp_ID = @CMP_ID
						GROUP By Branch_ID
					  ) as QRY ON GS.For_Date = QRY.ForDate AND GS.Branch_ID = QRY.Branch_ID
		    WHERE (CASE WHEN GS.IS_LATE_MARK = 0 THEN 0 ELSE I.Emp_Late_Mark END) = 1 or	(I.Emp_Early_mark = 1 ) 
		) a
	
	
	select ROW_NUMBER() over(order by Emp_Id) as rn,* into #tmpEmp_cons from #Emp_Cons

	

	Delete T
	from #TempData1  t inner join 
	(
		select l.For_Date ,E.emp_Id
		from T0140_LEAVE_TRANSACTION L WITH (NOLOCK) inner join #data E on L.Emp_ID = E.Emp_id and L.For_Date = e.For_date
		--where EMP_Id in (3,14) 
		and Leave_Used >0
	) a on t.for_date = a.For_Date and T.emp_Id = a.emp_id

	--where For_date  in 
	--(
	--	select l.For_Date ,E.emp_Id
	--	from T0140_LEAVE_TRANSACTION L inner join #data E on L.Emp_ID = E.Emp_id and L.For_Date = e.For_date
	--	--where EMP_Id in (3,14) 
	--	and Leave_Used >0
	--)

	select ROW_NUMBER() OVER(partition by (emp_Id) ORDER BY (SELECT NULL)) AS RowNo,* into #TempData from #TempData1
	--
	--select L.*
	--from #TEMPDATA t LEFt join T0140_LEAVE_TRANSACTION L  
	--on T.emp_id =L.Emp_ID 
	--and cast(T.For_date as DATE) = cast(L.For_Date as date) 
	--and Leave_Used <> 1
	--where  T.emp_id = 1106
	--Select * from #TEMPDATA t --where For_date not in (select For_Date from T0140_LEAVE_TRANSACTION where EMP_Id = @empID and Leave_Used = 1)
	--select * from #TempData
	
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
						Declare @LateMinuteSec as numeric(18,0) = 0
						Declare @ActualLateLimit as numeric(18,0) = 0
						Declare @For_date as DATE
						Declare @EMP_Id as int
						DECLARE @Counter INT = 1
						--select * from #TEMPDATA  where emp_id = @empID
						--select * from #TempData1 where emp_id = @empID
						set @MonthExemptLimitInSec = @EmpWiseMonthExemptLimitInSec
						WHILE (@Counter <= @rowCount)
						BEGIN
								
								--select t.*,@Counter
								--from #TEMPDATA t left join T0140_LEAVE_TRANSACTION L  on T.emp_id =L.Emp_ID and T.For_date = L.For_Date and Leave_Used <> 1
								--where RowNo = @Counter and T.emp_id = @empID

								select @LateMinuteSec = LateMinuteSec,@ActualLateLimit =ActualLateLimit ,@For_date =T.For_date,@EMP_Id = t.Emp_ID
								from #TEMPDATA t left join T0140_LEAVE_TRANSACTION L WITH (NOLOCK)  on T.emp_id =L.Emp_ID and T.For_date = L.For_Date and Leave_Used <> 1
								where RowNo = @Counter and T.emp_id = @empID
								
--								select @LateMinuteSec = LateMinuteSec,@ActualLateLimit =ActualLateLimit ,@For_date = t.For_Date
--								from #TEMPDATA t inner join T0140_LEAVE_TRANSACTION L  on T.emp_id =L.Emp_ID and T.For_date = L.For_Date and Leave_Used <> 1
--								where RowNo = @Counter and T.emp_id = @empID
----								
								if @LateMinuteSec > 0
								BEGIN
										--select @LateMinuteSec,@ActualLateLimit,@empID,(@MonthExemptLimitInSec- @ActualLateLimit),@For_date
										if ((@MonthExemptLimitInSec- @ActualLateLimit) >= 0) 
										BEGIN	
											--select @MonthExemptLimitInSec, @ActualLateLimit,* from #TEMPDATA where RowNo = @Counter and emp_id = @empID
											update #TEMPDATA set DeductMonthLimit = @MonthExemptLimitInSec- @ActualLateLimit ,P_days = 1  where RowNo = @Counter and emp_id = @empID
										END
										--else
										--BEGIN	
										--	update #TEMPDATA set P_days = 0.5 where RowNo = @Counter 
										--END
								END
								--select @For_date,@EMP_Id,@MonthExemptLimitInSec,@ActualLateLimit,@Counter
								IF ((@MonthExemptLimitInSec- @ActualLateLimit) >= 0) 
								BEGIN	
									 SET @MonthExemptLimitInSec = @MonthExemptLimitInSec - @ActualLateLimit
								END
								SET @Counter  = @Counter  + 1
						END
			
						Update d SET d.P_days = t.P_days
						FROM #data d 
						INNER JOIN #TEMPDATA T 
						ON d.For_date = t.For_date and D.Emp_Id = T.Emp_Id 
						where t. emp_id = @empID
			
			set @empCounter = @empCounter + 1
	END -- Outer while	
END  
--select * from #data


			--select * from #data		where emp_id = 24 and 
--			select * from #data where emp_id = 1126 --and 
			--select t.* 
			--FROM #data d 
			--INNER JOIN #TEMPDATA T 
			--ON d.For_date = t.For_date and D.Emp_Id = T.Emp_Id
			--where t.emp_id = 24