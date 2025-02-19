
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Set_Salary_Register_Amount_Settlement]
 @Cmp_ID		numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   = 0
,@Cat_ID		numeric  = 0
,@Grd_ID		numeric = 0
,@Type_ID		numeric  = 0
,@Dept_ID		numeric  = 0
,@Desig_ID		numeric = 0
,@Emp_ID		numeric  = 0
,@Constraint	varchar(max) = ''
,@Sal_Type    numeric
,@Salary_Cycle_id numeric = 0
 ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
 ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
 ,@flag numeric = 0	--Mukti(25062016)if flag=1 than only publish settlement records shown for ess side else show all
 ,@Type Numeric = 0 --Added By Jimit 11052018

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric
	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
		
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)
	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	Declare @S_Eff_Date datetime
	DEclare @For_Date as datetime
	Declare @TDS numeric(18,2)
	Declare @Gross_salary as numeric(18,2)
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
		
	CREATE table #Temp_Salary_Muster_Report		
	(
	Emp_ID numeric(18, 0) Not Null,
	Cmp_ID numeric(18, 0) Not Null,
	Transaction_ID numeric(18, 0) Not Null default (0),
	Month numeric(18, 0) Not Null,
	Year numeric(18, 0) Not Null,
	Label_Name varchar(200) Not Null,
	Amount numeric(18, 2) null,
	Value_String varchar(250) Not Null default (''),
	INCOME_TAX_ID numeric(18, 0)  Null,
	Row_id numeric(18, 0) Null,
	S_Eff_Month numeric(18, 0)  Null,
	S_Eff_Year numeric(18, 0) Null
	)
		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
		
	
	set @month = month(@to_Date)
	set @Year = Year(@to_Date)
	  
	EXEC Set_Salary_register_Lable_Settlement @Cmp_ID ,@month , @Year
	
	CREATE TABLE #Emp_Cons -- Ankit 05092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

	
	
	DECLARE @S_Sal_Tran_ID NUMERIC	--Ankit 18022016
	SET @S_Sal_Tran_ID = 0	
	
					--commented By Mukti(25062016)start		
		--DECLARE CUR_EMP CURSOR FOR			
		--	SELECT sg.EMP_ID,sg.S_Month_End_Date,SG.S_Sal_Tran_ID  FROM T0201_MONTHLY_SALARY_SETT SG INNER JOIN
		--		T0080_EMP_MASTER E ON sg.EMP_ID =e.EMP_ID 
		--		INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID  
		--		--Inner join ( select T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment inner join 
		--		--								( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment
		--		--								where Increment_Effective_date <= @To_Date
		--		--								and Cmp_ID = @Cmp_ID
		--		--								group by emp_ID  ) Qry
		--		--								on t0095_Increment.Emp_ID = Qry.Emp_ID and
		--		--								t0095_Increment.Increment_ID   = Qry.Increment_ID	
		--		--						where Cmp_ID = @Cmp_ID ) I_Q on 
		--		--				e.Emp_ID = I_Q.Emp_ID
		--	WHERE  sg.Cmp_ID = @Cmp_ID AND Month(sg.S_Eff_Date) = @MONTH AND Year(sg.S_Eff_Date) = @YEAR 
			--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	--commented By Mukti(25062016)end	
	
	--Added By Mukti(25062016)start	



					INSERT INTO #Temp_Salary_Muster_Report
						(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,S_Eff_Month,S_Eff_Year)
					
					Select SG.Emp_ID, SG.Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', isnull(S_Sal_cal_Days,0),'',2,Month(S_Month_End_Date),Year(S_Month_End_Date)
					FROM T0201_MONTHLY_SALARY_SETT SG WITH (NOLOCK)
						INNER JOIN #Emp_Cons ec on SG.Emp_ID = Ec.Emp_ID  					
					WHERE  sg.Cmp_ID = @Cmp_ID AND Month(sg.S_Eff_Date) = @MONTH AND Year(sg.S_Eff_Date) = @YEAR 
						--And (S_Gross_Salary <> 0 or S_Total_Dedu_Amount <>0 ) 						
					Union All
					Select SG.Emp_ID, SG.Cmp_ID, @Transaction_ID, @Month, @Year, 'Basic', isnull(S_Salary_Amount,0),'',5,Month(S_Month_End_Date),Year(S_Month_End_Date)
					FROM T0201_MONTHLY_SALARY_SETT SG WITH (NOLOCK) 
						INNER JOIN #Emp_Cons ec on SG.Emp_ID = Ec.Emp_ID  					
					WHERE  sg.Cmp_ID = @Cmp_ID AND Month(sg.S_Eff_Date) = @MONTH AND Year(sg.S_Eff_Date) = @YEAR 
						--And (S_Gross_Salary <> 0 or S_Total_Dedu_Amount <>0 )
					Union All
					Select EC.Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, Label_Name, 0,'',Row_ID,Month(S_Month_End_Date),Year(S_Month_End_Date) 
					From #TEMP_REPORT_LABEL TRL Cross Join #Emp_Cons EC 
					Inner Join T0201_MONTHLY_SALARY_SETT SG WITH (NOLOCK) On EC.Emp_ID=SG.Emp_ID
					Where Row_ID > 5 And sg.Cmp_ID = @Cmp_ID AND Month(sg.S_Eff_Date) = @MONTH AND Year(sg.S_Eff_Date) = @YEAR
						--And (S_Gross_Salary <> 0 or S_Total_Dedu_Amount <>0 )	
									
					UPDATE	TMR
					SET	Amount = IsNULL(MAD.M_AD_Amount,0)
					FROM T0210_MONTHLY_AD_DETAIL MAD inner join
						T0201_MONTHLY_SALARY_SETT MSS ON MAD.Sal_Tran_ID=MSS.Sal_Tran_ID and MAD.S_Sal_Tran_ID = MSS.S_Sal_Tran_ID INNER JOIN
						T0050_AD_MASTER AD ON MAD.Ad_Id = AD.Ad_ID  INNER JOIN
						#Temp_Salary_Muster_Report TMR ON MAD.Emp_ID = TMR.Emp_ID And Label_Name = Ad_Sort_Name 
						and TMR.S_Eff_Month = Month(MAD.To_date) and TMR.S_Eff_Year=Year(MAD.To_date)
					WHERE AD_Active = 1  And sal_type=1 and Month(MSS.S_Eff_Date) = @MONTH and Year(MSS.S_Eff_Date) = @YEAR

				--SELECT @Other_Allow = S_Other_Allow_Amount, @P_Days = isnull(S_Sal_cal_Days,0),
				--		@Gross_salary = S_Gross_Salary, @Total_Deduction = S_Total_Dedu_Amount, @PT = S_PT_Amount, @Loan = S_Loan_Amount + S_Loan_Intrest_Amount, 
				--		@Advance = S_Advance_Amount, @Net_Salary = S_Net_Amount, @Revenue_Amt = S_Revenue_amount, @LWF_Amt = S_LWF_Amount
				--	FROM T0201_MONTHLY_SALARY_SETT SG 
				--		INNER JOIN T0080_EMP_MASTER E ON sg.EMP_ID =e.EMP_ID 
				--		INNER JOIN #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID  					
				--WHERE  sg.Cmp_ID = @Cmp_ID AND Month(sg.S_Eff_Date) = @MONTH AND Year(sg.S_Eff_Date) = @YEAR 
				--And (S_Gross_Salary <> 0 or S_Total_Dedu_Amount <>0 )
				
				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_Other_Allow_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'Oth A' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = Isnull(SG.S_OT_Amount,0) + Isnull(SG.S_WO_OT_Amount,0) + ISNULL(SG.S_HO_OT_Amount,0)
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'OT AMT' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR


				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_Gross_Salary
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'Gross' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_PT_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'PT' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = Isnull(S_Loan_Amount,0) + Isnull(S_Loan_Intrest_Amount,0) + Isnull(S_Advance_Amount,0)
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'LN/AD' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_Revenue_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'Revenue' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_LWF_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'LWF' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR
						
						
				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_M_IT_TAX
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'TDS' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR
						

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_Other_Dedu_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'Oth De' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR
						

				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_Total_Dedu_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'Deduction' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR
				
				UPDATE #Temp_Salary_Muster_Report
				SET Amount = S_Net_Amount
				FROM T0201_MONTHLY_SALARY_SETT SG   Inner Join
					#Temp_Salary_Muster_Report TMR ON SG.Emp_ID = TMR.Emp_ID  And Month(SG.S_Month_End_Date) = TMR.S_Eff_Month And Year(SG.S_Month_End_Date) = TMR.S_Eff_Year
				WHERE   Label_Name = 'Net_Salary' and Month(SG.S_Eff_Date) = @MONTH and Year(SG.S_Eff_Date) = @YEAR										
					

		
				IF @Type = 0
				  BEGIN  
						update #Temp_Salary_Muster_Report set Label_Name = REPLACE(Label_Name,'_',' ')
						
						select #Temp_Salary_Muster_Report.* ,
						--Alpha_Emp_Code + ' - ' + Emp_Full_Name as Emp_Full_Name
						ISNULL(Alpha_Emp_Code + ' - ' + EmpName_Alias_Salary,Alpha_Emp_Code + ' - ' + Emp_Full_Name) as Emp_Full_Name
						, Emp_code, E.Dept_ID,Cmp_Name,Cmp_Address, BM.Branch_ID from #Temp_Salary_Muster_Report Inner join
						T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
						( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID, Branch_ID from t0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)	-- Ankit 05092014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
						E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
						on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  left outer join T0030_BRANCH_MASTER BM WITH (NOLOCK)
						on Inc_Qry.Branch_ID= BM.Branch_ID inner join 
						t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
						--where amount > 0 and S_Eff_Month=5
						order by Row_ID,S_eff_month
						--#Temp_Salary_Muster_Report.Emp_ID ,Row_ID
				
				END
				ELSE If @Type = 1     --ADDED BY JIMIT 11052018
					BEGIN
							DECLARE @SQL VARCHAR(MAX)
							DECLARE @COLS VARCHAR(MAX)
							DECLARE @SQL1 VARCHAR(MAX)
							
							DECLARE @COUNT_SETTLEMENT_COUNT NUMERIC
							
							DECLARE @GRAND_TOTAL_ROW VARCHAR(MAX)
							
							
							
							DELETE T FROM #Temp_Salary_Muster_Report T
							  INNER JOIN (SELECT Row_ID,S_Eff_Month,S_Eff_Year 
										  FROM	#Temp_Salary_Muster_Report T1 
										  Group By Row_ID,S_Eff_Month,S_Eff_Year 
										  Having Sum(AMOUNT) = 0
										  ) T1 ON T.ROW_ID=T1.ROW_ID AND T.S_Eff_Month=T1.S_Eff_Month AND T.S_Eff_Year=T1.S_Eff_Year
							
							
																
							Insert INTO #Temp_Salary_Muster_Report(Emp_Id,Cmp_Id,month,Year,Label_Name,amount,Row_id,S_Eff_Month,S_Eff_Year)				
							select		Emp_ID,@Cmp_ID,Month,Year,Label_Name,
										SUM(ISNULL(Amount,0)),Row_id,99,9999
							from		#Temp_Salary_Muster_Report	
							Group By    Label_Name,Row_id,Emp_ID,Month,Year
							
							Insert INTO #Temp_Salary_Muster_Report(Emp_Id,Cmp_Id,month,Year,Label_Name,amount,Row_id,S_Eff_Month,S_Eff_Year)				
							select		9999,@Cmp_ID,Month,Year,Label_Name,
										SUM(ISNULL(Amount,0)),Row_id,S_Eff_Month,S_Eff_Year
							from		#Temp_Salary_Muster_Report	
							Group By    Label_Name,Row_id,S_Eff_Month,S_Eff_Year,Month,Year
																			

							SELECT		@COUNT_SETTLEMENT_COUNT = COUNT(1) 
							FROM		#Temp_Salary_Muster_Report
							GROUP BY	S_EFF_MONTH,S_EFF_YEAR

							SELECT	 @COLS = COALESCE(@COLS + ',','')  + '[' + Label_Name + '\' + convert(VARCHAR(9),EffDate,112)  + ']' 
							FROM	(
										SELECT	Row_Number() Over(PARTITION By Emp_ID ORDER BY S_Eff_Year,S_eff_month,Row_Id) as Row_Id,Label_Name,case when S_Eff_Month <> 99 then LEFT(DATENAME(MONTH, dbo.GET_MONTH_ST_DATE(S_Eff_Month,S_Eff_Year)),3) + '-' + CAST(YEAR(dbo.GET_MONTH_ST_DATE(S_Eff_Month,S_Eff_Year)) AS VARCHAR(4))  else 'Total'  end As EffDate --,Row_id
										FROM	#Temp_Salary_Muster_Report											
									) PL
							GROUP BY Label_Name,EffDate
							ORDER BY MAX(ROW_ID)	
							
							------select * from #Temp_Salary_Muster_Report
						
							DECLARE @ALTER_COLS VARCHAR(MAX)
							DECLARE @SUM_COLS VARCHAR(MAX)
							
							
							SELECT	@ALTER_COLS = ISNULL(@ALTER_COLS + ';', '') + 'ALTER TABLE #Salary_settelement ADD ' + data + ' numeric(18,2)',
									@SUM_COLS = IsNull(@SUM_COLS + ',','') + 'Sum(IsNull(' + Data + ',0)) As ' + Data
							FROM	dbo.Split(@COLS, ',') T
							
							
							CREATE TABLE #Salary_settelement
							(
								Emp_ID			Numeric,
								Alpha_Emp_Code  Varchar(64),
								Emp_Full_Name	Varchar(128)					
							)
							exec(@ALTER_COLS);
							
							

							SET @SQL = 'INSERT INTO #Salary_settelement
										SELECT	* 
										FROM	 
											(								
												SELECT	distinct T.EMP_ID,Alpha_Emp_Code,Emp_Full_Name,
												(Label_Name + ''\'' + case when S_Eff_Month <> 99 then LEFT(DATENAME(MONTH, dbo.GET_MONTH_ST_DATE(S_Eff_Month,S_Eff_Year)),3) + ''-'' + CAST(YEAR(dbo.GET_MONTH_ST_DATE(S_Eff_Month,S_Eff_Year)) AS VARCHAR(4))  else ''Total'' end) as Label_Name
												,ISNULL(Amount,0) Amount										
												FROM	#Temp_Salary_Muster_Report T Left Outer Join
														T0080_Emp_Master E WITH (NOLOCK) on T.Emp_Id = E.Emp_ID	
																																
											) YS 
											PIVOT 
											(
												Sum(Amount) FOR Label_Name IN (' + @COLS + ')
											) PVT
											
											'
							
							
														
							EXEC (@SQL)									
							SELECT * FROM #SALARY_SETTELEMENT  
							
							
							
					END
	
	RETURN




