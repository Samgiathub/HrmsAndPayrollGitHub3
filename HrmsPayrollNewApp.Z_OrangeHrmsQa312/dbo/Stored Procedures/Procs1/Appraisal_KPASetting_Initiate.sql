---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Appraisal_KPASetting_Initiate]
	 @cmp_Id  numeric(18,0) 
	,@condition varchar(800)=''
	,@effectivedate datetime =null
	,@flag int = 0
	,@Dur_From_Month varchar(15)
	,@Dur_To_Month varchar(15)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	DECLARE @joinVal int;
	
	IF @effectivedate is NULL	
		SET @effectivedate = getdate()
	
	SELECT  @joinVal= JoiningDate_Limit
	FROM T0050_AppraisalLimit_Setting SA WITH (NOLOCK) INNER JOIN
	(
		SELECT isnull(max(Effective_Date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_Id))effective_date
		FROM T0050_AppraisalLimit_Setting WITH (NOLOCK)
		WHERE Cmp_ID=@cmp_Id AND  ISNULL(Effective_Date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_Id)) <= @effectivedate
		
	)s ON s.effective_date = ISNULL(SA.effective_date,(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_Id))
	WHERE SA.Cmp_ID = @cmp_Id 	
	
	
	CREATE TABLE #emp_table
	(
		emp_id NUMERIC(18,0)
		,Emp_full_name VARCHAR(100) 
		,Alpha_Emp_code VARCHAR(50)
		,EmployeeName  VARCHAR(150) 
		,joindate DATETIME
		,dept_id NUMERIC(18,0)
		,desig_id NUMERIC(18,0)
		,branch_id NUMERIC(18,0)
		,grd_id	NUMERIC(18,0)
		,cmp_id NUMERIC(18,0)
		,Hod_id NUMERIC(18,0)		
		,GH_Id	NUMERIC(18,0) 
        ,RM_id NUMERIC(18,0)--   Added by Deepali 7July22
	    ,RM_Name VARCHAR(100)--   Added by Deepali 7July22
	)
	
	INSERT INTO #emp_table
	SELECT E.Emp_ID,E.Emp_Full_Name,E.Alpha_Emp_Code,(E.Alpha_Emp_Code +'-'+ E.Emp_Full_Name),E.Date_Of_Join
	      ,I.Dept_ID,I.Desig_ID,I.Branch_ID,I.Grd_ID,E.Cmp_ID,DM.Emp_id,0,
		  ( select  top 1   r.R_Emp_ID from  T0090_EMP_REPORTING_DETAIL r  where r.Emp_id = E.Emp_ID and r.Cmp_ID = E.Cmp_ID order by r.Effect_Date), (select Alpha_Emp_Code+'-'+Emp_Full_Name from T0080_EMP_MASTER e1 where emp_id = ( select  top 1   r.R_Emp_ID from  T0090_EMP_REPORTING_DETAIL r  where r.Emp_id = E.Emp_ID and r.Cmp_ID = E.Cmp_ID order by r.Effect_Date))

		 -- (select Alpha_Emp_Code+'-'+Emp_Full_Name from T0080_EMP_MASTER  E1 where E1.emp_id = isnull( E.Emp_Superior, (Select TOP 1 ERD.R_Emp_ID  from T0090_EMP_REPORTING_DETAIL ERD INNER JOIN (select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WHERE Effect_Date<=GETDATE() GROUP BY emp_ID) RQry on ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date Where ERD.Emp_ID=E.Emp_ID and ERD.Cmp_ID=@cmp_Id ORDER BY ERD.ROW_ID DESC)))
	FROM T0080_EMP_MASTER E WITH (NOLOCK) 
	INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID
	INNER JOIN (
					SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
					FROM T0095_INCREMENT WITH (NOLOCK)
						INNER JOIN(
										SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
										FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE Cmp_ID <= @cmp_Id AND Increment_Effective_Date <= @effectivedate
										GROUP BY Emp_ID
						           )I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
					WHERE Cmp_ID <= @cmp_Id
					GROUP BY T0095_INCREMENT.Emp_ID
				)I1 ON I1.Emp_ID = i.Emp_ID and I1.Increment_ID = I.Increment_ID	
	LEFT JOIN
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
	)DM ON DM.Dept_Id = I.Dept_ID
	WHERE E.Cmp_ID = @cmp_Id --AND CONVERT(DATETIME,E.Date_Of_Join,105) < CONVERT(DATETIME,DATEADD(MONTH,-@joinVal,GETDATE()),105) 
	AND E.Emp_Left<>'Y'
	

	--select * from #emp_table where emp_id=25260
	IF(@flag=0)
	BEGIN
		--DELETE FROM #emp_table WHERE 
		--EXISTS (SELECT emp_id FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Cmp_ID=@cmp_Id and isnull(Overall_Status,0)<>5
		--and Emp_Id = #emp_table.emp_id)	
		
		---added on 08/08/2017--------start
		DELETE FROM #emp_table
		WHERE EXISTS (SELECT emp_id FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) WHERE Cmp_ID=@cmp_Id and isnull(Initiate_Status,0)<> 1
		--AND Duration_FromMonth=@Dur_From_Month AND Duration_ToMonth=@Dur_To_Month	
		AND Emp_Id = #emp_table.emp_id)	
		---added on 08/08/2017--------end

		--DELETE FROM #emp_table
		--WHERE EXISTS (SELECT emp_id FROM T0055_Hrms_Initiate_KPASetting WHERE Cmp_ID=@cmp_Id 
		--AND Duration_FromMonth=@Dur_From_Month AND Duration_ToMonth=@Dur_To_Month	AND Emp_Id = #emp_table.emp_id)	
	END
	
DECLARE @query as VARCHAR(max)

SET @query = 'select * from #emp_table where cmp_id='+ cast(@cmp_Id as VARCHAR)

IF @condition =''
	EXEC (@query + ' order by Alpha_Emp_code')
ELSE
	EXEC (@query + @condition + ' order by Alpha_Emp_code')
	print @query + @condition + ' order by Alpha_Emp_code'
DROP TABLE #emp_table
END

