



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_BalanceScoreCard]
	     @cmp_id			as numeric(18,0)
		,@From_Date			as datetime
		,@To_Date			as datetime
		,@branch_Id			as numeric(18,0)=0
		,@Cat_ID			as numeric = 0	
		,@Grd_Id			as numeric(18,0)=0
		,@Type_Id			as numeric(18,0)=0
		,@Dept_Id			as numeric(18,0)=0
		,@Desig_Id			as numeric(18,0)=0
		,@Emp_Id			as numeric(18,0)=0
		,@Constraint		as varchar(max)=''
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
     IF @branch_Id = 0  
		SET @branch_Id = null   
	 IF @Grd_Id = 0  
		SET @Grd_Id = null  
	 IF @Emp_ID = 0  
		SET @Emp_ID = null  
	 IF @Desig_ID = 0  
		SET @Desig_ID = null  
	 IF @Dept_ID = 0  
		SET @Dept_ID = null 
	 IF @Cat_ID = 0
		SET @Cat_ID = null
		
	DECLARE @col1 AS NUMERIC(18,0)  
    DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC 
	)  
	
	IF @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	Else
		Begin
			Insert Into @Emp_Cons
			select emp_id from T0090_BalanceScoreCard_Setting k WITH (NOLOCK) where Cmp_ID=@cmp_id and CreatedDate  between cast(@From_Date AS datetime) and cast(@To_Date as datetime)
			and k.BSC_SettingId = (select max(BSC_SettingId) from T0090_BalanceScoreCard_Setting WITH (NOLOCK) where emp_id=k.emp_id and CreatedDate  between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
			--and ( Review_Status <> 0 or Review_Status <> 3)
		End
		
	CREATE TABLE #Table1
	(
		 CompanyName		varchar(100)
		,CompanyLogo		image
		,Emp_Id				numeric(18,0)
		,EmpCode			varchar(100)
		,Emp_Full_Name		varchar(100)
		,Department			varchar(100)
		,Designation		varchar(100)
		,Branch				varchar(100)
		,FinancialYear		int
	)
	
	CREATE TABLE #Table2
	(
		 Emp_Id						NUMERIC(18,0)
		 ,KPI_Id					NUMERIC(18,0)
		 ,KPI						VARCHAR(250)
		 ,FinancialYear				int	
	)
	
	CREATE TABLE #Table3
	(
		  Emp_Id					NUMERIC(18,0)
		 ,KPI_Id					NUMERIC(18,0)
		 ,BSC_Objective				NVARCHAR(MAX)
		 ,BSC_Measure				NVARCHAR(200)
		 ,BSC_Target				NVARCHAR(100)
		 ,BSC_Formula				NVARCHAR(100)
		 ,BSC_Weight				NUMERIC(18,2)
		 ,BSC_Setting_Detail_Id		NUMERIC(18,0)
		 ,Key_1						VARCHAR(100)
		 ,Key_2						VARCHAR(100)
		 ,Key_3						VARCHAR(100)
		 ,Key_4						VARCHAR(100)
		 ,Actual					NVARCHAR(100)
		 ,Score						VARCHAR(50)
		 ,WeightedScore				NUMERIC(18,2)
		 ,Review_type				VARCHAR(10)
		 ,Emp_BSC_Review_Detail_Id	NUMERIC(18,0)
		 ,Emp_BSC_Review_Id			NUMERIC(18,0)
	)
	
	DECLARE @empid AS NUMERIC(18,0)
	DECLARE @finyear AS NUMERIC(18,0)
	DECLARE @kpiid NUMERIC(18,0)
	DECLARE @bscsettingdetailid NUMERIC(18,0)
	
	declare @branchid numeric(18,0)
	declare @desigid numeric(18,0)
	
	DECLARE cur CURSOR
	FOR 
		SELECT emp_id FROM @Emp_Cons
	OPEN cur
		FETCH NEXT FROM cur INTO @empid
		WHILE @@fetch_status= 0
			BEGIN
				SET @finyear = 0
				SET @branchid = 0
				SET @desigid = 0
				--insert into table 1
				INSERT INTO #Table1 (CompanyName,CompanyLogo,Emp_id,EmpCode,Emp_Full_Name,Department,Designation,Branch,FinancialYear)
				SELECT  C.Cmp_Name,C.cmp_logo,E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,
					    d.Dept_Name,dg.Desig_Name,b.Branch_Name,EG.FinYear
				FROM	T0080_EMP_MASTER E WITH (NOLOCK) inner join 
						T0010_COMPANY_MASTER C WITH (NOLOCK) on C.Cmp_Id = E.Cmp_ID INNER JOIN
						T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID and I.Increment_Effective_Date = 
						(SELECT MAX(Increment_Effective_Date) FROM T0095_INCREMENT IC WITH (NOLOCK) WHERE ic.Emp_ID = @empid)  left JOIN
						T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID left JOIN
						T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id left JOIN
						T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = i.Branch_ID INNER JOIN
						T0090_BalanceScoreCard_Setting EG WITH (NOLOCK) on EG.Emp_id=e.Emp_ID and 
						EG.BSC_SettingId = (select max(BSC_SettingId) from T0090_BalanceScoreCard_Setting WITH (NOLOCK) where emp_id=@empid and CreatedDate  between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
				WHERE	E.Emp_ID = @empid --and ( EG.Review_Status <> 0 or EG.Review_Status <> 3)
				
				SELECT @branchid = i.Branch_ID ,@desigid = i.Desig_Id
				FROM T0080_EMP_MASTER E WITH (NOLOCK) inner join 
					 T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID and I.Increment_Effective_Date = 
						(SELECT MAX(Increment_Effective_Date) FROM T0095_INCREMENT IC WITH (NOLOCK) WHERE ic.Emp_ID = @empid)
				WHERE E.emp_id=@empid
				
				SELECT  @finyear = FinancialYear FROM #Table1 WHERE Emp_id = @empid
				
				INSERT INTO #Table2
				SELECT @empid,KPI_id,KPI,@finyear FROM T0040_KPI_Master WITH (NOLOCK) where cmp_id=@cmp_id
				and @branchid in (SELECT data FROM dbo.Split(Branch_Id,'#')) and  
				@desigid in (SELECT data FROM dbo.Split(designation_Id,'#'))
				and Active=1  and Effective_Date = (SELECT max(Effective_Date) FROM T0040_KPI_Master WITH (NOLOCK)
				WHERE @branchid in (SELECT data FROM dbo.Split(Branch_Id,'#')) 
				and @desigid in (SELECT data FROM dbo.Split(designation_Id,'#')))
				ORDER BY KPI_Id
												
				FETCH NEXT FROM cur INTO @empid	
			END
	CLOSE cur
	DEALLOCATE cur
	
	SET @empid = null
	
	DECLARE cur CURSOR
	FOR 
		SELECT emp_id,KPI_Id,FinancialYear FROM #Table2
	OPEN cur
		FETCH NEXT FROM cur INTO @empid,@kpiid,@finyear
		WHILE @@fetch_status= 0
			BEGIN
				INSERT INTO #Table3 (Emp_Id,KPI_Id,BSC_Objective,BSC_Measure,BSC_Target,BSC_Formula,BSC_Weight,BSC_Setting_Detail_Id,Actual,Score,WeightedScore,Review_type,Emp_BSC_Review_Detail_Id,Emp_BSC_Review_Id)
				SELECT @empid,@kpiid,BSC_Objective,BSC_Measure,BSC_Target,BSC_Formula,BSC_Weight,T0095_BalanceScoreCard_Setting_Details.BSC_Setting_Detail_Id,
						--ED.Actual,ED.Score,ED.WeightedScore,
						--case when EG.Review_Type = 1 then 'Interim'  when EG.Review_Type=2 then 'Final' END,
						--ED.Emp_BSC_Review_Detail_Id,ED.Emp_BSC_Review_Id
						'','',0,'',0,0
				FROM  T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK) inner join 
					  T0090_BalanceScoreCard_Setting WITH (NOLOCK) on T0090_BalanceScoreCard_Setting.BSC_SettingId = T0095_BalanceScoreCard_Setting_Details.BSC_SettingId --inner JOIN
					  --T0100_BalanceScoreCard_Evaluation_Details ED on ed.BSC_Setting_Detail_Id =T0095_BalanceScoreCard_Setting_Details.BSC_Setting_Detail_Id INNER JOIN
					  --T0095_BalanceScoreCard_Evaluation EG on EG.Emp_BSC_Review_Id = ed.Emp_BSC_Review_Id  					   
				WHERE KPI_Id = @kpiid and T0090_BalanceScoreCard_Setting.Emp_Id= @empid and T0090_BalanceScoreCard_Setting.FinYear = @finyear
						and T0090_BalanceScoreCard_Setting.FinYear = @finyear
										
				FETCH NEXT FROM cur INTO @empid,@kpiid,@finyear
			END
	CLOSE cur
	DEALLOCATE cur
	
	set @kpiid=null
	set @empid = null
	
	DECLARE cur CURSOR
	FOR
		SELECT Emp_Id,KPI_Id,BSC_Setting_Detail_Id  FROM #Table3 
	OPEN cur
		FETCH NEXT FROM cur INTO @empid,@kpiid,@bscsettingdetailid
		WHILE @@fetch_status= 0
			BEGIN
				UPDATE #Table3
				SET key_1= b.Key_Value
				FROM (SELECT Key_Value 
					  FROM T0100_BSC_ScoringKey WITH (NOLOCK)
					  WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
					  AND Key_Name = 1)b
				WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
				
				UPDATE #Table3
				SET key_2= b.Key_Value
				FROM (SELECT Key_Value 
					  FROM T0100_BSC_ScoringKey WITH (NOLOCK)
					  WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
					  AND Key_Name = 2)b
				WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
				
				UPDATE #Table3
				SET key_3= b.Key_Value
				FROM (SELECT Key_Value 
					  FROM T0100_BSC_ScoringKey WITH (NOLOCK)
					  WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
					  AND Key_Name = 3)b
				WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
				
				UPDATE #Table3
				SET key_4= b.Key_Value
				FROM (SELECT Key_Value 
					  FROM T0100_BSC_ScoringKey WITH (NOLOCK)
					  WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
					  AND Key_Name = 4)b
				WHERE BSC_Setting_Detail_Id = @bscsettingdetailid
				
				FETCH NEXT FROM cur INTO @empid,@kpiid,@bscsettingdetailid
			END
	CLOSE cur
	DEALLOCATE cur
	
	SELECT * FROM #Table1
	SELECT * FROM #Table2
	SELECT * FROM #Table3
	
	DROP TABLE #Table1 
	DROP TABLE #Table2
	DROP TABLE #Table3
END



