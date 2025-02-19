

-------------------------------------------

--ADDED JIMIT 15052017------
--- Increment slabwise Report---

---------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_EMP_Increment_Slabwise]      
     @COMPANY_ID	NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		varchar(Max)	
	,@GRADE_ID 		varchar(Max)
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
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @COMPANY_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRADE_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'',0,0   
	
		IF Object_ID('tempdb..#Increment_SlabWise') is not null
		drop TABLE #Increment_SlabWise

	
	CREATE TABLE #Increment_SlabWise       
		(   
			Emp_Id  NUMERIC,
			cmp_Id	NUMERIC,
			Dept_Id	Numeric,
			EMP_CODE VARCHAR(100) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,       
			Emp_Name   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Branch   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Department   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Designation   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Category   VARCHAR(200) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
			Old_SAlary	NUMERIC(18,2),
			Paid_Days	NUMERIC(18,2),
			Increment_15 NUMERIC(18,2),
			Last_year_Increment_Release NUMERIC(18,0),
			New_Salary  NUMERIC(18,2),
			Minimun_wages_Benifit NUMERIC(18,2),
			final_salary	NUMERIC(18,2),
			New_Basic		NUMERIC(18,2),
			New_HRA			NUMERIC(18,2),
			ConV			NUMERIC(18,2),
			Wages_Caluculate_On NUMERIC(18,2),
			Minimum_wages    	NUMERIC(18,2),
			Aditional_Amount	NUMERIC(18,2),
			Basic_Percentage	Numeric(18,2) Default(0),
			CCA_Percentage		Numeric(18,2) Default(0),
			HRA_Percentage		Numeric(18,2) Default(0)
			
		)		
	
	
	
			INSERT INTO	#Increment_SlabWise(Emp_Id,cmp_Id,Dept_Id,EMP_CODE,Emp_Name,Branch,Department,Designation,Category,
											Old_SAlary,Paid_Days,Increment_15,Last_year_Increment_Release,New_Salary,
											Wages_Caluculate_On,Minimum_wages,Aditional_Amount)						
							
			SELECT		E.Emp_ID,cm.cmp_Id,DPM.Dept_Id,E.Alpha_Emp_Code,E.Emp_Full_Name,BM.Branch_Name,DPM.Dept_Name,DM.Desig_Name,dpm.Category,ISB.Gross_Salary,isb.Working_Days,ISNULL(isb.Increment_Amount,0),0,
						dbo.f_Round_Upper((IsNull(ISB.Gross_Salary,0) + ISNULL(isb.Increment_Amount,0) + ISNULL(ISB.Additional_Increment,0)),10),ISB.Wages_Calculate_On
						,DPM.Minimum_Wages,ISNULL(ISB.Additional_Increment,0)
			FROM		T0080_EMP_MASTER E WITH (NOLOCK)	INNER JOIN
							( SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
								( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
								WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
								AND CMP_ID = @COMPANY_ID
								GROUP BY EMP_ID  ) QRY ON
								I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
							E.EMP_ID = INC_QRY.EMP_ID INNER JOIN
							#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID INNER JOIN
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID INNER JOIN
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON Dpm.Dept_Id = INC_QRY.Dept_ID INNER JOIN
							T0100_Increment_Slabwise ISB WITH (NOLOCK) On Isb.Emp_ID = ec.EMP_ID
			WHERE		isb.From_date >= @from_date and isb.To_date <= @to_date
					
			
				UPDATE  C 
				SET		C.final_salary = (case WHEN Q.Minimum_Wages > C.New_Salary then Q.Minimum_Wages ELSE C.New_Salary end)										
				FROM 	#Increment_SlabWise C INNER JOIN
						(							
							SELECT	DM.Dept_Id,EM.Emp_ID,EM.Cmp_Id,Dm.Minimum_Wages
							FROM	 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) Inner join
									( SELECT I.EMP_ID,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
								( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)  
								WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
								AND CMP_ID = @COMPANY_ID
								GROUP BY EMP_ID  ) QRY ON
								I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON dm.Dept_Id = INC_QRY.Dept_ID	INNER JOIN
							T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = INC_QRY.Emp_ID						
						)Q ON Q.EMP_ID = C.EMP_ID AND Q.CMP_ID = C.CMP_ID and C.Dept_Id = Q.Dept_Id
				WHERE  C.Emp_Id = Q.EMP_ID				
						
				Update Inc
					SET Basic_Percentage = EC.Value
				From #Increment_SlabWise Inc Inner JOIN 
				T0082_EMP_COLUMN EC ON Inc.Emp_Id = EC.Emp_Id
				INNER JOIN  T0081_CUSTOMIZED_COLUMN CC
				ON CC.Tran_Id = EC.mst_Tran_Id
				Where CC.Cmp_Id = @COMPANY_ID AND CC.Column_Name = 'Basic Increment Per' 
						 
						 
				Update Inc
					SET CCA_Percentage = EC.Value
				From #Increment_SlabWise Inc Inner JOIN 
				T0082_EMP_COLUMN EC ON Inc.Emp_Id = EC.Emp_Id
				INNER JOIN  T0081_CUSTOMIZED_COLUMN CC
				ON CC.Tran_Id = EC.mst_Tran_Id
				Where CC.Cmp_Id = @COMPANY_ID AND CC.Column_Name = 'CCA Increment Per'
				
				
				Update Inc
					SET HRA_Percentage = EC.Value
				From #Increment_SlabWise Inc Inner JOIN 
				T0082_EMP_COLUMN EC ON Inc.Emp_Id = EC.Emp_Id
				INNER JOIN  T0081_CUSTOMIZED_COLUMN CC
				ON CC.Tran_Id = EC.mst_Tran_Id
				Where CC.Cmp_Id = @COMPANY_ID AND CC.Column_Name = 'HRA Increment Per'
				
				UPDATE  C 
				SET		C.New_Basic = dbo.f_Round_Upper(((IsNULl(C.final_salary,0) * 60) / 100),10),
						C.New_HRA = dbo.f_Round_Upper(((IsNULl(C.final_salary,0) * 30) / 100),10),
						--C.ConV = round(((IsNULl(C.final_salary,0) * 10) / 100),0),
						C.Minimun_wages_Benifit = (ISNULL(C.final_salary,0) - ISNULL(C.New_Salary,0))
				FROM 	#Increment_SlabWise C INNER JOIN
						(
							SELECT Emp_Id from #EMP_CONS													
						)Q ON Q.EMP_ID = C.EMP_ID 
				WHERE  C.Emp_Id = Q.EMP_ID AND Basic_Percentage = 0
				
				UPDATE  C 
				SET		C.New_Basic = dbo.f_Round_Upper(((IsNULl(C.final_salary,0) * C.Basic_Percentage) / 100),10),
						C.New_HRA =  case when HRA_Percentage <> 0 then dbo.f_Round_Upper(((IsNULl(C.final_salary,0) * HRA_Percentage) / 100),10) ELSE 0 END,
						--C.ConV = round(((IsNULl(C.final_salary,0) * C.CCA_Percentage) / 100),0),
						C.Minimun_wages_Benifit = (ISNULL(C.final_salary,0) - ISNULL(C.New_Salary,0))
				FROM 	#Increment_SlabWise C INNER JOIN
						(
							SELECT Emp_Id from #EMP_CONS													
						)Q ON Q.EMP_ID = C.EMP_ID 
				WHERE  C.Emp_Id = Q.EMP_ID AND Basic_Percentage <> 0
				
				UPDATE  C 
				SET		C.ConV = C.final_salary - (C.New_Basic + C.New_HRA)
				FROM 	#Increment_SlabWise C INNER JOIN
						(
							SELECT Emp_Id from #EMP_CONS														
						)Q ON Q.EMP_ID = C.EMP_ID 
				WHERE  C.Emp_Id = Q.EMP_ID
	
	
				SELECT ROW_NUMBER() OVER(ORDER BY  T.Emp_Id  ASC) AS SR_NO,* 
				Into #Increment_SlabWise2
				FROM #Increment_SlabWise T
				ORDER BY
				Case When IsNumeric(Replace(Replace(T.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(T.Emp_Code,'="',''),'"',''), 20)
					 When IsNumeric(Replace(Replace(T.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(T.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
					 Else Replace(Replace(T.Emp_Code,'="',''),'"','') End 
				
			
				
				SELECT		Isb.*,GM.Grd_Name,Type_Name,vS.Vertical_Name,Sv.SubVertical_Name	
							,@From_DAte as From_Date,@To_Date as To_DAte
							,Cm.Cmp_Name,Cm.Cmp_Address,BM.Comp_Name,BM.Branch_Address	
				FROM		#Increment_SlabWise2 Isb Inner join
							#EMP_CONS Ec On Ec.EMP_ID = Isb.Emp_Id INNER JOIN	
							T0095_INCREMENT Ic WITH (NOLOCK) On Ic.Increment_ID = Ec.Increment_ID LEFT OUTER JOIN
							T0040_Vertical_Segment vS WITH (NOLOCK) oN VS.Vertical_ID = Ic.Vertical_ID LEFT OUTER JOIN
							T0050_SubVertical Sv  WITH (NOLOCK) On Sv.SubVertical_ID = Ic.SubVertical_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER Tm WITH (NOLOCK) On tm.type_Id = Ic.Type_ID LEFT Outer JOIN
							T0040_GRADE_MASTER GM WITH (NOLOCK) On gm.Grd_ID = Ic.Grd_ID INNER JOIN	
							T0010_COMPANY_MASTER Cm WITH (NOLOCK) On CM.Cmp_Id = Isb.Cmp_Id INNER JOIN	
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = IC.Branch_ID
				--WHERE		Cm.From_Date >= @From_date and Cm.To_Date <= @To_date
				Order by SR_NO
				
				
				--DROP TABLE #CROSSTAB_FORMAT2
				
				
				

