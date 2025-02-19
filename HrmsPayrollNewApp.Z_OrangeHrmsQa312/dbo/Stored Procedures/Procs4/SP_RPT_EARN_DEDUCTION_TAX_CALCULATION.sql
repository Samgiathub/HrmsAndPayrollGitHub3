

---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EARN_DEDUCTION_TAX_CALCULATION]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		
	,@Vertical_Id numeric = 0		
	,@SubVertical_Id numeric = 0	 
	,@SubBranch_Id numeric = 0		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	IF @Salary_Cycle_id = 0	 
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 
	set @Segment_Id = null
	If @Vertical_Id = 0		 
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 
	set @SubBranch_Id = null	
	
	
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   

	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,'0',1,0
	
	Create Table #Temp_Earning_Comp
	(
		Cmp_ID Numeric,
		EMP_ID Numeric,
		Sal_Month Numeric,
		Sal_Year Numeric,
		E_Basic Numeric(18,2),
		E_FPI Numeric(18,2),
		E_SP Numeric(18,2),
		E_DA Numeric(18,2),
		E_HRA Numeric(18,2),
		E_CCA Numeric(18,2),
		E_IR Numeric(18,2),
		E_CA Numeric(18,2),
		E_OA Numeric(18,2),
		E_TI Numeric(18,2),
		E_CCP Numeric(18,2),--edit by Ronny 17012022 
		R_Total Numeric(18,2)
	)
	
	Create Table #Temp_Deduction_Comp
	(
		Cmp_ID Numeric,
		EMP_ID Numeric,
		Sal_Month Numeric,
		Sal_Year Numeric,
		E_GIS Numeric(18,2),
		E_TSEGIS Numeric(18,2),
		E_TSGLIF Numeric(18,2),
		E_GPF Numeric(18,2),
		E_LIC Numeric(18,2),
		E_IT Numeric(18,2),
		E_PT Numeric(18,2),
		E_HBA Numeric(18,2),
		E_HBA_Int Numeric(18,2),
		R_Total Numeric(18,2)
	)

   Declare @Cur_Emp_ID Numeric
   Declare @temp_From_Date  datetime
	
	
   Declare Cur_Emp_Con Cursor for
   Select EMP_ID From #Emp_Cons
   Open Cur_Emp_Con
   fetch next From Cur_Emp_Con into @Cur_Emp_ID
		While @@fetch_Status = 0
			Begin
				set @temp_From_Date  = @from_Date
				WHILE  @temp_From_Date <=  @To_Date
					Begin
						Insert INTO #Temp_Earning_Comp VALUES(@Cmp_ID,@Cur_Emp_ID,MONTH(@temp_From_Date),YEAR(@temp_From_Date),0,0,0,0,0,0,0,0,0,0,0,0) --edit by Ronny 17012022 
						Insert INTO #Temp_Deduction_Comp VALUES(@Cmp_ID,@Cur_Emp_ID,MONTH(@temp_From_Date),YEAR(@temp_From_Date),0,0,0,0,0,0,0,0,0,0)
						set @temp_From_Date = DATEADD(mm,1,@temp_From_Date)
					End
				 fetch next From Cur_Emp_Con into @Cur_Emp_ID
			End 
	
	Close Cur_Emp_Con	
	
	
	Update EC SET E_Basic = MS.Basic_Salary
	From #Temp_Earning_Comp EC Inner JOIN T0200_MONTHLY_SALARY MS
	On EC.EMP_ID = MS.Emp_ID and Month(MS.Month_End_Date) = EC.Sal_Month and YEAR(MS.Month_End_Date) = EC.Sal_Year
	
	--Update EC SET E_FPI = MAD.M_AD_Amount
	--From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	--On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	--and YEAR(MAD.To_date) = EC.Sal_Year
	--INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	--where AD.AD_SORT_NAME = 'FPI'
	
	Update EC SET E_DA = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'DA'
	
	Update EC SET E_HRA = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'HRA'
	
	Update EC SET E_CCA = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'CCA'
	
	Update EC SET E_IR = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'IR'
	
	Update EC SET E_CA = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'CA'
	
	Update EC SET E_OA = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'OA'
	
	Update EC SET E_TI = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'TI'


	--edit by Ronny 17012022 
	Update EC SET E_CCP = MAD.M_AD_Amount
	From #Temp_Earning_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'CCP'

	--edit by Ronny 17012022 
	Update TP SET R_Total = qry.R_Total 
	From #Temp_Earning_Comp TP Inner JOIN(
	Select (E_Basic + E_DA + E_HRA + E_CCA + E_IR + E_CA + E_OA + E_TI + E_CCP) as R_Total,EMP_ID,Sal_Month,Sal_Year   
	From #Temp_Earning_Comp ) qry
	on qry.EMP_ID = TP.EMP_ID and qry.Sal_Month = TP.Sal_Month and qry.Sal_Year = TP.Sal_Year
	



	--- Dedcuction Temp Table -----
	
	Update EC SET E_GIS = MAD.M_AD_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'GIS'
	
	
	Update EC SET E_TSEGIS = MAD.M_AD_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'TSEGIS'
	
	Update EC SET E_TSGLIF = MAD.M_AD_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'TSGLIF'
	
	Update EC SET E_GPF = MAD.M_AD_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'GPF'
	
	Update EC SET E_LIC = MAD.M_AD_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'LIC'
	
	Update EC SET E_IT = MAD.M_AD_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0210_MONTHLY_AD_DETAIL MAD
	On EC.EMP_ID = MAD.EMP_ID and MONTH(MAD.To_date) = EC.Sal_Month 
	and YEAR(MAD.To_date) = EC.Sal_Year
	INNER JOIN T0050_AD_MASTER AD On AD.AD_ID = MAD.AD_ID
	where AD.AD_SORT_NAME = 'TDS'
	
	
	Update EC SET E_HBA = MLP.Loan_Pay_Amount
	From #Temp_Deduction_Comp EC 
	Inner JOIN T0120_LOAN_APPROVAL LA On LA.Emp_ID = EC.EMP_ID
	inner JOIN T0040_LOAN_MASTER LM  on LM.Loan_ID = LA.Loan_ID
	INNER JOIN T0210_MONTHLY_LOAN_PAYMENT MLP on MLP.Loan_Apr_ID = LA.Loan_Apr_ID
	where LM.Loan_ID IN(39,53) and Month(MLP.Loan_Payment_Date) = EC.Sal_Month and Year(MLP.Loan_Payment_Date) = EC.Sal_Year
	
	Update EC SET E_HBA_Int = MLP.Loan_Pay_Amount
	From #Temp_Deduction_Comp EC 
	Inner JOIN T0120_LOAN_APPROVAL LA On LA.Emp_ID = EC.EMP_ID
	inner JOIN T0040_LOAN_MASTER LM  on LM.Loan_ID = LA.Loan_ID
	INNER JOIN T0210_MONTHLY_LOAN_PAYMENT MLP on MLP.Loan_Apr_ID = LA.Loan_Apr_ID
	where LM.Loan_ID = 40 and Month(MLP.Loan_Payment_Date) = EC.Sal_Month and Year(MLP.Loan_Payment_Date) = EC.Sal_Year
	
	Update EC SET E_PT = MS.PT_Amount
	From #Temp_Deduction_Comp EC Inner JOIN T0200_MONTHLY_SALARY MS
	On EC.EMP_ID = MS.Emp_ID and Month(MS.Month_End_Date) = EC.Sal_Month and YEAR(MS.Month_End_Date) = EC.Sal_Year
	
	Update TP SET R_Total = qry.R_Total 
	From #Temp_Deduction_Comp TP Inner JOIN(
	Select (E_GIS + E_TSEGIS + E_TSGLIF + E_GPF + E_LIC + E_IT + E_PT + E_HBA + E_HBA_Int) as R_Total,EMP_ID,Sal_Month,Sal_Year   
	From #Temp_Deduction_Comp ) qry
	on qry.EMP_ID = TP.EMP_ID and qry.Sal_Month = TP.Sal_Month and qry.Sal_Year = TP.Sal_Year
	
	
	Select DISTINCT UPPER(EM.Emp_Full_Name) as Emp_Full_Name,EM.Alpha_Emp_Code,EC.Emp_ID,CM.Cmp_Name,EM.Pan_No,@From_Date as From_Date,@To_Date as To_Date
	,Isnull(DM.Desig_Name,'') as Desig_Name ,isnull(EM.Mobile_No,0) as Mobile_No
	From #Emp_Cons EC 
	Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = EC.Emp_ID
	Inner JOIN (SELECT I.Emp_ID,I.Desig_Id FROM T0095_INCREMENT I WITH (NOLOCK) 
		INNER JOIN(SELECT max(Increment_Effective_Date) as Effective_date,emp_id 
				   FROM T0095_INCREMENT WITH (NOLOCK) where Increment_Effective_Date <= @To_Date GROUP BY emp_id
				   ) Qry
		ON I.Increment_Effective_Date = Qry.Effective_date and I.Emp_ID = Qry.Emp_id
		) as I_Q
	ON I_Q.Emp_ID = EC.Emp_ID
	Left outer Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On I_Q.Desig_Id = DM.Desig_ID
	Inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.Cmp_Id = EM.Cmp_ID
	
	Select * From #Temp_Earning_Comp
	
	Select * From #Temp_Deduction_Comp
	
	RETURN 
