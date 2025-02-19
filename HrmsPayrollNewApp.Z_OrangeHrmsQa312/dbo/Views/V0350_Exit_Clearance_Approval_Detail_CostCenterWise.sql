





CREATE VIEW [dbo].[V0350_Exit_Clearance_Approval_Detail_CostCenterWise]
AS
SELECT DISTINCT    CA.Item_name, isnull(ED.Tran_id,0) as Tran_id, ECA.Approval_id, CA.Clearance_id, isnull(ED.Recovery_Amt,0) As Recovery_Amt, ED.Remarks, ED.Attachment_path, 
                      ISNULL(ED.Not_Applicable, 0) AS Not_Applicable,ECA.Hod_ID,CA.Cmp_id,CA.Active,ECA.Remarks As A_Remarks,ECA.Emp_ID,
                      EM.Alpha_Emp_Code +' - ' +EM.Emp_Full_Name As Emp_Full_Name,0 AS Dept_id,ED.Status,EC.Center_ID
FROM         dbo.T0095_Exit_Clearance AS EC WITH (NOLOCK) INNER JOIN
					  T0040_COST_CENTER_MASTER CM WITH (NOLOCK)  ON CM.Center_ID = EC.Center_ID INNER JOIN
                      dbo.T0040_Clearance_Attribute AS CA WITH (NOLOCK)  ON EC.Center_ID = CA.Cost_Center_ID INNER JOIN
                      dbo.T0300_Exit_Clearance_Approval AS ECA WITH (NOLOCK)  ON ECA.Hod_ID = EC.Emp_id and ECA.Center_ID = EC.Center_ID AND EC.Cmp_id=ECA.Cmp_ID INNER JOIN
                      dbo.T0080_EMP_MASTER as EM WITH (NOLOCK)  ON EM.Emp_ID = ECA.Emp_ID LEFT OUTER JOIN
                      dbo.T0350_Exit_Clearance_Approval_Detail AS ED WITH (NOLOCK)  ON ED.Approval_id = ECA.Approval_Id and ED.Cmp_id=EC.Cmp_id AND ED.Clearance_id = CA.Clearance_id 




