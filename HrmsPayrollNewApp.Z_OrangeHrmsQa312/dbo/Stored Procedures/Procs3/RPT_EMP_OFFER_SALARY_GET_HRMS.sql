

CREATE PROCEDURE [dbo].[RPT_EMP_OFFER_SALARY_GET_HRMS]
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
	,@LETTER		VARCHAR(30)= 'Offer'
    ,@PBRANCH_ID VARCHAR(200) = '0'
    ,@REQ_TYPE		INT = 0 --0 EMPLOYEE ,1 CANDIDATE
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	 DECLARE @YEAR_END_DATE AS DATETIME  
	 DECLARE @USER_TYPE VARCHAR(30)  
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
		
	CREATE TABLE #EMP_CONS 
 (      
	EMP_ID NUMERIC ,     
	BRANCH_ID NUMERIC,
	INCREMENT_ID NUMERIC
 )   
 
 IF @REQ_TYPE = 0
	BEGIN
		 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,3,0,0,0
	END
ELSE
	BEGIN
		INSERT INTO #EMP_CONS(EMP_ID)
		select data from dbo.Split(@constraint,'#')
		--SELECT Resume_ID,Branch_id,Tran_ID
		--from T0060_RESUME_FINAL where Resume_ID = (select data from dbo.Split(@constraint,'#'))
	END
 
 CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);

	CREATE TABLE #CTCMAST
(
	
	TRAN_ID		NUMERIC IDENTITY(1,1), 	
	CMP_ID		NUMERIC,
	BRANCH_ID	NUMERIC,
	INCREMENT_ID NUMERIC,
	EMP_ID		NUMERIC,
	DEF_ID		NUMERIC,
	LABEL_HEAD	VARCHAR(100),
	MONTHLY_AMT	NUMERIC(18,2),
	YEARLY_AMT	NUMERIC(18,2),
	AD_ID		NUMERIC,
	AD_FLAG		CHAR(1),
	AD_DEF_ID	NUMERIC,
	Allowance_Type	CHAR(1) DEFAULT '',  --added jimit 04032016	
	Group_Name  VARCHAR(20) DEFAULT ''  --Added By Jimit 03012019
)	
	CREATE NONCLUSTERED INDEX IX_CTCMAST ON #CTCMAST
	(
	 TRAN_ID,CMP_ID,BRANCH_ID,INCREMENT_ID,EMP_ID,DEF_ID
	)
	
	----------------------------------------------------------------
	DECLARE @COLUMNS NVARCHAR(2000)
	DECLARE @CTC_CMP_ID NUMERIC(18,0)
	DECLARE @CTC_EMP_ID NUMERIC(18,0)
	DECLARE @CTC_BASIC NUMERIC(18,2)
	DECLARE @AD_NAME_DYN NVARCHAR(100)
	DECLARE @VAL NVARCHAR(500)
	DECLARE @Allowance_Type	char(1)

	
	SET @COLUMNS = '#'
	DECLARE ALLOW_DEDU_CURSOR CURSOR FOR
	SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 0 AND AD_FLAG = 'I' ORDER BY AD_LEVEL
	OPEN ALLOW_DEDU_CURSOR
			FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
			WHILE @@FETCH_STATUS = 0
				BEGIN									
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
				END
	CLOSE ALLOW_DEDU_CURSOR	
	DEALLOCATE ALLOW_DEDU_CURSOR
	----------------------------------------------------------------
	SET @COLUMNS = @COLUMNS +  'Gross_Salary#'
	----------------------------------------------------------------
	DECLARE ALLOW_DEDU_CURSOR CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 1 AND AD_FLAG = 'I' ORDER BY AD_LEVEL
	OPEN ALLOW_DEDU_CURSOR
			FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
			WHILE @@FETCH_STATUS = 0
				BEGIN									
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
				END
	CLOSE ALLOW_DEDU_CURSOR	
	DEALLOCATE ALLOW_DEDU_CURSOR
	
	----------------------------------------------------------------
	SET @COLUMNS = @COLUMNS +  'CTC#'
	
	----------------------------------------------------------------
	DECLARE ALLOW_DEDU_CURSOR CURSOR FOR
		SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_NOT_EFFECT_SALARY = 0 AND AD_FLAG = 'D' ORDER BY AD_LEVEL
	OPEN ALLOW_DEDU_CURSOR
			FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
			WHILE @@FETCH_STATUS = 0
				BEGIN									
					SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')															
					SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'
					FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN
				END
	CLOSE ALLOW_DEDU_CURSOR	
	DEALLOCATE ALLOW_DEDU_CURSOR
	
	----------------------------------------------------------------
	SET @COLUMNS = @COLUMNS +  'PT#'
	SET @COLUMNS = @COLUMNS +  'Total_Deduction#'
	SET @COLUMNS = @COLUMNS +  'Net_Take_Home#'
	
	----------------------------------------------------------------
	
	SET @CTC_CMP_ID = @CMP_ID
	DECLARE @CUR_BRANCH_ID NUMERIC(18,0)
	DECLARE @CUR_INCREMENT_ID NUMERIC(18,0)
	SET @CUR_BRANCH_ID = 0
	SET @CUR_INCREMENT_ID = 0
	DECLARE @CTC_DOJ DATETIME
	DECLARE @CTC_NEW_DOJ DATETIME
	DECLARE @CTC_NEW_DOJ2 DATETIME
	DECLARE @CTC_PRV_MON_DOJ NUMERIC
	DECLARE @CTC_TOT_MON NUMERIC
	DECLARE @CTC_COLUMNS NVARCHAR(100)
	DECLARE @CTC_GROSS NUMERIC(18,2)
	DECLARE @TOTAL_EAR NUMERIC(18,2)
	DECLARE @TOTAL_DED NUMERIC(18,2)
	DECLARE @CTC_AD_FLAG VARCHAR(1)
	DECLARE @CTC_PT NUMERIC(18,2)
	DECLARE @ALLOW_AMOUNT NUMERIC(18,2)
	DECLARE @NUMTMPCAL NUMERIC(18,2)
	DECLARE @NUMTEMPCAL2 NUMERIC(18,2)
	DECLARE @NUMTEMPCAL3 NUMERIC(18,2)
	DECLARE @CTC_AD_ID NUMERIC
	DECLARE @ALLOW_AMOUNT_NET AS NUMERIC(18,2)
	---------------------------------------------------------------
	DECLARE @COUNT NUMERIC
	IF @REQ_TYPE = 0
		BEGIN
			DECLARE CTC_UPDATE CURSOR FOR
				SELECT	EC.EMP_ID,EC.BRANCH_ID,EC.INCREMENT_ID,EM.DATE_OF_JOIN,IE.BASIC_SALARY 
				FROM	#EMP_CONS EC 
					INNER JOIN T0095_INCREMENT IE WITH (NOLOCK) ON EC.INCREMENT_ID = IE.INCREMENT_ID
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = EC.EMP_ID
			OPEN CTC_UPDATE
			FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC
			WHILE @@FETCH_STATUS = 0
			BEGIN				
					SET @COUNT = 1
				
					IF YEAR(@CTC_DOJ) < YEAR(GETDATE()) -1 
						BEGIN					
							SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))
						END
					ELSE IF YEAR(@CTC_DOJ) = YEAR(GETDATE()) -1 AND MONTH(@CTC_DOJ) < 4
						BEGIN
							SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))
						END
					ELSE
						BEGIN	
							SET @CTC_NEW_DOJ = CONVERT(DATETIME,DBO.GET_MONTH_ST_DATE(MONTH(@CTC_DOJ),YEAR(@CTC_DOJ)))
						END
						
					IF MONTH(GETDATE()) = 3
						BEGIN	
							SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))
						END
					ELSE IF MONTH(GETDATE()) < 4
						BEGIN	
							SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))
						END
					ELSE
						BEGIN
							SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE())))
							SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE()) + 1))
						END
					SET @CTC_TOT_MON = DATEDIFF(mm,@CTC_NEW_DOJ,@CTC_NEW_DOJ2) + 1	
					IF @CTC_TOT_MON > 12
						BEGIN	
							SET @CTC_TOT_MON  = 12
						END
					SET @CTC_COLUMNS = ''
					SET @CTC_GROSS = 0
					SET @TOTAL_EAR = 0
					SET @TOTAL_DED = 0
					SET @CTC_AD_FLAG = ''
					SET @CTC_PT = 0
					SET @NUMTMPCAL = 0
					SET @ALLOW_AMOUNT = 0
					
					SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_BASIC * @CTC_TOT_MON)
				
					INSERT INTO #CTCMAST (CMP_ID,EMP_ID,Branch_ID,Increment_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Allowance_Type,Group_Name)
						VALUES
					(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@Cur_Increment_ID,@COUNT,'Basic Salary',@CTC_BASIC,@numTmpCal,NULL,'I',NULL,'A','Earning')
					
					SET @COUNT = @COUNT + 1
					
					DECLARE CRU_COLUMNS CURSOR FOR
						SELECT DATA FROM SPLIT(@COLUMNS,'#') WHERE DATA <> ''
					OPEN CRU_COLUMNS
						FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
						WHILE @@FETCH_STATUS = 0
							IF @CUR_INCREMENT_ID > 0
								BEGIN
									SET @CTC_COLUMNS = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
									SET @NUMTMPCAL = 0
									IF @CTC_COLUMNS = 'Gross_Salary'
										BEGIN													
											SET @CTC_GROSS =ISNULL(@TOTAL_EAR,0) + ISNULL(@CTC_BASIC,0)
											--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
											IF @CTC_GROSS > 0
												BEGIN
													SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_GROSS * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Group_Name)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@CTC_GROSS,(@NUMTMPCAL),NULL,'I',NULL,'Earning')
												
													SET @COUNT = @COUNT + 1
												END
										END
									ELSE IF	@CTC_COLUMNS = 'CTC'
										BEGIN
											SET @NUMTMPCAL =  ISNULL(@TOTAL_EAR,0) + ISNULL(@CTC_BASIC,0)
											IF @NUMTMPCAL > 0
												BEGIN			
													--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
													--DECLARE @NUMTEMPCAL2 NUMERIC(18,2)
													SET @NUMTEMPCAL2 = 0
													SET @NUMTEMPCAL2 = @NUMTEMPCAL2 + (@NUMTMPCAL * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@CUR_INCREMENT_ID,@COUNT, @CTC_COLUMNS,@NUMTMPCAL,@NUMTEMPCAL2,NULL,'I',NULL)
													SET @COUNT = @COUNT + 1
												END	
										END
									ELSE IF @CTC_COLUMNS = 'PT'	
										BEGIN
											SELECT @CTC_PT=EMP_PT_AMOUNT FROM T0095_INCREMENT WITH (NOLOCK) WHERE INCREMENT_ID=@CUR_INCREMENT_ID
											if @CTC_PT > 0
												BEGIN
													--added jimit 04032016	
														select @Allowance_Type = Allowance_Type 
														from   T0050_AD_MASTER  WITH (NOLOCK)
														WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														and CMP_ID = @CTC_CMP_ID 
													--ended
												
													SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_PT * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,@CTC_COLUMNS,@CTC_PT, @NUMTMPCAL ,NULL,'D',NULL)
													
													SET @COUNT = @COUNT + 1
													SET @TOTAL_DED = @TOTAL_DED + ISNULL(@CTC_PT,0)
												END												
										END
									ELSE IF @CTC_COLUMNS = 'Total_Deduction'
										BEGIN		
											IF  @TOTAL_DED > 0
												BEGIN	
													--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
													
													SET @NUMTMPCAL = @NUMTMPCAL + (@TOTAL_DED * @CTC_TOT_MON)													
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@TOTAL_DED,@NUMTMPCAL,NULL,'D',NULL)
													SET @COUNT = @COUNT + 1
												END				
										END
									ELSE IF @CTC_COLUMNS = 'Net_Take_Home'	
										BEGIN
											SET @NUMTMPCAL = (ISNULL(@CTC_GROSS,0)  - ISNULL(@TOTAL_DED,0))
											IF  @NUMTMPCAL > 0
												BEGIN		
													--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
																							
													--DECLARE @NUMTEMPCAL3 NUMERIC(18,2)
													SET @NUMTEMPCAL3 = 0
													SET @NUMTEMPCAL3 = @NUMTEMPCAL3 + (@NUMTMPCAL * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@NUMTMPCAL,@NUMTEMPCAL3,NULL,'M',NULL)	
													SET @COUNT = @COUNT + 1
												END
										END
									ELSE
										BEGIN
											SELECT @ALLOW_AMOUNT =  ISNULL(E_AD_AMOUNT,0),@CTC_AD_FLAG = E_AD_FLAG,@CTC_AD_ID = AD_Id ,@Allowance_Type = Allowance_Type 
												from 
												(
													SELECT DISTINCT EED.AD_ID,EED.E_AD_FLAG,
														 Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
															Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
														 Else
															eed.e_ad_Amount End As E_Ad_Amount,AD_LEVEL , AM.Allowance_Type
													FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
															T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
															T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
															( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
																From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
																( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
																	Where Emp_Id = @CTC_EMP_ID And For_date <= @To_Date 
																 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
															) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
													WHERE Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
														AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AM.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														AND EED.CMP_ID = @CTC_CMP_ID AND EED.EMP_ID = @CTC_EMP_ID AND EED.INCREMENT_ID = @CUR_INCREMENT_ID 
													
													UNION ALL
													
													SELECT DISTINCT    EED.AD_ID, EED.E_AD_FLAG, EED.E_AD_AMOUNT,AD_LEVEL  , T0050_AD_MASTER.Allowance_Type
													FROM   dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
															( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @CTC_EMP_ID AND INCREMENT_ID = @Cur_Increment_ID And For_date <= @To_Date GROUP BY Ad_Id )Qry 
																ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
															dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
															dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
													WHERE EED.EMP_ID = @CTC_EMP_ID AND EEd.ENTRY_TYPE = 'A'
														AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(dbo.T0050_AD_MASTER.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														AND EED.CMP_ID = @CTC_CMP_ID AND EED.EMP_ID = @CTC_EMP_ID AND EED.INCREMENT_ID = @CUR_INCREMENT_ID 
													
													) Qry_temp
													ORDER BY AD_LEVEL ASC
												
												
												IF @ALLOW_AMOUNT > 0
													BEGIN
														
														--DECLARE @ALLOW_AMOUNT_NET AS NUMERIC(18,2)
														SET @ALLOW_AMOUNT_NET = 0
														
														SET @ALLOW_AMOUNT_NET = @ALLOW_AMOUNT_NET + (@ALLOW_AMOUNT * @CTC_TOT_MON)
														
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Allowance_Type)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,@Allowance_Type)			
													
													END												   
										END
										
									IF @CTC_AD_FLAG = 'I'
										BEGIN
											SET @TOTAL_EAR = @TOTAL_EAR + ISNULL(@ALLOW_AMOUNT,0)
										END
									ELSE IF @CTC_AD_FLAG = 'D'
										BEGIN
											SET @TOTAL_DED = @TOTAL_DED + ISNULL(@ALLOW_AMOUNT,0)											
										END
									SET @ALLOW_AMOUNT = 0
									FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
								END
					CLOSE CRU_COLUMNS	
					DEALLOCATE CRU_COLUMNS
				FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC
			END	
			
			--Added By Jimit 04012019
			Update	C
			SEt		Group_Name = (CASE WHEN ((Isnull(Q.AD_NOT_EFFECT_SALARY,0) = 0 and C.Allowance_Type = 'A') or C.Allowance_Type = 'R') then 'Earning' else 'Other Components' end)					
			FROm	#CTCMAST C Inner join
					(
						SELect	Isnull(am.AD_NOT_EFFECT_SALARY,0) as AD_NOT_EFFECT_SALARY,
								C.EMP_ID,C.Ad_Id
						from	#CTCMAST C Inner Join
								T0050_AD_MASTER Am WITH (NOLOCK) On Am.Ad_Id = IsNull(c.Ad_Id,0)
					)Q On C.Emp_Id = Q.Emp_Id and Q.AD_ID = C.Ad_Id
			--Ended

			Update C Set C.AD_FLAG=A.AD_FLAG From #CTCMAST C Inner Join T0050_AD_MASTER A On C.AD_ID=A.AD_ID 
			Where C.AD_FLAG Is null
			
			SELECT *,(ISNULL(MONTHLY_AMT,0) * 12) AS TOTAL_YEAR_AMT FROM #CTCMAST  -- ADDED BY GADRIWALA 05012014
			ORDER BY EMP_ID ,TRAN_ID
			
			DROP TABLE #CTCMAST
		END
	ELSE
		BEGIN
			DECLARE CTC_UPDATE CURSOR FOR
				SELECT	EC.EMP_ID,EM.BRANCH_ID,EM.Tran_ID,EM.Joining_date,EM.Basic_Salay 
				FROM	#EMP_CONS EC 
					INNER JOIN T0060_RESUME_FINAL EM WITH (NOLOCK) ON EM.Resume_ID = EC.EMP_ID
			OPEN CTC_UPDATE
			FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC
			WHILE @@FETCH_STATUS = 0
			BEGIN	
					SET @COUNT = 1
					
					IF YEAR(@CTC_DOJ) < YEAR(GETDATE()) -1 
							BEGIN					
								SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))
							END
						ELSE IF YEAR(@CTC_DOJ) = YEAR(GETDATE()) -1 AND MONTH(@CTC_DOJ) < 4
							BEGIN
								SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))
							END
						ELSE
							BEGIN	
								SET @CTC_NEW_DOJ = CONVERT(DATETIME,DBO.GET_MONTH_ST_DATE(MONTH(@CTC_DOJ),YEAR(@CTC_DOJ)))
							END
						
					IF MONTH(GETDATE()) = 3
						BEGIN	
							SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))
						END
					ELSE IF MONTH(GETDATE()) < 4
						BEGIN	
							SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))
						END
					ELSE
						BEGIN
							SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE())))
							SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE()) + 1))
						END
					SET @CTC_TOT_MON = DATEDIFF(mm,@CTC_NEW_DOJ,@CTC_NEW_DOJ2) + 1
					IF @CTC_TOT_MON > 12
						BEGIN	
							SET @CTC_TOT_MON  = 12
						END	
					SET @CTC_COLUMNS = ''
					SET @CTC_GROSS = 0
					SET @TOTAL_EAR = 0
					SET @TOTAL_DED = 0
					SET @CTC_AD_FLAG = ''
					SET @CTC_PT = 0
					SET @NUMTMPCAL = 0
					SET @ALLOW_AMOUNT = 0	
					
					SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_BASIC * @CTC_TOT_MON)
					INSERT INTO #CTCMAST (CMP_ID,EMP_ID,Branch_ID,Increment_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Allowance_Type,group_NAme)
					VALUES
					(@CTC_CMP_ID,@CTC_EMP_ID,NULL,NULL,@COUNT,'Basic Salary',@CTC_BASIC,@numTmpCal,NULL,'I',NULL,'A','Earning')
					
					SET @COUNT = @COUNT + 1
				
					DECLARE CRU_COLUMNS CURSOR FOR
						SELECT DATA FROM SPLIT(@COLUMNS,'#') WHERE DATA <> ''
					OPEN CRU_COLUMNS
						FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
						WHILE @@FETCH_STATUS = 0
							IF @CUR_INCREMENT_ID > 0
								BEGIN
									SET @CTC_COLUMNS = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
									SET @NUMTMPCAL = 0
									IF @CTC_COLUMNS = 'Gross_Salary'
										BEGIN
											SET @CTC_GROSS =ISNULL(@TOTAL_EAR,0) + ISNULL(@CTC_BASIC,0)
											
											--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
											
											IF @CTC_GROSS > 0
												BEGIN
													SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_GROSS * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Group_Name)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@CTC_GROSS,(@NUMTMPCAL),NULL,'I',NULL,'Earning')
													
													SET @COUNT = @COUNT + 1
												END
										END
									ELSE IF	@CTC_COLUMNS = 'CTC'
										BEGIN
											SET @NUMTMPCAL =  ISNULL(@TOTAL_EAR,0) + ISNULL(@CTC_BASIC,0)
											IF @NUMTMPCAL > 0
												BEGIN
													
													--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
													
													SET @NUMTEMPCAL2 = 0
													SET @NUMTEMPCAL2 = @NUMTEMPCAL2 + (@NUMTMPCAL * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@Cur_Branch_ID,@CUR_INCREMENT_ID,@COUNT, @CTC_COLUMNS,@NUMTMPCAL,@NUMTEMPCAL2,NULL,'I',NULL)
													SET @COUNT = @COUNT + 1
												END	
										END
									ELSE IF @CTC_COLUMNS = 'PT'	
										BEGIN
											SELECT @CTC_PT=0 FROM T0060_RESUME_FINAL WITH (NOLOCK) WHERE Tran_ID=@CUR_INCREMENT_ID
											if @CTC_PT > 0
												BEGIN
													--added jimit 04032016	
														select @Allowance_Type = Allowance_Type 
														from   T0050_AD_MASTER WITH (NOLOCK)  
														WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
														and CMP_ID = @CTC_CMP_ID 
														--ended
													
													SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_PT * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,@CTC_COLUMNS,@CTC_PT, @NUMTMPCAL ,NULL,'D',NULL)
													
													SET @COUNT = @COUNT + 1
													SET @TOTAL_DED = @TOTAL_DED + ISNULL(@CTC_PT,0)
												END												
										END
									ELSE IF @CTC_COLUMNS = 'Total_Deduction'
										BEGIN
											IF @TOTAL_DED > 0
												BEGIN	
												
													--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
													
													SET @NUMTMPCAL = @NUMTMPCAL + (@TOTAL_DED * @CTC_TOT_MON)													
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@TOTAL_DED,@NUMTMPCAL,NULL,'D',NULL)
													SET @COUNT = @COUNT + 1
												END				
										END
									ELSE IF @CTC_COLUMNS = 'Net_Take_Home'	
										BEGIN
											SET @NUMTMPCAL = (ISNULL(@CTC_GROSS,0)  - ISNULL(@TOTAL_DED,0))
											IF  @NUMTMPCAL > 0
												BEGIN	
													
														--added jimit 04032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended												
													
													SET @NUMTEMPCAL3 = 0
													SET @NUMTEMPCAL3 = @NUMTEMPCAL3 + (@NUMTMPCAL * @CTC_TOT_MON)
													INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID)
														VALUES
													(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,REPLACE(@CTC_COLUMNS,'_',' '),@NUMTMPCAL,@NUMTEMPCAL3,NULL,'M',NULL)	
													SET @COUNT = @COUNT + 1
												END
										END
									ELSE
										BEGIN
											
												SELECT @ALLOW_AMOUNT=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=AD.AD_ID,@Allowance_Type = Allowance_Type  FROM T0090_HRMS_RESUME_EARN_DEDUCTION  DED WITH (NOLOCK)
												INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON DED.AD_ID = AD.AD_ID
												WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS AND DED.CMP_ID = @CTC_CMP_ID AND DED.Resume_id = @CTC_EMP_ID AND DED.TRAN_ID = @CUR_INCREMENT_ID 
																							
												IF @ALLOW_AMOUNT > 0
													BEGIN
														
														
														SET @ALLOW_AMOUNT_NET = 0
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
														SET @ALLOW_AMOUNT_NET = @ALLOW_AMOUNT_NET + (@ALLOW_AMOUNT * @CTC_TOT_MON)
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
														INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,Allowance_Type)
															VALUES
														(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,@Allowance_Type)			
														--Set @Count = @Count + 1
													END		
																					   
										END
										
									IF @CTC_AD_FLAG = 'I'
										BEGIN
											SET @TOTAL_EAR = @TOTAL_EAR + ISNULL(@ALLOW_AMOUNT,0)
										END
									ELSE IF @CTC_AD_FLAG = 'D'
										BEGIN
											SET @TOTAL_DED = @TOTAL_DED + ISNULL(@ALLOW_AMOUNT,0)											
										END
									SET @ALLOW_AMOUNT = 0
									FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS
								END
					CLOSE CRU_COLUMNS	
					DEALLOCATE CRU_COLUMNS
				FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC
			END
			
			--Added By Jimit 04012019
			Update	C
			SEt		Group_Name = (CASE WHEN ((Isnull(Q.AD_NOT_EFFECT_SALARY,0) = 0 and C.Allowance_Type = 'A') or C.Allowance_Type = 'R') then 'Earning' else 'Other Components' end)
					
			FROm	#CTCMAST C Inner join
					(
						SELect	Isnull(am.AD_NOT_EFFECT_SALARY,0) as AD_NOT_EFFECT_SALARY,
								C.EMP_ID,C.Ad_Id
						from	#CTCMAST C Inner Join
								T0050_AD_MASTER Am WITH (NOLOCK) On Am.Ad_Id = IsNull(c.Ad_Id,0)
					)Q On C.Emp_Id = Q.Emp_Id and Q.AD_ID = C.Ad_Id
			--Ended

			Update C Set C.AD_FLAG=A.AD_FLAG From #CTCMAST C Inner Join T0050_AD_MASTER A On C.AD_ID=A.AD_ID 
			Where C.AD_FLAG Is null
			
			SELECT *,(ISNULL(MONTHLY_AMT,0) * 12) AS TOTAL_YEAR_AMT FROM #CTCMAST  
			ORDER BY EMP_ID ,TRAN_ID
			
			DROP TABLE #CTCMAST
		END
	
END

