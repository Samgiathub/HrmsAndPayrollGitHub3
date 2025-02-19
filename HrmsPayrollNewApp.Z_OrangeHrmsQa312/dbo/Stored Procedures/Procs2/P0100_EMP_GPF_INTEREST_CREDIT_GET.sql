

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_GPF_INTEREST_CREDIT_GET]
	@Cmp_ID		NUMERIC,
	@AD_ID		NUMERIC,
	@MONTH		NUMERIC,
	@YEAR		NUMERIC,
	
	@BRANCH_ID  NUMERIC = 0,
	@GRD_ID     NUMERIC = 0,
	@EMP_ID		NUMERIC = 0,
	@REC_TYPE	TINYINT = 1,
	@P_Branch   varchar(max)= '',  --Added By Jaina 10-08-2016
	@P_Vertical varchar(max) = '', --Added By Jaina 10-08-2016
	@P_SubVertical varchar(max) = '', --Added By Jaina 10-08-2016
	@P_Department varchar(max) = ''  --Added By Jaina 10-08-2016
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @FROM_DATE		DATETIME;
	DECLARE @TO_DATE		DATETIME;	
	DECLARE @YEAR_ST_DATE	DATETIME;
	DECLARE @YEAR_END_DATE	DATETIME;
	DECLARE @GPF_INT_PERC	NUMERIC(18,4);
	
	IF @BRANCH_ID = 0
		SET @BRANCH_ID = NULL;
	IF @GRD_ID = 0
		SET @GRD_ID = NULL;
	IF @EMP_ID = 0 
		SET @EMP_ID = NULL;
	
	--Added By Jaina 09-08-2016 Start	
	IF 	@P_Branch = '' or @P_Branch = '0'
		set @P_Branch = NULL
	
	IF @P_Vertical = '' or @P_Vertical = '0'
		set @P_Vertical = NULL
		
	IF @P_SubVertical = '' or @P_SubVertical='0'
		set @P_SubVertical = NULL
	
	IF @P_Department = '' or @P_Department='0'
		set @P_Department = NULL
		
	if @P_Branch is null
	Begin	
		select   @P_Branch = COALESCE(@P_Branch + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @P_Branch = @P_Branch + '#0'
	End
	
	if @P_Vertical is null
	Begin	
		select   @P_Vertical = COALESCE(@P_Vertical + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @P_Vertical IS NULL
			set @P_Vertical = '0';
		else
			set @P_Vertical = @P_Vertical + '#0'		
	End
	if @P_SubVertical is null
	Begin	
		select   @P_SubVertical = COALESCE(@P_SubVertical + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @P_SubVertical IS NULL
			set @P_SubVertical = '0';
		else
			set @P_SubVertical = @P_SubVertical + '#0'
	End
	IF @P_Department is null
	Begin
		select   @P_Department = COALESCE(@P_Department + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		
		if @P_Department is null
			set @P_Department = '0';
		else
			set @P_Department = @P_Department + '#0'
	End
	--Added By Jaina 09-08-2016 End
	
	IF @MONTH > 3 
		BEGIN
			SET	@YEAR_ST_DATE	= CAST(CAST(@YEAR - 1 AS varchar) + '-04-01' AS DATETIME);
			SET	@YEAR_END_DATE  = CAST(CAST(@YEAR AS varchar) + '-03-31 23:59:59' AS DATETIME);						
			SET	@FROM_DATE	= CAST(CAST(@YEAR AS varchar) + '-' + CAST(@MONTH AS varchar) + '-01' AS DATETIME);
		END
	ELSE
		BEGIN
			SET	@YEAR_ST_DATE	= CAST(CAST(@YEAR AS varchar) + '-01-01' AS DATETIME);
			SET	@YEAR_END_DATE  = CAST(CAST(@YEAR AS varchar) + '-12-31 23:59:59' AS DATETIME);
			SET	@FROM_DATE	= CAST(CAST(@YEAR - 1 AS varchar) + '-' + CAST(@MONTH AS varchar) + '-01' AS DATETIME);
		END
	
	
	
	SET	@TO_DATE  = CONVERT(DATETIME, CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(M, 1, @FROM_DATE)) , 103) + ' 23:59:59', 103);
	
	
	SELECT	TOP 1 @GPF_INT_PERC = Interest_Rate
	FROM	T0060_GPF_INTEREST_RATE WITH (NOLOCK)
	WHERE	Cmp_ID=@CMP_ID AND AD_ID=@AD_ID AND Effective_Date <= @YEAR_END_DATE
	ORDER BY Effective_Date DESC
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
	)  
	--Comment By Jaina 11-08-2016 Start
	--INSERT INTO #Emp_Cons
	--SELECT	E.EMP_ID
	--FROM	T0080_EMP_MASTER E INNER JOIN T0095_INCREMENT I ON E.Emp_ID=I.Emp_ID AND E.Cmp_ID=I.Cmp_ID
	--WHERE	I.Increment_ID=(SELECT	TOP 1 Increment_ID
	--						FROM	T0095_INCREMENT I1
	--						WHERE	I1.Cmp_ID=E.Cmp_ID AND I1.Emp_ID=E.Emp_ID 
	--								AND I1.Increment_Effective_Date <= @YEAR_END_DATE
	--						ORDER BY Increment_Effective_Date DESC, Increment_ID DESC)
	--		AND E.CMP_ID=@CMP_ID 
	--		AND IsNull(E.Emp_ID,0)=COALESCE(@EMP_ID, E.Emp_ID, 0)
	--		AND IsNull(I.Branch_ID,0)=COALESCE(@BRANCH_ID, I.Branch_ID, 0)
	--		AND IsNull(I.Grd_ID,0)=COALESCE(@GRD_ID, I.Grd_ID, 0)
	--ORDER BY E.Emp_ID
	
	--Added By Jaina 10-08-2016 Start
	INSERT INTO #Emp_Cons
	SELECT V.Emp_ID 
	FROM V_Emp_Cons V INNER JOIN
		  ( select I1.Emp_ID,I1.Increment_ID,I1.Branch_ID,I1.Vertical_ID,I1.SubVertical_ID,I1.Dept_ID,I1.Grd_ID
				from T0095_INCREMENT I1 WITH (NOLOCK)
				INNER JOIN (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, Increment_Effective_Date, I2.Emp_ID
							FROM T0095_INCREMENT I2 WITH (NOLOCK)
							GROUP BY I2.Increment_Effective_Date, I2.Emp_ID
							) I2 ON I1.Increment_ID=I2.INCREMENT_ID
				INNER JOIN (SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date, I3.Emp_ID
							FROM	T0095_INCREMENT I3 WITH (NOLOCK)
							WHERE	I3.Increment_Effective_Date <= @YEAR_END_DATE
							GROUP BY I3.Emp_ID
							) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.Emp_ID=I3.Emp_ID
			)I_Q ON I_Q.Increment_ID =V.Increment_ID and I_Q.Emp_ID = V.Emp_ID
	WHERE  V.CMP_ID=@CMP_ID 
			AND IsNull(V.Emp_ID,0)=COALESCE(@EMP_ID, V.Emp_ID, 0)
			AND IsNull(I_Q.Branch_ID,0)=COALESCE(@BRANCH_ID, I_Q.Branch_ID, 0)
			AND IsNull(I_Q.Grd_ID,0)=COALESCE(@GRD_ID, I_Q.Grd_ID, 0)
			and EXISTS (select Data from dbo.Split(@P_Branch, '#') B Where cast(B.data as numeric)=Isnull(I_Q.Branch_ID,0))
			and EXISTS (select Data from dbo.Split(@P_Vertical, '#') VE Where cast(VE.data as numeric)=Isnull(I_Q.Vertical_ID,0))
			and EXISTS (select Data from dbo.Split(@P_SubVertical, '#') S Where cast(S.data as numeric)=Isnull(I_Q.SubVertical_ID,0))
			and EXISTS (select Data from dbo.Split(@P_Department, '#') D Where cast(D.data as numeric)=Isnull(I_Q.Dept_ID,0))    		          			
			
	ORDER BY V.Emp_ID
	--Added By Jaina 10-08-2016 End
	
	CREATE TABLE #GPF_INT
	(
		TRAN_ID		NUMERIC,
		EMP_ID		NUMERIC,
		CLOSING		NUMERIC(18,4),
		PERCENTAGE	NUMERIC(18,4),
		AMOUNT		NUMERIC(18,4)
	);
	
	IF (@REC_TYPE = 0 OR @REC_TYPE = 1)		--ALL OR PENDING
		INSERT	INTO #GPF_INT
		SELECT	0,GPF_BALANCE.EMP_ID, GPF_BALANCE.GPF_CLOSING,@GPF_INT_PERC,(GPF_CLOSING * (@GPF_INT_PERC / 100)) AS AMOUNT
		FROM	(
					SELECT	T1.GPF_CLOSING, T1.EMP_ID, T1.CMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T1 WITH (NOLOCK)
					WHERE	T1.TRAN_ID = (
								SELECT	TOP 1 T2.TRAN_ID
								FROM	T0140_EMP_GPF_TRANSACTION T2 WITH (NOLOCK)
								WHERE	T2.CMP_ID=T1.CMP_ID AND T2.EMP_ID=T1.EMP_ID AND T2.FOR_DATE <= @YEAR_END_DATE
								ORDER BY T2.FOR_DATE DESC
							) AND T1.CMP_ID=@CMP_ID --AND T1.FOR_DATE <= @YEAR_END_DATE
					
				) GPF_BALANCE INNER JOIN #Emp_Cons E ON GPF_BALANCE.EMP_ID=E.Emp_ID
				LEFT OUTER JOIN T0100_EMP_GPF_INTEREST_CREDIT CR WITH (NOLOCK) ON CR.Emp_ID=GPF_BALANCE.EMP_ID
								AND CR.Cmp_ID=GPF_BALANCE.CMP_ID AND MONTH(CR.Year_End_Date)=MONTH(@YEAR_END_DATE) 
								AND YEAR(CR.Year_End_Date)=YEAR(@YEAR_END_DATE)
		WHERE	E.Emp_ID IN (	SELECT	Emp_ID 
								FROM	T0100_EMP_EARN_DEDUCTION EARN WITH (NOLOCK)
								WHERE	EARN.AD_ID=@AD_ID AND E.Emp_ID=EARN.EMP_ID AND EARN.CMP_ID=@CMP_ID
							) AND CR.Emp_ID IS NULL and GPF_BALANCE.GPF_CLOSING > 0
			
	IF (@REC_TYPE = 0 OR @REC_TYPE = 2)		--ALL OR EXISTING
		INSERT	INTO #GPF_INT
		SELECT	CR.TRAN_ID,GPF_BALANCE.EMP_ID, GPF_BALANCE.GPF_CLOSING,@GPF_INT_PERC,CR.Amount
		FROM	(
					SELECT	T1.GPF_CLOSING, T1.EMP_ID,T1.CMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T1 WITH (NOLOCK)
					WHERE	T1.TRAN_ID = (
								SELECT	TOP 1 T2.TRAN_ID
								FROM	T0140_EMP_GPF_TRANSACTION T2 WITH (NOLOCK)
								WHERE	T2.CMP_ID=T1.CMP_ID AND T2.EMP_ID=T1.EMP_ID	AND T2.FOR_DATE <= @YEAR_END_DATE
								ORDER BY T2.FOR_DATE DESC
							) AND T1.CMP_ID=@CMP_ID 
					
				) GPF_BALANCE INNER JOIN #Emp_Cons E ON GPF_BALANCE.EMP_ID=E.Emp_ID
				INNER JOIN T0100_EMP_GPF_INTEREST_CREDIT CR WITH (NOLOCK) ON CR.Cmp_ID=GPF_BALANCE.CMP_ID
							AND CR.Emp_ID=GPF_BALANCE.EMP_ID 
		WHERE	CR.AD_ID=@AD_ID AND MONTH(CR.Year_End_Date)=MONTH(@YEAR_END_DATE) 
				AND YEAR(CR.Year_End_Date)=YEAR(@YEAR_END_DATE) AND CR.Cmp_ID=@CMP_ID
		
	
	SELECT	G.TRAN_ID,E.Emp_ID, AD.AD_ID, AD.AD_NAME , E.Alpha_Emp_Code, E.Emp_Full_Name,G.CLOSING,G.PERCENTAGE,G.AMOUNT
	FROM	#GPF_INT G INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON G.EMP_ID=E.Emp_ID
			INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON E.Cmp_ID=AD.CMP_ID
	WHERE	E.Cmp_ID=@CMP_ID AND AD.AD_ID=@AD_ID
	
	
