

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 03/10/2018
-- Description:	TO GENERATE BOND REGISTER WITH REQUIRED DETAILS
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_EMP_BOND_DETAIL]
	 @CMP_ID			NUMERIC,      
	 @FROM_DATE			DATETIME,      
	 @TO_DATE			DATETIME ,      
	 @BRANCH_ID			VARCHAR(100),      
	 @CAT_ID			VARCHAR(100),      
	 @GRD_ID			VARCHAR(100),      
	 @TYPE_ID			VARCHAR(100),      
	 @DEPT_ID			VARCHAR(100),      
	 @DESIG_ID			VARCHAR(100),      
	 @EMP_ID			NUMERIC  ,      
	 @CONSTRAINT		VARCHAR(MAX) = '',      
	 @Report_Type		NUMERIC = 0	,	--0: INSTALLMENT SUMMARY , 1: BOND DETAILS , 2:AMOUNT SUMMARY
	 @Status			NUMERIC = 0	,	--0: ALL BOND , 1:PENDING BOND , 2:CLOSED BOND
	 @Payment_Status	NUMERIC = 0	,	--0: ALL , 1:PAYMENT PENDING , 2:PAYMENT DONE
	 @Order_By			VARCHAR(30) = 'Code' --Added by Ramiz 13/11/2018
	 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

    CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	);
	CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);

	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0,0,0,0,0,0,0,0,0,0
	

	CREATE TABLE #BOND_APPROVAL
	(
		BOND_APPROVAL_ID			NUMERIC,
		EMP_ID						NUMERIC,
		BOND_RETURN_STATUS			VARCHAR(10),
		BOND_APR_PENDING_AMOUNT		NUMERIC
	)

	IF 	@Report_Type = 0		--0:- INSTALLMENT SUMMARY--
		BEGIN
			
			SELECT	EM.ALPHA_EMP_CODE AS EMP_CODE , EM.EMP_FULL_NAME,BM.BOND_NAME ,T.*
			
			FROM	(
						/* FIRST JOIN IS TAKING RECORDS FROM IMPORT AND SECOND JOIN IS TAKING RECORDS FROM PAYMENT*/
						SELECT	EC.EMP_ID,BA.Bond_ID, CONVERT(VARCHAR(20) , BA.Bond_Apr_Date,103) AS Bond_Payment_Date , BA.Bond_Paid_Amount , 'Paid from Import' As Bond_Pay_Comments
						FROM T0120_BOND_APPROVAL BA WITH (NOLOCK)
							INNER JOIN		#EMP_CONS EC ON BA.Emp_Id = EC.EMP_ID							
						WHERE BA.Cmp_ID = @CMP_ID AND Bond_Paid_Amount > 0				
					
					UNION ALL	
										
						/* SECOND JOIN IS TAKING RECORDS FROM PAYMENT*/
						SELECT	EC.EMP_ID,BA.Bond_Id, CONVERT(VARCHAR(20) , MBP.Bond_Payment_Date,103) AS Bond_Payment_Date , MBP.Bond_Pay_Amount , Bond_Pay_Comments
						FROM T0120_BOND_APPROVAL BA WITH (NOLOCK)
							INNER JOIN		#EMP_CONS EC ON BA.Emp_Id = EC.EMP_ID
							INNER JOIN		T0210_MONTHLY_BOND_PAYMENT MBP	WITH (NOLOCK) ON MBP.Bond_Apr_ID = BA.Bond_Apr_Id							
						WHERE BA.Cmp_ID = @CMP_ID
					) T
					INNER JOIN		T0040_BOND_MASTER BM WITH (NOLOCK) ON BM.Bond_ID = t.Bond_Id							
					INNER JOIN		T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = t.EMP_ID
			ORDER BY CASE WHEN @Order_By='Enroll_No' 
							THEN RIGHT(REPLICATE('0',21) + CAST(Enroll_No AS VARCHAR(20)), 21)  
						  WHEN @Order_By='Monthly' 
							THEN Bond_Payment_Date
						  END ,
					 CASE WHEN IsNumeric(Replace(Replace(EMP_CODE,'="',''),'"','')) = 1
							THEN Right(Replicate('0',21) + Replace(Replace(EMP_CODE,'="',''),'"',''), 20)
						  WHEN IsNumeric(Replace(Replace(EMP_CODE,'="',''),'"','')) = 0
							THEN Left(Replace(Replace(EMP_CODE,'="',''),'"','') + Replicate('',21), 20)
						  ELSE 
								Replace(Replace(EMP_CODE,'="',''),'"','')
						  END 

		END
	ELSE IF @Report_Type = 1	--1:- BOND DETAILS--
		BEGIN				
			--INSERTING ALL RECORDS IN TEMP BOND APPROVAL TABLE
			INSERT INTO #BOND_APPROVAL
			SELECT BA.Bond_Apr_Id ,EC.EMP_ID , CASE WHEN BA.Bond_Return_Status = 'Yes' THEN 'Returned' ELSE 'Pending' END , BOND_APR_PENDING_AMOUNT
			FROM T0120_BOND_APPROVAL BA WITH (NOLOCK)
				INNER JOIN #EMP_CONS EC ON BA.Emp_Id = EC.EMP_ID

			IF @Status = 1	--PENDING BOND	(DELETING CLOSED BOND RECORDS)
				BEGIN
					DELETE FROM #BOND_APPROVAL			
					WHERE BOND_APR_PENDING_AMOUNT = 0
				END
			ELSE IF @Status = 2	--CLOSED BOND	(DELETING PENDING BOND RECORDS)
				BEGIN
					DELETE FROM #BOND_APPROVAL 
					WHERE BOND_APR_PENDING_AMOUNT > 0
					
					IF @Payment_Status = 1	--PAYMENT PENDING( DELETING RECORDS WHOSE PAYMENT IS DONE)
						BEGIN
							DELETE FROM #BOND_APPROVAL 
							WHERE BOND_RETURN_STATUS = 'Returned'
						END
					ELSE IF @Payment_Status = 2 -- PAYMENT DONE (DELETING RECORDS WHOSE PAYMENT IS PENDING )
						BEGIN
							DELETE FROM #BOND_APPROVAL 
							WHERE BOND_RETURN_STATUS = 'Pending'
						END
				END
			
			SELECT	EM.Alpha_Emp_Code AS EMP_CODE , EM.EMP_FULL_NAME,BM.BRANCH_NAME,ETM.TYPE_NAME,DPM.DEPT_NAME,DGM.DESIG_NAME,CONVERT(VARCHAR(20) , EM.DATE_OF_JOIN,103) AS DATE_OF_JOIN ,
					VM.Vertical_Name,SVM.SubVertical_Name , CONVERT(VARCHAR(20) , BA.Bond_Apr_Date , 103) AS BOND_APPROVED_DATE,BA.Bond_Apr_Amount AS BOND_APPROVED_AMOUNT,
					(BA.Bond_Apr_Amount - BA.Bond_Apr_Pending_Amount) AS TOTAL_DEDUCTED_BOND, BA.Bond_Apr_Pending_Amount AS BOND_PENDING_AMOUNT ,
					TBA.BOND_RETURN_STATUS ,CASE WHEN BA.Bond_Return_Mode = 'P' THEN 'Payment Process' ELSE 'Salary' END as Bond_Return_Mode , CONVERT(VARCHAR(20) ,Bond_Return_Date,103) as Bond_Paid_Date , 
					CAST(dbo.F_GET_MONTH_NAME(Bond_Return_Month) AS CHAR(3)) + '-' + CAST(Bond_Return_Year as CHAR(4)) as Bond_Return_Month
			FROM T0120_BOND_APPROVAL BA WITH (NOLOCK)
				INNER JOIN		#EMP_CONS EC ON BA.Emp_Id = EC.EMP_ID
				INNER JOIN		#BOND_APPROVAL TBA	ON TBA.BOND_APPROVAL_ID = BA.Bond_Apr_Id
				INNER JOIN		T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EC.EMP_ID
				INNER JOIN		T0095_INCREMENT INC WITH (NOLOCK) ON INC.Increment_ID = EC.INCREMENT_ID
				INNER JOIN		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC.Branch_ID = BM.Branch_ID
				INNER JOIN		T0040_GRADE_MASTER GM WITH (NOLOCK) ON INC.Grd_ID = GM.Grd_ID
				LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON INC.Type_ID = ETM.Type_ID
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON INC.Desig_Id = DGM.Desig_Id
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON INC.Dept_Id = DPM.Dept_Id
				LEFT OUTER JOIN T0040_Vertical_Segment VM WITH (NOLOCK) on INC.Vertical_ID = Vm.Vertical_ID
				LEFT OUTER JOIN T0050_SubVertical  SVM WITH (NOLOCK) on INC.SubVertical_ID = SVM.SubVertical_ID
			ORDER BY CASE WHEN IsNumeric(Replace(Replace(EMP_CODE,'="',''),'"','')) = 1
							THEN Right(Replicate('0',21) + Replace(Replace(EMP_CODE,'="',''),'"',''), 20)
						  WHEN IsNumeric(Replace(Replace(EMP_CODE,'="',''),'"','')) = 0
							THEN Left(Replace(Replace(EMP_CODE,'="',''),'"','') + Replicate('',21), 20)
						  ELSE 
								Replace(Replace(EMP_CODE,'="',''),'"','')
						  END
		END
	ELSE IF @Report_Type = 2	--MONTHLY SUMMARY
		BEGIN
			CREATE TABLE #TOTAL_SUMMARY
			(
				Sr_No			INT,
				Particular		VARCHAR(72),
				Head_Count		NUMERIC(18,0),
				Debit_Amount	NUMERIC(18,2),
				Credit_Amount	NUMERIC(18,2),
				Payment_Mode	CHAR(1)
			)
			
			CREATE TABLE #MONTHLY_BOND_DEDUCTION
			(
				EMP_ID			NUMERIC,
				BOND_ID			NUMERIC,
				MAX_EFFECT_DATE	DATETIME,
				INSTALLMENT_AMT	NUMERIC						
			)
			
			INSERT INTO #MONTHLY_BOND_DEDUCTION
			SELECT EMP_ID , BOND_ID, MAX(Effective_Date) , INSTALLMENT_AMT
			FROM T0130_BOND_INSTALLMENT_DETAIL WITH (NOLOCK)
			WHERE CMP_ID = @CMP_ID
			GROUP BY EMP_ID ,BOND_ID, INSTALLMENT_AMT
			
			--INSERTING LABELS IN TABLE , SO THAT ALL ENTRIES CAN BE VISIBLE.
			INSERT INTO #TOTAL_SUMMARY
				(Sr_No , Particular , Payment_Mode)
			SELECT 1 , 'Amount to be Provided ( via Salary )' , 'S'
			UNION
			SELECT 2 , 'Amount to be Provided ( via Payment Process )' , 'P'
			UNION
			SELECT 3 , 'Bond Amount to be Deducted ( In Salary )' , NULL
			UNION
			SELECT 4 , 'TOTAL AMOUNT' , NULL

			--UPDATING ALL DEBIT ENTRIES
			UPDATE TS
			SET Head_Count = QRY.Head_Count,
				Debit_Amount = QRY.Bond_Apr_Amount
			FROM #TOTAL_SUMMARY TS
				INNER JOIN
					(
						SELECT COUNT(BA.Emp_ID) AS Head_Count , ISNULL(SUM(ISNULL(Bond_Apr_Amount,0)),0) AS Bond_Apr_Amount, BA.Bond_Return_Mode
						FROM T0120_BOND_APPROVAL BA WITH (NOLOCK)
							INNER JOIN	#EMP_CONS EC ON BA.Emp_Id = EC.EMP_ID
						WHERE BA.Cmp_ID = @Cmp_Id 
								AND Bond_Return_Month = MONTH(@from_Date) and Bond_Return_Year = Year(@from_Date)
								AND BOND_APR_PENDING_AMOUNT = 0 AND Bond_Return_Status <> 'Yes'
						GROUP BY BA.Bond_Return_Mode
					)QRY ON QRY.Bond_Return_Mode = TS.Payment_Mode
			
			--UPDATING ALL CREDIT ENTRIES
			UPDATE TS
			SET Head_Count = QRY.Head_Count,
				Credit_Amount = QRY.Bond_Apr_Amount
			FROM #TOTAL_SUMMARY TS
				INNER JOIN
					(
						SELECT	COUNT(BA.Emp_ID) AS Head_Count ,
								ISNULL(SUM(ISNULL(Bond_Apr_Amount,0)),0) AS Bond_Apr_Amount ,
								3 AS Sr_No	-- NUMBER 3 IS FOR CREDIT ENTRIES
						FROM T0120_BOND_APPROVAL BA WITH (NOLOCK)
							INNER JOIN	#EMP_CONS EC ON BA.Emp_Id = EC.EMP_ID
							INNER JOIN	#MONTHLY_BOND_DEDUCTION MBD	
											ON MBD.BOND_ID = BA.BOND_ID AND MBD.EMP_ID = BA.EMP_ID 
						WHERE BA.Cmp_ID = @Cmp_Id AND BOND_APR_PENDING_AMOUNT > 0 
						AND INSTALLMENT_START_DATE <= @TO_DATE
						GROUP BY BA.Emp_ID
					)QRY ON QRY.Sr_No = TS.Sr_No
			
			--UPDATING TOTAL AMOUNTS
			UPDATE #TOTAL_SUMMARY
			SET Head_Count = QRY.Head_Count,
				Debit_Amount = QRY.Debit_Amount,
				Credit_Amount = QRY.Credit_Amount
			FROM 
				(
					SELECT	SUM(Head_Count) AS Head_Count ,
							SUM(Debit_Amount) AS Debit_Amount ,
							SUM(Credit_Amount) AS Credit_Amount
					FROM #TOTAL_SUMMARY
				) AS QRY
			WHERE Sr_No = 4	-- NUMBER 4 IS FOR TOTAL
			
			SELECT Sr_No , Particular , Head_Count , Debit_Amount , Credit_Amount FROM #TOTAL_SUMMARY
					
		END
		
END

