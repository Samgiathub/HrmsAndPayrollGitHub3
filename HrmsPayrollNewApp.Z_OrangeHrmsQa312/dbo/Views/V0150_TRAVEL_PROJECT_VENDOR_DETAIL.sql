


CREATE VIEW [dbo].[V0150_TRAVEL_PROJECT_VENDOR_DETAIL]
AS
SELECT Tran_id as Project_Id,Project_Name,TAD.Cmp_ID,TAD.Travel_Approval_ID from T0050_Project_Master_Payroll
PMP WITH (NOLOCK) inner join T0130_TRAVEL_APPROVAL_DETAIL TAD  WITH (NOLOCK) on TAD.Project_ID=PMP.Tran_Id


