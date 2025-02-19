

-------------------------------------------

--ADDED JIMIT 31052017------
--- Bonus slabwise Report---

---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_Bonus_Slabwise]      
     @CMP_ID	NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		varchar(Max)	
	,@GRD_ID 		varchar(Max)
	,@TYPE_ID 		varchar(Max)
	,@DEPT_ID 		varchar(Max)
	,@DESIG_ID 		varchar(Max)
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@CAT_ID        varchar(Max) = ''
	,@IS_COLUMN		TINYINT = 0
	,@SALARY_CYCLE_ID  NUMERIC  = 0
	,@SEGMENT_ID	varchar(Max) = '' 
	,@Vertical_ID		varchar(Max) = '' 
	,@SubVertical_Id	varchar(Max) = '' 
	,@SubBranch_Id		varchar(Max) = ''
	,@Bank_Id		Numeric(18,0) = 0  --Added By Jimit 18062018 
	
    
    
AS      
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	CREATE TABLE #EMP_CONS 
		(      
			EMP_ID NUMERIC ,     
			BRANCH_ID NUMERIC,
			INCREMENT_ID NUMERIC
		)	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'',0,0   
	
		IF Object_ID('tempdb..#Bonus_SlabWise') is not null
		drop TABLE #Bonus_SlabWise

	
	CREATE TABLE #Bonus_SlabWise       
		(   
			Emp_Id  NUMERIC,
			cmp_Id	NUMERIC,
			Dept_Id	Numeric,
			EMP_CODE VARCHAR(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Emp_Name   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Branch   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Department   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,			
			DOJ			 VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,			
			Paid_Days	NUMERIC(18,2),
			Actual_Basic_Salary	NUMERIC(18,2),
			Basic_Salary_As_Per_Bonus_Ceiling_Limit NUMERIC(18,2),
			Eligible_Bonus_Salary NUMERIC(18,2),
			Payable_Bonus 	NUMERIC(18,2),
			Bonus_Paid_On_Diwali 	NUMERIC(18,2),
			Paid_On_31032017 NUMERIC(18,2),
			Excess NUMERIC(18,2)
		)    
	
			DECLARE @Bonus_Max_Limit as NUMERIC(18,0)
			DECLARE @Total_Days as NUMERIC
			
			DECLARE @FromDate as Datetime
			select @FromDate =  dbo.GET_YEAR_START_DATE(year(@To_Date),month(@To_Date),0)
  
			Set @Total_Days = DATEDIFF(day,@FromDate,@To_Date) + 1
			
			Select	@Bonus_Max_Limit = Max_Bonus_Salary_Amount from T0040_GENERAL_SETTING WITH (NOLOCK)
			Where Cmp_ID = @CMP_ID and For_Date = (select Max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @CMP_ID and For_Date<= @To_date)
			
		
			
			INSERT INTO	#Bonus_SlabWise(Emp_Id,cmp_Id,Dept_Id,EMP_CODE,Emp_Name,Branch,Department,DOJ,Paid_Days,Actual_Basic_Salary,
										Basic_Salary_As_Per_Bonus_Ceiling_Limit,Eligible_Bonus_Salary,Payable_Bonus,Bonus_Paid_On_Diwali,
										Paid_On_31032017,Excess)						
							
			SELECT		E.Emp_ID,cm.cmp_Id,DPM.Dept_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,BM.Branch_Name,DPM.Dept_Name,
						Convert(Varchar(15),E.Date_Of_Join,103),B_Q.PRESENT_DAYS
						,INC_QRY.Basic_Salary,(Case When INC_QRY.Basic_Salary > @Bonus_Max_Limit 
												    then INC_QRY.Basic_Salary else @Bonus_Max_Limit end),
						--((IsNULL(@Bonus_Max_Limit,0) / @Total_Days) * IsNull(B_Q.PRESENT_DAYS,0) * 12),
						Bs.Bonus_Calculated_Amount,
						Bs.Bonus_Amount,0,0,0
						--,B.Bonus_Amount,Bs.Total_Bonus_Amount,(Case When Bs.Total_Bonus_Amount > B.Bonus_Amount then 0 ELSE (B.Bonus_Amount - Bs.Total_Bonus_Amount) end),
						--(Case When Bs.Total_Bonus_Amount > B.Bonus_Amount then (Bs.Total_Bonus_Amount - B.Bonus_Amount) ELSE 0 end)
						
			FROM		T0080_EMP_MASTER E WITH (NOLOCK)	INNER JOIN
							( SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,
									 I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
								( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
								WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
								AND CMP_ID = @CMP_ID
								GROUP BY EMP_ID  ) QRY ON
								I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
							E.EMP_ID = INC_QRY.EMP_ID INNER JOIN
							#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID INNER JOIN
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID INNER JOIN
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON Dpm.Dept_Id = INC_QRY.Dept_ID INNER JOIN
							--T0100_Bonus_Slabwise Bs On Bs.Emp_ID = ec.EMP_ID LEFT join 
							t0180_bonus Bs WITH (NOLOCK) on Ec.Emp_ID = Bs.Emp_Id LEFT join
								(SELECT SUM(ISNULL(SAL_CAL_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID 
										,SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year
								FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK) Left Outer join
										T0180_BONUS BN WITH (NOLOCK) on MS.Emp_ID = BN.Emp_ID
										and Bn.From_Date >= @From_date and Bn.To_Date <= @to_date 
								WHERE	MONTH_ST_DATE >= BN.From_Date AND MONTH_END_DATE <= BN.To_Date GROUP BY MS.Emp_ID)B_Q
							ON INC_QRY.EMP_ID = B_Q.EMP_ID
			WHERE			Bs.From_date between @from_date and @to_date
							and  Bs.Bonus_Amount <> 0
			
			UNION ALL
			
			SELECT		E.Emp_ID,cm.cmp_Id,DPM.Dept_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,BM.Branch_Name,DPM.Dept_Name,
						Convert(Varchar(15),E.Date_Of_Join,103),B_Q.PRESENT_DAYS
						,INC_QRY.Basic_Salary,(Case When INC_QRY.Basic_Salary > @Bonus_Max_Limit 
												    then INC_QRY.Basic_Salary else @Bonus_Max_Limit end),						
						0 as Bonus_Calculated_Amount,B_Q.Bonus_Amount,0,0,0					
						
			FROM		T0080_EMP_MASTER E 	WITH (NOLOCK) INNER JOIN
							( SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,
									 I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
								( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
								WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
								AND CMP_ID = @CMP_ID
								GROUP BY EMP_ID  ) QRY ON
								I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
							E.EMP_ID = INC_QRY.EMP_ID INNER JOIN
							#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID INNER JOIN
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID INNER JOIN
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON Dpm.Dept_Id = INC_QRY.Dept_ID LEFT join
							(
									SELECT  SUM(ISNULL(SAL_CAL_DAYS,0))AS PRESENT_DAYS,MS.Emp_ID,
											SUM(ISNULL(SAL_CAL_DAYS,0)-(ISNULL(HOLIDAY_DAYS,0) + ISNULL(Weekoff_Days,0))) as Day_Year,
											SUM(ISNULL(MS.Bonus_Amount,0)) AS Bonus_Amount
									FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
									WHERE	MONTH_ST_DATE >= @From_Date AND MONTH_END_DATE <= @To_date
									GROUP BY MS.Emp_ID
							)B_Q	ON INC_QRY.EMP_ID = B_Q.EMP_ID
				where 		B_Q.Bonus_Amount <> 0 and E.Emp_Left = 'Y'
			
			
			
			UPDATE  C 
			SET		C.Bonus_Paid_On_Diwali = (Case When C.Bonus_Paid_On_Diwali > IsNULL(Q.Bonus_Amount,C.Payable_Bonus) then 0 													 
													--ELSE (IsNULL(Q.Bonus_Amount,C.Payable_Bonus)) end)
													ELSE (IsNULL(Q.Bonus_Amount,0)) end)
					--C.Paid_On_31032017 = (Case When C.Bonus_Paid_On_Diwali > IsNULL(Q.Bonus_Amount,C.Payable_Bonus) then 0 ELSE (IsNULL(Q.Bonus_Amount,C.Payable_Bonus) - ISNULL(C.Bonus_Paid_On_Diwali,0)) end),
					--C.Excess = 	(Case When C.Bonus_Paid_On_Diwali > IsNULL(Q.Bonus_Amount,C.Payable_Bonus) then (C.Bonus_Paid_On_Diwali - ISNULL(IsNULL(Q.Bonus_Amount,C.Payable_Bonus),0)) ELSE 0 end)									
			FROM 	#Bonus_SlabWise C LEFT JOIN
					(							
						SELECT	Emp_Id,Bonus_Amount
						FROM	T0100_Bonus_Slabwise WITH (NOLOCK) 	
						Where	(From_date between @from_date and @TO_DATE or To_date between @from_date and @TO_DATE)
					)Q ON Q.EMP_ID = C.EMP_ID
			WHERE   C.Eligible_Bonus_Salary <> 0		
				
			UPDATE  C
			SET		--C.Payable_Bonus = IsNull(Q.Bonus_Amount,0),
					--C.Paid_On_31032017 = (Case When C.Bonus_Paid_On_Diwali > IsNULL(Q.Bonus_Amount,C.Payable_Bonus) then 0 ELSE (IsNULL(Q.Bonus_Amount,C.Payable_Bonus) - ISNULL(C.Bonus_Paid_On_Diwali,0)) end),
					--C.Excess = 	(Case When C.Bonus_Paid_On_Diwali > IsNULL(Q.Bonus_Amount,C.Payable_Bonus) then (C.Bonus_Paid_On_Diwali - ISNULL(IsNULL(Q.Bonus_Amount,C.Payable_Bonus),0)) ELSE 0 end)									
					--C.Bonus_Paid_On_Diwali = (Case When C.Bonus_Paid_On_Diwali > IsNULL(Q.Bonus_Amount,C.Payable_Bonus) then 0 ELSE (IsNULL(Q.Bonus_Amount,C.Payable_Bonus)) end),
					C.Paid_On_31032017 = (Case When C.Bonus_Paid_On_Diwali > IsNULL(C.Payable_Bonus,0) then 0 ELSE (IsNULL(C.Payable_Bonus,0) - ISNULL(C.Bonus_Paid_On_Diwali,0)) end)
					                       --IsNULL(C.Payable_Bonus,0) - ISNULL(C.Bonus_Paid_On_Diwali,0)
					,C.Excess = 	(Case When C.Bonus_Paid_On_Diwali > IsNULL(C.Payable_Bonus,0) then (C.Bonus_Paid_On_Diwali - ISNULL(C.Payable_Bonus,0)) ELSE 0 end)									
			FROM 	#Bonus_SlabWise C LEFT JOIN
					(							
						SELECT	Emp_Id,Bonus_Amount
						FROM	T0100_Bonus_Slabwise WITH (NOLOCK)	
						Where	(From_date between @from_date and @TO_DATE or To_date between @from_date and @TO_DATE)
					)Q ON Q.EMP_ID = C.EMP_ID 
			WHERE   C.Eligible_Bonus_Salary <> 0		
			--WHERE  C.Emp_Id = Q.EMP_ID				
					
		
				
				SELECT ROW_NUMBER() OVER(ORDER BY  T.Emp_Code  ASC) AS SR_NO,* 
				Into #Bonus_SlabWise2
				FROM #Bonus_SlabWise T
				ORDER BY
				Case When IsNumeric(Replace(Replace(T.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(T.Emp_Code,'="',''),'"',''), 20)
					 When IsNumeric(Replace(Replace(T.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(T.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
					 Else Replace(Replace(T.Emp_Code,'="',''),'"','') End 
				
			 
			 
				SELECT		Isb.*,GM.Grd_Name,Type_Name,vS.Vertical_Name,Sv.SubVertical_Name	
							,@From_DAte as From_Date,@To_Date as To_DAte
							,Cm.Cmp_Name,Cm.Cmp_Address,BM.Comp_Name,BM.Branch_Address
							,Cm.cmp_logo,DM.Desig_Name	
				FROM		#Bonus_SlabWise2 Isb Inner join
							#EMP_CONS Ec On Ec.EMP_ID = Isb.Emp_Id INNER JOIN	
							T0095_INCREMENT Ic WITH (NOLOCK) On Ic.Increment_ID = Ec.Increment_ID LEFT OUTER JOIN
							T0040_Vertical_Segment vS WITH (NOLOCK) oN VS.Vertical_ID = Ic.Vertical_ID LEFT OUTER JOIN
							T0050_SubVertical Sv WITH (NOLOCK) On Sv.SubVertical_ID = Ic.SubVertical_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER Tm WITH (NOLOCK) On tm.type_Id = Ic.Type_ID LEFT Outer JOIN
							T0040_GRADE_MASTER GM WITH (NOLOCK) On gm.Grd_ID = Ic.Grd_ID INNER JOIN	
							T0010_COMPANY_MASTER Cm WITH (NOLOCK) On CM.Cmp_Id = Isb.Cmp_Id INNER JOIN	
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = IC.Branch_ID  LEFT JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = Ic.DESIG_ID
				--WHERE		Cm.From_Date >= @From_date and Cm.To_Date <= @To_date
				Order by SR_NO
				
				
				--DROP TABLE #CROSSTAB_FORMAT2
				
				
				

