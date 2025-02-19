


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Get_Increment_RateDetails_KPA 9,1
-- exec Get_Increment_RateDetails_KPA 9
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Increment_RateDetails_KPA]
	@Cmp_id	 numeric(18,0)
	,@type		int = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN


CREATE TABLE #finaltbl
(
	 Val			INT
	,Rate_Value  VARCHAR(20)
	,valuerange	VARCHAR(50)
	,effective_date	DATETIME
)

DECLARE @columns VARCHAR(max)

IF @type = 0
	BEGIN
		IF NOT  EXISTS (SELECT 1 from T0050_KPI_IncrementRange WITH (NOLOCK) where Cmp_Id = @Cmp_id)
			BEGIN
				INSERT INTO #finaltbl
				SELECT 1,cast(cast(MIN(Rate_Value) as INTEGER) as VARCHAR) + ' (Promotion)','',NULL
				FROM T0030_HRMS_RATING_MASTER WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_id
				UNION ALL
				SELECT 1,CASE WHEN Rate_Value = ( SELECT min (Rate_Value)
												FROM  T0030_HRMS_RATING_MASTER WITH (NOLOCK)
												WHERE  Cmp_ID = @Cmp_id) 
						THEN  cast(cast(Rate_Value as INTEGER) as VARCHAR) + ' (Non Promotion)'
						ELSE cast(CAST(Rate_Value as INT) as VARCHAR) end ,'',NULL
				FROM T0030_HRMS_RATING_MASTER  WITH (NOLOCK)
				WHERE Cmp_ID = @Cmp_id
			--ORDER BY Rate_Value ASC
			END
		ELSE
			BEGIN 
				INSERT INTO #finaltbl
				SELECT KPI_IncrementRangeId,RangeName,cast(KPI_IncrementRangeId as VARCHAR(18)) +'#'+ RangeValue,IR.EffectiveDate
				FROM T0050_KPI_IncrementRange WITH (NOLOCK) inner	 JOIN
				(
					SELECT  max(EffectiveDate)EffectiveDate
					FROM  T0050_KPI_IncrementRange WITH (NOLOCK)
					WHERE Cmp_Id = @Cmp_id 
				)IR on T0050_KPI_IncrementRange.EffectiveDate = IR.EffectiveDate
				WHERE Cmp_Id = @Cmp_id 
			END		
	
		SELECT @columns  = COALESCE(@columns + ',[' + Rate_Value + ']','[' + Rate_Value + ']')
		FROM  #finaltbl	
		ORDER BY Rate_Value ASC	
	END
ELSE
	BEGIN
		INSERT INTO #finaltbl
		SELECT KPI_IncrementRangeId,RangeName,cast(KPI_IncrementRangeId AS VARCHAR(18)) +'#'+ RangeValue,EffectiveDate
		FROM T0050_KPI_IncrementRange WITH (NOLOCK)
		WHERE Cmp_Id = @Cmp_id 
		
		
		SELECT @columns  = COALESCE(@columns + ',[' + Rate_Value + ']','[' + Rate_Value + ']')
		FROM  (
					SELECT DISTINCT Rate_Value
					FROM #finaltbl 
					
				)t
		ORDER BY Rate_Value ASC	
	END



--SELECT @columns

--select * from #finaltbl

DECLARE @QUERY VARCHAR(max)
SET @QUERY = ''
SET @QUERY = 'SELECT *
			FROM (
				SELECT 
					valuerange,Rate_Value,effective_date
				FROM #finaltbl 
			) as s
			PIVOT
			(
				MAX(valuerange)
				FOR Rate_Value IN ('+ @columns+')
			)AS pvt'


--print @QUERY
exec(@QUERY)

delete from #finaltbl

END

