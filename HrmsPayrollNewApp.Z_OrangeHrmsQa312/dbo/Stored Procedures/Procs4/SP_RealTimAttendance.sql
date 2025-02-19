
-- SP_RealTimAttendance 0


CREATE Procedure [dbo].[SP_RealTimAttendance]
@cmp_id int
as

Begin

Declare @ToDayDate as Datetime
SET @ToDayDate = '2021-04-01'

IF OBJECT_ID(N'tempdb..#tblRealTimAttendance') IS NOT NULL
BEGIN
DROP TABLE #tblRealTimAttendance
END



Select 'Attendance'  as Type, Type_Name,B.Branch_Name,  max(Emp_Count) as Employee_Strength ,max(In_Count) as In_Punch, max(Out_Count) as Out_Punch ,Sum(In_Count)-Sum(Out_Count) as Diffrence
Into #tblRealTimAttendance
From 

(
select  Distinct
Branch_ID,Type_ID,count(INOUT.Emp_Id) as In_Count,0 as Out_Count,Min(IN_Time) as IN_Time from  T0150_EMP_INOUT_RECORD as INOUT
Inner Join (
select 
I.Emp_ID,I.Branch_Id,I.Type_ID From T0095_INCREMENT as I Inner Join 
(
Select Emp_Id,Max(Increment_ID) as Increment_ID from T0095_INCREMENT 
group by Emp_id
) as IM On I.Increment_ID = IM.Increment_ID

) AS IE  on INOUT.Emp_ID = IE.Emp_ID
where For_Date = @ToDayDate And IN_Time Is NOT Null
group by Branch_ID,Type_ID

Union All

--select  Distinct 0 as In_Count ,Count(Emp_Id) as Out_Count,Max(Out_Time) as Out_Time from  T0150_EMP_INOUT_RECORD
--where For_Date ='2022-02-22' And Out_Time Is NOT Null

select  Distinct  Branch_ID,Type_ID, 0 as In_Count ,Count(INOUT.Emp_Id) as Out_Count,Max(Out_Time) as Out_Time from  T0150_EMP_INOUT_RECORD as INOUT
Inner Join (
select I.Emp_ID,I.Branch_Id,I.Type_ID From T0095_INCREMENT as I Inner Join 
(Select Emp_Id,Max(Increment_ID) as Increment_ID from T0095_INCREMENT 
group by Emp_id) as IM On I.Increment_ID = IM.Increment_ID
) AS IE  on INOUT.Emp_ID = IE.Emp_ID
where For_Date = @ToDayDate And Out_Time Is NOT Null
group by Branch_ID,Type_ID

) as A Inner Join T0030_BRANCH_MASTER AS B On A.Branch_ID = B.Branch_ID
Inner Join 
(
select 
count(I.Emp_ID) as Emp_Count, I.Branch_Id From T0095_INCREMENT as I Inner Join 
(
Select Emp_Id,Max(Increment_ID) as Increment_ID from T0095_INCREMENT 
group by Emp_id
) as IM On I.Increment_ID = IM.Increment_ID
group by Branch_Id

) as T On A.Branch_ID = T.Branch_ID
inner join T0040_TYPE_MASTER as TM On A.Type_ID = TM.Type_ID

Group by Branch_Name,Type_Name


Select Br.Branch_Name,isnull(RegEmp.CountofRegular,0) as CountofRegular
,isnull(ContEmp.CountofContract,0) as CountofContract
,isnull(JobWorkEmp.CountofJobWork,0) as CountofJobWork
,isnull(RegOthLocEmp.CountofOthLocRegular,0)  as CountofOthLocRegular  

,0 as CountofVisitors  

,isnull(RegEmp.CountofRegular,0)+isnull(ContEmp.CountofContract,0)+isnull(JobWorkEmp.CountofJobWork,0)+isnull(RegOthLocEmp.CountofOthLocRegular,0) as TotalHeadCount 

from 
(
select Distinct Branch_Name from #tblRealTimAttendance where Branch_Name = 'Ahmedabad'
) as Br  
Left outer Join (
--SElect  Type,Type_Name,Branch_Name,Employee_Strength,In_Punch,Out_Punch,Diffrence ,
select Branch_Name,case When Type_Name = 'Permanent' then Diffrence else 0 end as CountofRegular
from #tblRealTimAttendance
where Branch_Name = 'Ahmedabad'
And Type_Name='Permanent'
) as RegEmp On Br.Branch_Name = RegEmp.Branch_Name
Left outer Join (
select Branch_Name,case When Type_Name = 'Contract' then Diffrence else 0 end as CountofContract
from #tblRealTimAttendance
where Branch_Name = 'Ahmedabad'
And Type_Name='Contract'
) as ContEmp On Br.Branch_Name = ContEmp.Branch_Name
Left outer Join (
select Branch_Name,
case When Type_Name = 'Job Work' then Diffrence else 0 end as CountofJobWork
from #tblRealTimAttendance
where Branch_Name = 'Ahmedabad'
And Type_Name='Job Work'
) as JobWorkEmp On Br.Branch_Name = JobWorkEmp.Branch_Name

Left outer Join (
select 'Ahmedabad' as Branch_Name,sum(case When Type_Name = 'Permanent' then Diffrence else 0 end) as CountofOthLocRegular
from #tblRealTimAttendance
where Branch_Name <> 'Ahmedabad'
And Type_Name='Permanent'
) as RegOthLocEmp On Br.Branch_Name = RegOthLocEmp.Branch_Name





----SElect  Type,Type_Name,Branch_Name,Employee_Strength,In_Punch,Out_Punch,Diffrence ,
--Union All
--SElect 'Total ' as Type,''Type_Name, '' as Branch_Name,sum(Employee_Strength),sum(In_Punch),sum(Out_Punch),sum(Diffrence) from #tblRealTimAttendance
End



