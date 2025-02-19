
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Roster_Shift_Weekoff]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 	
	,@Branch_ID		VARCHAR(max) = ''  --Added by Jaina 20-03-2018 Start
	,@Cat_ID		VARCHAR(max) = ''
	,@Grd_ID		VARCHAR(max) = ''
	,@Type_ID		VARCHAR(max) = ''
	,@Dept_ID		VARCHAR(max) = ''
	,@Desig_ID		VARCHAR(max) = '' --Added by Jaina 20-03-2018 End
	,@Emp_ID		NUMERIC = 0
	,@Constraint	VARCHAR(max) = ''
	,@Print			tinyint = 0
	,@Vertical_Id_Multi VARCHAR(max) = ''  --Added By Jaina 19-09-2015
	,@Subvertical_Id_Multi VARCHAR(max) = '' --Added By Jaina 19-09-2015
	,@Dept_Id_Multi VARCHAR(max) = '' --Added By Jaina 19-09-2015
	,@Branch_Id_Multi VARCHAR(max) = 0 --Added By Jaina 19-09-2015
	,@Vertical_ID    VARCHAR(max) = ''
	,@SubVertical_ID VARCHAR(max) = ''
	,@SubBranch_ID   VARCHAR(max) = ''
	,@Segment_Id     VARCHAR(max) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	if @Emp_ID > 0
		BEGIN
			SET @Branch_Id_Multi = ''
			set @Dept_Id_Multi = ''
		END
		


	IF @Branch_ID = '0' or @Branch_ID = ''
		SET @Branch_ID = NULL

	IF @Cat_ID = '0' or  @Cat_ID = ''
		SET @Cat_ID = NULL
		 
	IF @Type_ID = '0' or @Type_ID = ''
		SET @Type_ID = NULL
	IF @Dept_ID = '0' or @Dept_ID = ''
		SET @Dept_ID = NULL
	IF @Grd_ID = '0' or @Grd_ID = ''
		SET @Grd_ID = NULL
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Vertical_ID='0' or @Vertical_ID = ''
		set @Vertical_ID = NULL
		
	if @SubVertical_ID='0' or @SubVertical_ID=''
		set @SubVertical_ID = NULL
		
	IF @SubBranch_ID='0' or @SubBranch_ID=''
		set @SubBranch_ID = NULL
		
	if @Segment_Id='0' or @Segment_Id=''
		set @Segment_Id = NULL
		
	IF @Desig_ID = '0' or @Desig_ID = ''
		SET @Desig_ID = NULL
	
	IF @Branch_Id_Multi= '0' OR @Branch_Id_Multi=''  --Added By Jaina 21-09-2015
		SET @Branch_Id_Multi = NULL
	
	IF @Vertical_Id_Multi = '0' OR @Vertical_Id_Multi='' --Added By Jaina 21-09-2015
		SET @Vertical_Id_Multi = NULL
	
	IF @Subvertical_Id_Multi ='0' OR @Subvertical_Id_Multi='' --Added By Jaina 21-09-2015
		SET @Subvertical_Id_Multi =NULL
		
	IF @Dept_Id_Multi='0' OR @Dept_Id_Multi='' --Added By Jaina 21-09-2015
		SET @Dept_Id_Multi= NULL
			
		
	DECLARE @Branch_Name VARCHAR(50)
	SET @Branch_Name  = ''
	
	--SELECT	@Branch_Name = Branch_Name 
	--FROM	T0030_BRANCH_MASTER 
	--WHERE	Branch_ID = @Branch_ID
	
	DECLARE @All_Weekoff BIT
	SET @All_Weekoff = 1;
	
	
	
	/*
	DECLARE @Emp_Cons Table
	(
			Emp_ID	NUMERIC   ,     
		  Branch_ID NUMERIC,
		  Increment_ID NUMERIC
	)
	
	IF @Constraint <> ''
		begin
			INSERT INTO @Emp_Cons
			SELECT  cast(data  as NUMERIC),0,0 FROM dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			
			INSERT INTO @Emp_Cons
			   SELECT emp_id,branch_id,Increment_ID FROM V_Emp_Cons WHERE 
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is NULL and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date ))
						order by Emp_ID
						
			delete  FROM @Emp_Cons WHERE Increment_ID not in (SELECT max(Increment_ID) FROM T0095_Increment
				where  Increment_effective_Date <= @to_date
				group by emp_ID)

			--SELECT I.Emp_Id FROM T0095_Increment I INNER JOIN 
			--		( SELECT max(Increment_effective_Date) as For_Date , Emp_ID FROM T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			--Where Cmp_ID = @Cmp_ID 
			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and I.Emp_ID in 
			--	( SELECT Emp_Id from
			--	(SELECT emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date FROM T0110_EMP_LEFT_JOIN_TRAN) qry
			--	where cmp_ID = @Cmp_ID   and  
			--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
			--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
			--	or Left_date is NULL and @To_Date >= Join_Date)
			--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		*/
		
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grd_ID,@Type_ID,@Dept_Id_Multi,@Desig_ID,@Emp_ID,@Constraint,0,0,@Segment_Id,@Vertical_Id_Multi,@Subvertical_Id_Multi,@SubBranch_ID,0,0,0,@Branch_Id_Multi,0,0  --Change By Jaina 19-09-2015

	CREATE TABLE #ROSTER_DATE
	(		
		Emp_id NUMERIC(18,0),
		Cmp_id NUMERIC(18,0),
		Alpha_emp_code NVARCHAR(50),
		Emp_Name_full NVARCHAR(200),
		Branch_ID		NUMERIC,
		Cat_ID		NUMERIC  ,
		Grd_ID		NUMERIC ,
		Type_ID		NUMERIC  ,
		Dept_ID		NUMERIC  ,
		Desig_ID		NUMERIC ,
		col1 NVARCHAR(1) default '',
		col1_shift NUMERIC(18,0) default 0,
		col1_comment NVARCHAR(200)  default '-' ,	
		col2 NVARCHAR(200) default '',
		col2_shift NUMERIC(18,0) default 0,
		col2_comment NVARCHAR(200) default '-' ,	
		col3 NVARCHAR(200) default '',
		col3_shift NUMERIC(18,0) default 0,
		col3_comment NVARCHAR(200) default '-' ,	
		col4 NVARCHAR(200) default '',
		col4_shift NUMERIC(18,0) default 0,
		col4_comment NVARCHAR(200) default '-' ,	
		col5 NVARCHAR(200) default '',
		col5_shift NUMERIC(18,0) default 0,
		col5_comment NVARCHAR(200) default '-' ,	
		col6 NVARCHAR(200) default '',
		col6_shift NUMERIC(18,0) default 0,
		col6_comment NVARCHAR(200) default '-' ,	
		col7 NVARCHAR(200) default '',
		col7_shift NUMERIC(18,0) default 0,
		col7_comment NVARCHAR(200) default '-' 		
	)
	
	INSERT	INTO #ROSTER_DATE (Emp_id,Cmp_id,Alpha_emp_code,Emp_Name_full,Branch_ID,Cat_ID,Grd_ID,Type_ID,Dept_ID,Desig_ID)
	SELECT	I.Emp_ID ,@Cmp_ID, Alpha_Emp_Code , Emp_Full_Name as Emp_Name_full , I.Branch_ID , I.Cat_ID , I.Grd_ID , I.Type_ID , I.Dept_ID , I.Desig_Id
	FROM	T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID
			INNER JOIN T0010_Company_Master CM WITH (NOLOCK) ON Cm.Cmp_Id =E.Cmp_ID 			
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Emp_ID=I.Emp_ID AND I.Increment_ID=EC.Increment_ID
	WHERE	E.Cmp_ID = @Cmp_Id	
	ORDER BY E.Emp_Code asc
	
	IF @Print = 1
		begin
			INSERT INTO #ROSTER_DATE (Emp_id)
			SELECT 0
		end					
								
		
	DECLARE @Emp_ID_Cur NUMERIC(18,0)
	DECLARE @Shift_ID_Cur NUMERIC(18,0)
	DECLARE @For_date_Cur DATETIME
	DECLARE @Shift_Cur NVARCHAR(200)
		
		
	CREATE TABLE #Emp_Shift
	(
		Emp_Id NUMERIC(18,0),
		For_date DATETIME,
		Shift_ID NUMERIC(18,0),
		Shift_St_Time VARCHAR(10),
		Shift_End_Time VARCHAR(10)
	)
	IF (@Constraint = '' OR @Constraint = NULL)
		SET @Constraint = @Emp_ID
			
	--Added by Sumit on 18102016		
	--SET @Constraint= isnull(@Constraint,@Emp_ID);			
	Exec P_GET_EMP_SHIFT_DETAIL @Cmp_ID=@Cmp_ID,@from_Date=@From_Date,@To_Date=@To_Date,@Constraint=@Constraint
	
	UPDATE	ES 
	SET		SHIFT_ST_TIME=  CASE WHEN (SM.Is_Half_Day=1 and SM.Week_Day = DATENAME(WEEKDAY, For_date)) THEN 
									ISNULL(SM.Half_St_Time,sm.Shift_St_Time) 
								Else 
									SM.Shift_St_Time
							End,								   
			SHIFT_END_TIME=  CASE WHEN (SM.Is_Half_Day=1 and SM.Week_Day= DATENAME(WEEKDAY, For_date)) THEN 
									ISNULL(SM.Half_End_Time,sm.Shift_End_Time) 
								Else
									SM.Shift_End_Time 
							END
	FROM	#EMP_SHIFT ES 
			INNER JOIN T0040_SHIFT_MASTER SM ON ES.SHIFT_ID=SM.SHIFT_ID
	WHERE	SM.CMP_ID=@CMP_ID 
	----Ended by Sumit on 18102016----------------------------------------------------------------------------------

	DECLARE @SQL NVARCHAR(MAX);
	DECLARE @DayIndex INT
	
	DECLARE @day_Flag VARCHAR(5)	
	--DECLARE @Temp_For_Date as DATETIME
	DECLARE curEmpRoster cursor for
	SELECT	* 
	FROM	(SELECT ESD.Emp_ID , ESD.Shift_ID, ESD.For_Date,   SM.Shift_St_Time + '-' + SM.Shift_End_Time as Shift_det  
			 FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID
					INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Shift_ID = SM.Shift_ID 					
					INNER JOIN (SELECT	MAX(For_Date) AS For_Date, SD.Emp_ID 
								FROM	T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK)
										INNER JOIN #Emp_Cons EC1 ON SD.Emp_ID=EC1.Emp_ID
								WHERE	For_Date <= @From_Date AND IsNull(Shift_Type,0)=0
								GROUP BY SD.Emp_ID) SD ON SD.Emp_ID = ESD.Emp_ID AND ESD.For_Date = SD.For_Date 
			 WHERE	ESD.Cmp_ID = @Cmp_ID
			) AS T1
	UNION
	SELECT	* 
	FROM	(SELECT	ESD.Emp_ID , ESD.Shift_ID , ESD.For_Date,   SM.Shift_St_Time + '-' + SM.Shift_End_Time as Shift_det 
			 FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC on ESD.Emp_ID = EC.Emp_ID					
					INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON ESD.Shift_ID = SM.Shift_ID  					
			 WHERE	ESD.For_Date >= @From_Date and ESD.For_Date <= @To_Date and ESD.Cmp_ID = @Cmp_ID  
			) AS T2 
	ORDER BY Emp_ID,For_Date
	OPEN curEmpRoster

	FETCH NEXT FROM curEmpRoster INTO @Emp_ID_Cur ,@Shift_ID_Cur,@For_date_Cur,@Shift_Cur
	WHILE @@FETCH_STATUS = 0
		BEGIN
			--SET @day_Flag ='S'
			SET @DayIndex = 0
			WHILE @DayIndex < 7
				BEGIN 
					IF @For_date_Cur <= DATEADD(D,@DayIndex,@From_Date)
						BEGIN
							SET @SQL = 'UPDATE	#ROSTER_DATE 
										SET		col' + CAST(@DayIndex + 1 AS varchar(2)) + ' = ''S'',
												col' + CAST(@DayIndex + 1 AS varchar(2)) + '_comment = ''' + @Shift_Cur + ''',
												col' + CAST(@DayIndex + 1 AS varchar(2)) + '_shift = ''' + Cast(@Shift_ID_Cur AS VARCHAR(10)) + '''
										WHERE	Emp_id = ' + CAST(@Emp_ID_Cur  AS VARCHAR(10));									
							EXEC(@SQL);
						END
					SET @DayIndex = @DayIndex + 1;
				END	

			--IF @for_date_cur <= @from_date
			--	UPDATE	#ROSTER_DATE 
			--	SET		col1 = @day_Flag,
			--			col1_comment = @Shift_Cur,
			--			col1_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur
				
			--IF @for_date_cur <= dateadd(d,1,@from_date)
			--	UPDATE	#ROSTER_DATE 
			--	SET		col2 = @day_Flag,col2_comment = @Shift_Cur,col2_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur

			--IF @for_date_cur <= dateadd(d,2,@from_date)
			--	UPDATE	#ROSTER_DATE 
			--	SET		col3 = @day_Flag,col3_comment = @Shift_Cur,col3_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur						
		
			--IF @for_date_cur <= dateadd(d,3,@from_date)
			--	UPDATE	#ROSTER_DATE 
			--	SET		col4 = @day_Flag,col4_comment = @Shift_Cur,col4_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur
		
			--IF @for_date_cur <= dateadd(d,4,@from_date)
			--	UPDATE	#ROSTER_DATE 
			--	SET		col5 = @day_Flag,col5_comment = @Shift_Cur,col5_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur
		
			--IF @for_date_cur <= dateadd(d,5,@from_date)
			--	update	#ROSTER_DATE 
			--	SET		col6 = @day_Flag , col6_comment = @Shift_Cur, col6_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur
			
			--IF @for_date_cur <=  dateadd(d,6,@from_date)
			--	UPDATE	#ROSTER_DATE 
			--	SET		col7 = @day_Flag,col7_comment = @Shift_Cur,col7_shift = @Shift_ID_Cur
			--	WHERE	Emp_id = @Emp_ID_Cur
		
			FETCH NEXT FROM curEmpRoster INTO @Emp_ID_Cur ,@Shift_ID_Cur,@For_date_Cur,@Shift_Cur
		END 
	CLOSE curEmpRoster
	DEALLOCATE curEmpRoster
	
	-- Added by Nimesh 22 April, 2015
	-- Now, shift should be fetched FROM Rotation IF shift is not assigned for particular date to any employee in shift detail.
	-- otherwise it should take latest shift defined in Shift detail table by default.
	-- Shift Rotation should have higher priority.
	-- So, we are updating shifts IF user has defined any shift rotation for particular employee.
	
	--Taking all shift rotation detail in temp table.	
	SELECT	ER.Emp_ID,SR.ShiftID,SR.DayName AS for_Date,
			SM.Shift_St_Time + '-' + SM.Shift_End_Time AS Shift_det,ER.Effective_Date 
	INTO	#tmpRotation
	FROM	T0050_Emp_Monthly_Shift_Rotation ER WITH (NOLOCK), T0040_SHIFT_MASTER SM WITH (NOLOCK),
			(SELECT Cmp_ID,Tran_ID,DayName,ShiftID FROM 
				(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
				FROM T0050_Shift_Rotation_Master WITH (NOLOCK)) p
			UNPIVOT
				(ShiftID FOR DayName IN 
					(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
				) As unpvt
			) As SR,#Emp_Cons EC 		
	WHERE	ER.Cmp_ID=SM.Cmp_ID AND SR.ShiftID=SM.Shift_ID AND ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID 
			AND ER.Cmp_ID=@Cmp_ID AND ER.Effective_Date <= @To_Date AND ER.Emp_ID=EC.Emp_ID 
	ORDER BY ER.Effective_Date DESC
	
	--Modified by Nimesh 
	--Checking IF Rotation exist for any employee
	
	--IF EXISTS(SELECT 1 FROM #tmpRotation)
	--								Begin
	--									UPDATE	#ROSTER_DATE SET col1_comment=T.Shift_det, col1_shift = T.ShiftID
	--									FROM	(SELECT Top 1 Shift_det,Emp_ID As EmpID,ShiftID,for_Date,Effective_Date FROM #tmpRotation T
	--											WHERE	Effective_Date <='Sep 19 2016 12:00AM' AND Emp_id=T.Emp_ID AND 
	--													for_Date='Day' + Cast(DatePart(d,'Sep 19 2016 12:00AM') As VARCHAR) 
	--											ORDER BY Effective_Date Desc) T
	--									Where	EMP_ID NOT IN (SELECT DISTINCT EMP_ID FROM T0100_EMP_SHIFT_DETAIL AS ESD 
	--														WHERE (ESD.For_Date= 'Sep 19 2016 12:00AM') AND (ESD.Cmp_ID= 149) 
	--																		AND (ESD.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons))) AND
	--											EMP_ID=EmpID
	--								End
	--							Else
	--								Begin
	--									UPDATE	#ROSTER_DATE SET col1_comment=ES.Shift_St_Time + '-' + ES.Shift_End_Time, col1_shift = ES.Shift_ID
	--									FROM	#Emp_Shift ES WHERE For_Date= 'Sep 19 2016 12:00AM'
	--								End
	--			SELECT * FROM #ROSTER_DATE					
	--			return					
	
		--Taking each date FROM @FromDate to @ToDate
	DECLARE @TmpDate DATETIME;		
	DECLARE @QRY AS VARCHAR(MAX);
	SET @TmpDate = @From_Date;
	SET @QRY='';
	DECLARE @DateDiff Int;
		
	
	DECLARE @hasRotation bit
	SET @hasRotation = 0
	IF EXISTS(SELECT 1 FROM #tmpRotation)
		SET @hasRotation = 1

	While (@TmpDate <= @To_Date) 
		BEGIN		
			SET @DateDiff = DateDiff(d,@From_Date,@TmpDate);
				
			IF @hasRotation = 1
				BEGIN
					SET @QRY ='	UPDATE	#ROSTER_DATE 
								SET		col' + cast((@DateDiff + 1) as VARCHAR(2)) + '_comment=T.Shift_det, 
										col' + cast((@DateDiff + 1) as VARCHAR(2)) + '_shift = T.ShiftID
								FROM	(SELECT Top 1 Shift_det,Emp_ID As EmpID,ShiftID,for_Date,Effective_Date FROM #tmpRotation T
										WHERE	Effective_Date <='''+ cast(@TmpDate as VARCHAR(20)) +''' AND Emp_id=T.Emp_ID AND 
												for_Date=''Day'' + Cast(DatePart(d,'''+ cast(@TmpDate as VARCHAR(20)) +''') As VARCHAR) 
										ORDER BY Effective_Date Desc) T
								Where	NOT EXISTS (SELECT	DISTINCT EMP_ID 
													FROM	T0100_EMP_SHIFT_DETAIL AS ESD WITH (NOLOCK)
													WHERE	ESD.EMP_ID=T.EMP_ID AND (ESD.For_Date= ''' + cast(@TmpDate as VARCHAR(20)) +''') 
															AND EXISTS(SELECT 1 FROM #EMP_CONS EC1 ON ESD.EMP_ID=EC.EMP_ID)
															AND (ESD.Cmp_ID= ' + cast(@Cmp_ID as VARCHAR(10))+') 																			
													) AND EMP_ID=EmpID'
				END
			ELSE
				BEGIN				
					SET @QRY =' UPDATE	#ROSTER_DATE 
								SET		col'+ cast((@DateDiff + 1 ) as VARCHAR(2)) +'_comment=ES.Shift_St_Time + ''-'' + ES.Shift_End_Time, 
										col' + cast((@DateDiff + 1) as VARCHAR(2)) + '_shift = ES.Shift_ID
								FROM	#Emp_Shift ES 
								WHERE	#ROSTER_DATE.EMP_ID=ES.Emp_ID AND For_Date= ''' + cast(@TmpDate as VARCHAR(20)) +''' '
				END	
				
			EXEC(@QRY); --Changed by Sumit on 19102016						
			SET @TmpDate = DateAdd(d,1,@TmpDate);
		END	

	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/	
	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

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

	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 1, @Exec_Mode=0

	
	DECLARE @branch_id_cur NUMERIC(18,0)
	--DECLARE @Is_Cancel_Holiday TINYINT 
	--DECLARE @Is_Cancel_Holiday_WO_HO_same_day tinyint --Added By Mukti on 01032017(For Cancel Holiday When WO/HO on Same Day
 --   DECLARE @StrHoliday_Date NVARCHAR(Max)
    
	--SET @Is_Cancel_Holiday_WO_HO_same_day = 0
 --   SET @StrHoliday_Date = ''
	DECLARE curEmpRoster cursor for 
	
	SELECT	Emp_id,@From_Date,Branch_ID 
	FROM	#ROSTER_DATE

	OPEN curEmpRoster
	FETCH NEXT FROM curEmpRoster INTO @Emp_ID_Cur  ,@For_date_Cur ,@branch_id_cur 
	WHILE @@FETCH_STATUS = 0
		BEGIN 
			--DECLARE @StrWeekoff_Date NVARCHAR(Max)
			--DECLARE @varCancelWeekOff_Date NVARCHAR(Max)
			--DECLARE @Weekoff_Days NUMERIC(12,2)    
			--DECLARE @Cancel_Weekoff NUMERIC(12,2)    
			--DECLARE @Holiday_days NUMERIC(12,2)
			--DECLARE @Cancel_Holiday NUMERIC(12,2)
			DECLARE @end_date_week DATETIME
			DECLARE @WH_ForDate DATETIME		    
			DECLARE @HW_Flag  CHAR(1)  
			DECLARE @comment  VARCHAR(20)
		    
			--SET @StrWeekoff_Date = ''
			--SET @Holiday_days = 0
			--SET @Weekoff_Days = 0
			--SET @Cancel_Weekoff = 0
			--SET @varCancelWeekOff_Date = ''
			--SET @StrHoliday_Date = ''
			SET @end_date_week = dateadd(d,6,@For_date_Cur)				
				
			----Added By Mukti(start)01032017		
			--SELECT @Is_Cancel_Holiday_WO_HO_same_day=Is_Cancel_Holiday_WO_HO_same_day,@Is_Cancel_Holiday=Is_Cancel_Holiday FROM T0040_GENERAL_SETTING WHERE 
			--cmp_ID = @cmp_ID and isnull(Is_Cancel_Holiday_WO_HO_same_day,0)=1 and Branch_ID = @branch_id_cur and For_Date =(SELECT max(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <=@end_date_week and Cmp_ID = @Cmp_ID and Branch_ID = @branch_id_cur)
				
			--IF @Is_Cancel_Holiday_WO_HO_same_day = 1
			--	Begin
			--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output ,0,0,0,@varCancelWeekOff_Date output   
			--		Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,NULL,null,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date,1
			--	End
			--Else
			--	Begin
			--		Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,NULL,null,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date,1
			--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID_Cur,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output ,0,0,0,@varCancelWeekOff_Date output
			--	End
			--Added By Mukti(end)01032017
			----Comment By Ankit Unable to add Cancel WO	on 22042015
			--SET @StrWeekoff_Date = @StrWeekoff_Date + @varCancelWeekOff_Date	
			
			

			DECLARE curWH_Roster CURSOR FAST_FORWARD FOR
				--SELECT data, 'W' As col1 FROM dbo.Split(@StrWeekoff_Date,';') WHERE data <> ''
				--union all
				--SELECT data, 'H' As col1 FROM dbo.Split(@StrHoliday_Date,';') WHERE data <> '' 
			SELECT FOR_DATE, 'W' AS HW_Flag FROM #EMP_WEEKOFF
			UNION ALL
			SELECT FOR_DATE, 'H' AS HW_Flag FROM #EMP_HOLIDAY
			
			OPEN curWH_Roster
			FETCH NEXT FROM curWH_Roster INTO @WH_ForDate, @HW_Flag
			WHILE @@FETCH_STATUS = 0
				BEGIN 				
					SET @comment = CASE WHEN @HW_Flag = 'H' THEN 'Holiday' ELSE 'Day-Off' End

					SET @DayIndex = 0
					WHILE @DayIndex < 7
						BEGIN 
							IF @WH_ForDate = DATEADD(D,@DayIndex,@From_Date)
								BEGIN
									SET @SQL = 'UPDATE	#ROSTER_DATE 
												SET		col' + CAST(@DayIndex + 1 AS varchar(2)) + ' = ''' + @HW_Flag + ''',
														col' + CAST(@DayIndex + 1 AS varchar(2)) + '_comment = ''' + @comment + '''
												WHERE	Emp_id = ' + CAST(@Emp_ID_Cur  AS VARCHAR(10));
									EXEC(@SQL);
								END
							SET @DayIndex = @DayIndex + 1;
						END	
					FETCH NEXT FROM curWH_Roster into @WH_ForDate,@HW_Flag
				END 
			CLOSE curWH_Roster
			DEALLOCATE curWH_Roster					
		
			FETCH NEXT FROM curEmpRoster into @Emp_ID_Cur  ,@For_date_Cur ,@branch_id_cur 
		END 
	CLOSE curEmpRoster
	DEALLOCATE curEmpRoster
		
					
	IF @Print = 0
		SELECT * FROM #ROSTER_DATE
	ELSE
		BEGIN
			SELECT 'Code','Name',  convert(NVARCHAR,@From_Date,106) + ' ' + datename(dw,@From_Date) ,convert(NVARCHAR,dateadd(dd,1,@From_Date),106) + ' ' + datename(dw,dateadd(dd,1,@From_Date)) ,  convert(NVARCHAR,dateadd(dd,2,@From_Date),106) + ' ' + datename(dw,dateadd(dd,2,@From_Date)) ,  convert(NVARCHAR,dateadd(dd,3,@From_Date),106) + ' ' + datename(dw,dateadd(dd,3,@From_Date))  ,  convert(NVARCHAR,dateadd(dd,4,@From_Date),106) + ' ' + datename(dw,dateadd(dd,4,@From_Date)) ,  convert(NVARCHAR,dateadd(dd,5,@From_Date),106) + ' ' + datename(dw,dateadd(dd,5,@From_Date)) ,  convert(NVARCHAR,dateadd(dd,6,@From_Date),106) + ' ' + datename(dw,dateadd(dd,6,@From_Date)) 
			SELECT Alpha_emp_code , Emp_Name_full , isnull(col1_comment,'-') ,	isnull(col2_comment,'-') ,	isnull(col3_comment,'-') ,	isnull(col4_comment,'-') ,isnull(col5_comment,'') , isnull(col6_comment,'-') ,isnull(col7_comment,'-'),Branch_ID , '0' as Total , @Branch_Name as branch_name, convert(NVARCHAR,@From_Date,103) + ' to ' + convert(NVARCHAR,@To_Date,103) as Period, Emp_id FROM #ROSTER_DATE
		END
RETURN




