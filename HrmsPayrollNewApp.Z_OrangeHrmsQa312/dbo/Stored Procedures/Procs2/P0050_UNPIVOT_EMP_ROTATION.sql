

-- =============================================
-- Author:		Nimesh
-- Create date: 20 April, 2015
-- Description:	To generate the temporary table which holds Employee Monthly Shift Rotation.
-- =============================================
CREATE PROCEDURE [dbo].[P0050_UNPIVOT_EMP_ROTATION]	
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0) = null,
	@Effective_Date DateTime = null,
	@SelectedEmp varchar(Max) = ''
AS
BEGIN
	
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	IF (OBJECT_ID('tempdb..#Emp_UNPVT') IS NULL) 
		CREATE TABLE #Emp_UNPVT(
			T_Emp_ID numeric(18,0)
		)
	ELSE
		TRUNCATE TABLE #Emp_UNPVT;
	IF (IsNull(@SelectedEmp,'') <> '') BEGIN        
		INSERT INTO #Emp_UNPVT
		SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@SelectedEmp,'#')         
	END ELSE BEGIN
		DECLARE @ToDate DateTime;
		If (@Effective_Date IS NOT NULL)
			SET @ToDate = @Effective_Date;
		ELSE
			SET @ToDate = GETDATE();
			
		INSERT	INTO #Emp_UNPVT
		SELECT	DISTINCT I.Emp_Id 
		FROM	dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
					( 
						SELECT	MAX(Increment_effective_Date) AS For_Date, Emp_ID 
						FROM	dbo.T0095_Increment WITH (NOLOCK) 
						WHERE	Increment_Effective_date <= @ToDate AND Cmp_ID = @Cmp_ID and Emp_ID=ISNULL(@Emp_ID, Emp_ID)
						GROUP BY emp_ID 
					) Qry ON I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date
				INNER JOIN T0050_Emp_Monthly_Shift_Rotation R  WITH (NOLOCK) ON R.Emp_ID=I.Emp_ID AND R.Cmp_ID=I.Cmp_ID
				INNER JOIN T0050_SHIFT_ROTATION_MASTER ROT  WITH (NOLOCK) ON R.Cmp_ID=ROT.Cmp_ID AND R.Rotation_ID=ROT.Tran_ID					
		WHERE	I.Cmp_ID = Isnull(@Cmp_ID,I.Cmp_ID) and I.Emp_ID=ISNULL(@Emp_ID, I.Emp_ID)
				AND I.Emp_ID IN (
									SELECT	EMP_ID 
									FROM	(
												SELECT	EMP_ID, JOIN_DATE, isnull(left_Date, @ToDate) AS left_Date 
												FROM	dbo.T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) 
												WHERE	Cmp_ID = @Cmp_ID
											) qry
									WHERE	((@ToDate  >= join_Date  and  @ToDate <= left_date ) or left_date is null and @ToDate >= Join_Date)											
								)
				AND ROT.Rotation_Type=1
	END
	
	
	DECLARE @HasLocalTemp bit;
	SET @HasLocalTemp = 1;
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL) BEGIN
		Create Table #Rotation
		(
			R_EmpID numeric(18,0),
			R_DayName varchar(25),
			R_ShiftID numeric(18,0),
			R_Effective_Date DateTime
		)
	END ELSE BEGIN
		SET @HasLocalTemp = 0;
		TRUNCATE TABLE #Rotation;
	END
	
	IF OBJECT_ID('IX_ROTATION_EMPID_DAYNAME') IS NOT NULL
		CREATE CLUSTERED INDEX IX_ROTATION_EMPID_DAYNAME ON #Rotation(R_EmpID, R_Effective_Date, R_DayName);
	
	
	/*
	--Do not remove or change any column.
	Create Table #Rotation
	(
		R_EmpID numeric(18,0),
		R_DayName varchar(25),
		R_ShiftID numeric(18,0),
		R_Effective_Date DateTime
	)*/

    IF (@Emp_ID IS NULL AND @Effective_Date IS NULL)
		--To Fetch Record from Employee Shift Rotation Master Table.
		Insert Into #Rotation
		Select ER.Emp_ID,SR.[DayName],SR.ShiftID,Er.Effective_Date		
		From T0050_Emp_Monthly_Shift_Rotation ER  WITH (NOLOCK) ,
			(SELECT Cmp_ID,Tran_ID,DayName,ShiftID FROM 
				(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
				FROM T0050_Shift_Rotation_Master WITH (NOLOCK) 
				WHERE Rotation_Type=1 And Cmp_ID = @Cmp_ID) p
			UNPIVOT
				(ShiftID FOR DayName IN 
					(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
				) As unpvt
			) As SR, #Emp_UNPVT EMP
		Where	ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID And ER.Cmp_ID=@Cmp_ID AND 
				--CAST(REPLACE([DayName], 'Day','') As Numeric(18,0)) >= DATEPART(d, ER.Effective_Date) AND
				EMP.T_Emp_ID=ER.Emp_ID 
		Order By ER.Effective_Date Desc
	ELSE IF (@Emp_ID IS NOT NULL AND @Effective_Date IS NULL)
		--To Fetch Record from Employee Shift Rotation Master Table.
		Insert Into #Rotation
		Select ER.Emp_ID,SR.[DayName],SR.ShiftID,Er.Effective_Date		
		From T0050_Emp_Monthly_Shift_Rotation ER WITH (NOLOCK) ,
			(SELECT Cmp_ID,Tran_ID,DayName,ShiftID FROM 
				(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
				FROM T0050_Shift_Rotation_Master WITH (NOLOCK) 
				WHERE Rotation_Type=1 And Cmp_ID = @Cmp_ID) p
			UNPIVOT
				(ShiftID FOR DayName IN 
					(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
				) As unpvt
			) As SR, #Emp_UNPVT EMP
		Where ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID AND ER.EMP_ID=@EMP_ID 
			And ER.Cmp_ID=@Cmp_ID AND --CAST(REPLACE([DayName], 'Day','') As Numeric(18,0)) >= DATEPART(d, ER.Effective_Date) AND
			EMP.T_Emp_ID = ER.Emp_ID
		Order By ER.Effective_Date Desc
	ELSE IF (@Emp_ID IS NULL AND @Effective_Date IS NOT NULL)
		--To Fetch Record from Employee Shift Rotation Master Table.
		Insert Into #Rotation
		Select ER.Emp_ID,SR.[DayName],SR.ShiftID,Er.Effective_Date
		From T0050_Emp_Monthly_Shift_Rotation ER WITH (NOLOCK) ,
			(SELECT Cmp_ID,Tran_ID,DayName,ShiftID --,CONVERT(DATETIME,(CONVERT(varchar(8), @Effective_Date, 111) + Right('00' + REPLACE(DayName, 'Day',''),2)), 111) As For_Date
				FROM 
				(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
				FROM T0050_Shift_Rotation_Master WITH (NOLOCK) 
				WHERE Rotation_Type=1 And Cmp_ID = @Cmp_ID) p
			UNPIVOT
				(ShiftID FOR DayName IN 
					(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
				) As unpvt
			) As SR, #Emp_UNPVT EMP
		Where ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID 
			And ER.Cmp_ID=@Cmp_ID AND --CAST(REPLACE([DayName], 'Day','') As Numeric(18,0)) >= DATEPART(d, ER.Effective_Date) AND
			ER.Effective_Date <= @Effective_Date AND EMP.T_Emp_ID = ER.Emp_ID --AND
			--SR.For_Date <= @Effective_Date
		Order By ER.Effective_Date Desc
	ELSE IF (@Emp_ID IS NOT NULL AND @Effective_Date IS NOT NULL) BEGIN
		--To Fetch Record from Employee Shift Rotation Master Table.
		Insert Into #Rotation		
		Select ER.Emp_ID,SR.[DayName],SR.ShiftID,Er.Effective_Date
		From T0050_Emp_Monthly_Shift_Rotation ER WITH (NOLOCK) ,
			(SELECT Cmp_ID,Tran_ID,DayName,ShiftID --,CONVERT(DATETIME,(CONVERT(varchar(8), @Effective_Date, 111) + Right('00' + REPLACE(DayName, 'Day',''),2)), 111) As For_Date 
				FROM 
				(SELECT Cmp_ID,Tran_ID,Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31 
				FROM T0050_Shift_Rotation_Master WITH (NOLOCK) 
				WHERE Rotation_Type=1 And Cmp_ID = @Cmp_ID) p
			UNPIVOT
				(ShiftID FOR DayName IN 
					(Day1, Day2, Day3, Day4, Day5,Day6,Day7,Day8,Day9,Day10,Day11, Day12, Day13, Day14, Day15,Day16,Day17,Day18,Day19,Day20,Day21, Day22, Day23, Day24, Day25,Day26,Day27,Day28,Day29,Day30,Day31)
				) As unpvt
			) As SR
		Where ER.Rotation_ID=SR.Tran_ID AND ER.Cmp_ID=SR.Cmp_ID AND ER.EMP_ID=@EMP_ID 
			And ER.Cmp_ID=@Cmp_ID AND --CAST(REPLACE([DayName], 'Day','') As Numeric(18,0)) >= DATEPART(d, ER.Effective_Date) AND
			ER.Effective_Date <= @Effective_Date AND ER.Emp_ID = @Emp_ID --AND
			--SR.For_Date <= @Effective_Date
		Order By ER.Effective_Date Desc		
		
		
	END
	
	DROP TABLE #Emp_UNPVT;
		
	IF (@HasLocalTemp = 0) BEGIN
		IF OBJECT_ID('tempdb..##Rotation') IS NOT NULL 
			TRUNCATE TABLE ##Rotation
		ELSE
			SELECT	TOP 0 *
			INTO	##Rotation
			FROM	#Rotation
		
		INSERT INTO	##Rotation
		SELECT * FROM	#Rotation
		
	END
END


