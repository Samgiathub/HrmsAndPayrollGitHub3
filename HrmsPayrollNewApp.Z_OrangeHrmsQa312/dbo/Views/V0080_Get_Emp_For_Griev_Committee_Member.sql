
CREATE View [dbo].[V0080_Get_Emp_For_Griev_Committee_Member]
As
select EM.Emp_ID, EM.Emp_Full_Name,EM.Alpha_Emp_Code,BM.Branch_Name,EM.Cmp_ID,BM.Branch_ID,isnull(BM.State_ID,0) State_ID,
 isnull(BM.District_ID,0) District_ID , isnull(BM.Tehsil_ID,0) Tehsil_ID,isnull(I.Vertical_ID,0) as Vertical_ID,
 ISNULL(I.SubVertical_ID,0) SubVertical,isnull(I.Segment_ID,0) BusiSgmt
 from T0080_EMP_MASTER EM
left join T0095_INCREMENT I on I.Emp_ID = EM.Emp_ID
CROSS APPLY (SELECT * FROM dbo.fn_getEmpIncrement(EM.Cmp_ID,EM.Emp_ID,getdate()) T WHERE I.Increment_ID=T.Increment_ID) T
left join T0030_BRANCH_MASTER BM on BM.Branch_ID = I.Branch_ID
where  EM.Emp_Left='N' 
