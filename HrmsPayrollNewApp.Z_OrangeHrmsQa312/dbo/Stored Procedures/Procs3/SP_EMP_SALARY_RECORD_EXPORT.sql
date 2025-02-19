

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_SALARY_RECORD_EXPORT]
	 @Cmp_ID			NUMERIC
	,@From_Date			DATETIME
	,@To_Date			DATETIME
	--,@Branch_ID			NUMERIC	= 0 '' Comment by nilesh patel on 05112014 
	,@Branch_ID			varchar(Max) = ''  -- Added by nilesh patel on 05112014 
	,@Cat_ID			NUMERIC = 0 
	,@Grd_ID			NUMERIC = 0
	,@Type_ID			NUMERIC = 0
	--,@Dept_ID			NUMERIC = 0 '' Comment by nilesh patel on 05112014
	,@Dept_ID			varchar(Max) = ''  -- Added by nilesh patel on 05112014
	,@Desig_ID			NUMERIC = 0
	,@Emp_ID			NUMERIC = 0	
	,@Constraint		VARCHAR(5000) = ''
	,@Salary_Status		VARCHAR(10) = 'All'
	,@Salary_Cycle_id	NUMERIC = 0
	--,@Sub_Branch_Id		NUMERIC(18,0) = 0		-- Added By Hiral 13 August, 2013 '' Comment by nilesh patel on 05112014 
	--,@BSegment_Id		NUMERIC(18,0) = 0		-- Added By Hiral 13 August, 2013 '' Comment by nilesh patel on 05112014 
	--,@Vertical_Id		NUMERIC(18,0) = 0		-- Added By Hiral 13 August, 2013 '' Comment by nilesh patel on 05112014 
	--,@SVertical_Id		NUMERIC(18,0) = 0		-- Added By Hiral 13 August, 2013 '' Comment by nilesh patel on 05112014 
	,@Sub_Branch_Id		varchar(Max) = ''  -- Added by nilesh patel on 05112014 
	,@BSegment_Id		varchar(Max) = ''  -- Added by nilesh patel on 05112014 
	,@Vertical_Id		varchar(Max) = ''  -- Added by nilesh patel on 05112014 
	,@SVertical_Id		varchar(Max) = ''  -- Added by nilesh patel on 05112014 
	,@pBranch_id_multi as varchar(Max) = '0'		--Added By Gadriwala 16092013
	,@PVertical_ID_Multi as Varchar(Max) = '0'	--Added By Gadriwala 16092013
	,@PSubVertical_id_multi as Varchar(Max) = '0'	--Added By Gadriwala 16092013	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Date_Diff NUMERIC 
	Declare @W_SQL Varchar(Max) --= ''
	Declare @W_SQL_1 Varchar(Max) --= ''
	Declare @Where1 Varchar(Max) --= ''
	
	SET @W_SQL = ''   --changed jimit 18042016
	SET @W_SQL_1 = ''	--changed jimit 18042016
	SET @Where1 = ''	--changed jimit 18042016
	
	SET @Date_Diff = DATEDIFF(d,@From_Date,@To_date) + 1
	
	IF @Salary_Cycle_id = 0
		SET @Salary_Cycle_id = NULL
	
	IF @Branch_ID = ''
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
		 
	IF @Type_ID = 0
		SET @Type_ID = NULL
		
	IF @Dept_ID = ''
		SET @Dept_ID = NULL
		
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
		
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Desig_ID = 0
		SET @Desig_ID = NULL
		
	-- Added By Hiral 13 August, 2013 (Start)
	IF @Sub_Branch_Id = ''
		SET @Sub_Branch_Id = NULL
		
	If @BSegment_Id = ''
		Set @BSegment_Id = Null
		
	If @Vertical_Id = ''
		Set @Vertical_Id = Null
	
	If @SVertical_Id = ''
		Set @SVertical_Id = Null
	-- Added By Hiral 13 August, 2013 (End)
	
	if @pBranch_id_multi = '0'				--Added By Gadriwala 16092013
	Set @pBranch_id_multi =    null			
	if @PVertical_ID_Multi = '0'				--Added By Gadriwala 16092013
	set @PVertical_ID_Multi = null	
	if @PSubVertical_id_multi = '0'			--Added By Gadriwala 16092013
	set @PSubVertical_id_multi = null
		
	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
  
	--SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
	--FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
	
	If @Dept_ID is not null
		Begin
			Set @Where1 = ' AND ISNULL(Dept_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL( ''' + cast(@Dept_ID AS varchar(100)) + ''',ISNULL(Dept_ID,0)),''#'') )' 
		End
	If @Branch_ID is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(VE.Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL( ''' + cast(@Branch_ID AS varchar(100)) + ''',ISNULL(VE.Branch_ID,0)),''#'') )'  
		End 
	if @pBranch_id_multi is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNull(Branch_ID,0) in (select CAST(Data as Numeric)  from dbo.Split(isnull(''' + cast(@pBranch_id_multi AS varchar(100)) + ''',isnull(Branch_ID,0)),''#'')) '
		End 
	if @PVertical_ID_Multi is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNull(Vertical_ID,0) in (select CAST(Data as Numeric)  from dbo.Split(isnull(''' + cast(@PVertical_ID_Multi AS varchar(100)) + ''',isnull(Vertical_ID,0)),''#''))'
		End		
	if @PSubVertical_id_multi is not null 
		Begin
			Set @Where1 = @Where1 + ' AND ISNull(SubVertical_ID,0) in (select CAST(Data as Numeric)  from dbo.Split(isnull(''' + cast(@PSubVertical_id_multi AS varchar(100)) + ''',isnull(SubVertical_ID,0)),''#''))'
		End	
	if @BSegment_Id is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(''' + cast(@BSegment_Id AS varchar(100)) + ''',ISNULL(Segment_ID,0)),''#'') )'
		End	
	if @Vertical_Id is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(''' + cast(@Vertical_Id AS varchar(100)) + ''',ISNULL(Vertical_ID,0)),''#'') )'
		End			
	if @SVertical_Id is not null   
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(''' + cast(@SVertical_Id AS varchar(100)) + ''',ISNULL(SubVertical_ID,0)),''#'') )'
		End	
	if @Sub_Branch_Id is not null   
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(''' + cast(@Sub_Branch_Id AS varchar(100)) + ''',ISNULL(subBranch_ID,0)),''#'') )'
		End	
	if @Cat_ID is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(Cat_ID,0) = ISNULL(''' + Cast(@Cat_ID As varchar(100)) + ''' ,ISNULL(Cat_ID,0))'
		End	
	if @Grd_ID is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(Grd_ID,0)  = ISNULL(''' + Cast(@Grd_ID As varchar(100)) + ''' ,ISNULL(Grd_ID,0))'
		End
	if @Type_ID is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(TYPE_ID,0) = ISNULL(''' + Cast(@Type_ID As varchar(100)) + ''' ,ISNULL(TYPE_ID,0))'
		End
	if @Desig_ID is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(Desig_ID,0) = ISNULL(''' + Cast(@Desig_ID As varchar(100)) + ''' ,ISNULL(Desig_ID,0))'
		End     
	if @Salary_Cycle_id is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(QrySC.SalDate_id,0) = ISNULL(''' + Cast(@Salary_Cycle_id As varchar(100)) + ''' ,ISNULL(QrySC.SalDate_id,0))'   
		End
	if @Emp_ID  is not null
		Begin
			Set @Where1 = @Where1 + ' AND ISNULL(Emp_ID,0)  = ISNULL(''' + Cast(@Emp_ID As varchar(100)) + ''' ,ISNULL(Emp_ID,0))'	
		End   							
	if @Branch_ID is not null
		Begin
			Set @Where1 = @Where1 + ' and For_Date = (select max(for_date) From T0040_General_Setting GS WITH (NOLOCK) where Cmp_ID = ' + Cast(@Cmp_ID As varchar(100)) + ' and ISNULL(Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL('''+ cast(@Branch_ID AS varchar(100)) + ''',ISNULL(VE.Branch_ID,0)),''#'') ) )'		
		End
	Else
		Begin
			Set @Where1 = @Where1 + ' and For_Date = (select max(for_date) From T0040_General_Setting GS WITH (NOLOCK) where  GS.Cmp_ID = ' + Cast(@Cmp_ID As varchar(100)) + ' and ISNULL(GS.Branch_ID,0) = ISNULL(VE.Branch_ID,0) )'
		End

	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)      
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons
			SELECT  CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE 
		BEGIN
			/*INSERT INTO #Emp_Cons      
				SELECT DISTINCT emp_id,V_Emp_Cons.branch_id,Increment_ID 
					FROM V_Emp_Cons 
					inner join T0040_GENERAL_SETTING g on V_Emp_Cons.branch_id=g.branch_id
						LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid FROM T0095_Emp_Salary_Cycle ESC
											INNER JOIN (SELECT MAX(Effective_date) AS Effective_date, emp_id FROM T0095_Emp_Salary_Cycle WHERE Effective_date <= @To_Date GROUP BY emp_id) Qry
											ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
										) AS QrySC
						ON QrySC.eid = V_Emp_Cons.Emp_ID
					WHERE V_Emp_Cons.cmp_id=@Cmp_ID 
						AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))  
						AND ISNULL( V_Emp_Cons.Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Branch_ID,ISNULL(V_Emp_Cons.Branch_ID,0)),'#') )  -- Added by nilesh on 05112014        
						--AND V_Emp_Cons.Branch_ID = ISNULL(@Branch_ID ,V_Emp_Cons.Branch_ID)     --Comment by nilesh patel on 05112014     
						AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)      
						--AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0)) 
						AND ISNULL(Dept_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )  -- Added by nilesh on 05112014              
						AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
						AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0)) 
						AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))      
						AND Emp_ID = ISNULL(@Emp_ID ,Emp_ID)   
						AND Increment_Effective_Date <= @To_Date 
						AND ((@From_Date >= join_Date AND @From_Date <= left_date) OR (@To_Date >= join_Date AND @To_Date <= left_date)      
							 OR (Left_date IS NULL AND @To_Date >= Join_Date) OR (@To_Date >= left_date AND @From_Date <= left_date )
							 --OR 1 = (CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date <= @To_Date) AND (DATEADD(mm,1,Left_Date) > @From_Date )) THEN 1 ELSE 0 END)
							 OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)
							)
						AND ISNull(V_Emp_Cons.Branch_ID,0) in (select CAST(Data as Numeric)  from dbo.Split(isnull(@pBranch_id_multi,isnull(V_Emp_Cons.Branch_ID,0)),'#')) -- Added By Gadriwala Muslim 26092013
						AND ISNull(Vertical_ID,0) in (select CAST(Data as Numeric)  from dbo.Split(isnull(@PVertical_ID_Multi,isnull(Vertical_ID,0)),'#'))-- Added By Gadriwala Muslim 26092013
						AND ISNull(SubVertical_ID,0) in (select CAST(Data as Numeric)  from dbo.Split(isnull(@PSubVertical_id_multi,isnull(SubVertical_ID,0)),'#'))-- Added By Gadriwala Muslim 26092013
						--And ISNULL(Segment_ID,0) = ISNULL(@BSegment_Id,IsNull(Segment_ID,0))			-- Added By Hiral 13 August, 2013 -- Comment by nilesh on 05112014
						--And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))			-- Added By Hiral 13 August, 2013 -- Comment by nilesh on 05112014
						--And ISNULL(SubVertical_ID,0) = ISNULL(@SVertical_Id,IsNull(SubVertical_ID,0))	-- Added By Hiral 13 August, 2013 -- Comment by nilesh on 05112014
						--And ISNULL(subBranch_ID,0) = ISNULL(@Sub_Branch_Id,IsNull(subBranch_ID,0))		-- Added By Hiral 13 August, 2013 -- Comment by nilesh on 05112014
						AND ISNULL(Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@BSegment_Id,ISNULL(Segment_ID,0)),'#') )  -- Added by nilesh on 05112014    
						AND ISNULL(Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical_Id,ISNULL(Vertical_ID,0)),'#') )  -- Added by nilesh on 05112014    
						AND ISNULL(SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SVertical_Id,ISNULL(SubVertical_ID,0)),'#') )  -- Added by nilesh on 05112014    
						AND ISNULL(subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Sub_Branch_Id,ISNULL(subBranch_ID,0)),'#') )  -- Added by nilesh on 05112014    
						And Emp_ID Not In (Select Emp_ID from T0190_MONTHLY_PRESENT_IMPORT 
												Where Month = Month(@From_Date) And Cmp_ID = @Cmp_ID)		-- Added By Hiral 16 August, 2013
						and For_Date = (select max(for_date) From T0040_General_Setting where Cmp_ID = @Cmp_ID and Branch_ID =Isnull(@branch_id,Branch_Id))  --Modified By Ramiz on 17092014
					ORDER BY Emp_ID		
						
			DELETE FROM #emp_cons 
				WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WHERE  Increment_effective_Date <= @to_date GROUP BY emp_ID)*/
				--inner join T0040_GENERAL_SETTING g on V_Emp_Cons.branch_id=g.branch_id  comment by Nilay : 28112014
						
					Set @W_SQL = ' INSERT INTO #Emp_Cons      
					SELECT DISTINCT VE.emp_id,VE.branch_id,VE.Increment_ID 
					FROM V_Emp_Cons VE 
					inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on VE.branch_id=g.branch_id
					 LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
											INNER JOIN (SELECT MAX(Effective_date) AS Effective_date, emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) WHERE Effective_date <= ''' + Cast(@To_Date AS varchar(100)) + '''  GROUP BY emp_id) Qry
											ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
										) AS QrySC
						ON QrySC.eid = VE.Emp_ID
					WHERE VE.cmp_id= ' + Cast(@Cmp_ID As varchar(100)) + '
						AND Increment_Effective_Date <= ''' + Cast(@To_Date AS varchar(100)) + '''  ' + @Where1 + '
						AND ((''' + Cast(@From_Date AS varchar(100)) + ''' >= join_Date AND ''' + Cast(@From_Date AS varchar(100)) + ''' <= left_date) OR (''' + Cast(@To_Date AS varchar(100)) + '''  >= join_Date AND ''' + Cast(@To_Date AS varchar(100)) + '''  <= left_date)      
							 OR (Left_date IS NULL AND ''' + Cast(@To_Date AS varchar(100)) + '''  >= Join_Date) OR ( ''' + Cast(@To_Date AS varchar(100)) + '''  >= left_date AND ''' + Cast(@From_Date AS varchar(100)) + ''' <= left_date )
							 OR 1=(CASE WHEN (('+ cast(@Show_Left_Employee_for_Salary AS varchar(1)) + ' = 1) AND (left_date >= case when (isnull(Sal_St_Date,'''')) = ''''  then ''' + Cast(@From_Date AS varchar(100)) + '''  when day(Sal_St_Date) = 1  then ''' + Cast(@From_Date AS varchar(100)) + '''  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + ''-'' + cast(datename(mm,dateadd(m,-1,''' + Cast(@To_Date AS varchar(100)) + ''' )) as varchar(10)) + ''-'' +  cast(year(dateadd(m,-1,''' + Cast(@To_Date AS varchar(100)) + ''' ) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'''')) = ''''  then ''' + Cast(@To_Date AS varchar(100)) + '''  when day(sal_st_date)=1 then ''' + Cast(@To_Date AS varchar(100)) + '''  else  dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + ''-'' + cast(datename(mm,dateadd(m,-1,''' + Cast(@To_Date AS varchar(100)) + ''' )) as varchar(10)) + ''-'' +  cast(year(dateadd(m,-1,''' + Cast(@To_Date AS varchar(100)) + ''' ) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)
							)
						And VE.Emp_ID Not In (Select Emp_ID from T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) Where Month = Month(''' + Cast(@From_Date AS varchar(100)) + ''') and year = year(''' + Cast(@From_Date AS varchar(100)) + ''') And Cmp_ID = ' + Cast(@Cmp_ID As varchar(100)) + ')   
					ORDER BY Emp_ID'	
					Exec(@W_SQL)
					--
					-- and For_Date = (select max(for_date) From T0040_General_Setting where Cmp_ID = ' + Cast(@Cmp_ID As varchar(100)) + ' and ISNULL(Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL('''+ cast(@Branch_ID AS varchar(100)) + ''',ISNULL(V_Emp_Cons.Branch_ID,0)),''#'') ) )		
					--and ISNULL(For_Date,0) = (select max(for_date) From T0040_General_Setting where Cmp_ID = ' + Cast(@Cmp_ID As varchar(100)) + ' and ISNULL(Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(' + @Branch_ID + ',ISNULL(V_Emp_Cons.Branch_ID,0)),''#'') ) )		
					--Exec(@W_SQL)
					--and For_Date = (select max(for_date) From T0040_General_Setting NE where Cmp_ID = ' + Cast(@Cmp_ID As varchar(100)) + ' and ISNULL(Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL('''+ cast(@Branch_ID AS varchar(100)) + ''',ISNULL(NE.Branch_ID,0)),''#'') ) )		
			-- Comment by nilesh patel on 05122014 	start
			--DELETE FROM #emp_cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WHERE  Increment_effective_Date <= @to_date GROUP BY emp_ID)
			-- Comment by nilesh patel on 05122014 	End
			
			Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Ec.Increment_Id = Qry.Increment_Id
					Where Qry.Increment_ID is null
		END
		
	CREATE TABLE #Emp_Sal_Data
	(
		Alpha_Emp_Code NVARCHAR(70),
		Emp_Full_Name NVARCHAR(150),
		Date_of_Join datetime,
		Branch_Name NVARCHAR(50),
		CTC NUMERIC(18,2)  ,
		Payable_CTC NUMERIC(18,2)		
	)
	
	
	
	IF @Show_Left_Employee_for_Salary = 0
		BEGIN
			INSERT INTO #Emp_Sal_Data
				SELECT CAST(E.Alpha_Emp_Code AS VARCHAR) AS  Alpha_Emp_Code, E.Emp_Full_Name AS Emp_Full_Name,E.Date_Of_Join, BM.Branch_Name,I_Q.CTC, I_Q.CTC AS Payable_CTC
				FROM T0080_EMP_MASTER E WITH (NOLOCK)
					LEFT OUTER JOIN (SELECT I.Emp_Id, Grd_ID, Branch_ID, Cat_ID, Desig_ID, Dept_ID, TYPE_ID, CTC
										FROM T0095_Increment I WITH (NOLOCK)
											INNER JOIN 
													/*(SELECT MAX(Increment_effective_Date) AS For_Date, Emp_ID 
															FROM T0095_Increment
															WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
															GROUP BY emp_ID
														) Qry 
											ON I.Emp_ID = Qry.Emp_ID AND I.Increment_effective_Date = Qry.For_Date */

											(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
											(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
											Where Increment_effective_Date <= @to_date and Cmp_Id=@Cmp_Id Group by emp_ID) new_inc
											on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
											Where TI.Increment_effective_Date <= @to_date and Cmp_Id=@Cmp_Id group by ti.emp_id) Qry on I.Increment_Id = Qry.Increment_Id											
									 ) I_Q 
					ON E.Emp_ID = I_Q.Emp_ID  
					INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID 
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
					INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  
				WHERE E.Cmp_ID = @Cmp_Id 
					AND ((@From_Date < E.Emp_LEft_Date AND @To_Date < E.Emp_LEft_Date) OR E.Emp_LEft_Date IS NULL)	
					AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons)
				ORDER BY  Alpha_Emp_Code ASC


						
			DECLARE @ad_name AS VARCHAR(100)
			
			DECLARE cur_ad_name CURSOR
		    FOR SELECT AD_SORT_NAME FROM T0050_AD_MASTER WITH (NOLOCK)  WHERE CMP_ID = @Cmp_ID AND AD_CALCULATE_ON = 'Import' and AD_ACTIVE = 1	-- Added By Gadriwala 28012014	
			OPEN cur_ad_name  
			FETCH NEXT FROM cur_ad_name INTO @ad_name 
			WHILE @@FETCH_STATUS =0  
				BEGIN  
					DECLARE @eval AS NVARCHAR(500)
					SET @ad_name = REPLACE(REPLACE(REPLACE(REPLACE(@ad_name,'  ',' '),' ','_'),'(','_'),')','_')
						
					SET @eval = 'ALTER   table	#Emp_Sal_Data   add ' + @ad_name + ' numeric(18,2) default 0 not null'
					EXEC (@eval)
						
					FETCH NEXT FROM cur_ad_name INTO @ad_name 		
				END
			CLOSE cur_ad_name  
			DEALLOCATE cur_ad_name  
		END
			 
	SELECT * FROM #Emp_Sal_Data
	DROP TABLE #Emp_Sal_Data
		  
RETURN


