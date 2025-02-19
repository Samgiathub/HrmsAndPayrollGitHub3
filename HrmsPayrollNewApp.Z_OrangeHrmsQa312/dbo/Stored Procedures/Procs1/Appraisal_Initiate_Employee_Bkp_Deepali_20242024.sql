--exec Appraisal_Initiate_Employee @cmp_Id=1,@condition='',@effectivedate='2022-10-01 00:00:00',@flag='add'


---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[Appraisal_Initiate_Employee_Bkp_Deepali_20242024]
	 @cmp_Id  numeric(18,0) 
	,@condition varchar(800)=''
	,@effectivedate datetime =null
	,@flag varchar(10) --Mukti(12102016)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
    	
	declare @joinVal int;
	
	if @effectivedate is NULL	
		set @effectivedate = getdate()

SELECT  @joinVal= Isnull(JoiningDate_Limit,0)
FROM T0050_AppraisalLimit_Setting SA WITH (NOLOCK) INNER JOIN
(
	SELECT isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_Id))effective_date
	FROM T0050_AppraisalLimit_Setting WITH (NOLOCK)
	WHERE Cmp_ID=@cmp_Id AND  ISNULL(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_Id)) <= @effectivedate
	--GROUP BY Limit_Id
)s ON s.effective_date = ISNULL(SA.effective_date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_Id))
WHERE SA.Cmp_ID = @cmp_Id 		
	--select @joinVal= JoiningDate_Limit from T0050_AppraisalLimit_Setting WHERE
	--				cmp_id=@cmp_Id and  isnull(Effective_Date,(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_Id)) = 
	--				(select isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER where Cmp_Id=@cmp_Id)) 
	--					from T0050_AppraisalLimit_Setting where cmp_id=@cmp_Id and effective_date<= @effectivedate)
CREATE TABLE #emp_table
(
	emp_id NUMERIC(18,0)
	,Emp_full_name VARCHAR(100) 
	,Alpha_Emp_code VARCHAR(50)
	,joindate DATETIME
	,dept_id NUMERIC(18,0)
	,desig_id NUMERIC(18,0)
	,branch_id NUMERIC(18,0)
	,grd_id	NUMERIC(18,0)
	,cmp_id NUMERIC(18,0)
	,Hod_id NUMERIC(18,0)
	,EmployeeName  VARCHAR(150) --22 Feb 2017
	,GH_Id	NUMERIC(18,0)  --22 Feb 2017
	,RM_id NUMERIC(18,0)--   Added by Deepali 7July22
	,RM_Name VARCHAR(100)--   Added by Deepali 7July22
)


INSERT INTO #emp_table (emp_id,Emp_full_name,Alpha_Emp_code,joindate,dept_id,desig_id,branch_id,grd_id,cmp_id,Hod_id,EmployeeName,GH_Id,RM_id,RM_Name)
SELECT E.Emp_ID,E.Emp_Full_Name,E.Alpha_Emp_Code,E.Date_Of_Join,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,E.cmp_id,DM.Emp_id,(E.Alpha_Emp_Code+'-'+E.Emp_Full_Name) ,GE.Emp_ID,
( select  top 1   r.R_Emp_ID from  T0090_EMP_REPORTING_DETAIL r  where r.Emp_id = E.Emp_ID and r.Cmp_ID = E.Cmp_ID order by r.Effect_Date), 
(select Alpha_Emp_Code+'-'+Emp_Full_Name from T0080_EMP_MASTER  where emp_id = ( select  top 1   r.R_Emp_ID from  T0090_EMP_REPORTING_DETAIL r  where r.Emp_id = E.Emp_ID and r.Cmp_ID = E.Cmp_ID order by r.Effect_Date desc))
FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
    (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
        FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
            (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
             FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
                    (
                        SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date ,EMP_ID 
                        FROM T0095_INCREMENT WITH (NOLOCK)
                        WHERE CMP_ID = @cmp_Id  AND Increment_Effective_Date <= @effectivedate
                        GROUP BY EMP_ID
                    ) inqry ON inqry.Emp_ID = T0095_INCREMENT.Emp_ID
             WHERE CMP_ID = @cmp_Id 
             GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
        WHERE I.Cmp_ID= @cmp_Id  
    )IE ON IE.Emp_ID = E.Emp_ID LEFT JOIN
	(
		SELECT T0095_Department_Manager.Dept_Id,Emp_id
		FROM T0095_Department_Manager WITH (NOLOCK) INNER JOIN
		(
			SELECT MAX(tran_id) tran_id,T0095_Department_Manager.Dept_Id
			FROM T0095_Department_Manager WITH (NOLOCK) INNER JOIN
			(
				SELECT MAX(Effective_Date)Effective_Date,Dept_Id
				FROM 	T0095_Department_Manager WITH (NOLOCK)
				WHERE Cmp_id = @cmp_Id and Effective_Date <= @effectivedate
				GROUP BY Dept_Id
			)DM2 ON DM2.Dept_Id = T0095_Department_Manager.Dept_Id 	
			GROUP BY T0095_Department_Manager.Dept_Id	
		)DM1 ON DM1.tran_id = T0095_Department_Manager.tran_id AND DM1.Dept_Id = T0095_Department_Manager.Dept_Id
	)DM ON DM.Dept_Id = IE.Dept_ID  LEFT JOIN
	T0080_EMP_MASTER GE WITH (NOLOCK) ON GE.Alpha_Emp_Code = isnull(E.Old_Ref_No,'')
WHERE CONVERT(DATETIME,E.Date_Of_Join,105) < CONVERT(DATETIME,DATEADD(MONTH,-@joinVal,GETDATE()),105) and E.Cmp_ID=@cmp_Id AND E.Emp_Left<>'Y'



--SELECT e.Emp_ID,E.Emp_Full_Name,e.Alpha_Emp_Code,E.Date_Of_Join,i.Dept_ID,i.Desig_Id,i.Branch_ID,i.Grd_ID,e.cmp_id,dm.Emp_id,(E.Alpha_Emp_Code+'-'+E.Emp_Full_Name) 
--FROM 
--T0080_EMP_MASTER E INNER JOIN
--T0095_INCREMENT I ON i.Increment_ID = 
--(SELECT max(Increment_ID) 
--FROM T0095_INCREMENT  WHERE emp_id=e.emp_id and Increment_Effective_Date=
--(SELECT max(Increment_Effective_Date) FROM T0095_INCREMENT WHERE emp_id=e.Emp_ID)) left JOIN
--T0095_Department_Manager DM on dm.Dept_Id = i.Dept_ID and dm.Effective_Date =(SELECT max(Effective_Date) FROM T0095_Department_Manager WHERE Dept_Id=i.dept_id )
--WHERE Date_Of_Join < DATEADD(MONTH,@joinVal,getdate()) and e.Cmp_ID=@cmp_Id and E.Emp_Left<>'Y'
--ORDER by E.Emp_ID

IF(@flag='add') --added to allow edit if Self Assessment not filled
BEGIN
	DELETE FROM #emp_table WHERE 
	EXISTS (SELECT emp_id FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Cmp_ID=@cmp_Id and isnull(Overall_Status,0)<>5
	and Emp_Id = #emp_table.emp_id)
	
	---added on 08/08/2017--------start
	DELETE FROM #emp_table WHERE
	EXISTS (SELECT emp_id FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Cmp_ID=@cmp_Id and isnull(Initiate_Status,0)<> 1
		AND Emp_Id = #emp_table.emp_id)	
	---added on 08/08/2017--------end

		---added on 08/08/2017--------start
	--Select * FROM #emp_table WHERE
	--EXISTS (SELECT emp_id FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Cmp_ID=@cmp_Id and Initiate_Status= 1
	--	AND Emp_Id = #emp_table.emp_id)	
	---added on 08/08/2017--------end
	
END

declare @query as varchar(max)

--set @query = 'select * from #emp_table where Emp_Id in (SELECT distinct emp_id FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Cmp_ID= '+ cast(@cmp_Id as VARCHAR)+' and Initiate_Status= 1)  and 
--			cmp_id='+ cast(@cmp_Id as VARCHAR)


set @query = 'select * from #emp_table where cmp_id='+ cast(@cmp_Id as VARCHAR)

IF @condition =''
	EXEC (@query + ' order by Alpha_Emp_code')
ELSE
	EXEC (@query + @condition + ' order by Alpha_Emp_code')
DROP TABLE #emp_table
 print @query

 print @condition
END
-----------------

