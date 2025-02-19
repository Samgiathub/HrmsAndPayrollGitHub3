


CREATE VIEW [dbo].[V0140_Travel_Vendor_Expense_Detail]
AS
select TSE.Tran_ID,TSE.Travel_Approval_Id,Project_ID,Project_Name,TSE.Vendor_ID,
Vendor_Name,Description,Quantity,Rate,Tax_Components,isnull(Tax_Per,0) as Tax_Per,Total_Amount,
TSE.Remarks,TSA.Travel_Set_Application_id as Travel_Settlement_ID,
isnull(TCM.Tax_Cmponent_Name,'') as Tax_Cmpnt_Name,
case when Self_Pay=0 then 'No' else 'Yes' End as Self_Pay,
TSE.Order_Type_Id,OTM.Order_Type_Name,ISNULL(pmp.Site_Id,'') as Site_ID,
TSE.Cmp_ID
	from T0140_Travel_Vendor_Expense_Request TSE WITH (NOLOCK)
		inner join T0050_Vendor_Master Vm WITH (NOLOCK) on TSE.Vendor_ID=VM.Vendor_Id and TSE.Cmp_ID=VM.Cmp_Id
		inner join T0050_project_master_payroll pmp WITH (NOLOCK) on pmp.Tran_Id=TSE.Project_ID and pmp.Cmp_Id=TSE.Cmp_ID
		inner join T0050_Order_Type_Master OTM WITH (NOLOCK) on OTM.Order_Type_Id=TSE.Order_Type_ID and OTM.Cmp_Id=TSE.Cmp_ID
		left join T0050_Travel_Tax_Component_Master TCM WITH (NOLOCK) on TCM.Tran_ID=TSE.Tax_Components and TCM.Cmp_ID=TSE.Cmp_ID
		
		left join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) on TSE.Travel_Approval_Id = TSA.Travel_Approval_Id  and TSE.Emp_ID = TSA.emp_id		



