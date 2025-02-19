




CREATE PROCEDURE [dbo].[P0065_EMP_DOC_CHECKLIST_APP]
  	 @Emp_Tran_ID		AS BIGINT 
	,@Cmp_ID		AS INT 
	,@Branch_ID   INT        
	,@Cat_ID    INT         
	,@Grd_ID    INT        
	,@Type_ID    INT        
	,@Dept_ID    INT        
	,@Desig_ID    INT     
	,@constraint   VARCHAR(5000)   
	,@type VARCHAR(1) = 'O'     
		
AS
Declare @Emp_Cons TABLE        
 (        
	 Emp_Tran_ID BIGINT        
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
        
 IF @Emp_Tran_ID = 0          
	SET @Emp_Tran_ID = null     

DECLARE @to_date AS DATETIME
SET @to_date = GETDATE()         

 IF @Constraint <> ''        
  BEGIN        
		INSERT INTO @Emp_Cons(Emp_Tran_ID)        
		SELECT  cast(data  AS BIGINT) FROM dbo.Split (@Constraint,'#')         
  END        
 ELSE        
 BEGIN        
          
      INSERT INTO @Emp_Cons(Emp_Tran_ID)        
      SELECT I.Emp_Tran_ID from T0070_EMP_INCREMENT_APP I WITH (NOLOCK) LEFT JOIN         
			( SELECT MAX(Increment_Id) AS Increment_Id , Emp_Tran_ID From T0070_EMP_INCREMENT_APP  WITH (NOLOCK)      
			  WHERE Increment_Effective_date <= @To_Date  AND Cmp_ID = @Cmp_ID        
			 GROUP BY Emp_Tran_ID  ) Qry ON I.Emp_Tran_ID = Qry.Emp_Tran_ID and I.Increment_Id = Qry.Increment_Id         
      WHERE Cmp_ID = @Cmp_ID AND Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
				AND Branch_ID = isnull(@Branch_ID ,Branch_ID)        
			    AND Grd_ID = isnull(@Grd_ID ,Grd_ID)        
				AND isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
				AND Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
			    AND Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))        
				AND I.Emp_Tran_ID = isnull(@Emp_Tran_ID ,I.Emp_Tran_ID)   
         
 END     					



	IF @type = 'O'
		BEGIN
			SELECT DM.Doc_Name , case when EDD.Doc_Path is null then '0' else '1' end as Status 
				FROM T0040_DOCUMENT_MASTER DM WITH (NOLOCK)
			CROSS JOIN T0060_EMP_MASTER_APP EM WITH (NOLOCK)
			LEFT OUTER JOIN T0065_EMP_DOC_DETAIL_APP EDD WITH (NOLOCK)  ON EDD.DOC_ID = DM.DOC_ID AND EM.Emp_Tran_ID = EDD.Emp_Tran_ID
			INNER JOIN @Emp_Cons EC  on ec.Emp_Tran_ID = em.Emp_Tran_ID
			WHERE DM.CMP_ID = @Cmp_ID AND DOC_REQUIRED = 1 ORDER BY EM.Emp_Tran_ID,DM.DOC_ID
		END
	ELSE IF @type = 'D'
		BEGIN	
			SELECT ROW_NUMBER() OVER (ORDER BY EM.Emp_Tran_ID,DM.DOC_ID) as 'Sr_No'  ,Em.Alpha_Emp_Code as 'Emp_Code',Em.Emp_Full_Name as 'Emp_Name', Bm.Branch_Name , DMD.Dept_Name as 'Department_Name' ,  DESM.Desig_Name 'Designation_Master',DM.Doc_Name 'Document_Name' , case when EDD.Doc_Path is null then 'No' else 'Yes' end as 'Status' 
			FROM T0040_DOCUMENT_MASTER DM WITH (NOLOCK)
			CROSS JOIN T0060_EMP_MASTER_APP EM WITH (NOLOCK)
			LEFT OUTER JOIN T0065_EMP_DOC_DETAIL_APP EDD WITH (NOLOCK) ON EDD.DOC_ID = DM.DOC_ID AND EM.Emp_Tran_ID = EDD.Emp_Tran_ID
			INNER JOIN @Emp_Cons EC on ec.Emp_Tran_ID = em.Emp_Tran_ID
			INNER JOIN T0070_EMP_INCREMENT_APP i WITH (NOLOCK) on i.Emp_Tran_ID = ec.Emp_Tran_ID
			INNER JOIN ( SELECT MAX(Increment_Id) as Increment_Id , Emp_Tran_ID FROM T0070_EMP_INCREMENT_APP  WITH (NOLOCK)       
			WHERE Increment_Effective_date <= @To_Date        
			and Cmp_ID = @Cmp_ID        
			GROUP BY Emp_Tran_ID  ) Qry ON  Ec.Emp_Tran_ID = Qry.Emp_Tran_ID and I.Increment_Id = Qry.Increment_Id 			
			left outer join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = i.Branch_ID
			left outer join T0040_DEPARTMENT_MASTER DMD WITH (NOLOCK) ON DMD.Dept_Id = i.Dept_ID
			left outer join T0040_DESIGNATION_MASTER DESM WITH (NOLOCK) ON DESM.Desig_ID = i.Desig_Id
			WHERE DM.CMP_ID = @Cmp_ID  ORDER BY EM.Emp_Tran_ID,DM.DOC_ID
		END
 

RETURN




