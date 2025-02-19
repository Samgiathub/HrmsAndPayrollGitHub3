
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_PREPARATION_ALL]
	 @Cmp_ID				NUMERIC
	,@From_Date				DATETIME
	,@To_Date				DATETIME	
	,@Branch_ID				VARCHAR(max) = '' 
	,@Cat_ID				VARCHAR(max) = '' 
	,@Grd_ID				VARCHAR(max) = '' 
	,@Type_ID				VARCHAR(max) = '' 
	,@Dept_ID				VARCHAR(max) = '' 
	,@Desig_Id				VARCHAR(max) = ''  
	,@Emp_ID				NUMERIC
	,@Constraint			VARCHAR(max)
	,@Product_ID			NUMERIC 
	,@Taxable_Amount_Cond	NUMERIC = 0  
	,@Format_Name			VARCHAR(50) ='Format1'
	,@Form_ID				NUMERIC =0
	,@Sp_Call_For			VARCHAR(30) =''
	,@Month_En_Date			DATETIME =NULL 
	,@Month_St_Date			DATETIME = NULL
	,@Salary_Cycle_id		NUMERIC  = 0
	,@Segment_ID			VARCHAR(max) = ''
	,@Vertical				VARCHAR(max) = ''
	,@SubVertical			VARCHAR(max) = ''
	,@subBranch				VARCHAR(max) = ''
	,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 16-05-2017
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @Show_Hidden_Allowance = 0

	DECLARE @Cont_Basic_Sal					TINYINT
	DECLARE @Cont_Gratuity_Sal				TINYINT		--Ankit 09122015
	DECLARE @Cont_PT_Amount					TINYINT 
	DECLARE @Cont_Total_Tax					TINYINT 
	DECLARE @Cont_Surcharge					TINYINT 
	DECLARE @Cont_Total_tax_Lia				TINYINT 
	DECLARE @Cont_ED_Cess					TINYINT 
	DECLARE @Cont_Net_Lia					TINYINT 
	DECLARE @Cont_Tax						TINYINT 
	DECLARE @Cont_Paid_Tax					TINYINT		
	DECLARE @Cont_Due_Tax					TINYINT 
	DECLARE @Cont_Annual_Sal				TINYINT 
	DECLARE @Cont_HRA						TINYINT
	DECLARE @Cont_Arrear					TINYINT
	DECLARE @Cont_Less_TDS					TINYINT 
	DECLARE @Cont_Perquisit_Amt				TINYINT
	DECLARE @Cont_Leave_salary				TINYINT
	DECLARE @Relief_sec_87					NUMERIC(18,2)
	DECLARE @Relief_sec_87_limit			NUMERIC(18,2)
	DECLARE @Cont_Notice_Pay				TINYINT
	DECLARE @Cont_OT_Amount					NUMERIC(18,2)
	DECLARE @Cont_Production_Bonus			TINYINT
	DECLARE @Cont_Production_Variable		TINYINT
	DECLARE @Cont_Standard_Deduction		TINYINT
	DECLARE @Cont_Net_Round_Amount			TINYINT	
	DECLARE @Cont_Travel_Settlement_Amount	TINYINT	

	SET @Cont_Basic_Sal		=1
	SET	@Cont_OT_Amount		=4
	SET @Cont_Gratuity_Sal  =5
	SET @Cont_PT_Amount		=10
	SET @Cont_Total_Tax		=101
	SET @Cont_Surcharge		=102
	SET @Cont_Total_tax_Lia	=103
	SET @Cont_ED_Cess		=104
	SET @Cont_Net_Lia		=105
	SET @Cont_Tax			=106
	SET @Cont_Paid_Tax		=107
	SET @Cont_Due_Tax		=108
	SET @Cont_Annual_Sal	=109
	SET @Cont_HRA			=110	
	SET @Cont_Arrear		=12
	SET @Cont_Less_TDS      =120
	SET @Cont_Perquisit_Amt =201
	SET @Cont_Leave_salary  =6
	SET @Cont_Notice_Pay	=51
	SET @Cont_Production_Bonus = 167
	SET @Cont_Production_Variable = 168
	SET @Cont_Standard_Deduction = 169
	SET @Cont_Net_Round_Amount = 170
	SET @Cont_Travel_Settlement_Amount = 171

	SET @Relief_sec_87			= 2000
	SET @Relief_sec_87_limit	= 500000

	
	IF ISNULL(@Month_En_Date,'') = ''
		BEGIN
			SET @Month_En_Date = @To_Date
		END 
	IF ISNULL(@Month_St_Date,'') =''
		BEGIN
			SET @Month_St_Date = @From_Date
		END
	
   --Ankit 17072014--
 
    DECLARE @fin_year AS NVARCHAR(20)  
	SET @fin_year = ''
	SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)  
	
	IF NOT EXISTS (SELECT 1 from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Financial_Year = @fin_year )
		BEGIN
			DECLARE @Error_Msg AS VARCHAR(100)
			SET @Error_Msg = '@@IT Form Design of Financial Year ' + @fin_year + + ' does not Exists.@@'
			RAISERROR(@Error_Msg , 16 , 1)
			RETURN
		END	
	
	CREATE table #Emp_Cons 
	(      
        Emp_ID numeric ,     
        Branch_ID numeric,
		Increment_ID numeric    
	)      
 
    EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical,@SubVertical,@SubBranch,0,0,0,'0',0,0
 	
 	CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
 	
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects WHERE name LIKE '#Tax_Report' )		
		BEGIN
			DROP TABLE #Tax_Report
		END
			
	IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#Tax_Report_Male')
	    BEGIN
	        DROP TABLE #Tax_Report_Male
	    END	
	    
	 IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#Salary_AD')
	    BEGIN
	        DROP TABLE #Salary_AD
	    END		

	CREATE TABLE #Tax_Report 
	( 
		T_ID						NUMERIC IDENTITY(1,1),
		Emp_ID						NUMERIC,
		Cmp_ID						NUMERIC(18, 0) NOT NULL ,
		Format_Name					VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS ,
		Row_ID						INT NOT NULL ,
		Field_Name					VARCHAR (100) COLLATE SQL_Latin1_General_CP1_CI_AS ,
		AD_ID						NUMERIC(18, 0) NULL ,
		Rimb_ID						NUMERIC(18, 0) NULL ,
		Default_Def_Id				INT NOT NULL ,
		Is_Total					TINYINT NOT NULL ,
		From_Row_ID					INT NOT NULL ,
		To_Row_ID					INT NOT NULL ,
		Multiple_Row_ID				VARCHAR (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		Is_Exempted					TINYINT NOT NULL ,
		Max_Limit					NUMERIC(18, 0)	NOT NULL ,
		Max_Limit_Compare_Row_ID	INT NOT NULL ,
		Max_Limit_Compare_Type		VARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		Is_Proof_Req				TINYINT NOT NULL ,
		IT_ID						NUMERIC NULL,
		From_Date					DATETIME ,
		To_Date						DATETIME ,
		Amount_Col_1				NUMERIC DEFAULT 0,
		Amount_Col_2				NUMERIC DEFAULT 0,
		Amount_Col_3				NUMERIC DEFAULT 0,
		Amount_Col_4				NUMERIC DEFAULT 0,
		Amount_Col_Final			NUMERIC DEFAULT 0,
		Sal_No_Of_Month				INT DEFAULT 0,
		Field_Type					TINYINT DEFAULT 0,
		IT_Month					INT ,
		IT_YEAR						INT ,
		Increment_ID				NUMERIC,
		IT_L_ID						NUMERIC,
		Is_Show						TINYINT DEFAULT 0,
		Col_No						INT ,
		Concate_Space				TINYINT DEFAULT 0,
		Is_Salary_comp				TINYINT DEFAULT 0,
		Exem_Againt_row_Id			INT DEFAULT 0,
		Exempted_Amount				NUMERIC DEFAULT 0,
		Is_TaxPaid_Rec				TINYINT DEFAULT 0,
		Y_IT_Paid_Amount			NUMERIC DEFAULT 0,
		Y_Edu_Cess_Amount			NUMERIC DEFAULT 0,
		Y_Surcharge_Amount			NUMERIC DEFAULT 0,
		M_IT_Amount					NUMERIC DEFAULT 0,
		M_Edu_Cess_Amount			NUMERIC DEFAULT 0,
		M_Surcharge_Amount			NUMERIC DEFAULT 0,
		Month_Count					NUMERIC DEFAULT 0,
		Total_TAxable_Amount		NUMERIC DEFAULT 0,
		Final_Tax					NUMERIC DEFAULT 0,
		Total_Amount				NUMERIC DEFAULT 0,
		Incentive_Tax               NUMERIC(18, 0),
		Incentive_Tax_Amount        NUMERIC(18, 0),
		Is_Incentive                TINYINT,
		Show_In_SalarySlip			TINYINT DEFAULT 0,			--Added by Hardik 19/03/2014
		Display_Name_For_SalarySlip VARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT '',	--Added by Hardik 19/03/2014
		Column_24Q					TINYINT DEFAULT 0,			--Added by Hardik 19/08/2014
		Amount_Col_Actual			NUMERIC DEFAULT 0,			--Added By rohit For Actual Value on 04052015
		Amount_Col_Assumed			NUMERIC DEFAULT 0,			--Added by rohit For Assumed Value on 04052015
	)
	  
	CREATE UNIQUE CLUSTERED	INDEX CLIX_Tax_Report ON #Tax_Report(Emp_ID, Row_ID)
	
		
	CREATE TABLE #Tax_Report_Male
	(
		Auto_Row_Id		INT IDENTITY(1,1) ,
		Field_Name		VARCHAR(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Default_Def_Id	NUMERIC,
		T_F_Row_ID		INT ,
		T_T_Row_ID		INT ,
		IT_Month		INT,
		IT_YEAR			INT,
		IT_L_ID			NUMERIC,
		Is_Show			TINYINT DEFAULT 1,
		Is_TaxPaid_Rec	TINYINT DEFAULT 0	,
		Show_In_SalarySlip Tinyint Default 0, --Hardik 20/03/2014
		Display_Name_For_SalarySlip varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS default '', --Added by Hardik 19/03/2014
		Column_24Q		tinyint default 0, -- Added by Hardik 19/08/2014
		Gender			varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS default '' --Ankit 02052016
	)
	 
	CREATE CLUSTERED INDEX ind_Male_temp1 ON #Tax_Report_Male(Auto_Row_Id)
	CREATE NONCLUSTERED INDEX ind_Male_temp2 ON #Tax_Report_Male(Default_Def_Id)
	  

	CREATE TABLE #Salary_AD
	(
		Cmp_ID					NUMERIC,
		Emp_ID					NUMERIC,
		AD_ID					NUMERIC ,
		M_AD_Amount				NUMERIC ,
		Month_Count				INT,
		Old_M_AD_Amount			NUMERIC,
		AD_NOT_EFFECT_ON_PT		TINYINT	DEFAULT 0,
		AD_NOT_EFFECT_ON_SAL	TINYINT DEFAULT 0,
		Ad_Effect_On_TDS        TINYINT DEFAULT 0,
		Month_Diff_Amount		NUMERIC,
		For_Date				DATETIME,
		Default_Def_ID			TINYINT DEFAULT 0,
	)
	
	 
	DECLARE @Max_Row_ID			NUMERIC
	DECLARE @Max_From_Row_ID	NUMERIC
	DECLARE @T_For_Date			DATETIME
	DECLARE @Increment_ID		NUMERIC
	DECLARE @Month_Count		NUMERIC
	DECLARE @Month_Sal			NUMERIC
	DECLARE @Month_Diff			NUMERIC
	DECLARE @ED_Cess_Per		NUMERIC(5,2)
	DECLARE @SurCharge_per		NUMERIC(5,2)
	DECLARE @Month_Max_Date		DATETIME
	DECLARE @Join_date			DATETIME
	DECLARE @Relief_87A_Amount	Numeric(18,2)

	
	SET @SurCharge_per		= 0 --10 % Surchage not applicable from 2009-10 (A.Y. 2010-11) and w.e.f. 01.04.2009 comment by Hasmukh 10042012
	SET @Relief_87A_Amount	= 0	
	SET @ED_Cess_Per = 0
	
	SELECT @ED_Cess_Per = Field_Value 
	FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
	WHERE Default_Def_Id = @Cont_ED_Cess and Financial_Year = @fin_year and Cmp_ID= @Cmp_ID 

	If @ED_Cess_Per = 0
		BEGIN
			If YEAR(@From_Date) < 2018
				SET @ED_Cess_Per = 3
		END

	
	
	SET @Month_Count = DATEDIFF(m,@From_Date,@To_Date) +1	
	
	INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,Field_Type,Is_Show,Col_No,Concate_Space
								,Is_Salary_comp,Exem_Againt_row_Id,Exempted_Amount,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)	

	SELECT	ec.Emp_ID,I.Cmp_ID,Format_Name,Row_ID,Field_Name,I.AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,@From_Date,@To_Date ,Field_Type,Is_Show,Col_No,ISNULL(Concate_Space,0) 
								,ISNULL(Is_Salary_comp,0),ISNULL(Exem_Againt_row_Id,0),0,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q
	FROM	T0100_IT_FORM_DESIGN I  WITH (NOLOCK)
			LEFT OUTER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = I.AD_ID --Added by Jaina 16-05-2017	
			CROSS APPLY #Emp_Cons ec 
	WHERE	I.Cmp_Id=@Cmp_ID 
			And Default_Def_Id not in (101,-102,-103,103,104,105,106,107,108,120,121,102) and row_id <1000		 --Hardik		
			AND Financial_Year = @fin_year  --Ankit 17072014
			AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND AD.Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 16-05-2017	
	

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_show)
	SELECT ' ',0,1	
		 
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_show)
	SELECT 'Tax Limit ',0,1
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT ' ',0,1


	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show,Gender)
	SELECT '---------------------Male-------------------',0,1,'M'
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,IS_Show,Gender)	
	SELECT CAST(From_Limit AS VARCHAR(15)) + ' To ' +  CAST(TO_Limit AS VARCHAR(15)) + ' ( ' +  CAST(Percentage AS VARCHAR(10))+ ' %) ' ,0,IT_L_ID ,1,'M'
	FROM T0040_tAx_limit t WITH (NOLOCK) INNER JOIN
	( SELECT cmp_ID , MAX(for_Date) For_Date FROM T0040_tAx_limit WITH (NOLOCK)
		WHERE cmp_ID= @Cmp_ID AND For_Date <=@To_Date AND gender ='M' GROUP BY cmp_ID)q ON t.cmp_ID =q.cmp_ID AND T.for_Date =q.for_Date AND gender ='M'

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show,Gender)
	SELECT '-------------------Female-------------------',0,1,'F'
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,Is_show,Gender)
	SELECT CAST(From_Limit AS VARCHAR(15)) + ' To ' +  CAST(TO_Limit AS VARCHAR(15)) + ' ( ' +  CAST(Percentage AS VARCHAR(10))+ ' %) ' ,0,IT_L_ID ,1,'F'
	FROM T0040_tAx_limit t WITH (NOLOCK) INNER JOIN
	( SELECT cmp_ID , MAX(for_Date) For_Date FROM T0040_tAx_limit WITH (NOLOCK)
		WHERE cmp_ID= @Cmp_ID AND For_Date <=@To_Date AND gender ='F' GROUP BY cmp_ID)q ON t.cmp_ID =q.cmp_ID AND T.for_Date =q.for_Date AND gender ='F'

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show,Gender)
	select '-----------------Senior Citizen------------',0,0,'S'
		
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,Is_show,Gender)	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(15)) + ' ( ' +  cast(Percentage as varchar(10))+ ' %) ' ,0,IT_L_ID ,0,'S'
	From T0040_tAx_limit t WITH (NOLOCK) inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and Gender ='S' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='S'
	
  
	--Added By Jimit 23052018 for case at WCL One Employee's Age is 
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show,Gender)
	select '-----------------Very Senior Citizen------------',0,0,'V'
		
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,Is_show,Gender)	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(15)) + ' ( ' +  cast(Percentage as varchar(10))+ ' %) ' ,0,IT_L_ID ,0,'V'
	From T0040_tAx_limit t WITH (NOLOCK) inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and Gender ='V' 
		group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='V'
  
	--Ended--
  
	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '12. Tax on Total Income ',101

	--Added by Hardik 20/03/2014
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (101) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

	IF YEAR(@To_Date) >= 2014
		Begin
			--Commented by Hardik 20/03/2014
			--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
			--SELECT '   * Less: Sec. 87A ',-102
	
			INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
			SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (-102) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

			--Commented by Hardik 20/03/2014
--			INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
--			SELECT '#   Tax on Total Income ',-103

			INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
			SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (-103) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014
			
		END
		
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (102) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014


--	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--	select 'Surcharge @10% on Tax ',102

--	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
--	select 'Total Tax Liabilities',103


	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '13. Ed. Cess 3%(On Tax Computed At Sr.No.12)',104

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (104) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014
	
	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '14. Tax Payable(12 + 13)',105

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (105) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '15.(a) Less:Relief Under section 89 (attach details)',121,@Max_From_Row_ID,@Max_Row_ID-1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (121) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

	
	--Commented by Hardik 20/03/2014
--	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
--	SELECT '     (b) Less TDS deducted from other income reported by employee',120,@Max_From_Row_ID,@Max_Row_ID-1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (120) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '     (c) Less:Relief Under section 87 A',121,@Max_From_Row_ID,@Max_Row_ID-1
	
	--Commented by Hardik 20/03/2014
--	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
--	SELECT '16. Tax Payable(14 - 15)',103,@Max_From_Row_ID,@Max_Row_ID-1


	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (103) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014
	
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,is_show)
	SELECT 'Income Tax Paid Detail',106,1

	--SELECT @Max_Row_ID = ISNULL(MAX(AUTO_Row_ID),0) + 1  FROM  #Tax_Report_Male
	
	--SET @Max_From_Row_ID = @Max_Row_ID
	SET @T_For_Date = @From_Date
	WHILE @T_For_Date <=@To_Date 
		BEGIN
			--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR,Is_Show,Is_TaxPaid_Rec	)
			--SELECT DATENAME(m,@T_For_Date),0,MONTH(@T_For_Date),YEAR(@T_For_Date),1,1
				
			IF @Sp_Call_For='Salary Slip'	--Ankit 17022016
				BEGIN
					INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR,Is_Show,Is_TaxPaid_Rec	,Show_In_SalarySlip)
					SELECT DATENAME(m,@T_For_Date),0,MONTH(@T_For_Date),YEAR(@T_For_Date),1,1 ,1
				END		
			ELSE
				BEGIN
					INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR,Is_Show,Is_TaxPaid_Rec	)
					SELECT DATENAME(m,@T_For_Date),0,MONTH(@T_For_Date),YEAR(@T_For_Date),1,1
				END	
					
			SET @T_For_Date = DATEADD(m,1,@T_For_Date)
			SET @Max_Row_ID = @Max_Row_ID + 1
		END
	
	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '17. Less: TDS Paid',107,@Max_From_Row_ID,@Max_Row_ID-1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (107) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

	--Commented by Hardik 20/03/2014
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '18. TAX PAYABLE/REFUNDABLE (16 - 17)',108

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT Space(Concate_Space) + Field_Name,Default_Def_Id,Show_In_SalarySlip,Space(Concate_Space) + Display_Name_For_SalarySlip,Column_24Q from T0100_IT_FORM_DESIGN WITH (NOLOCK) where Default_Def_Id in (108) AND Cmp_Id=@Cmp_ID AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT ' ',0,1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT 'HOUSE RENT ALLOWANCE EXEMPT',0,1
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT 'Annual Salary ( Exclusive benefits and Perquisites)',109,1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT 'House Rent Allowance Received',110,1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT 'Less : Exemption u/s 10 (13A) read with rule 2 A',0,1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT '  A ) House rent allowance Received',110,1
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT '  B ) Actual Rent Paid',112,1
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT '   Less : 1/10 of Salary',113,1
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT '   Different Amount',114,1
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT '  C ) I. Two Fifth of Salary (Non Metro)',115,1
	
	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT '       II. One Half of Salary (Metro)',116,1

	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	SELECT 'House rent Allow. Exempted ( least of a,b or c )',7,1

	
	SELECT @Max_Row_ID = ISNULL(MAX(Row_ID),0) + 1  FROM  dbo.#Tax_Report
	
	---- Ankit 27062016
	INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
				,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,IT_Month,IT_YEAR,IT_L_ID,Is_Show,Is_TaxPaid_Rec,
				Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	SELECT EC.Emp_ID,@Cmp_ID,@Format_Name,Auto_Row_Id + @Max_Row_ID ,Field_Name,NULL,NULL,Default_Def_Id,0,ISNULL(T_F_Row_ID + @Max_Row_ID,0) ,ISNULL(T_T_Row_ID + @Max_Row_ID,0),'',0,0
				,0,0,0,NULL,@From_Date,@To_Date,IT_Month,IT_Year,IT_L_ID,Is_Show ,Is_TaxPaid_Rec,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q
	FROM #Emp_Cons EC INNER JOIN
		(SELECT CASE WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'N','Y') AS NUMERIC(18,2)) > 80 THEN 'V' 
		             WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'N','Y') AS NUMERIC(18,2)) > 60 THEN 'S' 
				ELSE Gender END AS Gender, Emp_ID FROM  T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID) EM ON EC.Emp_ID = Em.Emp_ID 
		CROSS JOIN #Tax_Report_Male TR 
	WHERE 
		EM.Gender  = (CASE WHEN tr.Gender = '' COLLATE SQL_Latin1_General_CP1_CI_AS THEN em.Gender ELSE tr.Gender COLLATE SQL_Latin1_General_CP1_CI_AS END) 
	ORDER BY EC.Emp_ID
	
	----Below Code Comment by Ankit 27062016
	--INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
	--							,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,IT_Month,IT_YEAR,IT_L_ID,Is_Show,Is_TaxPaid_Rec,
	--							Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
	--SELECT Emp_ID,@Cmp_ID,@Format_Name,Auto_Row_Id + @Max_Row_ID ,Field_Name,NULL,NULL,Default_Def_Id,0,ISNULL(T_F_Row_ID + @Max_Row_ID,0) ,ISNULL(T_T_Row_ID + @Max_Row_ID,0),'',0,0
	--							,0,0,0,NULL,@From_Date,@To_Date,IT_Month,IT_Year,IT_L_ID,Is_Show ,Is_TaxPaid_Rec,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q
	-- FROM #Tax_Report_Male CROSS JOIN #Emp_Cons
	----------	

	INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,Field_Type,Is_Show,Col_No,Concate_Space
								,Is_Salary_comp,Exem_Againt_row_Id,Exempted_Amount,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)	

	SELECT Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,@From_Date,@To_Date ,Field_Type,Is_Show,Col_No,ISNULL(Concate_Space,0) 
								,ISNULL(Is_Salary_comp,0),ISNULL(Exem_Againt_row_Id,0),0,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q
								FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) CROSS JOIN #Emp_Cons ec 
	WHERE --ISNULL(Form_ID,0) = @Form_ID AND 
			Cmp_Id=@Cmp_ID 
		And row_id >=1000		 --Hardik		
		AND Financial_Year = @fin_year  --Ankit 17072014

										
	UPDATE dbo.#Tax_Report
	SET Month_Count =  CASE WHEN Date_OF_Join > @From_date  AND ISNULL(Emp_Left_Date,@To_Date) >=@To_Date  THEN 
								DATEDIFF(m,Date_OF_Join,@To_Date) +1 
							WHEN Date_OF_Join > @From_date  AND ISNULL(Emp_Left_Date,@To_Date) < @To_Date  THEN 
								DATEDIFF(m,Date_OF_Join,Emp_Left_Date) +1 	
							WHEN Date_OF_Join <= @From_date  AND ISNULL(Emp_Left_Date,@To_Date) < @To_Date  THEN 
								DATEDIFF(m,@From_date,Emp_Left_Date) +1 	
							ELSE
								DATEDIFF(m,@From_Date,@To_Date) +1
							END
							
	FROM #Tax_Report t INNER JOIN T0080_emp_Master e ON t.Emp_ID =e.Emp_ID  
	WHERE Month_count = 0

	
	--Commnented By jimit 30012018 and added By Jimit as there is case at WCL (not getting latest Increment)
	UPDATE	#Tax_Report 
	SET		Increment_ID = Q.Increment_ID 
	FROM	#Tax_Report T INNER JOIN 
			(
				SELECT	I1.Emp_Id ,I1.Increment_ID 
				from	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN 
							(
								SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
								FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN 
										#Emp_Cons E ON I2.Emp_ID=E.Emp_ID INNER JOIN 
										(
											SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
													T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID	
											WHERE	I3.Increment_effective_Date <= @To_date AND I3.Cmp_ID = @Cmp_ID
													and I3.increment_type <> 'Transfer'
											GROUP BY I3.EMP_ID  
										 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
								 WHERE INCREMENT_TYPE <> 'TRANSFER' AND INCREMENT_TYPE<>'DEPUTATION'																																		
								 GROUP BY I2.Emp_ID
							 ) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID	
				 WHERE	Cmp_ID = @Cmp_ID
			 )Q ON T.emp_ID =Q.Emp_ID

	CREATE TABLE #TaxReportPara
	(
		Emp_ID			Int,
		Increment_ID	Int,
		Month_Count		TinyInt,
		From_Date		smalldatetime,
		To_Date			smalldatetime,
		Month_Diff		smallint,
		Month_En_Date	smalldatetime,
		Month_Sal		smallint,
		Month_Max_Date	smalldatetime,
		Date_Of_Join	smalldatetime
	)
	CREATE UNIQUE NONCLUSTERED INDEX NCIX_TaxReportPara ON #TaxReportPara(Emp_ID) Include(From_Date,To_Date, Month_Diff, Month_En_Date, Increment_ID)
	
	INSERT	INTO #TaxReportPara(Emp_ID, Increment_ID, Month_Count, From_Date, To_Date, Month_Diff, Month_En_Date)
	SELECT	Emp_ID, Increment_ID, Month_Count, @From_Date, @To_Date, 0, @Month_En_Date
	FROM	(SELECT DISTINCT Emp_ID,Increment_ID,Month_Count 
			 FROM	#Tax_Report) T
	
	/*
	SELECT	@Month_Sal = ISNULL(COUNT(emp_ID),0),@Month_Max_Date = MAX(Month_End_Date)
	FROM	T0200_Monthly_Salary 
	WHERE	Emp_ID=@emp_ID AND Month_End_Date >=@From_Date AND Month_End_Date <=@To_Date AND Month_End_Date <=@Month_En_Date
	
	SELECT	@join_date = date_of_join FROM T0080_EMP_MASTER WHERE emp_id = @emp_id
	
	DECLARE @temp_date AS DATETIME
	DECLARE @mon_count_actual AS NUMERIC
	DECLARE @mon_sal_not_done AS NUMERIC
    
	SET @mon_sal_not_done  = 0
    
    
	IF @Month_Max_Date IS NULL
		BEGIN 
			IF @from_date < @join_date 
				SET @Month_Max_Date = @join_date
			ELSE 
				SET @Month_Max_Date = @From_Date
		END
	*/
	UPDATE	T
	SET		Month_Sal = MS.Month_Sal,
			Month_Max_Date = Case When MS.Month_Max_Date IS NULL THEN
									CASE WHEN T.From_Date < EM.Date_Of_Join 
										THEN EM.Date_Of_Join 
										ELSE T.From_Date
									END									
								 Else MS.Month_Max_Date								 
							 End,
			Date_Of_Join = EM.Date_Of_Join
	FROM	#TaxReportPara T
			INNER JOIN T0080_Emp_Master EM ON T.Emp_ID=EM.Emp_ID
			INNER JOIN (SELECT	MS.Emp_ID,Count(1) As Month_Sal, Max(MS.Month_End_Date) As Month_Max_Date
						FROM	T0200_Monthly_Salary MS WITH (NOLOCK)
								INNER JOIN #TaxReportPara T1 ON MS.Emp_ID=T1.Emp_ID
						Where	MS.Month_End_Date BETWEEN T1.From_Date AND T1.TO_Date AND MS.Month_End_Date <= T1.Month_En_Date
						Group By MS.Emp_ID) MS ON T.Emp_ID=MS.Emp_ID
	
	/*
	IF @from_date < @join_date  
		SET @temp_date = @join_date
	ELSE 
		SET @temp_date = @From_Date
		
	SET	@mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) 				
	IF (@Month_Max_Date <> @join_date and @Month_Max_Date <> @From_Date)
		SET	@mon_count_actual = @mon_count_actual + 1
		
	
	SET @mon_sal_not_done = @mon_count_actual  - @Month_Sal
	SET	0 =					1 -					 1

	--IF ( @Month_Count - @Month_Sal - @mon_sal_not_done) > 0 --AND @Sp_Call_For <> 'Export_For_Actual'
	IF @Month_Count > @mon_count_actual --AND @Sp_Call_For <> 'Export_For_Actual'
		BEGIN 					
			SET @Month_Diff = @Month_Count - @Month_Sal	- @mon_sal_not_done												
			SET @Month_Diff = @Month_Count - (@Month_Sal + @mon_sal_not_done)
			SET @Month_Diff = @Month_Count - @mon_count_actual
			SET	11			=	12			- 1			-	0
			SET	11			=	12			- 1 --@mon_count_actual
		END						
	*/
	If @Sp_Call_For <> 'Export_For_Actual'
		BEGIN
			UPDATE	T
			SET		Month_Diff = DateDiff(MM, CASE WHEN FROM_DATE < Date_Of_Join THEN Date_Of_Join ELSE FROM_DATE END, Month_Max_Date)	--@mon_count_actual
			FROM	#TaxReportPara T
			
			--If there is salary exist between selected period
			UPDATE	T
			SET		Month_Diff = Month_Diff + 1 --@mon_count_actual
			FROM	#TaxReportPara T
			WHERE	Month_Max_Date <> Date_Of_Join and Month_Max_Date <> FROM_DATE
			
			UPDATE	T
			SET		Month_Diff = CASE WHEN Month_Count - Month_Diff < 0 THEN 0 ELSE  Month_Count - Month_Diff END --@Month_Diff
			FROM	#TaxReportPara T	
		END
	------------------ Allowance Exemption ---------------
	SELECT  * FROM #TaxReportPara
 
	DECLARE CUR_AD_Tax CURSOR FOR 
		SELECT DISTINCT t.EMP_ID ,t.Increment_ID,Month_Count 
		FROM #Tax_Report t --INNER JOIN T0080_emp_master e ON t.emp_ID = e.emp_ID	
	OPEN CUR_AD_Tax 
	FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID,@Month_Count
	WHILE @@FETCH_STATUS =0
		BEGIN
                       
			SET @Month_Sal =0
			
			SET @Month_Diff = 0
			
			If @Sp_Call_For <> 'Export_For_Actual'
				BEGIN
						
					SELECT	@Month_Sal = ISNULL(COUNT(emp_ID),0),@Month_Max_Date = MAX(Month_End_Date)
					FROM	T0200_Monthly_Salary WITH (NOLOCK)
					WHERE	Emp_ID=@emp_ID AND Month_End_Date >=@From_Date AND Month_End_Date <=@To_Date AND Month_End_Date <=@Month_En_Date
					
					SELECT	@join_date = date_of_join FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE emp_id = @emp_id
					
					DECLARE @temp_date AS DATETIME
					DECLARE @mon_count_actual AS NUMERIC
					DECLARE @mon_sal_not_done AS NUMERIC
		            
					SET @mon_sal_not_done  = 0
		            
		            
					IF @Month_Max_Date IS NULL
						BEGIN 
							IF @from_date < @join_date 
								SET @Month_Max_Date = @join_date
							ELSE 
								SET @Month_Max_Date = @From_Date
						END
				
		            
		            
					--IF @from_date < @join_date AND ISNULL(@Month_Max_Date,@from_date) = @From_Date
					--	SET @Month_Max_Date = ISNULL(@Month_Max_Date,@join_date)
					--ELSE IF	ISNULL(@Month_Max_Date,@from_date) = @From_Date
					--	SET @Month_Max_Date = ISNULL(@Month_Max_Date,@From_Date)
				
					IF @from_date < @join_date  
						SET @temp_date = @join_date
					ELSE 
						SET @temp_date = @From_Date
						
					SET	@mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) 				
					IF (@Month_Max_Date <> @join_date and @Month_Max_Date <> @From_Date)
						SET	@mon_count_actual = @mon_count_actual + 1
						
				
					--IF @Month_Max_Date = @join_date OR @Month_Max_Date = @From_Date
					--	BEGIN
					--		SET	@mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) 				
					--	END
					--ELSE
					--	BEGIN
					--		SET @mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) + 1
					--	END
				
					SET @mon_sal_not_done = @mon_count_actual  - @Month_Sal
				
				 
				
					IF ( @Month_Count - @Month_Sal - @mon_sal_not_done) > 0 --AND @Sp_Call_For <> 'Export_For_Actual'
						BEGIN 					
							SET @Month_Diff = @Month_Count - @Month_Sal	- @mon_sal_not_done												
						END						
				END
			select @Month_Diff Month_Diff, @Month_Max_Date Month_Max_Date, @Month_Sal Month_Sal

			EXEC dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID,@Cmp_ID,@Increment_ID,@From_Date,@To_Date,@Month_Diff,@Month_En_Date
			
			EXEC SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Diff,0		
			
			FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID	,@Month_Count	
		END
	CLOSE CUR_AD_Tax
	DEALLOCATE CUR_AD_Tax
			
	-------------------End Allowance	   ---------------
	--SELECT amount_col_final, * FROM #Tax_Report where Rimb_ID = 676


	UPDATE	#Tax_Report
	SET		Amount_Col_Final = Max_Limit 
	WHERE	Is_Exempted = 0 AND max_Limit_Compare_Row_ID =0 AND Max_Limit  > 0 AND Amount_Col_Final > 0 AND Amount_Col_Final > Max_Limit
	
	
	UPDATE	#Tax_Report 
	SET		Sal_No_Of_Month = E_COUNT
	FROM	#Tax_Report Tr INNER JOIN (SELECT MS.EMP_ID ,COUNT(MS.EMP_ID)E_COUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE
											AND ms.Month_End_Date <=@Month_En_Date 
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID



	UPDATE #Tax_Report 
	SET Amount_Col_Final = ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) + 
		,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0)  -- Added by rohit on 04052015
	,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) -- Added by rohit on 04052015
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND sa.Default_Def_ID = @Cont_Basic_Sal
	WHERE tr.DEFAULT_DEF_ID =@Cont_Basic_Sal
	
	UPDATE	#Tax_Report 
	SET		Amount_Col_Final =OT_Amount,
			Amount_Col_Actual = OT_Amount	
	FROM	#Tax_Report Tr 
			INNER JOIN (SELECT	MS.EMP_ID , Sum(IsNull(MS.OT_Amount,0)) + Sum(IsNull(MS.M_HO_OT_Amount,0)) + Sum(IsNull(MS.M_WO_OT_Amount,0)) As OT_Amount
						FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
								INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
						WHERE	MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE AND MS.Month_End_Date <=@Month_En_Date 
						GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE	tr.DEFAULT_DEF_ID =@Cont_OT_Amount
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Amount_Col_Final  + Isnull(S_Salary_Amount,0)
		,Amount_Col_Actual = Isnull(Amount_Col_Actual,0) + ISNULL(S_Salary_Amount,0)  -- Added by Hardik 08/11/2016 for Ashiana
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,SUM(MS.S_Salary_Amount) S_Salary_Amount FROM 
											T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.S_Eff_Date >=@FROM_DATE AND MS.S_Eff_Date <=@TO_DATE 
											AND Ms.S_Eff_Date <= @Month_En_Date
											AND EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY MS1 WITH (NOLOCK)
														WHERE MONTH(S_Eff_Date) = MONTH(MS1.MONTH_END_DATE) AND YEAR(S_Eff_Date) = YEAR(MS1.MONTH_END_DATE) 
																AND MS.Emp_ID=MS1.EMP_ID and MS1.MONTH_END_DATE >=@FROM_DATE AND MS1.MONTH_END_DATE <=@TO_DATE 
																AND MS1.MONTH_END_DATE <= @Month_En_Date
																)
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Basic_Sal
	
	
	--UPDATE #Tax_Report	--Ankit For Gratuity	
	--SET Amount_Col_Final = Gratuity_Amount
	--FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,SUM(MS.Gratuity_Amount) Gratuity_Amount FROM 
	--										T0200_MONTHLY_SALARY MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
	--								  WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE AND Ms.Month_End_Date <=@Month_En_Date
	--								  GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	--WHERE DEFAULT_DEF_ID =@Cont_Gratuity_Sal
	
	
	UPDATE #Tax_Report	--Ankit For Gratuity	
	SET Amount_Col_Final = Gratuity_Amount
	FROM #Tax_Report Tr INNER JOIN (  SELECT G.EMP_ID ,SUM(G.Gr_Amount) Gratuity_Amount FROM 
											T0100_GRATUITY G WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON G.EMP_ID = EC.EMP_ID 
									  WHERE G.Gr_FNF = 1 
											and paid_date between @FROM_DATE and @To_date --added By Jimit 11052018 as Gratuity Amount shown in Each financial year at WCL
									  GROUP BY G.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Gratuity_Sal
	

	
	--Added by Nimesh on 16-May-2017 (For Leave Encashment)
	CREATE TABLE #EMP_LEAVE_ENCASH
	(
		EMP_ID		NUMERIC,
		FOR_DATE	DATETIME,
		AMOUNT		NUMERIC(18,2)
	)

	INSERT INTO #EMP_LEAVE_ENCASH
	SELECT	MS.EMP_ID, Month_End_Date, Leave_Salary_Amount
	FROM	#Tax_Report Tr 
			INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Emp_ID=TR.Emp_ID
	WHERE	 MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE AND Ms.Month_End_Date <=@Month_En_Date
			AND MS.Leave_Salary_Amount >  0 AND DEFAULT_DEF_ID =@Cont_Leave_salary

	INSERT  INTO #EMP_LEAVE_ENCASH
	SELECT	Distinct TR.EMP_ID, LE.Lv_Encash_Apr_Date, LE.Leave_Encash_Amount
	FROM	#Tax_Report Tr 
			INNER JOIN T0120_LEAVE_ENCASH_APPROVAL LE WITH (NOLOCK) ON LE.Emp_ID=TR.Emp_ID
	WHERE	LE.Lv_Encash_Apr_Date >=@FROM_DATE AND LE.Lv_Encash_Apr_Date <=@TO_DATE AND LE.Lv_Encash_Apr_Date <=@Month_En_Date
			AND NOT EXISTS(SELECT 1 FROM #EMP_LEAVE_ENCASH ELE WHERE LE.Emp_ID=ELE.EMP_ID AND MONTH(LE.Lv_Encash_Apr_Date)=MONTH(ELE.FOR_DATE) AND YEAR(LE.Lv_Encash_Apr_Date)=YEAR(ELE.FOR_DATE))
			AND DEFAULT_DEF_ID =@Cont_Leave_salary And Isnull(LE.Eff_In_Salary,0) = 0 --- Eff_In_Salary condition added by Hardik 24/01/2018 for Ifedora as without Salary generate Leave Encash amount should not show
			AND Is_Exempted = 0

	UPDATE TR 
	SET		Amount_Col_Final = AMOUNT
	FROM	#Tax_Report TR 
			INNER JOIN (SELECT	EMP_ID, SUM(AMOUNT) AS AMOUNT 
						FROM	#EMP_LEAVE_ENCASH ELE 
						GROUP BY EMP_ID) ELE ON TR.EMP_ID=ELE.EMP_ID
	WHERE	DEFAULT_DEF_ID =@Cont_Leave_salary AND Is_Exempted = 0
	DROP TABLE #EMP_LEAVE_ENCASH
	
	--Added by Hardik 12/02/2018 for Havmor as they are Exempted Leave Encash during F&F
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Leave_Salary_Amount
	FROM #Tax_Report Tr INNER JOIN (  
	SELECT MS.EMP_ID ,SUM(MS.Leave_Encash_Amount)Leave_Salary_Amount 
	FROM 
	T0120_LEAVE_ENCASH_APPROVAL MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
	WHERE MS.Lv_Encash_Apr_Date >=@FROM_DATE AND MS.Lv_Encash_Apr_Date <=@TO_DATE 
	AND Ms.Lv_Encash_Apr_Date <=@Month_En_Date And Isnull(MS.Is_Tax_Free,0) = 1
	GROUP BY MS.EMP_ID 
	) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Leave_salary
			AND Is_Exempted = 1

	
	--UPDATE #Tax_Report 
	--SET Amount_Col_Final = Leave_Salary_Amount
	--FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,SUM(MS.Leave_Salary_Amount)Leave_Salary_Amount FROM 
	--										T0200_MONTHLY_SALARY MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
	--										WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
	--										AND Ms.Month_End_Date <=@Month_En_Date
	--									GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	--WHERE DEFAULT_DEF_ID =@Cont_Leave_salary
	--		AND Is_Exempted = 0 --Ankit 11082016
	


	/*
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Leave_Salary_Amount
	FROM #Tax_Report Tr INNER JOIN (  
	SELECT MS.EMP_ID ,SUM(MS.Leave_Encash_Amount)Leave_Salary_Amount 
	FROM 
	T0120_LEAVE_ENCASH_APPROVAL MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
	WHERE MS.Lv_Encash_Apr_Date >=@FROM_DATE AND MS.Lv_Encash_Apr_Date <=@TO_DATE 
	AND Ms.Lv_Encash_Apr_Date <=@Month_En_Date
	GROUP BY MS.EMP_ID 
	) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Leave_salary
			AND Is_Exempted = 0  -- added by rohit with discussion with hardikbhai on 18012017 for amount from leave approval -- case havmor 16-jan-2017
	*/
	
	------Hasmukh for notice payment 24122013---------
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Notice_payment
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,isnull(MS.Short_Fall_Dedu_Amount,0) as Notice_payment FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											Inner join T0100_LEFT_EMP LE WITH (NOLOCK) on MS.Emp_ID = LE.Emp_ID
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
											AND MS.Is_FNF = 1 and LE.Is_Terminate = 1) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Notice_Pay
	
	--------------------End---------------------------
	

   
	UPDATE #Tax_Report 
	SET Amount_Col_Final = OTHER_ALLOW_AMOUNT
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,ISNULL(SUM(MS.OTHER_ALLOW_AMOUNT),0)OTHER_ALLOW_AMOUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
											AND Ms.Month_End_Date <=@Month_En_Date
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID = @Cont_Arrear
		
	--UPdate #Tax_Report 
	--SET Amount_Col_Final = isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) + 
	--From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_HRA
	--WHERE tr.DEFAULT_DEF_ID =@Cont_HRA
	
	
	Declare @PT_Arrear Numeric(18,2)
	SET @PT_Arrear = 0
	
	SELECT @PT_Arrear = SUM(Isnull(MAD.M_AD_Amount,0)) 
	FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
	INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)
	ON MAD.AD_ID = AD.AD_ID  Where EMP_ID = @Emp_Id and AD.AD_DEF_ID = 22 
	and AD.AD_CALCULATE_ON='Import'
	and MAD.For_Date >=@From_Date and MAD.For_Date <=@To_Date
	
	 
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) + ISNULL(@PT_Arrear,0) --isnull(M_AD_Amount,0) +
	,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0)  -- Added by rohit on 04052015
	,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) -- Added by rohit on 04052015
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND sa.Default_Def_ID = @Cont_PT_Amount
	WHERE tr.DEFAULT_DEF_ID = @Cont_PT_Amount
	
	--- Added by Hardik 11/04/2018 For Standard Deduction
	UPDATE	TR 
	SET		Amount_Col_Final = CASE WHEN LE.Emp_ID IS NOT NULL AND (LE.Is_Death = 1 OR LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value,0) ELSE (ISNULL(IFD.Field_Value,0)/12)* dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID,@From_Date,@To_Date) END,
			Amount_Col_Actual = CASE WHEN LE.Emp_ID IS NOT NULL AND (LE.Is_Death = 1 OR LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value,0) ELSE (ISNULL(IFD.Field_Value,0)/12)* dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID,@From_Date,@To_Date) END
	FROM	#Tax_Report TR 
			INNER JOIN T0100_IT_FORM_DESIGN IFD  ON TR.Default_Def_Id=IFD.Default_Def_Id
			LEFT OUTER JOIN T0100_LEFT_EMP LE ON TR.Emp_ID = LE.Emp_ID
	WHERE	TR.Default_Def_Id = @Cont_Standard_Deduction And IFD.Financial_Year = @fin_year

	--- Added by Hardik 11/04/2018 For Net Round Amount for Taxable For RKM
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Net_Salary_Round_Diff_Amount
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,ISNULL(SUM(MS.Net_Salary_Round_Diff_Amount),0) as Net_Salary_Round_Diff_Amount FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
											AND Ms.Month_End_Date <=@Month_En_Date
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID = @Cont_Net_Round_Amount
	
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) +
	,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0)  -- Added by rohit on 04052015
	,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) -- Added by rohit on 04052015
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND tr.AD_ID = sa.aD_ID
			INNER JOIN T0050_AD_MASTER AM on AM.AD_ID = tr.AD_ID 
	  AND (ISNULL(AD_NOT_EFFECT_ON_SAL,0) =0 OR SA.Ad_effect_on_TDS =1)   and isnull(AM.Allowance_Type,'A') <> 'R'
	  And AD_DEF_ID Not in (20,21) -- Added by Hardik for Production Bonus and Production Variable on 22/03/2018
	  		
	--- Aded by Hardik 22/03/2018 for Production Bonus (AIA Client)
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0)
	,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0) 
	,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) 
	FROM #Tax_Report Tr INNER JOIN 
		(Select Emp_Id, SA.Ad_effect_on_TDS, Sum(SA.Old_M_AD_Amount) As Old_M_AD_Amount, Sum(SA.Month_Diff_Amount) As Month_Diff_Amount 
			From #Salary_AD SA Inner Join T0050_AD_MASTER AM On SA.Ad_Id = AM.AD_ID 
			Where AD_DEF_ID in (20)  and isnull(AM.Allowance_Type,'A') <> 'R' AND SA.Ad_effect_on_TDS =1
			Group By Emp_Id, SA.Ad_effect_on_TDS) SA
	ON tr.Emp_ID =sa.Emp_ID
	WHERE tr.DEFAULT_DEF_ID = @Cont_Production_Bonus

--Ramiz 03/07/2018-- Travel Settlement amount--
	UPDATE #Tax_Report 
	SET Amount_Col_Final = isnull(Travel_Amount,0)
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,ISNULL(SUM(MS.Travel_Amount),0) as Travel_Amount FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
											AND Ms.Month_End_Date <=@Month_En_Date
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID = @Cont_Travel_Settlement_Amount
--Ramiz 03/07/2018-- Travel Settlement amount--	
	
	---- Nilay20062014Perpuisite amount calculation-----

	UPDATE #Tax_Report 
	SET Amount_Col_Final =  Amount_Col_Final + ISNULL(Old_M_AD_Amount,0)  + ISNULL(Month_Diff_Amount,0)
	,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0)  -- Added by rohit on 04052015
	,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) -- Added by rohit on 04052015
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND tr.Rimb_ID = sa.aD_ID	
	inner join T0050_AD_MASTER on T0050_AD_MASTER.AD_ID = tr.Rimb_ID  where 
	   (ISNULL(AD_NOT_EFFECT_ON_SAL,0) =1 )  and isnull(Allowance_Type,'A')='R' and isnull(Tr.Default_Def_Id,0) = 0 And Tr.Is_Exempted=0 --- Hardik 12/02/2016 Added Exempted Codition
	 
	------ Nilay20062014Perpuisite amount calculation-----


	--	UPDATE #Tax_Report 
	--	SET Amount_Col_Final =  Bonus_Amt
	--	FROM #Tax_Report Tr INNER JOIN (SELECT sa.emp_id,SUM(ISNULL(Bonus_amount,0)) Bonus_Amt FROM 
	--									T0180_BONUS sa WHERE sa.From_DATE >=@FROM_DATE AND sa.TO_DATE <=@TO_DATE
	--									GROUP BY sa.emp_id) QB
	--									ON Tr.Emp_ID =QB.Emp_ID AND Tr.Default_Def_Id=2
										
	--	-----Nilay18062014----								
	-- changed by rohit for Effective month for tax calculate.
		UPDATE #Tax_Report 
	SET Amount_Col_Final =  Bonus_Amt
	FROM #Tax_Report Tr INNER JOIN (SELECT sa.emp_id,SUM(ISNULL(Bonus_amount,0)) Bonus_Amt FROM 
									T0180_BONUS sa WITH (NOLOCK)
									WHERE dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month,sa.Bonus_Effect_Year) >=@FROM_DATE AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month,sa.Bonus_Effect_Year)<=@TO_DATE
									GROUP BY sa.emp_id) QB
									ON Tr.Emp_ID =QB.Emp_ID AND Tr.Default_Def_Id=2  -- legal Bonus Amount
	
	
	-- Added by rohit For Add exgratia Amount tax calculation on 18052016									
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  Ex_Gratia_Bonus_Amount
	FROM #Tax_Report Tr INNER JOIN (SELECT sa.emp_id,SUM(ISNULL(Ex_Gratia_Bonus_Amount,0)) Ex_Gratia_Bonus_Amount FROM 
									T0180_BONUS sa WITH (NOLOCK) WHERE dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month,sa.Bonus_Effect_Year)>=@FROM_DATE AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month,sa.Bonus_Effect_Year) <=@TO_DATE
									GROUP BY sa.emp_id) QB
									ON Tr.Emp_ID =QB.Emp_ID AND Tr.Default_Def_Id=3  -- Exgratia bonus Amount
	-- ended by rohit on 18052016	
	
		
	--UPDATE #Tax_Report 
	--SET Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT,0)
	--FROM #Tax_Report Tr INNER JOIN (SELECT ITD.EMP_ID,IT_ID ,ISNULL(SUM(ITD.AMOUNT),0)AMOUNT FROM 
	--										T0100_IT_DECLARATION ITD INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID 
	--										WHERE ITD.FOR_DATE >=@FROM_DATE AND ITD.FOR_DATE <=@TO_DATE 
	--									GROUP BY ITD.EMP_ID,IT_ID ) Q ON TR.EMP_ID =Q.EMP_ID AND TR.IT_ID = Q.IT_ID	
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT,0)
	FROM #Tax_Report Tr INNER JOIN (SELECT ITD.EMP_ID,ITD.IT_ID , CASE WHEN ISNULL(IT.Exempt_Percent,0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT),0) * ISNULL(IT.Exempt_Percent,0))/100 ELSE ISNULL(SUM(ITD.AMOUNT),0) END AS AMOUNT 
										FROM 
											T0100_IT_DECLARATION ITD WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID 
											INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK) ON ITD.IT_ID=IT.IT_ID AND ITD.CMP_ID=IT.Cmp_ID
										WHERE ITD.FOR_DATE >=@FROM_DATE AND ITD.FOR_DATE <=@TO_DATE 
										GROUP BY ITD.EMP_ID,ITD.IT_ID,IT.Exempt_Percent ) Q ON TR.EMP_ID =Q.EMP_ID AND TR.IT_ID = Q.IT_ID	
						
						
	-------------------SET IT Form Design -------------------------					
																															
				
	
	UPDATE #Tax_Report
	SET Default_Def_Id = it_def_id
	FROM #Tax_Report tr INNER JOIN T0070_IT_MASTER it ON it.IT_ID = tr.IT_ID
	
	

--======================

DECLARE @IS_TOTAL INT 
	DECLARE @ROW_ID	  INT 
	DECLARE @From_Row_ID INT 
	DECLARE @TO_ROW_ID	INT 
	DECLARE @Multiple_Row_ID	VARCHAR(100)
	DECLARE @Max_Limit			NUMERIC(18, 0)
	DECLARE @Max_Limit_Compare_Row_ID	INT 
	DECLARE @Max_Limit_Compare_Type		VARCHAR(20)
	DECLARE @sqlQuery AS NVARCHAR(4000)
 
	DECLARE CUR_T CURSOR FOR 
		SELECT distinct IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
				Max_Limit_Compare_Type 
		FROM #Tax_Report  WHERE IS_TOTAL > 0
		ORDER BY Row_ID
	OPEN CUR_T 
	FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type 
	WHILE @@FETCH_STATUS =0
		BEGIN
		
		
			SET @sqlQuery =''
			IF @is_Total =1 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
				BEGIN
					UPDATE #Tax_Report
					SET Amount_Col_Final =ISNULL(Q.sum_amount,0)
					FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,SUM(Amount_Col_Final)Sum_amount FROM #Tax_Report WHERE
						Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID AND t.Row_ID =@Row_ID							
						
						
				END
			ELSE IF @is_Total =1  AND RTRIM(@Multiple_Row_ID) <> ''
				BEGIN

						UPDATE #Tax_Report
									SET Amount_Col_Final =ISNULL(Q.sum_amount,0)
									FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,SUM(Amount_Col_Final)Sum_amount FROM #Tax_Report WHERE
									Row_ID IN (SELECT DATA FROM dbo.Split(@Multiple_Row_ID,'#') WHERE DATA >0) GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID AND t.Row_ID =@Row_ID 
									
	--				SET @sqlQuery = 'update #Tax_Report
	--								SET Amount_Col_Final =isnull(Q.sum_amount,0)
	--								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
	--								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '
					
	--				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
				END
			ELSE IF @is_Total =2 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
				BEGIN
					UPDATE #Tax_Report
					SET Amount_Col_Final =ISNULL(Q.First_Amount,0) - ISNULL(Q1.Second_Amount,0)
					FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS First_Amount  FROM #Tax_Report WHERE
						Row_ID =@From_Row_ID )Q  ON t.emp_ID =q.Emp_ID 
						INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS Second_Amount  FROM #Tax_Report WHERE
						Row_ID =@To_row_ID )Q1  ON t.emp_ID =Q1.Emp_ID 
					WHERE t.Row_ID =@Row_ID													
																
				END
			ELSE IF @is_Total = 3 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 AND @Max_Limit > 0
				BEGIN
					

					      										
					--IF @Row_Id=138 --Commented by Hardik 27/04/2018
					IF Exists(Select 1 From #Tax_Report Where Row_ID=@ROW_ID And Default_Def_Id = 9) --- For Conveyance Exemption -- Change by Hardik 27/04/2018
						UPDATE #Tax_Report
						SET Amount_Col_Final = 
						CASE WHEN ISNULL(Q.Sum_amount,0)  <= @Max_Limit THEN
									ISNULL(Q.Sum_amount,0)
							 WHEN  ISNULL(Q.Sum_amount,0) > 0 THEN
									@Max_Limit
							ELSE
								0
							END 
						FROM #Tax_Report t INNER JOIN  (SELECT Emp_ID ,ISNULL(SUM(Amount_Col_Final),0)Sum_amount FROM #Tax_Report WHERE
							Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID
						WHERE t.Row_ID =@Row_ID	
						       AND NOT EXISTS(Select 1 From T0240_Perquisites_Employee_Car PEC WITH (NOLOCK) Where PEC.Financial_Year = @fin_year AND PEC.emp_id=T.Emp_ID)
					ELSE
						UPDATE #Tax_Report
						SET Amount_Col_Final = 
						CASE WHEN ISNULL(Q.Sum_amount,0)  <= @Max_Limit THEN
									ISNULL(Q.Sum_amount,0)
							 WHEN  ISNULL(Q.Sum_amount,0) > 0 THEN
									@Max_Limit
							ELSE
								0
							END 
						FROM #Tax_Report t INNER JOIN  (SELECT Emp_ID ,ISNULL(SUM(Amount_Col_Final),0)Sum_amount FROM #Tax_Report WHERE
							Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID
						WHERE t.Row_ID =@Row_ID												
													

				END
			ELSE IF @is_Total = 3 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
				BEGIN
					
					UPDATE #Tax_Report
					SET Amount_Col_Final =
					CASE WHEN ISNULL(Q.First_Amount,0)  <=   ISNULL(Q1.Second_Amount,0) THEN
								ISNULL(Q.First_Amount,0)
						ELSE
								ISNULL(Q1.Second_Amount,0)
						END 
					FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS First_Amount  FROM #Tax_Report WHERE
						Row_ID =@From_Row_ID )Q  ON t.emp_ID =q.Emp_ID 
						INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS Second_Amount  FROM #Tax_Report WHERE
						Row_ID =@To_row_ID )Q1  ON t.emp_ID =Q1.Emp_ID 
					WHERE t.Row_ID =@Row_ID													
																
				END
			
			FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type
		END
	CLOSE cur_T 
	DEALLOCATE Cur_T	



	-----------
   	DECLARE @EMP_ID_Per AS NUMERIC(18)
   
    DECLARE CUR_Tax_Per CURSOR FOR 
		SELECT emp_id FROM #Emp_Cons
	OPEN CUR_Tax_Per 
	FETCH NEXT FROM CUR_Tax_Per INTO @EMP_ID_Per
	WHILE @@FETCH_STATUS =0
		BEGIN
		
			DECLARE @PAct_Gross_Cal AS NUMERIC(18,2)
			DECLARE @PAct_Exe_Cal AS NUMERIC(18,2)
			DECLARE @Perquisit_amount AS NUMERIC(18,2)
			--DECLARE @fin_year AS NVARCHAR(20)
			
			SET @PAct_Gross_Cal = 0
			SET @PAct_Exe_Cal = 0
			SET @Perquisit_amount = 0
			
			--SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)
			
			SELECT @PAct_Gross_Cal =  Amount_Col_Final FROM #Tax_Report WHERE Row_ID = 104 AND Emp_ID = @EMP_ID_Per 
			
								
			
			SELECT @PAct_Exe_Cal = SUM(Amount_Col_Final) FROM #Tax_Report WHERE Default_Def_Id IN (8,9,11,151,152,163,160,164,166) AND Emp_ID = @EMP_ID_Per --added 166 for Gratuity exemption amount (as Tax computation perq value come wrong at WCL) added By Jimit 20012018
			
			--Declare @Reim_Perquisite_amount as numeric(18,2)
			--SET @Reim_Perquisite_amount =0
			--commented by rohit on 10092015 as per discussion with Deepak vyas wonder
			 ---- Nilay20062014Perpuisite amount calculation-----
			 
			--select @Reim_Perquisite_amount = sum(isnull(Taxable,0) + isnull(Tax_Free_amount,0)) 
			--						from T0210_Monthly_Reim_Detail where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID_Per and
			--                                       for_date >=@from_date and for_Date<=@to_date
			--                                       and Sal_tran_ID is null
			                                       
			---- Nilay20062014Perpuisite amount calculation-----
			
			
			
			EXEC GET_EMP_PERQUISITES @cmp_id,@EMP_ID_Per,@fin_year,@PAct_Gross_Cal,@PAct_Exe_Cal,@Perquisit_amount OUTPUT
			
			--if @Reim_Perquisite_amount > 0
			--	SET @Perquisit_amount =	 @Perquisit_amount + @Reim_Perquisite_amount
			
				
		
			UPDATE #Tax_Report
			SET Amount_Col_Final = @Perquisit_amount 
			--from #Tax_Report inner join #Emp_Cons ec on ec.Emp_ID = #Tax_Report.Emp_ID
			WHERE Default_Def_Id = @Cont_Perquisit_Amt AND Emp_ID = @EMP_ID_Per
		
	
	FETCH NEXT FROM CUR_Tax_Per INTO @EMP_ID_Per 
		END
	CLOSE CUR_Tax_Per
	DEALLOCATE CUR_Tax_Per
	
	
	----------
	--UPDATE #Tax_Report SET Amount_Col_Final = 0   WHERE Row_ID = 107 

	--Added by rohit for add Customized Perq on 26102015
	UPDATE	#Tax_Report 
	SET		Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT,0)
	FROM	#Tax_Report Tr 
			INNER JOIN (SELECT	ITD.EMP_ID,ITD.IT_ID ,ISNULL(SUM(ITD.AMOUNT),0)AMOUNT 
						FROM	T0240_Perquisites_Employee_Dynamic ITD WITH (NOLOCK)
								INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID 
								INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK) on ITD.Cmp_ID =IT.Cmp_ID and ITD.IT_ID = It.IT_ID and It.IT_Is_Active=1 and IT_Is_perquisite =1 
						WHERE	ITD.Financial_Year =@fin_year
						GROUP BY ITD.EMP_ID,ITD.IT_ID 
						) Q ON TR.EMP_ID =Q.EMP_ID AND TR.IT_ID = Q.IT_ID	 
	--Ended by rohit for add Customized Perq on 26102015



	--DECLARE CUR_T CURSOR FOR 
	--	SELECT IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
	--			Max_Limit_Compare_Type 
	--	FROM #Tax_Report  WHERE IS_TOTAL > 0
	--	order by Row_ID
	--OPEN CUR_T 
	--FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type 
	--while @@fetch_status =0
	--	begin
	--		SET @sqlQuery =''
	--		if @is_Total =1 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
	--			begin
	--				update #Tax_Report
	--				SET Amount_Col_Final = 0
	--				from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
	--					Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID							
	--			end
	--		else if @is_Total =1  and rtrim(@Multiple_Row_ID) <> ''
	--			begin

	--					update #Tax_Report
	--								SET Amount_Col_Final =isnull(Q.sum_amount,0)
	--								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
	--								Row_ID in (select Data From dbo.Split(@Multiple_Row_ID,'#') where Data >0) group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID 
									
	----				SET @sqlQuery = 'update #Tax_Report
	----								SET Amount_Col_Final =isnull(Q.sum_amount,0)
	----								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
	----								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '
					
	----				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
	--			end
	--		else if @is_Total =2 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
	--			begin
	--				update #Tax_Report
	--				SET Amount_Col_Final = 0
	--				from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
	--					Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
	--					inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
	--					Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
	--				Where t.Row_ID =@Row_ID													
																
	--			end
	--		--else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 and @Max_Limit > 0
	--		--	begin
					
	--		--		update #Tax_Report
	--		--		SET Amount_Col_Final =  0
	--		--		from #Tax_Report t inner join  (select Emp_ID ,isnull(sum(Amount_Col_Final),0)Sum_amount From #Tax_Report where
	--		--			Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID
	--		--		Where t.Row_ID =@Row_ID												
												

				 
	--		--	end
	--		--else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
	--		--	begin
					
					
	--		--		update #Tax_Report
	--		--		SET Amount_Col_Final = 0					 
	--		--		from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
	--		--			Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
	--		--			inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
	--		--			Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
	--		--		Where t.Row_ID =@Row_ID													
																
	--		--	end
			
	--		FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type
	--	end
	--close cur_T 
	--deallocate Cur_T
	
	
	UPDATE #Tax_Report
	SET Amount_Col_Final = Final_Exemption_Amount
	FROM #Tax_Report tr INNER JOIN 
	
	( SELECT t.Emp_ID,t.Row_ID, CASE WHEN q.Amount_Col_Final > t.Amount_Col_Final AND t.Amount_Col_Final > 0 THEN
								t.Amount_Col_Final
						   ELSE
								q.Amount_Col_Final
						   END  Final_Exemption_Amount
							
	FROM #Tax_Report t INNER JOIN 
	 ( SELECT Amount_Col_Final,Exem_Againt_Row_ID,Emp_ID FROM #Tax_Report WHERE ISNULL(Exem_Againt_Row_ID,0) >0 AND Amount_Col_Final >0 And Isnull(Rimb_ID,0)=0)q  --- Hardik 12/02/2016 Condition added for Rimb_Id As Reimbursement Exempt code done in Allowance exempt SP
	 ON t.Row_ID =q.Exem_Againt_Row_ID AND t.Emp_Id =q.emp_ID) q1 ON tr.Exem_Againt_Row_ID =q1.Row_ID AND tr.Emp_Id =q1.emp_ID
	
	
	--UPDATE #Tax_Report
	--SET Amount_Col_Final = 0
	--FROM #Tax_Report t 
	--WHERE t.Row_ID =138	
	--		AND EXISTS(Select 1 From T0240_Perquisites_Employee_Car PEC Where PEC.Financial_Year = @fin_year AND PEC.emp_id=T.Emp_ID)
	
	
	--Declare @IS_TOTAL int 
	--Declare @ROW_ID	  int 
	--Declare @From_Row_ID int 
	--Declare @TO_ROW_ID	int 
	--Declare @Multiple_Row_ID	varchar(100)
	--Declare @Max_Limit			numeric(18, 0)
	--Declare @Max_Limit_Compare_Row_ID	int 
	--Declare @Max_Limit_Compare_Type		varchar(20)
	--Declare @sqlQuery as nvarchar(4000)
	
	
	SET  @IS_TOTAL   =0
	SET  @ROW_ID	   =0
	SET   @From_Row_ID    =0
	SET   @TO_ROW_ID	  =0
	SET   @Multiple_Row_ID	= ''
	SET  @Max_Limit		  =0
	SET  @Max_Limit_Compare_Row_ID	  =0
	SET   @Max_Limit_Compare_Type	= ''
	SET   @sqlQuery = ''
  
 
	DECLARE CUR_T CURSOR FOR 
		SELECT distinct IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
				Max_Limit_Compare_Type 
		FROM #Tax_Report  WHERE IS_TOTAL > 0
		ORDER BY Row_ID
	OPEN CUR_T 
	FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type 
	WHILE @@FETCH_STATUS =0
		BEGIN
			SET @sqlQuery =''
			IF @is_Total =1 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
				BEGIN
					UPDATE #Tax_Report
					SET Amount_Col_Final =ISNULL(Q.sum_amount,0)
					FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,SUM(Amount_Col_Final)Sum_amount FROM #Tax_Report WHERE
						Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID AND t.Row_ID =@Row_ID							
				END
			ELSE IF @is_Total =1  AND RTRIM(@Multiple_Row_ID) <> ''
				BEGIN

						UPDATE #Tax_Report
									SET Amount_Col_Final =ISNULL(Q.sum_amount,0)
									FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,SUM(Amount_Col_Final)Sum_amount FROM #Tax_Report WHERE
									Row_ID IN (SELECT DATA FROM dbo.Split(@Multiple_Row_ID,'#') WHERE DATA >0) GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID AND t.Row_ID =@Row_ID 
									
	--				SET @sqlQuery = 'update #Tax_Report
	--								SET Amount_Col_Final =isnull(Q.sum_amount,0)
	--								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
	--								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '
					
	--				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
				END
			ELSE IF @is_Total =2 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
				BEGIN
					UPDATE #Tax_Report
					SET Amount_Col_Final =ISNULL(Q.First_Amount,0) - ISNULL(Q1.Second_Amount,0)
					FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS First_Amount  FROM #Tax_Report WHERE
						Row_ID =@From_Row_ID )Q  ON t.emp_ID =q.Emp_ID 
						INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS Second_Amount  FROM #Tax_Report WHERE
						Row_ID =@To_row_ID )Q1  ON t.emp_ID =Q1.Emp_ID 
					WHERE t.Row_ID =@Row_ID													
																
				END
			ELSE IF @is_Total = 3 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 AND @Max_Limit > 0
				BEGIN
					

					--IF @Row_Id=138 --Commented by Hardik 27/04/2018
				IF Exists(Select 1 From #Tax_Report Where Row_ID=@ROW_ID And Default_Def_Id = 9) --- For Conveyance Exemption -- Change by Hardik 27/04/2018
					UPDATE #Tax_Report
					SET Amount_Col_Final = 
					CASE WHEN ISNULL(Q.Sum_amount,0)  <= @Max_Limit THEN
								ISNULL(Q.Sum_amount,0)
						 WHEN  ISNULL(Q.Sum_amount,0) > 0 THEN
								@Max_Limit
						ELSE
							0
						END 
					FROM #Tax_Report t INNER JOIN  (SELECT Emp_ID ,ISNULL(SUM(Amount_Col_Final),0)Sum_amount FROM #Tax_Report WHERE
						Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID
					WHERE t.Row_ID =@Row_ID		
							AND not EXISTS(Select 1 From T0240_Perquisites_Employee_Car PEC WITH (NOLOCK) Where PEC.Financial_Year = @fin_year AND PEC.emp_id=T.Emp_ID)
				else
					UPDATE #Tax_Report
					SET Amount_Col_Final = 
					CASE WHEN ISNULL(Q.Sum_amount,0)  <= @Max_Limit THEN
								ISNULL(Q.Sum_amount,0)
						 WHEN  ISNULL(Q.Sum_amount,0) > 0 THEN
								@Max_Limit
						ELSE
							0
						END 
					FROM #Tax_Report t INNER JOIN  (SELECT Emp_ID ,ISNULL(SUM(Amount_Col_Final),0)Sum_amount FROM #Tax_Report WHERE
						Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID
					WHERE t.Row_ID =@Row_ID												
												

				 
				END
			ELSE IF @is_Total = 3 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
				BEGIN
					
					
					UPDATE #Tax_Report
					SET Amount_Col_Final =
					CASE WHEN ISNULL(Q.First_Amount,0)  <=   ISNULL(Q1.Second_Amount,0) THEN
								ISNULL(Q.First_Amount,0)
						ELSE
								ISNULL(Q1.Second_Amount,0)
						END 
					FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS First_Amount  FROM #Tax_Report WHERE
						Row_ID =@From_Row_ID )Q  ON t.emp_ID =q.Emp_ID 
						INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS Second_Amount  FROM #Tax_Report WHERE
						Row_ID =@To_row_ID )Q1  ON t.emp_ID =Q1.Emp_ID 
					WHERE t.Row_ID =@Row_ID													
																
				END
			
			FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type
		END
	CLOSE cur_T 
	DEALLOCATE Cur_T	

	UPDATE T SET Amount_Col_Final = 0 FROM #Tax_Report T WHERE Field_Type = 2 And Amount_Col_Final < 0 -- Added Condition by Hardik 28/08/2018 for Arkray as they don't want to show Negative Taxable Amount
	
	UPDATE #Tax_Report
	SET Amount_Col_Final = 0
	FROM #Tax_Report t 
	--WHERE t.Row_ID =138	 --- Commented by Hardik 27/04/2018
	WHERE t.Default_Def_Id = 9 -- For Conveyance Exemption -- Added by Hardik 27/04/2018
			AND EXISTS(Select 1 From T0240_Perquisites_Employee_Car PEC WITH (NOLOCK) Where PEC.Financial_Year = @fin_year AND PEC.emp_id=T.Emp_ID)

 
    UPDATE #Tax_Report 
      SET Amount_Col_Final = isnull(M_AD_Amount,0) 
      FROM #Tax_Report  t INNER JOIN T0210_Monthly_AD_Detail mad ON t.emp_ID =mad.Emp_ID 
      AND t.IT_Month = MONTH(Mad.To_Date) AND t.IT_Year = YEAR(Mad.To_Date) INNER JOIN
	  T0050_AD_MAster am ON mad.AD_ID= am.AD_ID AND AD_DEF_ID=1 AND mad.M_AD_Amount > 0   --Reguler TDS effected in salary
	
	UPDATE #Tax_Report 	
	 SET Amount_Col_Final = isnull(Amount_Col_Final,0) + Isnull(mad.TDS,0) 
      FROM #Tax_Report  t INNER JOIN (select sum(isnull(TDS,0)) as tds ,Emp_Id,month(for_date) AS _Month,YEAR(For_Date) as _year 
      from  T0210_ESIC_On_Not_Effect_on_Salary WITH (NOLOCK) group by emp_id,month(for_date) ,YEAR(For_Date) ) mad ON t.emp_ID =mad.Emp_ID 
      AND t.IT_Month = _Month AND t.IT_Year = _year AND mad.TDS > 0  --Extra Deducted TDS not effected on salary Component added by Rohit on  21072015
	
	UPDATE #Tax_Report 	
	 SET Amount_Col_Final = isnull(Amount_Col_Final,0) + Isnull(mad.Income_Tax_on_Bonus,0) 
      FROM #Tax_Report  t INNER JOIN 
      (select sum(isnull(Income_Tax_on_Bonus,0)) as Income_Tax_on_Bonus ,Emp_Id, Bonus_Effect_Month AS Bonus_Effect_Month,Bonus_Effect_Year as Bonus_Effect_Year 
      from  t0180_bonus WITH (NOLOCK) group by emp_id,Bonus_Effect_Month,Bonus_Effect_Year) mad ON t.emp_ID =mad.Emp_ID 
      AND t.IT_Month = Bonus_Effect_Month AND t.IT_Year = Bonus_Effect_Year AND mad.Income_Tax_on_Bonus > 0  --Extra Deducted TDS on Bonus and Exgratia amount added by Rohit on  19052016
	
	  
	  
	UPDATE #Tax_Report 
      SET Amount_Col_Final = Amount_Col_Final + Isnull(M_AD_Amount,0) 
      FROM #Tax_Report  t INNER JOIN T0210_Monthly_AD_Detail mad ON t.emp_ID =mad.Emp_ID 
      AND t.IT_Month = MONTH(Mad.To_Date) AND t.IT_Year = YEAR(Mad.To_Date) INNER JOIN
	  T0050_AD_MAster am ON mad.AD_ID= am.AD_ID AND AD_DEF_ID=13 AND mad.M_AD_Amount > 0  --Extra TDS not effected in salary added by Hasmukh 17092014
	
	
	--UPDATE #Tax_Report 
	--SET Increment_ID = Q.Increment_ID 
	--FROM #Tax_Report t INNER JOIN 
	--(SELECT I.Emp_Id ,Increment_ID FROM T0095_Increment I INNER JOIN 
	--				(SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment
	--				WHERE Increment_Effective_date <= @To_Date
	--				AND Cmp_ID = @Cmp_ID
	--				GROUP BY emp_ID  ) Qry ON
	--				I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date	
	--		WHERE Cmp_ID = @Cmp_ID )Q ON t.emp_ID =q.Emp_ID 
			
		
	
	DECLARE @TAXABLE_AMOUNT		NUMERIC 
	DECLARE @Return_Tax_Amount	NUMERIC 
	DECLARE @Surcharge_amount	NUMERIC 
	DECLARE @ED_Cess			NUMERIC 
	DECLARE @M_AD_Amount		NUMERIC 
	
	DECLARE @TAXABLE_AMOUNT_Inc		NUMERIC 
	DECLARE @Return_Tax_Amount_Inc	NUMERIC 
	DECLARE @Surcharge_amount_Inc	NUMERIC 
	DECLARE @ED_Cess_Inc			NUMERIC 
	DECLARE @M_AD_Amount_Inc		NUMERIC 
	DECLARE @Incentive_Amount		NUMERIC
	DECLARE @Remain_Month			NUMERIC
	DECLARE @Other_Paid_TDS_Amont   NUMERIC
	DECLARE @Return_Tax_Amount_Actual NUMERIC	--Ankit 27042016
	SET @Return_Tax_Amount_Actual = 0
	
	DECLARE CUR_TAX CURSOR FOR 
		SELECT EMP_ID ,Amount_Col_Final,Increment_ID FROM #Tax_Report 	WHERE field_type = 2	
	OPEN CUR_TAX 
	FETCH NEXT FROM CUR_TAX INTO @EMP_ID ,@TAXABLE_AMOUNT,@Increment_ID
	WHILE @@FETCH_STATUS =0
		BEGIN
			SET @Return_Tax_Amount		= 0
			SET @Surcharge_amount		= 0 
			SET @ED_Cess				= 0
			SET @TAXABLE_AMOUNT_Inc		= 0 
			SET @Return_Tax_Amount_Inc	= 0
			SET @Surcharge_amount_Inc	= 0 
			SET @ED_Cess_Inc			= 0
			SET @Incentive_Amount		= 0		
			SET @Return_Tax_Amount_Actual = 0
			
			SELECT @Incentive_Amount = ISNULL(SUM(Amount_Col_Final),0) FROM #Tax_Report WHERE Emp_ID =@Emp_ID AND isnull(Is_Incentive,0) = 1  --ISNULL(Is_Salary_comp,0) = 1 
		
		
				
			IF @Incentive_Amount > 0 
				BEGIN					
					SET @TAXABLE_AMOUNT_Inc = @TAXABLE_AMOUNT - @Incentive_Amount
					EXEC dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date,@TAXABLE_AMOUNT_Inc ,@Return_Tax_Amount_Inc OUTPUT
							,@Surcharge_amount_Inc OUTPUT ,@ED_Cess_Inc OUTPUT ,@ED_Cess_Per ,@SurCharge_Per, @Relief_87A_Amount output,@Return_Tax_Amount_Actual OUTPUT
					
					

					SET @Return_Tax_Amount_Inc = @Return_Tax_Amount_Inc + @ED_Cess_Inc
				END 
				
      
			EXECUTE dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date,@TAXABLE_AMOUNT ,@Return_Tax_Amount OUTPUT
						,@Surcharge_amount OUTPUT ,@ED_Cess OUTPUT ,@ED_Cess_Per ,@SurCharge_Per, @Relief_87A_Amount output,@Return_Tax_Amount_Actual OUTPUT
			 
	
	
			UPDATE #Tax_Report 
			SET Amount_Col_Final = @Return_Tax_Amount 
			WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_Tax

			--------- Relief_87A_Amount Add By Hasmukh 20-Dec-13------------
			declare @Actual_IT_Amount as numeric(18,2)
			DECLARE @Sec_87A_Amount NUMERIC(18,2)
			
			
			
			IF YEAR(@From_Date) >= 2016		/* Relief Limit Change 2000 to 5000 effect From Year 2016-2017  --Ankit 25042016	*/
				If YEAR(@From_Date) >= 2017
					SET @Sec_87A_Amount = 2500
				ELSE
					SET @Sec_87A_Amount = 5000
			ELSE	
				SET @Sec_87A_Amount = 2000


			IF @Relief_87A_Amount > 0 and year(@To_Date) >= 2014
				begin

					Update #Tax_Report 
					SET Amount_Col_Final = @Return_Tax_Amount_Actual -- Amount_Col_Final + @Sec_87A_Amount
					where Emp_ID =@Emp_ID and Default_Def_ID = 101 
				
					select @Actual_IT_Amount = Amount_Col_Final from #Tax_Report
					where Emp_ID =@Emp_ID and Default_Def_ID = 101
							
					Update #Tax_Report 
					SET Amount_Col_Final = @Sec_87A_Amount /* CASE WHEN @Sec_87A_Amount > @Return_Tax_Amount_Actual THEN @Return_Tax_Amount_Actual ELSE @Sec_87A_Amount END  */
					where Emp_ID =@Emp_ID and Default_Def_ID = -102
									
					Update #Tax_Report 
					SET Amount_Col_Final = @Actual_IT_Amount - @Sec_87A_Amount /* CASE WHEN @Sec_87A_Amount > @Return_Tax_Amount_Actual THEN @Return_Tax_Amount_Actual ELSE @Sec_87A_Amount END  */
					where Emp_ID =@Emp_ID and Default_Def_ID = -103
				end	
			-------------------End---------------------------
			
			UPDATE #Tax_Report 
			SET Amount_Col_Final = @ED_Cess 
			WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_ED_Cess
			
			SET @Other_Paid_TDS_Amont = 0
            SELECT @Other_Paid_TDS_Amont = ISNULL(SUM(Amount),0) FROM T0100_IT_DECLARATION ID WITH (NOLOCK)
					LEFT OUTER JOIN	T0070_IT_MASTER IM WITH (NOLOCK) ON ID.IT_ID = IM.IT_ID AND IM.cmp_id = IM.cmp_id 
			WHERE Emp_ID =@Emp_ID AND For_Date >=@From_Date AND for_Date <=@To_Date AND For_Date <=@Month_En_Date AND IM.IT_Def_ID = 10 
			

			--Start-------1-Cr.--Surcharge---------------------------------------------------Mitesh--
			DECLARE @Taxabel_Income_S NUMERIC(18,2)
			--select @Taxabel_Income_S = Amount_Col_Final from #Tax_Report WHERE field_type = 2 AND emp_id = @EMP_ID
			SET @Taxabel_Income_S = @TAXABLE_AMOUNT
			
			
			
			IF @Taxabel_Income_S >= 10000000  Or (@Taxabel_Income_S >= 5000000 and YEAR(@From_Date) >= 2017)
				BEGIN
					

						DECLARE @limt_Const_S NUMERIC(18,2) 
						DECLARE @tax_Payable_On_limit_Const_S NUMERIC(18,2) 
			
						DECLARE @Tax_Amount_S NUMERIC(18,2)
						DECLARE @Tax_Amount_WO_S NUMERIC(18,2)
						DECLARE @Temp_Surcharge_S NUMERIC(18,2)
						DECLARE @Marginal_Relief_S NUMERIC(18,2)
						DECLARE @Actual_Surcharge_S NUMERIC(18,2) 
						DECLARE @TAXABLE_AMOUNT_with_Sur NUMERIC(18,2) 
						Declare @Surcharge_Amt as numeric(18,2)
									
						SET @Marginal_Relief_S = 0
						SET @Actual_Surcharge_S = 0
						SET @Surcharge_Amt= 0

						if YEAR(@From_Date) >= 2017
							if @Taxabel_Income_S >= 5000000 and @Taxabel_Income_S < 10000000
								SET @limt_Const_S =  5000000
							else 
								SET @limt_Const_S =  10000000
						else
							SET @limt_Const_S =  10000000
						
						-- Added by rohit on 27062015
						Declare @net_Income_Range Numeric(18,2)
						Declare @Surchage_Percentage Numeric(18,2)
						
						SET @net_Income_Range = 0
						SET @Surchage_Percentage = 0
						
						select @net_Income_Range = net_income_Range,@Surchage_Percentage = Field_Value
						from T0100_IT_FORM_DESIGN WITH (NOLOCK)
						WHERE default_def_id = @Cont_Surcharge and Financial_Year = @fin_year and Cmp_ID= @Cmp_ID 
						
						if @net_Income_Range = 0
							SET @net_Income_Range = 10510540
						if @Surchage_Percentage = 0
							SET @Surchage_Percentage = 10
						
						if @Taxabel_Income_S >= 5000000 and @Taxabel_Income_S < 10000000
							SET @Surchage_Percentage =  10
						else  if  @Taxabel_Income_S >  10000000
							SET @Surchage_Percentage =  15							
						else  if  @Taxabel_Income_S <  10000000
						    SET @Surchage_Percentage =  15							
					
						-- Ended by rohit on 27062015
						
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
						--	SET @Surcharge_Amt= (@Return_Tax_Amount * 10/100)
						--ELSE
						--	SET @Surcharge_Amt= (@Return_Tax_Amount * 12/100)	
							
							SET @Surcharge_Amt= (@Return_Tax_Amount * @Surchage_Percentage/100)
							


						SET @tax_Payable_On_limit_Const_S = ROUND((@Taxabel_Income_S - @limt_Const_S) * 30/100,0)
							
						If (@Taxabel_Income_S) <= @net_Income_Range  -- 10510540
							begin
								SET @Marginal_Relief_S = (@Taxabel_Income_S - @limt_Const_S) -  @tax_Payable_On_limit_Const_S
							end
						Else
							SET @Marginal_Relief_S =  0

						If (@Taxabel_Income_S) <= @net_Income_Range  --10510540 
							SET @Actual_Surcharge_S =  Case When @Surcharge_Amt < @Marginal_Relief_S then @Surcharge_Amt else @Marginal_Relief_S End
						Else
							SET @Actual_Surcharge_S =  Case When @Surcharge_Amt > @Marginal_Relief_S then @Surcharge_Amt else @Marginal_Relief_S End



						UPDATE #Tax_Report SET Amount_Col_Final = @Actual_Surcharge_S WHERE default_def_id = @Cont_Surcharge AND emp_id = @emp_id
						
						 

						SET @TAXABLE_AMOUNT_with_Sur = @Return_Tax_Amount + @Actual_Surcharge_S

						SET @Return_Tax_Amount = @TAXABLE_AMOUNT_with_Sur

					EXECUTE dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date, @TAXABLE_AMOUNT,@TAXABLE_AMOUNT_with_Sur OUTPUT
						,@Actual_Surcharge_S OUTPUT ,@ED_Cess OUTPUT ,@ED_Cess_Per ,@SurCharge_Per, @Relief_87A_Amount output
					
					
					 
						--UPDATE #Tax_Report 
						--	SET Amount_Col_Final = @Return_Tax_Amount 
						--	WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_Tax

						UPDATE #Tax_Report 
							SET Amount_Col_Final = @ED_Cess 
							WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_ED_Cess
			
				End
			


			--End-------1-Cr.--Surcharge---------------------------------------------------Mitesh--

		 
			UPDATE #Tax_Report 
			SET Amount_Col_Final = @Other_Paid_TDS_Amont 
			WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Less_TDS )
			
			
			----DECLARE @tax_inc AS NUMERIC(18,2)
			----DECLARE @Relief_amount AS NUMERIC(18,2)
			
			----SET @tax_inc = 0
			----SET @Relief_amount = 0

			----SELECT @tax_inc = Amount_Col_Final FROM #tax_report WHERE Row_ID = 182 AND Emp_ID =@Emp_ID
			------select * from #tax_report where default_def_Id = 103

			----IF @tax_inc <= @Relief_sec_87_limit AND YEAR(@to_date) >= 2014 
			----	BEGIN
			----		UPDATE #tax_report SET Amount_Col_Final = @Relief_sec_87  WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID
			----		IF (@Return_Tax_Amount + @ED_Cess) < @Relief_sec_87
			----			BEGIN
			----				SET @Relief_sec_87 = @Return_Tax_Amount + @ED_Cess
			----			END
			----		ELSE
			----			BEGIN
			----				SET @Relief_sec_87 = 2000
			----			END 
	
			----	SET @Relief_amount =  @Relief_sec_87
			----	END
			----ELSE
			----	BEGIN
			----		SET @Relief_sec_87 = 2000 
			----		UPDATE #tax_report SET Amount_Col_Final = 0 WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID
			----		SET @Relief_amount =  0
			----	END
			
		
			UPDATE #Tax_Report 
			SET Amount_Col_Final = (@Return_Tax_Amount + @ED_Cess) - @Other_Paid_TDS_Amont -- - @Relief_amount
			WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_tax_Lia


		 
			SET @Return_Tax_Amount  = (@Return_Tax_Amount + @ED_Cess) - @Other_Paid_TDS_Amont --- @Relief_amount
		
			SET @M_AD_Amount = 0
			SELECT @M_AD_Amount = ISNULL(SUM(M_AD_Amount),0)  FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK) INNER JOIN
					T0050_AD_MAster am WITH (NOLOCK) ON mad.AD_ID= am.AD_ID AND mad.cmp_id = am.cmp_id AND (AD_DEF_ID = 1 or AD_DEF_ID = 13)  -- ad Def id 1 = TDS + ad Def id 13 = extra TDS added by Hasmukh 17092014
			WHERE Emp_ID =@Emp_ID AND To_Date >=@From_Date AND To_Date <=@To_Date AND To_Date <=@Month_En_Date
           
            
			SELECT @M_AD_Amount = @M_AD_Amount + ISNULL(SUM(mad.TDS),0)  FROM T0210_ESIC_On_Not_Effect_on_Salary mad WITH (NOLOCK)  -- TDS on Not Effect on Salary Componenet added by rohit on 21072015
			WHERE Emp_ID =@Emp_ID AND For_Date >=@From_Date AND For_Date <=@To_Date AND For_Date  <=@Month_En_Date
		
			
		
			UPDATE #Tax_Report 			
			SET Amount_Col_Final = @Return_Tax_Amount + @Other_Paid_TDS_Amont  ,Y_Surcharge_Amount =@Surcharge_amount,Y_Edu_Cess_Amount=@ED_Cess			            --+ @Relief_amount
						,Y_IT_Paid_Amount = @M_AD_Amount,Total_Taxable_Amount =@TAXABLE_AMOUNT						
						,Incentive_Tax = @Return_Tax_Amount_Inc , Incentive_Tax_Amount =@Incentive_Amount		
			WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Net_Lia)
									
			UPDATE #Tax_Report 
			SET Amount_Col_Final = @M_AD_Amount 
			WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Paid_Tax )
		
			UPDATE #Tax_Report 
			SET Amount_Col_Final = @Return_Tax_Amount - @M_AD_Amount 
			WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Due_Tax )


              UPDATE #Tax_Report 
			SET Y_IT_Paid_Amount  = Y_IT_Paid_Amount + @Other_Paid_TDS_Amont --+ @Relief_amount 
			WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Net_Lia )
		
			FETCH NEXT FROM CUR_TAX INTO @EMP_ID ,@TAXABLE_AMOUNT,@Increment_ID		
		END
	CLOSE CUR_TAX
	DEALLOCATE CUR_TAX 
	
	

	--UPdate #Tax_Report 
	--SET Amount_Col_Final = SALARY_AMOUNT
	--From #Tax_Report Tr inner join (SELECT MS.EMP_ID ,SUM(MS.SALARY_AMOUNT)SALARY_AMOUNT FROM 
	--										T0200_MONTHLY_SALARY MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
	--										WHERE MS.MONTH_sT_DATE >=@FROM_DATE AND MS.MONTH_ST_DATE <=@TO_DATE 
	--									GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	--WHERE DEFAULT_DEF_ID =@Cont_Annual_Sal


  
	UPDATE #Tax_Report
	SET Amount_col_1 = Amount_Col_Final
	WHERE ISNULL(Col_No,0) IN(0,1)
	

	UPDATE #Tax_Report
	SET Amount_col_2 = Amount_Col_Final
	WHERE ISNULL(Col_No,0) =2

	UPDATE #Tax_Report
	SET Amount_col_3 = Amount_Col_Final
	WHERE ISNULL(Col_No,0) =3

	UPDATE #Tax_Report
	SET Amount_col_4 = Amount_Col_Final
	WHERE ISNULL(Col_No,0) =4

	UPDATE #Tax_Report
	SET Exempted_Amount = q.Amount_Col_Final
	FROM #Tax_Report t INNER JOIN 
	 ( SELECT Amount_Col_Final,Exem_Againt_Row_ID,Emp_ID FROM #Tax_Report WHERE ISNULL(Exem_Againt_Row_ID,0) >0 AND Amount_Col_Final >0)q 
	 ON t.Row_Id =q.Exem_Againt_Row_ID AND t.Emp_Id =q.emp_ID
	 
	 

	IF @Sp_Call_For='Tax Planning'
		BEGIN
		
			DECLARE @Less_TDS NUMERIC(18,2)
			
			SET @Remain_Month = 0
			SET @Less_TDS = 0
			
			SELECT @Remain_Month = DATEDIFF(MM,@Month_En_Date,@To_Date)	+ 1			
			--select @Less_TDS = Amount_Col_Final from #Tax_Report where Default_Def_Id = 120
			
			--SET @Less_TDS = ISNULL(@Less_TDS,0)

			IF @Remain_Month > 0
				BEGIN									
					UPDATE  #Tax_Report  
					--Set		M_IT_Amount		  = Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount, 
					--		M_Edu_Cess_Amount = (Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount) * @ED_Cess_Per * 0.01						
					
					--Set		M_IT_Amount		  = (((Amount_col_final - (Y_IT_PAID_Amount + @Less_TDS))/@Remain_Month) + Incentive_Tax) - ((((Amount_col_final - (Y_IT_PAID_Amount))/@Remain_Month) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))),
					--		M_Edu_Cess_Amount = (((Amount_col_final - (Y_IT_PAID_Amount + @Less_TDS))/@Remain_Month) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))
					
												--(Y_IT_PAID_Amount + @Less_TDS)												
					SET		M_IT_Amount		  = (((Amount_col_final - (Y_IT_PAID_Amount ))/@Remain_Month) + Incentive_Tax) - ((((Amount_col_final - (Y_IT_PAID_Amount ))/@Remain_Month) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))),
							M_Edu_Cess_Amount = (((Amount_col_final - (Y_IT_PAID_Amount ))/@Remain_Month) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))
						
					WHERE Default_Def_ID = @Cont_Net_Lia 
					--select * from #Tax_Report Where Default_Def_ID = @Cont_Net_Lia
		 		 END
		 	ELSE		 		
		 		BEGIN					 		
					--Set		M_IT_Amount		  = Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount, 
					--		M_Edu_Cess_Amount = (Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount) * @ED_Cess_Per * 0.01						
					
					
					UPDATE  #Tax_Report  
					SET		M_IT_Amount		  = ((Amount_col_final - (Y_IT_PAID_Amount )) + Incentive_Tax) - (((Amount_col_final - Y_IT_PAID_Amount ) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))),
							M_Edu_Cess_Amount =  ((Amount_col_final - (Y_IT_PAID_Amount )) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))
					
					WHERE Default_Def_ID = @Cont_Net_Lia 
					
		 		 END
		 	
			UPDATE  #Tax_Report  
					SET	 M_IT_Amount= 0,
						 M_Edu_Cess_Amount = 0
			WHERE Default_Def_ID = @Cont_Net_Lia AND M_IT_Amount < 0 
		
			-- Changed By Ali 22112013 EmpName_Alias
			SELECT  tr.*,ISNULL(EM.EmpName_Alias_Tax,EM.Emp_Full_Name) as Emp_Full_Name,em.Alpha_Emp_Code As emp_code,em.Alpha_Emp_Code
					,EM.Date_Of_Join				-- Added By Hiral 05 June,2013
			FROM #Tax_Report tr LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID
			WHERE Default_Def_ID = @Cont_Net_Lia AND tr.M_IT_Amount > 0 
			ORDER BY tr.Emp_ID ,tr.Row_ID
				
		END	
	ELSE If @Sp_Call_For='Salary Slip'
		BEGIN
			-- Changed By Ali 22112013 EmpName_Alias
			SELECT  Row_ID,SPACE(Concate_Space)+ FIELD_NAME AS  FIELD_NAME,Amount_Col_Final,Amount_Col_1,Amount_Col_2,Amount_Col_3,Amount_Col_4,Default_def_ID,AD_ID,IT_ID 
					,tr.Emp_ID,em.Emp_Code,em.Alpha_Emp_Code,ISNULL(EM.EmpName_Alias_Tax,EM.Emp_Full_Name) as Emp_Full_Name,DM.Desig_Name,em.Date_Of_Join,em.Pan_No,@From_Date P_From_Date ,@To_Date P_To_Date
					,Is_Show,Concate_Space,Exempted_Amount,I_Q.Branch_ID
					,CASE WHEN EM.Date_Of_Join > @From_date THEN EM.Date_Of_Join ELSE @From_date END AS H_From_date 
					,CASE WHEN EM.Emp_Left_date < @To_date THEN EM.Emp_Left_date ELSE @To_date END AS H_To_test,tr.Field_type
					,Show_In_SalarySlip,--SPACE(Concate_Space)+ Display_Name_For_SalarySlip as Display_Name_For_SalarySlip
					Display_Name_For_SalarySlip, tr.Amount_Col_Actual,tr.Amount_Col_Assumed
			FROM #Tax_Report tr LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID INNER JOIN  
				
				(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
				(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment   WITH (NOLOCK)  -- Ankit 11092014 for Same Date Increment
					WHERE Increment_Effective_date <= @To_Date    
						AND Cmp_ID = @Cmp_ID    
						GROUP BY emp_ID  ) Qry ON    
				I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  ) I_Q  ON EM.Emp_ID = I_Q.Emp_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON I_Q.Desig_Id = DM.Desig_ID
				Where Show_In_SalarySlip=1
			ORDER BY tr.Emp_ID ,tr.Row_ID			
		END
	Else if @Sp_Call_For='Full & Final'  --Added by Hardik 11/10/2014
		Begin
			
			SELECT  Tr.Emp_ID,tr.Amount_Col_Final
			FROM #Tax_Report tr LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID
			WHERE Default_Def_ID = @Cont_Due_Tax 
			ORDER BY tr.Emp_ID ,tr.Row_ID
			
		End
	Else if @Sp_Call_For='Taxable_Amount'  --Added by Rohit for taxable Amount get on 15072015
		Begin
			SELECT TR.Cmp_ID,TR.EMP_ID ,Amount_Col_Final,
					CASE WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'N','Y') AS NUMERIC(18,2)) > 80 THEN 'V' 
						 WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'N','Y') AS NUMERIC(18,2)) > 60 THEN 'S'				
					else Gender end as gender,0,0 FROM #Tax_Report TR LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID
				WHERE field_type = 2 order by emp_id	
			
		End		
	Else If @Sp_Call_For ='Export' OR @Sp_Call_For ='Export_For_Actual'	
		BEGIN
			-- Changed By Ali 22112013 EmpName_Alias
			SELECT  Row_ID,SPACE(Concate_Space)+ FIELD_NAME AS  FIELD_NAME,Amount_Col_Final,Amount_Col_1,Amount_Col_2,Amount_Col_3,Amount_Col_4,Default_def_ID,AD_ID,IT_ID 
					,tr.Emp_ID,em.Emp_Code,em.Alpha_Emp_Code,ISNULL(EM.EmpName_Alias_Tax,EM.Emp_Full_Name) as Emp_Full_Name,DM.Desig_Name,em.Date_Of_Join,em.Pan_No,@From_Date P_From_Date ,@To_Date P_To_Date
					,Is_Show,Concate_Space,Exempted_Amount,I_Q.Branch_ID
					,CASE WHEN EM.Date_Of_Join > @From_date THEN EM.Date_Of_Join ELSE @From_date END AS H_From_date 
					,CASE WHEN EM.Emp_Left_date < @To_date THEN EM.Emp_Left_date ELSE @To_date END AS H_To_test,tr.Field_type
					,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q,Amount_Col_Actual,Amount_Col_Assumed
					,dmm.Dept_Name ,BM.branch_name
			FROM #Tax_Report tr LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID INNER JOIN  
				
				(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
				(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment  WITH (NOLOCK)  
					WHERE Increment_Effective_date <= @To_Date    
						AND Cmp_ID = @Cmp_ID    
						GROUP BY emp_ID  ) Qry ON    
				I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  ) I_Q  ON EM.Emp_ID = I_Q.Emp_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON I_Q.Desig_Id = DM.Desig_ID
				left join t0040_department_master DMM WITH (NOLOCK) on  I_Q.Dept_ID = DMM.Dept_ID
				left join t0030_branch_master BM WITH (NOLOCK) on I_Q.branch_id = Bm.branch_id
				---Where Is_Show =1
			--where 1 = case when (AD_ID > 0 OR Rimb_ID >0) and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
			--and Is_Show =1 -- Added by rohit
			ORDER BY Dmm.Dept_Name, tr.Emp_ID ,tr.Row_ID			
		END
	Else If @Sp_Call_For ='Form24Q'	
		BEGIN
			-- Changed By Ali 22112013 EmpName_Alias
			SELECT  Row_ID,SPACE(Concate_Space)+ FIELD_NAME AS  FIELD_NAME,Amount_Col_Final,Amount_Col_1,Amount_Col_2,Amount_Col_3,Amount_Col_4,Default_def_ID,AD_ID,IT_ID 
					,tr.Emp_ID,em.Emp_Code,em.Alpha_Emp_Code,ISNULL(EM.EmpName_Alias_Tax,EM.Emp_Full_Name) as Emp_Full_Name,DM.Desig_Name,em.Date_Of_Join,em.Pan_No,@From_Date P_From_Date ,@To_Date P_To_Date
					,Is_Show,Concate_Space,Exempted_Amount,I_Q.Branch_ID
					,CASE WHEN EM.Date_Of_Join > @From_date THEN EM.Date_Of_Join ELSE @From_date END AS H_From_date 
					,CASE WHEN EM.Emp_Left_date < @To_date THEN EM.Emp_Left_date ELSE @To_date END AS H_To_test,tr.Field_type
					,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q,Amount_Col_Actual,Amount_Col_Assumed
					,dmm.Dept_Name ,BM.branch_name
			FROM #Tax_Report tr LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID INNER JOIN  
				
				(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
				(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)   
					WHERE Increment_Effective_date <= @To_Date    
						AND Cmp_ID = @Cmp_ID    
						GROUP BY emp_ID  ) Qry ON    
				I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  ) I_Q  ON EM.Emp_ID = I_Q.Emp_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON I_Q.Desig_Id = DM.Desig_ID
				left join t0040_department_master DMM WITH (NOLOCK) on  I_Q.Dept_ID = DMM.Dept_ID
				left join t0030_branch_master BM WITH (NOLOCK) on I_Q.branch_id = Bm.branch_id
				---Where Is_Show =1
			--where 1 = case when (AD_ID > 0 OR Rimb_ID >0) and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
			--and Is_Show =1 -- Added by rohit
			ORDER BY Dmm.Dept_Name, tr.Emp_ID ,tr.Row_ID			
		END


	ELSE
		BEGIN
		
		
			-- Changed By Ali 22112013 EmpName_Alias
			SELECT  Row_ID,SPACE(Concate_Space)+ FIELD_NAME AS  FIELD_NAME,Amount_Col_Final,Amount_Col_1,Amount_Col_2,Amount_Col_3,Amount_Col_4,Default_def_ID,AD_ID,IT_ID 
					,tr.Emp_ID,em.Emp_Code,em.Alpha_Emp_Code,ISNULL(EM.EmpName_Alias_Tax,EM.Emp_Full_Name) as Emp_Full_Name,DM.Desig_Name,em.Date_Of_Join,em.Pan_No,@From_Date P_From_Date ,@To_Date P_To_Date
					,Is_Show,Concate_Space,Exempted_Amount,I_Q.Branch_ID
					,CASE WHEN EM.Date_Of_Join > @From_date THEN EM.Date_Of_Join ELSE @From_date END AS H_From_date 
					,CASE WHEN EM.Emp_Left_date < @To_date THEN EM.Emp_Left_date ELSE @To_date END AS H_To_test,tr.Field_type
					,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q,Amount_Col_Actual,Amount_Col_Assumed
					,dmm.Dept_Name ,BM.branch_name,cm.Cmp_Name,cm.Cmp_PAN_No,cm.Cmp_TAN_No
			FROM #Tax_Report tr LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID INNER JOIN  
				
				(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN     
				(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment  WITH (NOLOCK)  
					WHERE Increment_Effective_date <= @To_Date    
						AND Cmp_ID = @Cmp_ID    
						GROUP BY emp_ID  ) Qry ON    
				I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  ) I_Q  ON EM.Emp_ID = I_Q.Emp_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON I_Q.Desig_Id = DM.Desig_ID
				left join t0040_department_master DMM WITH (NOLOCK) on  I_Q.Dept_ID = DMM.Dept_ID
				left join t0030_branch_master BM WITH (NOLOCK) on I_Q.branch_id = Bm.branch_id Inner JOIN
				T0010_COMPANY_MASTER CM WITH (NOLOCK) on em.Cmp_ID=cm.Cmp_Id
				---Where Is_Show =1
			--	where 1 = case when AD_ID > 0 and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
			--ORDER BY tr.Emp_ID ,tr.Row_ID		
				where 1 = case when (AD_ID > 0 OR Rimb_ID >0) and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
			--and Is_Show =1 -- Added by rohit
			ORDER BY tr.Emp_ID ,tr.Row_ID				
		END
	RETURN




