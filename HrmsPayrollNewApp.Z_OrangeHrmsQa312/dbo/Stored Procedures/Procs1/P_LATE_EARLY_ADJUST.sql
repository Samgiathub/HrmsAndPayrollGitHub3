

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 01-Mar-2019
-- Description:	This procedure is used to generate the detail for Late Adjustment with Leave
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_LATE_EARLY_ADJUST] 
	@Cmp_ID INT, 
	@From_Date DateTime,
	@To_Date DateTime,
	@Constraint Varchar(Max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF Object_ID('tempdb..#Emp_Cons') IS NULL
		BEGIN
			CREATE TABLE #Emp_Cons 
			(      
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric    
			);
			CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons (Emp_ID);

			IF @Constraint <> ''        
				BEGIN
					INSERT	INTO #Emp_Cons(Emp_ID)        
					SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
					--Added By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---
					UPDATE	#Emp_Cons 
					SET		Branch_ID=I1.Branch_ID,
							Increment_ID =I1.Increment_ID
					FROM	#Emp_Cons EC 
							INNER JOIN T0095_INCREMENT I1 ON EC.Emp_ID=I1.Emp_ID
							INNER JOIN (
											SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
											FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E ON I2.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment --
													INNER JOIN (
																	SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																	FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.Emp_ID	
																	WHERE I3.Increment_effective_Date <= @to_date AND I3.Cmp_ID =@Cmp_ID
																	GROUP BY I3.EMP_ID  
																) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
											GROUP BY I2.Emp_ID
										) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID
										
										
					--Ended By Rohit on 26/11/2015 as Branch_Id and Increment ID was Coming NULL---       
				END
			ELSE
				BEGIN
					INSERT	INTO #Emp_Cons      
					SELECT	DISTINCT emp_id,branch_id,Increment_ID 
					FROM	dbo.V_Emp_Cons 
					WHERE	Cmp_ID=@Cmp_ID 															
							AND Increment_Effective_Date <= @To_Date 
							AND (
									(@From_Date  >= join_Date  AND  @From_Date <= left_date ) 
									OR ( @To_Date  >= join_Date  and @To_Date <= left_date )      
									OR (Left_date is null and @To_Date >= Join_Date)
									OR (@To_Date >= left_date  and  @From_Date <= left_date )
								) 
					ORDER BY Emp_ID
							
					
					DELETE E FROM #Emp_Cons E
					WHERE NOT EXISTS (
										SELECT	TOP 1 1
										FROM	t0095_increment TI WITH (NOLOCK)
												INNER JOIN (
															SELECT	MAX(T0095_Increment.Increment_ID) AS Increment_ID,T0095_Increment.Emp_ID 
															FROM	T0095_Increment WITH (NOLOCK) INNER JOIN #Emp_Cons E ON T0095_INCREMENT.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment
															WHERE	Increment_effective_Date <= @to_date AND Cmp_ID =@Cmp_Id 
															GROUP BY T0095_Increment.emp_ID
															) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID
										WHERE	Increment_effective_Date <= @to_date AND E.Increment_ID	= TI.Increment_ID
									)


				END        
		END

		--select * from #T0185_LOCKED_IN_OUT

    IF Object_Id('tempdb..#T0185_LOCKED_IN_OUT') IS NULL
		BEGIN
			SELECT TOP 0 * INTO #T0185_LOCKED_IN_OUT FROM T0185_LOCKED_IN_OUT WITH (NOLOCK)
			CREATE UNIQUE CLUSTERED INDEX IX_T0185_LOCKED_IN_OUT ON #T0185_LOCKED_IN_OUT(Emp_ID, For_Date)
					

			INSERT INTO #T0185_LOCKED_IN_OUT
			SELECT	LOCK_ID,T.Emp_Id,For_date,Duration_in_sec,Shift_ID,Emp_OT,P_Days,OT_Sec,In_Time,Shift_Start_Time,
					Shift_Change,Weekoff_OT_Sec,Holiday_OT_Sec,Chk_By_Superior,Out_Time,Shift_End_Time,GatePass_Deduct_Days,Leave_Days,
					W_Days,H_Days,Late_sec,Early_sec,Status1,Status2,LatesalDeduDays,EarlySalDeduDays
			FROM	T0185_LOCKED_IN_OUT T WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
					
		END

	SELECT TOP 0 * INTO #T0185_LOCKED_LATE_EARLY_ADJUST FROM T0185_LOCKED_LATE_EARLY_ADJUST WITH (NOLOCK)
	CREATE UNIQUE CLUSTERED INDEX CLIX_T0185_LOCKED_LATE_EARLY_ADJUST ON #T0185_LOCKED_LATE_EARLY_ADJUST(Emp_ID,To_Date Desc, Leave_ID, Flag)

	SELECT	EMP_ID, @From_Date As From_Date, @To_Date As To_Date, IsNull(Max(LateSalDeduDays),0) As LateDays, IsNull(Max(EarlySalDeduDays),0) As EarlyDays
	INTO	#LateEarlyDays
	FROM	#T0185_LOCKED_IN_OUT
	GROUP BY EMP_ID

	SELECT * INTO #Emp_Cons_Actual FROM #Emp_Cons
	DELETE EC FROM #Emp_Cons EC WHERE EXISTS(SELECT 1 FROM #LateEarlyDays LED WHERE LED.Emp_ID=EC.Emp_ID AND (LED.LateDays + LED.EarlyDays) = 0)

	SELECT	ROW_NUMBER() OVER(PARTITION BY Emp_ID ORDER BY Emp_ID,Leave_Sorting_No) As Row_ID,
			Emp_ID,LM.Leave_ID,Cast(0.0000 As Numeric(9,4)) As LeaveBalance,LM.Leave_Sorting_No, LM.Leave_Negative_Allow, 
			LM.leave_negative_max_limit, Cast(0.0000 As Numeric(9,4)) As LateAdjustDays, Cast(0.0000 As Numeric(9,4)) As EarlyAdjustDays,
			LM.Can_Apply_Fraction,LM.Leave_Min
	INTO	#EmpLeaveBalance
	FROM	#Emp_Cons EC 			
			CROSS JOIN (SELECT	Leave_ID,Leave_Negative_Allow,leave_negative_max_limit,
								Case When Default_Short_Name = 'LWP' Then 999 Else Leave_Sorting_No End Leave_Sorting_No,LM.Can_Apply_Fraction,LM.Leave_Min
						FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK) 
						WHERE	(LM.Is_Late_Adj = 1 OR Default_Short_Name = 'LWP')
						UNION ALL	
						SELECT	-1, -1,-999,9999,1,0) LM
	ORDER BY EC.Emp_ID,LM.Leave_Sorting_No
	

	UPDATE	ELB
	SET		LeaveBalance = LT.Leave_Closing
	FROM	#EmpLeaveBalance ELB
			INNER JOIN (SELECT	LT.EMP_ID, LT.Leave_ID, LT.Leave_Closing + Isnull(LT.Leave_Adj_L_Mark,0) As Leave_Closing
						FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 
								INNER JOIN #EmpLeaveBalance ELB1 ON LT.Emp_ID=ELB1.Emp_ID AND LT.Leave_ID=ELB1.Leave_ID
								INNER JOIN (SELECT	LT1.Emp_ID, LT1.Leave_ID, Max(For_Date) As For_Date
											FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)
													INNER JOIN #EmpLeaveBalance ELB1 ON LT1.Emp_ID=ELB1.Emp_ID AND LT1.Leave_ID=ELB1.Leave_ID
											WHERE	LT1.For_Date <= @To_Date
											GROUP BY LT1.Emp_ID, LT1.Leave_ID) LT1 ON LT.Emp_ID=LT1.Emp_ID AND LT.Leave_ID=LT1.Leave_ID AND LT.For_Date=LT1.For_Date
						) LT ON ELB.Emp_ID=LT.Emp_ID AND ELB.Leave_ID=LT.Leave_ID

	DELETE ELB FROM	#EmpLeaveBalance ELB WHERE (LeaveBalance = 0 AND Leave_ID > 0)

	UPDATE	ELB
	SET		LateAdjustDays = LED.LateDays,
			EarlyAdjustDays = LED.EarlyDays
	FROM	#EmpLeaveBalance ELB
			INNER JOIN #LateEarlyDays LED ON ELB.Emp_ID=LED.Emp_ID 
	WHERE	ELB.Leave_ID = -1
	
	--select  * from #EmpLeaveBalance
	--UPDATE #EmpLeaveBalance SET LeaveBalance = 0.5 Where Emp_ID=30 AND Leave_ID=8
	/*
	;WITH T(Emp_ID,Leave_ID,LeaveBalance,Leave_Sorting_No,LateAdjustDays,LateDays,RemainingDays)
	AS(
		SELECT	ELB.Emp_ID,ELB.Leave_ID,ELB.LeaveBalance,ELB.Leave_Sorting_No,
				Cast(Case When ELB.LeaveBalance > A.LateAdjustDays THEN A.LateAdjustDays ELSE ELB.LeaveBalance END As Numeric(9,4)) As LateAdjustDays,
				A.LateAdjustDays, 
				Cast(Case When ELB.LeaveBalance > A.LateAdjustDays THEN 0 ELSE A.LateAdjustDays - ELB.LeaveBalance END As Numeric(9,4)) As RemainingDays
		FROM	#EmpLeaveBalance ELB
				INNER JOIN (SELECT * FROM #EmpLeaveBalance A WHERE Leave_ID= -1) A ON ELB.Emp_ID=A.Emp_ID				
		WHERE	ELB.Leave_ID > 0
				AND ELB.Leave_Sorting_No = (SELECT TOP 1 Leave_Sorting_No FROM #EmpLeaveBalance ELB1 WHERE ELB.Emp_ID=ELB1.Emp_ID)
		UNION ALL
		SELECT	ELB.Emp_ID,ELB.Leave_ID,ELB.LeaveBalance,ELB.Leave_Sorting_No,
				Case When ELB.LeaveBalance > T.RemainingDays THEN T.RemainingDays ELSE ELB.LeaveBalance END As LateAdjustDays,
				T.RemainingDays,
				Cast(Case When ELB.LeaveBalance > T.RemainingDays THEN 0 ELSE T.RemainingDays - ELB.LeaveBalance END As Numeric(9,4)) As RemainingDays
		FROM	#EmpLeaveBalance ELB
				INNER JOIN T ON ELB.Emp_ID=T.Emp_ID AND ELB.Leave_Sorting_No > T.Leave_Sorting_No
		WHERE	ELB.Leave_ID > 0

	)
	SELECT	* FROM T 
	order by Emp_ID, Leave_Sorting_No
	option(MAXRECURSION 0)
	*/
	

	;WITH T(Emp_ID,Leave_ID,LeaveBalance,Leave_Sorting_No,LateAdjustDays,LateDays,RemainingDays,Can_Apply_Fraction,Leave_Min)
	AS(
		SELECT	ELB.Emp_ID,ELB.Leave_ID,ELB.LeaveBalance,ELB.Leave_Sorting_No,
				dbo.fn_getLateEarlyAdjustDays(A.LateAdjustDays,ELB.LeaveBalance, ELB.Can_Apply_Fraction, ELB.Leave_Min) As LateAdjustDays,
				A.LateAdjustDays,  
				Cast(A.LateAdjustDays -dbo.fn_getLateEarlyAdjustDays(A.LateAdjustDays,ELB.LeaveBalance, ELB.Can_Apply_Fraction, ELB.Leave_Min) As Numeric(9,4)) As RemainingDays,
				ELB.Can_Apply_Fraction,ELB.Leave_Min
		FROM	#EmpLeaveBalance ELB
				INNER JOIN (SELECT * FROM #EmpLeaveBalance A WHERE Leave_ID= -1) A ON ELB.Emp_ID=A.Emp_ID				
		WHERE	ELB.Leave_ID > 0
				AND ELB.Leave_Sorting_No = (SELECT TOP 1 Leave_Sorting_No FROM #EmpLeaveBalance ELB1 WHERE ELB.Emp_ID=ELB1.Emp_ID)
		UNION ALL
		SELECT	ELB.Emp_ID,ELB.Leave_ID,ELB.LeaveBalance,ELB.Leave_Sorting_No,
				dbo.fn_getLateEarlyAdjustDays(T.RemainingDays,ELB.LeaveBalance, ELB.Can_Apply_Fraction, ELB.Leave_Min) As LateAdjustDays,
				T.RemainingDays,
				Cast(T.RemainingDays - dbo.fn_getLateEarlyAdjustDays(T.RemainingDays,ELB.LeaveBalance, ELB.Can_Apply_Fraction, ELB.Leave_Min) As Numeric(9,4)) As RemainingDays,
				ELB.Can_Apply_Fraction,ELB.Leave_Min
		FROM	#EmpLeaveBalance ELB
				INNER JOIN T ON ELB.Emp_ID=T.Emp_ID AND ELB.Leave_Sorting_No > T.Leave_Sorting_No
		WHERE	ELB.Leave_ID > 0
	)
	--SELECT  * FROM T
	UPDATE	ELB
	SET		LateAdjustDays = T.LateAdjustDays
	FROM	#EmpLeaveBalance ELB
			INNER JOIN T ON ELB.Emp_ID=T.Emp_ID AND ELB.Leave_ID=T.Leave_ID
	Where	T.LateAdjustDays > 0		
	option(MAXRECURSION 0)

	DELETE FROM #EmpLeaveBalance WHERE LateAdjustDays = 0 AND EarlyAdjustDays = 0 AND Leave_ID > 0

	UPDATE	ELB
	SET		LateAdjustDays = LateAdjustDays - TotalAdjustDays
	FROM	#EmpLeaveBalance ELB
			INNER JOIN (SELECT	Emp_ID, Sum(LateAdjustDays) As TotalAdjustDays
						FROM	#EmpLeaveBalance L WHERE L.Leave_ID > 0
						GROUP BY Emp_ID) A ON ELB.Emp_ID=A.Emp_ID		
	WHERE	ELB.Leave_ID= -1

	UPDATE #EmpLeaveBalance SET LateAdjustDays = 0 WHERE LateAdjustDays < 0 

	--SELECT  * FROM #EmpLeaveBalance
	--select  * from #EmpLeaveBalance
	
	DELETE LLE FROM T0185_LOCKED_LATE_EARLY_ADJUST LLE INNER JOIN #Emp_Cons_Actual EC ON LLE.Emp_ID=EC.Emp_ID 
	WHERE	To_Date=@To_Date

	INSERT INTO T0185_LOCKED_LATE_EARLY_ADJUST(Lock_Id,Cmp_ID,Emp_ID,From_Date,To_Date,Sort_ID,Leave_ID,LastBalance,Flag,AdjustDays)
	SELECT	LA.Lock_Id,@Cmp_ID,L.Emp_ID,@From_Date,@To_Date,Leave_Sorting_No,Leave_ID,L.LeaveBalance,'L',L.LateAdjustDays
	FROM	#EmpLeaveBalance L INNER JOIN
			T0180_LOCKED_ATTENDANCE LA WITH (NOLOCK) ON LA.EMP_ID = L.EMP_ID AND YEAR(@TO_DATE) = LA.[YEAR] AND MONTH(@TO_DATE) = LA.[MONTH]
	
END


