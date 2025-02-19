---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Emp_Perquisites]
	 @Cmp_ID				NUMERIC
	,@From_Date				DATETIME
	,@To_Date				DATETIME
	,@Branch_ID				NUMERIC 
	,@Cat_ID				NUMERIC
	,@Grd_ID				NUMERIC
	,@Type_ID				NUMERIC
	,@Dept_ID				NUMERIC
	,@Desig_Id				NUMERIC 
	,@Emp_ID				NUMERIC
	,@Constraint			VARCHAR(max)
	,@Product_ID			NUMERIC 
	,@Taxable_Amount_Cond	NUMERIC = 0  
	,@Format_Name			VARCHAR(50) ='Format1'
	,@Form_ID				NUMERIC =0
	,@Sp_Call_For			VARCHAR(30) =''
	,@Month_En_Date			DATETIME =NULL 
	,@Month_St_Date			DATETIME = NULL
	,@F_Year				Varchar(50)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Cont_Basic_Sal		TINYINT
	DECLARE @Cont_Gratuity_Sal TINYINT -- ADDED BY HARDIK 17/06/2020 FOR WCL
	DECLARE @Cont_PT_Amount		TINYINT 
	DECLARE @Cont_Total_Tax		TINYINT 
	DECLARE @Cont_Surcharge		TINYINT 
	DECLARE @Cont_Total_tax_Lia	TINYINT 
	DECLARE @Cont_ED_Cess		TINYINT 
	DECLARE @Cont_Net_Lia		TINYINT 
	DECLARE @Cont_Tax			TINYINT 
	DECLARE @Cont_Paid_Tax		TINYINT 
	DECLARE @Cont_Due_Tax		TINYINT 
	DECLARE @Cont_Annual_Sal	TINYINT 
	DECLARE @Cont_HRA			TINYINT
	DECLARE @Cont_Arrear		TINYINT
	DECLARE @Cont_Less_TDS		TINYINT 
	DECLARE @Cont_Perquisit_Amt TINYINT
	DECLARE @Cont_Leave_salary  TINYINT
	DECLARE @Relief_sec_87 NUMERIC(18,2)
	DECLARE @Relief_sec_87_limit NUMERIC(18,2)
	DECLARE @Cont_Notice_Pay	TINYINT
	

	SET @Cont_Basic_Sal		=1
	SET @Cont_Gratuity_Sal = 5 -- ADDED BY HARDIK 17/06/2020 FOR WCL
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
	SET @Cont_Leave_salary  = 6
	SET @Relief_sec_87 = 2000
	SET @Relief_sec_87_limit = 500000
	SET @Cont_Notice_Pay = 51
	
	IF ISNULL(@Month_En_Date,'') = ''
		BEGIN
			SET @Month_En_Date = @To_Date
		END 
	IF ISNULL(@Month_St_Date,'') =''
		BEGIN
			SET @Month_St_Date = @From_Date
		END
	

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
		
	
	DECLARE @Emp_Cons TABLE
	 (
		Emp_ID	NUMERIC
	  )
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO @Emp_Cons(Emp_ID)
			SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
			INSERT INTO @Emp_Cons(Emp_ID)

			SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
					( SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					WHERE Increment_Effective_date <= @To_Date
					AND Cmp_ID = @Cmp_ID
					GROUP BY emp_ID  ) Qry ON
					I.Emp_ID = Qry.Emp_ID	AND I.Increment_Id = Qry.Increment_Id
					INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) ON i.Emp_ID = e.Emp_ID							
			WHERE i.Cmp_ID = @Cmp_ID 
			AND ISNULL(i.Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(i.Cat_ID,0))
			AND i.Branch_ID = ISNULL(@Branch_ID ,i.Branch_ID)
			AND i.Grd_ID = ISNULL(@Grd_ID ,i.Grd_ID)
			AND ISNULL(i.Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(i.Dept_ID,0))
			AND ISNULL(i.Type_ID,0) = ISNULL(@Type_ID ,ISNULL(i.Type_ID,0))
			AND ISNULL(i.Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(i.Desig_ID,0))
			AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID) 
			AND E.Date_Of_Join <=@Month_En_Date
			AND I.Emp_ID IN 
				( SELECT Emp_Id FROM
				(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @Month_En_Date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				WHERE cmp_ID = @Cmp_ID   AND  
				(( @Month_St_Date  >= join_Date  AND  @Month_St_Date <= left_date ) 
				OR ( @Month_En_Date  >= join_Date  AND @Month_En_Date <= left_date )
				OR Left_date IS NULL AND @Month_En_Date >= Join_Date)
				OR @Month_En_Date >= left_date  AND  @Month_St_Date <= left_date ) 		
		END
	
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
	    
	--IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#perquisites_Details')
	--BEGIN
	--	DROP TABLE #Salary_AD
	--END			    	

	CREATE table #Tax_Report 
	  ( 
		T_ID						NUMERIC IDENTITY(1,1),
		Emp_ID						NUMERIC,
		Cmp_ID						NUMERIC(18, 0) NOT NULL ,
		Format_Name					VARCHAR (20) ,
		Row_ID						INT NOT NULL ,
		Field_Name					VARCHAR (100) ,
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
		Is_Incentive                TINYINT
	  )
	CREATE CLUSTERED INDEX ind_temp1 ON #Tax_Report(T_ID)
	CREATE NONCLUSTERED INDEX ind_temp2 ON #Tax_Report(Row_ID)
	CREATE NONCLUSTERED INDEX ind_temp3 ON #Tax_Report(Emp_ID)
	CREATE NONCLUSTERED INDEX ind_temp4 ON #Tax_Report(Field_Name)
	CREATE NONCLUSTERED INDEX ind_temp5 ON #Tax_Report(Cmp_ID)
		
	CREATE table #Tax_Report_Male
	  (
		 Auto_Row_Id	 INT IDENTITY(1,1) ,
		 Field_Name		VARCHAR(2000),
		 Default_Def_Id	NUMERIC,
		 T_F_Row_ID		INT ,
		 T_T_Row_ID		INT ,
		 IT_Month		INT,
		 IT_YEAR		INT,
		 IT_L_ID		NUMERIC,
		 Is_Show		TINYINT DEFAULT 1,
		 Is_TaxPaid_Rec  TINYINT DEFAULT 0	
	   )
	 
	CREATE table #Salary_AD
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
	
	--CREATE table #perquisites_Details
	--(
	--	Sr_NO numeric,
	--	cmp_id numeric,
	--	emp_id numeric,
	--	fin_year nvarchar(50),
	--	Nature_of_perq nvarchar(60),
	--	value_of_perq numeric(18,2),
	--	Amount_Recoverd numeric(18,2),
	--	Final_Amount numeric(18,2),
	--	Gross_Salary numeric(18,2) default 0,
	--	Total_Exp numeric(18,2)	default 0	
	--)		

    DECLARE @fin_year AS NVARCHAR(20)  
	Set @fin_year = ''
	SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)  

	
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

	SET @ED_Cess_Per		= 3
	SET @SurCharge_per		= 0 --10 % Surchage not applicable from 2009-10 (A.Y. 2010-11) and w.e.f. 01.04.2009 comment by Hasmukh 10042012
	Set @Relief_87A_Amount = 0
	
	
	SET @Month_Count = DATEDIFF(m,@From_Date,@To_Date) +1		
	INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,Field_Type,Is_Show,Col_No,Concate_Space
								,Is_Salary_comp,Exem_Againt_row_Id,Exempted_Amount)	

	SELECT Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,@From_Date,@To_Date ,Field_Type,Is_Show,Col_No,ISNULL(Concate_Space,0) 
								,ISNULL(Is_Salary_comp,0),ISNULL(Exem_Againt_row_Id,0),0
								FROM T0100_IT_FORM_DESIGN WITH (NOLOCK) CROSS JOIN @Emp_Cons ec 
	WHERE ISNULL(Form_ID,0) = @Form_ID AND Cmp_Id=@Cmp_ID 				
	And Default_Def_Id not in (101,-102,-103,103,104,105,106,107,108,120,121,102)		 --Hardik		
	AND Financial_Year = @fin_year  --Ankit 17072014

	
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_show)
	--SELECT ' ',0,0	
		 
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_show)
	--SELECT 'Tax Limit ',0,0
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT ' ',0,0
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '---------------------Male-------------------',0,0
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,IS_Show)	
	--SELECT CAST(From_Limit AS VARCHAR(15)) + ' To ' +  CAST(TO_Limit AS VARCHAR(15)) + ' ( ' +  CAST(Percentage AS VARCHAR(10))+ ' %) ' ,0,IT_L_ID ,0  
	--FROM T0040_tAx_limit t INNER JOIN
	--( SELECT cmp_ID , MAX(for_Date) For_Date FROM T0040_tAx_limit 
	--	WHERE cmp_ID= @Cmp_ID AND For_Date <=@To_Date AND gender ='M' GROUP BY cmp_ID)q ON t.cmp_ID =q.cmp_ID AND T.for_Date =q.for_Date AND gender ='M'

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '-------------------Female-------------------',0,0
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,Is_show)
	--SELECT CAST(From_Limit AS VARCHAR(15)) + ' To ' +  CAST(TO_Limit AS VARCHAR(15)) + ' ( ' +  CAST(Percentage AS VARCHAR(10))+ ' %) ' ,0,IT_L_ID ,0  
	--FROM T0040_tAx_limit t INNER JOIN
	--( SELECT cmp_ID , MAX(for_Date) For_Date FROM T0040_tAx_limit 
	--	WHERE cmp_ID= @Cmp_ID AND For_Date <=@To_Date AND gender ='F' GROUP BY cmp_ID)q ON t.cmp_ID =q.cmp_ID AND T.for_Date =q.for_Date AND gender ='F'

  
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '12. Tax on Total Income ',101

	--IF YEAR(@To_Date) >= 2014
	--	Begin
	--		INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--		SELECT '   * Less: Tax rebate U/s 87A ',-102
	
	--		INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--		SELECT '#   Tax on Total Income ',-103
	--	End


	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '13. Ed. Cess 3%(On Tax Computed At Sr.No.12)',104
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '14. Tax Payable(12 + 13)',105

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '15.(a) Less:Relief Under section 89 (attach details)',0,@Max_From_Row_ID,@Max_Row_ID-1
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '     (b) Less TDS deducted from other income reported by employee',120,@Max_From_Row_ID,@Max_Row_ID-1
		
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '16. Tax Payable(14 - 15)',103,@Max_From_Row_ID,@Max_Row_ID-1
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,is_show)
	--SELECT 'Income Tax Paid Detail',106,0

	--SELECT @Max_Row_ID = ISNULL(MAX(AUTO_Row_ID),0) + 1  FROM  #Tax_Report_Male
	
	--SET @Max_From_Row_ID = @Max_Row_ID
	--SET @T_For_Date = @From_Date
	--WHILE @T_For_Date <=@To_Date 
	--	BEGIN
	--			INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR,Is_Show,Is_TaxPaid_Rec	)
	--			SELECT DATENAME(m,@T_For_Date),0,MONTH(@T_For_Date),YEAR(@T_For_Date),0,1
				
	--		SET @T_For_Date = DATEADD(m,1,@T_For_Date)
	--		SET @Max_Row_ID = @Max_Row_ID + 1
	--	END
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	--SELECT '17. Less: TDS Paid',107,@Max_From_Row_ID,@Max_Row_ID-1

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
	--SELECT '18. TAX PAYABLE/REFUNDABLE (16 - 17)',108
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT ' ',0,0

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT 'HOUSE RENT ALLOWANCE EXEMPT',0,0
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT 'Annual Salary ( Exclusive benefits and Perquisites)',109,0

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT 'House Rent Allowance Received',110,0

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT 'Less : Exemption u/s 10 (13A) read with rule 2 A',0,0

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '  A ) House rent allowance Received',110,0
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '  B ) Actual Rent Paid',112,0
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '   Less : 1/10 of Salary',113,0
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '   Different Amount',114,0
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '  C ) I. Two Fifth of Salary (Non Metro)',115,0
	
	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT '       II. One Half of Salary (Metro)',116,0

	--INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	--SELECT 'House rent Allow. Exempted ( least of a,b or c )',7,0

	
	SELECT @Max_Row_ID = ISNULL(MAX(Row_ID),0) + 1  FROM  dbo.#Tax_Report
	
	--INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
	--							,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,IT_Month,IT_YEAR,IT_L_ID,Is_Show,Is_TaxPaid_Rec)
	--SELECT Emp_ID,@Cmp_ID,@Format_Name,Auto_Row_Id + @Max_Row_ID ,Field_Name,NULL,NULL,Default_Def_Id,0,ISNULL(T_F_Row_ID + @Max_Row_ID,0) ,ISNULL(T_T_Row_ID + @Max_Row_ID,0),'',0,0
	--							,0,0,0,NULL,@From_Date,@To_Date,IT_Month,IT_Year,IT_L_ID,Is_Show ,Is_TaxPaid_Rec FROM #Tax_Report_Male CROSS JOIN @Emp_Cons
										
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
														and I3.increment_type <> 'Transfer' AND INCREMENT_TYPE<>'DEPUTATION'
												GROUP BY I3.EMP_ID  
											 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
									 WHERE INCREMENT_TYPE <> 'TRANSFER' AND INCREMENT_TYPE<>'DEPUTATION'																																		
									 GROUP BY I2.Emp_ID
								 ) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID	
					 WHERE	Cmp_ID = @Cmp_ID
				 )Q ON T.emp_ID =Q.Emp_ID

------------------ Allowance Exemption ---------------
 
	DECLARE CUR_AD_Tax CURSOR FOR 
		SELECT DISTINCT t.EMP_ID ,t.Increment_ID,Month_Count 
		FROM #Tax_Report t INNER JOIN T0080_emp_master e WITH (NOLOCK) ON t.emp_ID = e.emp_ID	
	OPEN CUR_AD_Tax 
	FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID,@Month_Count
	WHILE @@FETCH_STATUS =0
		BEGIN
            
            IF EXISTS (Select Emp_Id from (
			SELECT Emp_id FROM T0240_Perquisites_Employee WITH (NOLOCK) WHERE Emp_id = @emp_ID AND Cmp_id = @Cmp_ID AND Financial_Year = @F_Year
			UNION
			SELECT Emp_Id FROM T0240_Perquisites_Employee_Car WITH (NOLOCK) WHERE emp_id = @emp_ID AND Cmp_id = @Cmp_ID AND Financial_Year = @F_Year
			UNION 
			SELECT Emp_Id FROM T0240_PERQUISITES_EMPLOYEE_GEW WITH (NOLOCK) WHERE Emp_id = @emp_ID AND Cmp_id = @Cmp_ID AND Financial_Year = @F_Year) as t)       
			BEGIN
				
				SET @Month_Sal =0
				
				SELECT @Month_Sal = ISNULL(COUNT(emp_ID),0) FROM T0200_Monthly_Salary WITH (NOLOCK) WHERE Emp_ID=@emp_ID AND Month_End_Date >=@From_Date AND Month_End_Date <=@To_Date AND Month_End_Date <=@Month_En_Date
				SELECT @Month_Max_Date = MAX(Month_End_Date) FROM T0200_Monthly_Salary WITH (NOLOCK) WHERE Emp_ID=@emp_ID AND Month_End_Date >=@From_Date AND Month_End_Date <=@To_Date AND Month_End_Date <=@Month_En_Date
				SELECT @join_date = date_of_join FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE emp_id = @emp_id
	   
				DECLARE @temp_date AS DATETIME
				DECLARE @mon_count_actual AS NUMERIC
				DECLARE @mon_sal_not_done AS NUMERIC
	            
				SET @mon_sal_not_done  = 0
	            
				IF @from_date < @join_date AND ISNULL(@Month_Max_Date,@from_date) = @From_Date
					SET @Month_Max_Date = ISNULL(@Month_Max_Date,@join_date)
				ELSE IF	ISNULL(@Month_Max_Date,@from_date) = @From_Date
					SET @Month_Max_Date = ISNULL(@Month_Max_Date,@From_Date)
			
				IF @from_date < @join_date  
					SET @temp_date = @join_date
				ELSE 
					SET @temp_date = @From_Date
			
			
				IF @Month_Max_Date = @join_date OR @Month_Max_Date = @From_Date
					BEGIN
						SET	@mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) 				
					END
				ELSE
					BEGIN
						SET @mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) + 1
					END
			
				SET @mon_sal_not_done = @mon_count_actual  - @Month_Sal
				IF ( @Month_Count - @Month_Sal ) > 0
					BEGIN 
					 
							SET @Month_Diff = @Month_Count - @Month_Sal	- @mon_sal_not_done							
					END	
				ELSE 
					BEGIN 
						SET @Month_Diff =0
					END	
			
			  
				
				EXEC dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID,@Cmp_ID,@Increment_ID,@From_Date,@To_Date,@Month_Diff,@Month_En_Date
				EXEC SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Diff,0		
			END			
			FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID	,@Month_Count	
		END
	CLOSE CUR_AD_Tax
	DEALLOCATE CUR_AD_Tax
			
	-------------------End Allowance	   ---------------

	UPDATE #Tax_Report
	SET Amount_Col_Final = Max_Limit 
	WHERE Is_Exempted = 0 AND max_Limit_Compare_Row_ID =0 AND Max_Limit  > 0 AND Amount_Col_Final > 0 AND Amount_Col_Final > Max_Limit

	
	UPDATE #Tax_Report 
	SET Sal_No_Of_Month = E_COUNT
	FROM #Tax_Report Tr INNER JOIN (SELECT MS.EMP_ID ,COUNT(MS.EMP_ID)E_COUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE
											AND ms.Month_End_Date <=@Month_En_Date 
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID

	UPDATE #Tax_Report 
	SET Amount_Col_Final = ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) 
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND sa.Default_Def_ID = @Cont_Basic_Sal
	WHERE tr.DEFAULT_DEF_ID =@Cont_Basic_Sal
	
	UPDATE #Tax_Report	--Ankit For Gratuity	
	SET Amount_Col_Final = Gratuity_Amount
	FROM #Tax_Report Tr INNER JOIN (  SELECT G.EMP_ID ,SUM(G.Gr_Amount) Gratuity_Amount FROM 
											T0100_GRATUITY G WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON G.EMP_ID = EC.EMP_ID 
									  WHERE G.CMP_ID= @CMP_ID AND G.Gr_FNF = 1 
											and paid_date between @FROM_DATE and @To_date --added By Jimit 11052018 as Gratuity Amount shown in Each financial year at WCL
									  GROUP BY G.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Gratuity_Sal
	 
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Amount_Col_Final  + S_Salary_Amount
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,SUM(MS.S_Salary_Amount) S_Salary_Amount FROM 
											T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.S_Month_End_Date >=@FROM_DATE AND MS.S_Month_End_Date <=@TO_DATE 											
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Basic_Sal
	
   
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Leave_Salary_Amount
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,SUM(MS.Leave_Salary_Amount)Leave_Salary_Amount FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 											
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Leave_salary
	
	------Hasmukh for notice payment 24122013---------
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Notice_payment
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,isnull(MS.Short_Fall_Dedu_Amount,0) as Notice_payment FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											Inner join T0100_LEFT_EMP LE WITH (NOLOCK) on MS.Emp_ID = LE.Emp_ID
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 
											AND MS.Is_FNF = 1 and LE.Is_Terminate = 1) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Notice_Pay
	
	--------------------End---------------------------
	
  
	UPDATE #Tax_Report 
	SET Amount_Col_Final = OTHER_ALLOW_AMOUNT
	FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,ISNULL(SUM(MS.OTHER_ALLOW_AMOUNT),0)OTHER_ALLOW_AMOUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE 											
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID = @Cont_Arrear
		
	--UPdate #Tax_Report 
	--set Amount_Col_Final = isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) + 
	--From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_HRA
	--WHERE tr.DEFAULT_DEF_ID =@Cont_HRA
	   
	 
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) +
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND sa.Default_Def_ID = @Cont_PT_Amount
	WHERE tr.DEFAULT_DEF_ID = @Cont_PT_Amount
	
	
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) +
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND tr.AD_ID = sa.aD_ID
	  AND (ISNULL(AD_NOT_EFFECT_ON_SAL,0) =0 OR Ad_effect_on_TDS =1) 
	  
	  
	  
	UPDATE #Tax_Report 
	SET Amount_Col_Final =  Bonus_Amt
	FROM #Tax_Report Tr INNER JOIN (SELECT sa.emp_id,SUM(ISNULL(Bonus_amount,0)) Bonus_Amt FROM 
									T0180_BONUS sa WITH (NOLOCK) WHERE sa.From_DATE >=@FROM_DATE AND sa.TO_DATE <=@TO_DATE
									GROUP BY sa.emp_id) QB
									ON Tr.Emp_ID =QB.Emp_ID AND Tr.Default_Def_Id=2
	
	UPDATE #Tax_Report 
	SET Amount_Col_Final = Amount_Col_Final + IsNULL(AMOUNT,0) --Changed By Jimit 03042018 As LTA Exemption Amount is not considering in the Perq report (WCL)
	FROM #Tax_Report Tr INNER JOIN (SELECT ITD.EMP_ID,IT_ID ,ISNULL(SUM(ITD.AMOUNT),0)AMOUNT FROM 
											T0100_IT_DECLARATION ITD WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON ITD.EMP_ID = EC.EMP_ID 
											WHERE ITD.FOR_DATE >=@FROM_DATE AND ITD.FOR_DATE <=@TO_DATE 
										GROUP BY ITD.EMP_ID,IT_ID ) Q ON TR.EMP_ID =Q.EMP_ID AND TR.IT_ID = Q.IT_ID
										
										
	
	---- Nilay20062014Perpuisite amount calculation-----	Added By Ankit 25032016

	UPDATE #Tax_Report 
	SET Amount_Col_Final =  Amount_Col_Final + ISNULL(Old_M_AD_Amount,0)  + ISNULL(Month_Diff_Amount,0)
	FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND tr.Rimb_ID = sa.aD_ID	
	inner join T0050_AD_MASTER on T0050_AD_MASTER.AD_ID = tr.Rimb_ID  where 
	   (ISNULL(AD_NOT_EFFECT_ON_SAL,0) =1 )  and isnull(Allowance_Type,'A')='R' and isnull(Tr.Default_Def_Id,0) = 0 And Tr.Is_Exempted=0 --- Hardik 12/02/2016 Added Exempted Codition
	 
---- Nilay20062014Perpuisite amount calculation-----
										
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
		SELECT IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
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
 --  	DECLARE @EMP_ID_Per AS NUMERIC(18)
   
 --   DECLARE CUR_Tax_Per CURSOR FOR 
	--	SELECT emp_id FROM @Emp_Cons
	--OPEN CUR_Tax_Per 
	--FETCH NEXT FROM CUR_Tax_Per INTO @EMP_ID_Per
	--WHILE @@FETCH_STATUS =0
	--	BEGIN
		
	--		DECLARE @PAct_Gross_Cal AS NUMERIC(18,2)
	--		DECLARE @PAct_Exe_Cal AS NUMERIC(18,2)
	--		DECLARE @Perquisit_amount AS NUMERIC(18,2)
	--		--DECLARE @fin_year AS NVARCHAR(20)
			
	--		SET @PAct_Gross_Cal = 0
	--		SET @PAct_Exe_Cal = 0
	--		SET @Perquisit_amount = 0
			
	--		SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)
	--		SELECT @PAct_Gross_Cal =  Amount_Col_Final FROM #Tax_Report WHERE Row_ID = 104 AND Emp_ID = @EMP_ID_Per 
	--		SELECT @PAct_Exe_Cal = SUM(Amount_Col_Final) FROM #Tax_Report WHERE Default_Def_Id IN (8,9,11,151,152) AND Emp_ID = @EMP_ID_Per
			
	--		insert into #perquisites_Details
	--		Select @Cmp_ID,@EMP_ID_Per,@fin_year,@PAct_Gross_Cal,@PAct_Exe_Cal
						
	--		UPDATE #Tax_Report
	--		SET Amount_Col_Final = @Perquisit_amount 
	--		WHERE Default_Def_Id = @Cont_Perquisit_Amt AND Emp_ID = @EMP_ID_Per
	
	--FETCH NEXT FROM CUR_Tax_Per INTO @EMP_ID_Per 
	--	END
	--CLOSE CUR_Tax_Per
	--DEALLOCATE CUR_Tax_Per

	---Added by Hardik 30/11/2018 to remove above cursor
	DECLARE @Perquisit_amount AS NUMERIC(18,2)
	SET @Perquisit_amount = 0
	
	insert into #perquisites_Details
	Select Cmp_Id, T.Emp_Id, CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date)AS NVARCHAR), Qry.PAct_Gross_Cal, Qry1.PAct_Exe_Cal
	From #Tax_Report T Left Outer Join
		(Select Emp_Id, Amount_Col_Final As PAct_Gross_Cal  FROM #Tax_Report WHERE Row_ID = 104) Qry ON T.Emp_ID = Qry.Emp_ID Left Outer Join
		(Select Emp_Id, SUM(Amount_Col_Final) As PAct_Exe_Cal FROM #Tax_Report WHERE Default_Def_Id IN (8,9,11,151,152,163,160,164,166) Group by Emp_ID) Qry1 ON T.Emp_ID = Qry1.Emp_ID

	UPDATE #Tax_Report
	SET Amount_Col_Final = @Perquisit_amount 
	WHERE Default_Def_Id = @Cont_Perquisit_Amt
	
	---End by Hardik 30/11/2018 to remove above cursor

	
	UPDATE #Tax_Report SET Amount_Col_Final = 0   WHERE Row_ID = 107
	
	UPDATE #Tax_Report
	SET Amount_Col_Final = Final_Exemption_Amount
	FROM #Tax_Report tr INNER JOIN 
	
	( SELECT t.Emp_ID,t.Row_ID, CASE WHEN q.Amount_Col_Final > t.Amount_Col_Final AND t.Amount_Col_Final > 0 THEN
								t.Amount_Col_Final
						   ELSE
								q.Amount_Col_Final
						   END  Final_Exemption_Amount
							
	FROM #Tax_Report t INNER JOIN 
	 ( SELECT Amount_Col_Final,Exem_Againt_Row_ID,Emp_ID FROM #Tax_Report WHERE ISNULL(Exem_Againt_Row_ID,0) >0 AND Amount_Col_Final >0)q 
	 ON t.Row_ID =q.Exem_Againt_Row_ID AND t.Emp_Id =q.emp_ID) q1 ON tr.Exem_Againt_Row_ID =q1.Row_ID AND tr.Emp_Id =q1.emp_ID
	
	
	--SET  @IS_TOTAL   =0
	--SET  @ROW_ID	   =0
	--SET   @From_Row_ID    =0
	--SET   @TO_ROW_ID	  =0
	--SET   @Multiple_Row_ID	= ''
	--SET  @Max_Limit		  =0
	--SET  @Max_Limit_Compare_Row_ID	  =0
	--SET   @Max_Limit_Compare_Type	= ''
	--SET   @sqlQuery = ''
  
 
	--DECLARE CUR_T CURSOR FOR 
	--	SELECT IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
	--			Max_Limit_Compare_Type 
	--	FROM #Tax_Report  WHERE IS_TOTAL > 0
	--	ORDER BY Row_ID
	--OPEN CUR_T 
	--FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type 
	--WHILE @@FETCH_STATUS =0
	--	BEGIN
	--		SET @sqlQuery =''
	--		IF @is_Total =1 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
	--			BEGIN
	--				UPDATE #Tax_Report
	--				SET Amount_Col_Final =ISNULL(Q.sum_amount,0)
	--				FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,SUM(Amount_Col_Final)Sum_amount FROM #Tax_Report WHERE
	--					Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID AND t.Row_ID =@Row_ID							
	--			END
	--		ELSE IF @is_Total =1  AND RTRIM(@Multiple_Row_ID) <> ''
	--			BEGIN

	--					UPDATE #Tax_Report
	--								SET Amount_Col_Final =ISNULL(Q.sum_amount,0)
	--								FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,SUM(Amount_Col_Final)Sum_amount FROM #Tax_Report WHERE
	--								Row_ID IN (SELECT DATA FROM dbo.Split(@Multiple_Row_ID,'#') WHERE DATA >0) GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID AND t.Row_ID =@Row_ID 
									
	--			END
	--		ELSE IF @is_Total =2 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
	--			BEGIN
	--				UPDATE #Tax_Report
	--				SET Amount_Col_Final =ISNULL(Q.First_Amount,0) - ISNULL(Q1.Second_Amount,0)
	--				FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS First_Amount  FROM #Tax_Report WHERE
	--					Row_ID =@From_Row_ID )Q  ON t.emp_ID =q.Emp_ID 
	--					INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS Second_Amount  FROM #Tax_Report WHERE
	--					Row_ID =@To_row_ID )Q1  ON t.emp_ID =Q1.Emp_ID 
	--				WHERE t.Row_ID =@Row_ID													
																
	--			END
	--		ELSE IF @is_Total = 3 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 AND @Max_Limit > 0
	--			BEGIN
					
	--				UPDATE #Tax_Report
	--				SET Amount_Col_Final = 
	--				CASE WHEN ISNULL(Q.Sum_amount,0)  <= @Max_Limit THEN
	--							ISNULL(Q.Sum_amount,0)
	--					 WHEN  ISNULL(Q.Sum_amount,0) > 0 THEN
	--							@Max_Limit
	--					ELSE
	--						0
	--					END 
	--				FROM #Tax_Report t INNER JOIN  (SELECT Emp_ID ,ISNULL(SUM(Amount_Col_Final),0)Sum_amount FROM #Tax_Report WHERE
	--					Row_ID >=@From_Row_ID AND Row_ID <=@To_Row_ID GROUP BY Emp_ID )Q  ON t.emp_ID =q.Emp_ID
	--				WHERE t.Row_ID =@Row_ID												
												

				 
																																	
	--			END
	--		ELSE IF @is_Total = 3 AND @FROM_ROW_ID > 0 AND @To_row_ID > 0 
	--			BEGIN
					
					
	--				UPDATE #Tax_Report
	--				SET Amount_Col_Final =
	--				CASE WHEN ISNULL(Q.First_Amount,0)  <=   ISNULL(Q1.Second_Amount,0) THEN
	--							ISNULL(Q.First_Amount,0)
	--					ELSE
	--							ISNULL(Q1.Second_Amount,0)
	--					END 
	--				FROM #Tax_Report t INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS First_Amount  FROM #Tax_Report WHERE
	--					Row_ID =@From_Row_ID )Q  ON t.emp_ID =q.Emp_ID 
	--					INNER JOIN (SELECT Emp_ID ,Amount_Col_Final AS Second_Amount  FROM #Tax_Report WHERE
	--					Row_ID =@To_row_ID )Q1  ON t.emp_ID =Q1.Emp_ID 
	--				WHERE t.Row_ID =@Row_ID													
																
	--			END
			
	--		FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type
	--	END
	--CLOSE cur_T 
	--DEALLOCATE Cur_T	
	
 
   -- UPDATE #Tax_Report 
   --   SET Amount_Col_Final = M_AD_Amount 
   --   FROM #Tax_Report  t INNER JOIN T0210_Monthly_AD_Detail mad ON t.emp_ID =mad.Emp_ID 
   --   AND t.IT_Month = MONTH(Mad.To_Date) AND t.IT_Year = YEAR(Mad.To_Date) INNER JOIN
	  --T0050_AD_MAster am ON mad.AD_ID= am.AD_ID AND AD_DEF_ID=1 AND mad.M_AD_Amount > 0
	
	
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
	
	--DECLARE CUR_TAX CURSOR FOR 
	--	SELECT EMP_ID ,Amount_Col_Final,Increment_ID FROM #Tax_Report 	WHERE field_type = 2	
	--OPEN CUR_TAX 
	--FETCH NEXT FROM CUR_TAX INTO @EMP_ID ,@TAXABLE_AMOUNT,@Increment_ID
	--WHILE @@FETCH_STATUS =0
	--	BEGIN
	--		SET @Return_Tax_Amount		= 0
	--		SET @Surcharge_amount		= 0 
	--		SET @ED_Cess				= 0
	--		SET @TAXABLE_AMOUNT_Inc		= 0 
	--		SET @Return_Tax_Amount_Inc	= 0
	--		SET @Surcharge_amount_Inc	= 0 
	--		SET @ED_Cess_Inc			= 0
	--		SET @Incentive_Amount		= 0		
       
	--		SELECT @Incentive_Amount = ISNULL(SUM(Amount_Col_Final),0) FROM #Tax_Report WHERE Emp_ID =@Emp_ID AND isnull(Is_Incentive,0) = 1  --ISNULL(Is_Salary_comp,0) = 1 
		
				
	--		IF @Incentive_Amount > 0 
	--			BEGIN					
	--				SET @TAXABLE_AMOUNT_Inc = @TAXABLE_AMOUNT - @Incentive_Amount
	--				EXEC dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date,@TAXABLE_AMOUNT_Inc ,@Return_Tax_Amount_Inc OUTPUT
	--						,@Surcharge_amount_Inc OUTPUT ,@ED_Cess_Inc OUTPUT ,@ED_Cess_Per ,@SurCharge_Per, @Relief_87A_Amount output
					
	--				select @Return_Tax_Amount_Inc,@TAXABLE_AMOUNT_Inc

	--				SET @Return_Tax_Amount_Inc = @Return_Tax_Amount_Inc + @ED_Cess_Inc
	--			END 
              
            
	--		EXECUTE dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date,@TAXABLE_AMOUNT ,@Return_Tax_Amount OUTPUT
	--					,@Surcharge_amount OUTPUT ,@ED_Cess OUTPUT ,@ED_Cess_Per ,@SurCharge_Per, @Relief_87A_Amount output
			 
							
	--		UPDATE #Tax_Report 
	--		SET Amount_Col_Final = @Return_Tax_Amount 
	--		WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_Tax

	--		--------- Relief_87A_Amount Add By Hasmukh 20-Dec-13------------
	--		declare @Actual_IT_Amount as numeric(18,2)
	--		DECLARE @Sec_87A_Amount NUMERIC(18,2)
			
			
	--		SET @Sec_87A_Amount = 2000
							
	--		IF @Relief_87A_Amount > 0 and year(@To_Date) >= 2014
	--			begin
	--				Update #Tax_Report 
	--				set Amount_Col_Final = Amount_Col_Final + @Sec_87A_Amount
	--				where Emp_ID =@Emp_ID and Default_Def_ID = 101
				
	--				select @Actual_IT_Amount = Amount_Col_Final from #Tax_Report
	--				where Emp_ID =@Emp_ID and Default_Def_ID = 101
							
	--				Update #Tax_Report 
	--				set Amount_Col_Final = @Sec_87A_Amount 
	--				where Emp_ID =@Emp_ID and Default_Def_ID = -102
									
	--				Update #Tax_Report 
	--				set Amount_Col_Final = @Actual_IT_Amount - @Sec_87A_Amount
	--				where Emp_ID =@Emp_ID and Default_Def_ID = -103
	--			end	
	--		-------------------End---------------------------
			
	--		UPDATE #Tax_Report 
	--		SET Amount_Col_Final = @ED_Cess 
	--		WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_ED_Cess
			
	--		SET @Other_Paid_TDS_Amont = 0
 --           SELECT @Other_Paid_TDS_Amont = ISNULL(SUM(Amount),0) FROM T0100_IT_DECLARATION ID 
	--				LEFT OUTER JOIN	T0070_IT_MASTER IM ON ID.IT_ID = IM.IT_ID AND IM.cmp_id = IM.cmp_id 
	--		WHERE Emp_ID =@Emp_ID AND For_Date >=@From_Date AND for_Date <=@To_Date AND For_Date <=@Month_En_Date AND IM.IT_Def_ID = 10 
			
	--		UPDATE #Tax_Report 
	--		SET Amount_Col_Final = @Other_Paid_TDS_Amont 
	--		WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Less_TDS )
			
	--		UPDATE #Tax_Report 
	--		SET Amount_Col_Final = (@Return_Tax_Amount + @ED_Cess) - @Other_Paid_TDS_Amont -- - @Relief_amount
	--		WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_tax_Lia

	--		SET @Return_Tax_Amount  = (@Return_Tax_Amount + @ED_Cess) - @Other_Paid_TDS_Amont --- @Relief_amount
		
	--		SET @M_AD_Amount = 0
	--		SELECT @M_AD_Amount = ISNULL(SUM(M_AD_Amount),0)  FROM T0210_Monthly_AD_Detail mad INNER JOIN
	--				T0050_AD_MAster am ON mad.AD_ID= am.AD_ID AND mad.cmp_id = am.cmp_id AND AD_DEF_ID = 1
	--		WHERE Emp_ID =@Emp_ID AND To_Date >=@From_Date AND To_Date <=@To_Date AND To_Date <=@Month_En_Date
           
		
	--		UPDATE #Tax_Report 			
	--		SET Amount_Col_Final = @Return_Tax_Amount + @Other_Paid_TDS_Amont  ,Y_Surcharge_Amount =@Surcharge_amount,Y_Edu_Cess_Amount=@ED_Cess			            --+ @Relief_amount
	--					,Y_IT_Paid_Amount = @M_AD_Amount,Total_Taxable_Amount =@TAXABLE_AMOUNT						
	--					,Incentive_Tax = @Return_Tax_Amount_Inc , Incentive_Tax_Amount =@Incentive_Amount		
	--		WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Net_Lia)
									
	--		UPDATE #Tax_Report 
	--		SET Amount_Col_Final = @M_AD_Amount 
	--		WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Paid_Tax )
		
	--		UPDATE #Tax_Report 
	--		SET Amount_Col_Final = @Return_Tax_Amount - @M_AD_Amount 
	--		WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Due_Tax )


 --             UPDATE #Tax_Report 
	--		SET Y_IT_Paid_Amount  = Y_IT_Paid_Amount + @Other_Paid_TDS_Amont --+ @Relief_amount 
	--		WHERE Emp_ID =@Emp_ID AND (Default_Def_ID = @Cont_Net_Lia )
		
	--		FETCH NEXT FROM CUR_TAX INTO @EMP_ID ,@TAXABLE_AMOUNT,@Increment_ID		
	--	END
	--CLOSE CUR_TAX
	--DEALLOCATE CUR_TAX 
	
	

	--UPdate #Tax_Report 
	--set Amount_Col_Final = SALARY_AMOUNT
	--From #Tax_Report Tr inner join (SELECT MS.EMP_ID ,SUM(MS.SALARY_AMOUNT)SALARY_AMOUNT FROM 
	--										T0200_MONTHLY_SALARY MS INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
	--										WHERE MS.MONTH_sT_DATE >=@FROM_DATE AND MS.MONTH_ST_DATE <=@TO_DATE 
	--									GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	--WHERE DEFAULT_DEF_ID =@Cont_Annual_Sal


  
	--UPDATE #Tax_Report
	--SET Amount_col_1 = Amount_Col_Final
	--WHERE ISNULL(Col_No,0) IN(0,1)
	

	--UPDATE #Tax_Report
	--SET Amount_col_2 = Amount_Col_Final
	--WHERE ISNULL(Col_No,0) =2

	--UPDATE #Tax_Report
	--SET Amount_col_3 = Amount_Col_Final
	--WHERE ISNULL(Col_No,0) =3

	--UPDATE #Tax_Report
	--SET Amount_col_4 = Amount_Col_Final
	--WHERE ISNULL(Col_No,0) = 4

			--UPDATE #Tax_Report
			--SET Exempted_Amount = q.Amount_Col_Final
			--FROM #Tax_Report t INNER JOIN 
			-- ( SELECT Amount_Col_Final,Exem_Againt_Row_ID,Emp_ID FROM #Tax_Report WHERE ISNULL(Exem_Againt_Row_ID,0) >0 AND Amount_Col_Final >0)q 
			-- ON t.Row_Id =q.Exem_Againt_Row_ID AND t.Emp_Id =q.emp_ID
	 
			-- Changed By Ali 22112013 EmpName_Alias
			--SELECT  Row_ID,SPACE(Concate_Space)+ FIELD_NAME AS  FIELD_NAME,Amount_Col_Final,Amount_Col_1,Amount_Col_2,Amount_Col_3,Amount_Col_4,Default_def_ID,AD_ID,IT_ID 
			--		,tr.Emp_ID,em.Emp_Code,em.Alpha_Emp_Code,ISNULL(EM.EmpName_Alias_Tax,EM.Emp_Full_Name) as Emp_Full_Name
			--FROM #Tax_Report tr LEFT OUTER JOIN T0080_EMP_MASTER EM ON TR.EMP_ID = EM.EMP_ID INNER JOIN  
				
			--	(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I INNER JOIN     
			--	(SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment    
			--		WHERE Increment_Effective_date <= @To_Date    
			--			AND Cmp_ID = @Cmp_ID    
			--			GROUP BY emp_ID  ) Qry ON    
			--	I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date  ) I_Q  ON EM.Emp_ID = I_Q.Emp_ID 
			--	LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM ON I_Q.Desig_Id = DM.Desig_ID
			--	---Where Is_Show =1
			--ORDER BY tr.Emp_ID ,tr.Row_ID	
			
			--select * from #perquisites_Details			

	RETURN


