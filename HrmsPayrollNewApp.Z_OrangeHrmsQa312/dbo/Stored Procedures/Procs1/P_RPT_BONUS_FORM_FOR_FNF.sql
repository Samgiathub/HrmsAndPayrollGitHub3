

------------------------------------------------
-------Added jimit 21/03/2016----
--For Getting the bonus Details in FNF Letter---
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
------------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_BONUS_FORM_FOR_FNF]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		Varchar(Max) = ''
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric  = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric	 = 0
	,@Emp_ID		numeric  = 0
	,@Constraint		varchar(MAX) = ''
	,@Report_Type tinyint    = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
		DECLARE @TEmp_For_DAte	as DATETIME
		DECLARE @Emp_Left_DAte	as DATETIME
		--SET @TEmp_For_DAte = @From_Date	
		
		CREATE TABLE #EMP_CONS 
			(      
				EMP_ID NUMERIC ,     
				BRANCH_ID NUMERIC,
				INCREMENT_ID NUMERIC
			)		
		EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
				
		CREATE TABLE #EMP_BONUS
		(								
			EMP_ID				NUMERIC,
			CMP_ID				NUMERIC,
			--Bonus_Id			NUMERIC,
			MONTH_NAME			VARCHAR(100),
			MONTH_DATE			DATETIME,
			Basic_Sal			NUMERIC(18,2),
			Work_Days			NUMERIC(18,2),
			Working				NUMERIC(18,2),
			Bonusable_Basic		NUMERIC(18,2),
			Bonus_Amount		NUMERIC(18,2)
		)
		CREATE NONCLUSTERED  INDEX IX_EMP_LEAVE_EMPID ON #EMP_BONUS(EMP_ID,CMP_ID)
			
						
		Declare @For_Date as Datetime
		Declare @Increment_Id as Numeric
		Declare @Wages_Type as Varchar(15)
		Declare @Effect_Allow_Amount as Numeric(18,2)
		Declare @Basic_Salary as Numeric(18,2)
		Declare @Dept_Name as varchar(100)
		Declare @Desig_Name as varchar(100)
		Declare @Branch_Name as varchar(150)
		Declare @Emp_Id_Cur as Numeric
        Declare @Effect_Allow_Amount_earning as Numeric(18,2)
        Declare @Basic_Salary_earning as Numeric(18,2)
        Declare @Other_Allow_Amount as Numeric(18,2)
		Declare @Desig_Dis_No  as NUMERIC(18,0)   
		DECLARE @Gross_Salary AS NUMERIC(18,2)
		DECLARE @Bonus_Id	as NUMERIC(18,2)
		DECLARE @date_Of_join	as DATETIME
		
		Set @Basic_Salary = 0
		Set @Effect_Allow_Amount = 0
		Set @Increment_Id = 0
		Set @Wages_Type = ''
		Set @Dept_Name = ''
		Set @Desig_Name = ''		
        Set @Effect_Allow_Amount_earning = 0
        Set @Basic_Salary_earning = 0 
		Set @Other_Allow_Amount = 0
		set @Gross_Salary = 0
		
		Declare curEmp cursor for
			Select Emp_Id From #Emp_Cons
		open curEmp                      
		fetch next from curEmp into @Emp_Id_Cur 
				while @@fetch_status = 0                    
					begin
					
						SELECT @Emp_Left_DAte = Emp_Left_Date,@date_Of_join = Date_Of_Join
						from T0080_EMP_MASTER WITH (NOLOCK)
						where	Emp_ID = @Emp_Id_Cur and Cmp_ID = @cmp_Id	
				
						SET @From_Date = dbo.GET_YEAR_START_DATE(YEAR(@Emp_Left_DAte),Month(@Emp_Left_DAte),2)
						SET @To_Date = dbo.GET_YEAR_END_DATE(YEAR(@Emp_Left_DAte),Month(@Emp_Left_DAte),2)
						--Select @Bonus_Id =  Bonus_Id 
						--from T0180_BONUS 
						--Where Emp_ID = @Emp_Id_Cur
					
						IF @Emp_Left_DAte < = @To_Date
							BEGIN
								SET @To_Date = @Emp_Left_DAte
							END
						If @date_Of_join >= @From_date 
							BEGIN					
								Set @From_date = @date_Of_join
							END
								
						Set @Temp_For_Date = @From_Date
						While @Temp_For_Date <= @To_Date
							Begin												
								Set @Basic_Salary = 0
								Set @Effect_Allow_Amount = 0
								Set @Increment_Id = 0
								Set @Wages_Type = ''
								Set @Other_Allow_Amount = 0
								
								INSERT INTO #EMP_BONUS(EMP_ID,CMP_ID,MONTH_NAME,MONTH_DATE)
								SELECT @Emp_Id_Cur,@cmp_Id,DBO.F_GET_MONTH_NAME(MONTH(@Temp_For_Date)),@Temp_For_Date
								
								Select	@Increment_Id = I.Increment_ID, @Wages_Type = Wages_Type,@Dept_Name = Dept_Name, @Desig_Name = Desig_Name,
										@Branch_Name = Branch_Name, @Basic_Salary = Basic_Salary,@Desig_Dis_No = DG.Desig_Dis_No 
								FROM	dbo.T0095_Increment I WITH (NOLOCK) inner join       
										 (SELECT	max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)  
										  WHERE		Increment_Effective_date <= @Temp_For_Date      
													AND Cmp_ID = @Cmp_ID      
										  GROUP BY emp_ID) Qry on      
										I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  Left Outer Join    
										dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = I.Dept_ID Left Outer Join
										dbo.T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on DG.Desig_ID = I.Desig_Id Inner Join
										dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = I.Branch_ID 
								WHERE I.Emp_ID = @Emp_Id_Cur 

								Select	@Basic_Salary = Case When @wages_Type = 'Monthly' Then  isnull(sum(basic_salary),0) Else @Basic_Salary End ,
										@Other_Allow_Amount =isnull(sum(Other_Allow_Amount),0) , @Basic_Salary_earning = isnull(sum(salary_amount),0) ,
										@Gross_Salary = ISNULL(sum(Gross_Salary),0)
								from	dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
								where	cmp_id=@Cmp_ID and emp_id=@Emp_Id_Cur 
										and Month(month_end_date) = Month(@Temp_For_Date) and Year(month_end_date) = Year(@Temp_For_Date)
							
								Select	@Effect_Allow_Amount = Isnull(Sum(E_AD_AMOUNT),0) 
								From	dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Inner Join
										dbo.T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID 
								Where   AD_EFFECT_ON_BONUS = 1 And EED.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
										And EED.INCREMENT_ID = @Increment_Id 

								Select  @Effect_Allow_Amount_earning = Isnull(Sum(M_AD_AMOUNT),0) 
								From	dbo.T0210_Monthly_ad_detail MAD WITH (NOLOCK) Inner Join
										dbo.T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 							
								Where	AD_EFFECT_ON_BONUS = 1 And MAD.Cmp_ID=@Cmp_ID and Emp_id= @Emp_Id_Cur 
										And Month(For_date) = Month(@Temp_For_Date) and Year(For_date) = Year(@Temp_For_Date)	
				
								
								IF  @Wages_Type= 'Monthly'
									Begin
										UPDATE  EB
										SET		EB.Bonusable_Basic = Cast(@Basic_Salary_earning + @Effect_Allow_Amount_earning as varchar(100))
										From	#EMP_BONUS EB 
										where	month(Eb.MONTH_DATE) = Month(@TEmp_For_DAte) and YEAR(Eb.MONTH_DATE) = YEAR(@TEmp_For_DAte)
												and EB.EMP_ID = @Emp_Id_Cur
									END
								Else
									BEGIN
											Update	EB
											Set		EB.Bonusable_Basic  =  Cast(@Basic_Salary_earning  + @Other_Allow_Amount + @Effect_Allow_Amount_earning as varchar(40)) 
											From	#EMP_BONUS EB inner join 								
													dbo.T0180_BONUS B   on EB.Emp_ID = B.Emp_ID Inner Join 
													T0190_BONUS_DETAIL BD							
											On		B.Bonus_ID = BD.Bonus_ID 
											Where	Month(BD.Month_Date) = Month(@Temp_For_Date) and YEAR(BD.MONTH_DATE) = YEAR(@TEmp_For_DAte)
													and EB.EMP_ID = @Emp_Id_Cur
									end				
								
								
								Update	EB 
								Set		Work_Days = Q.Present_Days,
										Working = Q.Working_Days,
										Bonus_Amount = Q.Bonus_Amount
								From	#EMP_BONUS EB INNER JOIN
										(		
										Select  B.Emp_ID,BD.Present_Days,BD.Working_Days,BD.Bonus_Amount,BD.Month_Date
										from    dbo.T0190_BONUS_DETAIL BD WITH (NOLOCK) LEFT Join 
        										T0180_BONUS B WITH (NOLOCK) ON BD.Cmp_ID = B.Cmp_ID
										Where	Month(BD.Month_Date) = Month(@Temp_For_Date) and YEAR(BD.MONTH_DATE) = YEAR(@TEmp_For_DAte)
												And B.Emp_Id = Cast(@Emp_Id_Cur as varchar(10)) and B.Bonus_ID IN (Select bonus_Id from T0180_BONUS WITH (NOLOCK) Where Emp_ID = @Emp_Id_Cur)
										)Q ON Q.Emp_ID = Eb.EMP_ID --and Q.Bonus_ID = EB.Bonus_Id 
												and month(EB.MONTH_DATE) = month(Q.Month_Date)
												and YEAR(EB.MONTH_DATE) = YEAR(EB.MONTH_DATE)
								
								UPDATE	#EMP_BONUS
								SET		Basic_Sal = @Basic_Salary 
								FROM	#EMP_BONUS
								where	Month(Month_Date) = Month(@Temp_For_Date) and YEAR(MONTH_DATE) = YEAR(@TEmp_For_DAte)
										And Emp_Id = Cast(@Emp_Id_Cur as varchar(10))										
								Set @Temp_For_Date = DATEADD(M,1,@Temp_For_Date)
							End   
					fetch next from curEmp into @Emp_Id_Cur
				end                    
		close curEmp                    
		deallocate curEmp 
		
		SELECT * from #EMP_BONUS ORDER BY EMP_ID
		DROP TABLE #EMP_BONUS
