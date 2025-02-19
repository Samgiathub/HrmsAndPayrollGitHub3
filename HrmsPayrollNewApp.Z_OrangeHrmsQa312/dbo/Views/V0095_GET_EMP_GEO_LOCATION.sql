


CREATE VIEW [dbo].[V0095_GET_EMP_GEO_LOCATION]
AS

select Emp_Geo_Location_ID,T.Emp_ID,T.Cmp_ID,T.Effective_Date,T.Login_ID,
(EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name ) AS 'Emp_Full_Name',EM.Alpha_Emp_Code
from T0095_EMP_GEO_LOCATION_ASSIGN T 
inner join T0080_EMP_MASTER Em on em.Emp_ID = t.Emp_ID
inner join (
		  Select Max(Effective_Date) as  Effective_Date ,Emp_ID
		from T0095_EMP_GEO_LOCATION_ASSIGN GL where Effective_Date<= getdate() And 
		Emp_ID in (Emp_ID)
		Group By Emp_ID
) J on T.Emp_ID = J.Emp_ID and T.Effective_Date = j.Effective_Date


