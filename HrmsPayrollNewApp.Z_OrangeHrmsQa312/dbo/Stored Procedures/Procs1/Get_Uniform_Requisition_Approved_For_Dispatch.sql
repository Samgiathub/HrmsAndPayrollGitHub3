
-- =============================================
-- Author:		Binal Prajapati
-- Create date: 08/08/2020
-- Description:	Get Approved Application Fo Dispacth
-- =============================================
CREATE PROCEDURE [dbo].[Get_Uniform_Requisition_Approved_For_Dispatch]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT  URA.Uni_Req_App_Id,URA.Uni_Id,UM.Uni_Name,URA.Cmp_ID,URA.Uni_Req_App_Code,
			URA.Request_Date,URA.Requested_By_Emp_ID,URA.System_Date,URAD.Emp_ID,URAD.Uni_Amount,URAD.Uni_Fabric_Price,
			URAD.Uni_Pieces,URAD.Uni_Req_App_Detail_Id,URAD.Uni_Stitching_Price,URAP.Uni_Apr_Id,
			URAP.Approval_Code,URAP.Approval_Date,
		    (CASE  WHEN ISnull(URAP.Approve_Status,'')='' THEN 'Pending'
				   ELSE URAP.Approve_Status
			 END) as Status,
			URAP.Approved_By_Emp_ID,Em.Alpha_Emp_Code,Em.Alpha_Code,
			Em.Emp_Full_Name 
	FROM T0090_UNIFORM_REQUISITION_APPLICATION URA WITH (NOLOCK)
	INNER JOIN T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL URAD WITH (NOLOCK) on URA.Uni_Req_App_Id=URAD.Uni_Req_App_Id
	INNER JOIN T0040_UNIFORM_MASTER UM WITH (NOLOCK) on UM.Uni_ID=URA.Uni_Id
	INNER JOIN T0100_UNIFORM_REQUISITION_APPROVAL URAP WITH (NOLOCK) ON URAD.Uni_Req_App_Detail_Id=URAP.Uni_Req_App_Detail_Id
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID=URAD.Emp_ID
	WHERE URAP.Approve_Status='Approved'

END

