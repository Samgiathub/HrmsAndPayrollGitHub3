


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 20-Oct-2015
-- Description:	Redefine shift to each employee by assigned shift rotation.
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_REDEFINE_SHIFT_BY_ROTATION] 
	@Cmp_ID NUMERIC, 
	@Effective_Date DateTime
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	SET @Effective_Date = cast(Cast(year(@Effective_Date) as varchar) + '-01-01' as datetime)
	
	CREATE TABLE #Emp_Cons
	(
		Emp_ID	NUMERIC		
	)
	
	INSERT	INTO #Emp_Cons
	SELECT	DISTINCT E.Emp_ID 
	FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN T0050_EMP_MONTHLY_SHIFT_ROTATION MSR WITH (NOLOCK) ON E.Emp_ID=MSR.Emp_ID
	WHERE	Year(MSR.Effective_Date) <= Year(@Effective_Date) AND E.Cmp_ID=@Cmp_ID
	
	DELETE	T 
	FROM	#Emp_Cons T LEFT OUTER JOIN T0055_EMP_DEFINED_SHIFT ED ON ED.Emp_ID=T.Emp_ID 
				AND YEAR(Last_Execution) = YEAR(@Effective_Date) AND ED.Cmp_ID=@Cmp_ID 
	WHERE	ED.Emp_ID IS NOT NULL AND ED.Cmp_ID=@Cmp_ID
	
	IF EXISTS(SELECT EMP_ID	FROM #Emp_Cons)
	BEGIN
	
		DECLARE @CONSTRAINT VARCHAR(MAX);
		
		SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EMP_ID AS VARCHAR(10)) FROM #Emp_Cons T
	
		EXEC dbo.P0050_ASSIGN_SHIFT_BY_ROTATION @Cmp_ID, @Effective_Date, @CONSTRAINT
		
		--INSERT INTO T0055_EMP_DEFINED_SHIFT (Cmp_ID, Emp_ID, Last_Execution)
		--SELECT	@Cmp_ID, Emp_ID, @Effective_Date FROM #Emp_Cons T
	END

END

