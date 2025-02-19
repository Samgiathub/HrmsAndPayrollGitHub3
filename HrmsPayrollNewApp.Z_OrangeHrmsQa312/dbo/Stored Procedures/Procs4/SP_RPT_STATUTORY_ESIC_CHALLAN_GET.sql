

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_ESIC_CHALLAN_GET]
	@Cmp_ID		numeric ,
	@Month		numeric ,
	@Year		numeric ,
	@Branch_Id	numeric, 
	@ESIC_Challan_ID numeric = 0,     --added jimit 03092015
	@PBranch_ID Varchar(max) = ''   --added jimit 07092015
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
Create table #Branch_Cons 
 (      
      
  Branch_ID numeric,
  Cmp_ID numeric
 )      
 
    if @PBranch_ID <> ''
		begin
			Insert Into #Branch_Cons
			Select cast(data  as numeric),@Cmp_ID From dbo.Split(@PBranch_ID,'#') 
		end
	else 
		begin
			Insert Into #Branch_Cons      
			select @Branch_Id,@Cmp_ID
		end
 
 
	
	if @ESIC_Challan_ID <> 0 and @PBranch_ID Is Not Null
		begin 
			select ec.*, cmp_Name,cmp_Address,bank_Name 
			,dbo.F_Number_TO_Word(Total_Amount) as Amount_In_Word
			, cmp_City
			,(
				SELECT ISNULL((STUFF((SELECT distinct  ',' + CASE WHEN B.ESIC_No = '' THEN NULL ELSE B.ESIC_No END   FROM T0030_BRANCH_MASTER B WITH (NOLOCK) INNER JOIN 
							(SELECT CAST(DATA AS NUMERIC) AS BRANCH_ID FROM DBO.Split(Branch_ID_Multi, '#')) MB ON B.Branch_ID= MB.BRANCH_ID
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON B.Cmp_ID=CM.Cmp_Id
							WHERE  ec.ESIC_Challan_ID = @ESIC_Challan_ID and  B.Cmp_ID=ec.Cmp_ID FOR XML PATH('')),1,1,'')
				),CM.ESIC_No) )  as ESIC_No
				
			From T0220_ESIC_Challan ec WITH (NOLOCK) Inner join T0010_company_master cm WITH (NOLOCK) on ec.cmp_Id = cm.cmp_ID inner join T0040_bank_master bm WITH (NOLOCK) on ec.bank_ID = bm.bank_ID
			Where ec.Cmp_ID = @Cmp_ID and ec.Month = @Month and ec.Year = @Year and 
			isnull(Branch_ID,0) = @Branch_Id 
			and ec.ESIC_Challan_ID = @ESIC_Challan_ID
		end
	else
		begin
			select ec.*, cmp_Name,cmp_Address,ESIC_No,bank_Name 
			,dbo.F_Number_TO_Word(Total_Amount) as Amount_In_Word
			, cmp_City
			From T0220_ESIC_Challan ec WITH (NOLOCK) Inner join T0010_company_master cm WITH (NOLOCK) on ec.cmp_Id = cm.cmp_ID inner join T0040_bank_master bm WITH (NOLOCK) on ec.bank_ID = bm.bank_ID
			Where ec.Cmp_ID = @Cmp_ID and ec.Month = @Month and ec.Year = @Year and 
			isnull(Branch_ID,0) = @Branch_Id
		end
		
	RETURN




