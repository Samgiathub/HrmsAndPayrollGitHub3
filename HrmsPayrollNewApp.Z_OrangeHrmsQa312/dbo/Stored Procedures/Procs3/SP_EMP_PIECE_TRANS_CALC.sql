--Declare @Sal numeric(18,4)
-- Exec SP_EMP_PIECE_TRANS_CALC 119,'2021-03-01','2021-03-31',21535 , @Sal Output
-- Select @Sal as SalaryAmount
---10/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_PIECE_TRANS_CALC]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	--,@Branch_ID		VARCHAR(MAX) = '' 
	--,@Cat_ID		VARCHAR(MAX) = '' 
	--,@Grd_ID		VARCHAR(MAX) = '' 
	--,@Type_ID		NUMERIC  = 0
	--,@Dept_ID		VARCHAR(MAX) = '' 
	--,@Desig_ID		VARCHAR(MAX) = '' 
	,@Emp_ID		NUMERIC  = 0
	,@Salary_Amount		NUMERIC(18, 4) OUTPUT
	--,@Constraint	VARCHAR(MAX) = ''
	--,@Segment_ID VARCHAR(MAX) = '' 
	--,@Vertical VARCHAR(MAX) = '' 
	--,@SubVertical VARCHAR(MAX) = '' 
	--,@SubBranch VARCHAR(MAX) = '' 
	--,@PieceTrans_id numeric(18,0) = 0
	--,@Type int = 0
	--,@Product_ID numeric(18,0) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--IF @Branch_ID = '0' or @Branch_ID = ''
	--	SET @Branch_ID = NULL

	--IF @Cat_ID = '0' or  @Cat_ID = ''
	--	SET @Cat_ID = NULL
		 
	--IF @Type_ID = '0' or @Type_ID = ''
	--	SET @Type_ID = NULL
	--IF @Dept_ID = '0' or @Dept_ID = ''
	--	SET @Dept_ID = NULL
	--IF @Grd_ID = '0' or @Grd_ID = ''
	--	SET @Grd_ID = NULL
	
	--IF @Emp_ID = 0
	--	SET @Emp_ID = NULL
		
	--IF @Vertical='0' or @Vertical = ''
	--	set @Vertical = NULL
		
	--if @SubVertical='0' or @SubVertical=''
	--	set @SubVertical = NULL
		
	--IF @subBranch='0' or @subBranch=''
	--	set @subBranch = NULL
		
	--if @Segment_Id='0' or @Segment_Id=''
	--	set @Segment_Id = NULL
	
	
	--IF @Desig_ID = '0' or @Desig_ID = ''
	--	SET @Desig_ID = NULL
	
	--IF @Branch_ID= '0' OR @Branch_ID=''  --Added By Jaina 21-09-2015
	--	SET @Branch_ID = NULL
	--IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015
	--	SET @Constraint = NULL
	
		
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)  

	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,@Segment_Id,@Vertical,@SubVertical,@subBranch,0,0,0,0,0,0  --Change By Jaina 19-09-2015
	
	--IF @Constraint <> ''
	--	Begin		
	--		INSERT INTO #Emp_Cons
	--		SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T  
	--End

	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			 DROP TABLE #tmp
	
	
	--Declare @FromDate1  as DateTime = '2021-03-01'
	--Declare @ToDate1 as DateTime  = '2021-03-31'
	--SELECT ROW_NUMBER() OVER(ORDER BY Piece_Trans_Date) AS RowNum,* into #tmpPieceTrans 
	--from T0050_Piece_Transaction where Piece_Trans_Date between @FromDate1 and @ToDate1 
	--and Emp_ID = 21535 and Cmp_ID = 119
	--drop table #tmpPieceTrans 

	IF OBJECT_ID('tempdb..#tmpPieceTrans') IS NOT NULL
			 DROP TABLE #tmpPieceTrans

	SELECT ROW_NUMBER() OVER(ORDER BY Piece_Trans_Date) AS RowNum,* into #tmpPieceTrans 
	from T0050_Piece_Transaction WITH (NOLOCK) where Piece_Trans_Date between @From_Date and @To_Date
	and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID


	IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL
			 DROP TABLE #tmp1

	Select distinct t.Rate_Id,RateDetail_ID,T.Emp_ID,t.Cmp_ID,t.Product_ID,t.SubProduct_ID,Effective_date 
	,t3.From_Limit,To_Limit,Rate into #tmp1
	FROM T0050_Rate_Master t WITH (NOLOCK)
			inner join T0051_Rate_Details t3 WITH (NOLOCK) on t.Rate_Id = t3.Rate_ID 
	where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID

	--Select distinct t.Rate_Id,RateDetail_ID,T.Emp_ID,t.Cmp_ID,t.Product_ID,t.SubProduct_ID,Effective_date 
	--,t3.From_Limit,To_Limit,Rate into #tmp1
	--FROM T0050_Rate_Master t 
	--		inner join T0051_Rate_Details t3 on t.Rate_Id = t3.Rate_ID 
	--where Emp_ID = 21535	and Cmp_ID = 119

	IF OBJECT_ID('tempdb..#FinalTable') IS NOT NULL
			 DROP TABLE #FinalTable

	Create Table #FinalTable
	(
	  PieceTransCount numeric(9) ,
	  PiectTransDate Datetime,
	  ProductID numeric(9),
	  SubProductId numeric(9),
	  EffDate DateTime,
	  FromLimit numeric(9),
	  ToLimit numeric(9),
	  Rate numeric(18,2),
	  Amount numeric(18,2)
	)
	
	DECLARE @ProdId as int =0
	DECLARE @SubPId as int =0
	DECLARE @PieceTranDate as Date 
	DECLARE @PieceTranCount as int = 0 

	--Declare @FromDate1  as DateTime = '2021-03-01'
	--Declare @ToDate1 as DateTime  = '2021-03-31'
	Declare @Rcnt as int
	declare @whileCnt as int = 1
	--SELECT @Rcnt = Count(1) from T0050_Piece_Transaction where Piece_Trans_Date between @FromDate1 and @ToDate1 -- Change the From Date and To date
	SELECT @Rcnt = Count(1) from T0050_Piece_Transaction 
	WITH (NOLOCK) where Piece_Trans_Date between @From_Date and @To_Date and Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID
	-- Change the From Date and To date

	WHILE @whileCnt <= @Rcnt
	BEGIN
		SELECT  @ProdId = Case When Product_ID <> 0 then Product_ID else 0 end, 
				@SubPId = Case When SubProduct_ID <> 0 then SubProduct_ID else 0 end,
				@PieceTranDate = Cast(Piece_Trans_date as date),
				@PieceTranCount = Piece_Trans_Count
		FROM #tmpPieceTrans where RowNum = @whileCnt
		
		IF @ProdId <> 0 and @SubPId <> 0
		BEGIN 
			insert into #FinalTable (PieceTransCount,PiectTransDate,ProductID,SubProductId,EffDate,FromLimit,ToLimit,Rate,Amount)  
			Select @PieceTranCount as PieceCnt,@PieceTranDate as PieceDate,Product_ID,SubProduct_ID,Effective_date,From_Limit,To_Limit,Rate,(@PieceTranCount * Rate) as Amount
			from #tmp1 t1 Inner Join
				(Select Max(Effective_date) As Eff_Date 
				 from #tmp1 
				 Where Product_ID = @ProdId and SubProduct_ID = @SubPId and Effective_date <= @PieceTranDate
			)t2 On t1.Effective_date=t2.Eff_Date
			where Product_ID = @ProdId and SubProduct_ID = @SubPId and @PieceTranCount Between Cast(From_Limit as Int) and Cast(To_Limit as Int)
		END
		SET	@whileCnt = @whileCnt + 1
	END 


	SELECT @Salary_Amount = ISNULL(SUM(Amount),0) FROM #FinalTable
	--Select t.Rate_Id,RateDetail_ID,Piece_Tran_ID,T.Emp_ID,t.Cmp_ID,t.Product_ID,t.SubProduct_ID,Effective_date 
	--,t3.From_Limit,To_Limit,Rate
	--,Piece_Trans_Count,Piece_Trans_Date
	--into #tmp
	--FROM T0050_Rate_Master t inner join (  Select Max(Effective_date) AS For_Date, emp_id from T0050_Rate_Master
	--										WHERE  Effective_date <= Getdate() AND cmp_id = 119 
	--										Group by emp_id
	--									)t2 on t.Effective_date = t2.For_Date and T.Emp_ID = t2.Emp_ID
	--		inner join T0051_Rate_Details t3 on t.Rate_Id = t3.Rate_ID
	--		inner join T0050_Piece_Transaction t4 on t4.Cmp_ID = t.Cmp_ID 
	--					and t4.Emp_ID = t.Emp_ID 
	--					and t4.SubProduct_ID = t.SubProduct_ID
	
	--select * from #tmp
	--Select *,(Rate * Piece_Trans_Count) as Amt from #tmp
	--where Piece_Trans_Count between cast(From_Limit as int) and cast(To_Limit as Int)
RETURN

