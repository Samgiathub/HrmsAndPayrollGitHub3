--Exec SP_Mobile_HRMS_WebService_Get_Medical_DepDetails 121,21164,''
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Get_Medical_DepDetails]  
@Cmp_Id numeric(18,0),
@Emp_Id numeric(18,0),
@Result varchar(250) OUTPUT
AS    
BEGIN

SET NOCOUNT ON		
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 
select @Result = Emp_dependent_members from V0090_EMP_INSURANCE_DETAIL_FAMILY_MEMBER where Emp_Ins_Tran_ID =(
select ID.Emp_Ins_Tran_ID from T0090_EMP_INSURANCE_DETAIL ID 
inner join T0040_INSURANCE_MASTER IM on ID.Ins_Tran_ID = IM.Ins_Tran_ID 
where IM.Type = 'Insurance' and IM.Insurance_Type = 1 and ID.Emp_Id = @Emp_Id and ID.Cmp_ID = @Cmp_Id)

	select @Result as result
Return

	
End