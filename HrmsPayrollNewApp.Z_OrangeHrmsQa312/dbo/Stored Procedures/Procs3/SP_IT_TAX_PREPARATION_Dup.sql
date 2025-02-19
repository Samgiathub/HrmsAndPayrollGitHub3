CREATE PROCEDURE [dbo].[SP_IT_TAX_PREPARATION_Dup] @Cmp_ID NUMERIC
, @From_Date DATETIME
, @To_Date DATETIME
, @Branch_ID VARCHAR(MAX) = ''
, @Cat_ID VARCHAR(MAX) = ''
, @Grd_ID VARCHAR(MAX) = ''
, @Type_ID VARCHAR(MAX) = ''
, @Dept_ID VARCHAR(MAX) = ''
, @Desig_Id VARCHAR(MAX) = ''
, @Emp_ID NUMERIC
, @Constraint VARCHAR(MAX)
, @Product_ID NUMERIC
, @Taxable_Amount_Cond NUMERIC = 0
, @Format_Name VARCHAR(50) = 'Format1'
, @Form_ID NUMERIC = 0
, @Sp_Call_For VARCHAR(50) = ''
, @Month_En_Date DATETIME = NULL
, @Month_St_Date DATETIME = NULL
, @Salary_Cycle_id NUMERIC = 0
, @Segment_ID VARCHAR(MAX) = ''
, @Vertical VARCHAR(MAX) = ''
, @SubVertical VARCHAR(MAX) = ''
, @subBranch VARCHAR(MAX) = ''
, @Show_Hidden_Allowance BIT = 1   --Added by Jaina 16-05-2017
, @IT_Declaration_Calc_On VARCHAR(30) = 'On_Regular'--'On_Approved'   --Added by Hardik 06/03/2019 --- 3 Types : "On_Regular", "On_Provisional", "On_Approved"
, @For_Regime VARCHAR(MAX) = ''  --Added by Jaina 31-08-2020
AS
  SET NOCOUNT ON;
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET ARITHABORT ON

  SET @Show_Hidden_Allowance = 0

  DECLARE @Cont_Basic_Sal TINYINT
  DECLARE @Cont_Gratuity_Sal TINYINT	--Ankit 09122015
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
  DECLARE @Relief_sec_87 NUMERIC(18, 2)
  DECLARE @Relief_sec_87_limit NUMERIC(18, 2)
  DECLARE @Cont_Notice_Pay TINYINT
  DECLARE @Cont_OT_Amount NUMERIC(18, 2)
  DECLARE @Cont_Production_Bonus TINYINT
  DECLARE @Cont_Production_Variable TINYINT
  DECLARE @Cont_Standard_Deduction TINYINT
  DECLARE @Cont_Net_Round_Amount TINYINT
  DECLARE @Cont_Travel_Settlement_Amount TINYINT

  SET @Cont_Basic_Sal = 1
  SET @Cont_OT_Amount = 4
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

  SET @Relief_sec_87 = 2000
  SET @Relief_sec_87_limit = 500000

  --added by deepal on 06092023
  DECLARE @ConstEmpid AS NUMERIC
  SET @ConstEmpid = @Emp_ID

  --if @Emp_ID <> 0
  --begin
  --	set @Emp_ID = 0
  --end
  --added by deepal on 06092023

  IF ISNULL(@Month_En_Date, '') = ''
  BEGIN
    SET @Month_En_Date = @To_Date
  END
  IF ISNULL(@Month_St_Date, '') = ''
  BEGIN
    SET @Month_St_Date = @From_Date
  END

  --Ankit 17072014--

  DECLARE @fin_year AS NVARCHAR(20)
  SET @fin_year = ''
  --SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)  

  DECLARE @Fn_Start_Date AS DATETIME
  DECLARE @Fn_ENd_Date AS DATETIME

  SELECT
    @Fn_Start_Date = dbo.GET_YEAR_START_DATE(YEAR(@From_Date), MONTH(@From_Date), 0)
  SELECT
    @Fn_ENd_Date = dbo.GET_YEAR_END_DATE(YEAR(@To_Date), MONTH(@To_Date), 0)

  SET @fin_year = CAST(YEAR(@Fn_Start_Date) AS NVARCHAR) + '-' + CAST(YEAR(@Fn_ENd_Date) AS NVARCHAR)

  IF NOT EXISTS (SELECT
        1
      FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
      WHERE Cmp_ID = @Cmp_ID
      AND Financial_Year = @fin_year)
  BEGIN
    DECLARE @Error_Msg AS VARCHAR(100)
    SET @Error_Msg = '@@IT Form Design of Financial Year ' + @fin_year + +' does not Exists.@@'
    RAISERROR (@Error_Msg, 16, 1)
    RETURN
  END

  CREATE TABLE #Emp_Cons (
    Emp_ID NUMERIC
   ,Branch_ID NUMERIC
   ,Increment_ID NUMERIC
  )

  EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID
                                         ,@From_Date
                                         ,@To_Date
                                         ,@Branch_ID
                                         ,@Cat_ID
                                         ,@Grd_ID
                                         ,@Type_ID
                                         ,@Dept_ID
                                         ,@Desig_Id
                                         ,@Emp_ID
                                         ,@Constraint
                                         ,0
                                         ,@Salary_Cycle_id
                                         ,@Segment_ID
                                         ,@Vertical
                                         ,@SubVertical
                                         ,@subBranch
                                         ,0
                                         ,0
                                         ,0
                                         ,'0'
                                         ,0
                                         ,0

  CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);

  IF EXISTS (SELECT
        1
      FROM [tempdb].dbo.sysobjects
      WHERE name LIKE '#Tax_Report')
  BEGIN
    DROP TABLE #Tax_Report
  END

  IF EXISTS (SELECT
        1
      FROM [TEMPDB].dbo.SYSOBJECTS
      WHERE NAME LIKE '#Tax_Report_Male')
  BEGIN
    DROP TABLE #Tax_Report_Male
  END

  IF EXISTS (SELECT
        1
      FROM [TEMPDB].dbo.SYSOBJECTS
      WHERE NAME LIKE '#Salary_AD')
  BEGIN
    DROP TABLE #Salary_AD
  END

  CREATE TABLE #Tax_Report (
    T_ID NUMERIC IDENTITY (1, 1)
   ,Emp_ID NUMERIC
   ,Cmp_ID NUMERIC(18, 0) NOT NULL
   ,Format_Name VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS
   ,Row_ID INT NOT NULL
   ,Field_Name VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS
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
   ,Y_IT_Paid_Amount NUMERIC DEFAULT 0
   ,Y_Edu_Cess_Amount NUMERIC DEFAULT 0
   ,Y_Surcharge_Amount NUMERIC DEFAULT 0
   ,M_IT_Amount NUMERIC DEFAULT 0
   ,M_Edu_Cess_Amount NUMERIC DEFAULT 0
   ,M_Surcharge_Amount NUMERIC DEFAULT 0
   ,Month_Count NUMERIC DEFAULT 0
   ,Total_TAxable_Amount NUMERIC DEFAULT 0
   ,Final_Tax NUMERIC DEFAULT 0
   ,Total_Amount NUMERIC DEFAULT 0
   ,Incentive_Tax NUMERIC(18, 0)
   ,Incentive_Tax_Amount NUMERIC(18, 0)
   ,Is_Incentive TINYINT
   ,Show_In_SalarySlip TINYINT DEFAULT 0
   ,			--Added by Hardik 19/03/2014
    Display_Name_For_SalarySlip VARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT ''
   ,	--Added by Hardik 19/03/2014
    Column_24Q TINYINT DEFAULT 0
   ,			--Added by Hardik 19/08/2014
    Amount_Col_Actual NUMERIC DEFAULT 0
   ,			--Added By rohit For Actual Value on 04052015
    Amount_Col_Assumed NUMERIC DEFAULT 0
   ,			--Added by rohit For Assumed Value on 04052015
    Tax_Regime VARCHAR(100)					-- Added by Hardik 02/04/2020

  )

  CREATE CLUSTERED INDEX ind_temp1 ON #Tax_Report (T_ID)
  CREATE NONCLUSTERED INDEX ind_temp2 ON #Tax_Report (Row_ID)
  CREATE NONCLUSTERED INDEX ind_temp3 ON #Tax_Report (Emp_ID)
  CREATE NONCLUSTERED INDEX ind_temp4 ON #Tax_Report (Field_Name)
  CREATE NONCLUSTERED INDEX ind_temp5 ON #Tax_Report (Cmp_ID)
  CREATE NONCLUSTERED INDEX ind_temp6 ON #Tax_Report (Default_Def_Id)


  CREATE TABLE #Tax_Report_Male (
    Auto_Row_Id INT IDENTITY (1, 1)
   ,Field_Name VARCHAR(2000) COLLATE SQL_Latin1_General_CP1_CI_AS
   ,Default_Def_Id NUMERIC
   ,T_F_Row_ID INT
   ,T_T_Row_ID INT
   ,IT_Month INT
   ,IT_YEAR INT
   ,IT_L_ID NUMERIC
   ,Is_Show TINYINT DEFAULT 1
   ,Is_TaxPaid_Rec TINYINT DEFAULT 0
   ,Show_In_SalarySlip TINYINT DEFAULT 0
   , --Hardik 20/03/2014
    Display_Name_For_SalarySlip VARCHAR(250) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT ''
   , --Added by Hardik 19/03/2014
    Column_24Q TINYINT DEFAULT 0
   , -- Added by Hardik 19/08/2014
    Gender VARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS DEFAULT '' --Ankit 02052016
  )

  CREATE CLUSTERED INDEX ind_Male_temp1 ON #Tax_Report_Male (Auto_Row_Id)
  CREATE NONCLUSTERED INDEX ind_Male_temp2 ON #Tax_Report_Male (Default_Def_Id)


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
   ,
  )

  CREATE CLUSTERED INDEX Salary_AD_temp1 ON #Salary_AD (Emp_Id, Default_Def_Id, AD_ID)
  --CREATE CLUSTERED INDEX Salary_AD_temp2 ON #Salary_AD(Default_Def_Id)
  --CREATE CLUSTERED INDEX Salary_AD_temp3 ON #Salary_AD(AD_ID)

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

  INSERT INTO #Perq_Detail (Emp_ID, IT_ID, AD_ID, ShowDetails)
    SELECT
      EC.Emp_ID
     ,IT.IT_ID
     ,CAST(T.Data AS INT)
     ,0
    FROM #Emp_Cons EC
    CROSS JOIN T0070_IT_MASTER IT WITH (NOLOCK)
    CROSS APPLY dbo.Split(AD_String, '#') T
    INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK)
      ON T.Data = AM.AD_ID
    WHERE IT_Is_perquisite = 1
    AND IT.Cmp_ID = @Cmp_ID
    AND AD_String IS NOT NULL
    AND AM.Allowance_Type = 'R'
    AND ISNULL(T.Data, '') <> ''



  DECLARE @Max_Row_ID NUMERIC
  DECLARE @Max_From_Row_ID NUMERIC
  DECLARE @T_For_Date DATETIME
  DECLARE @Increment_ID NUMERIC
  DECLARE @Month_Count NUMERIC
  DECLARE @Month_Sal NUMERIC
  DECLARE @Month_Diff NUMERIC
  DECLARE @ED_Cess_Per NUMERIC(5, 2)
  DECLARE @SurCharge_per NUMERIC(5, 2)
  DECLARE @Month_Max_Date DATETIME
  DECLARE @Join_date DATETIME
  DECLARE @Relief_87A_Amount NUMERIC(18, 2)


  SET @SurCharge_per = 0 --10 % Surchage not applicable from 2009-10 (A.Y. 2010-11) and w.e.f. 01.04.2009 comment by Hasmukh 10042012
  SET @Relief_87A_Amount = 0
  SET @ED_Cess_Per = 0

  SELECT
    @ED_Cess_Per = Field_Value
  FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
  WHERE Default_Def_Id = @Cont_ED_Cess
  AND Financial_Year = @fin_year
  AND Cmp_ID = @Cmp_ID

  IF @ED_Cess_Per = 0
  BEGIN
    IF YEAR(@From_Date) < 2018
      SET @ED_Cess_Per = 3
  END



  SET @Month_Count = DATEDIFF(m, @From_Date, @To_Date) + 1

  INSERT INTO #Tax_Report (Emp_ID, Cmp_ID, Format_Name, Row_ID, Field_Name, AD_ID, Rimb_ID, Default_Def_Id, Is_Total, From_Row_ID, To_Row_ID, Multiple_Row_ID, Is_Exempted, Max_Limit
  , Max_Limit_Compare_Row_ID, Max_Limit_Compare_Type, Is_Proof_Req, IT_ID, From_Date, To_Date, Field_Type, Is_Show, Col_No, Concate_Space
  , Is_Salary_comp, Exem_Againt_row_Id, Exempted_Amount, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)

    SELECT
      ec.Emp_ID
     ,I.Cmp_ID
     ,Format_Name
     ,Row_ID
     ,Field_Name
     ,I.AD_ID
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
     ,ISNULL(Concate_Space, 0)
     ,ISNULL(Is_Salary_comp, 0)
     ,ISNULL(Exem_Againt_row_Id, 0)
     ,0
     ,Show_In_SalarySlip
     ,Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN I WITH (NOLOCK)
    LEFT OUTER JOIN  --Added by Jaina 16-05-2017
    T0050_AD_MASTER AD WITH (NOLOCK)
      ON AD.AD_ID = I.AD_ID
    CROSS APPLY #Emp_Cons ec
    WHERE	--ISNULL(Form_ID,0) = @Form_ID AND 
    I.Cmp_ID = @Cmp_ID
    AND Default_Def_Id NOT IN (101, -102, -103, 103, 104, 105, 106, 107, 108, 120, 121, 102)
    AND Row_ID < 1000		 --Hardik		
    AND Financial_Year = @fin_year  --Ankit 17072014
    AND (CASE
      WHEN @Show_Hidden_Allowance = 0 AND
        AD.Hide_In_Reports = 1 THEN 0
      ELSE 1
    END) = 1 --Added by Jaina 16-05-2017

  --SELECT Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
  --							,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,@From_Date,@To_Date ,Field_Type,Is_Show,Col_No,ISNULL(Concate_Space,0) 
  --							,ISNULL(Is_Salary_comp,0),ISNULL(Exem_Againt_row_Id,0),0,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q
  --							FROM T0100_IT_FORM_DESIGN CROSS JOIN #Emp_Cons ec 
  --WHERE	--ISNULL(Form_ID,0) = @Form_ID AND 
  --		Cmp_Id=@Cmp_ID 
  --		And Default_Def_Id not in (101,-102,-103,103,104,105,106,107,108,120,121,102) and row_id <1000		 --Hardik		
  --		AND Financial_Year = @fin_year  --Ankit 17072014



  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      ' '
     ,0
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'Tax Limit '
     ,0
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      ' '
     ,0
     ,1


  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show, Gender)
    SELECT
      '---------------------Male-------------------'
     ,0
     ,1
     ,'M'

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, IT_L_ID, Is_Show, Gender)
    SELECT
      CAST(From_Limit AS VARCHAR(15)) + ' To ' +
      CASE
        WHEN t.To_Limit LIKE '9999%' THEN 'Above'
        ELSE CAST(TO_Limit AS VARCHAR(15))
      END + ' ( ' + CAST(Percentage AS VARCHAR(10)) + ' %) '
     ,0
     ,IT_L_ID
     ,1
     ,'M'
    FROM T0040_tAx_limit t WITH (NOLOCK)
    INNER JOIN (SELECT DISTINCT
        Cmp_ID
       ,MAX(for_Date) For_Date
      FROM T0040_tAx_limit WITH (NOLOCK)
      WHERE Cmp_ID = @Cmp_ID
      AND For_Date <= @To_Date
      AND Gender = 'M'
      GROUP BY Cmp_ID
              ,Regime) q
      ON t.Cmp_ID = q.Cmp_ID
        AND t.for_Date = q.for_Date
        AND Gender = 'M'
    ORDER BY IT_L_ID ASC

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show, Gender)
    SELECT
      '-------------------Female-------------------'
     ,0
     ,1
     ,'F'

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, IT_L_ID, Is_Show, Gender)
    SELECT
      CAST(From_Limit AS VARCHAR(15)) + ' To ' +
      CASE
        WHEN t.To_Limit LIKE '9999%' THEN 'Above'
        ELSE CAST(TO_Limit AS VARCHAR(15))
      END + ' ( ' + CAST(Percentage AS VARCHAR(10)) + ' %) '
     ,0
     ,IT_L_ID
     ,1
     ,'F'
    FROM T0040_tAx_limit t WITH (NOLOCK)
    INNER JOIN (SELECT DISTINCT
        Cmp_ID
       ,MAX(for_Date) For_Date
      FROM T0040_tAx_limit WITH (NOLOCK)
      WHERE Cmp_ID = @Cmp_ID
      AND For_Date <= @To_Date
      AND Gender = 'F'
      GROUP BY Cmp_ID
              ,Regime) q
      ON t.Cmp_ID = q.Cmp_ID
        AND t.for_Date = q.for_Date
        AND Gender = 'F'
    ORDER BY IT_L_ID ASC

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show, Gender)
    SELECT
      '-----------------Senior Citizen------------'
     ,0
     ,0
     ,'S'

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, IT_L_ID, Is_Show, Gender)
    SELECT
      CAST(From_Limit AS VARCHAR(15)) + ' To ' +
      CASE
        WHEN t.To_Limit LIKE '9999%' THEN 'Above'
        ELSE CAST(TO_Limit AS VARCHAR(15))
      END + ' ( ' + CAST(Percentage AS VARCHAR(10)) + ' %) '
     ,0
     ,IT_L_ID
     ,0
     ,'S'
    FROM T0040_tAx_limit t WITH (NOLOCK)
    INNER JOIN (SELECT DISTINCT
        Cmp_ID
       ,MAX(for_Date) For_Date
      FROM T0040_tAx_limit WITH (NOLOCK)
      WHERE Cmp_ID = @Cmp_ID
      AND For_Date <= @To_Date
      AND Gender = 'S'
      GROUP BY Cmp_ID
              ,Regime) q
      ON t.Cmp_ID = q.Cmp_ID
        AND t.for_Date = q.for_Date
        AND Gender = 'S'
    ORDER BY IT_L_ID ASC

  --Added By Jimit 23052018 for case at WCL One Employee's Age is 
  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show, Gender)
    SELECT
      '-----------------Very Senior Citizen------------'
     ,0
     ,0
     ,'V'

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, IT_L_ID, Is_Show, Gender)
    SELECT
      CAST(From_Limit AS VARCHAR(15)) + ' To ' +
      CASE
        WHEN t.To_Limit LIKE '9999%' THEN 'Above'
        ELSE CAST(TO_Limit AS VARCHAR(15))
      END + ' ( ' + CAST(Percentage AS VARCHAR(10)) + ' %) '
     ,0
     ,IT_L_ID
     ,0
     ,'V'
    FROM T0040_tAx_limit t WITH (NOLOCK)
    INNER JOIN (SELECT DISTINCT
        Cmp_ID
       ,MAX(for_Date) For_Date
      FROM T0040_tAx_limit WITH (NOLOCK)
      WHERE Cmp_ID = @Cmp_ID
      AND For_Date <= @To_Date
      AND Gender = 'V'
      GROUP BY Cmp_ID
              ,Regime) q
      ON t.Cmp_ID = q.Cmp_ID
        AND t.for_Date = q.for_Date
        AND Gender = 'V'
    ORDER BY IT_L_ID ASC
  --Ended--

  --Commented by Hardik 20/03/2014
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
  --SELECT '12. Tax on Total Income ',101

  --Added by Hardik 20/03/2014
  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (101)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  IF YEAR(@To_Date) >= 2014
  BEGIN
    --Commented by Hardik 20/03/2014
    --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
    --SELECT '   * Less: Sec. 87A ',-102

    INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
      SELECT
        SPACE(Concate_Space) + Field_Name
       ,Default_Def_Id
       ,Show_In_SalarySlip
       ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
       ,Column_24Q
      FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
      WHERE Default_Def_Id IN (-102)
      AND Cmp_ID = @Cmp_ID
      AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

    --Commented by Hardik 20/03/2014
    --			INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
    --			SELECT '#   Tax on Total Income ',-103

    INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
      SELECT
        SPACE(Concate_Space) + Field_Name
       ,Default_Def_Id
       ,Show_In_SalarySlip
       ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
       ,Column_24Q
      FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
      WHERE Default_Def_Id IN (-103)
      AND Cmp_ID = @Cmp_ID
      AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  END


  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (102)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014


  --	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
  --	select 'Surcharge @10% on Tax ',102

  --	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
  --	select 'Total Tax Liabilities',103


  --Commented by Hardik 20/03/2014
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
  --SELECT '13. Ed. Cess 3%(On Tax Computed At Sr.No.12)',104

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (104)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  --Commented by Hardik 20/03/2014
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
  --SELECT '14. Tax Payable(12 + 13)',105

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (105)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  --Commented by Hardik 20/03/2014
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
  --SELECT '15.(a) Less:Relief Under section 89 (attach details)',121,@Max_From_Row_ID,@Max_Row_ID-1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (121)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (173)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Tejas 24072024

  --Commented by Hardik 20/03/2014
  --	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
  --	SELECT '     (b) Less TDS deducted from other income reported by employee',120,@Max_From_Row_ID,@Max_Row_ID-1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (120)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
  --SELECT '     (c) Less:Relief Under section 87 A',121,@Max_From_Row_ID,@Max_Row_ID-1

  --Commented by Hardik 20/03/2014
  --	INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
  --	SELECT '16. Tax Payable(14 - 15)',103,@Max_From_Row_ID,@Max_Row_ID-1


  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (103)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014


  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'Income Tax Paid Detail'
     ,106
     ,1

  --SELECT @Max_Row_ID = ISNULL(MAX(AUTO_Row_ID),0) + 1  FROM  #Tax_Report_Male

  --SET @Max_From_Row_ID = @Max_Row_ID
  SET @T_For_Date = @From_Date
  WHILE @T_For_Date <= @To_Date
  BEGIN
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR,Is_Show,Is_TaxPaid_Rec	)
  --SELECT DATENAME(m,@T_For_Date),0,MONTH(@T_For_Date),YEAR(@T_For_Date),1,1

  IF @Sp_Call_For = 'Salary Slip'	--Ankit 17022016
  BEGIN
    INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, IT_Month, IT_YEAR, Is_Show, Is_TaxPaid_Rec, Show_In_SalarySlip)
      SELECT
        DATENAME(m, @T_For_Date)
       ,0
       ,MONTH(@T_For_Date)
       ,YEAR(@T_For_Date)
       ,1
       ,1
       ,1
  END
  ELSE
  BEGIN
    INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, IT_Month, IT_YEAR, Is_Show, Is_TaxPaid_Rec)
      SELECT
        DATENAME(m, @T_For_Date)
       ,0
       ,MONTH(@T_For_Date)
       ,YEAR(@T_For_Date)
       ,1
       ,1
  END

  SET @T_For_Date = DATEADD(m, 1, @T_For_Date)
  SET @Max_Row_ID = @Max_Row_ID + 1
  END

  --Commented by Hardik 20/03/2014
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
  --SELECT '17. Less: TDS Paid',107,@Max_From_Row_ID,@Max_Row_ID-1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (107)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  --Commented by Hardik 20/03/2014
  --INSERT INTO #Tax_Report_Male (Field_Name,Default_def_ID)
  --SELECT '18. TAX PAYABLE/REFUNDABLE (16 - 17)',108

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      SPACE(Concate_Space) + Field_Name
     ,Default_Def_Id
     ,Show_In_SalarySlip
     ,SPACE(Concate_Space) + Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    WHERE Default_Def_Id IN (108)
    AND Cmp_ID = @Cmp_ID
    AND Financial_Year = @fin_year  -- Financial_Year --Ankit 17072014

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      ' '
     ,0
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'HOUSE RENT ALLOWANCE EXEMPT'
     ,0
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'Annual Salary ( Exclusive benefits and Perquisites)'
     ,109
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'House Rent Allowance Received'
     ,110
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'Less : Exemption u/s 10 (13A) read with rule 2 A'
     ,0
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      '  A ) House rent allowance Received'
     ,110
     ,1
  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      '  B ) Actual Rent Paid'
     ,112
     ,1
  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      '   Less : 1/10 of Salary'
     ,113
     ,1
  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      '   Different Amount'
     ,114
     ,1
  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      '  C ) I. Two Fifth of Salary (Non Metro)'
     ,115
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      '       II. One Half of Salary (Metro)'
     ,116
     ,1

  INSERT INTO #Tax_Report_Male (Field_Name, Default_def_ID, Is_Show)
    SELECT
      'House rent Allow. Exempted ( least of a,b or c )'
     ,7
     ,1



  SELECT
    @Max_Row_ID = ISNULL(MAX(Row_ID), 0) + 1
  FROM #Tax_Report

  --select * from #Tax_Report_Male
  ---- Ankit 27062016
  INSERT INTO #Tax_Report (Emp_ID, Cmp_ID, Format_Name, Row_ID, Field_Name, AD_ID, Rimb_ID, Default_Def_Id, Is_Total, From_Row_ID, To_Row_ID, Multiple_Row_ID, Is_Exempted, Max_Limit
  , Max_Limit_Compare_Row_ID, Max_Limit_Compare_Type, Is_Proof_Req, IT_ID, From_Date, To_Date, IT_Month, IT_YEAR, IT_L_ID, Is_Show, Is_TaxPaid_Rec,
  Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)
    SELECT
      EC.Emp_ID
     ,@Cmp_ID
     ,@Format_Name
     ,Auto_Row_Id + @Max_Row_ID
     ,Field_Name
     ,NULL
     ,NULL
     ,Default_Def_Id
     ,0
     ,ISNULL(T_F_Row_ID + @Max_Row_ID, 0)
     ,ISNULL(T_T_Row_ID + @Max_Row_ID, 0)
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
     ,IT_YEAR
     ,IT_L_ID
     ,Is_Show
     ,Is_TaxPaid_Rec
     ,Show_In_SalarySlip
     ,Display_Name_For_SalarySlip
     ,Column_24Q
    FROM #Emp_Cons EC
    INNER JOIN (SELECT
        CASE
          WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth, GETDATE(), 'N', 'Y') AS NUMERIC(18, 2)) > 80 THEN 'V'
          WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth, GETDATE(), 'N', 'Y') AS NUMERIC(18, 2)) > 60 THEN 'S'
          ELSE Gender
        END AS Gender
       ,Emp_ID
      FROM T0080_EMP_MASTER WITH (NOLOCK)
      WHERE Cmp_ID = @Cmp_ID) EM
      ON EC.Emp_ID = EM.Emp_ID
    CROSS JOIN #Tax_Report_Male TR
    WHERE EM.Gender = (CASE
      WHEN TR.Gender = '' COLLATE SQL_Latin1_General_CP1_CI_AS THEN EM.Gender
      ELSE TR.Gender COLLATE SQL_Latin1_General_CP1_CI_AS
    END)
    ORDER BY EC.Emp_ID


  --Comment by Jaina 31-08-2020
  ---Added by Hardik 02/04/2020 for New Tax Regime
  --IF YEAR(@FROM_DATE)> 2019
  --	BEGIN
  --		UPDATE T SET Tax_Regime = TAX_REG.Regime 
  --		FROM #Tax_Report T INNER JOIN T0095_IT_Emp_Tax_Regime TAX_REG ON T.Emp_ID = TAX_REG.Emp_ID
  --		WHERE TAX_REG.Financial_Year = @fin_year

  --		DELETE T
  --		FROM #Tax_Report T
  --		WHERE 
  --			NOT EXISTS (SELECT 1 FROM T0040_TAX_LIMIT TL WHERE T.IT_L_ID = TL.IT_L_ID AND T.Tax_Regime = TL.Regime) AND
  --			T.IT_L_ID IS NOT NULL 

  --	END
  --Added by Jaina 31-08-2020
  --if @For_Regime != ''


  BEGIN



    IF YEAR(@From_Date) > 2019
    BEGIN

      IF EXISTS (SELECT
            1
          FROM T0095_IT_Emp_Tax_Regime R WITH (NOLOCK)
          INNER JOIN #Emp_Cons Ec
            ON R.Emp_ID = Ec.Emp_ID)
      BEGIN

        UPDATE T
        SET Tax_Regime = TAX_REG.Regime
        FROM #Tax_Report T
        INNER JOIN T0095_IT_Emp_Tax_Regime TAX_REG WITH (NOLOCK)
          ON T.Emp_ID = TAX_REG.Emp_ID
        WHERE TAX_REG.Financial_Year = @fin_year


      END
      ELSE
      BEGIN

        UPDATE T
        SET Tax_Regime = @For_Regime
        FROM #Tax_Report T
        WHERE Emp_ID = @Emp_ID
      END

      ---- Added below update query by Hardik 19/10/2020 for WCL as if employee has not selected any Regime then default use Tax Regime 1 and calculate Tax as per Old regime




      --UPDATE T SET Tax_Regime =( case when To_Date <='2023-03-31' then 'Tax Regime 1' when To_Date >='2023-04-01' then  'Tax Regime 2' else 'Tax Regime 2'  end )
      --FROM #Tax_Report T Where (Tax_Regime Is null or Tax_Regime='0') --And To_Date <='2023-03-31' --Added by ronakk 14042023(Sajid Changes)



      UPDATE T
      SET Tax_Regime = (CASE
        WHEN @For_Regime = 'Tax Regime 1' THEN 'Tax Regime 1'
        WHEN @For_Regime = 'Tax Regime 2' THEN 'Tax Regime 2'
        ELSE CASE
            WHEN To_Date <= '2023-03-31' THEN 'Tax Regime 1'
            WHEN To_Date >= '2023-04-01' THEN 'Tax Regime 2'
          END
      END)
      FROM #Tax_Report T
      WHERE (Tax_Regime IS NULL
      OR Tax_Regime = '0') --And To_Date <='2023-03-31' --Added by ronakk 14042023(Sajid Changes)

      ----FROM #Tax_Report T Where Tax_Regime Is null  --Comment by ronakk 14042023

      -- Added below update query by Hardik 19/10/2020 for WCL as if employee has not selected any Regime then default use Tax Regime 1 and calculate Tax as per Old regime
      --UPDATE T SET Tax_Regime = 'Tax Regime 1'
      --FROM #Tax_Report T Where (Tax_Regime Is null or Tax_Regime=0) And To_Date <='2023-03-31'

      ----Added by ronakk 15042023(Sajid Changes)
      --If YEAR(@From_Date) < 2023 AND  (@For_Regime IS NULL OR @For_Regime='')
      --BEGIN 
      --UPDATE T SET Tax_Regime ='Tax Regime 1'
      --FROM #Tax_Report T Where (Tax_Regime Is null or Tax_Regime=0)
      --END
      --If YEAR(@From_Date) >=2023 AND (@For_Regime IS NULL OR @For_Regime='')
      --BEGIN
      --UPDATE T SET Tax_Regime ='Tax Regime 2' 
      --FROM #Tax_Report T Where (Tax_Regime Is null or Tax_Regime=0)
      --END
      ----Added by ronakk 15042023(Sajid Changes)

      DELETE T
        FROM #Tax_Report T
      WHERE NOT EXISTS (SELECT
            1
          FROM T0040_TAX_LIMIT TL WITH (NOLOCK)
          WHERE T.IT_L_ID = TL.IT_L_ID
          AND T.Tax_Regime = TL.Regime)
        AND T.IT_L_ID IS NOT NULL

    END

  END


  ----Below Code Comment by Ankit 27062016
  --INSERT INTO #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
  --							,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,IT_Month,IT_YEAR,IT_L_ID,Is_Show,Is_TaxPaid_Rec,
  --							Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q)
  --SELECT Emp_ID,@Cmp_ID,@Format_Name,Auto_Row_Id + @Max_Row_ID ,Field_Name,NULL,NULL,Default_Def_Id,0,ISNULL(T_F_Row_ID + @Max_Row_ID,0) ,ISNULL(T_T_Row_ID + @Max_Row_ID,0),'',0,0
  --							,0,0,0,NULL,@From_Date,@To_Date,IT_Month,IT_Year,IT_L_ID,Is_Show ,Is_TaxPaid_Rec,Show_In_SalarySlip,Display_Name_For_SalarySlip,Column_24Q
  -- FROM #Tax_Report_Male CROSS JOIN #Emp_Cons
  ----------	

  INSERT INTO #Tax_Report (Emp_ID, Cmp_ID, Format_Name, Row_ID, Field_Name, AD_ID, Rimb_ID, Default_Def_Id, Is_Total, From_Row_ID, To_Row_ID, Multiple_Row_ID, Is_Exempted, Max_Limit
  , Max_Limit_Compare_Row_ID, Max_Limit_Compare_Type, Is_Proof_Req, IT_ID, From_Date, To_Date, Field_Type, Is_Show, Col_No, Concate_Space
  , Is_Salary_comp, Exem_Againt_row_Id, Exempted_Amount, Show_In_SalarySlip, Display_Name_For_SalarySlip, Column_24Q)

    SELECT
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
     ,@From_Date
     ,@To_Date
     ,Field_Type
     ,Is_Show
     ,Col_No
     ,ISNULL(Concate_Space, 0)
     ,ISNULL(Is_Salary_comp, 0)
     ,ISNULL(Exem_Againt_row_Id, 0)
     ,0
     ,Show_In_SalarySlip
     ,Display_Name_For_SalarySlip
     ,Column_24Q
    FROM T0100_IT_FORM_DESIGN WITH (NOLOCK)
    CROSS JOIN #Emp_Cons ec
    WHERE --ISNULL(Form_ID,0) = @Form_ID AND 
    Cmp_ID = @Cmp_ID
    AND Row_ID >= 1000		 --Hardik		
    AND Financial_Year = @fin_year  --Ankit 17072014


  UPDATE #Tax_Report
  SET Month_Count =
  CASE
    WHEN Date_OF_Join > @From_Date AND
      ISNULL(Emp_Left_Date, @To_Date) >= @To_Date THEN DATEDIFF(m, Date_OF_Join, @To_Date) + 1
    WHEN Date_OF_Join > @From_Date AND
      ISNULL(Emp_Left_Date, @To_Date) < @To_Date THEN DATEDIFF(m, Date_OF_Join, Emp_Left_Date) + 1
    WHEN Date_OF_Join <= @From_Date AND
      ISNULL(Emp_Left_Date, @To_Date) < @To_Date THEN DATEDIFF(m, @From_Date, Emp_Left_Date) + 1
    ELSE DATEDIFF(m, @From_Date, @To_Date) + 1
  END

  FROM #Tax_Report t
  INNER JOIN T0080_emp_Master e WITH (NOLOCK)
    ON t.Emp_ID = e.Emp_ID
  WHERE Month_Count = 0

  --UPDATE	#Tax_Report 
  --SET		Increment_ID = Q.Increment_ID 
  --FROM	#Tax_Report t 
  --		INNER JOIN (SELECT	I.Emp_Id ,I.Increment_ID 
  --					FROM	T0095_Increment I 
  --							INNER JOIN (SELECT	MAX(I.Increment_ID) AS Increment_ID , I.Emp_ID 
  --										FROM	T0095_Increment I 
  --												Inner Join #Emp_Cons EC on I.Emp_ID = EC.Emp_ID	-- Ankit 11092014 for Same Date Increment
  --										WHERE	Increment_Effective_date <= @To_Date and increment_type <> 'Transfer'
  --												AND Cmp_ID = @Cmp_ID
  --										GROUP BY I.emp_ID
  --										) Qry ON I.Emp_ID = Qry.Emp_ID	AND I.Increment_ID = Qry.Increment_ID	
  --					WHERE Cmp_ID = @Cmp_ID
  --					)Q ON t.emp_ID =q.Emp_ID 


  --Commnented By jimit 30012018 and added By Jimit as there is case at WCL (not getting latest Increment)
  UPDATE #Tax_Report
  SET Increment_ID = Q.Increment_ID
  FROM #Tax_Report T
  INNER JOIN (SELECT
      I1.Emp_Id
     ,I1.Increment_ID
    FROM T0095_INCREMENT I1 WITH (NOLOCK)
    INNER JOIN (SELECT
        MAX(I2.Increment_ID) AS Increment_ID
       ,I2.Emp_ID
      FROM T0095_Increment I2 WITH (NOLOCK)
      INNER JOIN #Emp_Cons E
        ON I2.Emp_ID = E.Emp_ID
      INNER JOIN (SELECT
          MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
         ,I3.EMP_ID
        FROM T0095_INCREMENT I3 WITH (NOLOCK)
        INNER JOIN #Emp_Cons E
          ON I3.Emp_ID = E.Emp_ID
        WHERE I3.INCREMENT_EFFECTIVE_DATE <= @To_Date
        AND I3.Cmp_ID = @Cmp_ID
        AND I3.increment_type <> 'Transfer'
        AND INCREMENT_TYPE <> 'DEPUTATION'
        GROUP BY I3.EMP_ID) I3
        ON I2.INCREMENT_EFFECTIVE_DATE = I3.INCREMENT_EFFECTIVE_DATE
        AND I2.EMP_ID = I3.Emp_ID
      WHERE INCREMENT_TYPE <> 'TRANSFER'
      AND INCREMENT_TYPE <> 'DEPUTATION'
      GROUP BY I2.Emp_ID) I
      ON I1.Emp_ID = I.Emp_ID
      AND I1.Increment_ID = I.Increment_ID
    WHERE Cmp_ID = @Cmp_ID) Q
    ON T.emp_ID = Q.Emp_ID


  --select * from #Tax_Report where Row_ID=317
  

  ------------------ Allowance Exemption ---------------
  DECLARE @TAX_REGIME VARCHAR(50)

  DECLARE CUR_AD_Tax CURSOR FAST_FORWARD FOR SELECT DISTINCT
    t.EMP_ID
   ,t.Increment_ID
   ,Month_Count
   ,Tax_Regime
  FROM #Tax_Report t --INNER JOIN T0080_emp_master e ON t.emp_ID = e.emp_ID	
  OPEN CUR_AD_Tax
  FETCH NEXT FROM CUR_AD_Tax INTO @Emp_ID, @Increment_ID, @Month_Count, @TAX_REGIME
  WHILE @@FETCH_STATUS = 0
  BEGIN

  SET @Month_Sal = 0

  SELECT
    @Month_Sal = ISNULL(COUNT(emp_ID), 0)
  FROM T0200_Monthly_Salary WITH (NOLOCK)
  WHERE Emp_ID = @Emp_ID
  AND Month_End_Date >= @From_Date
  AND Month_End_Date <= @To_Date
  AND Month_End_Date <= @Month_En_Date
  SELECT
    @Month_Max_Date = MAX(Month_End_Date)
  FROM T0200_Monthly_Salary WITH (NOLOCK)
  WHERE Emp_ID = @Emp_ID
  AND Month_End_Date >= @From_Date
  AND Month_End_Date <= @To_Date
  AND Month_End_Date <= @Month_En_Date
  SELECT
    @Join_date = date_of_join
  FROM T0080_EMP_MASTER WITH (NOLOCK)
  WHERE emp_id = @Emp_ID

  DECLARE @temp_date AS DATETIME
  DECLARE @mon_count_actual AS NUMERIC
  DECLARE @mon_sal_not_done AS NUMERIC

  SET @mon_sal_not_done = 0


  IF @From_Date < @Join_date
    AND ISNULL(@Month_Max_Date, @From_Date) = @From_Date
    SET @Month_Max_Date = ISNULL(@Month_Max_Date, @Join_date)
  ELSE
  IF ISNULL(@Month_Max_Date, @From_Date) = @From_Date
    SET @Month_Max_Date = ISNULL(@Month_Max_Date, @From_Date)

  IF @From_Date < @Join_date
    SET @temp_date = @Join_date
  ELSE
    SET @temp_date = @From_Date

  --if datepart(dd,@temp_date) > 1
  --set @mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date) + 1
  --else
  -- set @mon_count_actual = DATEDIFF(mm,@temp_date ,@Month_Max_Date)
  IF @Month_Max_Date = @Join_date
    OR @Month_Max_Date = @From_Date
  BEGIN
    SET @mon_count_actual = DATEDIFF(mm, @temp_date, @Month_Max_Date)
  END
  ELSE
  BEGIN
    SET @mon_count_actual = DATEDIFF(mm, @temp_date, @Month_Max_Date) + 1
  END

  SET @mon_sal_not_done = @mon_count_actual - @Month_Sal

  IF @mon_sal_not_done < 0
    SET @mon_sal_not_done = 1

  IF (@Month_Count - @Month_Sal - @mon_sal_not_done) > 0
    AND @Sp_Call_For <> 'Export_For_Actual'
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
  --	end
  END
  ELSE
  BEGIN
    SET @Month_Diff = 0
  END


  
  



  EXEC dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @Emp_ID
                                           ,@Cmp_ID
                                           ,@Increment_ID
                                           ,@From_Date
                                           ,@To_Date
                                           ,@Month_Diff
                                           ,@Month_En_Date




  IF ISNULL(@TAX_REGIME, 'Tax Regime 1') = 'Tax Regime 1'
    AND YEAR(@From_Date) < 2023  --Added by ronakk condtion with sajid 14042023
  BEGIN
    EXEC SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID
                                                   ,@Cmp_ID
                                                   ,@Increment_ID
                                                   ,@From_Date
                                                   ,@To_Date
                                                   ,@Month_Diff
                                                   ,0
                                                   ,@IT_Declaration_Calc_On
  END
  ELSE
  IF @TAX_REGIME = 'Tax Regime 1'
    AND YEAR(@From_Date) >= 2023  --Added by ronakk condtion with sajid 14042023
  BEGIN
    EXEC SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID
                                                   ,@Cmp_ID
                                                   ,@Increment_ID
                                                   ,@From_Date
                                                   ,@To_Date
                                                   ,@Month_Diff
                                                   ,0
                                                   ,@IT_Declaration_Calc_On
  END
  ELSE
  BEGIN
    ----Start---Gratuity Exemption------Ankit 05052016
    DECLARE @Cont_Gratuity_Exemp NUMERIC
    DECLARE @Gratuity_Exemp_Amount NUMERIC(18, 2)
    DECLARE @Gratuity_Amount NUMERIC(18, 2)

    SET @Cont_Gratuity_Exemp = 166
    SET @Gratuity_Amount = 0
    SET @Gratuity_Exemp_Amount = 0

    IF EXISTS (SELECT
          1
        FROM #Tax_Report
        WHERE emp_ID = @Emp_ID
        AND default_Def_ID = @Cont_Gratuity_Exemp)
    BEGIN
      EXEC dbo.SP_IT_TAX_GRATUITY_EXEMPTION @Emp_ID
                                           ,@Cmp_ID
                                           ,@From_Date
                                           ,@To_Date
                                           ,@Increment_ID
                                           ,@Gratuity_Amount OUTPUT
                                           ,@Gratuity_Exemp_Amount OUTPUT
    END

    UPDATE #Tax_Report
    SET Amount_Col_Final = @Gratuity_Exemp_Amount
    WHERE Emp_ID = @Emp_ID
    AND Default_Def_ID = @Cont_Gratuity_Exemp

  END

  
  FETCH NEXT FROM CUR_AD_Tax INTO @Emp_ID, @Increment_ID, @Month_Count, @TAX_REGIME
  END
  CLOSE CUR_AD_Tax
  DEALLOCATE CUR_AD_Tax

  -------------------End Allowance	   ---------------
  --SELECT amount_col_final, * FROM #Tax_Report where Rimb_ID = 676


  UPDATE #Tax_Report
  SET Amount_Col_Final = Max_Limit
  WHERE Is_Exempted = 0
  AND Max_Limit_Compare_Row_ID = 0
  AND Max_Limit > 0
  AND Amount_Col_Final > 0
  AND Amount_Col_Final > Max_Limit


  UPDATE #Tax_Report
  SET Sal_No_Of_Month = E_COUNT
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,COUNT(MS.EMP_ID) E_COUNT
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Cmp_ID = @Cmp_ID
    AND MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Month_End_Date <= @Month_En_Date
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID

	
  


  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0) --isnull(M_AD_Amount,0) + 
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)  -- Added by rohit on 04052015
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0) -- Added by rohit on 04052015
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND sa.Default_Def_ID = @Cont_Basic_Sal
  WHERE Tr.DEFAULT_DEF_ID = @Cont_Basic_Sal

  UPDATE #Tax_Report
  SET Amount_Col_Final = OT_Amount
     ,Amount_Col_Actual = OT_Amount
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,SUM(ISNULL(MS.OT_Amount, 0)) + SUM(ISNULL(MS.M_HO_OT_Amount, 0)) + SUM(ISNULL(MS.M_WO_OT_Amount, 0)) AS OT_Amount
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Cmp_ID = @Cmp_ID
    AND MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Month_End_Date <= @Month_En_Date
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE Tr.DEFAULT_DEF_ID = @Cont_OT_Amount

  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(S_Salary_Amount, 0)
     ,Amount_Col_Actual = ISNULL(Amount_Col_Actual, 0) + ISNULL(S_Salary_Amount, 0)  -- Added by Hardik 08/11/2016 for Ashiana
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,SUM(MS.S_Salary_Amount) S_Salary_Amount
    FROM T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Cmp_ID = @Cmp_ID
    AND MS.S_Eff_Date >= @From_Date
    AND MS.S_Eff_Date <= @To_Date
    AND MS.S_Eff_Date <= @Month_En_Date
    AND EXISTS (SELECT
        1
      FROM T0200_MONTHLY_SALARY MS1 WITH (NOLOCK)
      WHERE MS1.Cmp_ID = @Cmp_ID
      AND MONTH(S_Eff_Date) = MONTH(MS1.MONTH_END_DATE)
      AND YEAR(S_Eff_Date) = YEAR(MS1.MONTH_END_DATE)
      AND MS.Emp_ID = MS1.EMP_ID
      AND MS1.MONTH_END_DATE >= @From_Date
      AND MS1.MONTH_END_DATE <= @To_Date
      AND MS1.MONTH_END_DATE <= @Month_En_Date)
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Basic_Sal

  --UPDATE #Tax_Report	--Ankit For Gratuity	
  --SET Amount_Col_Final = Gratuity_Amount
  --FROM #Tax_Report Tr INNER JOIN (  SELECT MS.EMP_ID ,SUM(MS.Gratuity_Amount) Gratuity_Amount FROM 
  --										T0200_MONTHLY_SALARY MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
  --								  WHERE MS.Month_End_Date >=@FROM_DATE AND MS.Month_End_Date <=@TO_DATE AND Ms.Month_End_Date <=@Month_En_Date
  --								  GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
  --WHERE DEFAULT_DEF_ID =@Cont_Gratuity_Sal


  UPDATE #Tax_Report	--Ankit For Gratuity	
  SET Amount_Col_Final = Gratuity_Amount
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      G.EMP_ID
     ,SUM(G.Gr_Amount) Gratuity_Amount
    FROM T0100_GRATUITY G WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON G.EMP_ID = EC.EMP_ID
    WHERE G.Cmp_ID = @Cmp_ID
    AND G.Gr_FNF = 1
    AND paid_date BETWEEN @From_Date AND @To_Date --added By Jimit 11052018 as Gratuity Amount shown in Each financial year at WCL
    GROUP BY G.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Gratuity_Sal



  --Added by Nimesh on 16-May-2017 (For Leave Encashment)
  CREATE TABLE #EMP_LEAVE_ENCASH (
    EMP_ID NUMERIC
   ,FOR_DATE DATETIME
   ,AMOUNT NUMERIC(18, 2)
  )

  INSERT INTO #EMP_LEAVE_ENCASH
    SELECT DISTINCT
      MS.EMP_ID
     ,Month_End_Date
     ,Leave_Salary_Amount
    FROM #Tax_Report Tr
    INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK)
      ON MS.Emp_ID = Tr.Emp_ID
    WHERE MS.Cmp_ID = @Cmp_ID
    AND MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Month_End_Date <= @Month_En_Date
    AND MS.Leave_Salary_Amount > 0
    AND DEFAULT_DEF_ID = @Cont_Leave_salary
    AND Is_Exempted = 0

  INSERT INTO #EMP_LEAVE_ENCASH
    SELECT DISTINCT
      Tr.EMP_ID
     ,LE.Lv_Encash_Apr_Date
     ,LE.Leave_Encash_Amount
    FROM #Tax_Report Tr
    INNER JOIN T0120_LEAVE_ENCASH_APPROVAL LE WITH (NOLOCK)
      ON LE.Emp_ID = Tr.Emp_ID
    WHERE LE.Cmp_ID = @Cmp_ID
    AND LE.Lv_Encash_Apr_Date >= @From_Date
    AND LE.Lv_Encash_Apr_Date <= @To_Date
    AND LE.Lv_Encash_Apr_Date <= @Month_En_Date
    --AND NOT EXISTS(SELECT 1 FROM #EMP_LEAVE_ENCASH ELE WHERE LE.Emp_ID=ELE.EMP_ID AND MONTH(LE.Lv_Encash_Apr_Date)=MONTH(ELE.FOR_DATE) AND YEAR(LE.Lv_Encash_Apr_Date)=YEAR(ELE.FOR_DATE)) -- Query Was One Leave Amount Effect in Salary and Another One Not Effect in Salary During Leave Encash Now There Was Leave Amount Deduct in Same Month  Commented by Rajput As Discussed with Mr. Hardik Bhai on 25012019  
    AND DEFAULT_DEF_ID = @Cont_Leave_salary
    AND ISNULL(LE.Eff_In_Salary, 0) = 0 --- Eff_In_Salary condition added by Hardik 24/01/2018 for Ifedora as without Salary generate Leave Encash amount should not show
    AND Is_Exempted = 0
    AND LE.Lv_Encash_Apr_Status = 'A'

  UPDATE TR
  SET Amount_Col_Final = AMOUNT
  FROM #Tax_Report TR
  INNER JOIN (SELECT
      EMP_ID
     ,SUM(AMOUNT) AS AMOUNT
    FROM #EMP_LEAVE_ENCASH ELE
    GROUP BY EMP_ID) ELE
    ON TR.EMP_ID = ELE.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Leave_salary
  AND Is_Exempted = 0

  DROP TABLE #EMP_LEAVE_ENCASH
  
  --Added by Hardik 12/02/2018 for Havmor as they are Exempted Leave Encash during F&F
  UPDATE #Tax_Report
  SET Amount_Col_Final = Leave_Salary_Amount
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,SUM(MS.Leave_Encash_Amount) Leave_Salary_Amount
    FROM T0120_LEAVE_ENCASH_APPROVAL MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Lv_Encash_Apr_Date >= @From_Date
    AND MS.Lv_Encash_Apr_Date <= @To_Date
    AND MS.Lv_Encash_Apr_Date <= @Month_En_Date
    AND ISNULL(MS.Is_Tax_Free, 0) = 1
    AND MS.Lv_Encash_Apr_Status = 'A'
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Leave_salary
  AND Is_Exempted = 1
  AND (Tr.Tax_Regime = 'Tax Regime 1'
  OR Tr.Tax_Regime IS NULL)


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
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,ISNULL(MS.Short_Fall_Dedu_Amount, 0) AS Notice_payment
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    INNER JOIN T0100_LEFT_EMP LE WITH (NOLOCK)
      ON MS.Emp_ID = LE.Emp_ID
    WHERE MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Is_FNF = 1
    AND LE.Is_Terminate = 1) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Notice_Pay

  --------------------End---------------------------

  


  UPDATE #Tax_Report
  SET Amount_Col_Final = OTHER_ALLOW_AMOUNT
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,ISNULL(SUM(MS.OTHER_ALLOW_AMOUNT), 0) OTHER_ALLOW_AMOUNT
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Month_End_Date <= @Month_En_Date
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Arrear

  --UPdate #Tax_Report 
  --set Amount_Col_Final = isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) + 
  --From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_HRA
  --WHERE tr.DEFAULT_DEF_ID =@Cont_HRA


  DECLARE @PT_Arrear NUMERIC(18, 2)
  SET @PT_Arrear = 0

  SELECT
    @PT_Arrear = SUM(ISNULL(MAD.M_AD_Amount, 0))
  FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
  INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK)
    ON MAD.AD_ID = AD.AD_ID
  WHERE EMP_ID = @Emp_ID
  AND AD.AD_DEF_ID = 22
  AND AD.AD_CALCULATE_ON = 'Import'
  AND MAD.For_Date >= @From_Date
  AND MAD.For_Date <= @To_Date


  --Comment by ronakk with sajid  14042023 
  --UPDATE #Tax_Report 
  --SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) + ISNULL(@PT_Arrear,0) --isnull(M_AD_Amount,0) +
  --,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0)  -- Added by rohit on 04052015
  --,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) -- Added by rohit on 04052015
  --FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND sa.Default_Def_ID = @Cont_PT_Amount
  --WHERE tr.DEFAULT_DEF_ID = @Cont_PT_Amount AND (TR.Tax_Regime = 'Tax Regime 1' OR TR.Tax_Regime IS NULL) --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME

  --Added by ronak with sajid 14042023

  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0) + ISNULL(@PT_Arrear, 0) --isnull(M_AD_Amount,0) +
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)  -- Added by rohit on 04052015
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0) -- Added by rohit on 04052015
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND sa.Default_Def_ID = @Cont_PT_Amount
  WHERE Tr.DEFAULT_DEF_ID = @Cont_PT_Amount
  AND (Tr.Tax_Regime = 'Tax Regime 1'
  OR Tr.Tax_Regime IS NULL)
  AND To_Date <= '2023-03-31' --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME 


  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0) + ISNULL(@PT_Arrear, 0) --isnull(M_AD_Amount,0) +
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)  -- Added by rohit on 04052015
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0) -- Added by rohit on 04052015
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND sa.Default_Def_ID = @Cont_PT_Amount
  WHERE Tr.DEFAULT_DEF_ID = @Cont_PT_Amount
  AND (Tr.Tax_Regime = 'Tax Regime 1')
  AND To_Date >= '2023-04-01' --- ADDED BY SAJID 18-03-2023

  --End by ronakk with sajid 14042023
  
  


  --Commment by ronakk with sajid 14042023
  --- Added by Hardik 11/04/2018 For Standard Deduction
  --UPDATE	TR 
  --SET		Amount_Col_Final = CASE WHEN LE.Emp_ID IS NOT NULL AND (LE.Is_Death = 1 OR LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value,0) ELSE (ISNULL(IFD.Field_Value,0)/12)* dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID,@From_Date,@To_Date) END,
  --		Amount_Col_Actual = CASE WHEN LE.Emp_ID IS NOT NULL AND (LE.Is_Death = 1 OR LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value,0) ELSE (ISNULL(IFD.Field_Value,0)/12)* dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID,@From_Date,@To_Date) END
  --FROM	#Tax_Report TR 
  --		INNER JOIN T0100_IT_FORM_DESIGN IFD WITH (NOLOCK)  ON TR.Default_Def_Id=IFD.Default_Def_Id And TR.Cmp_Id = IFD.Cmp_Id
  --		LEFT OUTER JOIN T0100_LEFT_EMP LE WITH (NOLOCK) ON TR.Emp_ID = LE.Emp_ID
  --WHERE	TR.Default_Def_Id = @Cont_Standard_Deduction And IFD.Financial_Year = @fin_year And TR.Cmp_ID = @Cmp_ID
  --		AND (TR.Tax_Regime = 'Tax Regime 1' OR TR.Tax_Regime IS NULL) --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME
  --



  --Add by ronakk with sajid 14042023
  UPDATE TR
  SET Amount_Col_Final =
      CASE
        WHEN LE.Emp_ID IS NOT NULL AND
          (LE.Is_Death = 1 OR
          LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value, 0)
        ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
      END
     ,Amount_Col_Actual =
      CASE
        WHEN LE.Emp_ID IS NOT NULL AND
          (LE.Is_Death = 1 OR
          LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value, 0)
        ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
      END
  FROM #Tax_Report TR
  INNER JOIN T0100_IT_FORM_DESIGN IFD
    ON TR.Default_Def_Id = IFD.Default_Def_Id
    AND TR.Cmp_ID = IFD.Cmp_ID
  LEFT OUTER JOIN T0100_LEFT_EMP LE
    ON TR.Emp_ID = LE.Emp_ID
  WHERE TR.Default_Def_Id = @Cont_Standard_Deduction
  AND IFD.Financial_Year = @fin_year
  AND TR.Cmp_ID = @Cmp_ID
  AND (TR.Tax_Regime = 'Tax Regime 1'
  OR TR.Tax_Regime IS NULL)
  AND To_Date <= '2023-03-31' --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME --- Commeted BY SAJID 18-03-2023


  UPDATE TR
  SET Amount_Col_Final =
      CASE
        WHEN LE.Emp_ID IS NOT NULL AND
          (LE.Is_Death = 1 OR
          LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value, 0)
        ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
      END
     ,Amount_Col_Actual =
      CASE
        WHEN LE.Emp_ID IS NOT NULL AND
          (LE.Is_Death = 1 OR
          LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value, 0)
        ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
      END
  FROM #Tax_Report TR
  INNER JOIN T0100_IT_FORM_DESIGN IFD
    ON TR.Default_Def_Id = IFD.Default_Def_Id
    AND TR.Cmp_ID = IFD.Cmp_ID
  LEFT OUTER JOIN T0100_LEFT_EMP LE
    ON TR.Emp_ID = LE.Emp_ID
  WHERE TR.Default_Def_Id = @Cont_Standard_Deduction
  AND IFD.Financial_Year = @fin_year
  AND TR.Cmp_ID = @Cmp_ID
  AND (TR.Tax_Regime = 'Tax Regime 1')
  AND To_Date >= '2023-04-01'   --- ADDED BY SAJID 18-03-2023

  --- Added by Sajid 18-03-2023 For Standard Deduction for Tax Regime 2
  UPDATE TR
  SET Amount_Col_Final =
      CASE
        WHEN LE.Emp_ID IS NOT NULL AND
          (LE.Is_Death = 1 OR
          LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value, 0)
        ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
      END
     ,Amount_Col_Actual =
      CASE
        WHEN LE.Emp_ID IS NOT NULL AND
          (LE.Is_Death = 1 OR
          LE.Is_Retire = 1) THEN ISNULL(IFD.Field_Value, 0)
        ELSE (ISNULL(IFD.Field_Value, 0) / 12) * dbo.F_GET_STANDARD_DED_MONTH_COUNT(TR.Emp_ID, @From_Date, @To_Date)
      END
  FROM #Tax_Report TR
  INNER JOIN T0100_IT_FORM_DESIGN IFD
    ON TR.Default_Def_Id = IFD.Default_Def_Id
    AND TR.Cmp_ID = IFD.Cmp_ID
  LEFT OUTER JOIN T0100_LEFT_EMP LE
    ON TR.Emp_ID = LE.Emp_ID
  WHERE TR.Default_Def_Id = @Cont_Standard_Deduction
  AND IFD.Financial_Year = @fin_year
  AND TR.Cmp_ID = @Cmp_ID
  AND ((TR.Tax_Regime = 'Tax Regime 2'
  OR TR.Tax_Regime IS NULL)
  AND To_Date >= '2023-04-01')
  --- Added by Sajid 18-03-2023 For Standard Deduction for Tax Regime 2


  --End by ronakk with sajid 14042023



  --- Added by Hardik 11/04/2018 For Net Round Amount for Taxable For RKM
  UPDATE #Tax_Report
  SET Amount_Col_Final = Net_Salary_Round_Diff_Amount
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,ISNULL(SUM(MS.Net_Salary_Round_Diff_Amount), 0) AS Net_Salary_Round_Diff_Amount
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Month_End_Date <= @Month_En_Date
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Net_Round_Amount


  --Comment by ronakk with sajid 14042023
  --UPDATE #Tax_Report 
  --SET Amount_Col_Final =  ISNULL(Old_M_AD_Amount,0) + ISNULL(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) +
  --,Amount_Col_Actual = ISNULL(Old_M_AD_Amount,0)  -- Added by rohit on 04052015
  --,Amount_Col_Assumed = ISNULL(Month_Diff_Amount,0) -- Added by rohit on 04052015
  --FROM #Tax_Report Tr 
  --	INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND tr.AD_ID = sa.aD_ID
  --	INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) on AM.AD_ID = tr.AD_ID 
  --  AND (ISNULL(AD_NOT_EFFECT_ON_SAL,0) =0 OR SA.Ad_effect_on_TDS =1)   and isnull(AM.Allowance_Type,'A') <> 'R'
  --  And AD_DEF_ID Not in (20,21) -- Added by Hardik for Production Bonus and Production Variable on 22/03/2018
  --  And (Tr.Is_Exempted=0 Or TR.Tax_Regime = 'Tax Regime 1' OR TR.Tax_Regime IS NULL)


  --Added by ronakk with sajid 14042023

  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0) --isnull(M_AD_Amount,0) +
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)  -- Added by rohit on 04052015
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0) -- Added by rohit on 04052015
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND Tr.AD_ID = sa.AD_ID
  INNER JOIN T0050_AD_MASTER AM
    ON AM.AD_ID = Tr.AD_ID
    AND (ISNULL(AD_NOT_EFFECT_ON_SAL, 0) = 0
    OR sa.Ad_Effect_On_TDS = 1)
    AND ISNULL(AM.Allowance_Type, 'A') <> 'R'
    AND AD_DEF_ID NOT IN (20, 21) -- Added by Hardik for Production Bonus and Production Variable on 22/03/2018
    AND (Tr.Is_Exempted = 0
    OR Tr.Tax_Regime = 'Tax Regime 1'
    OR Tr.Tax_Regime IS NULL)
    AND To_Date <= '2023-03-31' --- Commeted BY SAJID 18-03-2023


  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0) --isnull(M_AD_Amount,0) +
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)  -- Added by rohit on 04052015
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0) -- Added by rohit on 04052015
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND Tr.AD_ID = sa.AD_ID
  INNER JOIN T0050_AD_MASTER AM
    ON AM.AD_ID = Tr.AD_ID
    AND (ISNULL(AD_NOT_EFFECT_ON_SAL, 0) = 0
    OR sa.Ad_Effect_On_TDS = 1)
    AND ISNULL(AM.Allowance_Type, 'A') <> 'R'
    AND AD_DEF_ID NOT IN (20, 21) -- Added by Hardik for Production Bonus and Production Variable on 22/03/2018  
    AND (Tr.Is_Exempted = 0
    OR Tr.Tax_Regime = 'Tax Regime 1')
    AND To_Date >= '2023-04-01' --- Added BY SAJID 18-03-2023


  --End by ronakk with sajid 14042023

  
 

  --Added By Ramiz on 21/12/2018 for Removing the Assumed Amount of those employees , who have Production Based Salary
  UPDATE #Tax_Report
  SET Amount_Col_Assumed = 0
  FROM #Tax_Report Tr
  INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
    ON EM.Emp_ID = Tr.Emp_ID
  INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK)
    ON AM.AD_ID = Tr.AD_ID
  WHERE EM.Salary_Depends_on_Production = 1
  AND AM.AD_CALCULATE_ON <> 'Import'

  --- Aded by Hardik 22/03/2018 for Production Bonus (AIA Client)
  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0)
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0)
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      Emp_Id
     ,SA.Ad_Effect_On_TDS
     ,SUM(SA.Old_M_AD_Amount) AS Old_M_AD_Amount
     ,SUM(SA.Month_Diff_Amount) AS Month_Diff_Amount
    FROM #Salary_AD SA
    INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK)
      ON SA.AD_ID = AM.AD_ID
    WHERE AD_DEF_ID IN (20)
    AND ISNULL(AM.Allowance_Type, 'A') <> 'R'
    AND SA.Ad_Effect_On_TDS = 1
    GROUP BY Emp_Id
            ,SA.Ad_Effect_On_TDS) SA
    ON Tr.Emp_ID = SA.Emp_ID
  WHERE Tr.DEFAULT_DEF_ID = @Cont_Production_Bonus



  --Ramiz 03/07/2018-- Travel Settlement amount--


  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Travel_Amount, 0)
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      MS.EMP_ID
     ,ISNULL(SUM(MS.Travel_Amount), 0) AS Travel_Amount
    FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MS.EMP_ID = EC.EMP_ID
    WHERE MS.Month_End_Date >= @From_Date
    AND MS.Month_End_Date <= @To_Date
    AND MS.Month_End_Date <= @Month_En_Date
    GROUP BY MS.EMP_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
  WHERE DEFAULT_DEF_ID = @Cont_Travel_Settlement_Amount
  --Ramiz 03/07/2018-- Travel Settlement amount--	

  ---- Nilay20062014Perpuisite amount calculation-----

  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(Old_M_AD_Amount, 0) + ISNULL(Month_Diff_Amount, 0)
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)  -- Added by rohit on 04052015
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0) -- Added by rohit on 04052015
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND Tr.Rimb_ID = sa.AD_ID
  INNER JOIN T0050_AD_MASTER WITH (NOLOCK)
    ON T0050_AD_MASTER.AD_ID = Tr.Rimb_ID
  WHERE (ISNULL(AD_NOT_EFFECT_ON_SAL, 0) = 1)
  AND ISNULL(Allowance_Type, 'A') = 'R'
  AND ISNULL(Tr.Default_Def_Id, 0) = 0
  AND Tr.Is_Exempted = 0 --- Hardik 12/02/2016 Added Exempted Codition


  -- select AD_NOT_EFFECT_ON_SAL,Allowance_Type,Tr.Default_Def_Id,Tr.Is_Exempted,* FROM #Tax_Report Tr INNER JOIN #Salary_AD sa ON tr.Emp_ID =sa.Emp_ID AND tr.Rimb_ID = sa.aD_ID	
  --inner join T0050_AD_MASTER WITH (NOLOCK) on T0050_AD_MASTER.AD_ID = tr.Rimb_ID  where 
  --   (ISNULL(AD_NOT_EFFECT_ON_SAL,0) =1 )  and isnull(Allowance_Type,'A')='R' and isnull(Tr.Default_Def_Id,0) = 0 And Tr.Is_Exempted=0
  --   and Rimb_ID = 530
  ------ Nilay20062014Perpuisite amount calculation-----

  /*Perquisites-Nimesh*/
  UPDATE AD
  SET Amount_Col_Final = 0
     ,Amount_Col_Actual = 0
     ,Amount_Col_Assumed = 0
  FROM #Tax_Report AD
  INNER JOIN #Perq_Detail PD
    ON PD.EMP_ID = AD.EMP_ID
    AND (PD.AD_ID = AD.AD_ID
    OR PD.AD_ID = AD.Rimb_ID)
  WHERE PD.ShowDetails = 0
  AND Row_ID < 125

  --	UPDATE #Tax_Report 
  --	SET Amount_Col_Final =  Bonus_Amt
  --	FROM #Tax_Report Tr INNER JOIN (SELECT sa.emp_id,SUM(ISNULL(Bonus_amount,0)) Bonus_Amt FROM 
  --									T0180_BONUS sa WHERE sa.From_DATE >=@FROM_DATE AND sa.TO_DATE <=@TO_DATE
  --									GROUP BY sa.emp_id) QB
  --									ON Tr.Emp_ID =QB.Emp_ID AND Tr.Default_Def_Id=2

  --	-----Nilay18062014----								
  -- changed by rohit for Effective month for tax calculate.
  UPDATE #Tax_Report
  SET Amount_Col_Final = Bonus_Amt
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      sa.emp_id
     ,SUM(ISNULL(sa.Bonus_amount, 0)) Bonus_Amt
    FROM T0180_BONUS sa WITH (NOLOCK)
    WHERE sa.Cmp_ID = @Cmp_ID
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @From_Date
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @To_Date
    GROUP BY sa.emp_id) QB
    ON Tr.Emp_ID = QB.Emp_ID
    AND Tr.Default_Def_Id = 2  -- legal Bonus Amount


  -- Added by rohit For Add exgratia Amount tax calculation on 18052016									
  UPDATE #Tax_Report
  SET Amount_Col_Final = Ex_Gratia_Bonus_Amount
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      sa.emp_id
     ,SUM(ISNULL(Ex_Gratia_Bonus_Amount, 0)) Ex_Gratia_Bonus_Amount
    FROM T0180_BONUS sa WITH (NOLOCK)
    WHERE sa.Cmp_ID = @Cmp_ID
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @From_Date
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @To_Date
    GROUP BY sa.emp_id) QB
    ON Tr.Emp_ID = QB.Emp_ID
    AND Tr.Default_Def_Id = 3  -- Exgratia bonus Amount
  -- ended by rohit on 18052016	
  --Added By Deepali for Calculate bonus 20Nov21 - Start    ----------
  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Bonus_Amt, 0)
     ,Amount_Col_Actual = ISNULL(Old_M_AD_Amount, 0)
     ,Amount_Col_Assumed = ISNULL(Month_Diff_Amount, 0)
  FROM #Tax_Report Tr
  INNER JOIN #Salary_AD sa
    ON Tr.Emp_ID = sa.Emp_ID
    AND Tr.AD_ID = sa.AD_ID
  INNER JOIN T0050_AD_MASTER AM
    ON AM.AD_ID = Tr.AD_ID
    AND (ISNULL(AD_NOT_EFFECT_ON_SAL, 0) = 0
    OR sa.Ad_Effect_On_TDS = 1)
    AND ISNULL(AM.Allowance_Type, 'A') <> 'R'
    AND AD_DEF_ID = 19
    AND (Tr.Is_Exempted = 0
    OR Tr.Tax_Regime = 'Tax Regime 1'
    OR Tr.Tax_Regime IS NULL)
  INNER JOIN (SELECT
      sa.emp_id
     ,SUM(ISNULL(sa.Net_Payable_Bonus, 0)) Bonus_Amt
    FROM T0180_BONUS sa
    WHERE sa.Cmp_ID = @Cmp_ID
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @From_Date
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @To_Date
    GROUP BY sa.emp_id) QB
    ON Tr.Emp_ID = QB.Emp_ID
    AND Tr.Default_Def_Id = 0

  --Added By Deepali for Calculate bonus 20Nov21 - End    -------------------------

  -- Added by Hardik 17/03/2020 for WCL, Bonus Allowance amount
  UPDATE #Tax_Report
  SET Amount_Col_Final = Bonus_Amt
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      sa.emp_id
     ,SUM(ISNULL(sa.Bonus_amount, 0)) Bonus_Amt
    FROM T0180_BONUS sa WITH (NOLOCK)
    WHERE sa.Cmp_ID = @Cmp_ID
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @From_Date
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @To_Date
    AND Bonus_Cal_Type = 'Regular Bonus'
    AND Bonus_Calculated_On = 'Allowance'
    AND ISNULL(Bonus_Effect_on_Sal, 0) = 1
    GROUP BY sa.emp_id) QB
    ON Tr.Emp_ID = QB.Emp_ID
    AND Tr.Default_Def_Id = 13  -- Regular Bonus Amount


  -- Added by Hardik 17/03/2020 for WCL, Bonus Exgratia Allowance amount
  UPDATE #Tax_Report
  SET Amount_Col_Final = Ex_Gratia_Bonus_Amount
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      sa.emp_id
     ,SUM(ISNULL(Ex_Gratia_Bonus_Amount, 0)) Ex_Gratia_Bonus_Amount
    FROM T0180_BONUS sa WITH (NOLOCK)
    WHERE sa.Cmp_ID = @Cmp_ID
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) >= @From_Date
    AND dbo.GET_MONTH_ST_DATE(sa.Bonus_Effect_Month, sa.Bonus_Effect_Year) <= @To_Date
    AND Bonus_Cal_Type = 'Exgratia Bonus'
    AND Bonus_Calculated_On = 'Allowance'
    AND ISNULL(Bonus_Effect_on_Sal, 0) = 1
    GROUP BY sa.emp_id) QB
    ON Tr.Emp_ID = QB.Emp_ID
    AND Tr.Default_Def_Id = 14  -- Exgratia bonus Amount	

  --UPDATE #Tax_Report 
  --SET Amount_Col_Final = Amount_Col_Final + isnull(AMOUNT,0)
  --FROM #Tax_Report Tr INNER JOIN (SELECT ITD.EMP_ID,IT_ID ,ISNULL(SUM(ITD.AMOUNT),0)AMOUNT FROM 
  --										T0100_IT_DECLARATION ITD INNER JOIN #Emp_Cons EC ON ITD.EMP_ID = EC.EMP_ID 
  --										WHERE ITD.FOR_DATE >=@FROM_DATE AND ITD.FOR_DATE <=@TO_DATE 
  --									GROUP BY ITD.EMP_ID,IT_ID ) Q ON TR.EMP_ID =Q.EMP_ID AND TR.IT_ID = Q.IT_ID	


  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(AMOUNT, 0)
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      ITD.EMP_ID
     ,ITD.IT_ID
     ,CASE @IT_Declaration_Calc_On
        WHEN 'On_Regular' THEN CASE
            WHEN ISNULL(IT.Exempt_Percent, 0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
            ELSE ISNULL(SUM(ITD.AMOUNT), 0)
          END
        WHEN 'On_Provisional' THEN CASE
            WHEN ISNULL(IT.Exempt_Percent, 0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT_ESS), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
            ELSE ISNULL(SUM(ITD.AMOUNT_ESS), 0)
          END
        WHEN 'On_Approved' THEN CASE
            WHEN ISNULL(ITD.Is_Lock, 0) = 1 THEN CASE
                WHEN ISNULL(IT.Exempt_Percent, 0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
                ELSE ISNULL(SUM(ITD.AMOUNT), 0)
              END
            ELSE 0
          END
      END
      AS AMOUNT
    FROM T0100_IT_DECLARATION ITD WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON ITD.EMP_ID = EC.EMP_ID
    INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK)
      ON ITD.IT_ID = IT.IT_ID
      AND ITD.Cmp_ID = IT.Cmp_ID
    WHERE ITD.FOR_DATE >= @From_Date
    AND ITD.FOR_DATE <= @To_Date
    AND It_Def_Id <> 167  ----Hostel Def Id Not Considering Added By Jimit 16052019
    GROUP BY ITD.EMP_ID
            ,ITD.IT_ID
            ,IT.Exempt_Percent
            ,Is_Lock) Q
    ON Tr.EMP_ID = Q.EMP_ID
    AND Tr.IT_ID = Q.IT_ID
  WHERE (Tr.Tax_Regime = 'Tax Regime 1'
  OR Tr.Tax_Regime IS NULL) --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME

  --Changed By Deepali -17 jan2022



  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(AMOUNT, 0)
  FROM #Tax_Report tr
  INNER JOIN (SELECT
      ITD.EMP_ID
     ,ITD.IT_ID
     ,CASE @IT_Declaration_Calc_On
        WHEN 'On_Regular' THEN CASE
            WHEN ISNULL(IT.Exempt_Percent, 0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
            ELSE ISNULL(SUM(ITD.AMOUNT), 0)
          END
        WHEN 'On_Provisional' THEN CASE
            WHEN ISNULL(IT.Exempt_Percent, 0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT_ESS), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
            ELSE ISNULL(SUM(ITD.AMOUNT_ESS), 0)
          END
        WHEN 'On_Approved' THEN CASE
            WHEN ISNULL(ITD.Is_Lock, 0) = 1 THEN CASE
                WHEN ISNULL(IT.Exempt_Percent, 0) > 0 THEN (ISNULL(SUM(ITD.AMOUNT), 0) * ISNULL(IT.Exempt_Percent, 0)) / 100
                ELSE ISNULL(SUM(ITD.AMOUNT), 0)
              END
            ELSE 0
          END
      END
      AS AMOUNT
    FROM T0100_IT_DECLARATION ITD WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON ITD.EMP_ID = EC.EMP_ID
    INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK)
      ON ITD.IT_ID = IT.IT_ID
      AND ITD.Cmp_ID = IT.Cmp_ID
    INNER JOIN T0070_IT_MASTER IT1 WITH (NOLOCK)
      ON IT1.IT_ID = IT.IT_Parent_ID
      AND IT1.IT_Alias IN ('E', 'F', 'D') -- 'D' added by Hardik 07/12/2020 for WCL as Leave Exemption head need to display in New Regime
    WHERE ITD.FOR_DATE >= @From_Date
    AND ITD.FOR_DATE <= @To_Date
    AND IT.It_Def_Id <> 167  ----Hostel Def Id Not Considering Added By Jimit 16052019
    AND IT.IT_Alias NOT IN ('Previous Employer PF', 'Prev Emp PT', 'Income from self occ', 'Intrest on housing')
    --And IT.IT_Def_ID=152 -- 152 added by Hardik 07/12/2020 for WCL as Leave Exemption head need to display in New Regime  --Comment by ronakk 29052023 
    GROUP BY ITD.EMP_ID
            ,ITD.IT_ID
            ,IT.Exempt_Percent
            ,Is_Lock) Q
    ON tr.EMP_ID = Q.EMP_ID
    AND tr.IT_ID = Q.IT_ID
  WHERE (tr.Tax_Regime = 'Tax Regime 2') --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME

  -------------------Set IT Form Design -------------------------		


  UPDATE #Tax_Report
  SET Amount_Col_Final = 0
  FROM #Tax_Report Tr
  INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK)
    ON Tr.AD_ID = AM.AD_ID
  WHERE Tr.Tax_Regime = 'Tax Regime 2' --- ADDED BY HARDIK 02/04/2020 FOR TAX REGIME
  AND AM.AD_DEF_ID IN (2, 4, 5) -- For PF, Vol. PF and Employer PF



  UPDATE #Tax_Report
  SET Default_Def_Id = it_def_id
  FROM #Tax_Report tr
  INNER JOIN T0070_IT_MASTER it WITH (NOLOCK)
    ON it.IT_ID = tr.IT_ID


  IF OBJECT_ID('tempdb..#Tbl_Formula') IS NOT NULL
    DROP TABLE #Tbl_Formula

  CREATE TABLE #Tbl_Formula (
    Emp_ID NUMERIC
   ,Formula_Id NUMERIC
   ,Formula_Name NVARCHAR(MAX)
   ,Formula_Value NVARCHAR(MAX)
   ,
  )

  IF OBJECT_ID('tempdb..#Tbl_Formula_Result') IS NOT NULL
    DROP TABLE #Tbl_Formula_Result

  CREATE TABLE #Tbl_Formula_Result (
    Emp_ID NUMERIC
   ,Formula_Name NVARCHAR(MAX)
   ,Formula_Cal NUMERIC(18, 2)
  )


  IF OBJECT_ID('tempdb..#Tbl_Result') IS NOT NULL
    DROP TABLE #Tbl_Result

  CREATE TABLE #Tbl_Result (
    Emp_ID NUMERIC
   ,Formula_Name NVARCHAR(MAX)
   ,Formula_Cal NUMERIC(18, 2)
  )

  

  --======================

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
  DECLARE @query NVARCHAR(MAX)

  DECLARE @Result NVARCHAR(MAX)
  DECLARE @Qry NVARCHAR(MAX)

  

  DECLARE CUR_T CURSOR FOR SELECT DISTINCT
    t.Is_Total
   ,t.Row_ID
   ,t.From_Row_ID
   ,t.To_Row_ID
   ,t.Multiple_Row_ID
   ,t.Max_Limit
   ,t.Max_Limit_Compare_Row_ID
   ,t.Max_Limit_Compare_Type
   ,FD.TotalFormula
  FROM #Tax_Report t
  INNER JOIN T0100_IT_FORM_DESIGN FD WITH (NOLOCK)
    ON t.Row_ID = FD.Row_ID
    AND t.Cmp_ID = FD.Cmp_ID
    AND FD.Financial_Year = @fin_year
  WHERE t.Is_Total > 0
  ORDER BY Row_ID
  OPEN CUR_T
  FETCH NEXT FROM CUR_T INTO @IS_TOTAL, @ROW_ID, @From_Row_ID, @TO_ROW_ID, @Multiple_Row_ID, @Max_Limit, @Max_Limit_Compare_Row_ID, @Max_Limit_Compare_Type, @TotalFormula
  WHILE @@FETCH_STATUS = 0
  BEGIN

  SET @sqlQuery = ''
  IF @IS_TOTAL = 1
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
  BEGIN

    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Q.sum_amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,SUM(Amount_Col_Final) Sum_amount
      FROM #Tax_Report
      WHERE Row_ID >= @From_Row_ID
      AND Row_ID <= @TO_ROW_ID
      GROUP BY Emp_ID) Q
      ON t.emp_ID = Q.Emp_ID
      AND t.Row_ID = @ROW_ID


  END
  ELSE
  IF @IS_TOTAL = 1
    AND RTRIM(@Multiple_Row_ID) <> ''
  BEGIN

    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Q.sum_amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,SUM(Amount_Col_Final) Sum_amount
      FROM #Tax_Report
      WHERE Row_ID IN (SELECT
          DATA
        FROM dbo.Split(@Multiple_Row_ID, '#')
        WHERE DATA > 0)
      GROUP BY Emp_ID) Q
      ON t.emp_ID = Q.Emp_ID
      AND t.Row_ID = @ROW_ID

  --				set @sqlQuery = 'update #Tax_Report
  --								set Amount_Col_Final =isnull(Q.sum_amount,0)
  --								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '

  --				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
  END
  ELSE
  IF @IS_TOTAL = 2
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
  BEGIN
    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Q.First_Amount, 0) - ISNULL(Q1.Second_Amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS First_Amount
      FROM #Tax_Report
      WHERE Row_ID = @From_Row_ID) Q
      ON t.emp_ID = Q.Emp_ID
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS Second_Amount
      FROM #Tax_Report
      WHERE Row_ID = @TO_ROW_ID) Q1
      ON t.emp_ID = Q1.Emp_ID
    WHERE t.Row_ID = @ROW_ID

  END
  ELSE
  IF @IS_TOTAL = 3
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
    AND @Max_Limit > 0
  BEGIN



    --IF @Row_Id=138 --Commented by Hardik 27/04/2018
    IF EXISTS (SELECT
          1
        FROM #Tax_Report
        WHERE Row_ID = @ROW_ID
        AND Default_Def_Id = 9) --- For Conveyance Exemption -- Change by Hardik 27/04/2018
      UPDATE #Tax_Report
      SET Amount_Col_Final =
      CASE
        WHEN ISNULL(Q.Sum_amount, 0) <= @Max_Limit THEN ISNULL(Q.Sum_amount, 0)
        WHEN ISNULL(Q.Sum_amount, 0) > 0 THEN @Max_Limit
        ELSE 0
      END
      FROM #Tax_Report t
      INNER JOIN (SELECT
          Emp_ID
         ,ISNULL(SUM(Amount_Col_Final), 0) Sum_amount
        FROM #Tax_Report
        WHERE Row_ID >= @From_Row_ID
        AND Row_ID <= @TO_ROW_ID
        GROUP BY Emp_ID) Q
        ON t.emp_ID = Q.Emp_ID
      WHERE t.Row_ID = @ROW_ID
      AND NOT EXISTS (SELECT
          1
        FROM T0240_Perquisites_Employee_Car PEC WITH (NOLOCK)
        WHERE PEC.Financial_Year = @fin_year
        AND PEC.emp_id = t.Emp_ID)
    ELSE
      UPDATE #Tax_Report
      SET Amount_Col_Final =
      CASE
        WHEN ISNULL(Q.Sum_amount, 0) <= @Max_Limit THEN ISNULL(Q.Sum_amount, 0)
        WHEN ISNULL(Q.Sum_amount, 0) > 0 THEN @Max_Limit
        ELSE 0
      END
      FROM #Tax_Report t
      INNER JOIN (SELECT
          Emp_ID
         ,ISNULL(SUM(Amount_Col_Final), 0) Sum_amount
        FROM #Tax_Report
        WHERE Row_ID >= @From_Row_ID
        AND Row_ID <= @TO_ROW_ID
        GROUP BY Emp_ID) Q
        ON t.emp_ID = Q.Emp_ID
      WHERE t.Row_ID = @ROW_ID


  END
  ELSE
  IF @IS_TOTAL = 3
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
  BEGIN

    UPDATE #Tax_Report
    SET Amount_Col_Final =
    CASE
      WHEN ISNULL(Q.First_Amount, 0) <= ISNULL(Q1.Second_Amount, 0) THEN ISNULL(Q.First_Amount, 0)
      ELSE ISNULL(Q1.Second_Amount, 0)
    END
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS First_Amount
      FROM #Tax_Report
      WHERE Row_ID = @From_Row_ID) Q
      ON t.emp_ID = Q.Emp_ID
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS Second_Amount
      FROM #Tax_Report
      WHERE Row_ID = @TO_ROW_ID) Q1
      ON t.emp_ID = Q1.Emp_ID
    WHERE t.Row_ID = @ROW_ID

  END
  ELSE
  IF @IS_TOTAL = 4 -- Added By Nilesh Patel on 23052019 for Formula
  BEGIN
    SET @TotalFormula = REPLACE(@TotalFormula, ' ', '')

    TRUNCATE TABLE #Tbl_Formula
    TRUNCATE TABLE #Tbl_Formula_Result
    TRUNCATE TABLE #Tbl_Result

    INSERT INTO #Tbl_Formula
      SELECT DISTINCT
        Emp_ID
       ,ID
       ,Data
       ,Data
      FROM dbo.Split(@TotalFormula, '#')
      CROSS JOIN #Tax_Report
      WHERE Data <> ''
      ORDER BY Emp_ID, ID

    -- Stop Here Deepal
    --select * from #Tbl_Formula

    --select *
    --From #Tax_Report t
    --Inner Join #Tbl_Formula TF 
    --ON t.Row_ID = TF.Formula_Name and t.Emp_ID = TF.Emp_ID
    --Where Isnumeric(TF.Formula_Name) > 0 

    UPDATE TF
    SET TF.Formula_Value = ISNULL(t.Amount_Col_Final, 0)
    FROM #Tax_Report t
    INNER JOIN #Tbl_Formula TF
      ON t.Row_ID = TF.Formula_Name
      AND t.Emp_ID = TF.Emp_ID
    WHERE ISNUMERIC(TF.Formula_Name) > 0
    AND TF.Formula_Name NOT LIKE '(%'


    UPDATE tf
    SET tf.Formula_Value = 0
    FROM #Tbl_Formula tf
    WHERE NOT EXISTS (SELECT
        1
      FROM #Tax_Report t
      WHERE tf.Formula_Name = t.Row_ID
      AND t.Emp_ID = tf.Emp_ID)
    AND tf.Formula_Name LIKE '%[0-9]%'
    AND tf.Formula_Name NOT LIKE '(%'




    INSERT INTO #Tbl_Formula_Result
      SELECT
        S.Emp_ID
       ,STUFF((SELECT
            ' ' + CONVERT(VARCHAR, Formula_Value)
          FROM #Tbl_Formula t
          WHERE (t.Emp_ID = S.Emp_ID)
          ORDER BY t.Formula_Id ASC
          FOR XML PATH (''))
        , 1, 1, '') AS FormulaValue
       ,0
      FROM #Tbl_Formula S
      GROUP BY S.Emp_ID


    SET @query = NULL;
    SELECT
      @query = COALESCE(@query + ' UNION ', '') + 'SELECT Emp_ID, Formula_Name,  Cast(' + Formula_Name + ' as  BIGINT) AS CalcValue FROM #Tbl_Formula_Result WHERE Formula_Name = ''' + Formula_Name + ''' '
    FROM #Tbl_Formula_Result

    --SET @query = STUFF(@query,1,14,'')
    SET @query = 'INSERT INTO #Tbl_Result 
									' + @query

    --INSERT INTO #Tbl_Result
    EXEC (@query)


    UPDATE t
    SET t.Amount_Col_Final =
    CASE
      WHEN ISNULL(TR.Formula_Cal, 0) > @Max_Limit AND
        ISNULL(@Max_Limit, 0) <> 0 THEN @Max_Limit
      ELSE ISNULL(TR.Formula_Cal, 0)
    END
    FROM #Tax_Report t
    INNER JOIN #Tbl_Result TR
      ON t.Emp_ID = TR.Emp_ID
    WHERE t.Row_ID = @ROW_ID


  END

  FETCH NEXT FROM CUR_T INTO @IS_TOTAL, @ROW_ID, @From_Row_ID, @TO_ROW_ID, @Multiple_Row_ID, @Max_Limit, @Max_Limit_Compare_Row_ID, @Max_Limit_Compare_Type, @TotalFormula
  END
  CLOSE CUR_T
  DEALLOCATE CUR_T

  
  /*Perquisite-Nimesh*/
  UPDATE PD
  SET TaxFreeAmount = MRD.TaxFreeAmount
  FROM #Perq_Detail PD
  INNER JOIN (SELECT
      MRD.EMP_ID
     ,RC_ID
     ,SUM(ISNULL(Tax_Free_amount, 0)) AS TaxFreeAmount
    FROM T0210_Monthly_Reim_Detail MRD WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON MRD.Emp_ID = EC.Emp_ID
    WHERE for_Date >= @From_Date
    AND for_Date <= @To_Date
    AND Sal_tran_ID IS NULL
    GROUP BY MRD.EMP_ID
            ,RC_ID) MRD
    ON PD.Emp_ID = MRD.Emp_ID
    AND PD.AD_ID = MRD.RC_ID

  UPDATE #Perq_Detail
  SET FinalAmount = ISNULL(TotalAmount, 0) - ISNULL(TaxFreeAmount, 0)



  -----------
  DECLARE @EMP_ID_Per AS NUMERIC(18)



  DECLARE CUR_Tax_Per CURSOR FOR SELECT
    emp_id
  FROM #Emp_Cons
  OPEN CUR_Tax_Per
  FETCH NEXT FROM CUR_Tax_Per INTO @EMP_ID_Per
  WHILE @@FETCH_STATUS = 0
  BEGIN

  DECLARE @PAct_Gross_Cal AS NUMERIC(18, 2)
  DECLARE @PAct_Exe_Cal AS NUMERIC(18, 2)
  DECLARE @Perquisit_amount AS NUMERIC(18, 2)
  --DECLARE @fin_year AS NVARCHAR(20)

  SET @PAct_Gross_Cal = 0
  SET @PAct_Exe_Cal = 0
  SET @Perquisit_amount = 0

  --SET @fin_year = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)

  SELECT
    @PAct_Gross_Cal = Amount_Col_Final
  FROM #Tax_Report
  WHERE Row_ID = 104
  AND Emp_ID = @EMP_ID_Per

  


  SELECT
    @PAct_Exe_Cal = SUM(Amount_Col_Final)
  FROM #Tax_Report
  WHERE Default_Def_Id IN (8, 9, 11, 151, 152, 163, 160, 164, 166)
  AND Emp_ID = @EMP_ID_Per --added 166 for Gratuity exemption amount (as Tax computation perq value come wrong at WCL) added By Jimit 20012018

  --Declare @Reim_Perquisite_amount as numeric(18,2)
  --set @Reim_Perquisite_amount =0
  --commented by rohit on 10092015 as per discussion with Deepak vyas wonder
  ---- Nilay20062014Perpuisite amount calculation-----

  --select @Reim_Perquisite_amount = sum(isnull(Taxable,0) + isnull(Tax_Free_amount,0)) 
  --						from T0210_Monthly_Reim_Detail where Cmp_ID=@Cmp_ID and Emp_ID=@EMP_ID_Per and
  --                                       for_date >=@from_date and for_Date<=@to_date
  --                                       and Sal_tran_ID is null

  ---- Nilay20062014Perpuisite amount calculation-----





  EXEC GET_EMP_PERQUISITES @Cmp_ID
                          ,@EMP_ID_Per
                          ,@fin_year
                          ,@PAct_Gross_Cal
                          ,@PAct_Exe_Cal
                          ,@Perquisit_amount OUTPUT





  --if @Reim_Perquisite_amount > 0
  --	set @Perquisit_amount =	 @Perquisit_amount + @Reim_Perquisite_amount

  --select @Perquisit_amount
  /*Perquisite-Nimesh*/
  UPDATE TR
  SET Amount_Col_Final = ISNULL(@Perquisit_amount, 0) + ISNULL(PD.Taxable, 0)
  FROM #Tax_Report TR
  LEFT OUTER JOIN (SELECT
      EMP_ID
     ,SUM(ISNULL(PD.FinalAmount, 0)) AS Taxable
    FROM #Perq_Detail PD
    GROUP BY EMP_ID) PD
    ON TR.Emp_ID = PD.Emp_ID
  WHERE Default_Def_Id = @Cont_Perquisit_Amt
  AND TR.Emp_ID = @EMP_ID_Per



  /*
	UPDATE #Tax_Report
	SET Amount_Col_Final = @Perquisit_amount 
	--from #Tax_Report inner join #Emp_Cons ec on ec.Emp_ID = #Tax_Report.Emp_ID
	WHERE Default_Def_Id = @Cont_Perquisit_Amt AND Emp_ID = @EMP_ID_Per
	*/

  FETCH NEXT FROM CUR_Tax_Per INTO @EMP_ID_Per
  END
  CLOSE CUR_Tax_Per
  DEALLOCATE CUR_Tax_Per

  ----------
  --UPDATE #Tax_Report SET Amount_Col_Final = 0   WHERE Row_ID = 107 

  --Added by rohit for add Customized Perq on 26102015
  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(AMOUNT, 0)
  FROM #Tax_Report Tr
  INNER JOIN (SELECT
      ITD.EMP_ID
     ,ITD.IT_ID
     ,ISNULL(SUM(ITD.AMOUNT), 0) AMOUNT
    FROM T0240_Perquisites_Employee_Dynamic ITD WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON ITD.EMP_ID = EC.EMP_ID
    INNER JOIN T0070_IT_MASTER IT WITH (NOLOCK)
      ON ITD.Cmp_ID = IT.Cmp_ID
      AND ITD.IT_ID = IT.IT_ID
      AND IT.IT_Is_Active = 1
      AND IT_Is_perquisite = 1
    WHERE ITD.Cmp_ID = @Cmp_ID
    AND ITD.Financial_Year = @fin_year
    GROUP BY ITD.EMP_ID
            ,ITD.IT_ID) Q
    ON Tr.EMP_ID = Q.EMP_ID
    AND Tr.IT_ID = Q.IT_ID
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
  --		set @sqlQuery =''
  --		if @is_Total =1 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
  --			begin
  --				update #Tax_Report
  --				set Amount_Col_Final = 0
  --				from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --					Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID							
  --			end
  --		else if @is_Total =1  and rtrim(@Multiple_Row_ID) <> ''
  --			begin

  --					update #Tax_Report
  --								set Amount_Col_Final =isnull(Q.sum_amount,0)
  --								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --								Row_ID in (select Data From dbo.Split(@Multiple_Row_ID,'#') where Data >0) group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID 

  ----				set @sqlQuery = 'update #Tax_Report
  ----								set Amount_Col_Final =isnull(Q.sum_amount,0)
  ----								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  ----								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '

  ----				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
  --			end
  --		else if @is_Total =2 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
  --			begin
  --				update #Tax_Report
  --				set Amount_Col_Final = 0
  --				from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
  --					Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
  --					inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
  --					Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
  --				Where t.Row_ID =@Row_ID													

  --			end
  --		--else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 and @Max_Limit > 0
  --		--	begin

  --		--		update #Tax_Report
  --		--		set Amount_Col_Final =  0
  --		--		from #Tax_Report t inner join  (select Emp_ID ,isnull(sum(Amount_Col_Final),0)Sum_amount From #Tax_Report where
  --		--			Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID
  --		--		Where t.Row_ID =@Row_ID												




  --		--	end
  --		--else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
  --		--	begin


  --		--		update #Tax_Report
  --		--		set Amount_Col_Final = 0					 
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
  FROM #Tax_Report tr
  INNER JOIN (SELECT
      t.Emp_ID
     ,t.Row_ID
     ,CASE
        WHEN q.Amount_Col_Final > t.Amount_Col_Final AND
          t.Amount_Col_Final > 0 THEN t.Amount_Col_Final
        ELSE q.Amount_Col_Final
      END Final_Exemption_Amount

    FROM #Tax_Report t
    INNER JOIN (SELECT
        Amount_Col_Final
       ,Exem_Againt_row_Id
       ,Emp_ID
      FROM #Tax_Report
      WHERE ISNULL(Exem_Againt_row_Id, 0) > 0
      AND Amount_Col_Final > 0
      AND ISNULL(Rimb_ID, 0) = 0) q  --- Hardik 12/02/2016 Condition added for Rimb_Id As Reimbursement Exempt code done in Allowance exempt SP
      ON t.Row_ID = q.Exem_Againt_row_Id
      AND t.Emp_Id = q.emp_ID) q1
    ON tr.Exem_Againt_row_Id = q1.Row_ID
    AND tr.Emp_Id = q1.emp_ID

	

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


  -- Added by Hardik 03/06/2019 for 80D Total As it should not exceed Individual Mediclaim Limit and Health checkup
  DECLARE @ROW_ID_HEALTH INT
  SELECT
    @ROW_ID_HEALTH = Row_ID
  FROM #Tax_Report
  WHERE Default_Def_Id = 170 --IT_Def_ID  = 170 for Health Checkup


  SELECT
    MAIN.* INTO #HEALTH_DESIGN
  FROM T0100_IT_FORM_DESIGN IFD WITH (NOLOCK)
  INNER JOIN T0100_IT_FORM_DESIGN MAIN WITH (NOLOCK)
    ON MAIN.Row_ID BETWEEN IFD.From_Row_ID AND IFD.To_Row_ID
      AND MAIN.Financial_Year = IFD.Financial_Year
  WHERE IFD.FINANCIAL_YEAR = @fin_year
  AND IFD.Is_Total = 1
  AND @ROW_ID_HEALTH BETWEEN IFD.From_Row_ID AND IFD.To_Row_ID
  AND @ROW_ID_HEALTH <> MAIN.Row_ID
  AND IFD.Cmp_ID = @Cmp_ID

  DECLARE @ROW_ID_80D INT
  SET @ROW_ID_80D = 0

  SELECT
    @ROW_ID_80D = ISNULL(IFD.Row_ID, 0)
  FROM T0100_IT_FORM_DESIGN IFD WITH (NOLOCK)
  WHERE IFD.FINANCIAL_YEAR = @fin_year
  AND IFD.Is_Total = 1
  AND @ROW_ID_HEALTH BETWEEN IFD.From_Row_ID AND IFD.To_Row_ID
  AND IFD.Cmp_ID = @Cmp_ID


  

  UPDATE T
  SET Amount_Col_Final =
  CASE
    WHEN CLAIMED_AMOUNT + TR_HEALTH.Amount_Col_Final > IT.Max_Limit THEN IT.Max_Limit
    ELSE CLAIMED_AMOUNT + TR_HEALTH.Amount_Col_Final
  END
  FROM #Tax_Report T
  INNER JOIN (SELECT
      TR.EMP_ID
     ,SUM(TR.Amount_Col_Final) AS CLAIMED_AMOUNT
     ,SUM(TR.Max_Limit) AS MAX_LIMIT
    FROM #HEALTH_DESIGN HD
    INNER JOIN #Tax_Report TR
      ON HD.IT_ID = TR.IT_ID
    WHERE TR.Amount_Col_Final > 0
    GROUP BY TR.EMP_ID) IT
    ON T.Emp_ID = IT.Emp_ID
  INNER JOIN #Tax_Report TR_HEALTH
    ON T.Emp_ID = TR_HEALTH.EMP_ID
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
  DECLARE @Exem_Ag_RowID AS INT = 0





  DECLARE CUR_T CURSOR FOR SELECT DISTINCT
    T.Is_Total
   ,T.Row_ID
   ,T.From_Row_ID
   ,T.To_Row_ID
   ,T.Multiple_Row_ID
   ,T.Max_Limit
   ,T.Max_Limit_Compare_Row_ID
   ,T.Max_Limit_Compare_Type
   ,FD.TotalFormula
   ,FD.Exem_Againt_row_Id
  FROM #Tax_Report T
  LEFT OUTER JOIN T0100_IT_FORM_DESIGN FD
    ON T.Row_ID = FD.Row_ID
    AND T.Cmp_ID = FD.Cmp_ID
    AND FD.Financial_Year = @fin_year
  WHERE T.Is_Total > 0
  AND T.Row_ID <> @ROW_ID_80D
  ORDER BY Row_ID
  OPEN CUR_T
  FETCH NEXT FROM CUR_T INTO @IS_TOTAL, @ROW_ID, @From_Row_ID, @TO_ROW_ID, @Multiple_Row_ID, @Max_Limit, @Max_Limit_Compare_Row_ID, @Max_Limit_Compare_Type, @TotalFormula, @Exem_Ag_RowID
  WHILE @@FETCH_STATUS = 0
  BEGIN
  SET @sqlQuery = ''
  IF @IS_TOTAL = 1
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
  BEGIN

    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Q.sum_amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,SUM(Amount_Col_Final) Sum_amount
      FROM #Tax_Report
      WHERE Row_ID >= @From_Row_ID
      AND Row_ID <= @TO_ROW_ID
      GROUP BY Emp_ID) Q
      ON t.emp_ID = Q.Emp_ID
      AND t.Row_ID = @ROW_ID


  END
  ELSE
  IF @IS_TOTAL = 1
    AND RTRIM(@Multiple_Row_ID) <> ''
  BEGIN

    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Q.sum_amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,SUM(Amount_Col_Final) Sum_amount
      FROM #Tax_Report
      WHERE Row_ID IN (SELECT
          DATA
        FROM dbo.Split(@Multiple_Row_ID, '#')
        WHERE DATA > 0)
      GROUP BY Emp_ID) Q
      ON t.emp_ID = Q.Emp_ID
      AND t.Row_ID = @ROW_ID

  --				set @sqlQuery = 'update #Tax_Report
  --								set Amount_Col_Final =isnull(Q.sum_amount,0)
  --								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '

  --				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
  END
  ELSE
  IF @IS_TOTAL = 2
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
  BEGIN
    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Q.First_Amount, 0) - ISNULL(Q1.Second_Amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS First_Amount
      FROM #Tax_Report
      WHERE Row_ID = @From_Row_ID) Q
      ON t.emp_ID = Q.Emp_ID
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS Second_Amount
      FROM #Tax_Report
      WHERE Row_ID = @TO_ROW_ID) Q1
      ON t.emp_ID = Q1.Emp_ID
    WHERE t.Row_ID = @ROW_ID

  END
  ELSE
  IF @IS_TOTAL = 3
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
    AND @Max_Limit > 0
    AND @Exem_Ag_RowID > 0 -- Added by Deepal To check the NPS condition 01022022 As discussed with chintan bhai related to tradebull client
  BEGIN
    IF @From_Row_ID = @TO_ROW_ID
      AND @Max_Limit > 0
    BEGIN
      UPDATE #Tax_Report
      SET Amount_Col_Final =
      CASE
        WHEN ISNULL(Q.First_Amount, 0) <= ISNULL(Q1.Second_Amount, 0) THEN CASE
            WHEN ISNULL(Q.First_Amount, 0) <= ISNULL(@Max_Limit, 0) THEN ISNULL(Q.First_Amount, 0)
            ELSE ISNULL(@Max_Limit, 0)
          END
        ELSE CASE
            WHEN ISNULL(Q1.Second_Amount, 0) <= ISNULL(@Max_Limit, 0) THEN ISNULL(Q1.Second_Amount, 0)
            ELSE ISNULL(@Max_Limit, 0)
          END
      END
      FROM #Tax_Report t
      INNER JOIN (SELECT
          Emp_ID
         ,Amount_Col_Final AS First_Amount
        FROM #Tax_Report
        WHERE Row_ID = @From_Row_ID) Q
        ON t.emp_ID = Q.Emp_ID
      INNER JOIN (SELECT
          Emp_ID
         ,Amount_Col_Final AS Second_Amount
        FROM #Tax_Report
        WHERE Row_ID = @Exem_Ag_RowID) Q1
        ON t.emp_ID = Q1.Emp_ID
      WHERE t.Row_ID = @ROW_ID
    END
    ELSE
    BEGIN
      UPDATE #Tax_Report
      SET Amount_Col_Final =
      CASE
        WHEN ISNULL(Q.First_Amount, 0) <= ISNULL(Q1.Second_Amount, 0) THEN ISNULL(Q.First_Amount, 0)
        ELSE ISNULL(Q1.Second_Amount, 0)
      END
      FROM #Tax_Report t
      INNER JOIN (SELECT
          Emp_ID
         ,Amount_Col_Final AS First_Amount
        FROM #Tax_Report
        WHERE Row_ID = @From_Row_ID) Q
        ON t.emp_ID = Q.Emp_ID
      INNER JOIN (SELECT
          Emp_ID
         ,Amount_Col_Final AS Second_Amount
        FROM #Tax_Report
        WHERE Row_ID = @TO_ROW_ID) Q1
        ON t.emp_ID = Q1.Emp_ID
      WHERE t.Row_ID = @ROW_ID
    END
  END
  ELSE
  IF @IS_TOTAL = 3
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
    AND @Max_Limit > 0
  BEGIN


    --IF @Row_Id=138 --Commented by Hardik 27/04/2018
    IF EXISTS (SELECT
          1
        FROM #Tax_Report
        WHERE Row_ID = @ROW_ID
        AND Default_Def_Id = 9) --- For Conveyance Exemption -- Change by Hardik 27/04/2018
      UPDATE #Tax_Report
      SET Amount_Col_Final =
      CASE
        WHEN ISNULL(Q.Sum_amount, 0) <= @Max_Limit THEN ISNULL(Q.Sum_amount, 0)
        WHEN ISNULL(Q.Sum_amount, 0) > 0 THEN @Max_Limit
        ELSE 0
      END
      FROM #Tax_Report t
      INNER JOIN (SELECT
          Emp_ID
         ,ISNULL(SUM(Amount_Col_Final), 0) Sum_amount
        FROM #Tax_Report
        WHERE Row_ID >= @From_Row_ID
        AND Row_ID <= @TO_ROW_ID
        GROUP BY Emp_ID) Q
        ON t.emp_ID = Q.Emp_ID
      WHERE t.Row_ID = @ROW_ID
      AND NOT EXISTS (SELECT
          1
        FROM T0240_Perquisites_Employee_Car PEC WITH (NOLOCK)
        WHERE PEC.Financial_Year = @fin_year
        AND PEC.emp_id = t.Emp_ID)
    ELSE
      UPDATE #Tax_Report
      SET Amount_Col_Final =
      CASE
        WHEN ISNULL(Q.Sum_amount, 0) <= @Max_Limit THEN ISNULL(Q.Sum_amount, 0)
        WHEN ISNULL(Q.Sum_amount, 0) > 0 THEN @Max_Limit
        ELSE 0
      END
      FROM #Tax_Report t
      INNER JOIN (SELECT
          Emp_ID
         ,ISNULL(SUM(Amount_Col_Final), 0) Sum_amount
        FROM #Tax_Report
        WHERE Row_ID >= @From_Row_ID
        AND Row_ID <= @TO_ROW_ID
        GROUP BY Emp_ID) Q
        ON t.emp_ID = Q.Emp_ID
      WHERE t.Row_ID = @ROW_ID




  END
  ELSE
  IF @IS_TOTAL = 3
    AND @From_Row_ID > 0
    AND @TO_ROW_ID > 0
  BEGIN


    UPDATE #Tax_Report
    SET Amount_Col_Final =
    CASE
      WHEN ISNULL(Q.First_Amount, 0) <= ISNULL(Q1.Second_Amount, 0) THEN ISNULL(Q.First_Amount, 0)
      ELSE ISNULL(Q1.Second_Amount, 0)
    END
    FROM #Tax_Report t
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS First_Amount
      FROM #Tax_Report
      WHERE Row_ID = @From_Row_ID) Q
      ON t.emp_ID = Q.Emp_ID
    INNER JOIN (SELECT
        Emp_ID
       ,Amount_Col_Final AS Second_Amount
      FROM #Tax_Report
      WHERE Row_ID = @TO_ROW_ID) Q1
      ON t.emp_ID = Q1.Emp_ID
    WHERE t.Row_ID = @ROW_ID

  END
  ELSE
  IF @IS_TOTAL = 4 -- Added By Nilesh Patel on 23052019 for Formula
  BEGIN

  

    SET @TotalFormula = REPLACE(@TotalFormula, ' ', '')

    TRUNCATE TABLE #Tbl_Formula
    TRUNCATE TABLE #Tbl_Formula_Result
    TRUNCATE TABLE #Tbl_Result



    INSERT INTO #Tbl_Formula
      SELECT DISTINCT
        Emp_ID
       ,ID
       ,Data
       ,Data
      FROM dbo.Split(@TotalFormula, '#')
      CROSS JOIN #Tax_Report --Change by ronakk 26042023 
      WHERE Data <> ''
      ORDER BY Emp_ID, ID



    UPDATE TF
    SET TF.Formula_Value = ISNULL(t.Amount_Col_Final, 0)
    FROM #Tax_Report t
    INNER JOIN #Tbl_Formula TF
      ON t.Row_ID = TF.Formula_Name
      AND t.Emp_ID = TF.Emp_ID
    WHERE ISNUMERIC(TF.Formula_Name) > 0


    UPDATE tf
    SET tf.Formula_Value = 0
    FROM #Tbl_Formula tf
    WHERE NOT EXISTS (SELECT
        1
      FROM #Tax_Report t
      WHERE tf.Formula_Name = t.Row_ID
      AND t.Emp_ID = tf.Emp_ID)
    AND tf.Formula_Name LIKE '%[0-9]%'


    INSERT INTO #Tbl_Formula_Result
      SELECT
        S.Emp_ID
       ,STUFF((SELECT
            ' ' + Formula_Value
          FROM #Tbl_Formula t
          WHERE (t.Emp_ID = S.Emp_ID)
          ORDER BY t.Formula_Id ASC
          FOR XML PATH (''))
        , 1, 1, '') AS FormulaValue
       ,0
      FROM #Tbl_Formula S
      GROUP BY S.Emp_ID


	  


    --Commented by deepal
    SET @query = NULL;
    SELECT
      @query = COALESCE(@query + ' UNION ', '') + 'SELECT Emp_ID, Formula_Name, ' + Formula_Name + ' AS CalcValue 
					FROM #Tbl_Formula_Result WHERE Formula_Name = ''' + Formula_Name + ''' '
    FROM #Tbl_Formula_Result

    SET @query = 'INSERT INTO #Tbl_Result 
									' + @query

    EXEC (@query)



    UPDATE t
    SET t.Amount_Col_Final =
    CASE
      WHEN ISNULL(TR.Formula_Cal, 0) > @Max_Limit AND
        ISNULL(@Max_Limit, 0) <> 0 THEN @Max_Limit
      ELSE ISNULL(TR.Formula_Cal, 0)
    END
    FROM #Tax_Report t
    INNER JOIN #Tbl_Result TR
      ON t.Emp_ID = TR.Emp_ID
    WHERE t.Row_ID = @ROW_ID
  --Commented by deepal

  END

  FETCH NEXT FROM CUR_T INTO @IS_TOTAL, @ROW_ID, @From_Row_ID, @TO_ROW_ID, @Multiple_Row_ID, @Max_Limit, @Max_Limit_Compare_Row_ID, @Max_Limit_Compare_Type, @TotalFormula, @Exem_Ag_RowID
  END
  CLOSE CUR_T
  DEALLOCATE CUR_T
  
  UPDATE T
  SET Amount_Col_Final = 0
  FROM #Tax_Report T
  WHERE Field_Type = 2
  AND Amount_Col_Final < 0 -- Added Condition by Hardik 28/08/2018 for Arkray as they don't want to show Negative Taxable Amount

  UPDATE #Tax_Report
  SET Amount_Col_Final = 0
  FROM #Tax_Report t
  --WHERE t.Row_ID =138	 --- Commented by Hardik 27/04/2018
  WHERE t.Default_Def_Id = 9 -- For Conveyance Exemption -- Added by Hardik 27/04/2018
  AND EXISTS (SELECT
      1
    FROM T0240_Perquisites_Employee_Car PEC WITH (NOLOCK)
    WHERE PEC.Financial_Year = @fin_year
    AND PEC.emp_id = t.Emp_ID)


  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(M_AD_Amount, 0)
  FROM #Tax_Report t
  INNER JOIN T0210_Monthly_AD_Detail mad WITH (NOLOCK)
    ON t.emp_ID = mad.Emp_ID
    AND t.IT_Month = MONTH(mad.To_Date)
    AND t.IT_YEAR = YEAR(mad.To_Date)
  INNER JOIN T0050_AD_MAster am WITH (NOLOCK)
    ON mad.AD_ID = am.AD_ID
    AND AD_DEF_ID = 1
    AND mad.M_AD_Amount > 0   --Reguler TDS effected in salary

  -- Added by Hardik 05/06/2020 for Aculife as they deducted pending tax in Apr and May month under Allowance Name : "Income Tax Recovery"
  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(Qry.M_AD_Amount, 0)
  FROM #Tax_Report t
  INNER JOIN (SELECT
      SUM(M_AD_Amount) M_AD_Amount
     ,T.Emp_Id
     ,3 AS Month_1
     ,YEAR(@To_Date) AS Year_1
    FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK)
    INNER JOIN #Tax_Report T
      ON mad.Emp_Id = T.Emp_ID
      AND T.IT_Month = 3
      AND T.IT_YEAR = YEAR(@To_Date)
    INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK)
      ON mad.AD_ID = AM.AD_ID
      AND mad.Cmp_ID = AM.Cmp_ID
    WHERE ((MONTH(mad.To_Date) = MONTH(DATEADD(MM, 1, @To_Date))
    AND YEAR(mad.To_Date) = YEAR(@To_Date))
    OR (MONTH(mad.To_Date) = MONTH(DATEADD(MM, 2, @To_Date))
    AND YEAR(mad.To_Date) = YEAR(@To_Date)))
    AND AD_Name = 'Income Tax Recovery'
    GROUP BY T.Emp_ID) Qry
    ON t.Emp_ID = Qry.Emp_ID
    AND T.IT_Month = Month_1
    AND T.IT_YEAR = Year_1


  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Amount_Col_Final, 0) + ISNULL(mad.TDS, 0)
  FROM #Tax_Report t
  INNER JOIN (SELECT
      SUM(ISNULL(tds, 0)) AS tds
     ,EONES.Emp_Id
     ,MONTH(for_date) AS _Month
     ,YEAR(For_Date) AS _year
    FROM T0210_ESIC_On_Not_Effect_on_Salary EONES WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON EONES.Emp_Id = EC.Emp_Id
    GROUP BY EONES.emp_id
            ,MONTH(for_date)
            ,YEAR(For_Date)) mad
    ON t.emp_ID = mad.Emp_ID
    AND t.IT_Month = _Month
    AND t.IT_YEAR = _year
    AND mad.tds > 0  --Extra Deducted TDS not effected on salary Component added by Rohit on  21072015


  --Added by Hardik 05/03/2019 for Additional TDS Paid through TDS Challan
  IF EXISTS (SELECT
        1
      FROM sys.syscolumns
      WHERE name LIKE 'Additional_Amount'
      AND id = OBJECT_ID('T0230_TDS_CHALLAN_DETAIL')) -- Added condition by Hardik 15/04/2019 As Some client has this column created and some has not created so it is giving error
  BEGIN
    UPDATE #Tax_Report
    SET Amount_Col_Final = ISNULL(Amount_Col_Final, 0) + ISNULL(TDS_Challan.Additional_Amount, 0)
    FROM #Tax_Report t
    INNER JOIN (SELECT
        TCD.Emp_Id
       ,TC.month
       ,TC.year
       ,SUM(ISNULL(TCD.Additional_Amount, 0)) AS Additional_Amount
      FROM T0220_TDS_CHALLAN TC WITH (NOLOCK)
      INNER JOIN T0230_TDS_CHALLAN_DETAIL TCD WITH (NOLOCK)
        ON TC.Challan_Id = TCD.Challan_Id
      WHERE TCD.Additional_Amount > 0
      GROUP BY TCD.Emp_Id
              ,TC.month
              ,TC.year) TDS_Challan
      ON t.emp_ID = TDS_Challan.Emp_ID
      AND t.IT_Month = TDS_Challan.month
      AND t.IT_YEAR = TDS_Challan.year
  END

  UPDATE #Tax_Report
  SET Amount_Col_Final = ISNULL(Amount_Col_Final, 0) + ISNULL(mad.Income_Tax_on_Bonus, 0)
  FROM #Tax_Report t
  INNER JOIN (SELECT
      SUM(ISNULL(Income_Tax_on_Bonus, 0)) AS Income_Tax_on_Bonus
     ,B.Emp_Id
     ,Bonus_Effect_Month AS Bonus_Effect_Month
     ,Bonus_Effect_Year AS Bonus_Effect_Year
    FROM t0180_bonus B WITH (NOLOCK)
    INNER JOIN #Emp_Cons EC
      ON B.Emp_Id = EC.Emp_Id
    GROUP BY B.emp_id
            ,Bonus_Effect_Month
            ,Bonus_Effect_Year) mad
    ON t.emp_ID = mad.Emp_ID
    AND t.IT_Month = Bonus_Effect_Month
    AND t.IT_YEAR = Bonus_Effect_Year
    AND mad.Income_Tax_on_Bonus > 0  --Extra Deducted TDS on Bonus and Exgratia amount added by Rohit on  19052016

	

  UPDATE #Tax_Report
  SET Amount_Col_Final = Amount_Col_Final + ISNULL(M_AD_Amount, 0)
  FROM #Tax_Report t
  INNER JOIN T0210_Monthly_AD_Detail mad WITH (NOLOCK)
    ON t.emp_ID = mad.Emp_ID
    AND t.IT_Month = MONTH(mad.To_Date)
    AND t.IT_YEAR = YEAR(mad.To_Date)
  INNER JOIN T0050_AD_MAster am
    ON mad.AD_ID = am.AD_ID
    AND AD_DEF_ID = 13
    AND mad.M_AD_Amount > 0  --Extra TDS not effected in salary added by Hasmukh 17092014


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
  DECLARE @Remain_Month NUMERIC
  DECLARE @Other_Paid_TDS_Amont NUMERIC
  DECLARE @Return_Tax_Amount_Actual NUMERIC	--Ankit 27042016
  SET @Return_Tax_Amount_Actual = 0
  --DECLARE CUR_AD_Tax CURSOR FOR 
  --	SELECT Distinct EMP_ID ,Increment_ID,Month_Count FROM #Tax_Report 	
  --OPEN CUR_AD_Tax 
  --FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID,@Month_Count
  --WHILE @@FETCH_STATUS =0
  --	BEGIN

  --		set @Month_Sal =0

  --		select @Month_Sal = isnull(count(emp_ID),0) From T0200_Monthly_Salary where Emp_ID=@emp_ID and Month_St_Date >=@From_Date and Month_st_Date <=@To_Date and Month_St_Date <=@Month_En_Date


  --		if @Month_Count -( @Month_Sal ) > 0
  --                              Begin 
  --								set @Month_Diff = @Month_Count -(@Month_Sal)

  --							end	
  --		else 
  --                            Begin 
  --							set @Month_Diff =0
  --						 end			
  --		EXECUTE SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Diff,0

  --		FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID	,@Month_Count	
  --	END
  --CLOSE CUR_AD_Tax
  --DEALLOCATE CUR_AD_Tax



  --DECLARE CUR_T CURSOR FOR 
  --	SELECT IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
  --			Max_Limit_Compare_Type 
  --	FROM #Tax_Report  WHERE IS_TOTAL > 0 order by Row_ID

  --OPEN CUR_T 
  --FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type 
  --while @@fetch_status =0
  --	begin
  --		set @sqlQuery =''
  --		if @is_Total =1 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
  --			begin



  --				update #Tax_Report
  --				set Amount_Col_Final =isnull(Q.sum_amount,0)
  --				from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --					Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID							


  --			end
  --		else if @is_Total =1  and rtrim(@Multiple_Row_ID) <> ''
  --			begin

  --					update #Tax_Report
  --								set Amount_Col_Final =isnull(Q.sum_amount,0)
  --								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --								Row_ID in (select Data From dbo.Split(@Multiple_Row_ID,'#') where Data >0) group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID 

  ----				set @sqlQuery = 'update #Tax_Report
  ----								set Amount_Col_Final =isnull(Q.sum_amount,0)
  ----								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  ----								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '

  ----				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
  --			end
  --		else if @is_Total =2 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
  --			begin
  --				update #Tax_Report
  --				set Amount_Col_Final =isnull(Q.First_Amount,0) - isnull(Q1.Second_Amount,0)
  --				from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
  --					Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
  --					inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
  --					Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
  --				Where t.Row_ID =@Row_ID													

  --			end
  --		else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 and @Max_Limit > 0
  --			begin

  --				update #Tax_Report
  --				set Amount_Col_Final = 
  --				case when isnull(Q.Sum_amount,0)  <=   @Max_Limit Then
  --							isnull(Q.Sum_amount,0)
  --					 when  isnull(Q.Sum_amount,0) > 0 then
  --							@Max_Limit
  --					else
  --						0
  --					end 
  --				from #Tax_Report t inner join  (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
  --					Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID
  --				Where t.Row_ID =@Row_ID													


  --			end
  --		else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
  --			begin

  --				update #Tax_Report
  --				set Amount_Col_Final =
  --				case when isnull(Q.First_Amount,0)  <=   isnull(Q1.Second_Amount,0) Then
  --							isnull(Q.First_Amount,0)
  --					else
  --							isnull(Q1.Second_Amount,0)
  --					end 
  --				from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
  --					Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
  --					inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
  --					Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
  --				Where t.Row_ID =@Row_ID																								
  --			end

  --		FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type
  --	end
  --close cur_T 
  --deallocate Cur_T 
  

   

  DECLARE CUR_TAX CURSOR FOR SELECT
    EMP_ID
   ,Amount_Col_Final
   ,Increment_ID
   ,Tax_Regime
  FROM #Tax_Report
  WHERE Field_Type = 2
  OPEN CUR_TAX
  FETCH NEXT FROM CUR_TAX INTO @Emp_ID, @TAXABLE_AMOUNT, @Increment_ID, @TAX_REGIME
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

  SELECT
    @Incentive_Amount = ISNULL(SUM(Amount_Col_Final), 0)
  FROM #Tax_Report
  WHERE Emp_ID = @Emp_ID
  AND ISNULL(Is_Incentive, 0) = 1  --ISNULL(Is_Salary_comp,0) = 1 


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
                                  ,@SurCharge_per
                                  ,@Relief_87A_Amount OUTPUT
                                  ,@Return_Tax_Amount_Actual OUTPUT
                                  ,@TAX_REGIME



    SET @Return_Tax_Amount_Inc = @Return_Tax_Amount_Inc + @ED_Cess_Inc
  END
  --check this		
  

  EXECUTE dbo.SP_IT_TAX_CALCULATION @Cmp_ID
                                   ,@Emp_ID
                                   ,@To_Date
                                   ,@TAXABLE_AMOUNT
                                   ,@Return_Tax_Amount OUTPUT
                                   ,@Surcharge_amount OUTPUT
                                   ,@ED_Cess OUTPUT
                                   ,@ED_Cess_Per
                                   ,@SurCharge_per
                                   ,@Relief_87A_Amount OUTPUT
                                   ,@Return_Tax_Amount_Actual OUTPUT
                                   ,@TAX_REGIME

  --check this 						
  UPDATE #Tax_Report
  SET Amount_Col_Final = @Return_Tax_Amount
  WHERE Emp_ID = @Emp_ID
  AND Default_Def_ID = @Cont_Total_Tax

  --------- Relief_87A_Amount Add By Hasmukh 20-Dec-13------------
  DECLARE @Actual_IT_Amount AS NUMERIC(18, 2)
  --DECLARE @Sec_87A_Amount NUMERIC(18,2)



  --IF YEAR(@From_Date) >= 2016		/* Relief Limit Change 2000 to 5000 effect From Year 2016-2017  --Ankit 25042016	*/
  --	If YEAR(@From_Date) >= 2017
  --		SET @Sec_87A_Amount = 2500
  --	ELSE
  --		SET @Sec_87A_Amount = 5000
  --ELSE	
  --	SET @Sec_87A_Amount = 2000


  IF @Relief_87A_Amount > 0
    AND YEAR(@To_Date) >= 2014
  BEGIN



    UPDATE #Tax_Report
    SET Amount_Col_Final = @Return_Tax_Amount_Actual -- Amount_Col_Final + @Sec_87A_Amount
    WHERE Emp_ID = @Emp_ID
    AND Default_Def_ID = 101


    SELECT
      @Actual_IT_Amount = Amount_Col_Final
    FROM #Tax_Report
    WHERE Emp_ID = @Emp_ID
    AND Default_Def_ID = 101

    UPDATE #Tax_Report
    SET Amount_Col_Final = @Relief_87A_Amount --@Sec_87A_Amount /* CASE WHEN @Sec_87A_Amount > @Return_Tax_Amount_Actual THEN @Return_Tax_Amount_Actual ELSE @Sec_87A_Amount END  */
    WHERE Emp_ID = @Emp_ID
    AND Default_Def_ID = -102


    UPDATE #Tax_Report
    SET Amount_Col_Final = @Actual_IT_Amount - @Relief_87A_Amount --@Sec_87A_Amount /* CASE WHEN @Sec_87A_Amount > @Return_Tax_Amount_Actual THEN @Return_Tax_Amount_Actual ELSE @Sec_87A_Amount END  */
    WHERE Emp_ID = @Emp_ID
    AND Default_Def_ID = -103
  END
  -------------------End---------------------------

  UPDATE #Tax_Report
  SET Amount_Col_Final = @ED_Cess
  WHERE Emp_ID = @Emp_ID
  AND Default_Def_ID = @Cont_ED_Cess

  SET @Other_Paid_TDS_Amont = 0
  SELECT
    @Other_Paid_TDS_Amont = ISNULL(SUM(AMOUNT), 0)
  FROM T0100_IT_DECLARATION ID WITH (NOLOCK)
  LEFT OUTER JOIN T0070_IT_MASTER IM WITH (NOLOCK)
    ON ID.IT_ID = IM.IT_ID
      AND IM.Cmp_ID = IM.Cmp_ID
  WHERE Emp_ID = @Emp_ID
  AND For_Date >= @From_Date
  AND for_Date <= @To_Date
  AND For_Date <= @Month_En_Date
  AND IM.IT_Def_ID = 10

  
  --Start-------1-Cr.--Surcharge---------------------------------------------------Mitesh--
  DECLARE @Taxabel_Income_S NUMERIC(18, 2)
  --select @Taxabel_Income_S = Amount_Col_Final from #Tax_Report WHERE field_type = 2 AND emp_id = @EMP_ID
  SET @Taxabel_Income_S = @TAXABLE_AMOUNT

   


  IF @Taxabel_Income_S >= 10000000
    OR (@Taxabel_Income_S >= 5000000
    AND YEAR(@From_Date) >= 2017)
  BEGIN


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

    SELECT
      @net_Income_Range = net_income_Range
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
      ELSE
      IF @Taxabel_Income_S > 10000000
        SET @Surchage_Percentage = 15
      ELSE
      IF @Taxabel_Income_S < 10000000
        SET @Surchage_Percentage = 15
    END
    ELSE  -- Added condition for New Slab in 2019 Budget
    BEGIN
      IF @Taxabel_Income_S >= 5000000
        AND @Taxabel_Income_S < 10000000
        SET @Surchage_Percentage = 10
      ELSE
      IF @Taxabel_Income_S >= 10000000
        AND @Taxabel_Income_S < 20000000
        SET @Surchage_Percentage = 15
      ELSE
      IF @Taxabel_Income_S >= 20000000
        AND @Taxabel_Income_S <= 50000000
        SET @Surchage_Percentage = 25
      ELSE
      IF @Taxabel_Income_S > 50000000
        SET @Surchage_Percentage = 37
    END

    -- Added By Sajid 15042023 for Surcharge Changes in Tax Regime 2 FY 23-24 Reduce Surcharge 25% Instead of 37%
    IF YEAR(@From_Date) >= 2023
      AND @TAX_REGIME = 'Tax Regime 2'
      OR (@TAX_REGIME IS NULL
      OR @TAX_REGIME = '0')
    BEGIN
      IF @Taxabel_Income_S >= 5000000
        AND @Taxabel_Income_S < 10000000
        SET @Surchage_Percentage = 10
      ELSE
      IF @Taxabel_Income_S >= 10000000
        AND @Taxabel_Income_S < 20000000
        SET @Surchage_Percentage = 15
      ELSE
      IF @Taxabel_Income_S >= 20000000
        SET @Surchage_Percentage = 25
    END


    --SS	
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
    --	Set @Surcharge_Amt= (@Return_Tax_Amount * 10/100)
    --ELSE
    --	Set @Surcharge_Amt= (@Return_Tax_Amount * 12/100)	

    SET @Surcharge_Amt = (@Return_Tax_Amount * @Surchage_Percentage / 100)


    SET @tax_Payable_On_limit_Const_S = ROUND((@Taxabel_Income_S - @limt_Const_S) * 30 / 100, 0)

    IF (@Taxabel_Income_S) <= @net_Income_Range  -- 10510540
    BEGIN
      SET @Marginal_Relief_S = (@Taxabel_Income_S - @limt_Const_S) - @tax_Payable_On_limit_Const_S
    END
    ELSE
      SET @Marginal_Relief_S = 0

    IF (@Taxabel_Income_S) <= @net_Income_Range  --10510540 
      SET @Actual_Surcharge_S =
      CASE
        WHEN @Surcharge_Amt < @Marginal_Relief_S THEN @Surcharge_Amt
        ELSE @Marginal_Relief_S
      END
    ELSE
      SET @Actual_Surcharge_S =
      CASE
        WHEN @Surcharge_Amt > @Marginal_Relief_S THEN @Surcharge_Amt
        ELSE @Marginal_Relief_S
      END



    UPDATE #Tax_Report
    SET Amount_Col_Final = @Actual_Surcharge_S
    WHERE default_def_id = @Cont_Surcharge
    AND emp_id = @Emp_ID



    SET @TAXABLE_AMOUNT_with_Sur = @Return_Tax_Amount + @Actual_Surcharge_S

    SET @Return_Tax_Amount = @TAXABLE_AMOUNT_with_Sur

    -- deepal Resolved in 28308 Multiple time Surcharge is getting add DT :- 12-04-24 Commented
    --EXECUTE dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date, @TAXABLE_AMOUNT,@TAXABLE_AMOUNT_with_Sur OUTPUT
    --	,@Actual_Surcharge_S OUTPUT ,@ED_Cess OUTPUT ,@ED_Cess_Per ,@SurCharge_Per, @Relief_87A_Amount output,@Return_Tax_Amount_Actual OUTPUT, @TAX_REGIME
    -- deepal Resolved in 28308 Multiple time Surcharge is getting add DT :- 12-04-24 Commented




    --UPDATE #Tax_Report 
    --	SET Amount_Col_Final = @Return_Tax_Amount 
    --	WHERE Emp_ID =@Emp_ID AND Default_Def_ID = @Cont_Total_Tax

    UPDATE #Tax_Report
    SET Amount_Col_Final = @ED_Cess
    WHERE Emp_ID = @Emp_ID
    AND Default_Def_ID = @Cont_ED_Cess

  END




  --End-------1-Cr.--Surcharge---------------------------------------------------Mitesh--
  

  UPDATE #Tax_Report
  SET Amount_Col_Final = @Other_Paid_TDS_Amont
  WHERE Emp_ID = @Emp_ID
  AND (Default_Def_ID = @Cont_Less_TDS)


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
  WHERE Emp_ID = @Emp_ID
  AND Default_Def_ID = @Cont_Total_tax_Lia

  SET @Return_Tax_Amount = (@Return_Tax_Amount + @ED_Cess) - @Other_Paid_TDS_Amont --- @Relief_amount

  SET @M_AD_Amount = 0

  -- Commented by Hardik 05/03/2019 As Tax Paid calculate from #Tax_Report table
  /*
	SELECT @M_AD_Amount = ISNULL(SUM(M_AD_Amount),0)  FROM T0210_Monthly_AD_Detail mad INNER JOIN
			T0050_AD_MAster am ON mad.AD_ID= am.AD_ID AND mad.cmp_id = am.cmp_id AND (AD_DEF_ID = 1 or AD_DEF_ID = 13)  -- ad Def id 1 = TDS + ad Def id 13 = extra TDS added by Hasmukh 17092014
	WHERE Emp_ID =@Emp_ID AND To_Date >=@From_Date AND To_Date <=@To_Date AND To_Date <=@Month_En_Date
       
        
	SELECT @M_AD_Amount = @M_AD_Amount + ISNULL(SUM(mad.TDS),0)  FROM T0210_ESIC_On_Not_Effect_on_Salary mad   -- TDS on Not Effect on Salary Componenet added by rohit on 21072015
	WHERE Emp_ID =@Emp_ID AND For_Date >=@From_Date AND For_Date <=@To_Date AND For_Date  <=@Month_En_Date
	*/
	 
  --- Added by Hardik 05/03/2019
  SELECT
    @M_AD_Amount = SUM(Amount_Col_Final)
  FROM #Tax_Report
  WHERE Emp_ID = @Emp_ID
  AND ISNULL(Is_TaxPaid_Rec, 0) = 1

  -- Added by Hardik 05/06/2020 for Aculife as they deducted pending tax in Apr and May month under Allowance Name : "Income Tax Recovery"
  SELECT
    @M_AD_Amount = @M_AD_Amount + ISNULL(Qry.M_AD_Amount, 0)
  FROM #Tax_Report t
  INNER JOIN (SELECT
      SUM(M_AD_Amount) M_AD_Amount
     ,T.Emp_Id
     ,3 AS Month_1
     ,YEAR(@To_Date) AS Year_1
    FROM T0210_Monthly_AD_Detail mad WITH (NOLOCK)
    INNER JOIN #Tax_Report T
      ON mad.Emp_Id = T.Emp_ID
      AND T.IT_Month = 3
      AND T.IT_YEAR = YEAR(@To_Date)
    INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK)
      ON mad.AD_ID = AM.AD_ID
      AND mad.Cmp_ID = AM.Cmp_ID
    WHERE ((MONTH(mad.To_Date) = MONTH(DATEADD(MM, 1, @To_Date))
    AND YEAR(mad.To_Date) = YEAR(@To_Date))
    OR (MONTH(mad.To_Date) = MONTH(DATEADD(MM, 2, @To_Date))
    AND YEAR(mad.To_Date) = YEAR(@To_Date)))
    AND AD_Name = 'Income Tax Recovery'
    AND mad.Emp_ID = @Emp_ID
    GROUP BY T.Emp_ID) Qry
    ON t.Emp_ID = Qry.Emp_ID
      AND T.IT_Month = Month_1
      AND T.IT_YEAR = Year_1

  UPDATE #Tax_Report
  SET Amount_Col_Final = @Return_Tax_Amount + @Other_Paid_TDS_Amont
     ,Y_Surcharge_Amount = @Surcharge_amount
     ,Y_Edu_Cess_Amount = @ED_Cess			            --+ @Relief_amount
     ,Y_IT_Paid_Amount = @M_AD_Amount
     ,Total_TAxable_Amount = @TAXABLE_AMOUNT
     ,Incentive_Tax = @Return_Tax_Amount_Inc
     ,Incentive_Tax_Amount = @Incentive_Amount
  WHERE Emp_ID = @Emp_ID
  AND (Default_Def_ID = @Cont_Net_Lia)

  UPDATE #Tax_Report
  SET Amount_Col_Final = @M_AD_Amount
  WHERE Emp_ID = @Emp_ID
  AND (Default_Def_ID = @Cont_Paid_Tax)

  UPDATE #Tax_Report
  SET Amount_Col_Final = @Return_Tax_Amount - @M_AD_Amount
  WHERE Emp_ID = @Emp_ID
  AND (Default_Def_ID = @Cont_Due_Tax)


  UPDATE #Tax_Report
  SET Y_IT_Paid_Amount = Y_IT_Paid_Amount + @Other_Paid_TDS_Amont --+ @Relief_amount 
  WHERE Emp_ID = @Emp_ID
  AND (Default_Def_ID = @Cont_Net_Lia)

  
  -- /////////// Added By tejas for more than 5cr  income ////////////////////////////
  IF @Taxabel_Income_S >= 50000000
  BEGIN
	IF (select top 1 Field_Name from #Tax_Report where Emp_ID = @Emp_ID and Field_Name = 'Margin relief' and From_Date = @From_Date and To_Date = @To_Date) = 'Margin relief' 
		BEGIN
			select 123
			DECLARE @MR1 numeric(18,2), @MR2 numeric(18,2),@MR3 numeric(18,2);

			select @MR1 = ISNULL(Amount_Col_Final,0.0) from #Tax_Report where Row_ID = 365 and Emp_ID = @Emp_ID
			select @MR2 = @MR1 -((Amount_Col_Final-50000000)*0.3) from #Tax_Report where Row_ID = 305 and Emp_ID = @Emp_ID
			select @MR3 =   (select ISNULL(Amount_Col_Final,0) from #Tax_Report where Row_ID = 367 and Emp_ID = @Emp_ID) - ROUND(((Amount_Col_Final-50000000)*0.7)+(0.25*@MR2),0)  
			from #Tax_Report where Row_ID = 305 and Emp_ID = @Emp_ID
			
			UPDATE #Tax_Report
			SET Amount_Col_Final = @mr3 + ROUND((@mr3*0.04),0) from #Tax_Report where Row_ID = 371 and Emp_ID = @Emp_ID
			UPDATE #Tax_Report
			SET Amount_Col_Final = (Amount_Col_Final - (@mr3 + FLOOR((@mr3*0.04)))) from #Tax_Report where  Emp_ID = @Emp_ID and Row_ID in (373,388) 
		END
  END
  --//////
  FETCH NEXT FROM CUR_TAX INTO @Emp_ID, @TAXABLE_AMOUNT, @Increment_ID, @TAX_REGIME
  END
  CLOSE CUR_TAX
  DEALLOCATE CUR_TAX



  --UPdate #Tax_Report 
  --set Amount_Col_Final = SALARY_AMOUNT
  --From #Tax_Report Tr inner join (SELECT MS.EMP_ID ,SUM(MS.SALARY_AMOUNT)SALARY_AMOUNT FROM 
  --										T0200_MONTHLY_SALARY MS INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
  --										WHERE MS.MONTH_sT_DATE >=@FROM_DATE AND MS.MONTH_ST_DATE <=@TO_DATE 
  --									GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
  --WHERE DEFAULT_DEF_ID =@Cont_Annual_Sal


   

  UPDATE #Tax_Report
  SET Amount_Col_1 = Amount_Col_Final
  WHERE ISNULL(Col_No, 0) IN (0, 1)


  UPDATE #Tax_Report
  SET Amount_Col_2 = Amount_Col_Final
  WHERE ISNULL(Col_No, 0) = 2

  UPDATE #Tax_Report
  SET Amount_Col_3 = Amount_Col_Final
  WHERE ISNULL(Col_No, 0) = 3

  UPDATE #Tax_Report
  SET Amount_Col_4 = Amount_Col_Final
  WHERE ISNULL(Col_No, 0) = 4

  UPDATE #Tax_Report
  SET Exempted_Amount = q.Amount_Col_Final
  FROM #Tax_Report t
  INNER JOIN (SELECT
      Amount_Col_Final
     ,Exem_Againt_row_Id
     ,Emp_ID
    FROM #Tax_Report
    WHERE ISNULL(Exem_Againt_row_Id, 0) > 0
    AND Amount_Col_Final > 0) q
    ON t.Row_ID = q.Exem_Againt_row_Id
    AND t.Emp_Id = q.emp_ID


	

  IF @Sp_Call_For = 'Tax Planning'
  BEGIN

    DECLARE @Less_TDS NUMERIC(18, 2)

    SET @Remain_Month = 0
    SET @Less_TDS = 0

    SELECT
      @Remain_Month = DATEDIFF(MM, @Month_En_Date, @To_Date) + 1
    --select @Less_TDS = Amount_Col_Final from #Tax_Report where Default_Def_Id = 120

    --set @Less_TDS = ISNULL(@Less_TDS,0)

    IF @Remain_Month > 0
    BEGIN
      UPDATE #Tax_Report
      --Set		M_IT_Amount		  = Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount, 
      --		M_Edu_Cess_Amount = (Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount) * @ED_Cess_Per * 0.01						

      --Set		M_IT_Amount		  = (((Amount_col_final - (Y_IT_PAID_Amount + @Less_TDS))/@Remain_Month) + Incentive_Tax) - ((((Amount_col_final - (Y_IT_PAID_Amount))/@Remain_Month) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))),
      --		M_Edu_Cess_Amount = (((Amount_col_final - (Y_IT_PAID_Amount + @Less_TDS))/@Remain_Month) + Incentive_Tax) * (@ED_Cess_Per/(100 + @ED_Cess_Per))

      --(Y_IT_PAID_Amount + @Less_TDS)												
      SET M_IT_Amount = (((Amount_Col_Final - (Y_IT_Paid_Amount)) / @Remain_Month) + Incentive_Tax) - ((((Amount_Col_Final - (Y_IT_Paid_Amount)) / @Remain_Month) + Incentive_Tax) * (@ED_Cess_Per / (100 + @ED_Cess_Per)))
         ,M_Edu_Cess_Amount = (((Amount_Col_Final - (Y_IT_Paid_Amount)) / @Remain_Month) + Incentive_Tax) * (@ED_Cess_Per / (100 + @ED_Cess_Per))

      WHERE Default_Def_ID = @Cont_Net_Lia
    --select * from #Tax_Report Where Default_Def_ID = @Cont_Net_Lia
    END
    ELSE
    BEGIN
      --Set		M_IT_Amount		  = Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount, 
      --		M_Edu_Cess_Amount = (Amount_col_final - (Incentive_Tax /Month_Count)*(@Remain_Month) -Y_IT_PAID_Amount) * @ED_Cess_Per * 0.01						


      UPDATE #Tax_Report
      SET M_IT_Amount = ((Amount_Col_Final - (Y_IT_Paid_Amount)) + Incentive_Tax) - (((Amount_Col_Final - Y_IT_Paid_Amount) + Incentive_Tax) * (@ED_Cess_Per / (100 + @ED_Cess_Per)))
         ,M_Edu_Cess_Amount = ((Amount_Col_Final - (Y_IT_Paid_Amount)) + Incentive_Tax) * (@ED_Cess_Per / (100 + @ED_Cess_Per))

      WHERE Default_Def_ID = @Cont_Net_Lia

    END

    UPDATE #Tax_Report
    SET M_IT_Amount = 0
       ,M_Edu_Cess_Amount = 0
    WHERE Default_Def_ID = @Cont_Net_Lia
    AND M_IT_Amount < 0

		
 

    -- Changed By Ali 22112013 EmpName_Alias
    SELECT
      tr.*
     ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
     ,EM.Alpha_Emp_Code AS emp_code
     ,EM.Alpha_Emp_Code
     ,EM.Date_Of_Join				-- Added By Hiral 05 June,2013
     ,CASE
        WHEN tr.Tax_Regime IS NULL OR
          tr.Tax_Regime = '' THEN ''
        WHEN tr.Tax_Regime = 'Tax Regime 1' THEN 'Old Regime'
        WHEN tr.Tax_Regime = 'Tax Regime 2' THEN 'New Regime'
      END AS Regime
     ,CASE
        WHEN tr.Tax_Regime IS NULL OR
          tr.Tax_Regime = '' THEN	--added by Krushna 08042020
          'clsinactive1'
        WHEN tr.Tax_Regime = 'Tax Regime 1' THEN 'clsinactive'
        ELSE 'clsactive'
      END AS Activeclass
    FROM #Tax_Report tr
    LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK)
      ON tr.EMP_ID = EM.EMP_ID
    WHERE Default_Def_ID = @Cont_Net_Lia
    AND tr.M_IT_Amount > 0
    ORDER BY tr.Emp_ID, tr.Row_ID
    --Start Added by Niraj (09062022)

    --added by deepal on 06092023
    IF @ConstEmpid <> 0
    BEGIN

      -- Changed By Ali 22112013 EmpName_Alias
      SELECT
        tr.*
       ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
       ,EM.Alpha_Emp_Code AS emp_code
       ,EM.Alpha_Emp_Code
       ,EM.Date_Of_Join				-- Added By Hiral 05 June,2013
       ,CASE
          WHEN tr.Tax_Regime IS NULL OR
            tr.Tax_Regime = '' THEN ''
          WHEN tr.Tax_Regime = 'Tax Regime 1' THEN 'Old Regime'
          WHEN tr.Tax_Regime = 'Tax Regime 2' THEN 'New Regime'
        END AS Regime
       ,CASE
          WHEN tr.Tax_Regime IS NULL OR
            tr.Tax_Regime = '' THEN	--added by Krushna 08042020
            'clsinactive1'
          WHEN tr.Tax_Regime = 'Tax Regime 1' THEN 'clsinactive'
          ELSE 'clsactive'
        END AS Activeclass
      FROM #Tax_Report tr
      LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK)
        ON tr.EMP_ID = EM.EMP_ID
      WHERE Default_Def_ID = @Cont_Net_Lia
      AND tr.M_IT_Amount > 0
      AND tr.Emp_ID = @ConstEmpid
      ORDER BY tr.Emp_ID, tr.Row_ID
    END
    ELSE
    BEGIN
      SELECT
        tr.*
       ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
       ,EM.Alpha_Emp_Code AS emp_code
       ,EM.Alpha_Emp_Code
       ,EM.Date_Of_Join				-- Added By Hiral 05 June,2013
       ,CASE
          WHEN tr.Tax_Regime IS NULL OR
            tr.Tax_Regime = '' THEN ''
          WHEN tr.Tax_Regime = 'Tax Regime 1' THEN 'Old Regime'
          WHEN tr.Tax_Regime = 'Tax Regime 2' THEN 'New Regime'
        END AS Regime
       ,CASE
          WHEN tr.Tax_Regime IS NULL OR
            tr.Tax_Regime = '' THEN	--added by Krushna 08042020
            'clsinactive1'
          WHEN tr.Tax_Regime = 'Tax Regime 1' THEN 'clsinactive'
          ELSE 'clsactive'
        END AS Activeclass
      FROM #Tax_Report tr
      LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK)
        ON tr.EMP_ID = EM.EMP_ID
      WHERE Default_Def_ID = @Cont_Net_Lia
      AND tr.M_IT_Amount > 0
      ORDER BY tr.Emp_ID, tr.Row_ID
    END
    --added by deepal on 06092023


    --Start Added by Niraj (09062022)
    IF @Sp_Call_For = 'Tax Planning'
      AND @Salary_Cycle_id = 0
    BEGIN
      UPDATE Salary_Temp_Table
      SET IT_M_Amount += (SELECT
          ISNULL(MAX(M_IT_Amount), 0) + ISNULL(MAX(M_Edu_Cess_Amount), 0)
        FROM #Tax_Report)
    END
  --End Added by Niraj (09062022)	
  END
  ELSE
  IF @Sp_Call_For = 'Salary Slip'
  BEGIN
    -- Changed By Ali 22112013 EmpName_Alias
    SELECT
      Row_ID
     ,SPACE(Concate_Space) + FIELD_NAME AS FIELD_NAME
     ,Amount_Col_Final
     ,Amount_Col_1
     ,Amount_Col_2
     ,Amount_Col_3
     ,Amount_Col_4
     ,Default_def_ID
     ,AD_ID
     ,IT_ID
     ,tr.Emp_ID
     ,EM.Emp_Code
     ,EM.Alpha_Emp_Code
     ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
     ,DM.Desig_Name
     ,EM.Date_Of_Join
     ,EM.Pan_No
     ,@From_Date P_From_Date
     ,@To_Date P_To_Date
     ,Is_Show
     ,Concate_Space
     ,Exempted_Amount
     ,I_Q.Branch_ID
     ,CASE
        WHEN EM.Date_Of_Join > @From_Date THEN EM.Date_Of_Join
        ELSE @From_Date
      END AS H_From_date
     ,CASE
        WHEN EM.Emp_Left_date < @To_Date THEN EM.Emp_Left_date
        ELSE @To_Date
      END AS H_To_test
     ,tr.Field_Type
     ,Show_In_SalarySlip
     ,--SPACE(Concate_Space)+ Display_Name_For_SalarySlip as Display_Name_For_SalarySlip
      Display_Name_For_SalarySlip
     ,tr.Amount_Col_Actual
     ,tr.Amount_Col_Assumed
    FROM #Tax_Report tr
    LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
      ON tr.EMP_ID = EM.EMP_ID
    INNER JOIN (SELECT
        I.Emp_Id
       ,Grd_ID
       ,Branch_ID
       ,Cat_ID
       ,Desig_ID
       ,Dept_ID
       ,type_id
      FROM T0095_Increment I WITH (NOLOCK)
      INNER JOIN (SELECT
          MAX(Increment_ID) AS Increment_ID
         ,Emp_ID
        FROM T0095_Increment WITH (NOLOCK)    -- Ankit 11092014 for Same Date Increment
        WHERE Increment_Effective_date <= @To_Date
        AND Cmp_ID = @Cmp_ID
        GROUP BY emp_ID) Qry
        ON I.Emp_ID = Qry.Emp_ID
        AND I.Increment_ID = Qry.Increment_ID) I_Q
      ON EM.Emp_ID = I_Q.Emp_ID
    LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)
      ON I_Q.Desig_Id = DM.Desig_ID
    WHERE Show_In_SalarySlip = 1
    ORDER BY tr.Emp_ID, tr.Row_ID
  END
  ELSE
  IF @Sp_Call_For = 'Full & Final'  --Added by Hardik 11/10/2014
  BEGIN

    SELECT
      tr.Emp_ID
     ,tr.Amount_Col_Final
    FROM #Tax_Report tr
    LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK)
      ON tr.EMP_ID = EM.EMP_ID
    WHERE Default_Def_ID = @Cont_Due_Tax
    ORDER BY tr.Emp_ID, tr.Row_ID

  END
  ELSE
  IF @Sp_Call_For = 'Taxable_Amount'  --Added by Rohit for taxable Amount get on 15072015
  BEGIN
    SELECT
      TR.Cmp_ID
     ,TR.EMP_ID
     ,Amount_Col_Final
     ,CASE
        WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth, GETDATE(), 'N', 'Y') AS NUMERIC(18, 2)) > 80 THEN 'V'
        WHEN CAST(dbo.F_GET_AGE(Date_Of_Birth, GETDATE(), 'N', 'Y') AS NUMERIC(18, 2)) > 60 THEN 'S'
        ELSE Gender
      END AS gender
     ,0
     ,0
    FROM #Tax_Report TR
    LEFT OUTER JOIN T0080_emp_Master EM WITH (NOLOCK)
      ON TR.EMP_ID = EM.EMP_ID
    WHERE Field_Type = 2
    ORDER BY emp_id

  END
  ELSE
  IF @Sp_Call_For = 'Export'
    OR @Sp_Call_For = 'Export_For_Actual'
  BEGIN
    IF CAST(@From_Date AS DATE) >= '2020-04-01'
    BEGIN

      -- Changed By Ali 22112013 EmpName_Alias

      SELECT
        Row_ID
       ,SPACE(Concate_Space) + FIELD_NAME AS FIELD_NAME
       ,Amount_Col_Final
       ,Amount_Col_1
       ,Amount_Col_2
       ,Amount_Col_3
       ,Amount_Col_4
       ,Default_def_ID
       ,AD_ID
       ,IT_ID
       ,tr.Emp_ID
       ,EM.Emp_Code
       ,EM.Alpha_Emp_Code
       ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
       ,DM.Desig_Name
       ,EM.Date_Of_Join
       ,EM.Pan_No
       ,@From_Date P_From_Date
       ,@To_Date P_To_Date
       ,Is_Show
       ,Concate_Space
       ,Exempted_Amount
       ,I_Q.Branch_ID
       ,CASE
          WHEN EM.Date_Of_Join > @From_Date THEN EM.Date_Of_Join
          ELSE @From_Date
        END AS H_From_date
       ,CASE
          WHEN EM.Emp_Left_date < @To_Date THEN EM.Emp_Left_date
          ELSE @To_Date
        END AS H_To_test
       ,tr.Field_Type
       ,Show_In_SalarySlip
       ,Display_Name_For_SalarySlip
       ,Column_24Q
       ,Amount_Col_Actual
       ,Amount_Col_Assumed
       ,DMM.Dept_Name
       ,BM.branch_name
       ,GM.Grd_Name
       ,          -----grade name added by aswini 12/01/2024
        CASE
          WHEN tr.Tax_Regime = 'Tax Regime 2' THEN 'New Regime'
          ELSE 'Old Regime'
        END AS Tax_Regime -- Added by Hardik 14/10/2020
      FROM #Tax_Report tr
      LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
        ON tr.EMP_ID = EM.EMP_ID
      INNER JOIN (SELECT
          I.Emp_Id
         ,Grd_ID
         ,Branch_ID
         ,Cat_ID
         ,Desig_ID
         ,Dept_ID
         ,type_id
        FROM T0095_Increment I WITH (NOLOCK)
        INNER JOIN (SELECT
            MAX(Increment_ID) AS Increment_ID
           ,Emp_ID
          FROM T0095_Increment WITH (NOLOCK)
          WHERE Increment_Effective_date <= @To_Date
          AND Cmp_ID = @Cmp_ID
          GROUP BY emp_ID) Qry
          ON I.Emp_ID = Qry.Emp_ID
          AND I.Increment_ID = Qry.Increment_ID) I_Q
        ON EM.Emp_ID = I_Q.Emp_ID
      LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)
        ON I_Q.Desig_Id = DM.Desig_ID
      LEFT JOIN t0040_department_master DMM WITH (NOLOCK)
        ON I_Q.Dept_ID = DMM.Dept_ID
      LEFT JOIN t0030_branch_master BM WITH (NOLOCK)
        ON I_Q.Branch_ID = BM.Branch_ID
      LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK)
        ON I_Q.Grd_ID = GM.Grd_ID     -----grade id added by aswini 12/01/2024
      ---Where Is_Show =1
      --where 1 = case when (AD_ID > 0 OR Rimb_ID >0) and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
      --and Is_Show =1 -- Added by rohit
      ORDER BY DMM.Dept_Name, tr.Emp_ID, tr.Row_ID
    END
    ELSE
    BEGIN
      -- Changed By Ali 22112013 EmpName_Alias

      SELECT
        Row_ID
       ,SPACE(Concate_Space) + FIELD_NAME AS FIELD_NAME
       ,Amount_Col_Final
       ,Amount_Col_1
       ,Amount_Col_2
       ,Amount_Col_3
       ,Amount_Col_4
       ,Default_def_ID
       ,AD_ID
       ,IT_ID
       ,tr.Emp_ID
       ,EM.Emp_Code
       ,EM.Alpha_Emp_Code
       ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
       ,DM.Desig_Name
       ,EM.Date_Of_Join
       ,EM.Pan_No
       ,@From_Date P_From_Date
       ,@To_Date P_To_Date
       ,Is_Show
       ,Concate_Space
       ,Exempted_Amount
       ,I_Q.Branch_ID
       ,CASE
          WHEN EM.Date_Of_Join > @From_Date THEN EM.Date_Of_Join
          ELSE @From_Date
        END AS H_From_date
       ,CASE
          WHEN EM.Emp_Left_date < @To_Date THEN EM.Emp_Left_date
          ELSE @To_Date
        END AS H_To_test
       ,tr.Field_Type
       ,Show_In_SalarySlip
       ,Display_Name_For_SalarySlip
       ,Column_24Q
       ,Amount_Col_Actual
       ,Amount_Col_Assumed
       ,DMM.Dept_Name
       ,BM.branch_name
       ,'' AS Tax_Regime
      FROM #Tax_Report tr
      LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
        ON tr.EMP_ID = EM.EMP_ID
      INNER JOIN (SELECT
          I.Emp_Id
         ,Grd_ID
         ,Branch_ID
         ,Cat_ID
         ,Desig_ID
         ,Dept_ID
         ,type_id
        FROM T0095_Increment I WITH (NOLOCK)
        INNER JOIN (SELECT
            MAX(Increment_ID) AS Increment_ID
           ,Emp_ID
          FROM T0095_Increment WITH (NOLOCK)
          WHERE Increment_Effective_date <= @To_Date
          AND Cmp_ID = @Cmp_ID
          GROUP BY emp_ID) Qry
          ON I.Emp_ID = Qry.Emp_ID
          AND I.Increment_ID = Qry.Increment_ID) I_Q
        ON EM.Emp_ID = I_Q.Emp_ID
      LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)
        ON I_Q.Desig_Id = DM.Desig_ID
      LEFT JOIN t0040_department_master DMM WITH (NOLOCK)
        ON I_Q.Dept_ID = DMM.Dept_ID
      LEFT JOIN t0030_branch_master BM WITH (NOLOCK)
        ON I_Q.Branch_ID = BM.Branch_ID
      ---Where Is_Show =1
      --where 1 = case when (AD_ID > 0 OR Rimb_ID >0) and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
      --and Is_Show =1 -- Added by rohit
      ORDER BY DMM.Dept_Name, tr.Emp_ID, tr.Row_ID

    END

  END
  ELSE
  IF @Sp_Call_For = 'Form24Q'
  BEGIN
    -- Changed By Ali 22112013 EmpName_Alias
    SELECT
      Row_ID
     ,SPACE(Concate_Space) + FIELD_NAME AS FIELD_NAME
     ,Amount_Col_Final
     ,Amount_Col_1
     ,Amount_Col_2
     ,Amount_Col_3
     ,Amount_Col_4
     ,Default_def_ID
     ,AD_ID
     ,IT_ID
     ,tr.Emp_ID
     ,EM.Emp_Code
     ,EM.Alpha_Emp_Code
     ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
     ,DM.Desig_Name
     ,EM.Date_Of_Join
     ,EM.Pan_No
     ,@From_Date P_From_Date
     ,@To_Date P_To_Date
     ,Is_Show
     ,Concate_Space
     ,Exempted_Amount
     ,I_Q.Branch_ID
     ,CASE
        WHEN EM.Date_Of_Join > @From_Date THEN EM.Date_Of_Join
        ELSE @From_Date
      END AS H_From_date
     ,CASE
        WHEN EM.Emp_Left_date < @To_Date THEN EM.Emp_Left_date
        ELSE @To_Date
      END AS H_To_test
     ,tr.Field_Type
     ,Show_In_SalarySlip
     ,Display_Name_For_SalarySlip
     ,Column_24Q
     ,Amount_Col_Actual
     ,Amount_Col_Assumed
     ,DMM.Dept_Name
     ,BM.branch_name
    FROM #Tax_Report tr
    LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
      ON tr.EMP_ID = EM.EMP_ID
    INNER JOIN (SELECT
        I.Emp_Id
       ,Grd_ID
       ,Branch_ID
       ,Cat_ID
       ,Desig_ID
       ,Dept_ID
       ,type_id
      FROM T0095_Increment I WITH (NOLOCK)
      INNER JOIN (SELECT
          MAX(Increment_ID) AS Increment_ID
         ,Emp_ID
        FROM T0095_Increment WITH (NOLOCK)
        WHERE Increment_Effective_date <= @To_Date
        AND Cmp_ID = @Cmp_ID
        GROUP BY emp_ID) Qry
        ON I.Emp_ID = Qry.Emp_ID
        AND I.Increment_ID = Qry.Increment_ID) I_Q
      ON EM.Emp_ID = I_Q.Emp_ID
    LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM
      ON I_Q.Desig_Id = DM.Desig_ID
    LEFT JOIN t0040_department_master DMM
      ON I_Q.Dept_ID = DMM.Dept_ID
    LEFT JOIN t0030_branch_master BM
      ON I_Q.Branch_ID = BM.Branch_ID
    ---Where Is_Show =1
    --where 1 = case when (AD_ID > 0 OR Rimb_ID >0) and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
    --and Is_Show =1 -- Added by rohit
    ORDER BY DMM.Dept_Name, tr.Emp_ID, tr.Row_ID
  END
  ELSE
  BEGIN


    -- Changed By Ali 22112013 EmpName_Alias
    SELECT
      Row_ID
     ,SPACE(Concate_Space) + FIELD_NAME AS FIELD_NAME
     ,Amount_Col_Final
     ,Amount_Col_1
     ,Amount_Col_2
     ,Amount_Col_3
     ,Amount_Col_4
     ,Default_def_ID
     ,AD_ID
     ,IT_ID
     ,tr.Emp_ID
     ,EM.Emp_Code
     ,EM.Alpha_Emp_Code
     ,ISNULL(EM.EmpName_Alias_Tax, EM.Emp_Full_Name) AS Emp_Full_Name
     ,DM.Desig_Name
     ,EM.Date_Of_Join
     ,EM.Pan_No
     ,@From_Date P_From_Date
     ,@To_Date P_To_Date
     ,Is_Show
     ,Concate_Space
     ,Exempted_Amount
     ,I_Q.Branch_ID
     ,CASE
        WHEN EM.Date_Of_Join > @From_Date THEN EM.Date_Of_Join
        ELSE @From_Date
      END AS H_From_date
     ,CASE
        WHEN EM.Emp_Left_date < @To_Date THEN EM.Emp_Left_date
        ELSE @To_Date
      END AS H_To_test
     ,tr.Field_Type
     ,Show_In_SalarySlip
     ,Display_Name_For_SalarySlip
     ,Column_24Q
     ,Amount_Col_Actual
     ,Amount_Col_Assumed
     ,DMM.Dept_Name
     ,BM.branch_name
     ,CM.Cmp_Name
     ,CM.Cmp_PAN_No
     ,CM.Cmp_TAN_No
      --,ITR.Regime  --Comment by Jaina 31-08-2020
     ,ISNULL(tr.Tax_Regime, ITR.Regime) AS Regime  --Added by Jaina 31-08-2020
    FROM #Tax_Report tr
    LEFT OUTER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
      ON tr.EMP_ID = EM.EMP_ID
    INNER JOIN (SELECT
        I.Emp_Id
       ,Grd_ID
       ,Branch_ID
       ,Cat_ID
       ,Desig_ID
       ,Dept_ID
       ,type_id
      FROM T0095_Increment I WITH (NOLOCK)
      INNER JOIN (SELECT
          MAX(Increment_ID) AS Increment_ID
         ,Emp_ID
        FROM T0095_Increment WITH (NOLOCK)
        WHERE Increment_Effective_date <= @To_Date
        AND Cmp_ID = @Cmp_ID
        GROUP BY emp_ID) Qry
        ON I.Emp_ID = Qry.Emp_ID
        AND I.Increment_ID = Qry.Increment_ID) I_Q
      ON EM.Emp_ID = I_Q.Emp_ID
    LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)
      ON I_Q.Desig_Id = DM.Desig_ID
    LEFT JOIN t0040_department_master DMM WITH (NOLOCK)
      ON I_Q.Dept_ID = DMM.Dept_ID
    LEFT JOIN t0030_branch_master BM WITH (NOLOCK)
      ON I_Q.Branch_ID = BM.Branch_ID
    INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK)
      ON EM.Cmp_ID = CM.Cmp_ID
    LEFT OUTER JOIN T0095_IT_Emp_Tax_Regime ITR WITH (NOLOCK)
      ON tr.Emp_id = ITR.Emp_id
        AND YEAR(@From_Date) = LEFT(ITR.Financial_Year, 4)
        AND YEAR(@To_Date) = RIGHT(ITR.Financial_Year, 4)
    ---Where Is_Show =1
    --	where 1 = case when AD_ID > 0 and Amount_Col_Final = 0 then 0 else 1 end -- Added by rohit on 04052015
    --ORDER BY tr.Emp_ID ,tr.Row_ID		
    WHERE 1 = CASE
      WHEN (AD_ID > 0 OR
        Rimb_ID > 0) AND
        Amount_Col_Final = 0 THEN 0
      ELSE 1
    END -- Added by rohit on 04052015
    --and Is_Show =1 -- Added by rohit
    ORDER BY tr.Emp_ID, tr.Row_ID


    RETURN
  END
  RETURN