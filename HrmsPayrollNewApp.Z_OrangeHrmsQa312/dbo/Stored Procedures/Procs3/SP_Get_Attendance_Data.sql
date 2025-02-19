

  
  
  ---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Attendance_Data]  
  
as  

select 'Fetch Spectra Device data '
 /* 
if exists(select * from sysobjects where name like 'GTPL_AttData')  
drop table GTPL_AttData  
  
Declare @Month as varchar(3)  
select @Month = DATENAME(month, GETDATE())   
  
Declare @Qry as varchar(5000)  
set @qry = 'select ROW_NUMBER() OVER (ORDER BY empid,Io_DateTime) AS RowNo,*   
into GTPL_AttData  
from   
(  
select empid, indate1+intime1 as Io_DateTime from ' + @Month +' as a where isnull(indate1,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, indate1+intime1 as Io_DateTime from ' + @Month +' as a where isnull(indate1,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, indate2+intime2 as Io_DateTime from  ' + @Month +'  as a where isnull(indate2,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, indate3+intime3 as Io_DateTime from  ' + @Month +'  as a where isnull(indate3,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, indate4+intime4 as Io_DateTime from  ' + @Month +'  as a where isnull(indate4,''01-Jan-1900'') > ''01-Jan-1900''  
union  
select empid, outdate1+outtime1 as Io_DateTime from  ' + @Month +'  as a where isnull(outdate1,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, outdate2+outtime2 as Io_DateTime from  ' + @Month +'  as a where isnull(outdate2,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, outdate3+outtime3 as Io_DateTime from  ' + @Month +'  as a where isnull(outdate3,''01-Jan-1900'') > ''01-Jan-1900''  
union all  
select empid, outdate4+outtime4 as Io_DateTime from  ' + @Month +'  as a where isnull(outdate4,''01-Jan-1900'') > ''01-Jan-1900''  
)as data   
order by empid,io_datetime'  
  
exec (@qry)  
  */

