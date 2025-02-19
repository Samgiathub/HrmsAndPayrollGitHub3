




CREATE PROCEDURE [dbo].[P0090_EMP_DOC_CHECKLIST]
  	 @Emp_ID		AS NUMERIC 
	,@Cmp_ID		AS NUMERIC 
	,@Branch_ID   NUMERIC        
	,@Cat_ID    NUMERIC         
	,@Grd_ID    NUMERIC        
	,@Type_ID    NUMERIC        
	,@Dept_ID    NUMERIC        
	,@Desig_ID    NUMERIC     
	,@constraint   VARCHAR(MAX)   
	,@type VARCHAR(1) = 'O'     
		
AS
DECLARE @Emp_Cons TABLE        
 (        
	Emp_ID NUMERIC        
 )        
 
 
  IF @Branch_ID = 0          
	SET @Branch_ID = null        
          
 IF @Cat_ID = 0          
	SET @Cat_ID = null        
        
 IF @Grd_ID = 0          
	SET @Grd_ID = null        
        
 IF @Type_ID = 0          
	SET @Type_ID = null        
        
 IF @Dept_ID = 0          
	SET @Dept_ID = null        
        
 IF @Desig_ID = 0          
	SET @Desig_ID = null        
        
 IF @Emp_ID = 0          
	SET @Emp_ID = null     

DECLARE @to_date AS DATETIME

SET @to_date = GETDATE()         

 IF @Constraint <> ''        
  BEGIN        
		INSERT INTO @Emp_Cons(Emp_ID)        
		SELECT  cast(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#')         
  END        
 ELSE        
  BEGIN   
      INSERT INTO @Emp_Cons(Emp_ID)        
      SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN         
		( SELECT MAX(Increment_Id) as Increment_Id , Emp_ID From T0095_Increment WITH (NOLOCK)        
			WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID        
			GROUP BY emp_ID  ) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id         
      WHERE Cmp_ID = @Cmp_ID  AND Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
			AND Branch_ID = isnull(@Branch_ID ,Branch_ID)        
			AND Grd_ID = isnull(@Grd_ID ,Grd_ID)        
			AND isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
			AND Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
			AND Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
			AND I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)   
         
  END     					

  

	IF @type = 'O'
		BEGIN
			SELECT DM.Doc_Name , case when EDD.Doc_Path is null then '0' else '1' end as Status 
			FROM T0040_DOCUMENT_MASTER DM WITH (NOLOCK)
			CROSS JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
			LEFT OUTER JOIN T0090_EMP_DOC_DETAIL EDD WITH (NOLOCK)  ON EDD.DOC_ID = DM.DOC_ID AND EM.EMP_ID = EDD.EMP_ID
			inner join @Emp_Cons EC on ec.Emp_ID = em.Emp_ID
			WHERE DM.CMP_ID = @Cmp_ID AND DOC_REQUIRED = 1 ORDER BY EM.EMP_ID,DM.DOC_ID
		END
	ELSE IF @type = 'D'
		BEGIN	
			SELECT ROW_NUMBER() OVER (ORDER BY EM.EMP_ID,DM.DOC_ID) as 'Sr_No'  ,Em.Alpha_Emp_Code as 'Emp_Code',Em.Emp_Full_Name as 'Emp_Name', Bm.Branch_Name , DMD.Dept_Name as 'Department_Name' ,  DESM.Desig_Name 'Designation_Master',DM.Doc_Name 'Document_Name' , case when EDD.Doc_Path is null then 'No' else 'Yes' end as 'Status' 
			FROM T0040_DOCUMENT_MASTER DM WITH (NOLOCK)
			CROSS JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
			LEFT OUTER JOIN T0090_EMP_DOC_DETAIL EDD WITH (NOLOCK) ON EDD.DOC_ID = DM.DOC_ID AND EM.EMP_ID = EDD.EMP_ID
			INNER JOIN @Emp_Cons EC on ec.Emp_ID = em.Emp_ID
			INNER JOIN T0095_INCREMENT i WITH (NOLOCK) on i.Emp_ID = ec.Emp_ID
			INNER JOIN ( SELECT MAX(Increment_Id) as Increment_Id , Emp_ID From T0095_Increment WITH (NOLOCK)        
						WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID        
						GROUP BY emp_ID  ) Qry ON        
						Ec.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id 			
			left outer join T0030_BRANCH_MASTER BM WITH (NOLOCK) on Bm.Branch_ID = i.Branch_ID
			left outer join T0040_DEPARTMENT_MASTER DMD WITH (NOLOCK) on DMD.Dept_Id = i.Dept_ID
			left outer join T0040_DESIGNATION_MASTER DESM WITH (NOLOCK) on DESM.Desig_ID = i.Desig_Id
			WHERE DM.CMP_ID = @Cmp_ID  ORDER BY EM.EMP_ID,DM.DOC_ID
		end
 

RETURN




