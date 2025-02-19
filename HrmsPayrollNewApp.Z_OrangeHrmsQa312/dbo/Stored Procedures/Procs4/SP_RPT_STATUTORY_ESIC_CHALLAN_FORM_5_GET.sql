



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_CHALLAN_FORM_5_GET]
	@Cmp_ID		numeric ,
	@From_Date	Datetime ,
	@To_Date	Datetime ,
	@Branch_Id	numeric 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	

	select ec.*, cmp_Name,cmp_Address,bank_Name 
				,dbo.F_Number_TO_Word(Total_Amount) as Amount_In_Word
				, cmp_City ,dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year)as For_Date
	From T0220_ESIC_Challan ec WITH (NOLOCK) Inner join T0010_company_master cm WITH (NOLOCK) on ec.cmp_Id = cm.cmp_ID inner join T0040_bank_master bm WITH (NOLOCK) on ec.bank_ID = bm.bank_ID
	Where ec.Cmp_ID = @Cmp_ID and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) >= @From_date and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) <= @To_Date and 
	isnull(Branch_ID,0) = @Branch_Id 
	



