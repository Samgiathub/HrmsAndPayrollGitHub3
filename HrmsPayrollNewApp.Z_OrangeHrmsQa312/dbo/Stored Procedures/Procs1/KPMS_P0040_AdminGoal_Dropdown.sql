-- EXEC P0040_ROLE_MASTER_DROPDOWN  
-- DROP PROCEDURE P0040_ROLE_MASTER_DROPDOWN  
CREATE PROCEDURE [dbo].[KPMS_P0040_AdminGoal_Dropdown]  
@rCmpId INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET ARITHABORT ON;  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
 DECLARE @ddlFrequncy VARCHAR(MAX) = ''  


 SELECT @ddlFrequncy = '<option value="0"> -- Select -- </option>'  
 SELECT @ddlFrequncy = @ddlFrequncy + '<option value="' + CONVERT(VARCHAR,Frequency_ID) + '">' + Frequency + '</option>'  
 FROM KPMS_T0040_Frequency_Master WITH(NOLOCK) WHERE Cmp_ID = @rCmpId  and IsActive = 1


 SELECT @rCmpId AS CmpId  
 ,@ddlFrequncy AS FreqResult
  
END  
