
CREATE PROCEDURE [dbo].[SP_RPT_IT_FORM_16_Backup_08082024] 
	@Cmp_ID NUMERIC
	,@From_Date DATETIME
	,@To_Date DATETIME
	,@Branch_ID NUMERIC
	,@Cat_ID NUMERIC
	,@Grd_ID NUMERIC
	,@Type_ID NUMERIC
	,@Dept_ID NUMERIC
	,@Desig_Id NUMERIC
	,@Emp_ID NUMERIC
	,@Constraint VARCHAR(Max)
	,@Product_ID NUMERIC
	,@Taxable_Amount_Cond NUMERIC = 0
	,@Format_Name VARCHAR(50) = 'Format1'
	,@Form_ID NUMERIC = 0
	,@Salary_Cycle_id NUMERIC = 0 -- Added By Ali 05042014
	,@Segment_ID NUMERIC = 0 -- Added By Ali 05042014	
	,@Vertical NUMERIC = 0 -- Added By Ali 05042014	
	,@SubVertical NUMERIC = 0 -- Added By Ali 05042014	
	,@subBranch NUMERIC = 0 -- Added By Ali 05042014
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Cont_Basic_Sal TINYINT
DECLARE @Cont_Gratuity_Sal TINYINT --Ankit 09122015
DECLARE @Cont_PT_Amount TINYINT
DECLARE @Cont_Total_Tax TINYINT
DECLARE @Cont_Surcharge TINYINT
DECLARE @Cont_Total_tax_Lia TINYINT
DECLARE @Cont_ED_Cess TINYINT
DECLARE @Cont_Net_Lia TINYINT
DECLARE @Cont_Tax TINYINT
DECLARE @Cont_Paid_Tax TINYINT
DECLARE @Cont_Due_Tax TINYINT
DECLARE @Cont_Annual_Sal TINYINT
DECLARE @Cont_HRA TINYINT
DECLARE @Cont_Arrear TINYINT
DECLARE @Cont_Less_TDS TINYINT
DECLARE @Cont_Perquisit_Amt TINYINT
DECLARE @Cont_Leave_salary TINYINT
DECLARE @Relief_sec_87_limit NUMERIC(18, 2)
DECLARE @Cont_Notice_Pay TINYINT
DECLARE @Cont_Production_Bonus TINYINT
DECLARE @Cont_Production_Variable TINYINT
DECLARE @Cont_Standard_Deduction TINYINT
DECLARE @Cont_Net_Round_Amount TINYINT
DECLARE @Cont_OT_Amount TINYINT --Added by nilesh patel on 19052018
DECLARE @Cont_Travel_Settlement_Amount TINYINT
DECLARE @Cmp_Name VARCHAR(50)
DECLARE @Cmp_Address VARCHAR(250)
DECLARE @Cmp_Pan_No VARCHAR(30)
DECLARE @cmp_TAN_No VARCHAR(30)
DECLARE @First_Ack_No VARCHAR(30) --Acknowledgement No	
DECLARE @Second_Ack_No VARCHAR(30) --Acknowledgement No	
DECLARE @Third_Ack_No VARCHAR(30) --Acknowledgement No	
DECLARE @Forth_Ack_No VARCHAR(30) --Acknowledgement No	
DECLARE @Other_Paid_TDS_Amont NUMERIC

SET @Cont_Basic_Sal = 1
SET @Cont_OT_Amount = 4 --Added by nilesh patel on 19052018
SET @Cont_Gratuity_Sal = 5
SET @Cont_PT_Amount = 10
SET @Cont_Total_Tax = 101
SET @Cont_Surcharge = 102
SET @Cont_Total_tax_Lia = 103
SET @Cont_ED_Cess = 104
SET @Cont_Net_Lia = 105
SET @Cont_Tax = 106
SET @Cont_Paid_Tax = 107
SET @Cont_Due_Tax = 108
SET @Cont_Annual_Sal = 109
SET @Cont_HRA = 110
SET @Cont_Arrear = 12
SET @Cont_Less_TDS = 120
SET @Cont_Perquisit_Amt = 201
SET @Cont_Leave_salary = 6
SET @Cont_Notice_Pay = 51
SET @Cont_Production_Bonus = 167
SET @Cont_Production_Variable = 168
SET @Cont_Standard_Deduction = 169
SET @Cont_Net_Round_Amount = 170
SET @Cont_Travel_Settlement_Amount = 171

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

IF @Salary_Cycle_id = 0
	SET @Salary_Cycle_id = NULL

IF @Segment_ID = 0
	SET @Segment_ID = NULL

IF @Vertical = 0
	SET @Vertical = NULL

IF @SubVertical = 0
	SET @SubVertical = NULL

IF @subBranch = 0
	SET @subBranch = NULL

--Ankit 17072014--
DECLARE @fin_year AS NVARCHAR(20)

SET @fin_year = ''
SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)

--Ankit 17072014--
CREATE TABLE #Emp_Cons (
	Emp_ID NUMERIC
	,Branch_ID NUMERIC
	,Increment_ID NUMERIC
	)

IF @Constraint <> ''
BEGIN
	INSERT INTO #Emp_Cons
	SELECT T.Emp_ID
		,I.Branch_ID
		,I.Increment_ID
	FROM (
		SELECT CAST(DATA AS NUMERIC) AS EMP_ID
		FROM dbo.Split(@Constraint, '#') T
		) T
	INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON T.Emp_ID = I.Emp_ID
	INNER JOIN (
		SELECT I1.EMP_ID
			,MAX(I1.Increment_ID) AS Increment_ID
		FROM T0095_INCREMENT I1 WITH (NOLOCK)
		INNER JOIN (
			SELECT I2.EMP_ID
				,MAX(I2.Increment_Effective_Date) AS Increment_Effective_Date
			FROM T0095_INCREMENT I2 WITH (NOLOCK)
			WHERE I2.Increment_Effective_Date <= @To_Date
			GROUP BY I2.Emp_ID
			) I2 ON I1.Emp_ID = I2.Emp_ID
			AND I1.Increment_Effective_Date = I2.Increment_Effective_Date
		GROUP BY I1.Emp_ID
		) I1 ON I1.Emp_ID = I.Emp_ID
		AND I1.Increment_ID = I.Increment_ID
END
ELSE
BEGIN
	INSERT INTO #Emp_Cons
	SELECT I.Emp_ID
		,I.Branch_ID
		,I.Increment_ID
	FROM T0095_Increment I WITH (NOLOCK)
	CROSS APPLY (
		SELECT Increment_ID
		FROM dbo.fn_getEmpIncrement(@Cmp_ID, COALESCE(@EMP_ID, I.Emp_ID), @To_Date) T
		WHERE T.Emp_ID = I.Emp_ID
			AND T.Increment_ID = I.Increment_ID
		) IQ
	INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID
	WHERE I.Cmp_ID = @Cmp_ID
		AND COALESCE(I.Cat_ID, @Cat_ID, 0) = COALESCE(@Cat_ID, I.Cat_ID, 0)
		AND I.Branch_ID = isnull(@Branch_ID, I.Branch_ID)
		AND I.Grd_ID = isnull(@Grd_ID, I.Grd_ID)
		AND COALESCE(I.Dept_ID, @DEPT_ID, 0) = COALESCE(@DEPT_ID, I.Dept_ID, 0)
		AND COALESCE(I.Type_ID, @Type_ID, 0) = COALESCE(@Type_ID, I.Type_ID, 0)
		AND COALESCE(I.Desig_ID, @Desig_ID, 0) = COALESCE(@Desig_ID, I.Desig_ID, 0)
		AND COALESCE(I.SalDate_id, @Salary_Cycle_id, 0) = COALESCE(@Salary_Cycle_id, I.SalDate_id, 0)
		AND COALESCE(I.Segment_ID, @Segment_ID, 0) = COALESCE(@Segment_ID, I.Segment_ID, 0)
		AND COALESCE(I.Vertical_ID, @Vertical, 0) = COALESCE(@Vertical, I.Vertical_ID, 0)
		AND COALESCE(I.SubVertical_ID, @SubVertical, 0) = COALESCE(@SubVertical, I.SubVertical_ID, 0)
		AND COALESCE(I.subBranch_ID, @subBranch, 0) = COALESCE(@subBranch, I.subBranch_ID, 0)
		AND I.Emp_ID = isnull(@Emp_ID, I.Emp_ID)
		AND Date_Of_Join <= @To_Date
		AND (
			(
				@From_Date >= Date_Of_Join
				AND @From_Date <= Emp_Left_Date
				)
			OR (
				@To_Date >= Date_Of_Join
				AND @To_Date <= Emp_Left_Date
				)
			OR (
				Emp_Left_Date IS NULL
				AND @To_Date >= Date_Of_Join
				)
			OR (
				@To_Date >= Emp_Left_Date
				AND @From_Date <= Emp_Left_Date
				)
			)
	ORDER BY I.Emp_ID
		--Delete From #Emp_Cons Where Increment_ID Not In
		--(select TI.Increment_ID from t0095_increment TI inner join
		--(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
		--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
		--on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Effective_Date
		--Where Increment_effective_Date <= @to_date) 
END

CREATE TABLE #Tax_Report (
	T_ID NUMERIC identity(1, 1)
	,Emp_ID NUMERIC
	,Cmp_ID NUMERIC(18, 0) NOT NULL
	,Format_Name VARCHAR(20)
	,Row_ID INT NOT NULL
	,Field_Name VARCHAR(100)
	,AD_ID NUMERIC(18, 0) NULL
	,Rimb_ID NUMERIC(18, 0) NULL
	,Default_Def_Id INT NOT NULL
	,Is_Total TINYINT NOT NULL
	,From_Row_ID INT NOT NULL
	,To_Row_ID INT NOT NULL
	,Multiple_Row_ID VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,Is_Exempted TINYINT NOT NULL
	,Max_Limit NUMERIC(18, 0) NOT NULL
	,Max_Limit_Compare_Row_ID INT NOT NULL
	,Max_Limit_Compare_Type VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,Is_Proof_Req TINYINT NOT NULL
	,IT_ID NUMERIC NULL
	,From_Date DATETIME
	,To_Date DATETIME
	,Amount_Col_1 NUMERIC DEFAULT 0
	,Amount_Col_2 NUMERIC DEFAULT 0
	,Amount_Col_3 NUMERIC DEFAULT 0
	,Amount_Col_4 NUMERIC DEFAULT 0
	,Amount_Col_Final NUMERIC DEFAULT 0
	,Sal_No_Of_Month INT DEFAULT 0
	,Field_Type TINYINT DEFAULT 0
	,IT_Month INT
	,IT_YEAR INT
	,Increment_ID NUMERIC
	,IT_L_ID NUMERIC
	,Is_Show TINYINT DEFAULT 0
	,Col_No INT
	,Concate_Space TINYINT DEFAULT 0
	,Is_Salary_comp TINYINT DEFAULT 0
	,Exem_Againt_row_Id INT DEFAULT 0
	,Exempted_Amount NUMERIC DEFAULT 0
	,Is_TaxPaid_Rec TINYINT DEFAULT 0
	,Y_Edu_Cess_Amount NUMERIC DEFAULT 0
	,Y_Surcharge_Amount NUMERIC DEFAULT 0
	,M_IT_Amount NUMERIC DEFAULT 0
	,M_Edu_Cess_Amount NUMERIC DEFAULT 0
	,M_Surcharge_Amount NUMERIC DEFAULT 0
	,Total_TAxable_Amount NUMERIC DEFAULT 0
	,Final_Tax NUMERIC DEFAULT 0
	,Total_Amount NUMERIC DEFAULT 0
	,Incentive_Tax NUMERIC(18, 0)
	,Incentive_Tax_Amount NUMERIC(18, 0)
	,Is_Incentive TINYINT
	,Tax_Regime VARCHAR(50) -- Added by Hardik 02/04/2020
	)

CREATE TABLE #Tax_Report_Male (
	Auto_Row_Id INT identity(1, 1)
	,Field_Name VARCHAR(200)
	,Default_Def_Id NUMERIC
	,T_F_Row_ID INT
	,T_T_Row_ID INT
	,IT_Month INT
	,IT_YEAR INT
	,IT_L_ID NUMERIC
	,Is_Show TINYINT DEFAULT 1
	,Is_TaxPaid_Rec TINYINT DEFAULT 0
	,Show_In_SalarySlip TINYINT DEFAULT 0
	,--Hardik 20/03/2014
	Display_Name_For_SalarySlip VARCHAR(250) DEFAULT ''
	,--Added by Hardik 19/03/2014
	Gender VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT '' --Ankit 02052016
	)

CREATE TABLE #Salary_AD (
	Cmp_ID NUMERIC
	,Emp_ID NUMERIC
	,AD_ID NUMERIC
	,M_AD_Amount NUMERIC
	,Month_Count INT
	,Old_M_AD_Amount NUMERIC
	,AD_NOT_EFFECT_ON_PT TINYINT DEFAULT 0
	,AD_NOT_EFFECT_ON_SAL TINYINT DEFAULT 0
	,Ad_Effect_On_TDS TINYINT DEFAULT 0
	,Month_Diff_Amount NUMERIC
	,For_Date DATETIME
	,Default_Def_ID TINYINT DEFAULT 0
	)

/*Perquisites-Nimesh*/
CREATE TABLE #Perq_Detail (
	Emp_ID INT
	,IT_ID INT
	,AD_ID INT
	,TotalAmount NUMERIC(18, 2)
	,TaxFreeAmount NUMERIC(18, 2)
	,FinalAmount NUMERIC(18, 2)
	,ShowDetails BIT
	)

INSERT INTO #Perq_Detail (
	Emp_ID
	,IT_ID
	,AD_ID
	,ShowDetails
	)
SELECT EC.Emp_ID
	,IT.IT_ID
	,Cast(T.Data AS INT)
	,0
FROM #Emp_Cons EC
CROSS JOIN T0070_IT_MASTER IT WITH (NOLOCK)
CROSS APPLY dbo.Split(AD_String, '#') T
INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON T.Data = AM.AD_ID
WHERE IT_Is_perquisite = 1
	AND IT.Cmp_ID = @Cmp_ID
	AND AD_String IS NOT NULL
	AND AM.Allowance_Type = 'R'
	AND IsNull(T.Data, '') <> ''

DECLARE @Max_Row_ID NUMERIC
DECLARE @Max_From_Row_ID NUMERIC
DECLARE @T_For_Date DATETIME
DECLARE @Increment_ID NUMERIC
DECLARE @Month_Count TINYINT
DECLARE @Month_Sal TINYINT
DECLARE @Month_Diff TINYINT
DECLARE @Month_Max_Date DATETIME
DECLARE @Join_date DATETIME
DECLARE @ED_Cess_Per NUMERIC(5, 2)
DECLARE @SurCharge_per NUMERIC(5, 2)
DECLARE @Relief_87A_Amount NUMERIC(18, 2)

SET @Month_Count = datediff(m, @From_Date, @To_Date) + 1
SET @ED_Cess_Per = 0
SET @SurCharge_per = 0 --10 % Surchage not applicable from 2009-10 (A.Y. 2010-11) and w.e.f. 01.04.2009 comment by Hasmukh 10042012
SET @Relief_87A_Amount = 0

SELECT @ED_Cess_Per = Field_Value
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id = @Cont_ED_Cess
	AND Financial_Year = @fin_year
	AND Cmp_ID = @Cmp_ID

IF @ED_Cess_Per = 0
BEGIN
	IF YEAR(@From_Date) < 2018
		SET @ED_Cess_Per = 3
END

INSERT INTO #Tax_Report (
	Emp_ID
	,Cmp_ID
	,Format_Name
	,Row_ID
	,Field_Name
	,AD_ID
	,Rimb_ID
	,Default_Def_Id
	,Is_Total
	,From_Row_ID
	,To_Row_ID
	,Multiple_Row_ID
	,Is_Exempted
	,Max_Limit
	,Max_Limit_Compare_Row_ID
	,Max_Limit_Compare_Type
	,Is_Proof_Req
	,IT_ID
	,From_Date
	,To_Date
	,Field_Type
	,Is_Show
	,Col_No
	,Concate_Space
	,Is_Salary_comp
	,Exem_Againt_row_Id
	,Exempted_Amount
	)
SELECT Emp_ID
	,Cmp_ID
	,Format_Name
	,Row_ID
	,Field_Name
	,AD_ID
	,Rimb_ID
	,Default_Def_Id
	,Is_Total
	,From_Row_ID
	,To_Row_ID
	,Multiple_Row_ID
	,Is_Exempted
	,Max_Limit
	,Max_Limit_Compare_Row_ID
	,Max_Limit_Compare_Type
	,Is_Proof_Req
	,IT_ID
	,@From_Date
	,@To_Date
	,Field_Type
	,Is_Show
	,Col_No
	,isnull(Concate_Space, 0)
	,isnull(Is_Salary_comp, 0)
	,isnull(Exem_Againt_row_Id, 0)
	,0
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
CROSS JOIN #Emp_Cons ec
WHERE --isnull(Form_ID,0) = @Form_ID	 and Cmp_ID=@Cmp_ID					
	Cmp_Id = @Cmp_ID
	AND Default_Def_Id NOT IN (
		101
		,- 102
		,- 103
		,103
		,104
		,105
		,106
		,107
		,108
		,120
		,121
		,102
		)
	AND Financial_Year = @fin_year --Ankit 17072014

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_show
	)
SELECT ' '
	,0
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_show
	)
SELECT 'Tax Limit '
	,0
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT ' '
	,0
	,0

/*	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(10)),0   from T0040_tAx_limit t inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit 
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='M' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='M'


	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0 
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Tax Liabilities ',0
*/
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	,Gender
	)
SELECT ' '
	,0
	,0
	,'M'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,IT_L_ID
	,IS_Show
	,Gender
	)
SELECT cast(From_Limit AS VARCHAR(15)) + ' To ' + CASE 
		WHEN t.To_Limit LIKE '9999%'
			THEN 'Above'
		ELSE CAST(TO_Limit AS VARCHAR(15))
		END + ' ( ' + cast(Percentage AS VARCHAR(10)) + ' %) '
	,0
	,IT_L_ID
	,0
	,'M'
FROM T0040_tAx_limit t WITH (NOLOCK)
INNER JOIN (
	SELECT cmp_ID
		,max(for_Date) For_Date
	FROM T0040_tAx_limit WITH (NOLOCK)
	WHERE cmp_ID = @Cmp_ID
		AND For_Date <= @To_Date
		AND gender = 'M'
	GROUP BY cmp_ID
		,Regime
	) q ON t.cmp_ID = q.cmp_ID
	AND T.for_Date = q.for_Date
	AND gender = 'M'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	,Gender
	)
SELECT ' '
	,0
	,0
	,'F'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,IT_L_ID
	,Is_show
	,Gender
	)
SELECT cast(From_Limit AS VARCHAR(15)) + ' To ' + CASE 
		WHEN t.To_Limit LIKE '9999%'
			THEN 'Above'
		ELSE CAST(TO_Limit AS VARCHAR(15))
		END + ' ( ' + cast(Percentage AS VARCHAR(10)) + ' %) '
	,0
	,IT_L_ID
	,0
	,'F'
FROM T0040_tAx_limit t WITH (NOLOCK)
INNER JOIN (
	SELECT cmp_ID
		,max(for_Date) For_Date
	FROM T0040_tAx_limit WITH (NOLOCK)
	WHERE cmp_ID = @Cmp_ID
		AND For_Date <= @To_Date
		AND gender = 'F'
	GROUP BY cmp_ID
		,Regime
	) q ON t.cmp_ID = q.cmp_ID
	AND T.for_Date = q.for_Date
	AND gender = 'F'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	,Gender
	)
SELECT ' '
	,0
	,0
	,'V'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,IT_L_ID
	,Is_show
	,Gender
	)
SELECT cast(From_Limit AS VARCHAR(15)) + ' To ' + CASE 
		WHEN t.To_Limit LIKE '9999%'
			THEN 'Above'
		ELSE CAST(TO_Limit AS VARCHAR(15))
		END + ' ( ' + cast(Percentage AS VARCHAR(10)) + ' %) '
	,0
	,IT_L_ID
	,0
	,'V'
FROM T0040_tAx_limit t WITH (NOLOCK)
INNER JOIN (
	SELECT cmp_ID
		,max(for_Date) For_Date
	FROM T0040_tAx_limit WITH (NOLOCK)
	WHERE cmp_ID = @Cmp_ID
		AND For_Date <= @To_Date
		AND gender = 'V'
	GROUP BY cmp_ID
		,Regime
	) q ON t.cmp_ID = q.cmp_ID
	AND T.for_Date = q.for_Date
	AND gender = 'V'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	,Gender
	)
SELECT ' '
	,0
	,0
	,'S'

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,IT_L_ID
	,Is_show
	,Gender
	)
SELECT cast(From_Limit AS VARCHAR(15)) + ' To ' + CASE 
		WHEN t.To_Limit LIKE '9999%'
			THEN 'Above'
		ELSE CAST(TO_Limit AS VARCHAR(15))
		END + ' ( ' + cast(Percentage AS VARCHAR(10)) + ' %) '
	,0
	,IT_L_ID
	,0
	,'S'
FROM T0040_tAx_limit t WITH (NOLOCK)
INNER JOIN (
	SELECT cmp_ID
		,max(for_Date) For_Date
	FROM T0040_tAx_limit WITH (NOLOCK)
	WHERE cmp_ID = @Cmp_ID
		AND For_Date <= @To_Date
		AND gender = 'S'
	GROUP BY cmp_ID
		,Regime
	) q ON t.cmp_ID = q.cmp_ID
	AND T.for_Date = q.for_Date
	AND gender = 'S'

--insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--select '12. Tax on Total Income',101
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (101)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

IF YEAR(@To_Date) >= 2014
BEGIN
	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '   * Less: Sec. 87A ',-102
	INSERT INTO #Tax_Report_Male (
		Field_Name
		,Default_def_ID
		,Show_In_SalarySlip
		,Display_Name_For_SalarySlip
		)
	SELECT Space(Concate_Space) + Field_Name
		,Default_Def_Id
		,Show_In_SalarySlip
		,Space(Concate_Space) + Display_Name_For_SalarySlip
	FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
	WHERE Default_Def_Id IN (- 102)
		AND Cmp_Id = @Cmp_ID
		AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

	--Commented by Hardik 20/03/2014
	--			INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--			SELECT '#   Tax on Total Income ',-103
	INSERT INTO #Tax_Report_Male (
		Field_Name
		,Default_def_ID
		,Show_In_SalarySlip
		,Display_Name_For_SalarySlip
		)
	SELECT Space(Concate_Space) + Field_Name
		,Default_Def_Id
		,Show_In_SalarySlip
		,Space(Concate_Space) + Display_Name_For_SalarySlip
	FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
	WHERE Default_Def_Id IN (- 103)
		AND Cmp_Id = @Cmp_ID
		AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014
END

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (102)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

--insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--select 'Surcharge @10% on Tax ',102
--insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--select 'Total Tax Liabilities',103
----insert into #Tax_Report_Male (Field_Name,Default_def_ID)
----select '13. Ed. Cess 3%(On Tax Computed At Sr.No.12)',104
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (104)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

--insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--select '14. Tax Payable(12 + 13)',105
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (105)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

--insert into #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
--select '15. Less:Relief Under section 89 (attach details)',0,@Max_From_Row_ID,@Max_Row_ID-1
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (121)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

--insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--select '16. Tax Payable(14 - 15)',108
--insert into #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
--select '17. Less: TDS Paid',107,@Max_From_Row_ID,@Max_Row_ID-1  ---DO not change text 17. Less: TDS Paid if change than must change in form 16 report
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (120)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (103)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

--insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
--select ' ',0,0
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,is_show
	)
SELECT 'Income Tax '
	,106
	,0

SELECT @Max_Row_ID = isnull(max(AUTO_Row_ID), 0) + 1
FROM #Tax_Report_Male

SET @Max_From_Row_ID = @Max_Row_ID
SET @T_For_Date = @From_Date

WHILE @T_For_Date <= @To_Date
BEGIN
	INSERT INTO #Tax_Report_Male (
		Field_Name
		,Default_def_ID
		,IT_Month
		,IT_YEAR
		,Is_Show
		,Is_TaxPaid_Rec
		)
	SELECT datename(m, @T_For_Date)
		,0
		,month(@T_For_Date)
		,Year(@T_For_Date)
		,0
		,1

	SET @T_For_Date = dateadd(m, 1, @T_For_Date)
	SET @Max_Row_ID = @Max_Row_ID + 1
END

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (107)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

--Commented by Hardik 20/03/2014
--	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
--	SELECT '18. TAX PAYABLE/REFUNDABLE (16 - 17)',108
INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Show_In_SalarySlip
	,Display_Name_For_SalarySlip
	)
SELECT Space(Concate_Space) + Field_Name
	,Default_Def_Id
	,Show_In_SalarySlip
	,Space(Concate_Space) + Display_Name_For_SalarySlip
FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
WHERE Default_Def_Id IN (108)
	AND Cmp_Id = @Cmp_ID
	AND Financial_Year = @fin_year -- Financial_Year --Ankit 17072014

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT ' '
	,0
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT 'HOUSE RENT ALLOWANCE EXEMPT'
	,0
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT 'Annual Salary ( Exclusive benefits and Perquisites)'
	,109
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT 'House Rent Allowance Received'
	,110
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT 'Less : Exemption u/s 10 (13A) read with rule 2 A'
	,0
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT '  A ) House rent allowance Received'
	,110
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT '  B ) Actual Rent Paid'
	,112
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT '   Less : 1/10 of Salary'
	,113
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT '   Different Amount'
	,114
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT '  C ) Two Fifth of Salary'
	,115
	,0

INSERT INTO #Tax_Report_Male (
	Field_Name
	,Default_def_ID
	,Is_Show
	)
SELECT 'House rent Allow. Exempted ( least of a,b or c )'
	,7
	,0

SELECT @Max_Row_ID = isnull(max(Row_ID), 0) + 1
FROM #Tax_Report

INSERT INTO #Tax_Report (
	Emp_ID
	,Cmp_ID
	,Format_Name
	,Row_ID
	,Field_Name
	,AD_ID
	,Rimb_ID
	,Default_Def_Id
	,Is_Total
	,From_Row_ID
	,To_Row_ID
	,Multiple_Row_ID
	,Is_Exempted
	,Max_Limit
	,Max_Limit_Compare_Row_ID
	,Max_Limit_Compare_Type
	,Is_Proof_Req
	,IT_ID
	,From_Date
	,To_Date
	,IT_Month
	,IT_YEAR
	,IT_L_ID
	,Is_Show
	,Is_TaxPaid_Rec
	)
SELECT EC.Emp_ID
	,@Cmp_ID
	,@Format_Name
	,Auto_Row_Id + @Max_Row_ID
	,Field_Name
	,NULL
	,NULL
	,Default_Def_Id
	,0
	,isnull(T_F_Row_ID + @Max_Row_ID, 0)
	,isnull(T_T_Row_ID + @Max_Row_ID, 0)
	,''
	,0
	,0
	,0
	,0
	,0
	,NULL
	,@From_Date
	,@To_Date
	,IT_Month
	,IT_Year
	,IT_L_ID
	,Is_Show
	,Is_TaxPaid_Rec
FROM #Emp_Cons EC
INNER JOIN (
	SELECT CASE 
			WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth, GETDATE(), 'N', 'Y') AS NUMERIC(18, 2)) > 80
				THEN 'V'
			WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth, GETDATE(), 'N', 'Y') AS NUMERIC(18, 2)) > 60
				THEN 'S'
			ELSE Gender
			END AS gender
		,Emp_ID
	FROM T0080_EMP_MASTER WITH (NOLOCK)
	WHERE Cmp_ID = @Cmp_ID
	) EM ON EC.Emp_ID = Em.Emp_ID
CROSS JOIN #Tax_Report_Male TR
WHERE EM.Gender = (
		CASE 
			WHEN tr.Gender = '' COLLATE SQL_Latin1_General_CP1_CI_AS
				THEN em.Gender
			ELSE tr.Gender COLLATE SQL_Latin1_General_CP1_CI_AS
			END
		)
ORDER BY EC.Emp_ID

---Added by Hardik 02/04/2020 for New Tax Regime
IF YEAR(@FROM_DATE) > 2019
BEGIN
	UPDATE T
	SET Tax_Regime = TAX_REG.Regime
	FROM #Tax_Report T
	INNER JOIN T0095_IT_Emp_Tax_Regime TAX_REG ON T.Emp_ID = TAX_REG.Emp_ID
	WHERE TAX_REG.Financial_Year = @fin_year

	-- Added below update query by Hardik 19/10/2020 for WCL as if employee has not selected any Regime then default use Tax Regime 1 and calculate Tax as per Old regime
	UPDATE T
	SET Tax_Regime = 'Tax Regime 1'
	FROM #Tax_Report T
	WHERE Tax_Regime IS NULL

	DELETE T
	FROM #Tax_Report T
	WHERE NOT EXISTS (
			SELECT 1
			FROM T0040_TAX_LIMIT TL WITH (NOLOCK)
			WHERE T.IT_L_ID = TL.IT_L_ID
				AND T.Tax_Regime = TL.Regime
			)
		AND T.IT_L_ID IS NOT NULL
END

UPDATE T
SET Col_No = IT.Col_No
FROM #Tax_Report T
INNER JOIN T0100_IT_FORM_DESIGN IT ON Ltrim(T.Field_Name) = IT.Field_Name
WHERE T.Col_No IS NULL
	AND IT.Financial_Year = @fin_year
	AND IT.Cmp_ID = @CMP_ID

--Update #Tax_Report 
--set Increment_ID = Q.Increment_ID 
--from #Tax_Report t inner join 
--(select I.Emp_Id ,I.Increment_ID from T0095_Increment I inner join 
--				( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment	-- Ankit 10092014 for Same Date Increment
--				where Increment_Effective_date <= @To_Date and increment_type <> 'Transfer'
--				and Cmp_ID = @Cmp_ID
--				group by emp_ID  ) Qry on
--				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
--		Where Cmp_ID = @Cmp_ID )Q on t.emp_ID =q.Emp_ID 
--Commnented By jimit 01062018 and added By Jimit as there is case at WCL (not getting latest Increment)
UPDATE #Tax_Report
SET Increment_ID = Q.Increment_ID
FROM #Tax_Report T
INNER JOIN (
	SELECT I1.Emp_Id
		,I1.Increment_ID
	FROM T0095_INCREMENT I1 WITH (NOLOCK)
	INNER JOIN (
		SELECT MAX(I2.Increment_ID) AS Increment_ID
			,I2.Emp_ID
		FROM T0095_Increment I2 WITH (NOLOCK)
		INNER JOIN #Emp_Cons E ON I2.Emp_ID = E.Emp_ID
		INNER JOIN (
			SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
				,I3.EMP_ID
			FROM T0095_INCREMENT I3 WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID = E3.Emp_ID
			WHERE I3.Increment_effective_Date <= @To_date
				AND I3.Cmp_ID = @Cmp_ID
				AND I3.increment_type <> 'Transfer'
			GROUP BY I3.EMP_ID
			) I3 ON I2.Increment_Effective_Date = I3.Increment_Effective_Date
			AND I2.EMP_ID = I3.Emp_ID
		WHERE INCREMENT_TYPE <> 'TRANSFER'
			AND INCREMENT_TYPE <> 'DEPUTATION'
		GROUP BY I2.Emp_ID
		) I ON I1.Emp_ID = I.Emp_ID
		AND I1.Increment_ID = I.Increment_ID
	WHERE Cmp_ID = @Cmp_ID
	) Q ON T.emp_ID = Q.Emp_ID

-------------------- Allowance Exemption ---------------
--	DECLARE CUR_AD_Tax CURSOR FOR 
--		SELECT Distinct EMP_ID ,Increment_ID FROM #Tax_Report 	
--	OPEN CUR_AD_Tax 
--	FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID
--	WHILE @@FETCH_STATUS =0
--		BEGIN
--			set @Month_Sal =0
--			select @Month_Sal = isnull(count(emp_ID),0) From T0200_Monthly_Salary where Emp_ID=@emp_ID and Month_St_Date >=@From_Date and Month_st_Date <=@To_Date
--			if @Month_Count -( @Month_Sal + 1 ) > 0
--				set @Month_Diff = @Month_Count -( @Month_Sal + 1 )
--			else 
--				set @Month_Diff =0
--			set @Month_Diff = 0
--			Exec dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID,@Cmp_ID,@Increment_ID,@From_Date,@To_Date,@Month_Diff,''
--			Exec SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Count,0
--			FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID		
--		END
--	CLOSE CUR_AD_Tax
--	DEALLOCATE CUR_AD_Tax
--	------------------- End Allowance  -------------------------
------------------ Allowance Exemption ---------------
DECLARE @TAX_REGIME VARCHAR(50)

DECLARE CUR_AD_Tax CURSOR
FOR
SELECT DISTINCT t.EMP_ID
	,t.Increment_ID
	,TAX_REGIME --,Month_Count 
FROM #Tax_Report t
INNER JOIN T0080_emp_master e WITH (NOLOCK) ON t.emp_ID = e.emp_ID

OPEN CUR_AD_Tax

FETCH NEXT
FROM CUR_AD_Tax
INTO @EMP_ID
	,@Increment_ID
	,@TAX_REGIME --,@Month_Count

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Month_Sal = 0

	SELECT @Month_Sal = isnull(count(emp_ID), 0)
	FROM T0200_Monthly_Salary WITH (NOLOCK)
	WHERE Emp_ID = @emp_ID
		AND Month_End_Date >= @From_Date
		AND Month_End_Date <= @To_Date

	SELECT @Month_Max_Date = max(Month_End_Date)
	FROM T0200_Monthly_Salary WITH (NOLOCK)
	WHERE Emp_ID = @emp_ID
		AND Month_End_Date >= @From_Date
		AND Month_End_Date <= @To_Date

	SELECT @join_date = date_of_join
	FROM T0080_EMP_MASTER WITH (NOLOCK)
	WHERE emp_id = @emp_id

	DECLARE @temp_date AS DATETIME
	DECLARE @mon_count_actual AS NUMERIC
	DECLARE @mon_sal_not_done AS NUMERIC

	SET @mon_sal_not_done = 0

	IF @from_date < @join_date
		AND isnull(@Month_Max_Date, @from_date) = @From_Date
		SET @Month_Max_Date = isnull(@Month_Max_Date, @join_date)
	ELSE IF isnull(@Month_Max_Date, @from_date) = @From_Date
		SET @Month_Max_Date = isnull(@Month_Max_Date, @From_Date)

	IF @from_date < @join_date
		SET @temp_date = @join_date
	ELSE
		SET @temp_date = @From_Date

	--if datepart(dd,@temp_date) > 1
	--set @mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) + 1
	--else
	-- set @mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date)
	IF @Month_Max_Date = @join_date
		OR @Month_Max_Date = @From_Date
	BEGIN
		SET @mon_count_actual = DATEDIFF(mm, @temp_date, @Month_Max_Date)
	END
	ELSE
	BEGIN
		SET @mon_count_actual = DATEDIFF(mm, @temp_date, @Month_Max_Date) + 1
	END

	SET @mon_sal_not_done = @mon_count_actual - @Month_Sal

	IF (@Month_Count - @Month_Sal) > 0
	BEGIN
		--if month(@Month_Max_Date) >= 1 and  month(@Month_Max_Date) <= 3  and year(@join_date) = year(@to_date) 
		--	begin						
		--		set @Month_Diff = 3 - month(@Month_Max_Date) + 1 
		--		set @Month_Diff = @Month_Diff - @Month_Sal 
		--	end
		--else if month(@Month_Max_Date) >= 4 and  month(@Month_Max_Date) <= 12  and year(@join_date) = year(@From_date) 
		--	begin						
		--		set @Month_Diff = (12 - month(@Month_Max_Date)) + 3
		--		set @Month_Diff = @Month_Diff - @Month_Sal 
		--	end	
		--else
		--	begin
		SET @Month_Diff = @Month_Count - @Month_Sal - @mon_sal_not_done
			--end
	END
	ELSE
	BEGIN
		SET @Month_Diff = 0
	END

	SET @Month_Diff = 0

	EXEC dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID
		,@Cmp_ID
		,@Increment_ID
		,@From_Date
		,@To_Date
		,@Month_Diff
		,''

	IF Isnull(@TAX_REGIME, 'Tax Regime 1') = 'Tax Regime 1'
		EXEC SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID
			,@Cmp_Id
			,@Increment_ID
			,@From_Date
			,@To_Date
			,@Month_Diff
			,0
	ELSE
	BEGIN
		----Start---Gratuity Exemption------Ankit 05052016
		DECLARE @Cont_Gratuity_Exemp NUMERIC
		DECLARE @Gratuity_Exemp_Amount NUMERIC(18, 2)
		DECLARE @Gratuity_Amount NUMERIC(18, 2)

		SET @Cont_Gratuity_Exemp = 166
		SET @Gratuity_Amount = 0
		SET @Gratuity_Exemp_Amount = 0

		IF EXISTS (
				SELECT 1
				FROM dbo.#Tax_Report
				WHERE emp_ID = @emp_ID
					AND default_Def_ID = @Cont_Gratuity_Exemp
				)
		BEGIN
			EXEC dbo.SP_IT_TAX_GRATUITY_EXEMPTION @Emp_ID
				,@Cmp_ID
				,@From_Date
				,@To_Date
				,@Increment_ID
				,@Gratuity_Amount OUTPUT
				,@Gratuity_Exemp_Amount OUTPUT
		END

		UPDATE dbo.#Tax_Report
		SET Amount_Col_Final = @Gratuity_Exemp_Amount
		WHERE Emp_ID = @Emp_ID
			AND Default_Def_ID = @Cont_Gratuity_Exemp
	END

	FETCH NEXT
	FROM CUR_AD_Tax
	INTO @EMP_ID
		,@Increment_ID
		,@TAX_REGIME --,@Month_Count	
END

CLOSE CUR_AD_Tax

DEALLOCATE CUR_AD_Tax

-------------------End Allowance	   ---------------
---Nilay23062014- add condition amount_col_final > max limit---------
UPDATE #Tax_Report
SET Amount_Col_Final = Max_Limit
WHERE Is_Exempted = 0
	AND max_Limit_Compare_Row_ID = 0
	AND Max_Limit > 0
	AND Amount_Col_Final > 0
	AND Amount_Col_Final > Max_Limit

---Nilay23062014- add condition amount_col_final > max limit---------	
UPDATE #Tax_Report
SET Sal_No_Of_Month = E_COUNT
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,COUNT(MS.EMP_ID) E_COUNT
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID

UPDATE #Tax_Report
SET Amount_Col_Final = isnull(M_AD_Amount, 0) + isnull(Old_M_AD_Amount, 0) + isnull(Month_Diff_Amount, 0)
FROM #Tax_Report Tr
INNER JOIN #Salary_AD sa ON tr.Emp_ID = sa.Emp_ID
	AND sa.Default_Def_ID = @Cont_Basic_Sal
WHERE tr.DEFAULT_DEF_ID = @Cont_Basic_Sal

--Added by nilesh patel on 19052018 -- For Overtime is not calculate in grindmaster -- Emp coe 0327
UPDATE #Tax_Report
SET Amount_Col_Final = OT_Amount
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,Sum(IsNull(MS.OT_Amount, 0)) + Sum(IsNull(MS.M_HO_OT_Amount, 0)) + Sum(IsNull(MS.M_WO_OT_Amount, 0)) AS OT_Amount
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE tr.DEFAULT_DEF_ID = @Cont_OT_Amount

--Added by nilesh patel on 19052018 -- For Overtime is not calculate in grindmaster -- Emp coe 0327
UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + Isnull(S_Salary_Amount, 0)
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,SUM(MS.S_Salary_Amount) S_Salary_Amount
	FROM T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.S_Eff_Date >= @FROM_DATE
		AND MS.S_Eff_Date <= @TO_DATE
		--AND Ms.S_Eff_Date <= @Month_En_Date
		AND EXISTS (
			SELECT 1
			FROM T0200_MONTHLY_SALARY MS1 WITH (NOLOCK)
			WHERE MONTH(S_Eff_Date) = MONTH(MS1.MONTH_END_DATE)
				AND YEAR(S_Eff_Date) = YEAR(MS1.MONTH_END_DATE)
				AND MS.Emp_ID = MS1.EMP_ID
				AND MS1.MONTH_END_DATE >= @FROM_DATE
				AND MS1.MONTH_END_DATE <= @TO_DATE
			)
	--AND MS1.MONTH_END_DATE <= @Month_En_Date
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Basic_Sal

UPDATE #Tax_Report --Ankit For Gratuity	
SET Amount_Col_Final = Gratuity_Amount
FROM #Tax_Report Tr
INNER JOIN (
	SELECT G.EMP_ID
		,SUM(G.Gr_Amount) Gratuity_Amount
	FROM T0100_GRATUITY G WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON G.EMP_ID = EC.EMP_ID
	WHERE G.Gr_FNF = 1
		AND paid_date BETWEEN @FROM_DATE
			AND @To_date --added By Jimit 11052018 as Gratuity Amount shown in Each financial year at WCL
	GROUP BY G.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Gratuity_Sal

--UPdate #Tax_Report 
--set Amount_Col_Final = Leave_Salary_Amount
--From #Tax_Report Tr inner join (  SELECT MS.EMP_ID ,SUM(MS.Leave_Salary_Amount)Leave_Salary_Amount FROM 
--										T0200_MONTHLY_SALARY MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
--										WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
--										--and Ms.Month_st_Date <=@Month_En_Date
--									GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
--WHERE DEFAULT_DEF_ID =@Cont_Leave_salary
--Added by Nimesh on 16-May-2017 (For Leave Encashment)
CREATE TABLE #EMP_LEAVE_ENCASH (
	EMP_ID NUMERIC
	,FOR_DATE DATETIME
	,AMOUNT NUMERIC(18, 2)
	)

INSERT INTO #EMP_LEAVE_ENCASH
SELECT DISTINCT MS.EMP_ID
	,Month_End_Date
	,Leave_Salary_Amount
FROM #Tax_Report Tr
INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Emp_ID = TR.Emp_ID
WHERE MS.Month_End_Date >= @FROM_DATE
	AND MS.Month_End_Date <= @TO_DATE --AND Ms.Month_End_Date <=@Month_En_Date
	AND MS.Leave_Salary_Amount > 0
	AND DEFAULT_DEF_ID = @Cont_Leave_salary
	AND Is_Exempted = 0

INSERT INTO #EMP_LEAVE_ENCASH
SELECT DISTINCT TR.EMP_ID
	,LE.Lv_Encash_Apr_Date
	,LE.Leave_Encash_Amount
FROM #Tax_Report Tr
INNER JOIN T0120_LEAVE_ENCASH_APPROVAL LE WITH (NOLOCK) ON LE.Emp_ID = TR.Emp_ID
WHERE LE.Lv_Encash_Apr_Date >= @FROM_DATE
	AND LE.Lv_Encash_Apr_Date <= @TO_DATE --AND LE.Lv_Encash_Apr_Date <=@Month_En_Date
	AND NOT EXISTS (
		SELECT 1
		FROM #EMP_LEAVE_ENCASH ELE
		WHERE LE.Emp_ID = ELE.EMP_ID
			AND MONTH(LE.Lv_Encash_Apr_Date) = MONTH(ELE.FOR_DATE)
			AND YEAR(LE.Lv_Encash_Apr_Date) = YEAR(ELE.FOR_DATE)
		)
	AND DEFAULT_DEF_ID = @Cont_Leave_salary
	AND Isnull(LE.Eff_In_Salary, 0) = 0 --- Eff_In_Salary condition added by Hardik 24/01/2018 for Ifedora as without Salary generate Leave Encash amount should not show
	AND Is_Exempted = 0
	AND LE.Lv_Encash_Apr_Status = 'A'

UPDATE TR
SET Amount_Col_Final = AMOUNT
FROM #Tax_Report TR
INNER JOIN (
	SELECT EMP_ID
		,SUM(AMOUNT) AS AMOUNT
	FROM #EMP_LEAVE_ENCASH ELE
	GROUP BY EMP_ID
	) ELE ON TR.EMP_ID = ELE.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Leave_salary
	AND Is_Exempted = 0

DROP TABLE #EMP_LEAVE_ENCASH

--Added by Hardik 12/02/2018 for Havmor as they are Exempted Leave Encash during F&F
UPDATE #Tax_Report
SET Amount_Col_Final = Leave_Salary_Amount
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,SUM(MS.Leave_Encash_Amount) Leave_Salary_Amount
	FROM T0120_LEAVE_ENCASH_APPROVAL MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Lv_Encash_Apr_Date >= @FROM_DATE
		AND MS.Lv_Encash_Apr_Date <= @TO_DATE
		AND Ms.Lv_Encash_Apr_Date <= @TO_DATE
		AND Isnull(MS.Is_Tax_Free, 0) = 1
		AND MS.Lv_Encash_Apr_Status = 'A'
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Leave_salary
	AND Is_Exempted = 1
	AND (
		TR.Tax_Regime = 'Tax Regime 1'
		OR TR.Tax_Regime IS NULL
		)

------Hasmukh for notice payment 24122013---------
UPDATE #Tax_Report
SET Amount_Col_Final = Notice_payment
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,isnull(MS.Short_Fall_Dedu_Amount, 0) AS Notice_payment
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	INNER JOIN T0100_LEFT_EMP LE WITH (NOLOCK) ON MS.Emp_ID = LE.Emp_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
		AND MS.Is_FNF = 1
		AND LE.Is_Terminate = 1
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Notice_Pay

--------------------End---------------------------
UPDATE #Tax_Report
SET Amount_Col_Final = OTHER_ALLOW_AMOUNT
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,Isnull(SUM(MS.OTHER_ALLOW_AMOUNT), 0) OTHER_ALLOW_AMOUNT
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
	--and Ms.Month_st_Date <=@Month_En_Date
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Arrear

DECLARE @PT_Arrear NUMERIC(18, 2)

SET @PT_Arrear = 0

SELECT @PT_Arrear = SUM(Isnull(MAD.M_AD_Amount, 0))
FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
WHERE EMP_ID = @Emp_Id
	AND AD.AD_DEF_ID = 22
	AND AD.AD_CALCULATE_ON = 'Import'
	AND MAD.For_Date >= @From_Date
	AND MAD.For_Date <= @To_Date

UPDATE #Tax_Report
SET Amount_Col_Final = isnull(M_AD_Amount, 0) + isnull(Old_M_AD_Amount, 0) + isnull(Month_Diff_Amount, 0) + ISNULL(@PT_Arrear, 0)
FROM #Tax_Report Tr
INNER JOIN #Salary_AD sa ON tr.Emp_ID = sa.Emp_ID
	AND sa.Default_Def_ID = @Cont_PT_Amount
WHERE tr.DEFAULT_DEF_ID = @Cont_PT_Amount
	AND (
		TR.Tax_Regime = 'Tax Regime 1'
		OR TR.Tax_Regime IS NULL
		) --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME

--- Added by Hardik 11/04/2018 For Standard Deduction
UPDATE TR
SET Amount_Col_Final = CASE 
		WHEN LE.Emp_ID IS NOT NULL
			AND (
				LE.Is_Death = 1
				OR LE.Is_Retire = 1
				)
			THEN ISNULL(IFD.Field_Value, 0)
		ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
		END
FROM #Tax_Report TR
INNER JOIN T0100_IT_FORM_DESIGN IFD ON TR.Default_Def_Id = IFD.Default_Def_Id
	AND TR.Cmp_ID = IFD.Cmp_ID
LEFT OUTER JOIN T0100_LEFT_EMP LE ON TR.Emp_ID = LE.Emp_ID
WHERE TR.Default_Def_Id = @Cont_Standard_Deduction
	AND IFD.Financial_Year = @fin_year
	AND TR.Cmp_ID = @Cmp_ID
	AND (
		TR.Tax_Regime = 'Tax Regime 1'
		OR TR.Tax_Regime IS NULL
		)
	AND To_Date <= '2023-03-31' --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME --- ADDED BY SAJID 18-03-2023

UPDATE TR
SET Amount_Col_Final = CASE 
		WHEN LE.Emp_ID IS NOT NULL
			AND (
				LE.Is_Death = 1
				OR LE.Is_Retire = 1
				)
			THEN ISNULL(IFD.Field_Value, 0)
		ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
		END
FROM #Tax_Report TR
INNER JOIN T0100_IT_FORM_DESIGN IFD ON TR.Default_Def_Id = IFD.Default_Def_Id
	AND TR.Cmp_ID = IFD.Cmp_ID
LEFT OUTER JOIN T0100_LEFT_EMP LE ON TR.Emp_ID = LE.Emp_ID
WHERE TR.Default_Def_Id = @Cont_Standard_Deduction
	AND IFD.Financial_Year = @fin_year
	AND TR.Cmp_ID = @Cmp_ID
	AND (
		TR.Tax_Regime = 'Tax Regime 1'
		OR TR.Tax_Regime IS NULL
		)
	AND To_Date >= '2023-04-01' --- ADDED BY SAJID 18-03-2023

--- Added by Sajid 18-03-2023 For Standard Deduction for Tax Regime 2
UPDATE TR
SET Amount_Col_Final = CASE 
		WHEN LE.Emp_ID IS NOT NULL
			AND (
				LE.Is_Death = 1
				OR LE.Is_Retire = 1
				)
			THEN ISNULL(IFD.Field_Value, 0)
		ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
		END
FROM #Tax_Report TR
INNER JOIN T0100_IT_FORM_DESIGN IFD ON TR.Default_Def_Id = IFD.Default_Def_Id
	AND TR.Cmp_ID = IFD.Cmp_ID
LEFT OUTER JOIN T0100_LEFT_EMP LE ON TR.Emp_ID = LE.Emp_ID
WHERE TR.Default_Def_Id = @Cont_Standard_Deduction
	AND IFD.Financial_Year = @fin_year
	AND TR.Cmp_ID = @Cmp_ID
	--AND ((TR.Tax_Regime = 'Tax Regime 2' OR TR.Tax_Regime IS NULL) AND To_Date >='2023-04-01'  )  -- Commeted by Sajid 29-07-2024 For Standard Deduction 
			AND ((TR.Tax_Regime = 'Tax Regime 2' OR TR.Tax_Regime IS NULL) AND To_Date >='2023-04-01' and To_Date<='2024-03-31'  ) -- Added by Sajid 29-07-2024 For Standard Deduction 

--- Added by Sajid 18-03-2023 For Standard Deduction for Tax Regime 2


	--- Added by Sajid 29-07-2024 For Standard Deduction for Tax Regime 2 75000 Limit
	UPDATE	TR 
	SET		Amount_Col_Final =  CASE WHEN LE.Emp_ID IS NOT NULL AND (LE.Is_Death = 1 OR LE.Is_Retire = 1) THEN ISNULL(75000,0) ELSE (ISNULL(75000,0)/12)* dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID,@From_Date,@To_Date) END
	FROM	#Tax_Report TR 
			INNER JOIN T0100_IT_FORM_DESIGN IFD  ON TR.Default_Def_Id=IFD.Default_Def_Id And TR.Cmp_ID = IFD.Cmp_ID
			LEFT OUTER JOIN T0100_LEFT_EMP LE ON TR.Emp_ID = LE.Emp_ID
	WHERE	TR.Default_Def_Id = @Cont_Standard_Deduction And IFD.Financial_Year = @fin_year And TR.Cmp_ID = @Cmp_ID
			AND ((TR.Tax_Regime = 'Tax Regime 2' OR TR.Tax_Regime IS NULL) AND To_Date >='2024-04-01'  ) 
	--- Added by Sajid 29-07-2024 For Standard Deduction for Tax Regime 2 75000 Limit

--- Added by Hardik 11/04/2018 For Net Round Amount for Taxable For RKM
UPDATE #Tax_Report
SET Amount_Col_Final = Net_Salary_Round_Diff_Amount
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,ISNULL(SUM(MS.Net_Salary_Round_Diff_Amount), 0) AS Net_Salary_Round_Diff_Amount
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
	--AND Ms.Month_End_Date <=@Month_En_Date
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Net_Round_Amount

UPDATE #Tax_Report
SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0) --isnull(M_AD_Amount,0) +
FROM #Tax_Report Tr
INNER JOIN #Salary_AD sa ON tr.Emp_ID = sa.Emp_ID
	AND tr.AD_ID = sa.aD_ID
INNER JOIN T0050_AD_MASTER AM ON AM.AD_ID = tr.AD_ID
	AND (
		ISNULL(AD_NOT_EFFECT_ON_SAL, 0) = 0
		OR SA.Ad_effect_on_TDS = 1
		)
	AND isnull(AM.Allowance_Type, 'A') <> 'R'
	AND AD_DEF_ID NOT IN (
		20
		,21
		) -- Added by Hardik for Production Bonus and Production Variable on 22/03/2018
	AND (
		Tr.Is_Exempted = 0
		OR TR.Tax_Regime = 'Tax Regime 1'
		OR TR.Tax_Regime IS NULL
		)

--- Aded by Hardik 22/03/2018 for Production Bonus (AIA Client)
UPDATE #Tax_Report
SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0)
FROM #Tax_Report Tr
INNER JOIN (
	SELECT Emp_Id
		,SA.Ad_effect_on_TDS
		,Sum(SA.Old_M_AD_Amount) AS Old_M_AD_Amount
		,Sum(SA.Month_Diff_Amount) AS Month_Diff_Amount
	FROM #Salary_AD SA
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON SA.Ad_Id = AM.AD_ID
	WHERE AD_DEF_ID IN (20)
		AND isnull(AM.Allowance_Type, 'A') <> 'R'
		AND SA.Ad_effect_on_TDS = 1
	GROUP BY Emp_Id
		,SA.Ad_effect_on_TDS
	) SA ON tr.Emp_ID = sa.Emp_ID
WHERE tr.DEFAULT_DEF_ID = @Cont_Production_Bonus

--Ramiz 03/07/2018-- Travel Settlement amount--
UPDATE #Tax_Report
SET Amount_Col_Final = isnull(Travel_Amount, 0)
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,ISNULL(SUM(MS.Travel_Amount), 0) AS Travel_Amount
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
	--AND Ms.Month_End_Date <= @Month_En_Date
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Travel_Settlement_Amount

--Ramiz 03/07/2018-- Travel Settlement amount--	
---- Nilay20062014Perpuisite amount calculation-----
UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + ISNULL(Old_M_AD_Amount, 0)
FROM #Tax_Report Tr
INNER JOIN #Salary_AD sa ON tr.Emp_ID = sa.Emp_ID
	AND tr.Rimb_ID = sa.aD_ID
INNER JOIN T0050_AD_MASTER ON T0050_AD_MASTER.AD_ID = tr.Rimb_ID
WHERE (ISNULL(AD_NOT_EFFECT_ON_SAL, 0) = 1)
	AND isnull(Allowance_Type, 'A') = 'R'
	AND isnull(Tr.Default_Def_Id, 0) = 0
	AND Tr.Is_Exempted = 0

---- Nilay20062014Perpuisite amount calculation-----
-- Added below query from IT_TAX_Preparation by Hardik 29/06/2020 for Tradebulls client
/*Perquisites-Nimesh*/
UPDATE AD
SET Amount_Col_Final = 0
FROM #Tax_Report AD
INNER JOIN #Perq_Detail PD ON PD.EMP_ID = AD.EMP_ID
	AND (
		PD.AD_ID = AD.AD_ID
		OR PD.AD_ID = AD.Rimb_ID
		)
WHERE PD.ShowDetails = 0
	AND Row_ID < 125

-- changed by rohit for Effective month for tax calculate.
UPDATE #Tax_Report
SET Amount_Col_Final = Bonus_Amt
FROM #Tax_Report Tr
INNER JOIN (
	SELECT sa.emp_id
		,SUM(ISNULL(sa.Net_Payable_Bonus, 0)) Bonus_Amt
	FROM T0180_BONUS sa WITH (NOLOCK)
	WHERE dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @FROM_DATE
		AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @TO_DATE
	GROUP BY sa.emp_id
	) QB ON Tr.Emp_ID = QB.Emp_ID
	AND Tr.Default_Def_Id = 2 -- legal Bonus Amount

UPDATE #Tax_Report
SET Amount_Col_Final = 0
WHERE Row_ID = 107

-- Added by rohit For Add exgratia Amount tax calculation on 18052016									
UPDATE #Tax_Report
SET Amount_Col_Final = Ex_Gratia_Bonus_Amount
FROM #Tax_Report Tr
INNER JOIN (
	SELECT sa.emp_id
		,SUM(ISNULL(Ex_Gratia_Bonus_Amount, 0)) Ex_Gratia_Bonus_Amount
	FROM T0180_BONUS sa WITH (NOLOCK)
	WHERE dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @FROM_DATE
		AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @TO_DATE
	GROUP BY sa.emp_id
	) QB ON Tr.Emp_ID = QB.Emp_ID
	AND Tr.Default_Def_Id = 3 -- Exgratia bonus Amount
	-- ended by rohit on 18052016	

-- Added by Hardik 17/03/2020 for WCL, Bonus Allowance amount
UPDATE #Tax_Report
SET Amount_Col_Final = Bonus_Amt
FROM #Tax_Report Tr
INNER JOIN (
	SELECT sa.emp_id
		,SUM(ISNULL(sa.Bonus_amount, 0)) Bonus_Amt
	FROM T0180_BONUS sa WITH (NOLOCK)
	WHERE SA.Cmp_ID = @Cmp_Id
		AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @FROM_DATE
		AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @TO_DATE
		AND Bonus_Cal_Type = 'Regular Bonus'
		AND Bonus_Calculated_On = 'Allowance'
		AND Isnull(Bonus_Effect_on_Sal, 0) = 1
	GROUP BY sa.emp_id
	) QB ON Tr.Emp_ID = QB.Emp_ID
	AND Tr.Default_Def_Id = 13 -- Regular Bonus Amount

-- Added by Hardik 17/03/2020 for WCL, Bonus Exgratia Allowance amount
UPDATE #Tax_Report
SET Amount_Col_Final = Ex_Gratia_Bonus_Amount
FROM #Tax_Report Tr
INNER JOIN (
	SELECT sa.emp_id
		,SUM(ISNULL(Ex_Gratia_Bonus_Amount, 0)) Ex_Gratia_Bonus_Amount
	FROM T0180_BONUS sa WITH (NOLOCK)
	WHERE SA.Cmp_ID = @Cmp_Id
		AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @FROM_DATE
		AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @TO_DATE
		AND Bonus_Cal_Type = 'Exgratia Bonus'
		AND Bonus_Calculated_On = 'Allowance'
		AND Isnull(Bonus_Effect_on_Sal, 0) = 1
	GROUP BY sa.emp_id
	) QB ON Tr.Emp_ID = QB.Emp_ID
	AND Tr.Default_Def_Id = 14 -- Exgratia bonus Amount	

UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT, 0)
FROM #Tax_Report Tr
INNER JOIN (
	SELECT ITD.EMP_ID
		,ITD.IT_ID
		,CASE 
			WHEN ISNULL(IT.Exempt_Percent, 0) > 0
				THEN (ISNULL(SUM(ITD.AMOUNT), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
			ELSE ISNULL(SUM(ITD.AMOUNT), 0)
			END AS AMOUNT
	FROM T0100_IT_DECLARATION ITD WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID
	INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK) ON ITD.IT_ID = IT.IT_ID
		AND ITD.CMP_ID = IT.Cmp_ID
	WHERE ITD.FOR_DATE >= @FROM_DATE
		AND ITD.FOR_DATE <= @TO_DATE
		AND IT.It_Def_Id <> 167 ----Hostel Def Id Not Considering Added By Jimit 16052019
	GROUP BY ITD.EMP_ID
		,ITD.IT_ID
		,IT.Exempt_Percent
	) Q ON TR.EMP_ID = Q.EMP_ID
	AND TR.IT_ID = Q.IT_ID
	AND (
		TR.Tax_Regime = 'Tax Regime 1'
		OR TR.Tax_Regime IS NULL
		) --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME

UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT, 0)
FROM #Tax_Report Tr
INNER JOIN (
	SELECT ITD.EMP_ID
		,ITD.IT_ID
		,CASE 
			WHEN ISNULL(IT.Exempt_Percent, 0) > 0
				THEN (ISNULL(SUM(ITD.AMOUNT), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
			ELSE ISNULL(SUM(ITD.AMOUNT), 0)
			END AS AMOUNT
	FROM T0100_IT_DECLARATION ITD WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID
	INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK) ON ITD.IT_ID = IT.IT_ID
		AND ITD.CMP_ID = IT.Cmp_ID
	INNER JOIN T0070_IT_MASTER IT1 WITH (NOLOCK) ON IT1.IT_ID = IT.IT_Parent_ID
		AND IT1.IT_Alias IN (
			'E'
			,'F'
			,'D'
			) -- 'D' added by Hardik 07/12/2020 for WCL as Leave Exemption head need to display in New Regime
	WHERE ITD.FOR_DATE >= @FROM_DATE
		AND ITD.FOR_DATE <= @TO_DATE
		AND IT.It_Def_Id <> 167 ----Hostel Def Id Not Considering Added By Jimit 16052019
		AND IT.IT_Alias NOT IN (
			'Previous Employer PF'
			,'Prev Emp PT'
			,'Income from self occ'
			,'Intrest on housing'
			)
	--And IT.IT_Def_ID=152 -- 152 added by Hardik 07/12/2020 for WCL as Leave Exemption head need to display in New Regime Comment by ronakk 29052023
	GROUP BY ITD.EMP_ID
		,ITD.IT_ID
		,IT.Exempt_Percent
	) Q ON TR.EMP_ID = Q.EMP_ID
	AND TR.IT_ID = Q.IT_ID
	AND (TR.Tax_Regime = 'Tax Regime 2') --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME

UPDATE #Tax_Report
SET Amount_Col_Final = 0
FROM #Tax_Report Tr
INNER JOIN T0050_AD_MASTER AM ON TR.AD_ID = AM.AD_ID
WHERE TR.Tax_Regime = 'Tax Regime 2' --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME
	AND AM.AD_DEF_ID IN (
		2
		,4
		,5
		) -- For PF, Vol. PF and Employer PF

UPDATE #Tax_Report
SET Default_Def_Id = it_def_id
FROM #Tax_Report tr
INNER JOIN T0070_IT_MASTER it ON it.IT_ID = tr.IT_ID

IF Object_ID('tempdb..#Tbl_Formula') IS NOT NULL
	DROP TABLE #Tbl_Formula

CREATE TABLE #Tbl_Formula (
	Emp_ID NUMERIC
	,Formula_Id NUMERIC
	,Formula_Name NVARCHAR(max)
	,Formula_Value NVARCHAR(max)
	,
	)

IF Object_ID('tempdb..#Tbl_Formula_Result') IS NOT NULL
	DROP TABLE #Tbl_Formula_Result

CREATE TABLE #Tbl_Formula_Result (
	Emp_ID NUMERIC
	,Formula_Name NVARCHAR(max)
	,Formula_Cal NUMERIC(18, 2)
	)

IF Object_ID('tempdb..#Tbl_Result') IS NOT NULL
	DROP TABLE #Tbl_Result

CREATE TABLE #Tbl_Result (
	Emp_ID NUMERIC
	,Formula_Name NVARCHAR(max)
	,Formula_Cal NUMERIC(18, 2)
	)

DECLARE @IS_TOTAL INT
DECLARE @ROW_ID INT
DECLARE @From_Row_ID INT
DECLARE @TO_ROW_ID INT
DECLARE @Multiple_Row_ID VARCHAR(100)
DECLARE @Max_Limit NUMERIC(18, 0)
DECLARE @Max_Limit_Compare_Row_ID INT
DECLARE @Max_Limit_Compare_Type VARCHAR(20)
DECLARE @sqlQuery AS NVARCHAR(4000)
DECLARE @TotalFormula AS VARCHAR(500)
DECLARE @StrSQl VARCHAR(500)

SET @StrSQl = ''

DECLARE @Result NVARCHAR(MAX)
DECLARE @Qry NVARCHAR(MAX)

DECLARE CUR_T CURSOR
FOR
SELECT DISTINCT t.IS_TOTAL
	,t.ROW_ID
	,t.From_Row_ID
	,t.TO_ROW_ID
	,t.Multiple_Row_ID
	,t.Max_Limit
	,t.Max_Limit_Compare_Row_ID
	,t.Max_Limit_Compare_Type
	,FD.TotalFormula
FROM #Tax_Report t
INNER JOIN T0100_IT_FORM_DESIGN FD WITH (NOLOCK) ON t.Row_ID = FD.Row_ID
	AND t.Cmp_ID = FD.Cmp_ID
	AND FD.Financial_Year = @fin_year
WHERE t.IS_TOTAL > 0
ORDER BY Row_ID

OPEN CUR_T

FETCH NEXT
FROM CUR_t
INTO @Is_Total
	,@ROW_ID
	,@FROM_ROW_ID
	,@To_row_ID
	,@Multiple_Row_ID
	,@Max_Limit
	,@Max_Limit_Compare_Row_ID
	,@Max_Limit_Compare_Type
	,@TotalFormula

WHILE @@fetch_status = 0
BEGIN
	SET @sqlQuery = ''

	IF @is_Total = 1
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = isnull(Q.sum_amount, 0)
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,sum(Amount_Col_Final) Sum_amount
			FROM #Tax_Report
			WHERE Row_ID >= @From_Row_ID
				AND Row_ID <= @To_Row_ID
			GROUP BY Emp_ID
			) Q ON t.emp_ID = q.Emp_ID
			AND t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 1
		AND rtrim(@Multiple_Row_ID) <> ''
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = isnull(Q.sum_amount, 0)
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,sum(Amount_Col_Final) Sum_amount
			FROM #Tax_Report
			WHERE Row_ID IN (
					SELECT Data
					FROM dbo.Split(@Multiple_Row_ID, '#')
					WHERE Data > 0
					)
			GROUP BY Emp_ID
			) Q ON t.emp_ID = q.Emp_ID
			AND t.Row_ID = @Row_ID
			--				set @sqlQuery = 'update #Tax_Report
			--								set Amount_Col_Final =isnull(Q.sum_amount,0)
			--								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
			--								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '
			--				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
	END
	ELSE IF @is_Total = 2
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = isnull(Q.First_Amount, 0) - isnull(Q1.Second_Amount, 0)
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS First_Amount
			FROM #Tax_Report
			WHERE Row_ID = @From_Row_ID
			) Q ON t.emp_ID = q.Emp_ID
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS Second_Amount
			FROM #Tax_Report
			WHERE Row_ID = @To_row_ID
			) Q1 ON t.emp_ID = Q1.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 3
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
		AND @Max_Limit > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = CASE 
				WHEN isnull(Q.Sum_amount, 0) <= @Max_Limit
					THEN isnull(Q.Sum_amount, 0)
				WHEN isnull(Q.Sum_amount, 0) > 0
					THEN @Max_Limit
				ELSE 0
				END
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,ISNULL(SUM(Amount_Col_Final), 0) Sum_amount
			FROM #Tax_Report
			WHERE Row_ID >= @From_Row_ID
				AND Row_ID <= @To_Row_ID
			GROUP BY Emp_ID
			) Q ON t.emp_ID = q.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 3
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = CASE 
				WHEN isnull(Q.First_Amount, 0) <= isnull(Q1.Second_Amount, 0)
					THEN isnull(Q.First_Amount, 0)
				ELSE isnull(Q1.Second_Amount, 0)
				END
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS First_Amount
			FROM #Tax_Report
			WHERE Row_ID = @From_Row_ID
			) Q ON t.emp_ID = q.Emp_ID
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS Second_Amount
			FROM #Tax_Report
			WHERE Row_ID = @To_row_ID
			) Q1 ON t.emp_ID = Q1.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 4 -- Added By Nilesh Patel on 23052019 for Formula
	BEGIN
		SET @TotalFormula = REPLACE(@TotalFormula, ' ', '')

		TRUNCATE TABLE #Tbl_Formula

		TRUNCATE TABLE #Tbl_Formula_Result

		TRUNCATE TABLE #Tbl_Result

		INSERT INTO #Tbl_Formula
		SELECT DISTINCT Emp_ID
			,ID
			,Data
			,Data
		FROM dbo.Split(@TotalFormula, '#')
		CROSS JOIN #Tax_Report
		WHERE Data <> '' --and Emp_ID = 14837
		ORDER BY Emp_ID
			,ID

		UPDATE TF
		SET TF.Formula_Value = ISNULL(t.Amount_Col_Final, 0)
		FROM #Tax_Report t
		INNER JOIN #Tbl_Formula TF ON t.Row_ID = TF.Formula_Name
			AND t.Emp_ID = TF.Emp_ID
		WHERE Isnumeric(TF.Formula_Name) > 0
			AND TF.Formula_Name NOT LIKE '(%' ---Added By Deepali -29Jun22

		UPDATE TF
		SET TF.Formula_Value = 0
		FROM #Tbl_Formula tf
		WHERE NOT EXISTS (
				SELECT 1
				FROM #Tax_Report t
				WHERE TF.Formula_Name = t.Row_ID
					AND t.Emp_ID = TF.Emp_ID
				)
			AND TF.Formula_Name LIKE '%[0-9]%'
			AND TF.Formula_Name NOT LIKE '(%' ---Added By Deepali -29Jun22										

		INSERT INTO #Tbl_Formula_Result
		SELECT S.Emp_ID
			,STUFF((
					SELECT ' ' + Formula_Value
					FROM #Tbl_Formula t
					WHERE (t.Emp_ID = S.Emp_ID)
					ORDER BY T.Formula_Id ASC
					FOR XML PATH('')
					), 1, 1, '') AS FormulaValue
			,0
		FROM #Tbl_Formula S
		GROUP BY S.Emp_ID

		--Select * From #Tbl_Formula_Result
		--EXEC (@query)
		--Select * From #Tbl_Formula
		DECLARE @query NVARCHAR(MAX) = ''

		SELECT @query = @query + '
					UNION 
					SELECT Emp_ID, Formula_Name, ' + Formula_Name + ' AS CalcValue 
					FROM #Tbl_Formula_Result WHERE Formula_Name = ''' + Formula_Name + ''' '
		FROM #Tbl_Formula_Result

		SET @query = STUFF(@query, 1, 14, '')

		INSERT INTO #Tbl_Result
		EXEC (@query)

		--INSERT INTO @table
		--EXEC(@sql)
		--SELECT @StrSQl = COALESCE(@StrSQl+' ', ' ') + Replace(Replace(Formula_Value,'}',''),'{','') 
		--from #Tbl_Formula
		--group by Emp_ID
		--SELECT @StrSQl + Replace(Replace(Formula_Value,'}',''),'{','')
		--from #Tbl_Formula
		--if @StrSQl <> ''
		--	Begin
		--		SET @Qry='SELECT @Result = ' + @StrSQl
		--		EXECUTE Sp_executesql @Qry, N'@Result NVARCHAR(MAX) OUTPUT', @Result OUTPUT
		--	End
		UPDATE t
		SET t.Amount_Col_Final = CASE 
				WHEN ISNULL(TR.Formula_Cal, 0) > @Max_Limit
					AND Isnull(@Max_Limit, 0) <> 0
					THEN @Max_Limit
				ELSE ISNULL(TR.Formula_Cal, 0)
				END
		FROM #Tax_Report t
		INNER JOIN #Tbl_Result TR ON t.Emp_ID = TR.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END

	FETCH NEXT
	FROM CUR_t
	INTO @Is_Total
		,@ROW_ID
		,@FROM_ROW_ID
		,@To_row_ID
		,@Multiple_Row_ID
		,@Max_Limit
		,@Max_Limit_Compare_Row_ID
		,@Max_Limit_Compare_Type
		,@TotalFormula
END

CLOSE cur_T

DEALLOCATE Cur_T

/*Perquisite-Nimesh*/
UPDATE PD
SET TaxFreeAmount = MRD.TaxFreeAmount
FROM #Perq_Detail PD
INNER JOIN (
	SELECT MRD.EMP_ID
		,RC_ID
		,Sum(IsNull(Tax_Free_amount, 0)) AS TaxFreeAmount
	FROM T0210_Monthly_Reim_Detail MRD WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MRD.Emp_ID = EC.Emp_ID
	WHERE for_Date >= @from_date
		AND for_Date <= @to_date
		AND Sal_tran_ID IS NULL
	GROUP BY MRD.EMP_ID
		,RC_ID
	) MRD ON PD.Emp_ID = MRD.Emp_ID
	AND PD.AD_ID = MRD.RC_ID

UPDATE #Perq_Detail
SET FinalAmount = IsNull(TotalAmount, 0) - IsNull(TaxFreeAmount, 0)

-----------
DECLARE @EMP_ID_Per AS NUMERIC(18)

DECLARE CUR_Tax_Per CURSOR
FOR
SELECT emp_id
FROM #Emp_Cons

OPEN CUR_Tax_Per

FETCH NEXT
FROM CUR_Tax_Per
INTO @EMP_ID_Per

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @PAct_Gross_Cal AS NUMERIC(18, 2)
	DECLARE @PAct_Exe_Cal1 AS NUMERIC(18, 2)
	DECLARE @Perquisit_amount AS NUMERIC(18, 2)

	--Declare @fin_year as nvarchar(20)
	SET @PAct_Gross_Cal = 0
	SET @PAct_Exe_Cal1 = 0
	SET @Perquisit_amount = 0

	--set @fin_year = cast(year(@From_Date) as nvarchar) + '-' + cast(year(@To_Date) as nvarchar)
	SELECT @PAct_Gross_Cal = Amount_Col_Final
	FROM #Tax_Report
	WHERE Row_ID = 104
		AND Emp_ID = @EMP_ID_Per

	--Select @PAct_Gross_Cal = SUM(Old_M_AD_Amount + Month_Diff_Amount) From #Salary_AD inner join T0050_AD_MASTER adm
	--on adm.ad_id = #Salary_AD.AD_ID where (isnull(adm.AD_NOT_EFFECT_SALARY,0) = 0 and adm.AD_FLAG = 'I') and Emp_ID = @EMP_ID_Per
	--Select @PAct_Gross_Cal = @PAct_Gross_Cal + SUM(Old_M_AD_Amount + Month_Diff_Amount) From #Salary_AD where Default_Def_ID = @Cont_Basic_Sal
	--Select @PAct_Gross_Cal = @PAct_Gross_Cal + Amount_Col_Final From #Tax_Report where (Default_Def_ID = @Cont_Basic_Sal or Default_Def_ID = @Cont_Leave_salary) and Emp_ID = @EMP_ID_Per
	SELECT @PAct_Exe_Cal1 = SUM(Amount_Col_Final)
	FROM #Tax_Report
	WHERE Default_Def_Id IN (
			8
			,9
			,11
			,151
			,152
			,163
			,160
			,164
			,166
			)
		AND Emp_ID = @EMP_ID_Per --added 166 for Gratuity exemption amount (as Tax computation perq value come wrong at WCL) added By Jimit 20012018

	---- Nilay20062014Perpuisite amount calculation-----
	--			Declare @Reim_Perquisite_amount as numeric(18,2)
	--			set @Reim_Perquisite_amount =0 
	--			select @Reim_Perquisite_amount = sum(isnull(Taxable,0) + isnull(Tax_Free_amount,0)) 
	--									from T0210_Monthly_Reim_Detail where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID_Per and
	--			                                       for_date >=@from_date and for_Date<=@to_date
	--			                                       and Sal_tran_ID is null
	---- Nilay20062014Perpuisite amount calculation-----
	EXEC GET_EMP_PERQUISITES @cmp_id
		,@EMP_ID_Per
		,@fin_year
		,@PAct_Gross_Cal
		,@PAct_Exe_Cal1
		,@Perquisit_amount OUTPUT

	/*Perquisite-Nimesh*/--NMS
	SELECT @Perquisit_amount = IsNull(@Perquisit_amount, 0) + IsNull(SUM(PD.FinalAmount), 0)
	FROM #Perq_Detail PD
	--LEFT OUTER JOIN (SELECT EMP_ID, SUM(IsNull(PD.FinalAmount,0)) AS Taxable FROM #Perq_Detail PD GROUP BY EMP_ID) PD ON TR.Emp_ID=PD.Emp_ID
	WHERE Emp_ID = @EMP_ID_Per

	--select	top 1 111, @Perquisit_amount, *
	--from	#Tax_Report  --nms
	UPDATE #Tax_Report
	SET Amount_Col_Final = @Perquisit_amount
	--from #Tax_Report inner join #Emp_Cons ec on ec.Emp_ID = #Tax_Report.Emp_ID
	WHERE Default_Def_Id = @Cont_Perquisit_Amt
		AND Emp_ID = @EMP_ID_Per

	FETCH NEXT
	FROM CUR_Tax_Per
	INTO @EMP_ID_Per
END

CLOSE CUR_Tax_Per

DEALLOCATE CUR_Tax_Per

----------
UPDATE #Tax_Report
SET Amount_Col_Final = 0
WHERE Row_ID = 107

--Added by rohit for add Customized Perq on 26102015
UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT, 0)
FROM #Tax_Report Tr
INNER JOIN (
	SELECT ITD.EMP_ID
		,ITD.IT_ID
		,ISNULL(SUM(ITD.AMOUNT), 0) AMOUNT
	FROM T0240_Perquisites_Employee_Dynamic ITD WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID
	INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK) ON ITD.Cmp_ID = IT.Cmp_ID
		AND ITD.IT_ID = It.IT_ID
		AND It.IT_Is_Active = 1
		AND IT_Is_perquisite = 1
	WHERE ITD.Financial_Year = @fin_year
	GROUP BY ITD.EMP_ID
		,ITD.IT_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
	AND TR.IT_ID = Q.IT_ID

--Ended by rohit for add Customized Perq on 26102015
UPDATE #Tax_Report
SET Amount_Col_Final = Final_Exemption_Amount
FROM #Tax_Report tr
INNER JOIN (
	SELECT t.Emp_ID
		,t.Row_ID
		,CASE 
			WHEN q.Amount_Col_Final > t.Amount_Col_Final
				AND t.Amount_Col_Final > 0
				THEN t.Amount_Col_Final
			ELSE q.Amount_Col_Final
			END Final_Exemption_Amount
	FROM #Tax_Report t
	INNER JOIN (
		SELECT Amount_Col_Final
			,Exem_Againt_Row_ID
			,Emp_ID
		FROM #Tax_Report
		WHERE isnull(Exem_Againt_Row_ID, 0) > 0
			AND Amount_Col_Final > 0
			AND Isnull(Rimb_ID, 0) = 0
		) q --- Hardik 12/02/2016 Condition added for Rimb_Id As Reimbursement Exempt code done in Allowance exempt SP
		ON t.Row_ID = q.Exem_Againt_Row_ID
		AND t.Emp_Id = q.emp_ID
	) q1 ON tr.Exem_Againt_Row_ID = q1.Row_ID
	AND tr.Emp_Id = q1.emp_ID

-- Added by Hardik 03/06/2019 for 80D Total As it should not exceed Individual Mediclaim Limit and Health checkup
DECLARE @ROW_ID_HEALTH INT

SELECT @ROW_ID_HEALTH = Row_ID
FROM #Tax_Report
WHERE Default_Def_Id = 170 --IT_Def_ID  = 170 for Health Checkup

SELECT MAIN.*
INTO #HEALTH_DESIGN
FROM T0100_IT_FORM_DESIGN IFD WITH (NOLOCK)
INNER JOIN T0100_IT_FORM_DESIGN MAIN WITH (NOLOCK) ON MAIN.Row_ID BETWEEN IFD.From_Row_ID
		AND IFD.To_Row_ID
	AND MAIN.Financial_Year = IFD.Financial_Year
WHERE IFD.FINANCIAL_YEAR = @fin_year
	AND IFD.Is_Total = 1
	AND @ROW_ID_HEALTH BETWEEN IFD.From_Row_ID
		AND IFD.To_Row_ID
	AND @ROW_ID_HEALTH <> MAIN.Row_ID
	AND IFD.Cmp_Id = @Cmp_Id

DECLARE @ROW_ID_80D INT

SET @ROW_ID_80D = 0

SELECT @ROW_ID_80D = Isnull(IFD.Row_ID, 0)
FROM T0100_IT_FORM_DESIGN IFD WITH (NOLOCK)
WHERE IFD.FINANCIAL_YEAR = @fin_year
	AND IFD.Is_Total = 1
	AND @ROW_ID_HEALTH BETWEEN IFD.From_Row_ID
		AND IFD.To_Row_ID
	AND IFD.Cmp_Id = @Cmp_Id

UPDATE T
SET Amount_Col_Final = CASE 
		WHEN CLAIMED_AMOUNT + TR_HEALTH.Amount_Col_Final > IT.MAX_LIMIT
			THEN IT.MAX_LIMIT
		ELSE CLAIMED_AMOUNT + TR_HEALTH.Amount_Col_Final
		END
FROM #Tax_Report T
INNER JOIN (
	SELECT TR.EMP_ID
		,SUM(TR.Amount_Col_Final) AS CLAIMED_AMOUNT
		,SUM(TR.Max_Limit) AS MAX_LIMIT
	FROM #HEALTH_DESIGN HD
	INNER JOIN #Tax_Report TR ON HD.IT_ID = TR.IT_ID
	WHERE TR.Amount_Col_Final > 0
	GROUP BY TR.EMP_ID
	) IT ON T.Emp_ID = IT.Emp_ID
INNER JOIN #Tax_Report TR_HEALTH ON T.Emp_ID = TR_HEALTH.EMP_ID
	AND TR_HEALTH.Row_ID = @ROW_ID_HEALTH
WHERE T.Row_ID = @ROW_ID_80D

--- End for Health Check	 
SET @IS_TOTAL = 0
SET @ROW_ID = 0
SET @From_Row_ID = 0
SET @TO_ROW_ID = 0
SET @Multiple_Row_ID = ''
SET @Max_Limit = 0
SET @Max_Limit_Compare_Row_ID = 0
SET @Max_Limit_Compare_Type = ''
SET @sqlQuery = ''
SET @StrSQl = ''

DECLARE CUR_T CURSOR
FOR
SELECT DISTINCT t.IS_TOTAL
	,t.ROW_ID
	,t.From_Row_ID
	,t.TO_ROW_ID
	,t.Multiple_Row_ID
	,t.Max_Limit
	,t.Max_Limit_Compare_Row_ID
	,t.Max_Limit_Compare_Type
	,FD.TotalFormula
FROM #Tax_Report t
INNER JOIN T0100_IT_FORM_DESIGN FD WITH (NOLOCK) ON t.Row_ID = FD.Row_ID
	AND t.Cmp_ID = FD.Cmp_ID
	AND FD.Financial_Year = @fin_year
WHERE t.IS_TOTAL > 0
	AND T.Row_ID <> @Row_ID_80D
ORDER BY Row_ID

OPEN CUR_T

FETCH NEXT
FROM CUR_t
INTO @Is_Total
	,@ROW_ID
	,@FROM_ROW_ID
	,@To_row_ID
	,@Multiple_Row_ID
	,@Max_Limit
	,@Max_Limit_Compare_Row_ID
	,@Max_Limit_Compare_Type
	,@TotalFormula

WHILE @@fetch_status = 0
BEGIN
	SET @sqlQuery = ''

	IF @is_Total = 1
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = isnull(Q.sum_amount, 0)
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,sum(Amount_Col_Final) Sum_amount
			FROM #Tax_Report
			WHERE Row_ID >= @From_Row_ID
				AND Row_ID <= @To_Row_ID
			GROUP BY Emp_ID
			) Q ON t.emp_ID = q.Emp_ID
			AND t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 1
		AND rtrim(@Multiple_Row_ID) <> ''
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = isnull(Q.sum_amount, 0)
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,sum(Amount_Col_Final) Sum_amount
			FROM #Tax_Report
			WHERE Row_ID IN (
					SELECT Data
					FROM dbo.Split(@Multiple_Row_ID, '#')
					WHERE Data > 0
					)
			GROUP BY Emp_ID
			) Q ON t.emp_ID = q.Emp_ID
			AND t.Row_ID = @Row_ID
			--				set @sqlQuery = 'update #Tax_Report
			--								set Amount_Col_Final =isnull(Q.sum_amount,0)
			--								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
			--								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '
			--				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
	END
	ELSE IF @is_Total = 2
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = isnull(Q.First_Amount, 0) - isnull(Q1.Second_Amount, 0)
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS First_Amount
			FROM #Tax_Report
			WHERE Row_ID = @From_Row_ID
			) Q ON t.emp_ID = q.Emp_ID
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS Second_Amount
			FROM #Tax_Report
			WHERE Row_ID = @To_row_ID
			) Q1 ON t.emp_ID = Q1.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 3
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
		AND @Max_Limit > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = CASE 
				WHEN isnull(Q.Sum_amount, 0) <= @Max_Limit
					THEN isnull(Q.Sum_amount, 0)
				WHEN isnull(Q.Sum_amount, 0) > 0
					THEN @Max_Limit
				ELSE 0
				END
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,isnull(sum(Amount_Col_Final), 0) Sum_amount
			FROM #Tax_Report
			WHERE Row_ID >= @From_Row_ID
				AND Row_ID <= @To_Row_ID
			GROUP BY Emp_ID
			) Q ON t.emp_ID = q.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 3
		AND @FROM_ROW_ID > 0
		AND @To_row_ID > 0
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = CASE 
				WHEN isnull(Q.First_Amount, 0) <= isnull(Q1.Second_Amount, 0)
					THEN isnull(Q.First_Amount, 0)
				ELSE isnull(Q1.Second_Amount, 0)
				END
		FROM #Tax_Report t
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS First_Amount
			FROM #Tax_Report
			WHERE Row_ID = @From_Row_ID
			) Q ON t.emp_ID = q.Emp_ID
		INNER JOIN (
			SELECT Emp_ID
				,Amount_Col_Final AS Second_Amount
			FROM #Tax_Report
			WHERE Row_ID = @To_row_ID
			) Q1 ON t.emp_ID = Q1.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END
	ELSE IF @is_Total = 4 -- Added By Nilesh Patel on 23052019 for Formula
	BEGIN
		SET @TotalFormula = REPLACE(@TotalFormula, ' ', '')

		TRUNCATE TABLE #Tbl_Formula

		TRUNCATE TABLE #Tbl_Formula_Result

		TRUNCATE TABLE #Tbl_Result

		INSERT INTO #Tbl_Formula
		SELECT DISTINCT Emp_ID
			,ID
			,Data
			,Data
		FROM dbo.Split(@TotalFormula, '#')
		CROSS JOIN #Tax_Report
		WHERE Data <> '' --and Emp_ID = 14837
		ORDER BY Emp_ID
			,ID

		UPDATE TF
		SET TF.Formula_Value = ISNULL(t.Amount_Col_Final, 0)
		FROM #Tax_Report t
		INNER JOIN #Tbl_Formula TF ON t.Row_ID = TF.Formula_Name
			AND t.Emp_ID = TF.Emp_ID
		WHERE Isnumeric(TF.Formula_Name) > 0

		UPDATE TF
		SET TF.Formula_Value = 0
		FROM #Tbl_Formula tf
		WHERE NOT EXISTS (
				SELECT 1
				FROM #Tax_Report t
				WHERE TF.Formula_Name = t.Row_ID
					AND t.Emp_ID = TF.Emp_ID
				)
			AND TF.Formula_Name LIKE '%[0-9]%'
			AND TF.Formula_Name NOT LIKE '(%' -- Added By Deepali -29Jun22

		INSERT INTO #Tbl_Formula_Result
		SELECT S.Emp_ID
			,STUFF((
					SELECT ' ' + Formula_Value
					FROM #Tbl_Formula t
					WHERE (t.Emp_ID = S.Emp_ID)
					ORDER BY T.Formula_Id ASC
					FOR XML PATH('')
					), 1, 1, '') AS FormulaValue
			,0
		FROM #Tbl_Formula S
		GROUP BY S.Emp_ID

		--Select * From #Tbl_Formula_Result
		--EXEC (@query)
		--Select * From #Tbl_Formula
		SET @query = ''

		SELECT @query = @query + '
					UNION 
					SELECT Emp_ID, Formula_Name, ' + Formula_Name + ' AS CalcValue 
					FROM #Tbl_Formula_Result WHERE Formula_Name = ''' + Formula_Name + ''' '
		FROM #Tbl_Formula_Result

		SET @query = STUFF(@query, 1, 14, '')

		INSERT INTO #Tbl_Result
		EXEC (@query)

		--INSERT INTO @table
		--EXEC(@sql)
		--SELECT @StrSQl = COALESCE(@StrSQl+' ', ' ') + Replace(Replace(Formula_Value,'}',''),'{','') 
		--from #Tbl_Formula
		--group by Emp_ID
		--SELECT @StrSQl + Replace(Replace(Formula_Value,'}',''),'{','')
		--from #Tbl_Formula
		--if @StrSQl <> ''
		--	Begin
		--		SET @Qry='SELECT @Result = ' + @StrSQl
		--		EXECUTE Sp_executesql @Qry, N'@Result NVARCHAR(MAX) OUTPUT', @Result OUTPUT
		--	End
		UPDATE t
		SET t.Amount_Col_Final = CASE 
				WHEN ISNULL(TR.Formula_Cal, 0) > @Max_Limit
					AND Isnull(@Max_Limit, 0) <> 0
					THEN @Max_Limit
				ELSE ISNULL(TR.Formula_Cal, 0)
				END
		FROM #Tax_Report t
		INNER JOIN #Tbl_Result TR ON t.Emp_ID = TR.Emp_ID
		WHERE t.Row_ID = @Row_ID
	END

	FETCH NEXT
	FROM CUR_t
	INTO @Is_Total
		,@ROW_ID
		,@FROM_ROW_ID
		,@To_row_ID
		,@Multiple_Row_ID
		,@Max_Limit
		,@Max_Limit_Compare_Row_ID
		,@Max_Limit_Compare_Type
		,@TotalFormula
END

CLOSE cur_T

DEALLOCATE Cur_T

UPDATE T
SET Amount_Col_Final = 0
FROM #Tax_Report T
WHERE Field_Type = 2
	AND Amount_Col_Final < 0 -- Added Condition by Hardik 28/08/2018 for Arkray as they don't want to show Negative Taxable Amount	

-----------------------------Define in annexture in salary wise ---------------------------------------	
UPDATE #Tax_Report
SET Amount_Col_Final = 0
FROM #Tax_Report t
--WHERE t.Row_ID =138	 --- Commented by Hardik 27/04/2018
WHERE t.Default_Def_Id = 9 -- For Conveyance Exemption -- Added by Hardik 27/04/2018
	AND EXISTS (
		SELECT 1
		FROM T0240_Perquisites_Employee_Car PEC WITH (NOLOCK)
		WHERE PEC.Financial_Year = @fin_year
			AND PEC.emp_id = T.Emp_ID
		)

UPDATE #Tax_Report
SET Amount_Col_Final = isnull(M_AD_Amount, 0)
FROM #Tax_Report t
INNER JOIN T0210_Monthly_AD_Detail mad ON t.emp_ID = mad.Emp_ID
	AND t.IT_Month = month(Mad.To_Date)
	AND t.IT_Year = Year(Mad.To_Date)
INNER JOIN T0050_AD_MAster am ON mad.AD_ID = am.AD_ID
	AND AD_DEF_ID = 1
	AND M_AD_Amount > 0

-- Added by Hardik 05/06/2020 for Aculife as they deducted pending tax in Apr and May month under Allowance Name : "Income Tax Recovery"
UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + Isnull(Qry.M_AD_Amount, 0)
FROM #Tax_Report t
INNER JOIN (
	SELECT sum(M_AD_Amount) M_AD_Amount
		,T.Emp_Id
		,3 AS Month_1
		,Year(@To_date) AS Year_1
	FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK)
	INNER JOIN #Tax_Report T ON Mad.Emp_Id = T.Emp_ID
		AND T.IT_Month = 3
		AND T.IT_YEAR = Year(@To_date)
	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON Mad.ad_id = Am.ad_id
		AND mad.Cmp_ID = am.CMP_ID
	WHERE (
			(
				Month(MAD.To_Date) = Month(DateAdd(MM, 1, @To_Date))
				AND Year(MAD.To_Date) = Year(@To_Date)
				)
			OR (
				Month(MAD.To_Date) = Month(DateAdd(MM, 2, @To_Date))
				AND Year(MAD.To_Date) = Year(@To_Date)
				)
			)
		AND AM.AD_Name = 'Income Tax Recovery'
	GROUP BY T.Emp_ID
	) Qry ON t.Emp_ID = qry.Emp_ID
	AND T.IT_Month = Month_1
	AND T.IT_YEAR = Year_1

-- Added by rohit on 03062016 for Extra tds not Shows in the report
UPDATE #Tax_Report
SET Amount_Col_Final = isnull(Amount_Col_Final, 0) + Isnull(mad.TDS, 0)
FROM #Tax_Report t
INNER JOIN (
	SELECT sum(isnull(TDS, 0)) AS tds
		,Emp_Id
		,month(for_date) AS _Month
		,YEAR(For_Date) AS _year
	FROM T0210_ESIC_On_Not_Effect_on_Salary WITH (NOLOCK)
	GROUP BY emp_id
		,month(for_date)
		,YEAR(For_Date)
	) mad ON t.emp_ID = mad.Emp_ID
	AND t.IT_Month = _Month
	AND t.IT_Year = _year
	AND mad.TDS > 0 --Extra Deducted TDS not effected on salary Component added by Rohit on  21072015

--Added by Hardik 05/03/2019 for Additional TDS Paid through TDS Challan
IF EXISTS (
		SELECT 1
		FROM sys.syscolumns
		WHERE name LIKE 'Additional_Amount'
			AND id = OBJECT_ID('T0230_TDS_CHALLAN_DETAIL')
		) -- Added condition by Hardik 15/04/2019 As Some client has this column created and some has not created so it is giving error
BEGIN
	UPDATE #Tax_Report
	SET Amount_Col_Final = isnull(Amount_Col_Final, 0) + Isnull(TDS_Challan.Additional_Amount, 0)
	FROM #Tax_Report t
	INNER JOIN (
		SELECT TCD.Emp_Id
			,TC.Month
			,TC.Year
			,Sum(Isnull(TCD.Additional_Amount, 0)) AS Additional_Amount
		FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
		INNER JOIN T0230_TDS_CHALLAN_DETAIL TCD WITH (NOLOCK) ON TC.Challan_Id = TCD.Challan_Id
		WHERE TCD.Additional_Amount > 0
		GROUP BY TCD.Emp_Id
			,TC.Month
			,TC.Year
		) TDS_Challan ON t.emp_ID = TDS_Challan.Emp_ID
		AND t.IT_Month = TDS_Challan.Month
		AND t.IT_Year = TDS_Challan.Year
END

UPDATE #Tax_Report
SET Amount_Col_Final = isnull(Amount_Col_Final, 0) + Isnull(mad.Income_Tax_on_Bonus, 0)
FROM #Tax_Report t
INNER JOIN (
	SELECT sum(isnull(Income_Tax_on_Bonus, 0)) AS Income_Tax_on_Bonus
		,Emp_Id
		,Bonus_Effect_Month AS Bonus_Effect_Month
		,Bonus_Effect_Year AS Bonus_Effect_Year
	FROM t0180_bonus WITH (NOLOCK)
	GROUP BY emp_id
		,Bonus_Effect_Month
		,Bonus_Effect_Year
	) mad ON t.emp_ID = mad.Emp_ID
	AND t.IT_Month = Bonus_Effect_Month
	AND t.IT_Year = Bonus_Effect_Year
	AND mad.Income_Tax_on_Bonus > 0 --Extra Deducted TDS on Bonus and Exgratia amount added by Rohit on  19052016

UPDATE #Tax_Report
SET Amount_Col_Final = Amount_Col_Final + Isnull(M_AD_Amount, 0)
FROM #Tax_Report t
INNER JOIN T0210_Monthly_AD_Detail mad ON t.emp_ID = mad.Emp_ID
	AND t.IT_Month = MONTH(Mad.To_Date)
	AND t.IT_Year = YEAR(Mad.To_Date)
INNER JOIN T0050_AD_MAster am ON mad.AD_ID = am.AD_ID
	AND AD_DEF_ID = 13
	AND mad.M_AD_Amount > 0 --Extra TDS not effected in salary added by Hasmukh 17092014

-- Ended by rohit on 03062016		
UPDATE #Tax_Report
SET M_Edu_Cess_Amount = IT_M_ED_Cess_Amount
FROM #Tax_Report t
INNER JOIN T0200_Monthly_Salary mad ON t.emp_ID = mad.Emp_ID
	AND t.IT_Month = month(Mad.Month_End_Date)
	AND t.IT_Year = Year(Mad.Month_End_Date)

UPDATE #Tax_Report
SET M_Surcharge_Amount = IT_M_Surcharge_Amount
FROM #Tax_Report t
INNER JOIN T0200_Monthly_Salary mad ON t.emp_ID = mad.Emp_ID
	AND t.IT_Month = month(Mad.Month_End_Date)
	AND t.IT_Year = Year(Mad.Month_End_Date)

-----------------------Define in annexture in salary wise ---------------------------------------	
--DECLARE CUR_AD_Tax CURSOR FOR 
--	SELECT Distinct EMP_ID ,Increment_ID FROM #Tax_Report 	
--OPEN CUR_AD_Tax 
--FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID
--WHILE @@FETCH_STATUS =0
--	BEGIN
--		set @Month_Sal =0
--		select @Month_Sal = isnull(count(emp_ID),0) From T0200_Monthly_Salary where Emp_ID=@emp_ID and Month_St_Date >=@From_Date and Month_st_Date <=@To_Date
--		if @Month_Count -( @Month_Sal + 1 ) > 0
--			set @Month_Diff = @Month_Count -( @Month_Sal + 1 )
--		else 
--			set @Month_Diff =0
--		set @Month_Diff = 0
--		Exec dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID,@Cmp_ID,@Increment_ID,@From_Date,@To_Date,@Month_Diff,''
--		Exec SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Count,0
--		FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID		
--	END
--CLOSE CUR_AD_Tax
--DEALLOCATE CUR_AD_Tax
--Update #Tax_Report 
--set Increment_ID = Q.Increment_ID 
--from #Tax_Report t inner join 
--(select I.Emp_Id ,Increment_ID from T0095_Increment I inner join 
--				( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
--				where Increment_Effective_date <= @To_Date
--				and Cmp_ID = @Cmp_ID
--				group by emp_ID  ) Qry on
--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
--		Where Cmp_ID = @Cmp_ID )Q on t.emp_ID =q.Emp_ID 
DECLARE @TAXABLE_AMOUNT NUMERIC
DECLARE @Return_Tax_Amount NUMERIC
DECLARE @Surcharge_amount NUMERIC
DECLARE @ED_Cess NUMERIC
DECLARE @M_AD_Amount NUMERIC
DECLARE @TAXABLE_AMOUNT_Inc NUMERIC
DECLARE @Return_Tax_Amount_Inc NUMERIC
DECLARE @Surcharge_amount_Inc NUMERIC
DECLARE @ED_Cess_Inc NUMERIC
DECLARE @M_AD_Amount_Inc NUMERIC
DECLARE @Incentive_Amount NUMERIC
DECLARE @Return_Tax_Amount_Actual NUMERIC --Ankit 27042016

SET @Return_Tax_Amount_Actual = 0

DECLARE CUR_TAX CURSOR
FOR
SELECT EMP_ID
	,Amount_Col_Final
	,Increment_ID
	,Tax_Regime
FROM #Tax_Report
WHERE field_type = 2

OPEN CUR_TAX

FETCH NEXT
FROM CUR_TAX
INTO @EMP_ID
	,@TAXABLE_AMOUNT
	,@Increment_ID
	,@TAX_REGIME

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Return_Tax_Amount = 0
	SET @Surcharge_amount = 0
	SET @ED_Cess = 0
	SET @TAXABLE_AMOUNT_Inc = 0
	SET @Return_Tax_Amount_Inc = 0
	SET @Surcharge_amount_Inc = 0
	SET @ED_Cess_Inc = 0
	SET @Incentive_Amount = 0
	SET @Return_Tax_Amount_Actual = 0

	SELECT @Incentive_Amount = ISNULL(SUM(Amount_Col_Final), 0)
	FROM #Tax_Report
	WHERE Emp_ID = @Emp_ID
		AND isnull(Is_Incentive, 0) = 1 --ISNULL(Is_Salary_comp,0) = 1 

		
	IF @Incentive_Amount > 0
	BEGIN
		SET @TAXABLE_AMOUNT_Inc = @TAXABLE_AMOUNT - @Incentive_Amount

		EXEC dbo.SP_IT_TAX_CALCULATION @Cmp_ID
			,@Emp_ID
			,@To_Date
			,@TAXABLE_AMOUNT_Inc
			,@Return_Tax_Amount_Inc OUTPUT
			,@Surcharge_amount_Inc OUTPUT
			,@ED_Cess_Inc OUTPUT
			,@ED_Cess_Per
			,@SurCharge_Per
			,@Relief_87A_Amount OUTPUT
			,@Return_Tax_Amount_Actual OUTPUT
			,@TAX_REGIME

		SET @Return_Tax_Amount_Inc = @Return_Tax_Amount_Inc + @ED_Cess_Inc
	END

	EXEC dbo.SP_IT_TAX_CALCULATION @Cmp_ID
		,@Emp_ID
		,@To_Date
		,@TAXABLE_AMOUNT
		,@Return_Tax_Amount OUTPUT
		,@Surcharge_amount OUTPUT
		,@ED_Cess OUTPUT
		,@ED_Cess_Per
		,@SurCharge_Per
		,@Relief_87A_Amount OUTPUT
		,@Return_Tax_Amount_Actual OUTPUT
		,@TAX_REGIME

		
	UPDATE #Tax_Report
	SET Amount_Col_Final = @Return_Tax_Amount
	WHERE Emp_ID = @Emp_ID
		AND Default_Def_ID = @Cont_Total_Tax

	--------- Relief_87A_Amount Add By Hasmukh 20-Dec-13------------
	DECLARE @Actual_IT_Amount AS NUMERIC(18, 2)

	--DECLARE @Sec_87A_Amount NUMERIC(18,2)
	--SET @Relief_sec_87_limit = 500000	
	--IF YEAR(@From_Date) >= 2017
	--	BEGIN
	--		SET @Sec_87A_Amount = 2500
	--		SET @Relief_sec_87_limit = 350000
	--	END
	--ELSE IF YEAR(@From_Date) >= 2016		/* Relief Limit Change 2000 to 5000 effect From Year 2016-2017  --Ankit 25042016	*/
	--	SET @Sec_87A_Amount = 5000
	--ELSE	
	--	SET @Sec_87A_Amount = 2000
	--SET @Sec_87A_Amount = 2000
	IF @Relief_87A_Amount > 0
		AND year(@To_Date) >= 2014
	BEGIN
		UPDATE #Tax_Report
		SET Amount_Col_Final = @Return_Tax_Amount_Actual -- Amount_Col_Final + @Sec_87A_Amount
		WHERE Emp_ID = @Emp_ID
			AND Default_Def_ID = 101

		SELECT @Actual_IT_Amount = Amount_Col_Final
		FROM #Tax_Report
		WHERE Emp_ID = @Emp_ID
			AND Default_Def_ID = 101

		UPDATE #Tax_Report
		SET Amount_Col_Final = @Relief_87A_Amount --@Sec_87A_Amount 
		WHERE Emp_ID = @Emp_ID
			AND Default_Def_ID = - 102

		UPDATE #Tax_Report
		SET Amount_Col_Final = @Actual_IT_Amount - @Relief_87A_Amount --@Sec_87A_Amount
		WHERE Emp_ID = @Emp_ID
			AND Default_Def_ID = - 103
	END

	-------------------End---------------------------
	--Update #Tax_Report 
	--set Amount_Col_Final = @Surcharge_amount 
	--where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Surcharge
	--set @Return_Tax_Amount = @Return_Tax_Amount + @Surcharge_amount
	--Update #Tax_Report 
	--set Amount_Col_Final = @Return_Tax_Amount
	--where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Total_tax_Lia
	UPDATE #Tax_Report
	SET Amount_Col_Final = @ED_Cess
	WHERE Emp_ID = @Emp_ID
		AND Default_Def_ID = @Cont_ED_Cess

	--set @Return_Tax_Amount  = @Return_Tax_Amount + @ED_Cess
	UPDATE #Tax_Report
	SET Amount_Col_Final = @Return_Tax_Amount
	WHERE Emp_ID = @Emp_ID
		AND (
			Default_Def_ID = @Cont_Net_Lia
			OR Default_Def_ID = @Cont_Tax
			)

	SET @Other_Paid_TDS_Amont = 0

	SELECT @Other_Paid_TDS_Amont = ISNULL(sum(Amount), 0)
	FROM T0100_IT_DECLARATION ID WITH (NOLOCK)
	LEFT OUTER JOIN T0070_IT_MASTER IM WITH (NOLOCK) ON ID.IT_ID = IM.IT_ID
		AND IM.cmp_id = IM.cmp_id
	WHERE Emp_ID = @Emp_ID
		AND For_Date >= @From_Date
		AND for_Date <= @To_Date -- and For_Date <=@Month_En_Date 
		AND IM.IT_Def_ID = 10

	--Start-------1-Cr.--Surcharge---------------------------------------------------Mitesh--
	DECLARE @Taxabel_Income_S NUMERIC(18, 2)

	--select @Taxabel_Income_S = Amount_Col_Final from #Tax_Report WHERE field_type = 2 AND emp_id = @EMP_ID
	SET @Taxabel_Income_S = @TAXABLE_AMOUNT

	--IF @Taxabel_Income_S >= 10000000
	IF @Taxabel_Income_S >= 10000000
		OR (
			@Taxabel_Income_S >= 5000000
			AND YEAR(@From_Date) >= 2017
			) --Added by Nimesh on 26-April-2017 (For new Slab)
	BEGIN
		-- Old Code for Surcharge -- Added by rohit on 24072015
		--DECLARE @limt_Const_S NUMERIC(18,2) 
		--DECLARE @tax_Payable_On_limit_Const_S NUMERIC(18,2) 
		--DECLARE @Tax_Amount_S NUMERIC(18,2)
		--DECLARE @Tax_Amount_WO_S NUMERIC(18,2)
		--DECLARE @Temp_Surcharge_S NUMERIC(18,2)
		--DECLARE @Marginal_Relief_S NUMERIC(18,2)
		--DECLARE @Actual_Surcharge_S NUMERIC(18,2) 
		--DECLARE @TAXABLE_AMOUNT_with_Sur NUMERIC(18,2) 
		--SET @Marginal_Relief_S = 0
		--SET @Actual_Surcharge_S = 0
		--SET @limt_Const_S =  10000000
		----SET @tax_Payable_On_limit_Const_S = 2830000  -- tax on 1 cr.
		----SET @Tax_Amount_WO_S = (@Return_Tax_Amount - @Other_Paid_TDS_Amont) 
		----SET @Tax_Amount_S = @Tax_Amount_WO_S + @Tax_Amount_WO_S * 0.1
		----IF (@Taxabel_Income_S - @tax_Payable_On_limit_Const_S) >= (@Taxabel_Income_S - @limt_Const_S)
		----	BEGIN
		----		SET @Marginal_Relief_S = (@limt_Const_S + (@Tax_Amount_S - @tax_Payable_On_limit_Const_S)) - @Taxabel_Income_S
		----	END
		----ELSE
		----	BEGIN
		----		SET @Marginal_Relief_S = 0
		----	END 
		----IF @Marginal_Relief_S < 0
		----	BEGIN
		----		SET @Marginal_Relief_S = 0
		----	END
		----SET @Actual_Surcharge_S =  (@Tax_Amount_S - @Marginal_Relief_S)	-@Tax_Amount_WO_S 
		--SET @Actual_Surcharge_S =  (@Taxabel_Income_S - @limt_Const_S) -  ((@Taxabel_Income_S - @limt_Const_S)*30/100)
		--UPDATE #Tax_Report SET Amount_Col_Final = @Actual_Surcharge_S WHERE default_def_id = @Cont_Surcharge AND emp_id = @emp_id
		--SET @TAXABLE_AMOUNT_with_Sur = @Return_Tax_Amount + @Actual_Surcharge_S
		--SET @Return_Tax_Amount = @TAXABLE_AMOUNT_with_Sur
		DECLARE @limt_Const_S NUMERIC(18, 2)
		DECLARE @tax_Payable_On_limit_Const_S NUMERIC(18, 2)
		DECLARE @Tax_Amount_S NUMERIC(18, 2)
		DECLARE @Tax_Amount_WO_S NUMERIC(18, 2)
		DECLARE @Temp_Surcharge_S NUMERIC(18, 2)
		DECLARE @Marginal_Relief_S NUMERIC(18, 2)
		DECLARE @Actual_Surcharge_S NUMERIC(18, 2)
		DECLARE @TAXABLE_AMOUNT_with_Sur NUMERIC(18, 2)
		DECLARE @Surcharge_Amt AS NUMERIC(18, 2)

		SET @Marginal_Relief_S = 0
		SET @Actual_Surcharge_S = 0
		SET @Surcharge_Amt = 0

		--SET @limt_Const_S =  10000000
		IF YEAR(@From_Date) >= 2017
			IF @Taxabel_Income_S >= 5000000
				AND @Taxabel_Income_S < 10000000
				SET @limt_Const_S = 5000000
			ELSE
				SET @limt_Const_S = 10000000
		ELSE
			SET @limt_Const_S = 10000000

		-- Added by rohit on 27062015
		DECLARE @net_Income_Range NUMERIC(18, 2)
		DECLARE @Surchage_Percentage NUMERIC(18, 2)

		SET @net_Income_Range = 0
		SET @Surchage_Percentage = 0

		SELECT @net_Income_Range = net_income_Range
			,@Surchage_Percentage = Field_Value
		FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
		WHERE default_def_id = @Cont_Surcharge
			AND Financial_Year = @fin_year
			AND Cmp_ID = @Cmp_ID

		IF @net_Income_Range = 0
			SET @net_Income_Range = 10510540

		IF @Surchage_Percentage = 0
			SET @Surchage_Percentage = 10

		IF YEAR(@From_Date) <= 2018
		BEGIN
			IF @Taxabel_Income_S >= 5000000
				AND @Taxabel_Income_S < 10000000
				SET @Surchage_Percentage = 10
			ELSE IF @Taxabel_Income_S > 10000000
				SET @Surchage_Percentage = 15
			ELSE IF @Taxabel_Income_S < 10000000
				SET @Surchage_Percentage = 15
		END
		ELSE -- Added condition for New Slab in 2019 Budget
		BEGIN
			IF @Taxabel_Income_S >= 5000000
				AND @Taxabel_Income_S < 10000000
				SET @Surchage_Percentage = 10
			ELSE IF @Taxabel_Income_S >= 10000000
				AND @Taxabel_Income_S < 20000000
				SET @Surchage_Percentage = 15
			ELSE IF @Taxabel_Income_S >= 20000000
				AND @Taxabel_Income_S <= 50000000
				SET @Surchage_Percentage = 25
			ELSE IF @Taxabel_Income_S > 50000000
				SET @Surchage_Percentage = 37
		END

		-- Ended by rohit on 27062015
		-- Added By Sajid 15042023 for Surcharge Changes in Tax Regime 2 FY 23-24 Reduce Surcharge 25% Instead of 37%
		IF YEAR(@From_Date) >= 2023
			AND @TAX_REGIME = 'Tax Regime 2'
			OR (
				@TAX_REGIME IS NULL
				OR @TAX_REGIME = '0'
				)
		BEGIN
			IF @Taxabel_Income_S >= 5000000
				AND @Taxabel_Income_S < 10000000
				SET @Surchage_Percentage = 10
			ELSE IF @Taxabel_Income_S >= 10000000
				AND @Taxabel_Income_S < 20000000
				SET @Surchage_Percentage = 15
			ELSE IF @Taxabel_Income_S >= 20000000
				SET @Surchage_Percentage = 25
		END

		---Below Condition for Wonder, When give version to Wonder uncomment below code. 
		--SET @tax_Payable_On_limit_Const_S = 2830000  -- tax on 1 cr.
		--SET @Tax_Amount_WO_S = (@Return_Tax_Amount - @Other_Paid_TDS_Amont) 
		--If @From_Date < '01-Apr-2015' --Changed by Hardik 09/06/2015 as rule changed from 01-apr-2015
		--SET @Tax_Amount_S = @Tax_Amount_WO_S + @Tax_Amount_WO_S * 0.1
		--else
		--SET @Tax_Amount_S = @Tax_Amount_WO_S + @Tax_Amount_WO_S * 0.12
		--IF (@Taxabel_Income_S - @tax_Payable_On_limit_Const_S) >= (@Taxabel_Income_S - @limt_Const_S)
		--	BEGIN
		--		SET @Marginal_Relief_S = (@limt_Const_S + (@Tax_Amount_S - @tax_Payable_On_limit_Const_S)) - @Taxabel_Income_S
		--	END
		--ELSE
		--	BEGIN
		--		SET @Marginal_Relief_S = 0
		--	END 
		--IF @Marginal_Relief_S < 0
		--	BEGIN
		--		SET @Marginal_Relief_S = 0
		--	END
		--SET @Actual_Surcharge_S =  (@Tax_Amount_S - @Marginal_Relief_S)	-@Tax_Amount_WO_S 
		---When Give version to Wonder, Comment below line, which is using by BMA
		--SET @Actual_Surcharge_S =  (@Taxabel_Income_S - @limt_Const_S) -  ((@Taxabel_Income_S - @limt_Const_S)*30/100)
		---Added common surcharge calculation by Hardik/Rohit as per Cera calculation 26/06/2015
		--If @From_Date <= '01-Apr-2014' -- 12% Effective from 01-Apr-2015 change by Hardik 27/06/2015
		--	Set @Surcharge_Amt= (@Return_Tax_Amount * 10/100)
		--ELSE
		--	Set @Surcharge_Amt= (@Return_Tax_Amount * 12/100)	
		--if @Taxabel_Income_S >= 5000000 and @Taxabel_Income_S < 10000000
		--	SET @Surchage_Percentage =  10
		--else  if  @Taxabel_Income_S >  10000000
		--	SET @Surchage_Percentage =  15							
		--else  if  @Taxabel_Income_S <  10000000
		--    SET @Surchage_Percentage =  15		
		SET @Surcharge_Amt = (@Return_Tax_Amount * @Surchage_Percentage / 100)
		SET @tax_Payable_On_limit_Const_S = ROUND((@Taxabel_Income_S - @limt_Const_S) * 30 / 100, 0)

		IF (@Taxabel_Income_S) <= @net_Income_Range -- 10510540
		BEGIN
			SET @Marginal_Relief_S = (@Taxabel_Income_S - @limt_Const_S) - @tax_Payable_On_limit_Const_S
		END
		ELSE
			SET @Marginal_Relief_S = 0

		IF (@Taxabel_Income_S) <= @net_Income_Range --10510540 
			SET @Actual_Surcharge_S = CASE 
					WHEN @Surcharge_Amt < @Marginal_Relief_S
						THEN @Surcharge_Amt
					ELSE @Marginal_Relief_S
					END
		ELSE
			SET @Actual_Surcharge_S = CASE 
					WHEN @Surcharge_Amt > @Marginal_Relief_S
						THEN @Surcharge_Amt
					ELSE @Marginal_Relief_S
					END

		UPDATE #Tax_Report
		SET Amount_Col_Final = @Actual_Surcharge_S
		WHERE default_def_id = @Cont_Surcharge
			AND emp_id = @emp_id

		SET @TAXABLE_AMOUNT_with_Sur = @Return_Tax_Amount + @Actual_Surcharge_S
		SET @Return_Tax_Amount = @TAXABLE_AMOUNT_with_Sur

		-- Ended by rohit on 24072015						
		EXECUTE dbo.SP_IT_TAX_CALCULATION @Cmp_ID
			,@Emp_ID
			,@To_Date
			,@TAXABLE_AMOUNT
			,@TAXABLE_AMOUNT_with_Sur OUTPUT
			,@Actual_Surcharge_S OUTPUT
			,@ED_Cess OUTPUT
			,@ED_Cess_Per
			,@SurCharge_Per
			,@Relief_87A_Amount OUTPUT
			,@Return_Tax_Amount_Actual OUTPUT
			,@TAX_REGIME

		--UPDATE #Tax_Report 
		--	SET Amount_Col_Final = @Return_Tax_Amount 
		--	WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_Tax
		UPDATE #Tax_Report
		SET Amount_Col_Final = @ED_Cess
		WHERE Emp_ID = @Emp_ID
			AND Default_Def_ID = @Cont_ED_Cess
	END

	--End-------1-Cr.--Surcharge---------------------------------------------------Mitesh--
	SET @Return_Tax_Amount = @Return_Tax_Amount + @ED_Cess

	UPDATE #Tax_Report
	SET Amount_Col_Final = @Return_Tax_Amount
	WHERE Emp_ID = @Emp_ID
		AND (
			Default_Def_ID = @Cont_Net_Lia
			OR Default_Def_ID = @Cont_Tax
			)

	UPDATE #Tax_Report
	SET Amount_Col_Final = @Other_Paid_TDS_Amont
	WHERE Emp_ID = @Emp_ID
		AND (Default_Def_ID = @Cont_Less_TDS)

	UPDATE #Tax_Report
	SET Amount_Col_Final = (@Return_Tax_Amount) - @Other_Paid_TDS_Amont -- - @Relief_amount
	WHERE Emp_ID = @Emp_ID
		AND Default_Def_ID = @Cont_Total_tax_Lia

	SET @Return_Tax_Amount = (@Return_Tax_Amount) - @Other_Paid_TDS_Amont --- @Relief_amount

	-- Commented by Hardik 05/03/2019 As Tax Paid calculate from #Tax_Report table
	/*
			---Hasmukh 23062014 --Add To_Date instead of for_date----
			set @M_AD_Amount = 0
			select @M_AD_Amount = isnull(sum(M_AD_Amount),0)  from T0210_Monthly_AD_Detail mad inner join
					T0050_AD_MAster am on mad.AD_ID= am.AD_ID and (AD_DEF_ID = 1 or AD_DEF_ID = 13) -- reguler tds + extra TDS added by Hasmukh 17092014
			Where Emp_ID =@Emp_ID and mad.To_date >=@From_Date and mad.To_date <=@To_Date
			---Hasmukh 23062014 --Add To_Date instead of for_date----
		
			SELECT @M_AD_Amount = @M_AD_Amount + ISNULL(SUM(mad.TDS),0)  FROM T0210_ESIC_On_Not_Effect_on_Salary mad   -- TDS on Not Effect on Salary Componenet added by rohit on 21072015
			WHERE Emp_ID =@Emp_ID AND For_Date >=@From_Date AND For_Date <=@To_Date --AND For_Date  <=@Month_En_Date
			*/
	--- Added by Hardik 05/03/2019
	SELECT @M_AD_Amount = Sum(Amount_Col_Final)
	FROM #Tax_Report
	WHERE Emp_ID = @Emp_Id
		AND Isnull(Is_TaxPaid_Rec, 0) = 1

	-- Added by Hardik 05/06/2020 for Aculife as they deducted pending tax in Apr and May month under Allowance Name : "Income Tax Recovery"
	SELECT @M_AD_Amount = @M_AD_Amount + Isnull(Qry.M_AD_Amount, 0)
	FROM #Tax_Report t
	INNER JOIN (
		SELECT sum(M_AD_Amount) M_AD_Amount
			,T.Emp_Id
			,3 AS Month_1
			,Year(@To_date) AS Year_1
		FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK)
		INNER JOIN #Tax_Report T ON Mad.Emp_Id = T.Emp_ID
			AND T.IT_Month = 3
			AND T.IT_YEAR = Year(@To_date)
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON Mad.ad_id = Am.ad_id
			AND mad.Cmp_ID = am.CMP_ID
		WHERE (
				(
					Month(MAD.To_Date) = Month(DateAdd(MM, 1, @To_Date))
					AND Year(MAD.To_Date) = Year(@To_Date)
					)
				OR (
					Month(MAD.To_Date) = Month(DateAdd(MM, 2, @To_Date))
					AND Year(MAD.To_Date) = Year(@To_Date)
					)
				)
			AND AM.AD_Name = 'Income Tax Recovery'
			AND MAD.Emp_Id = @Emp_Id
		GROUP BY T.Emp_ID
		) Qry ON t.Emp_ID = qry.Emp_ID
		AND T.IT_Month = Month_1
		AND T.IT_YEAR = Year_1

	UPDATE #Tax_Report
	SET Amount_Col_Final = @M_AD_Amount
	WHERE Emp_ID = @Emp_ID
		AND (Default_Def_ID = @Cont_Paid_Tax)

	UPDATE #Tax_Report
	SET Amount_Col_Final = @Return_Tax_Amount - @M_AD_Amount
	WHERE Emp_ID = @Emp_ID
		AND (Default_Def_ID = @Cont_Due_Tax)

	FETCH NEXT
	FROM CUR_TAX
	INTO @EMP_ID
		,@TAXABLE_AMOUNT
		,@Increment_ID
		,@TAX_REGIME
END

CLOSE CUR_TAX

DEALLOCATE CUR_TAX

UPDATE #Tax_Report
SET Amount_Col_Final = SALARY_AMOUNT
FROM #Tax_Report Tr
INNER JOIN (
	SELECT MS.EMP_ID
		,SUM(MS.SALARY_AMOUNT) SALARY_AMOUNT
	FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID
	WHERE MS.Month_End_Date >= @FROM_DATE
		AND MS.Month_End_Date <= @TO_DATE
	GROUP BY MS.EMP_ID
	) Q ON TR.EMP_ID = Q.EMP_ID
WHERE DEFAULT_DEF_ID = @Cont_Annual_Sal

UPDATE #Tax_Report
SET Exempted_Amount = q.Amount_Col_Final
FROM #Tax_Report t
INNER JOIN (
	SELECT Amount_Col_Final
		,Exem_Againt_Row_ID
		,Emp_ID
	FROM #Tax_Report
	WHERE isnull(Exem_Againt_Row_ID, 0) > 0
		AND Amount_Col_Final > 0
	) q ON t.Row_Id = q.Exem_Againt_Row_ID
	AND t.Emp_Id = q.emp_ID

DECLARE @Tax_Manager_Form_16 NVARCHAR(100)
DECLARE @Father_Name_Form_16 NVARCHAR(100)
DECLARE @Designation_Manager_Form_16 NVARCHAR(100)
DECLARE @CIT_Address NVARCHAR(200)
DECLARE @CIT_City NVARCHAR(200)
DECLARE @CIT_Pin NUMERIC(18)
DECLARE @City_Cmp NVARCHAR(50)
DECLARE @DateForm16Submit DATETIME

SELECT @Cmp_Name = Cmp_NAme
	,@Cmp_Address = Cmp_Address
	,@Cmp_Pan_No = Cmp_Pan_No
	,@cmp_TAN_No = cmp_TAN_No
	,@City_Cmp = cmp_City
	,@Tax_Manager_Form_16 = Tax_Manager_Form_16
	,@Father_Name_Form_16 = Father_Name_Form_16
	,@Designation_Manager_Form_16 = Designation_Manager_Form_16
	,@CIT_Address = CIT_Address
	,@CIT_City = CIT_City
	,@CIT_Pin = CIT_Pin
	,@DateForm16Submit = Date_Form_16_Submit
FROM T0010_Company_Master WITH (NOLOCK)
WHERE cmp_ID = @Cmp_ID

CREATE TABLE #Amout_Cal (
	Emp_id NUMERIC(18, 0)
	,Taxable_Amount_paid NUMERIC(18, 2)
	,salary_other_than_perq NUMERIC(18, 2)
	,frt_qut_tax_ded NUMERIC(18, 2)
	,sec_qut_tax_ded NUMERIC(18, 2)
	,thrd_qut_tax_ded NUMERIC(18, 2)
	,frth_qut_tax_ded NUMERIC(18, 2)
	,frt_qut_tax_credited NUMERIC(18, 2) DEFAULT 0
	,--added jimit 04022016
	sec_qut_tax_credited NUMERIC(18, 2) DEFAULT 0
	,--added jimit 04022016
	thrd_qut_tax_credited NUMERIC(18, 2) DEFAULT 0
	,--added jimit 04022016
	frth_qut_tax_credited NUMERIC(18, 2) DEFAULT 0 --added jimit 04022016
	)

CREATE TABLE #perquisites_Details (
	Sr_NO NUMERIC
	,cmp_id NUMERIC
	,emp_id NUMERIC
	,fin_year NVARCHAR(50)
	,Nature_of_perq NVARCHAR(60)
	,value_of_perq NUMERIC(18, 2)
	,Amount_Recoverd NUMERIC(18, 2)
	,Final_Amount NUMERIC(18, 2)
	)

DECLARE @fin_Yr NVARCHAR(50)

SET @fin_Yr = cast(year(@from_date) AS NVARCHAR(5)) + '-' + cast(year(@to_date) AS NVARCHAR(5))

DECLARE @Gross_per NUMERIC(18, 2)
DECLARE @PAct_Exe_Cal NUMERIC(18, 2)
DECLARE @Taxable_Amount_paid NUMERIC(18, 2)
DECLARE @total_exm NUMERIC(18, 2)
DECLARE @tax_emp_id NUMERIC(18)
DECLARE @frt_qut_tax_ded NUMERIC(18, 2)
DECLARE @sec_qut_tax_ded NUMERIC(18, 2)
DECLARE @thrd_qut_tax_ded NUMERIC(18, 2)
DECLARE @frth_qut_tax_ded NUMERIC(18, 2)
DECLARE @frt_qut_tax_Credit NUMERIC(18, 2) --added jimit 04022016
DECLARE @sec_qut_tax_Credit NUMERIC(18, 2) --added jimit 04022016
DECLARE @thrd_qut_tax_Credit NUMERIC(18, 2) --added jimit 04022016
DECLARE @frth_qut_tax_Credit NUMERIC(18, 2) --added jimit 04022016

DECLARE CUR_TAX_Cal CURSOR
FOR
SELECT DISTINCT EMP_ID
FROM #Tax_Report

OPEN CUR_TAX_Cal

FETCH NEXT
FROM CUR_TAX_Cal
INTO @tax_emp_id

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Gross_per = 0
	SET @PAct_Exe_Cal = 0
	SET @Taxable_Amount_paid = 0
	SET @total_exm = 0
	SET @frt_qut_tax_ded = 0
	SET @sec_qut_tax_ded = 0
	SET @thrd_qut_tax_ded = 0
	SET @frth_qut_tax_ded = 0
	SET @frt_qut_tax_Credit = 0
	SET @sec_qut_tax_Credit = 0
	SET @thrd_qut_tax_Credit = 0
	SET @frth_qut_tax_Credit = 0

	SELECT @frt_qut_tax_ded = sum(isnull(TCD.TDS_Amount, 0) + isnull(TCD.Ed_Cess, 0))
	FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
	INNER JOIN T0230_TDS_Challan_Detail TCD WITH (NOLOCK) ON TCD.Challan_Id = TC.Challan_Id
	WHERE TC.Month IN (
			4
			,5
			,6
			)
		AND Year = year(@from_date)
		AND TCD.Emp_Id = @tax_emp_id
	GROUP BY emp_id

	SELECT @sec_qut_tax_ded = sum(isnull(TCD.TDS_Amount, 0) + isnull(TCD.Ed_Cess, 0))
	FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
	INNER JOIN T0230_TDS_Challan_Detail TCD WITH (NOLOCK) ON TCD.Challan_Id = TC.Challan_Id
	WHERE TC.Month IN (
			7
			,8
			,9
			)
		AND Year = year(@from_date)
		AND TCD.Emp_Id = @tax_emp_id
	GROUP BY emp_id

	SELECT @thrd_qut_tax_ded = sum(isnull(TCD.TDS_Amount, 0) + isnull(TCD.Ed_Cess, 0))
	FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
	INNER JOIN T0230_TDS_Challan_Detail TCD WITH (NOLOCK) ON TCD.Challan_Id = TC.Challan_Id
	WHERE TC.Month IN (
			10
			,11
			,12
			)
		AND Year = year(@from_date)
		AND TCD.Emp_Id = @tax_emp_id
	GROUP BY emp_id

	SELECT @frth_qut_tax_ded = sum(isnull(TCD.TDS_Amount, 0) + isnull(TCD.Ed_Cess, 0))
	FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
	INNER JOIN T0230_TDS_Challan_Detail TCD WITH (NOLOCK) ON TCD.Challan_Id = TC.Challan_Id
	WHERE TC.Month IN (
			1
			,2
			,3
			)
		AND Year = year(@To_Date)
		AND TCD.Emp_Id = @tax_emp_id
	GROUP BY emp_id

	--added jimit 04022016-----
	--SELECT @frt_qut_tax_Credit = sum(isnull(TC.Total_Amount,0))  FROM 
	--T0220_TDS_CHALLAN  TC inner join T0230_TDS_Challan_Detail TCD on TCD.Challan_Id = TC.Challan_Id  
	--where TC.Month IN (4,5,6) AND Year = year(@From_Date) AND TCD.Emp_Id = @tax_emp_id
	--GROUP BY Emp_Id
	--SELECT @sec_qut_tax_Credit = sum(isnull(TC.Total_Amount,0))  FROM 
	--T0220_TDS_CHALLAN  TC inner join T0230_TDS_Challan_Detail TCD on TCD.Challan_Id = TC.Challan_Id  
	--where TC.Month IN (7,8,9) AND Year = year(@From_Date) AND TCD.Emp_Id = @tax_emp_id
	--GROUP BY Emp_Id
	--SELECT @thrd_qut_tax_Credit = sum(isnull(TC.Total_Amount,0))  FROM 
	--T0220_TDS_CHALLAN  TC inner join T0230_TDS_Challan_Detail TCD on TCD.Challan_Id = TC.Challan_Id  
	--where TC.Month IN (10,11,12) AND Year = year(@From_Date) AND TCD.Emp_Id = @tax_emp_id
	--GROUP BY Emp_Id
	--SELECT @frth_qut_tax_Credit = sum(isnull(TC.Total_Amount,0))  FROM 
	--T0220_TDS_CHALLAN  TC inner join T0230_TDS_Challan_Detail TCD on TCD.Challan_Id = TC.Challan_Id  
	--where TC.Month IN (1,2,3) AND Year = year(@To_Date) AND TCD.Emp_Id = @tax_emp_id	 
	--GROUP BY Emp_Id
	----ended----------
	--Ankit 24052016
	SELECT @frt_qut_tax_Credit = SUM(ISNULL(Gross_Salary, 0)) - SUM(ISNULL(Settelement_Amount, 0))
	FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
	WHERE MONTH(month_end_date) IN (
			4
			,5
			,6
			)
		AND YEAR(month_end_date) = YEAR(@From_Date)
		AND Emp_ID = @tax_emp_id

	SELECT @sec_qut_tax_Credit = sum(isnull(Gross_Salary, 0)) - SUM(ISNULL(Settelement_Amount, 0))
	FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
	WHERE MONTH(month_end_date) IN (
			7
			,8
			,9
			)
		AND YEAR(month_end_date) = YEAR(@From_Date)
		AND Emp_Id = @tax_emp_id

	SELECT @thrd_qut_tax_Credit = SUM(ISNULL(Gross_Salary, 0)) - SUM(ISNULL(Settelement_Amount, 0))
	FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
	WHERE MONTH(month_end_date) IN (
			10
			,11
			,12
			)
		AND YEAR(month_end_date) = YEAR(@From_Date)
		AND Emp_Id = @tax_emp_id

	SELECT @frth_qut_tax_Credit = SUM(ISNULL(Gross_Salary, 0)) - SUM(ISNULL(Settelement_Amount, 0))
	FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
	WHERE MONTH(month_end_date) IN (
			1
			,2
			,3
			)
		AND YEAR(month_end_date) = year(@To_Date)
		AND Emp_Id = @tax_emp_id

	----Settlement Gross Amount
	SELECT @frt_qut_tax_Credit = ISNULL(@frt_qut_tax_Credit, 0) + ISNULL(SUM(S_Gross_Salary), 0)
	FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
	WHERE MONTH(S_month_end_date) IN (
			4
			,5
			,6
			)
		AND YEAR(S_month_end_date) = YEAR(@From_Date)
		AND Emp_ID = @tax_emp_id

	SELECT @sec_qut_tax_Credit = ISNULL(@sec_qut_tax_Credit, 0) + ISNULL(SUM(S_Gross_Salary), 0)
	FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
	WHERE MONTH(S_month_end_date) IN (
			7
			,8
			,9
			)
		AND YEAR(S_month_end_date) = YEAR(@From_Date)
		AND Emp_Id = @tax_emp_id

	SELECT @thrd_qut_tax_Credit = ISNULL(@thrd_qut_tax_Credit, 0) + ISNULL(SUM(S_Gross_Salary), 0)
	FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
	WHERE MONTH(S_month_end_date) IN (
			10
			,11
			,12
			)
		AND YEAR(S_month_end_date) = YEAR(@From_Date)
		AND Emp_Id = @tax_emp_id

	SELECT @frth_qut_tax_Credit = ISNULL(@frth_qut_tax_Credit, 0) + ISNULL(SUM(S_Gross_Salary), 0)
	FROM T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
	WHERE MONTH(S_month_end_date) IN (
			1
			,2
			,3
			)
		AND YEAR(S_month_end_date) = YEAR(@To_Date)
		AND Emp_Id = @tax_emp_id

	-----Payment Process
	SELECT @frt_qut_tax_Credit = @frt_qut_tax_Credit + IsNull(SUM(CASE 
					WHEN MONTH(FOR_DATE) IN (
							4
							,5
							,6
							)
						THEN NET_AMOUNT
					ELSE 0
					END), 0)
		,--QTR - 1
		@sec_qut_tax_Credit = @sec_qut_tax_Credit + IsNull(SUM(CASE 
					WHEN MONTH(FOR_DATE) IN (
							7
							,8
							,9
							)
						THEN NET_AMOUNT
					ELSE 0
					END), 0)
		,--QTR - 2
		@thrd_qut_tax_Credit = @thrd_qut_tax_Credit + IsNull(SUM(CASE 
					WHEN MONTH(FOR_DATE) IN (
							10
							,11
							,12
							)
						THEN NET_AMOUNT
					ELSE 0
					END), 0)
		,--QTR - 3
		@frth_qut_tax_Credit = @frth_qut_tax_Credit + IsNull(SUM(CASE 
					WHEN MONTH(FOR_DATE) IN (
							1
							,2
							,3
							)
						THEN NET_AMOUNT
					ELSE 0
					END), 0) --QTR - 4		
	FROM MONTHLY_EMP_BANK_PAYMENT P WITH (NOLOCK)
	INNER JOIN T0301_Process_Type_Master PT WITH (NOLOCK) ON P.Process_Type_ID = PT.Process_Type_ID
	CROSS APPLY (
		SELECT AD.AD_ID
			,AD.AD_NAME
		FROM T0050_AD_MASTER AD WITH (NOLOCK)
		WHERE AD.AD_NOT_EFFECT_SALARY = 1
			AND EXISTS (
				SELECT 1
				FROM dbo.split(PT.AD_ID_MULTI, '#') T
				WHERE CAST(T.DATA AS NUMERIC) = AD.AD_ID
				)
			AND AD.CMP_ID = @CMP_ID
		) AD
	WHERE FOR_DATE BETWEEN @FROM_DATE
			AND @TO_DATE
		AND Emp_Id = @tax_emp_id

	--Ankit 24052016 
	SELECT @total_exm = isnull(amount_col_final, 0)
	FROM #Tax_Report
	WHERE Row_ID = 118
		AND emp_id = @tax_emp_id

	SELECT @Gross_per = isnull(amount_col_final, 0)
	FROM #Tax_Report
	WHERE Row_ID = 104
		AND emp_id = @tax_emp_id

	SELECT @PAct_Exe_Cal = SUM(Amount_Col_Final)
	FROM #Tax_Report
	WHERE Default_Def_Id IN (
			8
			,9
			,11
			,151
			,152
			,163
			,160
			,164
			)
		AND Emp_ID = @tax_emp_id

	SELECT @Taxable_Amount_paid = isnull(amount_col_final, 0)
	FROM #Tax_Report
	WHERE Default_Def_Id = @Cont_Paid_Tax
		AND Emp_ID = @tax_emp_id

	INSERT INTO #Amout_Cal
	SELECT @tax_emp_id
		,@Taxable_Amount_paid
		,(@Gross_per - @total_exm)
		,@frt_qut_tax_ded
		,@sec_qut_tax_ded
		,@thrd_qut_tax_ded
		,@frth_qut_tax_ded
		,@frt_qut_tax_Credit
		,@sec_qut_tax_Credit
		,@thrd_qut_tax_Credit
		,@frth_qut_tax_Credit

	EXEC GET_EMP_PERQUISITES_12BA @Cmp_ID
		,@tax_emp_id
		,@fin_Yr
		,@Gross_per
		,@PAct_Exe_Cal
		,0
		,'R'
		,''

	FETCH NEXT
	FROM CUR_TAX_Cal
	INTO @tax_emp_id
END

CLOSE CUR_TAX_Cal

DEALLOCATE CUR_TAX_Cal

UPDATE #Tax_Report
SET Amount_col_1 = Amount_Col_Final
WHERE isnull(Col_No, 0) IN (
		0
		,1
		)

UPDATE #Tax_Report
SET Amount_col_2 = Amount_Col_Final
WHERE isnull(Col_No, 0) = 2

UPDATE #Tax_Report
SET Amount_col_3 = Amount_Col_Final
WHERE isnull(Col_No, 0) = 3

UPDATE #Tax_Report
SET Amount_col_4 = Amount_Col_Final
WHERE isnull(Col_No, 0) = 4

--select * from #Amout_Cal
-- Changed By Ali 22112013 EmpName_Alias
SELECT DISTINCT tr.Row_ID
	,space(Concate_Space) + FIELD_NAME AS FIELD_NAME
	,Amount_Col_Final
	,Amount_Col_1
	,Amount_Col_2
	,Amount_Col_3
	,Amount_Col_4
	,Default_def_ID
	,AD_ID
	,tr.Rimb_ID
	,IT_ID
	,tr.Emp_ID
	,em.Alpha_Emp_Code AS Emp_code
	,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
	,@From_Date P_From_Date
	,@To_Date P_To_Date
	,Is_Show
	,Concate_Space
	,em.Street_1
	,em.City
	,em.Zip_Code
	,em.Pan_no
	,Exempted_Amount
	,@Cmp_Name Cmp_Name
	,@Cmp_Address Cmp_Address
	,@Cmp_Pan_No Cmp_Pan_No
	,@cmp_TAN_No cmp_TAN_No
	,Desig_Name
	,iq.Branch_ID
	,IAN.First_Qaurter_No
	,IAN.Second_Qaurter_No
	,IAN.Third_Qaurter_No
	,IAN.Fourth_Qaurter_No
	,@Tax_Manager_Form_16 AS Tax_Manager_Form_16
	,@Father_Name_Form_16 AS Father_Name_Form_16
	,@Designation_Manager_Form_16 AS Designation_Manager_Form_16
	,@fin_Yr AS fin_year
	,AC.Taxable_Amount_paid AS payble_amount
	,dbo.F_Number_TO_Word(AC.Taxable_Amount_paid) AS payble_amount_word
	,@CIT_Address AS CIT_Address
	,@CIT_City AS CIT_City
	,@CIT_Pin AS CIT_Pin
	,AC.salary_other_than_perq AS salary_other_than_perq
	,@City_Cmp AS City_cmp
	,AC.frt_qut_tax_ded
	,AC.sec_qut_tax_ded
	,AC.thrd_qut_tax_ded
	,AC.frth_qut_tax_ded
	,@DateForm16Submit AS Date_Form_16_Submit
	,AC.frt_qut_tax_credited
	,AC.sec_qut_tax_credited
	,AC.thrd_qut_tax_credited
	,AC.frth_qut_tax_credited --added jimit 04022016
	,Em.Street_1 --added jimit 15022016
	,Tr.Tax_Regime -- Added by Hardik 22/04/2020
	,em.Tehsil
	,em.District
	,em.STATE --added by mansi 03-08-23
FROM #Tax_Report tr
LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID
LEFT OUTER JOIN #Amout_Cal AC ON AC.emp_id = EM.Emp_id
LEFT OUTER JOIN (
	SELECT I.Emp_Id
		,Desig_ID
		,Branch_ID
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT max(Increment_ID) AS Increment_ID
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @Cmp_ID
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_ID = Qry.Increment_ID
	) Iq ON em.emp_ID = iq.Emp_ID
LEFT OUTER JOIN T0040_Designation_MAster dgm WITH (NOLOCK) ON iq.Desig_ID = dgm.Desig_ID
LEFT OUTER JOIN T0250_IT_Acknowledge_No IAN WITH (NOLOCK) ON IAN.Financial_Year = (cast(year(@from_date) AS VARCHAR(4)) + '-' + cast(year(@to_date) AS VARCHAR(4)))
	AND ian.Cmp_Id = tr.Cmp_ID
WHERE Is_Show = 1
	AND 1 = (
		CASE 
			WHEN (
					Isnull(Tr.AD_ID, 0) > 0
					OR Isnull(Tr.Rimb_ID, 0) > 0
					)
				AND Tr.Amount_Col_Final = 0
				AND TR.Row_ID < 100
				THEN 0
			ELSE 1
			END
		)
ORDER BY tr.Emp_ID
	,tr.Row_ID

-- chalan ANNEXURE-B
SELECT DISTINCT Row_ID
	,FIELD_NAME
	,Amount_Col_Final
	,Tr.Emp_ID
	,Cheque_No
	,Bank_BSR_Code
	,Payment_Date
	,CIN_No
	,INC.Branch_ID
FROM #Tax_Report tr
INNER JOIN #Emp_Cons EC ON Tr.emp_Id = EC.emp_id
LEFT OUTER JOIN (
	SELECT Emp_Id
		,DateName(month, DateAdd(month, [Month], 0) - 1) MonthName
		,Cheque_No
		,Bank_BSR_Code
		,Payment_Date
		,CIN_No
		,Month
		,Year
	FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
	INNER JOIN T0230_TDS_Challan_Detail TDD WITH (NOLOCK) ON TC.Challan_Id = TDD.Challan_Id
	) Qry ON TR.Emp_Id = Qry.Emp_Id
	AND TR.Field_name = Qry.MonthName
INNER JOIN (
	SELECT I.Emp_Id
		,I.Branch_ID
	FROM T0095_Increment I WITH (NOLOCK)
	INNER JOIN (
		SELECT max(Increment_ID) AS Increment_ID
			,Emp_ID
		FROM T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment
		WHERE Increment_Effective_date <= @To_Date
			AND Cmp_ID = @cmp_id
		GROUP BY emp_ID
		) Qry ON I.Emp_ID = Qry.Emp_ID
		AND I.Increment_ID = Qry.Increment_ID
	) AS INC ON inc.emp_id = tr.emp_id
WHERE Is_TaxPaid_Rec = 1
	AND cast((cast(Qry.Month AS NVARCHAR(5)) + '-01-' + cast(Qry.Year AS NVARCHAR(5))) AS DATETIME) >= @From_Date
	AND cast((cast(Qry.Month AS NVARCHAR(5)) + '-01-' + cast(Qry.Year AS NVARCHAR(5))) AS DATETIME) <= @To_Date -- addded by mitesh on 24122013
ORDER BY tr.Emp_ID
	,tr.Row_ID

-- 12ba
SELECT *
FROM #perquisites_Details

--   select  Row_ID 	,FIELD_NAME,Amount_Col_Final,tr.Emp_ID,M_Edu_Cess_Amount,M_Surcharge_Amount,iq.Branch_ID
--From #Tax_Report tr  Left outer join 
--(select I.Emp_Id,Desig_ID,Branch_ID from T0095_Increment I inner join 
--				( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
--				where Increment_Effective_date <= @To_Date
--				and Cmp_ID = @Cmp_ID
--				group by emp_ID  ) Qry on
--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date)Iq on tr.Emp_ID =iq.Emp_ID 
--Where Is_TaxPaid_Rec =1 
--order by tr.Emp_ID ,tr.Row_ID
--	select  Row_ID 	,FIELD_NAME,Amount_Col_Final,Exempted_Amount,Emp_ID
--	From #Tax_Report tr 
--	Where Is_Salary_comp =1 
--	order by tr.Emp_ID ,tr.Row_ID
--	Select d.Cmp_ID,d.Emp_ID,p.IT_Bank_BSR_Code,IT_Acknowledgement_No,d.E_IT_Amount,d.E_IT_Surcharge,d.E_IT_ED_Cess from T0251_IT_PAID_Detail d  Inner join #Emp_Cons ec on d.emp_ID =ec.emp_ID 
--inner join T0250_IT_PAid p on d.IT_Paid_ID =p.IT_Paid_ID
--Where For_Date >=@From_Date and For_Date <=@To_Date  
--exec IT_TaxPaid_Form16 @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,@Product_ID
RETURN
