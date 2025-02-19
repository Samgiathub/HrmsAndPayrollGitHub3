
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Roster_Shift_Monthly]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		varchar(max) = ''
	,@Cat_ID		varchar(max) = ''
	,@Grd_ID		varchar(max) = ''
	,@Type_ID		varchar(max) = ''
	,@Dept_ID		varchar(max) = ''
	,@Desig_ID		varchar(max) = ''
	,@Emp_ID		NUMERIC = 0
	,@Constraint	VARCHAR(MAX) = ''
	,@Vertical_ID   varchar(max) = ''
	,@SubVertical_ID varchar(max) = ''
	,@SubBranch_ID   varchar(max) = ''
	,@Segment_ID     varchar(max) = ''
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
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
			
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_ID,@SubVertical_ID,@SubBranch_ID,0,0,0,'0',0,0
	declare @Day_count numeric(18,0)= 0
	
	set @Day_count = DATEDIFF(day,@From_Date,@To_Date) 
	set @Day_count = @Day_count + 1
	
	Declare @Temp_Date datetime
	set @Temp_Date = @From_Date
	
	CREATE TABLE #R_DATES
	(
		For_date datetime
	)
	
	while @Temp_Date <= @To_Date
	begin
		insert INTO #R_DATES VALUES (@Temp_Date)
		set @Temp_Date = DATEADD(dd,1,@Temp_Date)
	end
	
	
	
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
		Desig_ID		NUMERIC,
		
		col1 Varchar(10),
		col1_shift Numeric,
		col1_comment Varchar(200),
		col1_color Varchar(16),
		col1_weekoff  Varchar(8) Default('False'),

		col2 Varchar(10),
		col2_shift Numeric,
		col2_comment Varchar(200),
		col2_color Varchar(16),
		col2_weekoff  Varchar(8) Default('False'),

		col3 Varchar(10),
		col3_shift Numeric,
		col3_comment Varchar(200),
		col3_color Varchar(16),
		col3_weekoff  Varchar(8) Default('False'),

		col4 Varchar(10),
		col4_shift Numeric,
		col4_comment Varchar(200),
		col4_color Varchar(16),
		col4_weekoff  Varchar(8) Default('False'),

		col5 Varchar(10),
		col5_shift Numeric,
		col5_comment Varchar(200),
		col5_color Varchar(16),
		col5_weekoff  Varchar(8) Default('False'),

		col6 Varchar(10),
		col6_shift Numeric,
		col6_comment Varchar(200),
		col6_color Varchar(16),
		col6_weekoff  Varchar(8) Default('False'),

		col7 Varchar(10),
		col7_shift Numeric,
		col7_comment Varchar(200),
		col7_color Varchar(16),
		col7_weekoff  Varchar(8) Default('False'),

		col8 Varchar(10),
		col8_shift Numeric,
		col8_comment Varchar(200),
		col8_color Varchar(16),
		col8_weekoff  Varchar(8) Default('False'),

		col9 Varchar(10),
		col9_shift Numeric,
		col9_comment Varchar(200),
		col9_color Varchar(16),
		col9_weekoff  Varchar(8) Default('False'),

		col10 Varchar(10),
		col10_shift Numeric,
		col10_comment Varchar(200),
		col10_color Varchar(16),
		col10_weekoff  Varchar(8) Default('False'),

		col11 Varchar(10),
		col11_shift Numeric,
		col11_comment Varchar(200),
		col11_color Varchar(16),
		col11_weekoff  Varchar(8) Default('False'),

		col12 Varchar(10),
		col12_shift Numeric,
		col12_comment Varchar(200),
		col12_color Varchar(16),
		col12_weekoff  Varchar(8) Default('False'),

		col13 Varchar(10),
		col13_shift Numeric,
		col13_comment Varchar(200),
		col13_color Varchar(16),
		col13_weekoff  Varchar(8) Default('False'),

		col14 Varchar(10),
		col14_shift Numeric,
		col14_comment Varchar(200),
		col14_color Varchar(16),
		col14_weekoff  Varchar(8) Default('False'),

		col15 Varchar(10),
		col15_shift Numeric,
		col15_comment Varchar(200),
		col15_color Varchar(16),
		col15_weekoff  Varchar(8) Default('False'),

		col16 Varchar(10),
		col16_shift Numeric,
		col16_comment Varchar(200),
		col16_color Varchar(16),
		col16_weekoff  Varchar(8) Default('False'),

		col17 Varchar(10),
		col17_shift Numeric,
		col17_comment Varchar(200),
		col17_color Varchar(16),
		col17_weekoff  Varchar(8) Default('False'),

		col18 Varchar(10),
		col18_shift Numeric,
		col18_comment Varchar(200),
		col18_color Varchar(16),
		col18_weekoff  Varchar(8) Default('False'),

		col19 Varchar(10),
		col19_shift Numeric,
		col19_comment Varchar(200),
		col19_color Varchar(16),
		col19_weekoff  Varchar(8) Default('False'),

		col20 Varchar(10),
		col20_shift Numeric,
		col20_comment Varchar(200),
		col20_color Varchar(16),
		col20_weekoff  Varchar(8) Default('False'),

		col21 Varchar(10),
		col21_shift Numeric,
		col21_comment Varchar(200),
		col21_color Varchar(16),
		col21_weekoff  Varchar(8) Default('False'),

		col22 Varchar(10),
		col22_shift Numeric,
		col22_comment Varchar(200),
		col22_color Varchar(16),
		col22_weekoff  Varchar(8) Default('False'),

		col23 Varchar(10),
		col23_shift Numeric,
		col23_comment Varchar(200),
		col23_color Varchar(16),
		col23_weekoff  Varchar(8) Default('False'),

		col24 Varchar(10),
		col24_shift Numeric,
		col24_comment Varchar(200),
		col24_color Varchar(16),
		col24_weekoff  Varchar(8) Default('False'),

		col25 Varchar(10),
		col25_shift Numeric,
		col25_comment Varchar(200),
		col25_color Varchar(16),
		col25_weekoff  Varchar(8) Default('False'),

		col26 Varchar(10),
		col26_shift Numeric,
		col26_comment Varchar(200),
		col26_color Varchar(16),
		col26_weekoff  Varchar(8) Default('False'),

		col27 Varchar(10),
		col27_shift Numeric,
		col27_comment Varchar(200),
		col27_color Varchar(16),
		col27_weekoff  Varchar(8) Default('False'),

		col28 Varchar(10),
		col28_shift Numeric,
		col28_comment Varchar(200),
		col28_color Varchar(16),
		col28_weekoff  Varchar(8) Default('False'),

		col29 Varchar(10),
		col29_shift Numeric,
		col29_comment Varchar(200),
		col29_color Varchar(16),
		col29_weekoff  Varchar(8) Default('False'),

		col30 Varchar(10),
		col30_shift Numeric,
		col30_comment Varchar(200),
		col30_color Varchar(16),
		col30_weekoff  Varchar(8) Default('False'),

		col31 Varchar(10),
		col31_shift Numeric,
		col31_comment Varchar(200),
		col31_color Varchar(16),
		col31_weekoff  Varchar(8) Default('False')
	)

	CREATE UNIQUE CLUSTERED INDEX CLIX_ROSTER_DATE ON #ROSTER_DATE (EMP_ID)
		
	INSERT	INTO #ROSTER_DATE (Emp_id,Cmp_id,Alpha_emp_code,Emp_Name_full,Branch_ID,Cat_ID,Grd_ID,Type_ID,Dept_ID,Desig_ID)
	SELECT	I.Emp_ID ,@Cmp_ID, Alpha_Emp_Code , Emp_Full_Name as Emp_Name_full , I.Branch_ID , I.Cat_ID , I.Grd_ID , I.Type_ID , I.Dept_ID , I.Desig_Id
	FROM	T0080_EMP_MASTER E WITH (NOLOCK) 
			INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID
			INNER JOIN T0010_Company_Master CM WITH (NOLOCK) ON Cm.Cmp_Id =E.Cmp_ID 			
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Emp_ID=I.Emp_ID AND I.Increment_ID=EC.Increment_ID
	WHERE	E.Cmp_ID = @Cmp_Id	
	ORDER BY E.Emp_Code asc
	
	--DECLARE @CNT NUMERIC = 0
	--DECLARE @COLUMN VARCHAR(100)
	--DECLARE @COLUMN_SHIFT VARCHAR(100)
	--DECLARE @COLUMN_COMMENT VARCHAR(100)
	--DECLARE @COLUMN_COLOR VARCHAR(100)
	--DECLARE @COLUMN_WEEKOFF VARCHAR(100)
	--DECLARE @QUERY VARCHAR(MAX)
	
	
	--WHILE @CNT < @Day_count
	--begin
	--		set @Cnt = @Cnt+1
	--		set @Column = 'col' + cast(@Cnt as varchar) +' '
	--		set @Column_Shift = 'col' + cast(@Cnt as varchar) +'_shift '
	--		set @Column_Comment = 'col' + cast(@Cnt as varchar) +'_comment '
	--		set @Column_color = 'col'+ CAST(@CNT AS varchar) + '_color'
	--		set @COLUMN_WEEKOFF = 'col'+CAST(@CNT AS varchar) +'_weekoff'
	--		set @query= 'Alter table #ROSTER_DATE add ' + @Column +' VARCHAR(200) default '''','+ @Column_Shift + ' NUMERIC(18,0) default 0,'+ @Column_Comment + ' VARCHAR(200) default ''-'','+@Column_color + ' VARCHAR(50) default ''#EFF8E8'','+ @COLUMN_WEEKOFF + ' varchar(10)';
			
	--		exec (@query)
			
	--end		
	
	
	
	DECLARE @Emp_ID_Cur NUMERIC(18,0)
	DECLARE @Shift_ID_Cur NUMERIC(18,0)
	DECLARE @For_date_Cur DATETIME
	DECLARE @Shift_Cur NVARCHAR(200)
		
		
	--CREATE TABLE #Emp_Shift
	--(
	--	Emp_Id NUMERIC(18,0),
	--	For_date DATETIME,
	--	Shift_ID NUMERIC(18,0),
	--	Shift_St_Time VARCHAR(10),
	--	Shift_End_Time VARCHAR(10)
	--)
	--IF (@Constraint = '' OR @Constraint = NULL)
	--	SET @Constraint = @Emp_ID
		
	--Exec P_GET_EMP_SHIFT_DETAIL @Cmp_ID=@Cmp_ID,@from_Date=@From_Date,@To_Date=@To_Date,@Constraint=@Constraint
	
	
	--UPDATE	ES 
	--SET		SHIFT_ST_TIME=  CASE WHEN (SM.Is_Half_Day=1 and SM.Week_Day = DATENAME(WEEKDAY, For_date)) THEN 
	--								ISNULL(SM.Half_St_Time,sm.Shift_St_Time) 
	--							Else 
	--								SM.Shift_St_Time
	--						End,								   
	--		SHIFT_END_TIME=  CASE WHEN (SM.Is_Half_Day=1 and SM.Week_Day= DATENAME(WEEKDAY, For_date)) THEN 
	--								ISNULL(SM.Half_End_Time,sm.Shift_End_Time) 
	--							Else
	--								SM.Shift_End_Time 
	--						END
	--FROM	#EMP_SHIFT ES 
	--		INNER JOIN T0040_SHIFT_MASTER SM ON ES.SHIFT_ID=SM.SHIFT_ID
	--WHERE	SM.CMP_ID=@CMP_ID 
	----Ended by Sumit on 18102016----------------------------------------------------------------------------------
	
	
	
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

	DECLARE @SQL NVARCHAR(MAX)
	declare @W_SQL varchar(max)
	declare @H_SQL varchar(max)
	DECLARE @DayIndex INT
	Declare @Weekoff_Date datetime
	Declare @Holiday_Date datetime
	
	DECLARE @day_Flag VARCHAR(5)	

	SELECT	E.Emp_ID,SM.Shift_ID,D.For_Date,
			SM.Shift_Name + ' ( '+ SM.Shift_St_Time + '-' + SM.Shift_End_Time + ')' as Shift_Name, 
			isnull(W.For_Date,'') As Weekoff_Date,ISNULL(H.FOR_DATE,'') As Holiday_Date, CASE WHEN W.W_Day >0 THEN 'W' WHEN H.H_DAY > 0 THEN 'H' ELSE 'S' END AS [STATUS]
	INTO	#EMP_HW_SHIFT
	FROM	#Emp_Cons E 
			CROSS 	JOIN #R_DATES D
			Inner join T0040_Shift_Master SM WITH (NOLOCK) ON SM.Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(SM.Cmp_ID,E.Emp_ID,D.For_date)
			LEFT OUTER JOIN #EMP_WEEKOFF W ON W.Emp_ID = E.Emp_ID AND D.For_date=W.For_Date AND W.W_Day > 0 
			LEFT OUTER JOIN #EMP_HOLIDAY H ON H.EMP_ID = E.Emp_ID AND D.For_date=H.For_Date AND H.H_DAY > 0
	WHERE	SM.Cmp_ID = @Cmp_Id
	ORDER BY E.Emp_ID,D.For_date

	
	DECLARE @ShiftColor Varchar(7)
	DECLARE @WOColor Varchar(7)
	DECLARE @HOColor Varchar(7)
	
	SET @ShiftColor = '#EFF8E8'
	SET @WOColor = '#F7DBDB'
	SET @HOColor = '#90EE90'

	DECLARE @INDEX INT

	DECLARE @FOR_DATE DATETIME
	SET @FOR_DATE = @From_Date
	SET @INDEX = 1
	WHILE @FOR_DATE <= @To_Date
		BEGIN
			SET @SQL = 'UPDATE	RD
						SET		col#Index = WS.[STATUS],
								col#Index_comment = WS.Shift_Name,
								col#Index_shift = WS.Shift_ID,
								col#Index_color = CASE WS.[STATUS] WHEN ''W'' THEN @WOColor When ''H'' Then @HOColor Else @ShiftColor End,
								col#Index_weekoff = CASE WS.[STATUS] WHEN ''W'' THEN ''True'' Else ''False'' End
						FROM	#ROSTER_DATE RD
								INNER JOIN #EMP_HW_SHIFT WS ON RD.Emp_id=WS.Emp_ID
						WHERE	WS.For_date=@FOR_DATE'
			SET @SQL = REPLACE(@SQL, '#Index', @INDEX)
			EXEC sp_executesql @SQL, N'@FOR_DATE DATETIME,@WOColor Char(7), @HOColor Char(7), @ShiftColor Char(7)', @FOR_DATE, @WOColor, @HOColor, @ShiftColor
						
			SET @INDEX = @INDEX + 1 
			SET @FOR_DATE = DATEADD(D, 1,@FOR_DATE)
		END
	
	/*
	PRINT 'START'
	DECLARE curEmpRoster cursor for	
	SELECT	E.Emp_ID,SM.Shift_ID,D.For_date,
			SM.Shift_Name + ' ( '+ SM.Shift_St_Time + '-' + SM.Shift_End_Time + ')' as Shift_det, 
			isnull(W.For_Date,'') As Weekoff_Date,ISNULL(H.FOR_DATE,'') As Holiday_Date
	FROM	#Emp_Cons E 
			CROSS 	JOIN #R_DATES D
			Inner join T0040_Shift_Master SM ON SM.Shift_ID = dbo.fn_get_Shift_From_Monthly_Rotation(SM.Cmp_ID,E.Emp_ID,D.For_date)
			left JOIN #EMP_WEEKOFF W ON W.Emp_ID = E.Emp_ID AND D.For_date=W.For_Date
			left JOIN #EMP_HOLIDAY H ON H.EMP_ID = E.Emp_ID AND D.For_date=H.For_Date
	where SM.Cmp_ID = @Cmp_Id
	order BY E.Emp_ID,D.For_date
	OPEN curEmpRoster

	FETCH NEXT FROM curEmpRoster INTO @Emp_ID_Cur ,@Shift_ID_Cur,@For_date_Cur,@Shift_Cur,@Weekoff_Date,@Holiday_Date
	WHILE @@FETCH_STATUS = 0
		BEGIN
			--SET @day_Flag ='S'
			
			SET @DayIndex = 0
			WHILE @DayIndex < @Day_count
				BEGIN 
					IF @For_date_Cur <= DATEADD(D,@DayIndex,@From_Date)
						BEGIN
							SET @SQL = 'UPDATE	#ROSTER_DATE 
										SET		col' + CAST(@DayIndex + 1 AS varchar(2)) + ' = ''S'',
												col' + CAST(@DayIndex + 1 AS varchar(2)) + '_comment= ''' + @Shift_Cur + ''',
												col' + CAST(@DayIndex + 1 AS varchar(2)) + '_shift= ''' + Cast(@Shift_ID_Cur AS VARCHAR(10)) + ''',
												col' + CAST(@DayIndex + 1 AS varchar(2)) + '_color= ''' + '#EFF8E8' + ''',
												col' + CAST(@DayIndex + 1 AS varchar(2)) + '_weekoff= ''false''
										WHERE	Emp_id = ' + CAST(@Emp_ID_Cur  AS VARCHAR(10));									
							EXEC(@SQL);
							
							
							IF @Weekoff_Date = @For_date_Cur 
								begin
									PRINT @For_date_Cur
									SET @W_SQL = 'UPDATE	#ROSTER_DATE 
													SET		col' + CAST(@DayIndex + 1 AS varchar(2)) + ' = ''W'',
															--col' + CAST(@DayIndex + 1 AS varchar(2)) + '_comment = ''Day-Off'',
															col' + CAST(@DayIndex + 1 AS varchar(2)) + '_color = ''#F7DBDB'',
															col' + CAST(@DayIndex + 1 AS varchar(2)) + '_weekoff = ''true''
													WHERE	Emp_id = ' + CAST(@Emp_ID_Cur  AS VARCHAR(10)) 
															
									EXEC(@W_SQL);
								end
							
							IF @Holiday_Date = @For_date_Cur
							begin
								SET @H_SQL = 'UPDATE	#ROSTER_DATE 
												SET		col' + CAST(@DayIndex + 1 AS varchar(2)) + ' = ''H'',
														--col' + CAST(@DayIndex + 1 AS varchar(2)) + '_comment = ''Holiday'',
														col' + CAST(@DayIndex + 1 AS varchar(2)) + '_color = ''#90EE90'',
														col' + CAST(@DayIndex + 1 AS varchar(2)) + '_weekoff = ''false''
												WHERE	Emp_id = ' + CAST(@Emp_ID_Cur  AS VARCHAR(10)) 
														
								EXEC(@H_SQL);
							end
							
						END
					SET @DayIndex = @DayIndex + 1;
				END	
			FETCH NEXT FROM curEmpRoster INTO @Emp_ID_Cur ,@Shift_ID_Cur,@For_date_Cur,@Shift_Cur,@Weekoff_Date,@Holiday_Date
		END 
	CLOSE curEmpRoster
	DEALLOCATE curEmpRoster
	
	*/
	SELECT * FROM #ROSTER_DATE 
	RETURN
	
	-- Added by Nimesh 22 April, 2015
	-- Now, shift should be fetched FROM Rotation IF shift is not assigned for particular date to any employee in shift detail.
	-- otherwise it should take latest shift defined in Shift detail table by default.
	-- Shift Rotation should have higher priority.
	-- So, we are updating shifts IF user has defined any shift rotation for particular employee.
	
	--Taking all shift rotation detail in temp table.	
	--SELECT	ER.Emp_ID,SR.ShiftID,SR.DayName AS for_Date,
	--		SM.Shift_Name + '( '+ SM.Shift_St_Time + '-' + SM.Shift_End_Time + ')' AS Shift_det,ER.Effective_Date 
	--INTO	#tmpRotation
	--FROM	T0050_Emp_Monthly_Shift_Rotation ER, T0040_SHIFT_MASTER SM,
	--		(SELECT Cmp_ID,Tran_ID,DayName,ShiftID FROM 
	--			(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
	--			FROM T0050_Shift_Rotation_Master) p
	--		UNPIVOT
	--			(ShiftID FOR DayName IN 
	--				(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
	--			) As unpvt
	--		) As SR,#Emp_Cons EC 		
	--WHERE	ER.Cmp_ID=SM.Cmp_ID AND SR.ShiftID=SM.Shift_ID AND ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID 
	--		AND ER.Cmp_ID=@Cmp_ID AND ER.Effective_Date <= @To_Date AND ER.Emp_ID=EC.Emp_ID 
	--ORDER BY ER.Effective_Date DESC
	
	
	--DECLARE @TmpDate DATETIME;		
	--DECLARE @QRY AS VARCHAR(MAX);
	--SET @TmpDate = @From_Date;
	--SET @QRY='';
	--DECLARE @DateDiff Int;
		
	
	
	--DECLARE @hasRotation bit
	--SET @hasRotation = 0
	--IF EXISTS(SELECT 1 FROM #tmpRotation)
	--	SET @hasRotation = 1

	--While (@TmpDate <= @To_Date) 
	--	BEGIN		
	--		SET @DateDiff = DateDiff(d,@From_Date,@TmpDate);
				
	--		IF @hasRotation = 1
	--			BEGIN
	--				SET @QRY ='	UPDATE	#ROSTER_DATE 
	--							SET		col' + cast((@DateDiff + 1) as VARCHAR(2)) + '_comment =T.Shift_det, 
	--									col' + cast((@DateDiff + 1) as VARCHAR(2)) + '_shift = T.ShiftID
	--							FROM	(SELECT Top 1 Shift_det,Emp_ID As EmpID,ShiftID,for_Date,Effective_Date FROM #tmpRotation T
	--									WHERE	Effective_Date <='''+ cast(@TmpDate as VARCHAR(20)) +''' AND Emp_id=T.Emp_ID AND 
	--											for_Date=''Day'' + Cast(DatePart(d,'''+ cast(@TmpDate as VARCHAR(20)) +''') As VARCHAR) 
	--									ORDER BY Effective_Date Desc) T
	--							Where	NOT EXISTS (SELECT	DISTINCT EMP_ID 
	--												FROM	T0100_EMP_SHIFT_DETAIL AS ESD 
	--												WHERE	ESD.EMP_ID=T.EMP_ID AND (ESD.For_Date= ''' + cast(@TmpDate as VARCHAR(20)) +''') 
	--														AND EXISTS(SELECT 1 FROM #EMP_CONS EC1 ON ESD.EMP_ID=EC.EMP_ID)
	--														AND (ESD.Cmp_ID= ' + cast(@Cmp_ID as VARCHAR(10))+') 																			
	--												) AND EMP_ID=EmpID'
	--			END
	--		ELSE
	--			BEGIN				
	--				SET @QRY =' UPDATE	#ROSTER_DATE 
	--							SET		col'+ cast((@DateDiff + 1 ) as VARCHAR(2)) +'_comment =SM.SHIFT_NAME +'' (''+ ES.Shift_St_Time + ''-'' + ES.Shift_End_Time + '')'', 
	--									col' + cast((@DateDiff + 1) as VARCHAR(2)) + '_shift = ES.Shift_ID
	--							FROM	#Emp_Shift ES INNER JOIN T0040_SHIFT_MASTER SM ON SM.SHIFT_ID = ES.SHIFT_ID
	--							WHERE	#ROSTER_DATE.EMP_ID=ES.Emp_ID AND For_Date= ''' + cast(@TmpDate as VARCHAR(20)) +''' '
	--			END	
				
	--		EXEC(@QRY); --Changed by Sumit on 19102016						
	--		SET @TmpDate = DateAdd(d,1,@TmpDate);
	--	END	
	
	
	--DECLARE @branch_id_cur NUMERIC(18,0)

	--DECLARE curEmpRoster cursor for 
	
	--SELECT	Emp_id,@From_Date,Branch_ID 
	--FROM	#ROSTER_DATE

	--OPEN curEmpRoster
	--FETCH NEXT FROM curEmpRoster INTO @Emp_ID_Cur  ,@For_date_Cur ,@branch_id_cur 
	--WHILE @@FETCH_STATUS = 0
	--	BEGIN 
		
	--		--DECLARE @end_date_week DATETIME
	--		DECLARE @WH_ForDate DATETIME		    
	--		DECLARE @HW_Flag  CHAR(1)  
	--		DECLARE @comment  VARCHAR(20)
	--	    DECLARE @COLOR VARCHAR(50)
	--	    DECLARE @WEEKOFF varchar(5)
			
	--		--SET @end_date_week = dateadd(d,6,@For_date_Cur)				
				
	--		DECLARE curWH_Roster CURSOR FAST_FORWARD FOR
			
	--		SELECT FOR_DATE, 'W' AS HW_Flag FROM #EMP_WEEKOFF where Emp_ID = @Emp_ID_Cur 
	--		UNION ALL
	--		SELECT FOR_DATE, 'H' AS HW_Flag FROM #EMP_HOLIDAY where EMP_ID = @Emp_ID_Cur
			
	--		OPEN curWH_Roster
	--		FETCH NEXT FROM curWH_Roster INTO @WH_ForDate, @HW_Flag
	--		WHILE @@FETCH_STATUS = 0
	--			BEGIN 				
	--				SET @comment = CASE WHEN @HW_Flag = 'H' THEN 'Holiday' ELSE 'Day-Off' End
	--				Set @COLOR = CASE WHEN @HW_Flag = 'W' THEN '#F7DBDB'
	--								  WHEN @HW_Flag = 'H' THEN '#90EE90'
	--								  ELSE '#EFF8E8' END
	--				set @WEEKOFF = CASE When @HW_Flag = 'W' THEN 'true' ELSE 'false' END
								  		
	--				SET @DayIndex = 0
	--				WHILE @DayIndex < @Day_count
	--					BEGIN 
	--						IF @WH_ForDate = DATEADD(D,@DayIndex,@From_Date)
	--							BEGIN
									
	--								SET @SQL = 'UPDATE	#ROSTER_DATE 
	--											SET		col' + CAST(@DayIndex + 1 AS varchar(2)) + ' = ''' + @HW_Flag + ''',
	--													col' + CAST(@DayIndex + 1 AS varchar(2)) + '_comment = ''' + @comment + ''',
	--													col' + CAST(@DayIndex + 1 AS varchar(2)) + '_color = ''' + @COLOR + ''',
	--													col' + CAST(@DayIndex + 1 AS varchar(2)) + '_weekoff = ''' + @WEEKOFF + '''
	--											WHERE	Emp_id = ' + CAST(@Emp_ID_Cur  AS VARCHAR(10));
	--								EXEC(@SQL);
	--							END
	--						SET @DayIndex = @DayIndex + 1;
	--					END	
	--				FETCH NEXT FROM curWH_Roster into @WH_ForDate,@HW_Flag
	--			END 
	--		CLOSE curWH_Roster
	--		DEALLOCATE curWH_Roster					
		
	--		FETCH NEXT FROM curEmpRoster into @Emp_ID_Cur  ,@For_date_Cur ,@branch_id_cur 
	--	END 
	--CLOSE curEmpRoster
	--DEALLOCATE curEmpRoster
	
	--select * from #ROSTER_DATE
END
