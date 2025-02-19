CREATE procedure [dbo].[KPMS_prc_GetMonths]      
@rCmpId int,    
@StartDate1  VARCHAR(10),  
@EndDate1 VARCHAR(10)  
  
as      
begin   

--declare @StartDate1 as date
--declare @EndDate1 as date

--set @StartDate1 = convert(date, @StartDate, 23)
--set @EndDate1 = convert(date, @EndDate, 23)

 SELECT @StartDate1 = CASE ISNULL(@StartDate1,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @StartDate1, 105), 23) END    
 SELECT @EndDate1 = CASE ISNULL(@EndDate1,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @EndDate1, 105), 23) END    

declare @StartDate as date
declare @EndDate as date

set @StartDate = convert(date, @StartDate1, 23)
set @EndDate = convert(date, @EndDate1, 23)


IF OBJECT_ID(N'tempdb..#tblMonth') IS NOT NULL    
BEGIN    
DROP TABLE #tblMonth    
END    
    
Create Table #tblMonth    
(   
Month_Number int,
Month_Name  varchar(30)    
)    
    
WHILE (@StartDate <= @EndDate)    
    
BEGIN    
    
Insert into #tblMonth(Month_Number,Month_Name)    
SELECT month(@StartDate) as month_num,   DATENAME( MONTH, DATEADD( MONTH, MONTH(DATEADD(month, 0, @StartDate)), -1)) AS 'Month Name'    
    
set @StartDate = DATEADD(month, 1, @StartDate);    
    
END;    
   
  -- select * from #tblMonth;
declare @lResult varchar(max) = '<option value="0"> -- Select -- </option>'   
 select @lResult = isnull(@lResult,'') + '<option value="' +  convert(varchar,Month_Number) + '">' + Month_Name+'</option>' from #tblMonth    

select @lResult as Result      
end    
    
    