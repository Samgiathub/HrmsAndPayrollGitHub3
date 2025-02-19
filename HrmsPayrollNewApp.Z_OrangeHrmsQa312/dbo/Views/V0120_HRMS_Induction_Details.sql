


CREATE VIEW [dbo].[V0120_HRMS_Induction_Details]
AS
SELECT   Schedule_Date, Induction_ID,dbo.T0120_HRMS_Induction_Details.Cmp_ID,
 isnull(dbo.F_GET_AMPM(dbo.T0120_HRMS_Induction_Details.From_Time),'')From_Time, 
 isnull(dbo.F_GET_AMPM(dbo.T0120_HRMS_Induction_Details.To_Time),'')To_Time, 
 dbo.T0040_DEPARTMENT_MASTER.Dept_Name,
 (SELECT     (E.Alpha_Emp_Code + '-' + E.Emp_Full_Name) + ','
                            FROM          T0080_EMP_MASTER E WITH (NOLOCK)
                            WHERE      E.Emp_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0120_HRMS_Induction_Details.Emp_ID, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) AS Employee_Name
FROM         dbo.T0120_HRMS_Induction_Details WITH (NOLOCK) INNER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0120_HRMS_Induction_Details.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id --INNER JOIN
                    --  dbo.T0080_EMP_MASTER EM ON dbo.T0120_HRMS_Induction_Details.Emp_ID = EM.Emp_ID INNER JOIN
                      --dbo.T0080_EMP_MASTER CM ON dbo.T0120_HRMS_Induction_Details.Contact_Person_ID = CM.Emp_ID INNER JOIN
                     

                     

