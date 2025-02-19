
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--exec SP_EMP_PIECE_TRANSACTION 119,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,82
--exec SP_EMP_PIECE_TRANSACTION @Cmp_ID=119,@From_Date='2021-03-01 18:14:33.770',@To_Date='2021-03-01 18:14:33.770',@Branch_ID=0,@Cat_ID='0',@Grd_ID='0',@Type_ID=0,@Dept_ID='0',@Desig_ID='0',@Emp_ID =13960,@Constraint='0',@Segment_ID='0',@Vertical='0',@SubVertical='0',@SubBranch='0',@Type='0',@Product_ID='83'	
CREATE PROCEDURE [dbo].[SP_EMP_PIECE_TRANSACTION]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		VARCHAR(MAX) = '' 
	,@Cat_ID		VARCHAR(MAX) = '' 
	,@Grd_ID		VARCHAR(MAX) = '' 
	,@Type_ID		NUMERIC  = 0
	,@Dept_ID		VARCHAR(MAX) = '' 
	,@Desig_ID		VARCHAR(MAX) = '' 
	,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX) = ''
	,@Segment_ID VARCHAR(MAX) = '' 
	,@Vertical VARCHAR(MAX) = '' 
	,@SubVertical VARCHAR(MAX) = '' 
	,@SubBranch VARCHAR(MAX) = '' 
	,@PieceTrans_id numeric(18,0) = 0
	,@Type int = 0
	,@Product_ID numeric(18,0) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Branch_ID = '0' or @Branch_ID = ''
		SET @Branch_ID = NULL

	IF @Cat_ID = '0' or  @Cat_ID = ''
		SET @Cat_ID = NULL
		 
	IF @Type_ID = '0' or @Type_ID = ''
		SET @Type_ID = NULL
	IF @Dept_ID = '0' or @Dept_ID = ''
		SET @Dept_ID = NULL
	IF @Grd_ID = '0' or @Grd_ID = ''
		SET @Grd_ID = NULL
	
	--IF @Emp_ID = 0
	--	SET @Emp_ID = NULL
		
	IF @Vertical='0' or @Vertical = ''
		set @Vertical = NULL
		
	if @SubVertical='0' or @SubVertical=''
		set @SubVertical = NULL
		
	IF @subBranch='0' or @subBranch=''
		set @subBranch = NULL
		
	if @Segment_Id='0' or @Segment_Id=''
		set @Segment_Id = NULL
	
	
	IF @Desig_ID = '0' or @Desig_ID = ''
		SET @Desig_ID = NULL
	
	IF @Branch_ID= '0' OR @Branch_ID=''  --Added By Jaina 21-09-2015
		SET @Branch_ID = NULL
	IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015
		SET @Constraint = NULL
	
	
		
	
		
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)  

	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,@Segment_Id,@Vertical,@SubVertical,@subBranch,0,0,0,0,0,0  --Change By Jaina 19-09-2015
	
	
	
	IF @Constraint <> ''
		Begin		
			INSERT INTO #Emp_Cons
			SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T  
		End

	
	IF OBJECT_ID('tempdb..#DateList') IS NOT NULL
			 DROP TABLE #DateList
	
	Create table #DateList(
		DateLabel VARCHAR(10) 
	)

	DECLARE @Today DATE= GETDATE() ,@StartOfMonth DATE ,@EndOfMonth DATE;
	--SET @EndOfMonth = EOMONTH(GETDATE());
	--SET @StartOfMonth = DATEFROMPARTS(YEAR(@Today), MONTH(@Today), 1);
	SET @EndOfMonth = @To_Date
	SET @StartOfMonth = @From_Date
	
	WHILE @StartOfMonth <= @EndOfMonth
	BEGIN
	   INSERT  INTO #DateList
	   VALUES  ( convert(varchar, @StartOfMonth, 5) );
	   SET @StartOfMonth = DATEADD(DAY, 1, @StartOfMonth);
	END;
	
	
	IF OBJECT_ID('tempdb..##t1') IS NOT NULL
			 DROP TABLE ##t1

	DECLARE @cols NVARCHAR (MAX)
	DECLARE @query NVARCHAR (MAX)
	SELECT @cols = COALESCE (@cols + ',[' +  DateLabel + ']', 
			  '[' +  DateLabel + ']')
			   FROM    (SELECT DISTINCT DateLabel  FROM #DateList) PV  
			   ORDER BY DateLabel
	SELECT @query = '
	SELECT * into ##t1
	FROM
	(
	   SELECT DateLabel FROM #DateList --where 0 =1
	) AS t
	PIVOT 
	(
	  COUNT(DateLabel) 
	  FOR DateLabel IN( ' + @cols + ' )' +
	') AS p ;'
	EXEC SP_EXECUTESQL @query

	IF OBJECT_ID('tempdb..#tmpMonthDate') IS NOT NULL
			 DROP TABLE #tmpMonthDate

	Select * into #tmpMonthDate from ##t1

	IF OBJECT_ID('tempdb..##t1') IS NOT NULL
			 DROP TABLE ##t1
	IF OBJECT_ID('tempdb..#DateList') IS NOT NULL
			 DROP TABLE #DateList			


	IF @Type = 0
	BEGIN
			
			  SELECT a.SubProduct_ID,a.SubProduct_Name as [SubProduct Name], b.* FROM 
			  (SELECT SubProduct_ID,SubProduct_Name 
			   FROM T0040_SubProduct_Master
				where Cmp_ID = @Cmp_ID and Product_ID = @Product_ID
			  ) AS a,   
			  (SELECT *
			   FROM #tmpMonthDate 
			  ) AS b
			    
			--Select SubProduct_Name from T0040_SubProduct_Master  where Cmp_ID =119 and Product_ID = 82
	END
	Else
	BEGIN
				SELECT a.Emp_ID,[Emp Full Name], b.* FROM 
			  (SELECT E.Emp_ID,(Cast(Alpha_Emp_Code as varchar(100)) + ' - '+  Emp_Full_Name)  as [Emp Full Name]
			   FROM #Emp_Cons Ec inner join T0080_EMP_MASTER E on EC.Emp_ID = E.Emp_ID
				
			  ) AS a,   
			  (SELECT *
			   FROM #tmpMonthDate 
			  ) AS b
	END
	
		  
RETURN
