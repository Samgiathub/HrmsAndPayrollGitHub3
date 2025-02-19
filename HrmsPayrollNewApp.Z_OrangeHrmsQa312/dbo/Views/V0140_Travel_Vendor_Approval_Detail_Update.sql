


CREATE VIEW [dbo].[V0140_Travel_Vendor_Approval_Detail_Update]  
AS  
SELECT  TVA.Tran_ID,TVA.Travel_Aproval_ID as Travel_Approval_Id,TVA.Project_ID,Project_Name,
TVA.Vendor_ID,Vendor_Name,TVA.Description,TVA.Quantity,TVA.Rate,
TVA.Tax_Component_ID as Tax_Components,TVA.Tax_Per,TVA.Total_Amount,
TVA.Remarks,TVA.Travel_Settlement_ID,isnull(TCM.Tax_Cmponent_Name,'') as Tax_Cmpnt_Name,
case when TVA.Self_Pay=0 then 'No' else 'Yes' End as Self_Pay,
TVA.Order_Type_ID,OTM.Order_Type_Name,
ISNULL(pmp.Site_ID,'') as Site_ID,
TVA.Total_Approved_Amount as Approved_Amount,

TVA.Cmp_ID from
t0150_travel_vendor_approval_expense TVA WITH (NOLOCK)
inner join T0050_Vendor_Master VM WITH (NOLOCK) on TVA.Vendor_Id = VM.Vendor_Id and TVA.Cmp_ID=VM.Cmp_Id
inner join T0050_project_master_payroll pmp WITH (NOLOCK) on pmp.Tran_ID=TVA.Project_ID and pmp.Cmp_Id=TVA.Cmp_ID
inner join T0050_Order_Type_Master OTM WITH (NOLOCK) on OTM.Order_Type_Id=TVA.Order_Type_ID and OTM.Cmp_Id=TVA.Cmp_ID
left join T0050_Travel_Tax_Component_Master TCM WITH (NOLOCK) on TCM.Tran_ID=TVA.Tax_Component_ID and TCM.Cmp_ID=TVA.Cmp_ID
--inner join T0140_Travel_Vendor_Expense_Request TSE on TVA.Travel_Aproval_Id=TSE.Travel_Approval_Id
--and TVA.Emp_ID=TSE.Emp_ID and TSE.Cmp_ID=TVA.Cmp_ID and TSE.Project_ID=TVA.Project_ID 
--and TSE.Vendor_ID=TVA.Vendor_ID




