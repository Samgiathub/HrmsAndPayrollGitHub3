
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_EMP_Bonus_Slabwise_Export]      
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
	  
	Select ROW_NUMBER()Over(ORDER BY BS.Emp_ID) as Row_No,
		   E.Emp_code,
			--Replace(Convert(Varchar(11),@FROM_DATE,104),'.','/') as From_Date,
			--Replace(Convert(Varchar(11),@TO_DATE,104),'.','/') as To_Date,
		   @FROM_DATE as From_Date,
		   @TO_DATE as To_Date,
		   E.Alpha_Emp_Code,
		   E.Emp_Full_Name,
		   BM.Branch_Name,
		   DPM.Dept_Name,
		   DM.Desig_Name,
		   GM.Grd_Name,
		   VS.Vertical_Name,
		   TM.Type_Name,
		   SV.SubVertical_Name,
		   Replace(Convert(Varchar(11),Date_Of_Join,104),'.','/') as Date_Of_Join,
		   BS.Gross_Salary,
		   BS.Paid_Day,
		   BS.Extra_Paid_Days,
		  (BS.Paid_Day + BS.Extra_Paid_Days) As Total_Eligilable,
		   BS.Additional_Amount As Last_Year_Hold_Bonus,
		   BS.Bonus_Amount as Bonus,
		   (BS.Additional_Amount + BS.Bonus_Amount) as Total_Bonus,
		   Isnull(INC_QRY.Payment_Mode,'') as Payment_Mode,
		   Isnull(BBM.Bank_Name,'') as Bank_Name,
		   Isnull(INC_QRY.Inc_Bank_AC_No,'') as Inc_Bank_AC_No,
		   CM.Cmp_Name,
		   CM.Cmp_Address,
		   BM.Branch_Address,
		   BM.Comp_Name,
		   BM.Branch_ID as Branch
	FROM	T0080_EMP_MASTER E WITH (NOLOCK)	INNER JOIN
			(		
				SELECT I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,
					   I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,
					   I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID,I.Bank_ID
				FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
					(	 
						SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,EMP_ID 
						FROM T0095_INCREMENT WITH (NOLOCK)  
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @CMP_ID
					    GROUP BY EMP_ID  
					) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID 
			)As INC_QRY ON  E.EMP_ID = INC_QRY.EMP_ID INNER JOIN
	#EMP_CONS EC ON E.EMP_ID = EC.EMP_ID INNER JOIN
	T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID INNER JOIN
	T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = INC_QRY.BRANCH_ID LEFT JOIN 
	T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC_QRY.DESIG_ID LEFT OUTER JOIN
	T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK) ON DPM.DEPT_ID = INC_QRY.DEPT_ID INNER JOIN
	T0100_BONUS_SLABWISE BS WITH (NOLOCK) ON BS.EMP_ID = EC.EMP_ID Left Outer JOIN
	T0040_BANK_MASTER BBM WITH (NOLOCK) ON BBM.Bank_ID = INC_QRY.Bank_ID	Inner JOIN
	T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = E.Grd_ID LEFT OUTER JOIN
	T0040_Vertical_Segment VS WITH (NOLOCK) ON VS.Vertical_ID = INC_QRY.Vertical_ID LEFT OUTER JOIN
	T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID = INC_QRY.SubVertical_ID LEFT OUTER JOIN
	T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.Type_ID = INC_QRY.Type_ID
	WHERE BS.FROM_DATE BETWEEN @FROM_DATE AND @TO_DATE
	Order BY E.Emp_ID,E.Alpha_Emp_Code
  
	
				

