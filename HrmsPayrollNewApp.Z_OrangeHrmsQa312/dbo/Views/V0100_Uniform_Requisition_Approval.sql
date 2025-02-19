



CREATE  VIEW [dbo].[V0100_Uniform_Requisition_Approval]    
AS    
	SELECT ISNULL(URAP.Uni_Apr_Id,0) as Uni_Apr_Id,URA.Uni_Req_App_Id,URAD.Uni_Req_App_Detail_Id,URA.Uni_Id,UM.Uni_Name,
			URA.Cmp_ID,URA.Uni_Req_App_Code,URA.Request_Date,URA.Requested_By_Emp_ID,URA.System_Date,URAD.Emp_ID,EM.EMP_Left,
			(CASE  WHEN ISnull(URAP.Approve_Status,'Pending')='Pending'
				   THEN URAD.Uni_Amount
				   ELSE URAP.Uni_Amount 
		     END) AS Uni_Amount,
			(CASE  WHEN ISnull(URAP.Approve_Status,'Pending')='Pending' 
				   THEN URAD.Uni_Fabric_Price
				   ELSE URAP.Uni_Fabric_Price 
		     END) AS Uni_Fabric_Price,	
			(CASE  WHEN ISnull(URAP.Approve_Status,'Pending')='Pending' 
				   THEN URAD.Uni_Pieces
				   ELSE URAP.Uni_Pieces 
		     END) AS Uni_Pieces,
			(CASE  WHEN ISnull(URAP.Approve_Status,'Pending')='Pending' 
				   THEN URAD.Uni_Stitching_Price
				   ELSE URAP.Uni_Stitching_Price 
		     END) AS Uni_Stitching_Price,
			 URAP.Approval_Code,URAP.Approval_Date,
			(CASE  WHEN ISnull(URAP.Approve_Status,'')='' 
				   THEN 'Pending'
				   ELSE URAP.Approve_Status 
			 END) AS Approve_Status,
			 URAP.Approved_By_Emp_ID,(Em.Alpha_Emp_Code+'-'+Em.Emp_Full_Name) as Emp_Full_Name,Em.Alpha_Code,
			 BM.Branch_Name ,Em.Branch_ID,URAP.Comments,
			(CASE  WHEN ISnull(Rem.Alpha_Emp_Code,'')='' 
				   THEN Isnull(Rem.Emp_Full_Name,'Admin')
				   ELSE Isnull(Rem.Alpha_Emp_Code,'') + '-'+Isnull(Rem.Emp_Full_Name,'Admin') 
		     END) as Req_Emp_Full_Name			  
	From T0090_UNIFORM_REQUISITION_APPLICATION URA WITH (NOLOCK)
	INNER JOIN T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL URAD WITH (NOLOCK) on URA.Uni_Req_App_Id=URAD.Uni_Req_App_Id
	INNER JOIN T0040_UNIFORM_MASTER UM WITH (NOLOCK) ON UM.Uni_ID=URA.Uni_Id
	LEFT JOIN T0100_UNIFORM_REQUISITION_APPROVAL URAP WITH (NOLOCK) ON URAD.Uni_Req_App_Detail_Id=URAP.Uni_Req_App_Detail_Id
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)On EM.Emp_ID=URAD.Emp_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On BM.Branch_ID = EM.Branch_ID
	LEFT JOIN T0080_EMP_MASTER REM WITH (NOLOCK) On Rem.Emp_ID=URA.Requested_By_Emp_ID
   





