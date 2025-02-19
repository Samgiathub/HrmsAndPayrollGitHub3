

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 25-Feb-2019
-- Description:	This stored procedure is created to fetch Late & Early Deduction Days based on #Data table retrieved from parent Stored Procedure
--				It is mendatory that parent stored procedure has #Emp_Cons, #Data, #Emp_WeekOff, #Emp_Holiday Tables which will be used in this stored procedure.
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_CALCULATE_LATE_EARLY_DEDUCTION_DAYS] 
	@Cmp_ID   numeric  
	,@From_Date  datetime  
	,@To_Date   datetime 
AS
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON




		CREATE TABLE #EMP_CONS_LATE_EARLY
		(
			EMP_ID			INT,
			Increment_ID	INT,
			Gen_ID			INT,
			Late_Early		CHAR(1) DEFAULT('N'),		/*'N' : No Late Early Mark, 'L' : Only Late Mark, 'E' : Only Early Mark, 'A' : Both Late & Early Mark */
			Scenario		TinyInt,
			Late_Limit		Int,
			Early_Limit		Int,
			Late_Dedu_Type	Varchar(10),
			Early_Dedu_Type	Varchar(10),
			Late_On_HW		BIT,
			Early_On_HW		BIT,
			WithLeave		BIT,
			EarlyRounding	NUMERIC(9,2),
			LateRounding	NUMERIC(9,2),
			AdjustWithOT	BIT
		)
		CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_LATE_EARLY ON #EMP_CONS_LATE_EARLY(EMP_ID)
		CREATE NONCLUSTERED INDEX NCIX_EMP_CONS_LATE_EARLY ON #EMP_CONS_LATE_EARLY(EMP_ID,GEN_ID,Late_Early,Scenario)

		
		--Retrieving Employee Cons with Late Early Settings
		INSERT INTO #EMP_CONS_LATE_EARLY(EMP_ID, Increment_ID, Gen_ID, Scenario,Late_Early,Late_Limit,Early_Limit,Late_Dedu_Type,Early_Dedu_Type,
				Late_On_HW,Early_On_HW,WithLeave,EarlyRounding,LateRounding,AdjustWithOT)
		SELECT	EC.Emp_ID, EC.Increment_ID, G.Gen_ID, G.Late_Mark_Scenario, 
				Case When G.Is_Late_Mark = 1 Then 
					Case When I.Emp_Late_mark + I.Emp_Early_mark = 2 Then 'A' When I.Emp_Late_mark =1 Then 'L' When I.Emp_Early_mark=1 Then 'E' Else 'N' END
				Else 'N' END, DBO.F_RETURN_SEC(IsNull(I.Emp_Late_Limit, '00:00')), DBO.F_RETURN_SEC(IsNull(I.Emp_Early_Limit, '00:00')),I.Late_Dedu_Type,I.Early_Dedu_Type,
				ISNULL(Is_Late_Calc_On_HO_WO,0) , ISNULL(Is_Early_Calc_On_HO_WO,0),G.Late_With_Leave,
				IsNull(Early_Hour_Upper_Rounding,0),IsNull(Early_Hour_Upper_Rounding,0), --It supposed to be Late_Hour_Upper_Rounding
				ISNULL(LATE_ADJ_AGAIN_OT,0)
		FROM	#EMP_CONS EC				
				INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Emp_ID= I.Emp_ID AND EC.Increment_ID=I.Increment_ID
				INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON EC.Branch_ID=G.Branch_ID
				INNER JOIN (SELECT	MAX(Gen_ID) As Gen_ID, Branch_ID
							FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK) 
							WHERE	G1.For_Date <= @To_Date
							GROUP BY G1.Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID AND G.Gen_ID=G1.Gen_ID
    		
		
		--Delete Employee Records Without Late/Early Mark Policy
		DELETE FROM #EMP_CONS_LATE_EARLY WHERE Late_Early='N'

		

		--Creating Temp INOUT Table for later use
		SELECT	D.Emp_ID, D.For_Date, Max(IsNull(EIR.Is_Cancel_Late_In,0)) As Is_Cancel_Late_In, Max(IsNull(EIR.Is_Cancel_Early_Out,0)) As Is_Cancel_Early_Out,Max(EIR.Chk_By_Superior) As Chk_By_Superior
		INTO	#T0150_EMP_INOUT_RECORD 
		FROM	T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) 
				INNER JOIN #DATA D ON EIR.IN_TIME BETWEEN D.IN_TIME AND D.OUT_TIME AND EIR.Emp_ID=D.EMP_ID
		GROUP BY D.Emp_ID, D.For_Date

		
	
		--Creating #Data Without Absent Days for Late Calculation
		SELECT	D.*, DateAdd(s, EC.Late_Limit, Shift_Start_Time) As Late_Limit_Time, Cast(0 AS INT) As LateDiff, Cast(0 As BIT) Is_Late
		INTO	#DATA_LATE
		FROM	#DATA D
				INNER JOIN #EMP_CONS_LATE_EARLY EC	ON D.Emp_ID=EC.Emp_ID				
				INNER JOIN #T0150_EMP_INOUT_RECORD EIR ON EC.EMP_ID=EIR.Emp_ID AND D.FOR_DATE=EIR.FOR_DATE
		WHERE	(D.P_Days > 0 OR (Late_On_HW = 1 AND (Holiday_OT_Sec > 0  OR WeekOff_OT_Sec > 0)))
				AND EIR.Chk_By_Superior<> 1 AND Is_Cancel_Late_In=0				
					AND EC.Late_Early IN ('A', 'L')
				AND NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 										
									INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID=LM.LEAVE_ID
								WHERE LT.Emp_ID=D.Emp_ID AND LT.For_Date=D.For_Date 
										AND (
												((LT.Leave_Used + IsNull(LT.CompOff_Used,0) > 0.5) AND LM.Apply_Hourly=0)
												OR 
												((LT.Leave_Used + IsNull(LT.CompOff_Used,0) > 4) AND LM.Apply_Hourly=0)
											)
								)
	
		
		
		DELETE FROM #DATA_LATE WHERE In_Time < Late_Limit_Time
		
		
	
		--Creating #Data Without Absent Days for Early Calculation
		SELECT	D.*, DateAdd(s, EC.Early_Limit, Shift_End_Time) As Early_Limit_Time, Cast(0 AS INT) As EarlyDiff, Cast(0 As BIT) Is_Early
		INTO	#DATA_EARLY
		FROM	#DATA D
				INNER JOIN #EMP_CONS_LATE_EARLY EC	ON D.Emp_ID=EC.Emp_ID				
				INNER JOIN #T0150_EMP_INOUT_RECORD EIR ON EC.EMP_ID=EIR.Emp_ID AND D.FOR_DATE=EIR.FOR_DATE
		WHERE	D.P_Days > 0 OR (Early_On_HW=1 AND (Holiday_OT_Sec > 0  OR WeekOff_OT_Sec > 0))
				AND EIR.Chk_By_Superior<> 1 AND Is_Cancel_Early_Out=0
				AND EC.Late_Early IN ('A', 'E')
				AND NOT EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 										
									INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID=LM.LEAVE_ID
								WHERE LT.Emp_ID=D.Emp_ID AND LT.For_Date=D.For_Date 
										AND (
												((LT.Leave_Used + IsNull(LT.CompOff_Used,0) > 0.5) AND LM.Apply_Hourly=0)
												OR 
												((LT.Leave_Used + IsNull(LT.CompOff_Used,0) > 4) AND LM.Apply_Hourly=0)
											)
								)
		DELETE FROM #DATA_EARLY WHERE Out_Time > Early_Limit_Time

		

		/**********************************************************************************************************/
		/***************************************END OF COMMON CODE*************************************************/
		/**********************************************************************************************************/


		/***************************************CODE FOR SCENARIO 1 ***********************************************/

		/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF SCENARIO 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

		/***************************************CODE FOR SCENARIO 2 ***********************************************/
		BEGIN
			 CREATE TABLE #LATE_MARK_SLAB
			(
				CMP_ID NUMERIC(18,0),
				EMP_ID NUMERIC(18,0),
				TRANS_ID NUMERIC(18,0),
				BRANCH_ID NUMERIC(18,0),
				FROM_MIN NUMERIC(18,0),
				TO_MIN NUMERIC(18,0),
				EXMPT_COUNT NUMERIC(18,0),
				DEDUCTION NUMERIC(18,2),
				DEDUCTION_TYPE VARCHAR(100),
				GEN_ID NUMERIC(18,0),
				CURR_COUNT NUMERIC(18,0),
				ONE_TIME_EXEMPTION NUMERIC(2,0),
				Total_Deduct_Days Numeric(18,2),
				GROUP_FLAG BIT
			)   

			INSERT INTO #LATE_MARK_SLAB(CMP_ID,EMP_ID,TRANS_ID,BRANCH_ID,FROM_MIN,TO_MIN,EXMPT_COUNT,DEDUCTION,DEDUCTION_TYPE,GEN_ID,CURR_COUNT,ONE_TIME_EXEMPTION,Total_Deduct_Days,GROUP_FLAG)
            SELECT	LS.CMP_ID,LE.EMP_ID,TRANS_ID,Branch_ID,FROM_MIN,TO_MIN,EXEMPTION_COUNT,DEDUCTION,DEDUCTION_TYPE,G.Gen_ID,0,ONE_TIME_EXEMPTION,0,0
            FROM	T0050_GENERAL_LATEMARK_SLAB LS WITH (NOLOCK) 
					INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON G.GEN_ID=LS.GEN_ID
					INNER JOIN #EMP_CONS_LATE_EARLY LE ON G.GEN_ID=LE.Gen_ID 
			WHERE	LE.Scenario=2


			--Getting Difference
			UPDATE	DL
			SET		LateDiff = Case When DatePart(HH, Late_Limit_Time) = 0 AND In_Time < DateAdd(d, 1, For_date) Then 
										DateDiff(s,DateAdd(D,1,For_date) ,In_Time)
									Else
										DateDiff(s,Late_Limit_Time,In_Time)
									End 
			FROM	#DATA_LATE DL

			
			
			UPDATE	DL
			SET		LateDiff = dbo.Pro_Rounding_Sec_HH_MM(LateDiff,LateRounding)
			FROM	#DATA_LATE DL
					INNER JOIN #EMP_CONS_LATE_EARLY EC ON DL.Emp_Id=EC.EMP_ID
			WHERE	LateRounding > 0


			DELETE DL FROM #DATA_LATE DL WHERE LateDiff = 0

		ALTER TABLE #DATA_LATE ADD SlabID INT
			
			/*For One Time Exemption*/
			UPDATE 	DL
			SET		SlabID = (SELECT TOP 1 TRANS_ID FROM #LATE_MARK_SLAB LS WHERE DATEDIFF(N, DL.Shift_Start_Time , DL.In_Time) BETWEEN FROM_MIN AND TO_MIN	and DL.EMP_ID=LS.EMP_ID AND ONE_TIME_EXEMPTION = 1 ORDER BY TRANS_ID)
			FROM 	#DATA_LATE DL 	
					INNER JOIN (SELECT  T.EMP_ID,MIN(IN_TIME) AS IN_TIME 
								FROM 	#DATA_LATE T
										INNER JOIN #LATE_MARK_SLAB LS ON DATEDIFF(N, T.Shift_Start_Time , T.In_Time) BETWEEN FROM_MIN AND TO_MIN AND T.EMP_ID=LS.EMP_ID AND LS.ONE_TIME_EXEMPTION=1
								GROUP BY T.EMP_ID) T ON DL.EMP_ID=T.EMP_ID AND DL.IN_TIME = T.IN_TIME
			
			/*Other Slabs*/
			UPDATE 	DL
			SET		SlabID = (SELECT TOP 1 TRANS_ID FROM #LATE_MARK_SLAB LS WHERE DATEDIFF(N, DL.Shift_Start_Time , DL.In_Time) BETWEEN FROM_MIN AND TO_MIN	and DL.EMP_ID=LS.EMP_ID AND ONE_TIME_EXEMPTION = 0 ORDER BY TRANS_ID)
			FROM 	#DATA_LATE DL 
			WHERE	IsNull(SlabID,0) = 0
			

			UPDATE	LS
			SET		CURR_COUNT = (	SELECT	COUNT(1)
									FROM	#DATA_LATE DL1 
										WHERE	DL1.SlabID=LS.Trans_ID
									--WHERE	DATEDIFF(N, DL1.Shift_Start_Time , DL1.In_Time) BETWEEN FROM_MIN AND TO_MIN	and DL1.EMP_ID=LS.EMP_ID						
								 ) 
			FROM	#LATE_MARK_SLAB  LS
					--INNER JOIN (SELECT	DL1.EMP_ID , SUM(1) AS L_COUNT
					--			FROM	#DATA_LATE DL1 INNER JOIN #LATE_MARK_SLAB  LS ON LS.EMP_ID=DL1.Emp_Id 
					--					AND DATEDIFF(MINUTE, DL1.Shift_Start_Time , DL1.In_Time) BETWEEN FROM_MIN AND TO_MIN
					--			GROUP BY DL1.EMP_ID
					--			) DL ON LS.EMP_ID=DL.Emp_Id 
			
			DELETE FROM #LATE_MARK_SLAB WHERE IsNull(CURR_COUNT,0) = 0
			
			
			
			UPDATE	T1
			SET     GROUP_FLAG = 1
			FROM    #LATE_MARK_SLAB T1 
					INNER JOIN (SELECT T2.FROM_MIN, T2.TO_MIN FROM #LATE_MARK_SLAB T2 
								GROUP BY T2.FROM_MIN, T2.TO_MIN 
								HAVING COUNT(1) > 1) T2 ON T1.FROM_MIN=T2.FROM_MIN AND T1.TO_MIN = T2.TO_MIN
			
			
			SELECT	*, CAST(0.00 AS NUMERIC(9,2)) AS Late_Deduction_Days
			INTO	#Late_Days
			FROM	(
						SELECT	EMP_ID,EXMPT_COUNT,CURR_COUNT,DEDUCTION,DEDUCTION_TYPE,TRANS_ID,ONE_TIME_EXEMPTION,GROUP_FLAG 
						FROM	#LATE_MARK_SLAB 
						WHERE	GROUP_FLAG = 0
						UNION
						SELECT	LB.EMP_ID,EXMPT_COUNT,CURR_COUNT,DEDUCTION,DEDUCTION_TYPE,LB.TRANS_ID,ONE_TIME_EXEMPTION,GROUP_FLAG 
						FROM	#LATE_MARK_SLAB LB
								INNER JOIN( SELECT	MAX(TRANS_ID) AS TRANS_ID,FROM_MIN,TO_MIN,EMP_ID
											FROM	#LATE_MARK_SLAB Where GROUP_FLAG = 1 AND CURR_COUNT > EXMPT_COUNT 
											GROUP BY FROM_MIN,TO_MIN,EMP_ID) As Qry ON LB.TRANS_ID = Qry.TRANS_ID and LB.FROM_MIN = Qry.FROM_MIN and LB.TO_MIN = Qry.TO_MIN AND LB.EMP_ID=Qry.EMP_ID
						WHERE	GROUP_FLAG = 1 AND CURR_COUNT > EXMPT_COUNT
					) T
				

			UPDATE	LD
			SET		Late_Deduction_Days = LD.CURR_COUNT * LD.DEDUCTION
			FROM	#Late_Days LD	
					INNER JOIN #EMP_CONS_LATE_EARLY EC ON EC.Emp_ID=LD.EMP_ID
			WHERE	EC.AdjustWithOT=1

			

			UPDATE	LD
			SET		Late_Deduction_Days =	CASE WHEN GROUP_FLAG=1 Then
													DEDUCTION
												WHEN ONE_TIME_EXEMPTION=1 Then
													(CURR_COUNT - EXMPT_COUNT) * DEDUCTION 
												WHEN ONE_TIME_EXEMPTION=0 Then
													FLOOR((CURR_COUNT/(EXMPT_COUNT + 1))) * DEDUCTION
												ELSE
													0
											END
			FROM	#Late_Days LD	
					INNER JOIN #EMP_CONS_LATE_EARLY EC ON EC.Emp_ID=LD.EMP_ID
			WHERE	EC.AdjustWithOT=0 AND LD.DEDUCTION_TYPE='Days'

			

			IF OBJECT_ID('tempdb..#EMP_LATE_EARLY') IS NULL
				BEGIN
				print 124
					CREATE TABLE #EMP_LATE_EARLY
					(
						Emp_ID				INT,
						LateSalDeduDays		Numeric(9,3),
						TotalLateMark		INT,
						TotalLateOTHours	Numeric(9,3)
					)
				END
			

			INSERT INTO #EMP_LATE_EARLY(EMP_ID)
			SELECT DISTINCT EMP_ID FROM #Late_Days LD
			WHERE NOT EXISTS(SELECT 1 FROM #EMP_LATE_EARLY ELE WHERE LD.EMP_ID=ELE.EMP_ID)
			

			
			UPDATE	ELE
			SET		LateSalDeduDays = LD.Late_Deduction_Days,
					TotalLateOTHours = LD.TotalLateHours,
					TotalLateMark = LD.Curr_Count			
			FROM	#EMP_LATE_EARLY ELE
					INNER JOIN #EMP_CONS_LATE_EARLY EC ON EC.Emp_ID=ELE.EMP_ID
					INNER JOIN (SELECT	LD.EMP_ID, SUM(IsNull(Case When AdjustWithOT = 1 And Deduction_Type='Days' Then																
																	Late_Deduction_Days
																When AdjustWithOT = 0 Then
																	Late_Deduction_Days
																Else
																	0
															End,0)) As Late_Deduction_Days, 
												SUM(IsNull(Case When AdjustWithOT = 1 And Deduction_Type='Hours' Then																
																	Late_Deduction_Days																
																Else
																	0
															End,0)) As TotalLateHours, 
										Sum(IsNull(Curr_Count,0)) As Curr_Count
								FROM	#Late_Days LD 
										INNER JOIN #EMP_CONS_LATE_EARLY EC1 ON EC1.Emp_ID=LD.EMP_ID
								WHERE	LD.Late_Deduction_Days < 31
								GROUP BY LD.EMP_ID) LD ON ELE.Emp_ID=LD.EMP_ID
						
			

			IF OBJECT_ID('tempdb..#T0185_LOCKED_IN_OUT') IS NOT NULL
				BEGIN
					UPDATE	LA
					SET		LateSalDeduDays = ELE.LateSalDeduDays,
							Late_Sec = DL.LateDiff
					FROM	#T0185_LOCKED_IN_OUT LA
							INNER JOIN #EMP_LATE_EARLY ELE ON LA.EMP_ID=ELE.EMP_ID
							INNER JOIN #DATA_LATE DL ON LA.EMP_ID=DL.EMP_ID AND LA.FOR_DATE=DL.FOR_DATE										
				END
					
		END
		/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF SCENARIO 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

		/***************************************CODE FOR SCENARIO 3 ***********************************************/

		/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF SCENARIO 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

	END

