

-- =============================================
-- Author:		<Author,,JIMIT>
-- Create date: <Create Date,,02-02-2019>
-- Description:	<Description,,For Getting Salary Cycle Date based on Branch Id>
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[Fn_GetSalaryCycleDate] 
(
	@CMP_ID			NUMERIC, 	
	@BRANCH_ID		VARCHAR(MAX), 	
	@FOR_DATE		DATETIME,
	@FLAG			NUMERIC
)
RETURNS @SalaryCycle Table
(
	FROM_DATE	DATETIME,
	TO_DATE		DATETIME
)
AS
BEGIN
		
		
		DECLARE @BRNACH_ID AS NUMERIC		
		DECLARE @MONTH_ST_DATE AS DATETIME
		DECLARE @MONTH_END_DATE AS DATETIME
		DECLARE @SAL_ST_DATE AS DATETIME
		DECLARE @SAL_END_DATE AS DATETIME		
		DECLARE @MANUAL_SALARY_PERIOD AS NUMERIC(18,0)

		SET @MONTH_ST_DATE = DBO.GET_MONTH_ST_DATE(MONTH(@FOR_DATE),YEAR(@FOR_DATE))
		SET @MONTH_END_DATE = DBO.GET_MONTH_END_DATE(MONTH(@FOR_DATE),YEAR(@FOR_DATE))

		IF @FLAG = 299 AND @BRANCH_ID > '0'
			BEGIN
				
				IF CHARINDEX(',',@BRANCH_ID) > 0
					BEGIN
						 SET @BRANCH_ID = REPLACE(@BRANCH_ID,',','#')
					END

				IF CHARINDEX('#',@BRANCH_ID) > 0
				BEGIN
						--SELECT @BRANCH_ID = LEFT(@BRANCH_ID,(CHARINDEX('#',@BRANCH_ID)-1))
						SELECT top 1 @BRANCH_ID =  [Data]
						from		 dbo.split(@BRANCH_ID,'#')
						WHERE		[Data] > 0
				END

				SELECT  @SAL_ST_DATE = SAL_ST_DATE,
						@MANUAL_SALARY_PERIOD = ISNULL(MANUAL_SALARY_PERIOD ,0)
				FROM    T0040_GENERAL_SETTING WITH (NOLOCK)
				WHERE   CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID AND 
						FOR_DATE = (
									SELECT	MAX(FOR_DATE) 
									FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE	FOR_DATE <= @MONTH_END_DATE AND 
											BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID
								)    
                       					   						
				IF ISNULL(@SAL_ST_DATE,'') = '' OR DAY(@SAL_ST_DATE) = 1   
					BEGIN    
						INSERT INTO @SalaryCycle
						SELECT @MONTH_ST_DATE,@MONTH_END_DATE
					END     					     
				ELSE IF @SAL_ST_DATE <> ''  AND DAY(@SAL_ST_DATE) > 1   
					BEGIN    
                      
						IF @MANUAL_SALARY_PERIOD = 0 
							BEGIN
								SET @SAL_ST_DATE =  CAST(CAST(DAY(@SAL_ST_DATE)AS VARCHAR(5)) + '-' + CAST(DATENAME(MM,DATEADD(M,-1,@MONTH_ST_DATE)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(M,-1,@MONTH_ST_DATE) )AS VARCHAR(10)) AS SMALLDATETIME)    
								SET @SAL_END_DATE = DATEADD(D,-1,DATEADD(M,1,@SAL_ST_DATE)) 
						
                       
								SET @MONTH_ST_DATE = @SAL_ST_DATE
								SET @MONTH_END_DATE = @SAL_END_DATE 
							END 
						ELSE
							BEGIN
								SELECT	@SAL_ST_DATE=FROM_DATE,@SAL_END_DATE=END_DATE
								FROM	SALARY_PERIOD WITH (NOLOCK)
								WHERE	MONTH= MONTH(@MONTH_ST_DATE) AND YEAR=YEAR(@MONTH_ST_DATE)
						                           
								SET @MONTH_ST_DATE = @SAL_ST_DATE
								SET @MONTH_END_DATE = @SAL_END_DATE 
							END                           
						END
              
					INSERT INTO @SalaryCycle
					SELECT @MONTH_ST_DATE,@MONTH_END_DATE
						
				END
			ELSE
				BEGIN
						INSERT INTO @SalaryCycle
						SELECT @MONTH_ST_DATE,@MONTH_END_DATE
				END
	RETURN 
END

