
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_DAILY_ATTENDANCE_GET_New]
	@Cmp_ID 			numeric
	,@FROM_Date			datetime
	,@To_Date 			datetime 
	,@Branch_ID			numeric
	,@Cat_ID 			numeric 
	,@Grd_ID 			numeric
	,@Type_ID 			numeric
	,@Dept_ID 			numeric
	,@Desig_ID 			numeric
	,@Emp_ID 			numeric
	,@Shift_ID          numeric
	,@constraint 		varchar(5000)
	,@Format            numeric
	,@PBranch_ID        varchar(200) = '0'
	
	,@SubBranch_Id		numeric
	,@BusSegement_Id	numeric
	,@SalCyc_Id			numeric
	,@Vertical_Id		numeric
	,@SubVertical_Id	numeric
	
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @To_Date = @FROM_Date

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
	If @Shift_ID = 0
		SET @Shift_ID = NULL
	If @Cmp_ID = 0
		SET @Cmp_ID = NULL
		
	If @SubBranch_Id = 0
		SET @SubBranch_Id = NULL
	If @BusSegement_Id = 0
		SET @BusSegement_Id = NULL
	If @SalCyc_Id = 0
		SET @SalCyc_Id = NULL
	If @Vertical_Id = 0
		SET @Vertical_Id = NULL
	If @SubVertical_Id = 0
		SET @SubVertical_Id = NULL
		
		
 --Declare @Emp_Cons Table        
 --(        
 -- Emp_ID numeric        
 --)        
		
 --if @Constraint <> ''        
 -- begin        
 --  Insert Into @Emp_Cons(Emp_ID)        
 --  SELECT  cast(data  AS numeric) FROM dbo.Split (@Constraint,'#')         
 -- end        
 --else        
 -- begin        
              
 --  if @PBranch_ID <> '0' AND IsNull(@Branch_ID,0) = 0
 --   Begin         
 --    Insert Into @Emp_Cons(Emp_ID)

	--		SELECT I.Emp_Id FROM dbo.T0095_Increment I INNER JOIN 
	--				( SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM dbo.T0095_Increment
	--				WHERE Increment_Effective_date <= @To_Date
	--				AND Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date	
	--		WHERE Cmp_ID = IsNull(@Cmp_ID,Cmp_ID) 
	--		AND IsNull(Cat_ID,0) = IsNull(@Cat_ID ,IsNull(Cat_ID,0))
	--		--AND Branch_ID = IsNull(@Branch_ID ,Branch_ID)
	--		AND Branch_ID in (SELECT cast(IsNull(data,0) AS numeric) FROM dbo.Split(@PBranch_ID,'#'))
	--		AND Grd_ID = IsNull(@Grd_ID ,Grd_ID)
	--		AND IsNull(Dept_ID,0) = IsNull(@Dept_ID ,IsNull(Dept_ID,0))
	--		AND IsNull(Type_ID,0) = IsNull(@Type_ID ,IsNull(Type_ID,0))
	--		AND IsNull(Desig_ID,0) = IsNull(@Desig_ID ,IsNull(Desig_ID,0))
			
	--		AND IsNull(subBranch_ID,0) = IsNull(@SubBranch_Id ,IsNull(subBranch_ID,0))
	--		AND IsNull(Segment_ID,0) = IsNull(@BusSegement_Id ,IsNull(Segment_ID,0))
	--		AND IsNull(SalDate_id,0) = IsNull(@SalCyc_Id ,IsNull(SalDate_id,0))
	--		AND IsNull(Vertical_ID,0) = IsNull(@Vertical_Id ,IsNull(Vertical_ID,0))
	--		AND IsNull(SubVertical_ID,0) = IsNull(@SubVertical_Id ,IsNull(SubVertical_ID,0))
			
	--		AND I.Emp_ID = IsNull(@Emp_ID ,I.Emp_ID) 
	--		AND I.Emp_ID in (SELECT emp_Id FROM
	--				(SELECT emp_id, Cmp_ID, join_Date, IsNull(left_Date, @To_Date) AS left_Date FROM dbo.T0110_EMP_LEFT_JOIN_TRAN) qry
	--				WHERE Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)   AND  
	--				(( @FROM_Date  >= join_Date  AND  @FROM_Date <= left_date ) 
	--				or ( @FROM_Date <= join_Date  AND @To_Date >= left_date )	
	--				or ( @To_Date  >= join_Date  AND @To_Date <= left_date )
	--				or left_date is NULL AND  @To_Date >= Join_Date)) 
				
 --  end 
 -- else
 --  Begin
 --    Insert Into @Emp_Cons(Emp_ID)

	--		SELECT I.Emp_Id FROM dbo.T0095_Increment I INNER JOIN 
	--				( SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM dbo.T0095_Increment
	--				WHERE Increment_Effective_date <= @To_Date
	--				AND Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date	
							
	--		WHERE Cmp_ID = IsNull(@Cmp_ID,Cmp_ID) 
	--		AND IsNull(Cat_ID,0) = IsNull(@Cat_ID ,IsNull(Cat_ID,0))
	--		AND Branch_ID = IsNull(@Branch_ID ,Branch_ID)			
	--		AND Grd_ID = IsNull(@Grd_ID ,Grd_ID)
	--		AND IsNull(Dept_ID,0) = IsNull(@Dept_ID ,IsNull(Dept_ID,0))
	--		AND IsNull(Type_ID,0) = IsNull(@Type_ID ,IsNull(Type_ID,0))
	--		AND IsNull(Desig_ID,0) = IsNull(@Desig_ID ,IsNull(Desig_ID,0))
			
	--		AND IsNull(subBranch_ID,0) = IsNull(@SubBranch_Id ,IsNull(subBranch_ID,0))
	--		AND IsNull(Segment_ID,0) = IsNull(@BusSegement_Id ,IsNull(Segment_ID,0))
	--		AND IsNull(SalDate_id,0) = IsNull(@SalCyc_Id ,IsNull(SalDate_id,0))
	--		AND IsNull(Vertical_ID,0) = IsNull(@Vertical_Id ,IsNull(Vertical_ID,0))
	--		AND IsNull(SubVertical_ID,0) = IsNull(@SubVertical_Id ,IsNull(SubVertical_ID,0))
			
	--		AND I.Emp_ID = IsNull(@Emp_ID ,I.Emp_ID) 
	--		AND I.Emp_ID in (SELECT emp_Id FROM
	--				(SELECT emp_id, Cmp_ID, join_Date, IsNull(left_Date, @To_Date) AS left_Date FROM dbo.T0110_EMP_LEFT_JOIN_TRAN) qry
	--				WHERE Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)   AND  
	--				(( @FROM_Date  >= join_Date  AND  @FROM_Date <= left_date ) 
	--				or ( @FROM_Date <= join_Date  AND @To_Date >= left_date )	
	--				or ( @To_Date  >= join_Date  AND @To_Date <= left_date )
	--				or left_date is NULL AND  @To_Date >= Join_Date))
 --  end      
 -- end        

  		
	
	CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   	
	 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@FROM_Date=@FROM_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,
			@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@Constraint=@Constraint,@Sal_Type=0,@Salary_Cycle_ID=@SalCyc_Id,@Segment_ID=@BusSegement_Id,
			@Vertical_Id=@Vertical_Id,@SubVertical_Id = @SubVertical_Id,@SubBranch_Id=@SubBranch_Id,@New_Join_emp=0,@Left_Emp=0,@SalScyle_Flag=2,@PBranch_ID=@PBranch_ID 


	DECLARE @PRESENT TABLE  
	(  
		EMP_ID   NUMERIC,  
		EMP_CODE  varchar(100),  
		EMP_FULL_NAME VARCHAR(100),  
		IN_TIME   DATETIME,  
		STATUS   CHAR(2),
		type     varchar(50),
		Type_Name varchar(100)  ,
		branch_id numeric,
		shift_id numeric,
		dept_id numeric,
		Desig_Id Numeric 
	)  

	

	/*Following Query Modified by Nimesh ON 21-Sep-2017 (No need to apply condition for GradeID, BranchID, DesigID, etc. #EmpCons has already filtered employee detail)*/
	if IsNull(@Cmp_ID,0) = 0
		begin
			-- For Appointed Employee, Added by Hardik 13/09/2012
			INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME)   
			SELECT	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name 
			FROM	dbo.T0095_Increment I WITH (NOLOCK)					
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) ON I.Emp_ID = Em.Emp_ID
					INNER JOIN #Emp_Cons ec ON ec.Emp_ID = Em.Emp_ID AND I.Increment_ID=EC.Increment_ID
					INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON I.Cmp_ID=C.Cmp_Id AND C.is_GroupOFCmp=1
			--WHERE	IsNull(I.Type_ID,0) = IsNull(@Type_ID,IsNull(I.Type_ID,0))			
			--		AND IsNull(I.Dept_ID,0) = IsNull(@Dept_ID ,IsNull(I.Dept_ID,0))   
			--		AND IsNull(I.Desig_Id,0) = IsNull(@Desig_ID,IsNull(I.Desig_Id,0))  
			--		AND IsNull(I.Grd_ID,0) = IsNull(@Grd_ID,IsNull(I.Grd_ID,0))  
			--		AND IsNull(I.Cat_ID,0) = IsNull(@Cat_ID,IsNull(I.Cat_ID,0)) 
			--		AND IsNull(I.Branch_ID,0) =IsNull(@Branch_ID,IsNull(I.Branch_ID,0)) 
		
			--		AND IsNull(I.subBranch_ID,0) = IsNull(@SubBranch_Id ,IsNull(I.subBranch_ID,0))
			--		AND IsNull(I.Segment_ID,0) = IsNull(@BusSegement_Id ,IsNull(I.Segment_ID,0))
			--		AND IsNull(I.SalDate_id,0) = IsNull(@SalCyc_Id ,IsNull(I.SalDate_id,0))
			--		AND IsNull(I.Vertical_ID,0) = IsNull(@Vertical_Id ,IsNull(I.Vertical_ID,0))
			--		AND IsNull(I.SubVertical_ID,0) = IsNull(@SubVertical_Id ,IsNull(I.SubVertical_ID,0))
		
			--		AND (em.Emp_Left_Date is NULL or em.Emp_Left_Date > @FROM_Date)
			--		AND (em.Date_Of_Join <= @FROM_Date)
					--AND i.Cmp_ID in (SELECT Cmp_Id FROM T0010_COMPANY_MASTER WHERE is_GroupOFCmp = 1)
		END
	ELSE
		BEGIN
			INSERT	INTO @PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME)   
			SELECT	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name 
			FROM	dbo.T0095_Increment I WITH (NOLOCK)					
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) ON I.Emp_ID = Em.Emp_ID
					INNER JOIN #Emp_Cons ec ON ec.Emp_ID = Em.Emp_ID AND I.Increment_ID=EC.Increment_ID
					INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON I.Cmp_ID=C.Cmp_Id AND C.is_GroupOFCmp=1
			--WHERE	IsNull(I.Type_ID,0) = IsNull(@Type_ID,IsNull(I.Type_ID,0)) 
			--		AND IsNull(I.Dept_ID,0) = IsNull(@Dept_ID ,IsNull(I.Dept_ID,0))   
			--		AND IsNull(I.Desig_Id,0) = IsNull(@Desig_ID,IsNull(I.Desig_Id,0))  
			--		AND IsNull(I.Grd_ID,0) = IsNull(@Grd_ID,IsNull(I.Grd_ID,0))  
			--		AND IsNull(I.Cat_ID,0) = IsNull(@Cat_ID,IsNull(I.Cat_ID,0)) 
			--		AND IsNull(I.Branch_ID,0) =IsNull(@Branch_ID,IsNull(I.Branch_ID,0)) 
	
			--		AND IsNull(I.subBranch_ID,0) = IsNull(@SubBranch_Id ,IsNull(I.subBranch_ID,0))
			--		AND IsNull(I.Segment_ID,0) = IsNull(@BusSegement_Id ,IsNull(I.Segment_ID,0))
			--		AND IsNull(I.SalDate_id,0) = IsNull(@SalCyc_Id ,IsNull(I.SalDate_id,0))
			--		AND IsNull(I.Vertical_ID,0) = IsNull(@Vertical_Id ,IsNull(I.Vertical_ID,0))
			--		AND IsNull(I.SubVertical_ID,0) = IsNull(@SubVertical_Id ,IsNull(I.SubVertical_ID,0))
	
			--		AND (em.Emp_Left_Date is NULL or em.Emp_Left_Date > @FROM_Date)
			--		AND (em.Date_Of_Join <= @FROM_Date)
		END
	  


	UPDATE	P 
	SET		IN_TIME = T.In_Time,
			STATUS = 'P' 
	FROM	@PRESENT P 
			INNER JOIN T0150_EMP_INOUT_RECORD T ON P.EMP_ID = T.Emp_ID AND T.For_Date = @FROM_Date
	WHERE	MONTH(T.in_time)= MONTH(@FROM_Date) 
			AND YEAR(T.in_time) = YEAR(@FROM_Date) 
			AND DAY(T.in_time)  = DAY(@FROM_Date) 
  

	DELETE	@PRESENT 
	FROM	(SELECT S.Emp_ID, IN_TIME,ROW_NUMBER() OVER (PARTITION BY S.Emp_Id ORDER BY S.Emp_Id) AS NR
			FROM	@PRESENT S) Q	
			INNER JOIN @PRESENT P ON Q.EMP_ID = P.EMP_ID AND Q.IN_TIME = P.IN_TIME  
	WHERE	Q.NR > 1 



	UPDATE	P 
	SET		STATUS = 'L' 
	FROM	@PRESENT P 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL LA ON P.EMP_ID = LA.Emp_ID 
			INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID 
			LEFT OUTER JOIN dbo.T0150_LEAVE_CANCELLATION AS LC ON lad.Leave_Approval_ID =Lc.Leave_Approval_ID 
			INNER JOIN dbo.T0140_LEAVE_TRANSACTION LT ON LT.For_Date = @FROM_Date AND LAD.Leave_ID = LT.Leave_ID AND LA.Emp_ID = LT.Emp_ID -- added by Gadriwala 28022014( with Approved Hardikbhai)
	WHERE	LAD.FROM_Date < = @FROM_Date AND LAD.To_Date >= @FROM_Date AND LA.Approval_Status='A' 
			AND Leave_Type <> 'Company Purpose' AND IsNull(LC.Is_Approve,0)=0 AND STATUS Is NULL AND Leave_Used > 0


	UPDATE	P 
	SET		STATUS = 'OD' 
	FROM	@PRESENT P 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL LA ON P.EMP_ID = LA.Emp_ID 
			INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID 
			LEFT OUTER JOIN dbo.T0150_LEAVE_CANCELLATION AS LC ON lad.Leave_Approval_ID =Lc.Leave_Approval_ID
	WHERE	LAD.FROM_Date < = @FROM_Date AND LAD.To_Date >= @FROM_Date AND LA.Approval_Status='A' 
			AND Leave_Type = 'Company Purpose' AND IsNull(Is_Approve,0)=0 AND STATUS Is NULL


	
	UPDATE	P
	SET		STATUS = 'A' 
	FROM	@PRESENT P
	WHERE	STATUS Is NULL AND P.IN_TIME Is NULL

 -- Declare @Is_Cancel_Weekoff  Numeric(1,0)
 -- Declare @Left_Date		datetime  
 -- Declare @join_dt   		datetime  
 -- Declare @StrHoliday_Date  varchar(MAX)    
 -- Declare @StrWeekoff_Date  varchar(MAX)
 -- Declare @Cancel_Weekoff	numeric(18, 0)
 -- Declare @WO_Days	numeric
  
 -- SET @Is_Cancel_Weekoff = 0 
 -- SET @StrHoliday_Date = ''    
 -- SET @StrWeekoff_Date = ''  
  
 -- If @Branch_ID is NULL
	--	Begin 
	--		SELECT Top 1 @Is_Cancel_Weekoff = Is_Cancel_Weekoff FROM T0040_GENERAL_SETTING WHERE cmp_ID = @cmp_ID    
	--		AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= GETDATE() AND Cmp_ID = @Cmp_ID)    
	--	End
	--Else
	--	Begin
	--		SELECT @Is_Cancel_Weekoff = Is_Cancel_Weekoff FROM T0040_GENERAL_SETTING WHERE cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID    
	--		AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WHERE For_Date <= GETDATE() AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)    
	--	End

	--Declare @Cmp_Id_Cur AS Numeric

	-- Declare cur cursor for 
	--	SELECT EMP_ID FROM @PRESENT WHERE Status ='A'
	--  Open cur
	--  Fetch Next FROM cur into @Emp_ID
	  
	--  While @@FETCH_STATUS = 0
	--	Begin
	--		SELECT @join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date,@Cmp_Id_Cur = Cmp_ID 
	--		FROM T0080_EMP_MASTER WHERE Emp_ID=@Emp_ID
				
			
			
	--		Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_Id_Cur,@FROM_Date,@FROM_Date,@join_dt,@left_Date,@Is_Cancel_weekoff,'',@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
			
	--		If charindex(CONVERT(VARCHAR(11),@FROM_Date,109),@StrWeekoff_Date,0) > 0
	--			Begin
	--				UPDATE @PRESENT Set
	--					 STATUS='WO'
	--					,type='<font color="Green">' + 'WO' + '</font>'
	--				WHERE EMP_ID = @Emp_ID AND STATUS = 'A'
					
	--			End
			
	--		SET @StrHoliday_Date = ''    
	--		SET @StrWeekoff_Date = ''  
	  
	--		Fetch Next FROM cur into @Emp_ID
	--	End
	  
	--  Close cur
	--  Deallocate cur

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
				
				EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@FROM_Date, @All_Weekoff = 0, @Exec_Mode=1	
			END

	UPDATE	P
	Set		STATUS='WO',
			type='<font color="Green">WO</font>'
	FROM	@PRESENT P 
			INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID AND W.For_Date=@FROM_Date
	WHERE	P.EMP_ID = @Emp_ID AND STATUS = 'A'

	UPDATE	P 
	SET		branch_id = I.Branch_ID, 
			dept_id = I.Dept_ID, 
			Desig_Id = I.Desig_Id
	FROM	@PRESENT  P
			INNER JOIN T0095_INCREMENT I ON P.EMP_ID=P.EMP_ID
			INNER JOIN #Emp_Cons EC ON I.Increment_ID=EC.Increment_ID

			--INNER JOIN (SELECT	Branch_ID,I.Emp_ID,I.Dept_ID,I.Desig_Id			
			--			FROM	T0095_Increment I 
			--					INNER JOIN (SELECT	MAX(Increment_effective_Date) AS For_Date, Emp_ID 
			--								FROM	T0095_Increment    
			--	 WHERE Increment_Effective_date <= @To_Date
			--	 AND Cmp_ID = IsNull(@Cmp_ID,Cmp_ID)
			--	 group by emp_ID) Qry ON    
			--	 I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date) Inc ON Inc.Emp_ID = p.EMP_ID
	
	--Fetching default shift id 
	UPDATE	P
	SET		shift_id = Shf.Shift_ID
	FROM	@PRESENT  P
			INNER JOIN (SELECT	ESD.Shift_ID,ESD.Emp_ID 
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(For_Date) AS For_Date,Emp_ID 
											FROM	T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
											WHERE	Cmp_ID = IsNull(@Cmp_ID,Cmp_ID) AND For_Date <= @To_Date 
											GROUP BY Emp_ID
											) S ON ESD.Emp_ID = S.Emp_ID AND ESD.For_Date=S.For_Date
						) Shf ON Shf.Emp_ID = p.EMP_ID 
		
	--Added by Nimesh 21 May, 2015
	--The priory of table for employee's shift id is Emp_Shift_Detail=> Rotation=> Default Shift
	--overwriting rotation shift id if assigned.
	--Generating temp table for Employee Shift Rotation
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		CREATE TABLE #Rotation(R_EmpID numeric(18,0),R_ShiftID numeric(18,0),R_DayName varchar(25),R_Effective_Date DateTime);
	--This will retrieve all employees shift rotation  		
	EXEC P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint
	
	--Updating @PRESENT table for Shift_ID
	UPDATE	@PRESENT SET SHIFT_ID=R_ShiftID
	FROM	#Rotation R 
	WHERE	R.R_EmpID=EMP_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) AS Varchar)
			AND R.R_Effective_Date=(
										SELECT	MAX(R_Effective_Date) FROM #Rotation 
										WHERE	R_Effective_Date <=@To_Date
									)						

	--UPDATE Shift ID AS per the assigned shift in shift detail 
	--Retrieve the shift id FROM employee shift changed detail table
	UPDATE	@PRESENT SET SHIFT_ID = Shf.Shift_ID
	FROM	@PRESENT  p 
			INNER JOIN (
						SELECT	ESD.Shift_ID, ESD.Emp_ID 
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
						WHERE	ESD.Emp_ID IN (
									Select	R.R_EmpID FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) AS Varchar) 													
									GROUP BY R.R_EmpID
								)
								AND ESD.For_Date=@To_Date AND ESD.Cmp_ID=@Cmp_ID
						) Shf ON Shf.Emp_ID = p.EMP_ID
				
	--if the rotation is not assigned the only those shift should be assigned which shift_type is 1
	UPDATE	@PRESENT SET SHIFT_ID = Shf.Shift_ID
	FROM	@PRESENT  p 
			INNER JOIN (
						SELECT	ESD.Shift_ID, ESD.Emp_ID 
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
						WHERE	ESD.Emp_ID NOT IN (
									Select	R.R_EmpID FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) AS Varchar) 													
									GROUP BY R.R_EmpID
								)
								AND ESD.For_Date=@To_Date AND ESD.Cmp_ID=@Cmp_ID AND IsNull(ESD.Shift_Type,0)=1 
						) Shf ON Shf.Emp_ID = p.EMP_ID
	--End Nimesh
					
	Declare @Emp_Id_T Numeric
	Declare @In_Time Datetime
	Declare @New_Shift_Id Numeric


	Declare curautoshift cursor Fast_forward for  
		SELECT EMP_ID,IN_TIME FROM @PRESENT P INNER JOIN T0040_SHIFT_MASTER S WITH (NOLOCK) ON P.Shift_id = S.Shift_Id
			WHERE s.Inc_Auto_Shift = 1 AND STATUS = 'P'
	Open curautoshift                      
	  Fetch next FROM curautoshift into @Emp_ID_T,@In_Time
		While @@fetch_status = 0                    
			Begin     
						If Exists(SELECT 1 FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
									DateAdd(ss,-14400,Cast(CAST(@In_Time AS varchar(11)) + ' ' + Shift_St_Time AS datetime)) <= @In_Time And
									DateAdd(ss,14400,Cast(CAST(@In_Time AS varchar(11)) + ' ' + Shift_St_Time AS datetime)) >= @In_Time AND Inc_Auto_Shift = 1 )
							Begin
								SELECT @New_Shift_Id = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
									DateAdd(ss,-14400,Cast(CAST(@In_Time AS varchar(11)) + ' ' + Shift_St_Time AS datetime)) <= @In_Time And
									DateAdd(ss,14400,Cast(CAST(@In_Time AS varchar(11)) + ' ' + Shift_St_Time AS datetime)) >= @In_Time AND Inc_Auto_Shift = 1 
								ORDER BY ABS( DATEDIFF(ss,@In_Time,cast(@In_Time AS varchar(11)) + ' ' + Shift_St_Time)) desc 
									
								
								UPDATE @PRESENT SET shift_id = @New_Shift_Id WHERE EMP_ID = @Emp_Id_T AND In_Time = @In_Time
							End

				Fetch next FROM curautoshift into @Emp_ID_T,@In_Time
			End
	Close curautoshift
	Deallocate curautoshift
		
	
	If @Format = 0 
		Begin
			SELECT SUM (Total_Present) AS Total_Present,SUM(Total_Absent) AS Total_Absent, SUM(Total_Present + Total_Absent) AS EmpCnt FROM (
			SELECT 
			--distinct  
			distinct  sm.Shift_ID ,SM.Shift_Name ,
			( SELECT COUNT(*) FROM @PRESENT p1 WHERE p1.shift_id = SM.Shift_ID )  AS Total, 
			( SELECT COUNT(*) FROM @PRESENT p2 WHERE p2.shift_id = SM.Shift_ID AND p2.STATUS = 'P' ) AS Total_Present , 
			( SELECT COUNT(*) FROM @PRESENT p3 WHERE p3.shift_id = SM.Shift_ID AND p3.STATUS = 'L' ) AS Total_Leave , 
			( SELECT COUNT(*) FROM @PRESENT p4 WHERE p4.shift_id = SM.Shift_ID AND p4.STATUS = 'OD' ) AS Total_OD ,
			( SELECT COUNT(*) FROM @PRESENT p5 WHERE p5.shift_id = SM.Shift_ID AND p5.STATUS = 'A' ) AS Total_Absent,
			( SELECT COUNT(*) FROM @PRESENT p6 WHERE p6.shift_id = SM.Shift_ID AND p6.STATUS = 'WO' ) AS Total_Weekoff
			FROM @PRESENT P	INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK)
			on SM.Shift_ID = P.shift_id 
			INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON IsNull(Cm.Cmp_Id,0) = IsNull(@Cmp_ID,IsNull(Cm.Cmp_Id,0)) 
			WHERE IsNull(P.shift_id,0)  = IsNull(@Shift_ID,IsNull(P.Shift_Id,0)) ) AS temp
		Return
	End
	



