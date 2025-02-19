
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EMP_ATTENDANCE_CALANDER_DISPLAY]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint 	varchar(MAX)
	,@Report_For	varchar(50) = 'EMP RECORD'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	--Declare @Is_Cancel_Holiday  numeric(1,0)
	--Declare @Is_Cancel_Weekoff	numeric(1,0)	
		
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	);
	CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);

	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons(Emp_ID, Branch_ID, Increment_ID)
			SELECT	I.Emp_Id, I.Branch_ID, I.Increment_ID 
			FROM	T0095_INCREMENT I WITH (NOLOCK)
					INNER JOIN (SELECT	MAX(I1.Increment_ID) AS Increment_Id, I1.Emp_ID 
								FROM	T0095_INCREMENT I1  WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.Increment_Effective_Date <= @To_Date
													GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
								GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_Id
					INNER JOIN dbo.Split(@Constraint, '#') T ON I.Emp_ID=CAST(T.Data AS NUMERIC) AND T.Data <> ''			
		END
	ELSE
		BEGIN
			INSERT INTO #Emp_Cons(Emp_ID, Branch_ID, Increment_ID)
			SELECT	I.Emp_Id, I.Branch_ID, I.Increment_ID 
			FROM	T0095_INCREMENT I WITH (NOLOCK) 
					INNER JOIN (SELECT	MAX(I1.Increment_ID) AS Increment_Id, I1.Emp_ID 
								FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
										INNER JOIN (SELECT	MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.Increment_Effective_Date <= @To_Date
													GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
								GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_Id
					INNER JOIN (SELECT	Emp_ID 
								FROM	(SELECT Emp_ID, Cmp_ID, Join_Date, IsNull(Left_Date, @To_Date) AS Left_Date
										 FROM	T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) EL 
										 WHERE	Cmp_ID = @Cmp_ID  
												AND (
														(@From_Date >= Join_Date AND @From_Date <= Join_Date) 
													 OR (@From_Date <= Join_Date AND @To_Date >= Join_Date)	
													 OR (@To_Date >= Join_Date AND @To_Date <= Join_Date)
													 OR (Left_Date IS NULL AND @To_Date >= Join_Date))
													) EL ON I.Emp_ID=EL.Emp_ID 
			WHERE	I.Cmp_ID = @Cmp_ID AND IsNull(Cat_ID,0) = IsNull(@Cat_ID ,IsNull(Cat_ID,0))
					AND Branch_ID = IsNull(@Branch_ID ,Branch_ID)
					AND Grd_ID = IsNull(@Grd_ID ,Grd_ID)
					AND IsNull(Dept_ID,0) = IsNull(@Dept_ID ,IsNull(Dept_ID,0))
					AND IsNull(Type_ID,0) = IsNull(@Type_ID ,IsNull(Type_ID,0))
					AND IsNull(Desig_ID,0) = IsNull(@Desig_ID ,IsNull(Desig_ID,0))
					AND I.Emp_ID = IsNull(@Emp_ID ,I.Emp_ID) 					
		END


	
	IF @Report_For = 'EMP RECORD'
		BEGIN
			SELECT	E.Emp_ID ,E.Emp_code,E.Emp_full_Name ,Comp_Name,Branch_Address,
					Branch_Name,Dept_Name,Grd_Name,Desig_Name,Type_Name,CMP_NAME,CMP_ADDRESS,
					@From_Date as P_From_date ,@To_Date as P_To_Date			
			FROM	#Emp_Cons EC 
					INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  
					INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = EC.Emp_ID AND I.Increment_Id = EC.Increment_Id
					INNER JOIN	T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_Id = gm.Grd_ID 
					INNER JOIN  T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID 
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID 
					LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.DESIG_ID = DGM.DESIG_ID 
					INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID 
					LEFT OUTER JOIN T0040_Type_Master TM WITH (NOLOCK) on I.[Type_ID] = TM.[Type_ID]			
			RETURN 
		END
	ELSE
		BEGIN
			DECLARE @Required_Execution BIT
			SET @Required_Execution = 0
			IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
				BEGIN
					CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
					CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
					SET @Required_Execution = 1
				END

			IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
				BEGIN
					CREATE TABLE #EMP_WEEKOFF
					(
						Row_ID			NUMERIC,
						Emp_ID			NUMERIC,
						For_Date		DATETIME,
						Weekoff_day		VARCHAR(10),
						W_Day			numeric(4,1),
						Is_Cancel		BIT
					)
					CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
					SET @Required_Execution = 1
				END

			IF @Required_Execution = 1
				EXEC SP_GET_HW_ALL @Constraint=@Constraint,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0	
		END
	
	--Declare @Date_Diff numeric 
	--Declare @New_To_Date datetime 
	--Declare @Row_ID	numeric 
	--Declare @strHoliday_Date As Varchar(1000)
	--Declare @StrWeekoff_Date  varchar(1000)
	
	--set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	--set @Date_Diff = 0
	--set @New_To_Date = dateadd(d,@date_diff,@To_Date)
	--Set @StrHoliday_Date = ''      
	--set @StrWeekoff_Date = ''
	
	CREATE TABLE	#ATT_PERIOD
	(
		For_Date	datetime,
		Row_ID		numeric
	)
	CREATE UNIQUE CLUSTERED INDEX IX_ATT_PERIOD ON #ATT_PERIOD(FOR_DATE)

	INSERT INTO #ATT_PERIOD
	SELECT	DATEADD(D, ROW_ID, @From_Date) AS FOR_DATE, ROW_ID
	FROM	(SELECT (ROW_NUMBER() OVER(ORDER BY OBJECT_ID) - 1) ROW_ID
			 FROM	SYS.objects O) T 
	WHERE	DATEADD(D, ROW_ID, @From_Date) <= @To_Date

	--set @For_Date = @From_Date
	--set @Row_ID = 1
	--While @For_Date <= @New_To_Date
	--	begin
			
	--		insert into #ATT_PERIOD 
	--		select @For_Date ,@Row_ID
	--		set @Row_ID =@Row_ID + 1
	--		set @for_Date = dateadd(d,1,@for_date)
	--	end

	IF OBJECT_ID('tempdb..#Att_Muster') IS NOT NULL
		DROP TABLE #Att_Muster
	
	 CREATE table #Att_Muster 
	 (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			[Status]	varchar(10),
			Leave_Count	numeric(5,1),
			WO_HO		varchar(2),
			Status_2	varchar(10),
			Row_ID		numeric ,
			WO_HO_Day	numeric(3,1) default 0,
			P_days		numeric(5,1) default 0
	 )
	 CREATE NONCLUSTERED INDEX IX_ATT_MUSTER ON #Att_Muster (EMP_ID,FOR_DATE) INCLUDE(CMP_ID,WO_HO_Day,WO_HO)

	--CREATE table #Emp_Holiday
	--  (
	--		Emp_Id		numeric , 
	--		Cmp_ID		numeric,
	--		For_Date	datetime,
	--		H_Day		numeric(3,1),
	--		is_Half_day tinyint
	--  )	  

	--CREATE table #Emp_Weekoff
	--  (
	--		Emp_Id		numeric , 
	--		Cmp_ID		numeric,
	--		For_Date	datetime,
	--		W_Day		numeric(3,1)
	--  )	  
	  
	INSERT	INTO #Att_Muster(Emp_ID,Cmp_ID,For_Date,row_ID)
	SELECT 	Emp_ID ,@Cmp_ID,For_Date,Row_ID 
	FROM	#ATT_PERIOD CROSS JOIN #Emp_Cons
	
		
	--Declare cur_emp cursor for 
	--select Emp_ID From #Emp_Cons 
	--open cur_emp
	--fetch next from Cur_Emp into @Emp_ID 
	--while @@fetch_Status = 0
	--	begin 
	--		select 	@Branch_ID = Branch_ID From T0095_Increment I inner join 
	--				( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  --Changed by Hardik 10/09/2014 for Same Date Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
	--		Where I.Emp_ID = @Emp_ID

	--		select @Is_Cancel_Holiday = IsNull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = IsNull(Is_Cancel_Weekoff,0)
				
	--		from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
	--		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
			
			
			
	--		--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,'',0,0 ,1,@Branch_ID
	--		--Exec dbo.SP_EMP_WEEKOFF_DATE_GET  @Emp_Id,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Weekoff,'','',0,0,1
	--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_weekoff,@StrHoliday_Date,@StrWeekoff_Date output,0,0,1       
	--		Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,@StrHoliday_Date output,0,0,1,@Branch_ID,@StrWeekoff_Date  	 
	--		fetch next from Cur_Emp into @Emp_ID 
	--	end 
	--close cur_Emp
	--Deallocate cur_Emp
	
	
		
	UPDATE	#Att_Muster
	SET		Status = 'P',P_days = 1
	FROM	#Att_Muster AM 
			INNER JOIN T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID AND AM.FOR_DATE = EIR.FOR_DATE 
	WHERE	NOT EIR.IN_TIME IS NULL AND NOT EIR.OUT_TIME IS NULL --added by Falak 01-APR-2011
			AND Am.For_Date >=@From_Date AND Am.For_Date <=@To_Date
	
		
	--Alpesh 27-Jul-2011
	UPDATE	#Att_Muster
	SET		Status = CASE EIR.Half_Full_day WHEN 'First Half' THEN 'FH' WHEN 'Second Half' THEN 'SH' ELSE '' END,
			P_days = 0.5
	FROM	#Att_Muster AM 
			INNER JOIN T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID AND AM.FOR_DATE = EIR.FOR_DATE 
	WHERE	(EIR.Half_Full_day='First Half' OR EIR.Half_Full_day='Second Half') 
			AND EIR.Chk_By_Superior=1 AND Am.For_Date >=@From_Date AND Am.For_Date <=@To_Date
	
			
	UPDATE	#Att_Muster
	SET		Leave_Count = (IsNull(Leave_Used,0) + IsNull(CompOff_Used,0)), --Leave_Used, 
			P_days=0, -- P_days = case Leave_Used when 0.5 then 0.5 else 0 end,
			Status_2 = (IsNull(Leave_Used,0) + IsNull(CompOff_Used,0)) -- Changed By Gadriwala Muslim 02102014
	FROM	#Att_Muster AM 
			INNER JOIN T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID AND AM.FOR_DATE = LT.FOR_DATE 
	WHERE	(LT.Leave_Used  > 0 OR LT.CompOff_Used > 0)  -- Changed By Gadriwala Muslim 02102014
			AND Am.For_Date >=@From_Date AND Am.For_Date <=@To_Date
	
	
	UPDATE	#Att_Muster 
	SET		WO_HO = 'HO',
			WO_HO_Day =eh.H_Day
	FROM	#Att_Muster AM 
			INNER JOIN #Emp_Holiday EH ON AM.Emp_Id = EH.EMP_ID AND AM.For_Date=EH.FOR_DATE


	UPDATE	#Att_Muster 
	SET		WO_HO = 'W',
			WO_HO_Day = EW.W_Day
	FROM	#Att_Muster  AM 
			INNER JOIN #Emp_Weekoff EW ON AM.Emp_Id = EW.Emp_ID AND AM.For_Date = EW.For_Date AND W_Day > 0
		
				
	UPDATE	#Att_Muster
	SET		Status_2 = 'CO-' + WO_HO
	WHERE	[Status] = 'P' AND (WO_HO = 'W' OR WO_HO = 'HO') AND WO_HO_Day = 1 
			AND For_Date >= @From_Date AND For_Date <= @To_Date

	UPDATE	#Att_Muster
	SET		Status_2 = 'CO-' + WO_HO,
			P_days = 0.5
	WHERE	Status = 'P' AND (WO_HO = 'W' OR WO_HO = 'HO')
			AND WO_HO_Day = 0.5 AND For_Date >= @From_Date AND For_Date <=@To_Date
		
	UPDATE	#Att_Muster
	SET		Status = WO_HO
	WHERE	(IsNull([Status],'') <> 'P' AND IsNull([Status],'') <> 'FH' AND IsNull([Status],'') <> 'SH') AND (WO_HO = 'HO' OR WO_HO = 'W') 
			AND For_Date >=@From_Date AND For_Date <=@To_Date

		
	UPDATE	#Att_Muster
	SET		[Status] = 'A'
	WHERE	[Status] IS NULL
			AND For_Date >= @From_Date AND For_Date <= @To_Date
	
	UPDATE	#Att_Muster
	SET		[Status] = LM.LEAVE_CODE
	FROM	#Att_Muster AM 
			INNER JOIN T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID
			INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID=LM.LEAVE_ID AND AM.FOR_DATE = LT.FOR_DATE 
	WHERE	(LT.Leave_Used  > 0 OR LT.CompOff_Used > 0) --and Status='A' -- Changed By Gadriwala Muslim 02102014
			AND Am.For_Date >= @From_Date AND Am.For_Date <= @To_Date
	
		
	--SELECT	AM.* , E.Emp_code,CAST(E.Emp_Code AS VARCHAR) + ' - ' + E.Emp_Full_Name AS Emp_Full_Name,Branch_Address,Comp_Name,
	SELECT	AM.* , E.Emp_code,E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name AS Emp_Full_Name,Branch_Address,Comp_Name,
			Branch_Name,Dept_Name,Grd_Name,Desig_Name,@From_Date AS P_From_date,@To_Date AS P_To_Date 
	FROM	#Att_Muster AM 
			INNER JOIN #Emp_Cons EC ON AM.Emp_Id=EC.Emp_ID
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.EMP_ID = I.EMP_ID AND EC.Increment_ID=I.Increment_ID
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_Id = GM.Grd_ID 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.BRANCH_ID = BM.BRANCH_ID 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.DESIG_ID = DGM.DESIG_ID 
	ORDER BY Emp_Code,Am.For_Date
RETURN




