
CREATE VIEW [dbo].[V0100_GATE_PASS_APPLICATION]
AS
SELECT        dbo.T0100_GATE_PASS_APPLICATION.App_ID, dbo.T0100_GATE_PASS_APPLICATION.App_Date, dbo.T0100_GATE_PASS_APPLICATION.For_Date, CONVERT(VARCHAR(5), dbo.T0100_GATE_PASS_APPLICATION.From_Time, 108) 
                         AS From_Time, CONVERT(VARCHAR(5), dbo.T0100_GATE_PASS_APPLICATION.To_Time, 108) AS To_Time, dbo.T0100_GATE_PASS_APPLICATION.Duration, dbo.T0100_GATE_PASS_APPLICATION.Remarks, 
                         dbo.T0100_GATE_PASS_APPLICATION.App_User_ID, dbo.T0100_GATE_PASS_APPLICATION.System_Datetime, dbo.T0100_GATE_PASS_APPLICATION.App_Status, dbo.T0100_GATE_PASS_APPLICATION.Cmp_ID, 
                         dbo.T0040_Reason_Master.Reason_Name, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                         dbo.T0100_GATE_PASS_APPLICATION.Emp_ID, dbo.T0100_GATE_PASS_APPLICATION.Reason_ID, dbo.T0095_INCREMENT.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0095_INCREMENT.Grd_ID, 
                         dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0095_INCREMENT.Dept_ID, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0095_INCREMENT.Desig_Id, 
                         dbo.T0100_GATE_PASS_APPLICATION.From_Time AS From_DateTime, dbo.T0100_GATE_PASS_APPLICATION.To_Time AS To_DateTime, 0 AS APR_ID, dbo.T0095_INCREMENT.Vertical_ID, 
                         dbo.T0095_INCREMENT.SubVertical_ID, GA.Actual_Out_Time,GA.Actual_In_Time,GA.Actual_Duration
FROM            dbo.T0100_GATE_PASS_APPLICATION WITH (NOLOCK) INNER JOIN
                         dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_GATE_PASS_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                         dbo.T0040_Reason_Master WITH (NOLOCK)  ON dbo.T0100_GATE_PASS_APPLICATION.Reason_ID = dbo.T0040_Reason_Master.Res_Id INNER JOIN
                         dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID AND dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0095_INCREMENT.Emp_ID INNER JOIN
                         dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                         dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                         dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id INNER JOIN
                         dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                         dbo.T0040_Vertical_Segment WITH (NOLOCK)  ON dbo.T0040_Vertical_Segment.Vertical_ID = dbo.T0095_INCREMENT.Vertical_ID LEFT OUTER JOIN
                         dbo.T0050_SubVertical WITH (NOLOCK)  ON dbo.T0050_SubVertical.SubVertical_ID = dbo.T0095_INCREMENT.SubVertical_ID LEFT OUTER JOIN
                         dbo.T0120_GATE_PASS_APPROVAL AS GA WITH (NOLOCK)  ON GA.App_ID = dbo.T0100_GATE_PASS_APPLICATION.App_ID



