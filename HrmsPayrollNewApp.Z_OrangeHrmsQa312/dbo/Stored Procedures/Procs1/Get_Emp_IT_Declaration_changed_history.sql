

-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <17/04/2015>
-- Description:	<Employee IT-Declaration Changed History>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Emp_IT_Declaration_changed_history]
	@cmp_ID numeric(18,0),
	@Financial_Year varchar(20),
	@From_Date datetime,
	@to_date datetime,
	@Branch_Contraint varchar(max) = '',
	@Department_Constraint varchar(max) = '',  --Added By Jaina 09-08-2016
    @Vertical_Constraint varchar(max) = '',    --Added By Jaina 09-08-2016
    @SubVertical_Contraint varchar(max) = ''   --Added By Jaina 09-08-2016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--Added By Jaina 09-08-2016 Start	
	IF 	@Branch_Contraint = '' or @Branch_Contraint ='0'
		set @Branch_Contraint = NULL
	
	IF @Vertical_Constraint = '' or @Vertical_Constraint='0'
		set @Vertical_Constraint = NULL
		
	IF @SubVertical_Contraint = '' or @SubVertical_Contraint='0'
		set @SubVertical_Contraint = NULL
	
	IF @Department_Constraint = '' or @Department_Constraint='0'
		set @Department_Constraint = NULL
		
	if @Branch_Contraint is null
	Begin	
		select   @Branch_Contraint = COALESCE(@Branch_Contraint + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @Branch_Contraint = @Branch_Contraint + '#0'
	End
	
	if @Vertical_Constraint is null
		Begin	
			select   @Vertical_Constraint = COALESCE(@Vertical_Constraint + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
			If @Vertical_Constraint IS NULL
				set @Vertical_Constraint = '0';
			else
				set @Vertical_Constraint = @Vertical_Constraint + '#0'		
		End
	ELSE
		set @Vertical_Constraint = @Vertical_Constraint + '#0'		

	if @SubVertical_Contraint is null
		Begin	
			select   @SubVertical_Contraint = COALESCE(@SubVertical_Contraint + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
			If @SubVertical_Contraint IS NULL
				set @SubVertical_Contraint = '0';
			else
				set @SubVertical_Contraint = @SubVertical_Contraint + '#0'
		End
	ELSE
		set @SubVertical_Contraint = @SubVertical_Contraint + '#0'

	IF @Department_Constraint is null
		Begin
			select   @Department_Constraint = COALESCE(@Department_Constraint + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		
			if @Department_Constraint is null
				set @Department_Constraint = '0';
			else
				set @Department_Constraint = @Department_Constraint + '#0'
		End
	ELSE
		set @Department_Constraint = @Department_Constraint + '#0'
	--Added By Jaina 09-08-2016 End
	
	
	CREATE TABLE #Branch(Branch_ID Numeric Primary Key)
	INSERT INTO #Branch
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@Branch_Contraint, '#') T	
	

	
	CREATE TABLE #Vertical(Vertical_ID Numeric Primary Key)
	INSERT INTO #Vertical
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@Vertical_Constraint, '#') T
	
	
	CREATE TABLE #SubVertical(SubVertical_ID Numeric Primary Key)
	INSERT INTO #SubVertical
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@SubVertical_Contraint, '#') T
	
	CREATE TABLE #Department(Dept_ID Numeric Primary Key)
	INSERT INTO #Department
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@Department_Constraint, '#') T

	SELECT E.EMP_ID,E.Alpha_Emp_Code,E.Emp_Full_Name
	INTO    #EMP_DATA
	from t0080_emp_master e WITH (NOLOCK)
	INNER JOIN (
								SELECT	EMP_ID, CMP_ID, BRANCH_ID,I1.Dept_ID,I1.Vertical_ID,I1.SubVertical_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								WHERE	I1.Increment_ID =(
															SELECT	MAX(INCREMENT_ID)
															FROM	T0095_INCREMENT I2 WITH (NOLOCK)
															WHERE	I2.Increment_Effective_Date = (
																			SELECT	MAX(Increment_Effective_Date)
																			FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																			WHERE	I3.Cmp_ID=I2.Cmp_ID AND
																					I3.Emp_ID=I2.Emp_ID And Cmp_ID=@cmp_ID
																		)															
																	AND I2.Cmp_ID=I1.Cmp_ID AND I2.Emp_ID=I1.Emp_ID
																	And Cmp_ID=@cmp_ID
														 )										
							) INC ON INC.Cmp_ID=e.Cmp_Id AND INC.Emp_ID=e.Emp_Id 				
				INNER JOIN #Branch B ON B.Branch_ID=INC.Branch_ID
				INNER JOIN #Vertical V ON V.Vertical_ID=Isnull(INC.Vertical_ID,0)
				INNER JOIN #SubVertical S ON S.SubVertical_ID=Isnull(INC.SubVertical_ID,0)
				INNER JOIN #Department D ON D.Dept_ID=Isnull(INC.Dept_ID,0)
		WHERE IsNull(E.EMP_LEFT_DATE, getdate()) >= GETDATE()
				 
	
    SET @TO_DATE = DATEADD(SS, -1, DATEADD(DD, 1, @TO_DATE)) --Added By Rajput 03042017
	--IF ISNULL(@Branch_Contraint, '') <> ''   --Comment By Jaina 11-08-2016
		SELECT	DISTINCT
				Alpha_Emp_Code,
				Emp_Full_Name,
				ED.Emp_ID,
				Financial_Year,
				CONVERT(VARCHAR(20),Qry.change_date,103) as Change_Date ,
				Is_Verified 
		FROM	T9999_IT_Employe_History ITE WITH (NOLOCK)
				inner join(
							SELECT	Emp_ID,MAX(System_date) as change_date 
							FROM	T9999_IT_Employe_History IT WITH (NOLOCK)
							WHERE	IT.cmp_ID = @cmp_ID and Financial_Year = @Financial_Year
									AND CONVERT(DATETIME,System_date,103) >= @From_date  
									AND CONVERT(DATETIME,System_date,103) <= @to_date
									
							GROUP BY Emp_ID
						   )qry on qry.emp_ID= ITE.Emp_ID and qry.change_date = ITE.System_date
				INNER JOIN #EMP_DATA ED ON ITE.Emp_Id=ED.Emp_ID
				--INNER JOIN (
				--				SELECT	EMP_ID, CMP_ID, BRANCH_ID,I1.Dept_ID,I1.Vertical_ID,I1.SubVertical_ID
				--				FROM	T0095_INCREMENT I1
				--				WHERE	I1.Increment_ID =(
				--											SELECT	MAX(INCREMENT_ID)
				--											FROM	T0095_INCREMENT I2
				--											WHERE	I2.Increment_Effective_Date = (
				--															SELECT	MAX(Increment_Effective_Date)
				--															FROM	T0095_INCREMENT I3
				--															WHERE	I3.Cmp_ID=I2.Cmp_ID AND
				--																	I3.Emp_ID=I2.Emp_ID And Cmp_ID=@cmp_ID
				--														)															
				--													AND I2.Cmp_ID=I1.Cmp_ID AND I2.Emp_ID=I1.Emp_ID
				--													And Cmp_ID=@cmp_ID
				--										 )										
				--			) INC ON INC.Cmp_ID=ITE.Cmp_Id AND INC.Emp_ID=ITE.Emp_Id 				
				--INNER JOIN #Branch B ON B.Branch_ID=INC.Branch_ID
				--INNER JOIN #Vertical V ON V.Vertical_ID=Isnull(INC.Vertical_ID,0)
				--INNER JOIN #SubVertical S ON S.SubVertical_ID=Isnull(INC.SubVertical_ID,0)
				--INNER JOIN #Department D ON D.Dept_ID=Isnull(INC.Dept_ID,0)

				--INNER JOIN  (
				--				SELECT	CAST(DATA AS NUMERIC) AS BRANCH_ID
				--				FROM	dbo.Split(@Branch_Contraint, '#')
				--			) BM ON INC.Branch_ID=BM.BRANCH_ID
		WHERE	ITE.cmp_ID = @cmp_ID AND Financial_Year = @Financial_Year AND Is_Verified = 0	
				--Added By Jaina 09-08-2016 Start
				--and EXISTS (select Data from dbo.Split(@Branch_Contraint, '#') B Where cast(B.data as numeric)=Isnull(INC.Branch_ID,0))
				--and EXISTS (select Data from dbo.Split(@Vertical_Constraint, '#') VE Where cast(VE.data as numeric)=Isnull(INC.Vertical_ID,0))
				--and EXISTS (select Data from dbo.Split(@SubVertical_Contraint, '#') S Where cast(S.data as numeric)=Isnull(INC.SubVertical_ID,0))
				--and EXISTS (select Data from dbo.Split(@Department_Constraint, '#') D Where cast(D.data as numeric)=Isnull(INC.Dept_ID,0))  --Logic Changed and "#Dept_Rights" table created to hadle the privilege : Nimesh (28-Dec-2017)
				--Added By Jaina 09-08-2016 End
				
	--Comment By Jaina 11-08-2016 Start
	--ELSE
	--	select distinct
	--		Alpha_Emp_Code,
	--		Emp_Full_Name,
	--		Qry.Emp_ID,
	--		Financial_Year,
	--		Convert(varchar(20),Qry.change_date,103) as Change_Date ,
	--		Is_Verified from T9999_IT_Employe_History ITE 
	--	Inner join T0080_EMP_MASTER EM on ITE.Emp_ID = EM.Emp_ID inner join
	--	(
	--			select Emp_ID,MAX(System_date) as change_date from T9999_IT_Employe_History IT where 
	--			IT.cmp_ID = @cmp_ID and Financial_Year = @Financial_Year
	--			and convert(datetime,System_date,103) >= @From_date and convert(datetime,System_date,103) <= @to_date
	--			Group by Emp_ID
	--	)qry on qry.emp_ID= ITE.Emp_ID and qry.change_date = ITE.System_date
	--	where ITE.cmp_ID = @cmp_ID and Financial_Year = @Financial_Year 
	--	and Is_Verified = 0
	--Comment By Jaina 11-08-2016 End
				
			--select distinct Alpha_Emp_Code,Emp_Full_Name,ITE.Emp_ID,Financial_Year,Convert(varchar(20),ITE.Change_Date,103) as Change_Date ,Is_Verified from T0110_IT_Emp_Details ITE 
			--Inner join T0080_EMP_MASTER EM on ITE.Emp_ID = EM.Emp_ID 
			--where ITE.cmp_ID = @cmp_ID and Financial_Year = @Financial_Year 
			--and convert(date,Change_Date,103) >= @From_date and convert(date,Change_Date,103) <= @to_date
			--and Is_Verified = 0
					
			
END

