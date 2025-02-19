

--exec P0050_CANTEEN_Report_3 150 ,'2015-01-01','2020-01-01','548','437#484','','','','',0,'16243#16246#16253#16254'
--exec P0050_CANTEEN_Report_3 150 ,'2015-01-01','2020-01-01','548','437#484','','','','',0,'16243#16246#16253#16254'
--exec P0050_CANTEEN_Report 150 ,NULL,'2020-01-01',0,0,0,0,0,0,0,'16246'
--exec P0050_CANTEEN_Report 150 ,NULL,'2020-01-01',0,0,0,0,0,0,0,'16248'
--exec P0050_CANTEEN_Report 150 ,NULL,'2020-01-01',0,0,0,0,0,0,0,'22665'
---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_CANTEEN_Report_3] 
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(MAX) = ''   
	,@Grd_ID		varchar(MAX) = ''  
	,@Cat_ID		varchar(MAX) = ''  
	,@Dept_ID		varchar(MAX) = ''           
	,@Type_ID		varchar(MAX) = ''                
	,@Desig_ID		varchar(MAX) = ''     
	,@Emp_ID		varchar(MAX) = 0 
	,@Constraint	varchar(MAX) = ''
	,@flag         numeric 
	--Ronakb250724 added flag
AS
BEGIN

SET NOCOUNT ON	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		if @Branch_ID = '' 
			set @Branch_ID = null
		if @Cat_ID = '' 
			set @Cat_ID = null
		if @Type_ID = '' 
			set @Type_ID = null
		if @Dept_ID = '' 
			set @Dept_ID = null
		if @Grd_ID = ''
			set @Grd_ID = null
		if @Emp_ID = 0
			set @Emp_ID = null
		If @Desig_ID = ''
			set @Desig_ID = null

		CREATE TABLE #EMP_CONS 
		(      
			EMP_ID		 NUMERIC ,     
			BRANCH_ID	 NUMERIC,
			INCREMENT_ID NUMERIC
		)      
	
		--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date ,@To_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID ,@Emp_ID ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID,@From_Date ,@To_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID ,@Emp_ID  ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		--CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);
							
		-----------------------------------------Get the Employee Details from Company ID--------------------------------------

		SELECT distinct Emp_id, [Sub-Contractor], [Cost center] into #tmpSCCC
		FROM
		(	SELECT Emp_id,Column_Name,Value from [T0081_CUSTOMIZED_COLUMN] cc 
			WITH (NOLOCK) inner join T0082_Emp_Column ec WITH (NOLOCK) on cc.Tran_Id = ec.mst_Tran_Id where 
			 Column_Name in ('Sub-Contractor','Cost center')
		) AS SourceTable
		PIVOT
		(
			MAX(Value) FOR Column_Name IN ([Sub-Contractor], [Cost center])
		) AS PivotTable;

		SELECT E.emp_id, E.Alpha_Emp_Code, E.emp_full_name,e.Mobile_No, desig_name as Designation, dept_name as Department
		, branch_name as [Branch_Name],grd_name as [Grade_Name], TEC.[Sub-Contractor] as [Sub_Contractor],TEC.[Cost center] as [Cost_center],I.Grd_ID into #EmpDetails  --added by mansi start 06-10-22
		--, branch_name as [Branch Name],grd_name as [Grade Name], TEC.[Sub-Contractor] ,TEC.[Cost center] ,I.Grd_ID into #EmpDetails --commented by mansi start 06-10-22
		FROM   t0080_emp_master E WITH (NOLOCK)
				INNER JOIN  #EMP_CONS EC
						ON E.emp_id = EC.emp_id 
				INNER JOIN t0095_increment I  WITH (NOLOCK)
						ON EC.Increment_ID = I.Increment_ID
				LEFT OUTER JOIN t0040_grade_master GM WITH (NOLOCK)
						ON I.grd_id = gm.grd_id  
				LEFT OUTER JOIN t0030_branch_master BM WITH (NOLOCK)
						ON I.branch_id = BM.branch_id 
				LEFT OUTER JOIN t0040_department_master DM WITH (NOLOCK)
				        ON I.dept_id = DM.dept_id 
				LEFT OUTER JOIN t0040_designation_master DGM WITH (NOLOCK)
					    ON I.desig_id = DGM.desig_id 
				LEFT OUTER JOIN #tmpSCCC TEC
						ON TEC.Emp_Id = E.Emp_ID

				DECLARE @GroupCnt as integer = 1
				DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);
				WHILE (@GroupCnt <= 5)
				BEGIN
						SET @columns = N'';
						SELECT @columns += N', p.' + QUOTENAME(Cnt_Name)
						FROM (select Cnt_Name from T0050_CANTEEN_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID and Canteen_Group = @GroupCnt) AS x;
						IF (@columns <> '')
						BEGIN
							SET @sql = N';WITH CTE AS
							(
							SELECT EMP_ID,' + STUFF(@columns, 1, 2, '') + ',Amount,GST_Percentage ,grd_id,Exemption_Count 
							FROM
							(
							  SELECT   EMP_ID ,CM.Cnt_Name,q2.Amount,CM.GST_Percentage,grd_id,Exemption_Count 
							  FROM T0150_EMP_CANTEEN_PUNCH ECP WITH (NOLOCK)
							  left JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.Canteen_ID = CM.Cnt_Id
							  LEFT JOIN(
										SELECT DISTINCT Amount,CD.Cnt_Id,cd.grd_id,Exemption_Count FROM  T0050_CANTEEN_DETAIL CD WITH (NOLOCK) inner join 
											(SELECT  Max(Effective_Date) AS For_Date ,Cnt_Id
												FROM   T0050_CANTEEN_DETAIL WITH (NOLOCK)
												WHERE  Effective_Date <= Getdate() AND 
												cmp_id = ' + Cast(@Cmp_ID as nvarchar(5)) +' group by Cnt_Id) Q1 
												ON CD.Cnt_Id = Q1.Cnt_Id and CD.Effective_Date = Q1.For_Date
										) Q2 on CM.Cnt_Id = q2.Cnt_Id
										Where
										ECP.Canteen_Punch_Datetime between ''' + Cast(CONVERT(varchar(11),@From_Date,113) as Varchar(11)) + ''' and ''' + Cast(CONVERT(varchar(11),@To_Date,113) as Varchar(11)) + ''' AND 
										cm.Canteen_Group = ' + Cast(@GroupCnt as nvarchar(5)) + '
							) AS j
							PIVOT
							(
							   COUNT(Cnt_Name) FOR Cnt_Name IN('+ STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')
							)AS p 
							) -- End CTE
							select EMP_ID,
							('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') as [Total '+ STUFF(Replace(REPLACE(@columns, ', p.[', '/'),']',''), 1, 1, '') + ' Count]
							,grd_id
							,CASE WHEN EXEMPTION_COUNT = 0 OR (('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') < EXEMPTION_COUNT) THEN 0 ELSE (('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') - Exemption_Count) END as [Extra '+ STUFF(Replace(REPLACE(@columns, ', p.[', '/'),']',''), 1, 1, '') + ']
							,CASE WHEN EXEMPTION_COUNT = 0  OR (('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') < EXEMPTION_COUNT) THEN 0 ELSE ((('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') - Exemption_Count)*Amount) END as [Total Extra '+ STUFF(Replace(REPLACE(@columns, ', p.[', '/'),']',''), 1, 1, '') + ' Amount]
							,GST_Percentage  as [GST Percent '+ STUFF(Replace(REPLACE(@columns, ', p.[', '/'),']',''), 1, 1, '') + ']
							,CASE WHEN EXEMPTION_COUNT = 0  OR (('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') < EXEMPTION_COUNT) THEN 0 ELSE cast((((('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') - Exemption_Count)*Amount) * GST_Percentage/100) as decimal(10,2)) END as [GST '+ STUFF(Replace(REPLACE(@columns, ', p.[', '/'),']',''), 1, 1, '') + ' Amount]
							,CASE WHEN EXEMPTION_COUNT = 0 OR (('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') < EXEMPTION_COUNT) THEN 0 ELSE ((('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') - Exemption_Count)*Amount) 
							+ cast((((('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') - Exemption_Count)*Amount) * GST_Percentage/100) as decimal(10,2)) END as [Net '+ STUFF(Replace(REPLACE(@columns, ', p.[', '/'),']',''), 1, 1, '') + ' Amount]
							into tmp' + Cast(@GroupCnt as nvarchar(5)) + '
							From CTE 
							--where ('+ Replace(Replace(STUFF(@columns, 1, 2, ''),'p.',''),', ','+') + ') >= case when Exemption_Count = 0 then 0 else Exemption_Count end
							ORDER BY EMP_ID'
							--PRINT @sql;
							EXEC(@sql);
						END
						SET  @GroupCnt = @GroupCnt + 1
				END
		
		DECLARE @Tmp1Cols NVARCHAR(MAX) = ''
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmp1')
		BEGIN	
			IF ((select count(1) from tmp1) > 0)
			BEGIN 
				Select @Tmp1Cols =
				Stuff((
					Select ', ' + 'isnull(t1.['+COLUMN_NAME+'],0)  as [' + COLUMN_NAME + ']'
					From INFORMATION_SCHEMA.COLUMNS As C
					Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
						And C.TABLE_NAME = T.TABLE_NAME
						And c.COLUMN_NAME <> 'Emp_ID'
						And c.COLUMN_NAME <> 'grd_id'
					Order By C.ORDINAL_POSITION
					For Xml Path('')
					), 1, 2, '') --As Columns
				FROM INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmp1' 
			END
			ELSE
			BEGIN 
					SET @Tmp1Cols = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @Tmp1Cols = 'NoData'
		END

		DECLARE @Tmp2Cols NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmp2')
		BEGIN	
			IF ((select count(1) from tmp2) > 0)
			BEGIN 
				Select @Tmp2Cols =
					Stuff((
						Select ', ' + 'isnull(t2.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmp2' 
			END
			ELSE
			BEGIN 
					SET @Tmp2Cols = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @Tmp2Cols = 'NoData'
		END

		DECLARE @Tmp3Cols NVARCHAR(MAX) = ''
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmp3')
		BEGIN	
			IF ((select count(1) from tmp3) > 0)
			BEGIN 
				Select @Tmp3Cols =
				Stuff((
					Select ', ' + 'isnull(t3.['+COLUMN_NAME+'],0)  as [' + COLUMN_NAME + ']'
					From INFORMATION_SCHEMA.COLUMNS As C
					Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
						And C.TABLE_NAME = T.TABLE_NAME
						And c.COLUMN_NAME <> 'Emp_ID'
						And c.COLUMN_NAME <> 'grd_id'
					Order By C.ORDINAL_POSITION
					For Xml Path('')
					), 1, 2, '') --As Columns
				FROM INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmp3' 
			END
			ELSE
			BEGIN 
					SET @Tmp3Cols = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @Tmp3Cols = 'NoData'
		END

		DECLARE @Tmp4Cols NVARCHAR(MAX) = ''
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmp4')
		BEGIN	
			IF ((select count(1) from tmp4) > 0)
			BEGIN 
				Select @Tmp4Cols =
				Stuff((
					Select ', ' + 'isnull(t4.['+COLUMN_NAME+'],0)  as [' + COLUMN_NAME + ']'
					From INFORMATION_SCHEMA.COLUMNS As C
					Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
						And C.TABLE_NAME = T.TABLE_NAME
						And c.COLUMN_NAME <> 'Emp_ID'
						And c.COLUMN_NAME <> 'grd_id'
					Order By C.ORDINAL_POSITION
					For Xml Path('')
					), 1, 2, '') --As Columns
				FROM INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmp4' 
			END
			ELSE
			BEGIN 
					SET @Tmp4Cols = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @Tmp4Cols = 'NoData'
		END

		DECLARE @Tmp5Cols NVARCHAR(MAX) = ''
		IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmp5')
		BEGIN	
			IF ((select count(1) from tmp5) > 0)
			BEGIN 
				Select @Tmp5Cols =
				Stuff((
					Select ', ' + 'isnull(t5.['+COLUMN_NAME+'],0)  as [' + COLUMN_NAME + ']'
					From INFORMATION_SCHEMA.COLUMNS As C
					Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
						And C.TABLE_NAME = T.TABLE_NAME
						And c.COLUMN_NAME <> 'Emp_ID'
						And c.COLUMN_NAME <> 'grd_id'
					Order By C.ORDINAL_POSITION
					For Xml Path('')
					), 1, 2, '') --As Columns
				FROM INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmp5' 
			END
			ELSE
			BEGIN 
					SET @Tmp5Cols = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @Tmp5Cols = 'NoData'
		END
		
		
		IF((select count(1) from T0050_CANTEEN_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID and (Canteen_Group = 0 Or Canteen_Group is null)) > 0)
		BEGIN
				SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS SRNO,'[' +CNT_NAME+']'  as Cnt_Name INTO #TMPCNTNAME 
				FROM T0050_CANTEEN_MASTER WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND (Canteen_Group = 0 Or Canteen_Group is null)
					
				DECLARE @GroupCnt1 as integer = 1
				DECLARE @sqlCant NVARCHAR(MAX);
				
				WHILE (@GroupCnt1 <= (select Count(1) from #TMPCNTNAME))
				BEGIN
					DECLARE @CNT_NAME AS VARCHAR(50) = ''
					SELECT @CNT_NAME = CNT_NAME FROM #TMPCNTNAME WHERE SRNO = @GROUPCNT1

					SET @sqlCant = N';WITH CTE AS
								(
								SELECT EMP_ID,' + @Cnt_Name + ',Amount,GST_Percentage ,grd_id,Exemption_Count 
								FROM
								(
								  SELECT   EMP_ID ,CM.Cnt_Name,q2.Amount,CM.GST_Percentage,grd_id,Exemption_Count 
								  FROM T0150_EMP_CANTEEN_PUNCH ECP WITH (NOLOCK)
								  left JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.Canteen_ID = CM.Cnt_Id
								  LEFT JOIN(
											SELECT DISTINCT Amount,CD.Cnt_Id,cd.grd_id,Exemption_Count FROM  T0050_CANTEEN_DETAIL CD WITH (NOLOCK) inner join 
												(SELECT  Max(Effective_Date) AS For_Date ,Cnt_Id
													FROM   T0050_CANTEEN_DETAIL  WITH (NOLOCK)
													WHERE  Effective_Date <= Getdate() AND 
													cmp_id = ' + Cast(@Cmp_ID as nvarchar(5)) +' group by Cnt_Id) Q1 
													ON CD.Cnt_Id = Q1.Cnt_Id and CD.Effective_Date = Q1.For_Date
											) Q2 on CM.Cnt_Id = q2.Cnt_Id
											Where 
											ECP.Canteen_Punch_Datetime between ''' + Cast(CONVERT(varchar(11),@From_Date,113) as Varchar(11)) + ''' and ''' + Cast(CONVERT(varchar(11),@To_Date,113) as Varchar(11)) + ''' AND 
											cm.Cnt_Name = '''+ Replace(Replace(@Cnt_Name,'[',''),']','') +'''
								) AS j
								PIVOT
								(
								   COUNT(Cnt_Name) FOR Cnt_Name IN('+ @Cnt_Name + ')
								)AS p 
								) -- End CTE
								select EMP_ID,
								('+ @Cnt_Name + ') as [Total '+ Replace(Replace(@Cnt_Name,'[',''),']','') + ' Count]
								,grd_id
								,CASE WHEN EXEMPTION_COUNT = 0 OR (('+ @Cnt_Name + ') < EXEMPTION_COUNT) THEN 0 ELSE ((' + @Cnt_Name + ') - Exemption_Count) END as [Extra '+ Replace(Replace(@Cnt_Name,'[',''),']','') + ']
								,CASE WHEN EXEMPTION_COUNT = 0 OR (('+ @Cnt_Name + ') < EXEMPTION_COUNT) THEN 0 ELSE ((('+ @Cnt_Name + ') - Exemption_Count)*Amount) END as [Total Extra '+ Replace(Replace(@Cnt_Name,'[',''),']','') + ' Amount]
								,GST_Percentage as [GST Percent '+ Replace(Replace(@Cnt_Name,'[',''),']','') + ']
								,CASE WHEN EXEMPTION_COUNT = 0 OR (('+ @Cnt_Name + ') < EXEMPTION_COUNT) THEN 0 ELSE cast((((('+ @Cnt_Name + ') - Exemption_Count)*Amount) * GST_Percentage/100) as decimal(10,2)) END as [GST '+ Replace(Replace(@Cnt_Name,'[',''),']','') + ' Amount]
								,CASE WHEN EXEMPTION_COUNT = 0 OR (('+ @Cnt_Name + ') < EXEMPTION_COUNT) THEN 0 ELSE ((('+ @Cnt_Name + ') - Exemption_Count)*Amount) 
								+ cast((((('+ @Cnt_Name + ') - Exemption_Count)*Amount) * GST_Percentage/100) as decimal(10,2)) END as [Net '+ Replace(Replace(@Cnt_Name,'[',''),']','') + ' Amount]
								into tmpCanteen' + Cast(@GroupCnt1 as nvarchar(5)) + '
								From CTE 
								--where ('+ @Cnt_Name + ') >= case when Exemption_Count = 0 then 0 else  Exemption_Count end
								ORDER BY EMP_ID'
					--print @sqlCant
					EXEC(@sqlCant);
					SET  @GroupCnt1 = @GroupCnt1 + 1
				END
		END
			
			--select * from TmpCanteen3
			--select * from TmpCanteen4
			--select * from TmpCanteen5
			--select * from TmpCanteen6

		DECLARE @TmpCanteen1 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen1')
		BEGIN	
				IF ((select count(1) from tmpCanteen1) > 0)
				BEGIN 
					Select @TmpCanteen1 =
						Stuff((
							Select ', ' + 'isnull(tc1.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
							From INFORMATION_SCHEMA.COLUMNS As C
							Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
								And C.TABLE_NAME = T.TABLE_NAME
								And c.COLUMN_NAME <> 'Emp_ID'
								And c.COLUMN_NAME <> 'grd_id'
							Order By C.ORDINAL_POSITION
							For Xml Path('')
							), 1, 2, '') --As Columns
					From INFORMATION_SCHEMA.TABLES As T
					WHERE TABLE_NAME = 'tmpCanteen1' 
				END
				ELSE
				BEGIN 
						SET @TmpCanteen1 = 'NoData'
				END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen1 = 'NoData'
		END
		
		DECLARE @TmpCanteen2 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen2')
		BEGIN	
			IF ((select count(1) from tmpCanteen2) > 0)
			BEGIN 
				Select @TmpCanteen2 =
					Stuff((
						Select ', ' + 'isnull(tc2.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmpCanteen2' 
			END
			ELSE
			BEGIN 
					SET @TmpCanteen2 = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen2 = 'NoData'
		END

		DECLARE @TmpCanteen3 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen3')
		BEGIN	
			IF ((select count(1) from tmpCanteen3) > 0)
			BEGIN 
				Select @TmpCanteen3 =
					Stuff((
						Select ', ' + 'isnull(tc3.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmpCanteen3' 
			END
			ELSE
			BEGIN 
					SET @TmpCanteen3 = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen3 = 'NoData'
		END

		DECLARE @TmpCanteen4 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen4')
		BEGIN	
			IF ((select count(1) from tmpCanteen4) > 0)
			BEGIN 
				Select @TmpCanteen4 =
					Stuff((
						Select ', ' + 'isnull(tc4.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmpCanteen4' 
			END
			ELSE
			BEGIN 
					SET @TmpCanteen4 = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen4 = 'NoData'
		END

		DECLARE @TmpCanteen5 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen5')
		BEGIN	
			IF ((select count(1) from tmpCanteen5) > 0)
			BEGIN 
				Select @TmpCanteen5 =
					Stuff((
						Select ', ' + 'isnull(tc5.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmpCanteen5' 
			END
			ELSE
			BEGIN 
					SET @TmpCanteen5 = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen5 = 'NoData'
		END

		DECLARE @TmpCanteen6 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen6')
		BEGIN	
			IF ((select count(1) from tmpCanteen6) > 0)
			BEGIN 
				Select @TmpCanteen6 =
					Stuff((
						Select ', ' + 'isnull(tc6.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmpCanteen6' 
			END
			ELSE
			BEGIN 
					SET @TmpCanteen6 = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen6 = 'NoData'
		END
	
		DECLARE @TmpCanteen7 NVARCHAR(MAX) = ''
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tmpCanteen7')
		BEGIN	
			IF ((select count(1) from tmpCanteen7) > 0)
			BEGIN 
				Select @TmpCanteen7 =
					Stuff((
						Select ', ' + 'isnull(tc7.['+COLUMN_NAME+'],0) as [' + COLUMN_NAME + ']'
						From INFORMATION_SCHEMA.COLUMNS As C
						Where C.TABLE_SCHEMA = T.TABLE_SCHEMA
							And C.TABLE_NAME = T.TABLE_NAME
							And c.COLUMN_NAME <> 'Emp_ID'
							And c.COLUMN_NAME <> 'grd_id'
						Order By C.ORDINAL_POSITION
						For Xml Path('')
						), 1, 2, '') --As Columns
				From INFORMATION_SCHEMA.TABLES As T
				WHERE TABLE_NAME = 'tmpCanteen7' 
			END
			ELSE
			BEGIN 
					SET @TmpCanteen7 = 'NoData'
			END
		END
		ELSE
		BEGIN 
				SET @TmpCanteen7 = 'NoData'
		END

		------------------------------------------------------------- Group   ------------------
		Declare @appendQry varchar(MAX) = ''
		Declare @appendTable varchar(MAX) = ''
		If  @Tmp1Cols <> 'NoData'
		BEGIN 
			set @appendQry = '' + @Tmp1Cols + ''
			set @appendTable = 'LEFT JOIN tmp1 t1 On Ed.Emp_ID = t1.Emp_ID and ED.Grd_ID = t1.grd_id '
		END
		If  @Tmp2Cols <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @Tmp2Cols + ''
			set @appendTable = @appendTable + 'LEFT JOIN tmp2 t2 On Ed.Emp_ID = t2.Emp_ID and ED.Grd_ID = t2.grd_id '
		END
		If  @Tmp3Cols <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @Tmp3Cols + ''
			set @appendTable = @appendTable + 'LEFT JOIN tmp3 t3 On Ed.Emp_ID = t3.Emp_ID and ED.Grd_ID = t3.grd_id '
		END
		If  @Tmp4Cols <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @Tmp4Cols + ''
			set @appendTable = @appendTable + 'LEFT JOIN tmp4 t4 On Ed.Emp_ID = t4.Emp_ID and ED.Grd_ID = t4.grd_id '
		END
		If  @Tmp5Cols <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @Tmp5Cols + ''
			set @appendTable = @appendTable + 'LEFT JOIN tmp5 t5 On Ed.Emp_ID = t5.Emp_ID and ED.Grd_ID = t5.grd_id '
		END
		------------------------------------------------------------- END Group -------------------
		
		if @Tmp1Cols = 'NoData' and @Tmp2Cols = 'NoData' AND @Tmp3Cols = 'NoData' and @Tmp4Cols = 'NoData' AND @Tmp5Cols = 'NoData'
		BEGIN
			If  @TmpCanteen1 <> 'NoData'
			BEGIN
				set @appendQry = '' + @TmpCanteen1 + ''
				set @appendTable = 'LEFT JOIN tmpCanteen1 tc1 On Ed.Emp_ID = tc1.Emp_ID and ED.Grd_ID = tc1.grd_id '
			END
		END
		ELSE If  @TmpCanteen1 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen1 + ''
			set @appendTable = @appendTable + 'LEFT JOIN tmpCanteen1 tc1 On Ed.Emp_ID = tc1.Emp_ID and ED.Grd_ID = tc1.grd_id '
		END
		If  @TmpCanteen2 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen2 + ''
			set @appendTable =  @appendTable + 'LEFT JOIN tmpCanteen2 tc2 On Ed.Emp_ID = tc2.Emp_ID and ED.Grd_ID = tc2.grd_id '
		END
		If  @TmpCanteen3 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen3 + ''
			set @appendTable =  @appendTable + 'LEFT JOIN tmpCanteen3 tc3 On Ed.Emp_ID = tc3.Emp_ID and ED.Grd_ID = tc3.grd_id '
		END
		If  @TmpCanteen4 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen4 + ''
			set @appendTable =  @appendTable + 'LEFT JOIN tmpCanteen4 tc4 On Ed.Emp_ID = tc4.Emp_ID and ED.Grd_ID = tc4.grd_id '
		END
		If  @TmpCanteen5 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen5 + ''
			set @appendTable =  @appendTable + 'LEFT JOIN tmpCanteen5 tc5 On Ed.Emp_ID = tc5.Emp_ID and ED.Grd_ID = tc5.grd_id '
		END
		If  @TmpCanteen6 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen6 + ''
			set @appendTable =  @appendTable + 'LEFT JOIN tmpCanteen6 tc6 On Ed.Emp_ID = tc6.Emp_ID and ED.Grd_ID = tc6.grd_id '
		END
		If  @TmpCanteen7 <> 'NoData'
		BEGIN 
			set @appendQry = @appendQry + ', ' + @TmpCanteen7 + ''
			set @appendTable =  @appendTable + 'LEFT JOIN tmpCanteen7 tc7 On Ed.Emp_ID = tc7.Emp_ID and ED.Grd_ID = tc7.grd_id '
		END

		IF @appendQry <> '' and @appendTable <> ''
		BEGIN
		DECLARE @sqlQry	varchar(Max) = ''
			--added by mansi  06-10-22
			SET @sqlQry ='SELECT ED.Emp_ID,ED.Alpha_Emp_Code ,ED.emp_full_name,ED.Mobile_No,[DESIGNATION],[DEPARTMENT],[BRANCH_NAME]
						,[Grade_Name], ED.[Sub_Contractor] ,ED.[Cost_center]
						,' + @appendQry + '
						FROM #EmpDetails ED ' + @appendTable +''
			--ended by mansi start 06-10-22
						----commented by mansi start 06-10-22
				--SET @sqlQry =	'SELECT ED.Emp_ID,ED.Alpha_Emp_Code ,ED.emp_full_name,ED.Mobile_No,[DESIGNATION],[DEPARTMENT],[BRANCH NAME]
						--,[Grade Name], ED.[Sub-Contractor] ,ED.[Cost center]
						--,' + @appendQry + '
						--FROM #EmpDetails ED ' + @appendTable +''
						----commented by mansi end 06-10-22
		END
		ELSE
		BEGIN
		--added by mansi  06-10-22
			SET @sqlQry ='SELECT ED.Emp_ID,ED.Alpha_Emp_Code ,ED.emp_full_name,ED.Mobile_No,[DESIGNATION],[DEPARTMENT],[BRANCH_NAME]
						,[Grade_Name], ED.[Sub_Contractor] ,ED.[Cost_center]
						FROM #EmpDetails ED'
			--ended by mansi start 06-10-22
			--	--commented by mansi start 06-10-22
			--SET @sqlQry = '
			--			SELECT ED.Emp_ID,ED.Alpha_Emp_Code ,ED.emp_full_name,ED.Mobile_No,[DESIGNATION],[DEPARTMENT],[BRANCH NAME]
			--			,[Grade Name], ED.[Sub-Contractor] ,ED.[Cost center]
			--			FROM #EmpDetails ED'
			--				--commented by mansi end 06-10-22
		END
		--PRINT @SQLQRY
		EXEC(@sqlQry)

		IF OBJECT_ID('tempdb..#EMPDETAILS') IS NOT NULL 
			DROP TABLE #EMPDETAILS
		IF OBJECT_ID('tempdb..#EMP_CONS') IS NOT NULL 
			DROP TABLE #EMP_CONS
		IF OBJECT_ID('tempdb..#TMPSCCC') IS NOT NULL 
			DROP TABLE #TMPSCCC
		IF OBJECT_ID('tempdb..#TMPCNTNAME') IS NOT NULL 
			DROP TABLE #TMPCNTNAME
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmp1' and type = 'u')
				Drop table tmp1
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmp2' and type = 'u')
				Drop table tmp2
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmp3' and type = 'u')
				Drop table tmp3
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmp4' and type = 'u')
				Drop table tmp4
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmp5' and type = 'u')
				Drop table tmp5
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen1' and type = 'u')
				Drop table tmpCanteen1
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen2' and type = 'u')
				Drop table tmpCanteen2
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen3' and type = 'u')
				Drop table tmpCanteen3
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen4' and type = 'u')
				Drop table tmpCanteen4
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen5' and type = 'u')
				Drop table tmpCanteen5
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen6' and type = 'u')
				Drop table tmpCanteen6
		IF EXISTS (SELECT * from sys.objects WHERE name = 'tmpCanteen7' and type = 'u')
				Drop table tmpCanteen7
SET NOCOUNT OFF;
END



