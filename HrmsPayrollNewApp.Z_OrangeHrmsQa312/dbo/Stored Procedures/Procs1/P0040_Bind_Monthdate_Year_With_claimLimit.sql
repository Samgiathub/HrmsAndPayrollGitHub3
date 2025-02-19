    
--exec P0040_Bind_Monthdate_Year_With_claimLimit'          
Create PROCEDURE [dbo].[P0040_Bind_Monthdate_Year_With_claimLimit]          
   @Type as Varchar(50),        
   @date as datetime,        
   @Claim_ID int,    
   @Emp_Id BIGINT    
AS          
SET NOCOUNT ON           
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED          
SET ARITHABORT ON          
          
create table #tempClaimdata    
(    
ClaimID numeric(10),    
ConsiderationClaimLimit numeric(10)    
)          
if @Type='Daily'          
begin          
 Declare @Clmdate varchar(30)        
 DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, @date), 0);          
DECLARE @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, @date) + 1, 0);          
          
SELECT DATEADD(DAY, number, @StartDate) AS ClaimDate ,@Claim_ID as Claim_ID,0 as ConsiderationClaimLimit         
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
--select Convert(varchar(30),Date) as Date from #TempData          
DECLARE     
    @claim_GET_Date varchar(30);     
    
DECLARE Cursor_Claim_List CURSOR    
FOR SELECT     
         Convert(varchar(30),ClaimDate) as Date     
    FROM     
        #TempData;    
    
OPEN Cursor_Claim_List;    
    
FETCH NEXT FROM Cursor_Claim_List INTO     
     @claim_GET_Date;    
    
WHILE @@FETCH_STATUS = 0    
    BEGIN    
  set @Clmdate = convert(varchar, Convert(date, @claim_GET_Date), 103);    
  --PRINT @Clmdate;    
  insert into  #tempClaimdata (ClaimID,ConsiderationClaimLimit)    
   exec [prc_CheckClaimLimit_Autofill] @rClaimId=@Claim_ID,@rAmount=0,@rEmpId=@Emp_Id,@rClaimAppId=0,@rFromDate=@Clmdate;    
   UPDATE #TempData    
   SET ConsiderationClaimLimit = A.ConsiderationClaimLimit    
   from #tempClaimdata A    
   where #TempData.ClaimDate = @claim_GET_Date    
    
   TRUNCATE Table #tempClaimdata    
  FETCH NEXT FROM Cursor_Claim_List INTO     
             @claim_GET_Date;    
    END;    
    
CLOSE Cursor_Claim_List;    
    
DEALLOCATE Cursor_Claim_List;    
    
      
select * from #TempData     
     
    
    
drop table #TempData          
drop table #tempClaimdata          
          
RETURN          