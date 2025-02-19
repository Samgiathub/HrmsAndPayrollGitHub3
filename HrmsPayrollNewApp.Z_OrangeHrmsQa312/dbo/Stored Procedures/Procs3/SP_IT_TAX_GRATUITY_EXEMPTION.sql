

-- =============================================
-- Author:		<Author,,Ankit>
-- Create date: <Create Date,,05052016>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_IT_TAX_GRATUITY_EXEMPTION]
	 @Emp_ID				NUMERIC
	,@Cmp_ID				NUMERIC
	,@From_Date				DATETIME
	,@To_Date				DATETIME 
	,@Increment_ID			NUMERIC
	,@Gratuity_Amount		NUMERIC(18,2) OUTPUT 
	,@Gratuity_Exemp_Amount	NUMERIC(18,2) OUTPUT
	,@SP_Flag				VARCHAR(20) = 'GRATUITY EXEMPTION' 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Annual_Salary_Amount	NUMERIC(18,0)
	DECLARE @Cont_Gratuity_Exemp	TINYINT
	DECLARE @Cont_Gratuity			TINYINT 
	DECLARE @Gratuity_Max_Limit		NUMERIC(18,2)
	DECLARE @Temp_From_Date			DATETIME
	DECLARE @Temp_To_Date			DATETIME
	DECLARE @NOFYear				NUMERIC
	DECLARE @Left_Date				DATETIME
	DECLARE @Last_Drawn_Salary		Numeric(18,2)
	DECLARE @DA_Allow_Amount		Numeric(18,2)	
	
	SET @Annual_Salary_Amount = 0	
	SET @Cont_Gratuity_Exemp = 166
	SET @Cont_Gratuity = 5
	SET @Gratuity_Amount = 0
	SET @Gratuity_Max_Limit  = 0
	Set @Last_Drawn_Salary = 0
	SEt @DA_Allow_Amount = 0
	
	SELECT @Temp_To_Date = MAX(month_end_Date) FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Is_FNF = 0 AND  Emp_ID = @Emp_ID AND Month_End_Date <= @To_Date
	SET @Temp_From_Date =  DATEADD(d,1,DATEADD(MONTH ,-10 ,@Temp_To_Date))

	Update T0080_EMP_MASTER Set GroupJoiningDate = NULL Where GroupJoiningDate = '1900-01-01'

	SELECT @NOFYear = 
		Case When --dbo.F_GET_AGE(Case When ISNULL(GroupJoiningDate,'1900-01-01') <> '1900-01-01' Then GroupJoiningDate Else Date_Of_Join End,Emp_Left_Date,'Y','N') ,@Left_Date = Emp_Left_Date  
			Substring(dbo.F_GET_AGE(isnull(ISNULL(GroupJoiningDate,Date_Of_Join),Emp_Left_Date),Emp_Left_Date,'Y','N'),charindex('.',dbo.F_GET_AGE(isnull(ISNULL(GroupJoiningDate,Date_Of_Join),Emp_Left_Date),Emp_Left_Date,'Y','N'))+1,2) = 5 
		Then floor(dbo.F_GET_AGE(isnull(ISNULL(GroupJoiningDate,Date_Of_Join),Emp_Left_Date),Emp_Left_Date,'Y','N'))
		else
			CEILING(dbo.F_GET_AGE(isnull(ISNULL(GroupJoiningDate,Date_Of_Join),Emp_Left_Date),Emp_Left_Date,'Y','N'))  --Upper Round --Ankit 27082015
		End
	FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Emp_Left = 'Y'				


	
	IF @SP_Flag = 'GRATUITY EXEMPTION'
		BEGIN
			
			SELECT @Gratuity_Amount = ISNULL(Gr_Amount,0) FROM T0100_GRATUITY WITH (NOLOCK)  WHERE Emp_ID =@Emp_ID AND Paid_Date BETWEEN @From_Date AND @To_date
			SELECT @Gratuity_Max_Limit = ISNULL(Max_Limit,0) FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Default_Def_Id = @Cont_Gratuity_Exemp AND FOR_DATE BETWEEN @From_Date AND @To_Date
			
			If @Gratuity_Max_Limit = 2000000 --- Added this Condition by Hardik 22/04/2019 for Employee covered under Gratuity Payment Act
				Begin
					Select @Last_Drawn_Salary = Basic_Salary from T0095_INCREMENT WITH (NOLOCK) Where Increment_ID = @Increment_ID
					
					Select @DA_Allow_Amount = Isnull(E_AD_AMOUNT,0) 
					from T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID = AM.AD_ID 
					Where Increment_ID = @Increment_ID And AM.AD_DEF_ID = 11
					
					Set @Annual_Salary_Amount = (@Last_Drawn_Salary + @DA_Allow_Amount) * @NOFYear * 15/26
				End
			Else     --- Added this Condition by Hardik 22/04/2019 for Employee not covered under Gratuity Payment Act
				Begin
					SELECT @Annual_Salary_Amount = AVG(Salary_Amount) FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Month_St_Date >= @Temp_From_Date  AND Month_End_Date <= @Temp_To_Date
					SELECT @DA_Allow_Amount = AVG(M_AD_Amount) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
					WHERE Emp_ID =@Emp_ID AND For_Date >=@Temp_From_Date AND For_Date <=@Temp_To_Date AND AM.AD_DEF_ID = 11
					
					SET @Annual_Salary_Amount = ISNULL(@Annual_Salary_Amount,0) + ISNULL(@DA_Allow_Amount,0) * @NOFYear * 0.5
				End
			IF @Gratuity_Max_Limit > 0
				BEGIN
					SET @Gratuity_Exemp_Amount = 
						CASE 
							WHEN	@Gratuity_Amount <= @Gratuity_Max_Limit AND 
									@Gratuity_Amount <= @Annual_Salary_Amount THEN @Gratuity_Amount
							WHEN	@Gratuity_Max_Limit <= @Annual_Salary_Amount THEN @Gratuity_Max_Limit
							ELSE    @Annual_Salary_Amount
						END
				END
			ELSE
				BEGIN
					SET @Gratuity_Exemp_Amount = @Gratuity_Amount
				END	
			
			UPDATE #Tax_Report 
			SET Amount_Col_Final = @Gratuity_Exemp_Amount 
			WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Gratuity_Exemp
	
		END
	ELSE IF @SP_Flag = 'LEAVE EXEMPTION'
		BEGIN
			/* LEAVE EXEMPTION CALCULATION REFERENCE LINK - http://www.relakhs.com/leave-encashment-taxation-calculation/ */
			
			DECLARE @Leave_Amount			NUMERIC(18,2)
			DECLARE @LeaveEncash_Max_Limit	NUMERIC(18,2)
			DECLARE @Cont_Leave_Exemp		NUMERIC
			DECLARE @Leave_Exemp_Amount		NUMERIC(18,2) 

			DECLARE @Cash_Equivalent_Amount	Numeric(18,2)

			DECLARE @Leave_Credit			NUMERIC(18,2)
			DECLARE @Leave_Availed			NUMERIC(18,2)

			DECLARE @Leave_Encash_Days		NUMERIC(18,2)
			
			
			SET @NOFYear = 0
			SET @Leave_Credit = 0
			SET @Leave_Availed = 0
			SET @Leave_Amount = 0
			SET @LeaveEncash_Max_Limit = 0
			SET @Cont_Leave_Exemp = 6
			SET @Leave_Exemp_Amount = 0
			SET @DA_Allow_Amount = 0
			SET @Cash_Equivalent_Amount = 0
			SET @Leave_Encash_Days = 0

			SELECT @NOFYear = dbo.F_GET_AGE(Case When ISNULL(GroupJoiningDate,'1900-01-01') <> '1900-01-01' Then GroupJoiningDate Else Date_Of_Join End,Emp_Left_Date,'Y','N')
			FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Emp_Left = 'Y'	
				
			--1 Leave Encashment Amount
			SELECT	@Leave_Amount = SUM(Leave_Salary_Amount) 
			FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	Emp_ID =@Emp_ID AND Month_End_Date >=@FROM_DATE AND Month_End_Date <=@TO_DATE 

			--2 Leave Encashment Max Amount
			SELECT @LeaveEncash_Max_Limit = ISNULL(Max_Limit,0) FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Default_Def_Id = @Cont_Leave_Exemp AND FOR_DATE BETWEEN @From_Date AND @To_Date
			IF @LeaveEncash_Max_Limit = 0
				SET @LeaveEncash_Max_Limit = 9999999999
				
			--3 Basic + DA Allowance
			SELECT @Annual_Salary_Amount = AVG(Salary_Amount) FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Month_St_Date >= @Temp_From_Date  AND Month_End_Date <= @Temp_To_Date
			SELECT @DA_Allow_Amount = AVG(M_AD_Amount) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
			WHERE Emp_ID =@Emp_ID AND For_Date >=@Temp_From_Date AND For_Date <=@Temp_To_Date AND AM.AD_DEF_ID = 11
			
			SET @Annual_Salary_Amount = ISNULL(@Annual_Salary_Amount,0) + ISNULL(@DA_Allow_Amount,0)
			
			--4 Cash Equivalent Of Leaves
			
				/*  ***** Calculation Formula *****
					
					Cash equivalent = { ( ( ( Y * C) – A ) / 30) * S }
				 
					‘Y’ is No of completed Years of service (you need to exclude part of an year, if any).
					‘C’ is total no of leaves Credited per year. If company provides 40 leaves per year, for calculation purpose we need to take 30 leaves only.
					‘A’ is total no of leaves Availed during the service (total no of leaves minus no of leaves that were encashed).
					‘S’ is average salary for last 10 months.
					
				*/
			
			
			SELECT @NOFYear = dbo.F_GET_AGE(Date_Of_Join,Emp_Left_Date,'N','N') ,@Left_Date = Emp_Left_Date  FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID =@Emp_ID AND Emp_Left = 'Y'
			
			SELECT @Leave_Credit = SUM(Leave_Credit) , @Leave_Availed = (SUM(Leave_Used) - SUM(Leave_Encash_Days))
			FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
			WHERE Emp_ID =@Emp_ID AND LM.Leave_Type = 'Encashable' AND LT.For_Date < @Left_Date
			
			
			IF @Leave_Credit > 30
				SET @Leave_Credit = 30
			
			SET @Cash_Equivalent_Amount = ( ( ( ISNULL(@NOFYear,0) * ISNULL(@Leave_Credit,0)) - ISNULL(@Leave_Availed,0) ) / 30) * ISNULL(@Annual_Salary_Amount ,0)
			
			--SELECT @LeaveEncash_Max_Limit AS LeaveEncash_Max_Limit,@Leave_Amount as Leave_Amount,@Annual_Salary_Amount as Annual_Salary_Amount,@Cash_Equivalent_Amount as Cash_Equivalent_Amount
			
			SELECT @Leave_Exemp_Amount = MIN(Leave_Min_Amount) 
			FROM 
			( 
			 SELECT ISNULL(@LeaveEncash_Max_Limit,0) AS Leave_Min_Amount UNION
			 SELECT ISNULL(@Leave_Amount,0)  AS Leave_Min_Amount UNION
			 SELECT ISNULL(@Annual_Salary_Amount,0)  AS Leave_Min_Amount UNION
			 SELECT ISNULL(@Cash_Equivalent_Amount,0) AS Leave_Min_Amount 
			) QryLeave
			
			UPDATE	#Tax_Report 
			SET		Amount_Col_Final = @Leave_Exemp_Amount 
			WHERE	Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Leave_Exemp and Is_Exempted = 1
			
			SET @Gratuity_Amount = @Leave_Amount
			SET @Gratuity_Exemp_Amount = @Leave_Exemp_Amount
			
			
		END
		
	
RETURN
