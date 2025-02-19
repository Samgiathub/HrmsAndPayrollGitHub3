

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[sp_readTextFile] @FILENAME SYSNAME  
as 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 begin   
  
 CREATE table #tempfile (line nvarchar(max))  
 --exec ('bulk insert #tempfile from "' + @filename + '"')
 exec ('bulk insert #tempfile from "' + @filename + '" with (DATAFILETYPE = ''widechar'',FIELDTERMINATOR = ''\t'', ROWTERMINATOR = ''\n'')')   
   
insert into Attendance_Log  
 select * from #tempfile  
 drop table #tempfile  
 End

