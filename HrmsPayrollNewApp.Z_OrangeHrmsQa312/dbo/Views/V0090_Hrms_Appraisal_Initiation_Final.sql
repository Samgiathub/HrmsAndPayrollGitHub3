





CREATE VIEW [dbo].[V0090_Hrms_Appraisal_Initiation_Final]
AS
SELECT     HID.Appr_Int_Id, HID.Is_Accept, EM.Emp_ID, EM.Emp_code, EM.Emp_Full_Name, EM.Emp_Superior, E.Emp_Full_Name AS Employee_Superior, 
                      HID.Is_Emp_Submit, HID.Is_Sup_submit, HID.start_date, HID.End_date
FROM         dbo.T0090_Hrms_Appraisal_Initiation_Detail AS HID WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON HID.Emp_Id = EM.Emp_ID INNER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON EM.Emp_Superior = E.Emp_ID




