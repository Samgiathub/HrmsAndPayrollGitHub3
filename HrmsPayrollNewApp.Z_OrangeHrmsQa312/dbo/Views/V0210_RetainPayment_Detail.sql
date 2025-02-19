
CREATE VIEW [dbo].[V0210_RetainPayment_Detail]
AS
SELECT Em.Alpha_Emp_Code,Em.Emp_Full_Name,Am.AD_NAME,AM.AD_NOT_EFFECT_SALARY 
,I.Branch_Id,I.Grd_ID,I.Desig_Id,I.Dept_ID,I.Vertical_ID,I.SubVertical_ID,I.Segment_ID,
Bm.Branch_Name,I.Cat_ID,I.Type_ID,I.subBranch_ID
,GM.Grd_Name,DEM.Desig_Name,CM.Cmp_Name,DM.Dept_Name,BAM.Bank_Name,I.Inc_Bank_AC_No,TM.Type_Name,
Es.*
FROM T0210_Retaining_Payment_Detail ES WITH (NOLOCK) Inner Join T0080_EMP_MASTER EM WITH (NOLOCK)  On Es.Emp_id = EM.Emp_ID 
inner Join T0050_AD_MASTER Am WITH (NOLOCK)  on Es.Ad_Id = AM.AD_ID
Inner join (Select I.Cmp_ID,I.Basic_Salary,I.Bank_ID,I.Inc_Bank_AC_No,Branch_ID,I.Increment_Id, I.Emp_Id,I.Grd_ID,I.Desig_Id,I.Dept_ID,I.Vertical_ID,I.SubVertical_ID,I.Segment_ID,I.Cat_ID,I.Type_ID,I.subBranch_ID 
				From T0095_INCREMENT I WITH (NOLOCK) Inner Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
							(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
							Where Increment_effective_Date <= Getdate() Group by emp_ID) new_inc
							on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							Where TI.Increment_effective_Date <= Getdate() group by ti.emp_id) Qry on I.Increment_Id = Qry.Increment_Id ) I On EM.Emp_Id=I.Emp_ID

inner join T0030_BRANCH_MASTER BM WITH (NOLOCK)  on I.Branch_ID = Bm.Branch_ID 
inner join T0040_GRADE_MASTER GM WITH (NOLOCK) on I.Grd_ID = GM.Grd_ID
inner join T0040_DESIGNATION_MASTER DEM WITH (NOLOCK) on I.Desig_Id = DEM.Desig_Id
inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) on I.Cmp_ID = CM.Cmp_Id
--inner join T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) on I.Increment_ID = EED.INCREMENT_ID and EED.AD_ID = AM.AD_ID and EED.CMP_ID = EM.cmp_Id
LEFT join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_Id
LEFT join T0040_BANK_MASTER BAM WITH (NOLOCK) on I.Bank_ID = BAM.Bank_ID
left join T0040_TYPE_MASTER TM WITH (NOLOCK) on I.Type_ID = TM.Type_ID

