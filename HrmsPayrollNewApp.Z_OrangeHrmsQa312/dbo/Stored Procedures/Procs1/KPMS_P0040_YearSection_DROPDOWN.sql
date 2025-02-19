Create PROCEDURE [dbo].[KPMS_P0040_YearSection_DROPDOWN]  
@rCmpId INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @lYearResult VARCHAR(MAX) = ''    
  
 SELECT @lYearResult = '<option value="0"> -- Select -- </option>'  
 SELECT @lYearResult = @lYearResult + '<option ' + CASE WHEN IsDefault = 1 THEN 'selected="selected"' else '' end + ' value="' + CONVERT(VARCHAR,Batch_Detail_Id) + '">' + CONVERT(VARCHAR,YEAR(From_Date)) + ' - ' + CONVERT(VARCHAR,YEAR(To_Date)) + '</option>'  
 FROM KPMS_T0020_BatchYear_Detail WITH(NOLOCK) WHERE IsActive = 1  AND IsDefault = 1  -- AND Cmp_ID = @rCmpId
  
 SELECT @rCmpId AS CmpId  

,@lYearResult AS YearResult,REPLACE(@lYearResult,'-- Select --','-- Select --') AS YearResultALL  

  
END  
