


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Get_BalanceScoreCard_Setting_Details 9,2579,2016
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_BalanceScoreCard_Setting_Details] 
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
	) 
	
	INSERT INTO #tmpBalanceScoreCard_Setting_Details 
	SELECT BSC_Setting_Detail_Id,KPI_Id,BSC_Objective,BSC_Measure,BSC_Target,BSC_Formula,BSC_Weight FROM 
	T0095_BalanceScoreCard_Setting_Details BSCD WITH (NOLOCK) INNER JOIN
	T0090_BalanceScoreCard_Setting BSC WITH (NOLOCK) on bsc.BSC_SettingId = BSCD.BSC_SettingId
	WHERE BSCD.Cmp_Id=@cmp_id AND BSC.Emp_Id=@emp_id AND finyear=@finyear
	
	DECLARE @ratetext as varchar(5)
	DECLARE @columnname as varchar(1000)
	DECLARE @SQLCol as varchar(max)
	DECLARE @BSC_Setting_Detail_Id as numeric(18,0)
	declare @cnt as INT
	set @cnt = 0
DECLARE cur CURSOR
FOR 
	SELECT cast(cast(Rate_Value as INT) as varchar(5)) FROM T0030_HRMS_RATING_MASTER WITH (NOLOCK) WHERE Cmp_ID=@cmp_id ORDER BY Rate_Value
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

SELECT * FROM #tmpBalanceScoreCard_Setting_Details 
DROP TABLE #tmpBalanceScoreCard_Setting_Details

END


