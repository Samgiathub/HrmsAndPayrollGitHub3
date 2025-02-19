

-- =============================================
-- Author:		<Jaina>
-- Create date: <07-05-2018>
-- Description:	<Paternity Leave Laps>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Reset_Paternity_Leave]
	@Cmp_Id numeric(18,0),
	@Emp_id numeric(18,0) = 0
	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Leave_ID Numeric
	DECLARE @WO_As_Leave As Bit
	DECLARE @HO_As_Leave As Bit
	DECLARE @Request_Type_ID As Int
	DECLARE @Validity_Days	INT
	
	Create table #Paternity_Leave
	(
		Leave_Tran_Id numeric(18,0),
		Emp_id numeric(18,0),
		For_Date datetime,
		Leave_Opening numeric(18,2),
		Leave_Closing numeric(18,2),
		Laps_Days numeric(18,2),
		From_Date datetime,
		To_Date datetime
	)
	Select @Request_Type_ID = Request_id FROM T0040_Change_Request_Master WITH (NOLOCK) WHERE Request_type='Child Birth Detail' AND Flag = 0
	

	if @Emp_id = 0
		set @Emp_id = NULL
	
	IF @Request_Type_ID IS NULL
		RETURN

	SELECT	@Leave_ID = Leave_ID,@WO_As_Leave=Weekoff_as_leave,@HO_As_Leave=Holiday_as_leave,@Validity_Days = IsNull(Paternity_Leave_Validity, 20)
	FROM	T0040_LEAVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND Leave_Type='Paternity Leave'

	IF @Leave_ID IS NULL	
		RETURN
	
	
	INSERT INTO #Paternity_Leave (Leave_Tran_Id,Emp_id,For_Date,Leave_Opening,Leave_Closing,Laps_Days,From_Date,To_Date)
	SELECT	Leave_Tran_ID,LT.Emp_ID,LT.FOR_DATE,Leave_Opening,Leave_Closing,CF_Laps_Days, CAST('1900-01-01' AS DATETIME) AS FROM_DATE, CAST('1900-01-01' AS DATETIME) AS TO_DATE	
	FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
			INNER JOIN (SELECT	EMP_ID, MAX(FOR_DATE) AS FOR_DATE
						FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)
						WHERE	LT1.FOR_DATE >= DATEADD(D, -31,GETDATE()) AND Leave_ID=@Leave_ID
						GROUP BY EMP_ID) LT1 ON LT.Emp_ID=LT1.Emp_ID AND LT.For_Date=LT1.FOR_DATE
	WHERE	Leave_ID=@Leave_ID --AND Leave_Closing > 0 
			AND LT.Emp_ID = ISNULL(@Emp_ID,LT.Emp_ID)
			AND EXISTS(SELECT 1 FROM T0135_Paternity_Leave_Detail PLD WITH (NOLOCK)
						WHERE	PLD.Emp_Id=LT.Emp_ID AND PLD.For_Date BETWEEN DATEADD(D,-60, LT.For_Date) AND LT.FOR_DATE
								AND PLD.Laps_Status='Pending' AND PLD.Validity_Days <> 0)
								--and validity_days <> 0 Added by Jaina 19-01-2019 if leave validity period not set that time allow to leave.
	
	


	IF NOT EXISTS(SELECT 1 FROM #Paternity_Leave)
		RETURN;

	UPDATE	T
	SET		FROM_DATE = Child_Birth_Date,
			TO_DATE = DATEADD(D,@Validity_Days,Child_Birth_Date)
	FROM	#Paternity_Leave T
			INNER JOIN T0090_Change_Request_Approval CRA ON (CRA.Child_Birth_Date BETWEEN DATEADD(D,-365,T.For_Date) AND T.For_Date) AND CRA.Emp_ID=T.Emp_ID AND CRA.Request_Type_id=@Request_Type_ID

			--Added by mehul condition of -365 (D,-365,T.For_Date) in above earlier it was default set to -31, which was calculating for only 31 days behind As per discussion with sandip and chintan (22-may-2023) Bug #25166	

	IF @WO_As_Leave = 0 OR @HO_As_Leave = 0
		BEGIN
			DECLARE @FROM_DATE DATETIME
			DECLARE @TO_DATE DATETIME
			SELECT	@FROM_DATE = MIN(FROM_DATE), @TO_DATE = DATEADD(D,10, MAX(TO_DATE)) 
			FROM	#Paternity_Leave WHERE FROM_DATE > DATEADD(D,-60,GETDATE())
			
			

			DECLARE @Exec_Mode TinyInt 
			SET @Exec_Mode = CASE WHEN @WO_As_Leave=0 AND @HO_As_Leave=0 THEN 0 WHEN @WO_As_Leave = 0 THEN 1 WHEN @HO_As_Leave = 0 THEN 2 END



			IF @WO_As_Leave = 0
				BEGIN
					--WeekOff - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
					CREATE TABLE #Emp_WeekOff
					(
						Row_ID			NUMERIC,
						Emp_ID			NUMERIC,
						For_Date		DATETIME,
						Weekoff_day		VARCHAR(10),
						W_Day			numeric(4,1),
						Is_Cancel		BIT
					)
					CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);

				END

			IF @HO_As_Leave = 0
				BEGIN
					CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
					CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
				END

			DECLARE @CONSTRAINT VARCHAR(MAX)

			SELECT	@CONSTRAINT = ISNULL(@CONSTRAINT + '#', '') + CAST(EMP_ID AS VARCHAR(10))
			FROM	(SELECT DISTINCT EMP_ID FROM #Paternity_Leave) T
			
			EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 1, @Exec_Mode=@Exec_Mode


			SELECT	ROW_ID, DATEADD(D, ROW_ID-1,@FROM_DATE) AS FOR_DATE, CAST(1 AS NUMERIC(5,2)) AS WORKING_DAY
			INTO	#PT_DATES
			FROM	(SELECT Top 60 ROW_NUMBER() OVER (ORDER BY OBJECT_ID) AS ROW_ID FROM sys.objects ) T
			
			
			
			SELECT	T.Leave_Tran_ID,T.EMP_ID, WO.W_Day, HO.H_DAY,T.FOR_DATE, CASE WHEN ISNULL(WO.W_Day,0) + ISNULL(HO.H_DAY,0) > 0 THEN 0 ELSE  T.WORKING_DAY END AS WORKING_DAY
			INTO	#ROW_TABLE
			FROM	(SELECT T.Leave_Tran_ID,T.Emp_ID,D.FOR_DATE,D.WORKING_DAY FROM #Paternity_Leave T CROSS JOIN #PT_DATES D) T					
					LEFT OUTER JOIN #Emp_WeekOff WO ON T.Emp_ID=WO.Emp_ID AND T.FOR_DATE=WO.For_Date
					LEFT OUTER JOIN #EMP_HOLIDAY HO ON T.Emp_ID=HO.Emp_ID AND T.FOR_DATE=HO.FOR_DATE
			
			UPDATE	T1
			SET		TO_DATE=T.FOR_DATE										
			FROM	(
					SELECT ROW_NUMBER() OVER(PARTITION BY RT.EMP_ID,RT.WORKING_DAY ORDER BY RT.EMP_ID,RT.FOR_DATE) AS ROW_ID, RT.* , PL.FROM_DATE
					FROM	#ROW_TABLE RT	
							INNER JOIN #Paternity_Leave PL ON RT.EMP_ID=PL.EMP_ID AND RT.FOR_DATE>= PL.FROM_DATE
					) T INNER JOIN #Paternity_Leave T1 ON T.Emp_ID=T1.Emp_ID
			WHERE	ROW_ID = (@Validity_Days+1) AND WORKING_DAY = 1
		END
	
	
	select * from #Paternity_Leave
END


