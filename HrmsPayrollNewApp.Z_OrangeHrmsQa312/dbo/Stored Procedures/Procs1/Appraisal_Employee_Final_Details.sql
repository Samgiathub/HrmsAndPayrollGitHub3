


-- =============================================
-- Author: Mukti Chauhan
-- Create date: 27-07-2018
-- Description:	Closing Loop
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Appraisal_Employee_Final_Details]
	@Cmp_ID Numeric,
	@Emp_ID Numeric	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    DECLARE @InitiateId as INT
    
	SELECT @InitiateId=MAX(InitiateId)
	FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE CMP_ID = @cmp_id AND Emp_Id=@EMP_ID
	GROUP BY EMP_ID
	
	PRINT @InitiateId
				
	SELECT em.emp_id, IE.Increment_ID,(em.Alpha_Emp_Code +' '+ em.Emp_Full_Name)emp_name,
	D.Desig_Name,DM.Dept_Name,BM.Branch_Name,HI.Overall_Score,CONVERT(VARCHAR(15),em.Date_Of_Join,103)Date_Of_Join,
	em.Grd_ID,@InitiateId as Initiate_Id,HI.Emp_Engagement_Comment
		FROM T0080_EMP_MASTER em WITH (NOLOCK)
		INNER JOIN	
		(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID, I.Increment_ID
		FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
			 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
				(
					SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
					FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
			 WHERE CMP_ID = @cmp_id
			 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
		where I.Cmp_ID= @cmp_id
		)IE on ie.Emp_ID = em.Emp_ID 
	Inner Join T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON IE.Desig_Id=D.Desig_ID
	Inner Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IE.Dept_ID=DM.Dept_Id
	Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IE.Branch_ID=BM.Branch_ID
	inner JOIN T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK) ON HI.Emp_Id=EM.Emp_ID
	WHERE em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' and em.Emp_ID=@Emp_ID
		
	SELECT EF.*,OA.OA_Title from T0050_HRMS_EmpOA_Feedback EF WITH (NOLOCK)
	INNER JOIN T0040_HRMS_OtherAssessment_Master OA WITH (NOLOCK) on EF.OA_ID=OA.OA_Id
	WHERE EF.cmp_id=@cmp_id  and Emp_ID=@Emp_ID and Initiation_Id=@InitiateId
	--where ap.Cmp_ID =@cmp_id and ap.Emp_ID=@Emp_ID and ap.InitiateId=@Initiation_Id and ap.Approval_Level='Emp'
		
END

