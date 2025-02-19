
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[GET_InitiatedEmployee_Details]
    @cmp_id    as numeric(18,0)
   --,@Dept_ID numeric(18,0)
   --,@Branch_ID  varchar(100)
   --,@DesigID varchar(100)
   ,@FromDate datetime
   ,@ToDate datetime  
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	SELECT DISTINCT em.Emp_ID,em.Alpha_Emp_Code+'-'+em.Emp_Full_Name as Emp_Full_Name,ie.Branch_ID,ie.Dept_ID,ie.Desig_Id
	from T0050_HRMS_InitiateAppraisal hi WITH (NOLOCK)
	inner join T0080_EMP_MASTER em WITH (NOLOCK) on hi.Emp_Id=em.Emp_ID and hi.Cmp_ID=em.Cmp_ID  
	INNER JOIN	
						(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
						FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
							(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
							 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
								(
									SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
									FROM T0095_INCREMENT  WITH (NOLOCK) WHERE CMP_ID =@cmp_id GROUP BY EMP_ID
								) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
							 WHERE CMP_ID =@cmp_id
							 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
						where I.Cmp_ID=@cmp_id
						)IE on ie.Emp_ID = em.Emp_ID
	where hi.Cmp_ID =@cmp_id and hi.SA_Startdate >=@FromDate and hi.SA_Enddate <=@ToDate
		
END

