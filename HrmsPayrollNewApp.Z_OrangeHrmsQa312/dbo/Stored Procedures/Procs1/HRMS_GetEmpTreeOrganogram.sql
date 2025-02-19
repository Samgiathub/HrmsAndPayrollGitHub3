
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[HRMS_GetEmpTreeOrganogram]
	 @cmpid as numeric(18,0)
	,@parentid as numeric(18,0)=0
	,@branchid as numeric(18,0)=null
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

create table #final
(
     empid numeric(18,0)
    ,rid  numeric(18,0)
    ,rname varchar(100)
    ,ename varchar(800)
    ,desig numeric(18,0)
    ,branchId	numeric(18,0)
)

declare @empid as numeric(18,0)
declare @ename as varchar(100)
declare @rid as numeric(18,0)
declare @desig as numeric(18,0)

INSERT INTO #final (empid,rid,rname,ename,desig,branchId)
SELECT  em.emp_id,er.R_Emp_ID,'',
		'<table width="25%" style="background-color:FFF;border:0px solid #ECECEC;font-weight:normal;color:#000;
                    font-family:Verdana;font-size:11px;border-radius:5px;">
			<tr valign ="top" title="'+ dg.Desig_Name +'">
				<td valign ="top">
					<img src="../image_new/desig.png" height="20px"/>  
				</td>
				<td>
					<b> ' + (alpha_emp_code+'-'+Emp_Full_Name) + ' </b>
				</td>
				<td>
					(' + isnull(dg.Desig_Name,'')  + ')
				</td>
			</tr>
		</table>',
		IE.DESIG_ID ,IE.Branch_ID --(alpha_emp_code+'-'+Emp_Full_Name)as Emp_Full_Name
		FROM T0080_EMP_MASTER em WITH (NOLOCK)
		INNER JOIN	
		(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
		FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
			 FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
				(
					SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
					FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmpid GROUP BY EMP_ID
				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
			 WHERE CMP_ID = @cmpid
			 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
		WHERE I.Cmp_ID= @cmpid
		)IE ON ie.Emp_ID = em.Emp_ID LEFT JOIN 
		T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) on er.Emp_ID = em.Emp_ID INNER JOIN
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID 
			 from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) inner JOIN
				(select max(Effect_Date)Effect_Date,Emp_ID  
				  from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				 where Cmp_ID =@cmpid and Effect_Date <= getdate()
				GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID
			where Cmp_ID =@cmpid GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID LEFT JOIN
		T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = ie.Desig_Id
WHERE em.cmp_id=@cmpid  and em.Emp_Left<>'Y' 


CREATE TABLE #final1
(
	 empid numeric(18,0)
	,rid  numeric(18,0)
	,rname varchar(100)
	,ename varchar(800)
	,desig numeric(18,0)
	,childnodecount int
	,branchId	numeric(18,0)
)


IF @parentid <>0
	BEGIN
		INSERT INTO #final1
		SELECT DISTINCT #final.empid,#final.rid,rname,ename,desig,isnull(cnt,0) AS childnodecount,branchId FROM #final 
		LEFT JOIN 
		(
			SELECT COUNT(*)cnt,rid	
			FROM #final
			GROUP BY rid
		)t ON t.rid = #final.empid
		WHERE #final.rid = @parentid
		--order by #final.rid DESC
	END
ELSE
	BEGIN	
		--SELECT * FROM #final
		
		INSERT INTO #final1
		SELECT DISTINCT #final.empid,#final.rid,rname,ename,desig,isnull(cnt,0) as childnodecount,branchId from #final 
			LEFT JOIN 
			(
				SELECT COUNT(*)cnt,rid	
				FROM #final
				GROUP by rid
			)t on t.rid = #final.empid
		--WHERE #final.rid is null 
		UNION 			
		SELECT E.Emp_ID as empid,null as rid,'' as rname,
		'<table width="25%" style="background-color:FFF;border:0px solid #ECECEC;font-weight:normal;color:#000;
                    font-family:Verdana;font-size:11px;border-radius:5px;">
			<tr valign ="top" title="'+ dg.Desig_Name +'">
				<td valign ="top">
					<img src="../image_new/desig.png" height="20px"/>  
				</td>
				<td>
					<b> ' + (alpha_emp_code+'-'+Emp_Full_Name) + ' </b>
				</td>
				<td>
					' + isnull(dg.Desig_Name,'')  + '
				</td>
			</tr>
		</table>' as ename,
		IE.Desig_Id as desig,0 as childnodecount,IE.Branch_ID
		FROM T0080_EMP_MASTER E WITH (NOLOCK) LEFT JOIN
		#final on E.Emp_ID = empid  INNER JOIN	
		(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
		FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
			 FROM T0095_INCREMENT WITH (NOLOCK) INNER JOIN
				(
					SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
					FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmpid GROUP BY EMP_ID
				) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
			 WHERE CMP_ID = @cmpid
			 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
		WHERE I.Cmp_ID= @cmpid
		)IE ON ie.Emp_ID = e.Emp_ID LEFT JOIN
		T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = ie.Desig_Id
		where #final.empid IS NULL and 
		E.Cmp_ID=@cmpid and E.Emp_Left <> 'Y'
	END

	
	--SELECT * FROM #final --where branchId=606
	--SELECT * FROM #final1 where branchId=606
	
	DECLARE @sql AS VARCHAR(800)
	SET @sql = 'SELECT * FROM #final1 ORDER BY childnodecount desc'
	
	IF @branchid is not null
	SET	@sql = 'SELECT * FROM #final1 where branchId =' + cast(@branchid as varchar)+ ' ORDER BY childnodecount desc'
	
	EXEC(@sql)

END
DROP TABLE #final1
drop table #final
