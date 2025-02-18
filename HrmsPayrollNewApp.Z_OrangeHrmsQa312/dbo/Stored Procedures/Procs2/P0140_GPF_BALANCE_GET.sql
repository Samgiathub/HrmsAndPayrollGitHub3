﻿

-- =============================================
-- Author:		Nimesh Parmar
-- ALTER date: 31-Jul-2015
-- Description:	To get employee's GPF Balance
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0140_GPF_BALANCE_GET] 
	@Cmp_ID			NUMERIC, 
	@FOR_DATE		DATETIME = NULL,
	@Constraint		Varchar(MAX) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @FOR_DATE IS NULL
		SET @FOR_DATE = GETDATE();
	
	print @FOR_DATE
	
	CREATE TABLE #BAL
	(
		EMP_ID		NUMERIC,
		OPENING		NUMERIC(18,4),
		CREDIT		NUMERIC(18,4),
		DEBIT		NUMERIC(18,4),
		CLOSING		NUMERIC(18,4),
		OP_FOR_DATE	DATETIME
	)
	IF @Constraint = ''
		INSERT INTO #BAL (EMP_ID)
		SELECT	E.EMP_ID
		FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN (SELECT DISTINCT EMP_ID FROM T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK) WHERE T.CMP_ID=@CMP_ID) T ON E.Emp_ID=T.EMP_ID
		WHERE	Cmp_ID=@CMP_ID AND E.Date_Of_Join <= @FOR_DATE AND ISNULL(E.Emp_Left_Date, @FOR_DATE) >= @FOR_DATE
	ELSE
		INSERT INTO #BAL (EMP_ID)
		SELECT	E.EMP_ID
		FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN (SELECT DISTINCT EMP_ID FROM T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK) WHERE T.CMP_ID=@CMP_ID) T ON E.Emp_ID=T.EMP_ID
				INNER JOIN  (SELECT CAST(DATA AS numeric) AS EMP_ID FROM dbo.Split(@Constraint, '#')) D ON E.Emp_ID=D.EMP_ID
		WHERE E.Cmp_ID=@CMP_ID AND E.Date_Of_Join <= @FOR_DATE AND ISNULL(E.Emp_Left_Date, @FOR_DATE) >= @FOR_DATE

	
	--GETTING OPENING TRAN ID
	UPDATE	#BAL	
    SET		OP_FOR_DATE = ISNULL(FOR_DATE,'1900-01-01')
    FROM	#BAL B LEFT OUTER JOIN --INNER JOIN 
				(
					SELECT	ISNULL(MAX(T.FOR_DATE),'1900-01-01') As FOR_DATE,T.EMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK)
					WHERE	T.CMP_ID=@CMP_ID 
							AND T.GPF_POSTING IS NOT NULL AND T.FOR_DATE < @For_Date
					GROUP BY T.EMP_ID
				) T ON B.EMP_ID=T.EMP_ID
	
	
	--FOR OPENING 	
    UPDATE	#BAL	
    SET		OPENING = T.GPF_OPENING
    FROM	#BAL B INNER JOIN 
				(
					SELECT	T.GPF_OPENING,T.EMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK)
					WHERE	T.CMP_ID=@CMP_ID 
							AND T.TRAN_ID = (
												SELECT	TOP 1 T1.TRAN_ID 
												FROM	T0140_EMP_GPF_TRANSACTION T1 WITH (NOLOCK) INNER JOIN #BAL B ON T1.EMP_ID=B.EMP_ID
												WHERE	T1.EMP_ID=T.EMP_ID AND T1.CMP_ID=T.CMP_ID 
														AND T1.FOR_DATE <= @FOR_DATE AND T1.FOR_DATE > B.OP_FOR_DATE
												ORDER	BY T1.FOR_DATE ASC, T1.TRAN_ID ASC
											 )
				) T ON B.EMP_ID=T.EMP_ID
			


	--FOR CLOSING
	UPDATE	#BAL	
    SET		CLOSING = T.GPF_CLOSING
    FROM	#BAL B INNER JOIN 
				(
					SELECT	T.GPF_CLOSING,T.EMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK)
					WHERE	T.CMP_ID=@CMP_ID 
							AND T.TRAN_ID = (
												SELECT	TOP 1 T1.TRAN_ID 
												FROM	T0140_EMP_GPF_TRANSACTION T1 WITH (NOLOCK) INNER JOIN #BAL B ON T1.EMP_ID=B.EMP_ID
												WHERE	T1.EMP_ID=T.EMP_ID AND T1.CMP_ID=T.CMP_ID 
														AND T1.FOR_DATE <= @FOR_DATE AND T1.FOR_DATE > B.OP_FOR_DATE
												ORDER	BY T1.FOR_DATE DESC, T1.TRAN_ID DESC
											 )
				) T ON B.EMP_ID=T.EMP_ID
			
    --FOR CREDIT
    
	UPDATE	#BAL	
    SET		CREDIT = T.GPF_CREDIT
    FROM	#BAL B INNER JOIN 
				(
					SELECT	SUM(T.GPF_CREDIT) AS GPF_CREDIT,T.EMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK) INNER JOIN #BAL B ON T.EMP_ID=B.EMP_ID
					WHERE	T.CMP_ID=@CMP_ID AND T.FOR_DATE <= @FOR_DATE AND T.FOR_DATE > B.OP_FOR_DATE
					GROUP BY T.EMP_ID
				) T ON B.EMP_ID=T.EMP_ID
	 
	 --FOR DEBIT
	UPDATE	#BAL	
    SET		DEBIT = T.GPF_DEBIT
    FROM	#BAL B INNER JOIN 
				(
					SELECT	SUM(T.GPF_DEBIT) AS GPF_DEBIT,T.EMP_ID
					FROM	T0140_EMP_GPF_TRANSACTION T WITH (NOLOCK) INNER JOIN #BAL B ON T.EMP_ID=B.EMP_ID
					WHERE	T.CMP_ID=@CMP_ID AND T.FOR_DATE <= @FOR_DATE AND T.FOR_DATE > B.OP_FOR_DATE
					GROUP BY T.EMP_ID
				) T ON B.EMP_ID=T.EMP_ID
				
	
	SELECT	B.EMP_ID, dbo.F_Lower_Round(Opening, @Cmp_ID) AS Opening
			,dbo.F_Lower_Round(Credit, @Cmp_ID) AS Credit
			,dbo.F_Lower_Round(Debit, @Cmp_ID) AS Debit
			,dbo.F_Lower_Round(Closing, @Cmp_ID) AS Closing
			,G.FOR_DATE AS FROM_DATE, @FOR_DATE AS AS_ON_DATE
	FROM	#BAL B INNER JOIN (
								SELECT	EMP_ID, FOR_DATE 
								FROM	T0140_EMP_GPF_TRANSACTION G WITH (NOLOCK)
								WHERE	G.TRAN_ID = (
														SELECT	TOP 1 TRAN_ID 
														FROM	T0140_EMP_GPF_TRANSACTION G1 WITH (NOLOCK) INNER JOIN #BAL B1 ON G1.EMP_ID=B1.EMP_ID
														WHERE	G1.CMP_ID=G.CMP_ID AND G1.EMP_ID=G.EMP_ID AND G1.FOR_DATE > B1.OP_FOR_DATE
														ORDER	BY G1.FOR_DATE ASC, G1.TRAN_ID ASC
													)
										AND G.CMP_ID=@CMP_ID
							 ) G ON B.EMP_ID=G.EMP_ID
	WHERE	(OPENING+CREDIT+DEBIT+CLOSING) > 0 
	
			
END


