
CREATE PROCEDURE [dbo].[SP_IT_TAX_PREPARATION_EXPORT_New]
	 @Cmp_ID				numeric
	,@From_Date				Datetime
	,@To_Date				Datetime	 
	,@Branch_ID				Varchar(max)
	,@Cat_ID				Varchar(max)
	,@Grd_ID				Varchar(max)
	,@Type_ID				Varchar(max)
	,@Dept_ID				Varchar(max)
	,@Desig_Id				Varchar(max)
	,@Emp_ID				numeric
	,@Constraint			varchar(Max)
	,@Sp_Call_For			varchar(128) = 'Export'
	
AS
	set nocount on  

	IF @Branch_ID = ''  
		set @Branch_ID = null
		
	IF @Cat_ID = ''  
		set @Cat_ID = null

	IF @Grd_ID = ''  
		set @Grd_ID = null

	IF @Type_ID = ''  
		set @Type_ID = null

	IF @Dept_ID = ''  
		set @Dept_ID = null

	IF @Desig_ID = ''  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
		
	CREATE table #Tax_Report_output
	  ( 
		Row_ID numeric(18),
		FIELD_NAME varchar(500),
		Amount_Col_Final numeric(18,2),
		Amount_Col_1 numeric(18,2),
		Amount_Col_2 numeric(18,2),
		Amount_Col_3 numeric(18,2),
		Amount_Col_4 numeric(18,2),
		Default_def_ID numeric(18,0),
		AD_ID numeric(18,0),
		IT_ID  numeric(18,0),
		Emp_ID  numeric(18,0),
		Emp_Code  numeric(18),
		Alpha_Emp_Code varchar(50),
		Emp_Full_Name varchar(100),
		Desig_Name varchar(500),
		Date_Of_Join datetime,
		Pan_No varchar(50),
		P_From_Date datetime,
		P_To_Date datetime,
		Is_Show tinyint,
		Concate_Space numeric(18,0),
		Exempted_Amount numeric(18,2),
		Branch_ID numeric(18,0),
		H_From_date datetime ,
		H_To_test datetime,
		field_type tinyint,
		Show_In_SalarySlip tinyint, -- Added By Ali 05042014
		Display_Name_For_SalarySlip varchar(300), -- Added By Ali 05042014
		Column_24Q tinyint default 0 --added by hardik 19/08/2014
		,Amount_Col_Actual				NUMERIC DEFAULT 0,  -- Added By rohit For Actual Value on 04052015
		Amount_Col_Assumed			NUMERIC DEFAULT 0, -- Added by rohit For Assumed Value on 04052015
		Dept_Name varchar(Max),
		branch_Name Varchar(max),
		
		Grade_name varchar(max),---added aswini
		Tax_Regime Varchar(max) --Added by ronakk 17042023
	  )
	
	CREATE NONCLUSTERED INDEX ind_temp2 ON #Tax_Report_output(Row_ID,Emp_ID,Field_Name)
	--CREATE NONCLUSTERED INDEX ind_temp3 ON #Tax_Report_output(Emp_ID)
	--CREATE NONCLUSTERED INDEX ind_temp4 ON #Tax_Report_output(Field_Name)

	DECLARE @form_id AS INTEGER
	set @form_id = 0
	SELECT @form_id = isnull(Form_ID,0) from T0040_FORM_MASTER where Form_Name = 'Income Tax'  and Cmp_ID = @Cmp_ID
			
		
	Declare @Output_tax Table
	 (
		id numeric  PRIMARY KEY IDENTITY,
		val	nvarchar(MAX)
	  )
	  
		--Change by ronakk 07042023
	
		insert into #Tax_Report_output
		--exec SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_Id,@Emp_ID=@Emp_ID,@Constraint=@Constraint,@Product_ID=0,@Taxable_Amount_Cond=0,@Form_ID=@form_id,@Sp_Call_For = @Sp_Call_For
		exec SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID
		,@From_Date=@From_Date
		,@To_Date=@To_Date
		,@Branch_ID=@Branch_ID
		,@Cat_ID=@Cat_ID
		,@Grd_ID=@Grd_ID
		,@Type_ID=@Type_ID
		,@Dept_ID=@Dept_ID
		,@Desig_ID=@Desig_Id
		,@Emp_ID=@Emp_ID
		,@Constraint=@Constraint
		,@Product_ID=0
		,@Taxable_Amount_Cond=0
		,@Form_ID=@form_id
		,@Salary_Cycle_id=0
		,@Segment_ID=0
		,@Vertical=0
		,@SubVertical=0
		,@subBranch=0
		,@IT_Declaration_Calc_On='On_Regular'
		,@Sp_Call_For = @Sp_Call_For
		
		  


		IF @Sp_Call_For = 'Export_For_Actual'
			BEGIN
				SELECT EMP_ID, ROW_ID, 
				--REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(FIELD_NAME)), ',', '_'), '(', '_'), ')', '_'), ' ',''), '.','_') AS FIELD_NAME
				Replace(Replace(REPLACE(LTRIM(RTRIM(FIELD_NAME)), ' ', '_'),',','_'),'>','') AS FIELD_NAME
				, Amount_Col_Final INTO #TAX_REPORT_OUTPUT_TMP 
				FROM	#Tax_Report_output 
				ORDER BY EMP_ID, Row_ID
				
				DELETE FROM #TAX_REPORT_OUTPUT_TMP WHERE CHARINDEX('-', FIELD_NAME) > 0 OR RTRIM(FIELD_NAME) in('', '*') OR CHARINDEX('******',FIELD_NAME) > 0 
				

				DECLARE @SEL_COLS VARCHAR(MAX)
				DECLARE @COLS VARCHAR(MAX)
				DECLARE @QUERY VARCHAR(MAX)				
				--SELECT	@COLS = CASE WHEN CHARINDEX(FIELD_NAME, @COLS) > 0 THEN @COLS ELSE COALESCE(@COLS + ',', '') + '[' +  FIELD_NAME + ']' END						
				--FROM	(SELECT DISTINCT ROW_ID, FIELD_NAME FROM #TAX_REPORT_OUTPUT_TMP WHERE RTRIM(LTRIM(FIELD_NAME)) NOT IN ('', '*') ) T 
				--ORDER BY ROW_ID 

				SELECT	@COLS = COALESCE(@COLS +',','') + QUOTENAME(FIELD_NAME + '_' + CAST(ROW_ID AS VARCHAR(10))) ,
						@SEL_COLS = COALESCE(@SEL_COLS +',','') + QUOTENAME(FIELD_NAME + '_' + CAST(ROW_ID AS VARCHAR(10))) + ' AS ' + QUOTENAME(FIELD_NAME)
				FROM	(SELECT DISTINCT ROW_ID, FIELD_NAME FROM #TAX_REPORT_OUTPUT_TMP WHERE RTRIM(LTRIM(FIELD_NAME)) NOT IN ('', '*') ) T 
				ORDER BY ROW_ID 
				
				
				
				SET @QUERY = '	SELECT ''="'' +	Alpha_Emp_Code + ''"'' AS Alpha_Emp_Code,Name,Mobile,Work_Email,Date_Of_Birth,Join_Date,Left_Date,PAN_No,' + @SEL_COLS + '
								FROM	(Select E.Emp_Code,E.Alpha_Emp_Code,E.Emp_Full_Name AS Name,E.Mobile_No AS Mobile,Work_Email,Date_Of_Birth,
												E.Date_Of_Join AS Join_Date,E.Emp_Left_Date AS Left_Date, E.Pan_No AS Pan_no,T.Amount_Col_Final,T.FIELD_NAME + ''_'' + CAST(ROW_ID AS VARCHAR(10)) AS FIELD_NAME
										FROM	#TAX_REPORT_OUTPUT_TMP T 
												INNER JOIN T0080_EMP_MASTER E ON T.Emp_ID=E.Emp_ID ) P 
										PIVOT
										(
											Sum(Amount_Col_Final) 
											FOR FIELD_NAME IN (' + @COLS + ')
										) AS PVT'

				--PRINT @QUERY
				--SET @QUERY = '	SELECT	Emp_Code,Name,Mobile,Work_Email,Date_Of_Birth,Join_Date,Left_Date,pan_no,Basic,HRA
				--				FROM	(Select E.Emp_Code,E.Emp_Full_Name AS Name,E.Mobile_No AS Mobile,Work_Email,Date_Of_Birth,
				--								E.Date_Of_Join AS Join_Date,E.Emp_Left_Date AS Left_Date, E.Pan_No AS Pan_no,T.Amount_Col_Final,T.FIELD_NAME
				--						FROM	#TAX_REPORT_OUTPUT_TMP T 
				--								INNER JOIN T0080_EMP_MASTER E ON T.Emp_ID=E.Emp_ID ) P 
				--						PIVOT
				--						(
				--							Sum(Amount_Col_Final) 
				--							FOR FIELD_NAME IN (Basic,HRA)
				--						) AS PVT'
						
				EXEC (@QUERY)
				RETURN 
			END
		
		--select * from #Tax_Report_output
		declare @cmp_name nvarchar(100)
		declare @count_cur numeric(18)
		declare @Emp_id_cur numeric(18)
		declare @alpha_emp_code_cur nvarchar(50)
		declare @Emp_Full_name_cur nvarchar(100)
		declare @flg tinyint 
		declare @doj datetime
		declare @left_date datetime
		declare @pan nvarchar(50)
		
		--ADDED BY RAJPUT 20052017
		declare @mo_no varchar(20)
		declare @work_email nvarchar(50)
		declare @dob datetime
		---added aswini
		declare @branch varchar(50)
		declare @grade varchar(50)
		declare @dept varchar(50)
		declare @desig varchar(50)
		---ended aswini
		set @flg = 0
		set @count_cur = 4
		
		select @cmp_name = Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id = @Cmp_ID
		
		insert into @Output_tax
		select 'Company Name : ' + @cmp_name 
		
		insert into @Output_tax
		select 'Period :  ' + convert(nvarchar,@From_Date,103) + ' to ' + convert(nvarchar,@to_date,103)
		
		insert into @Output_tax
		select ' '
		
		DECLARE CUR_AD_Tax_emp CURSOR FOR 
--			select distinct(Emp_ID) , alpha_emp_code ,Emp_full_name from #Tax_Report_output
			SELECT DISTINCT(tro.Emp_ID) , tro.alpha_emp_code ,tro.Emp_full_name ,
			tro.branch_Name,tro.Grade_name,tro.Desig_Name,tro.Dept_Name,                        ---added aswini
			em.mobile_no,em.work_email,em.date_of_birth, em.date_of_join,em.emp_left_date,em.pan_no 
			from #Tax_Report_output tro inner join
			t0080_emp_master em on em.emp_id = tro.Emp_id 
		OPEN CUR_AD_Tax_emp 
		FETCH NEXT FROM CUR_AD_Tax_emp INTO @Emp_id_cur,@alpha_emp_code_cur,@Emp_Full_name_cur,@branch,@grade,@desig,@dept,@mo_no,@work_email,@dob,@doj,@left_date,@pan
		WHILE @@FETCH_STATUS =0
			BEGIN
				
				if @flg = 0
					begin
					
						insert into @Output_tax
						select( select replace(FIELD_NAME,',','/') + ','  from #Tax_Report_output 
							where Emp_ID = @Emp_id_cur order by Row_ID for xml path('') )
						
						
						update @Output_tax set val = 'Emp_Code,Name,Branch,Grade,Desig,Dept,Mobile,Work_Email,Date_Of_Birth,Join_Date,Left_Date,pan_no,' + val  where id = 4
						set @flg = 1
						
					end
						
				 set @count_cur = @count_cur + 1
				
				insert into @Output_tax
				SELECT(select cast(isnull(Amount_Col_Final,0) as nvarchar(50)) + ','  from #Tax_Report_output where Emp_ID = @Emp_id_cur order by Row_ID for xml path(''))
			      
			      
			      
			    --update @Output_tax set val =  @alpha_emp_code_cur + ',' + @Emp_Full_name_cur + ',' + val   where id = @count_cur
			    update @Output_tax set val =  '="' + @alpha_emp_code_cur + '",' + @Emp_Full_name_cur + ',' + ISNULL(@branch,'') + ',"' ++ ISNULL(@grade,'') + ',"' ++ ISNULL(@desig,'') + ',"' + ISNULL(@dept,'') + ',"' + ISNULL(@mo_no,'') + ',"' + ISNULL(@work_email,'') + '",' + isnull(convert(nvarchar(11),@dob ,103),'-') + ',' + isnull(convert(nvarchar(11),@doj ,103),'-') + ',' + isnull(convert(nvarchar(11),@left_date,103),'-')  + ',' + isnull(@pan,'-')   + ',' + val   where id = @count_cur
			   
			      
	    		FETCH NEXT FROM CUR_AD_Tax_emp INTO @Emp_id_cur,@alpha_emp_code_cur,@Emp_Full_name_cur,@branch,@grade,@desig,@dept,@mo_no,@work_email,@dob,@doj,@left_date,@pan
			END
		CLOSE CUR_AD_Tax_emp
		DEALLOCATE CUR_AD_Tax_emp  
		
		
		select val as ' '  from @Output_tax order by id
		
		
		         
	RETURN
