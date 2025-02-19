


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[getAllDaysBetweenTwoDate]
(
@FromDate DATETIME,    
@ToDate DATETIME
)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
    truncate table test1
    
    DECLARE @TOTALCount INT
    SET @FromDate = DATEADD(DAY,-1,@FromDate)
    Select  @TOTALCount= DATEDIFF(DD,@FromDate,@ToDate);
    WITH dates AS 
            (
              SELECT top (@TOTALCount) AllDays = DATEADD(DAY, ROW_NUMBER() 
                OVER (ORDER BY object_id), REPLACE(@FromDate,'-',''))
              FROM sys.all_objects
            )
        SELECT AllDays into #dt From dates        
        insert into test1
        select cast(day(AllDays) as varchar(2)) + '-' + left(DATENAME(mm,alldays),3) as id, alldays from #dt
    RETURN 
END

 


