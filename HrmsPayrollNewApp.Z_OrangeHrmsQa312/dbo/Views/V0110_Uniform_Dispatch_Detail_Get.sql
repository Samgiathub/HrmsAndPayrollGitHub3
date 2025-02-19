
CREATE VIEW [dbo].[V0110_Uniform_Dispatch_Detail_Get]
AS

 SELECT     ISNULL(UDD.Uni_Disp_Id,0) as Uni_Disp_Id,URA.Uni_Req_App_Id,URA.Uni_Id,UM.Uni_Name,URA.Cmp_ID,URA.Uni_Req_App_Code,
			URA.Request_Date,URA.Requested_By_Emp_ID,URA.System_Date,URAD.Emp_ID,URAP.Uni_Amount,URAP.Uni_Fabric_Price,
			URAP.Uni_Pieces,URAD.Uni_Req_App_Detail_Id,URAP.Uni_Stitching_Price,URAP.Uni_Apr_Id,
			URAP.Approval_Code,URAP.Approval_Date,
		    (CASE  WHEN ISnull(URAP.Approve_Status,'')='' 
				   THEN 'Pending'
				   ELSE URAP.Approve_Status	
		    END) AS Approve_Status,URAP.Approved_By_Emp_ID,Em.Alpha_Code,
			(Em.Alpha_Emp_Code+' - '+Em.Emp_Full_Name) as Emp_Full_Name,UDD.Dispatch_Code,UDD.Dispatch_Date,
			UDD.Refund_Installment,UDD.Deduction_Installment,				
			(CASE  WHEN convert(varchar(13), ISnull(UDD.Refund_Start_Date,'01/01/1900'), 103) ='01/01/1900' THEN ''
				   WHEN convert(varchar(13), UDD.Refund_Start_Date, 103) ='01/01/1900' THEN ''
			       ELSE convert(varchar(13),UDD.Refund_Start_Date,103)	
			END) AS Refund_Start_Date,
			UDD.Deduction_Start_Date,UDD.Dispatch_By_Emp_ID,UDD.System_Datetime,
			BM.Branch_Name ,Em.Branch_ID,UDD.Comments,
			(CASE  WHEN ISnull(Rem.Alpha_Emp_Code,'')='' THEN Isnull(Rem.Emp_Full_Name,'Admin')
				   ELSE Isnull(Rem.Alpha_Emp_Code,'') + ' - '+Isnull(Rem.Emp_Full_Name,'Admin') 
		     END) AS Req_Emp_Full_Name
			,ISNULL(UDD.Dispatch_Code,0) as DispatchCode,UDD.Dispatch_Date as DispatchDate
 FROM T0090_UNIFORM_REQUISITION_APPLICATION URA WITH (NOLOCK)
 INNER JOIN T0095_Uniform_Requisition_Application_Detail URAD WITH (NOLOCK) on URA.Uni_Req_App_Id=URAD.Uni_Req_App_Id  
 INNER JOIN T0040_Uniform_Master UM WITH (NOLOCK) ON UM.Uni_ID=URA.Uni_Id
 INNER JOIN T0100_Uniform_Requisition_Approval URAP WITH (NOLOCK) ON URAD.Uni_Req_App_Detail_Id=URAP.Uni_Req_App_Detail_Id
 INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON EM.Emp_ID=URAD.Emp_ID 
 INNER JOIN T0110_Uniform_Dispatch_Detail UDD WITH (NOLOCK) ON UDD.Uni_Apr_Id=URAP.Uni_Apr_Id and UDD.Uni_Req_App_Detail_Id=URAP.Uni_Req_App_Detail_Id
 INNER JOIN T0050_Uniform_Master_Detail UDM WITH (NOLOCK) ON UDM.Uni_ID =UM.Uni_ID and UDM.Cmp_ID=UM.Cmp_Id
 INNER JOIN (
					SELECT	max(Uni_Effective_Date) as For_Date,Uni_ID,Cmp_ID
					FROM	T0050_Uniform_Master_Detail WITH (NOLOCK)
					WHERE	Uni_Effective_Date <= GETDATE()
					GROUP BY Uni_ID,Cmp_ID
				) Q On UDM.Uni_ID = Q.Uni_ID and UDM.Cmp_ID=Q.Cmp_ID and UDM.Uni_Effective_Date = Q.For_Date
  INNER JOIN T0030_BRANCH_MASTER BM On BM.Branch_ID = EM.Branch_ID
  LEFT JOIN T0080_EMP_MASTER REM On Rem.Emp_ID=URA.Requested_By_Emp_ID
   











