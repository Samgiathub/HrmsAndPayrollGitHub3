
--exec SP_Mobile_HRMS_WebService_Get_Medical_AppId_Details @Emp_ID=21164,@Cmp_ID=121,@APPId = 247
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Get_Medical_AppId_Details]  
@Cmp_Id numeric(18,0),
@Emp_Id numeric(18,0),
@APPId numeric(18,0)
AS    
BEGIN

SET NOCOUNT ON		
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Emp_Assgn as numeric(18,0) = 0
select @Emp_Assgn = Emp_id from T0500_MEDICAL_APPLICATION where Created_by = @Emp_Id and App_Id = @APPId and Cmp_Id = @Cmp_Id


IF OBJECT_ID('tempdb..#temp') IS NOT NULL
    DROP TABLE #temp


select Emp_dependent_members ,Emp_Id,@Cmp_Id as Cmp_id into #temp from V0090_EMP_INSURANCE_DETAIL_FAMILY_MEMBER where Emp_Ins_Tran_ID in (
SELECT ID.EMP_INS_TRAN_ID FROM T0090_EMP_INSURANCE_DETAIL ID 
INNER JOIN T0040_INSURANCE_MASTER IM ON ID.INS_TRAN_ID = IM.INS_TRAN_ID 
WHERE IM.TYPE = 'INSURANCE' AND
IM.INSURANCE_TYPE = 1 AND ID.EMP_ID = @Emp_Assgn AND ID.CMP_ID = @Cmp_Id)


SELECT  M.*,S.State_Name,I.Incident_Name,Emp_Dependent_Members
FROM T0500_MEDICAL_APPLICATION M
inner join T0020_STATE_MASTER S on M.State_Id = S.State_ID
inner join T0040_INCIDENT_MASTER I on M.Incident_Id = I.Incident_Id
inner join #temp T on t.Emp_Id = M.Emp_id
WHERE APP_ID = @APPId AND M.Cmp_Id = @Cmp_Id and t.Cmp_id = @Cmp_Id
ORDER BY APP_ID DESC

END