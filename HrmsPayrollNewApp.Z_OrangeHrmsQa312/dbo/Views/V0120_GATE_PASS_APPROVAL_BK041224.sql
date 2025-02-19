






CREATE VIEW [dbo].[V0120_GATE_PASS_APPROVAL_BK041224]
AS
SELECT     dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Cat_ID, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, dbo.T0095_INCREMENT.Type_ID, dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0080_EMP_MASTER.Cmp_ID, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Increment_ID, dbo.T0100_GATE_PASS_APPLICATION.App_Status, dbo.T0100_GATE_PASS_APPLICATION.App_ID, 
                      dbo.T0120_GATE_PASS_APPROVAL.Apr_ID, dbo.T0120_GATE_PASS_APPROVAL.For_Date, 
                      --dbo.F_GET_AMPM(dbo.T0120_GATE_PASS_APPROVAL.From_Time) AS From_Time, dbo.F_GET_AMPM(dbo.T0120_GATE_PASS_APPROVAL.To_Time) AS To_Time, 
                      CONVERT(VARCHAR(5), dbo.T0120_GATE_PASS_APPROVAL.From_Time, 108 ) AS From_Time, CONVERT(VARCHAR(5), dbo.T0120_GATE_PASS_APPROVAL.To_Time, 108 ) AS To_Time,
                      dbo.T0120_GATE_PASS_APPROVAL.Duration,-- dbo.T0120_GATE_PASS_APPROVAL.Manager_Remarks AS Remarks, 
                      dbo.T0095_INCREMENT.Segment_ID, dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.subBranch_ID, 
                      dbo.T0100_GATE_PASS_APPLICATION.Reason_ID AS Expr1, dbo.T0040_Reason_Master.Reason_Name,
                      --dbo.F_GET_AMPM(Actual_Out_Time) AS Actual_Out_Time,dbo.F_GET_AMPM(Actual_In_Time) AS Actual_In_Time,
                      CONVERT(VARCHAR(5), dbo.T0120_GATE_PASS_APPROVAL.Actual_Out_Time, 108 ) AS Actual_Out_Time, CONVERT(VARCHAR(5), dbo.T0120_GATE_PASS_APPROVAL.Actual_In_Time, 108 ) AS Actual_In_Time,
                      Actual_Duration
                      ,Image_Name,dbo.T0100_GATE_PASS_APPLICATION.Remarks AS Remarks
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID INNER JOIN
                      dbo.T0100_GATE_PASS_APPLICATION WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_GATE_PASS_APPLICATION.Emp_ID LEFT OUTER JOIN
                      dbo.T0120_GATE_PASS_APPROVAL WITH (NOLOCK)  ON dbo.T0100_GATE_PASS_APPLICATION.App_ID = dbo.T0120_GATE_PASS_APPROVAL.App_ID INNER JOIN
                      dbo.T0040_Reason_Master WITH (NOLOCK)  ON dbo.T0120_GATE_PASS_APPROVAL.Reason_ID = dbo.T0040_Reason_Master.Res_Id 




