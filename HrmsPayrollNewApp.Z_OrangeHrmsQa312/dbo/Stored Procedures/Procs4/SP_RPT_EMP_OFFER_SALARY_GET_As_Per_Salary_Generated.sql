

CREATE PROCEDURE [dbo].[SP_RPT_EMP_OFFER_SALARY_GET_As_Per_Salary_Generated]		
	 @CMP_ID		NUMERIC
	,@FROM_DATE		DATETIME
	,@TO_DATE		DATETIME 
	,@BRANCH_ID		NUMERIC   = 0
	,@CAT_ID		NUMERIC  = 0
	,@GRD_ID		NUMERIC = 0
	,@TYPE_ID		NUMERIC  = 0
	,@DEPT_ID		NUMERIC  = 0
	,@DESIG_ID		NUMERIC = 0
	,@EMP_ID		NUMERIC  = 0
	,@CONSTRAINT	VARCHAR(MAX) = ''
	,@LETTER		VARCHAR(30)='OFFER'
    ,@PBRANCH_ID	VARCHAR(200) = '0'
    ,@With_Leave_Encashment	TINYINT	= 0 --Added jimit 07052016
	,@Show_Hidden_Allowance  BIT = 1   --Added by Jaina 16-05-2017
	,@With_All_Allowance  BIT = 1   --Added by Ramiz 04/07/2018
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  

	IF @BRANCH_ID = 0  
		SET @BRANCH_ID = NULL   
	IF @GRD_ID = 0  
		SET @GRD_ID = NULL  
	IF @EMP_ID = 0  
		SET @EMP_ID = NULL  
	IF @DESIG_ID = 0  
		SET @DESIG_ID = NULL  
	IF @DEPT_ID = 0  
		SET @DEPT_ID = NULL 

	SET @Show_Hidden_Allowance = 0    


	CREATE TABLE #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	 )     
	 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,3,0,0,0
		
	CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);


	CREATE TABLE #CTCMast
	(
		Tran_ID			numeric IDENTITY(1,1), 	
		Cmp_ID			numeric,
		Emp_ID			numeric,
		Branch_ID		numeric,
		Increment_ID	numeric,
		Def_ID			numeric,
		Label_Head		varchar(100),
		Monthly_Amt		numeric(18,2),
		AD_ID			numeric,
		AD_Flag			char(1),
		AD_DEF_ID		numeric,
		Group_Name		varchar(100) null,
		Seq_No			Numeric(18,2) NULL,
		Salary_Group	varchar(100)null
	)
	
	CREATE CLUSTERED INDEX IX_CTC ON #CTCMast(EMP_ID,Branch_ID,Increment_ID,DEF_ID)
	
		
	DECLARE @COLUMNS nvarchar(MAX)
	DECLARE @CTC_EMP_ID NUMERIC(18,0)
	DECLARE @CTC_BASIC NUMERIC(18,2)
	/*
		DECLARE @AD_NAME_DYN NVARCHAR(100)
		DECLARE Allow_Dedu_Cursor CURSOR FOR
			SELECT AD_NAME 
			FROM T0210_MONTHLY_AD_DETAIL MAD 
				INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
			WHERE MAD.CMP_ID = @CMP_ID AND ((AD_FLAG = 'I' AND AD_PART_OF_CTC = 1) OR AD_FLAG = 'D')
				AND (MAD.M_AD_AMOUNT >0 OR MAD.REIMAMOUNT >0) --AND ISNULL(ALLOWANCE_TYPE,'A') = 'A'  AND AD_NOT_EFFECT_SALARY = 0
				AND MAD.FOR_DATE >= @FROM_DATE AND MAD.TO_DATE <= @TO_DATE
				AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND HIDE_IN_REPORTS = 1  THEN 0 ELSE 1 END) = 1 --ADDED BY JAINA 16-05-2017
			GROUP BY AM.AD_NAME,AD_LEVEL
			ORDER BY AD_LEVEL
		OPEN Allow_Dedu_Cursor
				FETCH NEXT FROM Allow_Dedu_Cursor into @AD_NAME_DYN
				WHILE @@fetch_status = 0
					BEGIN						
						SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
						
						SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM Allow_Dedu_Cursor into @AD_NAME_DYN
				END
		CLOSE Allow_Dedu_Cursor	
		DEALLOCATE Allow_Dedu_Cursor
	*/
	
		SET @COLUMNS = ''
		
		--COMMENTED ABOVE CURSOR AND IMPLEMENTED NEW LOGIC OF COALESCE BY RAMIZ ON 21/06/2018--
		IF @With_All_Allowance = 1	--ALL ALLOWANCE WITHOUT ANY CONDITION
			BEGIN
				SELECT @COLUMNS = @COLUMNS + COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') + '#' , '')
				FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
					INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
				WHERE MAD.CMP_ID = @CMP_ID
					AND (MAD.M_AD_AMOUNT > 0 OR MAD.REIMAMOUNT > 0)
					AND MAD.FOR_DATE >= @FROM_DATE AND MAD.TO_DATE <= @TO_DATE
					AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND HIDE_IN_REPORTS = 1  THEN 0 ELSE 1 END) = 1
				GROUP BY AM.AD_NAME,AD_LEVEL
				ORDER BY AD_LEVEL
			END
		ELSE
			BEGIN	--TAKING ONLY THOSE EARNING ALLOWANCE WHICH ARE PART OF CTC AND ALL DEDUCTION
				SELECT @COLUMNS = @COLUMNS + COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_') + '#' , '')
				FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
					INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
				WHERE MAD.CMP_ID = @CMP_ID AND 
					(
						(AD_FLAG = 'I' AND AM.AD_PART_OF_CTC = 1 and AM.AD_NOT_EFFECT_SALARY = 0) --EARNINGS
						 OR AD_FLAG = 'D' OR AM.Auto_Paid = 1	--DEDUCTIONS & AUTO PAID ALLOWANCE
					)	--TAKING EARNING COMPONENTS WHICH ARE PART OF CTC AND ALL DEDUCTIONS
					AND (MAD.M_AD_AMOUNT > 0 OR MAD.REIMAMOUNT > 0)
					AND MAD.FOR_DATE >= @FROM_DATE AND MAD.TO_DATE <= @TO_DATE
					AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND HIDE_IN_REPORTS = 1  THEN 0 ELSE 1 END) = 1
				GROUP BY AM.AD_NAME,AD_LEVEL
				ORDER BY AD_LEVEL
			END
		
	

	SET @COLUMNS = @COLUMNS +  'Gross_Salary#'
	SET @COLUMNS = @COLUMNS +  'PT#'
	SET @COLUMNS = @COLUMNS +  'Total_Deduction#'
	SET @COLUMNS = @COLUMNS +  'Net_Take_Home#'
	SET @COLUMNS = @COLUMNS +  'LWF_Amt#'  --Added jimit 23032016
	SET @COLUMNS = @COLUMNS +	'Arrear_Settlement_Amount#'  --Added Ramiz 06/07/2018
	
	if (@With_Leave_Encashment = 1 OR @With_All_Allowance = 1)
		BEGIN
			SET @COLUMNS = @COLUMNS +	'Leave_Encashment#' --Added jimit 07052016
		END

	DECLARE @Cur_Branch_ID as numeric(18,0)
	SET @Cur_Branch_ID = 0
	
	DECLARE @Prev_Branch_ID as numeric(18,0)
	SET @Prev_Branch_ID = 0
	
	DECLARE @Cur_Increment_ID as numeric(18,0)
	SET @Cur_Increment_ID = 0
	
	DECLARE @CTC_DOJ datetime
	DECLARE @CTC_NEW_DOJ datetime
	DECLARE @CTC_NEW_DOJ2 datetime
	DECLARE @CTC_PRV_MON_DOJ numeric
    DECLARE @CTC_TOT_MON numeric
	DECLARE @CTC_COLUMNS nvarchar(100)
	DECLARE @CTC_GROSS numeric(18,2)
	DECLARE @Total_Ear numeric(18,2)
	DECLARE @Total_Ded numeric(18,2)
	DECLARE @CTC_AD_FLAG varchar(1)
	DECLARE @CTC_PT numeric(18,2)
	DECLARE @Allow_Amount numeric(18,2)
	DECLARE @numTmpCal numeric(18,2)
	DECLARE @CTC_AD_ID numeric
	DECLARE @ALlow_Amount_Net as numeric(18,2)
	DECLARE @Ad_Level as numeric
	DECLARE @Ad_Flag as char
	DECLARE @AD_DEF_IF AS NUMERIC(18,0)
	DECLARE @Arrear_Allow_Amount AS NUMERIC(18,2)
	DECLARE @CTC_BASIC_ARREAR NUMERIC(18,2)
	DECLARE @Arrear_Allow_Amount_CutOff AS NUMERIC(18,2)  --Added BY jimit 04072019  For GTPL CASe Of Arrear Cutoff
	DEclare @REIMAMOUNT AS Numeric(18,2)   --Added BY jimit 08072019  For GTPL CASe Of Reim

	DECLARE CTC_UPDATE CURSOR FOR
		SELECT EC.Emp_Id,EC.Branch_ID,EC.Increment_ID,EM.Date_Of_Join,SUM(MS.Salary_Amount) , SUM(MS.AREAR_BASIC) + IsNULL(Qry.S_Salary_Amount,0) + ISNULL(SUM(MS.Basic_Salary_Arear_cutoff),0)
		FROM #Emp_Cons EC 
			INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on EC.Emp_ID = MS.Emp_ID
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_ID
			left join																					--Added By Jimit 06062019 as there is query at GTPL salary certificate amount is not match with yearly salary report (10830)
						(   SELECT  ms.Emp_ID,SUM(ms.S_Salary_Amount) AS S_Salary_Amount
						 FROM 	T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) 
								 INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID 
								 AND  S_Eff_Date Between @From_Date ANd @To_Date
						 GROUP BY ms.Emp_ID
					 ) Qry ON Qry.Emp_ID = EC.Emp_ID
		WHERE MS.Month_St_Date >= @From_Date And MS.Month_End_Date <= @To_Date And EM.Cmp_ID = @Cmp_Id
		GROUP BY EC.Emp_Id,EC.Branch_ID,EC.Increment_ID,EM.Date_Of_Join,Qry.S_Salary_Amount
	OPEN CTC_UPDATE
	FETCH NEXT FROM CTC_UPDATE into @CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,@CTC_DOJ,@CTC_BASIC,@CTC_BASIC_ARREAR
	WHILE @@fetch_status = 0
		BEGIN
			SET @CTC_COLUMNS = ''
			SET @CTC_GROSS = 0
			SET @Total_Ear = 0
			SET @Total_Ded = 0
			SET @CTC_AD_FLAG = ''
			SET @CTC_PT = 0
			SET @numTmpCal = 0
			SET @Allow_Amount = 0
			SET @AD_DEF_IF = 0
			SET @Arrear_Allow_Amount = 0
			SET @Arrear_Allow_Amount_CutOff= 0
			SET @REIMAMOUNT = 0


			INSERT INTO #CTCMAST 
				(Cmp_ID,Branch_ID,Increment_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group)
			VALUES
				(@Cmp_ID,@Cur_Branch_ID,@Cur_Increment_ID,@CTC_EMP_ID,Null,'Basic Salary',(@CTC_BASIC + @CTC_BASIC_ARREAR) ,NULL,'I',0,'Salary',1,'Gross Salary')
			
				DECLARE CRU_COLUMNS CURSOR FOR
					SELECT data from Split(@COLUMNS,'#') WHERE data <> ''
				OPEN CRU_COLUMNS
						FETCH NEXT FROM CRU_COLUMNS into @CTC_COLUMNS
						WHILE @@fetch_status = 0
							BEGIN					
									
								if @Cur_Increment_ID > 0
									BEGIN
										SET @CTC_COLUMNS = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
										
										If @CTC_COLUMNS = 'PT'
											BEGIN
												SELECT @Allow_Amount = SUM(PT_Amount),@Ad_Flag = 'D' FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
												SET @Ad_Level = 991
											END
										ELSE IF @CTC_COLUMNS = 'LWF_Amt'
											BEGIN												
												SELECT @Allow_Amount = SUM(LWF_Amount),@Ad_Flag = 'D' FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
												SET @Ad_Level = 992
											END
										ELSE IF @CTC_COLUMNS = 'Leave_Encashment'
											BEGIN												
												SELECT @Allow_Amount = SUM(Encashment_Amount),@Ad_Flag = 'I' FROM T0200_Salary_Leave_Encashment WITH (NOLOCK) WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
											END
										--ELSE IF @CTC_COLUMNS = 'Arrear_Settlement_Amount'   No need to add seperately amount for all othere heads in as a settlement change by jimit 06062019
											--BEGIN							
											--	SELECT @Allow_Amount = SUM(Settelement_Amount),@Ad_Flag = 'I' FROM T0200_MONTHLY_SALARY WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
											--	SET @Ad_Level = 993
											--END	
										ELSE If @CTC_COLUMNS = 'Bonus'
											BEGIN
												SELECT @Allow_Amount = SUM(Bonus_Amount),@Ad_Flag = 'I' FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
												SET @Ad_Level = 994
											END
										
										ELSE IF @CTC_COLUMNS = 'Net_Take_Home'	--Do Not Change the Spelling , it is Used in Report Side in Formula Field
											BEGIN												
												--SELECT @Allow_Amount = SUM(Net_Amount + isnull(Settelement_Amount,0)),@Ad_Flag = 'I' from T0200_MONTHLY_SALARY WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date  change by Jimit 06062019
													SELECT @Allow_Amount = SUM(Net_Amount),@Ad_Flag = 'I' from T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @CTC_EMP_ID And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
												SET @Ad_Level = 999
											END									
										ELSE
											BEGIN
												SELECT @Allow_Amount = SUM(MAD.M_AD_Amount), 
														@Ad_Level = AM.AD_LEVEL,
														@Ad_Flag = AM.AD_FLAG, 
														@CTC_AD_ID = AM.AD_ID,
														@AD_DEF_IF = AM.AD_DEF_ID,
														@Arrear_Allow_Amount = SUM(MAD.M_AREAR_AMOUNT),
														@Arrear_Allow_Amount_CutOff = SUM(MAD.M_AREAR_AMOUNT_Cutoff)
												FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
													INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID 
												WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AM.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													AND EMP_ID = @CTC_EMP_ID and MAD.For_Date >= @From_Date and MAD.For_Date <= @To_Date --Added by jimit 17042017
													AND ALLOWANCE_TYPE <> 'R'
												GROUP by AM.AD_LEVEL,AM.AD_FLAG, AM.AD_ID ,AM.AD_DEF_ID


												SELECT @REIMAMOUNT = SUM(ReimAmount)
												FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
													INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID 
												WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AM.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													AND EMP_ID = @CTC_EMP_ID and MAD.For_Date >= @From_Date and MAD.For_Date <= @To_Date --Added by jimit 17042017
													AND ALLOWANCE_TYPE = 'R'	
											END
										
										IF @ALLOW_AMOUNT > 0
											BEGIN
												SET @ALLOW_AMOUNT = ISNULL(@ALLOW_AMOUNT,0) + ISNULL(@Arrear_Allow_Amount,0) + ISNULL(@Arrear_Allow_Amount_CutOff,0) + ISNULL(@REIMAMOUNT,0)
												
												INSERT INTO #CTCMAST 
													(Cmp_ID,Emp_ID,Branch_ID,Increment_ID,Def_ID,Label_Head,Monthly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Group_Name,seq_no,Salary_Group)
												VALUES
													(@Cmp_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@Allow_Amount,0),@CTC_AD_ID,@Ad_Flag,@AD_DEF_IF,'',@Ad_Level,'')
											END
											
										SET @Allow_Amount = 0
										SET @Ad_Level = 0
										SET @CTC_AD_ID = 0
										SEt @Ad_Flag = Null
										SET @AD_DEF_IF = 0
										SET @Arrear_Allow_Amount = 0
									END
								FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
							End
				CLOSE CRU_COLUMNS	
				DEALLOCATE CRU_COLUMNS
					
	
			FETCH NEXT FROM CTC_UPDATE into @CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,@CTC_DOJ,@CTC_BASIC,@CTC_BASIC_ARREAR
		END
	CLOSE CTC_UPDATE	
	DEALLOCATE CTC_UPDATE
	
	----------------------------------------------------------------
		
	SELECT *,(Monthly_Amt * 12) as Total_Year_Amt
			,T.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
	FROM	#CTCMast	T	--Added By Gadriwala 17022014
	ORDER BY T.EMP_ID ,SEQ_NO, TRAN_ID
	
	
	DROP TABLE #CTCMAST
	
	RETURN



