﻿

-- =============================================
-- AUTHOR:		<GADRIWALA MUSLIM,,NAME>
-- CREATE DATE: <10-AUG-2016,,>
-- DESCRIPTION:	<DESCRIPTION,,YEARLY GRADE WISE ATTRITION>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

CREATE PROCEDURE [dbo].[SP_RPT_GET_YEARLY_ATTRITION_GRADE_WISE_REPORT]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE 	DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID 	NUMERIC
	,@CAT_ID 		NUMERIC = 0 --Changed by Gadriwala Muslim 11082016
	,@GRD_ID 		NUMERIC = 0 --Changed by Gadriwala Muslim 11082016
	,@TYPE_ID 		NUMERIC = 0 --Changed by Gadriwala Muslim 11082016
	,@DEPT_ID 		NUMERIC = 0 --Changed by Gadriwala Muslim 11082016
	,@DESIG_ID 		NUMERIC = 0 --Changed by Gadriwala Muslim 11082016
	,@VERTICAL_ID	NUMERIC = 0 --Added By Ramiz on 07/03/2019
	,@EMP_ID 		NUMERIC = 0 --Changed by Gadriwala Muslim 11082016
	,@CONSTRAINT 	VARCHAR(MAX) = '' --Changed by Gadriwala Muslim 11082016
	,@Graph			tinyint = 0  --Added By Jimit 15112019
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @BRANCH_ID = 0  
		SET @BRANCH_ID = NULL
		
	IF @CAT_ID = 0  
		SET @CAT_ID = NULL

	IF @GRD_ID = 0  
		SET @GRD_ID = NULL

	IF @TYPE_ID = 0  
		SET @TYPE_ID = NULL

	IF @DEPT_ID = 0  
		SET @DEPT_ID = NULL

	IF @DESIG_ID = 0  
		SET @DESIG_ID = NULL

	IF @EMP_ID = 0  
		SET @EMP_ID = NULL
		
		CREATE TABLE #YEARLY_ATTRITION_REPORT
			(
				ROW_ID			NUMERIC IDENTITY (1,1) NOT NULL,
				CMP_ID			NUMERIC ,
				Grade_ID		NUMERIC ,
				MONTH_1_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_1_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_1_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_1_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_2_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_2_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_2_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_2_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_3_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_3_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_3_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_3_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_4_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_4_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_4_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_4_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_5_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_5_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_5_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_5_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_6_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_6_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_6_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_6_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_7_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_7_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_7_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_7_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_8_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_8_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_8_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_8_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_9_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_9_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_9_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_9_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_10_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_10_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_10_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_10_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_11_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_11_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_11_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_11_CL		NUMERIC(12,1) DEFAULT 0,
				MONTH_12_OP		NUMERIC(12,1) DEFAULT 0,
				MONTH_12_DR		NUMERIC(12,1) DEFAULT 0,
				MONTH_12_CR		NUMERIC(12,1) DEFAULT 0,
				MONTH_12_CL		NUMERIC(12,1) DEFAULT 0,
				TOTAL_DR		NUMERIC(12,1) DEFAULT 0,
				TOTAL_CR		NUMERIC(12,1) DEFAULT 0,
				TOTAL_CL		NUMERIC(12,1) DEFAULT 0
			)
			
			DECLARE @GRADE_ID_CUR NUMERIC
			DECLARE @GRADE_NAME AS VARCHAR(50)
			DECLARE @TEMP_DATE DATETIME
			DECLARE @COUNT NUMERIC 


DECLARE GRADE_CURSOR CURSOR FOR
	SELECT GRD_ID,GRD_NAME FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND GRD_ID = ISNULL(@GRD_ID,GRD_ID)
OPEN GRADE_CURSOR
	fetch next from GRADE_CURSOR into @GRADE_ID_CUR,@GRADE_NAME 
	while @@fetch_status = 0
		Begin
				INSERT INTO #YEARLY_ATTRITION_REPORT(CMP_ID,GRADE_ID)
				SELECT @CMP_ID,@GRADE_ID_CUR		
				SET @TEMP_DATE = @FROM_DATE 
				SET @COUNT = 1 
				WHILE @TEMP_DATE <=@TO_DATE 
				BEGIN
					
					IF @COUNT = 1
						BEGIN
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_1_OP = (
												SELECT COUNT(EM.EMP_ID) FROM T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID from T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) as INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.Emp_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = EM.EMP_ID	WHERE CMP_ID=@CMP_ID  AND  DATE_OF_JOIN < @TEMP_DATE
												AND INC_QRY.GRD_ID =@GRADE_ID_CUR AND 
												(
													EMP_LEFT ='N' 
													OR 
													(
														EMP_LEFT='Y' AND EMP_LEFT_DATE >= @TEMP_DATE
													)
												)
											)
							WHERE GRADE_ID =@GRADE_ID_CUR

							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_1_CR = (
													SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.Grd_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR
										
											
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_1_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_1_CL = MONTH_1_OP + MONTH_1_CR - MONTH_1_DR
							WHERE GRADE_ID =@GRADE_ID_CUR
							
						END
					ELSE IF @COUNT = 2 
						BEGIN
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_2_OP = MONTH_1_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_2_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.Grd_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_2_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) 
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_2_CL = MONTH_2_OP + MONTH_2_CR - MONTH_2_DR
							WHERE GRADE_ID =@GRADE_ID_CUR
						END
					ELSE IF @COUNT = 3
						BEGIN
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_3_OP = MONTH_2_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_3_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_3_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_3_CL = MONTH_3_OP + MONTH_3_CR - MONTH_3_DR
							WHERE GRADE_ID =@GRADE_ID_CUR							
						end
					else if @count = 4 
						begin
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_4_OP = MONTH_3_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_4_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_4_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE  WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_4_CL = MONTH_4_OP + MONTH_4_CR - MONTH_4_DR
							WHERE GRADE_ID =@GRADE_ID_CUR							
								
						end
					else if @count = 5 
						begin
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_5_OP = MONTH_4_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_5_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_5_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_5_CL = MONTH_5_OP + MONTH_5_CR - MONTH_5_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
						end
					else if @count = 6
						begin
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_6_OP = MONTH_5_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_6_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_6_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_6_CL = MONTH_6_OP + MONTH_6_CR - MONTH_6_DR
							WHERE GRADE_ID =@GRADE_ID_CUR							
						end
					else if @count = 7 
						begin
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_7_OP = MONTH_6_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_7_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_7_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_7_CL = MONTH_7_OP + MONTH_7_CR - MONTH_7_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
						END
					ELSE IF @COUNT = 8
						BEGIN
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_8_OP = MONTH_7_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_8_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_8_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_8_CL = MONTH_8_OP + MONTH_8_CR - MONTH_8_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
						END
					ELSE IF @COUNT = 9 
						BEGIN
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_9_OP = MONTH_8_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_9_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_9_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE  WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_9_CL = MONTH_9_OP + MONTH_9_CR - MONTH_9_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
						end
					else if @count = 10 
						begin
							
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_10_OP = MONTH_9_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_10_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_10_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE  WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_10_CL = MONTH_10_OP + MONTH_10_CR - MONTH_10_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
						end
					else if @count = 11 
						begin
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_11_OP = MONTH_10_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_11_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_11_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_11_CL = MONTH_11_OP + MONTH_11_CR - MONTH_11_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
						END
					ELSE IF @COUNT = 12
						BEGIN
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_12_OP = MONTH_11_CL
							WHERE GRADE_ID =@GRADE_ID_CUR
														
							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_12_CR = (
												SELECT COUNT(DATE_OF_JOIN) FROM T0080_EMP_MASTER EM WITH (NOLOCK)
												WHERE MONTH(DATE_OF_JOIN) = MONTH(@TEMP_DATE) 
												AND YEAR(DATE_OF_JOIN)=YEAR(@TEMP_DATE) AND CMP_ID = @CMP_ID AND EM.GRD_ID = @GRADE_ID_CUR
											 ) 
							WHERE GRADE_ID = @GRADE_ID_CUR

							UPDATE #YEARLY_ATTRITION_REPORT 
							SET MONTH_12_DR = 
										(
											SELECT COUNT(LEFT_DATE) FROM T0110_EMP_LEFT_JOIN_TRAN ET WITH (NOLOCK)	
											INNER JOIN
												 (
														SELECT IE.EMP_ID,GRD_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN 
														(
																SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
																 (
																	SELECT MAX(IE.INCREMENT_EFFECTIVE_DATE) AS EFFETIVE_DATE,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK)
																	WHERE CMP_ID=@CMP_ID  AND  INCREMENT_EFFECTIVE_DATE <= @TEMP_DATE GROUP BY IE.EMP_ID
																 ) IN_QRY ON IN_QRY.EFFETIVE_DATE = IE.INCREMENT_EFFECTIVE_DATE AND IN_QRY.EMP_ID = IE.EMP_ID
																GROUP BY IE.EMP_ID
														)QRY ON QRY.INCREMENT_ID = IE.INCREMENT_ID
												
												)INC_QRY ON INC_QRY.EMP_ID = ET.EMP_ID
											WHERE MONTH(LEFT_DATE) = MONTH(@TEMP_DATE) AND YEAR(LEFT_DATE)=YEAR(@TEMP_DATE) 
											AND CMP_ID = @CMP_ID AND INC_QRY.GRD_ID = @GRADE_ID_CUR) 
							WHERE GRADE_ID = @GRADE_ID_CUR
							
							UPDATE #YEARLY_ATTRITION_REPORT 
								SET MONTH_12_CL = MONTH_12_OP + MONTH_12_CR - MONTH_12_DR
							WHERE GRADE_ID =@GRADE_ID_CUR								
							
						END	
						
					SET @TEMP_DATE = DATEADD(M,1,@TEMP_DATE)
					SET @COUNT = @COUNT + 1  
				END
		
			UPDATE  #YEARLY_ATTRITION_REPORT 
			SET TOTAL_DR = MONTH_1_DR + MONTH_2_DR + MONTH_3_DR + MONTH_4_DR + MONTH_5_DR +MONTH_6_DR + MONTH_7_DR + MONTH_8_DR + MONTH_9_DR	
						+ MONTH_10_DR + MONTH_11_DR + MONTH_12_DR,
				TOTAL_CR = MONTH_1_CR + MONTH_2_CR + MONTH_3_CR + MONTH_4_CR + MONTH_5_CR +MONTH_6_CR + MONTH_7_CR + MONTH_8_CR + MONTH_9_CR	
						+ MONTH_10_CR + MONTH_11_CR + MONTH_12_CR,
				TOTAL_CL = MONTH_1_CL + MONTH_2_CL + MONTH_3_CL + MONTH_4_CL + MONTH_5_CL +MONTH_6_CL + MONTH_7_CL + MONTH_8_CL + MONTH_9_CL	
						+ MONTH_10_CL + MONTH_11_CL + MONTH_12_CL		 
			WHERE GRADE_ID =@GRADE_ID_CUR			
		
			FETCH NEXT FROM GRADE_CURSOR INTO @GRADE_ID_CUR,@GRADE_NAME 
		END
		
CLOSE GRADE_CURSOR	
DEALLOCATE GRADE_CURSOR
	
	-- ADDED BY GADRIWALA MUSLIM 09082016 - START  ATTRITION GRAPH CHART 
	CREATE TABLE #GRAPH_CHART
	(
		CMP_ID NUMERIC(18,0),
		GRADE_ID NUMERIC(18,0),
		MONTH_NAME VARCHAR(15),
		ATTRITION_VALUE NUMERIC(18,5),
		SORTING_NO NUMERIC(18,0)
	)
	
	
	
	DECLARE @I AS NUMERIC(18,0)
	SET @I=1
	
	WHILE @I<=12
		BEGIN
				IF @I = 1
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'JAN',CASE WHEN SUM(MONTH_1_OP) > 0 THEN (SUM(MONTH_1_DR) * 100)/SUM(MONTH_1_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 2
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'FEB',CASE WHEN SUM(MONTH_2_OP) > 0 THEN (SUM(MONTH_2_DR) * 100)/SUM(MONTH_2_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 3
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'MAR',CASE WHEN SUM(MONTH_3_OP) > 0 THEN (SUM(MONTH_3_DR) * 100)/SUM(MONTH_3_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 4
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'APR',CASE WHEN SUM(MONTH_4_OP) > 0 THEN (SUM(MONTH_4_DR) * 100)/SUM(MONTH_4_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 5
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'MAY',CASE WHEN SUM(MONTH_5_OP) > 0 THEN (SUM(MONTH_5_DR) * 100)/SUM(MONTH_5_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 6
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'JUN',CASE WHEN SUM(MONTH_6_OP) > 0 THEN (SUM(MONTH_6_DR) * 100)/SUM(MONTH_6_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 7
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'JUL',CASE WHEN SUM(MONTH_7_OP) > 0 THEN (SUM(MONTH_7_DR) * 100)/SUM(MONTH_7_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 8
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'AUG',CASE WHEN SUM(MONTH_8_OP) > 0 THEN (SUM(MONTH_8_DR) * 100)/SUM(MONTH_8_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 9
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'SEP',CASE WHEN SUM(MONTH_9_OP) > 0 THEN (SUM(MONTH_9_DR) * 100)/SUM(MONTH_9_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 10
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'OCT',CASE WHEN SUM(MONTH_10_OP) > 0 THEN (SUM(MONTH_10_DR) * 100)/SUM(MONTH_10_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 11
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'NOV',CASE WHEN SUM(MONTH_11_OP) > 0 THEN (SUM(MONTH_11_DR) * 100)/SUM(MONTH_11_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
				ELSE IF @I = 12
					BEGIN
						INSERT INTO #GRAPH_CHART (CMP_ID,GRADE_ID,MONTH_NAME,ATTRITION_VALUE,Sorting_No)
						SELECT  @CMP_ID,0,'DEC',CASE WHEN SUM(MONTH_12_OP) > 0 THEN (SUM(MONTH_12_DR) * 100)/SUM(MONTH_12_OP) ELSE 0 END AS ATTR_VALUE,@I
						FROM #YEARLY_ATTRITION_REPORT							
					END
		
			set @I = @I + 1
		end
	
	INSERT INTO #YEARLY_ATTRITION_REPORT
		(CMP_ID,	GRADE_ID,	MONTH_1_OP,	MONTH_1_DR,	MONTH_1_CR,	MONTH_1_CL,	MONTH_2_OP,	MONTH_2_DR,	MONTH_2_CR,	MONTH_2_CL,	MONTH_3_OP,	MONTH_3_DR,	MONTH_3_CR,	MONTH_3_CL,	MONTH_4_OP,	MONTH_4_DR,	MONTH_4_CR,	MONTH_4_CL,	MONTH_5_OP,	MONTH_5_DR,	MONTH_5_CR,	MONTH_5_CL,	MONTH_6_OP,	MONTH_6_DR,	MONTH_6_CR,	MONTH_6_CL,	MONTH_7_OP,	MONTH_7_DR,	MONTH_7_CR,	MONTH_7_CL,	MONTH_8_OP,	MONTH_8_DR,	MONTH_8_CR,	MONTH_8_CL,	MONTH_9_OP,	MONTH_9_DR,	MONTH_9_CR,	MONTH_9_CL,	MONTH_10_OP,	MONTH_10_DR,	MONTH_10_CR,	MONTH_10_CL,	MONTH_11_OP,	MONTH_11_DR,	MONTH_11_CR,	MONTH_11_CL,	MONTH_12_OP,	MONTH_12_DR,	MONTH_12_CR,	MONTH_12_CL)
	SELECT @CMP_ID,0
,SUM(MONTH_1_OP),	SUM(MONTH_1_DR),	SUM(MONTH_1_CR),	SUM(MONTH_1_CL),	SUM(MONTH_2_OP),	SUM(MONTH_2_DR),	SUM(MONTH_2_CR),	SUM(MONTH_2_CL),	SUM(MONTH_3_OP),	SUM(MONTH_3_DR),	
SUM(MONTH_3_CR),	SUM(MONTH_3_CL),	SUM(MONTH_4_OP),	SUM(MONTH_4_DR),	SUM(MONTH_4_CR),	
SUM(MONTH_4_CL),	SUM(MONTH_5_OP),	SUM(MONTH_5_DR),	SUM(MONTH_5_CR),	SUM(MONTH_5_CL),	
SUM(MONTH_6_OP),	SUM(MONTH_6_DR),	SUM(MONTH_6_CR),	SUM(MONTH_6_CL),	SUM(MONTH_7_OP),	
SUM(MONTH_7_DR),	SUM(MONTH_7_CR),	SUM(MONTH_7_CL),	SUM(MONTH_8_OP),	SUM(MONTH_8_DR),	
SUM(MONTH_8_CR),	SUM(MONTH_8_CL),	SUM(MONTH_9_OP),	SUM(MONTH_9_DR),	SUM(MONTH_9_CR),	
SUM(MONTH_9_CL),	SUM(MONTH_10_OP),	SUM(MONTH_10_DR),	SUM(MONTH_10_CR),	SUM(MONTH_10_CL),	
SUM(MONTH_11_OP),	SUM(MONTH_11_DR),	SUM(MONTH_11_CR),	SUM(MONTH_11_CL),	SUM(MONTH_12_OP),	
SUM(MONTH_12_DR),	SUM(MONTH_12_CR),	SUM(MONTH_12_CL)
 FROM #YEARLY_ATTRITION_REPORT					
		
	
	select  Ys.* ,YS.Grade_ID AS GROUP_ID , gm.Grd_Name AS GROUP_NAME ,GM.Grd_Description
			,Case When YS.GRADE_ID =0 Then 'Summary' Else GM.Grd_Name End Grd_Name
			,Cmp_NAme,Cmp_Address,@From_Date as P_From_Date , @To_Date as P_To_Date , 'Grade' as GROUP_BY
		from #Yearly_Attrition_Report  Ys Left Outer join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON YS.GRADE_ID = GM.GRD_ID INNER JOIN 
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON YS.CMP_ID = CM.CMP_ID
	
	If @Graph =1
		SELECT MONTH_NAME,ATTRITION_VALUE FROM #GRAPH_CHART	ORDER BY SORTING_NO	
	ELSE
		SELECT * FROM #GRAPH_CHART	ORDER BY SORTING_NO	
					
	RETURN 


