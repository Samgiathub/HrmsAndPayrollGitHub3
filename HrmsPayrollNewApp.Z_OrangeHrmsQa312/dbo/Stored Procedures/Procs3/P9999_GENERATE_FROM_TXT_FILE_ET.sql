

--- exec P9999_GENERATE_FROM_TXT_FILE_ET 1,'C:\Cmp1'

CREATE PROCEDURE [dbo].[P9999_GENERATE_FROM_TXT_FILE_ET]
@Cmp_id as int= 0  ,
@Path as varchar(max) = 'C:' --Assign the folder path where all the .dat files are located  
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

Declare @FileName as varchar(50)
declare @SQL as varchar(max)
Declare @CurDate as dateTime

Set @CurDate = cast(cast(dateadd(day,-1,getdate()) as varchar(11)) as datetime)

set @FileName = @Path+'\'+cast(month(@CurDate) as varchar(2))
                     +cast(day(@CurDate) as varchar(2))
                     +cast(year(@CurDate) as varchar(4))+'.TXT'  --'C:\bcptest02.txt'


BEGIN  
 --This is to configure the xp_cmdshell command.  
 IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell' AND value=1) BEGIN  
  
  --configuring xp command  
  EXEC sp_configure 'show advanced option', 1  
  RECONFIGURE  
  
  
  EXEC sp_configure 'xp_cmdshell', 1  
  RECONFIGURE  
END  
END  

--declare @Path as varchar(50) = 'C:\' --Assign the folder path where all the .dat files are located     
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[T0001_Query_Result]') AND type in (N'U'))
DROP TABLE [dbo].T0001_Query_Result

select 
C1+Yr+Mn+Dy+H+M+S+
right(Yr,4)+Mn+Dy+H+M+S+
replicate(0,15-len(cast(Enroll_no as Varchar(50)) ))+
cast(Enroll_no as Varchar(50)) 
as Col1
into T0001_Query_Result from (
select 'P1' as C1,

'00000'+cast(year(In_time) as varchar(4)) as Yr ,
replicate(0,2-len(cast(month(In_time) as varchar(4)))) 
+cast(month(In_time) as varchar(4)) as Mn ,

replicate(0,2-len(cast(day(In_time) as varchar(4)))) 
+cast(day(In_time) as varchar(4)) as Dy ,

replicate(0,2-len(cast(DATEPART(hh,In_time) as varchar(4)))) 
+cast(DATEPART(hh,In_time) as varchar(4)) as h ,

replicate(0,2-len(cast(DATEPART(mi,In_time) as varchar(4)))) 
+cast(DATEPART(mi,In_time) as varchar(4)) as m ,

replicate(0,2-len(cast(DATEPART(ss,In_time) as varchar(4)))) 
+cast(DATEPART(ss,In_time) as varchar(4)) as s ,

(select Enroll_no from T0080_emp_master WITH (NOLOCK) where Emp_id= A.Emp_id) As Enroll_no

--Emp_id
,In_time
,Cmp_id
 from t0150_Emp_inout_record as A WITH (NOLOCK)
union all
--select 'P2',Emp_id,Out_time from t0150_Emp_inout_record

select 'P2' as C1,

'00000'+cast(year(Out_time) as varchar(4)) as Yr ,
replicate(0,2-len(cast(month(Out_time) as varchar(4)))) 
+cast(month(Out_time) as varchar(4)) as Mn ,

replicate(0,2-len(cast(day(Out_time) as varchar(4)))) 
+cast(day(Out_time) as varchar(4)) as Dy ,

replicate(0,2-len(cast(DATEPART(hh,Out_time) as varchar(4)))) 
+cast(DATEPART(hh,Out_time) as varchar(4)) as h ,

replicate(0,2-len(cast(DATEPART(mi,Out_time) as varchar(4)))) 
+cast(DATEPART(mi,Out_time) as varchar(4)) as m ,

replicate(0,2-len(cast(DATEPART(ss,Out_time) as varchar(4)))) 
+cast(DATEPART(ss,Out_time) as varchar(4)) as s ,

(select Enroll_no from T0080_emp_master WITH (NOLOCK) where Emp_id= b.Emp_id) As Enroll_no

--Emp_id
,Out_time
,Cmp_id
 from t0150_Emp_inout_record as b WITH (NOLOCK)
 
) as Qry 
Where 
not In_time is null 

and isnull(in_time,'') >= '01-Jan-2016'
and isnull(in_time,'') <= @CurDate

----and isnull(in_time,'') = @CurDate

and (@Cmp_id =0 or Cmp_id =@Cmp_id)
order by Enroll_no,In_Time

SET @SQL = 'xp_cmdshell '' bcp " select * from Orange_HRMS_09072014.dbo.T0001_Query_Result " queryout "'+ @FileName + '" -T -c -t,''';   
select @SQL
EXEC(@SQL)  

return

