﻿


---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALC_INCENTIVE_DEDUCTION]
AS	
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	
	CREATE TABLE #INCENTIVE_TOTAL_AMOUNT_FOR_DEDUCTION
	(	
		EMP_ID NUMERIC(18,0),
		TRAN_ID NUMERIC(18,0),
		SCHEME_ID  NUMERIC(18,0),
		QUALIFYING_CONDITION_NAME VARCHAR(MAX),
		QUALIFYING_CONDITION_VALUE NUMERIC(18,2),
		QUALIFYING_CONDITION_AMOUNT NUMERIC(18,2)
	)
	CREATE TABLE #INCENTIVE_TABLE_PARAMETER_FOR_DEDUCTION
	(	
		EMP_ID NUMERIC(18,0),
		SCHEME_ID  NUMERIC(18,0),
		PARA_NAME VARCHAR(MAX),
		FROM_SLAB NUMERIC(18,2),
		TO_SLAB NUMERIC(18,2),
		SLAB_VALUE NUMERIC(18,2),
		IMPORT_VALUE NUMERIC(18,2)		
	)
	CREATE TABLE #INCENTIVE_TOTAL_SLAB_FOR_DEDUCTION
	(	
		EMP_ID NUMERIC(18,0),
		TRAN_ID NUMERIC(18,0),
		SCHEME_ID  NUMERIC(18,0),
		DEDUCTION_NAME VARCHAR(MAX),
		DEDUCTION_VALUE NUMERIC(18,2),
		OTHER_DEDUCTION_AMOUNT NUMERIC(18,2),
		SLAB_TYPE TINYINT,
		CALC_TYPE VARCHAR(100),
		CALC_ON VARCHAR(100),
		CONSIDER_PARA VARCHAR(max) -- ADDED ON 13102017
	)
	
	 
		INSERT INTO  #INCENTIVE_TABLE_PARAMETER_FOR_DEDUCTION(EMP_ID,SCHEME_ID,PARA_NAME,FROM_SLAB,TO_SLAB,SLAB_VALUE,IMPORT_VALUE)
		SELECT	DISTINCT IM.EMP_ID,ISP.SCHEME_ID,ISP.PARA_NAME,ISP.FROM_SLAB,ISP.TO_SLAB,ISP.SLAB_VALUE,IMP.PARA_VALUE
		--INTO #INCENTIVE_TABLE_PARAMETER
		FROM	DBO.T0055_INCENTIVE_SCHEME_PARA ISP WITH (NOLOCK)
				INNER JOIN #INCENTIVE_TOTAL_AMOUNT IM ON ISP.SCHEME_ID=IM.Scheme_ID
				INNER JOIN DBO.T0190_EMP_INCENTIVE_IMPORT IMP WITH (NOLOCK)
							ON IMP.Para_Name=ISP.Para_Name AND IMP.PARA_VALUE BETWEEN ISP.FROM_SLAB AND ISP.TO_SLAB AND IMP.EMP_ID=IM.EMP_ID
							AND IMP.Para_Type='PM' AND ISP.PARA_FOR='DEDUCTION' AND IM.IS_ADDITIONAL IS NULL
		--WHERE	IM.SCHEME_ID=@SCHEME_ID
		ORDER BY IM.EMP_ID,ISP.PARA_NAME
		
		
		
		INSERT INTO #INCENTIVE_TOTAL_SLAB_FOR_DEDUCTION(EMP_ID,SCHEME_ID,TRAN_ID,DEDUCTION_NAME,DEDUCTION_VALUE,SLAB_TYPE,CALC_TYPE,CALC_ON,CONSIDER_PARA)
		SELECT	 T.EMP_ID, INC.SCHEME_ID, INC.INC_TRAN_ID,INC.INCENTIVE_NAME, SUM(T.SLAB_VALUE),SLAB_TYPE,CALC_TYPE,CALC_ON,INC.CONSIDER_PARA
		FROM	#INCENTIVE_TABLE_PARAMETER_FOR_DEDUCTION T
			INNER JOIN 
			(
				SELECT DISTINCT SCHEME_ID,INC_TRAN_ID,INCENTIVE_NAME,CONSIDER_PARA,SLAB_TYPE,CALC_TYPE,CALC_ON FROM DBO.T0055_INCENTIVE_SCHEME_INC WITH (NOLOCK)
			) INC	ON T.SCHEME_ID=INC.SCHEME_ID AND INC.SLAB_TYPE=0 AND INC.CALC_TYPE='PERCENT' AND ISNULL(INC.CONSIDER_PARA,'--ALL--') <> '--ALL--'
					AND T.PARA_NAME=INC.CONSIDER_PARA -- ADDED ON 06022018 FOR MULTIPLE DEDUCTION PARAMETER TIME PROBLEM OCCUR
		GROUP BY T.EMP_ID, INC.SCHEME_ID, INC.INC_TRAN_ID,INC.INCENTIVE_NAME,INC.SLAB_TYPE,INC.CALC_TYPE,INC.CALC_ON,INC.CONSIDER_PARA
		
		
		
		INSERT INTO #INCENTIVE_TOTAL_AMOUNT_FOR_DEDUCTION(EMP_ID,TRAN_ID,SCHEME_ID,QUALIFYING_CONDITION_NAME,QUALIFYING_CONDITION_VALUE,QUALIFYING_CONDITION_AMOUNT)
		SELECT	INC_TSLAB.EMP_ID,INC_TSLAB.TRAN_ID,INC_TSLAB.SCHEME_ID,INC_TSLAB.DEDUCTION_NAME,
				INC_TSLAB.DEDUCTION_VALUE,INC.SLAB_VALUE
		FROM	#INCENTIVE_TOTAL_SLAB_FOR_DEDUCTION INC_TSLAB
				INNER JOIN  T0055_INCENTIVE_SCHEME_INC INC WITH (NOLOCK) ON  INC_TSLAB.DEDUCTION_VALUE BETWEEN INC.FROM_SLAB AND INC.TO_SLAB 
							AND INC.Scheme_ID=INC_TSLAB.SCHEME_ID AND  INC_TSLAB.SLAB_TYPE=0 
							AND INC_TSLAB.CALC_TYPE='PERCENT' AND INC.CONSIDER_PARA=INC_TSLAB.CONSIDER_PARA 
							AND  ISNULL(INC_TSLAB.CONSIDER_PARA,'--All--') <> '--All--' AND INC.Incentive_For='DEDUCTION' 
		
		UPDATE	T	
		SET		T.DEDUCTION_AMOUNT = DED.DEDUCTION
		FROM	#INCENTIVE_TOTAL_AMOUNT T 				
				INNER JOIN (
							SELECT	DED.EMP_ID, SUM((DED.QUALIFYING_CONDITION_AMOUNT * INC.INCENTIVE_AMOUNT / 100 )) AS DEDUCTION 
							FROM	#INCENTIVE_TOTAL_AMOUNT_FOR_DEDUCTION DED 
									INNER JOIN #INCENTIVE_TOTAL_AMOUNT INC ON  INC.SCHEME_ID=DED.SCHEME_ID AND DED.EMP_ID=INC.EMP_ID
							WHERE	IS_ADDITIONAL IS NULL
							GROUP  BY DED.EMP_ID
							) DED ON T.EMP_ID=DED.EMP_ID
				AND T.IS_ADDITIONAL IS NULL
								
								
			
END

	

