



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PF_CHALLAN_GET]
	@Cmp_ID		numeric ,
	@Month		numeric ,
	@Year		numeric ,
	@Branch_Id	numeric ,
	@PF_Challan_Id numeric = 0, --added jimit 31082015
	@PBranch_ID Varchar(max) = ''   --added jimit 04092015
	
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
 
 
 
	if @PF_Challan_Id <> 0 and @PBranch_ID Is Not Null
		begin
		
			select distinct pc.*, cmp_Name,cmp_Address,bank_Name 
				,PCD.Sr_No,PCD.Payment_Head,PCD.AC_1,PCD.AC_2,PCD.AC_10,PCD.AC_21,PCD.AC_22,PCD.AC_Total
				,Cmp_city,dbo.F_Number_TO_Word(Total_Challan_Amount) as Amount_In_Word,
				--,br.PF_No,
				(
				SELECT ISNULL((STUFF((SELECT distinct  ',' + CASE WHEN B.PF_NO = '' THEN NULL ELSE B.PF_NO END   FROM T0030_BRANCH_MASTER B WITH (NOLOCK) INNER JOIN 
							(SELECT CAST(DATA AS NUMERIC) AS BRANCH_ID FROM DBO.Split(Branch_ID_Multi, '#')) MB ON B.Branch_ID= MB.BRANCH_ID
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON B.Cmp_ID=CM.Cmp_Id
							WHERE  pc.Pf_Challan_ID = @PF_Challan_Id and  B.Cmp_ID=pc.Cmp_ID FOR XML PATH('')),1,1,'')
				),CM.PF_No) )  as PF_No
				
			From T0220_PF_Challan pc WITH (NOLOCK)  inner join T0230_PF_challan_Detail pcd WITH (NOLOCK) on pc.pf_Challan_ID = pcd.pf_Challan_ID
			Inner join T0010_company_master cm WITH (NOLOCK) on pc.cmp_Id = cm.cmp_ID Left Outer join T0040_bank_master bm WITH (NOLOCK) on pc.bank_ID = bm.bank_ID
			Inner JOIN #Branch_cons BC ON BC.Cmp_ID = PC.Cmp_ID
			left outer join T0030_BRANCH_MASTER Br WITH (NOLOCK) on Br.Branch_ID = BC.Branch_ID
			
			Where pc.Cmp_ID = @Cmp_ID and Pc.Month = @Month and pc.Year = @Year and 
			 pc.Pf_Challan_ID = @PF_Challan_Id     --added jimit 31082015
			 --and br.Branch_ID in (select Branch_ID from #Branch_Cons)
		end
		else 
			begin
			
				select pc.*, cmp_Name,cmp_Address,PF_no,bank_Name 
				,PCD.Sr_No,PCD.Payment_Head,PCD.AC_1,PCD.AC_2,PCD.AC_10,PCD.AC_21,PCD.AC_22,PCD.AC_Total
				,Cmp_city,dbo.F_Number_TO_Word(Total_Challan_Amount) as Amount_In_Word
			From T0220_PF_Challan pc WITH (NOLOCK) inner join T0230_PF_challan_Detail pcd WITH (NOLOCK) on pc.pf_Challan_ID = pcd.pf_Challan_ID
			Inner join T0010_company_master cm WITH (NOLOCK) on pc.cmp_Id = cm.cmp_ID Left Outer join T0040_bank_master bm WITH (NOLOCK) on pc.bank_ID = bm.bank_ID
			Where pc.Cmp_ID = @Cmp_ID and Pc.Month = @Month and pc.Year = @Year and 
			isnull(Branch_ID,0) = @Branch_Id 						
			end
	RETURN




