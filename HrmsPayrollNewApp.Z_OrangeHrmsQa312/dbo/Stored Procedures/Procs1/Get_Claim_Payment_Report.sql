
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Claim_Payment_Report]
@Cmp_ID numeric(18,0),
@Claim_Pay_ID numeric(18,0),
@Emp_ID numeric(18,0),
@To_Date datetime
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

select MD.*,CP.Voucher_No,Voucher_Date,CP.Claim_Payment_Type,CP.Claim_Payment_Date,
CP.Claim_Cheque_No,CP.Bank_Name,DM.Desig_Name,B.Branch_Name,D.Dept_Name,Cm.Cmp_Name,CM.Cmp_Address
,EM.Alpha_Emp_Code,Em.Emp_Full_Name,CLM.Claim_Name,Qrv.TtlKM
from T0230_MONTHLY_CLAIM_PAYMENT_DETAIL MD WITH (NOLOCK)
inner join T0210_MONTHLY_CLAIM_PAYMENT CP WITH (NOLOCK) on CP.Claim_Pay_ID = MD.Claim_Pay_Id and CP.Cmp_ID=MD.Cmp_ID
left join 
(select I.Emp_Id,I.Increment_ID,I.Cmp_ID,I.Desig_Id,I.Dept_ID,I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.SalDate_id,I.Segment_ID,I.Increment_effective_Date from dbo.T0095_Increment I WITH (NOLOCK) inner join dbo.T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <=@To_Date--'2015-02-07 00:00:00.000'
				 Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @To_Date--'2015-02-07 00:00:00.000'
				 group by ti.emp_id) I_Q on I_Q.Emp_ID=I.emp_id and I_Q.Increment_ID=I.Increment_ID) Qry on Qry.Emp_ID=MD.Emp_ID
left join 
(select SUM(Claim_PetrolKM) as TtlKM,Claim_Pay_Id from T0230_MONTHLY_CLAIM_PAYMENT_DETAIL WITH (NOLOCK) where cmp_ID=@Cmp_ID
and Claim_Pay_Id=@Claim_Pay_ID
 group by Claim_Pay_Id) Qrv on Qrv.Claim_Pay_Id=MD.Claim_Pay_Id

left join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID=MD.Emp_ID and EM.Cmp_ID=MD.Cmp_ID
left join T0040_Designation_Master DM WITH (NOLOCK) on DM.Desig_ID=Qry.Desig_Id
left join T0030_Branch_Master B WITH (NOLOCK) on B.Branch_ID=Qry.Branch_ID
left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id=Qry.Dept_ID
left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id=Qry.Cmp_ID
left join T0040_CLAIM_MASTER CLM WITH (NOLOCK) on CLM.Claim_ID=MD.Claim_id
 where MD.Cmp_ID=@Cmp_ID and MD.Claim_Pay_Id=@Claim_Pay_ID



--select MD.*,CP.Voucher_No,Voucher_Date,CP.Claim_Payment_Type,CP.Claim_Payment_Date,
--CP.Claim_Cheque_No,CP.Bank_Name,DM.Desig_Name,B.Branch_Name,D.Dept_Name,Cm.Cmp_Name,CM.Cmp_Address
--,EM.Alpha_Emp_Code,Em.Emp_Full_Name,CLM.Claim_Name,Qrv.TtlKM
--from T0230_MONTHLY_CLAIM_PAYMENT_DETAIL MD
--inner join T0210_MONTHLY_CLAIM_PAYMENT CP on CP.Claim_Pay_ID = MD.Claim_Pay_Id and CP.Cmp_ID=MD.Cmp_ID
--left join 
--(select I.Emp_Id,I.Increment_ID,I.Cmp_ID,I.Desig_Id,I.Dept_ID,I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.SalDate_id,I.Segment_ID,I.Increment_effective_Date from dbo.T0095_Increment I inner join dbo.T0080_Emp_Master e on i.Emp_ID = E.Emp_ID inner join
--				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join
--				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
--				Where Increment_effective_Date <='2015-02-07 00:00:00.000'
--				 Group by emp_ID) new_inc
--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
--				Where TI.Increment_effective_Date <= '2015-02-07 00:00:00.000'
--				 group by ti.emp_id) I_Q on I_Q.Emp_ID=I.emp_id and I_Q.Increment_ID=I.Increment_ID) Qry on Qry.Emp_ID=MD.Emp_ID

--left join 
--(select SUM(Claim_PetrolKM) as TtlKM,Claim_Pay_Id from T0230_MONTHLY_CLAIM_PAYMENT_DETAIL where cmp_ID=55 
--and Claim_Pay_Id=97
-- group by Claim_Pay_Id) Qrv on Qrv.Claim_Pay_Id=MD.Claim_Pay_Id
--left join
--T0080_EMP_MASTER EM on EM.Emp_ID=MD.Emp_ID and EM.Cmp_ID=MD.Cmp_ID
--left join T0040_Designation_Master DM on DM.Desig_ID=Qry.Desig_Id
--left join T0030_Branch_Master B on B.Branch_ID=Qry.Branch_ID
--left join T0040_DEPARTMENT_MASTER D on D.Dept_Id=Qry.Dept_ID
--left join T0010_COMPANY_MASTER CM on CM.Cmp_Id=Qry.Cmp_ID
--left join T0040_CLAIM_MASTER CLM on CLM.Claim_ID=MD.Claim_id
-- where MD.Cmp_ID=55 and MD.Claim_Pay_Id=97


END
return

