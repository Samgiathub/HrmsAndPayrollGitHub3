﻿

-- =============================================
-- AUTHOR:		<AUTHOR,,JIMIT>
-- CREATE DATE: <CREATE DATE,,08082019>
-- DESCRIPTION:	<DESCRIPTION,,FOR GETTING EMPLOYEE BASED ON GIVEN REIMBURSEMNT IN STRUCTURE>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_EMPLOYEE_BASED_ON_REIMBURSEMENT]
	@CMP_ID		NUMERIC(18,0),
	@EMP_ID		NUMERIC(18,0),
	@FOR_DATE	DATETIME,
	@BRANCH_ID  NUMERIC(18,0),
	@GRD_ID		NUMERIC(18,0),
	@DEPT_ID	NUMERIC(18,0),
	@RC_ID		NUMERIC(18,0)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	
	IF @BRANCH_ID = 0  
		SET @BRANCH_ID = NULL		

		IF @GRD_ID = 0  
			SET @GRD_ID = NULL	

		IF @DEPT_ID = 0  
			SET @DEPT_ID = NULL

		IF @EMP_ID = 0  
			SET @EMP_ID = NULL

	CREATE TABLE #EMP_CONS 
	 (      
		EMP_ID		 NUMERIC,     
		BRANCH_ID	 NUMERIC,
		INCREMENT_ID NUMERIC    
	 )    

	  EXEC	DBO.SP_RPT_FILL_EMP_CONS	@CMP_ID=@CMP_ID,@FROM_DATE=@FOR_DATE,@TO_DATE=@FOR_DATE,@BRANCH_ID=@BRANCH_ID,
										@CAT_ID=0,@GRD_ID=@GRD_ID,@TYPE_ID=0,@DEPT_ID=@DEPT_ID,@DESIG_ID=0,@EMP_ID=@EMP_ID,
										@CONSTRAINT= ''
	 
	 			

	 SELECT  EC.EMP_ID
	 FROM	#EMP_CONS EC 
			INNER JOIN (
							SELECT	DISTINCT EED.EMP_ID
							FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
									INNER JOIN	#EMP_CONS EC ON EED.EMP_ID = EC.EMP_ID 
									INNER JOIN	T0095_INCREMENT I1 WITH (NOLOCK) ON EED.EMP_ID = EC.EMP_ID AND EED.INCREMENT_ID = EC.INCREMENT_ID
									INNER JOIN	(
													SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID 
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
															INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID	
															INNER JOIN (
																			SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																			FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																					INNER JOIN #EMP_CONS  EC ON I3.EMP_ID = EC.EMP_ID  
																			WHERE	I3.INCREMENT_EFFECTIVE_DATE <= @FOR_DATE AND I3.CMP_ID = @CMP_ID
																					AND INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION')
																			GROUP BY I3.EMP_ID  
																		) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID																																			
													GROUP BY I2.EMP_ID
												) I ON I1.EMP_ID = I.EMP_ID AND I1.INCREMENT_ID=I.INCREMENT_ID 
							WHERE	EED.AD_ID = @RC_ID AND EED.INCREMENT_ID = EC.INCREMENT_ID 
						)Q ON Q.EMP_ID = EC.EMP_ID
	 
	 		
	  	
END


