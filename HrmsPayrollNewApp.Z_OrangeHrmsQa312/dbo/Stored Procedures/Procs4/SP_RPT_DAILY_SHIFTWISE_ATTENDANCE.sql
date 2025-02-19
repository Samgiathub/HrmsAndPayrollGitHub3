
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_DAILY_SHIFTWISE_ATTENDANCE]
	@Cmp_ID 			NUMERIC
	,@From_Date			DATETIME
	,@To_Date 			DATETIME 
	,@Branch_ID			NUMERIC
	,@Cat_ID 			NUMERIC 
	,@Grd_ID 			NUMERIC
	,@Type_ID 			NUMERIC
	,@Dept_ID 			NUMERIC
	,@Desig_ID 			NUMERIC
	,@Emp_ID 			NUMERIC
	,@Shift_ID          NUMERIC
	,@constraint 		VARCHAR(MAX)
	,@PBranch_ID        VARCHAR(200) = '0'
	,@Mode				VARCHAR(20)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @To_Date = @From_Date

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
	IF @Shift_ID = 0
		SET @Shift_ID = NULL
	IF @Cmp_ID = 0
		SET @Cmp_ID = NULL
	
	CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   	
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2,@PBranch_ID 

  		
	DECLARE @PRESENT TABLE  
	(  
		EMP_ID   NUMERIC,  
		EMP_CODE  VARCHAR(100),  
		EMP_FULL_NAME VARCHAR(100),  
		IN_TIME   DATETIME,  
		STATUS   CHAR(2),
		STATUS_2   CHAR(2),	--Added by Rajput 19072017 For Employee Present ON Week-off
		type     VARCHAR(50),
		Type_Name VARCHAR(100)  ,
		branch_id NUMERIC,
		shift_id NUMERIC,
		dept_id NUMERIC,
		segment_id NUMERIC, --Added by Rajput 11072017
		Desig_Id NUMERIC 
	)  

	IF IsNull(@Cmp_ID,0) = 0
		BEGIN
		-- For Appointed Employee, Added by Hardik 13/09/2012
			INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME)   
			SELECT	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name 
			FROM	dbo.T0095_Increment I WITH (NOLOCK)
					INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID, Emp_ID 
								FROM	dbo.T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
								WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)
								GROUP BY emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID 
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) ON I.Emp_ID = Em.Emp_ID
					INNER JOIN #Emp_Cons ec ON ec.Emp_ID = Em.Emp_ID
			WHERE	IsNull(I.Type_ID,0) = IsNull(@Type_ID,IsNull(I.Type_ID,0)) 
					AND IsNull(I.Dept_ID,0) = IsNull(@Dept_ID ,IsNull(I.Dept_ID,0))   
					AND IsNull(I.Desig_Id,0) = IsNull(@Desig_ID,IsNull(I.Desig_Id,0))  
					AND IsNull(I.Grd_ID,0) = IsNull(@Grd_ID,IsNull(I.Grd_ID,0))  
					AND IsNull(I.Cat_ID,0) = IsNull(@Cat_ID,IsNull(I.Cat_ID,0)) 
					AND IsNull(I.Branch_ID,0) =IsNull(@Branch_ID,IsNull(I.Branch_ID,0)) 
					AND (em.Emp_Left_Date IS NULL or em.Emp_Left_Date > @From_Date)
					AND (em.Date_Of_Join <= @From_Date)
					AND i.Cmp_ID IN (SELECT Cmp_Id FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE is_GroupOFCmp = 1 AND is_Main <> 1)
		END
	ELSE
		BEGIN
			INSERT	INTO	@PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME)   
			SELECT	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name 
			FROM	dbo.T0095_Increment I WITH (NOLOCK)
					INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID, Emp_ID 
								FROM	dbo.T0095_Increment WITH (NOLOCK) -- Ankit 08092014 for Same Date Increment
								WHERE	Increment_Effective_date <= @To_Date
										AND Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)
								GROUP BY emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID 
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) ON I.Emp_ID = Em.Emp_ID
					INNER JOIN #Emp_Cons ec ON ec.Emp_ID = Em.Emp_ID
			WHERE	IsNull(I.Type_ID,0) = IsNull(@Type_ID,IsNull(I.Type_ID,0)) 
					AND IsNull(I.Dept_ID,0) = IsNull(@Dept_ID ,IsNull(I.Dept_ID,0))   
					AND IsNull(I.Desig_Id,0) = IsNull(@Desig_ID,IsNull(I.Desig_Id,0))  
					AND IsNull(I.Grd_ID,0) = IsNull(@Grd_ID,IsNull(I.Grd_ID,0))  
					AND IsNull(I.Cat_ID,0) = IsNull(@Cat_ID,IsNull(I.Cat_ID,0)) 
					AND IsNull(I.Branch_ID,0) =IsNull(@Branch_ID,IsNull(I.Branch_ID,0)) 
					AND (em.Emp_Left_Date IS NULL or em.Emp_Left_Date > @From_Date)
					AND (em.Date_Of_Join <= @From_Date)
					--AND i.Cmp_ID IN (SELECT Cmp_Id FROM T0010_COMPANY_MASTER WHERE is_GroupOFCmp = 1 AND is_Main <> 1)
		END
  
	UPDATE	@PRESENT 
	SET  IN_TIME = T.In_Time, 
			STATUS = 'P' 
	FROM	@PRESENT P 
			INNER JOIN T0150_EMP_INOUT_RECORD T ON P.EMP_ID = T.Emp_ID AND T.For_Date = @From_Date
	WHERE	MONTH(T.in_time)= MONTH(@From_Date) 
			AND YEAR(T.in_time) = YEAR(@From_Date) 
			AND DAY(T.in_time)  = DAY(@From_Date) 
	  
	DELETE	@PRESENT 
	FROM	(SELECT	S.Emp_ID,IN_TIME,ROW_NUMBER() OVER (PARTITION BY S.Emp_Id ORDER BY S.Emp_Id) AS NR
			 FROM	@PRESENT S) Q 
			 INNER JOIN		@PRESENT P ON Q.EMP_ID = P.EMP_ID AND Q.IN_TIME = P.IN_TIME  
	WHERE	Q.NR > 1 

	UPDATE	@PRESENT 
	SET  STATUS = 'L' 
	FROM	@PRESENT P 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL LA ON P.EMP_ID = LA.Emp_ID 
			INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID 
			LEFT OUTER JOIN dbo.T0150_LEAVE_CANCELLATION AS LC ON lad.Leave_Approval_ID =Lc.Leave_Approval_ID 
			INNER JOIN dbo.T0140_LEAVE_TRANSACTION LT ON LT.For_Date = @From_Date AND LAD.Leave_ID = LT.Leave_ID AND LA.Emp_ID = LT.Emp_ID -- added by Gadriwala 28022014( with Approved Hardikbhai)
	WHERE	LAD.From_Date < = @From_Date 
			AND LAD.To_Date >= @From_Date 
			AND LA.Approval_STATUS='A' 
			AND Leave_Type <> 'Company Purpose' AND IsNull(LC.Is_Approve,0)=0 
			AND STATUS IS NULL AND (Leave_Used > 0 or CompOff_Used > 0 ) -- Changed By Gadriwala Muslim 02102014


	UPDATE	@PRESENT 
	SET  STATUS = 'OD' 
	FROM	@PRESENT P 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL LA ON P.EMP_ID = LA.Emp_ID 
			INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID 
			LEFT OUTER JOIN dbo.T0150_LEAVE_CANCELLATION AS LC ON lad.Leave_Approval_ID = Lc.Leave_Approval_ID
	WHERE	LAD.From_Date < = @From_Date AND LAD.To_Date >= @From_Date 
			AND LA.Approval_STATUS='A' AND Leave_Type = 'Company Purpose' AND IsNull(Is_Approve,0)=0 
			AND STATUS IS NULL

	UPDATE	@PRESENT 
	SET  STATUS = 'A' 
	FROM	@PRESENT P
	WHERE	STATUS IS NULL AND P.IN_TIME IS NULL

 
	--Hardik 10/07/2012
	--DECLARE @Is_Cancel_Weekoff	NUMERIC(1,0)
	--DECLARE @Left_Date			DATETIME  
	--DECLARE @join_dt			DATETIME  
	--DECLARE @StrHoliday_Date	VARCHAR(MAX)    
	--DECLARE @StrWeekoff_Date	VARCHAR(MAX)
	--DECLARE @Cancel_Weekoff		NUMERIC(18, 0)
	--DECLARE @WO_Days			NUMERIC

	--SET @Is_Cancel_Weekoff = 0 
	--SET @StrHoliday_Date = ''    
	--SET @StrWeekoff_Date = ''  
  
	--IF @Branch_ID IS NULL
	--	BEGIN 
	--		SELECT	TOP 1 @Is_Cancel_Weekoff = Is_Cancel_Weekoff 
	--		FROM	T0040_GENERAL_SETTING 
	--		WHERE	Cmp_ID = @cmp_ID AND 
	--				For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= GETDATE() AND Cmp_ID = @Cmp_ID)    
	--	END
	--ELSE
	--	BEGIN
	--		SELECT	@Is_Cancel_Weekoff = Is_Cancel_Weekoff 
	--		FROM	T0040_GENERAL_SETTING 
	--		WHERE	Cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID    
	--				AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= GETDATE() AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
	--	END

	--DECLARE @Cmp_Id_Cur AS NUMERIC

	--DECLARE cur CURSOR FAST_FORWARD FOR 
	--SELECT	EMP_ID 
	--FROM	@PRESENT 
	--WHERE	STATUS IN ('A','P')
  
	--OPEN cur
	--FETCH NEXT FROM cur INTO @Emp_ID
  
	--WHILE @@FETCH_STATUS = 0
	--	BEGIN
	--		SELECT	@join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date,@Cmp_Id_Cur = Cmp_ID 
	--		FROM	T0080_EMP_MASTER 
	--		WHERE	Emp_ID=@Emp_ID
			
	--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_Id_Cur,@From_Date,@From_Date,@join_dt,@left_Date,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
		
	--		IF CHARINDEX(CONVERT(VARCHAR(11),@From_Date,109),@StrWeekoff_Date,0) > 0
	--			BEGIN
	--				UPDATE	@PRESENT 
	--				SET		STATUS='WO',
	--						type='<font color="Green">WO</font>'
	--				WHERE	EMP_ID = @Emp_ID AND STATUS = 'A'
				
	--				UPDATE	@PRESENT 
	--				SET		STATUS_2='WO',
	--						type='<font color="Green">WO</font>'
	--				WHERE	EMP_ID = @Emp_ID AND STATUS = 'P'
				
	--			END
		
	--		SET @StrHoliday_Date = ''    
	--		SET @StrWeekoff_Date = ''  
  
	--		FETCH NEXT FROM cur INTO @Emp_ID
	--	END
  
	--Close cur
	--Deallocate cur


	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
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

			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@From_Date, @All_Weekoff = 0, @Exec_Mode=1

		END

	UPDATE	P 
	SET		STATUS='WO',
			type='<font color="Green">WO</font>'
	FROM	@PRESENT P
			INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID 
	WHERE	STATUS = 'A' AND W.For_Date=@From_Date

	UPDATE	P 
	SET		STATUS_2='WO',
			type='<font color="Green">WO</font>'
	FROM	@PRESENT P
			INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID 
	WHERE	STATUS = 'P' AND W.For_Date=@From_Date
				

	UPDATE	P
	SET		branch_id = inc.Branch_ID , dept_id = Inc.Dept_ID, Desig_Id = Inc.Desig_Id,Segment_Id = INC.SEGMENT_ID
	FROM	@PRESENT  p 
			INNER JOIN (	
						SELECT Branch_ID	, i.Emp_ID , I.Dept_ID,I.Desig_Id,I.SEGMENT_ID		
						FROM T0095_Increment I WITH (NOLOCK)
							INNER JOIN 
								( 
									SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
									FROM T0095_INCREMENT I WITH (NOLOCK) 
									INNER JOIN 
										(
											SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE I3.Increment_effective_Date <= GETDATE()
											GROUP BY I3.EMP_ID  
										) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
								   WHERE I.INCREMENT_EFFECTIVE_DATE <= GETDATE() AND I.Cmp_ID = @Cmp_ID
								   GROUP BY I.emp_ID  
								) Qry on	I.Emp_ID = Qry.Emp_ID	AND I.Increment_ID = Qry.Increment_ID 
						)Inc ON Inc.Emp_ID = p.EMP_ID
		
							 
				 --INNER JOIN     
				 --( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment		-- Ankit 08092014 for Same Date Increment			
				 --WHERE Increment_Effective_date <= @To_Date
				 --AND Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)
				 --GROUP BY emp_ID) Qry ON    
				 --I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID) Inc ON Inc.Emp_ID = p.EMP_ID
	
	--Updating Default Shift ID FROM Employee Shift Change Detail Table.
	UPDATE @PRESENT SET shift_id = Shf.Shift_ID
	FROM @PRESENT  p INNER JOIN (SELECT esd.Shift_ID , esd.Emp_ID 
									FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) INNER JOIN  
									(SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
									WHERE Cmp_ID = IsNull(@Cmp_ID,Cmp_ID) AND For_Date <= @To_Date GROUP BY Emp_ID) S ON 
								esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
					Shf.Emp_ID = p.EMP_ID 
					
	
	
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation AS per given employee id AND effective date.
	--it will fetch all employee's shift rotation detail IF employee id IS not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID NUMERIC(18,0), R_DayName VARCHAR(25), R_ShiftID NUMERIC(18,0), R_Effective_Date DATETIME);
	--The #Rotation table gets re-created IN dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint
	
	--Updating @PRESENT table for Shift_ID
	UPDATE	@PRESENT SET SHIFT_ID=R_ShiftID
	FROM #Rotation R 
	WHERE	R.R_EmpID=EMP_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) AS VARCHAR)
			AND R.R_Effective_Date=(
										SELECT	MAX(R_Effective_Date) FROM #Rotation 
										WHERE	R_Effective_Date <=@To_Date
									)
			
			
	
	--UPDATE Shift ID AS per the assigned shift IN shift detail 
	--Retrieve the shift id FROM employee shift changed detail table
	UPDATE	@PRESENT SET SHIFT_ID = Shf.Shift_ID
	FROM @PRESENT  p 
			INNER JOIN (
						SELECT	ESD.Shift_ID, ESD.Emp_ID 
						FROM T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
						WHERE	ESD.Emp_ID IN (
									Select	R.R_EmpID FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) AS VARCHAR) 													
									GROUP BY R.R_EmpID
								)
								AND ESD.For_Date=@To_Date AND ESD.Cmp_ID=@Cmp_ID
						) Shf ON Shf.Emp_ID = p.EMP_ID
				
	--IF the rotation IS not assigned the only those shift should be assigned which shift_type IS 1
	UPDATE	@PRESENT SET SHIFT_ID = Shf.Shift_ID
	FROM @PRESENT  p 
			INNER JOIN (
						SELECT	ESD.Shift_ID, ESD.Emp_ID 
						FROM T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
						WHERE	ESD.Emp_ID NOT IN (
									Select	R.R_EmpID FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) AS VARCHAR) 													
									GROUP BY R.R_EmpID
								)
								AND ESD.For_Date=@To_Date AND ESD.Cmp_ID=@Cmp_ID AND IsNull(ESD.Shift_Type,0)=1 
						) Shf ON Shf.Emp_ID = p.EMP_ID
	--END Nimesh
					
	--- Added by Hardik 11/04/2014 for Auto Shift				
	DECLARE @Emp_Id_T NUMERIC
	DECLARE @In_Time DATETIME
	DECLARE @New_Shift_Id NUMERIC


	DECLARE curautoshift cursor Fast_forward for	                  
		SELECT EMP_ID,IN_TIME FROM @PRESENT P INNER JOIN T0040_SHIFT_MASTER S WITH (NOLOCK) ON P.Shift_id = S.Shift_Id
			WHERE s.Inc_Auto_Shift = 1 AND STATUS = 'P'
	OPEN curautoshift                      
	  FETCH NEXT FROM curautoshift INTO @Emp_ID_T,@In_Time
		WHILE @@fetch_STATUS = 0                    
			BEGIN     
						IF Exists(SELECT 1 FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
									DateAdd(ss,-14400,Cast(CAST(@In_Time AS VARCHAR(11)) + ' ' + Shift_St_Time AS DATETIME)) <= @In_Time And
									DateAdd(ss,14400,Cast(CAST(@In_Time AS VARCHAR(11)) + ' ' + Shift_St_Time AS DATETIME)) >= @In_Time AND Inc_Auto_Shift = 1 )
							BEGIN
								SELECT @New_Shift_Id = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
									DateAdd(ss,-14400,Cast(CAST(@In_Time AS VARCHAR(11)) + ' ' + Shift_St_Time AS DATETIME)) <= @In_Time And
									DateAdd(ss,14400,Cast(CAST(@In_Time AS VARCHAR(11)) + ' ' + Shift_St_Time AS DATETIME)) >= @In_Time AND Inc_Auto_Shift = 1 
								ORDER BY ABS( DATEDIFF(ss,@In_Time,cast(@In_Time AS VARCHAR(11)) + ' ' + Shift_St_Time)) desc 
									
								
								UPDATE @PRESENT SET shift_id = @New_Shift_Id WHERE EMP_ID = @Emp_Id_T AND In_Time = @In_Time
							END

				FETCH NEXT FROM curautoshift INTO @Emp_ID_T,@In_Time
			END
			
	Close curautoshift
	Deallocate curautoshift
		
		BEGIN
		
			--SELECT * FROM @deptTable
		  DECLARE @colsParameters AS NVARCHAR(MAX)
		  DECLARE @qry1 AS nVARCHAR(MAX)
		  DECLARE @qry2 AS nVARCHAR(MAX)
		  DECLARE @columns VARCHAR(MAX)
		  DECLARE @Total_Present AS NUMERIC
		  DECLARE @Total_Present_On_Weekoff AS NUMERIC --Added by Rajput 19072017
		  DECLARE @Total_absent AS NUMERIC
		  DECLARE @Total_Leave AS NUMERIC
		  DECLARE @Total_Weekoff AS NUMERIC
		  DECLARE @Total_OD AS NUMERIC
		  DECLARE @Shift_Name AS VARCHAR(50)
		  DECLARE @Dept_Name AS VARCHAR(50)
		  DECLARE @Segment_Name AS VARCHAR(50) --Added by Rajput 11072017
		  DECLARE @Segment_id AS NUMERIC --Added by Rajput 11072017
		  DECLARE @Total AS NUMERIC
		  DECLARE @shift_total AS NUMERIC
		  DECLARE @Final_shift_total AS NUMERIC
		  
			
			
			DECLARE @temp_Dept_Id AS NUMERIC(18,0)
			IF (@MODE='DEPT')
					BEGIN
							
							create table #deptTable 
							(
							dt_Dept_id  NUMERIC,
							dt_Shift_id  NUMERIC,
							dt_Total  NUMERIC,
							dt_Total_Present  NUMERIC,
							dt_Total_Present_On_Weekoff  NUMERIC, --Added by Rajput 190712017
							dt_Total_Leave  NUMERIC,
							dt_total_OD  NUMERIC,
							dt_total_Absent  NUMERIC,
							dt_Total_Weekoff NUMERIC,
							
							--dt_Segment_id NUMERIC
							)	
							
										insert INTO #deptTable (dt_Dept_id,dt_Shift_id,dt_Total)
										SELECT distinct P.Dept_Id ,P.shift_id,count(p.Emp_id) AS Total FROM @PRESENT P GROUP BY P.dept_id,P.shift_id
											--	SELECT * FROM @PRESENT
										UPDATE #deptTable SET 
										dt_Total_Present =P_day
										FROM #deptTable P INNER JOIN 
										(	
											SELECT COUNT(p.emp_id)P_day,dept_id,shift_id FROM @PRESENT P
											WHERE P.STATUS = 'P' AND IsNull(P.STATUS_2 , '') = '' --Added by Rajput 19072017
											GROUP BY dept_id,shift_id
										) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
										
										UPDATE #deptTable SET 
										dt_Total_Leave = L_day
										FROM #deptTable P INNER JOIN 
										(SELECT COUNT(p.emp_id)L_day,dept_id,shift_id FROM @PRESENT P
										WHERE P.STATUS = 'L' GROUP BY dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
										
										UPDATE #deptTable SET 
										dt_total_OD = OD_day
										FROM #deptTable P INNER JOIN 
										(SELECT COUNT(p.emp_id)OD_day,dept_id,shift_id FROM @PRESENT P
										WHERE P.STATUS = 'OD' GROUP BY dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
										--SELECT * FROM #deptTable
										UPDATE #deptTable SET 
										dt_total_Absent = A_day
										FROM #deptTable P INNER JOIN 
										(SELECT COUNT(p.emp_id)A_day,dept_id,shift_id FROM @PRESENT P
										WHERE P.STATUS = 'A' GROUP BY dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id

										UPDATE #deptTable SET 
										dt_Total_Weekoff = W_day
										FROM #deptTable P INNER JOIN 
										(SELECT COUNT(p.emp_id)W_day,dept_id,shift_id FROM @PRESENT P
										WHERE P.STATUS = 'WO' GROUP BY dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
										
										UPDATE #deptTable SET --Added by Rajput 19072017
										dt_Total_Present_On_Weekoff =P_day
										FROM #deptTable P INNER JOIN 
										(	
											SELECT COUNT(p.emp_id)P_day,dept_id,shift_id FROM @PRESENT P
											WHERE P.STATUS = 'P' AND P.STATUS_2 ='WO'
											GROUP BY dept_id,shift_id
										) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
										
						
					--SELECT * FROM dt1
								--SELECT * FROM @deptTable
								IF exists(SELECT 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt1')
										drop table dt1
									
									IF exists(SELECT 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt2')
										drop table dt2
								
									SELECT distinct dt.dt_Dept_id,dt.dt_Shift_id,IsNull(dt.dt_Total,0) AS Total,  -- IsNull(dt.dt_Total_Present_On_Weekoff,0) AS Total_Present_On_Weekoff Added by Rajput 19072017
										IsNull(dt.dt_Total_Present,0) AS Total_Present,IsNull(dt.dt_Total_Present_On_Weekoff,0) AS Total_Present_On_Weekoff,IsNull(dt.dt_Total_Leave,0)as Total_Leave,
										IsNull(dt.dt_total_OD,0)as Total_OD ,IsNull(dt.dt_total_Absent,0)as Total_Absent,
										IsNull(dt.dt_Total_Weekoff,0) AS Total_Weekoff
									, dm.Dept_Name ,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date AS From_Date,SH.Shift_Name 
									INTO dt1
									FROM #deptTable dt 
									INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IsNull(dm.Dept_id,0) = IsNull(dt.dt_Dept_id ,IsNull(dm.Dept_id,0))
									INNER JOIN T0040_shift_master SH WITH (NOLOCK) ON IsNull(SH.Shift_id,0) = IsNull(dt.dt_Shift_id,IsNull(SH.Shift_id,0))
									INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON IsNull(Cm.Cmp_Id,0) = IsNull(@Cmp_ID,IsNull(Cm.Cmp_Id,0))			
									WHERE  not dt.dt_Dept_id IS NULL AND not dt.dt_Shift_id IS  NULL 
									AND IsNull(dt.dt_Dept_id,0) = IsNull(@Dept_ID,IsNull(dt.dt_Dept_id,0)) 
									AND IsNull(dt.dt_Shift_id,0) = IsNull(@Shift_ID,IsNull(dt.dt_Shift_id,0))
									ORDER BY dt.dt_Shift_id  

			create table #attENDance
			(
				Shift_Name  VARCHAR(150)
				,Dept_id  NUMERIC(18,0)
				,Shift_Id   NUMERIC(18,0)
				,Parameter VARCHAR(MAX)
				,value NUMERIC(18,0)
				,Dept_Name  VARCHAR(150)
				
				--,Segment_id NUMERIC
				--,Segment_Name  VARCHAR(150)
			)		 
					
								DECLARE attENDance CURSOR FOR
									--SELECT distinct dt_Dept_id,dt_Shift_Id,IsNull(Total_Present,0) AS Total_Present,IsNull(Total_Present_On_Weekoff,0) AS Total_Present_On_Weekoff,Total_absent,Total_Weekoff,Shift_Name,Dept_Name,Total,Total_Leave,Total_OD FROM dt1    ---commented by aswini 16012024(because invalid column name in table dt1)
										--SELECT distinct Shift_Name FROM dt1 GROUP BY Shift_Name,dt_Dept_id
										SELECT distinct dt_Dept_id,dt_Shift_Id,IsNull(Total_Present,0) AS Total_Present,Total_absent,Total_Weekoff,Shift_Name,Dept_Name,Total,Total_Leave,Total_OD FROM dt1   --added by aswini 16012024
								OPEN attENDance
								--FETCH NEXT FROM attENDance INTO @Dept_id,@Shift_Id,@Total_Present,@Total_Present_On_Weekoff,@Total_absent,@Total_Weekoff,@Shift_Name,@Dept_Name,@Total,@Total_Leave,@Total_OD  ---commented by aswini 16012024
								FETCH NEXT FROM attENDance INTO @Dept_id,@Shift_Id,@Total_Present,@Total_absent,@Total_Weekoff,@Shift_Name,@Dept_Name,@Total,@Total_Leave,@Total_OD        --added by aswini 16012024
								WHILE @@fetch_STATUS = 0
								BEGIN
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, '$A_Total_Strength',0,@Dept_Name)	
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$A_Appointed',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,REPLACE(@Shift_Name,' ','_') + '$B_Present',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$C_Absent',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$D_WO',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$E_Leave',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$F_OD',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$G_Total',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$H_Deviation',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z1_$_Total_Appointed',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z2_$_Total_Present',0,@Dept_Name)
									
									---commented by aswini 16012024
									--insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name) --Added by Rajput For Employee Present ON Week-off
									--values(@Shift_Name,@Dept_id,@Shift_Id,'z3_$_Total_Present_On_Weekoff',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z4_$_Total_Absent',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z5_$_Total_WO',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z6_$_Total_Leave',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z7_$_Total_OD',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z8_$_Total',0,@Dept_Name)
									
									insert INTO #attENDance(Shift_Name,Dept_id,Shift_Id,Parameter,value,Dept_Name)
									values(@Shift_Name,@Dept_id,@Shift_Id,'z9_$_Total_Deviation',0,@Dept_Name)
											
									--SELECT SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter)) FROM #attENDance 
									UPDATE #attENDance SET value=IsNull(@Total_Present,0) 
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='B_Present'
									
									UPDATE #attENDance SET value=IsNull(@Total_absent ,0)
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='C_Absent'
									
									UPDATE #attENDance SET value=IsNull(@Total_Weekoff,0) 
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='D_WO'
									
									UPDATE #attENDance SET value=IsNull(@Total_Leave,0)
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='E_Leave'
									
									UPDATE #attENDance SET value=IsNull(@Total_OD,0)
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='F_OD'
									
									SET @shift_total=(IsNull(@Total_Present,0) + IsNull(@Total_absent ,0) + IsNull(@Total_Weekoff,0) + IsNull(@Total_Leave,0) + IsNull(@Total_OD,0))
									
									UPDATE #attENDance SET value=@shift_total
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='G_Total'
									
									UPDATE #attENDance SET value=(@Total-@shift_total) 
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='H_Deviation'
									
									--SELECT SUBSTRING(Parameter,CHARINDEX('$',Parameter)+3,LEN(Parameter)) FROM #attENDance
									--WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='A_Employee_Appointed'
									UPDATE #attENDance SET value=@Total
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='A_Appointed'
									
									IF @Dept_id <> @temp_Dept_Id  --IF previous department of shift same than add 
										BEGIN
											SET @temp_Dept_Id=@Dept_id
												
											UPDATE #attENDance  SET value = value + @Total
  											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z1_$_Total_Appointed'
											
											UPDATE #attENDance  SET value = value + @Total_Present
  											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z2_$_Total_Present'
  											---commented by aswini 16012024
  											--UPDATE #attENDance  SET value = value + @Total_Present_On_Weekoff --Added by Rajput 19072017 For Employee Present ON Week-off
  											--WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z3_$_Total_Present_On_Weekoff'
									
											UPDATE #attENDance SET value = value + @Total_absent
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z4_$_Total_Absent'
											
											UPDATE #attENDance SET value = value + @Total_Weekoff
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z5_$_Total_WO'
											
											UPDATE #attENDance SET value = value + @Total_Leave
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z6_$_Total_Leave'
											
											UPDATE #attENDance SET value = value + @Total_OD
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z7_$_Total_OD'
											
											SET @Final_shift_total=(IsNull(@Total_Present,0) + IsNull(@Total_absent ,0) + IsNull(@Total_Weekoff,0) + IsNull(@Total_Leave,0) + IsNull(@Total_OD,0))
											
											UPDATE #attENDance SET value=value + @Final_shift_total
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z8_$_Total'
									
											UPDATE #attENDance SET value=value + (@Total-@Final_shift_total) 
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='z9_$_Total_Deviation'
											
											UPDATE #attENDance SET value=value + @Final_shift_total
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Parameter='$A_Total_Strength'
										END
									ELSE
										BEGIN
											SET @temp_Dept_Id=@Dept_id
											
											UPDATE #attENDance  SET value = value + @Total
  											WHERE Dept_id=@Dept_id  AND Parameter='z1_$_Total_Appointed'
							  				
											UPDATE #attENDance  SET value = value + @Total_Present
  											WHERE Dept_id=@Dept_id  AND Parameter='z2_$_Total_Present'
  											---commented by aswini 16012024
  										 --   UPDATE #attENDance  SET value = value + @Total_Present_On_Weekoff --Added by Rajput 19072017 For Employee Present ON Week-off
  											--WHERE Dept_id=@Dept_id AND Parameter='z3_$_Total_Present_On_Weekoff'
									
									
											UPDATE #attENDance SET value = value + @Total_absent
											WHERE Dept_id=@Dept_id  AND Parameter='z4_$_Total_Absent'
											
											UPDATE #attENDance SET value = value + @Total_Weekoff
											WHERE Dept_id=@Dept_id  AND Parameter='z5_$_Total_WO'
											
											UPDATE #attENDance SET value = value + @Total_Leave
											WHERE Dept_id=@Dept_id AND Parameter='z6_$_Total_Leave'
											
											UPDATE #attENDance SET value = value + @Total_OD
											WHERE Dept_id=@Dept_id AND Parameter='z7_$_Total_OD'
											
											SET @Final_shift_total=(IsNull(@Total_Present,0) + IsNull(@Total_absent ,0) + IsNull(@Total_Weekoff,0) + IsNull(@Total_Leave,0) + IsNull(@Total_OD,0))
											
											UPDATE #attENDance SET value=value +@Final_shift_total
											WHERE Dept_id=@Dept_id AND Parameter='z8_$_Total'
									
											UPDATE #attENDance SET value=value +(@Total-@Final_shift_total) 
											WHERE Dept_id=@Dept_id AND Parameter='z9_$_Total_Deviation'
											
											UPDATE #attENDance SET value=value +@Final_shift_total
											WHERE Dept_id=@Dept_id AND Parameter='$A_Total_Strength'
										END		
											
									--UPDATE #attENDance SET value=sum(@Total_Present)
									--WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('&',Parameter)+1,LEN(Parameter))='Total_Pre'
									--GROUP BY @Total_Present
											
								--FETCH NEXT FROM attENDance INTO @Dept_id,@Shift_Id,@Total_Present,@Total_Present_On_Weekoff,@Total_absent,@Total_Weekoff,@Shift_Name,@Dept_Name,@Total,@Total_Leave,@Total_OD
								FETCH NEXT FROM attENDance INTO @Dept_id,@Shift_Id,@Total_Present,@Total_absent,@Total_Weekoff,@Shift_Name,@Dept_Name,@Total,@Total_Leave,@Total_OD
								
								END
								close attENDance	
								deallocate attENDance
								
		
					 		
						SELECT @columns = COALESCE(@columns + ',[' + cast(Parameter AS VARCHAR(200)) + ']',
										'[' + cast(Parameter AS VARCHAR(200))+ ']')
										FROM #attENDance
										GROUP BY Parameter
										ORDER BY Parameter asc
							
						
							SET @qry1 = 'SELECT * FROM (
								SELECT 
									Dept_Name AS Department,Parameter,value
								FROM #attENDance
							) AS s
							PIVOT
							(
								MAX(value)
								FOR [Parameter] IN (' + @columns + ') 
							)AS m5'
							
						exec (@qry1)						
		END
	ELSE 
			BEGIN
				
				
							create table #deptTablebs 
							(
								dt_Dept_id  NUMERIC,
								dt_Shift_id  NUMERIC,
								dt_Total  NUMERIC,
								dt_Total_Present  NUMERIC,
								dt_Total_Leave  NUMERIC,
								dt_total_OD  NUMERIC,
								dt_total_Absent  NUMERIC,
								dt_Total_Weekoff NUMERIC,
								dt_Segment_id NUMERIC
							)	
				
										insert INTO #deptTablebs (dt_Dept_id,dt_Segment_id,dt_Shift_id,dt_Total)
										SELECT distinct P.Dept_Id ,IsNull(p.segment_id,0), P.shift_id,count(p.Emp_id) AS Total 
										FROM @PRESENT P 
										GROUP BY P.dept_id,P.segment_id,P.shift_id
										
								
										UPDATE #deptTablebs 
										SET dt_Total_Present =P_day
										FROM #deptTablebs P 
											INNER JOIN 
												(
													SELECT COUNT(p.emp_id)P_day,dept_id,IsNull(segment_id,0) AS segment_id,shift_id 
													FROM @PRESENT P
													WHERE P.STATUS = 'P' 
													GROUP BY dept_id,segment_id,shift_id
												) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_segment_id=qry.segment_id AND P.dt_Shift_id = qry.shift_id 
										WHERE dept_id = qry.dept_id AND segment_id=qry.segment_id AND shift_id = qry.shift_id 
										
										UPDATE #deptTablebs 
										SET dt_Total_Leave = L_day
										FROM #deptTablebs P 
										INNER JOIN 
											(
												SELECT COUNT(p.emp_id)L_day,dept_id,IsNull(segment_id,0) AS segment_id,shift_id 
												FROM @PRESENT P
												WHERE P.STATUS = 'L' 
												GROUP BY dept_id,segment_id,shift_id
											) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_segment_id=qry.segment_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND segment_id=qry.segment_id AND shift_id = qry.shift_id
										
										UPDATE #deptTablebs SET 
										dt_total_OD = OD_day
										FROM #deptTablebs P 
										INNER JOIN 
											(
												SELECT COUNT(p.emp_id)OD_day,dept_id,IsNull(segment_id,0) AS segment_id,shift_id 
												FROM @PRESENT P
												WHERE P.STATUS = 'OD' 
												GROUP BY dept_id,segment_id,shift_id
											) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_segment_id=qry.segment_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND segment_id=qry.segment_id AND shift_id = qry.shift_id
										
										--SELECT * FROM #deptTablebs
										UPDATE #deptTablebs SET 
										dt_total_Absent = A_day
										FROM #deptTablebs P
										INNER JOIN 
											(
												SELECT COUNT(p.emp_id)A_day,dept_id,IsNull(segment_id,0) AS segment_id,shift_id 
												FROM @PRESENT P
												WHERE P.STATUS = 'A' 
												GROUP BY dept_id,segment_id,shift_id
											) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_segment_id=qry.segment_id  AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND segment_id=qry.segment_id AND shift_id = qry.shift_id

										UPDATE #deptTablebs SET 
										dt_Total_Weekoff = W_day
										FROM #deptTablebs P
										INNER JOIN 
											(
												SELECT COUNT(p.emp_id)W_day,dept_id,IsNull(segment_id,0) AS segment_id,shift_id 
												FROM @PRESENT P
												WHERE P.STATUS = 'WO'
												GROUP BY dept_id,segment_id,shift_id
											) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_segment_id=qry.segment_id AND P.dt_Shift_id = qry.shift_id
										WHERE dept_id = qry.dept_id AND segment_id=qry.segment_id AND shift_id = qry.shift_id
				
									IF exists(SELECT 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt_business1')
										drop table dt_business1
									
									IF exists(SELECT 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt2')
										drop table dt2
								
									SELECT distinct dt.dt_Dept_id,dt.dt_Segment_id AS dt_Segment_id,dt.dt_Shift_id,IsNull(dt.dt_Total,0) AS Total,
										IsNull(dt.dt_Total_Present,0) AS Total_Present,IsNull(dt.dt_Total_Leave,0)as Total_Leave,
										IsNull(dt.dt_total_OD,0)as Total_OD ,IsNull(dt.dt_total_Absent,0)as Total_Absent,
										IsNull(dt.dt_Total_Weekoff,0) AS Total_Weekoff
									, dm.Dept_Name ,BS.SEGMENT_NAME,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date AS From_Date,SH.Shift_Name 
									INTO dt_business1
									FROM #deptTablebs dt 
									INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IsNull(dm.Dept_id,0) = IsNull(dt.dt_Dept_id ,IsNull(dm.Dept_id,0))
									INNER JOIN T0040_shift_master SH WITH (NOLOCK) ON IsNull(SH.Shift_id,0) = IsNull(dt.dt_Shift_id,IsNull(SH.Shift_id,0))
									INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON IsNull(Cm.Cmp_Id,0) = IsNull(@Cmp_ID,IsNull(Cm.Cmp_Id,0))	
									LEFT OUTER JOIN T0040_BUSINESS_SEGMENT BS WITH (NOLOCK) ON BS.SEGMENT_ID=DT.dt_Segment_id 
									WHERE  
									not dt.dt_Dept_id IS NULL AND not dt.dt_Shift_id IS  NULL 
									AND IsNull(dt.dt_Dept_id,0) = IsNull(@Dept_ID,IsNull(dt.dt_Dept_id,0)) 
									AND IsNull(dt.dt_Shift_id,0) = IsNull(@Shift_ID,IsNull(dt.dt_Shift_id,0))
									AND IsNull(dt.dt_Shift_id,0) = IsNull(@Shift_ID,IsNull(dt.dt_Shift_id,0))
									ORDER BY dt.dt_Shift_id


			create table #attENDancebs
			(
				Shift_Name  VARCHAR(150)
				,Dept_id  NUMERIC(18,0)
				,Shift_Id   NUMERIC(18,0)
				,Parameter VARCHAR(MAX)
				,value NUMERIC(18,0)
				,Dept_Name  VARCHAR(150)
				,Segment_id NUMERIC
				,Segment_Name  VARCHAR(150)
			)		 
								

								DECLARE attENDance CURSOR FOR
									SELECT distinct dt_Dept_id,IsNull(dt_Segment_id,0) AS dt_Segment_id ,dt_Shift_Id,IsNull(Total_Present,0) AS Total_Present,Total_absent,Total_Weekoff,Shift_Name,Dept_Name,Segment_Name,Total,Total_Leave,Total_OD 
									FROM dt_business1 
									
										--SELECT distinct Shift_Name FROM dt1 GROUP BY Shift_Name,dt_Dept_id
								OPEN attENDance
								FETCH NEXT FROM attENDance INTO @Dept_id,@Segment_id,@Shift_Id,@Total_Present,@Total_absent,@Total_Weekoff,@Shift_Name,@Dept_Name,@Segment_Name,@Total,@Total_Leave,@Total_OD
								WHILE @@fetch_STATUS = 0
								BEGIN
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, '$A_Total_Strength',0,@Dept_Name,@Segment_Name)	
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$A_Appointed',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,REPLACE(@Shift_Name,' ','_') + '$B_Present',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$C_Absent',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$D_WO',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$E_Leave',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$F_OD',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$G_Total',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id, REPLACE(@Shift_Name,' ','_') + '$H_Deviation',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z1_$_Total_Appointed',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z2_$_Total_Present',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z3_$_Total_Absent',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z4_$_Total_WO',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z5_$_Total_Leave',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z6_$_Total_OD',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z7_$_Total',0,@Dept_Name,@Segment_Name)
									
									insert INTO #attENDancebs(Shift_Name,Dept_id,Segment_id,Shift_Id,Parameter,value,Dept_Name,Segment_Name)
									values(@Shift_Name,@Dept_id,@Segment_id,@Shift_Id,'z8_$_Total_Deviation',0,@Dept_Name,@Segment_Name)
											
									--SELECT SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter)) FROM #attENDance 
									UPDATE #attENDancebs SET value=IsNull(@Total_Present,0) 
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id
									AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='B_Present'
									
									UPDATE #attENDancebs SET value=IsNull(@Total_absent ,0)
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='C_Absent'
									
									UPDATE #attENDancebs SET value=IsNull(@Total_Weekoff,0) 
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='D_WO'
									
									UPDATE #attENDancebs SET value=IsNull(@Total_Leave,0)
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='E_Leave'
									
									UPDATE #attENDancebs SET value=IsNull(@Total_OD,0)
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='F_OD'
									
									SET @shift_total=(IsNull(@Total_Present,0) + IsNull(@Total_absent ,0) + IsNull(@Total_Weekoff,0) + IsNull(@Total_Leave,0) + IsNull(@Total_OD,0))
									
									UPDATE #attENDancebs SET value=@shift_total
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='G_Total'
									
									UPDATE #attENDancebs SET value=(@Total-@shift_total) 
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='H_Deviation'
									
									--SELECT SUBSTRING(Parameter,CHARINDEX('$',Parameter)+3,LEN(Parameter)) FROM #attENDancebs
									--WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='A_Employee_Appointed'
									UPDATE #attENDancebs SET value=@Total
									WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND SUBSTRING(Parameter,CHARINDEX('$',Parameter)+1,LEN(Parameter))='A_Appointed'
									
									IF @Dept_id <> @temp_Dept_Id  --IF previous department of shift same than add 
										BEGIN
											SET @temp_Dept_Id=@Dept_id
												
											UPDATE #attENDancebs  SET value = value + @Total
  											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z1_$_Total_Appointed'
											
											UPDATE #attENDancebs  SET value = value + @Total_Present
  											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z2_$_Total_Present'
									
											UPDATE #attENDancebs SET value = value + @Total_absent
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z3_$_Total_Absent'
											
											UPDATE #attENDancebs SET value = value + @Total_Weekoff
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z4_$_Total_WO'
											
											UPDATE #attENDancebs SET value = value + @Total_Leave
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z5_$_Total_Leave'
											
											UPDATE #attENDancebs SET value = value + @Total_OD
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z6_$_Total_OD'
											
											SET @Final_shift_total=(IsNull(@Total_Present,0) + IsNull(@Total_absent ,0) + IsNull(@Total_Weekoff,0) + IsNull(@Total_Leave,0) + IsNull(@Total_OD,0))
											
											UPDATE #attENDancebs SET value=value + @Final_shift_total
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z7_$_Total'
									
											UPDATE #attENDancebs SET value=value + (@Total-@Final_shift_total) 
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='z8_$_Total_Deviation'
											
											UPDATE #attENDancebs SET value=value + @Final_shift_total
											WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND Segment_id=@Segment_id AND Parameter='$A_Total_Strength'
										END
									ELSE
										BEGIN
											SET @temp_Dept_Id=@Dept_id
											
											UPDATE #attENDancebs  SET value = value + @Total
  											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id  AND Parameter='z1_$_Total_Appointed'
							  				
											UPDATE #attENDancebs  SET value = value + @Total_Present
  											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id  AND Parameter='z2_$_Total_Present'
									
											UPDATE #attENDancebs SET value = value + @Total_absent
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id  AND Parameter='z3_$_Total_Absent'
											
											UPDATE #attENDancebs SET value = value + @Total_Weekoff
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id  AND Parameter='z4_$_Total_WO'
											
											UPDATE #attENDancebs SET value = value + @Total_Leave
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id AND Parameter='z5_$_Total_Leave'
											
											UPDATE #attENDancebs SET value = value + @Total_OD
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id AND Parameter='z6_$_Total_OD'
											
											SET @Final_shift_total=(IsNull(@Total_Present,0) + IsNull(@Total_absent ,0) + IsNull(@Total_Weekoff,0) + IsNull(@Total_Leave,0) + IsNull(@Total_OD,0))
											
											UPDATE #attENDancebs SET value=value +@Final_shift_total
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id AND Parameter='z7_$_Total'
									
											UPDATE #attENDancebs SET value=value +(@Total-@Final_shift_total) 
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id AND Parameter='z8_$_Total_Deviation'
											
											UPDATE #attENDancebs SET value=value +@Final_shift_total
											WHERE Dept_id=@Dept_id AND Segment_id=@Segment_id AND Parameter='$A_Total_Strength'
										END		
											
									--UPDATE #attENDance SET value=sum(@Total_Present)
									--WHERE Dept_id=@Dept_id AND Shift_Id=@Shift_Id AND SUBSTRING(Parameter,CHARINDEX('&',Parameter)+1,LEN(Parameter))='Total_Pre'
									--GROUP BY @Total_Present
											
								FETCH NEXT FROM attENDance INTO @Dept_id,@Segment_id,@Shift_Id,@Total_Present,@Total_absent,@Total_Weekoff,@Shift_Name,@Dept_Name,@Segment_Name,@Total,@Total_Leave,@Total_OD
								END
								close attENDance	
								deallocate attENDance
						
						SELECT @columns = COALESCE(@columns + ',[' + cast(Parameter AS VARCHAR(200)) + ']',
										'[' + cast(Parameter AS VARCHAR(200))+ ']')
										FROM #attENDancebs
										GROUP BY Parameter
										ORDER BY Parameter asc
						
		
							SET @qry1 = 'SELECT * FROM (
														SELECT 
															Dept_Name AS Department,Segment_Name AS [$A_Business_Segment], Parameter,value
														FROM #attENDancebs 
														) AS s
														PIVOT
														(
															MAX(value)
															FOR [Parameter] IN (' + @columns + ') 
														)AS m5
										ORDER BY Department'
							
						exec (@qry1)
			

			END

END	 


create table #tmp_cols(id int identity, col_Name VARCHAR(128), col_group VARCHAR(128), Sort_Index int)
			
IF (@MODE='DEPT')			
	insert INTO #tmp_cols (col_Name, col_group)
	SELECT	substring(Parameter, CHARINDEX('$', Parameter) + 1, len(Parameter)) AS col_Name, 
			substring(Parameter, 0, CHARINDEX('$', Parameter)) AS col_group
	FROM (SELECT DISTINCT Parameter FROM  #attENDance) T
ELSE
	BEGIN
		insert INTO #tmp_cols (col_Name, col_group)
		SELECT	substring(Parameter, CHARINDEX('$', Parameter) + 1, len(Parameter)) AS col_Name, 
				substring(Parameter, 0, CHARINDEX('$', Parameter)) AS col_group
		FROM (SELECT DISTINCT Parameter FROM  #attENDancebs) T

		insert INTO #tmp_cols (col_Name, col_group)
		values('Business_Segment', '');
	END

insert INTO #tmp_cols (col_Name, col_group)
values('Department', '');

UPDATE	#tmp_cols
SET  Sort_Index = 0
where	col_group=''

UPDATE	#tmp_cols
SET  col_group = 'Shift Total',
		Sort_Index = 999
Where	col_group like 'z[0-9]_'

UPDATE	#tmp_cols
SET  col_group = LTRIM(REPLACE(col_group, '_', ' ')),
		col_Name = LTRIM(REPLACE(col_Name, '_', ' '))

UPDATE	T
SET  SORT_INDEX = ROW_ID
FROM #tmp_cols T
		INNER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY col_group) AS ROW_ID, COL_GROUP FROM #tmp_cols WHERE col_group NOT IN ('', 'Shift Total') GROUP BY col_group) T1 ON t.col_group=t1.COL_GROUP
WHERE	T.col_group NOT IN ('', 'Shift Total')

DECLARE @Template VARCHAR(MAX)

SET @Template  = '<table style="border:solid 1px;">'

SELECT	@Template = @Template + '<td style="border:1 solid black;" align="center" colspan="' + cast(C_COUNT AS VARCHAR(5)) + '"><b>' + C_NAME + '</b></td>'
FROM (SELECT COUNT(1) AS C_COUNT, COL_GROUP AS C_NAME, SORT_INDEX FROM #tmp_cols GROUP BY col_group, SORT_INDEX) T
ORDER BY SORT_INDEX	

SET @Template  = @Template  + '</table>'

SELECT @Template

	IF exists(SELECT 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt1')
		drop table dt1
									
	IF exists(SELECT 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt2')
		drop table dt2RETURN
