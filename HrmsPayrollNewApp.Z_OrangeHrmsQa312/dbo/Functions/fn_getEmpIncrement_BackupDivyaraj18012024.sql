
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[fn_getEmpIncrement_BackupDivyaraj18012024] 
(	
	@Cmp_ID NUMERIC,
	@Emp_ID NUMERIC , 
	@For_Date DateTime
)

RETURNS @EmpInc TABLE 
(	
	[Increment_ID] [numeric](18, 0) NOT NULL PRIMARY KEY,
	Emp_ID NUMERIC NOT NULL	,
	Branch_Id numeric not null  --Added by Jaina 20-06-2017	
) 
AS
	BEGIN
		IF (YEAR(ISNULL(@For_Date,'1900-01-01')) < 1901)
			SET @For_Date = GETDATE();
		
		--I have placed two seperate queries to fetch employee detail instead of placing where condition with ISNULL function to improve performance.	
		IF (ISNULL(@Emp_ID,0) = 0)
			BEGIN
				INSERT INTO @EmpInc	
				SELECT	I.Increment_ID,I.Emp_ID,I.Branch_ID
				FROM	T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.Emp_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK)
											INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK)
														WHERE	I2.INCREMENT_EFFECTIVE_DATE <= @For_Date AND I2.CMP_ID=@Cmp_ID
														GROUP BY I2.EMP_ID
														) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
									WHERE	I1.Increment_Effective_Date <= @For_Date AND I1.CMP_ID=@Cmp_ID
									GROUP BY I1.Emp_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID
				WHERE	I.Increment_Effective_Date <= @For_Date AND I.CMP_ID=@Cmp_ID
				
			END
		ELSE
			BEGIN
				INSERT INTO @EmpInc	
				SELECT	I.Increment_ID,I.Emp_ID,I.Branch_ID
				FROM	T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.Emp_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK)
											INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK)
														WHERE	I2.INCREMENT_EFFECTIVE_DATE <= @For_Date AND I2.Emp_ID=@Emp_ID AND I2.CMP_ID=@Cmp_ID
														GROUP BY I2.EMP_ID
														) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
									WHERE	I1.Increment_Effective_Date <= @For_Date AND I1.Emp_ID=@Emp_ID AND I1.CMP_ID=@Cmp_ID
									GROUP BY I1.Emp_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID
				WHERE	I.Increment_Effective_Date <= @For_Date AND I.Emp_ID=@Emp_ID AND I.CMP_ID=@Cmp_ID
			END
		
		RETURN;
	END