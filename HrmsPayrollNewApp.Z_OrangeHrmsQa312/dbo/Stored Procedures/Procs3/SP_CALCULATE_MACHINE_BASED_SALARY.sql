


-- ====================================================
-- Author:		SHAIKH RAMIZ
-- Create date: 17TH-FEB-2018
-- Description:	CALCULATE EFFICIENCY BASED BASIC SALARY
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- ====================================================
CREATE PROCEDURE [dbo].[SP_CALCULATE_MACHINE_BASED_SALARY]
	@Emp_Id				NUMERIC ,                    
	@Cmp_ID				NUMERIC ,                    
	@Increment_ID		NUMERIC ,
	@Gen_Id				NUMERIC,
	@Month_St_Date		DATETIME,                    
	@Month_End_Date		DATETIME,
	@StrHoliday_Date	VARCHAR(MAX),
	@StrWeekoff_Date	VARCHAR(MAX),
	@Sal_cal_Days		NUMERIC(18, 2),
	@WeavingEmpType		VARCHAR(5),
	@Salary_Amount		NUMERIC(18, 4) OUTPUT,
	@Mchn_CL_Leave		NUMERIC(18, 2) OUTPUT,
	@is_Mchn_Based		NUMERIC(18, 2) OUTPUT
	--@StrHoliday_Date_Mchn	varchar(max) OUTPUT
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @GRD_ID				AS NUMERIC
	DECLARE @SEGMENT_ID			AS NUMERIC
	DECLARE @Inc_Weekoff		AS INT
	DECLARE @Inc_Holiday		AS INT
	DECLARE @Cancel_Weekoff		AS INT
	DECLARE @Cancel_Holiday		AS INT
	DECLARE @MONTHLY_AVG		AS NUMERIC(18,4)
	DECLARE @Sal_Fix_Days		AS  INT
	DECLARE @EMPMASTER_BASIC AS NUMERIC(18,2)
	DECLARE @ASSIGNED_MACHINE AS VARCHAR(100)
	DECLARE @Avg_Percent as NUMERIC(18,2)
	DECLARE @Month_AvgPercent as Numeric(18,2)
	DECLARE @Month_AvgBasic as Numeric(18,2)
	DECLARE @Mchn_Holiday	as Numeric(18,2)
	DECLARE @COUNTER AS INT
	DECLARE @Leave_Count AS INT
	DECLARE @Holiday_Count AS INT
	declare @prev_present as tinyint
	declare @nxt_present as tinyint

	SET @is_Mchn_Based = 1
	SET @Salary_Amount = 0
	SET @Mchn_Holiday = 0
	SET @ASSIGNED_MACHINE = ''
	SET @Avg_Percent = 0	
	

	SELECT @GRD_ID = GRD_ID , @Segment_ID = Segment_ID , @EMPMASTER_BASIC = ISNULL(Basic_Salary ,0)
	FROM T0095_INCREMENT WITH (NOLOCK) WHERE Increment_ID = @Increment_ID
	
	SELECT	@Inc_Weekoff = Inc_Weekoff , 
			@Inc_Holiday = Inc_Holiday , 
			@Cancel_Weekoff = Is_Cancel_Weekoff , 
			@Cancel_Holiday = Is_Cancel_Holiday , 
			@Sal_Fix_Days = Sal_Fix_Days
	FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Gen_ID = @Gen_Id
	

	SET @Sal_Fix_Days = CASE WHEN @Sal_Fix_Days > 0 THEN @Sal_Fix_Days ELSE @Sal_cal_Days END
	--SET @StrHoliday_Date_Mchn = @StrHoliday_Date

	SELECT MM.Machine_ID ,MM.Machine_Type, MDE.Shift_ID, ROUND(AVG(Efficiency),0) AS Avg_Percent , CAST(0 AS NUMERIC(18,2)) AS BSC_SALARY
	INTO #MACHINE_EFFICIENCY
	FROM T0040_Machine_Master MM WITH (NOLOCK)
	INNER JOIN T0100_Machine_Daily_Efficiency MDE WITH (NOLOCK) on MDE.Machine_ID = cast(MM.Machine_ID as varchar(20)) --and MDE.ALTERNATE_EMP_ID = @EMP_ID
	WHERE For_Date >= @Month_St_Date AND For_Date <= @Month_End_Date and Efficiency <> 0
	GROUP BY MM.Machine_ID , MM.Machine_Type , MDE.Shift_ID

	--Logic of Minimum 65% Efficiency -(START)-- Will be Used for Multiple Machine
	UPDATE ME
	SET Avg_Percent = 65.00
	FROM #MACHINE_EFFICIENCY ME
	INNER JOIN T0040_Machine_Master MM ON MM.Machine_ID = ME.Machine_ID
	WHERE Avg_Percent < 65.00 AND MM.Machine_Type = 'IBIZA'

	UPDATE ME
	SET Avg_Percent = 80.00
	FROM #MACHINE_EFFICIENCY ME
	INNER JOIN T0040_Machine_Master MM ON MM.Machine_ID = ME.Machine_ID
	WHERE Avg_Percent < 80.00 AND MM.Machine_Type <> 'IBIZA'
	--Logic of Minimum 65% Efficiency -(END)-- -- Will be Used for Multiple Machine

	UPDATE ME
	SET BSC_SALARY = MES.Basic_Amount
	FROM #MACHINE_EFFICIENCY ME
	INNER JOIN T0040_Machine_Efficiency_Master MEM ON ME.Machine_ID = CAST(MEM.Machine_ID AS VARCHAR(20))
	INNER JOIN T0050_Machine_Efficiency_Slab MES ON MEM.Efficiency_ID = MES.Efficiency_ID AND MES.Avg_Percent = ME.Avg_Percent


		--Adding Color Beam Allowance Machine wise--(START)
	UPDATE ME
	SET BSC_SALARY = BSC_SALARY + ISNULL(MMA.Allow_amount,0)
	FROM #MACHINE_EFFICIENCY ME
	INNER JOIN T0190_Machine_Monthly_Allowance MMA ON MMA.MACHINE_ID = ME.MACHINE_ID
	WHERE For_Date >= @Month_St_Date AND For_Date <= @Month_End_Date and Allow_amount <> 0
	--Adding Color Beam Allowance Machine wise--(END)

	SELECT * INTO #T0100_EMP_GRADE_DETAIL 
	FROM T0100_EMP_GRADE_DETAIL EGD WITH (NOLOCK)
	WHERE EGD.EMP_ID = @EMP_ID AND EGD.For_Date BETWEEN @Month_St_Date AND @Month_end_Date

	--INSERTING ALL DATES OF A MONTH
	CREATE TABLE #DATES(FOR_DATE DATETIME);

	INSERT INTO #DATES
	SELECT	DATEADD(d, T.Row_ID, @Month_St_Date)
	FROM	(SELECT TOP 31 (ROW_NUMBER() OVER(ORDER BY object_id) - 1) AS ROW_ID FROM sys.objects) T
	WHERE	DATEADD(d, T.Row_ID, @Month_St_Date) <= @Month_End_Date


	IF @WeavingEmpType in ('RV' , 'AT' , 'OL') --RELIVER , ASSISTANT TACKLER AND OILER
		BEGIN
			SELECT TOP 1 @ASSIGNED_MACHINE = Machine_ID 
			FROM	T0040_Machine_Allocation_Master WITH (NOLOCK)
			WHERE	Emp_ID = @Emp_Id AND Effective_Date <= @Month_End_Date
			ORDER BY Effective_Date DESC

			CREATE TABLE #RELIEVER
			(
				EMP_ID					NUMERIC,
				FOR_DATE				DATETIME,
				SHIFT_ID				NUMERIC(18,0),
				ASSIGNED_MACHINE		VARCHAR(200),
				WORKED_IN				VARCHAR(5),
				MASTER_BASIC			NUMERIC(18,2),
				CALCULATED_BASIC		NUMERIC(18,2),
				LEAVE_COUNT				NUMERIC(18,2),
				DAY_FLAG				VARCHAR(2),
				P_DAYS					NUMERIC(18,2),
				PrevDate		DATETIME,
				NxtDate			DATETIME
			)

			CREATE UNIQUE CLUSTERED INDEX IX_RELIEVER ON #RELIEVER(EMP_ID, FOR_DATE)

			INSERT INTO #RELIEVER
				(EMP_ID , FOR_DATE , DAY_FLAG)
			SELECT @EMP_ID , FOR_DATE , 'A'
			FROM #DATES


			UPDATE RV
			SET RV.SHIFT_ID = DA.SHIFT_ID , RV.DAY_FLAG = 'P' , 
				RV.P_DAYS = DA.P_DAYS , ASSIGNED_MACHINE = @ASSIGNED_MACHINE , WORKED_IN = @WeavingEmpType
			FROM #RELIEVER RV
				INNER JOIN #DATA DA ON DA.FOR_DATE = RV.FOR_DATE AND RV.EMP_ID = DA.EMP_ID
			WHERE DA.P_days > 0

			--INSERT INTO #RELIEVER
			--	(EMP_ID , FOR_DATE , SHIFT_ID , ASSIGNED_MACHINE , WORKED_IN , MASTER_BASIC , CALCULATED_BASIC , LEAVE_COUNT , DAY_FLAG , P_DAYS)
			--SELECT EMP_ID , FOR_DATE , SHIFT_ID , @ASSIGNED_MACHINE , @WeavingEmpType , 0.00 , 0.00 , 0 , 'P' , P_DAYS
			--FROM #DATA 
			--WHERE P_DAYS > 0


			UPDATE RV
			SET WORKED_IN = MDE.WeaverFlag , ASSIGNED_MACHINE = MDE.Machine_ID
			FROM #RELIEVER RV 
				INNER JOIN	T0100_Machine_Daily_Efficiency MDE ON RV.EMP_ID = MDE.Alternate_Emp_ID AND RV.FOR_DATE = MDE.For_Date
			WHERE MDE.Alternate_Emp_ID = @Emp_Id
			--IF WORKED IN UPPER MACHINE THEN UPDATE (ENDS)

			--IF WORKED IN UPPER GRADE THEN UPDATE STARTS
			UPDATE RV
			SET ASSIGNED_MACHINE = CAST(EGD.Grd_ID AS VARCHAR(20)) , WORKED_IN = 'GRD'
			FROM #RELIEVER RV 
				INNER JOIN	#T0100_EMP_GRADE_DETAIL EGD ON RV.EMP_ID = EGD.Emp_ID AND RV.FOR_DATE = EGD.For_Date
			WHERE EGD.Emp_ID = @Emp_Id
			--IF WORKED IN UPPER GRADE THEN UPDATE ENDS
			
			UPDATE RV
			SET DAY_FLAG = 'L' , LEAVE_COUNT = T.Leave_Used , P_Days = 1
			FROM #RELIEVER RV
				INNER JOIN (SELECT FOR_DATE , Isnull(Leave_Used,0) AS Leave_Used
							FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.LEAVE_ID = LT.LEAVE_ID
							WHERE Emp_ID = @Emp_id and LEAVE_PAID_UNPAID = 'P' AND For_Date BETWEEN @Month_St_Date AND @Month_end_Date
								AND Calculate_on_Previous_Month = 0 and LT.Leave_Used > 0
							) T on t.FOR_DATE = RV.FOR_DATE
	
			UPDATE	CT
			SET		PrevDate = (SELECT TOP 1 FOR_DATE FROM #RELIEVER T 
								WHERE T.FOR_DATE < CT.FOR_DATE AND T.DAY_FLAG <> 'L' 
									AND T.FOR_DATE = (SELECT MAX(FOR_DATE) from #RELIEVER T1 Where T1.FOR_DATE < CT.FOR_DATE AND T1.DAY_FLAG ='P')),
					NxtDate = (SELECT TOP 1 FOR_DATE FROM #RELIEVER T 
									WHERE T.FOR_DATE > CT.FOR_DATE AND T.DAY_FLAG <> 'L' 
										AND T.FOR_DATE = (SELECT MIN(FOR_DATE) from #RELIEVER T1 Where T1.FOR_DATE > CT.FOR_DATE AND T1.DAY_FLAG = 'P'))
			FROM #RELIEVER CT		
			WHERE	CT.DAY_FLAG='L'


			UPDATE 	CT
			SET		SHIFT_ID = isnull(prev.SHIFT_ID,nxt.SHIFT_ID) , 
					ASSIGNED_MACHINE = isnull(prev.ASSIGNED_MACHINE,nxt.ASSIGNED_MACHINE) , 
					WORKED_IN = isnull(prev.WORKED_IN , nxt.WORKED_IN)
			FROM	#RELIEVER CT
					LEFT OUTER JOIN #RELIEVER prev ON CT.PrevDate = prev.FOR_DATE
					LEFT OUTER JOIN #RELIEVER nxt ON CT.NxtDate = nxt.FOR_DATE
			WHERE  CT.DAY_FLAG = 'L'


			IF @Inc_Holiday = 1 AND @StrHoliday_Date <> ''
				BEGIN
					UPDATE RV
					SET RV.DAY_FLAG = 'H' , RV.P_Days = 1
					FROM #RELIEVER RV
						INNER JOIN (SELECT CAST(DATA AS DATETIME) AS FOR_DATE 
									FROM dbo.Split(@StrHoliday_Date, ';') 
									WHERE DATA <> ''
									) T on t.FOR_DATE = RV.FOR_DATE
				
					UPDATE	RV
					SET		PrevDate = (SELECT TOP 1 FOR_DATE FROM #RELIEVER T 
										WHERE T.FOR_DATE < RV.FOR_DATE AND T.DAY_FLAG <> 'H' 
											AND T.FOR_DATE = (select MAX(FOR_DATE) from #RELIEVER T1 Where T1.FOR_DATE < RV.FOR_DATE AND T1.DAY_FLAG = 'P')),
							NxtDate = (SELECT TOP 1 FOR_DATE FROM #RELIEVER T 
											WHERE T.FOR_DATE > RV.FOR_DATE AND T.DAY_FLAG <> 'H' 
												AND T.FOR_DATE = (select MIN(FOR_DATE) from #RELIEVER T1 Where T1.FOR_DATE > RV.FOR_DATE AND T1.DAY_FLAG = 'P'))
					FROM #RELIEVER RV		
					WHERE	RV.DAY_FLAG = 'H'

					UPDATE 	RV
					SET		ASSIGNED_MACHINE = isnull(prev.ASSIGNED_MACHINE,nxt.ASSIGNED_MACHINE),
							SHIFT_ID = isnull(prev.SHIFT_ID,nxt.SHIFT_ID) , 
							WORKED_IN = isnull(prev.WORKED_IN , nxt.WORKED_IN)
					FROM	#RELIEVER RV
							LEFT OUTER JOIN #RELIEVER prev ON RV.PrevDate = prev.FOR_DATE
							LEFT OUTER JOIN #RELIEVER nxt ON RV.NxtDate = nxt.FOR_DATE
					WHERE	RV.DAY_FLAG = 'H'
				END
			--INSERTING HOLIDAYS ENDS

			SELECT EMP_ID ,ASSIGNED_MACHINE ,SHIFT_ID,  WORKED_IN , SUM(P_DAYS) AS DAYS_WORKED , MASTER_BASIC , CALCULATED_BASIC
			INTO #RELIEVER_EFF
			FROM #RELIEVER
			GROUP BY EMP_ID , ASSIGNED_MACHINE ,SHIFT_ID,  WORKED_IN , MASTER_BASIC , CALCULATED_BASIC
	
			
			UPDATE	RV			--Updating Master Basic of Multiple Machine--
			SET		MASTER_BASIC = (SELECT  AVG(MDM.BSC_SALARY) AS BSC_SALARY
									FROM #MACHINE_EFFICIENCY MDM
									WHERE	MDM.Machine_ID IN ( SELECT data As Machine_ID FROM dbo.Split(RV.ASSIGNED_MACHINE, '#') T WHERE  T.Data <> '' )
									        AND MDM.Shift_ID=RV.Shift_ID
									) 
			FROM	#RELIEVER_EFF RV					
			WHERE CHARINDEX('#' , ASSIGNED_MACHINE) > 0 AND WORKED_IN <> 'GRD'

		
			UPDATE	RV			--Updating Master Basic of Single Machine--
			SET		MASTER_BASIC = (SELECT  AVG(MDM.BSC_SALARY) AS BSC_SALARY
									FROM #MACHINE_EFFICIENCY MDM
									WHERE	MDM.Machine_ID = RV.ASSIGNED_MACHINE 
									AND MDM.Shift_ID=RV.Shift_ID
									) 
			FROM	#RELIEVER_EFF RV					
			WHERE CHARINDEX('#' , ASSIGNED_MACHINE) = 0 AND WORKED_IN <> 'GRD'


			
			UPDATE	RV			--Updating Master Basic of GRADE
			SET		MASTER_BASIC = GM.Fix_Basic_Salary
			FROM	#RELIEVER_EFF RV	
					INNER JOIN T0040_GRADE_MASTER GM ON GM.Grd_ID = CAST(RV.ASSIGNED_MACHINE AS NUMERIC)	
			WHERE CHARINDEX('#' , ASSIGNED_MACHINE) = 0 AND WORKED_IN = 'GRD'
			

			INSERT INTO #EFFICIENCY_SALARY 
				(Machine_ID, Days_Count , Master_Basic , Calculated_Basic ,  WORKED_IN)
			SELECT ASSIGNED_MACHINE , DAYS_WORKED , MASTER_BASIC , CALCULATED_BASIC, WORKED_IN
			FROM #RELIEVER_EFF

			SELECT @Mchn_CL_Leave = SUM(LEAVE_COUNT) FROM #RELIEVER WHERE DAY_FLAG = 'L'
			SELECT @Mchn_Holiday  = SUM(P_DAYS)		 FROM #RELIEVER WHERE DAY_FLAG = 'H'

		END

	IF @WeavingEmpType in ( 'WV' , 'BD') 	--WEAVER & BADALI
		BEGIN
			CREATE TABLE #DAILY_EFFICIENCY
				(
					MACHINE_ID		VARCHAR(100) ,
					SHIFT_ID		NUMERIC,
					FOR_DATE		DATETIME,
					EFFICIENCY		NUMERIC(18,2),
					WORKED_IN		VARCHAR(5),
					LEAVE_COUNT		NUMERIC(18,2),
					DAY_FLAG		VARCHAR(2),		-- P for Present , L for Leave , H for Holiday , A for Absent and W for WeekOff
					P_Days			NUMERIC(18,2),
					PrevDate		DATETIME,
					NxtDate			DATETIME
				)
			CREATE UNIQUE CLUSTERED INDEX IX_DAILYEFF_FOR_DATE ON #DAILY_EFFICIENCY(FOR_DATE);

			--INSERTING ALL ENTRIES OF MONTH IN TABLE
			INSERT INTO #DAILY_EFFICIENCY
				(FOR_DATE , DAY_FLAG)
			SELECT FOR_DATE , 'A' FROM #DATES

			--FIRST OF ALL DELETING WEEK-OFF AS IT IS NOT REQUIRED
			DELETE DE
			FROM #DAILY_EFFICIENCY DE
				INNER JOIN (SELECT CAST(DATA AS DATETIME) AS FOR_DATE 
							FROM dbo.Split(@StrWeekoff_Date, ';') 
							WHERE DATA <> ''
							) T on t.FOR_DATE = DE.FOR_DATE

			--UPDATING ATTENDANCE OF MONTH
			UPDATE DE
			SET DE.MACHINE_ID = 0 , DE.SHIFT_ID = DA.SHIFT_ID , EFFICIENCY = @EMPMASTER_BASIC , 
				WORKED_IN = '999' , DAY_FLAG = 'P' , DE.P_DAYS = DA.P_DAYS
			FROM #DAILY_EFFICIENCY DE
				INNER JOIN #DATA DA ON DA.FOR_DATE = DE.FOR_DATE
			WHERE DA.P_days <> 0

			--IF WORKED IN MACHINE THEN UPDATING MACHINE
			UPDATE DE
			SET MACHINE_ID = MDE.Machine_ID , SHIFT_ID = MDE.Shift_ID , EFFICIENCY = MDE.Efficiency , WORKED_IN = MDE.WeaverFlag 
			FROM #DAILY_EFFICIENCY DE
				INNER JOIN T0100_MACHINE_DAILY_EFFICIENCY MDE ON MDE.For_Date = DE.FOR_DATE
			WHERE MDE.Alternate_Emp_ID = @EMP_ID AND MDE.For_Date BETWEEN @Month_St_Date AND @Month_End_Date AND DE.P_days <> 0

			--IF WORKED IN UPPER GRADE THEN UPDATE STARTS-- Commented Becoz , Weaver working in Grade is Not Done
			UPDATE DE
			SET MACHINE_ID = CAST(EGD.Grd_ID AS VARCHAR(20)) , WORKED_IN = 'GRD',
				EFFICIENCY = GM.Fix_Basic_Salary
			FROM #DAILY_EFFICIENCY DE 
				INNER JOIN	#T0100_EMP_GRADE_DETAIL EGD ON DE.FOR_DATE = EGD.For_Date
				INNER JOIN T0040_GRADE_MASTER GM ON  EGD.Grd_ID = GM.Grd_ID
			WHERE EGD.Emp_ID = @Emp_Id
			--IF WORKED IN UPPER GRADE THEN UPDATE ENDS

			----INSERTING REGULAR DAYS
			--INSERT INTO #DAILY_EFFICIENCY
			--SELECT MDE.Machine_ID , MDE.Shift_ID , MDE.For_Date , MDE.Efficiency , MDE.WeaverFlag, 0 , 'R' , D.P_days
			--FROM T0100_MACHINE_DAILY_EFFICIENCY MDE
			--	INNER JOIN #DATA D ON MDE.Alternate_Emp_ID = D.EMP_ID AND MDE.For_Date = D.FOR_DATE
			--WHERE MDE.Alternate_Emp_ID = @EMP_ID AND MDE.For_Date BETWEEN @Month_St_Date AND @Month_End_Date AND D.P_days <> 0
	
			----INSERTING HOLIDAYS - OLD CODE 
			--IF @Inc_Holiday = 1
			--	BEGIN
					
			--		INSERT INTO #DAILY_EFFICIENCY
			--		SELECT	MDE.Machine_ID , MDE.Shift_ID , T.For_Date , MDE.Efficiency ,  MDE.WeaverFlag,0 , 'H' , 1
			--		FROM	(	SELECT CAST(DATA AS DATETIME) AS FOR_DATE 
			--					FROM dbo.Split(@StrHoliday_Date, ';') 
			--					WHERE DATA <> ''
			--				 ) T
			--		 CROSS APPLY (SELECT	MAX(FOR_DATE)  AS FOR_DATE
			--					  FROM		#Data D
			--					  WHERE		D.For_date < T.FOR_DATE AND D.Emp_Id = @Emp_Id) D
			--		 CROSS APPLY (SELECT	MIN(FOR_DATE)  AS FOR_DATE
			--					  FROM		#Data D1
			--					  WHERE		D1.For_date > T.FOR_DATE AND D1.Emp_Id = @Emp_Id) D1
			--		 LEFT OUTER JOIN T0100_MACHINE_DAILY_EFFICIENCY MDE ON MDE.FOR_DATE=ISNULL(D.FOR_DATE,D1.FOR_DATE) AND MDE.Alternate_Emp_ID = @Emp_Id
			--	END
			
			--INSERT INTO #DAILY_EFFICIENCY
					--	(MACHINE_ID , SHIFT_ID , FOR_DATE , EFFICIENCY , WORKED_IN , LEAVE_COUNT , DAY_FLAG , P_Days)
					--SELECT 0 , 0 , FOR_DATE , 0 , '' , 0 , 'H' , 1 
					--FROM	(	SELECT CAST(DATA AS DATETIME) AS FOR_DATE 
					--			FROM dbo.Split(@StrHoliday_Date, ';') 
					--			WHERE DATA <> ''
					--		 ) T
		
			UPDATE DE
			SET DAY_FLAG = 'L' , LEAVE_COUNT = T.Leave_Used , P_Days = 1
			FROM #DAILY_EFFICIENCY DE
				INNER JOIN (SELECT FOR_DATE , Isnull(Leave_Used,0) AS Leave_Used
							FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.LEAVE_ID = LT.LEAVE_ID
							WHERE Emp_ID = @Emp_id and LEAVE_PAID_UNPAID = 'P' AND For_Date BETWEEN @Month_St_Date AND @Month_end_Date
								AND Calculate_on_Previous_Month = 0 and LT.Leave_Used > 0
							) T on t.FOR_DATE = DE.FOR_DATE
		
			--New Code--
			UPDATE	CT
			SET		PrevDate = (SELECT TOP 1 FOR_DATE FROM #DAILY_EFFICIENCY T 
								WHERE T.FOR_DATE < CT.FOR_DATE AND T.DAY_FLAG <> 'L' 
									AND T.FOR_DATE = (SELECT MAX(FOR_DATE) from #DAILY_EFFICIENCY T1 Where T1.FOR_DATE < CT.FOR_DATE AND T1.DAY_FLAG = 'P')),
					NxtDate = (SELECT TOP 1 FOR_DATE FROM #DAILY_EFFICIENCY T 
									WHERE T.FOR_DATE > CT.FOR_DATE AND T.DAY_FLAG <> 'L' 
										AND T.FOR_DATE = (SELECT MIN(FOR_DATE) from #DAILY_EFFICIENCY T1 Where T1.FOR_DATE > CT.FOR_DATE AND T1.DAY_FLAG = 'P'))
			FROM #DAILY_EFFICIENCY CT		
			WHERE	CT.DAY_FLAG='L'


			UPDATE 	CT
			SET		MACHINE_ID = isnull(prev.MACHINE_ID,nxt.MACHINE_ID),
					SHIFT_ID = isnull(prev.SHIFT_ID,nxt.SHIFT_ID) , 
					EFFICIENCY = isnull(prev.EFFICIENCY,nxt.EFFICIENCY) , 
					WORKED_IN = isnull(prev.WORKED_IN , nxt.WORKED_IN)
			FROM	#DAILY_EFFICIENCY CT
					LEFT OUTER JOIN #DAILY_EFFICIENCY prev ON CT.PrevDate = prev.FOR_DATE
					LEFT OUTER JOIN #DAILY_EFFICIENCY nxt ON CT.NxtDate = nxt.FOR_DATE
			WHERE  CT.DAY_FLAG='L'


		IF @Inc_Holiday = 1 AND @StrHoliday_Date <> ''
			BEGIN
				UPDATE DE
				SET DAY_FLAG = 'H' , P_Days = CASE WHEN @WeavingEmpType = 'WV' THEN 1 ELSE 0 END
				FROM #DAILY_EFFICIENCY DE
					INNER JOIN (SELECT CAST(DATA AS DATETIME) AS FOR_DATE 
								FROM dbo.Split(@StrHoliday_Date, ';') 
								WHERE DATA <> ''
								) T on t.FOR_DATE = DE.FOR_DATE
			
				IF @WeavingEmpType = 'BD'
					BEGIN
						UPDATE	CT
						SET		PrevDate = (SELECT TOP 1 FOR_DATE FROM #DAILY_EFFICIENCY T 
											WHERE T.FOR_DATE < CT.FOR_DATE AND T.DAY_FLAG <> 'H' 
												AND T.FOR_DATE = (select MAX(FOR_DATE) from #DAILY_EFFICIENCY T1 Where T1.FOR_DATE < CT.FOR_DATE AND T1.DAY_FLAG <> 'H')),
								NxtDate = (SELECT TOP 1 FOR_DATE FROM #DAILY_EFFICIENCY T 
												WHERE T.FOR_DATE > CT.FOR_DATE AND T.DAY_FLAG <> 'H' 
													AND T.FOR_DATE = (select MIN(FOR_DATE) from #DAILY_EFFICIENCY T1 Where T1.FOR_DATE > CT.FOR_DATE AND T1.DAY_FLAG <> 'H'))
						FROM #DAILY_EFFICIENCY CT		
						WHERE	CT.DAY_FLAG = 'H'
		
						UPDATE 	CT
						SET		P_Days = 1,
								MACHINE_ID = isnull(prev.MACHINE_ID,nxt.MACHINE_ID),
								SHIFT_ID = isnull(prev.SHIFT_ID,nxt.SHIFT_ID) , 
								EFFICIENCY = isnull(prev.EFFICIENCY,nxt.EFFICIENCY) , 
								WORKED_IN = isnull(prev.WORKED_IN , nxt.WORKED_IN)
						FROM	#DAILY_EFFICIENCY CT
								LEFT OUTER JOIN #DAILY_EFFICIENCY prev ON CT.PrevDate = prev.FOR_DATE
								LEFT OUTER JOIN #DAILY_EFFICIENCY nxt ON CT.NxtDate = nxt.FOR_DATE
						WHERE	CT.DAY_FLAG = 'H' AND IsNull(prev.DAY_FLAG, 'P') = 'P' AND IsNull(nxt.DAY_FLAG, 'P') = 'P'
					END
				ELSE
					BEGIN
						UPDATE	CT
						SET		PrevDate = (SELECT TOP 1 FOR_DATE FROM #DAILY_EFFICIENCY T 
											WHERE T.FOR_DATE < CT.FOR_DATE AND T.DAY_FLAG <> 'H' 
												AND T.FOR_DATE = (select MAX(FOR_DATE) from #DAILY_EFFICIENCY T1 Where T1.FOR_DATE < CT.FOR_DATE AND T1.DAY_FLAG = 'P')),
								NxtDate = (SELECT TOP 1 FOR_DATE FROM #DAILY_EFFICIENCY T 
												WHERE T.FOR_DATE > CT.FOR_DATE AND T.DAY_FLAG <> 'H' 
													AND T.FOR_DATE = (select MIN(FOR_DATE) from #DAILY_EFFICIENCY T1 Where T1.FOR_DATE > CT.FOR_DATE AND T1.DAY_FLAG = 'P'))
						FROM #DAILY_EFFICIENCY CT		
						WHERE	CT.DAY_FLAG = 'H'
		
						UPDATE 	CT
						SET		P_Days = 1,
								MACHINE_ID = isnull(prev.MACHINE_ID,nxt.MACHINE_ID),
								SHIFT_ID = isnull(prev.SHIFT_ID,nxt.SHIFT_ID) , 
								EFFICIENCY = isnull(prev.EFFICIENCY,nxt.EFFICIENCY) , 
								WORKED_IN = isnull(prev.WORKED_IN , nxt.WORKED_IN)
						FROM	#DAILY_EFFICIENCY CT
								LEFT OUTER JOIN #DAILY_EFFICIENCY prev ON CT.PrevDate = prev.FOR_DATE
								LEFT OUTER JOIN #DAILY_EFFICIENCY nxt ON CT.NxtDate = nxt.FOR_DATE
						WHERE	CT.DAY_FLAG = 'H'
								
					END
			END

			UPDATE D
			SET D.EFFICIENCY = T.Avg_Percent
			FROM #DAILY_EFFICIENCY D
			INNER JOIN
				(
					SELECT D.MACHINE_ID, MD.Avg_Percent 
					FROM #DAILY_EFFICIENCY D
					CROSS APPLY (
									  SELECT	ROUND(AVG(MD.Avg_Percent),0) AS Avg_Percent
									  FROM	(
											 SELECT	Cast(Data as Numeric) As Machine_ID 
											 FROM	dbo.Split(D.MACHINE_ID, '#') T 
											 WHERE  T.Data <> ''
											 ) T
											INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID
									)  MD							
					WHERE CHARINDEX('#' , Machine_ID) > 0 AND WORKED_IN NOT IN ('GRD' , '999' , '') --and DAY_FLAG = 'P'
				)T ON T.MACHINE_ID = D.MACHINE_ID AND D.EFFICIENCY = 0


		SELECT @Mchn_CL_Leave	=	SUM(LEAVE_COUNT) FROM #DAILY_EFFICIENCY WHERE DAY_FLAG = 'L' --and MACHINE_ID IS NOT NULL
		SELECT @Mchn_Holiday	=	SUM(P_DAYS) FROM #DAILY_EFFICIENCY WHERE DAY_FLAG = 'H' and P_Days = 1 --and MACHINE_ID IS NOT NULL


		IF @WeavingEmpType = 'WV'
			BEGIN
				--SINGLE MACHINE
				SELECT	 D.MACHINE_ID , SUM(D.P_Days) AS Days_Count ,Efficiency_ID , Round(Avg(D.EFFICIENCY),0) As AVG_PERCENT , WORKED_IN 
				INTO	#Single_Machine
				FROM	#DAILY_EFFICIENCY D
					CROSS APPLY (
									SELECT	Max(MEM.Efficiency_ID) As Efficiency_ID
									FROM	(
											SELECT	Cast(Data as Numeric) As Machine_ID 
											FROM	dbo.Split(D.MACHINE_ID, '#') T 
											WHERE  T.Data <> ''
											) T
										INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID AND MD.Shift_ID = D.SHIFT_ID
										LEFT OUTER JOIN T0040_MACHINE_EFFICIENCY_MASTER MEM WITH (NOLOCK) ON T.Machine_ID = MEM.Machine_ID								
								)  MD
				WHERE CHARINDEX('#' , Machine_ID) = 0 AND WORKED_IN NOT IN ('GRD' , '999' , '') 
				GROUP BY D.Machine_ID , Efficiency_ID	, WORKED_IN

				----UPDATING AVERAGE SEPARATELY , BECOZ NEED TO TAKE ONLY PHYSICAL PRESENT AVERAGE - (DONT DELETE THIS COMMENT)
				--UPDATE SM
				--SET AVG_PERCENT = QRY.AVG_PERCENT
				--FROM #Single_Machine SM
				--INNER JOIN 
				--		(SELECT D.MACHINE_ID ,  Round(Avg(D.EFFICIENCY),0) As AVG_PERCENT , WORKED_IN
				--		 FROM #DAILY_EFFICIENCY D
				--		 WHERE CHARINDEX('#' , Machine_ID) = 0 AND WORKED_IN NOT IN ('GRD' , '999' , '') AND DAY_FLAG = 'P'
				--		 GROUP BY D.Machine_ID, WORKED_IN
				--		)QRY ON QRY.MACHINE_ID = SM.MACHINE_ID

				--MINIMUM PERCENTAGE RULE
				UPDATE SM
				SET AVG_PERCENT = CASE WHEN MM.Machine_Type = 'IBIZA' AND SM.AVG_PERCENT < 65.00 THEN 65.00 
								      WHEN MM.Machine_Type <> 'IBIZA' AND SM.AVG_PERCENT < 80.00 THEN 80.00
								  ELSE AVG_PERCENT END
				FROM #Single_Machine SM
				INNER JOIN T0040_Machine_Master MM ON SM.MACHINE_ID = MM.Machine_ID


				--TAKING BASIC SALARY FROM SLABS OF MACHINE EFFICIENCY
				INSERT INTO #EFFICIENCY_SALARY
					( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT Q.MACHINE_ID , Q.Days_Count ,ISNULL(MES.Basic_Amount,@EMPMASTER_BASIC) ,0 , 0 , Q.WORKED_IN
				FROM #Single_Machine Q
				LEFT OUTER JOIN T0050_Machine_Efficiency_Slab MES WITH (NOLOCK) on MES.Avg_Percent = Q.AVG_PERCENT AND MES.Efficiency_ID = Q.Efficiency_ID
	
				--Adding Color Beam Allowance Machine wise--(START)
				UPDATE ES
				SET ES.Master_Basic = Master_Basic + ISNULL(MMA.Allow_amount,0)
				FROM #EFFICIENCY_SALARY ES
				INNER JOIN T0190_Machine_Monthly_Allowance MMA ON MMA.MACHINE_ID = ES.MACHINE_ID
				WHERE For_Date >= @Month_St_Date AND For_Date <= @Month_End_Date and Allow_amount <> 0 AND CHARINDEX('#' , ES.Machine_ID) = 0	
				--Adding Color Beam Allowance Machine wise--(END)
			

				--MULTIPLE Machine
				--TAKING BASIC SALARY FROM SLABS OF MACHINE EFFICIENCY	
				INSERT INTO #EFFICIENCY_SALARY
					( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT	 D.MACHINE_ID , SUM(D.P_Days) AS Days_Count , BASIC_SALARY , 0 , 0 , D.WORKED_IN --(BASIC_SALARY / @Sal_Fix_Days) * COUNT(D.MACHINE_ID) , 0 , D.WORKED_IN
				FROM	#DAILY_EFFICIENCY D
					CROSS APPLY (
								 SELECT	Avg(MD.BSC_SALARY) As BASIC_SALARY
								 FROM	(
											SELECT	Cast(Data as Numeric) As Machine_ID 
											FROM	dbo.Split(D.MACHINE_ID, '#') T 
											WHERE  T.Data <> ''
										) T
								 INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID	AND	D.SHIFT_ID = MD.Shift_ID			
								 --GROUP BY SHIFT_ID
								)  MD
				WHERE CHARINDEX('#' , Machine_ID) > 0 AND WORKED_IN NOT IN ('GRD' , '999' , '')
				GROUP BY D.Machine_ID , BASIC_SALARY , WORKED_IN 

				--INSERTING ALL UPPER GRADE WORKING - INCLUDED THE SCENERIO OF LEAVE AND HOLIDAY
				INSERT INTO #EFFICIENCY_SALARY
						( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT MACHINE_ID , SUM(P_DAYS) , EFFICIENCY , 0 , 0 , GM.Grd_Name
				FROM #DAILY_EFFICIENCY DE
					INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON  CAST(DE.MACHINE_ID AS NUMERIC) = GM.Grd_ID
				WHERE WORKED_IN = 'GRD' AND P_Days <> 0
				GROUP BY MACHINE_ID , EFFICIENCY , GM.Grd_Name


					---EXTRA WEAVER LOGIC--- Assistant Weaver sitting with Main Weaver
				INSERT INTO #EFFICIENCY_SALARY
					( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT 0 ,Count(For_date) , @EMPMASTER_BASIC ,0 , 0 , 'XTRA'
				FROM #DAILY_EFFICIENCY 
				WHERE P_DAYS > 0 AND WORKED_IN = '999'

				-----EXTRA WEAVER LOGIC--- Assistant Weaver sitting with Main Weaver
				--INSERT INTO #EFFICIENCY_SALARY
				--	( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				--SELECT 0 ,Count(For_date) , @EMPMASTER_BASIC ,0 , 0 , 'WV'
				--FROM #DATA 
				--WHERE P_DAYS > 0 AND FOR_DATE NOT IN (SELECT FOR_DATE FROM #DAILY_EFFICIENCY)

			END
		ELSE IF @WeavingEmpType = 'BD'
			BEGIN
				
				--Worked on Single Machine 
				SELECT Q.MACHINE_ID ,Q.Machine_Type, Q.Days_Count ,ISNULL(MES.Basic_Amount,504.25) AS Basic_Amount , Q.WORKED_IN
				INTO #TMP_MID_WISE
				FROM 
					(
						SELECT	 D.MACHINE_ID ,MD.Machine_Type, COUNT(D.MACHINE_ID) AS Days_Count ,Efficiency_ID , Round(Avg(D.EFFICIENCY),0) As AVG_PERCENT , WORKED_IN
						FROM	#DAILY_EFFICIENCY D
							CROSS APPLY (
											SELECT	Max(MEM.Efficiency_ID) As Efficiency_ID , MD.Machine_Type
											FROM	(
													SELECT	Cast(Data as Numeric) As Machine_ID 
													FROM	dbo.Split(D.MACHINE_ID, '#') T 
													WHERE  T.Data <> ''
													) T
												INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID
												LEFT OUTER JOIN T0040_MACHINE_EFFICIENCY_MASTER MEM WITH (NOLOCK) ON T.Machine_ID=MEM.Machine_ID		
											GROUP BY MD.Machine_Type						
										)  MD
						WHERE CHARINDEX('#' , Machine_ID) = 0	AND WORKED_IN NOT IN ('GRD' , '999' , '')							  				
						GROUP BY D.Machine_ID ,MD.Machine_Type, Efficiency_ID	, WORKED_IN
					)Q	
				LEFT OUTER JOIN T0050_Machine_Efficiency_Slab MES WITH (NOLOCK) on MES.Avg_Percent = Q.AVG_PERCENT AND MES.Efficiency_ID = Q.Efficiency_ID

				--Worked on Multiple Machine 
				INSERT INTO #TMP_MID_WISE
				SELECT	 D.MACHINE_ID , MD.Machine_Type, COUNT(D.MACHINE_ID) AS Days_Count , BASIC_SALARY , D.WORKED_IN
				FROM	#DAILY_EFFICIENCY D
					CROSS APPLY (
									 SELECT	Avg(MD.BSC_SALARY) As BASIC_SALARY , Machine_Type
									 FROM	(
												SELECT	Cast(Data as Numeric) As Machine_ID 
												FROM	dbo.Split(D.MACHINE_ID, '#') T 
												WHERE  T.Data <> ''
											) T
									 INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID	
									 GROUP BY MD.Machine_Type										
								)  MD
				WHERE CHARINDEX('#' , Machine_ID) > 0 AND WORKED_IN NOT IN ('GRD' , '999' , '')
				GROUP BY D.Machine_ID ,MD.Machine_Type, BASIC_SALARY , WORKED_IN
		

				/*
				--Worked on Multiple Machine 
				INSERT INTO #TMP_MID_WISE
				SELECT	 D.MACHINE_ID , MD.Machine_Type, COUNT(D.MACHINE_ID) AS Days_Count , BASIC_SALARY , D.WORKED_IN
				FROM	#DAILY_EFFICIENCY D
					CROSS APPLY (
								 SELECT	Avg(MD.BSC_SALARY) As BASIC_SALARY , Machine_Type
								 FROM	(
											SELECT	Cast(Data as Numeric) As Machine_ID 
											FROM	dbo.Split(D.MACHINE_ID, '#') T 
											WHERE  T.Data <> ''
										) T
								 INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID	
								 GROUP BY MD.Machine_Type										
								)  MD
				WHERE CHARINDEX('#' , Machine_ID) > 0
				GROUP BY D.Machine_ID ,MD.Machine_Type, BASIC_SALARY , WORKED_IN
				*/

				SELECT MM.MACHINE_TYPE , MES.AVG_PERCENT , MES.BASIC_AMOUNT 
				INTO #BADLI_MACHINE_EFFICIENCY
				FROM		[T0040_MACHINE_EFFICIENCY_MASTER] MEM WITH (NOLOCK)
				INNER JOIN	[T0040_MACHINE_MASTER] MM WITH (NOLOCK) ON MEM.MACHINE_ID = MM.MACHINE_ID
				INNER JOIN  [T0050_MACHINE_EFFICIENCY_SLAB] MES WITH (NOLOCK) ON MES.EFFICIENCY_ID = MEM.EFFICIENCY_ID
				GROUP BY MACHINE_TYPE , MES.AVG_PERCENT , MES.BASIC_AMOUNT


				SELECT	MD.Machine_Type, COUNT(D.MACHINE_ID) AS Days_Count , Round(Avg(D.EFFICIENCY),0) As AVG_PERCENT , WORKED_IN
				INTO	#GROUPING
				FROM	#DAILY_EFFICIENCY D
					CROSS APPLY (
									SELECT	Machine_Type
									FROM	(
											SELECT	Cast(Data as Numeric) As Machine_ID 
											FROM	dbo.Split(D.MACHINE_ID, '#') T 
											WHERE  T.Data <> ''
											) T
										INNER JOIN #MACHINE_EFFICIENCY MD ON T.Machine_ID = MD.Machine_ID
										LEFT OUTER JOIN T0040_MACHINE_EFFICIENCY_MASTER MEM WITH (NOLOCK) ON T.Machine_ID=MEM.Machine_ID
									GROUP BY Machine_Type								
								)  MD
				WHERE CHARINDEX('#' , Machine_ID) = 0 AND WORKED_IN NOT IN ('GRD' , '999' , '')					  				
				GROUP BY MD.Machine_Type,  WORKED_IN

				
				--Logic of Minimum 65% Efficiency -(START)-- Will be Used for Multiple Machine
				UPDATE G
				SET Avg_Percent = CASE WHEN Avg_Percent < 65.00 AND Machine_Type = 'IBIZA' THEN 65.00 
										WHEN Avg_Percent < 80.00 AND Machine_Type <> 'IBIZA' then 80.00 
									ELSE Avg_Percent END
				FROM #GROUPING G


				--COLOR BEAM PORTION STARTS HERE--
				SELECT MM.Machine_Type ,  MMA.* 
				INTO #TMP_MMA
				FROM T0190_Machine_Monthly_Allowance MMA WITH (NOLOCK)
				INNER JOIN T0040_Machine_Master MM WITH (NOLOCK) ON MMA.Machine_ID = MM.Machine_ID
				WHERE Allow_amount <> 0 and mma.For_Date = @Month_End_Date


				--INSERING SINGLE MACHINE WITH COLOR BEAM
				INSERT INTO #EFFICIENCY_SALARY
					( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT 0 , IsNull(MIDDays_Count, Days_Count) ,  (B.Basic_Amount + isnull(T.ALLOW_AMOUNT,0)) , 0 , 0 , G.WORKED_IN
				FROM	#GROUPING g
						LEFT OUTER JOIN (
										SELECT	MMA.Machine_Type, AVG(MMA.ALLOW_AMOUNT) AS ALLOW_AMOUNT,Sum(MID.Days_Count) As MIDDays_Count
										FROM	#TMP_MID_WISE MID
												INNER JOIN #TMP_MMA MMA ON MID.MACHINE_ID=MMA.Machine_ID and CHARINDEX('#' , MID.Machine_ID) = 0
										WHERE	For_Date = @Month_End_Date and Allow_amount <> 0 
										GROUP BY MMA.Machine_Type
									) t ON G.Machine_Type=T.Machine_Type
						INNER JOIN #BADLI_MACHINE_EFFICIENCY B ON G.Machine_Type=B.Machine_Type AND B.Avg_Percent = G.AVG_PERCENT
	
					
				--INSERING SINGLE MACHINE WITHOUT COLOR BEAM
				INSERT INTO #EFFICIENCY_SALARY
					( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT 0 ,  Days_Count-IsNull(MIDDays_Count,Days_Count)  ,  B.Basic_Amount , 0 , 0 , G.WORKED_IN
				FROM	#GROUPING g
						LEFT OUTER JOIN (
										SELECT	MMA.Machine_Type, AVG(MMA.ALLOW_AMOUNT) AS ALLOW_AMOUNT,Sum(MID.Days_Count) As MIDDays_Count
										FROM	#TMP_MID_WISE MID
												INNER JOIN #TMP_MMA MMA ON MID.MACHINE_ID=MMA.Machine_ID and CHARINDEX('#' , MID.Machine_ID) = 0
										WHERE	For_Date >= @Month_St_Date AND For_Date <= @Month_End_Date and Allow_amount <> 0 
										GROUP BY MMA.Machine_Type
									) t ON G.Machine_Type=T.Machine_Type
						INNER JOIN #BADLI_MACHINE_EFFICIENCY B ON G.Machine_Type=B.Machine_Type AND B.Avg_Percent=G.AVG_PERCENT
				WHERE	 Days_Count - IsNull(MIDDays_Count,Days_Count)  > 0
				
						
				--INSERING MULTIPLE MACHINE WITH COLOR BEAM
				INSERT INTO #EFFICIENCY_SALARY
					( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT 0 , AVG(Days_Count ), AVG(Basic_Amount ), 0 , 0 , WORKED_IN
				FROM #TMP_MID_WISE
				WHERE CHARINDEX('#' , Machine_ID) > 0
				GROUP BY WORKED_IN, MACHINE_ID


				--INSERTING ALL UPPER GRADE WORKING - INCLUDED THE SCENERIO OF LEAVE AND HOLIDAY
				INSERT INTO #EFFICIENCY_SALARY
						( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT MACHINE_ID , SUM(P_DAYS) , EFFICIENCY , 0 , 0 , isnull(GM.Grd_Name,'999')
				FROM #DAILY_EFFICIENCY DE
					LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON  CAST(DE.MACHINE_ID AS NUMERIC) = GM.Grd_ID
				WHERE (WORKED_IN = 'GRD' OR WORKED_IN = '999')  AND P_Days <> 0
				GROUP BY MACHINE_ID , EFFICIENCY , GM.Grd_Name


--SELECT * FROM #EFFICIENCY_SALARY		
--SELECT * FROM #DAILY_EFFICIENCY
/*
			--IF BADLI IS WORKING IN GRADEWISE SALARY , REPEATING THE CODE OF GRADEWISE IN THIS SP ALSO--
				------INSERTING ALL ATTENDANCE WITH ITS MASTER GRADE
				--INSERT INTO #EFFICIENCY_SALARY
				--		( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				--SELECT @Grd_ID ,  SUM(D.P_days) , @EMPMASTER_BASIC , 0 , 0 , '999'
				--FROM #DATA D
				--WHERE D.EMP_ID = @Emp_Id and P_days > 0

				--INSERTING ALL UPPER GRADE WORKING
				--INSERT INTO #EFFICIENCY_SALARY
				--		( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				--SELECT CAST(EGD.Grd_ID AS VARCHAR(5)) , SUM(D.P_days) , GM.Fix_Basic_Salary , 0 , 0 , GM.Grd_Name
				--FROM #T0100_EMP_GRADE_DETAIL EGD 
				--	INNER JOIN #DATA D ON EGD.Emp_ID = D.Emp_Id AND EGD.For_Date = D.For_date 
				--	INNER JOIN T0040_GRADE_MASTER GM ON  EGD.Grd_ID = GM.Grd_ID
				--WHERE D.P_days <> 0 AND EGD.Grd_ID <> @Grd_Id
				--GROUP BY EGD.Grd_ID , GM.Fix_Basic_Salary , GM.Grd_Name	
				
				--NOW REMOVING ALL UPPER GRADE DAYS AND EFFICIENCY DAYS FROM MASTER GRADE
				DECLARE @WORKED_OTHER_GRADE AS NUMERIC(18,2)
				SELECT @WORKED_OTHER_GRADE = SUM(Days_Count) FROM #EFFICIENCY_SALARY WHERE WORKED_IN <> '999'

				--SET @WORKED_OTHER_GRADE = ISNULL(@WORKED_OTHER_GRADE,0) - (ISNULL(@Mchn_CL_Leave,0) + ISNULL(@Mchn_Holiday,0))	--Removing Leave here , because in #Data only present days are their , so we need to minus only present days 


				UPDATE #EFFICIENCY_SALARY		--Update Master Grade P Days //Day shift
				SET Days_Count = Days_Count - ISNULL(@WORKED_OTHER_GRADE,0)
				WHERE WORKED_IN = '999'



				--INSERTING ALL LEAVE / HOLIDAY WITH ITS MASTER GRADE (IF WORKED IN OWN GRADE FOR WHOLE MONTH AND 1 DAY IN MACHINE)
				INSERT INTO #EFFICIENCY_SALARY
						( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				SELECT ISNULL(EGD.Grd_ID, @Grd_ID) ,  1 , ISNULL(GM.Fix_Basic_Salary , @EMPMASTER_BASIC) , 0 , 0 , ISNULL(GM.Grd_Name , '999')
				FROM #DAILY_EFFICIENCY D
				CROSS APPLY (
								SELECT	MAX(FOR_DATE)  AS FOR_DATE
								FROM		#T0100_EMP_GRADE_DETAIL T
								WHERE		T.For_date < D.FOR_DATE AND T.Emp_Id=@Emp_Id
							) Q-- ON Q.FOR_DATE=D.FOR_DATE AND EGD.Emp_ID=@Emp_Id
				LEFT OUTER JOIN #T0100_EMP_GRADE_DETAIL EGD ON EGD.FOR_DATE = Q.FOR_DATE AND EGD.Emp_ID=@Emp_Id
				LEFT OUTER JOIN T0040_GRADE_MASTER GM ON GM.Grd_ID = EGD.Grd_ID
				WHERE DAY_FLAG in ('L' , 'H') --and MACHINE_ID IS NULL
*/
	--select * from #EFFICIENCY_SALARY

				----INSERTING ALL LEAVE / HOLIDAY WITH ITS MASTER GRADE (IF WORKED IN OWN GRADE FOR WHOLE MONTH AND 1 DAY IN MACHINE)
				--INSERT INTO #EFFICIENCY_SALARY
				--		( Machine_ID , Days_Count , Master_Basic , Calculated_Basic , DA_Allow_Salary , WORKED_IN )
				--SELECT ISNULL(EGD.Grd_ID, @Grd_ID) ,  1 , ISNULL(GM.Fix_Basic_Salary , @EMPMASTER_BASIC) , 0 , 0 , ISNULL(GM.Grd_Name , '999')
				--FROM #DAILY_EFFICIENCY D
				--CROSS APPLY (
				--				SELECT	MAX(FOR_DATE)  AS FOR_DATE
				--				FROM		T0100_EMP_GRADE_DETAIL T
				--				WHERE		T.For_date = D.FOR_DATE AND T.Emp_Id=@Emp_Id
				--			) Q-- ON Q.FOR_DATE=D.FOR_DATE AND EGD.Emp_ID=@Emp_Id
				--LEFT OUTER JOIN T0100_EMP_GRADE_DETAIL EGD ON EGD.FOR_DATE=Q.FOR_DATE AND EGD.Emp_ID=@Emp_Id
				--LEFT OUTER JOIN T0040_GRADE_MASTER GM ON GM.Grd_ID = EGD.Grd_ID
				--WHERE DAY_FLAG in ('L' , 'H') and MACHINE_ID IS NULL

			END

			--NOTE:- NO NEED TO ADD COLOR BEAM IN MULTIPLE MACHINE , AS IT IS ALREADY ADDED AT TOP--
		
		END


	/***** FINAL COMMON CODE FOR ALL TYPE OF EMPLOYEES ****/

			UPDATE 	#EFFICIENCY_SALARY
			SET		Master_Basic = CASE WHEN WORKED_IN = 'AT' 
											THEN (((Master_Basic - 250.45) * 1.14) + 250.45) + 25.42 
										WHEN WORKED_IN = 'OL'
											THEN (((Master_Basic - 250.45) * 0.35) + 250.45)
										ELSE  
											Master_Basic 
										END

			--Comparing Basic Salary with Employee Master Basic ( NOT for Badali Employees)
			IF @WeavingEmpType <> 'BD'
				BEGIN
					UPDATE #EFFICIENCY_SALARY
					SET Master_Basic = CASE WHEN @EMPMASTER_BASIC > Master_Basic THEN @EMPMASTER_BASIC ELSE Master_Basic END
				END
	
			UPDATE #EFFICIENCY_SALARY
			SET CALCULATED_BASIC =  (Master_Basic / @Sal_Fix_Days) * Days_Count


			SELECT @Salary_Amount = ISNULL(SUM(Calculated_Basic),0) FROM #EFFICIENCY_SALARY

--Just Printed for Verification--
Print 'Machine Based Salary :- SP_CALCULATE_MACHINE_BASED_SALARY'
Print '*********************************************************'
print 'Employee TYPE is:- ' + CAST(@WeavingEmpType as varchar(20))
print 'Employee ID is:- ' + CAST(@Emp_Id as varchar(20))
print 'BASIC Salary is:- ' +  CAST(@Salary_Amount as varchar(20))
			
/*
--*********** Temporary code for Recess Allowance added on 29/03/2018 - (Need to define new field in formula allowance) ****************--
			DECLARE @AD_ID as numeric
			DECLARE @Tran_id as numeric
			SELECT @Days = ISNULL(Days_Count,0) FROM #EFFICIENCY_SALARY WHERE WORKED_IN = 'AT'
		
			SET @AD_ID = 0 
			SET @Tran_id = 0 
			
			IF EXISTS (Select AD_ID from T0050_AD_MASTER where AD_NAME = 'RECESS ALLOW' and CMP_ID = @Cmp_ID)
				BEGIN
					DELETE FROM T0195_Allowance_Days
					SELECT @AD_ID = Isnull(AD_ID,0) from T0050_AD_MASTER where AD_NAME = 'RECESS ALLOW' and CMP_ID = @Cmp_ID
					

					IF @Days > 0
						BEGIN
							IF Exists (select Tran_Id from T0195_Allowance_Days where AD_ID = @AD_ID and Cmp_Id = @Cmp_ID and [MONTH] = MONTH(@Month_St_Date) and [YEAR] = YEAR(@Month_St_Date))
								BEGIN
										Select @Tran_id = Tran_Id from T0195_Allowance_Days where AD_ID = @AD_ID and Cmp_Id = @Cmp_ID and [MONTH] = MONTH(@Month_St_Date) and [YEAR] = YEAR(@Month_St_Date)

										Update T0195_Allowance_Days 
										SET [Month] = MONTH(@Month_St_Date),[Year] = YEAR(@Month_St_Date),[Days] = @Days
										where Tran_Id = @Tran_id
								END
							ELSE
								BEGIN
										Select @Tran_id = Isnull(max(Tran_Id),0) + 1  From dbo.T0195_Allowance_Days

										INSERT INTO T0195_Allowance_Days 
										Values (@Tran_id,@Cmp_ID,@AD_ID,MONTH(@Month_St_Date),YEAR(@Month_St_Date),@Days)
								END
						END
				END
*/
END



