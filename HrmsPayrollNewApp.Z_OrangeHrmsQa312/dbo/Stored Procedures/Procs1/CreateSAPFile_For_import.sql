-- exec CreateSAPFile_For_import '2014-01-20 09:42:17.000','2022-01-29 19:42:17.000',1
CREATE Procedure [dbo].[CreateSAPFile_For_import]
(
@FromDate datetime,
@Todate datetime,
@Cmp_ID as int
--,@Emp_ID		Numeric
--,@Constraint	varchar(MAX)
)
as
Declare @From_Date Datetime=Convert(Date,@FromDate,103)
,@To_date Datetime=Convert(Date,@Todate,103)

--Declare @FromDate varchar(15)='2014-01-20 09:42:17.000',
--@Todate varchar(15)='2014-01-29 19:42:17.000',
--@Cmp_ID as int=1

Declare @PullDate as datetime
SET @PullDate = dateadd(d,-1,@Todate)

Select inout ,'9999' as Fix,
right('0000'+cast(year(Date)  as varchar(4)),4)+right('00'+cast(Month(Date)  as varchar(2)),2) +right('00'+cast(day(Date)  as varchar(2)),2)  as Date,

right('00'+cast(datepart(HH,Date_Time)  as varchar(2)),2)+right('00'+cast(datepart(mi,Date_Time)  as varchar(2)),2)+right('00'+cast(datepart(ss,Date_Time)  as varchar(2)),2) as Time

,right('0000'+cast(year(@PullDate)  as varchar(4)),4)+right('00'+cast(Month(@PullDate)  as varchar(2)),2) +right('00'+cast(day(@PullDate)  as varchar(2)),2)  as PULL_Date,

right('00'+cast(datepart(HH,getdate())  as varchar(2)),2)+right('00'+cast(datepart(mi,getdate())  as varchar(2)),2)+right('00'+cast(datepart(ss,getdate())  as varchar(2)),2) as PULL_Time
,Emp_Code as 'Time Id'
,Emp_Code as 'PERNR'
from (

select 'P10' as Inout, EM.Emp_code AS Emp_Code,cast(cast(IO_DateTime as varchar(11)) as datetime) as Date, min(IO_DateTime) as Date_Time--, dd.Cmp_ID as Cmp_ID  
from T9999_DEVICE_INOUT_DETAIL dd INNER JOIN T0150_EMP_INOUT_RECORD ER ON ER.IO_Tran_Id=DD.IO_Tran_ID
INNER JOIN T0080_EMP_MASTER EM ON EM.Emp_ID=ER.Emp_ID

where Convert(date,IO_DateTime,103) >@From_Date and Convert(date,IO_DateTime,103) <@Todate and  dd.Cmp_ID=@cmp_id 
---and CARD_ID = 247
group by Emp_Code,cast(cast(IO_DateTime as varchar(11)) as datetime)

Union all


select 'P20' as INOUT,Em.Emp_code as Emp_Code,cast(cast(IO_DateTime as varchar(11)) as datetime) as Date,max(IO_DateTime) as In_Time 
from T9999_DEVICE_INOUT_DETAIL  dd INNER JOIN T0150_EMP_INOUT_RECORD ER ON ER.IO_Tran_Id=DD.IO_Tran_ID
INNER JOIN T0080_EMP_MASTER EM ON EM.Emp_ID=ER.Emp_ID 

where Convert(date,IO_DateTime,103) >@From_Date and Convert(date,IO_DateTime,103) <@Todate and dd.Cmp_ID=@Cmp_ID
And Not Exists(select  1
from (
select 'P10' as Inout, em.Emp_code as Emp_Code,cast(cast(IO_DateTime as varchar(11)) as datetime) as Date,min(IO_DateTime) as Date_Time 
from T9999_DEVICE_INOUT_DETAIL dd INNER JOIN T0150_EMP_INOUT_RECORD ER ON ER.IO_Tran_Id=DD.IO_Tran_ID
INNER JOIN T0080_EMP_MASTER EM ON EM.Emp_ID=ER.Emp_ID

where Convert(date,IO_DateTime,103) >@From_Date and Convert(date,IO_DateTime,103) <@To_date and dd.Cmp_ID=@Cmp_ID
---and CARD_ID = 247
group by Emp_Code,cast(cast(IO_DateTime as varchar(11)) as datetime)
) as A  Where Emp_Code = A.Emp_Code And dd.IO_DateTime = A.Date_Time
)

group by Emp_Code,cast(cast(IO_DateTime as varchar(11)) as datetime)

) as a
order by Emp_Code,Date_Time

