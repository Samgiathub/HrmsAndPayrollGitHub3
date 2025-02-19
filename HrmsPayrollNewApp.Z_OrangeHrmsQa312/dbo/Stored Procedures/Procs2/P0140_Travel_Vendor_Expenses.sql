

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0140_Travel_Vendor_Expenses]
	 @Cmp_ID 		numeric
	,@Emp_ID 		numeric
 	,@Travel_Approval_Id Numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	 --Create table #Temp_Emp_Vendor_Expense
	 --(
		--Tran_id numeric(18,0) ,
		--Travel_Approval_Id numeric,
		--Project_ID numeric(18,0),
		--Project_Name varchar(200),		
		--Vendor_ID numeric(18,0),
		--Vendor_name  varchar(200),
	 --   Description  varchar(max),
	 --   Quantity numeric(18,2),
	 --   Rate numeric(18,2) ,
	 --   Tax_Components numeric(18,2),	    
	 --   Tax_Per numeric(18,2),
	 --   Total_Amount numeric(18,2),
  --      Remarks  varchar(max),
  --      Travel_Settlement_ID numeric(18,0),
  --      Tax_Cmpnt_Name varchar(200),
  --      Self_Pay varchar(50),        
  --      Order_Type_ID numeric(18,0),
  --      Order_Type_Name varchar(200),
  --      Site_ID varchar(100),
  --      Approved_Amount numeric(18,2)
        
	 --)	
		
	 --insert into #Temp_Emp_Vendor_Expense(Tran_id,Travel_Approval_Id,Project_ID,Project_Name,
		--								Vendor_ID,Vendor_name,Description,Quantity,
		--								Rate,Tax_Components,Tax_Per,Total_Amount,Remarks,
		--								Travel_Settlement_ID,Tax_Cmpnt_Name,Self_Pay,
		--								Approved_Amount,Order_Type_ID,Order_Type_Name,site_ID)
		select TSE.Tran_id ,
			   TSE.Travel_Approval_Id,
			   TSE.Project_ID,
			   pmp.Project_Name,
			   TSE.vendor_ID,
			   Vm.Vendor_Name,
			   TSE.Description,
			   TSE.Quantity,
			   TSE.Rate,
			   TSE.Tax_components,
			   isnull(TSE.Tax_Percentage,0) as Tax_Per,
			   TSE.Total_Amount,
			   TSE.Remarks,
			   TSA.Travel_Set_Application_id as Travel_Settlement_ID,
			   isnull(TCM.tax_cmponent_name,'') as Tax_Cmpnt_Name,
			   case when isnull(TSE.Self_Pay,0)=0 then 'No' else 'Yes' End as Self_Pay,			   
			   isnull(TSE.Order_Type_ID,0) as Order_Type_ID,
			   OTM.Order_Type_Name,
			   ISNULL(pmp.Site_Id,'') as Site_ID,
			   isnull(TSE.Total_Amount,0) as Approved_Amount
		
		from T0140_Travel_Vendor_Expense_Request TSE WITH (NOLOCK)
		
		inner join T0050_Vendor_Master VM WITH (NOLOCK) on TSE.Vendor_Id = VM.Vendor_Id and TSE.Cmp_ID =VM.Cmp_Id
		inner join T0050_project_master_payroll pmp WITH (NOLOCK) on pmp.Tran_ID=TSE.Project_ID and TSE.Cmp_ID =pmp.Cmp_Id
		inner join T0050_Order_Type_Master OTM WITH (NOLOCK) on OTM.Order_Type_Id=TSE.Order_Type_ID and TSE.Cmp_ID =OTM.Cmp_Id
		left join T0050_Travel_Tax_Component_Master TCM WITH (NOLOCK) on TCM.Tran_ID=TSE.Tax_components and TCM.Cmp_ID=TSE.Cmp_ID		
		left join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) on TSE.Travel_Approval_Id = TSA.Travel_Approval_Id  and TSE.Emp_ID = TSA.emp_id		
		where TSE.Emp_ID  =@Emp_ID and TSE.Travel_Approval_Id=@Travel_Approval_Id
		
		
		order by TSE.Travel_Approval_Id, Tran_ID
     
	 --select distinct * from #Temp_Emp_Vendor_Expense			
	--drop table #Temp_Emp_Vendor_Expense			
RETURN




