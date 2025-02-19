  
  
  
  
CREATE View [dbo].[V0040_Bank_Master]  
As   
select   
bm.Bank_Id as Bank_Id  
,bm.Bank_Code as Bank_Code  
,bm.Bank_Name as Bank_Name  
,bm.Bank_Ac_No as Bank_Ac_No  
,bm.Bank_Address as Bank_Address  
,bm.Bank_Branch_Name as Bank_Branch_Name  
---,BRM.Branch_Name as Company_Branch   --comment by manisha on 07012025
,bm.Bank_City as Bank_City  
,Is_Default as Is_Default  
,BM.Cmp_Id as Cmp_Id  
from T0040_BANK_MASTER BM With (NOLOCK)   
--inner join T0030_BRANCH_MASTER BRM With (NOLOCK)    --comment by manisha on 07012025
--on bm.Company_Branch=BRM.Branch_id   --comment by manisha on 07012025
  
  
  
  