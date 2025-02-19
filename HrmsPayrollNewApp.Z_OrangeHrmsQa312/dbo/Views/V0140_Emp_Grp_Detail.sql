



CREATE VIEW [dbo].[V0140_Emp_Grp_Detail]
AS
SELECT TSP.*,Em.Emp_first_Name,BM.Branch_Name,EM.Emp_Full_Name,Em.Alpha_Emp_Code,Em.Work_Email from T0140_Travel_Settlement_Group_Emp TSP WITH (NOLOCK)
inner join T0080_EMP_MASTER Em WITH (NOLOCK) on Em.Emp_ID=TSP.Selected_Emp_ID
and TSP.Cmp_ID=EM.Cmp_ID
left join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=TSP.Branch_ID




