
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_STATUTORY_ESIC_STATEMENT]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	varchar(Max)=''
,@Cat_ID 		varchar(Max)=''
,@Grd_ID 		varchar(Max)=''
,@Type_ID 		varchar(Max)=''
,@Dept_ID 		varchar(Max)=''
,@Desig_ID 		varchar(Max)=''
,@Emp_ID 		numeric
,@constraint 	varchar(MAX)
,@Report_Type	Numeric = 0

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
			Declare @AD_Def_ID numeric 	
			Declare @Emp_Share_Cont_Amount numeric 
			Declare @Employer_Share_Cont_Amount numeric 
			Declare @Total_Share_Cont_Amount numeric

			set @AD_Def_ID = 3
			set @Emp_Share_Cont_Amount =0
			set @Employer_Share_Cont_Amount = 0
			set @Total_Share_Cont_Amount =0 
		 
			IF @Branch_ID = '0' or  @Branch_ID=''
				set @Branch_ID = null
				
			IF @Cat_ID = '0' or @Cat_ID=''
				set @Cat_ID = null

			IF @Grd_ID = '0' or  @Grd_ID='' 
				set @Grd_ID = null

			IF @Type_ID = '0' or @Type_ID=''
				set @Type_ID = null

			IF @Dept_ID = '0' or @Dept_ID=''  
				set @Dept_ID = null

			IF @Desig_ID = '0' or @Desig_ID='' 
				set @Desig_ID = null

			IF @Emp_ID = 0  
				set @Emp_ID = null	
	
			IF @BRANCH_ID IS NULL
				BEGIN	
					SELECT   @BRANCH_ID = COALESCE(@BRANCH_ID + '#', '') + CAST(BRANCH_ID AS NVARCHAR(5))  FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID 
					SET @BRANCH_ID = @BRANCH_ID + '#0'
				END	
	
			CREATE table #Emp_Settlement
			(
				Emp_ID	numeric,
				For_Date Datetime,
				M_AD_Calculate_Amount Numeric(18,2),
				M_AD_Percentage Numeric(18,2),
				M_AD_Amount Numeric(18,2)
			)
			CREATE TABLE #Emp_Cons	
			 (      
			   Emp_ID numeric ,     
			   Branch_ID numeric,
			   Increment_ID numeric    
			 )   
	
			exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0  
	 
			declare @Temp_Date datetime
			declare @TempEnd_Date datetime
			DECLARE @To_Date_TEmp DATEtime
			SET @To_Date_TEmp = @To_Date
			Declare @count1 numeric 
			Declare @Month numeric 
			Declare @Year numeric 
			DECLARE @Esic_Def_Id NUMERIC
			SEt @Esic_Def_Id = 3
			
			set @Temp_Date = @From_Date 
			set @TempEnd_Date = dateadd(mm,1,@From_Date ) - 1 
			set @count1 = 1 
			
			If @Report_Type = 0 
				BEGIN
					IF Object_ID('tempdb..#ESIC_Statement_Report') is not null
					drop TABLE #ESIC_Statement_Report

					CREATE table #ESIC_Statement_Report
					(
						Cmp_ID						numeric,
						Month						numeric,
						YEAR						Numeric,								
						covered_Employee			Numeric,
						covered_Employee_Wages		Numeric(18,2),
						uncovered_Employee			Numeric,
						uncovered_Employee_Wages	Numeric(18,2),
						Total_Employee				numeric,
						Total_Employee_Wages		Numeric(18,2),	
						Contribution_175			Numeric(18,2),
						Contribution_475			Numeric(18,2),
						Total_Contribution			Numeric(18,2),
						Date_Of_Payment				varchar(20)
					)		 
			
				DECLARE @EmpId NUMERIC
				Declare @Sal_St_Date   Datetime    
				Declare @Sal_end_Date   Datetime 
				WHILE @Temp_Date <= @To_Date_TEmp 
					Begin						
						set @Month = month(@TempEnd_Date)
						set @Year = year(@TempEnd_Date)
						
						
						
						Insert INTO #ESIC_Statement_Report(cmp_Id,Month,YEAR)
						SELECT	@Cmp_Id,@Month,@Year
						
						IF Object_ID('tempdb..#GEN') is not null
						drop TABLE #GEN
						
						SELECT	G.Branch_ID, G.Sal_st_Date, DATEADD(m, 1, G.Sal_st_Date) As Sal_End_Date,G.ESIC_EMPLOYER_CONTRIBUTION
						INTO	#GEN
						FROM	(
									SELECT	G1.Branch_ID,G1.ESIC_Employer_Contribution,
										(CASE WHEN DAY(Sal_st_Date) > 1 THEN DATEADD(M,-1, DATEADD(D, DAY(Sal_st_Date)-DAY(@Temp_Date), @Temp_Date)) ELSE DATEADD(D, DAY(Sal_st_Date)-DAY(@Temp_Date), @Temp_Date) END ) AS Sal_st_Date	
									FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK) 
											inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=G1.Branch_ID
									WHERE	For_Date = (
															SELECT Max(For_Date) FROM T0040_GENERAL_SETTING G2 WITH (NOLOCK)															
															WHERE For_Date < @TempEnd_date and G1.Branch_id=G2.Branch_ID AND G1.Cmp_ID=G2.Cmp_ID
														) AND G1.Cmp_ID=@Cmp_ID
						) G		
	

							
						If @Branch_ID is null
							Begin 					
								select Top 1 @Sal_St_Date  = Sal_st_Date 
								from	T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
										and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Temp_Date and Cmp_ID = @Cmp_ID)    
							End
						Else
							Begin							
								  select @Sal_St_Date  =Sal_st_Date 
								  from T0040_GENERAL_SETTING As G1 WITH (NOLOCK)
								  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=G1.Branch_ID
								  where cmp_ID = @cmp_ID 
								  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Temp_Date and Cmp_ID = @Cmp_ID)    
							End    
					
					
					if isnull(@Sal_St_Date,'') = ''    
						begin    
						   set @From_Date  = @Temp_Date     
						   set @To_Date = @TempEnd_date    
						end     
					else if day(@Sal_St_Date) = 1 
						begin    
							set @From_Date  = @Temp_Date     
							set @To_Date = @TempEnd_date    
						end     
					else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						begin    
						   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Temp_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Temp_Date) )as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
						   set @From_Date = @Sal_St_Date
						   Set @To_Date = @Sal_end_Date   
						End
							
				
					If Exists(Select S_Sal_Tran_Id From dbo.T0201_MONTHLY_SALARY_SETT as s  WITH (NOLOCK)
									 inner join T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID=s.Increment_ID
									 INNER JOIN #Gen as G ON G.Branch_Id=i.Branch_ID
									  where S_Eff_Date Between G.Sal_st_Date And G.Sal_End_Date And S.Cmp_Id=@Cmp_Id)
					Begin 
								INSERT INTO #Emp_Settlement
								SELECT	SG.EMP_ID, @From_Date as For_Date, sum(M_AD_Calculated_Amount),ESIC_PER, sum(ESIC_Amount)
								FROM	T0201_MONTHLY_SALARY_SETT  SG  WITH (NOLOCK) INNER JOIN 
										(Select For_Date, Emp_ID, M_AD_Percentage as ESIC_PER, (M_AD_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_cutoff,0)) as ESIC_Amount, 
											--M_AD_Amount * 100 / M_AD_Percentage as M_AD_Calculated_Amount,
											M_AD_Calculated_Amount,
											SAL_TRAN_ID 
										From	T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
										where	AD_DEF_ID = @AD_Def_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
												and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
												AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
												T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
												#Emp_Cons E_S on E.Emp_ID = E_S.Emp_ID	
								WHERE   e.CMP_ID = @CMP_ID 
										And S_Eff_Date Between @From_Date And @To_Date
								Group by SG.EMP_ID,ESIC_PER
					End		
						
			  --UPdate	#ESIC_Statement_Report
				--SET		Total_Employee = (select Count(Ec.Emp_Id) as ESIC_COunt
				--			from #Emp_Cons Ec Inner join  
				--				 T0100_EMP_EARN_DEDUCTION  Mad  On Ec.Increment_Id = MAd.Increment_Id and Ec.emp_Id = Mad.emp_Id inner join
				--				 T0050_AD_MASTER Am On Am.AD_ID = mad.AD_ID	
				--			where ad_def_Id = @Esic_Def_Id)	
				--where	month = @Month and YEAR = @Year
				
				--UPdate	#ESIC_Statement_Report
				--SET		covered_Employee = (select	Count(Ec.Emp_Id) as ESIC_COunt
				--							from	#Emp_Cons Ec Inner join  
				--									T0100_EMP_EARN_DEDUCTION  Mad  On Ec.Increment_Id = MAd.Increment_Id and Ec.emp_Id = Mad.emp_Id inner join
				--									T0050_AD_MASTER Am On Am.AD_ID = mad.AD_ID	
				--							where	ad_def_Id = @Esic_Def_Id  and Mad.E_AD_AMOUNT <> 0)	
				--where	month = @Month and YEAR = @Year
					
					
					
				--select  @Emp_Share_Cont_Amount = sum(Emp_Cont_Amount) , 
				--	    @Employer_Share_Cont_Amount = sum(Employer_Cont_Amount) 
				--From	T0220_ESIC_Challan ec	
				--		inner JOIN #Gen as G1 on G1.Branch_Id=ec.Branch_ID
				--Where ec.Cmp_ID = @Cmp_ID and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) >= G1.Sal_st_Date and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) <= G1.Sal_End_Date and 
				--isnull(Ec.Branch_ID,0) = isnull(G1.Branch_Id ,isnull(Ec.Branch_ID,0))
				--set @Total_Share_Cont_amount =  @Emp_Share_Cont_Amount + @Employer_Share_Cont_Amount  
				
				Declare @Count as numeric(18,0)
				Declare @Ad_ID as numeric(18,0)
							
			  --UPDATE	ES 
				--SET		Total_Employee_Wages = covered_Employee_Wages + uncovered_Employee_Wages,
				--			Total_Employee = covered_Employee + uncovered_Employee					
				--From		#ESIC_Statement_Report	ES	Inner join										
				--		(select  Sum( MAD.M_AD_Calculated_Amount ) + sum( ISNULL(ES.M_AD_Calculate_Amount,0)) + sum(Isnull(Arear_Calc_Amount,0) )+ sum( ISNULL(MS.Arear_Basic,0)) + 
				--				sum(ISNULL(MS.Basic_Salary_Arear_cutoff ,0)) + sum( ISNULL(ESICNT.Amount,0)) as ESIC_WAGES,
				--				Count(E.Emp_ID) as Total_Employee,@Month as month1,@Year as year1
				--		from    t0210_Monthly_Ad_Detail Mad INNER JOIN 
				--				T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN 
				--				#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID	inner join
				--				T0050_AD_MASTER Am On Am.AD_ID = mad.AD_ID	Left Outer Join
				--				#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date inner join 
				--				T0200_MONTHLY_SALARY MS ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID	inner join 								
				--				T0095_INCREMENT I_Q ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	Inner join 
				--				T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID left outer JOIN 
				--				#Gen G on G.Branch_Id= I_Q.Branch_ID Left Outer Join
				--				(Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID	
				--				 From T0210_MONTHLY_AD_DETAIL 
				--				 Where AD_ID in (
				--						Select AD_ID from T0060_EFFECT_AD_MASTER 
				--						where CMP_ID = @Cmp_ID and EFFECT_AD_ID = (
				--							select top 1 AD_ID From T0050_AD_MASTER where CMP_ID = @Cmp_ID 
				--							and AD_DEF_ID = @Esic_Def_Id))
				--							and (M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <> 0 )
				--							and For_Date >= @Temp_Date and For_Date <= @TempEnd_date
				--						Group by Emp_ID) Qry on
				--						EC.Emp_ID = Qry.Emp_ID Left join							
				--				  (select	For_Date,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount 
				--					from		T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  Es INNER JOIN	
				--							T0050_AD_MASTER Am On Am.AD_ID = Es.Ad_Id and am.CMP_ID = es.Cmp_Id 
				--					where   Es.Cmp_Id = @Cmp_Id and ad_def_Id  = @Esic_Def_Id
				--				  group by  For_Date)	ESICNT on month(ESICNT.For_Date)= @Month and year(ESICNT.For_Date) = @Year
										    					 
				--		where   AM.AD_NOT_EFFECT_SALARY <> 1 And Sal_Type <> 1 and 
				--				AM.ad_def_Id = @Esic_Def_Id and E.cmp_Id = @Cmp_Id
				--				and month(Mad.for_date) = @Month and year(Mad.for_date) = @Year)Q On Q.month1= Es.Month and Q.year1 = Es.YEAR					
			
				UPDATE 	ES 
				SET		 Contribution_175 = Q.M_AD_Amount
						,Contribution_475 = Q.EMPLOYER_CONT_AMOUNT
						FROM #ESIC_Statement_Report	ES INNER JOIN								
						(select sum(MAD.M_AD_Amount) + sum(ISNULL(ES.M_AD_Amount,0)) +  sum(Isnull(MAD.M_AREAR_AMOUNT,0)) + sum(Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0)) + sum(ISNULL(ESICNT.Esic,0)) as M_AD_Amount
								,sum(ceiling(G.ESIC_EMPLOYER_CONTRIBUTION  * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100))EMPLOYER_CONT_AMOUNT
								,@Month as [month],@Year as [Year]
						from    t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
								#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID	inner join
								T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID	Left Outer Join
								#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date inner join 
								T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID	inner join 								
								T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	Inner join 
								T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID left outer JOIN 
								#Gen G on G.Branch_Id= I_Q.Branch_ID Left Outer Join
								(select	For_Date,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount 
									from		T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  Es WITH (NOLOCK) INNER JOIN	
											T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = Es.Ad_Id and am.CMP_ID = es.Cmp_Id 
									where   Es.Cmp_Id = @Cmp_Id and ad_def_Id  = @Esic_Def_Id
								  group by  For_Date)	ESICNT on month(ESICNT.For_Date)= @Month and year(ESICNT.For_Date) = @Year
										    					 
						where   (Mad.M_AD_Amount <> 0 or Mad.M_AREAR_AMOUNT <> 0) and 
								AM.AD_NOT_EFFECT_SALARY <> 1 And Sal_Type <> 1 and 
								AM.ad_def_Id = @Esic_Def_Id and E.cmp_Id = @Cmp_Id
								and month(Mad.for_date) = @Month and year(Mad.for_date) = @Year)
								Q ON Q.month = ES.Month and Q.Year = Es.YEAR							
					
				UPDATE 	ES 
				SET		covered_Employee_Wages = Q.ESIC_WAGES,
						covered_Employee = q.Covered_Employee
						--uncovered_Employee = Total_Employee - Es.covered_Employee
						--,uncovered_Employee_Wages = Total_Employee_Wages - Es.covered_Employee
				FROm  #ESIC_Statement_Report ES Inner JOIN
						(select  Sum( MAD.M_AD_Calculated_Amount ) + sum( ISNULL(ES.M_AD_Calculate_Amount,0)) + sum(Isnull(Arear_Calc_Amount,0) )+ sum( ISNULL(MS.Arear_Basic,0)) + 
								sum(ISNULL(MS.Basic_Salary_Arear_cutoff ,0)) + sum( ISNULL(ESICNT.Amount,0)) as ESIC_WAGES
								,Count(E.Emp_ID) as Covered_Employee,@Month as month1,@Year as Year1
						from    t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
								#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID	inner join
								T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID	Left Outer Join
								#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date inner join 
								T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID	Left Outer Join
								(Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID	
								 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
								 Where AD_ID in (
										Select AD_ID from T0060_EFFECT_AD_MASTER WITH (NOLOCK)
										where CMP_ID = @Cmp_ID and EFFECT_AD_ID = (
											select top 1 AD_ID From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @Cmp_ID 
											and AD_DEF_ID = @Esic_Def_Id))
											and (M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <> 0 )
											and For_Date >= @Temp_Date and For_Date <= @TempEnd_date
										Group by Emp_ID) Qry on
										EC.Emp_ID = Qry.Emp_ID Left join							
								  (select	For_Date,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount 
									from		T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  Es WITH (NOLOCK) INNER JOIN	
											T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = Es.Ad_Id and am.CMP_ID = es.Cmp_Id 
									where   Es.Cmp_Id = @Cmp_Id and ad_def_Id  = @Esic_Def_Id
								  group by  For_Date)	ESICNT on month(ESICNT.For_Date)= @Month and year(ESICNT.For_Date) = @Year
										    
						where   (Mad.M_AD_Amount <> 0 or Mad.M_AREAR_AMOUNT <> 0) and 
								AM.AD_NOT_EFFECT_SALARY <> 1 And Sal_Type <> 1 and 
								AM.ad_def_Id = @Esic_Def_Id and E.cmp_Id = @Cmp_Id
								and month(Mad.for_date) = @Month and year(Mad.for_date) = @Year)Q On Q.month1 = ES.Month and Q.Year1 = Es.YEAR
					WHERE   Month = @Month and YEAR = @Year
					
				UPDATE 	ES 
				SET		uncovered_Employee_Wages = Q.ESIC_WAGES,
						uncovered_Employee = q.Covered_Employee
						--uncovered_Employee = Total_Employee - Es.covered_Employee
						--,uncovered_Employee_Wages = Total_Employee_Wages - Es.covered_Employee
				FROm  #ESIC_Statement_Report ES Inner JOIN
						(select  Sum( MAD.M_AD_Calculated_Amount ) + sum( ISNULL(ES.M_AD_Calculate_Amount,0)) + sum(Isnull(Arear_Calc_Amount,0) )+ sum( ISNULL(MS.Arear_Basic,0)) + 
								sum(ISNULL(MS.Basic_Salary_Arear_cutoff ,0)) + sum( ISNULL(ESICNT.Amount,0)) as ESIC_WAGES
								,Count(E.Emp_ID) as Covered_Employee,@Month as month1,@Year as Year1
						from    t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) INNER JOIN 
								T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
								#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID	inner join
								T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID	Left Outer Join
								#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date inner join 
								T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID	Left Outer Join
								(Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID	
								 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) 
								 Where AD_ID in (
										Select AD_ID from T0060_EFFECT_AD_MASTER WITH (NOLOCK)
										where CMP_ID = @Cmp_ID and EFFECT_AD_ID = (
											select top 1 AD_ID From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @Cmp_ID 
											and AD_DEF_ID = @Esic_Def_Id))
											and (M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <> 0 )
											and For_Date >= @Temp_Date and For_Date <= @TempEnd_date
										Group by Emp_ID) Qry on
										EC.Emp_ID = Qry.Emp_ID Left join							
								  (select	For_Date,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount 
									from		T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  Es WITH (NOLOCK) INNER JOIN	
											T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = Es.Ad_Id and am.CMP_ID = es.Cmp_Id 
									where   Es.Cmp_Id = @Cmp_Id and ad_def_Id  = @Esic_Def_Id
								  group by  For_Date)	ESICNT on month(ESICNT.For_Date)= @Month and year(ESICNT.For_Date) = @Year
										    
						where   (Mad.M_AD_Amount = 0) and 
								AM.AD_NOT_EFFECT_SALARY <> 1 And Sal_Type <> 1 and 
								AM.ad_def_Id = @Esic_Def_Id and E.cmp_Id = @Cmp_Id
								and month(Mad.for_date) = @Month and year(Mad.for_date) = @Year)Q On Q.month1 = ES.Month and Q.Year1 = Es.YEAR
					WHERE   Month = @Month and YEAR = @Year	
				
							
				UPDATE   #ESIC_Statement_Report				
				SET		Total_Employee_Wages = IsNULL(covered_Employee_Wages,0) + IsNULL(uncovered_Employee_Wages,0),
						Total_Employee = IsNULL(covered_Employee,0) + IsNULL(uncovered_Employee,0)	
				where	Month = @Month and YEAR = @Year
				
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @TempEnd_date = dateadd(m,1,@TempEnd_date)
				set @count1 = @count1 + 1	
					
			END		
				
				DECLARE @SQL1 NVARCHAR(MAX)
				DECLARE @EMPLOYER_ESIC_PERCENTAGE as varchar(50)
				DECLARE @EMPLOYEE_ESIC_PERCENTAGE as varchar(50)

				SELECT	TOP 1 @EMPLOYER_ESIC_PERCENTAGE = ESIC_EMPLOYER_CONTRIBUTION 
				FROM	#GEN

				SELECT	@EMPLOYEE_ESIC_PERCENTAGE = Cast(mad.M_AD_Percentage as Numeric(5,2))
				FROM	t0210_Monthly_Ad_Detail mad WITH (NOLOCK)
						inner join T0050_AD_MASTER AM WITH (NOLOCK) ON mad.AD_ID = AM.AD_ID AND AM.CMP_ID = Mad.CMP_ID
				WHERE	AM.CMP_ID = @CMP_ID AND AD_DEF_ID = 3 
						and month(Mad.for_date) = @Month and year(Mad.for_date) = @Year
						
				
				
				SET @SQL1 = 'ALTER TABLE #ESIC_Statement_Report Drop Column Cmp_ID				
							SELECT DBO.F_GET_MONTH_NAME(MONTH) as Month,YEAR,COVERED_EMPLOYEE,COVERED_EMPLOYEE_WAGES,
								   UNCOVERED_EMPLOYEE,UNCOVERED_EMPLOYEE_WAGES,TOTAL_EMPLOYEE,TOTAL_EMPLOYEE_WAGES
								  ,CONTRIBUTION_175 AS [Contribution_' + @EMPLOYEE_ESIC_PERCENTAGE +' ]
								  ,CONTRIBUTION_475  AS [Contribution_' + @EMPLOYER_ESIC_PERCENTAGE +' ]
								  ,(CONTRIBUTION_175 + CONTRIBUTION_475) as Total_Contribution,DATE_OF_PAYMENT
							from #ESIC_Statement_Report'

				exec SP_EXECUTESQL @SQL1

				
				
		END 
				
			ELSE IF @Report_Type = 1 
				BEGIN
					IF Object_ID('tempdb..#ESIC_Statement_Exempted_Employee_Report') is not null
					drop TABLE #ESIC_Statement_Exempted_Employee_Report

					CREATE table #ESIC_Statement_Exempted_Employee_Report
					(
						Cmp_ID						numeric,
						Emp_Id						NUMERIC,
						Emp_Code					varchar(50),
						Employee_Name				varchar(250),
						Branch_Name					varchar(250),						
						Gross						Numeric,			
						ESIC						Numeric						
					)		 
					
				INSERT INTO #ESIC_Statement_Exempted_Employee_Report(Cmp_ID,Emp_Id,Emp_Code,Employee_Name,Branch_Name)	
				SELECT  @Cmp_Id,em.Emp_ID,Em.Alpha_Emp_Code,Em.Emp_Full_Name,bm.Branch_Name
				FROM	T0080_EMP_MASTER Em WITH (NOLOCK) INNER JOIN
						#Emp_Cons Ec On Ec.Emp_ID = Em.Emp_ID INNER JOIN
						T0095_INCREMENT I WITH (NOLOCK) On I.Increment_ID = ec.Increment_ID INNER JOIN
						T0030_BRANCH_MASTER BM	WITH (NOLOCK) On bm.Branch_ID = Ec.Branch_ID
				
				
				
				IF Object_ID('tempdb..#GEN1') is not null
						drop TABLE #GEN1
						
						SELECT	G.Branch_ID, G.Sal_st_Date, DATEADD(m, 1, G.Sal_st_Date) As Sal_End_Date,G.ESIC_EMPLOYER_CONTRIBUTION
						INTO	#GEN1
						FROM	(
									SELECT	G1.Branch_ID,G1.ESIC_Employer_Contribution,
										(CASE WHEN DAY(Sal_st_Date) > 1 THEN DATEADD(M,-1, DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date)) ELSE DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date) END ) AS Sal_st_Date	
									FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
											inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=G1.Branch_ID
									WHERE	For_Date = (
															SELECT Max(For_Date) FROM T0040_GENERAL_SETTING G2 WITH (NOLOCK)															
															WHERE For_Date < @From_Date and G1.Branch_id=G2.Branch_ID AND G1.Cmp_ID=G2.Cmp_ID
														) AND G1.Cmp_ID=@Cmp_ID
						) G		
	
						If @Branch_ID is null
							Begin 					
								select Top 1 @Sal_St_Date  = Sal_st_Date 
								from	T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
										and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
							End
						Else
							Begin							
								  select @Sal_St_Date  =Sal_st_Date 
								  from T0040_GENERAL_SETTING As G1 WITH (NOLOCK)
								  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=G1.Branch_ID
								  where cmp_ID = @cmp_ID 
								  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
							End    
					
					
					if isnull(@Sal_St_Date,'') = ''    
						begin    
						   set @From_Date  = @From_Date     
						   set @To_Date = @To_Date    
						end     
					else if day(@Sal_St_Date) = 1 
						begin    
							set @From_Date  = @From_Date     
							set @To_Date = @To_Date    
						end     
					else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
						begin    
						   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
						   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
						   set @From_Date = @Sal_St_Date
						   Set @To_Date = @Sal_end_Date   
						End
							
				
					If Exists(Select S_Sal_Tran_Id From dbo.T0201_MONTHLY_SALARY_SETT as s WITH (NOLOCK)
									 inner join T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID=s.Increment_ID
									 INNER JOIN #Gen1 as G ON G.Branch_Id=i.Branch_ID
									  where S_Eff_Date Between G.Sal_st_Date And G.Sal_End_Date And S.Cmp_Id=@Cmp_Id)
					Begin 

								INSERT INTO #Emp_Settlement
								SELECT  SG.EMP_ID, @From_Date as For_Date, sum(M_AD_Calculated_Amount),ESIC_PER, sum(ESIC_Amount)
									FROM T0201_MONTHLY_SALARY_SETT  SG  WITH (NOLOCK) INNER JOIN 
									( Select For_Date, Emp_ID, M_AD_Percentage as ESIC_PER, (M_AD_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_cutoff,0)) as ESIC_Amount, 
											--M_AD_Amount * 100 / M_AD_Percentage as M_AD_Calculated_Amount,
											M_AD_Calculated_Amount,
											SAL_TRAN_ID 
										From 
										T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
										where AD_DEF_ID = @AD_Def_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
										and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
										AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
										T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
									#Emp_Cons E_S on E.Emp_ID = E_S.Emp_ID	
							WHERE   e.CMP_ID = @CMP_ID 
									And S_Eff_Date Between @From_Date And @To_Date
							Group by SG.EMP_ID,ESIC_PER
					End		
					
					UPDATE 	 ES
					SET		 ESIC = Q.M_AD_Amount + Q.EMPLOYER_CONT_AMOUNT,
							 Gross = Q.ESIC_WAGES					
					FROM	#ESIC_Statement_Exempted_Employee_Report	ES INNER JOIN									
							(select sum(IsNull(MAD.M_AD_Amount,0)) + sum(ISNULL(ES.M_AD_Amount,0)) +  sum(Isnull(MAD.M_AREAR_AMOUNT,0)) + sum(Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0)) + sum(ISNULL(ESICNT.Esic,0)) as M_AD_Amount
									,sum(ceiling(Isnull(G.ESIC_EMPLOYER_CONTRIBUTION,0)  * (Isnull(M_AD_Calculated_Amount,0) + ISNULL(ES.M_AD_Calculate_Amount,0)) /100))EMPLOYER_CONT_AMOUNT
									,EC.Emp_ID,
									 Sum( MAD.M_AD_Calculated_Amount ) + sum( ISNULL(ES.M_AD_Calculate_Amount,0)) + sum(Isnull(Arear_Calc_Amount,0) )+ sum( ISNULL(MS.Arear_Basic,0)) + 
									sum(ISNULL(MS.Basic_Salary_Arear_cutoff ,0)) + sum( ISNULL(ESICNT.Amount,0)) as ESIC_WAGES
							from    t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) INNER JOIN 
									T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
									#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID	inner join
									T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID	Left Outer Join
									#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date inner join 
									T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID	inner join 								
									T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	Inner join 
									T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID left outer JOIN 
									#Gen1 G on G.Branch_Id= I_Q.Branch_ID Left Outer Join
									(Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID	
								 From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
								 Where AD_ID in (
										Select AD_ID from T0060_EFFECT_AD_MASTER WITH (NOLOCK)
										where CMP_ID = @Cmp_ID and EFFECT_AD_ID = (
											select top 1 AD_ID From T0050_AD_MASTER WITH (NOLOCK) where CMP_ID = @Cmp_ID 
											and AD_DEF_ID = @Esic_Def_Id))
											and (M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <> 0 )
											and For_Date >= @Temp_Date and For_Date <= @TempEnd_date
										Group by Emp_ID) Qry on
										EC.Emp_ID = Qry.Emp_ID
									Left Outer Join
									(select	For_Date,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount 
										from		T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  Es WITH (NOLOCK) INNER JOIN	
												T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = Es.Ad_Id and am.CMP_ID = es.Cmp_Id 
										where   Es.Cmp_Id = @Cmp_Id and ad_def_Id  = @Esic_Def_Id
									  group by  For_Date)	ESICNT on month(ESICNT.For_Date)= Month(@From_Date) and year(ESICNT.For_Date) = Year(@From_Date)
											    					 
							where   (Mad.M_AD_Amount = 0) and 
									AM.AD_NOT_EFFECT_SALARY <> 1 And Sal_Type <> 1 and 
									AM.ad_def_Id = @Esic_Def_Id and E.cmp_Id = @Cmp_Id
									and month(Mad.for_date) = Month(@From_Date) and year(Mad.for_date) = Year(@From_Date)
							GROUP By EC.Emp_ID)	Q ON Q.emp_Id = Es.Emp_Id
							
					
					
					--UPDATE 	ES
					--SET		Gross = Q.ESIC_WAGES
					--FROM	#ESIC_Statement_Exempted_Employee_Report ES INNER JOIN
					
					--		(select  sum(Isnull(MAD.M_AD_Calculated_Amount,0)) + sum(Isnull(ES.M_AD_Calculate_Amount,0)) + sum(Isnull(Arear_Calc_Amount,0)) + sum(Isnull(MS.Arear_Basic,0)) + 
					--				sum(Isnull(MS.Basic_Salary_Arear_cutoff,0)) + sum(Isnull(ESICNT.Amount,0)) as ESIC_WAGES
					--				,EC.Emp_ID
					--		from    t0210_Monthly_Ad_Detail Mad INNER JOIN 
					--				T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN 
					--				#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID	inner join
					--				T0050_AD_MASTER Am On Am.AD_ID = mad.AD_ID	Left Outer Join
					--				#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date inner join 
					--				T0200_MONTHLY_SALARY MS ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID	Left Outer Join
					--				(Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID	
					--				 From T0210_MONTHLY_AD_DETAIL 
					--				 Where AD_ID in (
					--						Select AD_ID from T0060_EFFECT_AD_MASTER 
					--						where CMP_ID = @Cmp_ID and EFFECT_AD_ID = (
					--							select top 1 AD_ID From T0050_AD_MASTER where CMP_ID = @Cmp_ID 
					--							and AD_DEF_ID = @Esic_Def_Id))
					--							and (M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <> 0 )
					--							and For_Date >= @From_Date and For_Date <= @To_Date
					--						Group by Emp_ID) Qry on
					--						EC.Emp_ID = Qry.Emp_ID Left join							
					--				  (select	For_Date,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount 
					--					from		T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  Es INNER JOIN	
					--							T0050_AD_MASTER Am On Am.AD_ID = Es.Ad_Id and am.CMP_ID = es.Cmp_Id 
					--					where   Es.Cmp_Id = @Cmp_Id and ad_def_Id  = @Esic_Def_Id
					--				  group by  For_Date)	ESICNT on month(ESICNT.For_Date) = Month(@From_Date) 
					--				  and year(ESICNT.for_date) = Year(@From_Date)											    
					--		where   --(Mad.M_AD_Amount = 0) and
					--				AM.AD_NOT_EFFECT_SALARY <> 1 And Sal_Type <> 1 and 
					--				AM.ad_def_Id = @Esic_Def_Id and E.cmp_Id = @Cmp_Id
					--				and month(Mad.for_date) = Month(@From_Date) and year(Mad.for_date) = Year(@From_Date)
					--		GRoup By EC.Emp_ID)Q ON	Q.Emp_ID = Es.emp_Id
				
				Alter table #ESIC_Statement_Exempted_Employee_Report DROP COLUMN emp_Id,Cmp_Id
					
				SELECT * from #ESIC_Statement_Exempted_Employee_Report
				where (ESIC is NOt Null)


									
				END
			
			 
	
--select @Ad_ID=AD_ID  from T0050_AD_MASTER where AD_DEF_ID=@AD_Def_ID and AD_not_effect_salary <>1 and CMP_ID=@Cmp_ID  

--Declare @Non_Coun as numeric(18,0)
--Declare @Non_Coun_Gross as numeric(22,0)	
--Declare @New_Emp_ID as numeric(18,0)
--set @Non_Coun=0
--declare curAD cursor for                    
--select Distinct(Emp_ID) from #Emp_Cons	
--	where Emp_ID not in(
--	Select MAD.Emp_ID
--		 From T0210_MONTHLY_AD_DETAIL  MAD Inner join 
--			  T0050_AD_MASTER ADM ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
--		T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN 
--			#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
--					T0200_MONTHLY_SALARY MS ON MAD.SAL_tRAN_ID = MS.SAL_TRAN_ID INNER JOIN 
--					T0095_INCREMENT I_Q ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	inner join
--					T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
--					T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
--					T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
--					T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
--					T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID INNER JOIN 
--					T0010_COMPANY_MASTER CM ON MAD.CMP_ID = CM.CMP_ID  
					
--		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
--				and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_not_effect_salary <>1 And sal_type<>1)
	
--	open curAD                      
--  fetch next from curAD into @New_Emp_ID
--		while @@fetch_status = 0                    
--		 begin 
--               if isnull(@Ad_ID,0) <> 0
--				BEgin
--					declare @New_ad_ID as numeric(18,0)
--					declare curAD_sub cursor for           
--						select ad_id from T0060_EFFECT_AD_MASTER where cmp_id=@Cmp_ID and Effect_ad_id=@ad_id
--					open curAD_sub                      
--					fetch next from curAD_sub into @New_ad_ID
--						while @@fetch_status = 0                    
--						begin 
--							declare @ad_amount as numeric(22,0)
--							set @ad_amount=0
--							select @ad_amount = SUM(isnull(M_ad_amount,0)) from T0210_MONTHLY_AD_DETAIL where Emp_ID=@New_Emp_ID And AD_ID=@New_ad_ID and For_Date >=@From_Date and For_Date<=@To_Date 
--							set @Non_Coun_Gross=isnull(@Non_Coun_Gross,0) + isnull(@ad_amount,0)
--						fetch next from curAD_sub into @New_ad_ID
--				        end                    
--				 close curAD_sub                    
--				 deallocate curAD_sub
--				End
				
--               set @Non_Coun = @Non_Coun + 1
--  			fetch next from curAD into @New_Emp_ID
                  
--		end                    
-- close curAD                    
-- deallocate curAD  		
 	
--		Select @Count=isnull(count(Distinct(MAD.Emp_ID)),0)
--		 From T0210_MONTHLY_AD_DETAIL  MAD Inner join 
--			  T0050_AD_MASTER ADM ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
--			T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN 
--			#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
--					T0200_MONTHLY_SALARY MS ON MAD.SAL_tRAN_ID = MS.SAL_TRAN_ID INNER JOIN 
--					T0095_INCREMENT I_Q ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	inner join
--					T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
--					T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
--					T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
--					T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
--					T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID INNER JOIN 
--					T0010_COMPANY_MASTER CM ON MAD.CMP_ID = CM.CMP_ID  
					
--		WHERE E.Cmp_ID = @Cmp_Id and For_date >= @From_Date and For_date <= @To_Date And MAD.M_AD_Amount>0
--				and  ADM.AD_DEF_ID = @AD_Def_ID And ADM.AD_not_effect_salary <> 1 And sal_type <> 1
				
	
			--Select Distinct M_AD_Tran_ID,MAD.Sal_Tran_ID,S_Sal_Tran_ID,L_Sal_Tran_ID,MAD.Emp_ID,MAD.Cmp_ID,MAD.AD_ID,MAD.For_Date,
				--	MAD.M_AD_Percentage,MAD.M_AD_Amount + ISNULL(ES.M_AD_Amount,0) + Isnull(MAD.M_AREAR_AMOUNT,0)+ Isnull(MAD.M_AREAR_AMOUNT_Cutoff,0) + ISNULL(ESICNT.Esic,0) as M_AD_Amount,
				--	MAD.M_AD_Flag,MAD.M_AD_Actual_Per_Amount,	--M_AREAR_AMOUNT Ankit 13012014
				--	MAD.M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0) + Isnull(Arear_Calc_Amount,0) + ISNULL(MS.Arear_Basic,0)+ ISNULL(MS.Basic_Salary_Arear_cutoff ,0) + ISNULL(ESICNT.Amount,0) as M_AD_Calculated_Amount,
				--	MAD.Temp_Sal_Tran_ID,MAD.M_AD_NOT_EFFECT_ON_PT,MAD.M_AD_NOT_EFFECT_SALARY,MAD.M_AD_EFFECT_ON_OT,
				--	MAD.M_AD_EFFECT_ON_EXTRA_DAY,MAD.Sal_Type,MAD.M_AD_EFFECT_DATE,MAD.M_AD_EFFECT_ON_LATE,MAD.M_AREAR_AMOUNT,
				--	MAD.FOR_FNF,MAD.To_date,
				--	isnull(@Count,0) as Total_Emp_Count,ISNULL(EmpName_Alias_ESIC,Emp_Full_Name) as Emp_full_Name,Date_Of_Join,E.Emp_Left_Date,Grd_Name,Alpha_Emp_Code as Emp_code,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
				--	,G.ESIC_EMPLOYER_CONTRIBUTION as EMPLOYER_CONT_PER ,CMP_NAME,CMP_ADDRESS,Cm.ESic_No as Cmp_ESIC_No
				--	,SIN_NO AS ESIC_NO ,Month(MAD.For_Date) as Month ,Year(MAD.For_Date) as Year
				--	--,ceiling(@EMPLOYER_CONT_PER * M_AD_Calculated_Amount /100)EMPLOYER_CONT_AMOUNT
				--	--,round(@EMPLOYER_CONT_PER * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100,2)EMPLOYER_CONT_AMOUNT
				--	,ceiling(G.ESIC_EMPLOYER_CONTRIBUTION  * (M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100)EMPLOYER_CONT_AMOUNT	--Ankit 13012014 
				--	,MS.SAL_CAL_DAYS,DAY_SALARY , @From_Date as P_From_Date , @To_Date as P_To_Date
				--	,@Emp_Share_Cont_Amount  Emp_Share_Cont_Amount , @Employer_Share_Cont_Amount Employer_Share_Cont_Amount
				--	,@Total_Share_Cont_amount Total_Share_cont_Amount , dbo.F_Number_TO_Word(@Total_Share_Cont_amount) Total_share_Cont_Amount_In_Word,@Non_Coun as Non_Contribution,@Non_Coun_Gross as Non_Contribution_Gross
				--	,BM.Branch_Name
				--	,sb.SubBranch_Name
				--	,E.Alpha_Emp_Code,E.Emp_First_Name   --added jimit 15062015
				--	,VS.Vertical_Name,SV.SubVertical_Name
				-- From T0210_MONTHLY_AD_DETAIL  MAD Inner join 
				--	  T0050_AD_MASTER ADM ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
				--T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN 
				--	#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
				--			T0200_MONTHLY_SALARY MS ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID INNER JOIN 
				--			T0095_INCREMENT I_Q ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	inner join
				--			T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
				--			T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
				--			T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
				--			T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
				--			T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID left outer JOIN 
				--			#Gen G on G.Branch_Id= I_Q.Branch_ID Inner JOIN   --Jaina 21-10-2015
				--			T0010_COMPANY_MASTER CM ON MAD.CMP_ID = CM.CMP_ID  Left Outer Join
				--			#Emp_Settlement ES on MAD.Emp_ID = ES.Emp_ID And MAD.For_Date = ES.For_Date	Left Outer Join
				--			(Select isnull(SUM(M_AREAR_AMOUNT),0)+ isnull(SUM(M_AREAR_AMOUNT_cutoff),0) as Arear_Calc_Amount,Emp_ID	--Ankit 13012014
				--				From T0210_MONTHLY_AD_DETAIL 
				--				Where AD_ID in (
				--					Select AD_ID from T0060_EFFECT_AD_MASTER 
				--					where CMP_ID=@Cmp_ID and EFFECT_AD_ID = (
				--						select top 1 AD_ID From T0050_AD_MASTER where CMP_ID=@Cmp_ID 
				--						and AD_DEF_ID=@AD_Def_ID))
				--				and ( M_AREAR_AMOUNT >0 or M_AREAR_AMOUNT_Cutoff <>0 )
				--				and For_Date >=@From_Date and For_Date <=@To_Date
				--				Group by Emp_ID) Qry on
				--				Ec.Emp_ID = Qry.Emp_ID left join 
				--				T0050_SubBranch SB on I_Q.subBranch_ID =SB.SubBranch_ID Left join
				--			--	T0210_ESIC_ON_NOT_EFFECT_ON_SALARY ESICNT on ESICNT.For_Date=MAD.To_date and ESICNT.Emp_Id=MAD.Emp_ID left join --and ESICNT.Ad_Id=MAD.AD_ID
				--			  (select For_Date,emp_id,sum(Amount) as Amount,sum(ESIC) as ESIC,sum(Net_Amount) as Net_Amount from T0210_ESIC_ON_NOT_EFFECT_ON_SALARY  group by emp_id,For_Date)
				--			  ESICNT on month(ESICNT.For_Date)=month(MAD.To_date) and year(ESICNT.For_Date) = year(MAD.To_date)  and ESICNT.Emp_Id=MAD.Emp_ID left join -- comment and added by rohit on 26042016
				--				T0040_Vertical_Segment VS on VS.Vertical_ID=I_Q.Vertical_ID left join
				--				T0050_SubVertical SV on SV.SubVertical_ID=I_Q.SubVertical_ID
								

				--WHERE E.Cmp_ID = @Cmp_Id and MAD.For_Date >=@From_Date and MAD.For_Date <=@To_Date
				--		and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_NOT_EFFECT_SALARY <>1 And Sal_Type<>1
				--			order by SIN_NO asc
		
		
				
	RETURN 




