-- =============================================
-- Author:		<Ankit >
-- Create date: <15122014,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_PF_ESIC_REPORT_DETAIL]
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
	,@Order_By		varchar(30) = 'Code' --Added by Jimit 28/9/2015 (To sort by Code/Name/Enroll No)

AS
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
		
	--added by chetan 05102017
	CREATE table #Emp_Settlement
	(
		Emp_ID	numeric,
		For_Date Datetime,
		M_AD_Calculate_Amount Numeric(18,2),
		M_AD_Percentage Numeric(18,2),
		M_AD_Amount Numeric(18,2),
		Ad_def_id	tinyint
	)
	---end
		  
	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )  

	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0    
	
	 
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
				   SET @SAL_ST_DATE =  CAST(CAST(DAY(@SAL_ST_DATE)AS VARCHAR(5)) + '-' + CAST(DATENAME(MM,DATEADD(M,-1,@TO_DATE)) AS VARCHAR(10)) + '-' +  CAST(YEAR(DATEADD(M,-1,@TO_DATE) )AS VARCHAR(10)) AS SMALLDATETIME)    
				   SET @SAL_END_DATE = DATEADD(D,-1,DATEADD(M,1,@SAL_ST_DATE))
				   SET @FROM_DATE = @SAL_ST_DATE
				   SET @TO_DATE = @SAL_END_DATE  
				 END
			ELSE
				BEGIN
					SELECT @SAL_ST_DATE=FROM_DATE,@SAL_END_DATE=END_DATE FROM SALARY_PERIOD WHERE MONTH= MONTH(@TO_DATE) AND YEAR=YEAR(@TO_DATE)							   
						SET @FROM_DATE = @SAL_ST_DATE
						SET @TO_DATE = @SAL_END_DATE    
				END	   
		END 
	-------PF-------
	
	IF @Report_Type = 'PF'
		BEGIN	
			SELECT	Alpha_Emp_Code,SSN_No AS PF_NO , EM.UAN_No AS UAN_No, Emp_Full_Name,Father_name,Gender,BM.Branch_ID,BM.Branch_Name,
					Convert(Varchar(12),Date_Of_Birth,5) As Date_Of_Birth,Convert(Varchar(15),Date_Of_Join,5) As Date_OF_Join,Convert(Varchar(15),Emp_Left_Date,5) As DATE_OF_LEFT,Sal_Cal_Days
					,Working_Days AS Month_Days -- Added By Sajid 20102021 for Arkray 
					,Ms.Arear_Day_Previous_month -- Added By Sajid 20102021 for Arkray
					,MS.Gross_Salary AS Gross_Salary
					,MS.Salary_Amount AS PF_Wages
					,Ms.Basic_Salary_Arear_cutoff AS Basic_Arrears_Cutoff  -- Added By Sajid 20102021 for Arkray
					,M_AD_Amount AS PF_Amount_Salary					
					,MD.M_Arear_Amount_Cutoff AS PF_Arrears_Cutoff  -- Added By Sajid 20102021 for Arkray	
					,PF_Amount = M_AD_Amount + MD.M_Arear_Amount_Cutoff
					,DGM.Desig_Dis_No,EM.Enroll_No			
			FROM T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join
				 T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EM.Emp_ID = Ms.Emp_ID Inner JOIn
				 T0210_MONTHLY_AD_DETAIL MD WITH (NOLOCK) ON MS.Sal_Tran_ID = MD.sal_Tran_ID Inner JOin
				 T0050_AD_MASTER AM WITH (NOLOCK) ON AM.AD_ID = MD.AD_ID Inner JOIn
				  (SELECT I.Branch_ID,I.Emp_ID,I.Desig_Id FROM T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	
								where Increment_Effective_date <= @To_Date
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID ) Q_I ON
					 EM.EMP_ID = Q_I.EMP_ID Inner JOIN
				 T0030_branch_master BM WITH (NOLOCK) ON  Q_I.Branch_Id = BM.Branch_ID 
				 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.Desig_ID = Q_I.Desig_Id  --added jimit 28/09/2015
			WHERE Month(MS.MOnth_End_Date ) = Month(@To_Date) And Year(MS.MOnth_End_Date ) = Year(@To_Date) And AM.AD_Def_ID = 2 And MS.Cmp_ID = @Cmp_ID
					AND EM.EMP_ID IN (SELECT Emp_ID FROM #Emp_Cons)
					
		---added jimit 28/09/2015			
					ORDER BY CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(EM.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN EM.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN DGM.Desig_dis_No  = 0 THEN DGM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(dgm.Desig_dis_No AS VARCHAR), 21)   END)   
							--ELSE RIGHT(REPLICATE(N' ', 500) + EM.Alpha_Emp_Code, 500) 
						End,Case When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') End 
						--RIGHT(REPLICATE(N' ', 500) + EM.Alpha_Emp_Code, 500)
		END
	
	--------ESIC-------
	IF @Report_Type = 'ESIC'
		BEGIN
			DECLARE @EMPLOYEE_ESIC_DEF_ID numeric 
			DECLARE @EMPLOYER_ESIC_DEF_ID numeric 
			
			SET @EMPLOYEE_ESIC_DEF_ID = 3	--EMPLOYEE ESIC
			SET @EMPLOYER_ESIC_DEF_ID = 6	--EMPLOYER ESIC
			
			--added by chetan 04102017
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
					
					--INSERTING EMPLOYEE ESIC				
					INSERT INTO #Emp_Settlement
					SELECT  SG.EMP_ID, @From_Date as For_Date, SUM(M_AD_Calculated_Amount),ESIC_PER, sum(ESIC_Amount) , ad_def_id
					FROM T0201_MONTHLY_SALARY_SETT  SG WITH (NOLOCK)
					INNER JOIN 
						( Select For_Date, Emp_ID, M_AD_Percentage as ESIC_PER, (M_AD_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_cutoff,0)) as ESIC_Amount, 
								M_AD_Calculated_Amount,S_Sal_Tran_ID , AD_DEF_ID
						  FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
							INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
						  WHERE AD_DEF_ID = @EMPLOYEE_ESIC_DEF_ID And ad_not_effect_salary <> 1 AND ad.sal_type=1
							AND AD.CMP_ID = @CMP_ID
						) MAD ON SG.Emp_ID = MAD.Emp_ID and sg.S_Sal_Tran_ID = mad.S_Sal_Tran_ID--AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID 
					INNER JOIN	#Emp_Cons E_S ON E.Emp_ID = E_S.Emp_ID	
					WHERE   e.CMP_ID = @CMP_ID 
							And S_Eff_Date Between @From_Date And @To_Date
					GROUP BY SG.EMP_ID,ESIC_PER , AD_DEF_ID
					
					--INSERTING EMPLOYER ESIC
					INSERT INTO #Emp_Settlement
					SELECT  SG.EMP_ID, @From_Date as For_Date, SUM(M_AD_Calculated_Amount),ESIC_PER, sum(ESIC_Amount) , ad_def_id
					FROM T0201_MONTHLY_SALARY_SETT  SG WITH (NOLOCK)  
					INNER JOIN 
						( Select For_Date, Emp_ID, M_AD_Percentage as ESIC_PER, (M_AD_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_cutoff,0)) as ESIC_Amount, 
								M_AD_Calculated_Amount,S_Sal_Tran_ID , AD_DEF_ID
						  FROM T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK)
							INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
						  WHERE AD_DEF_ID = @EMPLOYER_ESIC_DEF_ID AND ad.sal_type = 1
							AND AD.CMP_ID = @CMP_ID
						) MAD ON SG.Emp_ID = MAD.Emp_ID and sg.S_Sal_Tran_ID = mad.S_Sal_Tran_ID--AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID 
					INNER JOIN	#Emp_Cons E_S ON E.Emp_ID = E_S.Emp_ID	
					WHERE   e.CMP_ID = @CMP_ID 
							And S_Eff_Date Between @From_Date And @To_Date
					GROUP BY SG.EMP_ID,ESIC_PER , AD_DEF_ID
				END				
			
			
			SELECT	ROW_NUMBER() OVER (ORDER BY CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(EM.Enroll_No AS VARCHAR), 21)
													 WHEN @Order_By='Name' THEN EM.Emp_Full_Name
													 WHEN @Order_By = 'Designation' THEN (CASE WHEN DGM.Desig_dis_No  = 0 
																								THEN DGM.Desig_Name 
																							   ELSE RIGHT(REPLICATE('0',21) + CAST(dgm.Desig_dis_No AS VARCHAR), 21)
																						  END)   
													END,
												CASE WHEN IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 1 THEN Right(Replicate('0',21) + Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"',''), 20)
													 WHEN IsNumeric(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
													 ELSE Replace(Replace(EM.Alpha_Emp_Code,'="',''),'"','') End
									   ) AS Sr_No
					,Alpha_Emp_Code,ISNULL(EMPNAME_ALIAS_PF,Emp_Full_Name) as EMP_FULL_NAME ,Father_name, Gender ,CONVERT(VARCHAR(20) , EM.DATE_OF_BIRTH , 103) As Date_Of_Birth
					,Street_1 + ' ' + City + ' ' + State + ' ' + Zip_code As Address,BM.Branch_ID,BM.Branch_Name,DM.Dept_Name AS DEPARTMENT ,DGM.Desig_Name AS DESIGNATION 
					,GM.Grd_Name AS GRADE,CCM.Center_Name , CCM.CENTER_CODE ,CTM.Cat_Name AS CATEGORY , VS.Vertical_Name AS VERTICAL ,SV.SubVertical_name AS SUBVERTICAL 
					,BS.Segment_Name AS BUSINESS_SEGMENT ,CONVERT(VARCHAR(20) , EM.DATE_OF_JOIN , 103) AS DATE_OF_JOIN
					,CONVERT(VARCHAR(20) , EM.Emp_Left_Date , 103) AS DATE_OF_LEFT   -- Added By Sajid 20102021 for Arkray 
					,SIN_No AS ESIC_NO
					,MS.Sal_Cal_Days as Salary_Days 
					,MS.Arear_Day_Previous_month as Arear_Day_Previous_month -- Added By Sajid 20102021 for Arkray 
					, MS.Gross_Salary
					,MD175.M_AD_Amount + ISNULL(ES_175.M_AD_Amount,0) + Isnull(MD175.M_AREAR_AMOUNT,0) + Isnull(MD175.M_AREAR_AMOUNT_cutoff,0) AS ESIC_EMPLOYEE_CONTRIBUTION
					, CEILING(MD475.M_AD_Amount + ISNULL(ES_475.M_AD_Amount,0) + Isnull(MD475.M_AREAR_AMOUNT,0) + Isnull(MD475.M_AREAR_AMOUNT_cutoff,0)) as ESIC_EMPLOYER_CONTRIBUTION
					--,CEILING(G.ESIC_EMPLOYER_CONTRIBUTION  * (MD175.M_AD_Calculated_Amount + ISNULL(ES.M_AD_Calculate_Amount,0)) /100) AS ESIC_EMPLYER	--added by chetan 05102017
					--,DGM.Desig_Dis_No,EM.Enroll_No 
					,ISNULL(MD175.M_AD_Amount,0) + ISNULL(ES_175.M_AD_Amount,0) + ISNULL(ES_475.M_AD_Amount,0) + Isnull(MD175.M_AREAR_AMOUNT,0) + Isnull(MD175.M_AREAR_AMOUNT_cutoff,0) + ISNULL(MD475.M_AD_Amount,0) + Isnull(MD475.M_AREAR_AMOUNT,0) + Isnull(MD475.M_AREAR_AMOUNT_cutoff,0) as TOTAL_CONTRIBUTION
			INTO	#ESIC_RECORDS
			FROM T0080_EMP_MASTER EM WITH (NOLOCK)
				INNER JOIN		T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EM.Emp_ID = Ms.Emp_ID
				INNER JOIN		T0210_MONTHLY_AD_DETAIL MD175 WITH (NOLOCK) ON MS.Sal_Tran_ID = MD175.sal_Tran_ID	and MD175.S_Sal_Tran_ID is null		--ESIC JOIN
				INNER JOIN		T0050_AD_MASTER AM175  WITH (NOLOCK) ON AM175.AD_ID = MD175.AD_ID  AND AM175.AD_Def_ID = 3
				INNER JOIN		T0210_MONTHLY_AD_DETAIL MD475 WITH (NOLOCK) ON MS.Sal_Tran_ID = MD475.sal_Tran_ID and MD475.S_Sal_Tran_ID is null				--COMPANY ESIC JOIN
				INNER JOIN		T0050_AD_MASTER AM475 WITH (NOLOCK)  ON AM475.AD_ID = MD475.AD_ID  AND AM475.AD_Def_ID = 6
				INNER JOIN		#Emp_Cons EC		ON EC.Emp_ID = EM.Emp_ID
				INNER JOIN		T0095_INCREMENT INC	WITH (NOLOCK)	ON EC.Increment_ID = INC.Increment_ID
				INNER JOIN		T0030_BRANCH_MASTER BM WITH (NOLOCK)	ON  INC.Branch_Id = BM.Branch_ID
				INNER JOIN		T0040_GRADE_MASTER GM WITH (NOLOCK)	ON INC.GRD_ID = GM.GRD_ID
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.Desig_ID = INC.Desig_Id --Added jimit 28/09/2015
				LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INC.DEPT_ID = DM.DEPT_ID		--Ramiz 23/10/2018 (start)
				LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON INC.TYPE_ID = TM.TYPE_ID
				LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS WITH (NOLOCK) ON INC.VERTICAL_ID = VS.VERTICAL_ID
				LEFT OUTER JOIN	T0050_SUBVERTICAL SV WITH (NOLOCK) ON INC.SUBVERTICAL_ID = SV.SUBVERTICAL_ID
				LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON INC.Center_ID = CCM.Center_ID
				LEFT OUTER JOIN T0030_CATEGORY_MASTER CTM WITH (NOLOCK) ON INC.Cat_ID = CTM.Cat_ID
				LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) ON INC.Segment_ID = BS.Segment_ID			--Ramiz 23/10/2018 (end)
				--LEFT OUTER JOIN #Gen G ON G.Branch_ID = INC.Branch_ID --added by chetan 05102017
				LEFT OUTER JOIN #Emp_Settlement ES_175 ON MD175.Emp_ID = ES_175.Emp_ID AND MD175.For_Date = ES_175.For_Date and ES_175.AD_DEF_ID = 3
				LEFT OUTER JOIN #Emp_Settlement ES_475 ON MD175.Emp_ID = ES_475.Emp_ID AND MD475.For_Date = ES_475.For_Date and ES_475.AD_DEF_ID = 6
			WHERE Month(MS.MOnth_End_Date ) = Month(@To_Date) And Year(MS.MOnth_End_Date ) = Year(@To_Date)
			And MS.Cmp_ID = @Cmp_ID
					
			--SELECT * FROM #ESIC_RECORDS 
			
			INSERT INTO #ESIC_RECORDS
			( Sr_No , Branch_ID , GRADE , Salary_Days , Arear_Day_Previous_month,  Gross_Salary , ESIC_EMPLOYEE_CONTRIBUTION , ESIC_EMPLOYER_CONTRIBUTION )
			SELECT	99999 , 0 , 0 , 0 ,0, SUM(Gross_Salary), SUM(ESIC_EMPLOYEE_CONTRIBUTION) , SUM(ESIC_EMPLOYER_CONTRIBUTION)
			FROM	#ESIC_RECORDS
			
			SELECT * FROM #ESIC_RECORDS 
			ORDER BY Sr_No
		END




