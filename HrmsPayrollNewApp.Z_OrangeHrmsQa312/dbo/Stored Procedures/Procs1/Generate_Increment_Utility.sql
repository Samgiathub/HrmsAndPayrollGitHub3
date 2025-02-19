


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Generate_Increment_Utility]
		@cmp_Id			numeric(18,0)
		,@effective_date datetime
		,@Segment_Id		numeric(18,0)
		,@type			int = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	CREATE TABLE #Increment_utility
	(
		Grd_Id				NUMERIC(18,0)
		,Grd_Name			VARCHAR(100)
		,Achievement_Id		NUMERIC(18,0)
		,AchivementName		VARCHAR(1000)
		,Increment_Amount	NUMERIC(18,2)
	)
	
    DECLARE @grd_id		numeric(18,0)
    DECLARE @BaseFig	numeric(18,2)
    DECLARE @Grd_Name   VARCHAR(100)
    
    DECLARE cur CURSOR
    FOR
		SELECT T0052_Increment_Utility_BaseAmount.Grd_Id,G.Grd_Name,Amount
		FROM T0052_Increment_Utility_BaseAmount WITH (NOLOCK) INNER JOIN
		     T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = T0052_Increment_Utility_BaseAmount.Grd_ID
		WHERE segment_Id = @Segment_Id and EffectiveDate = @effective_date
	OPEN cur	
		FETCH NEXT FROM cur INTO @grd_id,@Grd_Name,@BaseFig
		WHILE @@fetch_status = 0
			BEGIN 
				IF @type = 0
					BEGIN 
						INSERT INTO #Increment_utility(Grd_Id,Grd_Name,Achievement_Id,AchivementName,Increment_Amount)
						SELECT @grd_id,@Grd_Name,AU.Achivement_Id,cast(AU.Achivement_Id as varchar)+'!'+cast(a.Achievement_Sort as VARCHAR)+'$'+A.Achievement_Level+'# ('+ cast(AU.Percentage as VARCHAR) +'% of BaseFig)',
						CASE when AU.Percentage = 0 then @BaseFig  else (@BaseFig * (AU.Percentage/100))+@BaseFig end IncrementAmt
							FROM T0050_Appraisal_Utility_Setting AU WITH (NOLOCK) INNER JOIN
							  (
								SELECT MAX(EffectiveDate) EffectiveDate,Segment_ID
								FROM T0050_Appraisal_Utility_Setting WITH (NOLOCK)
								WHERE Segment_ID = @Segment_Id and EffectiveDate <= @effective_date
								GROUP BY Segment_ID
							  )AU1 ON AU1.Segment_ID = AU.Segment_ID AND AU1.EffectiveDate = AU.EffectiveDate INNER JOIN
							  T0040_Achievement_Master A WITH (NOLOCK) on A.AchievementId = AU.Achivement_Id
						ORDER by A.Achievement_Sort						
					END
				ELSE IF @type =1
					BEGIN 
						INSERT INTO #Increment_utility(Grd_Id,Grd_Name,Achievement_Id,AchivementName,Increment_Amount)
						SELECT Iu.Grd_Id,@Grd_Name,IU.Achivement_Id,cast(IU.Achivement_Id as varchar)+'!'+cast(a.Achievement_Sort as VARCHAR)+'$'+A.Achievement_Level+'# ('+ cast(IU.Percentage as VARCHAR) +'% of BaseFig)',
								IU.Amount as IncrementAmt
						FROM  T0052_Increment_Utility IU WITH (NOLOCK) INNER JOIN
							  T0040_Achievement_Master A WITH (NOLOCK) on A.AchievementId = IU.Achivement_Id						
						WHERE Segment_ID = @Segment_Id and EffectiveDate = @effective_date
							  and IU.Grd_Id = @grd_id
						ORDER by A.Achievement_Sort
					END
				FETCH NEXT FROM cur INTO @grd_id,@Grd_Name,@BaseFig
			END
	CLOSE cur
	DEALLOCATE cur
	
	--SELECT * from #Increment_utility
	
	DECLARE @columns VARCHAR(8000)
	DECLARE @query VARCHAR(MAX)
	
	SELECT @columns = COALESCE(@columns + ',[' + CAST(AchivementName AS VARCHAR(1000)) + ']',
				'[' + CAST(AchivementName AS VARCHAR(1000))+ ']')
				FROM #Increment_utility
				GROUP BY AchivementName,Achievement_Id
				----ORDER BY Training_TypeId ASC
	
	--SELECT @columns
	
	
	SET @query = 'SELECT grd_id,grd_name,'+ @columns +'
				FROM (
					SELECT 
					grd_id ,grd_name,AchivementName,Increment_Amount
					FROM #Increment_utility					
					) as s
				PIVOT
				(
				 
					max(Increment_Amount)
					FOR [AchivementName] IN (' + @columns + ') 
				
				)AS T order by grd_id' 
	
	
	EXEC(@query)
	--SELECT * FROM #Increment_utility
	DROP TABLE #Increment_utility
END


