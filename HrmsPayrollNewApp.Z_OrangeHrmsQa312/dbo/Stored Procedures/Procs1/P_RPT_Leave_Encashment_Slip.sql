--ADDED JIMIT 16062016------
---LEAVE ENCASHMENT SLIP ---
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_Leave_Encashment_Slip]      
	 @CMP_ID		NUMERIC
	,@FROM_DATE		DATETIME
	,@TO_DATE		DATETIME
	,@BRANCH_ID		VARCHAR(MAX) = ''
	,@CAT_ID		VARCHAR(MAX) = ''
	,@GRD_ID		VARCHAR(MAX) = ''
	,@TYPE_ID		VARCHAR(MAX) = ''
	,@DEPT_ID		VARCHAR(MAX) = ''
	,@DESIG_ID		VARCHAR(MAX) = ''
	,@EMP_ID		NUMERIC  = 0
	,@CONSTRAINT	VARCHAR(MAX)
	,@Report_for    Varchar(10) = ''
    
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
	EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	
	
	DECLARE @PRE_YEAR_FROM_DATE	AS DATETIME
	DECLARE @PRE_YEAR_TO_DATE	AS DATETIME
	
	--SET @PRE_YEAR_FROM_DATE = DATEADD(YEAR,-1,@FROM_DATE)
	--SET @PRE_YEAR_TO_DATE = DATEADD(YEAR,-1,@TO_DATE)
	
	IF @BRANCH_ID = 0 
	SET @BRANCH_ID = NULL
	
	SET @PRE_YEAR_FROM_DATE = dbo.GET_YEAR_START_DATE(YEAR(@FROM_DATE),MONTH(@FROM_DATE),0)
	SET @PRE_YEAR_TO_DATE = dbo.GET_YEAR_END_DATE(YEAR(@FROM_DATE),MONTH(@FROM_DATE),0)
		
	Declare @Lv_Encash_Cal_On varchar(50)   
	 Declare @Lv_Encash_W_Day Numeric
	 SET @Lv_Encash_Cal_On = ''   
	 Set @Lv_Encash_W_Day = 0
	
	select @Lv_Encash_Cal_On = Lv_Encash_Cal_On,@Lv_Encash_W_Day = Lv_Encash_W_Day 
	FROM	T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID AND Branch_ID = ISNULL(@Branch_ID,Branch_ID)
			AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING  WITH (NOLOCK)
	WHERE For_Date <=@To_Date AND Branch_ID = ISNULL(@Branch_ID,Branch_ID) AND Cmp_ID = @Cmp_ID) 
				   
			IF OBJECT_ID('tempdb..#Emp_Branch') IS NOT NULL
			 DROP TABLE #Emp_Branch

			CREATE TABLE #Emp_Branch 
			(
				Branch_Id		NUMERIC,
				Calculate_On	Varchar(10)
			)

			IF OBJECT_ID('tempdb..#Emp_Allow') IS NOT NULL
			 DROP TABLE #Emp_Allow

			CREATE TABLE #Emp_Allow 
			(
				Emp_id		NUMERIC,
				AD_Id		NUMERIC,
				Ad_Amount	NUMERIC(18,2),
				Leave_Id	NUMERIC
			)
		
	
		If @Report_for = 'Excel'
		 BEGIN
								--If @Lv_Encash_Cal_On = 'Gross'
				--	Begin
						

				--		SELECT	'="' + E.ALPHA_EMP_CODE + '"' AS [EMP CODE],E.EMP_FULL_NAME AS [EMPLOYEE NAME],																						
				--				SUM(ISNULL(LA.LEAVE_ENCASH_AMOUNT,0)) AS [ENCASH AMT],
				--				SUM(ISNULL(LA.LV_ENCASH_APR_DAYS,0)) AS [ENCASH DAYS],INC_QRY.Gross_Salary  AS [CALCULATE ON]  ,
				--				Convert(varchar(11),Upto_Date,103)	as [ENCASH UPTO DATE],LEAVE_NAME AS [LEAVE NAME]
				--		FROM 	#EMP_CONS EC  INNER JOIN
				--				T0080_EMP_MASTER E ON EC.EMP_ID = E.EMP_ID INNER JOIN
				--				(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.DEPT_ID,I.Gross_Salary,Leave_Id
				--				 FROM T0095_INCREMENT I INNER JOIN 
				--					(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , I.EMP_ID ,Leave_Id
				--					 FROM T0095_INCREMENT I INNER JOIN
				--						   t0120_LEAVE_Encash_APPROVAL LEA ON I.emp_ID=LEA.Emp_id  
				--					 WHERE INCREMENT_EFFECTIVE_DATE <= LEA.Upto_Date AND I.CMP_ID = @CMP_ID
				--					 GROUP BY I.EMP_ID ,Leave_Id ) QRY ON
				--				I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
				--				E.EMP_ID = INC_QRY.EMP_ID INNER JOIN				
				--				T0010_COMPANY_MASTER C ON C.CMP_ID = E.CMP_ID INNER JOIN
				--				T0030_BRANCH_MASTER BM ON BM.BRANCH_ID = INC_QRY.BRANCH_ID INNER JOIN
				--				T0120_LEAVE_ENCASH_APPROVAL LA ON LA.EMP_ID = EC.EMP_ID AND LA.CMP_ID = E.CMP_ID ANd INC_QRY.Leave_Id = La.Leave_Id LEFT JOIN						
				--				T0040_DEPARTMENT_MASTER DM ON DM.DEPT_ID = INC_QRY.DEPT_ID LEFT OUTER JOIN
				--				(	
				--					SELECT SUM(ISNULL(MS.SAL_CAL_DAYS,0)) AS WRKR_DAYS,EC1.EMP_ID	
				--					FROM	T0200_MONTHLY_SALARY MS  INNER JOIN
				--							#EMP_CONS EC1 ON EC1.EMP_ID = MS.EMP_ID
				--					WHERE MS.MONTH_ST_DATE >= @PRE_YEAR_FROM_DATE AND MONTH_END_DATE <= @PRE_YEAR_TO_DATE AND MS.CMP_ID = @CMP_ID
				--					GROUP BY EC1.EMP_ID
				--				)QRY1 ON QRY1.EMP_ID = EC.EMP_ID Inner Join
				--				T0040_LEAVE_MASTER LM On Lm.Leave_Id = La.Leave_ID
				--	WHERE		(LA.LV_ENCASH_APR_DATE>=@FROM_DATE AND LA.LV_ENCASH_APR_DATE<=@TO_DATE)
				--				AND C.CMP_ID = @CMP_ID ANd Lv_Encash_Apr_Status = 'A'
				--	GROUP BY   	E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,C.CMP_NAME,INC_QRY.Gross_Salary,LEAVE_NAME
				
			
				--	end
				--else
					 --begin
		
								
								
							IF EXISTS(
										Select	1 
										from	t0120_LEAVE_Encash_APPROVAL WITH (NOLOCK)
										where	LV_ENCASH_APR_DATE >= @FROM_DATE AND LV_ENCASH_APR_DATE <= @TO_DATE 												 
										GROUP By Lv_Encash_Apr_Date,EMP_ID
										Having  count(Emp_ID) > 1
									)
								BEGIN
										


										INSERT INTO #Emp_Allow
										select	LEA.EMP_ID,Q.AD_ID,Q.E_AD_AMOUNT,LEA.Leave_ID
										from	t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) INNER JOIN
												#Emp_Cons EC ON EC.Emp_Id = LEA.Emp_ID 										
												Cross Apply 
												(
												 select	F.*
												 from	dbo.fn_getEmpIncrementDetail(@Cmp_Id,@Constraint,LEA.UpTo_date) f
														Inner JOin	T0050_AD_MASTER A WITH (NOLOCK) on F.AD_ID = A.AD_ID AND Isnull(A.AD_EFFECT_ON_LEAVE,0)=1 
												WHERE   F.EMP_ID = LEA.EMP_ID
												)Q 							
										
								END
							ELSE
							  BEGIN



										INSERT INTO #Emp_Allow
										Select EED.EMP_ID,eed.AD_ID,
												Case When Qry1.Increment_ID >= EED.INCREMENT_ID  Then
													Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
												Else eed.e_ad_Amount End,LEA.Leave_Id
										
										FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
												#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
												T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID LEFT OUTER JOIN
												( Select	EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID,LEAVE_Id  
												  From		T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
															#Emp_Cons EC ON EC.Emp_Id = EEDR.Emp_ID AND EC.Increment_Id = EEDR.INCREMENT_ID INNER JOIN	
															 (	
																Select	Max(For_Date) For_Date, Ad_Id,EE.EMP_ID,LEAVE_Id 
																From	T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
																		t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
																Where	For_date <= LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
																Group by Ad_Id ,EE.EMP_ID,LEAVE_Id
															) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
												) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID  INNER JOIN
												t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EED.emp_ID=LEA.Emp_id 		
										WHERE	EED.CMP_ID = @Cmp_ID AND Isnull(A.AD_EFFECT_ON_LEAVE,0)=1 										
			
										UNION 

										SELECT	EED.EMP_ID,eed.AD_ID,E_AD_Amount,LEA.Leave_Id 
										FROM	dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
												#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
												(
													 Select Max(For_Date) For_Date, Ad_Id,Leave_ID 
													 From	T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
															t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
													Where For_date <=  LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
													Group by Ad_Id,LEAVE_Id
												) Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id   INNER JOIN 
												dbo.T0050_AD_MASTER ADM  WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   INNER JOIN
												t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EED.emp_ID=LEA.Emp_id                  
										WHERE	Adm.AD_ACTIVE = 1 And EEd.ENTRY_TYPE = 'A' AND Isnull(ADM.AD_EFFECT_ON_LEAVE,0)=1 						

							  END
										
										
								
								
								INSERT INTO #Emp_Branch
								SELECT  BM.Branch_Id,Lv_Encash_Cal_On
								FROM    #EMP_CONS EC INNER JOIN
										T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = EC.BRANCH_ID INNER JOIN
										T0040_GENERAL_SETTING GS WITH (NOLOCK) ON GS.Branch_ID= EC.BRANCH_ID INNER JOIN
										(
											SELECT	MAX(For_Date) FOR_DATE,GS.BRANCH_ID,EC.EMP_ID
											FROM	T0040_GENERAL_SETTING GS WITH (NOLOCK) INNER JOIN
													#EMP_CONS EC ON EC.BRANCH_ID = GS.Branch_ID INNER JOIN
													T0095_INCREMENT INC_QRY WITH (NOLOCK) ON EC.EMP_ID = INC_QRY.EMP_ID 
											WHERE	For_Date <= @TO_DATE AND GS.Branch_ID = ISNULL(@Branch_ID,GS.Branch_ID)
											GROUP BY GS.BRANCH_ID,EC.EMP_ID
										)Q1 ON Q1.Branch_Id = Gs.Branch_ID and Q1.FOR_DATE = Gs.For_Date
								WHERE	Bm.cmp_ID = @cmp_ID AND Gs.Branch_ID = ISNULL(@Branch_ID,Gs.Branch_ID)
								group by BM.Branch_Id,Lv_Encash_Cal_On




																							
								SELECT		'="' + E.ALPHA_EMP_CODE + '"' AS [EMP CODE],E.EMP_FULL_NAME AS [EMPLOYEE NAME],											
											(ISNULL(LA.LEAVE_ENCASH_AMOUNT,0)) AS [ENCASH AMT],
											(ISNULL(LA.LV_ENCASH_APR_DAYS,0)) AS [ENCASH DAYS],	
											(
												CASE WHEN (EB.Calculate_On) = 'Gross' then INC_QRY.Gross_Salary
												ELSE (INC_QRY.Basic_Salary + ISNULL(SUBI_Q.E_AD_AMOUNT,0)) 
												END
										     ) AS [CALCULATE ON],
											 Convert(varchar(11),Upto_Date,103) as [ENCASH UPTO DATE],
											 LEAVE_NAME AS [LEAVE NAME]
											
								FROM 		#EMP_CONS EC  INNER JOIN
											T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID = E.EMP_ID INNER JOIN
											(
												SELECT	I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.DEPT_ID,I.Basic_Salary,I.Gross_Salary,Leave_Id
												FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
														(
															SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID,I.EMP_ID,Leave_ID 
															FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
																	t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON I.emp_ID=LEA.Emp_id  
															WHERE	INCREMENT_EFFECTIVE_DATE <= LEA.Upto_Date AND I.CMP_ID = @CMP_ID
															GROUP BY I.EMP_ID,Leave_ID
														) QRY ON
												I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
											 )INC_QRY ON E.EMP_ID = INC_QRY.EMP_ID INNER JOIN				
											T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.CMP_ID = E.CMP_ID INNER JOIN
											T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID INNER JOIN
											T0120_LEAVE_ENCASH_APPROVAL LA WITH (NOLOCK) ON LA.EMP_ID = EC.EMP_ID AND LA.CMP_ID = E.CMP_ID ANd INC_QRY.Leave_Id = La.Leave_Id LEFT OUTER JOIN													
											(	
												SELECT		ISNULL(SUM(AD_AMOUNT),0) AS E_AD_AMOUNT,EMP_ID,Leave_Id 
												FROM		#Emp_Allow 
												group by	emp_ID,Leave_Id
											) SUBI_Q  ON E.Emp_ID = SUBI_Q.Emp_ID and La.Leave_Id = SUBI_Q.Leave_Id Inner Join
											T0040_LEAVE_MASTER LM WITH (NOLOCK) On Lm.Leave_Id = La.Leave_ID	Inner Join
											#Emp_Branch EB ON EB.Branch_Id = BM.Branch_ID
								WHERE		(LA.LV_ENCASH_APR_DATE>=@FROM_DATE AND LA.LV_ENCASH_APR_DATE<=@TO_DATE)
											AND C.CMP_ID = @CMP_ID	ANd Lv_Encash_Apr_Status = 'A'	
											order by E.ALPHA_EMP_CODE --Added by ronakk 17022022
								--GROUP BY   	E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,INC_QRY.Basic_Salary,SUBI_Q.E_AD_AMOUNT,
								--			Upto_Date,LEAVE_NAMe,INc_QRY.Gross_Salary,Lv_Encash_Cal_On

								

						end	
		 --END
		ELSE 
			BEGIN
			--	If @Lv_Encash_Cal_On = 'Gross'
			--		Begin
			--			SELECT		E.EMP_ID,E.CMP_ID,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,(CASE WHEN BM.BRANCH_ADDRESS = '' THEN C.CMP_ADDRESS ELSE BM.BRANCH_ADDRESS END) AS CMP_ADDRESS				
			--			,E.SSN_NO AS PF_NO,QRY1.WRKR_DAYS,QRY.WRKR_RATE
			--			,SUM(ISNULL(LA.LV_ENCASH_APR_DAYS,0)) AS LEAVE_DAYS,SUM(ISNULL(LA.LEAVE_ENCASH_AMOUNT,0)) AS ENCASH_AMT
			--			,(CASE WHEN BM.BRANCH_ADDRESS = '' THEN C.CMP_NAME ELSE BM.BRANCH_NAME END) AS CMP_NAME
			--			,DEPT_NAME
			--			,@PRE_YEAR_FROM_DATE as from_Date,@PRE_YEAR_TO_DATE as To_Date
			--			,INC_QRY.Gross_Salary  AS Basic_Salary   --added by jimit 24032017
			--			,Convert(varchar(11),Upto_Date,103)	as Leave_Encashment_UpTo_date					--added by jimit 10042019
			--			FROM 		#EMP_CONS EC  INNER JOIN
			--			T0080_EMP_MASTER E ON EC.EMP_ID = E.EMP_ID INNER JOIN
			--					(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.DEPT_ID,I.Gross_Salary,Leave_Id
			--					 FROM T0095_INCREMENT I INNER JOIN 
			--						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , I.EMP_ID ,Leave_Id
			--						 FROM T0095_INCREMENT I INNER JOIN
			--							   t0120_LEAVE_Encash_APPROVAL LEA ON I.emp_ID=LEA.Emp_id  
			--						 WHERE INCREMENT_EFFECTIVE_DATE <= LEA.Upto_Date AND I.CMP_ID = @CMP_ID
			--						 GROUP BY I.EMP_ID ,Leave_Id ) QRY ON
			--					I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
			--					E.EMP_ID = INC_QRY.EMP_ID INNER JOIN				
			--					T0010_COMPANY_MASTER C ON C.CMP_ID = E.CMP_ID INNER JOIN
			--					T0030_BRANCH_MASTER BM ON BM.BRANCH_ID = INC_QRY.BRANCH_ID INNER JOIN
			--					T0120_LEAVE_ENCASH_APPROVAL LA ON LA.EMP_ID = EC.EMP_ID AND LA.CMP_ID = E.CMP_ID ANd INC_QRY.Leave_Id = La.Leave_Id LEFT JOIN						
			--			T0040_DEPARTMENT_MASTER DM ON DM.DEPT_ID = INC_QRY.DEPT_ID LEFT OUTER JOIN
			--			(SELECT SUM(ISNULL(MS.SAL_CAL_DAYS,0)) AS WRKR_DAYS,EC1.EMP_ID	
			--			 FROM T0200_MONTHLY_SALARY MS  INNER JOIN
			--				#EMP_CONS EC1 ON EC1.EMP_ID = MS.EMP_ID
			--				WHERE MS.MONTH_ST_DATE >= @PRE_YEAR_FROM_DATE AND MONTH_END_DATE <= @PRE_YEAR_TO_DATE AND MS.CMP_ID = @CMP_ID
			--				GROUP BY EC1.EMP_ID)QRY1 ON QRY1.EMP_ID = EC.EMP_ID	Left Outer JOIN
			--			(SELECT MS.EMP_ID,MS.Day_Salary as WRKR_RATE
			--					 FROM T0200_MONTHLY_SALARY MS INNER JOIN 
			--						(SELECT MAX(Sal_tran_Id) AS Sal_tran_Id , EMP_ID
			--						 FROM T0200_MONTHLY_SALARY  
			--						 WHERE Month_End_Date <= @To_date AND CMP_ID = @CMP_ID
			--						 GROUP BY EMP_ID  ) QRY ON
			--					MS.EMP_ID = QRY.EMP_ID	AND MS.Sal_Tran_ID = QRY.Sal_tran_Id INNER JOIN
			--				#EMP_CONS EC1 ON EC1.EMP_ID = MS.EMP_ID						
			--			GROUP By MS.EMP_ID,MS.Day_Salary,MS.Month_St_Date)QRY ON QRY.EMP_ID = EC.EMP_ID
			--WHERE		(LA.LV_ENCASH_APR_DATE>=@FROM_DATE AND LA.LV_ENCASH_APR_DATE<=@TO_DATE)
			--			AND C.CMP_ID = @CMP_ID	
			--GROUP BY   	E.EMP_ID,E.CMP_ID,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,BM.BRANCH_ADDRESS ,C.CMP_ADDRESS , BM.BRANCH_ADDRESS			
			--			,E.SSN_NO,DEPT_NAME,C.CMP_NAME,BM.BRANCH_NAME,WRKR_DAYS,QRY.WRKR_RATE,INC_QRY.Gross_Salary
				
			
			--		end
			--	else
					 begin
		
		
								IF EXISTS(
										Select	1 
										from	t0120_LEAVE_Encash_APPROVAL  WITH (NOLOCK)
										where	LV_ENCASH_APR_DATE >= @FROM_DATE AND LV_ENCASH_APR_DATE <= @TO_DATE 												 
										GROUP By Lv_Encash_Apr_Date,EMP_ID
										Having  count(Emp_ID) > 1
									)
								BEGIN
										PRINT 123
										INSERT INTO #Emp_Allow
										select	LEA.EMP_ID,Q.AD_ID,Q.E_AD_AMOUNT,LEA.Leave_ID
										from	t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) INNER JOIN
												#Emp_Cons EC ON EC.Emp_Id = LEA.Emp_ID 										
												Cross Apply 
												(
												 select	F.*
												 from	dbo.fn_getEmpIncrementDetail(@Cmp_Id,@Constraint,LEA.UpTo_date) f
														Inner JOin	T0050_AD_MASTER A WITH (NOLOCK) on F.AD_ID = A.AD_ID 
														AND Isnull(A.AD_EFFECT_ON_LEAVE,0)=1 
														--AND A.AD_EFFECT_ON_LEAVE=1 -- Sajid
												WHERE   F.EMP_ID = LEA.EMP_ID
												)Q 							
								END
							ELSE

								BEGIN

									INSERT INTO #EMP_ALLOW
								Select EED.EMP_ID,eed.AD_ID,
									Case When Qry1.Increment_ID >= EED.INCREMENT_ID  Then
										Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
									Else eed.e_ad_Amount End,Leave_Id
								FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join 
									#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
									T0050_AD_MASTER A WITH (NOLOCK) on EED.AD_ID = A.AD_ID And EED.CMP_ID=A.CMP_ID									
									LEFT OUTER JOIN
									( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.ENTRY_TYPE,EEDR.Increment_ID,Leave_ID
										From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
										#Emp_Cons EC ON EC.Emp_Id = EEDR.Emp_ID AND EC.Increment_Id = EEDR.INCREMENT_ID INNER JOIN	
										 ( Select Max(For_Date) For_Date, Ad_Id,EE.EMP_ID,Leave_ID From T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
											t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
											Where For_date <= LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
											Group by Ad_Id ,EE.EMP_ID,Leave_ID
										 ) Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
									) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID 
				
								WHERE EED.CMP_ID = @Cmp_ID AND Isnull(A.AD_EFFECT_ON_LEAVE,0)=1
			
								UNION 

								SELECT EED.EMP_ID,eed.AD_ID,E_AD_Amount,Leave_ID
								FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
									#Emp_Cons EC ON EC.Emp_Id = EED.Emp_ID AND EC.Increment_Id = EEd.INCREMENT_ID INNER JOIN
									( Select Max(For_Date) For_Date, Ad_Id,Leave_ID From T0110_EMP_Earn_Deduction_Revised EE WITH (NOLOCK) INNER JOIN
										t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON EE.emp_ID=LEA.Emp_id 
										Where For_date <=  LEA.Upto_Date and EE.EMP_ID IN ( Select Emp_id From #Emp_Cons ) 
										Group by Ad_Id,Leave_ID
									) Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
								   INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                     
								WHERE Adm.AD_ACTIVE = 1 And EEd.ENTRY_TYPE = 'A' AND Isnull(ADM.AD_EFFECT_ON_LEAVE,0)=1
								END

			-------------------------ended----------------------------------------
	

			

		

					

								INSERT INTO #Emp_Branch
								SELECT  BM.Branch_Id,Lv_Encash_Cal_On
								FROM    #EMP_CONS EC 
								INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = EC.BRANCH_ID 
								INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON GS.Branch_ID= EC.BRANCH_ID 
								INNER JOIN(
											SELECT	MAX(For_Date) FOR_DATE,GS.BRANCH_ID,EC.EMP_ID
											FROM	T0040_GENERAL_SETTING GS WITH (NOLOCK) INNER JOIN
													#EMP_CONS EC ON EC.BRANCH_ID = GS.Branch_ID INNER JOIN
													T0095_INCREMENT INC_QRY WITH (NOLOCK) ON EC.EMP_ID = INC_QRY.EMP_ID 
											WHERE	For_Date <= @TO_DATE AND GS.Branch_ID = ISNULL(@Branch_ID,GS.Branch_ID)
											GROUP BY GS.BRANCH_ID,EC.EMP_ID
										)Q1 ON Q1.Branch_Id = Gs.Branch_ID and Q1.FOR_DATE = Gs.For_Date

								WHERE	Bm.cmp_ID = @cmp_ID AND Gs.Branch_ID = ISNULL(@Branch_ID,Gs.Branch_ID)
								group by  BM.Branch_Id,Lv_Encash_Cal_On --added by ronakk 08022022																


					
							SELECT		E.EMP_ID,E.CMP_ID,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,(CASE WHEN BM.BRANCH_ADDRESS = '' THEN
										C.CMP_ADDRESS ELSE BM.BRANCH_ADDRESS END) AS CMP_ADDRESS				
										,E.SSN_NO AS PF_NO,QRY1.WRKR_DAYS
										--,QRY.WRKR_RATE										
										,(ISNULL(LA.Day_Salary,0)) AS WRKR_RATE -- Added By Sajid 09-02-2022
										,(ISNULL(LA.LV_ENCASH_APR_DAYS,0)) AS LEAVE_DAYS,(ISNULL(LA.LEAVE_ENCASH_AMOUNT,0)) AS ENCASH_AMT
										,(CASE WHEN BM.BRANCH_ADDRESS = '' THEN C.CMP_NAME ELSE BM.BRANCH_NAME END) AS CMP_NAME
										,DEPT_NAME
										,@PRE_YEAR_FROM_DATE as from_Date,@PRE_YEAR_TO_DATE as To_Date
										,(CASE WHEN (EB.Calculate_On) = 'Gross' then  INC_QRY.Gross_Salary
												ELSE (INC_QRY.Basic_Salary + ISNULL(SUBI_Q.E_AD_AMOUNT,0)) END) AS Basic_Salary   --added by jimit 24032017
										,Convert(varchar(11),Upto_Date,103)	as Leave_Encashment_UpTo_date						--added by jimit 10042019
								FROM 	#EMP_CONS EC  INNER JOIN
										T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID = E.EMP_ID INNER JOIN
													(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.DEPT_ID,I.Basic_Salary,I.Gross_Salary,Leave_Id
													 FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
														(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , I.EMP_ID ,Leave_Id
														 FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
															   t0120_LEAVE_Encash_APPROVAL LEA WITH (NOLOCK) ON I.emp_ID=LEA.Emp_id  
														 WHERE INCREMENT_EFFECTIVE_DATE <= LEA.Upto_Date AND I.CMP_ID = @CMP_ID
														 GROUP BY I.EMP_ID ,Leave_Id ) QRY ON
											I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
											E.EMP_ID = INC_QRY.EMP_ID INNER JOIN				
											T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.CMP_ID = E.CMP_ID INNER JOIN
											T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID INNER JOIN
											T0120_LEAVE_ENCASH_APPROVAL LA WITH (NOLOCK) ON LA.EMP_ID = EC.EMP_ID AND LA.CMP_ID = E.CMP_ID ANd INC_QRY.Leave_Id = La.Leave_Id LEFT JOIN						
											T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.DEPT_ID = INC_QRY.DEPT_ID LEFT OUTER JOIN
											(SELECT SUM(ISNULL(MS.SAL_CAL_DAYS,0)) AS WRKR_DAYS,EC1.EMP_ID	
											 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)  INNER JOIN
												#EMP_CONS EC1 ON EC1.EMP_ID = MS.EMP_ID
												WHERE MS.MONTH_ST_DATE >= @PRE_YEAR_FROM_DATE AND MONTH_END_DATE <= @PRE_YEAR_TO_DATE AND MS.CMP_ID = @CMP_ID
												GROUP BY EC1.EMP_ID)QRY1 ON QRY1.EMP_ID = EC.EMP_ID	Left Outer JOIN
											(SELECT MS.EMP_ID,MS.Day_Salary as WRKR_RATE
													 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN 
														(SELECT MAX(Sal_tran_Id) AS Sal_tran_Id , EMP_ID
														 FROM T0200_MONTHLY_SALARY  WITH (NOLOCK)
														 WHERE Month_End_Date <= @To_date AND CMP_ID = @CMP_ID
														 GROUP BY EMP_ID  ) QRY ON
													MS.EMP_ID = QRY.EMP_ID	AND MS.Sal_Tran_ID = QRY.Sal_tran_Id INNER JOIN
												#EMP_CONS EC1 ON EC1.EMP_ID = MS.EMP_ID						
											GROUP By MS.EMP_ID,MS.Day_Salary,MS.Month_St_Date)QRY ON QRY.EMP_ID = EC.EMP_ID	left outer join
											( SELECT ISNULL(SUM(AD_AMOUNT),0) AS E_AD_AMOUNT,EMP_ID,Leave_Id FROM #EMP_ALLOW group by emp_ID,LEAVE_Id	
											) SUBI_Q  ON E.Emp_ID = SUBI_Q.Emp_ID and La.Leave_Id = SUBI_Q.Leave_Id
											Inner Join #Emp_Branch EB ON EB.Branch_Id = BM.Branch_ID									
								WHERE		(LA.LV_ENCASH_APR_DATE>=@FROM_DATE AND LA.LV_ENCASH_APR_DATE<=@TO_DATE)
											AND C.CMP_ID = @CMP_ID	


								--GROUP BY   	E.EMP_ID,E.CMP_ID,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,BM.BRANCH_ADDRESS ,C.CMP_ADDRESS , BM.BRANCH_ADDRESS			
								--			,E.SSN_NO,DEPT_NAME,C.CMP_NAME,BM.BRANCH_NAME,WRKR_DAYS,QRY.WRKR_RATE,INC_QRY.Basic_Salary,SUBI_Q.E_AD_AMOUNT,
								--			Upto_Date,INc_QRY.Gross_Salary
						
						end	
			END	
		
	
	

