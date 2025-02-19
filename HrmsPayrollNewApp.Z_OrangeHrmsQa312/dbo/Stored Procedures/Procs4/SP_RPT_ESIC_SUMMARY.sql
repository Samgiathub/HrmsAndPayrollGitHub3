



-- =============================================
-- Author:		<chetan 10102017 for ESIC summary >
-- Create date: 10/10/2017
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_ESIC_SUMMARY]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		VARCHAR(MAX)
	,@Cat_ID		VARCHAR(MAX)
	,@Grd_ID		VARCHAR(MAX)
	,@Type_ID		VARCHAR(MAX)
	,@Dept_ID		VARCHAR(MAX) 
	,@Desig_ID		VARCHAR(MAX) 
	,@Emp_ID		NUMERIC			= 0
	,@Constraint	VARCHAR(MAX)	= ''
	,@Report_Type	VARCHAR(50)		= ''
	,@Order_By		varchar(30) = 'Code' 

AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
		IF @Branch_ID = ''            
		  SET @Branch_ID = Null          
		      
		IF @Cat_ID = ''           
		  SET @Cat_ID = null          
		       
		IF @Grd_ID = ''            
		  SET @Grd_ID = null          
		       
		IF @Type_ID = ''           
		  SET @Type_ID = null          
		       
		IF @Dept_ID = ''           
		  SET @Dept_ID = null          
		       
		IF @Desig_ID = ''            
		  SET @Desig_ID = null          
		       
		IF @Emp_ID = 0            
		  SET @Emp_ID = null          
		
		CREATE table #Emp_Settlement
	(
		Emp_ID	numeric,
		For_Date Datetime,
		M_AD_Calculate_Amount Numeric(18,2),
		M_AD_Percentage Numeric(18,2),
		M_AD_Amount Numeric(18,2)
	)
		  
	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )  
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0    
	
	 
		DECLARE @SAL_ST_DATE   DATETIME    
		DECLARE @SAL_END_DATE   DATETIME  
		DECLARE @MANUAL_SALARY_PERIOD AS NUMERIC(18,0) 
  
		IF @BRANCH_ID IS NULL
			BEGIN 
			
				SELECT TOP 1 @SAL_ST_DATE  = SAL_ST_DATE ,@MANUAL_SALARY_PERIOD= ISNULL(MANUAL_SALARY_PERIOD ,0)
				FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID    
				  AND FOR_DATE = ( SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE FOR_DATE <=@FROM_DATE AND CMP_ID = @CMP_ID)    
			END
		ELSE
			BEGIN
				SELECT @SAL_ST_DATE  =SAL_ST_DATE ,@MANUAL_SALARY_PERIOD= ISNULL(MANUAL_SALARY_PERIOD ,0)
				FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND BRANCH_ID = @BRANCH_ID    
				  AND FOR_DATE = ( SELECT MAX(FOR_DATE) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE FOR_DATE <=@FROM_DATE AND BRANCH_ID = @BRANCH_ID AND CMP_ID = @CMP_ID)    
			END  
	       
	 IF ISNULL(@SAL_ST_DATE,'') = ''    
		BEGIN    
		   SET @FROM_DATE  = @FROM_DATE     
		   SET @TO_DATE = @TO_DATE    
		END     
	 ELSE IF DAY(@SAL_ST_DATE) =1 
		BEGIN    
		   SET @FROM_DATE  = @FROM_DATE     
		   SET @TO_DATE = @TO_DATE    
		END     
	 ELSE IF @SAL_ST_DATE <> ''  AND DAY(@SAL_ST_DATE) > 1   
		BEGIN    
			IF @MANUAL_SALARY_PERIOD =0 
				BEGIN
				   SET @SAL_ST_DATE =  CAST(CAST(DAY(@SAL_ST_DATE)AS VARCHAR(5)) + '-' + CAST(DATENAME(MM,DATEADD(M,-1,@FROM_DATE)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(M,-1,@FROM_DATE) )AS VARCHAR(10)) AS SMALLDATETIME)    
				   SET @SAL_END_DATE = DATEADD(D,-1,DATEADD(M,1,@SAL_ST_DATE))
				   SET @FROM_DATE = @SAL_ST_DATE
				   SET @TO_DATE = @SAL_END_DATE  
				 END
			ELSE
				BEGIN
					SELECT @SAL_ST_DATE=FROM_DATE,@SAL_END_DATE=END_DATE FROM SALARY_PERIOD WHERE MONTH= MONTH(@FROM_DATE) AND YEAR=YEAR(@FROM_DATE)							   
						SET @FROM_DATE = @SAL_ST_DATE
						SET @TO_DATE = @SAL_END_DATE    
				END	   
		END 
	
	IF @Report_Type = 'ESIC Summary'
		BEGIN
		DECLARE @AD_Def_ID NUMERIC 
		SET @AD_Def_ID = 3
		SELECT	G.Branch_ID, G.Sal_st_Date, DATEADD(m, 1, G.Sal_st_Date) As Sal_End_Date,G.ESIC_EMPLOYER_CONTRIBUTION
			INTO	#GEN
			FROM	(
						SELECT	G1.Branch_ID,G1.ESIC_Employer_Contribution,
							(CASE WHEN DAY(Sal_st_Date) > 1 THEN DATEADD(M,-1, DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date)) ELSE DATEADD(D, DAY(Sal_st_Date)-DAY(@From_Date), @From_Date) END ) AS Sal_st_Date	
						FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
								INNER JOIN (SELECT DISTINCT BRANCH_ID FROM #Emp_Cons E)  T ON T.Branch_ID=G1.Branch_ID --Changed by Ramiz on 24/04/2017 as from Admin Side Arrears was not Calculating 
						WHERE	For_Date = (
												SELECT Max(For_Date) FROM T0040_GENERAL_SETTING G2 WITH (NOLOCK)
												WHERE For_Date < @To_Date and G1.Branch_id=G2.Branch_ID AND G1.Cmp_ID=G2.Cmp_ID
											) AND G1.Cmp_ID=@Cmp_ID
			) G		
		--end
		
		IF EXISTS(SELECT S_Sal_Tran_Id FROM dbo.T0201_MONTHLY_SALARY_SETT AS s WITH (NOLOCK)
									 INNER JOIN T0095_INCREMENT AS i WITH (NOLOCK) ON i.Increment_ID=s.Increment_ID
									 INNER JOIN #Gen as G ON G.Branch_Id=i.Branch_ID
									  WHERE S_Eff_Date BETWEEN G.Sal_st_Date AND G.Sal_End_Date AND S.Cmp_Id=@Cmp_Id)
			BEGIN 

						INSERT INTO #Emp_Settlement
						SELECT  SG.EMP_ID, @From_Date as For_Date, sum(M_AD_Calculated_Amount),ESIC_PER, sum(ESIC_Amount)
							FROM T0201_MONTHLY_SALARY_SETT  SG WITH (NOLOCK) INNER JOIN 
							( Select For_Date, Emp_ID, M_AD_Percentage as ESIC_PER, (M_AD_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_cutoff,0)) as ESIC_Amount, 
									M_AD_Calculated_Amount,
									SAL_TRAN_ID 
								From 
								T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
								WHERE AD_DEF_ID = @AD_Def_ID And ad_not_effect_salary <> 1 AND ad.sal_type=1
								AND AD.CMP_ID = @CMP_ID) MAD ON SG.Emp_ID = MAD.Emp_ID 
								AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
								T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID INNER JOIN
							#Emp_Cons E_S ON E.Emp_ID = E_S.Emp_ID	
					WHERE   e.CMP_ID = @CMP_ID 
							And S_Eff_Date Between @From_Date And @To_Date
					GROUP BY SG.EMP_ID,ESIC_PER
			End	
			
			CREATE TABLE #ESIC_SUMMARY
			(
				[STATE]				 VARCHAR(200)DEFAULT  '',
				BRANCH_NAME			 VARCHAR(200)DEFAULT  '',
				NO_OF_EMP			 INT			DEFAULT  0,
				NO_OF_EMP_FFS		 INT			DEFAULT  0,
				TOTAL_EMPLOYEE		 INT			DEFAULT  0,
				GROSS_SALARY		 NUMERIC(18,2) DEFAULT  0,
				GROSS_SALARY_FFS	 NUMERIC(18,2) DEFAULT 0, 
				TOTAL_GROSS_SALARY   NUMERIC(18,2) DEFAULT 0, 
				ESIC_EMPLOYEE		 NUMERIC(18,2) DEFAULT 0, 
				ESIC_EMPLOYEE_FFS    NUMERIC(18,2) DEFAULT 0,
				TOTAL_EMPLOYEE_PART  NUMERIC(18,2) DEFAULT 0,
				ESIC_EMPLOYER		 NUMERIC(18,2) DEFAULT  0,
				ESIC_EMPLOYER_FFS	 NUMERIC(18,2) DEFAULT  0,
				TOTAL_EMPLOYER_PART	 NUMERIC(18,2) DEFAULT  0,
				TOTAL_CHALLAN_AMOUNT NUMERIC(18,2) DEFAULT  0,	
				IS_FNF				 INT			DEFAULT 0
			);
			
			INSERT INTO #ESIC_SUMMARY(STATE)
			SELECT DISTINCT EM.Present_State FROM T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join
				 T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EM.Emp_ID = Ms.Emp_ID Inner JOIn
				 T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) ON MS.Sal_Tran_ID = MD.sal_Tran_ID Inner JOin
				 T0050_AD_MASTER AM WITH (NOLOCK) ON AM.AD_ID = MD.AD_ID Inner JOIn
				  (SELECT I.Branch_ID,I.Emp_ID,I.Desig_Id FROM T0095_Increment I WITH (NOLOCK) inner join 
								( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)	
								WHERE Increment_Effective_date <= @To_Date
								GROUP BY emp_ID  ) Qry ON
								I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID ) Q_I ON
					 EM.EMP_ID = Q_I.EMP_ID Inner JOIN
				 T0030_branch_master BM WITH (NOLOCK) ON  Q_I.Branch_Id = BM.Branch_ID 
				 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.Desig_ID = Q_I.Desig_Id  
				 LEFT OUTER JOIN #Gen G ON G.Branch_ID = Q_I.Branch_ID 
				 LEFT OUTER JOIN #Emp_Settlement ES ON MD.Emp_ID = ES.Emp_ID AND MD.For_Date = ES.For_Date 
				 LEFT OUTER JOIN T0220_ESIC_Challan EC WITH (NOLOCK) ON EC.MONTH=MONTH(@To_Date) AND EC.YEAR= YEAR(@To_Date)
			WHERE MONTH(MS.MOnth_End_Date ) = MONTH(@To_Date) AND YEAR(MS.MOnth_End_Date ) = YEAR(@To_Date)
			 AND AM.AD_Def_ID = 3  
			 AND MS.Cmp_ID = @Cmp_ID
			AND EM.EMP_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
			 AND MD.Sal_Type<>1 AND MD.M_AD_Amount > 0
			 
			 
			UPDATE ES
			SET BRANCH_NAME = Qry.Branch_Name 
			,NO_OF_EMP = Qry.NO_OF_EMP
			,GROSS_SALARY = Qry.GROSS_SALARY 
			,ESIC_EMPLOYEE = Qry.ESIC_Amount 
			,ESIC_EMPLOYER = Qry.ESIC_EMPLYER 
			,TOTAL_CHALLAN_AMOUNT = Qry.Total_Amount 
			FROM #ESIC_SUMMARY ES
			INNER JOIN 
			(
				SELECT EM.Present_State AS [State],BM.Branch_Name ,COUNT(EM.Emp_ID) AS NO_OF_EMP,SUM(MS.Gross_Salary) AS GROSS_SALARY,
				SUM(ISNULL(MD.M_AD_Amount,0) + ISNULL(ES.M_AD_Amount,0) + ISNULL(MD.M_AREAR_AMOUNT,0) + ISNULL(MD.M_AREAR_AMOUNT_cutoff,0)) AS ESIC_Amount
				,SUM(CEILING(ISNULL(G.ESIC_EMPLOYER_CONTRIBUTION,0)  * (ISNULL(M_AD_Calculated_Amount,0) + ISNULL(ES.M_AD_Calculate_Amount,0)) /100)) AS ESIC_EMPLYER
				,SUM(EC.Total_Amount) AS Total_Amount
				FROM T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join
					 T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EM.Emp_ID = Ms.Emp_ID Inner JOIn
					 T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) ON MS.Sal_Tran_ID = MD.sal_Tran_ID Inner JOin
					 T0050_AD_MASTER AM WITH (NOLOCK) ON AM.AD_ID = MD.AD_ID Inner JOIn
					  (SELECT I.Branch_ID,I.Emp_ID,I.Desig_Id FROM T0095_Increment I WITH (NOLOCK) inner join 
									( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)	
									WHERE Increment_Effective_date <= @To_Date
									GROUP BY emp_ID  ) Qry ON
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID ) Q_I ON
						 EM.EMP_ID = Q_I.EMP_ID Inner JOIN
					 T0030_branch_master BM WITH (NOLOCK) ON  Q_I.Branch_Id = BM.Branch_ID 
					 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.Desig_ID = Q_I.Desig_Id  
					 LEFT OUTER JOIN #Gen G ON G.Branch_ID = Q_I.Branch_ID 
					 LEFT OUTER JOIN #Emp_Settlement ES ON MD.Emp_ID = ES.Emp_ID AND MD.For_Date = ES.For_Date 
					 LEFT OUTER JOIN T0220_ESIC_Challan EC WITH (NOLOCK) ON EC.MONTH=MONTH(@To_Date) AND EC.YEAR= YEAR(@To_Date)
				WHERE MONTH(MS.MOnth_End_Date ) = MONTH(@To_Date) AND YEAR(MS.MOnth_End_Date ) = YEAR(@To_Date)
				 AND AM.AD_Def_ID = 3  
				 AND MS.Cmp_ID = @Cmp_ID
				AND EM.EMP_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
				 AND MD.Sal_Type<>1 AND MD.M_AD_Amount > 0 AND MS.Is_FNF = 0
				GROUP BY EM.Present_State,BM.Branch_Name
			)Qry ON ES.STATE = Qry.State 
		
			--for fnf (left) emp update
			 UPDATE ES
			 SET BRANCH_NAME = Qry.Branch_Name 
			,NO_OF_EMP_FFS = Qry.NO_OF_EMP
			,GROSS_SALARY_FFS = Qry.GROSS_SALARY 
			,ESIC_EMPLOYEE_FFS = Qry.ESIC_Amount 
			,ESIC_EMPLOYER_FFS = Qry.ESIC_EMPLYER 
			,TOTAL_CHALLAN_AMOUNT = Qry.Total_Amount 
			 FROM #ESIC_SUMMARY ES
			INNER JOIN 
			(
				SELECT EM.Present_State AS [State],BM.Branch_Name ,COUNT(EM.Emp_ID) AS NO_OF_EMP,SUM(MS.Gross_Salary) AS GROSS_SALARY,
				SUM(ISNULL(MD.M_AD_Amount,0) + ISNULL(ES.M_AD_Amount,0) + ISNULL(MD.M_AREAR_AMOUNT,0) + ISNULL(MD.M_AREAR_AMOUNT_cutoff,0)) AS ESIC_Amount
				,SUM(CEILING(ISNULL(G.ESIC_EMPLOYER_CONTRIBUTION,0)  * (ISNULL(M_AD_Calculated_Amount,0) + ISNULL(ES.M_AD_Calculate_Amount,0)) /100)) AS ESIC_EMPLYER
				,SUM(EC.Total_Amount) AS Total_Amount
				FROM T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join
					 T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EM.Emp_ID = Ms.Emp_ID Inner JOIn
					 T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) ON MS.Sal_Tran_ID = MD.sal_Tran_ID Inner JOin
					 T0050_AD_MASTER AM WITH (NOLOCK) ON AM.AD_ID = MD.AD_ID Inner JOIn
					  (SELECT I.Branch_ID,I.Emp_ID,I.Desig_Id FROM T0095_Increment I WITH (NOLOCK) inner join 
									( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)	
									WHERE Increment_Effective_date <= @To_Date
									GROUP BY emp_ID  ) Qry ON
									I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID ) Q_I ON
						 EM.EMP_ID = Q_I.EMP_ID Inner JOIN
					 T0030_branch_master BM WITH (NOLOCK) ON  Q_I.Branch_Id = BM.Branch_ID 
					 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.Desig_ID = Q_I.Desig_Id  
					 LEFT OUTER JOIN #Gen G ON G.Branch_ID = Q_I.Branch_ID 
					 LEFT OUTER JOIN #Emp_Settlement ES ON MD.Emp_ID = ES.Emp_ID AND MD.For_Date = ES.For_Date 
					 LEFT OUTER JOIN T0220_ESIC_Challan EC WITH (NOLOCK) ON EC.MONTH=MONTH(@To_Date) AND EC.YEAR= YEAR(@To_Date)
				WHERE MONTH(MS.MOnth_End_Date ) = MONTH(@To_Date) AND YEAR(MS.MOnth_End_Date ) = YEAR(@To_Date)
				 AND AM.AD_Def_ID = 3  
				 AND MS.Cmp_ID = @Cmp_ID
				AND EM.EMP_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
				 AND MD.Sal_Type<>1 AND MD.M_AD_Amount > 0 AND MS.Is_FNF = 1
				GROUP BY EM.Present_State,BM.Branch_Name
			)Qry ON ES.STATE = Qry.State 
			
			SELECT ROW_NUMBER() OVER(ORDER BY [STATE]) AS SR_NO,[STATE],BRANCH_NAME, NO_OF_EMP,NO_OF_EMP_FFS
			,NO_OF_EMP +NO_OF_EMP_FFS AS TOTAL_EMPLOYEE,GROSS_SALARY,GROSS_SALARY_FFS,GROSS_SALARY +GROSS_SALARY_FFS AS TOTAL_GROSS_SALARY
			,ESIC_EMPLOYEE,ESIC_EMPLOYEE_FFS,ESIC_EMPLOYEE+ESIC_EMPLOYEE_FFS AS TOTAL_EMPLOYEE_PART,ESIC_EMPLOYER,ESIC_EMPLOYER_FFS
			,ESIC_EMPLOYER+ESIC_EMPLOYER_FFS AS TOTAL_EMPLOYER_PART
			,TOTAL_CHALLAN_AMOUNT
			FROM #ESIC_SUMMARY
			
			
		END


