
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[TrainingCalender_DisplayESS]
	 @cmp_Id		numeric(18,0)
	,@cal_Year	int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	
	CREATE TABLE #data_tbl
	(
		 Month_Name		VARCHAR(50)
		,MonthNumber	INT
		,Training_name	VARCHAR(200)
		,Training_Id	NUMERIC(18,0)
	)
	
	;WITH months(MonthNumber) AS
	(
		SELECT 1
		UNION ALL
		SELECT MonthNumber+1
		FROM months
		WHERE MonthNumber < 12
	)
	
	INSERT INTO #data_tbl
	SELECT dbo.F_GET_MONTH_NAME(MonthNumber)Month_Name,MonthNumber,isnull(TC1.Training_name,'')Training_name,TC1.Training_Id
	FROM months m left JOIN
	(
		SELECT TC.Calender_Month,TC.Training_Id,TM.Training_name
		FROM  T0052_Hrms_TrainingCalenderYearly TC WITH (NOLOCK) inner JOIN
			  T0040_Hrms_Training_master TM WITH (NOLOCK) ON TM.Training_id = TC.Training_Id
		WHERE TM.Cmp_Id = @cmp_Id and Calender_Year = @cal_Year
	)TC1 ON tc1.Calender_Month = MonthNumber
	
	--DECLARE @columns AS VARCHAR(150)
	
	--SELECT @columns = COALESCE(@columns + ',[' + cast(Month_Name AS VARCHAR) + ']',
	--		'[' + cast(Month_Name AS VARCHAR)+ ']')
	--		 FROM #data_tbl
	--		GROUP BY MonthNumber,Month_Name
	--		ORDER BY MonthNumber ASC
	


	SELECT *
FROM (
    SELECT 
        ROW_NUMBER() OVER(ORDER BY MonthNumber ASC) as SrNo,
        Month_Name, 
        Training_name
    FROM #data_tbl
) as s
PIVOT
(
    max(Training_name)
    FOR [Month_Name] IN ([January],[February],[March],[April],[May],[June],[July],[August],[September],[October],[November],[December])
    )AS pvt
	


DROP TABLE #data_tbl
END