
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_LOCKED_ATTENDANCE]
	@Cmp_ID         NUMERIC,      
    @From_Date      DATETIME,      
    @To_Date        DATETIME ,      
    @Branch_ID      NUMERIC= 0,      
    @Cat_ID         NUMERIC= 0,      
    @Grd_ID         NUMERIC= 0,      
    @Type_ID        NUMERIC= 0,      
    @Dept_ID        NUMERIC= 0,      
    @Desig_ID       NUMERIC= 0,      
    @Emp_ID         NUMERIC= 0,      
    @Constraint     VARCHAR(MAX) = '',      
    @PBranch_ID     VARCHAR(200) = '0',
    @Order_By       VARCHAR(30) = 'Code' 
As
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	BEGIN

				
		IF NOT EXISTS(SELECT 1 FROM T0185_LOCKED_IN_OUT WITH (NOLOCK) WHERE FOR_DATE = @From_Date)
			AND NOT EXISTS(SELECT 1 FROM T0185_LOCKED_IN_OUT WITH (NOLOCK) WHERE FOR_DATE = @To_Date)
			RAISERROR('Attendance is not locked for this period',16,1)

	
		IF @BRANCH_ID = 0  
			SET @BRANCH_ID = NULL
		
		IF @CAT_ID = 0  
			SET @CAT_ID = NULL

		IF @GRD_ID = 0  
			SET @GRD_ID = NULL

		IF @TYPE_ID = 0  
			SET @TYPE_ID = NULL

		IF @DEPT_ID = 0  
			SET @DEPT_ID = NULL

		IF @DESIG_ID = 0  
			SET @DESIG_ID = NULL

		IF @EMP_ID = 0  
			SET @EMP_ID = NULL
		
		CREATE TABLE #EMP_CONS
		(
			EMP_ID			NUMERIC,
			BRANCH_ID		NUMERIC,
			INCREMENT_ID	NUMERIC
		)

		EXEC dbo.SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0
		

	
		SELECT	LA.Lock_Id,EC.Emp_ID, EC.Increment_ID, Cast(DateDiff(dd,Case When @From_Date < EM.Date_Of_Join Then EM.Date_Of_Join Else @From_Date End , Case When @To_Date > EM.Emp_Left_Date And Not EM.Emp_Left_Date Is Null Then EM.Emp_Left_Date Else @To_Date End) + 1 As Numeric(18,2)) as Month_Days, 
				Sum(P_Days) As Present_Days, Cast(0 As Numeric(18,2)) As Absent_Days,
				Sum(W_Days) As Weekoff_Days, Isnull(Sum(H_Days),0) As Holiday,
				Isnull(Sum(Leave_Days),0) As Leave_Days, Isnull(Max(LateSalDeduDays),0) As LateSalDeduDays
		INTO	#T0185_LOCKED_IN_OUT
		FROM	T0185_LOCKED_IN_OUT LA WITH (NOLOCK)
				INNER JOIN #EMP_CONS EC ON LA.EMP_ID=EC.EMP_ID
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) On EC.EMP_ID = EM.Emp_ID				
		WHERE	LA.For_Date BETWEEN @FROM_DATE AND @TO_DATE
		GROUP BY EC.Emp_ID, EC.Increment_ID,EM.Date_Of_Join,EM.Emp_Left_Date,LA.Lock_Id


		DECLARE @OD_CompOff_ConsiderAsPresent BIT
		SET @OD_CompOff_ConsiderAsPresent = 0
		IF EXISTS(SELECT 1 FROM T0040_SETTING WITH (NOLOCK) WHERE Setting_Name='OD and CompOff Leave Consider As Present' AND Setting_Value='1' AND Cmp_ID=@Cmp_ID)
			SET @OD_CompOff_ConsiderAsPresent = 1
		
		
		SELECT	Leave_ID, Leave_Code, Leave_Sorting_No
		INTO	#T0040_LEAVE_MASTER
		FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
		WHERE	(@OD_CompOff_ConsiderAsPresent = 0 
					OR (@OD_CompOff_ConsiderAsPresent = 1 
								AND (LM.Leave_Type <> 'Company Purpose' 
											AND LM.Default_Short_Name NOT IN ('COMP', 'COPH', 'COND')
									)
						)
				) AND Cmp_ID=@Cmp_ID


		/*Late Early Adjustment Days*/
		SELECT	LE.Emp_ID,LE.Leave_ID,LE.Sort_ID,LE.Leave_Code,LE.AdjustDays As LeaveDays
		INTO	#LateEarlyAdjustData
		FROM	#T0185_LOCKED_IN_OUT LA
				INNER JOIN 
					(SELECT LE.Emp_ID, LE.Leave_ID, LE.Sort_ID, LE.AdjustDays , L.Leave_Code
					 FROM	T0185_LOCKED_LATE_EARLY_ADJUST LE WITH (NOLOCK)
							INNER JOIN (SELECT LEAVE_ID, 'Penalty_' + Leave_Code Leave_Code FROM #T0040_LEAVE_MASTER
										UNION ALL
										SELECT -1, 'LD') L ON LE.Leave_ID=L.Leave_ID
					 WHERE	LE.To_Date = @To_Date
					 UNION 
					 SELECT LL.Emp_ID, LL.Leave_ID, LM.Leave_Sorting_No, 0 As Adjust_Days, LM.Leave_Code
					 FROM	T0185_LOCKED_LEAVE LL WITH (NOLOCK)
							INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LL.Leave_ID=LM.Leave_ID
					 WHERE	LL.For_Date Between @From_Date AND @To_Date
					 GROUP BY LL.Emp_ID, LL.Leave_ID, LM.Leave_Sorting_No,LM.Leave_Code
					)LE ON LA.Emp_ID=LE.Emp_ID 
				--INNER JOIN (SELECT DISTINCT EMP_ID, LEAVE_ID FROM T0185_LOCKED_LATE_EARLY_ADJUST) T
				--INNER JOIN (SELECT LEAVE_ID, Leave_Code FROM #T0040_LEAVE_MASTER
							--UNION ALL
							--SELECT -1, 'LD') L ON LE.Leave_ID=L.Leave_ID		
		Order by Emp_ID,Sort_ID

		
		
		IF EXISTS(SELECT 1 FROM #LateEarlyAdjustData)
			BEGIN		
				IF NOT EXISTS(SELECT 1 FROM #LateEarlyAdjustData Where Leave_ID = -1)		
					INSERT INTO #LateEarlyAdjustData (Emp_ID,Leave_ID,Sort_ID,Leave_Code,LeaveDays)
					SELECT DISTINCT Emp_ID, -1, 999, 'LD', 0 FROM #EMP_CONS					

				Update	LA
				Set		Present_Days = IsNull(Present_Days,0) - IsNull(T.LeaveDays,0),
						Leave_Days = IsNull(LA.Leave_Days,0) + IsNull(T.AdjustDays,0)
				FROM	#T0185_LOCKED_IN_OUT LA
						INNER JOIN (SELECT	EMP_ID, SUM(LeaveDays) LeaveDays, SUM(Case When Leave_ID = -1 Then 0 Else LeaveDays End) As AdjustDays
									FROM	#LateEarlyAdjustData
									GROUP BY EMP_ID) T ON LA.EMP_ID=T.Emp_ID

		
				--Adding Used Leaves in Particular Leave Column (CL, PL, etc.)
				UPDATE	LEA
				SET		LeaveDays = IsNull(LEA.LeaveDays,0) + IsNull(T.LeaveDays,0)
				FROM	#LateEarlyAdjustData LEA
						INNER JOIN (Select	Emp_ID,LL.Leave_ID,LM.Leave_Code,ISnull(Sum(LL.Leave_Days),0) As LeaveDays
									FROM	T0185_LOCKED_LEAVE LL WITH (NOLOCK)
											INNER JOIN #T0040_LEAVE_MASTER LM ON LL.Leave_ID=LM.Leave_ID
									WHERE	LL.For_Date between @From_Date and @To_date and
											EXISTS(SELECT 1 FROM #LateEarlyAdjustData T 
                                                  WHERE LL.Emp_ID=T.Emp_ID AND LL.Leave_ID=T.Leave_ID AND T.Leave_Code=LM.Leave_Code
														)
									GROUP BY Emp_ID,LL.Leave_ID,LM.Leave_Code) T ON LEA.Emp_ID=T.Emp_ID AND LEA.Leave_ID=T.Leave_ID AND LEA.Leave_Code=T.Leave_Code
		
				Insert Into #LateEarlyAdjustData
				Select	LL.Emp_ID,LL.Leave_ID,LM.Leave_Sorting_No,LM.Leave_Code,ISnull(Sum(LL.Leave_Days),0)
				FROM	T0185_LOCKED_LEAVE LL WITH (NOLOCK)
						INNER JOIN #EMP_CONS EC ON LL.EMP_ID=EC.EMP_ID
						INNER JOIN #T0040_LEAVE_MASTER LM ON LL.Leave_ID=LM.Leave_ID
				WHERE	LL.For_Date between @From_Date and @To_date and
						NOT EXISTS(SELECT 1 FROM #LateEarlyAdjustData T WHERE LL.Emp_ID=T.Emp_ID AND LL.Leave_ID=T.Leave_ID)
				GROUP BY LL.Emp_ID,LL.Leave_ID,LM.Leave_Sorting_No,LM.Leave_Code
		
		
			
/*Opening Balance*/
				UPDATE	T
				SET		Sort_ID=(T1.ROW_ID * 2)-1
				FROM	#LateEarlyAdjustData T 
						INNER JOIN (SELECT	Leave_ID, ROW_NUMBER() OVER(ORDER BY SORT_ID) AS ROW_ID 
									FROM	(SELECT DISTINCT Leave_ID, Sort_ID FROM #LateEarlyAdjustData) T1) T1 ON T.Leave_ID=T1.Leave_ID						
				Where	Sort_ID < 9999

				
				
				Insert 	Into #LateEarlyAdjustData
				SELECT	EC.Emp_ID,Q.Leave_ID,Q.Sort_ID,Q.Leave_Code,0 As LeaveDays
				FROM 	#EMP_CONS EC,
						(
							SELECT DISTINCT LM.Leave_ID,LL.Sort_ID,LM.Leave_Code
							FROM   #T0040_LEAVE_MASTER LM 
								   INNER JOIN #LateEarlyAdjustData LL ON LL.Leave_ID=LM.Leave_ID
						)Q 						
				WHERE	NOT EXISTS(SELECT 1 FROM #LateEarlyAdjustData T WHERE T.Emp_ID=EC.Emp_ID and T.Leave_ID=Q.Leave_ID)
				
				
						
				INSERT INTO #LateEarlyAdjustData(Emp_ID, Leave_ID, Sort_ID, Leave_Code, LeaveDays)
				SELECT	T.EMP_ID, T.LEAVE_ID, SORT_ID - 1, LM.LEAVE_CODE + '_Opening', 0 
				FROM	(SELECT DISTINCT EMP_ID, LEAVE_ID, SORT_ID FROM #LateEarlyAdjustData) T
						INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.LEAVE_ID=LM.LEAVE_ID
				WHERE	LM.Leave_Type <> 'Company Purpose' AND LM.Default_Short_Name NOT IN ('COMP', 'COPH', 'COND', 'LWP')						
				
			

				UPDATE	T
				SET		LeaveDays = IsNull(LT.Leave_closing,0)
				FROM	#LateEarlyAdjustData T
						INNER JOIN (SELECT	LT.EMP_ID, LT.LEAVE_ID, LT.LEAVE_CLOSING + ISNULL(LT2.LEAVE_USED,0) AS LEAVE_CLOSING
									FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) 
											INNER JOIN #EMP_CONS EC ON LT.EMP_ID=EC.EMP_ID
											INNER JOIN (SELECT	LT.EMP_ID, LT.LEAVE_ID, MAX(LT.FOR_DATE) AS FOR_DATE
														FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																INNER JOIN #EMP_CONS EC ON LT.EMP_ID=EC.EMP_ID
														WHERE	LT.FOR_DATE <= @From_Date
														GROUP BY LT.EMP_ID, LT.LEAVE_ID) LT1 ON LT.EMP_ID=LT1.EMP_ID 
																	AND LT.FOR_DATE=LT1.FOR_DATE 
																	AND LT1.LEAVE_ID=LT.LEAVE_ID
											LEFT OUTER JOIN (SELECT	LT.EMP_ID, LT.LEAVE_ID, SUM(LT.Leave_Used) AS LEAVE_USED, FOR_DATE
														FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
																INNER JOIN #EMP_CONS EC ON LT.EMP_ID=EC.EMP_ID
														WHERE	LT.FOR_DATE = @From_Date
														GROUP BY LT.EMP_ID, LT.LEAVE_ID,FOR_DATE) LT2 ON LT.EMP_ID=LT2.EMP_ID  AND LT.LEAVE_ID = LT2.Leave_ID
									) LT ON T.EMP_ID=LT.EMP_ID AND T.LEAVE_ID=LT.LEAVE_ID
									
				Where	Leave_Code like '%_Opening'

				
				
				UPDATE	T
				SET		LeaveDays = IsNull(LT.LEAVE_OPENING,LeaveDays)
				FROM	#LateEarlyAdjustData T
						INNER JOIN (SELECT	LT.EMP_ID, LT.LEAVE_ID, LT.LEAVE_OPENING
									FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
											INNER JOIN #EMP_CONS EC ON LT.EMP_ID=EC.EMP_ID
											INNER JOIN T0095_LEAVE_OPENING OP WITH (NOLOCK) ON LT.FOR_DATE=OP.FOR_DATE AND LT.EMP_ID = OP.EMP_ID AND LT.LEAVE_ID=OP.LEAVE_ID
									WHERE	LT.FOR_DATE=@From_Date
									) LT ON T.EMP_ID=LT.EMP_ID AND T.LEAVE_ID=LT.LEAVE_ID
				Where	Leave_Code like '%_Opening'
				/*End of Opening Balance*/
		

		
				DECLARE @COLS NVARCHAR(MAX)
				DECLARE @UPDATE_COLS NVARCHAR(MAX)
				DECLARE @ALTER_COLS NVARCHAR(MAX)

				SELECT	@COLS = COALESCE(@COLS + ',', '') +  QUOTENAME(Leave_Code),
						@UPDATE_COLS = COALESCE(@UPDATE_COLS + ',', '') +  QUOTENAME(Leave_Code) + ' = IsNull(p.' + QUOTENAME(Leave_Code) + ',0)',
						@ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE #T0185_LOCKED_IN_OUT ADD ' + QUOTENAME(Leave_Code) + ' NUMERIC(9,4) CONSTRAINT T_CONSTRAINT_' + Leave_Code + ' DEFAULT(0) WITH VALUES '
				FROM	(SELECT DISTINCT Sort_ID, Leave_Code FROM #LateEarlyAdjustData) T				
				Order by Sort_ID


				
				exec sp_executesql @ALTER_COLS

		
				Update #T0185_LOCKED_IN_OUT
				Set Absent_Days = Month_Days - (Present_Days + Isnull(Weekoff_Days,0) + Isnull(Holiday,0) + Isnull(Leave_Days,0))

				-- here Check Late Days if Employee dont have leave balance and adjust late with absent
				Update LIO
				  SET Absent_Days = Absent_Days - Isnull(LeaveDays,0)
				From #T0185_LOCKED_IN_OUT LIO INNER JOIN #LateEarlyAdjustData LEA
				ON LIO.EMP_ID = LEA.Emp_ID and LEA.Leave_Code = 'LD'
		
				DECLARE @SQL NVARCHAR(MAX)
				SET	@SQL = N'UPDATE	LA
							 SET	' + @UPDATE_COLS +  ',
									Absent_Days = IsNull(Absent_Days,0) + IsNull(P.[LD],0)
							 FROM	(SELECT EMP_ID, Leave_Code,LeaveDays
									 FROM	#LateEarlyAdjustData) T
									pivot 
									(
										Sum(LeaveDays) For Leave_Code IN ('  + @COLS + ')
									) p
									INNER JOIN #T0185_LOCKED_IN_OUT LA  ON P.Emp_ID=LA.EMP_ID;'
	
				exec sp_executesql @SQL
			END
		Else
			Begin
				Update #T0185_LOCKED_IN_OUT
				Set Absent_Days = Month_Days - (Present_Days + Isnull(Weekoff_Days,0) + Isnull(Holiday,0) + Isnull(Leave_Days,0))
			End

		/*Late Early Adjustment Days*/

		--ALTER TABLE #T0185_LOCKED_IN_OUT DROP COLUMN Leave_Days
		--ALTER TABLE #T0185_LOCKED_IN_OUT DROP COLUMN LateSalDeduDays
		--ALTER TABLE #T0185_LOCKED_IN_OUT DROP CONSTRAINT T_CONSTRAINT_LD
		--ALTER TABLE #T0185_LOCKED_IN_OUT DROP COLUMN LD

		SELECT	E.Alpha_Emp_Code As Employee_Code, E.Emp_Full_Name As Employee_Name, B.Branch_Name, D.Dept_Name As Department, 
				DG.Desig_Name As Designation, G.Grd_Name As Grade, C.Cmp_Name As Company_Name,
				LA.*				
		INTO	#FINAL
		FROM	#T0185_LOCKED_IN_OUT LA
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID=LA.EMP_ID
				INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID=LA.INCREMENT_ID
				INNER JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID=I.Branch_ID
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_ID=I.Dept_ID
				INNER JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) ON DG.Desig_ID=I.Desig_ID
				INNER JOIN T0040_GRADE_MASTER G WITH (NOLOCK) ON G.Grd_ID=I.Grd_ID
				INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_ID=I.Cmp_ID		
		
		
	
		ALTER TABLE #FINAL DROP COLUMN Leave_Days
		ALTER TABLE #FINAL DROP COLUMN LateSalDeduDays		
		IF EXISTS(SELECT 1 FROM #LateEarlyAdjustData)
			ALTER TABLE #FINAL DROP COLUMN LD 
		
		ALTER TABLE #FINAL DROP COLUMN Emp_ID
		ALTER TABLE #FINAL DROP COLUMN Increment_ID
		ALTER TABLE #FINAL DROP COLUMN Lock_Id
		SELECT  * FROM #FINAL			

	END

