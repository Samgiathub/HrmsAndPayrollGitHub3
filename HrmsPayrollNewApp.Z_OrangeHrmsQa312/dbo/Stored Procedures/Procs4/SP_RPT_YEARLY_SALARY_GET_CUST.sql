
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_YEARLY_SALARY_GET_CUST]  
	@Company_id		Numeric  
	,@From_Date		Datetime
	,@To_Date 		Datetime
	,@Branch_ID		Numeric	
	,@Grade_ID 		Numeric
	,@Type_ID 		Numeric
	,@Dept_ID 		Numeric
	,@Desig_ID 		Numeric
	,@Emp_ID 		Numeric
	,@Constraint	Varchar(max)
	,@Cat_ID        Numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID	Numeric = 0 
	,@Vertical		Numeric = 0 
	,@SubVertical	Numeric = 0 
	,@subBranch		Numeric = 0 
	--,@Order_By   varchar(30) = 'Code' --Added by Jimit 29/09/2015 (To sort by Code/Name/Enroll No)

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
     If @Cat_ID = 0
        set @Cat_ID = null
        
     If @Type_id = 0
        set @Type_id = null
        
        
     if @Salary_Cycle_id   = 0
		set @Salary_Cycle_id = null
		
	if @Segment_ID = 0 
		set @Segment_ID = NULL
		
	if @Vertical = 0 
		set @Vertical = NULL
		
	if @SubVertical = 0 
		set @SubVertical = NULL
	
	if @subBranch  = 0 
		set @subBranch = NULL

  	 ---26032014--
	 --exec SP_RPT_YEARLY_SALARY_GET @Cmp_ID=9,@From_Date='2014-03-01 00:00:00',@To_Date='2014-03-31 00:00:00',@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='1359# 1997# 2082# 2550# 2112# 1586# 1986# 2026',@Report_Call='ALL1',@Salary_Cycle_id=0,@Segment_Id=0,@Vertical_Id=0,@SubVertical_Id=0,@SubBranch_Id=0
		
		CREATE TABLE #temp1
		   (row_id numeric,
			cmp_id numeric,
			emp_id numeric,
			def_id varchar(max),
			lable_name varchar(100),
			month_1 numeric(18,2),
			month_2 numeric(18,2),
			month_3 numeric(18,2),
			month_4 numeric(18,2),
			month_5 numeric(18,2),
			month_6 numeric(18,2),
			month_7 numeric(18,2),
			month_8 numeric(18,2),
			month_9 numeric(18,2),
			month_10 numeric(18,2),
			month_11 numeric(18,2),
			month_12 numeric(18,2),
			Total numeric(18,2),
			ad_id numeric,
			loan_id numeric,
			claim_id numeric,
			group_def_id numeric,
			ad_level numeric,
			grd_name varchar(100),
			dept_name varchar(100),
			desig_name varchar(100),
			branch_name varchar(100),
			type_name varchar(100),
			branch_address varchar(max),
			comp_name varchar(max),
			cmp_name varchar(100),
			cmp_address varchar(250),
			emp_code numeric,
			alpha_emp_code varchar(50),
			emp_first_name varchar(100),
			emp_full_name varchar(350),
			p_from_date datetime,
			p_to_date datetime,
			branch_id numeric,
			Emp_Pan_No varchar(30),
			Date_Of_Joining Datetime,
			Date_Of_Birth Datetime,
			Date_Of_Leaving Datetime,
			Vertical_Name varchar(50)
			--,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 29/09/2015
			--,Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 29/09/2015
			,leave_id numeric
		   )

Create table #Tbl_Yearly_Salary_Register
		(
			Emp_ID numeric(18,0),
			Ad_ID numeric(18,0),
			for_date datetime,
			E_Ad_Percentage numeric(18,5),
			E_Ad_Amount numeric(18,2)
		)
		
		Insert into #Temp1
			Exec SP_RPT_YEARLY_SALARY_GET 
			@Company_id ,
			@From_Date ,
			@To_Date ,
			@Branch_ID ,
			@Cat_ID ,
			@Grade_ID ,
			@Type_ID ,
			@Dept_ID ,
			@Desig_ID ,
			@Emp_ID ,
			@Constraint ,
			'ALL1',
			@Salary_Cycle_id ,
			@Segment_Id ,
			@Vertical ,
			@SubVertical ,
			@subBranch ,
			0,  --Mukti(03022016)
			0,  --Mukti(03022016)
			1   --Mukti(03022016)		
				
		Insert into #Temp1
			Exec SP_RPT_YEARLY_Attandance_Summary 
			@Company_id ,
			@From_Date ,
			@To_Date ,
			@Branch_ID ,
			@Cat_ID ,
			@Grade_ID ,
			@Type_ID ,
			@Dept_ID ,
			@Desig_ID ,
			@Emp_ID ,
			@Constraint ,
			'ALL1',
			@Salary_Cycle_id ,
			@Segment_Id ,
			@Vertical ,
			@SubVertical ,
			@subBranch 
	--select 111,* from #Temp1
	

	Create Table #Temp2
	(   emp_id numeric,
		lable_name varchar(max),
		def_id varchar(max),
		month_id varchar(max),
		amount numeric(18,2),
		grd_name varchar(max),
		dept_name varchar(max),
		desig_name varchar(max),
		branch_name varchar(max),
		type_name varchar(max),
		branch_address varchar(max),
		comp_name varchar(max),
		cmp_name varchar(max),
		cmp_address varchar(max),
		emp_code numeric,
		alpha_emp_code varchar(max),
		emp_first_name varchar(max),
		emp_full_name varchar(max),
		p_from_date datetime,
		p_to_date datetime,
		branch_id numeric,
		Emp_Pan_No varchar(max),
		Date_Of_Joining Datetime,
		Date_Of_Birth Datetime,
		Date_Of_Leaving Datetime,
		Row_Id Numeric
		--,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 29/09/2015
		--,Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 29/09/2015
	)

	
	
	Insert Into #temp2
	select emp_id,lable_name,def_id,month_id,amount,grd_name ,dept_name ,desig_name ,branch_name ,type_name ,branch_address ,comp_name ,cmp_name ,cmp_address ,emp_code ,alpha_emp_code ,emp_first_name ,emp_full_name ,p_from_date ,p_to_date ,branch_id ,Emp_Pan_No,convert(date,Date_Of_Joining,103),Date_Of_Birth,Date_Of_Leaving , Row_Id--,Desig_dis_No,Enroll_No
	from(
	select emp_id,Replace(lable_name,' ','_') as Lable_name,def_id,ad_id,month_1,month_2,month_3,month_4,month_5,month_6,month_7,month_8,month_9,month_10,month_11,month_12,Total,grd_name ,dept_name ,desig_name ,branch_name ,type_name ,branch_address ,comp_name ,cmp_name ,cmp_address ,emp_code ,alpha_emp_code ,emp_first_name ,emp_full_name ,p_from_date ,p_to_date ,branch_id,Emp_Pan_No,Date_Of_Joining,Date_Of_Birth,Date_Of_Leaving,row_id--,Desig_dis_No,Enroll_No
	 From #Temp1
	) as p
	unpivot
	(amount for month_id in (month_1,month_2,month_3,month_4,month_5,month_6,month_7,month_8,month_9,month_10,month_11,month_12,Total)
	)as unpvt
	
	
	
	Select * into #temp3 from #temp2

	DECLARE @temp_End_Date AS DATETIME
	
	SET @temp_End_Date = DATEADD(DAY,-1,DATEADD(YEAR,1,@From_Date))
	
	EXEC dbo.getAllDaysBetweenTwoDate @FromDate = @from_date, -- datetime
		@ToDate = @temp_End_Date -- datetime
	
	SELECT DISTINCT RIGHT(CONVERT(NVARCHAR(11),test1,106),8) AS Month_Name INTO #test1 FROM test1
	
	
	Declare @colsPivot_null as varchar(max),
			@colsPivot as varchar(max),
			@colsPivot_add as varchar(max),
			@query_leave as varchar(max)
	
	DECLARE @count AS NUMERIC 
	SET @count= 1
	DECLARE @month_name AS VARCHAR(MAX)
	
	
	
	WHILE @count <=12
	BEGIN
		SELECT @month_name = month_name FROM (SELECT ROW_NUMBER() OVER (ORDER BY CAST(month_name AS datetime)) AS Row_ID, Month_Name FROM #test1) 
					AS a WHERE Row_ID = @count
		
		
		UPDATE #temp3 
		SET month_id = @month_name
		WHERE month_id = 'Month_' + CAST(@count AS VARCHAR(MAX))
		
		SET @count = @count + 1
	END 
	
	
	select @colsPivot_null = STUFF((SELECT ', isnull(' + QUOTENAME(cast(lable_name as varchar(max))) + ',0) AS ' + QUOTENAME(cast(lable_name as varchar(max)))
									from #temp2 as a
									cross apply ( select 'lable_name' col, 1 so ) c 
									group by col,a.lable_name,so ,def_id 
									order by def_id-- CASE WHEN def_id = 0 THEN def_id ELSE def_id end
								    --order by RIGHT(REPLICATE(N' ', 500) + def_id, 500)
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

		
	
	select @colsPivot = STUFF((SELECT  ',' + QUOTENAME(cast(lable_name as varchar(max))) 
									from #temp2 as a
									cross apply ( select 'lable_name' col, 1 so ) c 
									group by col,a.lable_name,so,def_id 
									 order by def_id-- CASE WHEN def_id = 0 THEN def_id ELSE def_id end
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')
				
	
	select @colsPivot_add = STUFF((SELECT '+' + QUOTENAME(cast(lable_name as varchar(max))) 
									from #temp2 as a
									cross apply ( select 'lable_name' col, 1 so ) c 
									group by col,a.lable_name,so,def_id 
									order by def_id--CASE WHEN def_id = 0 THEN def_id ELSE def_id end
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

							
							--SELECT @colsPivot
							--SELECT @colsPivot_null
		
--''="'' + Alpha_emp_code + ''"''as Alpha_emp_code added by gadriwala 03052014
	IF @colsPivot IS NOT NULL
	BEGIN			
		set @query_leave = 'select Month_ID,''="'' + Alpha_emp_code + ''"''as Alpha_emp_code,Emp_full_name ,Grd_name ,Dept_name ,Desig_name ,Branch_name ,Type_name,Emp_Pan_No ,Date_Of_Joining,Date_Of_Birth,Date_Of_Leaving,Branch_ID,'+ IsNull(@colsPivot_null, '') +' 
				from (select Emp_ID,lable_name,Month_ID,Emp_code ,Alpha_emp_code ,Emp_full_name ,Grd_name ,Dept_name ,Desig_name ,Branch_name ,Branch_address ,Type_name ,Comp_name ,Cmp_name ,Cmp_address ,p_from_date ,p_to_date,Emp_Pan_No ,Date_Of_Joining,Date_Of_Birth,Date_Of_Leaving,Amount,Branch_ID from #temp3) 
				as data pivot 
				( sum(Amount) 
				for lable_name in ('+ IsNull(@colsPivot,'') +') ) p
				order by Emp_ID,case when month_id = ''Total'' then ''' + cast(@To_date as varchar(20)) +''' else cast(month_id as datetime) end' 
				
--		print @colsPivot
				--Order By CASE WHEN ' + @Order_By + ' = ''Enroll_No'' THEN RIGHT(REPLICATE(''0'',21) + CAST(Enroll_No AS VARCHAR), 21)  
				--			WHEN ' + @Order_By + ' = ''Name'' THEN Emp_Full_Name 
				--			When ' + @Order_By + ' = ''Designation'' then (CASE WHEN CAst(Desig_dis_No As VARCHAR) = ''0'' THEN Alpha_Emp_Code ELSE CAst(Desig_dis_No As VARCHAR) END) 
				--			ELSE RIGHT(REPLICATE(N'' '', 500) + Alpha_Emp_Code, 500)
				--		End
				
	END
	ELSE
	BEGIN 
		set @query_leave = 'select Month_ID,''="'' + Alpha_emp_code + ''"''as Alpha_emp_code,Emp_full_name ,Grd_name ,Dept_name ,Desig_name ,Branch_name ,Type_name,Emp_Pan_No ,Date_Of_Joining,Date_Of_Birth,Date_Of_Leaving,Branch_ID
			from (select Emp_ID,lable_name,Month_ID,Emp_code ,Alpha_emp_code ,Emp_full_name ,Grd_name ,Dept_name ,Desig_name ,Branch_name ,Branch_address ,Type_name ,Comp_name ,Cmp_name ,Cmp_address ,p_from_date ,p_to_date,Emp_Pan_No ,Date_Of_Joining,Date_Of_Birth,Date_Of_Leaving,Amount,Branch_ID from #temp3) as data 
			order by Emp_ID,case when month_id = ''Total'' then ''' + cast(@To_date as varchar(20)) +''' else cast(month_id as datetime) end' 
			
			--Order By CASE WHEN ' + @Order_By + ' = ''Enroll_No'' THEN RIGHT(REPLICATE(''0'',21) + CAST(Enroll_No AS VARCHAR), 21)  
			--				WHEN ' + @Order_By + ' = ''Name'' THEN Emp_Full_Name 
			--				When ' + @Order_By + ' = ''Designation'' then (CASE WHEN CAst(Desig_dis_No As VARCHAR) = ''0'' THEN Alpha_Emp_Code ELSE CAst(Desig_dis_No As VARCHAR) END) 
			--				ELSE RIGHT(REPLICATE(N'' '', 500) + Alpha_Emp_Code, 500)
			--			End'
	END

	--select * from #Temp1
	
	exec (@query_leave)
	
	
	drop table #temp3

	 ---26032014--
	
	
Return