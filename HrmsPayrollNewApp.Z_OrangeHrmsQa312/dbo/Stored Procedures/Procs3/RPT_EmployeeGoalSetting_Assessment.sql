
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_EmployeeGoalSetting_Assessment]
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
		,@flag				as numeric(18,0)=0
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
        
    declare @col1 as numeric(18,0)  
    Declare @Emp_Cons Table
	(
		Emp_ID	numeric 
	)    
	
	IF @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	Else
		Begin
			Insert Into @Emp_Cons
			select emp_id from T0095_EmployeeGoalSetting_Evaluation k WITH (NOLOCK) where Cmp_ID=@cmp_id and CreatedDate  between cast(@From_Date AS datetime) and cast(@To_Date as datetime)
			and Emp_GoalSetting_Review_Id = (select max(Emp_GoalSetting_Review_Id) from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where emp_id=k.emp_id and CreatedDate  between cast(@From_Date AS datetime) and cast(@To_Date as datetime) and ( review_status <> 0 or Review_Status <> 3))
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
		,KRA						NVARCHAR(1000)
		,KPI						NVARCHAR(1000)
		,[Target]					NVARCHAR(1000)
		,[Weight]					NUMERIC(18,2)
		,Emp_GoalSetting_Detail_Id	NUMERIC(18,0)
		,Actual						NVARCHAR(1000)
		,Emp_Feedback				VARCHAR(500)
		,Sup_Score					VARCHAR(500)
		,Sup_Feedback				VARCHAR(1000)
		,WeightedScore				NUMERIC(18,2)
		,Emp_GoalSetting_Review_Detail_Id	NUMERIC(18,2)
		,Emp_GoalSetting_Review_Id	NUMERIC(18,2)
		,Review_type				VARCHAR(50)
		,KRA_Type					VARCHAR(200)
	)
	
	CREATE TABLE #Table3
	(
		 Emp_Id						NUMERIC(18,0)
		,AdditionalAchievement      VARCHAR(1000)
		,Review_type				VARCHAR(10)
	)
	
	CREATE TABLE #Table4
	(
		Emp_Id						NUMERIC(18,0)
		,Emp_GoalSetting_Review_Id	NUMERIC(18,0)
		,SupEval_Comments			VARCHAR(500)
		,YearEnd_FinalRating		VARCHAR(50)
		,YearEnd_NormalRating		VARCHAR(50)
		,Sup_PromoRecommend			VARCHAR(5)--22/03/2017
		,Final_PromoRecommend		VARCHAR(5)--22/03/2017
	)
	
	DECLARE @empid AS NUMERIC(18,0)
	DECLARE @finyear AS NUMERIC(18,0)
	DECLARE @Emp_GoalSetting_Detail_Id as NUMERIC
	
	if @flag=1
		BEGIN
			DECLARE cur CURSOR
			FOR 
				SELECT emp_id FROM @Emp_Cons
			OPEN cur
				FETCH NEXT FROM cur INTO @empid
				WHILE @@fetch_status= 0
					BEGIN
						SET @finyear = 0
						--insert into table 1
						INSERT INTO #Table1 (CompanyName,CompanyLogo,Emp_id,EmpCode,Emp_Full_Name,Department,Designation,Branch,FinancialYear)
						SELECT C.Cmp_Name,C.cmp_logo,E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,
								d.Dept_Name,dg.Desig_Name,b.Branch_Name,EG.FinYear
						 FROM	T0080_EMP_MASTER E WITH (NOLOCK) inner join 
								T0010_COMPANY_MASTER C WITH (NOLOCK) on C.Cmp_Id = E.Cmp_ID INNER JOIN
								T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID and i.Increment_ID=e.Increment_ID  left JOIN
								T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID left JOIN
								T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id left JOIN
								T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = i.Branch_ID INNER JOIN
								T0095_EmployeeGoalSetting_Evaluation EG WITH (NOLOCK) on EG.Emp_id=e.Emp_ID and 
								 Emp_GoalSetting_Review_Id = (select max(Emp_GoalSetting_Review_Id) from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where emp_id=@empid and CreatedDate  between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 WHERE E.Emp_ID = @empid and ( EG.Review_Status <> 0 or EG.Review_Status <> 3)
						 
						SELECT  @finyear = FinancialYear FROM #Table1 WHERE Emp_id = @empid
						 
						--insert into table 2
						INSERT INTO #Table2 (Emp_Id,KRA,KPI,[Target],[Weight],Emp_GoalSetting_Detail_Id,Actual,
											Emp_Feedback,Sup_Score,Sup_Feedback,WeightedScore,Emp_GoalSetting_Review_Detail_Id,Emp_GoalSetting_Review_Id,Review_type,KRA_Type)
						SELECT @empid,GD.KRA,GD.KPI,GD.Target,GD.Weight,GD.Emp_GoalSetting_Detail_Id,ED.Actual,ED.Emp_Feedback,ED.Sup_Score,ED.Sup_Feedback,
								ED.WeightedScore,ED.Emp_GoalSetting_Review_Detail_Id,ED.Emp_GoalSetting_Review_id,case when ES.Review_Type = 1 then 'Interim'  when es.Review_Type=2 then 'Final' END,KM.KPA_Type						
						FROM T0090_EmployeeGoalSetting G WITH (NOLOCK) INNER JOIN
							  T0095_EmployeeGoalSetting_Details GD WITH (NOLOCK) on GD.Emp_GoalSetting_Id = G.Emp_GoalSetting_Id INNER JOIN
							  T0100_EmployeeGoalSetting_Evaluation_Details ED WITH (NOLOCK) on ed.Emp_GoalSetting_Detail_Id = gd.Emp_GoalSetting_Detail_Id INNER JOIN
							  T0095_EmployeeGoalSetting_Evaluation ES WITH (NOLOCK) on ES.Emp_GoalSetting_Review_Id = ed.Emp_GoalSetting_Review_Id LEFT JOIN
							  T0040_HRMS_KPAType_Master KM WITH (NOLOCK) ON KM.KPA_Type_Id=ED.KPA_Type_ID AND KM.Cmp_ID=ED.Cmp_Id
						WHERE G.Emp_Id = @empid AND G.FinYear = @finyear AND ( G.EGS_Status <> 0 or EGS_Status <> 3)
								and ES.FinYear = @finyear   AND ( ES.Review_Status <> 0 or ES.Review_Status <> 3)
						ORDER By Emp_GoalSetting_Detail_Id,g.Emp_Id
						
							
						--insert into table 3
						
						INSERT INTO #Table3(Emp_Id,AdditionalAchievement,Review_type)
						SELECT ES.Emp_Id,ES.AdditionalAchievement,case when ES.Review_Type = 1 then 'Interim'  when es.Review_Type=2 then 'Final' END
						FROM	T0095_EmployeeGoalSetting_Evaluation ES WITH (NOLOCK)
						WHERE ES.Emp_Id = @empid and ES.FinYear = @finyear   AND ( ES.Review_Status <> 0 or ES.Review_Status <> 3) 
						--insert into table 4
						INSERT into #Table4(Emp_Id,Emp_GoalSetting_Review_Id,SupEval_Comments,YearEnd_FinalRating,YearEnd_NormalRating,Sup_PromoRecommend,Final_PromoRecommend)
						SELECT S.Emp_Id,S.Emp_GoalSetting_Review_Id,SupEval_Comments,
						rm.description_value as YearEnd_FinalRating,rmn.description_value as YearEnd_NormalRating,
						--YearEnd_FinalRating,YearEnd_NormalRating,
						case when isnull(S.Sup_PromoRecommend,0)=0 then 'No' else 'Yes' end,case when isnull(S.Final_PromoRecommend,0)=0 then 'No' else 'Yes' end
						FROM   T0100_EmployeeGoal_SupEval S WITH (NOLOCK) left JOIN
							  T0095_EmployeeGoalSetting_Evaluation ES WITH (NOLOCK) on es.Emp_Id = s.Emp_Id and es.Emp_GoalSetting_Review_Id = s.Emp_GoalSetting_Review_Id LEFT JOIN
							  T0030_HRMS_RATING_MASTER RM WITH (NOLOCK) on cast(rm.Rate_ID as varchar)=S.YearEnd_FinalRating and RM.Cmp_ID=S.Cmp_Id left join
							  T0030_HRMS_RATING_MASTER RMN WITH (NOLOCK) on cast(rmn.Rate_ID as varchar)=S.YearEnd_NormalRating and rmn.Cmp_ID=S.Cmp_Id
						WHERE  S.Emp_Id = @empid and ES.FinYear = @finyear   AND ( ES.Review_Status <> 0 or ES.Review_Status <> 3) 
						
						
						FETCH NEXT FROM cur INTO @empid	
					END
			close cur
			DEALLOCATE cur
			
						
			SELECT CompanyName	as CMP_Name	
				,CompanyLogo		
				,Emp_Id				
				,EmpCode			
				,Emp_Full_Name		
				,Department			
				,Designation		
				,Branch				
				,FinancialYear	 
			FROM #Table1
			--SELECT * 
			--FROM #Table2
			SELECT DISTINCT Emp_Id ,
					Review_type,
					Emp_GoalSetting_Detail_Id,
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then  KRA
					Else '' End KRA,
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then  KPI
					Else '' End KPI,
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then  [Target]
					Else '' End [Target],
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then [Weight]
					Else 0 End [Weight],
					Actual,
					Emp_Feedback,
					Sup_Score,
					Sup_Feedback,
					WeightedScore,
					Emp_GoalSetting_Review_Detail_Id,
					Emp_GoalSetting_Review_Id,
					KRA_TYPE							
			FROM #Table2 
			order by emp_id
			
			SELECT * FROM #Table3
			SELECT * FROM #Table4
			
			DROP TABLE #Table1
			DROP TABLE #Table2
			DROP TABLE #Table3
			DROP TABLE #Table4
		END
	ELSE if @flag=0
		BEGIN
		--select * from @Emp_Cons
			DECLARE cur CURSOR
			FOR 
				SELECT emp_id FROM @Emp_Cons
			OPEN cur
				FETCH NEXT FROM cur INTO @empid
				WHILE @@fetch_status= 0
					BEGIN
						SET @finyear = 0
						--insert into table 1
						INSERT INTO #Table1 (CompanyName,CompanyLogo,Emp_id,EmpCode,Emp_Full_Name,Department,Designation,Branch,FinancialYear)
						SELECT  C.Cmp_Name,C.cmp_logo,E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,
								d.Dept_Name,dg.Desig_Name,b.Branch_Name,EG.FinYear
						 FROM	T0080_EMP_MASTER E WITH (NOLOCK) inner join 
								T0010_COMPANY_MASTER C WITH (NOLOCK) on C.Cmp_Id = E.Cmp_ID INNER JOIN
								T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = E.Emp_ID and i.Increment_ID=e.Increment_ID  left JOIN
								T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID left JOIN
								T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id left JOIN
								T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = i.Branch_ID INNER JOIN
								T0090_EmployeeGoalSetting EG WITH (NOLOCK) on EG.Emp_id=e.Emp_ID and 
								EG.Emp_GoalSetting_Id = (select max(Emp_GoalSetting_Id)
								from T0090_EmployeeGoalSetting WITH (NOLOCK) where emp_id=@empid and CreatedDate 
								between cast(@From_Date AS datetime) and cast(@To_Date as datetime))
						 WHERE E.Emp_ID = @empid and B.Cmp_ID=@cmp_id
						 
						SELECT  @finyear = FinancialYear FROM #Table1 WHERE Emp_id = @empid
						 	
						--insert into table 2
						INSERT INTO #Table2 (Emp_Id,KRA,KPI,[Target],[Weight],Emp_GoalSetting_Detail_Id,Actual,
											Emp_Feedback,Sup_Score,Sup_Feedback,WeightedScore,Emp_GoalSetting_Review_Detail_Id,Emp_GoalSetting_Review_Id,Review_type,KRA_Type)
						SELECT @empid,GD.KRA,GD.KPI,GD.Target,GD.Weight,GD.Emp_GoalSetting_Detail_Id,'','','','',0,0,0,'',KM.KPA_Type										
						FROM T0090_EmployeeGoalSetting G WITH (NOLOCK) INNER JOIN
							  T0095_EmployeeGoalSetting_Details GD WITH (NOLOCK) on GD.Emp_GoalSetting_Id = G.Emp_GoalSetting_Id LEFT JOIN
							  T0040_HRMS_KPAType_Master KM WITH (NOLOCK) ON KM.KPA_Type_Id=GD.KPA_Type_ID AND KM.Cmp_ID=GD.Cmp_Id
						WHERE G.Emp_Id = @empid AND G.FinYear = @finyear
						ORDER By Emp_GoalSetting_Detail_Id,g.Emp_Id
						FETCH NEXT FROM cur INTO @empid	
					END
			close cur
			DEALLOCATE cur
			
			SELECT CompanyName	as CMP_Name	
				,CompanyLogo		
				,Emp_Id				
				,EmpCode			
				,Emp_Full_Name		
				,Department			
				,Designation		
				,Branch				
				,FinancialYear	 
			FROM #Table1
			
			SELECT DISTINCT  Emp_Id ,
					Review_type,
					Emp_GoalSetting_Detail_Id,
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then  KRA
					Else '' End KRA,
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then  KPI
					Else '' End KPI,
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then  [Target]
					Else '' End [Target],
					Case When row_number() OVER ( PARTITION BY Emp_GoalSetting_Detail_Id order by Emp_GoalSetting_Detail_Id) = 1
					Then [Weight]
					Else 0 End [Weight],KRA_Type					
			FROM #Table2 
			order by emp_id
			
			SELECT '="' + cast(T1.EmpCode  as VARCHAR)+ '"'  AS[Employee_Code],T1.Emp_Full_Name as[Employee Name],T2.KRA,T2.KPI,T2.KRA_Type as[KRA Type],T2.[Target],T2.[Weight] as Weightage FROM #Table1 T1 
			INNER JOIN #Table2 T2 ON T1.Emp_Id=T2.Emp_Id
			
			DROP TABLE #Table1
			DROP TABLE #Table2
		END
END



