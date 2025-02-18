﻿



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_BONUS_CALC]
 @EMP_ID		AS NUMERIC,
 @CMP_ID		AS NUMERIC,
 @TRAN_ID		AS NUMERIC(18,0) OUTPUT,
 @FOR_DATE		AS DATETIME = NULL,
 @BRANCH_ID		AS NUMERIC(18,0),
 @PARTICULARS	AS VARCHAR(512),
 @LOGIN_ID		AS NUMERIC(18,0),
 @TRAN_TYPE		AS VARCHAR(1),
 @BONUS_CALCULATE_ON AS Numeric(18,2)
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
			
	IF ISNULL(@CMP_ID,0) = 0
		BEGIN 
			RAISERROR('@@ Company ID must be specified @@',16,2) 
			RETURN
		END
		
	IF ISNULL(@BRANCH_ID,0) = 0
		BEGIN 
			RAISERROR('@@ Branch ID must be specified @@',16,2) 
			RETURN
		END
	ELSE IF NOT EXISTS(SELECT 1 FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND Branch_ID = @BRANCH_ID)
		BEGIN 
			RAISERROR('@@ Branch does not exist in selected company @@',16,2) 
			RETURN
		END
	IF (IsNull(@FOR_DATE,'1900-01-01') ='1900-01-01' )  	
		BEGIN
			RAISERROR('@@ For Date must be specified  @@',16,2)  		
			RETURN
		END
	
	
	
 IF UPPER(@TRAN_TYPE) ='I' or UPPER(@TRAN_TYPE) ='U'
			BEGIN			 
				
				If EXISTS(SELECT 1 FROM T0040_BONUS_CALC WITH (NOLOCK) WHERE  BRANCH_ID=@BRANCH_ID AND FOR_DATE=@FOR_DATE AND CMP_ID=@CMP_ID)
				BEGIN
					--RETURN
						SELECT @TRAN_ID = TRAN_ID
						FROM T0040_BONUS_CALC WITH (NOLOCK)
						WHERE BRANCH_ID=@BRANCH_ID AND  FOR_DATE=@FOR_DATE AND CMP_ID=@CMP_ID
						
					     UPDATE dbo.T0040_BONUS_CALC 
					     SET PARTICULARS=@PARTICULARS,LOGIN_ID=@LOGIN_ID,SYSTEMDATE=GETDATE(),BONUS_CALCULATE_ON =  @BONUS_CALCULATE_ON
					     WHERE Tran_ID=@TRAN_ID
						
				END
				IF NOT EXISTS(SELECT 1 FROM dbo.T0040_BONUS_CALC WITH (NOLOCK) WHERE BRANCH_ID=@BRANCH_ID AND FOR_DATE=@FOR_DATE AND CMP_ID=@CMP_ID)
				BEGIN	
						SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0040_BONUS_CALC WITH (NOLOCK)
								
						INSERT INTO T0040_BONUS_CALC
							(TRAN_ID,CMP_ID,FOR_DATE,BRANCH_ID,PARTICULARS,LOGIN_ID,SYSTEMDATE,BONUS_CALCULATE_ON)
						VALUES (@TRAN_ID,@CMP_ID,@FOR_DATE,@BRANCH_ID,@PARTICULARS, @LOGIN_ID,GETDATE(),@BONUS_CALCULATE_ON)	
						
				END
				 
		     DELETE FROM T0045_BONUS_DAYS_SLAB WHERE TRAN_ID = @TRAN_ID			
			  
             END 
	ELSE IF  UPPER(@TRAN_TYPE) ='U' 
			BEGIN
								
				UPDATE    T0040_BONUS_CALC
				SET       FOR_DATE = @FOR_DATE, BRANCH_ID = @BRANCH_ID 
						 ,PARTICULARS = @PARTICULARS
				WHERE     TRAN_ID = @TRAN_ID
				
			END
			
	ELSE IF  UPPER(@TRAN_TYPE) ='D'
			BEGIN			 
			
				DELETE FROM T0045_BONUS_DAYS_SLAB WHERE TRAN_ID = @TRAN_ID		
				DELETE FROM T0040_BONUS_CALC WHERE TRAN_ID = @TRAN_ID			
				
			END
			
	ELSE IF UPPER(@TRAN_TYPE) ='S'
		BEGIN
	
			IF EXISTS(SELECT 1 FROM T0040_BONUS_CALC WITH (NOLOCK)) -- ADDED BY RAJPUT 13042017
			BEGIN
					SELECT BNS.TRAN_ID,CONVERT(VARCHAR(10),BNS.FOR_DATE,103) AS FOR_DATE,BRCH.BRANCH_NAME FROM T0040_BONUS_CALC AS BNS WITH (NOLOCK)
					INNER JOIN T0030_BRANCH_MASTER AS BRCH WITH (NOLOCK) ON BRCH.Branch_ID=BNS.BRANCH_ID WHERE BNS.CMP_ID=@CMP_ID AND BNS.BRANCH_ID=@BRANCH_ID
					 
 			END
	
		END	
	ELSE IF UPPER(@TRAN_TYPE) ='T'
		BEGIN
	
			SELECT 1 FROM dbo.T0040_BONUS_CALC WITH (NOLOCK) WHERE BRANCH_ID=@BRANCH_ID AND FOR_DATE=@FOR_DATE AND CMP_ID=@CMP_ID
	
		END	
		 	
	RETURN

