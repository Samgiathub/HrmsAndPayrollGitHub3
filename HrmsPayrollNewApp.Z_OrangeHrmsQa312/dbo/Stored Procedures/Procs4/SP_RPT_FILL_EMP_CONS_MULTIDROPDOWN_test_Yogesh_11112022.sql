

CREATE PROCEDURE [DBO].[SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN_test_Yogesh_11112022]          
  @Cmp_ID			numeric          
 ,@From_Date		datetime          
 ,@To_Date			datetime          
 ,@Branch_ID		varchar(MAX)     
 ,@Cat_ID			varchar(MAX)            
 ,@Grd_ID			varchar(MAX)        
 ,@Type_ID			varchar(MAX)          
 ,@Dept_ID			varchar(MAX)            
 ,@Desig_ID			varchar(MAX)            
 ,@Emp_ID			numeric          
 ,@constraint		VARCHAR(MAX)          
 ,@Sal_Type			numeric = 0      
 ,@Salary_Cycle_id	numeric = 0  
 ,@Segment_Id		varchar(MAX) =0
 ,@Vertical_Id		varchar(MAX)=0
 ,@SubVertical_Id	varchar(MAX) =0
 ,@SubBranch_Id		varchar(MAX) =0
 ,@New_Join_emp		Numeric = 0 
 ,@Left_Emp			Numeric = 0
 ,@SalScyle_Flag	Numeric = 0	 
 ,@PBranch_ID		varchar(MAX) = 0
 ,@With_Ctc			Numeric = 0
 ,@Type				numeric = 0
AS 
Set Nocount on 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @W_SQL Varchar(Max)
	Declare @Where_To_Date Varchar(Max) 
	Declare @Where_From_Date Varchar(Max)
	Declare @Where1 Varchar(Max) 
		
	Declare @Cmp_Id_Str varchar(200) --Added by Hardik 23/01/2020 for Daily Attendance Report and Joining_Left Report for Group Company Wise, for Jyote Motors

	SET  @W_SQL	 = ''
	SET  @Where_From_Date	 = Cast(@From_Date As Varchar(11))
	SET  @Where_To_Date	 = Cast(@To_Date As Varchar(11))
	SET  @Where1	 = ''



	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0



	SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
	FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'

	IF @Branch_ID = '' or @Branch_ID = '0'           
	  SET @Branch_ID = Null          
      
	IF @Cat_ID = '' or @Cat_ID = '0'         
	  SET @Cat_ID = null          
       
	IF @Grd_ID = '' or @Grd_ID = '0'            
	  SET @Grd_ID = null          
       
	IF @Type_ID = '' or @Type_ID = '0'           
	  SET @Type_ID = null          
       
	IF @Dept_ID = '' or @Dept_ID = '0'         
	  SET @Dept_ID = null          
       
	IF @Desig_ID = '' or @Desig_ID = '0'          
	  SET @Desig_ID = null          
       
	IF @Emp_ID = 0            
	  SET @Emp_ID = null          
      
	IF @Segment_Id = ''  or @Segment_Id = '0'  
	  SET @Segment_Id = null    
  
	IF @Vertical_Id= ''   or @Vertical_Id= '0' 
	  SET @Vertical_Id = null    
  
	IF @SubVertical_Id = '' or  @SubVertical_Id = '0'  
	  SET @SubVertical_Id= Null    
  
	IF @SubBranch_Id = ''  or @SubBranch_Id = '0'
	  SET @SubBranch_Id = null 

	if @PBranch_ID = '' or @PBranch_ID = '0' --Added By Jaina 21-09-2015
		set @PBranch_ID = null

	---change by nilay : 26/112014
	if @Salary_Cycle_id = 0
	  SET @Salary_Cycle_id = null  
  
  
  ---change by nilay : 26/112014

             if @Cat_ID is not null
				Begin 
					Set @Where1 = ' and ISNULL(VE.Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Cat_ID AS varchar(max)) + ''',ISNULL(VE.Cat_ID,0)),''#'') )'
				End
		     if @Branch_ID is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Branch_ID AS varchar(max)) + ''',ISNULL(VE.Branch_ID,0)),''#'') ) '
				End
			 if @Grd_ID is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Grd_ID AS varchar(max)) + ''',ISNULL(VE.Grd_ID,0)),''#'') )  '
				End
			  if @Dept_ID is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Dept_ID AS varchar(max)) + ''',ISNULL(VE.Dept_ID,0)),''#'') ) '
				End
		      if @Type_ID is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Type_ID AS varchar(max)) + ''',ISNULL(VE.Type_ID,0)),''#'') ) '
				End
			 if @Desig_ID is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Desig_ID AS varchar(max)) + ''',ISNULL(VE.Desig_ID,0)),''#'') ) '
				End           
			 	           
			  if @Segment_Id is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Segment_Id AS varchar(max)) + ''',ISNULL(VE.Segment_ID,0)),''#'') ) '
				End	           
				
			 if @Vertical_Id is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Vertical_Id AS varchar(max)) + ''',ISNULL(VE.Vertical_ID,0)),''#'') )  '
				End	           
			
			 if @SubVertical_ID is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@SubVertical_ID AS varchar(max)) + ''',ISNULL(VE.SubVertical_ID,0)),''#'') ) '
				End	           
				           
			if @SubBranch_Id is not null
				Begin 
					Set @Where1 = @Where1 + ' and ISNULL(VE.subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@SubBranch_Id AS varchar(max)) + ''',ISNULL(VE.subBranch_ID,0)),''#'') )'					
				End
					           
			if @Emp_ID is not null
				Begin 
					Set @Where1 = @Where1 + 'AND ISNULL(VE.Emp_ID,0) = isnull(''' + Cast(@Emp_ID AS varchar(max)) + ''',isnull(VE.Emp_ID,0)) '
				End	
				
			if @Salary_Cycle_id is not null
				Begin 
				
					Set @Where1 = @Where1 + 'and isnull(QrySC.SalDate_id,0) = isnull(''' + Cast(@Salary_Cycle_id AS varchar(max)) + ''',isnull(QrySC.SalDate_id,0)) '
				End	
			
			if @PBranch_ID  is not null  --Change By Jaina 21-09-2015
				Begin 
					Set @Where1 = @Where1 + 'and ISNULL(VE.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@PBranch_ID AS varchar(max)) + ''',ISNULL(VE.Branch_ID,0)),''#'') ) '
				End		
    
	IF @Constraint <> ''
		BEGIN
			print 'a'
			INSERT INTO #Emp_Cons
			SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T
			
			UPDATE  E 
			SET		Branch_ID = I.Branch_ID, Increment_ID=I.Increment_ID
			FROM	#Emp_Cons E						
					INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
															INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																		FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
																		WHERE	I3.Increment_Effective_Date <= @To_Date
																		GROUP BY I3.Emp_ID
																		) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
													WHERE	I2.Cmp_ID = @Cmp_Id 
													GROUP BY I2.Emp_ID
													) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
								WHERE	I1.Cmp_ID=@Cmp_Id											
							) I ON E.EMP_ID=I.Emp_ID
		END
	ELSE IF @New_Join_emp = 1 and @SalScyle_Flag = 0
		BEGIN
			print 'b'
			--print 1
			/*INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
			FROM V_Emp_Cons VE INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle 
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_id=@Cmp_ID 
				and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') ) 
				and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )
				and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') )  
				and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
				and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') ) 
				and ISNULL(VE.Emp_ID,0) = isnull(@Emp_ID ,VE.Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			ORDER BY Emp_ID
						
			DELETE FROM #Emp_Cons WHERE Increment_ID Not In
				(SELECT TI.Increment_ID FROM t0095_increment TI inner join
					(SELECT Max(Increment_ID) AS Increment_ID,Emp_ID FROM T0095_Increment
						WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
				ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
				WHERE Increment_effective_Date <= @to_date)
				
				INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
			 */
			Set @W_SQL = 'INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
					FROM dbo.V_Emp_Cons VE WITH (NOLOCK)
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
														and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + '''  
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_id= ''' + Cast(@Cmp_ID As Varchar(100)) + '''   
				and Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + '''
				and Date_of_Join >= ''' + Cast( @From_Date As Varchar(100)) + ''' and Date_OF_Join <= ''' + Cast(@To_Date As Varchar(100)) + ''' '+ @Where1 +'
			ORDER BY Emp_ID'
			
			Exec(@W_SQL)
			
			-- Added by nilesh patel on 05122014 --start
				--DELETE E FROM #Emp_Cons E Left join 
				--	(SELECT Max(Increment_ID) AS Increment_ID,Emp_ID FROM T0095_Increment
				--			WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) as new_inc
				--	on E.Increment_ID = new_inc.Increment_ID and E.Emp_ID = new_inc.Emp_ID
				--where ISNULL(new_inc.Increment_ID,0) = 0
			-- Added by nilesh patel on 05122014 --End
			
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
				
		END	
	ELSE IF @TYPE = 4 -- For FNF Emp
		Begin
			print'c'
			--print 2
			/*INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
			FROM V_Emp_Cons VE INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle 
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_id=@Cmp_ID 
				and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') ) 
				and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') )
				AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))      
				and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
				and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)   
                and VE.Emp_ID in   
                ( select Emp_Id from  
                (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
                where cmp_ID = @Cmp_ID  )
               ORDER BY Emp_ID  */
          
            Set @W_SQL = 'INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
			FROM V_Emp_Cons VE WITH (NOLOCK) INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
														WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
														and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_id = ' + Cast(@Cmp_ID As Varchar(100)) + '     
                and VE.Emp_ID in   
                ( select Emp_Id from  
                (select emp_id, cmp_ID, join_Date, isnull(left_Date, ''' + Cast(@To_Date As Varchar(100)) + ''') as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry  
                where cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + '  ) '+ @Where1 +'
               ORDER BY Emp_ID'
            Exec(@W_SQL)
            
		End
	ELSE IF @TYPE = 5 -- For Rotation Dashboard Summary Report ''Added by nilesh patel on 25022015
		Begin
			--print 3
			print 'd'


			if @Cmp_ID=0
				Select @Cmp_Id_Str =  COALESCE(@Cmp_Id_Str + ',','') + CAST(Cmp_Id AS varchar(10)) from T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1
			else
				Set @Cmp_Id_Str = @Cmp_ID

			Set @W_SQL ='INSERT INTO #Emp_Cons 	
			  SELECT DISTINCT Emp_ID,VE.branch_id,Increment_ID 
			  FROM dbo.V_Emp_Cons VE WITH (NOLOCK)  inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on VE.branch_id=g.branch_id 
		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
							and cmp_id in (''' + @Cmp_Id_Str + ''')
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = VE.Emp_ID
			  WHERE VE.Cmp_id in ( ' + @Cmp_Id_Str + ' )
				   '+ @Where1 + '
				   AND Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
			ORDER BY Emp_ID'

			
			Exec(@W_SQL)	
			
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
		End 
	ELSE IF @Left_Emp = 1  and @SalScyle_Flag = 0
		BEGIN
			--print 4
			/*INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
			FROM V_Emp_Cons VE INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle 
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_id=@Cmp_ID 
				and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') ) 
				and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') )
				AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))      
				and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
				and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Left_date >=@From_Date and Left_Date <=@to_Date
			ORDER BY Emp_ID 
			
			
			DELETE FROM #Emp_Cons WHERE Increment_ID Not In
				(SELECT TI.Increment_ID from t0095_increment TI inner join
					(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
						WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
					ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
				WHERE Increment_effective_Date <= @to_date)
				 INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID
			*/
			print 'e'
			Set @W_SQL = 'INSERT INTO #Emp_Cons      
			SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
					FROM V_Emp_Cons VE WITH (NOLOCK)  
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
														and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE VE.Cmp_id= ' + Cast(@Cmp_ID As Varchar(100)) + ' 
				and Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + '''
				and Left_date >= ''' + Cast(@From_Date As Varchar(100)) + ''' and Left_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' '+ @Where1 +'
			ORDER BY Emp_ID'
			Exec(@W_SQL)	
			
			-- Comment by nilesh patel on 05122014 --Start
				--DELETE E FROM #Emp_Cons E  Left join 
				--	(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
				--			WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) as new_inc
				--	On E.Increment_ID  = new_inc.Increment_ID and E.Emp_ID = new_inc.Emp_ID
				--Where Isnull(new_inc.Increment_ID,0) = 0
			-- Comment by nilesh patel on 05122014 --End
			
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
			
		END	
	ELSE IF @SalScyle_Flag = 1	-- Use SP : Set_Salary_Register_Amount
		BEGIN
			print 'f'
			 --print 5
			/*INSERT INTO #Emp_Cons 
			SELECT I.Emp_Id,I.Branch_ID,I.Increment_ID 
			FROM T0095_Increment I INNER JOIN 
					( SELECT max(Increment_ID) as Increment_ID , Emp_ID FROM T0095_Increment
						WHERE Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						GROUP BY emp_ID  ) Qry ON
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
						  LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
						  INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date
									GROUP BY emp_id) Qry on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				   ON QrySC.eid = Qry.Emp_ID
			WHERE Cmp_ID = @Cmp_ID 
				and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
	   			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
				and I.Emp_ID IN 
					( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
						where cmp_ID = @Cmp_ID   and  
						(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )
						or Left_date is null and @To_Date >= Join_Date)
						or @To_Date >= left_date  and  @From_Date <= left_date )*/
			
			Set @W_SQL = 'INSERT INTO #Emp_Cons 
			SELECT VE.Emp_Id,VE.Branch_ID,VE.Increment_ID 
			FROM T0095_Increment VE WITH (NOLOCK) INNER JOIN 
					( SELECT max(Increment_ID) as Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
						WHERE Increment_Effective_date <= ''' + cast(@To_Date As varchar(100)) + '''
						and Cmp_ID = ' + cast(@Cmp_ID As Varchar(100)) + '  
						GROUP BY emp_ID  ) Qry ON
						VE.Emp_ID = Qry.Emp_ID and VE.Increment_ID = Qry.Increment_ID
						  LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
						  INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= ''' + cast(@To_Date As varchar(100)) + '''
									GROUP BY emp_id) Qry on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
				   ON QrySC.eid = Qry.Emp_ID
			WHERE Cmp_ID = ' + cast(@Cmp_ID As Varchar(100)) + ' 
				and VE.Emp_ID IN 
					( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, ''' + cast(@To_Date As varchar(100)) + ''') as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_ID = ' + cast(@Cmp_ID As Varchar(100)) + '    and  
						(( ''' + cast(@From_Date As varchar(100)) + '''  >= join_Date  and  ''' + cast(@From_Date As varchar(100)) + ''' <= left_date ) 
						or ( ''' + cast(@To_Date As varchar(100)) + '''  >= join_Date  and ''' + cast(@To_Date As varchar(100)) + ''' <= left_date )
						or Left_date is null and ''' + cast(@To_Date As varchar(100)) + ''' >= Join_Date)
						or ''' + cast(@To_Date As varchar(100)) + ''' >= left_date  and  ''' + cast(@From_Date As varchar(100)) + ''' <= left_date )'+ @Where1 + ''
			 Exec(@W_SQL)
			 	
		END
	ELSE IF @SalScyle_Flag = 2	-- Use SP : Set_Salary_Wages_Register_Amount_With_Late,Set_Salary_Register_Amount_NIIT
		BEGIN
			print 'g'
			--print 6
			IF @PBranch_ID <> '0' and @Branch_ID is null --isnull(@Branch_ID,0) = 0  -- added by mitesh on 02042012
				BEGIN
					
					/*INSERT INTO #Emp_Cons
					select I.Emp_Id, I.Branch_ID,I.Increment_ID  from dbo.T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
					Where Cmp_ID = @Cmp_ID 
						and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
						and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
						and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )
						and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
						and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') )
						and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0)) 
						and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@PBranch_ID,ISNULL(Branch_ID,0)),'#') ) 
						and I.Emp_ID in 
						( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
						where cmp_ID = @Cmp_ID   and  
						(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )
						or Left_date is null and @To_Date >= Join_Date)
						or @To_Date >= left_date  and  @From_Date <= left_date ) */
					Set @W_SQL = 'INSERT INTO #Emp_Cons
					select VE.Emp_Id, VE.Branch_ID,VE.Increment_ID  from dbo.T0095_Increment VE WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
							and Cmp_ID = ' + cast(@Cmp_ID As Varchar(100)) + '
							group by emp_ID  ) Qry on
							VE.Emp_ID = Qry.Emp_ID	and VE.Increment_ID = Qry.Increment_ID
					Where Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + '
						 and VE.Emp_ID in 
						( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, ''' + Cast(@To_Date As Varchar(100)) + ''') as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + '   and  
						(( ''' + Cast(@From_Date As Varchar(100)) + '''  >= join_Date  and  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date ) 
						or ( ''' + Cast(@To_Date As Varchar(100)) + '''  >= join_Date  and ''' + Cast(@To_Date As Varchar(100)) + ''' <= left_date )
						or Left_date is null and ''' + Cast(@To_Date As Varchar(100)) + ''' >= Join_Date)
						or ''' + Cast(@To_Date As Varchar(100)) + ''' >= left_date  and  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )'+ @Where1 + ''
						Exec(@W_SQL)
					
				END
			ELSE
				BEGIN
					print 'h'
					--print 7
					/*INSERT INTO #Emp_Cons
					SELECT I.Emp_Id,I.Branch_ID,I.Increment_ID from dbo.T0095_Increment I INNER JOIN 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
					WHERE Cmp_ID = @Cmp_ID 
						and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
						and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
						and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
						and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
						and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
						and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
						and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0)) 
						and I.Emp_ID in 
						( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
						where cmp_ID = @Cmp_ID   and  
						(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )
						or Left_date is null and @To_Date >= Join_Date)
						or @To_Date >= left_date  and  @From_Date <= left_date )*/ 
					Set @W_SQL = 'INSERT INTO #Emp_Cons
					SELECT VE.Emp_Id,VE.Branch_ID,VE.Increment_ID from dbo.T0095_Increment VE WITH (NOLOCK) INNER JOIN 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
							and Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + '
							group by emp_ID  ) Qry on
							VE.Emp_ID = Qry.Emp_ID and VE.Increment_ID = Qry.Increment_ID
					WHERE Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + ' 
						and VE.Emp_ID in 
						( select Emp_Id from
						(select emp_id, cmp_ID, join_Date, isnull(left_Date, ''' + Cast(@To_Date As Varchar(100)) + ''') as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + '    and  
						(( ''' + Cast(@From_Date As Varchar(100)) + '''  >= join_Date  and  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date ) 
						or ( ''' + Cast(@To_Date As Varchar(100)) + '''  >= join_Date  and ''' + Cast(@To_Date As Varchar(100)) + ''' <= left_date )
						or Left_date is null and ''' + Cast(@To_Date As Varchar(100)) + ''' >= Join_Date)
						or ''' + Cast(@To_Date As Varchar(100)) + ''' >= left_date  and  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )'+ @Where1 + ''
						Exec(@W_SQL)
				END
		END
	ELSE IF @With_Ctc = 1		-- Use SP : SP_RPT_YEARLY_SALARY_GET
		BEGIN
				print 'i'
				--print 8
				/*INSERT INTO #Emp_Cons
				SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V 
					INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle 
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = V.Emp_ID
				WHERE 
				   V.cmp_id=@Cmp_ID 
				   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				   and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				   and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				   and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				   and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				   and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))
				   and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				   and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				   and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				   and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
				   and ms.month_end_date >= @from_date and ms.month_end_date <= @to_date
				   and ms.Is_FNF = 0
				   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
				   AND Increment_Effective_Date <= @To_Date 
				   AND ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
				ORDER BY Emp_ID
				
				DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment
					WHERE  Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID
					GROUP BY emp_ID )
				*/
				
				Set @W_SQL = 'INSERT INTO #Emp_Cons
				SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID FROM V_Emp_Cons VE WITH (NOLOCK) 
					INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
					LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= ''' + cast(@To_Date As Varchar(100)) + '''
														and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = VE.Emp_ID
				WHERE 
				   VE.cmp_id=' + cast(@Cmp_ID As Varchar(100)) + '
				   and ms.month_end_date >= ''' + cast(@from_date As Varchar(100)) + ''' and ms.month_end_date <= ''' + cast(@To_Date As Varchar(100)) + '''
				   and ms.Is_FNF = 0 
				   AND Increment_Effective_Date <= ''' + cast(@To_Date As Varchar(100)) + ''' 
				   AND ( (''' + cast(@from_date As Varchar(100)) + '''  >= join_Date  AND  ''' + cast(@from_date As Varchar(100)) + ''' <= left_date )      
						OR ( ''' + cast(@To_Date As Varchar(100)) + '''  >= join_Date  AND ''' + cast(@To_Date As Varchar(100)) + ''' <= left_date )      
						OR (Left_date IS NULL AND ''' + cast(@To_Date As Varchar(100)) + ''' >= Join_Date)      
						OR (''' + cast(@To_Date As Varchar(100)) + ''' >= left_date  AND  ''' + cast(@from_date As Varchar(100)) + ''' <= left_date )
						OR 1=(case when ( (left_date <= ''' + cast(@To_Date As Varchar(100)) + ''') and (dateadd(mm,1,Left_Date) > ''' + cast(@from_date As Varchar(100)) + ''' ))  then 1 else 0 end)
						)'+ @Where1 + '
				ORDER BY Emp_ID'
				Exec(@W_SQL)
				-- Comment by nilesh patel on 05122014 --Start
					--DELETE E  FROM #Emp_Cons E Left join (SELECT MAX(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
					--	WHERE  Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID
					--	GROUP BY emp_ID )as inc_d 
					--	on  E.Increment_ID  =  inc_d.Increment_ID and E.emp_id = inc_d.Emp_ID
					--Where ISNULL(inc_d.Increment_ID,0) = 0
				-- Comment by nilesh patel on 05122014 --End
				
				Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
				Where Qry.Increment_ID is null
				
		END
	ELSE IF @SalScyle_Flag = 3	--Use Sp : SP_RPT_EMP_ATTENDANCE_MUSTER_GET
		BEGIN
			IF @Type = 0 -- All Employee
				BEGIN
					print 'j'
						--print 9
					 /*INSERT INTO #Emp_Cons  
					 SELECT DISTINCT emp_id,branch_id,Increment_ID 
					 FROM V_Emp_Cons 
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle 
										WHERE Effective_date <= @To_Date GROUP BY emp_id) Qry
									ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
								ON QrySC.eid = V_Emp_Cons.Emp_ID
					 WHERE cmp_id=@Cmp_ID 
						   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				           and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				           and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				           and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				           and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				           and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				           and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				           and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				           and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				           and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
			
						   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
						   and Increment_Effective_Date <= @To_Date 
						   and 
							( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
							or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
							or (Left_date is null and @To_Date >= Join_Date)
							)
					 ORDER BY Emp_ID
					 
					 DELETE FROM #Emp_Cons WHERE Increment_ID NOT IN
						(SELECT TI.Increment_ID FROM t0095_increment TI INNER JOIN
							(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
								WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
							on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
						WHERE Increment_effective_Date <= @to_date) 
					 */

					if @Cmp_ID=0
						Select @Cmp_Id_Str =  COALESCE(@Cmp_Id_Str + ',','') + CAST(Cmp_Id AS varchar(10)) from T0010_COMPANY_MASTER WITH (NOLOCK) Where is_GroupOFCmp = 1
					else
						Set @Cmp_Id_Str = @Cmp_ID
							 
					 Set @W_SQL = 'INSERT INTO #Emp_Cons 		
					 SELECT DISTINCT emp_id,branch_id,Increment_ID 
					 FROM V_Emp_Cons VE WITH (NOLOCK)
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
										WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
										---and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ')'' 
										and cmp_id in (' + @Cmp_Id_Str + ')
										GROUP BY emp_id) Qry
									ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
								ON QrySC.eid = VE.Emp_ID
					 --WHERE VE.cmp_id= ' + Cast(@Cmp_ID As Varchar(100)) + '  
					 WHERE VE.cmp_id in (' + @Cmp_Id_Str + ')  
						   and Increment_Effective_Date <= ''' + @Where_To_Date + '''
						   AND join_Date <= '''+ @Where_To_Date +  '''
						   AND IsNull(Left_Date, '''  + @Where_To_Date + ''') >= '''+ @Where_From_Date+  '''
						   '+ @Where1 + '
					 ORDER BY Emp_ID'

					 Exec(@W_SQL)
					 
					-- Comment by nilesh patel on 05122014 --Start 
						--DELETE E FROM #Emp_Cons E Left join 
						--		(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
						--			WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
						--	on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
						--Where ISNULL(new_inc.Increment_ID,0) = 0
					-- Comment by nilesh patel on 05122014 --End
					
					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null
				
			END
			ELSE IF @Type = 1 -- Active Employee
				BEGIN
					print 'k'
					--print 10
					 /*INSERT INTO #Emp_Cons  
					 SELECT DISTINCT emp_id,branch_id,Increment_ID FROM V_Emp_Cons 
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id 
										FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date GROUP BY emp_id) Qry
								ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
							ON QrySC.eid = V_Emp_Cons.Emp_ID
					  WHERE cmp_id=@Cmp_ID
						   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				           and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				           and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				           and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				           and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				           and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') )			   
						   and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				           and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				           and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				           and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
			
						   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
						   and Increment_Effective_Date <= @To_Date 
						   and (V_Emp_Cons.Emp_Left = 'N' Or V_Emp_Cons.Emp_Left = 'n')					  
						   and 
						   ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
							or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
							or (Left_date is null and @To_Date >= Join_Date)						)
					  ORDER BY Emp_ID
					  
					  	DELETE FROM #Emp_Cons WHERE Increment_ID Not In
							(SELECT TI.Increment_ID FROM t0095_increment TI inner join
								(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
									WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
							WHERE Increment_effective_Date <= @to_date) 
					  */
					 	
					 Set @W_SQL = 'INSERT INTO #Emp_Cons  
					 SELECT DISTINCT emp_id,branch_id,Increment_ID FROM V_Emp_Cons VE WITH (NOLOCK)
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id 
										FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
										and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
										GROUP BY emp_id) Qry
								ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
							ON QrySC.eid = VE.Emp_ID
					  WHERE cmp_id= ' + Cast(@Cmp_ID As Varchar(100)) + '  
						   and Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + '''
						   and (Left_date is null OR Left_Date > ''' + Cast(@To_Date As Varchar(100)) + ''') and join_Date <= ''' + Cast(@To_Date As Varchar(100)) + '''
						   '+ @Where1 + ' 
						 --  ( (''' + Cast(@From_Date As Varchar(100)) + '''  >= join_Date  and  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )      
						--	or ( ''' + Cast(@To_Date As Varchar(100)) + '''  >= join_Date  and ''' + Cast(@To_Date As Varchar(100)) + ''' <= left_date )      
						--	)'+ @Where1 + '
					  ORDER BY Emp_ID'

					  Print @W_SQL
					  Exec(@W_SQL)
					  -- Comment by nilesh patel on 05122014 --Start
						 -- DELETE E FROM #Emp_Cons E Left join 
							--	(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
							--		WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
							--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
						 -- Where ISNULL(new_inc.Increment_ID,0) = 0 
					  -- Comment by nilesh patel on 05122014 --End
					  
					  Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
					  Where Qry.Increment_ID is null
				
				END
			ELSE IF @Type = 2 -- InActive Employee
				BEGIN
					print 'l'
					--print 11
					/*INSERT INTO #Emp_Cons  
					SELECT DISTINCT emp_id,branch_id,Increment_ID from V_Emp_Cons 
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle 
										WHERE Effective_date <= @To_Date GROUP BY emp_id) Qry
								on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
						ON QrySC.eid = V_Emp_Cons.Emp_ID
					 WHERE cmp_id=@Cmp_ID 
						   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				           and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				           and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				           and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				           and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				           and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') )			   
						   and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				           and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				           and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				           and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
			
						   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
						   and Increment_Effective_Date <= @To_Date 
						   and (V_Emp_Cons.Emp_Left = 'Y' Or V_Emp_Cons.Emp_Left = 'y')					  
						   and (--(@From_Date  >= join_Date  and  @From_Date <= left_date )   
							--or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
							--or (Left_date is null and @To_Date >= Join_Date)      
							(@To_Date >= left_date  and  @From_Date <= left_date )
							--OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date )) then 1 else 0 end))
							)
					 ORDER BY Emp_ID
					 
					 DELETE FROM #Emp_Cons WHERE Increment_ID Not In
					(SELECT TI.Increment_ID from t0095_increment TI inner join
						(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
						WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
						ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
					 WHERE Increment_effective_Date <= @to_date)  
					 
					 */
					 
					Set @W_SQL = 'INSERT INTO #Emp_Cons  
					SELECT DISTINCT emp_id,branch_id,Increment_ID from V_Emp_Cons VE WITH (NOLOCK)
							LEFT OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							INNER JOIN (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
										WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
										and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
										GROUP BY emp_id) Qry
								on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
						ON QrySC.eid = VE.Emp_ID
					 WHERE cmp_id= ' + Cast(@Cmp_ID As Varchar(100)) + ' 
						   and Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
						   and (VE.Emp_Left = ''Y'' Or VE.Emp_Left = ''y'')					  
						   and ((''' + Cast(@To_Date As Varchar(100)) + ''' >= left_date  and  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date ))'+ @Where1 + '
					 ORDER BY Emp_ID'				
					Exec(@W_SQL) 
					
					 -- Comment by nilesh patel on 05122014 --Start
					 --DELETE E FROM #Emp_Cons E Left join 
						--	(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
						--		WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
						--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
					 -- Where ISNULL(new_inc.Increment_ID,0) = 0 
					 -- Comment by nilesh patel on 05122014 --End
					 
					 Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
					  Where Qry.Increment_ID is null
				
				END
		END
	ELSE IF @SalScyle_Flag = 4	--Use Sp : SP_RPT_Form_ER_1
		BEGIN
			
			IF @New_Join_emp = 1
				BEGIN
					IF @PBranch_ID <> '0' and @Branch_ID is null
						BEGIN
							print 'm'
							/*INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE 
								INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle 
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=@Cmp_ID
								and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				                and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				                and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				                and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				                and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				                and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				                and ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))
				                and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				                and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				                and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				                and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
							ORDER BY Emp_ID
							
							DELETE FROM #Emp_Cons WHERE Increment_ID Not In
								(SELECT TI.Increment_ID FROM t0095_increment TI inner join
									(SELECT Max(Increment_ID) AS Increment_ID,Emp_ID FROM T0095_Increment
										WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
								ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
								WHERE Increment_effective_Date <= @to_date)
							*/
							--print 12
							Set @W_SQL = 'INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
								INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
																		WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
																		and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=' + Cast(@Cmp_ID as Varchar(100)) + '
								and Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
								and Date_of_Join >=''' + Cast(@From_Date As Varchar(100)) + ''' and Date_OF_Join <= ''' + Cast(@To_Date As Varchar(100)) + ''' '+ @Where1 + '
							ORDER BY Emp_ID'
							Exec(@W_SQL)
							
							-- Comment by nilesh patel on 05122014 --Start
								--DELETE E FROM #Emp_Cons E Left join 
								--(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
								--	WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
								--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
								--Where ISNULL(new_inc.Increment_ID,0) = 0 
							-- Comment by nilesh patel on 05122014 --End
							
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
						
						END
					ELSE
						BEGIN
							/*INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE 
								INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle 
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=@Cmp_ID 
								and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				                and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				                and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				                and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				                and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				                and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				                and ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))
				                and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				                and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				                and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				                and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
							ORDER BY Emp_ID
							
							DELETE FROM #Emp_Cons WHERE Increment_ID Not In
								(SELECT TI.Increment_ID FROM t0095_increment TI inner join
									(SELECT Max(Increment_ID) AS Increment_ID,Emp_ID FROM T0095_Increment
										WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
								ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
								WHERE Increment_effective_Date <= @to_date)
							*/
							--print 13
							print 'n'
							Set @W_SQL = 'INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
								INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
																		WHERE Effective_date <= ''' + cast(@To_Date As Varchar(100)) + '''
																		and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID= ' + Cast(@Cmp_ID As Varchar(100)) + '
								and Increment_Effective_Date <= ''' + cast(@To_Date As Varchar(100)) + ''' 
								and Date_of_Join >= ''' + cast(@From_Date As Varchar(100)) + ''' and Date_OF_Join <= ''' + cast(@To_Date As Varchar(100)) + ''' '+ @Where1 + '
							ORDER BY Emp_ID'
							Exec(@W_SQL)
							
							-- Comment by nilesh patel on 05122014 --Start
								--DELETE E FROM #Emp_Cons E Left join 
								--(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
								--	WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
								--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
								--Where ISNULL(new_inc.Increment_ID,0) = 0
							-- Comment by nilesh patel on 05122014 --End
							
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
							
						END
				END		
			ELSE IF @Left_Emp = 1
				BEGIN
					
					IF @PBranch_ID <> '0' and @Branch_ID is null --isnull(@Branch_ID,0) = 0
						BEGIN
							print 'o'
							/*INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE
									INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle 
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=@Cmp_ID
								and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				                and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				                and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				                and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				                and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				                and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				                and ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))
				                and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				                and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				                and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				                and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Left_date >=@From_Date and Left_Date <=@to_Date
							ORDER BY Emp_ID
							
							DELETE FROM #Emp_Cons WHERE Increment_ID Not In
								(SELECT TI.Increment_ID from t0095_increment TI inner join
									(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
										WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
									ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
								WHERE Increment_effective_Date <= @to_date)
							*/
							--print 14
							Set @W_SQL = 'INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
									INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
																		WHERE Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
																		and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID= ' + Cast(@Cmp_ID As Varchar(100)) + '
								and Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
								and Left_date >= ''' + Cast(@From_Date As Varchar(100)) + ''' and Left_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' '+ @Where1 + '
							ORDER BY Emp_ID'
							Exec(@W_SQL)
								
							-- Comment by nilesh patel on 05122014 --Start
								--DELETE E FROM #Emp_Cons E Left join 
								--(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
								--	WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
								--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
								--Where ISNULL(new_inc.Increment_ID,0) = 0
							-- Comment by nilesh patel on 05122014 --End
							
							Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
							
							
						END
					ELSE
						BEGIN
							print 'p'
							/*INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE
									INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle 
																		WHERE Effective_date <= @To_Date
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID=@Cmp_ID 
								and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				                and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				                and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				                and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				                and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				                and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				                and ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))
				                and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				                and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				                and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				                and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
								and VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)  
								and Increment_Effective_Date <= @To_Date 
								and Left_date >=@From_Date and Left_Date <=@to_Date
							ORDER BY Emp_ID
							
							DELETE FROM #Emp_Cons WHERE Increment_ID Not In
								(SELECT TI.Increment_ID from t0095_increment TI inner join
									(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
										WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
									ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
								WHERE Increment_effective_Date <= @to_date)
							*/
							
							Set @W_SQL = ' INSERT INTO #Emp_Cons      
							SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
							FROM V_Emp_Cons VE WITH (NOLOCK)
									INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
									LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
													FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
														INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																		FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
																		WHERE Effective_date <= ''' + cast(@To_Date As Varchar(100)) + '''
																		and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
																		GROUP BY emp_id
																	) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
												) AS QrySC ON QrySC.eid = VE.Emp_ID
							WHERE VE.Cmp_ID= ' + Cast(@Cmp_ID As Varchar(100)) + '
								and Increment_Effective_Date <= ''' + cast(@To_Date As Varchar(100)) + ''' 
								and Left_date >= ''' + cast(@From_Date As Varchar(100)) + ''' and Left_Date <= ''' + cast(@To_Date As Varchar(100)) + ''' '+ @Where1 + '
							ORDER BY Emp_ID'
							Exec(@W_SQL)
							
							-- Comment by nilesh patel on 05122014 --Start
								--DELETE E FROM #Emp_Cons E Left join 
								--(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
								--	WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
								--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
								--Where ISNULL(new_inc.Increment_ID,0) = 0
							-- Comment by nilesh patel on 05122014 --End
							
							Delete #Emp_Cons From  #Emp_Cons EC  Left Outer Join
								(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
								(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
								Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
								on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
								Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
							Where Qry.Increment_ID is null
							
						END
				END
			ELSE 
				BEGIN
					print 'q'
					/*  INSERT INTO #Emp_Cons 	
					  SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE
					  WHERE Cmp_id=@Cmp_ID 
						   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') )
				           and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				           and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				           and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') ) 
				           and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') ) 
				           and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				           and ISNULL(Segment_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Segment_Id,ISNULL(Segment_ID,0)),'#') ) 
				           and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  
				           and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_ID,ISNULL(SubVertical_ID,0)),'#') ) 
				           and ISNULL(subBranch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubBranch_Id,ISNULL(subBranch_ID,0)),'#') )
						   AND VE.Emp_ID = isnull(@Emp_ID ,VE.Emp_ID)   
						   AND Increment_Effective_Date <= @To_Date 
						   AND ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
									or ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
									or (Left_date is null AND @To_Date >= Join_Date)      
									or (@To_Date >= left_date  AND  @From_Date <= left_date )) 
					ORDER BY Emp_ID
					
					DELETE FROM #Emp_Cons Where Increment_ID NOT IN
						( select TI.Increment_ID from t0095_increment TI INNER JOIN
							(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
								Where Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID Group by emp_ID) new_inc
							on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID
						Where Increment_effective_Date <= @to_date )  */
						--print 16
					Set @W_SQL = ' INSERT INTO #Emp_Cons 	
					  SELECT DISTINCT VE.Emp_ID,branch_id,VE.Increment_ID 
					  FROM dbo.V_Emp_Cons VE WITH (NOLOCK)
					  WHERE Cmp_id= ' + Cast(@Cmp_ID AS varchar(100)) + ' 
						   AND Increment_Effective_Date <= ''' + cast(@From_Date AS varchar(100)) + '''
						   AND ( ( ''' + cast(@From_Date AS varchar(100)) + '''   >= join_Date  AND  ''' + cast(@From_Date AS varchar(100)) + '''  <= left_date )      
									or ( ''' + cast(@To_Date AS varchar(100)) + '''   >= join_Date  AND ''' + cast(@To_Date AS varchar(100)) + ''' <= left_date )      
									or (Left_date is null AND ''' + cast(@To_Date AS varchar(100)) + ''' >= Join_Date)      
									or (''' + cast(@To_Date AS varchar(100)) + ''' >= left_date  AND  ''' + cast(@From_Date AS varchar(100)) + '''  <= left_date ))  '+ @Where1 + '
					ORDER BY Emp_ID '
					Exec(@W_SQL)		
					
					-- Comment by nilesh patel on 05122014 --start  
						--DELETE E FROM #Emp_Cons E Left join 
						--		(SELECT Max(Increment_ID) as Increment_ID,Emp_ID FROM T0095_Increment
						--			WHERE Increment_effective_Date <= @to_date and Cmp_id=@Cmp_ID GROUP BY emp_ID)as new_inc
						--		on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
						--Where ISNULL(new_inc.Increment_ID,0) = 0
					-- Comment by nilesh patel on 05122014 --End  
					
					Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
					 Where Qry.Increment_ID is null
							
				End		
		END
	ELSE IF @With_Ctc = 2		-- Use SP : SP_RPT_SALART_SUMMARY ( With FNF Employees )( Note:- IS_FNF Column is Added in #EmpCons in this )
		BEGIN
			--print 17
			print 'r'
			Set @W_SQL = 'INSERT INTO #Emp_Cons
			SELECT DISTINCT VE.emp_id,branch_id,VE.Increment_ID FROM V_Emp_Cons VE WITH (NOLOCK)
				INNER JOIN dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = VE.Emp_ID 
				LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
								FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
									INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
													FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
													WHERE Effective_date <= ''' + cast(@To_Date As Varchar(100)) + '''
													and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
													GROUP BY emp_id
												) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
							) AS QrySC ON QrySC.eid = VE.Emp_ID
			WHERE 
			   VE.cmp_id=' + cast(@Cmp_ID As Varchar(100)) + '
			   and ms.month_end_date >= ''' + cast(@from_date As Varchar(100)) + ''' and ms.month_end_date <= ''' + cast(@To_Date As Varchar(100)) + '''
			   AND Increment_Effective_Date <= ''' + cast(@To_Date As Varchar(100)) + ''' 
			   '+ @Where1 + '
			ORDER BY Emp_ID'

			Exec(@W_SQL)
			
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
							(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
							(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
							Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
							on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
			
	
		END
	ELSE 
		BEGIN
			print 's'
			
			  Set @W_SQL ='INSERT INTO #Emp_Cons 	
			  SELECT DISTINCT Emp_ID,VE.branch_id,Increment_ID 
			  FROM dbo.V_Emp_Cons VE WITH (NOLOCK) inner join T0040_GENERAL_SETTING g on VE.branch_id=g.branch_id 
		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= ''' + Cast(@To_Date As Varchar(100)) + '''
							and cmp_id = ''' + Cast(@Cmp_ID As Varchar(100)) + ''' 
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = VE.Emp_ID
			  WHERE VE.Cmp_id= ' + Cast(@Cmp_ID As Varchar(100)) + ' 
				   '+ @Where1 + '
				   AND Increment_Effective_Date <= ''' + Cast(@To_Date As Varchar(100)) + ''' 
				   AND ( 	
							( ''' + Cast(@To_Date As Varchar(100)) + '''  >= join_Date  AND ''' + Cast(@To_Date As Varchar(100)) + ''' <= left_date )      
							or (Left_date is null AND ''' + Cast(@To_Date As Varchar(100)) + ''' >= Join_Date)   
							or (''' + Cast(@To_Date As Varchar(100)) + ''' > left_date  AND  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )
							or 1 = (CASE WHEN (( ' + cast(@Show_Left_Employee_for_Salary As Varchar(1)) + ' = 1) AND (''' + Cast(@To_Date As Varchar(100)) + ''' >= left_date  AND  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )) then 1 else 0 end)      
						) 
			ORDER BY Emp_ID'
			
			Exec(@W_SQL)	
			
			
			
			-- Comment by nilesh patel on 07012015
			--(''' + Cast(@From_Date As Varchar(100)) + '''  >= join_Date  AND  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )      
			--				or ( ''' + Cast(@To_Date As Varchar(100)) + '''  >= join_Date  AND ''' + Cast(@To_Date As Varchar(100)) + ''' <= left_date )      
			--				or (Left_date is null AND ''' + Cast(@To_Date As Varchar(100)) + ''' >= Join_Date)      
			--				or (''' + Cast(@To_Date As Varchar(100)) + ''' >= left_date  AND  ''' + Cast(@From_Date As Varchar(100)) + ''' <= left_date )
			--				OR 1=(case when (( ' + cast(@Show_Left_Employee_for_Salary As Varchar(1)) + ' = 1) and (left_date <= ''' + Cast(@To_Date As Varchar(100)) + ''') and (dateadd(mm,1,Left_Date) > ''' + Cast(@From_Date As Varchar(100)) + ''' ))  then 1 else 0 end)
						
			--Comment by nilesh patel on 05122014 --start
				--DELETE E FROM #Emp_Cons E Left join (Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment
				--Where Increment_effective_Date <= @To_Date  and Cmp_id= @Cmp_ID  Group by emp_ID) as new_inc
				--on E.Increment_ID = new_inc. Increment_ID and E.emp_id = new_inc.Emp_ID
				--Where ISNULL(new_inc.Increment_ID,0) = 0
			--Comment by nilesh patel on 05122014 --End
			
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
			
			
			
		End	

	--Added By Ramiz for Deleting those employees whose Left Date is Less then Join Date. This Case comes when Company transffered on Same Date of Joining--
	Delete #Emp_Cons From  #Emp_Cons EC
		INNER JOIN T0080_EMP_MASTER EM ON EC.EMP_ID = EM.EMP_ID AND EM.Date_Of_Join > isnull(EM.Emp_Left_Date , @To_Date)
	WHERE em.Emp_Left_Date IS NOT NULL
