



CREATE VIEW [dbo].[V0090_Uniform_Requisition_Application]
AS
SELECT UEI.Uni_Req_App_Id, UEI.Uni_Id,URAM.Uni_Req_App_Detail_Id, UM.Uni_Name, EM.Alpha_Emp_Code, EM.Emp_Full_Name, 
	   UEI.Cmp_ID,I.Branch_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID, I.Type_ID, I.Grd_ID, I.Cat_ID, I.Desig_Id,
	   I.Segment_ID, I.subBranch_ID, EM.Emp_First_Name,UEI.Uni_Req_App_Code,UEI.Request_Date,UEI.Requested_By_Emp_ID,
	   UEI.System_Date,URAM.Uni_Pieces,URAM.Uni_Fabric_Price,URAM.Uni_Stitching_Price,URAM.Uni_Amount,URAM.Emp_ID,
	   URAM.Comments
FROM  T0090_UNIFORM_REQUISITION_APPLICATION UEI WITH (NOLOCK)
INNER JOIN T0095_UNIFORM_REQUISITION_APPLICATION_DETAIL URAM WITH (NOLOCK) ON UEI.Uni_Req_App_Id = URAM.Uni_Req_App_Id 
INNER JOIN T0040_UNIFORM_MASTER UM WITH (NOLOCK) ON UEI.Uni_Id = UM.Uni_ID 
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = URAM.Emp_ID 
INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON	I.Emp_ID = EM.Emp_ID 
INNER JOIN ( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
			 FROM T0095_INCREMENT I WITH (NOLOCK)
				INNER JOIN 
				(
						SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
						FROM T0095_INCREMENT I3 WITH (NOLOCK)
						WHERE I3.Increment_effective_Date <= GETDATE()
						GROUP BY I3.EMP_ID  
				) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
			   WHERE I.INCREMENT_EFFECTIVE_DATE <= GETDATE()
			   GROUP BY I.emp_ID  
			) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 







