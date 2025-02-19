


---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_EmpGoalSetting_SubmitList]
	 @cmp_id numeric(18,0)
	 ,@condition varchar(800)=''
	 ,@year as int 
	 ,@tablefetch as varchar(50) =''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	if @condition =''
	set @condition=' and 1=1'

	declare @query as varchar(max)
	
	CREATE table #Maintable
(
	 emp_id  numeric(18,0)
	,alpha_emp_code varchar(50)
	,emp_full_name varchar(500)
	,date_of_join datetime
	,grd_name	varchar(50)---04/05/2017
	,dept_name  varchar(50)
	,desig_name varchar(50)
	,reviewType varchar(50)
	,ManagerCode	varchar(50)---04/05/2017
	,ManagerName	varchar(50)---06/05/2017
	,estatus varchar(50)
)

if @tablefetch ='Employee Goal Setting'
begin
	set @query ='SELECT EG.Emp_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Date_of_Join,g.Grd_Name,d.Dept_Name,dg.Desig_Name,'''',ER.Alpha_Emp_Code,ER.Emp_Full_Name,
				Case when eg.EGS_Status = 0 then ''Draft'' 
					 when eg.EGS_Status = 1 then ''Send For Employee Review & Approval'' 
					 when eg.EGS_Status = 2 then ''Draft''
					 when eg.EGS_Status = 3 then ''Approved by Employee''
					 when eg.EGS_Status = 4 then ''Approved by Manager'' end
				FROM T0090_EmployeeGoalSetting EG WITH (NOLOCK)
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = EG.Emp_id
				INNER JOIN	
				(
					SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK)
								WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
								 GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
						 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= ' + cast(@cmp_id as varchar) + ' 
				)IE on ie.Emp_ID = e.Emp_ID  
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = IE.Dept_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = IE.Grd_ID
				LEFT JOIN T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = EG.Emp_ID INNER JOIN
				(
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)  INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
						GROUP BY Emp_ID	
					)ERD on ERD.Emp_ID  = T0090_EMP_REPORTING_DETAIL.Emp_ID
					WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID	
				)ERD1 on ERD1.Emp_ID = R.Emp_ID and R.Row_ID = ERD1.Row_ID LEFT JOIN
				T0080_EMP_MASTER ER WITH (NOLOCK) on er.Emp_ID = r.R_Emp_ID
	where EG.Cmp_Id=' + cast(@cmp_id as varchar) + ' and FinYear=' + cast(@year as VARCHAR)
end
else if @tablefetch ='Employee Goal Setting Review'
	BEGIN
		set @query ='SELECT EG.Emp_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Date_of_Join,g.Grd_Name,d.Dept_Name,dg.Desig_Name,case when Review_Type =2 then ''Final'' else ''Interim'' end,ER.Alpha_Emp_Code,ER.Emp_Full_Name,
				Case when eg.Review_Status = 0 then ''Draft'' 
					 when eg.Review_Status = 1 then ''Send For Employee Review & Approval'' 
					 when eg.Review_Status = 2 then ''Draft''
					 when eg.Review_Status = 3 then ''Approved by Employee''
					 when eg.Review_Status = 4 then ''Approved by Manager'' end
				FROM T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK)
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = EG.Emp_id
				INNER JOIN	
				(
					SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK)
								WHERE CMP_ID = ' + cast(@cmp_id as varchar) + ' 
								 GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = ' + cast(@cmp_id as varchar) + ' 
						 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= ' + cast(@cmp_id as varchar) + '  
				)IE on ie.Emp_ID = e.Emp_ID 
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = IE.Dept_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = IE.Grd_ID
				LEFT JOIN T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = EG.Emp_ID INNER JOIN
				(
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
						GROUP BY Emp_ID	
					)ERD on ERD.Emp_ID  = T0090_EMP_REPORTING_DETAIL.Emp_ID
					WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID	
				)ERD1 on ERD1.Emp_ID = R.Emp_ID and R.Row_ID = ERD1.Row_ID LEFT JOIN
				T0080_EMP_MASTER ER WITH (NOLOCK) on er.Emp_ID = r.R_Emp_ID
	where EG.Cmp_Id=' + cast(@cmp_id as varchar) + ' and FinYear=' + cast(@year as VARCHAR)
	END
ELSE IF @tablefetch ='Balance Score Card'
	BEGIN
		set @query ='SELECT EG.Emp_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Date_of_Join,g.Grd_Name,d.Dept_Name,dg.Desig_Name,'''',ER.Alpha_Emp_Code,ER.Emp_Full_Name,
				Case when eg.BSC_Status = 0 then ''Draft'' 
					 when eg.BSC_Status = 1 then ''Send For Employee Review & Approval'' 
					 when eg.BSC_Status = 2 then ''Draft''
					 when eg.BSC_Status = 3 then ''Approved by Employee''
					 when eg.BSC_Status = 4 then ''Approved by Manager'' end
				FROM T0090_BalanceScoreCard_Setting EG WITH (NOLOCK)
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = EG.Emp_id
				INNER JOIN	
				(
					SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK)
								WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
								 GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
						 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= ' + cast(@cmp_id as varchar) + ' 
				)IE on ie.Emp_ID = e.Emp_ID  
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = IE.Dept_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = IE.Grd_ID
				LEFT JOIN T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = EG.Emp_ID INNER JOIN
				(
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
						GROUP BY Emp_ID	
					)ERD on ERD.Emp_ID  = T0090_EMP_REPORTING_DETAIL.Emp_ID
					WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID	
				)ERD1 on ERD1.Emp_ID = R.Emp_ID and R.Row_ID = ERD1.Row_ID LEFT JOIN
				T0080_EMP_MASTER ER WITH (NOLOCK) on er.Emp_ID = r.R_Emp_ID
		where EG.Cmp_Id=' + cast(@cmp_id as varchar) + ' and FinYear=' + cast(@year as VARCHAR)
	END
ELSE IF @tablefetch ='Balance Score Card Review'
	BEGIN
		set @query ='SELECT EG.Emp_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Date_of_Join,g.Grd_Name,d.Dept_Name,dg.Desig_Name,case when Review_Type =2 then ''Final'' else ''Interim'' end,ER.Alpha_Emp_Code,ER.Emp_Full_Name,
				Case when eg.Review_Status = 0 then ''Draft'' 
					 when eg.Review_Status = 1 then ''Send For Employee Review & Approval'' 
					 when eg.Review_Status = 2 then ''Draft''
					 when eg.Review_Status = 3 then ''Approved by Employee''
					 when eg.Review_Status = 4 then ''Approved by Manager'' end
				FROM T0095_BalanceScoreCard_Evaluation EG WITH (NOLOCK)
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = EG.Emp_id
				INNER JOIN	
				(
					SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
					FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
						(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
						 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
							(
								SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
								FROM T0095_INCREMENT WITH (NOLOCK)
								WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
								 GROUP BY EMP_ID
							) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
						 WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
						 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
					where I.Cmp_ID= ' + cast(@cmp_id as varchar) + ' 
				)IE on ie.Emp_ID = e.Emp_ID 
				LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = IE.Dept_ID
				LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id
				LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = IE.Grd_ID
				LEFT JOIN T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = EG.Emp_ID INNER JOIN
				(
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
						GROUP BY Emp_ID	
					)ERD on ERD.Emp_ID  = T0090_EMP_REPORTING_DETAIL.Emp_ID
					WHERE Cmp_ID = ' + cast(@cmp_id as varchar) + '
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID	
				)ERD1 on ERD1.Emp_ID = R.Emp_ID and R.Row_ID = ERD1.Row_ID LEFT JOIN
				T0080_EMP_MASTER ER WITH (NOLOCK) on er.Emp_ID = r.R_Emp_ID
		where EG.Cmp_Id=' + cast(@cmp_id as varchar) + ' and FinYear=' + cast(@year as VARCHAR)
	END

INSERT INTO #Maintable
exec (@query +  @condition)

--print @query

set @query ='select E.emp_id,E.Alpha_Emp_Code,E.Emp_Full_Name,E.Date_of_Join,g.Grd_Name,d.Dept_Name,dg.Desig_Name,'''',ER.Alpha_Emp_Code,ER.Emp_Full_Name,''Not Submitted'' from T0080_EMP_MASTER E WITH (NOLOCK)
INNER JOIN	
	(
		SELECT  I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
		FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , T0095_INCREMENT.EMP_ID 
			 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
				(
					SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
					FROM T0095_INCREMENT WITH (NOLOCK)
					WHERE CMP_ID = ' + cast(@cmp_id as varchar) + '
					 GROUP BY EMP_ID
				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
			 WHERE CMP_ID =' + cast(@cmp_id as varchar) + '
			 GROUP BY T0095_INCREMENT.EMP_ID  ) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
		where I.Cmp_ID= ' + cast(@cmp_id as varchar) + '
	)IE on ie.Emp_ID = e.Emp_ID 
LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on D.Dept_Id = IE.Dept_ID
LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = IE.Desig_Id
LEFT JOIN T0040_GRADE_MASTER G WITH (NOLOCK) on g.Grd_ID = IE.Grd_ID
LEFT JOIN	(select R.Row_ID,R.Effect_Date,ERD1.Emp_ID,R.R_Emp_ID from T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) INNER JOIN
				
					(SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) INNER JOIN
					(
						SELECT MAX(Effect_Date)Effect_Date,Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						WHERE Cmp_ID =  ' + cast(@cmp_id as varchar) + '
						GROUP BY Emp_ID	
					)ERD on ERD.Emp_ID  = T0090_EMP_REPORTING_DETAIL.Emp_ID
					WHERE Cmp_ID =  ' + cast(@cmp_id as varchar) + '
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID	
				)ERD1 on ERD1.Emp_ID = R.Emp_ID and R.Row_ID = ERD1.Row_ID
				)erd2 on erd2.Emp_ID = E.Emp_ID LEFT JOIN
				T0080_EMP_MASTER ER WITH (NOLOCK) on er.Emp_ID = erd2.R_Emp_ID
where not exists (select emp_id from #Maintable MT  Where MT.emp_id=e.emp_id )and e.Cmp_ID = '+ cast(@cmp_id as varchar)
+' and E.Emp_Left <>''Y'''

--print @query


INSERT INTO #Maintable
exec (@query +  @condition)

IF @tablefetch ='Employee Goal Setting Review' OR @tablefetch ='Balance Score Card Review'
	BEGIN
		SELECT DISTINCT alpha_emp_code as 'Employee Code',
				emp_full_name  as 'Employee Name' ,
				CONVERT(varchar(15),date_of_join,105)   as 'Joining Date',
				grd_name	   as 'Grade Name',
				dept_name	   as 'Department Name',
				desig_name	   as 'Designation Name',
				ManagerCode		   as 'Manager Code',
				ManagerName		   as 'Manager Name',
				reviewType	   as 'Review Type',	
				estatus		   as 'Status'
		FROM #Maintable ORDER BY estatus
	END
ELSE
	BEGIN
		SELECT DISTINCT alpha_emp_code as 'Employee Code',
				emp_full_name  as 'Employee Name' ,
				CONVERT(varchar(15),date_of_join,105)   as 'Joining Date',
				grd_name	   as 'Grade Name',
				dept_name	   as 'Department Name',
				desig_name	   as 'Designation Name',
				ManagerCode		   as 'Manager Code',
				ManagerName		   as 'Manager Name',
				estatus		   as 'Status'
		FROM #Maintable ORDER BY estatus
	END

drop table #Maintable
  
END
