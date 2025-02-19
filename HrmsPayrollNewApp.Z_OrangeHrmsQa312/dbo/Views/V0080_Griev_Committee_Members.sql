


CREATE View [dbo].[V0080_Griev_Committee_Members]
AS
select A.GCMID,EMP.Emp_Full_Name,(EMP.Alpha_Emp_Code+'-'+EMP.Emp_Full_Name) as EmpAlpha,EMP.Branch_Name,T.GCM_Type,A.Cmp_ID,EMP.Alpha_Emp_Code,A.Is_Active,A.GCMEmpID as EmpID,
CASE WHEN A.Is_Active=1 THEN 'awards_link' WHEN A.Is_Active=0 THEN 'awards_link clsinactive' ELSE 'awards_link clsinactive' END as Status_Color
from T0080_Griev_Committee_Member_Allocation A
left join T0040_Griev_Committee_Member_Type T on T.GCM_ID = A.MemberType
left join V0080_Get_Emp_For_Griev_Committee_Member EMP on EMP.Emp_ID = A.GCMEmpID
