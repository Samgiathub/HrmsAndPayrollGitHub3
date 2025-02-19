

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_YEARLY_SALARY_GET_PIVOT]  
	 @Company_id		Numeric  
	,@From_Date		Datetime
	,@To_Date 		Datetime
	,@Branch_ID		Numeric	
	,@Grade_ID 		Numeric
	,@Type_ID 		Numeric
	,@Dept_ID 		Numeric
	,@Desig_ID 		Numeric
	,@Emp_ID 		Numeric
	,@Constraint	Varchar(max)
	,@Cat_ID        Numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID	Numeric = 0 
	,@Vertical		Numeric = 0 
	,@SubVertical	Numeric = 0 
	,@subBranch		Numeric = 0 
	,@SelectedCols	Varchar(Max) = 'ALL'
	,@PrivilegeID	NUMERIC = 0
	,@Format		VARCHAR(32) = 'Horizontal'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	DECLARE @WITH_CTC BIT
	SET @WITH_CTC=1
	 
	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0  
		SET @Cat_ID = NULL

	IF @Grade_ID = 0  
		SET @Grade_ID = NULL

	IF @Type_ID = 0  
		SET @Type_ID = NULL

	IF @Dept_ID = 0  
		SET @Dept_ID = NULL

	IF @Desig_ID = 0  
		SET @Desig_ID = NULL

	IF @Emp_ID = 0  
		SET @Emp_ID = NULL
	
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
		SET @Salary_Cycle_id = NULL	
	IF @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
		SET @Segment_Id = NULL
	IF @Vertical = 0		 -- Added By Gadriwala Muslim 21082013
		SET @Vertical = NULL
	IF @SubVertical = 0	 -- Added By Gadriwala Muslim 21082013
		SET @SubVertical = NULL	
	IF @subBranch = 0	 -- Added By Gadriwala Muslim 21082013
		SET @subBranch = NULL	

	DECLARE @ProductionBonus_Ad_Def_Id NUMERIC		
	SET		@ProductionBonus_Ad_Def_Id=20

	DECLARE @ShowHiddenAllowance AS BIT
	SET @ShowHiddenAllowance = 0

	IF EXISTS(SELECT	1
				FROM	T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK)
						INNER JOIN T0000_DEFAULT_FORM DF WITH (NOLOCK) ON PD.Form_Id=DF.Form_ID
				WHERE	DF.Form_Name='Show Hidden Allowance' AND Page_Flag='AP'
						AND (IsNull(Is_View,0) + IsNull(Is_Edit,0) + IsNull(Is_Save,0) + IsNull(Is_Delete,0) + IsNull(Is_Print,0)) <> 0
						AND Privilage_ID=@PrivilegeID)			
		SET @ShowHiddenAllowance = 1
	
	CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	EXEC SP_RPT_FILL_EMP_CONS  @Company_id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical ,@SubVertical ,@subBranch,@With_Ctc=1
	
	SELECT	EMP_ID, G.Branch_ID, GEN_ID, Ad_Rounding, Net_Salary_Round
	INTO	#EMP_GEN_SETTING
	FROM	#Emp_Cons EC 
			INNER JOIN T0040_GENERAL_SETTING G WITH (NOLOCK) ON EC.Branch_ID=G.Branch_ID 
			INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE, BRANCH_ID 
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
						WHERE	G1.For_Date <= @To_Date
						GROUP BY G1.Branch_ID) G1 ON G.Branch_ID=G1.Branch_ID AND G.For_Date=G1.FOR_DATE
	
	DECLARE @Month NUMERIC 
	DECLARE @Year NUMERIC  

	
	CREATE TABLE #DATES(ID INT, FOR_DATE DATETIME) 

	INSERT INTO #DATES
	SELECT	ROW_ID, DATEADD(M,ROW_ID-1,@From_Date)
	FROM	(SELECT TOP 96 ROW_NUMBER() OVER(ORDER BY OBJECT_ID) ROW_ID FROM sys.objects) T
	WHERE	T.ROW_ID <= (DATEDIFF(M, @FROM_DATE, @TO_DATE) + 1)

	CREATE TABLE #EMP_DATES(EMP_ID NUMERIC, Increment_ID NUMERIC, FOR_DATE DATETIME)

	INSERT INTO #EMP_DATES
	SELECT	EC.Emp_ID,Increment_ID, FOR_DATE
	FROM	#Emp_Cons EC Cross Join #DATES D

	CREATE TABLE #IT_HEAD
	(
		ROW_ID		int,
		Label_Name	Varchar(256),
		AD_ID		Numeric,
		IT_Def_ID	Numeric,
		IT_ID		Numeric
	)
	CREATE UNIQUE CLUSTERED INDEX IX_IT_HEAD_ROW_ID ON #IT_HEAD(ROW_ID)

	DECLARE @FIN_YEAR VARCHAR(9)
	IF MONTH(@TO_DATE) BETWEEN 1 AND 3
		BEGIN 
			SET @FIN_YEAR = CAST(YEAR(@TO_DATE) -1 AS VARCHAR(4))
			SET @FIN_YEAR = @FIN_YEAR + '-' + CAST(YEAR(@TO_DATE) AS VARCHAR(4))
		END
	ELSE
		BEGIN
			SET @FIN_YEAR = CAST(YEAR(@TO_DATE) AS VARCHAR(4))
			SET @FIN_YEAR = @FIN_YEAR + '-' + CAST(YEAR(@TO_DATE) + 1 AS VARCHAR(4))
		END
	
	INSERT INTO #IT_HEAD
	SELECT	I.Row_ID, I.Field_Name, AD.AD_ID, I.Default_Def_Id, I.IT_ID
	FROM	T0100_IT_FORM_DESIGN I WITH (NOLOCK)  
			LEFT OUTER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = I.AD_ID		
	WHERE	I.Cmp_Id= @Company_id and row_id <101
				AND Financial_Year = @FIN_YEAR
	ORDER BY  Row_ID

	
			 
	CREATE TABLE #Yearly_Salary 
	(
		Row_ID			NUMERIC IDENTITY (1,1) not NULL,
		Cmp_ID			NUMERIC ,
		Emp_Id			NUMERIC ,
		FOR_DATE		DATETIME,
		Def_ID			VARCHAR(8),
		Label_Name		VARCHAR(100),			
		Label_Value		NUMERIC(18,4),
		Leave_ID		NUMERIC, 
		Group_Def_ID	NUMERIC DEFAULT 0,
		SORT_INDEX		INT,
		AD_ID			NUMERIC
	)
	
			
	CREATE TABLE #Salary_Publish_Emp
	(
		Cmp_ID	NUMERIC,
		Emp_ID	NUMERIC,
		P_Month NUMERIC,
		P_Year	NUMERIC,
		Publish_Flag NUMERIC
	)
	CREATE CLUSTERED INDEX IX_Salary_Publish_Emp_Emp_ID_P_Month_P_Year_Publish_Flag ON #Salary_Publish_Emp (Emp_ID,P_Month,P_Year,Publish_Flag)
		

		
	INSERT	INTO #Salary_Publish_Emp(Cmp_ID,Emp_ID,P_Month,P_Year,Publish_Flag)
	SELECT	MS.Cmp_ID,EC.Emp_ID,MONTH(MS.Month_End_Date),YEAR(MS.Month_End_Date),IsNull(SPE.Is_Publish,0) 
	FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
			LEFT JOIN T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) ON MS.Emp_ID=SPE.Emp_ID AND MONTH(MS.Month_End_Date) = SPE.MONTH AND YEAR(MS.Month_End_Date) = SPE.Year AND SPE.Sal_Type='Salary' 
			INNER JOIN #Emp_Cons EC ON MS.Emp_ID = EC.Emp_ID
		
	--if @Publish_Flag = 1 --Added by nilesh patel ON 27112015 For When Admin show all salary.
		Begin
			UPDATE #Salary_Publish_Emp SET Publish_Flag = 1
		End 	
	
	
	
	DECLARE @SORT_INDEX INT
	SET @SORT_INDEX  = 1


	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,1,'Present', Present_Days,@SORT_INDEX 
	FROM	#EMP_DATES ED
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date
			--CROSS APPLY(SELECT Present_Days AS Label_Value FROM T0200_MONTHLY_SALARY MS WHERE MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date) MS

	SET @SORT_INDEX  = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,2,'WeekOff', Weekoff_Days,@SORT_INDEX 
	FROM	#EMP_DATES ED
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date
			--CROSS APPLY(SELECT Weekoff_Days AS Label_Value FROM T0200_Monthly_Salary MS WHERE MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date) MS

	SET @SORT_INDEX  = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,3,'Holiday', Holiday_Days,@SORT_INDEX 
	FROM	#EMP_DATES ED
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date
			--CROSS APPLY(SELECT Holiday_Days AS Label_Value FROM T0200_Monthly_Salary MS WHERE MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date) MS

	SET @SORT_INDEX  = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,4,'Absent', Absent_Days,@SORT_INDEX 
	FROM	#EMP_DATES ED
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date
			--CROSS APPLY(SELECT Absent_Days AS Label_Value FROM T0200_Monthly_Salary MS WHERE MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date) MS
	
	SET @SORT_INDEX  = @SORT_INDEX + 1
	/*Leave Detail*/
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.EMP_ID,ED.FOR_DATE,5,'Leave Count',LT.LeaveCount,@SORT_INDEX 
	FROM	#EMP_DATES ED
			INNER JOIN (SELECT	
								Emp_ID,DATEADD(D,( DAY(FOR_DATE)-1) * -1, FOR_DATE) AS FOR_DATE,
								(SUM(
										(CASE	WHEN LM.Apply_Hourly = 1 AND LM.Default_Short_Name <> 'COMP' THEN 
													CASE WHEN IsNull(LEAVE_USED,0) > 8 THEN 
														8 
													ELSE 
														IsNull(LEAVE_USED,0) 
													END / 8  
												WHEN  LM.Default_Short_NAME <> 'COMP' THEN 
													IsNull(LEAVE_USED,0) 
												ELSE 
													0 
										END)
									) + SUM(CASE	WHEN LM.Apply_Hourly = 1 AND LM.Default_Short_NAME = 'COMP'  THEN 
														(IsNull(CompOff_Used,0) - IsNull(Leave_Encash_Days,0)) /8  
													WHEN LM.Default_Short_NAME = 'COMP'  THEN 
														(IsNull(CompOff_Used,0) - IsNull(Leave_Encash_Days,0)) 
													ELSE  
														0 
											END)
								) AS LeaveCount
						FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
								INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
						WHERE	EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) WHERE LT.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date AND MS.Emp_ID=LT.EMP_ID)
						GROUP BY Emp_ID, DATEADD(D,( DAY(FOR_DATE)-1) * -1, FOR_DATE)
						) LT ON LT.FOR_DATE BETWEEN ED.FOR_DATE AND (DATEADD(M,1,ED.FOR_DATE)-1) AND ED.EMP_ID=LT.Emp_ID

			

	SET @SORT_INDEX  = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,Emp_ID,FOR_DATE,14,'Late/Early Penalty',LT.Late_Adj,@SORT_INDEX
	FROM	#EMP_DATES ED
			CROSS APPLY(SELECT	SUM(IsNull(leave_adj_L_mark,0)) AS Late_Adj 
						FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
						WHERE	LT.FOR_DATE BETWEEN ED.FOR_DATE AND (DATEADD(M,1,ED.FOR_DATE)-1) AND ED.EMP_ID=LT.Emp_ID) LT
	
	SET @SORT_INDEX  = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,Emp_ID,FOR_DATE,15,'Gate Pass Days',Label_Value,@SORT_INDEX
	FROM	#EMP_DATES ED
			CROSS APPLY(SELECT GatePass_Deduct_Days AS Label_Value FROM T0200_Monthly_Salary MS WITH (NOLOCK) WHERE MS.Emp_ID=ED.EMP_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date) MS

	SET @SORT_INDEX  = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,SORT_INDEX)
	SELECT	@Company_id,Emp_ID,FOR_DATE,18,'Total Days',@SORT_INDEX
	FROM	#EMP_DATES ED
	
	
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'52','Salary Days',IsNull(Sal_Cal_Days,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)						
					
	
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'B1','Basic Salary',Salary_Amount + IsNull(Arear_Basic ,0) + IsNull(Qry.S_Salary_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year
			CROSS APPLY	(SELECT	SUM(MST.S_Salary_Amount) AS S_Salary_Amount
						FROM	T0201_MONTHLY_SALARY_SETT MST WITH (NOLOCK)
								INNER JOIN #Emp_Cons ec ON MS.Emp_ID =ec.emp_ID 													
								AND S_Eff_Date BETWEEN MS.Month_St_Date AND MS.Month_End_Date AND MS.Emp_ID=MST.Emp_ID) Qry
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)



	SELECT	@SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) + 1 FROM #Yearly_Salary
	--ALL ALLOWANCE
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	--SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,Case when IsNull(MS.is_fnf,0)=0 then AM.AD_NAME Else  AM.AD_NAME + '_FNF' End as AD_NAME ,M_AD_Amount + IsNull(M_AREAR_AMOUNT,0) + IsNull(MS_Arear.MS_Amount,0),5000 + AM.AD_LEVEL,MAD.AD_ID	
	--FROM	#EMP_DATES ED  
	--		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
	--		INNER JOIN T0200_MONTHLY_SALARY MS ON MS.Sal_Tran_ID= MAD.Sal_Tran_ID AND MS.Emp_ID = MAD.emp_ID   
	--		INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
	--		INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year 
	--		LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_ID_Arear,
	--							Month(MSS.S_Eff_Date) AS EFF_Month, Year(MSS.S_Eff_Date) AS EFF_Year
	--					From	T0210_MONTHLY_AD_DETAIL MAD 
	--							INNER JOIN T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
	--							INNER JOIN T0050_AD_MASTER ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
	--					WHERE	MAD.Cmp_ID = @Company_id --AND MONTH(MSS.S_Eff_Date) =  ' + Cast(@Month AS varchar(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS varchar(4)) + ' 
	--							AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0  AND Ad_Active = 1 AND Sal_Type = 1  AND M_AD_Flag='I'
	--					GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
	--					) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_ID_Arear AND MONTH(MAD.To_date)=MS_Arear.EFF_Month AND YEAR(MAD.To_date)=MS_Arear.EFF_Year						
	--WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=0 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1)
	--		AND AM.AD_DEF_ID NOT IN (@ProductionBonus_Ad_Def_Id) AND M_AD_Flag='I'

		Declare @Setting_Value tinyint
		Set @Setting_Value=0
	 	SELECT @Setting_Value = Setting_Value FROM T0040_SETTING WITH (NOLOCK) where Setting_Name='After Salary Overtime Payment Process' AND Cmp_ID=@Company_id

	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,
			IT.Label_Name  + CASE  when IsNull(MS.is_fnf,0)=0 then '' Else  '_FNF' End as AD_NAME ,
			M_AD_Amount + IsNull(M_AREAR_AMOUNT,0) + IsNull(MS_Arear.MS_Amount,0),
			5000 + IT.ROW_ID,MAD.AD_ID	
	FROM	#EMP_DATES ED  
			INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
			INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Sal_Tran_ID= MAD.Sal_Tran_ID AND MS.Emp_ID = MAD.emp_ID   
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
			INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year 
			LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_ID_Arear,
								Month(MSS.S_Eff_Date) AS EFF_Month, Year(MSS.S_Eff_Date) AS EFF_Year
						From	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
								INNER JOIN T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
								INNER JOIN T0050_AD_MASTER WITH (NOLOCK) ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						WHERE	MAD.Cmp_ID = @Company_id --AND MONTH(MSS.S_Eff_Date) =  ' + Cast(@Month AS varchar(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS varchar(4)) + ' 
								--AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0  
								AND Ad_Active = 1 AND Sal_Type = 1  AND M_AD_Flag='I'
						GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
						) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_ID_Arear AND MONTH(MAD.To_date)=MS_Arear.EFF_Month AND YEAR(MAD.To_date)=MS_Arear.EFF_Year						
			INNER JOIN #IT_HEAD IT ON MAD.AD_ID=IT.AD_ID
	WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	
			--AND MAD.M_AD_NOT_EFFECT_SALARY=0 
			AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1)
			AND AM.AD_DEF_ID NOT IN (@ProductionBonus_Ad_Def_Id) AND M_AD_Flag='I'
			AND AM.AD_CALCULATE_ON <> 'Import' AND AM.Allowance_Type <> 'R'
	ORDER BY IT.ROW_ID

	If @Setting_Value =1 
		Begin
			INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
			SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,
					AD_NAME , Amount, 5000 + IT.ROW_ID,Qry.AD_ID	
			FROM	#EMP_DATES ED  Inner Join
					(Select T_AD_ID As AD_ID, Emp_ID, Month(For_Date) As [Month], Year(For_Date) As [Year], Sum(Isnull(MEB.Net_Amount,0)) As Amount
					from T0301_Process_Type_Master PTM  WITH (NOLOCK)
						cross APPLY  (Select Cast(Data As Numeric) As T_AD_ID FROM dbo.split (PTM.Ad_id_multi,'#') T Where Data <> '') SP 
						Inner Join MONTHLY_EMP_BANK_PAYMENT MEB WITH (NOLOCK) On PTM.Process_Type=MEB.Process_Type
					where For_Date >=@From_Date and For_Date <=@To_Date
					Group by Emp_ID, Month(For_Date), Year(For_Date),T_AD_ID ) Qry On Ed.EMP_ID=Qry.Emp_ID And Month(ED.For_Date)=Qry.Month And Year(ED.For_Date)=Qry.Year
					Inner Join T0050_AD_MASTER AM WITH (NOLOCK) On Qry.AD_ID = AM.AD_ID
					INNER JOIN #IT_HEAD IT ON Qry.AD_ID=IT.AD_ID
			WHERE AM.AD_CALCULATE_ON = 'Transfer OT' AND AM.Allowance_Type <> 'R'
		End

	
	/*REIMBERSEMENTS*/
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	SELECT	@Company_id,ED.EMP_ID,ED.FOR_DATE,IT.IT_Def_ID,IT.Label_Name,
			ISNULL(Taxable,0) + ISNULL(Tax_free_amount,0),
			5000 + IT.ROW_ID, IT.AD_ID
	FROM	#EMP_DATES ED  
			INNER JOIN T0210_MONTHLY_REIM_DETAIL MAD WITH (NOLOCK) ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.for_Date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.for_Date)=YEAR(ED.FOR_DATE)
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.RC_ID = AM.AD_ID
			INNER JOIN #Emp_Cons EC ON MAD.Emp_ID=EC.Emp_ID
			INNER JOIN #IT_HEAD IT ON MAD.RC_ID=IT.AD_ID
	WHERE	AM.Allowance_Type = 'R'

	--							select @old_M_AD_Amount = isnull(sum(Taxable),0) + isnull(sum(Tax_free_amount),0)  From T0210_MONTHLY_rEIM_DETAIL INNER JOIN 
	--						T0050_AD_MASTER ON T0210_MONTHLY_rEIM_DETAIL.RC_ID=T0050_AD_MASTER.AD_ID						
	--						where Emp_ID =@Emp_ID and RC_ID =@AD_ID AND ISNULL(AD_NOT_EFFECT_SALARY,0) = 1 AND ISNULL(Allowance_Type,'A')='R'
	--						and for_Date >=@From_Date and for_Date <=@Month_Date 
	--						--AND Sal_tran_ID > 0  -- Commneted by rohit For Approved reimbershement not Effect on Salary Shown in the report on 08092015
	--						AND T0050_AD_MASTER.CMP_ID=@CMP_id

	
	--SELECT * FROM #Yearly_Salary --WHERE AD_ID=137

	--SELECT @SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) FROM #Yearly_Salary
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	SELECT	@Company_id,MADI.Emp_ID,ED.FOR_DATE,IT.IT_Def_ID,IT.Label_Name,MADI.Amount,5000 + IT.ROW_ID, IT.AD_ID
	FROM	T0190_MONTHLY_AD_DETAIL_IMPORT MADI WITH (NOLOCK)
			INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MADI.AD_ID=AD.AD_ID
			INNER JOIN #IT_HEAD IT ON MADI.AD_ID=IT.AD_ID 
			INNER JOIN #Emp_Cons EC on MADI.Emp_ID=EC.EMP_ID
			INNER JOIN #EMP_DATES ED On MADI.For_Date BETWEEN ED.FOR_DATE AND DATEADD(D, -1, DATEADD(M,1, ED.FOR_DATE)) And EC.Emp_ID=ED.EMP_ID
	WHERE	AD.AD_CALCULATE_ON = 'Import' AND AD.AD_FLAG='I'

	
	
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	--SELECT	@Company_id,Emp_ID,FOR_DATE,AD_DEF_ID,AD_NAME,Net_Amount,5000 + IT.ROW_ID,T.AD_ID
	--FROM	(SELECT	ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,AM.AD_NAME,Sum(Net_Amount) As Net_Amount,AM.AD_LEVEL,AM.AD_ID,MONTH(MP.For_Date) AS MP_MONTH,YEAR(MP.FOR_DATE) AS MP_YEAR
	--		FROM	#EMP_DATES ED  
	--				INNER JOIN MONTHLY_EMP_BANK_PAYMENT MP ON ED.EMP_ID=MP.EMP_ID AND MONTH(ED.FOR_DATE)=MONTH(MP.FOR_DATE) AND YEAR(ED.FOR_DATE)=YEAR(MP.FOR_DATE)
	--				INNER JOIN T0050_AD_MASTER AM ON MP.AD_ID=AM.AD_ID
	--		WHERE	AM.AD_CALCULATE_ON = 'Import' --AND AM.AD_NOT_EFFECT_SALARY=1
	--		GROUP BY ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,AM.AD_NAME,AM.AD_LEVEL,AM.AD_ID,MONTH(MP.For_Date),YEAR(MP.FOR_DATE)) T
	--		INNER JOIN #IT_HEAD IT ON T.AD_ID=IT.AD_ID
	--WHERE	NOT EXISTS(SELECT 1 FROM #Yearly_Salary YS WHERE YS.EMP_ID=T.EMP_ID AND MONTH(YS.FOR_DATE)=T.MP_MONTH AND YEAR(YS.FOR_DATE)=T.MP_YEAR AND T.AD_ID=YS.AD_ID)
	 
	
	SELECT @SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) + 1 FROM #Yearly_Salary

	

	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'I199','Production Bonus',P_Bonus,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN (SELECT	EMP_ID, MONTH(MAD.TO_DATE) AS T_MONTH,YEAR(MAD.TO_DATE) AS T_YEAR, IsNull(Sum(M_AD_Amount),0) AS P_Bonus
						FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
								INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID
						WHERE	Ad_Active = 1 AND AD_Flag = 'I' AND AD_NOT_EFFECT_SALARY = 0 
								AND AD_DEF_ID=@ProductionBonus_Ad_Def_Id
						GROUP BY MAD.EMP_ID,MONTH(MAD.TO_DATE),YEAR(MAD.TO_DATE)
						) MS ON ED.EMP_ID = MS.Emp_ID AND MONTH(ED.FOR_DATE) = MS.T_MONTH AND YEAR(ED.FOR_DATE) = MS.T_YEAR
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MS.T_MONTH = SP.P_Month AND MS.T_YEAR = SP.P_Year			
	Where	SP.Publish_Flag = 1 
	
	
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'B1','Other Allowance',Other_Allow_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)

	
	SET @SORT_INDEX = @SORT_INDEX +1						
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J20','WD OT Amount',IsNull(OT_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)				
									
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J21','WO OT Amount',IsNull(M_WO_OT_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)				

	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J22','HO OT Amount',IsNull(M_HO_OT_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)		

	
							 
	--SET @SORT_INDEX = @SORT_INDEX +1				
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	--SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J17','Leave Encashment Amount',Leave_Salary_Amount,@SORT_INDEX
	--FROM	#EMP_DATES ED 
	--		INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
	--		INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	--Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)					

	
	SET @SORT_INDEX = @SORT_INDEX +1				
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J17','Leave Encashment Amount',LE.Leave_Encash_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0120_LEAVE_ENCASH_APPROVAL LE WITH (NOLOCK) ON ED.EMP_ID = LE.Emp_ID AND MONTH(ED.FOR_DATE) = MONTH(LE.Lv_Encash_Apr_Date) AND YEAR(ED.FOR_DATE) = YEAR(LE.Lv_Encash_Apr_Date)
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(ED.FOR_DATE) = SP.P_Month AND Year(ED.FOR_DATE) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 OR LE.IS_FNF = 1) AND LE.Eff_In_Salary = 0
			
	SET @SORT_INDEX = @SORT_INDEX +1				
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,'J18','Bonus',ISNULL(B.Bonus_Amount,MEBP.Net_Amount),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK) ON ED.EMP_ID = MEBP.Emp_ID AND MONTH(ED.FOR_DATE) = MONTH(MEBP.Payment_Date) AND YEAR(ED.FOR_DATE) = YEAR(MEBP.Payment_Date)
			LEFT OUTER JOIN T0180_BONUS B WITH (NOLOCK) ON MEBP.Emp_ID = B.Emp_ID AND MONTH(MEBP.For_Date) = B.Bonus_Effect_Month AND YEAR(MEBP.For_Date)=B.Bonus_Effect_Year
	Where	MEBP.Process_Type = 'Bonus'


	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id, Emp_ID,For_Date,'J23', 'Gross', Sum(Label_Value), @SORT_INDEX
	FROM	#Yearly_Salary 
	Where	SORT_INDEX > 9 --Sort Index : 10 for Basic + All Earnings
	Group By Emp_ID,For_Date
	--SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J23','Gross',Gross_Salary + IsNull(S_Gross_Salary,0) - IsNull(S_Net_Amount,0),@SORT_INDEX
	--FROM	#EMP_DATES ED 
	--		INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
	--		INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year
	--		CROSS APPLY	(SELECT	SUM(MST.S_Gross_Salary) AS S_Gross_Salary, SUM(MST.S_Net_Amount) AS S_Net_Amount
	--					FROM	T0201_MONTHLY_SALARY_SETT MST
	--							INNER JOIN #Emp_Cons ec ON MS.Emp_ID =ec.emp_ID 													
	--							AND S_Eff_Date BETWEEN MS.Month_St_Date AND MS.Month_End_Date AND MS.Emp_ID=MST.Emp_ID) Qry
	--Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)

			

	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P11','PT',PT_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)


	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P12','LWF',LWF_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)
							
	
	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P13','REVENUE',Revenue_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)
											
	
	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P14','ADVANCE',Advance_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)	

			
							
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P29','Late Dedu.',IsNull(Late_Dedu_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)			

	

	SELECT	@SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) + 1 FROM #Yearly_Salary

	--ALL DEDUCTION
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,Case when IsNull(MS.is_fnf,0)=0 then AM.AD_NAME Else  AM.AD_NAME + '_FNF' End as AD_NAME,M_AD_Amount + IsNull(M_AREAR_AMOUNT,0) + IsNull(MS_Arear.MS_Amount,0),6000 + AM.AD_LEVEL,MAD.AD_ID
	FROM	#EMP_DATES ED  
			INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
			INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Sal_Tran_ID= MAD.Sal_Tran_ID AND MS.Emp_ID = MAD.emp_ID   
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
			INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year 
			LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_ID_Arear,
								Month(MSS.S_Eff_Date) AS EFF_Month, Year(MSS.S_Eff_Date) AS EFF_Year
						From	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
								INNER JOIN T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
								INNER JOIN T0050_AD_MASTER WITH (NOLOCK) ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						WHERE	MAD.Cmp_ID = @Company_id --AND MONTH(MSS.S_Eff_Date) =  ' + Cast(@Month AS varchar(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS varchar(4)) + ' 
								AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0  AND Ad_Active = 1 AND Sal_Type = 1  AND M_AD_Flag='D'
						GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
						) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_ID_Arear AND MONTH(MAD.To_date)=MS_Arear.EFF_Month AND YEAR(MAD.To_date)=MS_Arear.EFF_Year						
	WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=0 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1)
			AND AM.AD_DEF_ID NOT IN (@ProductionBonus_Ad_Def_Id) AND M_AD_Flag='D'

		
	SELECT	@SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) + 1 FROM #Yearly_Salary		
		
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P27','Asset Installment Amount',IsNull(Asset_Installment,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)		
								
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P18','Travel Advance Amount',IsNull(Travel_Advance_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)	
	
	
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J18','Travel Amount',IsNull(Travel_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)															
								
			
									
	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P23','Loan',IsNull(Loan_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)				

	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P24','Loan Int Amt',IsNull(Loan_Intrest_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)		

	SET @SORT_INDEX = @SORT_INDEX +1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P26','Gate Pass Amount',IsNull(GatePass_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)		
				

	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P98','Total Deduction',Total_Dedu_Amount + IsNull(S_total_Dedu_Amount,0),@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year
			CROSS APPLY	(SELECT	SUM(MST.S_Total_Dedu_Amount) AS S_Total_Dedu_Amount
						FROM	T0201_MONTHLY_SALARY_SETT MST WITH (NOLOCK)
								INNER JOIN #Emp_Cons ec ON MS.Emp_ID =ec.emp_ID 													
								AND S_Eff_Date BETWEEN MS.Month_St_Date AND MS.Month_End_Date AND MS.Emp_ID=MST.Emp_ID) Qry
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)						

	SET @SORT_INDEX = @SORT_INDEX + 1
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P99','NET SALARY',Net_Amount,@SORT_INDEX
	FROM	#EMP_DATES ED 
			INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)						

				
	
	--UPDATING SETTLEMENT	
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	--SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,0,AM.AD_NAME,  M_AD_Amount + IsNull(M_AREAR_AMOUNT ,0) + IsNull(MS_Arear.MS_Amount,0),12,MAD.AD_ID							
	--UPDATE	YS
	--SET		Label_Value = Label_Value + 
	--FROM	#Yearly_Salary YS 
	--		INNER JOIN #EMP_DATES ED ON ED.EMP_ID=YS.Emp_Id AND ED.FOR_DATE=YS.FOR_DATE
	--		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON ED.EMP_ID = MAD.Emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE) AND MAD.AD_ID=YS.AD_ID
	--		INNER JOIN T0200_MONTHLY_SALARY MS ON MS.Sal_Tran_ID= MAD.Sal_Tran_ID AND MS.Emp_ID = MAD.emp_ID   
	--		INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
	--		INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year
	--		LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_id_Arear,Month(MSS.S_Eff_Date) As Eff_Month,Month(MSS.S_Eff_Date) As Eff_Year
	--					From	T0210_MONTHLY_AD_DETAIL MAD 
	--							INNER JOIN T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
	--							INNER JOIN T0050_AD_MASTER ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
	--					WHERE	MAD.Cmp_ID = @Company_id -- AND MONTH(MSS.S_Eff_Date) = ' + Cast(@Month AS NVARCHAR(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS NVARCHAR(4)) + ' 
	--							AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0    AND Ad_Active = 1 AND Sal_Type = 1
	--					GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
	--					) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_id_Arear  AND MONTH(MAD.To_Date)=MS_Arear.Eff_Month AND YEAR(MAD.To_date) = MS_Arear.Eff_Year
	--WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=0 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1) 
				
									
								
	--SET @SORT_INDEX = @SORT_INDEX +1
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	--SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'0',Q.Claim_Name,IsNull(Claim_Pay_Amount,0),@SORT_INDEX
	--FROM	#EMP_DATES ED  
	--		INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(ED.FOR_DATE) = SP.P_Month AND Year(ED.FOR_DATE) = SP.P_Year 
	--		CROSS APPLY (SELECT	CLAIM_PAYMENT_DATE,CA.Claim_ID,CM.Claim_Name,CA.Emp_ID,Claim_Pay_Amount 
	--					From	T0210_MONTHLY_CLAIM_PAYMENT CP 
	--							INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
	--							INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  
	--							INNER JOIN #Emp_Cons ec ON ca.emp_ID =ec.emp_Id 
	--					WHERE	MONTH(CLAIM_PAYMENT_DATE)=MONTH(ED.FOR_DATE) AND YEAR(CLAIM_PAYMENT_DATE)=YEAR(ED.FOR_DATE)
	--					) Q 			
	--Where	SP.Publish_Flag = 1 
							
	--SET @SORT_INDEX = @SORT_INDEX +1
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	--SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P28','Uniform Installment Amount',IsNull(Uniform_Dedu_Amount,0),@SORT_INDEX
	--FROM	#EMP_DATES ED 
	--		INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
	--		INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	--Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)	
							
	
	--SET @SORT_INDEX = @SORT_INDEX +1
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	--SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'J26','Uniform Refund Amount',IsNull(Uniform_Refund_Amount,0),@SORT_INDEX
	--FROM	#EMP_DATES ED 
	--		INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
	--		INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	--Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)	
					

				
	---- Added by rohit For Add component which Not Effect in salary AND Part of Ctc ON 09102013
	--IF @WITH_CTC = 1
	--	BEGIN 
	--		SET @SORT_INDEX = @SORT_INDEX +1
	--		INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	--		SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,'L4','CTC',IsNull(SUM(M_AD_Amount + IsNull(MS_Amount,0)),0),@SORT_INDEX,MAD.AD_ID
	--		FROM	#EMP_DATES ED  
	--				INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
	--				INNER JOIN T0200_MONTHLY_SALARY MS ON MS.Sal_Tran_ID= MAD.Sal_Tran_ID AND MS.Emp_ID = MAD.emp_ID   
	--				INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
	--				INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year 
	--				LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_ID_Arear,
	--									Month(MSS.S_Eff_Date) AS EFF_Month, Year(MSS.S_Eff_Date) AS EFF_Year
	--							From	T0210_MONTHLY_AD_DETAIL MAD 
	--									INNER JOIN T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
	--									INNER JOIN T0050_AD_MASTER ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
	--							WHERE	MAD.Cmp_ID = @Company_id --AND MONTH(MSS.S_Eff_Date) =  ' + Cast(@Month AS varchar(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS varchar(4)) + ' 
	--									AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0  AND Ad_Active = 1 AND Sal_Type = 1
	--							GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
	--							) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_ID_Arear AND MONTH(MAD.To_date)=MS_Arear.EFF_Month AND YEAR(MAD.To_date)=MS_Arear.EFF_Year						
	--		WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=0 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1)
	--				AND AM.AD_Part_Of_CTC = 1 AND AM.AD_Flag = 'I'
	--		GROUP BY ED.EMP_ID,ED.FOR_DATE,YEAR(MAD.TO_DATE), MONTH(MAD.TO_DATE),MAD.AD_ID
			
							 
			
	--		UPDATE	YS
	--		SET		Label_Value = Label_Value  + Gross_Salary + IsNull(S_Gross_Salary,0) -IsNull(S_Net_Amount,0)
	--		FROM	#EMP_DATES ED  
	--				INNER JOIN #Yearly_Salary YS ON ED.EMP_ID=YS.Emp_Id AND ED.FOR_DATE=YS.FOR_DATE
	--				INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
	--				INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
	--				LEFT JOIN	(SELECT	MST.Emp_ID,SUM(MST.S_Gross_Salary) AS S_Gross_Salary,SUM(MST.S_Net_Amount) AS S_Net_Amount,MONTH(S_Eff_Date) EFF_MONTH,YEAR(S_Eff_Date) EFF_YEAR
	--							FROM	T0201_MONTHLY_SALARY_SETT MST 
	--									INNER JOIN #Emp_Cons EC ON MST.Emp_ID = EC.Emp_ID 										
	--							GROUP BY MST.Emp_ID,MONTH(S_Eff_Date) ,YEAR(S_Eff_Date) 
	--						 ) Qry ON Qry.Emp_ID = ED.EMP_ID AND MONTH(ED.FOR_DATE) =	Qry.EFF_MONTH AND MONTH(ED.FOR_DATE) = Qry.EFF_YEAR
	--		Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1) AND YS.Def_ID='L4'			
								
	--	END	

					
		
	--IF @ROUNDING <> 0 AND @Net_Salary_Round <> -1
	/*FOR ROUNDING IN NET AMOUNT*/
		--Begin
			
		--	UPDATE	YS
		--	SET		Label_Value = Net_Amount - IsNUll(Net_Salary_Round_Diff_Amount,0)
		--	FROM	#Yearly_Salary YS 
		--			INNER JOIN #EMP_DATES ED ON YS.FOR_DATE=ED.FOR_DATE AND YS.Emp_Id=ED.FOR_DATE					
		--			INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
		--			INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
		--			INNER JOIN #EMP_GEN_SETTING G ON YS.Emp_Id = G.EMP_ID AND IsNull(G.Ad_Rounding,0) <> 0 AND ISNULL(Net_Salary_Round,0) <> -1
		--	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1) AND YS.Def_ID='P99'
					
									
		--	SET @SORT_INDEX = @SORT_INDEX +1
		--	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
		--	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P100','Net Round',Net_Salary_Round_Diff_Amount,@SORT_INDEX
		--	FROM	#EMP_DATES ED 
		--			INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
		--			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
		--			INNER JOIN #EMP_GEN_SETTING G ON ED.Emp_Id = G.EMP_ID AND IsNull(G.Ad_Rounding,0) <> 0 AND ISNULL(Net_Salary_Round,0) <> -1
		--	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)		
			
			
		--	SET @SORT_INDEX = @SORT_INDEX +1
		--	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
		--	SELECT	@Company_id,ED.Emp_ID,FOR_DATE,'P101','Final Net Amount',Net_Amount,@SORT_INDEX
		--	FROM	#EMP_DATES ED 
		--			INNER JOIN T0200_Monthly_Salary MS ON ED.EMP_ID = MS.Emp_ID AND ED.FOR_DATE BETWEEN MS.Month_St_Date AND MS.Month_End_Date								
		--			INNER JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(Month_End_Date) = SP.P_Month AND Year(Month_End_Date) = SP.P_Year			
		--			INNER JOIN #EMP_GEN_SETTING G ON ED.Emp_Id = G.EMP_ID AND IsNull(G.Ad_Rounding,0) <> 0 AND ISNULL(Net_Salary_Round,0) <> -1
		--	Where	(SP.Publish_Flag = 1 or IsNull(MS.Is_FNF,0)=1)						
										
		--End
	SELECT @SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) FROM #Yearly_Salary
						
	
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX)
	SELECT	@Company_id,ED.Emp_Id,ED.FOR_DATE,'X1','TDS On Special',SUM(TDS) AS TDS, @SORT_INDEX 
	FROM	T0210_ESIC_On_Not_Effect_on_Salary  ESIC WITH (NOLOCK)
			INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ESIC.Ad_Id=ESIC.Ad_Id
			INNER JOIN #EMP_DATES ED ON MONTH(ED.FOR_DATE)=MONTH(ESIC.FOR_DATE) AND YEAR(ED.FOR_DATE)=YEAR(ESIC.For_Date) AND ESIC.Emp_Id=ED.EMP_ID
	WHERE	AD.Hide_In_Reports = 1 AND ESIC.Cmp_Id=@Company_id
	GROUP BY ED.EMP_ID,ED.FOR_DATE

							
	/*
	SET @SORT_INDEX = @SORT_INDEX + 1
	--ALL NOT EFFECTED IN SALARY ALLOWANCE
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,0,AM.AD_NAME, M_AD_Amount + IsNull(M_AREAR_AMOUNT,0) + IsNull(MS_Arear.MS_Amount,0) ,7000 + AM.AD_LEVEL,MAD.AD_ID							
	FROM	#EMP_DATES ED  
			INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
			INNER JOIN T0200_MONTHLY_SALARY MS ON MS.sal_tran_id= MAD.sal_tran_id AND MS.Emp_ID = MAD.emp_ID   
			INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
			INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year
			LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_id_Arear,Month(MSS.S_Eff_Date) As Eff_Month, Year(MSS.S_Eff_Date) as Eff_Year
						From	T0210_MONTHLY_AD_DETAIL MAD 
								INNER JOIN T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
								INNER JOIN T0050_AD_MASTER ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						WHERE	MAD.Cmp_ID = @Company_id -- AND MONTH(MSS.S_Eff_Date) = ' + Cast(@Month AS NVARCHAR(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS NVARCHAR(4)) + ' 
								AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    AND Ad_Active = 1 AND Sal_Type = 1								
						GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
						) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_id_Arear  AND MONTH(MAD.To_date)=MS_Arear.Eff_Month AND YEAR(MAD.To_date)=MS_Arear.Eff_Year
	WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=1 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1) 
			AND MAD.ReimAmount  = 0
			AND NOT EXISTS(SELECT 1 FROM  MONTHLY_EMP_BANK_PAYMENT MBP WHERE MAD.AD_ID=MBP.Ad_Id)
	*/
			
	/*
	SELECT @SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) FROM #Yearly_Salary
	--ALL REIMBERSEMENT
	INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,0,AM.AD_NAME, CASE WHEN MAD.ReimAmount  > 0 THEN  MAD.ReimAmount +  IsNull(MS_arear.ms_amount,0) END ,8000 + AM.AD_LEVEL,MAD.AD_ID							
	FROM	#EMP_DATES ED  
			INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
			INNER JOIN T0200_MONTHLY_SALARY MS ON MS.sal_tran_id= MAD.sal_tran_id AND MS.Emp_ID = MAD.emp_ID   
			INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
			INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year
			LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_id_Arear  
						From	T0210_MONTHLY_AD_DETAIL MAD 
								INNER JOIN T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
								INNER JOIN T0050_AD_MASTER ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						WHERE	MAD.Cmp_ID = @Company_id -- AND MONTH(MSS.S_Eff_Date) = ' + Cast(@Month AS NVARCHAR(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS NVARCHAR(4)) + ' 
								AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    
								AND Ad_Active = 1 AND Sal_Type = 1
						GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
						) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_id_Arear  
	WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=1 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1) 
			AND MAD.ReimAmount  > 0
	*/					 
		
					
	--SELECT @SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) FROM #Yearly_Salary

	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	--SELECT	@Company_id,Emp_ID,FOR_DATE,AD_DEF_ID,AD_NAME,Net_Amount,8500 + AD_LEVEL,AD_ID
	--FROM	(SELECT	ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,AM.AD_NAME,Sum(Net_Amount) As Net_Amount,AM.AD_LEVEL,AM.AD_ID,MONTH(MP.For_Date) AS MP_MONTH,YEAR(MP.FOR_DATE) AS MP_YEAR
	--		FROM	#EMP_DATES ED  
	--				INNER JOIN MONTHLY_EMP_BANK_PAYMENT MP ON ED.EMP_ID=MP.EMP_ID AND MONTH(ED.FOR_DATE)=MONTH(MP.FOR_DATE) AND YEAR(ED.FOR_DATE)=YEAR(MP.FOR_DATE)
	--				INNER JOIN T0050_AD_MASTER AM ON MP.AD_ID=AM.AD_ID
	--		WHERE	AM.AD_CALCULATE_ON = 'Import' AND AM.AD_NOT_EFFECT_SALARY=1
	--		GROUP BY ED.Emp_ID,ED.FOR_DATE,AM.AD_DEF_ID,AM.AD_NAME,AM.AD_LEVEL,AM.AD_ID,MONTH(MP.For_Date),YEAR(MP.FOR_DATE)) T
	--WHERE	NOT EXISTS(SELECT 1 FROM #Yearly_Salary YS WHERE YS.EMP_ID=T.EMP_ID AND MONTH(YS.FOR_DATE)=T.MP_MONTH AND YEAR(YS.FOR_DATE)=T.MP_YEAR AND T.AD_ID=YS.AD_ID)
	 
	--SELECT @SORT_INDEX  = ISNULL(MAX(SORT_INDEX),0) FROM #Yearly_Salary		
		
	--INSERT	INTO #Yearly_Salary(Cmp_ID,Emp_Id,FOR_DATE,Def_ID,Label_Name,Label_Value,SORT_INDEX,AD_ID)
	--SELECT	@Company_id,ED.Emp_ID,ED.FOR_DATE,0,AM.AD_NAME, MAD.M_AD_Amount + MAD.M_AREAR_AMOUNT + MAD.M_AREAR_AMOUNT_Cutoff,8000 + AM.AD_LEVEL,MAD.AD_ID							
	--FROM	#EMP_DATES ED  
	--		INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON ED.EMP_ID = MAD.emp_ID AND MONTH(MAD.To_date)=MONTH(ED.FOR_DATE) AND YEAR(MAD.To_date)=YEAR(ED.FOR_DATE)
	--		INNER JOIN T0200_MONTHLY_SALARY MS ON MS.sal_tran_id= MAD.sal_tran_id AND MS.Emp_ID = MAD.emp_ID   
	--		INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
	--		INNER JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = ED.EMP_ID AND MONTH(MAD.To_date) = SP.P_Month AND Year(MAD.To_date) = SP.P_Year
	--		LEFT JOIN (	SELECT	MAD.AD_ID AS AD_ID_Arear,IsNull(SUM(M_AD_Amount),0) AS MS_Amount,MSS.Emp_ID AS Emp_id_Arear  
	--					From	T0210_MONTHLY_AD_DETAIL MAD 
	--							INNER JOIN T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID AND mad.emp_id = Mss.emp_id  
	--							INNER JOIN T0050_AD_MASTER ON MAD.Ad_Id = T0050_AD_MASTER.Ad_ID AND MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
	--					WHERE	MAD.Cmp_ID = @Company_id -- AND MONTH(MSS.S_Eff_Date) = ' + Cast(@Month AS NVARCHAR(3)) + ' AND Year(MSS.S_Eff_Date) = '+ Cast(@Year AS NVARCHAR(4)) + ' 
	--							AND IsNull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    AND Ad_Active = 1 AND Sal_Type = 1
	--					GROUP BY MAD.AD_ID,MSS.Emp_ID,Month(MSS.S_Eff_Date), Year(MSS.S_Eff_Date) 
	--					) AS MS_Arear ON MAD.AD_ID = MS_Arear.AD_ID_Arear AND  MAD.Emp_ID = MS_Arear.Emp_id_Arear  
	--WHERE	IsNull(MAD.S_Sal_Tran_ID,0) = 0	AND MAD.M_AD_NOT_EFFECT_SALARY=1 AND (SP.Publish_Flag = 1 or IsNull(MS.is_fnf,0)=1) AND  AD_DEF_ID LIKE '%K%'
							 
	
					
	/*Salary Structure*/
	
	--SELECT * FROM #Yearly_Salary
	--ORDER BY Emp_Id,FOR_DATE, SORT_INDEX

	SELECT  EM.Alpha_Emp_Code,  Emp_Full_Name, BM.Branch_Name AS Branch, GM.Grd_Name As Grade,
				DM.Dept_Code As Department_Code, DM.Dept_Name As Department,DGM.Desig_Name As Designation, EM.Pan_No,Em.Date_Of_Join,EM.Emp_ID,I.Branch_ID
	INTO	#EmpDetail 
	FROM	#Emp_Cons EC
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.EMP_ID = EM.EMP_ID 
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID=I.Emp_ID
			INNER JOIN (SELECT	MAX(I1.Increment_ID) AS Increment_ID, I1.Emp_ID 
						FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								INNER JOIN (SELECT	I2.Emp_ID, Max(Increment_Effective_Date) As Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE	I2.Increment_Effective_Date <= @To_Date
																
											GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I2.Increment_Effective_Date=I1.Increment_Effective_Date
							
						GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_ID=I1.Increment_ID			
			INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) on I.Branch_ID = BM.Branch_ID 
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id 
			
			--INNER JOIN T0010_COMPANY_MASTER cm on I.cmp_Id = cm.cmp_Id 
			--LEFT JOIN T0040_Vertical_Segment VS on I.Vertical_ID = vs.Vertical_ID		
	DELETE	Y
	FROM	#Yearly_Salary Y
	WHERE	NOT EXISTS(SELECT 1 FROM #Yearly_Salary Y1 WHERE Y.Emp_ID=Y1.Emp_ID AND Y.Label_Name=Y1.Label_Name AND Y.Label_Value > 0)

	
	
	--IF (@ShowHiddenAllowance = 0)
	--	DELETE	YS 		
	--	FROM	#Yearly_Salary YS
	--			INNER JOIN T0050_AD_MASTER AD ON YS.AD_ID=AD.AD_ID 
	--	WHERE	(AD.Hide_In_Reports=1 OR Def_ID IN ('X1'))
	Update #Yearly_Salary SET Label_Name=REPLACE(Label_Name, ' ', '_')
	SET @SelectedCols = REPLACE(@SelectedCols, ' ', '_')

	DECLARE @SQL VARCHAR(MAX)
	DECLARE @COLS VARCHAR(MAX)
	if @is_column = 1
		BEGIN

			SELECT	@COLS=COALESCE(@COLS + ',','') + '[' + Label_Name + ']'
			FROM	(SELECT	DISTINCT Label_Name, RIGHT('0000' + CAST(SORT_INDEX AS VARCHAR(10)), 4) + Label_Name AS SortLabel  FROM #Yearly_Salary) YS
			ORDER BY SortLabel



			SET @SQL = 'SELECT	TOP 0 *
						FROM	#EmpDetail ED	
								CROSS JOIN (SELECT	*
											FROM	(SELECT	Label_Name,Label_Value FROM #Yearly_Salary) YS
													PIVOT (
															SUM(Label_Value) FOR Label_Name IN (' + @COLS + ')
														  ) PVT
											) YS '

			EXEC (@SQL);	
				
		END
	ELSE
		BEGIN
			DECLARE @DEFAULT_COLS VARCHAR(256)
			SET @DEFAULT_COLS = 'Alpha_Emp_Code,Emp_Full_Name,Branch,Grade,Department_Code,Department,Designation,Pan_No,Date_Of_Join,Branch_ID';
			
			
			UPDATE #Yearly_Salary SET Label_Name = REPLACE(Label_Name, ' ', '_')
			IF @SelectedCols = 'All'
				BEGIN
					SET @SelectedCols = @DEFAULT_COLS;					
				END
			ELSE
				BEGIN
					SET @SelectedCols = REPLACE(@SelectedCols, ' ', '_')
					SET @SQL = 'DELETE FROM #Yearly_Salary WHERE Label_Name NOT IN (''' + Replace(@SelectedCols, ',', ''',''') + ''')'
					EXEC (@SQL);
					
					DECLARE @TEMP_COLS VARCHAR(256)	
					SELECT	@TEMP_COLS = COALESCE(@TEMP_COLS + ',','') + DATA
					FROM	dbo.Split(@SelectedCols, ',') T
					WHERE	EXISTS(SELECT 1 FROM dbo.Split(@DEFAULT_COLS,',') T1   WHERE T.DATA=T1.DATA)
					SET @SelectedCols = @TEMP_COLS
				END

			DECLARE @SELECT_COLS VARCHAR(MAX)		
			SELECT	@SELECT_COLS = COALESCE(@SELECT_COLS + ',', '') + '[' + FieldName + ']'
			FROM	(SELECT DATA AS FieldName From dbo.Split(REPLACE(@SelectedCols, '''', ''), ',') T1) T1
			WHERE	NOT EXISTS (SELECT DISTINCT Label_Name FROM #Yearly_Salary T WHERE REPLACE(T1.FieldName, ' ', '_') = REPLACE(T.Label_Name, ' ', '_')) 

			

			DECLARE @SUM_COLS VARCHAR(MAX)
			IF @Format = 'Vertical'
				BEGIN
					
					INSERT INTO #Yearly_Salary
					SELECT	Cmp_ID,Emp_ID,'2100-01-01',Def_ID,Label_Name,Round(Sum(Label_Value),0) Label_Value, Leave_ID,Group_Def_ID,SORT_INDEX,AD_ID
					FROM	#Yearly_Salary YS
					GROUP BY Cmp_ID,Emp_ID,Def_ID,Label_Name,Leave_ID,Group_Def_ID,SORT_INDEX,AD_ID

					UPDATE #Yearly_Salary SET Label_Name = REPLACE(Label_Name, '_', ' ')

					ALTER TABLE #Yearly_Salary ADD Month_Year Varchar(32)
					UPDATE	YS
					SET		Month_Year = CASE WHEN YEAR(FOR_DATE) = 2100 THEN 'Total' Else LEFT(DATENAME(MONTH, FOR_DATE),3) + '-' + CAST(YEAR(FOR_DATE) AS VARCHAR(4)) END
					FROM	#Yearly_Salary YS

					

					DECLARE @MONTH_COLS VARCHAR(MAX)
					SELECT	@MONTH_COLS = COALESCE(@MONTH_COLS + ',','') + '[' + Month_Year + ']'
					FROM	(SELECT DISTINCT FOR_DATE,Month_Year FROM #Yearly_Salary) T
					ORDER BY FOR_DATE

					
					CREATE TABLE #Yearly_Salary_Vertical
					(
						ID				BIGINT	IDENTITY(1,1),
						SORT_INDEX		NUMERIC,
						GROUP_ID		NUMERIC
					)

					DECLARE @ALTER_COLS VARCHAR(MAX);
					SELECT  @ALTER_COLS = COALESCE(@ALTER_COLS + ',','') + DATA + ' VARCHAR(128) '
					FROM	dbo.Split(@SelectedCols, ',') T

					
					SET @SQL = 'ALTER TABLE #Yearly_Salary_Vertical ADD ' + @ALTER_COLS 
					PRINT @SQL
					EXEC (@SQL)

					ALTER TABLE #Yearly_Salary_Vertical ADD Label_Name  VARCHAR(64)

					SET		@ALTER_COLS = NULL
					SELECT  @ALTER_COLS = COALESCE(@ALTER_COLS + ',','') + DATA + ' NUMERIC(18,2) '
					FROM	dbo.Split(@MONTH_COLS, ',') T

					

					SET @SQL = 'ALTER TABLE #Yearly_Salary_Vertical ADD ' + @ALTER_COLS 
					EXEC (@SQL)
					
					SET @SQL = 'INSERT	INTO #Yearly_Salary_Vertical(SORT_INDEX,GROUP_ID,' + @SelectedCols + ',Label_Name,' + @MONTH_COLS + ')
								SELECT	SORT_INDEX,ROW_NUMBER() OVER(PARTITION BY EMP_ID ORDER BY SORT_INDEX) GROUP_ID,' + @SelectedCols + ',Label_Name,' + @MONTH_COLS + '
								FROM	(SELECT	SORT_INDEX,ED.*,YS.Month_Year,YS.Label_Value, YS.Label_Name
										FROM	#Yearly_Salary YS 
												INNER JOIN #EmpDetail ED ON YS.EMP_ID=ED.EMP_ID
										) T
										PIVOT (
											SUM(Label_Value) FOR Month_Year IN (' + @MONTH_COLS + ')
										) PVT
								ORDER BY Alpha_Emp_Code,SORT_INDEX'
					
					EXEC (@SQL)

					
					
					SELECT  @SUM_COLS = COALESCE(@SUM_COLS + ',','') + ' SUM(IsNull(' + DATA + ',0))'
					FROM	dbo.Split(@MONTH_COLS, ',') T

					SET @SQL = 'INSERT	INTO #Yearly_Salary_Vertical(SORT_INDEX,GROUP_ID,Label_Name,' + @MONTH_COLS + ')
								SELECT	99999,999,''Total'',' + @SUM_COLS + '
								FROM	#Yearly_Salary_Vertical'

					EXEC (@SQL)


					
					SET	@SUM_COLS = NULL;
					SELECT	@SUM_COLS = COALESCE(@SUM_COLS + ',','') + DATA + '=NULL'
					FROM	dbo.Split(@SelectedCols,',') T

					SET @SQL = 'UPDATE	#Yearly_Salary_Vertical
								SET		' + @SUM_COLS + '
								WHERE	SORT_INDEX <> 99999 AND GROUP_ID <> 1' 

					EXEC (@SQL)

					PRINT @SQL
					SET	@SQL = 'SELECT	' + @SelectedCols + ',Label_Name,' + @MONTH_COLS + ' FROM	#Yearly_Salary_Vertical ORDER BY ID'
					EXEC (@SQL)
					--SELECT * FROM #Yearly_Salary_Vertical
					--SELECT distinct for_date,Month_Year FROM #Yearly_Salary order by for_date
				END
			ELSE
				BEGIN
					

					INSERT INTO #Yearly_Salary
					SELECT	Cmp_ID,Emp_ID,'2100-01-01',Def_ID,Label_Name,Round(Sum(Label_Value),0) Label_Value, Leave_ID,Group_Def_ID,SORT_INDEX,AD_ID
					FROM	#Yearly_Salary YS
					GROUP BY Cmp_ID,Emp_ID,Def_ID,Label_Name,Leave_ID,Group_Def_ID,SORT_INDEX,AD_ID

					ALTER TABLE  #Yearly_Salary ADD Month_Label Varchar(128)
			
					UPDATE	YS
					SET		Month_Label = CASE WHEN FOR_DATE = '2100-01-01' THEN 'Total' ELSE RIGHT(CONVERT(VARCHAR(11), FOR_DATE, 106),8) END + ' - ' + Label_Name
					FROM	#Yearly_Salary YS

					

					--SELECT	*
					--FROM	(SELECT	DISTINCT Month_Label,LEFT(REPLACE(CONVERT(VARCHAR(11), FOR_DATE, 102), '.', ''), 6) + RIGHT('0000' + CAST(SORT_INDEX AS VARCHAR(10)), 4) + Label_Name As SortField  
					--		 FROM	#Yearly_Salary) YS
					--ORDER BY SortField
			
					SELECT	@COLS=COALESCE(@COLS + ',','') + '[' + Month_Label + ']'
					FROM	(SELECT	DISTINCT Month_Label,LEFT(REPLACE(CONVERT(VARCHAR(11), FOR_DATE, 102), '.', ''), 6) + RIGHT('0000' + CAST(SORT_INDEX AS VARCHAR(10)), 4) + Label_Name As SortField  
							 FROM	#Yearly_Salary) YS
					ORDER BY SortField

					--INSERT INTO #Yearly_Salary
			
						
			
					IF LEN(@SELECT_COLS) > 0
						SET @SELECT_COLS = @SELECT_COLS + ','

					DECLARE @ORDERBY_COL VARCHAR(32)

					IF CHARINDEX(',',@SELECT_COLS) > 0
						SET @ORDERBY_COL = SUBSTRING(@SELECT_COLS, 0, CHARINDEX(',',@SELECT_COLS))
					ELSE
						SET @ORDERBY_COL = @SELECT_COLS

					SET @SQL = 'SELECT	'+ @SELECT_COLS + @COLS + '
								FROM	(SELECT ED.*,YS.Month_Label,YS.Label_Value
										FROM	#Yearly_Salary YS 
												INNER JOIN #EmpDetail ED ON YS.EMP_ID=ED.EMP_ID
										) T
										PIVOT (
											SUM(Label_Value) FOR Month_Label IN (' + @COLS + ')
										) PVT'

					
					SELECT	@SUM_COLS = COALESCE(@SUM_COLS + ',','') + CASE WHEN ID=1 THEN '''Total'' As ' ELSE 'NULL  As ' END + DATA
					FROM	dbo.Split(@SELECT_COLS,',') T WHERE DATA <> ''
			
					SELECT	@SUM_COLS = COALESCE(@SUM_COLS + ',','') + 'SUM(' + DATA + ') As ' + Data 
					FROM	dbo.Split(@COLS,',') T WHERE DATA <> ''
			
					SET @SQL =  @SQL 
				
						+ '
								UNION
								SELECT	'+ @SUM_COLS + '
								FROM	(SELECT ED.*,YS.Month_Label,Isnull(YS.Label_Value,0) as Label_Value
										FROM	#Yearly_Salary YS 
												INNER JOIN #EmpDetail ED ON YS.EMP_ID=ED.EMP_ID
										) T
										PIVOT (
											SUM(Label_Value) FOR Month_Label IN (' + @COLS + ')
										) PVT
								ORDER BY ' + @ORDERBY_COL
				
			
					EXEC (@SQL);
						--Select * FROM #tmpSalary
						--	ORDER BY Case							--- Added by rohit for Order by not Working in yearly salary report - cera
						--		When IsNumeric(Alpha_Emp_Code) = 1 then 
						--			Right(Replicate('0',21) + Alpha_Emp_Code , 20) 
						--		When IsNumeric(Alpha_Emp_Code) = 0 then 
						--			Left(Alpha_Emp_Code + Replicate('',21), 20)	
						--		Else 
						--			Alpha_Emp_Code 
						--		End,row_id
				END
		END
