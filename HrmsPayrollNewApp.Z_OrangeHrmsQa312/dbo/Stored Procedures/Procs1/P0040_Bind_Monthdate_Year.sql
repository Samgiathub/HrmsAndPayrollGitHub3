--exec P0040_Bind_Monthdate_Year 'Daily'  
CREATE PROCEDURE [dbo].[P0040_Bind_Monthdate_Year]  
   @Type as Varchar(50)  
    
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  
if @Type='Daily'  
begin  
  
 DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);  
DECLARE @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0);  
  
SELECT DATEADD(DAY, number, @StartDate) AS Date  
into #TempData FROM master..spt_values  
WHERE type = 'P'  
AND number >= 0  
AND DATEADD(DAY, number, @StartDate) < @EndDate;  
end  
--else if @Type='Monthly'  
--begin   
  
--end  
  
--else if @Type='Yearly'  
--begin   
  
--end  
  
  
--select Convert(date,Date,103) as Date,'From Location' as HQFROM,'To Location' as 'TO' ,'Enter Purpose here' as 'Purpose'  from #TempData  
select Convert(varchar(10),Date) as Date from #TempData  
  
drop table #TempData  
  
RETURN  
  
  
  
  