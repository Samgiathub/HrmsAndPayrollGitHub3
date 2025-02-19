


 
 
CREATE  VIEW [dbo].[V0040_Employee_Transport_Registration]

AS

SELECT ETR.Transport_Reg_ID,ETR.Emp_ID,ETR.Route_ID,ETR.Pickup_ID,ETR.Designation_ID,ETR.Transport_Status,
CONVERT(varchar(11), ETR.Effective_Date ,103) AS 'Effective_Date',ETR.Cmp_ID,RM.Route_Name,PM.Pickup_Name,
DM.Designation_Name,(EM.Initial + '' + EM.Emp_First_Name +''+ ISNULL(EM.Emp_Second_Name,'')+''+ISNULL(EM.Emp_Last_Name,'')) AS 'Emp_Name',
EM.Emp_code,(CASE WHEN Transport_Status = 0 THEN 'UnRegister' ELSE 'Register' END) AS 'TransStatus',
(CASE WHEN Transport_Type = 'T' THEN 'Temporary' ELSE 'Permanent' END) AS 'TransType',Transport_Type
FROM T0040_Employee_Transport_Registration ETR WITH (NOLOCK)
INNER JOIN T0040_Route_Master RM WITH (NOLOCK) ON ETR.Route_ID = RM.Route_ID
INNER JOIN T0040_PickupStation_Master PM WITH (NOLOCK) ON ETR.Pickup_ID = PM.Pickup_ID
LEFT JOIN T0040_DESIGNATION_MASTER_TRANSPORT DM WITH (NOLOCK) ON ETR.Designation_ID = DM.Designation_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ETR.Emp_ID = EM.Emp_ID




