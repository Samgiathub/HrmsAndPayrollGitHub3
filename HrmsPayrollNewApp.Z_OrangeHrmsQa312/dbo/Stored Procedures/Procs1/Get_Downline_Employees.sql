

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	exec Get_Downline_Employees 1353,9
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Downline_Employees]
	 @r_emp_id		numeric(18,0)
	,@cmp_id		numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN



WITH CTE (eid,rid,gr)
AS
(
    SELECT emp_id,R_Emp_ID, 1 AS GenerationsRemoved
    FROM T0090_EMP_REPORTING_DETAIL i WITH (NOLOCK)
    WHERE i.R_Emp_ID = @r_emp_id
    UNION ALL
    select e.emp_id,e.R_Emp_Id,(x.gr + 1)
    FROM T0090_EMP_REPORTING_DETAIL e WITH (NOLOCK) join
    CTE x on x.eid = e.r_Emp_ID
    where e.R_Emp_ID is not null and Cmp_ID = @cmp_id
			and x.gr <= 10
)
SELECT DISTINCT	i.Emp_ID AS emp_id,i.R_Emp_ID AS r_emp_id,i.Reporting_To,e.Alpha_Emp_Code,e.Emp_Full_Name,(e.Alpha_Emp_Code+'-'+e.emp_full_name) as emp_full_name_new,
       (rm.Alpha_Emp_Code+'-'+rm.emp_full_name) as reportingmanager,d.Dept_Name,inc.dept_id,inc.desig_id,dg.Desig_Name,inc.Branch_ID,b.Branch_Name ,e.Emp_Left,e.Cmp_ID
FROM  (select  top 50000 * from cte) x INNER JOIN
	V0090_EMP_REPORTING_DETAIL_Get i ON i.Emp_ID = x.eid INNER JOIN
	(
		SELECT max(Row_ID)Row_ID,V0090_EMP_REPORTING_DETAIL_Get.Emp_ID
		FROM V0090_EMP_REPORTING_DETAIL_Get  INNER JOIN
		(
			SELECT max(Effect_Date)Effect_Date,Emp_ID
			FROM V0090_EMP_REPORTING_DETAIL_Get
			GROUP by Emp_ID
		)R1 on R1.Emp_ID = V0090_EMP_REPORTING_DETAIL_Get.Emp_ID
		GROUP by V0090_EMP_REPORTING_DETAIL_Get.Emp_ID
	)R2 on R2.Row_ID = i.Row_ID and R2.Emp_ID = i.Emp_ID INNER JOIN
	T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = i.Emp_ID INNER JOIN
	T0095_INCREMENT Inc WITH (NOLOCK) on Inc.Emp_ID = e.Emp_ID INNER JOIN
	(
		SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
		FROM T0095_INCREMENT  WITH (NOLOCK) INNER JOIN
			 (
				SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
				FROM T0095_INCREMENT WITH (NOLOCK)
				GROUP BY Emp_ID
			 ) inc1 ON inc1.Emp_ID = T0095_INCREMENT.Emp_ID
		GROUP By T0095_INCREMENT.Emp_ID
	)inc2 ON inc2.Increment_ID = inc.Increment_ID and inc2.Emp_ID = inc.Emp_ID INNER JOIN
	T0080_EMP_MASTER RM WITH (NOLOCK) on RM.Emp_ID = i.R_Emp_ID LEFT JOIN
	T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Branch_ID = inc.Branch_ID LEFT JOIN
	T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = inc.Dept_ID LEFT JOIN
	T0040_DESIGNATION_MASTER dg WITH (NOLOCK) on dg.Desig_ID = inc.Desig_Id 
WHERE i.R_Emp_ID = @r_emp_id	and e.Emp_Left<>'Y'


--select distinct eid,rid  from CTE


--select distinct eid as emp_id,rid as r_emp_id,Reporting_To,e.Alpha_Emp_Code,e.Emp_Full_Name,(e.Alpha_Emp_Code+'-'+e.emp_full_name) as emp_full_name_new,(rm.Alpha_Emp_Code+'-'+rm.emp_full_name) as reportingmanager,
--	d.Dept_Name,inc.dept_id,inc.desig_id,dg.Desig_Name,inc.Branch_ID,b.Branch_Name ,e.Emp_Left,e.Cmp_ID
--from CTE x
--	left join V0090_EMP_REPORTING_DETAIL_Get i on i.Emp_ID = x.eid
--	and i.Effect_Date = (select MAX(Effect_Date) from t0090_EMP_REPORTING_DETAIL where Emp_ID = x.eid) 
--	left join t0080_emp_master e on e.emp_id = x.eid 
--	inner join T0095_INCREMENT inc on inc.Emp_ID = x.eid and 
--	inc.Increment_ID=(select MAX(Increment_ID) from T0095_INCREMENT where Emp_ID = inc.Emp_ID)
--	left join T0030_BRANCH_MASTER b on b.Branch_ID = inc.Branch_ID 
--	left join T0040_DEPARTMENT_MASTER d on d.Dept_Id = inc.Dept_ID left join 
--	T0040_DESIGNATION_MASTER dg on dg.Desig_ID = inc.Desig_Id  left join 
--	t0080_emp_master rm on rm.Emp_ID = x.rid 
--Where 	e.Emp_Left<>'Y'
	
	

END




