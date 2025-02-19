



CREATE VIEW [dbo].[V0095_Uniform_Requisition_Application_Data]
AS

SELECT Uni_Req_App_Detail_Id,UM.Uni_Req_App_ID,UM.Cmp_ID,Emp_ID,Uni_Pieces,
	   Uni_Fabric_Price,Uni_Stitching_Price,Uni_Amount,Uni_Id,Uni_Req_App_Code,Request_Date,
	   Requested_By_Emp_ID,System_Date  
FROM   T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL AS UST WITH (NOLOCK)
INNER JOIN T0090_UNIFORM_REQUISITION_APPLICATION AS UM WITH (NOLOCK) ON UST.Uni_Req_App_Id = UM.Uni_Req_App_Id





