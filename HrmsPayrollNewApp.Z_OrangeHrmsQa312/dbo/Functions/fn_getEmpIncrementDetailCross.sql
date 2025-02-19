


-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 10-Jan-2018
-- Description:	To retrieve the employee's salary structure based on Revised Allowance (Transfer will not be affected here)
---10/3/2021 (EDIT BY MEHUL ) (Table-valued function WITH NOLOCK)---
-- =============================================
CREATE FUNCTION [dbo].[fn_getEmpIncrementDetailCross] 
(	
	-- Add the parameters for the function here
	@Cmp_ID		Numeric, 
	@Constraint	Varchar(Max),
	@For_Date	DateTime
)
RETURNS @EmpInc TABLE 
(	
	[Increment_ID]	[numeric](18, 0) NOT NULL,
	Emp_ID			[NUMERIC] NOT NULL,
	AD_ID			[NUMERIC] NOT NULL,
	FOR_DATE		[DateTime] NOT NULL,
	E_AD_FLAG		[VARCHAR] (10),
	E_AD_PERCENTAGE	[NUMERIC] (18,4),
	E_AD_AMOUNT		[NUMERIC] (18,4),
	PRIMARY KEY ( Emp_ID,AD_ID )
) 
AS	
	BEGIN
		IF @For_Date IS NULL
			SET @For_Date = GETDATE();

		
		DECLARE @Cons TABLE 
		(
			Increment_ID	NUMERIC,
			Emp_ID			NUMERIC,
			Effective_Date	DateTime
		)

		IF (ISNULL(@Constraint,'') = '')
			SET @Constraint = NULL

		--IF @Constraint IS NOT NULL
			INSERT INTO @Cons(Increment_ID, Emp_ID, Effective_Date)
			SELECT	I.Increment_ID,I.Emp_ID, I.Increment_Effective_Date
			FROM	T0095_INCREMENT I WITH (NOLOCK)	
					INNER JOIN	dbo.Split(@Constraint, '#') T ON Cast(IsNull(Data,I.Emp_ID) As Numeric) = I.Emp_ID
					INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.Emp_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.INCREMENT_EFFECTIVE_DATE <= @For_Date --AND I2.CMP_ID=@Cmp_ID
															AND I2.Increment_Type NOT IN ('Transfer', 'Deputation')
															--AND Cmp_ID=@Cmp_ID
													GROUP BY I2.EMP_ID
													) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
								WHERE	I1.Increment_Effective_Date <= @For_Date --AND I1.CMP_ID=@Cmp_ID
										AND I1.Increment_Type NOT IN ('Transfer', 'Deputation')
										AND Cmp_ID=@Cmp_ID
								GROUP BY I1.Emp_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID
			WHERE	I.Increment_Effective_Date <= @For_Date --AND I.CMP_ID=@Cmp_ID
					--AND I.Cmp_ID=@Cmp_ID 
					
		--ELSE
		--	INSERT INTO @Cons(Increment_ID, Emp_ID, Effective_Date)
		--	SELECT	I.Increment_ID,I.Emp_ID, I.Increment_Effective_Date
		--	FROM	T0095_INCREMENT I 						
		--			INNER JOIN T0080_EMP_MASTER E ON I.Emp_ID=E.Emp_ID
		--			INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.Emp_ID
		--						FROM	T0095_INCREMENT I1
		--								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
		--											FROM	T0095_INCREMENT I2
		--											WHERE	I2.INCREMENT_EFFECTIVE_DATE <= @For_Date AND I2.CMP_ID=@Cmp_ID
		--													AND I2.Increment_Type NOT IN ('Transfer', 'Deputation')
		--													AND Cmp_ID=@Cmp_ID
		--											GROUP BY I2.EMP_ID
		--											) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
		--						WHERE	I1.Increment_Effective_Date <= @For_Date AND I1.CMP_ID=@Cmp_ID
		--								AND I1.Increment_Type NOT IN ('Transfer', 'Deputation')
		--								AND Cmp_ID=@Cmp_ID
		--						GROUP BY I1.Emp_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID
				
		--WHERE	I.Increment_Effective_Date <= @For_Date AND I.CMP_ID=@Cmp_ID
		--		AND I.Cmp_ID=@Cmp_ID
		--		AND (
		--				e.Date_Of_Join < @For_Date AND IsNull(e.Emp_Left_Date, @For_Date) >= @For_Date
		--			)
		
		/*	
			Get the Employee's Allocated Allowance & Deductions in Increment Page
			The Allowance which are deleted from Earn Deduction Revised module will not be considered
		*/
		

		INSERT	INTO @EmpInc
		SELECT	C.Increment_ID, C.Emp_ID, EED.AD_ID,EED.FOR_DATE, EED.E_AD_FLAG, EED.E_AD_PERCENTAGE, EED.E_AD_AMOUNT
		FROM	@Cons C
				INNER JOIN T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON C.Increment_ID=EED.INCREMENT_ID
				LEFT OUTER JOIN T0110_EMP_EARN_DEDUCTION_REVISED EDR WITH (NOLOCK) ON EED.EMP_ID=EDR.EMP_ID AND EED.AD_ID=EDR.AD_ID AND EDR.ENTRY_TYPE = 'D'
				LEFT OUTER JOIN (SELECT	EDR1.EMP_ID, EDR1.AD_ID, Max(EDR1.FOR_DATE) As FOR_DATE
								 FROM	T0110_EMP_EARN_DEDUCTION_REVISED EDR1 WITH (NOLOCK)
										INNER JOIN @Cons C ON EDR1.EMP_ID=C.Emp_ID 
								 WHERE	EDR1.FOR_DATE <= @For_Date AND EDR1.ENTRY_TYPE = 'D'
								 GROUP BY EDR1.EMP_ID, EDR1.AD_ID) EDR1 ON EDR.EMP_ID=EDR1.EMP_ID AND EDR.AD_ID=EDR1.AD_ID
		WHERE	EDR.AD_ID IS NULL	--Deleted Allowance Should not be retrieve along with the Employee's Salary Structure
		
		
		
		UPDATE	EI
		SET		E_AD_AMOUNT = EDR.E_AD_AMOUNT,
				E_AD_PERCENTAGE = EDR.E_AD_PERCENTAGE				
		FROM	@EmpInc EI
				INNER JOIN T0110_EMP_EARN_DEDUCTION_REVISED EDR ON EI.Emp_ID=EDR.Emp_ID AND EI.AD_ID=EDR.AD_ID
				INNER JOIN (SELECT	Emp_ID, AD_ID, Max(For_Date) As For_Date
							FROM	T0110_EMP_EARN_DEDUCTION_REVISED EDR1 WITH (NOLOCK)
							WHERE	EXISTS (SELECT 1 FROM @Cons C1 WHERE C1.Effective_Date <= EDR1.FOR_DATE AND C1.Emp_ID=EDR1.EMP_ID)
									AND EDR1.FOR_DATE <= @For_Date AND EDR1.ENTRY_TYPE = 'U'
							GROUP BY Emp_ID, AD_ID) EDR1 ON EDR.EMP_ID=EDR1.EMP_ID AND EDR.FOR_DATE=EDR1.For_Date AND EDR.AD_ID=EDR1.AD_ID
		WHERE	EXISTS(SELECT 1 FROM @EmpInc EI WHERE EDR.EMP_ID=EI.Emp_ID AND EDR.AD_ID=EI.AD_ID)
				AND EDR.ENTRY_TYPE = 'U'
			
		/*
			Getting Allowance & Deduction allowa
		*/
		INSERT	INTO @EmpInc
		SELECT	C.Increment_ID, C.Emp_ID, EDR.AD_ID,EDR.FOR_DATE, EDR.E_AD_FLAG, EDR.E_AD_PERCENTAGE, EDR.E_AD_AMOUNT
		FROM	@Cons C
				INNER JOIN T0110_EMP_EARN_DEDUCTION_REVISED EDR WITH (NOLOCK) ON C.Emp_ID=EDR.Emp_ID
				INNER JOIN (SELECT	Emp_ID, AD_ID, Max(For_Date) As For_Date
							FROM	T0110_EMP_EARN_DEDUCTION_REVISED EDR1 WITH (NOLOCK)
							WHERE	EXISTS (SELECT 1 FROM @Cons C1 WHERE C1.Effective_Date <= EDR1.FOR_DATE AND C1.Emp_ID=EDR1.EMP_ID)
									AND EDR1.FOR_DATE <= @For_Date AND EDR1.ENTRY_TYPE = 'A'
							GROUP BY Emp_ID, AD_ID) EDR1 ON EDR.EMP_ID=EDR1.EMP_ID AND EDR.FOR_DATE=EDR1.For_Date AND EDR.AD_ID=EDR1.AD_ID
		WHERE	NOT EXISTS(SELECT 1 FROM @EmpInc EI WHERE EDR.EMP_ID=EI.Emp_ID AND EDR.AD_ID=EI.AD_ID)
				AND EDR.ENTRY_TYPE = 'A'
	
		RETURN;	
	END	

	
