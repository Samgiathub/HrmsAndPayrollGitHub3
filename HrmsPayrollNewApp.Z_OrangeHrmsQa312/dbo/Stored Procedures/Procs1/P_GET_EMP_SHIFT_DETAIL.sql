
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_EMP_SHIFT_DETAIL]
  @Cmp_ID    numeric        
 ,@From_Date   datetime        
 ,@To_Date    datetime                  
 ,@Constraint varchar(max)
 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	CREATE TABLE #DATES (FOR_DATE DATETIME)
	
	
	
	CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
	EXEC dbo.SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0,@Cat_ID=0, @Grd_ID=0, @Type_ID=0, @Dept_ID=0, @Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint 
	
	
	
	INSERT INTO #Emp_Shift(EMP_ID,FOR_DATE)
	SELECT	EMP_ID,DATEADD(d,ROW_ID, @From_Date ) AS FOR_DATE
	FROM	(SELECT TOP 366 ROW_NUMBER() OVER(ORDER BY OBJECT_ID) - 1 AS ROW_ID FROM SYS.OBJECTS ) T
			CROSS JOIN #EMP_CONS E
	WHERE	DATEADD(d,ROW_ID, @From_Date ) <= @To_Date
	ORDER BY EMP_ID, FOR_DATE
	
	
	
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @to_date, @Constraint
	
	
	
	DECLARE @Tmp_Date DATETIME;
	SET @Tmp_Date = @From_Date;
	
	WHILE (@Tmp_Date <= @To_Date) BEGIN					
		--Updating default shift info From Shift Detail
		UPDATE	#Emp_Shift SET shift_id = Shf.Shift_ID
		FROM	#Emp_Shift D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
		FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) INNER JOIN  
				(SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) 
					WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @Tmp_Date and ISNULL(Shift_Type,0)=0 GROUP BY Emp_ID) S ON 
					esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
				Shf.Emp_ID = D.EMP_ID 
		WHERE	D.For_Date=@Tmp_Date
		
		
		--Updating Shift ID From Rotation
		UPDATE	#Emp_Shift 
		SET		SHIFT_ID=SM.SHIFT_ID
		FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
		WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 
				AND Emp_Id=R.R_EmpID AND For_Date=@Tmp_Date
				AND R.R_Effective_Date=(
										SELECT	MAX(R_Effective_Date)
										FROM	#Rotation R1	
										WHERE	R1.R_EmpID=Emp_Id AND R_Effective_Date<=@Tmp_Date
									   ) 							
				
		--Updating Shift ID For Shift_Type=0
		UPDATE	#Emp_Shift
		SET		SHIFT_ID=Shf.SHIFT_ID
		FROM	#Emp_Shift D 
				INNER JOIN (
							SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
							FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) 
							WHERE	esd.Emp_ID IN (
													SELECT	R.R_EmpID 
													FROM	#Rotation R
													WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 
													GROUP BY R.R_EmpID
												  ) 
									AND Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date 
							) Shf ON Shf.Emp_ID = D.Emp_Id
		WHERE	For_date=@Tmp_Date

		--Updating Shift ID For Shift_Type=1
		UPDATE	#Emp_Shift
		SET		SHIFT_ID=Shf.SHIFT_ID
		FROM	#Emp_Shift D 
				INNER JOIN (
							SELECT	esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
							FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)
							WHERE	esd.Emp_ID NOT IN (
														SELECT	R.R_EmpID 
														FROM	#Rotation R
														WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 
														GROUP BY R.R_EmpID
													  ) 
									AND Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND IsNull(esd.Shift_Type,0)=1 AND For_Date = @Tmp_Date 
							) Shf ON Shf.Emp_ID = D.Emp_Id
		WHERE	For_date=@Tmp_Date		   
    
        
		SET @Tmp_Date = DATEADD(d,1,@tmp_date) 					
	END
	--IF OBJECT_ID('tempdb..#EMP_CONS') IS NULL
	--	BEGIN		
	--		CREATE TABLE #EMP_CONS(EMP_ID NUMERIC, BRANCH_ID NUMERIC, INCREMENT_ID NUMERIC);
	--		EXEC dbo.SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@From_Date, @To_Date=@To_Date, @Branch_ID=0,@Cat_ID=0, @Grd_ID=0, @Type_ID=0, @Dept_ID=0, @Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint 
	--	END
	
		
		RETURN
		
	
	
END

