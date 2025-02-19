

-- =============================================
-- Author:		<Author,,Jimit Soni>
-- Create date: <Create Date,,26112018>
-- Description:	<Description,,Payroll Variance Report For G&D>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_SALARY_VARIANCE_REGISTER]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric  = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric	 = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric  = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''	
	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		
	DECLARE @MONTH AS NUMERIC(18,0)
	DECLARE @YEAR AS NUMERIC(18,0)
	
	DECLARE @PREV_MONTH AS NUMERIC(18,0)
	DECLARE @PREV_YEAR AS NUMERIC(18,0)
	
	DECLARE @GROSS_SALARY AS NUMERIC(18,2)
	
		
	CREATE TABLE #SALARY_VARIANCE_REPORT		
		(
			EMP_ID			NUMERIC(18, 0) NOT NULL,
			CMP_ID			NUMERIC(18, 0) NOT NULL,			
			EMPLOYEE_CODE  VARCHAR(20),
			EMPLOYEE_NAME  	VARCHAR(200),			
			DATE_OF_JOIN	VARCHAR(12)				
		)
		
		IF @BRANCH_ID = 0
			SET @BRANCH_ID = NULL
		IF @CAT_ID = 0
			SET @CAT_ID = NULL		 
		IF @TYPE_ID = 0
			SET @TYPE_ID = NULL
		IF @DEPT_ID = 0
			SET @DEPT_ID = NULL
		IF @GRD_ID = 0
			SET @GRD_ID = NULL
		IF @EMP_ID = 0
			SET @EMP_ID = NULL		
		IF @DESIG_ID = 0
			SET @DESIG_ID = NULL	
		
	
			SET @MONTH = MONTH(@TO_DATE)
			SET @YEAR = YEAR(@TO_DATE)
	  
			SET @PREV_MONTH = DATEPART(M,DATEADD(M,-1,@TO_DATE))
			IF @PREV_MONTH = 12 
				SET @PREV_YEAR = @YEAR - 1
			ELSE
				SET @PREV_YEAR = @YEAR
				
			DECLARE @TO_DATE_CURRENT_MONTH AS DATETIME
			DECLARE @TO_DATE_PREVIOUS_MONTH AS DATETIME

			SELECT @TO_DATE_CURRENT_MONTH = DBO.GET_MONTH_END_DATE(@MONTH,@YEAR)
			SELECT @TO_DATE_PREVIOUS_MONTH = DBO.GET_MONTH_END_DATE(@PREV_MONTH,@PREV_YEAR)

				CREATE TABLE #EMP_CONS 
				 (      
				   EMP_ID NUMERIC ,     
				   BRANCH_ID NUMERIC,
				   INCREMENT_ID NUMERIC    
				 )   
	 
					EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,
											  @EMP_ID,@CONSTRAINT,0

				
					INSERT INTO #SALARY_VARIANCE_REPORT
								(EMP_ID,CMP_ID,EMPLOYEE_NAME,EMPLOYEE_CODE,DATE_OF_JOIN)
					SELECT	EC.EMP_ID,@CMP_ID,EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,CONVERT(VARCHAR(12),DATE_OF_JOIN,103) AS DATE_OF_JOIN
					FROM	#EMP_CONS EC INNER JOIN 
							T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = EC.EMP_ID	
					WHERE   CMP_ID = @CMP_ID		
	
					DECLARE @SQL as VARCHAR(Max)
					SET @SQL = ' ALTER TABLE  #Salary_Variance_Report ADD Vendor_Code_Previous Varchar(20) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Vendor_Code_New Varchar(20) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_1  Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_1 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Designation_Previous Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Designation_New  Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_2 Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_2 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Cost_Center_Code_Previous Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Cost_Center_Code_New Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_3 Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_3 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD UAN_Previous Varchar(50) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD UAN_New Varchar(50) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_4 Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_4 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD PAN_Previous Varchar(50) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD PAN_New Varchar(50) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_5 Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_5 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Basic_Previous Numeric(18,2) default 0 not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Basic_New Numeric(18,2) default 0 not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_6 Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_6 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Total_Earning_Previous Numeric(18,2) default 0 not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Total_Earning_New Numeric(18,2) default 0 not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_7 Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_7 Varchar(100) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Bank_Account_Previous Varchar(20) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Bank_Account_New Varchar(20) default '''';
								 ALTER TABLE  #Salary_Variance_Report ADD Validation_8  Varchar(5) default ''False'' not null;
								 ALTER TABLE  #Salary_Variance_Report ADD Remark_8 Varchar(100) default '''';	
								 '
					EXEC(@SQL)					
					
					UPDATE	SVR					
					SET		SVR.Designation_NEW = ISNULL(Q_NEW.Desig_Name,''),
							SVR.Cost_Center_Code_New = ISNULL(Q_NEW.Center_Code,''),
							SVR.UAN_New = ISNULL(Q_NEW.UAN_No,''),
							SVR.PAN_New = ISNULL(Q_NEW.Pan_No,''),
							SVR.Bank_Account_New = ISNULL(Q_NEW.Inc_Bank_AC_No,0),
							SVR.Vendor_Code_New = Q_NEW.Value,
							SVR.Designation_Previous = ISNULL(Q_Previous.Desig_Name,''),
							SVR.Cost_Center_Code_Previous = ISNULL(Q_Previous.Center_Code,''),
							SVR.UAN_Previous = ISNULL(Q_Previous.UAN_No,''),
							SVR.PAN_Previous = ISNULL(Q_Previous.Pan_No,''),
							SVR.Bank_Account_Previous = ISNULL(Q_Previous.Inc_Bank_AC_No,0),
							SVR.Vendor_Code_Previous = Q_Previous.Value,
							SVr.Validation_1 = (CASE WHEN Q_NEW.Value = ISNULL(Q_Previous.Value,'') THEN 'True' ELSe 'False' ENd),
							SVr.Validation_2 = (CASE WHEN Q_NEW.Desig_Name = ISNULL(Q_Previous.Desig_Name,'') THEN 'True' ELSe 'False' ENd),
							SVr.Validation_3 = (CASE WHEN Q_NEW.Center_Code = ISNULL(Q_Previous.Center_Code,'') THEN 'True' ELSe 'False' ENd),
							SVr.Validation_4 = (CASE WHEN Q_NEW.UAN_No = ISNULL(Q_Previous.UAN_No,'')  THEN 'True' ELSe 'False' ENd),
							SVr.Validation_5 = (CASE WHEN Q_NEW.Pan_No = ISNULL(Q_Previous.Pan_No,'') THEN 'True' ELSe 'False' ENd),
							SVr.Validation_8 = (CASE WHEN Q_NEW.Inc_Bank_AC_No = ISNULL(Q_Previous.Inc_Bank_AC_No,0) THEN 'True' ELSe 'False' ENd)

					FROM	#Emp_Cons EC INNER JOIN
							#SALARY_VARIANCE_REPORT SVR ON SVR.EMP_ID = EC.EMP_ID INNER JOIN							
							(
								SELECT  Desig_Name,Center_Code,UAN_NO,Pan_No,EM.Emp_ID,I.Inc_Bank_AC_No,EMC.Value
								FROM	T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
										T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = EM.Emp_ID INNER JOIN																					
										(
											SELECT MAX(IE.INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
												(
													SELECT	I.EMP_ID,MAX(INCREMENT_EFFECTIVE_DATE) AS EFFECTIVE_DATE
													FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
															#EMP_CONS EC ON EC.EMP_ID = I.EMP_Id
													WHERE	INCREMENT_EFFECTIVE_DATE <= @To_date_Current_month AND CMP_ID = @CMP_ID 																						
													GROUP BY I.EMP_ID
												)AS INN_QRY ON IE.EMP_ID = INN_QRY.EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE = INN_QRY.EFFECTIVE_DATE
											GROUP BY IE.EMP_ID
										
										) AS QRY ON I.INCREMENT_ID = QRY.INCREMENT_ID AND I.EMP_ID = QRY.EMP_ID LEFT OUTER JOIN
										T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id LEFT OUTER JOIN
										T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.Center_ID = I.Center_ID LEFT OUTER JOIN						
							T0082_EMP_COLUMN EMC WITH (NOLOCK) ON EM.Emp_Id = EMC.Emp_Id INNER JOIN  
							T0081_CUSTOMIZED_COLUMN CUC	WITH (NOLOCK) ON CUC.Tran_Id = EMC.mst_Tran_Id AND CUC.Column_Name like '%SAP%' 
							)Q_NEW ON Q_NEW.EMP_Id = SVR.EMP_ID INNER JOIN							
							(
								SELECT  Desig_Name,Center_Code,UAN_NO,Pan_No,EM.Emp_ID,I.Inc_Bank_AC_No,EMC.Value
								FROM	T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
										T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = EM.Emp_ID INNER JOIN																					
										(
											SELECT MAX(IE.INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE WITH (NOLOCK) INNER JOIN
												(
													SELECT	I.EMP_ID,MAX(INCREMENT_EFFECTIVE_DATE) AS EFFECTIVE_DATE
													FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
															#EMP_CONS EC ON EC.EMP_ID = I.EMP_Id
													WHERE	INCREMENT_EFFECTIVE_DATE <= @To_date_Previous_month AND CMP_ID = @CMP_ID 																						
													GROUP BY I.EMP_ID
												)AS INN_QRY ON IE.EMP_ID = INN_QRY.EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE = INN_QRY.EFFECTIVE_DATE
											GROUP BY IE.EMP_ID
										
										) AS QRY ON I.INCREMENT_ID = QRY.INCREMENT_ID AND I.EMP_ID = QRY.EMP_ID LEFT OUTER JOIN
										T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id LEFT OUTER JOIN
										T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.Center_ID = I.Center_ID LEFT OUTER JOIN						
							T0082_EMP_COLUMN EMC WITH (NOLOCK) ON EM.Emp_Id = EMC.Emp_Id INNER JOIN  
							T0081_CUSTOMIZED_COLUMN CUC	WITH (NOLOCK) ON CUC.Tran_Id = EMC.mst_Tran_Id AND CUC.Column_Name like '%SAP%' 
							)Q_Previous ON Q_Previous.EMP_Id = SVR.EMP_ID
					WHERE	SVR.Emp_ID = EC.Emp_ID					
					
					--UPDATE	SVR					
					--SET		SVR.Designation_Previous = ISNULL(DM.Desig_Name,''),
					--		SVR.Cost_Center_Code_Previous = ISNULL(CC.Center_Code,''),
					--		SVR.UAN_Previous = ISNULL(UAN_No,''),
					--		SVR.PAN_Previous = ISNULL(Pan_No,''),
					--		SVR.Bank_Account_Previous = ISNULL(I.Inc_Bank_AC_No,0),
					--		SVr.Validation_1 = (CASE WHEN SVR.Designation_NEW = ISNULL(DM.Desig_Name,'') THEN 'True' ELSe 'False' ENd),
					--		SVr.Validation_2 = (CASE WHEN SVR.Cost_Center_Code_New = ISNULL(CC.Center_Code,'') THEN 'True' ELSe 'False' ENd),
					--		SVr.Validation_3 = (CASE WHEN SVR.UAN_New = ISNULL(UAN_No,'')  THEN 'True' ELSe 'False' ENd),
					--		SVr.Validation_4 = (CASE WHEN SVR.PAN_New = ISNULL(Pan_No,'') THEN 'True' ELSe 'False' ENd),
					--		SVr.Validation_7 = (CASE WHEN SVR.Bank_Account_New = ISNULL(I.Inc_Bank_AC_No,0) THEN 'True' ELSe 'False' ENd)
					--FROM	#Emp_Cons EC INNER JOIN
					--		#SALARY_VARIANCE_REPORT SVR ON SVR.EMP_ID = EC.EMP_ID INNER JOIN
					--		T0080_EMP_MASTER EM ON EM.EMP_Id = EC.EMP_Id INNER JOIN
					--		T0095_INCREMENT I ON EC.EMP_ID = I.EMP_ID INNER JOIN																					
					--		(
					--			SELECT MAX(IE.INCREMENT_ID) AS INCREMENT_ID,IE.EMP_ID FROM T0095_INCREMENT IE INNER JOIN
					--					(
					--						SELECT	I.EMP_ID,MAX(INCREMENT_EFFECTIVE_DATE) AS EFFECTIVE_DATE
					--						FROM	T0095_INCREMENT INNER JOIN
					--								#EMP_CONS EC ON EC.EMP_ID = I.EMP_Id
					--						WHERE	INCREMENT_EFFECTIVE_DATE <= @To_date_Previous_month AND CMP_ID = @CMP_ID 																						
					--						GROUP BY I.EMP_ID
					--					)AS INN_QRY ON IE.EMP_ID = INN_QRY.EMP_ID AND IE.INCREMENT_EFFECTIVE_DATE = INN_QRY.EFFECTIVE_DATE
					--			GROUP BY IE.EMP_ID
					--		) AS QRY ON I.INCREMENT_ID = QRY.INCREMENT_ID AND I.EMP_ID = QRY.EMP_ID INNER JOIn
					--		T0040_DESIGNATION_MASTER DM ON DM.Desig_ID = I.Desig_Id LEFT OUTER JOIN
					--		T0040_COST_CENTER_MASTER CC ON CC.Center_ID = I.Center_ID
					--WHERE	SVR.Emp_ID = EC.Emp_ID
					
					UPDATE	SVR					
					SET		Basic_New = ISNULL(Q_NEW.Salary_Amount,0),
							Total_Earning_New = ISNULL(Q_NEW.Gross_Salary,0),
							Basic_Previous = ISNULL(Q_Previous.Salary_Amount,0),
							Total_Earning_Previous = ISNULL(Q_Previous.Gross_Salary,0),
							SVr.Validation_6 = (CASE WHEN Q_NEW.Salary_Amount = IsNULL(Q_Previous.Salary_Amount,0) THEN 'True' ELSe 'False' ENd),
							SVr.Validation_7 = (CASE WHEN Q_NEW.Gross_Salary = ISNULL(Q_Previous.Gross_Salary,0) THEN 'True' ELSe 'False' ENd)
					FROM	#SALARY_VARIANCE_REPORT SVR INNER JOIN
							( 
								select  Salary_Amount,Gross_Salary,EC.Emp_ID,Month(MS.Month_End_Date) as [Month],Year(MS.Month_End_Date) as [Year]
								from 	T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner Join
										#Emp_Cons EC  ON MS.Emp_ID = EC.Emp_ID  and
										Month(MS.Month_End_Date) = @month  AND Year(Ms.Month_End_Date) = @Year
								where	cmp_Id = @Cmp_ID		 
							)Q_NEW ON Q_NEW.EMP_ID = SVR.EMP_ID  INNER JOIN
							( 
								select  Salary_Amount,Gross_Salary,EC.Emp_ID,Month(MS.Month_End_Date) as [Month],Year(MS.Month_End_Date) as [Year]
								from 	T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner Join
										#Emp_Cons EC  ON MS.Emp_ID = EC.Emp_ID  and
										Month(MS.Month_End_Date) = @Prev_month AND Year(Ms.Month_End_Date) = @Prev_Year
								where	cmp_Id = @Cmp_ID
							)Q_Previous ON Q_Previous.EMP_ID = SVR.EMP_ID 
					WHERE   SVR.Emp_ID = Q_NEW.Emp_ID --and Q_NEW.Month = @month AND Q_NEW.Year  = @Year
												
					--UPDATE	SVR					
					--SET		Basic_Previous = ISNULL(Ms.Salary_Amount,0),
					--		Total_Earning_Previous = ISNULL(Ms.Gross_Salary,0),
					--		SVr.Validation_5 = (CASE WHEN SVR.Basic_New = IsNULL(Ms.Salary_Amount,0) THEN 'True' ELSe 'False' ENd),
					--		SVr.Validation_6 = (CASE WHEN SVR.Total_Earning_New = ISNULL(Ms.Gross_Salary,0) THEN 'True' ELSe 'False' ENd)
					--FROM	#Emp_Cons EC INNER JOIN
					--		T0200_MONTHLY_SALARY MS ON MS.Emp_ID = EC.Emp_ID Inner Join
					--		#SALARY_VARIANCE_REPORT SVR ON MS.Emp_ID = SVR.Emp_ID and
					--		Month(MS.Month_End_Date) = @Prev_month AND Year(Ms.Month_End_Date) = @Prev_Year 
					--WHERE   SVR.Emp_ID = EC.Emp_ID and Month(MS.Month_End_Date) = @Prev_month AND
					--		Year(MS.Month_End_Date) = @Prev_Year					
					
					
					
					--SELECT Row_Number() Over(Order By Emp_ID) as Sr_No,* 
					--INTO   #SALARY_VARIANCE_REPORT_FINAL
					--FROM   #SALARY_VARIANCE_REPORT

					
					ALTER TABLE  #SALARY_VARIANCE_REPORT
					DROP COLUMN EMP_Id
					ALTER TABLE  #SALARY_VARIANCE_REPORT 
					DROP COLUMN CMP_Id
											
					SELECT	Row_Number() Over(Order By EMPLOYEE_CODE) as Sr_No,*
					FROM	#SALARY_VARIANCE_REPORT  
	
	RETURN

