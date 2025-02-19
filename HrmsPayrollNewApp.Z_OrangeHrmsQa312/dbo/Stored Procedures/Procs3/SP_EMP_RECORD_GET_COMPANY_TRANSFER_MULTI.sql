
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_COMPANY_TRANSFER_MULTI]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC  = 0
	,@Cat_ID		NUMERIC  = 0  
	,@Grd_ID		NUMERIC  = 0
	,@Type_ID		NUMERIC  = 0
	,@Dept_ID		NUMERIC  = 0
	,@Desig_ID		NUMERIC  = 0
    ,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX) = ''
	,@Segment_ID NUMERIC  = 0 
	,@Vertical NUMERIC    = 0 
	,@SubVertical NUMERIC = 0 
	,@subBranch NUMERIC   = 0 
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = 0
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
		 
	IF @Type_ID = 0
		SET @Type_ID = NULL
		
	IF @Dept_ID = 0
		SET @Dept_ID = NULL
		
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
		
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Desig_ID = 0
		SET @Desig_ID = NULL
		
	IF @Segment_ID = 0 
		SET @Segment_ID = NULL
		
	IF @Vertical = 0
		SET @Vertical = NULL
		
	IF @SubVertical = 0
		SET @SubVertical  = NULL
	
	IF @subBranch = 0
		SET @subBranch = NULL
	
		
	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
  
	SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
		FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
	
	
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)      
	
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons
				SELECT CAST(DATA AS NUMERIC), CAST(DATA AS NUMERIC), CAST(DATA AS NUMERIC) FROM dbo.Split(@Constraint,'#') 
		END
	ELSE 
		BEGIN
			
			INSERT INTO #Emp_Cons			
				SELECT DISTINCT emp_id,V_Emp_Cons.branch_id,Increment_ID 
				FROM V_Emp_Cons 
				WHERE V_Emp_Cons.cmp_id=@Cmp_ID 				
					AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))      
					AND ISNULL(V_Emp_Cons.Branch_ID,0) = ISNULL(@Branch_ID ,ISNULL(V_Emp_Cons.Branch_ID,0))  
					AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)      
					AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0)) 
					AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
					AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
					AND ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,ISNULL(Segment_ID,0))
					AND ISNULL(Vertical_ID,0) = ISNULL(@Vertical,ISNULL(Vertical_ID,0))
					AND ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,ISNULL(SubVertical_ID,0))
					AND ISNULL(subBranch_ID,0) = ISNULL(@subBranch,ISNULL(subBranch_ID,0)) 
					AND ISNULL(Emp_Id,0) = ISNULL(@Emp_Id,ISNULL(Emp_Id,0)) 
					AND Increment_Effective_Date <= @To_Date 
					AND ((@From_Date >= join_Date AND  @From_Date <= left_date )      
						 OR(@To_Date  >= join_Date AND @To_Date <= left_date )      
						 OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						 OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						)
					ORDER BY Emp_ID
				
					
					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null
				
		END

		IF @Show_Left_Employee_for_Salary = 0 
			BEGIN
				SELECT e.Cmp_Id,e.Emp_Id,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,
						I_Q.Branch_ID,e.Vertical_ID,e.SubVertical_ID ,Emp_Left_Date,Emp_Left,E.Dept_ID  --Added By Jaina 23-09-2015 Dept_id
				FROM T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN 
					( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID  FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID
							GROUP BY emp_ID  ) Qry ON
							I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
							#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
					WHERE E.Cmp_ID = @Cmp_Id 
						AND	 ((@From_Date < E.Emp_LEft_Date AND @To_Date < E.Emp_LEft_Date) OR E.Emp_LEft_Date IS NULL)	
						AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons)
						ORDER BY  Emp_Code ASC
				End
		Else
			Begin

				SELECT e.Cmp_Id,e.Emp_Id,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,
						I_Q.Branch_ID,e.Vertical_ID,e.SubVertical_ID  ,Emp_Left_Date,Emp_Left,E.Dept_ID  --Added By Jaina 23-09-2015 Dept_id
				FROM T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN 
					( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID  FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID
							GROUP BY emp_ID  ) Qry ON
							I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
							#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
							

					WHERE E.Cmp_ID = @Cmp_Id 
						AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons)
						ORDER BY  Emp_Code ASC
				End


RETURN

