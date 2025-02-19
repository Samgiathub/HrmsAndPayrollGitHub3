


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Get_Employee_HeadCount 9,''
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Employee_HeadCount]
	 @cmp_id as numeric(18,0)
	,@condition	varchar(800)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF @condition=''
		BEGIN
			SET @condition='where 1=1'
		END
		
	CREATE TABLE #HeadCount
	(
		 Branch_id		numeric(18,0)
		,Branch			varchar(100)
		,desig_id		numeric(18,0)
		,Designation	varchar(100)
		,dept_id		numeric(18,0)
		,Department		varchar(100)
		,TotalHeadCount	int
		,cmp_id			numeric(18,0)
	)
	CREATE TABLE #FinalHeadCount
	(
		 Branch_id		numeric(18,0)
		,Branch			varchar(100)
		,desig_id		numeric(18,0)
		,Designation	varchar(100)
		,dept_id		numeric(18,0)
		,Department		varchar(100)
		,TotalHeadCount	int
		,Employee		varchar(200)
		,emp_id			numeric(18,0)
		--,cat_id			numeric(18,0)
	)
	
	--cross join of branch,designation,dept
	INSERT INTO #HeadCount(Branch_id,Branch,dept_id,Department,desig_id,Designation)
	SELECT Branch_ID,Branch_Name,Dept_Id,Dept_Name,Desig_Id,Desig_Name
	FROM T0030_BRANCH_MASTER WITH (NOLOCK) CROSS JOIN
		 T0040_DEPARTMENT_MASTER WITH (NOLOCK) CROSS JOIN
		 T0040_DESIGNATION_MASTER WITH (NOLOCK)
	WHERE T0030_BRANCH_MASTER.Cmp_Id=@cmp_id AND T0040_DEPARTMENT_MASTER.Cmp_Id=@cmp_id AND T0040_DESIGNATION_MASTER.Cmp_Id=@cmp_id
	ORDER BY Branch_ID
	
	
	UPDATE #HeadCount
SET TotalHeadCount = up.cntemp
FROM
(select count(T.Emp_ID)cntemp,hc.Branch_id,hc.dept_id,hc.desig_id
	from #HeadCount HC inner JOIN
	(
	SELECT EM.Emp_ID,em.Alpha_Emp_Code,em.Emp_Full_Name,EM.Cmp_ID,IE.Branch_ID,IE.Desig_Id,IE.Dept_ID
	FROM T0080_EMP_MASTER  EM  WITH (NOLOCK) inner JOIN
		       (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
				FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
                (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
                 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
                        (
                                SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
                                FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
                        ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
                 WHERE CMP_ID = @cmp_id
                 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID
        WHERE I.Cmp_ID= @cmp_id 
			)IE on ie.Emp_ID = EM.Emp_ID
	WHERE emp_left<>'Y'	and em.Cmp_ID=@cmp_id --and IE.Branch_ID=@branchid and IE.Desig_Id = @desigid and IE.Dept_ID=@deptid
	)T ON t.Branch_ID = hc.Branch_id and t.Dept_ID = hc.dept_id and t.Desig_Id = hc.desig_id
	GROUP by HC.Branch_id,HC.desig_id,HC.dept_id
)up
WHERE #HeadCount.Branch_id=up.Branch_id and #HeadCount.dept_id=up.dept_id and #HeadCount.desig_id= up.desig_id


INSERT INTO #FinalHeadCount
	SELECT HC.Branch_id,HC.Branch,HC.desig_id,HC.Designation,HC.dept_id,HC.Department,HC.TotalHeadCount,(t.alpha_emp_code+'-'+t.Emp_Full_Name),T.Emp_ID
	FROM #HeadCount HC inner JOIN
	(
	SELECT EM.Emp_ID,em.Alpha_Emp_Code,em.Emp_Full_Name,EM.Cmp_ID,IE.Branch_ID,IE.Desig_Id,IE.Dept_ID
	FROM T0080_EMP_MASTER  EM WITH (NOLOCK)  inner JOIN
		       (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
				FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
                (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
                 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
                        (
                                SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
                                FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
                        ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
                 WHERE CMP_ID = @cmp_id
                 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID
        where I.Cmp_ID= @cmp_id 
			)IE on ie.Emp_ID = EM.Emp_ID
	Where emp_left<>'Y'	and em.Cmp_ID=@cmp_id 
	)T on t.Branch_ID = hc.Branch_id and t.Dept_ID = hc.dept_id and t.Desig_Id = hc.desig_id

declare @sqlquery as varchar(max)	

set @sqlquery	=	'Select  Case When row_number() OVER ( PARTITION BY branch_id  order by branch_id)  =1
						Then  cast(Branch  AS varchar(100)) Else '''' End Branch 	
						--,Branch		
						,Case When row_number() OVER ( PARTITION BY branch_id,dept_id order by branch_id,dept_id )  =1
						Then  cast(Department  AS varchar(100)) Else '''' End Department 
						--,Department			
						,Case When row_number() OVER ( PARTITION BY branch_id,dept_id,desig_id  order by branch_id,dept_id,desig_id )  =1
						Then  cast(Designation  AS varchar(100)) Else '''' End Designation 
						,Case When row_number() OVER ( PARTITION BY branch_id,dept_id,desig_id  order by branch_id,dept_id,desig_id )  =1
						Then  cast(TotalHeadCount  AS varchar(100)) Else '''' End TotalHeadCount 						
						,Employee		
						,emp_id		
				 From #FinalHeadCount '
	
exec (@sqlquery + @condition + ' order by Branch_id,dept_id,desig_id')
DROP TABLE #HeadCount
DROP TABLE #FinalHeadCount
END

