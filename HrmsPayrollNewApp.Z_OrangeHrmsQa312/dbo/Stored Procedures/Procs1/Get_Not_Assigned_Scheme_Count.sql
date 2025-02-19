

--EXEC Get_Not_Assigned_Scheme_Count 149, '2016-11-28'
-- =============================================
-- Author:		<Jaina>
-- Create date: <25-11-2016>
-- Description:	<Not Assign Employee Count Scheme Wise>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Not_Assigned_Scheme_Count]
		@CMP_ID			NUMERIC(18,0),
		@PBranch_ID	varchar(max)= '', 
		@PVertical_ID	varchar(max)= '', 
		@PSubVertical_ID	varchar(max)= '', 
		@PDept_ID varchar(max)=''  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	IF @PBranch_ID = '0' or @PBranch_ID='' 
		set @PBranch_ID = null   	
	
	if @PVertical_ID ='0' or @PVertical_ID = ''		
		set @PVertical_ID = null
	
	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	
		set @PsubVertical_ID = null
	
	IF @PDept_ID = '0' or @PDept_Id=''  
		set @PDept_ID = NULL	 


	
	if @PBranch_ID is null
		Begin	
			select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
			IF @PBranch_ID is null
				set @PBranch_ID = '0';
			else
				set @PBranch_ID = @PBranch_ID + ',0'
		End	
	
	
		
	if @PVertical_ID is null
		Begin	
			select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
			If @PVertical_ID IS NULL
				set @PVertical_ID = '0';
			else
				set @PVertical_ID = @PVertical_ID + ',0'	
		End
	ELSE 
		SET @PVertical_ID = @PVertical_ID + ',0'	

	
	
	if @PsubVertical_ID is null
		Begin	
			select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
			If @PsubVertical_ID IS NULL
				set @PsubVertical_ID = '0';
			else
				set @PsubVertical_ID = @PsubVertical_ID + ',0'
		End
	ELSE
		set @PsubVertical_ID = @PsubVertical_ID + ',0'

	
	IF @PDept_ID is null
		Begin
			select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
			if @PDept_ID is null
				set @PDept_ID = '0';
			else
				set @PDept_ID = @PDept_ID + ',0'	
		End
	ELSE
		set @PDept_ID = @PDept_ID + ',0'	

	
	CREATE TABLE #Branch(Branch_ID Numeric Primary Key)
	INSERT INTO #Branch
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@PBranch_ID, ',') T	

	CREATE TABLE #Vertical(Vertical_ID Numeric Primary Key)
	INSERT INTO #Vertical
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@PVertical_ID, ',') T

	CREATE TABLE #SubVertical(SubVertical_ID Numeric Primary Key)
	INSERT INTO #SubVertical
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@PsubVertical_ID, ',') T


	CREATE TABLE #Department(Dept_ID Numeric Primary Key)	
	INSERT INTO #Department
	SELECT	CAST(DATA AS NUMERIC) FROM dbo.Split(@PDept_ID, ',') T
	
			CREATE table #Emp_Cons 
			(
				Emp_ID	NUMERIC,
				Branch_Id numeric
			);
	
							  
			INSERT INTO #Emp_Cons(Emp_ID,Branch_Id)
			SELECT I.Emp_Id,I.Branch_ID 
				FROM T0095_Increment I WITH (NOLOCK)
					INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID  
									FROM T0095_Increment I2 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
													FROM	T0095_INCREMENT I3 WITH (NOLOCK)
													WHERE	I3.Increment_Effective_Date <= GETDATE()
													GROUP BY I3.Emp_ID
													) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
									GROUP BY i2.emp_ID 
								) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.Emp_ID=E.Emp_ID
					INNER JOIN #Branch B ON B.Branch_ID=I.Branch_ID
					INNER JOIN #Vertical V ON V.Vertical_ID=Isnull(I.Vertical_ID,0)
					INNER JOIN #SubVertical S ON S.SubVertical_ID=Isnull(I.SubVertical_ID,0)
					INNER JOIN #Department D ON D.Dept_ID=Isnull(I.Dept_ID,0)
				WHERE I.Cmp_ID = @Cmp_ID AND IsNull(E.Emp_Left_Date, GETDATE()) >= GETDATE()
					--Added By Jaina 14-10-2015 start   					
					--and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
					--and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
					--and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
					--and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
					--Added By Jaina 14-10-2015 end
			
			
		IF OBJECT_ID('tempdb..#Scheme_Type') IS NULL		
		CREATE table #Scheme_Type 
		(
			Scheme_Type  varchar(250),
			Emp_count bigint default 0
		);
		Insert INTO #Scheme_Type (Scheme_Type)
		SELECT DISTINCT Scheme_Type FROM T0040_Scheme_Master WITH (NOLOCK) where Cmp_Id=@Cmp_Id
		
		
		
		--SELECT  ST.Scheme_Type, COUNT(1) AS EMP_COUNT
		--FROM	#Emp_Cons E CROSS JOIN #Scheme_Type ST
		--WHERE	NOT EXISTS(SELECT 1 FROM T0095_EMP_SCHEME ES 
		--							LEFT OUTER JOIN T0040_Scheme_Master SM ON ES.Scheme_ID=SM.Scheme_Id
		--				   WHERE E.Emp_ID=ES.Emp_ID AND SM.Scheme_Type=ST.Scheme_Type)
		--GROUP BY ST.Scheme_Type
		--ORDER BY ST.Scheme_Type	
		
		--SELECT  ST.Scheme_Type, COUNT(1) AS EMP_COUNT
		--FROM	#Emp_Cons E CROSS JOIN #Scheme_Type ST
		--WHERE	NOT EXISTS(SELECT 1 FROM T0095_EMP_SCHEME ES 
		--							INNER JOIN T0040_Scheme_Master SM ON ES.Scheme_ID=SM.Scheme_Id
		--							INNER JOIN
		--							(	
		--								select max(effective_date) as effective_date,emp_id 
		--								from T0095_EMP_SCHEME IES INNER JOIN
		--									#Scheme_Type s ON s.Scheme_Type=IES.Type
		--									where IES.effective_date <= GETDATE()  AND Cmp_ID = @Cmp_Id 
		--									--AND Type = @Scheme_Name
		--								GROUP by emp_id 
		--							) Tbl1 ON Tbl1.Emp_ID = ES.Emp_ID AND Tbl1.effective_date = ES.Effective_Date 
		--							INNER JOIN #Scheme_Type s ON s.Scheme_Type = ES.Type
		--				   WHERE E.Emp_ID=ES.Emp_ID AND SM.Scheme_Type=ST.Scheme_Type)
		--GROUP BY ST.Scheme_Type
		--ORDER BY ST.Scheme_Type	
						  
						  
								
	Declare @Scheme_Name varchar(250)
				
	DECLARE Cursor_Scheme cursor for		
		select Scheme_Type from #Scheme_Type
	OPEN Cursor_Scheme 					
			Fetch next from Cursor_Scheme into @Scheme_Name
									 
	While @@fetch_status = 0                    
	Begin 
		
		update #Scheme_Type SET Emp_count = Ec.Emp_count
		from #Scheme_Type S inner JOIN
			(Select COUNT(emp.emp_id)As Emp_Count,@Scheme_Name as Scheme_Name
				From T0080_EMP_MASTER EMP WITH (NOLOCK)
					left Outer JOIN 
					(SELECT QES.* from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
						(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
						where IES.effective_date <= GETDATE()  AND Cmp_ID = @Cmp_Id AND Type = @Scheme_Name
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date and qes.Type = @Scheme_Name  
					) ES		
					
					ON ES.EMP_ID =  EMP.EMP_ID 
					left outer JOIN T0040_Scheme_Master SM WITH (NOLOCK) On  ES.Scheme_ID = SM.Scheme_ID 
				Where Emp.EMP_ID in (select Emp_ID from #Emp_Cons)
				And EMP.Emp_Left = 'N' And ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') = '-'
			)AS Ec ON Ec.Scheme_Name = S.Scheme_Type
			
		where S.Scheme_Type =@Scheme_Name
			
		fetch next from Cursor_Scheme into @Scheme_Name
	End
	Close Cursor_Scheme                    
	Deallocate Cursor_Scheme

	select * from #Scheme_Type order BY Emp_count desc
				 
END



