
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0100_EMP_SHIFT_DETAIL_GET]
	 @Cmp_ID 		NUMERIC
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		NUMERIC
	,@Cat_ID 		NUMERIC 
	,@Grd_ID 		NUMERIC
	,@Type_ID 		NUMERIC
	,@Dept_ID 		NUMERIC
	,@Desig_ID 		NUMERIC
	,@Emp_ID 		NUMERIC
	,@constraint 	VARCHAR(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #Emp_shift1 
	(
		Emp_ID		NUMERIC ,
		Shift_ID	NUMERIC ,
		Day1		VARCHAR(10), 
		Day2		VARCHAR(10),
		Day3		VARCHAR(10),
		Day4		VARCHAR(10) ,
		Day5		VARCHAR(10) ,
		Day6		VARCHAR(10) ,
		Day7		VARCHAR(10) ,
		Day8		VARCHAR(10) ,
		Day9		VARCHAR(10) ,
		Day10		VARCHAR(10) ,
		Day11		VARCHAR(10) ,
		Day12		VARCHAR(10) ,
		Day13		VARCHAR(10) ,
		Day14		VARCHAR(10) ,
		Day15		VARCHAR(10) ,
		Day16		VARCHAR(10) ,
		Day17		VARCHAR(10) ,
		Day18		VARCHAR(10) ,
		Day19		VARCHAR(10) ,
		Day20		VARCHAR(10) ,
		Day21		VARCHAR(10) ,
		Day22		VARCHAR(10) ,
		Day23		VARCHAR(10) ,
		Day24		VARCHAR(10) ,
		Day25		VARCHAR(10) ,
		Day26		VARCHAR(10) ,
		Day27		VARCHAR(10) ,
		Day28		VARCHAR(10) ,
		Day29		VARCHAR(10) ,
		Day30		VARCHAR(10) ,
		Day31		VARCHAR(10) ,
		Cmp_ID		NUMERIC 
	)

	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0  
		SET @Cat_ID = NULL

	IF @Grd_ID = 0  
		SET @Grd_ID = NULL

	IF @Type_ID = 0  
		SET @Type_ID = NULL

	IF @Dept_ID = 0  
		SET @Dept_ID = NULL

	IF @Desig_ID = 0  
		SET @Desig_ID = NULL

	IF @Emp_ID = 0  
		SET @Emp_ID = NULL


	DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_shift1(Emp_ID,cmp_ID)
			SELECT  CAST(DATA  AS NUMERIC),@Cmp_ID from dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
			Insert Into #Emp_shift1(Emp_ID,cmp_ID)

			SELECT I.Emp_Id ,Cmp_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( SELECT max(Increment_effective_Date) AS For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and IsNULL(Cat_ID,0) = IsNULL(@Cat_ID ,IsNULL(Cat_ID,0))
			and Branch_ID = isNULL(@Branch_ID ,Branch_ID)
			and Grd_ID = isNULL(@Grd_ID ,Grd_ID)
			and isNULL(Dept_ID,0) = isNULL(@Dept_ID ,isNULL(Dept_ID,0))
			and IsNULL(Type_ID,0) = isNULL(@Type_ID ,IsNULL(Type_ID,0))
			and IsNULL(Desig_ID,0) = isNULL(@Desig_ID ,IsNULL(Desig_ID,0))
			and I.Emp_ID = isNULL(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( SELECT Emp_Id from
				(SELECT emp_id, cmp_ID, join_Date, isNULL(left_Date, @To_date) AS left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is NULL and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		END

		-- Rohit
	CREATE TABLE #Emp_WeekOFf_Detail
	(        
		Emp_ID NUMERIC        ,
		StrWeekoff_Holiday VARCHAR(max),
		StrWeekoff VARCHAR(max), --Hardik 07/09/2012    
		StrHoliday VARCHAR(max) --Hardik 07/09/2012    
	)  
 

	DECLARE @Is_Cancel_Holiday_WO_HO_same_day NUMERIC(5,0)
	SET @Is_Cancel_Holiday_WO_HO_same_day = 0

	insert into #Emp_WeekOFf_Detail 
	SELECT Emp_ID,'','','' from #Emp_shift1 --Hardik 07/09/2012

	DECLARE @Emp_Week_Detail NUMERIC(18,0)
	DECLARE @strweekoff VARCHAR(max)
	DECLARE @Is_Negative_Ot Int ---For negative yes or no take its value from general setting

	--DECLARE curEmp_weekoff_Detail CURSOR FAST_FORWARD FOR
	--SELECT  Emp_ID 
	--from	#Emp_shift1 
	--ORDER BY Emp_ID

	--OPEN curEmp_weekoff_Detail                      
	--FETCH NEXT FROM curEmp_weekoff_Detail INTO @Emp_Week_Detail
	--WHILE @@FETCH_STATUS = 0                    
	--	BEGIN                    

	--		--DECLARE @Is_Cancel_Weekoff  NUMERIC(1,0) 
	--		--DECLARE @Weekoff_Days   NUMERIC(12,1)    
	--		--DECLARE @Cancel_Weekoff   NUMERIC(12,1)  
	--		--DECLARE @Week_oF_Branch NUMERIC(18,0)
	--		DECLARE @tras_week_ot tinyint
	--		DECLARE @Auto_OT tinyint
	--		DECLARE @OT_Present tinyint
	--		DECLARE @Is_Compoff NUMERIC
	--		DECLARE @Is_WD NUMERIC
	--		DECLARE @Is_WOHO NUMERIC
    
	--		--DECLARE @Is_Cancel_Holiday Int
	--		--DECLARE @StrHoliday_Date VARCHAR(Max)
	--		--DECLARE @Holiday_days NUMERIC(18,2)
	--		--DECLARE @Cancel_Holiday NUMERIC(18,2)

	--		--DECLARE @StrWeekoff_Date VARCHAR(max)
    
    
 
	--		----SELECT @Week_oF_Branch=Branch_ID  from dbo.t0095_increment where Increment_id in (SELECT Max(Increment_id) from dbo.t0095_increment where emp_id=@Emp_Week_Detail AND Increment_Effective_Date <= @To_Date)
	
	--		---- Added by nilesh Patel ON 01122015 --Start
	--		--SELECT @Is_Cancel_Holiday_WO_HO_same_day = Is_Cancel_Holiday_WO_HO_same_day 
	--		--from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Week_oF_Branch    
	--		--and For_Date = ( SELECT max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Week_oF_Branch and Cmp_ID = @Cmp_ID)
	--		---- Added by nilesh Patel ON 01122015 --END
			
  
	--		--SET @StrWeekoff_Date=''
	--		--SET @Weekoff_Days=0
	--		--SET @Cancel_Weekoff=0
			
	--		----Hardik 07/09/2012
	--		--SET @StrHoliday_Date =''
	--		--SET @Holiday_days = 0
	--		--SET @Cancel_Holiday =0
			
	--		--Added by nilesh Patel ON 01122015 -Start
			
	--		--IF @Is_Cancel_Holiday_WO_HO_same_day = 1
	--		--	BEGIN
	--		--		Exec SP_EMP_WEEKOFF_DATE_GET	  @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output, 0,0,0,''
	--		--		Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
	--		--	END
	--		--ELSE
	--		--	BEGIN
	--		--		Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,@Branch_ID,@StrWeekoff_Date
	--		--		Exec SP_EMP_WEEKOFF_DATE_GET	  @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,9,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output, 0,0,0,''
	--		--	END 
			
	--		--Added by nilesh Patel ON 01122015 -END
			
	--		--Exec dbo.SP_EMP_WEEKOFF_DATE_GET1 @Emp_Week_Detail,@Cmp_ID,@From_Date,@To_Date,NULL,NULL,0,'',@StrWeekoff_Date output,@Weekoff_Days output ,@Cancel_Weekoff output,@constraint=''    -- Comment by nilesh patel ON 01122015
			
	--		Update 	@Emp_WeekOFf_Detail 
	--		SET StrWeekoff_Holiday=@StrWeekoff_Date + ';' + @StrHoliday_Date , --Hardik 07/09/2012
	--			StrHoliday = @StrHoliday_Date,StrWeekoff = @StrWeekoff_Date  --Hardik 07/09/2012
	--		where Emp_ID=@Emp_Week_Detail --Hardik 07/09/2012

	--		FETCH NEXT FROM curEmp_weekoff_Detail INTO @Emp_Week_Detail
	--	END                    
	--CLOSE	curEmp_weekoff_Detail                    
	--DEALLOCATE curEmp_weekoff_Detail   
 
	--SELECT * into #Emp_WeekOFf_Detail from @Emp_WeekOFf_Detail
	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;

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
		BEGIN
			DECLARE @All_Weekoff BIT
			SET @All_Weekoff = 0;

			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = @All_Weekoff, @Exec_Mode=0		
		END 


	--Add by Nimesh 28 April, 2015
	--This sp retrieves the Shift Rotation AS per given employee id and effective date.
	--it will fetch all employee's shift rotation detail IF employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID NUMERIC(18,0), R_DayName VARCHAR(25), R_ShiftID NUMERIC(18,0), R_Effective_Date DATETIME);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint



	DECLARE @For_Date	DATETIME
	DECLARE @Sql_Query	NVARCHAR(4000)
	DECLARE @Sql_Query1 NVARCHAR(4000)
	DECLARE @Sql_Query2 NVARCHAR(4000)
	SET @For_Date = @From_Date 
	WHILE @For_Date <=@To_Date
		BEGIN						
				 						
			--Added by Nimesh 22 April, 2015
			--Updating default shift info From Shift Detail 
			SET @Sql_Query2 ='Update	#Emp_shift1 
							SET		Day' + CAST(DAY(@For_Date) AS VARCHAR(2)) + '= Q1.Shift_ID
							FROM	#Emp_shift1 d inner Join        
									(SELECT sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail sd WITH (NOLOCK) inner join        
									(SELECT MaX(for_Date) for_Date ,Emp_Id  from T0100_Emp_Shift_Detail WITH (NOLOCK)       
										where	Cmp_Id =@Cmp_ID and shift_Type = 0 and For_Date <=@For_Date group by Emp_ID)q ON 
												sd.Emp_ID =q.Emp_ID and sd.For_Date =q.for_Date)q1  ON d.Emp_ID = q1.Emp_ID'
			EXECUTE SP_EXECUTESQL @Sql_Query2 ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID

				
			--Updating Shift ID From Rotation
			SET @Sql_Query2 ='UPDATE	#Emp_shift1 
							SET		Day' + CAST(DAY(@For_Date) AS VARCHAR(2)) + '=SM.SHIFT_ID
							FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
							WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = ''Day'' + CAST(DATEPART(d, @For_Date) AS VARCHAR) AND
									Emp_ID=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
										FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
												R_Effective_Date<=@For_Date)'
			EXECUTE SP_EXECUTESQL @Sql_Query2 ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should be assigned to that particular employee
			SET @Sql_Query2 ='UPDATE	#Emp_shift1 
							SET		Day' + CAST(DAY(@For_Date) AS VARCHAR(2)) + '=ESD.SHIFT_ID
							FROM	#Emp_shift1 D INNER JOIN (SELECT esd.Shift_ID,esd.Emp_ID,esd.Shift_Type,esd.For_Date
									FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND esd.For_Date = @For_Date) ESD ON
									D.Emp_Id=ESD.Emp_ID 
							WHERE	ESD.Emp_ID IN (SELECT R.R_EmpID FROM #Rotation R
										WHERE R_DayName = ''Day'' + CAST(DATEPART(d, @For_Date) AS VARCHAR) AND R_Effective_Date<=@For_Date
										GROUP BY R.R_EmpID)'
			EXECUTE SP_EXECUTESQL @Sql_Query2 ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should not be assigned to that particular employee
			SET @Sql_Query2 ='UPDATE	#Emp_shift1 
							SET		Day' + CAST(DAY(@For_Date) AS VARCHAR(2)) + '=ESD.SHIFT_ID
							FROM	#Emp_shift1 D INNER JOIN (SELECT esd.Shift_ID,esd.Emp_ID,esd.Shift_Type,esd.For_Date
									FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND esd.For_Date = @For_Date) ESD ON
									D.Emp_Id=ESD.Emp_ID 
							WHERE	IsNULL(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (SELECT R.R_EmpID FROM #Rotation R
										WHERE R_DayName = ''Day'' + CAST(DATEPART(d, @For_Date) AS VARCHAR) AND R_Effective_Date<=@For_Date
										GROUP BY R.R_EmpID)'				
			EXECUTE SP_EXECUTESQL @Sql_Query2 ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID
			--END Nimesh
						

			SET @Sql_Query = 'UPDATE	#Emp_shift1
							  SET		Day' + CAST(day(@For_Date) AS VARCHAR(2)) + ' = LM.Leave_Code
							  FROM		#Emp_shift1 E
										INNER JOIN T0140_LEAVE_TRANSACTION LT ON E.Emp_ID = LT.Emp_ID and lt.Leave_Used>0 and LT.For_Date <= @For_Date 
										INNER JOIN T0040_LEAVE_MASTER LM ON LT.leave_id = LM.leave_id and LT.Cmp_ID = Lm.Cmp_ID AND 
													DATEADD(DD,case when lt.Leave_Used=0.5 OR LM.Apply_Hourly = 1 then 0.5 ELSE ((lt.Leave_Used)-1)END ,LT.For_Date)>= @For_Date					
							  WHERE		LT.leave_used > 0'
				
			EXECUTE sp_executesql @Sql_Query ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID
		


			SET @Sql_Query1 = 'UPDATE	#Emp_shift1
							   SET		Day' + CAST(day(@For_Date) AS VARCHAR(2)) + ' = ''W''
							   FROM		#Emp_shift1 E
										INNER JOIN #EMP_WEEKOFF EWD ON E.emp_id = EWD.emp_id AND EWD.FOR_DATE=@For_Date'
												--'AND  @for_date in (SELECT CAST(DATA  AS DATETIME)  from dbo.Split(EWD.strweekoff,'';'' ) where DATA <>'''')'
				

			EXECUTE sp_executesql @Sql_Query1 ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID

			SET @Sql_Query2 = 'UPDATE	#Emp_shift1
							   SET		Day' + CAST(day(@For_Date) AS VARCHAR(2)) + ' = ''H''
							   FROM		#Emp_shift1 E
										INNER JOIN #EMP_HOLIDAY EHD ON E.emp_id = EHD.emp_id AND EHD.FOR_DATE=@For_Date'
												--'AND  @for_date in (SELECT CAST(DATA  AS DATETIME)  from dbo.Split(EWD.StrHoliday,'';'' ) where DATA <>'''')'
		

			EXECUTE sp_executesql @Sql_Query2 ,N'@For_Date DATETIME,@Cmp_ID NUMERIC',@For_Date,@Cmp_ID

			SET @For_Date = dateadd(d,1,@For_Date)
		END	
	
	SELECT	* INTO #Emp_shift1_Unpivot
	FROM	(SELECT Emp_ID,Cmp_ID,[DayName],INTIAL AS INTIAL  FROM 
			(SELECT Emp_ID, Cmp_ID, Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31
			FROM	#Emp_shift1) UP
		UNPIVOT
			(INTIAL FOR [DayName] IN 
				(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
			) AS UNPVT
		) AS EUP 
			
			
	DECLARE @InitialDesc VARCHAR(max),
			@Shifts VARCHAR(max);
		
	SELECT	@InitialDesc = COALESCE(@InitialDesc + ',', '') + LEFT(INTIAL + '  ',3) + ' : ' + L.Leave_Name
	FROM	(SELECT DISTINCT INTIAL, Cmp_ID FROM #Emp_shift1_Unpivot WHERE Cmp_ID=@Cmp_ID) T INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON
			T.INTIAL COLLATE SQL_Latin1_General_CP1_CI_AS  = L.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS  AND T.Cmp_ID=L.Cmp_ID
		
		

	SET @InitialDesc = IsNULL(@InitialDesc,'') + '#';
		
	SELECT	@Shifts = COALESCE(@Shifts + ',', '') + LEFT(CAST(S.Shift_ID AS VARCHAR) + '  ',3) + ' : ' + S.Shift_Name
	FROM	T0040_SHIFT_MASTER S WITH (NOLOCK)
	WHERE	S.Cmp_ID=@Cmp_ID
		
	SET @InitialDesc = @InitialDesc + @Shifts;
		
		
	
	SELECT	ES.* ,Emp_full_Name,Emp_Code,Branch_NAme,Grd_Name,Dept_NAme,Type_Name,Desig_NAme,
			Cmp_Name ,Cmp_Address,@From_Date AS P_From_date ,@To_Date AS P_To_Date,Comp_Name,Branch_Address,BM.Branch_ID,
			@InitialDesc AS InitialDescription,E.Alpha_Emp_Code,DGM.Desig_Dis_No  --added jimit 24082015
	FROM	#Emp_shift1 ES 
			INNER JOIN T0080_Emp_master E WITH (NOLOCK) ON Es.Emp_ID = E.Emp_ID 
			INNER JOIN (SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date  
						FROM	T0095_Increment I WITH (NOLOCK)
								INNER JOIN (SELECT max(Increment_ID) AS Increment_ID , Emp_ID 
											FROM	T0095_Increment	WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
											WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
											GROUP BY emp_ID  ) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
						) I_Q  ON E.Emp_ID = I_Q.Emp_ID  
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
			INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I_Q.Branch_ID = BM.Branch_ID 
			INNER JOIN T0010_company_master cm WITH (NOLOCK) ON es.cmp_Id = cm.cmp_ID
	ORDER BY CASE WHEN IsNUMERIC(e.Alpha_Emp_Code) = 1 THEN RIGHT(REPLICATE('0',21) + e.Alpha_Emp_Code, 20)
				When IsNUMERIC(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + REPLICATE('',21), 20)
					ELSE e.Alpha_Emp_Code
				END
RETURN




