Create View V0080_Get_Griev_Emp_Details
As
select EM.Emp_ID,EM.Cmp_ID,EM.Mobile_No,EM.Branch_ID,EM.Branch_Name,BM.Branch_Address,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Work_Email
from V0080_Employee_Master EM
Left join T0030_BRANCH_MASTER BM on BM.Branch_ID = EM.Branch_ID