


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Get_BalanceScoreCard_Evaluation_Details 9,2681,2016
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_BalanceScoreCard_Evaluation_Details]
	@cmp_id  numeric(18,0)
   ,@emp_id  numeric(18,0)
   ,@finyear int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	CREATE TABLE #tmpBalanceScoreCard_Setting_Details
	(
		 BSC_Setting_Detail_Id	numeric(18,0)
		,KPI_Id					numeric(18,0)
		,BSC_Objective			nvarchar(max)
		,BSC_Measure			nvarchar(200)
		,BSC_Target				nvarchar(100)
		,BSC_Formula			nvarchar(100)
		,BSC_Weight				numeric(18,2)
		,Emp_BSC_Review_Detail_Id	numeric(18,0)
		,Actual					NVARCHAR(100)
		,Score				VARCHAR(50)
		,WeightedScore			numeric(18,2)
	) 

	INSERT INTO #tmpBalanceScoreCard_Setting_Details (BSC_Setting_Detail_Id,KPI_Id,BSC_Objective,BSC_Measure,BSC_Target,BSC_Formula,BSC_Weight)
	SELECT BSC_Setting_Detail_Id,KPI_Id,BSC_Objective,BSC_Measure,BSC_Target,BSC_Formula,BSC_Weight FROM 
	T0095_BalanceScoreCard_Setting_Details BSCD WITH (NOLOCK) INNER JOIN
	T0090_BalanceScoreCard_Setting BSC WITH (NOLOCK) on bsc.BSC_SettingId = BSCD.BSC_SettingId
	WHERE BSCD.Cmp_Id=@cmp_id AND BSC.Emp_Id=@emp_id AND finyear=@finyear and BSC.BSC_Status=4
	
	DECLARE @ratetext as varchar(5)
	DECLARE @columnname as varchar(1000)
	DECLARE @SQLCol as varchar(max)
	DECLARE @BSC_Setting_Detail_Id as numeric(18,0)
	declare @cnt as INT
	set @cnt = 0
	
	DECLARE cur CURSOR
	FOR 
		SELECT cast(cast(Rate_Value as INT) as VARCHAR(5)) FROM T0030_HRMS_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID=@cmp_id ORDER BY Rate_Value
	OPEN cur
	FETCH NEXT FROM cur INTO @ratetext
	WHILE @@fetch_status =0
		BEGIN
			--set @cnt = @cnt  +1
			SET @columnname =''
			SET @SQLCol =''
			
			SET @columnname = 'Key_' + @ratetext--cast(@ratetext as VARCHAR)--cast(@cnt as varchar)
			IF Not EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @columnname AND TABLE_NAME LIKE '#tmpBalanceScoreCard_Setting_Details%')		
			BEGIN			
				set @SQLCol ='ALTER TABLE  #tmpBalanceScoreCard_Setting_Details ADD [' + @columnname + '] NVARCHAR(100)'
				exec (@SQLCol)	
			END		
			
			DECLARE curkpi CURSOR
			FOR
				select BSC_Setting_Detail_Id from #tmpBalanceScoreCard_Setting_Details
			OPEN curkpi
				FETCH NEXT FROM curkpi INTO @BSC_Setting_Detail_Id
				WHILE @@fetch_status =0
					BEGIN		
						--select  @columnname as keyname,@BSC_Setting_Detail_Id as bscdetail
						set @SQLCol = ''
						set @SQLCol ='			 
						UPDATE  #tmpBalanceScoreCard_Setting_Details
						SET '+ @columnname + '= s.Key_Value
						FROM (  SELECT Key_Value 
								FROM T0100_BSC_ScoringKey where BSC_Setting_Detail_Id =' + cast(@BSC_Setting_Detail_Id as varchar) + 'and Key_Name = '+ @ratetext +'
								)s
						WHERE BSC_Setting_Detail_Id = ' + cast(@BSC_Setting_Detail_Id as varchar)
						
						--print @SQLCol
						exec (@SQLCol)
						
						FETCH NEXT FROM curkpi INTO @BSC_Setting_Detail_Id
					END
			CLOSE curkpi
			DEALLOCATE curkpi	
								
			FETCH NEXT FROM cur INTO @ratetext
		end
	close cur
	DEALLOCATE cur
	
	
	--IF EXISTS(select 1 from T0100_BalanceScoreCard_Evaluation_Details inner join T0095_BalanceScoreCard_Evaluation on T0095_BalanceScoreCard_Evaluation.Emp_BSC_Review_Id = T0100_BalanceScoreCard_Evaluation_Details.Emp_BSC_Review_Id where T0095_BalanceScoreCard_Evaluation.emp_id=@emp_id and finyear = @finyear)
	--	BEGIN
			DECLARE curkpi CURSOR
			FOR
				select BSC_Setting_Detail_Id from #tmpBalanceScoreCard_Setting_Details
			OPEN curkpi
				FETCH NEXT FROM curkpi INTO @BSC_Setting_Detail_Id
				WHILE @@fetch_status =0
					BEGIN	
						UPDATE #tmpBalanceScoreCard_Setting_Details
						SET Emp_BSC_Review_Detail_Id = k.Emp_BSC_Review_Detail_Id
						    ,Actual = isnull(k.Actual,'')
						    ,Score = isnull(k.Score,'')
						    ,WeightedScore = isnull(k.WeightedScore,'0')
						FROM (SELECT Emp_BSC_Review_Detail_Id,Actual,score,WeightedScore
							FROM T0100_BalanceScoreCard_Evaluation_Details WITH (NOLOCK)
							WHERE BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id)k
						WHERE BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
					
						FETCH NEXT FROM curkpi INTO @BSC_Setting_Detail_Id
					END	
				CLOSE curkpi
			DEALLOCATE curkpi			
		--END
		
		
	SELECT * FROM #tmpBalanceScoreCard_Setting_Details 
	DROP TABLE #tmpBalanceScoreCard_Setting_Details

END




