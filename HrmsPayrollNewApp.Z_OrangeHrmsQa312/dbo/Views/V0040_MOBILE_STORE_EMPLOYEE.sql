


CREATE VIEW [dbo].[V0040_MOBILE_STORE_EMPLOYEE]
AS
	SELECT  Store_Tran_ID ,N.Cmp_Id,A.Emp_ID ,A.Emp_Code,E.Emp_Full_Name 
	,A.Store_ID,N.Current_Outlet_Mapping as Store_Name,Effective_Date 
	FROM T0040_EMP_MOBILE_STORE_ASSIGN_New A  WITH (NOLOCK)
	INNER join T0040_MOBILE_STORE_MASTER_New N WITH (NOLOCK) ON A.Store_ID = N.Store_ID
	left JOIN T0080_EMP_MASTER E WITH (NOLOCK) on A.Emp_Code = E.Alpha_Emp_Code	and A.Emp_ID = E.Emp_ID

