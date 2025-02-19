

-------------------------------------------

--ADDED JIMIT 06022015------
---SALARY REGISTER FORM-R FOR TAMILNADU ---
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_ATTENDANCE_SALARY_REGISTER_FORMR]      
     @COMPANY_ID		NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		NUMERIC	
	,@GRADE_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@CAT_ID        NUMERIC = 0
	,@IS_COLUMN		TINYINT = 0
	,@SALARY_CYCLE_ID  NUMERIC  = 0
	,@SEGMENT_ID NUMERIC = 0 
	,@VERTICAL NUMERIC = 0 
	,@SUBVERTICAL NUMERIC = 0 
	,@SUBBRANCH NUMERIC = 0 
	,@SUMMARY VARCHAR(MAX)=''
	,@PBRANCH_ID VARCHAR(200) = '0'
	,@ORDER_BY   VARCHAR(30) = 'CODE' 
	,@REPORT_CALL VARCHAR(20) = 'IN-OUT'   
    ,@WEEKOFF_ENTRY VARCHAR(1) = 'Y'
    ,@STATE_ID  NUMERIC(18,0) = 0
    
    
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #EMP_CONS 
		(      
			EMP_ID NUMERIC ,     
			BRANCH_ID NUMERIC,
			INCREMENT_ID NUMERIC
		)	
	EXEC SP_RPT_FILL_EMP_CONS @COMPANY_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRADE_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	CREATE TABLE #CROSSTAB_FORMAT2       
		(   
			EMP_ID NUMERIC(18,0),
			CMP_ID NUMERIC(18,0),
			EMP_CODE VARCHAR(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Name_of_the_Person   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			SEX VARCHAR(20),
			Designation VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Daily_rated_Piece_rated_Monthly_Rated NUMERIC(18,0),
			WAGES_PERIOD_MONTH VARCHAR(5) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Total_no_of_days_worked_during_the_month NUMERIC(18,2),
			Units_of_work_done_no_of_days_worked  NUMERIC(18,2),
			daily_rate_of_wags_piece_rate NUMERIC(18,2),
			OT_RATE NUMERIC(18,2),
			BASIC_WAGES NUMERIC(18,2),		
			CMP_ADDRESS VARCHAR(500) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			STATE_NAME	VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS
			,DESIG_DIS_NO    NUMERIC(18,0) DEFAULT 0 
			,ENROLL_NO       VARCHAR(50)	 COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS DEFAULT ''	
		)    
	
	DECLARE @STATE_NAME VARCHAR(50)
	SELECT @STATE_NAME = STATE_NAME FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE	CMP_ID= @COMPANY_ID AND STATE_ID = @STATE_ID
	
	INSERT INTO	#CROSSTAB_FORMAT2(EMP_ID,CMP_ID,EMP_CODE,Name_of_the_Person,SEX,DESIGNATION,Daily_rated_Piece_rated_Monthly_Rated,WAGES_PERIOD_MONTH,Total_no_of_days_worked_during_the_month,Units_of_work_done_no_of_days_worked,
							daily_rate_of_wags_piece_rate,OT_RATE,BASIC_WAGES,CMP_ADDRESS,STATE_NAME,DESIG_DIS_NO,ENROLL_NO) 
	SELECT		E.EMP_ID,E.CMP_ID,E.EMP_CODE,( E.Alpha_Emp_Code+ ' - ' +E.EMP_FULL_NAME ) AS EMP_FULL_NAME,
				CASE WHEN E.GENDER='M' THEN 'MALE' ELSE 'FEMALE' END SEX,DM.DESIG_NAME,0,'',0,0,0,0,0,(CASE WHEN BM.BRANCH_ADDRESS = '' THEN CM.CMP_ADDRESS ELSE BM.BRANCH_ADDRESS END) AS CMP_ADDRESS
				,@STATE_NAME,DM.Desig_Dis_No,E.Enroll_No
	FROM		T0080_EMP_MASTER E WITH (NOLOCK)	INNER JOIN
					( SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @COMPANY_ID
						GROUP BY EMP_ID  ) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
					E.EMP_ID = INC_QRY.EMP_ID INNER JOIN
					#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID INNER JOIN
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID INNER JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN 
					T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID LEFT OUTER JOIN 
					T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
					
	
	----------------------------SALARY RELATED DETAILS-----------------------
	
				  
				  DECLARE @COLUMNS NVARCHAR(4000)
				DECLARE @CTC_BASIC NUMERIC(18,2)
				DECLARE @AD_NAME_DYN NVARCHAR(100)
				DECLARE @VAL NVARCHAR(MAX)
				SET @COLUMNS = '#'
				DECLARE @CTC_COLUMNS NVARCHAR(100)
				DECLARE @ALLOW_AMOUNT NUMERIC(18,2)
				DECLARE @CTC_AD_FLAG VARCHAR(1)
				DECLARE @AD_LEVEL NUMERIC
				DECLARE @SUM_OF_ALLOWNACES_DEDUCT AS VARCHAR(MAX)
				DECLARE @SUM_OF_ALLOWNACES_EARNING AS VARCHAR(MAX)
				SET @SUM_OF_ALLOWNACES_DEDUCT=''
				SET @SUM_OF_ALLOWNACES_EARNING = ''
				SET @AD_LEVEL = 0
				
				 DECLARE @COLUMN_EARNING	VARCHAR(4000)
				 DECLARE @COLUMN_DEDUCTION VARCHAR(4000)
				 SET @COLUMN_EARNING = ''
				 SET @COLUMN_DEDUCTION = ''
				  
				 
	-----------------------------ENDED--------------------------------------------------		
	
			
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD DA NUMERIC(18,2)'
		EXEC(@VAL)	
			
		-----------------FOR DA-------------------			
				UPDATE  C 
				SET		C.DA = Q.M_AD_AMOUNT
				FROM	#CROSSTAB_FORMAT2 C INNER JOIN
						(
						select MAD.M_AD_AMOUNT,EC.EMP_ID,AM.CMP_ID from T0050_AD_MASTER AM WITH (NOLOCK) INNER join
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.Emp_ID
						where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 11 and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) = year(@To_date)--and MAD.For_Date > = @From_date and MAD.For_Date < = @To_Date			
						)Q ON Q.EMP_ID = C.EMP_ID AND Q.CMP_ID = C.CMP_ID						
			-----------------END DA ----------------------------		
		
			
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD Other_Allowances_Cash_Payments_Nature_to_be_specified NUMERIC(18,2)'
		EXEC(@VAL)
		
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD OT_EARNED NUMERIC(18,2)'
		EXEC(@VAL)
			
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD Leave_wages_including_cash_in_Lieu_of_Kinds NUMERIC(18,2)'
		EXEC(@VAL)
			
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD GROSS_WAGES NUMERIC(18,2)'
		EXEC(@VAL)
		---------------------------FOR DEDUCTION COMPONENT ---------------------------------
		
	
		
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD Provident_Fund NUMERIC(18,2)'
		EXEC(@VAL)
		
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD ESI NUMERIC(18,2)'
		EXEC(@VAL)
		
		
		-----------------------------------Pf ANd ESIC------------------------------
		
		
				UPDATE  C
				SET	C.Provident_Fund = MAD.M_AD_AMOUNT
				From #CROSSTAB_FORMAT2 C INNER JOIN
					 #EMP_CONS EC On Ec.EMP_ID = C.EMP_ID INNER JOIN
					 T0210_MONTHLY_AD_DETAIL MAD ON Mad.Emp_ID = Ec.EMP_ID INNER join
					 T0050_AD_MASTER AM On MAD.AD_ID = AM.AD_ID	and C.CMP_ID = Am.CMP_ID							
				where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 2 
						and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)
				
				UPDATE  C
				SET	C.ESI = MAD.M_AD_AMOUNT
				From #CROSSTAB_FORMAT2 C INNER JOIN
					 #EMP_CONS EC On Ec.EMP_ID = C.EMP_ID INNER JOIN
					 T0210_MONTHLY_AD_DETAIL MAD ON Mad.Emp_ID = Ec.EMP_ID INNER join
					 T0050_AD_MASTER AM On MAD.AD_ID = AM.AD_ID	and C.CMP_ID = Am.CMP_ID							
				where	AM.CMP_ID = @Company_ID and AM.AD_DEF_ID = 3 
						and month(mad.To_date) = Month(@To_date) and YEAR(mad.to_date) =year(@To_date)
				
		
		-------------------------------end------------------------------------------
		
		
		
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD OTHER_DEDUCTION NUMERIC(18,2)'
		EXEC(@VAL)
		
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD TOTAL_DEDUCTION NUMERIC(18,2)'
		EXEC(@VAL)
			
		
		SET @VAL = 'ALTER TABLE  #CROSSTAB_FORMAT2 ADD NET_WAGES NUMERIC(18,2)'
		EXEC(@VAL)
	
	
	
	---------------------------ENDED------------------------------------------------------
	
							
							UPDATE  C 
							SET		C.Total_no_of_days_worked_during_the_month = Q.WORKING_DAYS,
									C.Units_of_work_done_no_of_days_worked = Q.SAL_CAL_DAYS
									,C.BASIC_WAGES = Q.SALARY_AMOUNT,C.OT_RATE = Q.OT_RATE
									,C.daily_rate_of_wags_piece_rate = Q.DAY_SALARY,C.WAGES_PERIOD_MONTH = Q.WAGES_PERIOD_MONTH
									,C.Daily_rated_Piece_rated_Monthly_Rated = Q.BASIC_SALARY
									,C.GROSS_WAGES = Q.GROSS_SALARY
									,C.NET_WAGES = Q.NET_AMOUNT
									--,C.OTHER_ALLOWANCES = Q.Other_Allow_Amount
									--,C.OTHER_DEDUCTION = Q.Other_Dedu_Amount
									,C.TOTAL_DEDUCTION = Q.Total_Dedu_Amount
									,C.OT_EARNED = Q.OT_AMOUNT
							FROM 	#CROSSTAB_FORMAT2 C INNER JOIN
									(							
										SELECT	 WORKING_DAYS ,SAL_CAL_DAYS
												,SALARY_AMOUNT, SUM(HOUR_SALARY) AS OT_RATE,
												 DAY_SALARY, BASIC_SALARY, MONTH(MONTH_ST_DATE) AS WAGES_PERIOD_MONTH,EMP_ID,CMP_ID
												 ,GROSS_SALARY,NET_AMOUNT,Other_Allow_Amount,Other_Dedu_Amount,Total_Dedu_Amount,SUM(ISNULL(OT_AMOUNT,0)) AS OT_AMOUNT
										FROM	 T0200_MONTHLY_SALARY WITH (NOLOCK)
										WHERE	 month(Month_End_Date) = month(@To_date) and YEAR(Month_End_Date) = YEAR(@To_date)
										GROUP BY WORKING_DAYS ,SAL_CAL_DAYS,SALARY_AMOUNT, DAY_SALARY,
												BASIC_SALARY,MONTH_ST_DATE,EMP_ID,CMP_ID,GROSS_SALARY,NET_AMOUNT,Other_Allow_Amount,Other_Dedu_Amount,Total_Dedu_Amount
									)Q ON Q.EMP_ID = C.EMP_ID AND Q.CMP_ID = C.CMP_ID
								
						
								
						UPDATE  C 
						SET		C.Other_Allowances_Cash_Payments_Nature_to_be_specified = (ISNULL(C.GROSS_WAGES,0) - (ISNULL(C.BASIC_WAGES,0) + ISNULL(C.DA,0)))					
						FROM 	#CROSSTAB_FORMAT2 C INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = C.EMP_ID
					
						UPDATE  C 
						SET		C.OTHER_DEDUCTION = (ISNULL(C.TOTAL_DEDUCTION,0) - (ISNULL(C.Provident_Fund,0) + ISNULL(C.ESI,0)))
						FROM 	#CROSSTAB_FORMAT2 C INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = C.EMP_ID
	---------------------------------ENDED------------------------------------------
	
	
	
				ALTER TABLE  #CROSSTAB_FORMAT2 ADD Signature_with_Date_or_Thumble_impression_Checque_no_ans_date_in_case_of_payment_through_Bank_Advice_of_the_Bank_to_be_appended VARCHAR
				ALTER TABLE  #CROSSTAB_FORMAT2 ADD Total_unpaid_amounts_accumu_lated  NUMERIC
				--ALTER TABLE #CROSSTAB_FORMAT2 DROP COLUMN CODE
				
				DECLARE @STRING	VARCHAR(MAX)				
				SET @STRING = 'INSERT INTO #CROSSTAB_FORMAT2 (EMP_CODE,Name_of_the_Person,Designation,BASIC_WAGES,Desig_dis_no,Enroll_no' + @COLUMN_EARNING + ',GROSS_WAGES'+ @COLUMN_DEDUCTION + ',NET_WAGES)
								SELECT 9999999999,''TOTAL'','' '',SUM(BASIC_WAGES) AS BASIC_WAGES,0,99999999999'
								 + @SUM_OF_ALLOWNACES_EARNING + ',SUM(GROSS_WAGES) AS GROSS_WAGES'
								 + @SUM_OF_ALLOWNACES_DEDUCT + ',SUM(NET_WAGES) AS NET_WAGES
								 FROM #CROSSTAB_FORMAT2'		
				
				
				EXEC(@STRING)		
				
				
				SELECT ROW_NUMBER() OVER(ORDER BY  @ORDER_BY  ASC) AS SR_NO,* 
				Into #Crosstabdata
				FROM #CROSSTAB_FORMAT2 T
				ORDER BY
				CASE WHEN @Order_By ='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(T.Enroll_No AS VARCHAR), 21) 
				--WHEN @Order_By='Name' THEN #CROSSTABDATA.
				When @Order_By = 'Designation' then (CASE WHEN T.Desig_dis_No  = 0 THEN T.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(T.Desig_dis_No AS VARCHAR), 21)   END)   
				---ELSE RIGHT(REPLICATE(N' ', 500) + #CTCMast.Emp_Code, 500) 
				End,Case When IsNumeric(Replace(Replace(T.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(T.Emp_Code,'="',''),'"',''), 20)
					 When IsNumeric(Replace(Replace(T.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(T.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
					 Else Replace(Replace(T.Emp_Code,'="',''),'"','') End 
				
				update #Crosstabdata set SR_NO = 999999
				Where EMp_ID IS NULL
				
				SELECT * FROM #Crosstabdata 
				Order by SR_NO
				
				
				DROP TABLE #CROSSTAB_FORMAT2
				
				
				

