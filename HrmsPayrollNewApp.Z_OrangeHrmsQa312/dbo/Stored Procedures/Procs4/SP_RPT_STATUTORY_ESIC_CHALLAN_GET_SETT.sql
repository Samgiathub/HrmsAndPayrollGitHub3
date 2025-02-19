



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_CHALLAN_GET_SETT]
	@Cmp_ID		numeric ,
	@Month		numeric ,
	@Year		numeric ,
	@Branch_Id	numeric 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	select ec.*, cmp_Name,cmp_Address,ESIC_No,bank_Name 
				,dbo.F_Number_TO_Word(Total_Amount) as Amount_In_Word
				, cmp_City
	From T0220_ESIC_Challan_SETT ec WITH (NOLOCK) Inner join T0010_company_master cm WITH (NOLOCK) on ec.cmp_Id = cm.cmp_ID inner join T0040_bank_master bm WITH (NOLOCK) on ec.bank_ID = bm.bank_ID
	Where ec.Cmp_ID = @Cmp_ID and ec.Month = @Month and ec.Year = @Year and 
	isnull(Branch_ID,0) = @Branch_Id 
	
	RETURN




