




CREATE VIEW [dbo].[V0040_Training_Induction_Master]
AS
SELECT dbo.T0040_Training_Induction_Master.*, dbo.T0040_DEPARTMENT_MASTER.Dept_Name,
T0040_Hrms_Training_master.Training_name,
 (SELECT     (E.Alpha_Emp_Code + '-' + E.Emp_Full_Name) + ','
FROM          T0080_EMP_MASTER E WITH (NOLOCK)
WHERE      E.Emp_ID IN
           (SELECT     cast(data AS numeric(18, 0))
             FROM          dbo.Split(ISNULL(dbo.T0040_Training_Induction_Master.Contact_Person_ID, '0'), '#')
             WHERE      data <> '') FOR XML path('')) AS Emp_Name
FROM  dbo.T0040_Training_Induction_Master  WITH (NOLOCK)
--INNER JOIN T0080_EMP_MASTER on T0080_EMP_MASTER.Emp_ID=T0040_Training_Induction_Master.Contact_Person_ID
inner join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0040_Training_Induction_Master.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id
inner join dbo.T0040_Hrms_Training_master WITH (NOLOCK) ON dbo.T0040_Hrms_Training_master.Training_id = dbo.T0040_Training_Induction_Master.Training_id




