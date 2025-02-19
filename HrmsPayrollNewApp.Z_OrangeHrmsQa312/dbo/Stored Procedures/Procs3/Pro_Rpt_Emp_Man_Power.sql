

---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Pro_Rpt_Emp_Man_Power]
	@Cmp_Id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@R_Type        tinyint = 1
	,@R_All_Join    tinyint = 1
	,@Cat_ID        numeric = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
  CREATE table #Emp_Cons 
  (      
    Emp_ID numeric ,     
    Branch_ID numeric,
    Increment_ID numeric    
  )  
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons
			SELECT cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) FROM dbo.Split(@Constraint,'#') 
		END
	
	If @R_All_Join = 1   -- ALL
	Begin
		if @R_Type = 1   -- Type
		Begin
		
					SELECT T.Type_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_TYPE_MASTER AS T WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Type_ID = T.Type_ID INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE T.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
						AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
						And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  T.Type_Name
		
		End
		Else If @R_Type = 2  -- Grade
		Begin
		
				SELECT G.Grd_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_Grade_MASTER AS G WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Grd_ID = G.Grd_ID INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE G.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  G.Grd_Name
		
		End
		Else If @R_Type = 3  -- Designation
		Begin
					SELECT D.Desig_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_Designation_MASTER AS D WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID,Desig_Id FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Desig_Id = D.Desig_Id INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE D.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  D.Desig_Name
		End
		Else If @R_Type = 4  -- Department
		Begin
					SELECT DISTINCT D.Dept_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0080_EMP_MASTER AS E WITH (NOLOCK) INNER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID,Desig_Id,Dept_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Emp_ID = E.Emp_ID INNER JOIN 
						dbo.T0040_Department_MASTER D WITH (NOLOCK) on QRY1.Dept_ID = D.Dept_ID
					WHERE E.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  D.Dept_Name
					
					
					--SELECT D.Dept_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
					--	COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					--FROM     
					--	T0040_Department_MASTER AS D 	LEFT OUTER JOIN
					--	(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID,Desig_Id,Dept_ID FROM dbo.T0095_INCREMENT I inner join 
					--	( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT  --Changed by Hardik 10/09/2014 for Same Date Increment
					--		where Increment_Effective_date <= @To_Date
					--		and Cmp_ID = @Cmp_Id
					--		group by emp_ID  ) Qry on
					--	I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
					--	ON  QRY1.Dept_Id = D.Dept_Id INNER JOIN 
					--	dbo.T0080_EMP_MASTER E on QRY1.emp_ID = E.Emp_ID
					--WHERE D.Cmp_ID = @Cmp_Id And E.Emp_Left <> 'Y' AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					--And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					--GROUP BY  D.Dept_Name
		End
		Else If @R_Type = 5  -- Branch
		Begin
					SELECT B.Branch_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0030_Branch_MASTER AS B WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Branch_ID = B.Branch_Id INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE B.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  B.Branch_Name
		End
	End
	Else If @R_All_Join = 2
	Begin
		if @R_Type = 1   -- Type
		Begin
		
					SELECT T.Type_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_TYPE_MASTER AS T WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Type_ID = T.Type_ID INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE T.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					AND E.Date_Of_Join >= @From_Date AND E.Date_Of_Join <= @To_Date
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  T.Type_Name
		
		End
		Else If @R_Type = 2  -- Grade
		Begin
		
				SELECT G.Grd_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_Grade_MASTER AS G WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Grd_ID = G.Grd_ID INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE G.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					AND E.Date_Of_Join >= @From_Date AND E.Date_Of_Join <= @To_Date
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  G.Grd_Name
		
		End
		Else If @R_Type = 3  -- Designation
		Begin
					SELECT D.Desig_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_Designation_MASTER AS D WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID,Desig_Id FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Desig_Id = D.Desig_Id INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE D.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					AND E.Date_Of_Join >= @From_Date AND E.Date_Of_Join <= @To_Date
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  D.Desig_Name
		End
		Else If @R_Type = 4  -- Department
		Begin
					SELECT D.Dept_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0040_Department_MASTER AS D WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID,Desig_Id,Dept_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Dept_Id = D.Dept_Id INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE D.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y' 
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					AND E.Date_Of_Join >= @From_Date AND E.Date_Of_Join <= @To_Date
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  D.Dept_Name
		End
		Else If @R_Type = 5  -- Branch
		Begin
					SELECT B.Branch_Name As Status,COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Male, 
						COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) AS Female, COUNT(E.Emp_ID) AS Total
					FROM     
						T0030_Branch_MASTER AS B WITH (NOLOCK)	LEFT OUTER JOIN
						(SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID FROM dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id)QRY1
						ON  QRY1.Branch_ID = B.Branch_Id INNER JOIN 
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on QRY1.emp_ID = E.Emp_ID
					WHERE B.Cmp_ID = @Cmp_Id --And E.Emp_Left <> 'Y'
					AND QRY1.Branch_ID = ISNULL(NULL,QRY1.Branch_ID)
					AND E.Date_Of_Join >= @From_Date AND E.Date_Of_Join <= @To_Date
					And E.Emp_ID in (select Emp_ID From #Emp_Cons)
					GROUP BY  B.Branch_Name
		End
		
	END	
	
END


