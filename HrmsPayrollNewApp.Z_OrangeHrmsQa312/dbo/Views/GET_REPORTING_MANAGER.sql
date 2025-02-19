


CREATE  VIEW [dbo].[GET_REPORTING_MANAGER]  
AS  
SELECT DISTINCT EM.Emp_ID,(ISNULL(EM.Alpha_Emp_Code,'')+' - '+  ISNULL(EM.Initial,'')+' '+isnull(Emp_First_Name,'')+' '+isnull(Emp_Last_Name,'')) as 'EmployeeName',EPD.Cmp_ID   
FROM T0080_EMP_MASTER  EM WITH (NOLOCK)
inner JOIN T0090_EMP_REPORTING_DETAIL EPD WITH (NOLOCK) ON EM.Emp_ID = EPD.R_Emp_ID  

