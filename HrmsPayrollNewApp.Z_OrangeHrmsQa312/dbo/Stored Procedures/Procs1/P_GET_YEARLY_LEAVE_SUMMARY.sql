﻿

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 16-Mar-2017
-- Description:	To get the yearly leave summary
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_YEARLY_LEAVE_SUMMARY] 
	@Emp_ID NUMERIC 
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	DECLARE @FROM_DATE DATETIME
	SET @FROM_DATE = CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01' AS DATETIME)


    CREATE TABLE #MONTHS(ID INT, [MONTH] VARCHAR(3), [YEAR] INT)

	INSERT INTO #MONTHS
	SELECT	ROW_ID, LEFT(DATENAME(MM, FOR_DATE),3), YEAR(FOR_DATE)
	FROM	(
				SELECT	ROW_ID, DATEADD(M, ROW_ID - 1, @FROM_DATE) AS FOR_DATE
				FROM	(SELECT Top 12  ROW_NUMBER() OVER(ORDER BY OBJECT_ID) ROW_ID FROM sys.objects) T 
				--WHERE	ROW_ID <= DATEDIFF(MM, @FROM_DATE, GETDATE()) + 1 
			) T

				
	SELECT	Emp_ID As EmpID,Leave_Code As LeaveCode, CAST(SUM(LEAVE_USED) AS NUMERIC(6,2)) AS LeaveUsed, M.Year , M.Month, M.MONTH + '-' + RIGHT(CAST(M.YEAR AS VARCHAR(4)),2) AS MonthName
	INTO	#LEAVE_SUMMARY
	FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
			INNER JOIN (SELECT	TOP 3 L.Leave_ID,Leave_Code 
						FROM	T0040_LEAVE_MASTER L WITH (NOLOCK)
								INNER JOIN (SELECT DISTINCT LEAVE_ID 
											FROM T0140_LEAVE_TRANSACTION T1 WITH (NOLOCK)
											WHERE T1.FOR_DATE >= @FROM_DATE AND LEAVE_USED > 0 AND Emp_ID=@Emp_ID) T1 ON L.Leave_ID=T1.Leave_ID
						ORDER BY L.Leave_Def_ID) L ON T.Leave_ID=L.Leave_ID
			INNER JOIN #MONTHS M ON YEAR(T.FOR_DATE) = M.YEAR AND LEFT(DATENAME(MM,T.FOR_DATE),3) = M.MONTH
	WHERE	Leave_Used > 0 AND Emp_ID=@Emp_ID
	GROUP BY EMP_ID, LEAVE_CODE, M.YEAR, M.MONTH


	INSERT	INTO #LEAVE_SUMMARY(EmpID, LeaveCode,LeaveUsed,M.YEAR,M.MONTH,MonthName)
	SELECT	EmpID,LeaveCode,0,M.YEAR,M.MONTH,M.MONTH + '-' + RIGHT(CAST(M.YEAR AS VARCHAR(4)),2)
	FROM	(SELECT DISTINCT EmpID,LeaveCode FROM #LEAVE_SUMMARY) L CROSS JOIN #MONTHS M
	WHERE	NOT EXISTS(SELECT 1 FROM #LEAVE_SUMMARY L1 WHERE L.EmpID=L1.EmpID AND L1.LeaveCode=L.LeaveCode AND M.MONTH=L1.MONTH AND M.YEAR=L1.YEAR)
	
	
	SELECT * FROM #LEAVE_SUMMARY 
	ORDER BY EmpID,LeaveCode,CAST('01-' + MonthName AS DATETIME)
END

