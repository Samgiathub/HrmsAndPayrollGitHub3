



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PF_CHALLAN_GET_SETT]
	@Cmp_ID		numeric ,
	@Month		numeric ,
	@Year		numeric ,
	@Branch_Id	numeric 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	select pc.*, cmp_Name,cmp_Address,PF_no,bank_Name 
		,PCD.Sr_No,PCD.Payment_Head,PCD.AC_1,PCD.AC_2,PCD.AC_10,PCD.AC_21,PCD.AC_22,PCD.AC_Total
		,Cmp_city,dbo.F_Number_TO_Word(Total_Challan_Amount) as Amount_In_Word
	From T0220_PF_Challan_SETT pc WITH (NOLOCK) inner join T0230_PF_challan_Detail_sett pcd WITH (NOLOCK) on pc.pf_Challan_ID = pcd.pf_Challan_ID
	Inner join T0010_company_master cm WITH (NOLOCK) on pc.cmp_Id = cm.cmp_ID inner join T0040_bank_master bm WITH (NOLOCK) on pc.bank_ID = bm.bank_ID
	Where pc.Cmp_ID = @Cmp_ID and Pc.Month = @Month and pc.Year = @Year and 
	isnull(Branch_ID,0) = @Branch_Id 
	
	RETURN




