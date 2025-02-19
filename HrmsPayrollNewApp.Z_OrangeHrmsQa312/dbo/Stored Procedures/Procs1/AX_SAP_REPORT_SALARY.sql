
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AX_SAP_REPORT_SALARY]
	  @Cmp_Id		numeric output	 
	 ,@From_Date	datetime
	 ,@To_Date		datetime
	 ,@Flag			Char = 'C'
	 ,@AD_id_Pass	Numeric = 0
	 ,@Cost_Center	varchar(MAX) =''     --Added by Ramiz 18/05/2018
	  ,@Business_Segment	varchar(MAX) =''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE TABLE #AX_MAPPING
	(
		DOCDT		DATETIME,
		COCODE		VARCHAR(50),
		EMPNAME		VARCHAR(500),
		VOUDT		DATETIME,
		BUSIUNIT	VARCHAR(50),	
		COSTCENT	VARCHAR(50),		
		DEPTCODE	VARCHAR(50),		
		BANKCODE	VARCHAR(50),		
		JOURTYPE	VARCHAR(50),		
		JOURNAME	VARCHAR(50),		
		OFFSETAC	VARCHAR(50),			
		ACCODE1		VARCHAR(50),			
		ACCTTYPE	VARCHAR(50),				
		ACCDDR		VARCHAR(50)	,		
		PAYREFNO	VARCHAR(50),				
		PAYREFDT	VARCHAR(50),				
		AMOUNT		NUMERIC(18,2),
		TRANSACTION_TEXT NVARCHAR(500)	,
		CURRENCY	VARCHAR(50),					
		CUREXGRT	VARCHAR(50),						
		RECTNAME	VARCHAR(50),						
		VOUMONTH	VARCHAR(50),						
		EMPIND		VARCHAR(50),
		CMP_ID		NUMERIC(18,0),
		AD_ID		NUMERIC(18,0),
		DEPT_ID		NUMERIC(18,0),
		CC_ID		NUMERIC(18,0),
		AD_FLAG		CHAR(1),
		LOAN_ID		NUMERIC(18,0),
		VOUCHER_FLAG CHAR(1),
		VENDER_CODE VARCHAR(50),
		SORTING_NO	NUMERIC(18,0),
		BANK_ID		NUMERIC(18,0)
	)
	
DECLARE @VOU_DT	DATETIME
DECLARE @DOC_DT	DATETIME
SET @VOU_DT	= DATEADD(DD,-(DAY(@TO_DATE)),@TO_DATE)
SET @DOC_DT = @TO_DATE

DECLARE @TOTAL_EARNING AS NUMERIC(18,2)
DECLARE @TOTAL_DEDUCTION AS NUMERIC(18,2)
DECLARE @SUM_AMT AS NUMERIC(18,2) 
DECLARE @SUM_AMT_SETT AS NUMERIC(18,2)

SET @TOTAL_EARNING = 0
SET @TOTAL_DEDUCTION = 0


IF @AD_id_Pass = 0
		BEGIN
			IF ISNULL(@Cost_Center,'') = '' OR ISNULL(@Cost_Center,'') = '0'
				SELECT	@Cost_Center=COALESCE(@Cost_Center + '#','') + CAST(Center_ID AS VARCHAR(10))
				FROM	T0040_COST_CENTER_MASTER WITH (NOLOCK)
				WHERE	Cmp_ID=@Cmp_Id
			
			SET @Cost_Center = @Cost_Center + '#0'
			
			--Deleting Employees from EMP_CONS if Salary not done -- Added by Ramiz on 14/06/2019
			DELETE EC
			FROM #EMP_CONS EC
			WHERE NOT EXISTS (SELECT EMP_ID FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
								WHERE Month_St_Date >= @From_Date and Month_End_Date <= @To_Date and ec.emp_id = ms.Emp_ID) 
								
			INSERT INTO #AX_MAPPING
				(DOCDT,COCODE,EMPNAME,VOUDT,BUSIUNIT,COSTCENT,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1,ACCTTYPE,ACCDDR,PAYREFNO,PAYREFDT,AMOUNT,Transaction_Text,CURRENCY,CUREXGRT,RECTNAME,VOUMONTH,EMPIND,CMP_ID,AD_ID,DEPT_ID,CC_ID,AD_FLAG,LOAN_ID,VOUCHER_FLAG,VENDER_CODE,SORTING_NO,BANK_ID)
			SELECT @Doc_DT ,AX_Head.Cmp_Code,'',@vou_DT, group1.Segment_Code,group1.Center_Code,'','','0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
				@Cmp_Id,AX_Head.Ad_id,0,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',AX_Head.vender_code, AX_Head.Sorting_no , AX_Head.Bank_Id
			FROM
				(
					SELECT   ax.Ad_id, Sorting_no, Account, 
						(	
							CASE WHEN Month_Year =1 THEN Narration + ' FOR THE MONTH OF '  + UPPER(CAST(DATENAME(MONTH,@TO_DATE) AS VARCHAR(3))) + '.,' + CAST(YEAR(@TO_DATE) AS VARCHAR(5))
								 WHEN Month_Year =0 THEN Head_Name 
							END
						) as [Transaction Text],ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No , CM.Cmp_Code , AX.Bank_Id
					FROM    T9999_Ax_Mapping AX WITH (NOLOCK)						
					LEFT JOIN T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
					LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id where ax.Cmp_id = @Cmp_Id
				 ) as AX_Head
			CROSS JOIN  
				(SELECT DISTINCT CCM.Center_Code , ISNULL(ccm.Center_ID,0) as Center_id  , BS.Segment_ID , BS.Segment_Code 
				 FROM T0080_EMP_MASTER EM WITH (NOLOCK)
					INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
					INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
					LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
					LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID = INC.Segment_ID
					INNER JOIN (SELECT CAST(DATA AS NUMERIC) AS Center_ID
								FROM	dbo.Split(@Cost_Center, '#') T
								Where	Data <> '') T  ON IsNull(INC.Center_ID,0)=T.Center_ID
				WHERE  EM.CMP_ID = @CMP_ID 
				GROUP BY CCM.Center_Code, ccm.Center_ID , BS.Segment_ID , BS.Segment_Code 
				) AS group1
			ORDER BY  GROUP1.CENTER_CODE, AX_HEAD.SORTING_NO
		END


	DECLARE @CUR_CMP_ID AS NUMERIC(18,0)
	DECLARE @CUR_DEPT_ID AS NUMERIC(18,0)  
	DECLARE @CUR_CENTER_ID AS NVARCHAR(50)
	DECLARE @CUR_AD_ID AS NUMERIC(18,0)
	DECLARE @CUR_AD_FLAG AS CHAR(1)
	DECLARE @CUR_LOAN_ID AS NUMERIC(18,0)
	DECLARE @CUR_BUS_AREA AS NVARCHAR(50)
	DECLARE @AD_DEF_ID AS NUMERIC(18,0)
	DECLARE @ALPHA_EMP_CODE AS NVARCHAR(200)
	DECLARE @BANK_ID AS NUMERIC(18,0)
	DECLARE @VENDOR_CODE AS VARCHAR(50)
	
	SELECT CMP_ID,CC_ID,AD_ID,AD_FLAG,LOAN_ID,BUSIUNIT ,BANK_ID , VENDER_CODE
	INTO	#CURSOR_DATA
	FROM #AX_MAPPING 
	WHERE CMP_Id = @Cmp_Id AND COSTCENT IS NOT NULL AND BUSIUNIT IS NOT NULL
	--AND COSTCENT = 1010001

	DECLARE CUR_AX CURSOR FOR
		SELECT * FROM #CURSOR_DATA
	OPEN CUR_AX
	FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID, @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA , @BANK_ID , @VENDOR_CODE
	While @@fetch_Status = 0
		BEGIN
		
			SET @SUM_AMT_SETT=0 
			SET @SUM_AMT = 0

	
				
			If @CUR_AD_ID = 1002 -- Gross
				BEGIN
					SELECT @SUM_AMT = (ISNULL(SUM(MS.Gross_Salary),0) - (ISNULL(SUM(MS.Leave_Salary_Amount),0) + ISNULL(SUM(Ms.Gratuity_Amount),0) + ISNULL(SUM(Qry2.M_AD_Amount),0) + ISNULL(SUM(Qry2.M_AREAR_AMOUNT),0) + ISNULL(SUM(Qry2.M_AREAR_AMOUNT_Cutoff),0))) 
					FROM  T0200_MONTHLY_SALARY MS 
						--INNER JOIN 
						--	(SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I 
						--		INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--		INNER JOIN 
						--			(
						--				SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT
						--				WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--				AND CMP_ID = @CMP_ID 
						--				GROUP BY EMP_ID 
						--			) QRY ON
						--			I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id 
						--	) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						LEFT OUTER JOIN 
							(
								SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT ,  ISNULL(SUM(MAD.M_AREAR_AMOUNT),0) AS M_AREAR_AMOUNT ,ISNULL(SUM(MAD.M_AREAR_AMOUNT_Cutoff),0) AS M_AREAR_AMOUNT_Cutoff,  
								MAD.TO_DATE
								FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
									INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
								WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
								AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
								GROUP BY MAD.Emp_ID , MAD.TO_DATE
							) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE)
					
						UPDATE #AX_MAPPING 
						SET AMOUNT = @SUM_AMT
						WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
						AND BUSIUNIT =  @CUR_BUS_AREA
	
				END
				
			ELSE IF @CUR_AD_ID = 1003 -- Net Amount with Hold Salary
				BEGIN
					--Inserting Hold Salary Employees before All Employees
					INSERT INTO #AX_MAPPING
						(DOCDT,COCODE,EMPNAME,VOUDT,BUSIUNIT,COSTCENT,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1,ACCTTYPE,ACCDDR,PAYREFNO,PAYREFDT,AMOUNT,Transaction_Text,CURRENCY,CUREXGRT,RECTNAME,VOUMONTH,EMPIND,CMP_ID,AD_ID,DEPT_ID,CC_ID,AD_FLAG,LOAN_ID,VOUCHER_FLAG,VENDER_CODE,SORTING_NO,BANK_ID)
					SELECT	DOCDT , COCODE , (Initial + ' ' + Emp_First_Name + ' '+ Emp_Second_Name + ' '+ Emp_Last_Name)
							,VOUDT, BUSIUNIT , COSTCENT ,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1,ACCTTYPE,ACCDDR,PAYREFNO,PAYREFDT,Round(ISNULL(MS.Net_Amount,0) ,0)
							,'Hold Salary -' + CONVERT(VARCHAR(3), ms.Month_End_Date, 100) + '''' + CAST(YEAR(ms.Month_End_Date) AS VARCHAR) + ' of ' + (EM.Initial + ' ' + EM.Emp_First_Name + ' '+ EM.Emp_Second_Name + ' '+ EM.Emp_Last_Name) 
							,CURRENCY,CUREXGRT,RECTNAME,VOUMONTH,EMPIND,am.CMP_ID,AD_ID,am.DEPT_ID,CC_ID,'H' AS AD_FLAG,LOAN_ID, VOUCHER_FLAG,VENDER_CODE, (SORTING_NO - 1) , 0 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						INNER JOIN #AX_MAPPING AM ON am.CC_ID = inc.Center_ID and am.AD_ID = @CUR_AD_ID
					WHERE INC.Center_ID = @CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID and MS.Sal_Cal_Days <> 0 and Salary_Status = 'Hold'
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) 
						
					SELECT @SUM_AMT = ISNULL(SUM(MS.Net_Amount),0) 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
					where INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID and Salary_Status <> 'Hold'
					and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 --and EM.Dealer_Code = @CUR_BUS_AREA

					UPDATE #AX_MAPPING 
					SET AMOUNT = @SUM_AMT
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA and ISNULL(AD_FLAG,'') <> 'H'
					
					SET @TOTAL_DEDUCTION = ISNULL(@TOTAL_DEDUCTION,0) + ISNULL(@SUM_AMT,0)	
				END
					
			ELSE IF @CUR_AD_ID = 1006 -- LWF
				BEGIN
					SELECT @SUM_AMT = isnull(SUM(MS.LWF_Amount),0) 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						--INNER JOIN 
						--	(SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I 
						--		INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--		INNER JOIN 
						--			(
						--				SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT
						--				WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--				AND CMP_ID = @CMP_ID 
						--				GROUP BY EMP_ID 
						--			) QRY ON
						--			I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
					WHERE INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						
					UPDATE #AX_MAPPING 
					SET AMOUNT = @SUM_AMT
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
					SET @TOTAL_DEDUCTION = ISNULL(@TOTAL_DEDUCTION,0) + ISNULL(@SUM_AMT,0)	
				END
				
			ELSE IF @CUR_AD_ID = 1001 -- PT
				BEGIN
					SELECT @sum_amt = isnull(SUM(MS.PT_Amount),0) 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
					--INNER JOIN 
					--	(SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I 
					--		INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
					--		INNER JOIN 
					--			( 
					--				SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT
					--				WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
					--				AND CMP_ID = @CMP_ID 
					--				GROUP BY EMP_ID
					--			) QRY ON
					--			I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id 
					--	) AS INC ON INC.EMP_ID = MS.EMP_ID
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
					INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
					INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
					where INC.Center_ID =@CUR_CENTER_ID --and ms.Sal_Cal_Days <> 0
					and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)
					
					UPDATE #AX_MAPPING 
					SET AMOUNT = @SUM_AMT
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
					SET @TOTAL_DEDUCTION = ISNULL(@TOTAL_DEDUCTION,0) + ISNULL(@SUM_AMT,0)	
				END
			
			else if @CUR_AD_ID = 1015 -- Advance
				BEGIN

				--select 11,  * from #AX_MAPPING

					INSERT INTO #AX_MAPPING
						(DOCDT,COCODE,EMPNAME,VOUDT,BUSIUNIT,COSTCENT,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1,ACCTTYPE,ACCDDR,PAYREFNO,PAYREFDT,AMOUNT,Transaction_Text,CURRENCY,CUREXGRT,RECTNAME,VOUMONTH,EMPIND,CMP_ID,AD_ID,DEPT_ID,CC_ID,AD_FLAG,LOAN_ID,VOUCHER_FLAG,VENDER_CODE,SORTING_NO,BANK_ID)
					SELECT @Doc_DT , CM.Cmp_Code , (Initial + ' ' + Emp_First_Name + ' '+ Emp_Second_Name + ' '+ Emp_Last_Name) ,@vou_DT, BS.Segment_Code , CCM.Center_Code , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' ,  
					Round(ISNULL(MS.Advance_Amount,0) ,0) as Advance_Amonut  , 
					(EM.Initial + ' ' + EM.Emp_First_Name + ' '+ EM.Emp_Second_Name + ' '+ EM.Emp_Last_Name) + ' ' + 'Advance' , 'INR' , '' , '' , ''  , '' , em.Cmp_ID ,  @CUR_AD_ID , 0 , INC.Center_ID , 'D' , 0 , 'D', EM.Dealer_Code , 20 , 0 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
								--INNER JOIN 
								--	(
								--		SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code , I.Segment_ID FROM T0095_INCREMENT I 
								--			INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID
								--			INNER JOIN 
								--				( 
								--					SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT
								--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
								--					AND CMP_ID = @CMP_ID 
								--					GROUP BY EMP_ID
								--				) QRY ON
								--		I.EMP_ID = QRY.EMP_ID AND I.Increment_Id = QRY.Increment_Id
								--	) AS INC ON INC.EMP_ID = MS.EMP_ID
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
								INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
								INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
								Inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EM.Cmp_ID
								Left OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID = INC.Segment_ID
								Left OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
								Left Outer JOin T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) on AP.Emp_ID = EM.Emp_ID and AP.For_Date = DATEADD(DAY , 1 , @TO_date)
							WHERE INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID and MS.Sal_Cal_Days <> 0 and MS.Advance_Amount <> 0 
								and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) 


								SET @TOTAL_DEDUCTION = ISNULL(@TOTAL_DEDUCTION,0) + ISNULL(@SUM_AMT,0)
	
								
							--UPDATE #AX_MAPPING SET AMOUNT = @SUM_AMT
							--WHERE LOAN_ID = @CUR_LOAN_ID AND CC_ID = @CUR_CENTER_ID
							--AND BUSIUNIT =  @CUR_BUS_AREA
				END
				
			else if @CUR_AD_ID = 1030 -- lEAVE Encashment
				BEGIN
					
					SELECT @sum_amt = isnull(SUM(MS.Leave_Salary_Amount),0) 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						--INNER JOIN (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code 
						--			FROM T0095_INCREMENT I 
						--				INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--				INNER JOIN 
						--				( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID 
						--				  FROM T0095_INCREMENT
						--				  WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @CMP_ID 
						--				  GROUP BY EMP_ID
						--				) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id 
						--			) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
					WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						AND MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)
						
					UPDATE #AX_MAPPING 
					SET AMOUNT = @SUM_AMT, AD_FLAG = 'I' -- Added Flag by Hardik 08/08/2020 for Arkray client
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
					SET @TOTAL_EARNING = ISNULL(@TOTAL_EARNING,0) + ISNULL(@SUM_AMT,0)
				END
				
			else if @CUR_AD_ID = 2003 -- Basic Amount
				BEGIN


						SELECT @SUM_AMT = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) + isnull(SUM((MS.Basic_Salary_arear_cutoff )),0) 
						FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						--INNER JOIN (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code 
						--            FROM T0095_INCREMENT I INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--			INNER JOIN 
						--				( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
						--				  WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--				  AND CMP_ID = @CMP_ID 
						--				  GROUP BY EMP_ID 
						--				 ) QRY ON	I.EMP_ID = QRY.EMP_ID AND I.Increment_Id = QRY.Increment_Id 
						--			) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MS.EMP_ID = EM.EMP_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						
						SELECT @sum_amt_Sett = isnull(SUM(MS.S_Salary_Amount),0) 
						FROM  T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
							--INNER JOIN 
							--	(SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I 
							--	INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
							--	INNER JOIN 
							--				( 
							--					SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
							--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
							--						AND CMP_ID = @CMP_ID 
							--					GROUP BY EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id
							--				) AS INC ON INC.EMP_ID = MS.EMP_ID
							INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
							INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
							INNER Join T0200_MONTHLY_SALARY MSL WITH (NOLOCK) ON MSL.EMP_ID = MS.EMP_ID AND MONTH(Month_End_Date) = MONTH(S_Eff_Date) and YEAR(Month_End_Date) = YEAR(S_Eff_Date)
						WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID and ms.Effect_On_Salary = 1
							and MONTH(S_Eff_Date) = MONTH(@To_Date)  and YEAR(S_Eff_Date) = YEAR(@To_Date)-- and EM.Dealer_Code = @CUR_BUS_AREA
						

						SET @SUM_AMT = @SUM_AMT + @SUM_AMT_SETT
						
						UPDATE #AX_MAPPING 
						SET AMOUNT = @SUM_AMT , AD_FLAG = 'B'
						WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
						AND BUSIUNIT =  @CUR_BUS_AREA
						
						SET @TOTAL_EARNING = ISNULL(@TOTAL_EARNING,0) + ISNULL(@SUM_AMT,0)


							

						--select @TOTAL_EARNING as Basic_Earning
					END
					
			else if @CUR_AD_FLAG = 'I' --This will give you all Earnings
				BEGIN
					SELECT @SUM_AMT = isnull(SUM(MAD.M_AD_AMOUNT),0) + ISNULL(SUM(MAD.M_AREAR_AMOUNT),0) + ISNULL(SUM(MAD.M_AREAR_AMOUNT_CUTOFF),0)
					FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						--INNER JOIN 
						--	(SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code 
						--		FROM T0095_INCREMENT I 
						--		INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--		INNER JOIN 
						--			( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
						--			  WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--			  AND CMP_ID = @CMP_ID 
						--			  GROUP BY EMP_ID  
						--			) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id
						--		) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						LEFT JOIN T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
					WHERE INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID AND MS.Sal_Cal_Days <> 0
						and MONTH(month_end_date) = MONTH(@To_Date) and YEAR(month_end_date) = YEAR(@To_Date) and mad.AD_ID = @CUR_AD_id
						--and AM.AD_NOT_EFFECT_SALARY <> 1
						
					SET @SUM_AMT_SETT = 0
					
					SELECT @SUM_AMT_SETT = isnull(sum(M_Ad_Amount),0)
					FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						INNER JOIN T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID 
						INNER JOIN T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
						--INNER JOIN (
						--			SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code 
						--			FROM T0095_INCREMENT I 
						--			INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--			INNER JOIN 
						--				(	SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID 
						--					FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
						--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--					AND CMP_ID = @CMP_ID 
						--					GROUP BY EMP_ID  
						--				) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id
						--			) AS INC ON INC.EMP_ID = MAD.EMP_ID	and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MAD.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						INNER Join T0200_MONTHLY_SALARY MSL WITH (NOLOCK) ON MSL.EMP_ID = MSS.EMP_ID AND MONTH(Month_End_Date) = MONTH(S_Eff_Date) and YEAR(Month_End_Date) = YEAR(S_Eff_Date)
					WHERE MAD.Cmp_ID = @cmp_id and month(MSS.S_Eff_Date) =  month(@To_Date ) and Year(MSS.S_Eff_Date) = year(@To_Date ) and
					Ad_Active = 1 And sal_type=1 and mad.ad_id =@CUR_AD_id and inc.Center_ID = @CUR_CENTER_ID and mss.Effect_On_Salary = 1 --and  inc.Dealer_Code =  @CUR_BUS_AREA	
					--and t0050_ad_master.AD_NOT_EFFECT_SALARY <>1
				
					SET @SUM_AMT = @SUM_AMT + @SUM_AMT_SETT		
					
					SET @TOTAL_EARNING = ISNULL(@TOTAL_EARNING,0) + ISNULL(@SUM_AMT,0)
				
				--SELECT @TOTAL_EARNING as Allowance_Earning	 ,@SUM_AMT as Allowance_Amount ,  @CUR_AD_id

					UPDATE #AX_MAPPING 
					SET AMOUNT = @SUM_AMT
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
				END
			
			ELSE IF @CUR_AD_FLAG = 'D'	--This will give you all Deduction
				BEGIN
					SELECT @SUM_AMT = ISNULL(SUM(MAD.M_AD_AMOUNT),0) + ISNULL(SUM(MAD.M_AREAR_AMOUNT),0) + ISNULL(SUM(MAD.M_AREAR_AMOUNT_Cutoff),0) 
					FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						--INNER JOIN (
						--			SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I 
						--			INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--			INNER JOIN 
						--				( 
						--					SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT
						--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--					AND CMP_ID = @CMP_ID 
						--					GROUP BY EMP_ID
						--				) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						LEFT JOIN T0050_AD_MASTER Am WITH (NOLOCK) on  MAD.AD_ID = Am.AD_ID 
						where inc.Center_ID = @CUR_CENTER_ID AND MS.Sal_Cal_Days <> 0 AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and mad.AD_ID = @CUR_AD_id
						and AM.AD_NOT_EFFECT_SALARY <> 1
						
					SET @SUM_AMT_SETT = 0
					
					SELECT @SUM_AMT_SETT = ISNULL(SUM(M_AD_AMOUNT),0) 
					FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						INNER JOIN T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) ON MAD.SAL_TRAN_ID=MSS.SAL_TRAN_ID 
						INNER JOIN T0050_AD_MASTER WITH (NOLOCK)  ON MAD.AD_ID = T0050_AD_MASTER.AD_ID
						--INNER JOIN 
						--		(
						--			SELECT I.EMP_ID,I.CENTER_ID ,E.DEALER_CODE FROM T0095_INCREMENT I 
						--			INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID 
						--			INNER JOIN 
						--				(
						--					SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT
						--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--					AND CMP_ID = @CMP_ID 
						--					GROUP BY EMP_ID
						--				) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID 
						--		) AS INC ON INC.EMP_ID = MAD.EMP_ID AND MAD.CMP_ID = T0050_AD_MASTER.CMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MAD.EMP_ID = EM.EMP_ID
						INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
						INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
						INNER Join T0200_MONTHLY_SALARY MSL WITH (NOLOCK) ON MSL.EMP_ID = MSS.EMP_ID AND MONTH(Month_End_Date) = MONTH(S_Eff_Date) and YEAR(Month_End_Date) = YEAR(S_Eff_Date)
					WHERE MAD.CMP_ID = @CMP_ID AND MONTH(MSS.S_EFF_DATE) =  MONTH(@TO_DATE ) AND YEAR(MSS.S_EFF_DATE) = YEAR(@TO_DATE ) AND
					AD_ACTIVE = 1 AND SAL_TYPE=1 AND MAD.AD_ID =@CUR_AD_ID AND INC.CENTER_ID = @CUR_CENTER_ID and mss.Effect_On_Salary = 1 --AND  INC.DEALER_CODE =  @CUR_BUS_AREA	
					AND T0050_AD_MASTER.AD_NOT_EFFECT_SALARY <> 1
				
					SET @SUM_AMT = @SUM_AMT + @SUM_AMT_SETT	
					
					SET @TOTAL_DEDUCTION = ISNULL(@TOTAL_DEDUCTION,0) + ISNULL(@SUM_AMT,0)
			
					
					UPDATE #AX_MAPPING SET AMOUNT = @SUM_AMT
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID and LOAN_ID = 0 AND BANK_ID = 0 AND VENDER_CODE = ''
					AND BUSIUNIT =  @CUR_BUS_AREA
				END
				
			ELSE IF @CUR_AD_ID = 0 and @CUR_LOAN_ID <> 0		--This will Give you Loan Entries Employee Wise
				BEGIN
				
					SELECT  @SUM_AMT = ROUND(SUM(ISNULL(MS.Loan_Amount,0) - ISNULL(AP.Adv_Amount,0)) ,0)
					FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
								INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
								INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
								INNER JOIN T0140_LOAN_TRANSACTION LT WITH (NOLOCK) ON LT.Emp_ID = MS.Emp_ID and LT.For_Date = MS.Month_End_Date
								Inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EM.Cmp_ID
								LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID = INC.Segment_ID
								LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
								LEFT OUTER JOIN T9999_Ax_Mapping AX WITH (NOLOCK) on AX.Loan_id = @CUR_LOAN_ID
								LEFT OUTER JOIN T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) on AP.Emp_ID = EM.Emp_ID and AP.For_Date = DATEADD(DAY , 1 , @TO_date)
					WHERE INC.Center_ID =@CUR_CENTER_ID and LT.Loan_ID = @CUR_LOAN_ID AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)
							

					SET @TOTAL_DEDUCTION = ISNULL(@TOTAL_DEDUCTION,0) + ISNULL(@SUM_AMT,0)
						
					UPDATE #AX_MAPPING SET AMOUNT = @SUM_AMT
					WHERE LOAN_ID = @CUR_LOAN_ID AND CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
				END
				
			ELSE IF @CUR_AD_ID = 2052	--This will Give you Interest of Loan Entries Consolidated
				BEGIN
				
					SELECT @SUM_AMT = ROUND(ISNULL(SUM(MS.LOAN_INTREST_AMOUNT),0),0) 
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MS.EMP_ID = EM.EMP_ID
							INNER JOIN #EMP_CONS EC ON EM.Emp_ID = EC.EMP_ID
							INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) ON EC.Increment_ID = INC.Increment_ID AND EC.Emp_ID = INC.Emp_ID
							WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Sal_Cal_Days <> 0 AND MS.Cmp_ID = @CUR_CMP_ID
							AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) -- AND ISNULL(MS.IS_FNF,0)  = 0 --AND EM.DEALER_CODE = @CUR_BUS_AREA
						
			
						UPDATE #AX_MAPPING SET AMOUNT = @SUM_AMT
						WHERE AD_ID = @CUR_AD_ID AND CC_ID = @CUR_CENTER_ID	
						AND BUSIUNIT =  @CUR_BUS_AREA	
						
				END
				
			Else If @CUR_AD_ID = 0 and @Bank_id <> 0			--This will give Bank wise Summary
				BEGIN
		
						SELECT @SUM_AMT = isnull(Sum(MEB.Net_Amount),0) --- (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0)) 
						from MONTHLY_EMP_BANK_PAYMENT MEB WITH (NOLOCK)
							Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MEB.Emp_ID = MS.Emp_ID and MONTH(MEB.For_date) = MONTH(@TO_DATE)  AND YEAR(MEB.For_date) = YEAR(@TO_DATE)
							Inner JOIN T0095_INCREMENT I WITH (NOLOCK) on Ms.Increment_ID = I.Increment_ID
							LEFT JOIN T0040_BANK_MASTER BM WITH (NOLOCK) on BM.Bank_ID = @Bank_id
						WHERE I.Center_ID = @CUR_CENTER_ID And MEB.Emp_Bank_ID = @Bank_id  and 
						MEB.Process_Type = 'Salary' and MEB.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						GROUP BY I.Center_ID ,BM.Bank_Name	
						
						--Taking From Salary--
						--	SELECT @SUM_AMT = isnull(Sum(MS.Net_Amount),0) - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0)) from T0200_MONTHLY_SALARY MS
						--	Inner JOIN T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID
						--	LEFT JOIN T0040_BANK_MASTER BM on BM.Bank_ID = @Bank_id
						--	LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--		GROUP BY MAD.Emp_ID , MAD.TO_DATE
						--	) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						--WHERE I.Center_ID = @CUR_CENTER_ID And I.Bank_ID = @Bank_id
						--and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						--GROUP BY I.Center_ID ,BM.Bank_Name	
						
				
						UPDATE #AX_MAPPING set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC' 
						WHERE AD_ID = @CUR_AD_ID and  cc_id = @CUR_CENTER_ID and Bank_id = @Bank_id
						AND BUSIUNIT =  @CUR_BUS_AREA
					
				
				END
			
			Else If @CUR_AD_ID = 0 and @VENDOR_CODE = 'Cheque'	--This will give Cheque Summary
				BEGIN
			
						SELECT @SUM_AMT = isnull(Sum(MEB.Net_Amount),0) --- (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						from MONTHLY_EMP_BANK_PAYMENT MEB WITH (NOLOCK)
						Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MEB.Emp_ID = MS.Emp_ID and MONTH(MEB.For_date) = MONTH(@TO_DATE)  AND YEAR(MEB.For_date) = YEAR(@TO_DATE)
						Inner JOIN T0095_INCREMENT I WITH (NOLOCK) on Ms.Increment_ID = I.Increment_ID
						WHERE I.CENTER_ID = @CUR_CENTER_ID AND MEB.PAYMENT_MODE = 'CHEQUE' 
						and MEB.Process_Type = 'Salary' and MEB.Cmp_ID = @CUR_CMP_ID
						AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) --AND ISNULL(MS.IS_FNF,0)  = 0 
						GROUP BY I.CENTER_ID
						
						
						----Taking from Salary--
						--SELECT @SUM_AMT = isnull(Sum(MS.Net_Amount),0) - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						--from T0200_MONTHLY_SALARY MS
						--Inner JOIN T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID
						--LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--		GROUP BY MAD.Emp_ID , MAD.TO_DATE
						--	) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						--WHERE I.CENTER_ID = @CUR_CENTER_ID AND I.PAYMENT_MODE = 'CHEQUE'
						--AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) --AND ISNULL(MS.IS_FNF,0)  = 0 
						--GROUP BY I.CENTER_ID
				
						UPDATE #AX_MAPPING set AMOUNT = @SUM_AMT,vender_Code = 'Cheque'  
						WHERE AD_ID = @CUR_AD_ID and  CC_ID = @CUR_CENTER_ID AND vender_Code = 'Cheque'
						AND BUSIUNIT =  @CUR_BUS_AREA
				END
				
			Else If @CUR_AD_ID = 0 and @VENDOR_CODE = 'Cash'	--This will give Cash Summary
				BEGIN
			--Taking from Salary--
						--SELECT @SUM_AMT = isnull(Sum(Ms.Net_Amount),0) - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						--from T0200_MONTHLY_SALARY MS
						--Inner JOIN T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID
						--LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--		GROUP BY MAD.Emp_ID , MAD.TO_DATE
						--	) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						--WHERE I.Center_ID = @CUR_CENTER_ID and Payment_Mode = 'Cash'
						--and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						--GROUP BY I.Center_ID
				
				--Taking from Payment Process--
						SELECT @SUM_AMT = isnull(Sum(MEB.Net_Amount),0) -- - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						from MONTHLY_EMP_BANK_PAYMENT MEB WITH (NOLOCK)
						Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MEB.Emp_ID = MS.Emp_ID and MONTH(MEB.For_date) = MONTH(@TO_DATE)  AND YEAR(MEB.For_date) = YEAR(@TO_DATE)
						Inner JOIN T0095_INCREMENT I WITH (NOLOCK) on Ms.Increment_ID = I.Increment_ID
						WHERE I.Center_ID = @CUR_CENTER_ID and MEB.Payment_Mode = 'Cash' 
						and MEB.Process_Type = 'Salary' and MEB.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						GROUP BY I.Center_ID
						
						UPDATE #AX_MAPPING 
						SET AMOUNT = @SUM_AMT,VENDER_CODE = 'Cash' 
						WHERE AD_ID = @CUR_AD_ID and  CC_ID = @CUR_CENTER_ID AND VENDER_CODE = 'Cash'
						AND BUSIUNIT =  @CUR_BUS_AREA
				END
			
			ELSE if @CUR_AD_ID = 2004	--Total of All Earning Allowance with/without effect on Salary
				BEGIN
					UPDATE #AX_MAPPING SET Amount = ISNULL(@TOTAL_EARNING,0)
					WHERE AD_ID = @CUR_AD_ID  and CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
					SET @TOTAL_EARNING = 0
				END
				
			ELSE if @CUR_AD_ID = 2005	--Total of All Deduction including Net Payable
				BEGIN
					UPDATE #AX_MAPPING SET AMOUNT = ISNULL(@TOTAL_DEDUCTION,0)
					WHERE AD_ID = @CUR_AD_ID  and CC_ID = @CUR_CENTER_ID
					AND BUSIUNIT =  @CUR_BUS_AREA
					
					SET @TOTAL_DEDUCTION = 0
				END
				
			FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID, @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA , @Bank_id , @VENDOR_CODE
		end 
	close CUR_AX
	Deallocate CUR_AX
	
	
	/* AS PER NEW REQUIREMENT , CHANGED THE LOGIC AND SELECT QUERY ALSO CHANGED */			
	SELECT	1 AS Srno ,ROW_NUMBER() OVER (ORDER BY DOCDT) AS [Line Item] , COCODE AS [Company Code], DOCDT AS [Doc Date],
			'' AS [Posting Date] , CURRENCY , 'Salary ' + CONVERT(VARCHAR(3), DOCDT, 100) + '''' + CAST(YEAR(DOCDT) AS VARCHAR) AS [Reference],
			'Journal Voucher' as [Doc.Header Text] , ACCODE1 AS [G.L. Code  Account] , 'JV' AS [Doc Type] ,
			 CASE WHEN (AD_FLAG = 'B' OR  AD_FLAG = 'I') 
					THEN AMOUNT ELSE -AMOUNT END AS AMOUNT,
			 CASE WHEN AD_FLAG = 'H'
				THEN TRANSACTION_TEXT
			 ELSE
				 'Salary - ' + CONVERT(VARCHAR(3), DOCDT, 100) + '''' + CAST(YEAR(DOCDT) AS VARCHAR) 
			  END AS [Text]
			 , BUSIUNIT as [Business Area Code] , COSTCENT as [Cost Center]
	FROM #AX_MAPPING  T
	WHERE  COSTCENT IS NOT NULL AND AMOUNT <> 0
	ORDER BY COSTCENT , SORTING_NO
			
/*
		-- Query Comnmented on 25/10/2018-- As per new Requirement , now this is not Required
		
			SELECT	ACCODE1 AS [G.L. Code  Account], '' , '', AMOUNT , '' , '' , '' , '' ,CONVERT(VARCHAR(20) ,DOCDT , 103) as DOC_DATE, 'Salary - ' + CONVERT(VARCHAR(3), DOCDT, 100) + '''' + CAST(YEAR(DOCDT) AS VARCHAR) AS [Text],
			'' , '' , BUSIUNIT as [Business Area Code], '' , COSTCENT as [Cost Center] , Transaction_Text as [Final Account Head]				
			FROM #AX_MAPPING  T
			WHERE  COSTCENT is NOT NULL and AMOUNT <> 0
			ORDER BY COSTCENT
			
*/


RETURN



