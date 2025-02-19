
-- EXEC Rolling_Manpower_Report 2 ,'2024-11-01','2024-11-30','','4328'
-- EXEC Rolling_Manpower_Report 2 ,'2024-09-01','2024-09-30','','4328'
CREATE Procedure [dbo].[Rolling_Manpower_Report]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Emp_ID		int = 0
	,@Constraint	varchar(MAX) = ''
	,@BranchID varchar(MAx)  -- add  by manisha on 17022025
	,@DeptID varchar(MAX)  -- add  by manisha on 17022025
As
Begin

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		
		DECLARE @previousMonthStartDate date;
		DECLARE @previousMonthEndDate date;
		select @previousMonthStartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@To_Date as date))-1, 0)
		select @previousMonthEndDate = DATEADD(MONTH, DATEDIFF(MONTH, -1, cast(@To_Date as date))-1, -1)
		

		--select @PreviousMonthStartDate,@PreviousMonthEndDate,@From_Date , @To_Date
		--select LEFT(DATENAME(MONTH, @previousMonthEndDate), 3)
		--select LEFT(DATENAME(MONTH, @To_Date), 3)

		CREATE TABLE #EMP_CONS 
		(      
			EMP_ID		 NUMERIC ,     
			BRANCH_ID	 NUMERIC,
			INCREMENT_ID NUMERIC
		)    
		CREATE TABLE #Data     
	(     
		Emp_Id     numeric ,     
		For_date   datetime,    
		Duration_in_sec  numeric, 
		Shift_ID   numeric ,    
		Shift_Type   numeric ,    
		Emp_OT    numeric ,    
		Emp_OT_min_Limit numeric,    
		Emp_OT_max_Limit numeric,    
		P_days    numeric(12,3) default 0,
		OT_Sec    numeric default 0,
		In_Time datetime default null,
		Shift_Start_Time datetime default null,
		OT_Start_Time numeric default 0,
		Shift_Change tinyint default 0 ,
		Flag Int Default 0  ,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0,
		Out_time datetime default null,
		Shift_End_Time datetime,			--Ankit 16112013
		OT_End_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID,@From_Date ,@To_Date ,0 ,0 ,0 ,0 ,0 ,0 ,@Emp_ID ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0
		--select * from #EMP_CONS
		SELECT * INTO #TMP_EMP_CONS FROM #Emp_Cons
			TRUNCATE TABLE #Emp_Cons
			Exec dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID,@previousMonthStartDate,@To_Date,0,0,0,0,0,0,@emp_ID,0,4,'',1   			
			TRUNCATE TABLE #Emp_Cons
			INSERT INTO #Emp_Cons 
			SELECT * FROM #TMP_EMP_CONS
			
			--select  * from #Data where Emp_Id = 3794
			--return
			select OT.BRANCH_ID,OT.Month_name 
			into #BranchWisemonth
			from (
			Select T.BRANCH_ID,T.Month_name
			from (
	Select ES.BRANCH_ID,DA.For_date,DATENAME(MONTH, DA.For_date)as [Month_name] from #Data DA
	INNER JOIN #EMP_CONS ES ON ES.EMP_ID = DA.Emp_Id
	group by ES.BRANCH_ID,DA.For_date
	) T group by T.BRANCH_ID,T.Month_name
	) OT ORDER BY MONTH(OT.Month_name + ' 1 2014') 
	 
	 
		Create Table #DeptBrc
		(
			Depat_Id numeric(10),
			Dept_name varchar(50),
			Branch_Id numeric(10),
			Branch_Name varchar(50)
		) 

		insert into #DeptBrc (Depat_Id,Dept_name,Branch_Id,Branch_Name)
		select Dept_Id,Dpt.Dept_Name,bm.Branch_ID,bm.Branch_Name
		from  T0040_DEPARTMENT_MASTER Dpt 
			Inner Join T0030_BRANCH_MASTER  BM on Dpt.Cmp_Id=BM.Cmp_Id
			where dpt.Cmp_Id= @Cmp_ID
			order by Dpt.Dept_Name,bm.Branch_Name

			--select * from #DeptBrc

		Declare @previousMonthBranchColumn as varchar(max) = ''	
		Select @previousMonthBranchColumn = '[' + Replace(STRING_AGG(Branch_City,','),',','] ,[') + ']'  
		from (
				Select Distinct Branch_Name + '_' + LEFT(DATENAME(MONTH, @previousMonthEndDate), 3)  as Branch_City from T0030_BRANCH_MASTER where CMP_ID = @Cmp_ID
		)a

		Declare @currentMonthBranchColumn as varchar(max) = ''	
		Select @currentMonthBranchColumn = '[' + Replace(STRING_AGG(Branch_City ,','),',','] ,[') + ']'  + '-' +  LEFT(DATENAME(MONTH, @To_Date), 3)   
		from (
				Select Distinct Branch_Name + '_' + LEFT(DATENAME(MONTH, @To_Date), 3)  as Branch_City from T0030_BRANCH_MASTER where CMP_ID = @Cmp_ID
		)a
		
		--select @previousMonthBranchColumn,@currentMonthBranchColumn
		--return
		
		declare @Branch_ID varchar(max)
		declare @Branch_NAme varchar(max)

					select @Branch_ID = COALESCE( @Branch_ID + '],[', '[') + Branch_Name   from T0030_BRANCH_MASTER  where Cmp_ID=@Cmp_ID 
					set @Branch_ID = @Branch_ID + ']'
					select @Branch_NAme = COALESCE( @Branch_Name + ''''',''''', '') + Branch_Name   from T0030_BRANCH_MASTER  where Cmp_ID=@Cmp_ID 
					set @Branch_NAme = REPLACE(@Branch_NAme,' ','')
					--select @Branch_ID
					--select @Branch_NAme

		--SELECT --Row_Number() Over(order by Branch_Id) as RowId,
		--Branch_Name,Department --, @currentMonthBranchColumn --,[Branch Name]
		--FROM
		--(		
		--	select  Dpt.Dept_Name As [Department]
		--	,Branch_Name As [Branch_Name],Branch_City
		--	from  T0040_DEPARTMENT_MASTER Dpt 
		--	Inner Join T0030_BRANCH_MASTER  BM on Dpt.Cmp_Id=BM.Cmp_Id
		--) As S  
		--PIVOT ( 
		--	Count([Branch_City]) for  [Branch_Name] In  ([head office],[pune] )
		--) AS PivotTable

		DECLARE @query AS VARCHAR(MAX) = ''
		SET @query = '	Select *
							from (
								SELECT Row_Number() Over(order by Department) as RowId,Department 
								FROM
								(		
									select  Dpt.Dept_Name As [Department]
										 ,Branch_City,Branch_Name
										from  T0040_DEPARTMENT_MASTER Dpt 
										Inner Join T0030_BRANCH_MASTER  BM on Dpt.Cmp_Id=BM.Cmp_Id 
									where BM.Cmp_ID = ' + Cast(@Cmp_ID as varchar(3)) + '
								) AS 
								SourceTable PIVOT (count(Branch_City) FOR Branch_Name IN  (' + @Branch_ID + ')) AS PivotTable
						) a'
		
		--select @query
		--execute(@query)
		
		--Declare @expTypeColumn as varchar(2000) = ''	
		--Select @expTypeColumn = '[' + Replace(STRING_AGG(expense_Type,','),',','] ,[') + ']'  
		--from (
		--		Select distinct Expense_Type from T0040_Expense_Type_Master	where CMP_ID = @Cmp_ID
		--)a
		
		DECLARE @sumTypeColumn as varchar(5000) = ''	
		SET @sumTypeColumn = Replace(Replace(@Branch_ID,',',',0) + '),'[','isnull([') + ',0)' 
		
		--DECLARE @colWiseSum as varchar(2000) = ''	
		--SET @colWiseSum = Replace(Replace(@expTypeColumn,',',',0)) , '),'[','Sum(isnull([') + ',0))' 
		
		
		--Declare @tableColumn as varchar(2000) = ''	
		--SELECT @tableColumn =  Replace('' + @expTypeColumn + '',',' , 'Numeric(18,2) NULL ,')  + ' Numeric(18,2) NULL ,'
		
		--select @tableColumn
		--IF OBJECT_ID('tempdb.dbo.##Finaltable', 'U') IS NOT NULL
		--		DROP TABLE ##Finaltable

		--DECLARE @sSQL Varchar(MAX) = ''
		--set @sSQL = 'CREATE TABLE ##Finaltable ( ' +
		--' [RowId]  bigint, ' +
		--' [Emp_Id]  Numeric(18,2) NULL, ' +
		--' [For_Date]  Date NULL, ' +
		--' [Particulart Expense]     VARCHAR (200) NULL, 
		--' + @tableColumn + '
		--  [Total] numeric(18,2) NULL,
		--  [Remarks] varchar(250) NULL,
		--)' 
		--execute(@sSQL)

		----CREATE TABLE #Tmptotal(
		----	RowId bigint,
		----	Emp_Id numeric(18,0),
		----	[Particulart Expense] varchar(50)
		----)
		
		----Declare @query1 as varchar(MAX) = ''
		----set @query1 = ' Insert Into #Tmptotal
		----				SELECT 99999 as RowId,Emp_ID,''Total'' as [Particulart Expense] 
		----				From #EMP_CONS'
		----execute(@query1)

		--DECLARE @Q as varchar(2000) 
		--SELECT @Q = 'NULL as ' + Replace('' + @expTypeColumn + '',',' , ', NULL as ') 

		--DECLARE @query AS VARCHAR(MAX) = ''
		--SET @query = '	--insert into ##Finaltable
		--				Select RowId,Emp_Id,For_Date,[Particulart Expense],	'+ @Branch_ID + ', ('+ @sumTypeColumn + ') as	Total,	Remarks 
		--					from (
		--						SELECT Row_Number() Over(order by Department) as RowId, '+ @Branch_ID + ', Total,Remarks
		--						FROM
		--						(		
		--							select  Dpt.Dept_Name As [Department]
		--								,Branch_Name,Branch_City
		--								from  T0040_DEPARTMENT_MASTER Dpt 
		--								Inner Join T0030_BRANCH_MASTER  BM on Dpt.Cmp_Id=BM.Cmp_Id 
		--							--inner join #EMP_CONS EC on EC.emp_ID = A.emp_id 
		--							where BM.Cmp_ID = ' + Cast(@Cmp_ID as varchar(3)) + '
		--						) AS 
		--						SourceTable PIVOT (MAX(Approved_Amount) FOR Branch_Name IN  (' + @Branch_ID + ')) AS PivotTable
		--				) a'
		
		--execute(@query)
		--select @query
		
		
	
		--select Distinct CAST(F.Emp_Id as int) as Emp_Id,E.Emp_Full_Name,E.Alpha_Emp_Code as Emp_Code,Mobile_No,B.Branch_City,D.Desig_Name
		--, Convert(varchar(20),@From_Date ,103) + '-' + Convert(varchar(20), @To_Date ,103) as Claim_Period
  --      From ##FINALTABLE F 
		--inner join T0080_EMP_MASTER E on E.Emp_id = F.Emp_ID 
		--inner join T0095_INCREMENT I on I.Emp_ID = F.EMP_ID
  --      INNER JOIN  
  --                          ( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
  --                              FROM T0095_INCREMENT I2 
  --                                  INNER JOIN 
  --                                  (
  --                                          SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
  --                                          FROM T0095_INCREMENT I3
  --                                          WHERE I3.Increment_effective_Date <= GETDATE() and I3.Cmp_ID = @Cmp_ID 
		--									and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' --AND I3.EMP_ID = @Emp_ID
  --                                          GROUP BY I3.EMP_ID  
  --                                   ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
  --                             WHERE I2.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
  --                             GROUP BY I2.emp_ID  
  --                          ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID 
		--inner join 	T0030_BRANCH_MASTER B on  b.Branch_ID = I.Branch_ID
		--inner join 	T0040_DESIGNATION_MASTER d on  D.Desig_ID = I.Desig_Id
  --      WHERE I.CMP_ID = @Cmp_ID 
		

		--Declare @qrySum as varchar(MAX) = ''
		--set @qrySum  = 'Select * from (
		--					SELECT * FROM ##FINALTABLE 
		--					union all
		--					SELECT 9999 as RowId,Emp_ID,NULL as For_Date,''Total'' as [Particulart Expense],' + @colWiseSum + ', Sum(Total) as Total  , NULL as Remarks
		--					From ##FINALTABLE Group by Emp_Id
		--				) a ORDER BY EMP_ID, ROWID ASC'
		
		--execute(@qrySum)
	
	--/////////////////////////////// Tejas /////////////////////////////////////
	--SELECT DISTINCT I.Emp_Id
	--				,Branch_ID
	--				,Dept_ID
	--				,I.Increment_ID
	--			FROM dbo.T0095_Increment I WITH (NOLOCK)
	--			INNER JOIN (
	--				SELECT max(T0095_Increment.Increment_Effective_Date) AS Increment_Effective_Date
	--					,max(T0095_Increment.Increment_ID) AS Increment_ID
	--					,max(T0095_Increment.Bank_ID) AS Bank_ID
	--					,max(T0095_Increment.Inc_Bank_AC_No) AS Inc_Bank_AC_No
	--					,T0095_Increment.Emp_ID
	--				FROM dbo.T0095_Increment WITH (NOLOCK)
	--				INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON T0095_Increment.Emp_ID = EC.Emp_ID
	--				WHERE Increment_Effective_date <= '2024-11-30'
	--					AND Cmp_ID = @Cmp_ID  
	--				GROUP BY T0095_Increment.emp_ID
	--				) Qry ON I.Emp_ID = Qry.Emp_ID
	--				AND I.Increment_Effective_Date = Qry.Increment_Effective_Date
	--				and I.Increment_ID = Qry.Increment_ID  

					--return
					
	select  ROW_NUMBER() OVER(ORDER BY T.Dept_ID ASC) AS RowID,T.Branch_ID,T.Dept_ID,DM.Dept_Name,BM.Branch_Name,T.Month_name,T.Emp_list into #EMp_List_test
	from (
	SELECT 
				I_Q.Branch_ID
				,I_Q.Dept_ID
				,BM.Month_name
				,Replace(STRING_AGG(I_Q.Emp_ID,','),',','#')as Emp_list
				,count(I_Q.Emp_ID)emp_count
			FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			LEFT OUTER JOIN dbo.T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID = l.Emp_ID
			INNER JOIN (
				SELECT DISTINCT I.Emp_Id
					,Branch_ID
					,Dept_ID
					,I.Increment_ID
				FROM dbo.T0095_Increment I WITH (NOLOCK)
				INNER JOIN (
					SELECT max(T0095_Increment.Increment_Effective_Date) AS Increment_Effective_Date
						,max(T0095_Increment.Increment_ID) AS Increment_ID
						,max(T0095_Increment.Bank_ID) AS Bank_ID
						,max(T0095_Increment.Inc_Bank_AC_No) AS Inc_Bank_AC_No
						,T0095_Increment.Emp_ID
					FROM dbo.T0095_Increment WITH (NOLOCK)
					INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON T0095_Increment.Emp_ID = EC.Emp_ID
					WHERE Increment_Effective_date <= @To_Date
						AND Cmp_ID = @Cmp_ID  
					GROUP BY T0095_Increment.emp_ID
					) Qry ON I.Emp_ID = Qry.Emp_ID
					AND I.Increment_Effective_Date = Qry.Increment_Effective_Date
					and I.Increment_ID = Qry.Increment_ID  --ronakb Bug #27284
				) I_Q ON E.Emp_ID = I_Q.Emp_ID AND E.Cmp_ID = @Cmp_ID
				INNER JOIN #BranchWisemonth BM ON BM.BRANCH_ID = I_Q.Branch_ID
			--INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON E.Emp_ID = EC.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID
				AND E.Date_Of_Join <= ISNULL(e.Emp_Left_Date, @To_Date) 
				group by I_Q.Dept_ID , I_Q.Branch_ID ,BM.Month_name   
		) as T 
		INNER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON T.Dept_Id = DM.Dept_Id
			INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON T.BRANCH_ID = BM.BRANCH_ID
			--where T.Branch_ID  = 80 
			
			IF (select COUNT(1) from #EMp_List_test) = 0
			BEGIN
				return 
			END
			
			-- Add by Manisha on 18022025--start
			Create TABLE #EMp_List 
	(
		RowID int,
		Branch_ID varchar(50),
		Dept_ID varchar(50),
		Dept_Name varchar(100),
		Branch_Name varchar(100),
		Month_name nvarchar(50),
       Emp_list  nvarchar(max)

	)
	
			declare @frbranch varchar(500)
			declare @frdept varchar(500)
			select @frbranch =replace(@BranchID,'#',''',''')
			select @frdept =replace(@DeptID,'#',''',''')
			set @frbranch = CONCAT('''',@frbranch,'''')
			set @frdept = CONCAT('''',@frdept,'''')
			--select @frbranch
		--	select @frdept
			IF DATALENGTH(@frbranch) > 2 and DATALENGTH(@frdept) > 2
			BEGIN
			set @query = 'INSERT INTO #EMp_List select *  from #EMp_List_test where  Branch_ID in ( '+ @frbranch + ') AND Dept_ID in ('+ @frdept+')'
			END
			ELSE IF DATALENGTH(@frbranch) > 2 
			BEGIN
			set @query = 'INSERT INTO #EMp_List select *  from #EMp_List_test where  Branch_ID in ( '+ @frbranch + ')'
			END
			ELSE IF DATALENGTH(@frdept) > 2
			BEGIN
				set @query = 'INSERT INTO #EMp_List select *  from #EMp_List_test where Dept_ID in ('+ @frdept+')'
			END
			ELSE
				set @query = 'INSERT INTO #EMp_List select *  from #EMp_List_test'

			--select @query
		exec (@query)
		
		-- Add by Manisha on 18022025--start
			--select * from #EMp_List
			--return
			--IF (select COUNT(1) from #EMp_List) = 0
			--BEGIN
			--Declare @strErr nvarchar(100)
			--SET @strErr = '@@ No Data Found @@';
			--				Raiserror(@strErr,18,2)
			--				return -1 

			--				End
			IF (select COUNT(1) from #EMp_List) = 0
			BEGIN
				return 
			END
			
	--//////////////////// End Tejas ////////////////////////////////////////////
	Alter Table #EMp_List Add Total_Hours varchar(15)
	Alter Table #EMp_List Add Total_DtHours varchar(15)
	--select * from #EMp_List
	
	declare @datacount int = 0
	declare @monthName varchar (20)
	declare @stcnt varchar(10) = '1'
	declare @emp_list varchar(max) = ''
	declare @tothour nvarchar(max)
	declare @DTthour nvarchar(max)
	declare @qry nvarchar(max)
	Declare @curmonth as varchar(10) = Datename(MONTH,@To_Date)
	Declare @Premonth as varchar(10) = Datename(MONTH,@previousMonthStartDate)
	select @datacount =count(1) from #EMp_List --where MONTH(Month_name + '1,1') = month(@From_Date) 
	
	
	----// data Update for Current Month /////////////////////////
	while CAST(@stcnt as numeric) <= @datacount
	BEGIN
		select @emp_list = Emp_list from #EMp_List where RowID = @stcnt
		select @monthName = Month_name from #EMp_List where RowID = @stcnt
		--select @emp_list
		
		IF @monthName = @Premonth
		BEGIN
			select @tothour = '''' + cast(CAST(ISNULL(sum(OTAP.Approved_OT_Sec)+ sum(OTAP.Approved_HO_OT_Sec)+ sum(OTAP.Approved_WO_OT_Sec),0)as numeric(10)) as varchar(50)) + ''''
			,@DTthour = cast(sum(dbo.F_Return_Sec(ISNULL(SM.Shift_End_Time,0)) - dbo.F_Return_Sec(ISNULL(SM.Shift_St_Time,0)))  as varchar(50))
			from T0160_OT_APPROVAL OTAP
			INNER JOIN #Data DM ON DM.For_date = OTAP.For_Date
			LEFT JOIN T0040_SHIFT_MASTER SM ON SM.Shift_ID = DM.Shift_ID
			where DM.Emp_ID IN (select data as Emp_ID from  dbo.Split(@emp_list,'#')) AND 
			OTAP.Emp_ID IN (select data as Emp_ID from  dbo.Split(@emp_list,'#'))
			and OTAP.For_date >= @previousMonthStartDate and OTAP.For_Date <= @previousMonthEndDate
		END
		ELSE
		BEGIN
			select @tothour = '''' + cast(ISNULL(sum(DM.OT_Sec)+ sum(DM.Holiday_OT_Sec)+ sum(DM.Weekoff_OT_Sec),0) as varchar(50)) + ''''
			,@DTthour = cast(sum(dbo.F_Return_Sec(ISNULL(SM.Shift_End_Time,0)) - dbo.F_Return_Sec(ISNULL(SM.Shift_St_Time,0)))  as varchar(50))
			from #Data DM
			LEFT JOIN T0040_SHIFT_MASTER SM ON SM.Shift_ID = DM.Shift_ID
			where DM.Emp_ID IN (select data as Emp_ID from  dbo.Split(@emp_list,'#'))  
			and DM.For_date >= DATEFROMPARTS(YEAR(@To_Date), MONTH(@monthName + '1,1'), 1) and For_Date <= EOmonth(DATEFROMPARTS(YEAR(@To_Date), MONTH(@monthName + '1,1') , 1)) 
		END
		
		set  @qry =  'update #EMp_List SET Total_Hours = ' + @tothour + ' , Total_DtHours = ' + @DTthour + ' where Rowid = ' + '''' + @stcnt + ''''
		
		--select @qry
		EXEC(@qry);
		
		set @stcnt = CAST(@stcnt as numeric) + 1
	END
	--select * INTO #EMp_List_Test from #EMp_List order by  month(CONCAT(Month_name,' 1',' 1'))
	
	--select *
	----,DBO.F_Return_Hours_D(cast(Total_Hours as numeric(19,0))) as Total_OT_Hours 
	----,DBO.F_Return_Hours_D(cast(TOtal_DtHours as numeric(19,0))) as Total_Duty_Hours 
	--from #EMp_List
	
	DECLARE @columns NVARCHAR(MAX) = '';
	DECLARE @Tabcolumns NVARCHAR(MAX) = '';
	DECLARE @ALTER_COLS NVARCHAR(MAX) = '';

	Create TABLE #OT_DATA 
	(
		Dept_Name varchar(100)
	)
	Create TABLE #DT_DATA 
	(
		Dept_Name varchar(100)
	)
	Create TABLE #VAR_DATA 
	(
		Dept_Name varchar(100)
	)

	DECLARE @PreMonthBRCount as Int
	DECLARE @CurMonthBRCount as Int
	select  @PreMonthBRCount =CounT(Distinct Branch_Name)  from #EMp_List  where Month_name = @Premonth 
	select  @CurMonthBRCount = Count(distinct Branch_Name) from #EMp_List where Month_name = DATENAME(MONTH, @To_Date) 
	if @PreMonthBRCount < @CurMonthBRCount
	BEGIN
		INSERT INTO #EMp_List
		Select Distinct RowID,Dept_ID,Branch_ID, Dept_Name,Branch_name,@Premonth,Emp_list,null,NULL  from #EMp_List  where Branch_Name not in (Select Distinct Branch_Name from #EMp_List where Month_name = @Premonth)
	END    
	select  @PreMonthBRCount =CounT(Distinct Branch_Name)  from #EMp_List  where Month_name = @Premonth 
	select  @CurMonthBRCount = Count(distinct Branch_Name) from #EMp_List where Month_name = DATENAME(MONTH, @To_Date) 
	if   @CurMonthBRCount < @PreMonthBRCount
	BEGIN
		INSERT INTO #EMp_List
		Select Distinct RowID,Dept_ID,Branch_ID,Dept_Name,Branch_name,DATENAME(MONTH, @To_Date),Emp_list,null,NULL  from #EMp_List  where Branch_Name not in (Select Distinct Branch_Name from #EMp_List where Month_name = DATENAME(MONTH, @To_Date) )
	END
	
	
	SELECT 
	  @Tabcolumns += 
	  ('['+ Branch_Name + '_' +Month_name + '],')
	FROM #EMp_List
	group by 
	Branch_Name,Month_name
    --Branch_Name + '_' + Month_name;
	IF LEN(@Tabcolumns) > 1
	SET @Tabcolumns = LEFT(@Tabcolumns, LEN(@Tabcolumns) - 1);
	set  @Tabcolumns = REPLACE(@Tabcolumns,' ','_')

	
	SELECT @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #DT_DATA ADD ' + DATA + ' VARCHAR(32)' FROM dbo.Split(@Tabcolumns, ',');
    --select @ALTER_COLS
	EXEC (@ALTER_COLS);

	
	SELECT 
	  @columns += 
	  ('['+ Branch_Name + '],')
	FROM #EMp_List
	
	--where Branch_ID in (@frbranch)
	group by 
	Branch_Name
	
	IF LEN(@columns) > 1
	SET @columns = LEFT(@columns, LEN(@columns) - 1);
	

	SET @query = '
	INSERT INTO #DT_DATA
	select *  from (
	select Dept_Name,(REPLACE(Branch_Name,'' '',''_'') + ''_'' + Month_name)as ''Branch''
	,''="'' + DBO.F_Return_Hours_D([TOtal_DtHours]) + ''"'' as Total_DT_Hours 
	from  #EMp_List
	) t 
	pivot (
	MAX(Total_DT_Hours) for Branch in (' + @Tabcolumns +')
	)AS pivot_table;'
--	select * from #EMp_List 	
	EXEC(@query)
	--Alter Table #OT_DAta Add Total numeric(18,2)
	
	
	
	set @ALTER_COLS =   ''
	SELECT @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #OT_DATA ADD ' + DATA + ' VARCHAR(32)' FROM dbo.Split(@Tabcolumns, ',');
	EXEC (@ALTER_COLS);


	SET @query = '
	INSERT INTO #OT_DATA
	select * from (
	select Dept_Name,(REPLACE(Branch_Name,'' '',''_'') + ''_'' + Month_name)as ''Branch''
	,''="'' + DBO.F_Return_Hours_D([Total_Hours]) + ''"'' as Total_OT_Hours 
	from #EMp_List
	) t 
	pivot (
	MAX(Total_OT_Hours) for Branch in (' + @Tabcolumns +')
	)AS pivot_table;'

	
	EXEC(@query)
		

	set @ALTER_COLS =   ''
	SELECT @ALTER_COLS = COALESCE(@ALTER_COLS + ';', '') + 'ALTER TABLE  #VAR_DATA ADD ' + DATA + ' VARCHAR(32)' FROM dbo.Split(@columns, ',');
	EXEC (@ALTER_COLS);
	
	select * from  #DT_DATA
	select * from #OT_DATA
	
	select * INTO #Pre_month_data from #EMp_List  where Month_name = @Premonth
	select * INTO #Cur_month_data from #EMp_List where Month_name = DATENAME(MONTH, @To_Date)


	select Dept_Name, '="' + dbo.F_Return_Hours_D(sum(CAST(ISNULL(Total_Hours,'0') as NUMERIC(10)))+sum(CAST(ISNULL(Total_DtHours,'0') as NUMERIC(10)))) + '"' Pre_Total from #Pre_month_data group by Dept_Name
	select Dept_Name, '="' + dbo.F_Return_Hours_D(sum(CAST(ISNULL(Total_Hours,'0') as NUMERIC(10)))+sum(CAST(ISNULL(Total_DtHours,'0') as NUMERIC(10)))) + '"' Cur_Total from #Cur_month_data group by Dept_Name
	
	
	
	select CD.Dept_Name,CD.Branch_Name,
	CASE WHEN CAST(CD.Total_Hours as numeric(10))-CAST(PD.Total_Hours as numeric(10)) < 0 THEN '-' ELSE '' END + 
	CASE WHEN CAST(CD.Total_Hours as numeric(15))-CAST(PD.Total_Hours as numeric(15)) < 0 THEN  dbo.F_Return_Hours_D((CAST(CD.Total_Hours as numeric(15))-CAST(PD.Total_Hours as numeric(15)))*-1)  
	ELSE  dbo.F_Return_Hours_D(CAST(CD.Total_Hours as numeric(10))-CAST(PD.Total_Hours as numeric(10))) 
	END Total_Hours  
	,CASE WHEN CAST(CD.Total_DtHours as numeric(10))-CAST(PD.Total_DtHours as numeric(10)) < 0 THEN '-' ELSE '' END + 
	CASE WHEN CAST(CD.Total_DtHours as numeric(15))-CAST(PD.Total_DtHours as numeric(15)) < 0 THEN  dbo.F_Return_Hours_D((CAST(CD.Total_DtHours as numeric(15))-CAST(PD.Total_DtHours as numeric(15)))*-1) 
	ELSE  dbo.F_Return_Hours_D(CAST(CD.Total_DtHours as numeric(10))-CAST(PD.Total_DtHours as numeric(10))) 
	END Total_DT_Hours   INTO #Variance_Data
	from #Cur_month_data CD
	LEFT JOIN #Pre_month_data PD ON PD.Dept_Name = CD.Dept_Name AND CD.Branch_Name= PD.Branch_Name
	
	--select * from #Variance_Data
	--select * from #VAR_DATA
	SET @query = '
	select * from (
	select Dept_Name,(Branch_Name)as ''Branch''
	,''="'' + [Total_DT_Hours] + ''"'' as Total_DT_Hours 
	from #Variance_Data
	) t 
	pivot (
	MAX(Total_DT_Hours) for Branch in (' + @columns +')
	)AS pivot_table;'

	EXEC(@query)

	SET @query = '
	select * from (
	select Dept_Name,(Branch_Name)as ''Branch''
	,''="'' + [Total_Hours] + ''"'' as Total_OT_Hours 
	from #Variance_Data
	) t 
	pivot (
	MAX(Total_OT_Hours) for Branch in (' + @columns +')
	)AS pivot_table;'

	EXEC(@query)

	select CD.Dept_Name,CD.Branch_Name,
	(CAST(CD.Total_Hours as numeric(10))-CAST(PD.Total_Hours as numeric(10))) +
	(CAST(CD.Total_DtHours as numeric(10))-CAST(PD.Total_DtHours as numeric(10)))
	 Total_Hours  
	   INTO #Variance_Data_Sec
	from #Cur_month_data CD
	LEFT JOIN #Pre_month_data PD ON PD.Dept_Name = CD.Dept_Name AND CD.Branch_Name= PD.Branch_Name

	--CASE WHEN CAST(CD.Total_Hours as numeric(10))-CAST(PD.Total_Hours as numeric(10)) < 0 THEN '-' ELSE '' END + 
	--CASE WHEN CAST(CD.Total_Hours as numeric(15))-CAST(PD.Total_Hours as numeric(15)) < 0 OR CAST(CD.Total_DtHours as numeric(10))-CAST(PD.Total_DtHours as numeric(10)) < 0 THEN
	--dbo.F_Return_Hours_D((CAST(CD.Total_Hours as numeric(15))-CAST(PD.Total_Hours as numeric(15)) ) + (CAST(CD.Total_DtHours as numeric(15))-CAST(PD.Total_DtHours as numeric(15))) *-1) 
	--ELSE dbo.F_Return_Hours_D((CAST(CD.Total_Hours as numeric(10))-CAST(PD.Total_Hours as numeric(10))) + (CAST(CD.Total_DtHours as numeric(15))-CAST(PD.Total_DtHours as numeric(15))) )
	--END Total_Hours  
	--select @columns
	select Dept_Name,CASE WHEN sum(Total_Hours) < 0 THEn '="-' + dbo.F_Return_Hours_D(sum(Total_Hours)*-1)+ '"' ELSE '="' + dbo.F_Return_Hours_D(sum(Total_Hours)) + '"' END Total_Hours from #Variance_Data_Sec
	group by Dept_Name

	select Branch_Name,Month_name,CONCAT('="',dbo.F_Return_Hours(sum(CAST(Total_Hours as numeric(12)))),'"')Total_Hours,CONCAT('="',dbo.F_Return_Hours(sum(CAST(Total_DtHours as numeric(12)))),'"')Total_DtHours  
	from #EMp_List
	group by Branch_Name,Month_name
	order by  month(CONCAT(Month_name,' 1',' 1'))
	
	

	select Month_name,CONCAT('="',dbo.F_Return_Hours(sum(CAST(Total_Hours as numeric(12)))+(sum(CAST(Total_DtHours as numeric(12))))),'"')Pre_Total_Hours  
	from #EMp_List
	Where Month_name = @Premonth
	group by Month_name
	UNION ALL
	select Month_name,CONCAT('="',dbo.F_Return_Hours(sum(CAST(Total_Hours as numeric(12)))+(sum(CAST(Total_DtHours as numeric(12))))),'"')Pre_Total_Hours  
	from #EMp_List
	Where Month_name <> @Premonth
	group by Month_name
	
	select 
	Branch_Name ,
	CONCAT('="',dbo.F_Return_Hours(sum(CAST(dbo.F_Return_Sec(Total_Hours) as numeric(12)))),'"')Var_Total_Hours
	,CONCAT('="',dbo.F_Return_Hours(sum(CAST(dbo.F_Return_Sec(Total_DT_Hours) as numeric(12)))),'"')Var_Total_DtHours  
	from #Variance_Data
	group by Branch_Name

	select VA.RowId
	, CONCAT('="',dbo.F_Return_Hours(sum(dbo.f_return_sec(REPLACE(Total_Hours,'-',''))) + sum(dbo.f_return_sec(REPLACE(Total_DT_Hours,'-','')))),'"')Total_Var
	from  (
	select '1' as RowID,
	*
	from #Variance_Data )VA 
	group by VA.RowId
	----group by CD.Dept_Name ,cd.Branch_Name
End