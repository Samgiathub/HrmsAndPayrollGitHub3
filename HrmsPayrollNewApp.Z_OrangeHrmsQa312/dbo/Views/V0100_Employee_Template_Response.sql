
CREATE VIEW [dbo].[V0100_Employee_Template_Response]
AS
SELECT DISTINCT 
                    TR.Emp_ID, TR1.Created_Date, T_Id,(EI.Alpha_Emp_Code + '-' + EI.Emp_Full_Name) as Emp_Full_Name,
					EI.Alpha_Emp_Code,EI.Emp_First_Name, EI.Branch_ID,EI.Branch_Name, EI.Dept_ID,EI.Dept_Name, EI.Desig_Id,EI.Desig_Name				
FROM         dbo.T0100_Employee_Template_Response TR WITH (NOLOCK) 
INNER JOIN (SELECT MAX(Created_Date)Created_Date,EMP_ID FROM T0100_Employee_Template_Response WITH (NOLOCK) GROUP BY Emp_Id) TR1 ON TR.Emp_Id=TR1.EMP_ID 
INNER JOIN  V0060_HRMS_EMP_MASTER_INCREMENT_GET EI ON EI.EMP_ID=TR.Emp_Id 			 


