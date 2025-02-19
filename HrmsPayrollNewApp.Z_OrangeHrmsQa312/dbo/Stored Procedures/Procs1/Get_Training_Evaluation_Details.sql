

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Training_Evaluation_Details]
	 @Cmp_ID		Numeric(18,0)
	,@Dept_id	varchar(max)
	,@Grade_id	varchar(max)
	,@Desg_id	varchar(max)
	,@Emp_ID 	Numeric(18,0)
	,@FromDate datetime
	,@flag int=0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Dept_id = 0 or @Dept_id = ''
		set @Dept_id = null
	IF @Grade_id = 0 or @Grade_id = ''
		set @Grade_id = null
	IF @Desg_id = 0 or @Desg_id = ''
		set @Desg_id = null	
	if @Emp_ID=0
		set @Emp_ID= NULL
		
	DECLARE @columns VARCHAR(8000)
	DECLARE @query VARCHAR(MAX)
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@FromDate,@FromDate,'','',@Grade_id,'',@Dept_ID,@Desg_id,@Emp_ID,'',0,0,'','','','',0,0,0,'0',0,0 
   
	--INSERT INTO #Emp_Cons(emp_id, Increment_ID) 
	--	select  em.emp_id, IE.Increment_ID
	--	from T0080_EMP_MASTER em
	--	INNER JOIN	
	--	(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID, I.Increment_ID
	--	FROM T0095_INCREMENT I INNER JOIN
	--		(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
	--		 FROM T0095_INCREMENT Inner JOIN
	--			(
	--				SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
	--				FROM T0095_INCREMENT WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
	--			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
	--		 WHERE CMP_ID = @cmp_id
	--		 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
	--	where I.Cmp_ID= @cmp_id
	--	)IE on ie.Emp_ID = em.Emp_ID 
	--	where em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' 
	--	--and isnull(IE.Dept_ID,0) = isnull(@Dept_ID ,isnull(IE.Dept_ID,0))
	--	and isnull(em.Emp_ID,0) = isnull(@Emp_ID ,isnull(em.Emp_ID,0))
	--	and (ISNULL(IE.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_id,ISNULL(IE.Dept_ID,0)),'#') ) or isnull(IE.Dept_ID,0) = 0 )
	--	and (ISNULL(IE.Desig_Id,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desg_id,ISNULL(IE.Desig_Id,0)),'#') ) or isnull(IE.Desig_Id,0) = 0 )
	--	and (ISNULL(IE.Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grade_id,ISNULL(IE.Grd_ID,0)),'#') ) or isnull(IE.Grd_ID,0) = 0 )
		
		--select * from #Emp_Cons
	if @flag=0
		BEGIN		
			SELECT @columns = COALESCE(@columns + ',', '')+
			 '[' + CAST(Training_TypeName AS VARCHAR(100)) + '_Training],' +
			 '[' + CAST(Training_TypeName AS VARCHAR(100)) + '_Desired],' +
			 '[' + CAST(Training_TypeName AS VARCHAR(100)) + '_Present]'
			from T0030_Hrms_Training_Type WITH (NOLOCK) where Cmp_Id=@Cmp_ID
			GROUP BY Training_TypeName
			/*Data Table 1 : Main*/
			
			Select	EC.Emp_ID, E.Alpha_Emp_Code, E.Emp_Full_Name, G.Grd_Name As Grade, D.Desig_Name As Designation
			FROM	#Emp_Cons EC
					Inner Join T0080_EMP_MASTER E WITH (NOLOCK) ON EC.Emp_ID=E.Emp_ID
					Inner Join T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
					Inner Join T0040_DESIGNATION_MASTER D WITH (NOLOCK) ON I.Desig_Id=D.Desig_ID
					Inner Join T0040_GRADE_MASTER G WITH (NOLOCK) ON I.Grd_ID=G.Grd_ID
			--where EC.Emp_ID=2853
			
			/*Data Table 2 : Columns*/
			SELECT	ROW_NUMBER() OVER(ORDER BY Training_TypeName) + 4 AS ROW_ID, Training_TypeName, 1 AS IsGroup, Training_Type_ID
			INTO	#COLUMNS
			FROM	T0030_Hrms_Training_Type WITH (NOLOCK) where Cmp_Id=@Cmp_ID
			GROUP BY Training_TypeName,Training_Type_ID
			
			--INSERT INTO #COLUMNS Values(1, 'Employee Code', 0, 0)
			--INSERT INTO #COLUMNS Values(2, 'Employee Name', 0, 0)
			--INSERT INTO #COLUMNS Values(3, 'Grade', 0, 0)
			--INSERT INTO #COLUMNS Values(4, 'Designation', 0, 0)
			
			SELECT * FROM #COLUMNS 
			
			/*Data Table 3 : Row*/
			SELECT	EC.EMP_ID,T.Training_Type_ID, T.Training_TypeName, TE.Training_ID As T_Title, ISNULL(TE.Desired,0) As T_Desired, ISNULL(TE.Present,0) As T_Present,ISNULL(TE.Training_ID,0)Training_ID
			FROM	#Emp_Cons EC
					CROSS JOIN (SELECT * FROM #COLUMNS WHERE ISGROUP=1) T
					LEFT JOIN T0130_Training_TypeWise_Evaluation TE WITH (NOLOCK) on TE.emp_id=ec.Emp_ID and TE.Training_Type_ID=t.Training_Type_ID
				--where EC.Emp_ID=2853
			ORDER BY EC.EMP_ID,T.Training_TypeName
		END
	else 
		BEGIN			
			--SELECT Training_TypeName +' '+'_Training' as T1 ,Training_TypeName +' '+'_Desired' as T2,
			--Training_TypeName +' '+'_Present' AS T3,Training_Type_ID INTO #COLUMNS1 
			--FROM T0030_Hrms_Training_Type where Cmp_Id=@Cmp_ID
			--GROUP BY Training_TypeName,Training_Type_ID
			----CROSS JOIN #COLUMNS1  T
			--select 111, * from #COLUMNS1	
            
   --         SELECT SD.Training_Type_ID,ca.*,0 as Rating
			--INTO #COLUMNS2
			--FROM #COLUMNS1 AS sd
			--			CROSS APPLY
			--			(
			--				VALUES
			--					(T1),
			--					(T2),
			--					(T3)
			--			) AS ca (TITLE)
						
			--SELECT 222,C.*, E.Desired FROM #COLUMNS2 c 
			--		INNER JOIN T0130_Training_TypeWise_Evaluation E ON C.Training_Type_ID=E.Training_Type_ID
			--where title like '%_Desired'
			
			--update #COLUMNS2 CL set rating=te.Training_ID
			--from T0130_Training_TypeWise_Evaluation TE
			--where cl.TE.Training_Type_ID=te.Training_Type_ID
			
			--SELECT	EC.EMP_ID,T.title, TE.Training_ID As T_Title, ISNULL(TE.Desired,0) As T_Desired, ISNULL(TE.Present,0) As T_Present,ISNULL(TE.Training_ID,0)Training_ID
			--FROM	#Emp_Cons EC
			--		CROSS JOIN (SELECT * FROM #COLUMNS2) T
			--		LEFT JOIN T0130_Training_TypeWise_Evaluation TE on TE.emp_id=ec.Emp_ID and TE.Training_Type_ID=t.Training_Type_ID			
			--ORDER BY EC.EMP_ID--,T.Training_TypeName
			
			SELECT	TOP 0 EMP_ID, T.Training_Type_ID, T.Training_TypeName, CAST('' AS VARCHAR(150)) As Value, CAST('' AS VARCHAR(32)) AS VALUE_TYPE, 0 AS Sort_ID
			INTO	#RAW_DATA
			FROM	T0130_Training_TypeWise_Evaluation E WITH (NOLOCK)
					INNER JOIN T0030_Hrms_Training_Type T WITH (NOLOCK) ON E.Training_Type_ID=T.Training_Type_ID
				
			INSERT	INTO #RAW_DATA
			SELECT distinct	E.EMP_ID, T.Training_Type_ID, T.Training_TypeName + '_Title',IsNull(TM.Training_name,''), 'Title', 1
			FROM	T0130_Training_TypeWise_Evaluation E WITH (NOLOCK)
					INNER JOIN T0030_Hrms_Training_Type T WITH (NOLOCK) ON E.Training_Type_ID=T.Training_Type_ID
					LEFT OUTER JOIN T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_ID=E.Training_ID
					INNER JOIN #Emp_Cons EC ON EC.EMP_ID=E.EMP_ID
			WHERE E.CMP_ID=@CMP_ID
			UNION ALL
			SELECT distinct	E.EMP_ID, T.Training_Type_ID, T.Training_TypeName + '_Desired',CAST(E.Desired AS VARCHAR(25)), 'Desired', 2
			FROM	T0130_Training_TypeWise_Evaluation E WITH (NOLOCK)
					INNER JOIN T0030_Hrms_Training_Type T WITH (NOLOCK) ON E.Training_Type_ID=T.Training_Type_ID
					INNER JOIN #Emp_Cons EC ON EC.EMP_ID=E.EMP_ID
			WHERE E.CMP_ID=@CMP_ID
			UNION ALL
			SELECT distinct	E.EMP_ID, T.Training_Type_ID, T.Training_TypeName + '_Present',CAST(E.Present AS VARCHAR(25)), 'Present', 3
			FROM	T0130_Training_TypeWise_Evaluation E WITH (NOLOCK)
					INNER JOIN T0030_Hrms_Training_Type T WITH (NOLOCK) ON E.Training_Type_ID=T.Training_Type_ID
					INNER JOIN #Emp_Cons EC ON EC.EMP_ID=E.EMP_ID
			WHERE E.CMP_ID=@CMP_ID
				--select * from #RAW_DATA		
			SELECT @columns = COALESCE(@columns + ',[' + CAST(Training_TypeName AS VARCHAR(1000)) + ']',
				'[' + CAST(Training_TypeName AS VARCHAR(1000))+ ']')
			FROM	(SELECT ROW_NUMBER() OVER(ORDER BY TRAINING_TYPE_ID,SORT_ID) AS ROW_ID,Training_TypeName 
					FROM	#RAW_DATA
					GROUP BY TRAINING_TYPE_ID,SORT_ID,Training_TypeName) T
			ORDER BY T.ROW_ID
			
			PRINT @columns
			SET @query = 'SELECT distinct ''="'' + Alpha_Emp_Code  + ''"'' as [Employee Code],Emp_Full_Name as [Employee Name],Grd_Name as[Grade],
			Desig_Name as[Designation],'+ @columns +'
										
								FROM (
									SELECT distinct EC.EMP_ID,Alpha_Emp_Code,Emp_Full_Name,Grd_Name,Desig_Name,Training_TypeName,value
									FROM #RAW_DATA EC
									inner join V0095_INCREMENT IC on EC.EMP_ID=IC.EMP_ID																																										
									) as s
								PIVOT	
								(				 
									max(value)	
									FOR [Training_TypeName] IN (' + @columns + ')  														 				
								)AS T
								 '
					print @query
					EXEC(@query)					
		END
END

